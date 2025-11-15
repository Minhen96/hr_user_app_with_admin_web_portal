import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import MemoDialog from "../components/MemoDialog";
import SOPDialog from '../components/SOPDialog';
import HandbookDialog from '../components/HandbookDialog';
import PolicyDialog from '../components/PolicyDialog';
import UpdatesDialog from '../components/UpdatesDialog';
import * as documentApi from '../api/documentApi';
import { useToast } from "@/hooks/use-toast";
import {
  CheckCircle, Pencil, Trash2, Download, FileText, Folder,
  BookOpen, Shield, List, Plus, ChevronDown, ChevronUp, User, Calendar
} from "lucide-react";
import { GlassCard } from '../../../components/modern/GlassCard';
import { GradientButton, IconButton } from '../../../components/modern/GradientButton';
import { ModernBadge } from '../../../components/modern/ModernBadge';

// Modern Document Card Component
const ModernDocumentCard = ({ document: docData, isOwnPost, onEdit, onDelete, activeTab, index }) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const { toast } = useToast();
  const showActions = activeTab === 'ALL_POSTED' && isOwnPost;

  const handleDownload = async (docId) => {
    try {
      await documentApi.downloadDocument(docId, docData.title, activeTab);
      toast({
        title: "Success",
        description: "Document downloaded successfully",
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to download document",
        variant: "destructive",
      });
    }
  };

  const hasContent = docData.content && docData.content.trim().length > 0;
  const hasFile = docData.hasUpload;

  const getTabConfig = () => {
    const configs = {
      MEMO: {
        icon: <FileText className="w-5 h-5" />,
        gradient: 'gradient-cyan',
        color: 'text-secondary-cyan'
      },
      SOP: {
        icon: <Folder className="w-5 h-5" />,
        gradient: 'gradient-success',
        color: 'text-success'
      },
      HANDBOOK: {
        icon: <BookOpen className="w-5 h-5" />,
        gradient: 'gradient-purple',
        color: 'text-primary-purple'
      },
      POLICY: {
        icon: <Shield className="w-5 h-5" />,
        gradient: 'gradient-pink',
        color: 'text-accent-pink'
      },
      UPDATES: {
        icon: <CheckCircle className="w-5 h-5" />,
        gradient: 'gradient-warning',
        color: 'text-warning'
      },
    };
    return configs[activeTab] || configs.MEMO;
  };

  const config = getTabConfig();

  return (
    <GlassCard animate delay={index * 0.05} className="overflow-hidden">
      <div className={`p-4 ${config.gradient}`}>
        <div className="flex items-center gap-3 text-white">
          <div className="p-2 bg-white/20 rounded-lg backdrop-blur-sm">
            {config.icon}
          </div>
          <div className="flex-1 min-w-0">
            <h3 className="font-semibold text-lg truncate">{docData.title}</h3>
            <p className="text-white/80 text-sm">{docData.type || activeTab}</p>
          </div>
          {hasFile && (
            <ModernBadge variant="outline" size="sm" className="border-white/50 text-white">
              File Attached
            </ModernBadge>
          )}
        </div>
      </div>

      <div className="p-4">
        {/* Meta Information */}
        <div className="grid grid-cols-2 gap-3 mb-4">
          <div className="flex items-center gap-2">
            <User className={`w-4 h-4 ${config.color}`} />
            <div>
              <p className="text-xs text-text-hint">Author</p>
              <p className="text-sm font-medium text-text-primary dark:text-white truncate">
                {docData.authorName}
              </p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <Calendar className={`w-4 h-4 ${config.color}`} />
            <div>
              <p className="text-xs text-text-hint">Posted</p>
              <p className="text-sm font-medium text-text-primary dark:text-white">
                {docData.postDate}
              </p>
            </div>
          </div>
        </div>

        {/* Content Preview */}
        {hasContent && (
          <div className="mb-4">
            <button
              onClick={() => setIsExpanded(!isExpanded)}
              className="w-full text-left flex items-center justify-between p-3 bg-surface dark:bg-surface-variant rounded-lg hover:bg-surface-variant dark:hover:bg-slate-600 transition-colors"
            >
              <span className="text-sm font-medium text-text-primary dark:text-white">
                View Content
              </span>
              {isExpanded ? (
                <ChevronUp className="w-4 h-4 text-text-hint" />
              ) : (
                <ChevronDown className="w-4 h-4 text-text-hint" />
              )}
            </button>

            <AnimatePresence>
              {isExpanded && (
                <motion.div
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: 'auto', opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  transition={{ duration: 0.3 }}
                  className="overflow-hidden"
                >
                  <div className="mt-3 p-4 bg-surface dark:bg-surface-variant rounded-lg">
                    <p className="text-sm text-text-secondary whitespace-pre-wrap">
                      {docData.content}
                    </p>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        )}

        {/* Actions */}
        <div className="flex gap-2">
          {hasFile && (
            <GradientButton
              variant="purple"
              size="sm"
              icon={<Download className="w-4 h-4" />}
              onClick={() => handleDownload(docData.id)}
              className="flex-1"
            >
              Download
            </GradientButton>
          )}
          {showActions && (
            <>
              <IconButton
                icon={<Pencil className="w-4 h-4" />}
                onClick={() => onEdit(docData)}
                variant="cyan"
              />
              <IconButton
                icon={<Trash2 className="w-4 h-4" />}
                onClick={() => onDelete(docData.id)}
                variant="error"
              />
            </>
          )}
        </div>
      </div>
    </GlassCard>
  );
};

// Document List Component
const DocumentList = ({ documents, isOwnPost, onEdit, onDelete, activeTab }) => {
  if (activeTab === 'ALL_POSTED') {
    const groupedDocuments = documents.reduce((acc, doc) => {
      if (!acc[doc.type]) acc[doc.type] = [];
      acc[doc.type].push(doc);
      return acc;
    }, {});

    return (
      <div className="space-y-8">
        {Object.entries(groupedDocuments).map(([type, docs]) => (
          <div key={type}>
            <h3 className="text-xl font-semibold text-text-primary dark:text-white mb-4 flex items-center gap-2">
              <span className="w-1 h-6 gradient-purple rounded-full"></span>
              {type}
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {docs.map((doc, index) => (
                <ModernDocumentCard
                  key={doc.id}
                  document={doc}
                  isOwnPost={isOwnPost}
                  onEdit={onEdit}
                  onDelete={onDelete}
                  activeTab={type.toUpperCase()}
                  index={index}
                />
              ))}
            </div>
          </div>
        ))}
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {documents.map((doc, index) => (
        <ModernDocumentCard
          key={doc.id}
          document={doc}
          isOwnPost={isOwnPost}
          onEdit={onEdit}
          onDelete={onDelete}
          activeTab={activeTab}
          index={index}
        />
      ))}
    </div>
  );
};

// Modern Pill Tab Component
const PillTab = ({ tab, isActive, onClick }) => {
  const Icon = tab.icon;

  return (
    <motion.button
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
      className={`
        flex items-center gap-2 px-4 py-2.5 rounded-full transition-all font-medium
        whitespace-nowrap
        ${isActive
          ? 'gradient-purple text-white shadow-glow-purple'
          : 'glass-card hover:bg-surface dark:hover:bg-surface-variant text-text-primary dark:text-white'
        }
      `}
      onClick={onClick}
    >
      <Icon className={`w-4 h-4 ${isActive ? 'text-white' : 'text-text-hint'}`} />
      <span>{tab.label}</span>
    </motion.button>
  );
};

// Main Document Page Component
const DocumentPage = () => {
  const [isMemoDialogOpen, setIsMemoDialogOpen] = useState(false);
  const [isSOPDialogOpen, setIsSOPDialogOpen] = useState(false);
  const [isHandbookDialogOpen, setIsHandbookDialogOpen] = useState(false);
  const [isPolicyDialogOpen, setIsPolicyDialogOpen] = useState(false);
  const [isUpdatesDialogOpen, setIsUpdatesDialogOpen] = useState(false);
  const [activeTab, setActiveTab] = useState('MEMO');
  const [documents, setDocuments] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [editingDocument, setEditingDocument] = useState(null);
  const { toast } = useToast();

  const tabItems = [
    { key: 'MEMO', label: 'Memo', icon: FileText },
    { key: 'SOP', label: 'SOP', icon: Folder },
    { key: 'HANDBOOK', label: 'Handbook', icon: BookOpen },
    { key: 'POLICY', label: 'ISMS Policy', icon: Shield },
    { key: 'UPDATES', label: 'Updates', icon: CheckCircle },
    { key: 'ALL_POSTED', label: 'My Posts', icon: List }
  ];

  const user = JSON.parse(localStorage.getItem('user'));

  const fetchDocumentsData = async () => {
    setIsLoading(true);
    try {
      if (!user) {
        throw new Error('User not found');
      }
      const docs = await documentApi.fetchDocuments(activeTab, user.id);
      setDocuments(docs);
    } catch (error) {
      toast({
        title: "Error",
        description: error.message || "Failed to fetch documents",
        variant: "destructive",
      });
      setDocuments([]);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (activeTab !== 'HANDBOOK') {
      fetchDocumentsData();
    }
  }, [activeTab]);

  const handleTabClick = (tabKey) => {
    setActiveTab(tabKey);
    setEditingDocument(null);
  };

  const handleEdit = (document) => {
    setEditingDocument(document);
    switch (activeTab) {
      case 'MEMO':
        setIsMemoDialogOpen(true);
        break;
      case 'SOP':
        setIsSOPDialogOpen(true);
        break;
      case 'POLICY':
        setIsPolicyDialogOpen(true);
        break;
      case 'UPDATES':
        setIsUpdatesDialogOpen(true);
        break;
    }
  };

  const handleDelete = async (documentId) => {
    if (window.confirm('Are you sure you want to delete this document?')) {
      try {
        await documentApi.deleteDocument(documentId, activeTab);
        toast({
          title: "Success",
          description: "Document deleted successfully",
        });
        fetchDocumentsData();
      } catch (error) {
        toast({
          title: "Error",
          description: error.message || "Failed to delete document",
          variant: "destructive",
        });
      }
    }
  };

  const handleSuccess = () => {
    setEditingDocument(null);
    fetchDocumentsData();
  };

  const openDialog = () => {
    switch (activeTab) {
      case 'MEMO':
        setIsMemoDialogOpen(true);
        break;
      case 'SOP':
        setIsSOPDialogOpen(true);
        break;
      case 'HANDBOOK':
        setIsHandbookDialogOpen(true);
        break;
      case 'POLICY':
        setIsPolicyDialogOpen(true);
        break;
      case 'UPDATES':
        setIsUpdatesDialogOpen(true);
        break;
    }
  };

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold text-text-primary dark:text-white">
            Documents
          </h1>
          <p className="text-text-secondary mt-1">
            Browse and manage company documents
          </p>
        </div>
        {activeTab !== 'ALL_POSTED' && activeTab !== 'HANDBOOK' &&
         (user?.role === 'super-admin' || user?.role === 'department-admin') && (
          <GradientButton
            variant="purple"
            icon={<Plus />}
            onClick={openDialog}
          >
            Add {activeTab.toLowerCase()}
          </GradientButton>
        )}
      </div>

      {/* Pill Tabs */}
      <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
        {tabItems.map((tab) => (
          <PillTab
            key={tab.key}
            tab={tab}
            isActive={activeTab === tab.key}
            onClick={() => handleTabClick(tab.key)}
          />
        ))}
      </div>

      {/* Content Area */}
      <div>
        {activeTab === 'HANDBOOK' ? (
          <HandbookDialog isVisible={true} />
        ) : (
          <AnimatePresence mode="wait">
            {isLoading ? (
              <motion.div
                key="loading"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                className="flex flex-col items-center justify-center py-20"
              >
                <div className="w-16 h-16 border-4 border-primary-purple/30 border-t-primary-purple rounded-full animate-spin mb-4" />
                <p className="text-text-secondary">Loading documents...</p>
              </motion.div>
            ) : documents.length > 0 ? (
              <motion.div
                key="content"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                transition={{ duration: 0.3 }}
              >
                <DocumentList
                  documents={documents}
                  isOwnPost={activeTab === 'ALL_POSTED' || user?.id}
                  onEdit={handleEdit}
                  onDelete={handleDelete}
                  activeTab={activeTab}
                />
              </motion.div>
            ) : (
              <motion.div
                key="empty"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
              >
                <GlassCard>
                  <div className="flex flex-col items-center justify-center py-20">
                    <FileText className="w-16 h-16 text-text-hint mb-4" />
                    <p className="text-text-secondary text-lg">
                      No {activeTab === 'ALL_POSTED' ? '' : activeTab.toLowerCase()} documents found
                    </p>
                  </div>
                </GlassCard>
              </motion.div>
            )}
          </AnimatePresence>
        )}
      </div>

      {/* Dialogs */}
      <MemoDialog
        isOpen={isMemoDialogOpen}
        onClose={() => {
          setIsMemoDialogOpen(false);
          setEditingDocument(null);
        }}
        onSuccess={handleSuccess}
        editDocument={editingDocument}
      />
      <SOPDialog
        isOpen={isSOPDialogOpen}
        onClose={() => {
          setIsSOPDialogOpen(false);
          setEditingDocument(null);
        }}
        onSuccess={handleSuccess}
        editDocument={editingDocument}
      />
      <PolicyDialog
        isOpen={isPolicyDialogOpen}
        onClose={() => {
          setIsPolicyDialogOpen(false);
          setEditingDocument(null);
        }}
        onSuccess={handleSuccess}
        editDocument={editingDocument}
      />
      <UpdatesDialog
        isOpen={isUpdatesDialogOpen}
        onClose={() => {
          setIsUpdatesDialogOpen(false);
          setEditingDocument(null);
        }}
        onSuccess={handleSuccess}
        editDocument={editingDocument}
      />
    </div>
  );
};

export default DocumentPage;
