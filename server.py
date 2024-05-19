import socket
import threading

# クライアントを管理するリスト
clients = []

# クライアントからのメッセージをブロードキャストする関数
def broadcast(message, client_socket):
    for client in clients:
        if client != client_socket:
            try:
                client.send(message)
            except:
                client.close()
                clients.remove(client)

# クライアントをハンドルする関数
def handle_client(client_socket):
    while True:
        try:
            message = client_socket.recv(1024)
            broadcast(message, client_socket)
        except:
            client_socket.close()
            clients.remove(client_socket)
            break

# サーバーをセットアップ
def start_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(("0.0.0.0", 5555))
    server_socket.listen()

    print("Server started and listening on port 5555")

    while True:
        client_socket, client_address = server_socket.accept()
        print(f"Connection from {client_address}")

        clients.append(client_socket)
        thread = threading.Thread(target=handle_client, args=(client_socket,))
        thread.start()

if __name__ == "__main__":
    start_server()