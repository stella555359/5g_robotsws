from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_SuiteSetup.upgrade import AsirUpgrade
import time
from robot.api import logger


class DasUpgrade(AsirUpgrade):
    def upgrade(self, loadname, loadpkg, comm_subtype=None, testline=None,
                oam_ip="192.168.255.129", username="toor4nsn",
                password="oZPS0POrRieRtu", ssh_port=22, https_port=443,
                remote_vm_ip=None, remote_vm_user=None, remote_vm_passwd=None, remote_vm_port=22,
                remote_oper_flag=False, timeout=600, connection=None):

        # ********************************************************************************* #
        logger.info('=' * 10 + 'Start<{}>: check sysmod status after yaft'.format(connection) + '=' * 10,
                    also_console=True)
        self._check_sysmod_status(oam_ip=oam_ip, https_port=https_port, remote_ssh_ip=remote_vm_ip,
                                  remote_ssh_user=remote_vm_user, remote_ssh_passwd=remote_vm_passwd,
                                  remote_ssh_port=remote_vm_port, remote_oper_flag=remote_oper_flag, timeout=timeout,
                                  connection=connection)
        logger.info('=' * 10 + 'End<{}>: check sysmod status after yaft'.format(connection) + '=' * 10,
                    also_console=True)

        # ********************************************************************************* #
        logger.info('=' * 10 + 'Start<{}>: get commission'.format(connection) + '=' * 10, also_console=True)
        gnb_commission_path, asir_commission_path = self._get_commission(loadname=loadname,
                                                                         testline=testline,
                                                                         comm_subtype=comm_subtype)
        logger.info('=' * 10 + 'End<{}>: get commission'.format(connection) + '=' * 10, also_console=True)

        # # ********************************************************************************* #
        logger.info('=' * 10 + 'Start<{}>: check bbmod status after yaft'.format(connection) + '=' * 10,
                    also_console=True)
        try:
            self._check_bbmod_status(oam_ip=oam_ip, https_port=https_port, timeout=timeout, remote_ssh_ip=remote_vm_ip,
                                     remote_ssh_user=remote_vm_user, remote_ssh_passwd=remote_vm_passwd,
                                     remote_ssh_port=remote_vm_port, remote_oper_flag=remote_oper_flag,
                                     connection=connection)
        except Exception as Ex:
            logger.error("Check bbmod failed with err: {}, one reason maybe this is ASOE testline".format(str(Ex)))
        logger.info('=' * 10 + 'End<{}>: check bbmod status after yaft'.format(connection) + '=' * 10,
                    also_console=True)

        # # ********************************************************************************* #
        logger.info('=' * 10 + 'Start<{}>: update swconfig'.format(connection) + '=' * 10, also_console=True)
        self._update_swconfig(loadname=loadname, oam_ip=oam_ip, username=username,
                              password=password, port=ssh_port, remote_ssh_ip=remote_vm_ip,
                              remote_ssh_user=remote_vm_user, remote_ssh_passwd=remote_vm_passwd,
                              remote_ssh_port=remote_vm_port, remote_oper_flag=remote_oper_flag,
                              timeout=timeout)
        logger.info('=' * 10 + 'End<{}>: update swconfig'.format(connection) + '=' * 10, also_console=True)

        # # ********************************************************************************* #
        logger.info('=' * 10 + 'Start<{}>: plan macro commission'.format(connection) + '=' * 10, also_console=True)
        self._plan_commission(scf_file=gnb_commission_path, oam_ip=oam_ip, https_port=https_port, timeout=timeout,
                              remote_ssh_ip=remote_vm_ip,
                              remote_ssh_user=remote_vm_user, remote_ssh_passwd=remote_vm_passwd,
                              remote_ssh_port=remote_vm_port, remote_oper_flag=remote_oper_flag,
                              connection=connection)
        logger.info('=' * 10 + 'End<{}>: plan macro commission'.format(connection) + '=' * 10, also_console=True)

        # # ********************************************************************************* #
        logger.info(
            '=' * 10 + 'Start<{}>: check sysmod status after plan marco commission'.format(connection) + '=' * 10,
            also_console=True)
        self._check_sysmod_status(oam_ip=oam_ip, https_port=https_port, remote_ssh_ip=remote_vm_ip,
                                  remote_ssh_user=remote_vm_user, remote_ssh_passwd=remote_vm_passwd,
                                  remote_ssh_port=remote_vm_port, remote_oper_flag=remote_oper_flag, timeout=timeout,
                                  connection=connection)
        logger.info('=' * 10 + 'End<{}>: check sysmod status after plan marco commission'.
                    format(connection) + '=' * 10, also_console=True)

        # # ********************************************************************************* #
        logger.info(
            '=' * 10 + 'Start<{}>: check bbmod status after plan marco commission'.format(connection) + '=' * 10,
            also_console=True)
        try:
            self._check_bbmod_status(oam_ip=oam_ip, https_port=https_port, timeout=timeout, remote_ssh_ip=remote_vm_ip,
                                     remote_ssh_user=remote_vm_user, remote_ssh_passwd=remote_vm_passwd,
                                     remote_ssh_port=remote_vm_port, remote_oper_flag=remote_oper_flag,
                                     connection=connection)
        except Exception as Ex:
            logger.error("Check bbmod failed with err: {}, one reason maybe this is ASOE testline".format(str(Ex)))
        logger.info('=' * 10 + 'End<{}>: check bbmod status after plan marco commission'.format(connection) + '=' * 10,
                    also_console=True)

        # # ********************************************************************************* #
        if not remote_oper_flag:
            logger.info('=' * 10 + 'Start<{}>: upgrade via admin cli'.format(connection) + '=' * 10, also_console=True)
            self._upgrade_via_admin_cli(loadpkg=loadpkg, oam_ip=oam_ip, https_port=https_port, timeout=timeout,
                                        remote_ssh_ip=remote_vm_ip,
                                        remote_ssh_user=remote_vm_user, remote_ssh_passwd=remote_vm_passwd,
                                        remote_ssh_port=remote_vm_port, remote_oper_flag=remote_oper_flag,
                                        connection=connection)
            logger.info('=' * 10 + 'End<{}>: upgrade via admin cli'.format(connection) + '=' * 10, also_console=True)

            # # ********************************************************************************* #
            logger.info('=' * 10 + 'Start<{}>: check sysmod status after upgrade'.format(connection) + '=' * 10,
                        also_console=True)
            self._check_sysmod_status(oam_ip=oam_ip, https_port=https_port, remote_ssh_ip=remote_vm_ip,
                                      remote_ssh_user=remote_vm_user, remote_ssh_passwd=remote_vm_passwd,
                                      remote_ssh_port=remote_vm_port, remote_oper_flag=remote_oper_flag,
                                      timeout=timeout, connection=connection)
            logger.info('=' * 10 + 'End<{}>: check sysmod status after upgrade'.format(connection) + '=' * 10,
                        also_console=True)

            # # ********************************************************************************* #
            logger.info('=' * 10 + 'Start<{}>: check bbmod status after upgrade'.format(connection) + '=' * 10,
                        also_console=True)
            try:
                self._check_bbmod_status(oam_ip=oam_ip, https_port=https_port, timeout=timeout,
                                         remote_ssh_ip=remote_vm_ip,
                                         remote_ssh_user=remote_vm_user, remote_ssh_passwd=remote_vm_passwd,
                                         remote_ssh_port=remote_vm_port, remote_oper_flag=remote_oper_flag,
                                         connection=connection)
            except Exception as Ex:
                logger.error("Check bbmod failed with err: {}, one reason maybe this is ASOE testline".format(str(Ex)))
            logger.info('=' * 10 + 'End<{}>: check bbmod status after upgrade'.format(connection) + '=' * 10,
                        also_console=True)

            # # ********************************************************************************* #
            time.sleep(20)
            logger.info('=' * 10 + 'Start<{}>: check cell status'.format(connection) + '=' * 10, also_console=True)
            self._check_cell_status(oam_ip=oam_ip, https_port=https_port, timeout=timeout,
                                    remote_ssh_ip=remote_vm_ip,
                                    remote_ssh_user=remote_vm_user, remote_ssh_passwd=remote_vm_passwd,
                                    remote_ssh_port=remote_vm_port, remote_oper_flag=remote_oper_flag,
                                    connection=connection)
            logger.info('=' * 10 + 'End<{}>: check cell status'.format(connection) + '=' * 10, also_console=True)
