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
        const response = await fetch('http://192.168.177.187/api/generate', {
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

async function fetchSystemInfo() {
    try {
        const response = await fetch('http://192.168.177.187/system-info.php');
        if (!response.ok) throw new Error("Erreur HTTP");
        const data = await response.json();

        if (data.ip) document.getElementById('ipAddress').textContent = data.ip;
        if (data.model) document.getElementById('modelName').textContent = data.model;
        if (data.date && data.time) {
            const dateTimeElem = document.getElementById('dateTime');
            if (dateTimeElem) dateTimeElem.textContent = `${data.date} ${data.time}`;
        }
    } catch (error) {
        console.error('Erreur lors de la récupération des infos système :', error);
    }
}

async function fetchGpuInfo() {
    try {
        const response = await fetch('http://192.168.177.187/gpu-info.php');
        if (!response.ok) throw new Error("Erreur HTTP GPU");
        const data = await response.json();

        const gpuInfoElem = document.getElementById('gpuInfo');
        gpuInfoElem.innerHTML = ''; // nettoyage

        data.forEach((gpu, index) => {
            const div = document.createElement('div');
            div.classList.add('gpu-block');
            div.innerHTML = `
                <strong>GPU ${index} - ${gpu.name}</strong><br>
                Temp: ${gpu.temperature}°C<br>
                Utilisation: ${gpu.utilization}%<br>
                Mémoire: ${gpu.memory_used}/${gpu.memory_total} MiB (Libre: ${gpu.memory_free} MiB)
            `;
            gpuInfoElem.appendChild(div);
        });
    } catch (error) {
        console.error('Erreur GPU info :', error);
    }
}

setInterval(fetchGpuInfo, 2000);
fetchSystemInfo();
