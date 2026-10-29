import pytest
from mock import patch
from data import CPNB_0_UES_DATA, CPRT_0_UES_DATA, CPNRT_0_UES_DATA, CPNB_1_UE_DATA, CPRT_1_UE_DATA, CPNRT_1_UE_DATA

with patch('robot.libraries.BuiltIn.BuiltIn'):
    from testsuite.Wroclaw.RRM.VRF_WRO2_T04.HR.resources.keywords_hr import check_cplane_against_hanging_resources

    @pytest.mark.usefixtures('mocks')
    class TestHangingResources:
        @pytest.fixture
        def mocks(self, mocker):
            self.output = mocker.patch(
                'testsuite.Wroclaw.RRM.VRF_WRO2_T04.HR.resources.aashell_commands.execute_aashell_command')

        def test_no_hanging_resources_cpnb(self):
            self.output.side_effect = CPNB_0_UES_DATA, CPRT_0_UES_DATA, CPNRT_0_UES_DATA
            check_cplane_against_hanging_resources()

        def test_fail_when_hanging_resources_on_cpnb(self):
            self.output.side_effect = CPNB_1_UE_DATA, CPRT_0_UES_DATA, CPNRT_0_UES_DATA
            with pytest.raises(AssertionError):
                check_cplane_against_hanging_resources()

        def test_fail_when_hanging_resources_on_cprt(self):
            self.output.side_effect = CPNB_0_UES_DATA, CPRT_1_UE_DATA, CPNRT_0_UES_DATA
            with pytest.raises(AssertionError):
                check_cplane_against_hanging_resources()

        def test_fail_when_hanging_resources_on_cpnrt(self):
            self.output.side_effect = CPNB_0_UES_DATA, CPRT_0_UES_DATA, CPNRT_1_UE_DATA
            with pytest.raises(AssertionError):
                check_cplane_against_hanging_resources()

        def test_fail_when_all_components_contains_hanging_resources(self):
            self.output.side_effect = CPNB_1_UE_DATA, CPRT_1_UE_DATA, CPNRT_1_UE_DATA
            with pytest.raises(AssertionError):
                check_cplane_against_hanging_resources()
