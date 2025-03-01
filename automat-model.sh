#!/bin/bash

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

    # Create a copy "old" of the original file
    old_modelfile_name="old_$modelfile_name"
    echo "Creating a copy of '$modelfile_name' as '$old_modelfile_name'..."
    cp "./Kusanagi-Section/$modelfile_name" "./Kusanagi-Section/$old_modelfile_name"

    # Open the original file in nano for modification
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
        echo -e "\n=== Models Section ==="
        echo "   1.   List existing models"
        echo "   2.   Delete an existing model"
        echo "   3.   Run an existing model"
        echo "   4.   Return to Main Menu"
        echo "   5.   Quit"
        read -p "Choose an option (1-5): " choice

        case $choice in
            1)
                list_existing_models
                ;;
            2)
                delete_model
                ;;
            3)
                run_existing_model
                ;;
            4)
                echo "Returning to main menu..."
                return
                ;;
            5)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Error: Invalid option. Please choose between 1 and 5."
                ;;
        esac
    done
}

# Modelfiles Section Menu
modelfiles_section() {
    while true; do
        echo -e "\n=== Modelfiles Section ==="
        echo "   1.   List available Modelfiles"
        echo "   2.   Choose create/run a new model"
        echo "   3.   Modify an existing Modelfile"
        echo "   4.   Delete an existing Modelfile"
        echo "   5.   Return to Main Menu"
        echo "   6.   Quit"
        read -p "Choose an option (1-6): " choice

        case $choice in
            1)
                check_directory
                list_modelfiles
                ;;
            2)
                check_directory
                create_and_run_model
                ;;
            3)
                check_directory
                modify_modelfile
                ;;
            4)
                check_directory
                delete_modelfile
                ;;
            5)
                echo "Returning to main menu..."
                return
                ;;
            6)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Error: Invalid option. Please choose between 1 and 6."
                ;;
        esac
    done
}

# Pre-Menu (Main Menu)
while true; do
    echo -e "\n=== Pre-Menu ==="
    echo "   1.   Models Section"
    echo "   2.   Modelfiles Section"
    echo "   3.   Quit"
    read -p "Choose an option (1-3): " choice

    case $choice in
        1)
            models_section
            ;;
        2)
            modelfiles_section
            ;;
        3)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Error: Invalid option. Please choose between 1 and 3."
            ;;
    esac
done
