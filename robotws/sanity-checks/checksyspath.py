import sys


class SyspathGuard(object):
    ROBOT_LISTENER_API_VERSION = 2
    allowed_path_substrings = ("taf/ul/swing/core/remoteswinglibrary-2.2.3.jar",
                               "site-packages/jaeger_client/thrift_gen",
                               )

    def __init__(self):
        self.sys_path = sys.path[:]

    def end_test(self, name, attrs):
        if self.sys_path != sys.path:
            added = set(sys.path) - set(self.sys_path)
            removed = set(self.sys_path) - set(sys.path)
            diff = list(filter(self._is_prohibited, added.union(removed)))
            self.sys_path = sys.path[:]

            if diff:
                msg = "sys.path modification detected when running '{name}' test\n"
                msg += "sys.path difference:\n{diff}"
                msg = msg.format(name=name, diff="\n".join(diff))

                print(msg)
                sys.exit(1)

    def _is_prohibited(self, path):
        return not any(substring in path
                       for substring in self.allowed_path_substrings)
