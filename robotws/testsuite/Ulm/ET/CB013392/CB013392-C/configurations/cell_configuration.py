import os
import logging

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.CB013392.libraries.cell_freq_modifier import CellFrequencyModifier


# ====================================================================================================[120 characters]
#   Feature Specific Functions changing the Cell Configuration
# ====================================================================================================[120 characters]

@log_begin_end_func_name
def change_cell_settings_for_TMO(band_of_cell_12='n77'):
    cell_configuration_json_filepath = os.sep.join(__file__.split(os.sep)[:-1]) + '/cell_configuration.json'
    logging.info('cell_configuration_json_filepath = %s' % cell_configuration_json_filepath)
    cell_modifier = CellFrequencyModifier(cell_configuration_json_filepath)
    cell_modifier.modify_cell('n41', 11)
    cell_modifier.modify_cell(band_of_cell_12, 12)
    cell_modifier.execute_modifications()


@log_begin_end_func_name
def change_cell_settings_for_AEQE():
    cell_configuration_json_filepath = os.sep.join(__file__.split(os.sep)[:-1]) + '/cell_configuration_AEQE.json'
    logging.info('cell_configuration_json_filepath = %s' % cell_configuration_json_filepath)
    cell_modifier = CellFrequencyModifier(cell_configuration_json_filepath)
    cell_modifier.modify_cell('n78', 2)
    cell_modifier.execute_modifications()
