# Blood Sea Web Management

A Next.js web application for managing and documenting the Blood Sea Flutter project.

## Overview

This web application serves as a project management and documentation hub for the Blood Sea blood donation mobile app. It provides comprehensive information about the system architecture, API documentation, and deployment guides.

## Features

- **Project Information**: Overview of the Blood Sea mobile app
- **Architecture Documentation**: Detailed system architecture and design patterns
- **API Documentation**: Firebase collections, models, and integration details
- **Deployment Guides**: Step-by-step deployment instructions for all platforms

## Tech Stack

- **Framework**: Next.js 15.3.4 with App Router
- **Styling**: Tailwind CSS 4.0
- **Language**: TypeScript
- **Deployment**: Firebase Hosting
- **Package Manager**: npm

## Getting Started

### Prerequisites

- Node.js 18 or later
- npm or yarn
- Firebase CLI (for deployment)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd blood-sea-web
```

2. Install dependencies:
```bash
npm install
```

3. Run the development server:
```bash
npm run dev
```

4. Open [http://localhost:3000](http://localhost:3000) in your browser.

## Available Scripts

- `npm run dev` - Start development server with Turbopack
- `npm run build` - Build the application for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint
- `npm run deploy` - Build and deploy to Firebase Hosting
- `npm run deploy:preview` - Deploy to Firebase preview channel

## Project Structure

```
src/
├── app/
│   ├── layout.tsx          # Root layout with navigation
│   ├── page.tsx            # Home page
│   ├── architecture/       # System architecture docs
│   ├── api/               # API documentation
│   └── deployment/        # Deployment guides
├── components/            # Reusable components (if any)
└── lib/                  # Utility functions (if any)
```

## Deployment

### Firebase Hosting

1. Initialize Firebase in your project:
```bash
firebase login
firebase init hosting
```

2. Build and deploy:
```bash
npm run deploy
```

3. For preview deployment:
```bash
npm run deploy:preview
```

### Configuration

The project is configured for static export to work with Firebase Hosting:

- `next.config.ts` - Configured for static export
- `firebase.json` - Firebase hosting configuration
- Output directory: `out/`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build: `npm run build`
5. Submit a pull request

## License

This project is part of the Blood Sea application suite.