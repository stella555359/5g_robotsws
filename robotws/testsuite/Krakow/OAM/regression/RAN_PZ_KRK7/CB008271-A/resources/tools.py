from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations


def check_all_hubmods_status(operationalState,
                             commissioned,
                             localState,
                             hardwareState,
                             softwareState,
                             activeStatusLEDColor,
                             faultStatusLEDColor,
                             powerStatusLEDColor):
    asirOperations = GnbAsirHubOperations()
    expected_stat = {'operationalState': operationalState,
                     'commissioned': commissioned,
                     'localState': localState,
                     'hardwareState': hardwareState,
                     'softwareState': softwareState,
                     'activeStatusLEDColor': activeStatusLEDColor,
                     'faultStatusLEDColor': faultStatusLEDColor,
                     'powerStatusLEDColor': powerStatusLEDColor}
    asirOperations.verify_status_of_all_hubmods(expected_statuses=expected_stat)
