import apiClient from '../../../core/api/client';

// ============ REQUEST APPROVAL APIs ============
export const getAllRequests = async (type = 'all') => {
  try {
    const response = await apiClient.get(`/Approval/requests`, {
      params: { type }
    });
    return response.data;
  } catch (error) {
    console.error('Error fetching requests:', error);
    throw error;
  }
};

export const getRequestDetails = async (requestId, requestType) => {
  try {
    const response = await apiClient.get(`/Approval/${requestType}/${requestId}`);
    return response.data;
  } catch (error) {
    console.error('Error fetching request details:', error);
    throw error;
  }
};

export const updateRequestStatus = async (requestId, requestType, status, signature = null) => {
  try {
    const response = await apiClient.put(`/Approval/${requestType}/${requestId}/status`, {
      status,
      signature
    });
    return response.data;
  } catch (error) {
    console.error('Error updating request status:', error);
    throw error;
  }
};

export const approveRequest = async (requestId, requestType, signatureData) => {
  try {
    const response = await apiClient.put(`/Approval/${requestType}/${requestId}/approve`, {
      signature: signatureData
    });
    return response.data;
  } catch (error) {
    console.error('Error approving request:', error);
    throw error;
  }
};

export const rejectRequest = async (requestId, requestType, reason) => {
  try {
    const response = await apiClient.put(`/Approval/${requestType}/${requestId}/reject`, {
      reason
    });
    return response.data;
  } catch (error) {
    console.error('Error rejecting request:', error);
    throw error;
  }
};

// ============ PASSWORD CHANGE APPROVAL APIs ============
export const getPasswordChangeRequests = async () => {
  try {
    const response = await apiClient.get('/Approval/password-changes');
    return response.data;
  } catch (error) {
    console.error('Error fetching password change requests:', error);
    throw error;
  }
};

export const approvePasswordChange = async (requestId, signatureData) => {
  try {
    const response = await apiClient.put(`/Approval/password-change/${requestId}/approve`, {
      signature: signatureData
    });
    return response.data;
  } catch (error) {
    console.error('Error approving password change:', error);
    throw error;
  }
};

export const rejectPasswordChange = async (requestId, reason) => {
  try {
    const response = await apiClient.put(`/Approval/password-change/${requestId}/reject`, {
      reason
    });
    return response.data;
  } catch (error) {
    console.error('Error rejecting password change:', error);
    throw error;
  }
};
