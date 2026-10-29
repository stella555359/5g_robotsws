import signal
from robot.api import logger

GREEN = '\033[92m'
WARNING = '\033[93m'
END = '\033[0m'
original_sigint_handler = signal.getsignal(signal.SIGINT)


def signal_turn_off(sig, frame):
    logger.console(WARNING + '\nYou pressed Ctrl+C again, exiting.' + END)
    signal.signal(signal.SIGINT, original_sigint_handler)  # give back control to orig handler (probably robot handler)
    original_sigint_handler(sig, frame)                    # Instead implicit replace You can use context manager.


def signal_stop_logs(sig, frame):
    logger.console(GREEN + '\nYou pressed Ctrl+C, stopping logging.' + END)
    signal.signal(signal.SIGINT, signal_turn_off)


def wait_for_ctrl_c(msg=None):
    if msg is None:
        msg = 'Logging successfully started. Press Ctrl+C to stop logging.'
    signal.signal(signal.SIGINT, signal_stop_logs)
    logger.console(GREEN + '\n' + msg + END)
    signal.pause()
