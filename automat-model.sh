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

green='\033[43;30m'      # Fond jaune, texte noir (déjà existant)
red='\033[41;30m'        # Fond rouge, texte noir (déjà existant)
darkblue='\033[44;97m'   # Fond bleu foncé, texte blanc
lightblue='\033[104;97m' # Fond bleu clair, texte blanc
yellow='\033[43;30m'     # Fond jaune, texte noir (identique à green pour l'exemple)
clear='\e[0m'            # Réinitialisation (déjà existant)

##
# Color Functions
##

ColorGreen() {
    echo -ne $green$1$clear
}

ColorRed() {
    echo -ne $red$1$clear
}

ColorDarkBlue() {
    echo -ne $darkblue$1$clear
}

ColorLightBlue() {
    echo -ne $lightblue$1$clear
}

ColorYellow() {
    echo -ne $yellow$1$clear
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

    read -p "MODELFILE TO USE " model_number
    if ! [[ "$model_number" =~ ^[0-9]+$ ]] || [ "$model_number" -lt 1 ] || [ "$model_number" -gt ${#files[@]} ]; then
        echo "ERROR --> Invalid number. Please choose a number between 1 and ${#files[@]}."
        return
    fi

    modelfile_name="${files[$((model_number-1))]}"
    if [ ! -f "./Kusanagi-Section/$modelfile_name" ]; then
        echo "ERROR --> The file './Kusanagi-Section/$modelfile_name' does not exist."
        return
    fi

    read -p "NAME OF THE NEW MODEL " new_model_name
    echo "CREATING NEW MODEL '$new_model_name' USING 'Kusanagi-Section/$modelfile_name'..."
    ollama create "$new_model_name" -f "./Kusanagi-Section/$modelfile_name"

    echo "EXISTING MODELS"
    ollama list

    read -p "NAME OF THE MODEL TO RUN" selected_model
    echo "RUNNING THE MODEL '$selected_model'..."
    ollama run "$selected_model"
}

# Function to modify an existing Modelfile
modify_modelfile() {
    list_modelfiles
    if [ ${#files[@]} -eq 0 ]; then
        return
    fi

    read -p "NUMBER OF THE MODELFILE TO EDIT " model_number
    if ! [[ "$model_number" =~ ^[0-9]+$ ]] || [ "$model_number" -lt 1 ] || [ "$model_number" -gt ${#files[@]} ]; then
        echo "ERROR --> Invalid number. Please choose a number between 1 and ${#files[@]}."
        return
    fi

    modelfile_name="${files[$((model_number-1))]}"
    if [ ! -f "./Kusanagi-Section/$modelfile_name" ]; then
        echo "ERROR --> The file './Kusanagi-Section/$modelfile_name' does not exist."
        return
    fi

    old_modelfile_name="old_$modelfile_name"
    echo "CREATING A COPY OF '$modelfile_name' AS '$old_modelfile_name'..."
    cp "./Kusanagi-Section/$modelfile_name" "./Kusanagi-Section/$old_modelfile_name"

    echo "MODIFYING MODELFILE '$modelfile_name' IN NANO"
    nano "./Kusanagi-Section/$modelfile_name"

    echo "MODELFILE '$modelfile_name' MODIFIED --> A copy of the old version is saved as '$old_modelfile_name'."
}

# Function to delete an existing Modelfile
delete_modelfile() {
    list_modelfiles
    if [ ${#files[@]} -eq 0 ]; then
        return
    fi

    read -p "NUMBER OF THE MODELFILE TO DELETE " model_number
    if ! [[ "$model_number" =~ ^[0-9]+$ ]] || [ "$model_number" -lt 1 ] || [ "$model_number" -gt ${#files[@]} ]; then
        echo "ERROR --> Invalid number. Please choose a number between 1 and ${#files[@]}."
        return
    fi

    modelfile_name="${files[$((model_number-1))]}"
    if [ ! -f "./Kusanagi-Section/$modelfile_name" ]; then
        echo "ERROR --> The file './Kusanagi-Section/$modelfile_name' does not exist."
        return
    fi

    echo "DELETING MODELFILE '$modelfile_name'..."
    rm "./Kusanagi-Section/$modelfile_name"
    echo "MODELFILE '$modelfile_name' DELETED"
}

# Parameters Section Menu
parameters_section() {
    while true; do
        echo -ne "\n"
        echo -e "\033[44;97m PARAMETERS SECTION .....//\033[0m"
        echo -ne "\n"
        # Function to check if Parameters-Section directory exists
        check_parameters_directory() {
            if [ ! -d "./Parameters-Section" ]; then
                echo "ERROR --> The 'Parameters-Section' directory does not exist."
                return 1
            fi
            return 0
        }
        
        # Function to list and view parameter files
        list_and_view_parameters() {
            if ! check_parameters_directory; then
                return
            fi
            
            echo "AVAILABLE PARAMETERS FILES"
            mapfile -t param_files < <(ls -A "./Parameters-Section/")
            if [ ${#param_files[@]} -eq 0 ]; then
                echo "NO PARAMETERS FILES FOUND"
                return
            fi
            
            for i in "${!param_files[@]}"; do
                echo "$((i+1)). ${param_files[$i]}"
            done
            
            read -p "NUMBER OF THE PARAMETERS FILE --> 0 to GOBACK: " param_number
            if [ "$param_number" == "0" ]; then
                return
            fi
            
            if ! [[ "$param_number" =~ ^[0-9]+$ ]] || [ "$param_number" -lt 1 ] || [ "$param_number" -gt ${#param_files[@]} ]; then
                echo "WRONG CHOISE --> Number between 1 and ${#param_files[@]} --> 0 to GOBACK"
                return
            fi
            
            param_file_name="${param_files[$((param_number-1))]}"
            if [ ! -f "./Parameters-Section/$param_file_name" ]; then
                echo "ERROR --> The file './Parameters-Section/$param_file_name' does not exist."
                return
            fi
            
            echo -e "\nContents of '$param_file_name':"
            echo "----------------------------------------"
            cat "./Parameters-Section/$param_file_name"
            echo "----------------------------------------"
        }
        
        echo -ne "\n"
        echo -ne "$(ColorGreen ' 01 --> ') $(ColorGreen 'LIST AND VIEW PARAMETERS ...........//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorGreen ' 02 --> ') $(ColorGreen 'BACK TO MAIN MENU ..................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorRed   ' 00 --> ') $(ColorRed   'QUIT ...............................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorLightBlue ' OPTION NUMBER .........................//_____ = ')"
        read a
        case $a in
            01) list_and_view_parameters ;;
            02) return ;;
            00)
                echo "DISCONNECTED"
                exit 0
                ;;
            *) echo -e $(ColorRed 'WRONG CHOICE') ;;
        esac
    done
}

# Models Section Menu
models_section() {
    while true; do
        echo -ne "\n"
        echo -e "\033[44;97m MODELS SECTION .....//\033[0m"
        echo -ne "\n"
        echo -ne "$(ColorGreen ' 01 --> ') $(ColorGreen 'LIST A MODEL .......................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorGreen ' 02 --> ') $(ColorGreen 'DELETE A MODEL .....................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorGreen ' 03 --> ') $(ColorGreen 'RUN A MODEL ........................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorGreen ' 04 --> ') $(ColorGreen 'BACK TO MAIN MENU ..................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorRed   ' 00 --> ') $(ColorRed   'QUIT ...............................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorLightBlue ' OPTION NUMBER .........................//_____ = ')"
        read a
        case $a in
            01) list_existing_models ; models_section ;;
            02) delete_model ; models_section ;;
            03) run_existing_model ; models_section ;;
            04) return ;;
            00)
                echo "DISCONNECTED"
                exit 0
                ;;
            *) echo -e $(ColorRed 'WRONG CHOICE') ; models_section ;;
        esac
    done
}

# Modelfiles Section Menu
modelfiles_section() {
    while true; do
        echo -ne "\n"
        echo -e "\033[44;97m MODELFILES SECTION .....//\033[0m"
        echo -ne "\n"
        echo -ne "$(ColorGreen ' 01 --> ') $(ColorGreen 'LIST AVAILABLE MODELFILES ..........//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorGreen ' 02 --> ') $(ColorGreen 'CREATE AND RUN A NEW MODEL .........//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorGreen ' 03 --> ') $(ColorGreen 'MODIFY A MODELFILE .................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorGreen ' 04 --> ') $(ColorGreen 'DELETE A MODELFILE .................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorGreen ' 05 --> ') $(ColorGreen 'BACK TO MAIN MENU ..................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorRed   ' 00 --> ') $(ColorRed   'QUIT ...............................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorLightBlue ' OPTION NUMBER .........................//_____ = ')"
        read a
        case $a in
            01) check_directory ; list_modelfiles ; modelfiles_section ;;
            02) check_directory ; create_and_run_model ; modelfiles_section ;;
            03) check_directory ; modify_modelfile ; modelfiles_section ;;
            04) check_directory ; delete_modelfile ; modelfiles_section ;;
            05) return ;;
            00)
                echo "DISCONNECTED"
                exit 0
                ;;
            *) echo -e $(ColorRed 'WRONG CHOICE') ; modelfiles_section ;;
        esac
    done
}

# Pre-Menu (Main Menu)
main_menu() {
    while true; do
        echo -ne "\n"
        echo -e "\033[44;97m KuzAI MENU .....//\033[0m"
        echo -ne "\n"
        echo -ne "$(ColorGreen ' 01 --> ') $(ColorGreen 'MODELES SECTION ....................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorGreen ' 02 --> ') $(ColorGreen 'MODELFILES SECTION .................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorGreen ' 03 --> ') $(ColorGreen 'PARAMETERS SECTION .................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorRed   ' 00 --> ') $(ColorRed   'QUIT ...............................//_____')\n"
        echo -ne "\n"
        echo -ne "$(ColorLightBlue ' OPTION NUMBER .........................//_____ = ')"
        read a
        case $a in
            01) models_section ;;
            02) modelfiles_section ;;
            03) parameters_section ;;
            00)
                echo "DISCONNECTED"
                exit 0
                ;;
            *) echo -e $(ColorRed 'WRONG CHOICE') ; main_menu ;;
	esac
    done
}

# Call the main menu function
main_menu
