import socket
import struct
import select
import time

def start_server(host='0.0.0.0', port=8090, timeout=20):
    # Create a TCP/IP socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind((host, port))
    server_socket.listen()
    print(f"[LISTENING] Server is listening on {host}:{port}")

    # Dictionary to keep track of connected sockets and their last activity time
    clients = {}
    
    try:
        while True:
            # Use select to wait for I/O events
            read_sockets, _, _ = select.select([server_socket] + list(clients.keys()), [], [])

            # Check for timeouts
            current_time = time.time()
            for sock in list(clients.keys()):
                if current_time - clients[sock] > timeout:
                    print(f"[TIMEOUT] {sock.getpeername()} has timed out.")
                    sock.close()  # Close the socket
                    del clients[sock]  # Remove the client from the list

            for sock in read_sockets:
                # If the server socket is readable, it means there's a new connection
                if sock is server_socket:
                    client_socket, addr = server_socket.accept()
                    clients[client_socket] = current_time  # Initialize last activity time
                    print(f"[NEW CONNECTION] {addr} connected.")
                else:
                    # If a client socket is readable, it may have sent data
                    try:
                        data = sock.recv(1024)
                        if data:
                            # Print the received data from the client
                            print(f"[RECEIVED] {struct.unpack('ffffffh', data)} from {sock.getpeername()}")
                            clients[sock] = current_time  # Update last activity time
                        else:
                            # No data means the client has disconnected
                            raise ConnectionResetError
                    except (ConnectionResetError, BrokenPipeError):
                        print(f"[DISCONNECTED] {sock.getpeername()} disconnected.")
                        sock.close()  # Clean up the socket
                        del clients[sock]  # Remove the disconnected client from the list

    except KeyboardInterrupt:
        print("[SHUTTING DOWN] Server is shutting down.")
    finally:
        server_socket.close()  # Ensure the server socket is closed on shutdown

if __name__ == "__main__":
    start_server()
