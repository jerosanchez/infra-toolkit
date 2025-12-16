# Makefile Creation Guidelines

This document provides a structured approach for AI agents to create clear, portable, and error-free Makefiles. Follow these guidelines to ensure all generated Makefiles meet the standards of the infra-toolkit documentation.

---

## Structure of a Makefile

Each Makefile should follow this structure:

1. **Title**
   - Clearly state the purpose of the Makefile.
   - Example: `# Project Build and Automation Makefile`

2. **Introduction**
   - Briefly describe what the Makefile covers and its importance.
   - Example: `This Makefile automates common build, test, and clean tasks for the project.`

3. **Requirements**
   - List all prerequisites needed before using the Makefile.
   - Example:
     - `GNU Make installed`
     - `Required build tools and dependencies available`

4. **Variable Definitions**
   - Define variables at the top for easy configuration.
   - Example:

     ```makefile
     CC = gcc
     CFLAGS = -Wall -Werror
     ```

5. **Rules**
   - Clearly separate variable definitions and rules with blank lines.
   - Use tabs for command indentation, as required by Makefile syntax and to ensure compatibility with linters.
   - Example:

     ```makefile
     all:
         $(CC) $(CFLAGS) main.c -o main
     ```

6. **.PHONY Targets**
   - Add `.PHONY` at the end of the file for non-file targets (like `clean`, `lint`, etc.).
   - Example:

     ```makefile
     .PHONY: all clean lint
     ```

7. **Comments**
   - Add comments to explain complex rules or variables.
   - Example:

     ```makefile
     # Clean up build artifacts
     clean:
         rm -f main
     ```

8. **References**
   - Provide links to related documentation or guides for further reading.
   - Example:
     - See [GNU Make Manual](https://www.gnu.org/software/make/manual/make.html).

---

## Writing Style

- Use clear and concise language in comments and documentation.
- Prefer imperative mood for instructions (e.g., "Run `make clean` to remove build artifacts").
- Add comments to explain non-obvious logic or important steps.

---

## Makefile Best Practices

- Use tabs for command indentation as required by Makefile syntax.
- Clearly separate variable definitions and rules with blank lines.
- Keep recipes simple and readable.
- Use `.PHONY` for non-file targets.
- Avoid unnecessary complexity in rules.

---

## Formatting

- Use Markdown syntax for headings, lists, and code blocks in documentation.
- Ensure consistent formatting throughout the document.
- Format all Makefile examples in fenced code blocks with `makefile` specified.

---

## Linting

- All Makefiles must follow the [Markdown content guidelines](../guidelines/markdown.md) for compatibility with markdown linters (e.g., `markdownlint`).

---

## Review Process

- Review the Makefile for clarity, completeness, and portability.
- Test the Makefile to ensure it works as intended.
- Request peer review for additional feedback before finalizing.

---

By following these guidelines, AI agents can generate Makefiles that are portable, maintainable, and consistent with the rest of the infra-toolkit documentation.
