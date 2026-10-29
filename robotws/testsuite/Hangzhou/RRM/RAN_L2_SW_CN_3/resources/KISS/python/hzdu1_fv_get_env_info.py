# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author:
:contact:
"""

import configparser
import os
# import MySQLdb
import datetime
import socket
import logging
from ute_fsmaccess import ute_fsmaccess
# from ta_kiss_pa import ta_kiss_pa
fsmaccess = ute_fsmaccess()
# ta_kiss_pa = ta_kiss_pa()


def get_testline_info():
    hostname = socket.gethostname()
    hostip = socket.gethostbyname(hostname)
    logging.info('TestLineHostName={}'.format(hostname))
    logging.info('TestLineIpAddress={}'.format(hostip))
    return "testline_name:{},testline_ip:{}".format(hostname, hostip)


def get_bts_version():
    fsmaccess.setup_enb_fsm_access()
    sw_version = fsmaccess.get_enb_sw_version()
    fsmaccess.teardown_enb_fsm_access()
    logging.info('activeBuildVersion={}'.format(sw_version))
    return sw_version


def get_bts_type():
    fsmaccess.setup_enb_fsm_access()
    bts_type = fsmaccess.execute_command_on_enb('cat /proc/device-tree/module-identity/unit-id').strip("\x00")
    fsmaccess.teardown_enb_fsm_access()
    logging.info(bts_type)
    return bts_type


def get_iphy_version():
    fsmaccess.setup_wts_fsm_access()
    iphy_version = fsmaccess.get_wts_sw_version()
    fsmaccess.teardown_wts_fsm_access()
    logging.info('activeIphyVersion={}'.format(iphy_version))
    return iphy_version


def generate_output_file(output_file):
    try:
        with open(output_file, 'w+') as file:
            testline = get_testline_info()
            file.write("{}\n".format(testline))
            sw_version = get_bts_version()
            bts_type = get_bts_type()
            iphy_version = get_iphy_version()
            file.write("sw_version:{}\n".format(sw_version))
            file.write("bts_type:{}\n".format(bts_type))
            file.write("iphy_version:{}\n".format(iphy_version))
        file.close()
    except Exception as result:
        pass


def ini2dict():
    cfg = configparser.ConfigParser()
    file_dir = os.path.dirname(os.path.abspath(__file__))
    cfg.read(os.path.join(file_dir, 'env.ini'))
    d = dict(cfg._sections)
    for k in d:
        d[k] = dict(d[k])
    return d


def get_env_variable(variable):
    hostname = socket.gethostname()
    config = configparser.ConfigParser()
    file_dir = os.path.dirname(os.path.abspath(__file__))
    config.read(os.path.join(file_dir, 'env.ini'))
    try:
        value = config.get(hostname, variable)
        return value
    except value.coding:
        value = config.get('default', variable)
        return value


def upload_swconfig_to_enb():
    file = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                        'configuration_file', 'swconfig.txt')
    if get_env_variable('Communication_interface') != 'ecpri':
        fsmaccess.setup_enb_fsm_access(alias='swconfig')
        fsmaccess.put_enb_swconfig_file(source=file, timeout=60, alias='swconfig')
        fsmaccess.teardown_enb_fsm_access(alias='swconfig')


def upload_data_to_mysql(case_name, dlput, ulput):
    now_time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    release_version = get_bts_version()
    testline = socket.gethostname()
    conn = MySQLdb.connect(host='10.108.161.68', port=8080, user='sg11', passwd='sg11', db='hellotools')
    cursor = conn.cursor()
    sql = "INSERT INTO `hellotools`.`Mumimo` " \
          "(`time`, `release_version`, `case_name`, `DL_throughput`, `UL_throughput`, `testline`)" \
          " VALUES ('{}', '{}', '{}', '{}', '{}', '{}')".format(now_time, release_version, case_name,
                                                                dlput, ulput, testline)
    try:
        cursor.execute(sql)
        conn.commit()
    except conn.rollback:
        conn.rollback()
    conn.close()
