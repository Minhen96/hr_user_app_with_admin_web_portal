import React, { useState, useEffect, useRef } from 'react';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Search } from 'lucide-react';
import axios from 'axios';

import { FaCheck } from 'react-icons/fa';
import { fetchEquipmentReturns as fetchAllReturns, fetchEquipmentReturnDetails as fetchReturnDetails, updateEquipmentReturnStatus as updateReturnStatus } from '../api/equipmentApi';

// SignatureCanvas component remains the same
const SignatureCanvas = ({ points, width, height }) => {
    const canvasRef = useRef(null);
  
    useEffect(() => {
      const canvas = canvasRef.current;
      const ctx = canvas.getContext('2d');
      
      // Parse the points and normalize the format
      const signatureData = JSON.parse(points).map(point => ({
        x: point.X || point.x, 
        y: point.Y || point.y  
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

// ReturnDetails component remains the same
const ReturnDetails = ({ returnData }) => {
  if (!returnData) return null;

  return (
    <div className="details-container">
      <div className="details-grid">
        <div className="details-field">
          <h4 className="details-label">Returned by</h4>
          <p className="details-value">{returnData.returnerName}</p>
        </div>
        <div className="details-field">
          <h4 className="details-label">Department</h4>
          <p className="details-value">{returnData.department}</p>
        </div>
      </div>
      
      <div className="equipment-section">
        <h4 className="section-title">Returned Equipment Items</h4>
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
              {returnData.equipmentItems?.map((item, index) => (
                <TableRow key={index}>
                  <TableCell>{item.title}</TableCell>
                  <TableCell>{item.description}</TableCell>
                  <TableCell>{item.quantity}</TableCell>
                  <TableCell>{item.justification}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </div>

      {returnData.signature && (
        <div className="signature-section">
          <h4 className="section-title">Signature</h4>
          <div className="signature-container">
            <SignatureCanvas 
              points={returnData.signature.points} 
              width={returnData.signature.boundaryWidth} 
              height={returnData.signature.boundaryHeight} 
            />
          </div>
        </div>
      )}
    </div>
  );
};

const ReturnTable = ({ returns, onStatusChange, onViewDetails, userRole, userDepartment }) => {
  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  const filteredReturns = returns.filter(returnItem => {
    // First, apply role-based filtering
    let roleBasedFilter = false;
    switch(userRole) {
      case 'super-admin':
        roleBasedFilter = true;
        break;
      case 'department-admin':
        roleBasedFilter = returnItem.department === userDepartment;
        break;
      case 'user':
        roleBasedFilter = returnItem.returnerName === JSON.parse(localStorage.getItem('user')).full_name;
        break;
      default:
        roleBasedFilter = false;
    }
  
    // If role-based filter fails, return false
    if (!roleBasedFilter) return false;
    
    // Then apply existing search, status, and department filters
    const matchesSearch = 
      returnItem.returnerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      returnItem.id.toString().includes(searchTerm.toLowerCase()) ||
      returnItem.department.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesStatus = selectedStatus === 'all' || 
      returnItem.status.toLowerCase() === selectedStatus.toLowerCase();
    
    const matchesDepartment = selectedDepartment === 'all' || 
      returnItem.department === selectedDepartment;
  
    return matchesSearch && matchesStatus && matchesDepartment;
  });

  return (
    <div className="table-container">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>ID</TableHead>
            <TableHead>Name</TableHead>
            <TableHead>Department</TableHead>
            <TableHead>Return Date</TableHead>
            <TableHead>Details</TableHead>
            <TableHead>Status</TableHead>
            <TableHead>Action</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {filteredReturns.map((returnItem) => {
            const isActionDisabled = 
              userRole === 'department-admin' && returnItem.department !== userDepartment ||
              userRole === 'user' && returnItem.returnerName !== JSON.parse(localStorage.getItem('user')).full_name;

            return (
              <TableRow key={returnItem.id}>
                <TableCell>{returnItem.id}</TableCell>
                <TableCell>{returnItem.returnerName}</TableCell>
                <TableCell>{returnItem.department}</TableCell>
                <TableCell>{formatDate(returnItem.dateReturn)}</TableCell>
                <TableCell>
                  <button 
                    className="view-details-button"
                    onClick={() => onViewDetails(returnItem.id)}
                    disabled={isActionDisabled}
                  >
                    View Details
                  </button>
                </TableCell>
                <TableCell>
                  <span className={`status-badge status-${returnItem.status.toLowerCase()}`}>
                    {returnItem.status.charAt(0).toUpperCase() + returnItem.status.slice(1)}
                  </span>
                </TableCell>
                <TableCell>
                  <Button
                    className={`check-button flex items-center gap-2 px-4 py-2 rounded-lg 
                      ${
                        isActionDisabled || returnItem.status.toLowerCase() !== 'unchecked'
                          ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
                          : 'bg-green-500 text-white hover:bg-green-600'
                      }`}
                    disabled={
                      isActionDisabled || returnItem.status.toLowerCase() !== 'unchecked'
                    }
                    onClick={() => onStatusChange(returnItem.id, 'checked')}
                  >
                    <FaCheck className="text-lg" />
                    <span>Check</span>
                  </Button>
                </TableCell>
              </TableRow>
            );
          })}
        </TableBody>
      </Table>
    </div>
  );
};

const EquipmentReturnal = () => {
  const [returns, setReturns] = useState([]);
  const [selectedReturn, setSelectedReturn] = useState(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [userRole, setUserRole] = useState('user');
  const [userDepartment, setUserDepartment] = useState(null);

  // New filter states
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedStatus, setSelectedStatus] = useState('all');
  const [selectedDepartment, setSelectedDepartment] = useState('all');
  
  // Derived states for filter options
  const [departments, setDepartments] = useState([]);
  const statuses = ['Unchecked', 'Checked']; // Add more statuses if needed

  useEffect(() => {
    const user = JSON.parse(localStorage.getItem('user'));
    if (user) {
      setUserRole(user.role || 'user');
      setUserDepartment(user.department_name);
    }
    fetchReturns();
  }, []);

  useEffect(() => {
    if (returns.length > 0) {
      const uniqueDepartments = [...new Set(returns.map(item => item.department))];
      setDepartments(uniqueDepartments);
    }
  }, [returns]);

  const fetchReturns = async () => {
    try {
      const data = await fetchAllReturns();
      setReturns(data);
    } catch (error) {
      console.error('Error fetching returns:', error);
    }
  };
  

  const handleFetchReturnDetails = async (returnId) => {
    try {
      const data = await fetchReturnDetails(returnId);
      setSelectedReturn(data);
      setIsDialogOpen(true);
    } catch (error) {
      console.error('Error fetching return details:', error);
    }
  };
  
const handleStatusChange = async (returnId, newStatus) => {
  const user = JSON.parse(localStorage.getItem('user'));
  try {
    await updateReturnStatus(returnId, newStatus, user.id);
    fetchReturns();
  } catch (error) {
    console.error('Error updating status:', error);
  }
};

  const handleReset = () => {
    setSearchTerm('');
    setSelectedStatus('all');
    setSelectedDepartment('all');
  };

  // Filter the returns based on search term, status, and department
  const filteredReturns = returns.filter(returnItem => {
    const matchesSearch = 
      returnItem.returnerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      returnItem.id.toString().includes(searchTerm.toLowerCase()) ||
      returnItem.department.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesStatus = selectedStatus === 'all' || 
      returnItem.status.toLowerCase() === selectedStatus.toLowerCase();
    
    const matchesDepartment = selectedDepartment === 'all' || 
      returnItem.department === selectedDepartment;

    return matchesSearch && matchesStatus && matchesDepartment;
  });

  const CustomDialog = ({ isOpen, onClose, title, children }) => {
    if (!isOpen) return null;
  
    return (
      <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
        <div className="bg-white rounded-lg shadow-xl w-[600px] max-w-[90%]">
          <div className="flex justify-between items-center p-4 border-b">
            <h2 className="text-xl font-semibold">{title}</h2>
            <button 
              className="text-gray-600 hover:text-gray-900 text-2xl" 
              onClick={onClose}
            >
              ×
            </button>
          </div>
          <div className="p-4">
            {children}
          </div>
        </div>
      </div>
    );
  };

  const renderContent = () => {
    return (
      <>
        <header className="dashboard-header">
          <h2 className="dashboard-title">
            {userRole === 'user' ? 'My Equipment Returns' : 'Material Returns'}
          </h2>
          {userRole !== 'user' && (
            <p className="dashboard-subtitle">Manage and review equipment returns</p>
          )}
        </header>

        <Card className="mb-6">
          <CardContent className="pt-6">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div className="relative">
                <Search className="absolute left-2 top-2.5 h-4 w-4 text-gray-500" />
                <Input
                  placeholder="Search returns..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-8"
                />
              </div>

              <Select value={selectedStatus} onValueChange={setSelectedStatus}>
                <SelectTrigger>
                  <SelectValue placeholder="Filter by Status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Statuses</SelectItem>
                  {statuses.map(status => (
                    <SelectItem key={status} value={status.toLowerCase()}>
                      {status}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>

              <Select value={selectedDepartment} onValueChange={setSelectedDepartment}>
                <SelectTrigger>
                  <SelectValue placeholder="Filter by Department" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Departments</SelectItem>
                  {departments.map(department => (
                    <SelectItem key={department} value={department}>
                      {department}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>

              <button
                onClick={handleReset}
                className="px-4 py-2 bg-gray-100 text-gray-600 rounded-md hover:bg-gray-200 transition-colors"
              >
                Reset Filters
              </button>
            </div>
          </CardContent>
        </Card>
        
        <ReturnTable 
          returns={filteredReturns}
          onStatusChange={handleStatusChange}
          onViewDetails={handleFetchReturnDetails}
          userRole={userRole}
          userDepartment={userDepartment}
        />
      </>
    );
  };

  return (
    <div className="dashboard-card">
      {renderContent()}

      <CustomDialog 
        isOpen={isDialogOpen}
        onClose={() => setIsDialogOpen(false)}
        title="Return Details"
      >
        <ReturnDetails returnData={selectedReturn} />
      </CustomDialog>
    </div>
  );
};

export default EquipmentReturnal;