import React from 'react';
import { ModernTopNav } from './ModernTopNav';

export const ModernLayout = ({ children }) => {
  return (
    <div className="min-h-screen bg-background">
      <ModernTopNav />

      {/* Main Content Area with top padding for fixed nav */}
      <main className="pt-20 px-4 sm:px-6 lg:px-8 pb-8">
        <div className="max-w-screen-2xl mx-auto">
          {children}
        </div>
      </main>
    </div>
  );
};
