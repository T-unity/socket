package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
)

func receiveMessages(conn net.Conn) {
	for {
		message, err := bufio.NewReader(conn).ReadString('\n')
		if err != nil {
			fmt.Println("Connection closed.")
			conn.Close()
			break
		}
		fmt.Print(message)
	}
}

func main() {
	conn, err := net.Dial("tcp", "127.0.0.1:5555")
	if err != nil {
		fmt.Println("Error connecting to server:", err)
		return
	}
	defer conn.Close()

	go receiveMessages(conn)

	fmt.Println("Connected to the server. Type your messages:")

	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		message := scanner.Text()
		_, err := fmt.Fprintf(conn, message+"\n")
		if err != nil {
			fmt.Println("Error sending message:", err)
			return
		}
	}
}
