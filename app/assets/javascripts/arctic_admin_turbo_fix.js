// Turbo compatibility for Arctic Admin and Trix
document.addEventListener('turbo:load', function() {
  // Re-initialize Arctic Admin listeners
  if (typeof removeListeners === 'function') removeListeners();
  if (typeof addListeners === 'function') addListeners();
  
  // Ensure Trix editors are properly initialized
  if (typeof Trix !== 'undefined') {
    document.querySelectorAll('trix-editor').forEach(function(editor) {
      if (!editor.editor) {
        var input = editor.previousElementSibling;
        if (input && input.tagName === 'INPUT' && input.type === 'hidden') {
          editor.setAttribute('input', input.id);
        }
      }
    });
  }
});

