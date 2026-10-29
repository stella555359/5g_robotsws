"""
Global static variables for NR-RRC messages

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""

from taf.rfrl.utilities.parsers.pcap_checker import AwaitedMessage, inspectors

RRC_SETUP_REQ = AwaitedMessage(
    name='RRCSetupRequest',
    find_by=[inspectors.HasInspector('nr-rrc.rrcSetupRequest_element')],
    verify_by=[],
)

RRC_SETUP = AwaitedMessage(
    name='RRCSetup',
    find_by=[inspectors.HasInspector('nr-rrc.rrcSetup_element')],
    verify_by=[],
)

RRC_SETUP_PASSES = AwaitedMessage(
    name='RRCSetup',
    find_by=[inspectors.HasInspector('nr-rrc.rrcSetup_element')],
    verify_by=[inspectors.PassesInspector('%s')],
)

RRC_SETUP_BWP = AwaitedMessage(
    name='RRCSetup',
    find_by=[inspectors.HasInspector('nr-rrc.rrcSetup_element')],
    verify_by=[
        inspectors.HasInspector('nr-rrc.bwp_Id', '1'),
        inspectors.HasInspector('nr-rrc.locationAndBandwidth', '%s'),
        inspectors.HasInspector('nr-rrc.firstActiveDownlinkBWP_Id', '1'),
        inspectors.HasInspector('nr-rrc.firstActiveUplinkBWP_Id', '1'),
    ],
)

RRC_SETUP_COMPLETE = AwaitedMessage(
    name='RRCSetupComplete',
    find_by=[inspectors.HasInspector('nr-rrc.rrcSetupComplete_element')],
    verify_by=[],
)

RRC_RELEASE = AwaitedMessage(
    name='RRCRelease',
    find_by=[inspectors.HasInspector('nr-rrc.rrcRelease_element')],
    verify_by=[],
)

RRC_REESTABLISHMENT = AwaitedMessage(
    name='RRCReestablishment',
    find_by=[inspectors.HasInspector('nr-rrc.rrcReestablishmentRequest_element')],
    verify_by=[],
)

RRC_RECONFIG_PASSES = AwaitedMessage(
    name='RRCReconfiguration',
    find_by=[inspectors.HasInspector('nr-rrc.rrcReconfiguration_element')],
)

RRC_RECONFIG_SCG_RELEASE = AwaitedMessage(
    name='RRCReconfiguration',
    find_by=[inspectors.HasInspector('nr-rrc.rrcReconfiguration_element')],
    verify_by=[
        inspectors.HasInspector('nr-rrc.mrdc_SecondaryCellGroupConfig', '0'),
        inspectors.HasInspector('nr-rrc.release_element'),
    ],
)

RRC_RECONFIG_MEAS_OBJECT_FR2 = AwaitedMessage(
    name='RRCReconfiguration',
    find_by=[
        inspectors.HasInspector('nr-rrc.rrcReconfiguration_element'),
        inspectors.HasInspector('nr-rrc.ssbSubcarrierSpacing', '4'),
    ],
    verify_by=[],
)

RRC_RECONFIG_MEAS_OBJECT_KA_TEST = AwaitedMessage(
    name='RRCReconfiguration',
    find_by=[
        inspectors.HasInspector('nr-rrc.rrcReconfiguration_element'),
        inspectors.HasInspector('nr-rrc.ssbSubcarrierSpacing', '4'),
    ],
    verify_by=[
        inspectors.HasInspector('nr-rrc.ssbFrequency', '2055259'),
        inspectors.NotHasInspector('nr-rrc.ssbFrequency', '2061595'),
    ],
)

RRC_RECONFIG_8CC = AwaitedMessage(
    name='RRCReconfiguration',
    find_by=[inspectors.HasInspector('nr-rrc.rrcReconfiguration_element')],
    verify_by=[
        inspectors.HasInspector('nr-rrc.sCellIndex', '2'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '3'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '4'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '5'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '6'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '7'),
    ],
)

RRC_RECONFIG_4CC = AwaitedMessage(
    name='RRCReconfiguration',
    find_by=[
        inspectors.HasInspector('nr-rrc.rrcReconfiguration_element'),
        inspectors.HasInspector('nr-rrc.mrdc_SecondaryCellGroupConfig'),
    ],
    verify_by=[
        inspectors.HasInspector('nr-rrc.sCellToAddModList', '3'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '2'),
        inspectors.HasInspector('nr-rrc.physCellId', '61'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '3'),
        inspectors.HasInspector('nr-rrc.physCellId', '62'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '4'),
        inspectors.HasInspector('nr-rrc.physCellId', '63'),
    ],
)

RRC_RECONFIG_NRDC_DETAILED = AwaitedMessage(
    name='RRCReconfiguration',
    find_by=[inspectors.HasInspector('nr-rrc.rrcReconfiguration_element')],
    verify_by=[
        inspectors.HasInspector('nr-rrc.mrdc_SecondaryCellGroupConfig', '1'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '2'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '3'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '4'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '5'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '6'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '7'),

        inspectors.HasInspector('nr-rrc.sCellConfigCommon_element'),
        inspectors.HasInspector('nr-rrc.sCellConfigDedicated_element'),
        inspectors.HasInspector('nr-rrc.SCellConfig_element'),
        inspectors.HasInspector('nr-rrc.csi_ReportConfigToAddModList', '8'),
        inspectors.HasInspector('nr-rrc.csi_MeasConfig', '1'),
        inspectors.HasInspector('nr-rrc.csi_ResourceConfigId'),
        inspectors.HasInspector('nr-rrc.CellGroupConfig_element'),
        inspectors.HasInspector('nr-rrc.downlinkBWP_ToAddModList', '1'),
        inspectors.HasInspector('nr-rrc.bwp_Dedicated_element'),
        inspectors.HasInspector('nr-rrc.pdcch_ConfigCommon', '1'),
        inspectors.HasInspector('nr-rrc.controlResourceSetToAddModList', '1'),
        inspectors.HasInspector('nr-rrc.spCellConfig_element'),
        inspectors.HasInspector('nr-rrc.downlinkConfigCommon_element'),
        inspectors.HasInspector('nr-rrc.scs_SpecificCarrierList', '1'),
        inspectors.HasInspector('nr-rrc.offsetToCarrier', '0'),
    ],
)

RRC_RECONFIG_PS_BWP = AwaitedMessage(
    name='RRCReconfiguration',
    find_by=[inspectors.HasInspector('nr-rrc.rrcReconfiguration_element')],
    verify_by=[
        inspectors.HasInspector('nr-rrc.bwp_Id', '1'),
        inspectors.HasInspector('nr-rrc.bwp_Id', '2'),
        inspectors.HasInspector('nr-rrc.locationAndBandwidth', '%s'),
    ],
)

RRC_RECONFIG_BWP = AwaitedMessage(
    name='RRCReconfiguration',
    find_by=[inspectors.HasInspector('nr-rrc.rrcReconfiguration_element')],
    verify_by=[
        inspectors.HasInspector('nr-rrc.bwp_Id', '1'),
        inspectors.HasInspector('nr-rrc.locationAndBandwidth', '%s'),
        inspectors.HasInspector('nr-rrc.firstActiveDownlinkBWP_Id', '1'),
        inspectors.HasInspector('nr-rrc.firstActiveUplinkBWP_Id', '1'),
    ],
)

RRC_RECONFIG_NO_DRX = AwaitedMessage(
    name='RRCReconfiguration',
    find_by=[inspectors.HasInspector('nr-rrc.rrcReconfiguration_element')],
    verify_by=[inspectors.NotHasInspector('nr-rrc.drx_Config')],
)

RRC_RECONFIG_DRX = AwaitedMessage(
    name='RRCReconfiguration',
    find_by=[inspectors.HasInspector('nr-rrc.rrcReconfiguration_element')],
    verify_by=[inspectors.HasInspector('nr-rrc.drx_Config')],
)

RRC_RECONFIG_COMPLETE = AwaitedMessage(
    name='RRCReconfigurationComplete',
    find_by=[inspectors.HasInspector('nr-rrc.rrcReconfigurationComplete_element')],
    verify_by=[],
)

UE_CAPABILITY_INFO = AwaitedMessage(
    name='ueCapabilityInformation',
    find_by=[inspectors.HasInspector('nr-rrc.ueCapabilityInformation_element')],
    verify_by=[],
)

UE_CAPABILITY_INFO_PS_BWP = AwaitedMessage(
    name='ueCapabilityInformation',
    find_by=[inspectors.HasInspector('nr-rrc.ueCapabilityInformation_element')],
    verify_by=[
        inspectors.HasInspector('nr-rrc.bwp_SwitchingDelay'),
        inspectors.HasInspector('nr-rrc.bwp_SameNumerology'),
        inspectors.HasInspector('nr-rrc.dl_SchedulingOffset_PDSCH_TypeA'),
    ],
)

MEASUREMENT_REPORT_PCI = AwaitedMessage(
    name='measurementReport',
    find_by=[inspectors.HasInspector('nr-rrc.measurementReport_element')],
)

RRC_RECONFIG_NRDC_SCG_CONFIG = AwaitedMessage(
    name='NRDC SCG Setup',
    find_by=[inspectors.HasInspector('nr-rrc.mrdc_SecondaryCellGroupConfig', '1')],
    verify_by=[],
)

RRC_RECONFIG_SNODE_ADD_MOD = AwaitedMessage(
    name='NRDC SCG Setup',
    find_by=[inspectors.HasInspector('nr-rrc.secondaryCellGroup')],
    verify_by=[],
)

RRC_RECONFIG_SCELL_ADD = AwaitedMessage(
    name='NRDC SCG Setup',
    find_by=[inspectors.HasInspector('nr-rrc.sCellToAddModList')],
    verify_by=[],
)

RRC_RECONFIG_SCELL_RELEASE = AwaitedMessage(
    name='NRDC SCG Setup',
    find_by=[inspectors.HasInspector('nr-rrc.sCellToReleaseList')],
    verify_by=[],
)
