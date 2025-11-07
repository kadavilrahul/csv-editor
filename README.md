# CSV Editor
An interactive command-line tool for editing CSV files with a user-friendly menu interface.

## 🚀 Quick Start

### Clone Repository

```bash
git clone https://github.com/kadavilrahul/csv-editor.git
```

```bash
cd csv-editor
```

```bash
bash run.sh
```

## Prerequisites

Before using the CSV editor, ensure you have:

1. Bash shell (version 4.0 or higher)
2. Basic Unix utilities (awk, find, wc, head)
3. A terminal that supports ANSI color codes
4. CSV files in your working directory

## Installation Steps

1. Make the script executable (if needed):
   ```bash
   chmod +x run.sh
   ```

2. Ensure you have CSV files to edit:
   ```bash
   ls *.csv  # Check for existing CSV files
   ```

3. Create a backup of your important CSV files:
   ```bash
   cp your_file.csv your_file_backup.csv
   ```

## Features

1. **Interactive File Selection** - Choose from available CSV files in your directory
2. **Row Summary View** - See all rows with product ID and title preview
3. **Detailed Row Inspection** - View complete row data with column names
4. **Cell Editing** - Modify individual cell values with validation
5. **Row Replacement** - Replace entire rows with data from another CSV file
6. **Search Functionality** - Find rows containing specific terms
7. **Color-Coded Interface** - Easy-to-read terminal output with color highlighting
8. **Data Source Management** - Switch between different CSV files during editing

## Project Structure

1. `run.sh` - Main interactive CSV editor script (439 lines of bash code)
2. `test_products.csv` - Sample CSV file with 102 product records
3. `new_data.csv` - Sample data source file for row replacements (108 records)
4. `.opencode/` - Configuration directory with 10 agent files

## How to Use

1. **Start the editor**: Run `bash run.sh`
2. **Select your CSV file**: Choose from the numbered list of available files
3. **Choose data source**: Select a CSV file to use for row replacements
4. **Navigate the menu**: Use options 1-7 to perform different operations:
   - Option 1: View all rows (shows first 20 + header)
   - Option 2: View specific row details
   - Option 3: Edit a cell value
   - Option 4: Replace entire row with new data
   - Option 5: Search for rows
   - Option 6: Change primary CSV file
   - Option 7: Change data source file

## Important Warnings

1. **Data Backup Required**: This script modifies files directly. Always create backups before editing
2. **Special Character Limitations**: The script may not handle CSV cells containing commas, quotes, or pipes correctly
3. **Header Protection**: Row 1 (header) cannot be edited or replaced
4. **File Validation**: Ensure your CSV files are properly formatted before editing

## Troubleshooting

1. **Problem**: "No CSV files found in the current directory"
   **Solution**: Add CSV files to the directory or navigate to the correct folder

2. **Problem**: Script shows garbled colors or formatting
   **Solution**: Use a terminal that supports ANSI color codes (most modern terminals do)

3. **Problem**: Cannot edit cells with special characters
   **Solution**: Manually edit complex cells in a text editor, then use this tool for simple edits

4. **Problem**: Script exits unexpectedly
   **Solution**: Check that your CSV files are properly formatted and not corrupted

5. **Problem**: Changes not saving properly
   **Solution**: Ensure you have write permissions in the directory

## Sample Data

The repository includes sample files:
- `test_products.csv`: Contains anti-aging product data with 11 columns
- `new_data.csv`: Contains replacement data for testing row replacement feature

## Getting Help

If you encounter issues:
1. Check that your CSV files follow standard formatting
2. Verify file permissions in your directory
3. Test with the included sample CSV files first
4. Create an issue on the GitHub repository for bugs

## License
This project is open source and available for free use.