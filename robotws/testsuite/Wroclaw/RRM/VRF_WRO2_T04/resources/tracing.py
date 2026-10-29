import os
import logging
import subprocess
import time
from threading import Thread
from robot.api import logger
from taf.transport.ssh import ssh, ConnectFailedError
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_output_dir
from testsuite.Wroclaw.RRM.resources.rrm_fixture import (
    get_robot_variable, asik_password, asik_username, classical_asik_ip_address
)

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import (
    get_mplane_address, is_smod_pingable, has_ssh_access, get_timestamped_filename
)
from taf.rfrl.csv4all.resources.utilities.utilities import wait_until_success

LISTEN_PORT = 12345
ssh_lib = ssh()


class smod_watcher():
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self._watcher = None
        self._keep_watching = False
        self._connection_alias = 'ssh_check'
        self._logger = logging.getLogger()
        self._reset = False

    def start_watcher(self, iter_var):
        self._start_watcher(iter_var=iter_var)

    def _start_watcher(self, iter_var):
        self._keep_watching = True
        self._watcher = Thread(target=self._watch, kwargs={'iter_var': iter_var})
        self._watcher.start()

    def _should_still_watch(self):
        return self._keep_watching

    def _watch(self, iter_var):
        while self._should_still_watch():

            if not is_smod_pingable():
                logger.info("SMOD is not pingable or there is no ssh access!")
                self._reset = True
                stop_pcap_collection(ignore_fail=True)

            if self._reset:
                logger.info("Reset occured, checking ping and ssh..")
                if is_smod_pingable() and has_ssh_access():
                    time.sleep(10)
                    start_pcap_collection(iter_var=iter_var)
                    self._reset = False
            time.sleep(10)

    def _stop_watcher_thread(self):
        self._keep_watching = False

        if self._watcher is not None:
            self._watcher.join()

    def stop_watcher(self):
        self._stop_watcher_thread()


watcher = smod_watcher()


def start_pcap_collection(filepath=None, interface=None, packet_filter='', iter_var='i'):
    if not filepath:
        iteration = get_robot_variable(f"${{{iter_var}}}") or 'setup'
        filename = "{}_iter_{}{}.pcap".format(get_timestamped_filename('pcap'), iter_var, iteration)
        filepath = os.path.join(get_robot_output_dir(), 'pcaps', filename)
        os.system('mkdir -p {}'.format(os.path.dirname(filepath)))
    logger.info("Start pcap collection..")
    is_smod_pingable()
    has_ssh_access()
    start_listening_on_vm(filepath)
    _start_packet_forwarding_to_vm(interface, packet_filter=packet_filter)
    return filepath


def stop_pcap_collection(ignore_fail=False):
    logger.info("Stop pcap collection")
    _stop_packet_forwarding_to_vm(ignore_fail=ignore_fail)
    stop_listening_on_vm()


def _get_interface_name(connection):
    mplane_address = get_mplane_address()
    interface = ssh_lib.execute(r'ifconfig | grep -B1 {} | grep -o "^\w*" | head -n1'.format(mplane_address),
                                connection=connection).strip()
    if not interface or interface.startswith('eth'):
        raise RuntimeError("Mplane interface not found!")
    return interface


def start_listening_on_vm(filepath):
    os.system('killall -q nc')
    command = 'nc -l -k -p {}'.format(LISTEN_PORT, filepath)
    logger.info("Start listening on vm: {}".format(command))
    with open(filepath, 'wb') as f:
        subprocess.Popen([command], shell=True, stdout=f)


def stop_listening_on_vm():
    command = 'killall -q nc'
    logger.info("Stop listening on vm.")
    subprocess.Popen([command], shell=True)


def _start_packet_forwarding_to_vm(interface=None, packet_filter=''):
    ssh_lib.connect_to(classical_asik_ip_address, asik_username, asik_password, alias='ssh_smod')
    if not interface:
        interface = wait_until_success(timeout=60, interval=1, function_name=_get_interface_name, connection='ssh_smod')
    command = f'tcpdump -i {interface} -U -w - {packet_filter} | nc 192.168.255.126 {LISTEN_PORT} &'
    logger.info("Start tcpdump on smod: {}".format(command))
    try:
        ssh_lib.execute('killall tcpdump', connection='ssh_smod')
        ssh_lib.send_command(command, connection='ssh_smod')
        is_running = ssh_lib.execute('pgrep tcpdump', connection='ssh_smod')
        logger.debug("Is running: {}".format(is_running))
    finally:
        ssh_lib.disconnect(connection='ssh_smod')
    logger.info("Forwarding started")


def _stop_packet_forwarding_to_vm(ignore_fail=False):
    try:
        ssh_lib.connect_to(classical_asik_ip_address, asik_username, asik_password, alias='ssh_smod')
    except ConnectFailedError:
        if ignore_fail:
            logger.info("Connection failed")
            return
        raise ConnectFailedError("Could not connect to smod")

    try:
        ssh_lib.execute('killall -q tcpdump', connection='ssh_smod')
    finally:
        ssh_lib.disconnect(connection='ssh_smod')


def start_continuous_tcpdump(iter_var='i', packet_filter='sctp'):
    start_pcap_collection(iter_var=iter_var, packet_filter=packet_filter)
    watcher.start_watcher(iter_var=iter_var)


def stop_continuous_tcpdump():
    stop_pcap_collection()
    watcher.stop_watcher()


def start_listening_tcpdump_from_smod(filepath, interface='any', packet_filter='sctp'):
    """
    :param filepath: full path or filename, in case of filename robot output dir will be used
    :param interface: tcpdump interface to collect pcap
    :param packet_filter: tcpdump filter
    """
    if not filepath.startswith('/'):
        filepath = os.path.join(get_robot_output_dir(), filepath)
    return start_pcap_collection(filepath, interface=interface, packet_filter=packet_filter)


def stop_listening_tcpdump_from_smod():
    return stop_pcap_collection()
