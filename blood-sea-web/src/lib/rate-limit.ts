import { NextRequest, NextResponse } from 'next/server';
import { LRUCache } from 'lru-cache';
import { logger } from './logger';

interface RateLimitOptions {
  windowMs: number; // Time window in milliseconds
  maxRequests: number; // Maximum requests per window
  message?: string; // Custom error message
  keyGenerator?: (request: NextRequest) => string; // Custom key generator function
  onLimitReached?: (key: string, request: NextRequest) => void; // Callback when limit is reached
}

interface RateLimitEntry {
  count: number;
  resetTime: number;
}

// Default rate limit configurations
export const RateLimitConfigs = {
  // General API rate limiting: 100 requests per 15 minutes
  general: {
    windowMs: 15 * 60 * 1000,
    maxRequests: 100,
    message: 'Too many requests from this IP, please try again later.'
  },
  
  // Notification-specific rate limiting: 10 requests per minute
  notifications: {
    windowMs: 1 * 60 * 1000,
    maxRequests: 10,
    message: 'Too many notification requests, please try again later.'
  },
  
  // Authentication rate limiting: 5 attempts per 5 minutes
  auth: {
    windowMs: 5 * 60 * 1000,
    maxRequests: 5,
    message: 'Too many authentication attempts, please try again later.'
  },
  
  // Blood request rate limiting: 5 requests per hour
  bloodRequests: {
    windowMs: 60 * 60 * 1000,
    maxRequests: 5,
    message: 'Too many blood request submissions, please try again later.'
  }
};

// Global cache for rate limit entries
const rateLimitCache = new LRUCache<string, RateLimitEntry>({
  max: 10000, // Maximum number of entries
  ttl: 24 * 60 * 60 * 1000, // 24 hours TTL
});

/**
 * Get client IP address from request
 */
function getClientIP(request: NextRequest): string {
  // Try various headers that might contain the real IP
  const forwarded = request.headers.get('x-forwarded-for');
  const realIP = request.headers.get('x-real-ip');
  const remoteAddr = request.headers.get('x-remote-addr');
  
  if (forwarded) {
    // x-forwarded-for can contain multiple IPs, take the first one
    return forwarded.split(',')[0].trim();
  }
  
  if (realIP) {
    return realIP;
  }
  
  if (remoteAddr) {
    return remoteAddr;
  }
  
  // Fallback to connection remote address (might not be available in all environments)
  return request.ip || 'unknown';
}

/**
 * Default key generator using IP address
 */
function defaultKeyGenerator(request: NextRequest): string {
  return getClientIP(request);
}

/**
 * User-based key generator (requires authenticated user)
 */
export function userBasedKeyGenerator(userId: string): string {
  return `user:${userId}`;
}

/**
 * Combined IP and endpoint key generator
 */
export function endpointKeyGenerator(request: NextRequest): string {
  const ip = getClientIP(request);
  const pathname = new URL(request.url).pathname;
  return `${ip}:${pathname}`;
}

/**
 * Rate limiting middleware
 */
export function createRateLimit(options: RateLimitOptions) {
  const {
    windowMs,
    maxRequests,
    message = 'Rate limit exceeded',
    keyGenerator = defaultKeyGenerator,
    onLimitReached
  } = options;

  return async function rateLimit(request: NextRequest): Promise<NextResponse | null> {
    try {
      const key = keyGenerator(request);
      const now = Date.now();
      const windowStart = now - windowMs;
      
      // Get or create rate limit entry
      let entry = rateLimitCache.get(key);
      
      if (!entry || entry.resetTime <= now) {
        // Create new entry or reset expired entry
        entry = {
          count: 1,
          resetTime: now + windowMs
        };
        rateLimitCache.set(key, entry);
        
        return null; // Allow request
      }
      
      if (entry.count >= maxRequests) {
        // Rate limit exceeded
        logger.warn('Rate limit exceeded', {
          key,
          count: entry.count,
          maxRequests,
          windowMs,
          ip: getClientIP(request),
          userAgent: request.headers.get('user-agent'),
          url: request.url
        });
        
        if (onLimitReached) {
          onLimitReached(key, request);
        }
        
        return NextResponse.json(
          {
            success: false,
            message,
            retryAfter: Math.ceil((entry.resetTime - now) / 1000)
          },
          { 
            status: 429,
            headers: {
              'Retry-After': Math.ceil((entry.resetTime - now) / 1000).toString(),
              'X-RateLimit-Limit': maxRequests.toString(),
              'X-RateLimit-Remaining': '0',
              'X-RateLimit-Reset': entry.resetTime.toString()
            }
          }
        );
      }
      
      // Increment counter
      entry.count++;
      rateLimitCache.set(key, entry);
      
      return null; // Allow request
    } catch (error) {
      logger.error('Rate limiting error:', error as Error);
      return null; // Allow request on error (fail open)
    }
  };
}

/**
 * Higher-order function to wrap API route with rate limiting
 */
export function withRateLimit(
  options: RateLimitOptions,
  handler: (request: NextRequest) => Promise<NextResponse>
) {
  const rateLimit = createRateLimit(options);
  
  return async function(request: NextRequest): Promise<NextResponse> {
    const rateLimitResponse = await rateLimit(request);
    
    if (rateLimitResponse) {
      return rateLimitResponse;
    }
    
    return handler(request);
  };
}

/**
 * Preset rate limiters for common use cases
 */
export const RateLimiters = {
  general: createRateLimit(RateLimitConfigs.general),
  notifications: createRateLimit(RateLimitConfigs.notifications),
  auth: createRateLimit(RateLimitConfigs.auth),
  bloodRequests: createRateLimit(RateLimitConfigs.bloodRequests)
};

/**
 * Advanced rate limiter with sliding window
 */
export class SlidingWindowRateLimit {
  private cache: LRUCache<string, number[]>;
  private windowMs: number;
  private maxRequests: number;
  
  constructor(windowMs: number, maxRequests: number) {
    this.windowMs = windowMs;
    this.maxRequests = maxRequests;
    this.cache = new LRUCache<string, number[]>({
      max: 10000,
      ttl: windowMs * 2 // Keep entries for 2 windows
    });
  }
  
  async check(key: string): Promise<{ allowed: boolean; remaining: number; resetTime: number }> {
    const now = Date.now();
    const windowStart = now - this.windowMs;
    
    // Get request timestamps for this key
    let timestamps = this.cache.get(key) || [];
    
    // Remove timestamps outside the current window
    timestamps = timestamps.filter(timestamp => timestamp > windowStart);
    
    const allowed = timestamps.length < this.maxRequests;
    const remaining = Math.max(0, this.maxRequests - timestamps.length);
    const resetTime = timestamps.length > 0 ? timestamps[0] + this.windowMs : now + this.windowMs;
    
    if (allowed) {
      timestamps.push(now);
      this.cache.set(key, timestamps);
    }
    
    return {
      allowed,
      remaining,
      resetTime
    };
  }
}

/**
 * Burst rate limiter (allows short bursts but limits sustained usage)
 */
export class BurstRateLimit {
  private shortTermLimit: SlidingWindowRateLimit;
  private longTermLimit: SlidingWindowRateLimit;
  
  constructor(
    shortWindowMs: number,
    shortMaxRequests: number,
    longWindowMs: number,
    longMaxRequests: number
  ) {
    this.shortTermLimit = new SlidingWindowRateLimit(shortWindowMs, shortMaxRequests);
    this.longTermLimit = new SlidingWindowRateLimit(longWindowMs, longMaxRequests);
  }
  
  async check(key: string): Promise<{ allowed: boolean; reason?: string; resetTime: number }> {
    const shortTerm = await this.shortTermLimit.check(key);
    const longTerm = await this.longTermLimit.check(key);
    
    if (!shortTerm.allowed) {
      return {
        allowed: false,
        reason: 'Short-term rate limit exceeded',
        resetTime: shortTerm.resetTime
      };
    }
    
    if (!longTerm.allowed) {
      return {
        allowed: false,
        reason: 'Long-term rate limit exceeded',
        resetTime: longTerm.resetTime
      };
    }
    
    return {
      allowed: true,
      resetTime: Math.min(shortTerm.resetTime, longTerm.resetTime)
    };
  }
}

/**
 * Reset rate limit for a specific key (useful for testing or admin overrides)
 */
export function resetRateLimit(key: string): void {
  rateLimitCache.delete(key);
}

/**
 * Get current rate limit status for a key
 */
export function getRateLimitStatus(key: string): RateLimitEntry | undefined {
  return rateLimitCache.get(key);
}

/**
 * Clear all rate limit entries (useful for testing)
 */
export function clearAllRateLimits(): void {
  rateLimitCache.clear();
}

export default {
  createRateLimit,
  withRateLimit,
  RateLimiters,
  RateLimitConfigs,
  SlidingWindowRateLimit,
  BurstRateLimit,
  userBasedKeyGenerator,
  endpointKeyGenerator,
  resetRateLimit,
  getRateLimitStatus,
  clearAllRateLimits
};
