*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Tomasz Dabrowski
...             :contact: tomasz.dabrowski@nokia.com

Library     ../../../resources/scout_report.py
Resource    ../keywords/traffic.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_testline_management
Library     ta5g_enb
Library     ta5g_iphy
Library     ute_wtssim
Library     ta5g_ue_mobility


Suite Setup        Run Keywords
...                                Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS}
...                AND             Update And Put Iphy Xml         input_filepath=${IPHY}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC}
...                                skip_relation_errors=True
...                AND             Reach Onair    lua_cfg=${EGATE}

Suite Teardown     Run Keyword    Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
@{swconfig_8717_rdFlag}=        0x890057=0 # rdActNrDualConnectivity - Parameter set to 0 implies intraGnb NR-DC enabled in all cells
${rdMergedMeasGapSetupAndDrxRelease}=        0x890046=1 # rdMergedMeasGapSetupAndDrxRelease
@{8717_SWCONFIG_FLAGS}=    ${rdMergedMeasGapSetupAndDrxRelease}    @{swconfig_8717_rdFlag}
${IPHY}=              ${CURDIR}/config/iphy_n78A_n257A_BOO_AP_LOO.xml
${SCFC}=              scfc_JC_B19_n78A_n257A_BOO_LOO.xml
${EGATE}=             ${CURDIR}/config/BOO_AP_LOO_n78_n257_JC_B19.cfg
@{FAULT_IDS_LIST}=           6450    4383
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${qosflows}=                3
${F1AP_UE_CONTEXT_MODIFICATION_REQUEST}
...    f1ap.UEContextModificationRequest_element &&
...    !nr-rrc.measGapConfig_element && nr-rrc.measObjectToAddModList==2 &&
...    nr-rrc.reportConfigToAddModList==1 && nr-rrc.measIdToAddModList==1 &&
...    nr-rrc.ssbFrequency==2071387&& nr-rrc.freqBandIndicatorNR==257 &&
...    nr-rrc.a4_Threshold=="rsrp" && nr-rrc.hysteresis==0 &&
...    nr-rrc.timeToTrigger=="ms5120" && nr-rrc.reportAmount=="r4" &&
...    nr-rrc.reportInterval=="ms1024"
${F1AP_DLRRC_MESSAGE_TRANSFER_RRC_RECONFIGURATION}
...    f1ap.DLRRCMessageTransfer_element &&
...    nr-rrc.measGapConfig_element&&nr-rrc.measObjectToAddModList==1 &&
...    nr-rrc.reportConfigToAddModList==1 && nr-rrc.measIdToAddModList==1 &&
...    nr-rrc.ssbFrequency==2071387 && nr-rrc.freqBandIndicatorNR==257 &&
...    nr-rrc.a4_Threshold=="rsrp" && nr-rrc.hysteresis==0 &&
...    nr-rrc.timeToTrigger=="ms5120" && nr-rrc.reportAmount=="r4" &&
...    nr-rrc.reportInterval=="ms1024"
${F1AP_UE_CONTEXT_RELEASE_COMMAND}
...    f1ap.UEContextReleaseCommand_element && f1ap.RRCContainer &&
...    nr-rrc.cellReselectionPriorities_element && nr-rrc.freqPriorityListNR == 4 &&
...    nr-rrc.carrierFreq == 295000 && nr-rrc.cellReselectionPriority == 7 &&
...    nr-rrc.carrierFreq == 286000 && nr-rrc.cellReselectionPriority == 3 &&
...    nr-rrc.carrierFreq == 158200 && nr-rrc.cellReselectionPriority == 2 &&
...    nr-rrc.carrierFreq == 636672 && nr-rrc.cellReselectionPriority == 0

*** Test Cases ***
CB008717_JC_B19a_RRC_Connection_Release_When_Idle_Mode_Mobility_Steering_Is_Enabled_And_UE_Is_Not_In_NR-DC_Mode
    [Setup]    Run Keywords     Start Default Logging And Mark New Test
    Attach Ue    ue_id=1
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Sleep    15s    reason=Wait for traffic to stabilize
    Deregister Ue By AMF
    Verify In F1AP Messages That A4 NR-DC Measurements Are Configured and Cell Reselection Priorities Set On RRCRelease
    [Teardown]     Run Keywords
     ...           Stop Default Logging
     ...    AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
     ...    AND    Add Scout Scf Id To Test Data

*** Keywords ***
Verify In F1AP Messages That A4 NR-DC Measurements Are Configured and Cell Reselection Priorities Set On RRCRelease
    Verify Tcpdump Log      ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST}
    Verify Tcpdump Log      ${F1AP_DLRRC_MESSAGE_TRANSFER_RRC_RECONFIGURATION}
    Verify Tcpdump Log      ${F1AP_UE_CONTEXT_RELEASE_COMMAND}


Deregister Ue By AMF
    Execute Egate Command    cmd=ue_deregister id=1 by=amf ue_deregister_type=normal
