
from testsuite.Ulm.ET.Performance_Test.resources.test.testmock.ute_wtssim import UteWtsSimMock


class TafSwWtssimWrapperMock():
    """until we set up unit test, this will do
    """

    def __init__(self):
        pass

    def execute_egate_command_and_wait_for_data(self, cmd, *_, **kwargs):
        return self._intercept_returns(cmd, **kwargs)

    def execute_egate_command(self, cmd, *_, **kwargs):
        return self._intercept_returns(cmd, **kwargs)

    def _intercept_returns(self, cmd, **kwargs):
        if "ue_summary" in cmd:
            test_pc_index = int(kwargs.get('test_pc_index', 0))
            if test_pc_index == 0:
                UE_COUNT = 1
                CELL_NUMBER = 1
                return UteWtsSimMock.generate_ue_summary(active=1,
                                                         cells=[
                                                             (CELL_NUMBER,
                                                              UE_COUNT)
                                                         ])
            if test_pc_index == 1:
                UE_COUNT = 2
                CELL_NUMBER = 2
                return UteWtsSimMock.generate_ue_summary(active=2,
                                                         cells=[
                                                             (CELL_NUMBER,
                                                              UE_COUNT)
                                                         ])
            if test_pc_index == 2:
                UE_COUNT = 3
                CELL_NUMBER = 3
                return UteWtsSimMock.generate_ue_summary(active=3,
                                                         cells=[
                                                             (CELL_NUMBER,
                                                              UE_COUNT)
                                                         ])
        return cmd
