# -*- coding: utf-8 -*-
"""
This module provides functionalities for automating configuration tasks in a network environment.

:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
"""

import logging
import os
import re
import time
from retrying import retry

from taf.rfrl.utilities.robot.general import get_builtin_value

from taf.hw.mcs import mcs
from obtain_information import get_mcs_mapping

__all__ = ['check_mcs_by_csv']

tl = get_builtin_value(param_name="tl")


class MCS:
    """
    This class represents a MCS (Modulation and Coding Scheme) device.
    It provides methods to setup, teardown and configure the device.
    """
    def __init__(self,
                 vendor=tl.mcses[0].vendor,
                 model=tl.mcses[0].model,
                 ip=tl.mcses[0].ip_addr,
                 port=tl.mcses[0].port,
                 alias='MCS'):
        """
        Initialize the MCS device with the given parameters.
        """
        self.vendor = vendor
        self.model = model
        self.ip = ip
        self.port = port
        self.alias = alias
        self.mcs = mcs()

    def setup(self):
        """
        Setup the MCS device with the initialized parameters.
        """
        if self.vendor.lower() == 'hbte':
            self.mcs.setup(vendor=self.vendor, model=self.model, ip=self.ip, server_port=self.port, alias=self.alias)
        elif self.vendor.lower() == 'topyoung':
            self.mcs.setup(
                vendor=self.vendor, model=self.model, server_ip=self.ip, server_port=self.port, alias=self.alias)
        elif self.vendor.lower() == 'haojin':
            self.mcs.setup(
                vendor=self.vendor, model=self.model, server_ip=self.ip, port=self.port, alias=self.alias)
        else:
            raise Exception(f"Unsupported MCS vendor: {self.vendor}")

    def teardown(self):
        """
        Teardown the MCS device.
        """
        self.mcs.teardown(mcs_device=self.alias)

    def phases_setting_and_attenuation_parse_file(self, mcs_file_path):
        """
        Parse the given file and return the data as a list of tuples.
        Each tuple contains the row name, column name, attenuation and phase.
        """
        with open(mcs_file_path, 'r') as file:
            lines = file.readlines()

        column_names = lines[0].strip().split(',')

        data = []
        for line in lines[1:]:
            values = line.strip().split(',')
            row_name = values[0]
            for i in range(1, len(values)):
                if values[i]:
                    att, phase = values[i].split('|')
                    dic = {'OUTPUT ID': row_name, 'INPUT ID': column_names[i], 'ATT': att, 'PHASE': phase}
                    data.append(dic)
        logging.info(data)
        return data

    def angles_setting_and_attenuation_parse_file(self, mcs_file_path):
        """
        Parse the given file and return the data as a list of tuples.
        Each tuple contains the row name, column name, vertical angle, horizontal angle,
        vertical distance and horizontal distance.
        """
        with open(mcs_file_path, 'r') as file:
            lines = file.readlines()

        column_names = lines[0].strip().split(',')

        data = []
        for line in lines[1:]:
            values = line.strip().split(',')
            dic = {}
            for i in range(len(values)):
                dic[column_names[i]] = values[i]
            data.append(dic)
        logging.info(data)
        return data

    @retry(stop_max_attempt_number=3, wait_fixed=1000)
    def set_mcs_att(self, input_port, output_port, att):
        """
        Set the attenuation of the MCS device.
        """
        input_port, output_port = int(input_port), int(output_port)
        try:
            self.mcs.set_attenuation(float(att), input_port=input_port, output_port=output_port, mcs_device=self.alias)
            new_att = self.mcs.get_attenuation(
                input_port=input_port, output_port=output_port, mcs_device=self.alias)
            assert float(new_att) == float(att), f"Set attenuation failed, expect {att}, but get {new_att}"
            return True
        except Exception as e:
            logging.error('Set attenuation failed, reason: {}'.format(e))
            return False

    @retry(stop_max_attempt_number=3, wait_fixed=1000)
    def set_mcs_phase(self, input_port, output_port, phase):
        """
        Set the phase of the MCS device.
        """
        input_port, output_port = int(input_port), int(output_port)
        try:
            self.mcs.set_phase(float(phase), input_port=input_port, output_port=output_port, mcs_device=self.alias)
            new_phase = self.mcs.get_phase(
                input_port=input_port, output_port=output_port, mcs_device=self.alias)
            assert float(new_phase) == float(phase), f"Set phase failed, expect {phase}, but get {new_phase}"
            return True
        except Exception as e:
            logging.error('Set phase failed, reason: {}'.format(e))
            return False

    @retry(stop_max_attempt_number=3, wait_fixed=1000)
    def set_mcs_phases_according_to_angles(self, vertical_angle, horizontal_angle, vertical_distance,
                                           horizontal_distance, output_group_id, input_group_id):
        self.mcs.set_phases_according_to_angles(
            vertical_angle=float(vertical_angle), horizontal_angle=float(horizontal_angle),
            vertical_distance=vertical_distance, horizontal_distance=horizontal_distance,
            output_group_id=int(output_group_id), input_group_id=int(input_group_id), mcs_device=self.alias)

    @retry(stop_max_attempt_number=3, wait_fixed=1000)
    def set_mcs_even_attenuations(self, attenuation, begin_input_port=1, end_input_port=64, output_port=1):
        self.mcs.set_even_attenuations(
            float(attenuation), begin_input_port=begin_input_port, end_input_port=end_input_port,
            output_port=int(output_port), mcs_device=self.alias)

    @retry(stop_max_attempt_number=3, wait_fixed=1000)
    def set_mcs_odd_attenuations(self, attenuation, begin_input_port=1, end_input_port=64, output_port=1):
        self.mcs.set_odd_attenuations(
            float(attenuation), begin_input_port=begin_input_port, end_input_port=end_input_port,
            output_port=int(output_port), mcs_device=self.alias)

    def phases_setting_and_attenuation(self, mcs_mapping, testline):
        """
        Set the attenuation and phase of the MCS device based on the data from the given file.
        """
        mcs_file_name = mcs_mapping['mcs_file_name']
        mcs_file_path = os.path.join(os.path.dirname(__file__),
                                     f'../../../../../../../commissionings/HGZ/{testline}/{mcs_file_name}')
        output_id_list = mcs_mapping['output_id_list']
        intput_id_list = mcs_mapping['intput_id_list']
        mcs_modified = False
        checked_pass = True
        data = self.phases_setting_and_attenuation_parse_file(mcs_file_path=mcs_file_path)
        for row in data:
            output_port = re.search(r'\d+', row['OUTPUT ID']).group()
            input_port = re.search(r'\d+', row['INTPUT ID']).group()
            if int(output_port) not in output_id_list or int(input_port) not in intput_id_list:
                continue
            real_att = self.mcs.get_attenuation(
                input_port=int(input_port), output_port=int(output_port), mcs_device=self.alias)
            if float(real_att) != float(row[2]):
                logging.info("set attenuation from {} to {}".format(real_att, row['ATT']))
                result = self.set_mcs_att(input_port, output_port, row[2])
                mcs_modified = True
                if not result:
                    checked_pass = False
                    time.sleep(1)
            real_phase = self.mcs.get_phase(
                input_port=int(input_port), output_port=int(output_port), mcs_device=self.alias)
            if float(real_phase) != float(row[3]):
                logging.info("set phase from {} to {}".format(real_phase, row['PHASE']))
                result = self.set_mcs_phase(input_port, output_port, row[3])
                mcs_modified = True
                if not result:
                    checked_pass = False
                    time.sleep(1)
        if mcs_modified:
            logging.warning("Your testline/MCS maybe changed by someone!!!.")
        assert checked_pass, 'Check and set MCS attenuation or phase failed'

    def angles_setting_and_attenuation(self, mcs_mapping, testline):
        """
        Set the phase and attenuation of the MCS device based on the given mapping.
        """
        mcs_file_name = mcs_mapping['mcs_file_name']
        mcs_file_path = os.path.join(os.path.dirname(__file__),
                                     f'../../../../../../../commissionings/HGZ/{testline}/{mcs_file_name}')
        output_group_id_list = mcs_mapping['output_group_id_list']
        input_group_id_list = mcs_mapping['input_group_id_list']
        horizontal_distance = mcs_mapping['horizontal_distance']
        vertical_distance = mcs_mapping['vertical_distance']
        matrix_id = mcs_mapping['matrix_id']
        data = self.angles_setting_and_attenuation_parse_file(mcs_file_path=mcs_file_path)
        for row in data:
            get_matrix_id = re.search(r'\d+', row['MatrixID']).group()
            output_id = re.search(r'\d+', row['Port B']).group()
            if int(output_id) not in output_group_id_list or int(get_matrix_id) != matrix_id:
                continue
            for input_group_id in input_group_id_list:
                self.set_mcs_phases_according_to_angles(
                    vertical_angle=float(row['Theta Vertical']), horizontal_angle=float(row['Theta Horizontal']),
                    vertical_distance=vertical_distance, horizontal_distance=horizontal_distance,
                    output_group_id=int(output_id), input_group_id=input_group_id)
            begin_input_port, end_input_port = input_group_id_list[0], input_group_id_list[-1]
            self.set_mcs_even_attenuations(
                float(row['EvenAtt']), begin_input_port=begin_input_port, end_input_port=end_input_port,
                output_port=int(output_id))
            self.set_mcs_odd_attenuations(
                float(row['OddAtt']), begin_input_port=begin_input_port, end_input_port=end_input_port,
                output_port=int(output_id))


def check_mcs_by_csv(scf_path):
    """
    Setup and configure the MCS device based on the data from the given CSV file.
    The file name is 'MCS.csv' by default.
    """
    mcs = MCS()
    configuration = get_builtin_value(param_name='CONFIGURATION')
    enb_build = get_builtin_value(param_name='ENB_BUILD')
    ute_env = configuration is not None and enb_build is not None
    if ute_env:
        testline_name = configuration.split('.')[-1]
    else:
        testline_name = get_builtin_value(param_name='testline_name')
    scf_name = os.path.basename(scf_path)
    mcs_mapping = get_mcs_mapping(testline_name=testline_name, scf_name=scf_name)
    set_type = mcs_mapping['set_type']
    try:
        mcs.setup()
        if set_type == 'phases_setting':
            mcs.phases_setting_and_attenuation(mcs_mapping=mcs_mapping, testline=testline_name)
        else:
            mcs.angles_setting_and_attenuation(mcs_mapping=mcs_mapping, testline=testline_name)
    except Exception as e:
        raise e
    finally:
        mcs.teardown()
