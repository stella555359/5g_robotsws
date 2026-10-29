import tti_analyzer_framework.pandas_gate
import logging


def load_dataframe(path_to_pickle):
    global pd
    pd = tti_analyzer_framework.pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    return df


def filter_dataframe(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'ulTdSchedSubcellData.subcellId',
                               'ulTdSchedSubcellData.numAllocCellPrbUl', 'lcrId']
    df = df[required_discriminators]
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp'])
    return df


def prepare_dataframe_for_analysis(df):
    df.set_index(['timeStamp', 'sfn',	'slot', 'ulTdSchedSubcellData.subcellId'], inplace=True)
    return df


def load_and_prepare_data_frame_for_analysis(path_to_pickle):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe(df)
    df = prepare_dataframe_for_analysis(df)
    return df


def identify_subcells_in_trace(df):
    new_df = df.copy()
    new_df.reset_index(inplace=True)
    subcells = list(new_df['ulTdSchedSubcellData.subcellId'].unique())
    subcells = [int(subcell) for subcell in subcells]
    subcells = sorted(subcells)
    return subcells


def generate_average_prb_allocation_per_subcell(df):
    df['AveragePRBAllocationPerSubcell'] = None
    df['AveragePRBAllocationPerSubcell'] = \
        df.groupby(level=[0, 1, 2, 3])['ulTdSchedSubcellData.numAllocCellPrbUl'].mean()
    return df


def calculate_total_pooled_prb_per_slot(df):
    df_stat = df.copy()
    df_stat.dropna(subset=['AveragePRBAllocationPerSubcell'], inplace=True)
    df_stat = df_stat[~df_stat.index.duplicated(keep='first')]
    df_stat['TotalPooledPRB'] = df_stat.groupby(level=[0, 1])['AveragePRBAllocationPerSubcell'].sum()
    df_stat = df_stat[df_stat.index.get_level_values(0).duplicated(keep=False)]
    return df_stat


def plot_using_matplot_lib(df_stat, subcells, base_location):
    try:
        ax = df_stat[df_stat.index.get_level_values(3) ==
                     subcells[0]]['ulTdSchedSubcellData.numAllocCellPrbUl'].plot()
        legend_list = [str("Subcell_%s" % subcells[0])]
        for subcell in subcells[1:]:
            df_stat[df_stat.index.get_level_values(3) ==
                    subcell]['ulTdSchedSubcellData.numAllocCellPrbUl'].plot(ax=ax)
            legend_list.append(str("Subcell_%s" % subcell))
        ax.legend(legend_list)
        fig = ax.get_figure()
        path_to_plot = base_location + "/plot.png"
        fig.savefig(path_to_plot)
    except ImportError:
        logging.warning("matplotlib not installed therefore plot will not be saved, please install matplotlib using "
                        "the command: pip install matplotlib")


def populate_sfn_slot_index(df_to_be_manipulated):
    g = df_to_be_manipulated.groupby((df_to_be_manipulated['sfn'].diff() < 0.0).cumsum())
    mp = df_to_be_manipulated.groupby((df_to_be_manipulated['sfn'].diff() < 0).cumsum(), as_index=False).max().\
        shift(1).fillna(0)['sfn']
    for grp, chunk in g:
        df_to_be_manipulated['sfn'] += (df_to_be_manipulated['sfn'].diff() < 0).cumsum().map(mp)
    final_df = df_to_be_manipulated.copy()
    final_df['sfn_slot'] = final_df['sfn'].map(str) + '/' + final_df['slot'].map(str)
    return final_df


def prepare_dataframe_for_plotting_with_plotly(df):
    df.reset_index(inplace=True)
    df = populate_sfn_slot_index(df)
    return df


def identify_reference_subcell(df_stat, subcells):
    reference_cell = df_stat[df_stat['ulTdSchedSubcellData.subcellId'] == subcells[0]]
    for subcell in subcells[1:]:
        if len(reference_cell) > len(df_stat[df_stat['ulTdSchedSubcellData.subcellId'] == subcell]):
            reference_cell = df_stat[df_stat['ulTdSchedSubcellData.subcellId'] == subcell]
    return reference_cell


def plot_df_with_plotly(df, subcells, base_location):
    try:
        import plotly.graph_objects as go
        fig = go.Figure()
        ref_subcell = identify_reference_subcell(df, subcells)
        for subcell in subcells:
            subcell_data = df[df['ulTdSchedSubcellData.subcellId'] == subcell]
            fig.add_trace(go.Scatter(x=ref_subcell['sfn_slot'],
                                     y=subcell_data['ulTdSchedSubcellData.numAllocCellPrbUl'],
                                     mode='lines', name=str("Subcell_%s" % subcell)))
        fig.update_layout(title="PRB allocation per TTI", xaxis_title="SFN / SLOT",
                          yaxis_title="ulTdSchedSubcellData.numAllocCellPrbUl")
        fig.write_html(base_location+'/all_subcells_prb_plot.html', auto_open=False)
    except ModuleNotFoundError:
        logging.warning("plotly is not installed therefore plot will not be saved, please install plotly using "
                        "the command: pip install plotly")


def get_directory_path(path_to_pickle):
    return "/".join(path_to_pickle.split("/")[:-1])


def plot_prb_allocation_per_subcell(path_to_pickle):
    directory = get_directory_path(path_to_pickle)
    df = load_and_prepare_data_frame_for_analysis(path_to_pickle)
    subcells = identify_subcells_in_trace(df)
    df = generate_average_prb_allocation_per_subcell(df)
    plot_df = calculate_total_pooled_prb_per_slot(df)
    plot_using_matplot_lib(plot_df, subcells, directory)
    plot_plotly_df = prepare_dataframe_for_plotting_with_plotly(plot_df)
    plot_df_with_plotly(plot_plotly_df, subcells, directory)
