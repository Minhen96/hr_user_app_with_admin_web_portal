import React, { useState, useEffect } from 'react';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { useToast } from "@/hooks/use-toast";
import { Upload, X } from "lucide-react";
import axios from 'axios';
import './MemoDialog.css';
import { createPolicy, updatePolicy } from '../api/documentApi';

const PolicyDialog = ({ isOpen, onClose, onSuccess, editDocument }) => {
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [file, setFile] = useState(null);
  const [fileName, setFileName] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const { toast } = useToast();
  
  useEffect(() => {
    if (editDocument) {
      setTitle(editDocument.title);
      setContent(editDocument.content || '');
      setFileName(editDocument.fileName || '');
    } else {
      resetForm();
    }
  }, [editDocument, isOpen]);

  const resetForm = () => {
    setTitle('');
    setContent('');
    setFile(null);
    setFileName('');
  };

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0];
    if (selectedFile) {
      // Add file size validation (e.g., 25MB limit)
      if (selectedFile.size > 25 * 1024 * 1024) {
        toast({
          title: "Error",
          description: "File size must be less than 25MB",
          variant: "destructive",
        });
        return;
      }
      
      // Allowed file types
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

      const policyData = {
        title,
        content,
        file,
        userId: user.id,
        departmentId: user.departmentId || user.department_id || 0
      };

      let response;
      if (editDocument) {
        response = await updatePolicy(editDocument.id, policyData);
      } else {
        response = await createPolicy(policyData);
      }

      if (response.success) {
        toast({
          title: "Success",
          description: editDocument 
            ? "Policy has been updated successfully" 
            : "policy has been created successfully",
        });
        resetForm();
        if (onSuccess) {
          onSuccess(response);
        }
        onClose();
      }
    } catch (error) {
      console.error('Error creating/updating policy:', error);
      const errorMessage = error.response?.data?.message || error.message || `Failed to ${editDocument ? 'update' : 'create'} policy`;

      toast({
        title: "Error",
        description: errorMessage,
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="dialog-overlay" onClick={onClose}>
      <div className="dialog-content" onClick={(e) => e.stopPropagation()}>
        <div className="dialog-header">
          <h2>{editDocument ? 'Edit Policy' : 'Create New Policy'}</h2>
        </div>
        <form onSubmit={handleSubmit}>
          <div className="dialog-body">
            <div className="form-group">
              <label htmlFor="title">Title</label>
              <Input
                id="title"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Enter Policy title"
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
                placeholder="Enter policy content"
                className="h-32"
                maxLength={2000}
              />
            </div>
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
              disabled={isSubmitting || !title.trim() || (!content.trim() && !file)}
            >
              {isSubmitting ? "Saving..." : (editDocument ? "Update" : "Save")}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default PolicyDialog;