import re
import subprocess
from robot.errors import ExecutionFailed
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from robot.api import logger
import time
import csv


def check_if_next_tx_contains_fmc(bip_csv_filepath):
    passed = False
    index = 0
    fmc = 0
    next_tx = None
    with open(bip_csv_filepath, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            if row['pdcp-nr.fmc']:
                # Sprawdź czy fmc jest listą i pobierz pierwszy element
                fmc_value = row['pdcp-nr.fmc']
                if ',' in fmc_value:
                    fmc_list = fmc_value.split(',')
                    fmc = fmc_list[0]
                else:
                    fmc = fmc_value
                fmc_index = index
            if fmc != 0 and index == fmc_index + 1:
                next_tx = row['pdcp-nr.seq-num']
            index += 1

    if next_tx:
        next_tx_list = next_tx.split(',')
        print(fmc)
        print(next_tx_list)
        for sn in next_tx_list:
            if int(sn) == int(fmc):
                passed = True
                break
    if not passed:
        raise Exception("Process timed out")


def send_event_measurement(ue_id='1', a4_params='phycell_id=52 nrsrp_nr=60 event=A4'):
    meas_id = check_a4_measurement_id(ue_id)
    wts = BuiltIn().get_library_instance('ute_wtssim')
    wts.execute_egate_command(
        cmd='ue_measurement_send id={} meas_id={} {}'.format(ue_id, meas_id, a4_params))


def check_a4_measurement_id(ue_id):
    pat_nr_meas = ('{} MEASUREMENT IDENTITIES:.*MeasId  ObjectId  ReportCfgId.*\\d+'.format(ue_id))
    pat_meas_id = ('\\d+')
    regx_nr_meas = re.compile(pat_nr_meas, re.MULTILINE)
    regx_meas_id = re.compile(pat_meas_id)

    ue_meas_disp = disp_ue_measurement(ue_id=ue_id)
    nr_meas = (regx_nr_meas.findall(ue_meas_disp))

    if len(nr_meas) == 0:
        time.sleep(12)
        ue_meas_disp = disp_ue_measurement(ue_id=ue_id)
        nr_meas = (regx_nr_meas.findall(ue_meas_disp))
    meas_id = regx_meas_id.findall(nr_meas[0])
    a4_meas_id = int(meas_id[0])
    logger.info('Detected A4 MeasId= {}'.format(a4_meas_id))
    return a4_meas_id


def disp_ue_measurement(ue_id):
    wts = BuiltIn().get_library_instance('ute_wtssim')
    ue_meas_disp = wts.execute_egate_command(
        cmd='ue_meas_disp id={}'.format(ue_id), pass_regexp='Measurement Configuration', timeout='5')
    ue_meas_disp = ue_meas_disp.replace("\r\n", " ")
    return ue_meas_disp
