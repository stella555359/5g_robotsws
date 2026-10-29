*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/logging.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     CB008533_filters_and_keywords.robot
Library      ta5g_pm_counters
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta_messaging
Library      ../resources/messaging.py
Variables    CB008533_messaging_filters.py
Library      ta5g_iphy
Library      taf.ul.ettf.setups

Suite Setup     Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008533_B7_B11.xml
      ...         AND           With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
      ...         AND           With Gnb Configuration    commissioning=${scfc}
      ...         AND           Wait For Testline Icmp Echo Replies And Ssh Services
      ...         AND           Start Default Logging    output_dirpath=${OUTPUT_DIR}
      ...         AND           Reach Onair    lua_cfg=${CURDIR}/config/egate_A-B11a.cfg
      ...         AND           Wait For Next Full Pm Interval

Test Teardown  Run Keywords    Stop Default Logging
      ...         AND          Release All Ues
      ...         AND          Stop Default Processes And Gather Logs


*** Variables ***
${UE_ID}=                      1
${PCELL_ID}=                   1
${GNB_ID}=                     2
${SCELL_ADD_A1_MEAS_ID}=       3
${SCELL_REL_A2_MEAS_ID}=       6
${SCELL_CHA_A1_MEAS_ID}=       12
${scfc}=         full_scfc_A_B11a.xml
${rdMergedMeasGapSetupAndDrxRelease}=        0x890046=1 # rdMergedMeasGapSetupAndDrxRelease
@{SWCONFIG_FLAGS_LIST}=       ${rdMergedMeasGapSetupAndDrxRelease}

*** Test Cases ***
CB008533_A_B11a_SCell_Release_leading_to_SCell_Change
    Add Scout Data Info To Testcase
    Attach UE And Verify Establishing PDU Session    ue_id=${UE_ID}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}
    Trigger And Verify A1-Based SCell Addition
    Increase Load On TDD Cells
    Trigger And Verify A2-Based Scell Release
    Trigger And Verify A1-Based Scell Change
    Verify PM Counters


*** Keywords ***
Trigger And Verify A1-Based SCell Addition
    Expect SCell Addition messages flow    ue_id=${UE_ID}
    Send A1 Measurement For SCell Addition Purposes
    Check if SCell Addition messages flow occured    ue_id=${UE_ID}

Send A1 Measurement For SCell Addition Purposes
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${SCELL_ADD_A1_MEAS_ID} event=A1 srsrp_nr=110
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=30

Increase Load On TDD Cells
    Attach UE And Establish PDU Session    ue_id=2    cell_id=3    enb_id=${GNB_ID}    pdu_id=2    gw_id=2
    Attach UE And Establish PDU Session    ue_id=3    cell_id=3    enb_id=${GNB_ID}    pdu_id=3    gw_id=3
    Attach UE And Establish PDU Session    ue_id=4    cell_id=6    enb_id=${GNB_ID}    pdu_id=4    gw_id=4
    Attach UE And Establish PDU Session    ue_id=5    cell_id=6    enb_id=${GNB_ID}    pdu_id=5    gw_id=5

Trigger And Verify A2-Based Scell Release
    Expect SCell Release messages flow    ${UE_ID}
    Send A2 Measurement For SCell Release Purposes
    Check if SCell Release messages flow occured    ${UE_ID}
    Verify Scell Release


Send A2 Measurement For SCell Release Purposes
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${SCELL_REL_A2_MEAS_ID} event=A2 scell=1 scell_rsrq=30
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=30

Verify Scell Release
    Verify SCell-ToBeRemoved-List
    Verify PUCCH Configuration During FDD SCell Release
    Verify RRC Reconfiguration Contents During FDD SCell Release

Verify SCell-ToBeRemoved-List
    Verify That Message Fulfills Query
    ...      ${selected_SCell_for_FDD_SCell_Release_in_FFTT_4CC_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellRelease_UE${UE_ID}

Verify PUCCH Configuration During FDD SCell Release
    Verify That Message Fulfills Query
    ...      ${pucch_for_FDD_SCell_Release_in_FFTT_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellRelease_UE${UE_ID}

Verify RRC Reconfiguration Contents During FDD SCell Release
    Verify That Message Fulfills Query
    ...      ${measurements_config_for_FDD_SCell_Release_in_FFTT_4CC_CA_in_RRC_Reconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellRelease_UE${UE_ID}

Trigger And Verify A1-Based Scell Change
    Expect SCell Change messages flow    ${UE_ID}
    Send A1 Measurement For SCell Change Purposes
    Check if SCell Change messages flow occured    ${UE_ID}
    Verify Scell Change

Send A1 Measurement For SCell Change Purposes
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${SCELL_CHA_A1_MEAS_ID} event=A1 srsrp_nr=110
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=30

Verify Scell Change
    Verify SCell-ToBeSetupMod-List And SCell-ToBeRemoved-List
    Verify PUCCH Configuration During SCell Change
    Verify SCellToAddModList and SCellToReleaseList
    Verify Measurement Deconfiguration and Configuration
    Verify Selected Band Combination

Verify SCell-ToBeSetupMod-List And SCell-ToBeRemoved-List
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_SCell_Change_from_FTT_to_FFF_in_UE_Context_Modification_Request}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellChange_UE${UE_ID}

Verify PUCCH Configuration During SCell Change
    Verify That Message Fulfills Query
    ...  ${pucch_configuration_for_SCell_Change_from_FTT_to_FFF_3CC_CA_in_UE_Context_Modification_Response}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellChange_UE${UE_ID}

Verify SCellToAddModList and SCellToReleaseList
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_SCell_Change_from_FTT_to_FFF_in_RRC_Reconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellChange_UE${UE_ID}

Verify Measurement Deconfiguration and Configuration
    Verify That Message Fulfills Query
    ...  ${measurement_deconfiguration_A1_A2_and_configuration_A2_SCell_Change_from_FTT_to_FFF_in_RRC_Reconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellChange_UE${UE_ID}

Verify Selected Band Combination
    Verify That Message Fulfills Query
    ...  ${Postcondition_SCell_Change_from_FTT_to_FFF_in_RRC_Reconfiguration}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellChange_UE${UE_ID}

Verify PM Counters
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55118C06501
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55118C06502
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}

Release All Ues
    Release PDU session    ue_id=${UE_ID}
    Deregister UE    ue_id=${UE_ID}
    Release PDU session    ue_id=2    pdu_id=2
    Deregister UE    ue_id=2
    Release PDU session    ue_id=3    pdu_id=3
    Deregister UE    ue_id=3
    Release PDU session    ue_id=4    pdu_id=4
    Deregister UE    ue_id=4
    Release PDU session    ue_id=5    pdu_id=5
    Deregister UE    ue_id=5
