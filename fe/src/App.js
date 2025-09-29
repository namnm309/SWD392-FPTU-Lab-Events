import React, { useState } from 'react';
import { AdminDashboard, Login } from './features';
import './App.css';

function App() {
  const [showAdmin] = useState(false);

  if (showAdmin) {
    return <AdminDashboard />;
  }

  return (
    <div className="App">
      <Login />
    </div>
  );
}

export default App;
