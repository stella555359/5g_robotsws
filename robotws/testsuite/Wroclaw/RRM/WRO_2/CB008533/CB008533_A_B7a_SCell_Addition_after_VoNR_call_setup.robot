*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
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
      ...         AND           Reach Onair    lua_cfg=${CURDIR}/config/egate_A-B7a.cfg

Test Teardown  Run Keywords    Release UE1
      ...         AND          Stop Default Processes And Gather Logs


*** Variables ***
${UE_ID}=                      1
${PCELL_ID}=                   1
${GNB_ID}=                     2
${SCELL_ADD_A1_MEAS_ID}=       3
${COUNTER_INCREMENTING_EVERY_SECOND_5_MIN_LOWER_VALUE}=    298
${COUNTER_INCREMENTING_EVERY_SECOND_5_MIN_UPPER_VALUE}=    302
${scfc}=                       full_scfc_A_B7a.xml
${rdMergedMeasGapSetupAndDrxRelease}=        0x890046=1 # rdMergedMeasGapSetupAndDrxRelease
@{SWCONFIG_FLAGS_LIST}=       ${rdMergedMeasGapSetupAndDrxRelease}

*** Test Cases ***
CB008533_A_B7a_SCell_Addition_after_VoNR_call_setup
    Attach UE And Verify Establishing PDU Session    ue_id=${UE_ID}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}
    Start GBR VoNR Traffic In Both Directions
    Trigger And Verify A1-Based SCell Addition
    Stop Capturing Messages
    Start nonGBR Data Traffic In DL And Verify Two SCells Activation
    Increase nonGBR Data Traffic In DL And Verify Third SCell Activation
    Verify That Traffic Is Scheduled On All SCells
    Wait Full PM Interval And Verify PM Counters


*** Keywords ***
Activate Delta
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=delta_A-B7a.json    retries=10    retry_timer=90

Start GBR VoNR Traffic In Both Directions
    Clear Egate Buffer From Logs
    Sleep    1s
    Verify Egate Content    expected_pattern=Setup QosFlow with QFI:2 5QI:1
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=2 trf_id=1 mbps=10 dir=dl
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=2 trf_id=2 mbps=10 dir=ul
    Wait For Traffic To Stabilize

Trigger And Verify A1-Based SCell Addition
    Expect SCell Addition messages flow    ue_id=${UE_ID}
    Send A1 Measurement For SCell Addition Purposes
    Check if SCell Addition messages flow occured    ue_id=${UE_ID}
    Verify SCell Addition

Send A1 Measurement For SCell Addition Purposes
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${SCELL_ADD_A1_MEAS_ID} event=A1 srsrp_nr=126 srsrq_nr=101
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=30

Verify SCell Addition
    Verify SCell-ToBeSetupMod-List Contents
    Verify SCellToAddModList
    Verify Resource Configuration
    Verify CSI Configuration
    Verify Measurements Configuration
    Verify PUCCH Configuration

Verify SCell-ToBeSetupMod-List Contents
    Verify That Message Fulfills Query
    ...      ${selected_SCells_for_FFTT_4CC_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${UE_ID}

Verify SCellToAddModList
    Verify That Message Fulfills Query
    ...      ${added_SCells_for_FFTT_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${UE_ID}

Verify Resource Configuration
    Verify That Message Fulfills Query
    ...      ${resources_for_FFTT_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${UE_ID}

Verify CSI Configuration
    Verify That Message Fulfills Query
    ...      ${csi_for_FFTT_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${UE_ID}

Verify Added SCells
    Verify That Message Fulfills Query
    ...      ${added_SCells_for_FFTT_4CC_CA_in_RRC_Reconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${UE_ID}

Verify Measurements Configuration
    Verify That Message Fulfills Query
    ...      ${measurements_config_for_FFTT_4CC_CA_in_RRC_Reconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${UE_ID}

Verify PUCCH Configuration
    Verify That Message Fulfills Query
    ...      ${PUCCH_config_for_FFTT_4CC_CA_in_RRC_Reconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${UE_ID}

Start nonGBR Data Traffic In DL And Verify Two SCells Activation
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=1 trf_id=3 mbps=80 dir=dl
    ...    pass_regexp=SCellIndex 3 activated successfully at airphone
    ...    timeout=60
    Clear Egate Buffer From Logs
    Verify Egate Content    expected_pattern=SCellIndex 2 activated successfully at airphone

Increase nonGBR Data Traffic In DL And Verify Third SCell Activation
    Execute Egate Command
    ...    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=1 trf_id=4 mbps=175 dir=dl
    Execute Egate Command
    ...    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=1 trf_id=5 mbps=175 dir=dl
    Execute Egate Command
    ...    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=1 trf_id=6 mbps=175 dir=dl
    Wait For Traffic To Stabilize
    Clear Egate Buffer From Logs
    Verify Egate Content    expected_pattern=SCellIndex 1 activated successfully at airphone

Wait Full PM Interval And Verify PM Counters
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Next Unpacked Full PM Counters File
    Verify If Latest PM Counter Is Lower Than The Given Value
        ...    counter_id=M55316C03003
        ...    value=${COUNTER_INCREMENTING_EVERY_SECOND_5_MIN_UPPER_VALUE}
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Is Bigger Than The Given Value
        ...    counter_id=M55316C03003
        ...    value=${COUNTER_INCREMENTING_EVERY_SECOND_5_MIN_LOWER_VALUE}
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55316C05003
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}

Release UE1
    Stop DL and UL traffic on PDU for UE    ue_id=${UE_ID}
    Release PDU session    ue_id=${UE_ID}
    Deregister UE    ue_id=${UE_ID}
