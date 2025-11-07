#!/bin/bash

# CSV Editor Script
# Interactive tool to modify cells in a selected CSV file

CSV_FILE=""
NEW_DATA_FILE=""
TEMP_FILE="/tmp/csv_temp_$$"

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to select a CSV file
select_csv_file() {
    display_header
    echo -e "${YELLOW}Please select a CSV file to edit:${NC}"
    
    # Find all CSV files in the current directory
    local csv_files=($(find . -maxdepth 1 -name "*.csv"))
    
    if [ ${#csv_files[@]} -eq 0 ]; then
        echo -e "${RED}No CSV files found in the current directory!${NC}"
        echo "Please add some CSV files to this directory and try again."
        exit 1
    fi
    
    # Display a numbered list of CSV files
    for i in "${!csv_files[@]}"; do
        echo "$((i+1)). ${csv_files[$i]}"
    done
    
    echo ""
    echo -n "Enter the number of the file you want to edit: "
    read file_choice
    
    # Validate user input
    if ! [[ "$file_choice" =~ ^[0-9]+$ ]] || [ "$file_choice" -lt 1 ] || [ "$file_choice" -gt ${#csv_files[@]} ]; then
        echo -e "${RED}Invalid selection! Please try again.${NC}"
        sleep 2
        select_csv_file
    else
        CSV_FILE="${csv_files[$((file_choice-1))]}"
        echo -e "${GREEN}You have selected: $CSV_FILE${NC}"
        sleep 1
    fi
}

# Function to select a new data file
select_new_data_file() {
    display_header
    echo -e "${YELLOW}Please select a CSV file to use as the new data source:${NC}"
    
    # Find all CSV files in the current directory
    local csv_files=($(find . -maxdepth 1 -name "*.csv"))
    
    if [ ${#csv_files[@]} -eq 0 ]; then
        echo -e "${RED}No CSV files found in the current directory!${NC}"
        return
    fi
    
    # Display a numbered list of CSV files
    for i in "${!csv_files[@]}"; do
        echo "$((i+1)). ${csv_files[$i]}"
    done
    
    echo ""
    echo -n "Enter the number of the file: "
    read file_choice
    
    # Validate user input
    if ! [[ "$file_choice" =~ ^[0-9]+$ ]] || [ "$file_choice" -lt 1 ] || [ "$file_choice" -gt ${#csv_files[@]} ]; then
        echo -e "${RED}Invalid selection! Please try again.${NC}"
        sleep 2
        select_new_data_file
    else
        NEW_DATA_FILE="${csv_files[$((file_choice-1))]}"
        echo -e "${GREEN}You have selected: $NEW_DATA_FILE${NC}"
        sleep 1
    fi
}



# Function to display header
display_header() {
    clear
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}     CSV EDITOR - INTERACTIVE MODE     ${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}NOTE 1: This script modifies the file directly. Please create a backup of your CSV file before using this editor.${NC}"
    echo -e "${YELLOW}NOTE 2: The script may not handle cells containing special characters (commas, quotes, pipes) correctly.${NC}"
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
    echo -e "${GREEN}Main Menu:${NC}"
    echo "1. View all rows (summary)"
    echo "2. View specific row details"
    echo "3. Edit a cell"
    echo "4. Replace entire row with data from new_data.csv (row 2)"
    echo "5. Search for a row"
    echo "6. Change CSV File"
    echo "7. Select New Data File"
    echo "0. Exit"
    echo ""
    echo -n "Enter your choice [0-7]: "
}

# Function to view all rows in summary
view_all_rows() {
    display_header
    echo -e "${YELLOW}Total Rows (including header):${NC} $(count_rows)"
    echo ""
    echo -e "${BLUE}Row# | Product ID | Product Title (first 50 chars)${NC}"
    echo "-------------------------------------------------------------"
    
    awk -F',' 'NR==1 {
        printf "%4d | %10s | %s\n", NR, "HEADER", "product_id,post_title,slug..."
        next
    }
    NR>1 {
        title = substr($2, 1, 50)
        printf "%4d | %10s | %s\n", NR, $1, title
    }' "$CSV_FILE" | head -21
    
    echo ""
    echo -e "${YELLOW}(Showing first 20 rows + header)${NC}"
    echo ""
}

# Function to view specific row
view_row() {
    local row_num=$1
    
    display_header
    
    if [ $row_num -lt 1 ] || [ $row_num -gt $(count_rows) ]; then
        echo -e "${RED}Error: Invalid row number!${NC}"
        return
    fi
    
    if [ $row_num -eq 1 ]; then
        echo -e "${GREEN}Row 1 is the HEADER row${NC}"
        echo ""
        local header=$(get_columns)
        IFS=',' read -ra COLUMNS <<< "$header"
        for i in "${!COLUMNS[@]}"; do
            echo -e "${CYAN}[$((i+1))] ${COLUMNS[$i]}${NC}"
        done
        echo ""
        return
    fi
    
    echo -e "${GREEN}Row $row_num Details:${NC}"
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
        
        echo -e "${CYAN}[$((i+1))] $col_name:${NC}"
        echo "    $col_value"
        echo ""
    done
}

# Function to edit a cell
edit_cell() {
    local row_num=$1
    local col_num=$2
    
    if [ $row_num -lt 1 ] || [ $row_num -gt $(count_rows) ]; then
        echo -e "${RED}Error: Invalid row number!${NC}"
        return 1
    fi
    
    if [ $row_num -eq 1 ]; then
        echo -e "${RED}Error: Cannot edit header row!${NC}"
        return 1
    fi
    
    # Get header
    local header=$(get_columns)
    IFS=',' read -ra COLUMNS <<< "$header"
    
    if [ $col_num -lt 1 ] || [ $col_num -gt ${#COLUMNS[@]} ]; then
        echo -e "${RED}Error: Invalid column number!${NC}"
        return 1
    fi
    
    local col_name="${COLUMNS[$((col_num-1))]}"
    
    # Get current value
    local current_value=$(awk -F',' -v line="$row_num" -v col="$col_num" 'NR==line {print $col}' "$CSV_FILE")
    
    echo -e "${YELLOW}Current value of '$col_name':${NC}"
    echo "$current_value"
    echo ""
    echo -e "${GREEN}Enter new value (or press Enter to cancel):${NC}"
    read -e new_value
    
    if [ -z "$new_value" ]; then
        echo -e "${YELLOW}Edit cancelled.${NC}"
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
    
    echo -e "${GREEN}Cell updated successfully!${NC}"
    return 0
}

# Function to replace entire row with row 2 from new_data.csv
replace_row_with_new_data() {
    local row_num=$1
    
    if [ ! -f "$NEW_DATA_FILE" ]; then
        echo -e "${RED}Error: File $NEW_DATA_FILE not found!${NC}"
        return 1
    fi
    
    if [ $row_num -lt 1 ] || [ $row_num -gt $(count_rows) ]; then
        echo -e "${RED}Error: Invalid row number!${NC}"
        return 1
    fi
    
    if [ $row_num -eq 1 ]; then
        echo -e "${RED}Error: Cannot replace header row!${NC}"
        return 1
    fi
    
    # Get row 2 from new_data.csv
    local new_row_data=$(awk 'NR==2' "$NEW_DATA_FILE")
    
    if [ -z "$new_row_data" ]; then
        echo -e "${RED}Error: Row 2 not found in $NEW_DATA_FILE!${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Row 2 from new_data.csv:${NC}"
    echo "$new_row_data" | cut -c1-200
    echo "..."
    echo ""
    echo -e "${RED}This will replace row $row_num in $CSV_FILE${NC}"
    echo -n "Are you sure? (y/n): "
    read confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo -e "${YELLOW}Operation cancelled.${NC}"
        return 1
    fi
    
    # Replace the row
    awk -v line="$row_num" -v newrow="$new_row_data" '
    NR == line {print newrow; next}
    {print}
    ' "$CSV_FILE" > "$TEMP_FILE"
    
    mv "$TEMP_FILE" "$CSV_FILE"
    
    echo -e "${GREEN}Row $row_num replaced successfully!${NC}"
    return 0
}

# Function to search for a row
search_row() {
    echo -e "${YELLOW}Enter search term (searches in product_id and post_title):${NC}"
    read search_term
    
    if [ -z "$search_term" ]; then
        echo -e "${RED}Search term cannot be empty!${NC}"
        return
    fi
    
    display_header
    echo -e "${GREEN}Search results for: '$search_term'${NC}"
    echo ""
    echo -e "${BLUE}Row# | Product ID | Product Title${NC}"
    echo "-------------------------------------------------------------"
    
    awk -F',' -v search="$search_term" '
    NR>1 && (tolower($1) ~ tolower(search) || tolower($2) ~ tolower(search)) {
        title = substr($2, 1, 50)
        printf "%4d | %10s | %s\n", NR, $1, title
    }' "$CSV_FILE"
    
    echo ""
}

# Main program loop
main() {
    while true; do
        display_header
        
        # Show current file info
        echo -e "${MAGENTA}Current file:${NC} $CSV_FILE"
        echo -e "${MAGENTA}New data file:${NC} $NEW_DATA_FILE"
        echo -e "${MAGENTA}Total rows:${NC} $(count_rows)"
        echo ""
        
        display_menu
        read choice
        
        case $choice in
            1)
                view_all_rows
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2)
                echo -n "Enter row number to view: "
                read row_num
                view_row $row_num
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
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
            4)
                echo -n "Enter row number to replace: "
                read row_num
                replace_row_with_new_data $row_num
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5)
                search_row
                echo ""
                read -p "Press Enter to continue..."
                ;;
            6)
                select_csv_file
                ;;
            7)
                select_new_data_file
                ;;
            0)
                echo -e "${GREEN}Thank you for using CSV Editor!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice! Please try again.${NC}"
                sleep 2
                ;;
        esac
     done
 }
 
 # Start the program
 select_csv_file
 select_new_data_file
 main
