*** Settings ***
Force Tags        CLOUD_5G_I_LOO_AP_LOOO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED


Documentation
...
...  AUTHOR          :   Sagarika.V  sagarika.s_v@nokia.com
...  MAINTAINER      :   Sagarika.V  sagarika.s_v@nokia.com
...  INTRODUCTION    :   CNI-109585 BWP_switch_success_for_Multiple_UE_supporting_smallBWP_fromTo_psBWP
...  TEST SET NAME   :   CNI109585_A_7_CB008541_BWP_switch_success_for_Multiple_UE_supporting_smallBWP_fromTo_psBWP_robustness
...  TESTING SPLIT   :   Split-A
...  REFERENCES      :   CNI-109585-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_25855

Resource         CNI109585_resource.robot
Library          ta5g_enb
Library          ta5g_pm_counters
Resource         ../../T09/5GC000937/resources/MultiUe_MultiDRB_Wrapper_Keyword.robot
Resource         ../../../resources/robot/counter_benchmark_resource.robot

Suite Setup         Run keywords    Suite setup from scratch
...                 AND    CNI109585_resource.Perform SCF Delta Commissioning with MULTILBWP_CHANGES_TMO.json
...                 AND    sleep    180s
...                 AND    CNI109585_resource.Perform SCF Delta Commissioning with CELL3_FREQ_CHANGES_TMO.json
...                 AND    sleep    150s
...                 AND    CNI109585_resource.Perform SCF Delta Commissioning with delta_g.json
...                 AND    sleep    100s
...                 AND    CNI109585_resource.Perform SCF Delta Commissioning with RRC_Inactive.json
...                 AND    sleep    100s
...                 AND    CNI109585_resource.Perform SCF Delta Commissioning with Vonr_GRB.json
...                 AND    sleep    100s
...                 AND    Prepare TL with IPHY file change
...                 AND    Reboot gNB System Module from Console and check Airscale is ready
...                 AND    Configure eth3 IP
...                 AND    Load CFG and verify cell status   ${wts_cfg_file}     1      4


Suite Teardown      Run Keyword And Ignore Error    Get Sos Report

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts/TMO_basic_setup.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${Start_UE_ID_LBWP}    3
${End_UE_ID_LBWP}      3
${UE_ID_LBWP}    3
${UE_ID_SBWP}    4
${Start_UE_ID_SBWP}    4
${End_UE_ID_SBWP}      4
${UE_ID}    1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${QFI_ID1}     1
${TRF_ID1}     1
${Q_O_ADD1}    1
${Target_Cells}    1
${epc_log_path}    /tmp/
${AP_XML}            ${CURDIR}/config/SCF/New_Iphy_file.xml
&{Vonr_qos}       5=5    6=1
&{qfi_ids_vonr}        5=2    1=3
&{GBR_qos}        7=4
&{qfi_ids_gbr}    4=2
${target_dir}=    /home/ute/Desktop/
${counter_json_file}=    ${CURDIR}/config/counter_cni109585.json
${host}=   192.168.255.129
${user}=   Nemuadmin
${password}=   nemuuser
${git_path}=   https://gitlabe1.ext.net.nokia.com/BTS_TOOLS/counter_benchmarking/-/blob/main/Bangalore/VRF_BLR1/T09/CNI109585_Counter_Benchmking.xlsx

*** Test Cases ***
[1]CNI109585_A_7_CB008541_BWP_switch_success_for_Multiple_UE_supporting_smallBWP_fromTo_psBWP_robustness
    [Documentation]   Test Case Configured for NRCELL-1
    [Tags]   TC01
    Set test variable      ${LOG_PATH}
    ${TEST_LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${TEST_LOG_PATH}
    log to console   Suite setup successful ...
    Start log   btslog
    Run Keyword and continue on failure    Attach ues with ues for PSBWP switch and Validate IncomingPsBwpCounter
    Run Keyword and continue on failure    Trigger data for BWP switch from PsBwp to SmallBwp and Validate IncomingSmallBwp OutgoingPsBwp Counters
    Run Keyword and continue on failure    Deregister ues and Validate IncomingSmallBwp OutgoingPsBwp IncomingPsBwp OutgoingSmallBwp Counters
    Stop log   btslog      test_scenario=attach_log
    [Teardown]       Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] CNI109585B_11_CB008954_largeToPsBWP_SwitchFailure_scanning_recovery_succes
    [Documentation]   Test Case Configured for NRCELL-3
    [Tags]   TC02
    Set test variable      ${LOG_PATH}
    ${TEST_LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${TEST_LOG_PATH}
    log to console   Suite setup successful ...
    Run Keyword and continue on failure    Start log   btslog
    Scanning And Recovery successful    3    4
    Scanning And Recovery successful SBWP    5    6
    Scanning And Recovery failure     7
    Run Keyword and continue on failure    Validate Counters For Scanning And Recovery Failure SBWP
    Run Keyword and continue on failure    Stop log   btslog      test_scenario=attach_log
    [Teardown]       Link SCOUT SCF to Configuration ID for Reporting

[1]CB013684_G_10_PMQAP_NRCell_level_MAC_DL_Throughut_Distribution_BIN_counters_cfgThptDistUpdate_perSec
    [Documentation]   Test Case Configured for NRCELL-2
    [Tags]   TC01
    Set test variable      ${LOG_PATH}
	Start Log   btslog
    Start_Fetching_Counter_Values
    MultiUe MultiDBR registration Should Be Successful
    Verify The Counter DL UL    500    40
    Stop_Fetching_Counter_Values
    Run Keyword And Continue On Failure    Collect_Counter_Logs      ${host}     ${user}      ${password}
	...     ${target_dir}    ${counter_json_file}         ${git_path}
    Sleep    60s
    Send High Data
	Check Counters    perburst=${False}
    Deregister Multiple Ues    8    8
    Wait For Next Full Pm Interval
    CNI109585_resource.Perform SCF Delta Commissioning with delta_g_burst.json
    sleep    10s
    Register UE and Send High Data
    Check Counters   perburst=${True}
    Deregister Multiple Ues    8    8
    Ue RRC Inactive state should be successful    38    40    310    260
	${syslog_path}    Stop Log    btslog    test_scenario=syslog1
    Stop log    snapshot  test_scenario=snap
    [Teardown]    Run keywords       Link SCOUT SCF to Configuration ID for Reporting
    ...    AND       Check resource hanging

*** Keywords ***
Attach ues with ues for PSBWP switch and Validate IncomingPsBwpCounter
    wts_sim_keywords.UE Register should be Successful     ue_id=${UE_ID}
    wts_sim_keywords.Trigger data    ue_id=${UE_ID}     dir=dl		pdu_id=${Pdu_session_ID}     trf_id=1		qfi=${QFI_ID}  Traffic_unit=mbps
    ...     	traffic_rate=1
    wts_sim_keywords.Trigger data    ue_id=${UE_ID}     dir=ul       pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=mbps
    ...         traffic_rate=1
    log to console   attach and data trigger complete for all ues ...
    Wait For Next Full Pm Interval
    Start log  biptaf
    wts_sim_keywords.Trigger data    ue_id=${UE_ID}     dir=dl      pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=kbps
    ...         traffic_rate=10
    wts_sim_keywords.Trigger data    ue_id=${UE_ID}     dir=ul       pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=kbps
    ...         traffic_rate=10
    log to console    Traffic reduced to kbps ...
    Run Keyword and continue on failure    Stop log   biptaf
    Run Keyword and continue on failure    Validate Counters For Bwp switch

Trigger data for BWP switch from PsBwp to SmallBwp and Validate IncomingSmallBwp OutgoingPsBwp Counters
    wts_sim_keywords.Trigger data    ue_id=${UE_ID}     dir=dl      pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=mbps
    ...          traffic_rate=1
    wts_sim_keywords.Trigger data    ue_id=${UE_ID}     dir=ul       pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=mbps
    ...      traffic_rate=1
    log to console    Traffic increased to Mbps ...
    Sleep    10s
    Run Keyword and continue on failure    Validate Counters For Bwp switch To SmallBWP

Deregister ues and Validate IncomingSmallBwp OutgoingPsBwp IncomingPsBwp OutgoingSmallBwp Counters
    Wait For Next Full Pm Interval
    wts_sim_keywords.UE Deregister should be Successful    ue_id=1
    Run Keyword and continue on failure    Validate Counters For Deregister Ues
    log to console    Dregister of Ues Completed  ...


MultiUe MultiDBR registration Should Be Successful
    Register ALL Ues and Send Low data    Start_ue=8    End_ue=37
    Log to console    Adding Vonr Ues
    QosFlow addition should be Successful     9   11      ${Vonr_qos}     ${qfi_ids_vonr}
    QosFlow addition should be Successful     12   15        ${GBR_qos}     ${qfi_ids_gbr}
    Trigger Multiue Data

Validate Counters For Deregister Ues
    Wait For Next Full Pm Interval
    ${pm_counters}    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55351C01005    0         INCOM_BWP_SWITCH_CBWP3
    ...    M55351C01006    0         INCOM_BWP_SWITCH_CBWP4
    ...    M55351C01009    0         OUTGO_BWP_SWITCH_CBWP3
    ...    M55351C01010    0         OUTGO_BWP_SWITCH_CBWP4
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

Validate Counters For Bwp switch Reregister Ues
    Wait For Next Full Pm Interval
    ${pm_counters}    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55351C01005    1         INCOM_BWP_SWITCH_CBWP3
    ...    M55351C01006    1         INCOM_BWP_SWITCH_CBWP4
    ...    M55351C01009    1         OUTGO_BWP_SWITCH_CBWP3
    ...    M55351C01010    1         OUTGO_BWP_SWITCH_CBWP4
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

Verify The Counter DL UL
    [Arguments]    ${DL_rate}    ${UL_rate}
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${PM_dir1}=      Get Latest Unpacked Full Pm Counters File
    ${DLG_06}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C01006    local_moid=NRCELL-2
    ${DLG_01}    Get Latest Pm Counter Value   filepath=${PM_dir1}    counter_id=M55310C01001    local_moid=NRCELL-2
    ${DLG_04}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C01004    local_moid=NRCELL-2
    ${DLG_06}=   convert to integer    ${DLG_06}
    ${DLG_01}=   convert to integer    ${DLG_01}
    ${DLG_04}=   convert to integer    ${DLG_04}
    ${DL_Primary}    Evaluate    ${DLG_04}+${DLG_06}+${DLG_01}
    ${DL_Primary}    Evaluate    ${DL_Primary}*8/300000000
    ${ULG_06}    Get Latest Pm Counter Value   filepath=${PM_dir1}    counter_id=M55310C03006    local_moid=NRCELL-2
    ${ULG_01}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C03001    local_moid=NRCELL-2
    ${ULG_04}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C03004    local_moid=NRCELL-2
    ${ULG_06}=   convert to integer    ${ULG_06}
    ${ULG_01}=   convert to integer    ${ULG_01}
    ${ULG_04}=   convert to integer    ${ULG_04}
    ${UL_Primary}    Evaluate    ${ULG_04}+${ULG_06}+${ULG_01}
    ${UL_Primary}    Evaluate    ${UL_Primary}*8/300000000
    Should be True    ${DL_Primary} > ${DL_rate}
    Should be True    ${UL_Primary} > ${UL_rate}

Trigger Multiue Data
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    16    30    Traffic_rate=mbps   dl_rate=1   pdu_id=1
    ...    trf_id=1   qfi_id=1
    Sleep   30s
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    16    30    Traffic_rate=mbps   ul_rate=1   pdu_id=1
    ...    trf_id=1   qfi_id=1
    Start Multi UE DL traffic with multiple trafficID     start_ue=31   end_ue=37    Traffic_rate=mbps    dl_trf_id=1    qfi_id=1    dl_rate_DL=100
    Start Multi UE UL traffic with multiple trafficID     start_ue=31   end_ue=37    Traffic_rate=mbps    ul_trf_id=1    qfi_id=1    ul_rate_UL=10

Send High Data
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=8      Traffic_rate=mbps     dl_rate=5    pdu_id=1   trf_id=1
    sleep  10s  reason=wait for data to stable

Register UE and Send High Data
    ${rnti}    wts_sim_keywords.UE Register should be Successful And Fetch RNTI    ue_id=8
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=8      Traffic_rate=mbps     dl_rate=5    pdu_id=1   trf_id=1
    sleep  10s  reason=wait for data to stable

Check Throughput
    [Arguments]    ${ue_id}=8   ${scell_idx}=0
    ${DATA_DL}    wts_sim_keywords.Get AVG DL DATA TRAFFIC For Given CC     ${ue_id}    ${scell_idx}
    Should be True    ${DATA_DL} > 5

Check Counters
    [Arguments]  ${perburst}
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counters}    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55353C00007    0-100000         DL_RLC_PDU_UE_TPUT_BIN4_PMQAP
    ...    M55353C00008    0-100000         DL_RLC_PDU_UE_TPUT_BIN5_PMQAP
    ...    M55353C00009    0-100000         DL_RLC_PDU_UE_TPUT_BIN6_PMQAP
    ...    M55353C00010    0-100000         DL_RLC_PDU_UE_TPUT_BIN7_PMQAP
    ...    M55353C00011    0-100000         DL_RLC_PDU_UE_TPUT_BIN8_PMQAP
    ...    M55353C00012    0-50000         DL_RLC_PDU_UE_TPUT_BIN9_PMQAP
    ...    M55353C00013    0-500         DL_RLC_PDU_UE_TPUT_BIN10_PMQAP
    ...    M55353C00014    0-500         DL_RLC_PDU_UE_TPUT_BIN11_PMQAP
    ...    M55353C00015    0-500         DL_RLC_PDU_UE_TPUT_BIN12_PMQAP
    ...    M55353C00016    0-500         DL_RLC_PDU_UE_TPUT_BIN13_PMQAP
    ...    M55353C00017    0-500         DL_RLC_PDU_UE_TPUT_BIN14_PMQAP
    ...    M55353C00018    0-500         DL_RLC_PDU_UE_TPUT_BIN15_PMQAP
    ...    M55353C00019    0-500         DL_RLC_PDU_UE_TPUT_BIN16_PMQAP
    ...    M55353C00020    0-500         DL_RLC_PDU_UE_TPUT_BIN17_PMQAP
    ...    M55353C00021    0-500         DL_RLC_PDU_UE_TPUT_BIN18_PMQAP
    ...    M55353C00022    0-500         DL_RLC_PDU_UE_TPUT_BIN19_PMQAP
    ...    M55353C00023    0-500         DL_RLC_PDU_UE_TPUT_BIN20_PMQAP
	...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters}
    Run Keyword if   ${perburst}==${True}   Expected Ranges of values per Bursts   ${pm_counters}
    ...   ELSE   Expected Ranges of values in Seconds   ${pm_counters}
    Show Counter values    ${pm_counters}

Expected Ranges of values in Seconds
    [Arguments]   ${pm_counters}
    Verify Last Counters In File
    ...    M55353C00004    0-5000      DL_RLC_PDU_UE_TPUT_BIN1_PMQAP
    ...    M55353C00005    0-5000         DL_RLC_PDU_UE_TPUT_BIN2_PMQAP
    ...    M55353C00006    0-50000         DL_RLC_PDU_UE_TPUT_BIN3_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters}

Expected Ranges of values per Bursts
    [Arguments]   ${pm_counters}
    Verify Last Counters In File
    ...    M55353C00004    0-9000      DL_RLC_PDU_UE_TPUT_BIN1_PMQAP
    ...    M55353C00005    0-15000      DL_RLC_PDU_UE_TPUT_BIN2_PMQAP
    ...    M55353C00006    0-50000      DL_RLC_PDU_UE_TPUT_BIN3_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters}

Show Counter values
    [Arguments]  ${pm_counters}
    ${DL_RLC_PDU_VOL_UE_TPUT_PMQAP}  ta5g_pm_counters.get_pm_counter_value   M55353C00002   PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...   ${pm_counters}
    ${DL_RLC_PDU_TIME_UE_TPUT_PMQAP}  ta5g_pm_counters.get_pm_counter_value   M55353C00003   PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...   ${pm_counters}
    ${DL_PDCP_VOL_UE_TPUT_PMQAP}  ta5g_pm_counters.get_pm_counter_value   M55352C01001   PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...   ${pm_counters}
    ${DL_PDCP_TIME_UE_TPUT_PMQAP}  ta5g_pm_counters.get_pm_counter_value   M55352C00001   PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...   ${pm_counters}
   ${DL_MAC_SDU_VOL_UE_TPUT}  ta5g_pm_counters.get_pm_counter_value  M55309C00002   PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...   ${pm_counters}
   ${DL_MAC_SDU_TIME_UE_TPUT}  ta5g_pm_counters.get_pm_counter_value   M55309C00003   PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...   ${pm_counters}

Scanning And Recovery successful
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR     ${UE_ID_1}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wts_sim_keywords.UE Register should be Successful     ue_id=${UE_ID_1}
    wts_sim_keywords.Trigger data    ue_id=${UE_ID_1}     dir=dl      pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=mbps
    ...    traffic_rate=1
    wts_sim_keywords.Trigger data    ue_id=${UE_ID_1}     dir=ul       pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=mbps
    ...       traffic_rate=1
    log to console   attach and data trigger complete for all ues ...
    Wait until the next Measurement Period starts
    Run Keyword and continue on failure    Start log  biptaf
    AP commands to Drop bwp switching DCIs SUE    profile_id=1    num_dci_drop=6     UE_ID=${UE_ID_1}
    wts_sim_keywords.Trigger data    ue_id=${UE_ID_1}     dir=dl      pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=kbps
    ...       traffic_rate=10
    wts_sim_keywords.Trigger data    ue_id=${UE_ID_1}     dir=ul       pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=kbps
    ...       traffic_rate=10
    log to console    Traffic reduced to kbps ...
    Run Keyword and continue on failure    Stop log   biptaf
    Run Keyword and continue on failure    Validate Counters For Scanning And Recovery Success
    END

Scanning And Recovery successful SBWP
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR     ${UE_ID_2}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wts_sim_keywords.UE Register should be Successful     ue_id=${UE_ID_2}
    wts_sim_keywords.Trigger data    ue_id=${UE_ID_2}     dir=dl      pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=mbps
    ...    traffic_rate=1
    wts_sim_keywords.Trigger data    ue_id=${UE_ID_2}     dir=ul       pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=mbps
    ...       traffic_rate=1
    log to console   attach and data trigger complete for all ues ...
    Wait until the next Measurement Period starts
    Run Keyword and continue on failure    Start log  biptaf
    AP commands to Drop bwp switching DCIs SUE    profile_id=1    num_dci_drop=6     UE_ID=${UE_ID_2}
    wts_sim_keywords.Trigger data    ue_id=${UE_ID_2}     dir=dl      pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=kbps
    ...       traffic_rate=10
    wts_sim_keywords.Trigger data    ue_id=${UE_ID_2}     dir=ul       pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=kbps
    ...       traffic_rate=10
    log to console    Traffic reduced to kbps ...
    Run Keyword and continue on failure    Stop log   biptaf
    Run Keyword and continue on failure    Validate Counters For Scanning And Recovery Success SBWP
    END

Scanning And Recovery failure
    [Arguments]    ${UE_ID}
    wts_sim_keywords.UE Register should be Successful     ue_id=${UE_ID}
    wts_sim_keywords.Trigger data    ue_id=${UE_ID}     dir=dl      pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=mbps
    ...    traffic_rate=1
    wts_sim_keywords.Trigger data    ue_id=${UE_ID}     dir=ul       pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=mbps
    ...       traffic_rate=1
    log to console   attach and data trigger complete for all ues ...
    Wait until the next Measurement Period starts
    Run Keyword and continue on failure    Start log  biptaf
    AP commands to Drop bwp switching DCIs Fail    1    2    2    9999    7    7
    wts_sim_keywords.Trigger data    ue_id=${UE_ID}     dir=dl      pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=kbps
    ...       traffic_rate=10
    wts_sim_keywords.Trigger data    ue_id=${UE_ID}     dir=ul       pdu_id=${Pdu_session_ID}     trf_id=1       qfi=${QFI_ID}  Traffic_unit=kbps
    ...       traffic_rate=10
    log to console    Traffic reduced to kbps ...
    Run Keyword and continue on failure    Stop log   biptaf

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI


