import React, { useState, useEffect, useRef } from 'react';
import { Search } from 'lucide-react';
import axios from 'axios';
import { Input } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Filter } from 'lucide-react';
import jsPDF from 'jspdf';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Edit, Trash } from 'lucide-react';
import { apiClient } from '../../../core/api/client';

const SignatureCanvas = ({ onSignatureComplete, width = 400, height = 200 }) => {
  const canvasRef = useRef(null);
  const [isDrawing, setIsDrawing] = useState(false);
  const [points, setPoints] = useState([]);
  const [hasSignature, setHasSignature] = useState(false);

  const startDrawing = (event) => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    const rect = canvas.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = event.clientY - rect.top;

    ctx.beginPath();
    ctx.moveTo(x, y);
    setIsDrawing(true);
    setPoints([{ x, y }]);
  };

  const draw = (event) => {
    if (!isDrawing) return;
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    const rect = canvas.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = event.clientY - rect.top;

    ctx.lineTo(x, y);
    ctx.stroke();
    setPoints(prev => [...prev, { x, y }]);
    setHasSignature(true);
  };

  const stopDrawing = () => {
    setIsDrawing(false);
  };

  const clearCanvas = () => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    
    ctx.clearRect(0, 0, width, height);
    setPoints([]);
    setHasSignature(false);
  };

  const saveSignature = () => {
    if (hasSignature) {
      onSignatureComplete(JSON.stringify(points), width, height);
    }
  };

  return (
    <div className="flex flex-col items-center space-y-4">
      <canvas 
        ref={canvasRef}
        width={width}
        height={height}
        style={{ 
          border: '1px solid #000', 
          backgroundColor: 'white' 
        }}
        onMouseDown={startDrawing}
        onMouseMove={draw}
        onMouseUp={stopDrawing}
        onMouseOut={stopDrawing}
      />
      <div className="flex space-x-4">
        <button 
          onClick={clearCanvas}
          className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition-colors"
        >
          Clear
        </button>
        <button 
          onClick={saveSignature}
          disabled={!hasSignature}
          className={`px-4 py-2 rounded transition-colors ${
            hasSignature 
              ? 'bg-green-500 text-white hover:bg-green-600' 
              : 'bg-gray-300 text-gray-500 cursor-not-allowed'
          }`}
        >
          Save Signature
        </button>
      </div>
    </div>
  );
};


const SignatureRenderer = ({ points, width, height }) => {
  const canvasRef = useRef(null);

  useEffect(() => {
    if (!points) return;

    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    
    // Clear previous drawing
    ctx.clearRect(0, 0, width, height);
    
    // Parse the points (assuming it's stored as a JSON string)
    const parsedPoints = JSON.parse(points);
    
    if (parsedPoints.length === 0) return;

    // Set up drawing context
    ctx.strokeStyle = 'black';
    ctx.lineWidth = 2;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';

    // Begin drawing
    ctx.beginPath();
    ctx.moveTo(parsedPoints[0].x, parsedPoints[0].y);

    // Draw all subsequent points
    for (let i = 1; i < parsedPoints.length; i++) {
      ctx.lineTo(parsedPoints[i].x, parsedPoints[i].y);
    }

    // Stroke the path
    ctx.stroke();
  }, [points, width, height]);

  return (
    <canvas 
      ref={canvasRef}
      width={width}
      height={height}
      style={{ 
        border: '1px solid #e0e0e0', 
        backgroundColor: 'white',
        maxWidth: '100%'
      }}
    />
  );
};

const CustomDialog = ({ isOpen, onClose, title, children }) => {
  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div 
          className="fixed inset-0 z-50 flex items-center justify-center p-4 overflow-y-auto"
          initial={{ backgroundColor: 'rgba(0,0,0,0)' }}
          animate={{ backgroundColor: 'rgba(0,0,0,0.5)' }}
          exit={{ backgroundColor: 'rgba(0,0,0,0)' }}
        >
          <motion.div 
            className="bg-white w-full max-w-2xl rounded-2xl shadow-2xl overflow-hidden"
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.9 }}
            transition={{ type: 'spring', damping: 15, stiffness: 300 }}
          >
            {/* Header */}
            <div className="flex justify-between items-center p-6 bg-gray-50 border-b border-gray-200">
              <h2 className="text-2xl font-semibold text-gray-800">{title}</h2>
              <button 
                onClick={onClose} 
                className="text-gray-500 hover:text-gray-700 transition-colors rounded-full p-2 hover:bg-gray-200"
                aria-label="Close dialog"
              >
                <X className="w-6 h-6" />
              </button>
            </div>

            {/* Content */}
            <div className="p-6 max-h-[70vh] overflow-y-auto">
              {children}
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

const ChangeRequest = () => {
  const [changeRequests, setChangeRequests] = useState([]);
  const [selectedRequest, setSelectedRequest] = useState(null);
  const [isDetailsDialogOpen, setIsDetailsDialogOpen] = useState(false);
  const [isSignatureDialogOpen, setIsSignatureDialogOpen] = useState(false);
  const [currentRequestForAction, setCurrentRequestForAction] = useState(null);
  const [userRole, setUserRole] = useState('user');
  const [userDepartment, setUserDepartment] = useState(null);
  const [fixedAssetTypes, setFixedAssetTypes] = useState([]);
  
  // Filter states
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedStatus, setSelectedStatus] = useState('all');
  const [selectedFixedAssetType, setSelectedFixedAssetType] = useState('');
  const [runningCode, setRunningCode] = useState('');
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
    fetchChangeRequests();
    fetchFixedAssetTypes();
  }, []);

  const fetchFixedAssetTypes = async () => {
    try {
      const response = await apiClient.get(`/ChangeRequests/fixedAssetTypes`);
      setFixedAssetTypes(response.data);
    } catch (error) {
      console.error('Error fetching fixed asset types:', error);
    }
  };

  const handleStatusChange = async (requestId, status) => {
    try {
      const user = JSON.parse(localStorage.getItem('user'));
      
      if (status === 'approved') {
        setCurrentRequestForAction({ id: requestId, status });
        setSelectedFixedAssetType('');
        setRunningCode('');
        setIsSignatureDialogOpen(true);
      } else {
        await apiClient.put(`/changeRequests/${requestId}/changestatus`, {
          status: status,
          approverId: user.id
        });
        fetchChangeRequests();
      }
    } catch (error) {
      console.error('Error updating request status:', error);
      alert('Failed to update request status');
    }
  };

  const handleApprovalWithFixedAsset = async (points, width, height) => {
    if (!selectedFixedAssetType || !runningCode) {
      alert('Please select a Fixed Asset Type and enter a Running Code');
      return;
    }

    if (currentRequestForAction) {
      await updateRequestStatus(
        currentRequestForAction.id, 
        currentRequestForAction.status, 
        { 
          points, 
          boundaryWidth: width, 
          boundaryHeight: height,
          fixedAssetTypeId: selectedFixedAssetType,
          runningCode: runningCode
        }
      );
    }
  };

  const updateRequestStatus = async (requestId, status, additionalData = {}) => {
    const user = JSON.parse(localStorage.getItem('user'));
    try {
      await apiClient.put(`/changeRequests/${requestId}/status`, {
        status,
        ApproverId: user.id,
        DateApproved: new Date(),
        ApprovalSignature: additionalData.points ? {
          points: additionalData.points,
          boundaryWidth: additionalData.boundaryWidth,
          boundaryHeight: additionalData.boundaryHeight
        } : null,
        FixedAssetTypeId: additionalData.fixedAssetTypeId,
        RunningCode: additionalData.runningCode
      });
      fetchChangeRequests();
      setIsSignatureDialogOpen(false);
      setCurrentRequestForAction(null);
    } catch (error) {
      console.error('Error updating request status:', error);
      alert('The running code of this category already exist');
    }
  };
  
  const fetchChangeRequests = async () => {
    try {
      const response = await apiClient.get(`/changeRequests`);
      setChangeRequests(response.data);
    } catch (error) {
      console.error('Error fetching change requests:', error);
    }
  };

  const handleViewDetails = async (requestId) => {
    try {
      const response = await apiClient.get(`/changeRequests/${requestId}/details`);
      setSelectedRequest(response.data);
      setIsDetailsDialogOpen(true);
    } catch (error) {
      console.error('Error fetching request details:', error);
    }
  };

  const closeSignatureDialog = () => {
    setIsSignatureDialogOpen(false);
    setCurrentRequestForAction(null);
    const dropdownElement = document.querySelector(`select[data-request-id="${currentRequestForAction?.id}"]`);
    if (dropdownElement) {
      dropdownElement.value = '';
    }
  };

  const filteredRequests = changeRequests.filter(request => {
    // Role-based filter
    const isDepartmentAdmin = userRole === 'department-admin';
    const matchesDepartment = !isDepartmentAdmin || request.department === userDepartment;

    // Status filter
    const matchesStatus = selectedStatus === 'all' || 
      request.status.toLowerCase() === selectedStatus.toLowerCase();

    // Date filter (month and year)
    const requestDate = new Date(request.dateRequested);
    const requestMonth = requestDate.getMonth().toString();
    const requestYear = requestDate.getFullYear().toString();
    const monthMatches = monthFilter === 'all' || requestMonth === monthFilter;
    const yearMatches = yearFilter === 'all' || requestYear === yearFilter;

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
          Asset Requisition
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {/* Filters (matching LeaveApprovalTab structure) */}
          <div className="bg-gray-50 p-4 rounded-lg border border-gray-200">
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

          {/* Table */}
          <div className="overflow-x-auto shadow-sm rounded-lg border">
            <Table>
              <TableHeader className="bg-gray-100">
                <TableRow>
                  <TableHead>ID</TableHead>
                  <TableHead>Requester</TableHead>
                  <TableHead>Department</TableHead>
                  <TableHead>Date</TableHead>
                  <TableHead>Details</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Action</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredRequests.map((request) => (
                  <TableRow key={request.id} className="hover:bg-gray-50 transition-colors">
                    <TableCell>{request.id}</TableCell>
                    <TableCell>{request.requesterName}</TableCell>
                    <TableCell>{request.department}</TableCell>
                    <TableCell>{formatDate(request.dateRequested)}</TableCell>
                    <TableCell>
                      <button 
                        onClick={() => handleViewDetails(request.id)}
                        className="text-blue-600 hover:underline"
                      >
                        View Details
                      </button>
                    </TableCell>
                    <TableCell>
                      <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm ${
                        request.status === 'approved' ? 'bg-green-100 text-green-800 border border-green-200' :
                        request.status === 'rejected' ? 'bg-red-100 text-red-800 border border-red-200' :
                        'bg-yellow-100 text-yellow-800 border border-yellow-200'
                      }`}>
                        {request.status.charAt(0).toUpperCase() + request.status.slice(1)}
                      </span>
                    </TableCell>
                    <TableCell>
                      <select
                        defaultValue=""
                        onChange={(e) => handleStatusChange(request.id, e.target.value)}
                        data-request-id={request.id}
                        className="w-[120px] px-2 py-1 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        disabled={request.status !== 'pending'}
                      >
                        <option value="" disabled>Select</option>
                        <option value="approved">Approve</option>
                        <option value="rejected">Reject</option>
                      </select>
                    </TableCell>
                  </TableRow>
                ))}
                {filteredRequests.length === 0 && (
                  <TableRow>
                    <TableCell colSpan="7" className="text-center py-8 text-gray-500">
                      No change requests found for the selected filters
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
        title="Asset Request Details"
      >
        {selectedRequest && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <strong>Requester:</strong> {selectedRequest.requesterName}
              </div>
              <div>
                <strong>Department:</strong> {selectedRequest.department}
              </div>
              <div>
                <strong>Date Requested:</strong> {formatDate(selectedRequest.dateRequested)}
              </div>
              <div>
                <strong>Status:</strong> {selectedRequest.status}
              </div>
            </div>

            {selectedRequest.description && (
              <div className="mt-4">
                <h3 className="font-semibold text-lg">Description</h3>
                <p>{selectedRequest.description}</p>
              </div>
            )}

            {selectedRequest.reason && (
              <div className="mt-4">
                <h3 className="font-semibold text-lg">Reason</h3>
                <p>{selectedRequest.reason}</p>
              </div>
            )}

            {selectedRequest.risk && (
              <div className="mt-4">
                <h3 className="font-semibold text-lg">Risk Assessment</h3>
                <p>{selectedRequest.risk}</p>
              </div>
            )}

            {selectedRequest.instruction && (
              <div className="mt-4">
                <h3 className="font-semibold text-lg">Instructions</h3>
                <p>{selectedRequest.instruction}</p>
              </div>
            )}

            {selectedRequest.completeDate && (
              <div className="mt-4">
                <h3 className="font-semibold text-lg">Completion Date</h3>
                <p>{formatDate(selectedRequest.completeDate)}</p>
              </div>
            )}

            {selectedRequest.postReview && (
              <div className="mt-4">
                <h3 className="font-semibold text-lg">Post-Review</h3>
                <p>{selectedRequest.postReview}</p>
              </div>
            )}

            {selectedRequest.signature && (
              <div className="mt-4">
                <h3 className="font-semibold text-lg">Signature</h3>
                <div className="flex flex-col items-center">
                  <SignatureRenderer 
                    points={selectedRequest.signature.points}
                    width={selectedRequest.signature.boundaryWidth}
                    height={selectedRequest.signature.boundaryHeight}
                  />
                </div>
              </div>
            )}
          </div>
        )}
      </CustomDialog>

      {/* Signature Dialog */}
      <CustomDialog
        isOpen={isSignatureDialogOpen}
        onClose={closeSignatureDialog}
        title="Approve Request - Fixed Asset Details"
      >
        <div className="space-y-4">
          {/* Fixed Asset Type Dropdown */}
          <div>
            <label className="block text-sm font-medium text-gray-700">
              Fixed Asset Type
            </label>
            <select
              value={selectedFixedAssetType}
              onChange={(e) => setSelectedFixedAssetType(e.target.value)}
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm"
              required
            >
              <option value="">Select Fixed Asset Type</option>
              {fixedAssetTypes.map((type) => (
                <option key={type.id} value={type.id}>
                  {type.name} ({type.code})
                </option>
              ))}
            </select>
          </div>

          {/* Running Code Input */}
          <div>
            <label className="block text-sm font-medium text-gray-700">
              Running Code
            </label>
            <input
              type="text"
              value={runningCode}
              onChange={(e) => setRunningCode(e.target.value)}
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm"
              placeholder="Enter Running Code"
              required
            />
          </div>

          {/* Signature Canvas */}
          <div className="flex flex-col items-center">
            <p className="mb-4">Please sign to approve the change request</p>
            <SignatureCanvas 
              onSignatureComplete={handleApprovalWithFixedAsset}
              width={400}
              height={200}
            />
          </div>
        </div>
      </CustomDialog>
    </Card>
  );
};

export default ChangeRequest;
