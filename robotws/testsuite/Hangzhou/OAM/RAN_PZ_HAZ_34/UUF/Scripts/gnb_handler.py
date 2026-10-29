"""
Author: Yafang Chen
Contacts: yafang.chen@nokia-sbell.com
Description: deal with gNB information

"""
import time

from taf.gnb.oam.megazone_client import megazone_client
from taf.sbts.oam.coam.admin import admin as coam_admin
from taf.gnb.oam.megazone_client.exceptions import ConnectionError
from ute_common_admin.exception import AdminApiConnectionClosedException
from taf.transport.ssh import ssh
import re
import json
import datetime
# from time import sleep
import time
import sys
import warnings
from dateutil import rrule
import logging
import psutil

conn_store = {}
if sys.version_info[0] >= 3:
    warnings.filterwarnings("ignore", category=ResourceWarning)


def get_node_process_counter(bts_host):
    """returns the num of open processes"""
    counter = 0
    for process in psutil.pids():
        try:
            p = psutil.Process(process)
            if p.name() == 'node' and bts_host != "localhost" and "--bts-host={}".format(bts_host) in p.cmdline():
                counter += 1
        except psutil.NoSuchProcess:
            pass
    return counter


def wrap_retry_login_if_failed(retry=2, interval=5):
    def wrapper(func):
        def _retry_login_if_failed(cls, *args, **kwargs):
            retry_count = retry
            while True:
                try:
                    return func(cls, *args, **kwargs)
                except (ConnectionError, AdminApiConnectionClosedException) as e:
                    print('retry count: %s' % retry_count)
                    if retry_count == 0:
                        raise Exception(e.message)
                    cls.login()
                    retry_count -= 1
                    time.sleep(interval)

        return _retry_login_if_failed

    return wrapper


def wrap_check_connection_exist(func):
    def _check_connection_exist(connection='default', *args, **kwargs):
        obj = conn_store.get(connection)
        if obj:
            response = func(obj, *args, **kwargs)
            return response
        else:
            raise Exception('have not established the connection.')

    return _check_connection_exist


def get_sw_version_by_ssh(gnb_ip, username='toor4nsn', password='oZPS0POrRieRtu', format='abbreviation'):
    """
        - get sw version
        - format: abbreviation or full

        Example:
        | get_sw_version_by_ssh | 10.57.227.228 | format='abbreviation' |
        result: 11.800.604
        | get_sw_version_by_ssh | 10.57.227.228 | format='full' |
        result: 5G21A_GNB_0011_000800_000604
    """
    ssh_handler = ssh()
    ssh_handler.connect_to(gnb_ip, username, password)
    active_v_cmd = r"ls -al /ffs/run/ | grep -i TargetBD | grep -v .p7 | awk '{print $9}'"
    passive_v_cmd = r"ls -al /ffs/stb/ | grep -i TargetBD | grep -v .p7 | awk '{print $9}'"
    active_output = ssh_handler.execute(active_v_cmd)
    passive_output = ssh_handler.execute(passive_v_cmd)
    ssh_handler.disconnect()
    if format == 'abbreviation':
        active_v = __exact_version(active_output)
        passive_v = __exact_version(passive_output)
    elif format == 'full':
        active_v = active_output.strip('\r\n').lstrip('TargetBD_').rstrip('.xml')
        passive_v = passive_output.strip('\r\n').lstrip('TargetBD_').rstrip('.xml')
    else:
        raise Exception('wrong format')
    return active_v, passive_v


def __exact_version(origin_v):
    format_v = ''
    if origin_v:
        common_v = origin_v.find('SBTS')
        if common_v == -1:
            match_obj = re.match(r'.*?_0*(\d*)_0*(\d*)_0*(\d*)(.*)?\.xml', origin_v)
            if match_obj:
                format_v = '%s.%s.%s%s' % (match_obj.group(1) if match_obj.group(1) else '0',
                                           match_obj.group(2) if match_obj.group(2) else '0',
                                           match_obj.group(3) if match_obj.group(3) else '0',
                                           match_obj.group(4).rstrip('_').replace('_', '-')
                                           if match_obj.group(4) else '')
        else:
            match_obj = origin_v.strip('\r\n').lstrip('TargetBD_').rstrip('.xml').split('_')
            format_v = '%s_%s_%s_%s' % (match_obj[1], match_obj[2], match_obj[3], match_obj[4])
    return format_v


def login(ip, username="Nemuadmin", password="nemuuser", gnb_type='coam', connection='default', admin_api_log_dir='',
          release='SBTS22R3'):
    gnb_type = gnb_type.lower()
    if gnb_type in ['coam', 'enb']:
        handler = CoamHandler(ip, username, password, gnb_type, admin_api_log_dir=admin_api_log_dir, release=release)
    elif gnb_type == 'megazone':
        handler = MgzHandler(ip, username, password)
    else:
        raise Exception('params gnb_type is not correct. please set as coam or megazone.')
    conn_store[connection] = handler


def logout(connection='default'):
    obj = conn_store.get(connection)
    if obj:
        obj.logout()
        conn_store.pop(connection)


def reset_cache():
    for key, obj in conn_store.items():
        if obj:
            logging.warning('[LEAK WARNING] connection %s not released, will force disconnect' % key)
            try:
                obj.logout()
            finally:
                conn_store.pop(key)


@wrap_check_connection_exist
def get_sw_version(connection='default'):
    return connection.get_sw_version()


@wrap_check_connection_exist
def get_active_alarms(connection='default', except_alarms=''):
    total_alarms = connection.get_active_alarms()
    ret_alarms = []
    except_alarms = except_alarms.split(',')
    except_alarms = list(map(lambda x: x.strip(), except_alarms))
    for alarm in total_alarms:
        if not str(alarm['faultId']) in except_alarms:
            ret_alarms.append(alarm)
    return ret_alarms


@wrap_check_connection_exist
def get_parameters_by_class(class_name, connection='default'):
    return connection.get_parameters_for_all(class_name)


@wrap_check_connection_exist
def check_gnb_ru_status(connection='default'):
    return connection.get_frm_status()


@wrap_check_connection_exist
def check_gnb_abil_status(connection='default'):
    return connection.get_fbb_status()


@wrap_check_connection_exist
def check_gnb_cablink_status(connection='default'):
    return connection.get_cablink_status()


@wrap_check_connection_exist
def check_gnb_cablink_status(connection='default'):
    return connection.get_cablink_status()


@wrap_check_connection_exist
def check_gnb_asik_status(connection='default'):
    return connection.get_fsm_status()


@wrap_check_connection_exist
def collect_im_snapshot(connection='default', target_file_name='', timeout=60):
    return connection.collect_im_snapshot(target_file_name, timeout)


@wrap_check_connection_exist
def check_gnb_cell_status(connection='default', cell_type='nr'):
    """
    - cell_type can be 'lte', 'wcdma', 'gsm', 'nr'

    Example:
    | gnb_handler.check_gnb_cell_status | connection=gnb | lte |
    result:[{'name': 'cell-11', 'operationalState': 'Enabled', 'proceduralStatus': 'configured', 'availabilityStatus':
    'Online', 'administrativeState': 'Unlocked', 'isOnair': True}
    """
    return connection.get_cell_status(cell_type)


def _check_led_status(info):
    if info['operationalState'] == 'Enabled' and info['proceduralStatus'] == 'configured' \
            and info['availabilityStatus'] == 'Online' and info['administrativeState'] == 'Unlocked':
        return True
    else:
        return False


@wrap_check_connection_exist
def get_bts_status(connection='default'):
    return connection.get_bts_status()


@wrap_check_connection_exist
def get_history_alarms(connection='default', except_alarms=''):
    total_alarms = connection.get_historic_alarms()
    ret_alarms = []
    except_alarms = except_alarms.split(',')
    except_alarms = list(map(lambda x: x.strip(), except_alarms))
    for alarm in total_alarms:
        if not str(alarm['faultId']) in except_alarms:
            ret_alarms.append(alarm)
    return ret_alarms


@wrap_check_connection_exist
def get_rx_tx(connection='default'):
    return connection.get_cell_carrier()


@wrap_check_connection_exist
def get_bbmod_id(connection='default', rmod_id=''):
    return connection.get_bbmod_id_according_to_rmod(rmod_id)


@wrap_check_connection_exist
def force_sw_upgrade(connection='default', package_path="/home/ute", timeout=1800):
    return connection.force_sw_upgrade(package_path=package_path, timeout=timeout)


@wrap_check_connection_exist
def collect_snapshot(connection='default', file_path="/home/ute/snapshot.zip", timeout=1800):
    return connection.collect_snapshot(local_path=file_path, timeout=int(timeout))


class CoamHandler(object):
    def __init__(self, ip, username="Nemuadmin", password="nemuuser", bts_type='coam', admin_api_log_dir='',
                 release='SBTS22R3'):
        self.gnb_ip = ip
        self.username = username
        self.password = password
        self.bts_type = bts_type.lower()
        self.admin_api_log_dir = admin_api_log_dir
        self.release = release
        self.login()
        self.bts_info = None

    def login(self):
        api = coam_admin()
        self.connection = api.connect_to(self.gnb_ip, username=self.username, password=self.password,
                                         admin_api_log_dir=self.admin_api_log_dir, release=self.release)
        return self.connection

    @wrap_retry_login_if_failed(retry=3, interval=1)
    def get_active_alarms(self):
        data = self.connection.get_active_alarms()
        alarms = self.__extract_alarm_info(data)
        return alarms

    @wrap_retry_login_if_failed(retry=3, interval=1)
    def get_historic_alarms(self):
        data = self.connection.get_historic_alarms(timeout=30, load_history=True)
        alarms = self.__extract_alarm_info(data)
        return alarms

    def __extract_alarm_info(self, alarms):
        ret = []
        for item in alarms:
            info = {}
            info['alarmId'] = item.get('alarmId')
            info['alarmName'] = item.get('alarmName')
            info['faultId'] = item.get('faultId')
            info['faultName'] = item.get('faultName')
            info['severity'] = item.get('severity')
            object_name = item.get('configObjectName') if item.get('configObjectName') else ''
            info['alarmObject'] = re.sub(r'\[.*\]', '', object_name).strip()
            cleared_time = item.get('clearedTime')
            if cleared_time:
                info['clearedTime'] = '%s-%s-%s %s:%s:%s' % (
                    cleared_time[:4], cleared_time[4:6], cleared_time[6:8], cleared_time[8:10],
                    cleared_time[10:12], cleared_time[12: 14])
            else:
                info['clearedTime'] = ''
            observation_t = item.get('btsObservationTime')
            if observation_t:
                info['time'] = '%s-%s-%s %s:%s:%s' % (observation_t[:4], observation_t[4:6], observation_t[6:8],
                                                      observation_t[8:10], observation_t[10:12], observation_t[12: 14])
            else:
                info['time'] = ''
            ret.append(info)
        return ret

    def __get_module_status_info(self, data):
        info = {}
        config_id = data.get('id', {}).get('configuration', '').split('/')[-1]
        product_name = data.get('productName', '').split(' ')[0]
        info['name'] = '{} {}'.format(product_name, config_id).strip()
        status = data.get('status', {})
        info['operationalState'] = status.get('operationalState')
        info['proceduralStatus'] = status.get('proceduralStatus')
        info['availabilityStatus'] = status.get('availabilityStatus')
        info['administrativeState'] = status.get('administrativeState')
        info['usageState'] = status.get('usageState')
        info['isGreen'] = _check_led_status(info)
        if 'CABLINK' in config_id:
            firstEndPoint_id = data.get('firstEndPointId', {}).get('configuration', '').split('/')[-2]
            secondEndPoint_id = data.get('secondEndPointId', {}).get('configuration', '').split('/')[-2]
            info['firstEndPointId'] = firstEndPoint_id
            info['secondEndPointId'] = secondEndPoint_id
        return info

    @wrap_retry_login_if_failed()
    def get_frm_status(self):
        bts_info = self.connection.get_bts_info()
        data = bts_info.get('radioModules', {}).get('rmod', [])
        frms = []
        for item in data:
            info = self.__get_module_status_info(item)
            frms.append(info)
        frms.sort(key=lambda k: k['name'])
        return frms

    @wrap_retry_login_if_failed()
    def get_fbb_status(self):
        bts_info = self.connection.get_bts_info()
        data = bts_info.get('basebandModules', [])
        fbbs = []
        for item in data:
            info = self.__get_module_status_info(item)
            fbbs.append(info)
        fbbs.sort(key=lambda k: k['name'])
        return fbbs

    @wrap_retry_login_if_failed()
    def get_cablink_status(self):
        bts_info = self.connection.get_bts_info()
        data = bts_info.get('cables', [])
        cabs = []
        for item in data:
            info = self.__get_module_status_info(item)
            cabs.append(info)
        cabs.sort(key=lambda k: k['name'])
        return cabs

    @wrap_retry_login_if_failed()
    def get_fsm_status(self):
        bts_info = self.connection.get_bts_info()
        data = bts_info.get('systemModules', [])
        fsms = []
        for item in data:
            info = self.__get_module_status_info(item)
            fsms.append(info)
        fsms.sort(key=lambda k: k['name'])
        return fsms

    @wrap_retry_login_if_failed()
    def get_cell_status(self, cell_type='nr'):
        bts_info = self.connection.get_bts_info()
        data = bts_info.get('cells', {}).get(str(cell_type), [])
        cells = []
        for i, item in enumerate(data):
            cell_id = item['globalCellId'] if 'globalCellId' in item else i + 1
            info = {'name': 'cell-%s' % cell_id}
            status = item.get('status', {})
            info['operationalState'] = status.get('operationalState')
            info['proceduralStatus'] = status.get('proceduralStatus')
            info['availabilityStatus'] = status.get('availabilityStatus')
            info['administrativeState'] = status.get('administrativeState')
            info['isOnair'] = _check_led_status(info)
            cells.append(info)
        cells.sort(key=lambda k: k['name'])
        return cells

    @wrap_retry_login_if_failed()
    def get_sw_version(self):
        sw_info = self.connection.get_software_info()
        tmp_active_v = sw_info.get('Active SW version')
        tmp_passive_v = sw_info.get('Passive SW version')
        active_v = self._extract_version(tmp_active_v)
        passive_v = self._extract_version(tmp_passive_v)
        return active_v, passive_v

    @staticmethod
    def _extract_version(origin_version):
        version = None
        if origin_version:
            match_obj = re.match(r'.*?_0*(\d*)_0*(\d*)_0*(\d*)(.*)?', origin_version)
            if match_obj:
                version = '%s.%s.%s%s' % (match_obj.group(1) if match_obj.group(1) else '0',
                                          match_obj.group(2) if match_obj.group(2) else '0',
                                          match_obj.group(3) if match_obj.group(3) else '0',
                                          match_obj.group(4).rstrip('_').replace('_', '-')
                                          if match_obj.group(4) else '')
        return version

    def logout(self):
        self.connection.disconnect()

    @wrap_retry_login_if_failed()
    def get_bts_status(self):
        bts_info = self.connection.get_bts_info()
        status = bts_info.get('status', {}).get('proceduralState')
        return status

    @wrap_retry_login_if_failed()
    def get_cell_carrier(self):
        bts_info = self.connection.get_bts_info()
        if self.bts_type == 'enb':
            key = 'lte'
        else:
            key = 'nr'
        data = bts_info.get('cells', {}).get(key, [])
        ret = []
        for i, item in enumerate(data):
            name = 'cell-%s' % (item['globalCellId'] if 'globalCellId' in item else i + 1)
            carriers = item.get('carrierList', [])
            tx, rx = 0, 0
            for c in carriers:
                tx = tx + 1 if c['direction'] == 'TX' else tx
                rx = rx + 1 if c['direction'] == 'RX' else rx
            ret.append({'name': name, 'tx': tx, 'rx': rx})
        ret.sort(key=lambda k: k['name'])
        return ret

    @wrap_retry_login_if_failed()
    def get_bbmod_id_according_to_rmod(self, rmod_id):
        rmod = 'RMOD-%s' % str(rmod_id)
        bts_info = self.connection.get_bts_info()
        cables = bts_info.get('cables', [])
        for cable in cables:
            second_end_point = cable.get('secondEndPointId', {}).get('configuration', '')
            first_end_point = cable.get('firstEndPointId', {}).get('configuration', '')
            if rmod in second_end_point:
                bbmod = re.search(r'BBMOD-(\d)', first_end_point).group()
                break
        else:
            raise Exception("Can not find %s's cable." % rmod)
        return bbmod

    @wrap_retry_login_if_failed()
    def force_sw_upgrade(self, package_path, timeout=1800):
        start_time = datetime.datetime.now()
        while True:
            try:
                self.connection.update_software(sw_package=package_path, timeout=2400)
                return True
            except Exception:
                curr_time = datetime.datetime.now()
                if rrule.rrule(rrule.SECONDLY, dtstart=start_time, until=curr_time).count() > timeout:
                    raise RuntimeError("Upgrade action failure within requested timer %d" % timeout)
                time.sleep(5)
                continue
        return False

    @wrap_retry_login_if_failed()
    def collect_snapshot(self, local_path, timeout=1800):
        self.connection.get_snapshot(target_file_name=local_path, timeout=timeout)

    @wrap_retry_login_if_failed()
    def collect_im_snapshot(self, target_file_name, timeout=60):
        self.connection.collect_im_snapshot(target_file_name, timeout)

    def __del__(self):
        self.logout()


class MgzHandler(object):
    def __init__(self, ip, username="Nemuadmin", password="nemuuser"):
        self.gnb_ip = ip
        self.username = username
        self.password = password
        self.login()

    def login(self):
        self.connection = megazone_client()
        self.connection.create_session(self.gnb_ip, user=self.username, password=self.password)
        return self.connection

    @wrap_retry_login_if_failed()
    def get_active_alarms(self):
        data = self.connection.get_active_alarms()
        alarms = self.__extract_alarm_info(data)
        return alarms

    @wrap_retry_login_if_failed()
    def get_historic_alarms(self):
        data = self.connection.get_historic_alarms()
        alarms = self.__extract_alarm_info(data)
        return alarms

    def __extract_alarm_info(self, alarms):
        ret = []
        for item in alarms:
            info = {}
            info['alarmId'] = item.get('specificProblem')
            info['alarmName'] = item.get('alarmText')
            info['faultId'] = item.get('additionalText1', '').split(' ')[0]
            info['faultName'] = item.get('additionalText1', '').replace(info['faultId'], '').strip()
            info['severity'] = item.get('perceivedSeverity')
            info['alarmObject'] = item.get('additionalText8')
            event_t = item.get('eventTime')
            if event_t:
                info['time'] = datetime.datetime.fromtimestamp(int(event_t) / 1000).strftime("%Y-%m-%d %H:%M:%S")
            else:
                info['time'] = ''
            ret.append(info)
        return ret

    @wrap_retry_login_if_failed()
    def get_frm_status(self):
        data = self.connection.get_all_frms()
        frms = []
        for item in data.values():
            info = {}
            planning_status = item.get('planningStatus')
            if planning_status != 'planned':
                continue
            info['name'] = item.get('name')
            info['operationalState'] = item.get('operationalState')
            info['proceduralStatus'] = item.get('proceduralStatus')
            info['planningStatus'] = planning_status
            info['availabilityStatus'] = item.get('availabilityStatus')
            info['administrativeState'] = item.get('administrativeState')
            info['isGreen'] = _check_led_status(info)
            frms.append(info)
        frms.sort(key=lambda k: k['name'])
        return frms

    @wrap_retry_login_if_failed()
    def get_fbb_status(self):
        data = self.connection.get_fbbs()
        fbbs = []
        for item in data.values():
            info = {}
            planning_status = item.get('planningStatus')
            if planning_status != 'planned' and not item.get('fsp', {}).get('proceduralStatus'):
                continue
            info['name'] = item.get('fsp', {}).get('name')
            info['operationalState'] = item.get('operationalState')
            info['proceduralStatus'] = item.get('proceduralStatus')
            info['planningStatus'] = item.get('planningStatus')
            info['availabilityStatus'] = item.get('availabilityStatus')
            info['administrativeState'] = item.get('administrativeState')
            info['isGreen'] = _check_led_status(info)
            fbbs.append(info)
        fbbs.sort(key=lambda k: k['name'])
        return fbbs

    @wrap_retry_login_if_failed()
    def get_fsm_status(self):
        data = self.connection.get_fsms()
        fsms = []
        for item in data.values():
            info = {}
            info['name'] = item.get('name')
            info['operationalState'] = item.get('operationalState')
            info['proceduralStatus'] = item.get('proceduralStatus')
            info['planningStatus'] = item.get('planningStatus')
            info['availabilityStatus'] = item.get('availabilityStatus')
            info['administrativeState'] = item.get('administrativeState')
            info['isGreen'] = _check_led_status(info)
            fsms.append(info)
        fsms.sort(key=lambda k: k['name'])
        return fsms

    @wrap_retry_login_if_failed()
    def get_cell_status(self):
        data = self.connection.get_cell_specific_info()
        cells = []
        for item in data:
            info = {}
            info['name'] = 'cell-%s' % item.get('visibleId')
            info['operationalState'] = item.get('operationalState')
            info['proceduralStatus'] = item.get('proceduralStatus')
            info['availabilityStatus'] = item.get('availabilityStatus')
            info['planningStatus'] = item.get('planningStatus')
            info['administrativeState'] = item.get('administrativeState')
            info['isOnair'] = _check_led_status(info)
            cells.append(info)
        cells.sort(key=lambda k: k['name'])
        return cells

    def get_sw_version(self):
        resp = self.connection.session_handler.send_request('/mz/c/v1/cbts/1/rap/1/interface/1')
        info = json.loads(resp.content)
        tmp_active_v = info.get('activeVersion')
        tmp_passive_v = info.get('passiveVersion')
        active_v, passive_v = tmp_active_v, tmp_passive_v
        if tmp_active_v:
            active_v = tmp_active_v[tmp_active_v.index('_') + 1:].rstrip('_').replace('_', '-')
        if tmp_passive_v:
            passive_v = tmp_passive_v[tmp_passive_v.index('_') + 1:].rstrip('_').replace('_', '-')
        return active_v, passive_v

    def logout(self):
        self.connection.teardown_session()

    @wrap_retry_login_if_failed()
    def get_bts_status(self):
        status = self.connection.get_bts_status()
        return status

    def __del__(self):
        self.logout()


if __name__ == '__main__':
    # print (get_sw_version_by_ssh('10.57.229.132'))
    try:
        login('10.57.227.226', gnb_type='coam', connection='gnb')
        # print(get_active_alarms(connection='gnb'))
        # print(get_history_alarms(connection='gnb'))
        # print(check_gnb_abil_status(connection='gnb'))
        # print(check_gnb_cablink_status(connection='gnb'))
        # print(check_gnb_asik_status(connection='gnb'))
        print(check_gnb_cell_status(connection='gnb', cell_type='nr'))
        print(check_gnb_cell_status(connection='gnb', cell_type='wcdma'))
        # print(check_gnb_ru_status(connection='gnb'))
        # print(get_rx_tx(connection='gnb'))
        # print(get_bbmod_id('gnb', '5'))
    finally:
        logout(connection='gnb')
