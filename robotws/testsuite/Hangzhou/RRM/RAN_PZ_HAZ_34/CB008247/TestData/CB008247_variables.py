import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = "MRBTS-" + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)
NR_BTS_ID = "NRBTS-" + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + "/NRCELL-3"
MR_NR_CELL2_NAME = MR_NR_BTS_NAME + "/NRCELL-4"
MR_NR_FDDCELL_NAME = MR_NR_BTS_NAME + "/NRCELL-1"
MR_NR_NRREL0_NAME = MR_NR_CELL_NAME + "/NRREL-1"
MR_NR_NRREL1_NAME = MR_NR_CELL_NAME + "/NRREL-2"

# ------------ modify parameter ------------ #
MODIFY_PARA_1086_off_actCoverageNonCoherentUes_on = [
    dict(dist_name=MR_NR_CELL_NAME, parameter="actUlSrsBm", value="false"),
    dict(dist_name=MR_NR_CELL_NAME, parameter="actDlSrsBm", value="true"),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="dlMimoMode",
        value="4x4 or 4x2 Closed Loop Spatial Multiplexing",
    ),
    dict(dist_name=MR_NR_BTS_NAME, parameter="actCoverageNonCoherentUes", value="true"),
]

MODIFY_PARA_1086_off_actCoverageNonCoherentUes_on_cni92005 = {
    'case_level_params':
        ['modify:NRCELL-3:actUlSrsBm=false',
         'modify:NRCELL-3:actDlSrsBm=true',
         'modify:NRCELL-3:muteLastSymbolInSsbSlot=MutingOfLastDlSymbolInAllSsbSlots',
         'modify:NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing',
         'modify:'+NR_BTS_ID+':actCoverageNonCoherentUes=true']
}

MODIFY_PARA_1086_off_8247_on_cni92005 = {
    'case_level_params':
        ['modify:NRCELL-3:actUlSrsBm=false',
         'modify:NRCELL-3:actDlSrsBm=true',
         'modify:NRCELL-3:muteLastSymbolInSsbSlot=MutingOfLastDlSymbolInSsbSlotZero',
         'modify:NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing']
}

MODIFY_PARA_1086_on_8247_on_cni92005_off = {
    'case_level_params':
        ['modify:NRCELL-3:actUlSrsBm=true',
         'modify:NRCELL-3:actDlSrsBm=true',
         'modify:NRCELL-3:muteLastSymbolInSsbSlot=NoMutingOfDlSymbol',
         'modify:NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing',
         'modify:'+NR_BTS_ID+':actCoverageNonCoherentUes=false']
}

MODIFY_PARA_1086_on_8247_on = [
    dict(dist_name=MR_NR_CELL_NAME, parameter="actUlSrsBm", value="true"),
    dict(dist_name=MR_NR_CELL_NAME, parameter="actDlSrsBm", value="true"),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="dlMimoMode",
        value="4x4 or 4x2 Closed Loop Spatial Multiplexing",
    ),
    dict(
        dist_name=MR_NR_BTS_NAME, parameter="actCoverageNonCoherentUes", value="false"
    ),
]

MODIFY_PARA_uespecific_true_8247_on_1086_on = [
    dict(dist_name=MR_NR_CELL_NAME, parameter="actUlSrsBm", value="true"),
    dict(dist_name=MR_NR_CELL_NAME, parameter="actDlSrsBm", value="true"),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="actUeCsirsCoexistCellCsirs",
        value="true",
    ),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="actCDrx",
        value="true",
    ),
    dict(
        dist_name=MR_NR_CELL2_NAME,
        parameter="actCDrx",
        value="true",
    ),
    dict(
        dist_name=MR_NR_FDDCELL_NAME,
        parameter="actCDrx",
        value="true",
    ),
    dict(
        dist_name=MR_NR_NRREL0_NAME,
        parameter="sCellAdditionMethod",
        value="covBasedA1",
    ),
    dict(
        dist_name=MR_NR_NRREL1_NAME,
        parameter="sCellAdditionMethod",
        value="covBasedA1",
    ),
    dict(
        dist_name=MR_NR_FDDCELL_NAME,
        parameter="weightForSCellSelection",
        value="40",
    ),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='a1MeasSCellAddSsbRsrp',
        value=[{'a1ThresholdSCellAddSsbRsrpFDD': '68', 'a1ThresholdSCellAddSsbRsrpTDD': '76'}])
]

MODIFY_PARA_cellspecific_8247_on_1086_on = [
    dict(dist_name=MR_NR_CELL_NAME, parameter="actUlSrsBm", value="true"),
    dict(dist_name=MR_NR_CELL_NAME, parameter="actDlSrsBm", value="true"),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="actUeCsirsCoexistCellCsirs",
        value="false",
    ),
]

MODIFY_PARA_uespecific_true_8247_on_1086_off_weightforscell_fdd = [
    dict(dist_name=MR_NR_CELL_NAME, parameter="actUlSrsBm", value="false"),
    dict(dist_name=MR_NR_CELL_NAME, parameter="actDlSrsBm", value="true"),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="actUeCsirsCoexistCellCsirs",
        value="true",
    ),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="actCDrx",
        value="false",
    ),
    dict(
        dist_name=MR_NR_CELL2_NAME,
        parameter="actCDrx",
        value="false",
    ),
    dict(
        dist_name=MR_NR_FDDCELL_NAME,
        parameter="actCDrx",
        value="false",
    ),
    dict(
        dist_name=MR_NR_FDDCELL_NAME,
        parameter="weightForSCellSelection",
        value="100",
    ),
    dict(
        dist_name=MR_NR_NRREL0_NAME,
        parameter="sCellAdditionMethod",
        value="covBasedA1",
    ),
    dict(
        dist_name=MR_NR_NRREL1_NAME,
        parameter="sCellAdditionMethod",
        value="covBasedA1",
    ),
]

MODIFY_PARA_uespecific_true_8247_on_1086_on_scelladd_blind_weightforscell_fdd = [
    dict(dist_name=MR_NR_CELL_NAME, parameter="actUlSrsBm", value="true"),
    dict(dist_name=MR_NR_CELL_NAME, parameter="actDlSrsBm", value="true"),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="actUeCsirsCoexistCellCsirs",
        value="true",
    ),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="actCDrx",
        value="true",
    ),
    dict(
        dist_name=MR_NR_CELL2_NAME,
        parameter="actCDrx",
        value="true",
    ),
    dict(
        dist_name=MR_NR_FDDCELL_NAME,
        parameter="actCDrx",
        value="true",
    ),
    dict(
        dist_name=MR_NR_FDDCELL_NAME,
        parameter="weightForSCellSelection",
        value="100",
    ),
    dict(
        dist_name=MR_NR_NRREL0_NAME,
        parameter="sCellAdditionMethod",
        value="blind",
    ),
    dict(
        dist_name=MR_NR_NRREL1_NAME,
        parameter="sCellAdditionMethod",
        value="blind",
    ),
]

MODIFY_PARA_uespecific_true_8247_on_1086_on_weightforscell_fdd = [
    dict(dist_name=MR_NR_CELL_NAME, parameter="actUlSrsBm", value="true"),
    dict(dist_name=MR_NR_CELL_NAME, parameter="actDlSrsBm", value="true"),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="actUeCsirsCoexistCellCsirs",
        value="true",
    ),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="actCDrx",
        value="true",
    ),
    dict(
        dist_name=MR_NR_CELL2_NAME,
        parameter="actCDrx",
        value="true",
    ),
    dict(
        dist_name=MR_NR_FDDCELL_NAME,
        parameter="actCDrx",
        value="true",
    ),
    dict(
        dist_name=MR_NR_FDDCELL_NAME,
        parameter="weightForSCellSelection",
        value="100",
    ),
    dict(
        dist_name=MR_NR_NRREL0_NAME,
        parameter="sCellAdditionMethod",
        value="covBasedA1",
    ),
    dict(
        dist_name=MR_NR_NRREL1_NAME,
        parameter="sCellAdditionMethod",
        value="covBasedA1",
    ),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='a1MeasSCellAddSsbRsrp',
        value=[{'a1ThresholdSCellAddSsbRsrpFDD': '93', 'a1ThresholdSCellAddSsbRsrpTDD': '100'}])
]

MODIFY_PARA_1086_off_8247_on = [
    dict(dist_name=MR_NR_CELL_NAME, parameter="actUlSrsBm", value="false"),
    dict(dist_name=MR_NR_CELL_NAME, parameter="actDlSrsBm", value="true"),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="dlMimoMode",
        value="4x4 or 4x2 Closed Loop Spatial Multiplexing",
    ),
]

MODIFY_PARA_1086_on_8247_on_2200_on = [
    dict(dist_name=MR_NR_CELL_NAME, parameter="actUlSrsBm", value="true"),
    dict(dist_name=MR_NR_CELL_NAME, parameter="actDlSrsBm", value="true"),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="srsForBeamMgmt",
        value=[
            {
                "bSRS": "2",
                "cSRS": "12",
                "srsUePeriodicity": "slots40",
            }
        ],
    ),
    dict(
        dist_name=MR_NR_BTS_NAME, parameter="actCoverageNonCoherentUes", value="false"
    ),
    dict(dist_name=MR_NR_CELL_NAME, parameter="numberOfRxBeamforming", value="4Rx"),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="beamSet",
        value=[{"basicBeamSet": "beamSet_5_1"}],
    ),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="beamSet",
        value=[{"nrBtsBeamRefinementP2": "false"}],
    ),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="periodicCsiAcquisition",
        value=[
            {
                "csiReportPeriodicity": "slots320",
                "csirsNumberWithinReportPeriod_Set1": "1",
                "maxCsirsNumber": "4",
                "csirsPower": "18",
            }
        ],
    ),
    dict(dist_name=MR_NR_CELL_NAME, parameter="actBeamforming", value="true"),
    dict(dist_name=MR_NR_CELL_NAME, parameter="ssPbchBlockPower", value="15"),
    dict(dist_name=MR_NR_CELL_NAME, parameter="nrCellType", value="8DL4UL"),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter="dlMimoMode",
        value="8x4 Closed Loop Spatial Multiplexing",
    ),
]


MODIFY_SCF_1086_on_8247_on_2200_on = [
    "delete:NRCELL-3:periodicCsiAcquisition",
    "add:NRCELL-3:periodicCsiAcquisition",
    "add:NRCELL-3:actUeCsirsCoexistCellCsirs=false",
    "modify:NRCELL-3:dlMimoMode=8x4 Closed Loop Spatial Multiplexing",
    'add:NRCELL-3:periodicCsiAcquisition:{'
    '"csiReportPeriodicity": "slots320",  "csirsNumberWithinReportPeriod_Set1": "1",'
    '"csirsPower": "18", "maxCsirsNumber": "4"}',
]

MODIFY_SCF_1086_on_8247_on_2200_on_add_scramblingIdStep = [
    "delete:NRCELL-3:periodicCsiAcquisition",
    "add:NRCELL-3:periodicCsiAcquisition",
    "add:NRCELL-3:actUeCsirsCoexistCellCsirs=false",
    "modify:NRCELL-3:dlMimoMode=8x4 Closed Loop Spatial Multiplexing",
    "modify:NRCELL-3:actCsirsMultiplexing=true",
    'add:NRCELL-3:periodicCsiAcquisition:{'
    '"csiReportPeriodicity": "slots320",  "csirsNumberWithinReportPeriod_Set1": "1",'
    '"csirsPower": "18", "maxCsirsNumber": "4", "scramblingIdStep": "3"}',
]

MODIFY_SCF_1086_on_8247_on_2200_on_srsUePeriodicity = [
    "delete:NRCELL-3:periodicCsiAcquisition",
    "add:NRCELL-3:periodicCsiAcquisition",
    "add:NRCELL-3:actUeCsirsCoexistCellCsirs=false",
    "modify:NRCELL-3:dlMimoMode=8x4 Closed Loop Spatial Multiplexing",
    "modify:NRCELL-3:srsForBeamMgmt:srsUePeriodicity=slots20",
    'add:NRCELL-3:periodicCsiAcquisition:{'
    '"csiReportPeriodicity": "slots320",  "csirsNumberWithinReportPeriod_Set1": "1",'
    '"csirsPower": "18", "maxCsirsNumber": "4" }',
]

MODIFY_SCF_1086_on_8247_on_2200_on_srsUePeriodicity_add_scramblingIdStep = [
    "delete:NRCELL-3:periodicCsiAcquisition",
    "add:NRCELL-3:periodicCsiAcquisition",
    "add:NRCELL-3:actUeCsirsCoexistCellCsirs=false",
    "modify:NRCELL-3:dlMimoMode=8x4 Closed Loop Spatial Multiplexing",
    "modify:NRCELL-3:srsForBeamMgmt:srsUePeriodicity=slots20",
    'add:NRCELL-3:periodicCsiAcquisition:{'
    '"csiReportPeriodicity": "slots320",  "csirsNumberWithinReportPeriod_Set1": "1",'
    '"csirsPower": "18", "maxCsirsNumber": "4", "scramblingIdStep": "3"}',
]


MODIFY_SCF_actUeCsirsCoexistCellCsirs_true_chbw_100MHz_40MHz = {
    'framestructure': '11160ms',
    'cell_chbw': {
        '3': '100MHz',
        '4': '40MHz'},
    'case_level_params':
        ['modify:NRCELL-3:prachConfigurationIndex=9',
         'modify:NRCELL-3:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-3:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=2/8',
         'modify:NRCELL-3:actUeCsirsCoexistCellCsirs=true',
         'modify:NRCELL-4:prachConfigurationIndex=9',
         'modify:NRCELL-4:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-4:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=2/8',
         'modify:NRCELL-4:actUeCsirsCoexistCellCsirs=true']
}

# ------------ swconfig 8247 flags ------------------
# rdNumberOfUeCsirsSymbol --> test purpose for UE/CELL specific CSI-RS
# 0x580265=0
SWCONFIG_cell_specific_CSI_RS = ["0x580265=0"]

# rdSrsCodebookAndTas : 0: FALSE[default], 1: TRUE;'antennaSwitching' SRS can overlap with codebook SRS or not
# 0x590103=0
# rdMaxSrsResPerSym1116
# 0x590128=1

SWCONFIG_SRS_exhuased = ["0x590103=0", "0x590128=1", "0x580265=0"]
