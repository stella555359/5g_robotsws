from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.scf_verification.scf_verifier import setup_and_check_preconditions_in_scf
from taf.rfrl.ue.logs.tput_logs_collecting import collect_logs_during_data_transfer


def start_max_tput_kpi_logs():
    collect_logs_during_data_transfer()


@logged_keyword
def max_tput_test_setup(used_cell_number, type_of_transfer):
    ports = []
    if used_cell_number == '1':
        ports = [19, 20]
    elif used_cell_number == '2':
        ports = [17, 18]
    elif used_cell_number == '3':
        ports = [21, 22, 23, 24]
    attenuator = Attenuator()
    attenuator.set_attenuation(value_string='90')
    attenuator.set_attenuation(value_string='0', ports=ports)
    attenuator.release_attenuator()
    if type_of_transfer == 'scg':
        setup_and_check_preconditions_in_scf(
            {
                'ulDataPath': 'ulOverNr',
                'dlDataSplitMode': 'dlOverF1U',
            })
    elif type_of_transfer == 'split':
        setup_and_check_preconditions_in_scf(
            {
                'ulDataPath': 'ulOverNr',
                'dlDataSplitMode': 'dlOverF1UX2U',
            })
    blog('Setup finished!')


@logged_keyword
def max_tput_test_teardown():
    attenuator = Attenuator()
    attenuator.set_attenuation(value_string='0')
    attenuator.release_attenuator()
