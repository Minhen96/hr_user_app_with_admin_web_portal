import React, { useState, useEffect } from 'react';
import { X, Edit, Trash } from 'lucide-react';
import './DepartmentDialog.css';
import {
  fetchDepartment,
  createDepartment,
  updateDepartment,
  deleteDepartment,
} from '../api/staffApi';

const DepartmentDialog = ({ isOpen, onClose }) => {
  const [departments, setDepartments] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [isEditing, setIsEditing] = useState(false);
  const [editingDepartment, setEditingDepartment] = useState(null);
  const [newDepartment, setNewDepartment] = useState({ name: '', description: '' });

  useEffect(() => {
    if (isOpen) {
      handleFetchDepartments();
    }
  }, [isOpen]);

  const handleFetchDepartments = async () => {
    try {
      setIsLoading(true);
      const data = await fetchDepartment();
      setDepartments(data);
    } catch (error) {
      setError(error.message);
    } finally {
      setIsLoading(false);
    }
  };

  const handleEdit = (department) => {
    setIsEditing(true);
    setEditingDepartment(department);
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this department?')) {
      try {
        await deleteDepartment(id);
        handleFetchDepartments();
      } catch (error) {
        setError(error.message);
      }
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (isEditing) {
        await updateDepartment(editingDepartment.id, {
          name: editingDepartment.name,
          description: editingDepartment.description,
        });
      } else {
        await createDepartment(newDepartment);
      }
      handleFetchDepartments();
      resetForm();
    } catch (error) {
      setError(error.message);
    }
  };

  const resetForm = () => {
    setIsEditing(false);
    setEditingDepartment(null);
    setNewDepartment({ name: '', description: '' });
  };

  if (!isOpen) return null;

  return (
    <div className="modal-overlay">
  <div className="modal-content">
    <div className="modal-header">
      <h2 className="modal-title">Manage Departments</h2>
      <button className="close-button" onClick={onClose}>
        <X size={24} />
      </button>
    </div>

    {error && <div className="error-message">{error}</div>}
    {isLoading ? (
      <div className="loading-spinner">Loading...</div>
    ) : (
      <>
        {/* Department Form */}
        <div className="department-form">
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <input
                type="text"
                placeholder="Department Name"
                value={isEditing ? editingDepartment.name : newDepartment.name}
                onChange={(e) =>
                  isEditing
                    ? setEditingDepartment({ ...editingDepartment, name: e.target.value })
                    : setNewDepartment({ ...newDepartment, name: e.target.value })
                }
                required
              />
            </div>
            <div className="form-group">
              <input
                type="text"
                placeholder="Description"
                value={isEditing ? editingDepartment.description : newDepartment.description}
                onChange={(e) =>
                  isEditing
                    ? setEditingDepartment({ ...editingDepartment, description: e.target.value })
                    : setNewDepartment({ ...newDepartment, description: e.target.value })
                }
              />
            </div>
            <div className="form-actions">
              <button type="submit" className="button">
                {isEditing ? 'Update Department' : 'Add Department'}
              </button>
              {isEditing && (
                <button type="button" className="button button-outline" onClick={resetForm}>
                  Cancel
                </button>
              )}
            </div>
          </form>
        </div>

        {/* Department List */}
        <div className="department-list">
          <table className="department-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Description</th>
                <th>Created At</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {departments.map((department) => (
                <tr key={department.id}>
                  <td>{department.name}</td>
                  <td>{department.description}</td>
                  <td>{new Date(department.createdAt).toLocaleDateString()}</td>
                  <td>
                    <div className="button-group">
                      <button className="icon-button" onClick={() => handleEdit(department)}>
                        <Edit className="icon" size={16} />
                      </button>
                      <button
                        className="icon-button destructive"
                        onClick={() => handleDelete(department.id)}
                      >
                        <Trash className="icon" size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </>
    )}
  </div>
</div>
  );
};

export default DepartmentDialog;
