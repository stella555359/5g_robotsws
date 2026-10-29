from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp


class Logger(object):

    @staticmethod
    def info(msg):
        """
        Logs robot framework message with robot's "INFO" level to the log and to console
        :param msg: message to be logged
        :return: None
        """
        BuiltIn().log("{}: NCO_INFO - {}".format(TimeStamp().log_timestamp, msg), "INFO", console=True)

    @staticmethod
    def warning(msg):
        """
        Logs robot framework message with robot's "WARN" level to the log and to console
        :param msg: message to be logged
        :return: None
        """
        BuiltIn().log("{}: NCO_WARNING - {}".format(TimeStamp().log_timestamp, msg), "WARN", console=True)

    @staticmethod
    def debug(msg):
        """
        Logs robot framework message with robot's "DEBUG" level to the log only
        :param msg: message to be logged
        :return: None
        """
        BuiltIn().log("{}: NCO_DEBUG - {}".format(TimeStamp().log_timestamp, msg), "DEBUG", console=False)

    @staticmethod
    def picture(path_to_the_picture):
        """
        Inserts picture to the robotframework's log.html
        :param path_to_the_picture: picture to be logged
        :return: None
        """
        BuiltIn().log(f"<img src='{path_to_the_picture}'/>", "INFO", html=True)
