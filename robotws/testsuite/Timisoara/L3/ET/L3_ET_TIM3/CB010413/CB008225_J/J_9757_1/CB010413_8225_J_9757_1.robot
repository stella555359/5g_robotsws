*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Dan Moldovan
...              :maintainer: Dan Moldovan

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
Suite Teardown    Testline Teardown
Test Teardown    Run Keywords     DCAP Disconnect To gNB
#...               AND     log to console    TEST
...               AND     Cleanup EMil dir


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
${TC_Name}      UUSCB008225_J_9757_1_Active_UEs_configured_per_cell_with_periodic_measurements_during_end_of_periodic_measurements_for_SA

@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
&{CONFIG_del_TCE}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${CU_Delta_DEL_TCE}   delta_vdu=${DU_Delta_DEL_TCE}
${CU_Delta_DEL_TCE}     ${CURDIR}/configs/CU_Delta_DEL_TCE.xml
${DU_Delta_DEL_TCE}     ${CURDIR}/configs/DU_Delta_DEL_TCE.xml
&{CONFIG_DCAP}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${CU_Delta_DCAP}   delta_vdu=${DU_Delta_DCAP}
${CU_Delta_DCAP}     ${CURDIR}/configs/CU_Delta_DCAP.xml
${DU_Delta_DCAP}     ${CURDIR}/configs/DU_Delta_DCAP.xml
#
&{CONFIG_no_ran_sh}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${no_ran_sh_VCU}   delta_vdu=${no_ran_sh_VDU}
${no_ran_sh_VCU}     ${CURDIR}/configs/CU_Delta_8225_no_ran_sharing.xml
${no_ran_sh_VDU}     ${CURDIR}/configs/DU_Delta_8225_no_ran_sharing.xml
&{DEL_NRMTRACECU}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DEL_NRMTRACECU_VCU}   delta_vdu=${DEL_NRMTRACECU_VDU}
${DEL_NRMTRACECU_VCU}     ${CURDIR}/configs/CU_Delta_DEL_NRMTRACECU.xml
${DEL_NRMTRACECU_VDU}     ${CURDIR}/configs/DU_Delta_DEl_ipif1.xml
&{Create_MDT_PCMD}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${Create_MDT_PCMD_VCU}   delta_vdu=${Create_MDT_PCMD_VDU}
${Create_MDT_PCMD_VCU}     ${CURDIR}/configs/CU_DELTA_MDT_PCMD.xml
${Create_MDT_PCMD_VDU}     ${CURDIR}/configs/DU_Delta_Create_ipif1.xml
&{Create_NRMTRACECU}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${Create_NRMTRACECU_VCU}   delta_vdu=${Create_NRMTRACECU_VDU}
${Create_NRMTRACECU_VCU}     ${CURDIR}/configs/CU_Delta_create_NRMTRACECU-NRRESOURCECU.xml
${Create_NRMTRACECU_VDU}     ${CURDIR}/configs/DU_Delta_Create_ipif1.xml
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS}=    amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                        ue_specific_drx=64 periodic_registration_update_timer=5:1min plmn_id=311:489 tac_id=200
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS2}=    amf_ue_ics_param id=1 ue=2 core_network_assistance_info=on ue_identity_index_value=1
...                                                        ue_specific_drx=64 periodic_registration_update_timer=5:1min plmn_id=311:489 tac_id=200
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD}=    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200

*** Test Cases ***
UUSCB008225_J_9757_1_Active_UEs_configured_per_cell_with_periodic_measurements_during_end_of_periodic_measurements_for_SA
    [Documentation]    This test case tests the gNB behavior for UE in RRC_CONNECTED state that is successfully
    ...                transitioned to RRC_INACTIVE state based on the UE inactivity after Initial Context Setup.
    ...                Successful suspend procedure.
    ...                5G_CP_ARC_ARG_9757

    [Setup]    Run Keywords     Log to console      Start test setup
    ...     AND    Test Case Setup    reach_on_air=no   config=&{CONFIG_del_TCE}    reboot_after_config=no
    ...     AND    Test Case Setup    reach_on_air=no   config=&{CONFIG_DCAP}    reboot_after_config=no
    ...     AND    Test Case Setup    reach_on_air=no   config=&{DEL_NRMTRACECU}    reboot_after_config=no
    ...     AND    Test Case Setup    reach_on_air=no   config=&{Create_MDT_PCMD}    reboot_after_config=no
    ...     AND    Test Case Setup    reach_on_air=no   config=&{CONFIG_no_ran_sh}    reboot_after_config=yes
    ...     AND    Test Case Setup    reach_on_air=yes       reboot_after_config=no

    sleep    10s
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

    Execute Egate Command    cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD}
    log to console     Egate register ue_id=1
    Execute Egate Command     cmd=ue_register id=1
    Sleep  2s
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Sleep  5s
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1

    log to console     Egate register ue_id=2
    Execute Egate Command     cmd=ue_register id=2
    Sleep  2s
    Execute Egate Command    cmd=set_pdu_param ue=2 pdu=1 trf_type=internal
    Sleep  5s
    Execute Egate Command    cmd=ue_pdu_session_setup ue=2 pdu=1 nwslice=1 gw=2
    #Wait for release
    Sleep  105s

#    stop tcpdump on remote interface
    log to console    Stop Log Via DCAP vducelltrace test_scenario=vcucelltrace
    Stop Log Via DCAP  vcucelltrace  test_scenario=vcucelltrace
#    Verify tshark
#    ...     alias=tshark_testcase_aic
#    ...     packet_filter=${ResumeRequest1}
#    ...     pass_criteria= >=1
#    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
#    log to console     checked ResumeRequest1
#    sleep    5s
#    Verify tshark
#    ...     alias=tshark_testcase_aic
#    ...     packet_filter=${rrcResumeComplete}
#    ...     pass_criteria= >=1
#    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
#    log to console     checked rrcResumeComplete
#    sleep    5s
#    log to console     stop TCPDUMP
#    stop tcpdump on remote interface

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
    log to console    MeasurementReport::measurementReport
    Check msg in Cell Trace logs  MeasurementReport::measurementReport

*** Keywords ***
Copy Files To Windows KW1
    [Arguments]    ${source_dir_5gm}    ${user}    ${ip}    ${destination_5gm}    ${password}
    Copy Files To Windows1    ${source_dir_5gm}    ${user}    ${ip}    ${destination_5gm}    ${password}
Copy Files To Windows KW2
    [Arguments]    ${source_dir_lcbin}    ${user}    ${ip}    ${destination_lcbin}    ${password}
    Copy Files To Windows2    ${source_dir_lcbin}    ${user}    ${ip}    ${destination_lcbin}    ${password}


##    Set AMF To Send CNAI IE In UE Initial Context Setup Request
##    Attach Ue And Establish PDU Session    ue_id=1    gw_id=1
##    Attach UE And Establish PDU Session And Wait For Release    ue_id=2    gw_id=2
##    Stop DCAP trace and download logs

#    ${MDT_list1}   set variable      UEs with MDT enabled is 1
#    ${MDT_list2}   set variable      UEs with MDT enabled is 2
#    Syslog should contain MDT List message    ${MDT_list1}
#    Syslog should NOT contain MDT List message   ${MDT_list2}
#    Convert 5gm Files To Csv
#    Convert lcbin Files To Csv
#    Check msg in Cell Trace logs  MeasurementReport::measurementReport
