"""
:copyright: Nokia Networks
:authors:
    Michał Obszarny <michal.obszarny@nokia.com>
    Łukasz Gdowski <lukasz.gdowski@nokia.com>
:maintainers:
    Michał Obszarny <michal.obszarny@nokia.com>
    Łukasz Gdowski <lukasz.gdowski@nokia.com>
"""
import csv
import logging
from robot.libraries.BuiltIn import BuiltIn


def _create_list_from_tti_trace_csv(direction, directory=None):
    direction = direction.lower()
    if directory is None:
        directory = BuiltIn().get_variable_value("${parent_directory}")
    csv_path = "/".join([BuiltIn().get_variable_value("${OUTPUTDIR}"),
                         BuiltIn().get_variable_value("${TESTNAME}"),
                         directory,
                         "output_{}.csv".format(direction)])
    logging.info("csv path is {}".format(csv_path))
    tti_trace_ul = open(csv_path)
    csv_list = list(csv.reader(tti_trace_ul))
    return csv_list


def _create_list_from_column(tti_trace_list, column_name):
    try:
        sr_column_index = tti_trace_list[0].index(column_name)
    except ValueError:
        raise ValueError("No such column {} in tti traces. Available columns are {}".format(column_name,
                                                                                            tti_trace_list[0]))
    list_from_single_column = [row[sr_column_index] for row in tti_trace_list[1:]]
    return list_from_single_column


def _filter_tti_traces_by_column_and_value(tti_data, column, value):
    column_index = tti_data[0].index(column)
    header = tti_data[0]
    content = tti_data[1:]
    tti_traces_filtered = [header] + [row for row in content if row[column_index] == value]
    return tti_traces_filtered


def _filter_out_tti_traces_with_value(tti_data, column, value):
    column_index = tti_data[0].index(column)
    header = tti_data[0]
    content = tti_data[1:]
    tti_traces_filtered = [header] + [row for row in content if row[column_index] != value]
    return tti_traces_filtered


def _filter_out_tti_traces_with_different_values_than(tti_data, column, values):
    column_index = tti_data[0].index(column)
    header = tti_data[0]
    content = tti_data[1:]
    tti_traces_filtered = [header] + [row for row in content if row[column_index] in values]
    return tti_traces_filtered


def _get_csi_report_dtx_ratio(tti_data):
    column_index = tti_data[0].index('csiSrReportData.dtx')
    content = tti_data[1:]
    tti_traces_filtered = [row for row in content if row[column_index] == 'DTX']
    dtx_ratio = round(float(len(tti_traces_filtered)) * 100 / len(content), 2)
    logging.debug("{} CSI reports. {} reports with DTX".format(len(content), len(tti_traces_filtered)))
    logging.debug("DTX ratio is {}".format(dtx_ratio))
    return dtx_ratio


def verify_csi_reports_dtx_ratio(phys_cells_ids, accepted_ratio):
    """
    Verifies if there is not too many DTX while sending CSI reports
    :param phys_cells_ids: physical id of cells, separated by comma, like: 51,52,53
    :param accepted_ratio: dtx ratio that is acceptable
    :return:
    """
    accepted_ratio = float(accepted_ratio)
    cells = phys_cells_ids.split(',')
    tti_data = _create_list_from_tti_trace_csv('dl')
    csi_tti_traces = _filter_tti_traces_by_column_and_value(tti_data,
                                                            column='csiSrReportData.reportType',
                                                            value='PERIODIC_CSI')
    for cell in cells:
        csi_reports_on_cell = _filter_tti_traces_by_column_and_value(csi_tti_traces, column='physCellId', value=cell)
        dtx_ratio = _get_csi_report_dtx_ratio(csi_reports_on_cell)
        assert dtx_ratio <= accepted_ratio, \
            "DTX ratio on cell {} for CSI reports is to high. Expected below {}, got {}".format(cell,
                                                                                                accepted_ratio,
                                                                                                dtx_ratio)


def verify_if_ue_performs_csi_measurement_reports_on_all_carriers(phys_cells_ids):
    """
    Verifies if UE performs CSI measurement reports on all carriers
    :param phys_cells_ids: physical id of cells
    """
    cells_ids = set(phys_cells_ids.split(','))
    tti_data = _create_list_from_tti_trace_csv('dl')
    csi_tti_traces = _filter_tti_traces_by_column_and_value(tti_data,
                                                            column='csiSrReportData.reportType',
                                                            value='PERIODIC_CSI')
    column_values = _create_list_from_column(csi_tti_traces, column_name='physCellId')
    csi_reports_cells = set(column_values)
    assert csi_reports_cells.intersection(cells_ids), \
        "Reports are sent for cells {} instead of {}".format(csi_reports_cells, cells_ids)


def _verify_correct_currentbestbeamid_was_selected(tti_data, expected_currentbetbeamid_value, cell_id):
    tti_for_cell = _filter_tti_traces_by_column_and_value(tti_data, column='physCellId', value=cell_id)
    tti_with_beam_data_for_cell = _filter_out_tti_traces_with_value(tti_for_cell,
                                                                    column='dlBeamData.currentBestBeamId',
                                                                    value="")
    list_of_beam_reports = _create_list_from_column(tti_with_beam_data_for_cell,
                                                    column_name='dlBeamData.currentBestBeamId')
    logging.debug("Measured value is : {}".format(set(list_of_beam_reports)))
    assert set(list_of_beam_reports) == {expected_currentbetbeamid_value}


def verify_that_beam_reports_are_sent_for_cell(cell_id):
    """
    Verify that beam reports are sent for cell
    :param cell_id: physical id of SCell
    """
    expected_best_beam_id = "0.0"
    tti_data = _create_list_from_tti_trace_csv('dl')
    _verify_correct_currentbestbeamid_was_selected(tti_data, expected_best_beam_id, cell_id)


def verify_if_beam_has_changed(directory):
    """
    Verify if beam has changed. Default best beam id is 0.0 so this method checks if it has changed to 1.0
    """
    selected_best_beam_id = "1.0"
    tti_data = _create_list_from_tti_trace_csv('dl', directory=directory)
    tti_traces_BestBeamId = _filter_out_tti_traces_with_value(tti_data,
                                                              column='dlBeamData.selectedBestBeamId',
                                                              value='')
    tti_traces_2ndBeamId = _filter_out_tti_traces_with_value(tti_data,
                                                             column='dlBeamData.selected2ndBeamId',
                                                             value='')
    tti_traces_BestBeamId = _create_list_from_column(tti_traces_BestBeamId,
                                                     column_name='dlBeamData.selectedBestBeamId')
    tti_traces_2ndBeamId = _create_list_from_column(tti_traces_2ndBeamId,
                                                    column_name='dlBeamData.selected2ndBeamId')
    logging.debug("selectedBestBeamId = 1.0 : {}".format(tti_traces_BestBeamId.count("1.0")))
    logging.debug("selected2ndBeamId = 1.0 : {}".format(tti_traces_2ndBeamId.count("1.0")))
    logging.debug("selectedBestBeamId lenght : {}".format(len(tti_traces_BestBeamId)))
    assert tti_traces_BestBeamId != tti_traces_2ndBeamId and \
           tti_traces_BestBeamId.count("1.0") + tti_traces_2ndBeamId.count("1.0") == len(tti_traces_BestBeamId), \
           "Beam has not changed. Got beam lists {},{}, expected {}".format(tti_traces_BestBeamId,
                                                                            tti_traces_2ndBeamId,
                                                                            selected_best_beam_id)


def verify_if_csi_rs_is_present_after_scell_activation(expected_csi_rs_config, cell_id, directory):
    """
    Verify CSI-RS are present after Scell activation
    :param expected_csi_rs_config: expected value of csiRsConfig for SCell
    :param cell_id: physical id of SCell
    """
    tti_data = _create_list_from_tti_trace_csv('dl', directory=directory)
    tti_for_cell = _filter_tti_traces_by_column_and_value(tti_data, column='physCellId', value=cell_id)
    tti_for_cell_without_blanks = _filter_out_tti_traces_with_value(tti_for_cell,
                                                                    column='csiRsSchedData.csiRsConfig',
                                                                    value="")
    tti_for_cell_without_rnti0 = _filter_out_tti_traces_with_value(tti_for_cell_without_blanks,
                                                                   column='rnti',
                                                                   value="0")
    csi_rs_values = _create_list_from_column(tti_for_cell_without_rnti0, column_name='csiRsSchedData.csiRsConfig')
    logging.debug("final list")
    logging.debug("All used selectedBestBeamId values: {}".format(csi_rs_values))
    assert set(csi_rs_values) == {expected_csi_rs_config}, \
        "csiRsConfig on scells is {} instead of expected {}".format(csi_rs_values, expected_csi_rs_config)


def Verify_if_pCSI_and_beam_report_are_reported_in_a_bundle_for_TDD_scell(cell_id, directory):
    """
    Verify if pCSI for channel acquisition and pCSI for beam report are reported in a bundle for TDD serving cell
    :param cell_id: physical id of SCell
    """
    tti_data = _create_list_from_tti_trace_csv('dl', directory=directory)
    tti_for_cell = _filter_tti_traces_by_column_and_value(tti_data, column='physCellId', value=cell_id)
    tti_for_cqi_without_blanks = _filter_out_tti_traces_with_value(tti_for_cell,
                                                                   column='csiSrReportData.csiReport.cqi',
                                                                   value="")
    tti_for_beamid_without_blanks = _filter_out_tti_traces_with_value(tti_for_cell,
                                                                      column='dlBeamData.selectedBestBeamId',
                                                                      value="")
    cqi_values = _create_list_from_column(tti_for_cqi_without_blanks, column_name='csiSrReportData.csiReport.cqi')
    beamid_values = _create_list_from_column(tti_for_beamid_without_blanks, column_name='dlBeamData.selectedBestBeamId')
    logging.debug("All used csiReport.cqi values: {}".format(cqi_values))
    logging.debug("All used selectedBestBeamId values: {}".format(beamid_values))
    assert set(cqi_values) != 255 and beamid_values and tti_for_cell, \
        "pCSI and beam report are not reported in a bundle cqi={} BM={} scell={}".format(cqi_values,
                                                                                         beamid_values,
                                                                                         tti_for_cell)


def Verify_if_pCSI_is_reported_either_on_PUCCH_or_multiplexed_with_ULSCH_on_PUSCH(pcell, directory, scells=None):
    """
    Verifies if	pCSI is reported either on PUCCH or multiplexed with UL-SCH on PUSCH;
    :param pcell: id of primary cell
    :param scells: id of SCells, separated by comma like: 51,53, if not provided than omits SCells verification
    :return:
    """
    tti_data = _create_list_from_tti_trace_csv('dl', directory=directory)
    csi_tti_traces = _filter_tti_traces_by_column_and_value(tti_data,
                                                            column='csiSrReportData.reportType',
                                                            value='PERIODIC_CSI')
    pcell_csi_tti_traces = _filter_tti_traces_by_column_and_value(csi_tti_traces, column='physCellId', value=pcell)
    pcell_pucch_format_values = _create_list_from_column(pcell_csi_tti_traces,
                                                         column_name='csiSrReportData.pucchFormat')
    logging.debug("All PCell reports have formats: {}".format(pcell_pucch_format_values))
    assert set(pcell_pucch_format_values) == {'FORMAT_3'} or {'FROM_PUSCH'}, \
        "PUCCH format on pcells is {} instead of FORMAT_3 or FROM_PUSCH".format(pcell_pucch_format_values)
    if scells is not None:
        scells = scells.split(',')
        scells_csi_tti_traces = _filter_out_tti_traces_with_different_values_than(csi_tti_traces,
                                                                                  column='physCellId',
                                                                                  values=scells)
        scells_csi_tti_traces = _filter_out_tti_traces_with_value(scells_csi_tti_traces,
                                                                  column='csiSrReportData.pucchFormat',
                                                                  value='FORMAT_3')
        scell_pucch_format_values = _create_list_from_column(scells_csi_tti_traces,
                                                             column_name='csiSrReportData.pucchFormat')
        logging.debug("All SCells reports have formats: {}".format(scell_pucch_format_values))
        assert set(scell_pucch_format_values) == {'FOR_SCELL'} or {'FROM_PUSCH'}, \
            "PUCCH format on scells is {} instead of FOR_SCELL or FROM_PUSCH".format(scell_pucch_format_values)
