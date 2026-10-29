import pytest
import pandas as pd
from .GetFiles import download_package_using_git
# Reactivate to perform pytests, comment to respect PEP8

# import sys
# import os
# sys.path.append(os.path.abspath(os.path.join(os.path.dirname(
#     os.path.realpath(__file__)), "..", "TtiTrace")))

# from MultipleTtiAnalysis import MultipleTtiAnalysis


class Test_MultiTtiAnalysis:
    def setup_method(self, method):
        print(f"\nSetting up for test: {method.__name__}")
        download_package_using_git('gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git',
                                   'SWENG/Test_files', 'TTI_A05_3_Traffic.json',
                                   'NpsVrfToken', 'glpat-4yNB_jaBXxz_BsyeAsgL')
        # Initialize a MultipleTtiAnalysis object
        json_file = "Traces/TTI_A05_3_Traffic.json"
        self.tti_events_list = ['utcTimeStampData', 'dlMetricIndData', 'dlAllocatedPooledResourcesData',
                                'dlFdSchedData']
        self.multiple_tti_analysis = MultipleTtiAnalysis(json_file, self.tti_events_list)

    def test_verify_distribution_table_of(self):
        # Define the event, method name, and parameters
        event = "dlMetricIndData"
        method_name = "verify_distribution_table_of"
        column_name = "sfn"
        parameters = [column_name, None, None, True]

        # Apply the method to the event
        result = self.multiple_tti_analysis.apply_analyzer_method_to_event(event, method_name, parameters)

        # Assert the expected behavior
        for tti in self.tti_events_list:
            assert hasattr(self.multiple_tti_analysis.analysis_dict[tti], 'events_list')

        # Check that the result is a DataFrame
        assert isinstance(result, pd.DataFrame)

        # Check that the DataFrame has the expected columns
        expected_columns = ['Count', 'Percentage']
        assert set(result.columns) == set(expected_columns)

    def test_check_value_inrange_for_column(self):
        # Define the event, method name, and parameters
        event_list = ["dlMetricIndData", "dlAllocatedPooledResourcesData", "dlFdSchedData"]
        method_name = "check_value_inrange_for_column"
        column_name = "numOfPrb"
        range_to_check = [(16, 273)]
        parameters = [column_name, range_to_check]
        # if present in parameter list set its index here!
        column_name_index = 0
        # Apply the method to the event
        result = self.multiple_tti_analysis.apply_analyzer_method_to_event_list(event_list, method_name, parameters,
                                                                                column_name_index)

        # Assert the expected behavior
        for tti in self.tti_events_list:
            assert hasattr(self.multiple_tti_analysis.analysis_dict[tti], 'events_list')

        # Check that the result is a boolean
        assert isinstance(result, list)
        assert all(isinstance(elem, bool) for elem in result)

    def test_save_tocsv_for_all_events(self):
        self.multiple_tti_analysis.save_tocsv_for_all_events()
        for tti in self.tti_events_list:
            assert os.path.exists(f"TTI_{tti}.csv")
        for tti in self.tti_events_list:
            os.remove(f"TTI_{tti}.csv")
        for tti in self.tti_events_list:
            assert not os.path.exists(f"TTI_{tti}.csv")

    def test_save_tojson_for_all_events(self):
        self.multiple_tti_analysis.save_tojson_for_all_events()
        for tti in self.tti_events_list:
            assert os.path.exists(f"TTI_{tti}.json")
        for tti in self.tti_events_list:
            os.remove(f"TTI_{tti}.json")
        for tti in self.tti_events_list:
            assert not os.path.exists(f"TTI_{tti}.json")
