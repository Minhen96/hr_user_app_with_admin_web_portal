// eslint-disable-next-line no-unused-vars
import React, { useState, useEffect, useRef } from 'react';
import { DownloadCloud } from 'lucide-react';
import { Button } from "@/components/ui/button";
import apiClient from '../../../core/api/client';
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';

const CustomDialog = ({ isOpen, onClose, title, children, maxWidth = 'max-w-6xl' }) => {
  const dialogRef = useRef(null);
  
  // Close when clicking outside the dialog
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dialogRef.current && !dialogRef.current.contains(event.target)) {
        onClose();
      }
    };
    
    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen, onClose]);
  
  // Close on escape key
  useEffect(() => {
    const handleEscKey = (event) => {
      if (event.key === 'Escape') {
        onClose();
      }
    };
    
    if (isOpen) {
      document.addEventListener('keydown', handleEscKey);
    }
    
    return () => {
      document.removeEventListener('keydown', handleEscKey);
    };
  }, [isOpen, onClose]);
  
  if (!isOpen) return null;
  
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
      <div 
        ref={dialogRef}
        className={`${maxWidth} w-full bg-white rounded-lg shadow-lg overflow-hidden animate-in fade-in-0 zoom-in-95 duration-300`}
      >
        <div className="flex justify-between items-center px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-semibold">{title}</h2>
          <button 
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700 focus:outline-none"
          >
            ✕
          </button>
        </div>
        <div className="p-6 max-h-[80vh] overflow-y-auto">
          {children}
        </div>
      </div>
    </div>
  );
};

const LeaveReportDialog = () => {
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [reportType, setReportType] = useState("");
  const [reportData, setReportData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const tableRef = useRef(null);
  const [pdfOptions, setPdfOptions] = useState({
    orientation: 'portrait',
    pageSize: 'a4',
    showPageNumbers: true,
    rowsPerPage: 0, // 0 means auto-calculate based on page size
    tableScale: 0.85, // Scale factor for the table (0.9 = 90% of page width)
  });
  
  const fetchReportData = async (type) => {
    if (!type) return;
    
    setLoading(true);
    setError(null);
    
    try {
      // This would be modified to fetch JSON data instead of PDF
      const response = await apiClient.get(`/LeaveReport/report/${type}/preview`);
      setReportData(response.data);
    } catch (err) {
      console.error(`Error fetching ${type} report data:`, err);
      setError(`Failed to load ${type} report data. Please try again.`);
    } finally {
      setLoading(false);
    }
  };
  
  const handleReportSelection = (e) => {
    const type = e.target.value;
    if (!type) return;
    
    setReportType(type);
    fetchReportData(type);
    setIsDialogOpen(true);
  };
  
  const generatePDF = async () => {
    if (!reportType || !tableRef.current || !reportData.length) return;
    
    try {
      // Create a loading indicator
      const loadingOverlay = document.createElement('div');
      loadingOverlay.className = 'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50';
      loadingOverlay.innerHTML = '<div class="bg-white p-4 rounded shadow">Generating PDF...</div>';
      document.body.appendChild(loadingOverlay);
      
      // Create new PDF with selected orientation and page size
      const pdf = new jsPDF({
        orientation: pdfOptions.orientation,
        unit: 'mm',
        format: pdfOptions.pageSize,
      });
      
      // Get page dimensions in mm
      const pageWidth = pdf.internal.pageSize.getWidth();
      const pageHeight = pdf.internal.pageSize.getHeight();
      
      // Set margins
      const margin = 15; // mm
      const contentWidth = pageWidth - (margin * 2);
      const headerHeight = 25; // mm (for title and date)
      const footerHeight = 10; // mm (for page numbers)
      const contentHeight = pageHeight - headerHeight - footerHeight - (margin * 2);
      
      // Title for the report
      const title = `${reportType === 'annual' ? 'Annual Leave Report' : 'Medical Leave Report'} - ${new Date().getFullYear()}`;
      
      // Count rows and calculate pagination if needed
      const rowCount = reportData.length;
      
      // Calculate rows per page based on row height approximation if not set
      const approximateRowHeight = 8; // mm - adjust based on your font size
      const calculatedRowsPerPage = Math.floor(contentHeight / approximateRowHeight);
      const rowsPerPage = pdfOptions.rowsPerPage > 0 ? pdfOptions.rowsPerPage : calculatedRowsPerPage;
      
      // Calculate total pages needed
      const totalPages = Math.ceil(rowCount / rowsPerPage);
      
      // Process each chunk of rows for pagination
      for (let pageIndex = 0; pageIndex < totalPages; pageIndex++) {
        // Add a new page for pages after the first one
        if (pageIndex > 0) {
          pdf.addPage();
        }
        
        // Add title to each page
        pdf.setFontSize(16);
        pdf.text(title, margin + 15, margin + 10);
        
        pdf.setFontSize(10);
        const dateText = `Generated on: ${new Date().toLocaleDateString()}`;
        const textWidth = pdf.getTextWidth(dateText); // Get width of the text in mm
        pdf.text(dateText, pageWidth - margin - 50, margin + 20);
        
        // Add page number if enabled
        if (pdfOptions.showPageNumbers) {
          pdf.setFontSize(10);
          pdf.text(`Page ${pageIndex + 1} of ${totalPages}`, pageWidth - margin - 30, pageHeight - margin);
        }
        
        // Calculate start and end indices for this page
        const startIdx = pageIndex * rowsPerPage;
        const endIdx = Math.min(startIdx + rowsPerPage, rowCount);
        
        // Create a temporary div for this page's content
        const tempDiv = document.createElement('div');
        tempDiv.style.position = 'absolute';
        tempDiv.style.left = '-9999px';
        document.body.appendChild(tempDiv);
        
        // Clone the table
        const tableClone = tableRef.current.cloneNode(true);
        
        // If we're paginating, keep only the header and the current page's rows
        if (totalPages > 1) {
          const tbody = tableClone.querySelector('tbody');
          const rows = Array.from(tbody.querySelectorAll('tr'));
          
          // Remove all rows
          rows.forEach(row => tbody.removeChild(row));
          
          // Add only this page's rows
          for (let i = startIdx; i < endIdx; i++) {
            if (i < reportData.length) {
              tbody.appendChild(rows[i]);
            }
          }
        }
        
        tempDiv.appendChild(tableClone);
        
        // Generate canvas from the temporary table
        const canvas = await html2canvas(tableClone, {
          scale: 2, // Higher scale for better quality
          useCORS: true,
          logging: false,
        });
        
        // Calculate table dimensions for this page to fit within content area
        const tableWidth = contentWidth * pdfOptions.tableScale;
        const tableHeight = (canvas.height * tableWidth) / canvas.width;
        
        // Calculate position to center the table horizontally
        const tableX = margin + (contentWidth - tableWidth) / 2;
        
        // Add table as image
        pdf.addImage(
          canvas.toDataURL('image/png'),
          'PNG',
          tableX,
          headerHeight + margin,
          tableWidth,
          tableHeight
        );
        
        // Clean up temporary elements
        document.body.removeChild(tempDiv);
      }
      
      // Save PDF
      pdf.save(`${reportType}_leave_report_${new Date().getFullYear()}.pdf`);
      
      // Remove loading overlay
      document.body.removeChild(loadingOverlay);
    } catch (error) {
      console.error(`Error generating ${reportType} leave report PDF:`, error);
      setError(`Failed to generate PDF. Please try again.`);
    }
  };
  
  // Update PDF options
  const handlePdfOptionChange = (field, value) => {
    setPdfOptions(prev => ({
      ...prev,
      [field]: value
    }));
  };
  
  const renderAnnualLeaveTable = () => {
    if (!reportData.length) return null;
    
    return (
      <div className="overflow-x-auto">
        <table ref={tableRef} className="w-full border-collapse">
          <thead>
            <tr className="bg-blue-100">
              <th className="border border-blue-200 px-4 py-2 text-left">Name</th>
              <th className="border border-blue-200 px-4 py-2 text-center">Entitlement</th>
              <th className="border border-blue-200 px-2 py-2 text-center">Jan</th>
              <th className="border border-blue-200 px-2 py-2 text-center">Feb</th>
              <th className="border border-blue-200 px-2 py-2 text-center">Mar</th>
              <th className="border border-blue-200 px-2 py-2 text-center">Apr</th>
              <th className="border border-blue-200 px-2 py-2 text-center">May</th>
              <th className="border border-blue-200 px-2 py-2 text-center">Jun</th>
              <th className="border border-blue-200 px-2 py-2 text-center">Jul</th>
              <th className="border border-blue-200 px-2 py-2 text-center">Aug</th>
              <th className="border border-blue-200 px-2 py-2 text-center">Sep</th>
              <th className="border border-blue-200 px-2 py-2 text-center">Oct</th>
              <th className="border border-blue-200 px-2 py-2 text-center">Nov</th>
              <th className="border border-blue-200 px-2 py-2 text-center">Dec</th>
              <th className="border border-blue-200 px-2 py-2 text-center">Total</th>
              <th className="border border-blue-200 px-2 py-2 text-center">Balance</th>
            </tr>
          </thead>
          <tbody>
            {reportData.map((row, index) => (
              <tr key={index} className={index % 2 === 0 ? "bg-blue-50" : "bg-white"}>
                <td className="border border-blue-200 px-4 py-2">{row.fullName}</td>
                <td className="border border-blue-200 px-4 py-2 text-center">{row.entitlement}</td>
                <td className="border border-blue-200 px-2 py-2 text-center">{row.jan !== 0 ? row.jan : ''}</td>
                <td className="border border-blue-200 px-2 py-2 text-center">{row.feb !== 0 ? row.feb : ''}</td>
                <td className="border border-blue-200 px-2 py-2 text-center">{row.mar !== 0 ? row.mar : ''}</td>
                <td className="border border-blue-200 px-2 py-2 text-center">{row.apr !== 0 ? row.apr : ''}</td>
                <td className="border border-blue-200 px-2 py-2 text-center">{row.may !== 0 ? row.may : ''}</td>
                <td className="border border-blue-200 px-2 py-2 text-center">{row.jun !== 0 ? row.jun : ''}</td>
                <td className="border border-blue-200 px-2 py-2 text-center">{row.jul !== 0 ? row.jul : ''}</td>
                <td className="border border-blue-200 px-2 py-2 text-center">{row.aug !== 0 ? row.aug : ''}</td>
                <td className="border border-blue-200 px-2 py-2 text-center">{row.sep !== 0 ? row.sep : ''}</td>
                <td className="border border-blue-200 px-2 py-2 text-center">{row.oct !== 0 ? row.oct : ''}</td>
                <td className="border border-blue-200 px-2 py-2 text-center">{row.nov !== 0 ? row.nov : ''}</td>
                <td className="border border-blue-200 px-2 py-2 text-center">{row.dec !== 0 ? row.dec : ''}</td>
                <td className="border border-blue-200 px-2 py-2 text-center">{row.totalTaken}</td>
                <td className="border border-blue-200 px-2 py-2 text-center">{row.balance}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  };
  
  const renderMedicalLeaveTable = () => {
    if (!reportData.length) return null;
    
    return (
      <div className="overflow-x-auto">
        <table ref={tableRef} className="w-full border-collapse">
          <thead>
            <tr className="bg-green-100">
              <th className="border border-green-200 px-4 py-2 text-left">Name</th>
              <th className="border border-green-200 px-2 py-2 text-center">Jan</th>
              <th className="border border-green-200 px-2 py-2 text-center">Feb</th>
              <th className="border border-green-200 px-2 py-2 text-center">Mar</th>
              <th className="border border-green-200 px-2 py-2 text-center">Apr</th>
              <th className="border border-green-200 px-2 py-2 text-center">May</th>
              <th className="border border-green-200 px-2 py-2 text-center">Jun</th>
              <th className="border border-green-200 px-2 py-2 text-center">Jul</th>
              <th className="border border-green-200 px-2 py-2 text-center">Aug</th>
              <th className="border border-green-200 px-2 py-2 text-center">Sep</th>
              <th className="border border-green-200 px-2 py-2 text-center">Oct</th>
              <th className="border border-green-200 px-2 py-2 text-center">Nov</th>
              <th className="border border-green-200 px-2 py-2 text-center">Dec</th>
              <th className="border border-green-200 px-2 py-2 text-center">Total</th>
            </tr>
          </thead>
          <tbody>
            {reportData.map((row, index) => (
              <tr key={index} className={index % 2 === 0 ? "bg-green-50" : "bg-white"}>
                <td className="border border-green-200 px-4 py-2">{row.fullName}</td>
                <td className="border border-green-200 px-2 py-2 text-center">
                  {row.jan !== 0 ? row.jan : ''}
                </td>
                <td className="border border-green-200 px-2 py-2 text-center">{row.feb !== 0 ? row.feb : ''}</td>
                <td className="border border-green-200 px-2 py-2 text-center">{row.mar !== 0 ? row.mar : ''}</td>
                <td className="border border-green-200 px-2 py-2 text-center">{row.apr !== 0 ? row.apr : ''}</td>
                <td className="border border-green-200 px-2 py-2 text-center">{row.may !== 0 ? row.may : ''}</td>
                <td className="border border-green-200 px-2 py-2 text-center">{row.jun !== 0 ? row.jun : ''}</td>
                <td className="border border-green-200 px-2 py-2 text-center">{row.jul !== 0 ? row.jul : ''}</td>
                <td className="border border-green-200 px-2 py-2 text-center">{row.aug !== 0 ? row.aug : ''}</td>
                <td className="border border-green-200 px-2 py-2 text-center">{row.sep !== 0 ? row.sep : ''}</td>
                <td className="border border-green-200 px-2 py-2 text-center">{row.oct !== 0 ? row.oct : ''}</td>
                <td className="border border-green-200 px-2 py-2 text-center">{row.nov !== 0 ? row.nov : ''}</td>
                <td className="border border-green-200 px-2 py-2 text-center">{row.dec !== 0 ? row.dec : ''}</td>
                <td className="border border-green-200 px-2 py-2 text-center">{row.totalTaken}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  };

  return (
    <>
      <div className="flex items-center gap-2">
        <select 
          onChange={handleReportSelection}
          defaultValue=""
          className="border rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <option value="" disabled>Print Report</option>
          <option value="annual">Annual Leave Report</option>
          <option value="medical">Medical Leave Report</option>
        </select>
      </div>
      
      <CustomDialog 
        isOpen={isDialogOpen} 
        onClose={() => setIsDialogOpen(false)}
        title={`${reportType === "annual" ? "Annual Leave Report" : "Medical Leave Report"} - ${new Date().getFullYear()}`}
      >
        {loading && <div className="flex justify-center py-8">Loading report data...</div>}
        
        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
            {error}
          </div>
        )}
        
        {!loading && !error && reportType === "annual" && renderAnnualLeaveTable()}
        {!loading && !error && reportType === "medical" && renderMedicalLeaveTable()}
        
        {!loading && !error && reportData.length > 0 && (
          <div className="mt-6 border-t pt-4">
            <h3 className="text-lg font-medium mb-3">PDF Export Options</h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Orientation</label>
                <select
                  value={pdfOptions.orientation}
                  onChange={(e) => handlePdfOptionChange('orientation', e.target.value)}
                  className="w-full border rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="landscape">Landscape</option>
                  <option value="portrait">Portrait</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Page Size</label>
                <select
                  value={pdfOptions.pageSize}
                  onChange={(e) => handlePdfOptionChange('pageSize', e.target.value)}
                  className="w-full border rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="a4">A4</option>
                  <option value="letter">Letter</option>
                  <option value="legal">Legal</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Table Scale</label>
                <input
                  type="range"
                  min="0.5"
                  max="1"
                  step="0.05"
                  value={pdfOptions.tableScale}
                  onChange={(e) => handlePdfOptionChange('tableScale', parseFloat(e.target.value))}
                  className="w-full focus:outline-none"
                />
                <div className="text-xs text-gray-500 text-center">{Math.round(pdfOptions.tableScale * 100)}%</div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Page Numbers</label>
                <div className="flex items-center">
                  <input
                    type="checkbox"
                    checked={pdfOptions.showPageNumbers}
                    onChange={(e) => handlePdfOptionChange('showPageNumbers', e.target.checked)}
                    className="rounded text-blue-500 focus:ring-blue-500"
                  />
                  <span className="ml-2 text-sm">Show page numbers</span>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Rows Per Page</label>
                <select
                  value={pdfOptions.rowsPerPage}
                  onChange={(e) => handlePdfOptionChange('rowsPerPage', parseInt(e.target.value))}
                  className="w-full border rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="0">Auto</option>
                  <option value="10">10 rows</option>
                  <option value="15">15 rows</option>
                  <option value="20">20 rows</option>
                  <option value="25">25 rows</option>
                  <option value="30">30 rows</option>
                </select>
              </div>
            </div>
          </div>
        )}
        
        <div className="flex justify-end mt-4">
          <Button 
            onClick={generatePDF} 
            disabled={loading || error || !reportData.length}
            className="flex items-center gap-2"
          >
            <DownloadCloud size={16} />
            Generate PDF
          </Button>
        </div>
      </CustomDialog>
    </>
  );
};

export default LeaveReportDialog;