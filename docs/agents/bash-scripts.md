# Bash Script Creation Guidelines

This document provides a structured approach for AI agents to create safe, readable, and lint-compliant Bash scripts. Follow these guidelines to ensure all generated scripts meet the standards of the infra-toolkit documentation.

---

## Structure of a Bash Script

Each Bash script must be modular and follow this structure:

1. **Script Content**
     - All scripts must be organized into explicit, purpose-driven functions. Function names must clearly describe their purpose (e.g., `parse_arguments`, `run_pre_checks`, `start_runner_container`).
     - Use a `main` function at the bottom to orchestrate execution, and invoke it as `main "$@"`.
     - Required functions in every script:
         - `print_usage`: Print usage instructions.
         - `parse_arguments`: Handle and validate command-line arguments, call `print_usage` on error.
         - `run_pre_checks`: Perform pre-execution checks (e.g., dependencies, environment).
         - Additional functions for script logic as needed, with explicit names.
     - Only use comments for logic that is not obvious.
     - Always look at other scripts under `scripts/` for established patterns and naming conventions.
     - Make use of helper functions and shared logic under `scripts/shared/` by including them at the top of your script, following the pattern:

        ```bash
        source "$CURRENT_DIR/../shared/logging.sh"
        ```

     - Include any other shared files as needed, as shown in other scripts (e.g., `install-docker.sh`, `install-role.sh`).
     - Example template:

    ```bash
    #!/bin/bash
    set -euo pipefail

    print_usage() {
        echo "Usage: $0"
    }

    parse_arguments() {
        if [ "$#" -ne 0 ]; then
            print_usage
            exit 1
        fi
    }

    run_pre_checks() {
        # Non-obvious pre-check logic here
    }

    main() {
        parse_arguments "$@"
        run_pre_checks
        # Call other explicit logic functions as needed
    }

    main "$@"
    ```

2. **Configuration**
   - Describe any variables or settings that need to be adjusted before use.
   - Example:
     - `Set the SERVER_ROLE and CONFIG_DIR variables at the top of the script.`

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
