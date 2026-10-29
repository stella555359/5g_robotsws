from testsuite.Krakow.RRM.RAN_PZ.regression.KRK7.resources.methods import GnbWeb
import variables


def change_ssbFrequencies_by_json(proper=True):
    ssbFrequencies_to_commission = variables.proper_frequencies if proper else variables.improper_frequencies
    GnbWeb().perform_delta_recommissioning(delta_file=ssbFrequencies_to_commission)


def restore_default_nrhoif_events_configuration():
    """
    Restores default HG events configuration.
    Event A4 is enabled only on FR2 NRHOIFs
    Events A3 and A5 are disabled
    """
    GnbWeb().perform_delta_recommissioning(delta_file=variables.default_nrhoif_event_configuration)
