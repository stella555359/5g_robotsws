from taf.transport.ssh import ssh
from taf.transport.ssh.exceptions import ConnectionError
import logging
import time
import os


class RemoteTLPreparation(object):
    def __init__(self, tl_address, tl_type, target_gnb_sw, commission_prefix):
        """Class for remote TL upgrade and commissioning"""
        self.tl_address = tl_address
        self.tl_type = tl_type
        self.target_gnb_sw = target_gnb_sw
        self.commission_prefix = commission_prefix
        self.remote_tl_alias = tl_address.split(".")[0].replace("-", "_")
        self.local_script_path = os.path.join("/home/ute", "run_script.sh")
        self.remote_script_path = os.path.join("/home/ute/remote_tl_preparation_logs", "run_script.sh")
        self.execution_log_path = os.path.join("/home/ute/remote_tl_preparation_logs", "exec_log.txt")
        self.commission_logs_path = os.path.join("/home/ute/remote_tl_preparation_logs", "commission_logs")
        self.upgrade_logs_path = os.path.join("/home/ute/remote_tl_preparation_logs", "upgrade_logs")
        self.tl_configuration_path = os.path.join("/home/ute/testline_configuration", self.remote_tl_alias)
        self.remote_vm_connection = None
        self.tasks_list = []

    def start_tasks_list_on_target_machine(self):
        """
        Start execution of defined tasks with target vm.

        :return: None
        """
        self._generate_script()
        self._establish_remote_vm_connection()
        self.remote_vm_connection.execute("mkdir /home/ute/remote_tl_preparation_logs")
        self.remote_vm_connection.upload_file(local_path=self.local_script_path, remote_path=self.remote_script_path)
        self.remote_vm_connection.upload_file(
            local_path=os.path.join(os.path.realpath(os.path.dirname(__file__)), "commission.robot"),
            remote_path="/home/ute/commission.robot")
        self.remote_vm_connection.execute(command="chmod +x {}".format(self.remote_script_path))
        self.remote_vm_connection.send_command(
            command="nohup {} > {} 2>&1 &".format(self.remote_script_path, self.execution_log_path))

    def add_prepare_environment_task(self):
        """
        Add environment preparation commends to tasks list.

        :return: None
        """
        self.tasks_list.append("git clone 'https://gerrit.ext.net.nokia.com/gerrit/MN/UTE/testline_configuration'")
        self.tasks_list.append("git clone 'https://gerrit.ext.net.nokia.com/gerrit/MN/UTE/robotws'")
        self.tasks_list.append("mkdir /home/ute/remote_prep_env")
        self.tasks_list.append("virtualenv /home/ute/remote_prep_env")
        self.tasks_list.append("source /home/ute/remote_prep_env/bin/activate")
        self.tasks_list.append("pip install --upgrade pip")
        self.tasks_list.append("cd /home/ute/robotws")
        self.tasks_list.append("pip install -U -r requirements.cfg")
        self.tasks_list.append("cd")
        self.tasks_list.append("deactivate")
        self.tasks_list.append("mv /home/ute/commission.robot /home/ute/robotws")
        self.tasks_list.append("echo 'TL ENV preparation finished with success'")

    def add_upgrade_classical_tl_task(self):
        """
        Add upgrade process (with usage of agent_5g_classical) to tasks list.

        :return: None
        """
        agent_5g_cmd = "agent_5g_classical init -l '{}' -b '{}' -o '/home/ute/output' -s 'sw_uploaded' " \
                       "-R '{}' -p '{}'".format(self.tl_type, self.target_gnb_sw, self.upgrade_logs_path,
                                                self.tl_configuration_path)
        self.tasks_list.append("source /opt/ute/agent_env/bin/activate")
        self.tasks_list.append(agent_5g_cmd)

    def add_commission_tl_task(self):
        """
        Add commission process (with usage of defined robot test suite) to tasks list.

        :return: None
        """
        branch_alias = "SBTS00" if "SBTS00" in self.target_gnb_sw else self.target_gnb_sw
        asir_tl = True if "ASIR" in self.tl_type else False
        robot_commission_cmd = \
            "robot -v SCF_PREFIX:{} -v ASIR:{} -v CONFIGURATION:Krakow.{} -v ENB_BUILD:{} -v ENB_BRANCH:{} -L TRACE " \
            "-b debug.log --outputdir {} -V {} {}".format(
                self.commission_prefix, asir_tl, self.remote_tl_alias, self.target_gnb_sw, branch_alias,
                self.commission_logs_path, self.tl_configuration_path, "/home/ute/robotws/commission.robot")
        self.tasks_list.append("cd /home/ute/robotws")
        self.tasks_list.append("source /home/ute/remote_prep_env/bin/activate")
        self.tasks_list.append(robot_commission_cmd)

    def monitor_tl_preparation_flow(self):
        """
        Monitor all stages of tl preparation flow.

        :return: None
        """
        self._wait_for_tl_env_preparation_process_to_finish()
        self._wait_for_tl_upgrade_process_to_finish()
        self._wait_for_tl_commission_process_to_finish()

    def verify_if_vm_is_ready_for_upgrade_procedure_start(self):
        """
        Verify if VM is ready for preparation flow (check if there is no ongoing tasks on VM).

        :return: None
        """
        self._establish_remote_vm_connection()
        env_preparation_ongoing = self._check_if_tl_env_preparation_script_ongoing()
        tl_upgrade_ongoing = self._check_if_tl_upgrade_ongoing()
        commissioning_ongoing = self._check_if_tl_commissioning_ongoing()
        if env_preparation_ongoing or tl_upgrade_ongoing or commissioning_ongoing:
            logging.error("TL env preparation ongoing") if env_preparation_ongoing else None
            logging.error("TL upgrade ongoing") if tl_upgrade_ongoing else None
            logging.error("TL commission ongoing") if commissioning_ongoing else None
            raise Exception("Cannot start remote upgrade procedure due to ongoing operations")
        else:
            logging.info("VM ready for upgrade procedure")

    def _establish_remote_vm_connection(self):
        if not self.remote_vm_connection:
            try:
                self.remote_vm_connection = ssh()
                self.remote_vm_connection.connect_to(hostname=self.tl_address, username="ute", password="uteUTE!")
            except ConnectionError:
                self.remote_vm_connection = ssh()
                self.remote_vm_connection.connect_to(hostname=self.tl_address, username="ute", password="ute")

    def _generate_script(self):
        with open(self.local_script_path, "w") as script_file:
            script_file.write("#!/usr/bin/env bash\n\n")
            [script_file.write("{}\n".format(task)) for task in self.tasks_list]
        script_file.close()

    def _terminate_tl_env_preparation_script(self):
        tl_preparation_process_pid = self.remote_vm_connection.execute(
            command="pgrep -f '/home/ute/remote_tl_preparation_logs/run_script.sh'")
        self.remote_vm_connection.execute(command="sudo kill {}".format(tl_preparation_process_pid))

    def _terminate_tl_upgrade(self):
        tl_upgrade_process_pid = self.remote_vm_connection.execute(
            command="pgrep -f '/opt/ute/agent_env/bin/agent_5g_classical init'")
        self.remote_vm_connection.execute(command="sudo kill {}".format(tl_upgrade_process_pid))

    def _terminate_tl_commissioning(self):
        tl_commission_process_pid = self.remote_vm_connection.execute(command="pgrep -f 'robot'")
        self.remote_vm_connection.execute(command="sudo kill {}".format(tl_commission_process_pid))

    def _check_if_tl_env_preparation_script_ongoing(self):
        tl_preparation_process_pid = self.remote_vm_connection.execute(
            command="pgrep -f '/home/ute/remote_tl_preparation_logs/run_script.sh'")
        if tl_preparation_process_pid:
            return True
        else:
            return False

    def _check_if_tl_upgrade_ongoing(self):
        tl_upgrade_process_pid = self.remote_vm_connection.execute(
            command="pgrep -f '/opt/ute/agent_env/bin/agent_5g_classical init'")
        if tl_upgrade_process_pid:
            return True
        else:
            return False

    def _check_if_tl_commissioning_ongoing(self):
        tl_commission_process_pid = self.remote_vm_connection.execute(command="pgrep -f 'robot'")
        if tl_commission_process_pid:
            return True
        else:
            return False

    def _check_for_pattern_in_execution_log(self, pattern):
        matched_lines = self.remote_vm_connection.execute(
            command="grep '{}' {}".format(pattern, self.execution_log_path))
        if matched_lines:
            return True
        else:
            return False

    def _wait_for_tl_env_preparation_process_to_finish(self, timeout=30):
        while timeout > 0:
            if self._check_for_pattern_in_execution_log("TL ENV preparation finished with success"):
                logging.info("TL env preparation finished with success")
                break
            elif not self._check_if_tl_env_preparation_script_ongoing():
                raise Exception("TL env preparation finished with failure")
            else:
                logging.info("TL env preparation in progress ...")
            time.sleep(60)
            timeout -= 1
        else:
            self._terminate_tl_env_preparation_script()

    def _wait_for_tl_upgrade_process_to_finish(self, timeout=60):
        while timeout > 0:
            if self._check_for_pattern_in_execution_log("EXECUTION SUCCESSFUL"):
                logging.info("TL upgrade finished with success")
                break
            elif not self._check_if_tl_upgrade_ongoing():
                raise Exception("TL upgrade finished with failure")
            else:
                logging.info("TL upgrade in progress ...")
            time.sleep(60)
            timeout -= 1
        else:
            self._terminate_tl_upgrade()

    def _wait_for_tl_commission_process_to_finish(self, timeout=60):
        while timeout > 0:
            if self._check_for_pattern_in_execution_log("| PASS |"):
                logging.info("TL commission finished with success")
                break
            elif not self._check_if_tl_commissioning_ongoing():
                raise Exception("TL commission finished with failure")
            else:
                logging.info("TL commission in progress ...")
            time.sleep(60)
            timeout -= 1
        else:
            self._terminate_tl_commissioning()


def perform_remote_tl_preparation(tl_address, tl_type, target_gnb_sw, commission_prefix):
    """
    Function for remote TL preparation with usage of generated bash script which is run on target VM.

    :param tl_address: IP address of target VM in fqdn format
    :param tl_type: target TL topology type
    :param target_gnb_sw: target SW build
    :param commission_prefix: prefix of target SCF file available for defined TL
    :return: None
    """

    upgrade_runner = RemoteTLPreparation(tl_address=tl_address, tl_type=tl_type, target_gnb_sw=target_gnb_sw,
                                         commission_prefix=commission_prefix)
    upgrade_runner.verify_if_vm_is_ready_for_upgrade_procedure_start()
    upgrade_runner.add_prepare_environment_task()
    upgrade_runner.add_upgrade_classical_tl_task()
    upgrade_runner.add_commission_tl_task()
    upgrade_runner.start_tasks_list_on_target_machine()
    upgrade_runner.monitor_tl_preparation_flow()
