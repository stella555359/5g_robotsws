"""
:copyright: Nokia Networks
:author: Damian Zak, Mateusz Plinta, Mateusz Pajor, Damian Piasecki
:maintainer: Damian Zak, Mateusz Plinta, Mateusz Pajor
:contact: damian.zak@nokia.com, mateusz.plinta@nokia.com, mateusz.pajor@nokia.com, damian.piasecki@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG, MN_RAN_L2_SW_2_KRK_Vrf_SG
"""

from variables import *


def run_egate_command(command, return_output=True):
    """
    The function to run eGate command

    :param command: (str) The command to run
    :param return_output: (bool) The flag to return output
    """
    BuiltIn().get_library_instance("ta5g_egate")._ute_wtssim_instance.execute_egate_command(
        command, return_output=return_output
    )
