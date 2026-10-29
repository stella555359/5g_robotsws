# -*- coding:utf-8 -*-
"""
:copyright: Nokia Networks
:author: Civen Chen
:contact: civen.chen@nokia-sbell.com
"""
import logging
from robot.libraries.BuiltIn import BuiltIn

__all__ = [
    'Test_PC_IP',
    'Test_PC_username',
    'Test_PC_password',
    'DU_OAM_IP',
    'instance_id_MRBTS',
    'Compass_ID_list']


def read_parameter_from_tl():
    tl = BuiltIn().get_variable_value('${tl}')
    test_pc_variables, DU_OAM_IP, instance_MRBTS = None, None, None
    try:
        test_pc_variables = tl.test_pc[0].default_ssh_connection_details
    except Exception as e:
        try:
            test_pc_variables = tl.test_pc.default_ssh_connection_details
        except Exception as e:
            test_pc_variables = None
            logging.info(f"parameter test_pc_ssh_variables not found")
    try:
        DU_OAM_IP = tl.gnbs[0].dus[0].f1_m_ip_addr
    except Exception as e:
        try:
            DU_OAM_IP = tl.gnbs[0].dus.f1_m_ip_addr
        except Exception as e:
            try:
                DU_OAM_IP = tl.gnbs[0].dus[0].oam_ip
            except Exception as e:
                try:
                    DU_OAM_IP = tl.gnbs[0].dus.oam_ip
                except Exception as e:
                    try:
                        DU_OAM_IP = tl.gnbs.dus[0].f1_m_ip_addr
                    except Exception as e:
                        try:
                            DU_OAM_IP = tl.gnbs.dus.f1_m_ip_addr
                        except Exception as e:
                            try:
                                DU_OAM_IP = tl.gnbs.dus[0].oam_ip
                            except Exception as e:
                                try:
                                    DU_OAM_IP = tl.gnbs.dus.oam_ip
                                except Exception as e:
                                    DU_OAM_IP = None
                                    logging.info(
                                        f"parameter DU_OAM_IP not found")
    try:
        instance_MRBTS = f"MRBTS-{tl.gnbs[0].instance_id}"
    except Exception as e:
        try:
            instance_MRBTS = f"MRBTS-{tl.gnbs.instance_id}"
        except Exception as e:
            logging.info(f"parameter instance_id_MRBTS not found")
    return test_pc_variables, DU_OAM_IP, instance_MRBTS


def get_test_pc_info(test_pc_variables):
    Test_PC_IP, Test_PC_username, Test_PC_password = None, None, None
    if test_pc_variables is not None:
        try:
            Test_PC_IP = test_pc_host_variables.addr
        except Exception as e:
            Test_PC_IP = None
        try:
            Test_PC_username = test_pc_host_variables.username
        except Exception as e:
            Test_PC_username = None
        try:
            Test_PC_password = test_pc_host_variables.password
        except Exception as e:
            Test_PC_password = None
    return Test_PC_IP, Test_PC_username, Test_PC_password


p_list = read_parameter_from_tl()
test_pc_host_variables = p_list[0]
DU_OAM_IP = p_list[1]
instance_id_MRBTS = p_list[2]
test_pc_info = get_test_pc_info(test_pc_host_variables)
Test_PC_IP = test_pc_info[0]
Test_PC_username = test_pc_info[1]
Test_PC_password = test_pc_info[2]
Compass_ID_list = []
