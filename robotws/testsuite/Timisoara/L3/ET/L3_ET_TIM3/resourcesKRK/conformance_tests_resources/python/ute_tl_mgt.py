
import os


def add_wts_to_tl_variable(tl):

    tl.core = type("Core", (), {
        "default_ssh_connection_details": tl.test_pc.default_ssh_connection_details,
        "dir_path": "/opt/iphy/latest",
        "cfg_filename": "basic_wts_step2.cfg",
        "port": "20000",
        "mme_ip": '',
        "edaemon_port": '22222',
        "egate_port": '9880'
    })()


def identify_oam_type(cmd_output):

    """Author : Jing Liang"""

    if "succeeded" in cmd_output:

        # for kiwi vm output

        return "coam"

    elif 'open' in cmd_output:

        # for ute vm output

        return "coam"

    elif 'Connected' in cmd_output:

        # for newer ute vm output 19.02.2020

        return "coam"

    elif 'No route to host' in cmd_output:

        raise Exception('No route to host or host not reachable')

    else:

        return "cloud_coam"


def reform_coam_sw_version(version):

    """reform SW Version from COAM GNB to QC required form:

    from 5G19_FSMK_0000_018351_001507 to 5G_0.18351.1507

    from 5G19B_FDD_GNB_0008_001840_000327 to 5G19B_0.1840.327"""

    tmp = version.split('_')

    version = strip_version(tmp[-3:])

    if version[0] == '0':

        result = '_'.join(['5G', version])

    else:

        result = '_'.join([tmp[0], version])

    return result


def strip_version(version):

    """remove 0 from sw version"""

    for i in range(len(version)):

        if version[i].lstrip('0') == '':

            version[i] = '0'

        else:

            version[i] = version[i].lstrip('0')

    return '.'.join(version)
