import React from 'react';

export const ModernBadge = ({
  children,
  variant = 'default',
  size = 'md',
  className = '',
  ...props
}) => {
  const variants = {
    default: 'bg-primary-purple/20 text-primary-purple dark:bg-primary-purple/30 dark:text-primary-purple-light',
    success: 'gradient-success text-white',
    warning: 'bg-warning/20 text-warning dark:bg-warning/30 dark:text-yellow-300',
    error: 'bg-error/20 text-error dark:bg-error/30 dark:text-red-300',
    info: 'bg-info/20 text-info dark:bg-info/30 dark:text-blue-300',
    purple: 'gradient-purple text-white',
    cyan: 'gradient-cyan text-white',
    outline: 'border-2 border-primary-purple text-primary-purple bg-transparent dark:border-primary-purple-light dark:text-primary-purple-light',
  };

  const sizes = {
    sm: 'px-2 py-0.5 text-xs',
    md: 'px-3 py-1 text-sm',
    lg: 'px-4 py-1.5 text-base',
  };

  return (
    <span
      className={`
        ${variants[variant]}
        ${sizes[size]}
        ${className}
        inline-flex items-center
        rounded-full
        font-semibold
        transition-all duration-300
      `}
      {...props}
    >
      {children}
    </span>
  );
};
