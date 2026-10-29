from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.decorators import continue_on_failure
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger
from .robot_library import RobotLibrary


class Teardown(RobotLibrary):
    verbose = False

    def __init__(self, verbose=False):
        if self._library_initiation_guard():
            return
        self.verbose = verbose
        self._suite_teardown_callbacks = {}
        self._test_teardown_callbacks = {}

    def _teardown(self, teardown_kind='suite'):
        callbacks = self._test_teardown_callbacks if teardown_kind == 'test' else self._suite_teardown_callbacks
        logger.info(f"Initiating {teardown_kind} teardown with {len(callbacks)} steps: {list(callbacks.keys())}",
                    also_to_console=self.verbose)
        failed = []
        for name, (callback, args) in reversed(list(callbacks.items())):
            _, result = callback(*args)
            if result is False:
                failed.append(name)
        assert not failed, f"{teardown_kind.capitalize()} teardown encountered error in following functions:" \
                           f" {failed}. Inspect log for details"

    def schedule(self, name, callback, args, scope='test', exceptions=Exception):
        if scope == 'test':
            self.schedule_test_teardown_function(name, callback, args, exceptions)
        else:
            self.schedule_suite_teardown_function(name, callback, args, exceptions)

    def recall(self, name, scope='test'):
        if scope == 'test':
            self.recall_test_teardown_function(name)
        else:
            self.recall_suite_teardown_function(name)

    def recall_test_teardown_function(self, name):
        if name in self._test_teardown_callbacks:
            del self._test_teardown_callbacks[name]

    def recall_suite_teardown_function(self, name):
        if name in self._suite_teardown_callbacks:
            del self._suite_teardown_callbacks[name]

    def schedule_suite_teardown_function(self, name, callback, args, exceptions=Exception):
        self._suite_teardown_callbacks[name] = (continue_on_failure(exceptions, self.verbose)(callback), args)

    def schedule_test_teardown_function(self, name, callback, args, exceptions=Exception):
        self._test_teardown_callbacks[name] = (continue_on_failure(exceptions, self.verbose)(callback), args)

    def __call__(self, *args, **kwargs):
        self._teardown(*args, **kwargs)

    def reset_suite_teardown(self):
        self._suite_teardown_callbacks = {}

    def reset_test_teardown(self):
        self._test_teardown_callbacks = {}
