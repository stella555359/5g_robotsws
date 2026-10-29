from collections import defaultdict
from contextvars import ContextVar
import asyncio
import re
import logging
from random import randint
import datetime
import time
import sys
import os
import importlib
import subprocess
from helpful_scripts.utilities import get_robot_output_dir


# timestamp = datetime.datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
_max_reached_scen = None
_max_reached = None
_cell_map = None
_default_5qi_map = None
_locks = None
# locks = defaultdict(asyncio.Lock)
_timestamp = None
_logger = None
_file_logger = None
_log_path = None
_log_file = None
_csv_file_timings = None
# _plot_filename = None
_plt_path = None
_watcher = None
_task_timings = None
_run_counts = None
current_error_counter = ContextVar("current_error_counter")


class Proxy:
    def __init__(self, getter):
        # getter: funkcja bezargumentowa, która zwraca aktualny obiekt
        object.__setattr__(self, "_getter", getter)
        # self._getter = getter

    def _get_target(self):
        getter = object.__getattribute__(self, "_getter")
        # getter = getattr(self, "_getter", None)
        if not callable(getter):
            raise RuntimeError("Proxy getter must be callable and return the target")
        return getter()

    def __getattr__(self, name):
        target = self._get_target()
        return getattr(target, name)

    def __setattr__(self, name, value):
        if name == "_getter":
            object.__setattr__(self, name, value)
        else:
            setattr(self._get_target(), name, value)

    def __delattr__(self, name):
        delattr(self._get_target(), name)

    def __call__(self, *args, **kwargs):
        """
        Call proxied object only if is callable itself
        Else raise clear error
        """
        target = self._get_target()
        if not callable(target):
            raise TypeError(f"Proxied object of type {type(target).__name__} is not callable")
        return target(*args, **kwargs)

    def __repr__(self):
        try:
            target = self._get_target()
            return f"<Proxy to {target!r}>"
        except Exception:
            return "<Proxy (uninitialized)>"

    def __getitem__(self, key):
        return self._get_target()[key]

    def __setitem__(self, key, value):
        self._get_target()[key] = value


def set_log_file(base_path="/home/ute/logs/"):
    global _log_file, _log_path, _timestamp, _csv_file_timings, _plt_path, _locks, _logger, _file_logger, _max_reached
    global _task_timings, _run_counts, _cell_map, _default_5qi_map, _max_reached_scen
    _max_reached = asyncio.Event()
    _max_reached_scen = asyncio.Event()
    _locks = defaultdict(asyncio.Lock)
    _timestamp = datetime.datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    base_path = get_robot_output_dir() or base_path
    _log_path = f"{base_path}{_timestamp}/"
    _log_file = f"{_log_path}telnet_watcher_{_timestamp}.log"
    _csv_file_timings = f"{_log_path}telnet_watcher_{_timestamp}_timings.csv"
    # _plot_filename = f"telnet_stats_{_timestamp}.png"
    _plt_path = f"{_log_path}telnet_stats_{_timestamp}.png"
    os.makedirs(_log_path, exist_ok=True)
    _logger = _get_logger()
    _file_logger = _get_file_logger()
    _task_timings = {}
    _run_counts = {}
    _cell_map = {
        1: {"band": "n71", "technology": "FDD", "meas_id": 5},
        2: {"band": "n71", "technology": "FDD", "meas_id": 5},
        21: {"band": "n25", "technology": "FDD", "meas_id": 3},
        22: {"band": "n25", "technology": "FDD", "meas_id": 3},
        201: {"band": "n41", "technology": "TDD", "meas_id": 4},
        202: {"band": "n41", "technology": "TDD", "meas_id": 4},
        211: {"band": "n41", "technology": "TDD", "meas_id": 4},
        212: {"band": "n41", "technology": "TDD", "meas_id": 4}
    }
    _default_5qi_map = {
        6: {"qos_flow": 1},
        5: {"qos_flow": 2},
        1: {"qos_flow": 3},
        9: {"qos_flow": 4},
        128: {"qos_flow": 5},
        7: {"qos_flow": 6},
        2: {"qos_flow": 7},
        None: {"qos_flow": None}
    }


def get_cell_map():
    return _cell_map


def get_5qi_map():
    return _default_5qi_map


def get_task_timings():
    return _task_timings


def get_run_counts():
    return _run_counts


def get_locks():
    return _locks


def get_plt_path():
    return _plt_path


def get_log_path():
    return _log_path


def get_timestamp():
    return _timestamp


def get_csv_timings():
    return _csv_file_timings


def get_max_reached():
    return _max_reached


def get_max_reached_scen():
    return _max_reached_scen


def _get_logger():
    global _logger, _log_file
    if _logger is None:
        if _log_file is None:
            raise RuntimeError("LOG_FILE not been set before creating file logger")
        _root_logger = logging.getLogger()
        _logger = logging.getLogger("logger")
        _logger.setLevel(logging.DEBUG)
        has_robot_handler = any("robot" in str(h).lower() for h in _root_logger.handlers)
        if has_robot_handler:
            if not any(isinstance(h, logging.FileHandler) for h in _logger.handlers):
                fh = logging.FileHandler(_log_file, mode="a")
                fh.setLevel(logging.DEBUG)
                fh.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
                _logger.addHandler(fh)
                _logger.propagate = True
        else:
            logging.basicConfig(
                format='%(asctime)s - %(levelname)s - %(message)s',
                level=logging.DEBUG,
                handlers=[
                    logging.FileHandler(_log_file, mode='a'),
                    logging.StreamHandler(sys.stdout)
                ]
            )
    # print(f"Logger handlers: {_logger}, {_logger.handlers}")
    return _logger


def _get_file_logger():
    global _file_logger, _log_file
    if _file_logger is None:
        if _log_file is None:
            raise RuntimeError("LOG_FILE not been set before creating file logger")
        _file_logger = logging.getLogger("file_logger")
        _file_logger.setLevel(logging.DEBUG)
        _file_handler = logging.FileHandler(_log_file, mode='a')
        _file_handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
        _file_logger.addHandler(_file_handler)
        _file_logger.propagate = False
    # print(f"File Logger handlers: {_file_logger}, {_file_logger}")
    return _file_logger


def reset_loggers():
    global _logger, _file_logger, _log_file, _log_path, _timestamp, _csv_file_timings, _plt_path, _locks, _max_reached
    global _task_timings, _run_counts, _cell_map, _default_5qi_map, _max_reached_scen
    for lg in (_logger, _file_logger):
        if lg is not None:
            for h in lg.handlers[:]:
                lg.removeHandler(h)
                h.close()
    _logger = None
    _file_logger = None
    _log_file = None
    _log_path = None
    _timestamp = None
    _csv_file_timings = None
    _plt_path = None
    _locks = None
    _task_timings = None
    _run_counts = None
    _cell_map = None
    _default_5qi_map = None
    _max_reached = None
    _max_reached_scen = None


timestamp = Proxy(get_timestamp)
log_path = Proxy(get_log_path)
logger = Proxy(_get_logger)
file_logger = Proxy(_get_file_logger)
CSV_FILE_TIMINGS = Proxy(get_csv_timings)
plt_path = Proxy(get_plt_path)
locks = Proxy(get_locks)
task_timings = Proxy(get_task_timings)
run_counts = Proxy(get_run_counts)
cell_map = Proxy(get_cell_map)
default_5qi_map = Proxy(get_5qi_map)
max_reached = Proxy(get_max_reached)
max_reached_scen = Proxy(get_max_reached_scen)


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


class TelnetCommandSender:
    """Class used to send commands stored FIFO"""
    def __init__(self, writer, stats, delay=0.1, ):
        self.writer = writer
        self.commands = asyncio.Queue()
        self.pending_commands = {}    # mapping: command -> asyncio Event
        self.delay = delay
        self.stats = stats

    async def send_command(self, command):
        event = asyncio.Event()
        self.pending_commands[command] = event

        await self.commands.put(command)
        file_logger.info(f"[COMMAND] Added command to send: {command}")
        await event.wait()

    async def process_commands(self):
        """Send commands from queue without blocking"""
        while True:
            try:
                # logging.info(f"[PENDING] commands pending: {self.commands.qsize()}")
                # file_logger.info(f"[PENDING] commands pending: {list(self.commands._queue)}")
                self.stats["command_data"].append((time.time(), self.commands.qsize()))
                command = await self.commands.get()
                self.writer.write(command.encode() + b"\n")
                await self.writer.drain()
                file_logger.info(f"Successfully sent command to telnet: {command}")
                if command in self.pending_commands:
                    self.pending_commands[command].set()  # unlocking awaiting task
                    del self.pending_commands[command]   # deleting because task already done
                await asyncio.sleep(0.03)
            except ConnectionResetError:
                print("Connection lost, task stopped cleanly")


class RegexWatcherTelnet:
    def __init__(self, host, port):
        """Telnet monitoring object initialization."""
        self.host = host
        self.port = port
        self.regex_patterns = []  # List of patterns to find
        self.waiting_tasks = {}   # Dict of awaiting syncio tasks
        self.running = True       # Flag controlling running
        self.reader = None        # Telnet data stream
        self.command_sender = None
        self.stats = {
            "regex_data": [],
            "command_data": []
        }

    async def connect(self):
        """Telnet connection establish."""
        try:
            self.reader, self.writer = await asyncio.open_connection(self.host, self.port)
            logger.info(f"[DEBUG] Connected to {self.host}:{self.port}")
            self.command_sender = TelnetCommandSender(self.writer, self.stats)
            asyncio.create_task(self.command_sender.process_commands())
        except Exception as e:
            logger.warning(f"[ERROR] Couldn't connect: {e}")
            self.running = False  # Turning off watcher if connection not possible

    async def add_pattern(self, pattern):
        """Adds new pattern to watch for."""
        if pattern in self.waiting_tasks:
            return self.waiting_tasks[pattern]
        fut = asyncio.get_event_loop().create_future()
        self.waiting_tasks[pattern] = fut
        self.regex_patterns.append(pattern)
        file_logger.info(f"[DEBUG] Added regex: {pattern}")

        return fut

    async def wait_for_pattern(self, pattern, timeout=None, output=True, sleep_without_regex=None):
        """Waits for pattern finding in telnet."""
        if sleep_without_regex:
            await asyncio.sleep(sleep_without_regex)
        if pattern not in self.regex_patterns:
            fut = await self.add_pattern(pattern)
        try:
            start_time = time.time()
            result = await asyncio.wait_for(fut, timeout=timeout)
            elapsed_time = time.time() - start_time
            file_logger.info(f"[MATCH][In: {elapsed_time:2f}s] Found pattern: {pattern}")
            return result
        except asyncio.CancelledError:
            logger.warning(f"[BREAK] Task awaiting for {pattern} has been cancelled")
            raise
        except asyncio.TimeoutError:
            if output:
                logger.error(f"[ERROR] Not found pattern '{pattern}' in time {timeout} seconds.")
            counter = current_error_counter.get(None)
            if counter:
                counter["errors"] += 1
            if pattern in self.waiting_tasks:
                del self.waiting_tasks[pattern]
            if pattern in self.regex_patterns:
                self.regex_patterns.remove(pattern)
            return False

    async def wait_with_padding(self, pattern, total_time, sleep_without_regex=0):
        start_time = time.time()
        await asyncio.sleep(sleep_without_regex)
        try:
            found = await self.wait_for_pattern(pattern, timeout=total_time, output=False)
            elapsed_time = time.time() - start_time
            remaining_time = max(0, total_time - elapsed_time)
            if found:
                file_logger.info(f"Regex found after {elapsed_time:.2f}s, waiting next {remaining_time:2f}s...")
                await asyncio.sleep(remaining_time)
            else:
                logger.error(f"[ERROR] Not found pattern '{pattern}' in time {total_time}s")
            return found
        except asyncio.CancelledError:
            raise

    async def watch_telnet(self):
        """Watches telnet session to find regex matches, reading line-by-line."""
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

                await asyncio.sleep(0)
                # logging.info(f"[PENDING] Patterns active: {len(self.regex_patterns)}")
                self.stats["regex_data"].append((time.time(), len(self.regex_patterns)))
                line = await self.reader.readuntil(b"EGATE>")  # Reading data until "EGATE>"
                if not line:
                    logger.error("[ERROR] Telnet connection has been closed")
                    break
                decoded_line = line.decode("ascii", errors="ignore")
                decoded_line = REGEXP.sub("", decoded_line)

                file_logger.debug(f"[DEBUG] Telnet line received: {repr(decoded_line)}")

                for pattern in self.regex_patterns[:]:
                    match = re.search(pattern, decoded_line)
                    if match:
                        # file_logger.info(f"[MATCH] Found pattern: {pattern}")
                        fut = self.waiting_tasks.pop(pattern)
                        self.regex_patterns.remove(pattern)

                        # del self.waiting_tasks[pattern]
                        # break  # If found pattern breaks
                        fut.set_result(match)

            except asyncio.CancelledError:
                raise

            except Exception as e:
                logger.error(f"[ERROR] Error during telnet data reading: {e}")
                break

    async def send_command(self, command):
        """Directs command to TelnetCommandSender"""
        if self.command_sender:
            try:
                await self.command_sender.send_command(command)
            except asyncio.CancelledError:
                raise

    def generate_plot(self):
        try:
            plt = importlib.import_module("matplotlib.pyplot")
        except ModuleNotFoundError:
            subprocess.run(["pip", "install", "matplotlib"], check=True)
            plt = importlib.import_module("matplotlib.pyplot")
        if not self.stats["regex_data"] and not self.stats["command_data"]:
            print("No data collected for creating plot")
            return

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
        plt.savefig(plt_path._get_target())

    async def start_watching_telnet(self):
        self._task = asyncio.create_task(self.watch_telnet())
        return self._task

    async def stop(self):
        """Stops telnet watching and closes connection."""
        logger.info("[DEBUG] Stopping RegexWatcherTelnet...")
        self.running = False
        if self.writer:
            self.writer.close()
            await self.writer.wait_closed()
            logger.info("[DEBUG] Closed telnet connection.")
        if self._task and not self._task.done():
            self._task.cancel()
            try:
                await self._task
            except asyncio.CancelledError:
                pass

        self.generate_plot()


async def reset_watcher():
    global _watcher
    if _watcher is not None:
        if hasattr(_watcher, "stop"):
            try:
                await _watcher.stop()
            except Exception as e:
                print(f"Watcher stop failed: {e}")
        _watcher = None


def get_watcher():
    global _watcher
    if _watcher is None:
        _watcher = RegexWatcherTelnet("localhost", 20000)
    return _watcher


watcher = Proxy(get_watcher)
