*** Settings ***
Documentation
    ...  In the beginning, TC performs site reset to clear the counters.
    ...  Fault 9102 'RFOE MHAB recovery event' is triggered 2 times.
    ...  One eCPRI cablink is chosen from ABIO, ABIN, ASOE or ASOF based on MODULE_TYPE variable.
    ...  TC opens ssh connection to SoC with chosen cablink mapped on it and sends the following command:
    ...  - confmgmtbrowser write FrontHaul rdCgxFifoFullOperations <OPERATION_ID>, where OPERATION_ID is specific for
    ...  RF port of the chosen cablink.
    ...  For the first time, 9102 should have Warning severity on each cablink from RFOE of the chosen cablink and no
    ...  services and cells should be affected. 9102 will disappear after 30s.
    ...  For the second time, 2087 'SoC autonomous reset as recovery action' will be raised and SoC autonomous reset is
    ...  performed.
    ...  In the end, TC waits until SBTS is reaching on air state.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${MODULE_TYPE}  ${EMPTY}  # Mandatory, can be ABIO, ABIN, ASOE or ASOF
${RECOVERY_TIMEOUT}  600  # time for cells on RMOD to recover after RF reset
${9102_TIMEOUT}  60  # time for fault 9102 to be visible in WebEM and NetAct
${2087_TIMEOUT}  180  # time for fault 2087 to be visible in WebEM and NetAct


*** Keywords ***
TC__FM__eCPRI_Radio_autonomous_reset_FID_9102_sent_twice_counter_exceeded
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26922
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 13.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26922 - Initial TAT creation
    ...  - 03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  ******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  CNI-106959

    Step0: TC Variables And Preconditions
    Step1: Perform Site Reset To Clear All Counters
    Step2: Trigger Fault 9102 And Check SBTS Status
    Step3: Trigger Fault 2087 And Check SBTS Status


Step0: TC Variables And Preconditions
    ${all_rmods}  Get Parameters For All  RMOD
    ${modules_ids}  Run Keyword If  '${MODULE_TYPE}' in ['ABIO', 'ABIN']
    ...  Get Existing Runtime Ids For MODULE TYPE  BBMOD  ${MODULE_TYPE}
    ...  ELSE IF  '${MODULE_TYPE}' in ['ASOE', 'ASOF']
    ...  Get Existing Runtime Ids For MODULE TYPE  SMOD  ${MODULE_TYPE}
    ...  ELSE
    ...  Fail  Please provide a proper MODULE_TYPE (ABIO, ABIN, ASOE, ASOF).
    ${ecpri_cablinks}  Create List
    FOR  ${module_id}  IN  @{modules_ids}
        ${module_cablinks}  Get Cablinks With Ecpri Rmods  ${module_id}
        Append To List  ${ecpri_cablinks}  @{module_cablinks}
    END
    ${length}  Get Length  ${ecpri_cablinks}
    Should Not Be Equal As Integers  ${length}  0  SBTS does not have eCPRI cablinks for ${MODULE_TYPE}.

    ${bts_name}  Get Bts Name
    Set Test Variable  ${BTS_NAME}

    ${random_ecpri_cablink}  Evaluate  random.choice(${ecpri_cablinks})  random
    ${module_parameters}  coam.Get Parameters  ${random_ecpri_cablink}[first_end_point_id]
    ${first_end_point_type}  Get Regexp Matches  ${random_ecpri_cablink}[first_end_point_id]  B?[BS]MOD
    ${module_l_dn}  Get Module L Dist Name  ${module_parameters}[serialNumber]  ${first_end_point_type}[0]
    ${module_vertical_position}  Get Module Vertical Position  ${random_ecpri_cablink}[first_end_point_id]
    ${loki_position}  Get Loki Position Based On First End Point Port  ${random_ecpri_cablink}[first_end_point_port]
    ${operation_id}  Get Operation Id To Trigger RFOE Reset  ${MODULE_TYPE}  ${random_ecpri_cablink}[first_end_point_port]
    ${cablinks_r_ids_on_rfoe}  Get Cablinks Ids For RFOE  ${ecpri_cablinks}  ${random_ecpri_cablink}

    Set Test Variable  ${RMOD_R_DN}  ${random_ecpri_cablink}[second_end_point_id]
    Set Test Variable  ${MODULE_R_DN}  ${random_ecpri_cablink}[first_end_point_id]
    Set Test Variable  ${MODULE_L_DN}
    Set Test Variable  ${MODULE_VERTICAL_POSITION}
    Set Test Variable  ${LOKI_POSITION}
    Set Test Variable  ${OPERATION_ID}
    Set Test Variable  ${CABLINKS_R_IDS_ON_RFOE}

    Log  Cablink chosen: ${random_ecpri_cablink}.  console=true
    Log  Cablinks on RFOE: ${CABLINKS_R_IDS_ON_RFOE}.  console=true
    Change Parameter ActForce(Unit)AutoReset  true  actForceUnitAutoReset


Step1: Perform Site Reset To Clear All Counters
    Log  \nStep1: Perform site reset to clear all counters  console=true
    Perform Site Reset


Step2: Trigger Fault 9102 And Check SBTS Status
    Log  \nStep2: Trigger fault 9102 and check SBTS status  console=true
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    Open Connection To Primary Core
    ${smod_stored_role}  Get StoredRole From MODULE_L  ${MODULE_L_DN}
    Run Keyword If  '${smod_stored_role}'=='Idle'
    ...  Open Connection To Secondary Core
    Log  Open connection to Loki ${LOKI_POSITION}.  console=true
    Open Connection To SoC  ${MODULE_VERTICAL_POSITION}  ${LOKI_POSITION}
    SSHLibrary.Write  confmgmtbrowser write FrontHaul rdCgxFifoFullOperations ${OPERATION_ID}
    Log  confmgmtbrowser write command with operation id ${OPERATION_ID} was sent on Loki SoC.  console=true

    ${9102_parameters}  Get String With Alarm Parameters  ${FAULT_9102_RFOE_REC_EVENT_WARNING}
    FOR  ${cablink_id}  IN  @{CABLINKS_R_IDS_ON_RFOE}
        ${9102_parameters}  Catenate  ${9102_parameters},  notifier=[${BTS_NAME}] ${cablink_id}
        Assert Alarm Active  ${9102_parameters}  timeout=${9102_TIMEOUT}
        Log  Fault 9102 on ${cablink_id} is active in WebEM.  console=true
    END
    Admin Check All Required State
    FOR  ${cablink_id}  IN  @{CABLINKS_R_IDS_ON_RFOE}
        ${9102_parameters}  Catenate  ${9102_parameters},  notifier=[${BTS_NAME}] ${cablink_id}
        Assert Alarm Inactive  ${9102_parameters}  timeout=30
        Log  Fault 9102 on ${cablink_id} is inactive in WebEM after 30s.  console=true
    END

    FOR  ${cablink_id}  IN  @{CABLINKS_R_IDS_ON_RFOE}
        Wait Until Keyword Succeeds  30  10
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_9102_RFOE_REC_EVENT_WARNING}
        ...  time_from=${time_from}  object_id=${cablink_id}  additional_fault_id=${FAULT_9102_RFOE_REC_EVENT_WARNING}[fault_id]
        ...  suppl_info=RFOE recovery successfully performed.+
        Log  Fault 9102 on ${cablink_id} is cleared in NetAct.  console=true
    END

    Admin Check All Required State
    SSHLibrary.Close All Connections


Step3: Trigger Fault 2087 And Check SBTS Status
    Log  \nStep3: Trigger fault 2087 and check SBTS status  console=true
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
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2087_SOC_AUTO_RST}
    ...  time_from=${time_from}  object_id=${module_id}  additional_fault_id=${FAULT_9102_RFOE_REC_EVENT_WARNING}[fault_id]
    ...  suppl_info=[A-Za-z]+ SoC_[A-Za-z] autonomous reset
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
        ...  AND
        ...  Append To List  ${cablink_list}  ${cablink_dict}
    END

    [Return]  ${cablink_list}


Get Loki Position Based On First End Point Port
    [Arguments]  ${module_port}

    Run Keyword If  '${MODULE_TYPE}'=='ABIN' or ${module_port}<=3
    ...  Return From Keyword  1
    Run Keyword If  '${MODULE_TYPE}'=='ASOF'
    ...  Return From Keyword  2
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
    ${asof_dict}  Create Dictionary  ${1}=33  ${2}=9  ${3}=3  ${4}=33  ${5}=9  ${6}=3

    [Return]  ${${module_type_given}_dict}[${module_port}]


Get Cablinks Ids For RFOE
    [Documentation]
    ...  This KW returns one list with runtime dist names for cablinks from RMOD with random cablink chosen.
    [Arguments]  ${ecpri_cablinks}  ${random_ecpri_cablink}

    ${cablinks_id_list}  Create List
    FOR  ${ecpri_cablink}  IN  @{ecpri_cablinks}
        ${first_end_point_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${ecpri_cablink}[first_end_point_id]  ${random_ecpri_cablink}[first_end_point_id]
        ${second_end_point_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${ecpri_cablink}[second_end_point_id]  ${random_ecpri_cablink}[second_end_point_id]
        Continue For Loop If  not ${first_end_point_status} or not ${second_end_point_status}
        ${available_ports_on_rfoe}  Get The Other Ports Of Rfoe With Chosen Cablink  ${random_ecpri_cablink}[first_end_point_port]

        ${cablink_id}  Replace String Using Regexp  ${ecpri_cablink}[cablink_id]  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
        Run Keyword If  '${ecpri_cablink}[first_end_point_port]' in '${available_ports_on_rfoe}'
        ...  Append To List  ${cablinks_id_list}  ${cablink_id}
    END

    [Return]  ${cablinks_id_list}


Get The Other Ports Of Rfoe With Chosen Cablink
    [Documentation]  KW returns the list with RFOE ports as string based on port_id which is
    ...  the port of the chosen cablink.
    [Arguments]  ${port_id}

    ${loki_a_rfoe_0}  ${loki_a_rfoe_1}  Run Keyword If  '${MODULE_TYPE}'=='ASOF'
    ...  Set Variable  [1,2,3]  []
    ...  ELSE
    ...  Set Variable  [1,2,3,4]  [5,6]
    ${loki_b_rfoe_0}  ${loki_b_rfoe_1}  Run Keyword If  '${MODULE_TYPE}' in ['ABIO', 'ABIN']
    ...  Set Variable  [7,8]  [9]
    ...  ELSE IF  '${MODULE_TYPE}'=='ASOE'
    ...  Set Variable  [7,8,9,10]  [11,12]
    ...  ELSE
    ...  Set Variable  [4,5,6]  []
    ${rfoe_ports}  Create Dictionary  loki_a_rfoe_0=${loki_a_rfoe_0}  loki_a_rfoe_1=${loki_a_rfoe_1}  loki_b_rfoe_0=${loki_b_rfoe_0}
    ...  loki_b_rfoe_1=${loki_b_rfoe_1}
    FOR  ${rfoe}  IN  @{rfoe_ports}
        Run Keyword If  '${port_id}' in '${rfoe_ports}[${rfoe}]'
        ...  Return From Keyword  ${rfoe_ports}[${rfoe}]
    END


TC Setup
    Common Test Setup  tc_name=FM__eCPRI_Radio_autonomous_reset_FID_9102_sent_twice
    Setup Netact


TC Teardown
    Change Parameter ActForce(Unit)AutoReset  false  actForceUnitAutoReset
    Teardown Netact
    Common Test Teardown
