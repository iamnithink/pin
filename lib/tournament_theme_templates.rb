module TournamentThemeTemplates
  # Theme 1: Classic Blue (based on sample image)
  CLASSIC_BLUE = <<~HTML
    <div class="tournament-theme classic-blue" id="tournament-theme-{{THEME_ID}}">
      <style>
        .tournament-theme.classic-blue {
          background: linear-gradient(135deg, #000080 0%, #1a1a5e 100%);
          color: white;
          padding: 30px;
          border-radius: 10px;
          font-family: 'Arial', sans-serif;
          position: relative;
          overflow: hidden;
        }
        .tournament-theme.classic-blue::before {
          content: '';
          position: absolute;
          top: -50%;
          left: -50%;
          width: 200%;
          height: 200%;
          background: radial-gradient(circle, rgba(255,255,255,0.1) 1px, transparent 1px);
          background-size: 30px 30px;
          animation: movePattern 20s linear infinite;
        }
        @keyframes movePattern {
          0% { transform: translate(0, 0); }
          100% { transform: translate(30px, 30px); }
        }
        .theme-header {
          text-align: center;
          margin-bottom: 25px;
          position: relative;
          z-index: 1;
        }
        .theme-title {
          font-size: 42px;
          font-weight: bold;
          color: #FFD700;
          text-shadow: 3px 3px 0px #DC143C, 5px 5px 10px rgba(0,0,0,0.5);
          margin: 10px 0;
          letter-spacing: 2px;
        }
        .theme-subtitle {
          font-size: 24px;
          color: #FF6347;
          text-shadow: 2px 2px 0px #FFD700, 3px 3px 5px rgba(0,0,0,0.5);
          margin: 10px 0;
        }
        .theme-details {
          background: rgba(0,0,0,0.3);
          padding: 20px;
          border-radius: 8px;
          margin: 20px 0;
          position: relative;
          z-index: 1;
        }
        .theme-detail-row {
          display: flex;
          justify-content: space-between;
          padding: 10px 0;
          border-bottom: 1px solid rgba(255,255,255,0.2);
        }
        .theme-detail-row:last-child {
          border-bottom: none;
        }
        .theme-detail-label {
          font-weight: bold;
          color: #FFD700;
          font-size: 16px;
        }
        .theme-detail-value {
          color: white;
          font-size: 16px;
        }
        .theme-prizes {
          display: flex;
          gap: 20px;
          margin: 25px 0;
          position: relative;
          z-index: 1;
        }
        .theme-prize-box {
          flex: 1;
          background: rgba(255,215,0,0.2);
          border: 3px solid #FFD700;
          border-radius: 10px;
          padding: 20px;
          text-align: center;
        }
        .theme-prize-label {
          font-size: 18px;
          color: #FFD700;
          font-weight: bold;
          margin-bottom: 10px;
        }
        .theme-prize-amount {
          font-size: 28px;
          color: white;
          font-weight: bold;
        }
        .theme-rules {
          background: rgba(0,128,0,0.3);
          padding: 20px;
          border-radius: 8px;
          margin: 25px 0;
          position: relative;
          z-index: 1;
        }
        .theme-rules-title {
          font-size: 22px;
          color: #90EE90;
          font-weight: bold;
          margin-bottom: 15px;
          text-align: center;
        }
        .theme-rules-list {
          list-style: none;
          padding: 0;
        }
        .theme-rules-list li {
          padding: 8px 0;
          color: white;
          border-left: 3px solid #90EE90;
          padding-left: 15px;
          margin: 10px 0;
        }
        .theme-entry-fee {
          position: absolute;
          top: 20px;
          right: 20px;
          background: #DC143C;
          color: white;
          padding: 15px 25px;
          border-radius: 50%;
          font-size: 18px;
          font-weight: bold;
          transform: rotate(-15deg);
          box-shadow: 0 5px 15px rgba(0,0,0,0.5);
          z-index: 2;
        }
        .theme-footer {
          background: #DC143C;
          padding: 15px;
          text-align: center;
          margin-top: 25px;
          border-radius: 8px;
          position: relative;
          z-index: 1;
        }
        .theme-footer-text {
          color: white;
          font-size: 16px;
          font-weight: bold;
        }
        .theme-qr-code {
          text-align: center;
          padding: 15px;
          background: rgba(255,255,255,0.1);
          border-radius: 10px;
          position: relative;
          z-index: 1;
          max-width: 100%;
          box-sizing: border-box;
          overflow: hidden;
          height: 100%;
          display: flex;
          flex-direction: column;
          justify-content: center;
        }
        .theme-qr-code h4 {
          color: #FFD700;
          margin-bottom: 15px;
          font-size: 18px;
        }
        .theme-qr-code img {
          max-width: 200px;
          width: auto;
          height: auto;
          border: 3px solid #FFD700;
          padding: 10px;
          background: white;
          border-radius: 8px;
          box-shadow: 0 4px 8px rgba(0,0,0,0.3);
          display: block;
          margin: 0 auto;
        }
        .theme-qr-code a {
          color: #FFD700;
          text-decoration: none;
          margin-top: 10px;
          display: inline-block;
          font-size: 14px;
          font-weight: bold;
        }
        .theme-qr-code small {
          color: rgba(255,255,255,0.8);
          margin-top: 5px;
          display: block;
        }
        .theme-contact-phones {
          text-align: center;
          padding: 15px;
          background: rgba(255,255,255,0.1);
          border-radius: 10px;
          position: relative;
          z-index: 1;
          height: 100%;
          display: flex;
          flex-direction: column;
          justify-content: center;
        }
        .theme-contact-phones h4 {
          color: #FFD700;
          margin-bottom: 15px;
          font-size: 18px;
        }
        .theme-contact-phones a {
          color: white;
          text-decoration: none;
          display: block;
          padding: 10px 15px;
          margin: 5px 0;
          background: rgba(255,215,0,0.2);
          border: 2px solid #FFD700;
          border-radius: 20px;
          font-size: 16px;
          font-weight: bold;
          transition: all 0.3s ease;
        }
        .theme-contact-phones a:hover {
          background: rgba(255,215,0,0.4);
          transform: scale(1.05);
        }
        .theme-qr-code {
          height: 100%;
          display: flex;
          flex-direction: column;
          justify-content: center;
        }
        /* Side-by-side container for QR code and Contact phones */
        .theme-contact-qr-container {
          display: flex;
          gap: 20px;
          margin: 25px 0;
          align-items: stretch;
          position: relative;
          z-index: 1;
        }
        .theme-contact-qr-container > div {
          flex: 1;
          min-width: 0;
        }
        /* Hide empty containers */
        .theme-contact-phones:empty,
        .theme-qr-code:empty {
          display: none;
        }
        /* If one side is empty, make the other full width */
        .theme-contact-qr-container > div:empty {
          display: none;
        }
        .theme-contact-qr-container > div:not(:empty) {
          flex: 1;
        }
        /* If only one child is present, make it full width */
        .theme-contact-qr-container > div:only-child {
          flex: 1;
          max-width: 100%;
        }
        @media (max-width: 768px) {
          .theme-contact-qr-container {
            flex-direction: column;
            gap: 15px;
          }
          .theme-contact-qr-container > div {
            width: 100%;
          }
        }
        @media (max-width: 768px) {
          .theme-qr-code {
            padding: 10px;
            margin: 20px 0;
          }
          .theme-qr-code img {
            max-width: 180px;
            padding: 8px;
          }
          .theme-qr-code h4 {
            font-size: 16px;
            margin-bottom: 12px;
          }
          .theme-contact-phones a {
            font-size: 14px;
            padding: 6px 12px;
          }
        }
        @media (max-width: 480px) {
          .theme-qr-code {
            padding: 8px;
            margin: 15px 0;
          }
          .theme-qr-code img {
            max-width: 150px;
            padding: 5px;
            border-width: 2px;
          }
          .theme-qr-code h4 {
            font-size: 14px;
            margin-bottom: 10px;
          }
          .theme-qr-code a {
            font-size: 12px;
          }
          .theme-qr-code small {
            font-size: 11px;
          }
          .theme-contact-phones {
            padding: 10px;
          }
          .theme-contact-phones h4 {
            font-size: 16px;
          }
          .theme-contact-phones a {
            font-size: 12px;
            padding: 5px 10px;
            display: block;
            margin: 5px auto;
            max-width: 200px;
          }
        }
      </style>
      <div class="theme-entry-fee">Entry Fee<br>{{ENTRY_FEE}}</div>
      <div class="theme-header">
        <div class="theme-title">{{TOURNAMENT_TITLE}}</div>
        <div class="theme-subtitle">{{SPORT_NAME}} Tournament</div>
      </div>
      <div class="theme-details">
        <div class="theme-detail-row">
          <span class="theme-detail-label">Date:</span>
          <span class="theme-detail-value">{{START_TIME_FULL}}</span>
        </div>
        <div class="theme-detail-row">
          <span class="theme-detail-label">Venue:</span>
          <span class="theme-detail-value">{{VENUE_NAME}}</span>
        </div>
        <div class="theme-detail-row">
          <span class="theme-detail-label">Location:</span>
          <span class="theme-detail-value">{{VENUE_ADDRESS}}</span>
        </div>
        <div class="theme-detail-row">
          <span class="theme-detail-label">Pincode:</span>
          <span class="theme-detail-value">{{PINCODE}}</span>
        </div>
      </div>
      <div class="theme-prizes">
        {{PRIZES}}
      </div>
      <div class="theme-rules">
        <div class="theme-rules-title">Rules & Regulations</div>
        <ul class="theme-rules-list">
          <li>{{RULES}}</li>
        </ul>
      </div>
      <div class="theme-contact-qr-container">
        <div>{{CONTACT_PHONES}}</div>
        <div>{{GOOGLE_MAPS_QR}}</div>
      </div>
      <div class="theme-footer">
        <div class="theme-footer-text">Organized by: {{CREATED_BY}}</div>
        <div class="theme-footer-brand" style="margin-top: 10px; font-size: 14px; color: rgba(255,255,255,0.8);">
          Made by <a href="https://www.playinnear.com" target="_blank" style="color: #FFD700; text-decoration: none; font-weight: bold;">www.playinnear.com</a>
        </div>
      </div>
      <script>
        (function() {
          const theme = document.getElementById('tournament-theme-{{THEME_ID}}');
          if (theme) {
            // Add animation on load
            theme.style.opacity = '0';
            theme.style.transform = 'scale(0.95)';
            theme.style.transition = 'all 0.5s ease-in-out';
            setTimeout(() => {
              theme.style.opacity = '1';
              theme.style.transform = 'scale(1)';
            }, 100);
          }
        })();
      </script>
    </div>
  HTML

  # Theme 2: Fire Red
  FIRE_RED = <<~HTML
    <div class="tournament-theme fire-red" id="tournament-theme-{{THEME_ID}}">
      <style>
        .tournament-theme.fire-red {
          background: linear-gradient(135deg, #8B0000 0%, #DC143C 100%);
          color: white;
          padding: 30px;
          border-radius: 10px;
          font-family: 'Arial', sans-serif;
          position: relative;
          overflow: hidden;
          box-shadow: 0 10px 30px rgba(220,20,60,0.5);
        }
        .tournament-theme.fire-red::before {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: repeating-linear-gradient(
            45deg,
            transparent,
            transparent 10px,
            rgba(255,255,255,0.05) 10px,
            rgba(255,255,255,0.05) 20px
          );
        }
        .theme-header {
          text-align: center;
          margin-bottom: 25px;
          position: relative;
          z-index: 1;
        }
        .theme-title {
          font-size: 42px;
          font-weight: bold;
          color: #FFD700;
          text-shadow: 3px 3px 0px #000, 5px 5px 15px rgba(0,0,0,0.8);
          margin: 10px 0;
          letter-spacing: 2px;
          animation: pulse 2s ease-in-out infinite;
        }
        @keyframes pulse {
          0%, 100% { transform: scale(1); }
          50% { transform: scale(1.02); }
        }
        .theme-subtitle {
          font-size: 24px;
          color: #FFA500;
          text-shadow: 2px 2px 0px #000, 3px 3px 8px rgba(0,0,0,0.6);
          margin: 10px 0;
        }
        .theme-details {
          background: rgba(0,0,0,0.4);
          padding: 20px;
          border-radius: 8px;
          margin: 20px 0;
          position: relative;
          z-index: 1;
          border: 2px solid rgba(255,215,0,0.3);
        }
        .theme-detail-row {
          display: flex;
          justify-content: space-between;
          padding: 10px 0;
          border-bottom: 1px solid rgba(255,255,255,0.2);
        }
        .theme-detail-row:last-child {
          border-bottom: none;
        }
        .theme-detail-label {
          font-weight: bold;
          color: #FFD700;
          font-size: 16px;
        }
        .theme-detail-value {
          color: white;
          font-size: 16px;
        }
        .theme-prizes {
          display: flex;
          gap: 20px;
          margin: 25px 0;
          position: relative;
          z-index: 1;
        }
        .theme-prize-box {
          flex: 1;
          background: rgba(255,165,0,0.3);
          border: 3px solid #FFA500;
          border-radius: 10px;
          padding: 20px;
          text-align: center;
          transition: transform 0.3s ease;
        }
        .theme-prize-box:hover {
          transform: translateY(-5px);
        }
        .theme-prize-label {
          font-size: 18px;
          color: #FFD700;
          font-weight: bold;
          margin-bottom: 10px;
        }
        .theme-prize-amount {
          font-size: 28px;
          color: white;
          font-weight: bold;
        }
        .theme-rules {
          background: rgba(0,0,0,0.4);
          padding: 20px;
          border-radius: 8px;
          margin: 25px 0;
          position: relative;
          z-index: 1;
          border-left: 5px solid #FFA500;
        }
        .theme-rules-title {
          font-size: 22px;
          color: #FFD700;
          font-weight: bold;
          margin-bottom: 15px;
          text-align: center;
        }
        .theme-rules-list {
          list-style: none;
          padding: 0;
        }
        .theme-rules-list li {
          padding: 8px 0;
          color: white;
          border-left: 3px solid #FFA500;
          padding-left: 15px;
          margin: 10px 0;
        }
        .theme-entry-fee {
          position: absolute;
          top: 20px;
          right: 20px;
          background: #FFD700;
          color: #8B0000;
          padding: 15px 25px;
          border-radius: 50%;
          font-size: 18px;
          font-weight: bold;
          transform: rotate(15deg);
          box-shadow: 0 5px 15px rgba(0,0,0,0.5);
          z-index: 2;
          animation: bounce 2s ease-in-out infinite;
        }
        @keyframes bounce {
          0%, 100% { transform: rotate(15deg) translateY(0); }
          50% { transform: rotate(15deg) translateY(-10px); }
        }
        .theme-footer {
          background: #000;
          padding: 15px;
          text-align: center;
          margin-top: 25px;
          border-radius: 8px;
          position: relative;
          z-index: 1;
          border: 2px solid #FFD700;
        }
        .theme-footer-text {
          color: #FFD700;
          font-size: 16px;
          font-weight: bold;
        }
        .theme-qr-code {
          text-align: center;
          padding: 15px;
          background: rgba(255,255,255,0.1);
          border-radius: 10px;
          position: relative;
          z-index: 1;
          max-width: 100%;
          box-sizing: border-box;
          overflow: hidden;
          height: 100%;
          display: flex;
          flex-direction: column;
          justify-content: center;
        }
        .theme-qr-code h4 {
          color: #FFD700;
          margin-bottom: 15px;
          font-size: 18px;
        }
        .theme-qr-code img {
          max-width: 200px;
          width: auto;
          height: auto;
          border: 3px solid #FFD700;
          padding: 10px;
          background: white;
          border-radius: 8px;
          box-shadow: 0 4px 8px rgba(0,0,0,0.3);
          display: block;
          margin: 0 auto;
        }
        .theme-qr-code a {
          color: #FFD700;
          text-decoration: none;
          margin-top: 10px;
          display: inline-block;
          font-size: 14px;
          font-weight: bold;
        }
        .theme-qr-code small {
          color: rgba(255,255,255,0.8);
          margin-top: 5px;
          display: block;
        }
        .theme-contact-phones {
          text-align: center;
          padding: 15px;
          background: rgba(255,255,255,0.1);
          border-radius: 10px;
          position: relative;
          z-index: 1;
          height: 100%;
          display: flex;
          flex-direction: column;
          justify-content: center;
        }
        .theme-contact-phones h4 {
          color: #FFD700;
          margin-bottom: 15px;
          font-size: 18px;
        }
        .theme-contact-phones a {
          color: white;
          text-decoration: none;
          display: block;
          padding: 10px 15px;
          margin: 5px 0;
          background: rgba(255,215,0,0.2);
          border: 2px solid #FFD700;
          border-radius: 20px;
          font-size: 16px;
          font-weight: bold;
          transition: all 0.3s ease;
        }
        .theme-contact-phones a:hover {
          background: rgba(255,215,0,0.4);
          transform: scale(1.05);
        }
        .theme-qr-code {
          height: 100%;
          display: flex;
          flex-direction: column;
          justify-content: center;
        }
        /* Side-by-side container for QR code and Contact phones */
        .theme-contact-qr-container {
          display: flex;
          gap: 20px;
          margin: 25px 0;
          align-items: stretch;
          position: relative;
          z-index: 1;
        }
        .theme-contact-qr-container > div {
          flex: 1;
          min-width: 0;
        }
        /* Hide empty containers */
        .theme-contact-phones:empty,
        .theme-qr-code:empty {
          display: none;
        }
        /* If one side is empty, make the other full width */
        .theme-contact-qr-container > div:empty {
          display: none;
        }
        .theme-contact-qr-container > div:not(:empty) {
          flex: 1;
        }
        /* If only one child is present, make it full width */
        .theme-contact-qr-container > div:only-child {
          flex: 1;
          max-width: 100%;
        }
        @media (max-width: 768px) {
          .theme-contact-qr-container {
            flex-direction: column;
            gap: 15px;
          }
          .theme-contact-qr-container > div {
            width: 100%;
          }
        }
        @media (max-width: 768px) {
          .theme-qr-code {
            padding: 10px;
            margin: 20px 0;
          }
          .theme-qr-code img {
            max-width: 180px;
            padding: 8px;
          }
          .theme-qr-code h4 {
            font-size: 16px;
            margin-bottom: 12px;
          }
          .theme-contact-phones a {
            font-size: 14px;
            padding: 6px 12px;
          }
        }
        @media (max-width: 480px) {
          .theme-qr-code {
            padding: 8px;
            margin: 15px 0;
          }
          .theme-qr-code img {
            max-width: 150px;
            padding: 5px;
            border-width: 2px;
          }
          .theme-qr-code h4 {
            font-size: 14px;
            margin-bottom: 10px;
          }
          .theme-qr-code a {
            font-size: 12px;
          }
          .theme-qr-code small {
            font-size: 11px;
          }
          .theme-contact-phones {
            padding: 10px;
          }
          .theme-contact-phones h4 {
            font-size: 16px;
          }
          .theme-contact-phones a {
            font-size: 12px;
            padding: 5px 10px;
            display: block;
            margin: 5px auto;
            max-width: 200px;
          }
        }
      </style>
      <div class="theme-entry-fee">Entry Fee<br>{{ENTRY_FEE}}</div>
      <div class="theme-header">
        <div class="theme-title">{{TOURNAMENT_TITLE}}</div>
        <div class="theme-subtitle">{{SPORT_NAME}} Championship</div>
      </div>
      <div class="theme-details">
        <div class="theme-detail-row">
          <span class="theme-detail-label">Date:</span>
          <span class="theme-detail-value">{{START_TIME_FULL}}</span>
        </div>
        <div class="theme-detail-row">
          <span class="theme-detail-label">Venue:</span>
          <span class="theme-detail-value">{{VENUE_NAME}}</span>
        </div>
        <div class="theme-detail-row">
          <span class="theme-detail-label">Location:</span>
          <span class="theme-detail-value">{{VENUE_ADDRESS}}</span>
        </div>
        <div class="theme-detail-row">
          <span class="theme-detail-label">Pincode:</span>
          <span class="theme-detail-value">{{PINCODE}}</span>
        </div>
      </div>
      <div class="theme-prizes">
        {{PRIZES}}
      </div>
      <div class="theme-rules">
        <div class="theme-rules-title">Rules & Regulations</div>
        <ul class="theme-rules-list">
          <li>{{RULES}}</li>
        </ul>
      </div>
      <div class="theme-contact-qr-container">
        <div>{{CONTACT_PHONES}}</div>
        <div>{{GOOGLE_MAPS_QR}}</div>
      </div>
      <div class="theme-footer">
        <div class="theme-footer-text">Organized by: {{CREATED_BY}}</div>
        <div class="theme-footer-brand" style="margin-top: 10px; font-size: 14px; color: rgba(255,255,255,0.8);">
          Made by <a href="https://www.playinnear.com" target="_blank" style="color: #FFD700; text-decoration: none; font-weight: bold;">www.playinnear.com</a>
        </div>
      </div>
      <script>
        (function() {
          const theme = document.getElementById('tournament-theme-{{THEME_ID}}');
          if (theme) {
            theme.style.opacity = '0';
            theme.style.transform = 'translateY(20px)';
            theme.style.transition = 'all 0.6s ease-out';
            setTimeout(() => {
              theme.style.opacity = '1';
              theme.style.transform = 'translateY(0)';
            }, 100);
          }
        })();
      </script>
    </div>
  HTML

  # Theme 3: Forest Green
  FOREST_GREEN = <<~HTML
    <div class="tournament-theme forest-green" id="tournament-theme-{{THEME_ID}}">
      <style>
        .tournament-theme.forest-green {
          background: linear-gradient(135deg, #006400 0%, #228B22 100%);
          color: white;
          padding: 30px;
          border-radius: 10px;
          font-family: 'Arial', sans-serif;
          position: relative;
          overflow: hidden;
          box-shadow: 0 10px 30px rgba(34,139,34,0.5);
        }
        .tournament-theme.forest-green::before {
          content: '';
          position: absolute;
          top: -50%;
          right: -50%;
          width: 200%;
          height: 200%;
          background: radial-gradient(circle, rgba(255,255,255,0.1) 2px, transparent 2px);
          background-size: 40px 40px;
          animation: rotatePattern 25s linear infinite;
        }
        @keyframes rotatePattern {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        .theme-header {
          text-align: center;
          margin-bottom: 25px;
          position: relative;
          z-index: 1;
        }
        .theme-title {
          font-size: 42px;
          font-weight: bold;
          color: #FFD700;
          text-shadow: 3px 3px 0px #006400, 5px 5px 12px rgba(0,0,0,0.7);
          margin: 10px 0;
          letter-spacing: 2px;
        }
        .theme-subtitle {
          font-size: 24px;
          color: #90EE90;
          text-shadow: 2px 2px 0px #006400, 3px 3px 6px rgba(0,0,0,0.6);
          margin: 10px 0;
        }
        .theme-details {
          background: rgba(0,0,0,0.3);
          padding: 20px;
          border-radius: 8px;
          margin: 20px 0;
          position: relative;
          z-index: 1;
          border: 2px solid rgba(144,238,144,0.4);
        }
        .theme-detail-row {
          display: flex;
          justify-content: space-between;
          padding: 10px 0;
          border-bottom: 1px solid rgba(255,255,255,0.2);
        }
        .theme-detail-row:last-child {
          border-bottom: none;
        }
        .theme-detail-label {
          font-weight: bold;
          color: #90EE90;
          font-size: 16px;
        }
        .theme-detail-value {
          color: white;
          font-size: 16px;
        }
        .theme-prizes {
          display: flex;
          gap: 20px;
          margin: 25px 0;
          position: relative;
          z-index: 1;
        }
        .theme-prize-box {
          flex: 1;
          background: rgba(144,238,144,0.2);
          border: 3px solid #90EE90;
          border-radius: 10px;
          padding: 20px;
          text-align: center;
        }
        .theme-prize-label {
          font-size: 18px;
          color: #FFD700;
          font-weight: bold;
          margin-bottom: 10px;
        }
        .theme-prize-amount {
          font-size: 28px;
          color: white;
          font-weight: bold;
        }
        .theme-rules {
          background: rgba(0,100,0,0.4);
          padding: 20px;
          border-radius: 8px;
          margin: 25px 0;
          position: relative;
          z-index: 1;
          border-top: 5px solid #90EE90;
        }
        .theme-rules-title {
          font-size: 22px;
          color: #FFD700;
          font-weight: bold;
          margin-bottom: 15px;
          text-align: center;
        }
        .theme-rules-list {
          list-style: none;
          padding: 0;
        }
        .theme-rules-list li {
          padding: 8px 0;
          color: white;
          border-left: 3px solid #90EE90;
          padding-left: 15px;
          margin: 10px 0;
        }
        .theme-entry-fee {
          position: absolute;
          top: 20px;
          right: 20px;
          background: #FFD700;
          color: #006400;
          padding: 15px 25px;
          border-radius: 50%;
          font-size: 18px;
          font-weight: bold;
          transform: rotate(-15deg);
          box-shadow: 0 5px 15px rgba(0,0,0,0.5);
          z-index: 2;
        }
        .theme-footer {
          background: rgba(0,100,0,0.6);
          padding: 15px;
          text-align: center;
          margin-top: 25px;
          border-radius: 8px;
          position: relative;
          z-index: 1;
          border: 2px solid #90EE90;
        }
        .theme-footer-text {
          color: #FFD700;
          font-size: 16px;
          font-weight: bold;
        }
        .theme-qr-code {
          text-align: center;
          padding: 15px;
          background: rgba(255,255,255,0.1);
          border-radius: 10px;
          position: relative;
          z-index: 1;
          max-width: 100%;
          box-sizing: border-box;
          overflow: hidden;
          height: 100%;
          display: flex;
          flex-direction: column;
          justify-content: center;
        }
        .theme-qr-code h4 {
          color: #FFD700;
          margin-bottom: 15px;
          font-size: 18px;
        }
        .theme-qr-code img {
          max-width: 200px;
          width: auto;
          height: auto;
          border: 3px solid #FFD700;
          padding: 10px;
          background: white;
          border-radius: 8px;
          box-shadow: 0 4px 8px rgba(0,0,0,0.3);
          display: block;
          margin: 0 auto;
        }
        .theme-qr-code a {
          color: #FFD700;
          text-decoration: none;
          margin-top: 10px;
          display: inline-block;
          font-size: 14px;
          font-weight: bold;
        }
        .theme-qr-code small {
          color: rgba(255,255,255,0.8);
          margin-top: 5px;
          display: block;
        }
        .theme-contact-phones {
          text-align: center;
          padding: 15px;
          background: rgba(255,255,255,0.1);
          border-radius: 10px;
          position: relative;
          z-index: 1;
          height: 100%;
          display: flex;
          flex-direction: column;
          justify-content: center;
        }
        .theme-contact-phones h4 {
          color: #FFD700;
          margin-bottom: 15px;
          font-size: 18px;
        }
        .theme-contact-phones a {
          color: white;
          text-decoration: none;
          display: block;
          padding: 10px 15px;
          margin: 5px 0;
          background: rgba(255,215,0,0.2);
          border: 2px solid #FFD700;
          border-radius: 20px;
          font-size: 16px;
          font-weight: bold;
          transition: all 0.3s ease;
        }
        .theme-contact-phones a:hover {
          background: rgba(255,215,0,0.4);
          transform: scale(1.05);
        }
        .theme-qr-code {
          height: 100%;
          display: flex;
          flex-direction: column;
          justify-content: center;
        }
        /* Side-by-side container for QR code and Contact phones */
        .theme-contact-qr-container {
          display: flex;
          gap: 20px;
          margin: 25px 0;
          align-items: stretch;
          position: relative;
          z-index: 1;
        }
        .theme-contact-qr-container > div {
          flex: 1;
          min-width: 0;
        }
        /* Hide empty containers */
        .theme-contact-phones:empty,
        .theme-qr-code:empty {
          display: none;
        }
        /* If one side is empty, make the other full width */
        .theme-contact-qr-container > div:empty {
          display: none;
        }
        .theme-contact-qr-container > div:not(:empty) {
          flex: 1;
        }
        /* If only one child is present, make it full width */
        .theme-contact-qr-container > div:only-child {
          flex: 1;
          max-width: 100%;
        }
        @media (max-width: 768px) {
          .theme-contact-qr-container {
            flex-direction: column;
            gap: 15px;
          }
          .theme-contact-qr-container > div {
            width: 100%;
          }
        }
        @media (max-width: 768px) {
          .theme-qr-code {
            padding: 10px;
            margin: 20px 0;
          }
          .theme-qr-code img {
            max-width: 180px;
            padding: 8px;
          }
          .theme-qr-code h4 {
            font-size: 16px;
            margin-bottom: 12px;
          }
          .theme-contact-phones a {
            font-size: 14px;
            padding: 6px 12px;
          }
        }
        @media (max-width: 480px) {
          .theme-qr-code {
            padding: 8px;
            margin: 15px 0;
          }
          .theme-qr-code img {
            max-width: 150px;
            padding: 5px;
            border-width: 2px;
          }
          .theme-qr-code h4 {
            font-size: 14px;
            margin-bottom: 10px;
          }
          .theme-qr-code a {
            font-size: 12px;
          }
          .theme-qr-code small {
            font-size: 11px;
          }
          .theme-contact-phones {
            padding: 10px;
          }
          .theme-contact-phones h4 {
            font-size: 16px;
          }
          .theme-contact-phones a {
            font-size: 12px;
            padding: 5px 10px;
            display: block;
            margin: 5px auto;
            max-width: 200px;
          }
        }
      </style>
      <div class="theme-entry-fee">Entry Fee<br>{{ENTRY_FEE}}</div>
      <div class="theme-header">
        <div class="theme-title">{{TOURNAMENT_TITLE}}</div>
        <div class="theme-subtitle">{{SPORT_NAME}} League</div>
      </div>
      <div class="theme-details">
        <div class="theme-detail-row">
          <span class="theme-detail-label">Date:</span>
          <span class="theme-detail-value">{{START_TIME_FULL}}</span>
        </div>
        <div class="theme-detail-row">
          <span class="theme-detail-label">Venue:</span>
          <span class="theme-detail-value">{{VENUE_NAME}}</span>
        </div>
        <div class="theme-detail-row">
          <span class="theme-detail-label">Location:</span>
          <span class="theme-detail-value">{{VENUE_ADDRESS}}</span>
        </div>
        <div class="theme-detail-row">
          <span class="theme-detail-label">Pincode:</span>
          <span class="theme-detail-value">{{PINCODE}}</span>
        </div>
      </div>
      <div class="theme-prizes">
        {{PRIZES}}
      </div>
      <div class="theme-rules">
        <div class="theme-rules-title">Rules & Regulations</div>
        <ul class="theme-rules-list">
          <li>{{RULES}}</li>
        </ul>
      </div>
      <div class="theme-contact-qr-container">
        <div>{{CONTACT_PHONES}}</div>
        <div>{{GOOGLE_MAPS_QR}}</div>
      </div>
      <div class="theme-footer">
        <div class="theme-footer-text">Organized by: {{CREATED_BY}}</div>
        <div class="theme-footer-brand" style="margin-top: 10px; font-size: 14px; color: rgba(255,255,255,0.8);">
          Made by <a href="https://www.playinnear.com" target="_blank" style="color: #FFD700; text-decoration: none; font-weight: bold;">www.playinnear.com</a>
        </div>
      </div>
      <script>
        (function() {
          const theme = document.getElementById('tournament-theme-{{THEME_ID}}');
          if (theme) {
            theme.style.opacity = '0';
            theme.style.filter = 'blur(10px)';
            theme.style.transition = 'all 0.7s ease-out';
            setTimeout(() => {
              theme.style.opacity = '1';
              theme.style.filter = 'blur(0)';
            }, 100);
          }
        })();
      </script>
    </div>
  HTML
end
