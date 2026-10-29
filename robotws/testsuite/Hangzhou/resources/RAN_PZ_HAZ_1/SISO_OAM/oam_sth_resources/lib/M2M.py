import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
import logging
import time
import datetime


def get_token(host='', username='Nemuadmin', password='nemuuser'):
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
    logging.info('Login to '+host+' with '+username+'/'+password)
    auth_url = 'https://' + host + ':443/api/licensed/sec/v1/login'
    headers = {"Content-Type": "application/Json", "Accept": "application/Json"}
    s = requests.Session()
    s.auth = (username, password)
    rsp = s.post(auth_url, headers=headers, verify=False)
    if rsp.status_code == 201:
        token = rsp.json()['Token']
        logging.info(token)
        return token
    else:
        logging.error(rsp.text)
        raise Exception('HTTP error: ' + str(rsp.status_code))
    pass


def get_common_configuration(host='', username='Nemuadmin', password='nemuuser'):
    logging.info('Logout to ' + host + ' with ' + username + '/' + password)
    api = 'https://' + host + ':443/api/licensed/v1/traces/common-configuration'
    token = get_token(host, username, password)
    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    rsp = s.get(api, headers=headers, verify=False)
    if rsp.status_code == 200:
        logging.info(rsp.text)
        logout(host, token)
        return rsp.json()['dscp']
    else:
        logout(host, token)
        print(rsp.text)
        logging.error(rsp.text)
        raise Exception('HTTP error: ' + str(rsp.status_code))


def common_configuration_update_check(host='', username='Nemuadmin', password='nemuuser', dscp=0, timeout=60):
    while timeout > 0:
        _dscp = get_common_configuration(host, username=username, password=password)
        if _dscp == dscp:
            logging.info('Host ' + str(host) + ' DSCP setting to ' + str(dscp) + ' successful.')
            return True
        timeout = timeout - 1
        time.sleep(1)
    return False


def configure_common_cplane_uplane_tracing(host='', username='Nemuadmin', password='nemuuser', uplane_ip_address='',
                                           uplane_port=3006, dscp=20, trace_type='UPlane'):
    api = 'https://' + host + ':443/api/licensed/v1/traces/common-configuration'
    token = get_token(host, username, password)
    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    data = {
        "uplaneIpAddress": uplane_ip_address,
        "uplanePort": uplane_port,
        "dscp": dscp,
        "traceType": trace_type
    }
    rsp = s.put(api, headers=headers, json=data, verify=False)

    if rsp.status_code == 202:
        logout(host, token)
        if not common_configuration_update_check(host=host, username=username, password=password, dscp=dscp):
            raise Exception('Configuration failure')
        return True
    else:
        logout(host, token)
        print(rsp.text)
        logging.error(rsp.text)
        raise Exception('HTTP error: ' + str(rsp.status_code))
    pass


def get_op_status(host, s, headers, operation_id, operation_type='resets'):
    api = 'https://' + host + ':443/api/licensed/v1/cell-groups/operations/' + operation_type + '/' + operation_id

    rsp = s.get(api, headers=headers, verify=False)

    if rsp.status_code == 200:
        logging.info(rsp.text)
        return rsp.json()['status']

    else:
        logging.error(rsp.text)
        raise Exception('HTTP error: ' + str(rsp.status_code))
    pass


def delete_operation(host, s, headers, operation_id, operation_type='resets'):
    api = 'https://' + host + ':443/api/licensed/v1/cell-groups/operations/' + operation_type + '/' + operation_id
    rsp = s.delete(api, headers=headers, verify=False)
    if rsp.status_code == 204:
        logging.info('delete successful. Operation id: ' + str(operation_id))
        return True
    else:
        logging.error(rsp.text)
        error = 'HTTP error: ' + str(rsp.status_code)
        raise Exception(error)
        pass

    pass


def reset_cell_group(host, cell_group_dn, username='Nemuadmin', password='nemuuser'):
    token = get_token(host, username, password)
    api = 'https://' + host + ':443/api/licensed/v1/cell-groups/operations/resets'
    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    data = {'dn': cell_group_dn}
    rsp = s.post(api, headers=headers, json=data, verify=False)

    if rsp.status_code == 202:
        operation_id = rsp.json()['id']

        while True:

            status = get_op_status(host, s, headers, operation_id)
            if status == 'ongoing':
                time.sleep(5)
            else:
                logging.info('Reset cell group success. ' + str(host) + ': ' + str(cell_group_dn))
                delete_operation(host, s, headers, operation_id)
                break
    else:
        logging.error(rsp.text)
        logout(host, token)
        raise Exception('HTTP error: ' + str(rsp.status_code))

    logout(host, token)


def lock_cell_groups(host, cell_groups, username='Nemuadmin', password='nemuuser'):
    token = get_token(host, username, password)
    api = 'https://' + host + ':443/api/licensed/v1/cell-groups/operations/locks'

    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    rsp = s.post(api, headers=headers, json=cell_groups, verify=False)
    if rsp.status_code == 202:
        operation_id = rsp.json()['id']

        while True:

            status = get_op_status(host, s, headers, operation_id, operation_type='locks')
            if status == 'ongoing':
                time.sleep(5)
            else:
                logging.info('lock cell group success. ' + str(host) + ': ' + str(cell_groups))
                delete_operation(host, s, headers, operation_id, operation_type='locks')
                break
    else:
        logging.error(rsp.text)
        logout(host, token)
        raise Exception('HTTP error: ' + str(rsp.status_code))
    logout(host, token)


def unlock_cell_groups(host, cell_groups, username='Nemuadmin', password='nemuuser'):
    token = get_token(host, username, password)
    api = 'https://' + host + ':443/api/licensed/v1/cell-groups/operations/unlocks'

    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    rsp = s.post(api, headers=headers, json=cell_groups, verify=False)
    if rsp.status_code == 202:
        return rsp.json()
    else:
        logout(host, token)
        raise Exception('HTTP error: ' + str(rsp.status_code))
    pass


def get_vdu_cell_with_id(host, cell_id, username='Nemuadmin', password='nemuuser'):
    token = get_token(host, username, password)
    api = 'https://' + host + ':443/api/licensed/v1/vdu-cells/' + str(cell_id)
    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    rsp = s.get(api, headers=headers, verify=False)
    if rsp.status_code == 200:
        logout(host, token)
        return rsp.json()
    else:
        logging.error(rsp.text)
        raise Exception('HTTP error: ' + str(rsp.status_code))


def get_vdu_cells(host, username='Nemuadmin', password='nemuuser'):
    token = get_token(host, username, password)
    api = 'https://' + host + ':443/api/licensed/v1/vdu-cells/diff'
    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    rsp = s.get(api, headers=headers, verify=False)
    if rsp.status_code == 200:
        logout(host, token)
        return rsp.json()['created']
    else:
        logout(host, token)
        logging.error(rsp.text)
        raise Exception('HTTP error: ' + str(rsp.status_code))


def get_vdu_cells_summary(host, username='Nemuadmin', password='nemuuser'):
    token = get_token(host, username, password)
    api = 'https://' + host + ':443/api/licensed/v1/vdu-cells/summary'
    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    rsp = s.get(api, headers=headers, verify=False)
    if rsp.status_code == 200:
        logout(host, token)
        return rsp.json()
    else:
        logout(host, token)
        logging.error(rsp.text)
        raise Exception('HTTP error: ' + str(rsp.status_code))


def get_cu_cell_with_id(host, cell_id, username='Nemuadmin', password='nemuuser'):
    token = get_token(host, username, password)
    api = 'https://' + host + ':443/api/licensed/v1/cu-cells/' + str(cell_id)
    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    rsp = s.get(api, headers=headers, verify=False)
    if rsp.status_code == 200:
        logout(host, token)
        return rsp.json()
    else:
        logging.error(rsp.text)
        raise Exception('HTTP error: ' + str(rsp.status_code))


def get_cu_cells(host, username='Nemuadmin', password='nemuuser'):
    token = get_token(host, username, password)
    api = 'https://' + host + ':443/api/licensed/v1/cu-cells/diff'
    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    rsp = s.get(api, headers=headers, verify=False)
    logging.info(rsp.text)
    if rsp.status_code == 200:
        logout(host, token)
        return rsp.json()['created']
    else:
        logging.error(rsp.text)
        raise Exception('HTTP error: ' + str(rsp.status_code))


def get_cu_cells_summary(host, username='Nemuadmin', password='nemuuser'):
    token = get_token(host, username, password)
    api = 'https://' + host + ':443/api/licensed/v1/cu-cells/summary'
    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    rsp = s.get(api, headers=headers, verify=False)
    logout(host, token)
    if rsp.status_code == 200:
        return rsp.json()
    else:
        logging.error(rsp.text)
        raise Exception('HTTP error: ' + str(rsp.status_code))


def get_vdu_state(host, username='Nemuadmin', password='nemuuser'):
    token = get_token(host, username, password)
    api = 'https://' + host + ':443/api/licensed/v1/vdu'
    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    rsp = s.get(api, headers=headers, verify=False)
    logout(host, token)
    if rsp.status_code == 200:
        return rsp.json()
    else:
        logging.error(rsp.text)
        raise Exception('HTTP error: ' + str(rsp.status_code))


def get_cu_state(host, username='Nemuadmin', password='nemuuser'):
    token = get_token(host, username, password)
    api = 'https://' + host + ':443/api/licensed/v1/cu'
    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    rsp = s.get(api, headers=headers, verify=False)
    logout(host, token)
    if rsp.status_code == 200:
        return rsp.json()
    else:
        logging.error(rsp.text)
        raise Exception('HTTP error: ' + str(rsp.status_code))


def get_counter(host, counter_id, mo_dn, username='Nemuadmin', password='nemuuser'):
    token = get_token(host, username, password)
    api = 'https://' + host + ':443/api/pm/v2/counters/values'
    params = {'counter': counter_id + ':' + mo_dn}
    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    rsp = s.get(api, headers=headers, params=params, verify=False)
    if rsp.status_code == 200:
        logout(host, token)
        logging.info(rsp.text)
        return rsp.json()
    else:
        logging.error(rsp.text)
        raise Exception('HTTP error: ' + str(rsp.status_code))
    pass


def logout(host, token):
    logout_url = 'https://' + host + ':443/api/licensed/sec/v1/logout'
    headers = {"Content-Type": "application/Json", "Accept": "application/Json", 'Authorization': 'Bearer ' + token}
    s = requests.Session()
    rsp = s.post(logout_url, headers=headers, verify=False)
    if not rsp.status_code == 204:
        raise Exception('Logout failed with HTTP error: ' + str(rsp.status_code))
    logging.info('Logout successful')
    pass


def all_vdu_cells_are_enabled(host, username='Nemuadmin', password='nemuuser', timeout=60):
    while timeout > 0:
        vdu_cells_summary = get_vdu_cells_summary(host=host, username=username, password=password)
        if vdu_cells_summary['availabilityStatus']['off line'] == 0:
            logging.info('All vDU cells are enabled.')
            return True
        timeout = timeout - 1
        time.sleep(1)
        pass
    raise Exception('Not all vDU cells are enabled. ')
    pass


def all_cu_cells_are_enabled(host, username='Nemuadmin', password='nemuuser', timeout=60):
    while timeout > 0:
        cu_cells_summary = get_cu_cells_summary(host=host, username=username, password=password)
        if cu_cells_summary['availabilityStatus']['off line'] == 0:
            logging.info('All CU cells are enabled.')
            return True
        timeout = timeout - 1
        time.sleep(1)
        pass
    raise Exception('Not all CU cells are enabled. ')
    pass


def reset_cu_cell_groups(host='', username='Nemuadmin', password='nemuuser'):
    cell_groups = []
    cu_cells = get_cu_cells(host=host, username=username, password=password)
    for cell in cu_cells:
        cell_dn = cell['basicCell']['distNames']['config']
        cell_name = cell['basicCell']['name']
        cell_group_id = cell['basicCell']['cellGroupId']
        cell_group_name = 'NRCELLGRP-' + str(cell_group_id)
        cell_group_dn = cell_dn.replace(cell_name, cell_group_name)
        if cell_group_dn not in cell_groups:
            cell_groups.append(cell_group_dn)
        else:
            continue
        reset_cell_group(host=host, cell_group_dn=cell_group_dn, username=username, password=password)
        pass
    return cell_groups


def reset_vdu_cell_groups(host='', username='Nemuadmin', password='nemuuser'):
    cell_groups = []
    cu_cells = get_vdu_cells(host=host, username=username, password=password)
    for cell in cu_cells:
        cell_dn = cell['basicCell']['distNames']['config']
        cell_name = cell['basicCell']['name']
        cell_group_id = cell['basicCell']['cellGroupId']
        cell_group_name = 'NRCELLGRP-' + str(cell_group_id)
        cell_group_dn = cell_dn.replace(cell_name, cell_group_name)
        if cell_group_dn not in cell_groups:
            cell_groups.append(cell_group_dn)
        else:
            continue
        reset_cell_group(host=host, cell_group_dn=cell_group_dn, username=username, password=password)
        pass
    return cell_groups


def get_cu_cells_dn(host='', username='Nemuadmin', password='nemuuser'):
    cu_cells = get_cu_cells(host=host, username=username, password=password)
    cells = []
    for cell in cu_cells:
        cells.append(cell['basicCell']['distNames']['config'])
    return cells


def get_vdu_cells_dn(host='', username='Nemuadmin', password='nemuuser'):
    vdu_cells = get_vdu_cells(host=host, username=username, password=password)
    cells = []
    for cell in vdu_cells:
        cells.append(cell['basicCell']['distNames']['config'])
    return cells


def reset_cu_cell_groups_and_check_couters_update(host='', username='Nemuadmin', password='nemuuser'):
    reset_cu_cell_groups(host=host, username=username, password=password)
    all_cu_cells_are_enabled(host=host, username=username, password=password)
    cu_cells = get_cu_cells_dn(host=host, username=username, password=password)
    for cell_dn in cu_cells:
        counter_is_updated(host=host, username=username, password=password, counter_id='M55601C01002', mo_dn=cell_dn)
        counter_is_updated(host=host, username=username, password=password, counter_id='M55601C01001', mo_dn=cell_dn)
    pass


def reset_vdu_cell_groups_and_check_couters_update(host='', username='Nemuadmin', password='nemuuser'):
    reset_vdu_cell_groups(host=host, username=username, password=password)
    start = datetime.datetime.now()
    all_vdu_cells_are_enabled(host=host, username=username, password=password)
    end = datetime.datetime.now()
    downtime = (end - start).seconds
    logging.info('start/end: ' + str(start) + '/' + str(end))
    logging.info('Cell downtime in seconds: ' + str(downtime))
    if downtime > 40:
        raise Exception("Cell downtime exceed limit!!! Pls refer to OM_GEN_SFS_PERF_CAP.24216.")

    vdu_cells = get_vdu_cells_dn(host=host, username=username, password=password)
    for cell_dn in vdu_cells:
        counter_is_updated(host=host, username=username, password=password, counter_id='M55601C01002', mo_dn=cell_dn)
        counter_is_updated(host=host, username=username, password=password, counter_id='M55601C01001', mo_dn=cell_dn)
    pass


def counter_is_updated(host, username='Nemuadmin', password='nemuuser', counter_id='', mo_dn='', timeout=30 * 60):
    start_time = datetime.datetime.now()
    while (datetime.datetime.now() - start_time).seconds < timeout:

        counter = get_counter(host=host, username=username, password=password, counter_id=counter_id, mo_dn=mo_dn)
        logging.info('Checking counter update: ' + counter_id)
        counter_key = counter_id + ':PLMN-PLMN/' + mo_dn
        if counter_key not in counter:
            time.sleep(60)
            logging.info('Counter is not yet available')
            continue
        lastest_value = int(counter[counter_key][-1]['value'])
        if lastest_value:
            logging.info(counter_id + ' of ' + mo_dn + ' updated: ' + str(lastest_value))
            return counter[counter_key][-1]
        time.sleep(60)
    logging.error(counter_id + ' of ' + mo_dn + ' not update in ' + str(timeout) + 's.')
    raise Exception('Wait for counter update timeout.')
    pass


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, filename=__file__ + '.log', filemode='a',
                        format='%(asctime)s - %(pathname)s[line:%(lineno)d] - %(levelname)s: %(funcName)s, %(message)s')
    # s=get_vdu_cells_summary(host='10.71.173.82')
    # configure_common_cplane_uplane_tracing(host='10.108.194.162', username='Nemuadmin', password='Nokia@123',
    #                                        uplane_ip_address='10.97.92.238', uplane_port=3006, dscp=63,
    #                                        trace_type='UPlane')
