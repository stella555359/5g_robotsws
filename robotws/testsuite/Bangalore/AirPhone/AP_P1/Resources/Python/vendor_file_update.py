import os
import xml.etree.ElementTree as ET
from datetime import datetime
import shutil
from taf.sbts.oam.coam.admin import admin
import functools
from retrying import retry
from taf.transport.ssh.exceptions import ConnectFailedError
import time
from robot.api import logger

admin = admin()


class ADETTimeout(Exception):
    pass


class RadioNotInstalled(Exception):
    pass


class CommisioningFailure(Exception):
    pass


def retry_if_ap_failed_startup(exception):
    return isinstance(exception, ADETTimeout) or isinstance(exception, RadioNotInstalled)\
           or isinstance(exception, ConnectFailedError)\
           or isinstance(exception, CommisioningFailure)


def timed_wait_task(timeout, step_time):
    def inner(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            initial_time = current_time = time.time()
            while (current_time - initial_time) < timeout:
                if func(*args, **kwargs):
                    return True
                time.sleep(step_time)
                current_time = time.time()
            logger.error('{} Got timedout waiting for {}'.format(func.__name__,
                                                                 timeout))
            return False
        return wrapper
    return inner


def gnb_admin_connection(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        try:
            admin.connect_to()
            return func(*args, **kwargs)
        finally:
            admin.teardown()
    return wrapper


@gnb_admin_connection
@timed_wait_task(timeout=300, step_time=30)
def check_gnb_radio_online_state(timeout=600):
    logger.error('Checking If Radio State is Online.')
    rmod = admin.get_bts_info()['radioModules']['rmod']
    if rmod:
        print('Radio State output from ADMIN API is {}'.format(rmod[0]['status']['operationalState']))
        if rmod[0]['status']['operationalState'] == 'enabled':
            logger.error('Radio State is {}'.format(rmod[0]['status']['operationalState']))
            return True
        return False


@gnb_admin_connection
@timed_wait_task(timeout=300, step_time=30)
def check_gnb_state_configured(timeout=600):
    logger.error('Checking If GNB State is ready.')
    bts_state = admin.get_mrbts_state()
    print('BTS State from ADMIN API is {}'.format(bts_state))
    if bts_state in ['Configured', 'OnAir', 'IntegratedToRan']:
        logger.error('BTS State is {}'.format(bts_state))
        return True
    return False


@gnb_admin_connection
def reboot_gnb_with_admin():
    logger.info('Reboot via the ADMIN CLI.')
    output = admin.reset(reset_coverage='Site', wait_for_reconnection=True, timeout=600)
    return


@gnb_admin_connection
def get_vendor_file(download_filepath):
    vendor_download_response = admin.download_vendor_file(download_filepath)
    print("vendor_download_response:", vendor_download_response)


@gnb_admin_connection
def disable_bbpool_feature(name="bbppol_update"):
    mrbts_id = "".join(["MRBTS", "-", str(admin.get_bts_info()['mrbtsID'])])
    nrbts = admin.get_managed_objects('NRBTS_A')
    nrbts_id = "/".join([mrbts_id, nrbts[0]['distName'].split('/')[-1].replace("_A", "")])
    delta_store = admin.create_delta(delta_id=name)
    print("delta store details", delta_store)
    params_list = ["actBbPoolTddFr1", "actBbPoolTddFr1AlgEnh", "actLargeBbPoolTddFr1"]
    for param_name in params_list:
        admin.append_parameter_update_to_delta(delta_id=name, dist_name=nrbts_id,
                                               parameter=param_name,
                                               value="false")
    delta_value = admin.get_delta(delta_id=name)
    print("deta json value:", delta_value)
    for _ in range(10):
        try:
            output = admin.perform_delta_recommissioning(delta_file=delta_value,
                                                         skip_parameter_relation_errors=True,
                                                         should_activate=True)
            print(f"Delta commissioning output: {output}")
            return
        except Exception as e:
            print(f"ADMIN API Delta Commissioning failed due to: {repr(e)}")
            time.sleep(240)
    raise CommisioningFailure("Delta Commisioning Failed")


def update_vendor_file(file_path, param_updates):
    # Parse the XML file
    ns = "raml21.xsd"
    ET.register_namespace('', ns)
    tree = ET.parse(file_path)
    root = tree.getroot()
    # Find and update the parameters
    path = "{ns}cmData//{ns}managedObject[@class='NRBTS']//{ns}p[@name='{name}']"
    for param in param_updates.keys():
        param_list = tree.find(path.format(ns="{" + ns + "}", name=param))
        print("Before update the value at the xml file for {} : {}".format(param, param_list.text))
        param_list.text = param_updates[param]
        print("New value updated at the xml file for {} : {}".format(param, param_list.text))
    # Write the updated XML back to the file
    tree.write(file_path)


def download_update_and_upload_vendor_file_to_gnb(vendor_filepath='/home/ute'):
    original_vendor_filepath = os.path.join(vendor_filepath, 'vendor_original.xml')
    modified_vendor_filepath = os.path.join(vendor_filepath, 'vendor_modified.xml')
    print('downloading the vendor file')
    get_vendor_file(original_vendor_filepath)
    print('updating the vendor file')
    shutil.copyfile(original_vendor_filepath, modified_vendor_filepath)
    update_vendor_file(modified_vendor_filepath,
                       {'xEc': '14', 'betaEc': '13'})
    upload_vendor_file(modified_vendor_filepath)
#    print("Waiting before Delta commissioning")
#    time.sleep(240)
#    print("Disable BBPool Feature for eCPRI72e")
#    disable_bbpool_feature()


@gnb_admin_connection
def upload_vendor_file(modified_vendor_filepath, scf_path="/home/ute/", scf_timeout=60):
    build_id = os.environ.get("BUILD_NUMBER", "0")
    scf_file_name = f"scf_{build_id}.xml"
    scf_dir_path = admin.get_current_scf_file(local_dir_path=scf_path,
                                              file_name=scf_file_name,
                                              timeout=scf_timeout)
    for _ in range(10):
        try:
            print('uploading the vendor file')
            vendor_output = admin.set_vendor_file(modified_vendor_filepath)
            print(f"Vendor file upload output: {vendor_output}")
            time.sleep(180)
            commision_output = admin.perform_commissioning(scf_file=scf_dir_path,
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True, timeout=300)
            print(f"Full commissioning output {commision_output}")
            return
        except Exception as e:
            print(f"ADMIN API Commissioning failed due to {repr(e)}")
            time.sleep(60)
    raise CommisioningFailure("Commisioning Failed")


@gnb_admin_connection
def download_scf_and_perform_full_commissioning(scf_path):
    print('downloading the scf file')
    build_id = os.environ.get("BUILD_NUMBER", "0")
    scf_file_name = f"scf_{build_id}.xml"
    scf_dir_path = admin.get_current_scf_file(local_dir_path=scf_path,
                                              file_name=scf_file_name)
    for _ in range(10):
        try:
            commision_output = admin.perform_commissioning(scf_file=scf_dir_path,
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True, timeout=300)
            print(f"Full commissioning output {commision_output}")
            return
        except Exception as e:
            print(f"ADMIN API Commissioning failed due to {repr(e)}")
            time.sleep(120)
    raise CommisioningFailure("Commisioning Failed")


@retry(retry_on_exception=retry_if_ap_failed_startup, stop_max_attempt_number=5,
       wait_fixed=5000, wrap_exception=False)
def check_gnb_configure_and_radio_online():
    print('checking gnb state configure')
    for _ in range(10):
        if check_gnb_state_configured():
            break
        time.sleep(15)
    if not check_gnb_state_configured():
        print("gNB has not come to configured state")
    print('checking radio state online')
    for _ in range(10):
        if check_gnb_radio_online_state():
            break
        time.sleep(15)
    if not check_gnb_radio_online_state():
        raise RadioNotInstalled()


def modify_upload_vendor_file_in_gnb_and_commission_gnb(vendor_file_folder='/home/ute'):
    download_update_and_upload_vendor_file_to_gnb(vendor_filepath=vendor_file_folder)
#    download_scf_and_perform_full_commissioning(scf_path=vendor_file_folder)
    check_gnb_configure_and_radio_online()


if __name__ == "__main__":
    print("starting the script")
    modify_upload_vendor_file_in_gnb_and_commission_gnb()
    print("script completed")
