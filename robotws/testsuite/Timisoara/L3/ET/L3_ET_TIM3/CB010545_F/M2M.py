import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
import logging
import time
import sys
import json
import datetime
import re


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


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, filename=__file__ + '.log', filemode='a',
                        format='%(asctime)s - %(pathname)s[line:%(lineno)d] - %(levelname)s: %(funcName)s, %(message)s')
    # s=get_vdu_cells_summary(host='10.71.173.82')
    # configure_common_cplane_uplane_tracing(host='10.108.194.162', username='Nemuadmin', password='Nokia@123',
    #                                        uplane_ip_address='10.97.92.238', uplane_port=3006, dscp=63,
    #                                        trace_type='UPlane')
