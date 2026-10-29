"""
################################################################################
Egen logs collector module.
This module provides functions to start and stop Egen logs collection.
It also provides a function to download the collected logs from the Egen device
################################################################################

:author: Mateusz Potoniec
:contact: mateusz.potoniec@nokia.com
:maintainer: mateusz.potoniec@nokia.com

################################################################################
Example of how to use EgenLogsCollector in your test case.
This example shows how to create an instance of EgenLogsCollector, with
eCIPRI and MSG5 filters, and start/stop logs collection.
################################################################################

Example:

    host = "egen-host.p02.ska-lab.nsn-rdnet.net"
    login = "egen_user"
    password = "egen_password"
    file_name = "egen_logs.pcap"
    timeout = 600  # Timeout for the Egen logs collection command in seconds

    cores = "1-4"
    ports = ["4:00.0", "4:00.1", "3:00.0", "3:00.1"]
    additional_options = "--constant-timing --terminate --filter-string 'is_ecpri == 1 && msgtype == 5'"

    egen_logs_collector = EgenLogsCollector(
        host=host,
        login=login,
        password=password,
        file_name=file_name,
        cores=cores,
        ports=ports,
        additional_options=additional_options,
    )

    egen_logs_collector.start_logs_collection(timeout=timeout)
    ...
    your test logic
    ...
    egen_logs_collector.stop_logs_collection()
    egen_logs_collector.download_logs(local_dir="/path/to/local/dir")
    OR
    egen_logs_collector.stop_logs_collection_and_download_logs(local_dir="/path/to/local/dir")
    ...
    Or download pcap file with egen logs from egen device via own script / manually.
    ...
    Further postprocessing of logs
    Cheching egen logs with for example taf.analyzer.pcap library.
    ...

################################################################################
After logs collection is completed, you may need to transfer the pcap file
from the Egen device to your local machine with EgenLogsCollector or on your own
################################################################################
"""

from typing import List, Optional

from robot.api import logger
from robot.api.deco import keyword

from moler.device import DeviceFactory
from taf.ul.moler.converter import add_unix_remote_device_to_already_loaded_configuration
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.transfer_files import download_files


class EgenLogsCollector:
    def __init__(self, host: str, login: str, password: str, file_name: str, cores: str, ports: List[str],
                 additional_options: Optional[str] = None, egen_path: str = "./egen", use_sudo: bool = True,
                 remote_dir: str = "/home/egenuser"):
        """
        Initialize EgenLogsCollector.
        The class collects Egen logs using remote host, and stres it to pcap file.
        The class uses Moler to connect to Egen device and start/stop logs collection.

        :param host: Hostname or IP address of the Egen device.
        :param login: Login for the Egen device.
        :param password: Password for the Egen device.
        :param file_name: Name of the file to store the logs: (Egen CMD parameter) (with extension .pcap).
        :param cores: Number of cores to use for Egen logs collection: (Egen CMD parameter).
        :param ports: List of ports to use for Egen logs collection: (Egen CMD parameter).
        :param additional_options: Additional options for Egen logs collection: (Egen CMD parameter).
        :param egen_path: Path to the Egen executable on the remote device (Default: "./egen").
        :param use_sudo: Whether to use sudo to run the Egen command (Default: True).
        :param remote_dir: Remote directory where the logs will be stored (Default: "/home/egenuser").
        """

        self._host = host
        self._login = login
        self._password = password

        self._cores = cores
        self._ports = ports
        self._additional_options = additional_options
        self._file_name = file_name

        self._egen_path = egen_path
        self._use_sudo = use_sudo
        self._remote_dir = remote_dir

        self._egen_device_name = 'EGEN'
        self._egen_device = self._create_egen_device()
        self._egen_cmd = self._create_egen_cmd()
        self._egen_cmd_object = self._create_egen_cmd_object()

    @property
    def egen_device(self):
        """
        Get the Egen device object.

        :return: The Egen device object.
        """
        if self._egen_device is None:
            logger.warning("Egen device is not initialized")
        return self._egen_device

    @property
    def egen_cmd(self):
        """
        Get the Egen command string.

        :return: The Egen command string.
        """
        if self._egen_cmd is None:
            logger.warning("Egen command is not initialized")
        return self._egen_cmd

    @property
    def egen_cmd_object(self):
        """
        Get the Egen command object.

        :return: The Egen command object.
        """
        if self._egen_cmd_object is None:
            logger.warning("Egen command object is not initialized")
        return self._egen_cmd_object

    @keyword()
    @load_moler_configuration_from_tl()
    def start_logs_collection(self, timeout: int = 600) -> None:
        """
        Start Egen logs collection.

        :param timeout: Timeout for the Egen logs collection command in seconds (Default: 600s).
        """

        logger.debug(f"Running Egen logs collecting with cmd: {self._egen_cmd}")
        self._egen_cmd_object.start(timeout=timeout)
        logger.info(f"Egen logs collection run successfully. Timeout: {timeout} seconds")

    @keyword()
    def stop_logs_collection(self) -> None:
        """
        Stop Egen logs collection.
        """

        logger.debug(f"Stopping egen logs collection")
        self._egen_cmd_object.cancel()
        logger.info(f"Egen logs collection stopped")

    @keyword()
    def download_logs(self, local_dir: str) -> str:
        """
        Download Egen logs from the device to the local directory.

        :param local_dir: Local directory to store the downloaded logs.

        :return: Path to the downloaded logs file.
        """

        logger.debug(f"Downloading Egen logs from device {self._egen_device_name} to local directory {local_dir}")
        download_files(
            local_dir=local_dir,
            remote_file=self._file_name,
            device_name=self._egen_device_name,
            remote_dir=self._remote_dir,
        )
        logger.info(f"Egen logs downloaded to {local_dir}/{self._file_name}")
        return f"{local_dir}/{self._file_name}"

    def stop_logs_collection_and_download_logs(self, local_dir: str) -> str:
        """
        Stop Egen logs collection and download logs to the local directory.
        :param local_dir: Local directory to store the downloaded logs.

        :return: Path to the downloaded logs file.
        """

        self.stop_logs_collection()
        return self.download_logs(local_dir=local_dir)

    def _create_egen_cmd_object(self) -> object:
        """
        Get the Egen cmd moler object.

        :return: The Egen command object.
        """
        return self._egen_device.get_cmd(
            cmd_name='run_script',
            cmd_params={'script_command': self._egen_cmd, 'error_regex': '.*error.*([1-9][0-9]+|[1-9])'}
        )

    def _create_egen_cmd(self) -> str:
        """
        Create Egen start logs collection command.

        :return: The command string to start Egen logs collection.
        """

        logger.debug(f"Creating egen command")
        command = f"sudo {self._egen_path} " if self._use_sudo else f"{self._egen_path} "

        command = command + f"--cores {self._cores} "
        for port in self._ports:
            command = command + f"--port {port} "

        if self._additional_options is not None:
            command = command + f"{self._additional_options} "
        command = command + f"--capture {self._file_name}"

        logger.debug(f"Egen Command: {command}")
        return command

    @load_moler_configuration_from_tl()
    def _create_egen_device(self) -> object:
        """
        Create Egen Moler device.

        :return: The Egen device object.
        """

        logger.debug(f"Create egen device")
        add_unix_remote_device_to_already_loaded_configuration(
            host=self._host,
            login=self._login,
            password=self._password,
            device_name=self._egen_device_name
        )
        logger.debug(f"Set egen device")
        return DeviceFactory.get_device(name=self._egen_device_name)
