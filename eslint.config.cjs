const { FlatCompat } = require('@eslint/eslintrc')
const js = require('@eslint/js')
const path = require('path')

const compat = new FlatCompat({
    allConfig: js.configs.all,
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
})

const legacyConfig = {
    root: true,
    parser: '@typescript-eslint/parser',
    parserOptions: {
        ecmaFeatures: { jsx: true },
        ecmaVersion: 2022,
        sourceType: 'module',
        tsconfigRootDir: __dirname,
    },
    plugins: ['@typescript-eslint', 'prettier', 'react', 'react-hooks'],
    extends: [
        'eslint:recommended',
        'plugin:@typescript-eslint/recommended',
        'plugin:react/jsx-runtime',
        'plugin:react/recommended',
        // Prettier should be last so it can disable formatting rules from eslint
        'plugin:prettier/recommended',
    ],
    settings: { react: { version: 'detect' } },
    env: { browser: true, es2022: true, node: true },
    rules: {
        'no-console': 'warn',
        'prettier/prettier': 'error',
        'react-hooks/exhaustive-deps': 'warn',
        'react-hooks/rules-of-hooks': 'error',
        'react/react-in-jsx-scope': 'off',
    },
    overrides: [
        { files: ['**/*.js', '**/*.jsx'], rules: { '@typescript-eslint/no-unused-vars': 'off' } },
        { files: ['**/*.ts', '**/*.tsx'], parserOptions: { projectService: true } },
    ],
}

module.exports = [
    {
        ignores: [
            '.bundle/**',
            '.eslintcache',
            '.pnpm-store/**',
            'coverage/**',
            'db/*.sqlite3',
            'dist/**',
            'log/**',
            'node_modules/**',
            'public/**',
            'public/packs/**',
            'storage/**',
            'tmp/**',
            'vendor/bundle/**',
            'vite-dev/**',
            'vite-test/**',
        ],
    },
    ...compat.config(legacyConfig),
]
