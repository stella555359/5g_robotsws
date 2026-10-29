*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LPQ_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC

Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: damian.rzeczkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/ta_messaging_robot_keywords.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/tshark_verifying.robot
Resource     Keywords_CB011081.robot
Resource     CB011081_BB1_variables.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      ta5g_ue_measurements
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Variables    ta5g_global_var
Variables    CB011081_messaging_filters.py
Variables    logging_policy.py


Suite Setup    Run Keywords    Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_lpq_BB1.xml
...            AND             With Gnb Configuration    commissioning=${SCFC}
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Create gNB Alias
...            AND             Wait For Next Full Pm Interval

Test Teardown    Run Keywords    Release Multiple UEs    ue_ids=@{UE_IDs}    pdu_ids=@{PDU_IDs}
...           AND                Add Scout Data Info To Testcase

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs


*** Test Cases ***
CB011081-BB1_Multiple_UEs_Call_Setup_for_FDD_+_TDD_FR1_DL_6CCs_CA_and_UL_2CCs_CA
    Set 10 expected UE Context Modification messages for gNB2
    Expect SCell Addition Messages Flow For Several UEs in UE set-1
    Attach Several UEs in UE set-1 And Verify Establishing PDU Sessions
    Verify UE1 6CC 3F3T Blind SCell Addition Message Contents
    Verify UE2 6CC 3F3T Blind SCell Addition Message Contents
    Verify 10 UE Context Modification messages for gNB2 occured

    Set 10 expected UE Context Modification messages for gNB2
    Expect SCell Addition Messages Flow For Several UEs in UE set-2
    Attach Several UEs in UE set-2 And Verify Establishing PDU Sessions
    Verify UE3 6CC 4F2T Blind SCell Addition Message Contents
    Verify UE4 6CC 4F2T Blind SCell Addition Message Contents
    Verify 10 UE Context Modification messages for gNB2 occured

    Set 10 expected UE Context Modification messages for gNB2
    Expect SCell Addition Messages Flow For Several UEs in UE set-3
    Attach Several UEs in UE set-3 And Verify Establishing PDU Sessions
    Verify UE5 4CC 4F Blind SCell Addition Message Contents
    Verify UE6 4CC 4F Blind SCell Addition Message Contents
    Verify 10 UE Context Modification messages for gNB2 occured

    Traffic Start DL and UL non-GBR Data on Several UEs
    Traffic Stop DL and UL non-GBR Data on Several UEs    ue_ids=${UE_IDs}    pdu_ids=${PDU_IDs}

    Verify Pm Counters BB1


*** Keywords ***
Attach Several UEs in UE set-1 And Verify Establishing PDU Sessions
    Attach Several UEs And Verify Establishing PDU Sessions    ue_ids=${UE_IDs_Set1}    pdu_ids=${PDU_IDs_Set1}
    ...    gw_ids=${GW_IDs_Set1}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}

Attach Several UEs in UE set-2 And Verify Establishing PDU Sessions
    Attach Several UEs And Verify Establishing PDU Sessions    ue_ids=${UE_IDs_Set2}    pdu_ids=${PDU_IDs_Set2}
    ...    gw_ids=${GW_IDs_Set2}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}

Attach Several UEs in UE set-3 And Verify Establishing PDU Sessions
    Attach Several UEs And Verify Establishing PDU Sessions    ue_ids=${UE_IDs_Set3}    pdu_ids=${PDU_IDs_Set3}
    ...    gw_ids=${GW_IDs_Set3}    cell_id=${PCELL_ID}    gnb_id=${GNB_ID}

Attach Several UEs And Verify Establishing PDU Sessions
    [Arguments]    ${ue_ids}    ${pdu_ids}    ${gw_ids}    ${cell_id}    ${gnb_id}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Expect PDU Messages Flow     ue_id=${ue_ids}[${ue_index}]    gNB_id=${gnb_id}
        Attach UE And Establish PDU Session    ue_id=${ue_ids}[${ue_index}]    cell_id=${cell_id}    enb_id=${gnb_id}
        ...                                    pdu_id=${pdu_ids}[${ue_index}]    gw_id=${gw_ids}[${ue_index}]
        Check If PDU Messages Flow Occurred     ue_id=${ue_ids}[${ue_index}]
    END

Expect SCell Addition Messages Flow For Several UEs
    [Arguments]    ${ue_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Create UE Alias    alias=UE${ue_ids}[${ue_index}]    ue_id=${ue_ids}[${ue_index}]
        ...    id_type=wts_5g
        Expect SCell Addition Messages Flow    ue_id=${ue_ids}[${ue_index}]
    END

Expect SCell Addition Messages Flow For Several UEs in UE set-1
    Expect SCell Addition Messages Flow For Several UEs    ue_ids=${UE_IDs_Set1}

Expect SCell Addition Messages Flow For Several UEs in UE set-2
    Expect SCell Addition Messages Flow For Several UEs    ue_ids=${UE_IDs_Set2}

Expect SCell Addition Messages Flow For Several UEs in UE set-3
    Expect SCell Addition Messages Flow For Several UEs    ue_ids=${UE_IDs_Set3}

Traffic Start DL and UL non-GBR Data on Several UEs
    Start Specific Data DL Traffic    ue_id=${UE1_ID}   pdu_id=${PDU_ID_UE1}    mbps_per_trf_id=150    last_trf_id=4
    Execute Egate Command    cmd=trf_data_start ue=${UE1_ID} pdu=${PDU_ID_UE1} qfi=1 trf_id=5 dir=ul mbps=100
    Start Specific Data DL Traffic    ue_id=${UE2_ID}   pdu_id=${PDU_ID_UE2}    mbps_per_trf_id=150    first_trf_id=6    last_trf_id=10
    Execute Egate Command    cmd=trf_data_start ue=${UE2_ID} pdu=${PDU_ID_UE2} qfi=1 trf_id=11 dir=ul mbps=100
    Start Specific Data DL Traffic    ue_id=${UE3_ID}   pdu_id=${PDU_ID_UE3}    mbps_per_trf_id=150    first_trf_id=12    last_trf_id=16
    Execute Egate Command    cmd=trf_data_start ue=${UE3_ID} pdu=${PDU_ID_UE3} qfi=1 trf_id=17 dir=ul mbps=100
    Start Specific Data DL Traffic    ue_id=${UE4_ID}   pdu_id=${PDU_ID_UE4}    mbps_per_trf_id=150    first_trf_id=18    last_trf_id=22
    Execute Egate Command    cmd=trf_data_start ue=${UE4_ID} pdu=${PDU_ID_UE4} qfi=1 trf_id=23 dir=ul mbps=100
    Start Specific Data DL Traffic    ue_id=${UE5_ID}   pdu_id=${PDU_ID_UE5}    mbps_per_trf_id=75    first_trf_id=24    last_trf_id=27
    Start Specific Data DL Traffic    ue_id=${UE6_ID}   pdu_id=${PDU_ID_UE6}    mbps_per_trf_id=75    first_trf_id=28    last_trf_id=31

Verify DL and UL Traffic Is Scheduled On PCell and SCells on Several UEs
    Wait for Traffic to Stabilize    inactive_timer=10
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE1_ID}    cells_list=${6CC_SCELLS_INDEXES_DL}
    ...    expected_throughput=15    direction=dl    margin=95%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE1_ID}    cells_list=${2CC_SCELLS_INDEXES_UL_CELL6_OR_CELL7}
    ...    expected_throughput=15    direction=ul    margin=95%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE2_ID}    cells_list=${6CC_SCELLS_INDEXES_DL}
    ...    expected_throughput=15    direction=dl    margin=95%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE2_ID}    cells_list=${2CC_SCELLS_INDEXES_UL_CELL6}
    ...    expected_throughput=15    direction=ul    margin=95%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE3_ID}    cells_list=${6CC_SCELLS_INDEXES_DL}
    ...    expected_throughput=15    direction=dl    margin=95%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE3_ID}    cells_list=${2CC_SCELLS_INDEXES_UL_CELL6_OR_CELL7}
    ...    expected_throughput=15    direction=ul    margin=95%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE4_ID}    cells_list=${6CC_SCELLS_INDEXES_DL}
    ...    expected_throughput=15    direction=dl    margin=95%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE4_ID}    cells_list=${2CC_SCELLS_INDEXES_UL_CELL6_OR_CELL7}
    ...    expected_throughput=15    direction=ul    margin=95%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE5_ID}    cells_list=${4CC_SCELLS_INDEXES_DL}
    ...    expected_throughput=15    direction=dl    margin=95%    selection_type=maximum
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE6_ID}    cells_list=${4CC_SCELLS_INDEXES_DL}
    ...    expected_throughput=15    direction=dl    margin=95%    selection_type=maximum

Traffic Stop DL and UL non-GBR Data on Several UEs
    [Arguments]    ${ue_ids}    ${pdu_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
    Stop DL and UL traffic on PDU for UE    ue_id=${ue_ids}[${ue_index}]    pdu_id=${pdu_ids}[${ue_index}]
    END

Set ${all:\d+} expected UE Context Modification messages for gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=30]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify ${all:\d+} UE Context Modification messages for gNB${gnb_id:\d+} occured
    PASS FLOW[timeout=30]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify UE1 6CC 3F3T Blind SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 3 of 10 fulfils ${selected_SCells_for_6CC_3F3T_UE1_BB1_CA_in_UE_CON_MOD_REQ} content
    Verify gNB2 message UEContextModificationResponse number 3 of 10 fulfils ${selected_SCells_for_6CC_3F3T_UE1_BB1_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 3 of 10 fulfils ${PUCCH_config_for_6CC_3F3T_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 3 of 10 fulfils ${csi_MeasConfig_for_6CC_3F3T_CA_in_UE_CON_MOD_RESP} content

Verify UE2 6CC 3F3T Blind SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 8 of 10 fulfils ${selected_SCells_for_6CC_3F3T_UE2_BB1_CA_in_UE_CON_MOD_REQ} content
    Verify gNB2 message UEContextModificationResponse number 8 of 10 fulfils ${selected_SCells_for_6CC_3F3T_UE2_BB1_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 8 of 10 fulfils ${PUCCH_config_for_6CC_3F3T_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 8 of 10 fulfils ${csi_MeasConfig_for_6CC_3F3T_CA_in_UE_CON_MOD_RESP} content

Verify UE3 6CC 4F2T Blind SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 3 of 10 fulfils ${selected_SCells_for_6CC_4F2T_UE3_BB1_CA_in_UE_CON_MOD_REQ} content
    Verify gNB2 message UEContextModificationResponse number 3 of 10 fulfils ${selected_SCells_for_6CC_4F2T_UE3_BB1_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 3 of 10 fulfils ${PUCCH_config_for_6CC_4F2T_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 3 of 10 fulfils ${csi_MeasConfig_for_6CC_4F2T_CA_in_UE_CON_MOD_RESP} content

Verify UE4 6CC 4F2T Blind SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 8 of 10 fulfils ${selected_SCells_for_6CC_4F2T_UE4_BB1_CA_in_UE_CON_MOD_REQ} content
    Verify gNB2 message UEContextModificationResponse number 8 of 10 fulfils ${selected_SCells_for_6CC_4F2T_UE4_BB1_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 8 of 10 fulfils ${PUCCH_config_for_6CC_4F2T_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 8 of 10 fulfils ${csi_MeasConfig_for_6CC_4F2T_CA_in_UE_CON_MOD_RESP} content

Verify UE5 4CC 4F Blind SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 3 of 10 fulfils ${selected_SCells_for_4CC_4F_UE5_UE6_BB1_CA_in_UE_CON_MOD_REQ} content
    Verify gNB2 message UEContextModificationResponse number 3 of 10 fulfils ${selected_SCells_for_4CC_4F_UE5_UE6_BB1_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 3 of 10 fulfils ${PUCCH_config_for_4CC_4F_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 3 of 10 fulfils ${csi_MeasConfig_for_4CC_4F_CA_in_UE_CON_MOD_RESP} content

Verify UE6 4CC 4F Blind SCell Addition Message Contents
    Verify gNB2 message UEContextModificationRequest number 8 of 10 fulfils ${selected_SCells_for_4CC_4F_UE5_UE6_BB1_CA_in_UE_CON_MOD_REQ} content
    Verify gNB2 message UEContextModificationResponse number 8 of 10 fulfils ${selected_SCells_for_4CC_4F_UE5_UE6_BB1_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 8 of 10 fulfils ${PUCCH_config_for_4CC_4F_CA_in_UE_CON_MOD_RESP} content
    Verify gNB2 message UEContextModificationResponse number 8 of 10 fulfils ${csi_MeasConfig_for_4CC_4F_CA_in_UE_CON_MOD_RESP} content

Verify Pm Counters BB1
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Pm Counters    counter_id_list=${COUNTER_IDs_PCELL}    counter_name_list=${COUNTER_NAMEs_PCELL}
    ...    local_moid=${LOCAL_MOID_PCELL}    pm_counter_file=${pm_counter_file}    condition=4
    Verify Pm Counters    counter_id_list=${SAMPLE_COUNTER_IDs_PCELL}    counter_name_list=${SAMPLE_COUNTER_NAMEs_PCELL}
    ...    local_moid=${LOCAL_MOID_PCELL}    pm_counter_file=${pm_counter_file}    condition=>0

    FOR    ${CURRENT_MOID}    IN    @{SCELLs_DL_MOID}
       Verify Pm Counters    counter_id_list=${SAMPLE_COUNTER_ID_SCELLs_DL}    counter_name_list=${SAMPLE_COUNTER_NAME_SCELLs_DL}
   ...    local_moid=${CURRENT_MOID}    pm_counter_file=${pm_counter_file}    condition=>0
    END
    FOR    ${CURRENT_MOID}    IN    @{SCELLs_UL_MOID}
       Verify Pm Counters    counter_id_list=${SAMPLE_COUNTER_ID_SCELL_UL}    counter_name_list=${SAMPLE_COUNTER_NAME_SCELL_UL}
   ...    local_moid=${CURRENT_MOID}    pm_counter_file=${pm_counter_file}    condition=>0
    END

Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}
