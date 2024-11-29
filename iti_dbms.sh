#!/bin/bash

# NOTE: this script needs boxes to be installed

##############################################################################################################
############################################# MAYBE NEEDED ##################################################
##############################################################################################################

# delete row
# awk '$1 != 3' file.txt > temp.txt && mv temp.txt file.txt

# cat /etc/passwd | cut -f 1,2,3 -d ":"

## Ternary condition
# echo "$([[ "id name" == *"notnull"* ]] && echo "YES" || echo "NO")"

# var="(1; John; 25)"
# echo "$var" | awk -F'[()]' '{print $2}'

# example for extract a string from {}
# string="This is {example1} and {example2}"
# table columns: $columnsMetadata"$string" | grep -oP '\{.*?\}' 

# TODO: 
# - select from table
#  -- todo: add support for >=, !=, pla pla.
#  -- todo: add regex to check the query input.

# - update row
# - update table
# - delete row
# - insert into table
# - validate columns helper
# - validate rows helper 
# - clean code and do refactors
# - create helper function to read options from the list
# - add support for the default options (y/n)
# - update list databases function
# - update dropDatabases to use menu options
# - check there are a count or not!

##############################################################################################################
############################################# CONSTANTS ######################################################
##############################################################################################################
 
instructions=true
TERM_WIDTH=$(tput cols)
ORIGINAL_IFS="$IFS"
TABLE_REGEX="^[[:alnum:]_]+[[:space:]]+\|[[:space:]]+[[:alnum:]_]+[[:space:]]+[[:alnum:]_]+([[:space:]]+[[:alnum:]_]+)*([[:space:]]*;[[:space:]]+[[:alnum:]_]+[[:space:]]+[[:alnum:]_]+([[:space:]]+[[:alnum:]_]+)*)*$"

###########################################################################################################
############################################# COLORS ######################################################
###########################################################################################################

##
# Color Variables
##

RED='\e[31m' #error
GREEN='\e[32m' #sucess
YELLOW='\e[33m' #instructions
BLUE='\e[34m' #input
MAGENTA='\e[35m' #input
CYAN='\e[36m' #input
CLEAR='\e[0m'

##
# Color Functions
##

ColorRed(){
  echo -ne "$RED$1$CLEAR"
}

ColorGreen(){
  echo -ne "$GREEN$1$CLEAR"
}

ColorYellow(){
  echo -ne "$YELLOW$1$CLEAR"
}

ColorBlue(){
  echo -ne "$BLUE$1$CLEAR"
}

ColorMagenta(){
  echo -ne "$MAGENTA$1$CLEAR"
}

ColorCyan(){
  echo -ne "$CYAN$1$CLEAR"
}

##############################################################################################################
######################################## PrettyTable.sh ######################################################
##############################################################################################################
## This script for github repe: https://github.com/jakobwesthoff/prettytable.sh

## how to use:
# {
#  printf 'PID\tUSER\tAPPNAME\n';
#  printf '%s\t%s\t%s\n' "1" "john" "foo bar";
#  printf '%s\t%s\t%s\n' "12345678" "someone_with_a_long_name" "blub blib blab bam boom";
# } | prettytable 3 ("3 is the number of columns")
            
_prettytable_char_top_left="┌"
_prettytable_char_horizontal="─"
_prettytable_char_vertical="│"
_prettytable_char_bottom_left="└"
_prettytable_char_bottom_right="┘"
_prettytable_char_top_right="┐"
_prettytable_char_vertical_horizontal_left="├"
_prettytable_char_vertical_horizontal_right="┤"
_prettytable_char_vertical_horizontal_top="┬"
_prettytable_char_vertical_horizontal_bottom="┴"
_prettytable_char_vertical_horizontal="┼"

# Default colors
_prettytable_color_blue="0;34"
_prettytable_color_green="0;32"
_prettytable_color_cyan="0;36"
_prettytable_color_red="0;31"
_prettytable_color_purple="0;35"
_prettytable_color_yellow="0;33"
_prettytable_color_gray="1;30"
_prettytable_color_light_blue="1;34"
_prettytable_color_light_green="1;32"
_prettytable_color_light_cyan="1;36"
_prettytable_color_light_red="1;31"
_prettytable_color_light_purple="1;35"
_prettytable_color_light_yellow="1;33"
_prettytable_color_light_gray="0;37"

# Somewhat special colors
_prettytable_color_black="0;30"
_prettytable_color_white="1;37"
_prettytable_color_none="0"

function _prettytable_prettify_lines() {
  cat - | sed -e "s@^@${_prettytable_char_vertical}@;s@\$@	@;s@	@	${_prettytable_char_vertical}@g"
}

function _prettytable_fix_border_lines() {
  cat - | sed -e "1s@ @${_prettytable_char_horizontal}@g;3s@ @${_prettytable_char_horizontal}@g;\$s@ @${_prettytable_char_horizontal}@g"
}

function _prettytable_colorize_lines() {
  local color="$1"
  local range="$2"
  local ansicolor="$(eval "echo \${_prettytable_color_${color}}")"

  cat - | sed -e "${range}s@\\([^${_prettytable_char_vertical}]\\{1,\\}\\)@"$'\E'"[${ansicolor}m\1"$'\E'"[${_prettytable_color_none}m@g"
}

function prettytable() {
  local cols="${1}"
  local color="${2:-none}"
  local input="$(cat -)"
  local header="$(echo -e "${input}"|head -n1)"
  local body="$(echo -e "${input}"|tail -n+2)"
  {
      # Top border
    echo -n "${_prettytable_char_top_left}"
    for i in $(seq 2 ${cols}); do
      echo -ne "\t${_prettytable_char_vertical_horizontal_top}"
    done
    echo -e "\t${_prettytable_char_top_right}"

    echo -e "${header}" | _prettytable_prettify_lines

    # Header/Body delimiter
    echo -n "${_prettytable_char_vertical_horizontal_left}"
    for i in $(seq 2 ${cols}); do
      echo -ne "\t${_prettytable_char_vertical_horizontal}"
    done
    echo -e "\t${_prettytable_char_vertical_horizontal_right}"

    echo -e "${body}" | _prettytable_prettify_lines

    # Bottom border
    echo -n "${_prettytable_char_bottom_left}"
    for i in $(seq 2 ${cols}); do
      echo -ne "\t${_prettytable_char_vertical_horizontal_bottom}"
    done
    echo -e "\t${_prettytable_char_bottom_right}"
  } | column -t -s $'\t' | _prettytable_fix_border_lines | _prettytable_colorize_lines "${color}" "2"
}

##############################################################################################################
############################################# INSTRUCTIONS ###################################################
##############################################################################################################

function displayCreateTableInstuctions() {
  echo -e "$(ColorYellow "===============================================")"
  echo -e "$(ColorYellow "=      Instructions for Table MetaData        =")"
  echo -e "$(ColorYellow "===============================================")"
  echo -e "$(ColorYellow "Use the following pattern to enter table metadata:")"
  echo
  echo -e "$(ColorYellow "tableName | column1 type attributes; column2 type attributes; ...")"
  echo
  echo -e "$(ColorYellow "Details:")"
  echo -e "$(ColorYellow "1. tableName  - The name of your table (e.g., 'students').")"
  echo -e "$(ColorYellow "2. | - Separator between the table name and columns.")"
  echo -e "$(ColorYellow "3. columnN - The name of each column (e.g., 'id', 'name').")"
  echo -e "$(ColorYellow "4. type - Data type of the column (e.g., 'int', 'str', 'number').")"
  echo -e "$(ColorYellow "5. attributes - Additional column attributes (e.g., 'pk', 'autoincrement', 'notnull').")"
  echo
  echo -e "$(ColorYellow "Example:")"
  echo -e "$(ColorYellow "students | id int pk autoincrement; name str notnull; age number")"
  echo
  echo -e "$(ColorYellow "===============================================")"
}

function displaySelectFromTableInstuctions() {
  echo -e "$(ColorYellow "===============================================")"
  echo -e "$(ColorYellow "=     Instructions for Select From Table      =")"
  echo -e "$(ColorYellow "===============================================")"
  echo -e "$(ColorYellow "Use the following pattern to enter a SELECT query:")"
  echo
  echo -e "$(ColorYellow "column1; column2; column3; ... | column1=value; column2=value; ...")"
  echo
  echo -e "$(ColorYellow "Details:")"
  echo -e "$(ColorYellow "1. columnN - Specify the columns you want to retrieve (e.g., 'id', 'name').")"
  echo -e "$(ColorYellow "2. | - Separator between the selected columns and the filter conditions.")"
  echo -e "$(ColorYellow "3. columnN=value - Specify the filter conditions (e.g., 'id=1', 'name=John').")"
  echo -e "$(ColorYellow "   - Use ';' to separate multiple conditions.")"
  echo
  echo -e "$(ColorYellow "Notes:")"
  echo -e "$(ColorYellow "1. You can retrieve all columns by entering '*'.")"
  echo -e "$(ColorYellow "2. Filters are optional; if no filter is needed, omit the right part after '|'.")"
  echo
  echo -e "$(ColorYellow "Example:")"
  echo -e "$(ColorYellow "id; name | id=1; age=25")"
  echo -e "$(ColorYellow "   - Retrieve 'id' and 'name' columns where 'id=1' and 'age=25'.")"
  echo -e "$(ColorYellow "id; name; age | " )"
  echo -e "$(ColorYellow "   - Retrieve 'id', 'name', and 'age' columns with no filters.")"
  echo
  echo -e "$(ColorYellow "===============================================")"
}

function displayInsertIntoTableInstructions() {
  echo -e "$(ColorYellow "===============================================")"
  echo -e "$(ColorYellow "=     Instructions for Insert Into Table      =")"
  echo -e "$(ColorYellow "===============================================")"
  echo -e "$(ColorYellow "Use the following pattern to enter an INSERT query:")"
  echo
  echo -e "$(ColorYellow "id; name; age | (1; John; 25), (2; Jane; 30), (3; Doe; 20)")"
  echo -e "$(ColorYellow "   - This will insert multiple rows into the table.")"
  echo -e "$(ColorYellow "   - The format is: columns | (value1; value2; value3), (value4; value5; value6), ...")"
  echo
  echo -e "$(ColorYellow "Details:")"
  echo -e "$(ColorYellow "1. columnN - Specify the columns you want to insert data into (e.g., 'id', 'name').")"
  echo -e "$(ColorYellow "   - Use '*' to insert values into all columns of the table, in the order defined by the table schema.")"
  echo -e "$(ColorYellow "   - Example: * | (1; John; 25), (2; Jane; 30), (3; Doe; 20)")"
  echo -e "$(ColorYellow "     This inserts into all columns without specifying each one.")"
  echo
  echo -e "$(ColorYellow "2. | - Separator between the column names (or *) and the corresponding values.")"
  echo -e "$(ColorYellow "3. valueN - Specify the values you want to insert into the respective columns.")"
  echo
  echo -e "$(ColorYellow "Notes:")"
  echo -e "$(ColorYellow "1. If a column can be NULL, you can insert 'NULL' as a value instead of leaving it empty.")"
  echo -e "$(ColorYellow "   Example: id; name; age | (1; John; NULL), (2; NULL; 30), (3; Doe; NULL)")"
  echo -e "$(ColorYellow "   In this case, 'name' is NULL for row 2 and 'age' is NULL for row 1 and 3.")"
  echo
  echo -e "$(ColorYellow "2. If you omit a column from the query, it will automatically be set to NULL (if allowed) or the default value defined for that column.")"
  echo -e "$(ColorYellow "   Example: id; age | (1; 25), (2; 30)")"
  echo -e "$(ColorYellow "   In this case, 'name' will be NULL by default for both rows.")"
  echo
  echo -e "$(ColorYellow "3. The columns and their values should be provided in the same order as the table schema, unless '*' is used to insert into all columns.")"
  echo -e "$(ColorYellow "   If '*' is used, the values should match the order of columns in the table.")"
  echo
  echo -e "$(ColorYellow "===============================================")"
}

function displayUpdateInstructions() {
  echo -e "$(ColorYellow "===============================================")"
  echo -e "$(ColorYellow "=        Instructions for Update Rows         =")"
  echo -e "$(ColorYellow "===============================================")"
  echo -e "$(ColorYellow "Use the following pattern to enter an UPDATE query:")"
  echo
  echo -e "$(ColorYellow "column1=value1; column2=value2 | condition")"
  echo
  echo -e "$(ColorYellow "Details:")"
  echo -e "$(ColorYellow "1. Condition - Specify the columns to update and the condition to match rows.")"
  echo -e "$(ColorYellow "   - Use the following pattern for updating columns:")"
  echo -e "$(ColorYellow "     - \"column1=value1; column2=value2\" - To update multiple columns with new values.")"
  echo -e "$(ColorYellow "     - Separate multiple column assignments with ';'.")"
  echo -e "$(ColorYellow "   - Use the following pattern for condition:")"
  echo -e "$(ColorYellow "     - \"id=value\" - A condition to match rows based on the id.")"
  echo -e "$(ColorYellow "   - Separate the column assignments from the condition with a pipe symbol '|'.")"
  echo -e "$(ColorYellow "2. Only valid condition is 'id=value'. No other conditions are allowed.")"
  echo -e "$(ColorYellow "3. The query will only update rows that match the condition.")"
  echo
  echo -e "$(ColorYellow "Examples:")"
  echo -e "$(ColorYellow "1. Update columns id and name where id=2:")"
  echo -e "$(ColorYellow "   id=2; name=John | id=2")"
  echo -e "$(ColorYellow "2. Update columns name and age where id=3:")"
  echo -e "$(ColorYellow "   name=Jane; age=25 | id=3")"
  echo -e "$(ColorYellow "3. Update multiple columns where id=1:")"
  echo -e "$(ColorYellow "   name=Alice; age=30 | id=1")"
  echo
  echo -e "$(ColorYellow "===============================================")"
}


function displayDeleteInstructions() {
  echo -e "$(ColorYellow "===============================================")"
  echo -e "$(ColorYellow "=         Instructions for Delete Rows        =")"
  echo -e "$(ColorYellow "===============================================")"
  echo -e "$(ColorYellow "Use the following pattern to enter a DELETE query:")"
  echo
  echo -e "$(ColorYellow "conditions")"
  echo
  echo -e "$(ColorYellow "Details:")"
  echo -e "$(ColorYellow "1. Conditions - Specify the rows to delete using the id.")"
  echo -e "$(ColorYellow "   - Use the following pattern for the condition:")"
  echo -e "$(ColorYellow "     - \"id=value\" - A single condition to match the id.")"
  echo -e "$(ColorYellow "     - \"*\" - Use '*' as the condition to delete all rows in the table.")"
  echo -e "$(ColorYellow "2. Omit the condition part to delete all rows (equivalent to using '*').")"
  echo
  echo -e "$(ColorYellow "Examples:")"
  echo -e "$(ColorYellow "1. Delete row with a specific id:")"
  echo -e "$(ColorYellow "   id=1")"
  echo -e "$(ColorYellow "2. Delete all rows using '*':")"
  echo -e "$(ColorYellow "   *")"
  echo -e "$(ColorYellow "3. Delete all rows by omitting the condition part:")"
  echo -e "$(ColorYellow "   (no conditions provided)")"
  echo
  echo -e "$(ColorYellow "===============================================")"
}


##############################################################################################################
############################################# HELPERS ########################################################
##############################################################################################################

function handleInput() {
  read -ep "$1: " user_input

  while [[ -z "$user_input" ]]; do
    echo -e $(ColorRed "$2: ") >&2
    read -ep "$1: " user_input
  done

  echo "$user_input"
}

# This method with the help of boxes, it install this do 'apt install boxes'
function welcome() {
  ASCII_ART=$(figlet "ITI DBMS")

  ADDITIONAL_TEXT=$(cat <<EOT
    $(ColorYellow "To learn more about how to use ITI DBMS")
    $(ColorYellow "go to https://github.com/polybar/polybar")

    $(ColorYellow "The README contains a lot of information.")
    $(ColorYellow "Authors: Nada Maher, Yoser Yasser")
EOT
  )

  FULL_CONTENT="$ASCII_ART\n$ADDITIONAL_TEXT"
  BOX=$(echo -e "$FULL_CONTENT" | boxes -d shell -p a2 -a c -s ${TERM_WIDTH}x)
  COLORED_BOX=$(echo -e "$BOX" | while IFS= read -r line; do ColorBlue "$line"; done)

  echo -e "$COLORED_BOX"
  echo -e "Welcome to ITI DBMS:"
}

function getFiles() {
  files=()

  for file in *; do
    if [[ -f $file ]]; then
      files+=("$file")
    fi
  done

  echo ${files[@]}
}

function getDirs() {
  dirs=()

  for dir in *; do
    if [[ -d $dir ]]; then
      dirs+=("$dir")
    fi
  done

  echo ${dirs[@]}
}



function checkTableExpression() {
  if [[ $1 =~ $TABLE_REGEX ]]; then
    return 0
  else
    return 1 
  fi
}

# TODO later
function validateColumns() {
  return 0
}

function handleTableInput() {
  local table=$(handleInput "enter table metadata" "metadata can't be empty...")

  while true; do

    if ! checkTableExpression "$table"; then
      echo -e $(ColorRed "Invalid table metdata") >&2
      echo -e $(ColorRed "use this pattern: tableName | column1 type attributes; column2 type attributes; ...") >&2
      table=$(handleInput "enter table metadata" "metadata can't be empty...")
      continue
    fi

    IFS='|' read -ra parts <<< "$table"
    tableName=$(echo "${parts[0]}" | xargs)
    columns=$(echo "${parts[1]}" | xargs)

    if ! validateColumns "$columns"; then
      echo -e $(ColorRed "Please fix the column errors and try again.") >&2
      table=$(handleInput "enter table metadata" "metadata can't be empty...")
      continue
    fi

    break

  done

  echo $table
}

function createColumns() {
  IFS=';' read -ra columns <<< "$@"
  columnsMetadata=""

  # echo "Columns:" >&2
  for column in "${columns[@]}"; do
    trimmed_column=$(echo "$column" | xargs) # Trim spaces
    columnsMetadata+=":$trimmed_column"
    # echo "- $trimmed_column" >&2
  done

  # echo "---- $columnsMetadata" >&2
  echo ${columnsMetadata:1}
}

function displayTableMetadata() {
  tableName="$1"
  columnsMetadata="$2"

  IFS=':' read -ra column <<< "$columnsMetadata"

  echo $tableName
  {
    printf 'FIELD\tTYPE\tNULL\tKEY\tExtra\n';

    for index in "${!column[@]}"; do
      IFS=' ' read -ra token <<< "${column[$index]}"
      if [[ index -eq 0 ]]; then
        printf '%s\t%s\t%s\t%s\t%s\n' "${token[0]}" "${token[1]}" "NO" "${token[2]}" "${token[3]}";
      else
        printf '%s\t%s\t%s\t%s\t%s\n' "${token[0]}" "${token[1]}" "$([[ $token[2] == *"notnull"* ]] && echo "NO" || echo "YES")";
      fi
    done

  } | prettytable 5
}

function displayTableData() {
  tableData="$1" 
  IFS=$'\n' read -r -d '' -a rows <<< "$tableData"

  headers="${rows[0]}"
  unset rows[0]

  IFS=':' read -ra columnsMetadata <<< "$headers"
  columns=()

  for metadata in "${columnsMetadata[@]}"; do
    columnName=$(echo "$metadata" | cut -d " " -f 1) 
    columns+=("$columnName")
  done

  {
    for index in "${!columns[@]}"; do
      if [[ $index -eq 0 ]]; then
        printf '%s' "${columns[$index]}"
      else
        printf '\t%s' "${columns[$index]}"
      fi
    done
    printf '\n'

    for row in "${rows[@]}"; do
      IFS=':' read -ra rowColumns <<< "$row"
      for colIndex in "${!rowColumns[@]}"; do
        if [[ $colIndex -eq 0 ]]; then
          printf '%s' "${rowColumns[$colIndex]}"
        else
          printf '\t%s' "${rowColumns[$colIndex]}"
        fi
      done
      printf '\n'
    done
  } | prettytable ${#columns[@]}
}

function displayDataAsOptions() {
  data="$1"
  errorMessage="$2"
  IFS=' ' read -ra data <<< "$data"

  if [[ ${#data[@]} -eq 0 ]]; then
    echo -e "$(ColorMagenta "$errorMessage")" >&2
    echo "------------------------------------" >&2
    return 0
  fi

  for index in "${!data[@]}"; do
    echo -e "$(ColorGreen "$((index + 1)))") ${data[$index]}" >&2
  done

  echo -e "$(ColorGreen "0)") back" >&2
  read -p "$(ColorBlue 'Choose an option: ') " opt

  while ! [[ $opt =~ ^[0-9]+$ ]] || ! [[ $opt -ge 0 && $opt -le ${#data[@]} ]]; do
    echo -e "$(ColorRed 'Invalid option. Please choose a valid number.')" >&2
    read -p "$(ColorBlue 'Choose an option: ') " opt
  done

  echo "$opt"
}

function getColIndex() {
  cols="$1"
  neededCol="$2"
  IFS=' ' read -ra cols <<< "$cols"

  for index in "${!cols[@]}"; do
    if [[ "${cols[$index]}" == "$neededCol" ]]; then
      echo "$(($index + 1))"
      break
    fi
  done
}

function buildAwkCondition() {
  colNames="$1"
  condition="$2"

  tokens=$(echo "$condition" | awk -F ' ' '{gsub(/[()]/, " & "); gsub(/  +/, " "); print}' | xargs)
  IFS=' ' read -ra tokens <<< "$tokens"

  index=$(getColIndex "${colNames[*]}" "age")

  awkCommand=""

  for token in "${tokens[@]}"; do
    case $token in  
      "(") awkCommand+=" ( " ;;
      ")") awkCommand+=" ) " ;;
      "OR") awkCommand+=" || " ;;
      "AND") awkCommand+=" && " ;;
      *)
        # echo "token: ${token}" >&2
        token=$(echo "$token" | awk '{gsub(/[=!<>]+/, " & "); print}')
        IFS=' ' read -ra token <<< "$token"

        awkCommand+=" $"
        awkCommand+="$(getColIndex "${colNames[*]}" "${token[0]}") "

        case ${token[1]} in  
          '=') awkCommand+=" == " ;; 
          *) awkCommand+=" ${token[1]} " ;;
        esac

        awkCommand+="${token[2]} "
        ;;
    esac

  done

  awkCommand=$(echo "$awkCommand" | awk '{gsub(/  +/, " "); print}' | xargs)

  echo "command: $awkCommand" >&2

  echo "$awkCommand"
}

function getColumnNames() {
  headers="$1"
  IFS=':' read -ra headers <<< "$headers"

  colNames=()

  for header in "${headers[@]}"; do
    colNames+=("$(echo "$header" | cut -d ' ' -f 1)")
  done

  echo "${colNames[@]}"
}


##############################################################################################################
############################################# Main Menu ######################################################
##############################################################################################################

function mainMenu() {
  echo -e "$(ColorGreen '1)') Connect To Databases"  
  echo -e "$(ColorGreen '2)') List Databases"  
  echo -e "$(ColorGreen '3)') Create Database"  
  echo -e "$(ColorGreen '4)') Drop Database"  
  echo -e "$(ColorGreen '0)') Exit"  
  read -p "$(ColorBlue 'Choose an option:') " opt
  
  case $opt in
    1) connectToDatabase ; mainMenu ;;
    2) listDatabases ; mainMenu ;;
    3) createDatabase ; mainMenu ;;
    4) dropDatabase ; mainMenu ;;
    0) echo "Good Bye!"; exit 0 ;;
    *) echo -e $(ColorRed "Wrong option"); mainMenu ;;
  esac


}

function createDatabase() {
  dbname=$(handleInput "enter the new database name" "please enter a vaild database name...")
  while [[ -d "$dbname" ]]; do
    echo -e $(ColorRed "database [${dbname}] already exists...") >&2
    dbname=$(handleInput "enter the new database name" "please enter a vaild database name...")
  done

  mkdir "$dbname"
  echo -e $(ColorGreen "database [${dbname}] created successfully...") >&2
  echo "------------------------------------"
  echo
}

# TODO: update this method to use getDirs
function listDatabases() {
  local list=(*/)
  {
    printf 'Datbase\n';
    for database in ${list[@]}
    do
      printf '%s\n' "${database%/}";
    done
  } | prettytable 1

  echo -e "$(ColorYellow "${#list[@]} rows in set")"
  echo "------------------------------------"
  echo 
}

function dropDatabase() {
  databases=($(getDirs))
  opt=$(displayDataAsOptions "${databases[*]}" "There are no databases for now... create a database and come back :(")

  if [[ $opt -eq 0 ]]; then
    return 0
  fi

  rm -rf "${databases[$((opt - 1))]}" 
  echo -e $(ColorGreen "database [${databases[$((opt - 1))]}] deleted successfully...") >&2
  echo "------------------------------------"
  echo
}

function connectToDatabase() {
  databases=($(getDirs))
  opt=$(displayDataAsOptions "${databases[*]}" "There are no databases for now... create a database and come back :(")

  if [[ $opt -eq 0 ]]; then
    return 0
  fi

  cd "${databases[$((opt - 1))]}" 
  databaseMenu "${databases[$(($opt - 1))]}"

}

##############################################################################################################
############################################# Secondary Menu #################################################
##############################################################################################################

function databaseMenu() {
  echo -e "$(ColorYellow "===============================================")"
  echo -e "$(ColorYellow "                  $1 Database                  ")"
  echo -e "$(ColorYellow "===============================================")" 

  echo -e "$(ColorGreen '1)') List Tables"  
  echo -e "$(ColorGreen '2)') Create Table"  
  echo -e "$(ColorGreen '3)') Update Table"  
  echo -e "$(ColorGreen '4)') Drop Tables"  
  echo -e "$(ColorGreen '5)') Select From Table"  
  echo -e "$(ColorGreen '6)') Insert Into Table"  
  echo -e "$(ColorGreen '7)') Update Row Inside Table"  
  echo -e "$(ColorGreen '8)') Delete Row From Table"  
  echo -e "$(ColorGreen '0)') Back"  
  read -p "$(ColorBlue 'Choose an option:') " a
  
  case $a in
    1) listTables "$1"; databaseMenu "$1";;
    2) createTable ; databaseMenu "$1";;
    3) updateTable ; databaseMenu "$1";;
    4) dropTable ; databaseMenu "$1";;
    5) selectFromTable ; databaseMenu "$1";;
    6) insertIntoTable ; databaseMenu "$1";;
    7) updateRow ; databaseMenu "$1";;
    8) deleteRow ; databaseMenu "$1";;
    0) cd ..; echo "-----------------------------------------------"; return 0 ;;
    *) echo -e $(ColorRed "Wrong option"); databaseMenu "$1";;
  esac
}

# name=Alice; age=30 | id=1
# TODO: complete this function
function updateRow() {
  tables=($(getFiles))
  opt=$(displayDataAsOptions "${tables[*]}" "There are no tables for now... create a table and come back :(")

  if [[ $opt -eq 0 ]]; then
    return 0
  fi

  table=${tables[$((opt - 1))]}
  columnsMetadata=$(head -n 1 "$table")

  [[ "$instructions" == true ]] && displayUpdateInstructions
  displayTableMetadata "$table" "$columnsMetadata"

  query=$(handleInput "Enter your query" "Query can't be empty")

  IFS='|' read -ra queryParts <<< "$query"
  enteredCols=$(echo "${queryParts[0]}" | xargs) 
  IFS=';' read -ra enteredCols <<< "$enteredCols"

  filter=$(echo "${queryParts[1]}" | xargs)

  colNames=($(getColumnNames "$columnsMetadata"))
  command=$(buildAwkCondition "${colNames[*]}" "$filter")
 
  rows=$(tail -n +2 "$table" | awk -F ':' "$command {print \$0}")

  while IFS= read -r row; do
    IFS=":" read -ra rowFields <<< "$row"
    line=""
    
    for indexCol in "${!colNames[@]}"; do
        updated=0
        for enteredCol in "${enteredCols[@]}"; do
            IFS='=' read -ra colValue <<< "$(echo "$enteredCol" | xargs)"
            if [[ "${colValue[0]}" == "${colNames[$indexCol]}" ]]; then
                line+=":${colValue[1]}"
                updated=1
                break
            fi
        done

        if [[ "$updated" -eq 0 ]]; then
            line+=":${rowFields[$indexCol]}"
        fi
    done

    line="${line#:}" # Remove leading colon
    awk -v id="${rowFields[0]}" -v newValue="$line" -F ':' 'BEGIN {OFS=":"} $1 == id {$0 = newValue} {print $0}' "$table" > temp.txt && mv temp.txt "$table"
  done <<< "$rows"

  echo -e "$(ColorGreen "row update succfully...")"
  echo '------------------------------------'
  return 0
}

# TODO: complete this function
function updateTable() {
  echo -e "$(ColorMagenta "comming soon :()")"
  echo '------------------------------------'
  return 0
}

# TODO: complete this function
function selectFromTable() {
  tables=($(getFiles))
  opt=$(displayDataAsOptions "${tables[*]}" "There are no tables for now... create a table and come back :(")

  if [[ $opt -eq 0 ]]; then
    return 0
  fi

  table=${tables[$((opt - 1))]}
  columnsMetadata=$(head -n 1 "$table")

  [[ "$instructions" == true ]] && displaySelectFromTableInstuctions
  displayTableMetadata "$table" "$columnsMetadata"

  query=$(handleInput "Enter your query" "Query can't be empty")

  IFS='|' read -ra queryParts <<< "$query"
  enteredCols=$(echo "${queryParts[0]}" | xargs) # Trim spaces
  IFS=';' read -ra cols <<< "$enteredCols"
  enteredFilters=$(echo "${queryParts[1]}" | xargs)
  IFS=';' read -ra filters <<< "$enteredFilters"

  declare -A colIndexMap
  IFS=':' read -ra colsMetadata <<< "$columnsMetadata"
  for i in "${!colsMetadata[@]}"; do
    colName=$(echo "${colsMetadata[$i]}" | cut -d ' ' -f 1)
    colIndexMap[$colName]=$((i + 1))
  done

  # Handle '*' for selecting all columns
  if [[ "${cols[0]}" == "*" ]]; then
    selectedIndexes=($(seq 1 ${#colsMetadata[@]}))
  else
    # Prepare column indexes and validate query
    selectedIndexes=()
    for col in "${cols[@]}"; do
      col=$(echo "$col" | xargs)
      if [[ -n "${colIndexMap[$col]}" ]]; then
        selectedIndexes+=("${colIndexMap[$col]}")
      else
        echo "$(ColorRed "Error: Column '$col' not found in table metadata.")"
        exit 1
      fi
    done
  fi

  # Build filter conditions for `awk` with case-insensitive support
  filterConditions=""
  for filter in "${filters[@]}"; do
    key=$(echo "$filter" | cut -d '=' -f 1 | xargs)
    value=$(echo "$filter" | cut -d '=' -f 2 | xargs | sed 's/^"//;s/"$//') # Remove quotes
    if [[ -n "${colIndexMap[$key]}" ]]; then
      colIndex="${colIndexMap[$key]}"
      # Append case-insensitive condition to the filter
      filterConditions+="tolower(\$$colIndex)==tolower(\"$value\") && "
    else
      echo "$(ColorRed "Error: Column '$key' not found in table metadata.")"
      exit 1
    fi
  done

  # Remove trailing `&&` from filter conditions
  filterConditions=${filterConditions%&& }

  # Generate `awk` command for reordering columns with filtering
  awkCommand="awk 'BEGIN {FS=\":\"; OFS=\":\"} "

  if [[ -n "$filterConditions" ]]; then
    awkCommand+="{ if ($filterConditions) print "
  else
    awkCommand+="{ print "
  fi

  for index in "${selectedIndexes[@]}"; do
    awkCommand+="\$${index},"
  done

  awkCommand="${awkCommand%,} }' $table"

  # Execute `awk` and capture the result
  # eval "$awkCommand"
  tableData=$(eval "$awkCommand")

  # Ensure `awk` execution is successful
  if [[ -z "$tableData" ]]; then
    echo "$(ColorYellow "No data returned from the query.")"
    echo "------------------------------------"

    return 0
  fi

  # Display the result as a formatted table
  displayTableData "$tableData" 
  lineCount=$(($(echo "$tableData" | wc -l) - 1))
  echo -e "$(ColorYellow "$lineCount rows in set.")"
  echo "------------------------------------"
  return 0

}

# TODO: complete this function
function deleteRow() {
  tables=($(getFiles))
  opt=$(displayDataAsOptions "${tables[*]}" "There are no tables for now... create a table and come back :(")

  # Process the chosen option
  if [[ $opt -eq 0 ]]; then
    return 0
  fi

  table=${tables[$((opt - 1))]}
  columnsMetadata=$(head -n 1 "$table")

  # Display instructions and metadata
  [[ "$instructions" == true ]] && displayDeleteInstructions 
  displayTableMetadata "$table" "$columnsMetadata"

  # Get user query
  query=$(handleInput "Enter row id" "Query can't be empty")

  # TODO: check if the id exists of not...

  # NOTE: this command is very tricky
  awk -v id="$query" -F ':' '$1 != id' "$table" > temp.txt && mv temp.txt "$table"

  echo -e $(ColorGreen "row deleted successfuly..")
  echo '------------------------------------'
  return 0
}

function createTable() {
  [[ "$instructions" == true ]] && displayCreateTableInstuctions
  table=$(handleTableInput)

  IFS='|' read -ra parts <<< "$table"
  tableName=$(echo "${parts[0]}" | xargs)
  columns=$(echo "${parts[1]}" | xargs)


  while [[ -e "${tableName}" ]]; do
    echo -e $(ColorRed "table [${tableName}] already exists...") >&2
    table=$(handleTableInput)
    IFS='|' read -ra parts <<< "$table"
    tableName=$(echo "${parts[0]}" | xargs)
    columns=$(echo "${parts[1]}" | xargs)
  done


  columnsMetadata=$(createColumns ${columns})
  displayTableMetadata "$tableName" "${columnsMetadata}"

  touch $tableName
  echo "${columnsMetadata}" >> $tableName
  echo -e $(ColorGreen "table [${tableName}] created successfully...") >&2
  echo "------------------------------------"
}

function listTables() {
  tables=($(getFiles))

  if [[ ${#tables[@]} -eq 0 ]]; then
    echo -e "$(ColorMagenta "There are no tables for now... create a table and come back :(")"
    echo '------------------------------------'
    return 0
  fi

  {
    printf "Tables_in_${1}\n";
    for table in ${tables[@]}; do
      printf '%s\n' "${table}";
    done
  } | prettytable 1

  echo "${#tables[@]} rows in the set."
  echo '------------------------------------'
}

# TODO: complete this function
function insertIntoTable() {
  tables=($(getFiles))
  opt=$(displayDataAsOptions "${tables[*]}" "There are no tables for now... create a table and come back :(")

  # Process the chosen option
  if [[ $opt -eq 0 ]]; then
    return 0
  fi

  table=${tables[$((opt - 1))]}
  columnsMetadata=$(head -n 1 "$table")

  # Display instructions and metadata
  [[ "$instructions" == true ]] && displayInsertIntoTableInstructions 
  displayTableMetadata "$table" "$columnsMetadata"

  # Get user query
  query=$(handleInput "Enter your query" "Query can't be empty")
  echo "Query: $query"

  IFS="|" read -ra parts <<< "$query"
  colsPart=$(echo "${parts[0]}" | xargs)
  valuesPart=$(echo "${parts[1]}" | xargs)

  if [[ "${colsPart}" == "*" ]]; then

    IFS="," read -ra rows <<< "${valuesPart}"

    # TODO: Validate Row
    for row in "${rows[@]}"; do
      actualRow=$(echo "$row" | xargs | awk -F '[()]' '{print $2}')
      IFS=";" read -ra values <<< "${actualRow}"

      line=""
      for value in "${values[@]}"; do
        line+=":$(echo "$value" | xargs)"
      done

      echo "${line#:}" >> $table
    done

    echo -e $(ColorGreen "data inserted successfuly..")
    echo '-------------------------'
    return 0;
  else

    # TODO: handle the impossible logic
    # 1. extract headers:
    # example: id int pk autoincrement:name str notnull:age number
    IFS=':' read -ra metadataParts <<< "$columnsMetadata"

    columnNames=()
    for metadataPart in ${!metadataParts[@]}; do
      columnNames+=("$(echo "${metadataParts[$metadataPart]}" | cut -d ' ' -f 1)")
    done

    # echo "col Names: ${columnNames[*]}"

    # 2. extract columns and rows from the insert query...
    # echo "colsPart: ${colsPart[*]}"
    # echo "valuesPart: ${valuesPart[*]}"

    IFS=";" read -ra insertedCols <<< "$colsPart"
    # echo "insertedCols: ${insertedCols[*]}"
    IFS="," read -ra insertedData <<< "$valuesPart"
    # echo "insertedData: ${insertedData[*]}"



    # 3. loop over rows
    for rowIndex in ${!insertedData[@]}; do

      IFS=";" read -ra rowValues <<< "$(echo "${insertedData[$rowIndex]}" | awk -F'[()]' '{print $2}')"
      line=""

      for col in "${columnNames[@]}"; do 
        found=0
        # 4. loop over inserted cols by index
        for insertedColIndex in "${!insertedCols[@]}"; do 
          if [[ "$(echo "$col" | xargs)" == "$(echo "${insertedCols[$insertedColIndex]}" | xargs)" ]]; then
            # echo "col: $col match ${insertedCols[$insertedColIndex]}, with index=$insertedColIndex"
            # echo "inserted value: $(echo "${rowValues[$insertedColIndex]}" | xargs)"
            line+=":$(echo "${rowValues[$insertedColIndex]}" | xargs)"
            found=1
            break
          fi
        done

        if [[ $found -eq 0 ]]; then
          line+=":NULL"
        fi

      done
      echo "${line#:}" >> $table
    done

    echo -e $(ColorGreen "data inserted successfuly..")
    echo '-------------------------'
    return 0;
  fi

}

function dropTable() {
  tables=($(getFiles))
  opt=$(displayDataAsOptions "${tables[*]}" "There are no tables for now... create a table and come back :(")

  if [[ $opt -eq 0 ]]; then
    return 0
  else
    rm "${tables[$((opt - 1))]}" 
    echo -e $(ColorGreen "table [${tables[$((opt - 1))]}] deleted successfully...") >&2
    echo "------------------------------------"
    return 0
  fi
}

#############################################################################################################
############################################# SCRIPT ########################################################
#############################################################################################################

for arg in "$@"; do
  case $arg in
    --instructions=*)
      instructions="${arg#*=}"
      ;;
    *)
      echo "Unknown argument: $arg"
      ;;
  esac
done

welcome
mainMenu