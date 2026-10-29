*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65    CONFIGURED
...           SBTS00    RAN_5G    CRT    PY311
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Kornel Dluzniewsi
...              :contact: kornel.dluzniewski@nokia.com,

Resource    CB010741_Keywords_And_Variables.robot

Suite Setup        Run Keywords
...                                Update UTF Lab on UTE VM
...                AND             Update And Put Iphy Xml         input_filepath=${IPHY}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC}
...                AND             Reach Onair    lua_cfg=${cfg}

...                AND             Start UTF Lab on UTE VM
...                AND             Wait Until UTF Lab Connection Is Established
...                AND             UTF Lab Start Tracing gNB    gnb_ip=192.168.255.129
...                                gnb_port=443     gnb_username=Nemuadmin      gnb_password=nemuuser


Suite Teardown   Run Keyword       Stop Default Processes And Gather Logs And Compress Logs
  ...            AND               Stop UTF Lab on UTE VM

*** Variables ***
${SCFC}=                           scfc_C_B5.xml
${cfg}=                            ${CURDIR}/config/basic_setup_scfc_C_B5.cfg
${iphy}=                           ${CURDIR}/config/iphy_CB010471_scfc_C_B5.xml
${gnb_custom_profile}=             cp_5g
${UTF_DIR_NAME}                    UTF_LAB
${CONNECTION_ALIAS}                UTE_UTF_LAB


*** Test Cases ***
CB010741_C_B5_UL_Buffer_Triggered_SCell_Upgrade_With_Measurement_Reconfiguration_Due_To_Power_Class_Criterion
    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/

    amf ue ics param
    sleep   3s
    ta5g_ue_mobility.Attach UE    ue_id=1
    Set Internal Traffic Type For UE    ue=1    pdu=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    sleep   3s
    UE Tput DL
    sleep   11s
    Ue Stats NR PDSCH
    sleep   3s
    Ue Stats NR PUSCH
    sleep   3s
    UE Tput UL
    sleep   13s
    Ue Stats NR PDSCH
    sleep   4s
    Ue Stats NR PUSCH
    Verify Messages UL Buffer Triggered SCell
    Pm counter I
    Verify DCAP messages

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=1
        ...       AND             Stop UTF Lab on UTE VM
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
amf ue ics param
    Execute egate command   cmd=amf_ue_ics_param id=1 ue=1 object_id=1 location_reporting_reference_id=1 trace_activation=on
        ...    trace_plmn=310:260 trace_ref_id=1 trace_rec_session_ref_id=1 trace_depth=medium ifaces_to_trace=Uu,NG-C,Xn-C,F1-C tce_ip=10.42.189.98
Ue Stats NR PDSCH
    Execute egate command   cmd=ue_stats_nr id=1 scell=0-5 type=pdsch
Ue Stats NR PUSCH
    Execute egate command   cmd=ue_stats_nr id=1 scell=0-5 type=pusch
UE Tput DL
    Execute egate command   cmd=trf_data_start ue=1 pdu=1 trf_id=1 dir=dl mbps=150
    Execute egate command   cmd=trf_data_start ue=1 pdu=1 trf_id=2 dir=dl mbps=150
    Execute egate command   cmd=trf_data_start ue=1 pdu=1 trf_id=3 dir=dl mbps=100

UE Tput UL
    Execute egate command   cmd=trf_data_start ue=1 pdu=1 trf_id=4 dir=ul mbps=150
    Execute egate command   cmd=trf_data_start ue=1 pdu=1 trf_id=5 dir=ul mbps=100
    Execute egate command   cmd=trf_data_start ue=1 pdu=1 trf_id=6 dir=ul mbps=150
    Execute egate command   cmd=trf_data_start ue=1 pdu=1 trf_id=7 dir=ul mbps=150

Create dcap filters
    ${f1ap_protocol}=     Catenate    SEPARATOR=;  "Message name"="ITF_CP_CPUE_CPRT_CPRT_SENDTOCPUE_ID"
    ${other_protocols}=    Catenate    SEPARATOR=;  "Message name"="F1AP: UEContextModificationResponse"
    ${filtered_protocols}=  Catenate  SEPARATOR=;  ${f1ap_protocol}  ${other_protocols}
    [Return]    ${filtered_protocols}

Verify DCAP messages
    @{master_node_messages}=    Create List
    ...    UEContextModificationResponse
    ...    NokiaPmaxParameters
    ...    pMaxPCell
    ...    pMaxFr1Bc
    ${timestamp} =    Get Current Date    result_format=%Y%m%d-%H%M
    ${filename} =    Catenate    SEPARATOR=_    ${TEST_NAME}    ${timestamp}
    ${utf_dir}     Catenate    SEPARATOR=/    ${OUTPUT_DIR}    ${UTF_DIR_NAME}
    Set test variable    ${utf_dir}
    create directory    ${utf_dir}
    UTF Lab Stop Tracing and Collect Results    log_dir=${utf_dir}   with_name=${filename}
    ${filters}    create dcap filters
    Unpack and prepare new DCAP 5gm files to verify json    ${utf_dir}/${filename}   ${filters}     connection=${CONNECTION_ALIAS}
    ${json_dir}=    Catenate    SEPARATOR=/    ${utf_dir}    ${filename}
    @{json_files}=    OperatingSystem.List Files In Directory
    ...    ${json_dir}
    ...    pattern=C_Plane_${TEST_NAME}_filtered_part_*.json
    Sort List    ${json_files}
    FOR    ${file}    IN    @{json_files}
    ${full_path}=    Catenate    SEPARATOR=/    ${json_dir}    ${file}
    Log    Verifying file: ${full_path}
    Run Keyword And Ignore Error    kws.Verify Message Sequence In Json    ${full_path}    ${master_node_messages}
    END

Pm counter I
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55113C00025   +1    SCELL_CONFIG_SUCC_UL_BUFFER_SA
    ...    M55138C03524   +1    GNB_UL_SCELL_1_ADMI_REQ_SA
    ...    M55138C03527   +1    GNB_UL_SCELL_1_ADMI_SUCC_SA
    ...    M55138C01501   +1    GNB_SCELL_1_ADMI_REQ_SA
    ...    M55138C01502   +1    GNB_SCELL_1_ADMI_SUCC_SA
    ...    M55118C11058   >0    GNB_UL_SCELL_1_CONFIG_REQ_SA
    ...    M55139C05516   >0    GNB_DU_UL_SCELL_1_ADMI_REQ_SA
    ...    M55139C01003   >0    GNB_DU_SCELL_1_ADMI_REQ_SA
    ...    M55139C05519   +1    GNB_DU_UL_SCELL_1_ADMI_SUCC_SA
    ...    M55139C01004   >0    GNB_DU_SCELL_1_ADMI_SUCC_SA
    ...    M55118C10001   +1    RRC_RECONF_ADD1ULSCELL_ATT_SA
    ...    M55118C10002   +1    RRC_RECONF_ADD1ULSCELL_SUCC_SA
    ...    M55118C11108   +1    UL_RRC_STEP_SCELL_ADD_ATT_SA
    ...    M55118C11109   +1    UL_RRC_STEP_SCELL_ADD_SUCC_SA
    ...    M55118C11068   +1    GNB_UL_SCELL_1_CONFIG_SUCC_SA
    ...    M55118C00098   >0    SCELL_CONFIG_DUR_SA
    ...    M55118C00097   >0    SCELL_CONFIG_RRC_RECNFG_DUR_SA
    ...    M55118C00099   >0    SCELL_CONFIG_DUR_GNB_MAX
    ...    M55118C11051   +1    GNB_DL_SCELL_1_CONFIG_REQ_SA
    ...    M55118C11061   +1    GNB_DL_SCELL_1_CONFIG_SUCC_SA
    ...    M55118C11106   <1    DL_RRC_STEP_SCELL_ADD_ATT_SA
    ...    M55118C11107   <1    DL_RRC_STEP_SCELL_ADD_SUCC_SA
    ...    M55138C03510   +1    GNB_DL_SCELL_1_ADMI_REQ_SA
    ...    M55138C03517   +1    GNB_DL_SCELL_1_ADMI_SUCC_SA
    ...    M55139C05502   +1    GNB_DU_DL_SCELL_1_ADMI_REQ_SA
    ...    M55139C05509   +1    GNB_DU_DL_SCELL_1_ADMI_SUCC_SA
    ...    M55118C00033   +1    BLIND_SCELL_ADDED_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${PM_COUNTER_FILE}
    ...    rep.report_pm_counter=True
