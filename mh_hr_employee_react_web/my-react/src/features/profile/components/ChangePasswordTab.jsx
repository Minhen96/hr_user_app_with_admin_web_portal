import React, { useState, useEffect } from 'react';
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from '@/components/ui/table';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { 
  Clock, 
  Check, 
  X, 
  Filter, 
  User, 
  Building2, 
  Calendar,
  Lock 
} from 'lucide-react';
import { fetchPasswordChangeRequests, updatePasswordStatus } from "../api/profileApi";

const StatusBadge = ({ status }) => {
  const statusConfig = {
    pending: { 
      icon: <Clock className="w-4 h-4 mr-2" />, 
      color: 'bg-yellow-100 text-yellow-800 border border-yellow-200' 
    },
    approved: { 
      icon: <Check className="w-4 h-4 mr-2" />, 
      color: 'bg-green-100 text-green-800 border border-green-200' 
    },
    rejected: { 
      icon: <X className="w-4 h-4 mr-2" />, 
      color: 'bg-red-100 text-red-800 border border-red-200' 
    }
  };

  const { icon, color } = statusConfig[status.toLowerCase()] || {};

  return (
    <Badge 
      className={`flex items-center px-3 py-1 rounded-full truncate max-w-[100px] ${color}`}
      title={status} 
    >
      {icon}
      <span className="truncate">{status.charAt(0).toUpperCase() + status.slice(1)}</span>
    </Badge>
  );
};

const ChangePasswordTable = ({ users, onStatusChange }) => {
  const [statusFilter, setStatusFilter] = useState('all');
  const [monthFilter, setMonthFilter] = useState('all');
  const [yearFilter, setYearFilter] = useState(new Date().getFullYear().toString());
  const [userRole, setUserRole] = useState('user');
  const [userDepartment, setUserDepartment] = useState(null);

  // Generate month options (same as LeaveApprovalTab)
  const months = [
    { value: 'all', label: 'All Months' },
    { value: '0', label: 'January' },
    { value: '1', label: 'February' },
    { value: '2', label: 'March' },
    { value: '3', label: 'April' },
    { value: '4', label: 'May' },
    { value: '5', label: 'June' },
    { value: '6', label: 'July' },
    { value: '7', label: 'August' },
    { value: '8', label: 'September' },
    { value: '9', label: 'October' },
    { value: '10', label: 'November' },
    { value: '11', label: 'December' }
  ];

  // Generate year options (current year and 5 years back)
  const currentYear = new Date().getFullYear();
  const years = ['all', ...Array.from({ length: 6 }, (_, i) => (currentYear - i).toString())];

  useEffect(() => {
    const user = JSON.parse(localStorage.getItem('user'));
    if (user) {
      setUserRole(user.role || 'user');
      setUserDepartment(user.department_name);
    }
  }, []);

  const formatDate = (dateString) => {
    return dateString 
      ? new Date(dateString).toLocaleDateString('en-US', {
          year: 'numeric',
          month: 'short',
          day: 'numeric'
        }) 
      : 'Not Changed';
  };

  const filteredUsers = users.filter(user => {
    // Status filter
    const matchesStatusFilter = statusFilter === 'all' 
      ? true 
      : user.status.toLowerCase() === statusFilter.toLowerCase();

    // Date filter (month and year)
    const changeDate = user.changePasswordDate ? new Date(user.changePasswordDate) : null;
    const changeMonth = changeDate ? changeDate.getMonth().toString() : null;
    const changeYear = changeDate ? changeDate.getFullYear().toString() : null;
    const monthMatches = monthFilter === 'all' || (changeDate && changeMonth === monthFilter);
    const yearMatches = yearFilter === 'all' || (changeDate && changeYear === yearFilter);

    // Role-based filter
    switch(userRole) {
      case 'super-admin':
        return matchesStatusFilter && monthMatches && yearMatches;
      case 'department-admin':
        return matchesStatusFilter && monthMatches && yearMatches && user.department === userDepartment;
      case 'user':
        return matchesStatusFilter && 
               monthMatches && 
               yearMatches && 
               user.fullName === JSON.parse(localStorage.getItem('user')).full_name;
      default:
        return false;
    }
  });

  return (
    <div className="space-y-6">
      <div className="bg-gray-50 p-4 rounded-lg border border-gray-200">
        <div className="flex items-center space-x-3 mb-3">
          <Filter className="w-5 h-5 text-gray-600" />
          <span className="text-sm font-medium text-gray-700">Filter Password Change Records:</span>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {/* Status Filter */}
          <div className="flex flex-col space-y-1">
            <label className="text-xs text-gray-500">Status</label>
            <select 
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="form-select border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="all">All Statuses</option>
              <option value="pending">Pending</option>
              <option value="approved">Approved</option>
              <option value="rejected">Rejected</option>
            </select>
          </div>
          
          {/* Month Filter */}
          <div className="flex flex-col space-y-1">
            <label className="text-xs text-gray-500">Month</label>
            <select 
              value={monthFilter}
              onChange={(e) => setMonthFilter(e.target.value)}
              className="form-select border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {months.map(month => (
                <option key={month.value} value={month.value}>
                  {month.label}
                </option>
              ))}
            </select>
          </div>
          
          {/* Year Filter */}
          <div className="flex flex-col space-y-1">
            <label className="text-xs text-gray-500">Year</label>
            <select 
              value={yearFilter}
              onChange={(e) => setYearFilter(e.target.value)}
              className="form-select border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {years.map(year => (
                <option key={year} value={year}>
                  {year === 'all' ? 'All Years' : year}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      <div className="overflow-x-auto shadow-sm rounded-lg border">
        <Table>
          <TableHeader className="bg-gray-100">
            <TableRow>
              <TableHead className="flex items-center">
                <User className="w-4 h-4 mr-2" /> ID
              </TableHead>
              <TableHead>
                <div className="flex items-center">
                  <User className="w-4 h-4 mr-2" /> Name
                </div>
              </TableHead>
              <TableHead>
                <div className="flex items-center">
                  <Building2 className="w-4 h-4 mr-2" /> Department
                </div>
              </TableHead>
              <TableHead>
                <div className="flex items-center">
                  <Calendar className="w-4 h-4 mr-2" /> Password Change Date
                </div>
              </TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredUsers.map((user) => {
              const isActionDisabled = 
                userRole === 'department-admin' && user.department !== userDepartment ||
                userRole === 'user' || 
                user.status.toLowerCase() !== 'pending';

              return (
                <TableRow key={user.id} className="hover:bg-gray-50 transition-colors">
                  <TableCell className="font-medium">{user.id}</TableCell>
                  <TableCell>{user.fullName}</TableCell>
                  <TableCell>{user.department}</TableCell>
                  <TableCell>{formatDate(user.changePasswordDate)}</TableCell>
                  <TableCell>
                    <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm ${
                      user.status === 'approved' ? 'bg-green-100 text-green-800 border border-green-200' :
                      user.status === 'rejected' ? 'bg-red-100 text-red-800 border border-red-200' :
                      'bg-yellow-100 text-yellow-800 border border-yellow-200'
                    }`}>
                      {user.status.charAt(0).toUpperCase() + user.status.slice(1)}
                    </span>
                  </TableCell>
                  <TableCell>
                    <select 
                      disabled={isActionDisabled}
                      onChange={(e) => onStatusChange(user.id, e.target.value)}
                      className={`w-[120px] px-2 py-1 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${isActionDisabled ? 'opacity-50 cursor-not-allowed' : ''}`}
                      value=""
                    >
                      <option value="">Select</option>
                      <option value="approved">Approve</option>
                      <option value="rejected">Reject</option>
                    </select>
                  </TableCell>
                </TableRow>
              );
            })}
            {filteredUsers.length === 0 && (
              <TableRow>
                <TableCell colSpan="6" className="text-center py-8 text-gray-500">
                  No password change requests found for the selected filters
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
};
const ChangePasswordTab = () => {
  const [users, setUsers] = useState([]);
  const [userRole, setUserRole] = useState("user");

  useEffect(() => {
    const user = JSON.parse(localStorage.getItem("user"));
    if (user) {
      setUserRole(user.role || "user");
    }
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const data = await fetchPasswordChangeRequests();
      setUsers(data);
    } catch (error) {
      console.error("Error fetching users:", error);
    }
  };

  const handleStatusChange = async (userId, newStatus) => {
    const adminUser = JSON.parse(localStorage.getItem("user"));
    try {
      await updatePasswordStatus(userId, newStatus, adminUser.id);
      fetchUsers();
    } catch (error) {
      console.error("Error updating status:", error);
    }
  };

  const renderContent = () => {
    switch (userRole) {
      case "super-admin":
      case "department-admin":
        return (
          <Card className="w-full">
            <CardHeader>
              <CardTitle className="text-2xl font-bold text-gray-800 flex items-center">
                <Lock className="w-6 h-6 mr-3 text-primary" />
                Change Password Requests
              </CardTitle>
            </CardHeader>
            <CardContent>
              <ChangePasswordTable users={users} onStatusChange={handleStatusChange} />
            </CardContent>
          </Card>
        );
      case "user":
        return (
          <Card className="w-full">
            <CardHeader>
              <CardTitle className="text-2xl font-bold text-gray-800 flex items-center">
                <Lock className="w-6 h-6 mr-3 text-primary" />
                My Password Change Request
              </CardTitle>
            </CardHeader>
            <CardContent>
              <ChangePasswordTable users={users} onStatusChange={handleStatusChange} />
            </CardContent>
          </Card>
        );
      default:
        return (
          <div className="flex justify-center items-center h-64 bg-gray-100 rounded-lg">
            <p className="text-gray-600 text-lg">You do not have permission to view this page.</p>
          </div>
        );
    }
  };

  return renderContent();
};

export default ChangePasswordTab;