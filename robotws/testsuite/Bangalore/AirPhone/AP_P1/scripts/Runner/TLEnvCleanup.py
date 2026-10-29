import os
import sys
try:
    import click
except ImportError:
    os.system('pip install click')
    import click
try:
    from ute_common_config_files.scfc.scfc import Scfc
except ImportError:
    os.system('pip install ute_common_config_files')
    from ute_common_config_files.scfc.scfc import Scfc
import importlib
from APGNBControl import APGNBControl
from ORANOperations import ORANOperations
from retrying import retry
from taf.sbts.oam.coam.admin import admin
from errors import ADETTimeout, RadioNotInstalled, retry_if_ap_failed_startup
from time import sleep
from taf.transport.ssh.exceptions import ConnectFailedError
from IphyUpdate import IphyUpdate
from Regression_runner import Host
try:
    import loguru
except ImportError:
    os.system('pip install loguru')
    import loguru

TESTLINE_CONFIGURATION_DIR = "/home/ute/testline_configuration/"


class TLEnvCleanup():
    def __init__(self):
        self.apctrl = APGNBControl()
        pass

    def env_reset_after_suite(self, config_folder, update_required="False", is_oran="False", output_dir=''):
        self.check_if_gnb_is_ready()
        self.get_config_files_to_output_dir(output_dir)
        sleep(120)
        self.env_cleanup_ap(config_folder, update_required, is_oran)
        self.env_cleanup_gnb(config_folder)
        self.env_cleanup_wts(config_folder)
        self.load_scf_gnb(config_folder, update_required)
        self.check_if_ap_gnb_ready()
        loguru.logger.info("GNB is in configured state")
        os.system('pkill egate')
        os.system('sudo pkill edaemon')
        os.system('ps -aef | grep -i egate')
        os.system('ps -aef | grep -i edaemon')
        os.system('ps -aef | grep -i admin')
        # removed below as fetch scf id from scout was failing due to admin cli connection is being killed
        """os.system('sudo pkill node')
        os.system('ps -aef | grep -i admin')"""
        os.system('ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "10.0.1.3"')
        os.system('ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "10.0.1.2"')
        return

    @retry(retry_on_exception=retry_if_ap_failed_startup, stop_max_attempt_number=2,
           wait_fixed=5000, wrap_exception=False)
    def check_if_ap_gnb_ready(self):
        self.apctrl.wait_for_ap_to_be_reachable()
        self.apctrl.check_adet_ready()
        gnb_state = self.apctrl.check_gnb_state_configured()
        loguru.logger.info("gnb_state is {}".format(gnb_state))
        radio_state = self.apctrl.check_gnb_radio_online_state()
        loguru.logger.info("radio state is {}".format(radio_state))
        if not gnb_state or not radio_state:
            loguru.logger.info('Rebooting gnb as AP and GNB states are not as expected')
            self.apctrl.reboot_gnb_with_admin()
            raise RadioNotInstalled()
        self.apctrl.reset_reboot_count_on_gnb()
        return

    def check_if_gnb_is_ready(self):
        try:
            loguru.logger.info("Check if gnb is ready before env cleanup")
            gnb_state = self.apctrl.check_gnb_state_configured()
            radio_state = self.apctrl.check_gnb_radio_online_state()
        except Exception as e:
            loguru.logger.info(f"GNB failed to comeup with error {e}")
        return

    def activate_ap_swconfig(self):
        self.apctrl.ssh.connect_to(self.apctrl.AP_IP, 'toor4nsn', 'oZPS0POrRieRtu', alias='ap_connection')
        self.apctrl.ssh.execute('crasign /ffs/run/swconfig.txt', connection='ap_connection')
        self.apctrl.ssh.execute('craverify /ffs/run/swconfig.txt*', connection='ap_connection')
        loguru.logger.info('Succesfully activated ap swconfig.')
        self.apctrl.ssh.disconnect(connection='ap_connection')
        return

    def activate_gnb_swconfig(self):
        self.apctrl.ssh.connect_to(self.apctrl.GNB_IP, 'toor4nsn', 'oZPS0POrRieRtu', alias='gnb_connection')
        self.apctrl.ssh.execute('crasign /ffs/run/swconfig.txt', connection='gnb_connection')
        self.apctrl.ssh.execute('craverify /ffs/run/swconfig.txt*', connection='gnb_connection')
        loguru.logger.info('Succesfully activated gnb swconfig.')
        self.apctrl.ssh.disconnect(connection='gnb_connection')
        return

    def env_cleanup_ap(self, config_folder, update_required='False', is_oran='False'):
        loguru.logger.info('Cleaning up the environment on AP...')
        ap_swconfig_path = os.path.join(config_folder, 'sim', 'swconfig.txt')
        iphy_path = os.path.join(config_folder, 'sim', 'iphy.xml')
        iphy_folder = os.path.join(config_folder, 'sim')
        if update_required == 'True':
            if is_oran != 'True':
                AP_Update = IphyUpdate()
                AP_Update.set_iphy_file_to_be_updated(input_folder=iphy_folder)
                AP_Update.modify_iphy_xml_rmods_from_targetbd()
            else:
                oran_ops = ORANOperations()
                oran_ops.set_iphy_file_to_be_updated(input_folder=iphy_folder)
                oran_ops.download_and_upload_snapshot(config_folder)
        os.system("scp {0} {1}:/ffs/run/ >/dev/null 2>&1".format(ap_swconfig_path, self.apctrl.AP_IP))
        os.system("scp {0} {1}:/ffs/run/simmode/ >/dev/null 2>&1".format(iphy_path, self.apctrl.AP_IP))
        self.activate_ap_swconfig()
        return

    def env_cleanup_gnb(self, config_folder):
        loguru.logger.info('Cleaning up the environment on GNB...')
        gnb_swconfig_path = os.path.join(config_folder, 'sm', 'swconfig.txt')
        os.system("scp {0} {1}:/ffs/run/ >/dev/null 2>&1".format(gnb_swconfig_path, self.apctrl.GNB_IP))
        self.activate_gnb_swconfig()
        return

    def env_cleanup_wts(self, config_folder):
        loguru.logger.info('Cleaning up the environment on WTS...')
        wts_cfg = os.path.join(config_folder, 'wts', 'basic_setup.cfg')
        wts_lua = os.path.join(config_folder, 'wts', 'basic*.lua')
        wts_custom_folder = os.path.join(config_folder, 'wts')
        # Copy all files from wts folder to /opt/wts/latest/
        cpy_cmd = "cp -r {0}/* /opt/wts/latest/".format(wts_custom_folder)
        os.system(cpy_cmd)
        os.system("cp {0} {1}".format(wts_cfg, '/opt/wts/latest/'))
        os.system("cp {0} {1}".format(wts_cfg, '/opt/wts/latest/wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS.cfg'))
        os.system("cp {0} {1}".format(wts_lua, '/opt/wts/latest/'))
        return

    def _get_module_import(self, conf_dir, file_name):
        try:
            sys.path.append(conf_dir)
            module = importlib.import_module(file_name)
        finally:
            sys.path = sys.path[:-1]
        return module

    def update_testline_details_in_scf(self, scf_path):
        host_obj = Host("/home/ute/")
        tl_name = host_obj.get_hostname()
        tl_path = host_obj.get_tl_config_file()
        loguru.logger.info("Dir for the TL dir : {}".format(tl_path.strip(tl_name)))
        tl_config = self._get_module_import(TESTLINE_CONFIGURATION_DIR, tl_name)
        root = Scfc(scf_path)
        mo = root.find_managed_object('MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1')
        mo.find_param('vlanId').value = tl_config.tl.gnbs[0].cu.x2c.vlan_id
        mos = root.find_managed_objects('MRBTS')
        for mo_obj in mos:
            mo_obj.find_param('btsName').value = tl_name
        root.save(scf_path)

    def load_scf_gnb(self, config_folder, update_required='False'):
        scf_config_path = os.path.join(config_folder, 'sm', 'scfc.xml')
        if update_required == 'True':
            self.update_testline_details_in_scf(scf_config_path)
        loguru.logger.info('Performing gNB commissioning...')
        coam_api = admin()
        coam_admin = coam_api.connect_to()
        coam_admin.perform_commissioning(scf_file=scf_config_path, skip_parameter_relation_errors=True,
                                         should_activate=True, timeout=600)
        coam_api.teardown()
        return

    def get_config_files_to_output_dir(self, output_dir):
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
        self.apctrl.ap_wts_config_backup(output_dir)
        self.apctrl.gnb_config_backup(output_dir)
        self.apctrl.get_coam_scf(output_dir)


@click.group()
@click.pass_context
def main(ctx):
    ctx.obj = TLEnvCleanup()
    return


@main.command()
@click.argument('config_folder')
@click.option('--update_required', default="False")
@click.option('--is_oran', default="False")
@click.option('--output_dir', default="False")
@click.pass_obj
def testline_reboot_after_suite(ctx, config_folder, update_required, is_oran, output_dir):
    ctx.env_reset_after_suite(config_folder, update_required, is_oran, output_dir)
    return


@main.command()
@click.argument('config_folder')
@click.pass_obj
def update_tl_details_in_scf(ctx, config_folder):
    ctx.update_testline_details_in_scf(config_folder)
    return


@main.command()
@click.argument('config_folder')
@click.pass_obj
def update_iphy_file(ctx, config_folder):
    ctx.env_cleanup_ap(config_folder, "True")


if __name__ == '__main__':
    main()
