*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD

Documentation
...  AUTHOR          :   Kiran.G  kiran.1.g@nokia.com
...  MAINTAINER      :   Kiran.G  kiran.1.g@nokia.com
...  INTRODUCTION    :   CB013138 RIM Mitigation Enhancemment
...  TEST SET NAME   :   CB013138_A_02_D_02_RIMRS1_RS2_based_DL_mitigation
...  TESTING SPLIT   :   Split-A , Split-B , Split-D
...  CONTACTS        :   kiran.1.g@nokia.com
...  REFERENCES      :   CB013138-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_26491;5G_RAN_USR_RRM_26492;5G_RAN_USR_RRM_26504;CB_FIM_48841;5G_PM_1974
...  Requirement ID  :   5G_RAN_USR_RRM_17671


Library          taf.transport.ssh         WITH NAME    taf_ssh
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource        ./CB009215_keyword.robot
Resource         ./CB013138_resource.robot
Resource         ../../../resources/robot/PM_Counters.robot
Library          ta5g_enb
Library          taf.sw.scout    WITH NAME     scout


*** Variables ***

##${wts_cfg_file}        ${CURDIR}/wts/basic.cfg
${wts_cfg_file}        ${WTS_DIR}/basic_setup.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${r&d_parameter}       0x58057f=262223;0x58057a=4
${NOISE_POWER_RI}=       SEPARATOR=
...                       -55,-55,-55,-60,-60,-60,-65,-65,-65,-70,-70,-75,-75,-115,-115,-115,-115,
...                       -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115
${TLConfig.isUTE}   True
${tl.core}      ${None}


*** Test Cases ***
[1]CB013138_A_02_D_02_RIMRS1_RS2_based_DL_mitigation

    [Tags]    TC01
	[Setup]    Run keywords    Suite setup from scratch
	...                 AND    Perform SCF Delta Commissioning with FrameStructure_1116_3ms_4GP.json
	...                 AND    Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
	...                 AND    gnb.Perform gNB reboot
	...                 AND    Sleep   700s    reason=wait for RMOD to comeup
	...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   1    1

    Set test variable      ${LOG_PATH}
    Setup X2 Link
    Perform SCF Delta Commissioning with Framework0_RS1_DL_Mitigation.json
    sleep  20s  reason=Wait for RIParameterexecution
    Register and Send High Data
    Check Tput    ue_id=1   scell_idx=0
    RIM RS1 RS2 Detection and Mitigation and Check Alarm
    sleep  10s  reason=stable data
    Stop log    snapshot  test_scenario=snap

	[Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     wts_sim_keywords.Clean edaemon and egate
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting


[1]CB013138_B_01_B_02_RIMRS1_RS2_NearFar_Disabled_Enabled

    [Tags]    TC02
	[Setup]    Run keywords    Suite setup from scratch
	...                 AND    Perform SCF Delta Commissioning with FrameStructure_1116_3ms_4GP.json
	...                 AND    Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
	...                 AND    gnb.Perform gNB reboot
	...                 AND    Sleep   700s    reason=wait for RMOD to comeup
	...                 AND    Configure UTE ETH3 IPs
	...                 AND    Load CFG and verify cell status   ${wts_cfg_file}   1    4

    Set test variable      ${LOG_PATH}
    Setup X2 Link
    Perform SCF Delta Commissioning with Framework0_RS1_DL_Mitigation_withrsdistancethreshold.json
    sleep  20s  reason=Wait for RIParameterexecution
    Register and Send High Data
    Check Tput    ue_id=1   scell_idx=0
    RIM RS1 RS2 Detection with NearFar disabled enabled with rsdistancethreshold
    sleep  10s  reason=stable data
    Stop log    snapshot  test_scenario=snap

	[Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     wts_sim_keywords.Clean edaemon and egate
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
RIM RS1 RS2 Detection and Mitigation and Check Alarm
    Start Log    btslog
    Activate RI
    Log to console    RI Triggered
    Wait For Fault To Be Up     fault_id=7525   timeout=400
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Generate RS1    profile=200		delay=26
    Wait For Fault To Be Up     fault_id=7527   timeout=600
    Log to Console    RS1 is generated
    Verify Fault Description    faultid=${7527}    faultname=RIM-RS detected
    ...     description=RIM RS1 is detected
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH special slot plus two preceding slots
    Log to Console    Counter Validation
    Verify The Counter for Special and 2 DL Slots with RIM RS1
    Deactivate RS1    profile=200
    Wait For Fault To Be Down   fault_id=7527   timeout=600
    Wait For Fault To Be Down   fault_id=7535   timeout=100
	Log to Console    Counter Validation for No Muting
	Verify The Counter for No Muting
    Deactivate RI
    Log to console     RI deactivated and waiting for 7525 down after RI disappear
    Wait For Fault To Be down     fault_id=7525   timeout=400
    sleep   200s    reason=Wait time for Framework1
    Log to console     Change the PDCCH Muting false on Special slot and Framework1
    Perform SCF Delta Commissioning with Framework1_RS1_RS2_PDCCHMuting_false.json
    sleep    100s
    Activate RI
    Log to console    RI Triggered
    Wait For Fault To Be Up     fault_id=7525   timeout=400
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Generate RS1andRS2    profile=250	delay=26	nearfar=0       globalfoforrs=528432    startfreq1=0    startfreq2=48
    Wait For Fault To Be Up     fault_id=7527   timeout=600
    sleep   300s
    Log to console    Wait for both RS1 and RS2
    #Log to Console    RS1 and RS2 is generated
    Verify Fault Description    faultid=${7527}    faultname=RIM-RS detected
    ...     description=Both RIM RS1 and RS2 are detected
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH special slot plus two preceding slots
    Log to Console    Counter Validation
    Verify The Counter for Special and 2 DL Slots with RIM RS1 and RS2
    Deactivate RS1andRS2    profile=250
    Wait For Fault To Be Down   fault_id=7527   timeout=600
    Wait For Fault To Be Down   fault_id=7535   timeout=100
	Log to Console    Counter Validation for No Muting
	Verify The Counter for No Muting
    Deactivate RI
    Log to console     RI deactivated and waiting for 7525 down after RI disappear
    Wait For Fault To Be down     fault_id=7525   timeout=400
    ${syslog_path}    Stop Log    btslog    test_scenario=syslog
    sleep    5s

Verify The Counter for Special and 2 DL Slots with RIM RS1
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${UL_SYMB_IMP_RI}   Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00001    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Special_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00281    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_2_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00282    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${NUM_RIM_RS1_Detected}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00005   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS1_21}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00189   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS1_22}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00190   moc=MRBTS-1/NRBTS-1/NRCELL-1
    Should be True    ${Special_slot} >= 298.0
    Should be True    ${Preceding_DL_slot} >= 298.0
    Should be True    ${Preceding_2_DL_slot} >= 298.0
    Should be True    ${NUM_RIM_RS1_Detected} != 0
    Run Keyword If   ${RS1_21} == 1.0   Should be True    ${RS1_21} == 1.0
    ...  ELSE   Should be True    ${RS1_22} == 1.0
    Log to console    Number of UL Symbol IMpacted by RI is ${UL_SYMB_IMP_RI}
    Log to console    Number of Detected SET ID is ${NUM_RIM_RS1_Detected}

Verify The Counter for Special and 2 DL Slots with RIM RS1 and RS2
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${UL_SYMB_IMP_RI}   Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00001    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Special_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00281    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_2_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00282    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${NUM_RIM_RS1_Detected}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00005   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${NUM_RIM_RS2_Detected}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00006   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS1_21}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00189   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS1_22}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00190   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS2_21}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00245   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS2_22}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00246   moc=MRBTS-1/NRBTS-1/NRCELL-1
    Should be True    ${Special_slot} >= 298.0
    Should be True    ${Preceding_DL_slot} >= 298.0
    Should be True    ${Preceding_2_DL_slot} >= 298.0
    Should be True    ${NUM_RIM_RS1_Detected} != 0
    Should be True    ${NUM_RIM_RS2_Detected} != 0
    Run Keyword If   ${RS1_21} == 1.0   Should be True    ${RS1_21} == 1.0
    ...  ELSE   Should be True    ${RS1_22} == 1.0
    Run Keyword If   ${RS2_21} == 1.0   Should be True    ${RS2_21} == 1.0
    ...  ELSE   Should be True    ${RS2_22} == 1.0
    Log to console    Number of UL Symbol IMpacted by RI is ${UL_SYMB_IMP_RI}
    Log to console    Number of Detected SET ID for RS1 is ${NUM_RIM_RS1_Detected}
    Log to console    Number of Detected SET ID for RS2 is ${NUM_RIM_RS2_Detected}

RIM RS1 RS2 Detection with NearFar disabled enabled with rsdistancethreshold
    Start Log    btslog
    Activate RI
    Log to console    RI Triggered
    Wait For Fault To Be Up     fault_id=7525   timeout=400
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Generate RS1    profile=200		delay=12
    Wait For Fault To Be Down     fault_id=7527   timeout=600
    Wait For Fault To Be Down     fault_id=7535   timeout=100
#    Perform SCF Delta Commissioning with rsdistancethreshold_set_4.json
    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-1/NRRIM_PROFILE-1       update      rsDistanceThreshold      4
	Wait For Fault To Be Up     fault_id=7527   timeout=300
	Verify Fault Description    faultid=${7527}    faultname=RIM-RS detected
    ...     description=RIM RS1 is detected
	Wait For Fault To Be Up     fault_id=7535   timeout=60
	Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH special slot plus the preceding slot
	Log to Console    Counter Validation
    Verify The Counter for Special and DL Slot with RIM RS1
	Deactivate RI
	Deactivate RS1    200
	Log to console     RI deactivated and waiting for 7525 7527 7535 down after RI disappear
	Wait For Fault To Be down     fault_id=7525   timeout=400
	Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-1/NRRIM_PROFILE-1       update      rsDistanceThreshold      8
	Wait For Fault To Be down     fault_id=7527   timeout=400
	Wait For Fault To Be down     fault_id=7535   timeout=400
	Log to Console    Counter Validation for No Muting
	Verify The Counter for No Muting
    sleep   200s    reason=Wait time for Framework1
    Log to console     Change to Framework1 with NearFar enabled
    Perform SCF Delta Commissioning with Framework1_RS1_RS2_NearFar_enabled.json
    sleep    100s
    Activate RI
    Log to console    RI Triggered
    Wait For Fault To Be Up     fault_id=7525   timeout=400
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
#    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-1/NRRIM_PROFILE-1       update      rsDistanceThreshold      4
    Generate RS1andRS2    profile=250		delay=12	nearfar=1   globalfoforrs=528432    startfreq1=0    startfreq2=48
    Wait For Fault To Be Up     fault_id=7527   timeout=700
    sleep   300s
    Log to console    Wait for both RS1 and RS2
    Verify Fault Description    faultid=${7527}    faultname=RIM-RS detected
    ...     description=Both RIM RS1 and RS2 are detected
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH special slot plus the preceding slot
    Log to Console    Counter Validation
    Verify The Counter for Special and DL Slot with RIM RS1 and RS2
    sleep    60s
	Perform SCF Delta Commissioning with rsdistancethreshold_set_8.json
#	Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-1/NRRIM_PROFILE-1       update      rsDistanceThreshold      8
	sleep    100s
    Wait For Fault To Be Down   fault_id=7527   timeout=400
    Wait For Fault To Be Down   fault_id=7535   timeout=60
	Log to Console    Counter Validation for No Muting
	Verify The Counter for No Muting
    Deactivate RI
    Deactivate RS1andRS2     250
    Log to console     RI deactivated and waiting for 7525  down after RI disappear
    Wait For Fault To Be down     fault_id=7525   timeout=400
    ${syslog_path}    Stop Log    btslog    test_scenario=syslog
    sleep    5s

Verify The Counter for Special and DL Slot with RIM RS1
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${UL_SYMB_IMP_RI}   Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00001    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Special_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00281    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_2_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00282    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${NUM_RIM_RS1_Detected}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00005   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS1_7}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00175   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS1_8}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00176   moc=MRBTS-1/NRBTS-1/NRCELL-1
    Should be True    ${Special_slot} >= 298.0
    Should be True    ${Preceding_DL_slot} >= 298.0
    Should be True    ${Preceding_2_DL_slot} == 0
    Should be True    ${NUM_RIM_RS1_Detected} != 0
    Run Keyword If   ${RS1_7} == 1.0   Should be True    ${RS1_7} == 1.0
    ...  ELSE   Should be True    ${RS1_8} == 1.0
    Log to console    Number of UL Symbol IMpacted by RI is ${UL_SYMB_IMP_RI}
    Log to console    Number of Detected SET ID  is ${NUM_RIM_RS1_Detected}

Verify The Counter for Special and DL Slot with RIM RS1 and RS2
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${UL_SYMB_IMP_RI}   Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00001    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Special_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00281    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_2_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00282    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${NUM_RIM_RS1_Detected}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00005   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${NUM_RIM_RS2_Detected}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00006   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS1_7}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00175   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS1_8}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00176   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS2_7}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00231   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS2_8}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00232   moc=MRBTS-1/NRBTS-1/NRCELL-1
    Should be True    ${Special_slot} >= 298.0
    Should be True    ${Preceding_DL_slot} >= 298.0
    Should be True    ${Preceding_2_DL_slot} == 0
    Should be True    ${NUM_RIM_RS1_Detected} != 0
    Should be True    ${NUM_RIM_RS2_Detected} != 0
    Run Keyword If   ${RS1_7} == 1.0   Should be True    ${RS1_7} == 1.0
    ...  ELSE   Should be True    ${RS1_8} == 1.0
    Run Keyword If   ${RS2_7} == 1.0   Should be True    ${RS2_7} == 1.0
    ...  ELSE   Should be True    ${RS2_8} == 1.0
    Log to console    Number of UL Symbol IMpacted by RI is ${UL_SYMB_IMP_RI}
    Log to console    Number of Detected SET ID for RS1 is ${NUM_RIM_RS1_Detected}
    Log to console    Number of Detected SET ID for RS2 is ${NUM_RIM_RS2_Detected}
