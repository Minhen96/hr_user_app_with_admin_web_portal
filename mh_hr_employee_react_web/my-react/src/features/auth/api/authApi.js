import apiClient from '../../../core/api/client';
import { AUTH_ENDPOINTS } from '../../../core/api/endpoints';

/**
 * Login user with email and password
 * @param {string} email - User email
 * @param {string} password - User password
 * @returns {Promise} Response data with token and user info
 */
export const login = async (email, password) => {
  try {
    const response = await apiClient.post(AUTH_ENDPOINTS.LOGIN, { email, password });

    if (response.data.user.active_status === 'inactive') {
      throw {
        response: {
          data: {
            success: false,
            message: "Your account is currently inactive. Please contact your administrator."
          }
        }
      };
    }

    // Store the token after successful login (token is inside user object)
    if (response.data.user && response.data.user.token) {
      localStorage.setItem('token', response.data.user.token);
    }

    return response.data;
  } catch (error) {
    console.error("Login error:", error);
    throw error;
  }
};

/**
 * Change user password
 * @param {number} userId - User ID
 * @param {string} oldPassword - Current password
 * @param {string} newPassword - New password
 * @returns {Promise} Response data
 */
export const changePassword = async (userId, oldPassword, newPassword) => {
  try {
    const response = await apiClient.put("/Auth/change-password", {
      userId,
      oldPassword,
      newPassword,
    });
    return response.data;
  } catch (error) {
    console.error("API change password error:", {
      message: error.message,
      response: error.response?.data,
      status: error.response?.status,
    });
    throw error.response?.data || {
      message: "Failed to change password",
    };
  }
};

/**
 * Logout user (clear local storage)
 */
export const logout = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('user');
  window.location.href = '/';
};

/**
 * Get current user from localStorage
 * @returns {Object|null} User object or null
 */
export const getCurrentUser = () => {
  const userStr = localStorage.getItem('user');
  return userStr ? JSON.parse(userStr) : null;
};

/**
 * Get auth token from localStorage
 * @returns {string|null} Token or null
 */
export const getToken = () => {
  return localStorage.getItem('token');
};

/**
 * Check if user is authenticated
 * @returns {boolean} True if authenticated
 */
export const isAuthenticated = () => {
  return !!getToken();
};
