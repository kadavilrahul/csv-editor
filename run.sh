#!/bin/bash

# CSV Editor Script
# Interactive tool to modify cells in a selected CSV file

# Load configuration
CONFIG_FILE="./config.sh"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[ERROR] Configuration file '$CONFIG_FILE' not found!"
    echo "Please create config.sh with CSV_FILE and NEW_DATA_FILE settings."
    exit 1
fi

# Source the config file to load CSV_FILE and NEW_DATA_FILE
source "$CONFIG_FILE"

TEMP_FILE="/tmp/csv_temp_$$"

# Function to load CSV files from config
load_csv_files() {
    # Validate CSV_FILE
    if [ -z "$CSV_FILE" ]; then
        echo "[ERROR] CSV_FILE not set in config.sh"
        echo "Please edit config.sh and set CSV_FILE to your CSV file path."
        exit 1
    fi
    
    if [ ! -f "$CSV_FILE" ]; then
        echo "[ERROR] CSV file '$CSV_FILE' not found!"
        echo "Please check the path in config.sh"
        exit 1
    fi
    
    echo "[INFO] Loaded CSV file from config: $CSV_FILE"
    
    # Validate NEW_DATA_FILE if set
    if [ -n "$NEW_DATA_FILE" ] && [ ! -f "$NEW_DATA_FILE" ]; then
        echo "[WARNING] NEW_DATA_FILE '$NEW_DATA_FILE' not found. Row replacement will not be available."
        NEW_DATA_FILE=""
    fi
    
    sleep 1
}

# Function to check and install csvi
check_install_csvi() {
    local CSVI_PATH="./csvi-bin"
    
    if [ -f "$CSVI_PATH" ]; then
        echo "[SUCCESS] csvi editor is already installed."
        return 0
    fi
    
    echo "[INFO] csvi editor not found. Building from source..."
    
    # Check if Go is installed
    if ! command -v go &> /dev/null; then
        echo "[ERROR] Go is not installed!"
        echo "[INFO] Installing Go..."
        echo -n "Continue? (y/n): "
        read confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            DEBIAN_FRONTEND=noninteractive apt-get update -qq
            DEBIAN_FRONTEND=noninteractive apt-get install -y -qq golang-go
            if ! command -v go &> /dev/null; then
                echo "[ERROR] Failed to install Go."
                return 1
            fi
            echo "[SUCCESS] Go installed successfully!"
        else
            return 1
        fi
    fi
    
    # Build csvi from root directory
    echo "[INFO] Building csvi editor from source (this may take a minute)..."
    if make; then
        # Move the built binary to csvi-bin
        if [ -f "./csvi" ]; then
            mv ./csvi ./csvi-bin
            echo "[SUCCESS] csvi editor built successfully!"
            return 0
        else
            echo "[ERROR] Build succeeded but binary not found."
            return 1
        fi
    else
        echo "[ERROR] Failed to build csvi editor."
        return 1
    fi
}

# Function to launch csvi editor
launch_csvi() {
    local CSVI_PATH="./csvi-bin"
    
    if [ ! -f "$CSVI_PATH" ]; then
        echo "[ERROR] csvi editor not found. Checking..."
        check_install_csvi
        if [ ! -f "$CSVI_PATH" ]; then
            echo "[ERROR] Failed to find csvi editor."
            return 1
        fi
    fi
    
    if [ ! -f "$CSV_FILE" ]; then
        echo "[ERROR] No CSV file selected!"
        return 1
    fi
    
    echo "[INFO] Launching csvi editor..."
    echo "Key bindings:"
    echo "  Navigate: Arrow keys or hjkl (vi-style)"
    echo "  Edit cell: r (replace)"
    echo "  Save: w"
    echo "  Undo: u"
    echo "  Search: / (forward), ? (backward)"
    echo "  Quit: q or ESC"
    echo ""
    echo "Press Enter to continue..."
    read
    
    # Launch csvi with the selected CSV file
    "$CSVI_PATH" "$CSV_FILE"
    
    echo ""
    echo "[INFO] csvi editor closed."
    return 0
}

# Function to reload config
reload_config() {
    display_header
    echo "[INFO] Reloading configuration from config.sh..."
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "[ERROR] Configuration file '$CONFIG_FILE' not found!"
        return 1
    fi
    
    # Reload the config file
    source "$CONFIG_FILE"
    
    # Validate the new settings
    if [ -z "$CSV_FILE" ]; then
        echo "[ERROR] CSV_FILE not set in config.sh"
        return 1
    fi
    
    if [ ! -f "$CSV_FILE" ]; then
        echo "[ERROR] CSV file '$CSV_FILE' not found!"
        return 1
    fi
    
    echo "[SUCCESS] Configuration reloaded successfully!"
    echo "CSV File: $CSV_FILE"
    echo "Data Source File: ${NEW_DATA_FILE:-None}"
    sleep 2
    return 0
}

# Function to display header
display_header() {
    clear
    echo "========================================"
    echo "     CSV EDITOR - INTERACTIVE MODE     "
    echo "========================================"
    echo ""
    echo "NOTE: This script modifies the file directly. Please create a backup of your CSV file before using this editor."
    echo ""
}

# Function to count total rows (including header)
count_rows() {
    if [ -f "$CSV_FILE" ]; then
        local count=$(wc -l < "$CSV_FILE")
        echo $count
    else
        echo 0
    fi
}

# Function to get column names
get_columns() {
    head -1 "$CSV_FILE"
}

# Function to display menu
display_menu() {
    echo "========================================================================================================"
    echo "                                         MAIN MENU                                                      "
    echo "========================================================================================================"
    echo ""
    echo "VIEWING & NAVIGATION"
    echo "--------------------------------------------------------------------------------------------------------"
    echo "1. View all rows (summary)               ./run.sh view              # Show first 20 rows, 10 columns"
    echo "2. View specific row details             ./run.sh row 5             # View all columns for row 5"
    echo "3. Search for rows                       ./run.sh search 'term'     # Search rows containing 'term'"
    echo ""
    echo "EDITING OPTIONS"
    echo "--------------------------------------------------------------------------------------------------------"
    echo "4. Install/Build csvi editor             ./run.sh build             # Build the csvi binary"
    echo "5. Open in csvi editor (Vi-style)        ./run.sh csvi              # Recommended for large files (>10MB)"
    echo "6. Edit a cell (small files)             ./run.sh edit 10 3         # Edit row 10, column 3 (<10MB)"
    echo "7. Replace entire row (small files)      ./run.sh replace 5         # Replace row 5 with data source (<10MB)"
    echo ""
    echo "CONFIGURATION"
    echo "--------------------------------------------------------------------------------------------------------"
    echo "8. Reload configuration from config.sh   ./run.sh reload            # Reload CSV file settings"
    echo ""
    echo "HELP"
    echo "--------------------------------------------------------------------------------------------------------"
    echo "Type 'help' or run ./run.sh help for detailed usage guide"
    echo ""
    echo "0. Exit"
    echo ""
    echo "========================================================================================================"
    echo ""
    echo -n "Enter your choice [0-8] or command: "
}

# Function to view all rows in summary
view_all_rows() {
    display_header
    echo "Total Rows (including header): $(count_rows)"
    echo ""
    
    # Get header to determine number of columns
    local header=$(get_columns)
    IFS=',' read -ra COLUMNS <<< "$header"
    local num_cols=${#COLUMNS[@]}
    local display_cols=$((num_cols < 10 ? num_cols : 10))
    
    echo "Displaying first $display_cols columns:"
    echo ""
    
    # Display with proper field parsing for CSV
    awk -F',' -v cols="$display_cols" '
    BEGIN {FPAT = "([^,]*)|(\"[^\"]*\")"}
    NR==1 {
        printf "%4s | ", "Row#"
        for(i=1; i<=cols && i<=NF; i++) {
            col = $i
            gsub(/^"|"$/, "", col)
            printf "%-20s | ", substr(col, 1, 20)
        }
        printf "\n"
        for(i=0; i<(cols*24)+10; i++) printf "-"
        printf "\n"
    }
    NR<=21 {
        printf "%4d | ", NR
        for(i=1; i<=cols && i<=NF; i++) {
            col = $i
            gsub(/^"|"$/, "", col)
            printf "%-20s | ", substr(col, 1, 20)
        }
        printf "\n"
    }
    ' "$CSV_FILE"
    
    echo ""
    echo "(Showing first 20 rows + header, up to $display_cols columns)"
    if [ $num_cols -gt 10 ]; then
        echo "Total columns in file: $num_cols (use option 2 to see all columns for a specific row)"
    fi
    echo ""
}

# Function to view specific row
view_row() {
    local row_num=$1
    
    display_header
    
    if [ $row_num -lt 1 ] || [ $row_num -gt $(count_rows) ]; then
        echo "[ERROR] Invalid row number!"
        return
    fi
    
    if [ $row_num -eq 1 ]; then
        echo "Row 1 is the HEADER row"
        echo ""
        local header=$(get_columns)
        IFS=',' read -ra COLUMNS <<< "$header"
        for i in "${!COLUMNS[@]}"; do
            echo "[$((i+1))] ${COLUMNS[$i]}"
        done
        echo ""
        return
    fi
    
    echo "Row $row_num Details:"
    echo ""
    
    # Get header
    local header=$(get_columns)
    IFS=',' read -ra COLUMNS <<< "$header"
    
    # Get row data
    local row_data=$(awk -F',' -v line="$row_num" 'NR==line' "$CSV_FILE")
    
    # Parse row data
    local field_num=1
    local in_quotes=0
    local current_field=""
    local fields=()
    
    while IFS= read -r -n1 char; do
        if [ "$char" = '"' ]; then
            if [ $in_quotes -eq 0 ]; then
                in_quotes=1
            else
                in_quotes=0
            fi
            current_field+="$char"
        elif [ "$char" = ',' ] && [ $in_quotes -eq 0 ]; then
            fields+=("$current_field")
            current_field=""
        else
            current_field+="$char"
        fi
    done <<< "$row_data"
    fields+=("$current_field")
    
    # Display fields
    for i in "${!COLUMNS[@]}"; do
        local col_name="${COLUMNS[$i]}"
        local col_value="${fields[$i]}"
        
        # Truncate long values
        if [ ${#col_value} -gt 100 ]; then
            col_value="${col_value:0:100}..."
        fi
        
        echo "[$((i+1))] $col_name:"
        echo "    $col_value"
        echo ""
    done
}

# Function to edit a cell
edit_cell() {
    local row_num=$1
    local col_num=$2
    
    if [ $row_num -lt 1 ] || [ $row_num -gt $(count_rows) ]; then
        echo "[ERROR] Invalid row number!"
        return 1
    fi
    
    if [ $row_num -eq 1 ]; then
        echo "[ERROR] Cannot edit header row!"
        return 1
    fi
    
    # Get header
    local header=$(get_columns)
    IFS=',' read -ra COLUMNS <<< "$header"
    
    if [ $col_num -lt 1 ] || [ $col_num -gt ${#COLUMNS[@]} ]; then
        echo "[ERROR] Invalid column number!"
        return 1
    fi
    
    local col_name="${COLUMNS[$((col_num-1))]}"
    
    # Get current value
    local current_value=$(awk -F',' -v line="$row_num" -v col="$col_num" 'NR==line {print $col}' "$CSV_FILE")
    
    echo "Current value of '$col_name':"
    echo "$current_value"
    echo ""
    echo "Enter new value (or press Enter to cancel):"
    read -e new_value
    
    if [ -z "$new_value" ]; then
        echo "[INFO] Edit cancelled."
        return 1
    fi
    
    # Escape special characters and handle commas in the new value
    if [[ "$new_value" == *","* ]] || [[ "$new_value" == *"\""* ]]; then
        new_value="\"${new_value//\"/\"\"}\""
    fi
    
    # Update the file using awk
    awk -F',' -v OFS=',' -v line="$row_num" -v col="$col_num" -v newval="$new_value" '
    BEGIN {FPAT = "([^,]*)|(\"[^\"]*\")"}
    NR == line {$col = newval}
    {
        for(i=1; i<=NF; i++) {
            if(i>1) printf ","
            printf "%s", $i
        }
        printf "\n"
    }
    ' "$CSV_FILE" > "$TEMP_FILE"
    
    mv "$TEMP_FILE" "$CSV_FILE"
    
    echo "[SUCCESS] Cell updated successfully!"
    return 0
}

# Function to replace entire row with row 2 from new_data.csv
replace_row_with_new_data() {
    local row_num=$1
    
    if [ ! -f "$NEW_DATA_FILE" ]; then
        echo "[ERROR] File $NEW_DATA_FILE not found!"
        return 1
    fi
    
    if [ $row_num -lt 1 ] || [ $row_num -gt $(count_rows) ]; then
        echo "[ERROR] Invalid row number!"
        return 1
    fi
    
    if [ $row_num -eq 1 ]; then
        echo "[ERROR] Cannot replace header row!"
        return 1
    fi
    
    # Get row 2 from new_data.csv
    local new_row_data=$(awk 'NR==2' "$NEW_DATA_FILE")
    
    if [ -z "$new_row_data" ]; then
        echo "[ERROR] Row 2 not found in $NEW_DATA_FILE!"
        return 1
    fi
    
    echo "Row 2 from new_data.csv:"
    echo "$new_row_data" | cut -c1-200
    echo "..."
    echo ""
    echo "This will replace row $row_num in $CSV_FILE"
    echo -n "Are you sure? (y/n): "
    read confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "[INFO] Operation cancelled."
        return 1
    fi
    
    # Replace the row
    awk -v line="$row_num" -v newrow="$new_row_data" '
    NR == line {print newrow; next}
    {print}
    ' "$CSV_FILE" > "$TEMP_FILE"
    
    mv "$TEMP_FILE" "$CSV_FILE"
    
    echo "[SUCCESS] Row $row_num replaced successfully!"
    return 0
}

# Function to search for a row
search_row() {
    echo "Enter search term (searches in all columns):"
    read search_term
    
    if [ -z "$search_term" ]; then
        echo "[ERROR] Search term cannot be empty!"
        return
    fi
    
    display_header
    echo "Search results for: '$search_term'"
    echo ""
    echo "Row# | Product ID | Product Title"
    echo "-------------------------------------------------------------"
    
    awk -F',' -v search="$search_term" '
    NR>1 && (tolower($0) ~ tolower(search)) {
        title = substr($2, 1, 50)
        printf "%4d | %10s | %s\n", NR, $1, title
    }' "$CSV_FILE"
    
    echo ""
}

# Function to show usage/help
show_usage() {
    echo "========================================"
    echo "     CSV EDITOR - USAGE GUIDE"
    echo "========================================"
    echo ""
    echo "INTERACTIVE MODE:"
    echo "  ./run.sh                    # Launch interactive menu"
    echo ""
    echo "DIRECT COMMANDS:"
    echo "  ./run.sh view               # View all rows (summary)"
    echo "  ./run.sh row <num>         # View specific row"
    echo "  ./run.sh search <term>    # Search for rows"
    echo "  ./run.sh build              # Install/Build csvi editor"
    echo "  ./run.sh csvi               # Open csvi editor"
    echo "  ./run.sh edit <row> <col> # Edit a cell (small files)"
    echo "  ./run.sh replace <row>    # Replace entire row (small files)"
    echo "  ./run.sh reload             # Reload configuration"
    echo "  ./run.sh help               # Show this help"
    echo ""
    echo "EXAMPLES:"
    echo "  ./run.sh row 5             # View row 5"
    echo "  ./run.sh search 'collagen' # Search for 'collagen'"
    echo "  ./run.sh edit 10 3         # Edit row 10, column 3"
    echo "  ./run.sh replace 5         # Replace row 5 with data source"
    echo ""
    echo "CONFIGURATION:"
    echo "  Edit config.sh to set CSV_FILE and NEW_DATA_FILE"
    echo ""
}

# Main program loop
main() {
    while true; do
        display_header
        
        # Show current file info
        echo "Current file: $CSV_FILE"
        echo "New data file: $NEW_DATA_FILE"
        echo "Total rows: $(count_rows)"
        echo ""
        
        display_menu
        read -r choice
        
        # Parse CLI commands or numeric choices
        case $choice in
            # Numeric menu options
            1|view)
                view_all_rows
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2|row)
                echo -n "Enter row number to view: "
                read row_num
                view_row $row_num
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3|search)
                search_row
                echo ""
                read -p "Press Enter to continue..."
                ;;
            4|build)
                check_install_csvi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5|csvi)
                launch_csvi
                ;;
            6|edit)
                echo -n "Enter row number: "
                read row_num
                view_row $row_num
                echo ""
                echo -n "Enter column number to edit: "
                read col_num
                edit_cell $row_num $col_num
                echo ""
                read -p "Press Enter to continue..."
                ;;
            7|replace)
                echo -n "Enter row number to replace: "
                read row_num
                replace_row_with_new_data $row_num
                echo ""
                read -p "Press Enter to continue..."
                ;;
            8|reload)
                reload_config
                ;;
            0|exit|quit)
                echo "Thank you for using CSV Editor!"
                exit 0
                ;;
            row\ *)
                row_num=$(echo "$choice" | awk '{print $2}')
                if [[ "$row_num" =~ ^[0-9]+$ ]]; then
                    view_row $row_num
                    echo ""
                    read -p "Press Enter to continue..."
                else
                    echo "[ERROR] Invalid row number!"
                    sleep 2
                fi
                ;;
            edit\ *)
                params=$(echo "$choice" | awk '{print $2, $3}')
                row_num=$(echo "$params" | awk '{print $1}')
                col_num=$(echo "$params" | awk '{print $2}')
                if [[ "$row_num" =~ ^[0-9]+$ ]] && [[ "$col_num" =~ ^[0-9]+$ ]]; then
                    view_row $row_num
                    echo ""
                    edit_cell $row_num $col_num
                    echo ""
                    read -p "Press Enter to continue..."
                else
                    echo "[ERROR] Invalid parameters! Usage: edit <row> <col>"
                    sleep 2
                fi
                ;;
            replace\ *)
                row_num=$(echo "$choice" | awk '{print $2}')
                if [[ "$row_num" =~ ^[0-9]+$ ]]; then
                    replace_row_with_new_data $row_num
                    echo ""
                    read -p "Press Enter to continue..."
                else
                    echo "[ERROR] Invalid row number! Usage: replace <row>"
                    sleep 2
                fi
                ;;
            search\ *)
                search_term=$(echo "$choice" | cut -d' ' -f2-)
                if [ -n "$search_term" ]; then
                    display_header
                    echo "Search results for: '$search_term'"
                    echo ""
                    echo "Row# | Product ID | Product Title"
                    echo "-------------------------------------------------------------"
                    
                    awk -F',' -v search="$search_term" '
                    NR>1 && (tolower($0) ~ tolower(search)) {
                        title = substr($2, 1, 50)
                        printf "%4d | %10s | %s\n", NR, $1, title
                    }' "$CSV_FILE"
                    
                    echo ""
                    read -p "Press Enter to continue..."
                else
                    echo "[ERROR] Invalid search term! Usage: search <term>"
                    sleep 2
                fi
                ;;
            help|h|\?)
                display_header
                echo "Available CLI Commands:"
                echo "  view              - View all rows"
                echo "  row <num>         - View specific row"
                echo "  search <term>    - Search for rows"
                echo "  build             - Build csvi editor"
                echo "  csvi              - Open csvi editor"
                echo "  edit <row> <col> - Edit a cell"
                echo "  replace <row>    - Replace entire row"
                echo "  reload            - Reload configuration"
                echo "  exit or quit     - Exit the program"
                echo ""
                read -p "Press Enter to continue..."
                ;;
            *)
                echo "[ERROR] Invalid choice! Type 'help' for available commands."
                sleep 2
                ;;
        esac
     done
 }

# Main program entry point
main_program() {
    local command="${1:-interactive}"
    shift || true
    
    case "$command" in
        interactive)
            # Interactive mode
            main
            ;;
        view|1)
            view_all_rows
            ;;
        row|2)
            if [ -z "$1" ]; then
                echo "[ERROR] Row number required"
                echo "Usage: ./run.sh row <num>"
                exit 1
            fi
            view_row "$1"
            ;;
        search|3)
            if [ -z "$1" ]; then
                echo "[ERROR] Search term required"
                echo "Usage: ./run.sh search <term>"
                exit 1
            fi
            display_header
            echo "Search results for: '$*'"
            echo ""
            echo "Row# | Product ID | Product Title"
            echo "-------------------------------------------------------------"
            
            awk -F',' -v search="$*" '
            NR>1 && (tolower($0) ~ tolower(search)) {
                title = substr($2, 1, 50)
                printf "%4d | %10s | %s\n", NR, $1, title
            }' "$CSV_FILE"
            ;;
        build|4)
            check_install_csvi
            ;;
        csvi|5)
            launch_csvi
            ;;
        edit|6)
            if [ -z "$1" ] || [ -z "$2" ]; then
                echo "[ERROR] Row and column numbers required"
                echo "Usage: ./run.sh edit <row> <col>"
                exit 1
            fi
            view_row "$1"
            echo ""
            edit_cell "$1" "$2"
            ;;
        replace|7)
            if [ -z "$1" ]; then
                echo "[ERROR] Row number required"
                echo "Usage: ./run.sh replace <row>"
                exit 1
            fi
            replace_row_with_new_data "$1"
            ;;
        reload|8)
            reload_config
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            echo "[ERROR] Unknown command '$command'"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Start the program
load_csv_files

# Check if arguments were provided
if [ $# -eq 0 ]; then
    # No arguments - run interactive mode
    main
else
    # Arguments provided - run direct command
    main_program "$@"
fi
