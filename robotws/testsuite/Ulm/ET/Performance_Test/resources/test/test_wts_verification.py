

import mock  # pylint: disable=locally-disabled, E0401
from testsuite.Ulm.ET.Performance_Test.resources.python import wts_verification


def test_verify_number_of_active_ues_in_cells():
    ret_val = """=====================================================
    Parameter                Simulated  External  Total
    -----------------------------------------------------
    Configured               6000       0         6000
    -----------------------------------------------------
    Active                   64         0         64
    ENB-2                 64         0         64
        Cell-1             16         -
        Cell-2             16         -
        Cell-3             16         -
        Cell-4             16         -
    -----------------------------------------------------
    Active (Time Aligned)    64         -
    ENB-2                 64         -
        Cell-1             16         -
        Cell-2             16         -
        Cell-3             16         -

        Cell-4             16         -

    -----------------------------------------------------
    Active (Time Unaligned)  0          -
    =====================================================
    Idle                     0          0         0
    InActive                 0          0         0
    ====================================================="""
    with mock.patch('testsuite.Ulm.ET.Performance_Test.resources.python.wts_manager.send_command_to_egate',
                    return_value=ret_val):
        assert wts_verification.verify_number_of_active_ues_in_cells(
            16, 4, cell_max_ue=['null'], active_cells=['all'])
