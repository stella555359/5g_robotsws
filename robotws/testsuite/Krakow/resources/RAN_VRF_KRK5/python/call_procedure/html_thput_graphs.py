import os
import re
import plotly.graph_objects as go
import plotly.io as pio
import taf.rfrl.utilities.logger.custom_logger as logger
import testsuite.Krakow.resources.RAN_VRF_KRK5.python.call_procedure.common_operations as common_operations
from plotly.subplots import make_subplots


def generate_graphs(tput_stats, output_file):
    """
    Generate throughput graphs and save them to an HTML file.

    Parameters:
    tput_stats (dict): Throughput statistics.
    output_file (str): Path to the output HTML file.
    """

    dt_names = sorted(tput_stats.keys())
    fig = make_subplots(rows=len(dt_names), cols=1, subplot_titles=dt_names, x_title='Time[sec]', y_title='T-put')
    for i, dt_name in enumerate(dt_names, start=1):
        tput_data = tput_stats[dt_name]['iperf_data']
        tput_data = re.sub(r'^.*?\;(\[)*', '[', tput_data)
        tput_data += "" if tput_data.endswith("]") else "]"
        tput_data = eval(tput_data)
        fig.add_trace(go.Scatter(x=list(range(len(tput_data))), y=tput_data, mode='lines', showlegend=False), row=i,
                      col=1)
        target = float(tput_stats[dt_name]['expected_tput'].split()[0]) * 1000000.0
        fig.add_hline(y=target, line_dash="dot", row=i, col=1)
    fig.update_layout(autosize=False, width=1400, height=500*len(dt_names))
    pio.write_html(fig, file=output_file)


def generate_html_thput_graphs(data_transfer_stats=None, path_to_json_file=None, path_to_output_file=None, run_num='1'):
    """
    Generate HTML file with throughput graphs from data transfer statistics.

    Parameters:
    data_transfer_stats (dict, optional): Data transfer statistics.
    path_to_json_file (str, optional): Path to the JSON file containing data transfer statistics.
    path_to_output_file (str, optional): Path to save the output HTML file.
    run_num (str, optional): The current run number. Defaults to "1".
    """

    if path_to_json_file:
        data_transfer_stats = common_operations.load_data_from_json_file(path_to_json_file)

    if not data_transfer_stats:
        logger.log_warn_to_console('No data transfer statistics provided to generate graphs in HTML.')
        return

    if path_to_output_file:
        path_to_output_file += f"_DT_stats_run_{run_num}.html"
    else:
        path_to_output_file = os.path.join(
            common_operations.get_output_dir_to_save_dt_data(),
            f"{common_operations.get_test_case_name()}_run_{run_num}_tput_graphs.html"
        )

    generate_graphs(tput_stats=data_transfer_stats, output_file=path_to_output_file)
