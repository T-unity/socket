// const socket = new WebSocket('ws://localhost:8080/ws');
// const socket = new WebSocket('ws://socket.gynga.org/ws');
const socket = new WebSocket('wss://socket.gynga.org/ws');

socket.onopen = function(event) {
    console.log('WebSocket is open now.');
    document.getElementById('messages').innerHTML += '<p class="system">WebSocket is open now.</p>';
};

socket.onmessage = function(event) {
    console.log('Message from server:', event.data);
    document.getElementById('messages').innerHTML += `<p class="message">${event.data}</p>`;
};

socket.onerror = function(error) {
    console.log('WebSocket Error:', error);
    document.getElementById('messages').innerHTML += '<p class="error">WebSocket Error.</p>';
};

socket.onclose = function(event) {
    console.log('WebSocket is closed now.');
    document.getElementById('messages').innerHTML += '<p class="system">WebSocket is closed now.</p>';
};

function sendMessage() {
    const message = document.getElementById('messageInput').value;
    socket.send(message);
    document.getElementById('messages').innerHTML += `<p class="sent">Sent: ${message}</p>`;
    document.getElementById('messageInput').value = '';
}