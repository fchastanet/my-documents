// ESLint flat config (ESLint v9+/v10)
// https://eslint.org/docs/latest/use/configure/configuration-files
// CommonJS + require() on purpose: MegaLinter runs ESLint from its own
// /node-deps/node_modules, and require() honors NODE_PATH whereas ESM imports don't.
const jsonc = require('eslint-plugin-jsonc');

// JS-only helpers are optional: ESLint v10 no longer bundles @eslint/js and
// MegaLinter's image does not ship it or globals.
const optionalRequire = (name) => {
  try {
    return require(name);
  } catch {
    return undefined;
  }
};
const js = optionalRequire('@eslint/js');
const globals = optionalRequire('globals');
const prettierRecommended = optionalRequire('eslint-plugin-prettier/recommended');

// eslint-plugin-jsonc v2 exposes flat configs as 'flat/<name>', v3 as '<name>'
const jsoncConfig = (name) => jsonc.configs[`flat/${name}`] || jsonc.configs[name];

const jsFiles = ['**/*.js', '**/*.cjs', '**/*.mjs'];

module.exports = [
  {
    ignores: ['.history/', 'node_modules/', 'public/', 'report/', 'megalinter-reports/'],
  },
  ...(js ? [{...js.configs.recommended, files: jsFiles}] : []),
  ...(prettierRecommended ? [{...prettierRecommended, files: jsFiles}] : []),
  {
    files: jsFiles,
    languageOptions: {
      ecmaVersion: 2021,
      sourceType: 'commonjs',
      globals: globals ? {...globals.es2021, ...globals.node} : {},
    },
  },
  ...[].concat(jsoncConfig('recommended-with-jsonc')).map((config) => ({
    ...config,
    files: ['**/*.json', '**/*.jsonc'],
  })),
  ...[].concat(jsoncConfig('recommended-with-json5')).map((config) => ({
    ...config,
    files: ['**/*.json5'],
  })),
];
