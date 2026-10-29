import os
import time
from datetime import datetime
import threading
import logging

# Configure journaling with robust error handling
import sys

# Clear any existing handlers to avoid conflicts
for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler)

# Create file handler with better error handling
log_file = "/tmp/pmc_id_timer_service.log"
try:
    # Test write permissions first
    with open(log_file, 'a') as test_file:
        test_file.write("")  # Test write access
    file_handler = logging.FileHandler(log_file, mode='a')
    file_handler.setLevel(logging.DEBUG)
except (PermissionError, IOError) as e:
    print(f"Warning: Cannot write to {log_file}: {e}")
    file_handler = None

# Create console handler
console_handler = logging.StreamHandler(sys.stdout)
console_handler.setLevel(logging.DEBUG)

# Configure formatters
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
if file_handler:
    file_handler.setFormatter(formatter)
console_handler.setFormatter(formatter)

# Configure root logger
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)  # Set to DEBUG for maximum visibility
if file_handler:
    logger.addHandler(file_handler)
logger.addHandler(console_handler)


# Force immediate flush for all handlers
def force_flush_logs():
    for handler in logger.handlers:
        if hasattr(handler, 'flush'):
            handler.flush()


def journaling(method):
    def modified_method(*args, **kwargs):
        try:
            logging.info(f"Method Invoked {method.__name__} with arguments {args} and {kwargs}")
            force_flush_logs()  # Force immediate write
            result = method(*args, **kwargs)
            logging.info(f"Method Result  {method.__name__}: {result}")
            force_flush_logs()  # Force immediate write
            return result
        except Exception as log_error:
            # Fallback to direct file write if logging fails
            fallback_log = f"LOGGING ERROR in {method.__name__}: {log_error}\n"
            try:
                with open("/tmp/pmc_id_timer_service_fallback.log", 'a') as f:
                    f.write(f"{datetime.now()} - {fallback_log}")
            except (PermissionError, IOError, OSError):
                print(fallback_log)  # Last resort: print to stdout
            raise

    return modified_method


def manage_exceptions(method):
    def modified_method(*args, **kwargs):
        try:
            return method(*args, **kwargs)
        except Exception as e:
            logging.error(f"Exception raised in method {method.__name__}: {e}")
            raise

    return modified_method


class PmcIdTimerService:
    def __init__(self, granularity, safe_window_seconds=5):
        # Validate granularity parameter
        try:
            granularity_int = int(granularity)
            if granularity_int <= 0:
                raise ValueError(f"Granularity must be positive, got: {granularity_int}")
            if granularity_int > 60:
                logging.warning(f"Large granularity value ({granularity_int}min) may cause long wait times")
        except (ValueError, TypeError) as e:
            raise ValueError(f"Invalid granularity parameter: {granularity}. Must be a positive integer.") from e

        # Validate safe_window_seconds parameter
        try:
            safe_window_int = int(safe_window_seconds)
            if safe_window_int < 1:
                raise ValueError(f"Safe window must be at least 1 second, got: {safe_window_int}")
            if safe_window_int > 30:
                logging.warning(f"Large safe window ({safe_window_int}s) may cause long wait times")
        except (ValueError, TypeError) as e:
            error_msg = f"Invalid safe_window_seconds parameter: {safe_window_seconds}. "
            error_msg += "Must be a positive integer."
            raise ValueError(error_msg) from e

        os.environ['PM_PERIOD_INDEX'] = '0'
        os.environ['PM_PERIOD_START_DATE'] = ''
        self._stop_event = threading.Event()
        self._lock = threading.Lock()
        self.granularity = granularity_int
        self.safe_window_seconds = safe_window_int

    def _safe_get_pm_index(self):
        """Thread-safe getter for PM_PERIOD_INDEX"""
        with self._lock:
            return int(os.environ['PM_PERIOD_INDEX'])

    def _safe_get_pm_start_date(self):
        """Thread-safe getter for PM_PERIOD_START_DATE"""
        with self._lock:
            return str(os.environ['PM_PERIOD_START_DATE'])

    def _safe_set_pm_values(self, index, start_date):
        """Thread-safe setter for PM values"""
        with self._lock:
            os.environ['PM_PERIOD_INDEX'] = str(index)
            os.environ['PM_PERIOD_START_DATE'] = start_date

    @journaling
    def increment_variable(self, now):
        formatted_time = now.strftime('%Y-%m-%d %H:%M:%S')
        current_value = self._safe_get_pm_index()
        self._safe_set_pm_values(current_value + 1, formatted_time)
        logging.info(f"NEW PM_PERIOD_INDEX : {current_value + 1} PM_START_DATE : {formatted_time}")
        force_flush_logs()  # Ensure critical PM updates are immediately written

    @journaling
    @manage_exceptions
    def check_time_and_increment(self):
        while not self._stop_event.is_set():
            now = datetime.now()

            # Check if we're at a PM period boundary
            if now.minute % self.granularity == 0 and now.second == 0:
                self.increment_variable(now)
                # Sleep 1 second to move past this boundary
                time.sleep(1)
                continue

            # Calculate time until next PM period boundary
            minutes_in_current_period = now.minute % self.granularity
            seconds_in_current_period = minutes_in_current_period * 60 + now.second

            # Time until next boundary in seconds
            period_duration_seconds = self.granularity * 60
            seconds_until_next_boundary = period_duration_seconds - seconds_in_current_period

            # Sleep until just before the boundary (keep 2s margin for precision)
            if seconds_until_next_boundary > 2:
                sleep_duration = seconds_until_next_boundary - 2
                logging.debug(f"Sleeping {sleep_duration}s until ~2s before next PM boundary")
                time.sleep(sleep_duration)
            else:
                # We're close to boundary, check frequently with short sleep
                time.sleep(0.1)

    @journaling
    @manage_exceptions
    def start(self, granularity=None, safe_window_seconds=None):
        if granularity is not None:
            # Validate and update granularity
            try:
                granularity_int = int(granularity)
                if granularity_int <= 0:
                    raise ValueError(f"Granularity must be positive, got: {granularity_int}")
                self.granularity = granularity_int
                logging.info(f"Granularity updated to {self.granularity} minutes")
            except (ValueError, TypeError) as e:
                raise ValueError(f"Invalid granularity parameter: {granularity}. Must be a positive integer.") from e

        if safe_window_seconds is not None:
            # Validate and update safe window
            try:
                safe_window_int = int(safe_window_seconds)
                if safe_window_int < 1:
                    raise ValueError(f"Safe window must be at least 1 second, got: {safe_window_int}")
                self.safe_window_seconds = safe_window_int
                logging.info(f"Safe window updated to {self.safe_window_seconds} seconds")
            except (ValueError, TypeError) as e:
                error_msg = f"Invalid safe_window_seconds parameter: {safe_window_seconds}. "
                error_msg += "Must be a positive integer."
                raise ValueError(error_msg) from e

        # Protection: delay startup if too close to the end of a PM period
        self._wait_for_safe_startup_time()

        # Reset to 0 after delay for a clean start
        self._safe_set_pm_values(0, '')
        logging.info("Timer service started - PM_PERIOD_INDEX reset to 0")

        self.thread = threading.Thread(target=self.check_time_and_increment)
        self.thread.start()

    @journaling
    @manage_exceptions
    def stop(self):
        self._stop_event.set()
        self.thread.join()

    @journaling
    @manage_exceptions
    def wait_for_pm_period_index_target_value(self, target_value):
        # Validate target_value parameter
        try:
            target_value = int(target_value)
            if target_value < 0:
                raise ValueError(f"Target value must be non-negative, got: {target_value}")
        except (ValueError, TypeError) as e:
            error_msg = f"Invalid target_value parameter: {target_value}. "
            error_msg += "Must be a non-negative integer."
            raise ValueError(error_msg) from e

        # Check initial state
        current_value = self._safe_get_pm_index()
        logging.info(f"Waiting for PM period index {target_value}, current value: {current_value}")

        # If current value already exceeds target, handle gracefully
        if current_value > target_value:
            logging.warning(f"Current PM index ({current_value}) already exceeds target ({target_value})")
            logging.info("Continuing with current PM period state")
            return

        while True:
            now = datetime.now()

            # Wait until we're safely past the PM period boundary
            # This avoids reading the index during the critical update window
            aligned_minute = now.minute % self.granularity == 0
            safe_window = now.second >= self.safe_window_seconds  # Wait for configured safe window

            if aligned_minute and safe_window:
                # Multiple reads with delay to ensure consistency
                readings = []
                for _ in range(3):  # Take 3 readings
                    time.sleep(0.2)  # Small delay between reads
                    readings.append(self._safe_get_pm_index())

                # Use the most recent stable reading
                current_value = max(readings)  # Take highest value to avoid stale reads

                logging.info(f"PM period check: current={current_value}, target={target_value}, readings={readings}")

                if current_value == target_value:
                    logging.info(f"Target PM period index {target_value} reached successfully")
                    break
                elif current_value > target_value:
                    logging.warning(f"PM index {current_value} exceeded target {target_value}")
                    logging.info("Continuing with current PM period state")
                    break

                # If we're still below target, wait for next period
                logging.info(f"Current index {current_value} < target {target_value}, waiting for next PM period")

            # Calculate smart sleep time
            if aligned_minute and not safe_window:
                # We're in a PM period but too early - wait until safe window
                sleep_time = self.safe_window_seconds - now.second + 1
                logging.debug(f"In PM period but too early, waiting {sleep_time}s for safe window")
            else:
                # Calculate time until next PM period + safe window
                minutes_until_next = self.granularity - (now.minute % self.granularity)
                if minutes_until_next == self.granularity:  # We're at period boundary
                    minutes_until_next = 0

                seconds_until_next_period = minutes_until_next * 60 - now.second
                sleep_time = seconds_until_next_period + self.safe_window_seconds  # Add configured safe window

                if sleep_time <= 0:
                    sleep_time = self.safe_window_seconds

                # Cap sleep time for responsiveness
                sleep_time = min(sleep_time, 30)

                logging.debug(f"Sleeping {sleep_time}s until next check window")

            time.sleep(sleep_time)

    @journaling
    @manage_exceptions
    def get_pm_period_date_if_current_pm_period_index(self, index):
        current_value = self._safe_get_pm_index()
        int_index = int(index)
        if current_value == int_index:
            current_date = self._safe_get_pm_start_date()
            return current_date

    @journaling
    @manage_exceptions
    def has_enough_time_before_next_pm(self, script_duration_seconds, safety_margin=30):
        """
        Check if there is enough time to run a script before the next PM period starts.

        Args:
            script_duration_seconds: Expected duration of the script in seconds (int or float)
            safety_margin: Safety margin in seconds before PM boundary (default: 30s)

        Returns:
            bool: True if there is enough time to run the script, False otherwise
        """
        # Validate input parameters
        try:
            script_duration = float(script_duration_seconds)
            if script_duration < 0:
                raise ValueError(f"Script duration must be non-negative, got: {script_duration}")
        except (ValueError, TypeError) as e:
            raise ValueError(f"Invalid script_duration_seconds: {script_duration_seconds}. Must be a number.") from e

        try:
            margin = int(safety_margin)
            if margin < 0:
                raise ValueError(f"Safety margin must be non-negative, got: {margin}")
        except (ValueError, TypeError) as e:
            raise ValueError(f"Invalid safety_margin: {safety_margin}. Must be a non-negative integer.") from e

        now = datetime.now()

        # Calculate current position in PM period
        minutes_in_period = now.minute % self.granularity
        seconds_in_period = minutes_in_period * 60 + now.second

        # Calculate time remaining until next PM period (in seconds)
        total_period_seconds = self.granularity * 60
        seconds_until_next_pm = total_period_seconds - seconds_in_period

        # Calculate total time needed (script duration + safety margin)
        total_time_needed = script_duration + margin

        # Check if we have enough time
        has_time = seconds_until_next_pm >= total_time_needed

        logging.info(
            f"Time check: {seconds_until_next_pm}s until next PM, "
            f"need {total_time_needed}s (script: {script_duration}s + margin: {margin}s) "
            f"-> {'OK' if has_time else 'NOT ENOUGH TIME'}"
        )

        return has_time

    @journaling
    def _wait_for_safe_startup_time(self):
        """
        Protection to delay service start if too close to PM period boundary.
        Waits until next PM period + safety margin to avoid race conditions.
        """
        now = datetime.now()
        minutes_in_period = now.minute % self.granularity
        seconds_in_period = minutes_in_period * 60 + now.second

        # Calculate time left in seconds before beginning of next PM period
        total_period_seconds = self.granularity * 60
        seconds_remaining = total_period_seconds - seconds_in_period

        # If time left in present PM period is less than 30 seconds, wait for next period
        safety_margin = 30
        if seconds_remaining < safety_margin:
            wait_time = seconds_remaining + 10  # Wait until next period + 10s safety
            logging.info(f"Startup too close to PM period end - {seconds_remaining}s remaining")
            logging.info(f"Deferring startup by {wait_time}s (next period + 10s safety)")
            time.sleep(wait_time)

            # Log after waiting to confirm
            new_now = datetime.now()
            logging.info(f"Safe startup time reached at {new_now.strftime('%Y-%m-%d %H:%M:%S')}")
        else:
            logging.info(f"Safe startup time - {seconds_remaining}s remaining in current PM period")
