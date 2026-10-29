import re
import subprocess
import sys


ANSI_RED = "\033[31m"
ANSI_GREEN = "\033[32m"
ANSI_YELLOW = "\033[1;93m"
ANSI_RESET = "\033[0m"

MSG_ERRORS = (
    "─────────────────────────────────────────────────────────\n"
    "        Robocop linter: see errors listed above\n"
    "─────────────────────────────────────────────────────────\n"
)
MSG_WARNINGS = (
    "─────────────────────────────────────────────────────────────\n"
    "        Robocop linter: see warnings listed above\n"
    "─────────────────────────────────────────────────────────────\n"
)
MSG_OK = (
    "───────────────────────────────────────────────\n"
    "        Robocop linter: no issues found\n"
    "───────────────────────────────────────────────\n"
)


class RobocopOutputAnalyser:

    def __init__(self):
        self.has_errors = False
        self.has_warnings = False
        self.has_infos = False

        self._error_pattern = re.compile(r"\s\[E\]\s\(.*\)")
        self._warning_pattern = re.compile(r"\s\[W\]\s\(.*\)")
        self._info_pattern = re.compile(r"\s\[I\]\s\(.*\)")

    def process_line(self, line: str) -> str:    
        if self._error_pattern.search(line):
            self.has_errors = True
        elif self._warning_pattern.search(line):
            self.has_warnings = True
        elif self._info_pattern.search(line):
            self.has_infos = True

    def get_exit_code(self) -> int:
        if self.has_errors:
            print(f"{ANSI_RED}{MSG_ERRORS}{ANSI_RESET}")
            return 1
        elif self.has_warnings:
            print(f"{ANSI_YELLOW}{MSG_WARNINGS}{ANSI_RESET}")
            return 199
        print(f"{ANSI_GREEN}{MSG_OK}{ANSI_RESET}")

        return 0


def execute(cmd: list[str]):
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.stderr:
        print(proc.stderr)
        exit(1)
            
    return proc.stdout


if __name__ == "__main__":   
    changed_files = sys.argv[1:]

    analyser = RobocopOutputAnalyser()
    output = execute(["robocop", "check", "--config", "robocop.toml", *changed_files])
    for line in output.splitlines():
        analyser.process_line(line)
        print(line)

    exit(analyser.get_exit_code())
