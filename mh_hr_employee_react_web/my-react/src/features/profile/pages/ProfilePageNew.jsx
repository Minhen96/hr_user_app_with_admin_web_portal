import React, { useEffect, useState } from "react";
import { motion } from 'framer-motion';
import {
  User,
  Lock,
  Mail,
  Building2,
  ShieldCheck,
  Calendar,
  BadgeCheck,
  CreditCard,
  IdCard
} from 'lucide-react';
import PasswordChangeDialog from '../components/PasswordChangeDialog';
import { GlassCard, GlassCardContent } from '../../../components/modern/GlassCard';
import { GradientButton } from '../../../components/modern/GradientButton';
import { ModernBadge } from '../../../components/modern/ModernBadge';

function ProfilePage() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isPasswordDialogOpen, setIsPasswordDialogOpen] = useState(false);

  useEffect(() => {
    const storedUser = localStorage.getItem("user");
    if (storedUser) {
      try {
        const userData = JSON.parse(storedUser);
        setUser(userData);
      } catch (error) {
        console.error("Error parsing user data:", error);
      }
    }
    setLoading(false);
  }, []);

  const getRoleDisplay = (user) => {
    const roleMap = {
      'super-admin': 'Super Admin',
      'department-admin': 'Department Admin',
      'user': 'User'
    };
    return roleMap[user.role.toLowerCase()] || user.role;
  };

  const getRoleBadgeVariant = (role) => {
    const variants = {
      'super-admin': 'purple',
      'department-admin': 'cyan',
      'user': 'default'
    };
    return variants[role?.toLowerCase()] || 'default';
  };

  const getDepartmentDisplay = (user) => {
    return user.role.toLowerCase() === 'super-admin'
      ? 'Access to All Departments'
      : user.departmentName;
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen">
        <div className="w-16 h-16 border-4 border-primary-purple/30 border-t-primary-purple rounded-full animate-spin" />
      </div>
    );
  }

  if (!user) {
    return (
      <div className="flex justify-center items-center h-screen">
        <GlassCard className="p-8">
          <p className="text-error text-lg">Please log in to view your profile.</p>
        </GlassCard>
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold text-text-primary dark:text-white">Profile</h1>
          <p className="text-text-secondary mt-1">
            Manage your personal information and account settings
          </p>
        </div>
      </div>

      {/* Profile Header Card */}
      <GlassCard gradient gradientType="purple" animate>
        <div className="flex flex-col sm:flex-row items-center gap-6 p-6">
          <div className="w-24 h-24 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white text-4xl font-bold border-4 border-white/30">
            {user.fullName?.charAt(0).toUpperCase()}
          </div>
          <div className="flex-1 text-center sm:text-left">
            <h2 className="text-2xl font-bold text-white mb-2">{user.fullName}</h2>
            <div className="flex flex-wrap gap-2 justify-center sm:justify-start">
              <ModernBadge variant={getRoleBadgeVariant(user.role)} size="md" className="bg-white/20 text-white border-white/30">
                {getRoleDisplay(user)}
              </ModernBadge>
              {user.departmentName && (
                <ModernBadge variant="outline" size="md" className="bg-white/10 text-white border-white/30">
                  {user.departmentName}
                </ModernBadge>
              )}
            </div>
          </div>
        </div>
      </GlassCard>

      {/* Information Grid */}
      <div className="grid md:grid-cols-2 gap-6">
        {/* Personal Information */}
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.1 }}
        >
          <GlassCard>
            <div className="p-6">
              <div className="flex items-center gap-3 mb-6">
                <div className="p-2.5 rounded-lg gradient-cyan">
                  <User className="w-5 h-5 text-white" />
                </div>
                <h3 className="text-xl font-semibold text-text-primary dark:text-white">
                  Personal Information
                </h3>
              </div>
              <div className="space-y-4">
                <ProfileRow
                  icon={<User className="w-5 h-5 text-primary-purple" />}
                  label="Full Name"
                  value={user.fullName}
                />
                <ProfileRow
                  icon={<IdCard className="w-5 h-5 text-secondary-cyan" />}
                  label="NRIC"
                  value={user.nric}
                />
                {user.tin && (
                  <ProfileRow
                    icon={<CreditCard className="w-5 h-5 text-success" />}
                    label="TIN"
                    value={user.tin}
                  />
                )}
                {user.epfNo && (
                  <ProfileRow
                    icon={<BadgeCheck className="w-5 h-5 text-accent-pink" />}
                    label="EPF Number"
                    value={user.epfNo}
                  />
                )}
              </div>
            </div>
          </GlassCard>
        </motion.div>

        {/* Account Information */}
        <motion.div
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.2 }}
        >
          <GlassCard>
            <div className="p-6">
              <div className="flex items-center gap-3 mb-6">
                <div className="p-2.5 rounded-lg gradient-success">
                  <Mail className="w-5 h-5 text-white" />
                </div>
                <h3 className="text-xl font-semibold text-text-primary dark:text-white">
                  Account Information
                </h3>
              </div>
              <div className="space-y-4">
                <ProfileRow
                  icon={<Mail className="w-5 h-5 text-info" />}
                  label="Email Address"
                  value={user.email}
                />
                <ProfileRow
                  icon={<BadgeCheck className="w-5 h-5 text-warning" />}
                  label="User ID"
                  value={`#${user.id}`}
                />
                <div className="pt-4">
                  <GradientButton
                    variant="purple"
                    icon={<Lock />}
                    onClick={() => setIsPasswordDialogOpen(true)}
                    fullWidth
                  >
                    Change Password
                  </GradientButton>
                </div>
              </div>
            </div>
          </GlassCard>
        </motion.div>

        {/* Role & Department - Full Width */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="md:col-span-2"
        >
          <GlassCard>
            <div className="p-6">
              <div className="flex items-center gap-3 mb-6">
                <div className="p-2.5 rounded-lg gradient-purple">
                  <ShieldCheck className="w-5 h-5 text-white" />
                </div>
                <h3 className="text-xl font-semibold text-text-primary dark:text-white">
                  Role & Permissions
                </h3>
              </div>
              <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
                <ProfileRow
                  icon={<ShieldCheck className="w-5 h-5 text-primary-purple" />}
                  label="Role"
                  value={getRoleDisplay(user)}
                />
                <ProfileRow
                  icon={<Building2 className="w-5 h-5 text-secondary-cyan" />}
                  label="Department"
                  value={getDepartmentDisplay(user)}
                />
                {user.dateJoined && (
                  <ProfileRow
                    icon={<Calendar className="w-5 h-5 text-success" />}
                    label="Date Joined"
                    value={new Date(user.dateJoined).toLocaleDateString('en-US', {
                      year: 'numeric',
                      month: 'long',
                      day: 'numeric'
                    })}
                  />
                )}
              </div>
            </div>
          </GlassCard>
        </motion.div>
      </div>

      {/* Additional Info Cards */}
      <div className="grid sm:grid-cols-3 gap-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
        >
          <GlassCard gradient gradientType="success">
            <div className="p-6 text-center">
              <BadgeCheck className="w-10 h-10 text-white mx-auto mb-3" />
              <p className="text-white/80 text-sm mb-1">Account Status</p>
              <p className="text-white font-semibold text-lg">Active</p>
            </div>
          </GlassCard>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
        >
          <GlassCard gradient gradientType="cyan">
            <div className="p-6 text-center">
              <ShieldCheck className="w-10 h-10 text-white mx-auto mb-3" />
              <p className="text-white/80 text-sm mb-1">Access Level</p>
              <p className="text-white font-semibold text-lg">{getRoleDisplay(user)}</p>
            </div>
          </GlassCard>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
        >
          <GlassCard gradient gradientType="pink">
            <div className="p-6 text-center">
              <Building2 className="w-10 h-10 text-white mx-auto mb-3" />
              <p className="text-white/80 text-sm mb-1">Department</p>
              <p className="text-white font-semibold text-lg truncate">
                {user.departmentName || 'All'}
              </p>
            </div>
          </GlassCard>
        </motion.div>
      </div>

      {/* Password Change Dialog */}
      <PasswordChangeDialog
        isOpen={isPasswordDialogOpen}
        onClose={() => setIsPasswordDialogOpen(false)}
      />
    </div>
  );
}

// Modern Profile Row Component
function ProfileRow({ label, value, icon }) {
  return (
    <div className="flex items-start gap-3 p-4 bg-surface dark:bg-surface-variant rounded-lg">
      <div className="p-2 bg-background rounded-lg">
        {icon}
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-xs text-text-hint uppercase tracking-wider mb-1">{label}</p>
        <p className="font-medium text-text-primary dark:text-white break-words">
          {value || 'N/A'}
        </p>
      </div>
    </div>
  );
}

export default ProfilePage;
