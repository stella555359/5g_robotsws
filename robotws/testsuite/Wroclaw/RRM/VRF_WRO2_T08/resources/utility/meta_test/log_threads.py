import gc
from threading import Thread


class GatheringThread(Thread):
    def __init__(self, gather_fn, iterations, log_queue):
        super().__init__(name="Gathering Thread")
        self._gather_fn = gather_fn
        self._iterations = iterations
        self._log_queue = log_queue
        self._keep_gathering = True
        self._exc = None

    def run(self):
        self._exc = None
        try:
            self.gather_logs(iterations=self._iterations)
        except BaseException as e:
            self._exc = e

    def join(self, timeout=None):
        Thread.join(self, timeout)
        if self._exc is not None:
            raise self._exc

    def gather_logs(self, iterations):
        try:
            for i in iterations:
                if not self._keep_gathering:
                    print("Log gathering stopped")
                    break
                logs = self._gather_fn(i)
                self._log_queue.put(logs)
        finally:
            self._log_queue.put(None)

    def stop(self):
        self._keep_gathering = False


class AnalysisThread(Thread):
    def __init__(self, analysis_fn, log_queue):
        super().__init__(name='Analysis Thread')
        self._analysis_fn = analysis_fn
        self._log_queue = log_queue
        self._exc = None
        self.outcome = None

    def run(self):
        self._exc = None
        try:
            self.analyze_logs()
        except BaseException as e:
            self._exc = e

    def join(self, timeout=None):
        Thread.join(self, timeout)
        if self._exc is not None:
            raise self._exc

    def analyze_logs(self):
        while True:
            gc.collect()
            logs = self._log_queue.get()
            if logs is None:
                return
            self.outcome = self._analysis_fn(logs)
