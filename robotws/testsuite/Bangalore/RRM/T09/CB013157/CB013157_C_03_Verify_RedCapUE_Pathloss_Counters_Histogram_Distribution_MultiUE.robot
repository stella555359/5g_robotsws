*** Settings ***
Force Tags        CLOUD_5G_I_LOO_AP_LOOO     SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation
...  INTRODUCTION    :   Verify the correct distribution of pathloss measurements across multiple counter bins by using several
...						 RedCap UEs (both 1Rx and 2Rx)operating simultaneously at various simulated pathloss levels.
...  TEST SET NAME   :   CB012268_B1_UPD2_SA_UEs_DL&UL_CA_config_with_a_DL_pathloss_Verify_Cell_Throughput_Radio_Link_Quality_Counters
...                      _not_pegged_when_cell_is_acting_as_SCell_for_any_UEs
...  TESTING SPLIT   :   Split-C
...  REFERENCES      :   CB013157-CFAM
...  REQUIREMENT ID  :  12646065

Library          taf.transport.ssh           WITH NAME    taf_ssh
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../../../resources/robot/counter_benchmark_resource.robot
Library          ta5g_enb
Library          ta5g_pm_counters
Library          taf.sw.scout    WITH NAME     scout

Suite Setup         Run keywords    Suite setup from scratch
...                 AND    Perform SCF Delta Commissioning with Delta_redcap_no_barred.json
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
...                 AND    Configure eth3 IP
...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   1    4


Test Teardown    Run keywords       Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts/basic_setup_redcap_1Rx_2Rx.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${UE_ID}        1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${TRF_ID}    1
${Q_O_ADD1}    1
${Timeout_NSA}    300
${epc_log_path}    /tmp/
${1Rx_redcap}      Selected Redcap type is : redCap1Rx
${2Rx_redcap}      redCap2Rx

${SCFC}=                  ${CURDIR}/config/SCF/Scf_UPD2_CA.xml
${AP_XML}=                ${CURDIR}/config/SCF/iphy_UPD2_CA.xml


*** Test Cases ***
[1][1.0] CB013157_C_03_Verify_RedCapUE_Pathloss_Counters_Histogram_Distribution_MultiUE
    Set test variable      ${LOG_PATH}
	Start Collecting Syslog     NAME=ue_check1_or_2rx
	Create pathloss profile
    Register UE and Send Data
    Stop Collecting Syslog       NAME=ue_check1_or_2rx
    Validate 1rx in SYSLOG   ue_check1_or_2rx    ${1Rx_redcap}
    Validate 2rx in SYSLOG   ue_check1_or_2rx    ${2Rx_redcap}
    Activate pathloss profile
    Check redcap pathloss Counters

    wts_sim_keywords.MultiUE Deregister should be Successful    1   20

*** Keywords ***
Register UE and Send Data
    ${crnti}=      wts_sim_keywords.MultiUE Register should be Successful    1  20
    sleep    2s
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1   20    Traffic_rate=mbps     dl_rate=25          trf_id=${TRF_ID}
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1   20    Traffic_rate=mbps     ul_rate=25          trf_id=${TRF_ID}

Create pathloss profile
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=3 pcmax=20 pathloss=30
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=4 pcmax=20 pathloss=40
       ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=5 pcmax=20 pathloss=50
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=6 pcmax=20 pathloss=60
       ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=7 pcmax=20 pathloss=70
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=8 pcmax=20 pathloss=80
       ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=9 pcmax=20 pathloss=90
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=10 pcmax=20 pathloss=100
       ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=11 pcmax=20 pathloss=110
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=12 pcmax=20 pathloss=120
       ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=13 pcmax=20 pathloss=130
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=14 pcmax=20 pathloss=140
       ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=15 pcmax=20 pathloss=150
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=16 pcmax=-10 pathloss=160
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=17 pcmax=20 pathloss=164
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=18 pcmax=-10 pathloss=28
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=19 pcmax=5 pathloss=28
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=20 pcmax=-20 pathloss=28

    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=21 pcmax=10 pathloss=163
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=22 pcmax=5 pathloss=162
Activate pathloss profile
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=3
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=2 testmode=ul_sinr action=activate profile_id=4
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=3 testmode=ul_sinr action=activate profile_id=5
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=4 testmode=ul_sinr action=activate profile_id=6
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=5 testmode=ul_sinr action=activate profile_id=7
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=6 testmode=ul_sinr action=activate profile_id=8
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=7 testmode=ul_sinr action=activate profile_id=9
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=8 testmode=ul_sinr action=activate profile_id=10
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=9 testmode=ul_sinr action=activate profile_id=11
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=10 testmode=ul_sinr action=activate profile_id=12
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=11 testmode=ul_sinr action=activate profile_id=13
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=12 testmode=ul_sinr action=activate profile_id=14
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=13 testmode=ul_sinr action=activate profile_id=15
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=14 testmode=ul_sinr action=activate profile_id=16
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=15 testmode=ul_sinr action=activate profile_id=17
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=16 testmode=ul_sinr action=activate profile_id=18
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=17 testmode=ul_sinr action=activate profile_id=19
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=18 testmode=ul_sinr action=activate profile_id=20
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=19 testmode=ul_sinr action=activate profile_id=21
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=20 testmode=ul_sinr action=activate profile_id=22


Check redcap pathloss Counters
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55202C00009    >0      RC_UE_PATHL_PUSCH_SSB_LEV_1
    ...     M55202C00010    >0      RC_UE_PATHL_PUSCH_SSB_LEV_2
    ...     M55202C00012    >0      RC_UE_PATHL_PUSCH_SSB_LEV_4
    ...     M55202C00013    >0      RC_UE_PATHL_PUSCH_SSB_LEV_5
    ...     M55202C00015    >0      RC_UE_PATHL_PUSCH_SSB_LEV_7
    ...     M55202C00016    >0      RC_UE_PATHL_PUSCH_SSB_LEV_8
    ...     M55202C00017    >0      RC_UE_PATHL_PUSCH_SSB_LEV_9
    ...     M55202C00018    >0      RC_UE_PATHL_PUSCH_SSB_LEV_10
    ...     M55202C00019    >0      RC_UE_PATHL_PUSCH_SSB_LEV_11
    ...     M55202C00020    >0      RC_UE_PATHL_PUSCH_SSB_LEV_12
    ...     M55202C00021    >0      RC_UE_PATHL_PUSCH_SSB_LEV_13
    ...     M55202C00022    >0      RC_UE_PATHL_PUSCH_SSB_LEV_14
    ...     M55202C00023    >0      RC_UE_PATHL_PUSCH_SSB_LEV_15
    ...     M55202C00024    >0      RC_UE_PATHL_PUSCH_SSB_LEV_16
    ...     M55202C00025    >0      RC_UE_PATHL_PUSCH_SSB_LEV_17
    ...     M55202C00026    >0      RC_UE_PATHL_PUSCH_SSB_LEV_18
    ...     M55202C00027    >0      RC_UE_PATHL_PUSCH_SSB_LEV_19
    ...     M55202C00028    >0      RC_UE_PATHL_PUSCH_SSB_LEV_20
    ...     M55202C00029    >0      RC_UE_PATHL_PUSCH_SSB_LEV_21
    ...     M55202C00030    >0      RC_UE_PATHL_PUSCH_SSB_LEV_22
    ...     M55202C00032    >0      RC_UE_PATHL_PUSCH_SSB_LEV_24
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
	...     file_path=${pm_counter_file}



Validate 1rx in SYSLOG
    [Arguments]    ${syslog}   ${1Rx_redcap}
    ${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "Selected Redcap type is : "
    Builtin.Log   ${status}
    Should Not Be Empty    ${status}
    Should Contain    ${status}   ${1Rx_redcap}

Validate 2rx in SYSLOG
    [Arguments]    ${syslog}   ${2Rx_redcap}
    #${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "Selected \ \\n \ Redcap type is : "
    ${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${syslog}.log | grep "Selected${SPACE}${SPACE}Redcap type is : "
    Builtin.Log   ${status}
    Should Not Be Empty    ${status}
    Should Contain    ${status}   ${2Rx_redcap}
