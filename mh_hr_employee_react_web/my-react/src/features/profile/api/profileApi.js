import apiClient from '../../../core/api/client';

// ============ PASSWORD CHANGE APIs ============
export const changePassword = async (oldPassword, newPassword) => {
  try {
    const user = JSON.parse(localStorage.getItem('user'));
    const response = await apiClient.post('/users/change-password', {
      userId: user.id,
      oldPassword,
      newPassword
    });
    return response.data;
  } catch (error) {
    console.error('Error changing password:', error);
    throw error;
  }
};

export const validateSuperAdmin = async () => {
  try {
    const user = JSON.parse(localStorage.getItem('user'));
    return user && user.role === 'super-admin';
  } catch (error) {
    console.error('Error validating super admin:', error);
    return false;
  }
};

export const fetchPasswordChangeRequests = async () => {
  try {
    const response = await apiClient.get('/users/password-changes');
    return response.data;
  } catch (error) {
    console.error('Error fetching password change requests:', error);
    throw error;
  }
};

export const updatePasswordStatus = async (requestId, status) => {
  try {
    const response = await apiClient.put(`/users/password-changes/${requestId}`, {
      status
    });
    return response.data;
  } catch (error) {
    console.error('Error updating password status:', error);
    throw error;
  }
};

// ============ PROFILE APIs ============
export const getUserProfile = async (userId) => {
  try {
    const response = await apiClient.get(`/users/${userId}`);
    return response.data;
  } catch (error) {
    console.error('Error fetching user profile:', error);
    throw error;
  }
};

export const updateUserProfile = async (userId, profileData) => {
  try {
    const response = await apiClient.put(`/users/${userId}`, profileData);
    return response.data;
  } catch (error) {
    console.error('Error updating user profile:', error);
    throw error;
  }
};
