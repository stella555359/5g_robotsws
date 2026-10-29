*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Library    OperatingSystem


*** Variables ***
${Target SW name}         ${None}  # SW package name. If not given, TC will choose newest package in a directory.
${Target SW dir}          /home/ute/BTSSW_bak   # Directory sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${SW Upgrade Timeout}     25m  # Given in seconds; That is a timeout for SW download and activation
${Ping loss timeout}      420  # Timeout for ping loss during reset
${Ping regain timeout}    600  # Timeout for ping regain during reset
${BTS_OnAir_Timeout}      15  # Timeout for BTS on Air (in minutes)
${Test_Timeout}           45  # Test timeout (in minutes)
${PASSIVE_SW_STATE}            #Expected SW state after rollback, available states: 'commissioned' 'notcommissioned'.
                               ...   Leave blank if TC shouldn't fail due BTS state.
${MODULES_RESTORE_TIMEOUT}      20m    #Timeout for waiting until cells are onAir/notOnAir in Robot Framework format (600s, 10m)
${CELLS_RESTORE_TIMEOUT}       20m    #Timeout for waiting until cells are onAir/notOnAir in Robot Framework format (600s, 10m)
${Second Single Core IP}      10.68.179.223


*** Keywords ***
SWM__DSC_Local_Software_Fallback_RLC_first_core
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7168
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC should perform Software_fallback in first single core and check that no impact on second single core
    ...  After that BTS state shall be verified.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...

    [Timeout]    ${Test_Timeout} minutes
    Set Tags    CA-SWM    PHASE-CIT    OWNER-kamil.osak@nokia.com    AUTHOR-sebastian.burniak@nokia.com
    ...    MAINTAINER-wojciech.sikora@nokia.com    GROUP_IN_CHARGE-HZH_2_Vrf    SW-SBTS20C    SW-SBTS21A
    ...    FEATURE-CNI26582
    Status_info_after_fallback
    Stp1. Start IMlog for Second Single Core
    Stp2. perform Fallback for first single core
    Stp3. Confirm no impact for Second Single Core
    Stp4. recovery BTS

Status_info_after_fallback
    [Documentation]    Short description.
    ${cells_LTE_expected_states_after_fallback}  set variable
    ...  administrativeState=${_Unlocked}, operationalState=${_Enabled}, availabilityStatus=${_Degraded}, blockingState=Unblocked
    ${cells_WCDMA_expected_states_after_fallback}  set variable
    ...  operationalState=${_Enabled}, availabilityStatus=${_Degraded}, blockingState=Unblocked, usageState=Active
    ${cells_GSM_expected_states_after_fallback}  set variable
    ...  administrativeState=${_Unlocked}, operationalState=${_Enabled}, availabilityStatus=${_Degraded}, blockingState=Unblocked, usageState=Active
    Set Test Variable    ${cells_LTE_expected_states_after_fallback}
    Set Test Variable    ${cells_WCDMA_expected_states_after_fallback}
    Set Test Variable    ${cells_GSM_expected_states_after_fallback}

Stp1. Start IMlog for Second Single Core
    [Documentation]    Short description.
    Log Step Header  step1: Start to get IMlog For SecondSingleScore
    Setup infomodel    address=${Second Single Core IP}    port=443    use_ssl=True    alias=secondcore
    Connect infomodel    alias=secondcore

Stp2.perform Fallback for first single core
    [Documentation]    Short description.
    Delete_uboot_parameters
    Step1: Check active and passive sw version
    Step2: Software fallback
    Step3: Wait till BTS is stable
    Step4: Check software version
    Step5: Check components states
    Step6: Alarm state verification
    Add_uboot_parameters

Stp3. Confirm no impact for Second Single Core
    [Documentation]    Short description.
    Save Infomodel log    secondlog.ims2    alias=secondcore
    Check second single core not impact    secondlog.ims2

Stp4. recovery BTS
    [Documentation]    Short description.
    rollback_AF_Fallback

Check second single core not impact
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${IM_Log_Path}: <description>
    ...        ${CellID}: <description>
    [Arguments]    ${IM_Log_Path}    ${CellID}=${CELL1_INFO.ID}
    ute_admin_infomodel.Initialize Ims2 Validator    ${IM_Log_Path}
    ute_admin_infomodel.Add Expected Ims2 Event
    ...  change /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/LCELL-${CellID} [stateInfo.operationalState: Disabled -> Enabled]
    ${result}=    Run Keyword And Ignore Error    ute_admin_infomodel.Validate Ims2    alias=hfv
    Should Be True    '${result[0]}'=='FAIL'
    Log    Validation Succeed

Custom Test Setup
    [Documentation]    Short description.
    Common Test Setup  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}
    Setup hran compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Verify SSH connection and enable if necessary
    Set Test Variables
    #Create Table  sw_table  State  Active  Passive
    Set test variable  ${sw_pattern}   SBTS[1][9]|SBTS[2][0-9]

Set Test Variables
    [Documentation]    Short description.
    Set Test Variable  ${radio_dist_name}                 //EQM_L-1//RMOD_L-*/RU_L-*
    Set Test Variable  @{radio_expected_states}           administrativeState=${_Unlocked}  operationalState=${_Enabled}
    ...                                                        blockingState=Unblocked
    Set Test Variable  ${smod_dist_name}                  //MCTRL-*/BBTOP_M-*/MRBTS_M-*
    Set Test Variable  @{smod_expected_states}            administrativeState=${_Unlocked}  operationalState=${_Enabled}
    Set Test Variable  @{cells_expected_states}           administrativeState=${_Unlocked}  operationalState=${_Enabled}
    ...                                                     availabilityStatus=${_Degraded}  blockingState=Unblocked
    Set Test Variable  ${cells_dist_name}                 /MRBTS-*/RAT-*//BBTOP_M-*/MRBTS_M-*//CELL_M-*
    Set Test Variable  ${SCF_dist_name}                   /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*
    Set Test Variable  ${sw_pattern}                      (?i)SBTS(?!16)

rollback_AF_Fallback
    [Documentation]    Short description.
    ${rollback_status}=  Run keyword and return status  taf.sbts.oam.coam.admin.Rollback software
    Run keyword if    not ${rollback_status}  FAIL  Software rollback was not performed.

Step1: Check active and passive sw version
    [Documentation]    Short description.
    Log  ${\n}======================================  console=${TRUE}
    Log  Step1: Check active and passive sw version  console=${TRUE}
    Set test variable  ${sw_pattern}   SBTS[1][9]|SBTS[2][0-9]
    ${active_sw_before}  ${passive_sw_before}=  Infomodel Get SW Versions
    ${passive_sw_before_list}  Get Regexp Matches  ${passive_sw_before}  SBTS([09]{0,2})(.)*
    ${passive_sw_before_pattern}  Get From List  ${passive_sw_before_list}  0
    ${active_sw_before_list}  Get Regexp Matches  ${active_sw_before}  SBTS([09]{0,2})(.)*
    ${active_sw_before_pattern}  Get From List  ${active_sw_before_list}  0
    Set Test Variable  ${active_sw_before_suite_var}  ${active_sw_before_pattern}
    Set Test Variable  ${passive_sw_before_suite_var}  ${passive_sw_before_pattern}
    #Create Table  sw_table  State  Active  Passive
    ##[Aa]dd [Rr]ow  sw_table  Before  ${active_sw_before_suite_var}  ${passive_sw_before_suite_var}
    ${active_status}=  Run Keyword And Return Status  Should Match Regexp  ${active_sw_before}  ${sw_pattern}
    Run keyword if    not ${active_status}  Fail  ${active_sw_before} doesn't match ${sw_pattern} pattern
    ${passive_status}=  Run Keyword And Return Status  Should Match Regexp  ${passive_sw_before}  ${sw_pattern}
    Run keyword if    not ${passive_status}  Fail  ${passive_sw_before} doesn't match ${sw_pattern} pattern
    Log  Sw versions checked and set as test variables  console=${TRUE}

Step2: Software fallback
    [Documentation]    Short description.
    Log  ${\n}======================================  console=${TRUE}
    Log  Step2: Software fallback  console=${TRUE}
    ${sm_variant}=  Get SM variant
    hran_compa.Software Fallback  ${sm_variant[0]}

Step3: Wait till BTS is stable
    [Documentation]    Short description.
    Log  ${\n}======================================  console=${TRUE}
    Log  Step3: Wait till BTS is stable  console=${TRUE}
    Log  Wait For Target To Be Reachable  console=${TRUE}
    ${status}=  Run Keyword And Return Status  Wait For Target To Be Reachable  ${SMOD1['TRS_IP']}
    Run keyword if    not ${status}  Fail  BTS not reachable after reboot.
    Log  Wait For Reset  console=${TRUE}
    ${status}=  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=600
    Run keyword if    not ${status}  Set Test Restriction  Software reset was not performed.
    Log  Wait For Target To Be Reachable after Reset  console=${TRUE}
    ${status}=  Run Keyword And Return Status  Wait For Target To Be Reachable  ${SMOD1['TRS_IP']}  timeout=360
    Run keyword if    not ${status}  Fail  BTS not reachable after reset.
    Log  Check If Target Is Stable For 480s  console=${TRUE}
    ${ping_status}  ${reset_counter}  Check if target is stable and return reset counter  ${SMOD1['TRS_IP']}
    ...  min_uptime=480  max_downtime=300  timeout=1400
    Log  status:${ping_status} reset_counter:${reset_counter}  console=${TRUE}
    Run keyword if    not ${ping_status}  Fail  BTS is not stable after fallback.
    Run Keyword If  '${reset_counter}'!='0' and '${reset_counter}'!='1'  Set Test Restriction
    ...  Additional reset_number:${reset_counter} after fallback
    ...  ELSE  Log  BTS is stable after fallback.  console=${TRUE}
    ${Admin working state}  hran_admin.Reset admin and infomodel connection if broken
    Run keyword if    not ${Admin working state}  Fail  Admin and/of infomodel failure after reset. Interface reset did not help.  console=True

Step4: Check software version
    [Documentation]    Short description.
    Log  ${\n}======================================  console=${TRUE}
    Log  Step4: Check software version after fallback  console=${TRUE}
    ${software_after}  taf.sbts.oam.coam.admin.Get Software Info
    Log  Passive SW after: ${software_after['Passive SW version']}  console=${TRUE}
    Log  Active SW after: ${software_after['Active SW version']}  console=${TRUE}
    #add row  sw_table  After  ${software_after['Active SW version']}  ${software_after['Passive SW version']}
    ${active_status}=  Run Keyword And Return Status  Should Contain  ${software_after['Active SW version']}  ${passive_sw_before_suite_var}
    ...  ignore_case=${True}
    Run keyword if    not ${active_status}  Fail  ${software_after['Active SW version']} not match ${passive_sw_before_suite_var}
    ${passive_status}=  Run Keyword And Return Status  Should Contain  ${software_after['Passive SW version']}  ${active_sw_before_suite_var}
    ...  ignore_case=${True}
    Run keyword if    not ${passive_status}  Fail  ${software_after['Passive SW version']} not match ${active_sw_before_suite_var}

Step5: Check components states
    [Documentation]    Short description.
    Log  ${\n}======================================  console=${TRUE}
    Log  Step5: Check components states  console=${TRUE}
    Log  Check if active sw is commisioned  console=${TRUE}
    Verify Commissioned State
    Log  Check if modules states are correct  console=${TRUE}
    System Modules State Verification
    Log  Check cells states  console=${TRUE}
    Verify BTS cells states after fallback

Step6: Alarm state verification
    [Documentation]    Short description.
    Log  ${\n}======================================  console=${TRUE}
    Log  Step6: Alarm state verification  console=${TRUE}
    ${EXPECTED_ALARM1}=     Create Dictionary  faultId=4082  severity=Major
    ${EXPECTED_ALARM2}=     Create Dictionary  faultId=23  severity=Critical
    ${EXPECTED1}=            Create List  ${EXPECTED_ALARM1}
    ${EXPECTED2}=            Create List  ${EXPECTED_ALARM1}  ${EXPECTED_ALARM2}
    ${CRITICAL_ALARM1}=     Create Dictionary  severity=Major|Critical
    ${CRITICAL}=            Create List  ${CRITICAL_ALARM1}
    ${alarms_status1}  ${alarms_msg1}  Run Keyword And Ignore Error  Admin Check Active Alarms  expected_patterns=${EXPECTED1}
    ...  critical_patterns=${CRITICAL}
    ${alarms_status2}  ${alarms_msg2}  Run Keyword And Ignore Error  Admin Check Active Alarms  expected_patterns=${EXPECTED2}
    ...  critical_patterns=${CRITICAL}
    Run Keyword If  '${alarms_status1}'=='FAIL' and '${alarms_status2}'=='FAIL'
    ...    Fail  No Fault 4082 with Major severity found or other Major|Critical occured
    ...    ELSE IF  '${alarms_status1}'=='PASS'  run keyword  RF Modules state verification
    set test variable    ${alarms_status1}

Is Ssh Enabled
    [Documentation]  If ssh is disabled test is Failed and execution is aborted
    Setup hran compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    ${is_ssh_enabled}=  Check If Ssh Is Enabled
    Run keyword if    not ${is_ssh_enabled}  Fail  SSH not enabled

Verify Commissioned State
    [Documentation]    Short description.
    ${is_commissioned}=  Run Keyword And Return Status  Query infomodel  ${SCF_dist_name} is [stateInfo.proceduralState=validated]
    Run Keyword If  ${is_commissioned}  Log  Active sw is commisioned  console=${TRUE}
    ...  ELSE  Fail  Active sw is not commisioned

System Modules state verification
    [Documentation]    Short description.
    Log  \nChecking smod moduls states (max ${MODULES_RESTORE_TIMEOUT} for expected states)  console=${TRUE}
    ${sm_status}  ${sm_states}=  Infomodel check if all objects from path are online
    ...  ${smod_dist_name}  ${MODULES_RESTORE_TIMEOUT}  ${True}
    ...  @{smod_expected_states}
    Run keyword if    not ${sm_status}  Set Test Failed  At least one smod modul state is other than expected.
    Run keyword if  ${sm_status}  Log  All smod moduls are in expected state.  console=${TRUE}

RF Modules state verification
    [Documentation]    Short description.
    Log  \nChecking rf moduls states (max ${MODULES_RESTORE_TIMEOUT} for expected states)  console=${TRUE}
    ${rf_status}  ${rf_states}=  Infomodel check if all objects from path are online
    ...  ${radio_dist_name}  ${MODULES_RESTORE_TIMEOUT}  ${True}
    ...  @{radio_expected_states}
    Run keyword if    not ${rf_status}  Set Test Failed  At least one rf modul state is other than expected.
    Run keyword if  ${rf_status}  Log  All rf moduls are in expected state.  console=${TRUE}

Verify BTS cells states after fallback
    [Documentation]    Wrapper KW for checking all RATs cells count against SCF and comparing cells states with states defined in
    ...    ${cells_LTE_expected_states_after_fallback} , ${cells_WCDMA_expected_states_after_fallback}
    ...    and ${cells_GSM_expected_states_after_fallback} variables
    Log    Start BTS cells verification    console=${True}
    Run keyword if    ${scf_parser_started}    Set SCF cells count    LTE
    ${LTEstatus}    Run keyword and return status    Verify cells    LTE    ${cells_LTE_expected_states_after_fallback}
    ...    scf_check=${scf_parser_started}
    Run keyword if    ${scf_parser_started}    Set SCF cells count    WCDMA
    ${WCDMAstatus}    Run keyword and return status    Verify cells    WCDMA   ${cells_WCDMA_expected_states_after_fallback}
    ...    scf_check=${scf_parser_started}
    Run keyword if    ${scf_parser_started}    Set SCF cells count    GSM
    ${GSMstatus}    Run keyword and return status    Verify cells    GSM    ${cells_GSM_expected_states_after_fallback}
    ...    scf_check=${scf_parser_started}
    run keyword if   ${LTEstatus} and ${WCDMAstatus} and ${GSMstatus}    Log    All cells are in expected state.    console=${TRUE}
    ...  ELSE  Fail  At least one cell status is not in expected status

Log KPI
    [Documentation]    Short description.
    Return From Keyword If  ${fallback_occurrence}

    Add event  request          create /MRBTS-*/RAT-*/URI-*/SESSION-*/SW_ROLLBACK_IND-*
    Add cell   first_cell_down  cell_down=True  first_cell=True
    Add cell   first_cell_up    cell_up=True    first_cell=True
    Add cell   last_cell_up     cell_up=True    last_cell=True
    Setup_ims_file  ${BTS Files}/IM/InfoModel_log.ims2
    Register cells list  ${ALL_AVAILABLE_CELLS}
    ims.Create delta  reset__to__first_cell_up           request           first_cell_up
    ims.Create delta  first_cell_down__to__last_cell_up  first_cell_down   last_cell_up
    Log delta
    Log all cells downtime and uptime after alias  request
