from pathlib import Path
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console


def verify_syslog_for_correct_prints(file_path: str, logs: list | tuple) -> None:
    """Verify if syslog contains print with mobility profile
    :param: file_path (str) - syslog file path
    :param: logs (list|tuple) collection of logs to check in syslog
    :raises: Exception - if the print is not in file or syslog doesn't exit
    """
    syslog = next(Path(file_path).rglob('default_syslog_enb*.log'), None)
    if syslog is None:
        raise Exception(f"No syslog found")
    logs_iter = iter(logs)
    current_log = next(logs_iter)
    with syslog.open() as file:
        for line in file:
            if current_log in line:
                current_log = next(logs_iter, None)
                if current_log is None:
                    log_info_to_console("Syslog contains all necessary prints")
                    return
        raise Exception(f"Lack of print in syslog: {current_log}")
