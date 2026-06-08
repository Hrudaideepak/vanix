const dns = require('dns');
try {
  dns.setServers(['8.8.8.8', '8.8.4.4']);
  console.log('🌐 DNS servers patched to Google DNS (8.8.8.8)');
} catch (e) {
  console.warn('⚠️ Failed to patch DNS servers:', e.message);
}
