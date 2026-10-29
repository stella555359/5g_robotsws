*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/netact.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Test checks scenario where RU powers on the FPFH PDU port after it was switched off for energy saving,
...  when there is cell on RU that need to be activated.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  20.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-495 - TC creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
@{supported_RU_models}=  AENB  AEQQ

*** Keywords ***
PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation
    PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test_Step:0 Test Preparation
    PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test_Step:1 Disable Feature Before Test
    PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test_Step:2 Create And Activate NRPGRP
    PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test_Step:3 Waiting For Energy Savig Ang Deepsleep
    PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test_Step:4 Enable CB009176 For RU Connected To FPFH PDU Port
    PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test_Step:5 Cell Activation
    PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test_Step:6 Final Recovery

PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    @{cb008745_feature_flags}=  Create List  actLbpsCtrlLogicEnh  actNrLBPowerSaving
    Set Test Variable  ${cb008745_feature_flags}
    @{lnbts_flags}=  Create List  actLBPowerSaving  actLBRTXPowerSaving
    Set Test Variable  ${lnbts_flags}
    @{selected_cells_IDs}=  Create List
    ${ru_info}=  Create Dictionary
    ${dcport_info}=  Create Dictionary
    Set Test Variable  @{selected_cells_IDs}
    Set Test Variable  ${ru_info}
    Set Test Variable  ${dcport_info}
    ${rmodModel}  Evaluate  random.choice(${supported_RU_models})  random
    ${all_rmods}=  admin.get managed objects  RMOD_R
    Set Test Variable  ${rmodModel}
    Set Test Variable  ${all_rmods}
    @{rmods_and_nrcells}=  Get All Radios And Their Cells
    Get Selected RU Info
    ${all_dcports}=  admin.get managed objects  DCPORT_A
    Set Test Variable  ${all_dcports}

PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test_Step:1 Disable Feature Before Test
    Log to console    \n========================================
    Log  Step: 1 Disable Feature Before Test  console=${True}
    Log to console    ========================================
    Set Feature Under Given Object  ${NRBTS_DistName}  ${cb008745_feature_flags}  false
    Set Test Variable  ${featcadm_dn}  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    FOR  ${dcport}  IN  @{all_dcports}
        ${parameters}=  Get From Dictionary  ${dcport}  parameters
        ${portLabel}=  Get From Dictionary  ${parameters}  portLabel
        ${dcport_Dn}=  Get From Dictionary  ${dcport}  distName
        ${split_dcportDn}=  Split String From Right  ${dcport_Dn}  separator=/SCF-1/  max_split=1
        ${dcport_Dn}=  Get From List  ${split_dcportDn}  1
        ${dcport_Dn_without_A}=  Replace String  ${dcport_Dn}  _A  ${EMPTY}
        IF  '${rmodModel}'=='${portLabel}'
            Set To Dictionary  ${dcport_info}  distName=${dcport_Dn_without_A}
            Set To Dictionary  ${dcport_info}  portLabel=${portLabel}
            Set Feature Under Given Object  ${dcport_info['distName']}  actAutoPwrOffForES  false
        END
    END
    Set Feature Under Given Object  ${featcadm_dn}  actAutoPwrOffDCPort  false
    Set Feature Under Given Object  ${ru_info['distName']}  energySavingMode  NORMAL
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP

PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test_Step:2 Create And Activate NRPGRP
    Log to console    \n========================================
    Log  Step: 2 Create And Activate NRPGRP  console=${True}
    Log to console    ========================================
    ${if_actNrExtCellSOMethod}  ${value_actNrExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under NRBTS  actNrExtCellSOMethod
    Set Test Variable  ${if_actNrExtCellSOMethod}
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  36
    Set Feature Under Given Object  ${ru_info['distName']}  energySavingMode  DEEPSLEEP
    Create And Activate NRPGRP For CB008745  1  15min  true  CB009176
    Set Feature Under Given Object  ${NRBTS_DistName}  ${cb008745_feature_flags}  true

PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test_Step:3 Waiting For Energy Savig Ang Deepsleep
    Log to console    \n========================================
    Log  Step: 3 Waiting For Energy Savig Ang Deepsleep  console=${True}
    Log to console    ========================================
    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${ru_info['cellId']}
    Wait Until Keyword Succeeds  4min  15sec  Check Power Saving NR  ${ru_info['cellId']}  ENABLED  SWITCHINGOFF
    Log To Console  NRCEL_R-${ru_info['cellId']} START TO SWITCHINGOFF
    Wait Until Keyword Succeeds  1min 10sec  10sec  Check Power Saving NR  ${ru_info['cellId']}  DISABLED  ENERGYSAVING
    Log To Console  NRCEL_R-${ru_info['cellId']} ENTER ENERGYSAVING
    Prepare To Power Off Via FPFH DC Port
    Set Feature Under Given Object  ${featcadm_dn}  actAutoPwrOffDCPort  true
    Log To Console  \Waiting For DeepSleep Mode On ${ru_info['productName']}
    Wait Until Keyword Succeeds  6min  30s  Check RU state for DEEPSLEEP  ${ru_info['distName']}  SLEEP

PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test_Step:4 Enable CB009176 For RU Connected To FPFH PDU Port
    Log to console    \n========================================
    Log  Step: 4 Enable CB009176 For RU Connected To FPFH PDU Port  console=${True}
    Log to console    ========================================
    Log To Console  \Waiting For DC Port PowerOff
    Wait Until keyword Succeeds  6min  1sec  Check Radio State DC Port PWROFF  ${ru_info['ruId']}  POWEROFFBYES  POWER OFF
    Allow Fault In Watchdog  faultID=4107
    Sleep   2s
    Check DCPort Power State And Maintenance Mode  OFF  DISABLED
    Allow Fault In Watchdog  faultID=4589    #Fault name:Unit power reset

PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test_Step:5 Cell Activation
    Log to console    \n========================================
    Log  Step: 5 Cell Activation  console=${True}
    Log to console    ========================================
    Log To Console  \nWaiting for NOTENERGYSAVING DUE TO CELL ACTIVATION
    Wait Until keyword Succeeds  25min  30sec  Check Radio State DC Port PWROFF  ${ru_info['ruId']}  AWAKE  NONE
    Log To Console  CHECK IF NRCEL_R-${ru_info['cellId']} NOTENERGYSAVING AND ENABLED
    Wait Until Keyword Succeeds  4min 10sec  10sec  Check Power Saving NR  ${ru_info['cellId']}  ENABLED  NOTENERGYSAVING
    Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test_Step:6 Final Recovery
    Log to console    \n========================================
    Log  Step: 6 Final Recovery  console=${True}
    Log to console    ========================================
    Set Feature Under Given Object  ${featcadm_dn}  actAutoPwrOffDCPort  false
    Set Feature Under Given Object  ${dcport_info['distName']}  actAutoPwrOffForES  false
    Remove RMOD dcPortWinList
    Set Feature Under Given Object  ${NRBTS_DistName}  ${cb008745_feature_flags}  false
    Set Feature Under Given Object  ${ru_info['distName']}  energySavingMode  NORMAL
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    admin.reset site  timeout=700
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${featcadm_dn}  actAutoPwrOffDCPort  false
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${dcport_info['distName']}  actAutoPwrOffForES  false
    Run Keyword And Ignore Error  Remove RMOD dcPortWinList
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${NRBTS_DistName}  ${cb008745_feature_flags}  false
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${ru_info['distName']}  energySavingMode  NORMAL
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    admin.reset site  timeout=700
    Run Keyword And Ignore Error  Check SMODs State  ${SMOD_expected_states}
    Run Keyword And Ignore Error  Check RMODs State  ${RMOD_expected_states}
    Run Keyword And Ignore Error  Check If ALDs Are Connected And Achieved Expected State
    Run Keyword And Ignore Error  common.Check BTS State  ${BTS_expected_states}
    Run Keyword And Ignore Error  Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.51_CB009176_RU_PowerOn_Through_FPFH_Due_To_Time_Window_Change.Test Specific Teardown
