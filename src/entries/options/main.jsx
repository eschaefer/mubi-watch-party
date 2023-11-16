import '../enableDevHmr';
import React from 'react';
import ReactDOM from 'react-dom/client';
import { make as Options } from './Options.bs';

import './App.css';

ReactDOM.createRoot(document.getElementById('app')).render(
  <React.StrictMode>
    <Options />
  </React.StrictMode>
);
