*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_TDD
...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT


Documentation
...  AUTHOR          :   Prasanta Kumar Nayak
...  MAINTAINER      :   Prasanta Kumar nayak
...  INTRODUCTION    :  CB012719 feature allows the traffic in proctected slot whne the cellload is above the
...                    above the thershold value with the configured powerr backoff.
...  TEST SET NAME   :  [1]CB012719_A#B08_2_ CB012719 activation RIM_RS based DL muting with
...               high cell load to low load switch and frame structure is configured as tddlte_0ms_RIM_framework_1


...		[1]CB012719_A#B06_3_CB012719 Manually triggered DL muting is combined with RIM-RS based DL muting with high cell
...		load and frame structure is configured as tddlte_0ms_RIM_framework_1
...		[1]CB012719_A#B01_1_ CB012719 activation RIM_RS based DL muting with low cell load and frame structure is configured
...		as tddlte_0ms_RIM_framework_1
...		[1]CB012719_A#B07_3_ CB012719 activation Manually triggered DL muting is combined with RIM-RS based DL muting with low cell
...		load to high load switch and frame structure is configured as tddlte_0ms_RIM_framework_1
...		[1]CB012719_A#B07_1_ CB012719 activation RIM_RS based DL muting with low cell load to high load switch and frame structure
...		is configured as tddlte_0ms_RIM_framework_1
...		[1]CB012719_A#B08_2_ CB012719 activation RIM_RS based DL muting with high cell load to low load switch and frame structure
...	    is configured as tddlte_0ms_RIM_framework_1
...  TESTING SPLIT   :   SPLIT-A SPLIT-B
...  CONTACTS        :  Prasanta Kumar Nayak
...  REFERENCES      :   CFAM CB012719
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_27564,5G_RAN_USR_RRM_28219,5G_RAN_USR_RRM_28220,5G_RAN_USR_RRM_2822
...                    G_RAN_USR_RRM_27567,5G_RAN_USR_RRM_28235,5G_RAN_USR_RRM_28236,5G_RAN_USR_RRM_28239,
...                    5G_RAN_USR_RRM_28237,5G_RAN_USR_RRM_27570,5G_RAN_USR_RRM_28255,5G_RAN_USR_RRM_27570,
...                    5G_RAN_USR_RRM_28255,5G_RAN_USR_RRM_28257,



Library          taf.transport.ssh           WITH NAME    taf_ssh
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource         ./CB012719_Resource.robot
Resource         ../../../resources/robot/PM_Counters.robot
Library          ./python/check_alarm.py
Library          ta5g_enb
Library          taf.sw.scout    WITH NAME     scout



Suite Setup         Run keywords    run keyword and ignore error     Suite setup from scratch
...                 AND    Perform SCF Delta Commissioning with Delta_Configuration_1CC_TDD_GBR__FS_tddlte_0ms_4_gp_RIM_FW1.json
...                 AND     Sleep   60s
...                 AND    Perform SCF Delta Commissioning with actvonr_enable.json
...                 AND     Sleep   60s
#...                 AND    Perform SCF Delta Commissioning with Delta_Configuration_1CC_TDD_GBR__FS_tddlte_0ms_4_gp_RIM_FW1_tmo.json
...                 AND     Sleep   60s
...                 AND     Update bsr package_TMO_65
...                 AND     Sleep   60s
...                 AND    Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
...                 AND    Configure eth3 IP
...                 AND    Start wts application and load CFG    ${wts_cfg_file}

Test Teardown    Run Keywords    Stop Log  snapshot  sosreport  btslog
...   AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${TLConfig.isUTE}   True
#${wts_cfg_file}       ${WTS_DIR}/basic_setup.cfg
${wts_cfg_file}       ${CURDIR}/config/wts/basic_setup_tmo.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${r&d_parameter}       0x58057f=262223;0x58057a=4
${kpi_txt}            ${CURDIR}/python/req_kpi.txt

${NOISE_POWER_RI_LTETDD}=       SEPARATOR=
...                   -40,-45,-50,-55,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,
...                    -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115

${NOISE_POWER_RI}       SEPARATOR=
...                       -60,-63,-66,-69,-70,-72,-76,-78,-80,-83,-84,-88,-90,-94,-96,-100,-104,-108,
...                       -112,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115


${noise_rimrs_fw1_tdlte}    SEPARATOR=
&{ue_to_qos_map}    ${1}=2,3    ${2}=20,21,22    ${3}=2,3,4    ${4}=22,5

${Pdu_session_ID}       1
${nwslice_ID}           1

*** Test Cases ***
[1]CB012719_A#B01_1_CB012719 activation RIM_RS based DL muting with low cell load and frame structure is configured as tddlte_0ms_RIM_framework_1
    [Tags]   TC1

    Increase Buffer Size for VM and IPHY
    Set test variable      ${LOG_PATH}
    Setup X2 Link
    Perform SCF Delta Commissioning with rim_pwr.json
    sleep    60s
    Perform SCF Delta Commissioning with delta_rim_drb_config.json
    sleep    60s
    ${protected_slots}    Create List    ${2}    ${3}    ${12}    ${13}
    Perform SCF Delta Commissioning with change_thershold_to_high.json
    sleep    60s
    Perform SCF Delta Commissioning with disable_high_pri.json
    sleep    60s
    Perform SCF Delta Commissioning with disable_manual_miti_2dl.json
    sleep    60s
    Activate RI     ${NOISE_POWER_RI}
    Wait For Fault To Be Up     fault_id=7525   timeout=700

    Perform SCF Delta Commissioning with off_rim_pwr_red.json
    Generate RS1andRS2      profile_id=1     config_mode=standalone     victim_cell=1   aggressor_cell=1
    ...    rsSetId=22223     numRsSetId=1     rimRsType=rsType1AndType2     rsNearFarConfig=0    propagation_delay=16   rsType1NScId=1,2,3,4,5,6,7,8
    ...    rsType2NScId=101,102,103,104,105,106,107,108     numRbForRs=48   rsPattern1Period=50    repetitionRsType1=4     repetitionRsType2=4
    ...    rim_framework=framework_1     factorRsSequence=1     factorRsSequenceRS2=1     offsetRsSequence=1     offsetRsSequenceRS2=1
    ...    numRsType1SetId=65536    numRsType2SetId=65536    rimRsTxPower=-330    rimRsTxPowerRS2=-330    globalF0ForRs=528432
    ...    startFreqOffsetForRs=0,48

    Generate RS1andRS2      profile_id=1     config_mode=standalone     victim_cell=1   aggressor_cell=1
    ...    rsSetId=22223     numRsSetId=1     rimRsType=rsType1AndType2     rsNearFarConfig=0    propagation_delay=16   rsType1NScId=1,2,3,4,5,6,7,8
    ...    rsType2NScId=101,102,103,104,105,106,107,108     numRbForRs=48   rsPattern1Period=50    repetitionRsType1=4     repetitionRsType2=4
    ...    rim_framework=framework_1     factorRsSequence=1     factorRsSequenceRS2=1     offsetRsSequence=1     offsetRsSequenceRS2=1
    ...    numRsType1SetId=65536    numRsType2SetId=65536    rimRsTxPower=-330    rimRsTxPowerRS2=-330    globalF0ForRs=528432
    ...    startFreqOffsetForRs=0,48

    Wait For Fault To Be Up     fault_id=7527   timeout=900
    Wait For Fault To Be Up     fault_id=7535   timeout=100


    Perform SCF Delta Commissioning with on_rim_pwr_red.json

    Start Log   btslog
    ${tl_name}=    testline.Get Testline Name
    Configure Scout API    ${tl_name}    ${API_KEY}
    Enable Kpi Pm Collection
    ${RUN1_START_TIME}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%dT%H:%M:%S.%fZ
    ${RUN1_START_TIME_ACTUAL}    ${WAIT_MS}=   Round Time To Next 15 Min With Wait    ${RUN1_START_TIME}
    Sleep    ${WAIT_MS}ms

    ${rnti_list}    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1     ${1}     ${4}
    MultiUE PDU Modfication should be Successful selective    1    ${ue_to_qos_map}

    #UE1 5qi 6,5,1    lcid 4, 5,6
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=175     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=175     pdu_id=1    trf_id=2       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=175     pdu_id=1    trf_id=3       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=175     pdu_id=1    trf_id=4       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=2      pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=2     pdu_id=1    trf_id=1       qfi_id=2
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=2      pdu_id=1    trf_id=1       qfi_id=2
    Trigger VONR custom data    ${1}    ul    1    1    3    kbps   25.1    custom
    Trigger VONR custom data    ${1}    dl    1    1    3    kbps   25.1    custom

    #UE2    7 8 9
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=175     pdu_id=1    trf_id=1       qfi_id=2
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=10      pdu_id=1    trf_id=1       qfi_id=2
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=175     pdu_id=1    trf_id=1       qfi_id=3
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=10      pdu_id=1    trf_id=1       qfi_id=3
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=175     pdu_id=1    trf_id=1       qfi_id=4
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=10      pdu_id=1    trf_id=1       qfi_id=4

    #UE3 6,5,1,2
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=175     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=10      pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=2     pdu_id=1    trf_id=1       qfi_id=2
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=2      pdu_id=1    trf_id=1       qfi_id=2
    Trigger VONR custom data    ${1}    ul    3    3    3    kbps   25.1    custom
    Trigger VONR custom data    ${1}    dl    3    3    3    kbps   25.1    custom
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=30     pdu_id=1    trf_id=1       qfi_id=4
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=30      pdu_id=1    trf_id=1       qfi_id=4
    #UE4
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    4    4    Traffic_rate=mbps     dl_rate=175     pdu_id=1    trf_id=1       qfi_id=2
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    4    4    Traffic_rate=mbps     ul_rate=10      pdu_id=1    trf_id=1       qfi_id=2
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    4    4    Traffic_rate=mbps     dl_rate=30     pdu_id=1    trf_id=1       qfi_id=3
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    4    4    Traffic_rate=mbps     ul_rate=30      pdu_id=1    trf_id=1       qfi_id=3

    sleep  302s
    Validate DL Traffic For SA custom    1    4    1    1
    #download_measurements    ${LOG_PATH}/    pre_before.zip

    sleep    10s
    ${Active_alarm}    ta5g_enb.get_active_alarms
    ${faluts_supres}    Create List    7535
    ${rc}     get_list_of_faults_check    ${Active_alarm}    ${faluts_supres}
    Should Contain    	${rc}	 fail
    Start TTI_TRACE custom    ${51}
    sleep     1s
    ${low_load}     Stop Log     ttitrace         test_scenario=low_load_by_config
    Decode TTI Trace    low_load_by_config
    sleep    300s
    #download_measurements    ${LOG_PATH}/    before.zip
    #clean_target    ${LOG_PATH}/pre_before/PERFMON_FILES/     ${LOG_PATH}/before/PERFMON_FILES/
    #${bef}    read_file_list    ${LOG_PATH}/before/PERFMON_FILES/   ${kpi_txt}    NR_5114b    NRCELL-1
    ${RUN1_END_TIME}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%dT%H:%M:%S.%fZ
    ${RUN1_END_TIME_ACTUAL}    ${EWAIT_MS}=   Round Time To Next 15 Min With Wait   ${RUN1_END_TIME}
    Sleep    ${EWAIT_MS}ms

    ${low_status}   get_cqi_derived_verify   ${low_load}[ttitrace]/output_dl_formated.csv    ${protected_slots}
    ${low_status_sche}    check_scheduling    ${low_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}
    Should Contain    	${low_status}	 false
    Should Contain    	${low_status_sche}    fail

    sleep    3600s

#
#    ${NR_5067a}       scout.get_kpi        NR_5067a   2026-03-18T16:30:00.000Z    2026-03-18T17:00:00.000Z     scoutalias
#    ${NR_5068a}       scout.get_kpi        NR_5068a   2026-03-18T16:30:00.000Z    2026-03-18T17:00:00.000Z    scoutalias
#    ${QAM64_M55300C00060}     scout.get_pm
#  ...    pm_id=M55300C00060
#  ...    interval=15
#  ...    start_time=2026-03-18T16:30:00.000Z
#  ...    end_time=2026-03-18T17:00:00.000Z
#  ...    alias=scoutalias
#
#    ${QAM256_M55300C00061}     scout.get_pm
#  ...    pm_id=M55300C00061
#  ...    interval=15
#  ...    start_time=2026-03-18T16:30:00.000Z
#  ...    end_time=2026-03-18T17:00:00.000Z
#  ...    alias=scoutalias



    ${NR_5067a}       scout.get_kpi        NR_5067a   ${RUN1_START_TIME_ACTUAL}  ${RUN1_END_TIME_ACTUAL}     scoutalias
    ${NR_5068a}       scout.get_kpi        NR_5068a   ${RUN1_START_TIME_ACTUAL}  ${RUN1_END_TIME_ACTUAL}     scoutalias
    ${QAM64_M55300C00060}     scout.get_pm
  ...    pm_id=M55300C00060
  ...    interval=15
  ...    start_time=${RUN1_START_TIME_ACTUAL}
  ...    end_time=${RUN1_END_TIME_ACTUAL}
  ...    alias=scoutalias

      ${QAM256_M55300C00061}     scout.get_pm
  ...    pm_id=M55300C00061
  ...    interval=15
  ...    start_time=${RUN1_START_TIME_ACTUAL}
  ...    end_time=${RUN1_END_TIME_ACTUAL}
  ...    alias=scoutalias


      cmp_kpi_cntr     ${NR_5067a}     ${QAM64_M55300C00060}
      cmp_kpi_cntr     ${NR_5068a}     ${QAM256_M55300C00061}


    ${KPI_REPORT1}=  Generate Scout Kpi Report   kpi_report1.json     ${TEMPLATE_ID}  ${RUN1_START_TIME_ACTUAL}  ${RUN1_END_TIME_ACTUAL}




[1]CB012719_A#B07_1_ CB012719 activation RIM_RS based DL muting with low cell load to high load switch

    ${tl_name}=    testline.Get Testline Name
    Configure Scout API    ${tl_name}    ${API_KEY}
    Enable Kpi Pm Collection
    ${RUN1_START_TIME}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%dT%H:%M:%S.%fZ
    ${RUN1_START_TIME_ACTUAL}    ${WAIT_MS}=   Round Time To Next 15 Min With Wait    ${RUN1_START_TIME}
    Sleep    ${WAIT_MS}ms
    ${RUN1_END_TIME}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%dT%H:%M:%S.%fZ
    ${RUN1_END_TIME_ACTUAL}    ${EWAIT_MS}=   Round Time To Next 15 Min With Wait   ${RUN1_END_TIME}
    Sleep    ${EWAIT_MS}ms
    Sleep     900s
    ${pre_NR_5114b}       scout.get_kpi        NR_5114b   ${RUN1_START_TIME_ACTUAL}  ${RUN1_END_TIME_ACTUAL}     scoutalias

    Perform SCF Delta Commissioning with change_thershold_to_low.json
    sleep    60s
    Perform SCF Delta Commissioning with off_rim_pwr_red.json
    sleep    60s
    Perform SCF Delta Commissioning with on_rim_pwr_red.json
    sleep    600s
    ${protected_slots}    Create List    ${2}    ${3}    ${12}    ${13}

    Configure Scout API    ${tl_name}    ${API_KEY}
    Enable Kpi Pm Collection
    ${RUN1_START_TIME}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%dT%H:%M:%S.%fZ
    ${RUN1_START_TIME_ACTUAL}    ${WAIT_MS}=   Round Time To Next 15 Min With Wait    ${RUN1_START_TIME}
    Sleep    ${WAIT_MS}ms
    ${RUN1_END_TIME}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%dT%H:%M:%S.%fZ
    ${RUN1_END_TIME_ACTUAL}    ${EWAIT_MS}=   Round Time To Next 15 Min With Wait   ${RUN1_END_TIME}
    Sleep    ${EWAIT_MS}ms
    Sleep     900s
    ${post_NR_5114b}       scout.get_kpi        NR_5114b   ${RUN1_START_TIME_ACTUAL}  ${RUN1_END_TIME_ACTUAL}     scoutalias



#    download_measurements    ${LOG_PATH}/    after.zip
#    clean_target    ${LOG_PATH}/pre_before/PERFMON_FILES/     ${LOG_PATH}/after/PERFMON_FILES/
#    clean_target    ${LOG_PATH}/before/PERFMON_FILES/    ${LOG_PATH}/after/PERFMON_FILES/
#    ${aft}    read_file_list    ${LOG_PATH}/after/PERFMON_FILES/   ${kpi_txt}    NR_5114b    NRCELL-1
#    ${kpi_res}    cmp_kpis     ${LOG_PATH}/before/PERFMON_FILES/    ${LOG_PATH}/after/PERFMON_FILES/    ${kpi_txt}    NR_5114b
#    ...      NRCELL-1
    sleep    60s
    Start TTI_TRACE custom    ${51}
    sleep     1s
    ${high_load}     Stop Log     ttitrace         test_scenario=high_load_by_config
    Decode TTI Trace    high_load_by_config

    ${high_status}   get_cqi_derived_verify   ${high_load}[ttitrace]/output_dl_formated.csv    ${protected_slots}
    ${high_status_sche}    check_scheduling    ${high_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}

     Should Contain    	${high_status}	 pass
     Should Contain    	${high_status_sche}    pass

[1]CB012719_A#B06_3_CB012719 Manually triggered DL muting is combined with RIM-RS based DL muting with high cell load
    Perform SCF Delta Commissioning with change_thershold_to_high.json
    sleep    60s
    Perform SCF Delta Commissioning with enable_manual_miti_2dl.json
    sleep    60s
    Perform SCF Delta Commissioning with off_rim_pwr_red.json
    sleep    60s
    Perform SCF Delta Commissioning with on_rim_pwr_red.json
    sleep    60s
    ${protected_slots}    Create List    ${1}    ${2}    ${3}    ${11}    ${12}    ${13}
    sleep  302s
#    download_measurements    ${LOG_PATH}/    B07_pre_before.zip

    sleep    10s
    ${Active_alarm}    ta5g_enb.get_active_alarms
    ${faluts_supres}    Create List    7535
    ${rc}     get_list_of_faults_check    ${Active_alarm}    ${faluts_supres}
    Should Contain    	${rc}	 fail
    Start TTI_TRACE custom    ${51}
    sleep     1s
    ${low_load}     Stop Log     ttitrace         test_scenario=low_load_by_config_man
    Decode TTI Trace    low_load_by_config_man
    sleep    300s
#    download_measurements    ${LOG_PATH}/    B07_before.zip
#    clean_target    ${LOG_PATH}/B07_pre_before/PERFMON_FILES/     ${LOG_PATH}/B07_before/PERFMON_FILES/
#    ${bef}    read_file_list    ${LOG_PATH}/B07_before/PERFMON_FILES/   ${kpi_txt}    NR_5114b    NRCELL-1
    ${low_status}   get_cqi_derived_verify   ${low_load}[ttitrace]/output_dl_formated.csv    ${protected_slots}
    ${low_status_sche}    check_scheduling    ${low_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}
     Should Contain    	${low_status}	 false
     Should Contain    	${low_status_sche}    fail

[1]CB012719_A#B07_3_ CB012719 activation Manually triggered DL muting is combined with RIM-RS based DL muting with low cell load
    Perform SCF Delta Commissioning with change_thershold_to_low.json
    sleep      60s
    Perform SCF Delta Commissioning with update_pwr_val.json
    sleep    600s
    ${protected_slots}    Create List    ${1}    ${2}    ${3}    ${11}    ${12}    ${13}
#    download_measurements    ${LOG_PATH}/   B07_after.zip
#    clean_target    ${LOG_PATH}/B07_pre_before/PERFMON_FILES/     ${LOG_PATH}/B07_after/PERFMON_FILES/
#    clean_target    ${LOG_PATH}/B07_before/PERFMON_FILES/    ${LOG_PATH}/B07_after/PERFMON_FILES/
#    ${aft}    read_file_list    ${LOG_PATH}/B07_after/PERFMON_FILES/   ${kpi_txt}    NR_5114b    NRCELL-1
#    cmp_kpis     ${LOG_PATH}/B07_before/PERFMON_FILES/    ${LOG_PATH}/B07_after/PERFMON_FILES/    ${kpi_txt}    NR_5114b
#    ...      NRCELL-1
    sleep     60s
    Start TTI_TRACE custom    ${51}
    sleep     1s
    ${high_load}     Stop Log     ttitrace         test_scenario=high_load_by_config_man
    Decode TTI Trace    high_load_by_config_man

    ${high_status}   get_cqi_derived_verify   ${high_load}[ttitrace]/output_dl_formated.csv    ${protected_slots}
    ${high_status_sche}    check_scheduling    ${high_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}
     Should Contain    	${high_status}	 pass
     Should Contain    	${high_status_sche}    pass

    Perform SCF Delta Commissioning with change_thershold_to_high.json
    sleep    60s
    Perform SCF Delta Commissioning with off_rim_pwr_red.json
    sleep    60s
    Perform SCF Delta Commissioning with on_rim_pwr_red.json
    sleep    60s
    Perform SCF Delta Commissioning with enable_high_pri.json
    sleep    60s
    Start TTI_TRACE custom    ${51}
    sleep     1s
    ${high_load}     Stop Log     ttitrace         test_scenario=high_load_by_config_man_high
    Decode TTI Trace    high_load_by_config_man_high

    ${high_status_sche}    check_scheduling    ${high_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}
    Should Contain    	${high_status_sche}    pass

    Perform SCF Delta Commissioning with disable_high_pri.json
    sleep     60s

    Start TTI_TRACE custom    ${51}
    sleep     1s
    ${low_load}     Stop Log     ttitrace         test_scenario=low_load_by_config_man_high
    Decode TTI Trace    low_load_by_config_man_high
    sleep    60s
    ${low_status_sche}    check_scheduling    ${low_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}
    Should Contain    	${low_status_sche}    fail


[1]CB012719_A#B08_2_ CB012719 activation RIM_RS based DL muting with high cell load to low load switch
    Perform SCF Delta Commissioning with disable_high_pri.json
    sleep    60s
    Perform SCF Delta Commissioning with disable_manual_miti_2dl.json
    sleep    60s
    Perform SCF Delta Commissioning with change_thershold_to_high.json
    sleep    60s
    Perform SCF Delta Commissioning with enable_ri_based_rim_rs.json
    sleep    60s
    Perform SCF Delta Commissioning with off_rim_pwr_red.json
    sleep    60s
    Perform SCF Delta Commissioning with on_rim_pwr_red.json
    sleep    60s
    ${protected_slots}    Create List        ${2}    ${3}       ${12}    ${13}
    sleep  302s
#    download_measurements    ${LOG_PATH}/    A_B07_pre_before.zip

    sleep    10s
    ${Active_alarm}    ta5g_enb.get_active_alarms
    ${faluts_supres}    Create List    7535
    ${rc}     get_list_of_faults_check    ${Active_alarm}    ${faluts_supres}
    Should Contain    	${rc}	 fail
    Start TTI_TRACE custom    ${51}
    sleep     1s
    ${low_load}     Stop Log     ttitrace         test_scenario=low_load_by_config_ri
    Decode TTI Trace    low_load_by_config_ri
    sleep    300s
#
#    download_measurements    ${LOG_PATH}/    A_B07_before.zip
#    clean_target    ${LOG_PATH}/A_B07_pre_before/PERFMON_FILES/     ${LOG_PATH}/A_B07_before/PERFMON_FILES/
#    ${bef}    read_file_list    ${LOG_PATH}/A_B07_before/PERFMON_FILES/   ${kpi_txt}    NR_5114b    NRCELL-1


    Perform SCF Delta Commissioning with change_thershold_to_low.json
    sleep    600s

#    download_measurements    ${LOG_PATH}/   A_B07_after.zip
#    clean_target    ${LOG_PATH}/A_B07_pre_before/PERFMON_FILES/     ${LOG_PATH}/A_B07_after/PERFMON_FILES/
#    clean_target    ${LOG_PATH}/A_B07_before/PERFMON_FILES/    ${LOG_PATH}/A_B07_after/PERFMON_FILES/
#    ${aft}    read_file_list    ${LOG_PATH}/A_B07_after/PERFMON_FILES/   ${kpi_txt}    NR_5114b    NRCELL-1
#    cmp_kpis     ${LOG_PATH}/A_B07_before/PERFMON_FILES/    ${LOG_PATH}/A_B07_after/PERFMON_FILES/    ${kpi_txt}    NR_5114b
#    ...      NRCELL-1
    sleep    60s
    Start TTI_TRACE custom    ${51}
    sleep     1s
    ${high_load}     Stop Log     ttitrace         test_scenario=high_load_by_config_ri
    Decode TTI Trace    high_load_by_config_ri

    ${high_status}   get_cqi_derived_verify   ${high_load}[ttitrace]/output_dl_formated.csv    ${protected_slots}
    ${high_status_sche}    check_scheduling    ${high_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}

    ${low_status}   get_cqi_derived_verify   ${low_load}[ttitrace]/output_dl_formated.csv    ${protected_slots}
    ${low_status_sche}    check_scheduling    ${low_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}


     Should Contain    	${low_status}	 false
     Should Contain    	${low_status_sche}    fail
     Should Contain    	${high_status}	 pass
     Should Contain    	${high_status_sche}    pass

    Perform SCF Delta Commissioning with change_thershold_to_high.json
    sleep    60s
    Perform SCF Delta Commissioning with off_rim_pwr_red.json
    sleep    60s
    Perform SCF Delta Commissioning with on_rim_pwr_red.json
    sleep    60s
    Perform SCF Delta Commissioning with enable_high_pri.json
    sleep    60s
    Start TTI_TRACE custom    ${51}
    sleep     1s
    ${high_load}     Stop Log     ttitrace         test_scenario=high_load_by_config_man_high
    Decode TTI Trace    high_load_by_config_man_high

    ${high_status_sche}    check_scheduling    ${high_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}
    Should Contain    	${high_status_sche}    pass

    Perform SCF Delta Commissioning with disable_high_pri.json
    sleep    60s
    Start TTI_TRACE custom    ${51}
    sleep     1s
    ${low_load}     Stop Log     ttitrace         test_scenario=low_load_by_config_man_high
    Decode TTI Trace    low_load_by_config_man_high
    sleep    60s
    ${low_status_sche}    check_scheduling    ${low_load}[ttitrace]/output_dl_formated.csv     ${protected_slots}
    Should Contain    	${low_status_sche}    fail
    Perform SCF Delta Commissioning with disable_ri_based_rim_rs.json

*** Keywords ***
Validate DL Traffic For SA custom
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}    ${end_ue}     ${pdu_id}     ${qfi_id}
#    Builtin.Log     ${dl_rate}
    FOR    ${i}    IN RANGE    ${ue_id}    ${end_ue}+${1}
    ${bearer_stats_cmd}	SET VARIABLE	bearer_stats ue=${i} pdu=${pdu_id} qfi=${qfi_id} dir=dl
    ${bearer_stat_dl}		Execute Egate Command And Wait For Data   ${bearer_stats_cmd}	pass_regexp=Average packet interval
    ...                     timeout=30
    END
    #wts_sim_keywords.Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    #Run keyword and Ignore Error    wts_sim_keywords.Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}

MultiUE PDU Modfication should be Successful selective
    [Arguments]     ${pdu_id}      ${ue_to_qos_map}

    ${ue_list}     Get Dictionary Keys    ${ue_to_qos_map}

	FOR     ${ue_idx}   IN      @{ue_list}
	${qosflows_to_add}     Get From Dictionary	${ue_to_qos_map}	${ue_idx}
    Add Qos flows one by one    ${ue_idx}    ${pdu_id}    ${qosflows_to_add}
    END
    BuiltIn.Log       All_ue_added_an_extra_qosflow_successfully
	Log to Console    All_ue_added_an_extra_qosflow_successfully


Add Qos flows one by one
    [Arguments]     ${ue_idx}     ${pdu_id}      ${qosflows_to_add}
    ${qosflows_to_add}    Split String	${qosflows_to_add}    ,
    FOR     ${qosflow}    IN    @{qosflows_to_add}
        ${pdu_modify}	SET VARIABLE	ue_pdu_session_modify ue=${ue_idx} pdu=${pdu_id} qosflows_to_add=${qosflow} by=amf
        ${output}	Execute Egate Command And Wait For Data   ${pdu_modify}		pass_regexp=${Pdu_session_qos_patten}
        ...     timeout=${Timeout_SA}
        BuiltIn.Log               ue=${ue_idx} qosflow=${qosflows_to_add} added
        Log to Console            ue=${ue_idx} qosflow=${qosflows_to_add} added
    END
MultiUE Trigger DL Traffic for SA on qfi
    [Arguments]     ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${dl_rate}    ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    ${data_cmd}	SET VARIABLE	trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=${qfi_id} dir=dl ${Traffic_rate}=${dl_rate} trf_id=${trf_id}
    ${output}	      Execute Egate Command And Wait For Data   ${data_cmd}    pass_regexp=Started Downlink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
	END
    BuiltIn.Log    DL_traffic_data_is_started_successfully

UE Register should be Successful sim
    [Arguments]    ${ue_id}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file

    ${ue_reg_cmd}   SET VARIABLE        ue_register id=${ue_id}
    Execute Egate Command    ${ue_reg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}

UE Deregister should be Successful sim
    [Arguments]    ${ue_id}
    [Documentation]    This keyword checks the message for the completion of UE deregistration in the output file
    ${deregister_cmd}    SET VARIABLE    ue_deregister id=${ue_id} ue_deregister_type=switch_off by=ue
    Execute Egate Command    ${deregister_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}

Trigger VONR custom data
	[Arguments]    ${ue_id}     ${dir}		${pdu_id}     ${trf_id}		${qfi}		${Traffic_unit}		${traffic_rate}		${rtp_codec}
    [Documentation]    This keyword starts the vonr data
    Builtin.Log     ${Traffic_unit}
    Builtin.Log     ${traffic_rate}
    Log to Console    \nRunning Traffic
	${data_cmd}	SET VARIABLE	trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=${dir} trf_id=${trf_id} rtp_codec=${rtp_codec}
    Execute Egate Command And Wait For Data		${data_cmd}		timeout=${EGATE_COMMAND_TIMEOUT}
Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgS4SsiuoeE23c8C -P ${CURDIR}/BSR
    coam.setup admin
     ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
     coam.teardown admin
