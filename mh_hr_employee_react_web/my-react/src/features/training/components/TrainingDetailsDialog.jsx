import React, { useState, useEffect } from 'react';
import { X } from 'lucide-react';
import { fetchTrainingCertificates } from '../api/trainingApi';

const TrainingDetailsDialog = ({ isOpen, onClose, trainingDetails, certificateId }) => {
  const [selectedCertificate, setSelectedCertificate] = useState(null);
  const [error, setError] = useState('');

  useEffect(() => {
    let mounted = true;

    const loadCertificate = async () => {
      if (isOpen && certificateId) {
        const result = await fetchTrainingCertificates(certificateId);
        
        if (mounted) {
          if (result.error) {
            setError(result.error);
            setSelectedCertificate(null);
          } else {
            setSelectedCertificate({
              url: result.url,
              type: result.type
            });
            setError('');
          }
        }
      }
    };

    loadCertificate();

    // Cleanup function
    return () => {
      mounted = false;
      if (selectedCertificate?.url) {
        URL.revokeObjectURL(selectedCertificate.url);
      }
    };
  }, [isOpen, certificateId]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-4xl w-full max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold">Training Details</h2>
          <button 
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700 text-2xl"
          >
            <X size={24} />
          </button>
        </div>

        {error && (
          <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            {error}
          </div>
        )}

        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="font-medium">Title:</label>
              <p className="mt-1">{trainingDetails.title}</p>
            </div>
            <div>
              <label className="font-medium">Description:</label>
              <p className="mt-1">{trainingDetails.description}</p>
            </div>
            <div>
              <label className="font-medium">Course Date:</label>
              <p className="mt-1">
                {new Date(trainingDetails.courseDate).toLocaleDateString('en-GB', {
                  day: '2-digit',
                  month: '2-digit',
                  year: 'numeric'
                })}
              </p>
            </div>
            <div>
              <label className="font-medium">Status:</label>
              <span className={`status-badge status-${trainingDetails.status.toLowerCase()} ml-2`}>
                {trainingDetails.status.charAt(0).toUpperCase() + trainingDetails.status.slice(1)}
              </span>
            </div>
          </div>

          {selectedCertificate && (
            <div className="mt-6">
              <h3 className="text-lg font-semibold mb-4">Certificate</h3>
              <div className="certificate-preview border rounded-lg">
                {selectedCertificate.type.includes('pdf') ? (
                  <iframe
                    src={selectedCertificate.url}
                    className="w-full h-[calc(100vh-400px)] min-h-[500px]"
                    title="Certificate Preview"
                  />
                ) : (
                  <img
                    src={selectedCertificate.url}
                    alt="Certificate"
                    className="max-w-full h-auto"
                  />
                )}
              </div>
              <div className="mt-4 flex justify-end">
                <a 
                  href={selectedCertificate.url} 
                  download="certificate"
                  className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
                >
                  Download Certificate
                </a>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default TrainingDetailsDialog;