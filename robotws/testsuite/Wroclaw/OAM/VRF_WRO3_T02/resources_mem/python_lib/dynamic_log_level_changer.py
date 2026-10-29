from robot.libraries.BuiltIn import BuiltIn


class DynamicLogLevelChanger:
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self):
        self.loglevel = BuiltIn().get_variable_value('${LOGLEVEL}', 'INFO').upper()

    def start_test(self, *args):
        self.set_log_level(self.loglevel)

    def start_keyword(self, *args):
        self.set_log_level(self.loglevel)

    def set_log_level(self, level):
        from robot.api import logger
        logger.console(f'Loglevel changed to: {level}')
        logger.set_level(level)
