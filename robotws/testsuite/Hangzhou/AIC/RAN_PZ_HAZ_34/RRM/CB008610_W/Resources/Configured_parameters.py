import datetime
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

gnb_id = str(tl.gnbs[0].dus[0].instance_id)
MRBTS_dist = 'MRBTS-' + gnb_id
NRBTS_dist = MRBTS_dist + '/NRBTS-' + gnb_id
NRCELL_dist = NRBTS_dist + '/NRCELL-1'
NRDRB1_dist = NRBTS_dist + '/NRDRB-1'
NRBTSDU_dist = NRBTS_dist + '/NRDU-1'
NRCELLGRP_dist = NRBTS_dist + '/NRCELLGRP-0'
NRSYSINFO_dist = NRBTS_dist + '/NRSYSINFO_PROFILE-0'
BWP1_PDCCH_dist = NRBTS_dist + '/BWP_PROFILE-0/PDCCH-1'
BWP47_PDCCH_dist = NRBTS_dist + '/BWP_PROFILE-47/PDCCH-1'

CU_parameters_unschedule = {
    NRCELL_dist: {'actCDrx': 'false'},
    NRDRB1_dist: {'nsaDrbParam/0/ulDataPath': 'ulOverNr'},
}
CU_parameters_schedule = {
    NRCELL_dist: {'actCDrx': 'true'},
    NRCELL_dist: {'drxProfile1/0/drxLongCycle': '320ms'},
    NRDRB1_dist: {'nsaDrbParam/0/ulDataPath': 'ulOverNr'},
}

DU_parameters_schedule_COMMON = {
    NRCELL_dist: {
        'actAdaptiveSr': 'false',
        'actProactUlScheduling': 'true',
        'actCDrx': 'true',
        'drxProfile1/0/drxLongCycle': '320ms',
        'drxProfile1/0/drxOnDurationTimer': '10ms',
        'drxProfile1/0/drxInactivityTimer': '200ms',
        'pucchModeSelect': 'longPucch',
        'actUlTxSkip': 'true',
        'ulProGrantTimerTxSkip': '1000',
        'ulSchedTimeIntervalTxSkip': '4',
        'pucchModeSelect': 'longPucch',
        'periodicCsiAcquisition/0/csiReportPeriodicity': 'slots320',
    }
}
DU_parameters_unschedule_COMMON = {
    NRCELL_dist: {
        'actAdaptiveSr': 'true',
        'srPeriodicityMin': 'slots10',
        'srPeriodicity': 'slots80',
        'actProactUlScheduling': 'false',
        'actCDrx': 'false',
        'periodicCsiAcquisition/0/csiReportPeriodicity': 'slots320',
        'pucchModeSelect': 'longPucch',
    }
}
DU_parameters_1208 = {
    NRCELL_dist: {
        'tddFrameStructure/0/frameStructureType': 'semiStatic',
        'tddFrameStructure/0/guardPeriodLength': '2Symbols',
        'tddFrameStructure/0/tdLteUlDlConfig': 'tdLteConfig2',
        'tddFrameStructure/0/ulDlDataSlotRatio': '1/4',
        'prachConfigurationIndex': '148',
    }
}
DU_parameters_1070 = {
    NRCELL_dist: {
        'tddFrameStructure/0/frameStructureType': 'semiStatic',
        'tddFrameStructure/0/guardPeriodLength': '2Symbols',
        'tddFrameStructure/0/tdLteUlDlConfig': 'tdLteConfig2',
        'tddFrameStructure/0/ulDlDataSlotRatio': '3/7',
        'prachConfigurationIndex': '148',
    }
}
DU_parameters_1116_0_shift = {
    NRCELL_dist: {
        'tddFrameStructure/0/frameStructureType': 'tdlte',
        'tddFrameStructure/0/guardPeriodLength': '6Symbols',
        'tddFrameStructure/0/tdLteUlDlConfig': 'tdLteConfig2',
        'tddFrameStructure/0/ulDlDataSlotRatio': '2/8',
        'prachConfigurationIndex': '9',
    }
}
VC1_parameters_DU = {
    NRCELL_dist: {
        'nrCellType': '4DL4UL',
        'dlMimoMode': '4x4 or 4x2 Closed Loop Spatial Multiplexing',
        'ulMimoMode': 'Closed loop Spatial Multiplexing (2x2)',
        'actDl256Qam': 'true',
        'csirsForTracking/0/csirsTrackingPeriod': '80ms',
        'prachConfigurationIndex': '98',
        'dlDMRSAdditionalPosition': 'One additional DMRS',
        'actPdschAtSsbSlots': 'true',
        'actPrachMultiplexing': 'true',
        'actPdschRmCsirsForTracking': 'true',
        'csirsForTracking/0/rbAllocation': '52RB',
        'beamSet/0/nrBtsBeamRefinementP2': 'false',
        'actAperCsi': 'false',
        'actBeamforming': 'false',
        'actDlMuMimo': 'false',
        'type0CoresetConfigurationIndex': '10',
        'type0SearchSpaceConfigurationIndex': '4',
        'tddFrameStructure/0/frameStructureType': 'semiStatic',
        'tddFrameStructure/0/guardPeriodLength': '2Symbols',
        'tddFrameStructure/0/tdLteUlDlConfig': 'tdLteConfig2',
        'tddFrameStructure/0/ulDlDataSlotRatio': '1/4',
    },
    NRCELLGRP_dist: {
        'numberOfTransmittedSsBlocks': '1 beam',
        'ssBurstSetPeriod': '20',
    },
    NRBTS_dist: {
        'actFdmScheduling': 'true',
    },
    BWP1_PDCCH_dist: {
        'dciSiAggregationLevel': 'AL4',
    },
    BWP47_PDCCH_dist: {
        'dciSiAggregationLevel': 'AL4',
    },
}
VC5_parameters_DU = {
    NRCELL_dist: {
        'ulMimoMode': 'Closed loop Spatial Multiplexing (2x2)',
        'csirsForTracking/0/csirsTrackingPeriod': '80ms',
        'prachConfigurationIndex': '87',
        'dlDMRSAdditionalPosition': 'One additional DMRS',
        'actPrachMultiplexing': 'true',
        'csirsForTracking/0/rbAllocation': '52RB',
        'ulDMRSAdditionalPosition': 'No additional DMRS',
        'pucchModeSelect': 'longPucch',
        'periodicCsiAcquisition/0/csiReportPeriodicity': 'slots320',
        'actUl256Qam': 'true',
        'pucchF3ModulationScheme': 'qpsk_4psk',
        'pucchF3MaxCodeRate': 'zeroDot25',
        'reqMinNumPuschPrb': '0',
        'gscnOrSsPbchArfcn': '0',
        'tddFrameStructure/0/frameStructureType': 'semiStatic',
        'tddFrameStructure/0/guardPeriodLength': '2Symbols',
        'tddFrameStructure/0/tdLteUlDlConfig': 'tdLteConfig2',
        'tddFrameStructure/0/ulDlDataSlotRatio': '3/7',
    },
    NRCELLGRP_dist: {
        'numberOfTransmittedSsBlocks': '1 beam',
        'ssBurstSetPeriod': '20',
    },
    NRBTS_dist: {
        'actFdmEnhancedScheduling': 'true',
    },
}
