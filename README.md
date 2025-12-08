# CSV Editor

A professional command-line tool for editing CSV files with both interactive menu and direct CLI command support. Built with a powerful vi-style terminal editor for handling large files efficiently.

## 🚀 Quick Start

### Clone Repository

```bash
git clone https://github.com/kadavilrahul/csv-editor.git
```
```bash
cd csv-editor
```

### Configuration

1. Create your configuration file:
   ```bash
   cp config.example.sh config.sh
   ```

2. Edit `config.sh` to set your CSV files:
   ```bash
   CSV_FILE="./products.csv"
   NEW_DATA_FILE="./new_data.csv"  # Optional: for row replacement
   ```

3. Run the editor:
   ```bash
   ./run.sh
   ```

## Prerequisites

Before using the CSV editor, ensure you have:

1. **Bash shell** (version 4.0 or higher)
2. **Basic Unix utilities** (awk, find, wc, head)
3. **CSV files** in your working directory
4. **Go (Golang)** - Required for building the csvi terminal editor (recommended for large files >10MB)
5. **Make** - For building the csvi binary

## Features

### Core Features

1. **Config-Based File Selection** - No interactive prompts; set files in `config.sh`
2. **Dual Operation Modes** - Interactive menu or direct CLI commands
3. **View Multiple Columns** - Display up to 10 columns in summary view
4. **Row-Level Operations** - View, edit, search, and replace rows
5. **Search Functionality** - Search across all columns for specific terms
6. **Professional Interface** - Clean, structured menu system
7. **Live Configuration Reload** - Update config without restarting

### Advanced Features (CSVI Terminal Editor)

8. **Terminal-Based CSV Editor** - Full-featured vi-style CSV editor for large files
9. **Fast Startup** - Opens large files (100MB+) quickly with background loading
10. **Minimal Changes on Save** - Only modified cells are updated, preserving original formatting
11. **Visual Feedback** - Modified cells are underlined for easy tracking
12. **Undo Support** - Press `u` to restore original cell values
13. **Copy/Paste** - Use `y` to copy and `p` to paste cell values
14. **Search & Navigation** - Forward/backward search with vi-style keybindings
15. **Source Code Included** - Full Go source code for building and customization

## Project Structure

```
csv-editor/
├── run.sh              # Main executable (interactive + CLI modes)
├── config.sh           # Configuration file (CSV_FILE, NEW_DATA_FILE)
├── config.example.sh   # Example configuration template
├── csvi-bin            # Compiled csvi editor binary
├── main.go             # Main csvi application code
├── go.mod              # Go module dependencies
├── go.sum              # Go module checksums
├── Makefile            # Build configuration
├── candidate/          # Candidate-related code
├── cmd/                # Command-line interface code
├── internal/           # Internal packages (ansi, manualctl, nonblock)
├── startup/            # Startup and initialization code
├── uncsv/              # CSV parsing utilities
└── [sample CSV files]  # Example data files
```

## Usage

### Interactive Mode

Launch the full interactive menu:

```bash
./run.sh
```

You'll see a professional menu with all available options:

```
========================================================================================================
                                         MAIN MENU                                                      
========================================================================================================

VIEWING & NAVIGATION
--------------------------------------------------------------------------------------------------------
1. View all rows (summary)               ./run.sh view              # Show first 20 rows, 10 columns
2. View specific row details             ./run.sh row 5             # View all columns for row 5
3. Search for rows                       ./run.sh search 'term'     # Search rows containing 'term'

EDITING OPTIONS
--------------------------------------------------------------------------------------------------------
4. Install/Build csvi editor             ./run.sh build             # Build the csvi binary
5. Open in csvi editor (Vi-style)        ./run.sh csvi              # Recommended for large files (>10MB)
6. Edit a cell (small files)             ./run.sh edit 10 3         # Edit row 10, column 3 (<10MB)
7. Replace entire row (small files)      ./run.sh replace 5         # Replace row 5 with data source (<10MB)

CONFIGURATION
--------------------------------------------------------------------------------------------------------
8. Reload configuration from config.sh   ./run.sh reload            # Reload CSV file settings

HELP
--------------------------------------------------------------------------------------------------------
Type 'help' or run ./run.sh help for detailed usage guide

0. Exit
```

### Direct CLI Commands

Run operations directly from the command line:

**Viewing Data:**
```bash
./run.sh view                    # View first 20 rows, up to 10 columns
./run.sh row 5                   # View all columns for row 5
./run.sh search 'collagen'       # Search for rows containing 'collagen'
```

**Editing (Small Files <10MB):**
```bash
./run.sh edit 10 3               # Edit row 10, column 3
./run.sh replace 5               # Replace row 5 with data from NEW_DATA_FILE
```

**Editing (Large Files >10MB):**
```bash
./run.sh csvi                    # Open vi-style terminal editor
```

**System:**
```bash
./run.sh build                   # Build csvi editor from source
./run.sh reload                  # Reload configuration from config.sh
./run.sh help                    # Show detailed usage guide
```

## CSVI Terminal Editor

The CSVI terminal editor is based on [hymkor/csvi](https://github.com/hymkor/csvi) - a powerful vi-style CSV editor optimized for large files.

### Installation

The csvi editor can be built automatically:

```bash
./run.sh build
```

Or manually using make:

```bash
make
```

**Requirements:**
- Go (Golang) 1.21 or later
- Make utility

### Key Bindings (CSVI Editor)

Once inside the csvi editor, use these vi-style keybindings:

**Navigation:**
- `h`, `←`, `Shift-TAB` - Move cursor left
- `j`, `↓`, `Enter` - Move cursor down
- `k`, `↑` - Move cursor up
- `l`, `→`, `TAB` - Move cursor right
- `0`, `^`, `Ctrl-A` - Beginning of line
- `$`, `Ctrl-E` - End of line
- `<` - Beginning of file
- `>`, `G` - End of file

**Editing:**
- `r` - Replace current cell
- `i` - Insert new cell before current
- `a` - Append new cell after current
- `d`, `x` - Delete current cell
- `D` - Delete current line
- `o` - Append new line after current
- `O` - Insert new line before current
- `u` - Undo (restore original cell value)
- `y` - Copy current cell to clipboard
- `p` - Paste clipboard to current cell
- `"` - Toggle double quotes on current cell

**Search:**
- `/` - Search forward
- `?` - Search backward
- `n` - Repeat search forward
- `N` - Repeat search backward
- `*` - Search forward for exact match
- `#` - Search backward for exact match

**File Operations:**
- `w` - Write/save file
- `q`, `ESC` - Quit editor

**Display:**
- `Ctrl-L` - Repaint screen
- `]` - Widen current column
- `[` - Narrow current column
- `L` - Reload with different encoding

## Configuration

Edit `config.sh` to configure your CSV files:

```bash
#!/bin/bash

# CSV Editor Configuration File

# Primary CSV file to edit (required)
CSV_FILE="./products.csv"

# Data source file for row replacements (optional)
# Set to empty string "" if not needed
NEW_DATA_FILE="./new_data.csv"
```

You can reload the configuration while the editor is running:
- Interactive mode: Select option 8
- CLI mode: `./run.sh reload`

## Important Notes

1. **Data Backup Required**: This tool modifies files directly. Always create backups before editing
2. **File Size Recommendations**: 
   - Small files (<10MB): Use basic editing (options 6-7)
   - Large files (>10MB): Use csvi editor (option 5) for better performance
3. **Header Protection**: Row 1 (header) cannot be edited or replaced
4. **File Validation**: Ensure your CSV files are properly formatted before editing

## Performance Comparison

| File Size | Basic Editor (Options 6-7) | CSVI Editor (Option 5) |
|-----------|---------------------------|------------------------|
| < 10 MB   | Fast ✓                    | Fast ✓                 |
| 10-100 MB | Slow ⚠                    | Fast ✓                 |
| > 100 MB  | Very Slow/Hangs ✗         | Fast ✓                 |

**Recommendation**: Use CSVI editor (option 5) for files larger than 10MB.

## Troubleshooting

### Common Issues

1. **"Configuration file not found"**
   - Solution: Copy `config.example.sh` to `config.sh` and configure your file paths

2. **"CSV file not found"**
   - Solution: Check the path in `config.sh` and ensure the file exists

3. **"Go is not installed" error when building csvi**
   - Solution: The script will offer to install Go automatically, or install manually

4. **Changes not saving properly**
   - Solution: Ensure you have write permissions in the directory

5. **CSVI editor hangs on very large files**
   - Solution: Be patient during initial load. CSVI loads in the background and becomes responsive quickly

6. **Cannot edit cells with special characters (basic mode)**
   - Solution: Use the csvi editor (option 5) which handles all CSV formatting correctly

## Sample Data

The repository includes sample files for testing:
- `products.csv`: Product catalog data
- `new_data.csv`: Sample data for row replacement testing
- `sample_data.csv`: Additional sample data

## Development

### Building from Source

```bash
# Build the csvi binary
make

# Clean build artifacts
make clean

# Run tests
make test
```

### Source Code Structure

The project includes the complete CSVI editor source code:
- **main.go** - Main application logic
- **cmd/** - Command-line interface
- **internal/** - Internal packages for ANSI handling, manual control, and non-blocking I/O
- **startup/** - Application startup and configuration
- **uncsv/** - CSV parsing and handling utilities

## Credits

This CSV editor tool combines custom bash scripting with the powerful CSVI terminal editor.

### CSVI Terminal Editor

The CSVI editor is based on [hymkor/csvi](https://github.com/hymkor/csvi) by HAYABUSA Masanao.

**Original Repository**: https://github.com/hymkor/csvi

**License**: [MIT License](LICENSE)

The CSVI editor provides:
- Vi-style keybindings for efficient editing
- Fast loading and rendering for large CSV files
- Minimal file modification (only changed cells are updated)
- Advanced search and navigation features
- Multi-encoding support (UTF-8, UTF-16, Shift_JIS, etc.)

We are grateful to HAYABUSA Masanao and all contributors to the hymkor/csvi project for creating this excellent terminal-based CSV editor.

### Enhancements in This Repository

This repository adds:
- Configuration-based file selection system
- Direct CLI command support
- Interactive menu interface
- Integrated bash scripting wrapper
- Pre-configured build system
- Enhanced documentation and examples

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

For issues related to the core CSVI editor functionality, please report them to the original repository: https://github.com/hymkor/csvi

For issues related to the bash wrapper, configuration system, or CLI interface, please report them to this repository.

## License

This project is open source and available under the MIT License.

The CSVI editor component is licensed under the MIT License by HAYABUSA Masanao. See the [LICENSE](LICENSE) file for details.

## Links

- **Original CSVI Repository**: https://github.com/hymkor/csvi
- **CSVI Documentation**: https://github.com/hymkor/csvi/blob/master/README.md
- **This Repository**: https://github.com/kadavilrahul/csv-editor

---

**Made with ❤️ by the community**

*Standing on the shoulders of giants - Thank you to all open source contributors!*
