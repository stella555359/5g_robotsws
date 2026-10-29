*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_TDD_GMC
...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT


Documentation
...  AUTHOR          :   Padmashree
...  MAINTAINER      :   Padmashree
...  INTRODUCTION    :  CB012719 feature allows the traffic in proctected slot whne the cellload is above the
...                    above the thershold value with the configured powerr backoff.
...  TEST SET NAME   :   [1]CB012719_C#IWK01_Feature interworking with baseband pooling
...  CONTACTS        :  Padmashree
...  REFERENCES      :   CFAM CB012719
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_27575

Library          taf.transport.ssh           WITH NAME    taf_ssh
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
#Resource         ../CB009215/resources/CB009215_keyword.robot
Resource         ./CB012719_Resource.robot
Resource         ../../../resources/robot/PM_Counters.robot
Library          ./python/check_alarm.py
Library          ./python/utility.py
Library		     ./python/check_prballocation.py
Library          ta5g_enb
Library          taf.sw.scout    WITH NAME     scout

Suite Setup         Run keywords    Suite setup from scratch
...                 AND    Perform SCF Delta Commissioning with Delta_Configuration_1CC_TDD_GBR__FS_tddlte_0ms_4_gp_RIM_FW1.json
...                 AND     Sleep   60s
...                 AND    Perform SCF Delta Commissioning with BBpool_config.json
...                 AND     Sleep   60s
...                 AND    Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   300s    reason=wait for RMOD- to comeup
...                 AND    Configure eth3 IP
...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   1    2

Test Teardown    Run Keywords    Stop Log   btslog    #snapshot  sosreport
...   AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}       ${WTS_DIR}/basic_setup.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${r&d_parameter}       0x58057f=262223;0x58057a=4
${NOISE_POWER_RI}=       SEPARATOR=
...                   -40,-45,-50,-55,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,
...                    -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115
${Pdu_session_ID}       1
${nwslice_ID}           1
@{cell_id}              50  51
&{minprb}               50=${48}  51=${48}
@{prb_c4}            1       1
*** Test Cases ***
[1]CB012719_C_IWK_1_CB012719 feature interworking with Baseband pooling

    Set test variable      ${LOG_PATH}
    Setup X2 Link
    Perform SCF Delta Commissioning with rim_pwr.json
    sleep    60s
    Perform SCF Delta Commissioning with delta_rim_drb_config.json
    sleep    60s
    ${protected_slots}    Create List    ${2}    ${3}    ${12}    ${13}
    Perform SCF Delta Commissioning with change_thershold_to_high.json

    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1    ${1}     ${4}
    Trigger DL Data and UL Data      ${1}       ${4}	${100}	mbps

    Start log       btslog
    BuiltIn.Log                 RI Triggered
    Activate RI         ${NOISE_POWER_RI}
    Wait For Fault To Be Up     fault_id=7525   timeout=200

    Perform SCF Delta Commissioning with off_rim_pwr_red.json
    Generate RS1andRS2      profile_id=1     config_mode=standalone     victim_cell=1   aggressor_cell=1
    ...    rsSetId=22223     numRsSetId=1     rimRsType=rsType1AndType2     rsNearFarConfig=0    propagation_delay=16   rsType1NScId=1,2,3,4,5,6,7,8
    ...    rsType2NScId=101,102,103,104,105,106,107,108     numRbForRs=96   rsPattern1Period=50    repetitionRsType1=4     repetitionRsType2=4
    ...    rim_framework=framework_1     factorRsSequence=1     factorRsSequenceRS2=1     offsetRsSequence=1     offsetRsSequenceRS2=1
    ...    numRsType1SetId=65536    numRsType2SetId=65536    rimRsTxPower=-330    rimRsTxPowerRS2=-330    globalF0ForRs=631206
    ...     startFreqOffsetForRs=105,201
    BuiltIn.Log                  RIM-RS
    Wait For Fault To Be Up     fault_id=7527   timeout=500
    Wait For Fault To Be Up     fault_id=7535   timeout=200

    Perform SCF Delta Commissioning with on_rim_pwr_red.json
    sleep    10s
    ${Active_alarm}    ta5g_enb.get_active_alarms
    ${faluts_supres}    Create List    7535
    ${rc}     get_list_of_faults_check    ${Active_alarm}    ${faluts_supres}
    Should Contain	${rc}	fail

    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${PRB_AVAIL_PDSCH_BB_POOL_lowload}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10005    moc=NRCELL-1
    Start Log         ttitrace
    sleep     1s
    ${low_load}     Stop Log     ttitrace         test_scenario=low_load_by_config
    Decode TTI Trace    low_load_by_config

#   Trigger DL Data and UL Data      ${1}       ${4}	${100}	 mbps       ${2}
    Perform SCF Delta Commissioning with change_thershold_to_low.json
    sleep    500s

    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${PRB_AVAIL_PDSCH_BB_POOL_highload}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C10005    moc=NRCELL-1
    Start Log         ttitrace
    sleep     1s
    ${high_load}     Stop Log     ttitrace         test_scenario=high_load_by_config
    Decode TTI Trace    high_load_by_config
    ${high_status}   get_cqi_derived_verify   ${high_load}[ttitrace]/output_dl_formated.csv    ${protected_slots}
    ${high_status_sche}    check_scheduling    ${high_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}

    ${low_status}   get_cqi_derived_verify   ${low_load}[ttitrace]/output_dl_formated.csv    ${protected_slots}
    ${low_status_sche}    check_scheduling    ${low_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}

     Should Contain    	${low_status}	 false
     Should Contain    	${low_status_sche}    fail
     Should Contain    	${high_status}	 pass
     Should Contain    	${high_status_sche}    pass
     Validate PRBallocation		${high_load}[ttitrace]
     Validate PRBallocation		${low_load}[ttitrace]
     Should be True    ${PRB_AVAIL_PDSCH_BB_POOL_lowload} <= ${PRB_AVAIL_PDSCH_BB_POOL_highload}

*** Keywords ***

Trigger DL Data and UL Data
    [Arguments]    ${st_ue_id}=1        ${en_ue_id}=1		${dl_rate}=100		${rate}=mbps        ${pdu}=1
    FOR    ${id}    IN RANGE   ${st_ue_id}        ${en_ue_id}+1
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${id}      Traffic_rate=${rate}     dl_rate=${dl_rate}     pdu_id=${pdu}   trf_id=1
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${id}      Traffic_rate=${rate}     dl_rate=${dl_rate}      pdu_id=${pdu}   trf_id=2
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${id}      Traffic_rate=${rate}     dl_rate=${dl_rate}      pdu_id=${pdu}   trf_id=3
    wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=${id}      Traffic_rate=${rate}     ul_rate=${dl_rate}      pdu_id=${pdu}   trf_id=1
    sleep    10s
    END

Stop DL and UL data
    [Arguments]    ${st_ue_id}=1        ${en_ue_id}=1
    FOR    ${id}    IN RANGE   ${st_ue_id}        ${en_ue_id}+1
    Stop Data Traffic for SA        ${id}
    END

Validate Throughput
    [Arguments]    ${st_ue_id}=1        ${en_ue_id}=1   ${scell_idx}=0
    FOR    ${id}    IN RANGE   ${st_ue_id}        ${en_ue_id}+1
    ${DATA_DL}    wts_sim_keywords.Get AVG DL DATA TRAFFIC For Given CC     ${ue_id}    ${scell_idx}
#    Should be True    ${DATA_DL} > 300
    ${DATA_UL}    wts_sim_keywords.Get AVG UL DATA TRAFFIC For Given CC     ${ue_id}    ${scell_idx}
#    Should be True    ${DATA_UL} > 80
    END

Validate PRBallocation
	[Arguments]		${ttipath}
    ${allocated_subcell}    Create List     1     1
    ${ch_bw}    Create list   100   100
    Validate cell dlprballocation from TTI traces    ${ttipath}    ${cell_id}   ${allocated_subcell}
    ...    ${ch_bw}   subcell=${2}
    check_prballocation.Check_minprballocation   ${ttipath}/output_dl_formated.csv    ${minprb}

Verify cell dlprballocation
    [Arguments]   ${csv_file_path}  ${cellid}   ${prb_in_c4}   ${ch_bw}   ${subcell}
    ${all_prb}   Create cellprb Dictionary   ${cellid}   ${prb_in_c4}    ${ch_bw}
    ${Result}   check_prballocation.Check_dlallocatedprb    ${csv_file_path}   ${all_prb}   ${subcell}
    [Return]   ${Result}

Validate cell dlprballocation from TTI traces
    [Arguments]   ${csv_file_path}  ${cellid}   ${prb_in_c4}   ${ch_bw}   ${subcell}
    ${Check}   Verify cell dlprballocation    ${csv_file_path}/output_dl_formated.csv    ${cellid}   ${prb_in_c4}    ${ch_bw}   ${subcell}
    run keyword and continue on failure   Run Keyword if   ${Check}!=${True}   Fail   prb allocation is not matching

Create cellprb Dictionary
    [Arguments]   ${cellid}   ${prb_in_c4}   ${ch_bw}
    ${Dict1}   Create Dictionary
    ${len}   Get Length    ${cellid}
    FOR    ${i}    IN RANGE   ${len}
         ${temp}   create list    ${prb_in_c4}[${i}]    ${ch_bw}[${i}]
         Set To Dictionary   ${Dict1}    ${cellid}[${i}]    ${temp}
    END
    [Return]   &{Dict1}
