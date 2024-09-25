from gpiozero import Button
from signal import pause
import os
import time

os.system("clear")  

button = Button(2)
switch = Button(18)
stick_y = Button(24)
stick_x = Button(25)

switch_pressed = False
state = 0

def handle_button():
    global state
    state = (state + 1) % 3

def switch_on():
    global switch_pressed
    global state
    if state == 0:
        print('A') 
    elif state == 1:
        print('B')
    else:
        print('C')

def stick_y_on():
    global switch_pressed
    global state
    if state == 0:
        print('.') 
    elif state == 1:
        print('!')
    else:
        print('?')

def stick_x_on():
    global switch_pressed
    global state
    if state == 0:
        print('<') 
    elif state == 1:
        print('>')
    else:
        print('=')

button.when_pressed = handle_button
stick_y.when_pressed = stick_y_on
stick_x.when_pressed = stick_x_on

switch.when_pressed = switch_on


pause()