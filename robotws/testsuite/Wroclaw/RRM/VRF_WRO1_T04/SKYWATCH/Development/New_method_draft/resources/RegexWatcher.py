import asyncio
import re
import logging
from random import randint
import datetime
import time
import sys
import os
# import matplotlib.pyplot as plt
import multiprocessing
import queue
import importlib
import subprocess

# Logging setup
log_path = "/home/ute/logs/"
timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
# LOG_FILE = f"{log_path}telnet_watcher_{timestamp}.log"
LOG_FILE = f"telnet_watcher_{timestamp}.log"

logging.basicConfig(
    format='%(asctime)s - %(levelname)s - %(message)s',
    level=logging.DEBUG,
    handlers=[
        logging.FileHandler(LOG_FILE, mode='a'),
        logging.StreamHandler(sys.stdout)
    ]
)

file_logger = logging.getLogger("file_logger")
file_logger.setLevel(logging.DEBUG)
file_handler = logging.FileHandler(LOG_FILE, mode='a')
file_handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
file_logger.addHandler(file_handler)
file_logger.propagate = False


def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])


def import_with_auto_install(packages):
    results = []
    for package in packages:
        try:
            results.append(importlib.import_module(package))
        except ImportError:
            install(package)
            results.append(importlib.import_module(package))
            print("\n\ninstalling: {}\nfinal result = {}".format(package, results))
    return results


class RegexWatcherProcess(multiprocessing.Process):
    """Process responsible for monitoring regex patterns in Telnet output."""
    plt = None

    def __init__(self, regex_queue, result_queue, stats_queue, host, port):
        super().__init__()
        self.regex_queue = regex_queue
        self.result_queue = result_queue
        self.stats_queue = stats_queue
        self.host = host
        self.port = port
        self.regex_patterns = []
        self.running = True
        self.reader = None
        self.writer = None

    async def connect(self):
        """Establishes Telnet connection."""
        try:
            self.reader, self.writer = await asyncio.open_connection(self.host, self.port)
            logging.info(f"[RegexWatcher] Connected to {self.host}:{self.port}")
        except Exception as e:
            logging.error(f"[ERROR] Connection failed: {e}")
            self.running = False

    async def watch_telnet(self):
        """Monitors Telnet output and searches for regex matches."""
        if plt is None:
            plt = import_with_auto_install([matplotlib.pyplot])
        await self.connect()
        if not self.running:
            return
        REGEXP = re.compile(
            "|".join(
                [
                    r"\x1b\[\d{1,3}[lhinc]",
                    r"\x1b\[\d{1,3};\d{1,3}[lhy]",
                    r"\x1b\[\d+[ABCDmgKJPLMincq]",
                    r"\x1b\[\d+;\d+[HfmrR]",
                    r"\x1b\[[HfmKJic]",
                    r"\x1b[DME78=>NOHgZc<ABCDIFGKJ\^_WXV\]]",
                    r"\x1b[()][AB012]",
                    r"\x1b#\d",
                    r"\x1bY\d+",
                    r"\x1b\/Z",
                    r"\x00",
                    r"\x1b\[[0-9;]*[A-Za-z]",
                    r"\r\n",
                ]
            )
        )
        while self.running:
            try:
                while not self.regex_queue.empty():
                    new_pattern = self.regex_queue.get()
                    file_logger.debug(f"[REGEX] New regex added to search list: {new_pattern}")
                    self.regex_patterns.append(new_pattern)
                line = await self.reader.readuntil(b"EGATE>")  # Reading data until "EGATE>"
                if not line:
                    logging.error("[RegexWatcher] Telnet connection closed")
                    break

                decoded = line.decode("ascii", errors="ignore")
                decoded_line = REGEXP.sub("", decoded)
                # file_logger.debug(f"[Telnet Output] {decoded_line}")
                file_logger.debug(f"[Telnet Output] {repr(decoded_line)}")

                self.stats_queue.put(("regex", len(self.regex_patterns)))  # Send regex count
                file_logger.debug(f"[REGEX] Current regex patterns: {len(self.regex_patterns)}")
                for pattern in self.regex_patterns[:]:
                    # file_logger.debug(f"[PATTERN] Searching for {pattern} in {decoded_line}")
                    if re.search(pattern, decoded_line):
                        file_logger.debug(f"[MATCH] Found pattern: {pattern}")
                        self.result_queue.put(pattern)  # Notify Watcher
                        # if pattern in self.waiting_tasks:
                        #     self.waiting_tasks[pattern].set_result(True)
                        #     del self.waiting_tasks[pattern]
                        self.regex_patterns.remove(pattern)

            except Exception as e:
                logging.error(f"[ERROR] Telnet reading error: {e}")
                break

    def run(self):
        """Starts asyncio loop inside the new process."""
        asyncio.run(self.watch_telnet())


class CommandSenderProcess(multiprocessing.Process):
    """Process responsible for sending commands to Telnet."""

    def __init__(self, command_queue, sent_commands_queue, stats_queue, host, port, delay=0.1):
        super().__init__()
        self.command_queue = command_queue
        self.sent_commands_queue = sent_commands_queue
        self.stats_queue = stats_queue
        self.host = host
        self.port = port
        self.delay = delay
        self.running = True
        self.reader = None
        self.writer = None

    async def connect(self):
        """Establishes Telnet connection."""
        try:
            self.reader, self.writer = await asyncio.open_connection(self.host, self.port)
            logging.info(f"[CommandSender] Connected to {self.host}:{self.port}")
        except Exception as e:
            logging.error(f"[ERROR] Connection failed: {e}")
            self.running = False

    async def process_commands(self):
        """Processes the command queue, sending each command immediately."""
        await self.connect()
        if not self.running:
            return

        while self.running:
            try:
                command = self.command_queue.get()
                file_logger.info(f"[CommandSender] Sending command: {command}")

                self.writer.write(command.encode() + b"\n")
                await self.writer.drain()

                self.sent_commands_queue.put(command)
                self.stats_queue.put(("commands", self.command_queue.qsize()))  # Send command count
                if self.command_queue.qsize() % 10 == 0:
                    logging.info(f"[COMMAND_QUEUE] Current size: {self.command_queue.qsize()}")
                await asyncio.sleep(0.05)
            except queue.Empty:
                await asyncio.sleep(0.01)

    def run(self):
        """Starts asyncio loop inside the new process."""
        asyncio.run(self.process_commands())


class Watcher:
    """Manages asyncio tasks that need to run in the main process."""

    def __init__(self, regex_queue, command_queue, result_queue, stats_queue):
        self.regex_queue = regex_queue
        self.command_queue = command_queue
        self.result_queue = result_queue
        self.stats_queue = stats_queue
        self.waiting_tasks = {}
        self.stats = {
            "regex_data": [],
            "command_data": []
        }

    async def manage_tasks(self):
        """Handles regex matches and resolves futures."""
        start_time = time.time()
        last_log_time = start_time

        while True:
            if not self.result_queue.empty():
                matched_pattern = self.result_queue.get()
                # file_logger.info(f"[INFO] Processing matched pattern: {matched_pattern}")

                if matched_pattern in self.waiting_tasks:
                    future = self.waiting_tasks.pop(matched_pattern)
                    if not future.done():
                        # future.set_result(True)
                        asyncio.create_task(self.resolve_future(future, matched_pattern))
                    # if not self.waiting_tasks[matched_pattern].done():
                    #     self.waiting_tasks[matched_pattern].set_result(True)
                    # del self.waiting_tasks[matched_pattern]
            current_time = time.time()
            if current_time - last_log_time >= 5:
                regex_size = self.regex_queue.qsize() if hasattr(self.regex_queue, 'qsize') else "unknown"
                command_size = self.command_queue.qsize() if hasattr(self.command_queue, 'qsize') else "unknown"
                logging.info(f"[QUEUE_STATUS] Regex queue size: {regex_size}")
                logging.info(f"[QUEUE_STATUS] Command queue size: {command_size}")
                last_log_time = current_time

            while not self.stats_queue.empty():
                stat_type, count = self.stats_queue.get()
                timestamp = time.time() - start_time

                if stat_type == "regex":
                    self.stats["regex_data"].append((timestamp, count))
                elif stat_type == "commands":
                    self.stats["command_data"].append((timestamp, count))

            await asyncio.sleep(0.01)

    async def resolve_future(self, future, pattern):
        future.set_result(True)
        file_logger.info(f"[INFO] Future resolved for pattern: {pattern}")

    async def send_command(self, command):
        """Sends a command without waiting for regex."""
        self.command_queue.put(command)
        file_logger.debug(f"[COMMAND] added to queue: {command}")
        while True:
            try:
                sent_command = self.sent_commands_queue.get()
                if sent_command == command:
                    break
                await asyncio.sleep(0.01)
            except queue.Empty:
                await asyncio.sleep(0.01)

    async def wait_for_pattern(self, regex, timeout=10):
        """Waits for a specific regex to appear in the Telnet output."""
        future = asyncio.get_event_loop().create_future()
        self.waiting_tasks[regex] = future
        self.regex_queue.put(regex)
        await asyncio.sleep(0.01)
        # file_logger.debug(f"[REGEX] Started to search for {regex}")
        done, pending = await asyncio.wait([future], timeout=timeout)
        if future in done:
            return True
        else:
            self.waiting_tasks.pop(regex, None)
            return False

        # try:
        #     result = await asyncio.wait_for(future, timeout=timeout)
        #     return result
        # except asyncio.TimeoutError:
        #     logging.error(f"[ERROR] Timeout while waiting for regex: {regex}")
        #     self.waiting_tasks.pop(regex, None)
        #     # self.regex_queue.get(regex)
        #     return False

    # async def wait_with_padding(self, command, regex, total_time, sleep_without_regex=0):
    async def wait_with_padding(self, regex, total_time, sleep_without_regex=0):
        """Sends a command, waits for regex, then waits the remaining time."""
        start_time = time.time()
        await asyncio.sleep(sleep_without_regex)
        success = await self.wait_for_pattern(regex, timeout=total_time)
        elapsed_time = time.time() - start_time

        if success:
            remaining_time = total_time - elapsed_time
            if remaining_time > 0:
                file_logger.info(f"[WAIT] Waiting additional {remaining_time:.2f} seconds.")
                await asyncio.sleep(remaining_time)

    def generate_plot(self):
        try:
            plt = importlib.import_module("matplotlib.pyplot")
        except ModuleNotFoundError:
            subprocess.run(["pip", "install", "matplotlib"], check=True)
            plt = importlib.import_module("matplotlib.pyplot")
        """Generates and saves a plot of regex and command queue sizes over time."""
        plt.figure(figsize=(10, 5))
        plt.xlabel("Time (s)")
        plt.ylabel("Count")
        plt.title("Pending Regex Patterns and Commands")
        logging.getLogger('matplotlib.font_manager').disabled = True

        # Get start time from first recorded entry
        all_timestamps = [t for t, _ in self.stats["regex_data"]] + [t for t, _ in self.stats["command_data"]]
        start_time = min(all_timestamps) if all_timestamps else time.time()

        # Convert absolute timestamps to relative times
        if self.stats["regex_data"]:
            regex_times, regex_counts = zip(*self.stats["regex_data"])
            regex_times = [t - start_time for t in regex_times]
            plt.plot(regex_times, regex_counts, label="Regex Patterns", color="blue")

        if self.stats["command_data"]:
            command_times, command_counts = zip(*self.stats["command_data"])
            command_times = [t - start_time for t in command_times]
            plt.plot(command_times, command_counts, label="Command Queue", color="red")

        plt.legend()

        plot_filename = f"telnet_stats_{timestamp}.png"
        plt.savefig(f"{log_path}{plot_filename}")
        plt.show()

    def stop(self):
        """Stops asyncio tasks and generates the final plot."""
        self.generate_plot()


# if __name__ == "__main__":
# from multiprocessing import Manager

# manager = Manager()
# regex_queue = multiprocessing.Queue()
command_queue = multiprocessing.Queue()
# result_queue = multiprocessing.Queue()
# stats_queue = multiprocessing.Queue()
# sent_commands_queue = multiprocessing.Queue()
regex_queue = multiprocessing.Queue()
# command_queue = asyncio.Queue()
result_queue = multiprocessing.Queue()
stats_queue = multiprocessing.Queue()
sent_commands_queue = multiprocessing.Queue()

regex_watcher = RegexWatcherProcess(regex_queue, result_queue, stats_queue, "localhost", 20000)
command_sender = CommandSenderProcess(command_queue, sent_commands_queue, stats_queue, "localhost", 20000)

watcher = Watcher(regex_queue, command_queue, result_queue, stats_queue)
