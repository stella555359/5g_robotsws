import logging


class AbstractLogger:
    level_lookup_table = {'WARN': logging.WARNING,
                          'WARNING': logging.WARNING,
                          'DEBUG': logging.DEBUG,
                          'ERROR': logging.ERROR,
                          'INFO': logging.INFO,
                          'TRACE': 5}

    def trace(self, msg, html=False):
        self.write(msg, 'TRACE', html)

    def debug(self, msg, html=False):
        self.write(msg, 'DEBUG', html)

    def error(self, msg, html=False):
        self.write(msg, 'ERROR', html)

    def info(self, msg, html=False, also_to_console=False):
        self.write(msg, 'INFO', html)
        if also_to_console:
            self.console(msg)

    def warn(self, msg, html=False):
        self.write(msg, 'WARN', html)

    def warning(self, msg, html=False):
        self.warn(msg, html)

    def console(self, msg, newline=True, stream='stdout'):
        raise NotImplementedError

    def write(self, msg, level, html=False):
        raise NotImplementedError

    def set_logging_level(self, level):
        raise NotImplementedError

    @staticmethod
    def _lookup_level(level_str):
        level = AbstractLogger.level_lookup_table.get(level_str, None)
        if level is None:
            raise KeyError(f'Supported log level strings are: {list(AbstractLogger.level_lookup_table.keys())}')
        return level

    def _reverse_lookup_level(self, level_int):
        for level_str, level_value in AbstractLogger.level_lookup_table.items():
            if level_int == level_value:
                return level_str
        self.warning(f"There is no predefined log level for value {level_int}. Setting INFO as fallback...")
        return 'INFO'
