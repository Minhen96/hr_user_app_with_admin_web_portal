import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Search, Filter, X, FileText, Calendar, User, Tag,
  AlertTriangle, CheckCircle, Download, RefreshCw, Grid, List
} from 'lucide-react';
import apiClient from '../../../core/api/client';
import { GlassCard, GlassCardContent, GlassCardHeader, GlassCardTitle } from '../../../components/modern/GlassCard';
import { GradientButton, IconButton } from '../../../components/modern/GradientButton';
import { ModernBadge } from '../../../components/modern/ModernBadge';
import { ModernInput, ModernSelect } from '../../../components/modern/ModernInput';
import jsPDF from 'jspdf';

// Equipment Request Card Component
const EquipmentRequestCard = ({ request, onClick, index }) => {
  const getStatusVariant = (status) => {
    const statusLower = status?.toLowerCase();
    if (statusLower === 'active') return 'success';
    if (statusLower === 'inactive') return 'error';
    if (statusLower === 'pending') return 'warning';
    return 'default';
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric'
    });
  };

  return (
    <GlassCard
      hover
      onClick={onClick}
      animate
      delay={index * 0.05}
      className="cursor-pointer"
    >
      <div className="flex flex-col gap-4">
        {/* Header */}
        <div className="flex items-start justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-lg gradient-purple">
              <Tag className="w-5 h-5 text-white" />
            </div>
            <div>
              <h3 className="font-semibold text-text-primary dark:text-white text-base">
                {request.productCode || 'N/A'}
              </h3>
              <p className="text-sm text-text-secondary mt-0.5">
                {request.department || 'Unknown'}
              </p>
            </div>
          </div>
          <ModernBadge variant={getStatusVariant(request.activeStatus)} size="sm">
            {request.activeStatus || 'N/A'}
          </ModernBadge>
        </div>

        {/* Details Grid */}
        <div className="grid grid-cols-2 gap-3">
          <div className="flex items-center gap-2">
            <User className="w-4 h-4 text-primary-purple" />
            <div className="min-w-0">
              <p className="text-xs text-text-hint">Requester</p>
              <p className="text-sm font-medium text-text-primary dark:text-white truncate">
                {request.requesterName}
              </p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <Calendar className="w-4 h-4 text-secondary-cyan" />
            <div className="min-w-0">
              <p className="text-xs text-text-hint">Date</p>
              <p className="text-sm font-medium text-text-primary dark:text-white">
                {formatDate(request.dateRequested)}
              </p>
            </div>
          </div>
        </div>

        {/* Reason */}
        <div className="pt-3 border-t border-border">
          <p className="text-xs text-text-hint mb-1">Reason</p>
          <p className="text-sm text-text-secondary line-clamp-2">
            {request.reason || 'No reason provided'}
          </p>
        </div>
      </div>
    </GlassCard>
  );
};

// Equipment Request Details Dialog
const EquipmentDetailsDialog = ({ isOpen, onClose, request }) => {
  if (!isOpen || !request) return null;

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  const handleDownloadPDF = () => {
    const doc = new jsPDF('portrait', 'mm', 'a4');

    doc.setFont('helvetica');
    doc.setFontSize(18);
    doc.text('Change Request Form (CRF)', 150, 20, { align: 'right' });

    doc.setFontSize(12);
    let yPosition = 30;
    const startX = 20;
    const cellWidth = 50;
    const valueWidth = 130;
    const cellHeight = 10;

    const addRowWithBorder = (label, value, boldLabel = false) => {
      doc.rect(startX, yPosition, cellWidth, cellHeight);
      doc.rect(startX + cellWidth, yPosition, valueWidth, cellHeight);

      if (boldLabel) {
        doc.setFont('helvetica', 'bold');
      } else {
        doc.setFont('helvetica', 'normal');
      }

      doc.text(label, startX + 2, yPosition + 7);
      doc.setFont('helvetica', 'normal');

      const splitText = doc.splitTextToSize(value || 'N/A', valueWidth - 5);
      splitText.forEach((line, index) => {
        doc.text(line, startX + cellWidth + 2, yPosition + 7 + index * 4);
      });

      yPosition += Math.max(cellHeight, splitText.length * 4);
    };

    addRowWithBorder('REF.NO', request.id.toString(), true);
    addRowWithBorder('REQUESTOR', request.requesterName, true);
    addRowWithBorder('DEPARTMENT', request.department, true);
    addRowWithBorder('DATE', formatDate(request.dateRequested), true);
    addRowWithBorder('REASON', request.reason, true);
    addRowWithBorder('DESCRIPTION', request.description, true);
    addRowWithBorder('RISK', request.risk, true);
    addRowWithBorder('INSTRUCTIONS', request.instruction, true);
    addRowWithBorder('COMPLETION DATE', formatDate(request.completeDate), true);
    addRowWithBorder('POST REVIEW', request.postReview, true);

    doc.setFontSize(10);
    doc.text('Document No: ISMS-P09-F01', startX, 280, { align: 'left' });

    doc.save(`Change_Request_${request.id}_Report.pdf`);
  };

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4"
        onClick={onClose}
      >
        <motion.div
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          exit={{ scale: 0.9, opacity: 0 }}
          transition={{ type: 'spring', duration: 0.3 }}
          className="w-full max-w-4xl max-h-[90vh] overflow-hidden"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="glass-card rounded-2xl overflow-hidden">
            {/* Header */}
            <div className="gradient-purple p-6">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <FileText className="w-6 h-6 text-white" />
                  <h2 className="text-2xl font-bold text-white">Equipment Request Details</h2>
                </div>
                <IconButton
                  icon={<X className="w-5 h-5" />}
                  onClick={onClose}
                  variant="purple"
                  className="bg-white/20 hover:bg-white/30 text-white"
                />
              </div>
            </div>

            {/* Content */}
            <div className="p-6 overflow-y-auto max-h-[calc(90vh-200px)] bg-background">
              <div className="grid md:grid-cols-2 gap-4 mb-6">
                <DetailItem
                  icon={<Tag className="w-5 h-5 text-primary-purple" />}
                  label="Product Code"
                  value={request.productCode || 'N/A'}
                />
                <DetailItem
                  icon={<User className="w-5 h-5 text-success" />}
                  label="Requester"
                  value={request.requesterName}
                />
                <DetailItem
                  icon={<Calendar className="w-5 h-5 text-secondary-cyan" />}
                  label="Request Date"
                  value={formatDate(request.dateRequested)}
                />
                <DetailItem
                  icon={<Calendar className="w-5 h-5 text-accent-pink" />}
                  label="Complete Date"
                  value={formatDate(request.completeDate)}
                />
              </div>

              <div className="space-y-4">
                <DetailSection
                  title="Description"
                  icon={<FileText className="w-5 h-5 text-info" />}
                  content={request.description || 'No description provided'}
                />
                <DetailSection
                  title="Reason"
                  icon={<AlertTriangle className="w-5 h-5 text-warning" />}
                  content={request.reason || 'No reason specified'}
                />
                {request.risk && (
                  <DetailSection
                    title="Risk Assessment"
                    icon={<AlertTriangle className="w-5 h-5 text-error" />}
                    content={request.risk}
                  />
                )}
                {request.instruction && (
                  <DetailSection
                    title="Instructions"
                    icon={<CheckCircle className="w-5 h-5 text-success" />}
                    content={request.instruction}
                  />
                )}
                {request.postReview && (
                  <DetailSection
                    title="Post Review"
                    icon={<FileText className="w-5 h-5 text-primary-purple" />}
                    content={request.postReview}
                  />
                )}
              </div>

              {request.approverName && (
                <div className="mt-6 glass-card p-4 rounded-xl">
                  <div className="flex items-center gap-3">
                    <div className="p-3 gradient-success rounded-full">
                      <CheckCircle className="w-6 h-6 text-white" />
                    </div>
                    <div>
                      <p className="text-sm text-text-hint">Approved By</p>
                      <p className="font-semibold text-text-primary dark:text-white">
                        {request.approverName}
                      </p>
                      <p className="text-sm text-text-secondary">
                        {formatDate(request.dateApproved)}
                      </p>
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Footer */}
            <div className="p-6 border-t border-border bg-surface dark:bg-surface-variant flex gap-3 justify-end">
              <GradientButton variant="outline" onClick={onClose}>
                Close
              </GradientButton>
              <GradientButton
                variant="purple"
                icon={<Download />}
                onClick={handleDownloadPDF}
              >
                Download PDF
              </GradientButton>
            </div>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
};

const DetailItem = ({ icon, label, value }) => (
  <div className="flex items-start gap-3 glass-card p-4 rounded-lg">
    <div className="p-2 bg-surface dark:bg-surface-variant rounded-lg">
      {icon}
    </div>
    <div className="min-w-0">
      <p className="text-xs text-text-hint uppercase tracking-wider mb-1">{label}</p>
      <p className="font-medium text-text-primary dark:text-white break-words">{value}</p>
    </div>
  </div>
);

const DetailSection = ({ title, icon, content }) => (
  <div className="glass-card p-4 rounded-xl">
    <div className="flex items-center gap-3 mb-3">
      <div className="p-2 bg-surface dark:bg-surface-variant rounded-lg">
        {icon}
      </div>
      <h3 className="font-semibold text-text-primary dark:text-white">{title}</h3>
    </div>
    <p className="text-text-secondary leading-relaxed">{content}</p>
  </div>
);

// Main Equipment Page Component
const EquipmentPage = () => {
  const [changeRequests, setChangeRequests] = useState([]);
  const [selectedRequest, setSelectedRequest] = useState(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [viewMode, setViewMode] = useState('grid'); // 'grid' or 'list'

  // Filter states
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedStatus, setSelectedStatus] = useState('all');
  const [selectedDepartment, setSelectedDepartment] = useState('all');
  const [showFilters, setShowFilters] = useState(false);

  const [loading, setLoading] = useState(true);
  const [departments, setDepartments] = useState([]);

  useEffect(() => {
    fetchChangeRequests();
  }, []);

  useEffect(() => {
    if (changeRequests.length > 0) {
      const uniqueDepartments = [...new Set(changeRequests.map(req => req.department))];
      setDepartments(uniqueDepartments);
    }
  }, [changeRequests]);

  const fetchChangeRequests = async () => {
    setLoading(true);
    try {
      const response = await apiClient.get(`/changeRequests/brief`);
      const requestsWithProductCode = response.data.map(request => ({
        ...request,
        productCode: request.productCode || 'N/A'
      }));
      setChangeRequests(requestsWithProductCode);
    } catch (error) {
      console.error('Error fetching change requests:', error);
      setChangeRequests([]);
    } finally {
      setLoading(false);
    }
  };

  const handleViewDetails = async (request) => {
    try {
      const response = await apiClient.get(`/changeRequests/${request.id}/details`);
      setSelectedRequest({
        ...request,
        ...response.data
      });
      setIsDialogOpen(true);
    } catch (error) {
      console.error('Error fetching request details:', error);
    }
  };

  const handleReset = () => {
    setSearchTerm('');
    setSelectedStatus('all');
    setSelectedDepartment('all');
  };

  const filteredRequests = changeRequests.filter(request => {
    const matchesSearch =
      request.productCode?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      request.requesterName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      request.reason?.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = selectedStatus === 'all' || request.activeStatus === selectedStatus;
    const matchesDepartment = selectedDepartment === 'all' || request.department === selectedDepartment;
    return matchesSearch && matchesStatus && matchesDepartment;
  });

  const statuses = [...new Set(changeRequests.map(req => req.activeStatus).filter(Boolean))];

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold text-text-primary dark:text-white">
            Equipment Requests
          </h1>
          <p className="text-text-secondary mt-1">
            Manage and track equipment change requests
          </p>
        </div>
        <div className="flex items-center gap-3">
          <IconButton
            icon={<RefreshCw className={loading ? 'animate-spin' : ''} />}
            onClick={fetchChangeRequests}
            variant="purple"
          />
          <div className="flex items-center gap-2 glass-card p-1 rounded-lg">
            <IconButton
              icon={<Grid className="w-4 h-4" />}
              onClick={() => setViewMode('grid')}
              variant={viewMode === 'grid' ? 'purple' : 'cyan'}
              size="sm"
            />
            <IconButton
              icon={<List className="w-4 h-4" />}
              onClick={() => setViewMode('list')}
              variant={viewMode === 'list' ? 'purple' : 'cyan'}
              size="sm"
            />
          </div>
        </div>
      </div>

      {/* Filters */}
      <GlassCard>
        <GlassCardContent className="p-0">
          {/* Filter Toggle Button */}
          <div className="p-4 flex justify-between items-center border-b border-border">
            <div className="flex items-center gap-2">
              <Filter className="w-5 h-5 text-primary-purple" />
              <span className="font-semibold text-text-primary dark:text-white">Filters</span>
              {(searchTerm || selectedStatus !== 'all' || selectedDepartment !== 'all') && (
                <ModernBadge variant="purple" size="sm">Active</ModernBadge>
              )}
            </div>
            <IconButton
              icon={showFilters ? <X /> : <Filter />}
              onClick={() => setShowFilters(!showFilters)}
              variant="purple"
              size="sm"
            />
          </div>

          {/* Filter Content */}
          <AnimatePresence>
            {showFilters && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: 'auto', opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                transition={{ duration: 0.3 }}
                className="overflow-hidden"
              >
                <div className="p-4 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                  <ModernInput
                    placeholder="Search..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    icon={<Search className="w-4 h-4" />}
                    containerClassName="sm:col-span-2"
                  />
                  <ModernSelect
                    value={selectedDepartment}
                    onChange={(e) => setSelectedDepartment(e.target.value)}
                    options={[
                      { value: 'all', label: 'All Departments' },
                      ...departments.map(dept => ({ value: dept, label: dept }))
                    ]}
                  />
                  <ModernSelect
                    value={selectedStatus}
                    onChange={(e) => setSelectedStatus(e.target.value)}
                    options={[
                      { value: 'all', label: 'All Statuses' },
                      ...statuses.map(status => ({ value: status, label: status }))
                    ]}
                  />
                </div>
                <div className="px-4 pb-4">
                  <GradientButton variant="outline" onClick={handleReset} fullWidth>
                    Reset Filters
                  </GradientButton>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </GlassCardContent>
      </GlassCard>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <GlassCard gradient gradientType="purple">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-white/80 text-sm">Total Requests</p>
              <p className="text-3xl font-bold text-white mt-1">{changeRequests.length}</p>
            </div>
            <FileText className="w-12 h-12 text-white/50" />
          </div>
        </GlassCard>
        <GlassCard gradient gradientType="success">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-white/80 text-sm">Active</p>
              <p className="text-3xl font-bold text-white mt-1">
                {changeRequests.filter(r => r.activeStatus?.toLowerCase() === 'active').length}
              </p>
            </div>
            <CheckCircle className="w-12 h-12 text-white/50" />
          </div>
        </GlassCard>
        <GlassCard gradient gradientType="cyan">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-white/80 text-sm">Filtered</p>
              <p className="text-3xl font-bold text-white mt-1">{filteredRequests.length}</p>
            </div>
            <Filter className="w-12 h-12 text-white/50" />
          </div>
        </GlassCard>
      </div>

      {/* Requests Grid/List */}
      {loading ? (
        <div className="flex justify-center items-center py-20">
          <div className="w-16 h-16 border-4 border-primary-purple/30 border-t-primary-purple rounded-full animate-spin" />
        </div>
      ) : filteredRequests.length === 0 ? (
        <GlassCard>
          <div className="text-center py-20">
            <AlertTriangle className="w-16 h-16 text-text-hint mx-auto mb-4" />
            <p className="text-text-secondary text-lg">No requests found</p>
          </div>
        </GlassCard>
      ) : (
        <div className={viewMode === 'grid'
          ? 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4'
          : 'flex flex-col gap-4'
        }>
          {filteredRequests.map((request, index) => (
            <EquipmentRequestCard
              key={request.id}
              request={request}
              onClick={() => handleViewDetails(request)}
              index={index}
            />
          ))}
        </div>
      )}

      {/* Details Dialog */}
      <EquipmentDetailsDialog
        isOpen={isDialogOpen}
        onClose={() => setIsDialogOpen(false)}
        request={selectedRequest}
      />
    </div>
  );
};

export default EquipmentPage;
