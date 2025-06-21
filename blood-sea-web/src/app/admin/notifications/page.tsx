'use client';

import { useEffect, useState } from 'react';
import { collection, getDocs, doc, deleteDoc, addDoc, query, orderBy, limit } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { Notification, User } from '@/types';
import ProtectedRoute from '@/components/ProtectedRoute';

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [newNotification, setNewNotification] = useState({
    title: '',
    message: '',
    type: 'system' as 'blood_request' | 'system' | 'reminder',
    recipients: 'all' as 'all' | 'donors' | 'clients' | 'specific',
    specificRecipients: [] as string[],
    bloodGroup: '',
    urgency: 'medium' as 'low' | 'medium' | 'high' | 'critical',
  });

  const bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  useEffect(() => {
    fetchNotifications();
    fetchUsers();
  }, []);

  const fetchNotifications = async () => {
    try {
      const notificationsQuery = query(
        collection(db, 'notifications'),
        orderBy('createdAt', 'desc'),
        limit(100)
      );
      const snapshot = await getDocs(notificationsQuery);
      const notificationsData = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate() || new Date(),
      })) as Notification[];
      
      setNotifications(notificationsData);
    } catch (error) {
      console.error('Error fetching notifications:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchUsers = async () => {
    try {
      const snapshot = await getDocs(collection(db, 'users'));
      const usersData = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate() || new Date(),
        updatedAt: doc.data().updatedAt?.toDate() || new Date(),
        lastSeen: doc.data().lastSeen?.toDate() || new Date(),
      })) as User[];
      
      setUsers(usersData);
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };

  const handleCreateNotification = async (e: React.FormEvent) => {
    e.preventDefault();
    
    try {
      let recipients: string[] = [];
      
      switch (newNotification.recipients) {
        case 'all':
          recipients = users.map(user => user.id);
          break;
        case 'donors':
          recipients = users.filter(user => user.userType === 'donor').map(user => user.id);
          break;
        case 'clients':
          recipients = users.filter(user => user.userType === 'client').map(user => user.id);
          break;
        case 'specific':
          recipients = newNotification.specificRecipients;
          break;
      }

      // Create notifications for each recipient
      const promises = recipients.map(recipientId => {
        const notificationData = {
          recipientId,
          type: newNotification.type,
          title: newNotification.title,
          message: newNotification.message,
          data: {
            ...(newNotification.bloodGroup && { bloodGroup: newNotification.bloodGroup }),
            ...(newNotification.urgency && { urgency: newNotification.urgency }),
          },
          isRead: false,
          createdAt: new Date(),
        };
        
        return addDoc(collection(db, 'notifications'), notificationData);
      });

      await Promise.all(promises);
      
      setShowCreateModal(false);
      setNewNotification({
        title: '',
        message: '',
        type: 'system',
        recipients: 'all',
        specificRecipients: [],
        bloodGroup: '',
        urgency: 'medium',
      });
      
      fetchNotifications();
    } catch (error) {
      console.error('Error creating notification:', error);
      alert('Failed to create notification');
    }
  };

  const handleDeleteNotification = async (notificationId: string) => {
    if (!confirm('Are you sure you want to delete this notification?')) return;
    
    try {
      await deleteDoc(doc(db, 'notifications', notificationId));
      fetchNotifications();
    } catch (error) {
      console.error('Error deleting notification:', error);
      alert('Failed to delete notification');
    }
  };

  const getRecipientName = (recipientId: string) => {
    const user = users.find(u => u.id === recipientId);
    return user ? user.name : 'Unknown User';
  };

  if (loading) {
    return (
      <ProtectedRoute>
        <div className="min-h-screen flex items-center justify-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-red-600"></div>
        </div>
      </ProtectedRoute>
    );
  }

  return (
    <ProtectedRoute>
      <div className="min-h-screen bg-gray-50">
        <div className="container mx-auto px-4 py-8">
          <div className="mb-8 flex justify-between items-center">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Notifications Management</h1>
              <p className="text-gray-600">Send and manage notifications to users</p>
            </div>
            <button
              onClick={() => setShowCreateModal(true)}
              className="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700"
            >
              Create Notification
            </button>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <div className="bg-white rounded-lg shadow p-4">
              <h3 className="text-lg font-semibold text-gray-900">Total Notifications</h3>
              <p className="text-2xl font-bold text-blue-600">{notifications.length}</p>
            </div>
            <div className="bg-white rounded-lg shadow p-4">
              <h3 className="text-lg font-semibold text-gray-900">Blood Requests</h3>
              <p className="text-2xl font-bold text-red-600">
                {notifications.filter(n => n.type === 'blood_request').length}
              </p>
            </div>
            <div className="bg-white rounded-lg shadow p-4">
              <h3 className="text-lg font-semibold text-gray-900">System Alerts</h3>
              <p className="text-2xl font-bold text-yellow-600">
                {notifications.filter(n => n.type === 'system').length}
              </p>
            </div>
            <div className="bg-white rounded-lg shadow p-4">
              <h3 className="text-lg font-semibold text-gray-900">Reminders</h3>
              <p className="text-2xl font-bold text-green-600">
                {notifications.filter(n => n.type === 'reminder').length}
              </p>
            </div>
          </div>

          {/* Notifications List */}
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200 text-sm">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Notification
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Recipient
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Type
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Date
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {notifications.map((notification) => (
                    <tr key={notification.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4">
                        <div>
                          <div className="text-sm font-medium text-gray-900">{notification.title}</div>
                          <div className="text-sm text-gray-500 max-w-xs truncate">{notification.message}</div>
                          {notification.data?.bloodGroup && (
                            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800 mt-1">
                              {notification.data.bloodGroup}
                            </span>
                          )}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{getRecipientName(notification.recipientId)}</div>
                        <div className="text-sm text-gray-500">ID: {notification.recipientId.slice(0, 8)}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                          notification.type === 'blood_request' ? 'bg-red-100 text-red-800' :
                          notification.type === 'system' ? 'bg-yellow-100 text-yellow-800' :
                          'bg-green-100 text-green-800'
                        }`}>
                          {notification.type.replace('_', ' ')}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                          notification.isRead ? 'bg-gray-100 text-gray-800' : 'bg-blue-100 text-blue-800'
                        }`}>
                          {notification.isRead ? 'Read' : 'Unread'}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">
                          {notification.createdAt.toLocaleDateString()}
                        </div>
                        <div className="text-sm text-gray-500">
                          {notification.createdAt.toLocaleTimeString()}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <button
                          onClick={() => handleDeleteNotification(notification.id)}
                          className="text-red-600 hover:text-red-900 text-sm font-medium"
                        >
                          Delete
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {notifications.length === 0 && (
              <div className="text-center py-12">
                <div className="text-gray-500 text-lg">No notifications found</div>
                <div className="text-gray-400 text-sm mt-2">
                  Create your first notification to get started
                </div>
              </div>
            )}
          </div>

          {/* Create Notification Modal */}
          {showCreateModal && (
            <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
              <div className="relative top-4 md:top-20 mx-auto p-5 border w-full max-w-md mx-4 shadow-lg rounded-md bg-white">
                <h3 className="text-lg font-bold text-gray-900 mb-4">Create New Notification</h3>
                <form onSubmit={handleCreateNotification} className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Title</label>
                    <input
                      type="text"
                      value={newNotification.title}
                      onChange={(e) => setNewNotification({...newNotification, title: e.target.value})}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Message</label>
                    <textarea
                      value={newNotification.message}
                      onChange={(e) => setNewNotification({...newNotification, message: e.target.value})}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md"
                      rows={3}
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Type</label>
                    <select
                      value={newNotification.type}
                      onChange={(e) => setNewNotification({...newNotification, type: e.target.value as 'blood_request' | 'system' | 'reminder'})}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md"
                    >
                      <option value="system">System</option>
                      <option value="blood_request">Blood Request</option>
                      <option value="reminder">Reminder</option>
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Recipients</label>
                    <select
                      value={newNotification.recipients}
                      onChange={(e) => setNewNotification({...newNotification, recipients: e.target.value as 'all' | 'donors' | 'clients' | 'specific'})}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md"
                    >
                      <option value="all">All Users</option>
                      <option value="donors">All Donors</option>
                      <option value="clients">All Clients</option>
                    </select>
                  </div>
                  
                  {newNotification.type === 'blood_request' && (
                    <>
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Blood Group</label>
                        <select
                          value={newNotification.bloodGroup}
                          onChange={(e) => setNewNotification({...newNotification, bloodGroup: e.target.value})}
                          className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md"
                        >
                          <option value="">Select Blood Group</option>
                          {bloodGroups.map(group => (
                            <option key={group} value={group}>{group}</option>
                          ))}
                        </select>
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-gray-700">Urgency</label>
                        <select
                          value={newNotification.urgency}
                          onChange={(e) => setNewNotification({...newNotification, urgency: e.target.value as 'low' | 'medium' | 'high' | 'critical'})}
                          className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md"
                        >
                          <option value="low">Low</option>
                          <option value="medium">Medium</option>
                          <option value="high">High</option>
                          <option value="critical">Critical</option>
                        </select>
                      </div>
                    </>
                  )}
                  
                  <div className="flex justify-end space-x-2">
                    <button
                      type="button"
                      onClick={() => setShowCreateModal(false)}
                      className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
                    >
                      Cancel
                    </button>
                    <button
                      type="submit"
                      className="px-4 py-2 bg-red-600 text-white text-sm font-medium rounded-md hover:bg-red-700"
                    >
                      Send Notification
                    </button>
                  </div>
                </form>
              </div>
            </div>
          )}
        </div>
      </div>
    </ProtectedRoute>
  );
}