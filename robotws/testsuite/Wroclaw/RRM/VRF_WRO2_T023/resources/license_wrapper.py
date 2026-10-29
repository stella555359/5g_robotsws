from taf.sw.qualcomm.license.interface import license
import zipfile
import os


def get_5g_qxdm_and_qcat_license(pc_ip, pc_login, pc_password, username, password):
    '''
    Keyword based on testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/ue_logs/ue_logs.py
    :param pc_ip: UE_PC IP Address
    :param pc_login: UE_PC Username
    :param pc_password: UE_PC Password
    :param username: username that is provided in License Keeper
    :param password: password that is provided in License Keeper - it could be random
    string if user is logged on QPM.
    '''
    launcher = {'host': pc_ip,
                'path': "/cygdrive/c/QPM_LK3",
                'user': pc_login,
                'password': pc_password}
    lk = license()
    lk.setup(launcher=launcher)
    lk.login(username=username, password=password)
    lk.get_licence_qxdm_5g()
    lk.get_licence_qcat_5g()


def release_5g_qxdm_and_qcat_license(pc_ip, pc_login, pc_password):
    '''
    Keyword based on testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/ue_logs/ue_logs.py
    :param pc_ip: UE_PC IP Address
    :param pc_login: UE_PC Username
    :param pc_password: UE_PC Password
    '''
    launcher = {'host': pc_ip,
                'path': "/cygdrive/c/QPM_LK3",
                'user': pc_login,
                'password': pc_password}
    lk = license()
    lk.setup(launcher=launcher)
    lk.release_licence_qxdm_5g()
    lk.release_licence_qcat_5g()
    lk.logout()
    lk.teardown()


def unzip_and_return_txt_file_path(misc_log_directory):
    extract_path = os.path.dirname(misc_log_directory) + '/unzipped/'
    with zipfile.ZipFile(misc_log_directory, 'r') as zip_ref:
        extracted = zip_ref.namelist()
        zip_ref.extractall(extract_path)
    txt_file_index = [i for i, word in enumerate(extracted) if word.endswith('txt')][0]
    txt_file = extract_path + extracted[txt_file_index]
    return txt_file
