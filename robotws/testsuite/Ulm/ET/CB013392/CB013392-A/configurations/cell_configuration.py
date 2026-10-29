import os
import logging

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.CB013392.libraries.cell_freq_modifier import CellFrequencyModifier


# ====================================================================================================[120 characters]
#   Feature Specific Functions changing the Cell Configuration
# ====================================================================================================[120 characters]

@log_begin_end_func_name
def change_cell_settings_for_CB013392_A_B3():
    cell_configuration_json_filepath = os.sep.join(__file__.split(os.sep)[:-1]) + '/cell_configuration.json'
    logging.info('cell_configuration_json_filepath = %s' % cell_configuration_json_filepath)
    cell_modifier = CellFrequencyModifier(cell_configuration_json_filepath)
    cell_modifier.modify_cell('n78', 12)
    cell_modifier.execute_modifications()
