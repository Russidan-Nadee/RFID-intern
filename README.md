# RFID Asset Management System
## Project Overview
RFID Asset Management System is an asset management system using RFID technology, developed with Flutter for the frontend and Node.js Express for the backend, along with a MySQL database.
## System Architecture

<p align="center">
  <img src="https://raw.githubusercontent.com/danielcranney/readme-generator/main/public/icons/skills/flutter-colored.svg" width="36" height="36" style="vertical-align: middle;" />
  <span style="font-size:30px; vertical-align: middle;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;───>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
  <img src="https://raw.githubusercontent.com/danielcranney/readme-generator/main/public/icons/skills/nodejs-colored.svg" width="36" height="36" style="vertical-align: middle;" />
  <span style="font-size:30px; vertical-align: middle;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;───>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
  <img src="https://raw.githubusercontent.com/danielcranney/readme-generator/main/public/icons/skills/mysql-colored.svg" width="36" height="36" style="vertical-align: middle;" />
</p>
<p align="center">
  Flutter App &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Node.js API &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; MySQL DB
</p>


## Features
### 🔐 Authentication & Authorization

Role-based Access Control: Admin, Manager, Staff, Viewer
JWT Authentication: Secure token-based authentication
User Management: Create, update, delete users (Manager+ only)
Permission System: Hierarchical permission structure

### 📱 Mobile Application (Flutter)

Dashboard: Overview of asset statistics and recent activities
Asset Search: Search and filter assets by various criteria
RFID Scanning: Simulate RFID tag scanning with asset detection
Asset Management: View detailed asset information
Status Updates: Update asset status from Available to Checked (Staff+ only)
Data Export: Export asset data to CSV format (Staff+ only)
Reports: Visual charts and statistics by category, status, and location

### 🖥️ Backend API (Node.js)

RESTful API: Complete CRUD operations for assets
Authentication Endpoints: Login, logout, user management
Role-based Endpoints: Permission-controlled access
Data Validation: Comprehensive input validation
Error Handling: Structured error responses
Database Integration: MySQL with connection pooling

### Technology Stack
#### Frontend (Flutter)

Framework: Flutter 3.x
State Management: Provider pattern with BLOCs
Architecture: Clean Architecture with Domain-Driven Design
HTTP Client: Built-in http package
Charts: fl_chart for data visualization
File Operations: CSV export functionality

#### Backend (Node.js)

Runtime: Node.js
Framework: Express.js
Database: MySQL with mysql2 driver
Authentication: JWT (jsonwebtoken)
Password Hashing: bcryptjs
CORS: Enabled for cross-origin requests
Environment: dotenv for configuration

#### Database (MySQL)

Assets Table: Complete asset information with RFID data
Users Table: User accounts with role-based permissions
Connection Pooling: Optimized database connections

## User Roles & Permissions
```
| Permission            | Viewer   | Staff    | Manager   | Admin    |
|-----------------------|----------|----------|-----------|----------|
| View Assets           | ✅       | ✅      | ✅        | ✅      |
| Scan RFID             | ✅       | ✅      | ✅        | ✅      |
| Update Asset Status   | ❌       | ✅      | ✅        | ✅      |
| Create Assets         | ❌       | ❌      | ✅        | ✅      |
| Export Data           | ❌       | ✅      | ✅        | ✅      |
| View Advanced Reports | ❌       | ❌      | ✅        | ✅      |
| Manage Users          | ❌       | ❌      | ✅        | ✅      |
| Delete Assets         | ❌       | ❌      | ❌        | ✅      |
| System Management     | ❌       | ❌      | ❌        | ✅      |

```
## Installation & Setup
### Prerequisites

Node.js (v16+ recommended)
Flutter SDK (3.x)
MySQL Server
Git

### Backend Setup

Clone the repository
```
git clone <repository-url>
cd rfid-asset-management/backend
```
```
Install dependencies
```
```
npm install
```
Environment Configuration
```
Create .env file:

DB_HOST=127.0.0.1
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=rfid_assets_details
PORT=3000
JWT_SECRET=your-secret-key-here
JWT_EXPIRES_IN=24h
```
Database Setup
```
-- Create database
CREATE DATABASE rfid_assets_details;
-- Create assets table
CREATE TABLE assets (
id VARCHAR(50) PRIMARY KEY,
tagId VARCHAR(50) UNIQUE NOT NULL,
epc VARCHAR(100) UNIQUE NOT NULL,
itemId VARCHAR(50),
itemName VARCHAR(200) NOT NULL,
category VARCHAR(100) NOT NULL,
status VARCHAR(50) NOT NULL,
tagType VARCHAR(50),
saleDate DATETIME,
frequency VARCHAR(50),
currentLocation VARCHAR(200),
zone VARCHAR(100),
lastScanTime DATETIME,
lastScannedBy VARCHAR(100),
batteryLevel VARCHAR(10),
batchNumber VARCHAR(100),
manufacturingDate DATETIME,
expiryDate DATETIME,
value VARCHAR(20),
createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
-- Create users table
CREATE TABLE users (
id INT AUTO_INCREMENT PRIMARY KEY,
username VARCHAR(50) UNIQUE NOT NULL,
password_hash VARCHAR(255) NOT NULL,
role ENUM('admin', 'manager', 'staff', 'viewer') NOT NULL,
lastLoginTime DATETIME,
createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
-- Insert default users (password: 1234)
INSERT INTO users (username, password_hash, role) VALUES
('admin', '2a$12
LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewvUqDQpbgPCr7cC', 'admin'),
('manager1', '2a$12
LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewvUqDQpbgPCr7cC', 'manager'),
('staff1', '2a$12
LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewvUqDQpbgPCr7cC', 'staff'),
('viewer1', '2a$12
LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewvUqDQpbgPCr7cC', 'viewer');

```
Start the server
```
npm start
//or for development
npm run dev
```
## Frontend Setup

Navigate to frontend directory
```
cd ../frontend
```
Install Flutter dependencies
```
flutter pub get
```
Configure API endpoint Update ```lib/core/config/app_config.dart:```
```
static const String apiBaseUrl = 'http://10.0.2.2:3000/api'; // For Android Emulator
// or
static const String apiBaseUrl = 'http://localhost:3000/api'; // For iOS Simulator
```
Run the app
```
flutter run
```
## API Documentation
### Authentication Endpoints
```
| Method | Endpoint                 | Description      | Auth Required |
| ------ | ------------------------ | ---------------- | ------------- |
| POST   | /api/auth/login          | User login       | No            |
| POST   | /api/auth/logout         | User logout      | Yes           |
| GET    | /api/auth/me             | Get current user | Yes           |
| GET    | /api/auth/users          | Get all users    | Manager+      |
| POST   | /api/auth/users          | Create user      | Manager+      |
| PUT    | /api/auth/users/\:userId | Update user      | Manager+      |
| DELETE | /api/auth/users/\:userId | Delete user      | Manager+      |

```
### Asset Endpoints
```
| Method | Endpoint                           | Description        | Auth Required |
| ------ | ---------------------------------- | ------------------ | ------------- |
| GET    | /api/assets                        | Get all assets     | No            |
| GET    | /api/assets/\:tagId                | Get asset by tagId | No            |
| GET    | /api/assets/search                 | Search assets      | No            |
| POST   | /api/assets                        | Create asset       | Manager+      |
| PUT    | /api/assets/\:tagId/status/checked | Update status      | Staff+        |
| DELETE | /api/assets/\:tagId                | Delete asset       | Admin         |
| GET    | /api/assets/check-epc              | Check EPC exists   | No            |
```
### Default User Accounts
```
| Username | Password | Role    | Permissions             |
| -------- | -------- | ------- | ----------------------- |
| admin    | 1234     | Admin   | Full system access      |
| manager1 | 1234     | Manager | Asset & user management |
| staff1   | 1234     | Staff   | Asset operations        |
| viewer1  | 1234     | Viewer  | Read-only access        |
```
## Project Structure
### Backend Structure
```
backend/
├── config/
│   └── db.js                 # Database configuration
├── controllers/
│   ├── assetController.js    # Asset CRUD operations
│   └── authController.js     # Authentication logic
├── middlewares/
│   ├── authMiddleware.js     # JWT verification
│   └── errorHandler.js       # Error handling
├── routes/
│   ├── assetRoutes.js        # Asset API routes
│   └── authRoutes.js         # Auth API routes
├── utils/
│   └── errors.js             # Custom error classes
├── .env                      # Environment variables
├── server.js                 # Main server file
└── package.json              # Dependencies
```
### Frontend Structure
```
frontend/lib/
├── core/
│   ├── config/               # App configuration
│   ├── constants/            # App constants
│   ├── di/                   # Dependency injection
│   ├── navigation/           # Navigation setup
│   ├── services/             # Core services
│   ├── theme/                # App theming
│   └── utils/                # Utility functions
├── data/
│   ├── datasources/          # Data sources
│   ├── models/               # Data models
│   └── repositories/         # Repository implementations
├── domain/
│   ├── entities/             # Domain entities
│   ├── repositories/         # Repository interfaces
│   └── usecases/             # Business logic
├── presentation/
│   ├── common_widgets/       # Reusable widgets
│   └── features/             # Feature modules
│       ├── assets/           # Asset management
│       ├── auth/             # Authentication
│       ├── dashboard/        # Dashboard
│       ├── export/           # Data export
│       ├── reports/          # Reports & analytics
│       ├── rfid/             # RFID scanning
│       └── settings/         # App settings
└── main.dart                 # App entry point
```
## Development Guidelines
### Code Style

Flutter: Follow Dart style guide with flutter_lints
Node.js: Use ESLint with standard configuration
Database: Use camelCase for column names
API: RESTful conventions with clear endpoints

### Error Handling

Backend: Structured error responses with appropriate HTTP status codes
Frontend: User-friendly error messages with retry mechanisms
Database: Connection pooling and query error handling

### Security

Authentication: JWT tokens with secure secret keys
Password Hashing: bcrypt with salt rounds
Input Validation: Server-side validation for all inputs
SQL Injection: Parameterized queries with mysql2

## Troubleshooting
### Common Issues

#### Database Connection Failed

Verify MySQL server is running
Check database credentials in .env
Ensure database exists


#### API Connection Error (Flutter)

Check API endpoint in app_config.dart
Verify backend server is running
Use 10.0.2.2 for Android emulator


#### Authentication Issues

Verify JWT secret key consistency
Check token expiration settings
Ensure proper password hashing

#### Permission Denied

Check user role assignments
Verify middleware configuration
Review route protection



## Performance Optimization
### Database

Indexing: Primary keys on id, tagId, epc
Connection Pooling: Max 10 concurrent connections
Query Optimization: Limit results and use appropriate WHERE clauses

### Frontend

State Management: Provider pattern for efficient rebuilds
Lazy Loading: Pagination for large datasets
Caching: Repository pattern with in-memory caching

### Backend

Error Logging: Structured logging for debugging
Request Validation: Early validation to prevent unnecessary processing
CORS Configuration: Optimized for development environment

## Future Enhancements

 Real RFID hardware integration
 Push notifications for asset alerts
 Advanced reporting with date ranges
 Asset maintenance scheduling
 QR code support as backup identification
 Multi-language support
 Offline capability with data synchronization
 Asset location tracking with GPS
 Barcode scanning integration
 Asset depreciation calculations

## Contributing

Fork the repository
Create feature branch (git checkout -b feature/amazing-feature)
Commit changes (git commit -m 'Add amazing feature')
Push to branch (git push origin feature/amazing-feature)
Open Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details.
## Support
For support and questions:

Create an issue in the repository
Contact the development team
Check the troubleshooting section above


Note : This is a development system designed for learning and demonstration purposes. For production use, additional security measures and optimizations should be implemented.
