import sys
from threading import Thread, RLock


class KpiThread(Thread):
    # This is the Qt event loop thread.
    # All Qt objects have to be created in this thread

    # Methods
    def __init__(self, pKpiContainer):
        Thread.__init__(self)
        self.kpiContainer_ = pKpiContainer

    def __del__(self):
        # self.wait()
        None

    def run(self):
        # FOR ENABLE BREAKPOINT IN THREAD BEGIN
        # import pydevd
        # pydevd.connected = True
        # pydevd.settrace(suspend=False)
        # FOR ENABLE BREAKPOINT IN THREAD END
        print("Kpi container loop thread started")
        sys.exit(self.kpiContainer_.processComponentConcurrent())
