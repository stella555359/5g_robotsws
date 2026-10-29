import logging
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.selenium.sbts.common.exceptions import ParamDoesNotExist
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


class ParameterSelectionError(Exception):
    pass


def verify_smodboardconfigtype_value(smodboardconfigtype_before_update,
                                     smodboardconfigtype_after_update,
                                     dist_name="MRBTS-{}/EQM-1/APEQM-1/CABINET-1/SMOD-1/BBCAP-1",
                                     parameter="SMOD board configuration type"):
    gnb_du = GnbDuOperations()
    gnb_du.connect(force=True)
    gnb_config = GnbCommissioning()
    if gnb_du.get_bts_sw_release_name() in ["SBTS24R3", "SBTS25R1", "SBTS25R2"]:
        gnb_config.verify_parameter_after_change(dist_name=dist_name, parameter=parameter,
                                                 value=smodboardconfigtype_before_update)
    else:
        gnb_config.verify_parameter_after_change(dist_name=dist_name, parameter=parameter,
                                                 value=smodboardconfigtype_after_update)


def verify_smodboardconfigtype_can_be_set_incorrectly(value,
                                                      dist_name="MRBTS-{}/EQM-1/APEQM-1/CABINET-1/SMOD-1/BBCAP-1",
                                                      parameter="SMOD board configuration type"):
    gnb_config = GnbCommissioning()
    try:
        gnb_config.verify_if_parameter_changed_to_incorrect_value_via_gui(dist_name=dist_name,
                                                                          parameter=parameter,
                                                                          value=value)
    except ParamDoesNotExist:
        logging.debug(f"Parameter value '{value}' is not possible to select, as expected.")
        return
    except Exception as e:
        raise ParameterSelectionError(
            f"Parameter value '{value}' should not be possible to select, but it is with some errors. "
            f"Supplementary info: {type(e).__name__}: {str(e)}"
        ) from e
    raise ParameterSelectionError(
        f"Parameter value '{value}' should not be possible to select, but it is."
    )
