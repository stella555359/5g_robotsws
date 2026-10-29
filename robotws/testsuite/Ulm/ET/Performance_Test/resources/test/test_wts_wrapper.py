
import mock  # pylint: disable=locally-disabled, E0401
import pathlib
import logging

from testsuite.Ulm.ET.Performance_Test.resources.test.testmock.ute_wtssim import UteWtsSimMock
from testsuite.Ulm.ET.Performance_Test.resources.python import wts_wrapper


logger = logging.getLogger(__name__)


def test_get_ue_count_per_cell():
    num_cells = 3
    cells = [  # (cell number, ue count)
        (1, 100),
        (3, 300)]
    active = 400
    with mock.patch('testsuite.Ulm.ET.Performance_Test.resources.python.wts_manager.send_command_to_egate',
                    return_value=UteWtsSimMock.generate_ue_summary(active=active, cells=cells)):
        ue_count = wts_wrapper.get_ue_count_per_cell(num_cells=num_cells)
    assert len(ue_count) == num_cells
    assert ue_count[0] == 100
    assert ue_count[1] == 0
    assert ue_count[2] == 300


def test_get_ue_count_per_cell_from_text():
    with open(pathlib.Path(__file__).resolve().parent.joinpath(
            'testmock', 'files', 'egate', 'ue_summary.txt'), 'r', encoding='utf-8') as f:
        ue_summary_str = f.read()
    with mock.patch('testsuite.Ulm.ET.Performance_Test.resources.python.wts_manager.send_command_to_egate',
                    return_value=ue_summary_str):
        ue_count = wts_wrapper.get_ue_count_per_cell(num_cells=1)
    print(ue_count)
    assert len(ue_count) == 1
    assert ue_count[0] == 106


def test_get_ue_count_per_cell_table():
    with open(pathlib.Path(__file__).resolve().parent.joinpath(
            'testmock', 'files', 'egate', 'ue_summary.txt'), 'r', encoding='utf-8') as f:
        ue_summary_str = f.read()
    with mock.patch('testsuite.Ulm.ET.Performance_Test.resources.python.wts_manager.send_command_to_egate',
                    return_value=ue_summary_str):
        output = wts_wrapper.get_ue_count_per_cell_table(
            num_cells=1, active_cells=None, expected=[106, 106, 106])
        assert 'Cell 01: 106 / 106 ( 100.0 %)' in output
