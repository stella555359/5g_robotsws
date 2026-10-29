*** Settings ***
Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
...    AND    Suite Setup    
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
...    AND    Suite Teardown
Test Setup    Run Keywords    Run keyword and continue on failure    case setup   
...    AND    robot_common_operations.Common Case Setup
Test Teardown    robot_common_operations.Common Case Teardown



Resource    ./Resources/CB008392_common_keywords.robot

Documentation
...    Author:Guo Zhenzhen
...    contact:zhenzhen.guo@nokia-sbell.com
...    squad group:mmw_SG_03
...    Feature CB008392 AZQG

*** Variables ***

*** Test Cases ***
[1]CB008392-B_1_Load_based_MIMO_muting_work_with_1_non_beamforming_4TRX_cell	
    [Tags]    CRT_TRUNK
    Scf commition and wair for on-air    scf_name=${scf_path}/${nonBF_scf_name}
	#Adjust HBTE ATT Values    ${ATTENUATION_VALUE_nonBF_4D4U_1234}
	Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_nonBF_4D4U_1234}
    Set limit time value of TX power saving on and off    off_time=30    on_time=60
    Wait until keyword succeeds    3min    10s    Verify cell is not energy saving state
	Verify all cells should be onair    connection=GNB_OAM
    UE Prepare and UE attach
    Start traffic and check UE DL and UL TP seperately
	...    expect_dl_tp=1200    expect_ul_tp=48    dl_traffic=1600M    ul_traffic=90M
    TX_switch_off_conditions_meet_before_and_during_start_power_saving_time_period
    Wait until keyword succeeds    10min    20s    Verify cell is reduced Energy Saving
    Start traffic and check UE DL and UL TP seperately    
	...    expect_dl_tp=600    expect_ul_tp=48    dl_traffic=800M    ul_traffic=90M	
    UE start traffic    tp_direction=dl    dl_tp=1600M
	sleep    60s
    Wait until keyword succeeds    1min    5s    Verify cell is not energy saving state
    UE stop traffic    tp_direction=both
    sleep    10s
    Start traffic and check UE DL and UL TP seperately
	...    expect_dl_tp=1200    expect_ul_tp=48    dl_traffic=1600M    ul_traffic=90M
	UE stop traffic    tp_direction=both
	sleep    30s
	Wait until keyword succeeds    1min    5s    Verify cell is reduced Energy Saving
    [teardown]    run keywords    Feature CB008392 Deactive    AND    Detach UE for case finished

[1]CB008392-C_1_Load_based_MIMO_muting_work_with_2_sub_sector
    [Tags]    CIT_TRUNK     CRT_TRUNK
    Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_2SS}
    ${scf_after_modify}    Scf xml modify    scf_file_path=${scf_path}/${8T8R_scf_name}
    ...    parameters_to_update_xml=${PARA_2SubSector}	
    Scf commition and wair for on-air    scf_name=${scf_after_modify}
    Set Suite Variable    ${default_scf}    ${scf_after_modify}
	#Set limit time value of TX power saving on and off    off_time=30    on_time=30
	UE Prepare
	Attach UE
	UE start traffic    tp_direction=both    ul_tp=100M    dl_tp=1600M
	UE check throughput by syslog    tp_direction=both    exp_ul_tp=48    exp_dl_tp=1400
	UE stop traffic    tp_direction=dl
    TX_switch_off_conditions_meet_before_and_during_start_power_saving_time_period
	Wait until keyword succeeds    10min    10s    Verify cell is reduced Energy Saving
	UE start traffic    tp_direction=dl    dl_tp=750M
	UE check throughput by syslog    tp_direction=both    exp_ul_tp=48    exp_dl_tp=600
    Detach UE for case finished
	Wait until keyword succeeds    10min    10s    Verify cell is reduced Energy Saving	
	Modify to close loop
	Wait Until Keyword Succeeds    10min    5s    Verify all cells should be onair    connection=GNB_OAM
	Attach UE
    Wait until keyword succeeds    2min    10s    Verify cell is reduced Energy Saving
	UE start traffic    tp_direction=both    ul_tp=80M    dl_tp=500M
	UE check throughput by syslog    tp_direction=both    exp_ul_tp=48    exp_dl_tp=400
    UE stop traffic    tp_direction=both
	UE start traffic    tp_direction=both    ul_tp=80M    dl_tp=1600M
    Wait until keyword succeeds    2min    5s    Verify cell is not energy saving state	
	UE check throughput by syslog    tp_direction=both    exp_ul_tp=48    exp_dl_tp=1200
    [teardown]    Feature CB008392 Deactive	

[1]CB008392-D_1_Load_based_MIMO_muting_work_with_beamforming_cell
    [Tags]    CRT_TRUNK
    #Scf commition and wair for on-air    scf_name=${scf_path}/${8T8R_scf_name}
    Scf commition and wair for on-air    scf_name=${scf_path}/${BF_scf_name}
    Set Suite Variable    ${default_scf}    ${scf_path}/${BF_scf_name}
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_BF_1234}
    UE Prepare and UE attach
    UE start traffic    tp_direction=dl    dl_tp=1600M
    UE check throughput by syslog    tp_direction=dl    exp_dl_tp=1350
    UE stop traffic    tp_direction=dl
    Set limit time value of TX power saving on and off    off_time=30    on_time=30	
    TX_switch_off_conditions_meet_before_and_during_start_power_saving_time_period
    Wait until keyword succeeds    10min    20s    Verify cell is reduced Energy Saving
    UE start traffic    tp_direction=dl    dl_tp=400M	
    UE check throughput by syslog    tp_direction=dl    exp_dl_tp=300
    Modify to 4D4U via admin
    Detach UE for case finished
    Wait Until Keyword Succeeds    10min    5s    Verify all cells should be onair    connection=GNB_OAM
    Modify 2RX to 4RX
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    run keyword and ignore error    UE Reboot with adb command    ue_index=${-1}
    Wait until keyword succeeds    2min    10s    Verify cell is reduced Energy Saving
    Modify to open loop
    Wait Until Keyword Succeeds    10min    5s    Verify all cells should be onair    connection=GNB_OAM	
	Attach UE
    Wait until keyword succeeds    2min    10s    Verify cell is reduced Energy Saving
    Start traffic and check UE DL and UL TP seperately    
    ...    expect_dl_tp=300    expect_ul_tp=48    dl_traffic=400M    ul_traffic=90M
    Wait until keyword succeeds    2min    10s    Verify cell is reduced Energy Saving
    Modify 4RX to 2RX
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Wait until keyword succeeds    2min    10s    Verify cell is reduced Energy Saving    
	Modify to 4D2U via admin
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM   
    Wait until keyword succeeds    2min    10s    Verify cell is reduced Energy Saving
    [teardown]    run keywords    D1 case teardown    AND    robot_common_operations.Common Case Teardown    
	
[1]CB008392-A_15_View_Power_Saving_Performance_Management_Counters
    [Tags]    CIT_TRUNK     CRT_TRUNK
    Counter case setup
    TX_switch_off_conditions_meet_before_and_during_start_power_saving_time_period
    Wait until keyword succeeds    8min    5s    Verify cell is reduced Energy Saving    
    sleep    15min
    Selenium Login And Disable Screen Lock    download_dir=/tmp
    ${counter_value}    Get PM Counter via Webem    counter_id=M55601C02002    interval=15min
    ${counter_value}    convert to integer    ${counter_value}
    should Be True    ${counter_value} != 0
    ${counter_value1}    Get PM Counter via Webem    counter_id=M55601C02001    interval=15min
    ${counter_value1}    convert to integer    ${counter_value1}
    run keyword and ignore error    should Be True    ${counter_value1} != 0
    [teardown]    run keywords    Feature CB008392 Deactive    AND    Counter case teardown    

[1]CB008392-A_1_Feature_CB008392_Activation
    [Tags]    CRT_TRUNK
    Feature CB008392 Active using admin
    [teardown]    Feature CB008392 Deactive    
	
[1]CB008392-A_2_Feature_CB008392_Deactivation	
    [Tags]    CRT_TRUNK
	Set limit time value of TX power saving on and off    off_time=300    on_time=30
    TX_switch_off_conditions_meet_before_and_during_start_power_saving_time_period
    Wait until keyword succeeds    5min    1s    Verify cell is switchingOffRTX state
    Feature CB008392 Deactive
    Wait until keyword succeeds    3min    20s    Verify cell is not energy saving state
	[teardown]    Feature CB008392 Deactive

[1]CB008392-A_3_Feature_CB008392_Deactivation_with_cell_in_reducedEnergySaving_state
    [Tags]    CRT_TRUNK
    Set limit time value of TX power saving on and off    off_time=30    on_time=30
    Wait until keyword succeeds    3min    10s    Verify cell is not energy saving state
    UE Prepare and UE attach
    Start traffic and check UE DL and UL TP seperately    
	...    expect_dl_tp=1350    expect_ul_tp=65    dl_traffic=1600M    ul_traffic=90M	
    TX_switch_off_conditions_meet_before_and_during_start_power_saving_time_period
    Wait until keyword succeeds    1min    10s    Verify cell is reduced Energy Saving
    Start traffic and check UE DL and UL TP seperately    
	...    expect_dl_tp=600    expect_ul_tp=65    dl_traffic=700M    ul_traffic=90M
    Deactive cell which is in reducedEnergySaving state
    Wait until keyword succeeds    1min    10s    Verify cell is not energy saving state	
	Start traffic and check UE DL and UL TP seperately    
	...    expect_dl_tp=1350    expect_ul_tp=65    dl_traffic=1600M    ul_traffic=90M
    [teardown]    run keywords    Feature CB008392 Deactive    AND    Detach UE for case finished
    ...    AND    robot_common_operations.Common Case Teardown
	
[1]CB008392-A_11_Suspend_Load_Based_Reduced_TX_Paths_Power_Saving
    [Tags]    CRT_TRUNK
    TX_switch_off_conditions_meet_before_and_during_start_power_saving_time_period
    Wait until keyword succeeds    10min    20s    Verify cell is reduced Energy Saving
    Suspend cells which is in reduced energy saving state
    Verify cell is not energy saving state
	
[1]CB008392-A_12_Un_Suspend_Load_Based_Reduced_TX_Paths_Power_Saving	
    [Tags]    CRT_TRUNK
    Unsuspend cells which is in not energy saving state
    Wait until keyword succeeds    10min    10s    Verify cell is reduced Energy Saving
    [teardown]    Feature CB008392 Deactive

	
[1]CB008392-interworking_with_IRC_with_beamforming
    [Tags]    CRT_TRUNK
    [Setup]    Modify precondition for IRC case
    UE Prepare and UE attach
	UE start traffic    tp_direction=ul    ul_tp=100M
	UE check throughput by syslog    tp_direction=ul    exp_ul_tp=78	
    TX_switch_off_conditions_meet_before_and_during_start_power_saving_time_period	
    Wait until keyword succeeds    10min    20s    Verify cell is reduced Energy Saving
    UE check throughput by syslog    tp_direction=ul    exp_ul_tp=78
    UE stop traffic    tp_direction=ul	
    [teardown]    run keywords    Feature CB008392 Deactive    AND    Detach UE for case finished	
	
[1]CB008392-interworking_with_5GC000341
    [Tags]    CIT_TRUNK     CRT_TRUNK
	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Modify to close loop
	#Set limit time value of TX power saving on and off    off_time=30    on_time=30
    TX_switch_off_conditions_meet_before_and_during_start_power_saving_time_period	
    Wait until keyword succeeds    1min    10s    Verify cell is reduced Energy Saving
    Modify to open loop
    Wait until keyword succeeds    1min    1s    Verify cell is not energy saving state
	Wait until keyword succeeds    2min    10s    Verify cell is reduced Energy Saving
    Modify to close loop
	Wait until keyword succeeds    1min    1s    Verify cell is not energy saving state
	Wait until keyword succeeds    2min    10s    Verify cell is reduced Energy Saving
    Block dedicated cell    cell_id=1
	Wait until keyword succeeds    1min    1s    Verify cell is not energy saving state
    Unblock dedicated cell    cell_id=1
    Wait until keyword succeeds    2min    10s    Verify cell is reduced Energy Saving
	Modify parameter administrativeState    value=Shutting Down
	Wait until keyword succeeds    3min    10s    Verify cell is not energy saving state
	Wait until keyword succeeds    3min    10s    Modify parameter administrativeState    value=Unlocked
	Wait until keyword succeeds    2min    10s    Verify cell is reduced Energy Saving
    [teardown]    run keywords    Feature CB008392 Deactive    
	...    AND    Check If there is new alarm
    ...    AND    Modify parameter administrativeState    value=Unlocked  

[1]CB008392-A_6_Determine_Cell_Switch_Off_List
    [Tags]    CRT_TRUNK	
    Set lbpsLastCellSOEnabled to true    NRPGRP_id=1
    TX_switch_off_conditions_meet_before_and_during_start_power_saving_time_period
    ...    NRPGRP_id=1
    Wait until keyword succeeds    10min    20s    Verify cell is reduced Energy Saving    cell_index=5
	Verify cell is not energy saving state    cell_index=1
    Wait until keyword succeeds    10min    20s    Verify cell is reduced Energy Saving    cell_index=1	

[1]CB008392-A_10_Handle_Cell_or_TX_Path_Outage_Impact_on_Capacity_cell_locking	
    [Tags]    CRT_TRUNK	
    TX_switch_off_conditions_meet_before_and_during_start_power_saving_time_period
    ...    NRPGRP_id=1
    Wait until keyword succeeds    10min    20s    Verify cell is reduced Energy Saving    cell_index=5
    run keyword and ignore error    Verify cell is not energy saving state    cell_index=1
    Make one cell fail or recovery cell    gscn_value=8    	
	#changed after PR671535
    Wait until keyword succeeds    10min    10s    Verify cell is not energy saving state     cell_index=5
	Make one cell fail or recovery cell    gscn_value=1
    Block dedicated cell    cell_id=1  
    Unblock dedicated cell    cell_id=1
    Verify cell is not energy saving state     cell_index=5
    sleep    5min
    Wait until keyword succeeds    1min    10s    Verify cell is reduced Energy Saving    cell_index=5
    [teardown]    run keywords    Make one cell fail or recovery cell    gscn_value=1
    ...    AND    Block dedicated cell    cell_id=1  
    ...    AND    Unblock dedicated cell    cell_id=1
    ...    AND    Feature CB008392 Deactive	
	
[1]CB008392-A_16_Cell_RTX_off_Order_last_cell_switch_off_enabled	
    [Tags]    CRT_TRUNK	
    Set lbpsLastCellSOEnabled to true    NRPGRP_id=2
    TX_switch_off_conditions_meet_before_and_during_start_power_saving_time_period
    ...    NRPGRP_id=2
    Wait until keyword succeeds    10min    20s    Verify cell is reduced Energy Saving    cell_index=6
    [teardown]    Feature CB008392 Deactive	

[1]CB008392-E_1_interworking_with_5GC000431	
    [Tags]    CRT_TRUNK
    run keyword and ignore error    Verify all cells should be onair    connection=GNB_OAM        
    Scf muti-radio commition and wair for on-air    scf_name=${scf_path}/${Muti_RF_scf_name}
	Set Suite Variable    ${default_scf}    ${scf_path}/${Muti_RF_scf_name}
    TX_switch_off_conditions_meet_before_and_during_start_power_saving_time_period
    Wait until keyword succeeds    10min    20s    Verify cell is reduced Energy Saving    cell_index=2
    Feature 5GC000431 Active using admin    NRPGRP_id=2	
    Cell_switch_off_conditions_meet_before_and_during_start_power_saving_time_period
    ...    NRPGRP_id=2	
    Wait until keyword succeeds    10min    20s    Verify cell is energy saving state    cell_index=3  
	Wait until keyword succeeds    10min    20s    Verify cell is reduced Energy Saving    cell_index=1
    Modify to close loop
    Modify to open loop
    Verify cell is not energy saving state     cell_index=1
    Verify cell is reduced Energy Saving    cell_index=2
    Verify cell is energy saving state    cell_index=3  
    Wait until keyword succeeds    10min    20s    Verify cell is reduced Energy Saving    cell_index=1
	
*** Keywords ***	
Subsector case precondition	
    log to console    \nSubsector case precondition	
    ${stream}    get stream from version    ${Active_SW_version}
    Run Keyword If    '${stream}'=='SBTS00'    Commissioning BF trunk SCF And Check On Air	
    UE Reboot with adb command
	
Commissioning BF trunk SCF And Check On Air	
    log to console    \nCommissioning BF trunk SCF And Check On Air	
    ${precondition_scf}    String.Replace String    ${Golden_SCF_Path}    SCF_SBTS00.xml    SCF_2SS_SBTS00.xml
    Commissioning SCF And Check On Air    scf_path=${precondition_scf}
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
	
Counter case setup
    log to console    \nCounter case setup
	csn.connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
	
Counter case teardown
    log to console    \nCounter case teardown
    csn.Disconnect     connection=ASIK Master 

BF 4D2U case precondition
    ${stream}    get stream from version    ${Active_SW_version}
    ${precondition_scf}    String.Replace String    ${Golden_SCF_Path}    SCF_${stream}.xml    SCF_BF_${stream}.xml
    Commissioning SCF And Check On Air    scf_path=${precondition_scf}
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
	
Modify to 4D4U
    log to console    \nModify to 4D4U
    ${modify_params}    create list
    #${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    #...    filter_param=Downlink MIMO Mode    p_name=dlMimoMode    value=4x4 or 4x2 Closed Loop Spatial Multiplexing
    #append to list    ${modify_params}    ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    filter_param=NR Cell type    p_name=nrCellType  value=4DL4UL
    append to list  ${modify_params}  ${item}	
    #${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    #...    filter_param=Number of Rx beamforming    p_name=numberOfRxBeamforming    value=4Rx 
    #append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate frequency domain scheduling    p_name=actFdmScheduling    value=true 
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate enhanced frequency domain scheduling    p_name=actFdmEnhancedScheduling    value=true 
    append to list    ${modify_params}    ${item}		
    Selenium Login And Disable Screen Lock    download_dir=/tmp
    Modify Parameters On Webem    modify_params=${modify_params}    despite_errors=${True}
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    [Teardown]    Selenium Logout And Close Browser


Modify 4RX to 2RX
    log to console    \nModify 4RX to 2RX
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=numberOfRxBeamforming
    ...    value=2Rx
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM	
	
Modify 2RX to 4RX
    log to console    \nModify 2RX to 4RX
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=numberOfRxBeamforming
    ...    value=4Rx
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM	
	
case setup
    log to console    \ncase setup
    run keyword and ignore error    UE Reboot with adb command    ue_index=${-1}	
	
	
D1 case teardown
    log to console    \nD1 case teardown
	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Feature CB008392 Deactive 
	Detach UE for case finished	

Modify to 4D2U 
    log to console    \nModify to 4D2U
    ${modify_params1}    create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    filter_param=NR Cell type    p_name=nrCellType  value=4DL2UL
    append to list  ${modify_params1}  ${item}
    Selenium Login And Disable Screen Lock    download_dir=/tmp
    Modify Parameters On Webem    modify_params=${modify_params1}    despite_errors=${True}
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    [Teardown]    Selenium Logout And Close Browser

Modify to 4D4U via admin
    log to console    \nModify to 4D4U
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=nrCellType
    ...    value=4DL4UL
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
	
Modify to 4D2U via admin
    log to console    \nModify to 4D2U
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=nrCellType
    ...    value=4DL2UL
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM   
   
