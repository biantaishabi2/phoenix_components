// Wrapper for topbar to provide ES6 module compatibility
// The topbar.js file uses CommonJS module.exports and expects 'this' to be window

// Since we're in a module context where 'this' is undefined,
// we need to manually execute the topbar function with the correct context

// First, we'll load the topbar code as text and execute it manually
const topbarCode = await fetch(new URL('./topbar.js', import.meta.url)).then(r => r.text());

// Execute the code in a way that provides the correct 'this' context
const fn = new Function('window', 'document', topbarCode.replace('}.call(this, window, document));', '}.call(window, window, document));'));
fn(window, document);

// Now window.topbar should be available
export default window.topbar;