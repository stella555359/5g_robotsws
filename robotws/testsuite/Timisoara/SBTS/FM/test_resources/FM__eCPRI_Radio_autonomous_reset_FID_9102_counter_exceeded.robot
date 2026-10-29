*** Settings ***
Documentation
    ...  In the beginning, TC performs site reset to clear the counters.
    ...  After it, TC checks if fault 9102 and fault 2087 are triggered as expected in 2 scenarios with actForceUnitAutoReset
    ...  set at True.
    ...  In the *first scenario*, rdTrafficStuckCountLimit and rdTrafficStuckCountingPeriod parameters are changed to
    ...  7 and 60 respectively. It means that fault 9102 can be triggered 7 times within 60 minutes.
    ...  According to FM counter, fault 9102 with Radio autonomous reset can be generated 6 times on m-plane
    ...  cablink (configuration) and the 7th time fault 1902 will be raised as Critical and autonomous reset
    ...  will not be performed.
    ...  For triggering 9102, one eCPRI cablink is chosen from ABIO, ABIN or ASOE based on MODULE_TYPE variable.
    ...  Then, TC opens ssh connection to cablink SoC and sends the following command:
    ...  - confmgmtbrowser write FrontHaul rdCgxFifoFullOperations <OPERATION_ID>, where OPERATION_ID is specific for
    ...  RF port of the cablink chosen.
    ...  9102 generates RFOE (a group of RF ports, each Loki SoC has 2 RFOE groups) autonomous reset if RFOE has
    ...  configuration cablink. For now in our SBTS configurations on each RFOE is mapped only one RMOD and TC is searching
    ...  for cablinks for one RMOD.
    ...  Then, if RMOD has cablink configuration on RFOE, 9102 will be raised as Warning and RMOD reset is performed.
    ...  If RMOD has other cablink on RFOE, then 9102 will be raised as Critical on this cablink.
    ...  After 9102 generation, RMOD reset is performed or not, depending on configuration cablink and even if RMOD is not
    ...  resetting, cells on RMOD will be down for a couple of seconds.
    ...  When 9102 is triggered 7th time this fault will be Critical on configuration cablink and RMOD and its cells will be
    ...  down. TC performs site reset to clear fault 9102.
    ...  After site reset, rdTrafficStuckCountLimit and rdTrafficStuckCountingPeriod parameters will have default values,
    ...  1 and 30 respectively. This is the *second scenario* where 9102 is triggered 2 times within 30 seconds.
    ...  First time, 9102 is raised on cablinks from RFOE. Second time, 2087 will be raised and SoC autonomous reset is performed.
    ...  In the end, site reset is performed and all counters are cleared.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${MODULE_TYPE}  ${EMPTY}  # Mandatory, can be ABIO, ABIN or ASOE
${STARTUP_TIMEOUT}  600  # time for SBTS to recover after Site reset
${RECOVERY_TIMEOUT}  600  # time for cells on RMOD to recover after RF reset
${9102_TIMEOUT}  60  # time for fault 9102 to be visible in WebEM and NetAct
${2087_TIMEOUT}  180  # time for fault 2087 to be visible in WebEM and NetAct


*** Keywords ***
TC__FM__eCPRI_Radio_autonomous_reset_FID_9102_counter_exceeded
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26052
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 31.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26052 - Initial TAT creation
    ...  - 17.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26450 - Replace alarmingResource with notifier parameter
    ...                                                           for checking active alarms
    ...  - 21.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26455 - Check cleared alarms instead of active alarms in NetAct
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26610 - Add verification for unacked cleared alarms in NetAct
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  ******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  CNI-81705

    Step0: TC Variables And Preconditions
    Step1: Perform Site Reset To Clear All Counters
    Step2: Change Rad Debug Parameters
    Step3: Trigger Fault 9102 And Check SBTS Status
    Step4: Trigger Fault 9102 And Check SBTS Status
    Step5: Trigger Fault 9102 And Check SBTS Status
    Step6: Trigger Fault 9102 And Check SBTS Status
    Step7: Trigger Fault 9102 And Check SBTS Status
    Step8: Trigger Fault 9102 And Check SBTS Status
    Step9: Trigger Fault 9102 For The 7th Time
    Step10: Perform Site Reset To Clear All Counters
    Step11: Trigger Fault 9102 And Check SBTS Status
    Step12: Trigger Fault 2087 And Check SBTS Status


Step0: TC Variables And Preconditions
    ${all_rmods}  Get Parameters For All  RMOD
    ${modules_ids}  Run Keyword If  '${MODULE_TYPE}'=='ABIO' or '${MODULE_TYPE}'=='ABIN'
    ...  Get Existing Runtime Ids For MODULE TYPE  BBMOD  ${MODULE_TYPE}
    ...  ELSE IF  '${MODULE_TYPE}'=='ASOE'
    ...  Get Existing Runtime Ids For MODULE TYPE  SMOD  ${MODULE_TYPE}
    ...  ELSE
    ...  Fail  Please provide a proper MODULE_TYPE (ABIO, ABIN, ASOE).
    ${ecpri_cablinks}  Create List
    FOR  ${module_id}  IN  @{modules_ids}
        ${module_cablinks}  Get Cablinks With Ecpri Rmods  ${module_id}
        Append To List  ${ecpri_cablinks}  @{module_cablinks}
    END
    Should Not Be Empty  ${ecpri_cablinks}  SBTS does not have eCPRI cablinks for ${MODULE_TYPE}.

    ${bts_name}  Get Bts Name
    Set Test Variable  ${BTS_NAME}

    ${random_ecpri_cablink}  Evaluate  random.choice(${ecpri_cablinks})  random
    ${module_parameters}  coam.Get Parameters  ${random_ecpri_cablink}[first_end_point_id]
    ${first_end_point_type}  Get Regexp Matches  ${random_ecpri_cablink}[first_end_point_id]  B?[BS]MOD
    ${module_l_dn}  Get Module L Dist Name  ${module_parameters}[serialNumber]  ${first_end_point_type}[0]
    ${module_vertical_position}  Get Module Vertical Position  ${random_ecpri_cablink}[first_end_point_id]
    ${loki_position}  Get Loki Position Based On First End Point Port  ${random_ecpri_cablink}[first_end_point_port]
    ${operation_id}  Get Operation Id To Trigger RFOE Reset  ${MODULE_TYPE}  ${random_ecpri_cablink}[first_end_point_port]
    ${cablinks_on_rfoe_ids_severity_dict}  Get Cablinks Id And Severity For RFOE  ${ecpri_cablinks}  ${random_ecpri_cablink}
    ${rmod_is_resetting}  Check If RMOD Is Resetting  ${cablinks_on_rfoe_ids_severity_dict}
    ${cells_on_rmod}  Get Cell Mapping By Module Id  ${random_ecpri_cablink}[second_end_point_id]
    ${cells_on_other_rmods}  Get All Cells On Bts
    Remove Values From List  ${cells_on_other_rmods}  @{cells_on_rmod}

    Set Test Variable  ${RMOD_R_DN}  ${random_ecpri_cablink}[second_end_point_id]
    Set Test Variable  ${MODULE_R_DN}  ${random_ecpri_cablink}[first_end_point_id]
    Set Test Variable  ${MODULE_L_DN}
    Set Test Variable  ${MODULE_VERTICAL_POSITION}
    Set Test Variable  ${LOKI_POSITION}
    Set Test Variable  ${OPERATION_ID}
    Set Test Variable  ${CABLINKS_ON_RFOE_IDS_SEVERITY_DICT}
    Set Test Variable  ${RMOD_IS_RESETTING}
    Set Test Variable  ${CELLS_ON_RMOD}
    Set Test Variable  ${CELLS_ON_OTHER_RMODS}

    Log  Cablink chosen: ${random_ecpri_cablink}.  console=true
    Log  Cablinks on RFOE: ${CABLINKS_ON_RFOE_IDS_SEVERITY_DICT}.  console=true
    Change Parameter ActForce(Unit)AutoReset  true  actForceUnitAutoReset


Step${index}: Perform Site Reset To Clear All Counters
    Log  \nStep${index}: Perform site reset to clear all counters  console=true
    Perform Site Reset


Step2: Change Rad Debug Parameters
    Log  \nStep2: Change rad debug parameters  console=true
    Set Rad Debug Parameters  domain=FrontHaul  persistency=NotPersistent  name=rdTrafficStuckCountLimit  value=7
    Log  rdTrafficStuckCountLimit is changed to 7.  console=true
    Set Rad Debug Parameters  domain=FrontHaul  persistency=NotPersistent  name=rdTrafficStuckCountingPeriod  value=60
    Log  rdTrafficStuckCountingPeriod is changed to 60.  console=true


Step${index}: Trigger Fault 9102 And Check SBTS Status
    Log  \nStep${index}: Trigger fault 9102 and check SBTS status  console=true
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    Open Connection To Primary Core
    ${smod_stored_role}  Get StoredRole From MODULE_L  ${MODULE_L_DN}
    Run Keyword If  '${smod_stored_role}'=='Idle'
    ...  Open Connection To Secondary Core
    Log  Open connection to Loki ${LOKI_POSITION}.  console=true
    Open Connection To SoC  ${MODULE_VERTICAL_POSITION}  ${LOKI_POSITION}
    SSHLibrary.Write  confmgmtbrowser write FrontHaul rdCgxFifoFullOperations ${OPERATION_ID}
    Log  confmgmtbrowser write command with operation id ${OPERATION_ID} was sent on Loki SoC.  console=true

    ${fid_9102_warning_params}  Get String With Alarm Parameters  ${FAULT_9102_RADIO_AUTO_RST}
    ${fid_9102_critical_params}  Get String With Alarm Parameters  ${FAULT_9102_RFOE_REC_EVENT_CRITICAL}

    FOR  ${cablink_id}  IN  @{CABLINKS_ON_RFOE_IDS_SEVERITY_DICT}
        ${fid_9102_warning_params}  Catenate  ${fid_9102_warning_params},  notifier=[${BTS_NAME}] ${cablink_id}
        ${fid_9102_critical_params}  Catenate  ${fid_9102_critical_params},  notifier=[${BTS_NAME}] ${cablink_id}
        ${9102_parameters}  Run Keyword If  '${CABLINKS_ON_RFOE_IDS_SEVERITY_DICT}[${cablink_id}]'=='Warning'
        ...  Assert Alarm Active  parameters=faultId=${fid_9102_warning_params}  timeout=${9102_TIMEOUT}
        ...  ELSE
        ...  Assert Alarm Active  parameters=${fid_9102_critical_params}  timeout=${9102_TIMEOUT}
        Log  Fault 9102 is active in WebEM on ${cablink_id}.  console=true
    END

    Run Keyword If  ${RMOD_IS_RESETTING}
    ...  Assert  RMOD  ${RMOD_R_DN}  availabilityStatus=${OFFLINE}, operationalState=${DISABLED}  timeout=60
    ...  ELSE
    ...  Assert  RMOD  ${RMOD_R_DN}  operationalState=${ENABLED}
    Check Parameters Status For Cells  ${CELLS_ON_RMOD}  availabilityStatus=${FAILED}, operationalState=${DISABLED}
    Log  Cells on ${RMOD_R_DN} are disabled.  console=true
    Check Parameters Status For Cells  ${CELLS_ON_OTHER_RMODS}  operationalState=${ENABLED}

    FOR  ${cablink_id}  IN  @{CABLINKS_ON_RFOE_IDS_SEVERITY_DICT}
        Run Keyword If  '${CABLINKS_ON_RFOE_IDS_SEVERITY_DICT}[${cablink_id}]'=='Warning'
        ...  Wait Until Keyword Succeeds  ${9102_TIMEOUT}  10
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_9102_WARNING}  time_from=${time_from}
        ...  object_id=${cablink_id}  additional_fault_id=${FAULT_9102_WARNING}[fault_id]
        ...  suppl_info=RFOE recovery successfully performed.+
        ...  ELSE
        ...  Wait Until Keyword Succeeds  ${9102_TIMEOUT}  10
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_9102_CRITICAL}  time_from=${time_from}
        ...  object_id=${cablink_id}  additional_fault_id=${FAULT_9102_CRITICAL}[fault_id]
        Log  Fault 9102 is cleared in NetAct on ${cablink_id}.  console=true
    END

    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  15
    ...  Check Parameters Status For Cells  ${CELLS_ON_RMOD}  operationalState=${ENABLED}
    Log  Cells on ${RMOD_R_DN} are enabled.  console=true

    SSHLibrary.Close All Connections


Step9: Trigger Fault 9102 For The 7th Time
    Log  \nStep9: Trigger fault 9102 for the 7th time  console=true
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    Open Connection To Primary Core
    ${smod_stored_role}  Get StoredRole From MODULE_L  ${MODULE_L_DN}
    Run Keyword If  '${smod_stored_role}'=='Idle'
    ...  Open Connection To Secondary Core
    Log  Open connection to Loki ${LOKI_POSITION}.  console=true
    Open Connection To SoC  ${MODULE_VERTICAL_POSITION}  ${LOKI_POSITION}
    SSHLibrary.Write  confmgmtbrowser write FrontHaul rdCgxFifoFullOperations ${OPERATION_ID}
    Log  confmgmtbrowser write command with operation id ${OPERATION_ID} was sent on Loki SoC.  console=true

    ${fid_9102_critical_params}  Get String With Alarm Parameters  ${FAULT_9102_RFOE_REC_EVENT_CRITICAL}
    FOR  ${cablink_id}  IN  @{CABLINKS_ON_RFOE_IDS_SEVERITY_DICT}
        ${fid_9102_critical_params}  Catenate  ${fid_9102_critical_params},  notifier=[${BTS_NAME}] ${cablink_id}
        Assert Alarm Active  parameters=${fid_9102_critical_params}  timeout=${9102_TIMEOUT}
        Log  Fault 9102 is active in WebEM on ${cablink_id}.  console=true
    END

    FOR  ${cablink_id}  IN  @{CABLINKS_ON_RFOE_IDS_SEVERITY_DICT}
        Run Keyword If  '${CABLINKS_ON_RFOE_IDS_SEVERITY_DICT}[${cablink_id}]'=='Warning'
        ...  Wait Until Keyword Succeeds  ${9102_TIMEOUT}  5
        ...  Check Additional Information For Given Alarm And Fault  &{FAULT_9102_CRITICAL}  object_id=${cablink_id}
        ...  additional_fault_id=${FAULT_9102_CRITICAL}[fault_id]
        ...  ELSE
        ...  Wait Until Keyword Succeeds  ${9102_TIMEOUT}  10
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_9102_CRITICAL}  time_from=${time_from}
        ...  object_id=${cablink_id}  additional_fault_id=${FAULT_9102_CRITICAL}[fault_id]
        Log  Fault 9102 is visible in NetAct on ${cablink_id}.  console=true
    END

    Check Parameters Status For Cells  ${CELLS_ON_RMOD}  availabilityStatus=${FAILED}, operationalState=${DISABLED}
    Check Parameters Status For Cells  ${CELLS_ON_OTHER_RMODS}  operationalState=${ENABLED}
    Log  Cells on ${RMOD_R_DN} are disabled.  console=true

    SSHLibrary.Close All Connections


Step12: Trigger Fault 2087 And Check SBTS Status
    Log  \nStep12: Trigger fault 2087 and check SBTS status  console=true
    ${soc_dist_name}  Set Variable If  '${LOKI_POSITION}'=='1'  ${MODULE_L_DN}/BBU_L-1/POWER_GROUP_L-1/SOC_L-2
    ...  ${MODULE_L_DN}/BBU_L-1/POWER_GROUP_L-2/SOC_L-1
    ${cells_on_soc}  Get Cells Mapped On SoC And RMODs  ${MODULE_R_DN}  Loki  ${soc_dist_name}
    ${other_cells}  Get All Cells On Bts
    Remove Values From List  ${other_cells}  @{cells_on_soc}

    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    Open Connection To Primary Core
    ${smod_stored_role}  Get StoredRole From MODULE_L  ${MODULE_L_DN}
    Run Keyword If  '${smod_stored_role}'=='Idle'
    ...  Open Connection To Secondary Core
    Log  Open connection to Loki ${LOKI_POSITION}.  console=true
    Open Connection To SoC  ${MODULE_VERTICAL_POSITION}  ${LOKI_POSITION}
    SSHLibrary.Write  confmgmtbrowser write FrontHaul rdCgxFifoFullOperations ${OPERATION_ID}
    Log  confmgmtbrowser write command with operation id ${OPERATION_ID} was sent on Loki SoC.  console=true

    Check Parameters Status For Cells  ${cells_on_soc}  availabilityStatus=${FAILED}, operationalState=${DISABLED}
    Log  Cells on ${soc_dist_name} are disabled.  console=true
    Check Parameters Status For Cells  ${other_cells}  operationalState=${ENABLED}

    ${module_id}  Replace String Using Regexp  ${MODULE_R_DN}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    ${fid_2087_params}  Get String With Alarm Parameters  ${FAULT_2087_SOC_AUTO_RST}
    ${fid_2087_params}  Catenate  ${fid_2087_params},  notifier=[${BTS_NAME}] ${module_id}
    Assert Alarm Active  parameters=${fid_2087_params}  timeout=${2087_TIMEOUT}
    Log  Fault ${FAULT_2087_SOC_AUTO_RST}[fault_id] "${FAULT_2087_SOC_AUTO_RST}[fault_name]" is active in WebEM.  console=true

    Wait Until Keyword Succeeds  ${2087_TIMEOUT}  15
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2087_SOC_AUTO_RST}  time_from=${time_from}
    ...  object_id=${module_id}  additional_fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  suppl_info=[A-Za-z]+ SoC_[A-Za-z] autonomous reset
    Log  Fault ${FAULT_2087_SOC_AUTO_RST}[fault_id] "${FAULT_2087_SOC_AUTO_RST}[fault_name]" is cleared in NetAct.  console=true

    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  15
    ...  Check Parameters Status For Cells  ${cells_on_soc}  operationalState=${ENABLED}
    SSHLibrary.Close All Connections


Get Existing Runtime Ids For MODULE TYPE
    [Arguments]  ${module_class}  ${module_type}

    ${all_modules}  Get Parameters For All  ${module_class}
    ${needed_modules_ids}  Create List
    FOR  ${module}  IN  @{all_modules}
        Run Keyword If  '${module_type}' in '${module}[productName]'
        ...  Append To List  ${needed_modules_ids}  ${module}[id]
    END

    [Return]  ${needed_modules_ids}


Get Cablinks With Ecpri Rmods
    [Arguments]  ${module_id}

    ${cablink_list}  Create List
    ${module_cablinks}  Query Infomodel  get list //CABLINK_R-* is [firstEndpointDN=${module_id}]  allow_negative_result=true
    ${length}  Get Length  ${module_cablinks}
    Run Keyword If  ${length}==0
    ...  Return From Keyword  ${module_cablinks}
    FOR  ${cablink}  IN  @{module_cablinks}
        ${rmod_parameters}  coam.Get Parameters  ${cablink}[secondEndpointDN]
        ${cablink_dict}  Create Dictionary
        Run Keyword If  '${rmod_parameters}[l3Protocol]'=='ECPRI_MPLANE'
        ...  Run Keywords
        ...  Set To Dictionary  ${cablink_dict}
        ...  cablink_id=${cablink}[dist_name]
        ...  first_end_point_id=${cablink}[firstEndpointDN]
        ...  first_end_point_port=${cablink}[firstEndpointPortId]
        ...  second_end_point_id=${cablink}[secondEndpointDN]
        ...  link_mode_configuration=${cablink}[linkModeConfiguration]
        ...  AND
        ...  Append To List  ${cablink_list}  ${cablink_dict}
    END

    [Return]  ${cablink_list}


Get Loki Position Based On First End Point Port
    [Arguments]  ${module_port}

    Run Keyword If  'ABIN' in '${MODULE_TYPE}'
    ...  Return From Keyword  1
    Run Keyword If  ${module_port}<=6
    ...  Return From Keyword  1

    [Return]  2


Get Operation Id To Trigger RFOE Reset
    [Documentation]  Each RF port has a specific operation id for triggering fault 9102. The dictionary keys
    ...  are the ids for RF ports.
    [Arguments]  ${module_type_given}  ${module_port}

    ${abio_dict}  Create Dictionary  ${1}=3  ${2}=5  ${3}=9  ${4}=17  ${5}=33  ${6}=65  ${7}=3  ${8}=9  ${9}=33
    ${abin_dict}  Create Dictionary  ${1}=3  ${2}=5  ${3}=9  ${4}=17  ${5}=33  ${6}=65  ${7}=129  ${8}=257  ${9}=513
    ${asoe_dict}  Create Dictionary  ${1}=3  ${2}=5  ${3}=9  ${4}=17  ${5}=33  ${6}=65  ${7}=3  ${8}=5  ${9}=9  ${10}=17  ${11}=33  ${12}=65

    [Return]  ${${module_type_given}_DICT}[${module_port}]


Get Cablinks Id And Severity For RFOE
    [Documentation]  This KW returns one dictionary with cablink runtime dist name as key and the severity of
    ...  fault 9102 as value. In case of m-plane (configuration) ecpri cablink, severity is Warning. Otherwise,
    ...  severity is Critical. KW is searching for cablinks from RMOD with random cablink chosen.
    [Arguments]  ${ecpri_cablinks}  ${random_ecpri_cablink}

    ${cablinks_id_severity_dict}  Create Dictionary
    FOR  ${ecpri_cablink}  IN  @{ecpri_cablinks}
        ${first_end_point_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${ecpri_cablink}[first_end_point_id]  ${random_ecpri_cablink}[first_end_point_id]
        ${second_end_point_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${ecpri_cablink}[second_end_point_id]  ${random_ecpri_cablink}[second_end_point_id]
        Continue For Loop If  not ${first_end_point_status} or not ${second_end_point_status}
        ${available_ports_on_rfoe}  Get Ports Of RFOE With Chosen Cablink  ${random_ecpri_cablink}[first_end_point_port]
        ${severity}  Set Variable If  'True' in '${ecpri_cablink}[link_mode_configuration]'  Warning  Critical
        ${cablink_id}  Replace String Using Regexp  ${ecpri_cablink}[cablink_id]  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
        Run Keyword If  '${ecpri_cablink}[first_end_point_port]' in '${available_ports_on_rfoe}'
        ...  Set To Dictionary  ${cablinks_id_severity_dict}  ${cablink_id}=${severity}
    END

    [Return]  ${cablinks_id_severity_dict}


Get Ports Of RFOE With Chosen Cablink
    [Documentation]  KW returns the list with RFOE ports as string based on port_id which is
    ...  the port of the chosen cablink.
    [Arguments]  ${port_id}

    ${rfoe_ports}  Create Dictionary  loki_a_rfoe_0=[1,2,3,4]  loki_a_rfoe_1=[5,6]  loki_b_rfoe_0=[7,8]  loki_b_rfoe_1=[9,11,12]
    FOR  ${rfoe}  IN  @{rfoe_ports}
        Run Keyword If  '${port_id}' in '${rfoe_ports}[${rfoe}]'
        ...  Return From Keyword  ${rfoe_ports}[${rfoe}]
    END


Check If RMOD Is Resetting
    [Documentation]  RMOD is resetting only if it has m-plane (configuration) ecpri cablink connected to
    ...  affected RFOE.
    [Arguments]  ${cablinks_id_severity_dict}

    FOR  ${cablink_id}  IN  @{cablinks_id_severity_dict}
        Run Keyword If  '${cablinks_id_severity_dict}[${cablink_id}]'=='Warning'
        ...  Return From Keyword  ${TRUE}
    END

    [Return]  ${FALSE}


TC Setup
    Common Test Setup  tc_name=FM__eCPRI_Radio_autonomous_reset_FID_9102_sent_9_times
    Setup Netact


TC Teardown
    Change Parameter ActForce(Unit)AutoReset  false  actForceUnitAutoReset
    Teardown Netact
    Common Test Teardown
