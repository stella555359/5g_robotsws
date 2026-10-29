rrc_setup_req = """
    RRCSetupRequest {
        findBy { has(nr-rrc.rrcSetupRequest_element) }}
"""
rrc_setup = """
    RRCSetup {
        findBy { has(nr-rrc.rrcSetup_element) }}
"""
rrc_setup_passes = """
    RRCSetup {
        findBy { has(nr-rrc.rrcSetup_element) }
        verifyBy { passes(%s) }}
"""
rrc_setup_bwp = """
    RRCSetup {
        findBy { has(nr-rrc.rrcSetup_element) }
        verifyBy { has(nr-rrc.bwp_Id:=1)
                   has(nr-rrc.locationAndBandwidth:=%s)
                   has(nr-rrc.firstActiveDownlinkBWP_Id:=1)
                   has(nr-rrc.firstActiveUplinkBWP_Id:=1) }}
"""
rrc_setup_complete = """
    RRCSetupComplete {
        findBy { has(nr-rrc.rrcSetupComplete_element) }}
"""
rrc_release = """
    RRCRelease {
        findBy { has(nr-rrc.rrcRelease_element) }}
"""
rrc_reestablishment = """
    RRCReestablishment {
        findBy { has(nr-rrc.rrcReestablishmentRequest_element) }}
"""
rrc_reconfig_passes = """
    RRCReconfiguration {
        findBy { has(nr-rrc.rrcReconfiguration_element) }
        verifyBy { passes(%s) }}
"""
rrc_reconfig_scg_release = """
    RRCReconfiguration with nrdc_SecondaryCellGroupConfig: release: NULL {
        findBy { has(nr-rrc.rrcReconfiguration_element) }
        verifyBy { has(nr-rrc.mrdc_SecondaryCellGroupConfig:=0)
                   has(nr-rrc.release_element) }}
"""
rrc_reconfig_8cc = """
    RRCReconfiguration {
        findBy { has(nr-rrc.rrcReconfiguration_element) }
        verifyBy { has(nr-rrc.sCellIndex:=2)
                   has(nr-rrc.sCellIndex:=3)
                   has(nr-rrc.sCellIndex:=4)
                   has(nr-rrc.sCellIndex:=5)
                   has(nr-rrc.sCellIndex:=6)
                   has(nr-rrc.sCellIndex:=7) }}
"""
rrc_reconfig_nrdc_detailed = """
    RRCReconfiguration {
        findBy { has(nr-rrc.rrcReconfiguration_element) }
        verifyBy { has(nr-rrc.mrdc_SecondaryCellGroupConfig:=1)
                   has(nr-rrc.sCellIndex:=2)
                   has(nr-rrc.sCellIndex:=3)
                   has(nr-rrc.sCellIndex:=4)
                   has(nr-rrc.sCellIndex:=5)
                   has(nr-rrc.sCellIndex:=6)
                   has(nr-rrc.sCellIndex:=7)
                   has(nr-rrc.sCellConfigCommon_element)
                   has(nr-rrc.sCellConfigDedicated_element)
                   has(nr-rrc.SCellConfig_element)
                   has(nr-rrc.csi_ReportConfigToAddModList:=8)
                   has(nr-rrc.csi_MeasConfig:=1)
                   has(nr-rrc.csi_ResourceConfigId)
                   has(nr-rrc.CellGroupConfig_element)
                   has(nr-rrc.downlinkBWP_ToAddModList:=1)
                   has(nr-rrc.bwp_Dedicated_element)
                   has(nr-rrc.pdcch_ConfigCommon:=1)
                   has(nr-rrc.controlResourceSetToAddModList:=1)
                   has(nr-rrc.spCellConfig_element)
                   has(nr-rrc.downlinkConfigCommon_element)
                   has(nr-rrc.scs_SpecificCarrierList:=1)
                   has(nr-rrc.offsetToCarrier:=0) }}
"""
rrc_reconfig_ps_bwp = """
    RRCReconfiguration {
        findBy { has(nr-rrc.rrcReconfiguration_element) }
        verifyBy { has(nr-rrc.bwp_Id:=1)
                   has(nr-rrc.bwp_Id:=2)
                   has(nr-rrc.locationAndBandwidth:=%s) }}
"""
rrc_reconfig_bwp = """
    RRCReconfiguration {
        findBy { has(nr-rrc.rrcReconfiguration_element) }
        verifyBy { has(nr-rrc.bwp_Id:=1)
                   has(nr-rrc.locationAndBandwidth:=%s)
                   has(nr-rrc.firstActiveDownlinkBWP_Id:=1)
                   has(nr-rrc.firstActiveUplinkBWP_Id:=1) }}
"""
rrc_reconfig_complete = """
    RRCReconfigurationComplete {
        findBy { has(nr-rrc.rrcReconfigurationComplete_element) }}
"""
ue_capability_info = """
    ueCapabilityInformation {
        findBy { has(nr-rrc.ueCapabilityInformation_element) }}
"""
ue_capability_info_ps_bwp = """
    ueCapabilityInformation {
        findBy { has(nr-rrc.ueCapabilityInformation_element) }
        verifyBy { has(nr-rrc.bwp_SwitchingDelay)
                   has(nr-rrc.bwp_SameNumerology)
                   has(nr-rrc.dl_SchedulingOffset_PDSCH_TypeA) }}
"""
measurement_raport = """
    measurementReport {
        findBy { has(nr-rrc.measurementReport_element) }}
"""
rrc_reconfig_nrdc_scg_config = """
    NRDC SCG Setup {
        findBy { has(nr-rrc.mrdc_SecondaryCellGroupConfig:=1) }}
"""
rrc_reconfig_snode_add_mod = """
    NRDC SCG Setup {
        findBy { has(nr-rrc.secondaryCellGroup) }}
"""
