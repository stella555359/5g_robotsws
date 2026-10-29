*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristinel Sava
...              :maintainer: Cristinel Sava

Library      OperatingSystem
Library      BuiltIn
Library       ute_reporting_portal


Resource     ../../../resourcesBLR/robot/common_log_collection.robot
Library      ../../../resourcesBLR/NPS/SWENG/python_libs/luashark_tools.py
Resource      ../../../resourcesKRK/krk3_common/main_vran.robot

Resource     CB010413_Keywords.robot
Library      copy_unix_to_win.py

Suite Setup      Testline Setup
#Suite Teardown    Testline Teardown
Test Teardown    Run Keywords     DCAP Disconnect To gNB
...               AND     log to console    TEST
#...               AND     Cleanup EMil dir


*** Variables ***
${UTE_SSH_IP}=                                           ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_SSH_USER_NAME}=                                    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_SSH_PASSWORD}=                                     ${tl.test_pc.default_ssh_connection_details.password}
${IPCAPTURE_TO_TXT}=   tshark -r ${OUTPUT DIR}/ipcaptureExtracted/* -Y 'nr-rrc.c1 == 0' -T text -o ntrstr.port:49148 -o
...  ntrstr.defragment:TRUE > ${OUTPUT DIR}/ipcaptureExtracted/ipcapture_to_txt.txt
${destination}       C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\
${log_path}    /home/ute/dcaplogs
${TS1}          stop1
${TS2}          stop2
${TC_Name}      USCB008225_J_B08_1_PCMD_records_from_gNB_DU_during_RRC_Inactive_to_RRC_Connected_transition_AC_fails_in_gNB_DU

@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
&{CONFIG_del_TCE}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${CU_Delta_DEL_TCE}   delta_vdu=${DU_Delta_DEL_TCE}
${CU_Delta_DEL_TCE}     ${CURDIR}/configs/CU_Delta_DEL_TCE.xml
${DU_Delta_DEL_TCE}     ${CURDIR}/configs/DU_Delta_DEL_TCE.xml
&{CONFIG_DCAP}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${CU_Delta_DCAP}   delta_vdu=${DU_Delta_DCAP}
${CU_Delta_DCAP}     ${CURDIR}/configs/CU_Delta_DCAP.xml
${DU_Delta_DCAP}     ${CURDIR}/configs/DU_Delta_DCAP.xml

&{CONFIG_no_ran_sh}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${no_ran_sh_VCU}   delta_vdu=${no_ran_sh_VDU}
${no_ran_sh_VCU}     ${CURDIR}/configs/CU_Delta_8225_no_ran_sharing.xml
${no_ran_sh_VDU}     ${CURDIR}/configs/DU_Delta_8225_no_ran_sharing.xml
&{DEL_NRMTRACEDU}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${Delta_DEL_NRMTRACEDU_VCU}   delta_vdu=${Delta_DEL_NRMTRACEDU_VDU}
${Delta_DEL_NRMTRACEDU_VCU}     ${CURDIR}/configs/CU_Delta_DEL_ipif1.xml
${Delta_DEL_NRMTRACEDU_VDU}     ${CURDIR}/configs/DU_Delta_DEL_NRMTRACEDU.xml
&{Create_NRSTRACEDU}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${Create_NRSTRACEDU_VCU}   delta_vdu=${Create_NRSTRACEDU_VDU}
${Create_NRSTRACEDU_VCU}     ${CURDIR}/configs/CU_Delta_UPD_ipif.xml
${Create_NRSTRACEDU_VDU}     ${CURDIR}/configs/DU_Delta_CRE_NRMTRACEDU.xml
&{upd_maxNumOfRrcSA}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${upd_maxNumOfRrcSA_VCU}   delta_vdu=${upd_maxNumOfRrcSA_VDU}
${upd_maxNumOfRrcSA_VCU}     ${CURDIR}/configs/CU_Delta_UPD_maxNumOfRrcSA.xml
${upd_maxNumOfRrcSA_VDU}     ${CURDIR}/configs/DU_Delta_UPD_maxNumOfRrcSA.xml
&{upd_maxNumOfRrcSA275}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${upd_maxNumOfRrcSA275_VCU}   delta_vdu=${upd_maxNumOfRrcSA275_VDU}
${upd_maxNumOfRrcSA275_VCU}     ${CURDIR}/configs/CU_Delta_UPD_maxNumOfRrcSA_275.xml
${upd_maxNumOfRrcSA275_VDU}     ${CURDIR}/configs/DU_Delta_UPD_maxNumOfRrcSA_275.xml
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS}=    amf_ue_ics_param id=1 ue=2 core_network_assistance_info=on ue_identity_index_value=2
...                                                  ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=100
${start_trace}=    ng_ue_trace_start id=1 trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1
...                                                           ifaces_to_trace=NG-C,Uu,Xn-C,F1-C tce_ip=0.0.0.0 trace_depth=minimum




*** Test Cases ***
USCB008225_J_B08_1_PCMD_records_from_gNB_DU_during_RRC_Inactive_to_RRC_Connected_transition_AC_fails_in_gNB_DU
    [Documentation]    This test case describes NG Full Reset initiated by gNB
    ...                5G_RAN_USR_RRM_1229
    ...                Test case checks:
    ...                - if counters NG_CU_RESET_ACK_RCV and NG_CU_RESET_REQ_SENT are incremented properly
    ...                author:    Cristinel Sava
    ...                contact:   cristinel.sava@nokia.com
    [Setup]    Run Keywords     Log to console      Start test setup
#    ...     AND    Test Case Setup    reach_on_air=no   config=&{CONFIG_del_TCE}    reboot_after_config=no
#    ...     AND    Test Case Setup    reach_on_air=no   config=&{CONFIG_DCAP}    reboot_after_config=no
#    ...     AND    Test Case Setup    reach_on_air=no   config=&{DEL_NRMTRACEDU}    reboot_after_config=no
#    ...     AND    Test Case Setup    reach_on_air=no   config=&{Create_NRSTRACEDU}    reboot_after_config=no
#    ...     AND    Test Case Setup    reach_on_air=yes   config=&{CONFIG_no_ran_sh}    reboot_after_config=yes
    ...     AND    Test Case Setup    reach_on_air=yes       reboot_after_config=no

###### PART 1 check in control plane logs #########
    sleep    10s
#    Test Case Setup    reach_on_air=no   config=&{upd_maxNumOfRrcSA275}    reboot_after_config=no
    Mkdir PC Emil
    log to console    Initiate Dcap
    Initiate Dcap
    log to console    sleep 20s
    sleep    20s
    log to console    DCAP Connect To gNB
    DCAP Connect To gNB
    log to console     BuiltIn.Log without cell argument
    BuiltIn.Log    without cell argument
    log to console     Start Log Via DCAP vducontrolplane
    Start Log Via DCAP  vducontrolplane
    log to console    sleep 10s
    sleep    10s

    log to console     Egate cmd=SET_AMF_TO_SEND
    Execute Egate Command    cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS}
    log to console     Egate cmd=set_pdu_param ue=2 pdu=1 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=2 pdu=1 trf_type=internal
    log to console     Egate register ue_id=2
    Execute Egate Command     cmd=ue_register id=2
    Sleep  2s
    log to console     Egate cmd=ue_pdu_session_setup ue=2 pdu=1 nwslice=1 gw=2
    Execute Egate Command    cmd=ue_pdu_session_setup ue=2 pdu=1 nwslice=1 gw=2
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
    Execute Egate Command    cmd=trf_data_stop ue=2 pdu=1 qfi=1 dir=dl
    log to console    sleep 180S
    Sleep  180s
    log to console     upd_maxNumOfRrcSA
    Test Case Setup    reach_on_air=no   config=&{upd_maxNumOfRrcSA}    reboot_after_config=no
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
    log to console    sleep 20S
    Sleep  20s
    log to console    Stop Log Via DCAP vducontrolplane
    Stop Log Via DCAP  vducontrolplane  test_scenario=vducontrol
    Test Case Setup    reach_on_air=no   config=&{upd_maxNumOfRrcSA275}    reboot_after_config=no
    Execute Egate Command    cmd=ue_deregister id=2 by=ue ue_deregister_type=switch_off
    Log to console    ue_deregistered id=2

    Copy DCAP Logs on VM in classical path
    ${tl_name}      CB010413_Keywords.Get TL hostname
    ${source_dir_5gm}    Set Variable    /${OUTPUT_DIR}/ipcaptureExtracted/5gm
    ${source_dir_lcbin}    Set Variable    /${OUTPUT_DIR}/ipcaptureExtracted/lcbin
    ${user}    Set Variable    NOKLAB\\rfsharing
    ${ip}    Set Variable    10.5.53.88
    ${destination_5gm}    Set Variable    C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}\\\\5gm\\\
    ${destination_lcbin}    Set Variable    C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}\\\\lcbin\\\\
    ${password}    Set Variable    Nokia2022!@1
    log to console    Copy Files To Windows 5gm
    Copy Files To Windows KW1    ${source_dir_5gm}    ${user}    ${ip}      ${destination_5gm}    ${password}
#    log to console    Copy Files To Windows lcbin
#    Copy Files To Windows KW2    ${source_dir_lcbin}    ${user}    ${ip}    ${destination_lcbin}    ${password}
    log to console    Convert 5gm Files To Csv
    Convert 5gm Files To Csv
    sleep    2s
#    log to console    Convert lcbin Files To Csv
#    Convert lcbin Files To Csv
    log to console    Send csv from PC to VM
    Send csv from PC to VM
    sleep    2s
    log to console    Check msgs in Control Plane logs
    Check msg in Control Plane logs  UEContextReleaseCommand::rrcReject
    sleep    2s
    Check msg in Control Plane logs  InitialULRRCMessageTransfer::rrcResumeRequest1
    sleep    2s
    DCAP Disconnect To gNB
###### PART 2 check in cell trace logs #########
    Mkdir PC Emil
    log to console    Initiate Dcap
    Initiate Dcap
    log to console    sleep 20s
    sleep    20s
    log to console    DCAP Connect To gNB
    DCAP Connect To gNB
    log to console     BuiltIn.Log without cell argument
    BuiltIn.Log    without cell argument
    log to console    Start Log Via DCAP vducelltrace
    Start Log Via DCAP  vducelltrace
    log to console    sleep 10s
    sleep    10s

    log to console     Egate cmd=SET_AMF_TO_SEND
    Execute Egate Command    cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS}
    log to console     Egate cmd=set_pdu_param ue=2 pdu=1 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=2 pdu=1 trf_type=internal
    log to console     Egate register ue_id=2
    Execute Egate Command     cmd=ue_register id=2
    Sleep  2s
#    log to console     start trace
#    Execute Egate Command    cmd=${start_trace}
#    Sleep  5s
    log to console     Egate cmd=ue_pdu_session_setup ue=2 pdu=1 nwslice=1 gw=2
    Execute Egate Command    cmd=ue_pdu_session_setup ue=2 pdu=1 nwslice=1 gw=2
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
    Execute Egate Command    cmd=trf_data_stop ue=2 pdu=1 qfi=1 dir=dl
    log to console    sleep 180S
    Sleep  180s
    log to console     upd_maxNumOfRrcSA
    Test Case Setup    reach_on_air=no   config=&{upd_maxNumOfRrcSA}    reboot_after_config=no
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
    log to console    sleep 20S
    Sleep  20s
    log to console    Stop Log Via DCAP vducelltrace test_scenario=vducelltrace
    Stop Log Via DCAP  vducelltrace  test_scenario=vducelltrace
    Test Case Setup    reach_on_air=no   config=&{upd_maxNumOfRrcSA275}    reboot_after_config=no
    Execute Egate Command    cmd=ue_deregister id=2 by=ue ue_deregister_type=switch_off
    Log to console    ue_deregistered id=2

    Copy DCAP Logs on VM in classical path
    ${tl_name}      CB010413_Keywords.Get TL hostname
    ${source_dir_5gm}    Set Variable    /${OUTPUT_DIR}/ipcaptureExtracted/5gm
    ${source_dir_lcbin}    Set Variable    /${OUTPUT_DIR}/ipcaptureExtracted/lcbin
    ${user}    Set Variable    NOKLAB\\rfsharing
    ${ip}    Set Variable    10.5.53.88
    ${destination_5gm}    Set Variable    C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}\\\\5gm\\\
    ${destination_lcbin}    Set Variable    C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}\\\\lcbin\\\\
    ${password}    Set Variable    Nokia2022!@1
#    log to console    Copy Files To Windows 5gm
#    Copy Files To Windows KW1    ${source_dir_5gm}    ${user}    ${ip}      ${destination_5gm}    ${password}
    log to console    Copy Files To Windows lcbin
    Copy Files To Windows KW2    ${source_dir_lcbin}    ${user}    ${ip}    ${destination_lcbin}    ${password}
    Sleep  2s
#    log to console    Convert 5gm Files To Csv
#    Convert 5gm Files To Csv
    log to console    Convert lcbin Files To Csv
    Convert lcbin Files To Csv
    Sleep  2s
    log to console    Send csv from PC to VM
    Send csv from PC to VM
    Sleep  2s

    log to console    Check msgs in Cell Trace logs
    log to console    UeCtxSetupTraceRecord::ueCtxSetupRecord,result miscFailure
    Check msg in Cell Trace logs  UeCtxSetupTraceRecord::ueCtxSetupRecord,result miscFailure
    Sleep  2s
    log to console    UeCtxSetupTraceRecord::ueCtxSetupRecord,initialUeRrcMessageTransferSndTime
    Check msg in Cell Trace logs  UeCtxSetupTraceRecord::ueCtxSetupRecord,initialUeRrcMessageTransferSndTime
    Sleep  2s
    log to console    UeCtxSetupTraceRecord::ueCtxSetupRecord,gnb-cu-ue-f1ap-Id
    Check msg in Cell Trace logs  UeCtxSetupTraceRecord::ueCtxSetupRecord,gnb-cu-ue-f1ap-Id
    Sleep  2s
    log to console    UeCtxSetupTraceRecord::ueCtxSetupRecord,gnb-du-ue-f1ap-Id
    Check msg in Cell Trace logs  UeCtxSetupTraceRecord::ueCtxSetupRecord,gnb-du-ue-f1ap-Id
    Sleep  2s

    Test Case Setup    reach_on_air=no   config=&{upd_maxNumOfRrcSA275}    reboot_after_config=no
    Execute Egate Command    cmd=ue_deregister id=2 by=ue ue_deregister_type=switch_off
    Log to console    ue_deregistered id=2
    Execute Egate Command    cmd=reset
    Log to console    Egate reseted
    Run     sudo killall edaemon egate
    Log to console    Egate killed
    sleep    5s


*** Keywords ***
Copy Files To Windows KW1
    [Arguments]    ${source_dir_5gm}    ${user}    ${ip}    ${destination_5gm}    ${password}
    Copy Files To Windows1    ${source_dir_5gm}    ${user}    ${ip}    ${destination_5gm}    ${password}
Copy Files To Windows KW2
    [Arguments]    ${source_dir_lcbin}    ${user}    ${ip}    ${destination_lcbin}    ${password}
    Copy Files To Windows2    ${source_dir_lcbin}    ${user}    ${ip}    ${destination_lcbin}    ${password}

#    Execute Egate Command    cmd=ue_deregister id=2 by=ue ue_deregister_type=switch_off
#    Log to console    ue_deregistered id=2
#    Execute Egate Command    cmd=reset
#    Log to console    Egate reseted
#    Run     sudo killall edaemon egate
#    Log to console    Egate killed
#    sleep    5s
#
