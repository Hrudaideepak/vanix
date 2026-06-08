/**
 * Escapes special characters in a string for use in a regular expression.
 * This is crucial for mitigating Regex Denial of Service (ReDoS) vulnerabilities
 * when user input is used directly within a RegExp object or $regex query.
 *
 * @param {string} string - The user input string to be escaped.
 * @returns {string} - The safely escaped string.
 */
const escapeRegExp = (string) => {
  if (typeof string !== 'string') {
    return '';
  }
  // $& means the whole matched string
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
};

module.exports = {
  escapeRegExp,
};
