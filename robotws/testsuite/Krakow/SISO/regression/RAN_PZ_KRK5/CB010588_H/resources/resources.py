from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.commissioning import perform_commissioning_on_gnb_to_onair_state


class BadConfiguration(Exception):
    pass


def perform_setup_reconfiguration(prefix_tag=None):
    perform_commissioning_on_gnb_to_onair_state(prefix_tag=prefix_tag, asir_hub=True)


def verify_is_correct_config_and_change_it_if_needed(correct_config, prefix_tag):
    du_operations = GnbDuOperations()
    bts_info = du_operations.get_bts_info()
    if bts_info["name"] != correct_config:
        perform_setup_reconfiguration(prefix_tag=prefix_tag)
        bts_info = du_operations.get_bts_info()
        if bts_info["name"] != correct_config:
            raise BadConfiguration(f'Wrong configuration detected. Actual Configuration: {bts_info["name"]}, '
                                   f'should be {correct_config}')
    return True


def change_bts_configuration(bts_id=0, prefix_tag=None):
    gnb_du = GnbDuOperations(bts_id=bts_id)
    perform_commissioning_on_gnb_to_onair_state(bts_id=bts_id, asir_hub=True, prefix_tag=prefix_tag)
    gnb_du.wait_for_site_to_be_onair(bts_id=bts_id)
