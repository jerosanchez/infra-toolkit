# Makefile content

To ensure that AI-generated Makefiles are portable and avoid common errors:

- Use spaces instead of tabs for command indentation to prevent 'missing separator' errors in some environments.
- Clearly separate variable definitions and rules with blank lines.
- Use `.PHONY` at the end of the file for non-file targets (like `lint`, `clean`, etc.).
- Add comments to explain complex rules or variables.
- Keep recipes simple and readable.
