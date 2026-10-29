import os
import glob
from robot.api.deco import keyword
from robot.api import logger

SYSLOG_BASE_PATH = "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/CB013151/config/All"


@keyword("Check Syslog For Pattern")
def check_syslog_for_pattern(syslog_file_name, check_pattern, log_type="gnb"):
    """
    check gNB or AP syslog include soecial context
    """
    file_pattern = f"{syslog_file_name}_{log_type}_"
    search_pattern = os.path.join(SYSLOG_BASE_PATH, f"syslog_{syslog_file_name}", f"*{file_pattern}*")
    log_files = glob.glob(search_pattern)

    if not log_files:
        raise AssertionError(
            f"not found '{file_pattern}' {log_type} files in: "
            f"{os.path.join(SYSLOG_BASE_PATH, f'syslog_{syslog_file_name}')}")

    logger.console(f"found {len(log_files)} {log_type} files:")
    for file in log_files:
        logger.console(f"  - {os.path.basename(file)}")

    for log_file in log_files:
        logger.console(f"check file: {os.path.basename(log_file)}")
        try:
            with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            if check_pattern in content:
                logger.console(f"✓ in {os.path.basename(log_file)} found special context: {check_pattern}")
                return True
        except Exception as e:
            logger.warn(f"read file failed {log_file}: {e}")

    raise AssertionError(f"all logs '{file_pattern}' {log_type} files not found: {check_pattern}")


@keyword("Check Syslog For SRCX Activity")
def check_syslog_for_srcx_activity(syslog_file_name):
    """
    check gNB syslog specila context
    """
    srcx_pattern = "set SrcxState to configured with offsetForSrcx"
    return check_syslog_for_pattern(syslog_file_name, srcx_pattern, "gnb")
