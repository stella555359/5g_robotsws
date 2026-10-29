*** Settings ***
Documentation
...     contact: Mikolaj Kasian

Library     ute_wtssim
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/cloud_bts.robot


*** Variables ***
${NR_CELL_ID}                                # ID of tested NR cell
${NAMESPACE}                                 # vDU namespace used for collecting Cplane logs
${COUNTER_PERIOD}      5                     # Counter collecting interval in minutes. Default value: 5
${NR_CELL_IDENTIFIER}                        # NR cell identifier

# X2AP: EN-DC Cell Activation Request message filter for cell 2
${ENDC_CELL_ACT_REQ_FILTER}    x2ap.ENDCCellActivationRequest_element
# X2AP: EN-DC Cell Activation Response message filter for cell 2
${ENDC_CELL_ACT_RESP_FILTER}    x2ap.ENDCCellActivationResponse_element
# F1AP: GNB-CU Configuration Update message gNB-CU->gNB-DU filter with Cells-to-be-Activated-List
${GNBCU_CONFIGURATION_UPDATE_FILTER}    f1ap.GNBCUConfigurationUpdate_element && f1ap.Cells_to_be_Activated_List
...    && f1ap.GNB_CUSystemInformation_element
# F1AP: GNB-CU Configuration Update Acknowledge message gNB-DU->gNB-CU filter
${GNBCU_CONFIGURATION_UPDATE_ACK_FILTER}     f1ap.GNBDUConfigurationUpdateAcknowledge_element
# F1AP: GNB-DU Configuration Update message gNB-DU->gNB-CU filter with Cells-status-List
${GNBDU_CONFIGURATION_UPDATE_FILTER}    f1ap.GNBDUConfigurationUpdate_element && f1ap.Cells_Status_List && f1ap.service_state == 0
# F1AP: GNB-DU Configuration Update Acknowledge message gNB-CU->gNB-DU filter
${GNBDU_CONFIGURATION_UPDATE_ACK_FILTER}=    f1ap.GNBDUConfigurationUpdateAcknowledge_element


*** Keywords ***
TC__CB007065_A_CB010442_B1_One_X2_link_MeNB_requests_to_switch_on_one_NSA_NR_cell_and_feature_CB010442_is_activated

    Set Tags    CA-RRM    AUTHOR-mikolaj.kasian@nokia.com    MAINTAINER-mikolaj.kasian@nokia.com
    ...         PHASE-CRT    SW-SBTS25R2    GROUP_IN_CHARGE-VRF_2_WRO_2

    Preconditions
    Step 1: Send Cell Activation Request From Simulated Enb
    Step 2: Wait For notEnergySaving State For NR Cell
    Step 3: Check Messages Flow
    Step 4: Check Counters Final Values

Preconditions
    Log    \n==== Preconditions ====    console=True
    Create Global Variables
    Wait Until Keyword Succeeds    7min    30sec
    ...    Check Energy Saving State For NR Cell On VDU    ${VDU_MRBTS_ID}   ${NRBTS_ID}    ${NR_CELL_ID}    energySaving
    Check Counters Initial Values

Create Global Variables

    Get Start Time

    Get MRBTS ID From VCU
    Get MRBTS ID From VDU
    Get NRBTS ID From VDU

    ${nr_cell_identity} =  Get NR Cell Identity From VDU  ${NR_CELL_ID}
    Set Test Variable  ${NR_CALL_CELL_ID}  ${nr_cell_identity}

Check Counters Initial Values
    Wait For New Counter Period
    Wait For New Counter Period    additional_waiting_time=65

    ${ENDC_CELL_ACT_REQ_X2}    ${ENDC_CELL_ACT_ACC_X2}    ${ENDC_CELL_ACT_REJ_X2}    Get Counters
    Set Test Variable    ${ENDC_CELL_ACT_REQ_X2__INIT}    ${ENDC_CELL_ACT_REQ_X2}
    Set Test Variable    ${ENDC_CELL_ACT_ACC_X2__INIT}    ${ENDC_CELL_ACT_ACC_X2}
    Set Test Variable    ${ENDC_CELL_ACT_REJ_X2__INIT}    ${ENDC_CELL_ACT_REJ_X2}

    [Teardown]    Collect Counter Files    1

Step 1: Send Cell Activation Request From Simulated Enb
    Log    \n==== Step 1: Send Cell Activation Request From Simulated Enb ====    console=True
    Execute Egate Command    cmd=endc_cell_act_req id=1 target_gnb_id=2 nrci=311:489|2

Step 2: Wait For notEnergySaving State For NR Cell
    Log    \n==== Step 2: Wait For notEnergySaving State For NR Cell ====    console=True
    Wait Until Keyword Succeeds    5min    30sec
    ...    Check Energy Saving State For NR Cell On VDU    ${VDU_MRBTS_ID}    ${NRBTS_ID}    ${NR_CELL_ID}    notEnergySaving

Step 3: Check Messages Flow
    Log    \n==== Step 3: Check Messages Flow ====    console=True
    ${x2ap_nRcellIdentifier_filter}    Set Variable    x2ap.nRcellIdentifier == ${NR_CELL_IDENTIFIER}
    ${f1ap_nRCellIdentity_filter}    Set Variable    f1ap.nRCellIdentity == ${NR_CELL_IDENTIFIER}
    ${tcpdump_path}=    Stop Wireshark Log Collection
    Run Keyword And Continue On Failure
    ...    Check If Message Appeared  ${ENDC_CELL_ACT_REQ_FILTER} && ${x2ap_nRcellIdentifier_filter}  1  ${tcpdump_path}
    Run Keyword And Continue On Failure
    ...    Check If Message Appeared  ${ENDC_CELL_ACT_RESP_FILTER} && ${x2ap_nRcellIdentifier_filter}  1  ${tcpdump_path}
    Run Keyword And Continue On Failure
    ...    Check If Message Appeared  ${GNBCU_CONFIGURATION_UPDATE_FILTER} && ${f1ap_nRCellIdentity_filter}   1  ${tcpdump_path}
    Run Keyword And Continue On Failure
    ...    Check If Message Appeared  ${GNBCU_CONFIGURATION_UPDATE_ACK_FILTER}  1  ${tcpdump_path}
    Run Keyword And Continue On Failure
    ...    Check If Message Appeared  ${GNBDU_CONFIGURATION_UPDATE_FILTER} && ${f1ap_nRCellIdentity_filter}  1  ${tcpdump_path}
    Run Keyword And Continue On Failure
    ...    Check If Message Appeared  ${GNBDU_CONFIGURATION_UPDATE_ACK_FILTER}  1  ${tcpdump_path}

Step 4: Check Counters Final Values
    Log    \n==== Step 4: Check Counters Final Values ====    console=True
    Wait For New Counter Period    additional_waiting_time=65

    ${ENDC_CELL_ACT_REQ_X2}    ${ENDC_CELL_ACT_ACC_X2}    ${ENDC_CELL_ACT_REJ_X2}    Get Counters
    ${ENDC_CELL_ACT_REQ_X2__EXPECT}=    Evaluate    ${ENDC_CELL_ACT_REQ_X2__INIT} + 1
    ${ENDC_CELL_ACT_ACC_X2__EXPECT}=    Evaluate    ${ENDC_CELL_ACT_ACC_X2__INIT} + 1
    Run Keyword And Continue On Failure    Should Be True    ${ENDC_CELL_ACT_REQ_X2} == ${ENDC_CELL_ACT_REQ_X2__EXPECT}
    Run Keyword And Continue On Failure    Should Be True    ${ENDC_CELL_ACT_ACC_X2} == ${ENDC_CELL_ACT_ACC_X2__EXPECT}
    Run Keyword And Continue On Failure    Should Be True    ${ENDC_CELL_ACT_REJ_X2} == ${ENDC_CELL_ACT_REJ_X2__INIT}

    [Teardown]    Collect Counter Files    2

Get Counters
    Connect To VCU
    ${ENDC_CELL_ACT_REQ_X2} =    Get Counter List For VCU    counter_id=M55112C00020
    ...    dimension_dn=MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ...    counter_amount=1    start_time=${START_TIME}
    Log    From vCU M55112C00020 ENDC_CELL_ACT_REQ_X2 = ${ENDC_CELL_ACT_REQ_X2[0]}    console=True

    ${ENDC_CELL_ACT_ACC_X2} =    Get Counter List For VCU    counter_id=M55112C00021
    ...    dimension_dn=MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    ...    counter_amount=1    start_time=${START_TIME}
    Log    From vCU M55112C00021 ENDC_CELL_ACT_ACC_X2 = ${ENDC_CELL_ACT_ACC_X2[0]}    console=True

    ${ENDC_CELL_ACT_REJ_X2} =    Get Counter List For VCU    counter_id=M55110C00037
    ...    dimension_dn=MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    counter_amount=1    start_time=${START_TIME}
    Log    From vCU M55110C00037 ENDC_CELL_ACT_REJ_X2 = ${ENDC_CELL_ACT_REJ_X2[0]}    console=True

    [Teardown]    vcu.Disconnect
    [Return]    ${ENDC_CELL_ACT_REQ_X2[0]}    ${ENDC_CELL_ACT_ACC_X2[0]}    ${ENDC_CELL_ACT_REJ_X2[0]}

Collect Counter Files
    [Arguments]    ${index}
    ${for_last} =    Evaluate    ${COUNTER_PERIOD} * 3
    Log    Collecting counter files form vCU...    console=True

    Collect PM Counters    xml_files_left=2    host=${VCU_OAM_CONNECTION.addr}    user=${VCU_OAM_CONNECTION.username}
    ...    password=${VCU_OAM_CONNECTION.password}    time_interval=${for_last} min
    ...    intervals=${COUNTER_PERIOD}    bts_type=vcu
    ...    target_dir_path=${LOG_PATH}/pm_counters/vcu_step${index}

TC Setup
    Cloud BTS Test Setup    ignored_alarms_vcu=${IGNORED_ALARMS_VCU}    ignored_alarms_vdu=${IGNORED_ALARMS_VDU}
    Save SCF VCU    vCU_SCF_original.xml
    Save SCF VDU    vDU_SCF_original.xml
    Set Test Variable    ${WIRESHARK_STARTED}    True
    Start Wireshark Log Collection For VCU    namespace=${NAMESPACE}

TC Teardown
    [Timeout]    60 min
    Log    \n === TC Teardown ===     console=True
    Cloud BTS Test Teardown
