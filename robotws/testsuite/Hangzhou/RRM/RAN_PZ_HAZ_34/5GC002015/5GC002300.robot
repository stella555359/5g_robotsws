*** Settings ***
Documentation      author: Ji Jian
...                contact: jian.ji@nokia-sbell.com
...                Group: HGZ_SG2
Force Tags         5G_RRM
...    PY36

Suite Setup    Common Suite Setup for COAM
Suite Teardown    Common Suite Teardown for COAM

Resource           Resources/5GC001655_common_keyword.robot

*** Variables ***
${scf_file}                        5GC002300.xml
${5GC002300_factor_0}              5GC002300_factor_0.xml
${5GC002300_factor_5}              5GC002300_factor_5.xml
${_schedulWeightFactorEnabled}     /home/ute/Downloads/SCF/5GC002300_C_001_schedulWeightFactorEnabled.xml
${data_transfer_dl}                1200M
${Expected_Throughput_DL}          200
${miNrEirp}                        5 min
${ratio}                           rrmEirpMinTokenRatio
${itf}                             itf_l2_ps_cell_CellReconfigurationReq
${actEirpControl_item}             itf_l2_ps_cell_CellReconfigurationReq_t.actEirpControl_item
${cellSegmentGridChange}           itf_l2_ps_cell_EirpControlReconf.cellSegmentGridChange
${numberOfCellSegments}            itf_l2_ps_cell_EirpControlReconf.numberOfCellSegments_item
${normalizedBeamGain}              itf_l2_ps_cell_NormalizedBeamGains.values_item
${powerReductionFactor}            itf_l2_ps_cell_PowerReductionFactors.values_item
${timeAveragingWindow}             itf_l2_ps_cell_TimeAveragingWindowDimensioning.timeAveragingWindow
${minGuaranteedBudgetRatioMode}    itf_l2_ps_cell_EirpControlReconf.minGuaranteedBudgetRatioMode_item
${minGuaranteedBudgetRatio}        itf_l2_ps_cell_EirpControlReconf.minGuaranteedBudgetRatio_item
${scheduleWeightFactorEnabled}     itf_l2_ps_cell_EirpControlReconf.scheduleWeightFactorEnabled_item
&{5GC002300_D_12}                  SBTS22R2=QC_324963    SBTS22R3=QC_402751    SBTS22R4=QC_361906    SBTS23R1=QC_56862

*** Test Cases ***
[1]5GC002300_D_12_EIRPcontrol_actualEirpBudgetRatio_with_BeamForming_Traffic_Impact_TDD
    [Tags]     5GC002300     CIT_TRUNK    ${5GC002300_D_12['${program}']}
    [Setup]     Case Setup    scf_file=${scf_file}
    "Step1" Settings of minGuaranteedBudgetRatio=0.5 eirpControlPowerReductionFactorList=-3
    "Step2" Waiting For 1 sliding windows
    "Step3" Start DL traffic of setting minGuaranteedBudgetRatio at 0.5
    "Step4" Settings of minGuaranteedBudgetRatio=0.8 eirpControlPowerReductionFactorList=-3
    "Step5" Cell Reconfiguration
#    "Step6" Check 5GC002300_D_12 eirpControlReconf for actEirpControl at true
    "Step7" Waiting For 1 sliding windows
    "Step8" Start DL traffic of setting minGuaranteedBudgetRatio at 0.8
    "Step9" Check result dl_tput_big_len_05 should be greater than dl_tput_big_len_08
    "Step10" Check result dl_tput_small_average_08 should be greater than dl_tput_small_average_05
    "Step11" Check result of rrmEirpMinTokenRatio
    [Teardown]     Case Teardown

[1]5GC002300_B_12_EIRPcontrol_PowerReductionFactor_Modification_during_DL_Tput_counter_M55324C00301_TDD
    [Tags]     5GC002300     CIT_TRUNK
    [Setup]     Case Setup    scf_file=${5GC002300_factor_5}
#    "Step1" Settings of eirpControlPowerReductionFactorList at -5
    "Step2" Attach And Start DL Traffic
    "Step3" Start Getting Tput List	
    "Step4" Waiting For miNrEirp AND Get Counter Time Before
    "Step5" Stop And Save Getting Tput List
    "Step6" Stop DL Traffic And Detach
    "Step6" Waiting For miNrEirp
    "Step7" Check Counter M55324C00301 Should not be 0
    "Step8" Settings of eirpControlPowerReductionFactorList at 0
    "Step9" Start Getting Tput List	
    "Step10" Waiting For miNrEirp AND Get Counter Time After
    "Step11" Stop And Save Getting Tput List
    "Step12" Stop DL Traffic And Detach
    "Step13" Waiting For miNrEirp
    "Step14" Check Counter M55324C00301 Should be 0 
    [Teardown]     Case Teardown

[1]5GC002300_G_07_maximum_minimum_cumulated_EIRP_SLIDING_SEGMENT_in_case_of _6_segments
    [Tags]     5GC002300     CIT_TRUNK
    [Setup]     Case Setup    scf_file=${5GC002300_factor_0}
#    "Step1" Settings of eirpControlPowerReductionFactorList at 0
    "Step2" Attach And Start DL Traffic 
    "Step3" Start Getting Tput List
    "Step4" Waiting For miNrEirp AND Get Counter Time Before
    "Step5" Stop And Save Getting Tput List
    "Step6" Stop DL Traffic And Detach
    "Step13" Waiting For miNrEirp
    "Step7" Check Counters Of 5GC002300_G_07 Before Modification
#    "Step8" Enable Parameter NumOfSegmentAzimuthEdges 
    "Step9" Start Getting Tput List	
    "Step10" Waiting For miNrEirp AND Get Counter Time After
    "Step11" Stop And Save Getting Tput List
    "Step12" Stop DL Traffic And Detach
    "Step13" Waiting For miNrEirp
    "Step14" Check Counters Of 5GC002300_G_07 After Modification
    [Teardown]     Case Teardown
#    [Teardown]    Run Keyword And Continue On Failure     Run keywords
#    ...    "Step15" Disable Parameter NumOfSegmentAzimuthEdges    AND    Case Teardown

[1]5GC002300_C_001_EIRPcontrol_eirpControlTimeAveragingWindow_offline_modification_via_WebEM_TDD
    [Tags]     5GC002300     CIT_TRUNK
    [Setup]    Case Setup    scf_file=${5GC002300_factor_0}
    "Step1" Settings of 5GC002300_C_001 actEirpControl at true
    "Step2" Start tcpdump for actEirpControl false
    "Step3" Settings of 5GC002300_C_001 actEirpControl at false
    "Step4" Stop tcpdump and download to testPC
    "Step5" Check 5GC002300_C_001 eirpControlReconf for actEirpControl at false
#-------------------------------------------line 302---------------------------------------------#
    "Step6" Start tcpdump for eirpControlTimeAveragingWindow 30 min
    "Step7" Settings of 5GC002300_C_001 actEirpControl at false eirpControlTimeAveragingWindow at 30min
    "Step8" Stop tcpdump and download to testPC
    "Step9" Check 5GC002300_C_001 eirpControlReconf for eirpControlTimeAveragingWindow at 30min
#------------------------------------------------------------------------------------------------#    
    "Step10" Start tcpdump for actEirpControl true
    "Step11" Settings of 5GC002300_C_001 actEirpControl at true eirpControlTimeAveragingWindow at 30min
    "Step12" Stop tcpdump and download to testPC    
    "Step13" Check 5GC002300_C_001 eirpControlReconf for actEirpControl at true
#------------------------------------------------------------------------------------------------#    
    "Step14" Start tcpdump for schedulWeightFactorEnabled true
    "Step15" Settings of 5GC002300_C_001 actEirpControl at true eirpControlTimeAveragingWindow at 30min schedulWeightFactorEnabled at true
    "Step16" Stop tcpdump and download to testPC 
    "Step17" Check 5GC002300_C_001 eirpControlReconf for schedulWeightFactorEnabled at true
    [Teardown]     Case Teardown
 
*** Keywords
Case Setup
    [Arguments]    ${scf_file}
    COAM Create log directory
    Run Keyword And Continue On Failure    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Aasyslog precondition    aa_sys_mode=5    aa_sys_addr=0xC0A8FF7E    aa_sys_udp_port=0xC738
    Run Keyword And Continue On Failure	   Btslog Setup Collector
    ${scf_file_path}=    OperatingSystem.Join Path    /home/ute/Downloads/SCF/    ${program}    ${scf_file}
    Run Keyword And Continue On Failure    COAM Commission with scf file     scf_file_path=${scf_file_path}
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    Check Alarm and stop robot testing when unexpected alarm raised
    Run Keyword And Continue On Failure     COAM Teardown gnb connections

#------------------------------------------------update parameter-----------------------------------------------# 
Update parameter For Enable 5GC002300
    [Arguments]
    ...    ${actEirpControl}=true
    ...    ${miNrEirp}=5min
    ...    ${antennaMechanicalDowntilt}=0
    ...    ${eirpControlTimeAveragingWindowStepSize}=100
    ...    ${eirpControlTimeAveragingWindow}=6
    ...    ${minSignificantNormalizedBeamGain}=-20
    ...    ${numOfSegmentAzimuthEdges}=9
    ...    ${numOfSegmentElevationEdges}=5
    ...    ${minGuaranteedBudgetRatio}=0.5
    ...    ${minGuaranteedBudgetRatioMode}=actualEirpBudgetRatio
    ...    ${schedulWeightFactorEnabled}=false
    ...    ${tiltOffset}=-1
    ...    ${eirpControlPowerReductionFactorList}=-3
    ...    ${actFdmEnhancedScheduling}=true
    ...    ${actFdmScheduling}=true
    Wait until keyword succeeds    3 min    5 s    COAM Navigate to login page via webUI
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Activate EIRP control
    ...    new_value=${actEirpControl}
#    Run keyword and ignore error    selenium_coam.add_element    dist_name=${MR_NR_CELL_NAME}
#    ...    filter_param=EIRP control
    ${value}    Run keyword and ignore error     selenium_coam.get_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=List of EIRP control power reduction factor per cell segment
    ...    node_index=0
    Run keyword if     '${value[0]}'=='FAIL'    Run Keyword And Continue On Failure   
    ...    selenium_coam.add_element    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=List of EIRP control power reduction factor per cell segment
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MR_NR_NRPMRNL_NAME}
    ...    filter_param=NR equivalent isotropic radiated power
    ...    new_value=${miNrEirp}
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Antenna mechanical downtilt
    ...    new_value=${antennaMechanicalDowntilt}
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=EIRP control time averaging window step size
    ...    new_value=${eirpControlTimeAveragingWindowStepSize}
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=EIRP control time averaging window
    ...    new_value=${eirpControlTimeAveragingWindow}
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Minimum EIRP threshold
    ...    new_value=${minSignificantNormalizedBeamGain} 
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Number of cell segment edges in azimuth
    ...    new_value=${numOfSegmentAzimuthEdges}
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Number of cell segment edges in elevation
    ...    new_value=${numOfSegmentElevationEdges}
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Minimum guaranteed budget ratio
    ...    new_value=${minGuaranteedBudgetRatio}
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Minimum guaranteed budget ratio mode
    ...    new_value=${minGuaranteedBudgetRatioMode}   
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Scheduling weight factor enabled
    ...    new_value=${schedulWeightFactorEnabled}
#    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
#    ...    filter_param=Tilt Offset
#    ...    new_value=${tiltOffset}
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MR_NR_NAME}
    ...    filter_param=Activate enhanced frequency domain scheduling
    ...    new_value=${actFdmEnhancedScheduling}
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MR_NR_NAME}
    ...    filter_param=Activate frequency domain scheduling
    ...    new_value=${actFdmScheduling}
#    FOR    ${node_index}    IN RANGE    1    61
#        Run Keyword And Continue On Failure    selenium_coam.set_parameter_value
#        ...    dist_name=${MR_NR_CELL_NAME}
#        ...    filter_param=List of EIRP control power reduction factor per cell segment
#        ...    node_index=${${node_index}}
#        ...    new_value=${eirpControlPowerReductionFactorList}
#    END
    run keywords    Connect to gnb coam via ssl
    ...     AND     selenium_coam.validate_plan
    ...     AND     COAM check validation errors from webui     is_need_to_check_validation_errors=${True}
    ...     AND     Wait until keyword succeeds    5 min    5 s    selenium_coam.activate_plan     activate_plan_despite_errors=${True}
    ...     AND     Run Keyword And Continue On Failure    Wait until keyword succeeds    10 min    5 s    COAM Check GNB cell on air
    ...     AND     Run Keyword And Continue On Failure    COAM Download scf from cluster    scf_dir_path=${TS_CASE_LOG_PATH}
#    ...     AND     Run Keyword And Continue On Failure    COAM Teardown gnb connections
    [Teardown]     Run Keyword And Continue On Failure     COAM selenium logout

"${Step}" Enable Parameter NumOfSegmentAzimuthEdges
    Log to console    \n"${Step}" Enable Parameter NumOfSegmentAzimuthEdges\n
    Wait until keyword succeeds    10 min    5 s    Enable Parameter NumOfSegmentAzimuthEdges
    
"${Step}" Disable Parameter NumOfSegmentAzimuthEdges
    Log to console    \n"${Step}" Disable Parameter NumOfSegmentAzimuthEdges\n
    Wait until keyword succeeds    10 min    5 s    Disable Parameter NumOfSegmentAzimuthEdges
    
Enable Parameter NumOfSegmentAzimuthEdges
    Wait until keyword succeeds    3 min    5 s    COAM Navigate to login page via webUI
#    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
#    ...    filter_param=Number of cell segment edges in azimtuh
#    ...    new_value=5
    Run Keyword If   '${program}'=='SBTS22R3'
    ...    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Number of cell segment edges in azimtuh
    ...    new_value=5
    ...    ELSE   selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Number of cell segment edges in azimuth
    ...    new_value=5
    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Cell segment edge azimuth 0
    ...    new_value=-30
    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Cell segment edge azimuth 1
    ...    new_value=-20
    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Cell segment edge azimuth 2
    ...    new_value=0
    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Cell segment edge azimuth 3
    ...    new_value=20
    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Cell segment edge azimuth 4
    ...    new_value=30
#    FOR    ${node_index}    IN RANGE    5
#        selenium_coam.add_element            dist_name=${MR_NR_CELL_NAME}
#        ...    filter_param=List of EIRP control power reduction factor per cell segment
#    END
    run keywords     selenium_coam.validate_plan
    ...     AND     COAM check validation errors from webui     is_need_to_check_validation_errors=${True}
    ...     AND     Wait until keyword succeeds    3 min    5 s    selenium_coam.activate_plan     activate_plan_despite_errors=${True}
    ...     AND     COAM Verify gnb on air after activate plan via webUI     is_gnb_restrat_after_online_modify=${True}
    [Teardown]     Run Keyword And Continue On Failure     COAM selenium logout

Disable Parameter NumOfSegmentAzimuthEdges
    Wait until keyword succeeds    3 min    5 s    COAM Navigate to login page via webUI
#    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
#    ...    filter_param=Number of cell segment edges in azimtuh
#    ...    new_value=0
    Run Keyword If   '${program}'=='SBTS22R3'
    ...    selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Number of cell segment edges in azimtuh
    ...    new_value=0
    ...    ELSE   selenium_coam.set_parameter_value    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Number of cell segment edges in azimuth
    ...    new_value=0
    selenium_coam.delete_parameter    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Cell segment edge azimuth 0
    selenium_coam.delete_parameter    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Cell segment edge azimuth 1
    selenium_coam.delete_parameter    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Cell segment edge azimuth 2
    selenium_coam.delete_parameter    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Cell segment edge azimuth 3
    selenium_coam.delete_parameter    dist_name=${MR_NR_CELL_NAME}
    ...    filter_param=Cell segment edge azimuth 4
#    FOR    ${node_index}    IN RANGE    5
#        selenium_coam.remove_element            dist_name=${MR_NR_CELL_NAME}
#        ...    filter_param=List of EIRP control power reduction factor per cell segment
#        ...    node_index=${node_index}
#    END
    run keywords     selenium_coam.validate_plan
    ...     AND     COAM check validation errors from webui     is_need_to_check_validation_errors=${True}
    ...     AND     Wait until keyword succeeds    3 min    5 s    selenium_coam.activate_plan     activate_plan_despite_errors=${True}
    ...     AND     COAM Verify gnb on air after activate plan via webUI     is_gnb_restrat_after_online_modify=${True}
    [Teardown]     Run Keyword And Continue On Failure     COAM selenium logout

#------------------------------------------------Update 5GC002300_D_12 parameter------------------------------------------------#
"${Step}" Settings of eirpControlPowerReductionFactorList at -5
    Log to console    \n"${Step}" Settings of eirpControlPowerReductionFactorList at -5\n
#    Wait until keyword succeeds    10 min    5 s    Update parameter For Enable 5GC002300
#    ...    eirpControlPowerReductionFactorList=-5
    ${scf_file_path}=    OperatingSystem.Join Path    /home/ute/Downloads/SCF/    ${program}    ${5GC002300_factor_5}
    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    COAM Commission with scf file     scf_file_path=${scf_file_path}
    COAM Wait for gnb ready and cell setup     timeout=20 min    gnb_type='SA'
#    COAM Teardown gnb connections

"${Step}" Settings of eirpControlPowerReductionFactorList at 0
    Log to console    \n "${Step}" Settings of eirpControlPowerReductionFactorList at 0\n
#    Wait until keyword succeeds    10 min    5 s    Update parameter For Enable 5GC002300
#    ...    eirpControlPowerReductionFactorList=0
    ${scf_file_path}=    OperatingSystem.Join Path    /home/ute/Downloads/SCF/    ${program}    ${5GC002300_factor_0}
    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    COAM Commission with scf file     scf_file_path=${scf_file_path}
    COAM Wait for gnb ready and cell setup     timeout=20 min    gnb_type='SA'
#    COAM Teardown gnb connections

"${Step}" Settings of minGuaranteedBudgetRatio=0.5 eirpControlPowerReductionFactorList=-3
    Log to console    \n "${Step}" Settings of minGuaranteedBudgetRatio at 0.5\n
    Wait until keyword succeeds    10 min    5 s    Update parameter For Enable 5GC002300
    ...    minGuaranteedBudgetRatio=0.5
    ...    eirpControlPowerReductionFactorList=-3
#    ...    eirpControlTimeAveragingWindowStepSize=500
#    ...    actEirpControl=true
#    ...    eirpControlTimeAveragingWindow=30min

"${Step}" Settings of minGuaranteedBudgetRatio=0.8 eirpControlPowerReductionFactorList=-3
    Log to console    \n "${Step}" Settings of minGuaranteedBudgetRatio at 0.8\n
    Wait until keyword succeeds    10 min    5 s    Update parameter For Enable 5GC002300
    ...    minGuaranteedBudgetRatio=0.8
    ...    eirpControlPowerReductionFactorList=-3
#    ...    eirpControlTimeAveragingWindowStepSize=500
#    ...    actEirpControl=true
#    ...    eirpControlTimeAveragingWindow=30min

#------------------------------------------------Update 5GC002300_C_001 Parameter------------------------------------------------#
"${Step}" Settings of 5GC002300_C_001 actEirpControl at true
    Log to console    \n"${Step}" Settings of 5GC002300_C_001 actEirpControl at true\n
    Wait until keyword succeeds    10 min    5 s    Update parameter For Enable 5GC002300
    ...    eirpControlTimeAveragingWindowStepSize=500
    ...    actEirpControl=true

"${Step}" Settings of 5GC002300_C_001 actEirpControl at false
    Log to console    \n"${Step}" Settings of 5GC002300_C_001 actEirpControl at false\n
    Wait until keyword succeeds    10 min    5 s    Update parameter For Enable 5GC002300
    ...    eirpControlTimeAveragingWindowStepSize=500
    ...    actEirpControl=false

"${Step}" Settings of 5GC002300_C_001 actEirpControl at false eirpControlTimeAveragingWindow at 30min
    Log to console    \n""${Step}" Settings of 5GC002300_C_001 actEirpControl at false eirpControlTimeAveragingWindow at 30min\n
    Wait until keyword succeeds    10 min    5 s    Update parameter For Enable 5GC002300
    ...    eirpControlTimeAveragingWindowStepSize=500
    ...    actEirpControl=false
    ...    eirpControlTimeAveragingWindow=30min

"${Step}" Settings of 5GC002300_C_001 actEirpControl at true eirpControlTimeAveragingWindow at 30min
    Log to console    \n"${Step}" Settings of 5GC002300_C_001 actEirpControl at true eirpControlTimeAveragingWindow at 30min\n
    Wait until keyword succeeds    10 min    5 s    Update parameter For Enable 5GC002300
    ...    eirpControlTimeAveragingWindowStepSize=500
    ...    actEirpControl=true
    ...    eirpControlTimeAveragingWindow=30min

"${Step}" Settings of 5GC002300_C_001 actEirpControl at true eirpControlTimeAveragingWindow at 30min schedulWeightFactorEnabled at true
    Log to console
    ...    \n"${Step}" Settings of 5GC002300_C_001 actEirpControl true eirpControlTimeAveragingWindow 30min schedulWeightFactorEnabled true\n
#    Run Keyword And Continue On Failure    COAM Commission with scf file     scf_file_path=${_schedulWeightFactorEnabled}
    Wait until keyword succeeds    10 min    5 s    Update parameter For Enable 5GC002300
    ...    eirpControlTimeAveragingWindowStepSize=500
    ...    actEirpControl=true
    ...    eirpControlTimeAveragingWindow=30min
    ...    schedulWeightFactorEnabled=true	

#------------------------------------------------Check 5GC002300_B_12 PM Counters-----------------------------------------------#
"${Step}" Check Counter M55324C00301 Should not be 0
    Log to console     \n"${Step}" Check Counter M55324C00301 Should Not Contain 0\n
    Wait until keyword succeeds    3 min    5 s    COAM Navigate to login page via webUI
    ${counter_dictionary}    Wait until keyword succeeds    3 min    5 s    selenium_coam.get_bts_counters_info    counter_id=M55324C00301
    ${counter_value}    Run Keyword And Continue On Failure    Get From Dictionary    ${counter_dictionary}    ${counter_time_before}
    Run keyword and ignore error     should be true    ${counter_value}>0
    Log to console    \nM55324C00301=${counter_value}
    [Teardown]     Run Keyword And Continue On Failure     COAM selenium logout

"${Step}" Check Counter M55324C00301 Should be 0
    Log to console     \n"${Step}" Check Counter M55324C00301 Should Contain 0\n
    Wait until keyword succeeds    3 min    5 s    COAM Navigate to login page via webUI
    ${counter_dictionary}    Wait until keyword succeeds    3 min    5 s    selenium_coam.get_bts_counters_info    counter_id=M55324C00301
    ${counter_value}    Run Keyword And Continue On Failure    Get From Dictionary    ${counter_dictionary}    ${counter_time_after}
    Run Keyword And Continue On Failure     should be true    ${counter_value}==0
    Log to console    \nM55324C00301=${counter_value}
    [Teardown]     Run Keyword And Continue On Failure     COAM selenium logout

"${Step}" Waiting For miNrEirp AND Get Counter Time Before
    Log to console    \n"${Step}" Waiting For miNrEirp AND Get Counter Time Before\n
    sleep    ${miNrEirp}
    ${counter_time_before}    Get BTS Counter time via webUI
    set test variable    ${counter_time_before}

"${Step}" Waiting For miNrEirp AND Get Counter Time After
    Log to console    \n"${Step}" Waiting For miNrEirp AND Get Counter Time After\n
    sleep    ${miNrEirp}
    ${counter_time_after}    Get BTS Counter time via webUI
    set test variable    ${counter_time_after}

Get BTS Counter time via webUI
    Wait until keyword succeeds    3 min    5 s    COAM Navigate to login page via webUI
	${curr_data}    Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d %H:%M
    set test variable	${curr_data}
    ${counter_time}     Run Keyword If     ${curr_data[-1]}<5    Catenate    SEPARATOR=   ${curr_data[:-1]}    0:00
    ...    ELSE    Catenate    SEPARATOR=   ${curr_data[:-1]}    5:00
    Log to console    ${counter_time}
    [return]      ${counter_time}
    [Teardown]     Run Keyword And Continue On Failure     COAM selenium logout

#------------------------------------------------Check 5GC002300_G_07 PM Counters------------------------------------------------#
"${Step}" Check Counters Of 5GC002300_G_07 Before Modification
    Log to console     \n"${Step}" Check Counters Of 5GC002300_G_07 Before Modification\n
    Wait until keyword succeeds    3 min    5 s    COAM Navigate to login page via webUI
    @{Before_Modification_counters_list}    Create list
    ...    M55324C00101
    ...    M55324C00501
    ...    M55324C00201
    ...    M55324C00601
    ...    M55324C00701
    ...    M55324C00400
    ...    M55324C00464
    ...    M55324C00800
    ...    M55324C00801
    ...    M55324C00802
    FOR    ${counter}    IN    @{Before_Modification_counters_list}
        Set test variable    ${counter}
        ${counter_dictionary}    Wait until keyword succeeds    3 min    5 s    selenium_coam.get_bts_counters_info    counter_id=${counter}
        ${counter_value}    Run Keyword And Continue On Failure    Get From Dictionary    ${counter_dictionary}    ${counter_time_before}
        Run keyword and ignore error     should be true    ${counter_value}>0
        Log to console    \n${counter}=${counter_value}
    END
    [Teardown]     Run Keyword And Continue On Failure     COAM selenium logout

"${Step}" Check Counters Of 5GC002300_G_07 After Modification
    Log to console     \n"${Step}" Check Counters Of 5GC002300_G_07 After Modification\n
    Wait until keyword succeeds    3 min    5 s    COAM Navigate to login page via webUI
    @{After_Modification_counters_list}    Create list
    ...    M55324C00102
    ...    M55324C00103
    ...    M55324C00104
    ...    M55324C00105
    ...    M55324C00106
    ...    M55324C00202
    ...    M55324C00203
    ...    M55324C00204
    ...    M55324C00205
    ...    M55324C00206
    ...    M55324C00502
    ...    M55324C00503
    ...    M55324C00504
    ...    M55324C00505
    ...    M55324C00506
    ...    M55324C00602
    ...    M55324C00603
    ...    M55324C00604
    ...    M55324C00605
    ...    M55324C00606
    ...    M55324C00702
    ...    M55324C00703
    ...    M55324C00704
    ...    M55324C00705
    ...    M55324C00706
    ...    M55324C00400
    ...    M55324C00464
    ...    M55324C00800
    ...    M55324C00801
    ...    M55324C00802
    FOR    ${counter}    IN    @{After_Modification_counters_list}
        Set test variable    ${counter}
        ${counter_dictionary}    Wait until keyword succeeds    3 min    5 s    selenium_coam.get_bts_counters_info    counter_id=${counter}
        ${counter_value}    Run Keyword And Continue On Failure    Get From Dictionary    ${counter_dictionary}    ${counter_time_after}
        Run keyword and ignore error     should be true    ${counter_value}>0
        Log to console    \n${counter}=${counter_value}
    END
    [Teardown]     Run Keyword And Continue On Failure     COAM selenium logout
    
#------------------------------------------------Check 5GC002300_C_001 eirpControlReconf------------------------------------------------#
"${Step}" Check 5GC002300_C_001 eirpControlReconf for actEirpControl at true
    Load pcap file    pcap_file=${tcpdump_log_path}    field_name=${actEirpControl_item}
    @{actEirpControl}                     create list     ${actEirpControl_item}                  1
    @{cellSegmentGridChange}              create list     ${cellSegmentGridChange}                1
    @{numberOfCellSegments}               create list     ${numberOfCellSegments}                 60
    @{normalizedBeamGain}                 create list     ${normalizedBeamGain}                   0
    @{powerReductionFactor}               create list     ${powerReductionFactor}                 0
    @{timeAveragingWindowDimensioning}    create list     ${timeAveragingWindow}                  30
    @{minGuaranteedBudgetRatioMode}       create list     ${minGuaranteedBudgetRatioMode}         10
    @{minGuaranteedBudgetRatio}           create list     ${minGuaranteedBudgetRatio}             50
    @{scheduleWeightFactorEnabled}        create list     ${scheduleWeightFactorEnabled}          0
    @{checkpoint_list}    create list
    ...    ${actEirpControl}
    ...    ${cellSegmentGridChange}
    ...    ${numberOfCellSegments}
    ...    ${normalizedBeamGain}
    ...    ${powerReductionFactor}
    ...    ${timeAveragingWindowDimensioning}
    ...    ${minGuaranteedBudgetRatioMode}
    ...    ${minGuaranteedBudgetRatio}
    ...    ${scheduleWeightFactorEnabled}
    FOR     ${checkpoint}    IN ZIP   ${checkpoint_list}
        ${values}    Run Keyword And Continue On Failure     Wait until keyword succeeds    2 min    5 s
        ...    pcap.get_field_value_by_xpath     xpath=.//${checkpoint[0]}
        ${values}    Run Keyword And Continue On Failure     Remove Duplicates    ${values}
        Run Keyword And Continue On Failure
        ...		should be true    '${values[0]}'=='${checkpoint}[1]'    msg = ${checkpoint[0].split('.')[-1]} check failed
        Run Keyword And Continue On Failure     log to console   ${checkpoint[0].split('.')[-1]}==${values[0]}
        log to console     *** check if ${checkpoint[0].split('.')[-1]} == ${checkpoint[1]} ***\n
    END
    ${values}    Run Keyword And Continue On Failure    Wait until keyword succeeds    2 min    5 s
    ...    pcap.get_field_value_by_xpath     xpath=.//itf_l2_ps_cell_EirpControlReconf.maxBeamGain_item
    ${values}    Remove Duplicates    ${values}
    Run Keyword And Continue On Failure     should be true    ${values[0]}>=0
    Run Keyword And Continue On Failure     log to console   \nmaxBeamGain_item_0==${values}

"${Step}" Check 5GC002300_C_001 eirpControlReconf for actEirpControl at false
    Load pcap file    pcap_file=${tcpdump_log_path}    field_name=${actEirpControl_item}
    ${values}    Run Keyword And Continue On Failure    Wait until keyword succeeds    2 min    5 s
    ...    pcap.get_field_value_by_xpath     xpath=.//${actEirpControl_item}
    log to console   \n*** check if actEirpControlis equal to 0 ***
    Run Keyword And Continue On Failure     should be true    '${values[0]}'=='0'
    log to console   \nactEirpControl==${values}

"${Step}" Check 5GC002300_C_001 eirpControlReconf for eirpControlTimeAveragingWindow at 30min
    Load pcap file    pcap_file=${tcpdump_log_path}    field_name=${actEirpControl_item}
    ${values}    Run Keyword And Continue On Failure    Wait until keyword succeeds    2 min    5 s
    ...    pcap.get_field_value_by_xpath     xpath=.//${actEirpControl_item}
    log to console   \n*** check if actEirpControlis equal to [] ***
    Run Keyword And Continue On Failure     should be true    '${values}'=='[]'
    log to console   \nactEirpControl==${values}

"${Step}" Check 5GC002300_C_001 eirpControlReconf for schedulWeightFactorEnabled at true
    Load pcap file    pcap_file=${tcpdump_log_path}    field_name=${scheduleWeightFactorEnabled}
    ${values}    Run Keyword And Continue On Failure    Wait until keyword succeeds    2 min    5 s
    ...    pcap.get_field_value_by_xpath     xpath=.//${scheduleWeightFactorEnabled}
    log to console   \n*** check if actEirpControlis equal to 1 ***
    Run Keyword And Continue On Failure     should be true    '${values[0]}'=='1'
    Run Keyword And Continue On Failure     log to console   \nactEirpControl==${values[0]}

Check value from pcap log
    [Arguments]    ${parameter_name}    ${field_name}    ${expected_value}
    Log to console    \nCheck ${parameter_name} value
    ${values}    Run Keyword And Continue On Failure    Wait until keyword succeeds    2 min    5 s
    ...    pcap.get_field_value_by_xpath     xpath=.//${field_name}
    Run Keyword And Continue On Failure     should be true    '${values[0]}'=='${expected_value}'
    Run Keyword And Continue On Failure     log to console   \n${parameter_name}=${values[0]}
    ${values}    Remove Duplicates    ${values}
    Run Keyword And Continue On Failure     should be true    '${values[0][-1]}'=='${checkpoint[1]}'
    Run Keyword And Continue On Failure     log to console    ${checkpoint[0].split('.')[2]}==${values[0][-1]}

#------------------------------------------------DL Traffic------------------------------------------------#
"${Step}" Attach And Start DL Traffic
    Log to console    \n"${Step}" Attach And Start DL Traffic\n
    Get UE Type for Power UE from File
    Wait until keyword succeeds    3 min    5 s    Common UE Attach
    Run Keyword And Continue On Failure     power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}
    ...     duration=1800     iperf_port=${dl_port}     buffer_size=1400     dt_name=dt_dl

"${Step}" Stop DL Traffic And Detach
    Log to console    \n"${Step}" Stop DL Traffic And Detach\n
    Run Keyword And Continue On Failure     Run keywords
    ...    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl     iperf_port=${dl_port}
    ...    AND     power_ue.UE Detach     ue_type=${ue_type}      

#------------------------------------------------Waiting time-----------------------------------------------#
"${Step}" Waiting For miNrEirp
    Log to console    \n"${Step}" Waiting For miNrEirp\n
    sleep    ${miNrEirp}

"${Step}" Waiting For 2 sliding windows
    Log to console    \n"${Step}" Waiting For 2 sliding windows\n
    sleep    12min

"${Step}" Waiting For 1 sliding windows
    Log to console    \n"${Step}" Waiting For 1 sliding windows\n
    sleep    6min
	
"${Step}" Cell Reconfiguration
    Log to console    \n"${Step}" Cell Reconfiguration\n
    Run Keyword And Continue On Failure    Connect to gnb coam via ssl
    Aasyslog precondition    aa_sys_mode=5    aa_sys_addr=0xC0A8FF7E    aa_sys_udp_port=0xC738
    Start tcpdump    pcap_name=CellReconfiguration
    Perform RU Reset    ru_index=1
#    Perform cell block
#    Sleep    5s
#    Perform cell unblock
#    Sleep    5s
    Wait until keyword succeeds    20min    10s    COAM Check GNB cell on air
    Sleep    5s
    Stop tcpdump and download to testPC
    Run Keyword And Continue On Failure    COAM Teardown gnb connections

#------------------------------------------------Check 5GC002300_D_12 eirpControlReconf------------------------------------------------#
"${Step}" Check 5GC002300_D_12 eirpControlReconf for actEirpControl at true
    Load pcap file    pcap_file=${tcpdump_log_path}    field_name=${actEirpControl_item}
    @{actEirpControl}                     create list     ${actEirpControl_item}                    1
    @{powerReductionFactor}               create list     ${powerReductionFactor}                   0
    @{timeAveragingWindowDimensioning}    create list     ${timeAveragingWindow}                    30
    @{minGuaranteedBudgetRatioMode}       create list     ${minGuaranteedBudgetRatioMode}           10
    @{minGuaranteedBudgetRatio}           create list     ${minGuaranteedBudgetRatio}               50
    @{scheduleWeightFactorEnabled}        create list     ${scheduleWeightFactorEnabled}            0
    @{checkpoint_list}    create list
    ...    ${actEirpControl}
    ...    ${powerReductionFactor}
    ...    ${timeAveragingWindowDimensioning}
    ...    ${minGuaranteedBudgetRatioMode}
    ...    ${minGuaranteedBudgetRatio}
    ...    ${scheduleWeightFactorEnabled}
    FOR     ${checkpoint}    IN ZIP   ${checkpoint_list}
        log to console     \n*** check if ${checkpoint[0]} is equal to ${checkpoint[1]} ***
        ${values}    Run Keyword And Continue On Failure     Wait until keyword succeeds    2 min    5 s
        ...    pcap.get_field_value_by_xpath     xpath=.//${checkpoint[0]}
        ${values}    Run Keyword And Continue On Failure     Remove Duplicates    ${values}
        Run Keyword And Continue On Failure     should be true    '${values[0]}'=='${checkpoint}[1]'
        Run Keyword And Continue On Failure     log to console   ${checkpoint[0].split('.')[-1]}==${values[0]}
    END

#------------------------------------------------DL Traffic for 5GC002300_D_12  -----------------------------------------------#    
"${Step}" Start DL traffic of setting minGuaranteedBudgetRatio at 0.5  
    Log to console    \n"${Step}" Start DL traffic of setting minGuaranteedBudgetRatio at 0.5  \n
    ${dl_tput_big_len_05}    ${dl_tput_small_average_05}    ${dl_tput_small_len_05}    Start DL traffic for 5GC002300_D_12    duration=720s
    Set test variable    ${dl_tput_big_len_05}
    Set test variable    ${dl_tput_small_average_05}
    Set test variable    ${dl_tput_small_len_05}

"${Step}" Start DL traffic of setting minGuaranteedBudgetRatio at 0.8    
    Log to console    \n"${Step}" Start DL traffic of setting minGuaranteedBudgetRatio at 0.8   \n
    ${dl_tput_big_len_08}    ${dl_tput_small_average_08}    ${dl_tput_small_len_08}    Start DL traffic for 5GC002300_D_12    duration=720s
    Set test variable    ${dl_tput_big_len_08}
    Set test variable    ${dl_tput_small_average_08}
    Set test variable    ${dl_tput_small_len_08}    

"${Step}" Check result dl_tput_big_len_05 should be greater than dl_tput_big_len_08
    Log to console    \n"${Step}" Check result dl_tput_big_len_05 should be greater than dl_tput_big_len_08
    Log to console    \ndl_tput_big_len_05=${dl_tput_big_len_05}
    Log to console    \ndl_tput_small_len_05=${dl_tput_small_len_05}
    Log to console    \ndl_tput_big_len_08=${dl_tput_big_len_08}
    Log to console    \ndl_tput_small_len_08=${dl_tput_small_len_08} 
    Run Keyword And Continue On Failure     should be true     ${dl_tput_big_len_05}>${dl_tput_big_len_08}
    Run Keyword And Continue On Failure     should be true     ${dl_tput_small_len_05}>0
    Run Keyword And Continue On Failure     should be true     ${dl_tput_small_len_08}>0  

"${Step}" Check result dl_tput_small_average_08 should be greater than dl_tput_small_average_05
    Log to console    \n"${Step}" Check result dl_tput_small_average_08 should be greater than dl_tput_small_average_05
    Log to console    \ndl_tput_small_average_05=${dl_tput_small_average_05}
    Log to console    \ndl_tput_small_average_08=${dl_tput_small_average_08}
    Run Keyword And Continue On Failure     should be true     ${dl_tput_small_average_08}>${dl_tput_small_average_05}
    Run Keyword And Continue On Failure     should be true     ${dl_tput_small_average_05}>0
    Run Keyword And Continue On Failure     should be true     ${dl_tput_small_average_08}>0

"${Step}" Check result of rrmEirpMinTokenRatio
    Run Keyword And Continue On Failure    Btslog Teardown Collector
    ${rrmEirpMinTokenRatio}=    run
    ...    command=cat ${LOG_PATH}/SYSLOG_${time_btslog}.LOG | grep "${ratio}" | awk -F '${ratio}:' '{print $2}'| cut -d ' ' -f 1 2>&1
	${rrmEirpMinTokenRatio}    Run Keyword And Continue On Failure    Remove Duplicates    ${rrmEirpMinTokenRatio.split('\n')}
	Run Keyword And Continue On Failure    set test variable    ${rrmEirpMinTokenRatio_0.5}    ${rrmEirpMinTokenRatio[0]}
	Run Keyword And Continue On Failure    set test variable    ${rrmEirpMinTokenRatio_0.8}    ${rrmEirpMinTokenRatio[1]}
	Run Keyword And Continue On Failure    should be true    '${rrmEirpMinTokenRatio_0.5}'=='0.500000'
	Run Keyword And Continue On Failure    should be true    '${rrmEirpMinTokenRatio_0.8}'=='0.800000'
	Run Keyword And Continue On Failure    log to console    	\nrrmEirpMinTokenRatio_0.5=${rrmEirpMinTokenRatio_0.5}
    Run Keyword And Continue On Failure    log to console    	\nrrmEirpMinTokenRatio_0.8=${rrmEirpMinTokenRatio_0.8}

Start DL traffic For 5GC002300_D_12
    [Arguments]     ${duration}    ${buffer_size}=1400
    Get UE Type for Power UE from File
    Wait until keyword succeeds    3 min    5 s    Common UE Attach
    Run Keyword And Continue On Failure     power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}
    ...     duration=900     iperf_port=${dl_port}     buffer_size=${buffer_size}     dt_name=dt_dl
    Sleep    16s
    ${dl_tput_list}    Get dl tput list from GNB    duration=${duration}
    ${dl_tput_big_len}    ${dl_tput_small_average}    ${dl_tput_small_len}    Run Keyword And Continue On Failure
    ...     Filter dl tput info for trigger EIRP     detail_tput_list=${dl_tput_list}
    Run Keyword And Continue On Failure     Wait until keyword succeeds    1 min    5 s    Common Capture BIP log and download to testPC 
    [Teardown]     Run Keyword And Continue On Failure     Run keywords
    ...    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl     iperf_port=${dl_port}
    ...    AND    power_ue.UE Detach     ue_type=${ue_type}
    [Return]     ${dl_tput_big_len}    ${dl_tput_small_average}    ${dl_tput_small_len}

Filter dl tput info for trigger EIRP
    [Arguments]     ${detail_tput_list}
    #Remove Values From List    ${dl_tput_list}    ${0}
    ${dl_tput_list_copy}    copy list    ${dl_tput_list}
    sort list    ${dl_tput_list_copy}
    set test variable    ${dl_tput_max}    ${dl_tput_list_copy[-1]}
    @{dl_tput_big}    create list
    @{dl_tput_small}    create list
    FOR    ${value}    IN    @{dl_tput_list}
        run keyword if    ${value}>${dl_tput_max}*0.7    Append To List    ${dl_tput_big}    ${value}
        ...    ELSE    Append To List    ${dl_tput_small}    ${value}
    END
    ${dl_tput_big_len}    get length    ${dl_tput_big}
    set test variable    ${dl_tput_big_len}
    ${dl_tput_small_len}    get length    ${dl_tput_small}
    set test variable    ${dl_tput_small_len}
    ${dl_tput_sum}    set variable    0
    Remove Values From List    ${dl_tput_small}    ${0}
    ${count}    get length    ${dl_tput_small}
    FOR    ${value}    IN    @{dl_tput_small}
        ${dl_tput_sum}    Evaluate    ${dl_tput_sum} + ${value}
    END
    ${dl_tput_small_average}    Run Keyword If    ${count}==0    Set Variable    ${0}    
    ...    ELSE    Evaluate    round(round(${dl_tput_sum},1)/round(${count},1),2)
    set test variable    ${dl_tput_small_average}
    [Return]     ${dl_tput_big_len}    ${dl_tput_small_average}    ${dl_tput_small_len}

#------------------------------------------------Getting Dl Tput List-----------------------------------------------# 
"${Step}" Start Getting Tput List
    Log to console    "${Step}" Start Getting Tput List
    Start Getting Tput List

"${Step}" Stop And Save Getting Tput List
    Log to console    "${Step}" Stop And Save Getting Tput List
    Connect to gnb coam via ssl
    Stop And Save Getting Tput List

#------------------------------------------------get tcpdump-----------------------------------------------# 
"${Step}" Start tcpdump for actEirpControl false
    Log to console    "${Step}" Start tcpdump for actEirpControl false
    Start tcpdump    pcap_name=actEirpControl_false

"${Step}" Start tcpdump for eirpControlTimeAveragingWindow 30 min
    Log to console    "${Step}" Start tcpdump for eirpControlTimeAveragingWindow 30 min
    Start tcpdump    pcap_name=eirpControlTimeAveragingWindow_30_min

"${Step}" Start tcpdump for actEirpControl true
    Log to console    "${Step}" Start tcpdump for actEirpControl true
    Start tcpdump    pcap_name=actEirpControl_true

"${Step}" Start tcpdump for schedulWeightFactorEnabled true 
    Log to console    "${Step}" Start tcpdump for schedulWeightFactorEnabled true
    Start tcpdump    pcap_name=schedulWeightFactorEnabled_true

"${Step}" Stop tcpdump and download to testPC
    Stop tcpdump and download to testPC
