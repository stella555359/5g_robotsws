import logging
import os
import csv
import io
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.connections import device_aliases as connection_names
from moler.device import DeviceFactory
from taf.rfrl.utilities.converters.converters import convert_pcap_to_csv as convert
from taf.rfrl.bts.devices.exceptions import SystemCheckFailure, MessageMissing
from taf.rfrl.utilities.transfer_files import download_files


@load_moler_configuration_from_tl()
def _download_capture(capture_file, dest_path, bts_id=0):
    download_files(local_dir=dest_path, remote_file=capture_file, device_name='GNB0_CU',
                   remote_dir='/home/robot', from_state='CPIF', remove_source_file=True, log_level='info')


def _verify_message(path, csv_path, msg):
    convert(path, csv_path)
    with io.open(csv_path, 'r', encoding='utf-8', newline='') as csvfile:
        csv_reader = csv.reader(csvfile, delimiter='\n')
        for row in csv_reader:
            if msg in row[0]:
                logging.info('Message {} found in: {}'.format(msg, row))
                return
    raise MessageMissing('Message {} not found in the capture {}'.format(msg, path))


@load_moler_configuration_from_tl()
def verify_chk_sys_cmd(bts_id=0, du_id=0):
    ip_ver = ''
    gnb = DeviceFactory.get_device(format(connection_names.ssh_bts_du.format('GNB', bts_id, du_id)))
    chk_sys = gnb.get_cmd(cmd_name='chk',
                          cmd_params={
                              "tags": ["sys"]
                          })
    output = chk_sys(timeout=60)['GROUPS']['syscontextconfig']
    for k in output.keys():
        if k.startswith('IP version'):
            ip_ver = k
            break
    if not ip_ver:
        raise SystemCheckFailure('The output does not contain the IP version parameter')

    logging.info('OUTPUT: {}'.format(ip_ver))
    if 'v6' not in ip_ver and output[ip_ver] != 'ok':
        raise SystemCheckFailure('IP version should be of v6.')


def verify_capture(capture_file, dest_path, msg, bts_id=0):
    _download_capture(capture_file=capture_file, dest_path=dest_path, bts_id=bts_id)
    pcap_file = os.path.join(dest_path, capture_file)
    csv_file = os.path.join(dest_path, 'capture.csv')
    _verify_message(pcap_file, csv_file, msg)


@load_moler_configuration_from_tl()
def verify_message_in_log(log_name, msg, bts_id=0):
    cu = DeviceFactory.get_device(format(connection_names.ssh_gnb_cu.format(bts_id)))
    cu.goto_state("CPUE")
    cat_cmd = cu.get_cmd(cmd_name="cat",
                         cmd_params={
                             "path": log_name,
                             "options": " | grep '{}'".format(msg)
                         })
    sudo = cu.get_cmd(cmd_name="sudo",
                      cmd_params={
                          "cmd_object": cat_cmd
                      })
    if not sudo()['LINES']:
        raise MessageMissing('Message {} not found in the log {}'.format(msg, log_name))
