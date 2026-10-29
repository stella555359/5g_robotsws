"""
:copyright: Nokia Networks
:author: Grzegorz Kaczor
:contact: grzegorz.kaczor@nokia.com
"""

import logging
from taf.rfrl.procedures.resources.python.testline.TestLine import TestLine
from taf.rfrl.procedures.resources.python.rmod_operations.RmodOperations import RmodOperations
from taf.rfrl.procedures.resources.python.logger import log_input_and_output
from taf.rfrl.procedures.resources.python.vm import move_file_to_target_directory
from taf.rfrl.procedures.resources.python.sw_stream.interface import get_sw_stream
from taf.rfrl.procedures.resources.python.admin_info_model.admin_info_model import get_rmods_ip
from taf.rfrl.bts.devices.generic_bts import login_logout, GenericBts


class RmodOpCustom(GenericBts, RmodOperations):

    def __init__(self):
        super(RmodOperations, self).__init__()
        super().__init__()
        self.ru_credentials = {}

    @log_input_and_output
    def download_blackbox_file_from_ru(self, download_path, blackbox_path="/mnt/runtime",
                                       blackbox_file="BBOX5", ru_id=0, suffix="", ru_password_overwrite=None) -> str:
        return self.get_file_from_ru(ru_id=ru_id,
                                     download_path=download_path,
                                     rmod_path=blackbox_path,
                                     rmod_file_name=blackbox_file,
                                     suffix=suffix,
                                     ru_password_overwrite=ru_password_overwrite)

    @log_input_and_output
    def get_file_from_ru(self, ru_id, download_path, rmod_path, rmod_file_name, suffix="", ru_password_overwrite=None,
                         slave_bts=False) -> str:
        final_file_path = f"{download_path}/RU-{ru_id}_{rmod_file_name}{suffix}"
        logging.info(f"Downloading {rmod_path}/{rmod_file_name} file from RMOD-{ru_id} to {final_file_path}")

        self._get_file_from_rmod(ru_id=ru_id, filename=rmod_file_name, rmod_path=rmod_path,
                                 local_path=download_path, slave_bts=slave_bts,
                                 ru_password_overwrite=ru_password_overwrite)
        move_file_to_target_directory(f"{download_path}/{rmod_file_name}", final_file_path)
        return final_file_path

    @log_input_and_output
    @login_logout
    def get_all_rus_credentials(self, sw_stream=None, custom_password=None, bts_id=0, du_id=0):
        testline = TestLine()
        sw_stream = get_sw_stream() if sw_stream is None else sw_stream
        rmods_serial_number_ip = get_rmods_ip(self.rest_alias.format(bts_id, du_id))
        radio_count = testline.get_count_of_radios()
        for ru in range(radio_count):
            ru_serial_number = testline.get_radio_serial_number(ru_id=ru)
            username, password = testline.get_rmod_credentials_by_sn(rmod_sn=ru_serial_number, sw_stream=sw_stream)
            if custom_password is not None:
                password = custom_password

            try:
                self.ru_credentials[ru_serial_number] = {
                    'ip': rmods_serial_number_ip[ru_serial_number],
                    'username': username,
                    'password': password,
                    'sn': ru_serial_number
                }
            except KeyError:
                logging.error(f"Could not extract IP from BTS for RU with serial number {ru_serial_number}, skipping")
        logging.info(f"Extracted testline infos: {self.ru_credentials}")

    @log_input_and_output
    @login_logout
    def _get_rmod_ssh_credentials(self, ru_id=0, sw_stream=None, custom_password=None,
                                  bts_id=0, du_id=0) -> dict:
        testline = TestLine()
        sw_stream = get_sw_stream() if sw_stream is None else sw_stream
        rmods_serial_number_ip = get_rmods_ip(self.rest_alias.format(bts_id, du_id))
        ru_serial_number = testline.get_radio_serial_number(ru_id=ru_id)
        username, password = testline.get_rmod_credentials_by_sn(rmod_sn=ru_serial_number, sw_stream=sw_stream)
        if custom_password is not None:
            password = custom_password

        rmod_ssh_credentials = {
            'ip': rmods_serial_number_ip[ru_serial_number],
            'username': username,
            'password': password,
            'sn': ru_serial_number
        }

        return rmod_ssh_credentials

    def _get_rmod_ssh_credentials_simplified(self, ru_id=0) -> dict:
        testline = TestLine()
        ru_serial_number = testline.get_radio_serial_number(ru_id=ru_id)
        return self.ru_credentials[ru_serial_number]

    @log_input_and_output
    def _get_file_from_rmod_with_dynamic_ip_extraction(self, ru_id, filename, rmod_path, local_path, slave_bts,
                                                       sw_stream=None, switch_to_rfsw_user=True,
                                                       ru_password_overwrite=None) -> str:

        self._rmod_credentials = self._get_rmod_ssh_credentials(ru_id=ru_id,
                                                                sw_stream=sw_stream,
                                                                custom_password=ru_password_overwrite)
        self._get_current_output_and_reconnect_channel_if_needed(slave_bts=slave_bts)
        super().get_file_from_rmod_to_smod(filename=filename, smod_path="/ram", rmod_path=rmod_path,
                                           rmod_ip=self._rmod_credentials['ip'],
                                           username=self._rmod_credentials['username'],
                                           password=self._rmod_credentials['password'],
                                           slave_bts=slave_bts,
                                           switch_to_rfsw=switch_to_rfsw_user)

        super().download_file_from_smod_to_vm(filename=filename, smod_path="/ram", local_path=local_path,
                                              slave_bts=slave_bts)
        logging.info("File has been downloaded successfully.")

        return f"{local_path}/{filename}"

    @log_input_and_output
    def _get_file_from_rmod(self, ru_id, filename, rmod_path, local_path, slave_bts,
                            sw_stream=None, switch_to_rfsw_user=True, ru_password_overwrite=None) -> str:
        self._rmod_credentials = self._get_rmod_ssh_credentials_simplified(ru_id=ru_id)
        self._get_current_output_and_reconnect_channel_if_needed(slave_bts=slave_bts)
        super().get_file_from_rmod_to_smod(filename=filename, smod_path="/ram", rmod_path=rmod_path,
                                           rmod_ip=self._rmod_credentials['ip'],
                                           username=self._rmod_credentials['username'],
                                           password=self._rmod_credentials['password'],
                                           slave_bts=slave_bts,
                                           switch_to_rfsw=switch_to_rfsw_user)

        super().download_file_from_smod_to_vm(filename=filename, smod_path="/ram", local_path=local_path,
                                              slave_bts=slave_bts)
        logging.info("File has been downloaded successfully.")

        return f"{local_path}/{filename}"
