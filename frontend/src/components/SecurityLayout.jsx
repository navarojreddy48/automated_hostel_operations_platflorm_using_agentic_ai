import React from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import '../styles/security-dashboard.css';

/**
 * SecurityLayout Component
 * 
 * Layout wrapper for all security pages
 * Uses unified Sidebar component
 */
const SecurityLayout = ({ children }) => {
  return (
    <div className="security-layout">
      <Sidebar role="security" />
      <main className="security-main" style={{ marginLeft: '280px' }}>
        {children || <Outlet />}
      </main>
    </div>
  );
};

export default SecurityLayout;
