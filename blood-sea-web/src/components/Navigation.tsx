'use client';

import Link from 'next/link';
import { useAuth } from '@/contexts/AuthContext';
import { usePathname } from 'next/navigation';

export default function Navigation() {
  const { user, logout } = useAuth();
  const pathname = usePathname();

  // Don't show navigation on login page
  if (pathname === '/login') {
    return null;
  }

  const handleLogout = async () => {
    try {
      await logout();
    } catch (error) {
      console.error('Failed to log out:', error);
    }
  };

  return (
    <nav className="bg-red-600 text-white shadow-lg">
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          <Link href="/" className="text-xl font-bold">
            Blood Sea Management
          </Link>
          
          <div className="flex items-center space-x-6">
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
        </div>
      </div>
    </nav>
  );
}