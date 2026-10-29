from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_SuiteSetup.common import *
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_SuiteSetup.configure import *
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_SuiteSetup.load import *
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_sbts_keywords import *
from taf.rfrl.common_resources.python.SWConfig import SWConfig
from taf.sbts.oam.coam.admin import admin

SWCFG_SYSLOG = ["0x1003F = 1", "0x10040 = 1", "0x10041 = 5", "0x10042 = 0xC0A8FF7E", "0x10043 = 0xc738", "0x420000=1"]


class CommonOAM:
    def __init__(self, **kwargs):
        self._kwargs = kwargs

        # delete ssh known_hosts
        run("rm -rf /home/ute/.ssh/known_hosts")

    def _update_swconfig(self, loadname, oam_ip, username, password, port, remote_ssh_ip, remote_ssh_user,
                         remote_ssh_passwd, remote_ssh_port, timeout, remote_oper_flag=False):
        release = get_release(loadname)
        swconfig_path = get_swconfig_template_path(PKG_LOCAL_ROOTPATH, release)

        def _update_swconfig_inner(oam_ip, username, password, port, connection="update_swconfig"):
            swc = SWConfig()
            try:
                swc.ssh.connect_to(hostname=oam_ip, username=username, password=password, port=port,
                                   alias=connection)
                swc.modify_swConfig_file(SWCFG_SYSLOG, swconfig_path)
                swc.upload_swConfig_file_to_asik_and_crasign(localFilePath=swconfig_path, asik_alias=connection)
            except Exception:
                raise Exception(
                    "Cant connect to host: {} with username: {} and password: {} and port: {}".format(oam_ip,
                                                                                                      username,
                                                                                                      password,
                                                                                                      port))
            finally:
                swc.ssh.disconnect(connection=connection)

        if remote_oper_flag:
            tunnels = self._setup_tunnel(oam_ip=oam_ip, port=port, remote_ssh_ip=remote_ssh_ip,
                                         remote_ssh_user=remote_ssh_user, remote_ssh_passwd=remote_ssh_passwd,
                                         remote_ssh_port=remote_ssh_port, timeout=timeout)
            for tunnel in tunnels:
                _update_swconfig_inner(oam_ip="127.0.0.1", username=username, password=password, port=tunnel,
                                       connection="slave")
        else:
            _update_swconfig_inner(oam_ip=oam_ip, username=username, password=password, port=port, connection="master")

    def _get_commission(self, loadname, testline, comm_subtype=None):
        local_dir = get_full_commission_dir()
        gnb_commission_path = None
        asir_commission_path = None

        try:
            commission_type_json_path, testline_json_path = get_configure_json_file(local_dir)
            mrbtsId, commission_type_number, commission_sub_type, testline_configuration_list = \
                get_testline_configuration_info_from_testline_json_file(testline_json_path=testline_json_path,
                                                                        testline=testline)
            comm_subtype = commission_sub_type if not comm_subtype else comm_subtype
            testline_type = get_testline_type_from_commission_type_json(
                commission_type_json_path=commission_type_json_path, commission_type_number=commission_type_number)
            gnb_commission_path, asir_commission_path = get_gnb_and_asir_commission_path(local_dir=local_dir,
                                                                                         testline_name=testline,
                                                                                         sw_build_info=loadname,
                                                                                         subtype=comm_subtype,
                                                                                         testline_type=testline_type)
        except Exception as e:
            gnb_commission_path, asir_commission_path = \
                get_gnb_and_asir_commission_path(local_dir=local_dir,
                                                 testline_name=testline,
                                                 sw_build_info=loadname,
                                                 subtype=comm_subtype if comm_subtype else '')

        return gnb_commission_path, asir_commission_path

    def _check_sysmod_status(self, oam_ip, https_port, timeout, remote_ssh_ip, remote_ssh_user, remote_ssh_passwd,
                             remote_ssh_port, remote_oper_flag=False, connection=None):
        dict_check_status = {"administrativeState": "Unlocked", "operationalState": "Enabled"}

        def _check_sysmod_status_inner(oam_ip, port, timeout, connection):
            i = 0
            delta_time = 30
            while i < timeout / delta_time:
                i += 1
                try:
                    check_sysmod_status(expected_status_dict=dict_check_status, oam_ip=oam_ip, port=port,
                                        running=True,
                                        connection=connection)
                    break
                except Exception:
                    logger.error("Check sysmod failed, try again after sleep {}s".format(delta_time))
                    time.sleep(delta_time)
                    continue
            else:
                raise Exception("Check sysmod failed in {}s".format(timeout))

        try:
            if remote_oper_flag:
                tunnels = self._setup_tunnel(oam_ip=oam_ip, port=https_port, remote_ssh_ip=remote_ssh_ip,
                                             remote_ssh_user=remote_ssh_user, remote_ssh_passwd=remote_ssh_passwd,
                                             remote_ssh_port=remote_ssh_port, timeout=timeout)
                for tunnel in tunnels:
                    self._setup_admin(oam_ip="127.0.0.1", bts_port=tunnel, timeout=timeout, connection=connection)
                    _check_sysmod_status_inner(oam_ip="127.0.0.1", port=tunnel, timeout=timeout, connection=connection)
            else:
                self._setup_admin(oam_ip=oam_ip, bts_port=https_port, timeout=timeout, connection=connection)
                _check_sysmod_status_inner(oam_ip=oam_ip, port=https_port, timeout=timeout, connection=connection)
        finally:
            self._teardown_admin(connection=connection)

    def _check_bbmod_status(self, oam_ip, https_port, timeout, remote_ssh_ip, remote_ssh_user, remote_ssh_passwd,
                            remote_ssh_port, remote_oper_flag=False, connection=None):
        dict_check_status = {"administrativeState": "Unlocked", "operationalState": "Enabled"}

        def _check_bbmod_status_inner(dict_check_status, oam_ip, port, timeout, connection):
            i = 0
            delta_time = 30
            while i < timeout / delta_time:
                i += 1
                try:
                    check_sbts_bbmod_status(dict_check_status=dict_check_status, oam_ip=oam_ip, port=port,
                                            connection=connection)
                    break
                except Exception:
                    logger.error("Check bbmod failed, try again after sleep {}s".format(delta_time))
                    time.sleep(delta_time)
                    continue
            else:
                raise Exception("Check bbmod failed in {}s".format(timeout))

        def _get_bbmod_hw_info(oam_ip, port, connection):
            adm = admin()
            i = 0
            delta_time = 60
            if not connection:
                adm.setup_admin(bts_host=oam_ip, bts_port=port)

            while i < timeout / 2 / delta_time:
                i += 1
                try:
                    logger.info("try get detect hw info times: {}".format(i), also_console=True)
                    hw_info = adm.get_detected_hw_info(connection=connection, timeout=10)
                    break
                except Exception as Ex:
                    logger.error(Ex)
                    logger.info("Get detect hw info failed with error info {}, try again after sleep {}s".
                                format(str(Ex), delta_time), also_console=True)
                    time.sleep(delta_time)
            else:
                logger.info("Get detect hw info failed after try {} times in {}s".format(i, timeout / 2),
                            also_console=True)

            if not connection:
                adm.teardown_admin()

            return False if not hw_info.get("basebandModules") else True

        try:
            if remote_oper_flag:
                tunnels = self._setup_tunnel(oam_ip=oam_ip, port=https_port, remote_ssh_ip=remote_ssh_ip,
                                             remote_ssh_user=remote_ssh_user, remote_ssh_passwd=remote_ssh_passwd,
                                             remote_ssh_port=remote_ssh_port, timeout=timeout)
                for tunnel in tunnels:
                    self._setup_admin(oam_ip="127.0.0.1", bts_port=tunnel, timeout=timeout, connection=connection)
                    hw_type = _get_bbmod_hw_info(oam_ip="127.0.0.1", port=tunnel, connection=connection)
                    if hw_type:
                        _check_bbmod_status_inner(dict_check_status=dict_check_status, oam_ip="127.0.0.1", port=tunnel,
                                                  timeout=timeout, connection=connection)
                    else:
                        logger.info("This testline dont have BBMOD, skip BBMOD checking", also_console=True)
            else:
                self._setup_admin(oam_ip=oam_ip, bts_port=https_port, timeout=timeout, connection=connection)
                hw_type = _get_bbmod_hw_info(oam_ip=oam_ip, port=https_port, connection=connection)
                if hw_type:
                    _check_bbmod_status_inner(dict_check_status=dict_check_status, oam_ip=oam_ip, port=https_port,
                                              timeout=timeout, connection=connection)
                else:
                    logger.info("This testline dont have BBMOD, skip BBMOD checking", also_console=True)
        finally:
            self._teardown_admin(connection=connection)

    def _plan_commission(self, scf_file, oam_ip, https_port, timeout, remote_ssh_ip,
                         remote_ssh_user, remote_ssh_passwd,
                         remote_ssh_port, remote_oper_flag=False, connection=None):

        def _plan_commission_inner(scf_file, oam_ip, https_port, timeout, connection):
            i = 0
            delta_time = 30
            while i < timeout / delta_time:
                i += 1
                try:
                    perform_sbts_full_commissioning(scf_file=scf_file, oam_ip=oam_ip, port=https_port, timeout=timeout,
                                                    connection=connection)
                    break
                except Exception:
                    logger.error("Perform bbu commission failed, try again after sleep {}s".format(delta_time))
                    time.sleep(delta_time)
                    continue
            else:
                logger.info("Perform bbu commission failed in {}s".format(timeout),
                            also_console=True)

        try:
            if remote_oper_flag:
                tunnels = self._setup_tunnel(oam_ip=oam_ip, port=https_port, remote_ssh_ip=remote_ssh_ip,
                                             remote_ssh_user=remote_ssh_user, remote_ssh_passwd=remote_ssh_passwd,
                                             remote_ssh_port=remote_ssh_port, timeout=timeout)
                for tunnel in tunnels:
                    self._setup_admin(oam_ip="127.0.0.1", bts_port=tunnel, timeout=timeout, connection=connection)
                    _plan_commission_inner(scf_file=scf_file, oam_ip="127.0.0.1", https_port=tunnel, timeout=timeout,
                                           connection=connection)
            else:
                self._setup_admin(oam_ip=oam_ip, bts_port=https_port, timeout=timeout, connection=connection)
                _plan_commission_inner(scf_file=scf_file, oam_ip=oam_ip, https_port=https_port, timeout=timeout,
                                       connection=connection)
        finally:
            self._teardown_admin(connection=connection)

    def _upgrade_via_admin_cli(self, loadpkg, oam_ip, https_port, timeout, remote_ssh_ip, remote_ssh_user,
                               remote_ssh_passwd,
                               remote_ssh_port, remote_oper_flag=False, connection=None):

        def _upgrade_via_admin_cli_inner(loadpkg, oam_ip, https_port, timeout, connection):
            adm = admin()
            i = 0
            delta_time = 60
            if not connection:
                adm.setup_admin(bts_host=oam_ip, bts_port=https_port)

            while i < timeout * 4 / delta_time:
                i += 1
                try:
                    logger.info("try upgrade times: {}".format(i), also_console=True)
                    status = adm.update_software(sw_package=loadpkg, connection=connection, timeout=1200)
                    if "Software update has been completed" in status:
                        MolerTest.info("Upgrade successfully with info: {}".format(status))
                        break
                    else:
                        MolerTest.info("Operation status: {}".format(status))
                except Exception as Ex:
                    logger.error(Ex)
                logger.info("Upgrade failed, try again after sleep {}s".format(delta_time), also_console=True)
                time.sleep(delta_time)
            else:
                logger.info("Upgrade failed after try {} times in {}s".format(i, timeout * 4), also_console=True)

            if not connection:
                adm.teardown_admin()

            MolerTest.steps_end()

        try:
            if remote_oper_flag:
                tunnels = self._setup_tunnel(oam_ip=oam_ip, port=https_port, remote_ssh_ip=remote_ssh_ip,
                                             remote_ssh_user=remote_ssh_user, remote_ssh_passwd=remote_ssh_passwd,
                                             remote_ssh_port=remote_ssh_port, timeout=timeout)
                for tunnel in tunnels:
                    self._setup_admin(oam_ip="127.0.0.1", bts_port=tunnel, timeout=timeout, connection=connection)
                    _upgrade_via_admin_cli_inner(loadpkg=loadpkg, oam_ip="127.0.0.1", https_port=tunnel,
                                                 timeout=timeout,
                                                 connection=connection)
            else:
                self._setup_admin(oam_ip=oam_ip, bts_port=https_port, timeout=timeout, connection=connection)
                _upgrade_via_admin_cli_inner(loadpkg=loadpkg, oam_ip=oam_ip, https_port=https_port, timeout=timeout,
                                             connection=connection)
        finally:
            self._teardown_admin(connection=connection)

    def _check_asirmod_status(self, oam_ip, https_port, timeout, remote_ssh_ip, remote_ssh_user, remote_ssh_passwd,
                              remote_ssh_port, remote_oper_flag=False, connection=None):
        dict_check_status = {"administrativeState": "Unlocked", "operationalState": "Enabled"}

        def _check_asirmod_status_inner(oam_ip, https_port, timeout, connection=None):
            i = 0
            delta_time = 30
            while i < timeout / delta_time:
                i += 1
                try:
                    check_asirmod_status(expected_status_dict=dict_check_status, oam_ip=oam_ip, port=https_port,
                                         connection=connection)
                    break
                except Exception:
                    logger.error("Check asirmod failed, try again after sleep {}s".format(delta_time))
                    time.sleep(delta_time)
                    continue
            else:
                raise Exception("Check asirmod failed in {}s".format(timeout))

        try:
            if remote_oper_flag:
                tunnels = self._setup_tunnel(oam_ip=oam_ip, port=https_port, remote_ssh_ip=remote_ssh_ip,
                                             remote_ssh_user=remote_ssh_user, remote_ssh_passwd=remote_ssh_passwd,
                                             remote_ssh_port=remote_ssh_port, timeout=timeout)
                for tunnel in tunnels:
                    self._setup_admin(oam_ip="127.0.0.1", bts_port=tunnel, timeout=timeout, connection=connection)
                    _check_asirmod_status_inner(oam_ip="127.0.0.1", https_port=tunnel, timeout=timeout,
                                                connection=connection)
            else:
                self._setup_admin(oam_ip=oam_ip, bts_port=https_port, timeout=timeout, connection=connection)
                _check_asirmod_status_inner(oam_ip=oam_ip, https_port=https_port, timeout=timeout,
                                            connection=connection)
        finally:
            self._teardown_admin(connection=connection)

    def _plan_asir_commission(self, loadname, scf_file, remote_ssh_ip, remote_ssh_user, remote_ssh_passwd,
                              remote_ssh_port, remote_oper_flag, connection=None):
        def _install_cli(connection='install_cli'):
            asimgr = r"/opt/Nokia/Managers/BTS\ Site/ASiR\ Manager/tools"
            i = 0
            ssh_manager = ssh()
            while i < 5:
                i += 1
                try:
                    ssh_manager.connect_to(hostname=remote_ssh_ip, username=remote_ssh_user,
                                           password=remote_ssh_passwd,
                                           port=remote_ssh_port, alias=connection)
                    ssh_manager.upload_file(os.path.join(os.path.join(PKG_LOCAL_ROOTPATH, loadname),
                                                         "asi-cli.tgz"), "/tmp/asi-cli.tgz", connection=connection)
                    ssh_manager.send_command(command="sudo mkdir -p {}".format(asimgr),
                                             connection=connection)
                    ssh_manager.send_command(command="sudo tar zxf /tmp/asi-cli.tgz -C {}".format(asimgr),
                                             connection=connection)
                    ssh_manager.send_command(
                        command="sudo rm -rf {0}/CLI && sudo cp -rf {0}/scripts {0}/CLI".format(asimgr),
                        connection=connection)
                    ssh_manager.send_command(
                        command="sudo rm -rf /opt/asir && sudo ln -s {}/scripts /opt/asir".format(asimgr),
                        connection=connection)
                    ssh_manager.send_command(command="sudo chown -R ute.ute {}".format(asimgr),
                                             connection=connection)
                    ssh_manager.send_command(
                        command="sudo chown -R ute.ute /opt/asir && sudo chown -R ute.ute /opt/asir/",
                        connection=connection)
                    break
                except Exception:
                    logger.error(
                        "Install CLI failed on host: {} with username: {} and password: {} and port: {}".format(
                            remote_ssh_ip,
                            remote_ssh_user,
                            remote_ssh_passwd,
                            remote_ssh_port))
                    time.sleep(10)
            ssh_manager.disconnect(connection=connection)

        def _run_cmd():
            i = 0
            while i < 5:
                i += 1
                cmd = "cd /opt/asir/ && bash -C commission.sh -ne 192.168.255.129 " \
                      "-pw Nemuadmin:nemuuser -fullfile {}".format(scf_file)
                output = run(cmd)
                MolerTest.info("Plan asir commission result: {}".format(output))
                logger.info("Plan asir commission result: {}".format(output), also_console=True)
                if "finished successfully" in output:
                    break
                time.sleep(60)
            MolerTest.steps_end()

        def _run_cmd_remote(connection='asir_commission'):
            ssh_manager = ssh()
            i = 0
            while i < 5:
                i += 1
                ssh_manager.connect_to(hostname=remote_ssh_ip, username=remote_ssh_user, password=remote_ssh_passwd,
                                       port=remote_ssh_port, alias=connection)
                ssh_manager.upload_file(scf_file, "/tmp/192.168.255.129_scf.xml", connection=connection)
                ssh_manager.send_command(command="cd /opt/asir/ && bash -C commission.sh -ne 192.168.255.129 "
                                                 "-pw Nemuadmin:nemuuser -fullfile {}".
                                         format("/tmp/192.168.255.129_scf.xml"),
                                         connection=connection)
                output = ssh_manager.read_output(connection=connection)
                MolerTest.info("Plan asir commission result: {}".format(output))
                logger.info("Plan asir commission result: {}".format(output), also_console=True)
                if "finished successfully" in output:
                    break
                time.sleep(60)
            ssh_manager.disconnect(connection=connection)
            MolerTest.steps_end()

        if remote_oper_flag:
            _install_cli()
            _run_cmd_remote()
        else:
            _run_cmd()

    def _check_cell_status(self, oam_ip, https_port, timeout, remote_ssh_ip, remote_ssh_user, remote_ssh_passwd,
                           remote_ssh_port, remote_oper_flag=False, connection=None):
        dict_check_status = {"administrativeState": "Unlocked", "operationalState": "Enabled"}

        def _check_cell_status_inner(oam_ip, https_port, timeout, connection=None):
            i = 0
            delta_time = 30
            while i < timeout * 2 / delta_time:
                i += 1
                try:
                    check_sbts_cell_status(expected_status_dict=dict_check_status, oam_ip=oam_ip, port=https_port,
                                           connection=connection)
                    break
                except Exception:
                    logger.error("Check cell status failed, try again after sleep {}s".format(delta_time))
                    time.sleep(delta_time)
                    continue
            else:
                raise Exception("Check cell status failed in {}s".format(timeout * 2))

        try:
            if remote_oper_flag:
                tunnels = self._setup_tunnel(oam_ip=oam_ip, port=https_port, remote_ssh_ip=remote_ssh_ip,
                                             remote_ssh_user=remote_ssh_user, remote_ssh_passwd=remote_ssh_passwd,
                                             remote_ssh_port=remote_ssh_port, timeout=timeout)
                for tunnel in tunnels:
                    self._setup_admin(oam_ip="127.0.0.1", bts_port=tunnel, timeout=timeout, connection=connection)
                    _check_cell_status_inner(oam_ip="127.0.0.1", https_port=tunnel, timeout=timeout,
                                             connection=connection)
            else:
                self._setup_admin(oam_ip=oam_ip, bts_port=https_port, timeout=timeout, connection=connection)
                _check_cell_status_inner(oam_ip=oam_ip, https_port=https_port, timeout=timeout,
                                         connection=connection)
        finally:
            self._teardown_admin(connection=connection)

    def _yaft(self, loadpkg, oam_ip, port, remote_ssh_ip=None, remote_ssh_user=None, remote_ssh_passwd=None,
              remote_ssh_port=None, remote_oper_flag=False, timeout=600):
        if remote_oper_flag:
            tunnels = self._setup_tunnel(oam_ip=oam_ip, port=port, remote_ssh_ip=remote_ssh_ip,
                                         remote_ssh_user=remote_ssh_user, remote_ssh_passwd=remote_ssh_passwd,
                                         remote_ssh_port=remote_ssh_port, timeout=timeout)
            for tunnel in tunnels:
                yaft(ip_addr="127.0.0.1", port=tunnel, loadpkg=loadpkg)
        else:
            yaft(ip_addr=oam_ip, port=port, loadpkg=loadpkg)

    def _setup_tunnel(self, oam_ip, port, remote_ssh_ip, remote_ssh_user, remote_ssh_passwd,
                      remote_ssh_port, timeout):
        i = 0
        delta_time = 30
        while i < timeout / delta_time:
            try:
                i += 1
                logger.info("Try {} time to setup tunnel".format(i), also_console=True)

                with sshtunnel.open_tunnel(
                        ssh_address_or_host=(remote_ssh_ip, int(remote_ssh_port)),
                        remote_bind_address=(oam_ip, port),
                        ssh_username=remote_ssh_user,
                        ssh_password=remote_ssh_passwd,
                        block_on_close=False,
                ) as tunnel1:
                    time.sleep(5)
                    logger.info("Tunnel to bts port {} setup successfully ".format(port), also_console=True)
                    yield tunnel1.local_bind_port
                    break
            except Exception:
                logger.info("Tunnel setup failed, try again after sleep 30s",
                            also_console=True)
                time.sleep(delta_time)
        else:
            raise Exception("Tunnel setup failed finally!!!")

    def _setup_admin(self, oam_ip, bts_port, timeout, connection=None):
        i = 0
        delta_time = 30
        while i < timeout / delta_time:
            i += 1
            try:
                admin().setup_admin(bts_host=oam_ip, bts_port=bts_port, name=connection)
                break
            except Exception:
                logger.error("Setup admin connection, try again after sleep {}s".format(delta_time))
                time.sleep(delta_time)
                continue
        else:
            raise Exception("Setup admin connection failed in {}s".format(timeout * 2))

    def _teardown_admin(self, connection=None):
        admin().teardown(connection=connection)
