*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case to verify the current capacity need for a Power Group and whether member Cells may be switched off to gain power
...  saving or whether switched off Cells must be switched on to increase capacity.
...  *****************
...  Pre-conditions
...  *****************
...  gNB is in operational On Air state, No active alarms on gNB, At least one non singleTX cell available
...  ******************
...  History of changes
...  ******************
...  17.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-213 - - TC creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking
    PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking:0 Test Preparation
    PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking:1 Disable Features
    PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking:2 Create and activate NRGRP
    PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking:3 Check Energy saving states and wake up cells
    PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking:4 Handle Cell Outage
    PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking:5 Final recovery

PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
#    Set Test Variable  ${ue}  NOKIA83
    Set Test Variable  ${ue}  NOKIA83_NR
    Select All NR Cells
    @{feature_flags}=  Create List  actLbpsCtrlLogicEnh  actNrLBPowerSaving
    Set Test Variable  ${feature_flags}
    Set Test Variable    ${selected_cells}
    Set Test Variable    ${selected_cells_paths}
    Sort List    ${selected_cells}
    Sort List    ${selected_cells_paths}
    Set Test Variable  ${1st_NRCELL_ID}  554
    Set Test Variable  ${2nd_NRCELL_ID}  551
    Set Test Variable  ${3d_NRCELL_ID}  552
    Set Test Variable  ${4th_NRCELL_ID}  553
    Set Test Variable  ${1st_NRCELL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-10819/NRCELL_R-4
    Set Test Variable  ${2nd_NRCELL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-10819/NRCELL_R-1
    Set Test Variable  ${3d_NRCELL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-10819/NRCELL_R-2
    Set Test Variable  ${4th_NRCELL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-10819/NRCELL_R-3
    ${selected_cells_IDs}=  Create List  ${1st_NRCELL_ID}  ${2nd_NRCELL_ID}  ${3d_NRCELL_ID}  ${4th_NRCELL_ID}
    Set Test Variable  ${selected_cells_IDs}
    Log To Console  Energy Saving for NRCEL_R-${1st_NRCELL_ID} and NRCEL_R-${2nd_NRCELL_ID}
    Check Power Saving NR  ${1st_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    ${selected_cells_DNs}=  Create List  ${1st_NRCELL_DN}  ${2nd_NRCELL_DN}  ${3d_NRCELL_DN}
    Set Test Variable  ${selected_cells_DNs}
    Check If Not Energy Saving Cells Are Enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}

PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking:1 Disable Features
    Log to console    \n========================================
    Log  Step: 1 Disable Features  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${NRBTS_DistName}  ${feature_flags}  false
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox

PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking:2 Create and activate NRGRP
    Log to console    \n========================================
    Log  Step: 2 Create and activate NRGRP  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    ${if_actNrExtCellSOMethod}  ${value_actNrExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under NRBTS  actNrExtCellSOMethod
    Set Test Variable  ${if_actNrExtCellSOMethod}
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  36
    Create And Activate NRPGRP for 5GC000431_Cell_Outage  1   120
    Set Feature Under Given Object  ${NRBTS_DistName}  ${feature_flags}  true
    Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking:3 Check Energy saving states and wake up cells
    Log to console    \n========================================
    Log  Step: 3 Check Energy saving states and wake up cells  console=${True}
    Log to console    ========================================
    Log to console  check Energysaving for NRCELL ${selected_cells[0]}
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Configure Attenuator Before Test
    Switch Off Cells According To Order
##=================================CALL 63 CELL TO WAKE UP 61 CELL============================================
#    Start UE traffic  expected_pci=85  NR_call=${false}  tput_ul=5  tput_dl=5   duration=4
##    Start UE traffic  expected_pci=${3d_NRCELL_ID}  NR_call=${true}  tput_ul=55  tput_dl=50   duration=65
#    Start UE traffic  expected_pci=${3d_NRCELL_ID}  NR_call=${true}  tput_ul=40  tput_dl=45   duration=45
#    Attenuate NR Cell  ${3d_NRCELL_ID}  ${90}
#    Wait Until Keyword Succeeds  50sec  10sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
#    Check If Unexpected Alarms Are Raised  ${skip_fault}
#=================================CALL 553 CELL TO WAKE UP 552 CELL============================================
#####    Start UE traffic  expected_pci=85  NR_call=${false}  tput_ul=5  tput_dl=5   duration=4
#    Start UE traffic  expected_pci=${3d_NRCELL_ID}  NR_call=${true}  tput_ul=55  tput_dl=50   duration=65
    Start UE SA traffic  expected_pci=02a4242290  NR_call=${true}  tput_ul=30  tput_dl=50   duration=70
#    Attenuate NR Cell  ${2nd_NRCELL_ID}  ${90}    #new_line!!!
    Attenuate NR Cell  ${4th_NRCELL_ID}  ${90}
    Wait Until Keyword Succeeds  70sec  10sec  Check Power Saving NR  ${3d_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    Check If Unexpected Alarms Are Raised  ${skip_fault}
##=================================CALL 61 CELL TO WAKE UP 60 CELL============================================
#    Start UE traffic  expected_pci=${2nd_NRCELL_ID}  NR_call=${true}  tput_ul=120  tput_dl=80   duration=95
#    Wait Until Keyword Succeeds  50sec  10sec  Check Power Saving NR  ${1st_NRCELL_ID}  ENABLED  NOTENERGYSAVING
#    Check If Unexpected Alarms Are Raised  ${skip_fault}
#    Configure Attenuator Before Test
#    Switch Off Cells According To Order
#=================================CALL 552 CELL TO WAKE UP 551 CELL============================================
#####    Start UE traffic  expected_pci=85  NR_call=${false}  tput_ul=5  tput_dl=5   duration=4    #new_line
    Start UE SA traffic  expected_pci=02a4242280  NR_call=${true}  tput_ul=50  tput_dl=130   duration=240
    Wait Until Keyword Succeeds  60sec  10sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Configure Attenuator Before Test
    Switch Off Cells According To Order
#    #=================================CALL 63 CELL TO WAKE UP ALL CELLS============================================
#    Start UE traffic  expected_pci=85  NR_call=${false}  tput_ul=5  tput_dl=5   duration=4
#    Start UE traffic  expected_pci=${3d_NRCELL_ID}  NR_call=${true}  tput_ul=300  tput_dl=85   duration=65
#    Wait Until Keyword Succeeds  50sec  10sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
#    Wait Until Keyword Succeeds  50sec  10sec  Check Power Saving NR  ${1st_NRCELL_ID}  ENABLED  NOTENERGYSAVING
#    Check If Unexpected Alarms Are Raised  ${skip_fault}
    #=================================CALL 63 CELL TO WAKE UP ALL CELLS============================================
#####    Start UE traffic  expected_pci=85  NR_call=${false}  tput_ul=5  tput_dl=5   duration=4
    Start UE SA traffic  expected_pci=02a4242290  NR_call=${true}  tput_ul=70  tput_dl=200   duration=400
    Wait Until Keyword Succeeds  60sec  10sec  Check Power Saving NR  ${3d_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    Wait Until Keyword Succeeds  60sec  10sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking:4 Handle Cell Outage
    Log to console    \n========================================
    Log  Step: 4 Handle Cell Outage   console=${True}
    Log to console    ========================================
#=================================Changes in NRPGRP============================================
    Log  Changes in NRPGRP  console=${true}
    ${delta_reconfig_nrpgrp}=  Set Variable  delta_reconfig_nrpgrp
    admin.create delta  ${delta_reconfig_nrpgrp}
    ${lbpsCellList}=  Create Dictionary
    ${lbpsCelPeriodList_reconfig}=  Create Dictionary
    ${item}=  Create List  1  2  3
    ${NRPGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1
    FOR  ${i}  ${cell}  IN ZIP  ${item}  ${selected_cells_IDs}
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${i}
        Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        Set To Dictionary  ${lbpsCellList}  nrCellId=${cell}
        admin.append complex item to delta  ${NRPGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_reconfig_nrpgrp}
    END
    admin.get delta  ${delta_reconfig_nrpgrp}
    admin.save delta  ${RESULTS}/delta_reconfig_nrpgrp.json  ${delta_reconfig_nrpgrp}
    admin.perform delta recommissioning  ${RESULTS}/delta_reconfig_nrpgrp.json  ${delta_reconfig_nrpgrp}
    Log  Changes in NRPGRP Finished  console=${true}
#=================================Waiting for ENERGYSAVING on NRCEL_R_1============================================
    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${1st_NRCELL_ID}
    Wait Until Keyword Succeeds  6min  15sec  Check Power Saving NR  ${1st_NRCELL_ID}  ENABLED  SWITCHINGOFF
    Log To Console  NRCEL_R-${1st_NRCELL_ID} START TO SWITCHINGOFF
    Wait Until Keyword Succeeds  150sec  10sec  Check Power Saving NR  ${1st_NRCELL_ID}  DISABLED  ENERGYSAVING
    Log To Console  NRCEL_R-${1st_NRCELL_ID} ENTER ENERGYSAVING
#=================================Waiting for ENERGYSAVING on NRCEL_R_2============================================
    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${2nd_NRCELL_ID}
    Wait Until Keyword Succeeds  6min  15sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  SWITCHINGOFF
    Log To Console  NRCEL_R-${2nd_NRCELL_ID} START TO SWITCHINGOFF
    Wait Until Keyword Succeeds  150sec  10sec  Check Power Saving NR  ${2nd_NRCELL_ID}  DISABLED  ENERGYSAVING
    Log To Console  NRCEL_R-${2nd_NRCELL_ID} ENTER ENERGYSAVING
##=================================Waiting for ENERGYSAVING on NRCEL_R_3============================================
#    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${3d_NRCELL_ID}
#    Wait Until Keyword Succeeds  6min  15sec  Check Power Saving NR  ${3d_NRCELL_ID}  ENABLED  SWITCHINGOFF
#    Log To Console  NRCEL_R-${3d_NRCELL_ID} START TO SWITCHINGOFF
#    Wait Until Keyword Succeeds  110sec  10sec  Check Power Saving NR  ${3d_NRCELL_ID}  DISABLED  ENERGYSAVING
#    Log To Console  NRCEL_R-${3d_NRCELL_ID} ENTER ENERGYSAVING
#=================================Check If NRCEL_R_2 Not Energy Saving============================================
    Check Power Saving NR  ${3d_NRCELL_ID}  ENABLED  NOTENERGYSAVING
#======================================== RMOD RESET ========================================================
    Log    ==Reset radio RMOD 2 ==  console=True
    ${bts_info}  Get BTS Info
    ${rmods}  Set variable  ${bts_info['radioModules']['rmod']}
    Set Test Variable  ${selected_rmod}  MRBTS-10819/EQM-1/APEQM-1/RMOD-2
    Log    ==Reset radio ${selected_rmod}==  console=True
    Run keyword and ignore error    admin.Reset Unit  ${selected_rmod}  timeout=10
    ${bts_info}  Get BTS Info
    ${rmods}  Set variable  ${bts_info['radioModules']['rmod']}
    FOR  ${rmod}  IN  @{rmods}
        ${rmod_states}  Get from dictionary  ${rmod}  status
        ${operational_state}  Get from dictionary  ${rmod_states}  operationalState
        IF  '${rmod['id']['configuration']}' == '${selected_rmod}'  Should Be True  '${operational_state}'=='disabled'
    END
    Log    ==RMOD Reseting==    console=True
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Sleep   10sec
#    Wait Until Keyword Succeeds  10sec  10sec  Check Power Saving NR  ${1st_NRCELL_ID}  ENABLED  NOTENERGYSAVING
#    Log To Console  restore service for NRCEL_R-${1st_NRCELL_ID}
#    Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    Wait Until Keyword Succeeds  55sec  10sec  Check Power Saving NR  ${1st_NRCELL_ID}  ENABLED  NOTENERGYSAVING
#    Log To Console  restore service for NRCEL_R-${1st_NRCELL_ID}
    Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    #=================================Waiting for ENERGYSAVING on NRCEL_R_3============================================
    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${1st_NRCELL_ID}
    Wait Until Keyword Succeeds  7min  15sec  Check Power Saving NR  ${1st_NRCELL_ID}  ENABLED  SWITCHINGOFF
    Log To Console  NRCEL_R-${1st_NRCELL_ID} START TO SWITCHINGOFF
    Wait Until Keyword Succeeds  150sec  10sec  Check Power Saving NR  ${1st_NRCELL_ID}  DISABLED  ENERGYSAVING
    Log To Console  NRCEL_R-${1st_NRCELL_ID} ENTER ENERGYSAVING
#=================================Waiting for NOTENERGYSAVING on NRCEL_R_4============================================
    Wait Until Keyword Succeeds  3min  15sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
#=================================Waiting for ENERGYSAVING on NRCEL_R_4============================================
    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${2nd_NRCELL_ID}
    Wait Until Keyword Succeeds  7min  15sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  SWITCHINGOFF
    Log To Console  NRCEL_R-${2nd_NRCELL_ID} START TO SWITCHINGOFF
    Wait Until Keyword Succeeds  150sec  10sec  Check Power Saving NR  ${2nd_NRCELL_ID}  DISABLED  ENERGYSAVING
    Log To Console  NRCEL_R-${2nd_NRCELL_ID} ENTER ENERGYSAVING
##=================================Waiting for ENERGYSAVING on NRCEL_R_3============================================
#    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${3d_NRCELL_ID}
#    Wait Until Keyword Succeeds  5min  15sec  Check Power Saving NR  ${3d_NRCELL_ID}  ENABLED  SWITCHINGOFF
#    Log To Console  NRCEL_R-${3d_NRCELL_ID} START TO SWITCHINGOFF
#    Wait Until Keyword Succeeds  110sec  10sec  Check Power Saving NR  ${3d_NRCELL_ID}  DISABLED  ENERGYSAVING
#    Log To Console  NRCEL_R-${3d_NRCELL_ID} ENTER ENERGYSAVING
#=================================Check If NRCEL_R_2 Not Energy Saving============================================
    ${post_action_reset_number}=  Get Reset Counter From Blackbox

PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking:5 Final recovery
    Log to console    \n========================================
    Log  Step: 5 Final recovery and verification  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${NRBTS_DistName}  ${feature_flags}  false
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}

PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking.Test Specific Teardown
    Run Keyword If Test Failed  PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking:5 Final recovery
    Run Keywords  common.Common Test Teardown

Configure Attenuator Before Test
    attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
    Set attenuator value on all ports  set_value_db=${90}
    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-1 PID:85 CID:2767873
    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-1 PID:60 CID:177143868
    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-1 PID:60 CID:177143868
    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-1 PID:60 CID:177143868
#	Adjust attenuation value for port  set_value_db=${90}  port=${att_port_5}   #NRCEL-2 PID:61 CID:177143869
#	Adjust attenuation value for port  set_value_db=${90}  port=${att_port_6}  #NRCEL-3 PID:63 CID:177143871
	Log to console  == Attenuator Configured ==

Attenuate NR Cell
    [Arguments]   ${nr_cell_id}    ${port_value}
    IF  '${nr_cell_id}' == '552'
        attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
        Adjust attenuation value for port  set_value_db=${port_value}  port=${att_port_5}
        Adjust attenuation value for port  set_value_db=${port_value}  port=${att_port_6}
        Adjust attenuation value for port  set_value_db=${port_value}  port=${att_port_7}
        Adjust attenuation value for port  set_value_db=${port_value}  port=${att_port_8}
    ELSE IF  '${nr_cell_id}' == '553'
        attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
        Adjust attenuation value for port  set_value_db=${port_value}  port=${att_port_9}
        Adjust attenuation value for port  set_value_db=${port_value}  port=${att_port_10}
        Adjust attenuation value for port  set_value_db=${port_value}  port=${att_port_11}
        Adjust attenuation value for port  set_value_db=${port_value}  port=${att_port_12}
    END
#    ...  ELSE IF  '${nr_cell_id}' == '60'    #new_line!!! dar nu mai trebuie la 35/25 lbps__Load
#    ...  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}    #new_line!!! dar nu mai trebuie la 35/25 lbps__Load
#    ...  AND  Adjust attenuation value for port  set_value_db=${port_value}  port=${att_port_4}    #new_line


Switch Off Cells According To Order
#    Attach to cell 60
#####    Start UE traffic  expected_pci=85  NR_call=${false}  tput_ul=5  tput_dl=5   duration=3
#    Start UE traffic  expected_pci=${1st_NRCELL_ID}  NR_call=${true}  tput_ul=5  tput_dl=5   duration=3
#    Start UE traffic  expected_pci=${1st_NRCELL_ID}  NR_call=${true}  tput_ul=9  tput_dl=9   duration=5
    Start UE SA Traffic  expected_pci=02a4242270  NR_call=${true}  tput_ul=10  tput_dl=10   duration=3
#    Start UE traffic  expected_pci=${2nd_NRCELL_ID}  NR_call=${true}  tput_ul=9  tput_dl=9   duration=5
#    Attenuate NR Cell  ${2nd_NRCELL_ID}  ${0}
    Attenuate NR Cell  ${3d_NRCELL_ID}  ${0}

#    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${1st_NRCELL_ID}
#    Wait Until Keyword Succeeds  8min  15sec  Check Power Saving NR  ${1st_NRCELL_ID}  ENABLED  SWITCHINGOFF
	#5min before
    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${2nd_NRCELL_ID}
    Wait Until Keyword Succeeds  8min  15sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  SWITCHINGOFF
#    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${2nd_NRCELL_ID}
#    Wait Until Keyword Succeeds  8min  15sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  SWITCHINGOFF
    Log To Console  NRCEL_R-${2nd_NRCELL_ID} START TO SWITCHINGOFF
#    Wait Until Keyword Succeeds  110sec  10sec  Check Power Saving NR  ${1st_NRCELL_ID}  DISABLED  ENERGYSAVING
	#50s before
#    Log To Console  NRCEL_R-${1st_NRCELL_ID} ENTER ENERGYSAVING
    Wait Until Keyword Succeeds  110sec  10sec  Check Power Saving NR  ${2nd_NRCELL_ID}  DISABLED  ENERGYSAVING
    Log To Console  NRCEL_R-${2nd_NRCELL_ID} ENTER ENERGYSAVING

    #Attach to cell 61
#####    Start UE traffic  expected_pci=85  NR_call=${false}  tput_ul=5  tput_dl=5   duration=4
#    Start UE traffic  expected_pci=${2nd_NRCELL_ID}  NR_call=${true}  tput_ul=5  tput_dl=5   duration=2
#    Start UE traffic  expected_pci=${2nd_NRCELL_ID}  NR_call=${true}  tput_ul=6  tput_dl=5   duration=3
#    Attenuate NR Cell  ${3d_NRCELL_ID}  ${0}
#    Start UE Traffic  expected_pci=${3d_NRCELL_ID}  NR_call=${true}  tput_ul=6  tput_dl=5   duration=3
    Start UE SA Traffic  expected_pci=02a4242280  NR_call=${true}  tput_ul=10  tput_dl=10   duration=3
    Attenuate NR Cell  ${4th_NRCELL_ID}  ${0}

#    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${2nd_NRCELL_ID}
#    Wait Until Keyword Succeeds  3min  15sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  SWITCHINGOFF
#    Log To Console  NRCEL_R-${2nd_NRCELL_ID} START TO SWITCHINGOFF
#    Wait Until Keyword Succeeds  110sec  10sec  Check Power Saving NR  ${2nd_NRCELL_ID}  DISABLED  ENERGYSAVING
#	#50s before
#    Log To Console  NRCEL_R-${2nd_NRCELL_ID} ENTER ENERGYSAVING
    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${3d_NRCELL_ID}
    Wait Until Keyword Succeeds  5min  15sec  Check Power Saving NR  ${3d_NRCELL_ID}  ENABLED  SWITCHINGOFF
    Log To Console  NRCEL_R-${3d_NRCELL_ID} START TO SWITCHINGOFF
    Wait Until Keyword Succeeds  110sec  10sec  Check Power Saving NR  ${3d_NRCELL_ID}  DISABLED  ENERGYSAVING
    Log To Console  NRCEL_R-${3d_NRCELL_ID} ENTER ENERGYSAVING
