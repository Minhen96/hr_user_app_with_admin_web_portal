import apiClient from '../../../core/api/client';

// ============ USER MANAGEMENT APIs ============
export const fetchUsers = async () => {
  try {
    const response = await apiClient.get('/staff');
    return response.data;
  } catch (error) {
    console.error('Error fetching users:', error);
    throw error;
  }
};

export const createUser = async (userData) => {
  try {
    const response = await apiClient.post('/users', userData);
    return response.data;
  } catch (error) {
    console.error('Error creating user:', error);
    throw error;
  }
};

export const updateUser = async (userId, userData) => {
  try {
    const response = await apiClient.put(`/users/${userId}`, userData);
    return response.data;
  } catch (error) {
    console.error('Error updating user:', error);
    throw error;
  }
};

export const deleteUser = async (userId) => {
  try {
    const response = await apiClient.delete(`/users/${userId}`);
    return response.data;
  } catch (error) {
    console.error('Error deleting user:', error);
    throw error;
  }
};

export const toggleUserStatus = async (userId) => {
  try {
    const response = await apiClient.put(`/Users/${userId}/toggle-status`);
    return response.data;
  } catch (error) {
    console.error('Error toggling user status:', error);
    throw error;
  }
};

// ============ DEPARTMENT APIs ============
export const fetchDepartment = async () => {
  try {
    const response = await apiClient.get('/Documents/departments');
    return response.data;
  } catch (error) {
    console.error('Error fetching departments:', error);
    throw error;
  }
};

export const createDepartment = async (departmentData) => {
  try {
    const response = await apiClient.post('/Department', departmentData);
    return response.data;
  } catch (error) {
    console.error('Error creating department:', error);
    throw error;
  }
};

export const updateDepartment = async (departmentId, departmentData) => {
  try {
    const response = await apiClient.put(`/Department/${departmentId}`, departmentData);
    return response.data;
  } catch (error) {
    console.error('Error updating department:', error);
    throw error;
  }
};

export const deleteDepartment = async (departmentId) => {
  try {
    const response = await apiClient.delete(`/Department/${departmentId}`);
    return response.data;
  } catch (error) {
    console.error('Error deleting department:', error);
    throw error;
  }
};

// ============ ROLE APIs ============
export const fetchRoles = async () => {
  try {
    // Return hardcoded roles since there's no backend endpoint
    return [
      { id: 1, name: 'user' },
      { id: 2, name: 'department-admin' },
      { id: 3, name: 'super-admin' }
    ];
  } catch (error) {
    console.error('Error fetching roles:', error);
    throw error;
  }
};

// ============ LEAVE DETAILS APIs ============
export const fetchLeaveDetails = async (userId) => {
  try {
    // Use the staff leave details endpoint
    const response = await apiClient.get(`/staff/${userId}/leave-details`);
    return response.data;
  } catch (error) {
    console.error('Error fetching leave details:', error);
    throw error;
  }
};

export const updateLeaveEntitlement = async (userId, entitlement) => {
  try {
    const response = await apiClient.put(`/staff/${userId}/leave-entitlement`, { entitlement });
    return response.data;
  } catch (error) {
    console.error('Error updating leave entitlement:', error);
    throw error;
  }
};

// ============ TRAINING APIs ============
export const fetchUserTrainings = async (fullName) => {
  try {
    // Use the Trainings endpoint - may need to be adjusted based on actual backend endpoint
    const response = await apiClient.get(`/Trainings`, {
      params: { userName: fullName }
    });
    return response.data;
  } catch (error) {
    console.error('Error fetching user trainings:', error);
    // Return empty array if endpoint doesn't exist
    return [];
  }
};

// ============ ATTENDANCE APIs ============
export const fetchAttendance = async (userId) => {
  try {
    const response = await apiClient.get(`/Attendance/${userId}`);
    return response.data;
  } catch (error) {
    console.error('Error fetching attendance:', error);
    throw error;
  }
};
