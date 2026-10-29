*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristinel Sava
...              :maintainer: Cristinel Sava

Resource     ../../../resourcesBLR/robot/common_log_collection.robot
Library      ../../../resourcesBLR/NPS/SWENG/python_libs/luashark_tools.py
Resource      ../../../resourcesKRK/krk3_common/main_vran.robot

Resource     CB010413_Keywords.robot
Library      copy_unix_to_win.py

Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      ute_tshark
Variables    ta5g_global_var

Resource    ../../../resourcesKRK/tl_init.robot

Suite Setup      Testline Setup
#Suite Teardown    Testline Teardown
Test Teardown    Run Keywords     DCAP Disconnect To gNB
#...               AND     log to console    TEST
...               AND     Cleanup EMil dir
#Suite Setup       Testline Setup
#Suite Teardown    Testline Teardown
#Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes


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
${TC_Name}      USCB008225_J_B09_1_Activation_of_MBA_functionality_Cell_Trace_and_PCMD

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
&{DEL_NRMTRACECU}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DEL_NRMTRACECU_VCU}   delta_vdu=${DEL_NRMTRACECU_VDU}
${DEL_NRMTRACECU_VCU}     ${CURDIR}/configs/CU_Delta_DEL_NRMTRACECU.xml
${DEL_NRMTRACECU_VDU}     ${CURDIR}/configs/DU_Delta_DEl_ipif1.xml
&{Create_NRMTRACECU}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${Create_NRMTRACECU_VCU}   delta_vdu=${Create_NRMTRACECU_VDU}
${Create_NRMTRACECU_VCU}     ${CURDIR}/configs/CU_Delta_create_NRMTRACECU-NRRESOURCECU.xml
${Create_NRMTRACECU_VDU}     ${CURDIR}/configs/DU_Delta_Create_ipif1.xml
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS}=    amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                        ue_specific_drx=64 periodic_registration_update_timer=5:1min plmn_id=311:489 tac_id=200
${ResumeRequest1}    nr-rrc.rrcResumeRequest1_element
${rrcResumeComplete}    nr-rrc.rrcResumeComplete_element

*** Test Cases ***
USCB008225_J_B09_1_Activation_of_MBA_functionality_Cell_Trace_and_PCMD
    [Documentation]    This test case describes NG Full Reset initiated by gNB
    ...                5G_RAN_USR_RRM_1229
    ...                Test case checks:
    ...                - if counters NG_CU_RESET_ACK_RCV and NG_CU_RESET_REQ_SENT are incremented properly
    ...                author:    Cristinel Sava
    ...                contact:   cristinel.sava@nokia.com
    [Setup]    Run Keywords     Log to console      Start test setup
    ...     AND    Test Case Setup    reach_on_air=no   config=&{CONFIG_del_TCE}    reboot_after_config=no
    ...     AND    Test Case Setup    reach_on_air=no   config=&{CONFIG_DCAP}    reboot_after_config=no
    ...     AND    Test Case Setup    reach_on_air=no   config=&{DEL_NRMTRACECU}    reboot_after_config=no
    ...     AND    Test Case Setup    reach_on_air=no   config=&{Create_NRMTRACECU}    reboot_after_config=no
    ...     AND    Test Case Setup    reach_on_air=yes   config=&{CONFIG_no_ran_sh}    reboot_after_config=yes
#    ...     AND    Test Case Setup    reach_on_air=yes       reboot_after_config=no

    sleep    10s
    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}

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
    log to console    Start Log Via DCAP vcucelltrace
    Start Log Via DCAP  vcucelltrace
    log to console    sleep 10s
    sleep    10s

    Execute Egate Command    cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS}
    Sleep  3s
    log to console     Egate cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Sleep  1s
    log to console     Egate register ue_id=1
    Execute Egate Command     cmd=ue_register id=1
    Sleep  2s
    log to console     Egate cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
    log to console     sleep 105S
    Sleep  105s
    log to console     nr_rrc_resume_request
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=1 gnb=2 cell=1 msg=resume_request_1 cause=mo_SMS
    Sleep  3s
    log to console     nr_rrc_resume_request
    Execute Egate Command    cmd=ue_nr_rrc_resume id=1
    log to console     sleep 100s
    Sleep  100s
    log to console    Stop Log Via DCAP vducelltrace test_scenario=vcucelltrace
    Stop Log Via DCAP  vcucelltrace  test_scenario=vcucelltrace
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${ResumeRequest1}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    log to console     checked ResumeRequest1
    sleep    5s
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${rrcResumeComplete}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    log to console     checked rrcResumeComplete
    sleep    5s
    log to console     stop TCPDUMP
    stop tcpdump on remote interface

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
    log to console    RRCResumeComplete::rrcResumeComplete
    Check msg in Cell Trace logs  RRCResumeComplete::rrcResumeComplete

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
