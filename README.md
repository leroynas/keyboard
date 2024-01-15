## Dependencies

This setup is honed and tested with the following dependencies.

- macOS High Sierra, 10.13
- Brew

## Installation

1. Copy the `hammerspoon/_config.lua.example` file and name it `hammerspoon/_config.lua`. Update the AUTOLOCK_ENABLED and AUTOLOCK_USER_PASSWORD to make use of the auto lock feature.

2. Run setup script from the root folder of the project

   ```sh
   script/setup
   ```

3. Enable accessibility to allow Hammerspoon to do its thing [[screenshot]](screenshots/accessibility-permissions-for-hammerspoon.png)

4. On macOS High Sierra or later, you'll be [prompted to allow Karabiner-Elements to load its kernel extension](https://pqrs.org/osx/karabiner/document.html#usage). Follow the prompts to upgrade your life:
   1. Click "Open System Preferences" [[screenshot]](https://github.com/jasonrudolph/keyboard/blob/v5.0.0/screenshots/karabiner-elements-system-extension-prompt-1.png)
   1. Click "Allow" [[screenshot]](https://github.com/jasonrudolph/keyboard/blob/v5.0.0/screenshots/karabiner-elements-system-extension-prompt-2.png)
