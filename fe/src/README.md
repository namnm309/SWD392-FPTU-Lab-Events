# FPT University Lab Events - Frontend

## 🏗️ Feature Architecture

Dự án được tổ chức theo **feature-based architecture** để dễ dàng mở rộng và bảo trì:

```
src/
├── components/           # Shared components
│   ├── Navbar/          # Navigation component
│   └── index.js         # Component exports
├── features/            # Feature modules
│   ├── admin/           # Admin feature
│   │   ├── components/  # Admin-specific components
│   │   ├── dashboard/   # Admin dashboard
│   │   └── index.js     # Feature exports
│   └── index.js         # Feature exports
├── App.js              # Main application
├── App.css             # Global styles
└── index.js            # Application entry point
```

## 🎨 Design System

### Color Palette
- **Primary Blue**: `#1e40af` (Main brand color)
- **Secondary Blue**: `#3b82f6` (Accent color)
- **Light Blue**: `#dbeafe` (Background highlights)
- **Text Gray**: `#374151` (Primary text)
- **Muted Gray**: `#64748b` (Secondary text)
- **Background**: `#f8fafc` (Page background)

### Typography
- **Headings**: 700 weight, blue color
- **Body**: 500 weight, gray color
- **Small text**: 400 weight, muted gray

## 🔧 Admin Functions

Dựa trên Overview.md, admin có các chức năng chính:

1. **UC-07**: Manage Permission Matrix (Quản lý ma trận quyền)
2. **UC-08**: Sync Calendars (Đồng bộ lịch với trường)
3. **UC-10**: View Audit Logs (Xem lịch sử thay đổi)
4. **UC-11**: Generate Reports (Xuất báo cáo)
5. **UC-06**: Manage Blackout (Quản lý ngày không cho đặt phòng)
6. **UC-04**: Approve Booking (Duyệt yêu cầu đặt phòng)

## 📱 Responsive Design

- **Desktop**: Full sidebar navigation
- **Tablet**: Collapsible sidebar
- **Mobile**: Hamburger menu with dropdown

## 🚀 Getting Started

```bash
cd fe
npm install
npm start
```

## 📁 File Structure Details

### Admin Feature
- `AdminDashboard.js`: Main admin dashboard with sidebar navigation
- `AdminDashboardOverview.js`: Dashboard overview with stats and quick actions
- CSS files: Professional styling with blue theme

### Navbar Component
- `Navbar.js`: Responsive navigation with user menu
- `Navbar.css`: Mobile-first responsive design
- Features: Logo, menu items, user dropdown, mobile toggle

### App Structure
- `App.js`: Main application with routing logic
- `App.css`: Global styles and home page layout
- State management for page navigation

## 🎯 Next Steps

1. Implement individual admin features (bookings, users, rooms, etc.)
2. Add React Router for proper navigation
3. Connect to backend API
4. Add authentication and authorization
5. Implement real-time notifications
6. Add data visualization for reports
