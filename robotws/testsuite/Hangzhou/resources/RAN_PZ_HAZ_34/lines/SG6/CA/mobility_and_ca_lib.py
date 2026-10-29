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
import random
import itertools
from collections import defaultdict
from taf.sbts.oam.coam.admin import admin
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_gnb_classical import *
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_parameter import *
from robot.libraries.BuiltIn import BuiltIn
from random import choice


__all__ = [
    "ARFCN_TO_SSB_FREQUENCY_TABLE",
    "GnbOperation",
    "EnbOperation",
    "MobilityCAConfiguration",
]

coam = admin()
tl = BuiltIn().get_variable_value("${tl}")

ARFCN_TO_SSB_FREQUENCY_TABLE = {
    510000: 509790,
    525996: 525870,
    639672: 639648,
    519000: 518910,
    636672: 636672,
    633334: 633312,
    531000: 530910,
    526998: 526830,
    517800: 517710,
    523800: 523710,
    630000: 629952,
    636670: 636768,
    640000: 639936,
    532800: 532590,
    634700: 634656,
    633000: 632928,
    625000: 624960,
    637368: 637344,
    650000: 649920,
    470000: 470210,
    624600: 624576,
    528000: 524190,
    513990: 514110,
    126400: 126490,
    128500: 128650,
    424000: 423850,
    392020: 391930,
    432000: 431790,
}


class GnbOperation:
    def __init__(self, connection="GNB_OAM0"):
        self._connection = connection
        pass

    def get_rmod_bbmod_mapping(self):
        rmod_mapping = coam.get_detected_hw_info(connection=self._connection)
        logging.debug("rmod_mapping result is {}".format(rmod_mapping))
        rmod_bbmod_mapping = {}
        for cable in rmod_mapping["cables"]:
            try:
                rmod_port_id = cable["secondEndPointId"]["configuration"]
            except Exception as e:
                rmod_port_id = "null"
                logging.debug("fail to get rmod_port_id".format(e))
            try:
                bbmod_port_id = cable["firstEndPointId"]["configuration"]
            except Exception as e:
                bbmod_port_id = "null"
                logging.debug("fail to get bbmod_port_id".format(e))
            # rmod_port_id = cable["secondEndPointId"]["configuration"]
            # bbmod_port_id = cable["firstEndPointId"]["configuration"]
            if "BBMOD" in bbmod_port_id and "RMOD" in rmod_port_id:
                rmod_index = re.match(r".*RMOD-(\d+).*", rmod_port_id).group(1)
                bbmod_index = bbmod_port_id.split("/")[-2].split("-")[-1]
                bbmod_list = []
                rmod_list = rmod_bbmod_mapping.keys()
                if rmod_index in rmod_list:
                    exist_bbmod_list = rmod_bbmod_mapping[rmod_index]
                    if bbmod_index not in exist_bbmod_list:
                        exist_bbmod_list.append(bbmod_index)
                    rmod_bbmod_mapping[rmod_index] = exist_bbmod_list
                else:
                    bbmod_list.append(bbmod_index)
                    rmod_bbmod_mapping[rmod_index] = bbmod_list
            else:
                logging.debug(
                    "*** not valid info: bbmod:{},rmod:{}, skip ***".format(
                        bbmod_port_id, rmod_port_id
                    )
                )
        return rmod_bbmod_mapping

    def get_rmod_bbmod_linkmode_mapping(self):
        rmod_mapping = coam.get_detected_hw_info(connection=self._connection)
        logging.debug("rmod_mapping result is {}".format(rmod_mapping))
        rmod_bbmod_mapping = {}
        for cable in rmod_mapping["cables"]:
            rmod_dic = cable["secondEndPointId"]
            bbmod_dic = cable["firstEndPointId"]
            if (
                "configuration" in rmod_dic.keys()
                and "configuration" in bbmod_dic.keys()
            ):
                rmod_port_id = rmod_dic.get("configuration")
                bbmod_port_id = bbmod_dic.get("configuration")
            else:
                continue
            link_mode_vlaue = cable["linkMode"]["configuration"]
            logging.debug(
                "rmod_bbmod_linkmode is {} {} {}".format(
                    rmod_mapping, bbmod_port_id, link_mode_vlaue
                )
            )
            if "BBMOD" in bbmod_port_id and "RMOD" in rmod_port_id:
                rmod_index = re.match(r".*RMOD-(\d+).*", rmod_port_id).group(1)
                bbmod_index = bbmod_port_id.split("/")[-2].split("-")[-1]
                bbmod_list = []
                rmod_list = rmod_bbmod_mapping.keys()
                logging.debug(
                    "rmod_bbmod_linkmode1 is {} {} {} {}".format(
                        rmod_index, bbmod_index, bbmod_list, rmod_list
                    )
                )
                if rmod_index in rmod_list:
                    exist_bbmod_list = rmod_bbmod_mapping[rmod_index]
                    logging.debug(
                        "exist_bbmod_list result is {}".format(exist_bbmod_list)
                    )
                    if bbmod_index not in exist_bbmod_list and link_mode_vlaue:
                        exist_bbmod_list.append(bbmod_index)
                    rmod_bbmod_mapping[rmod_index] = exist_bbmod_list
                else:
                    if link_mode_vlaue:
                        bbmod_list.append(bbmod_index)
                    rmod_bbmod_mapping[rmod_index] = bbmod_list
            else:
                logging.debug(
                    "*** not valid info: bbmod:{},rmod:{}, skip ***".format(
                        bbmod_port_id, rmod_port_id
                    )
                )
        return rmod_bbmod_mapping

    def get_arfcnSsbPbch_config(self):
        mo_list = coam.get_managed_objects(
            class_name="NRCELL_R", connection=self._connection
        )
        logging.debug("arfcnSsbPbch_config result is {}".format(mo_list))
        arfcnSsbPbch_mapping = {}
        for mo in mo_list:
            dist_name = mo["distName"]
            cell_idx = dist_name.split("-")[-1]
            arfcnSsbPbch = mo["parameters"]["arfcnSsbPbch"]
            arfcnSsbPbch_mapping[cell_idx] = arfcnSsbPbch
        return arfcnSsbPbch_mapping

    def get_xn_cplane_ip_address(self):
        mrbts_id = tl.gnbs[int(self._connection.split("M")[-1])].instance_id
        nrbts_id = tl.gnbs[int(self._connection.split("M")[-1])].global_bts_id
        logging.debug("nrbts is{}{}".format(mrbts_id, nrbts_id))
        xn_c_mo = get_single_value_from_scf_file(
            parameter="ipV4AddressDN1",
            list_name="xnCplane",
            dist_name="MRBTS-{}/NRBTS-{}".format(mrbts_id, nrbts_id),
            connection=self._connection,
            timeout=30,
        )
        xn_c_ip = get_single_value_from_scf_file(
            parameter="localIpAddr",
            dist_name=xn_c_mo,
            connection=self._connection,
            timeout=30,
        )
        logging.debug("xn_c_ip is {}".format(xn_c_ip))
        return xn_c_ip

    def get_plmn_info(self):
        mrbts_id = tl.gnbs[int(self._connection.split("M")[-1])].instance_id
        nrbts_id = tl.gnbs[int(self._connection.split("M")[-1])].global_bts_id
        logging.debug("nrbts is{}{}".format(mrbts_id, nrbts_id))
        mcc = get_single_value_from_scf_file(
            parameter="mcc",
            dist_name="MRBTS-{}/NRBTS-{}".format(mrbts_id, nrbts_id),
            connection=self._connection,
            timeout=30,
        )
        mnc = get_single_value_from_scf_file(
            parameter="mnc",
            dist_name="MRBTS-{}/NRBTS-{}".format(mrbts_id, nrbts_id),
            connection=self._connection,
            timeout=30,
        )
        mncLength = get_single_value_from_scf_file(
            parameter="mncLength",
            dist_name="MRBTS-{}/NRBTS-{}".format(mrbts_id, nrbts_id),
            connection=self._connection,
            timeout=30,
        )
        plmn_info = {}
        plmn_info["mcc"] = mcc
        plmn_info["mnc"] = mnc
        plmn_info["mncLength"] = mncLength
        logging.debug("plmn_info is {}".format(plmn_info))
        return plmn_info

    def get_gnb_id_length(self):
        mrbts_id = tl.gnbs[int(self._connection.split("M")[-1])].instance_id
        nrbts_id = tl.gnbs[int(self._connection.split("M")[-1])].global_bts_id
        logging.debug("nrbts is{}{}".format(mrbts_id, nrbts_id))
        gnb_id_length = get_single_value_from_scf_file(
            parameter="gNbIdLength",
            dist_name="MRBTS-{}/NRBTS-{}".format(mrbts_id, nrbts_id),
            connection=self._connection,
            timeout=30,
        )
        logging.debug("gnb id length is {}".format(gnb_id_length))
        return gnb_id_length

    def get_rmod_sn_mapping(self):
        frm_mapping = coam.get_frm(connection=self._connection)
        logging.debug("frm_mapping result is {}".format(frm_mapping))
        rmod_sn_mapping = {}
        for element in frm_mapping:
            rmod = element["id"]["configuration"]
            rmod_index = re.match(r".*RMOD-(\d+)", rmod).group(1)
            serial_number = element["serialNumber"]
            rmod_sn_mapping[rmod_index] = serial_number
        return rmod_sn_mapping

    def get_sn_ru_index_in_int_mapping(self):
        ru_list_in_init = tl.gnbs[int(self._connection.split("M")[-1])].dus[0].rus
        logging.debug("ru_list_in_init result is {}".format(ru_list_in_init))
        sn_ru_index_in_int_mapping = {}
        for element in ru_list_in_init:
            ru_index = ru_list_in_init.index(element)
            logging.debug("ru_index result is {}".format(ru_index))
            ru_sn = (
                tl.gnbs[int(self._connection.split("M")[-1])]
                .dus[0]
                .rus[ru_index]
                .serial_number
            )
            logging.debug("ru_sn of {} result is {}".format(ru_index, ru_sn))
            if ru_sn is not None:
                sn_ru_index_in_int_mapping[ru_sn] = ru_index
            else:
                pass
        return sn_ru_index_in_int_mapping

    def get_meas_config(self, cell_index):
        nrbts_id = str(tl.gnbs[int(self._connection.split("M")[-1])].global_bts_id)
        try:
            A1_scell_addition_rsrp_tdd = get_single_value_from_scf_file(
                parameter="a1ThresholdSCellAddSsbRsrpTDD",
                dist_name="NRBTS-{}/NRCELL-{}".format(nrbts_id, cell_index),
                list_name="a1MeasSCellAddSsbRsrp",
                connection=self._connection,
                timeout=300,
            )
        except Exception as e:
            A1_scell_addition_rsrp_tdd = None
            logging.debug(
                "no a1ThresholdSCellAddSsbRsrpTDD configured for cell-{}".format(
                    cell_index
                )
            )
        try:
            A1_scell_addition_rsrp_fdd = get_single_value_from_scf_file(
                parameter="a1ThresholdSCellAddSsbRsrpFDD",
                dist_name="NRBTS-{}/NRCELL-{}".format(nrbts_id, cell_index),
                list_name="a1MeasSCellAddSsbRsrp",
                connection=self._connection,
                timeout=300,
            )
        except Exception as e:
            A1_scell_addition_rsrp_fdd = None
            logging.debug(
                "no a1ThresholdSCellAddSsbRsrpFDD configured for cell-{}".format(
                    cell_index
                )
            )
        try:
            A2_scell_release_rsrp = get_single_value_from_scf_file(
                parameter="a2ThresholdSCellRelSsbRsrp",
                dist_name="NRBTS-{}/NRCELL-{}".format(nrbts_id, cell_index),
                list_name="a2MeasSCellRelSsbRsrp",
                connection=self._connection,
            )
        except Exception as e:
            A2_scell_release_rsrp = None
            logging.debug(
                "no a2ThresholdSCellRelSsbRsrp configured for cell-{}".format(
                    cell_index
                )
            )
        try:
            A2_ho_rsrp = get_single_value_from_scf_file(
                parameter="a2ThresholdhoSsbRsrpSA",
                dist_name="NRBTS-{}/NRCELL-{}".format(nrbts_id, cell_index),
                list_name="a2MeashoSsbRsrpSA",
                connection=self._connection,
                timeout=300,
            )
        except Exception as e:
            A2_ho_rsrp = None
            logging.debug(
                "no a2ThresholdhoSsbRsrpSA configured for cell-{}".format(cell_index)
            )
        meas_config_dict = {
            "A1_scell_addition_rsrp_tdd": A1_scell_addition_rsrp_tdd,
            "A1_scell_addition_rsrp_fdd": A1_scell_addition_rsrp_fdd,
            "A2_scell_release_rsrp": A2_scell_release_rsrp,
            "A2_ho_rsrp": A2_ho_rsrp,
        }
        return meas_config_dict

    def get_cell_mapping(self, gnb_index=0, alias='coam_alias'):
        cell_mapping = get_relation_mapping_between_cell_index_and_other_ids(
            connection_alias=self._connection,
            gnb_index=gnb_index,
            alias=alias
        )
        cell_indexs = cell_mapping.keys()
        arfcnSsbPbch_mapping_res = self.get_arfcnSsbPbch_config()
        logging.debug(
            "cell_index to arfcnSsbPbch mapping is {}".format(arfcnSsbPbch_mapping_res)
        )
        nrbts_id = str(tl.gnbs[int(self._connection.split("M")[-1])].global_bts_id)
        rmod_bbmod_mapping_res = self.get_rmod_bbmod_mapping()
        logging.debug("rmod to bbmod mapping is {}".format(rmod_bbmod_mapping_res))
        rmod_sn_mapping_res = self.get_rmod_sn_mapping()
        logging.debug("rmod to serial_number mapping is {}".format(rmod_sn_mapping_res))
        sn_ru_index_in_int_mapping_res = self.get_sn_ru_index_in_int_mapping()
        logging.debug(
            "serial_number to ru_index in int mapping is {}".format(
                sn_ru_index_in_int_mapping_res
            )
        )
        for cell_index in cell_indexs:
            rmod = cell_mapping[cell_index]["detail_cells_info"]["carrierList"][0][
                "antennaLineId"
            ]["configuration"]
            rmod_index = re.match(r".*RMOD-(\d+)", rmod).group(1)
            bbmod_index = rmod_bbmod_mapping_res[rmod_index]
            serial_number = rmod_sn_mapping_res[rmod_index]
            serial_number_in_int = sn_ru_index_in_int_mapping_res.__len__()
            logging.debug(
                "the length of serial_number_in_int is {}".format(serial_number_in_int)
            )
            if serial_number_in_int != 0:
                ru_index = int(sn_ru_index_in_int_mapping_res[serial_number])
            else:
                ru_index = int(rmod_index) - 1
            cell_technology = cell_mapping[cell_index]["detail_cells_info"][
                "technology"
            ]
            ssbfrequency = arfcnSsbPbch_mapping_res[str(cell_index)]
            logging.debug("ssbfrequency is:{}".format(ssbfrequency))
            weightForSCellSelection = get_single_value_from_scf_file(
                parameter="weightForSCellSelection",
                dist_name="NRBTS-{}/NRCELL-{}".format(nrbts_id, cell_index),
                connection=self._connection,
                timeout=300,
            )
            maxNumOfSCellAlloc = get_single_value_from_scf_file(
                parameter="maxNumOfSCellAlloc",
                dist_name="NRBTS-{}/NRCELL-{}".format(nrbts_id, cell_index),
                connection=self._connection,
                timeout=300,
            )
            gscn = get_single_value_from_scf_file(
                parameter="gscnOrSsPbchArfcn",
                dist_name="NRBTS-{}/NRCELL-{}".format(nrbts_id, cell_index),
                connection=self._connection,
                timeout=300,
            )
            if cell_technology == "TDD":
                logging.debug(
                    "start to get framestructure type for cell-{}".format(cell_index)
                )
                frameStructureType = get_single_value_from_scf_file(
                    parameter="frameStructureType",
                    dist_name="NRBTS-{}/NRCELL-{}".format(nrbts_id, cell_index),
                    list_name="tddFrameStructure",
                    connection=self._connection,
                    timeout=300,
                )
                if frameStructureType == "tdLte":
                    framestructure = "1116"
                elif frameStructureType == "semiStatic":
                    ulDlDataSlotRatio = get_single_value_from_scf_file(
                        parameter="ulDlDataSlotRatio",
                        dist_name="NRBTS-{}/NRCELL-{}".format(nrbts_id, cell_index),
                        list_name="tddFrameStructure",
                        connection=self._connection,
                        timeout=300,
                    )
                    if ulDlDataSlotRatio == "3/7":
                        framestructure = "1070"
                    else:
                        framestructure = "1208"
                logging.debug("framestructure is {}".format(framestructure))
                cell_mapping[cell_index]["framestructure"] = framestructure
            else:
                cell_mapping[cell_index]["framestructure"] = None
            meas_config = self.get_meas_config(cell_index)
            cell_mapping[cell_index][
                "weightForSCellSelection"
            ] = weightForSCellSelection
            cell_mapping[cell_index]["maxNumOfSCellAlloc"] = maxNumOfSCellAlloc
            cell_mapping[cell_index]["ru_index_mapping"] = str(ru_index)
            cell_mapping[cell_index]["ssbfrequency"] = ssbfrequency
            cell_mapping[cell_index]["bbmod_index"] = bbmod_index
            cell_mapping[cell_index]["rmod_index"] = rmod_index
            cell_mapping[cell_index]["gscn"] = gscn
            cell_mapping[cell_index]["meas_config"] = meas_config
        return cell_mapping

    def get_cell_mapping_for_tmo(self, gnb_index=0, alias='coam_alias'):
        cell_mapping = get_relation_mapping_between_cell_index_and_other_ids(
            connection_alias=self._connection,
            gnb_index=gnb_index,
            alias=alias
        )
        cell_indexs = cell_mapping.keys()
        arfcnSsbPbch_mapping_res = self.get_arfcnSsbPbch_config()
        logging.debug(
            "cell_index to arfcnSsbPbch mapping is {}".format(arfcnSsbPbch_mapping_res)
        )
        nrbts_id = str(tl.gnbs[int(self._connection.split("M")[-1])].global_bts_id)
        rmod_bbmod_mapping_res = self.get_rmod_bbmod_mapping()
        logging.debug("rmod to bbmod mapping is {}".format(rmod_bbmod_mapping_res))
        rmod_sn_mapping_res = self.get_rmod_sn_mapping()
        logging.debug("rmod to serial_number mapping is {}".format(rmod_sn_mapping_res))
        sn_ru_index_in_int_mapping_res = self.get_sn_ru_index_in_int_mapping()
        logging.debug(
            "serial_number to ru_index in int mapping is {}".format(
                sn_ru_index_in_int_mapping_res
            )
        )
        for cell_index in cell_indexs:
            rmod = cell_mapping[cell_index]["detail_cells_info"]["carrierList"][0][
                "antennaLineId"
            ]["configuration"]
            rmod_index = re.match(r".*RMOD-(\d+)", rmod).group(1)
            bbmod_index = rmod_bbmod_mapping_res[rmod_index]
            serial_number = rmod_sn_mapping_res[rmod_index]
            serial_number_in_int = sn_ru_index_in_int_mapping_res.__len__()
            logging.debug(
                "the length of serial_number_in_int is {}".format(serial_number_in_int)
            )
            if serial_number_in_int != 0:
                ru_index = int(sn_ru_index_in_int_mapping_res[serial_number])
            else:
                ru_index = int(rmod_index) - 1
            cell_technology = cell_mapping[cell_index]["detail_cells_info"][
                "technology"
            ]
            if cell_technology == "TDD":
                logging.debug(
                    "start to get framestructure type for cell-{}".format(cell_index)
                )
                frameStructureType = get_single_value_from_scf_file(
                    parameter="frameStructureType",
                    dist_name="NRBTS-{}/NRCELL-{}".format(nrbts_id, cell_index),
                    list_name="tddFrameStructure",
                    connection=self._connection,
                    timeout=300,
                )
                if frameStructureType == "tdLte":
                    framestructure = "1116"
                elif frameStructureType == "semiStatic":
                    ulDlDataSlotRatio = get_single_value_from_scf_file(
                        parameter="ulDlDataSlotRatio",
                        dist_name="NRBTS-{}/NRCELL-{}".format(nrbts_id, cell_index),
                        list_name="tddFrameStructure",
                        connection=self._connection,
                        timeout=300,
                    )
                    if ulDlDataSlotRatio == "3/7":
                        framestructure = "1070"
                    else:
                        framestructure = "1208"
                logging.debug("framestructure is {}".format(framestructure))
                cell_mapping[cell_index]["framestructure"] = framestructure
            else:
                cell_mapping[cell_index]["framestructure"] = None
            ssbfrequency = arfcnSsbPbch_mapping_res[str(cell_index)]
            logging.debug("ssbfrequency is:{}".format(ssbfrequency))
            cell_mapping[cell_index]["ru_index_mapping"] = str(ru_index)
            cell_mapping[cell_index]["ssbfrequency"] = ssbfrequency
            cell_mapping[cell_index]["bbmod_index"] = bbmod_index
            cell_mapping[cell_index]["rmod_index"] = rmod_index
        return cell_mapping

    def get_nrrel_config(self):
        return coam.get_managed_objects(
            class_name="NRREL_A", connection=self._connection, timeout=60
        )

    def get_nrrele_config(self):
        return coam.get_managed_objects(
            class_name="NRRELE_A", connection=self._connection, timeout=60
        )

    def get_nradjecell_config(self):
        return coam.get_managed_objects(
            class_name="NRADJECELL_A", connection=self._connection, timeout=60
        )

    def get_nrhoif_config(self):
        return coam.get_managed_objects(
            class_name="NRHOIF_A", connection=self._connection, timeout=60
        )

    def get_xn_link_config(self):
        return coam.get_managed_objects(
            class_name="XNLINK_A", connection=self._connection, timeout=60
        )

    def get_nradj_gnb_config(self):
        return coam.get_managed_objects(
            class_name="NRADJGNB_A", connection=self._connection, timeout=60
        )

    def get_nradjcell_config(self):
        return coam.get_managed_objects(
            class_name="NRADJNRCELL_A", connection=self._connection, timeout=60
        )


class EnbOperation:
    def __init__(self, connection="ENB_OAM0"):
        self._connection = connection
        pass


class MobilityCAConfiguration:
    def __init__(self):
        self._pcell_index = 0
        self._source_gnb_id = 0
        self._target_gnb_id = 1
        self.intra_gnb = GnbOperation(connection="GNB_OAM0")
        self.inter_gnb = GnbOperation(connection="GNB_OAM1")
        self.intra_enb = EnbOperation(connection="ENB_OAM0")
        self.all_neighbor_cell_config = {}

    def set_pcell_index(self, value):
        self._pcell_index = int(value)

    def set_gnb_id(self, value):
        self._source_gnb_id = int(value)
        if self._source_gnb_id == 1:
            self._target_gnb_id = 0

    def set_gnb_operation_object(self):
        if self._source_gnb_id == 1:
            self.intra_gnb = GnbOperation(connection="GNB_OAM1")
            self.inter_gnb = GnbOperation(connection="GNB_OAM0")
        else:
            self.intra_gnb = GnbOperation(connection="GNB_OAM0")
            self.inter_gnb = GnbOperation(connection="GNB_OAM1")

    def get_all_neighbor_cell_config_info(self):
        """
        :return: {u'1': [{'neighbor_cell_id': 0,
                       'nrCellIdentity': '173850624',
                       'is_scell': True,
                       'nrrel_id': u'0',
                       'band_type': 'Inter',
                       'l2rt_type': 'Inter',
                       'physicalCellId': 211,
                       'frequency_type': None,
                       'handover_gnb_type': 'Intra',
                       'technology': u'TDD',
                       'band_combination': 'n78+n41'},
                      {'neighbor_cell_id': 1,
                       'nrCellIdentity': '173850625',
                       'is_scell': False,
                       'nrrel_id': u'1',
                       'band_type': 'Intra',
                       'l2rt_type': 'Inter',
                       'physicalCellId': 212,
                       'frequency_type': 'Intra',
                       'handover_gnb_type': 'Inter',
                       'technology': u'TDD',
                       'band_combination': 'n78+n78'}]
        """
        intra_gnb_cell_mapping = self.intra_gnb.get_cell_mapping(gnb_index=self._source_gnb_id)
        logging.debug(
            "*****cell mapping result ******\n {}".format(intra_gnb_cell_mapping)
        )
        intra_gnb_nrrel_config = self.intra_gnb.get_nrrel_config()
        intra_gnb_nrhoif_config = self.intra_gnb.get_nrhoif_config()
        logging.debug(
            "*****all cell nrrel config ******\n {}".format(intra_gnb_nrrel_config)
        )
        logging.debug(
            "*****all cell nrhoif config ******\n {}".format(intra_gnb_nrhoif_config)
        )
        list_intra_gnb_cell_mapping = list(intra_gnb_cell_mapping.items())
        intra_gnb_id = tl.gnbs[self._source_gnb_id].global_bts_id
        try:
            inter_gnb_id = tl.gnbs[self._target_gnb_id].global_bts_id
            inter_gnb_cell_mapping = self.inter_gnb.get_cell_mapping(gnb_index=self._target_gnb_id,
                                                                     alias='coam_alias1')
            list_inter_gnb_cell_mapping = list(inter_gnb_cell_mapping.items())
        except Exception as e:
            logging.debug("inter gnb is not configured for testline:{}".format(e))
        neighbor_cell_config_mapping = defaultdict(list)
        for element in intra_gnb_nrrel_config:
            logging.debug(element["distName"])
            cell_id = re.match(r".*NRCELL_A-(\d+)", element["distName"]).group(1)
            source_cell_technology = intra_gnb_cell_mapping[int(cell_id)][
                "detail_cells_info"
            ]["technology"]
            if source_cell_technology == "TDD":
                source_nrarfcn_key = "nrarfcn"
            else:
                source_nrarfcn_key = "nrarfcnDl"
            source_cell_nrarfcn = intra_gnb_cell_mapping[int(cell_id)][
                "detail_cells_info"
            ][source_nrarfcn_key]
            source_cell_gscn = intra_gnb_cell_mapping[int(cell_id)]["gscn"]
            ssbfrequency_in_nrhoif = []
            for config_item in intra_gnb_nrhoif_config:
                logging.debug(
                    "*****start to get inter frequency cell info from nrhoif config******"
                )
                dist_name = config_item["distName"]
                cell_idx_in_disname = dist_name.split("/")[-2]
                if "NRCELL_A-{}".format(cell_id) == cell_idx_in_disname:
                    try:
                        ssbfrequency_config = config_item["parameters"]["ssbFrequency"]
                        ssbfrequency_in_nrhoif.append(ssbfrequency_config)
                    except Exception as e:
                        logging.debug(
                            "no ssbFrequency info configured for cell-{}".format(
                                cell_id
                            )
                        )
            logging.debug(
                "ssbfrequency configured in nrhoif is {}".format(ssbfrequency_in_nrhoif)
            )
            try:
                lcrId = element["parameters"]["lcrId"]
                nrrel_id = element["distName"].split("/")[-1].split("-")[-1].strip()
                sCellAdditionMethod = element["parameters"]["sCellAdditionMethod"]
                gnb_id = element["parameters"]["gNbId"]
            except Exception as e:
                logging.debug(
                    "error {} found on nrrel config for cell-{} ".format(e, cell_id)
                )
            if sCellAdditionMethod is not None:
                is_scell = True
            else:
                is_scell = False
            neighbor_cell_info_dict = {}
            neighbor_cell_info_dict["nrrel_id"] = nrrel_id
            neighbor_cell_info_dict["is_scell"] = is_scell
            try:
                if gnb_id == intra_gnb_id:
                    handover_gnb_type = "Intra"
                    cell_mapping = list_intra_gnb_cell_mapping
                elif gnb_id == inter_gnb_id:
                    handover_gnb_type = "Inter"
                    cell_mapping = list_inter_gnb_cell_mapping
                for item in cell_mapping:
                    if item[-1]["lcrId"] == lcrId:
                        logging.debug("start to get neighbor cell info")
                        cell_match_id = item[0]
                        target_cell_technology = item[-1]["detail_cells_info"][
                            "technology"
                        ]
                        if target_cell_technology == "TDD":
                            target_nrarfcn_key = "nrarfcn"
                        else:
                            target_nrarfcn_key = "nrarfcnDl"
                        if handover_gnb_type == "Intra":
                            intra_fre_condition = (
                                item[-1]["detail_cells_info"][target_nrarfcn_key]
                                == source_cell_nrarfcn
                                and item[0] != int(cell_id)
                                and item[-1]["gscn"] == source_cell_gscn
                            )
                        else:
                            intra_fre_condition = (
                                item[-1]["detail_cells_info"][target_nrarfcn_key]
                                == source_cell_nrarfcn
                                and item[-1]["gscn"] == source_cell_gscn
                            )
                        cell_ssbfrequency = item[-1]["ssbfrequency"]
                        logging.debug(
                            "cell_ssbfrequency for {} is {}".format(
                                item[0], cell_ssbfrequency
                            )
                        )
                        logging.debug(
                            "ssbfrequency_in_nrhoif for {} is {}".format(
                                item[0], ssbfrequency_in_nrhoif
                            )
                        )
                        inter_fre_condition_1 = (
                            item[-1]["gscn"] == source_cell_gscn
                            and item[-1]["detail_cells_info"][target_nrarfcn_key]
                            != source_cell_nrarfcn
                            and cell_ssbfrequency in ssbfrequency_in_nrhoif
                        )
                        inter_fre_condition_2 = (
                            item[-1]["gscn"] != source_cell_gscn
                            and cell_ssbfrequency in ssbfrequency_in_nrhoif
                        )
                        inter_fre_condition = (
                            inter_fre_condition_1 or inter_fre_condition_2
                        )
                        if intra_fre_condition:
                            neighbor_cell_info_dict["frequency_type"] = "Intra"
                        elif inter_fre_condition:
                            neighbor_cell_info_dict["frequency_type"] = "Inter"
                        else:
                            neighbor_cell_info_dict["frequency_type"] = None
                        source_cell_band = intra_gnb_cell_mapping[int(cell_id)][
                            "detail_cells_info"
                        ]["band"]
                        target_cell_band = item[-1]["detail_cells_info"]["band"]
                        if source_cell_band == target_cell_band:
                            band_type = "Intra"
                        else:
                            band_type = "Inter"
                        # source_cell_bbmod_index = intra_gnb_cell_mapping[int(cell_id)][
                        #     "bbmod_index"
                        # ]
                        # target_cell_bbmod_index = item[-1]["bbmod_index"]
                        # if source_cell_bbmod_index == target_cell_bbmod_index:
                        #     l2rt_type = "Intra"
                        # else:
                        #     l2rt_type = "Inter"
                        neighbor_cell_info_dict["handover_gnb_type"] = handover_gnb_type
                        neighbor_cell_info_dict["neighbor_cell_id"] = cell_match_id
                        neighbor_cell_info_dict["technology"] = item[-1][
                            "detail_cells_info"
                        ]["technology"]
                        neighbor_cell_info_dict["nrCellIdentity"] = str(
                            item[-1]["nrCellIdentity"]
                        )
                        neighbor_cell_info_dict["physicalCellId"] = item[-1][
                            "physicalCellId"
                        ]
                        neighbor_cell_info_dict["band_combination"] = "{}+{}".format(
                            source_cell_band, target_cell_band
                        )
                        neighbor_cell_info_dict["band_type"] = band_type
                        # neighbor_cell_info_dict["l2rt_type"] = l2rt_type
                        # neighbor_cell_info_dict['all_cell_info'] = item[-1]
                        neighbor_cell_config_mapping[cell_id].append(
                            neighbor_cell_info_dict
                        )
            except Exception as e:
                logging.debug("fail to get neighbor cell info".format(e))
        logging.debug(
            "*****all neighbor cell mapping result is ******\n {}".format(
                neighbor_cell_config_mapping
            )
        )
        self.all_neighbor_cell_config = neighbor_cell_config_mapping
        return neighbor_cell_config_mapping

    def get_all_scell_config_info(self):
        """
        :return: {u'1': [{'neighbor_cell_id': 0,
                       'nrCellIdentity': '173850624',
                       'is_scell': True,
                       'nrrel_id': u'0',
                       'physicalCellId': 211,
                       'technology': u'TDD'},
                      {'neighbor_cell_id': 1,
                       'nrCellIdentity': '173850625',
                       'is_scell': False,
                       'nrrel_id': u'1',
                       'physicalCellId': 212,
                       'technology': u'TDD']
        """
        intra_gnb_cell_mapping = self.intra_gnb.get_cell_mapping_for_tmo(gnb_index=self._source_gnb_id)
        logging.debug(
            "*****cell mapping result ******\n {}".format(intra_gnb_cell_mapping)
        )
        intra_gnb_nrrel_config = self.intra_gnb.get_nrrel_config()
        logging.debug(
            "*****all cell nrrel config ******\n {}".format(intra_gnb_nrrel_config)
        )
        list_intra_gnb_cell_mapping = list(intra_gnb_cell_mapping.items())
        neighbor_cell_config_mapping = defaultdict(list)
        for element in intra_gnb_nrrel_config:
            logging.debug(element["distName"])
            cell_id = re.match(r".*NRCELL_A-(\d+)", element["distName"]).group(1)
            try:
                lcrId = element["parameters"]["lcrId"]
                nrrel_id = element["distName"].split("/")[-1].split("-")[-1].strip()
                sCellAdditionMethod = element["parameters"]["sCellAdditionMethod"]
            except Exception as e:
                logging.debug(
                    "error {} found on nrrel config for cell-{} ".format(e, cell_id)
                )
            if sCellAdditionMethod is not None:
                is_scell = True
            else:
                is_scell = False
            neighbor_cell_info_dict = {}
            neighbor_cell_info_dict["nrrel_id"] = nrrel_id
            neighbor_cell_info_dict["is_scell"] = is_scell
            try:
                cell_mapping = list_intra_gnb_cell_mapping
                for item in cell_mapping:
                    if item[-1]["lcrId"] == lcrId:
                        logging.debug("start to get neighbor cell info")
                        cell_match_id = item[0]
                        neighbor_cell_info_dict["neighbor_cell_id"] = cell_match_id
                        neighbor_cell_info_dict["technology"] = item[-1][
                            "detail_cells_info"
                        ]["technology"]
                        neighbor_cell_info_dict["nrCellIdentity"] = str(
                            item[-1]["nrCellIdentity"]
                        )
                        neighbor_cell_info_dict["physicalCellId"] = item[-1][
                            "physicalCellId"
                        ]
                        neighbor_cell_config_mapping[cell_id].append(
                            neighbor_cell_info_dict
                        )
            except Exception as e:
                logging.debug("fail to get neighbor cell info".format(e))
        logging.debug(
            "*****all neighbor cell mapping result is ******\n {}".format(
                neighbor_cell_config_mapping
            )
        )
        return neighbor_cell_config_mapping

    def get_scell_mapping_for_pcell(self):
        if self.all_neighbor_cell_config:
            all_neighbor_cell_config = self.all_neighbor_cell_config
        else:
            all_neighbor_cell_config = self.get_all_neighbor_cell_config_info()
        logging.debug("all neighbour cell info is:{}".format(all_neighbor_cell_config))
        pcell_neighbor_cell_config_mapping = all_neighbor_cell_config[
            str(self._pcell_index)
        ]
        scell_config_status = False
        scell_mapping = {}
        for item in pcell_neighbor_cell_config_mapping:
            logging.debug(
                "******start to check scell is configured in nrrel config******"
            )
            scell_detail_info_dict = {}
            if item["is_scell"]:
                scell_config_status = True
                scell_detail_info_dict[
                    "all_cell_info"
                ] = self.intra_gnb.get_cell_mapping(gnb_index=self._source_gnb_id)[item["neighbor_cell_id"]]
                scell_detail_info_dict["nrrel_id"] = item["nrrel_id"]
                # scell_detail_info_dict["l2rt_type"] = item["l2rt_type"]
                scell_detail_info_dict["band_type"] = item["band_type"]
                scell_mapping[item["neighbor_cell_id"]] = scell_detail_info_dict
        assert scell_config_status, "no scell configured for pcell-{}".format(
            self._pcell_index
        )
        # logging.debug(
        #     "******pcell-{}_scell_mapping is :{}******".format(
        #         self._pcell_index, scell_mapping
        #     )
        # )
        return scell_mapping

    def get_scell_mapping_for_pcell_for_tmo(self):
        all_neighbor_cell_config = self.get_all_scell_config_info()
        logging.debug("all scell info is:{}".format(all_neighbor_cell_config))
        pcell_neighbor_cell_config_mapping = all_neighbor_cell_config[
            str(self._pcell_index)
        ]
        scell_config_status = False
        scell_mapping = {}
        for item in pcell_neighbor_cell_config_mapping:
            logging.debug(
                "******start to check scell is configured in nrrel config******"
            )
            scell_detail_info_dict = {}
            if item["is_scell"]:
                scell_config_status = True
                scell_detail_info_dict[
                    "all_cell_info"
                ] = self.intra_gnb.get_cell_mapping_for_tmo(gnb_index=self._source_gnb_id)[item["neighbor_cell_id"]]
                scell_detail_info_dict["nrrel_id"] = item["nrrel_id"]
                scell_mapping[item["neighbor_cell_id"]] = scell_detail_info_dict
        assert scell_config_status, "no scell configured for pcell-{}".format(
            self._pcell_index
        )
        # logging.debug(
        #     "******pcell-{}_scell_mapping is :{}******".format(
        #         self._pcell_index, scell_mapping
        #     )
        # )
        return scell_mapping

    def get_tdd_scell_mapping(self, all_scell_info):
        # all_scell_info = self.get_scell_mapping_for_pcell()
        tdd_scell_mapping = {}
        scell_ids = all_scell_info.keys()
        for scell_id in scell_ids:
            if (
                all_scell_info[scell_id]["all_cell_info"]["detail_cells_info"][
                    "technology"
                ]
                == "TDD"
            ):
                tdd_scell_mapping[scell_id] = all_scell_info[scell_id]
        return tdd_scell_mapping

    def get_fdd_scell_mapping(self, all_scell_info):
        # all_scell_info = self.get_scell_mapping_for_pcell()
        fdd_scell_mapping = {}
        scell_ids = all_scell_info.keys()
        for scell_id in scell_ids:
            if (
                all_scell_info[scell_id]["all_cell_info"]["detail_cells_info"][
                    "technology"
                ]
                == "FDD"
            ):
                fdd_scell_mapping[scell_id] = all_scell_info[scell_id]
        return fdd_scell_mapping

    def is_scell(self, cell_id):
        if self.all_neighbor_cell_config:
            all_neighbor_cell_config = self.all_neighbor_cell_config
        else:
            all_neighbor_cell_config = self.get_all_neighbor_cell_config_info()
        pcell_neighbor_cell_config_mapping = all_neighbor_cell_config[
            str(self._pcell_index)
        ]
        neighbor_cell_info = []
        if not isinstance(pcell_neighbor_cell_config_mapping, list):
            neighbor_cell_info.append(pcell_neighbor_cell_config_mapping)
        else:
            neighbor_cell_info = pcell_neighbor_cell_config_mapping
        filter_cell_info = list(
            filter(
                lambda x: x["neighbor_cell_id"] == cell_id
                and x["handover_gnb_type"] == "Intra",
                neighbor_cell_info,
            )
        )
        logging.debug("filter scell info is: {}".format(filter_cell_info))
        return filter_cell_info[0]["is_scell"]

    def get_pcell_mapping(self):
        return self.intra_gnb.get_cell_mapping(gnb_index=self._source_gnb_id)[self._pcell_index]

    def get_pcell_mapping_for_tmo(self):
        return self.intra_gnb.get_cell_mapping_for_tmo(gnb_index=self._source_gnb_id)[self._pcell_index]

    def get_required_handover_cell_mapping(
        self, frequency_type="Intra", handover_gnb_type="Intra"
    ):
        if self.all_neighbor_cell_config:
            all_neighbor_cell_config = self.all_neighbor_cell_config
        else:
            all_neighbor_cell_config = self.get_all_neighbor_cell_config_info()
        handover_cell_mapping = {}
        list_neighbor_cell_config_mapping = list(all_neighbor_cell_config.items())
        for item in list_neighbor_cell_config_mapping:
            neighbor_cell_info = []
            if not isinstance(item[-1], list):
                neighbor_cell_info.append(item[-1])
            else:
                neighbor_cell_info = item[-1]
            filter_neighbor_cell_info = list(
                filter(
                    lambda x: x["frequency_type"] == frequency_type
                    and x["handover_gnb_type"] == handover_gnb_type
                    and x["is_scell"] is False,
                    neighbor_cell_info,
                )
            )
            if len(filter_neighbor_cell_info) != 0:
                handover_cell_mapping[item[0]] = filter_neighbor_cell_info
        assert (
            len(handover_cell_mapping) != 0
        ), "no cell can do {} gnb {} frequency handover".format(
            handover_gnb_type, frequency_type
        )
        return handover_cell_mapping

    def config_relation_cells(self, relation_cells_info, addition_method="covBasedA1"):
        """
        :params relation_cells_info=[{inter_gnb_ho_cell:301},{scell_indexs:[1,2,3]},{swap_scell_index:22},
        {intra_gnb_ho_cell:31}]
        """
        mrbts_id = tl.gnbs[int(self._source_gnb_id)].instance_id
        nrbts_id = tl.gnbs[int(self._source_gnb_id)].global_bts_id
        gnb_connection = "GNB_OAM{}".format(self._source_gnb_id)
        target_gnb_cell_mapping = {}
        source_gnb_cell_mapping = self.intra_gnb.get_cell_mapping(gnb_index=self._source_gnb_id)
        logging.debug(
            "source gnb cell mapping result is {}".format(source_gnb_cell_mapping)
        )
        all_scell_indexs = []
        scell_indexs = [x for x in relation_cells_info if "scell_indexs" in x.keys()]
        swap_scell = [x for x in relation_cells_info if "swap_scell_index" in x.keys()]
        logging.debug("scell_indexs info is {}".format(scell_indexs))
        logging.debug("swap_scell info is {}".format(swap_scell))
        if scell_indexs[0]["scell_indexs"] is not None:
            all_scell_indexs.extend(scell_indexs[0]["scell_indexs"])
        if swap_scell[0]["swap_scell_index"] is not None:
            all_scell_indexs.append(swap_scell[0]["swap_scell_index"])
        # SCELLWEIGHT_OBJECT = []
        # for scell_index in all_scell_indexs:
        #     SCELLWEIGHT_ONE_CELL = [
        #         {
        #             "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
        #                 mrbts_id, nrbts_id, scell_index
        #             ),
        #             "parameter": "weightForSCellSelection",
        #             "value": 100,
        #         },
        #     ]
        #     SCELLWEIGHT_OBJECT.extend(SCELLWEIGHT_ONE_CELL)
        # logging.debug(
        #     "start to modify scellweight for all scells {}".format(SCELLWEIGHT_OBJECT)
        # )
        # update_scellweight_delta_output = create_update_parameters_delta(
        #     parameters=SCELLWEIGHT_OBJECT,
        #     connection=gnb_connection,
        # )
        # perform_scf_delta_commission(
        #     delta_file=update_scellweight_delta_output["updated"],
        #     skip_parameter_relation_errors=False,
        #     timeout=240,
        #     connection=gnb_connection,
        # )
        scell_mapping = {}
        for relation_cell_info in relation_cells_info:
            for cell_type, cell_indexs in relation_cell_info.items():
                if cell_indexs is not None:
                    if not isinstance(cell_indexs, list):
                        cell_indexs = [cell_indexs]
                elif cell_indexs is None:
                    cell_indexs = []
                for cell_index in cell_indexs:
                    logging.debug("start to config cell-{}".format(cell_index))
                    if cell_type == "inter_gnb_ho_cell":
                        try:
                            target_gnb_id = tl.gnbs[self._target_gnb_id].global_bts_id
                        except Exception as e:
                            assert "inter gnb info is not configured for testline init file,must config it"
                        xn_cplane_ip_address = self.inter_gnb.get_xn_cplane_ip_address()
                        target_plmn_info = self.inter_gnb.get_plmn_info()
                        target_mcc = target_plmn_info["mcc"]
                        target_mnc = target_plmn_info["mnc"]
                        target_mncLength = target_plmn_info["mncLength"]
                        target_gNbIdLength = self.inter_gnb.get_gnb_id_length()
                        target_gnb_cell_mapping = self.inter_gnb.get_cell_mapping(gnb_index=self._target_gnb_id,
                                                                                  alias='coam_alias1')
                        logging.debug(
                            "tartget gnb cell mapping result is {}".format(
                                target_gnb_cell_mapping
                            )
                        )
                        target_lcrid = target_gnb_cell_mapping[int(cell_index)]["lcrId"]
                        physicalCellId = target_gnb_cell_mapping[int(cell_index)][
                            "physicalCellId"
                        ]
                        ssbfrequency = target_gnb_cell_mapping[int(cell_index)][
                            "ssbfrequency"
                        ]
                        nrarfcn = target_gnb_cell_mapping[int(cell_index)][
                            "detail_cells_info"
                        ]["nrarfcn"]
                        # ------start to config XN-LINK ------#
                        all_xnlink_config = self.intra_gnb.get_xn_link_config()
                        xn_link_config_status = False
                        if len(all_xnlink_config) > 0:
                            all_used_xnlink_index = [
                                x["distName"].split("/")[-1].split("-")[-1].strip()
                                for x in all_xnlink_config
                            ]
                            logging.debug(
                                "pre-used xnlink index is {}".format(
                                    all_used_xnlink_index
                                )
                            )
                            xnlink_existence = [
                                x
                                for x in all_xnlink_config
                                if x["parameters"]["cPlaneIpAddr"]
                                == xn_cplane_ip_address
                            ]
                            if len(xnlink_existence) == 0:
                                xn_link_index = choice(
                                    [
                                        i
                                        for i in range(1, 9)
                                        if i not in all_used_xnlink_index
                                    ]
                                )
                            else:
                                xn_link_config_status = True
                                xn_link_index = [
                                    x["distName"].split("/")[-1].split("-")[-1].strip()
                                    for x in all_xnlink_config
                                    if x["parameters"]["cPlaneIpAddr"]
                                    == xn_cplane_ip_address
                                ][0]
                        else:
                            xn_link_index = choice([i for i in range(1, 9)])
                        if xn_link_config_status is False:
                            logging.debug(
                                "no xnlink configured,started to config XNLINK-{}".format(
                                    xn_link_index
                                )
                            )
                            XNLINK_OBJECT = [
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/XNLINK-{}".format(
                                        mrbts_id, nrbts_id, xn_link_index
                                    ),
                                    "parameter": "cPlaneIpAddr",
                                    "value": "{}".format(xn_cplane_ip_address),
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/XNLINK-{}".format(
                                        mrbts_id, nrbts_id, xn_link_index
                                    ),
                                    "parameter": "cPlaneIpAddrCtrl",
                                    "value": "oamControlled",
                                },
                            ]
                            xn_delta_output = create_objects_delta(
                                parameters=XNLINK_OBJECT, connection=gnb_connection
                            )
                            perform_scf_delta_commission(
                                delta_file=xn_delta_output["updated"],
                                skip_parameter_relation_errors=False,
                                timeout=240,
                                connection=gnb_connection,
                            )
                        # ------start to config ADJGNB ------#
                        all_adj_gnb_config = self.intra_gnb.get_nradj_gnb_config()
                        adj_gnb_config_status = False
                        if len(all_adj_gnb_config) > 0:
                            all_used_adj_gnb_index = [
                                x["distName"].split("/")[-1].split("-")[-1].strip()
                                for x in all_adj_gnb_config
                            ]
                            logging.debug(
                                "pre-used adjgnb index is {}".format(
                                    all_used_adj_gnb_index
                                )
                            )
                            adj_gnb_existence = [
                                x
                                for x in all_adj_gnb_config
                                if x["parameters"]["gNodeBId"] == target_gnb_id
                            ]
                            if len(adj_gnb_existence) == 0:
                                adj_gnb_index = choice(
                                    [
                                        i
                                        for i in range(1, 9)
                                        if i not in all_used_adj_gnb_index
                                    ]
                                )
                            else:
                                adj_gnb_config_status = True
                        else:
                            adj_gnb_index = choice([i for i in range(1, 9)])
                        if adj_gnb_config_status is False:
                            logging.debug(
                                "no adjgnb configured,started to config ADJGNB-{}".format(
                                    adj_gnb_index
                                )
                            )
                            NRADJGNB_OBJECT = [
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJGNB-{}".format(
                                        mrbts_id, nrbts_id, adj_gnb_index
                                    ),
                                    "parameter": "administrativeState",
                                    "value": "Unlocked",
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJGNB-{}".format(
                                        mrbts_id, nrbts_id, adj_gnb_index
                                    ),
                                    "parameter": "gNbIdLength",
                                    "value": target_gNbIdLength,
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJGNB-{}".format(
                                        mrbts_id, nrbts_id, adj_gnb_index
                                    ),
                                    "parameter": "gNodeBId",
                                    "value": target_gnb_id,
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJGNB-{}".format(
                                        mrbts_id, nrbts_id, adj_gnb_index
                                    ),
                                    "parameter": "gNodeBIdCtrl",
                                    "value": "oamControlled",
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJGNB-{}".format(
                                        mrbts_id, nrbts_id, adj_gnb_index
                                    ),
                                    "parameter": "weightForIgnbCaSelection",
                                    "value": 1,
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJGNB-{}".format(
                                        mrbts_id, nrbts_id, adj_gnb_index
                                    ),
                                    "parameter": "xnLinkRef",
                                    "value": xn_link_index,
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJGNB-{}".format(
                                        mrbts_id, nrbts_id, adj_gnb_index
                                    ),
                                    "parameter": "gnbPlmn",
                                    "value": [
                                        {
                                            "mcc": target_mcc,
                                            "mnc": target_mnc,
                                            "mncLength": target_mncLength,
                                        }
                                    ],
                                },
                            ]
                            adjgnb_delta_output = create_objects_delta(
                                parameters=NRADJGNB_OBJECT, connection=gnb_connection
                            )
                            perform_scf_delta_commission(
                                delta_file=adjgnb_delta_output["updated"],
                                skip_parameter_relation_errors=False,
                                timeout=240,
                                connection=gnb_connection,
                            )
                        # ------start to config ADJCELL ------#
                        all_adj_cell_config = self.intra_gnb.get_nradjcell_config()
                        adj_cell_config_status = False
                        if len(all_adj_cell_config) > 0:
                            all_used_adj_cell_index = [
                                x["distName"].split("/")[-1].split("-")[-1].strip()
                                for x in all_adj_cell_config
                            ]
                            logging.debug(
                                "pre-used adjcell index is {}".format(
                                    all_used_adj_cell_index
                                )
                            )
                            adj_cell_existence = [
                                x
                                for x in all_adj_cell_config
                                if x["parameters"]["gNbId"] == target_gnb_id
                                and x["parameters"]["lcrId"] == target_lcrid
                            ]
                            if len(adj_cell_existence) == 0:
                                adj_cell_index = choice(
                                    [
                                        i
                                        for i in range(2, 9)
                                        if i not in all_used_adj_cell_index
                                    ]
                                )
                                logging.debug(
                                    "adjcell index is {}".format(adj_cell_index)
                                )
                            else:
                                adj_cell_config_status = True
                        else:
                            adj_cell_index = choice([i for i in range(2, 9)])
                            logging.debug(
                                "choose adjcell index is {}".format(adj_cell_index)
                            )
                        if adj_cell_config_status is False:
                            logging.debug(
                                "no adjcell configured,started to config ADJCELL-{}".format(
                                    adj_cell_index
                                )
                            )
                            NRADJCELL_OBJECT = [
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJNRCELL-{}".format(
                                        mrbts_id, nrbts_id, adj_cell_index
                                    ),
                                    "parameter": "cellDepType",
                                    "value": "SA+NSA",
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJNRCELL-{}".format(
                                        mrbts_id, nrbts_id, adj_cell_index
                                    ),
                                    "parameter": "cellReservedForOperatorUse",
                                    "value": "notReserved",
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJNRCELL-{}".format(
                                        mrbts_id, nrbts_id, adj_cell_index
                                    ),
                                    "parameter": "gNbId",
                                    "value": target_gnb_id,
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJNRCELL-{}".format(
                                        mrbts_id, nrbts_id, adj_cell_index
                                    ),
                                    "parameter": "gNbIdLength",
                                    "value": target_gNbIdLength,
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJNRCELL-{}".format(
                                        mrbts_id, nrbts_id, adj_cell_index
                                    ),
                                    "parameter": "lcrId",
                                    "value": target_lcrid,
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJNRCELL-{}".format(
                                        mrbts_id, nrbts_id, adj_cell_index
                                    ),
                                    "parameter": "nrarfcn",
                                    "value": nrarfcn,
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJNRCELL-{}".format(
                                        mrbts_id, nrbts_id, adj_cell_index
                                    ),
                                    "parameter": "physCellId",
                                    "value": physicalCellId,
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJNRCELL-{}".format(
                                        mrbts_id, nrbts_id, adj_cell_index
                                    ),
                                    "parameter": "ssbFrequency",
                                    "value": ssbfrequency,
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRADJNRCELL-{}".format(
                                        mrbts_id, nrbts_id, adj_cell_index
                                    ),
                                    "parameter": "gnbPlmn",
                                    "value": [
                                        {
                                            "mcc": target_mcc,
                                            "mnc": target_mnc,
                                            "mncLength": target_mncLength,
                                        }
                                    ],
                                },
                            ]
                            adjcell_delta_output = create_objects_delta(
                                parameters=NRADJCELL_OBJECT, connection=gnb_connection
                            )
                            perform_scf_delta_commission(
                                delta_file=adjcell_delta_output["updated"],
                                skip_parameter_relation_errors=False,
                                timeout=240,
                                connection=gnb_connection,
                            )
                    all_nrrel_config = self.intra_gnb.get_nrrel_config()
                    nrrel_config_for_pcell = [
                        x
                        for x in all_nrrel_config
                        if "NRCELL_A-{}/".format(self._pcell_index) in x["distName"]
                    ]
                    logging.debug(
                        "all nrrel config result is {}".format(all_nrrel_config)
                    )
                    if cell_type == "inter_gnb_ho_cell":
                        lcrid = target_gnb_cell_mapping[int(cell_index)]["lcrId"]
                        gNbId = target_gnb_id
                        gNbIdLength = target_gNbIdLength
                        mcc = target_mcc
                        mnc = target_mnc
                        mncLength = target_mncLength
                    else:
                        lcrid = source_gnb_cell_mapping[int(cell_index)]["lcrId"]
                        gNbId = nrbts_id
                        plmn_info = self.intra_gnb.get_plmn_info()
                        mcc = plmn_info["mcc"]
                        mnc = plmn_info["mnc"]
                        mncLength = plmn_info["mncLength"]
                        gNbIdLength = self.intra_gnb.get_gnb_id_length()
                    # -------start to config NRREL-------#
                    nrrel_config_status = False
                    if len(nrrel_config_for_pcell) > 0:
                        all_used_nrrel_index = [
                            x["distName"].split("/")[-1].split("-")[-1].strip()
                            for x in nrrel_config_for_pcell
                        ]
                        all_used_nrrel_index = [int(x) for x in all_used_nrrel_index]
                        logging.debug(
                            "pre-used nrrel index is {}".format(all_used_nrrel_index)
                        )
                        nrrel_existence = [
                            x
                            for x in nrrel_config_for_pcell
                            if x["parameters"]["gNbId"] == gNbId
                            and x["parameters"]["lcrId"] == lcrid
                        ]
                        if len(nrrel_existence) == 0:
                            nrrel_cell_index = choice(
                                [
                                    i
                                    for i in range(1, 9)
                                    if i not in all_used_nrrel_index
                                ]
                            )
                        else:
                            nrrel_config_status = True
                            nrrel_cell_index = [
                                x["distName"].split("/")[-1].split("-")[-1].strip()
                                for x in nrrel_config_for_pcell
                                if x["parameters"]["gNbId"] == gNbId
                                and x["parameters"]["lcrId"] == lcrid
                            ][0]
                    else:
                        nrrel_cell_index = choice([i for i in range(1, 9)])
                    if nrrel_config_status is False:
                        logging.debug(
                            "no nrrel configured,started to config NRREL-{}".format(
                                nrrel_cell_index
                            )
                        )
                        NRREL_OBJECT = [
                            {
                                "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                    mrbts_id,
                                    nrbts_id,
                                    self._pcell_index,
                                    nrrel_cell_index,
                                ),
                                "parameter": "cellIndividualSsbRsrpOffset",
                                "value": "0dB",
                            },
                            {
                                "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                    mrbts_id,
                                    nrbts_id,
                                    self._pcell_index,
                                    nrrel_cell_index,
                                ),
                                "parameter": "cellIndividualSsbRsrqOffset",
                                "value": "0dB",
                            },
                            {
                                "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                    mrbts_id,
                                    nrbts_id,
                                    self._pcell_index,
                                    nrrel_cell_index,
                                ),
                                "parameter": "gNbId",
                                "value": gNbId,
                            },
                            {
                                "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                    mrbts_id,
                                    nrbts_id,
                                    self._pcell_index,
                                    nrrel_cell_index,
                                ),
                                "parameter": "gNbIdLength",
                                "value": gNbIdLength,
                            },
                            {
                                "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                    mrbts_id,
                                    nrbts_id,
                                    self._pcell_index,
                                    nrrel_cell_index,
                                ),
                                "parameter": "handoverAllowedSA",
                                "value": "allowed",
                            },
                            {
                                "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                    mrbts_id,
                                    nrbts_id,
                                    self._pcell_index,
                                    nrrel_cell_index,
                                ),
                                "parameter": "handoverAllowedSARedCap",
                                "value": "allowed",
                            },
                            {
                                "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                    mrbts_id,
                                    nrbts_id,
                                    self._pcell_index,
                                    nrrel_cell_index,
                                ),
                                "parameter": "isRplCellForPSCell",
                                "value": "false",
                            },
                            {
                                "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                    mrbts_id,
                                    nrbts_id,
                                    self._pcell_index,
                                    nrrel_cell_index,
                                ),
                                "parameter": "lcrId",
                                "value": lcrid,
                            },
                            {
                                "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                    mrbts_id,
                                    nrbts_id,
                                    self._pcell_index,
                                    nrrel_cell_index,
                                ),
                                "parameter": "removeNotAllowed",
                                "value": "true",
                            },
                            {
                                "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                    mrbts_id,
                                    nrbts_id,
                                    self._pcell_index,
                                    nrrel_cell_index,
                                ),
                                "parameter": "nrDcAllowed",
                                "value": "false",
                            },
                            {
                                "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                    mrbts_id,
                                    nrbts_id,
                                    self._pcell_index,
                                    nrrel_cell_index,
                                ),
                                "parameter": "gnbPlmn",
                                "value": [
                                    {"mcc": mcc, "mnc": mnc, "mncLength": mncLength}
                                ],
                            },
                        ]
                        if (
                            cell_type == "scell_indexs"
                            or cell_type == "swap_scell_index"
                        ):
                            sCellAdditionMethod = addition_method
                            pcell_technology = source_gnb_cell_mapping[
                                self._pcell_index
                            ]["detail_cells_info"]["technology"]
                            scell_technology = source_gnb_cell_mapping[int(cell_index)][
                                "detail_cells_info"
                            ]["technology"]
                            if pcell_technology == "TDD" and scell_technology == "TDD":
                                sCellOperationalMode = "dlOnly"
                            elif (
                                pcell_technology == "TDD" and scell_technology == "FDD"
                            ):
                                sCellOperationalMode = "dlAndUl"
                            elif (
                                pcell_technology == "FDD" and scell_technology == "TDD"
                            ):
                                sCellOperationalMode = "dlAndUl"
                            elif (
                                pcell_technology == "FDD" and scell_technology == "FDD"
                            ):
                                sCellOperationalMode = "dlOnly"
                            if cell_type == "scell_indexs":
                                sCellPrio = 1
                            elif cell_type == "swap_scell_index":
                                sCellPrio = 2
                            NRREL_SCELL_OBJECT = [
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                        mrbts_id,
                                        nrbts_id,
                                        self._pcell_index,
                                        nrrel_cell_index,
                                    ),
                                    "parameter": "sCellAdditionMethod",
                                    "value": sCellAdditionMethod,
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                        mrbts_id,
                                        nrbts_id,
                                        self._pcell_index,
                                        nrrel_cell_index,
                                    ),
                                    "parameter": "sCellOperationalMode",
                                    "value": sCellOperationalMode,
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                        mrbts_id,
                                        nrbts_id,
                                        self._pcell_index,
                                        nrrel_cell_index,
                                    ),
                                    "parameter": "sCellPrio",
                                    "value": sCellPrio,
                                },
                            ]
                            NRREL_OBJECT.extend(NRREL_SCELL_OBJECT)
                        logging.debug("start to add NRREL {}".format(NRREL_OBJECT))
                        nrrel_delta_output = create_objects_delta(
                            parameters=NRREL_OBJECT, connection=gnb_connection
                        )
                        perform_scf_delta_commission(
                            delta_file=nrrel_delta_output["updated"],
                            skip_parameter_relation_errors=False,
                            timeout=240,
                            connection=gnb_connection,
                        )
                    elif nrrel_config_status:
                        if (
                            cell_type == "scell_indexs"
                            or cell_type == "swap_scell_index"
                        ):
                            nrrel_filter = [
                                x
                                for x in nrrel_config_for_pcell
                                if x["distName"].endswith(
                                    "NRREL_A-{}".format(nrrel_cell_index)
                                )
                            ]
                            sCellAdditionMethod = nrrel_filter[0]["parameters"][
                                "sCellAdditionMethod"
                            ]
                            if sCellAdditionMethod is None:
                                sCellAdditionMethod = addition_method
                            pcell_technology = source_gnb_cell_mapping[
                                self._pcell_index
                            ]["detail_cells_info"]["technology"]
                            scell_technology = source_gnb_cell_mapping[int(cell_index)][
                                "detail_cells_info"
                            ]["technology"]
                            if pcell_technology == "TDD" and scell_technology == "TDD":
                                sCellOperationalMode = "dlOnly"
                            elif (
                                pcell_technology == "TDD" and scell_technology == "FDD"
                            ):
                                sCellOperationalMode = "dlAndUl"
                            elif (
                                pcell_technology == "FDD" and scell_technology == "TDD"
                            ):
                                sCellOperationalMode = "dlAndUl"
                            elif (
                                pcell_technology == "FDD" and scell_technology == "FDD"
                            ):
                                sCellOperationalMode = "dlOnly"
                            if cell_type == "scell_indexs":
                                sCellPrio = 1
                            elif cell_type == "swap_scell_index":
                                sCellPrio = 2
                            UPDATE_NRREL_OBJECT = [
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                        mrbts_id,
                                        nrbts_id,
                                        self._pcell_index,
                                        nrrel_cell_index,
                                    ),
                                    "parameter": "sCellAdditionMethod",
                                    "value": sCellAdditionMethod,
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                        mrbts_id,
                                        nrbts_id,
                                        self._pcell_index,
                                        nrrel_cell_index,
                                    ),
                                    "parameter": "sCellOperationalMode",
                                    "value": sCellOperationalMode,
                                },
                                {
                                    "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}".format(
                                        mrbts_id,
                                        nrbts_id,
                                        self._pcell_index,
                                        nrrel_cell_index,
                                    ),
                                    "parameter": "sCellPrio",
                                    "value": sCellPrio,
                                },
                            ]
                            logging.debug(
                                "start to update existed NRREL {}".format(
                                    UPDATE_NRREL_OBJECT
                                )
                            )
                            update_nrrel_delta_output = create_update_parameters_delta(
                                parameters=UPDATE_NRREL_OBJECT,
                                connection=gnb_connection,
                            )
                            perform_scf_delta_commission(
                                delta_file=update_nrrel_delta_output["updated"],
                                skip_parameter_relation_errors=False,
                                timeout=240,
                                connection=gnb_connection,
                            )
                    if cell_type == "scell_indexs" or cell_type == "swap_scell_index":
                        scell_info = {}
                        logging.debug(
                            "enter start to generate scell mapping for cell-{}".format(
                                cell_index
                            )
                        )
                        scell_info["nrrel_id"] = nrrel_cell_index
                        scell_info["all_cell_info"] = source_gnb_cell_mapping[
                            cell_index
                        ]
                        # scell_mapping[cell_index] = scell_info
                        scell_mapping.update({cell_index: scell_info})
        return source_gnb_cell_mapping, target_gnb_cell_mapping, scell_mapping
