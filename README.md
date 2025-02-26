## I hacked Major Kusanagi's ghost

### LLM Research Repository

Dedicated to exploring and documenting research on **large language models (LLMs)**. 

### With ollama 

--> curl -fsSL https://ollama.com/install.sh | sh

--> ollama create $NameOfNewModel -f ./$ModelfileName

--> ollama list

--> ollama run $NameOfNewModel 

### ________________________________________________________________________________________________________________

### Script Breakdown

--> Checks if the "Models" directory exists before listing available Modelfiles.

--> Lists all Modelfiles inside the Models/ directory.

--> Asks the user to choose a Modelfile and verifies that it exists.

--> Prompts the user to enter a name for the new model before creating it.

--> Runs ollama create to generate the new model from the chosen Modelfile.

--> Lists all models currently available in Ollama using ollama list.

--> Prompts the user to select a model and executes it using ollama run.




