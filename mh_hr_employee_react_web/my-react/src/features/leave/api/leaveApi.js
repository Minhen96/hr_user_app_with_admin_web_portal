import apiClient from '../../../core/api/client';

// ============ CALENDAR APIs ============
export const getCalendarData = async (startDate, endDate) => {
  try {
    const response = await apiClient.get(`/Leaves/calendar`, {
      params: {
        startDate: startDate.toISOString(),
        endDate: endDate.toISOString()
      }
    });
    return response.data;
  } catch (error) {
    console.error('Error fetching calendar data:', error);
    throw error;
  }
};

// ============ LEAVE REQUEST APIs ============
export const getLeaves = async () => {
  try {
    const response = await apiClient.get('/Leaves');
    return response.data;
  } catch (error) {
    console.error('Error fetching leaves:', error);
    throw error;
  }
};

export const createLeave = async (leaveData) => {
  try {
    const response = await apiClient.post('/Leaves', leaveData);
    return response.data;
  } catch (error) {
    console.error('Error creating leave:', error);
    throw error;
  }
};

export const updateLeave = async (leaveId, leaveData) => {
  try {
    const response = await apiClient.put(`/Leaves/${leaveId}`, leaveData);
    return response.data;
  } catch (error) {
    console.error('Error updating leave:', error);
    throw error;
  }
};

export const deleteLeave = async (leaveId) => {
  try {
    const response = await apiClient.delete(`/Leaves/${leaveId}`);
    return response.data;
  } catch (error) {
    console.error('Error deleting leave:', error);
    throw error;
  }
};

export const approveLeave = async (leaveId, signatureData) => {
  try {
    const response = await apiClient.put(`/Leaves/${leaveId}/approve`, { signature: signatureData });
    return response.data;
  } catch (error) {
    console.error('Error approving leave:', error);
    throw error;
  }
};

export const rejectLeave = async (leaveId, reason) => {
  try {
    const response = await apiClient.put(`/Leaves/${leaveId}/reject`, { reason });
    return response.data;
  } catch (error) {
    console.error('Error rejecting leave:', error);
    throw error;
  }
};

// ============ MEDICAL LEAVE APIs ============
export const getMedicalLeaves = async () => {
  try {
    const response = await apiClient.get('/MedicalLeave');
    return response.data;
  } catch (error) {
    console.error('Error fetching medical leaves:', error);
    throw error;
  }
};

export const createMedicalLeave = async (medicalLeaveData) => {
  try {
    const response = await apiClient.post('/MedicalLeave', medicalLeaveData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });
    return response.data;
  } catch (error) {
    console.error('Error creating medical leave:', error);
    throw error;
  }
};

export const approveMedicalLeave = async (leaveId, signatureData) => {
  try {
    const response = await apiClient.put(`/MedicalLeave/${leaveId}/approve`, { signature: signatureData });
    return response.data;
  } catch (error) {
    console.error('Error approving medical leave:', error);
    throw error;
  }
};

// ============ HOLIDAY APIs ============
export const getHolidays = async () => {
  try {
    const response = await apiClient.get('/Holiday');
    return response.data;
  } catch (error) {
    console.error('Error fetching holidays:', error);
    throw error;
  }
};

export const createHoliday = async (holidayData) => {
  try {
    const response = await apiClient.post('/Holiday', holidayData);
    return response.data;
  } catch (error) {
    console.error('Error creating holiday:', error);
    throw error;
  }
};

export const deleteHoliday = async (holidayId) => {
  try {
    const response = await apiClient.delete(`/Holiday/${holidayId}`);
    return response.data;
  } catch (error) {
    console.error('Error deleting holiday:', error);
    throw error;
  }
};

// ============ LEAVE BALANCE APIs ============
export const getLeaveBalance = async (userId) => {
  try {
    const response = await apiClient.get(`/Leave/balance/${userId}`);
    return response.data;
  } catch (error) {
    console.error('Error fetching leave balance:', error);
    throw error;
  }
};

// ============ USER LEAVE DETAILS APIs ============
export const getUserLeaveDetails = async (userId) => {
  try {
    const response = await apiClient.get(`/staff/${userId}/leave-details`);
    return response.data;
  } catch (error) {
    console.error('Error fetching user leave details:', error);
    throw error;
  }
};
