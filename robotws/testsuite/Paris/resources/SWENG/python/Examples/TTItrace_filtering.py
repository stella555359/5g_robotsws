"""
This file gives an example of filtering for event content using TtiTrace
and the TtiAnalysis class.

The used method is ==>    export_specific_parameters

Recall of method arguments:
    path_to_csv: The path to the CSV file to be created.
    parameters: The list of parameters to be exported. They are in the format 'event_name.parameter'
                for the event specific parameters. Common parameters name are the same.
    common_parameters_filter: a dict containing common parameters as keys and for values
                                a list of accepted values.
    specific_parameters_filter: A dict of filters to apply to the dataframe. The parameters names have to be
                    set without the event name as dict keys. The will be filtered for all the dataframe events.
                    Values will be a list of accepted values

The method export the dataframe content of the JSON file to a CSV file applying two filters
(common_parameters_filter and specific_parameters_filter) to the dataframe.
The parameters list gives the columns of the resulting CSV file and dataframe.

Filters are given as dictionaries. The keys are the column names and the values are lists of accepted values.
The values used in the filters can be written simply as string or integer or real values,
The conversion to the dataframe compatible type is transparently done by the method.
Used type can be for example np.int64, np.float64, np.str, etc. depending on the column type.
These types are from the numpy library.
In imput the values can be for example:
    common_parameters_filter = {"slot": [1, 2, 3, 4, 5], "rnti": [65521, 21187] }
    specific_parameters_filter = {"ulPuschReceiveRespPsData.rxPower": [0, -73.4786, -73.4931, -73.4836]}

The method is applied to all the events in the TtiAnalysis object.
The parameters list can contain any of the original columns. Maybe better to include filtered ones.
First of all to check the resulting columns in the CSV file.

Common parameters are choosen from these columns that are the first 6 present in generated dataframe from class
TtiAnalysis:
timeStamp, sfn, slot, rnti, lcrId, physCellId

specific parameters are choosen from alla available columns with name in the format 'event_name.parameter', like:
ulPuschReceiveRespPsData.rxPower

"""

import os
# Reactivate to try, comment to respect PEP8
# import sys

# sys.path.append(os.path.abspath(os.path.join(os.path.dirname(
#     os.path.realpath(__file__)), "..", "TtiTrace")))

# import tti_dataframe
# from TtiAnalysis import TtiAnalysis


def export_specific_parameters_to_csv_and_dataframe(jsonfile="/tmp/TTI_A05_3_Traffic.json"):
    tti_analyzer = TtiAnalysis(jsonfile)
    path_to_csv2, common_parameters_filter, specific_parameters_filter2, parameters2 = setup_parameters()
    # Call the method
    df2 = tti_analyzer.export_specific_parameters(
        path_to_csv2, parameters2, common_parameters_filter, specific_parameters_filter2)
    # Check if the file exists
    file_exists = os.path.exists(path_to_csv2)
    assert file_exists, "File does not exist"


def setup_parameters():
    path_to_csv = '/tmp/TTI_export2.csv'
    common_parameters_filter = {"slot": [1, 2, 3, 4, 5], "rnti": [65521, 21187]}
    specific_parameters_filter = {"ulPuschReceiveRespPsData.rxPower": [0, -73.4786, -73.4931, -73.4836]}
    parameters = ["timeStamp", "sfn", "slot", "rnti", "physCellId", "ulPuschReceiveRespPsData.rxPower"]
    return path_to_csv, common_parameters_filter, specific_parameters_filter, parameters


if __name__ == "__main__":
    export_specific_parameters_to_csv_and_dataframe()
