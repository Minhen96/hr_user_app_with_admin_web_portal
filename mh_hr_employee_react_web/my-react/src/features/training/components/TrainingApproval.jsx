import React, { useState, useEffect } from 'react';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Filter } from 'lucide-react';
import axios from 'axios';
import { fetchTrainings, updateTrainingStatus, fetchTrainingCertificate } from '../api/trainingApi';


// Custom Details Dialog Component
const DetailsDialog = ({ isOpen, onClose, trainingDetails, certificate }) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-4xl w-full max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold">Training Details</h2>
          <button 
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700 text-2xl font-bold"
          >
            ×
          </button>
        </div>
        
        <div className="space-y-6">
          <div className="grid grid-cols-2 gap-4 p-4 bg-gray-50 rounded-lg">
            <div>
              <h3 className="font-semibold mb-2">Course Information</h3>
              <div className="space-y-2">
                <p><span className="font-medium">Title:</span> {trainingDetails?.title}</p>
                <p><span className="font-medium">Course Date:</span> {
                  trainingDetails?.courseDate && new Date(trainingDetails.courseDate).toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                  })
                }</p>
                <p><span className="font-medium">Status:</span> 
                  <span className={`ml-2 inline-block px-2 py-1 text-sm rounded-full ${
                    trainingDetails?.status === 'approved' ? 'bg-green-100 text-green-800' :
                    trainingDetails?.status === 'rejected' ? 'bg-red-100 text-red-800' :
                    'bg-yellow-100 text-yellow-800'
                  }`}>
                    {trainingDetails?.status?.charAt(0).toUpperCase() + trainingDetails?.status?.slice(1)}
                  </span>
                </p>
              </div>
            </div>
            
            <div>
              <h3 className="font-semibold mb-2">Participant Information</h3>
              <div className="space-y-2">
                <p><span className="font-medium">Name:</span> {trainingDetails?.userName}</p>
                <p><span className="font-medium">Department:</span> {trainingDetails?.department}</p>
              </div>
            </div>
          </div>

          {/* Description Section */}
          <div className="p-4 bg-gray-50 rounded-lg">
            <h3 className="font-semibold mb-2">Course Description</h3>
            <p className="text-gray-700 whitespace-pre-wrap">{trainingDetails?.description}</p>
          </div>

          {/* Certificate Preview Section */}
          {certificate && (
            <div className="p-4 bg-gray-50 rounded-lg">
              <h3 className="font-semibold mb-4">Certificate</h3>
              <div className="certificate-preview">
                {certificate.type.includes('pdf') ? (
                  <iframe
                    src={certificate.url}
                    className="w-full h-[500px]"
                    title="Certificate Preview"
                  />
                ) : (
                  <img
                    src={certificate.url}
                    alt="Certificate"
                    className="max-w-full h-auto"
                  />
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

const TrainingApproval = () => {
  const [trainings, setTrainings] = useState([]);
  const [selectedTraining, setSelectedTraining] = useState(null);
  const [selectedCertificate, setSelectedCertificate] = useState(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [userRole, setUserRole] = useState('user');
  const [userDepartment, setUserDepartment] = useState(null);
  const [statusFilter, setStatusFilter] = useState('all');
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
    loadTrainings();
  }, []);

  const loadTrainings = async () => {
    try {
      const data = await fetchTrainings();
      setTrainings(data);
    } catch (error) {
      console.error('Error loading trainings:', error);
    }
  };

  const handleStatusChange = async (trainingId, newStatus) => {
    const user = JSON.parse(localStorage.getItem('user'));
    try {
      await updateTrainingStatus(trainingId, {
        status: newStatus,
        approverId: user.id,
        dateApproved: new Date().toISOString()
      });
      loadTrainings();
      
      if (selectedTraining?.id === trainingId) {
        setSelectedTraining(prev => ({ ...prev, status: newStatus }));
      }
    } catch (error) {
      console.error('Error updating status:', error);
    }
  };

  const viewDetails = async (training) => {
    try {
      setSelectedTraining(training);
      const certificateData = await fetchTrainingCertificate(training.id);
      setSelectedCertificate(certificateData);
      setIsDialogOpen(true);
    } catch (error) {
      console.error('Error viewing details:', error);
    }
  };

  const handleCloseDialog = () => {
    if (selectedCertificate?.url) {
      URL.revokeObjectURL(selectedCertificate.url);
    }
    setSelectedCertificate(null);
    setSelectedTraining(null);
    setIsDialogOpen(false);
  };

  // Apply filters similar to LeaveApprovalTab
  const filteredTrainings = trainings.filter(training => {
    // Status filter
    const matchesStatusFilter = statusFilter === 'all' 
      ? true 
      : training.status.toLowerCase() === statusFilter.toLowerCase();

    // Date filter (month and year)
    const trainingDate = new Date(training.courseDate);
    const trainingMonth = trainingDate.getMonth().toString();
    const trainingYear = trainingDate.getFullYear().toString();
    
    const monthMatches = monthFilter === 'all' || trainingMonth === monthFilter;
    const yearMatches = yearFilter === 'all' || trainingYear === yearFilter;

    // Role-based filter
    switch(userRole) {
      case 'super-admin':
        return matchesStatusFilter && monthMatches && yearMatches;
      case 'department-admin':
        return matchesStatusFilter && 
               monthMatches && 
               yearMatches && 
               training.department === userDepartment;
      case 'user':
        return matchesStatusFilter && 
               monthMatches && 
               yearMatches && 
               training.userName === JSON.parse(localStorage.getItem('user')).full_name;
      default:
        return false;
    }
  });

  return (
    <Card className="w-full">
      <CardHeader>
        <CardTitle className="text-2xl font-bold text-gray-800">
          Training Approval
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {/* Filters (matching LeaveApprovalTab structure) */}
          <div className="bg-gray-50 p-4 rounded-lg border border-gray-200">
            <div className="flex items-center space-x-3 mb-3">
              <Filter className="w-5 h-5 text-gray-600" />
              <span className="text-sm font-medium text-gray-700">Filter Training Records:</span>
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

          {/* Table */}
          <div className="overflow-x-auto shadow-sm rounded-lg border">
            <Table>
              <TableHeader className="bg-gray-100">
                <TableRow>
                  <TableHead>Course Date</TableHead>
                  <TableHead>Username</TableHead>
                  <TableHead>Department</TableHead>
                  <TableHead>Title</TableHead>
                  <TableHead>Details</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Action</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredTrainings.map((training) => {
                  const isActionDisabled = 
                    userRole === 'department-admin' && training.department !== userDepartment ||
                    userRole === 'user' ||
                    training.status !== 'pending';

                  return (
                    <TableRow key={training.id} className="hover:bg-gray-50 transition-colors">
                      <TableCell>
                        {new Date(training.courseDate).toLocaleDateString('en-GB', {
                          day: '2-digit',
                          month: '2-digit',
                          year: 'numeric'
                        })}
                      </TableCell>                      
                      <TableCell>{training.userName}</TableCell>
                      <TableCell>{training.department}</TableCell>
                      <TableCell>{training.title}</TableCell>
                      <TableCell>
                        <button
                          onClick={() => viewDetails(training)}
                          className="text-blue-600 hover:underline"
                        >
                          View Details
                        </button>
                      </TableCell>
                      <TableCell>
                        <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm ${
                          training.status === 'approved' ? 'bg-green-100 text-green-800 border border-green-200' :
                          training.status === 'rejected' ? 'bg-red-100 text-red-800 border border-red-200' :
                          'bg-yellow-100 text-yellow-800 border border-yellow-200'
                        }`}>
                          {training.status.charAt(0).toUpperCase() + training.status.slice(1)}
                        </span>
                      </TableCell>
                      <TableCell>
                        <select
                          disabled={isActionDisabled}
                          onChange={(e) => handleStatusChange(training.id, e.target.value)}
                          className={`w-[120px] px-2 py-1 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                            isActionDisabled ? 'opacity-50 cursor-not-allowed' : ''
                          }`}
                        >
                          <option value="">Select</option>
                          <option value="approved">Approve</option>
                          <option value="rejected">Reject</option>
                        </select>
                      </TableCell>
                    </TableRow>
                  );
                })}
                {filteredTrainings.length === 0 && (
                  <TableRow>
                    <TableCell colSpan="7" className="text-center py-8 text-gray-500">
                      No training requests found for the selected filters
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </div>
        </div>
      </CardContent>

      <DetailsDialog 
        isOpen={isDialogOpen}
        onClose={handleCloseDialog}
        trainingDetails={selectedTraining}
        certificate={selectedCertificate}
      />
    </Card>
  );
};

export default TrainingApproval;