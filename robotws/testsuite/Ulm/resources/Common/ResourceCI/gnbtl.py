from robot.api import logger
from sys import argv


class gnbtl:
    if "--dryrun" not in argv:
        ROBOT_LISTENER_API_VERSION = 2
        ROBOT_LIBRARY_SCOPE = 'LOCAL'

    def __init__(self):
        if "--dryrun" not in argv:
            self.ROBOT_LIBRARY_LISTENER = self

    def start_suite(self, name, args):
        logger.info("\n## Starting Testsuite {}".format(name), also_console=True)

    def end_suite(self, name, args):
        print("\n## Ending Testsuite {}".format(name))

    def start_test(self, name, args):
        print("\n## Starting Test {}".format(name))

    def end_test(self, name, args):
        print("\n## Ending Test {}".format(name))
