*** Settings ***
Test Timeout       90 minutes

Force Tags    CONFIGURED    CIT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Documentation   :copyright: Nokia
...             :authors: Tomasz Dabrowski, Kornel D?u?niewski
...             :contact: tomasz.dabrowski@nokia.com


Resource            ../CB008490_Keywords_And_Variables.robot
Resource             ../../keywords/traffic.robot
Library             taf.sbts.oam.coam.admin     WITH NAME    admin
Library             ta5g_egate
Resource            testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot


Suite Setup        Run Keywords
...                                Netconf access
...                AND             Upload oransnapshot.xml to AP   iphy_snap=${IPHY_SNAP}
...                AND             Put Swconfig File    ${SW_CONFIG}
...                AND             Update And Put Iphy Xml         input_filepath=${IPHY}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC_GNB_SN}
...                                skip_relation_errors=True
...                                remote_host=${REMOTE_HOST_1_IP}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                skip_relation_errors=True
...                                scfc_filename=${SCFC_GNB_MN}
...                AND             Reach Onair    lua_cfg=${cfg}    remote_hosts=${REMOTE_HOSTS}


Suite Teardown     Run Keywords
...                                Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${SCFC_GNB_MN}=             MN_scfc_LAB4A1_oran.xml
${SCFC_GNB_SN}=             SN_scfc_LAB4A1_oran.xml
${IPHY}=                    ${CURDIR}/config/iphy_LAB4A1_oran.xml
${IPHY_SNAP}                iphy_snap_CB008490_LAB4A1_N78.xml
${SW_CONFIG}                ${CURDIR}/config/swconfig_LA_B4.txt
${cfg}=                     ${CURDIR}/config/cfg_n1A_n257M_and_n78A_n257M_LA_B4A1_oran.cfg
${ue_id}=                   1
${pdu_id}=                  1
${amf_id}=                  1
${gnb_id}                   2
@{FAULT_IDS_LIST}=          6450    4383
@{mn_logs}=                 cp_5g
${UTF_DIR_NAME}             UTF_LAB
${CONNECTION_ALIAS}         UTE_UTF_LAB
${pcap_file}=               ${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap

${NZP_RESOURCES_F1AP}    nr-rrc.nzp_CSI_RS_ResourceToAddModList == 2 && nr-rrc.nzp_CSI_RS_ResourceId == 182 &&
...                      nr-rrc.nzp_CSI_RS_ResourceId == 183 && nr-rrc.nzp_CSI_RS_Resources == 4 &&
...                      nr-rrc.csi_IM_ResourceToAddModList == 2 && nr-rrc.csi_IM_Resources == 4

*** Test Cases ***
CB008490-LA_B4_Alt1_CSI-RS_Upgrade_In_PCell_During_NR-DC_Bearer_Takeback
    [Setup]    Run Keywords     Start Default Logging And Mark New Test

    ta5g_ue_mobility.attach_ue    ue_id=${ue_id}    enb=${gnb_id}    cell=1
    Set Internal Traffic Type For UE    ue=${ue_id}    pdu=1
    Establish Pdu Session        ue_id=${ue_id}    timeout=30
    Send Data Traffic    inactive_timer=1
    Wait 2s For Measurement To Configure
    Send Ue Measurement Nr    ue_id=${ue_id}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Wait 5s For NRDC To Establish
    Verify That Traffic Is Scheduled On All SCells In Group
    ...                              ue_id=${ue_id}    cell_group=SCG    cell_index_min=1    cell_index_max=1
    Wait 30s for traffic to stabilize
    Trigger PDU Session Modify Procedure For UE1 With PDU1 And QoS Flow ID Eq 2
    Wait 2s For NRDC Takeback
    Verify that Resources were correctly reconfigured after NR-DC Bearer Takeback
    Verify That Traffic Is Scheduled On All SCells In Group
    ...                              ue_id=${ue_id}    cell_group=MCG    cell_index_min=0    cell_index_max=0

    [Teardown]     Run Keywords
     ...           Deregister UE    ue_id=${ue_id}
     ...    AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
     ...    AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
     ...    AND    Add Scout Scf Id To Test Data

*** Keywords ***
Verify that Resources were correctly reconfigured after NR-DC Bearer Takeback
    Verify Tcpdump Log    packet_filter=${NZP_RESOURCES_F1AP}      number_of_messages=1     relation_symbol= >=    timeout=60

Trigger PDU Session Modify Procedure For UE${ue_id:\d+} With PDU${pdu_id:\d+} And QoS Flow ID Eq ${qosflows:\d+}
    Execute Egate Command And Wait For Data
    ...     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows}
    ...     pass_regexp=message c1 : rrcReconfigurationComplete

Verify traffic after NR-DC establishemnet
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Kbps
                                       ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=90Mbps      cell_index_min=1    cell_index_max=1
                                       ...     direction=dl    cell_group=SCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}   expected_throughput=10Mbps      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=Average    margin=10%

Verify Traffic after Takeback on MCG
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Kbps
                                       ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}   expected_throughput=10Mbps      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=Average    margin=10%

Create dcap filters
    ${f1ap_protocol}=     Catenate    SEPARATOR=;  "Message name"="ITF_CP_CPUE_CPRT_CPRT_SENDTOCPUE_ID"
    ...    "Message name"="ITF_CP_CPUE_CPRT_CPRT_RECEIVEFROMCPUE_ID"
    ${e1ap_protocol}=    Catenate    SEPARATOR=;  "Message name"="ITF_CP_CPUE_CPNRT_CPNRT_SENDTOCPUE_ID"
    ...    "Message name"="ITF_CP_CPUE_CPNRT_CPNRT_RECEIVEFROMCPUE_ID"
    ${other_protocols}=    Catenate    SEPARATOR=;  "Message name"="SctpMessage"    "Message name"="ZmqMessage"
    ...    "Message name"="TmMessage"
    ${filtered_protocols}=  Catenate  SEPARATOR=;  ${f1ap_protocol}  ${e1ap_protocol}  ${other_protocols}
    [Return]    ${filtered_protocols}

Verify that UeCapability check is passed
    @{master_node_messages}=    Create List    UeCapabilityCheckRequest
    ...   UeCapabilityCheckResponse    passed
    Stop UTFLAB and verify messages    ${master_node_messages}

Stop UTFLAB and verify messages
    [Arguments]    ${messages_to_check}
    ${timestamp} =    Get Current Date    result_format=%Y%m%d-%H%M
    ${filename} =    Catenate    SEPARATOR=_    ${TEST_NAME}    ${timestamp}
    ${utf_dir}     Catenate    SEPARATOR=/    ${OUTPUT_DIR}    ${UTF_DIR_NAME}
    Set test variable    ${utf_dir}
    os.create directory    ${utf_dir}
    UTF Lab Stop Tracing and Collect Results    log_dir=${utf_dir}   with_name=${filename}
    ${filters}    create dcap filters
    Unpack and prepare new DCAP 5gm files to verify json    ${utf_dir}/${filename}   ${filters}     connection=${CONNECTION_ALIAS}
    ${json_folder}    Catenate    SEPARATOR=/    ${utf_dir}    ${filename}
    @{files}=    os.List Files In Directory    ${json_folder}    *.json    absolute=True
    Verify Message Sequence In Multiple Json Files    ${files}    ${messages_to_check}

Upload oransnapshot.xml to AP
    [Arguments]  ${iphy_snap}
    Log To Console     Uploading Oransnapshot: ${iphy_snap}
    ${Oran_alias}      SSH.connect to    192.168.200.1   toor4nsn    oZPS0POrRieRtu   alias=iphy
    ssh.Upload File    ${CURDIR}/config/${iphy_snap}    /rom/simmode/${iphy_snap}  connection=${Oran_alias}

Netconf access
        admin.connect_to    name=gnb_connection
        admin.enable_ssh_access    timeout=${30}    connection=gnb_connection
        admin.configure_netconf_radio_management    authentication_method=NoAuthentication
        ...                                                    id=1
        ...                                                    name=xranuser
        ...                                                    password=xran-password
        ...                                                    dist_name=${EMPTY}
        ...                                                    unsecure_ciphering=False
        ...                                                    format=${EMPTY}
        ...                                                    value=${EMPTY}
        ...                                                    connection=gnb_connection

