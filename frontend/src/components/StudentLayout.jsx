import React from 'react';
import Sidebar from './Sidebar';
import '../styles/student-layout.css';

const StudentLayout = ({ children }) => {
  return (
    <div className="student-layout-wrapper">
      <Sidebar role="student" />
      <main className="student-layout-main" style={{ marginLeft: '280px' }}>
        {children}
      </main>
    </div>
  );
};

export default StudentLayout;
