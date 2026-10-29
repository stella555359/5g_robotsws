*** Settings ***
Documentation    TC__NRL__CM__NR_Enable_Disable_Energy_Consumption_Measurement_Collection
Variables    tc_variables/nrl__cm__nr_enable_disable_energy_consumption_measurement_collection_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${measurement_interval}  15  #This parameter defines the measurement interval for BTS Energy monitoring measurement in minutes.
                             #The acceptable range is 15, 30, 60, 360, 720, and 1440 minutes. By default value: 15
${SBTS_Energy_Consumption_Counter_Ids}  M40002C0,M40002C1,M40002C2  #Counters from SBTS_Energy_Consumption
${SBTS_RFM_Energy_Monitoring_Counter_Ids}  M40003C0,M40003C1,M40003C2,M40003C3,M40003C4,M40003C5  #Counters from SBTS_RFM_Energy_Monitoring
${SBTS_SM_Energy_Monitoring_Counter_Ids}  M40004C0,M40004C1,M40004C2,M40004C3,M40004C4,M40004C5  #Counters from SBTS_SM_Energy_Monitoring

*** Keywords ***
TC__NRL__CM__NR_Enable_Disable_Energy_Consumption_Measurement_Collection
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23407
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NRL test case for enable/disable feature CB007777/CB006831 on NR
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get shared RMOD info
    ...  - check feature CB006831/CB007777 status on NR BTS, and disable it if needed
    ...  - enable feature CB006831/CB007777 on NR with required parameters
    ...  - wait for monitoring measurement interval, then check collected counters on NR
    ...  - disable feature CB006831/CB007777 on NR BTS
    ...  - wait for monitoring measurement interval, then check collected counters on NR BTS
    ...  Pass criteria: enable/disable feature on NR works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23407 -
    ...  [Legacy][CB006831] RFS_BTS_LTE-LTE_Enable_Disable_Energy_Consumption_Measurement_Collectection
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-23407_NRL__CM__NR_Enable_Disable_Energy_Consumption_Measurement_Collection.png

    Set Tags    CA-CM    OWNER-ariel.ciucurita@nokia.com    AUTHOR-ariel.ciucurita@nokia.com    PHASE-CRT    SW-SBTS23    CABLING-RFS_01_UE

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get shared RMOD info
    Step 4: Check feature CB006831 status on NR BTS
    Step 5: Enable feature CB006831 on NR BTS
    Step 6: Check counters info on NR BTS with feature CB006831 enabled
    Step 7: Check after enable feature CB006831 all BTS state
    Step 8: Check after enable feature CB006831 all BTS alarms
    Step 9: Check after enable feature CB006831 number and state of Cells and RMs
    Step 10: Disable feature CB006831 on NR BTS
    Step 11: Check counters info on NR BTS with feature CB006831 disabled
    Step 12: Check final all BTS state
    Step 13: Check final all BTS alarms
    Step 14: Check final number and state of Cells and RMs

    [Teardown]  Particular Teardown

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get shared RMOD info
    [Documentation]
    ...  BTS info are related to shared RMOD

    Log  Step ${index}: Get shared RMOD info  console=True
    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave
    Sort List  ${Master_shared_RMOD_list}
    Set Test Variable  ${Master_shared_RMOD_list}
    Set Test Variable  ${Slave_shared_RMOD_list}
    Get RMOD ID SN dict  Master
    Get RMOD ID SN dict  Slave
    FOR  ${Master_RMOD_id}  IN  @{Master_shared_RMOD_list}
        ${RMOD_sn}=  Get From Dictionary  ${Master_module_ID_SN_dict}  ${Master_RMOD_id}
        ${Slave_RMOD_id}=  Get From Dictionary  ${Slave_module_SN_ID_dict}  ${RMOD_sn}
        Log  Shared RMOD with SN ${RMOD_sn}:  console=True
        Log  - Master RMOD id: ${Master_RMOD_id}  console=True
        Log  - Slave RMOD id: ${Slave_RMOD_id}  console=True
    END

Step ${index}: Check feature CB006831 status on NR BTS
    [Documentation]
    ...  Check feature CB006831 status on NR BTS and disable it if needed

    Log  Step ${index}: Check feature CB006831 status on NR BTS  console=True
    Set Test Variable  ${NRBTS_CB006831_precondition}  False

    ${measurement_interval_min}=  Catenate  SEPARATOR=  ${measurement_interval}  min
    Set Test Variable  ${measurement_interval_min}
    ${measurement_interval_doubled}=  BuiltIn.Evaluate  ${measurement_interval}*2
    ${measurement_interval_doubled_min}=  Catenate  SEPARATOR=  ${measurement_interval_doubled}  min
    Set Test Variable  ${measurement_interval_doubled}
    Set Test Variable  ${measurement_interval_doubled_min}

    Check feature CB006831 test precondition  Master

    Run Keyword If  ${NRBTS_CB006831_precondition}  Run Keywords
    ...  Log  Wait for ${measurement_interval_doubled} minutes for disable feature CB006831 reactivity on NR BTS   console=True
    ...  AND  Sleep  ${measurement_interval_doubled_min}

Step ${index}: ${Action} feature CB006831 on NR BTS
    [Documentation]
    ...  Enable or disable feature CB006831 on BTS

    Log  Step ${index}: ${Action} feature CB006831 on NR BTS  console=True
    Run Keyword If  '${Action}' == 'Enable'  Run Keywords
    ...  Enable feature CB006831  Master
    ...  AND  Log  Wait for ${measurement_interval_doubled} minutes for enable feature CB006831 reactivity on NR BTS   console=True
    ...  AND  Sleep  ${measurement_interval_doubled_min}
    ...  ELSE IF  '${Action}' == 'Disable'  Run Keywords
    ...  Disable feature CB006831  Master
    ...  AND  Log  Wait for ${measurement_interval_doubled} minutes for disable feature CB006831 reactivity on NR BTS   console=True
    ...  AND  Sleep  ${measurement_interval_doubled_min}

Step ${index}: Check counters info on NR BTS with feature CB006831 ${status}
    [Documentation]
    ...  Check counters info on NR BTS with feature CB006831 enabled or disabled

    Log  Step ${index}: Check counters info on NR BTS with feature CB006831 ${status}  console=True
    Check counters info for feature CB006831  Master

Step ${index}: Check ${when} number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check ${when} number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check feature CB006831 test precondition
    [Arguments]  ${alias}
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  NRBTS
    Log  Check feature CB006831 status on ${BTS}:  console=True
    ${actPowerMeter}  ${mtBtsEnergyMonitoring}  ${mtSBTSRfmEnergyMonitoring}  ${mtSBTSSmEnergyMonitoring}=  Get feature CB006831 info  ${alias}
    Set Test Variable  ${actPowerMeter_initial_${alias}}  ${actPowerMeter}
    Set Test Variable  ${mtBtsEnergyMonitoring_initial_${alias}}  ${mtBtsEnergyMonitoring}
    Set Test Variable  ${mtSBTSRfmEnergyMonitoring_initial_${alias}}  ${mtSBTSRfmEnergyMonitoring}
    Set Test Variable  ${mtSBTSSmEnergyMonitoring_initial_${alias}}  ${mtSBTSSmEnergyMonitoring}
    Log  Test precondition: feature CB006831 should be disabled on ${BTS} (actPowerMeter = false)  console=True
    Run Keyword If  '${actPowerMeter}' == 'false'
    ...  Log  Parameter actPowerMeter = false already set, no action needed!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Need to set parameter actPowerMeter = false  console=True
    ...  AND  Admin Perform BTS SCF Parameter Recommissioning  BTS_scf_class=FEATCADM  BTS_scf_param_name=actPowerMeter  BTS_scf_param_value=false
    ...  BTS_scf_operation=update  alias=${alias}
    ...  AND  Set Test Variable  ${${BTS}_CB006831_precondition}  True

Enable feature CB006831
    [Arguments]  ${alias}
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  NRBTS
    Log  Enable feature CB006831 status on ${BTS} with required parameters:  console=True
    Log  - actPowerMeter = true  console=True
    Log  - mtBtsEnergyMonitoring = ${measurement_interval_min}  console=True
    Log  - mtSBTSRfmEnergyMonitoring = ${measurement_interval_min}  console=True
    Log  - mtSBTSSmEnergyMonitoring = ${measurement_interval_min}  console=True

    Log  Need to set parameter actPowerMeter = true  console=True
    Admin Perform BTS SCF Parameter Recommissioning  BTS_scf_class=FEATCADM  BTS_scf_param_name=actPowerMeter  BTS_scf_param_value=true
    ...  BTS_scf_operation=update  alias=${alias}

    Run Keyword If  '${mtBtsEnergyMonitoring_initial_${alias}}' == '${measurement_interval_min}'
    ...  Log  Parameter mtBtsEnergyMonitoring = ${measurement_interval_min} already set, no action needed!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Need to set parameter mtBtsEnergyMonitoring = ${measurement_interval_min}  console=True
    ...  AND  Admin Perform BTS SCF Parameter Recommissioning  BTS_scf_class=PMMNL  BTS_scf_param_name=mtBtsEnergyMonitoring
    ...  BTS_scf_param_value=${measurement_interval_min}  BTS_scf_operation=update  alias=${alias}

    Run Keyword If  '${mtSBTSRfmEnergyMonitoring_initial_${alias}}' == '${measurement_interval_min}'
    ...  Log  Parameter mtSBTSRfmEnergyMonitoring = ${measurement_interval_min} already set, no action needed!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Need to set parameter mtSBTSRfmEnergyMonitoring = ${measurement_interval_min}  console=True
    ...  AND  Admin Perform BTS SCF Parameter Recommissioning  BTS_scf_class=PMMNL  BTS_scf_param_name=mtSBTSRfmEnergyMonitoring
    ...  BTS_scf_param_value=${measurement_interval_min}  BTS_scf_operation=update  alias=${alias}

    Run Keyword If  '${mtSBTSSmEnergyMonitoring_initial_${alias}}' == '${measurement_interval}'
    ...  Log  Parameter mtSBTSSmEnergyMonitoring = ${measurement_interval_min} already set, no action needed!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Need to set parameter mtSBTSSmEnergyMonitoring = ${measurement_interval_min}  console=True
    ...  AND  Admin Perform BTS SCF Parameter Recommissioning  BTS_scf_class=PMMNL  BTS_scf_param_name=mtSBTSSmEnergyMonitoring
    ...  BTS_scf_param_value=${measurement_interval_min}  BTS_scf_operation=update  alias=${alias}

    ${time_enable}=  Get Time
    Log  Enable feature CB006831 status on ${BTS} completed at: ${time_enable}  console=True

Disable feature CB006831
    [Arguments]  ${alias}
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  NRBTS
    Log  Disable feature CB006831 status on ${BTS} with required parameters:  console=True
    Log  - actPowerMeter = false  console=True

    Log  Need to set parameter actPowerMeter = false  console=True
    Admin Perform BTS SCF Parameter Recommissioning  BTS_scf_class=FEATCADM  BTS_scf_param_name=actPowerMeter  BTS_scf_param_value=false
    ...  BTS_scf_operation=update  alias=${alias}

    ${time_disable}=  Get Time
    Log  Disable feature CB006831 status on ${BTS} completed at: ${time_disable}  console=True

Check counters info for feature CB006831
    [Arguments]  ${alias}
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  NRBTS
    Log  Check counters info for feature CB006831 on ${BTS}:  console=True
    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${time}=  Set Variable  ${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}
    ${SBTS_Energy_Consumption_counter_path_file}=  Set Variable  ${BTS Files}/${alias}/SBTS_Energy_Consumption_counter_file_${time}.txt
    ${SBTS_RFM_Energy_Monitoring_counter_path_file}=  Set Variable  ${BTS Files}/${alias}/SBTS_RFM_Energy_Monitoring_counter_file_${time}.txt
    ${SBTS_SM_Energy_Monitoring_counter_path_file}=  Set Variable  ${BTS Files}/${alias}/SBTS_SM_Energy_Monitoring_counter_file_${time}.txt
    ${newest_timeStamp}=  Create List
    Set Test Variable  ${newest_timeStamp}

    ${time_collect}=  Get Time
    Log  Collect info related to SBTS Energy Consumption Counters M40002Cx time: ${time_collect}  console=True
    Export SBTS Energy Consumption Counters M40002Cx  counter_path_file=${SBTS_Energy_Consumption_counter_path_file}
    ...  counter_ids=${SBTS_Energy_Consumption_Counter_Ids}  alias=${alias}
    Log Long String  Info related to SBTS Energy Consumption Counters M40002Cx are available on
    ...  ${BTS Files}/${alias}/SBTS_Energy_Consumption_counter_file_${time}.txt file  console=True

    ${time_collect}=  Get Time
    Log  Collect info related to SBTS RFM Energy Monitoring Counters M40003Cx time: ${time_collect}  console=True
    Export SBTS RFM Energy Monitoring Counters M40003Cx  counter_path_file=${SBTS_RFM_Energy_Monitoring_counter_path_file}
    ...  counter_ids=${SBTS_RFM_Energy_Monitoring_Counter_Ids}  alias=${alias}
    Log Long String  Info related to SBTS RFM Energy Monitoring Counters M40003Cx are available on
    ...  ${BTS Files}/${alias}/SBTS_RFM_Energy_Monitoring_counter_file_${time}.txt file  console=True

    ${time_collect}=  Get Time
    Log  Collect info related to SBTS SM Energy Monitoring Counters M40004Cx time: ${time_collect}  console=True
    Export SBTS SM Energy Monitoring Counters M40004Cx  counter_path_file=${SBTS_SM_Energy_Monitoring_counter_path_file}
    ...  counter_ids=${SBTS_SM_Energy_Monitoring_Counter_Ids}  alias=${alias}
    Log Long String  Info related to SBTS SM Energy Monitoring Counters M40004Cx are available on
    ...  ${BTS Files}/${alias}/SBTS_SM_Energy_Monitoring_counter_file_${time}.txt  console=True

    ${newest_timeStamp}=  Remove Duplicates  ${newest_timeStamp}
    Log  \n=================================================  console=True
    Log  ${BTS} newest timestamp for all collected counters: ${newest_timeStamp}  console=True
    Log  =================================================\n  console=True

Recover BTS initial configuration
    [Arguments]  ${alias}
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  NRBTS
    Log  Recover initial settings for feature CB006831 on ${BTS}:  console=True
    Log  - actPowerMeter = ${actPowerMeter_initial_${alias}}  console=True
    Log  - mtBtsEnergyMonitoring = ${mtBtsEnergyMonitoring_initial_${alias}}  console=True
    Log  - mtSBTSRfmEnergyMonitoring = ${mtSBTSRfmEnergyMonitoring_initial_${alias}}  console=True
    Log  - mtSBTSSmEnergyMonitoring = ${mtSBTSSmEnergyMonitoring_initial_${alias}}  console=True

    ${actPowerMeter}  ${mtBtsEnergyMonitoring}  ${mtSBTSRfmEnergyMonitoring}  ${mtSBTSSmEnergyMonitoring}=  Get feature CB006831 info  ${alias}

    ${condition_actPowerMeter}=  Create Long String  '${actPowerMeter}' != '${actPowerMeter_initial_${alias}}'
    ...  and '${actPowerMeter_initial_${alias}}' != '${None}'
    ${condition_actPowerMeter_None}=  Create Long String  '${actPowerMeter}' != '${actPowerMeter_initial_${alias}}'
    ...  and '${actPowerMeter_initial_${alias}}' == '${None}'
    Run Keyword If  ${condition_actPowerMeter}
    ...  Admin Perform BTS SCF Parameter Recommissioning  BTS_scf_class=FEATCADM  BTS_scf_param_name=actPowerMeter
    ...  BTS_scf_param_value=${actPowerMeter_initial_${alias}}  BTS_scf_operation=update  alias=${alias}
    ...  ELSE IF  ${condition_actPowerMeter_None}
    ...  Admin Perform BTS SCF Parameter Recommissioning  BTS_scf_class=FEATCADM  BTS_scf_param_name=actPowerMeter
    ...  BTS_scf_param_value=${actPowerMeter}  BTS_scf_operation=delete  alias=${alias}

    ${condition_mtBtsEnergyMonitoring}=  Create Long String  '${mtBtsEnergyMonitoring}' != '${mtBtsEnergyMonitoring_initial_${alias}}'
    ...  and '${mtBtsEnergyMonitoring_initial_${alias}}' != '${None}'
    ${condition_mtBtsEnergyMonitoring_None}=  Create Long String  '${mtBtsEnergyMonitoring}' != '${mtBtsEnergyMonitoring_initial_${alias}}'
    ...  and '${mtBtsEnergyMonitoring_initial_${alias}}' == '${None}'
    Run Keyword If  ${condition_mtBtsEnergyMonitoring}
    ...  Admin Perform BTS SCF Parameter Recommissioning  BTS_scf_class=PMMNL  BTS_scf_param_name=mtBtsEnergyMonitoring
    ...  BTS_scf_param_value=${mtBtsEnergyMonitoring_initial_${alias}}  BTS_scf_operation=update  alias=${alias}
    ...  ELSE IF  ${condition_mtBtsEnergyMonitoring_None}
    ...  Admin Perform BTS SCF Parameter Recommissioning  BTS_scf_class=PMMNL  BTS_scf_param_name=mtBtsEnergyMonitoring
    ...  BTS_scf_param_value=${mtBtsEnergyMonitoring}  BTS_scf_operation=delete  alias=${alias}

    ${condition_mtSBTSRfmEnergyMonitoring}=  Create Long String  '${mtSBTSRfmEnergyMonitoring}' != '${mtSBTSRfmEnergyMonitoring_initial_${alias}}'
    ...  and '${mtSBTSRfmEnergyMonitoring_initial_${alias}}' != '${None}'
    ${condition_mtSBTSRfmEnergyMonitoring_None}=  Create Long String
    ...  '${mtSBTSRfmEnergyMonitoring}' != '${mtSBTSRfmEnergyMonitoring_initial_${alias}}'
    ...  and '${mtSBTSRfmEnergyMonitoring_initial_${alias}}' == '${None}'
    Run Keyword If  ${condition_mtSBTSRfmEnergyMonitoring}
    ...  Admin Perform BTS SCF Parameter Recommissioning  BTS_scf_class=PMMNL  BTS_scf_param_name=mtSBTSRfmEnergyMonitoring
    ...  BTS_scf_param_value=${mtSBTSRfmEnergyMonitoring_initial_${alias}}  BTS_scf_operation=update  alias=${alias}
    ...  ELSE IF  ${condition_mtSBTSRfmEnergyMonitoring_None}
    ...  Admin Perform BTS SCF Parameter Recommissioning  BTS_scf_class=PMMNL  BTS_scf_param_name=mtSBTSRfmEnergyMonitoring
    ...  BTS_scf_param_value=${mtSBTSRfmEnergyMonitoring}  BTS_scf_operation=delete  alias=${alias}

    ${condition_mtSBTSSmEnergyMonitoring}=  Create Long String  '${mtSBTSSmEnergyMonitoring}' != '${mtSBTSSmEnergyMonitoring_initial_${alias}}'
    ...  and '${mtSBTSSmEnergyMonitoring_initial_${alias}}' != '${None}'
    ${condition_mtSBTSSmEnergyMonitoring_None}=  Create Long String  '${mtSBTSSmEnergyMonitoring}' != '${mtSBTSSmEnergyMonitoring_initial_${alias}}'
    ...  and '${mtSBTSSmEnergyMonitoring_initial_${alias}}' == '${None}'
    Run Keyword If  ${condition_mtSBTSSmEnergyMonitoring}
    ...  Admin Perform BTS SCF Parameter Recommissioning  BTS_scf_class=PMMNL  BTS_scf_param_name=mtSBTSSmEnergyMonitoring
    ...  BTS_scf_param_value=${mtSBTSSmEnergyMonitoring_initial_${alias}}  BTS_scf_operation=update  alias=${alias}
    ...  ELSE IF  ${condition_mtSBTSSmEnergyMonitoring}
    ...  Admin Perform BTS SCF Parameter Recommissioning  BTS_scf_class=PMMNL  BTS_scf_param_name=mtSBTSSmEnergyMonitoring
    ...  BTS_scf_param_value=${mtSBTSSmEnergyMonitoring}  BTS_scf_operation=delete  alias=${alias}

Particular Teardown
    Recover BTS initial configuration  Master

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown


