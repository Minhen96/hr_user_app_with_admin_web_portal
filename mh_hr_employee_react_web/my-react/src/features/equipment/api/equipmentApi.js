import apiClient from '../../../core/api/client';

/**
 * Fetch equipment categories
 */
export const fetchEquipmentCategories = async () => {
  try {
    const response = await apiClient.get("/EquipmentRequests/categories");
    return response.data;
  } catch (error) {
    console.error("API fetch categories error:", error);
    throw error;
  }
};

/**
 * Fetch fixed asset types
 */
export const fetchFixedAssetTypes = async () => {
  try {
    const response = await apiClient.get("/EquipmentRequests/fixed-asset-types");
    return response.data;
  } catch (error) {
    console.error("API fetch fixed asset types error:", error);
    throw error;
  }
};

/**
 * Fetch approved equipment items
 */
export const fetchApprovedEquipmentItems = async () => {
  try {
    const response = await apiClient.get('/EquipmentItems/approved');
    const modifiedItems = response.data.map(item => ({
      ...item,
      quantity: item.categoryName === 'Fixed Asset' ? 1 : item.quantity
    }));
    return modifiedItems;
  } catch (error) {
    console.error("API fetch equipment items error:", {
      message: error.message,
      response: error.response?.data,
      status: error.response?.status,
    });
    throw error.response?.data || {
      message: "Failed to fetch approved equipment items",
    };
  }
};

/**
 * Fetch equipment returns
 */
export const fetchEquipmentReturns = async () => {
  try {
    const response = await apiClient.get("/EquipmentReturns");
    return response.data;
  } catch (error) {
    console.error("API fetch equipment returns error:", error);
    throw error;
  }
};

/**
 * Fetch equipment return details
 */
export const fetchEquipmentReturnDetails = async (returnId) => {
  try {
    const response = await apiClient.get(`/EquipmentReturns/${returnId}/details`);
    return response.data;
  } catch (error) {
    console.error("API fetch equipment return details error:", error);
    throw error;
  }
};

/**
 * Update equipment return status
 */
export const updateEquipmentReturnStatus = async (returnId, status) => {
  try {
    const response = await apiClient.put(`/EquipmentReturns/${returnId}/status`, {
      status: status
    });
    return response.data;
  } catch (error) {
    console.error("API update equipment return status error:", error);
    throw error;
  }
};

/**
 * Fetch equipment requests (user's own requests)
 */
export const fetchEquipmentRequests = async () => {
  try {
    const response = await apiClient.get(`/EquipmentRequests`);
    return response.data;
  } catch (error) {
    console.error("Fetch equipment requests error:", error);
    throw error;
  }
};

/**
 * Fetch all equipment requests (for admins)
 */
export const fetchAllEquipmentRequests = async (status = null) => {
  try {
    const params = status ? { status } : {};
    const response = await apiClient.get(`/EquipmentRequests/all`, { params });
    return response.data;
  } catch (error) {
    console.error("Fetch all equipment requests error:", error);
    throw error;
  }
};

/**
 * Fetch equipment request details
 */
export const fetchEquipmentRequestDetails = async (requestId) => {
  try {
    const response = await apiClient.get(`/EquipmentRequests/${requestId}/details`);
    return response.data;
  } catch (error) {
    console.error("Fetch equipment request details error:", error);
    throw error;
  }
};

/**
 * Update equipment request status
 */
export const updateEquipmentRequestStatus = async (requestId, status) => {
  try {
    const response = await apiClient.put(`/EquipmentRequests/${requestId}/status`, {
      status: status
    });
    return response.data;
  } catch (error) {
    console.error("Update equipment request status error:", error);
    throw error;
  }
};

/**
 * Approve equipment request
 */
export const approveEquipmentRequest = async (requestId, signature) => {
  try {
    const response = await apiClient.put(`/EquipmentRequests/${requestId}/approve`, {
      signature: signature
    });
    return response.data;
  } catch (error) {
    console.error("Approve equipment request error:", error);
    throw error;
  }
};

/**
 * Reject equipment request
 */
export const rejectEquipmentRequest = async (requestId, reason) => {
  try {
    const response = await apiClient.put(`/EquipmentRequests/${requestId}/reject`, {
      reason: reason
    });
    return response.data;
  } catch (error) {
    console.error("Reject equipment request error:", error);
    throw error;
  }
};

/**
 * Create equipment request
 */
export const createEquipmentRequest = async (requestData) => {
  try {
    const response = await apiClient.post('/EquipmentRequests', requestData);
    return response.data;
  } catch (error) {
    console.error("Create equipment request error:", error);
    throw error;
  }
};

/**
 * Create equipment return
 */
export const createEquipmentReturn = async (returnData) => {
  try {
    const response = await apiClient.post('/EquipmentReturns', returnData);
    return response.data;
  } catch (error) {
    console.error("Create equipment return error:", error);
    throw error;
  }
};
