document.addEventListener('DOMContentLoaded', function() {
  // Location detection
  const getLocationBtn = document.getElementById('get-location-btn');
  const latitudeInput = document.getElementById('latitude');
  const longitudeInput = document.getElementById('longitude');
  const locationStatus = document.getElementById('location-status');
  const locationText = document.getElementById('location-text');
  const clearLocationBtn = document.getElementById('clear-location');
  const filtersForm = document.getElementById('tournament-filters');

  // Get translation text
  const locationActiveText = locationStatus ? locationStatus.getAttribute('data-location-active') : '';
  const useLocationText = getLocationBtn ? getLocationBtn.textContent : '📍 Use My Location';

  // Check if location is already set
  const urlParams = new URLSearchParams(window.location.search);
  if (urlParams.get('latitude') && urlParams.get('longitude')) {
    if (latitudeInput) latitudeInput.value = urlParams.get('latitude');
    if (longitudeInput) longitudeInput.value = urlParams.get('longitude');
    if (locationStatus) {
      locationStatus.style.display = 'flex';
      if (locationText) locationText.textContent = locationActiveText;
    }
  }

  // Get user location
  if (getLocationBtn) {
    getLocationBtn.addEventListener('click', function() {
      if (navigator.geolocation) {
        getLocationBtn.textContent = '⏳ Getting location...';
        getLocationBtn.disabled = true;

        navigator.geolocation.getCurrentPosition(
          function(position) {
            if (latitudeInput) latitudeInput.value = position.coords.latitude;
            if (longitudeInput) longitudeInput.value = position.coords.longitude;
            
            if (locationStatus) {
              locationStatus.style.display = 'flex';
              if (locationText) locationText.textContent = locationActiveText;
            }
            
            getLocationBtn.textContent = useLocationText;
            getLocationBtn.disabled = false;

            // Auto-submit form to refresh with location
            if (filtersForm) filtersForm.submit();
          },
          function(error) {
            alert('Unable to get your location. Please enable location services.');
            getLocationBtn.textContent = useLocationText;
            getLocationBtn.disabled = false;
          }
        );
      } else {
        alert('Geolocation is not supported by your browser.');
      }
    });
  }

  // Clear location
  if (clearLocationBtn) {
    clearLocationBtn.addEventListener('click', function() {
      if (latitudeInput) latitudeInput.value = '';
      if (longitudeInput) longitudeInput.value = '';
      if (locationStatus) locationStatus.style.display = 'none';
      
      // Remove location params from URL and refresh
      const url = new URL(window.location);
      url.searchParams.delete('latitude');
      url.searchParams.delete('longitude');
      window.location.href = url.toString();
    });
  }

  // Search with debounce
  let searchTimeout;
  const searchInput = document.getElementById('search');
  if (searchInput) {
    searchInput.addEventListener('input', function() {
      clearTimeout(searchTimeout);
      searchTimeout = setTimeout(function() {
        // Optional: auto-submit after 1 second of no typing
        // if (filtersForm) filtersForm.submit();
      }, 1000);
    });
  }

  // Like button functionality
  document.querySelectorAll('.btn-like-card').forEach(function(likeBtn) {
    likeBtn.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      
      const tournamentSlug = this.getAttribute('data-tournament-slug');
      const isLiked = this.getAttribute('data-liked') === 'true';
      const likeCountEl = this.querySelector('.like-count-card');
      const locale = document.documentElement.lang || 'en';
      const localePrefix = locale === 'en' ? '' : `/${locale}`;
      const url = isLiked ? `${localePrefix}/tournaments/${tournamentSlug}/unlike` : `${localePrefix}/tournaments/${tournamentSlug}/like`;
      
      const csrfToken = document.querySelector('meta[name="csrf-token"]');
      if (!csrfToken) return;
      
      fetch(url, {
        method: isLiked ? 'DELETE' : 'POST',
        headers: {
          'X-CSRF-Token': csrfToken.content,
          'Content-Type': 'application/json'
        },
        credentials: 'same-origin'
      })
      .then(response => {
        if (response.status === 401) {
          return response.json().then(data => {
            if (data.redirect) {
              window.location.href = data.redirect;
            } else {
              window.location.href = '/users/sign_in';
            }
            return null;
          });
        }
        return response.json();
      })
      .then(data => {
        if (data && data.success) {
          this.classList.toggle('liked');
          this.setAttribute('data-liked', !isLiked);
          if (likeCountEl) {
            likeCountEl.textContent = data.like_count;
          }
        } else if (data && data.message) {
          if (data.redirect) {
            window.location.href = data.redirect;
          } else {
            alert(data.message || 'An error occurred');
          }
        }
      })
      .catch(error => {
        console.error('Error:', error);
        alert('An error occurred. Please try again.');
      });
    });
  });

  // Share button functionality
  document.querySelectorAll('.btn-share-card').forEach(function(shareBtn) {
    shareBtn.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      
      const url = this.getAttribute('data-url');
      const title = this.getAttribute('data-title');
      const description = this.getAttribute('data-description') || '';
      const image = this.getAttribute('data-image') || '';
      const sport = this.getAttribute('data-sport') || '';
      const date = this.getAttribute('data-date') || '';
      const venue = this.getAttribute('data-venue') || '';
      const entryFee = this.getAttribute('data-entry-fee') || 'Free';
      
      // Create rich share text with all tournament details
      let shareText = `🏆 ${title}\n\n`;
      if (description) {
        shareText += `${description}\n\n`;
      }
      shareText += `⚽ Sport: ${sport}\n`;
      shareText += `📅 Date: ${date}\n`;
      shareText += `📍 Venue: ${venue}\n`;
      shareText += `💰 Entry Fee: ${entryFee}\n\n`;
      shareText += `🔗 View details: ${url}`;
      
      if (navigator.share) {
        const shareData = {
          title: title,
          text: shareText,
          url: url
        };
        
        // Add image if available (some platforms support it)
        if (image) {
          try {
            shareData.files = [new File([], image, { type: 'image/png' })];
          } catch(e) {
            // Image sharing not supported, continue without it
          }
        }
        
        navigator.share(shareData).catch(err => {
          console.log('Error sharing', err);
          // Fallback to share options
          showShareOptions(url, title, shareText, shareBtn, image);
        });
      } else {
        // Show share options
        showShareOptions(url, title, shareText, shareBtn, image);
      }
    });
  });

  function showShareOptions(url, title, text, button, image) {
    // Create a simple share modal
    const shareModal = document.createElement('div');
    shareModal.className = 'share-modal';
    shareModal.innerHTML = `
      <div class="share-modal-content">
        <h3>Share Tournament</h3>
        <div class="share-options">
          <button class="share-option-btn" data-action="copy">
            <span>📋</span> Copy Link
          </button>
          <a href="https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(url)}" 
             target="_blank" class="share-option-btn" data-action="facebook">
            <span>📘</span> Facebook
          </a>
          <a href="https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(url)}" 
             target="_blank" class="share-option-btn" data-action="twitter">
            <span>🐦</span> Twitter
          </a>
          <a href="https://wa.me/?text=${encodeURIComponent(text + ' ' + url)}" 
             target="_blank" class="share-option-btn" data-action="whatsapp">
            <span>💬</span> WhatsApp
          </a>
        </div>
        <button class="share-close-btn" onclick="this.closest('.share-modal').remove()">Close</button>
      </div>
    `;
    document.body.appendChild(shareModal);
    
    // Handle copy button
    const copyBtn = shareModal.querySelector('[data-action="copy"]');
    if (copyBtn) {
      copyBtn.addEventListener('click', function() {
        copyToClipboard(url, button);
        shareModal.remove();
      });
    }
  }

  function copyToClipboard(text, button) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(() => {
        const originalText = button.innerHTML;
        button.innerHTML = '<span class="share-icon-card">✓</span>';
        button.style.background = '#28a745';
        button.style.borderColor = '#28a745';
        button.style.color = 'white';
        setTimeout(() => {
          button.innerHTML = originalText;
          button.style.background = '';
          button.style.borderColor = '';
          button.style.color = '';
        }, 2000);
      }).catch(err => {
        prompt('Copy this link:', text);
      });
    } else {
      prompt('Copy this link:', text);
    }
  }

  // Infinite Scroll Pagination
  const tournamentsGrid = document.getElementById('tournaments-grid');
  if (!tournamentsGrid) return; // Exit if grid doesn't exist
  
  let currentPage = parseInt(tournamentsGrid.getAttribute('data-current-page')) || 1;
  let isLoading = false;
  let hasMore = tournamentsGrid.getAttribute('data-has-more') === 'true';
  const loadingIndicator = document.createElement('div');
  loadingIndicator.className = 'loading-indicator';
  loadingIndicator.innerHTML = '<div class="spinner"></div><p>Loading more tournaments...</p>';
  loadingIndicator.style.display = 'none';
  
  if (tournamentsGrid) {
    tournamentsGrid.parentElement.appendChild(loadingIndicator);
    
    // Intersection Observer for infinite scroll
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && hasMore && !isLoading) {
          loadMoreTournaments();
        }
      });
    }, {
      rootMargin: '200px' // Start loading 200px before reaching the bottom
    });
    
    // Create a sentinel element at the bottom
    const sentinel = document.createElement('div');
    sentinel.className = 'scroll-sentinel';
    sentinel.style.height = '1px';
    tournamentsGrid.parentElement.appendChild(sentinel);
    observer.observe(sentinel);
    
    function loadMoreTournaments() {
      if (isLoading || !hasMore) return;
      
      isLoading = true;
      currentPage++;
      loadingIndicator.style.display = 'block';
      
      // Get current filter parameters
      const urlParams = new URLSearchParams(window.location.search);
      const params = new URLSearchParams({
        page: currentPage,
        sport_id: urlParams.get('sport_id') || '',
        search: urlParams.get('search') || '',
        start_date: urlParams.get('start_date') || '',
        latitude: urlParams.get('latitude') || '',
        longitude: urlParams.get('longitude') || ''
      });
      
      // Get locale from URL or HTML lang attribute
      const locale = document.documentElement.lang || 'en';
      const localePrefix = locale === 'en' ? '' : `/${locale}`;
      const loadMoreUrl = `${localePrefix}/tournaments/load_more?${params.toString()}`;
      
      fetch(loadMoreUrl, {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin'
      })
      .then(response => response.json())
      .then(data => {
        if (data.success && data.tournaments) {
          // Append new tournaments
          data.tournaments.forEach((tournament, index) => {
            const card = createTournamentCard(tournament, (currentPage - 1) * 20 + index);
            tournamentsGrid.appendChild(card);
          });
          
          hasMore = data.has_more;
          if (!hasMore) {
            sentinel.style.display = 'none';
          }
        } else {
          hasMore = false;
          sentinel.style.display = 'none';
        }
      })
      .catch(error => {
        console.error('Error loading more tournaments:', error);
        hasMore = false;
        sentinel.style.display = 'none';
      })
      .finally(() => {
        isLoading = false;
        loadingIndicator.style.display = 'none';
      });
    }
    
    function createTournamentCard(tournament, index) {
      const card = document.createElement('div');
      card.className = 'tournament-card';
      card.setAttribute('data-tournament-id', tournament.id);
      
      // Build image HTML
      let imageHtml = '';
      if (tournament.image_url) {
        imageHtml = `<img src="${tournament.image_url}" alt="${tournament.title}" class="card-image" loading="lazy" decoding="async" width="400">`;
      } else if (tournament.tournament_theme && tournament.tournament_theme.preview_image_url) {
        imageHtml = `<img src="${tournament.tournament_theme.preview_image_url}" alt="${tournament.title}" class="card-image" loading="lazy" decoding="async">`;
      } else {
        imageHtml = `<div class="card-image-placeholder">${tournament.sport.icon} ${tournament.sport.name}</div>`;
      }
      
      const distanceHtml = tournament.distance ? 
        `<div class="tournament-distance"><span class="distance-icon">📏</span><span class="distance-text">${tournament.distance} km away</span></div>` : '';
      
      const prizeHtml = tournament.first_prize ? 
        `<div class="tournament-prizes"><span class="prize-label">Prize Pool:</span><span class="prize-amount">₹${tournament.first_prize.toLocaleString('en-IN')}</span></div>` : '';
      
      const mapLinkHtml = tournament.venue_google_maps_link ? 
        `<a href="${tournament.venue_google_maps_link}" target="_blank" class="btn-map-link">🗺️ Map</a>` : '';
      
      const locale = document.documentElement.lang || 'en';
      const localePrefix = locale === 'en' ? '' : `/${locale}`;
      const tournamentUrl = `${localePrefix}/tournaments/${tournament.slug}`;
      
      const startDate = new Date(tournament.start_time);
      const dateStr = startDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
      const timeStr = startDate.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
      
      card.innerHTML = `
        <div class="tournament-image">
          ${imageHtml}
          <div class="tournament-badge">${tournament.sport.icon} ${tournament.sport.name}</div>
        </div>
        <div class="tournament-content">
          <h3 class="tournament-title">
            <a href="${tournamentUrl}" class="tournament-link">${tournament.title}</a>
          </h3>
          <div class="tournament-meta">
            <div class="meta-item">
              <span class="meta-icon">📅</span>
              <span class="meta-text">${dateStr}<small>${timeStr}</small></span>
            </div>
            <div class="meta-item">
              <span class="meta-icon">📍</span>
              <span class="meta-text">${tournament.venue_name || tournament.venue_address || 'TBD'}</span>
            </div>
            ${tournament.entry_fee ? `<div class="meta-item"><span class="meta-icon">💰</span><span class="meta-text">₹${tournament.entry_fee}</span></div>` : ''}
          </div>
          ${tournament.description ? `<p class="tournament-description">${tournament.description.substring(0, 120)}${tournament.description.length > 120 ? '...' : ''}</p>` : ''}
          ${prizeHtml}
          ${distanceHtml}
          <div class="tournament-social-actions">
            <div class="like-disabled" title="Likes available for signed-in admins only">
              <span class="like-icon-card">❤️</span>
              <span class="like-count-card">${tournament.likes_count || 0}</span>
            </div>
            <button class="btn-share-card" data-url="${window.location.origin}${tournamentUrl}" data-title="${tournament.title}" data-description="${tournament.description || ''}" data-sport="${tournament.sport.name}" data-date="${dateStr} ${timeStr}" data-venue="${tournament.venue_name || tournament.venue_address || 'TBD'}" data-entry-fee="${tournament.entry_fee ? '₹' + tournament.entry_fee : 'Free'}" data-tournament-id="${tournament.id}">
              <span class="share-icon-card">🔗</span>
            </button>
          </div>
          <div class="tournament-actions">
            <a href="${tournamentUrl}" class="btn-view-details">View Details</a>
            ${mapLinkHtml}
          </div>
        </div>
      `;
      
      // Re-attach share button event listener
      const shareBtn = card.querySelector('.btn-share-card');
      if (shareBtn) {
        shareBtn.addEventListener('click', function(e) {
          e.preventDefault();
          e.stopPropagation();
          
          const url = this.getAttribute('data-url');
          const title = this.getAttribute('data-title');
          const description = this.getAttribute('data-description') || '';
          const sport = this.getAttribute('data-sport') || '';
          const date = this.getAttribute('data-date') || '';
          const venue = this.getAttribute('data-venue') || '';
          const entryFee = this.getAttribute('data-entry-fee') || 'Free';
          
          let shareText = `🏆 ${title}\n\n`;
          if (description) shareText += `${description}\n\n`;
          shareText += `⚽ Sport: ${sport}\n`;
          shareText += `📅 Date: ${date}\n`;
          shareText += `📍 Venue: ${venue}\n`;
          shareText += `💰 Entry Fee: ${entryFee}\n\n`;
          shareText += `🔗 View details: ${url}`;
          
          if (navigator.share) {
            navigator.share({ title: title, text: shareText, url: url }).catch(() => {
              showShareOptions(url, title, shareText, shareBtn, '');
            });
          } else {
            showShareOptions(url, title, shareText, shareBtn, '');
          }
        });
      }
      
      return card;
    }
  }
});
