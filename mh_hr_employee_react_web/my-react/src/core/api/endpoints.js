// Authentication
export const AUTH_ENDPOINTS = {
  LOGIN: "/Auth/login",
  LOGOUT: "/Auth/logout",
  CHANGE_PASSWORD: "/Auth/change-password",
};

// Equipment
export const EQUIPMENT_ENDPOINTS = {
  LIST: "/Equipment",
  CREATE: "/Equipment",
  UPDATE: "/Equipment",
  DELETE: "/Equipment",
  CATEGORIES: "/Equipment/categories",
  RETURN: "/Equipment/return",
};

// Documents
export const DOCUMENT_ENDPOINTS = {
  MEMO: "/Memo",
  POLICY: "/Policy",
  SOP: "/SOP",
  UPDATES: "/Updates",
  HANDBOOK: "/Handbook",
};

// Leave
export const LEAVE_ENDPOINTS = {
  LIST: "/Leave",
  CREATE: "/Leave",
  APPROVE: "/Leave/approve",
  REJECT: "/Leave/reject",
  CALENDAR: "/Leave/calendar",
  MEDICAL: "/Leave/medical",
};

// Staff
export const STAFF_ENDPOINTS = {
  LIST: "/Staff",
  CREATE: "/Staff",
  UPDATE: "/Staff",
  DELETE: "/Staff",
  DEPARTMENTS: "/Departments",
  ATTENDANCE: "/Attendance",
};

// Training
export const TRAINING_ENDPOINTS = {
  LIST: "/Training",
  APPROVE: "/Training/approve",
  CERTIFICATES: "/Training/certificates",
};

// Profile
export const PROFILE_ENDPOINTS = {
  GET: "/Profile",
  UPDATE: "/Profile",
  CHANGE_PASSWORD: "/Profile/change-password",
};

// Approvals
export const APPROVAL_ENDPOINTS = {
  PENDING: "/Approvals/pending",
  APPROVE: "/Approvals/approve",
  REJECT: "/Approvals/reject",
};
