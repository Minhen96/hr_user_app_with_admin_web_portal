import React from 'react';

export const ModernInput = React.forwardRef(({
  label,
  error,
  icon,
  className = '',
  containerClassName = '',
  ...props
}, ref) => {
  return (
    <div className={`flex flex-col gap-1.5 ${containerClassName}`}>
      {label && (
        <label className="text-sm font-medium text-text-primary dark:text-white">
          {label}
        </label>
      )}
      <div className="relative">
        {icon && (
          <div className="absolute left-3 top-1/2 -translate-y-1/2 text-text-hint">
            {icon}
          </div>
        )}
        <input
          ref={ref}
          className={`
            w-full
            px-4 py-2.5
            ${icon ? 'pl-10' : ''}
            bg-surface dark:bg-surface-variant
            border border-border
            rounded-lg
            text-text-primary dark:text-white
            placeholder:text-text-hint
            focus:outline-none focus:ring-2 focus:ring-primary-purple
            transition-all duration-300
            ${error ? 'border-error focus:ring-error' : ''}
            ${className}
          `}
          {...props}
        />
      </div>
      {error && (
        <span className="text-xs text-error">{error}</span>
      )}
    </div>
  );
});

ModernInput.displayName = 'ModernInput';

export const ModernTextarea = React.forwardRef(({
  label,
  error,
  className = '',
  containerClassName = '',
  rows = 4,
  ...props
}, ref) => {
  return (
    <div className={`flex flex-col gap-1.5 ${containerClassName}`}>
      {label && (
        <label className="text-sm font-medium text-text-primary dark:text-white">
          {label}
        </label>
      )}
      <textarea
        ref={ref}
        rows={rows}
        className={`
          w-full
          px-4 py-2.5
          bg-surface dark:bg-surface-variant
          border border-border
          rounded-lg
          text-text-primary dark:text-white
          placeholder:text-text-hint
          focus:outline-none focus:ring-2 focus:ring-primary-purple
          transition-all duration-300
          resize-none
          ${error ? 'border-error focus:ring-error' : ''}
          ${className}
        `}
        {...props}
      />
      {error && (
        <span className="text-xs text-error">{error}</span>
      )}
    </div>
  );
});

ModernTextarea.displayName = 'ModernTextarea';

export const ModernSelect = React.forwardRef(({
  label,
  error,
  options = [],
  className = '',
  containerClassName = '',
  ...props
}, ref) => {
  return (
    <div className={`flex flex-col gap-1.5 ${containerClassName}`}>
      {label && (
        <label className="text-sm font-medium text-text-primary dark:text-white">
          {label}
        </label>
      )}
      <select
        ref={ref}
        className={`
          w-full
          px-4 py-2.5
          bg-surface dark:bg-surface-variant
          border border-border
          rounded-lg
          text-text-primary dark:text-white
          focus:outline-none focus:ring-2 focus:ring-primary-purple
          transition-all duration-300
          cursor-pointer
          ${error ? 'border-error focus:ring-error' : ''}
          ${className}
        `}
        {...props}
      >
        {options.map((option, index) => (
          <option key={index} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
      {error && (
        <span className="text-xs text-error">{error}</span>
      )}
    </div>
  );
});

ModernSelect.displayName = 'ModernSelect';
