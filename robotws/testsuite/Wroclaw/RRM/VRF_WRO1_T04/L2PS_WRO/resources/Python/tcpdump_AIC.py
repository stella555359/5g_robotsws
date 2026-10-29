# -*- coding: utf-8 -*-

import os
import subprocess
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_vcu import vCU
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.shell_management import (
    get_vdu_namespace, get_vcu_master_ip)


class TcpdumpCU(vCU):
    """
    TCPDUMP vCU Class

    Collect TCPDUMP from vCU
    """

    @staticmethod
    def tcpdump_f1_start(tshark_filter, path, interface):
        """
        Starts F1 TCPDUMP collection
        """
        namespace = get_vdu_namespace()
        host = get_vcu_master_ip()
        kubectl_command = "kubectl exec -n {} -c ctr-{}-nwmgmt ute-{}-cpif-0".format(namespace, namespace, namespace)
        tcpdump = "tcpdump -i {} sctp -s 0 -U -n -w -".format(interface)
        tshark_command = "tshark -r - -T fields -e frame.time_epoch -e sctp.data_payload_proto_id -e data -Y {} -w " \
                         "{}".format(tshark_filter, path)
        cmd = "$(sshpass -p system123 ssh core@{} -p 22 \"{} -- {}\" | {}) &".format(host, kubectl_command, tcpdump,
                                                                                     tshark_command)
        proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
        pid = int(proc.pid) + 4  # Adding 4 to get tshark process PID
        logger.console('pid: {}'.format(pid))
        return pid

    @staticmethod
    def tcpdump_f1_stop(pid):
        """
        Stops F1 TCPDUMP collection
        """
        cmd = 'sudo kill -2 {}'.format(pid)
        subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
