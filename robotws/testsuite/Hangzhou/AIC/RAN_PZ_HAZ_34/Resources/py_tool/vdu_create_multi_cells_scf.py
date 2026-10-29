# -*- coding: utf-8 -*-
# one RU one cell
# lcrid and phyCellId are increased 1 based on current scf

from taf.config.scf import scf as tafscf
# import xml.etree.ElementTree as ET
from scf_xml_parsing import ParsingSCF
import os
import logging
import string
# log_format = "%(asctime)s - %(levelname)s - %(message)s"
# logging.basicConfig(level=logging.DEBUG, format=log_format)

logger = logging.getLogger(__name__)
logger.addHandler(logging.NullHandler())

tafScfFunc = tafscf()

__all__ = [
    "get_delete_cell_mo",
    "get_add_cell_info"
]


class CurExistingCells(object):
    def __init__(self, scf_path=None, cell_id=None):
        self.current_scf = ParsingSCF(scf_path)
        tafScfFunc.load_scf(file_path=scf_path)
        self.scf_path = scf_path
        self.cell_id = cell_id

        self.last_rmod_dn = self.get_last_dn('RMOD')
        self.last_sync_dn = self.get_last_dn('SYNC')
        self.last_nrcell_dn = self.get_last_dn('NRCELL')
        self.last_nrcellgrp_dn = self.get_last_dn('NRCELLGRP')
        self.last_lcellnr_dn = self.get_last_dn('LCELNR')
        self.last_nrdu_dn = self.get_last_dn('NRDU')
        self.existingNumOfCells = len(self.get_mo_object_list("NRCELL"))
        self.lcrId = self.get_p_value(dn=self.last_nrcell_dn, p_name="lcrId")
        self.phyCellId = self.get_p_value(dn=self.last_nrcell_dn, p_name="physCellId")
        self.nrcellList = self.get_list_p_value(self.last_nrcellgrp_dn, list_name="nrCellList")[-1]
        self.refNrCellGroup = self.get_list_p_value(self.last_nrdu_dn, list_name="refNrCellGroup")[-1]
        self.channel_amount_per_lcellnr = len(self.get_mo_object_list("CHANNEL"))/self.existingNumOfCells

    def get_last_dn(self, name):
        dn_list = []
        mo_list = self.get_mo_object_list(name)
        for mo in mo_list:
            dn_list.append(mo.get('distName'))
        dn_list.sort()
        return dn_list[-1]

    def get_mo_object_list(self, class_name):
        self.current_scf.start_parsing()
        return self.current_scf.get_mo_list(class_name)

    @staticmethod
    def get_p_value(dn, p_name):
        p_val = tafScfFunc.get_value_from_scf(dist_name=dn, p_name=p_name)
        return p_val

    @staticmethod
    def get_list_p_value(dn, list_name):
        p_val = tafScfFunc.get_all_values_from_scf(dist_name=dn, list_name=list_name)
        return p_val


class CloneObjects(object):
    def __init__(self):
        pass

    def clone_objects(self, ref_cell, iter_num, new_scf_path):
        for i in range(1, iter_num):
            self._prepare_and_clone_objects(ref_cell=ref_cell, offset=i)
        tafScfFunc.save_scf(new_scf_path)
        # return new_scf_path

    def _prepare_and_clone_objects(self, ref_cell, offset):
        mo_to_create = PrepareRelatedMoToCreate(ref_cell=ref_cell, offset=offset)
        self._clone_one_mo_and_check(base_obj=ref_cell.last_rmod_dn, target_obj=mo_to_create.new_rmod_dn)
        self._clone_one_mo_and_check(base_obj=ref_cell.last_sync_dn, target_obj=mo_to_create.new_sync_dn)
        self._clone_one_mo_and_check(base_obj=ref_cell.last_nrcell_dn, target_obj=mo_to_create.new_nrcell_dn)
        self._clone_one_mo_and_check(base_obj=ref_cell.last_nrcellgrp_dn, target_obj=mo_to_create.new_nrcellgrp_dn)
        self._clone_one_mo_and_check(base_obj=ref_cell.last_lcellnr_dn, target_obj=mo_to_create.new_lcellnr_dn)

    @staticmethod
    def _clone_one_mo_and_check(base_obj, target_obj):
        logger.info("Starting clone {} based on {}".format(target_obj, base_obj))
        if not tafScfFunc.is_object_in_scf(dist_name=target_obj):
            tafScfFunc.clone_mo_with_descendant_mos(source_mo_dist_name=base_obj,
                                                    target_mo_dist_name=target_obj)
            logger.info("OK: Object cloned: {} , based on: {}".format(target_obj, base_obj))


class ModifyCreatedObjects(object):
    def __init__(self):
        pass

    def modify_objects(self, new_rmods_sn_dict, scf_path, iter_num, ref_cell):
        tafScfFunc.load_scf(scf_path)

        for i in range(1, iter_num):
            target_mo = PrepareRelatedMoToCreate(ref_cell=ref_cell, offset=i)
            self.modify_parameters_and_check(dn=target_mo.new_nrcell_dn, para_name='lcrId',
                                             value=target_mo.new_lcrid, para_type='p_name')
            self.modify_parameters_and_check(dn=target_mo.new_nrcell_dn, para_name='physCellId',
                                             value=target_mo.new_phyCellId, para_type="p_name")
            self.modify_parameters_and_check(dn=target_mo.new_nrcell_dn, para_name='rModDNList',
                                             value=target_mo.new_rmod_dn, para_type='list_name')
            self.modify_parameters_and_check(dn=target_mo.new_sync_dn, para_name='targetDNList',
                                             value=target_mo.new_rmod_dn, para_type='list_name')
            self.modify_parameters_and_check(dn=ref_cell.last_nrdu_dn, para_name='refNrCellGroup',
                                             value=target_mo.new_refNrCellGroup, para_type='list_name')
            self.modify_parameters_and_check(dn=target_mo.new_nrcellgrp_dn, para_name='nrCellList',
                                             value=target_mo.new_nrCellList, para_type='list_name')
            self.modify_parameters_and_check(dn=target_mo.new_rmod_dn, para_name='serialNumberPlanned',
                                             value=new_rmods_sn_dict[target_mo.new_rmod_dn.split('/')[-1]],
                                             para_type='p_name')
            for channel_dn in target_mo.new_channel_dn_list:
                self.modify_parameters_and_check(dn=channel_dn, para_name='resourceDN',
                                                 value=target_mo.new_resourcedn, para_type='p_name')

        tafScfFunc.save_scf(scf_path)

    @staticmethod
    def modify_parameters_and_check(dn, para_name, value, para_type):
        if tafScfFunc.is_object_in_scf(dist_name=dn):
            if para_name == "refNrCellGroup":
                tafScfFunc.add_elements_to_list(dist_name=dn, list_name=para_name, elements=value)
            elif para_type == "p_name":
                tafScfFunc.modify_scf_element(value=value, dist_name=dn, p_name=para_name)
            elif para_type == "list_name":
                tafScfFunc.modify_scf_element(value=value, dist_name=dn, list_name=para_name)
            logger.info("OK: Parameter modified {} = {} under {}".format(para_name, value, dn))
        else:
            logger.info("NOK: dist name {} not in created SCF".format(dn))


class PrepareRelatedMoToCreate(object):
    def __init__(self, ref_cell, offset):
        self.ref_cell = ref_cell
        self.offset = offset
        self.new_rmod_dn = self.calc_new_dn(self.ref_cell.last_rmod_dn)
        self.new_sync_dn = self.calc_new_dn(self.ref_cell.last_sync_dn)
        self.new_nrcell_dn = self.calc_new_dn(self.ref_cell.last_nrcell_dn)
        self.new_nrcellgrp_dn = self.calc_new_dn(self.ref_cell.last_nrcellgrp_dn)
        self.new_lcellnr_dn = self.calc_new_dn(self.ref_cell.last_lcellnr_dn)
        self.new_lcrid = self.calc_new_p_value(self.ref_cell.lcrId)
        self.new_phyCellId = self.calc_new_p_value(self.ref_cell.phyCellId)
        self.new_refNrCellGroup = self.new_nrcellgrp_dn[-1]
        self.new_nrCellList = self.new_nrcell_dn[-1]
        self.new_channel_dn_list = self.get_channel_dn_list()
        self.new_resourcedn = self.new_rmod_dn + "/" + "PHYANT-1"

    def calc_new_dn(self, based_dn):
        based_dn_ind = int(based_dn[-1])
        new_dn_ind = based_dn_ind + self.offset
        new_dn = based_dn[:-1] + str(new_dn_ind)
        return new_dn

    def calc_new_p_value(self, based_value):
        return int(based_value) + int(self.offset)

    def get_channel_dn_list(self):
        channel_dn_list = []
        for channel_id in range(1, self.ref_cell.channel_amount_per_lcellnr+1):
            channel_dn_list.append(self.new_lcellnr_dn + "/" + "CHANNELGROUP-1/CHANNEL-" + str(channel_id))
        return channel_dn_list


class DeleteObjects(object):
    def __init__(self):
        pass

    def delete_cells(self, cell_list, new_scf_path, ref_cell, remove_rmod=False):
        for cell in cell_list:
            self._prepare_cell_delete_objects(nrcellid=cell, ref_cell=ref_cell, remove_rmod=remove_rmod)
        tafScfFunc.save_scf(new_scf_path)
        return new_scf_path

    def get_delete_mo(self, nrcellid, ref_cell, remove_rmod=False):
        nrcellid = str(nrcellid)
        logger.info("###############get target NRCELL-{}###############".format(nrcellid))
        nrcellid_dn = ref_cell.last_nrcell_dn.rstrip(string.digits)+nrcellid
        try:
            lcrid = tafScfFunc.get_value_from_scf(dist_name=nrcellid_dn, p_name="lcrId")
        except KeyError:
            logger.info("ERROR: {}:{} does not exist, pls check your input".format(nrcellid_dn, "lcrId"))
        nrcellgrp_dn, nrcellgrp_remove_mo, nrcell_index = self._find_target_dn(ref_cell=ref_cell,
                                                                               class_name="NRCELLGRP",
                                                                               list_p_name="nrCellList",
                                                                               value=nrcellid)
        nrcellgrpid = nrcellgrp_dn.split("-")[-1]
        logger.info("###############get target NRCELLGRP-{}###############".format(nrcellgrpid))

        logger.info("###############get target NRDU###############")
        nrdu_dn, nrdu_remove_mo, nrcellgrp_index = self._find_target_dn(ref_cell, "NRDU", "refNrCellGroup", nrcellgrpid)
        lcellnr_dn, lcellnr_remove_mo = self._get_lcellnr_dn(ref_cell=ref_cell, class_name="LCELNR", lcrid=lcrid)
        return nrcellid_dn, lcellnr_dn, nrcellgrp_dn, nrdu_dn, nrcellgrp_index

    def _prepare_cell_delete_objects(self, nrcellid, ref_cell, remove_rmod=False):
        nrcellid = str(nrcellid)
        logger.info("############### delete NRCELL-{}###############".format(nrcellid))
        nrcellid_dn = ref_cell.last_nrcell_dn.rstrip(string.digits)+nrcellid
        try:
            lcrid = tafScfFunc.get_value_from_scf(dist_name=nrcellid_dn, p_name="lcrId")
        except KeyError:
            logger.info("ERROR: {}:{} does not exist, pls check your input".format(nrcellid_dn, "lcrId"))
        self._check_mo_and_remove(nrcellid_dn)
        nrcellgrp_dn, nrcellgrp_remove_mo, nrcell_index = self._find_target_dn(ref_cell=ref_cell,
                                                                               class_name="NRCELLGRP",
                                                                               list_p_name="nrCellList",
                                                                               value=nrcellid)
        nrcellgrpid = nrcellgrp_dn.split("-")[-1]
        logger.info("############### delete NRCELLGRP-{}###############".format(nrcellgrpid))
        self._delete_mo_or_element(remove_mo=nrcellgrp_remove_mo, dist_name=nrcellgrp_dn, list_name="nrCellList",
                                   value=nrcellid)
        logger.info("############### delete NRDU###############")
        nrdu_dn, nrdu_remove_mo, nrcellgrp_index = self._find_target_dn(ref_cell, "NRDU", "refNrCellGroup", nrcellgrpid)
        self._delete_mo_or_element(remove_mo=nrdu_remove_mo, dist_name=nrdu_dn, list_name="refNrCellGroup",
                                   value=nrcellgrpid)
        lcellnr_dn, lcellnr_remove_mo = self._get_lcellnr_dn(ref_cell=ref_cell, class_name="LCELNR", lcrid=lcrid)
        if lcellnr_dn:
            logger.info("############### delete RMOD###############")
            rmod_dn_list = tafScfFunc.get_all_values_from_scf_by_pattern(dist_name=lcellnr_dn,
                                                                         p_name="resourceDN|antlDN")
            rmod_dn = rmod_dn_list[0].rstrip(string.digits).rstrip("/PHYANT-").rstrip("/ANTL-")
            self._delete_mo_or_element(remove_mo=True, dist_name=rmod_dn)
            logger.info("############### delete SYNC###############")
            sync_dn, sync_remove_mo, rmod_index = self._find_target_dn(ref_cell=ref_cell,
                                                                       class_name="SYNC",
                                                                       list_p_name="targetDNList",
                                                                       value=rmod_dn)
            if sync_dn:
                self._delete_mo_or_element(remove_mo=sync_remove_mo, dist_name=sync_dn, list_name="targetDNList",
                                           value=rmod_dn)
            logger.info("############### delete LNCEL###############")
            self._delete_mo_or_element(remove_mo=lcellnr_remove_mo, dist_name=lcellnr_dn)

    def _delete_mo_or_element(self, remove_mo, dist_name, list_name=None, value=None):
        if remove_mo is True:
            self._check_mo_and_remove(dist_name)
        if remove_mo is False and list_name is not None:
            self._check_element_and_remove(dist_name=dist_name, list_name=list_name, value=value)

    def _find_target_dn(self, ref_cell, class_name, list_p_name, value):
        mo_list = ref_cell.get_mo_object_list(class_name)
        logger.info("Start to find the target distName for {}={}".format(list_p_name, value))
        for mo in mo_list:
            dn = mo.attrib["distName"]
            list_p_value = ref_cell.get_list_p_value(dn, list_p_name)
            logger.info("Start to find the target distName {}".format(list_p_value))
            if value in list_p_value:
                logger.info("The distName of {}:{} is {}".format(list_p_name, value, dn))
                if len(list_p_value) > 1:
                    logger.info("{} : {} contains multiple element {}".format(dn, list_p_name, list_p_value))
                    remove_mo = False
                if len(list_p_value) == 1:
                    remove_mo = True
                value_index = list_p_value.index(value)
                return dn, remove_mo, value_index
        return '', False, ''

    def _get_the_added_index(self, ref_cell, class_name, list_p_name):
        mo_list = ref_cell.get_mo_object_list(class_name)
        for mo in mo_list:
            dn = mo.attrib["distName"]
            list_p_value = ref_cell.get_list_p_value(dn, list_p_name)
            index = len(list_p_value)
            return index

    def _get_lcellnr_dn(self, ref_cell, class_name, lcrid):
        mo_list = ref_cell.get_mo_object_list(class_name)
        logger.info("Start to find the target distName for LCELNR-{}".format(lcrid))
        for mo in mo_list:
            dn = mo.attrib["distName"]
            if dn.split("-")[-1] == lcrid:
                remove_mo = True
                return dn, remove_mo

    @staticmethod
    def _check_mo_and_remove(target_obj):
        logger.info("Check {} exists".format(target_obj))
        if tafScfFunc.is_object_in_scf(dist_name=target_obj):
            tafScfFunc.remove_mo_with_descendant_mos(dist_name=target_obj)
            logger.info("OK: MO removed: {} ".format(target_obj))

    @staticmethod
    def _check_element_and_remove(dist_name, list_name, value):
        logger.info("Checking {} exists".format(list_name))
        try:
            value_list = tafScfFunc.get_all_values_from_scf(dist_name=dist_name, list_name=list_name)
        except KeyError:
            logger.info("Error:{}:{} does not exist, pls check your input".format(list_name, value))
        else:
            target_index = value_list.index(value)
            print(target_index)
            logger.info("The index of target element is {}".format(target_index))
            tafScfFunc.remove_element_from_scf(dist_name=dist_name, list_name=list_name,
                                               index=target_index)


def gen_new_scf_path(org_scf_path, cell_num):
    scf_dir, scf_name_org = os.path.split(org_scf_path)
    new_scf_name = os.path.splitext(scf_name_org)[0] + '_' + str(cell_num) + 'Cell_Created.xml'
    new_scf_path = os.path.join(scf_dir, new_scf_name)
    if os.path.exists(new_scf_path):
        os.remove(new_scf_path)
    return new_scf_path


def create_multi_cell_scf(scf_path_org, expect_num_of_cell, new_rmods_sn_dict):
    """
    This keyword is used to create multi cells based on the current scf file.

    :param string scf_path_org: the original scf file path, like /home/ute/scf_1cell.xml
    :param int expect_num_of_cell: the expected number of cells
    :param dict new_rmods_sn_dict: the new rmods dn and its serial number mapping, like {'RMOD-2':'1M213303663'}
    :return str: the new scf file path which is in the same directory with the original scf file.
    """
    new_scf = gen_new_scf_path(scf_path_org, expect_num_of_cell)
    ref_cell = CurExistingCells(scf_path=scf_path_org)
    existing_cell_amount = ref_cell.existingNumOfCells

    if expect_num_of_cell > existing_cell_amount:
        iter_of_clone = (expect_num_of_cell - existing_cell_amount) + 1
        logger.info("############### START CREATING {} CELLS SCF ###############".format(expect_num_of_cell))
        logger.info("{} cells on current SCF, {} cells will be added.".format(existing_cell_amount,
                                                                              iter_of_clone-1))
        CloneObjects().clone_objects(ref_cell=ref_cell, iter_num=iter_of_clone, new_scf_path=new_scf)
        logger.info("############### START Modify parameters in created SCF ###############")
        ModifyCreatedObjects().modify_objects(new_rmods_sn_dict,
                                              scf_path=new_scf,
                                              iter_num=iter_of_clone,
                                              ref_cell=ref_cell)
        logger.info("############### END CREATING {} CELLS SCF ###############".format(expect_num_of_cell))
    else:
        logger.info("ERROR: On base SCF exists {} cells. You still want to create SCF with {} cells".format(
            existing_cell_amount, expect_num_of_cell))
    return new_scf


def remove_cells_from_scf(scf_path_org, nrcell_list, remove_rmod=True):
    """
    This keyword is used to remove cells based on the current scf file.

    :param string scf_path_org: the original scf file path, like /home/ute/scf_1cell.xml
    :param list nrcell_list: the expected removed nrcell_index list
    :param bool remove_rmod: the flag indicate rmod need to be removed or not
    :return str: the new scf file path which is in the same directory with the original scf file.
    """
    ref_cell = CurExistingCells(scf_path=scf_path_org)
    scf_dir, scf_name_org = os.path.split(scf_path_org)
    new_scf_name = os.path.splitext(scf_path_org)[0] + '_Cell_removed.xml'
    new_scf_path = os.path.join(scf_dir, new_scf_name)
    if os.path.exists(new_scf_path):
        os.remove(new_scf_path)
    DeleteObjects().delete_cells(cell_list=nrcell_list, new_scf_path=new_scf_path,
                                 ref_cell=ref_cell, remove_rmod=remove_rmod)
    return new_scf_path


def get_delete_cell_mo(scf_path_org, nrcell_id, remove_rmod=False):
    """
    This keyword is used to get the target disname of delete cell.

    :param string scf_path_org: the original scf file path, like /home/ute/scf_1cell.xml
    :param str nrcell_id: the expected removed nrcell_index
    :param bool remove_rmod: the flag indicate rmod need to be removed or not
    :return str: the mo infos.
    """
    ref_cell = CurExistingCells(scf_path=scf_path_org)
    nrcellid_dn, lcellnr_dn, nrcellgrp_dn, nrdu_dn, nrcellgrpid = DeleteObjects().get_delete_mo(nrcellid=nrcell_id,
                                                                                                ref_cell=ref_cell,
                                                                                                remove_rmod=remove_rmod)
    return nrcellid_dn, lcellnr_dn, nrcellgrp_dn, nrdu_dn, nrcellgrpid


def get_add_cell_info(scf_path_org, class_name, list_p_name):
    """
    This keyword is used to get the info for adding cell.

    :param string scf_path_org: the original scf file path, like /home/ute/scf_1cell.xml
    :param str class_name: the class name of MO, like NRDU
    :param str list_p_name: the p name, like refNrCellGroup
    :return str: the info for adding cell.
    """
    ref_cell = CurExistingCells(scf_path=scf_path_org)
    p_value_index = DeleteObjects()._get_the_added_index(ref_cell=ref_cell,
                                                         class_name=class_name,
                                                         list_p_name=list_p_name)
    return p_value_index
