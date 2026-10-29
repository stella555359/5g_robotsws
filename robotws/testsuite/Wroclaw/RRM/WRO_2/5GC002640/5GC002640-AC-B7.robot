*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/traffic.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot

Library      ta5g_ue_measurements
Library      ta5g_testline_management
Library      ta5g_enb
Library      ta5g_throughput
Library      taf.ul.ettf.setups
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_iphy

Suite Setup       Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_H_B2a.xml
...               AND             With Gnb Configuration    commissioning=${scfc}
...               AND             Perform Common Parameters Commisssioning
Test Teardown     Run Keywords    Deregister UE   ue_id=${UE_ID}
...               AND             Stop Default Logging
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${UE_ID}=                      1
${PCELL_ID}=                   1
${GNB_ID}=                     2
${SCELL_ADD_A1_MEAS_ID}=       3
${rdMergedMeasGapSetupAndDrxRelease}=        0x890046=1 # rdMergedMeasGapSetupAndDrxRelease
${rdSupportSimultaneousHarqAckCsi}=  0x59003e=1
@{FLAGS_LIST}=  ${rdSupportSimultaneousHarqAckCsi}    ${rdMergedMeasGapSetupAndDrxRelease}
${scfc}=                       scfc_H_B2a.xml
${RRC_RECONF_DRX_PROFILE_1}=     nr-rrc.c1 == 0 && nr-rrc.drx_InactivityTimer == 14 && nr-rrc.drx_LongCycleStartOffset == 3
                           ...   && nr-rrc.drx_onDurationTimer == 1 && nr-rrc.milliSeconds == 7
                           ...   && nr-rrc.drx_RetransmissionTimerDL == 6 && nr-rrc.drx_RetransmissionTimerUL == 6

${RRC_RECONF_DRX_PROFILE_2_B7a}=     nr-rrc.c1 == 0 && nr-rrc.drx_InactivityTimer == 11 && nr-rrc.drx_LongCycleStartOffset == 1
                           ...   && nr-rrc.drx_onDurationTimer == 1 && nr-rrc.milliSeconds == 5
                           ...   && nr-rrc.drx_RetransmissionTimerDL == 0 && nr-rrc.drx_RetransmissionTimerUL == 0

${RRC_RECONF_DRX_PROFILE_2_B7b}=    nr-rrc.c1 == 0 && nr-rrc.drx_InactivityTimer == 8 && nr-rrc.drx_LongCycleStartOffset == 3
                           ...   && nr-rrc.drx_onDurationTimer == 1 && nr-rrc.milliSeconds == 5
                           ...   && nr-rrc.drx_RetransmissionTimerDL == 0 && nr-rrc.drx_RetransmissionTimerUL == 0

${RRC_RECONF_SCELL_ADDITION_FFT}=    nr-rrc.c1 == 0 && nr-rrc.sCellToAddModList == 2 && !(nr-rrc.drx_Config == 1) &&
                               ...   nr-rrc.physCellId == 51 && nr-rrc.physCellId == 55 && nr-rrc.measIdToAddModList == 2 &&
                               ...   nr-rrc.measId == 4 && nr-rrc.measObjectId == 2 && nr-rrc.reportConfigId == 4 &&
                               ...   nr-rrc.measId == 5 && nr-rrc.measObjectId == 3

${RRC_RECONF_SCELL_ADDITION_FTT}=    nr-rrc.c1 == 0 && nr-rrc.sCellToAddModList == 2 && !(nr-rrc.drx_Config == 1) &&
                               ...   nr-rrc.physCellId == 52 && nr-rrc.physCellId == 55 && nr-rrc.measIdToAddModList == 2 &&
                               ...   nr-rrc.measId == 4 && nr-rrc.measObjectId == 2 && nr-rrc.reportConfigId == 4 &&
                               ...   nr-rrc.measId == 5 && nr-rrc.measObjectId == 3

${RRC_RECONF_TDD_SCELL_RELEASE}=    nr-rrc.c1 == 0 && nr-rrc.sCellToReleaseList == 1 && nr-rrc.SCellIndex == 2 &&
                              ...   nr-rrc.measIdToRemoveList == 1 && nr-rrc.MeasId == 5  && !(nr-rrc.drx_Config == 1) &&
                              ...   nr-rrc.reportConfigToAddModList == 1 && nr-rrc.eventId == 0 && nr-rrc.measTriggerQuantity.rsrp == 80 &&
                              ...   nr-rrc.measIdToAddModList == 1 && nr-rrc.measId == 7

${RRC_RECONF_FDD_SCELL_RELEASE}=    nr-rrc.c1 == 0 && nr-rrc.sCellToReleaseList == 1 && nr-rrc.SCellIndex == 1 &&
                              ...   !(nr-rrc.drx_Config == 1) && nr-rrc.reportConfigToRemoveList == 2 &&
                              ...   nr-rrc.ReportConfigId == 4 && nr-rrc.ReportConfigId == 6 && nr-rrc.measTriggerQuantity.rsrp == 70 &&
                              ...   nr-rrc.reportConfigToAddModList == 1 && nr-rrc.eventId == 0 &&
                              ...   nr-rrc.MeasId == 4 && nr-rrc.MeasId == 7 && nr-rrc.measIdToAddModList == 1


*** Test Cases ***
5GC002640_AC_B7a_DRX_Configuration_with_3CC_with_Measurement_based_SCell_addition_VoNR_before_SCell_addition_but_after_data_call
    [Setup]    Run Keywords    Trigger Site Reset
      ...         AND          Wait For Testline Icmp Echo Replies And Ssh Services
      ...         AND          Start Default Logging    output_dirpath=${OUTPUT_DIR}
      ...         AND          Reach Onair    lua_cfg=${CURDIR}/config/config_AC_B7a.cfg

    Add Scout Data Info To Testcase

    Attach UE And Establish PDU Session    ue_id=${UE_ID}    cell_id=${PCELL_ID}    enb_id=${GNB_ID}
    Start Data Traffic In Both Directions
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_DRX_PROFILE_1}

    Add Second QoS Flow To PDU Session    ue_id=${UE_ID}
    Start GBR VoNR Traffic
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_DRX_PROFILE_2_B7a}

    Send A1 Measurement For SCell Addition Purposes
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_SCELL_ADDITION_FFT}

    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=5 event=A2 scell=2 srsrp_nr=5
    ...    pass_regexp=rrcReconfigurationComplete
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_TDD_SCELL_RELEASE}

    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=4 event=A2 scell=1 srsrp_nr=5
    ...    pass_regexp=rrcReconfigurationComplete
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_FDD_SCELL_RELEASE}


5GC002640-AC-B7b_DRX_Configuration_with_3CC_with_Measurement_based_SCell_addition_VoNR_and_data_call_before_SCell_addition
    [Setup]    Run Keywords    Trigger Site Reset
      ...         AND          Wait For Testline Icmp Echo Replies And Ssh Services
      ...         AND          Start Default Logging    output_dirpath=${OUTPUT_DIR}
      ...         AND          Sleep    300s
      ...         AND          Enable DRX Profile 2
      ...         AND          Reach Onair    lua_cfg=${CURDIR}/config/config_AC_B7b.cfg

    Add Scout Data Info To Testcase

    Attach UE And Establish PDU Session    ue_id=${UE_ID}    cell_id=${PCELL_ID}    enb_id=${GNB_ID}
    Start GBR VoNR Traffic
    Start Data Traffic In Both Directions
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_DRX_PROFILE_2_B7b}

    Send A1 Measurement For SCell Addition Purposes
    Verify Tcpdump Log    packet_filter=${RRC_RECONF_SCELL_ADDITION_FTT}


*** Keywords ***
Perform Common Parameters Commisssioning
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=delta_VoNR_DRX.json    retries=10    retry_timer=90
    With Swconfig Flags                       flags=@{FLAGS_LIST}

Enable DRX Profile 2
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=delta_AC-B7b_specific.json    retries=10    retry_timer=90

Add Second QoS Flow To PDU Session
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ...                                        pass_regexp=AMF-1: Added QosFlow with QFI:2 5QI:1

Start Data Traffic In Both Directions
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=1 trf_id=1 mbps=150 dir=dl
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=1 trf_id=1 mbps=20 dir=ul
    Wait For Traffic To Stabilize

Start GBR VoNR Traffic
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=2 trf_id=1 mbps=10 dir=dl
    Wait For Traffic To Stabilize

Send A1 Measurement For SCell Addition Purposes
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${SCELL_ADD_A1_MEAS_ID} event=A1 srsrp_nr=90
    ...    pass_regexp=rrcReconfigurationComplete
