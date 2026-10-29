*** Settings ***
Test Timeout       90 minutes

Force Tags    CONFIGURED    CIT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Documentation   :copyright: Nokia
...             :authors: Tomasz Dabrowski
...             :contact: tomasz.dabrowski@nokia.com


Resource            ../resources/feature_keywords.robot
Resource            ../../resources/testing_env.robot
Resource            ../../keywords/traffic.robot
Resource            taf/rfrl/utilities/utf_lab/utf_lab.robot
Library             testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008490/resources/keywords.py    WITH NAME    kws
Resource            testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot

Library             taf.ul.ettf.setups
Library             ../resources/multignb_variables.py
Library             ../resources/KeywordsCB008490.py
Library             ../resources/syslog_collector.py
Variables           ../resources/custom_policy.py
Library             ../resources/common_keywords.py

Suite Setup        Run Keywords
#...                Update UTF Lab on UTE VM
...                Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
...    AND         Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Update And Put Iphy Xml         input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_SN}
...                remote_host=${REMOTE_HOST_1_IP}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_MN}
...    AND         With Simulator Configuration    config=${cfg}    remote_hosts=${REMOTE_HOSTS}
...    AND         Enforce protocol    nr-rrc
#...    AND         Start UTF Lab on UTE VM
#...    AND         Wait Until UTF Lab Connection Is Established

Test Setup         Run Keywords
#...                  UTF Lab Start Tracing gNB    gnb_ip=192.168.255.129    gnb_port=443     gnb_username=Nemuadmin      gnb_password=nemuuser
...                  Enable Tshark Verification
...    AND           Setup multigNB devices aliases
...    AND           Start Collecting Syslog From Gnbs

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${SCFC_GNB_MN}=             scfc_MN_n78A_AEQE_with_nrrel_and_nrhoif_to_n257_ASIL_LA_B3_A1.xml
${SCFC_GNB_SN}=             scfc_SN_n257_AWEUB_LA.xml
${IPHY}=                    ${CURDIR}/config/iphy_MN_AHEGC_AEQE_SN_AWEUB_B1_B2_B3.xml
${cfg}=                     ${CURDIR}/config/cfg_n1A_n257M_and_n78A_n257M_LA_B3_A1.cfg
${ue1}=                     1
${ue2}=                     2
${amf_id}=                  1
${pdu_id}=                  1
${band_comb_1}=             1
${band_comb_2}=             3
${band_comb_index_asn_1}=   '0x0000'
${band_comb_index_asn_2}=   '0x0002'
@{meas_objects_id_list}=     1     2     2
@{report_config_ids}=        1     1
@{FAULT_IDS_LIST}=            6450    4383
@{mn_logs}=                 cp_5g
${UTF_DIR_NAME}             UTF_LAB
${CONNECTION_ALIAS}         UTE_UTF_LAB

*** Test Cases ***
CB008490-LA#B3_Alt1_CSI-RS_Capabilitys_Check_Is_Failed_In_MN_gNB-DU_During_NR-DC_Setup
    Set ICS flow
    ta5g_ue_mobility.Attach Ue    ue_id=${ue1}    enb=2    cell=1
    Set Internal Traffic Type To UE    ue_id=${ue1}    pdu_id=${pdu_id}
    Establish Pdu Session
    Send Data Traffic    inactive_timer=1
    Verify ICS Flow
    Set Expected Message Flow For Rejection Of A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue1} GNB2
    Waiting For Message Flow To Set Up
    Send Ue Measurement Nr    ue_id=${ue1}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Verify Expected Message Flow For Rejection Of A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue1} GNB2
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=300Mbps
                                       ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=50Mbps      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=Average    margin=10%
    #Verify that UeCapability check is permanently failed
    [Teardown]     Run Keywords    Deregister UE    ue_id=${ue1}
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
    ...            AND    Stop Collecting Syslog And Download Files
#    ...            AND    Stop UTF Lab on UTE VM
    ...            AND    Add scout external execution id to the reporting portal


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
    Unpack and prepare new DCAP 5gm files to verify json    ${utf_dir}/${filename}   ${filters}     connection=${CONNECTION_ALIAS}
    ${json_filepath}    Catenate    SEPARATOR=/    ${utf_dir}    ${filename}    C_Plane_${test_name}_filtered_part_1.json
    kws.Verify Message Sequence In Json    ${json_filepath}    ${master_node_messages}
