import React, { useState } from 'react';
import { AdminDashboard } from './features';
import './App.css';

function App() {
  const [showAdmin, setShowAdmin] = useState(false);

  if (showAdmin) {
    return <AdminDashboard />;
  }

  return (
    <div className="App">
      <div className="simple-home">
        <div className="simple-content">
          <h1>FPT Lab Events</h1>
          <p>Click the button below to access the Admin Dashboard</p>
          <button 
            className="btn btn-primary"
            onClick={() => setShowAdmin(true)}
          >
            Go to Admin Dashboard
          </button>
        </div>
      </div>
    </div>
  );
}

export default App;
