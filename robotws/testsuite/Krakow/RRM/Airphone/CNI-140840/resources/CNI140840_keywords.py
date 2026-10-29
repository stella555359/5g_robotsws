"""
:author: Dawid Chuchnowski  <dawid.chuchnowski@nokia.com>
:maintainer: Dawid Chuchnowski <dawid.chuchnowski@nokia.com>
"""
from ast import literal_eval
from robot.api import logger
from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.csv_verifiers import csv_verifiers

cv = csv_verifiers()


def verify_that_only_invalid_measurements_are_reported(csv_file_path, num_of_cells):
    """
    Verifies in TTI traces that ulPuschReceiveRespPsData.dbmNoiseOfAnt and ulPuschReceiveRespPsData.dbmRssiOfAnt
    contain only invalid values -140 for all cells
    :param csv_file_path: path to tti traces csv file
    :param num_of_cells: number of cells to be verified, starting form cell no.1
    """
    tti_list = cv.create_list_of_lists_from_csv(csv_file_path)
    tti_fake_ues = cv.filter_csv_by_column_value(csv_list=tti_list,
                                                 column_name='ulPuschReceiveRespPsData.isFakeUe',
                                                 condition='==',
                                                 value=1)
    for cell in range(1, int(num_of_cells) + 1):
        tti_cell = cv.filter_csv_by_column_value(csv_list=tti_fake_ues,
                                                 column_name='lcrId',
                                                 condition='==',
                                                 value=cell)
        cell_noise_values = cv.get_column_values(input_list=tti_cell,
                                                 column_name='ulPuschReceiveRespPsData.dbmNoiseOfAnt',
                                                 unique_values=True)
        cell_rssi_values = cv.get_column_values(input_list=tti_cell,
                                                column_name='ulPuschReceiveRespPsData.dbmRssiOfAnt',
                                                unique_values=True)
        unique_noise_values = set(literal_eval(cell_noise_values[0]))
        unique_rssi_values = set(literal_eval(cell_rssi_values[0]))
        logger.info(f"Cell-{cell} dbmNoiseOfAnt: {cell_noise_values}")
        logger.info(f"Cell-{cell} dbmRssiOfAnt: {cell_rssi_values}")
        assert unique_noise_values == {-140}, f"Cell {cell} contains unexpected valid noise measurements"
        assert unique_rssi_values == {-140}, f"Cell {cell} contains unexpected valid RSSI measurements"
