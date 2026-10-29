from robot.libraries.BuiltIn import BuiltIn
from ute_common_admin.exception import AdminApiProcedureFailureException

from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.sbts.oam.coam.admin import admin
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest, MolerException
import re

root_allowed_processes = \
    ['', 'kthreadd', 'systemd', 'systemd-journal', 'systemd-udevd', 'auditd', 'systemd-logind', 'rcpcpuload',
     'hypertracerolcd', 'ext-sshd', 'sshd', 'agetty', 'Orchestrator', 'rcplogd', 'quoratemonitor', 'logf',
     'alarmsystembuff', 'osmon', 'ipsrd', 'ipsrdmanager', 'rpc.mountd', 'glusterfs', 'symptomreport-server',
     'storage_manager.py', 'local_storage_agent.py', 'bash', 'inotifyrunner', 'inotifyrunner', 'inotifywait',
     'clifwkdaemon', 'rsyslogd', 'relimesg', 'certManServer', 'ksoftirqd/0', 'kworker/0:0H', 'rcu_sched', 'rcu_bh',
     'migration/0', 'migration/2', 'kdevtmpfs', 'netns', 'khungtaskd', 'writeback', 'ksmd', 'crypto', 'bioset',
     'kblockd', 'ata_sff', 'kswapd0', 'acpi_thermal_pm', 'bioset', 'iscsi_eh', 'ipv6_addrconf', 'jbd2/vda1-8',
     'ext4-rsv-conver', 'kauditd', 'avp-worker', 'avp-rx/0', 'scsi_eh_0', 'scsi_tmf_0', 'scsi_eh_1', 'scsi_tmf_1',
     'jbd2/vdf1-8', 'ext4-rsv-conver', 'rpciod', 'nfsiod', 'nfsd', 'etcd', 'eceslaved',
     'logicalipmgmt', 'rcpcoldstandbyproxy', 'alarmsystembuffer', 'avahi-publish',
     'cmactivatorbackend', 'DVMAgent', 'ecehistd', 'ecemasterd', 'iomon', 'lvmetad', 'ods_daemon', 'osmon', 'rcplogd',
     'rulemanager', 'schedmon', 'systemd-journald', 'start_fpdebug.sh', 'fpdebug', 'ipsecstarter', 'starter',
     'ipsecdataprovider', 'eventhandler', 'dpvi-nl-task', 'dnsmanager', 'sessionLimitDataSync',
     'NamespaceManager-SocketServer-', 'hypertracerd', 'aclmanager', 'ksoftirqd', 'migration', 'watchdog', 'watchdogd',
     'mm_percpu_wq', 'oom_reaper', 'sshdipmonitor', 'sync.sh', 'dvm_node_degrade_test.sh', 'bbrotationd.py',
     'kworker', 'cpuhp', 'kcompactd0', 'loop0', 'DHAAgent', 'jbd2', 'rcpUTMPWatcher', 'crond', 'bioset',
     'kdmflush', 'systemdservicemonitor', 'storage_repair.py', 'glusterd', 'glusterfsd', 'trafficmanagerd',
     'rcu_par_gp', 'rcu_gp', 'rcu_tasks_kthre', 'ipmanager', 'kthrotld', 'ipsecha',
     'bbrotationd.py', 'ipseceventhandler', 'fps-nfd', 'fpsd', 'cmgrd', 'fpexec', 'hitflagsd',
     'fp-cpu-usage-daemon', 'fpmd', 'sleep', 'ps -aux', 'syscom-proxy', 'pmagentproxy',
     'cp_cl', 'cp_nb', 'cp-nrt', 'cp_ue', 'cp_sb', 'L2HiCounterClientTracer', 'launch_logging_agent.sh',
     'logging_agent', 'TraceControllerMasterExe', 'bbserver.py', 'sctprdmgr', 'anacron', 'symptomdataprovider']

non_root_allowed_processes = \
    ['', 'dbus-daemon', 'systemd-networkd', 'bfddaemon', 'lemd', 'ntpd', 'AlarmLightProcessor', 'pm9core',
     'redis-server', 'rcpdbim', 'sshd', 'rcpdbrc', 'bfdmanager', 'ipv6dadserver', 'resourcemeas',
     'intsrvpubd', 'eventdaemon', 'avahi-daemon', 'trs_pm_collector',
     'linkstatemonitor', 'providercontroller', 'rpcbind', 'upload.py', 'rsyslogd', 'cmactivator', 'cmengine',
     'hcrotationd.py', 'trs_ctrl', 'trs_psv_cell', 'trs_psv_up', 'trs_fp', 'twampdaemon', 'ruim_replicator', 'pap',
     'charon', 'CCSMCUDaemonExe', 'CCSRTDaemonExe', 'CCSEmDispatcherExe', 'ptp-agent', 'rtmdp', 'rtmdp-manager',
     'metricPMReporter', 'startupApplications.py', 'ntpmonitor', 'ntpserver',
     'ntpclient', 'start_PTPMonitor.sh', 'ptp_agent.sh', 'FaultServiceExe',
     'linuxptp', 'phc2sys', 'inotifywait', 'ods_daemon', 'ipctproxy', 'mpmr_daemon', 'rcpmsgdispatcher',
     'ipctmanager', 'ipv6filter', 'named', 'msgMcuDataProvider', 'msgRtDataProvider', 'nwconfd', 'nwconfagent',
     'cmpluginrunner', 'lripmanager', 'SysComGWProxy', 'ipsetmanager', 'apigwcontroller', 'janus', 'httpd',
     'rcp_pm9_rest_server', 'syscomrouteproxy', 'collectd', 'NE3SAgent', 'AuditLogServer', 'monitorSSF',
     'stunnel', 'triggerdaemon', 'log_error.sh', 'logger', 'log_access.sh', 'log_ssl_access.sh',
     'fsauditcli', 'vault', 'sleep', 'sudo su -c ps -aux', 'su -c ps -aux', 'ps -aux', 'ext-sshd', 'bash',
     'fp-rte', 'msgdispatcher', 'ccs_mgt.appstart', 'ccs_up.appstart', 'givaxi', 'ccs_cp.appstart',
     'rcpalarmrestagent_config.info', 'oamcm.json', 'asm.json', 'fm.json', 'trsconfig.json', 'TAS/TAS',
     'pm.json', 'ims.json', 'med.json', 'cpconfig.json', 'NTS/NTS', 'oamagent.json', 'statsCollect',
     'cp_sctp', 'cp_if', 'sftp-server', 'swmdaemon', 'swmserver']

allowed_users = \
    ['root', 'robot', 'toor4nsn', 'sync', 'halt', 'shutdown', 'operator']

unused_linux_accounts = \
    ['tape', 'floppy', 'digital', 'audio', 'video', 'cdrom', 'game', 'Lighttpd']

allowed_executables = \
    ['/usr/bin/screen-*', '/usr/bin/sudo', '/usr/bin/gpasswd',
     '/usr/bin/chsh', '/usr/bin/chage', '/usr/bin/chfn', '/usr/bin/gpasswd',
     '/usr/libexec/ssh-keysign',
     '/opt/nokia/SS_RCPCCSRT/CCSEmDispatcherExe',  # to be removed after fix from CCS domain
     '/opt/nokia/SS_RCPCCSRT/CCSRTDaemonExe',  # to be removed after fix from CCS domain
     '/opt/nokia/SS_BPUtils/script/fileoperations_peer',  # to be fixed, remove when done
     '/opt/nokia/SS_RUIM/bin/authenticator', '/opt/nokia/SS_LimBash/bin/bash',
     '/opt/nokia/bin/fpGUIauthenticator', '/usr/libexec/dbus-daemon-launch-helper',
     '/usr/local/bin/fusermount', '/bin/su', '/opt/nokia/SS_SCLI/script/ssh_for_scli',
     '/opt/nokia/SS_SCLI/bin/wrapper', '/opt/nokia/SS_SCLI/sbin/sftp-wrapper',
     '/usr/libexec/lxc/lxc-user-nic',
     '/opt/nokia/sbin/fsuidsetter', '/opt/nokia/sbin/fsruidsetter', '/usr/bin/pwauth',
     '/opt/nokia/bin/fpHTTPauthenticator', '/usr/bin/passwd', '/opt/nokia/bin/fileoperations_peer',
     '/usr/bin/crontab', '/usr/bin/su', '/usr/sbin/unix_chkpwd', '/usr/sbin/netreport',
     '/opt/nokia/RCPComMsg/rcpmsgdispatcher', '/usr/bin/fileoperations_peer',
     '/opt/nokia/msgdispatcher/msgdispatcher']

allowed_alarms = \
    [61524, 61652, 4539, 61649, 4527, 6450]


class LinuxHardening:
    """Linux Hardening keywords for CU and DU"""

    def __init__(self):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.admin = admin()
        self.config = load_moler_configuration_from_tl()
        self.ip_address = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
        self.cu_ip_address = tl.gnbs[0].cu.backhaul_site_oam_ip

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_path_environment_variable(self, bts_id=0, vm_tag=None):
        """
        Check if output of command "sudo su -c 'echo $PATH'" NOT contain '.' char.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_echo = cloud_vm.get_cmd(cmd_name="echo", cmd_params={"text": "$PATH", 'text_in_quotation': False})
        result = self._sudo_su_cmd(cloud_vm=cloud_vm, cmd_object=cmd_echo)
        for line in result["RESULT"]:
            if "." in line:
                MolerTest.error("Output contains invalid char '.'")
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_services_and_processes(self, bts_id=0, vm_tag=None):
        """
        Check if output of 'ps -aux" command contain ONLY allowed root processes.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_ps_aux = cloud_vm.get_cmd(cmd_name="ps", cmd_params={"options": "-aux"})
        result = self._sudo_su_cmd(cloud_vm=cloud_vm, cmd_object=cmd_ps_aux)
        not_allowed_root = list()
        not_allowed_non_root = list()
        for process_info in result:
            root_process = bool(re.findall("root", process_info["USER"]))
            if root_process and self._check_if_process_is_forbidden(process_info, root_allowed_processes):
                not_allowed_root.append(process_info["COMMAND"])
            elif not root_process and self._check_if_process_is_forbidden(process_info, non_root_allowed_processes):
                not_allowed_non_root.append(process_info["COMMAND"])
        self._print_forbidden_processes_list(not_allowed_root, not_allowed_non_root)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_terminating_external_interface(self, bts_id=0, vm_tag=None):
        """
        Check if output of 'ps -aux' command NOT contain root forbidden processes.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_ps_aux = cloud_vm.get_cmd(cmd_name="ps", cmd_params={"options": "-aux"})
        result = cmd_ps_aux()
        forbidden_processes = list()
        for process_info in result:
            root_process = bool(re.findall("root", process_info["USER"]))
            forbidden_process_flag = bool(re.findall("(ntpd)|(rcpbind)|(mcproxy)", process_info["COMMAND"]))
            if root_process and forbidden_process_flag:
                forbidden_processes.append(process_info["COMMAND"])
        self._print_forbidden_processes_list(root=forbidden_processes)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_process_user_accounts(self, bts_id=0, vm_tag=None, not_allowed_process=""):
        """
        Check if output of 'ps -aux' command NOT contain not allowed process.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :param not_allowed_process: name of not allowed process
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_ps_aux = cloud_vm.get_cmd(cmd_name="ps", cmd_params={"options": "-aux"})
        result = cmd_ps_aux()
        forbidden_processes = list()
        for process_info in result:
            root_process = bool(re.findall("root", process_info["USER"]))
            forbidden_process_flag = bool(re.findall(not_allowed_process, process_info["COMMAND"]))
            if root_process and forbidden_process_flag:
                forbidden_processes.append(process_info["COMMAND"])
        self._print_forbidden_processes_list(forbidden_processes)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_temporary_accounts(self, bts_id=0, vm_tag=None):
        """
        Check if file /etc/passwd contain ONLY allowed root temporary users.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_cat = cloud_vm.get_cmd(cmd_name="cat", cmd_params={"path": "/etc/passwd"})
        result = cmd_cat()
        not_allowed_users = list()
        for line in result["LINES"]:
            # root:x:0:0:root:/root:/bin/bash
            if line.split(":")[3] == "0" and line.split(":")[0] not in allowed_users:
                not_allowed_users.append(line.split(":")[0])
        if not_allowed_users:
            MolerTest.error("Output contains not allowed temporary users:", dump=not_allowed_users)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_root_writeable_files_a(self, bts_id=0, vm_tag=None):
        """
        Check if there are files owned by root with incorrect permissions '/002'.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_ls = cloud_vm.get_cmd(cmd_name="ls", cmd_params={
            "options": "-la $(find / -xdev -type f -user 0 -perm /002 -print)"})
        output = self._sudo_su_cmd(cloud_vm=cloud_vm, cmd_object=cmd_ls)
        self._verify_permissions(output, r'[-d][-r][-w][-x][-r][-w][-x][-r]w[-x]')
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_root_writeable_files_b(self, bts_id=0, vm_tag=None):
        """
        Check if there are files owned by root with incorrect permissions '/020'.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_ls = cloud_vm.get_cmd(cmd_name="ls", cmd_params={
            "options": "-la $(find / -xdev -type f -user 0 ! -group 0 -perm /020 -print)"})
        output = self._sudo_su_cmd(cloud_vm=cloud_vm, cmd_object=cmd_ls)
        self._verify_permissions(output, r'[-d][-r][-w][-x][-r][-w][-x][-r]w[-x]')
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_system_executables_suid_sgid(self, bts_id=0, vm_tag=None):
        """
        Check if there are files with incorrect permissions '4000' or '2000'.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_string = "$(find / -xdev \\( -perm -4000 -o -perm -2000 \\) -type f -print)"
        cmd_ls_la = cloud_vm.get_cmd(cmd_name="ls", cmd_params={"options": "-la " + cmd_string})
        output = self._sudo_su_cmd(cloud_vm=cloud_vm, cmd_object=cmd_ls_la)
        result = list()
        if output["files"]:
            for _file in output["files"]:
                if _file not in allowed_executables:
                    result.append(_file)
        if result:
            MolerTest.error("Not allowed executables:", dump=result)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_orphaned_files(self, bts_id=0, vm_tag=None):
        """
        Check if there are files with no user and no group.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_find = cloud_vm.get_cmd(cmd_name="find", cmd_params={
            "options": "/ -xdev \\( -nouser -o -nogroup \\) -print"})
        result = self._sudo_su_cmd(cloud_vm=cloud_vm, cmd_object=cmd_find)
        LinuxHardening._verify_output_is_empty(result)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_unauthorized_world_writeable_files(self, bts_id=0, vm_tag=None):
        """
        Check if there are files with forbidden permission '777'.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_find = cloud_vm.get_cmd(cmd_name="find", cmd_params={
            "options": "/ -xdev -type f -perm 777 -exec ls -al {} \\;"})
        result = LinuxHardening._sudo_su_cmd(cloud_vm=cloud_vm, cmd_object=cmd_find)
        LinuxHardening._verify_output_is_empty(result)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_world_writable_directories(self, bts_id=0, vm_tag=None):
        """
        Check if there are files with incorrect permissions '0002'.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_find = cloud_vm.get_cmd(cmd_name="find", cmd_params={
            "options": "/ -xdev -type d \\( -perm -0002 -a ! -perm -1000 \\)"})
        result = self._sudo_su_cmd(cloud_vm, cmd_object=cmd_find)
        LinuxHardening._verify_output_is_empty(result)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def du_world_writable_directories(self, bts_id=0, vm_tag=None):
        """
        Check if there are files with incorrect permissions '0002'.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_find = cloud_vm.get_cmd(cmd_name="find", cmd_params={
            "options": "/ -xdev -type d \\( -perm -0002 -a ! -perm -1000 \\)"})
        result = cmd_find()
        not_allowed_directories = list()
        for directory in result["RESULT"]:
            exception_flag = bool(re.findall(r"(/tftpboot/slot01)|(/var/bci_db)", directory))
            if not exception_flag:
                not_allowed_directories.append(directory)
        if not_allowed_directories:
            MolerTest.error("Output contains NOT allowed directories:", dump=not_allowed_directories)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def du_process_with_lower_privileges(self, bts_id=0, vm_tag=None):
        """
        Check if there are processes for the "btssw" user

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_ps_aux = cloud_vm.get_cmd(cmd_name="ps", cmd_params={"options": "-aux"})
        result = cmd_ps_aux()
        processes = list()
        for process_info in result:
            if process_info["USER"] == "btssw":
                processes.append(process_info["COMMAND"])
        if not processes:
            MolerTest.error("There are no processes for the btssw user")
        else:
            MolerTest.info("Processes for the btssw user:", dump=processes)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def du_path_environment_variable(self, bts_id=0, vm_tag=None):
        """
        Check if output of command "echo $PATH" NOT contain '.' char.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_echo = cloud_vm.get_cmd(cmd_name="echo", cmd_params={"text": "$PATH", 'text_in_quotation': False})
        result = cmd_echo()
        for line in result["RESULT"]:
            if "." in line:
                MolerTest.error("Output contains invalid char '.'")
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def du_unauthorized_world_writeable_directories(self, bts_id=0, vm_tag=None):
        """
        Check if there are files with forbidden permission '777'.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_find = cloud_vm.get_cmd(cmd_name="find", cmd_params={
            "options": "/ -xdev -type d \\( -perm 777 \\)"})
        result = cmd_find()
        not_allowed_777_directories = []
        for directory in result["RESULT"]:
            exception_flag = bool(re.findall(r"(/tftpboot/slot01)|(/var/bci_db)", directory))
            if not exception_flag:
                not_allowed_777_directories.append(directory)
        if not_allowed_777_directories:
            MolerTest.error("Output contains NOT allowed directories:", dump=not_allowed_777_directories)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def du_root_writeable_files(self, bts_id=0, vm_tag=None):
        """
        Check if there are files with forbidden permission '777'.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_find = cloud_vm.get_cmd(cmd_name="find", cmd_params={
            "options": "/ -xdev -type f -perm 777 -exec ls -al {} \\;"})
        result = cmd_find()
        LinuxHardening._verify_output_is_empty(result)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def du_orphaned_files(self, bts_id=0, vm_tag=None):
        """
        Check if there are files with no user and no group.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_find = cloud_vm.get_cmd(cmd_name="find", cmd_params={
            "options": "/ -xdev \\( -nouser -o -nogroup \\) -print"})
        result = cmd_find()
        LinuxHardening._verify_output_is_empty(result)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def find_user_on_bb1(self, bts_id=0, vm_tag=None):
        """
        Check if btssw user exist in '/etc/passwd' directory

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        gnb = self._prepare_device(bts_id, vm_tag)
        cat_cmd = gnb.get_cmd(cmd_name="cat", cmd_params={"path": "/etc/passwd",
                                                          "options": """| awk -F ":" '($1=="btssw") {print $1}'"""})
        result = cat_cmd()
        if result["LINES"][0] == "btssw":
            MolerTest.info("BB1 user found")
        else:
            MolerTest.error("BB1 user not found", raise_exception=True)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def du_crypto_agent_encrypted_file_system(self, bts_id=0, vm_tag=None):
        """
        Check if encfs partition is mounted on '/ffs/fs1/trs_data/active/keystorage' directory.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        gnb = self._prepare_device(bts_id, vm_tag)
        df_cmd = gnb.get_cmd(cmd_name="df")
        directory_regex = re.compile(r'.ffs.fs[1-2].trs_data.active.keystorage')
        result = df_cmd()
        try:
            if re.match(directory_regex, result["by_FS"]["encfs"]["Mounted_on"]):
                MolerTest.info("Encfs partition mounted on /ffs/fs[1-2]/trs_data/active/keystorage found")
            else:
                MolerTest.error("Encfs partition mounted on incorrect directory", raise_exception=True)
        except KeyError:
            MolerTest.error("No encfs partition", raise_exception=True)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def file_permission_rules(self, bts_id=0, vm_tag=None, files_path="/",
                              expected_permission="-rw-r--r--"):
        """
        Check all file permissions are correct in defined path.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :param files_path: path where ls command is executed
        :param expected_permission: expected permissions of files
        :return: None
        """
        expected_permissions = list()
        expected_permissions.append(expected_permission)
        if "shadow" in files_path:
            expected_permissions.extend(LinuxHardening._add_lower_permissions())
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_ls = cloud_vm.get_cmd(cmd_name="ls", cmd_params={"options": "-l", "path": files_path})
        result = cmd_ls()
        for file_name in result["files"]:
            if "link" in result["files"][file_name]:
                if ".." in result["files"][file_name]["link"]:
                    result["files"][file_name]["link"] = result["files"][file_name]["link"][2:]
                cmd_ls = cloud_vm.get_cmd(cmd_name="ls",
                                          cmd_params={"options": "-l", "path": result["files"][file_name]["link"]})
                result = cmd_ls()
        for file_name in result["files"]:
            if not result["files"][file_name]["permissions"] in expected_permissions:
                MolerTest.error("File '{}' should have '{}' permission but it has '{}' "
                                "permission".format(file_name, expected_permissions,
                                                    result["files"][file_name]["permissions"]))
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def unused_linux_accounts(self, bts_id=0, vm_tag=None):
        """
        Check if file /etc/passwd contain ONLY allowed unused users.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: None
        """
        cloud_vm = self._prepare_device(bts_id, vm_tag)
        cmd_cat = cloud_vm.get_cmd(cmd_name="cat", cmd_params={"path": "/etc/passwd"})
        if vm_tag == "FCT":
            result = cmd_cat()
        else:
            result = self._sudo_su_cmd(cloud_vm=cloud_vm, cmd_object=cmd_cat)
        unused_users = list()
        for line in result["LINES"]:
            if line.split(":")[0] in unused_linux_accounts:
                unused_users.append(line.split(":")[0])
        if unused_users:
            MolerTest.error("Output contains NOT allowed unused users:", dump=unused_users)
        MolerTest.steps_end()

    @MolerTest.raise_background_exceptions()
    def check_on_air(self):
        """
        Check if all cells are in on Air state by checking proper parameters.

        :return: None
        """
        connection = self.admin.connect_to(bts_host=self.ip_address)
        cell_specific_info = self.admin.get_cells_info(connection=connection)
        connection.disconnect()
        availability = cell_specific_info[0]["status"]["availabilityStatus"]
        operational = cell_specific_info[0]["status"]["operationalState"]
        administrative = cell_specific_info[0]["status"]["administrativeState"]
        if availability == "Online" and operational == "Enabled" and administrative == "Unlocked":
            MolerTest.info("Cells are in 'onAir' state")
        else:
            MolerTest.error("Cells are NOT in 'onAir' state", raise_exception=True)

    @MolerTest.raise_background_exceptions()
    def wait_for_on_air(self):
        """
        Wait for all cells to be in on Air state by checking proper parameters.

        :return: None
        """
        connection = self.admin.connect_to(bts_host=self.ip_address)
        not_on_air = True
        not_on_air_time = 0
        while not_on_air and not_on_air_time < 600:
            cell_specific_info = self.admin.get_cells_info(connection=connection)
            availability = cell_specific_info[0]["status"]["availabilityStatus"]
            operational = cell_specific_info[0]["status"]["operationalState"]
            administrative = cell_specific_info[0]["status"]["administrativeState"]
            if availability == "Online" and operational == "Enabled" and administrative == "Unlocked":
                MolerTest.info("Cells are in 'onAir' state")
                not_on_air = False
            else:
                MolerTest.info("Waiting for on 'onAir' state ...")
                MolerTest.sleep(30)
                not_on_air_time += 30
        if not_on_air:
            MolerTest.error("Cells are NOT in 'onAir' state")
        connection.disconnect()

    @MolerTest.raise_background_exceptions()
    def perform_du_commissioning(self, path_to_scf, should_fail=False):
        """
        Load defined scf file with validation, activation and waiting for operation success.

        :return: None
        """
        status = None
        connection = self.admin.connect_to(bts_host=self.ip_address)
        try:
            status = self.admin.perform_commissioning(scf_file=path_to_scf, skip_parameter_relation_errors=True)
        except AdminApiProcedureFailureException as e:
            if not should_fail:
                MolerTest.error(e)
        connection.disconnect()
        MolerTest.info(status)

    def check_active_alarms(self):
        """
        Check if only allowed alarms are present on bts.

        :return: None
        """
        forbidden_alarms = []
        active_alarms_list = []
        connection = self.admin.connect_to(bts_host=self.ip_address)
        active_alarms = self.admin.get_active_alarms(connection=connection)
        connection.disconnect()
        for alarm_info in active_alarms:
            active_alarms_list.append({"alarm_id": alarm_info['faultId'],
                                       "alarm_description": alarm_info['faultName']})
        for alarm in active_alarms_list:
            if alarm["alarm_id"] not in allowed_alarms:
                forbidden_alarms.append(alarm)
        if forbidden_alarms:
            MolerTest.warning("NOT allowed active alarms {}".format(forbidden_alarms))
        else:
            MolerTest.info("Only allowed active alarms")

    def check_link_to_cu(self):
        """
        Check if if value of parameter 'f1CLinkStatusDU' is 'available'.

        :return: None
        """
        connection = self.admin.connect_to(bts_host=self.ip_address)
        bts_configuration = self.admin.get_scf(export_type="configurationAndRuntimeObjects")
        connection.disconnect()
        value = str(bts_configuration).partition('<p name="{}">'.format("f1CLinkStatusDU"))[2].partition('</p>')[0]
        if value == "available":
            MolerTest.info("Link to CU in available state")
        else:
            MolerTest.error("Link to CU NOT available", raise_exception=True)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def check_if_oam_vm_ssh_key_exist(self, bts_id=0):
        """Check if ssh key for cu address exists after upgrade, in not create new with ssh-keygen cmd.

        :param bts_id: ID of BTS
        :return None
        """
        try:
            cloud_vm = self._prepare_device(bts_id, "PROXY_PC")
            cloud_vm.goto_state(state="OAM", log_stacktrace_on_fail=False)
        except MolerException:
            cloud_device = DeviceFactory.get_device("GNB{}_CU".format(bts_id), initial_state="PROXY_PC")
            cmd_ssh_keygen = cloud_device.get_cmd(cmd_name="sshkeygen", cmd_params={
                "options": """-f "/home/ute/.ssh/known_hosts" -R '{}'""".format(self.cu_ip_address)})
            cmd_ssh_keygen()
            cloud_device.goto_state("OAM")
            MolerTest.info("Added ssh key for {}".format(self.cu_ip_address))
        MolerTest.steps_end()

    @staticmethod
    def _prepare_device(bts_id, vm_tag):
        """
        Prepare cu or du device and go to the right state.

        :param bts_id: ID of BTS
        :param vm_tag: connection tag which defines target cloud VM
        :return: moler device
        """
        if vm_tag == "FCT":
            device_name = "GNB{}".format(bts_id)
            return DeviceFactory.get_device(device_name)
        device_name = "GNB{}_CU".format(bts_id)
        cloud_vm = DeviceFactory.get_device(device_name, initial_state=vm_tag)
        return cloud_vm

    @staticmethod
    def _sudo_su_cmd(cloud_vm, cmd_object=None, cmd_string=None):
        """
        Execute 'sudo su -c' command with defined command object.

        :param cloud_vm: moler device
        :param cmd_object: command object
        :param cmd_string: command as string
        :return: command output
        """
        if cmd_object:
            cmd_su = cloud_vm.get_cmd(cmd_name="su", cmd_params={"cmd_object": cmd_object})
            cmd_sudo = cloud_vm.get_cmd(cmd_name="sudo", cmd_params={"password": "", "cmd_object": cmd_su})
            result = cmd_sudo()
        else:
            cmd_su = cloud_vm.get_cmd(cmd_name="su", cmd_params={"options": "-c " + cmd_string})
            cmd_sudo = cloud_vm.get_cmd(cmd_name="sudo", cmd_params={"password": "", "cmd_object": cmd_su})
            result = cmd_sudo()
        return result

    @staticmethod
    def _verify_output_is_empty(output):
        """
        Verify command output is empty.

        :param output: command output
        :return: None, raise exception if output is not empty
        """
        if output["RESULT"]:
            MolerTest.error("Output should be empty but contains: ", dump=output["RESULT"])

    @staticmethod
    def _print_forbidden_processes_list(root=None, non_root=None):
        """
        Print forbidden processes in readable format.

        :return: None
        """
        if root:
            MolerTest.error("Output contains NOT allowed root processes:", dump=root)
        else:
            MolerTest.info("Output contains ONLY allowed root processes:")
        if non_root:
            MolerTest.error("Output contains NOT allowed non root processes:", dump=non_root)
        else:
            MolerTest.info("Output contains ONLY allowed non root processes:")

    @staticmethod
    def _check_if_process_is_forbidden(process_info, exception_list):
        """
        Check if root process is forbidden.

        :param process_info: process info dictionary
        :return: True if process is allowed, False if not
        """
        allowed_flag = bool(re.findall(r"\[.+]", process_info["COMMAND"]))
        for process in exception_list:
            if process in process_info["COMMAND"] or allowed_flag:
                return False
        return True

    @staticmethod
    def _add_lower_permissions():
        """
        Add lower permissions.

        :return: permissions list
        """
        permissions = list()
        permissions.append("-r--------")
        permissions.append("--w-------")
        permissions.append("----------")
        return permissions

    @staticmethod
    def _verify_permissions(output, permissions):
        """
        Verify permissions in provided output.

        :return: None
        """
        files = list()
        for value in output['files']:
            if re.match(permissions, output['files'][value]['permissions']):
                files.append({value: output['files'][value]['permissions']})
        if files:
            MolerTest.error("Files that have incorrect permissions", dump=files)
