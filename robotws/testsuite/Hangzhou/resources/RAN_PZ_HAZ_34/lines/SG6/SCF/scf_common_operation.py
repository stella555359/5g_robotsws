# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Lin Stella
:contact: stella.lin@nokia-sbell.com
:maintainer: Lin Stella, Chen Jun
:contact: stella.lin@nokia-sbell.com, jun.8.chen@nokia-sbell.com
"""

import re
import logging
import os
from taf.config.scf import scf
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.common_resources.python.common_utilities import get_builtin_value
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__all__ = [
    "perform_update_scf_params",
    "perform_update_scf_params_for_current_scf",
    "add_managed_objects_to_scf",
    "delete_cell_from_scf",
    "update_celltype_for_cells",
]


class SCFCommonOperation:
    def __init__(self):
        self.coam = admin()
        self.scf = scf()
        self.scf_path = "/home/ute/basic_golden_scf.xml"
        self.cell_index_info_dict = {}
        self.mrbts_id = None
        self.nrbts_id = None

    def set_scf_path(self, scf_path):
        self.scf_path = scf_path

    def get_current_scf(self, connection="GNB_OAM", file_name="scf_basic.xml"):
        local_dir_path = get_builtin_value("LOG_PATH")
        self.coam.get_current_scf_file(
            local_dir_path=local_dir_path,
            file_name=file_name,
            export_type="configuration",
            timeout=30,
            connection=connection,
        )
        scf_file_path = os.path.join(local_dir_path, file_name)
        return scf_file_path

    def get_params(self):
        self.mrbts_id, self.nrbts_id = self.get_nrbts_and_mrbts_index()
        logging.debug(
            "cell mrbts and nrbts info:mrbts-{},nrbts-{}".format(
                self.mrbts_id, self.nrbts_id
            )
        )
        self.scf.load_scf(file_path=self.scf_path)
        self.cell_index_info_dict = self.get_cell_index_info()
        logging.debug("cell index info:{}".format(self.cell_index_info_dict))

    def modify_params(self, input_params):
        for input_param in input_params:
            if "list_name" in input_param and input_param["list_name"] != "cellBwpList":
                self.scf.remove_list_from_scf(
                    dist_name=input_param["dist_name"],
                    list_name=input_param["list_name"],
                )
                self.scf.add_list_to_scf(
                    dist_name=input_param["dist_name"],
                    list_name=input_param["list_name"],
                )
                if isinstance(input_param["elements"], list):
                    self.scf.add_elements_to_list(
                        dist_name=input_param["dist_name"],
                        list_name=input_param["list_name"],
                        elements=input_param["elements"],
                    )
                elif isinstance(input_param["elements"], dict):
                    for list_dict_item in input_param["elements"].values():
                        self.scf.add_item_to_list(
                            dist_name=input_param["dist_name"],
                            list_name=input_param["list_name"],
                            elements=list_dict_item,
                        )
            elif "p_name" in input_param and "list_name" not in input_param:
                self.scf.modify_scf_element(
                    value=input_param["value"],
                    dist_name=input_param["dist_name"],
                    p_name=input_param["p_name"],
                )
            elif "p_name" in input_param and input_param["list_name"] == "cellBwpList"\
                    and input_param["p_name"] == "bwpDN":
                self.scf.modify_scf_element(
                    value=input_param["value"],
                    dist_name=input_param["dist_name"],
                    p_name=input_param["p_name"],
                    list_name=input_param["list_name"],
                    index=input_param["index"],
                )

    def update_scf_params(self, update_params):
        """
        TODO: some operation are not support yet, need to be written .
        :param update_params: list
        :return: None
        """
        self.scf.perform_scf_modification(modification_strings=update_params)

    def add_mo_to_scf(self, source_mo_dist_name, target_mo_dist_name):
        self.scf.clone_mo_with_descendant_mos(
            source_mo_dist_name=source_mo_dist_name,
            target_mo_dist_name=target_mo_dist_name,
        )

    def delete_mo_to_scf(self, delete_mo_dist_name):
        self.scf.remove_mo_with_descendant_mos(dist_name=delete_mo_dist_name)

    def update_element_without_p_name_in_list(
        self, dist_name, list_name, update_elements
    ):
        self.scf.remove_list_from_scf(dist_name=dist_name, list_name=list_name)
        self.scf.add_list_to_scf(dist_name=dist_name, list_name=list_name)
        self.scf.add_elements_to_list(
            dist_name=dist_name, list_name=list_name, elements=update_elements
        )

    def get_nrbts_and_mrbts_index(self):
        with open(self.scf_path, "r") as f:
            scf_data = f.read()
            mrbts_regex = r".*MRBTS\" distName=\"MRBTS-(.*?)\" version=\""
            mrbts_id = "".join(re.findall(mrbts_regex, scf_data))
            nrbts_regex = r".*NRBTS\" distName=\".*\/NRBTS-(.*?)\" version=\"NRBTS"
            nrbts_id = "".join(re.findall(nrbts_regex, scf_data))
            return mrbts_id, nrbts_id

    def get_cell_index_info(self):
        with open(self.scf_path, "r") as f:
            scf_data = f.read()
            all_cell_regex = (
                r".*NRCELL\" distName=\".*/.*/NRCELL-(.*?)\" version=\"NRBTS.*"
            )
            fdd_cell_suffix_re = r".*NRCELL_FDD\" distName=\".*/.*/NRCELL-(.*?)/NRCELL_FDD-(.*?)\" version=\"NRBTS.*"
            all_cell_index_list = re.findall(all_cell_regex, scf_data)
            fdd_cell_suffix_index_list = re.findall(fdd_cell_suffix_re, scf_data)
            all_cell_index_info_dict = {}
            for element in fdd_cell_suffix_index_list:
                fdd_cell_index_info_dict = {}
                fdd_cell_index_info_dict["fdd_cell_suffix"] = element[1]
                fdd_cell_index_info_dict["technology"] = "FDD"
                all_cell_index_list.remove(element[0])
                all_cell_index_info_dict[element[0]] = fdd_cell_index_info_dict
            for item in all_cell_index_list:
                chbw = self.get_chbw_value(cell_id=item)
                framestructure = self.get_framestructure_type(cell_id=item)
                tdd_cell_index_info_dict = {}
                tdd_cell_index_info_dict["technology"] = "TDD"
                tdd_cell_index_info_dict["chbw"] = chbw
                tdd_cell_index_info_dict["framestructure"] = framestructure
                all_cell_index_info_dict[item] = tdd_cell_index_info_dict
            return all_cell_index_info_dict

    def get_chbw_value(self, cell_id):
        chbw = self.scf.get_value_from_scf(
            dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                self.mrbts_id, self.nrbts_id, cell_id
            ),
            p_name="chBw",
        )
        return chbw

    def get_framestructure_type(self, cell_id):
        frameStructureType = self.scf.get_value_from_scf(
            dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                self.mrbts_id, self.nrbts_id, cell_id
            ),
            p_name="frameStructureType",
            list_name="tddFrameStructure",
        )
        if frameStructureType == "tdLte":
            lteToNrFrameShift = self.scf.get_value_from_scf(
                dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                    self.mrbts_id, self.nrbts_id, cell_id
                ),
                p_name="lteToNrFrameShift",
                list_name="tddFrameStructure",
            )
            if lteToNrFrameShift == "0ms":
                framestructure = "11160ms"
            else:
                framestructure = "11163ms"
        else:
            ulDlDataSlotRatio = self.scf.get_value_from_scf(
                dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                    self.mrbts_id, self.nrbts_id, cell_id
                ),
                p_name="ulDlDataSlotRatio",
                list_name="tddFrameStructure",
            )
            if ulDlDataSlotRatio == "1/4":
                framestructure = "1208"
            else:
                framestructure = "1070"
        return framestructure

    def get_nrcell_mo_version(self):
        with open(self.scf_path, "r") as f:
            scf_data = f.read()
            nrcell_version_regex = (
                r".*NRBTS\" distName=\".*\/NRBTS-.*\/NRCELL-\d+\" version=\"(.*?)"
            )
            nrcell_version = "".join(re.findall(nrcell_version_regex, scf_data))
            return nrcell_version

    def get_channel_mo_version(self):
        with open(self.scf_path, "r") as f:
            scf_data = f.read()
            channel_version_regex = (
                r".*CHANNELGROUP\" distName=\".*\/CHANNELGROUP-\d+\" version=\"(.*?)\""
            )
            channel_version = re.findall(channel_version_regex, scf_data)
            return channel_version[0]

    def get_channel_mo_class_name(self):
        with open(self.scf_path, "r") as f:
            scf_data = f.read()
            channel_class_regex = r".*class=\"(.*):CHANNELGROUP\" distName=\".*\/CHANNELGROUP-\d+\" version=\".*?\""
            channel_class = re.findall(channel_class_regex, scf_data)
            return channel_class[0]

    def add_cellmapping_mo(self):
        class_name = "{}:CELLMAPPING".format(self.get_channel_mo_class_name())
        version = self.get_channel_mo_version()
        distname = "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1".format(
            tl.gnbs[0].instance_id
        )
        self.scf.add_object_to_scf(
            class_name=class_name, dist_name=distname, version=version
        )

    def add_lcelnr_mo(self, lcelnr_index):
        class_name = "{}:LCELNR".format(self.get_channel_mo_class_name())
        version = self.get_channel_mo_version()
        distname = "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{}".format(
            tl.gnbs[0].instance_id, str(lcelnr_index)
        )
        self.scf.add_object_to_scf(
            class_name=class_name, dist_name=distname, version=version
        )
        self.scf.add_element_to_scf(
            dist_name=distname, p_name="actAsiDistMimoNr", value="false"
        )
        self.scf.add_element_to_scf(
            dist_name=distname, p_name="actSimplChConfMAA", value="false"
        )

    def add_channelgroup_mo(self, lcelnr_index, channelgroup_index):
        class_name = "{}:CHANNELGROUP".format(self.get_channel_mo_class_name())
        version = self.get_channel_mo_version()
        distname = (
            "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{}/CHANNELGROUP-{}".format(
                tl.gnbs[0].instance_id, str(lcelnr_index), str(channelgroup_index)
            )
        )
        self.scf.add_object_to_scf(
            class_name=class_name, dist_name=distname, version=version
        )

    def add_channel_mo_for_one_channel_group(
        self,
        lcelnr_index,
        channelgroup_index,
        rmod_index,
        direction="TX",
        channel_index_start=1,
        channel_number=4,
    ):
        class_name = "{}:CHANNEL".format(self.get_channel_mo_class_name())
        version = self.get_channel_mo_version()
        for channel_index in range(
            int(channel_index_start), int(channel_index_start) + int(channel_number)
        ):
            distname = "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{}/CHANNELGROUP-{}/CHANNEL-{}".format(
                tl.gnbs[0].instance_id,
                str(lcelnr_index),
                str(channelgroup_index),
                channel_index,
            )
            self.scf.add_object_to_scf(
                class_name=class_name, dist_name=distname, version=version
            )
            self.scf.add_element_to_scf(
                dist_name=distname, p_name="direction", value=direction
            )
            self.scf.add_element_to_scf(
                dist_name=distname,
                p_name="resourceDN",
                value="MRBTS-{}/EQM-1/APEQM-1/RMOD-{}/PHYANT-1".format(
                    tl.gnbs[0].instance_id, rmod_index
                ),
            )


def perform_update_scf_params(
    update_params=[],
    basic_scf_path="/home/ute/SCF/basic_golden_scf.xml",
    update_scf_path="/home/ute/SCF/basic_golden_scf_update.xml",
):
    if update_params is None:
        update_params = []
    scf_obj = SCFCommonOperation()
    scf_obj.scf.load_scf(file_path=basic_scf_path)
    scf_obj.update_scf_params(update_params=update_params)
    scf_obj.scf.save_scf(file_path=update_scf_path)
    return update_scf_path


def add_managed_objects_to_scf(
    source_mo_dist_name_list=[],
    target_mo_dist_name_list=[],
    basic_scf_path="/home/ute/SCF/basic_golden_scf.xml",
    update_scf_path="/home/ute/SCF/basic_golden_scf_update.xml",
):
    if source_mo_dist_name_list is None:
        source_mo_dist_name_list = []
    if target_mo_dist_name_list is None:
        target_mo_dist_name_list = []
    scf_obj = SCFCommonOperation()
    scf_obj.scf.load_scf(file_path=basic_scf_path)
    for index in range(len(source_mo_dist_name_list)):
        scf_obj.add_mo_to_scf(
            source_mo_dist_name=source_mo_dist_name_list[index],
            target_mo_dist_name=target_mo_dist_name_list[index],
        )
    scf_obj.scf.save_scf(file_path=update_scf_path)
    return update_scf_path


def perform_update_scf_params(
    update_params=[],
    basic_scf_path="/home/ute/SCF/basic_golden_scf.xml",
    update_scf_path="/home/ute/SCF/basic_golden_scf_update.xml",
):
    if update_params is None:
        update_params = []
    scf_obj = SCFCommonOperation()
    scf_obj.scf.load_scf(file_path=basic_scf_path)
    scf_obj.update_scf_params(update_params=update_params)
    scf_obj.scf.save_scf(file_path=update_scf_path)
    return update_scf_path


def perform_update_scf_params_for_current_scf(update_params=[], connection="GNB_OAM"):
    if update_params is None:
        update_params = []
    scf_obj = SCFCommonOperation()
    scf_file_path = scf_obj.get_current_scf(connection=connection)
    scf_obj.scf.load_scf(file_path=scf_file_path)
    scf_obj.update_scf_params(update_params=update_params)
    local_dir_path = get_builtin_value("LOG_PATH")
    update_scf_path = os.path.join(local_dir_path, "scf_basic_UPDATE.xml")
    scf_obj.scf.save_scf(file_path=update_scf_path)
    return update_scf_path


def delete_cell_from_scf(
    cell_indexs=[],
    cell_group_indexs=[],
    channel_mapping_lcelnr_indexs=[],
    basic_scf_path="/home/ute/SCF/basic_golden_scf.xml",
    update_scf_path="/home/ute/SCF/basic_golden_scf_update.xml",
):
    """
    Auther: Stella
    :param:cell_indexs: delete cell indexs list
    :param:cell_group_indexs: delete cell group indexs list
    :param:channel_mapping_lcelnr_indexs: lcelnr index under mo "MRBTS-xxx/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1"
    """
    scf_obj = SCFCommonOperation()
    scf_obj.scf.load_scf(file_path=basic_scf_path)
    delete_mos = []
    cell_mos = []
    cell_group_mos = []
    channel_mos = []
    for cell_index in cell_indexs:
        cell_mo = "MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
            tl.gnbs[0].instance_id, tl.gnbs[0].global_bts_id, cell_index
        )
        cell_mos.append(cell_mo)
    for cell_group_index in cell_group_indexs:
        cell_group_mo = "MRBTS-{}/NRBTS-{}/NRCELLGRP-{}".format(
            tl.gnbs[0].instance_id, tl.gnbs[0].global_bts_id, cell_group_index
        )
        cell_group_mos.append(cell_group_mo)
    for channel_index in channel_mapping_lcelnr_indexs:
        channel_mo = "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{}".format(
            tl.gnbs[0].instance_id, channel_index
        )
        channel_mos.append(channel_mo)
    delete_mos.extend(cell_mos)
    delete_mos.extend(cell_group_mos)
    delete_mos.extend(channel_mos)
    logging.debug("following objects will be removed:{}".format(delete_mos))
    for delete_mo in delete_mos:
        scf_obj.delete_mo_to_scf(delete_mo_dist_name=delete_mo)
    origin_refNrCellGroup_list = scf_obj.scf.get_all_values_from_scf(
        dist_name="MRBTS-{}/NRBTS-{}/NRDU-1".format(
            tl.gnbs[0].instance_id, tl.gnbs[0].global_bts_id
        ),
        list_name="refNrCellGroup",
    )
    update_refNrCellGroup_list = [
        x for x in origin_refNrCellGroup_list if str(x) not in cell_group_indexs
    ]
    logging.debug("update refNrCellGroup list is {}".format(update_refNrCellGroup_list))
    scf_obj.update_element_without_p_name_in_list(
        dist_name="MRBTS-{}/NRBTS-{}/NRDU-1".format(
            tl.gnbs[0].instance_id, tl.gnbs[0].global_bts_id
        ),
        list_name="refNrCellGroup",
        update_elements=update_refNrCellGroup_list,
    )
    scf_obj.scf.save_scf(file_path=update_scf_path)
    return update_scf_path


def update_celltype_for_cells(
    celltype_info_dict_list,
    basic_scf_path="/home/ute/SCF/basic_golden_scf.xml",
    update_scf_path="/home/ute/SCF/basic_golden_scf_update.xml",
):
    """
    Auther: Stella
    :param:celltype_info_dict_list : dict keys["celltype","cell_index","lcelnr_index","rmod_index",
    "rx_channel_number","tx_channel_number"]
    eg: [{"celltype":"8DL8UL", "cell_index":"1","lcelnr_index":"1","rmod_index":"1",
    "rx_channel_number":"8","tx_channel_number":"4"},
    {"celltype":"16DL8UL", "cell_index":"2","lcelnr_index":"2","rmod_index":"2",
    "rx_channel_number":"4","tx_channel_number":"4"},
    {"celltype":"8DL4UL", "cell_index":"3","lcelnr_index":"3","rmod_index":"3",
    "rx_channel_number":"4","tx_channel_number":"4"},
    ]
    """
    scf_obj = SCFCommonOperation()
    scf_obj.set_scf_path(scf_path=basic_scf_path)
    scf_obj.scf.load_scf(file_path=basic_scf_path)
    scf_obj.delete_mo_to_scf(
        delete_mo_dist_name="MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1".format(
            tl.gnbs[0].instance_id
        )
    )
    scf_obj.add_cellmapping_mo()
    for celltype_info_dict in celltype_info_dict_list:
        scf_obj.add_lcelnr_mo(lcelnr_index=celltype_info_dict["lcelnr_index"])
        total_tx_channels = celltype_info_dict["celltype"].split("DL")[0]
        logging.debug("total_tx_channels is {}".format(total_tx_channels))
        total_rx_channels = (
            celltype_info_dict["celltype"].split("DL")[-1].split("UL")[0]
        )
        logging.debug("total_rx_channels is {}".format(total_rx_channels))
        logging.debug("start to add tx channel...")
        tx_channel_index_start = 1
        rx_channel_index_start = int(tx_channel_index_start) + int(
            celltype_info_dict["tx_channel_number"]
        )
        for tx_index in range(1, (int(int(total_tx_channels) / 4)) + 1):
            logging.debug("tx_chnnelgroup_index is {}".format(tx_index))
            channelgroup_index = tx_index
            scf_obj.add_channelgroup_mo(
                lcelnr_index=celltype_info_dict["lcelnr_index"],
                channelgroup_index=channelgroup_index,
            )
            scf_obj.add_channel_mo_for_one_channel_group(
                lcelnr_index=celltype_info_dict["lcelnr_index"],
                channelgroup_index=channelgroup_index,
                rmod_index=celltype_info_dict["rmod_index"],
                direction="TX",
                channel_index_start=tx_channel_index_start,
                channel_number=celltype_info_dict["tx_channel_number"],
            )
        logging.debug("start to add rx channel...")
        for rx_index in range(
            1,
            (int(int(total_rx_channels) / int(celltype_info_dict["rx_channel_number"])))
            + 1,
        ):
            logging.debug("rx_chnnelgroup_index is {}".format(rx_index))
            channelgroup_index = rx_index
            scf_obj.add_channel_mo_for_one_channel_group(
                lcelnr_index=celltype_info_dict["lcelnr_index"],
                channelgroup_index=channelgroup_index,
                rmod_index=celltype_info_dict["rmod_index"],
                direction="RX",
                channel_index_start=rx_channel_index_start,
                channel_number=celltype_info_dict["rx_channel_number"],
            )
        logging.debug("start to modify celltype related parameters")
        scf_obj.scf.modify_scf_element(
            value=celltype_info_dict["celltype"],
            dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                tl.gnbs[0].instance_id,
                tl.gnbs[0].global_bts_id,
                celltype_info_dict["cell_index"],
            ),
            p_name="nrCellType",
        )
        scf_obj.scf.modify_scf_element(
            value="{}Rx".format(str(celltype_info_dict["rx_channel_number"])),
            dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                tl.gnbs[0].instance_id,
                tl.gnbs[0].global_bts_id,
                celltype_info_dict["cell_index"],
            ),
            p_name="numberOfRxBeamforming",
        )
    scf_obj.scf.save_scf(file_path=update_scf_path)
    return update_scf_path
