from moler.exceptions import CommandFailure
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
import re
import copy

allowed_exceptions_002 = ["^/proc/.+$", "^/tmp/rshell/dev/log$"]
allowed_exceptions_0002 = ["^/proc/.+$", "^/tmp/rshell/dev/log$"]
allowed_exceptions_0022 = ["^/mnt/services/NE3SAgent/.*$", "^/opt/nokia/lib/serviceconf.d/ccs_cp.yaml$",
                           "^/opt/nokia/lib/serviceconf.d/ccs_mgt.yaml$", "^/run/utmp$", "^/var/log/btmp$",
                           "^/var/log/lastlog$", "^/var/log/wtmp$"]
allowed_exceptions_nouser_nogroup = []
allowed_exceptions_6000 = ["^/opt/nokia/SS_LimBash/bin/bash$",
                           "^/opt/nokia/SS_SCLI/bin/wrapper$",
                           "^/opt/nokia/SS_SCLI/sbin/sftp-wrapper$",
                           "^/opt/nokia/SS_SCLI/script/ssh_for_scli$",
                           "^/opt/nokia/bin/fpGUIauthenticator$",
                           "^/opt/nokia/bin/fpHTTPauthenticator$",
                           "^/opt/nokia/msgdispatcher/msgdispatcher$",
                           "^/opt/nokia/sbin/fsuidsetter$",
                           "^/usr/bin/chage$",
                           "^/usr/bin/chfn$",
                           "^/usr/bin/chsh$",
                           "^/usr/bin/crontab$",
                           "^/usr/bin/fileoperations_peer$",
                           "^/usr/bin/gpasswd$",
                           "^/usr/bin/passwd$",
                           "^/usr/bin/pwauth$",
                           "^/usr/bin/su$",
                           "^/usr/bin/sudo$",
                           "^/usr/libexec/lxc/lxc-user-nic$",
                           "^/usr/libexec/ssh-keysign$",
                           "^/usr/sbin/unix_chkpwd$"]
allowed_exceptions_002_1000 = []
re_allowed_services_all_vm = [r"0\.0\.0\.0:5353\s+\d+/avahi-daemon:.*",
                              r"0\.0\.0\.0:6118\s+-\s+",
                              r":::5353\s+\d+/avahi-daemon:.*",
                              r":::58\s+7\s+\d+/ipv6dadserver\s*",
                              r":::58\s+7\s+\d+/systemd-network\s*",
                              r":::255\s+7\s+\d+/ipv6dadserver\s*",
                              r":::58\s+7\s+\d+/ipmanager\s*"]
re_allowed_services_except_oam = [r"0\.0\.0\.0:(?P<PORT>\d+)\s+LISTEN\s+-\s*",
                                  r":::(?P<PORT>\d+)\s+LISTEN\s+-\s*"]
vms = ["OAM", "CPIF", "CPNRT", "UPUE", "CPCL", "CPNB", "CPUE", "DB"]


class CuKeywords:

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_mount_options_in_fstab(self, bts_id=0):
        """
        Verify 'defaults' mount options in /etc/fstab file.

        :param bts_id: ID of BTS
        :return: None
        """
        expected_mount_options = "defaults"
        fstab = self._get_cmd_output("GNB{}_CU".format(bts_id), "OAM", "cat", {"path": "/etc/fstab"})
        MolerTest.info("/etc/fstab: ", dump=fstab)
        current_mount_options = re.split(' +', fstab["LINES"][0])[3]
        if current_mount_options != expected_mount_options:
            MolerTest.error(
                "Fourth column in /etc/fstab should be '{}' but is '{}'".format(expected_mount_options,
                                                                                current_mount_options))

    def _get_cmd_output(self, device, state, cmd_name, cmd_params, root=False):
        vm = DeviceFactory.get_device(device, initial_state=state)
        cmd = vm.get_cmd(cmd_name=cmd_name, cmd_params=cmd_params)
        if root:
            cmd_su = vm.get_cmd(cmd_name="su", cmd_params={"cmd_object": cmd})
            cmd = vm.get_cmd(cmd_name="sudo", cmd_params={"password": "", "cmd_object": cmd_su})
        return cmd()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_robot_user_is_not_allowed_to_mount_filesystems(self, bts_id=0):
        """
        Verify that robot user is not allowed to mount filesystems on all VMs.

        :param bts_id: ID of BTS
        :return: None
        """
        for vm in vms:
            self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "rm", {"file": "/home/robot/rotta", "options": "-rf"})
            self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "mkdir", {"path": "/home/robot/rotta"})
            self._run_mount_cmd(vm, bts_id)
            self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "rm", {"file": "/home/robot/rotta", "options": "-rf"})
        MolerTest.steps_end()

    def _run_mount_cmd(self, vm, bts_id=0):
        expected_output = "/home/robot/rotta: must be superuser to use mount."
        try:
            mount_cmd = self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "mount",
                                             {"device": "//eseefsn50.emea.nsn-net.net/rotta4internal/",
                                              "directory": "/home/robot/rotta", "options": "-t cifs -o rw,norelatime"})
            MolerTest.error("Robot user is allowed to mount filesystems", dump=mount_cmd)
        except CommandFailure as e:
            if expected_output not in str(e):
                raise

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_unauthorized_world_writeable_files_are_not_present_on_the_system(self, bts_id=0):
        """
        Verify that unauthorized world-writeable files are not present on the system,
        each file is writable only by associated user or group.

        :param bts_id: ID of BTS
        :return: None
        """
        find_options_002 = "/ -type f -perm /002"
        for vm in vms:
            self._find_files_with_not_allowed_permissions(allowed_exceptions_002, find_options_002, vm, bts_id)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_files_owned_by_root_are_not_writeable_for_other_user_or_group(self, bts_id=0):
        """
        Verify that Files owned by root are not writeable for other user or group
        (they can be writeable to the root group).

        :param bts_id: ID of BTS
        :return: None
        """
        find_options_0002 = "/ -type f -user 0 -group 0 -perm /0002 -print"
        find_options_0022 = "/ -type f -user 0 ! -group 0 -perm /0022 -print"
        for vm in vms:
            self._find_files_with_not_allowed_permissions(allowed_exceptions_0002, find_options_0002, vm, bts_id)
            self._find_files_with_not_allowed_permissions(allowed_exceptions_0022, find_options_0022, vm, bts_id)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_orphaned_files_with_unknown_user_or_group_id_are_not_present_on_the_system(self, bts_id=0):
        """
        Verify that Orphaned files with unknown user or group id are not present on the system.

        :param bts_id: ID of BTS
        :return: None
        """
        find_options_nouser_nogroup = "/ -nouser -or -nogroup"
        for vm in vms:
            self._find_files_with_not_allowed_permissions(allowed_exceptions_nouser_nogroup,
                                                          find_options_nouser_nogroup, vm, bts_id)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_system_executables_with_user_id_or_group_id_attributes_set_are_not_present_on_the_system(self,
                                                                                                        bts_id=0):
        """
        Verify that System executables with User ID (SUID) or Group ID (SGID)
        attributes set are not present on the system.

        :param bts_id: ID of BTS
        :return: None
        """
        find_options_6000 = "/ -type f -perm /6000"
        for vm in vms:
            self._find_files_with_not_allowed_permissions(allowed_exceptions_6000, find_options_6000, vm, bts_id)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_world_writable_directories_are_not_present_on_the_system(self, bts_id=0):
        """
        Verify that world-writable directories are not present on the system. If a directory needs
        to be world-writable, its sticky bit shall be set so that the files in the directory can be deleted and renamed
        only by the owner of this file or the owner of the directory.

        :param bts_id: ID of BTS
        :return: None
        """
        find_options_002_1000 = "/ -type d -perm /002 -a ! -perm /1000"
        for vm in vms:
            self._find_files_with_not_allowed_permissions(allowed_exceptions_002_1000, find_options_002_1000, vm,
                                                          bts_id)
        MolerTest.steps_end()

    def _find_files_with_not_allowed_permissions(self, allowed_exceptions, find_options, vm, bts_id=0):
        find_output = self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "find",
                                           {"options": find_options + " 2>/dev/null"}, root=True)['RESULT']
        not_allowed_files_list = self._prepare_not_allowed_files_list(find_output, allowed_exceptions)
        if not_allowed_files_list:
            MolerTest.error("Files with not allowed permissions on VM {} (command: find {}):".format(vm, find_options),
                            dump=not_allowed_files_list)

    def _prepare_not_allowed_files_list(self, find_output, allowed_files):
        allowed_files_list = list()
        for file in find_output:
            for re_allowed in allowed_files:
                if re.search(re_allowed, file):
                    allowed_files_list.append(file)
        not_allowed_files_list = [file for file in find_output if file not in allowed_files_list]
        return not_allowed_files_list

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def verify_web_server_runs_in_chroot_jail(self, bts_id=0):
        """
        Verify that web server runs in chroot jail

        :param bts_id: ID of BTS
        :return: None
        """
        httpd_pid = self._get_cmd_output("GNB{}_CU".format(bts_id), "FCT", "netstat",
                                         {"options": "-nap | grep :443 | grep LISTEN"})["GROUP"][0][
            "interface"].split('/')[0]
        wc_proc_cmd = "ls -l /proc/{}/root/bin/ | wc -l".format(httpd_pid)
        wc_bin_cmd = "ls -l /bin/ | wc -l"
        wc_proc = self._get_cmd_output("GNB{}_CU".format(bts_id), "FCT", "echo",
                                       {"options": "$({})".format(wc_proc_cmd)})['RESULT'][0]
        wc_bin = self._get_cmd_output("GNB{}_CU".format(bts_id), "FCT", "echo",
                                      {"options": "$({})".format(wc_bin_cmd)})['RESULT'][0]
        if wc_bin == wc_proc:
            MolerTest.error(
                "Numbers in outputs from '{}' ({}) and '{}' ({}) should be different".format(wc_proc_cmd, wc_proc,
                                                                                             wc_bin_cmd, wc_bin))

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def verify_permissions_of_web_server_config_files(self, bts_id=0):
        """
        Verify permissions of web server config files.

        :param bts_id: ID of BTS
        :return: None
        """
        expected_permissions = "-rw-rw----"
        expected_owner = "apache"
        expected_group = "apache"
        ls_output = self._get_cmd_output("GNB{}_CU".format(bts_id), "FCT", "ls",
                                         {"options": "-l", "path": "/etc/rcpexthttpd/conf"})['files']
        error_list = self._check_files(ls_output, expected_permissions, expected_owner, expected_group)
        if error_list:
            MolerTest.error(
                "Files with not allowed permissions (correct: permissions {}, owner {}, group {}):".format(
                    expected_permissions, expected_owner, expected_group), dump=error_list)

    def _check_files(self, ls_output, expected_permissions, expected_owner, expected_group):
        error_list = ls_output.copy()
        params_to_delete = ['date', 'hard_links_count', 'name', 'size_bytes', 'size_raw']
        for file in ls_output:
            if re.search(expected_permissions, ls_output[file]['permissions']) and \
                    ls_output[file]['owner'] == expected_owner and ls_output[file]['group'] == expected_group:
                del error_list[file]
            else:
                for param in params_to_delete:
                    del error_list[file][param]
        return error_list

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def verify_permissions_of_web_server_content_served_files(self, bts_id=0):
        """
        Verify permissions of web server content served files.

        :param bts_id: ID of BTS
        :return: None
        """
        expected_permissions = "(dr-xr-x---|-r--r-----)"
        expected_owner = "root"
        expected_group = "apache"
        ls_output = self._get_cmd_output("GNB{}_CU".format(bts_id), "FCT", "ls",
                                         {"options": "-lR", "path": "/var/opt/www"})['files']
        ls_output = self._remove_directories(ls_output)
        error_list = self._check_files(ls_output, expected_permissions, expected_owner, expected_group)
        if error_list:
            MolerTest.error(
                "Files with not allowed permissions (correct: permissions {}, owner {}, group {}):".format(
                    expected_permissions, expected_owner, expected_group), dump=error_list)

    def _remove_directories(self, ls_output):
        ls_output_copy = ls_output.copy()
        for file in ls_output_copy:
            if '/var/opt/www' in file:
                del ls_output[file]
        return ls_output

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_ip_forwarding_is_enabled_only_on_loopback_interface(self, ip_version, bts_id=0):
        """
        Verify that ipv4 or ipv6 forwarding is enabled only on loopback interface.

        :param vm: ipv4 or ipv6
        :param bts_id: ID of BTS
        :return: None
        """
        expected_value = '1'
        for vm in vms:
            sysctl_output = self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "sysctl",
                                                 {"options": "-a | grep net.{} |  grep forwarding | grep -v 0$"
                                                 .format(ip_version)}, root=True)
            current_value = sysctl_output['net.{}.conf.lo.forwarding'.format(ip_version)]
            if current_value != expected_value:
                MolerTest.error(
                    "Value of net.{}.conf.lo.forwarding on {} should be {}, but is {}".format(ip_version, vm,
                                                                                              expected_value,
                                                                                              current_value),
                    dump=sysctl_output)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_proxy_arp_is_disabled_on_all_interface(self, bts_id=0):
        """
        Verify that proxy ARP is disabled on all interface.

        :param bts_id: ID of BTS
        :return: None
        """
        options = '-a | grep net.ipv4|grep proxy_arp | grep -v 0$'
        for vm in vms:
            sysctl_output = self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "sysctl", {"options": options},
                                                 root=True)
            if sysctl_output:
                MolerTest.error("Output of 'sysctl {}' on {} is not empty".format(options, vm), dump=sysctl_output)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_broadcast_icmp_is_ignored_on_cu(self, bts_id=0):
        """
        Verify that broadcast ICMP is ignored on CU.

        :param bts_id: ID of BTS
        :return: None
        """
        expected_value = '1'
        options = '-a | grep -e "net.ipv4.icmp_echo_ignore_broadcasts"'
        for vm in vms:
            sysctl_output = self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "sysctl", {"options": options},
                                                 root=True)
            current_value = sysctl_output['net.ipv4.icmp_echo_ignore_broadcasts']
            if current_value != expected_value:
                MolerTest.error(
                    "Value of 'net.ipv4.icmp_echo_ignore_broadcasts' should be {}, but is {} on {}".format(
                        expected_value, current_value, vm),
                    dump=sysctl_output)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_value_of_drop_gratuitous_arp(self, bts_id=0):
        """
        Verify that drop_gratuitous_ARP = 1 only on interfaces fronthaul, x2, backhaul and tracing.
        On other interfaces it should be 0.

        :param bts_id: ID of BTS
        :return: None
        """
        for vm in vms:
            error_dict = dict()
            error_dict.update(self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "sysctl", {
                "options": '-a | grep gratuitous_arp | grep -E "all|default|internal|oam" | grep -v 0$'}, root=True))
            error_dict.update(self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "sysctl", {
                "options": '-a | grep gratuitous_arp | grep -E "tracing|x2|fronthaul|backhaul" | grep -v 1$'},
                                                   root=True))
            if error_dict:
                MolerTest.error(
                    "Incorrect values of drop_gratuitous_ARP on {} (expected: tracing, x2, fronthaul, backhaul = 1;"
                    " all, default, internal, oam = 0):".format(vm), dump=error_dict)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_services_do_not_bind_to_all_interfaces(self, bts_id=0):
        """
        Verify that services do not bind to all interfaces.

        :param bts_id: ID of BTS
        :return: None
        """
        for vm in vms:
            netstat_output = self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "echo",
                                                  {"options": "$(netstat -nap | awk '\\''{ print \"###\" $4 \"\\t\" $6"
                                                              " \"\\t\" $7 }'\\'' | grep -E \"0.0.0.0|:::\")"},
                                                  root=True)['RESULT']
            netstat_output = "".join(netstat_output)
            services = netstat_output.split('###')[1:]
            error_list = self._check_services(services, vm)
            if error_list:
                MolerTest.error("Not allowed services on {}:".format(vm), dump=error_list)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_that_multicast_is_not_set_for_external_interfaces(self, bts_id=0):
        """
        Verify if MULTICAST is set only for internal interfaces, every external interface
        shouldn't be set as MUTLICAST.

        :param bts_id: ID of BTS
        :return: None
        """
        for vm in vms:
            self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "bash", {"bash": "ip a | grep MULTICAST > result"},
                                 root=True)
            result = self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "cat", {"path": "result"}, root=True)
            self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "rm", {"file": "result"}, root=True)
            for line in result["LINES"]:
                if re.search(r"\d+:\s+internal.*", line):
                    MolerTest.info("MULTICAST set for internal interface on {} vm".format(vm), dump=line)
                else:
                    MolerTest.error("MULTICAST set for non internal interface NOT allowed on {} vm".format(vm),
                                    dump=line, raise_exception=True)
        MolerTest.steps_end()

    def _check_services(self, services, vm):
        error_list = copy.deepcopy(services)
        if vm != 'OAM':
            for service in services:
                for allowed_service in re_allowed_services_except_oam:
                    m = re.search(allowed_service, service)
                    if m:
                        port = int(m.group('PORT'))
                        if port < 54000 or port > 65536:
                            MolerTest.error("Port should be between 54000 and 65536, but is {}".format(port),
                                            dump=service)
                        else:
                            error_list.remove(service)
        for service in services:
            for allowed_service in re_allowed_services_all_vm:
                if re.search(allowed_service, service):
                    error_list.remove(service)
        return error_list

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def verify_default_password_hash(self, bts_id=0):
        """
        Verify default password hash for all applicable users (toor4nsn, Nemuadmin, serviceuser, wsuser)

        :param bts_id: ID of BTS
        :return: None
        """
        error_dict = self._check_toor4nsn_password_hash("OAM", bts_id)
        error_dict.update(self._check_other_users_password_hashes("OAM", bts_id))
        if error_dict:
            MolerTest.error("Default password hash is not SHA-512 ($6$ prefix):", dump=error_dict)

    def _check_toor4nsn_password_hash(self, vm, bts_id=0):
        error_dict = dict()
        re_toor4nsn = r'toor4nsn:\$6\$.*'
        shadow = self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "cat", {
            "path": '/etc/shadow | grep toor4nsn'}, root=True)['LINES'][0]
        if not re.search(re_toor4nsn, shadow):
            toor4nsn = shadow.split(':', 1)
            error_dict.update({toor4nsn[0]: toor4nsn[1]})
        return error_dict

    def _check_other_users_password_hashes(self, vm, bts_id=0):
        loki = self._get_cmd_output("GNB{}_CU".format(bts_id), vm, "echo", {
            "options": "$(loki read-all |  awk '\\''{print\"###\"$0}'\\'' | grep -E \"gecos: \\\"Nemuadmin\\\"|gecos:"
                       " \\\"serviceuser\\\"|gecos: \\\"wsuser\\\"\" -A 5 | grep -E \"gecos|user_password\")"},
                                    root=True)['RESULT']
        lines = "".join(loki).split('###')[1:]
        return self._check_hashes(lines)

    def _check_hashes(self, lines):
        error_dict = dict()
        re_gecos = r"gecos:\s+\"(?P<USER>.*)\""
        re_user_password = r"user_password:\s+\"(?P<PASSWORD>.*)\""
        user = ""
        for line in lines:
            m = re.search(re_gecos, line)
            if m:
                user = m.group('USER')
            m = re.search(re_user_password, line)
            if m:
                password = m.group('PASSWORD')
                if "$6$rounds=" not in password:
                    error_dict.update({user: password})
        return error_dict

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def verify_aashell_binds_to_loopback_address_only(self, bts_id=0):
        """
        Verify that aashell binds to loopback address only.

        :param bts_id: ID of BTS
        :return: None
        """
        address = "127.0.0.1:15007"
        netstat_outut = self._get_cmd_output("GNB{}_CU".format(bts_id), "OAM", "netstat",
                                             {"options": "-natp"}, root=True)
        for connections in netstat_outut["INTERNET_CONNECTIONS"]:
            if connections['local address'] == address:
                return
        MolerTest.error("Missing address in netstat output: {}".format(address))
