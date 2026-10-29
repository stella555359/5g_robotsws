*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_TDD
...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation
...  AUTHOR          :   Sagarika sagarika.s_v@nokia.com
...  MAINTAINER      :   Sagarika sagarika.s_v@nokia.com
...  INTRODUCTION    :   The User Scenario is for Profile level DL Throughput Distribution counters.
...  TEST SET NAME   :   CB013684_G_10_PMQAP_NRCell_level_MAC_DL_Throughut_Distribution_BIN_counters_cfgThptDistUpdate_perSec
...  TESTING SPLIT   :   Split-G
...  REFERENCES      :   CB013684-CFAM
...  REQUIREMENT ID  :  5G_PM_839

Library          taf.transport.ssh           WITH NAME    taf_ssh
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../CB008541/resources/CB008541_Keywords.robot
Library          ta5g_enb
Library          ta5g_pm_counters
Library          taf.sw.scout    WITH NAME     scout

Suite Setup         Run keywords    Suite setup from scratch
...                 AND    Perform SCF Delta Commissioning with delta_g.json
#...                 AND    Sleep     130s
#...                 AND    Perform SCF Delta Commissioning with Counter_parameter.json
...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   2    2


Test Teardown     Run Keywords   Get Sos Report
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...   AND     Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_cell1_cni109585_cell2_cb013684.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${TRF_ID}    1
${Q_O_ADD1}    1
${epc_log_path}    /tmp/


*** Test Cases ***
[1]CB013684_G_10_PMQAP_NRCell_level_MAC_DL_Throughut_Distribution_BIN_counters_cfgThptDistUpdate_perSec
    Set test variable      ${LOG_PATH}
	Start Log   btslog
    Register UE and Send High Data
    Check Throughput    ue_id=2   scell_idx=0
	Check Counters    perburst=${False}
    wts_sim_keywords.MultiUE Deregister should be Successful    2   2
    Wait For Next Full Pm Interval
    Perform SCF Delta Commissioning with delta_g_burst.json
    Register UE and Send High Data
    Check Counters   perburst=${True}
    wts_sim_keywords.MultiUE Deregister should be Successful    2   2
	${syslog_path}    Stop Log    btslog    test_scenario=syslog1
    Stop log    snapshot  test_scenario=snap

*** Keywords ***
Register UE and Send High Data
    ${rnti}    wts_sim_keywords.UE Register should be Successful And Fetch RNTI    ue_id=2
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=2      Traffic_rate=mbps     dl_rate=5    pdu_id=1   trf_id=1
    #wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=2      Traffic_rate=mbps     ul_rate=5    pdu_id=1   trf_id=1
    sleep  10s  reason=wait for data to stable

Check Throughput
    [Arguments]    ${ue_id}=2   ${scell_idx}=0
    ${DATA_DL}    wts_sim_keywords.Get AVG DL DATA TRAFFIC For Given CC     ${ue_id}    ${scell_idx}
    Should be True    ${DATA_DL} > 5
    #${DATA_UL}    wts_sim_keywords.Get AVG UL DATA TRAFFIC For Given CC     ${ue_id}    ${scell_idx}
    #Should be True    ${DATA_UL} > 5


Check Counters
    [Arguments]  ${perburst}
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counters}    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55353C00007    0-5000         DL_RLC_PDU_UE_TPUT_BIN4_PMQAP
    ...    M55353C00008    0-5000         DL_RLC_PDU_UE_TPUT_BIN5_PMQAP
    ...    M55353C00009    0-5000         DL_RLC_PDU_UE_TPUT_BIN6_PMQAP
    ...    M55353C00010    0-5000         DL_RLC_PDU_UE_TPUT_BIN7_PMQAP
    ...    M55353C00011    0-5000         DL_RLC_PDU_UE_TPUT_BIN8_PMQAP
    ...    M55353C00012    0         DL_RLC_PDU_UE_TPUT_BIN9_PMQAP
    ...    M55353C00013    0         DL_RLC_PDU_UE_TPUT_BIN10_PMQAP
    ...    M55353C00014    0         DL_RLC_PDU_UE_TPUT_BIN11_PMQAP
    ...    M55353C00015    0         DL_RLC_PDU_UE_TPUT_BIN12_PMQAP
    ...    M55353C00016    0         DL_RLC_PDU_UE_TPUT_BIN13_PMQAP
    ...    M55353C00017    0         DL_RLC_PDU_UE_TPUT_BIN14_PMQAP
    ...    M55353C00018    0         DL_RLC_PDU_UE_TPUT_BIN15_PMQAP
    ...    M55353C00019    0         DL_RLC_PDU_UE_TPUT_BIN16_PMQAP
    ...    M55353C00020    0         DL_RLC_PDU_UE_TPUT_BIN17_PMQAP
    ...    M55353C00021    0         DL_RLC_PDU_UE_TPUT_BIN18_PMQAP
    ...    M55353C00022    0         DL_RLC_PDU_UE_TPUT_BIN19_PMQAP
    ...    M55353C00023    0         DL_RLC_PDU_UE_TPUT_BIN20_PMQAP
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
    ...    M55353C00006    0-5000         DL_RLC_PDU_UE_TPUT_BIN3_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters}

Expected Ranges of values per Bursts
    [Arguments]   ${pm_counters}
    Verify Last Counters In File
    ...    M55353C00004    0-9000      DL_RLC_PDU_UE_TPUT_BIN1_PMQAP
    ...    M55353C00005    0-5000      DL_RLC_PDU_UE_TPUT_BIN2_PMQAP
    ...    M55353C00006    0-5000      DL_RLC_PDU_UE_TPUT_BIN3_PMQAP
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
