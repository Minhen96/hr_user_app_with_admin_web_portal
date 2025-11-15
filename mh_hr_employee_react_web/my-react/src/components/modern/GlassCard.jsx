import React from 'react';
import { motion } from 'framer-motion';

export const GlassCard = ({
  children,
  className = '',
  gradient = false,
  gradientType = 'purple',
  hover = false,
  onClick,
  animate = true,
  delay = 0,
  ...props
}) => {
  const gradientClasses = {
    purple: 'gradient-purple',
    cyan: 'gradient-cyan',
    success: 'gradient-success',
    warning: 'gradient-warning',
    pink: 'gradient-pink',
  };

  const baseClasses = gradient
    ? `${gradientClasses[gradientType]} text-white`
    : 'glass-card';

  const hoverClasses = hover ? 'hover:shadow-glow-purple hover:scale-[1.02] transition-all duration-300' : '';
  const cursorClass = onClick ? 'cursor-pointer' : '';

  const Component = animate ? motion.div : 'div';

  const animationProps = animate ? {
    initial: { opacity: 0, y: 20 },
    animate: { opacity: 1, y: 0 },
    transition: { duration: 0.3, delay }
  } : {};

  return (
    <Component
      className={`rounded-xl p-lg ${baseClasses} ${hoverClasses} ${cursorClass} ${className}`}
      onClick={onClick}
      {...animationProps}
      {...props}
    >
      {children}
    </Component>
  );
};

export const GlassCardHeader = ({ children, className = '' }) => {
  return (
    <div className={`mb-lg ${className}`}>
      {children}
    </div>
  );
};

export const GlassCardTitle = ({ children, className = '' }) => {
  return (
    <h3 className={`text-xl font-semibold text-text-primary dark:text-white ${className}`}>
      {children}
    </h3>
  );
};

export const GlassCardDescription = ({ children, className = '' }) => {
  return (
    <p className={`text-sm text-text-secondary dark:text-slate-400 mt-1 ${className}`}>
      {children}
    </p>
  );
};

export const GlassCardContent = ({ children, className = '' }) => {
  return (
    <div className={className}>
      {children}
    </div>
  );
};

export const GlassCardFooter = ({ children, className = '' }) => {
  return (
    <div className={`mt-lg pt-lg border-t border-border ${className}`}>
      {children}
    </div>
  );
};
