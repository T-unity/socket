package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
)

var clients = make(map[net.Conn]bool)
var messages = make(chan string)

func handleClient(conn net.Conn) {
	defer conn.Close()
	clients[conn] = true

	for {
		message, err := bufio.NewReader(conn).ReadString('\n')
		if err != nil {
			delete(clients, conn)
			break
		}
		messages <- message
	}
}

func broadcastMessages() {
	for {
		msg := <-messages
		for client := range clients {
			_, err := fmt.Fprintf(client, msg)
			if err != nil {
				client.Close()
				delete(clients, client)
			}
		}
	}
}

func startServer() {
	listener, err := net.Listen("tcp", "0.0.0.0:5555")
	if err != nil {
		fmt.Println("Error starting server:", err)
		os.Exit(1)
	}
	defer listener.Close()

	go broadcastMessages()

	fmt.Println("Server started and listening on port 5555")

	for {
		conn, err := listener.Accept()
		if err != nil {
			fmt.Println("Error accepting connection:", err)
			continue
		}
		go handleClient(conn)
	}
}

func main() {
	startServer()
}
