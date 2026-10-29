from taf.rfrl.bts.parsers.snapshot_analyzer import *


def find_mandatory_rfsw_logs_in_snapshot(directory, mandatory_logs):
    """
    Search for RFSW files in snapshot
    :param directory: path to directory with snapshot
    :return: None
    """
    file_list = find_mandatory_files_in_snapshot(directory)
    if mandatory_logs is None:
        mandatory_log_list = ["journal", "hlapi", "runtime", "startup", "ps", "fault_history", "RP1OM"]
    else:
        mandatory_log_list = mandatory_logs
    for mandatory_log in mandatory_log_list:
        regex_file_list = re.compile(r"{}".format(mandatory_log))
        if not list(filter(regex_file_list.match, file_list)):
            raise FileNotFound("Mandatory RFSW file containing name {} "
                               "not found in snapshot".format(mandatory_log))
