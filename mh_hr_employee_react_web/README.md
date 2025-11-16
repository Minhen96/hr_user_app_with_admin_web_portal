# MH HR Employee Management - Web Admin Portal

A modern React-based web administration portal for managing HR operations, built with Vite, React 18, and Tailwind CSS.

## Tech Stack

- **Framework**: React 18
- **Build Tool**: Vite
- **Styling**: Tailwind CSS + Material-UI (MUI)
- **HTTP Client**: Axios with JWT authentication
- **State Management**: React hooks (local state)
- **Routing**: React Router v6
- **UI Components**: Material-UI, React Icons

## Quick Start

### Prerequisites
- Node.js 16+ and npm/yarn
- Backend API running (see `../mh_hr_employee_dotnet_backend/`)

### Installation

```bash
# Navigate to the React app directory
cd mh_hr_employee_react_web/my-react

# Install dependencies
npm install

# Start development server
npm run dev
# App will run on: http://localhost:5173
```

### Build for Production

```bash
npm run build       # Build production bundle
npm run preview     # Preview production build locally
```

## Project Structure

```
my-react/
├── src/
│   ├── features/              # Feature-based modules
│   │   ├── auth/             # Authentication (Login, Register)
│   │   ├── equipment/        # Equipment management
│   │   ├── documents/        # Document management (Memo, Policy, SOP, Updates)
│   │   ├── staff/            # Staff management
│   │   ├── leave/            # Leave applications
│   │   ├── training/         # Training courses
│   │   ├── moments/          # Social moments/feed
│   │   └── dashboard/        # Dashboard/analytics
│   ├── shared/               # Shared components
│   │   ├── Sidebar.jsx      # Navigation sidebar
│   │   ├── dialogs/         # Reusable dialog components
│   │   └── layouts/         # Layout components
│   ├── core/                 # Core infrastructure
│   │   ├── api/             # API client configuration
│   │   └── config/          # App configuration
│   ├── App.jsx              # Main application component
│   └── main.jsx             # Application entry point
├── public/                   # Static assets
├── index.html               # HTML template
├── vite.config.js           # Vite configuration
├── tailwind.config.js       # Tailwind CSS configuration
└── package.json             # Dependencies and scripts
```

## Architecture

### Feature-Based Structure
The application follows a feature-based architecture where each feature is self-contained:

```
features/
└── equipment/
    ├── components/          # Feature-specific components
    ├── hooks/              # Feature-specific hooks
    ├── pages/              # Feature pages/routes
    └── utils/              # Feature utilities
```

### API Integration

The app uses Axios with automatic JWT token injection:

```javascript
// core/api/client.js
import axios from 'axios';

const apiClient = axios.create({
  baseURL: 'http://localhost:5000',
});

// Automatic token injection
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Auto-logout on 401
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

### Authentication Flow

1. User logs in via `/login`
2. Backend returns JWT token
3. Token stored in `localStorage`
4. Axios automatically adds token to all API requests
5. On 401 response, user is logged out automatically

## Key Features

### Admin Capabilities

- **User Management**: Create, update, delete users and assign roles
- **Document Management**: Upload and manage company documents (Memos, Policies, SOPs, Updates)
- **Equipment Requests**: Approve/reject employee equipment requests
- **Leave Management**: Review and approve leave applications
- **Training Management**: Manage training courses and certificates
- **Staff Directory**: View and manage employee information
- **Analytics Dashboard**: View system metrics and reports
- **Social Feed**: Manage company moments and announcements

### User Roles

- **super-admin**: Full system access
- **department-admin**: Department-level administration
- **user**: Basic access (view-only for most features)

## API Endpoints

The web admin consumes these backend APIs:

### Authentication
- `POST /api/Auth/login` - Admin login
- `GET /api/Auth/profile` - Get current user profile

### Documents
- `GET /admin/api/Memo` - Get memos
- `POST /admin/api/Memo` - Create memo
- `GET /admin/api/Policy` - Get policies
- `GET /admin/api/SOP` - Get SOPs
- `GET /admin/api/Updates` - Get company updates

### Equipment
- `GET /admin/api/EquipmentRequest` - Get equipment requests
- `PUT /admin/api/EquipmentRequest/{id}` - Approve/reject request

### Leave Management
- `GET /api/Leave/requests` - Get leave requests
- `PUT /api/Leave/approve/{id}` - Approve leave
- `PUT /api/Leave/reject/{id}` - Reject leave

### Staff Management
- `GET /admin/api/Staff` - Get all staff
- `POST /admin/api/Staff` - Create staff member
- `PUT /admin/api/Staff/{id}` - Update staff
- `DELETE /admin/api/Staff/{id}` - Delete staff

See `../mh_hr_employee_dotnet_backend/README.md` for complete API documentation.

## Environment Configuration

### Development
Create `.env.development`:
```env
VITE_API_BASE_URL=http://localhost:5000
```

### Production
Create `.env.production`:
```env
VITE_API_BASE_URL=https://your-production-api.com
```

Access in code:
```javascript
const apiUrl = import.meta.env.VITE_API_BASE_URL;
```

## Available Scripts

```bash
npm run dev         # Start development server
npm run build       # Build for production
npm run preview     # Preview production build
npm run lint        # Run ESLint
```

## Styling Guidelines

### Tailwind CSS
The project uses Tailwind CSS for styling:

```jsx
<div className="flex items-center justify-between p-4 bg-white rounded-lg shadow">
  <h2 className="text-xl font-semibold text-gray-800">Title</h2>
  <button className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
    Action
  </button>
</div>
```

### Material-UI Components
MUI is used for complex components (tables, dialogs, date pickers):

```jsx
import { Button, Dialog, DialogTitle, DialogContent } from '@mui/material';

<Dialog open={open} onClose={handleClose}>
  <DialogTitle>Confirm Action</DialogTitle>
  <DialogContent>
    {/* Content */}
  </DialogContent>
</Dialog>
```

## Deployment

### Vercel / Netlify
```bash
npm run build
# Deploy the 'dist' folder
```

### Docker
```dockerfile
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Apache / Nginx
After running `npm run build`, serve the `dist/` folder:

**Nginx config:**
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/html/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

## Development Guidelines

### Adding a New Feature

1. Create feature folder in `src/features/[feature-name]/`
2. Add components, hooks, and pages
3. Create route in `App.jsx`
4. Add navigation link in `Sidebar.jsx`

### API Service Pattern

```javascript
// features/myfeature/api/myService.js
import apiClient from '@/core/api/client';

export const getMyData = async () => {
  const response = await apiClient.get('/admin/api/MyEndpoint');
  return response.data;
};

export const createMyData = async (data) => {
  const response = await apiClient.post('/admin/api/MyEndpoint', data);
  return response.data;
};
```

### Form Handling Pattern

```jsx
import { useState } from 'react';
import { createMyData } from '../api/myService';

function MyForm() {
  const [formData, setFormData] = useState({ name: '', email: '' });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await createMyData(formData);
      alert('Success!');
    } catch (error) {
      alert('Error: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* Form fields */}
    </form>
  );
}
```

## Troubleshooting

### Common Issues

**1. API Connection Failed**
- Verify backend is running on `http://localhost:5000`
- Check CORS configuration in backend
- Verify `.env` file has correct API URL

**2. 401 Unauthorized Errors**
- Check if JWT token is stored in localStorage
- Verify token hasn't expired
- Try logging out and logging back in

**3. Build Errors**
- Clear node_modules: `rm -rf node_modules && npm install`
- Clear Vite cache: `rm -rf node_modules/.vite`
- Update dependencies: `npm update`

**4. Hot Reload Not Working**
- Restart dev server
- Check Vite configuration
- Clear browser cache

## Related Projects

- **Backend API**: See `../mh_hr_employee_dotnet_backend/` for .NET backend setup and API documentation
- **Mobile App**: See `../mh_employee_flutter_app/` for Flutter employee mobile app
- **Main Project**: See `../README.md` for monorepo overview

## License

Proprietary - MH HR Employee Management System
