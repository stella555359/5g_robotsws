import os
import sys

# Add TtiTrace to path for local module imports
# (must be before importing tti_dataframe)
sys.path.insert(0, os.path.abspath(os.path.join(
    os.path.dirname(os.path.realpath(__file__)),
    "..", "TtiTrace")))

import pandas as pd  # noqa: E402
import pytest  # noqa: E402
import subprocess  # noqa: E402
import shutil  # noqa: E402

import tti_dataframe  # noqa: E402
from TtiAnalysis import TtiAnalysis  # noqa: E402
from .GetFiles import download_package_using_git  # noqa: E402


@pytest.fixture
def setup_parameters():
    path_to_csv = '/tmp/TTI_export.csv'
    common_parameters_filter = {
        "slot": [1, 2, 3, 4, 5],
        "rnti": [65521, 21187]
    }
    specific_parameters_filter = {
        "dlFdSchedData.numOfPrb": [273, 274]
    }
    parameters = [
        "timeStamp", "sfn", "slot", "rnti",
        "physCellId", "dlFdSchedData.numOfPrb"
    ]
    return (
        path_to_csv, common_parameters_filter,
        specific_parameters_filter, parameters
    )


@pytest.fixture
def setup_parameters2():
    path_to_csv = '/tmp/TTI_export2.csv'
    common_parameters_filter = {
        "slot": [1, 2, 3, 4, 5],
        "rnti": [65521, 21187]
    }
    specific_parameters_filter = {
        "ulPuschReceiveRespPsData.rxPower": [
            0, -73.4786, -73.4931, -73.4836
        ]
    }
    parameters = [
        "timeStamp", "sfn", "slot", "rnti",
        "physCellId", "ulPuschReceiveRespPsData.rxPower"
    ]
    return (
        path_to_csv, common_parameters_filter,
        specific_parameters_filter, parameters
    )


@pytest.fixture
def setup_parameters3():
    path_to_csv = '/tmp/TTI_export3.csv'
    common_parameters_filter = {"sfn": [117, 623], "rnti": [0]}
    specific_parameters_filter = {
        "dlPdcchDciData.ueDciInfoList": None
    }
    parameters = [
        "timeStamp", "sfn", "slot", "rnti",
        "physCellId", "dlPdcchDciData.ueDciInfoList"
    ]
    return (
        path_to_csv, common_parameters_filter,
        parameters, specific_parameters_filter
    )


@pytest.fixture
def setup_parameters4():
    path_to_csv = '/tmp/TTI_export4.csv'
    common_parameters_filter = {"sfn": [117, 623], "rnti": [0]}
    specific_parameters_filter = {
        "dlPdcchDciData.ueDciInfoList": {'rnti': [27126]}
    }
    parameters = [
        "timeStamp", "sfn", "slot", "rnti",
        "physCellId", "dlPdcchDciData.ueDciInfoList"
    ]
    return (
        path_to_csv, common_parameters_filter,
        parameters, specific_parameters_filter
    )


class Test_TtiAnalysis:
    def setup_method(self, method):
        target_dir = 'Traces'
        git_repo = 'gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git'
        git_dir = 'SWENG/Test_files'
        token_name = 'NpsVrfToken'
        token_val = 'glpat-4yNB_jaBXxz_BsyeAsgL'

        def download_if_not_exists(
            repo_url, directory, filename,
            token_name_arg, token_value_arg
        ):
            file_path = os.path.join(target_dir, filename)
            if not os.path.exists(file_path):
                download_package_using_git(
                    repo_url, directory, filename,
                    token_name_arg, token_value_arg,
                    target_dir=target_dir
                )
            else:
                print(
                    f"File {filename} already exists "
                    f"in {directory}."
                )
        print(f"\nSetting up for test: {method.__name__}")
        download_if_not_exists(
            git_repo, git_dir,
            'TTI_A05_3_Traffic.json',
            token_name, token_val
        )
        download_if_not_exists(
            git_repo, git_dir,
            'TTI_B8_noDummy1.json',
            token_name, token_val
        )
        download_if_not_exists(
            git_repo, git_dir,
            'TTI_traffic2_filtered.json',
            token_name, token_val
        )
        self.jsonfile = "Traces/TTI_A05_3_Traffic.json"
        self.jsonfile2 = "Traces/TTI_B8_noDummy1.json"
        self.jsonfile3 = "Traces/TTI_traffic2_filtered.json"
        self.tti_analyzer = TtiAnalysis(self.jsonfile)
        self.df = self.tti_analyzer.df

    def test_convert_json_tti_trace_to_df(self):
        events = [
            'utcTimeStampData', 'dlMetricIndData',
            'dlAllocatedPooledResourcesData', 'dlFdSchedData'
        ]
        self.tti_analyzer = TtiAnalysis(self.jsonfile, events)
        self.tti_analyzer._load_dataframe()
        assert self.tti_analyzer.df is not None
        assert len(self.tti_analyzer.df) > 0
        assert isinstance(self.tti_analyzer.df, pd.DataFrame)
        pd.set_option('display.max_columns', None)  # None means unlimited.

    def test_verify_distribution_table_of(self):
        # add parameter plot='Scatter' to get a scatter plot
        # add parameter plot='Bar' to get a bar plot
        result = self.tti_analyzer.verify_distribution_table_of(
            'dlFdSchedData.macCe.brsBeamChange', need_return=True)
        assert result is not None
        assert len(result) > 0
        print(type(result))
        print(f"Result: {result}")
        assert result['Count'].sum() == 5640

    def test_verify_distribution_table_htmlfile(self):
        try:
            os.remove(
                'Traces/dlFdSchedData_effectiveCodeRate_'
                'distribution_table.html'
            )
        except Exception:
            print("File not there, not removed")
        result = self.tti_analyzer.verify_distribution_table_of(
            'dlFdSchedData.effectiveCodeRate',
            need_return=True, plot='Scatter')
        assert result is not None
        html_file = (
            'Traces/dlFdSchedData_effectiveCodeRate_'
            'distribution_table.html'
        )
        assert os.path.exists(html_file)

    def test_verify_distribution_table2_htmlfile(self):
        try:
            os.remove('Traces/dlFdSchedData_numOfPrb_bar_graph.html')
        except Exception:
            print("File not there, not removed")
        result = self.tti_analyzer.verify_distribution_table_of(
            'dlFdSchedData.numOfPrb', need_return=True, plot='Bar')
        assert result is not None
        assert os.path.exists('Traces/dlFdSchedData_numOfPrb_bar_graph.html')

    def test_check_min_for_column(self):
        col_name = 'dlFdSchedData.numOfPrb'
        result = self.tti_analyzer.check_min_for_column(col_name)
        assert result is not None
        print(type(result))
        print(f"Result: {result}")
        assert result == 16.0

    def test_check_max_for_column(self):
        col_name = 'dlFdSchedData.numOfPrb'
        result = self.tti_analyzer.check_max_for_column(col_name)
        assert result is not None
        print(type(result))
        print(f"Result: {result}")
        assert result == 273.0

    def test_get_columns_with_same_values(self):
        result = self.tti_analyzer.get_columns_with_same_values()
        assert isinstance(result, list)
        print(f"Result: {result}")

    def test_get_columns_with_long_names(self):
        result = self.tti_analyzer.get_columns_with_long_names()
        assert isinstance(result, list)
        print(f"Result: {result}")

    def test_check_unique_value_for_column(self):
        events_list = [
            'utcTimeStampData', 'dlMetricIndData',
            'dlAllocatedPooledResourcesData', 'dlFdSchedData'
        ]
        self.tti_analyzer = TtiAnalysis(self.jsonfile, events_list)
        col_name = 'dlFdSchedData.cqiPdcchOffset'
        result, value = self.tti_analyzer.check_unique_value_for_column(
            col_name)
        assert result
        print(type(value))
        print(f"Result: {result}, with value: {value}")
        assert value == 0.0

    def test_check_unique_value_for_column2(self):
        events_list = [
            'utcTimeStampData', 'dlMetricIndData',
            'dlAllocatedPooledResourcesData', 'dlFdSchedData'
        ]
        self.tti_analyzer = TtiAnalysis(self.jsonfile, events_list)
        col_name = 'dlFdSchedData.streamConfig.patternId1'
        result, value = self.tti_analyzer.check_unique_value_for_column(
            col_name)
        assert result
        print(type(value))
        print(f"Result: {result}, with value: {value}")
        assert value == 6.0

    def test_get_values_list(self):
        col_name = 'dlFdSchedData.requiredPrbForMuAwareTdSch'
        val_list = self.tti_analyzer.get_column_values(col_name)
        print(f"Retrieved {len(val_list)} values in list")
        assert isinstance(val_list, list)
        assert len(val_list) > 0

    def test_get_first_column_value(self):
        col_name = 'dlFdSchedData.streamConfig.patternId1'
        index, val = self.tti_analyzer.get_first_column_value(col_name)
        print(f"Index: {index}, Value: {val}")
        assert isinstance(val, float)
        assert val == 6.0

    def test_get_columns_names_containing_substring(self):
        substring = 'macCe'
        result = self.tti_analyzer.get_columns_names_containing_substring(
            substring)
        print(f"Columns containing substring are:\n{result}")
        assert isinstance(result, list)
        assert len(result) == 8

    def test_check_substrings_in_columns(self):
        self.tti_analyzer = TtiAnalysis(self.jsonfile, ['dlFdSchedData'])
        substrings = [
            "antPort", "dmrsConfigType", "numCdmGroupNoData",
            "antennaPortValue"
        ]
        result = self.tti_analyzer.check_substrings_in_columns(
            substrings)
        assert isinstance(result, dict)
        print(f"Result:\n{result}")

    def test_check_multi_columns_values(self):
        my_dict = {
            'dlFdSchedData.macCe.cqiPdcchOffset': 0.0,
            'dlFdSchedData.streamConfig.patternId1': 6.0
        }
        result = self.tti_analyzer.check_multi_columns_values(my_dict)
        assert result
        print(f"Result: {result}")

    def test_check_value_inrange_for_column(self):
        self.tti_analyzer = TtiAnalysis(self.jsonfile, ['dlFdSchedData'])
        col_name = 'dlFdSchedData.numOfPrb'
        result = self.tti_analyzer.check_value_inrange_for_column(
            col_name, (16, 273))
        assert result
        print(f"Result: {result}")

    def test_check_value_inrange_for_column2(self):
        self.tti_analyzer = TtiAnalysis(self.jsonfile, ['dlFdSchedData'])
        col_name = 'dlFdSchedData.numOfPrb'
        result = self.tti_analyzer.check_value_inrange_for_column(
            col_name, (16, 272))
        assert not result
        print(f"Result: {result}")

    def test_check_value_inrange_for_column3(self):
        self.tti_analyzer = TtiAnalysis(self.jsonfile, ['dlFdSchedData'])
        col_name = 'dlFdSchedData.numOfPrb'
        with pytest.raises(ValueError):
            self.tti_analyzer.check_value_inrange_for_column(
                col_name, (299, 274))
        print("ValueError raised as expected")

    def test_check_value_inrange_for_column_dict(self):
        self.tti_analyzer = TtiAnalysis(self.jsonfile, ['dlFdSchedData'])
        my_dict = {
            'dlFdSchedData.numOfPrb': (16, 273),
            'dlFdSchedData.requiredPrbForMuAwareTdSch': (0, 1)
        }
        result = self.tti_analyzer.check_value_inrange_for_column_dict(my_dict)
        assert result
        print(f"Result: {result}")

    def test_check_value_inrange_for_column_dict2(self):
        self.tti_analyzer = TtiAnalysis(self.jsonfile, ['dlFdSchedData'])
        my_dict = {
            'dlFdSchedData.numOfPrb': (16, 22),
            'dlFdSchedData.requiredPrbForMuAwareTdSch': (0, 1)
        }
        result = self.tti_analyzer.check_value_inrange_for_column_dict(my_dict)
        assert not result
        print(f"Result: {result}")

    def test_check_value_inrange_for_column_dict3(self):
        self.tti_analyzer = TtiAnalysis(self.jsonfile, ['dlFdSchedData'])
        my_dict = {
            'dlFdSchedData.numOfPrb': (16, 2),
            'dlFdSchedData.requiredPrbForMuAwareTdSch': (0, 1)
        }
        with pytest.raises(ValueError):
            self.tti_analyzer.check_value_inrange_for_column_dict(my_dict)
        print("ValueError raised as expected")

    def test_get_list_from_dataframe_column(self):
        col_name = 'dlFdSchedData.nbrLchIdAndTokenBucketInBytesPerSlot'
        result, res_size = self.tti_analyzer.get_list_from_dataframe_column(
            col_name)
        msg = (
            f"Result first value: {result[0]}\n"
            f"Result list of lists has size: {res_size}"
        )
        print(msg)
        assert isinstance(result, list)
        assert isinstance(result[0], list)
        assert res_size == 5640

    def test_get_first_list_of_dict_value_from_dataframe_column(self):
        col_name = 'dlFdSchedData.scheduledBearers'
        result = (
            self.tti_analyzer
            .get_first_list_of_dict_value_from_dataframe_column(col_name)
        )
        print(f"Result: {result}")
        assert isinstance(result, pd.DataFrame)

    def test_export_dataframe_to_csv(self):
        csv_file = 'Traces/TTI_A05_3_Traffic.csv'
        self.tti_analyzer.export_dataframe_to_csv(csv_file)
        assert os.path.exists(csv_file)
        os.remove(csv_file)
        assert not os.path.exists(csv_file)

    def test_export_specific_parameters_to_csv_and_dataframe(
        self, setup_parameters
    ):
        (
            path_to_csv1, common_parameters_filter,
            specific_parameters_filter1, parameters1
        ) = setup_parameters
        # Call the method
        df1 = self.tti_analyzer.export_specific_parameters(
            path_to_csv1, parameters1, common_parameters_filter,
            specific_parameters_filter1)
        print(f"df1: {df1}")
        # Check if the file exists
        file_exists = os.path.exists(path_to_csv1)
        assert file_exists, "File does not exist"

    def test_export_specific_parameters_to_csv_and_dataframe2(
        self, setup_parameters2
    ):
        (
            path_to_csv2, common_parameters_filter,
            specific_parameters_filter2, parameters2
        ) = setup_parameters2
        # Call the method
        df2 = self.tti_analyzer.export_specific_parameters(
            path_to_csv2, parameters2, common_parameters_filter,
            specific_parameters_filter2)
        print(f"df2: {df2}")
        # Check if the file exists
        file_exists = os.path.exists(path_to_csv2)
        assert file_exists, "File does not exist"

    def test_export_specific_parameters_to_csv_and_dataframe3(
        self, setup_parameters3
    ):
        self.tti_analyzer = TtiAnalysis(self.jsonfile3, ['dlPdcchDciData'])
        (
            path_to_csv3, common_parameters_filter,
            parameters3, specific_parameters_filter3
        ) = setup_parameters3
        df3 = self.tti_analyzer.export_specific_parameters(
            path_to_csv3, parameters3, common_parameters_filter,
            specific_parameters_filter3, False)
        print(f"df3: {df3}")
        # Check if the file exists
        file_exists = os.path.exists(path_to_csv3)
        assert file_exists, "File does not exist"

    def test_export_specific_parameters_to_csv_and_dataframe4(
        self, setup_parameters4
    ):
        self.tti_analyzer = TtiAnalysis(self.jsonfile3, ['dlPdcchDciData'])
        (
            path_to_csv4, common_parameters_filter,
            parameters4, specific_parameters_filter4
        ) = setup_parameters4
        df4 = self.tti_analyzer.export_specific_parameters(
            path_to_csv4, parameters4, common_parameters_filter,
            specific_parameters_filter4, False)
        print(f"df4: {df4}")
        # Check if the file exists
        file_exists = os.path.exists(path_to_csv4)
        assert file_exists, "File does not exist"
