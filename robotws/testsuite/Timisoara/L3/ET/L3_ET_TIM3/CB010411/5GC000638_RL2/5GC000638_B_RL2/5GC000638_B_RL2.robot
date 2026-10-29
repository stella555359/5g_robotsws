*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristinel Sava
...              :maintainer: Cristinel Sava

Resource      ../../../resourcesKRK/krk3_common/main_vran.robot
Resource      ../../../resourcesKRK/krk3_common/aic/aic_common_resources.robot
Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      ute_tshark
Variables    ta5g_global_var
Resource    ../../../resourcesKRK/tl_init.robot
Library       ute_reporting_portal
Library      ta5g_pm_counters

Suite Setup       Testline Setup
Suite Teardown    Testline Teardown
Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes


*** Variables ***
@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
&{CONFIG_PM_5min}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU_5}   delta_vdu=${DELTA_VDU_5}
${DELTA_VCU_5}     ${CURDIR}/configs/CU_Delta_5min.xml
${DELTA_VDU_5}     ${CURDIR}/configs/DU_Delta_5min.xml
${NGAP_RESET}    ngap.NGReset_element
${NGAP_RESET_ACKNOWLEDGE}    ngap.NGResetAcknowledge_element
${NG_FULL_RESET}   ngap.NGReset_element && ngap.nG_Interface == 0
@{PM_OBJECTS_LIST}           NNGCB



*** Test Cases ***
5GC000638_B_NG_Full_Reset_gNB_Initiated_counters_test_case_3
    [Documentation]    This test case describes NG Full Reset initiated by gNB
    ...                5G_RAN_USR_RRM_1229
    ...                Test case checks:
    ...                - if counters NG_CU_RESET_ACK_RCV and NG_CU_RESET_REQ_SENT are incremented properly
    ...                author:    Cristinel Sava
    ...                contact:   cristinel.sava@nokia.com
    [Setup]    Run Keywords     Log to console      Start test setup
    ...     AND    Test Case Setup    reach_on_air=yes   config=&{CONFIG_PM_5min}    reboot_after_config=no

    sleep    10s
    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    sleep    5s
    ta5g_ue_mobility.Attach Ue    ue_id=4
    sleep    5s
    ta5g_ue_mobility.Establish Pdu Session    ue_id=4    pdu_id=1    gw_id=4
    sleep    5s
    log to console   check pid

    ${hostname}=  Get vCU Namespace From Init File  gnb_index=0

    log to console   resultat:${hostname}

    ${vcu_ssh_connection_params}=  Get vCU K8s Master Node Ssh Connection Parameters From Init File
    ...  gnb_index=0
    ${ip_addr}=  Set Variable  ${vcu_ssh_connection_params['ip_addr']}
    ${cmd1}=  set variable  sshpass -p system123 ssh core@${ip_addr} kubectl exec -n ${hostname} ute-${hostname}-cpif-0 -c c
    ${cmd2}=  set variable  tr-${hostname}-cpif -- netstat -nlp | awk '$4~":'"38472"'"{ gsub(/\\/.*/,"",$7); print $7 }'
    ${pid}    Run    ${cmd1}${cmd2}
    ${cmd3}=  set variable  tr-${hostname}-cpif -- kill -9 ${pid}
    log to console    KILL pid from VCU= ${pid}
    Run    ${cmd1}${cmd3}
    log to console    pid from VCU= ${pid}
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_RESET}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    5s
    Log to console    Verify tshark NGAP_RESET_ACKNOWLEDGE
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_RESET_ACKNOWLEDGE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    5s
    Log to console    Verify tshark NG_FULL_RESET
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NG_FULL_RESET}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    5s
    Log to console    Get Next vRAN XML PM Counters Files
    ${dirpath}  Set Variable   ${OUTPUT DIR}/Logs/${TEST NAME}/
    Create Directory    ${dirpath}/vcu
    Create Directory    ${dirpath}/vdu
    &{pm_files_dict}    get_next_vran_unpacked_full_pm_counters_files    output_dirpath=${dirpath}     timeout=3600      expected_interval=5
    Log to console    sleep 30s
    Log to console    Verify M55119C00011 and M55119C00014
    verify last counters in file
    ...  M55119C00011   1       NG_CU_RESET_REQ_SENT
    ...  M55119C00014   1       NG_CU_RESET_ACK_RCV
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...  file_path=${pm_files_dict.vcu}
    ...  measurement_type=NNGCB
     sleep    10s
    stop tcpdump on remote interface
    Report pm counter    M55119C00011  1           Passed
	Report pm counter    M55119C00014  1           Passed
    Execute Egate Command    cmd=ue_deregister id=2 by=ue ue_deregister_type=switch_off
    Log to console    ue_deregistered id=4
    Execute Egate Command    cmd=reset
    Log to console    Egate reseted
    Run     sudo killall edaemon egate
    Log to console    Egate killed
    sleep    5s
