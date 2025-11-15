import React, { useState, useEffect } from 'react';
import { X } from 'lucide-react';
import './AddStaffDialog.css';
import { apiClient } from '../../../core/api/client';

const AddStaffDialog = ({ isOpen, onClose, onSuccess }) => {
  const initialFormState = {
    fullName: '',
    email: '',
    password: '',
    nric: '',
    tin: '',
    epf: '',
    department: '',
    role: 'user',
    dateJoined: new Date().toISOString().split('T')[0],
    birthday: new Date().toISOString().split('T')[0],
    contactNumber: ''
  };

  const [departments, setDepartments] = useState([]);
  const [roles, setRoles] = useState([]);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [formData, setFormData] = useState(initialFormState);

  useEffect(() => {
    if (isOpen) {
      fetchDepartments();
      fetchRoles();
    }
  }, [isOpen]);

  const resetForm = () => {
    setFormData(initialFormState);
    setError('');
  };

  const fetchDepartments = async () => {
    try {
      const response = await apiClient.get(`/users/departments`);
      setDepartments(response.data);
    } catch (error) {
      console.error('Error fetching departments:', error);
      setError('Failed to fetch departments');
    }
  };

  const fetchRoles = async () => {
    try {
      const response = await apiClient.get(`/users/roles`);
      setRoles(response.data);
    } catch (error) {
      console.error('Error fetching roles:', error);
      setError('Failed to fetch roles');
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const validateForm = () => {
    // Check for required fields
    if (!formData.fullName || !formData.email || !formData.password || 
        !formData.nric || !formData.department) {
      setError('Please fill in all required fields');
      return false;
    }

    // Email validation
    if (!formData.email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
      setError('Please enter a valid email address');
      return false;
    }

    // NRIC validation
    if (!/^\d{12}$/.test(formData.nric)) {
      setError('NRIC must be exactly 12 digits');
      return false;
    }

    // Contact Number validation
      if (formData.contactNumber && !/^[\d\s+-]+$/.test(formData.contactNumber)) {
        setError('Contact number can only contain digits, +, -, or spaces');
        return false;
      }


    const month = parseInt(formData.nric.slice(2, 4), 10);
    if (month < 1 || month > 12) {
      setError('NRIC: Month must be between 01 and 12');
      return false;
    }

    const day = parseInt(formData.nric.slice(4, 6), 10);
    if (day < 1 || day > 31) {
      setError('NRIC: Day must be between 01 and 31');
      return false;
    }

    if (!formData.dateJoined) {
      setError('Date joined is required');
      return false;
    }

    // Ensure date is not in the future
    const selectedDate = new Date(formData.dateJoined);
    const today = new Date();
    if (selectedDate > today) {
      setError('Date joined cannot be in the future');
      return false;
    }

    if (!formData.birthday) {
      setError('Birthday is required');
      return false;
    }

    const selectedBirthday = new Date(formData.birthday);
    if (selectedBirthday > today) {
      setError('Birthday cannot be in the future');
      return false;
    }

    return true;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;

    setIsLoading(true);
    setError('');

    try {
      const userData = {
        fullName: formData.fullName,
        email: formData.email,
        password: formData.password,
        nric: formData.nric,
        tin: formData.tin || null,
        epfNo: formData.epf || null,
        departmentId: formData.department ? parseInt(formData.department) : 1,
        role: formData.role,
        dateJoined: formData.dateJoined + 'T00:00:00',
        birthday: formData.birthday + 'T00:00:00',
        contactNumber: formData.contactNumber || null
      };

      console.log('Creating user with data:', userData);

      const response = await apiClient.post(`/users`, userData);

      if (response.status === 201) {
        resetForm();
        onSuccess();
        onClose();
      }
    } catch (error) {
      console.error('Error adding user:', error);
      console.error('Error response:', error.response?.data);
      console.error('Validation errors:', error.response?.data?.errors);
      console.error('Error status:', error.response?.status);

      // Get first validation error message
      let errorMsg = 'Failed to add user';
      if (error.response?.data?.errors) {
        const errors = error.response.data.errors;
        const firstError = Object.values(errors)[0];
        errorMsg = Array.isArray(firstError) ? firstError[0] : firstError;
      } else if (error.response?.data?.message) {
        errorMsg = error.response.data.message;
      }

      setError(errorMsg);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (!isOpen) {
      resetForm();
    }
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div className="dialog-overlay">
      <div className="dialog-container">
        <div className="dialog-header">
          <h2 className="dialog-title">Add New Staff</h2>
          <button 
            onClick={onClose}
            className="close-button"
          >
            <X size={24} />
          </button>
        </div>
  
        {error && (
          <div className="error-message">
            {error}
          </div>
        )}
  
  <form 
          onSubmit={handleSubmit} 
          className="space-y-4"
          autoComplete="off"
        >
          <div className="form-grid">
            <div>
              <label className="label">Full Name*</label>
              <input
                type="text"
                name="fullName"
                value={formData.fullName}
                onChange={handleInputChange}
                className="input"
                required
                autoComplete="off"
              />
            </div>
            <div>
              <label className="label">Email*</label>
              <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleInputChange}
                className="input"
                required
                autoComplete="new-email"
                data-lpignore="true"
              />
            </div>

            <div>
              <label className="label">Password*</label>
              <input
                type="password"
                name="password"
                value={formData.password}
                onChange={handleInputChange}
                className="input"
                required
                autoComplete="new-password"
                data-lpignore="true"
              />
            </div>

            <div>
              <label className="label">NRIC*</label>
              <input
                type="text"
                name="nric"
                value={formData.nric}
                onChange={handleInputChange}
                className="input"
                placeholder="12-digit NRIC number"
                required
              />
            </div>

            <div>
              <label className="label">TIN</label>
              <input
                type="text"
                name="tin"
                value={formData.tin}
                onChange={handleInputChange}
                className="input"
                placeholder="10-11 digit TIN number"
              />
            </div>

            <div>
              <label className="label">EPF</label>
              <input
                type="text"
                name="epf"
                value={formData.epf}
                onChange={handleInputChange}
                className="input"
                placeholder="7-12 digit EPF number"
              />
            </div>

            <div>
              <label className="label">Contact Number</label>
              <input
                type="text"
                name="contactNumber"
                value={formData.contactNumber}
                onChange={handleInputChange}
                className="input"
                placeholder="e.g. 0123456789"
              />
            </div>

            <div>
              <label className="label">Department*</label>
              <select
                name="department"
                value={formData.department}
                onChange={handleInputChange}
                className="input"
                required
              >
                <option value="">Select Department</option>
                {departments.map(dept => (
                  <option key={dept.id} value={dept.id}>
                    {dept.name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="label">Role*</label>
              <select
                name="role"
                value={formData.role}
                onChange={handleInputChange}
                className="input"
                required
              >
                {roles.map(role => (
                  <option key={role.id} value={role.name}>
                    {role.name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="label">Date Joined*</label>
              <input
                type="date"
                name="dateJoined"
                value={formData.dateJoined}
                onChange={handleInputChange}
                className="input"
                required
              />
            </div>
            <div>
              <label className="label">Birthday*</label>
              <input
                type="date"
                name="birthday"
                value={formData.birthday}
                onChange={handleInputChange}
                className="input"
                required
              />
            </div>
          </div>
  
          <div className="button-group">
            <button
              type="button"
              onClick={onClose}
              className="cancel-button"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isLoading}
              className="submit-button"
            >
              {isLoading ? 'Adding...' : 'Add Staff'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default AddStaffDialog;