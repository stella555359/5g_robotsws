import subprocess
import ipaddress
import string
import time
import re

from contextlib import contextmanager
from robot.api import logger
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import interface


class SecurityMethods:
    """Class security methods"""

    WEBEM_USERS_FILE = "/ffs/run/config/users.json"

    def __init__(self, bts_ip, bts_username, bts_password):
        self.bts_ip = bts_ip
        self.bts_username = bts_username
        self.bts_password = bts_password

    @staticmethod
    @contextmanager
    def ssh_connection(ip_address, username, password):
        ssh = interface.ssh().connect_to(ip_address, username, password)
        yield ssh
        ssh.disconnect()

    def check_local_user_password_hashed_with_sha512(self, local_username=None):
        check_files_list_raw = [
            "/etc/shadow",
            "/ffs/run/etc/p_shadow",
            "/etc/security/opasswd",
            "/ffs/run/etc/security/opasswd",
            "/etc/passwd"
        ]

        with SecurityMethods.ssh_connection(self.bts_ip, self.bts_username, self.bts_password) as ssh:
            for file_path in check_files_list_raw:
                if interface.ssh().file_exists(file_path, connection=ssh):
                    if local_username is not None:
                        logger.info("Checking hashes in file: {0} for user: {1}".format(
                            file_path, local_username), also_console=True)
                        hash_raw = ssh.execute(command="grep '$.*$' {0} | grep {1}".format(file_path, local_username))
                    else:
                        logger.info("Checking hashes in file: {}".format(file_path), also_console=True)
                        hash_raw = ssh.execute(command="grep '$.*$' {0}".format(file_path))
                    for hashed_pass in hash_raw.split("\r\n"):
                        if hashed_pass and "$6$rounds=10000" not in hashed_pass:
                            raise Exception(
                                "File {0} contains hash different than $6$ sha512, {1}".format(file_path, hashed_pass))

    def check_webem_user_password_hashed_with_sha512(self, webem_username):
        with SecurityMethods.ssh_connection(self.bts_ip, self.bts_username, self.bts_password) as ssh:
            hash_entry = ssh.execute(
                command="cat {1} | grep -A 10 \"{0}\" | grep hashedPassword".format(
                    webem_username, self.WEBEM_USERS_FILE))
            logger.console("cat {1} | grep -A 10 \"{0}\" | grep hashedPassword".format(
                    webem_username, self.WEBEM_USERS_FILE))
            logger.console("Checking hash value: {0}".format(hash_entry))
            hash_raw = hash_entry.split(":")[1].strip(string.whitespace + string.punctuation)
            logger.info("Checking {0} password hash: {1}".format(webem_username, hash_raw), also_console=True)
            assert len(hash_raw) == 128, \
                "Hash length equals to {0} digits but should 128, sha512 not used!".format(len(hash_raw))

    def remove_users_json_and_reboot(self):
        """After removing users.json and rebooting local operator user
        accounts default passwords (eg. Nemuadmin nemuuser) are restored"""

        with SecurityMethods.ssh_connection(self.bts_ip, self.bts_username, self.bts_password) as ssh:
            ssh.execute(command="rm {0}".format(self.WEBEM_USERS_FILE))
            exit_status = ssh.execute(command="echo $?")
            logger.info("Removing {0}. Exit status of rm: {1}".format(
                self.WEBEM_USERS_FILE, exit_status.strip(string.whitespace)), also_console=True)
            assert exit_status.strip(string.whitespace) == "0", "{0} deletion failed!".format(self.WEBEM_USERS_FILE)
            logger.info("Rebooting bts to restore default users.json", also_console=True)
            ssh.send_command(command="ddal -s ddal_reboot_graceful")
            # 60s sleep to ensure gNB has time to start reboot before any other keyword tries to login to WebEM,
            # as it will regenerate users.json file with changed passwords and hashes
            time.sleep(60)

    def change_webem_user_password(self, old_username, old_password, new_password):
        status = None
        api = admin()
        connection = api.connect_to(self.bts_ip)
        try:
            logger.info("Changing password for {0}".format(old_username), also_console=True)
            connection.set_user_account(old_username=old_username,
                                        old_password=old_password,
                                        new_password=new_password)
            status = True
        except Exception as e:
            status = False
        finally:
            connection.disconnect()
            return status

    def change_ssh_user_password(self, username, new_password, old_password):
        status = None
        api = admin()
        connection = api.connect_to(bts_host=self.bts_ip)
        try:
            logger.info("Changing password for {0}".format(username), also_console=True)
            connection.change_ssh_password(username=username,
                                           new_password=new_password,
                                           old_password=old_password)
            status = True
        except Exception as e:
            status = False
        finally:
            connection.disconnect()
            return status

    def check_path_traversal_disabled_in_aashell(self):
        with SecurityMethods.ssh_connection(self.bts_ip, self.bts_username, self.bts_password) as ssh:
            aashell_path_traversal = ssh.execute(command="echo 'tag -a' | nc 127.0.0.1 15007 | grep path_traversal")
            logger.info("Path traversal tag value: {0}".format(
                aashell_path_traversal.strip("\r\n")), also_console=True)
            assert aashell_path_traversal != "", "Tag path_traversal is not set!"
            assert "disable" in aashell_path_traversal, "Path traversal is not disabled!"
            assert "01000000" in aashell_path_traversal, "Path traversal is not disabled!"

    def check_aashell_binds_to_localhost_only(self):
        addresses_allowed_for_aashell_bind = ["127.0.0.1", "::1"]
        with SecurityMethods.ssh_connection(self.bts_ip, self.bts_username, self.bts_password) as ssh:
            ccsdaemonexe_raw = ssh.execute(
                command="netstat -tnlp | "
                        "grep -i ccsdaemonexe | "
                        "sed -e 's/[[:space:]]\\+/ /g' | "
                        "cut -d ' ' -f4 | "
                        "cut -d ':' -f1 | "
                        "awk 1 ORS=','")
            ccsdaemonexe_addresses = set([addr.strip() for addr in ccsdaemonexe_raw.split(",") if addr])
            for address in ccsdaemonexe_addresses:
                logger.info("Checking CCSDaemonExe binded address: {0}".format(address), also_console=True)
                assert address in addresses_allowed_for_aashell_bind, \
                    "AaShell/CCSDaemonExe is binded to wrong address: {0}".format(address)

    def _check_available_bsh_sessions(self, possible_bsh_sessions):
        available_bsh_sessions = []
        with SecurityMethods.ssh_connection(self.bts_ip, self.bts_username, self.bts_password) as ssh:
            logger.info("Collecting available bsh sessions", also_console=True)
            for bsh_session in possible_bsh_sessions:
                bsh_check = ssh.execute(command="bsh {0} echo qwerasdfzxcv".format(bsh_session))
                if "qwerasdfzxcv" in bsh_check:
                    available_bsh_sessions.append(bsh_session)
        logger.info("Available bsh sessions: {0}".format(available_bsh_sessions), also_console=True)
        return available_bsh_sessions

    def check_aashell_available_for_serviceuser(self):
        bsh_sessions = self._check_available_bsh_sessions(["0:0", "1:0", "1:1", "1:2"])
        with SecurityMethods.ssh_connection(self.bts_ip, self.bts_username, self.bts_password) as ssh:
            for session in bsh_sessions:
                logger.info("Checking serviceuser login attempt to AaShell on bsh {0}".format(session),
                            also_console=True)
                aashell_login_attempt = ssh.execute(
                    command="bsh {0} 'runuser -l serviceuser -c \"nc 127.0.0.1 15007 -z -v -w 10\"'".format(session))
                assert "succeeded" not in aashell_login_attempt, \
                    "serviceuser was able to login to AaShell on bsh {0}!".format(session)

    def _check_nfs_restricted_to_internal_network(self, ip_version):
        bsh_sessions = self._check_available_bsh_sessions(["0:0", "1:0", "1:1", "1:2"])
        with SecurityMethods.ssh_connection(self.bts_ip, self.bts_username, self.bts_password) as ssh:
            for session in bsh_sessions:
                nfs_mounts = {}
                logger.info("Checking NFS restricted to internal network on bsh {0}".format(session),
                            also_console=True)
                showmount_raw = ssh.execute(
                    command="bsh {0} \"showmount -e --no-headers | sed -e 's/[[:space:]]\\+/;/g'\"".format(session))
                for line in [line for line in showmount_raw.splitlines() if "RPC:" not in line]:
                    filepath = line.split(";")[0]
                    networks = line.split(";")[1].split(",")
                    nfs_mounts[filepath] = networks
                for filepath, networks in nfs_mounts.items():
                    for network in networks:
                        if network != u"*":
                            classinfo = ipaddress.IPv4Network if ip_version == "ipv4" else ipaddress.IPv6Network
                            if isinstance(ipaddress.ip_network(network), classinfo):
                                assert ipaddress.ip_network(network).is_private, \
                                    "{0} is bound to external address: {1}!".format(filepath, network)

    def check_nfs_restricted_to_internal_network_v4(self):
        self._check_nfs_restricted_to_internal_network("ipv4")

    def check_nfs_restricted_to_internal_network_v6(self):
        self._check_nfs_restricted_to_internal_network("ipv6")

    def check_sensitive_files_world_readeable_on_smod(self):
        smod_files_to_check_permission = [
            "/ffs/run/etc/keys.d/private/bts-default.pem",
            "/ffs/run/etc/keys.d/private/*.crk",
            "/etc/ipsec.d/private/privkey.crk",
            "/ffs/run/trs_data/active/keystorage/certs/privkey.crk",
            "/etc/keys.d/board/privkey.pem",
            "/ffs/run/config/trs/keystorage/ipsecpsk.json",
            "/ffs/run/config/trs/keystorage/ipsecpsk.txt",
            "/ffs/run/config/trs/keystorage/pskFileNew",
            "/ffs/run/config/ruemlog.json",
            "/ffs/run/config/ruemlog_has.json",
            "/opt/trs/etc/cert/bts_pub_cert.pem",
            "/opt/trs/etc/cert/bts_priv_key.crk",
            "/rom/config/users.json",
            "/rom/config/dcusers.json",
            "/rom/config/userInfo.json",
            "/rom/config/operatingParameters.json",
            "/tmp/ruemlog",
            "/rom/config/model_5.ims2",
            "/rom/config/backupConf.json",
            "/rom/config/NCF.xml",
            "/rom/config/NCF_DATA.xml"
        ]

        bsh_sessions = self._check_available_bsh_sessions(["0:0", "0:1", "0:2"])
        with SecurityMethods.ssh_connection(self.bts_ip, self.bts_username, self.bts_password) as ssh:
            for session in bsh_sessions:
                logger.info("Checking file permisions on bsh {0}".format(session), also_console=True)
                file_permission_check = ssh.execute(
                    command="bsh {0} 'find {1} -perm -004' | sort".format(
                        session, " ".join(smod_files_to_check_permission)))
                for line in file_permission_check.splitlines():
                    if "No such file or directory" not in line:
                        assert line not in smod_files_to_check_permission, "File {0} is world readable!".format(line)

    def check_sensitive_files_world_readeable_on_bbmod(self):
        bbmod_files_to_check_permission = [
            "/etc/5g-layer-1/test_modes.conf",
            "/etc/5g-layer-1/ss_block_send_req_insert.conf",
            "/etc/5g-layer-1/srs_receive_req.conf",
            "/etc/5g-layer-1/slot_type_req.conf",
            "/etc/5g-layer-1/rd_thresholds.conf",
            "/etc/5g-layer-1/rd_parameters.conf",
            "/etc/5g-layer-1/pusch_receive_req.conf",
            "/etc/5g-layer-1/pucch_receive_req.conf",
            "/etc/5g-layer-1/prach_receive_req.conf",
            "/etc/5g-layer-1/pdsch_insert.conf",
            "/etc/5g-layer-1/pdcch_send_req.conf",
            "/etc/5g-layer-1/pattern_config_req.conf",
            "/etc/5g-layer-1/l2_address.conf",
            "/etc/5g-layer-1/l1_sw_version.txt",
            "/etc/5g-layer-1/ecpri_subscribe_req.conf",
            "/etc/5g-layer-1/ecpri_set_output_req.conf",
            "/etc/5g-layer-1/ecpri_delay_config_req.conf",
            "/etc/5g-layer-1/ecpri_configure_transport_req.conf",
            "/etc/5g-layer-1/ecpri_configure_links_req.conf",
            "/etc/5g-layer-1/ecpri.conf",
            "/etc/5g-layer-1/dma_test.conf",
            "/etc/5g-layer-1/debug_print.conf",
            "/etc/5g-layer-1/csi_rs_send_req.conf",
            "/etc/5g-layer-1/cpri_test.conf",
            "/etc/5g-layer-1/cpri_subscribe_req.conf",
            "/etc/5g-layer-1/cpri_set_output_req.conf",
            "/etc/5g-layer-1/cpri_link_param_req.conf",
            "/etc/5g-layer-1/cpri_delay_config_req.conf",
            "/etc/5g-layer-1/cpri_configure_links_req.conf",
            "/etc/5g-layer-1/cpri_configure_axc_info_req.conf",
            "/etc/5g-layer-1/const_customizer.conf",
            "/etc/5g-layer-1/cell_setup.conf",
            "/etc/5g-layer-1/antenna_snapshot.conf",
            "/etc/5g-layer-1/ul_insert.bin",
            "/etc/5g-layer-1/ul_insert_1.bin",
            "/etc/5g-layer-1/ul_insert_2.bin",
            "/etc/5g-layer-1/ul_insert_3.bin",
            "/usr/bin/set_qsfp_reference_freqs_PL3.sh",
            "/usr/bin/set_qsfp_reference_freqs_PL1.sh",
            "/usr/bin/set_qsfp_reference_freqs.sh",
            "/usr/bin/set_qsfp_pll.sh",
            "/usr/bin/set_ex003.sh",
            "/usr/bin/set_ecpri_config.sh",
            "/usr/bin/set_bip_mac_address.sh",
            "/usr/bin/serdes_params_elodin.sh",
            "/usr/bin/l1sw_tc_start.sh",
            "/usr/bin/l1sw_namespace.sh",
            "/usr/bin/l1sw_fastcm_bridge.sh",
            "/usr/bin/l1sw-collect-request-trace.py",
            "/usr/bin/fpga_bitstream_variant",
            "/usr/bin/fix_mpll_sys_apll_lol_bug.sh",
            "/usr/bin/create_directory_tarball",
            "/usr/bin/bootstrap_powerload.sh",
            "/usr/bin/bootstrap5g.sh",
            "/etc/usas/l1sw-log-collection.conf",
            "/etc/usas/ethss-log-collection.conf",
            "/etc/sysctl.d/ip_route.conf",
        ]

        bsh_sessions = self._check_available_bsh_sessions(["1:0", "1:1", "1:2"])
        with SecurityMethods.ssh_connection(self.bts_ip, self.bts_username, self.bts_password) as ssh:
            for session in bsh_sessions:
                logger.info("Checking file permisions on bsh {0}".format(session), also_console=True)
                file_check = ssh.execute(
                    command="bsh {0} 'find {1} -perm -004' | sort".format(
                        session, " ".join(bbmod_files_to_check_permission)))
                for line in file_check.splitlines():
                    if "No such file or directory" not in line:
                        assert line not in bbmod_files_to_check_permission, "File {0} is world readable!".format(line)

    def check_service_binding(self):
        process_bindings = {
            "atftpd": {
                "ports": ["69"]
            },
            "CCSDaemonExe": {
                "ports": [
                    "15007",
                    "15009",
                    "15010",
                    "15015",
                    "15016",
                    "15017",
                    "15018",
                    "15019",
                    "15020",
                    "15021",
                    "15172",
                    "4000",
                ]
            },
            "CCSTestPortSer": {
                "ports": ["15068"]
            },
            "dhcpd": {
                "ports": ["67"]
            },
            "givaxi": {
                "ports": [
                    "20400",
                    "20405",
                ]
            },
            "lightweightse": {
                "ports": [
                    "20491",
                    "64000",
                ]
            },
            "ministarter": {
                "ports": ["64000"]
            },
            "providercontr": {
                "ports": [
                    "20401",
                    "20402",
                ]
            },
            "redis-server": {
                "ports": ["6379"]
            },
            "rsyslogd": {
                "ports": ["514", "515"]
            },
            "sshd: /usr/sbi": {
                "ports": ["2022"]
            },
            "TAS": {
                "ports": ["20810"]
            },
        }

        with SecurityMethods.ssh_connection(self.bts_ip, self.bts_username, self.bts_password) as ssh:
            for process, process_attributes in process_bindings.items():
                logger.info("Checking bind addresses for process {0}".format(process), also_console=True)
                bind_check = ssh.execute(command="netstat -tulpn | grep '{0}' | awk '{{ print $4; }}'".format(process))
                bind_check_for_analysing = ssh.execute(command="netstat -anp | grep '{0}'".format(process))
                logger.info("Results of netstat -anp | grep {0}".format(process))
                logger.info(bind_check_for_analysing)
                nmap_result = subprocess.check_output("nmap -p- 192.168.255.129", shell=True, text=True)
                logger.info("nmap result for all ports: {0}".format(nmap_result))
                for line in bind_check.splitlines():
                    for port in process_attributes["ports"]:
                        if port == line.rsplit(":")[-1]:
                            assert "0.0.0.0" not in line, \
                                "Process {0} is binded to 0.0.0.0:{1}!".format(process, port)
                            assert ":::" not in line, \
                                "Process {0} is binded to :::{1}!".format(process, port)
                        if re.search(rf"^{port}/tcp\s+open", nmap_result, re.MULTILINE):
                            raise AssertionError(
                                f"Unauthorized access detected on port {port} for process {process}!"
                            )
                logger.info("Unauthorized access attempt blocked for port {0}.".format(port))
