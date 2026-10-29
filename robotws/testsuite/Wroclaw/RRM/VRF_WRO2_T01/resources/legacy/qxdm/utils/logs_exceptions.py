class LogAnalyzerExceptions(Exception):
    def __init__(self, message="Unknown error"):
        super().__init__(message)


class EmptyParsedFiles(LogAnalyzerExceptions):
    def __init__(self):
        super().__init__("Splitted log files are empty !")


class NoLogsToProcess(LogAnalyzerExceptions):
    def __init__(self, log_name, value_name=None):
        self.log_name = log_name
        self.value_name = value_name

    def __str__(self):
        if not self.value_name:
            return f"No logs to process for {self.log_name}"
        return f"No logs to process for {self.log_name} | {self.value_name}"
