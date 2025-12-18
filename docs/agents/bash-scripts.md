# Bash Script Creation Guidelines

This document provides a structured approach for AI agents to create safe, readable, and lint-compliant Bash scripts. Follow these guidelines to ensure all generated scripts meet the standards of the infra-toolkit documentation.

---

## Structure of a Bash Script

Each Bash script should follow this structure:

1. **Title**
   - Clearly state the purpose of the script.
   - Example: `# Backup Directory to Remote Server Script`

2. **Introduction**
   - Briefly describe what the script does and its importance.
   - Example: `This script automates the backup of a local directory to a remote server using rsync over SSH.`

3. **Script Content**
   - Provide the complete, well-commented script in a code block.
   - **Organize the script logic into functions, and use a `main` function at the bottom to orchestrate the execution flow.**  
     - The `main` function should call other logical functions in the correct order.
     - This improves readability, maintainability, and testability.
   - Example:

    ```bash
    #!/bin/bash
    set -euo pipefail

    do_backup() {
        # ...backup logic...
    }

    cleanup() {
        # ...cleanup logic...
    }

    main() {
        do_backup
        cleanup
    }

    main
    ```

4. **Configuration**
   - Describe any variables or settings that need to be adjusted before use.
   - Example:
     - `Set the SRC_DIR and DEST_SERVER variables at the top of the script.`

---

## Writing Style

- Use clear and concise language in comments and documentation.
- Prefer imperative mood for instructions (e.g., "Run the script").
- Add comments to explain non-obvious logic or important steps.

---

## Bash Scripting Best Practices

- Use `#!/bin/bash` as the shebang for portability.
- Add `set -euo pipefail` at the top for safer scripts.
- Quote all variable expansions (e.g., `"$var"`).
- Use `read -r` to avoid mangling backslashes.
- Avoid using `eval` unless absolutely necessary.
- Use functions for reusable code blocks or to improve readability.
- Always organize scripts with a `main` function that orchestrates other functions.
- Indent with 4 spaces or tabs consistently.
- Check command exit codes and handle errors.
- Prefer long-form options for commands (e.g., `--help`).
- Do not add new functions on top of the file, insert it following a logical sequence.

---

## Formatting

- Use Markdown syntax for headings, lists, and code blocks.
- Ensure consistent formatting throughout the document.
- Format all scripts in fenced code blocks with `bash` specified.

---

## Linting

- All scripts must pass [ShellCheck](https://www.shellcheck.net/) and follow the [Markdown content guidelines](../guidelines/markdown.md) for compatibility with markdown linters (e.g., `markdownlint`).

---

## Review Process

- Review the script for clarity, completeness, and safety.
- Test the script to ensure it works as intended.
- Request peer review for additional feedback before finalizing.

---

By following these guidelines, AI agents can generate Bash scripts that are safe, maintainable, and consistent with the rest of the infra-toolkit documentation.
