*** Settings ***
Documentation
...  AUTHOR-daniel.bartkowiak@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com
...
...  *****************
...  Basic information
...  *****************
...  TC Verifies correct detection of RETs under selected RU. Next commissioning is performed to confirm
...  succesful operation of RET addition. Faults: 10, 4141 and 4142 are checked depending on following parameters:
...  Fault 10 depends on dcVoltageEnabled=false if RET LOGLINK has linkMOdeDC=false
...  Fault 4141 depends on dcVoltageEnabled=false if RET LOGLINK has linkMOdeDC=true
...  Fault 4142 depends on hdlcCommunicationAllowed=false for all RETs
...  NOTE1. User can execute TC per single RU, it means that all RETs belonging to selected RU are tested
...  NOTE2. Only RET type HW can be commissioned under selected RU
...  NOTE3. While preparing REMOVE_RET_SCF user need to remove all RETs under tested RU in xml and set:
...  hdlcCommunicationAllowed=false, dcVoltageEnabled=false under MO RSL for tested RU
...  NOTE4. All RETs under selected RU should be assignet to TX antenas otherwise fault 4142 won't be visible on RETs on RX
...
...  ******************
...  History of changes
...  ******************
...  20.01.2024 - Initial creation in New Framework

Resource  ./../../Resources/Setup/setup_and_teardown.robot

*** Variables ***
${TESTED_BTS_ID}=  ${EMPTY}     # In case of multinode config, test must be executed on one node at a time with specified 'TESTED_BTS_ID'
                                # If single node config, 'TESTED_BTS_ID' is not used.
${STARTUP_TIMEOUT}=  600        # Timeout (in seconds) for BTS startup after reset. Default timeout 200s

${DETECTION_TIMEOUT}=  600      # Timeout (in seconds) for RET startup. Default timeout 120s.

${REMOVE_RET_SCF}=  ${EMPTY}    # Path to scf file with removed RETs

${RU_SN}=  ${EMPTY}             # RU serialNumber where all available RETs are going to be tested

*** Keywords ***
TC__ALD_Ret_Detection_And_Commissioning
    [Documentation]  TC__ALD_Ret_Detection_And_Commissioning
    Common Test Setup
    Step1: Ret Detect Preconditions
    Step2: Ret Detect
    Step3: Ret Full Commissioning
    Step4: Ret Fault Check
    [Teardown]  Teardown_ALD_Ret_Detection_And_Commissioning  tc_status=${KEYWORD_STATUS}

Step1: Ret Detect Preconditions
    [Documentation]  Preconditions for RET detection and Commissioning
    Logging With Timestamp
    ...  message=Step1: Ret Detect Preconditions
    ...  style=STEP
    ...  frame=${TRUE}
    IF  "${TESTED_BTS_ID}"=="${EMPTY}" and len(${CFG['active_bts_list']})>1
      Run Keywords
      ...  Logging With Timestamp
      ...  message=Multinode config detected. Please specify 'TESTED_BTS_ID' for testing.
      ...  style=ERROR
      ...  AND  Fail  Multinode config detected. Please specify 'TESTED_BTS_ID' for testing.
    ELSE IF  "${TESTED_BTS_ID}"=="${EMPTY}"
      Set Test Variable  ${TESTED_BTS_ID}  ${CFG['active_bts_list'][0]}
    END
    IF  "${REMOVE_RET_SCF}"=="${EMPTY}"
      Run Keywords
      ...  Logging With Timestamp
      ...  message=SCF for RET remove mnot provided.
      ...  style=ERROR
      ...  AND  Fail  SCF for RET remove mnot provided.
    END
    IF  "${RU_SN}"=="${EMPTY}"
      Run Keywords
      ...  Logging With Timestamp
      ...  message=Parent RU for tested RETs is missing, please provide SN.
      ...  style=ERROR
      ...  AND  Fail  Parent RU for tested RETs is missing, please provide SN.
    END
    ${RSL_conf_distname}  ${RU_runtime_distname}=  Get Distnames For RU
    ${init_ald_num}  ${init_ret_num}=  Get ALDs/RETs Number For RU  ru_runtime_dist=${RU_runtime_distname}
    IF  '${init_ret_num}'=='0'
      Logging With Timestamp
      ...  message=No RETs under ${RU_runtime_distname}
      ...  style=ERROR
      Fail  No RETs under ${RU_runtime_distname}
    END
    Set Test Variable  ${INIT_ALD_NUM}  ${init_ald_num}
    Set Test Variable  ${INIT_RET_NUM}  ${init_ret_num}
    Logging With Timestamp
    ...  message=Currently detected ALD=${init_ald_num} and RET=${init_ret_num} under ${RU_runtime_distname}
    ...  message_2=Clearing out ALD/RET from configuration started.
    admin.Perform Commissioning
    ...  bts_id=${TESTED_BTS_ID}
    ...  scf_file=${REMOVE_RET_SCF}
    ...  timeout=600
    ...  connection=${TESTED_BTS_ID}
    Logging With Timestamp
    ...  message=Step1: Ret Detect Preconditions
    ...  message_2=All RETs under ${RU_runtime_distname} removed from configuration.
    ...  style=DONE

Step2: Ret Detect
    [Documentation]  Verification of RET detection
    Logging With Timestamp
    ...  message=Step2: Ret Detect
    ...  style=STEP
    ...  frame=${TRUE}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20  STATE Verify Multi Node State  scf_check=${FALSE}
    ${RSL_conf_distname}  ${RU_runtime_distname}=  Get Distnames For RU
    Set Test Variable  ${RU_RUNTIME_DISTNAME}  ${RU_runtime_distname}
    Set Test Variable  ${RSL_CONF_DISTNAME}  ${RSL_conf_distname}
    ${is_ret_not_detected}=  Run Keyword And Return Status
    ...  Check If RETs Not Detected At All  ru_dist=${RU_RUNTIME_DISTNAME}
    IF  '${is_ret_not_detected}'=='${FALSE}'
      Logging With Timestamp
      ...  message=RETs under ${RU_RUNTIME_DISTNAME} should be not visible in runtimeView
      ...  style=ERROR
      Fail  RETs under ${RU_RUNTIME_DISTNAME} should be not visible in runtimeView
    END
    Logging With Timestamp
    ...  message=RETs not detected after clearing out configuration.
    Logging With Timestamp
    ...  message=RET detection started
    ...  style=ONGOING
    Start RET Detection  mo_dn=${RSL_CONF_DISTNAME}
    ${is_ret_detected}=  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${DETECTION_TIMEOUT}  10  Check If RETs Detected  ru_dist=${RU_RUNTIME_DISTNAME}
    IF  '${is_ret_detected}'=='${FALSE}'
      Logging With Timestamp
      ...  message=All ${INIT_ALD_NUM}/${INIT_RET_NUM} ALDs/RETs under ${RU_RUNTIME_DISTNAME} should be detected in runtimeView
      ...  style=ERROR
      Fail  All ${INIT_ALD_NUM}/${INIT_RET_NUM} ALDs/RETs under ${RU_RUNTIME_DISTNAME} should be detected in runtimeView
    END
    Logging With Timestamp
    ...  message=RET detection finished successfuly.
    ...  style=DONE
    Logging With Timestamp
    ...  message=Confirming ALD/RET are uncommissioned.
    ...  style=ONGOING
    ${commissioning_status}=  Run Keyword And Return Status  Check If ALDs/RETs Commissioned  ru_dist=${RU_RUNTIME_DISTNAME}
    IF  ${commissioning_status}
      Logging With Timestamp
      ...  message=Configuration MO ALD/RETU found, HW should be uncommissioned
      ...  style=ERROR
      Fail  Configuration MO ALD/RETU found, HW should be uncommissioned
    END
    Logging With Timestamp
    ...  message=Confirmed. ALD/RET are uncommissioned.
    ...  style=DONE
    Logging With Timestamp
    ...  message=State verification started.
    ...  style=ONGOING
    Check ALD/RET States By RU  ru_dist=${RU_RUNTIME_DISTNAME}  is_onair=${TRUE}
    STATE Verify Multi Node State  scf_check=${FALSE}
    Logging With Timestamp
    ...  message=Step2: Ret Detect
    ...  message_2=States are as expected.
    ...  style=DONE

Step3: Ret Full Commissioning
    [Documentation]  Verification of RET full commissioning
    Logging With Timestamp
    ...  message=Step3: Ret Full Commissioning
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=ALD/RET Full commissioning started.
    ...  style=ONGOING
    admin.Perform Commissioning
    ...  bts_id=${TESTED_BTS_ID}
    ...  scf_file=${CFG['NODES']['${TESTED_BTS_ID}']['scf_file_path']}
    ...  timeout=600
    ...  connection=${TESTED_BTS_ID}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20  STATE Verify Multi Node State  scf_check=${FALSE}
    ${commissioning_status}=  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${DETECTION_TIMEOUT}  10  Check If ALDs/RETs Commissioned  ru_dist=${RU_RUNTIME_DISTNAME}
    IF  not ${commissioning_status}
      Logging With Timestamp
      ...  message=Configuration MO ALD/RETU missing, HW should be commissioned
      ...  style=ERROR
      Fail  Configuration MO ALD/RETU missing, HW should be commissioned
    END
    Logging With Timestamp
    ...  message=ALD/RET Full commissioning successfuly finished.
    ...  style=DONE
    Logging With Timestamp
    ...  message=ALD/RET State verification started.
    ...  style=ONGOING
    Check ALD/RET States By RU  ru_dist=${RU_RUNTIME_DISTNAME}  is_onair=${TRUE}
    Logging With Timestamp
    ...  message=Step3: Ret Full Commissioning
    ...  message_2=ALD/RET States are as expected.
    ...  style=DONE

Step4: Ret Fault Check
    [Documentation]  RET faults check
    ${unique_attr_list_1}=  Create List
    ${unique_attr_list_2}=  Create List
    Logging With Timestamp
    ...  message=Step4: Ret Fault Check
    ...  style=STEP
    ...  frame=${TRUE}
    ${ret_impacted_cells}  ${ret_notimpacted_cells}=  Get Cells Impact For RET  ru_dist=${RU_RUNTIME_DISTNAME}
    Logging With Timestamp
    ...  message=Faults check when dcVoltageEnabled=false
    ...  style=ONGOING
    ${faults_dict}=  Prepare Fault Dict  ru_dist=${RU_RUNTIME_DISTNAME}
    admin.Perform Parameter Recommissioning
    ...  dist_name=${RSL_CONF_DISTNAME}
    ...  parameter=dcVoltageEnabled
    ...  operation=update
    ...  value=false
    ...  connection=${TESTED_BTS_ID}
    FOR  ${ret}  IN  @{faults_dict}
      IF  '${faults_dict['${ret}']}'=='10'
        ${unique_attr_tmp}=  FM Await For Fault
        ...  fault_attr=faultId=${faults_dict['${ret}']}, alarmingObjectIds[0].runtime=${ret}, severity=Major
        ...  node_id=${TESTED_BTS_ID}
        ...  alarm_resource=${FAULT_10}
        ...  timeout=600
        Append To List  ${unique_attr_list_1}  ${unique_attr_tmp}
      ELSE
        ${unique_attr_tmp}=  FM Await For Fault
        ...  fault_attr=faultId=${faults_dict['${ret}']}, alarmingObjectIds[0].runtime=${ret}, severity=Major
        ...  node_id=${TESTED_BTS_ID}
        ...  alarm_resource=${FAULT_4141}
        ...  timeout=120
        Append To List  ${unique_attr_list_1}  ${unique_attr_tmp}
        # additional fault 10 shows up for a moment right after fault 4141 is cleared
        Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=10, alarmingObjectIds[0].runtime=${ret}  connection=${TESTED_BTS_ID}
      END
    END
    Check Cells While Fault Active
    ...  impacted_cells=${ret_impacted_cells}
    ...  not_impacted_cells=${ret_notimpacted_cells}
    Check ALD/RET States By RU
    ...  ru_dist=${RU_RUNTIME_DISTNAME}
    ...  is_onair=${FALSE}
    ...  states=operationalState=regex"(?i)Disabled"
    admin.Perform Parameter Recommissioning
    ...  dist_name=${RSL_CONF_DISTNAME}
    ...  parameter=dcVoltageEnabled
    ...  operation=update
    ...  value=true
    ...  connection=${TESTED_BTS_ID}
    FOR  ${unique_attr}  IN  @{unique_attr_list_1}
      FM Await For Fault Cleared  fault_attr=${unique_attr}  node_id=${TESTED_BTS_ID}  timeout=300
    END
    STATE Verify Multi Node State  scf_check=${FALSE}
    Logging With Timestamp
    ...  message=Faults check when dcVoltageEnabled=false finished. Parameter dcVoltageEnabled successfuly set to 'true'
    ...  style=DONE
    Logging With Timestamp
    ...  message=Faults check when hdlcCommunicationAllowed=false
    ...  style=ONGOING
    admin.Perform Parameter Recommissioning
    ...  dist_name=${RSL_CONF_DISTNAME}
    ...  parameter=hdlcCommunicationAllowed
    ...  operation=update
    ...  value=false
    ...  connection=${TESTED_BTS_ID}
    FOR  ${ret}  IN  @{faults_dict}
      ${unique_attr_tmp}=  FM Await For Fault
      ...  fault_attr=faultId=4142, alarmingObjectIds[0].runtime=${ret}, severity=Major
      ...  node_id=${TESTED_BTS_ID}
      ...  alarm_resource=${FAULT_4142}
      ...  timeout=120
      Append To List  ${unique_attr_list_2}  ${unique_attr_tmp}
    END
    Check Cells While Fault Active
    ...  impacted_cells=${ret_impacted_cells}
    ...  not_impacted_cells=${ret_notimpacted_cells}
    Check ALD/RET States By RU
    ...  ru_dist=${RU_RUNTIME_DISTNAME}
    ...  is_onair=${FALSE}
    ...  states=operationalState=regex"(?i)Disabled"
    admin.Perform Parameter Recommissioning
    ...  dist_name=${RSL_CONF_DISTNAME}
    ...  parameter=hdlcCommunicationAllowed
    ...  operation=update
    ...  value=true
    ...  connection=${TESTED_BTS_ID}
    FOR  ${unique_attr}  IN  @{unique_attr_list_2}
      FM Await For Fault Cleared  fault_attr=${unique_attr}  node_id=${TESTED_BTS_ID}  timeout=300
    END
    STATE Check Class States  class=ALD  node_id=${TESTED_BTS_ID}  timeout=120
    Logging With Timestamp
    ...  message=Faults check when hdlcCommunicationAllowed=false finished. Parameter hdlcCommunicationAllowed successfuly set to 'true'
    ...  message_2=Step4: Ret Fault Check
    ...  style=DONE

Get Distnames For RU
    [Documentation]  KW gets config and runtime distanems for further usage
    ...    KW returns two values: config_distname and runtime_distname
    ${bts_info}=  admin.Get BTS Info  connection=${TESTED_BTS_ID}
    FOR  ${ru}  IN  @{bts_info['radioModules']['rmod']}
      IF  '${ru['serialNumber']}'=='${RU_SN}'
        FOR  ${port}  IN  @{ru['ports']}
          IF  '${port['label']}'=='RET'
            Return From Keyword  ${port['id']['configuration']}  ${ru['id']['internal']}
          END
        END
      END
    END
    Run Keywords  Logging With Timestamp
    ...  message=RU ${RU_SN} provided by user doesn't exist
    ...  style=ERROR
    ...  AND  Fail  RU ${RU_SN} provided by user doesn't exist

Get ALDs/RETs Number For RU
    [Arguments]  ${ru_runtime_dist}
    [Documentation]  Gets number of ALD/RET devices
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | ru_runtime_dist        | Yes  | runtime distname of RU                                   |
    ...  +------------------------+------+----------------------------------------------------------+
    ...  Return:
    ...  +--------------------------+--------------------------------------------------------------------+
    ...  | Return Value             | Description                                                        |
    ...  +==========================+====================================================================+
    ...  | ald_num                  | Returns unigue number of ALD under RU                              |
    ...  +--------------------------+--------------------------------------------------------------------+
    ...  | ret_num                  | Returns unigue number of RET under RU                              |
    ...  +--------------------------+--------------------------------------------------------------------+
    ${temp_ret_list}=  Create List
    ${ald_stat}  ${alds_msg}=  Run Keyword And Ignore Error  admin.Get Ald Id By Module Connector
    ...  module_id=${ru_runtime_dist}
    ...  connection=${TESTED_BTS_ID}
    ${alds}=  Set Variable If  '${ald_stat}'=='PASS'  ${alds_msg}  ${temp_ret_list}
    ${ald_num}=  Get length  ${alds}
    FOR  ${ald}  IN  @{alds}
      ${len}=  Get Length  ${ald['RETUs']}
      Append To List  ${temp_ret_list}  ${len}
    END
    ${ret_num}=  Evaluate  sum(${temp_ret_list})
    [Return]  ${ald_num}  ${ret_num}

Check If RETs Detected
    [Arguments]  ${ru_dist}
    [Documentation]  KW verifies if RET detected
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | ru_dist                | Yes  | runtime distname of RU                                   |
    ...  +------------------------+------+----------------------------------------------------------+
    ${current_ald_num}  ${current_ret_num}=  Get ALDs/RETs Number For RU  ru_runtime_dist=${ru_dist}
    IF  '${current_ald_num}'!='${INIT_ALD_NUM}' and '${current_ret_num}'!='${INIT_RET_NUM}'
      Fail
    END

Check If RETs Not Detected At All
    [Arguments]  ${ru_dist}
    [Documentation]  KW verifies if RET not detected at all
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | ru_dist                | Yes  | runtime distname of RU                                   |
    ...  +------------------------+------+----------------------------------------------------------+
    ${current_ald_num}  ${current_ret_num}=  Get ALDs/RETs Number For RU  ru_runtime_dist=${ru_dist}
    IF  '${current_ald_num}'!='0' and '${current_ret_num}'!='0'
      Fail
    END

Check If ALDs/RETs Commissioned
    [Arguments]  ${ru_dist}
    [Documentation]  KW verifies if ALD/RETs have config objects
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | ru_dist                | Yes  | runtime distname of RU                                   |
    ...  +------------------------+------+----------------------------------------------------------+
    ${alds}=  admin.Get Ald Id By Module Connector
    ...  module_id=${ru_dist}
    ...  connection=${TESTED_BTS_ID}
    FOR  ${ald}  IN  @{alds}
      ${stat_ald_comm}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${ald['id']}  configuration
      IF  not ${stat_ald_comm}
        Fail
      END
      FOR  ${ret}  IN  @{ald['RETUs']}
        ${stat_ret_comm}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${ret['id']}  configuration
        IF  not ${stat_ret_comm}
          Fail
        END
      END
    END

Start RET Detection
    [Arguments]  ${mo_dn}
    [Documentation]  KW performs delta recomissioning of dcVoltageEnabled=true and hdlcCommunicationAllowed=true
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | mo_dn                  | Yes  | config distname of object to recommission                |
    ...  +------------------------+------+----------------------------------------------------------+
    ${delta_id}  Set Variable  ret_detect
    admin.Create Delta  delta_id=${delta_id}
    admin.Append Parameter Update To Delta
    ...  dist_name=${mo_dn}
    ...  parameter=hdlcCommunicationAllowed
    ...  value=true
    ...  delta_id=${delta_id}
    admin.Append Parameter Update To Delta
    ...  dist_name=${mo_dn}
    ...  parameter=dcVoltageEnabled
    ...  value=true
    ...  delta_id=${delta_id}
    ${delta}  admin.Get Delta  delta_id=${delta_id}
    admin.Perform Delta Recommissioning  delta_file=${delta}
    ...  connection=${TESTED_BTS_ID}
    Logging With Timestamp
    ...  message=Delta commissioning with "hdlcCommunicationAllowed" and "dcVoltageEnabled" parameters finished.
    admin.Remove Delta  delta_id=${delta_id}

Check ALD/RET States By RU
    [Arguments]  ${ru_dist}  ${is_onair}  ${states}=${ALD_onair_states}
    [Documentation]  KW verifies states statuses of all ALD/RET devices under ru_dist. State values can by provided as regex.
    ...  states variable value example: administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | ru_dist                | Yes  | runtime distname of RU                                   |
    ...  +------------------------+------+----------------------------------------------------------+
    ...  | is_onair               | Yes  | Flag for onair/notonair check. ${TRUE}/${FALSE}          |
    ...  +------------------------+------+----------------------------------------------------------+
    ...  | states                 | No   | State value. Default value from STATE resource for ALD   |
    ...  +------------------------+------+----------------------------------------------------------+
    Sleep  10s  Wait 10s for ALD states stabilization
    ${alds}=  admin.Get Ald Id By Module Connector
    ...  module_id=${ru_dist}
    ...  connection=${TESTED_BTS_ID}
    FOR  ${ald}  IN  @{alds}
      ${ald_status}=  Run Keyword And Return Status  STATE Verify States For One
      ...  class=ALD
      ...  object=${ald['id']['internal']}
      ...  states=${states}
      ...  node_id=${TESTED_BTS_ID}
      ...  onair=${is_onair}
      IF  not ${ald_status}
        Logging With Timestamp
        ...  message=${ald['id']} has:
        ...  message_2=${ald['status']}
        ...  style=ERROR
        Fail  ${ald['id']} has ${ald['status']}
      END
      FOR  ${ret}  IN  @{ald['RETUs']}
        Logging With Timestamp
        ...  message=Start ${ret['id']['internal']} verification
        IF  ${is_onair}
          ${ret_availa}=  Run Keyword And Return Status
          ...  Dictionary Should Not Contain Key  ${ret['status']}  availabilityStatus
          ${ret_oper}=  Run Keyword And Return Status  Should Match Regexp  ${ret['status']['operationalState']}  (?i)Enabled
        ELSE
          ${ret_availa}=  Run Keyword And Return Status
          ...  Dictionary Should Contain Key  ${ret['status']}  availabilityStatus
          ${ret_oper}=  Run Keyword And Return Status  Should Match Regexp  ${ret['status']['operationalState']}  (?i)Disabled
        END
        IF  not (${ret_availa} and ${ret_oper})
          Logging With Timestamp
          ...  message=${ret['id']} has:
          ...  message_2=${ret['status']}
          ...  style=ERROR
          Fail  ${ret['id']} has ${ret['status']}
        END
        Logging With Timestamp
        ...  message=All states of ${ret['id']['internal']} are as expected
      END
    END

Get Cells Impact For RET
    [Arguments]  ${ru_dist}
    [Documentation]  KW verifies states operational and availability statuses of all ALD/RET devices under ru_dist
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | ru_dist                | Yes  | runtime distname of RU                                   |
    ...  +------------------------+------+----------------------------------------------------------+
    ...  Return:
    ...  +--------------------------+--------------------------------------------------------------------+
    ...  | Return Value             | Description                                                        |
    ...  +==========================+====================================================================+
    ...  | ret_impacted_cells_list  | Cells impacted by RETs on RU                                       |
    ...  +--------------------------+--------------------------------------------------------------------+
    ...  | ru_cells_list            | Cells not impacted by RETs on RU                                   |
    ...  +--------------------------+--------------------------------------------------------------------+
    ${ant_for_ret_list}=  Create List
    ${alds}=  admin.Get Ald Id By Module Connector
    ...  module_id=${ru_dist}
    ...  connection=${TESTED_BTS_ID}
    FOR  ${ald}  IN  @{alds}
      FOR  ${ret}  IN  @{ald['RETUs']}
        ${ant_for_ret_list}=  Combine Lists  ${ant_for_ret_list}  ${ret['antlDNList']}
      END
    END
    ${ru_cells_list}=  admin.Get Cell Mapping By Module Id
    ...  module_id=${ru_dist}
    ...  connection=${TESTED_BTS_ID}
    ${ret_impacted_cells_list}=  Create List
    FOR  ${cell}  IN  @{ru_cells_list}
      ${cell_info}=  admin.Get Cell Specific Info  cell_id=${cell}  connection=${TESTED_BTS_ID}
      FOR  ${carrier}  IN  @{cell_info['carrierList']}
        IF  '${carrier['antennaLineId']['internal']}' in ${ant_for_ret_list}
          Append To List  ${ret_impacted_cells_list}  ${cell}
          Exit For Loop
        END
      END
    END
    Remove Values From List  ${ru_cells_list}  @{ret_impacted_cells_list}
    [Return]  ${ret_impacted_cells_list}  ${ru_cells_list}

Check Cells While Fault Active
    [Arguments]  ${impacted_cells}  ${not_impacted_cells}
    [Documentation]  KW checks if Cells states have correct values.
    ...  Arguments:
    ...  +========================+======+==================================================================+
    ...  | Argument               | Man. | Description                                                      |
    ...  +========================+======+==================================================================+
    ...  | impacted_cells         | Yes  | Cells for state check                                            |
    ...  +------------------------+------+------------------------------------------------------------------+
    ...  | not_impacted_cells     | Yes  | Cells for state check                                            |
    ...  +------------------------+------+------------------------------------------------------------------+
    Logging With Timestamp
    ...  message=Checking cells states when Faults active.
    ...  message_2=Impacted ALD/RET cells ${impacted_cells}.${\n}Not impacted ALD/RET cells ${not_impacted_cells}
    ...  style=ONGOING
    FOR  ${cell}  IN  @{impacted_cells}
      ${split}=  Split String From Right  ${cell}  /  1
      ${tech}=  Get Substring  ${split[1]}  0  1
      ${class_name}=  Set Variable If
      ...  '${tech}'=='N'  NRCEL
      ...  '${tech}'=='L'  LNCEL
      ...  '${tech}'=='W'  WNCEL
      ...  '${tech}'=='G'  GNCEL
      ${status}=  Run Keyword And Return Status  admin.Assert
      ...  class_name=${class_name}
      ...  id=${cell}
      ...  parameters=operationalState=regex"(?i)Enabled", availabilityStatus=regex"(?i)Degraded
      ...  connection=${TESTED_BTS_ID}
      IF  not ${status}
        Logging With Timestamp
        ...  message=${cell} has wrong states oprational/availability. Should be Enabled/Degraded.
        ...  style=ERROR
        Fail  ${cell} has wrong states oprational/availability. Should be Enabled/Degraded.
      END
    END
    FOR  ${cell}  IN  @{not_impacted_cells}
      ${cell_info}=  admin.Get Cell Specific Info  cell_id=${cell}  connection=${TESTED_BTS_ID}
      ${stat_availa}=  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${cell_info['status']}  availabilityStatus
      ${stat_oper}=  Run Keyword And Return Status  Should Match Regexp  ${cell_info['status']['operationalState']}  (?i)Enabled
      IF  not (${stat_availa} and ${stat_oper})
        Logging With Timestamp
        ...  message=${cell} has wrong states oprational/availability. Should be Enabled/-.
        ...  style=ERROR
        Fail  ${cell} has wrong states oprational/availability. Should be Enabled/-.
      END
    END
    Logging With Timestamp
    ...  message=Cells check succeeded.
    ...  style=DONE

Prepare Fault Dict
    [Arguments]  ${ru_dist}
    [Documentation]  KW verifies states operational and availability statuses of all ALD/RET devices under ru_dist
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | ru_dist                | Yes  | runtime distname of RU                                   |
    ...  +------------------------+------+----------------------------------------------------------+
    ...  Return:
    ...  +--------------------------+--------------------------------------------------------------------+
    ...  | Return Value             | Description                                                        |
    ...  +==========================+====================================================================+
    ...  | fault_dict               | Dictionary with key as runtime_dist and faultid as value           |
    ...  +--------------------------+--------------------------------------------------------------------+
    ${fault_dict}=  Create Dictionary
    ${alds}=  admin.Get Ald Id By Module Connector
    ...  module_id=${ru_dist}
    ...  connection=${TESTED_BTS_ID}
    ${bts_info}=  admin.Get BTS Info  connection=${TESTED_BTS_ID}
    FOR  ${ald}  IN  @{alds}
      ${ald_r}=  Split String From Right  ${ald['id']['runtime']}  /  1
      FOR  ${loglink}  IN  @{bts_info['loglinks']}
        IF  '${ald_r[1]}' in '${loglink['secondEndPointId']}' and '${loglink['linkMode']['dc']}'=='True'
          FOR  ${ret}  IN  @{ald['RETUs']}
            Set To Dictionary  ${fault_dict}  ${ret['id']['runtime']}=4141
          END
        ELSE IF  '${ald_r[1]}' in '${loglink['secondEndPointId']}' and '${loglink['linkMode']['dc']}'=='False'
          FOR  ${ret}  IN  @{ald['RETUs']}
            Set To Dictionary  ${fault_dict}  ${ret['id']['runtime']}=10
          END
        END
      END
    END
    [Return]  ${fault_dict}

Teardown_ALD_Ret_Detection_And_Commissioning
    [Arguments]  ${tc_status}
    [Documentation]  Teardown procedures
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | tc_status              | Yes  | TC status                                                |
    ...  +------------------------+------+----------------------------------------------------------+
    Logging With Timestamp
    ...  message=TC teardown started
    IF  "${tc_status}"=="FAIL"  Run Keywords  Run Keyword And Continue On Failure  admin.Perform Commissioning
      ...  bts_id=${TESTED_BTS_ID}
      ...  scf_file=${CFG['NODES']['${TESTED_BTS_ID}']['scf_file_path']}
      ...  timeout=600
      ...  connection=${TESTED_BTS_ID}
      ...  AND  Run Keyword And Continue On Failure
      ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20  STATE Verify Multi Node State  scf_check=${FALSE}
    Common Test Teardown

