## KOOBLOO code

This is the code for the Module 2 Task 2. I made a musical box that outputs sound by connecting directly to a speaker using the DAC pin on the ESP32.

Once all your connections are in order according to the top of the code, you can upload to the ESP32 and play with the music. It's nothing too complicated.

There is some code in there for using the stack and queue. In case you want to use it, uncomment the commented code, comment the `plus` section of the main loop (if you wish, i don't know, i'm just a README), and make the buttons push and pop from the queue. It should be pretty straightforward given that I have functions for both written already. If you want the ESP32 to start with a populated stack of known frequencies, that's possible, too! The example I give here is Mary Had A Little Lamb.

By the way, here's some useful measurements I took using the DAC functions:
| Digital Value  | Voltage output |
| ------------- |-------------|
|0 | 0.07V |
|64 | 0.84V|
|128 | 1.61V|
|192 | 2.39V|
|255 | 3.17V|
I found a program doing the same thing for these numbers online, but these are the ones for MY ESP32.
