import React from "react";
import { Button } from "@/components/ui/button";

const CustomDialog = ({ isOpen, onClose, children }) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center overflow-x-hidden overflow-y-auto outline-none focus:outline-none">
      <div className="relative w-auto max-w-3xl mx-auto my-6">
        <div className="relative flex flex-col w-full bg-white border-0 rounded-lg shadow-lg outline-none focus:outline-none">
          <div className="flex items-start justify-between p-5 border-b border-solid rounded-t border-blueGray-200">
            <h3 className="text-3xl font-semibold">Approve Request</h3>
            <button 
              className="float-right p-1 ml-auto text-3xl font-semibold leading-none text-black bg-transparent border-0 outline-none opacity-5 focus:outline-none"
              onClick={onClose}
            >
              ×
            </button>
          </div>
          <div className="relative flex-auto p-6">
            {children}
          </div>
          <div className="flex items-center justify-end p-6 border-t border-solid rounded-b border-blueGray-200">
            <button
              className="px-6 py-2 mb-1 mr-1 text-sm font-bold text-red-500 uppercase outline-none background-transparent focus:outline-none"
              type="button"
              onClick={onClose}
            >
              Close
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

const ApproveRequestDialog = ({ 
  isOpen, 
  onClose, 
  request, 
  onApprove 
}) => {
  const validateAndApprove = () => {
    onApprove(request.equipmentItems);
  };

  return (
    <CustomDialog isOpen={isOpen} onClose={onClose}>
      <div>
        <h2 className="mb-4 text-xl font-bold">Approve Request</h2>
        <table className="w-full min-w-[500px] border-collapse">
          <thead>
            <tr>
              <th className="p-2 border text-left w-3/4">Item</th>
              <th className="p-2 border text-left w-1/4">Quantity</th>
            </tr>
          </thead>
          <tbody>
            {request?.equipmentItems?.map((item) => (
              <tr key={item.id} className="border">
                <td className="p-2">{item.title}</td>
                <td className="p-2">{item.quantity}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <div className="flex justify-end mt-4">
          <Button onClick={validateAndApprove} className="mr-2">
            Approve Request
          </Button>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
        </div>
      </div>
    </CustomDialog>
  );
};

export default ApproveRequestDialog;