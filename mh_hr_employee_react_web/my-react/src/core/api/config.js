export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:5000/admin/api";

export const API_TIMEOUT = 30000; // 30 seconds

export const API_CONFIG = {
  baseURL: API_BASE_URL,
  timeout: API_TIMEOUT,
};
