import React, { useState, useEffect, useRef } from 'react';
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { useToast } from "@/hooks/use-toast";
import { Pencil, Trash2, Plus, FileDown, X, Menu } from "lucide-react";
import axios from 'axios';
import "./HandbookDialog.css";
import jsPDF from 'jspdf';
import { NavLink } from 'react-router-dom';
import { 
  fetchHandbookSections, 
  fetchHandbookImage, 
  addHandbookSection,
  deleteHandbookSection,
  addHandbookContent,
  updateHandbookContent,
  deleteHandbookContent
} from '../api/documentApi';

const HandbookDialog = ({ isVisible, onClose }) => {
  const [sections, setSections] = useState([]);
  const [showAddSection, setShowAddSection] = useState(false);
  const [showAddContent, setShowAddContent] = useState(false);
  const [newSectionTitle, setNewSectionTitle] = useState('');
  const [selectedSection, setSelectedSection] = useState(null);
  const [editingContent, setEditingContent] = useState(null);
  const [newContent, setNewContent] = useState({ subtitle: '', content: '' });
  const [headerImage, setHeaderImage] = useState(null);
  const [footerImage, setFooterImage] = useState(null);
  const [notification, setNotification] = useState(null);

  useEffect(() => {
    fetchSections();
    fetchImages();
  }, []);

  const toast = (options) => {
    setNotification({
      title: options.title,
      description: options.description,
      variant: options.variant || 'success'
    });
    setTimeout(() => setNotification(null), 3000);
  };

  const fetchImages = async () => {
    try {
      const headerImageData = await fetchHandbookImage('HEADER');
      setHeaderImage(headerImageData.imageData);
      
      const footerImageData = await fetchHandbookImage('FOOTER');
      setFooterImage(footerImageData.imageData);
    } catch (error) {
      console.error('Error fetching images:', error);
    }
  };
  
  

  const generatePDF = async () => {
    const pdf = new jsPDF('p', 'mm', 'a4');
    const pdfWidth = pdf.internal.pageSize.getWidth();
    const pdfHeight = pdf.internal.pageSize.getHeight();
    const margin = 15; // Increased top margin
    const contentWidth = pdfWidth - (2 * margin);
  
    // Helper function to check and add new page if needed
    const checkAndAddNewPage = (requiredSpace) => {
      if (yPosition + requiredSpace > pdfHeight - margin) {
        pdf.addPage();
        yPosition = margin; // Reset to top margin when adding a new page
        return true;
      }
      return false;
    };
  
    // Helper function to draw table cell
    const drawTableCell = (text, x, width, height, isHeader = false) => {
      // Draw cell border
      pdf.setDrawColor(0, 0, 0);
      pdf.setLineWidth(0.1);
      pdf.rect(x, yPosition - 5, width, height);
  
      // Set text style
      pdf.setFontSize(isHeader ? 11 : 10);
      pdf.setFont(undefined, isHeader ? 'bold' : 'normal');
      
      // Calculate maximum width for text
      const maxWidth = width - 4;
      const lines = pdf.splitTextToSize(text || '', maxWidth);
      
      // Draw text
      pdf.text(lines, x + 2, yPosition);
      
      return Math.max(lines.length * (isHeader ? 6 : 5), height);
    };
  
    // Add title
    let yPosition = margin; // Start from top margin
    pdf.setFontSize(18);
    pdf.setFont(undefined, 'bold');
    pdf.text('Company Handbook', pdfWidth / 2, yPosition, { align: 'center' });
    yPosition += 15;
  
    // Process each section
    for (const section of sections) {
      checkAndAddNewPage(20);
  
      // Add section title
      pdf.setFontSize(14);
      pdf.setFont(undefined, 'bold');
      pdf.setTextColor(44, 62, 80); // Dark blue color
      pdf.text(section.title, margin, yPosition);
      yPosition += 15;
  
      // Add table headers
      const subtitleWidth = 50;
      const contentWidth = pdfWidth - (2 * margin) - subtitleWidth;
      
      checkAndAddNewPage(15);
      pdf.setTextColor(0);
      const headerHeight = drawTableCell('Subtitle', margin, subtitleWidth, 10, true);
      drawTableCell('Content', margin + subtitleWidth, contentWidth, 10, true);
      yPosition += headerHeight;
  
      // Add content rows
      for (const content of section.contents || []) {
        const contentLines = pdf.splitTextToSize(content.content, contentWidth - 4);
        const subtitleLines = pdf.splitTextToSize(content.subtitle, subtitleWidth - 4);
        const rowHeight = Math.max(
          contentLines.length * 5,
          subtitleLines.length * 5,
          10
        );
  
        checkAndAddNewPage(rowHeight + 5);
  
        // Draw cells
        drawTableCell(content.subtitle, margin, subtitleWidth, rowHeight);
        drawTableCell(content.content, margin + subtitleWidth, contentWidth, rowHeight);
        
        yPosition += rowHeight;
      }
  
      yPosition += 10; // Space between sections
    }
  
    // Save the PDF
    pdf.save('company-handbook.pdf');
    
    toast({
      title: "Success",
      description: "PDF generated successfully"
    });
  };
  
  const validateOperation = () => {
    const user = JSON.parse(localStorage.getItem('user')); // Assuming user object is stored in localStorage
    console.log("User:", user);
  
    if (!user || (user.role !== 'super-admin' && user.role !== 'department-admin')) {
      // Check for Notification permission
      if (Notification.permission === "granted") {
        new Notification("Permission Denied", {
          body: "You do not have permission to perform this action."
    
        });
      } else if (Notification.permission === "default") {
        Notification.requestPermission().then(permission => {
          if (permission === "granted") {
            new Notification("Permission Denied", {
              body: "You do not have permission to perform this action."
            });
          } else {
            alert("Permission Denied: You do not have permission to perform this action.");
          }
        });
      } else {
        alert("Permission Denied: You do not have permission to perform this action.");
      }
      return false;
    }
    return true;
  };
  
  const fetchSections = async () => {
    try {
      const sections = await fetchHandbookSections();
      setSections(sections);
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to fetch handbook sections",
        variant: "destructive",
      });
    }
  };
  

  const handleAddSection = async () => {
    if (!validateOperation()) return;
    try {
      await addHandbookSection(newSectionTitle);
      setNewSectionTitle('');
      setShowAddSection(false);
      fetchSections();
      toast({
        title: "Success",
        description: "Section added successfully"
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to add section",
        variant: "destructive",
      });
    }
  };

  const handleDeleteSection = async (sectionId) => {
    if (!validateOperation()) return;
    if (window.confirm('Are you sure you want to delete this section?')) {
      try {
        await deleteHandbookSection(sectionId);
        fetchSections();
        toast({
          title: "Success",
          description: "Section deleted successfully"
        });
      } catch (error) {
        toast({
          title: "Error",
          description: "Failed to delete section",
          variant: "destructive",
        });
      }
    }
  };
  

  const handleAddContent = async (sectionId) => {
    if (!validateOperation()) return;
    try {
      await addHandbookContent(sectionId, newContent.subtitle, newContent.content);
      setNewContent({ subtitle: '', content: '' });
      setShowAddContent(false);
      fetchSections();
      toast({
        title: "Success",
        description: "Content added successfully"
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to add content",
        variant: "destructive",
      });
    }
  };
  

  const handleUpdateContent = async (contentId) => {
    if (!validateOperation()) return;
    try {
      await updateHandbookContent(contentId, editingContent.subtitle, editingContent.content);
      setEditingContent(null);
      fetchSections();
      toast({
        title: "Success",
        description: "Content updated successfully"
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to update content",
        variant: "destructive",
      });
    }
  };

  const handleDeleteContent = async (contentId) => {
    if (!validateOperation()) return;
    if (window.confirm('Are you sure you want to delete this content?')) {
      try {
        await deleteHandbookContent(contentId);
        fetchSections();
        toast({
          title: "Success",
          description: "Content deleted successfully"
        });
      } catch (error) {
        toast({
          title: "Error",
          description: "Failed to delete content",
          variant: "destructive",
        });
      }
    }
  };


  if (!isVisible) return null;

  return (
    <div className="fixed inset-0 z-50 handbook-dialog-container flex items-center justify-center bg-black/50 backdrop-blur-sm">
    <div className="relative w-full max-w-5xl max-h-[90vh] bg-white rounded-xl shadow-2xl flex flex-col">
        {/* Notification */}
        {notification && (
          <div className={`absolute top-4 right-4 z-50 p-4 rounded-lg shadow-lg 
            ${notification.variant === 'error' 
              ? 'bg-red-500 text-white' 
              : 'bg-green-500 text-white'}`}>
            <div className="font-bold">{notification.title}</div>
            <div className="text-sm">{notification.description}</div>
          </div>
        )}

        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b">
          <h1 className="text-2xl font-bold text-gray-800">Company Handbook</h1>
          <div className="flex space-x-2">
            <button 
              onClick={generatePDF} 
              className="flex items-center bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600 transition"
            >
              <FileDown size={16} className="mr-2" /> Download PDF
            </button>
            <button 
              onClick={() => setShowAddSection(true)} 
              className="flex items-center bg-green-500 text-white px-4 py-2 rounded-md hover:bg-green-600 transition"
            >
              <Plus size={16} className="mr-2" /> Add Section
            </button>
            <button 
              onClick={() => {
                window.location.reload(); // Reload the page
              }} 
              className="text-gray-600 hover:bg-gray-100 p-2 rounded-full"
            >
              <NavLink to="/document" className="link" activeClassName="active">
                <X size={24} />
              </NavLink>
            </button>


          
          </div>
        </div>

        {/* Add Section Modal */}
        {showAddSection && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
            <div className="bg-white p-6 rounded-lg shadow-xl w-96">
              <h2 className="text-xl font-semibold mb-4">Add New Section</h2>
              <input
                type="text"
                value={newSectionTitle}
                onChange={(e) => setNewSectionTitle(e.target.value)}
                className="w-full border rounded-md p-2 mb-4"
                placeholder="Enter section title"
              />
              <div className="flex justify-end space-x-2">
                <button 
                  onClick={handleAddSection} 
                  className="bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600"
                >
                  Save
                </button>
                <button 
                  onClick={() => setShowAddSection(false)} 
                  className="bg-gray-200 text-gray-800 px-4 py-2 rounded-md hover:bg-gray-300"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Scrollable Content Area */}
        <div className="flex-grow overflow-y-auto p-6">
          {sections.map((section) => (
            <div key={section.id} className="mb-8 bg-gray-50 rounded-lg p-6 border">
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-xl font-semibold text-gray-800">{section.title}</h2>
                <div className="flex space-x-2">
                  <button 
                    onClick={() => { setSelectedSection(section.id); setShowAddContent(true); }}
                    className="flex items-center bg-green-500 text-white px-3 py-2 rounded-md text-sm hover:bg-green-600"
                  >
                    <Plus size={16} className="mr-1" /> Add Content
                  </button>
                  <button 
                    onClick={() => handleDeleteSection(section.id)}
                    className="bg-red-500 text-white px-3 py-2 rounded-md text-sm hover:bg-red-600"
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>

              {/* Content Table */}
              <div className="overflow-x-auto">
  <table className="w-full border-collapse table-fixed">
    <thead>
      <tr className="bg-gray-100">
        <th className="p-3 text-left border-b w-1/4">Subtitle</th>
        <th className="p-3 text-left border-b w-2/3">Content</th>
        <th className="p-3 text-right border-b w-3/12">Actions</th>
      </tr>
    </thead>
    <tbody>
      {section.contents?.map((content) => (
        <tr key={content.id} className="hover:bg-gray-50">
          <td className="p-3 border-b">
            {editingContent?.id === content.id ? (
              <input
                type="text"
                value={editingContent.subtitle}
                onChange={(e) => setEditingContent({ ...editingContent, subtitle: e.target.value })}
                className="w-full border rounded p-1"
              />
            ) : (
              content.subtitle
            )}
          </td>
          <td className="p-3 border-b">
            {editingContent?.id === content.id ? (
              <textarea
                value={editingContent.content}
                onChange={(e) => setEditingContent({ ...editingContent, content: e.target.value })}
                className="w-full border rounded p-1"
                rows="3"
              />
            ) : (
              <div className="whitespace-pre-wrap break-words">{content.content}</div>
            )}
          </td>
          <td className="p-3 border-b text-right">
                          {editingContent?.id === content.id ? (
                            <div className="flex space-x-2 justify-end">
                              <button 
                                onClick={() => handleUpdateContent(content.id)}
                                className="bg-blue-500 text-white px-3 py-1 rounded text-sm hover:bg-blue-600"
                              >
                                Save
                              </button>
                              <button 
                                onClick={() => setEditingContent(null)}
                                className="bg-gray-200 text-gray-800 px-3 py-1 rounded text-sm hover:bg-gray-300"
                              >
                                Cancel
                              </button>
                            </div>
                          ) : (
                            <div className="flex space-x-2 justify-end">
                              <button 
                                onClick={() => setEditingContent(content)}
                                className="text-blue-500 hover:bg-blue-50 p-2 rounded"
                              >
                                <Pencil size={16} />
                              </button>
                              <button 
                                onClick={() => handleDeleteContent(content.id)}
                                className="text-red-500 hover:bg-red-50 p-2 rounded"
                              >
                                <Trash2 size={16} />
                              </button>
                            </div>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              {/* Add Content Modal */}
              {showAddContent && selectedSection === section.id && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
                  <div className="bg-white p-6 rounded-lg shadow-xl w-96">
                    <h2 className="text-xl font-semibold mb-4">Add New Content</h2>
                    <input
                      type="text"
                      value={newContent.subtitle}
                      onChange={(e) => setNewContent({ ...newContent, subtitle: e.target.value })}
                      className="w-full border rounded-md p-2 mb-4"
                      placeholder="Enter subtitle"
                    />
                    <textarea
                      value={newContent.content}
                      onChange={(e) => setNewContent({ ...newContent, content: e.target.value })}
                      className="w-full border rounded-md p-2 mb-4"
                      rows="4"
                      placeholder="Enter content"
                    />
                    <div className="flex justify-end space-x-2">
                      <button 
                        onClick={() => handleAddContent(section.id)} 
                        className="bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600"
                      >
                        Save
                      </button>
                      <button 
                        onClick={() => { 
                          setShowAddContent(false); 
                          setNewContent({ subtitle: '', content: '' }); 
                        }} 
                        className="bg-gray-200 text-gray-800 px-4 py-2 rounded-md hover:bg-gray-300"
                      >
                        Cancel
                      </button>
                    </div>
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default HandbookDialog;
