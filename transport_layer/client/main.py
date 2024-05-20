import socket
import threading

# メッセージをサーバーに送信する関数
def send_message(client_socket):
    while True:
        message = input("")
        client_socket.send(message.encode('utf-8'))

# サーバーからのメッセージを受信する関数
def receive_message(client_socket):
    while True:
        try:
            message = client_socket.recv(1024).decode('utf-8')
            print(message)
        except:
            print("An error occurred. Connection closed.")
            client_socket.close()
            break

# クライアントをセットアップ
def start_client():
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect(("127.0.0.1", 5555))

    print("Connected to the server")

    send_thread = threading.Thread(target=send_message, args=(client_socket,))
    receive_thread = threading.Thread(target=receive_message, args=(client_socket,))

    send_thread.start()
    receive_thread.start()

if __name__ == "__main__":
    start_client()