from datetime import datetime
import time
import argparse


def do_something():
    print('just do this!')


def calculate_wait_time(interval=15):
    current_time = datetime.now()
    current_hour = current_time.hour
    print('current time is {}, current hour is {}'.format(current_time, current_hour))
    current_min = current_time.minute
    current_sec = current_time.second
    scope = {}
    wait_secs = 0
    for i in range(interval, 61, interval):
        scope[str(i // interval-1)] = i
    print(scope)

    if current_min % interval == 0 and current_sec == 0:
        wait_secs = 0
    else:
        for i, j in scope.items():
            if j - interval <= current_min < j:
                wait_secs = (j - current_min) * 60 - current_sec
    return wait_secs


def main():
    # CLI
    parser = argparse.ArgumentParser(
        description="calculate the sleep length to reach the next sharp point of min and sec.")
    parser.add_argument(
        "interval",
        help="2, 3, 5, 10, 15, etc.")
    args = parser.parse_args()
    interval = int(args.interval)
    print("Before:{}".format(datetime.now()))
    time.sleep(calculate_wait_time(interval=interval))
    do_something()
    print("After:{}".format(datetime.now()))


if __name__ == '__main__':
    main()
