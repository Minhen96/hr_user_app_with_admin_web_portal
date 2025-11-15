import React, { useState, useEffect, useRef } from 'react';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Search } from 'lucide-react';
import CustomDialog from '../../../shared/components/CustomDialog';

import axios from 'axios';
import ChangePasswordTab from '../../profile/components/ChangePasswordTab.jsx';
import './RequestApproval.css';
import LeaveApprovalTab from '../../leave/components/LeaveApprovalTab.jsx';
import EquipmentReturnal from '../../equipment/components/EquipmentReturnal';
import ApproveRequestDialog from '../../approvals/components/ApproveRequestDialog';
import TrainingApproval from '../../training/components/TrainingApproval';
import ChangeRequest from '../../approvals/components/ChangeRequest';
import { getPasswordChangeRequests, approvePasswordChange, rejectPasswordChange } from '../api/approvalsApi';
import { fetchAllEquipmentRequests, fetchEquipmentRequestDetails, updateEquipmentRequestStatus, approveEquipmentRequest } from '../../equipment/api/equipmentApi';
import ChangeReturn from '../../approvals/components/ChangeReturn';
import { Filter } from 'lucide-react';

const SignatureCanvas = ({ points, width, height }) => {
  const canvasRef = useRef(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    
    // Parse the points and normalize the format
    const signatureData = JSON.parse(points).map(point => ({
      x: point.X || point.x, // Handle both uppercase X and lowercase x
      y: point.Y || point.y  // Handle both uppercase Y and lowercase y
    }));

    // Clear the canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Begin drawing
    ctx.beginPath();
    ctx.strokeStyle = 'black';
    ctx.lineWidth = 2;
    
    signatureData.forEach((point, index) => {
      if (index === 0) {
        ctx.moveTo(point.x, point.y);
      } else {
        ctx.lineTo(point.x, point.y);
      }
    });
    
    ctx.stroke();
  }, [points]);

  return (
    <canvas 
      ref={canvasRef} 
      width={width} 
      height={height}
    />
  );
};

const RequestDetails = ({ request }) => {
  if (!request) return null;

  // Handle both flattened and navigation property formats
  const requesterName = request.requesterName || request.RequesterName || request.Requester?.FullName || 'Unknown';
  const department = request.department || request.Department || request.Requester?.Department?.Name || 'Unknown';
  const items = request.items || request.Items || request.equipmentItems || [];

  return (
    <div className="details-container">
      <div className="details-grid">
        <div className="details-field">
          <h4 className="details-label">Requested by</h4>
          <p className="details-value">{requesterName}</p>
        </div>
        <div className="details-field">
          <h4 className="details-label">Department</h4>
          <p className="details-value">{department}</p>
        </div>
      </div>
      
      <div className="equipment-section">
        <h4 className="section-title">Equipment Items</h4>
        <div className="equipment-table-container">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Item</TableHead>
                <TableHead>Description</TableHead>
                <TableHead>Quantity</TableHead>
                <TableHead>Justification</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {items.map((item, index) => (
                <TableRow key={index}>
                  <TableCell>{item.title || item.Title}</TableCell>
                  <TableCell>{item.description || item.Description}</TableCell>
                  <TableCell>{item.quantity || item.Quantity}</TableCell>
                  <TableCell>{item.justification || item.Justification}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </div>

      {request.signature && (
  <div className="signature-section">
    <h4 className="section-title">Signature</h4>
    <div className="signature-container">
      <SignatureCanvas 
        points={request.signature.points} 
        width={request.signature.boundaryWidth} 
        height={request.signature.boundaryHeight} 
      />
    </div>
  </div>
)}
    </div>
  );
};


const RequestTable = ({ requests, onStatusChange, onViewDetails, userRole, userDepartment }) => {
  // Filter states
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedStatus, setSelectedStatus] = useState('all');
  const [selectedDepartment, setSelectedDepartment] = useState('all');
  const [monthFilter, setMonthFilter] = useState('all');
  const [yearFilter, setYearFilter] = useState(new Date().getFullYear().toString());

  // Derived states for filter options
  const uniqueStatuses = ['all', ...new Set(requests.map(request => request.status))];
  const uniqueDepartments = ['all', ...new Set(requests.map(request => request.department))];

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

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  // Filter requests based on user role and filters
  const filteredRequests = requests.filter(request => {
    // Role-based filter
    const roleFiltered = (() => {
      switch(userRole) {
        case 'super-admin':
          return true;
        case 'department-admin':
          return request.department === userDepartment;
        case 'user':
          return false;
        default:
          return false;
      }
    })();

    if (!roleFiltered) return false;

    // Status filter - handle undefined status
    const matchesStatus = selectedStatus === 'all' ||
      (request.status && request.status.toLowerCase() === selectedStatus.toLowerCase());

    // Department filter - handle undefined department
    const matchesDepartment = selectedDepartment === 'all' ||
      (request.department && request.department === selectedDepartment);

    // Date filter (month and year) - handle both dateRequested and DateRequested
    const dateField = request.dateRequested || request.DateRequested;
    const requestDate = dateField ? new Date(dateField) : new Date();
    const requestMonth = requestDate.getMonth().toString();
    const requestYear = requestDate.getFullYear().toString();
    const monthMatches = monthFilter === 'all' || requestMonth === monthFilter;
    const yearMatches = yearFilter === 'all' || requestYear === yearFilter;

    // Search filter - handle undefined fields safely
    const requesterName = request.requesterName || request.Requester?.FullName || '';
    const department = request.department || request.Requester?.Department?.Name || '';
    const requestId = request.id || request.Id || '';

    const matchesSearch = !searchTerm ||
      requesterName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      department.toLowerCase().includes(searchTerm.toLowerCase()) ||
      requestId.toString().includes(searchTerm);

    return matchesStatus && matchesDepartment && monthMatches && yearMatches && matchesSearch;
  });

  const handleReset = () => {
    setSearchTerm('');
    setSelectedStatus('all');
    setSelectedDepartment('all');
    setMonthFilter('all');
    setYearFilter(new Date().getFullYear().toString());
  };

  return (
    <>
      <Card className="mb-6">
    
          <div className="bg-gray-50 p-4 rounded-lg border border-gray-100">
            <div className="flex items-center space-x-3 mb-3">
              <Filter className="w-5 h-5 text-gray-600" />
              <span className="text-sm font-medium text-gray-700">Filter Request Records:</span>
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
                  {uniqueStatuses.map(status => (
                    <option key={status} value={status}>
                      {status === 'all' ? 'All Statuses' : 
                        status.charAt(0).toUpperCase() + status.slice(1)}
                    </option>
                  ))}
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

      </Card>

      <div className="table-container overflow-x-auto shadow-sm rounded-lg border">
        <Table>
          <TableHeader className="bg-background">
            <TableRow>
              <TableHead>ID</TableHead>
              <TableHead>Name</TableHead>
              <TableHead>Department</TableHead>
              <TableHead>Request Date</TableHead>
              <TableHead>Details</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredRequests.map((request) => {
              // Handle both camelCase and PascalCase properties
              const requestId = request.id || request.Id || 'N/A';
              const requesterName = request.requesterName || request.Requester?.FullName || 'Unknown';
              const department = request.department || request.Requester?.Department?.Name || 'Unknown';
              const dateRequested = request.dateRequested || request.DateRequested;
              const status = request.status || request.Status || 'pending';

              const isActionDisabled =
                userRole === 'department-admin' && department !== userDepartment ||
                userRole === 'user';

              return (
                <TableRow key={requestId} className="hover:bg-gray-50 transition-colors">
                  <TableCell>{requestId}</TableCell>
                  <TableCell>{requesterName}</TableCell>
                  <TableCell>{department}</TableCell>
                  <TableCell>{formatDate(dateRequested)}</TableCell>
                  <TableCell>
                    <button
                      className="view-details-button text-blue-600 hover:underline"
                      onClick={() => onViewDetails(requestId)}
                      disabled={isActionDisabled}
                    >
                      View Details
                    </button>
                  </TableCell>
                  <TableCell>
                    <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm border-2 font-semibold ${
                      status.toLowerCase() === 'approved' ? 'bg-green-100 text-green-800 border-green-400 dark:bg-green-900/40 dark:text-green-100 dark:border-green-500' :
                      status.toLowerCase() === 'rejected' ? 'bg-red-100 text-red-800 border-red-400 dark:bg-red-900/40 dark:text-red-100 dark:border-red-500' :
                      'bg-yellow-100 text-yellow-800 border-yellow-400 dark:bg-yellow-900/40 dark:text-yellow-100 dark:border-yellow-500'
                    }`}>
                      {status.charAt(0).toUpperCase() + status.slice(1)}
                    </span>
                  </TableCell>
                  <TableCell>
                    <select
                      disabled={
                        isActionDisabled ||
                        status.toLowerCase() !== 'pending'
                      }
                      onChange={(e) => onStatusChange(requestId, e.target.value)}
                      className="w-[120px] px-2 py-1 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                      value=""
                    >
                      <option value="" disabled>Select</option>
                      <option value="approved">Approve</option>
                      <option value="rejected">Reject</option>
                    </select>
                  </TableCell>
                </TableRow>
              );
            })}
            {filteredRequests.length === 0 && (
              <TableRow>
                <TableCell colSpan="7" className="text-center py-8 text-gray-500">
                  No requests found for the selected filters
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </>
  );
};
const RequestApproval = () => {
  const [requests, setRequests] = useState([]);
  const [selectedRequest, setSelectedRequest] = useState(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [isApproveDialogOpen, setIsApproveDialogOpen] = useState(false);
  const [activeTab, setActiveTab] = useState('equipment-requisition');
  
  const [userRole, setUserRole] = useState('user');
  const [userDepartment, setUserDepartment] = useState(null);

  useEffect(() => {
    const user = JSON.parse(localStorage.getItem('user'));
    if (user) {
      setUserRole(user.role || 'user');
      setUserDepartment(user.department_name);
    }
    fetchRequests();
  }, []);
  const fetchRequests = async () => {
    try {
      const data = await fetchAllEquipmentRequests();
      setRequests(data);
    } catch (error) {
      console.error('Error fetching requests:', error);
      setRequests([]); // Set empty on error
    }
  };
  
  const fetchRequestDetails = async (requestId) => {
    try {
      const data = await fetchEquipmentRequestDetails(requestId);
      setSelectedRequest(data);
      setIsDialogOpen(true);
    } catch (error) {
      console.error('Error fetching request details:', error);
    }
  };

  const handleStatusChange = async (requestId, newStatus) => {
    if (newStatus === 'approved') {
      try {
        const data = await fetchEquipmentRequestDetails(requestId);
        setSelectedRequest(data);
        setIsApproveDialogOpen(true);
      } catch (error) {
        console.error('Error fetching request details:', error);
      }
    } else {
      const user = JSON.parse(localStorage.getItem('user'));
      try {
        await updateEquipmentRequestStatus(requestId, newStatus);
        fetchRequests();
      } catch (error) {
        console.error('Error updating status:', error);
      }
    }
  };

  const renderTabContent = () => {
    switch (activeTab) {
      case 'equipment-requisition':
        if (userRole === 'user') {
          return (
            <div className="dashboard-card">
              <p>You do not have permission to view equipment requisitions.</p>
            </div>
          );
        }
        return (
          <div className="dashboard-card">
            <header className="dashboard-header">
              <h3 className="dashboard-title">Material Requisition</h3>
            </header>
            <RequestTable 
              requests={requests}
              onStatusChange={handleStatusChange}
              onViewDetails={fetchRequestDetails}
              userRole={userRole}
              userDepartment={userDepartment}
            />
          </div>
        );
      case 'change-password':
        return <ChangePasswordTab />;
      case 'equipment-returned':
        return <ChangeReturn/>;
      case 'leave-approval':
        return <LeaveApprovalTab/>;
      case 'training-approval':
        return <TrainingApproval/>
      case 'change-request':
        return <ChangeRequest/>
      default:
        return null;
    }
  };

  const renderTabs = () => {
    const tabs = [
      { name: 'change-password', label: 'Change Password', show: true },
      { name: 'equipment-requisition', label: 'Material Requisition', show: userRole !== 'user' },
      { name: 'change-request', label: 'Asset Requisition', show: userRole !== 'user' },
      { name: 'equipment-returned', label: 'Asset Return', show: userRole !== 'user' },
      { name: 'leave-approval', label: 'Leave Approval', show: userRole !== 'user' },
      { name: 'training-approval', label: 'Training Approval', show: userRole !== 'user' }
    ];

    return tabs
      .filter(tab => tab.show)
      .map(tab => (
        <Button 
          key={tab.name}
          className={`${activeTab === tab.name ? 'button-primary' : 'button-ghost'}`}
          onClick={() => setActiveTab(tab.name)}
        >
          {tab.label}
        </Button>
      ));
  };

  const handleApproveRequest = async () => {
    try {
      const requestId = selectedRequest.id || selectedRequest.Id;
      await approveEquipmentRequest(requestId);
      setIsApproveDialogOpen(false);
      fetchRequests();
    } catch (error) {
      console.error('Error approving request:', error);
      alert('Failed to approve request');
    }
  };

  return (
    <div className="flex space-y-6 animate-fade-in bg-gray-50">
      
      <div className="flex-1  w-full px-4 sm:px-6 lg:px-8 py-6">
        <div className="max-w-7xl mx-auto">
          <nav className="flex flex-wrap gap-2 mb-6 overflow-x-auto pb-2">
            {renderTabs()}
          </nav>
          
          <div className="bg-white rounded-lg shadow">
            {renderTabContent()}
          </div>
  
          <ApproveRequestDialog 
            isOpen={isApproveDialogOpen} 
            onClose={() => {
              setIsApproveDialogOpen(false);
              setSelectedRequest(null);
            }}
            request={selectedRequest}
            onApprove={handleApproveRequest}
          />
                
          <CustomDialog 
            isOpen={isDialogOpen}
            onClose={() => setIsDialogOpen(false)}
            title="Request Details"
          >
            <RequestDetails request={selectedRequest} />
          </CustomDialog>
        </div>
      </div>
    </div>
  );
};

export default RequestApproval;
