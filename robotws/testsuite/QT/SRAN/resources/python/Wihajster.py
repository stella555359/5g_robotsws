import RPi.GPIO as GPIO
import time
import sys
import json

devices = {
    "nokia": {
        "pin": [
            11
        ],
        "time": 14
    },
    "huawei": {
        "pin": [
            11
        ],
        "time": 2
    },
    "samsung": {
        "pin": [
            11
        ],
        "time": 9
    },
    "oneplus": {
        "pin": [
            11,
            13
        ],
        "time": 15
    },
    "default": {
        "pin": [
            11
        ],
        "time": 4
    },
    "nokia-menu": {
        "pin": [
            11
        ],
        "time": 0.15
    },
    "nokia-unlock": {
        "pin": [
            11
        ],
        "time": 0.01
    },
}


class Servo:
    def __init__(self, pin, pin2=None):
        GPIO.setmode(GPIO.BOARD)
        GPIO.setup(pin, GPIO.OUT)
        GPIO.setwarnings(False)
        self.servo = GPIO.PWM(pin, 50)
        self.servo.start(0)
        print(pin2)
        if pin2 is not None:
            GPIO.setup(pin2, GPIO.OUT)
            self.servo2 = GPIO.PWM(pin2, 50)
            self.servo2.start(0)
        else:
            self.servo2 = False

    def click(self, howLong=0.3):
        time.sleep(1)
        self.servo.ChangeDutyCycle(5)
        if self.servo2:
            self.servo2.ChangeDutyCycle(5)
        time.sleep(0.3)
        self.servo.ChangeDutyCycle(2.5)
        if self.servo2:
            self.servo2.ChangeDutyCycle(2.4)
        time.sleep(0.5)
        time.sleep(howLong)
        self.servo.ChangeDutyCycle(5)
        if self.servo2:
            self.servo2.ChangeDutyCycle(5)
        time.sleep(0.3)
        self.servo.ChangeDutyCycle(0)
        if self.servo2:
            self.servo2.ChangeDutyCycle(0)

    def reboot(self):
        self.click(11)

    def cleanup(self):
        self.servo.stop()
        GPIO.cleanup()


def ServoClick(dev_data, time=0):
    pin = dev_data["pin"][0]
    if len(dev_data["pin"]) > 1:
        pin2 = dev_data["pin"][1]
        print(pin2)
    print("starting servo on pin {}".format(pin))
    if len(dev_data["pin"]) > 1:
        name = Servo(pin, pin2)
    else:
        name = Servo(pin)
    if time == 0:
        time = dev_data["time"]
    print("holding button for {} seconds".format(time))
    name.click(time)
    name.cleanup()


def reboot(devs, time=0):
    for dev_k in devices.keys():
        if dev_k == devs:
            ServoClick(devices[dev_k])


if __name__ == "__main__":
    print("Hello to Wihajster")

    if len(sys.argv) == 2:
        action = sys.argv[1]
        print(action)

        if action == "-l":
            for device in devices:
                print(device)
        elif action == "-r":
            selection = input("which one do you want to reboot?")
            reboot(selection)
        else:
            print("Invalid arguments")
            exit()

    elif len(sys.argv) >= 3 and sys.argv[1] == "-r":
        action = sys.argv[1]
        selection = sys.argv[2]
        print("Rebooting {}".format(selection))
        if len(sys.argv) > 3:
            t = int(sys.argv[3])
            reboot(selection, t)
        else:
            reboot(selection)

    else:
        print("Invalid arguments")
        exit()
