import glob
import os
import subprocess
import time
import datetime as dt
import re
import plotly.graph_objects as go
import math
from plotly.subplots import make_subplots


# from robot.libraries.BuiltIn import BuiltIn


def wait_for_syslog_to_finnish(p):
    out, err = p.communicate()
    log_path = out[out.find('Logs are saved at ') + 18: out.rfind('\n--- Executed')]

    return log_path


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


def calculate_tpus_means(results):
    max_tput = max(results)
    min_tput = min(results)
    mean_tput = sum(results) / len(results)
    results = [round(num, 2) for num in results]
    return round(mean_tput, 2), round(min_tput, 2), round(max_tput, 2), results


def calculate_tpus_means_with_time(results):
    # results -> [{'timestamp': val, 'tput_value': val}]
    max_tput = max([log['tput_value'] for log in results if log['tput_value'] != 0])
    min_tput = min([log['tput_value'] for log in results if log['tput_value'] != 0])
    mean_tput = sum([log['tput_value'] for log in results if log['tput_value'] != 0]) / len([log['tput_value'] for
                                                                                             log in results
                                                                                             if log['tput_value'] != 0])
    return round(mean_tput, 2), round(min_tput, 2), round(max_tput, 2), results


def get_path_to_octopus_output(path):
    list_of_files = glob.glob(path + '/*')
    if list_of_files:
        return max(glob.glob(path + '/*'), key=os.path.getctime)
    else:
        BuiltIn().log_to_console('There\'s no syslog file')
        return ''


def get_L2Hi_DL_tput(path):
    with open(path, 'r') as f:
        tputs = [float(line[line.find('outB:') + 5: line.find(',', line.find('outB:'))]) * 8 / 1000000
                 for line in f if 'DL-PDCP numOfBearers:1, bearerGroup:0' in line]
    tputs = [i for i in tputs if i != 0]
    if tputs:
        return calculate_tpus_means(tputs)
    else:
        return 0, 0, 0, [0]


def get_L2Hi_UL_tput(path):
    with open(path, 'r') as f:
        tputs = [float(line[line.find('outB:') + 5: line.find(',', line.find('outB:'))]) * 8 / 1000000
                 for line in f if 'UL-PDCP numOfBearers:1, bearerGroup:0' in line]
    tputs = [i for i in tputs if i != 0]
    if tputs:
        return calculate_tpus_means(tputs)
    else:
        raise Exception("No Uplink logs available in a syslog file.")


def get_L2Hi_DL_tput_with_time(path):
    tputs = []
    with open(path, 'r') as f:
        line = f.readline()
        first_in = False
        while line:
            if "STATS-DL-PDCP: GTPU" in line or "DL-PDCP: GTPU_STATS" in line:
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


def get_L2Hi_UL_tput_with_time(path):
    tputs = []
    with open(path, 'r') as f:
        line = f.readline()
        first_in = False
        while line:
            if "STATS-UL-PDCP: GTPU" in line or "UL-PDCP: GTPU_STATS" in line:
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


def get_L2Lo_DL_tput(path):
    with open(path, 'r') as f:
        tputs = []
        for line in f:
            if 'DlSlotSynchroCountersUpdate.hpp:87' in line:
                line = line[line.find('|Buffered: ') + 11: line.rfind('] [Event')]
                line = line[line.find('|') + 1:line.rfind('|')]
                line = float(line[line.find('|') + 1:])
                if line != 0:
                    tputs.append(round(line, 2))
    tputs = [i - tputs[0] for i in tputs]
    tputs_temp = [tputs[0]]
    for i in range(len(tputs) - 1):
        tputs_temp.append((tputs[i + 1] - tputs[i]) * 8 / 1000000)
    tputs = tputs_temp
    tputs = [i for i in tputs if i != 0.0]
    if tputs:
        return calculate_tpus_means(tputs)
    else:
        return 0, 0, 0, [0]


def get_L2Lo_DL_tput_2CC(path):
    with open(path, 'r') as f:
        tputs = []
        for line in f:
            if 'SentDataMeasurementCounting.hpp:184/ttisFromUpdate: 2048 nrCellId' in line:
                line = line[line.find('|DataPdu: ') + 10: line.rfind(']')]
                line = line[line.find('|') + 1:line.rfind('|')]
                line = float(line[line.find('|') + 1:]) * 8 / 1000000
                tputs.append(round(line, 2))
        combined = []
        for i in range(0, len(tputs) - 1, 2):
            # print('{}    {}    =    {}'.format(tputs[i], tputs[i + 1], tputs[i] + tputs[i + 1]))
            combined.append(tputs[i] + tputs[i + 1])
        tputs = combined
    tputs = [i for i in tputs if i != 0]
    if tputs:
        return calculate_tpus_means(tputs)
    else:
        return 0, 0, 0, [0]


def verify_intra_gNB_HO(syslog_path):
    status = None
    startingCellId = None
    targetCellId = None
    ue_status = None

    with open(syslog_path, 'r') as f:
        for line in f:
            if ' cause:INTRADUHANDOVER' in line:
                targetCellId = re.findall(r"servingCell\[0]:[0-9]+", line)[0]
                targetCellId = re.findall(r"[0-9][0-9]+", targetCellId)[0]
            if 'DL_CP' in line and 'cause:HANDOVER' in line or 'UL_CP' in line and 'cause:HANDOVER' in line:
                startingCellId = re.findall(r"nrCellIdentity:[0-9]+", line)[0]
                startingCellId = re.findall(r"[0-9][0-9]+", startingCellId)[0]
            if 'SaHandoverRrcReconfigurationProcedure' in line and 'RrcReconfigurationComplete received' in line:  # SA
                ue_status = 'received'
            if 'ueAddCause:intraDuHandover' in line and 'successfully built' in line:  # NSA
                ue_status = 'received'

    if startingCellId is not None and targetCellId is not None and ue_status == 'received':
        status = 'completed'

    return status, startingCellId, targetCellId


def verify_inter_gNB_HO(syslog_path):
    status = None
    targetCellId = None

    with open(syslog_path, 'r') as f:
        status = [0, 0, 0, 0]
        for line in f:
            if 'Inter DU/gnb Handover' in line and 'cp_rt' in line:
                status[0] = 1  # started
            if 'HandleUserSetupReq' in line and ' cause:HANDOVER' in line:
                targetCellId = re.findall(r"servingCell\[0]:[0-9]+", line)[0]
                targetCellId = re.findall(r"[0-9][0-9]+", targetCellId)[0]
                status[1] = 1  # setup
            if 'XnUeContextRelease to source Gnb' in line:
                status[2] = 1  # released
            if 'xnInterGnbHandoverOnTarget' in line and 'status: Completed' in line:
                status[3] = 1  # completed
        if 0 not in status and targetCellId is not None:
            status = 'completed'
        else:
            status = 'failed'

    return status, targetCellId


def verify_attach(syslog_path):
    bts_type = None
    with open(syslog_path, 'r') as f:
        for line in f:
            if 'UserSetup - ue' in line and ' cause:INITIALACCESS' in line or \
                    'UE setup' in line and 'ueAddCause:INITIALACCESS' in line:
                bts_type = 'SA'
            if 'UserSetup - ue' in line and 'cause:INITIALACCESSSGNBADDITION' in line \
                    or 'Admit UE' in line and 'ueAddCause:initialAccessSgnbAddition' in line:
                bts_type = 'NSA'
    if bts_type == 'SA':
        status, cell_id, statuses = verify_SA_attach(syslog_path)
    elif bts_type == 'NSA':
        status, cell_id, statuses = verify_NSA_attach(syslog_path)
    else:
        message = """
        Couldn\'t determine if NSA or SA. Please verify syslog prints:
        SA: cause:INITIALACCESS or ueAddCause:INITIALACCESS
        NSA: cause:INITIALACCESSSGNBADDITION or ueAddCause:initialAccessSgnbAddition
        """
        BuiltIn().log_to_console(message)
        status = 'failed'
        cell_id = None
        statuses = []
    if status != 'completed':
        for i in statuses:
            BuiltIn().log_to_console('Print not found in syslog: {}'.format(i))
    return status, cell_id


def verify_SA_attach(syslog_path):
    setup_cell, session_cell, status, init_ueIdCu, session_ueIdCu = None, None, None, None, None
    attaches = []
    statuses = []
    with open(syslog_path, 'r') as f:
        for line in f:
            if 'UserSetup - ue' in line and ' cause:INITIALACCESS' in line:
                setup_cell = re.findall(r"servingCell\[0]:[0-9]+", line)[0]
                setup_cell = re.findall(r"[0-9][0-9]+", setup_cell)[0]
            if 'UE setup' in line and 'ueAddCause:INITIALACCESS' in line:
                setup_cell = re.findall(r"cellId:[0-9]+", line)[0]
                setup_cell = re.findall(r"[0-9][0-9]+", setup_cell)[0]
            if 'Session established' in line:
                session_cell = re.findall(r"NRCellIdentity:.*[0-9]+", line)[0]
                session_cell = re.findall(r"[0-9]+", session_cell)[0]
                session_ueIdCu = re.findall(r"ueIdCu:[0-9]+", line)[0]
                session_ueIdCu = re.findall(r"[0-9]+", session_ueIdCu)[0]
                statuses.append('Session established')
            if 'Initial Access' in line and 'performed' in line:
                init_ueIdCu = re.findall(r"ueIdCu:[0-9]+", line)[0]
                init_ueIdCu = re.findall(r"[0-9]+", init_ueIdCu)[0]
                statuses.append('Initial Access')
            if None not in (session_ueIdCu, init_ueIdCu, session_ueIdCu, setup_cell):
                if session_ueIdCu == init_ueIdCu and session_cell == setup_cell:
                    status = 'completed'
                    attaches.append([status, setup_cell])
                    setup_cell, session_cell, status, init_ueIdCu, session_ueIdCu = None, None, None, None, None
    if len(attaches) > 1:
        return 'multiple attaches found in syslog.', None, statuses
    elif len(attaches) == 1:
        return attaches[0][0], attaches[0][1], statuses
    else:
        not_found = []
        if 'Session established' not in statuses:
            not_found.append('Session established')
        if 'Initial Access' not in statuses:
            not_found.append('Initial Access for ueIdCu:X has been performed')
        statuses = not_found
        return 'failed', None, statuses


def verify_NSA_attach(syslog_path):
    setup_cell, session_cell, status, init_ueIdCu, session_ueIdCu = None, None, None, None, None
    attaches = []
    statuses = []
    with open(syslog_path, 'r') as f:
        for line in f:
            if 'UserSetup - ue' in line and 'cause:INITIALACCESSSGNBADDITION' in line:
                setup_cell = re.findall(r"servingCell\[0]:[0-9]+", line)[0]
                setup_cell = re.findall(r"[0-9][0-9]+", setup_cell)[0]
            if 'Admit UE' in line and 'ueAddCause:initialAccessSgnbAddition' in line:
                try:
                    setup_cell = re.findall(r"nrCellIdentity:[0-9]+", line)[0]
                except IndexError:
                    setup_cell = re.findall(r"cell\([0-9]+\)", line)[0]
                setup_cell = re.findall(r"[0-9][0-9]+", setup_cell)[0]
            if 'SgnbAddition: origin' in line:
                session_cell = re.findall(r"candidateCells \[.*[0-9]+\]", line)[0]
                session_cell = re.findall(r"[0-9]+", session_cell)[0]
                session_ueIdCu = re.findall(r"ueIdCu:[0-9]+", line)[0]
                session_ueIdCu = re.findall(r"[0-9]+", session_ueIdCu)[0]
                statuses.append('SgnbAddition: origin')
            if 'InitialAccess established' in line:
                init_ueIdCu = re.findall(r"ueIdCu:[0-9]+", line)[0]
                init_ueIdCu = re.findall(r"[0-9]+", init_ueIdCu)[0]
                statuses.append('InitialAccess established')
            if None not in (session_ueIdCu, init_ueIdCu, session_ueIdCu, setup_cell):
                if session_ueIdCu == init_ueIdCu and session_cell == setup_cell:
                    status = 'completed'
                    attaches.append([status, setup_cell])
                    setup_cell, session_cell, status, init_ueIdCu, session_ueIdCu = None, None, None, None, None
    if len(attaches) > 1:
        return 'multiple attaches found in syslog.', None, statuses
    elif len(attaches) == 1:
        return attaches[0][0], attaches[0][1], statuses
    else:
        not_found = []
        if 'SgnbAddition: origin' not in statuses:
            not_found.append('SgnbAddition: origin')
        if 'InitialAccess established' not in statuses:
            not_found.append('InitialAccess established')
        statuses = not_found
        return 'failed', None, statuses


def get_pcell_scell_from_syslog(syslog_path):
    pcell = None
    scell = None
    with open(syslog_path, 'r') as f:
        for line in f:
            if 'ScellUeSchedulingReq coming from PCell' in line:
                pcell = re.findall(r"PCellId:[0-9]+", line)[0]
                pcell = re.findall(r"[0-9]+", pcell)[0]
                scell = re.findall(r"SCellId:[0-9]+", line)[0]
                scell = re.findall(r"[0-9]+", scell)[0]

    return pcell, scell


def generate_tput_chart_form_syslog(syslog_path, save_target="/home/ute/robotws/syslog_tput.html"):
    both_dl = get_L2Hi_DL_tput_with_time(syslog_path)[3]
    both_ul = get_L2Hi_UL_tput_with_time(syslog_path)[3]
    timestamps = [x['timestamp'] for x in both_dl]

    if both_dl:
        fig = make_subplots(rows=1, cols=1, subplot_titles=["Throughput chart"])

        tput_to_add = [float(x['tput_value']) for x in both_dl]
        fig.add_trace(go.Scatter(x=timestamps, y=tput_to_add, name="Downlink"), row=1, col=1)
        tput_to_add = [float(x['tput_value']) for x in both_ul]
        fig.add_trace(go.Scatter(x=timestamps, y=tput_to_add, name="Uplink"), row=1, col=1)
        fig.update_xaxes(title_text="Time")
        fig.update_yaxes(title_text="Mbps")

        with open(save_target, "w") as f:
            f.write(fig.to_html(full_html=False))


def check_tput_drops(syslog_path):
    both_dl = [log for log in get_L2Hi_DL_tput_with_time(syslog_path)[3] if log['tput_value'] > 1]
    both_ul = [log for log in get_L2Hi_UL_tput_with_time(syslog_path)[3] if log['tput_value'] > 2000]
    percentage_factor = 0.10
    percentage_up_deviation = 1.20
    percentage_down_deviation = 0.80
    to_cut = int(math.ceil(len(both_dl) * percentage_factor))
    max_repetition = 5
    drops = []
    avg = sum([dt_value['tput_value'] for dt_value in both_dl[to_cut + 1:-to_cut]]) / len(both_dl[to_cut + 1:-to_cut])
    print("AVG DL: ", avg)
    for value_dt in both_dl[to_cut + 1:-to_cut]:
        dt_tput_value = value_dt['tput_value']
        if dt_tput_value < (avg * percentage_down_deviation) or dt_tput_value > (avg * percentage_up_deviation):
            drops.append(value_dt)
            if len(drops) >= max_repetition:
                raise Exception("Downlink drops detected", drops)
    avg = sum([ut_value['tput_value'] for ut_value in both_ul[to_cut + 1:-to_cut]]) / len(both_ul[to_cut + 1:-to_cut])
    print("AVG UL: ", avg)
    for value_ut in both_ul[to_cut + 1:-to_cut]:
        ut_tput_value = value_ut['tput_value']
        if ut_tput_value < (avg * percentage_down_deviation) or ut_tput_value > (avg * percentage_up_deviation):
            drops.append(value_ut)
            if len(drops) >= max_repetition:
                raise Exception("Uplink drops detected", drops)


def check_tput_fluctuation(path_to_syslog, chart_target):
    generate_tput_chart_form_syslog(path_to_syslog, chart_target)
    check_tput_drops(path_to_syslog)
