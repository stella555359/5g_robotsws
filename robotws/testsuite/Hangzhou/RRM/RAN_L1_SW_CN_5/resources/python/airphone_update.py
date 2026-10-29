# coding=utf-8

import re
import os
import time
import requests
import argparse
import subprocess
import xml.etree.ElementTree as ET
from robot.api import logger
from taf.sbts.oam.coam.admin import admin
import taf.wts.runner as wtsrunner
import taf.transport.ssh as SSH

api = admin()


def cmd_execution(cmd):
    logger.console('-> ' + cmd)
    output = subprocess.Popen(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out = output.stdout.read().decode(encoding='utf-8', errors='ignore')
    err = output.stderr.read().decode(encoding='utf-8', errors='ignore')
    if err:
        logger.console('<- [ERROR]Failed: {}'.format(err))
    else:
        logger.console('<- ' + str(out))
    return str(out).strip() if out else None


def get_airphone_versions_from_wft():
    access_key = 'mzwMktgLPhlMbaBy9ckoBlJA3vt458S8EeBsOJue'
    items = 20

    wft_url = (("https://wft.int.net.nokia.com:8091/TOOLS/api/v1/build.json?access_key={}&view[items]={}\
    &view[sorting_field]=created_at&view[sorting_direction]=DESC&view[columns][][id]=deliverer.project.full_path\
    &view[columns][][id]=deliverer.title&view[columns][][id]=version&view[columns][][id]=branch.title\
    &view[columns][][id]=state&view[columns][][id]=planned_delivery_date&view[columns][][id]=common_links\
    &view[columns][][id]=build_reasons&view[view_filters_attributes][876642176920316][column]=component\
    &view[view_filters_attributes][876642176920316][operation]=eq\
    &view[view_filters_attributes][876642176920316][value][]=airphone\
    &view[view_filters_attributes][50883049757869][column]=state\
    &view[view_filters_attributes][50883049757869][operation]=eq\
    &view[view_filters_attributes][50883049757869][value][]=RELEASED\
    &view[view_filters_attributes][23001088109388][column]=state\
    &view[view_filters_attributes][23001088109388][operation]=eq\
    &view[view_filters_attributes][23001088109388][value][]=RELEASED_WITH_RESTRICTIONS&")
               .replace('    ', '').format(access_key, items))
    proxy = {"https": "http://10.158.100.8:8080"}
    result = requests.get(wft_url, proxies=proxy, verify=False, timeout=90)
    logger.console(f"wft_url: {wft_url}")
    if result.status_code != 200:
        logger.console(wft_url)
        raise Exception("REQUEST_FAIL")
    BUILD_INFO = []
    logger.console('-'*55)
    count = 1
    for item in result.json()["items"]:
        # "RELEASED" or "RELEASED_WITH_RESTRICTIONS" build
        logger.console(f"{item}")
        if item['state'] in ("RELEASED", "RELEASED_WITH_RESTRICTIONS"):
            latest_build = item['version'].strip('airphone_')
            logger.console(
                'Airphone version        :  {}'.format(latest_build))
            logger.console('branch.title            :  {}'.format(
                item['branch.title']))
            logger.console(
                'QT test state           :  {}'.format(item['state']))
            logger.console('Not released reasons    :  {}'.format(
                item['build_reasons']))
            logger.console('Planned Delivery_date   :  {}'.format(
                item['planned_delivery_date']))
            break
        else:
            count = count + 1
            if count == items:
                raise Exception(
                    f'[ ERROR ]No RELEASED / RELEASED_WITH_RESTRICTIONS in the latest {items} builds.')
            continue
    return latest_build


def get_esimmode_version(link):
    versions = cmd_execution("curl -u yughou:Nokia202502@ {}".format(link))
    patter_e = r'esimmode_WTS_\S+_sandybridge.tar.bz2'
    esimmode = re.search(patter_e, str(versions)).group()
    return esimmode.split('>')[-1] if esimmode else None


def uncompress_esimmode(package):
    logger.console('[ Uncompress ... ]\n{} -->'.format(package))
    path = package.strip('.tar.bz2')
    logger.console(path)
    if os.path.exists(path):
        cmd_execution("tar -xvf {} -C {}".format(package, path))
    else:
        cmd_execution("mkdir {} && tar -xvf {} -C {}".format(path, package, path))
    if os.path.exists('/opt/iphy/latest'):
        cmd_execution("rm /opt/iphy/latest")
    else:
        logger.console('[INFO] /opt/iphy/latest is NOT exists.')
    cmd_execution("cd /opt/iphy/; ln -sf {} latest".format(path))


def remove_old_esimmode(path):
    ln = cmd_execution("ls -l {} | grep '^l'".format(path))
    all_files = cmd_execution("find {} -maxdepth 1 -print".format(path))
    all_files_list = all_files.split('\n')
    if ln:
        latest = re.search(r'latest.*', ln).group()
        logger.console(f'[INFO] {latest}')
        latest_dir = latest.strip().split('-> ')[-1].strip().replace('//', '/')
        remove_files_list = [
            i for i in all_files_list[1:]
            if i not in {latest_dir, "/opt/iphy/latest"}
        ]
        print(f"remove files list:{remove_files_list}")
        for file in remove_files_list:
            cmd_execution("rm -rf {}".format(file))
    else:
        for file in all_files_list[1:]:
            cmd_execution("rm -rf {}".format(file))


def get_TargetBD(local_path):
    execution_and_wait('ping -c 5 192.168.255.1',
                       'received, 0% packet loss', 180)
    cmd_BD = "sshpass -p 'oZPS0POrRieRtu' scp toor4nsn@192.168.255.1:/rom/TargetBD_SBTS*.xml {}".format(
        local_path)
    cmd_execution(cmd_BD)
    find = cmd_execution(
        'find {} -name TargetBD*.xml -mmin -1'.format(local_path))
    return find.strip().split('\n') if find else None


def get_iphy_xml_from_airphone(local_path, ffs='run'):
    ip = '192.168.200.1'
    usr = 'toor4nsn'
    pwd = 'oZPS0POrRieRtu'
    execution_and_wait('ping -c 5 192.168.200.1',
                       'received, 0% packet loss', 180)
    cmd_iphy = "sshpass -p {} scp {}@{}:/ffs/{}/simmode/iphy.xml {}/iphy_bk.xml".format(
        pwd, usr, ip, ffs, local_path)
    cmd_execution(cmd_iphy)
    find = cmd_execution('find {} -name iphy*.xml -mmin -1'.format(local_path))
    return find.strip().split('\n') if find else None


def get_iphy_xml_from_local(source_path, target_path):
    cmd_iphy = 'cp {}/iphy*.xml {}'.format(source_path, target_path)
    cmd_execution(cmd_iphy)
    find = cmd_execution('find {} -name iphy*.xml'.format(target_path))
    return find.strip().split('\n') if find else None


def parse_xml(xml_file): return ET.parse(xml_file)


def get_SWVersion_from_TargetBD(targetBD):
    hwResource_dict = dict()
    root_bd = parse_xml(targetBD).getroot()
    for element in root_bd:
        if element.tag == 'hwResource':
            tmp_list = list()
            tmp_list.append(element.attrib['resourceSWVersion'])
            for swFileKey in element:
                tmp_list.append(swFileKey.text)
            hwResource_dict[element.attrib['resourceBuildKey']] = tmp_list
        else:
            pass
    return hwResource_dict


def update_iphy_xml(iphy_xml, hwResource_dict):
    root_iphy = parse_xml(iphy_xml)
    for RE in root_iphy.getroot()[1][0]:
        for items in RE:
            if items.tag == 'identity':
                for item in items:
                    if item.tag == 'cardName':
                        print('[ %s ]' % item.text)
                        rmod = 'LTX_' + item.text
                    elif item.tag == 'bldVersion':
                        try:
                            new_version = hwResource_dict[rmod]
                        except KeyError:
                            rmod += '_E1'
                        print('%-28s -->  %-28s' %
                              (item.text, hwResource_dict[rmod][0]))
                        item.text = hwResource_dict[rmod][0]
                    else:
                        pass
            elif items.tag == 'soap-config':
                for item in items:
                    if item.tag == 'software':
                        tmp_item_list = list()
                        for file in item:
                            for element in file:
                                if element.tag == 'name':
                                    print('%-28s -->  %-28s' %
                                          (element.text, hwResource_dict[rmod][1]))
                                    element.text = hwResource_dict[rmod][1]
                                elif element.tag == 'version':
                                    # print('%-28s -->  %-28s' % (element.text, hwResource_dict[rmod][0]))
                                    element.text = hwResource_dict[rmod][0]
    root_iphy.write(iphy_xml)


def update_iphy_rmod_buildversion(local_path, iphy_xml):
    targetBD = get_TargetBD(local_path)[0]
    hwResource_dict = get_SWVersion_from_TargetBD(targetBD)
    update_iphy_xml(iphy_xml, hwResource_dict)
    return iphy_xml


def upload_iphy_xml_to_airphone(iphy_xml):
    ip = '192.168.200.1'
    user = 'toor4nsn'
    pwd = 'oZPS0POrRieRtu'
    path = '/ffs/run/simmode'
    execution_and_wait('ping -c 5 192.168.200.1',
                       'received, 0% packet loss', 180)
    scp_run = "sshpass -p {} scp {} {}@{}:{}/auto_iphy.xml".format(
        pwd, iphy_xml, user, ip, path)
    ln_run = "sshpass -p {} ssh {}@{} ln -sf {}/auto_iphy.xml {}/iphy.xml".format(
        pwd, user, ip, path, path)
    cmd_execution(scp_run)
    cmd_execution(ln_run)


def download_yaft(yaft_path):
    git_yaft = "git clone ssh://gerrit-mn-essl1.int.net.nokia.com:29418/MN/RPSW/LFS/build/yaft"
    svn_link = "https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk"
    svn_yaft = "svn co --username ca_ute_test --password utetest {}".format(
        svn_link)
    cmd_execution("rm -rf {}".format(yaft_path))
    cmd_execution("{} {}".format(svn_yaft, yaft_path))
    yaft_version = cmd_execution(
        "python {}/yaft.py --version".format(yaft_path))
    logger.console('[INFO]YAFT checkout: ' + yaft_version)


def sw_update_via_yaft(ip, sw_package):
    cd_yaft = "cd /home/ute/BTS_T_YAFT; "
    input_pwd = 'echo oZPS0POrRieRtu | python '
    # yaft upgrade airphone and reboot
    yaft_ap = "yaft.py --ask_for_password -i {} -z {} -K --NO_fpga_update --NO_yupper;".format(
        ip, sw_package)
    # yaft upgrade gNB and reboot
    yaft_gnb = "yaft.py -i {} -z {} --ask_for_password".format(ip, sw_package)
    update = yaft_ap if '192.168.200.1' == ip.strip() else yaft_gnb
    module = 'Airphone' if '192.168.200.1' == ip.strip() else 'GNB'
    logger.console('-' * 52 + ' {} '.format(module) + '-' * 52)
    logger.console('[INFO]SW upgrading ...\n{}'.format(update))
    execution_and_wait('ping -c 5 {}'.format(ip),
                       'received, 0% packet loss', 180)
    process = subprocess.Popen(
        cd_yaft + input_pwd + update, stdout=subprocess.PIPE, shell=True).stdout.read()
    logger.console(process)


def gnb_upgrade_via_webui(bts_host, build_file):
    assert os.path.isfile(
        build_file), '[ERROR]Not Found: {}'.format(build_file)
    build_version = build_file[build_file.rfind('SBTS'):].strip('.zip')
    result = os.popen('ping -c 5 {}'.format(bts_host)).read().strip()
    print(result)
    if '100% packet loss' in result:
        return ('Not Pingable or wrong bts ip.', 'MRBTS-?')
    try:
        connection = api.setup_admin(bts_host, name='upgrade')
        btsinfo = connection.get_bts_info()
        bts_id = btsinfo['mrbtsID']

        faults = connection.get_active_alarms()
        logger.console(
            '\n[MRBTS-{}] Active Alarms before SW update ...\n'.format(bts_id) + '-' * 78)
        logger.console('| faultId%2s | faultName%40s  | severity\n' %
                       (' ', ' ') + '-' * 78)
        for fault in faults:
            logger.console('| %-9d | %-50s | %-5s' %
                           (fault['faultId'], fault['faultName'], fault['severity']))

        cur_build = connection.get_sw_version()
        logger.console(
            "\n[MRBTS-{}] SW updating ... ...\n".format(str(bts_id)) + '-'*(55+len(cur_build)))
        logger.console("[{}] Current Build Version    :    {}".format(
            current_time(), cur_build))
        logger.console("[{}] Upgrade Build Version    :    {}".format(
            current_time(), build_version))
        logger.console(
            "[{}] BTS upgrade              :    Starting".format(current_time()))
        connection.update_software(build_file, timeout=3000)
        logger.console(
            "[{}] BTS upgrade              :    Downloaded and activated".format(current_time()))
        time.sleep(90)
        logger.console(
            "[{}] Waiting BTS onair        :    Ongoing".format(current_time()))
        execution_and_wait('ping -c 5 {}'.format(bts_host),
                           '5 received, 0% packet loss')

        faults = connection.get_active_alarms()
        logger.console(
            '\n[MRBTS-{}] Active Alarms after SW update ...\n'.format(bts_id) + '-' * 78)
        logger.console('| faultId%2s | faultName%40s  | severity\n' %
                       (' ', ' ') + '-' * 78)
        for fault in faults:
            logger.console('| %-9d | %-50s | %-5s' %
                           (fault['faultId'], fault['faultName'], fault['severity']))

        # check admin api status_and_reconnection if needed
        api_status = os.popen('ps -ef | grep node').read()
        if bts_host not in api_status:
            logger.console('setup_admin reconnection ...')
            connection = api.setup_admin(bts_host, name='upgrade')
        isOnair = wait_bts_reach_status(
            connection, required_state='OnAir', timeout=900, sleep_time=30)
        assert isOnair, '[ERROR]BTS is NOT OnAir after upgraded.'
        new_build = connection.get_sw_version()
        return (None, 'MRBTS-{}'.format(bts_id))
    except Exception as e:
        logger.console(repr(e))
        return (repr(e), 'MRBTS-{}'.format(bts_id))
    finally:
        # UnboundLocalError: local variable 'connection' referenced before assignment
        # and api.teardown_admin before connection execute and assignment
        try:
            api.teardown_admin(connection)
        except UnboundLocalError as e:
            logger.console(repr(e))
            return ('Not Pingable or wrong bts ip', 'MRBTS-{}'.format(bts_id))


def execution_and_wait(command, pass_tag, timeout=60, sleep_time=20):
    start_time = time.time()
    while (time.time() - start_time) <= timeout:
        result = os.popen(command).read().strip()
        if pass_tag in result:
            break
        else:
            time.sleep(sleep_time)


def backup_configuration(connection, local_path):
    cur_scfc = connection.get_current_scf_file(
        local_path, file_name='scfc_backup.xml')
    gnb_swconfig = 'scp toor4nsn@192.168.255.1:/ffs/run/swconfig.txt {}/swconfig_gnb.txt'.format(
        local_path)
    ap_swconfig = 'scp toor4nsn@192.168.200.1:/ffs/run/swconfig.txt {}/swconfig_ap.txt'.format(
        local_path)
    cmd_execution(gnb_swconfig)
    cmd_execution(ap_swconfig)


def perform_commission(connection, local_path):
    scfc_local = cmd_execution(
        "find {} -name 'scf*.xml' | xargs ls".format(local_path))
    print(scfc_local)
    connection.perform_commissioning(scf_file=scfc_local)


def current_time(): return time.strftime("%Y-%m-%d %X", time.localtime())


def wait_bts_reach_status(connection, required_state='OnAir', timeout=60, sleep_time=30):
    start_time = time.time()
    isOnAir = False
    logger.console("BTS Status:\n" + '-'*86)
    while isOnAir or (time.time() - start_time) <= timeout:
        try:
            bts_status = connection.get_mrbts_state()
        except Exception as e:
            logger.console(repr(e))
            bts_status = 'Querying ... ...'
        if bts_status == required_state:
            logger.console('[{}] BTS proceduralState      :    {}'.format(
                current_time(), bts_status))
            isOnAir = True
            break
        else:
            logger.console('[{}] BTS proceduralState      :    {}'.format(
                current_time(), bts_status))
            time.sleep(sleep_time)
    return isOnAir


def wait_for_HW_ready(module, timeout=150, sleep_time=30):
    start_time = time.time()
    isReady = False
    while (time.time() - start_time) <= timeout:
        logger.console('[{}] HW status check ...'.format(current_time()))
        isReady = check_hw_status(module)
        if isReady:
            break
        else:
            time.sleep(sleep_time)
    assert isReady, '[{}][ERROR] HW is NOT ready.'.format(current_time())


def check_hw_status(module):
    assert module.lower() in (
        'ap', 'gnb'), "[ERROR] module should be 'ap'|'gnb'."
    ip = '192.168.255.1' if module.lower() == 'gnb' else '192.168.200.1'
    try:
        adet = cmd_execution(
            "sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 chk adet")
        return True if "failed : 0" in adet.strip().split('\n')[-1].strip() else False
    except Exception as e:
        logger.console(repr(e))
        return False


def setup_admin_with_retry(ip, name, max_retries=5, retry_interval=5):
    """
    Retry setup_admin until it succeeds or reaches the maximum number of retries.

    :param ip: The IP address to connect to.
    :param name: The name for the admin setup.
    :param max_retries: Maximum number of retries (default: 5).
    :param retry_interval: Time (in seconds) to wait between retries (default: 5).
    :return: The connection object if successful, or raises an exception.
    """
    for attempt in range(1, max_retries + 1):
        try:
            logger.console(f"[INFO] Attempt {attempt} to setup admin...")
            connection = api.setup_admin(ip, name=name)
            logger.console("[INFO] Setup admin successful.")
            return connection
        except Exception as e:
            logger.console(f"[WARNING] Setup admin failed: {e}")
            if attempt < max_retries:
                logger.console(f"[INFO] Retrying in {retry_interval} seconds...")
                time.sleep(retry_interval)
            else:
                raise Exception("[ERROR] Maximum retries reached. Setup admin failed.")


def teardown(connection):
    try:
        api.teardown_admin(connection)
    except UnboundLocalError as e:
        logger.console(repr(e))


def set_iphy_ip_route():
    cmd_execution('sudo ip addr add 10.0.2.1/24 dev eth4')
    for ip in range(121, 156):
        cmd_execution('sudo ip addr add 10.0.1.{}/24 dev eth4'.format(ip))
    for ip in range(90, 101):
        cmd_execution('sudo ip addr add 10.0.2.{}/24 dev eth4'.format(ip))
    for ip in range(9, 16):
        cmd_execution('sudo ip addr add 10.0.1.{}/24 dev eth3'.format(ip))
    for ip in range(100, 110):
        cmd_execution('sudo ip addr add 10.0.1.{}/24 dev eth3'.format(ip))


def restart_ute_wts(cfg_file):
    cmd_execution('sudo pkill edaemon; pkill egate')
    ssh_ute = SSH.ssh()
    ssh_ute.connect_to(hostname='127.0.0.1', username='ute',
                       password='L1PZ-hangzhou', alias='Wts')
    tmp_wtsrunner = wtsrunner.runner()
    tmp_wtsrunner.configure_wtsemu_edaemon(edaemon_ssh_alias='Wts', directory_path='/opt/iphy/latest',
                                           port='22222', sudo_password='ute')
    tmp_wtsrunner.configure_wtsemu_egate(egate_ssh_alias='Wts', directory_path='/opt/iphy/latest',
                                         port=20000, nostats=True)
    tmp_wtsrunner.start_wtsemu(egate_console_ip='127.0.0.1', egate_port=20000)
    tmp_wtsrunner.configure(cfg_file)
    tmp_wtsrunner.read_wtsemu_output_until_re(
        expected="SystemInformationBlockType", timeout=240)
    tmp_wtsrunner.enb_x2_link_up(enb=1, target=2)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Personal information')
    parser.add_argument('-xml', '--xml_update', dest='xml_update', type=bool, default=False,
                        help="if 'True', only update iphy.xml without gNB & airphone sw upgrade. default is 'False'.")
    parser.add_argument('-m', '--module', dest='module', type=str, default='all',
                        help="Defined the module will be sw upgraded. It should be gnb|ap|all. default is 'all'.")
    parser.add_argument('-v', '--version', dest='version', type=str, default='',
                        help="The specific version of airphone. Such as '4.0.25888'.\
                        default is null, it means latest version.")
    parser.add_argument('-s', '--minimal_required_state', dest='minimal_required_state', type=str, default='',
                        help="The minimal required status after gnb and airphone upgraded. default is ''.")
    parser.add_argument('-d', '--dir', dest='directory', type=str, default='/home/ute/Downloads/',
                        help="The directory to store the airphone package. defalut is '/home/ute/Downloads/'")
    parser.add_argument('-w', '--way', dest='sw_update_way', type=str, default='webui',
                        help="the way of sw update, webui | yaft. default is by webui.")
    args = parser.parse_args()

    assert args.module.lower() in (
        'gnb', 'all', 'ap'), "[ERROR]{} should be gnb|all|ap".format(args.module)

    iphy_path = r'/opt/iphy/'
    yaft_path = r'/home/ute/BTS_T_YAFT/'
    link_root = "https://artifactory-hz1.ext.net.nokia.com/artifactory/mnp5g-airphone-ci-gen-local/Airphone/"
    cfg_repository = r'/home/ute/Downloads/CFG_REPO/'

    cmd_execution('pkill node')
    connection = setup_admin_with_retry('192.168.255.129', name='admin')

    if not os.path.isdir(os.path.join(args.directory, 'CFG_BACKUP')):
        os.mkdir(os.path.join(args.directory, 'CFG_BACKUP'))
    else:
        cmd_execution(
            "cd {}; rm -rf *".format(os.path.join(args.directory, 'CFG_BACKUP')))
    if args.minimal_required_state:
        logger.console('[INFO]Configurations backup is NOT needed.')
        local_path = cfg_repository
        cfg_file = cmd_execution(
            'find {} -name *.cfg | xargs ls'.format(local_path))
        iphy_xml_list = get_iphy_xml_from_local(
            local_path, os.path.join(args.directory, 'CFG_BACKUP'))
    else:
        backup_configuration(connection, os.path.join(
            args.directory, 'CFG_BACKUP'))
        local_path = os.path.join(args.directory, 'CFG_BACKUP')
        iphy_xml_list = get_iphy_xml_from_airphone(
            os.path.join(args.directory, 'CFG_BACKUP'), ffs='run')
    assert iphy_xml_list, '[ERROR]Failed to get iphy*.xml from airphone or local.'

    if args.xml_update:
        iphy_xml = update_iphy_rmod_buildversion(os.path.join(
            args.directory, 'CFG_BACKUP'), iphy_xml_list[0])
        upload_iphy_xml_to_airphone(iphy_xml)
        cmd_execution(
            "sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 'system-module-reboot'")
        time.sleep(10)
        execution_and_wait('ping -c 5 192.168.200.1',
                           'received, 0% packet loss', 180)
    else:
        download_yaft(yaft_path)
        if args.module.lower() in ['all', 'gnb']:
            gnb_package = cmd_execution(
                "find {} -name 'SBTS*.zip' -ctime -1 | xargs ls".format(args.directory))
            bts_build = gnb_package.split('\n')[-1] if gnb_package else None
            if bts_build:
                # gNB sw upgrade via yaft/webui
                if args.sw_update_way == 'webui':
                    gnb_upgrade_via_webui('192.168.255.129', bts_build)
                elif args.sw_update_way == 'yaft':
                    sw_update_via_yaft('192.168.255.129', bts_build)
                else:
                    raise Exception(
                        f'[ ERROR ] Skipped to upgrade bts, because {args.sw_update_way} is NOT suppoted.')
                execution_and_wait('ping -c 20 192.168.255.1',
                                   'received, 0% packet loss', 180)
                # update iphy.xml and reboot airphone during gnb upgrading only
                iphy_xml = update_iphy_rmod_buildversion(os.path.join(
                    args.directory, 'CFG_BACKUP'), iphy_xml_list[-1])
                upload_iphy_xml_to_airphone(iphy_xml)
                wait_for_HW_ready(module='gnb', timeout=300, sleep_time=30)
                cmd_execution(
                    'scp {}/swconfig_gnb.txt toor4nsn@192.168.255.1:/ffs/run/swconfig.txt'.format(local_path))
                cmd_execution(
                    'sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 crasign /ffs/run/swconfig.txt')
                if args.sw_update_way == 'yaft':
                    # perform_commission(connection, local_path)
                    logger.console(
                        '[INFO]GNB is rebooting after commission ...')
                else:
                    logger.console('[INFO]Skipped to perform commission.')
                if args.module.lower() in ['gnb']:
                    # reboot airphone
                    cmd_execution(
                        "sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 'system-module-reboot'")
                    time.sleep(10)
                    execution_and_wait(
                        'ping -c 5 192.168.255.1', 'received, 0% packet loss', 180)
                    execution_and_wait(
                        'ping -c 5 192.168.200.1', 'received, 0% packet loss', 180)
                    wait_bts_reach_status('Configured', 300)
            else:
                logger.console('[ERROR]No GNB build can be found in {}: {}.'.format(
                    args.directory, bts_build))
        if args.module.lower() in ['all', 'ap']:
            logger.console('><' * 55)

            version = args.version if args.version else get_airphone_versions_from_wft()
            logger.console('><' * 55)
            logger.console('[INFO]airphone version    :    {}'.format(version))
            logger.console('[INFO]AirScale downloading ... ')
            usr_pwd = '--user=yughou --password=Nokia202502@'
            link_version = link_root + version + '/'
            download_ap = "wget {} -t 0 -c {}/AirScale-{}.zip -P {}".format(usr_pwd,
                                                                            link_version,
                                                                            version,
                                                                            args.directory)
            process_airscale = subprocess.Popen(
                download_ap, stdout=subprocess.PIPE, shell=True).stdout.readline()
            logger.console(process_airscale)

            logger.console('[INFO]esimmode downloading ... ')
            esimmode = get_esimmode_version(link_version)
            download_wts = "wget {} -t 0 -c {}/{} -P {}".format(
                usr_pwd, link_version, esimmode, iphy_path)
            process_esimmode = subprocess.Popen(
                download_wts, stdout=subprocess.PIPE, shell=True).stdout.readline()
            logger.console(process_esimmode)

            if args.version:
                ap_package = cmd_execution("find {} -name 'AirScale-{}.zip' | xargs ls".format(args.directory,
                                                                                               args.version))
            else:
                ap_package = cmd_execution(
                    "find {} -name 'AirScale*.zip' -ctime -1 |xargs ls".format(args.directory))
            # Airphone sw upgrade via yaft
            sw_update_via_yaft('192.168.200.1', ap_package.split('\n')[-1])

            # backup wts*.cfg and copy in to newest esimmode directory.
            cfg_backup = 'cp /opt/iphy/latest/*.cfg {}'.format(
                os.path.join(args.directory, 'CFG_BACKUP'))
            cmd_execution(cfg_backup)
            uncompress_esimmode('{}{}'.format(iphy_path, esimmode))
            remove_old_esimmode(iphy_path)
            cfg_to_latest = 'cp {}/*.cfg /opt/iphy/latest/'.format(
                os.path.join(args.directory, 'CFG_BACKUP'))
            cmd_execution(cfg_to_latest)

            execution_and_wait('ping -c 5 192.168.200.1',
                               'received, 0% packet loss', 180)
            wait_for_HW_ready(module='ap', timeout=300, sleep_time=30)
            iphy_xml = update_iphy_rmod_buildversion(os.path.join(
                args.directory, 'CFG_BACKUP'), iphy_xml_list[-1])
            upload_iphy_xml_to_airphone(iphy_xml)
            cmd_execution(
                'scp {}/swconfig_ap.txt toor4nsn@192.168.200.1:/ffs/run/swconfig.txt'.format(local_path))
            cmd_execution(
                'sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 crasign /ffs/run/swconfig.txt')

            # reboot airphone
            cmd_execution(
                "sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 'system-module-reboot'")
            time.sleep(10)
            execution_and_wait('ping -c 5 192.168.200.1',
                               'received, 0% packet loss', 180)
    teardown(connection)

    if args.minimal_required_state.lower() == 'configured':
        wait_bts_reach_status('Configured', 300)
    elif args.minimal_required_state.lower() == 'onair':
        perform_commission(connection, local_path)
        logger.console('[INFO]GNB is rebooting after commission ...')
        set_iphy_ip_route()
        restart_ute_wts(cfg_file)
        wait_bts_reach_status('OnAir', 300)
    else:
        logger.console('[WRAN][{}] should be in ['', Configured, OnAir].'.format(
            args.minimal_required_state))
