import '../choices-input';
import '../color-picker';
import '../file-preview';
import '../knowledge-mermaid';
import '../line-select';
import '../mention';
import '../trix-image-listener'

import Trix from 'trix';
import '@rails/actiontext';
Trix.config.blockAttributes.default.tagName = 'p';
Trix.config.blockAttributes.heading1.tagName = 'h3';
