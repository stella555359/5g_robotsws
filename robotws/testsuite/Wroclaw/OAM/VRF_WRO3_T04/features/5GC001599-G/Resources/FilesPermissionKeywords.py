from contextlib import contextmanager
from robot.api import logger
from taf.transport.ssh import interface


class FilesPermissionKeywords:

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

    def _check_available_bsh_sessions(self, possible_bsh_sessions):
        available_bsh_sessions = []
        with FilesPermissionKeywords.ssh_connection(self.bts_ip, self.bts_username, self.bts_password) as ssh:
            logger.info("Collecting available bsh sessions", also_console=True)
            for bsh_session in possible_bsh_sessions:
                bsh_check = ssh.execute(command="bsh {0} echo qwerasdfzxcv".format(bsh_session))
                if "qwerasdfzxcv" in bsh_check:
                    available_bsh_sessions.append(bsh_session)
        logger.info("Available bsh sessions: {0}".format(available_bsh_sessions), also_console=True)
        return available_bsh_sessions

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
        with FilesPermissionKeywords.ssh_connection(self.bts_ip, self.bts_username, self.bts_password) as ssh:
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
        with FilesPermissionKeywords.ssh_connection(self.bts_ip, self.bts_username, self.bts_password) as ssh:
            for session in bsh_sessions:
                logger.info("Checking file permisions on bsh {0}".format(session), also_console=True)
                file_check = ssh.execute(
                    command="bsh {0} 'find {1} -perm -004' | sort".format(
                        session, " ".join(bbmod_files_to_check_permission)))
                for line in file_check.splitlines():
                    if "No such file or directory" not in line:
                        assert line not in bbmod_files_to_check_permission, "File {0} is world readable!".format(line)
