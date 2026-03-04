import React from 'react';
import { useNavigate } from 'react-router-dom';
import Navbar from '../components/Navbar';
import '../styles/landing.css';

const LandingPage = () => {
  const navigate = useNavigate();

  const handleGetStarted = () => {
    navigate('/login');
  };

  const handleRegister = () => {
    navigate('/student-registration');
  };

  return (
    <div className="landing-page">
      <Navbar />

      {/* Hero Section */}
      <section className="hero-section">
        <div className="hero-background-shapes">
          <div className="shape shape-1"></div>
          <div className="shape shape-2"></div>
          <div className="shape shape-3"></div>
        </div>
        <div className="hero-content">
          <div className="hero-badge">🏠 Modern Hostel Management</div>
          <h1 className="hero-title">
            Hostel Management
            <span className="highlight"> Made Simple</span>
          </h1>
          <p className="hero-subtitle">
            A centralized platform for students, wardens, and staff to manage hostel operations efficiently.
          </p>
          <div className="hero-buttons">
            <button className="btn btn-primary" onClick={handleGetStarted}>
              Get Started →
            </button>
            <button className="btn btn-secondary" onClick={handleRegister}>
              🎓 New Student? Register
            </button>
          </div>
          <button
            className="status-cta"
            type="button"
            onClick={() => navigate('/registration-status')}
          >
            Already registered? Check your status →
          </button>
          <div className="hero-stats">
            <div className="stat-item">
              <div className="stat-number">500+</div>
              <div className="stat-label">Active Students</div>
            </div>
            <div className="stat-divider"></div>
            <div className="stat-item">
              <div className="stat-number">50+</div>
              <div className="stat-label">Staff Members</div>
            </div>
            <div className="stat-divider"></div>
            <div className="stat-item">
              <div className="stat-number">24/7</div>
              <div className="stat-label">Support Available</div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="features-section">
        <div className="features-container">
          <div className="section-header">
            <div className="section-badge">✨ Features</div>
            <h2 className="features-title">Everything You Need</h2>
            <p className="features-subtitle">
              Comprehensive tools for efficient hostel management and automation
            </p>
          </div>

          <div className="features-grid">
            {/* Digital Outpass Card */}
            <div className="feature-card blue-theme">
              <div className="feature-icon-container blue">
                <div className="feature-icon">📋</div>
              </div>
              <h3 className="feature-card-title">Digital Outpass</h3>
              <p className="feature-card-description">
                Request and track outpass approvals with instant notifications
              </p>
              <div className="feature-link">Learn more →</div>
            </div>

            {/* Complaint System Card */}
            <div className="feature-card orange-theme">
              <div className="feature-icon-container orange">
                <div className="feature-icon">🔔</div>
              </div>
              <h3 className="feature-card-title">Complaint System</h3>
              <p className="feature-card-description">
                Report issues and track resolution in real-time
              </p>
              <div className="feature-link">Learn more →</div>
            </div>

            {/* Real-Time Updates Card */}
            <div className="feature-card purple-theme">
              <div className="feature-icon-container purple">
                <div className="feature-icon">⚡</div>
              </div>
              <h3 className="feature-card-title">Real-Time Updates</h3>
              <p className="feature-card-description">
                Instant notifications for all important activities
              </p>
              <div className="feature-link">Learn more →</div>
            </div>

            {/* Easy Approvals Card */}
            <div className="feature-card green-theme">
              <div className="feature-icon-container green">
                <div className="feature-icon">✅</div>
              </div>
              <h3 className="feature-card-title">Easy Approvals</h3>
              <p className="feature-card-description">
                Simple approval workflow for wardens and staff
              </p>
              <div className="feature-link">Learn more →</div>
            </div>
          </div>
        </div>
      </section>

      {/* Benefits Section */}
      <section className="benefits-section">
        <div className="benefits-container">
          <div className="benefits-content">
            <div className="section-badge dark">🚀 Why Choose Us</div>
            <h2 className="benefits-title">Streamline Your Hostel Operations</h2>
            <p className="benefits-description">
              Our platform brings together students, wardens, and staff in one seamless ecosystem.
              Experience hassle-free hostel management with automated workflows and real-time tracking.
            </p>
            <ul className="benefits-list">
              <li className="benefit-item">
                <span className="benefit-icon">✓</span>
                <div>
                  <strong>Automated Workflow:</strong> Reduce manual paperwork by 80%
                </div>
              </li>
              <li className="benefit-item">
                <span className="benefit-icon">✓</span>
                <div>
                  <strong>Real-Time Tracking:</strong> Monitor all activities instantly
                </div>
              </li>
              <li className="benefit-item">
                <span className="benefit-icon">✓</span>
                <div>
                  <strong>Mobile Friendly:</strong> Access from anywhere, anytime
                </div>
              </li>
              <li className="benefit-item">
                <span className="benefit-icon">✓</span>
                <div>
                  <strong>Secure Platform:</strong> Your data is safe and encrypted
                </div>
              </li>
            </ul>
            <button className="btn btn-primary" onClick={handleGetStarted}>
              Get Started →
            </button>
          </div>
          <div className="benefits-visual">
            <div className="visual-card card-1">
              <div className="visual-icon">📊</div>
              <div className="visual-text">
                <strong>95%</strong> Faster Approvals
              </div>
            </div>
            <div className="visual-card card-2">
              <div className="visual-icon">👥</div>
              <div className="visual-text">
                <strong>1000+</strong> Happy Users
              </div>
            </div>
            <div className="visual-card card-3">
              <div className="visual-icon">⭐</div>
              <div className="visual-text">
                <strong>4.9/5</strong> Rating
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default LandingPage;
