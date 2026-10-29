*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008541: BWP Use Optimized for Feature Interworking and NR CA
...         The feature supports setting of SCell in NR CA when UE supports only the small BWP and not the
...         full carrier bandwidth of the SCell. It enables simultaneous support on one cell of Management
...         of UE Bandwidth Capabilities and of Dynamic BWP Adaptation for UE Power Saving.
...
...      == TEST SET NAME ==
...         CB008541-A-B001 SA Carrier Aggregation SCell selection for FDD PCell and FDD SCell
...
...      == TESTING SPLIT ==
...         CB008541-A-B001 SA Carrier Aggregation SCell selection for FDD PCell and FDD SCell
...         CB008541-A-B002 NSA Carrier Aggregation SCell selection for TDD PCell and TDD SCell
...         CB008541-A-B101 SA Carrier Aggregation SCell selection for FDD PCell and TDD SCell
...         CB008541-A-B102 NSA Carrier Aggregation SCell selection for FDD PCell and TDD SCell
...         CB008541-A-B201 SA Carrier Aggregation SCell selection for TDD PCell and FDD SCell
...         CB008541-A-B202 NSA Carrier Aggregation SCell selection for TDD PCell and FDD SCell
...         CB008541-A-B301 SA Carrier Aggregation SCell selection for TDD PCell and TDD SCell
...         CB008541-A-B401 Online feature activation and deactivation
...         CB008541-A-B501 SA Carrier Aggregation SCell Change
...
...      == CONTACTS ==
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...
...      == REFERENCES ==
...         CB008541 CFAM
...
...      == HISTORY ==
...         [31.05.2023] - Create Test Suite
...         [26.06.2023] - review closed (https://collab.ext.net.nokia.com/ui#review:id=886710)

Resource    ./resources/CB008541_keywords_KRK.robot
#Library   taf.sbts.oam.coam.admin
#Library    taf.sw.scout    WITH NAME     scout
Resource        ../resources/robot/configuration_id.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008541/8541b401_3_config.yml

Suite Setup  Prepare test suite   ute_ca=True

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_FDD_2Cells_SA_n25_n66.lua
${SCFC}=       ${CURDIR}/../../../../../custom-config/Bangalore/RRM/ET/CB008541/scfc_B401_3_FS.xml
${AP_XML}=     ${CURDIR}/../../../../../custom-config/Bangalore/RRM/ET/CB008541/iphy_FDD_2cells_SA_L1B_n25_n66.xml

@{NRCELL_1_large_bwp}=  ${rb_scs15_bw30}  ${loc_and_bw_scs15_bw30}
@{NRCELL_1_small_bwp}=  ${rb_scs15_bw20}  ${loc_and_bw_scs15_bw20}

@{NRCELL_2_large_bwp}=  ${rb_scs15_bw30}  ${loc_and_bw_scs15_bw30}
@{NRCELL_2_small_bwp}=  ${rb_scs15_bw20}  ${loc_and_bw_scs15_bw20}

*** Test Cases ***
[1][1.0] CB008541-A-B401_3 Feature flag online change during SCell addition
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   Purpose of this test is to verify that online change of actEnhMultipleDedicatedBWPs feature flag after
    ...   UE attach does not affect Scell Addition procedure. Scell Addition method is set as A1 measurement based.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL-1 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n25
    ...        SCS: 15kHz
    ...        large BWP: 30MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP: 20MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n106
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - NRCELL-2 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n66
    ...        SCS: 15kHz
    ...        large BWP: 30MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP: 20MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n106
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - AMF1 simulated
    ...  - UE5 - Airphone simulator
    ...        UE5 supports 2CC n25A-n66A band combination
    ...        In Feature Set Combination related to n25A-n66A CA band combination UE5 indicates:
    ...             In FeatureSetDownlinkPerCC for B25 carrier:
    ...	                15kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz30
    ...	            In FeatureSetUplinkPerCC for B25 carrier:
    ...	                15kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz30
    ...	            In FeatureSetDownlinkPerCC for B66 carrier:
    ...	                15kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz20
    ...	            In FeatureSetUplinkPerCC for B66 carrier:
    ...	                15kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz20
    ...	       channelBWs-DL = mhz30 on fr1 scs-15kHz entry for B25
    ...	       channelBWs-UL = mhz30 on fr1 scs-15kHz entry for B25
    ...	       channelBWs-DL = mhz20 on fr1 scs-15kHz entry for B66
    ...	       channelBWs-UL = mhz20 on fr1 scs-15kHz entry for B66
    ...
    ...  - gNB2 up and running with two SA cells OnAir (NRCELL-1 acts as PCell and NRCELL-2 acts as SCell)
    ...  - NRBTS/actMultipleDedicatedBWPs = true (CB007552 feature flag)
    ...  - NRBTS/NRCELL-1/NRREL/sCellAdditionMethod = covBasedA1 (relation to NRCELL-2)
    ...  - NRBTS/actMeasBasedSCellAddition = true
    ...  - NRBTS/NRCELL-1/a1MeasSCellAddEnabled = rsrp
    ...  - NRBTS/NRCELL-1/a2MeasSCellRelEnabled = rsrp
    ...  - NRBTS/NRCELL-1/actEnhMultipleDedicatedBWPs = false (CB008541-A feature flag)
    ...  - NRBTS/NRCELL-1/allowUnsuppBcOrBcs = 0 "complete BCS check"
    ...  - NRBTS/NRDU/carrierAggregationSupportList = ca_Fdd_Fdd
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AHFII radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_541, 5G_RAN_USR_RRM_14852
    ...
    ...  == REQUIRED LOGS ==
    ...    F1AP, NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior (Nokia - PL/Krakow) <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008541-6208 User Scenario#4 SA Feature deactivation before UE re-establishment - SCell configured
    ...        with small BWP
    ...
    ...  == HISTORY ==
    ...     [31.05.2023] - TC Create
    ...     [26.06.2023] - review closed (https://collab.ext.net.nokia.com/ui#review:id=886710)

    [Setup]  Prepare test environment B401_3
    [Tags]    QC_303813      QCD_MN_RAN    QCP_RAN_ET

    Attach UE1 to NRCELL-1
    Verify that Initial Context Setup with NRCELL-1 with large BWP profile was successful for UE1
    Verify that A1 measurement is not configured for UE1

    Set NRCELL-1 actEnhMultipleDedicatedBWPs to true

    Trigger reestablishment for UE1 in NRCELL-1
    Verify that A1 measurement is not configured for UE1

    Attach UE2 to NRCELL-1
    Verify that Initial Context Setup with NRCELL-1 with large BWP profile was successful for UE2
    Verify that A1 measurement was installed for UE2

    Attach UE3 to NRCELL-1
    Verify that Initial Context Setup with NRCELL-1 with large BWP profile was successful for UE3
    Verify that A1 measurement was installed for UE3

    Wait until PM counters file is ready and saved
    # Changes due to PR720042 - counter is increased after feature activation
    Verify that M55167C00001 SAMPLES_BWP_UE_AMOUNTS counter is in range 1 - 300 in NRCELL-1 in gNB2

    Trigger A1 measurement for UE3 with result greater than FDD threshold
    Verify that Scell Addition of NRCELL-2 with small BWP profile is completed for UE3
    Verify that A2 measurement is configured for UE3

    Set NRCELL-1 actEnhMultipleDedicatedBWPs to false

    Trigger A1 measurement for UE2 with result greater than FDD threshold
    Verify that Scell Addition of NRCELL-2 with small BWP profile is completed for UE2

    Trigger A2 measurement for UE3 with result greater than FDD threshold
    Verify that NRCELL-2 Scell was released for UE3
    Verify that A1 measurement was installed for UE3

    Wait until PM counters file is ready and saved
    Verify that M55167C00001 SAMPLES_BWP_UE_AMOUNTS counter is in range 1 - 300 in NRCELL-1 in gNB2
    Verify that M55167C00002 SUM_UE_SCELL_CONF_S_BWP counter is in range 1 - 300 in NRCELL-1 in gNB2
    Verify that M55139C04001 GNB_DU_SCELL_ADM_S_BWP_SUCC counter is equal 2 in NRCELL-1 in gNB2
    Verify that M55139C04002 GNB_DU_SCELL_ADM_L_BWP_SUCC counter is equal 0 in NRCELL-1 in gNB2
    Verify that M55167C00003 SUM_UE_SCELL_CONF_L_BWP counter is equal 0 in NRCELL-1 in gNB2


    [Teardown]   Run Keywords   Cleanup after test B401_3
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Prepare test environment B401_3
    Wait until PM counters file is ready and saved

Cleanup after test B401_3
    Deregister UE1
    Deregister UE2
    Deregister UE3
    Set NRCELL-1 actEnhMultipleDedicatedBWPs to false

Verify that A1 measurement is not configured for UE${ue_id}
    Verify That Message Fulfills Query
    ...     eventA1 is not present
    ...     message_alias=PCellConfiguration
    ...     flow_alias=UE${ue_id}_RRC_Reconfiguration_PCell

Trigger reestablishment for UE${ue_id} in NRCELL-1
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReestablishmentRequest
    ...     UE_${ue_id}:NR-RRC_RRCReestablishment
    ...     UE_${ue_id}:NR-RRC_RRCReestablishmentComplete
    ...     alias=UE${ue_id}_RRC_reestablishment
    ...     overall_timeout=30

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as PCellConfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_Reconfiguration_PCell
    ...     overall_timeout=30

    Execute egate command  cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=1

    Flow occurred as expected   alias=UE${ue_id}_RRC_reestablishment
    Flow occurred as expected   alias=UE${ue_id}_RRC_Reconfiguration_PCell

Trigger A1 measurement for UE${ue_id} with result greater than FDD threshold
    Flow not occurred for message  alias=UE${ue_id}_RRC_Reconfiguration_SCell_Add
    Expect RRC Reconfiguration flow with sCellToAddModList for UE${ue_id}

    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A1 srsrp_nr=11 phycell_id=51 nrsrp_nr=11

Trigger A2 measurement for UE${ue_id} with result greater than FDD threshold
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as SCellReleaseReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_Reconfiguration_Scell_Release
    ...     overall_timeout=30

    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 scell=1 scell_rsrp=4

    Flow occurred as expected   alias=UE${ue_id}_RRC_Reconfiguration_PCell

Verify that A2 measurement is configured for UE${ue_id}
    Verify That Message Fulfills Query
    ...     reportConfigToAddModList contains (eventA2 is present)
    ...     message_alias=RRCReconfScellAdd
    ...     flow_alias=UE${ue_id}_RRC_Reconfiguration_SCell_Add

Verify that NRCELL-${cell_id} Scell was released for UE${ue_id}
    Verify That Message Fulfills Query
    ...     log to console  ${cell_id}
    ...     sCellToReleaseList is present
    ...     message_alias=SCellReleaseReconfiguration
    ...     flow_alias=UE${ue_id}_RRC_Reconfiguration_Scell_Release


Outdated Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=False
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Outdated Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=0    ${node_type}=gnb
    ${tl_name_only}      Get Hostname
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    Log To Console   ${node_id}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

Outdated Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Suite Variable  ${HOSTNAME}  ${hostname_combined}
    [Return]   ${HOSTNAME}
