import socket 
import struct
from pythonosc.udp_client import SimpleUDPClient

host = '0.0.0.0'
port = 8090


sc_ip = "127.0.0.1"
sc_port = 57120
sc_client = SimpleUDPClient(sc_ip, sc_port)

s = socket.socket()
s.bind((host, port))
s.listen(0)
print(f"Listening on {host}:{port}.")
while True:
    client, addr = s.accept()
    
    with client:
        print(f"Connected to {addr}.")
        while True:
            data = client.recv(26)
            if len(data) != 0:
                fh = struct.unpack('ffffffh', data)
                print(f"Received data: {fh}")
                sc_client.send_message("/data", fh)
            else:
                print("Connection closed.")
                break
            
        
        