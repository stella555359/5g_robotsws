# -*- coding: utf-8 -*-

# @Copyright: Nokia Networks
# @Author: cathy.mao@nokia-sbell.com
# @Contact: I_NSB_MN_RAN_RD_VRF_HAZ3_07_GMS <I_NSB_MN_RAN_RD_VRF_HAZ3_07@internal.nsn.com>


import os
import time
from robot.libraries.BuiltIn import BuiltIn
from taf.hw.rf_attenuator import attenuator as attenuator
tl = BuiltIn().get_variable_value('${tl}')


class pa_obj(object):
    def __init__(self):
        self.attenuator = tl.attenuator
        self._att_obj = None

    @property
    def att_obj(self):
        if self._att_obj is None:
            self._att_obj = attenuator()
            self._att_obj.setup_attenuator(attenuator=self.attenuator)
        return self._att_obj

    def set_pa_values(self, pa_values, interval=5):
        """This keyword is to set multi port's pa values in a simple way.
        Examples:
            cell1 use port 1,2, cell2 use port 3,4
            @{attach_cell1_pa_values}
            ...    1=${10}
            ...    2=${10}
            ...    3=${50}
            ...    4=${50}
            set_pa_values    ${attach_cell1_pa_values}

        """
        final_values = []
        print(pa_values)

        for index in pa_values:
            port = index.split('=')[0]
            value = index.split('=')[1]
            self.att_obj.set_attenuation(port=int(port), value=int(value))
            time.sleep(interval)
            tmp_val = self.att_obj.read_attenuation(int(port))
            final_values.append("{}={}".format(port, tmp_val))

        return final_values


class ho_obj(object):
    def __init__(self):
        self.pa_operator = pa_obj()

    def convert_to_port_value_list(self, ports, value):
        print('===> ports: {}, value: {}'.format(ports, value))
        port_val = []
        for port in ports.split('-'):
            port_val.append('{}={}'.format(port, value))
        return port_val

    def set_next_port_value(self, ports, value):

        tgt_port_val = self.convert_to_port_value_list(ports, value)
        print('===> tgt_port_val: {} '.format(tgt_port_val))
        self.pa_operator.set_pa_values(tgt_port_val)

    def intergnb_intercell_ho(self, ho_params):
        """This keyword is to automatically trigger Intergnb Intercell HO,by input the good and bad signal.
        *** The current implementation is same with intragnb_intercell_ho ***
        Examples:
            @{InterGNB_HO_From_GNB1_Cell2_To_GNB2_Cell1_Params}
            ...    src_cell=2,port=9-10,good=50,bad=70
            ...    tgr_cell=1,port=12,good=10,bad=30

            @{InterGNB_HO_From_GNB2_Cell1_To_GNB1_Cell2_Params}
            ...    src_cell=1,port=12,good=10,bad=30
            ...    tgr_cell=2,port=9-10,good=50,bad=70

            intergnb_intercell_ho    ${InterGNB_HO_From_GNB1_Cell2_To_GNB2_Cell1_Params}
            intergnb_intercell_ho    ${InterGNB_HO_From_GNB2_Cell1_To_GNB1_Cell2_Params}

        """
        self.intragnb_intercell_ho(ho_params)

    def intragnb_intercell_ho(self, ho_params):
        """This keyword is to automatically trigger Intragnb Intercell HO,by input the good and bad signal.
        Examples:
            @{IntraGNB_HO_From_Cell2_To_Cell3_Params}
            ...    src_cell=2,port=1-2,good=10,bad=50
            ...    tgr_cell=3,port=3-4,good=15,bad=60
            intragnb_intercell_ho    ${IntraGNB_HO_From_Cell2_To_Cell3_Params}

        """
        src_dict = {}
        tgt_dict = {}
        print(ho_params)
        print(len(ho_params))
        if len(ho_params) != 2:
            raise Exception('==>>> only Source and Target Cell Allowed .')
        else:
            src_info = ho_params[0]
            tgt_info = ho_params[1]
            for index in src_info.split(','):
                src_dict[index.split('=')[0]] = index.split('=')[1]
            for index2 in tgt_info.split(','):
                tgt_dict[index2.split('=')[0]] = index2.split('=')[1]
        print(src_dict)
        print(tgt_dict)
        src_ori_val = self.pa_operator.att_obj.read_attenuation(
            int(src_dict['port'].split('-')[0]))
        tgt_ori_val = self.pa_operator.att_obj.read_attenuation(
            int(tgt_dict['port'].split('-')[0]))
        print(
            '-----src_ori_val: {}, tgt_ori_val: {} -----'.format(src_ori_val, tgt_ori_val))

        # if target signal too bad, first set to the bad limit
        if tgt_ori_val > int(tgt_dict['bad']):
            self.set_next_port_value(tgt_dict['port'], tgt_dict['bad'])
            tgt_ori_val = self.pa_operator.att_obj.read_attenuation(
                int(tgt_dict['port'].split('-')[0]))
        print(
            '------ src_ori_val: {}, tgt_ori_val: {} -----'.format(src_ori_val, tgt_ori_val))
        src_next_val = int(src_ori_val) + 10
        tgt_next_val = int(tgt_ori_val) - 10
        print('-----first==> src_next_val: {}, tgt_next_val: {} -----'.format(src_next_val, tgt_next_val))
        while src_next_val < int(src_dict['bad']) - 20:
            print('======in while====')
            print(
                '-----src_next_val: {}, tgt_next_val: {} -----'.format(src_next_val, tgt_next_val))
            self.set_next_port_value(src_dict['port'], src_next_val)
            self.set_next_port_value(tgt_dict['port'], tgt_next_val)
            src_next_val = int(src_next_val) + 10
            tgt_next_val = int(tgt_next_val) - 10

        # src signal is bad, it must make tgt signal good
        while tgt_next_val > int(tgt_dict['good']):
            self.set_next_port_value(tgt_dict['port'], tgt_next_val)
            tgt_next_val = int(tgt_next_val) - 10

        # now tgt signal is good enough, then adjust the src signal to bad
        self.set_next_port_value(tgt_dict['port'], int(tgt_dict['good']))
        if src_next_val > int(src_dict['bad']):
            self.set_next_port_value(src_dict['port'], src_dict['bad'])
        else:
            self.set_next_port_value(src_dict['port'], src_next_val)
            self.set_next_port_value(src_dict['port'], src_dict['bad'])


if __name__ == "__main__":
    obj = pa_obj()
