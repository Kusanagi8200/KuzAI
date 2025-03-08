const messagesDiv = document.getElementById('messages');
const userInput = document.getElementById('userInput');

function addMessage(content, isUser = false) {
    const messageDiv = document.createElement('div');
    messageDiv.classList.add('message');
    messageDiv.classList.add(isUser ? 'user-message' : 'bot-message');
    messageDiv.textContent = content;
    messagesDiv.appendChild(messageDiv);
    messagesDiv.scrollTop = messagesDiv.scrollHeight; // Défilement auto vers le bas
}

async function sendMessage() {
    const prompt = userInput.value.trim();
    if (!prompt) return;

    // Ajouter le message de l'utilisateur
    addMessage(prompt, true);
    userInput.value = ''; // Vider l'input

    // Préparer la requête
    const response = await fetch('http://192.168.138.187:11435/api/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            model: 'KuzaTrash',
            prompt: prompt
        })
    });

    // Gestion du streaming
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
}

// Permettre l'envoi avec la touche Entrée
userInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') sendMessage();
});
