from gpiozero import Button
from signal import pause
import os

button = Button(2)
switch = Button(18)
stick_y = Button(24)
stick_x = Button(25)

# Button changes mode of operation.
STATE = 0

def change_state():
    STATE = (STATE + 1) % 3
    os.system("clear")

button.when_pressed = change_state

#
def switch_on()
    # Print three dots in a sequence with half a second in between each dot, resetting to no dots when all three dots are printed.


switch.when_pressed = switch_on

pause()