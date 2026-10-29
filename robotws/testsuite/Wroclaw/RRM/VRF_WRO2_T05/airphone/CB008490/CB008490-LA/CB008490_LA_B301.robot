*** Settings ***
Test Timeout       90 minutes

Force Tags    CONFIGURED    CIT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Documentation   :copyright: Nokia
...             :authors: Tomasz Dabrowski
...             :contact: tomasz.dabrowski@nokia.com


Resource            ../CB008490_Keywords_And_Variables.robot
Resource            ../../keywords/traffic.robot
Resource            taf/rfrl/utilities/utf_lab/utf_lab.robot
Resource            testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot
Library             DateTime
Library             testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008490/resources/keywords.py    WITH NAME    kws



Suite Setup        Run Keywords
...                Update UTF Lab on UTE VM
...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
...    AND         Update And Put Iphy Xml         input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_SN}
...                remote_host=${REMOTE_HOST_1_IP}
...                skip_relation_errors=True
...   AND          Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_MN}
...                skip_relation_errors=True
...    AND         Reach Onair    lua_cfg=${cfg}    remote_hosts=${REMOTE_HOSTS}
...    AND         Start UTF Lab on UTE VM
...    AND         Wait Until UTF Lab Connection Is Established


Test Setup         Run Keywords
...                UTF Lab Start Tracing gNB    gnb_ip=192.168.255.129    gnb_port=443     gnb_username=Nemuadmin      gnb_password=nemuuser
...   AND          Start Default Logging And Mark New Test     remote_host=${REMOTE_HOST_1_IP}

*** Variables ***
${SCFC_GNB_MN}=             scfc_MN_n78A_AEQE_with_nrrel_and_nrhoif_to_n257_ASIL_LA_B3_A1.xml
${SCFC_GNB_SN}=             scfc_SN_n257_AWEUB_LA.xml
${IPHY}=                    ${CURDIR}/config/iphy_MN_AHGD_AEQE_SN_AWEUB_B1_B2_B3.xml
${cfg}=                     ${CURDIR}/config/cfg_n1A_n257M_and_n78A_n257M_LA_B3_A1.cfg
${ue_id}=                   1
${ue1}=                     1
${ue2}=                     2
${amf_id}=                  1
${pdu_id}=                  1
@{meas_objects_id_list}=     1     2     2
@{report_config_ids}=        1     1
@{FAULT_IDS_LIST}=           6450    4383
@{mn_logs}=                  cp_5g
${UTF_DIR_NAME}              UTF_LAB
${CONNECTION_ALIAS}          UTE_UTF_LAB

*** Test Cases ***
CB008490-LA#B3_Alt1_CSI-RS_Capabilitys_Check_Is_Failed_In_MN_gNB-DU_During_NR-DC_Setup
    ta5g_ue_mobility.Attach Ue    ue_id=${ue1}    enb=2    cell=1
    Set Internal Traffic Type For UE    ue=${ue1}    pdu=1
    Establish Pdu Session        ue_id=${ue_id}    timeout=30
    Send Data Traffic    inactive_timer=1
    Send Ue Measurement Nr    ue_id=${ue1}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Verify That Traffic Is Scheduled On All SCells In Group
    ...                              ue_id=${ue_id}    cell_group=MCG    cell_index_min=0    cell_index_max=0

    Verify that UeCapability check is permanently failed
    [Teardown]     Run Keywords    Deregister UE    ue_id=${ue1}
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
    ...            AND    Add Scout Scf Id To Test Data
    ...            AND    Stop Default Processes And Gather Logs And Compress Logs
    ...            AND    Stop UTF Lab on UTE VM



*** Keywords ***
Create dcap filters
    ${f1ap_protocol}=     Catenate    SEPARATOR=;  "Message name"="ITF_CP_CPUE_CPRT_CPRT_SENDTOCPUE_ID"
    ...    "Message name"="ITF_CP_CPUE_CPRT_CPRT_RECEIVEFROMCPUE_ID"
    ${e1ap_protocol}=    Catenate    SEPARATOR=;  "Message name"="ITF_CP_CPUE_CPNRT_CPNRT_SENDTOCPUE_ID"
    ...    "Message name"="ITF_CP_CPUE_CPNRT_CPNRT_RECEIVEFROMCPUE_ID"
    ${other_protocols}=    Catenate    SEPARATOR=;  "Message name"="SctpMessage"    "Message name"="ZmqMessage"
    ...    "Message name"="TmMessage"
    ${filtered_protocols}=  Catenate  SEPARATOR=;  ${f1ap_protocol}  ${e1ap_protocol}  ${other_protocols}
    [Return]    ${filtered_protocols}

Verify that UeCapability check is permanently failed
    @{master_node_messages}=    Create List    UeCapabilityCheckRequest
    ...   UeCapabilityCheckResponse    permanently-failed
    ${timestamp} =    Get Current Date    result_format=%Y%m%d-%H%M
    ${filename} =    Catenate    SEPARATOR=_    ${TEST_NAME}    ${timestamp}
    ${utf_dir}     Catenate    SEPARATOR=/    ${OUTPUT_DIR}    ${UTF_DIR_NAME}
    Set test variable    ${utf_dir}
    create directory    ${utf_dir}
    UTF Lab Stop Tracing and Collect Results    log_dir=${utf_dir}   with_name=${filename}
    ${filters}    create dcap filters
    Unpack and prepare new DCAP 5gm files to verify json
    ...     ${utf_dir}/${filename}   ${filters}
    ...     connection=${CONNECTION_ALIAS}
    ${json_files}  Kws.List Json Files   ${utf_dir}/${filename}
    kws.verify_message_sequence_in_multiple_json_files   ${json_files}    ${master_node_messages}
