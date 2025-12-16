# Markdown Content Guidelines

This document provides a structured approach for AI agents to create markdown content that is clear, consistent, and passes linting checks (e.g., `markdownlint`). Follow these guidelines to ensure all generated markdown meets the standards of the infra-toolkit documentation.

---

## Writing Style

- Use clear and concise language.
- Prefer imperative mood for instructions (e.g., "Run the command").
- Use consistent terminology and formatting throughout the document.

---

## Markdown Best Practices

- Surround lists with blank lines.
- Add blank lines before and after headings.
- Do not break paragraphs into multiple lines (ignore line length).
- Use proper indentation for nested lists and code blocks.
- Use fenced code blocks (triple backticks) for code snippets.
- Always specify the code type (language) in fenced code blocks (e.g., `bash`, `python`).
- For generic (no language) fenced code blocks, use `text`.
- Avoid trailing spaces at the end of lines.
- End files with a single newline.
- Use consistent heading levels and formatting.

---

## Formatting

- Use Markdown syntax for headings, lists, and code blocks.
- Ensure consistent formatting throughout the document.
- Format all code examples in fenced code blocks with the appropriate language specified.

---

## Linting

- All markdown content must follow these guidelines to ensure compatibility with markdown linters (e.g., `markdownlint`).

---

## Review Process

- Review the document for clarity, completeness, and formatting.
- Test the document by running `make lint` to ensure it passes all checks.
- Request peer review for additional feedback before finalizing.

---

By following these guidelines, AI agents can generate markdown content that is readable, maintainable, and consistent with the rest of the infra-toolkit documentation.
