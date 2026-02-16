import React from 'react';
import ReactDOM from 'react-dom/client';
import ImageMetaModal from './ImageMetaModal';

let modalRoot = document.getElementById('image-meta-modal-root');
if (!modalRoot) {
  modalRoot = document.createElement('div');
  modalRoot.id = 'image-meta-modal-root';
  document.body.appendChild(modalRoot);
}

ReactDOM.createRoot(modalRoot).render(<ImageMetaModal />);

document.addEventListener('click', (event) => {
  const figure = event.target.closest('figure');
  if (!figure) return;

  const img = figure.querySelector('img');
  const src = img?.getAttribute('src');
  const signedId = extractSignedIdFromUrl(src);
  if (!signedId) return;

  if (typeof window.dispatchImageMetaModal === 'function') {
    window.dispatchImageMetaModal({ signedId });
  }
});

function extractSignedIdFromUrl(url) {
  const match = url?.match(/blobs\/redirect\/([^/?]+)/);
  return match ? match[1] : null;
}
