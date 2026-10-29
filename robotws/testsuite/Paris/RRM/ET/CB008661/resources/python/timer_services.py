import os
import time
from datetime import datetime
import threading
import logging

# Configure journaling
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    handlers=[logging.FileHandler("/tmp/pmc_id_timer_service.log"),
                              logging.StreamHandler()])


def journaling(method):
    def modified_method(*args, **kwargs):
        logging.info(f"Method Invoked {method.__name__} with arguments {args} and {kwargs}")
        result = method(*args, **kwargs)
        logging.info(f"Method Result  {method.__name__}: {result}")
        return result

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
    def __init__(self, granularity):
        os.environ['PM_PERIOD_INDEX'] = '0'
        self._stop_event = threading.Event()
        self._lock = threading.Lock()
        self.granularity = int(granularity)

    @journaling
    def increment_variable(self):
        with self._lock:
            current_value = int(os.environ['PM_PERIOD_INDEX'])
            os.environ['PM_PERIOD_INDEX'] = str(current_value + 1)
            logging.info(f"NEW INCREMENT PM_PERIOD_INDEX : {os.environ['PM_PERIOD_INDEX']} DATE : {datetime.now()}")

    @journaling
    @manage_exceptions
    def check_time_and_increment(self):
        while not self._stop_event.is_set():
            now = datetime.now()
            if now.minute % self.granularity == 0 and now.second == 0:
                self.increment_variable()
                # Wait for to next Pm period granularity
                time.sleep(self.granularity - now.second)
            else:
                # Wait one more seconf cause calculation is still on previous second: second 59
                time.sleep(1)

    @journaling
    @manage_exceptions
    def start(self, granularity=None):
        if granularity is not None:
            self.granularity = int(granularity)  # reset self.granularity value  as int
        self.thread = threading.Thread(target=self.check_time_and_increment)
        self.thread.start()

    # def start(self):
    #     self.thread = threading.Thread(target=self.check_time_and_increment)
    #     self.thread.start()

    @journaling
    @manage_exceptions
    def stop(self):
        self._stop_event.set()
        self.thread.join()

    @journaling
    @manage_exceptions
    def wait_for_pm_period_index_target_value(self, target_value):
        target_value = int(target_value)
        while True:
            now = datetime.now()
            if now.minute % self.granularity == 0 and now.second == 1:
                current_value = int(os.environ['PM_PERIOD_INDEX'])
                if current_value >= target_value:
                    break
            # Calculer le temps restant jusqu'à la prochaine vérification
            next_check = (self.granularity - (now.minute % self.granularity)) * 60 + (1 - now.second)
            if next_check <= 0:
                next_check += self.granularity * 60  # Ajouter granularity in seconds
            time.sleep(next_check)
