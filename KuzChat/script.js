const messagesDiv = document.getElementById('messages');
const userInput = document.getElementById('userInput');
let abortController = null;
let isFirstRequest = true; // Indicateur pour la première requête

function addMessage(content, isUser) {
    const messageDiv = document.createElement('div');
    messageDiv.classList.add('message', isUser ? 'user-message' : 'bot-message');
    messageDiv.textContent = content;
    messagesDiv.appendChild(messageDiv);
    messagesDiv.scrollTop = messagesDiv.scrollHeight;
}

async function sendMessage() {
    const prompt = userInput.value.trim();
    if (!prompt) return;

    // Supprimer le message d'accueil avant la première requête
    if (isFirstRequest) {
        const welcomeMessage = document.querySelector('.welcome-message');
        if (welcomeMessage) welcomeMessage.remove();
        messagesDiv.style.display = 'block'; // Retour à l’affichage normal
        isFirstRequest = false;
    }

    addMessage(prompt, true);
    userInput.value = '';

    abortController = new AbortController();
    const signal = abortController.signal;

    try {
        const response = await fetch('http://192.168.138.187:11435/api/generate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                model: 'KuzaTrash',
                prompt: prompt
            }),
            signal
        });

        const reader = response.body.getReader();
        const decoder = new TextDecoder();
        let botMessageDiv = null;

        while (true) {
            const { done, value } = await reader.read();
            if (done) break;

            const chunk = decoder.decode(value);
            const lines = chunk.split('\n').filter(line => line.trim());

            for (const line of lines) {
                const data = JSON.parse(line);
                if (!botMessageDiv) {
                    botMessageDiv = document.createElement('div');
                    botMessageDiv.classList.add('message', 'bot-message');
                    messagesDiv.appendChild(botMessageDiv);
                }
                botMessageDiv.textContent += data.response;
                messagesDiv.scrollTop = messagesDiv.scrollHeight;
            }
        }
    } catch (error) {
        if (error.name === 'AbortError') {
            addMessage('Génération arrêtée.', false);
        } else {
            console.error('Erreur:', error);
            addMessage('Erreur lors de la génération.', false);
        }
    } finally {
        abortController = null;
    }
}

function stopGeneration() {
    if (abortController) {
        abortController.abort();
        abortController = null;
    }
}
