import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
  FaTools, FaFileAlt, FaUsers, FaCalendarAlt, FaUser,
  FaSignOutAlt, FaBars, FaTimes, FaMoon, FaSun, FaCheckCircle
} from 'react-icons/fa';
import logo from '../../images/logo_transaparent.png';

export const ModernTopNav = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [darkMode, setDarkMode] = useState(true);
  const [profileMenuOpen, setProfileMenuOpen] = useState(false);

  const userData = JSON.parse(localStorage.getItem('user') || '{}');
  const isSuperAdmin = userData.role === 'super-admin';

  const menuItems = [
    { path: '/main', label: 'Equipment', icon: <FaTools /> },
    { path: '/document', label: 'Documents', icon: <FaFileAlt /> },
    ...(isSuperAdmin ? [{ path: '/staff', label: 'Staff', icon: <FaUsers /> }] : []),
    { path: '/leave', label: 'Leave', icon: <FaCalendarAlt /> },
    { path: '/approval', label: 'Approvals', icon: <FaCheckCircle /> },
  ];

  const handleLogout = () => {
    localStorage.clear();
    navigate('/');
  };

  const toggleTheme = () => {
    setDarkMode(!darkMode);
    document.documentElement.classList.toggle('dark');
  };

  const isActive = (path) => location.pathname === path;

  return (
    <>
      {/* Top Navigation Bar */}
      <nav className="fixed top-0 left-0 right-0 z-50 bg-white dark:bg-slate-900 backdrop-blur-md border-b border-slate-200 dark:border-slate-700 shadow-lg">
        <div className="max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            {/* Logo */}
            <div className="flex items-center gap-3">
              <motion.div
                whileHover={{ scale: 1.05 }}
                transition={{ duration: 0.2 }}
                className="h-10 w-10 rounded-lg overflow-hidden p-1.5 ring-2 ring-purple-500/50"
                style={{ backgroundColor: '#ffffff' }}
              >
                <img
                  src={logo}
                  alt="MH HR Logo"
                  className="h-full w-full object-contain"
                />
              </motion.div>
              <div>
                <h1 className="text-xl font-extrabold bg-gradient-to-r from-purple-600 via-purple-500 to-pink-500 dark:from-purple-400 dark:via-purple-300 dark:to-pink-400 bg-clip-text text-transparent drop-shadow-sm">
                  MH HR Admin
                </h1>
                <p className="text-xs font-medium text-slate-600 dark:text-slate-400">
                  Employee Management System
                </p>
              </div>
            </div>

            {/* Desktop Menu - ALWAYS VISIBLE */}
            <div className="flex items-center gap-2 flex-1 justify-center">
              {menuItems.map((item) => (
                <motion.button
                  key={item.path}
                  onClick={() => {
                    console.log('Navigating to:', item.path);
                    navigate(item.path);
                  }}
                  className={`
                    px-3 py-2 rounded-lg flex items-center gap-2
                    font-medium transition-all duration-300 text-sm
                    ${isActive(item.path)
                      ? 'bg-purple-600 text-white shadow-lg'
                      : 'text-slate-700 dark:text-slate-200 hover:bg-slate-200 dark:hover:bg-slate-700'
                    }
                  `}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                >
                  <span className="text-base">{item.icon}</span>
                  <span className="hidden sm:inline">{item.label}</span>
                </motion.button>
              ))}
            </div>

            {/* Right Side Actions */}
            <div className="flex items-center gap-3">
              {/* Theme Toggle */}
              <motion.button
                onClick={toggleTheme}
                className="p-2 rounded-lg bg-surface dark:bg-surface-variant text-text-primary dark:text-white"
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
              >
                {darkMode ? <FaSun size={18} /> : <FaMoon size={18} />}
              </motion.button>

              {/* Profile Menu */}
              <div className="relative">
                <motion.button
                  onClick={() => setProfileMenuOpen(!profileMenuOpen)}
                  className="flex items-center gap-2 px-3 py-2 rounded-lg bg-surface dark:bg-surface-variant"
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                >
                  <div className="w-8 h-8 rounded-full gradient-purple flex items-center justify-center text-white font-semibold">
                    {userData.fullName?.charAt(0) || 'U'}
                  </div>
                  <div className="text-left">
                    <p className="text-sm font-medium text-text-primary dark:text-white">
                      {userData.fullName || 'User'}
                    </p>
                    <p className="text-xs text-text-secondary capitalize">
                      {userData.role || 'user'}
                    </p>
                  </div>
                </motion.button>

                <AnimatePresence>
                  {profileMenuOpen && (
                    <motion.div
                      initial={{ opacity: 0, y: -10 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -10 }}
                      className="absolute right-0 mt-2 w-48 bg-white dark:bg-slate-800 rounded-xl shadow-2xl overflow-hidden border border-slate-200 dark:border-slate-700"
                    >
                      <button
                        onClick={() => {
                          navigate('/profile');
                          setProfileMenuOpen(false);
                        }}
                        className="w-full px-4 py-3 text-left flex items-center gap-2 hover:bg-surface dark:hover:bg-surface-variant transition-colors"
                      >
                        <FaUser />
                        <span>Profile</span>
                      </button>
                      <button
                        onClick={handleLogout}
                        className="w-full px-4 py-3 text-left flex items-center gap-2 hover:bg-error/10 text-error transition-colors"
                      >
                        <FaSignOutAlt />
                        <span>Logout</span>
                      </button>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>

            </div>
          </div>
        </div>
      </nav>

      {/* Mobile Menu */}
      <AnimatePresence>
        {mobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0, x: '100%' }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: '100%' }}
            transition={{ type: 'tween' }}
            className="fixed inset-0 z-40 md:hidden"
          >
            {/* Backdrop */}
            <div
              className="absolute inset-0 bg-black/50 backdrop-blur-sm"
              onClick={() => setMobileMenuOpen(false)}
            />

            {/* Menu Content */}
            <div className="absolute right-0 top-0 bottom-0 w-72 bg-white dark:bg-slate-900 border-l border-slate-200 dark:border-slate-700 p-6 overflow-y-auto shadow-2xl">
              <div className="flex flex-col gap-6">
                {/* User Info */}
                <div className="flex items-center gap-3 pb-6 border-b border-border">
                  <div className="w-12 h-12 rounded-full gradient-purple flex items-center justify-center text-white font-bold text-xl">
                    {userData.fullName?.charAt(0) || 'U'}
                  </div>
                  <div>
                    <p className="font-semibold text-text-primary dark:text-white">
                      {userData.fullName || 'User'}
                    </p>
                    <p className="text-sm text-text-secondary capitalize">
                      {userData.role || 'user'}
                    </p>
                  </div>
                </div>

                {/* Menu Items */}
                <div className="flex flex-col gap-2">
                  {menuItems.map((item) => (
                    <motion.button
                      key={item.path}
                      onClick={() => {
                        navigate(item.path);
                        setMobileMenuOpen(false);
                      }}
                      className={`
                        px-4 py-3 rounded-lg flex items-center gap-3
                        font-medium transition-all duration-300 text-left
                        ${isActive(item.path)
                          ? 'gradient-purple text-white shadow-glow-purple'
                          : 'text-slate-700 dark:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800'
                        }
                      `}
                      whileTap={{ scale: 0.95 }}
                    >
                      {item.icon}
                      <span>{item.label}</span>
                    </motion.button>
                  ))}
                </div>

                {/* Actions */}
                <div className="pt-6 border-t border-border flex flex-col gap-2">
                  <button
                    onClick={() => {
                      navigate('/profile');
                      setMobileMenuOpen(false);
                    }}
                    className="px-4 py-3 rounded-lg flex items-center gap-3 text-left hover:bg-surface dark:hover:bg-surface-variant transition-colors"
                  >
                    <FaUser />
                    <span>Profile</span>
                  </button>
                  <button
                    onClick={handleLogout}
                    className="px-4 py-3 rounded-lg flex items-center gap-3 text-left hover:bg-error/10 text-error transition-colors"
                  >
                    <FaSignOutAlt />
                    <span>Logout</span>
                  </button>
                </div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
};
