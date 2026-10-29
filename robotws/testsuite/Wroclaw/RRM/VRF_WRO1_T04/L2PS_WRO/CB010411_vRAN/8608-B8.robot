*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC     	VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS24R1


Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Resource     resources/8608_keywords.robot
Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ../CB008697/CB008697_variables.robot
Library      ../resources/Python/webem_alarms.py
Library      resources/commissioning_vran.py
Library      ta5g_commissioning
Library      ta5g_iphy
Library      ta5g_admin_operations
Library      ta5g_ue_mobility
Library     ../CB008697/CB008697_keywords.py
Library      resources/counters_vdu.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Variables     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables_vran.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords_vran.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/vran_delta.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords_vran.robot
Resource     ../resources/configuration_id.robot


Suite Setup    Run Keywords    Enable Cloud
...            AND             Update And Put Iphy Xml Aic
...                               input_filepath=${CURDIR}/config/iphy_8608_B7.xml
...                               output_dirpath=${OUTPUT_DIR}
...            AND             Call Ap Console Reboot
...            AND             Enable AiC Carrier Aggregation
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}
...            AND             Check Radios Availability Aic
...                               timeout=400
...            AND             Wait For F1 Links To Be Available Aic
...            AND             Reach Onair Aic
...                            lua_cfg=${CURDIR}/config/8608_n78_new.cfg


Suite Teardown    Run Keywords    Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${ue_id_1}   ${1}

${wts_cfg_file_path}=   ${CURDIR}/config/8608.cfg

${vCU_admin}                192.168.100.129
${TRAFFIC_DURATION_SEC}=   60s
${ICS_SETUP_RESP_SUCCESS}    ngap.procedureCode == 14 && ngap.NGAP_PDU == 1

*** Test Cases ***
CB008608-5G-F1_CB008697_B8_B17_OAI_deactivation_of_all_inactive_SCells_and_OH_exit
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id_1} pdu=1 trf_type=internal
    ta5g_ue_mobility.Attach Ue    ue_id=${ue_id_1}
    ta5g_ue_mobility.Establish Pdu Session    ue_id=${ue_id_1}    pdu_id=1    gw_id=1
    Add Scells    ue_id=${ue_id_1}
    Start Low Data Dl    ue_id=${ue_id_1}    trf_id1=1    trf_id2=2
    Sleep    10s
    Verify Two Scells Are Added    ue_id=${ue_id_1}
    Sleep    5s
    Verify Tput For 2CC
    ...    ue_id=${ue_id_1}    cc0_tput=${True}    cc1_tput=${False}
    Set Ue In Overheated State With Max Cc    ue_id=${ue_id_1}    cc=0
    Verify Tcpdump Log
    ...    packet_filter=${RRC_UE_ASSISTANCE_MAX_CC_0_VRAN}
    ...    number_of_messages=2
    Verify Tcpdump Log
    ...    packet_filter=${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE}
    ...    number_of_messages=1
    Sleep    5s
    Verify Two Scells Are Added    ue_id=${ue_id_1}
    Sleep    5s
    Verify Tput For 2CC
    ...    ue_id=${ue_id_1}    cc0_tput=${True}    cc1_tput=${False}
    Stop All Data Transfer For Ue    ue_id=${ue_id_1}    pdu_id=1
    Start Big Data Dl    ue_id=${ue_id_1}    pdu_id=1    trf_id1=5    trf_id2=6
    Start Big Data Dl    ue_id=${ue_id_1}    pdu_id=1    trf_id1=7    trf_id2=8
    Sleep    5s
    Verify Tput For 2CC
    ...    ue_id=${ue_id_1}    cc0_tput=${True}    cc1_tput=${False}
    Stop All Data Transfer For Ue    ue_id=${ue_id_1}    pdu_id=1
    Wait For Next Full Pm Interval Aic
    Collect_coam_vdu_pm_counters
    Find Counter In Dir
    ...  counter_id=M55316C12001
    ...  value=0
    ...  dir_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pm_counters/
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    Execute Egate Command And Wait For Data    cmd=ue_deregister id=${ue_id_1} ue_deregister_type=switch_off
#    [Teardown]    Send Configuration ID To Scout


*** Keywords ***
Enable AiC Carrier Aggregation
    Send XML CU Delta Commisioning    ${CURDIR}/config/Delta_CU.xml
    Send XML DU Delta Commisioning    ${CURDIR}/config/Delta_DU.xml
    Sleep      380s

Set Internal Traffic Type To UEs
    [Arguments]    ${ue_id}=1     ${pdu_id}=1
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

