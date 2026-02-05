Here is a professional, clean, and comprehensive `README.md` for your project.

---

# ❄️ Cold Neo Writer

**The digital straitjacket for Neovim.**

Cold Neo Writer is a plugin and launcher designed to enforce deep work sessions. It turns Neovim into a "Prison Mode" writing kiosk that physically prevents you from quitting, switching tabs, or even `Alt-Tab`ing to other applications until your timer expires.

## ✨ Features

### 🔒 Level 1: The Vim Prison

Once a session starts, the plugin hijacks your editor:

* **No Exit:** `:q`, `:wq`, `ZZ`, and `:x` are disabled.
* **No Multitasking:** Splits (`:vsp`), Tabs (`:tabnew`), and Buffer switching (`:bn`) are blocked.
* **No Browsing:** File explorers (`:Netrw`, `:e .`) are disabled.
* **Status Line:** Your status bar is replaced by a minimalist countdown timer.

### ❄️ Level 2: The OS Enforcer

If you try to `Alt-Tab` (or `Cmd-Tab`) away to a web browser or Slack:

* **Focus Stealing:** The plugin detects the active window. If it is not Neovide or a PDF Reader, it forcibly pulls the focus back to Neovim.
* **OS Agnostic:** Works on macOS (AppleScript), Linux (wmctrl), and Windows.

### 🚀 The ColdWriter Launcher

Includes a dedicated launcher script (`coldwriter`) that runs Neovim in a standalone GUI (**Neovide**), removing terminal tabs and UI distractions entirely.

## 🛠️ Prerequisites

* **Neovim** (0.8+)
* **Neovide** (Recommended wrapper, installed automatically by the script)
* **OS Specifics:**
* **Linux:** `wmctrl` (Required for focus stealing on X11). *Note: Wayland users will have Level 1 blocking only.*
* **macOS:** You must grant "Accessibility" permissions to Terminal/Neovide when prompted.

## 📦 Installation

### 1. Download the Source

Clone this repository or download the folder to your preferred location (e.g., `~/code/cold-neo-writer`).

```bash
git clone https://github.com/yourusername/cold-neo-writer.git ~/code/cold-neo-writer
```

### 2. Run the Environment Setup

This script installs **Neovide**, creates the `coldwriter` launcher, and adds it to your PATH.

* **Mac / Linux:**
```bash
cd cold-neo-writer
chmod +x install.sh
./install.sh
```

### 3. Add to Package Manager

Tell your plugin manager to load the plugin from your local folder.

#### **Lazy.nvim**

```lua
{
    dir = "~/code/cold-neo-writer", -- Use the actual path where you cloned it
    name = "cold-neo-writer",
    config = function()
        -- Optional setup
    end
}

```

#### **Packer.nvim**

```lua
use {
  '~/code/cold-neo-writer',
  as = 'cold-neo-writer'
}

```

---

## 🚀 Usage

### The "Pro" Way (Launcher)

Open your terminal and use the `coldwriter` command. This opens a focused GUI window.

```bash
coldwriter my_thesis.tex
```

*This launches Neovide and immediately starts a 60-minute session.*

### The Manual Way

Open any file in Neovim and run:

```vim
:ColdStart 30
```

*(Locks the session for 30 minutes)*

### Emergency Exit

If you absolutely must quit before the timer ends (for debugging or emergencies):

```vim
:ColdStop
```

## ⚙️ Configuration

You can customize the **Allowed Apps** (PDF readers that won't trigger the punishment) by editing `lua/cold_neo/enforcer.lua`:

```lua
M.allowed_apps = {
    linux = { "zathura", "okular", "evince" },
    mac = { "Skim", "Preview", "Adobe" },
    windows = { "SumatraPDF", "Acrobat" }
}
```

## ⚠️ Known Limitations
1. **Wayland (Linux):** Modern Linux desktop environments (Wayland) prevent applications from stealing focus for security reasons. On these systems, the "OS Enforcer" (Level 2) will silently fail, but the "Vim Prison" (Level 1) will still work perfectly.
2. **macOS Permissions:** The first time you run this, macOS will ask for permission to control "System Events". You **must click Allow**, or the focus stealing will not work.
