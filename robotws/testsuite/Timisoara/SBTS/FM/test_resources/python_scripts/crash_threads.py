from threading import Thread
import time

"""This script is for simulating a crash with to many threads open."""


def time_sleep():
    time.sleep(100)


if __name__ == '__main__':
    for i in range(100000):
        print(f'loop {i}')
        t = Thread(target=time_sleep)
        t.start()
