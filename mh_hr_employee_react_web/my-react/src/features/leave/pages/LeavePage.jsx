import React, { useState, useEffect, useCallback } from 'react';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Input } from '@/components/ui/input';
import { Card, CardContent } from '@/components/ui/card';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { Search, Calendar, Users, X, CheckSquare2Icon } from 'lucide-react';

import LeaveCalendar from '../components/LeaveCalendar';
import AttendanceTab from '../../staff/components/AttendanceTab';
import { fetchUsers as getUsers } from '../../staff/api/staffApi';
import { getUserLeaveDetails } from '../api/leaveApi';
import "./LeavePage.css";
import apiClient from '../../../core/api/client';
import {Plus,Trash2 } from 'lucide-react';
import { DayPicker } from 'react-day-picker';
import 'react-day-picker/dist/style.css';
import { Button } from '@/components/ui/button';
import LeaveReportButton from '../components/LeaveReportButton';


const AddLeaveDialog = ({ isOpen, onClose, onSave, userId }) => {
  const [selectedDays, setSelectedDays] = useState(new Map());
  const [reason, setReason] = useState('');
  const [takenDates, setTakenDates] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [lastClickTime, setLastClickTime] = useState(0);
  const [lastClickedDay, setLastClickedDay] = useState(null);
  const [leaveType, setLeaveType] = useState('annual'); // 'annual' or 'medical'

  useEffect(() => {
    if (isOpen && userId) {
      fetchTakenDates();
    }
  }, [isOpen, userId]);

  const fetchTakenDates = async () => {
    try {
      // Fetch user leave details and holidays
      const [userLeaveResponse, holidaysResponse] = await Promise.all([
        apiClient.get(`/staff/${userId}/leave-details`),
        apiClient.get('/Holiday/all')
      ]);

      const leaveData = userLeaveResponse.data;
      const holidaysData = holidaysResponse.data;

      const dates = [
        // Process annual leaves (backend returns: leaves array with leaveDate, endDate, numberOfDays)
        ...(leaveData.leaves || []).flatMap(leave => {
          const dates = [];
          let currentDate = new Date(leave.leaveDate);
          const endDate = new Date(leave.endDate);

          while (currentDate <= endDate) {
            dates.push({
              date: new Date(currentDate),
              isHalfDay: leave.numberOfDays < 1,
              type: 'annual'
            });
            currentDate.setDate(currentDate.getDate() + 1);
          }
          return dates;
        }),
        // Process medical leaves
        ...(leaveData.medicalLeaves || []).flatMap(leave => {
          const dates = [];
          let currentDate = new Date(leave.leaveDate);
          const endDate = new Date(leave.endDate);

          while (currentDate <= endDate) {
            dates.push({
              date: new Date(currentDate),
              isHalfDay: false,
              type: 'medical'
            });
            currentDate.setDate(currentDate.getDate() + 1);
          }
          return dates;
        }),
        // Process holidays
        ...(holidaysData || []).map(holiday => ({
          date: new Date(holiday.holidayDate),
          isHalfDay: false,
          type: 'holiday'
        }))
      ];
      
      setTakenDates(dates);
      setIsLoading(false);
    } catch (error) {
      console.error('Error fetching taken dates:', error);
      setIsLoading(false);
    }
  };

  const handleDayClick = useCallback((day) => {
    const currentTime = new Date().getTime();
    const dateStr = day.toISOString();
    
    // Check if date is already taken or is a holiday
    const isTaken = takenDates.some(td => 
      td.date.toISOString().split('T')[0] === dateStr.split('T')[0] &&
      (td.type === 'annual' || td.type === 'medical' || td.type === 'holiday')
    );
    
    if (isTaken) {
      alert('This date is not available (already taken or a holiday)');
      return;
    }

    // Handle double click only for annual leave
    const isDoubleClick = 
      lastClickedDay && 
      lastClickedDay.toISOString() === dateStr && 
      currentTime - lastClickTime < 300;

    setSelectedDays(prev => {
      const newMap = new Map(prev);
      
      if (leaveType === 'annual' && isDoubleClick) {
        const currentValue = newMap.get(dateStr);
        if (currentValue === 1) {
          newMap.set(dateStr, 0.5);
        } else if (currentValue === 0.5) {
          newMap.delete(dateStr);
        }
      } else {
        if (newMap.has(dateStr)) {
          newMap.delete(dateStr);
        } else {
          newMap.set(dateStr, 1); // Always full day for medical leave
        }
      }
      
      return newMap;
    });

    setLastClickTime(currentTime);
    setLastClickedDay(day);
  }, [lastClickTime, lastClickedDay, takenDates, leaveType]);

  const handleSave = async () => {
    if (selectedDays.size === 0) return;

    const currentUser = JSON.parse(localStorage.getItem('user'));
    
    try {
      // Create separate records for each selected day
      const leaveRecords = Array.from(selectedDays.entries()).map(([dateStr, days]) => {
        const date = new Date(dateStr);
        date.setHours(12, 0, 0, 0);
        
        return {
          userId,
          startDate: date.toISOString(),
          endDate: date.toISOString(), // Same start and end date for each record
          reason: reason || `Added by ${currentUser.fullName}`,
          noOfDays: days, // Use the specific day value (1 or 0.5)
          leaveType,
          currentUserRole: currentUser.role 
        };
      });
      
      // Send each record separately
      for (const payload of leaveRecords) {
        await apiClient.post('/Leaves', payload);
      }
      
      onClose();
      window.location.reload();
    } catch (error) {
      console.error('Error saving leave:', error);
    }
  };

  const modifiersStyles = {
    halfDay: { 
      backgroundColor: '#93c5fd',
      color: 'black'
    },
    selected: {
      backgroundColor: '#3b82f6',
      color: 'white'
    }
  };

  const modifiers = {
    halfDay: Array.from(selectedDays.entries())
      .filter(([_, days]) => days === 0.5)
      .map(([date]) => new Date(date)),
    selected: Array.from(selectedDays.entries())
      .filter(([_, days]) => days === 1)
      .map(([date]) => new Date(date))
  };

  const handleLeaveTypeChange = (e) => {
    setLeaveType(e.target.value);
    setSelectedDays(new Map()); // Clear selected days when switching leave type
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center">
      <div
        className="bg-white rounded-lg shadow-xl w-full max-w-3xl sm:w-4/5 lg:w-3/4 max-h-screen overflow-y-auto"
      >
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b">
          <h2 className="text-xl font-semibold">Add Leave Days</h2>
          <button
            onClick={onClose}
            className="p-1 hover:bg-background rounded-full transition-colors"
          >
            <X className="h-5 w-5" />
          </button>
        </div>
  
        {/* Content */}
        <div className="p-4">
          {isLoading ? (
            <div className="text-center py-4">Loading...</div>
          ) : (
            <>
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Leave Type
                </label>
                <select
                  value={leaveType}
                  onChange={handleLeaveTypeChange}
                  className="w-full p-2 border rounded-md bg-white"
                >
                  <option value="annual">Annual Leave</option>
                  <option value="medical">Medical Leave</option>
                </select>
              </div>
  
              <div className="flex justify-center mb-4">
                <div className="border rounded-lg p-3">
                  <div className="text-sm text-gray-500 mb-2 space-y-1">
                    <p>• Click once to select/deselect a day</p>
                    {leaveType === 'annual' && (
                      <p>• Double click on a selected day to toggle half day</p>
                    )}
                    <p className="flex items-center gap-2">
                      <span className="inline-block w-3 h-3 bg-[#3b82f6] rounded-sm"></span>
                      Full day
                    </p>
                    {leaveType === 'annual' && (
                      <p className="flex items-center gap-2">
                        <span className="inline-block w-3 h-3 bg-[#93c5fd] rounded-sm"></span>
                        Half day
                      </p>
                    )}
                  </div>
                  <DayPicker
                    mode="multiple"
                    selected={Array.from(selectedDays.keys()).map((d) => new Date(d))}
                    onDayClick={handleDayClick}
                    disabled={takenDates.map((td) => td.date)}
                    modifiers={modifiers}
                    modifiersStyles={modifiersStyles}
                  />
                </div>
              </div>
  
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Selected Days:
                </label>
                <div className="text-sm text-gray-600 max-h-24 overflow-y-auto">
                  {Array.from(selectedDays.entries())
                    .sort(([a], [b]) => new Date(a) - new Date(b))
                    .map(([date, days]) => (
                      <div key={date} className="flex items-center gap-2">
                        <span>
                        {new Date(date).toLocaleDateString('en-GB', {
                          day: '2-digit',
                          month: '2-digit',
                          year: 'numeric'
                        })}
                      </span>
                        <span
                          className={`px-2 py-0.5 rounded text-xs ${
                            days === 0.5
                              ? 'bg-blue-100 text-blue-800'
                              : 'bg-blue-200 text-blue-900'
                          }`}
                        >
                          {days === 0.5 ? 'Half' : 'Full'} day
                        </span>
                      </div>
                    ))}
                </div>
                <div className="mt-2 text-sm font-medium text-gray-900">
                  Total days: {Array.from(selectedDays.values()).reduce((sum, days) => sum + days, 0)}
                </div>
              </div>
  
              <div className="mb-4">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Reason
                </label>
                <input
                  type="text"
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  className="w-full p-2 border rounded-md"
                  placeholder="Enter reason for leave (optional)"
                />
              </div>
            </>
          )}
        </div>
  
        {/* Footer */}
        <div className="p-4 border-t flex justify-end gap-3">
          <button
            onClick={onClose}
            className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700"
            disabled={selectedDays.size === 0}
          >
            Save
          </button>
        </div>
      </div>
    </div>
  );
  
  
};





const CustomDialog = ({ isOpen, onClose, children, title }) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center">
      <div className="bg-white rounded-lg shadow-xl w-full max-w-3xl max-h-[90vh] overflow-auto">
        <div className="flex items-center justify-between p-4 border-b">
          <h2 className="text-xl font-semibold">{title}</h2>
          <button 
            onClick={onClose}
            className="p-1 hover:bg-background rounded-full transition-colors"
          >
            <X className="h-5 w-5" />
          </button>
        </div>
        <div className="p-4">
          {children}
        </div>
      </div>
    </div>
  );
};

const LeaveDetails = ({ userData, monthlyData, userId }) => {
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
  const [leaveType, setLeaveType] = useState('annual');
  const [medicalData, setMedicalData] = useState(userData?.medicalLeaves || []);

  const transformedMonthlyData = (monthlyData || []).map(item => ({
    ...item,
    month: item.month?.substring(0, 3) || ''
  }));


  const handleDeleteLeave = async (leaveId, type = 'annual') => {
    const currentUser = JSON.parse(localStorage.getItem('user'));
  
    // Check if the current user is a super-admin
    if (currentUser.role !== 'super-admin') {
      window.alert('Only super admin can delete leave records.');
      return;
    }
  
    if (!leaveId) {
      console.error('Leave ID is undefined');
      return;
    }
  
    const confirmDelete = window.confirm('Are you sure you want to delete this leave record? This action cannot be undone.');
    
    if (confirmDelete) {
      try {
        const endpoint = type === 'annual' 
          ? `/leave/${leaveId}`
          : `/leave/medical/${leaveId}`;
  
        await apiClient.delete(endpoint);
        window.location.reload();
      } catch (error) {
        console.error('Error deleting leave:', error);
        window.alert('Failed to delete leave record');
      }
    }
  };

  const handleSaveLeave = async (leaveData) => {
    try {
      await apiClient.post('/leave/add', leaveData);
      window.location.reload();
    } catch (error) {
      console.error('Error saving leave:', error);
      window.alert('Failed to save leave record');
    }
  };
  // Update medical data when userData changes
  React.useEffect(() => {
    if (userData?.medicalLeaves) {
      setMedicalData(userData.medicalLeaves);
    }
  }, [userData]);

  return (
    <Tabs defaultValue="details" className="w-full">
      <TabsList className="grid w-full grid-cols-2 mb-6">
        <TabsTrigger value="details" className="text-sm">Leave Details</TabsTrigger>
        <TabsTrigger value="graph" className="text-sm">Monthly Overview</TabsTrigger>
      </TabsList>

      <TabsContent value="details">
      <div className="grid grid-cols-3 gap-4 mb-6">
  {leaveType !== 'medical' && (
    <>
      <Card>
        <CardContent className="pt-6">
          <div className="text-center">
            <p className="text-sm text-gray-500">Entitlement</p>
            <p className="text-2xl font-semibold mt-1">{userData.entitlement}</p>
          </div>
        </CardContent>
      </Card>
      <Card>
        <CardContent className="pt-6">
          <div className="text-center relative">
            <p className="text-sm text-gray-500">Taken</p>
            <div className="flex items-center justify-center gap-2">
              <p className="text-2xl font-semibold mt-1">{userData.taken}</p>
              <button
                onClick={() => setIsAddDialogOpen(true)}
                className="absolute right-0 top-0 p-1 hover:bg-background rounded-full"
                title="Add Leave"
              >
                <Plus className="h-5 w-5" />
              </button>
            </div>
          </div>
        </CardContent>
      </Card>
      <Card>
        <CardContent className="pt-6">
          <div className="text-center">
            <p className="text-sm text-gray-500">Balance</p>
            <p className="text-2xl font-semibold mt-1">{userData.balance}</p>
          </div>
        </CardContent>
      </Card>
    </>
  )}
</div>


        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Leave Type
          </label>
          <select
            value={leaveType}
            onChange={(e) => setLeaveType(e.target.value)}
            className="w-full p-2 border rounded-md bg-white"
          >
            <option value="" disabled>
              Select leave type
            </option>
            <option value="annual">Annual Leave</option>
            <option value="medical">Medical Leave</option>
          </select>
        </div>


        <div className="rounded-lg border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-14">#</TableHead>
                <TableHead>Start Date</TableHead>
                <TableHead>Days</TableHead>
                <TableHead>Reason</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="w-14">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {leaveType === 'annual' ? (
                (userData?.leaveDetails || []).map((detail, index) => (
                  <TableRow key={detail.id}>
                    <TableCell className="font-medium">{index + 1}</TableCell>
                    <TableCell>
                      {new Date(detail.fromDate).toLocaleDateString('en-GB', {
                        day: '2-digit',
                        month: '2-digit',
                        year: 'numeric'
                      })}
                    </TableCell>
                    <TableCell>{detail.noOfDays}</TableCell>
                    <TableCell>{detail.reason}</TableCell>
                    <TableCell>
                      <span className={`px-2 py-1 rounded-full text-xs font-medium border-2 ${
                        detail.status === 'approved' ? 'bg-green-100 text-green-800 border-green-400 dark:bg-green-900/40 dark:text-green-100 dark:border-green-500' :
                        detail.status === 'Pending' ? 'bg-yellow-100 text-yellow-800 border-yellow-400 dark:bg-yellow-900/40 dark:text-yellow-100 dark:border-yellow-500' :
                        'bg-red-100 text-red-800 border-red-400 dark:bg-red-900/40 dark:text-red-100 dark:border-red-500'
                      }`}>
                        {detail.status}
                      </span>
                    </TableCell>
                    <TableCell>
                      <button
                        onClick={() => handleDeleteLeave(detail.id)}
                        className="p-2 hover:bg-red-50 rounded-full text-red-600 transition-colors"
                        title="Delete Leave"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                (medicalData || []).map((detail, index) => (
                  <TableRow key={index}>
                    <TableCell className="font-medium">{index + 1}</TableCell>
                    <TableCell>
                      {new Date(detail.startDate).toLocaleDateString('en-GB', {
                        day: '2-digit',
                        month: '2-digit',
                        year: 'numeric'
                      })}
                    </TableCell>
                    <TableCell>{detail.totalDays}</TableCell>
                    <TableCell>{detail.reason}</TableCell>
                    <TableCell>
                      <span className={`px-2 py-1 rounded-full text-xs font-medium border-2 ${
                        detail.status === 'approved' ? 'bg-green-100 text-green-800 border-green-400 dark:bg-green-900/40 dark:text-green-100 dark:border-green-500' :
                        detail.status === 'Pending' ? 'bg-yellow-100 text-yellow-800 border-yellow-400 dark:bg-yellow-900/40 dark:text-yellow-100 dark:border-yellow-500' :
                        'bg-red-100 text-red-800 border-red-400 dark:bg-red-900/40 dark:text-red-100 dark:border-red-500'
                      }`}>
                        {detail.status}
                      </span>
                    </TableCell>
                    <TableCell>
                      <button
                        onClick={() => handleDeleteLeave(detail.mC_RequestId, 'medical')}
                        className="p-2 hover:bg-red-50 rounded-full text-red-600 transition-colors"
                        title="Delete Leave"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </div>

        <AddLeaveDialog
          isOpen={isAddDialogOpen}
          onClose={() => setIsAddDialogOpen(false)}
          onSave={handleSaveLeave}
          userId={userId}
        />
      </TabsContent>

      <TabsContent value="graph">
        <Card>
          <CardContent className="pt-6">
            <div className="h-[400px]">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={transformedMonthlyData}>
                  <CartesianGrid strokeDasharray="3 3" className="opacity-50" />
                  <XAxis dataKey="month" />
                  <YAxis domain={[0, 20]} />
                  <Tooltip />
                  <Bar dataKey="daysTaken" fill="#6366f1" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
      </TabsContent>
    </Tabs>
  );
};


const LeavePage = () => {
  const [users, setUsers] = useState([]);
  const [filteredUsers, setFilteredUsers] = useState([]);
  const [activeTab, setActiveTab] = useState('list');
  const [selectedUser, setSelectedUser] = useState(null);
  const [monthlyData, setMonthlyData] = useState([]);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [filters, setFilters] = useState({
    search: '',
    department: '',
    role: ''
  });
  const currentUser = JSON.parse(localStorage.getItem('user'));

  useEffect(() => {
    fetchUsers();
  }, []);

  useEffect(() => {
    filterUsers();
  }, [users, filters]);

  const fetchUsers = async () => {
    try {
      const data = await getUsers();
      setUsers(data);
      setFilteredUsers(data);
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };

  const filterUsers = () => {
    let filtered = [...users];
    if (filters.search) {
      const searchLower = filters.search.toLowerCase();
      filtered = filtered.filter(user => 
        user.fullName.toLowerCase().includes(searchLower) ||
        user.email.toLowerCase().includes(searchLower)
      );
    }
    if (filters.department) {
      filtered = filtered.filter(user => user.department === filters.department);
    }
    if (filters.role) {
      filtered = filtered.filter(user => user.role === filters.role);
    }
    setFilteredUsers(filtered);
  };

  const handleFilterChange = (key, value) => {
    setFilters(prev => ({
      ...prev,
      [key]: value
    }));
  };

  const getDepartments = () => [...new Set(users.map(user => user.department))];
  const getRoles = () => [...new Set(users.map(user => user.role))];

  const canViewDetails = (userDepartmentId, userId) => {
    if (currentUser.role === 'super-admin') return true;
    if (currentUser.role === 'department-admin' && currentUser.department_id === userDepartmentId) return true;
    if (currentUser.id === userId) return true; // Allow user to view their own details
    return false;
  };

  const handleViewDetails = async (userId) => {
    try {
      const data = await getUserLeaveDetails(userId);
      // Backend returns: { entitlement, taken, balance, leaves, medicalLeaves }
      setSelectedUser({
        entitlement: data.entitlement || 0,
        taken: data.taken || 0,
        balance: data.balance || 0,
        leaveDetails: data.leaves || [],  // Map backend 'leaves' to 'leaveDetails'
        medicalLeaves: data.medicalLeaves || [],  // Add medical leaves
        userId: userId
      });
      // For now, set empty monthlyData - this can be populated if needed
      setMonthlyData([]);
      setIsDialogOpen(true);
    } catch (error) {
      console.error('Error fetching leave details:', error);
    }
  };

  return (
    <div className="flex flex-col lg:flex-row space-y-6 animate-fade-in bg-gray-50">
      
      <div className="flex-1 p-4 sm:p-6 lg:p-8  bg-gray-50">
      <div className="max-w-7xl mx-auto">
        <div className="flex flex-col sm:flex-row items-center justify-between mb-6 sm:mb-8 gap-4">
          <h1 className="text-xl sm:text-2xl font-semibold text-gray-900">Leave Management</h1>
        </div>
        
        <Tabs defaultValue="list" className="space-y-4 sm:space-y-6">
          <TabsList className="flex flex-wrap gap-2 justify-start">
            <TabsTrigger value="list" className="flex items-center gap-2 text-sm sm:text-base">
              <Users className="h-4 w-4" />
              <span className="hidden sm:inline">Employee List</span>
            </TabsTrigger>
            <TabsTrigger value="calendar" className="flex items-center gap-2 text-sm sm:text-base">
              <Calendar className="h-4 w-4" />
              Calendar View
            </TabsTrigger>
            <TabsTrigger value="attendance" className="flex items-center gap-2 text-sm sm:text-base">
              <CheckSquare2Icon className="h-4 w-4" />
              Attendance
            </TabsTrigger>
          </TabsList>

          <TabsContent value="list">
            <Card className="mb-4 sm:mb-6">
              <CardContent className="pt-4 sm:pt-6">
                <div className="flex flex-col sm:flex-row gap-4">
                  <div className="flex-1">
                    <div className="relative">
                      <Search className="absolute left-3 top-2.5 h-4 w-4 text-gray-400" />
                      <Input
                        placeholder="Search by name or email..."
                        value={filters.search}
                        onChange={(e) => handleFilterChange('search', e.target.value)}
                        className="pl-9 w-full"
                      />
                    </div>
                  </div>
                  <div className="flex flex-col sm:flex-row gap-4 w-full sm:w-auto">
                    <select
                      value={filters.department}
                      onChange={(e) => handleFilterChange('department', e.target.value)}
                      className="w-full sm:w-48 p-2 border rounded-md text-sm"
                    >
                      <option value="">All Departments</option>
                      {getDepartments().map(dept => (
                        <option key={dept} value={dept}>{dept}</option>
                      ))}
                    </select>
                    <select
                      value={filters.role}
                      onChange={(e) => handleFilterChange('role', e.target.value)}
                      className="w-full sm:w-48 p-2 border rounded-md text-sm"
                    >
                      <option value="">All Roles</option>
                      {getRoles().map(role => (
                        <option key={role} value={role}>{role}</option>
                      ))}
                    </select>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-4 sm:pt-6">
                <div className="flex flex-col sm:flex-row items-center justify-between mb-6 gap-4">
                  <h2 className="text-xl font-semibold text-gray-900">Leave Management</h2>
                  <LeaveReportButton />
                </div>
                <div className="rounded-lg border shadow-sm overflow-x-auto">
                  <Table>
                    <TableHeader>
                      <TableRow className="bg-gray-50">
                        <TableHead className="font-semibold">Name</TableHead>
                        <TableHead className="font-semibold hidden sm:table-cell">Department</TableHead>
                        <TableHead className="font-semibold hidden md:table-cell">Role</TableHead>
                        <TableHead className="font-semibold hidden lg:table-cell">Email</TableHead>
                        <TableHead className="text-center font-semibold">Leave</TableHead>
                        <TableHead className="text-right font-semibold">Actions</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {filteredUsers?.map((user) => (
                        <TableRow key={user.id} className="hover:bg-gray-50">
                          <TableCell>
                            <div className="flex items-center gap-2">
                              <div className="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-600 flex items-center justify-center">
                                <span className="text-sm font-medium text-blue-700 dark:text-white">
                                  {user.fullName.charAt(0)}
                                </span>
                              </div>
                              <span className="font-medium text-gray-900 dark:text-gray-100">{user.fullName}</span>
                            </div>
                          </TableCell>
                          <TableCell className="hidden sm:table-cell">{user.department}</TableCell>
                          <TableCell className="hidden md:table-cell">
                            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800 dark:bg-slate-700 dark:text-slate-100">
                              {user.role}
                            </span>
                          </TableCell>
                          <TableCell className="hidden lg:table-cell text-gray-600">{user.email}</TableCell>
                          <TableCell className="text-center">
                            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-sm font-medium bg-blue-50 text-blue-700 dark:bg-blue-900/40 dark:text-blue-200">
                              {user.balanceLeave}d
                            </span>
                          </TableCell>
                          <TableCell className="text-right">
                          {canViewDetails(user.departmentId, user.id) ? (
                              <Button
                                onClick={() => handleViewDetails(user.id)}
                                variant="outline"
                                className="text-blue-600 hover:text-blue-700 hover:bg-blue-50 text-sm"
                              >
                                View
                              </Button>
                            ) : (
                              <span className="text-sm text-gray-500">No Access</span>
                            )}
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="calendar">
            <Card>
              <CardContent className="pt-4 sm:pt-6">
                <LeaveCalendar />
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="attendance">
            <Card>
              <CardContent className="pt-4 sm:pt-6">
                <AttendanceTab />
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>

        <CustomDialog
          isOpen={isDialogOpen}
          onClose={() => setIsDialogOpen(false)}
          title="Leave Details"
        >
          {selectedUser && (
            <LeaveDetails 
              userData={selectedUser}
              monthlyData={monthlyData}
              userId={selectedUser.userId}
            />
          )}
        </CustomDialog>
      </div>
    </div>
  </div>
);
};

export default LeavePage;
