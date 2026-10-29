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

#Resource     ../../../resourcesBLR/NPS/SWENG/robot/Connect.robot
Resource     ../../../resourcesBLR/robot/common_log_collection.robot
Library      ../../../resourcesBLR/NPS/SWENG/python_libs/luashark_tools.py
#Library      ../../../resourcesBLR/NPS/SWENG/python_lilbs/luashark_tools.analyzer       WITH NAME       analyze

Resource      ../../../resourcesKRK/krk3_common/main_vran.robot
#Resource      ../../../resourcesKRK/krk3_common/aic/aic_common_resources.robot
#Resource      ../../../resourcesKRK/tl_init.robot

Resource     CB010413_Keywords.robot
Library      copy_unix_to_win.py

#Library      ta5g_tshark
#Library      ta5g_ue_mobility
#Library      ute_tshark
#Variables    ta5g_global_var


#Library         SSHLibrary    WITH NAME    sshlib
#Resource     ../../CB008225_J/dcap_new.robot
#Library     ../../../resources/python/dcap.py

Suite Setup      Testline Setup
##                 ...    Testline Setup
#Suite Setup    Run Keywords     Initiate Dcap
#...            AND              Testline Setup
#Suite Teardown    DCAP Disconnect To gNB
#Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes
#Test Teardown     Cleanup EMil dir
Test Teardown    Run Keywords     DCAP Disconnect To gNB
...               AND     Cleanup EMil dir

*** Variables ***

#${labpcname}=                                            NOKLAB\\rfsharing
#${labpcpass}=                                            Nokia2022!@1
#${labpcip}=                                              10.5.53.88
#${alias}=                                                sshpc
${UTE_SSH_IP}=                                           ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_SSH_USER_NAME}=                                    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_SSH_PASSWORD}=                                     ${tl.test_pc.default_ssh_connection_details.password}
${IPCAPTURE_TO_TXT}=   tshark -r ${OUTPUT DIR}/ipcaptureExtracted/* -Y 'nr-rrc.c1 == 0' -T text -o ntrstr.port:49148 -o
...  ntrstr.defragment:TRUE > ${OUTPUT DIR}/ipcaptureExtracted/ipcapture_to_txt.txt
${destination}       C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\

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
&{Create_MDT_PCMD}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${Create_MDT_PCMD_VCU}   delta_vdu=${Create_MDT_PCMD_VDU}
${Create_MDT_PCMD_VCU}     ${CURDIR}/configs/CU_DELTA_MDT_PCMD.xml
${Create_MDT_PCMD_VDU}     ${CURDIR}/configs/DU_Delta_Create_ipif1.xml
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS}=    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                  ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
${log_path}    /home/ute/dcaplogs
${TS1}          stop1
${TS2}          stop2
${TC_Name}    USCB008225_J_B01_B_B1_1_gNB_CU_UeDuConnectivity_Record_from_gNB_CU_CP_during_RRC_Connected_to_RRC_Inactive_transition
#${NGAP_RESET}    ngap.NGReset_element
#${NGAP_RESET_ACKNOWLEDGE}    ngap.NGResetAcknowledge_element
#${NG_FULL_RESET}   ngap.NGReset_element && ngap.nG_Interface == 0
#@{PM_OBJECTS_LIST}           NNGCB



*** Test Cases ***
USCB008225_J_B01_B_B1_1_gNB_CU_UeDuConnectivity_Record_from_gNB_CU_CP_during_RRC_Connected_to_RRC_Inactive_transition
    [Documentation]    This test case describes NG Full Reset initiated by gNB
    ...                5G_RAN_USR_RRM_1229
    ...                Test case checks:
    ...                - if counters NG_CU_RESET_ACK_RCV and NG_CU_RESET_REQ_SENT are incremented properly
    ...                author:    Cristinel Sava    config=&{CONFIG_no_ran_sh}
    ...                contact:   cristinel.sava@nokia.com
    [Setup]    Run Keywords     Log to console      Start test setup
    ...     AND    Test Case Setup    reach_on_air=no    reboot_after_config=no
#    ...     AND    Test Case Setup    reach_on_air=no   config=&{CONFIG_del_TCE}    reboot_after_config=no
#    ...     AND    Test Case Setup    reach_on_air=no   config=&{CONFIG_DCAP}    reboot_after_config=no
#    ...     AND    Test Case Setup    reach_on_air=no   config=&{DEL_NRMTRACECU}    reboot_after_config=no
#    ...     AND    Test Case Setup    reach_on_air=no   config=&{Create_MDT_PCMD}    reboot_after_config=no
#    ...     AND    Test Case Setup    reach_on_air=yes   config=&{CONFIG_no_ran_sh}  reboot_after_config=yes
    ...     AND    Test Case Setup    reach_on_air=yes  reboot_after_config=no

#    Get TL hostname
    Mkdir PC Emil
    log to console    Initiate Dcap
    Initiate Dcap
    log to console    sleep 20s
    sleep    20s
    log to console    DCAP Connect To gNB
    DCAP Connect To gNB
    log to console     BuiltIn.Log without cell argument
    BuiltIn.Log    without cell argument
#    log to console     Start Log Via DCAP vducontrolplane
#    Start Log Via DCAP  vducontrolplane
#    log to console     Start Log Via DCAP vcucontrolplane
#    Start Log Via DCAP  vcucontrolplane
#    log to console    sleep 10s
#    sleep    10s
    log to console    Start Log Via DCAP vcucelltrace
    Start Log Via DCAP  vcucelltrace
    log to console    sleep 10s
    sleep    10s
    log to console    Start Log Via DCAP vducelltrace
    Start Log Via DCAP  vducelltrace
    log to console    sleep 10s
    sleep    10s
    log to console     Egate cmd=SET_AMF_TO_SEND
    Execute Egate Command     cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS}
#    Set AMF To Send CNAI IE In UE Initial Context Setup Request    command=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS}
    log to console     Egate register ue_id=2
    Execute Egate Command     cmd=ue_register id=2
    Sleep  2s
    log to console     Egate cmd=set_pdu_param ue=2 pdu=1 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=2 pdu=1 trf_type=internal
    Sleep  1s
    log to console     Egate cmd=ue_pdu_session_setup ue=2 pdu=1 nwslice=1 gw=2
    Execute Egate Command    cmd=ue_pdu_session_setup ue=2 pdu=1 nwslice=1 gw=2
    log to console    sleep 125S
    Sleep  125s
#    log to console    Stop Log Via DCAP vducontrolplane
#    Stop Log Via DCAP  vducontrolplane  test_scenario=vducontrol
#    log to console    sleep 12S
#    Sleep  125s

#    log to console    Stop Log Via DCAP vcucontrolplane
#    Stop Log Via DCAP  vcucontrolplane  test_scenario=vcucontrol
    log to console    Stop Log Via DCAP vcucelltrace test_scenario=vcucelltrace
    Stop Log Via DCAP  vcucelltrace  test_scenario=vcucelltrace
    log to console    Stop Log Via DCAP vducelltrace test_scenario=vducelltrace
    Stop Log Via DCAP  vducelltrace  test_scenario=vducelltrace

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
    log to console    Copy Files To Windows lcbin
    Copy Files To Windows KW2    ${source_dir_lcbin}    ${user}    ${ip}    ${destination_lcbin}    ${password}
    log to console    Convert 5gm Files To Csv
    Convert 5gm Files To Csv
    log to console    Convert lcbin Files To Csv
    Convert lcbin Files To Csv
    log to console    Send csv from PC to VM
    Send csv from PC to VM
    log to console    Check msgs in Control Plane logs
#    Check msg in Control Plane logs  InitialContextSetupRequest::CoreNetworkAssistanceInformationForInactive
#    Check msg in Control Plane logs  UEContextReleaseComplete::UEContextReleaseComplete
#    Check msg in Control Plane logs  BearerContextModificationRequest::BearerContextStatusChange : suspend
#    Check msg in Control Plane logs  BearerContextModificationResponse::System-BearerContextModificationResponse
#    Check msg in Control Plane logs  UEContextReleaseCommand::radioNetwork : normal-release
#    Check msg in Control Plane logs  rrcRelease::suspendConfig
    log to console    Check msgs in Cell Trace logs
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,releaseData
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,gnb-du-Ids
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,gnb-cu-ue-f1ap-Id
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,gnb-du-ue-f1ap-Id
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,ueCtxReleaseCmdSndTime
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,ueCtxReleaseCmplRcvTime
    Check msg in Cell Trace logs  MeasurementReport::measurementReport


*** Keywords ***
Copy Files To Windows KW1
    [Arguments]    ${source_dir_5gm}    ${user}    ${ip}    ${destination_5gm}    ${password}
    Copy Files To Windows1    ${source_dir_5gm}    ${user}    ${ip}    ${destination_5gm}    ${password}
Copy Files To Windows KW2
    [Arguments]    ${source_dir_lcbin}    ${user}    ${ip}    ${destination_lcbin}    ${password}
    Copy Files To Windows2    ${source_dir_lcbin}    ${user}    ${ip}    ${destination_lcbin}    ${password}



