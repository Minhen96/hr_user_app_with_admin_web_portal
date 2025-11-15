// eslint-disable-next-line no-unused-vars
import React, { useState } from "react";
import { NavLink } from "react-router-dom";
import {
  FaAddressBook,
  FaTools,
  FaUser,
  FaFileSignature,
  FaLayerGroup,
  FaCalendar,
  FaBars,
  FaTimes,
  FaQuestionCircle,
} from "react-icons/fa";
import { LogOut } from "lucide-react";
import logo from "../../images/company-logo.jpg";
import userGuide from "../../document/Web User Guide.pdf";
import "./Sidebar.css";

function Sidebar() {
  const [open, setOpen] = useState(false);
  const user = JSON.parse(localStorage.getItem("user"));
  const isUser = user?.role === "user";
  const isDeptAdmin = user?.role === "department-admin";
  const firstName = user?.fullName?.split(" ")[0] || "";

  const items = [
    { to: "/main", icon: FaTools, label: "Equipments" },
    { to: "/document", icon: FaAddressBook, label: "Documents" },
    { to: "/approval", icon: FaFileSignature, label: "Approval" },
    { to: "/leave", icon: FaCalendar, label: "Leave" },
    ...(!(isUser || isDeptAdmin)
      ? [{ to: "/staff", icon: FaLayerGroup, label: "Staff Management" }]
      : []),
  ];

  const handleDownload = () => {
    if (window.confirm("Download the Web User Guide?")) {
      const link = document.createElement("a");
      link.href = userGuide;
      link.download = "Web User Guide.pdf";
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem("user");
  };

  return (
    <>
      {/* Mobile Toggle Button */}
      <button
        onClick={() => setOpen(!open)}
        className="lg:hidden fixed top-4 left-4 z-50 p-2 rounded-md bg-slate-800 text-cyan-400 shadow-lg"
      >
        {open ? <FaTimes size={22} /> : <FaBars size={22} />}
      </button>

      {/* Overlay for mobile */}
      {open && (
        <div
          className="fixed inset-0 bg-black/50 z-40 lg:hidden"
          onClick={() => setOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside
        className={`fixed top-0 left-0 h-screen w-64 bg-gradient-to-b from-slate-900 to-slate-950 text-gray-200 shadow-xl flex flex-col z-50 transition-transform duration-300 ${
          open ? "translate-x-0" : "-translate-x-full lg:translate-x-0"
        }`}
      >
        {/* Header / Logo Section */}
        <div className="relative flex flex-col items-center justify-center py-10 border-b border-slate-800 bg-gradient-to-b from-slate-950/80 to-slate-900/60 backdrop-blur-md shadow-lg">
          {/* Glowing ring effect */}
          <div className="absolute w-36 h-36 bg-cyan-500 rounded-full blur-3xl opacity-20"></div>

          {/* Logo */}
          <div className="relative flex items-center justify-center">
            <div className="absolute -inset-1 bg-cyan-400/30 dark:bg-cyan-300/60 rounded-full blur-xl"></div>
            <div
              className="logo-container relative w-32 h-32 rounded-2xl p-4 border-4 border-cyan-400 dark:border-cyan-300 shadow-2xl flex items-center justify-center"
              style={{
                backgroundColor: 'rgb(255, 255, 255)',
                backgroundImage: 'none'
              }}
            >
              <img
                src={logo}
                alt="Company Logo"
                className="logo-image max-w-full max-h-full object-contain"
                style={{
                  backgroundColor: 'transparent'
                }}
              />
            </div>
          </div>

          {/* Text */}
          <div className="mt-5 text-center">
            <h1 className="text-xl font-semibold text-cyan-300 tracking-wide">
              {isUser ? "Welcome" : "Admin Portal"}
            </h1>
            {isUser && (
              <p className="text-sm text-gray-400 font-medium mt-1">
                Hi, {firstName}
              </p>
            )}
          </div>
        </div>

        {/* Navigation Section */}
        <nav className="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
          <p className="text-xs uppercase text-gray-500 px-3 mb-3 tracking-wider">
            Main Menu
          </p>
          <ul className="space-y-1">
            {items.map(({ to, icon: Icon, label }) => (
              <li key={to}>
                <NavLink
                  to={to}
                  onClick={() => setOpen(false)}
                  className={({ isActive }) =>
                    `flex items-center gap-3 px-4 py-2 rounded-md transition-all duration-200 ${
                      isActive
                        ? "bg-cyan-500/20 border-l-4 border-cyan-400 text-cyan-300"
                        : "hover:bg-slate-800 hover:text-cyan-200"
                    }`
                  }
                >
                  <Icon size={18} />
                  <span className="text-sm font-medium">{label}</span>
                </NavLink>
              </li>
            ))}
          </ul>

          {/* Help Section */}
          <div className="mt-8 border-t border-slate-800 pt-4">
            <p className="text-xs uppercase text-gray-500 px-3 mb-3 tracking-wider">
              Help & Info
            </p>
            <button
              onClick={handleDownload}
              className="flex items-center gap-3 px-4 py-2 w-full text-left rounded-md hover:bg-slate-800 hover:text-cyan-200 transition-all duration-200"
            >
              <FaQuestionCircle size={18} />
              <span className="text-sm font-medium">User Guide</span>
            </button>
          </div>
        </nav>

        {/* Footer / Profile + Logout */}
        <div className="border-t border-slate-800 bg-slate-950/60 p-4">
          <NavLink
            to="/profile"
            onClick={() => setOpen(false)}
            className="flex items-center gap-3 px-4 py-2 rounded-md hover:bg-slate-800 hover:text-cyan-200 transition-all duration-200 mb-2"
          >
            <FaUser size={18} />
            <span className="text-sm font-medium">Profile</span>
          </NavLink>

          <NavLink
            to="/"
            onClick={handleLogout}
            className="flex items-center gap-3 px-4 py-2 rounded-md text-red-400 hover:bg-red-500/10 hover:text-red-300 transition-all duration-200"
          >
            <LogOut size={18} />
            <span className="text-sm font-medium">Logout</span>
          </NavLink>
        </div>
      </aside>
    </>
  );
}

export default Sidebar;
