from datetime import datetime
import time


class TimeStamp(object):

    @property
    def file_timestamp(self):
        """
        Function creates timestamp formatted to be used in file names
        :return: formatted timestamp
        """
        return datetime.now().strftime("%Y-%b-%d-%H%M%S")

    @property
    def log_timestamp(self):
        """
        Function creates raw, precise timestamp string to be used in logs
        :return:
        """
        return str(datetime.now())

    @property
    def current_minute(self):
        """
        Function returns the current minute
        :return: the current minute
        """
        return int(datetime.now().minute)

    @property
    def unix_timestamp(self):
        """
        Function returns the unix timestamp (seconds since EPOCH)
        :return: the current second since EPOCH
        """
        return float(time.time())

    @staticmethod
    def wait_for_the_unix_timestamp(expected):
        """
        Function waits to the expected time since UNIX epoch
        :param expected: The Unix epoch timestamp to wait
        :return: None
        """
        while time.time() < expected:
            time.sleep(1)
