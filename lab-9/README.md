# Lab 9 Log


1. How are peers/primary being created/discovered (function name and/or line number): explain
Peers are discovered through via the ESP32NOW library, but the way they are established is handled by the `register_new_peer` callback. The primary is determined by comparing the priorities of your peers and yourself, assigning the primary to the individual with the highest priority.
2. How are MAC addresses being communicated? (function name and/or line number)
At `ESP_NOW.onNewPeer(register_new_peer, NULL)`, we specify a callback function that is passed the info of the message received from the new peer along with some information about the peer. Here, the MAC address can be seen as a series of bytes in the `src_addr` field of the `esp_now_recv_info_t` struct pointer `*info`.
3. How many total peers are possible? (EASY)
You can have a maximum of total 20 peers.
4. What effect does “channel” have?
Channels define the frequency that the ESP32s use to communicate. Choosing a less congested WiFi channel can help 
5. How does each peer send messages to: (function name and/or line number) 
    1. other peers
    The `ESP_NOW_Network_Peer` class has a `send_message` function that sends a message to the specified peer denoted by that class object. For example, if I wanted to broadcast a message, I would call `broadcast_peer.send_message(...)`. If I was the primary, I would send a message to every peer by looping through my peers and calling `peer.send_message` to all of them.
    2. the primary esp32
    If I wanted to send to the primary, I would call `primary_peer.send_message(...)`.
6. How would you edit this code to send some data interactively (via button press, for example)?
You would change the data sent between the primary and the nodes so that the primary sends data to nodes that corresponds to the state we want to change in the nodes. The nodes then parse that data and then change their state based on that (e.g. an LED turns on or off based on the data received from the primary).
7. What here is unnecessary for our purposes?
If you're just communicating between two peers, you don't need all the primary deciding logic. You don't need to generate random data and average it. All you need to do is leverage the API for sending and receiving data so that one peer receives a value and the other one sends. That way, the receiving peer changes the state of its peripherals based on the changing state of the peripherals of the sending peer. It essentially becomes the same thing as any other interactive ESP32 program except with the extra step of sending and parsing data.