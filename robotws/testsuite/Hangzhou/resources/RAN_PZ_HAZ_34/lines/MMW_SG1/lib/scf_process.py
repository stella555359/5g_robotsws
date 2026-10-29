# -*- coding: utf-8 -*
"""
Author: Ren Biyao
Contacts: biyao.ren@nokia-sbell.com
Description: Including: 1.delete_objects
                        2.modify_objetcs
                        3.add_objects
                        4.SCFProcess

"""
import os
from taf.config.scf import scf
import logging


class SCFProcess(object):
    def __init__(self):
        self.scf = scf()

    def delete_objects(self, list_para_to_delete):
        """
        Author: Ren Biyao
        Description: delete objects, including object, List, Element with p_name
        : param list_para_to_delete:
        eg:     PARAMS_TO_DELETE_1937_4CCDL_1CCUL = [
        dict(
            dist_name='MRBTS-245/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2'
        ),
        dict(dist_name='MRBTS-245/NRBTS-1/NRCELL-2', p_name='nrCellType'),
        dict(dist_name='MRBTS-245/NRBTS-1/NRCELL-2', list_name='a1MeashoSsbRsrq'),
        dict(dist_name='MRBTS-401/NRBTS-1' + '/NRCELLGRP-0', list_name='nrCellList', index='-1'),
        ]
        """
        for para_to_delete in list_para_to_delete:

            if 'p_name' in para_to_delete.keys():
                is_element_delete_exist = self.scf.is_element_in_object(dist_name=para_to_delete['dist_name'],
                                                                        p_name=para_to_delete['p_name'])
                if is_element_delete_exist:
                    self.scf.remove_element_from_scf(dist_name=para_to_delete['dist_name'],
                                                     p_name=para_to_delete['p_name'])
                else:
                    print("This parameter {} doesn't exist in SCF!".format(para_to_delete))
            elif 'index' in para_to_delete.keys():
                self.scf.remove_element_from_scf(dist_name=para_to_delete['dist_name'],
                                                 list_name=para_to_delete['list_name'],
                                                 index=para_to_delete['index'])

            elif 'list_name' in para_to_delete.keys() and 'index' not in para_to_delete.keys():
                is_list_delete_exists = self.scf.is_list_in_object(dist_name=para_to_delete['dist_name'],
                                                                   list_name=para_to_delete['list_name'])
                if is_list_delete_exists:
                    self.scf.remove_list_from_scf(dist_name=para_to_delete['dist_name'],
                                                  list_name=para_to_delete['list_name'])
                else:
                    print("This parameter {} doesn't exist in SCF!".format(para_to_delete))
            else:
                is_dist_delete_exists = self.scf.is_object_in_scf(dist_name=para_to_delete['dist_name'])
                if is_dist_delete_exists:
                    self.scf.remove_mo_with_descendant_mos(dist_name=para_to_delete['dist_name'])
                else:
                    print("This MO {} doesn't exist in SCF!".format(para_to_delete))

    def modify_objetcs(self, list_para_to_modify):
        """
        Author: Ren Biyao
        : param list_para_to_modify:
        eg:     PARAMS_TO_MODIFY_1937_4CCDL_1CCUL = [
        dict(value='barred', dist_name='MRBTS-245/NRBTS-1/NRCELL-2', p_name='cellBarred'),
        dict(value='100', dist_name='MRBTS-245/NRBTS-1/NRCELL-2', p_name='a2HysteresisRedirectSsbRsrq',
             list_name='a2MeasRedirectSsbRsrq'),
        dict(dist_name='MRBTS-245/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
             list_name='acceptedClockClass', p_name=None, value='100'),
        dict(dist_name='MRBTS-246/NRBTS-246', list_name='freqBandIndicatorEutra', value='100'),
        dict(value='5', dist_name='MRBTS-47/NRBTS-47/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
             p_name='coresetId', list_name='searchSpaceDedicated', index=0),
        dict(value='8', dist_name='MRBTS-47/NRBTS-47/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
             p_name='coresetId', list_name='searchSpaceDedicated', index=1),]
        """
        exceptions = []
        for params in list_para_to_modify:
            try:
                self.scf.modify_scf_element(**params)
            except Exception as e:
                msg = "Exception while modyfing SCF: {}"
                logging.warning(msg.format(str(e)))
                exceptions.append(e)
        if exceptions:
            raise Exception(exceptions)

    def add_objects(self, list_para_to_add):
        """
        Author: Ren Biyao
        :param list_para_to_add:
        eg: PARAMS_TO_ADD_1937_SA = [
            dict(dist_name = 'MRBTS-245' + '/NRCELL-5' + '/NRPLMNSET_NSA-1',
                 version = 'NRBTSCL5G21A_2012_200', class_name = 'com.nokia.srbts.nrbts:NRPLMNSET_NSA'),
            dict(dist_name='MRBTS-245' + '/NRCELL-5' + '/NRPLMNSET_NSA-1',
                list_name='nrPlmnDNList', elements=['MRBTS-245/NRBTS-1' + '/NRPLMN-1']),
            dict(dist_name='MRBTS-245' + '/NRCELL-5' + '/NRPLMNSET_NSA-1',
                                  list_name='a1MeashoSsbRsrpSA', elements={"a1HysteresishoSsbRsrpSA": "0",
                                                                           "a1ThresholdhoSsbRsrpSA": "34",
                                                                           "a1TimeToTriggerhoSsbRsrpSA": "ms480"}),
            dict(dist_name='MRBTS-245/NRBTS-1', p_name='pagingTargetRate', value='pagingDciAggregation')
            ]
        """
        for para_to_add in list_para_to_add:
            is_dist_add_exists = self.scf.is_object_in_scf(dist_name=para_to_add['dist_name'])
            if 'class_name' in para_to_add.keys():
                if not is_dist_add_exists:
                    self.scf.add_object_to_scf(class_name=para_to_add['class_name'],
                                               dist_name=para_to_add['dist_name'],
                                               version=para_to_add['version'])
            elif 'list_name' in para_to_add.keys() and is_dist_add_exists:
                is_list_to_add_exists = self.scf.is_list_in_object(dist_name=para_to_add['dist_name'],
                                                                   list_name=para_to_add['list_name'])
                if not is_list_to_add_exists:
                    self.scf.add_list_to_scf(dist_name=para_to_add['dist_name'],
                                             list_name=para_to_add['list_name'])
                elements = para_to_add['elements']
                if isinstance(elements, dict):
                    self.scf.add_item_to_list(dist_name=para_to_add['dist_name'],
                                              list_name=para_to_add['list_name'],
                                              elements=elements)
                else:
                    self.scf.add_elements_to_list(dist_name=para_to_add['dist_name'],
                                                  list_name=para_to_add['list_name'],
                                                  elements=para_to_add['elements'])

            elif 'p_name' in para_to_add.keys() and is_dist_add_exists:
                self.scf.add_element_to_scf(dist_name=para_to_add['dist_name'], p_name=para_to_add['p_name'],
                                            value=para_to_add['value'])
            else:
                raise Exception("Exception while add {} in SCF. Need add dist_name first".format(para_to_add))

    def SCFProcess(self, scf_template_path, scf_process_folder, list_para_to_delete=None,
                   list_para_to_modify=None, list_para_to_add=None, scf_file_name_after_process='SCFProcessed.xml'):
        """
        Author: Ren Biyao
        :param list_para_to_delete: if present, Delete the parameters in SCF, can be MO,List,
                                    and Element with P Name
        :param list_para_to_add: if present, Add parameter.
        :param list_para_to_modify: Modify parameters if  present.
        The format of arguments can be referred to the parameters defined above.
        :param scf_template_path: dir with xml file eg: /home/ute/MMW1_TL245_10.1800_4cc_1210.xml
        :param scf_process_folder: dir of processed scf, should not end with xml: eg: /home/ute
        :param scf_file_name_after_process: indicate file name after scf process
        :Return processed_scf_path:
        """
        if list_para_to_delete is not None or list_para_to_add is not None or list_para_to_modify is not None:
            if not os.path.exists(scf_process_folder):
                os.mkdir(scf_process_folder)
            processed_scf_path = os.path.join(scf_process_folder, scf_file_name_after_process)
            self.scf.load_scf(file_path=scf_template_path)
            if list_para_to_delete is not None:
                self.delete_objects(list_para_to_delete=list_para_to_delete)
            if list_para_to_add is not None:
                self.add_objects(list_para_to_add=list_para_to_add)
            if list_para_to_modify is not None:
                self.modify_objetcs(list_para_to_modify=list_para_to_modify)
            self.scf.save_scf(file_path=processed_scf_path)
            return processed_scf_path
        else:
            return scf_template_path
