import apiClient from '../../../core/api/client';

// ============ MEMO APIs ============
export const fetchMemos = async () => {
  const response = await apiClient.get('/Memo');
  return response.data;
};

export const createMemo = async (memoData) => {
  const formData = new FormData();
  formData.append('Title', memoData.title);
  if (memoData.content) {
    formData.append('Content', memoData.content);
  }
  formData.append('DepartmentId', memoData.departmentId);
  formData.append('PostBy', memoData.userId);
  if (memoData.file) {
    formData.append('File', memoData.file);
  }

  const response = await apiClient.post('/Memo', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  return response.data;
};

export const updateMemo = async (id, memoData) => {
  const formData = new FormData();
  formData.append('Title', memoData.title);
  if (memoData.content) {
    formData.append('Content', memoData.content);
  }
  formData.append('DepartmentId', memoData.departmentId);
  if (memoData.file) {
    formData.append('File', memoData.file);
  }

  const response = await apiClient.put(`/Memo/${id}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  return response.data;
};

export const deleteMemo = async (id) => {
  const response = await apiClient.delete(`/Memo/${id}`);
  return response.data;
};

export const downloadMemo = async (id, filename) => {
  const response = await apiClient.get(`/Memo/${id}/download`, {
    responseType: 'blob'
  });

  const url = window.URL.createObjectURL(new Blob([response.data]));
  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', filename);
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.URL.revokeObjectURL(url);
};

export const markMemoAsRead = async (memoId) => {
  const response = await apiClient.post(`/Memo/${memoId}/mark-read`);
  return response.data;
};

// ============ POLICY APIs ============
export const fetchPolicies = async () => {
  const response = await apiClient.get('/Policy');
  return response.data;
};

export const createPolicy = async (policyData) => {
  const formData = new FormData();
  formData.append('Title', policyData.title);
  if (policyData.content) {
    formData.append('Content', policyData.content);
  }
  formData.append('DepartmentId', policyData.departmentId);
  formData.append('PostBy', policyData.userId);
  if (policyData.file) {
    formData.append('File', policyData.file);
  }

  const response = await apiClient.post('/Policy', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  return response.data;
};

export const updatePolicy = async (id, policyData) => {
  const formData = new FormData();
  formData.append('Title', policyData.title);
  if (policyData.content) {
    formData.append('Content', policyData.content);
  }
  formData.append('DepartmentId', policyData.departmentId);
  if (policyData.file) {
    formData.append('File', policyData.file);
  }

  const response = await apiClient.put(`/Policy/${id}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  return response.data;
};

export const deletePolicy = async (id) => {
  const response = await apiClient.delete(`/Policy/${id}`);
  return response.data;
};

export const downloadPolicy = async (id, filename) => {
  const response = await apiClient.get(`/Policy/${id}/download`, {
    responseType: 'blob'
  });

  const url = window.URL.createObjectURL(new Blob([response.data]));
  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', filename);
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.URL.revokeObjectURL(url);
};

export const markPolicyAsRead = async (policyId) => {
  const response = await apiClient.post(`/Policy/${policyId}/mark-read`);
  return response.data;
};

// ============ SOP APIs ============
export const fetchSOPs = async () => {
  const response = await apiClient.get('/SOP');
  return response.data;
};

export const createSOP = async (sopData) => {
  const formData = new FormData();
  formData.append('Title', sopData.title);
  if (sopData.content) {
    formData.append('Content', sopData.content);
  }
  formData.append('DepartmentId', sopData.departmentId);
  formData.append('PostBy', sopData.userId);
  if (sopData.file) {
    formData.append('File', sopData.file);
  }

  const response = await apiClient.post('/SOP', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  return response.data;
};

export const updateSOP = async (id, sopData) => {
  const formData = new FormData();
  formData.append('Title', sopData.title);
  if (sopData.content) {
    formData.append('Content', sopData.content);
  }
  formData.append('DepartmentId', sopData.departmentId);
  if (sopData.file) {
    formData.append('File', sopData.file);
  }

  const response = await apiClient.put(`/SOP/${id}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  return response.data;
};

export const deleteSOP = async (id) => {
  const response = await apiClient.delete(`/SOP/${id}`);
  return response.data;
};

export const downloadSOP = async (id, filename) => {
  const response = await apiClient.get(`/SOP/${id}/download`, {
    responseType: 'blob'
  });

  const url = window.URL.createObjectURL(new Blob([response.data]));
  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', filename);
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.URL.revokeObjectURL(url);
};

export const markSOPAsRead = async (sopId) => {
  const response = await apiClient.post(`/SOP/${sopId}/mark-read`);
  return response.data;
};

// ============ UPDATES APIs ============
export const fetchUpdates = async () => {
  const response = await apiClient.get('/Updates');
  return response.data;
};

export const createUpdates = async (updatesData) => {
  const formData = new FormData();
  formData.append('Title', updatesData.title);
  if (updatesData.content) {
    formData.append('Content', updatesData.content);
  }
  formData.append('DepartmentId', updatesData.departmentId);
  formData.append('PostBy', updatesData.userId);
  if (updatesData.file) {
    formData.append('File', updatesData.file);
  }

  const response = await apiClient.post('/Updates', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  return response.data;
};

export const updateUpdates = async (id, updatesData) => {
  const formData = new FormData();
  formData.append('Title', updatesData.title);
  if (updatesData.content) {
    formData.append('Content', updatesData.content);
  }
  formData.append('DepartmentId', updatesData.departmentId);
  if (updatesData.file) {
    formData.append('File', updatesData.file);
  }

  const response = await apiClient.put(`/Updates/${id}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  return response.data;
};

export const deleteUpdates = async (id) => {
  const response = await apiClient.delete(`/Updates/${id}`);
  return response.data;
};

export const downloadUpdates = async (id, filename) => {
  const response = await apiClient.get(`/Updates/${id}/download`, {
    responseType: 'blob'
  });

  const url = window.URL.createObjectURL(new Blob([response.data]));
  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', filename);
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.URL.revokeObjectURL(url);
};

export const markUpdatesAsRead = async (updateId) => {
  const response = await apiClient.post(`/Updates/${updateId}/mark-read`);
  return response.data;
};

// ============ HANDBOOK APIs ============
export const fetchHandbooks = async () => {
  const response = await apiClient.get('/Handbook');
  return response.data;
};

export const createHandbook = async (formData) => {
  const response = await apiClient.post('/Handbook', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  return response.data;
};

export const updateHandbook = async (id, formData) => {
  const response = await apiClient.put(`/Handbook/${id}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  return response.data;
};

export const deleteHandbook = async (id) => {
  const response = await apiClient.delete(`/Handbook/${id}`);
  return response.data;
};

export const downloadHandbook = async (id, filename) => {
  const response = await apiClient.get(`/Handbook/${id}/download`, {
    responseType: 'blob'
  });

  const url = window.URL.createObjectURL(new Blob([response.data]));
  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', filename);
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.URL.revokeObjectURL(url);
};

export const fetchHandbookImage = async (id) => {
  const response = await apiClient.get(`/Handbook/${id}/image`, {
    responseType: 'arraybuffer'
  });
  return response.data;
};

// ============ HANDBOOK SECTION/CONTENT APIs ============
export const fetchHandbookSections = async () => {
  try {
    const response = await apiClient.get('/Handbook/sections');
    return response.data.sections;
  } catch (error) {
    console.error('Error fetching handbook sections:', error);
    throw error.response?.data || {
      message: "Failed to fetch handbook sections",
    };
  }
};

export const addHandbookSection = async (title) => {
  try {
    const response = await apiClient.post('/Handbook/sections', { title });
    return response.data;
  } catch (error) {
    console.error('Error adding section:', error);
    throw error.response?.data || {
      message: "Failed to add section",
    };
  }
};

export const deleteHandbookSection = async (sectionId) => {
  try {
    const response = await apiClient.delete(`/Handbook/sections/${sectionId}`);
    return response.data;
  } catch (error) {
    console.error('Error deleting section:', error);
    throw error.response?.data || {
      message: "Failed to delete section",
    };
  }
};

export const addHandbookContent = async (handbookSectionId, subtitle, content) => {
  try {
    const response = await apiClient.post('/Handbook/contents', {
      handbookSectionId,
      subtitle,
      content
    });
    return response.data;
  } catch (error) {
    console.error('Error adding content:', error);
    throw error.response?.data || {
      message: "Failed to add content",
    };
  }
};

export const updateHandbookContent = async (contentId, subtitle, content) => {
  try {
    const response = await apiClient.put(`/Handbook/contents/${contentId}`, {
      subtitle,
      content
    });
    return response.data;
  } catch (error) {
    console.error('Error updating content:', error);
    throw error.response?.data || {
      message: "Failed to update content",
    };
  }
};

export const deleteHandbookContent = async (contentId) => {
  try {
    const response = await apiClient.delete(`/Handbook/contents/${contentId}`);
    return response.data;
  } catch (error) {
    console.error('Error deleting content:', error);
    throw error.response?.data || {
      message: "Failed to delete content",
    };
  }
};

// ============ DEPARTMENT APIs ============
export const fetchDepartment1 = async () => {
  try {
    const response = await apiClient.get("/Documents/departments");
    return response.data;
  } catch (error) {
    console.error('Error fetching departments:', error);
    throw error;
  }
};

// ============ COMMON APIs ============
export const fetchAllDocuments = async () => {
  const [memos, policies, sops, updates, handbooks] = await Promise.all([
    fetchMemos(),
    fetchPolicies(),
    fetchSOPs(),
    fetchUpdates(),
    fetchHandbooks()
  ]);

  return {
    memos,
    policies,
    sops,
    updates,
    handbooks
  };
};

// Fetch documents based on type
export const fetchDocuments = async (type, userId) => {
  switch (type) {
    case 'MEMO':
      return await fetchMemos();
    case 'POLICY':
      return await fetchPolicies();
    case 'SOP':
      return await fetchSOPs();
    case 'UPDATES':
      return await fetchUpdates();
    case 'HANDBOOK':
      return await fetchHandbooks();
    case 'ALL':
      return await fetchAllDocuments();
    default:
      return [];
  }
};

// Delete document based on type
export const deleteDocument = async (documentId, type) => {
  switch (type) {
    case 'MEMO':
      return await deleteMemo(documentId);
    case 'POLICY':
      return await deletePolicy(documentId);
    case 'SOP':
      return await deleteSOP(documentId);
    case 'UPDATES':
      return await deleteUpdates(documentId);
    case 'HANDBOOK':
      return await deleteHandbook(documentId);
    default:
      throw new Error('Unknown document type');
  }
};

// Download document based on type
export const downloadDocument = async (documentId, filename, type) => {
  switch (type) {
    case 'MEMO':
      return await downloadMemo(documentId, filename);
    case 'POLICY':
      return await downloadPolicy(documentId, filename);
    case 'SOP':
      return await downloadSOP(documentId, filename);
    case 'UPDATES':
      return await downloadUpdates(documentId, filename);
    case 'HANDBOOK':
      return await downloadHandbook(documentId, filename);
    default:
      throw new Error('Unknown document type');
  }
};
