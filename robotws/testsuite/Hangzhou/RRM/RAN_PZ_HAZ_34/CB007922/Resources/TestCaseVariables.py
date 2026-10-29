# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Lin Stella
:contact: stella.lin@nokia-sbell.com
"""

from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
SOURCE_BTS_ID = "NRBTS-" + str(tl.gnbs[0].global_bts_id)
# TARGET_BTS_ID = "NRBTS-" + str(tl.gnbs[1].global_bts_id)

A13_PARAMS = {
    "cell4_ssbfrequency": {
        "NRBTS-10127": "639936",
        "NRBTS-10610": "639936",
        "NRBTS-10996": "624576",
    },
    "cell4_nrarfcn": {
        "NRBTS-10127": "640000",
        "NRBTS-10610": "640000",
        "NRBTS-10996": "624600",
    },
    "cell3_ssbfrequency": {
        "NRBTS-10127": "629952",
        "NRBTS-10610": "634656",
        "NRBTS-10996": "629952",
    },
}

if SOURCE_BTS_ID in A13_PARAMS["cell4_nrarfcn"]:
    A13_cell4_nrarfcn = A13_PARAMS["cell4_nrarfcn"][SOURCE_BTS_ID]
else:
    A13_cell4_nrarfcn = None

if SOURCE_BTS_ID in A13_PARAMS["cell4_ssbfrequency"]:
    A13_cell4_ssbfrequency = A13_PARAMS["cell4_ssbfrequency"][SOURCE_BTS_ID]
else:
    A13_cell4_ssbfrequency = None

if SOURCE_BTS_ID in A13_PARAMS["cell3_ssbfrequency"]:
    A13_cell3_ssbfrequency = A13_PARAMS["cell3_ssbfrequency"][SOURCE_BTS_ID]
else:
    A13_cell3_ssbfrequency = None


T081_PA_BASE_VALUE_MAPPING_TABLE = {
    "0": {"0": "5", "1": "10", "2": "5", "3": "35", "4": "35", "5": "50"},
    "1": {"0": "0"},
}

T820_PA_BASE_VALUE_MAPPING_TABLE = {
    "0": {
        "0": "10",
        "1": "33",
        "2": "0",
        "3": "35",
        "4": "35",
        "5": "35",
        "6": "35",
    },
    "1": {"0": "15", "1": "5", "2": "5"},
}

T079_PA_BASE_VALUE_MAPPING_TABLE = {
    "0": {
        "0": ["10", "20", "10", "10"],
        "1": ["10", "20", "10", "10"],
        "2": "20",
        "3": "35",
        "4": "35",
        "5": "35",
        "6": "35",
    },
    "1": {"0": "20"},
}

# ------ new testdata variables ------#
TESTCASE_INFO_MAPPING_TABLE_7922 = {
    "B_1": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "301",
            "case_level_params": [
                "modify:NRCELL-301:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=64",
                "modify:NRCELL-401:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=64",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "1",
            "case_level_params": [
                "modify:NRCELL-3:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=64",
                "modify:NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=64",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "1",
            "case_level_params": [
                "add:NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=64",
                "add:NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "A_24": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "301",
            "scell_index": ["401"],
            "case_level_params": [
                "delete:NRCELL-301/NRREL-42:sCellAdditionMethod",
                "delete:NRCELL-301/NRREL-42:sCellOperationalMode",
                "modify:NRCELL-401:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=48",
                "modify:NRCELL-501:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
    },
    "B_4": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "301",
            "scell_index": ["401"],
            "cell_chbw": {
                "401": "50MHz",
                "402": "50MHz",
            },
            "case_level_params": [
                "modify:NRCELL-301:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50",
                "modify:NRCELL-401:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=64",
                "modify:NRCELL-302:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50",
                "modify:NRCELL-402:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50",
                "modify:NRCELL-401:nrarfcn=512994",
                "modify:NRCELL-501:nrarfcn=505788",
                "modify:NRCELL-402:nrarfcn=512994",
                "modify:NRCELL-502:nrarfcn=505788",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "3",
            "cell_chbw": {
                "3": "100MHz",
                "4": "40MHz",
            },
            "case_level_params": [
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=68",
                "modify:NRCELL-3:a2MeashoEnabled=none",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "1",
            "cell_chbw": {
                "1": "100MHz",
                "2": "40MHz",
            },
            "case_level_params": [
                "add:NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=68",
                "modify:NRCELL-1:a2MeashoEnabled=none",
                "add:NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "A_12": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "301",
            "scell_index": ["401"],
            "cell_chbw": {
                "401": "50MHz",
                "402": "50MHz",
            },
            "case_level_params": [
                "modify:NRCELL-401:nrarfcn=512994",
                "modify:NRCELL-501:nrarfcn=505788",
                "modify:NRCELL-402:nrarfcn=512994",
                "modify:NRCELL-502:nrarfcn=505788",
                "modify:NRCELL-301/NRHOIF-1:ssbFrequency=653280",
                "modify:NRCELL-301/NRHOIF-1:freqBandIndicatorNR=77",
                "modify:NRCELL-301:a2MeasReleaseEnabled=none",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "3",
            "cell_chbw": {"3": "100MHz", "4": "40MHz"},
            "case_level_params": [
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
                "modify:NRCELL-3/NRHOIF-1:ssbFrequency=653280",
                "modify:NRCELL-3/NRHOIF-1:freqBandIndicatorNR=77",
                "modify:NRCELL-3:a2MeasReleaseEnabled=none",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "1",
            "cell_chbw": {"1": "100MHz", "2": "40MHz"},
            "case_level_params": [
                "add:NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-1/NRHOIF-1:ssbFrequency=653280",
                "modify:NRCELL-1/NRHOIF-1:freqBandIndicatorNR=77",
                "modify:NRCELL-1:a2MeasReleaseEnabled=none",
                "add:NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "A_13": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "301",
            "scell_index": ["401"],
            "cell_chbw": {
                "401": "50MHz",
                "402": "50MHz",
            },
            "case_level_params": [
                "modify:NRCELL-401:nrarfcn=512994",
                "modify:NRCELL-501:nrarfcn=505788",
                "modify:NRCELL-302:gscnOrSsPbchArfcn=6582",
                "modify:NRCELL-301/NRHOIF-1:ssbFrequency=526590",
                "modify:NRCELL-402:nrarfcn=512994",
                "modify:NRCELL-502:nrarfcn=505788",
                "modify:NRCELL-301:a2MeasReleaseEnabled=none",
                "modify:NRCELL-302:a2MeasReleaseEnabled=none",
                "modify:NRCELL-401:a2MeasReleaseEnabled=none",
                "modify:NRCELL-402:a2MeasReleaseEnabled=none",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "1",
            "cell_chbw": {"1": "100MHz", "2": "40MHz", "3": "100MHz", "4": "40MHz"},
            "case_level_params": [
                "add:NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
                "modify:NRCELL-1/NRHOIF-1:ssbFrequency=520110",
                "modify:NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41",
                "modify:NRCELL-3:gscnOrSsPbchArfcn=0",
                "delete:NRCELL-5/NRREL-3:sCellPrio",
                "modify:NRCELL-4:a2MeasSCellRelEnabled=none",
                "modify:NRCELL-1:a2MeasSCellRelEnabled=none",
                "modify:NRCELL-3:a2MeasSCellRelEnabled=none",
                "modify:NRCELL-2:a2MeasSCellRelEnabled=none",
                "modify:NRCELL-1:a2MeasReleaseEnabled=none",
                "modify:NRCELL-2:a2MeasReleaseEnabled=none",
                "modify:NRCELL-3:a2MeasReleaseEnabled=none",
                "modify:NRCELL-4:a2MeasReleaseEnabled=none",
                "modify:NRCELL-3:a1ThresholdSCellAddSsbRsrpTDD=78",
                "modify:NRCELL-1:a1ThresholdSCellAddSsbRsrpTDD=66",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "1",
            "cell_chbw": {"1": "100MHz", "2": "40MHz", "3": "100MHz", "4": "40MHz"},
            "case_level_params": [
                "add:NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-1/NRHOIF-1:ssbFrequency=520110",
                "modify:NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41",
                "modify:NRCELL-3:gscnOrSsPbchArfcn=0",
                "modify:NRCELL-4:a2MeasSCellRelEnabled=none",
                "modify:NRCELL-1:a2MeasSCellRelEnabled=none",
                "modify:NRCELL-3:a2MeasSCellRelEnabled=none",
                "modify:NRCELL-2:a2MeasSCellRelEnabled=none",
                "modify:NRCELL-1:a2MeasReleaseEnabled=none",
                "modify:NRCELL-2:a2MeasReleaseEnabled=none",
                "modify:NRCELL-3:a2MeasReleaseEnabled=none",
                "modify:NRCELL-4:a2MeasReleaseEnabled=none",
                "modify:NRCELL-3:a1ThresholdSCellAddSsbRsrpTDD=78",
                "modify:NRCELL-1:a1ThresholdSCellAddSsbRsrpTDD=66",
                "add:NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "B_10": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "303",
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
            "case_level_params": [
                "add:NRCELL-303/NRREL-41:sCellAdditionMethod=blind",
                "add:NRCELL-303/NRREL-41:sCellOperationalMode=dlOnly",
                # "modify:NRCELL-303:actUl256Qam=false",
            ],
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "5",
            "case_level_params": [
                "add:NRCELL-5/NRREL-3:sCellAdditionMethod=blind",
                "add:NRCELL-5/NRREL-3:sCellOperationalMode=dlOnly",
                "delete:NRCELL-5/NRREL-3:sCellPrio",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "5",
            "case_level_params": [
                "add:NRCELL-5/NRREL-3:sCellAdditionMethod=blind",
                "delete:NRCELL-5/NRREL-3:sCellPrio",
                "add:NRCELL-5/NRREL-3:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "D_9": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "301",
            "scell_index": ["401"],
            "case_level_params": [
                "delete:NRCELL-301/NRREL-42:sCellAdditionMethod",
                "delete:NRCELL-301/NRREL-42:sCellOperationalMode",
                "delete:NRCELL-302/NRREL-41"
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "1",
            "case_level_params": [
                "add:NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "1",
            "case_level_params": [
                "add:NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "D_12": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "301",
            "scell_index": ["401"],
            "cell_chbw": {
                "401": "50MHz",
                "402": "50MHz",
            },
            "case_level_params": [
                "modify:NRCELL-401:nrarfcn=512994",
                "modify:NRCELL-501:nrarfcn=505788",
                "modify:NRCELL-402:nrarfcn=512994",
                "modify:NRCELL-502:nrarfcn=505788",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "3",
            "cell_chbw": {"3": "100MHz", "4": "40MHz"},
            "case_level_params": [
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "1",
            "cell_chbw": {"1": "100MHz", "2": "40MHz"},
            "case_level_params": [
                "add:NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=60",
                "add:NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "F_02": {
        "T812": {
            "running_gnb": "0",
            "pcell_index": "2",
            "case_level_params": [
                "add:{}:actEutranFreqBandFiltering=true".format(SOURCE_BTS_ID),
                "modify:{}:actInterRatHoSA=true".format(SOURCE_BTS_ID),
                "delete:{}:freqBandIndicatorEutra".format(SOURCE_BTS_ID),
                "add:{}:freqBandIndicatorEutra".format(SOURCE_BTS_ID),
                "add:{}:freqBandIndicatorEutra::41".format(SOURCE_BTS_ID),
                "add:{}:freqBandIndicatorEutra::66".format(SOURCE_BTS_ID),
                "add:{}:freqBandIndicatorEutra::28".format(SOURCE_BTS_ID),
            ],
        }
    },
    "F_03": {
        "T812": {
            "running_gnb": "0",
            "pcell_index": "2",
            "case_level_params": [
                "modify:{}:mcc=450".format(SOURCE_BTS_ID),
                "modify:{}:mnc=5".format(SOURCE_BTS_ID),
                "modify:{}:mncLength=2".format(SOURCE_BTS_ID),
                "modify:NRPLMN-1:mcc=450",
                "modify:NRPLMN-1:mnc=5",
                "modify:NRPLMN-1:mncLength=2",
                "modify:NRPLMN-2:mcc=460",
                "modify:NRPLMN-2:mnc=2",
                "modify:NRPLMN-2:mncLength=2",
                "delete:NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList",
                "add:NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList",
                "add:NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList::MRBTS-812/NRBTS-812/NRPLMN-2",
                "delete:NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList",
                "add:NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList",
                "add:NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList::MRBTS-812/NRBTS-812/NRPLMN-2",
                "delete:NRCELL-3/NRPLMNSET_SA-1:nrPlmnDNList",
                "add:NRCELL-3/NRPLMNSET_SA-1:nrPlmnDNList",
                "add:NRCELL-3/NRPLMNSET_SA-1:nrPlmnDNList::MRBTS-812/NRBTS-812/NRPLMN-2",
                "delete:NRCELL-4/NRPLMNSET_SA-1:nrPlmnDNList",
                "add:NRCELL-4/NRPLMNSET_SA-1:nrPlmnDNList",
                "add:NRCELL-4/NRPLMNSET_SA-1:nrPlmnDNList::MRBTS-812/NRBTS-812/NRPLMN-2",
                "modify:NRCELL-1/NRREL-1:gnbPlmn:mcc=450",
                "modify:NRCELL-1/NRREL-1:gnbPlmn:mnc=5",
                "modify:NRCELL-1/NRREL-1:gnbPlmn:mncLength=2",
                "modify:NRCELL-2/NRREL-1:gnbPlmn:mcc=450",
                "modify:NRCELL-2/NRREL-1:gnbPlmn:mnc=5",
                "modify:NRCELL-2/NRREL-1:gnbPlmn:mncLength=2",
                "modify:NRCELL-3/NRREL-1:gnbPlmn:mcc=450",
                "modify:NRCELL-3/NRREL-1:gnbPlmn:mnc=5",
                "modify:NRCELL-3/NRREL-1:gnbPlmn:mncLength=2",
                "modify:NRCELL-4/NRREL-1:gnbPlmn:mcc=450",
                "modify:NRCELL-4/NRREL-1:gnbPlmn:mnc=5",
                "modify:NRCELL-4/NRREL-1:gnbPlmn:mncLength=2",
            ],
        }
    },
    "F_05": {
        "T812": {
            "running_gnb": "0",
            "pcell_index": "3",
        }
    },
    "K_02": {
        "T812": {
            "running_gnb": "0",
            "pcell_index": "2",
            "case_level_params": [
                "modify:{}:srbInactivityTimerSA=15".format(SOURCE_BTS_ID),
                "modify:{}:drbInactivityTimerSA=10".format(SOURCE_BTS_ID),
                "delete:NRCELL-2/NRREL-1:sCellAdditionMethod",
                "delete:NRCELL-2/NRREL-1:sCellOperationalMode",
                "modify:NRCELL-1:cellBarred=barred",
                "modify:NRCELL-2:cellBarred=notBarred",
                "modify:NRCELL-3:cellBarred=barred",
                "modify:NRCELL-4:cellBarred=barred",
                "modify:NRCELL-5:cellBarred=barred",
            ],
        }
    },
    "CNI_71694": {
        "T820": {
            "running_gnb": "0",
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
            "cell_chbw": {
                "401": "50MHz",
                "402": "50MHz",
            },
            "case_level_params": [
                "modify:NRCELL-401:nrarfcn=512994",
                "modify:NRCELL-501:nrarfcn=505788",
                "modify:NRCELL-402:nrarfcn=512994",
                "modify:NRCELL-502:nrarfcn=505788",
                "modify:NRCELL-301:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-401:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-501:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-302:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-402:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-502:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-303:actCaAwarePsCellSelectionFr1=true",
                "delete:NRCELL-301/NRREL-42:sCellAdditionMethod",
                "delete:NRCELL-301/NRREL-42:sCellOperationalMode",
                "delete:NRCELL-301/NRREL-42:sCellPrio",
                "delete:NRCELL-302/NRREL-41:sCellAdditionMethod",
                "delete:NRCELL-302/NRREL-41:sCellOperationalMode",
                "delete:NRCELL-302/NRREL-41:sCellPrio",
                "modify:NRCELL-301:gscnOrSsPbchArfcn=6582",
            ],
        },
        "T081": {
            "running_gnb": "0",
            "cell_chbw": {"1": "100MHz", "2": "40MHz"},
            "case_level_params": [
                "modify:NRCELL-1:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-2:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-3:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-4:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-5:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-6:actCaAwarePsCellSelectionFr1=true",
                "add:NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "cell_chbw": {"1": "100MHz", "2": "40MHz"},
            "case_level_params": [
                "modify:NRCELL-1:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-2:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-3:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-4:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-5:actCaAwarePsCellSelectionFr1=true",
                "modify:NRCELL-6:actCaAwarePsCellSelectionFr1=true",
                "add:NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly",
            ],
        },
    },
}

TESTCASE_INFO_MAPPING_TABLE_HO_GNB = {
    "B_10": {
        "T820": {
            "pcell_index": "1",
            "case_level_params": [],
        },
        "T081": {
            "pcell_index": "1",
            "case_level_params": [],
        },
        "T079": {
            "pcell_index": "1",
            "case_level_params": [],
        },
    },
    "A_12": {
        "T820": {
            "pcell_index": "1",
            "cell_chbw": {"1": "40MHz", "2": "40MHz"},
            "case_level_params": [
                "modify:NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1",
            ],
        },
        "T081": {
            "pcell_index": "1",
            "cell_chbw": {"1": "40MHz", "2": "40MHz"},
            "case_level_params": [],
        },
        "T079": {
            "pcell_index": "1",
            "cell_chbw": {"1": "40MHz", "2": "40MHz"},
            "case_level_params": [],
        },
    },
}

K02_23R1 = {
    "running_gnb": "0",
    "pcell_index": "2",
    "case_level_params": [
        "modify:{}:srbInactivityTimerSA=15".format(SOURCE_BTS_ID),
        "modify:{}:drbInactivityTimerSA=10".format(SOURCE_BTS_ID),
        "delete:NRCELL-2/NRREL-1:sCellAdditionMethod",
        "modify:NRCELL-1:cellBarred=barred",
        "modify:NRCELL-2:cellBarred=notBarred",
        "modify:NRCELL-3:cellBarred=barred",
        "modify:NRCELL-4:cellBarred=barred",
        "modify:NRCELL-5:cellBarred=barred",
    ],
}
