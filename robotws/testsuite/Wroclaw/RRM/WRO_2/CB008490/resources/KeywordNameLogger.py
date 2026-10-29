import datetime
from robot.libraries.BuiltIn import BuiltIn
from robot.api.deco import keyword


class KeywordNameLogger(object):
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self
        self.keywords = []

    def _start_keyword(self, name, attrs):
        self.keywords.append(name)

    def _end_keyword(self, name, attrs):
        self.keywords.pop()

    @keyword()
    def log_parent_keyword_name_to_console(self):
        """ KW logs to console (with timestamp) name of parent KW in which is used.
        """

        timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        try:
            parent_kw_name = self.keywords[-2]
            kw_name_without_lib_prefix = parent_kw_name.split(".", 1)[1]
            BuiltIn().log_to_console(f"\n[{timestamp}] {kw_name_without_lib_prefix} ", no_newline=True)
        except IndexError:
            BuiltIn().log("KW name not available")
