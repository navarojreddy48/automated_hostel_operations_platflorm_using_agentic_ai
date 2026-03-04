import React from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import '../styles/technician-layout.css';

/**
 * TechnicianLayout Component
 * 
 * Layout wrapper for all technician pages
 * Uses unified Sidebar component
 */
const TechnicianLayout = ({ children }) => {
  return (
    <div className="technician-layout-wrapper">
      <Sidebar role="technician" />
      <main className="technician-layout-main" style={{ marginLeft: '280px' }}>
        {children || <Outlet />}
      </main>
    </div>
  );
};

export default TechnicianLayout;
