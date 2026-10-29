# -*- coding: utf-8 -*-

import logging
import os
from taf.sbts.oam.coam.admin import admin
admin = admin()

bts_addr = '192.168.255.1'
bts_port = 443


def check_bts_state_via_admin():
    admin.setup_admin(bts_host=bts_addr, bts_port=bts_port, use_ssl=True, alias='proceduralState')
    version = admin.get_bts_info(alias='proceduralState')
    admin.teardown_admin(alias='proceduralState')
    return version['status']['proceduralState']


def check_cell_blockingState(cellid):
    cellid = int(cellid)
    admin.setup_admin(bts_host=bts_addr, bts_port=bts_port, use_ssl=True, alias='blockingState')
    parameters = admin.get_parameters_for_all('LNCEL', alias='blockingState')
    admin.teardown_admin(alias='blockingState')
    for element in parameters:
        if int(element['id'].split('-')[-1]) == cellid:
            return element['blockingState']


def block_cell_via_admin(cellid):
    cellid = int(cellid)
    if '{}'.format(check_cell_blockingState(cellid)) == 'Unblocked':
        admin.connect_to(bts_host=bts_addr, bts_port=bts_port, use_ssl=True, name='block')
        lncel_id = admin.get_cell_id_by_configuration_id(rat='LTE', configuration_id=cellid, connection='block')
        admin.block_cell(dist_name=lncel_id, connection='block')
        admin.teardown(connection='block')
        logging.info('cell blockingState is {}, when have been blocked .'.format(check_cell_blockingState(cellid)))


def unblock_cell_via_admin(cellid):
    cellid = int(cellid)
    if '{}'.format(check_cell_blockingState(cellid)) == 'Blocked':
        admin.setup_admin(bts_host=bts_addr, bts_port=bts_port, use_ssl=True, name='unblock')
        lncel_id = admin.get_cell_id_by_configuration_id(rat='LTE', configuration_id=cellid, connection='unblock')
        admin.unblock_cell(dist_name=lncel_id, connection='unblock')
        admin.teardown(connection='unblock')
        logging.info('cell blockingState is {}, when have been unblocked .'.format(check_cell_blockingState(cellid)))


def collect_snapshot_and_im_via_admin(save_path):
    admin.setup_admin(bts_host=bts_addr, bts_port=bts_port, use_ssl=True, alias='collect')
    try:
        admin.collect_im_snapshot(target_file_name='{}/fail.ims2'.format(save_path), alias='collect')
    except Exception as result:
        pass
    try:
        admin.collect_snapshot(target_file_name='{}/snapshot.zip'.format(save_path), timeout=900, alias='collect')
    except Exception as result:
        pass
    finally:
        admin.teardown_admin(alias='collect')


def get_active_alarm_via_admin():
    try:
        admin.setup_admin(bts_host=bts_addr, bts_port=bts_port, use_ssl=True, alias='alarm')
        logs = admin.get_alarms(alias='alarm')
        for log in logs:
            if log['alarmSeverity'] == 'Critical':
                logging.error('critical alarm:')
                logging.error(
                    'alarmId: {}, alarmDetail:{}, distName:{}'.format(log.get('faultId'), log.get('alarmDetail'),
                                                                      log.get('alarmingResource')))
        # major = admin.get_active_alarms(severity='major', alias='alarm')
        # if major:
        #     logging.error('major alarm:')
        #     for info in major:
        #         logging.error('alarmId: {}, alarmDetail:{}, distName:{}'.format(info.get('alarmId'),
        #                       info.get('alarmDetail'), info.get('distName')))
    except Exception as result:
        pass
    finally:
        admin.teardown_admin(alias='alarm')


def online_change_parameter(class_mo, parameter, value, cell='ALL'):
    from scfc_for_zwc import get_distname_from_classname
    import json
    import time
    json_list = []
    if os.path.exists('/tmp/scfc.xml'):
        os.remove('/tmp/scfc.xml')
    admin.setup_admin(bts_host=bts_addr, bts_port=bts_port, use_ssl=True, alias='scfc')
    admin.collect_scf(target_file_name='/tmp/scfc.xml', alias='scfc')
    admin.teardown_admin(alias='scfc')
    distnames = get_distname_from_classname('/tmp/scfc.xml', class_mo)
    distnames = sorted(distnames)
    if cell == 'ALL':
        if isinstance(value, dict):
            value = [value]
            for distname in distnames:
                update_str = '{"distName": "%s",' \
                     '"operation": "update",' \
                     '"parameters": [{"operation": "update",' \
                     '"parameterName": "%s",' \
                     '"value": %s}]}' % (distname, parameter, value)
                json_list.append(eval(update_str))
        else:
            for distname in distnames:
                update_str = '{"distName": "%s",' \
                     '"operation": "update",' \
                     '"parameters": [{"operation": "update",' \
                     '"parameterName": "%s",' \
                     '"value": "%s"}]}' % (distname, parameter, value)
                json_list.append(eval(update_str))
    else:
        if isinstance(value, dict):
            value = [value]
            update_str = '{"distName": "%s",' \
                         '"operation": "update",' \
                         '"parameters": [{"operation": "update",' \
                         '"parameterName": "%s",' \
                         '"value": %s}]}' % (distnames[int(cell)-1], parameter, value)
            json_list.append(eval(update_str))
        else:
            update_str = '{"distName": "%s",' \
                         '"operation": "update",' \
                         '"parameters": [{"operation": "update",' \
                         '"parameterName": "%s",' \
                         '"value": "%s"}]}' % (distnames[int(cell) - 1], parameter, value)
            json_list.append(eval(update_str))
    timeslot = time.strftime("%Y%m%d%H%M%S", time.localtime())
    filename = '/tmp/change_rad_parameter_{}.json'.format(timeslot)
    with open(filename, "w") as f:
        f.write(json.dumps(json_list, indent=1))
    f.close()
    logging.info(filename)
    admin.setup_admin(bts_host=bts_addr, bts_port=bts_port, use_ssl=True, alias='delta')
    admin.perform_delta_recommissioning(delta_file=filename, skip_parameter_relation_errors=True, alias='delta')
    admin.teardown_admin(alias='delta')
