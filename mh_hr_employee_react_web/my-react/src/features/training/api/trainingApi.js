import apiClient from '../../../core/api/client';

// ============ TRAINING APIs ============
export const fetchTrainings = async () => {
  try {
    const response = await apiClient.get('/Trainings');
    return response.data;
  } catch (error) {
    console.error('Error fetching trainings:', error);
    throw error;
  }
};

export const fetchTrainingsByUser = async (userId) => {
  try {
    const response = await apiClient.get(`/Trainings/user/${userId}`);
    return response.data;
  } catch (error) {
    console.error('Error fetching user trainings:', error);
    throw error;
  }
};

export const createTraining = async (trainingData) => {
  try {
    const response = await apiClient.post('/Trainings', trainingData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });
    return response.data;
  } catch (error) {
    console.error('Error creating training:', error);
    throw error;
  }
};

export const updateTraining = async (trainingId, trainingData) => {
  try {
    const response = await apiClient.put(`/Trainings/${trainingId}`, trainingData);
    return response.data;
  } catch (error) {
    console.error('Error updating training:', error);
    throw error;
  }
};

export const deleteTraining = async (trainingId) => {
  try {
    const response = await apiClient.delete(`/Trainings/${trainingId}`);
    return response.data;
  } catch (error) {
    console.error('Error deleting training:', error);
    throw error;
  }
};

export const updateTrainingStatus = async (trainingId, status) => {
  try {
    const response = await apiClient.put(`/Trainings/${trainingId}/status`, { status });
    return response.data;
  } catch (error) {
    console.error('Error updating training status:', error);
    throw error;
  }
};

// ============ TRAINING CERTIFICATE APIs ============
export const fetchTrainingCertificate = async (trainingId) => {
  try {
    const response = await apiClient.get(`/Trainings/${trainingId}/certificate`, {
      responseType: 'blob'
    });
    return response.data;
  } catch (error) {
    console.error('Error fetching training certificate:', error);
    throw error;
  }
};

export const fetchTrainingCertificates = async (userId) => {
  try {
    const response = await apiClient.get(`/Trainings/user/${userId}/certificates`);
    return response.data;
  } catch (error) {
    console.error('Error fetching training certificates:', error);
    throw error;
  }
};

export const uploadTrainingCertificate = async (trainingId, certificateFile) => {
  try {
    const formData = new FormData();
    formData.append('certificate', certificateFile);

    const response = await apiClient.post(`/Trainings/${trainingId}/certificate`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });
    return response.data;
  } catch (error) {
    console.error('Error uploading training certificate:', error);
    throw error;
  }
};

export const downloadTrainingCertificate = async (trainingId, filename) => {
  try {
    const response = await apiClient.get(`/Trainings/${trainingId}/certificate/download`, {
      responseType: 'blob'
    });

    const url = window.URL.createObjectURL(new Blob([response.data]));
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', filename || 'certificate.pdf');
    document.body.appendChild(link);
    link.click();
    link.remove();
    window.URL.revokeObjectURL(url);
  } catch (error) {
    console.error('Error downloading training certificate:', error);
    throw error;
  }
};
