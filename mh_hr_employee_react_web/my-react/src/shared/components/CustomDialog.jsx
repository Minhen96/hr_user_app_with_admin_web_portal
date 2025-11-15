import React from 'react';
import './CustomDialog.css';

const CustomDialog = ({ isOpen, onClose, title, children }) => {
  if (!isOpen) return null;

  return (
    <div className="container">
      {/* Overlay */}
      <div 
        className="overlay" 
        onClick={onClose}
      />
      
      {/* Dialog content */}
      <div className="content overflow-y-auto max-h-[70vh]">
        {/* Header */}
        <div className="header">
          <h2 className="title">{title}</h2>
          <button 
            onClick={onClose}
            className="close-button"
          >
            ×
          </button>
        </div>
        
        {/* Body */}
        <div className="body">
          {children}
        </div>
      </div>
    </div>
  );
};

export default CustomDialog;