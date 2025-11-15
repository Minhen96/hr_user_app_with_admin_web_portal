import React, { useState, useEffect } from 'react';
import { Calendar, X, Clock, MapPin, Camera } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Card, CardContent } from '@/components/ui/card';
import axios from 'axios';
import { apiClient } from '../../../core/api/client';

const CustomAttendanceDialog = ({ isOpen, onClose, userDetails }) => {
  const [convertedPhotos, setConvertedPhotos] = useState({});

  useEffect(() => {
    if (userDetails?.attendanceRecords) {
      const convertAllPhotos = async () => {
        const photoPromises = userDetails.attendanceRecords.map(async (record) => ({
          timeInPhoto: record.timeInPhoto
            ? await convertBinaryToBase64(record.timeInPhoto)
            : null,
          timeOutPhoto: record.timeOutPhoto
            ? await convertBinaryToBase64(record.timeOutPhoto)
            : null,
        }));

        const photos = await Promise.all(photoPromises);
        setConvertedPhotos(photos);
      };

      convertAllPhotos();
    }
  }, [userDetails]);

  const convertBinaryToBase64 = async (binaryString) => {
    if (!binaryString || binaryString.length === 0) return null;
    if (binaryString.startsWith('0x')) {
      binaryString = binaryString.slice(2);
    }
    const byteArray = Uint8Array.from(
      binaryString.match(/.{1,2}/g).map((byte) => parseInt(byte, 16))
    );
    const blob = new Blob([byteArray]);
    const reader = new FileReader();
    return new Promise((resolve, reject) => {
      reader.onloadend = () => resolve(reader.result.split(',')[1]);
      reader.onerror = reject;
      reader.readAsDataURL(blob);
    });
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl overflow-hidden">
        <div className="bg-blue-600 text-white p-6 flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center text-2xl font-bold">
              {userDetails.name.charAt(0).toUpperCase()}
            </div>
            <div>
              <h2 className="text-2xl font-bold">{userDetails.name}</h2>
              <p className="text-sm text-white/80">{userDetails.department}</p>
            </div>
          </div>
          <button onClick={onClose} className="hover:bg-white/20 rounded-full p-2">
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="p-6 space-y-6 max-h-[500px] overflow-y-auto">
          {userDetails.attendanceRecords.map((record, index) => (
            <div key={index} className="bg-gray-100 rounded-2xl p-6 shadow-sm border">
              <div className="flex justify-between mb-4 pb-4 border-b border-gray-300">
                <div className="flex items-center space-x-3">
                  <Clock className="w-5 h-5 text-blue-600" />
                  <div>
                    <p className="text-gray-600 text-sm">Time In</p>
                    <p className="text-xl font-semibold">
                      {new Date(record.timeIn).toLocaleTimeString()}
                    </p>
                  </div>
                </div>
                <div className="flex items-center space-x-3">
                  <Clock className="w-5 h-5 text-red-600" />
                  <div>
                    <p className="text-gray-600 text-sm">Time Out</p>
                    <p className="text-xl font-semibold">
                      {record.timeOut ? new Date(record.timeOut).toLocaleTimeString() : 'Not Clocked Out'}
                    </p>
                  </div>
                </div>
              </div>

              <div className="mb-4 flex items-center space-x-3">
                <MapPin className="w-5 h-5 text-green-600" />
                <div>
                  <p className="text-gray-600 text-sm">Place Name</p>
                  <p className="text-lg font-medium">{record.placeName}</p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                {convertedPhotos[index]?.timeInPhoto && (
                  <div className="bg-white p-2 rounded-lg shadow-sm">
                    <div className="flex items-center mb-2 space-x-2">
                      <Camera className="w-4 h-4 text-blue-600" />
                      <p className="text-sm text-gray-600">Time In Photo</p>
                    </div>
                    <img
                      src={`data:image/png;base64,${convertedPhotos[index]?.timeInPhoto}`}
                      alt="Time In"
                      className="w-full h-48 object-cover rounded-md"
                    />
                  </div>
                )}
                {convertedPhotos[index]?.timeOutPhoto && (
                  <div className="bg-white p-2 rounded-lg shadow-sm">
                    <div className="flex items-center mb-2 space-x-2">
                      <Camera className="w-4 h-4 text-red-600" />
                      <p className="text-sm text-gray-600">Time Out Photo</p>
                    </div>
                    <img
                      src={`data:image/png;base64,${convertedPhotos[index]?.timeOutPhoto}`}
                      alt="Time Out"
                      className="w-full h-48 object-cover rounded-md"
                    />
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>

        <div className="p-6 bg-gray-50 border-t">
          <button
            className="w-full bg-blue-600 text-white py-3 rounded-xl hover:bg-blue-700"
            onClick={onClose}
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
};





// UserStatCard Component
const UserStatCard = ({ user, onClick }) => (
  <Card 
    onClick={onClick} 
    className="cursor-pointer hover:bg-gray-50 transition-colors"
  >
    <CardContent className="pt-6 flex items-center space-x-4">
      <div className="w-12 h-12 bg-gray-200 rounded-full flex items-center justify-center">
        {user.name.charAt(0).toUpperCase()}
      </div>
      <div>
        <p className="font-semibold">{user.name}</p>
        <p className="text-sm text-gray-500">{user.department}</p>
      </div>
    </CardContent>
  </Card>
);

// Attendance Tab Component
const AttendanceTab = () => {
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [presentUsers, setPresentUsers] = useState([]);
  const [absentUsers, setAbsentUsers] = useState([]);
  const [selectedUser, setSelectedUser] = useState(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);

  useEffect(() => {
    fetchAttendanceData();
  }, [selectedDate]);

  const fetchAttendanceData = async () => {
    try {
      // TODO: /leave/attendance endpoint doesn't exist in backend
      // const response = await apiClient.get(`/leave/attendance`, {
      //   params: { date: selectedDate }
      // });
      // setPresentUsers(response.data.presentUsers);
      // setAbsentUsers(response.data.absentUsers);

      // Set empty arrays for now
      setPresentUsers([]);
      setAbsentUsers([]);
    } catch (error) {
      console.error('Error fetching attendance data:', error);
    }
  };

  const handleUserClick = async (user) => {
    try {
      const response = await apiClient.get(`/leave/attendance/${user.id}`, {
        params: { date: selectedDate }
      });

      setSelectedUser({
        ...user,
        attendanceRecords: response.data.attendanceRecords
      });
      setIsDialogOpen(true);
    } catch (error) {
      console.error('Error fetching user attendance details:', error);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-4">
        <Calendar className="h-5 w-5 text-gray-500" />
        <Input 
          type="date" 
          value={selectedDate}
          onChange={(e) => setSelectedDate(e.target.value)}
          className="w-64"
        />
      </div>

      <div className="grid grid-cols-2 gap-6">
        {/* Present Section */}
        <div>
          <h2 className="text-lg font-semibold mb-4">Present ({presentUsers.length})</h2>
          <div className="space-y-4">
            {presentUsers.map(user => (
              <UserStatCard 
                key={user.id} 
                user={user} 
                onClick={() => handleUserClick(user)}
              />
            ))}
          </div>
        </div>

        {/* Absent Section */}
        <div>
          <h2 className="text-lg font-semibold mb-4">Absent ({absentUsers.length})</h2>
          <div className="space-y-4">
            {absentUsers.map(user => (
              <UserStatCard 
                key={user.id} 
                user={user} 
                onClick={() => handleUserClick(user)}
              />
            ))}
          </div>
        </div>
      </div>

      <CustomAttendanceDialog 
        isOpen={isDialogOpen}
        onClose={() => setIsDialogOpen(false)}
        userDetails={selectedUser}
      />
    </div>
  );
};

export default AttendanceTab;