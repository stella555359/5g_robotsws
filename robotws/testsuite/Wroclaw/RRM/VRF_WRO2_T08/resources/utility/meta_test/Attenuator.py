from ta_attenuator import ta_attenuator

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration
from .robot_library import RobotLibrary
from .teardown import Teardown

_teardown = Teardown


class Attenuator(ta_attenuator, RobotLibrary):
    def __init__(self):
        if self._library_initiation_guard():
            return
        super().__init__()
        self.cells = []

    def load_attenuation_config(self, ta_attenuator_config=None):
        super().load_attenuation_config(TestlineConfiguration(yaml_conf=ta_attenuator_config).yaml_path)
        self.cells = self.cells_pool.registered_names
        self.require_attenuator_setup_of(self.cells)
        _teardown.schedule_suite_teardown_function('Teardown attenuator', self.release_attenuator_cell, [self.cells])

    def teardown_attenuator(self):
        self.release_attenuator_cell(self.cells)
        _teardown.recall_suite_teardown_function('Teardown attenuator')

    def force_cell(self, cell_name, attenuation='0dB'):
        self.set_maximum_attenuation_for_all_cells_of_testline()
        self.set_attenuation(cell_alias=cell_name, attenuation_value=attenuation)
