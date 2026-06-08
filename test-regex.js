const regexChars = /[.*+?^${}()|[\]\\]/g;
const escapeRegExp = (string) => {
  return string.replace(regexChars, '\\$&'); // $& means the whole matched string
};

console.log(escapeRegExp("foo+bar*baz"));
