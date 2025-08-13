const messagesDiv = document.getElementById('messages');
const userInput = document.getElementById('userInput');
let abortController = null;

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

    addMessage(prompt, true); // Affiche le message de l'utilisateur
    userInput.value = '';

    abortController = new AbortController();
    const signal = abortController.signal;

    try {
        const response = await fetch('http://10.12.248.187:3000/proxy', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ prompt, model: document.getElementById('modelName').textContent.trim() }),
            signal
        });

        if (!response.ok) throw new Error("HTTP ERROR");

        const reader = response.body.getReader();
        const decoder = new TextDecoder();
        let botMessageDiv = document.createElement('div');
        botMessageDiv.classList.add('message', 'bot-message');
        messagesDiv.appendChild(botMessageDiv);

        let buffer = '';

        while (true) {
            const { done, value } = await reader.read();
            if (done) break;

            buffer += decoder.decode(value, { stream: true });
            const lines = buffer.split('\n');
            buffer = lines.pop(); // Reste incomplet

            for (const line of lines) {
                if (!line.trim()) continue;
                try {
                    const data = JSON.parse(line);
                    if (data.response !== undefined) {
                        botMessageDiv.textContent += data.response;
                        messagesDiv.scrollTop = messagesDiv.scrollHeight;
                    }
                } catch (e) {
                    console.error('JSON parse error:', e, line);
                }
            }
        }

        // Traite la dernière ligne incomplète
        if (buffer.trim()) {
            try {
                const data = JSON.parse(buffer);
                if (data.response !== undefined) {
                    botMessageDiv.textContent += data.response;
                    messagesDiv.scrollTop = messagesDiv.scrollHeight;
                }
            } catch (e) {
                console.error('JSON parse error at end:', e, buffer);
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
        const response = await fetch('http://10.12.248.187/system-info.php');
        if (!response.ok) throw new Error("HTTP ERROR");
        const data = await response.json();

        if (data.ip) document.getElementById('ipAddress').textContent = data.ip;
        if (data.model) document.getElementById('modelName').textContent = data.model;
        if (data.date && data.time) {
            const dateTimeElem = document.getElementById('dateTime');
            if (dateTimeElem) dateTimeElem.textContent = `${data.date} ${data.time}`;
        }
    } catch (error) {
        console.error('ERROR', error);
    }
}

async function fetchGpuInfo() {
    try {
        const response = await fetch('http://10.12.248.187/gpu-info.php');
        if (!response.ok) throw new Error("GPU ERROR");
        const data = await response.json();

        const gpuInfoElem = document.getElementById('gpuInfo');
        gpuInfoElem.innerHTML = '';

        data.forEach((gpu, index) => {
            const div = document.createElement('div');
            div.classList.add('gpu-block');
            div.innerHTML = `
                <strong>GPU ${index} - ${gpu.name}</strong><br>
                TEMP - ${gpu.temperature}°C<br>
                USED - ${gpu.utilization}%<br>
                MEMORY - ${gpu.memory_used}/${gpu.memory_total} MiB (FREE --> ${gpu.memory_free} MiB)
            `;
            gpuInfoElem.appendChild(div);
        });
    } catch (error) {
        console.error('ERROR', error);
    }
}

async function fetchCPUInfo() {
    try {
        const response = await fetch('http://10.12.248.187/cpu-info.php');
        if (!response.ok) throw new Error("HTTP ERROR");
        const data = await response.json();

        if (data.cpu_model) document.getElementById('cpuModel').textContent = data.cpu_model;
        if (data.cpu_cores) document.getElementById('cpuCores').textContent = data.cpu_cores;
        if (data.cpu_architecture) document.getElementById('cpuArchitecture').textContent = data.cpu_architecture;
    } catch (error) {
        console.error('ERROR', error);
    }
}

function loadOllamaModels() {
    fetch('system-info.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=list'
    })
    .then(res => res.text())
    .then(data => {
	const rawLines = data.trim().split('\n').filter(line => line.length > 0 && !line.startsWith('NAME'));
	const modelNames = [...new Set(rawLines.map(line => line.split(/\s+/)[0]))];
        const container = document.getElementById('ollamaModels');
        container.innerHTML = '';

    modelNames.forEach(model => {
        const li = document.createElement('li');

        const nameSpan = document.createElement('span');
        nameSpan.textContent = model;

        const startBtn = document.createElement('button');
        startBtn.textContent = 'START ▶';
        startBtn.title = 'START';
        startBtn.onclick = () => controlModel('start', model);

        const stopBtn = document.createElement('button');
        stopBtn.textContent = 'STOP ■';
        stopBtn.title = 'STOP';
        stopBtn.onclick = () => controlModel('stop', model);

        const statusSpan = document.createElement('span');
        statusSpan.classList.add('model-status');

    	const currentModel = document.getElementById('modelName').textContent.trim();
   	if (model === currentModel) {
            statusSpan.textContent = ' ON';
            statusSpan.style.color = 'green';
            statusSpan.style.fontWeight = 'bold';
        }

    	li.appendChild(nameSpan);
    	li.appendChild(startBtn);
    	li.appendChild(stopBtn);
    	li.appendChild(statusSpan);
    	container.appendChild(li);
    });

    })
    .catch(err => {
        console.error('ERROR fetching models:', err);
        document.getElementById('ollamaModels').innerHTML = '<li>ERROR</li>';
    });
}

function controlModel(action, model) {
    fetch('system-info.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: `action=${action}&model=${encodeURIComponent(model)}`
    })
    .then(res => res.text())
    .then(msg => alert(msg))
    .catch(err => console.error('Erreur Ollama:', err));
}

// Initialisation
document.addEventListener('DOMContentLoaded', () => {
    loadOllamaModels();
    fetchCPUInfo();
    fetchGpuInfo();
    fetchSystemInfo();
    setInterval(fetchCPUInfo, 1000);
    setInterval(fetchGpuInfo, 1000);
    setInterval(fetchSystemInfo, 1000);
    setInterval(loadOllamaModels, 3000);
});
