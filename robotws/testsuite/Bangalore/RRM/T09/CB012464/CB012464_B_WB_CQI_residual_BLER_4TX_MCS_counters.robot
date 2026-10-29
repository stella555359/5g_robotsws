*** Settings ***
Force Tags      5G_SC_TDD    5G_RAN     SBTS00     SBTS25R2    CONFIGURED

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          Collections
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Library          taf.sw.scout    WITH NAME     scout
Library          ta5g_pm_counters
Library          ta5g_commissioning
Resource         ../../../resources/robot/counter_benchmark_resource.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Find Scfc And Send Delta Commissioning      scfc_filename=RI_bler.json
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1    4


Documentation
...      author:           Bhabani    bhabani.sankar_rout@nokia.com
...      maintainer:        Bhabani   bhabani.sankar_rout@nokia.com

...      INTRODUCTION:  The aim of the Cb012464 feature is NR Radio Quality Measurement PM Counters
...      Provides PMQAP counters for 5G DL/UL radio quality measurements.
...      Improves reporting of UL RIP per PRB counters;
...      Delivers SS-RSRP/RSRQ/SINR distribution counters per SSB Beam.
...      Introduces counters to report UL SINR and RIP per spatial stream
...      RI, BLER , CQI, MCS value multiple PMQAP profile counter validation

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/egate_TMOUS.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${TRF_ID}    1
${Q_O_ADD1}    1
${epc_log_path}    /tmp/
@{5QI1}     2    12    false
&{flows_ue1_pdu1}    ${2}=${5QI1}
@{crnti_list}
${host}=   192.168.255.129
${user}=   Nemuadmin
${password}=   nemuuser
${target_dir}=    /home/ute/Desktop/
${counter_json_file}=    ${CURDIR}/config/counter_data.json
${git_path}=   https://gitlabe1.ext.net.nokia.com/BTS_TOOLS/counter_benchmarking/-/blob/main/Bangalore/VRF_BLR1/T09/CB012464_Counter_Benchmking.xlsx
${b}=       59.2,59.2,59.2,59.2,5.2,6.2,7.2,8.2,9.2,10.2,11.2,12.2,13.2,14.2,15.2
${a}=       59.1,59.1,59.1,59.1,59.1,59.1,25.1,5.1,5.1,10.1,11.1,12.1,13.1,14.1,15.1

*** Test Cases ***
[1][1.0] CB012464_B_31_Robustness_verify_CP_OFDM_64_QAM_256QAM_RI_WB_CQI_BLER_MCS_distribution_PMQAP_Counters_with_multi_UEs_diff_cells
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
        Create RI Profiles
        Create MCS_256 Profiles
		Create MCS_64 Profiles
        Create CQI_256 Profiles
		Create CQI_64 Profiles
        Activate Ues to the CQI_256 Profile
		Activate Ues to the CQI_64 Profile
        Activate Ues to the RI Profile
        Activate Ues to the MCS_256 Profile
		Activate Ues to the MCS_64 Profile
        Start Log    btslog    cprt
        wts_sim_keywords.MultiUE Register should be Successful    1    25
        wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    25   mbps    100
        Validate the Counter 4Tx after UE attach
        Validate the Counter 2Tx DLMIMO after UE attach
        Validate the Counter BLER Residual after UE attach
        Validate the MCS_CQI_PMQAP_256Qam Counter after UE attach
        Validate the MCS_CQI_PMQAP_64Qam Counter after UE attach
        Stop Log    btslog    cprt    test_scenario=syslog
    [Teardown]   Run Keywords        Link SCOUT SCF to Configuration ID for Reporting
    ...         AND        wts_sim_keywords.Clean edaemon and egate
    ...         AND        run keyword if test failed    Run Keyword and Ignore Error    Get Snapshot
    ...         AND        run keyword if test failed    Run Keyword and Ignore Error    Get Sos Report
*** Keywords ***
Create RI Profiles
        ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=1 cqi=15 pmi=1 ri=1 cqi_mode=fixed
        ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=2 cqi=8 pmi=1 ri=1 cqi_mode=fixed
        ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=3 cqi=15 pmi=1 ri=0 cqi_mode=fixed
        ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=4 cqi=8 pmi=1 ri=0 cqi_mode=fixed
        ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=5 cqi=15 pmi=1 ri=3 cqi_mode=fixed
        ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=6 cqi=8 pmi=1 ri=3 cqi_mode=fixed
        ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=7 cqi=15 pmi=1 ri=2 cqi_mode=fixed
        ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=8 cqi=8 pmi=1 ri=2 cqi_mode=fixed
        ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=9 cqi=15 pmi=1 ri=1 cqi_mode=fixed
        ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=10 cqi=8 pmi=1 ri=1 cqi_mode=fixed
        ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=11 cqi=15 pmi=1 ri=0 cqi_mode=fixed
        ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=12 cqi=8 pmi=1 ri=0 cqi_mode=fixed
        ute_wtssim.Execute Egate Command
    ...    cmd=bler_testmode_nr profile_id=13 dl_bler=50,45,40,35,30,25,20,15
    sleep    2s



Activate Ues to the RI Profile
     ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=1 profile_id=9 action=activate testmode=csi_override scell=0
     ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=2 profile_id=10 action=activate testmode=csi_override scell=0
     ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=3 profile_id=11 action=activate testmode=csi_override scell=0
     ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=4 profile_id=12 action=activate testmode=csi_override scell=0
     ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=5 profile_id=1 action=activate testmode=csi_override scell=0
     ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=6 profile_id=2 action=activate testmode=csi_override scell=0
     ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=7 profile_id=3 action=activate testmode=csi_override scell=0
     ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=8 profile_id=4 action=activate testmode=csi_override scell=0
     ute_wtssim.Execute Egate Command
      ...    cmd=ue_testmode_set_nr id=9 profile_id=5 action=activate testmode=csi_override scell=0
     ute_wtssim.Execute Egate Command
      ...    cmd=ue_testmode_set_nr id=10 profile_id=6 action=activate testmode=csi_override scell=0
     ute_wtssim.Execute Egate Command
      ...    cmd=ue_testmode_set_nr id=11 profile_id=7 action=activate testmode=csi_override scell=0
     ute_wtssim.Execute Egate Command
      ...    cmd=ue_testmode_set_nr id=12 profile_id=8 action=activate testmode=csi_override scell=0
     ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=13 scell=0 testmode=bler profile_id=13 action=activate
     sleep    2s


Validate the Counter 4Tx after UE attach
#* [>200000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55386C00034    >100000      PDSCH_4TX_RI_01_PMQAP
    ...     M55386C00035    >100000      PDSCH_4TX_RI_02_PMQAP
    ...     M55386C00036    >100000      PDSCH_4TX_RI_03_PMQAP
    ...     M55386C00037    >100000      PDSCH_4TX_RI_04_PMQAP
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
     ...     file_path=${pm_counter_file}

Validate the Counter 2Tx DLMIMO after UE attach
#* [>400000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55386C00032    >400000     PDSCH_2TX_RI_01_PMQAP
    ...     M55386C00033    >400000     PDSCH_2TX_RI_02_PMQAP
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-7
     ...    file_path=${pm_counter_file}

Validate the Counter BLER Residual after UE attach
#* [>1000 & 2000000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55386C00031    >1000000     PDSCH_ANY_SUCC_DRB_PMQAP
    ...     M55386C00030    >1000       PDSCH_LAST_FAIL_DRB_PMQAP
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-2
    ...     file_path=${pm_counter_file}
    ${PDSCH_ANY_SUCC_DRB_PMQAP_value}=     Get Latest Pm Counter Value
	...      counter_id=M55386C00031
	...      local_moid=MRBTS-1/NRBTS-1/NRCELL-2
	...     filepath=${pm_counter_file}
	${PDSCH_LAST_FAIL_DRB_PMQAP_value}=    Get Latest Pm Counter Value    counter_id=M55386C00030    local_moid=MRBTS-1/NRBTS-1/NRCELL-2
	...     filepath=${pm_counter_file}
	${result}    Evaluate    ${PDSCH_LAST_FAIL_DRB_PMQAP_value}/(${PDSCH_LAST_FAIL_DRB_PMQAP_value}+${PDSCH_ANY_SUCC_DRB_PMQAP_value})

Validate the MCS_256_BIN4_PMQAP Counter after UE attach
#* [>40000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
	...     M55386C00062    >40000     PDSCH_CP_INRE_BIN4_256TBL_PMQ
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-3
	...     file_path=${pm_counter_file}

Create CQI_256 Profiles
    ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=51 cqi_mode=varying cqi=0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15


Activate Ues to the CQI_256 Profile
     ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=16-19 profile_id=51 action=activate testmode=csi_override
	 sleep    2s

Create MCS_256 Profiles
     ute_wtssim.Execute Egate Command
  	 ...    cmd=adv_bler_testmode_nr profile_id=52 target_mcs=28 mcs_table=all target_bler_profile_id=1 target_bler=${a} retx_target_bler1=${b}
    sleep    2s

Activate Ues to the MCS_256 Profile
     ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=20 profile_id=52 action=activate testmode=adv_bler
     sleep    2s

Create MCS_64 Profiles
     ute_wtssim.Execute Egate Command
  	 ...    cmd=adv_bler_testmode_nr profile_id=49 target_mcs=28 mcs_table=all target_bler_profile_id=1 target_bler=${a} retx_target_bler1=${b}
   sleep    2s

Activate Ues to the MCS_64 Profile
     ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=23-24 profile_id=49 action=activate testmode=adv_bler
     sleep    2s

Create CQI_64 Profiles
    ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=53 cqi_mode=varying cqi=0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

Activate Ues to the CQI_64 Profile
     ute_wtssim.Execute Egate Command
     ...    cmd=ue_testmode_set_nr id=21-22 profile_id=53 action=activate testmode=csi_override
	 sleep    2s

Validate the MCS_CQI_PMQAP_256Qam Counter after UE attach
#* [>1000 & 10000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55386C00023    >1000      WB_CQI_256TBL_CQI_BIN01_PMQAP
    ...     M55386C00024    >1000      WB_CQI_256TBL_CQI_BIN02_PMQAP
    ...     M55386C00025    >1000      WB_CQI_256TBL_CQI_BIN03_PMQAP
    ...     M55386C00026    >1000      WB_CQI_256TBL_CQI_BIN04_PMQAP
	...     M55386C00027    >1000      WB_CQI_256TBL_CQI_BIN05_PMQAP
	...     M55386C00058    >1000      PDSCH_CP_INRE_BIN0_256TBL_PMQ
	...     M55386C00059    >1000      PDSCH_CP_INRE_BIN1_256TBL_PMQ
	...     M55386C00060    >10000     PDSCH_CP_INRE_BIN2_256TBL_PMQ
	...     M55386C00061    >10000     PDSCH_CP_INRE_BIN3_256TBL_PMQ
	...     M55386C00062    >10000     PDSCH_CP_INRE_BIN4_256TBL_PMQ
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-2
	...     file_path=${pm_counter_file}

Validate the MCS_CQI_PMQAP_64Qam Counter after UE attach
#* [>1000 & 5000 value given based on PDU pegging]*
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55386C00018    >500      WB_CQI_64TBL_CQI_BIN01_PMQAP
    ...     M55386C00019    >500      WB_CQI_64TBL_CQI_BIN02_PMQAP
    ...     M55386C00020    >500      WB_CQI_64TBL_CQI_BIN03_PMQAP
    ...     M55386C00021    >500      WB_CQI_64TBL_CQI_BIN04_PMQAP
	...     M55386C00022    >1000     WB_CQI_64TBL_CQI_BIN05_PMQAP
	...     M55386C00053    >1000     PDSCH_CP_INRE_BIN0_64TBL_PMQ
	...     M55386C00054    >5000     PDSCH_CP_INRE_BIN1_64TBL_PMQ
	...     M55386C00055    >5000     PDSCH_CP_INRE_BIN2_64TBL_PMQ
	...     M55386C00056    >5000     PDSCH_CP_INRE_BIN3_64TBL_PMQ
	...     M55386C00057    >5000     PDSCH_CP_INRE_BIN4_64TBL_PMQ
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-4
	...     file_path=${pm_counter_file}
