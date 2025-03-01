#!/bin/bash

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.

echo #
echo -e "\033[38;5;214m█▄▀ █ █ ▀█▀ ▄▀▄ ▀  | Made by Kusanagi8200 - 2025\033[0m"
echo -e "\033[38;5;214m█ █ ▀▄█ █▄▄ █▀█ █  | https://github.com/Kusanagi8200\033[0m"
echo -e "\033[43;30m Bash Script Collection for Ollama Model Management \033[0m"

if [ `whoami` != "root" ]; then
    echo -e "\033[5;41;30mATTENTION. YOU MUST HAVE SUDO RIGHTS TO RUN THIS SCRIPT\033[0m"
    exit 1
fi

echo #

##
# Color Variables
##

green='\033[43;30m'
red='\033[41;30m'
clear='\e[0m'

##
# Color Functions
##

ColorGreen() {
    echo -ne $green$1$clear
}
ColorRed() {
    echo -ne $red$1$clear
}

# Function to check if the directory exists
check_directory() {
    if [ ! -d "./Kusanagi-Section" ]; then
        echo "Error: The 'Kusanagi-Section' directory does not exist."
        exit 1
    fi
}

# Function to list existing models in Ollama
list_existing_models() {
    echo "Existing models in Ollama:"
    ollama list
}

# Function to delete an existing model
delete_model() {
    echo "Existing models in Ollama:"
    ollama list
    read -p "Enter the name of the model to delete: " model_to_delete
    if [ -z "$model_to_delete" ]; then
        echo "Error: No model name specified."
        return
    fi
    echo "Deleting the model '$model_to_delete'..."
    ollama delete "$model_to_delete"
    echo "Model deleted. Current list:"
    ollama list
}

# Function to run an existing model
run_existing_model() {
    echo "Existing models in Ollama:"
    ollama list
    read -p "Enter the name of the model to run: " selected_model
    if [ -z "$selected_model" ]; then
        echo "Error: No model name specified."
        return
    fi
    echo "Running the model '$selected_model'..."
    ollama run "$selected_model"
}

# Function to list Modelfiles
list_modelfiles() {
    echo "Available Modelfiles in the 'Kusanagi-Section/' directory:"
    mapfile -t files < <(ls -A "./Kusanagi-Section/")
    if [ ${#files[@]} -eq 0 ]; then
        echo "No files found in 'Kusanagi-Section/'."
    else
        for i in "${!files[@]}"; do
            echo "$((i+1)). ${files[$i]}"
        done
    fi
}

# Function to choose, create, and run a new model
create_and_run_model() {
    list_modelfiles
    if [ ${#files[@]} -eq 0 ]; then
        return
    fi

    read -p "Enter the number of the Modelfile to use: " model_number
    if ! [[ "$model_number" =~ ^[0-9]+$ ]] || [ "$model_number" -lt 1 ] || [ "$model_number" -gt ${#files[@]} ]; then
        echo "Error: Invalid number. Please choose a number between 1 and ${#files[@]}."
        return
    fi

    modelfile_name="${files[$((model_number-1))]}"
    if [ ! -f "./Kusanagi-Section/$modelfile_name" ]; then
        echo "Error: The file './Kusanagi-Section/$modelfile_name' does not exist."
        return
    fi

    read -p "Enter the name of the new model: " new_model_name
    echo "Creating the model '$new_model_name' using 'Kusanagi-Section/$modelfile_name'..."
    ollama create "$new_model_name" -f "./Kusanagi-Section/$modelfile_name"

    echo "Existing models in Ollama:"
    ollama list

    read -p "Enter the name of the model to run: " selected_model
    echo "Running the model '$selected_model'..."
    ollama run "$selected_model"
}

# Function to modify an existing Modelfile
modify_modelfile() {
    list_modelfiles
    if [ ${#files[@]} -eq 0 ]; then
        return
    fi

    read -p "Enter the number of the Modelfile to modify: " model_number
    if ! [[ "$model_number" =~ ^[0-9]+$ ]] || [ "$model_number" -lt 1 ] || [ "$model_number" -gt ${#files[@]} ]; then
        echo "Error: Invalid number. Please choose a number between 1 and ${#files[@]}."
        return
    fi

    modelfile_name="${files[$((model_number-1))]}"
    if [ ! -f "./Kusanagi-Section/$modelfile_name" ]; then
        echo "Error: The file './Kusanagi-Section/$modelfile_name' does not exist."
        return
    fi

    old_modelfile_name="old_$modelfile_name"
    echo "Creating a copy of '$modelfile_name' as '$old_modelfile_name'..."
    cp "./Kusanagi-Section/$modelfile_name" "./Kusanagi-Section/$old_modelfile_name"

    echo "Modifying the Modelfile '$modelfile_name' in nano (save with Ctrl+O, exit with Ctrl+X)..."
    nano "./Kusanagi-Section/$modelfile_name"

    echo "The Modelfile '$modelfile_name' has been modified. A copy of the old version is saved as '$old_modelfile_name'."
}

# Function to delete an existing Modelfile
delete_modelfile() {
    list_modelfiles
    if [ ${#files[@]} -eq 0 ]; then
        return
    fi

    read -p "Enter the number of the Modelfile to delete: " model_number
    if ! [[ "$model_number" =~ ^[0-9]+$ ]] || [ "$model_number" -lt 1 ] || [ "$model_number" -gt ${#files[@]} ]; then
        echo "Error: Invalid number. Please choose a number between 1 and ${#files[@]}."
        return
    fi

    modelfile_name="${files[$((model_number-1))]}"
    if [ ! -f "./Kusanagi-Section/$modelfile_name" ]; then
        echo "Error: The file './Kusanagi-Section/$modelfile_name' does not exist."
        return
    fi

    echo "Deleting the Modelfile '$modelfile_name'..."
    rm "./Kusanagi-Section/$modelfile_name"
    echo "The Modelfile '$modelfile_name' has been deleted."
}

# Models Section Menu
models_section() {
    while true; do
        echo -ne "\n"
        echo -e "\033[43;30m MODELS SECTION .....//\033[0m"
        echo -ne "
$(ColorGreen ' 01 --> ') $(ColorGreen 'List existing models ..............//__________________')
$(ColorGreen ' 02 --> ') $(ColorGreen 'Delete an existing model ..........//__________________')
$(ColorGreen ' 03 --> ') $(ColorGreen 'Run an existing model .............//__________________')
$(ColorGreen ' 04 --> ') $(ColorGreen 'Return to Main Menu ...............//__________________')
$(ColorRed   ' 00 --> ') $(ColorRed   'Quit ..............................//__________________')
$(ColorGreen ' OPTION NUMBER .....................// = ')"
        read a
        case $a in
            01) list_existing_models ; models_section ;;
            02) delete_model ; models_section ;;
            03) run_existing_model ; models_section ;;
            04) return ;;
            00)
                echo "Goodbye!"
                exit 0
                ;;
            *) echo -e $(ColorRed 'WRONG CHOICE .........................................//') ; models_section ;;
        esac
    done
}

# Modelfiles Section Menu
modelfiles_section() {
    while true; do
        echo -ne "\n"
        echo -e "\033[43;30m MODELFILES SECTION .....//\033[0m"
        echo -ne "
$(ColorGreen ' 01 --> ') $(ColorGreen 'List available Modelfiles ..........//__________________')
$(ColorGreen ' 02 --> ') $(ColorGreen 'Choose create/run a new model ......//__________________')
$(ColorGreen ' 03 --> ') $(ColorGreen 'Modify an existing Modelfile .......//__________________')
$(ColorGreen ' 04 --> ') $(ColorGreen 'Delete an existing Modelfile .......//__________________')
$(ColorGreen ' 05 --> ') $(ColorGreen 'Return to Main Menu ................//__________________')
$(ColorRed   ' 00 --> ') $(ColorRed   'Quit ...............................//__________________')
$(ColorGreen ' OPTION NUMBER ......................// = ')"
        read a
        case $a in
            01) check_directory ; list_modelfiles ; modelfiles_section ;;
            02) check_directory ; create_and_run_model ; modelfiles_section ;;
            03) check_directory ; modify_modelfile ; modelfiles_section ;;
            04) check_directory ; delete_modelfile ; modelfiles_section ;;
            05) return ;;
            00)
                echo "Goodbye!"
                exit 0
                ;;
            *) echo -e $(ColorRed 'WRONG CHOICE .........................................//') ; modelfiles_section ;;
        esac
    done
}

# Pre-Menu (Main Menu)
main_menu() {
    while true; do
        echo -ne "\n"
        echo -e "\033[43;30m MAIN MENU .....//\033[0m"
        echo -ne "
$(ColorGreen ' 01 --> ') $(ColorGreen 'Models Section .....................//__________________')
$(ColorGreen ' 02 --> ') $(ColorGreen 'Modelfiles Section .................//__________________')
$(ColorRed   ' 00 --> ') $(ColorRed   'Quit ...............................//__________________')
$(ColorGreen ' OPTION NUMBER ......................// = ')"
        read a
        case $a in
            01) models_section ;;
            02) modelfiles_section ;;
            00)
                echo "Goodbye!"
                exit 0
                ;;
            *) echo -e $(ColorRed 'WRONG CHOICE .........................................//') ; main_menu ;;
        esac
    done
}

# Call the main menu function
main_menu
