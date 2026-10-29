
import mock  # pylint: disable=locally-disabled, E0401
import logging

from testsuite.Ulm.ET.Performance_Test.resources.python import wts_multivm_helper
from testsuite.Ulm.ET.Performance_Test.resources.test\
    .testmock.taf_sw_wtssim_wrapper import TafSwWtssimWrapperMock


logger = logging.getLogger(__name__)

_LIB_PATH = 'testsuite.Ulm.ET.Performance_Test.resources.python'


def test_get_ue_count_for_all_egates(mocker):
    mocker.patch(f'{_LIB_PATH}.taf_sw_wtssim_wrapper.execute_egate_command_and_wait_for_data',
                 side_effect=TafSwWtssimWrapperMock().execute_egate_command_and_wait_for_data)
    mocker.patch(f'{_LIB_PATH}.taf_transport_ssh_multivm.get_tl_obj_from_current_host')
    mocker.patch(f'{_LIB_PATH}.taf_transport_ssh_multivm.test_pc_count', return_value=3)
    cells = wts_multivm_helper.get_ue_count_for_all_egates(3, tl=None)
    assert len(cells) == 3
    assert int(cells[0]) == 1
    assert int(cells[1]) == 2
    assert int(cells[2]) == 3
    assert sum(cells) == 6


def test_get_sib_for_all_vms(mocker):
    mocker.patch(f'{_LIB_PATH}.taf_sw_wtssim_wrapper.execute_egate_command')
    mocker.patch(f'{_LIB_PATH}.taf_transport_ssh_multivm.get_tl_obj_from_current_host')
    mocker.patch(f'{_LIB_PATH}.taf_transport_ssh_multivm.test_pc_count', return_value=3)
    sshm = mocker.patch(f'{_LIB_PATH}.taf_transport_ssh_multivm.execute')
    sshm.return_value = _egate_console_sib_mock()

    sibs = wts_multivm_helper.get_sib_for_all_vms()
    assert wts_multivm_helper.is_sib_ready(
        sibs['enbs']['2'],
        start_cell=1,
        end_cell=6
    ) is True


def test_get_sib_for_all_vms_missing_one_cell(mocker):
    mocker.patch(f'{_LIB_PATH}.taf_sw_wtssim_wrapper.execute_egate_command')
    mocker.patch(f'{_LIB_PATH}.taf_transport_ssh_multivm.get_tl_obj_from_current_host')
    mocker.patch(f'{_LIB_PATH}.taf_transport_ssh_multivm.test_pc_count', return_value=3)
    sshm = mocker.patch(f'{_LIB_PATH}.taf_transport_ssh_multivm.execute')
    sshm.return_value = _egate_console_sib_mock()
    sibs = wts_multivm_helper.get_sib_for_all_vms()
    assert wts_multivm_helper.is_sib_ready(
        sibs['enbs']['2'],
        start_cell=1,
        end_cell=7
    ) is False


def test_get_ap_cell_for_all_vms(mocker):
    mocker.patch(f'{_LIB_PATH}.taf_sw_wtssim_wrapper.execute_egate_command')
    mocker.patch(f'{_LIB_PATH}.taf_transport_ssh_multivm.get_tl_obj_from_current_host')
    mocker.patch(f'{_LIB_PATH}.taf_transport_ssh_multivm.test_pc_count', return_value=3)
    sshm = mocker.patch(f'{_LIB_PATH}.taf_transport_ssh_multivm.execute')
    sshm.return_value = _egate_console_sib_mock()
    ap_cells = wts_multivm_helper.get_ap_cell_for_all_vms()
    assert wts_multivm_helper.is_ap_cell_ready(
        ap_cells,
        start_cell=1,
        end_cell=6
    ) is True


def test_get_ap_cell_for_all_vms_missing_one_cell(mocker):
    mocker.patch(f'{_LIB_PATH}.taf_sw_wtssim_wrapper.execute_egate_command')
    mocker.patch(f'{_LIB_PATH}.taf_transport_ssh_multivm.get_tl_obj_from_current_host')
    mocker.patch(f'{_LIB_PATH}.taf_transport_ssh_multivm.test_pc_count', return_value=3)
    sshm = mocker.patch(f'{_LIB_PATH}.taf_transport_ssh_multivm.execute')
    sshm.return_value = _egate_console_sib_mock()
    ap_cells = wts_multivm_helper.get_ap_cell_for_all_vms()
    assert wts_multivm_helper.is_ap_cell_ready(
        ap_cells,
        start_cell=1,
        end_cell=7
    ) is False


def _egate_console_sib_mock():
    return """
UEC-6: eNB 2 cell 1: SystemInformationBlockType1-NR updated
UEC-5: eNB 2 cell 1: SystemInformationBlockType1-NR updated
UEC-2: eNB 2 cell 1: SystemInformationBlockType1-NR updated
UEC-4: eNB 2 cell 1: SystemInformationBlockType1-NR updated
UEC-1: eNB 2 cell 1: SystemInformationBlockType1-NR updated
UEC-3: eNB 2 cell 1: SystemInformationBlockType1-NR updated
UEC-2: eNB 2 cell 2: SystemInformationBlockType1-NR updated
UEC-4: eNB 2 cell 2: SystemInformationBlockType1-NR updated
UEC-1: eNB 2 cell 2: SystemInformationBlockType1-NR updated
UEC-5: eNB 2 cell 2: SystemInformationBlockType1-NR updated
UEC-3: eNB 2 cell 2: SystemInformationBlockType1-NR updated
UEC-6: eNB 2 cell 2: SystemInformationBlockType1-NR updated
UEC-4: eNB 2 cell 6: SystemInformationBlockType1-NR updated
UEC-3: eNB 2 cell 6: SystemInformationBlockType1-NR updated
UEC-1: eNB 2 cell 6: SystemInformationBlockType1-NR updated
UEC-5: eNB 2 cell 6: SystemInformationBlockType1-NR updated
UEC-6: eNB 2 cell 6: SystemInformationBlockType1-NR updated
UEC-2: eNB 2 cell 6: SystemInformationBlockType1-NR updated
UEC-3: eNB 2 cell 5: SystemInformationBlockType1-NR updated
UEC-5: eNB 2 cell 5: SystemInformationBlockType1-NR updated
UEC-4: eNB 2 cell 5: SystemInformationBlockType1-NR updated
UEC-6: eNB 2 cell 5: SystemInformationBlockType1-NR updated
UEC-2: eNB 2 cell 5: SystemInformationBlockType1-NR updated
UEC-1: eNB 2 cell 5: SystemInformationBlockType1-NR updated
UEC-2: eNB 2 cell 4: SystemInformationBlockType1-NR updated
UEC-1: eNB 2 cell 4: SystemInformationBlockType1-NR updated
UEC-5: eNB 2 cell 4: SystemInformationBlockType1-NR updated
UEC-3: eNB 2 cell 4: SystemInformationBlockType1-NR updated
UEC-4: eNB 2 cell 4: SystemInformationBlockType1-NR updated
UEC-6: eNB 2 cell 4: SystemInformationBlockType1-NR updated
UEC-1: eNB 2 cell 3: SystemInformationBlockType1-NR updated
UEC-2: eNB 2 cell 3: SystemInformationBlockType1-NR updated
UEC-6: eNB 2 cell 3: SystemInformationBlockType1-NR updated
UEC-5: eNB 2 cell 3: SystemInformationBlockType1-NR updated
UEC-4: eNB 2 cell 3: SystemInformationBlockType1-NR updated
UEC-3: eNB 2 cell 3: SystemInformationBlockType1-NR updated
UEC-5: Airphone: Cell Setup completed for [CELL_ID:1]
UEC-5: Airphone: Cell Setup completed for [CELL_ID:2]
UEC-5: Airphone: Cell Setup completed for [CELL_ID:6]
UEC-5: Airphone: Cell Setup completed for [CELL_ID:5]
UEC-5: Airphone: Cell Setup completed for [CELL_ID:4]
UEC-5: Airphone: Cell Setup completed for [CELL_ID:3]
"""
