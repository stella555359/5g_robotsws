# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Lin Stella
:contact: stella.lin@nokia-sbell.com
:maintainer: Lin Stella, Chen Jun
:contact: stella.lin@nokia-sbell.com, jun.8.chen@nokia-sbell.com
"""
import logging
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.SG6.SCF.scf_common_operation import (
    SCFCommonOperation,
)

__all__ = ["update_framestructure_chbw_pdcch_params"]

TDD_INITIAL_BWP_DICT_TABLE = {"1208": "5", "1070": "6", "11160ms": "7", "11163ms": "8", "8406": "7"}
TDD_POWERSAVING_BWP_DICT_TABLE = {
    "100MHz_1208": "10057",
    "80MHz_1208": "10055",
    "60MHz_1208": "10053",
    "40MHz_1208": "10051",
    "20MHz_1208": "10050",
    "90MHz_1208": "10056",
    "70MHz_1208": "10054",
    "50MHz_1208": "10052",
    "30MHz_1208": "10058",
    "100MHz_1070": "10067",
    "80MHz_1070": "10065",
    "60MHz_1070": "10063",
    "40MHz_1070": "10061",
    "20MHz_1070": "10060",
    "90MHz_1070": "10066",
    "70MHz_1070": "10064",
    "50MHz_1070": "10062",
    "30MHz_1070": "10068",
    "100MHz_11160ms": "10077",
    "80MHz_11160ms": "10075",
    "60MHz_11160ms": "10073",
    "40MHz_11160ms": "10071",
    "20MHz_11160ms": "10070",
    "90MHz_11160ms": "10076",
    "70MHz_11160ms": "10074",
    "50MHz_11160ms": "10072",
    "30MHz_11160ms": "10078",
    "100MHz_8406": "10077",
    "80MHz_8406": "10075",
    "60MHz_8406": "10073",
    "40MHz_8406": "10071",
    "20MHz_8406": "10070",
    "90MHz_8406": "10076",
    "70MHz_8406": "10074",
    "50MHz_8406": "10072",
    "30MHz_8406": "10078",
    "100MHz_11163ms": "10087",
    "80MHz_11163ms": "10085",
    "60MHz_11163ms": "10083",
    "40MHz_11163ms": "10081",
    "20MHz_11163ms": "10080",
    "90MHz_11163ms": "10086",
    "70MHz_11163ms": "10084",
    "50MHz_11163ms": "10082",
    "30MHz_11163ms": "10088",
    "10MHz_11163ms": "10069",
}
TDD_DEDICATED_BWP_DICT_TABLE = {
    "100MHz_1208": "57",
    "80MHz_1208": "55",
    "60MHz_1208": "53",
    "40MHz_1208": "51",
    "20MHz_1208": "50",
    "90MHz_1208": "56",
    "70MHz_1208": "54",
    "50MHz_1208": "52",
    "30MHz_1208": "58",
    "100MHz_1070": "67",
    "80MHz_1070": "65",
    "60MHz_1070": "63",
    "40MHz_1070": "61",
    "20MHz_1070": "60",
    "90MHz_1070": "66",
    "70MHz_1070": "64",
    "50MHz_1070": "62",
    "30MHz_1070": "68",
    "100MHz_11160ms": "77",
    "80MHz_11160ms": "75",
    "60MHz_11160ms": "73",
    "40MHz_11160ms": "71",
    "20MHz_11160ms": "70",
    "90MHz_11160ms": "76",
    "70MHz_11160ms": "74",
    "50MHz_11160ms": "72",
    "30MHz_11160ms": "78",
    "100MHz_8406": "77",
    "80MHz_8406": "75",
    "60MHz_8406": "73",
    "40MHz_8406": "71",
    "20MHz_8406": "70",
    "90MHz_8406": "76",
    "70MHz_8406": "74",
    "50MHz_8406": "72",
    "30MHz_8406": "78",
    "100MHz_11163ms": "87",
    "80MHz_11163ms": "85",
    "60MHz_11163ms": "83",
    "40MHz_11163ms": "81",
    "20MHz_11163ms": "80",
    "90MHz_11163ms": "86",
    "70MHz_11163ms": "84",
    "50MHz_11163ms": "82",
    "30MHz_11163ms": "88",
    "10MHz_11163ms": "69",
}


class BandFramestructurePdcchConfig:
    def __init__(self):
        self.cell_id = ""
        self.chbw = ""
        self.framestructure = ""
        self.addition_params_dict = {}
        self.scf_obj = SCFCommonOperation()

    def set_cell_id(self, cell_id):
        self.cell_id = cell_id

    def set_chbw(self, chbw):
        self.chbw = chbw

    def set_framestructure(self, framestructure):
        self.framestructure = framestructure

    def set_addition_params(self, addition_params_dict):
        self.addition_params_dict = addition_params_dict

    def generate_chbw_config(self):
        chbw_param = []
        chbw_param.append(
            dict(
                dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                    self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                ),
                p_name="chBw",
                value=self.chbw,
            )
        )
        # type0CoresetConfigurationIndex = 12
        # if self.chbw == '20MHz':
        #     type0CoresetConfigurationIndex = 10
        # chbw_param.append(dict(dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(
        #     self.scf_obj.mrbts_id,
        #     self.scf_obj.nrbts_id,
        #     self.cell_id),
        #     p_name='type0CoresetConfigurationIndex',
        #     value=type0CoresetConfigurationIndex))
        return chbw_param

    def generate_framestructure_config(self):
        framestructure_param = []
        prachConfigurationIndex_mapping = {
            "11160ms": "156",
            "11163ms": "160",
            "1070": "98",
            "1208": "98",
            "8406": "98",
        }
        guardPeriodLength_mapping = {
            "11160ms": "4Symbols",
            "11163ms": "4Symbols",
            "1070": "2Symbols",
            "1208": "2Symbols",
            "8406": "4Symbols",
        }
        try:
            if (
                self.addition_params_dict.get(self.cell_id).get("guardPeriodLength")
                is not None
            ):
                guardPeriodLength = self.addition_params_dict[self.cell_id][
                    "guardPeriodLength"
                ]
            else:
                guardPeriodLength = guardPeriodLength_mapping[self.framestructure]
        except Exception as e:
            logging.debug("no addition params need to set")
            guardPeriodLength = guardPeriodLength_mapping[self.framestructure]
        try:
            if (
                self.addition_params_dict.get(self.cell_id).get(
                    "prachConfigurationIndex"
                )
                is not None
            ):
                prachConfigurationIndex = self.addition_params_dict[self.cell_id][
                    "prachConfigurationIndex"
                ]
            else:
                prachConfigurationIndex = prachConfigurationIndex_mapping[
                    self.framestructure
                ]
        except Exception as e:
            logging.debug("no addition params need to set")
            prachConfigurationIndex = prachConfigurationIndex_mapping[
                self.framestructure
            ]
        if self.framestructure == "11160ms":
            framestructure_param.append(
                dict(
                    dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                        self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                    ),
                    list_name="tddFrameStructure",
                    elements={
                        0: {
                            "frameStructureType": "tdLte",
                            "guardPeriodLength": guardPeriodLength,
                            "lteToNrFrameShift": "0ms",
                            "tdLteUlDlConfig": "tdLteConfig2",
                        }
                    },
                )
            )
            framestructure_param.append(
                dict(
                    dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                        self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                    ),
                    p_name="prachConfigurationIndex",
                    value=prachConfigurationIndex,
                )
            )
            framestructure_param.append(
                dict(
                    dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                        self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                    ),
                    p_name="lteToNrTimeOffset",
                    value="0",
                )
            )
        elif self.framestructure == "11163ms":
            framestructure_param.append(
                dict(
                    dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                        self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                    ),
                    list_name="tddFrameStructure",
                    elements={
                        0: {
                            "frameStructureType": "tdLte",
                            "guardPeriodLength": guardPeriodLength,
                            "lteToNrFrameShift": "3ms",
                            "tdLteUlDlConfig": "tdLteConfig2",
                        }
                    },
                )
            )
            framestructure_param.append(
                dict(
                    dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                        self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                    ),
                    p_name="prachConfigurationIndex",
                    value=prachConfigurationIndex,
                )
            )
            framestructure_param.append(
                dict(
                    dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                        self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                    ),
                    p_name="lteToNrTimeOffset",
                    value="30",
                )
            )
        elif self.framestructure == "1208":
            framestructure_param.append(
                dict(
                    dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                        self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                    ),
                    list_name="tddFrameStructure",
                    elements={
                        0: {
                            "frameStructureType": "semiStatic",
                            "guardPeriodLength": guardPeriodLength,
                            "ulDlDataSlotRatio": "1/4",
                        }
                    },
                )
            )
            framestructure_param.append(
                dict(
                    dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                        self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                    ),
                    p_name="prachConfigurationIndex",
                    value=prachConfigurationIndex,
                )
            )
        elif self.framestructure == "8406":
            framestructure_param.append(
                dict(
                    dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                        self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                    ),
                    list_name="tddFrameStructure",
                    elements={
                        0: {
                            "frameStructureType": "semiStatic",
                            "guardPeriodLength": guardPeriodLength,
                            "ulDlDataSlotRatio": "4/6",
                        }
                    },
                )
            )
            framestructure_param.append(
                dict(
                    dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                        self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                    ),
                    p_name="prachConfigurationIndex",
                    value=prachConfigurationIndex,
                )
            )
        elif self.framestructure == "1070":
            framestructure_param.append(
                dict(
                    dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                        self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                    ),
                    list_name="tddFrameStructure",
                    elements={
                        0: {
                            "frameStructureType": "semiStatic",
                            "guardPeriodLength": guardPeriodLength,
                            "ulDlDataSlotRatio": "3/7",
                        }
                    },
                )
            )
            framestructure_param.append(
                dict(
                    dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                        self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                    ),
                    p_name="prachConfigurationIndex",
                    value=prachConfigurationIndex,
                )
            )
        return framestructure_param

    def generate_pdcch_config(self, modify_param="23R3"):
        pdcch_param = []
        pdcch_param.append(
            dict(
                dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                    self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                ),
                list_name="cellBwpList",
                p_name="bwpDN",
                value="MRBTS-{}/NRBTS-{}/BWP_PROFILE-{}".format(
                    self.scf_obj.mrbts_id,
                    self.scf_obj.nrbts_id,
                    TDD_INITIAL_BWP_DICT_TABLE[self.framestructure],
                ),
                index="0",
            )
        )
        pdcch_param.append(
            dict(
                dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                    self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                ),
                list_name="cellBwpList",
                p_name="bwpDN",
                value="MRBTS-{}/NRBTS-{}/BWP_PROFILE-{}".format(
                    self.scf_obj.mrbts_id,
                    self.scf_obj.nrbts_id,
                    TDD_DEDICATED_BWP_DICT_TABLE[
                        self.chbw + "_" + self.framestructure
                        ],
                ),
                index="1",
            )
        )
        return pdcch_param

    def generate_pdcch_config_powersaving(self, modify_param="23R3"):
        pdcch_param = []
        pdcch_param.append(
            dict(
                dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(
                    self.scf_obj.mrbts_id, self.scf_obj.nrbts_id, self.cell_id
                ),
                list_name="cellBwpList",
                p_name="bwpDN",
                value="MRBTS-{}/NRBTS-{}/BWP_PROFILE-{}".format(
                    self.scf_obj.mrbts_id,
                    self.scf_obj.nrbts_id,
                    TDD_POWERSAVING_BWP_DICT_TABLE[
                        self.chbw + "_" + self.framestructure
                        ],
                ),
                index="2",
            )
        )
        return pdcch_param

    def generate_modified_pdcch_chbw_framestructure_params(self, modify_param="23R3"):
        modify_params = []
        chbw_params = self.generate_chbw_config()
        framestructure_params = self.generate_framestructure_config()
        pdcch_params = self.generate_pdcch_config(modify_param=modify_param)
        modify_params.extend(chbw_params)
        modify_params.extend(pdcch_params)
        modify_params.extend(framestructure_params)
        return modify_params


def update_framestructure_chbw_pdcch_params(
    modify_cell_chbw_dict={},
    framestructure={},
    addition_params_dict={},
    basic_scf_path="/home/ute/SCF/basic_golden_scf.xml",
    update_scf_path="/home/ute/SCF/basic_golden_scf_update.xml",
    modify_param="23R3",
    whether_do_pdcch_modify=True,
    whether_do_powersaving_pdcch_modify=False
):
    """
    :param modify_cell_chbw_dict:  1.modify all tdd cell chbw with same value  --> 80MHz
                                   2.modify partly tdd cell chbw --> {'1':'80MHz','2':'50MHz'}
    :param framestructure: 1.modify all cell with same framestructure ,11160ms,11163ms,1070,1208
                           2.modify different framestructure for multi cells {'1':'11160ms','2':'1070'}
    :param basic_scf_path:basic scf file for testline.defalut is stored in /home/ute/SCF/basic_golden_scf.xml
    :param update_scf_path:update scf file .defalut is stored in/home/ute/SCF/basic_golden_scf_modification.xml
    :return:
    """
    params_obj = BandFramestructurePdcchConfig()
    params_obj.scf_obj.set_scf_path(scf_path=basic_scf_path)
    params_obj.scf_obj.get_params()
    params_obj.scf_obj.scf.load_scf(file_path=basic_scf_path)
    tdd_cell_dict = {
        key: value
        for key, value in params_obj.scf_obj.cell_index_info_dict.items()
        if value["technology"] == "TDD"
    }
    modify_params = []
    for cell_index in tdd_cell_dict:
        logging.debug("cellindex is {}".format(cell_index))
        params_obj.set_cell_id(cell_id=cell_index)
        logging.debug(cell_index)
        if addition_params_dict is None:
            addition_params_dict = {}
        params_obj.set_addition_params(addition_params_dict=addition_params_dict)
        logging.debug("addition params is {}".format(params_obj.addition_params_dict))
        if modify_cell_chbw_dict:
            if modify_cell_chbw_dict is None:
                modify_cell_chbw_dict = {}
            if (
                not isinstance(modify_cell_chbw_dict, dict)
                and modify_cell_chbw_dict is not None
            ):
                modify_cell_chbw_dict = {"all_tdd_cell": modify_cell_chbw_dict}
            if "all_tdd_cell" in modify_cell_chbw_dict.keys():
                params_obj.set_chbw(chbw=modify_cell_chbw_dict["all_tdd_cell"])
            else:
                if cell_index not in modify_cell_chbw_dict.keys():
                    params_obj.set_chbw(chbw=tdd_cell_dict[cell_index]["chbw"])
                else:
                    params_obj.set_chbw(chbw=modify_cell_chbw_dict[cell_index])
        else:
            params_obj.set_chbw(chbw=tdd_cell_dict[cell_index]["chbw"])
        logging.debug("chbw is {}".format(params_obj.chbw))
        chbw_params = params_obj.generate_chbw_config()
        modify_params.extend(chbw_params)
        if framestructure:
            if framestructure is None:
                framestructure = {}
            if not isinstance(framestructure, dict) and framestructure is not None:
                framestructure = {"all_tdd_cell": framestructure}
            if "all_tdd_cell" in framestructure.keys():
                params_obj.set_framestructure(
                    framestructure=framestructure["all_tdd_cell"]
                )
                framestructure_params = params_obj.generate_framestructure_config()
                modify_params.extend(framestructure_params)
            else:
                if cell_index in framestructure.keys():
                    params_obj.set_framestructure(
                        framestructure=framestructure[cell_index]
                    )
                    framestructure_params = params_obj.generate_framestructure_config()
                    modify_params.extend(framestructure_params)
                else:
                    params_obj.set_framestructure(
                        framestructure=tdd_cell_dict[cell_index]["framestructure"]
                    )
        else:
            params_obj.set_framestructure(
                framestructure=tdd_cell_dict[cell_index]["framestructure"]
            )
        logging.debug("framestructure is {}".format(params_obj.framestructure))
        if whether_do_pdcch_modify:
            pdcch_params = params_obj.generate_pdcch_config(modify_param=modify_param)
            modify_params.extend(pdcch_params)
        if whether_do_powersaving_pdcch_modify:
            pdcch_params = params_obj.generate_pdcch_config_powersaving(modify_param=modify_param)
            modify_params.extend(pdcch_params)
        # pdcch_framestructure_chbw_params = (
        #     params_obj.generate_modified_pdcch_chbw_framestructure_params()
        # )
        # modify_params.extend(pdcch_framestructure_chbw_params)
    logging.debug(
        "following pdcch framestructure chbw parameters need to be update:{}".format(
            modify_params
        )
    )
    params_obj.scf_obj.modify_params(input_params=modify_params)
    params_obj.scf_obj.scf.save_scf(file_path=update_scf_path)
    return update_scf_path
