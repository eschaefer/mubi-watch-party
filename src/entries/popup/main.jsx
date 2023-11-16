import '../enableDevHmr';
import React from 'react';
import ReactDOM from 'react-dom/client';
import { make as Popup } from './Popup.bs';

import './App.css';

ReactDOM.createRoot(document.getElementById('app')).render(
  <React.StrictMode>
    <Popup />
  </React.StrictMode>
);
