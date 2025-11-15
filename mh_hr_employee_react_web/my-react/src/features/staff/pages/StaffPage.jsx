import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { X, Search, Filter, Edit, Trash, ArrowUp, ArrowDown } from 'lucide-react';
import AddStaffDialog from '../components/AddStaffDialog';
import DepartmentDialog from '../components/DepartmentDialog';
import { FaToggleOn, FaToggleOff } from 'react-icons/fa';
import TrainingDetailsDialog from '../../training/components/TrainingDetailsDialog';
import './StaffPage.css';

import {
  fetchUsers,
  updateUser,
  deleteUser,
  toggleUserStatus,
  fetchDepartment,
  fetchRoles,
  fetchLeaveDetails,
  updateLeaveEntitlement,
  fetchUserTrainings
} from '../api/staffApi';

const ROLE_HIERARCHY = {
    'super-admin': 3,
    'department-admin': 2,
    'user': 1
  };

  const hasHigherOrEqualRole = (userRole, targetRole) => {
    return ROLE_HIERARCHY[userRole] >= ROLE_HIERARCHY[targetRole];
  };
  
  const canViewDetails = (currentUser, targetUser) => {
    if (currentUser.role === 'super-admin') return true;

    if (currentUser.role === 'department-admin') {
      return currentUser.department_name === targetUser.department && 
             hasHigherOrEqualRole(currentUser.role, targetUser.role);
    }
    
    return currentUser.id === targetUser.id;
  };
  
  const canEdit = (currentUser, targetUser) => {

    if (currentUser.role === 'super-admin') return true;

    if (currentUser.role === 'department-admin') {
      return currentUser.department_name === targetUser.department && 
             ROLE_HIERARCHY[currentUser.role] > ROLE_HIERARCHY[targetUser.role];
    }
    
    return false;
  };
  
  const canDelete = (currentUser, targetUser) => {
    if (currentUser.role === 'super-admin') return true;
    if (currentUser.role === 'department-admin') {
        return currentUser.department_name === targetUser.department && 
               ROLE_HIERARCHY[currentUser.role] > ROLE_HIERARCHY[targetUser.role];
      }
    return false;
  };

  

  const StaffDialog = ({ isOpen, onClose, user, mode }) => {
    const [editableUser, setEditableUser] = useState(null);
    const [departments, setDepartments] = useState([]);
    const [roles, setRoles] = useState([]);
    const [currentStep, setCurrentStep] = useState(1);
    const [trainings, setTrainings] = useState([]);
  const [selectedTraining, setSelectedTraining] = useState(null);
  const [isTrainingDetailsOpen, setIsTrainingDetailsOpen] = useState(false);
    const [leaveType, setLeaveType] = useState('regular');
    const [leaveDetails, setLeaveDetails] = useState({
      entitlement: 0,
      taken: 0,
      balance: 0,
      leaves: [],
      medicalLeaves: []
    });
    const [isEditingEntitlement, setIsEditingEntitlement] = useState(false);
    const [tempEntitlement, setTempEntitlement] = useState(0);
    const [error, setError] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const currentUser = JSON.parse(localStorage.getItem('user'));
    const totalSteps = 3;

    const steps = [
      { number: 1, title: "Personal Details" },
      { number: 2, title: "Leave Information" },
      { number: 3, title: "Training Records" }
    ];

    useEffect(() => {
      if (user && isOpen) {
        setEditableUser({
          ...user,
          department: user.department,
          newPassword: ''
        });
        fetchLeaveDetailsData();
        fetchDepartmentsData();
        fetchRolesData();
        setError('');
        fetchTrainings();
      }
    }, [user, isOpen]);

    const renderStepIndicator = () => (
      <div className="flex items-center justify-center mb-6 w-full">
        {steps.map((step, index) => (
          <React.Fragment key={step.number}>
            <div
              className={`flex flex-col items-center relative ${
                index < steps.length - 1 ? 'mr-12' : ''
              }`}
            >
              <div
                className={`w-8 h-8 rounded-full flex items-center justify-center z-10 relative ${
                  currentStep >= step.number
                    ? 'bg-blue-600 text-white'
                    : 'bg-gray-200 text-gray-600'
                }`}
                onClick={() => setCurrentStep(step.number)}
                style={{ cursor: 'pointer' }}
              >
                {step.number}
                
                {/* Enhanced connecting line */}
               
              </div>
              <span className="text-sm mt-2">{step.title}</span>
            </div>
          </React.Fragment>
        ))}
      </div>
    );
  
    const renderNavigationButtons = () => (
      <div className="flex justify-between mt-6">
        <button
          className={`px-4 py-2 rounded ${
            currentStep === 1 ? 'invisible' : 'bg-gray-200 hover:bg-gray-300'
          }`}
          onClick={() => setCurrentStep(prev => prev - 1)}
          disabled={currentStep === 1}
        >
          Previous
        </button>
        <div className="flex gap-2">
          {mode === 'edit' && currentStep === 1 && (
            <button
              type="submit"
              className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
              disabled={isLoading}
            >
              {isLoading ? 'Saving...' : 'Save Changes'}
            </button>
          )}
          {currentStep < totalSteps && (
            <button
              className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
              onClick={() => setCurrentStep(prev => prev + 1)}
            >
              Next
            </button>
          )}
        </div>
      </div>
    );
  

    const fetchTrainings = async () => {
      try {
        const userTrainings = await fetchUserTrainings(user.fullName);
        setTrainings(userTrainings);
      } catch (error) {
        console.error('Error fetching trainings:', error);
        setError('Failed to fetch trainings');
      }
    };
    const handleEntitlementEdit = async () => {
      try {
        await updateLeaveEntitlement(user.id, parseInt(tempEntitlement));
        setLeaveDetails(prev => ({
          ...prev,
          entitlement: parseInt(tempEntitlement),
          balance: parseInt(tempEntitlement) - prev.taken
        }));
        setIsEditingEntitlement(false);
      } catch (error) {
        console.error('Error updating entitlement:', error);
        setError(error.message || 'Failed to update entitlement');
      }
    };
    
      const canEditEntitlement = (currentUser, targetUser) => {
        if (currentUser.role === 'super-admin') return true;
        if (currentUser.role === 'department-admin') {
          return currentUser.department_name === targetUser.department && 
                 ROLE_HIERARCHY[currentUser.role] > ROLE_HIERARCHY[targetUser.role];
        }
        return false;
      };

    
  
      const fetchDepartmentsData = async () => {
        try {
          const data = await fetchDepartment();
          setDepartments(data);
        } catch (error) {
          console.error('Error fetching departments:', error);
          
        }
      };

    const renderTrainingPage = () => (
      <div>
        <table className="staff-table">
          <thead>
            <tr>
              <th>Course Date</th>
              <th>Title</th>
              <th>Status</th>
              <th>Details</th>
            </tr>
          </thead>
          <tbody>
            {trainings.map((training) => (
              <tr key={training.id}>
                <td>
                  {new Date(training.courseDate).toLocaleDateString('en-GB', {
                    day: '2-digit',
                    month: '2-digit',
                    year: 'numeric'
                  })}
                </td>
                <td>{training.title}</td>
                <td>
                  <span className={`status-badge status-${training.status}`}>
                    {training.status}
                  </span>
                </td>
                <td>
                  <span
                    className="view-details"
                    onClick={() => {
                      setSelectedTraining(training);
                      setIsTrainingDetailsOpen(true);
                    }}
                  >
                    View Details
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
  
  
        {selectedTraining && (
          <TrainingDetailsDialog
            isOpen={isTrainingDetailsOpen}
            onClose={() => {
              setIsTrainingDetailsOpen(false);
              setSelectedTraining(null);
            }}
            trainingDetails={selectedTraining}
            certificateId={selectedTraining.id}
          />
        )}
      </div>
    );

    
  
    const fetchRolesData = async () => {
      try {
        const data = await fetchRoles();
        setRoles(data);
      } catch (error) {
        console.error('Error fetching roles:', error);
        setError('Failed to fetch roles');
      }
    };

    const handleInputChange = (e) => {
      const { name, value } = e.target;
      setEditableUser(prev => ({
        ...prev,
        [name]: value
      }));
    };
  
    const fetchLeaveDetailsData = async () => {
      try {
        const data = await fetchLeaveDetails(user.id);
        setLeaveDetails(data);
      } catch (error) {
        console.error('Error fetching leave details:', error);
        setError('Failed to fetch leave details');
      }
    };
    
    const canDisable = (currentUser, targetUser) => {
      if (currentUser.role === 'super-admin') return true;
      if (currentUser.role === 'department-admin') {
        return currentUser.department_name === targetUser.department && 
               ROLE_HIERARCHY[currentUser.role] > ROLE_HIERARCHY[targetUser.role];
      }
      return false;
    };
  
    const validateForm = () => {
      // Clear previous errors
      setError('');
    
      // Validate required fields
      if (!editableUser.fullName || !editableUser.email || !editableUser.department) {
        setError('Please fill in all required fields');
        return false;
      }
    
      // Email validation
      if (!editableUser.email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
        setError('Please enter a valid email address');
        return false;
      }
    
      // NRIC Validation
      const nricRegex = /^\d{12}$/;
      if (!nricRegex.test(editableUser.nric)) {
        setError('NRIC must be exactly 12 digits');
        return false;
      }

      // Contact Number validation
      if (editableUser.contactNumber && !/^[\d\s+-]+$/.test(editableUser.contactNumber)) {
        setError('Contact number can only contain digits, +, -, or spaces');
        return false;
      }

    
      // NRIC month validation (3rd and 4th digits)
      const nricMonth = parseInt(editableUser.nric.slice(2, 4), 10);
      if (nricMonth < 1 || nricMonth > 12) {
        setError('NRIC month must be between 01 and 12');
        return false;
      }
    
      // NRIC day validation (5th and 6th digits)
      const nricDay = parseInt(editableUser.nric.slice(4, 6), 10);
      if (nricDay < 1 || nricDay > 31) {
        setError('NRIC day must be between 01 and 31');
        return false;
      }
    
      // // TIN Validation (10-11 alphanumeric characters)
      // if (editableUser.tin) {
      //   const tinRegex = /^[a-zA-Z0-9]{10,11}$/;
      //   if (!tinRegex.test(editableUser.tin)) {
      //     setError('TIN must be 10-11 alphanumeric characters');
      //     return false;
      //   }
      // }
    
      // // EPF Validation (7-12 digits)
      // if (editableUser.epf) {
      //   const epfRegex = /^\d{7,12}$/;
      //   if (!epfRegex.test(editableUser.epf)) {
      //     setError('EPF number must be 7-12 digits');
      //     return false;
      //   }
      // }
    
      return true;
    };
  
    const handleSubmit = async (e) => {
      e.preventDefault();
      if (!validateForm()) return;
    
      setIsLoading(true);
      setError('');
    
      try {
        const updateData = {
          fullName: editableUser.fullName,
          email: editableUser.email,
          department: editableUser.department,
          role: editableUser.role,
          nric: editableUser.nric,
          tin: editableUser.tin || null,
          epf: editableUser.epf || null,
          dateJoined: editableUser.dateJoined, // Add this line
          birthday: editableUser.birthday,
          contactNumber: editableUser.contactNumber,
          password: ''
        };
    
        if (editableUser.newPassword && editableUser.newPassword.trim() !== '') {
          updateData.password = editableUser.newPassword;
        }
    
        await updateUser(user.id, updateData);
        onClose();
        window.location.reload();
      } catch (error) {
        console.error('Error updating user:', error);
        setError(error.response?.data?.message || 'Failed to update user');
      } finally {
        setIsLoading(false);
      }
    };
  
    if (!isOpen) return null;

    const renderContent = () => {
      switch (currentStep) {
        case 1:
          return (
            <form onSubmit={handleSubmit}>
              <div className="grid grid-cols-2 gap-4">
              <div className="form-group">
                  <label className="form-label">Name*</label>
                  <input
                    type="text"
                    className="form-input"
                    name="fullName"
                    value={editableUser?.fullName || ''}
                    onChange={handleInputChange}
                    readOnly={mode === 'view'}
                    required
                  />
                </div>
                <div className="form-group">
                    <label className="form-label">Role*</label>
                    {mode === 'view' || currentUser.role !== 'super-admin' ? (
                    <input
                        type="text"
                        className="form-input"
                        value={editableUser?.role || ''}
                        readOnly
                    />
                    ) : (
                    <select
                        className="form-input"
                        name="role"
                        value={editableUser?.role || ''}
                        onChange={handleInputChange}
                        required
                    >
                        <option value="">Select Role</option>
                        {roles.map(role => (
                        <option key={role.id} value={role.name}>
                            {role.name}
                        </option>
                        ))}
                    </select>
                    )}
                </div>
                <div className="form-group">
                  <label className="form-label">Date Joined*</label>
                  <input
                    type="date"
                    className="form-input"
                    name="dateJoined"
                    value={editableUser?.dateJoined ? new Date(editableUser.dateJoined).toISOString().split('T')[0] : ''}
                    onChange={handleInputChange}
                    readOnly={mode === 'view' || currentUser.role !== 'super-admin'}
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Birthday*</label>
                  <input
                    type="date"
                    className="form-input"
                    name="birthday"
                    value={editableUser?.birthday ? new Date(editableUser.birthday).toISOString().split('T')[0] : ''}
                    onChange={handleInputChange}
                    readOnly={mode === 'view' || currentUser.role !== 'super-admin'}
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">NRIC*</label>
                  <input
                    type="text"
                    className="form-input"
                    name="nric"
                    value={editableUser?.nric || ''}
                    onChange={handleInputChange}
                    readOnly={mode === 'view'}
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">TIN</label>
                  <input
                    type="text"
                    className="form-input"
                    name="tin"
                    value={editableUser?.tin || ''}
                    onChange={handleInputChange}
                    readOnly={mode === 'view'}
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">EPF</label>
                  <input
                    type="text"
                    className="form-input"
                    name="epf"
                    value={editableUser?.epf || ''}
                    onChange={handleInputChange}
                    readOnly={mode === 'view'}
                  />
                </div>
                <div className="form-group">
                        <label className="form-label">Department*</label>
                        {mode === 'view' ? (
                        <input
                            type="text"
                            className="form-input"
                            value={editableUser?.department || ''}
                            readOnly
                        />
                        ) : (
                        <select
                            className="form-input"
                            name="department"
                            value={editableUser?.department || ''}
                            onChange={handleInputChange}
                            required
                        >
                            <option value="">Select Department</option>
                            {departments.map(dept => (
                            <option key={dept.id} value={dept.name}>
                                {dept.name}
                            </option>
                            ))}
                        </select>
                        )}
                    </div>
                    <div className="form-group">
                    <label className="form-label">Contact Number</label>
                    <input
                      type="text"
                      name="contactNumber"
                      value={editableUser?.contactNumber}
                      onChange={handleInputChange}
                      className="input"
                      placeholder="e.g. 0123456789"
                    />
                  </div>
                <div className="form-group">
                  <label className="form-label">Email*</label>
                  <input
                    type="email"
                    className="form-input"
                    name="email"
                    value={editableUser?.email || ''}
                    onChange={handleInputChange}
                    readOnly={mode === 'view'}
                    required
                  />
                </div>
                {mode === 'edit' && (
                  <div className="form-group">
                    <label className="form-label">New Password</label>
                    <input
                      type="password"
                      className="form-input"
                      name="newPassword"
                      onChange={handleInputChange}
                      placeholder="Leave blank to keep current password"
                    />
                  </div>
                )}
              </div>
              
              {renderNavigationButtons()}
            </form>
          );
          case 2:
            return (
              <div>
                <div className="stats-grid">
                  {leaveType !== "medical" && ( // Only display for non-medical leaves
                    <>
                      <div className="stat-card">
                        <h3 className="stat-title">Entitlement</h3>
                        {isEditingEntitlement ? (
                          <div className="edit-entitlement">
                            <input
                              type="number"
                              className="form-input small-input"
                              value={tempEntitlement}
                              onChange={(e) => setTempEntitlement(e.target.value)}
                              min="0"
                            />
                            <div className="button-group">
                              <button className="button button-small" onClick={handleEntitlementEdit}>
                                Save
                              </button>
                              <button
                                className="button button-outline button-small"
                                onClick={() => {
                                  setIsEditingEntitlement(false);
                                  setTempEntitlement(leaveDetails.entitlement);
                                }}
                              >
                                Cancel
                              </button>
                            </div>
                          </div>
                        ) : (
                          <div className="view-entitlement">
                            <p className="stat-value">{leaveDetails.entitlement}</p>
                            {canEditEntitlement(currentUser, user) && (
                              <button
                                className="button button-outline button-small"
                                onClick={() => {
                                  setIsEditingEntitlement(true);
                                  setTempEntitlement(leaveDetails.entitlement);
                                }}
                              >
                                Edit
                              </button>
                            )}
                          </div>
                        )}
                      </div>
                      <div className="stat-card">
                        <h3 className="stat-title">Taken</h3>
                        <p className="stat-value">{leaveDetails.taken}</p>
                      </div>
                      <div className="stat-card">
                        <h3 className="stat-title">Balance</h3>
                        <p className="stat-value">{leaveDetails.balance}</p>
                      </div>
                    </>
                  )}
                </div>
          
                <select
                  className="leave-type-select"
                  value={leaveType}
                  onChange={(e) => setLeaveType(e.target.value)}
                >
                  <option value="regular">Regular Leave</option>
                  <option value="medical">Medical Leave</option>
                </select>
          
                <table className="staff-table">
                  <thead>
                    <tr>
                      <th>Index</th>
                      <th>Start Date</th>
                      <th>No. of Days</th>
                      <th>Reason</th>
                      <th>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {(leaveType === 'regular' ? leaveDetails.leaves : leaveDetails.medicalLeaves).map(
                      (leave, index) => (
                        <tr key={leave.id}>
                          <td>{index + 1}</td>
                          <td>
                            {new Date(leave.leaveDate).toLocaleDateString('en-GB', {
                              day: '2-digit',
                              month: '2-digit',
                              year: 'numeric'
                            })}
                          </td>
                          <td>{leave.numberOfDays}</td>
                          <td>{leave.reason}</td>
                          <td>
                            <span className={`status-badge status-${leave.status}`}>
                              {leave.status}
                            </span>
                          </td>
                        </tr>
                      )
                    )}
                  </tbody>
                </table>
          
                {renderNavigationButtons()}
              </div>
            );
          
        case 3:
          return (
            <div>
              {renderTrainingPage()}
              {renderNavigationButtons()}
            </div>
          );
        default:
          return null;
      }
    };
  
    if (!isOpen) return null;
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-6 max-w-4xl w-full max-h-[90vh] overflow-y-auto">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">
              {mode === 'view' ? 'User Details' : 'Edit User'}
            </h2>
            <button
              onClick={onClose}
              className="p-1 hover:bg-gray-100 rounded-full"
            >
              <X size={24} />
            </button>
          </div>
  
          {error && (
            <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
              {error}
            </div>
          )}
  
          {renderStepIndicator()}
          {renderContent()}
        </div>
      </div>
    );
  };

  const StaffPage = () => {
    const currentUser = JSON.parse(localStorage.getItem('user'));
    const [users, setUsers] = useState([]);
    if (currentUser.role !== 'super-admin') {
      return (
        <div className="flex min-h-screen bg-gray-50">
          <Sidebar />
          <main className="flex-1 p-4 lg:p-8 ml-64 flex items-center justify-center">
            <div className="bg-white shadow-lg rounded-lg p-8 text-center max-w-md">
              <div className="mb-6">
                <svg 
                  xmlns="http://www.w3.org/2000/svg" 
                  className="h-20 w-20 mx-auto text-red-500 mb-4" 
                  fill="none" 
                  viewBox="0 0 24 24" 
                  stroke="currentColor"
                >
                  <path 
                    strokeLinecap="round" 
                    strokeLinejoin="round" 
                    strokeWidth={2} 
                    d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" 
                  />
                </svg>
              </div>
              <h2 className="text-2xl font-bold text-gray-800 mb-4">Access Restricted</h2>
              <p className="text-gray-600 mb-6">
                You do not have permission to access the Staff Management page. 
                This feature is restricted to Super Admin users only.
              </p>
              <div className="text-sm text-gray-500">
                Please contact your system administrator if you believe this is an error.
              </div>
            </div>
          </main>
        </div>
      );
    }
    const [filteredUsers, setFilteredUsers] = useState([]);
    const [selectedUser, setSelectedUser] = useState(null);
    const [dialogMode, setDialogMode] = useState('view');
    const [isDialogOpen, setIsDialogOpen] = useState(false);
    const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
    const [isDepartmentDialogOpen, setIsDepartmentDialogOpen] = useState(false);
    const [error, setError] = useState('');
    const [searchQuery, setSearchQuery] = useState('');
    const [departmentFilter, setDepartmentFilter] = useState('');
    const [roleFilter, setRoleFilter] = useState('');
    const [statusFilter, setStatusFilter] = useState('');
    const [showFilters, setShowFilters] = useState(false);
    
    // Sorting state
    const [sortConfig, setSortConfig] = useState({
      key: 'fullName', // Default sort by name
      direction: 'asc'
    });
  
    // Unique values for filters
    const [departments, setDepartments] = useState([]);
    const [roles, setRoles] = useState([]);
  
    useEffect(() => {
      fetchUsersData();
    }, []);
  
    useEffect(() => {
      if (users.length > 0) {
        // Extract unique departments and roles
        setDepartments([...new Set(users.map(user => user.department))]);
        setRoles([...new Set(users.map(user => user.role))]);
        
        // Apply filters and sorting
        filterAndSortUsers();
      }
    }, [users, searchQuery, departmentFilter, roleFilter, statusFilter, sortConfig]);
  
    const filterAndSortUsers = () => {
      let filtered = [...users];
  
      // Apply search query
      if (searchQuery) {
        const query = searchQuery.toLowerCase();
        filtered = filtered.filter(user =>
          user.fullName.toLowerCase().includes(query) ||
          user.email.toLowerCase().includes(query) ||
          user.nric.toLowerCase().includes(query) ||
          (user.tin && user.tin.toLowerCase().includes(query)) ||
          (user.epf && user.epf.toLowerCase().includes(query))
        );
      }
  
      // Apply department filter
      if (departmentFilter) {
        filtered = filtered.filter(user => user.department === departmentFilter);
      }
  
      // Apply role filter
      if (roleFilter) {
        filtered = filtered.filter(user => user.role === roleFilter);
      }
  
      // Apply status filter
      if (statusFilter) {
        filtered = filtered.filter(user => user.activeStatus === statusFilter);
      }
  
      // Sort the filtered users
      const sortedUsers = [...filtered].sort((a, b) => {
        if (sortConfig.key === 'dateJoined') {
          return sortConfig.direction === 'asc'
            ? new Date(a.dateJoined) - new Date(b.dateJoined)
            : new Date(b.dateJoined) - new Date(a.dateJoined);
        }
        
        if (a[sortConfig.key] === undefined || b[sortConfig.key] === undefined) {
          return 0;
        }
  
        const comparison = a[sortConfig.key].localeCompare(b[sortConfig.key]);
        return sortConfig.direction === 'asc' ? comparison : -comparison;
      });
  
      setFilteredUsers(sortedUsers);
    };
  
    const handleSort = (key) => {
      let direction = 'asc';
      if (sortConfig.key === key && sortConfig.direction === 'asc') {
        direction = 'desc';
      }
      setSortConfig({ key, direction });
    };
  
    const renderSortIcon = (key) => {
      if (sortConfig.key !== key) return null;
      return sortConfig.direction === 'asc' 
        ? <ArrowUp size={16} className="inline ml-1" /> 
        : <ArrowDown size={16} className="inline ml-1" />;
    };

    const resetFilters = () => {
      setSearchQuery('');
      setDepartmentFilter('');
      setRoleFilter('');
      setStatusFilter('');
    };
  
  
    const fetchUsersData = async () => {
      try {
        const data = await fetchUsers();
        setUsers(data);
      } catch (error) {
        console.error('Error fetching users:', error);
      }
    };

    const handleToggleUserStatus = async (userId, currentStatus) => {
      try {
        const newStatus = currentStatus === 'active' ? 'inactive' : 'active';
        await toggleUserStatus(userId, newStatus);
        fetchUsersData();
      } catch (error) {
        console.error('Error updating user status:', error);
        alert('Failed to update user status');
      }
    };
    
  

    const canDisable = (currentUser, targetUser) => {
  if (currentUser.role === 'super-admin') return true;
  if (currentUser.role === 'department-admin') {
    return currentUser.department_name === targetUser.department && 
           ROLE_HIERARCHY[currentUser.role] > ROLE_HIERARCHY[targetUser.role];
  }
  return false;
};
  
  
const handleRemove = async (userId) => {
  if (window.confirm('Are you sure you want to remove this user?')) {
    try {
      await deleteUser(userId);
      fetchUsersData();
    } catch (error) {
      console.error('Error removing user:', error);
      // Check if it's a 500 error and show custom message
      if (error.response?.status === 500) {
        window.alert(
          "Failed to delete staff due to staff record exist in other fields. Try inactive the staff status if he/she has resigned."
        );
      }
    }
  }
};

    const maskSensitiveInfo = (value) => {
        if (!value) return '';
        return value.slice(0, -4).replace(/./g, '*') + value.slice(-4);
      };
      
  
      return (
        <div className="space-y-6 animate-fade-in">
          {/* Content */}
          {/* Header Section - improved mobile layout */}
          <div className="mb-6 sm:mb-8">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
              <div>
                <h1 className="text-2xl sm:text-3xl font-bold text-gray-900 mb-2">Staff Management</h1>
                <p className="text-sm sm:text-base text-gray-600">Manage your organization's staff members and departments</p>
              </div>
              {currentUser.role === 'super-admin' && (
                <div className="flex flex-col sm:flex-row gap-3 w-full sm:w-auto">
                  <button 
                    className="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white px-4 sm:px-6 py-2.5 rounded-lg font-medium shadow-sm transition-all flex items-center justify-center"
                    onClick={() => setIsAddDialogOpen(true)}
                  >
                    <span className="mr-2">+</span>
                    Add Staff
                  </button>
                  <button 
                    className="w-full sm:w-auto bg-white hover:bg-gray-50 text-gray-700 px-4 sm:px-6 py-2.5 rounded-lg font-medium shadow-sm border border-gray-200 transition-all"
                    onClick={() => setIsDepartmentDialogOpen(true)}
                  >
                    Manage Departments
                  </button>
                </div>
              )}
            </div>
          </div>
    
            {/* Search and Filters Card */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4 sm:p-6 mb-6">
        <div className="flex flex-col sm:flex-row gap-4 mb-6">
          <div className="relative flex-1">
            <input
              type="text"
              placeholder="Search by name, email, NRIC..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-12 pr-4 py-2.5 sm:py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all text-sm sm:text-base"
            />
          </div>
          <button 
            className={`flex items-center justify-center px-4 sm:px-6 py-2.5 sm:py-3 rounded-lg font-medium transition-all ${
              showFilters 
                ? 'bg-blue-50 text-blue-600 border border-blue-200' 
                : 'bg-gray-50 text-gray-700 border border-gray-200'
            }`}
            onClick={() => setShowFilters(!showFilters)}
          >
            <Filter size={20} className="mr-2" />
            {showFilters ? 'Hide Filters' : 'Show Filters'}
          </button>
        </div>

        {showFilters && (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mb-4 animate-fadeIn">
                  <div className="space-y-2">
                    <label className="text-sm font-medium text-gray-700">Department</label>
                    <select
                      value={departmentFilter}
                      onChange={(e) => setDepartmentFilter(e.target.value)}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="">All Departments</option>
                      {departments.map(dept => (
                        <option key={dept.id} value={dept.name}>{dept.name}</option>
                      ))}
                    </select>
                  </div>
    
                  <div className="space-y-2">
                    <label className="text-sm font-medium text-gray-700">Role</label>
                    <select
                      value={roleFilter}
                      onChange={(e) => setRoleFilter(e.target.value)}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="">All Roles</option>
                      {roles.map(role => (
                        <option key={role.id} value={role.name}>{role.name}</option>
                      ))}
                    </select>
                  </div>
    
                  <div className="space-y-2">
                    <label className="text-sm font-medium text-gray-700">Status</label>
                    <select
                      value={statusFilter}
                      onChange={(e) => setStatusFilter(e.target.value)}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="">All Statuses</option>
                      <option value="active">Active</option>
                      <option value="inactive">Inactive</option>
                    </select>
                  </div>
                </div>
              )}
    
    <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2 text-sm text-gray-600">
          <span>Showing {filteredUsers.length} of {users.length} staff members</span>
          {(searchQuery || departmentFilter || roleFilter || statusFilter) && (
            <button
              onClick={resetFilters}
              className="text-blue-600 hover:text-blue-700 font-medium"
            >
              Reset Filters
            </button>
          )}
        </div>
      </div>
    
            {/* Staff Table */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full min-w-[800px]">{/* Added min-width to prevent squishing */}<thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th 
                  className="p-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-200"
                  onClick={() => handleSort('dateJoined')}
                >
                  Date Joined
                  {renderSortIcon('dateJoined')}
                </th>
                <th 
                  className="p-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-200"
                  onClick={() => handleSort('fullName')}
                >
                  Name
                  {renderSortIcon('fullName')}
                </th>
                <th className="p-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">NRIC</th>
                <th 
                  className="p-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-200"
                  onClick={() => handleSort('department')}
                >
                  Department
                  {renderSortIcon('department')}
                </th>
                <th 
                  className="p-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-200"
                  onClick={() => handleSort('role')}
                >
                  Role
                  {renderSortIcon('role')}
                </th>
                <th 
                  className="p-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-200"
                  onClick={() => handleSort('activeStatus')}
                >
                  Status
                  {renderSortIcon('activeStatus')}
                </th>
                <th 
                  className="p-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-200 text-center"
                  onClick={() => handleSort('contactNumber')}
                >
                  Contact No
                  {renderSortIcon('contactNumber')}
                </th>
                {currentUser.role !== 'user' && (
                  <th className="p-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider text-center">Actions</th>
                )}
              </tr>
            </thead><tbody className="divide-y divide-gray-200">
                {filteredUsers.map((user) => (
                  <tr key={user.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {new Date(user.dateJoined).toLocaleDateString('en-GB')}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="h-10 w-10 flex-shrink-0">
                          <div className="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center">
                            <span className="text-gray-600 font-medium">
                              {user.fullName.charAt(0)}
                            </span>
                          </div>
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">{user.fullName}</div>
                          <div className="text-sm text-gray-500">{user.email}</div>
                        </div>
                      </div>
                    </td>
                    {/* ... other cells ... */}
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {maskSensitiveInfo(user.nric)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {user.department}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {user.role}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-3 py-1 rounded-full text-xs font-medium border-2 ${
                        user.activeStatus === 'active'
                          ? 'bg-green-100 text-green-800 border-green-400 dark:bg-green-900/40 dark:text-green-100 dark:border-green-500'
                          : 'bg-red-100 text-red-800 border-red-400 dark:bg-red-900/40 dark:text-red-100 dark:border-red-500'
                      }`}>
                        {user.activeStatus}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 text-center">
                      {user.contactNumber ? user.contactNumber : '-'}
                    </td>
                    {currentUser.role !== 'user' && (
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 ">
                        <div className="flex items-center gap-3">
                          <button
                            className="text-gray-600 hover:text-blue-600 transition-colors"
                            onClick={() => {
                              if (canEdit(currentUser, user)) {
                                setSelectedUser(user);
                                setDialogMode('edit');
                                setIsDialogOpen(true);
                              }
                            }}
                          >
                            <Edit size={18} />
                          </button>
                          <button
                            className="text-gray-600 hover:text-red-600 transition-colors"
                            onClick={() => {
                              if (canDelete(currentUser, user)) {
                                handleRemove(user.id);
                              }
                            }}
                          >
                            <Trash size={18} />
                          </button>
                          <button
                            className="text-gray-600 hover:text-gray-900 transition-colors"
                            onClick={() => {
                              if(canDisable(currentUser, user)) {
                                handleToggleUserStatus(user.id, user.activeStatus)
                              }
                            }}
                          >
                            {user.activeStatus === 'active' ? (
                              <FaToggleOff size={20} />
                            ) : (
                              <FaToggleOn size={20} />
                            )}
                          </button>
                        </div>
                      </td>
                    )}
                  </tr>
                ))}
              </tbody></table>
          </div>
        </div>

        {/* Keep existing dialogs */}
        <AddStaffDialog
          isOpen={isAddDialogOpen}
          onClose={() => setIsAddDialogOpen(false)}
          onSuccess={fetchUsersData}
        />

        <StaffDialog
          isOpen={isDialogOpen}
          onClose={() => {
            setIsDialogOpen(false);
            setSelectedUser(null);
            setDialogMode('view');
          }}
          user={selectedUser}
          mode={dialogMode}
        />

        <DepartmentDialog
          isOpen={isDepartmentDialogOpen}
          onClose={() => setIsDepartmentDialogOpen(false)}
        />
    </div>
  );
};

export default StaffPage;