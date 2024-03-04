module.exports = {
    "env": {
        "node": true, // Use Node.js environment globally
        "es2021": true
    },
    "extends": "eslint:recommended",
    "parserOptions": {
        "ecmaVersion": 12, // or "latest"
        "sourceType": "script" // Use "script" for Node.js (CommonJS), or "module" if using ES modules
    },
    "rules": {
        // Your custom rules here
    }
};
