'use client';

import Link from 'next/link';
import { useAuth } from '@/contexts/AuthContext';
import { usePathname } from 'next/navigation';
import { useState } from 'react';

export default function Navigation() {
  const { user, logout } = useAuth();
  const pathname = usePathname();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  // Don't show navigation on login page
  if (pathname === '/login') {
    return null;
  }

  const handleLogout = async () => {
    try {
      await logout();
      setIsMobileMenuOpen(false);
    } catch (error) {
      console.error('Failed to log out:', error);
    }
  };

  const closeMobileMenu = () => {
    setIsMobileMenuOpen(false);
  };

  return (
    <nav className="bg-red-600 text-white shadow-lg">
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link href="/" className="text-xl font-bold">
            Blood Sea Management
          </Link>
          
          {/* Desktop Menu */}
          <div className="hidden md:flex items-center space-x-6">
            {user ? (
              <>
                <Link href="/admin" className="hover:text-red-200 transition-colors">
                  Dashboard
                </Link>
                <Link href="/admin/donors" className="hover:text-red-200 transition-colors">
                  Donors
                </Link>
                <Link href="/admin/clients" className="hover:text-red-200 transition-colors">
                  Clients
                </Link>
                <Link href="/admin/notifications" className="hover:text-red-200 transition-colors">
                  Notifications
                </Link>
                <button
                  onClick={handleLogout}
                  className="bg-red-700 hover:bg-red-800 px-3 py-1 rounded transition-colors"
                >
                  Logout
                </button>
              </>
            ) : (
              <>
                <Link href="/" className="hover:text-red-200 transition-colors">
                  Home
                </Link>
                <Link href="/architecture" className="hover:text-red-200 transition-colors">
                  Architecture
                </Link>
                <Link href="/api" className="hover:text-red-200 transition-colors">
                  API Docs
                </Link>
                <Link href="/deployment" className="hover:text-red-200 transition-colors">
                  Deployment
                </Link>
                <Link href="/login" className="bg-red-700 hover:bg-red-800 px-3 py-1 rounded transition-colors">
                  Admin Login
                </Link>
              </>
            )}
          </div>

          {/* Mobile menu button */}
          <div className="md:hidden">
            <button
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
              className="inline-flex items-center justify-center p-2 rounded-md text-white hover:text-red-200 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
              aria-expanded="false"
            >
              <span className="sr-only">Open main menu</span>
              {!isMobileMenuOpen ? (
                <svg className="block h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />
                </svg>
              ) : (
                <svg className="block h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              )}
            </button>
          </div>
        </div>

        {/* Mobile Menu */}
        {isMobileMenuOpen && (
          <div className="md:hidden">
            <div className="px-2 pt-2 pb-3 space-y-1 sm:px-3 bg-red-700 rounded-lg mt-2">
              {user ? (
                <>
                  <Link 
                    href="/admin" 
                    className="block px-3 py-2 rounded-md text-base font-medium hover:text-red-200 hover:bg-red-800 transition-colors"
                    onClick={closeMobileMenu}
                  >
                    Dashboard
                  </Link>
                  <Link 
                    href="/admin/donors" 
                    className="block px-3 py-2 rounded-md text-base font-medium hover:text-red-200 hover:bg-red-800 transition-colors"
                    onClick={closeMobileMenu}
                  >
                    Donors
                  </Link>
                  <Link 
                    href="/admin/clients" 
                    className="block px-3 py-2 rounded-md text-base font-medium hover:text-red-200 hover:bg-red-800 transition-colors"
                    onClick={closeMobileMenu}
                  >
                    Clients
                  </Link>
                  <Link 
                    href="/admin/notifications" 
                    className="block px-3 py-2 rounded-md text-base font-medium hover:text-red-200 hover:bg-red-800 transition-colors"
                    onClick={closeMobileMenu}
                  >
                    Notifications
                  </Link>
                  <button
                    onClick={handleLogout}
                    className="block w-full text-left px-3 py-2 rounded-md text-base font-medium bg-red-800 hover:bg-red-900 transition-colors"
                  >
                    Logout
                  </button>
                </>
              ) : (
                <>
                  <Link 
                    href="/" 
                    className="block px-3 py-2 rounded-md text-base font-medium hover:text-red-200 hover:bg-red-800 transition-colors"
                    onClick={closeMobileMenu}
                  >
                    Home
                  </Link>
                  <Link 
                    href="/architecture" 
                    className="block px-3 py-2 rounded-md text-base font-medium hover:text-red-200 hover:bg-red-800 transition-colors"
                    onClick={closeMobileMenu}
                  >
                    Architecture
                  </Link>
                  <Link 
                    href="/api" 
                    className="block px-3 py-2 rounded-md text-base font-medium hover:text-red-200 hover:bg-red-800 transition-colors"
                    onClick={closeMobileMenu}
                  >
                    API Docs
                  </Link>
                  <Link 
                    href="/deployment" 
                    className="block px-3 py-2 rounded-md text-base font-medium hover:text-red-200 hover:bg-red-800 transition-colors"
                    onClick={closeMobileMenu}
                  >
                    Deployment
                  </Link>
                  <Link 
                    href="/login" 
                    className="block px-3 py-2 rounded-md text-base font-medium bg-red-800 hover:bg-red-900 transition-colors"
                    onClick={closeMobileMenu}
                  >
                    Admin Login
                  </Link>
                </>
              )}
            </div>
          </div>
        )}
      </div>
    </nav>
  );
}