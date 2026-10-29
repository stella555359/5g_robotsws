import logging

from tti_analyzer_framework import pandas_gate
from log_function_progress import log_begin_end_func_name


pd = None


@log_begin_end_func_name
def load_dataframe(path_to_pickle):
    global pd
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    return df


@log_begin_end_func_name
def filter_dataframe(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'ulTdSchedSubcellData.subcellId',
                               'ulTdSchedSubcellData.numAllocCellPrbUl', 'lcrId']
    df = df[required_discriminators]
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp'])
    return df


@log_begin_end_func_name
def drop_head_tail_entries(df, num=1000):
    """Function drops num entries from the beginning and the end of the dataframe to compensate for the
    abnormalities seen in trace during start and stop of traffic"""
    df = df[num:-num]
    return df


@log_begin_end_func_name
def prepare_df_to_compute_statistics(df_pooled_subcells):
    df_stat = pd.DataFrame()
    df_stat = df_pooled_subcells.copy()
    df_stat.dropna(subset=['AveragePRBAllocationPerSubcell'], inplace=True)
    df_stat = df_stat[~df_stat.index.duplicated(keep='first')]
    df_stat['TotalPooledPRB'] = df_stat.groupby(level=[0, 1])['AveragePRBAllocationPerSubcell'].sum()
    df_stat = df_stat[df_stat.index.get_level_values(0).duplicated(keep=False)]
    logging.info(df_stat)
    return df_stat


@log_begin_end_func_name
def prepare_df_to_compute_average_prb_allocation(df, list_of_pooled_subcells, non_pooled_subcell):
    df_pooled_subcells = df.where(df['ulTdSchedSubcellData.subcellId'] != non_pooled_subcell).dropna()
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'ulTdSchedSubcellData.subcellId'], inplace=True)
    df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
        df_pooled_subcells.groupby(level=[0, 1, 2, 3])['ulTdSchedSubcellData.numAllocCellPrbUl'].mean()
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


@log_begin_end_func_name
def prepare_df_to_compare_prbs_per_tti_in_pooled_subcells(list_of_pooled_subcells,
                                                          df_stat,
                                                          subcell_expecting_higher_prb_allocation):
    series_subcell_dict = {}
    for subcell in list_of_pooled_subcells:
        if subcell == subcell_expecting_higher_prb_allocation:
            series_subcell_dict['Subcell_with_expected_higher_prb_allocation'] = df_stat[df_stat.index.isin(
                [subcell], level=3)]['AveragePRBAllocationPerSubcell']
            series_subcell_dict['Subcell_with_expected_higher_prb_allocation'].drop(
                columns='ulTdSchedSubcellData.subcellId', inplace=True)
            series_subcell_dict['Subcell_with_expected_higher_prb_allocation'] = series_subcell_dict[
                'Subcell_with_expected_higher_prb_allocation'].droplevel(3)
        else:
            series_subcell_dict['Subcell_with_expected_lower_prb_allocation'] = df_stat[df_stat.index.isin(
                [subcell], level=3)]['AveragePRBAllocationPerSubcell']
            series_subcell_dict['Subcell_with_expected_lower_prb_allocation'].drop(
                columns='ulTdSchedSubcellData.subcellId', inplace=True)
            series_subcell_dict['Subcell_with_expected_lower_prb_allocation'] = series_subcell_dict[
                'Subcell_with_expected_lower_prb_allocation'].droplevel(3)
    return series_subcell_dict


@log_begin_end_func_name
def get_per_tti_prb_pooling_compliance_stats(series_subcell_dict):
    logging.info("get_per_tti_prb_pooling_compliance_stats: series_subcell_dict = %s" % series_subcell_dict)
    compare_subcell_pooling = series_subcell_dict['Subcell_with_expected_higher_prb_allocation'].compare(
        series_subcell_dict['Subcell_with_expected_lower_prb_allocation'])
    compare_subcell_pooling['CompareResult'] = compare_subcell_pooling['self'] > compare_subcell_pooling['other']
    compliance_expected_pooling = compare_subcell_pooling['CompareResult'].value_counts()
    compliance_percentage = (compliance_expected_pooling[True]/compliance_expected_pooling.sum())*100
    return compliance_percentage


@log_begin_end_func_name
def validate_load_based_prb_pooling_compliance(compliance_percentage, expected_compliance_percentage=90.0):
    """Generates verdict to ensure the compliance of the load based prb pooling per subcell is compliant to the
    defined threshold """
    logging.info("compliance_percentage = %s" % compliance_percentage)
    logging.info("expected_compliance_percentage = %s" % expected_compliance_percentage)
    if compliance_percentage >= expected_compliance_percentage:
        logging.info("Compliance test passed (%s) - PRB allocation is higher for cell with higher load"
                     % compliance_percentage)
        return True
    else:
        logging.error("Compliance test Failed (%s)- PRB allocation is lower than required threshold (%s) "
                      "for cell with higher load" % (compliance_percentage, expected_compliance_percentage))
        return False


@log_begin_end_func_name
def weighted_average(distribution, weights):
    return int(round(sum([distribution[i]*weights[i] for i in range(len(distribution))])/sum(weights), 2))


@log_begin_end_func_name
def validate_averaged_total_prbs_allocated(result, expected_total_prbs=352, expected_compliance_percentage=95):
    """Generates verdict to ensure the total prbs allocated per subcell matches the expected total prbs"""
    logging.info("result = %s" % result)
    logging.info("expected_total_prbs = %s" % expected_total_prbs)
    tolerance = int(expected_total_prbs * (100 - expected_compliance_percentage) / 100)
    defined_range_expected_total_prbs = list(range(expected_total_prbs - tolerance, expected_total_prbs + 1))
    logging.info("defined_range_expected_total_prbs = %s" % defined_range_expected_total_prbs)
    averaged_total_prb_pooled = weighted_average(list(result.keys()), list(result.values()))
    logging.info("averaged_total_prb_pooled = %s" % averaged_total_prb_pooled)
    if averaged_total_prb_pooled in defined_range_expected_total_prbs:
        logging.info("Total PRBs in pooled subcells matches expected total prbs")
        return True
    else:
        logging.error("Total PRBs (%s) in pooled subcells does not match expected total prbs (%s)"
                      % (result, defined_range_expected_total_prbs))
        return False


@log_begin_end_func_name
def plot_figure(path_to_save_plot, df_stat, list_of_pooled_subcells):
    try:
        ax = df_stat[df_stat.index.get_level_values(3) ==
                     list_of_pooled_subcells[0]]['ulTdSchedSubcellData.numAllocCellPrbUl'].plot()
        df_stat[df_stat.index.get_level_values(3) ==
                list_of_pooled_subcells[1]]['ulTdSchedSubcellData.numAllocCellPrbUl'].plot(ax=ax)
        ax.legend([str("Subcell_%s" % list_of_pooled_subcells[0]), str("Subcell_%s" % list_of_pooled_subcells[1])])
        fig = ax.get_figure()
        fig.savefig(path_to_save_plot+"/plot_pooled_subcells.png")
    except ImportError:
        logging.warning("matplotlib not installed therefore plot will not be saved, please install matplotlib using "
                        "the command: pip install matplotlib")


@log_begin_end_func_name
def get_directory(path):
    path_tmp = path.split("/")
    path = "/".join(path_tmp[:-1])
    return path


@log_begin_end_func_name
def run_load_based_prb_pooling_analysis(path_to_pickle,
                                        subcell_expecting_higher_prb_allocation,
                                        list_of_pooled_subcells=[0, 2],
                                        exclude_samples_for_analysis=1000,
                                        non_pooled_subcell=1,
                                        expected_total_prbs=352,
                                        expected_compliance_percentage=90):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_prb_allocation(df, list_of_pooled_subcells, non_pooled_subcell)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/dataframe_for_manual_analysis.csv" % get_directory(path_to_pickle)))
    total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    logging.info("total_prb_allocation_pooled_cells = %s" % total_prb_allocation_pooled_cells)
    plot_figure(get_directory(path_to_pickle), df_stat, list_of_pooled_subcells)
    series_subcell_dict = \
        prepare_df_to_compare_prbs_per_tti_in_pooled_subcells(list_of_pooled_subcells,
                                                              df_stat,
                                                              subcell_expecting_higher_prb_allocation)
    compliance_percentage = get_per_tti_prb_pooling_compliance_stats(series_subcell_dict)
    result_load_based_prb_pooling_compliance = \
        validate_load_based_prb_pooling_compliance(compliance_percentage, expected_compliance_percentage)
    result_total_prb_in_pooling_period = validate_averaged_total_prbs_allocated(
        total_prb_allocation_pooled_cells.to_dict(), expected_total_prbs, expected_compliance_percentage)
    return all([result_load_based_prb_pooling_compliance, result_total_prb_in_pooling_period])


@log_begin_end_func_name
def check_total_pooled_prbs(path_to_pickle,
                            subcell_expecting_higher_prb_allocation,
                            list_of_pooled_subcells=[0, 2],
                            exclude_samples_for_analysis=1000,
                            non_pooled_subcell=1,
                            expected_total_prbs=352,
                            expected_compliance_percentage=95):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_prb_allocation(df, list_of_pooled_subcells, non_pooled_subcell)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/dataframe_for_manual_analysis.csv" % get_directory(path_to_pickle)))
    total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    logging.info("total_prb_allocation_pooled_cells = %s" % total_prb_allocation_pooled_cells)
    plot_figure(get_directory(path_to_pickle), df_stat, list_of_pooled_subcells)
    result_total_prb_in_pooling_period = validate_averaged_total_prbs_allocated(
        total_prb_allocation_pooled_cells.to_dict(), expected_total_prbs, expected_compliance_percentage)
    return all([result_total_prb_in_pooling_period])


if __name__ == "__main__":
    path_to_pickle = "/Logs/tti_trace_scenario_1_default_scenario/ttitrace_streaming.pkl"
    run_load_based_prb_pooling_analysis(path_to_pickle, 0,
                                        list_of_pooled_subcells=[0, 1, 2],
                                        exclude_samples_for_analysis=1000, non_pooled_subcell=None,
                                        expected_total_prbs=615,
                                        expected_compliance_percentage=90)
