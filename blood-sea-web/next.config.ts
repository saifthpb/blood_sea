import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Removed output: 'export' to enable API routes
  trailingSlash: true,
  images: {
    unoptimized: true
  },
  // Enable experimental features for better API support
  experimental: {
    serverComponentsExternalPackages: ['firebase-admin']
  }
};

export default nextConfig;
