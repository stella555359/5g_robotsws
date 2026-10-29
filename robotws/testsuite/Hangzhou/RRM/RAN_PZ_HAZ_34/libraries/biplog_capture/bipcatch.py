# -*- coding: utf-8 -*-
"""
Author: Cheng Huimin
Contacts: huimin.1.cheng@nokia-sbell.com
Squard: cmw_sg3
Description: this bip mirror script is reference from gnbMirroring.sh ,and change it to python mode which is convenient
"""
from robot.api import logger
from taf.transport.ssh import ssh
import re
import time

csn = ssh()

# __all__ = ['detectHwAndStartMirroring']


def detectHwAndStartMirroring(asik_alias, loner_alias, mirror_mode, hw_index, sw_release='ASIK'):
    ssh_asik = csn.get_connection_by_alias(asik_alias)
    ssh_loner = csn.get_connection_by_alias(loner_alias)
    if 'ASIB' in sw_release:
        _operateMirroringInLoner(ssh_progress=ssh_loner, sw_release=sw_release, status='enable')
        _startMirroringInAsibMarvell(ssh_progress=ssh_asik, mirror_mode=mirror_mode, hw_index=hw_index)
        logger.info("Enable mirroring in ASIB/ABIL successfully")
    elif 'ASOD' in sw_release:
        logger.info("ASOD not yet support")
    elif 'ASIL' in sw_release:
        # startMirroringInAsil
        logger.info("ASIL not yet support")
    else:
        _operateMirroringInLoner(ssh_progress=ssh_loner, sw_release=sw_release, status='enable')
        _startMirroringInAsik(ssh_progress=ssh_asik, mirror_mode=mirror_mode, hw_index=hw_index)
        logger.info("Enable mirroring in ASIK/ABIL successfully")


def _startMirroringInAsibMarvell(ssh_progress, mirror_mode, hw_index):
    if mirror_mode == 'remote':
        logger.info("remote not support here")
    elif mirror_mode == 'local':
        _operateMirroringInAsibMarvell(ssh_progress=ssh_progress, hw_index=hw_index, status='disable')
        logger.info("disable mirroring")
        _operateMirroringInAsibMarvell(ssh_progress=ssh_progress, hw_index=hw_index, status='enable')
        logger.info("enable mirroring")


def _operateMirroringInAsibMarvell(ssh_progress, hw_index, status):
    abil_ena_no = 3+int(hw_index)*4
    abil_dis_no = 2+int(hw_index)*4
    if status == 'enable':
        ssh_progress.execute(r'echo 4 both > /var/run/cpss/ports/'+str(abil_ena_no)+'/mirroring_port')
    elif status == 'disable':
        ssh_progress.execute(r'echo both > /var/run/cpss/ports/'+str(abil_dis_no)+'/disable_mirroring 1> /dev/null')


def _startMirroringInAsik(ssh_progress, mirror_mode, hw_index):
    _dport_eif2 = 15
    _dport_asik = 2
    if mirror_mode == 'remote':
        _operateMirroringInAsikRrc(ssh_progress=ssh_progress, hw_index=hw_index, dport=_dport_eif2, status='enable')
        _enableEif2PortInAsikRrc(ssh_progress=ssh_progress, dport=_dport_eif2)
    elif mirror_mode == 'local':
        _operateMirroringInAsikRrc(ssh_progress=ssh_progress, hw_index=hw_index, dport=_dport_eif2, status='disable')
        logger.info("disable mirroring in ASIK/ABIL eif2")
        _operateMirroringInAsikRrc(ssh_progress=ssh_progress, hw_index=hw_index, dport=_dport_asik, status='enable')
        logger.info("enable mirroring in ASIK/ABIL etha01")


def _operateMirroringInAsikRrc(ssh_progress, hw_index, dport, status):
    sport_no = 17+int(hw_index)*8
    if status == 'enable':
        ssh_progress.execute(r'dbgrrc mirror sport '+str(sport_no)+' dport '+str(dport)+' enable both')
    elif status == 'disable':
        ssh_progress.execute(r'dbgrrc mirror sport ' + str(sport_no) + ' dport '
                             + str(dport) + ' disable both 1> /dev/null')


def _enableEif2PortInAsikRrc(ssh_progress, dport):
    ssh_progress.execute(r'dbgrrc enable port '+str(dport))
    ssh_progress.execute(r'dbgrrc set port '+str(dport)+' speed 10000')


def _operateMirroringInLoner(ssh_progress, sw_release, status):
    if status == 'enable':
        ssh_progress.execute(r'echo fffffff 2 > /sys/class/bip/bip0/device/multicast_ctrl')
        if '5G19_' in sw_release:
            _mirrortagadd(ssh_progress=ssh_progress, ports_mask='0x1', port_flag='0x2')
            logger.info("Enable Loner mirroring from arb0p0 to arb0p1")
        elif 'ASIB' in sw_release or 'ASIL' in sw_release:
            _mirrortagaddasib(ssh_progress=ssh_progress, ports_mask='0x2', port_flag='0x1')
            logger.info("Enable Loner mirroring from arb0p1 to arb0p0")
        else:
            _mirrortagadd(ssh_progress=ssh_progress, ports_mask='0x3', port_flag='0x4')
            logger.info("Enable Loner mirroring from arb0p0 and arb0p1 to arb0p2")
    elif status == 'disable':
        _mirrortagadd(ssh_progress=ssh_progress, ports_mask='0x0', port_flag='0x0')


def _readSwReleseFromTargetBD(ssh_progress):
    swReleaseLine = ssh_progress.execute(r'cat /ffs/run/TargetBD*.xml | grep swReleaseVersionPackageName')
    swReleaseString = re.findall(r"swReleaseVersionPackageName=\"(.+?)\"", swReleaseLine)
    return str(swReleaseString)


def _mirrortagaddasib(ssh_progress, ports_mask, port_flag):
    _mirrortagadd(ssh_progress=ssh_progress, ports_mask='0x2', port_flag='0x1')
    ssh_progress.execute(r'ethtool -s arb0p0 phyad 1')


def _mirrortagadd(ssh_progress, ports_mask, port_flag):
    mirror_path = '> /sys/class/xlgx/xlgx0/device/'
    ssh_progress.execute(r'echo ' + ports_mask+mirror_path+'monitored_ports_mask && echo '
                         + port_flag+mirror_path+'monitoring_port_flag')
