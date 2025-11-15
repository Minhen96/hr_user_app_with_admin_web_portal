import React, { useState, useEffect, useRef } from 'react';
import { Search } from 'lucide-react';
import axios from 'axios';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { X, Filter } from 'lucide-react';
import jsPDF from 'jspdf';
import { apiClient } from '../../../core/api/client';

const CustomDialog = ({ isOpen, onClose, title, children }) => {
    if (!isOpen) return null;
  
    return (
      <div className="fixed inset-0 z-50 flex items-center justify-center overflow-y-auto">
        {/* Backdrop with blur effect */}
        <div 
          className="fixed inset-0 bg-black/40 backdrop-blur-sm" 
          onClick={onClose}
        ></div>
        
        {/* Dialog Container */}
        <div className="relative w-full max-w-2xl mx-4 md:mx-auto">
          <div className="bg-white rounded-2xl shadow-2xl border border-gray-200 overflow-hidden animate-dialog-slide-up">
            {/* Header */}
            <div className="flex justify-between items-center p-6 border-b border-gray-100 bg-gray-50">
              <h2 className="text-2xl font-bold text-gray-800">{title}</h2>
              <button 
                onClick={onClose} 
                className="text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-full p-2 transition-colors"
                aria-label="Close dialog"
              >
                <X className="w-6 h-6" />
              </button>
            </div>
            
            {/* Content */}
            <div className="p-6">
              {children}
            </div>
          </div>
        </div>
      </div>
    );
  };

  const ChangeReturn = () => {
    const [changeReturns, setChangeReturns] = useState([]);
    const [selectedReturn, setSelectedReturn] = useState(null);
    const [isDetailsDialogOpen, setIsDetailsDialogOpen] = useState(false);
    const [userRole, setUserRole] = useState('user');
    const [userDepartment, setUserDepartment] = useState(null);
    
    // Filter states
    const [searchTerm, setSearchTerm] = useState('');
    const [selectedStatus, setSelectedStatus] = useState('all');
    const [monthFilter, setMonthFilter] = useState('all');
    const [yearFilter, setYearFilter] = useState(new Date().getFullYear().toString());
  
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
      fetchChangeReturns();
    }, []);
  
    const fetchChangeReturns = async () => {
      try {
        const response = await apiClient.get(`/changeReturns`);
        // Filter out 'in_use' status
        const filteredReturns = response.data.filter(
          item => item.returnStatus !== 'in_use'
        );
        setChangeReturns(filteredReturns);
      } catch (error) {
        console.error('Error fetching change returns:', error);
        setChangeReturns([]);
      }
    };
  
    const handleStatusChange = async (returnId, status) => {
      try {
        const user = JSON.parse(localStorage.getItem('user'));
        
        await apiClient.put(`/changeReturns/${returnId}/returnstatus`, {
          returnStatus: status,
          approverId: user.id
        });
        
        // Refresh the list
        fetchChangeReturns();
      } catch (error) {
        console.error('Error updating return status:', error);
        alert('Failed to update return status');
      }
    };
  
    const handleViewDetails = async (returnId) => {
      try {
        const response = await apiClient.get(`/changeReturns/${returnId}/details`);
        setSelectedReturn(response.data);
        setIsDetailsDialogOpen(true);
      } catch (error) {
        console.error('Error fetching return details:', error);
      }
    };
  
    const filteredReturns = changeReturns.filter(request => {
      // Role-based filter
      const isDepartmentAdmin = userRole === 'department-admin';
      const matchesDepartment = !isDepartmentAdmin || request.department === userDepartment;
  
      // Status filter
      const matchesStatus = selectedStatus === 'all' || 
        request.returnStatus.toLowerCase() === selectedStatus.toLowerCase();
  
      // Date filter (month and year)
      const returnDate = new Date(request.dateReturned);
      const returnMonth = returnDate.getMonth().toString();
      const returnYear = returnDate.getFullYear().toString();
      const monthMatches = monthFilter === 'all' || returnMonth === monthFilter;
      const yearMatches = yearFilter === 'all' || returnYear === yearFilter;
  
      // Search filter
      const matchesSearch = 
        request.requesterName.toLowerCase().includes(searchTerm.toLowerCase()) ||
        request.id.toString().includes(searchTerm.toLowerCase());
  
      // Combine all filters
      switch(userRole) {
        case 'super-admin':
          return matchesStatus && monthMatches && yearMatches && matchesSearch;
        case 'department-admin':
          return matchesStatus && monthMatches && yearMatches && matchesSearch && matchesDepartment;
        case 'user':
          return matchesStatus && 
                 monthMatches && 
                 yearMatches && 
                 matchesSearch && 
                 request.requesterName === JSON.parse(localStorage.getItem('user')).full_name;
        default:
          return false;
      }
    });
  
    const formatDate = (dateString) => {
      return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      });
    };
  
    return (
      <Card className="w-full">
        <CardHeader>
          <CardTitle className="text-2xl font-bold text-gray-800">
            Asset Return
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-6">
            {/* Filters (matching LeaveApprovalTab structure) */}
            <div className="bg-gray-50 p-4 rounded-lg border border-gray-200">
              <div className="flex items-center space-x-3 mb-3">
                <Filter className="w-5 h-5 text-gray-600" />
                <span className="text-sm font-medium text-gray-700">Filter Return Records:</span>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {/* Status Filter */}
                <div className="flex flex-col space-y-1">
                  <label className="text-xs text-gray-500">Status</label>
                  <select 
                    value={selectedStatus}
                    onChange={(e) => setSelectedStatus(e.target.value)}
                    className="form-select border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="all">All Statuses</option>
                    <option value="pending_return">Pending</option>
                    <option value="approved_return">Approved</option>
                    <option value="reject_return">Rejected</option>
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
  
            {/* Table */}
            <div className="overflow-x-auto shadow-sm rounded-lg border">
              <Table>
                <TableHeader className="bg-gray-100">
                  <TableRow>
                    <TableHead>ID</TableHead>
                    <TableHead>Requester</TableHead>
                    <TableHead>Department</TableHead>
                    <TableHead>Date Returned</TableHead>
                    <TableHead>Details</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Action</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredReturns.map((item) => (
                    <TableRow key={item.id} className="hover:bg-gray-50 transition-colors">
                      <TableCell>{item.id}</TableCell>
                      <TableCell>{item.requesterName}</TableCell>
                      <TableCell>{item.department}</TableCell>
                      <TableCell>{formatDate(item.dateReturned)}</TableCell>
                      <TableCell>
                        <button 
                          onClick={() => handleViewDetails(item.id)}
                          className="text-blue-600 hover:underline"
                        >
                          View Details
                        </button>
                      </TableCell>
                      <TableCell>
                        <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm ${
                          item.returnStatus === 'approved_return' ? 'bg-green-100 text-green-800 border border-green-200' :
                          item.returnStatus === 'reject_return' ? 'bg-red-100 text-red-800 border border-red-200' :
                          'bg-yellow-100 text-yellow-800 border border-yellow-200'
                        }`}>
                          {item.returnStatus
                            .replace('_return', '')
                            .replace('pending', 'Pending')
                            .replace('approved', 'Approved')
                            .replace('reject', 'Rejected')
                          }
                        </span>
                      </TableCell>
                      <TableCell>
                        <select
                          defaultValue=""
                          onChange={(e) => handleStatusChange(item.id, e.target.value)}
                          data-return-id={item.id}
                          className="w-[120px] px-2 py-1 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                          disabled={item.returnStatus !== 'pending_return'}
                        >
                          <option value="" disabled>Select</option>
                          <option value="approved_return">Approve</option>
                          <option value="reject_return">Reject</option>
                        </select>
                      </TableCell>
                    </TableRow>
                  ))}
                  {filteredReturns.length === 0 && (
                    <TableRow>
                      <TableCell colSpan="7" className="text-center py-8 text-gray-500">
                        No change returns found for the selected filters
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </div>
          </div>
        </CardContent>
  
        {/* Details Dialog */}
        <CustomDialog
          isOpen={isDetailsDialogOpen}
          onClose={() => setIsDetailsDialogOpen(false)}
          title="Asset Return Details"
        >
          {selectedReturn && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <strong>Requester:</strong> {selectedReturn.requesterName}
                </div>
                <div>
                  <strong>Department:</strong> {selectedReturn.department}
                </div>
                <div>
                  <strong>Date Returned:</strong> {formatDate(selectedReturn.dateReturned)}
                </div>
                {selectedReturn.productCode && (
                  <div>
                    <strong>Product Code:</strong> {selectedReturn.productCode}
                  </div>
                )}
              </div>
  
              {selectedReturn.receivedDetails && (
                <div className="mt-4">
                  <h3 className="font-semibold text-lg">Received Details</h3>
                  <p>{selectedReturn.receivedDetails}</p>
                </div>
              )}
  
              {selectedReturn.reason && (
                <div className="mt-4">
                  <h3 className="font-semibold text-lg">Reason</h3>
                  <p>{selectedReturn.reason}</p>
                </div>
              )}
            </div>
          )}
        </CustomDialog>
      </Card>
    );
  };
  
  export default ChangeReturn;
