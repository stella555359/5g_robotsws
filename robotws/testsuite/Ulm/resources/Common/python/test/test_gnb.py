from testsuite.Ulm.resources.Common.python import gnb
import pytest
import unittest.mock as mock
from testsuite.Ulm.resources.Common.python import connect as connect


def test_fetch_classical_sw_version():
    with mock.patch("testsuite.Ulm.resources.Common.python.gnb.BuiltIn") as builtin:
        mock_api = mock.Mock()
        builtin.return_value.get_library_instance.return_value = mock_api
        mock_api.get_sw_version.side_effect = get_sw_version_admin_mock
        result_0 = gnb.fetch_classical_sw_version("test_alias_0")
        assert result_0 == "SBTS00_ENB_9999_250604_111111"

        result_1 = gnb.fetch_classical_sw_version("test_alias_1")
        assert result_1 == "SBTS00_ENB_9999_250604_222222"


def get_sw_version_admin_mock(connection):
    if connection == "test_alias_0":
        return "SBTS00_ENB_9999_250604_111111"
    elif connection == "test_alias_1":
        return "SBTS00_ENB_9999_250604_222222"


chk_adet_output = """
++ [fct-4a] mcuadet         : MCU-HW-API autodetection (ADET)
   - unit 0x20 FSM2_FCT ready[0] ............................................................... ok
   - unit 0x22 FSM2_FSP1 ready[0] .............................................................. ok
   - cpu  0x2011 ready ......................................................................... ok
   - cpu  0x2230 ready ......................................................................... ok
   - cpu  0x2240 ready ......................................................................... ok
   - cpu  0x2250 ready ......................................................................... ok

  [fct-4a] duration : 11.5 sec
  [fct-4a] # passed : 6
  [fct-4a] # failed : 0
"""

chk_adet_output_ap = """
++ [fct-0a] mcuadet         : MCU-HW-API autodetection (ADET)
   - unit 0x50 FSM5_FCT ready[0] ............................................................... ok
   - unit 0x52 FSM5_FSP1 ready[0] .............................................................. ok
   - unit 0x53 FSM5_FSP2 ready[0] .............................................................. ok
   - unit 0x54 FSM5_FSP3 ready[0] .............................................................. ok
   - cpu  0x5011 ready ......................................................................... ok
   - cpu  0x5230 ready ......................................................................... ok
   - cpu  0x5240 ready ......................................................................... ok
   - cpu  0x5250 ready ......................................................................... ok
   - cpu  0x5330 ready ......................................................................... ok
   - cpu  0x5340 ready ......................................................................... ok
   - cpu  0x5350 ready ......................................................................... ok
   - cpu  0x5430 ready ......................................................................... ok
   - cpu  0x5440 ready ......................................................................... ok
   - cpu  0x5450 ready ......................................................................... ok
"""

chk_adet_output_asoe = """
++ [asc-0a] mcuadet         : MCU-HW-API autodetection (ADET)
   - unit 0x10 FSM1_FCT ready[0] ............................................................... ok
   - cpu  0x1011 ready ......................................................................... ok
   - cpu  0x1040 ready ......................................................................... ok
   - cpu  0x1050 ready ......................................................................... ok

  [asc-0a] duration : 11.4 sec
  [asc-0a] # passed : 4
  [asc-0a] # failed : 0
"""

chk_adet_output_ap_ko = """
++ [fct-0a] mcuadet         : MCU-HW-API autodetection (ADET)
   - unit 0x50 FSM5_FCT uninitialized[1] ............................................................... ok
   - unit 0x52 FSM5_FSP1 ready[0] .............................................................. ok
   - unit 0x53 FSM5_FSP2 ready[0] .............................................................. ok
   - unit 0x54 FSM5_FSP3 uninitialized[1] .............................................................. ok
   - cpu  0x5011 ready ......................................................................... ok
   - cpu  0x5230 ready ......................................................................... ok
   - cpu  0x5240 ready ......................................................................... ok
   - cpu  0x5250 ready ......................................................................... ok
   - cpu  0x5330 ready ......................................................................... ok
   - cpu  0x5340 ready ......................................................................... ok
   - cpu  0x5350 ready ......................................................................... ok
   - cpu  0x5430 ready ......................................................................... ok
   - cpu  0x5440 ready ......................................................................... ok
   - cpu  0x5450 sleep ......................................................................... ok

"""


def test_get_cpu_lines():
    cpu_lines = gnb.get_cpu_lines(chk_adet_output)
    assert cpu_lines == [["0x2011", "ready"],
                         ["0x2230", "ready"],
                         ["0x2240", "ready"],
                         ["0x2250", "ready"]]


def test_get_cpu_lines_ap():
    cpu_lines = gnb.get_cpu_lines(chk_adet_output_ap)
    assert cpu_lines == [["0x5011", "ready"],
                         ["0x5230", "ready"],
                         ["0x5240", "ready"],
                         ["0x5250", "ready"],
                         ["0x5330", "ready"],
                         ["0x5340", "ready"],
                         ["0x5350", "ready"],
                         ["0x5430", "ready"],
                         ["0x5440", "ready"],
                         ["0x5450", "ready"]]


def test_get_cpu_lines_asoe():
    cpu_lines = gnb.get_cpu_lines(chk_adet_output_asoe)
    assert cpu_lines == [["0x1011", "ready"],
                         ["0x1040", "ready"],
                         ["0x1050", "ready"]]


def test_get_unit_line():
    unit_lines = gnb.get_unit_lines(chk_adet_output)
    assert unit_lines == [["0x20", "FSM2_FCT", "ready"],
                          ["0x22", "FSM2_FSP1", "ready"]]


def test_get_unit_line_ap():
    unit_lines = gnb.get_unit_lines(chk_adet_output_ap)
    assert unit_lines == [["0x50", "FSM5_FCT", "ready"],
                          ["0x52", "FSM5_FSP1", "ready"],
                          ["0x53", "FSM5_FSP2", "ready"],
                          ["0x54", "FSM5_FSP3", "ready"]]


def test_get_unit_line_asoe():
    unit_lines = gnb.get_unit_lines(chk_adet_output_asoe)
    assert unit_lines == [["0x10", "FSM1_FCT", "ready"]]


def test_get_board_ids_and_status_for_fct():
    board_ids = gnb.get_board_ids_and_status_for('FCT', chk_adet_output)
    assert board_ids == [["0x20", "ready"]]


def test_get_board_ids_and_status_for_ap_fct():
    board_ids = gnb.get_board_ids_and_status_for('FCT', chk_adet_output_ap)
    assert board_ids == [["0x50", "ready"]]


def test_get_board_ids_and_status_for_ap_fsp():
    board_ids = gnb.get_board_ids_and_status_for('FSP', chk_adet_output_ap)
    assert board_ids == [["0x52", "ready"],
                         ["0x53", "ready"],
                         ["0x54", "ready"]]


def test_get_board_ids_and_status_for_asoe_fct():
    board_ids = gnb.get_board_ids_and_status_for('FCT', chk_adet_output_asoe)
    assert board_ids == [["0x10", "ready"]]


def test_get_board_ids_and_status_for_asoe_fsp():
    board_ids = gnb.get_board_ids_and_status_for('FSP', chk_adet_output_asoe)
    assert board_ids == []


def test_get_cpu_status_for_fsp():
    cpu_status = gnb.get_cpu_status_for('FSP', chk_adet_output)
    assert cpu_status == [["0x2230", "ready"],
                          ["0x2240", "ready"],
                          ["0x2250", "ready"]]


def test_get_cpu_status_for_ap_fsp():
    cpu_status = gnb.get_cpu_status_for('FSP', chk_adet_output_ap)
    assert cpu_status == [["0x5230", "ready"],
                          ["0x5240", "ready"],
                          ["0x5250", "ready"],
                          ["0x5330", "ready"],
                          ["0x5340", "ready"],
                          ["0x5350", "ready"],
                          ["0x5430", "ready"],
                          ["0x5440", "ready"],
                          ["0x5450", "ready"]]


def test_get_cpu_status_for_ap_fsp1():
    cpu_status = gnb.get_cpu_status_for('FSP1', chk_adet_output_ap)
    assert cpu_status == [["0x5230", "ready"],
                          ["0x5240", "ready"],
                          ["0x5250", "ready"]]


def test_get_cpu_status_for_ap_fsp2():
    cpu_status = gnb.get_cpu_status_for('FSP2', chk_adet_output_ap)
    assert cpu_status == [["0x5330", "ready"],
                          ["0x5340", "ready"],
                          ["0x5350", "ready"]]


def test_get_cpu_status_for_ap_fax():
    cpu_status = gnb.get_cpu_status_for('FAX', chk_adet_output_ap)
    assert cpu_status == []


def test_check_all_boards_and_cpus_are_ready():
    cpu_lines = gnb.get_cpu_lines(chk_adet_output_ap_ko)
    unit_lines = gnb.get_unit_lines(chk_adet_output_ap_ko)

    with pytest.raises(AssertionError, match=r"Only 9 of 10 items are ready"):
        gnb.check_all_items_ready(cpu_lines)
    with pytest.raises(AssertionError, match=r"Only 2 of 4 items are ready"):
        gnb.check_all_items_ready(unit_lines)
