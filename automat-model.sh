#!/bin/bash

# Check if the "Models" directory exists
if [ ! -d "./Models" ]; then
    echo "Error: The directory 'Models' does not exist."
    exit 1
fi

# List available Modelfiles in the "Models" directory
echo "Available Modelfiles in 'Models/' directory:"
ls Models/

# Prompt the user to choose a Modelfile
read -p "Enter the Modelfile name (from 'Models/' directory): " modelfile_name

# Check if the selected Modelfile exists
if [ ! -f "./Models/$modelfile_name" ]; then
    echo "Error: The file './Models/$modelfile_name' does not exist."
    exit 1
fi

# Prompt the user to enter a name for the new model
read -p "Enter the name of the new model: " new_model_name

# Create the new model using Ollama
echo "Creating the model '$new_model_name' using 'Models/$modelfile_name'..."
ollama create "$new_model_name" -f "./Models/$modelfile_name"

# List available models in Ollama
echo "Available models in Ollama:"
ollama list

# Prompt the user to select a model to run
read -p "Enter the model name to run: " selected_model

# Run the selected model using Ollama
echo "Running model '$selected_model'..."
ollama run "$selected_model"
