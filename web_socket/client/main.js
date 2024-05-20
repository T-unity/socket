// 開発者ツールでコンソールを複数開いて、全てのタブで以下を実行する
// リアルタイム通信に成功している場合、あるクライアントからのメッセージが、サーバーに接続してる全クライアントに対してブロードキャストされる事が確認できる

const socket = new WebSocket('ws://localhost:8080/ws');

socket.onopen = function(event) {
    console.log('WebSocket is open now.');
    socket.send('Hello Server!');
};

socket.onmessage = function(event) {
    console.log('Message from server:', event.data);
};

socket.onerror = function(error) {
    console.log('WebSocket Error:', error);
};

socket.onclose = function(event) {
    console.log('WebSocket is closed now.');
};