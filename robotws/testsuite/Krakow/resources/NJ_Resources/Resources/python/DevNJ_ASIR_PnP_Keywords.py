import os
import re
import logging
import shutil
import time
from taf.ul.sc.asimgr import AsiMgr
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


@load_moler_configuration_from_tl()
def collect_asir_commission_file(output_dir, path_to_scf=None):
    """
    Collect SCF file from HUB, store it into output_dir, Rename it to ASiR_PnP_${plan_id}.xml
    :param output_dir: destination directory for stored asir commissioning file
    :param path_to_scf: current commissioning file path, if None then download commissioning from device
    :return path to updated SCF file
    """
    plan_id = ''
    asirmgr = AsiMgr(autoconnect=True)
    if path_to_scf is None:
        path_to_scf = asirmgr.collect_commissioning_file(output_dir)

    if path_to_scf:
        logging.info("Successfully get file : {0}".format(path_to_scf))
        with open(path_to_scf, 'r') as scf_handler:
            for line in scf_handler.readlines():
                result = re.search("cmData id=\"(\\S+)\"\\s+scope.*", line)
                if result is not None:
                    plan_id = result.group(1)

    if plan_id:
        logging.info("plan_id of the commissioning file is : {0}, rename it now.".format(plan_id))
        os.rename(path_to_scf, os.path.join(output_dir, "ASiR_PnP_{0}.xml".format(plan_id)))
        if os.path.exists(os.path.join(output_dir, "ASiR_PnP_{0}.xml".format(plan_id))):
            return os.path.join(output_dir, "ASiR_PnP_{0}.xml".format(plan_id))


def check_asir_pnp_autoconnection_start(file_name, remote_dir):
    """
    Check ASIR PnP Auto connection start string appear in syslog or not
    :param file_name: syslog file name
    :param remote_dir: directory of syslog
    :return True if success, False otherwise
    """
    if os.path.exists(os.path.join(remote_dir, file_name)):
        logging.info("Make one copy of syslog file to /tmp directory.")
        shutil.copy(os.path.join(remote_dir, file_name), '/tmp/')
        with open(os.path.join('/tmp', file_name), 'r') as file_handler:
            for line in file_handler.readlines():
                if 'Audit Handler status: There was "1" successful' in line:
                    return True
        return False


def Multiple_check_autoconnection_start(wait_count, time_interval, file_dir='/tmp/btslog2'):
    """
    Check ASIR PnP Auto connection start appear in syslog or not within wait_count times restriction
    :param wait_count: times to check whether the ASIR PnP is started or not
    :param time_interval: time to sleep
    :param file_dir: directory of syslog
    :return Started if found, NotStarted otherwise
    """
    file_name = ''
    autoConn_flag = 'NO'
    for name in os.listdir(file_dir):
        if name.startswith('SYSLOG') and name.endswith('LOG'):
            logging.info("syslog file name is : {0}".format(name))
            file_name = name
    if file_name:
        for index in range(int(wait_count)):
            if check_asir_pnp_autoconnection_start(file_name, file_dir):
                autoConn_flag = 'YES'
                break
            else:
                logging.info("{0} - ASIR PnP Auto connection is not started, wait a while...".format(index))
                time.sleep(int(time_interval))

        if autoConn_flag == 'YES':
            logging.info("ASIR PnP Auto Connection has started.")
            return 'Started'
        else:
            logging.info("Sorry, ASIR PnP Auto Connection is not started within time restriction.")
            return 'NotStarted'


def remove_special_characeters(content):
    """change \x00 to none
    Change History:
    Change content = content.decode('UTF-8', 'ignore').strip().strip(b'\x00'.decode()) to
    content = content.strip().strip(b'\x00'.decode()) when do python2->3 adaptation
    """
    content = content.strip().strip(b'\x00'.decode())
    return content


if __name__ == '__main__':
    content = remove_special_characeters('DH203362897\x00')
    print(content)
