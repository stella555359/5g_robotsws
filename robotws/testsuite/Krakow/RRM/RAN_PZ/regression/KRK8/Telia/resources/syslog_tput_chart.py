import datetime as dt
import re
import plotly.graph_objects as go
import math
from plotly.subplots import make_subplots


# This code is a copy of this file:
# https://wrgitlab.int.net.nokia.com/RAN/robotws/-/blob/master/testsuite/Wroclaw/RRM/resources/syslog_tput_chart.py
# This version of the library is modified to allow for chart generation without any uplink throughput data

def parse_timestamp(log_line):
    time_re = r'[0-9]{2}.[0-9]{2} *[0-9]{2}:[0-9]{2}:[0-9]{2}'
    timestamp = re.findall(time_re, log_line)[0]
    year = str(dt.date.today().year)
    timestamp = year + " " + timestamp
    timestamp = timestamp.replace(".", " ")

    return dt.datetime.strptime(timestamp, "%Y %d %m %H:%M:%S")


def get_log_from_line(line):
    dt = parse_timestamp(line)
    dv = float(line[line.find('outB:') + 5: line.find(',', line.find('outB:'))]) * 8 / 1000

    return {'timestamp': dt, 'tput_value': dv}


def calculate_tpus_means_with_time(results):
    # results -> [{'timestamp': val, 'tput_value': val}]
    max_tput = max([log['tput_value'] for log in results if log['tput_value'] != 0])
    min_tput = min([log['tput_value'] for log in results if log['tput_value'] != 0])
    mean_tput = sum([log['tput_value'] for log in results if log['tput_value'] != 0]) / len([log['tput_value'] for
                                                                                             log in results
                                                                                             if log['tput_value'] != 0])
    return round(mean_tput, 2), round(min_tput, 2), round(max_tput, 2), results


def get_l2hi_dl_tput_with_time(path):
    tputs = []
    with open(path, 'r') as f:
        line = f.readline()
        first_in = False
        while line:
            if "STATS-DL-PDCP: GTPU" in line:
                if not first_in:
                    tputs.append(get_log_from_line(line))
                    first_in = True
                current_tput_log = get_log_from_line(line)
                last_log = tputs[-1]
                if last_log['timestamp'] == current_tput_log['timestamp']:
                    last_log['tput_value'] += current_tput_log['tput_value']
                else:
                    tputs.append(current_tput_log)
            line = f.readline()
    if tputs:
        return calculate_tpus_means_with_time(tputs)
    else:
        raise Exception("No Downlink logs available in a syslog file.")


def get_l2hi_ul_tput_with_time(path):
    tputs = []
    with open(path, 'r') as f:
        line = f.readline()
        first_in = False
        while line:
            if "STATS-UL-PDCP: GTPU" in line:
                if not first_in:
                    tputs.append(get_log_from_line(line))
                    first_in = True
                current_tput_log = get_log_from_line(line)
                last_log = tputs[-1]
                if last_log['timestamp'] == current_tput_log['timestamp']:
                    last_log['tput_value'] += current_tput_log['tput_value']
                else:
                    tputs.append(current_tput_log)
            line = f.readline()
    if tputs:
        return calculate_tpus_means_with_time(tputs)
    else:
        raise Exception("No Uplink logs available in a syslog file.")


def generate_tput_chart_form_syslog(syslog_path,
                                    save_target="/home/ute/robotws/syslog_tput.html",
                                    check_ul=True):
    both_dl = get_l2hi_dl_tput_with_time(syslog_path)[3]
    if check_ul:
        both_ul = get_l2hi_ul_tput_with_time(syslog_path)[3]
    timestamps = [x['timestamp'] for x in both_dl]

    if both_dl:
        fig = make_subplots(rows=1, cols=1, subplot_titles=["Throughput chart"])

        tput_to_add = [float(x['tput_value']) for x in both_dl]
        fig.add_trace(go.Scatter(x=timestamps, y=tput_to_add, name="Downlink"), row=1, col=1)
        if check_ul:
            tput_to_add = [float(x['tput_value']) for x in both_ul]
            fig.add_trace(go.Scatter(x=timestamps, y=tput_to_add, name="Uplink"), row=1, col=1)
        fig.update_xaxes(title_text="Time")
        fig.update_yaxes(title_text="Kbps")

        with open(save_target, "w") as f:
            f.write(fig.to_html(full_html=False))


def check_tput_drops(syslog_path,
                     max_avg_deviation=10,
                     max_repetition=3,
                     check_ul=True):
    both_dl = [log for log in get_l2hi_dl_tput_with_time(syslog_path)[3] if log['tput_value'] > 1]
    both_ul = [log for log in get_l2hi_ul_tput_with_time(syslog_path)[3] if log['tput_value'] > 2000]
    percentage_factor = 0.10
    percentage_up_deviation = 1 + (max_avg_deviation / 100)
    percentage_down_deviation = 1 - (max_avg_deviation / 100)
    to_cut = int(math.ceil(len(both_dl) * percentage_factor))
    drops = []
    avg = sum([dt_value['tput_value'] for dt_value in both_dl[to_cut + 1:-to_cut]]) / len(both_dl[to_cut + 1:-to_cut])
    print("AVG DL: ", avg)
    for value_dt in both_dl[to_cut + 1:-to_cut]:
        dt_tput_value = value_dt['tput_value']
        if dt_tput_value < (avg * percentage_down_deviation) or dt_tput_value > (avg * percentage_up_deviation):
            drops.append(value_dt)
            if len(drops) >= max_repetition:
                raise Exception("Downlink drops detected", drops)
    if not check_ul:
        return
    avg = sum([ut_value['tput_value'] for ut_value in both_ul[to_cut + 1:-to_cut]]) / len(both_ul[to_cut + 1:-to_cut])
    print("AVG UL: ", avg)
    for value_ut in both_ul[to_cut + 1:-to_cut]:
        ut_tput_value = value_ut['tput_value']
        if ut_tput_value < (avg * percentage_down_deviation) or ut_tput_value > (avg * percentage_up_deviation):
            drops.append(value_ut)
            if len(drops) >= max_repetition:
                raise Exception("Uplink drops detected", drops)


def check_tput_fluctuation(path_to_syslog,
                           chart_target,
                           check_ul=True):
    """Function generates html chart using syslog data. Function also checks tput fluctuation.
    Fluctuation means in this implementation deviation from avg.
    Parameters
        ----------
        path_to_syslog : str
            Path to syslog
        chart_target : str
            Path to save html chart
        check_ul : bool
            Whether to check fluctuation also for uplink (True by default)
        """

    generate_tput_chart_form_syslog(path_to_syslog, chart_target, check_ul)
    check_tput_drops(path_to_syslog, check_ul)
