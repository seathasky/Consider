# Consider

A World of Warcraft Classic Era addon that emulates the classic "consider" command from early MMORPGs. Get instant feedback on how challenging a target will be before engaging in combat. Works best without nameplates, player and targets frames.

<img src="https://raw.githubusercontent.com/seathasky/Consider/refs/heads/main/img/betterexample.png" alt="Consider examples">



## Features

- **Target Analysis**: Quickly assess the difficulty of any target based on level difference
- **Color-Coded Feedback**: Uses the classic difficulty color system for instant recognition
- **Customizable Keybinding**: Set your preferred key combination for quick access
- **Clean Interface**: Simple settings window with drag-and-drop repositioning
- **Lightweight**: Minimal performance impact with efficient code

## Installation

1. Download the addon files
2. Extract to your `World of Warcraft\_classic_era_\Interface\AddOns\Consider\` folder
3. Restart World of Warcraft or reload your UI (`/reload`)
4. The addon will confirm it's loaded with a chat message

## Usage

### Setting Up Your Keybind
1. Type `/consider` in chat to open the settings window
2. Either:
   - Click **Capture Key** and press your desired key combination
   - Type a key combination (e.g., `SHIFT-G`, `CTRL-F`) in the text field and press Enter
3. Your keybind is automatically saved and ready to use

### Using Consider
- Press your keybind while targeting a mob/player to see the difficulty assessment
- Alternatively, use `/con` for testing without a keybind

## Difficulty Colors

The addon uses the classic MMO color system to indicate difficulty:

| Color | Meaning      | Description |
|-------|--------------|-------------|
| 🟥 Red    | Impossible | Target will likely defeat you easily |
| 🟧 Orange | Very Hard  | Would take exceptional skill to defeat |
| 🟨 Yellow | Harder     | A challenging but winnable fight |
| ⬜ White  | Even Match | Fair fight with uncertain outcome |
| 🟦 Blue   | Easier     | You have a clear advantage |
| 🟩 Green  | Much Easier| Target poses little threat |
| ⬛ Gray   | No Reward  | Too weak to provide experience/rewards |



## Commands

- `/consider` - Opens the settings window to configure keybindings
- `/con` - Performs a consider check on your current target (testing/backup command)

- Automatic keybind saving
- Clean chat notifications

---

*Relive the nostalgia of classic MMO target assessment with Consider - making every encounter decision informed.*
