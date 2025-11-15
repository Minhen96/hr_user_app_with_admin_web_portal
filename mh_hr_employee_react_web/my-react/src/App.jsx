import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import { useEffect } from "react";
import LoginPage from "./features/auth/pages/LoginPage";
import EquipmentPage from "./features/equipment/pages/EquipmentPage";
import ProfilePage from "./features/profile/pages/ProfilePage";
import DocumentPage from "./features/documents/pages/DocumentPage";
import RequestApproval from "./features/approvals/pages/RequestApproval";
import StaffPage from "./features/staff/pages/StaffPage";
import LeavePage from "./features/leave/pages/LeavePage";
import ProtectedRoute from "./features/auth/components/ProtectedRoute";
import { ModernLayout } from "./components/modern/ModernLayout";

function App() {
  // Set dark mode by default on initial load
  useEffect(() => {
    document.documentElement.classList.add('dark');
  }, []);

  return (
    <Router>
      <Routes>
        <Route path="/" element={<LoginPage />} />
        <Route
          path="/main"
          element={
            <ProtectedRoute>
              <ModernLayout>
                <EquipmentPage />
              </ModernLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/profile"
          element={
            <ProtectedRoute>
              <ModernLayout>
                <ProfilePage />
              </ModernLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/document"
          element={
            <ProtectedRoute>
              <ModernLayout>
                <DocumentPage />
              </ModernLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/approval"
          element={
            <ProtectedRoute>
              <ModernLayout>
                <RequestApproval />
              </ModernLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/staff"
          element={
            <ProtectedRoute>
              <ModernLayout>
                <StaffPage />
              </ModernLayout>
            </ProtectedRoute>
          }
        />
        <Route
          path="/leave"
          element={
            <ProtectedRoute>
              <ModernLayout>
                <LeavePage />
              </ModernLayout>
            </ProtectedRoute>
          }
        />
      </Routes>
    </Router>
  );
}

export default App;
