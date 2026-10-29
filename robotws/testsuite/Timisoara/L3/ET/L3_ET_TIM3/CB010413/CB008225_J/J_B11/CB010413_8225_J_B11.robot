*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristinel Sava
...              :maintainer: Cristinel Sava

Resource      ../../../resourcesKRK/krk3_common/main_vran.robot
Resource      ../../../resourcesKRK/krk3_common/aic/aic_common_resources.robot
#Resource    ../CB008225_Keywords.robot
Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      ute_tshark
Variables    ta5g_global_var
Resource    ../../../resourcesKRK/tl_init.robot
Library       ute_reporting_portal

Suite Setup       Testline Setup
#Suite Teardown    Testline Teardown
#Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes


*** Variables ***
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
&{Create_NRSTRACECU}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${Create_NRSTRACECU_VCU}   delta_vdu=${Create_NRSTRACECU_VDU}
${Create_NRSTRACECU_VCU}     ${CURDIR}/configs/CU_Delta_create_NRSTRACECU.xml
${Create_NRSTRACECU_VDU}     ${CURDIR}/configs/DU_Delta_create_NRSTRACECU.xml
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS}=    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                  ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
${start_trace}=    ng_ue_trace_start id=1 trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1
...                                                           ifaces_to_trace=NG-C,Uu,Xn-C,F1-C tce_ip=0.0.0.0 trace_depth=minimum
#${NGAP_RESET}    ngap.NGReset_element
#${NGAP_RESET_ACKNOWLEDGE}    ngap.NGResetAcknowledge_element
#${NG_FULL_RESET}   ngap.NGReset_element && ngap.nG_Interface == 0
#@{PM_OBJECTS_LIST}           NNGCB



*** Test Cases ***
USCB008225_J_B11_3_Activation_of_SBA_functionality
    [Documentation]    This test case describes NG Full Reset initiated by gNB
    ...                5G_RAN_USR_RRM_1229
    ...                Test case checks:
    ...                - if counters NG_CU_RESET_ACK_RCV and NG_CU_RESET_REQ_SENT are incremented properly
    ...                author:    Cristinel Sava
    ...                contact:   cristinel.sava@nokia.com
    [Setup]    Run Keywords     Log to console      Start test setup
    ...     AND    Test Case Setup    reach_on_air=no   config=&{CONFIG_del_TCE}    reboot_after_config=no
    ...     AND    Test Case Setup    reach_on_air=no   config=&{CONFIG_DCAP}    reboot_after_config=no
#    ...     AND    Test Case Setup    reach_on_air=no   config=&{DEL_NRMTRACECU}    reboot_after_config=no
    ...     AND    Test Case Setup    reach_on_air=no   config=&{Create_NRSTRACECU}    reboot_after_config=no
    ...     AND    Test Case Setup    reach_on_air=yes   config=&{CONFIG_no_ran_sh}    reboot_after_config=yes
#    ...     AND    sleep   120s
#    ...     AND    Test Case Sletup    reach_on_air=yes       reboot_after_config=no

    sleep    10s
    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    log to console    PORNESTE DCAP-ul MANUAL sleep 180s
    sleep    180s
    log to console     Egate cmd=SET_AMF_TO_SEND
    Execute Egate Command    cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS}
#    Set AMF To Send CNAI IE In UE Initial Context Setup Request    command=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS}
    log to console     Egate cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    log to console     Egate register ue_id=1
    ta5g_ue_mobility.Attach Ue    ue_id=1
    Sleep  5s
    log to console     start trace
    Execute Egate Command    cmd=${start_trace}
    Sleep  5s
    log to console     Egate cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
    log to console    sleep 105S
    Sleep  105s
    log to console     Egate resume
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=1 gnb=2 cell=1 msg=resume_request_1 cause=mo_Signalling
    log to console    sleep 10S
    Sleep  10s
    log to console     Egate cmd=set_pdu_param ue=1 pdu=2 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=2 trf_type=internal
    log to console    sleep 2S
    Sleep  2s
    log to console     Egate cmd=ue_pdu_session_setup ue=1 pdu=2 nwslice=1 gw=1
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=2 nwslice=1 gw=1
    log to console    sleep 100S
    Sleep  100s
#    ta5g_ue_mobility.Establish Pdu Session    ue_id=2    pdu_id=1    gw_id=2
#    Sleep  105s
#    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
#    Sleep  10s
#    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=1 gnb=2 cell=1 msg=resume_request_1 cause=mo_SMS
#    Sleep  10s
#    Execute Egate Command    cmd=ue_nr_rrc_resume id=1
#    Sleep  10s
#    Attach UE And Establish PDU Session And Wait For Release    ue_id=1    gw_id=1

#    Set Parameters For UE RRC Resume Request    ue_id=1    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mo_SMS
#    Sleep  10s
#    UE RRC Resume Request    ue_id=1
#    Sleep  100s
##    sleep    10s
    stop tcpdump on remote interface
#    Stop DCAP trace and download logs
#    Convert 5gm Files To Csv
#    Convert lcbin Files To Csv
        ### Check messages: RRCResume, RRCResumeRequest1, RRCResumeComplete and PCMD Records are successfully captured
#    Ipcapture should contain Resume_Request List message    ${ResumeRequest1}

    ### Check UeDuConnectivityTraceRecord
#    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,releaseData

#    Check msg in Cell Trace logs  RRCResumeComplete::rrcResumeComplete  #tbd after PR
##    ta5g_ue_mobility.Attach Ue    ue_id=1
#    Attach UE And Establish PDU Session And Wait For Release    ue_id=1    gw_id=1
#    sleep    5s
#    Set Parameters For UE RRC Resume Request    ue_id=1    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mo_SMS
#    Sleep  10s
#    UE RRC Resume Request    ue_id=1
#    Sleep  100s
#    ta5g_ue_mobility.Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
#    sleep    5s
#    log to console   check pid
#
#    ${hostname}=  Get vCU Namespace From Init File  gnb_index=0
#
#    log to console   resultat:${hostname}
#
#    ${vcu_ssh_connection_params}=  Get vCU K8s Master Node Ssh Connection Parameters From Init File
#    ...  gnb_index=0
#    ${ip_addr}=  Set Variable  ${vcu_ssh_connection_params['ip_addr']}
#    ${cmd1}=  set variable  sshpass -p system123 ssh core@${ip_addr} kubectl exec -n ${hostname} ute-${hostname}-cpif-0 -c c
#    ${cmd2}=  set variable  tr-${hostname}-cpif -- netstat -nlp | awk '$4~":'"38472"'"{ gsub(/\\/.*/,"",$7); print $7 }'
#    ${pid}    Run    ${cmd1}${cmd2}
#    ${cmd3}=  set variable  tr-${hostname}-cpif -- kill -9 ${pid}
#    log to console    KILL pid from VCU= ${pid}
#    Run    ${cmd1}${cmd3}
#    log to console    pid from VCU= ${pid}
#    Verify tshark
#    ...     alias=tshark_testcase_aic
#    ...     packet_filter=${NGAP_RESET}
#    ...     pass_criteria= >=1
#    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
#    sleep    5s
#    Log to console    Verify tshark NGAP_RESET_ACKNOWLEDGE
#    Verify tshark
#    ...     alias=tshark_testcase_aic
#    ...     packet_filter=${NGAP_RESET_ACKNOWLEDGE}
#    ...     pass_criteria= >=1
#    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
#    sleep    5s
#    Log to console    Verify tshark NG_FULL_RESET
#    Verify tshark
#    ...     alias=tshark_testcase_aic
#    ...     packet_filter=${NG_FULL_RESET}
#    ...     pass_criteria= >=1
#    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
#    sleep    5s
#    Log to console    Get Next vRAN XML PM Counters Files
#    &{pm_files_dict}    Get Next vRAN XML PM Counters Files
#    ...    vcu_pm_objects_list=@{PM_OBJECTS_LIST}    timeout=3600
#    Log to console    sleep 30s
#    Log to console    Verify M55119C00011 and M55119C00014
#    Verify vran last counters in files
#    ...  M55119C00011   1       NG_CU_RESET_REQ_SENT
#    ...  M55119C00014   1       NG_CU_RESET_ACK_RCV
#    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
#    ...  files_list=${pm_files_dict.vcu}
#    ...  measurement_type=NNGCB
#     sleep    10s
#    stop tcpdump on remote interface
#    Report pm counter    M55119C00011  1           Passed
#	Report pm counter    M55119C00014  1           Passed
#    Execute Egate Command    cmd=ue_deregister id=1 by=ue ue_deregister_type=switch_off
#    Log to console    ue_deregistered id=1
#    Execute Egate Command    cmd=reset
#    Log to console    Egate reseted
#    Run     sudo killall edaemon egate
#    Log to console    Egate killed
#    sleep    5s
