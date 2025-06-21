export interface User {
  id: string;
  uid: string;
  email: string;
  name: string;
  phone: string;
  userType: 'donor' | 'client';
  bloodGroup?: string;
  location: {
    address: string;
    city: string;
    state: string;
    coordinates?: {
      latitude: number;
      longitude: number;
    };
  };
  profileImage?: string;
  isAvailable?: boolean;
  lastSeen: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface Donor extends User {
  userType: 'donor';
  bloodGroup: string;
  isAvailable: boolean;
  lastDonation?: Date;
  rating?: number;
  totalDonations?: number;
}

export interface Client extends User {
  userType: 'client';
}

export interface Notification {
  id: string;
  recipientId: string;
  senderId?: string;
  type: 'blood_request' | 'system' | 'reminder';
  title: string;
  message: string;
  data?: {
    bloodGroup?: string;
    location?: string;
    urgency?: 'low' | 'medium' | 'high' | 'critical';
    [key: string]: string | number | boolean | undefined;
  };
  isRead: boolean;
  createdAt: Date;
}

export interface BloodRequest {
  id: string;
  requesterId: string;
  bloodGroup: string;
  urgency: 'low' | 'medium' | 'high' | 'critical';
  location: {
    hospital: string;
    address: string;
    city: string;
    coordinates?: {
      latitude: number;
      longitude: number;
    };
  };
  contactInfo: {
    name: string;
    phone: string;
    email: string;
  };
  additionalInfo?: string;
  status: 'active' | 'fulfilled' | 'expired';
  respondedDonors: string[];
  createdAt: Date;
  expiresAt: Date;
}