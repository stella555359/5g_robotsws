*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Maciej Grzeszczak
...             :contact: maciej.grzeszczak@nokia.com

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../5GC001167/feature_keywords.robot
Resource    ../keywords/L3_Call.robot
Variables   ../5GC001167/feature_variables.py
Library     taf.ul.ettf.logging
Library     ta5g_throughput
Variables    ../resources/custom_policy.py
Library     ta5g_pm_counters
Library     ta5g_testline_management
Resource    ../5GC001167/feature_keywords.robot
Resource    CB007949_keywords.robot
Variables    ../resources/custom_policy.py

Test Setup    Custom Prepare Test Environement And Reach Onair
      ...     iphy_xml=${CURDIR}/config/iphy_3FDD_3TDD_bw_100_50_60.xml
      ...     scfc=7949_B_B2_full_commisioning.xml
      ...     egate_cfg=${CURDIR}/config/egate_custom_config.cfg
      ...     flags=@{swconfig_flags_list}

*** Variables ***
${LOGGING_POLICY}=                          FULL_POLICY
${PM_COUNTERS_INTERVAL}=     0x340000=5        #flag to speed up PM counters to 3 minutes
@{SWCONFIG_FLAGS_LIST}=      ${PM_COUNTERS_INTERVAL}
${F1AP_RESOURCE_SET_TO_ADD_MOD_LIST}=       (nr-rrc.pucch_ResourceSetId == 1) && (nr-rrc.PUCCH_ResourceId == 17) &&
                                       ...  (nr-rrc.maxPayloadSize == 16) && !(nr-rrc.rrc_TransactionIdentifier) &&
                                       ...  (nr-rrc.resourceSetToAddModList == 2)
${F1AP_A1_MEASUREMENT_FOR_SCELL_ADDITION}=  (nr-rrc.a1_Threshold == 0) && (nr-rrc.freqBandIndicatorNR == 41) &&
                                       ...  (nr-rrc.reportConfigId == 7) && (nr-rrc.measId == 7) &&
                                       ...  (nr-rrc.measObjectId == 2)
${F1AP_A2_FOR_SCELL_1_RELEASE}=             (nr-rrc.reportConfigId == 9) && (nr-rrc.measObjectId == 3) &&
                                       ...  (nr-rrc.freqBandIndicatorNR == 77) && (nr-rrc.a2_Threshold == 0)
${F1AP_A2_FOR_SCELL_2_RELEASE}=             (nr-rrc.reportConfigId == 9) && (nr-rrc.measObjectId == 4) &&
                                       ...  (nr-rrc.freqBandIndicatorNR == 41) && (nr-rrc.a2_Threshold == 0)
${SCELL_TO_BE_RELEASED}=                    (nr-rrc.sCellToReleaseList == 1)

*** Test Cases ***
CB007949_B_B2a_A1_Threshold_Criteria_Based_SCell_Addition_During_A3_A5_Triggered_intra_gNB_Handover_with_SCell_Release_procedure
    Change Ue Location
    Register UE With PDU Session Setup    ue_id=1    pdu_id=1    gw_id=1
    Perform Intra gNB Handover    ue_id=1    a2_meas_id=1    a3_meas_id=6    phycell_id=52   a3_rsrp=100
    Verify A1 Measurement
    Verify Successful 3CC TTT SCell Addition
    Verify PUCCH Resource
    Verify A2 Measurement For SCell Release
    Send A2 Measurement For Scell Release    ue_id=1    a2_meas_id=9     srsrp_nr=1    scell=1
    Verify PUCCH Resource After First SCell Release
    Send A2 Measurement For Scell Release    ue_id=1    a2_meas_id=10     srsrp_nr=1    scell=2
    Verify PUCCH Resource After Second SCell Release
    Verify Successful SCells Release
    [Teardown]    Run Keywords      Release Pdu Session    ue_id=1    pdu_id=1
        ...            AND          Deregister Ue    ue_id=1

*** Keywords ***
Change Ue Location
    [Arguments]    ${ue_id}=1    ${enb}=2    ${cell_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb} cell=${cell_id}
    ...  cmd=ue_change_location id\=${ue_id} enb\=${enb} cell\=${cell_id}

Perform Intra gNB Handover
    [Arguments]    ${ue_id}=1    ${a2_meas_id}=1    ${a3_meas_id}=6    ${phycell_id}=52    ${a3_rsrp}=100
    Send A2 Measurement To Reconfigure A3    ue_id=${ue_id}    a2_meas_id=${a2_meas_id}
    Send A3 Measurement To Perform UE Handover    ue_id=${ue_id}    phycell_id=${phycell_id}    a3_meas_id=${a3_meas_id}    a3_rsrp=${a3_rsrp}

Send A3 Measurement To Perform UE Handover
    [Arguments]    ${ue_id}     ${phycell_id}    ${a3_meas_id}    ${a3_rsrp}=100
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a3_meas_id} phycell_id\=${phycell_id} nrsrp_nr\=${a3_rsrp} event\=A3
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-*.* to EXT_ENB-*.* performed

Verify PUCCH Resource
    Verify Tcpdump Log      packet_filter=${F1AP_RESOURCE_SET_TO_ADD_MOD_LIST}       number_of_messages=1

Start Data Traffic And Verify DL Traffic Scheduling On All SCell
    [Arguments]    ${ue_id}=1    ${qfi}=1   ${scell}=0-3
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} mbps=175 dir=dl
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} mbps=100 dir=ul
    Wait For Traffic To Stabilize
    Execute Egate Command    cmd=ue_stats_nr id=${ue_id} scell=${scell}

Verify A1 Measurement
    [Arguments]    ${number_of_messages}=3
    Verify Tcpdump Log      packet_filter=${F1AP_A1_MEASUREMENT_FOR_SCELL_ADDITION}   number_of_messages=${number_of_messages}

Verify A2 Measurement For SCell Release
    [Arguments]    ${number_of_messages}=1
    Verify Tcpdump Log      packet_filter=${F1AP_A2_FOR_SCELL_1_RELEASE}   number_of_messages=${number_of_messages}
    Verify Tcpdump Log      packet_filter=${F1AP_A2_FOR_SCELL_2_RELEASE}   number_of_messages=${number_of_messages}

Wait for PM Counters To Update
    Sleep    180s

Verify Configuration Of A2 Measurement
    [Arguments]    ${filter}
    Verify Tcpdump Log      packet_filter=${filter}

Send A2 Measurement With Capture
    [Arguments]     ${ue_id}    ${a2_meas_id}    ${scell_id}
    Run Keyword And Return    With Message Capture    eth4   Send A2 Measurement    ue_id=${ue_id}
    ...  a2_meas_id=${a2_meas_id}    scell=${scell_id}

Verify Successful SCells Release
    [Arguments]    ${number_of_messages}=4
    Verify Tcpdump Log      packet_filter=${SCELL_TO_BE_RELEASED}   number_of_messages=${number_of_messages}

Send A2 Measurement For Scell Release
    [Arguments]    ${ue_id}    ${a2_meas_id}    ${srsrp_nr}    ${scell}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a2_meas_id} event\=A2 srsrp_nr\=${srsrp_nr} scell\=${scell}
    ...    pass_regexp=message c1 : rrcReconfigurationComplete
