## I hacked Major Kusanagi's ghost

### LLM Research Repository

Dedicated to exploring and documenting research on **large language models (LLMs)**. 


####  ___________________________________________________________________________

KuzAI - Bash Script for Ollama Model Management

KuzAI is a Bash script designed to simplify the management of models and Modelfiles for the Ollama framework. 
This tool provides an interactive, color-coded menu interface to perform various tasks such as listing, creating, running, modifying, and deleting models and Modelfiles. 

It is distributed under the GNU General Public License (GPL) v3 or later, ensuring it is free and open-source software.

### Features

KuzAI organizes its functionalities into three main sections: **Models**, **Modelfiles**, and **Parameters**.
Below is a detailed breakdown of what the application can do.

### 1. Main Menu

The entry point of the application is the KuzAI Menu, which offers the following options:

    Models Section: Manage existing Ollama models.
    Modelfiles Section: Work with Modelfiles stored in the Kusanagi-Section/ directory.
    Parameters Section: View parameter files stored in the Parameters-Section/ directory.
    Quit: Exit the application.

### 2. Models Section

This section allows you to interact with models already installed in Ollama. Available options include:

    List a Model: Displays a list of all installed models using ollama list.
    Delete a Model: Prompts for a model name and deletes it using ollama delete.
    Run a Model: Prompts for a model name and runs it with ollama run.
    Back to Main Menu: Returns to the main menu.
    Quit: Exits the application.

### 3. Modelfiles Section

This section manages Modelfiles located in the Kusanagi-Section/ directory. It requires this directory to exist; otherwise, the script will exit with an error. 
The options are:

    List Available Modelfiles: Lists all files in Kusanagi-Section/ with numbered options.
    Create and Run a New Model:
        Lists available Modelfiles.
        Prompts for a Modelfile number to use.
        Asks for a new model name and creates it with ollama create.
        Prompts for a model name to run with ollama run.
    Modify a Modelfile:
        Lists available Modelfiles.
        Prompts for a Modelfile number to edit.
        Creates a backup (prefixed with old_) of the selected Modelfile.
        Opens the Modelfile in the nano editor for modification.
    Delete a Modelfile:
        Lists available Modelfiles.
        Prompts for a Modelfile number to delete.
        Deletes the selected Modelfile from Kusanagi-Section/.
    Back to Main Menu: Returns to the main menu.
    Quit: Exits the application.

### 4. Parameters Section

This section is dedicated to viewing parameter files stored in the Parameters-Section/ directory. It includes:

    List and View Parameters:
        Lists all files in Parameters-Section/.
        Prompts for a file number to view (or 0 to go back).
        Displays the contents of the selected file using cat.
    Back to Main Menu: Returns to the main menu.
    Quit: Exits the application.

## How It Works

Interface

    The script uses a color-coded terminal interface for better readability:
        Green: Menu options and positive feedback.
        Red: Quit option and error messages.
        Dark Blue: Section headers.
        Light Blue: Input prompts.
    Each menu is displayed with a header banner showing the creator's name, GitHub link, and the current date (2025).
    After executing a task, the script pauses with a "Press Enter to continue..." prompt, allowing the user to review the output before returning to the menu.

Execution Flow

    The script starts with the Main Menu.
    Users select an option by entering a number (e.g., 01 for Models Section).
    Within each section, a submenu provides specific tasks.
    Tasks prompt for additional input (e.g., model names or file numbers) where necessary.
    After completing a task, the submenu reappears unless the user chooses to go back or quit.

Prerequisites

    Ollama: The script assumes the ollama command-line tool is installed and configured.
    Kusanagi-Section/: A directory containing Modelfiles must exist in the script's working directory for the Modelfiles Section to function.
    Parameters-Section/: Optional directory for storing parameter files (required for the Parameters Section).
    nano: Used as the default editor for modifying Modelfiles.

Usage

    Save the script as kuzai.sh.
    Make it executable: chmod +x kuzai.sh.
    Run it: ./kuzai.sh.
    Navigate the menus using the provided option numbers.

