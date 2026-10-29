"""
:copyright: Nokia Networks
:author: Damian Zak
:contact: damian.zak@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""
import os
import glob
from robot.errors import ExecutionFailed


def check_rach_contention(rach_procedure_type, wts_dir_location):
    """
    Author: Damian Zak
    Contact: damian.zak@nokia.com
    Creation Date: 09.04.2021
    Modified Date: -

    Function used to check the type of rach procedure(CBRA or CFRA)

    Args:
        rach_procedure_type(str): Type of rach procedure to validate
        wts_dir_location(str): WTS location

    Raises:
        ExecutionFailed: (CBRA OR CFRA) was not acquired

    Returns:
        None
    """
    list_of_files = glob.glob("%s/uec_1.log.*" % wts_dir_location)
    latest_file = max(list_of_files, key=os.path.getctime)
    with open(latest_file) as f:
        if rach_procedure_type not in f.read():
            raise ExecutionFailed(message="%s was not acquired" % rach_procedure_type)
