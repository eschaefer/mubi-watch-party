import '../../enableDevHmr';
import React from 'react';
import ReactDOM from 'react-dom/client';
import renderContent from '../renderContent';
import { make as Content } from './Content.bs';

import './App.css';

renderContent(import.meta.PLUGIN_WEB_EXT_CHUNK_CSS_PATHS, (appRoot) => {
  ReactDOM.createRoot(appRoot).render(
    <React.StrictMode>
      <Content />
    </React.StrictMode>
  );
});
