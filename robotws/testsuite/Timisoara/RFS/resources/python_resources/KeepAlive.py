from threading import Thread, Event
import time
from robot.libraries.BuiltIn import BuiltIn
import logging
from collections import defaultdict

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


class KeepAliveThread(Thread):
    def __init__(self):
        super().__init__()
        self.stop_event = Event()
        self.library_instance = None
        self.library_name = ""
        self.alias = ""
        self.username = ""
        self.password = ""

    def run(self):
        while not self.stop_event.is_set():
            connection_type = 'vdu_connection' if self.library_name == 'vdu' else 'connection'
            self.library_instance.refresh_token(username=self.username, password=self.password,
                                                **{connection_type: self.alias})
            for _ in range(12):
                time.sleep(10)
                if self.stop_event.is_set():
                    break

    def stop(self):
        self.stop_event.set()

    def start_keepalive(self, library, alias, username, password):
        self.library_instance = BuiltIn().get_library_instance(library)
        self.library_name = library
        self.alias = alias
        self.username = username
        self.password = password
        self.start()


class KeepAlive:
    def __init__(self):
        self.keepalive_threads = defaultdict(dict)

    def start_keepalive(self, library, alias, username, password):
        self.keepalive_threads[library][alias] = KeepAliveThread()
        self.keepalive_threads[library][alias].start_keepalive(library, alias, username, password)
        logging.info(f'Keepalive started - {library}, on {alias}')

    def stop_keepalive(self, library, alias):
        self.keepalive_threads[library][alias].stop()
        logging.info(f'Keepalive stopped - {library}, on {alias}')
