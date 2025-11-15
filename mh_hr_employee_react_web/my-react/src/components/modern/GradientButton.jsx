import React from 'react';
import { motion } from 'framer-motion';

export const GradientButton = ({
  children,
  variant = 'purple',
  size = 'md',
  className = '',
  onClick,
  disabled = false,
  loading = false,
  icon = null,
  fullWidth = false,
  type = 'button',
  ...props
}) => {
  const variants = {
    purple: 'gradient-purple hover:gradient-purple-hover shadow-glow-purple',
    cyan: 'gradient-cyan shadow-glow-cyan',
    success: 'gradient-success shadow-glow-success',
    warning: 'gradient-warning',
    pink: 'gradient-pink shadow-glow-pink',
    outline: 'border-2 border-primary-purple text-primary-purple hover:bg-primary-purple/10',
    ghost: 'text-primary-purple hover:bg-primary-purple/10',
  };

  const sizes = {
    sm: 'px-3 py-2 text-sm h-9',
    md: 'px-4 py-2.5 text-base h-11',
    lg: 'px-6 py-3 text-lg h-14',
  };

  const baseClasses = variant === 'outline' || variant === 'ghost'
    ? variants[variant]
    : `${variants[variant]} text-white`;

  const widthClass = fullWidth ? 'w-full' : '';
  const disabledClasses = disabled ? 'opacity-50 cursor-not-allowed' : 'btn-press';

  return (
    <motion.button
      type={type}
      className={`
        ${baseClasses}
        ${sizes[size]}
        ${widthClass}
        ${disabledClasses}
        ${className}
        rounded-xl font-semibold
        transition-all duration-300
        flex items-center justify-center gap-2
        disabled:pointer-events-none
      `}
      onClick={onClick}
      disabled={disabled || loading}
      whileTap={!disabled && !loading ? { scale: 0.95 } : {}}
      {...props}
    >
      {loading ? (
        <div className="flex items-center gap-2">
          <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
          <span>Loading...</span>
        </div>
      ) : (
        <>
          {icon && <span className="text-lg">{icon}</span>}
          {children}
        </>
      )}
    </motion.button>
  );
};

export const IconButton = ({
  icon,
  onClick,
  className = '',
  size = 'md',
  variant = 'purple',
  ...props
}) => {
  const sizes = {
    sm: 'w-8 h-8 text-sm',
    md: 'w-10 h-10 text-base',
    lg: 'w-12 h-12 text-lg',
  };

  const variants = {
    purple: 'bg-primary-purple/20 text-primary-purple hover:bg-primary-purple/30',
    cyan: 'bg-secondary-cyan/20 text-secondary-cyan hover:bg-secondary-cyan/30',
    success: 'bg-success/20 text-success hover:bg-success/30',
    error: 'bg-error/20 text-error hover:bg-error/30',
  };

  return (
    <motion.button
      className={`
        ${sizes[size]}
        ${variants[variant]}
        ${className}
        rounded-lg
        flex items-center justify-center
        transition-all duration-300
        btn-press
      `}
      onClick={onClick}
      whileTap={{ scale: 0.9 }}
      {...props}
    >
      {icon}
    </motion.button>
  );
};
