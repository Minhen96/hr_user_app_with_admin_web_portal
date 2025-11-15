import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { motion } from "framer-motion";
import { login } from "../api/authApi";
import { Mail, Lock, LogIn, AlertCircle } from "lucide-react";
import logo from "../../../images/company-logo.jpg";

function LoginPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleLoginClick = async () => {
    setIsLoading(true);
    setErrorMessage("");

    try {
      const response = await login(email, password);

      if (response.success && response.user) {
        localStorage.setItem("user", JSON.stringify(response.user));
        console.log("Login successful:", response.user);
        navigate("/main");
      } else {
        setErrorMessage(response.message || "Login failed. Please check your credentials.");
      }
    } catch (error) {
      console.error("Login error:", error);
      const errorMsg = error.response?.data?.message || error.message || "An error occurred during login. Please try again.";
      setErrorMessage(errorMsg);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    handleLoginClick();
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 p-4">
      {/* Animated Background Elements */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-purple-500/20 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-cyan-500/20 rounded-full blur-3xl animate-pulse delay-700"></div>
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="relative w-full max-w-5xl"
      >
        <div className="bg-white/10 backdrop-blur-xl rounded-3xl shadow-2xl border border-white/20 overflow-hidden">
          <div className="grid md:grid-cols-2 gap-0">
            {/* Left Side - Branding */}
            <div className="hidden md:flex flex-col justify-center items-center p-12 bg-gradient-to-br from-purple-600 to-purple-900 relative overflow-hidden">
              <div className="absolute inset-0 bg-black/20"></div>
              <div className="relative z-10 text-center">
                <motion.div
                  initial={{ scale: 0.8, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  transition={{ delay: 0.2, duration: 0.5 }}
                  className="mb-8"
                >
                  <img
                    src={logo}
                    alt="Company Logo"
                    className="w-48 h-48 object-contain mx-auto rounded-2xl shadow-2xl border-4 border-white/30"
                  />
                </motion.div>
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.4 }}
                >
                  <h1 className="text-4xl font-bold text-white mb-4">
                    MH HR System
                  </h1>
                  <p className="text-purple-100 text-lg">
                    Employee Management Portal
                  </p>
                  <div className="mt-8 space-y-3 text-left max-w-xs mx-auto">
                    <div className="flex items-center gap-3 text-purple-100">
                      <div className="w-2 h-2 bg-purple-300 rounded-full"></div>
                      <span>Equipment Management</span>
                    </div>
                    <div className="flex items-center gap-3 text-purple-100">
                      <div className="w-2 h-2 bg-purple-300 rounded-full"></div>
                      <span>Document Center</span>
                    </div>
                    <div className="flex items-center gap-3 text-purple-100">
                      <div className="w-2 h-2 bg-purple-300 rounded-full"></div>
                      <span>Leave Management</span>
                    </div>
                    <div className="flex items-center gap-3 text-purple-100">
                      <div className="w-2 h-2 bg-purple-300 rounded-full"></div>
                      <span>Staff Administration</span>
                    </div>
                  </div>
                </motion.div>
              </div>
            </div>

            {/* Right Side - Login Form */}
            <div className="p-8 md:p-12 flex flex-col justify-center bg-white dark:bg-slate-900">
              <motion.div
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.3 }}
              >
                {/* Mobile Logo */}
                <div className="md:hidden mb-8 text-center">
                  <img
                    src={logo}
                    alt="Company Logo"
                    className="w-24 h-24 object-contain mx-auto rounded-xl shadow-lg"
                  />
                </div>

                <div className="mb-8">
                  <h2 className="text-3xl font-bold text-slate-900 dark:text-white mb-2">
                    Welcome Back
                  </h2>
                  <p className="text-slate-600 dark:text-slate-400">
                    Please login to your account
                  </p>
                </div>

                <form onSubmit={handleSubmit} className="space-y-6">
                  {/* Email Input */}
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
                      Email Address
                    </label>
                    <div className="relative">
                      <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                        <Mail className="h-5 w-5 text-slate-400" />
                      </div>
                      <input
                        type="email"
                        placeholder="Enter your email"
                        className="w-full pl-12 pr-4 py-3 bg-slate-50 dark:bg-slate-800 border-2 border-slate-200 dark:border-slate-700 rounded-xl text-slate-900 dark:text-white placeholder:text-slate-400 focus:border-purple-500 focus:ring-4 focus:ring-purple-500/20 outline-none transition-all"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                      />
                    </div>
                  </div>

                  {/* Password Input */}
                  <div>
                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
                      Password
                    </label>
                    <div className="relative">
                      <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                        <Lock className="h-5 w-5 text-slate-400" />
                      </div>
                      <input
                        type="password"
                        placeholder="Enter your password"
                        className="w-full pl-12 pr-4 py-3 bg-slate-50 dark:bg-slate-800 border-2 border-slate-200 dark:border-slate-700 rounded-xl text-slate-900 dark:text-white placeholder:text-slate-400 focus:border-purple-500 focus:ring-4 focus:ring-purple-500/20 outline-none transition-all"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        required
                      />
                    </div>
                  </div>

                  {/* Error Message */}
                  {errorMessage && (
                    <motion.div
                      initial={{ opacity: 0, y: -10 }}
                      animate={{ opacity: 1, y: 0 }}
                      className="flex items-start gap-3 p-4 bg-red-50 dark:bg-red-900/20 border-2 border-red-200 dark:border-red-800 rounded-xl"
                    >
                      <AlertCircle className="h-5 w-5 text-red-600 dark:text-red-400 flex-shrink-0 mt-0.5" />
                      <p className="text-sm text-red-600 dark:text-red-400 font-medium">
                        {errorMessage}
                      </p>
                    </motion.div>
                  )}

                  {/* Login Button */}
                  <motion.button
                    type="submit"
                    disabled={isLoading}
                    className="w-full py-4 bg-gradient-to-r from-purple-600 to-purple-700 hover:from-purple-700 hover:to-purple-800 text-white font-semibold rounded-xl shadow-lg shadow-purple-500/50 hover:shadow-purple-500/70 transition-all duration-300 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                    whileHover={{ scale: isLoading ? 1 : 1.02 }}
                    whileTap={{ scale: isLoading ? 1 : 0.98 }}
                  >
                    {isLoading ? (
                      <>
                        <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                        <span>Logging in...</span>
                      </>
                    ) : (
                      <>
                        <LogIn className="w-5 h-5" />
                        <span>LOGIN</span>
                      </>
                    )}
                  </motion.button>
                </form>

                {/* Footer */}
                <div className="mt-8 text-center text-sm text-slate-500 dark:text-slate-400">
                  <p>© 2024 MH HR System. All rights reserved.</p>
                </div>
              </motion.div>
            </div>
          </div>
        </div>
      </motion.div>
    </div>
  );
}

export default LoginPage;
