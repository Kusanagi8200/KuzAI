const messagesDiv = document.getElementById('messages');
const userInput = document.getElementById('userInput');
let abortController = null;
let isFirstRequest = true; 

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

    addMessage(prompt, true);
    userInput.value = '';

    abortController = new AbortController();
    const signal = abortController.signal;

    try {
        const response = await fetch('http://192.168.124.187/api/generate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                model: 'KuzTrash',
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
            addMessage('ABORTED - TRY AGAIN', false);
        } else {
            console.error('Erreur:', error);
            addMessage('ERROR - TRY AGAIN', false);
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
