*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_TDD
...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation
...  AUTHOR          :   Ganesha.U  ganesha.u@nokia.com
...  MAINTAINER      :   Ganesha.U  ganesha.u@nokia.com
...  INTRODUCTION    :   CB010866 RIM Mitigation Enhancemment
...  TEST SET NAME   :   CB010866_D_01_Robustness_Activate_related_measurements_to_monitor_the_counters_
...                      related_to_number_of_RIM-RS_detected_per_distance.
...  TESTING SPLIT   :   Split-D
...  CONTACTS        :   Ganesha.u@nokia.com
...  REFERENCES      :   CB010866-CFAM
...  REQUIREMENT ID  :   5G_PM_1618

Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Library          ../../../resources/python/avg_dl_data.py
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../5GC000937/resources/MultiUe_MultiDRB_Wrapper_Keyword.robot
Resource         ../../../resources/robot/counter_benchmark_resource.robot
Resource         CB010866_resource.robot
Library          ta5g_pm_counters
Library          python/common_gnb.py
Library          ta5g_enb
Library    taf.transport.ssh  WITH NAME  ssh
Library      taf.sbts.oam.coam.admin


Suite Setup         Run keywords    Suite setup from scratch
...                 AND    Perform SCF Delta Commissioning with TMO_RIMRS.json
...                 AND    Perform SCF Delta Commissioning with RRC_Inactive.json
...                 AND    Perform SCF Delta Commissioning with Vonr_GBR.json
...                 AND    Update GNB R&D Parameters    ${LOG_PATH}   ${r&d_parameter}
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
...                 AND    Configure eth3 IP
...                 AND    Load Cfg File

Suite Teardown     Run Keyword and Ignore Error     Get Sos Report

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts/TMO_basic.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${r&d_parameter}       0x58057f=262219;0x590072=1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${nwslice_ID}    1
&{Vonr_qos}       5=5    6=1
&{qfi_ids_vonr}        5=2    1=3
&{GBR_qos}        7=4
&{qfi_ids_gbr}    4=2
${NOISE_POWER_RI}=       SEPARATOR=
...                       -55,-55,-55,-60,-60,-60,-65,-65,-65,-70,-70,-75,-75,-115,-115,-115,-115,
...                       -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115
${target_dir}=    /home/ute/Desktop/
${counter_json_file}=    ${CURDIR}/config/Counters.json
${host}=   192.168.255.129
${user}=   Nemuadmin
${password}=   nemuuser
${git_path}=   https://gitlabe1.ext.net.nokia.com/BTS_TOOLS/counter_benchmarking/-/blob/main/Bangalore/VRF_BLR1/T09/CB010866_Counter_Benchmking.xlsx
${BTS_ADDRESS}    192.168.255.129
${BTS_PORT}       443
${USE_SSL}        True
*** Test Cases ***
[1]CB010866_D_01_Robustness_Activate_related_measurements_to_monitor_the_counters_related_to_number_of_RIM-RS_detected_per_distance.
    Set test variable      ${LOG_PATH}
    Check CNI-141907 NIDD parameters activated
    MultiUe MultiDBR registration Should Be Successful
    Verify The Counter DL UL    600    5
    Start_Fetching_Counter_Values
    Verify RSSI For all 5 SB
    FOR    ${item}    IN RANGE   ${70}   ${75}    ${5}
         Start Log   btslog
         Repeat RI RS1 and RS2 Transmission    ${item}
         ${syslog_path}    Stop Log    btslog    test_scenario=syslog${item}
    END
    Stop log    snapshot  test_scenario=snap
    Stop_Fetching_Counter_Values
    Run Keyword And Continue On Failure    Collect_Counter_Logs      ${host}     ${user}      ${password}
    ...     ${target_dir}    ${counter_json_file}         ${git_path}
    [Teardown]    Run Keywords  Link SCOUT SCF to Configuration ID for Reporting
    ...   AND         Check resource hanging

*** Keywords ***
Update GNB R&D Parameters
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   admin.Setup admin    bts_host=${BTS_ADDRESS}   bts_port=${BTS_PORT}   use_ssl=${USE_SSL}   name=swc
   admin.download_software_config    ${LOG_PATH}/swconfig_gnb.txt   connection=swc
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   ssh.connect_to    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    alias=OAM-conn
   ssh.upload_file    local_path=${LOG_PATH}/swconfig_gnb.txt     remote_path=/ffs/run/swconfig.txt    connection=OAM-conn
   ssh.send_command     command=crasign /ffs/run/swconfig.txt   connection=OAM-conn
   ssh.send_command     command=craverify /ffs/run/swconfig.txt*    connection=OAM-conn
   ssh.disconnect   connection=OAM-conn

Load Cfg File
    Start Collecting gNB Syslog
    Start CPRT capture
    Load CFG and verify cell status   ${wts_cfg_file}   1    4
    Stop CPRT capture common     log_dir=${LOG_PATH}
    Stop Syslog    log_dir=${LOG_PATH}

MultiUe MultiDBR registration Should Be Successful
    Ue RRC Inactive state should be successful    36    40
    Register ALL Ues and Send Low data    Start_ue=1    End_ue=35
    Log to console    Adding Vonr Ues
    QosFlow addition should be Successful     1   10      ${Vonr_qos}     ${qfi_ids_vonr}
    Log to console    Adding GBR Ues
    QosFlow addition should be Successful     11   20      ${GBR_qos}     ${qfi_ids_gbr}
    #Start Multi UE UL traffic with multiple trafficID     start_ue=1   end_ue=35    Traffic_rate=mbps    ul_trf_id=1    qfi_id=1    ul_rate_UL=10
    Start Multi UE DL traffic with multiple trafficID     start_ue=21   end_ue=25    Traffic_rate=mbps    dl_trf_id=1    qfi_id=1    dl_rate_DL=10
    Start Multi UE DL traffic with multiple trafficID     start_ue=26   end_ue=35    Traffic_rate=mbps    dl_trf_id=1    qfi_id=1    dl_rate_DL=60

Check CNI-141907 NIDD parameters activated
   ${gnbOvlProtMode}     get_parameter_value_from_scf      dist_name=NRBTS-1      parameter=gnbOvlProtMode
   ${ovlNsaAddRej}       get_parameter_value_from_scf      dist_name=NRBTS-1      parameter=ovlNsaAddRej
   ${ovlSaRrcRej}        get_parameter_value_from_scf      dist_name=NRBTS-1      parameter=ovlSaRrcRej    index=1
   Should be True    "${gnbOvlProtMode}"=="classical"
   Should be True    "${ovlNsaAddRej}"=="enabled"
   Should be True    "${ovlSaRrcRej}"=="true"

Repeat RI RS1 and RS2 Transmission
    [Arguments]    ${item}
    Activate RI    2
    Log to console    RI Triggered
    Wait For Fault To Be Up     fault_id=7525   timeout=800
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    ...    cell=NRCELL-2
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...     description=DL mitigation on PDSCH preceding slot    cell=NRCELL-2
    Verify The Counter DL UL    600    5
    GenerateRS1    ${item}    2
    Log to console     RS1 Triggered
    Wait For Fault To Be Up     fault_id=7527   timeout=2000
    Verify Fault Description    faultid=${7527}    faultname=RIM-RS detected
    ...     description=RIM RS1 is detected, detected RIM RS1 setIDs list is 44444
    ...     cell=NRCELL-2
    Verify RS1 Counters
    DeactivateRS1     ${item}   2
    Wait For Fault To Be down     fault_id=7527   timeout=800
    ${RS2}   Evaluate    ${item}+${1}
    GenerateRS2    ${RS2}   2
    Log to console     RS2 Triggered
    Wait For Fault To Be Up     fault_id=7527   timeout=2000
    Verify Fault Description    faultid=${7527}    faultname=RIM-RS detected
    ...     description=RIM RS2 is detected, detected RIM RS2 setIDs list is 44444
    ...     cell=NRCELL-2
    Verify RS2 Counters
    DeactivateRS2     ${RS2}   2
    Wait For Fault To Be down     fault_id=7527   timeout=800
    Deactivate RI   2
    Log to console     RI deactivated and waiting for 7525 down.
    Wait For Fault To Be down     fault_id=7525   timeout=500
    Log to console    alarm 7535 will go down after 10 min of RI disappear.
    Wait For Fault To Be down     fault_id=7535   timeout=650
    sleep  10s  reason=stable data

Register UE and Send High Data
    ${rnti}    wts_sim_keywords.UE Register should be Successful And Fetch RNTI    ue_id=5
    FOR    ${trf}    IN RANGE   ${1}   ${6}
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=5      Traffic_rate=mbps     dl_rate=175     pdu_id=1   trf_id=${trf}
    END
    wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=5      Traffic_rate=mbps     ul_rate=175     pdu_id=1   trf_id=1
    wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=5      Traffic_rate=mbps     ul_rate=175     pdu_id=1   trf_id=2
    sleep    10s

Check Throughput
    [Arguments]    ${cell_id}    ${dl}    ${ul}
    ${DL_stats}    Get Max DL Cell throughput    cell_id=${cell_id}
    ${UL_stats}    Get Max UL Cell throughput    cell_id=${cell_id}
    Should be True    ${DL_stats} > ${dl}
    Should be True    ${UL_stats} > ${ul}

Verify RS1 Counters
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    ${Special_slots}  ta5g_pm_counters.get_pm_counter_value   M55194C00003    MRBTS-1/NRBTS-1/NRCELL-2  ${pm_counter_file}
    ${RS1_9}   ta5g_pm_counters.get_pm_counter_value   M55194C00177   MRBTS-1/NRBTS-1/NRCELL-2  ${pm_counter_file}
    ${RS1_10}  ta5g_pm_counters.get_pm_counter_value   M55194C00178   MRBTS-1/NRBTS-1/NRCELL-2  ${pm_counter_file}
    #Should be True    ${Special_slots}[0] == 300.0
    Run Keyword If   ${RS1_9}[0] == 1.0   Should be True    ${RS1_9}[0] == 1.0
    ...  ELSE   Should be True    ${RS1_10}[0] == 1.0

Verify RS2 Counters
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    ${Special_slots}  ta5g_pm_counters.get_pm_counter_value   M55194C00003    MRBTS-1/NRBTS-1/NRCELL-2  ${pm_counter_file}
    ${RS2_9}   ta5g_pm_counters.get_pm_counter_value   M55194C00233   MRBTS-1/NRBTS-1/NRCELL-2  ${pm_counter_file}
    ${RS2_10}  ta5g_pm_counters.get_pm_counter_value   M55194C00234   MRBTS-1/NRBTS-1/NRCELL-2  ${pm_counter_file}
    #Should be True    ${Special_slots} == 300.0
    Run Keyword If   ${RS2_9}[0] == 1.0   Should be True    ${RS2_9}[0] == 1.0
    ...  ELSE   Should be True    ${RS2_10}[0] == 1.0

Verify RSSI For all 5 SB
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55194C00009    !\=0     RSSI_SB1
    ...     M55194C00010    !\=0     RSSI_SB2
    ...     M55194C00011    !\=0     RSSI_SB3
    ...     M55194C00012    !\=0     RSSI_SB4
    ...     M55194C00013    !\=0     RSSI_SB5
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-2
    ...     file_path=${pm_counter_file}

GenerateRS1
    [Arguments]    ${profile}   ${cell_id}
    ${RS1}=    Catenate    SEPARATOR=
    ...  rimrs_testmode_nr profile_id=${profile} config_mode=standalone aggressor_cell=2 victim_cell=2 rsSetId=44444
    ...  \ numRsSetId=1 rimRsType=rsType1 propagation_delay=16 rsType2NScId=1,2,3,4,5,6,7,8 rsPattern1Period=50
    ...  \ rsPattern2Period=25 factorRsSequence=1 factorRsSequenceRS2=1 offsetRsSequence=1 offsetRsSequenceRS2=1
    ...  \ repetitionRsType2=4 rim_framework=framework_1 numRsType2SetId=131072 numRsType1SetId=131072 repetitionRsType1=4
    ...  \ globalF0ForRs=509064 startFreqOffsetForRs=10
    ute_wtssim.Execute Egate Command     cmd=${RS1}
    sleep  5s
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=${cell_id} gnb=2 testmode=rim_rs profile_id=${profile} action=activate

GenerateRS2
    [Arguments]    ${profile}   ${cell_id}
    ${RS2}=    Catenate    SEPARATOR=
    ...  rimrs_testmode_nr profile_id=${profile} config_mode=standalone aggressor_cell=2 victim_cell=2 rsSetId=44444
    ...  \ numRsSetId=1 rimRsType=rsType2 propagation_delay=16 rsType2NScId=1,2,3,4,5,6,7,8 rsPattern1Period=50
    ...  \ rsPattern2Period=25 factorRsSequence=1 factorRsSequenceRS2=1 offsetRsSequence=1 offsetRsSequenceRS2=1
    ...  \ repetitionRsType2=4 rim_framework=framework_1 numRsType2SetId=131072 numRsType1SetId=131072 repetitionRsType1=4
    ...  \ globalF0ForRs=509064 startFreqOffsetForRs=10
    ute_wtssim.Execute Egate Command     cmd=${RS2}
    sleep  5s
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=${cell_id} gnb=2 testmode=rim_rs profile_id=${profile} action=activate

DeactivateRS1
    [Arguments]    ${profile}   ${cell_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=${cell_id} gnb=2 testmode=rim_rs profile_id=${profile} action=deactivate
    sleep  3s

DeactivateRS2
    [Arguments]    ${profile}   ${cell_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=${cell_id} gnb=2 testmode=rim_rs profile_id=${profile} action=deactivate
    sleep  3s

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

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/MN/UTE/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI