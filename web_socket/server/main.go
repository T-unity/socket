package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

// WebSocketのアップグレーダ
var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

// クライアントを管理するための構造体
type Client struct {
	conn *websocket.Conn
	send chan []byte
}

// メッセージをブロードキャストするためのハブ
type Hub struct {
	clients    map[*Client]bool
	broadcast  chan []byte
	register   chan *Client
	unregister chan *Client
}

func newHub() *Hub {
	return &Hub{
		clients:    make(map[*Client]bool),
		broadcast:  make(chan []byte),
		register:   make(chan *Client),
		unregister: make(chan *Client),
	}
}

func (h *Hub) run() {
	for {
		select {
		case client := <-h.register:
			h.clients[client] = true
			log.Printf("Client registered: %v", client.conn.RemoteAddr())
		case client := <-h.unregister:
			if _, ok := h.clients[client]; ok {
				delete(h.clients, client)
				close(client.send)
				log.Printf("Client unregistered: %v", client.conn.RemoteAddr())
			}
		case message := <-h.broadcast:
			log.Printf("Broadcasting message: %s", message)
			for client := range h.clients {
				select {
				case client.send <- message:
					log.Printf("Sent message to client: %v", client.conn.RemoteAddr())
				default:
					close(client.send)
					delete(h.clients, client)
					log.Printf("Failed to send message, client removed: %v", client.conn.RemoteAddr())
				}
			}
		}
	}
}

func (c *Client) readPump(h *Hub) {
	defer func() {
		h.unregister <- c
		c.conn.Close()
	}()
	for {
		_, message, err := c.conn.ReadMessage()
		if err != nil {
			log.Println("Read error:", err)
			break
		}
		log.Printf("Message received: %s", message)
		h.broadcast <- message
	}
}

func (c *Client) writePump() {
	for message := range c.send {
		err := c.conn.WriteMessage(websocket.TextMessage, message)
		if err != nil {
			log.Println("Write error:", err)
			break
		}
		log.Printf("Message sent: %s", message)
	}
}

func wsHandler(h *Hub, w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("Upgrade error:", err)
		return
	}
	client := &Client{conn: conn, send: make(chan []byte, 256)}
	h.register <- client

	go client.writePump()
	client.readPump(h)
}

// CSPヘッダーを追加するミドルウェア
func addCSP(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// CSPヘッダーを設定
		w.Header().Set("Content-Security-Policy", "connect-src 'self' ws://localhost:8080")
		log.Println("CSP header added")
		next.ServeHTTP(w, r)
	})
}

func main() {
	hub := newHub()
	go hub.run()

	http.Handle("/ws", addCSP(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		wsHandler(hub, w, r)
	})))
	fmt.Println("Server started on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}