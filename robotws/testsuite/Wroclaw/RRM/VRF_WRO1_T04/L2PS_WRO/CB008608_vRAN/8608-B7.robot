*** Settings ***
Force Tags    CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    CONFIGS_L2PS_WRO/vRAN/CB008608/custom-config.yaml
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00    vDUCNF00    vCUCNF00

Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords_vran.robot
Library      taf.gnb.oam.coam.cu       WITH NAME    admin_cu
Library      taf.gnb.oam.coam.vdu      WITH NAME    admin_du
Library      ute_wtssim
Library      ta5g_cell_operations
Library      ta5g_tshark
Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Variables    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables_vran.py
Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords_vran.py
Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC000774_ROHC/keywords_ROHC.py
Library      ../CB008697/CB008697_keywords.py
Resource     ../CB008697/CB008697_variables.robot
Library      testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.tcpdump_AIC.TcpdumpCU    WITH NAME    TcpdumpCU

Suite Setup  Run Keyword
...          Suite setup

Test Setup    Test setup SA
#Test Teardown    Test Teardown SA

*** Variables ***
${ue_id_1}   ${1}

${wts_cfg_file_path}=   ${CURDIR}/config/8608.cfg

${vCU_admin}                192.168.100.129
${TRAFFIC_DURATION_SEC}=   60s
${ICS_SETUP_RESP_SUCCESS}    ngap.procedureCode == 14 && ngap.NGAP_PDU == 1

*** Test Cases ***
CB008608-5G-F1_CB008697_B7_B17_OAI_deactivation_of_all_active_SCells_and_OH_exit
    Wait Until Next Pm Interval Starts On vDU
    ${alias}=    Start Tshark For Custom Interface  eth_interface=lo
    ${pid}=    TcpdumpCU.Tcpdump F1 Start    sctp    ${OUTPUT_DIR}/f1.pcap    any
    Set Internal Traffic Type    ue_id=${ue_id_1}    pdu_id=1
#    Wait Until Next Pm Interval Starts
#    bip_logs.Start Collecting Aic Bip Logs
#    Attach Ue  ue_id=1
    Attach Ue    ue_id=${ue_id_1}
    ta5g_ue_mobility.Establish Pdu Session    ue_id=${ue_id_1}    pdu_id=1    gw_id=1
    Add Scells    ue_id=${ue_id_1}
    Sleep    5s
    Start Big Data Dl    ue_id=${ue_id_1}    pdu_id=1    trf_id1=1    trf_id2=2
    Sleep    10s
    Verify Two Scells Are Added    ue_id=${ue_id_1}
    Sleep    5s
    Verify Tput For 2CC
    ...    ue_id=${ue_id_1}    cc0_tput=${True}    cc1_tput=${True}
    Set Ue In Overheated State With Max Cc    ue_id=${ue_id_1}    cc=0
    Sleep    5s
    TcpdumpCU.tcpdump F1 Stop   ${pid}
    Sleep    10s    reason=Wait for tcpdump collection end
    Verify Tshark For Single Message    alias=${alias}
    ...                                 packet_filter=${RRC_UE_ASSISTANCE_MAX_CC_0_VRAN}
    ...                                 pcap_file_path=${OUTPUT_DIR}/f1.pcap
    Verify Tshark For Single Message    alias=${alias}
    ...                                 packet_filter=${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE}
    ...                                 pcap_file_path=${OUTPUT_DIR}/f1.pcap
    Stop Tshark    alias=${alias}
#    Verify Tcpdump Log       packet_filter=${RRC_UE_ASSISTANCE_MAX_CC_0}
#    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE}
    Verify Two Scells Are Added    ue_id=${ue_id_1}
    Sleep    5s
    Verify Tput For 2CC
    ...    ue_id=${ue_id_1}    cc0_tput=${True}    cc1_tput=${False}
    Stop All Data Transfer For Ue    ue_id=${ue_id_1}    pdu_id=1
    Start Big Data Dl    ue_id=${ue_id_1}    pdu_id=1    trf_id1=3    trf_id2=4
    Sleep    5s
    Verify Tput For 2CC
    ...    ue_id=${ue_id_1}    cc0_tput=${True}    cc1_tput=${False}
    Stop All Data Transfer For Ue    ue_id=${ue_id_1}    pdu_id=1
    Wait Until Next Pm Interval Starts On vDU
    ${counters_after_attach_vdu}=    Get Counters File From vDU
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55316C12001
    ...    value=1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${counters_after_attach_vdu}
    Execute Egate Command And Wait For Data    cmd=ue_deregister id=${ue_id_1} ue_deregister_type=switch_off

*** Keywords ***
Set Internal Traffic Type To UEs
    [Arguments]    ${ue_id}=1     ${pdu_id}=1
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
