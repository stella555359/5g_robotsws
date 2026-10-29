from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
import os
import pandas as pd

from testsuite.Wroclaw.RRM.resources.tti_verification.csv_verification import process_needed_messages, \
    filter_list_of_dicts


def check_and_assign_filename(folder='run_0'):
    path = os.path.join(robot_globals.outputdir(), folder)
    while os.path.exists(path):
        idx = folder.split('_')[-1]
        new_idx = int(idx) + 1
        name = folder.split('_')[0]
        folder = name + '_' + str(new_idx)
        path = os.path.join(robot_globals.outputdir(), folder)
    blog('output path: ' + path)
    return path


def analyse_all_tti(folder, filename_pattern='ROHC_C_COLLECT_LOGS_TTI', cell_id=None):
    df = pd.DataFrame(columns=['avg_sinr', 'avg_rssi', 'ul_used_MCS', 'ul_proposed_MCS'])
    for file in os.listdir(folder):
        if file.startswith('run_'):
            blog('------------------------------------')
            blog('LOG: ' + str(file))
            df = df.append(
                analyse_rohc_c(os.path.join(folder, file, filename_pattern + '.ul.csv'), file, cell_id=cell_id))
            blog('------------------------------------\n')
    blog('Analysis output is stored in: ' + folder)
    df.to_excel(os.path.join(folder, 'analysis_output.xls'), float_format='%.2f')


def analyse_rohc_c(tti_path, file, cell_id=None):
    pusch_response = process_needed_messages(tti_path, ['ulPuschReceiveRespPsData'])
    all_fd_sched = process_needed_messages(tti_path, ['ulFdSchedData'])

    if cell_id:
        pusch_response = filter_list_of_dicts(key='physCellId', val=str(cell_id), array=pusch_response)
        assert pusch_response, 'NO RELEVANT PUSCH FOUND IN TTI LOGS. CHECK IF CELL ARGUMENT MATCHES CELL IN LOGS.'
        all_fd_sched = filter_list_of_dicts(key='physCellId', val=str(cell_id), array=all_fd_sched)
        assert pusch_response, \
            'NO RELEVANT ulFdSchedData FOUND IN TTI LOGS. CHECK IF CELL ARGUMENT MATCHES CELL IN LOGS.'

    total_used_mcs = 0
    total_proposed_mcs = 0
    total_mcs = 0
    for fd in all_fd_sched:
        used_mcs = fd['rrmUlUsedMcs']
        proposed_mcs = fd['rrmUlProposedMcs']
        if int(used_mcs) in range(29) and int(proposed_mcs) in range(29):
            total_proposed_mcs += float(proposed_mcs)
            total_used_mcs += float(used_mcs)
            total_mcs += 1
    avg_used_mcs = total_used_mcs / total_mcs
    avg_proposed_mcs = total_proposed_mcs / total_mcs

    pusch_measurements = []
    for response in pusch_response:
        if abs(float(response['rssi'])) > 1.0:
            pusch_measurements.append((response['rssi'], response['sinr_[0]']))

    rssi_sum = 0
    sinr_sum = 0
    for measurement in pusch_measurements:
        rssi = measurement[0]
        sinr = measurement[1]
        rssi_sum += float(rssi)
        sinr_sum += float(sinr)

    try:
        pusch_rssi_avg = rssi_sum / len(pusch_measurements)
        pusch_sinr_avg = sinr_sum / len(pusch_measurements)
    except ZeroDivisionError:
        pusch_rssi_avg = 'N/A'
        pusch_sinr_avg = 'N/A'

    blog('----PUSCH----')
    blog('avg_sinr: ' + str(round(pusch_sinr_avg, 2)), 'avg_rssi: ' + str(round(pusch_rssi_avg, 2)) + '\n')

    data = {'avg_sinr': str(round(pusch_sinr_avg, 2)),
            'avg_rssi': str(round(pusch_rssi_avg, 2)),
            'ul_used_MCS': str(round(avg_used_mcs, 2)),
            'ul_proposed_MCS': str(round(avg_proposed_mcs, 2))}

    # Create DataFrame
    df = pd.DataFrame(data, index=[file])
    return df
