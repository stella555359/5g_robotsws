# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Haofeng Zhu
:contact: haofeng.zhu@nokia-sbell.com
:maintainer: Haofeng Zhu
:contact: haofeng.zhu@nokia-sbell.com
"""

import time
from taf.transport.ssh import ssh


class RemoteRuPc(object):

    """
    The class used for remote RU PC operations
    """

    DEFAULT_BTSLOG_DIR_PATH = ""
    DEFAULT_BTSLOG_APP_NAME = ""
    DEFAULT_BTSLOG_LAUNCHER_NAME = ""

    DEFAULT_BTSLOG_CONFIG_PATH = ""
    DEFAULT_BTSLOG_LOG_DIR_PATH = ""

    BTSLOG_SERVER_START_COMMAND_FORMAT = '"{app_path}/{app_name}" -NOGUI'
    BTSLOG_LAUNCHER_START_COMMAND_FORMAT = '"{app_path}/{launcher_name}" start_udplog'
    BTSLOG_LAUNCHER_STOP_COMMAND_FORMAT = '"{app_path}/{launcher_name}" stop_udplog'
    COMPRESS_BTSLOG_COMMAND = "tar -czvf {compressed_file_name} SYSLOG_*"
    COMPRESSED_FILE_PREFIX = "ru_btslog"

    def __init__(self,
                 ssh_proxy=None,
                 ssh_alias=None,
                 btslog_dir_path="",
                 btslog_app_name="",
                 btslog_launcher_name="",
                 btslog_log_dir_path="",
                 serial_number="",
                 logger=None,
                 btslog_stream_port=51001):

        self.ssh_proxy = ssh_proxy
        self.ssh_alias = ssh_alias

        self.btslog_dir_path = btslog_dir_path or self.DEFAULT_BTSLOG_DIR_PATH
        self.btslog_app_name = btslog_app_name or self.DEFAULT_BTSLOG_APP_NAME
        self.btslog_launcher_name = btslog_launcher_name or self.DEFAULT_BTSLOG_LAUNCHER_NAME
        self.btslog_log_dir_path = btslog_log_dir_path or self.DEFAULT_BTSLOG_LOG_DIR_PATH
        self.serial_number = serial_number

        self.logger = logger
        self.btslog_stream_port = btslog_stream_port
        self.invoke_shells = []
        self.compressed_file_name = "{}_{}_from_{}.tar.gz".format(self.COMPRESSED_FILE_PREFIX,
                                                                  self.serial_number,
                                                                  ssh_alias)

        """
        Store RU PC host and username for reconnecting ssh
        """
        self.host = ""
        self.port = 22
        self.username = ""
        self.password = ""

    @classmethod
    def setup_from_config(cls,
                          host="",
                          port=22,
                          username="",
                          password="",
                          btslog_dir_path="",
                          btslog_app_name="",
                          btslog_launcher_name="",
                          btslog_log_dir_path="",
                          serial_number="",
                          logger=None,
                          using_docker_solution=False,
                          btslog_stream_port=51001):
        """
        setup remote RU PC from configuration
        :param host: RU PC host
        :param port: RU PC ssh port
        :param username: RU PC ssh username
        :param password: RU PC ssh password
        :param btslog_dir_path: BTSLog application path on RU PC
        :param btslog_app_name: BTSLog application name
        :param btslog_launcher_name: BTSLog launcher name
        :param btslog_log_dir_path: BTSLog log directory path on RU PC
        :param serial_number: RU serial number
        :param logger: logger for debugging
        :param using_docker_solution: flag to indicate whether to use the docker solution
        :param btslog_stream_port: port for btslog stream
        :return: RemoteRuPc instance
        """
        ssh_alias = "ru_pc_{}".format(host)
        ssh_proxy = ssh()
        ssh_proxy.connect_to(hostname=host,
                             port=port,
                             username=username,
                             password=password,
                             alias=ssh_alias)
        if using_docker_solution:
            ru_pc = DockerContainerRuPc(ssh_proxy=ssh_proxy,
                                        ssh_alias=ssh_alias,
                                        btslog_dir_path=btslog_dir_path,
                                        btslog_app_name=btslog_app_name,
                                        btslog_launcher_name=btslog_launcher_name,
                                        btslog_log_dir_path=btslog_log_dir_path,
                                        serial_number=serial_number,
                                        logger=logger,
                                        btslog_stream_port=btslog_stream_port)
            ru_pc.host = host
            ru_pc.port = port
            ru_pc.username = username
            ru_pc.password = password
            return ru_pc

        output = ssh_proxy.execute(command="uname -s", connection=ssh_alias)
        if cls.is_remote_pc_windows(output):
            ru_pc = WindowsRuPc(ssh_proxy=ssh_proxy,
                                ssh_alias=ssh_alias,
                                btslog_dir_path=btslog_dir_path,
                                btslog_app_name=btslog_app_name,
                                btslog_launcher_name=btslog_launcher_name,
                                btslog_log_dir_path=btslog_log_dir_path,
                                serial_number=serial_number,
                                logger=logger)
            ru_pc.host = host
            ru_pc.port = port
            ru_pc.username = username
            ru_pc.password = password
            return ru_pc

        ru_pc = LinuxRuPc(ssh_proxy=ssh_proxy,
                          ssh_alias=ssh_alias,
                          btslog_dir_path=btslog_dir_path,
                          btslog_app_name=btslog_app_name,
                          btslog_launcher_name=btslog_launcher_name,
                          btslog_log_dir_path=btslog_log_dir_path,
                          serial_number=serial_number,
                          logger=logger)
        ru_pc.host = host
        ru_pc.port = port
        ru_pc.username = username
        ru_pc.password = password
        return ru_pc

    def reconnect_ssh(self):
        self.ssh_alias = "ru_pc_{}_{}".format(self.host, time.time())
        ssh_proxy = ssh()
        ssh_proxy.connect_to(hostname=self.host,
                             port=self.port,
                             username=self.username,
                             password=self.password,
                             alias=self.ssh_alias)

    def invoke_shell_execute(self, command):
        ssh_connection = self.ssh_proxy.get_connection_by_alias(self.ssh_alias)
        invoke_shell = ssh_connection.invoke_shell()
        invoke_shell.send(command + "\r\n")
        self.invoke_shells.append(invoke_shell)

    @classmethod
    def is_remote_pc_windows(cls, uname_output):
        '''
        $ uname -s
        CYGWIN_NT-10.0-19045
        '''
        return "cygwin" in uname_output.lower()

    def start_btslog_server(self):
        start_command = self.BTSLOG_SERVER_START_COMMAND_FORMAT.format(app_path=self.btslog_dir_path,
                                                                       app_name=self.btslog_app_name)
        output = self.ssh_proxy.execute(command="nohup {} > /dev/null 2>&1 &".format(start_command),
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("start btslog server {}".format(output))

    def stop_btslog_server(self):
        raise NotImplementedError

    def start_btslog_launcher(self):
        start_command = self.BTSLOG_LAUNCHER_START_COMMAND_FORMAT.format(app_path=self.btslog_dir_path,
                                                                         launcher_name=self.btslog_launcher_name)

        """
        Workaround to make sure the "start udp log" operation is executed successfully.
        The "start udp log" operation is not successful at sometimes.
        If operation is not successful, the ru bts log will not be collected.
        So we can check the udp log status by start udp log command again.
        If the output contains "UDP already started!", it means the udp log is already started.

        The first execution output of start udp log command:
        $ ./BTSLog_launcher.exe start_udplog
        Qt: Untested Windows version 10.0 detected!

        The second execution output of start udp log command:
        $ ./BTSLog_launcher.exe start_udplog
        Qt: Untested Windows version 10.0 detected!
        UDP already started!
        """
        retry = 3
        while retry:
            output = self.ssh_proxy.execute(command=start_command,
                                            connection=self.ssh_alias,
                                            timeout=60)
            self.logger.info("{} start btslog launcher {}".format(self.ssh_alias, output))
            if "UDP already started" in output:
                break
            retry -= 1

    def stop_btslog_launcher(self):
        stop_command = self.BTSLOG_LAUNCHER_STOP_COMMAND_FORMAT.format(app_path=self.btslog_dir_path,
                                                                       launcher_name=self.btslog_launcher_name)
        output = self.ssh_proxy.execute(command=stop_command,
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("stop btslog launcher {}".format(output))

    def is_btslog_process_exist(self):
        raise NotImplementedError

    def clear_log(self):
        output = self.ssh_proxy.execute(command="rm -f {}/BTSLOG_*".format(self.btslog_log_dir_path),
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("removed BTSLOG prefix files {}".format(output))

        output = self.ssh_proxy.execute(command="rm -f {}/SYSLOG_*".format(self.btslog_log_dir_path),
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("removed SYSLOG prefix files {}".format(output))

        output = self.ssh_proxy.execute(command="rm -f {}/{};ls -l {}".format(self.btslog_log_dir_path,
                                                                              self.compressed_file_name,
                                                                              self.btslog_log_dir_path),
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("removed compressed file {}".format(output))

    def download_log(self, local_dir_path, should_download_to_local_vm=True):
        compress_command = self.COMPRESS_BTSLOG_COMMAND.format(compressed_file_name=self.compressed_file_name)
        command = "cd {}; {}; ls -l".format(self.btslog_log_dir_path, compress_command)
        output = self.ssh_proxy.execute(command=command,
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("compressed syslog files {}".format(output))

        command = "cd {}; du -h {}".format(self.btslog_log_dir_path, self.compressed_file_name)
        output = self.ssh_proxy.execute(command=command,
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("collected ru bts log size: {}".format(output))

        if not should_download_to_local_vm:
            self.logger.info("skip download ru bts log to local vm")
            return

        local_dir_path = local_dir_path.rstrip("/").rstrip("\\")
        local_file_path = "{}/{}".format(local_dir_path, self.compressed_file_name)
        remote_file_path = "{}/{}".format(self.btslog_log_dir_path, self.compressed_file_name)
        self.ssh_proxy.download_file(remote_path=remote_file_path,
                                     local_path=local_file_path,
                                     connection=self.ssh_alias,
                                     timeout=30)
        self.logger.info("syslog file has been saved in {} from remote {}".format(local_file_path, remote_file_path))

    def teardown(self):
        self.ssh_proxy.disconnect(connection=self.ssh_alias)
        self.logger.info("disconnect ssh connection to {}".format(self.ssh_alias))


class WindowsRuPc(RemoteRuPc):

    """
    Windows os RU PC operations class.
    """

    DEFAULT_BTSLOG_DIR_PATH = "C:/Program Files (x86)/BTSLog2"
    DEFAULT_BTSLOG_APP_NAME = "BTSlog2.exe"
    DEFAULT_BTSLOG_LAUNCHER_NAME = "BTSLog_launcher.exe"

    DEFAULT_BTSLOG_CONFIG_PATH = "C:/ProgramData/BTSLog2/btslog.ini"
    DEFAULT_BTSLOG_LOG_DIR_PATH = "/cygdrive/c/TEMP/Logs"
    COMPRESS_BTSLOG_COMMAND = "tar -czvf {compressed_file_name} *SYSLOG_*"

    def clear_log(self):
        output = self.ssh_proxy.execute(command="rm -f {}/*BTSLOG_*".format(self.btslog_log_dir_path),
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("removed BTSLOG prefix files {}".format(output))

        output = self.ssh_proxy.execute(command="rm -f {}/*SYSLOG_*".format(self.btslog_log_dir_path),
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("removed SYSLOG prefix files {}".format(output))

        output = self.ssh_proxy.execute(command="rm -f {}/{};ls -l {}".format(self.btslog_log_dir_path,
                                                                              self.compressed_file_name,
                                                                              self.btslog_log_dir_path),
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("removed compressed file {}".format(output))

    def stop_btslog_server(self):
        kill_command = "taskkill /IM {} /F".format(self.btslog_app_name)
        output = self.ssh_proxy.execute(command=kill_command,
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("stop btslog process {}".format(output))

    def is_btslog_process_exist(self):
        output = self.ssh_proxy.execute(command="tasklist | grep {}".format(self.btslog_app_name),
                                        connection=self.ssh_alias,
                                        timeout=60)
        return self.btslog_app_name in output


class LinuxRuPc(RemoteRuPc):

    """
    Linux os RU PC operations class.
    """

    DEFAULT_BTSLOG_DIR_PATH = "/opt/btslog"
    DEFAULT_BTSLOG_APP_NAME = "btslog"
    DEFAULT_BTSLOG_LAUNCHER_NAME = "btslog_launcher"

    DEFAULT_BTSLOG_CONFIG_PATH = "/home/ute/btslog2/btslog.ini"
    DEFAULT_BTSLOG_LOG_DIR_PATH = "/tmp/btslog2"

    def start_btslog_server(self):
        start_command = self.BTSLOG_SERVER_START_COMMAND_FORMAT.format(app_path=self.btslog_dir_path,
                                                                       app_name=self.btslog_app_name)
        self.invoke_shell_execute(start_command)

        output = self.ssh_proxy.execute(command="ps -ef| grep btslog",
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("ps -ef : {}".format(output))

    def stop_btslog_server(self):
        kill_command = 'sudo pkill -9 -f -x "{}/{} -NOGUI"'.format(self.btslog_dir_path, self.btslog_app_name)
        output = self.ssh_proxy.execute(command=kill_command,
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("stop btslog process {}".format(output))

    def is_btslog_process_exist(self):
        query_process_command = "ps -ef | grep {}".format(self.btslog_app_name)
        output = self.ssh_proxy.execute(command=query_process_command,
                                        connection=self.ssh_alias,
                                        timeout=60)
        return self.btslog_app_name in output


class DockerContainerRuPc(RemoteRuPc):

    """
    Docker Container RU PC operations class.
    """
    """
    nc -u -l -p 51001
    """
    _NETCAT_BTSLOG_COLLECT_COMMAND = "nc -u -l -p {}"
    _BTSLOG_FILE_NAME = "SYSLOG.log"
    _DEFAULT_BTSLOG_SAVED_PATH = "/tmp/" + _BTSLOG_FILE_NAME
    _DEFAULT_COMPRESSED_BTSLOG_SAVED_PATH = "/tmp/btslog.tar.gz"
    COMPRESS_BTSLOG_COMMAND = "tar -czvf {compressed_file_name} " + _BTSLOG_FILE_NAME
    DEFAULT_BTSLOG_LOG_DIR_PATH = "/tmp/"

    def start_btslog_server(self):
        self.start_command = self._NETCAT_BTSLOG_COLLECT_COMMAND.format(self.btslog_stream_port)
        self.logger.info("start btslog collector: '{}'".format(self.start_command))
        self.invoke_shell_execute(self.start_command + " > " + self._DEFAULT_BTSLOG_SAVED_PATH)

        output = self.ssh_proxy.execute(command="ps -ef| grep '{}'".format(self.start_command),
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("ps -ef : {}".format(output))

    def stop_btslog_server(self):
        self.start_command = self._NETCAT_BTSLOG_COLLECT_COMMAND.format(self.btslog_stream_port)
        kill_command = 'pkill -9 -f -x "{}"'.format(self.start_command)
        self.logger.info("stop btslog collect: '{}'".format(kill_command))
        output = self.ssh_proxy.execute(command=kill_command,
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("stop btslog process {}".format(output))

    def is_btslog_process_exist(self):
        self.start_command = self._NETCAT_BTSLOG_COLLECT_COMMAND.format(self.btslog_stream_port)
        query_process_command = "ps -ef | grep '{}'".format(self.start_command)
        output = self.ssh_proxy.execute(command=query_process_command,
                                        connection=self.ssh_alias,
                                        timeout=60)
        return self.start_command in output

    def clear_log(self):
        output = self.ssh_proxy.execute(command="rm -f {}".format(self._DEFAULT_BTSLOG_SAVED_PATH),
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("removed SYSLOG files {}".format(output))

        output = self.ssh_proxy.execute(command="rm -f {}".format(self._DEFAULT_COMPRESSED_BTSLOG_SAVED_PATH),
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("removed compressed file {}".format(output))

    def download_log(self, local_dir_path, should_download_to_local_vm=True):
        compress_command = self.COMPRESS_BTSLOG_COMMAND.format(compressed_file_name=self.compressed_file_name)
        command = "cd {}; {}; ls -l".format(self.btslog_log_dir_path, compress_command)
        output = self.ssh_proxy.execute(command=command,
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("compressed syslog files {}".format(output))

        command = "cd {}; du -h {}".format(self.btslog_log_dir_path, self.compressed_file_name)
        output = self.ssh_proxy.execute(command=command,
                                        connection=self.ssh_alias,
                                        timeout=60)
        self.logger.info("collected ru bts log size: {}".format(output))

        if not should_download_to_local_vm:
            self.logger.info("skip download ru bts log to local vm")
            return

        local_dir_path = local_dir_path.rstrip("/").rstrip("\\")
        local_file_path = "{}/{}".format(local_dir_path, self.compressed_file_name)
        remote_file_path = "{}/{}".format(self.btslog_log_dir_path, self.compressed_file_name)
        self.ssh_proxy.download_file(remote_path=remote_file_path,
                                     local_path=local_file_path,
                                     connection=self.ssh_alias,
                                     timeout=30)
        self.logger.info("syslog file has been saved in {} from remote {}".format(local_file_path, remote_file_path))

    def start_btslog_launcher(self):
        pass

    def stop_btslog_launcher(self):
        pass


class BTSLogCollector(object):

    """
    The class used for BTSLog collector, which is used for starting and stopping BTSLog collector on remote RU PC.
    """

    def __init__(self, ru_pc, log_save_dir, logger):
        self.ru_pc = ru_pc
        self.log_save_dir = log_save_dir
        self.logger = logger

    def start(self):
        self.ru_pc.clear_log()
        if self.ru_pc.is_btslog_process_exist():
            self.ru_pc.stop_btslog_server()

        self.ru_pc.start_btslog_server()
        self.ru_pc.start_btslog_launcher()

    def stop(self):
        self.ru_pc.stop_btslog_launcher()
        self.ru_pc.stop_btslog_server()

    def download_log(self, should_download_to_local_vm=True):
        self.ru_pc.download_log(self.log_save_dir, should_download_to_local_vm=should_download_to_local_vm)

    def teardown(self):
        self.ru_pc.teardown()


def start_btslog_collector(host="",
                           port=22,
                           username="",
                           password="",
                           btslog_dir_path="",
                           btslog_app_name="",
                           btslog_launcher_name="",
                           btslog_log_dir_path="",
                           log_save_dir="",
                           serial_number="",
                           logger=None,
                           using_docker_solution=False,
                           btslog_stream_port=51001):
    """
    This keyword is used for starting the btslog collector on a remote RU PC.

    :param host: The host of the remote RU PC.
    :param port: The SSH port of the remote RU PC.
    :param username: The SSH username of the remote RU PC.
    :param password: The SSH password of the remote RU PC.
    :param btslog_dir_path: The path of the BTSLog application on the remote RU PC.
    :param btslog_app_name: The name of the BTSLog application.
    :param btslog_launcher_name: The name of the BTSLog launcher.
    :param btslog_log_dir_path: The path of the BTSLog log directory on the remote RU PC.
    :param log_save_dir: The directory where the logs will be saved.
    :param serial_number: The serial number of the RU.
    :param logger: The logger for the btslog collector.
    :param using_docker_solution: The flag to indicate whether to use the docker solution.
    :param btslog_stream_port: The port for btslog stream.
    :return: The BTSLogCollector instance.
    """
    try:
        ru_pc = RemoteRuPc.setup_from_config(host=host,
                                             port=port,
                                             username=username,
                                             password=password,
                                             btslog_dir_path=btslog_dir_path,
                                             btslog_app_name=btslog_app_name,
                                             btslog_launcher_name=btslog_launcher_name,
                                             btslog_log_dir_path=btslog_log_dir_path,
                                             serial_number=serial_number,
                                             logger=logger,
                                             using_docker_solution=using_docker_solution,
                                             btslog_stream_port=btslog_stream_port)
        btslog_collector = BTSLogCollector(ru_pc, log_save_dir, logger)
        btslog_collector.start()
    except Exception as err:
        err_msg = str(err)
        logger.error("failed to start btslog collector for {} error: {}".format(host, err_msg))
        return None
    logger.info("started btslog collector")
    return btslog_collector


def stop_btslog_collector_and_save_log(btslog_collector=None, should_download_to_local_vm=True):
    """
    This keyword is used for stopping the btslog collector and saving the log.

    :param btslog_collector: The btslog collector object.
    :param should_download_to_local_vm: The flag to indicate whether to download the log to the local VM.
    :return: None
    """
    if not btslog_collector:
        return

    retry = 1
    while True:
        try:
            btslog_collector.stop()
            btslog_collector.download_log(should_download_to_local_vm=should_download_to_local_vm)
            btslog_collector.teardown()
            btslog_collector.logger.info("stopped btslog collector")
            return
        except Exception as err:
            err_msg = str(err)
            if retry == 0:
                btslog_collector.logger.error("retry to download ru bts log failed, err is {}".format(err_msg))
                return

            btslog_collector.logger.error("failed to stop btslog collector error: {}".format(err_msg))
            btslog_collector.ru_pc.reconnect_ssh()
            btslog_collector.logger.info("reconnect to the ru pc and try to download ru bts log again")
            retry -= 1
