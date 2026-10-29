from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from robot.libraries.BuiltIn import BuiltIn
from pathlib import Path
import os.path
from robot.api import logger
from pprint import pformat
from typing import Union
from taf.rfrl.utilities.test_config import DefaultFileLocation


class RfcOperations:
    """implementation for tests related to RFC operations"""

    _rfc = None

    @classmethod
    def get_rfc_operations(cls):
        """
        Get RfcOperations object.
        :return: instance of RfcOperations
        """
        if cls._rfc is None:
            cls._rfc = RfcOperations()
        return cls._rfc

    def __init__(self):
        self._asir: GnbAsirHubOperations = None
        self._delta_parent_path = None

    def _get_delta_path(self, file_name: str) -> str:
        """
        Get full absolute path to delta file for specified setup.
        :param file_name: Name of delta file
        :return: Full absolute path to delta file
        """
        if self._delta_parent_path is None:
            source_path = Path(__file__).resolve()
            source_dir = source_path.parent
            setup_name = BuiltIn().get_variable_value("${TL_NAME}")
            logger.info(f"Setup name: '{setup_name}'")
            release = DefaultFileLocation().get_commissioning_branch()
            logger.info(f"release: '{release}'.")
            self._delta_parent_path = os.path.abspath(os.path.join(source_dir, "../", setup_name, release))
            logger.info(f"parent path: '{self._delta_parent_path}'")
        full_path = os.path.join(self._delta_parent_path, file_name)
        logger.info(f"full path to delta: '{full_path}', path exist check: {os.path.isfile(full_path)}")
        return full_path

    # function to delete RFC
    def delete_rfc(self) -> None:
        """
        Delete RFC.
        :return: None
        """
        scf_path = self._get_delta_path("config_delete.xml")
        logger.info(f"Deleting RFC with SCF: '{scf_path}'")
        self._get_asir().perform_asir_commissioning(scf_path=scf_path)

    def create_rfc(self) -> None:
        """
        Create RFC.
        :return: None
        """
        scf_path = self._get_delta_path("config_add.xml")
        logger.info(f"Creating RFC with SCF: '{scf_path}'")
        self._get_asir().perform_asir_commissioning(scf_path=scf_path)

    def verify_no_rfcs(self, cells_no: int) -> None:
        """
        Verify number of RFCs.

        :param cells_no: Number of RFCs
        :return: None
        """
        asir: GnbAsirHubOperations = self._get_asir()
        rfc = 0
        cells_info = asir.get_all_cells_info()
        for cell_info in cells_info:
            if 'RFCCELL_' in cell_info["dn"]:
                rfc += 1
        if rfc == cells_no:
            logger.info(f"Number of RFCs is as expected: '{rfc}'")
        else:
            msg = f"Number of RFCs '{rfc}' is not as expected: '{cells_no}'. Cells info: '{pformat(cells_info)}'"
            logger.error(msg)
            raise Exception(msg)

    def verify_only_allowed_alarms(self, allowed_alarms: Union[list, str, None] = None) -> None:
        """
        Verify only allowed alarms are active.

        :param allowed_alarms: List of allowed alarms
        :return: None
        """
        asir: GnbAsirHubOperations = self._get_asir()
        logger.info(f"Verifying only allowed alarms are active1: '{allowed_alarms}'")
        if allowed_alarms is None:
            allowed_alarms = []
        elif type(allowed_alarms) is str:
            allowed_alarms = allowed_alarms.split()
        logger.info(f"Verifying only allowed alarms are active2: '{allowed_alarms}'")
        asir.verify_only_allowed_alarms_are_active(allowed_alarms=allowed_alarms)

    def _get_asir(self) -> GnbAsirHubOperations:
        """
        Get AsirHubOperations object.
        """
        if self._asir is None:
            self._asir = GnbAsirHubOperations()
        return self._asir


def delete_rfc() -> None:
    rf = RfcOperations.get_rfc_operations()
    rf.delete_rfc()


def add_rfc() -> None:
    rf = RfcOperations.get_rfc_operations()
    rf.create_rfc()


def verify_no_rfcs(cells_no: int) -> None:
    rf = RfcOperations.get_rfc_operations()
    rf.verify_no_rfcs(cells_no=cells_no)


def verify_only_allowed_alarms(allowed_alarms: Union[list, str, None] = None) -> None:
    rf = RfcOperations.get_rfc_operations()
    rf.verify_only_allowed_alarms(allowed_alarms=allowed_alarms)
