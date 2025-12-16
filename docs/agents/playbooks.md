# Playbook Creation Guidelines

This document provides a structured approach for AI agents to create clear, consistent, and effective technical playbooks. Follow these guidelines to ensure all generated playbooks meet the standards of the infra-toolkit documentation.

---

## Structure of a Playbook

Each playbook should follow this structure:

1. **Title**  
   - Clearly state the purpose of the playbook.  
   - Example: `# Proxmox VM Setup from Template Playbook`

2. **Introduction**  
   - Briefly describe what the playbook covers and its importance.  
   - Example: `Deploying a new VM from a template streamlines your workflow and ensures consistency across your infrastructure.`

3. **Requirements**  
   - List all prerequisites needed before starting the process.  
   - Example:  
     - `A Proxmox VM template available (e.g., ubuntu-2404-tmpl)`
     - `An SSH public key generated on your local machine`

4. **Step-by-Step Instructions**  
   - Provide clear, numbered steps for the main process.
   - Use bullet points for additional details where necessary.
   - Example:  
     1. In the Proxmox web UI, right-click your chosen template and select **Clone**.

5. **Configuration**  
   - Include any necessary configuration steps after the initial setup.
   - Example:  
     - Configure Cloud-Init before starting the VM.

6. **Initial Setup**  
   - Describe any post-deployment setup that needs to be done via SSH or other methods.
   - Example:  
     - Update the system and install necessary packages.

7. **References**  
   - Provide links to related documents or playbooks for further reading.
   - Example:  
     - For template creation, see [Proxmox VM Template Playbook](proxmox-vm-template.md).

---

## Writing Style

- Use clear and concise language.
- Avoid unnecessary jargon; use terms commonly understood in the context.
- Use active voice and imperative mood for instructions (e.g., "Run the command").
- Format all commands and configuration snippets in code blocks.

---

## Formatting

- Use Markdown syntax for headings, lists, and code blocks.
- Ensure consistent formatting throughout the document.
- Use internal links to connect to other relevant playbooks or documentation.

---

## Markdown Linting

- All playbooks must follow the [Markdown content guidelines](../guidelines/markdown.md) to ensure compatibility with markdown linters (e.g., `markdownlint`).

---

## Review Process

- Review the playbook for clarity, completeness, and accuracy.
- Test the instructions to ensure they work as intended.
- Request peer review for additional feedback before finalizing.

---

By following these guidelines, AI agents can generate playbooks that are easy to read, reliable, and consistent with the rest of the infra-toolkit documentation.
