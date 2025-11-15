import React, { useState, useEffect } from 'react';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { Upload, X } from "lucide-react";
import axios from 'axios';
import './MemoDialog.css';
import { createSOP, updateSOP, fetchDepartment1 } from '../api/documentApi';

const SOPDialog = ({ isOpen, onClose, onSuccess, editDocument }) => {
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [file, setFile] = useState(null);
  const [fileName, setFileName] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [departments, setDepartments] = useState([]);
  const [selectedDepartmentId, setSelectedDepartmentId] = useState('');
  const { toast } = useToast();
  
  useEffect(() => {
    // Fetch departments if user is super-admin
    const user = JSON.parse(localStorage.getItem('user'));
    if (user && user.role === 'super-admin') {
      const loadDepartments = async () => {
        try {
          const departmentsResponse = await fetchDepartment1();
          if (departmentsResponse.success) {
            setDepartments(departmentsResponse.departments);
          }
        } catch (error) {
          toast({
            title: "Error",
            description: "Failed to load departments",
            variant: "destructive",
          });
        }
      };
      loadDepartments();
    }
  }, [isOpen]);

  useEffect(() => {
    const user = JSON.parse(localStorage.getItem('user'));
    if (editDocument) {
      setTitle(editDocument.title);
      setContent(editDocument.content || '');
      setFileName(editDocument.fileName || '');
      
      // If super-admin, set the selected department
      if (user && user.role === 'super-admin') {
        setSelectedDepartmentId(editDocument.departmentId.toString());
      }
    } else {
      resetForm();
    }
  }, [editDocument, isOpen]);

  const resetForm = () => {
    setTitle('');
    setContent('');
    setFile(null);
    setFileName('');
    setSelectedDepartmentId('');
  };

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0];
    if (selectedFile) {
      // File size and type validation (same as before)
      if (selectedFile.size > 25 * 1024 * 1024) {
        toast({
          title: "Error",
          description: "File size must be less than 25MB",
          variant: "destructive",
        });
        return;
      }
      
      const allowedTypes = [
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.ms-powerpoint',
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'image/jpeg',
        'image/png',
        'text/plain',
        'application/zip',
        'application/x-zip-compressed'
      ];
      
      if (!allowedTypes.includes(selectedFile.type)) {
        toast({
          title: "Error",
          description: "Unsupported file type. Please upload a PDF, Word, Excel, PowerPoint, image, text, or ZIP file.",
          variant: "destructive",
        });
        return;
      }
      
      setFile(selectedFile);
      setFileName(selectedFile.name);
    }
  };

  const removeFile = () => {
    setFile(null);
    setFileName('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!content.trim() && !file) {
      toast({
        title: "Error",
        description: "Please provide either content or upload a document",
        variant: "destructive",
      });
      return;
    }
    
    setIsSubmitting(true);
    
    try {
      const user = JSON.parse(localStorage.getItem('user'));
      if (!user) {
        throw new Error('User not found. Please login again.');
      }

      // Determine department ID
      const departmentId = user.role === 'super-admin' 
        ? selectedDepartmentId 
        : user.department_id;

      if (user.role === 'super-admin' && !departmentId) {
        toast({
          title: "Error",
          description: "Please select a department",
          variant: "destructive",
        });
        setIsSubmitting(false);
        return;
      }

      const SOPData = {
        title,
        content,
        file,
        userId: user.id,
        departmentId: departmentId || 0
      };

      let response;
      if (editDocument) {
        response = await updateSOP(editDocument.id, SOPData);
      } else {
        response = await createSOP(SOPData);
      }

      if (response.success) {
        toast({
          title: "Success",
          description: editDocument 
            ? "SOP has been updated successfully" 
            : "SOP has been created successfully",
        });
        resetForm();
        if (onSuccess) {
          onSuccess(response);
        }
        onClose();
      }
    } catch (error) {
      console.error('Error creating/updating SOP:', error);
      const errorMessage = error.response?.data?.message || error.message || `Failed to ${editDocument ? 'update' : 'create'} SOP`;

      toast({
        title: "Error",
        description: errorMessage,
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  // Check if user is super-admin
  const user = JSON.parse(localStorage.getItem('user'));
  const isSuperAdmin = user && user.role === 'super-admin';

  if (!isOpen) return null;

  return (
    <div className="dialog-overlay" onClick={onClose}>
      <div className="dialog-content" onClick={(e) => e.stopPropagation()}>
        <div className="dialog-header">
          <h2>{editDocument ? 'Edit SOP' : 'Create New SOP'}</h2>
        </div>
        <form onSubmit={handleSubmit}>
          <div className="dialog-body">
            <div className="form-group">
              <label htmlFor="title">Title</label>
              <Input
                id="title"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Enter SOP title"
                required
                maxLength={100}
              />
            </div>
            <div className="form-group">
              <label htmlFor="content">Content (Optional)</label>
              <Textarea
                id="content"
                value={content}
                onChange={(e) => setContent(e.target.value)}
                placeholder="Enter SOP content"
                className="h-32"
                maxLength={2000}
              />
            </div>
            {isSuperAdmin && (
              <div className="form-group">
                <label htmlFor="department">Department</label>
                <select
                  id="department"
                  value={selectedDepartmentId}
                  onChange={(e) => setSelectedDepartmentId(e.target.value)}
                  required
                  className="w-full p-2 border rounded"
                >
                  <option value="">Select Department</option>
                  {departments.map((dept) => (
                    <option 
                      key={dept.id} 
                      value={dept.id.toString()}
                    >
                      {dept.name}
                    </option>
                  ))}
                </select>
              </div>
            )}
            <div className="form-group">
              <label htmlFor="file">Attachment (Optional)</label>
              <div className="file-upload-container">
                {fileName ? (
                  <div className="file-info">
                    <span>{fileName}</span>
                    <button
                      type="button"
                      onClick={removeFile}
                      className="remove-file"
                    >
                      <X className="h-4 w-4" />
                    </button>
                  </div>
                ) : (
                  <div className="upload-button-container">
                    <input
                      type="file"
                      id="file"
                      accept=".pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.jpg,.jpeg,.png,.txt,.zip"
                      onChange={handleFileChange}
                      className="hidden"
                    />
                    <Button
                      type="button"
                      variant="outline"
                      className="upload-button"
                      onClick={() => document.getElementById('file').click()}
                    >
                      <Upload className="upload-icon" />
                      Upload File
                    </Button>
                  </div>
                )}
              </div>
            </div>
          </div>
          <div className="dialog-footer">
            <Button 
              type="button" 
              variant="outline" 
              onClick={() => {
                resetForm();
                onClose();
              }}
            >
              Cancel
            </Button>
            <Button 
              type="submit" 
              disabled={
                isSubmitting || 
                !title.trim() || 
                (!content.trim() && !file) || 
                (isSuperAdmin && !selectedDepartmentId)
              }
            >
              {isSubmitting ? "Saving..." : (editDocument ? "Update" : "Save")}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default SOPDialog;