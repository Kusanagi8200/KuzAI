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
        if (!response.ok) throw new Error("ERROR HTTP");
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
        const response = await fetch('http://192.168.177.187/gpu-info.php');
        if (!response.ok) throw new Error("ERROR GPU");
        const data = await response.json();

        const gpuInfoElem = document.getElementById('gpuInfo');
        gpuInfoElem.innerHTML = '';

        data.forEach((gpu, index) => {
            const div = document.createElement('div');
            div.classList.add('gpu-block');
            div.innerHTML = `
                <strong>GPU ${index} - ${gpu.name}</strong><br>
                TEMP --> ${gpu.temperature}°C<br>
                USED --> ${gpu.utilization}%<br>
                MEMORY --> ${gpu.memory_used}/${gpu.memory_total} MiB (FREE --> ${gpu.memory_free} MiB)
            `;
            gpuInfoElem.appendChild(div);
        });
    } catch (error) {
        console.error('ERROR', error);
    }
}

async function fetchCPUInfo() {
    try {
        const response = await fetch('http://192.168.177.187/cpu-info.php');
        if (!response.ok) throw new Error("Erreur HTTP");
        const data = await response.json();

        if (data.cpu_model) document.getElementById('cpuModel').textContent = data.cpu_model;
        if (data.cpu_cores) document.getElementById('cpuCores').textContent = data.cpu_cores;
        if (data.cpu_speed) document.getElementById('cpuSpeed').textContent = data.cpu_speed;
        if (data.cpu_architecture) document.getElementById('cpuArchitecture').textContent = data.cpu_architecture;
    } catch (error) {
        console.error('ERROR', error);
    }
}

async function fetchOllamaModels() {
    try {
        const response = await fetch('http://192.168.177.187/ollama-models.php');
        if (!response.ok) throw new Error('HTTP ERROR');

        const data = await response.json();
        const container = document.getElementById('ollamaModels');

        if (data.models && Array.isArray(data.models)) {
            container.innerHTML = data.models.map(line => `<div>${line}</div>`).join('');
        } else {
            container.textContent = 'NO MODEL FOUND';
        }
    } catch (error) {
        document.getElementById('ollamaModels').textContent = 'ERROR';
        console.error(error);
    }
}

async function fetchOllamaModels() {
    try {
        const response = await fetch('http://192.168.177.187/ollama-models.php');
        if (!response.ok) throw new Error('Erreur HTTP');

        const data = await response.json();
        const listElem = document.getElementById('ollamaModels');

        listElem.innerHTML = '';

        if (data.models && data.models.length > 0) {
            data.models.forEach(model => {
                const li = document.createElement('li');
                li.textContent = `${model.name} (${model.size})`;
                listElem.appendChild(li);
            });
        } else {
            listElem.innerHTML = '<li>NO MODELS</li>';
        }
    } catch (err) {
        console.error('ERROR', err);
        document.getElementById('ollamaModels').innerHTML = '<li>ERROR</li>';
    }
}


fetchCPUInfo();
fetchGpuInfo();
fetchSystemInfo();
fetchOllamaModels();

setInterval(fetchCPUInfo, 1000);
setInterval(fetchGpuInfo, 1000);
setInterval(fetchSystemInfo, 1000);
setInterval(fetchOllamaModels, 3000);
