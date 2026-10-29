# Specific keywords for SFP Monitoring test cases
import ast
from typing import Any

# Whitelist of SFP monitoring parameters that can contain no value or zero value
ALLOWED_ZEROS = ['LCV', 'BER', 'BER_24HR', 'dwdmFirstChannelFreq', 'dwdmFirstChannel', 'dwdmLastChannelFreq ',
                 'dwdmLastChannel', 'dwdmMinGridSpacing', 'dwdmTunedChannel', 'dwdmChannelConfMethod', 'scanningStatus',
                 'frequencyError', 'wavelengthError', 'dwdmFirstChannelWavelength', 'dwdmLastChannelWavelength',
                 'dwdmTuningCap', 'dwdmSelfTuningCap', 'cooledTransceiverDeclaration', 'txPowerHighAlarmThreshold',
                 'rxPowerHighAlarmThreshold']


class SFPMonitoringException(Exception):
    """
    Custom exception for SFP monitoring errors.
    """
    pass


# For source and destinations
def validate_sfp_monitoring_status(sfp_results: dict, radio_type: str, direction: str) -> None:
    """
    Validates the SFP monitoring status for a specific radio type.

    Args:
        sfp_results (dict): A dictionary containing the SFP monitoring results.
        radio_type (str): The product name of the radio type to validate.
        direction (str): The direction of the SFP monitoring ('source' or 'destination').

    Raises:
        SFPMonitoringException: If validation fails.
    """
    radio_found = False

    def validate_parameters(parameters: dict[str, Any], context: str) -> None:
        for param, value in parameters.items():
            if param not in ALLOWED_ZEROS and not _validate_specific_value_by_type(value):
                raise SFPMonitoringException(
                    f'{context}: {param} = {value} is invalid. It should not be zero or empty!'
                )

    for sfp in sfp_results.get('connected', []):
        if sfp.get('source', {}).get('productName') == radio_type:
            radio_found = True

        connector = sfp.get(direction, {}).get('connector', {})
        validate_parameters(connector.get('sfp', {}), f'{direction} SFP')
        validate_parameters(connector.get('linkData', {}), f'{direction} LinkData')

    if not radio_found:
        raise SFPMonitoringException(f'{radio_type} not found in the connected SFPs')


def _validate_specific_value_by_type(value: Any) -> bool:
    """
    Validates the specific value based on its type.

    Args:
        value (Any): The value to validate.

    Returns:
        bool: True if the value is valid, False otherwise.
    """
    if isinstance(value, str):
        try:
            converted = ast.literal_eval(value)
            if isinstance(converted, (int, float)) and converted == 0:
                return False
            if isinstance(converted, list) and not converted:
                return False
        except (ValueError, SyntaxError):
            pass
        return True

    if isinstance(value, (int, float)) and value == 0:
        return False

    if isinstance(value, list) and not value:
        return False

    return True
