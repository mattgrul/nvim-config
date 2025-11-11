You are tasked with developing a Neovim plugin for Magento development, similar to the Laravel.nvim plugin. You will be provided with a reference codebase and a specific feature request to implement.

First, here is the Laravel.nvim codebase for reference. Study this carefully to understand the plugin structure, coding patterns, and implementation approach:

/home/matt/Documents/laravel-nvim

## Project Context

You are building a Magento.nvim plugin that should provide similar functionality to Laravel.nvim but adapted for Magento 2 development. The plugin should help developers navigate Magento's complex file structure, understand relationships between files, and provide useful development shortcuts.

## Technical Requirements

- **Performance**: The plugin must be fast and performant in Neovim
- **Modern Syntax**: Use modern Neovim Lua syntax and functions available in recent versions
- **Minimal Dependencies**: Keep third-party plugins to a minimum, only using them when necessary for:
  - Async operations
  - Integration with pickers like Snacks picker or Telescope
  - Other essential functionality that can't be efficiently implemented from scratch
- **Code Quality**: Follow the same coding patterns, structure, and organization as seen in the Laravel.nvim codebase
- **Magento-Specific**: Adapt the concepts to work with Magento 2's architecture (modules, themes, dependency injection, etc.)

## Implementation Guidelines

- Study the Laravel.nvim folder structure and replicate a similar organization
- Understand how Laravel.nvim handles configuration, commands, and user interactions
- Adapt the patterns to work with Magento's unique file structures and conventions
- Ensure the code is well-documented and follows Lua best practices for Neovim plugins

<scratchpad>
Before implementing, think through:
1. How does this feature work in Laravel.nvim and what can be adapted?
2. What are the Magento-specific requirements for this feature?
3. What files and folder structure will be needed?
4. What dependencies (if any) are required?
5. How should this integrate with the overall plugin architecture?
6. What configuration options should be available to users?
</scratchpad>

Provide a complete implementation of the requested feature. Your response should include:

1. **File Structure**: List all files that need to be created or modified, with their relative paths
2. **Code Implementation**: Provide the complete code for each file
3. **Configuration**: Show any configuration options that should be available
4. **Usage Instructions**: Explain how users will interact with this feature
5. **Integration Notes**: Describe how this feature integrates with the rest of the plugin

Format your response with clear sections and use appropriate code blocks with language specification. Make sure your implementation follows the patterns established in the Laravel.nvim codebase while being adapted appropriately for Magento development.
