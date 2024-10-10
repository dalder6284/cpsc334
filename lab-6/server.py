import socket 

host = '0.0.0.0'
port = 10000


server_socket = socket.socket()
server_socket.bind((host, port))
server_socket.listen(0)

print(f"Listening on {host}:{port}")

while True:
    client_socket, addr = server_socket.accept()
    print(f"Connection from {addr}")
    
    while True:
        data = client_socket.recv(1024)
        if not data:
            break
        print(f"Received {data}")
    
    client_socket.close()
    print(f"Connection closed from {addr}")