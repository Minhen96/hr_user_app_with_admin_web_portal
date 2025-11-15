import React, { useState, useEffect } from 'react';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { ChevronLeft, ChevronRight, Calendar, Users, Plus, Trash2 } from 'lucide-react';
import axios from 'axios';
import './LeaveCalendar.css';
import { X } from 'lucide-react';
import { getCalendarData } from '../api/leaveApi';
import apiClient from '../../../core/api/client';

const AddHolidayDialog = ({ isOpen, onClose, onSubmit }) => {
  const [holidayDate, setHolidayDate] = useState('');
  const [holidayName, setHolidayName] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit({ holidayDate, holidayName });
    setHolidayDate('');
    setHolidayName('');
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-2xl w-[90%] max-w-md overflow-hidden animate-scale-in">
        <div className="flex justify-between items-center p-6 border-b border-gray-200">
          <h2 className="text-2xl font-semibold text-gray-800">Add Public Holiday</h2>
          <button 
            onClick={onClose}
            className="text-gray-500 hover:text-gray-800 transition-colors hover:bg-gray-100 rounded-full p-2"
          >
            <X size={20} />
          </button>
        </div>
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div className="space-y-2">
            <label className="block text-sm font-medium text-gray-700">Date</label>
            <input
              type="date"
              required
              value={holidayDate}
              onChange={(e) => setHolidayDate(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          <div className="space-y-2">
            <label className="block text-sm font-medium text-gray-700">Holiday Name</label>
            <input
              type="text"
              required
              value={holidayName}
              onChange={(e) => setHolidayName(e.target.value)}
              placeholder="Enter holiday name"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          <div className="flex justify-end space-x-3 mt-6">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              Add Holiday
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};


const CustomDialog = ({ isOpen, onClose, title, children }) => {
  useEffect(() => {
    const handleEscape = (e) => {
      if (e.key === 'Escape') {
        onClose();
      }
    };

    if (isOpen) {
      document.addEventListener('keydown', handleEscape);
      document.body.style.overflow = 'hidden';
    }

    return () => {
      document.removeEventListener('keydown', handleEscape);
      document.body.style.overflow = 'unset';
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
      <div 
        className="bg-white rounded-2xl shadow-2xl w-[90%] max-w-4xl max-h-[90vh] overflow-hidden 
        animate-scale-in transform transition-all duration-300"
      >
        <div className="flex justify-between items-center p-6 border-b border-gray-200">
          <h2 className="text-2xl font-semibold text-gray-800 flex items-center">
            <Calendar className="mr-3 text-blue-600" size={24} />
            {title}
          </h2>
          <button 
            onClick={onClose} 
            className="text-gray-500 hover:text-gray-800 transition-colors 
            hover:bg-gray-100 rounded-full p-2"
          >
            <span className="sr-only">Close</span>
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <div className="p-6 overflow-y-auto max-h-[70vh]">{children}</div>
      </div>
    </div>
  );
};
const LeaveCalendar = () => {
  const currentYear = new Date().getFullYear();
  const currentMonth = new Date().getMonth();
  const [isHolidayDialogOpen, setIsHolidayDialogOpen] = useState(false);
  const [holidays, setHolidays] = useState({});
  const [isSuperAdmin, setIsSuperAdmin] = useState(false);

  const [currentDate, setCurrentDate] = useState(new Date());
  const [selectedYear, setSelectedYear] = useState(currentYear);
  const [selectedMonth, setSelectedMonth] = useState(currentMonth);
  const [calendarData, setCalendarData] = useState({});
  const [selectedDate, setSelectedDate] = useState(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);


  // Generate years array (last 10 years to next 10 years)
  const years = Array.from(
    { length: 21 }, 
    (_, i) => currentYear - 10 + i
  );

  // Month names
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June', 
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  useEffect(() => {
    // Update currentDate when year or month is changed
    const newDate = new Date(selectedYear, selectedMonth, 1);
    setCurrentDate(newDate);
    fetchCalendarData();
    fetchHolidays();
    const user = JSON.parse(localStorage.getItem('user'));
    setIsSuperAdmin(user?.role === 'super-admin');
  }, [selectedYear, selectedMonth]);

  const fetchHolidays = async () => {
    try {
      const firstDay = new Date(selectedYear, selectedMonth, 1);
      // Set the lastDay to the first day of next month, then subtract 1 millisecond
      const lastDay = new Date(selectedYear, selectedMonth + 1, 1);
      lastDay.setMilliseconds(-1);
      
      const response = await apiClient.get(`/Holiday`, {
        params: {
          startDate: firstDay.toISOString(),
          endDate: lastDay.toISOString()
        }
      });
      
      const holidayMap = {};
      response.data.forEach(holiday => {
        // Ensure consistent date handling by creating a new Date object
        const holidayDate = new Date(holiday.holidayDate);
        holidayMap[holidayDate.toDateString()] = holiday;
      });
      
      setHolidays(holidayMap);
    } catch (error) {
      console.error('Error fetching holidays:', error);
    }
  };
  

  const handleAddHoliday = async (holidayData) => {
    if (!isSuperAdmin) {
      alert('Only super-admin users can add holidays');
      return;
    }
    
    try {
      await apiClient.post(`/leave/holidays`, {
        holidayDate: holidayData.holidayDate,
        holidayName: holidayData.holidayName
      });
      setIsHolidayDialogOpen(false);
      fetchHolidays();
    } catch (error) {
      console.error('Error adding holiday:', error);
    }
  };

  const handleDeleteHoliday = async (holidayId) => {
    if (!isSuperAdmin) {
      alert('Only super-admin users can delete holidays');
      return;
    }

    if (window.confirm('Are you sure you want to delete this holiday?')) {
      try {
        await apiClient.delete(`/leave/holidays/${holidayId}`);
        fetchHolidays();
      } catch (error) {
        console.error('Error deleting holiday:', error);
      }
    }
  };


  const fetchCalendarData = async () => {
    try {
      const firstDay = new Date(selectedYear, selectedMonth, 1);
      // Extend the range by a week before and after the current month
      const lastDay = new Date(selectedYear, selectedMonth + 1, 0);
      const extendedStartDate = new Date(firstDay.setDate(firstDay.getDate() - 7));
      const extendedEndDate = new Date(lastDay.setDate(lastDay.getDate() + 7));
  
      const data = await getCalendarData(extendedStartDate, extendedEndDate);
      
      const dataMap = {};
      data.forEach(item => {
        dataMap[new Date(item.date).toDateString()] = item.users;
      });
      setCalendarData(dataMap);
    } catch (error) {
      console.error('Error fetching calendar data:', error);
    }
  };

  const formatDateRange = (startDate, endDate) => {
    const start = new Date(startDate);
    const end = new Date(endDate);
    end.setDate(end.getDate() - 1);
    const options = { month: 'short', day: 'numeric' };
    return `${start.toLocaleDateString('en-US', options)} - ${end.toLocaleDateString('en-US', options)}`;
  };

  const getDaysInMonth = (date) => {
    return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
  };

  const getFirstDayOfMonth = (date) => {
    return new Date(date.getFullYear(), date.getMonth(), 1).getDay();
  };

  const handlePrevMonth = () => {
    const newMonth = selectedMonth === 0 ? 11 : selectedMonth - 1;
    const newYear = selectedMonth === 0 ? selectedYear - 1 : selectedYear;
    setSelectedYear(newYear);
    setSelectedMonth(newMonth);
  };

  const handleNextMonth = () => {
    const newMonth = selectedMonth === 11 ? 0 : selectedMonth + 1;
    const newYear = selectedMonth === 11 ? selectedYear + 1 : selectedYear;
    setSelectedYear(newYear);
    setSelectedMonth(newMonth);
  };

  const renderCalendarDays = () => {
    const daysInMonth = getDaysInMonth(currentDate);
    const firstDay = getFirstDayOfMonth(currentDate);
    const days = [];

    for (let i = 0; i < firstDay; i++) {
      days.push(
        <div 
          key={`empty-${i}`} 
          className="calendar-empty opacity-20"
        ></div>
      );
    }

    for (let day = 1; day <= daysInMonth; day++) {
      const date = new Date(selectedYear, selectedMonth, day);
      // Ensure the date is set to midnight
      date.setHours(0, 0, 0, 0);
      const dateString = date.toDateString();
      
      const holiday = holidays[dateString];
      const usersOnLeave = calendarData[dateString] || [];
      const annualLeaveUsers = usersOnLeave.filter(user => user.reason.includes('Annual Leave'));
      const medicalLeaveUsers = usersOnLeave.filter(user => user.reason.includes('Medical Leave'));
  
      days.push(
        <div
          key={day}
          className={`
            calendar-day 
            group
            ${usersOnLeave.length > 0 ? 'cursor-pointer hover:bg-blue-50' : ''}
            ${holiday ? 'bg-purple-100/50' : ''}
            ${annualLeaveUsers.length > 0 ? 'bg-blue-100/50' : ''} 
            ${medicalLeaveUsers.length > 0 ? 'bg-red-100/50' : ''}
            relative
          `}
          onClick={() => {
            if (usersOnLeave.length > 0) {
              setSelectedDate({ date: dateString, users: usersOnLeave });
              setIsDialogOpen(true);
            }
          }}
        >
          <div className="calendar-day-number text-gray-700 font-medium">
            {day}
          </div>
          {holiday && (
            <div className="absolute top-8 left-1 right-1">
              <div className="text-xs bg-purple-500 text-white px-1 py-0.5 rounded truncate">
                {holiday.holidayName}
              </div>
              {isSuperAdmin && (
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    handleDeleteHoliday(holiday.holidayId);
                  }}
                  className="absolute -right-1 -top-1 bg-white rounded-full p-0.5 shadow-sm 
                  opacity-0 group-hover:opacity-100 transition-opacity"
                >
                  <Trash2 size={12} className="text-red-500" />
                </button>
              )}
            </div>
          )}
          {(annualLeaveUsers.length > 0 || medicalLeaveUsers.length > 0) && (
            <div className="absolute bottom-1 right-1 flex space-x-1">
              {annualLeaveUsers.length > 0 && (
                <span className="bg-blue-500 text-white text-[10px] px-1 rounded-full">
                  {annualLeaveUsers.length}
                </span>
              )}
              {medicalLeaveUsers.length > 0 && (
                <span className="bg-red-500 text-white text-[10px] px-1 rounded-full">
                  {medicalLeaveUsers.length}
                </span>
              )}
            </div>
          )}
        </div>
      );
    }
  
    return days;
  };

  return (
    <div className="bg-white shadow-sm rounded-2xl overflow-hidden border border-gray-200">
      <div className="bg-gray-50 p-6 border-b border-gray-200">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <select 
              value={selectedYear} 
              onChange={(e) => setSelectedYear(parseInt(e.target.value))}
              className="px-3 py-2 border border-gray-300 rounded-lg 
              focus:ring-2 focus:ring-blue-500 focus:border-transparent 
              transition-all duration-300 text-gray-700"
            >
              {years.map((year) => (
                <option key={year} value={year}>
                  {year}
                </option>
              ))}
            </select>

            <select 
              value={selectedMonth} 
              onChange={(e) => setSelectedMonth(parseInt(e.target.value))}
              className="px-3 py-2 border border-gray-300 rounded-lg 
              focus:ring-2 focus:ring-blue-500 focus:border-transparent 
              transition-all duration-300 text-gray-700"
            >
              {months.map((month, index) => (
                <option key={month} value={index}>
                  {month}
                </option>
              ))}
            </select>

            {isSuperAdmin && (
              <button
                onClick={() => setIsHolidayDialogOpen(true)}
                className="flex items-center space-x-2 px-4 py-2 bg-purple-600 text-white rounded-lg 
                hover:bg-purple-700 transition-colors"
              >
                <Plus size={16} />
                <span>Add Holiday</span>
              </button>
            )}
          </div>

          <div className="flex space-x-2">
            <button 
              onClick={handlePrevMonth} 
              className="p-2 text-gray-600 hover:bg-gray-100 rounded-full 
              transition-colors duration-300 group"
            >
              <ChevronLeft 
                className="group-hover:text-blue-600 transition-colors" 
                size={20} 
              />
            </button>
            <button 
              onClick={handleNextMonth} 
              className="p-2 text-gray-600 hover:bg-gray-100 rounded-full 
              transition-colors duration-300 group"
            >
              <ChevronRight 
                className="group-hover:text-blue-600 transition-colors" 
                size={20} 
              />
            </button>
          </div>
        </div>
      </div>

      <div className="calendar-grid">
        {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(day => (
          <div 
            key={day} 
            className="calendar-weekday text-gray-500 font-semibold"
          >
            {day}
          </div>
        ))}
        {renderCalendarDays()}
      </div>

      <CustomDialog
        isOpen={isDialogOpen}
        onClose={() => setIsDialogOpen(false)}
        title={`Leave Details - ${selectedDate?.date}`}
      >
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>
                <Users className="inline-block mr-2 text-blue-600" size={16} />
                Name
              </TableHead>
              <TableHead>Department</TableHead>
              <TableHead>Leave Period</TableHead>
              <TableHead>Reason</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {selectedDate?.users.map((user, index) => (
              <TableRow key={index} className="hover:bg-gray-50 transition-colors">
                <TableCell>{user.fullName}</TableCell>
                <TableCell>{user.department}</TableCell>
                <TableCell>{formatDateRange(user.startDate, user.endDate)} ({user.noOfDays} days)</TableCell>
                <TableCell>
                  <span 
                    className={`
                      px-2 py-1 rounded-full text-sm font-medium
                      ${user.reason.includes('Medical Leave') 
                        ? 'bg-red-100 text-red-800' 
                        : 'bg-blue-100 text-blue-800'
                      }
                    `}
                  >
                    {user.reason}
                  </span>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CustomDialog>

      <AddHolidayDialog
        isOpen={isHolidayDialogOpen}
        onClose={() => setIsHolidayDialogOpen(false)}
        onSubmit={handleAddHoliday}
      />
    </div>
  );
};

export default LeaveCalendar;