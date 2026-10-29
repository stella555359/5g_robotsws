# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Haofeng Zhu
:contact: haofeng.zhu@nokia-sbell.com
:maintainer: Haofeng Zhu
:contact: haofeng.zhu@nokia-sbell.com
"""

import os
import time
import logging
from copy import deepcopy
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh import ssh
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.ru_btslog_collector import (start_btslog_collector,
                                                                                   stop_btslog_collector_and_save_log)
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.ru_serial_log_collector import create_ru_serial_log_collector


global_ru_collector_logger = None
total_rus_collectors = []

global_btslog_stream_port = {}
global_ru_pc_container_ssh_port = {}

BASE_BTSLOG_STREAM_PORT = 51001
BASE_CONTAINER_SSH_PORT = 2222

WINDOWS_DEFAULT_PYTHON_PATH = "C:/Python39/python"
WINDOWS_DEFAULT_WORK_DIR = "C:/rsi"
LINUX_DEFAULT_PYTHON_PATH = "/usr/bin/python"
LINUX_DEFAILT_WORK_DIR = "/tmp/rsi"
CONTAINER_DEFAULT_PYTHON_PATH = "/usr/local/bin/python"
CONTAINER_DEFAULT_WORK_DIR = "/tmp/docker"


def start_to_collect_serial_logs(ru=None,
                                 log_save_dir="",
                                 ru_pc_work_dir=WINDOWS_DEFAULT_WORK_DIR,
                                 ru_pc_python_path=WINDOWS_DEFAULT_PYTHON_PATH,
                                 serial_number="",
                                 logger=None,
                                 pyro_ip="0.0.0.0",
                                 btslog_stream_port=BASE_BTSLOG_STREAM_PORT):
    ru_type = ru.ru_hw_group
    ru_pc = ru.lmi.host.default_ssh_connection_details
    serial_ports = ru.lmi.uart_mapping
    """
    product code is VLAN ID, for example:
    0xC0A864C8      #Here the IP is: 192.168.100.200, the ip of VLAN257
    """
    vlan_id = ru.lmi.product_code if hasattr(ru.lmi, "product_code") else "0xC0A864C8"

    serial_collectors = []
    for serial_port in serial_ports:
        try:
            serial_collector = create_ru_serial_log_collector(ru_pc_address=ru_pc.addr,
                                                              ru_pc_ssh_port=ru_pc.port,
                                                              ru_pc_username=ru_pc.username,
                                                              ru_pc_password=ru_pc.password,
                                                              ru_type=ru_type,
                                                              serial_port=serial_port.port,
                                                              remote_dir=ru_pc_work_dir,
                                                              python_path=ru_pc_python_path,
                                                              log_save_dir=log_save_dir,
                                                              serial_number=serial_number,
                                                              logger=logger,
                                                              pyro_ip=pyro_ip,
                                                              vlan_id=vlan_id,
                                                              btslog_stream_port=btslog_stream_port)
        except Exception as err:
            err_msg = str(err)
            logger.error("failed connect to serial for {} port: {}, error: {}".format(ru_pc.addr,
                                                                                      serial_port,
                                                                                      err_msg))
            continue

        serial_collectors.append(serial_collector)

    if not serial_collectors:
        logger.error("no serial port connected for RU {} {}".format(ru_pc.addr, ru.serial_number))
        return []

    master_serial_collector = serial_collectors[0]
    master_serial_collector.enable_lmi_eth()
    master_serial_collector.config_aasyslog_parameters()
    master_serial_collector.start_monitor_for_enable_lmi_eth_on_ru_reboot()

    logger.info("started collecting serial logs, monitoring master serial port for lmi eth on ru reboot")
    return serial_collectors


def start_to_collect_btslogs(ru=None, log_save_dir="", serial_number="", logger=None,
                             using_docker_solution=False, btslog_stream_port=BASE_BTSLOG_STREAM_PORT):
    ru_pc = ru.lmi.host.default_ssh_connection_details
    btslog_collector = start_btslog_collector(host=ru_pc.addr,
                                              port=ru_pc.port,
                                              username=ru_pc.username,
                                              password=ru_pc.password,
                                              log_save_dir=log_save_dir,
                                              serial_number=serial_number,
                                              logger=logger,
                                              using_docker_solution=using_docker_solution,
                                              btslog_stream_port=btslog_stream_port)
    return btslog_collector


class CustomFormatter(logging.Formatter):

    def format(self, record):
        record.msg = record.msg.replace('\n', ' ').replace('\r', ' ').strip()
        return super(CustomFormatter, self).format(record)


def get_logger_for_ru_collector(log_file_path=None):
    global global_ru_collector_logger
    if global_ru_collector_logger:
        return global_ru_collector_logger

    log_file_handler = logging.FileHandler(log_file_path)
    testline_name = BuiltIn().get_variable_value("${testline_name}")
    formatter = CustomFormatter('"%(asctime)s", {}, %(levelname)s, "%(message)s"'.format(testline_name))
    log_file_handler.setFormatter(formatter)
    log_file_handler.setLevel(logging.DEBUG)
    global_ru_collector_logger = logging.getLogger('ru_collector_logger_{}'.format(time.time()))
    global_ru_collector_logger.addHandler(log_file_handler)
    return global_ru_collector_logger


def is_linux_os(ssh_connection_details):
    ssh_proxy = ssh()
    ssh_proxy.connect_to(hostname=ssh_connection_details.addr,
                         port=ssh_connection_details.port,
                         username=ssh_connection_details.username,
                         password=ssh_connection_details.password,
                         alias="tmp_con")
    output = ssh_proxy.execute(command="uname -s", connection="tmp_con")
    ssh_proxy.disconnect(connection="tmp_con")
    """
    linux VM output:
    ute@cnhznlbhkfdr2:~$ uname -s
    Linux

    windows VM output:
    $ uname -s
    CYGWIN_NT-10.0-22631
    """
    return "cygwin" not in output.lower()


class RuPcDockerManager(object):

    """
    ute@cnhznlfa4jhgf:~$ docker images
    REPOSITORY    TAG       IMAGE ID       CREATED        SIZE
    hz-5gran-ci-docker-repo-local.artifactory-hz1.int.net.nokia.com/taf/linux_ru_pc  v0.6  eb0192159ac5
    """
    _LATEST_IMAGE = "eb0192159ac5"

    """
    "docker run --rm -d --device=/dev/ttyUSB0 -p 22226:22 -p 9092:9092 -p 51001:51001/udp -v /tmp/ru eb0192159ac5"
    """

    _GET_CONTAINER_ID_BY_IMAGE_ID = 'docker ps --filter "ancestor={}"'.format(_LATEST_IMAGE) + ' --format "{{.ID}}"'

    _START_CONTAINER_COMMAND_TEMPLATE = "docker run --rm -d {device} {ports} -v /tmp/ru {image}"
    _KILL_CONTAINER_COMMAND_TEMPLATE = 'docker ps --filter "ancestor={}"'.format(_LATEST_IMAGE) + \
        ' --format "{{.ID}}" | xargs docker kill'

    _SSH_CONN_ALIAS = "ru_pc_con"

    def __init__(self, ru_pc_ssh_config, logger):
        self.ru_pc_ssh_config = ru_pc_ssh_config
        self.logger = logger

        self.devices = []
        self.publish_ports = []
        self._ssh_proxy = None

    def __enter__(self):
        self.connect_ru_pc()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.disconnect_ru_pc()
        self.logger.info("disconnected from ru pc {}".format(
            self.ru_pc_ssh_config.addr))

    def connect_ru_pc(self):
        self._ssh_proxy = ssh()
        self._ssh_proxy.connect_to(hostname=self.ru_pc_ssh_config.addr,
                                   port=self.ru_pc_ssh_config.port,
                                   username=self.ru_pc_ssh_config.username,
                                   password=self.ru_pc_ssh_config.password,
                                   alias=self._SSH_CONN_ALIAS)

    def disconnect_ru_pc(self):
        self._ssh_proxy.disconnect(connection=self._SSH_CONN_ALIAS)

    def is_docker_supported(self):
        output = self._ssh_proxy.execute("docker images | grep {}".format(self._LATEST_IMAGE),
                                         connection=self._SSH_CONN_ALIAS)
        result = output.strip() and "command not found" not in output and self._LATEST_IMAGE in output
        if result is False:
            self.logger.info("ru pc {} do not support docker, {}".format(self.ru_pc_ssh_config.addr, output))
        return result

    def add_devices_to_container(self, device_ports):
        if isinstance(device_ports, list):
            self.devices = device_ports
        else:
            self.devices = [device_ports]

    def publish_port_to_host(self, host_port="", container_port=""):
        self.publish_ports.append([host_port, container_port])

    def _build_devices_mapping_options(self):
        return " ".join(["--device={}".format(device) for device in self.devices])

    def _build_ports_publish_options(self):
        return " ".join(["-p {}:{}".format(*port_pair) for port_pair in self.publish_ports])

    def _build_container_startup_command(self):
        device_option = self._build_devices_mapping_options()
        port_option = self._build_ports_publish_options()
        return self._START_CONTAINER_COMMAND_TEMPLATE.format(device=device_option,
                                                             ports=port_option,
                                                             image=self._LATEST_IMAGE)

    def start_container(self):
        command = self._build_container_startup_command()
        self.logger.info("start container: {}".format(command))
        output = self._ssh_proxy.execute(command, connection=self._SSH_CONN_ALIAS)
        self.logger.info("output: {}".format(output))
        """
        aea202a73e8d0f81c99227ef5d466328200e40b41e654b3579db0f21b0b43373
        docker: Error response from daemon: driver failed programming external connectivity
        on endpoint determined_robinson (b0fe5ab9ff4e177c1514e7d4ea41ffc6733e142b95c47f760a90d50ec6):
        failed to bind port 0.0.0.0:9092/tcp: Error starting userland proxy: listen tcp4 0.0.0.0:9092:
        bind: address already in use.
        """
        if "Error" in output or "failed" in output:
            return False

        return True

    def stop_container(self):
        output = self._ssh_proxy.execute(self._KILL_CONTAINER_COMMAND_TEMPLATE,
                                         connection=self._SSH_CONN_ALIAS)
        self.logger.info("stopped container: {}".format(output))

    def get_container_id(self):
        output = self._ssh_proxy.execute(self._GET_CONTAINER_ID_BY_IMAGE_ID,
                                         connection=self._SSH_CONN_ALIAS)
        return output.strip()

    def is_container_alive(self):
        container_id = self.get_container_id()
        return container_id != ""


def get_new_ru_configuration(original_ru_configuration, ssh_port):
    new_ru = deepcopy(original_ru_configuration)
    """
    If using a Docker container to connect to the RU,
    the default SSH port is 2222, and the username/password is 'root'.
    """
    new_ru.lmi.host.default_ssh_connection_details.port = ssh_port
    new_ru.lmi.host.default_ssh_connection_details.username = "root"
    new_ru.lmi.host.default_ssh_connection_details.password = "root"
    return new_ru


def startup_docker_container(ssh_port, btslog_stream_port, ru_lmi, logger):
    with RuPcDockerManager(ru_pc_ssh_config=ru_lmi.host.default_ssh_connection_details,
                           logger=logger) as ru_pc_docker:
        ru_pc_docker.connect_ru_pc()
        if not ru_pc_docker.is_docker_supported():
            logger.info("docker container is not supported on RU PC {}".format(
                ru_lmi.host.default_ssh_connection_details.addr))
            return False

        logger.info("docker container is supported on RU PC {}".format(
            ru_lmi.host.default_ssh_connection_details.addr))

        ru_pc_docker.add_devices_to_container([serial.port for serial in ru_lmi.uart_mapping])

        """
        mapping host port 2222 to container port 22 for ssh connection
        mapping host port 9092 to container port 9092 for pyro server
        mapping host port 51001 to container port 51001 for btslog stream
        """
        ru_pc_docker.publish_port_to_host(host_port=ssh_port, container_port="22")
        ru_pc_docker.publish_port_to_host(host_port="9092", container_port="9092")
        ru_pc_docker.publish_port_to_host(
            host_port=btslog_stream_port, container_port="{}/udp".format(btslog_stream_port))

        if ru_pc_docker.is_container_alive():
            logger.info("kill old container on RU PC {}".format(
                ru_lmi.host.default_ssh_connection_details.addr))

            ru_pc_docker.stop_container()

        ru_pc_docker.start_container()

        result = ru_pc_docker.is_container_alive()
        return result


def start_to_collect_ru_logs(is_ru_log_collecting_enable=False, log_save_dir=None,
                             ru_pc_work_dir=WINDOWS_DEFAULT_WORK_DIR, ru_pc_python_path=WINDOWS_DEFAULT_PYTHON_PATH):
    """
    The keyword used for starting to collect RU logs (serial logs and bts logs)
    :param is_ru_log_collecting_enable: The flag to enable/disable collecting RU logs.
    :param log_save_dir: The directory to save RU logs.
    :param ru_pc_work_dir: The working directory on the RU PC.
    :param ru_pc_python_path: The path to the Python executable on the RU PC.
    :return: None
    """
    if not log_save_dir:
        log_save_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")

    log_file_path = os.path.join(log_save_dir, "ru_collector_log.csv")
    logger = get_logger_for_ru_collector(log_file_path=log_file_path)

    if is_ru_log_collecting_enable is False:
        logger.info("collect ru logs is disabled, no ru logs collected")
        return

    started_btslog_collector_ru_pc_addresses = []
    rus = get_rus_from_tl()
    for ru in rus:
        if not ru.lmi:
            logger.error("lmi or ru_hw_group field is not configured for RU in testline configuration")
            continue

        if ru.lmi.host is None or ru.lmi.uart_mapping is None:
            logger.error("host or uart_mapping field is not configured for RU.lmi in testline configuration")
            continue

        serial_number = ru.serial_number if ru.serial_number else ""
        pyro_ip = ru.lmi.host.default_ssh_connection_details.addr
        btslog_stream_port = allocate_btslog_port(ru.lmi.host.default_ssh_connection_details)
        using_docker_solution = False
        if is_linux_os(ru.lmi.host.default_ssh_connection_details):
            """
            if the docker solution is existed on linux RU PC, will select docker firstly.
            """
            ssh_port = allocate_ssh_port(ru.lmi.host.default_ssh_connection_details)
            if startup_docker_container(ssh_port, btslog_stream_port, ru.lmi, logger):
                logger.info("collect log using docker container on the linux ru pc")
                ru = get_new_ru_configuration(ru, ssh_port)
                ru_pc_python_path = CONTAINER_DEFAULT_PYTHON_PATH
                ru_pc_work_dir = CONTAINER_DEFAULT_WORK_DIR
                pyro_ip = "0.0.0.0"
                using_docker_solution = True
            else:
                logger.info("collect log directly on the linux ru pc")
                if ru_pc_python_path.lower().startswith("c:/"):
                    ru_pc_python_path = LINUX_DEFAULT_PYTHON_PATH
                ru_pc_work_dir = LINUX_DEFAILT_WORK_DIR if ru_pc_work_dir.lower().startswith("c:/") else ru_pc_work_dir
                logger.info("RU PC is running Linux OS, update python path to {} work dir to {}".format(
                    ru_pc_python_path, ru_pc_work_dir))
        else:
            logger.info("collect log directly on the windows ru pc")

        serial_collectors = start_to_collect_serial_logs(ru=ru,
                                                         log_save_dir=log_save_dir,
                                                         ru_pc_work_dir=ru_pc_work_dir,
                                                         ru_pc_python_path=ru_pc_python_path,
                                                         serial_number=serial_number,
                                                         logger=logger,
                                                         pyro_ip=pyro_ip,
                                                         btslog_stream_port=btslog_stream_port)

        btslog_collector = None
        if using_docker_solution or \
                ru.lmi.host.default_ssh_connection_details.addr not in started_btslog_collector_ru_pc_addresses:
            btslog_collector = start_to_collect_btslogs(ru=ru,
                                                        log_save_dir=log_save_dir,
                                                        serial_number=serial_number,
                                                        logger=logger,
                                                        using_docker_solution=using_docker_solution,
                                                        btslog_stream_port=btslog_stream_port)
            started_btslog_collector_ru_pc_addresses.append(ru.lmi.host.default_ssh_connection_details.addr)

        global total_rus_collectors
        total_rus_collectors.append({"serials": serial_collectors, "btslog": btslog_collector})

    logger.info("started collecting ru logs")


def allocate_ssh_port(ru_pc_ssh_config):
    global global_ru_pc_container_ssh_port
    if ru_pc_ssh_config.addr in global_ru_pc_container_ssh_port:
        last_port = global_ru_pc_container_ssh_port[ru_pc_ssh_config.addr][-1]
        new_port = last_port + 1
        global_ru_pc_container_ssh_port[ru_pc_ssh_config.addr].append(new_port)
        return new_port
    else:
        global_ru_pc_container_ssh_port[ru_pc_ssh_config.addr] = [BASE_CONTAINER_SSH_PORT]
        return BASE_CONTAINER_SSH_PORT


def allocate_btslog_port(ru_pc_ssh_config):
    global global_btslog_stream_port
    if ru_pc_ssh_config.addr in global_btslog_stream_port:
        last_port = global_btslog_stream_port[ru_pc_ssh_config.addr][-1]
        new_port = last_port + 1
        global_btslog_stream_port[ru_pc_ssh_config.addr].append(new_port)
        return new_port
    else:
        global_btslog_stream_port[ru_pc_ssh_config.addr] = [BASE_BTSLOG_STREAM_PORT]
        return BASE_BTSLOG_STREAM_PORT


def stop_to_collect_and_save_ru_logs():
    """
    The keyword used for stopping to collect RU logs and save logs.
    This function stops the collection of RU logs and saves the logs. It performs the following steps:
    1. Stops monitoring for enabling LMI ETH on RU reboot for the master serial port.
    2. Downloads the serial logs for each serial port.
    3. Stops the BTS log collector and saves the log.
    """

    logger = get_logger_for_ru_collector()
    global total_rus_collectors

    logger.info("stop collecting ru logs and save logs")
    for ru_collectors in total_rus_collectors:
        serial_collectors = ru_collectors["serials"]

        if not serial_collectors:
            continue

        master_serial_collector = serial_collectors[0]
        master_serial_collector.stop_monitor_for_enable_lmi_eth_on_ru_reboot()

        for serial_collector in serial_collectors:
            serial_collector.download_serial_log()
            serial_collector.merge_serial_logs()

        btslog_collector = ru_collectors["btslog"]
        if not btslog_collector:
            continue
        test_status = BuiltIn().get_variable_value("${TEST STATUS}")
        logger.info("test case is {}, will download ru btslog to local VM".format(test_status))

        should_download_to_local_vm = test_status != "PASS"
        stop_btslog_collector_and_save_log(btslog_collector, should_download_to_local_vm=should_download_to_local_vm)

    logger.info("disconnect serial port")
    for ru_collectors in total_rus_collectors:
        serial_collectors = ru_collectors["serials"]
        for serial_collector in serial_collectors:
            serial_collector.disconnect()

    logger.info("stop docker container if exists")
    rus = get_rus_from_tl()
    for ru in rus:
        with RuPcDockerManager(ru.lmi.host.default_ssh_connection_details, logger) as ru_pc_docker:
            if ru_pc_docker.is_docker_supported() and ru_pc_docker.is_container_alive():
                ru_pc_docker.stop_container()

    total_rus_collectors = []


def get_rus_from_tl():
    """
    The keyword used for getting the RUs from the testline configuration.
    :return: The RUs from the testline configuration.
    """
    tl = BuiltIn().get_variable_value("${tl}")
    rus = tl.gnbs[0].dus[0].rus
    if not rus:
        return []
    return rus
