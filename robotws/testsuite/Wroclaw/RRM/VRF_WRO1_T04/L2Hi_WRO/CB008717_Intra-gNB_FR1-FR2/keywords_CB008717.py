import re
import subprocess
from robot.errors import ExecutionFailed
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from robot.api import logger
import time
import csv


def check_if_next_tx_contains_fmc(bip_csv_fielpath):
    passed = False
    index = 0
    fmc = 0
    with open(bip_csv_fielpath, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            if row['pdcp-nr.fmc']:
                fmc = row['pdcp-nr.fmc']
                fmc_index = index
            if fmc != 0 and index == fmc_index + 1:
                next_tx = row['pdcp-nr.seq-num']
            index += 1
    next_tx_list = next_tx.split(',')
    print(fmc)
    print(next_tx_list)
    for sn in next_tx_list:
        if int(sn) == int(fmc):
            passed = True
    if not passed:
        raise Exception("Process timed out")


def send_a4_measurement(ue_id='1', a4_params='phycell_id=52 nrsrp_nr=60 event=A4'):
    meas_id = check_a4_measurement_id(ue_id)
    wts = BuiltIn().get_library_instance('ute_wtssim')
    wts.execute_egate_command(
        cmd='ue_measurement_send_nr id={} meas_id={} {}'.format(ue_id, meas_id, a4_params))


def check_a4_measurement_id(ue_id):
    pat_nr_meas = ('NR MEASUREMENT IDENTITIES:.*MeasId  ObjectId  ReportCfgId.*\\d+')
    pat_meas_id = ('\\d+')
    regx_nr_meas = re.compile(pat_nr_meas, re.MULTILINE)
    regx_meas_id = re.compile(pat_meas_id)
    nr_meas = []
    max_retry = 10

    while len(nr_meas) == 0:
        max_retry -= 1
        time.sleep(12)
        ue_meas_disp = disp_ue_measurement(ue_id=ue_id)
        nr_meas = (regx_nr_meas.findall(ue_meas_disp))
        if (len(nr_meas) > 0) or (max_retry == 0):
            meas_id = regx_meas_id.findall(nr_meas[0])
            a4_meas_id = int(meas_id[0])
            logger.info('Detected A4 MeasId= {}'.format(a4_meas_id))
            break
    return a4_meas_id


def disp_ue_measurement(ue_id):
    wts = BuiltIn().get_library_instance('ute_wtssim')
    ue_meas_disp = wts.execute_egate_command(
        cmd='ue_meas_disp id={}'.format(ue_id), pass_regexp='Measurement Configuration', timeout='5')
    ue_meas_disp = ue_meas_disp.replace("\r\n", " ")
    return ue_meas_disp


def check_ping_delay(host_ip):
    try:
        output = subprocess.check_output(['ping', '-c', '20', '-q', host_ip])
        output = output.decode('utf8')
        print(output)
        stat = re.search(r'(\d+\.\d+/){3}\d+\.\d+', output).group(0)
        rtt_avg = re.findall(r'\d+\.\d+', stat)[1]
        rtt_avg = float(rtt_avg)
        print(rtt_avg)
    except subprocess.CalledProcessError:
        rtt_avg = 999999
    return rtt_avg


def calculate_value_margin(margin, value):
    margin = float(margin.strip('%')) / 100
    return float(value) * (1 - margin), float(value) * (1 + margin)


def ping_delay_should_be_similar_for_nrdc_and_legacy_ue(nrdc_ip, legacy_ip, margin='50%'):
    delay_nrdc = check_ping_delay(host_ip=nrdc_ip)
    delay_legacy = check_ping_delay(host_ip=legacy_ip)
    margin_range = calculate_value_margin(margin, delay_legacy)

    if (delay_nrdc < min(margin_range)) or (delay_nrdc > max(margin_range)):
        raise ExecutionFailed(
            message="Ping delay for nrdc ue {} is not similar to ping delay for legacy ue {}".format(
                delay_nrdc, delay_legacy), continue_on_failure=True)


def verify_ul_throughput_leg(ue_id='1', cell_group='MCG', scell='0', expected_ul='10'):
    ta5g_ue_wts = BuiltIn().get_library_instance('ute_wtssim')
    ue_stats_nr_output = ta5g_ue_wts.execute_egate_command(
        cmd='ue_stats_nr id={} cell_group={} type=pusch scell={}'.format(ue_id, cell_group, scell),
        pass_regexp='CellIndex-', timeout='150')
    OperatingSystem().create_file(path='/tmp/ul_stats.txt', content=ue_stats_nr_output)
    average_ul_tput = OperatingSystem().run("cat /tmp/ul_stats.txt | grep -m 1 'CellIndex-' | awk '{print $8}'\n")
    logger.info('average_ul_tput= {}'.format(average_ul_tput))
    BuiltIn().should_be_true(float(average_ul_tput) >= float(expected_ul))
