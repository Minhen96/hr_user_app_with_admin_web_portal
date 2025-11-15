import React from 'react';
import './CustomDialog.css';

const CustomsDialog = ({ isOpen, onClose, title, children }) => {
  if (!isOpen) return null;

  return (
    <div className="dialog-overlay">
      <div className="dialog-content">
        <div className="dialog-header">
          <h2 className="dialog-title">{title}</h2>
          <button onClick={onClose} className="close-button">✕</button>
        </div>
        <div>{children}</div>
      </div>
    </div>
  );
};

export default CustomsDialog;

