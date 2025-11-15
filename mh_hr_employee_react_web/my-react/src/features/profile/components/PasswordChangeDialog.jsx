import React, { useState } from "react";
import { changePassword, validateSuperAdmin } from "../api/profileApi";
import "./PasswordChangeDialog.css";

const PasswordChangeDialog = ({ isOpen, onClose }) => {
  const [oldPassword, setOldPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const resetForm = () => {
    setOldPassword("");
    setNewPassword("");
    setConfirmPassword("");
    setError("");
  };

  const validatePasswords = () => {
    if (newPassword !== confirmPassword) {
      throw new Error("New passwords don't match");
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      setLoading(true);
      setError("");

      const user = JSON.parse(localStorage.getItem("user"));
      
      // Validate user role
      validateSuperAdmin(user);
      
      // Validate passwords match
      validatePasswords();

      // Call API to change password
      await changePassword(user.id, oldPassword, newPassword);

      alert("Password changed successfully");
      resetForm();
      onClose();
    } catch (err) {
      console.error("Error:", err);
      setError(err.message || "An error occurred while changing password");
    } finally {
      setLoading(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="dialog-overlay">
      <div className="dialog-container">
        <h2 className="dialog-title">Change Password</h2>
        {error && <div className="dialog-error">{error}</div>}
        <form onSubmit={handleSubmit}>
          <div className="dialog-input-group">
            <label className="dialog-label">Current Password</label>
            <input
              type="password"
              value={oldPassword}
              onChange={(e) => setOldPassword(e.target.value)}
              className="dialog-input"
              required
            />
          </div>
          <div className="dialog-input-group">
            <label className="dialog-label">New Password</label>
            <input
              type="password"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              className="dialog-input"
              required
            />
          </div>
          <div className="dialog-input-group">
            <label className="dialog-label">Confirm New Password</label>
            <input
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              className="dialog-input"
              required
            />
          </div>
          <div className="dialog-actions">
            <button
              type="button"
              onClick={() => {
                resetForm();
                onClose();
              }}
              className="dialog-button cancel-button"
              disabled={loading}
            >
              Cancel
            </button>
            <button
              type="submit"
              className="dialog-button submit-button"
              disabled={loading}
            >
              {loading ? "Changing..." : "Change Password"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default PasswordChangeDialog;