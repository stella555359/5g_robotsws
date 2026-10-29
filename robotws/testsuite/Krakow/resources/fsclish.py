from moler.exceptions import CommandFailure

from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from robot.libraries.BuiltIn import BuiltIn


class Fsclish(object):
    def __init__(self):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.cu_address = tl.gnbs[0].cu.backhaul_site_oam_ip

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def restore_default_rcp_certificates(self, bts_id=0):
        """
        Restore default RCP certificates.

        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}_CU".format(bts_id), initial_state="FSCLISH")
        delete_cmd = vm.get_cmd(cmd_name="delete", cmd_params={"options": "security cert httpd ee-cert-key-pair"})
        try:
            delete_cmd()
        except CommandFailure as cf:
            if "Failed to delete end-entity certificate of the specified service domain" not in str(cf):
                raise cf
        delete_cmd = vm.get_cmd(cmd_name="delete", cmd_params={"options": "security cert httpd ca-cert all"})
        delete_cmd()
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def upload_and_install_certificates_on_cu(self, ee, ca, key, bts_id=0):
        """
        Upload and install certificates used for https connection on CU.

        :param ee: path to ee.pem file
        :param ca: path to ca.pem file
        :param key: path to key.pem file
        :param bts_id: ID of BTS
        :return: None
        """
        self._upload_certificates(ee, ca, key, bts_id)
        vm = DeviceFactory.get_device("GNB{}_CU".format(bts_id), initial_state="FSCLISH")
        set_cmd = vm.get_cmd(cmd_name="set", cmd_params={
            "options": "security cert default ca-cert cert-file /home/robot/ca.pem "
                       "validation disabled profile-check disabled ca-id Emssim_CA"})
        set_cmd()
        set_cmd = vm.get_cmd(cmd_name="set", cmd_params={
            "options": "security cert default ee-cert cert-file /home/robot/ee.pem key-file /home/robot/key.pem "
                       "validation disabled"})
        set_cmd()
        MolerTest.steps_end()

    def _upload_certificates(self, ee, ca, key, bts_id=0):
        """
        Upload certificates on CU.

        :param ee: path to ee.pem file
        :param ca: path to ca.pem file
        :param key: path to key.pem file
        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}_CU".format(bts_id), initial_state="UNIX_LOCAL")
        scp_cmd = vm.get_cmd(cmd_name="scp", cmd_params={
            "source": "{} {} {}".format(ee, ca, key), "dest": "robot@{}:/home/robot/".format(self.cu_address),
            "password": "rastre1"})
        scp_cmd()
