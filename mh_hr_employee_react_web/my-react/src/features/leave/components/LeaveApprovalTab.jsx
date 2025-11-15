import React, { useState, useEffect, useRef } from 'react';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Button } from '@/components/ui/button';
import { Filter } from 'lucide-react';
import axios from 'axios';
import CustomsDialog from '../../../shared/components/CustomsDialog';
import './LeaveApprovalTab.css';
import { apiClient } from '../../../core/api/client';

const formatDate = (dateString) => {
    return dateString ? new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    }) : 'Not Changed';
  };

  const SignaturePad = ({ onSave }) => {
    const canvasRef = useRef(null);
    const [isDrawing, setIsDrawing] = useState(false);
    const [lastPoint, setLastPoint] = useState(null);
    const [points, setPoints] = useState([]);
  
    useEffect(() => {
      const canvas = canvasRef.current;
      const ctx = canvas.getContext('2d');
      
      // Improve line quality
      ctx.lineWidth = 2;
      ctx.lineJoin = 'round';
      ctx.lineCap = 'round';
      ctx.strokeStyle = '#000';
      
      // Set canvas scale for better resolution
      const dpr = window.devicePixelRatio || 1;
      const rect = canvas.getBoundingClientRect();
      
      canvas.width = rect.width * dpr;
      canvas.height = rect.height * dpr;
      ctx.scale(dpr, dpr);
      
      // Set CSS size
      canvas.style.width = `${rect.width}px`;
      canvas.style.height = `${rect.height}px`;
    }, []);
  
    const getCoordinates = (event) => {
      const canvas = canvasRef.current;
      const rect = canvas.getBoundingClientRect();
      const scaleX = canvas.width / rect.width;
      const scaleY = canvas.height / rect.height;
  
      if (event.touches && event.touches[0]) {
        // Touch event
        return {
          x: (event.touches[0].clientX - rect.left) * scaleX,
          y: (event.touches[0].clientY - rect.top) * scaleY
        };
      }
      // Mouse event
      return {
        x: (event.clientX - rect.left) * scaleX,
        y: (event.clientY - rect.top) * scaleY
      };
    };
  
    const drawLine = (start, end) => {
      const ctx = canvasRef.current.getContext('2d');
      ctx.beginPath();
      ctx.moveTo(start.x, start.y);
      
      // Use quadratic curve for smoother lines
      const controlPoint = {
        x: (start.x + end.x) / 2,
        y: (start.y + end.y) / 2
      };
      ctx.quadraticCurveTo(controlPoint.x, controlPoint.y, end.x, end.y);
      ctx.stroke();
    };
  
    const startDrawing = (e) => {
      e.preventDefault();
      const coords = getCoordinates(e);
      setIsDrawing(true);
      setLastPoint(coords);
      setPoints([coords]);
    };
  
    const draw = (e) => {
      e.preventDefault();
      if (!isDrawing) return;
  
      const newPoint = getCoordinates(e);
      if (lastPoint) {
        drawLine(lastPoint, newPoint);
        setPoints(prevPoints => [...prevPoints, newPoint]);
      }
      setLastPoint(newPoint);
    };
  
    const stopDrawing = () => {
      setIsDrawing(false);
      setLastPoint(null);
    };
  
    const handleSave = () => {
      if (points.length === 0) {
        alert('Please draw a signature before saving.');
        return;
      }
      
      onSave({
        points: JSON.stringify(points),
        boundaryWidth: canvasRef.current.width,
        boundaryHeight: canvasRef.current.height
      });
    };
  
    const handleClear = () => {
      const canvas = canvasRef.current;
      const ctx = canvas.getContext('2d');
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      setPoints([]);
    };
  
    return (
      <div className="flex flex-col items-center space-y-4">
        <div className="relative">
          {points.length === 0 && (
            <div className="absolute inset-0 flex items-center justify-center text-gray-400 pointer-events-none">
              Sign here
            </div>
          )}
          <canvas
            ref={canvasRef}
            className="border-2 border-gray-300 rounded-lg touch-none"
            style={{ width: '400px', height: '200px' }}
            onMouseDown={startDrawing}
            onMouseMove={draw}
            onMouseUp={stopDrawing}
            onMouseOut={stopDrawing}
            onTouchStart={startDrawing}
            onTouchMove={draw}
            onTouchEnd={stopDrawing}
          />
        </div>
        <div className="flex space-x-4">
          <Button 
            onClick={handleClear} 
            variant="outline"
            className="w-24"
          >
            Clear
          </Button>
          <Button 
            onClick={handleSave}
            className="w-24"
          >
            Save
          </Button>
        </div>
      </div>
    );
  };

const LeaveDetailsDialog = ({ isOpen, onClose, details }) => {
  if (!details) return null;

  const endDate = new Date(details.leaveDate);
  if(details.numberOfDays >= 1){
  endDate.setDate(endDate.getDate() + details.numberOfDays - 1);
  }

  return (
    <CustomsDialog isOpen={isOpen} onClose={onClose} title="Leave Details">
      <div className="leave-details-container">
        <div className="leave-details-grid overflow-y-auto max-h-[70vh]">
          <div>
            <h4 className="leave-details-title">Start Date</h4>
            <p>{formatDate(details.leaveDate)}</p>
          </div>
          <div>
            <h4 className="leave-details-title">End Date</h4>
            <p>{formatDate(endDate)}</p>
          </div>
          <div>
            <h4 className="leave-details-title">Number of Days</h4>
            <p>{details.numberOfDays}</p>
          </div>
          <div>
            <h4 className="leave-details-title">Reason</h4>
            <p>{details.reason}</p>
          </div>
          {details.documentUrl && (
            <div className="attached-document">
              <h4 className="leave-details-title attached-document-title">Attached Document</h4>
              {details.documentUrl.startsWith('%PDF') ? (
                <embed
                  src={`data:application/pdf;base64,${details.documentUrl}`}
                  type="application/pdf"
                  className="attached-document-pdf"
                />
              ) : (
                <img
                  src={`data:image/jpeg;base64,${details.documentUrl}`}
                  alt="Medical Certificate"
                  className="attached-document-image"
                />
              )}
            </div>
          )}
        </div>
      </div>
    </CustomsDialog>
  );
};

const LeaveApprovalTab = () => {
  const [leaves, setLeaves] = useState([]);
  const [medicalLeaves, setMedicalLeaves] = useState([]);
  const [selectedDetails, setSelectedDetails] = useState(null);
  const [isDetailsOpen, setIsDetailsOpen] = useState(false);
  const [isSignatureDialogOpen, setIsSignatureDialogOpen] = useState(false);
  const [selectedLeaveForApproval, setSelectedLeaveForApproval] = useState(null);
  const [isProcessingApproval, setIsProcessingApproval] = useState(false);
  const [statusFilter, setStatusFilter] = useState('all');
  const [userRole, setUserRole] = useState('user');
  const [userDepartment, setUserDepartment] = useState(null);
  const [monthFilter, setMonthFilter] = useState('all');
  const [yearFilter, setYearFilter] = useState(new Date().getFullYear().toString());

  // Generate month options
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
    // Fetch user details from localStorage
    const user = JSON.parse(localStorage.getItem('user'));
    if (user) {
      setUserRole(user.role || 'user');
      setUserDepartment(user.department_name);
    }
    fetchLeaves();
    fetchMedicalLeaves();
  }, []);

  const fetchLeaves = async () => {
    try {
      const response = await apiClient.get(`/leaves`);
      setLeaves(response.data);
    } catch (error) {
      console.error('Error fetching leaves:', error);
    }
  };

  const fetchMedicalLeaves = async () => {
    try {
      const response = await apiClient.get(`/leaves/medical`);
      setMedicalLeaves(response.data);
    } catch (error) {
      console.error('Error fetching medical leaves:', error);
      // Set empty array on error
      setMedicalLeaves([]);
    }
  };

  const handleSignatureSave = async (signatureData) => {
    setIsProcessingApproval(true);
    try {
      const user = JSON.parse(localStorage.getItem('user'));
      const signatureResponse = await apiClient.post(`/Signature`, {
        userId: user.id,
        ...signatureData
      });

      await updateLeaveStatus(
        selectedLeaveForApproval.id,
        'approved',
        selectedLeaveForApproval.isMedical,
        signatureResponse.data.id
      );

      setIsSignatureDialogOpen(false);
      setSelectedLeaveForApproval(null);
      fetchLeaves();
      fetchMedicalLeaves();
    } catch (error) {
      console.error('Error processing approval:', error);
    } finally {
      setIsProcessingApproval(false);
    }
  };

  const updateLeaveStatus = async (leaveId, status, isMedical, signatureId = null) => {
    const user = JSON.parse(localStorage.getItem('user'));
    const endpoint = isMedical 
      ? `/leaves/medical/${leaveId}/status`
      : `/leaves/${leaveId}/status`;

    try {
      await apiClient.put(endpoint, {
        status,
        approvedBy: user.id,
        approvalSignatureId: signatureId
      });
      
      if (isMedical) {
        fetchMedicalLeaves();
      } else {
        fetchLeaves();
      }
    } catch (error) {
      console.error('Error updating status:', error);
    }
  };

  const handleStatusChange = async (leaveId, newStatus, isMedical) => {
    if (newStatus === 'approved') {
      setSelectedLeaveForApproval({ id: leaveId, isMedical });
      setIsSignatureDialogOpen(true);
    } else {
      await updateLeaveStatus(leaveId, newStatus, isMedical);
    }
  };

  const LeaveTable = ({ data, title, isMedical }) => {
    // Filter by status
    const statusFilteredLeaves = data.filter(leave => 
      statusFilter === 'all' ? true : leave.status.toLowerCase() === statusFilter.toLowerCase()
    );

    // Filter by date (month and year)
    const dateFilteredLeaves = statusFilteredLeaves.filter(leave => {
      if (!leave.leaveDate) return false;
      
      const leaveDate = new Date(leave.leaveDate);
      const leaveMonth = leaveDate.getMonth().toString();
      const leaveYear = leaveDate.getFullYear().toString();
      
      const monthMatches = monthFilter === 'all' || leaveMonth === monthFilter;
      const yearMatches = yearFilter === 'all' || leaveYear === yearFilter;
      
      return monthMatches && yearMatches;
    });

    // Filter by user role
    const filteredLeaves = dateFilteredLeaves.filter(leave => {
      switch(userRole) {
        case 'super-admin':
          return true;
        case 'department-admin':
          return leave.user.department.name === userDepartment;
        case 'user':
          return leave.user.fullName === JSON.parse(localStorage.getItem('user')).full_name;
        default:
          return false;
      }
    });

    return (
      <div className="mb-8">
        <h3 className="text-xl font-semibold mb-4">{title}</h3>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Username</TableHead>
              <TableHead>NRIC</TableHead>
              <TableHead>Department</TableHead>
              <TableHead>Start Date</TableHead>
              <TableHead>Days</TableHead>
              <TableHead>Details</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredLeaves.length > 0 ? (
              filteredLeaves.map((leave) => {
                const isActionDisabled = 
                  userRole === 'department-admin' && leave.user.department.name !== userDepartment ||
                  userRole === 'user' && leave.user.fullName !== JSON.parse(localStorage.getItem('user')).full_name;

                return (
                  <TableRow key={leave.id}>
                    <TableCell>{leave.user.fullName}</TableCell>
                    <TableCell>{leave.user.nric}</TableCell>
                    <TableCell>{leave.user.department.name}</TableCell>
                    <TableCell>{formatDate(leave.leaveDate)}</TableCell>
                    <TableCell>{leave.numberOfDays}</TableCell>
                    <TableCell>
                      <span
                        className="view-details-link"
                        onClick={() => {
                          setSelectedDetails(leave);
                          setIsDetailsOpen(true);
                        }}
                        style={{ 
                          cursor: isActionDisabled ? 'not-allowed' : 'pointer',
                          color: isActionDisabled ? '#888' : 'blue'
                        }}
                      >
                        View Details
                      </span>
                    </TableCell>
                    <TableCell>
                      <span className={`status-badge status-${leave.status.toLowerCase()}`}>
                        {leave.status}
                      </span>
                    </TableCell>
                    <TableCell>
                      <select
                        disabled={
                          leave.status === 'approved' || 
                          leave.status === 'rejected' || 
                          isActionDisabled
                        }
                        onChange={(e) => handleStatusChange(leave.id, e.target.value, isMedical)}
                        defaultValue=""
                        className="form-select"
                      >
                        <option value="" disabled>Action</option>
                        <option value="approved">Approve</option>
                        <option value="rejected">Reject</option>
                      </select>
                    </TableCell>
                  </TableRow>
                );
              })
            ) : (
              <TableRow>
                <TableCell colSpan={8} className="text-center py-4 text-gray-500">
                  No leave records found for the selected filters
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    );
  };

  const renderContent = () => {
    switch(userRole) {
      case 'super-admin':
      case 'department-admin':
        return (
          <>
            <header className="dashboard-header">
              <h2 className="dashboard-title">Leave Approval</h2>
              <p className="dashboard-subtitle">Manage and review leave requests</p>
            </header>

            {/* Filters */}
            <div className="bg-gray-50 p-4 rounded-lg border border-gray-200 mb-6">
              <div className="flex items-center space-x-3 mb-3">
                <Filter className="w-5 h-5 text-gray-600" />
                <span className="text-sm font-medium text-gray-700">Filter Leave Records:</span>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {/* Status Filter */}
                <div className="flex flex-col space-y-1">
                  <label className="text-xs text-gray-500">Status</label>
                  <select 
                    value={statusFilter}
                    onChange={(e) => setStatusFilter(e.target.value)}
                    className="form-select border-gray-300"
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
                    className="form-select border-gray-300"
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
                    className="form-select border-gray-300"
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
            
            <LeaveTable data={leaves} title="Regular Leave" isMedical={false} />
            <LeaveTable data={medicalLeaves} title="Medical Leave" isMedical={true} />
          </>
        );
      case 'user':
        return (
          <>
            <header className="dashboard-header">
              <h2 className="dashboard-title">My Leaves</h2>
            </header>

            {/* Filters */}
            <div className="bg-gray-50 p-4 rounded-lg border border-gray-200 mb-6">
              <div className="flex items-center space-x-3 mb-3">
                <Filter className="w-5 h-5 text-gray-600" />
                <span className="text-sm font-medium text-gray-700">Filter Leave Records:</span>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {/* Status Filter */}
                <div className="flex flex-col space-y-1">
                  <label className="text-xs text-gray-500">Status</label>
                  <select 
                    value={statusFilter}
                    onChange={(e) => setStatusFilter(e.target.value)}
                    className="form-select border-gray-300"
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
                    className="form-select border-gray-300"
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
                    className="form-select border-gray-300"
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
            
            <LeaveTable data={leaves} title="Regular Leave" isMedical={false} />
            <LeaveTable data={medicalLeaves} title="Medical Leave" isMedical={true} />
          </>
        );
      default:
        return <p>You do not have permission to view this page.</p>;
    }
  };

  return (
    <div className="dashboard-card">
      {renderContent()}

      <LeaveDetailsDialog
        isOpen={isDetailsOpen}
        onClose={() => setIsDetailsOpen(false)}
        details={selectedDetails}
      />

      <CustomsDialog
        isOpen={isSignatureDialogOpen}
        onClose={() => setIsSignatureDialogOpen(false)}
        title="Signature Pad"
      >
        <SignaturePad onSave={handleSignatureSave} />
        {isProcessingApproval && <p>Processing approval...</p>}
      </CustomsDialog>
    </div>
  );
};

export default LeaveApprovalTab;
