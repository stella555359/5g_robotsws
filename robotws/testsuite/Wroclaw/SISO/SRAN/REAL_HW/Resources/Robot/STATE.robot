*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Library    ./../../../resources/ims2_parser.py
Library    OperatingSystem
Library    Collections
Library    String
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.sw.ping    WITH NAME    ping
Resource    ./BTS_INFO.robot


*** Variables ***
${RMOD_onair_states}=    administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${ASIRMOD_onair_states}=    administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${SMOD_onair_states}=    administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${BBMOD_onair_states}=    administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${FHS_onair_states}=    administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${ALD_onair_states}=    operationalState=regex"(?i)Enabled"
${SMOD_EXT_onair_states}=    operationalState=regex"(?i)Enabled"
${CABLINK_onair_states}=    operationalState=regex"(?i)Enabled"
${SFP_onair_states}=    operationalState=regex"(?i)Enabled"
${CARRIERGROUPC_onair_states}=    administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked",
...    usageState=regex"(?i)Active"
${LNCEL_onair_states}=    administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
${WNCEL_onair_states}=    operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${NRCEL_onair_states}=    administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
${GNCEL_onair_states}=    administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked",
...    usageState=regex"(?i)Active"
${BBU_onair_states}=    administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${DEGRADED_status}=    availabilityStatus=regex"(?i)Degraded"

# ==================================energy_efficiency========================================

&{CELL_ENERGY_SAVING_STATES_REQUIREMENTS}=
...    notenergysaving=administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
...    energysaving=administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Disabled", blockingState=regex"(?i)Unblocked",
...    availabilityStatus=regex"(?i)off line"
...    reducedenergysaving=administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
...    switchingoffrtx=administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
...    switchingoff=administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
...    switchingontx=administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"


*** Keywords ***
STATE Verify BTS Procedural State
    [Arguments]    ${expected_BTS_status}    ${node_id}
    [Documentation]  KW compares expected and actual BTS proceural state. Fails If values are different.
    ...    +---------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument            | Man.  | Description                                                                                   |
    ...    +=====================+=======+===============================================================================================+
    ...    | expected_BTS_status | Yes   | expected status, ex. OnAir                                                                    |
    ...    +---------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | node_id             | Yes   | BTS_ID used as alias                                                                          |
    ...    +---------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Logging With Timestamp
    ...    message=Start BTS procedural state verification
    ...    logs_dir=${CFG.suite_logs_path}
    ${current_status}=    admin.Get Mrbts State    connection=${node_id}
    ${BTS_in_expected_status}=    Run Keyword And Return Status    Should Match Regexp    ${current_status}    ${expected_BTS_status}
    IF    ${BTS_in_expected_status}
        Logging With Timestamp    message=BTS is in expected status (${current_status})!    logs_dir=${CFG.suite_logs_path}
    ELSE
        Logging With Timestamp
        ...    message=BTS has state ${current_status} other than expected. ${expected_BTS_status} status
        ...    logs_dir=${CFG.suite_logs_path}
        ...    style=FAIL
        Fail    BTS has state ${current_status} other than expected ${expected_BTS_status} status
    END

STATE Verify States For All
    [Arguments]    ${class}    ${node_id}    ${states}=${${class}_onair_states}    ${onair}=${TRUE}    ${scf_check}=${TRUE}    ${timeout}=60
    [Documentation]
    ...  KW for checking 'class' runtime objects number against SCF and comparing 'class' states with expected statuses.
    ...  If 'onair' is set to TRUE then 'availabilityStatus=-' is verified by default for all classes excluding NRCEL/LNCEL
    ...  If 'onair' is set to TRUE then energy efficiency states are checked according to dictionary CELL_ENERGY_SAVING_STATES_REQUIREMENTS
    ...  If 'onair' is set to FALSE then user need to provide desired value in 'states' argument.
    ...  When RMOD class is verified then additionaly energy efficiency powerState for RMOD is validated
    ...  Supported Classes: SMOD, RMOD, BBMOD, BBU, ASIRMOD, NRCEL, LNCEL, WNCEL, GNCEL, CARRIERGROUPC, ALD, CABLINK, SFP, FHS, SMOD_EXT
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | class              | Yes   | Class name for which states should be checked, ex. SMOD                                       |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | node_id            | Yes   | BTS_ID used as alias                                                                          |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | states             | No    | Expected states as string, e.g., "administrativeState=Unlocked, operationalState=Enabled"     |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | onair              | No    | TRUE/FALSE, set FALSE if KW used to check not onair states                                    |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | scf_check          | No    | TRUE/FALSE, set FALSE if number of SCF object should not be validated                         |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | timeout            | No    | default value 60s                                                                             |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Logging With Timestamp
    ...    message=Start ${class} verification
    ...    logs_dir=${CFG.suite_logs_path}
    IF    "${class}"=="RMOD"
        Wait Until Keyword Succeeds    ${timeout}    40    STATE Verify Energy Efficiency On Every RU    bts_id=${node_id}
    END
    ${ids}=    admin.Get Ids For All
    ...    ${class}
    ...    connection=${node_id}
    ...    search_for_iot_cells=${True}
    ...    timeout=${BASIC_ADMIN_PROCEDURES_TIMEOUT}
    ${admin_count}=    Get Length    ${ids}
    IF    not ${admin_count}
        ${status_1}    ${status_2}=    Set Variable    PASS    ${TRUE}
    ELSE
        ${status_1}    ${status_2}=    Set Variable    ${None}    ${None}
    END
    FOR    ${id}    IN    @{ids}
        IF    '${class}' in 'NRCEL|LNCEL'
            ${item_info}=    admin.Get Cell Specific Info    cell_id=${id}    timeout=${timeout}    connection=${node_id}
        ELSE
            ${item_info}=    Set Variable    ${EMPTY}
        END
        ${energy_saving_state}=    Set Variable If    "${item_info}"!="${EMPTY}"    ${item_info['energySavingState']}    ${EMPTY}
        IF    "${energy_saving_state}"!="${EMPTY}" and ${onair}==${TRUE}
            ${expected_states}=    Set Variable    ${CELL_ENERGY_SAVING_STATES_REQUIREMENTS["${energy_saving_state}".lower()]}
        ELSE
            ${expected_states}=    Set Variable    ${states}
        END
        ${status_1}    ${msg}=    Run Keyword And Ignore Error    admin.Assert
        ...    class_name=${class}
        ...    id=${id}
        ...    parameters=${expected_states}
        ...    timeout=${timeout}
        ...    connection=${node_id}
        IF    "${energy_saving_state}".lower()=="energysaving" or ${onair}==${FALSE}
            ${status_2}=    Set Variable    ${TRUE}
        ELSE
            ${status_2}=    Run Keyword And Return Status
            ...    Wait Until Keyword Succeeds
            ...    ${timeout}
            ...    15s
            ...    STATE Check AvailabilityStatus Is OnAir
            ...    class=${class}
            ...    node_id=${node_id}
            ...    distname=${id}
        END
        IF    "${energy_saving_state}".lower()=="energysaving" or ${onair}==${FALSE}
            ${expected_states}=    Set Variable    ${expected_states}
        ELSE
            ${expected_states}=    Set Variable    ${expected_states}, availabilityStatus=-
        END
        Exit For Loop If    "${status_1}"=="FAIL" or ${status_2}==False
    END
    ${scf_count}=    STATE Count Scf Objects    ${class}    ${node_id}
    IF    ${scf_count}==None
        Logging With Timestamp
        ...    message=Class ${class} is excluded globally from scf counting, only states are checked
        ...    logs_dir=${CFG.suite_logs_path}
    END
    IF    ${scf_check}
        ${count_status}=    Set Variable If    "${admin_count}"=="${scf_count}" or ${scf_count}==None    ${TRUE}    ${FALSE}
    ELSE
        ${count_status}=    Set Variable    ${TRUE}
    END
    IF    "${status_1}"=="PASS" and ${status_2} and ${count_status}
        Logging With Timestamp    message=All states of ${class} objects are as expected    logs_dir=${CFG.suite_logs_path}
    ELSE IF    "${status_1}"=="FAIL" or ${status_2}==False
        Logging With Timestamp
        ...    message=Class ${class} objects have states other than expected. ${\n}Expected=${expected_states}
        ...    logs_dir=${CFG.suite_logs_path}
        ...    style=FAIL
        Fail    Class ${class} objects have states other than expected. ${\n}Expected=${expected_states}
    ELSE IF    ${count_status}==False
        Logging With Timestamp
        ...    message=Class ${class} objects amount differs between scf and runtime_view, scf=${scf_count} runtime=${admin_count}
        ...    logs_dir=${CFG.suite_logs_path}
        ...    style=FAIL
        Fail    Class ${class} objects amount differs between scf and runtime_view, scf=${scf_count} runtime=${admin_count}
    END

STATE Verify States For One
    [Arguments]    ${class}    ${object}    ${node_id}    ${states}=${${class}_onair_states}    ${onair}=${TRUE}    ${timeout}=60
    [Documentation]
    ...  KW for checking states of one object from 'class'
    ...  If 'onair' is set to TRUE then 'availabilityStatus=-' is verified by default for all classes excluding NRCEL/LNCEL
    ...  If 'onair' is set to TRUE then energy efficiency states are checked according to dictionary CELL_ENERGY_SAVING_STATES_REQUIREMENTS
    ...  If 'onair' is set to FALSE then user need to provide desired value in 'states' argument.
    ...  When RMOD class is verified then additionaly energy efficiency powerState for RMOD is validated
    ...  Supported Classes: SMOD, RMOD, BBMOD, BBU, ASIRMOD, NRCEL, LNCEL, WNCEL, GNCEL, CARRIERGROUPC, ALD, CABLINK, SFP, FHS, SMOD_EXT
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | class              | Yes   | Class name for which states should be checked, ex SMOD                                        |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | object             | Yes   | Runtime object distname to verify                                                             |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | node_id            | Yes   | BTS_ID used as alias                                                                          |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | states             | No    | Expected states as string, e.g., "administrativeState=Unlocked, operationalState=Enabled"     |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | onair              | No    | TRUE/FALSE, set FALSE if KW used to check not onair states                                    |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | timeout            | No    | default value 60s                                                                             |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Logging With Timestamp
    ...    message=Start ${object} verification
    ...    logs_dir=${CFG.suite_logs_path}
    IF    "${class}"=="RMOD"
        STATE Verify Energy Efficiency On RU By Distname    bts_id=${node_id}    ru_dn=${object}
    END
    IF    '${class}' in 'NRCEL|LNCEL'
        ${item_info}=    admin.Get Cell Specific Info    cell_id=${object}    timeout=${timeout}    connection=${node_id}
    ELSE
        ${item_info}=    Set Variable    ${EMPTY}
    END
    ${energy_saving_state}=    Set Variable If    "${item_info}"!="${EMPTY}"    ${item_info['energySavingState']}    ${EMPTY}
    IF    "${energy_saving_state}"!="${EMPTY}" and ${onair}==${TRUE}
        ${expected_states}=    Set Variable    ${CELL_ENERGY_SAVING_STATES_REQUIREMENTS["${energy_saving_state}".lower()]}
    ELSE
        ${expected_states}=    Set Variable    ${states}
    END
    ${status_1}    ${msg}=    Run Keyword And Ignore Error    admin.Assert
    ...    class_name=${class}
    ...    id=${object}
    ...    parameters=${expected_states}
    ...    timeout=${timeout}
    ...    connection=${node_id}
    IF    "${energy_saving_state}".lower()=="energysaving" or ${onair}==${FALSE}
        ${status_2}=    Set Variable    ${TRUE}
    ELSE
        ${status_2}=    Run Keyword And Return Status
        ...    Wait Until Keyword Succeeds
        ...    ${timeout}
        ...    15s
        ...    STATE Check AvailabilityStatus Is OnAir
        ...    class=${class}
        ...    node_id=${node_id}
        ...    distname=${object}
    END
    IF    "${energy_saving_state}".lower()=="energysaving" or ${onair}==${FALSE}
        ${expected_states}=    Set Variable    ${expected_states}
    ELSE
        ${expected_states}=    Set Variable    ${expected_states}, availabilityStatus=-
    END
    IF    "${status_1}"=="PASS" and ${status_2}
        Logging With Timestamp    message=All states of ${object} are as expected    logs_dir=${CFG.suite_logs_path}
    ELSE
        Logging With Timestamp
        ...    message=${object} have states other than expected. ${\n}Expected=${expected_states}
        ...    logs_dir=${CFG.suite_logs_path}
        ...    style=FAIL
        Fail    ${object} have states other than expected. ${\n}Expected=${expected_states}
    END

STATE Check If State Remained Unchanged In History
    [Arguments]    ${ims2_log_path}    ${runtime_dn_list}    ${exp_state_name}
    [Documentation]
    ...  KW for checking runtime objects' parameters in IMS history
    ...  veryfies if desired state remainded unchanged in provided ims2 log.
    ...  KW fails when detected any transition in 'exp_state_name' history
    ...
    ...  NOTE availabilityStatus gets "-" when object is On Air
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | ims2_log_path      | Yes   | Path to ims file                                                                              |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | runtime_dn_list    | Yes   | Runtime distnames list for verification                                                       |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | exp_state_name     | Yes   | Expected state name e.g. administrativeState or operationalState                              |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Should Not Be Empty    ${runtime_dn_list}    Fail!! List Variable 'runtime_dn_list' should not be empty
    @{statuses_list}=    Create List
    @{failed_items_list}=    Create List
    Log    ${\n}Checking ${exp_state_name} history in ${ims2_log_path}:${\n}    console=${TRUE}
    FOR    ${item}    IN    @{runtime_dn_list}
        ${status}=    Run Keyword And Return Status    Run Keyword And Expect Error    No change*    Find Parameter Change
        ...    ${ims2_log_path}    ${item}    ${exp_state_name}
        IF    ${status}
            Log    ${exp_state_name} of ${item} remained unchanged    console=${TRUE}
        ELSE
            Append To List    ${failed_items_list}    ${item}
            Log    Fail occured when checking ${item}    console=${TRUE}
        END
        Append To List    ${statuses_list}    ${status}
    END
    IF    False in ${statuses_list}
        Fail    State ${exp_state_name} was changed for: {\n}${failed_items_list}. {\n}It shouldn't changed.
    END

STATE Check State And Value In History
    [Arguments]    ${ims2_log_path}    ${runtime_dn_list}    ${exp_state_name}    ${exp_state_value}    ${exp_times}=${None}
    [Documentation]
    ...  KW for checking runtime objects' parameters in IMS history
    ...  veryfies if desired state and its value found in provided ims2 log.
    ...  KW fails when not detected 'exp_state_value' in 'exp_state_name' desired number of times
    ...
    ...  NOTE 'exp_times' by default is checking if "exp_state_value" found at least one time
    ...  NOTE availabilityStatus gets "-" when object is On Air
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | ims2_log_path      | Yes   | Path to ims file                                                                              |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | runtime_dn_list    | Yes   | Runtime distnames list for verification                                                       |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | exp_state_name     | Yes   | Expected state name e.g. administrativeState or operationalState                              |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | exp_state_value    | Yes   | Expected state value, e.g., Unlocked or Enabled or Regex"(?i)Resetting"                       |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | exp_times          | No    | Defines how many times state_value is expected                                                |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Should Not Be Empty    ${runtime_dn_list}    Fail!! List Variable 'runtime_dn_list' should not be empty
    @{statuses_list}=    Create List
    @{failed_items_list}=    Create List
    ${rep}=    Set Variable If    ${exp_times}==None    at least once    ${exp_times} times
    Log    ${\n}Checking ${exp_state_name} history in ${ims2_log_path}:${\n}    console=${TRUE}
    FOR    ${item}    IN    @{runtime_dn_list}
        ${status}    ${msg}=    Run Keyword And Ignore Error    Find Parameter Change
        ...    ${ims2_log_path}    ${item}    ${exp_state_name}    ${exp_state_value}    ${exp_times}
        IF    "${status}"=="PASS"
            Log    ${exp_state_name}=${exp_state_value} of ${item} found expected number of times    console=${TRUE}
        ELSE
            Append To List    ${failed_items_list}    ${item}
            Log    ${exp_state_value} under ${msg} in ${item}!! Fail    console=${TRUE}
        END
        Append To List    ${statuses_list}    ${status}
    END
    ${failed_items_list_final}=    Evaluate    pprint.pformat(${failed_items_list}, indent=4)    modules=pprint
    ${is_fail}=    Run Keyword And Return Status    List Should Contain Value    ${statuses_list}    FAIL
    IF    ${is_fail}
        Fail    Check log, ${exp_state_value} should be found ${rep} under each object!! Failed items: ${\n}${failed_items_list_final}
    END

STATE Check Historical States Transition In IMS
    [Arguments]    ${ims2_log_path}    ${runtime_dn_list}    ${exp_state_name}    ${exp_state_trans}    ${exp_times}=${None}
    [Documentation]
    ...  KW for checking runtime parameters' transition in IMS history
    ...  KW fails when not detected 'exp_state_trans' in 'exp_state_name' history
    ...  KW fails when 'exp_state_trans' not detected exact number of 'exp_times' in 'exp_state_name' history
    ...
    ...  NOTE 'exp_times' by default is checking if "exp_state_trans" found at least one time
    ...  NOTE availabilityStatus gets "-" when object is On Air
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | ims2_log_path      | Yes   | Path to ims file                                                                              |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | runtime_dn_list    | Yes   | Runtime distnames list for verification                                                       |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | exp_state_name     | Yes   | Expected state name e.g. administrativeState or operationalState                              |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | exp_state_trans    | Yes   | Expected state trans, e.g., enabled->disabled or  Regex"(?i)-->off.*?line"                    |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | exp_times          | No    | Defines how many times exp_state_trans is expected                                            |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Should Not Be Empty    ${runtime_dn_list}    Fail!! List Variable 'runtime_dn_list' should not be empty
    @{statuses_list}=    Create List
    @{failed_items_list}=    Create List
    ${rep}=    Set Variable If    ${exp_times}==None    at least once    ${exp_times} times
    Log    ${\n}Checking ${exp_state_name} transition ${exp_state_trans} history in ${ims2_log_path}:${\n}    console=${TRUE}
    FOR    ${item}    IN    @{runtime_dn_list}
        ${status}    ${msg}=    Run Keyword And Ignore Error    Find Parameter Transition
        ...    ${ims2_log_path}    ${item}    ${exp_state_name}    ${exp_state_trans}    ${exp_times}
        IF    "${status}"=="PASS"
            Log    ${exp_state_trans} of ${item} found expected number of times    console=${TRUE}
        ELSE
            Append To List    ${failed_items_list}    ${item}
            Log    ${msg} in ${item}!! Fail    console=${TRUE}
        END
        Append To List    ${statuses_list}    ${status}
    END
    ${failed_items_list_final}=    Evaluate    pprint.pformat(${failed_items_list}, indent=4)    modules=pprint
    ${is_fail}=    Run Keyword And Return Status    List Should Contain Value    ${statuses_list}    FAIL
    IF    ${is_fail}
        Fail    Check log, ${exp_state_trans} should be found ${rep} under each object!! Failed items: ${\n}${failed_items_list_final}
    END

STATE Count Scf Objects
    [Arguments]    ${class}    ${node_id}
    [Documentation]  KW counts scf object for specific class in scf.
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | node_id            | Yes   | current bts id                                                                                |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | class              | Yes   | Allowed classes  SMOD|BBMOD|RMOD|ASIRMOD                                                      |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    IF    '${class}'=='GNCEL'
        ${number}=    Set Variable    ${cfg['NODES']['${node_id}']['scf_cell_count']['GSM']}
    ELSE IF    '${class}'=='WNCEL'
        ${number}=    Set Variable    ${cfg['NODES']['${node_id}']['scf_cell_count']['WCDMA']}
    ELSE IF    '${class}'=='LNCEL'
        ${number}=    Set Variable    ${cfg['NODES']['${node_id}']['scf_cell_count']['LTE']}
    ELSE IF    '${class}'=='NRCEL'
        ${number}=    Set Variable    ${cfg['NODES']['${node_id}']['scf_cell_count']['NR']}
    ELSE IF    '${class}'=='FHS'
        ${number}=    Set Variable    ${cfg['NODES']['${node_id}']['scf_hw_count']['FHS']}
    ELSE IF    '${class}'=='BBMOD'
        ${number}=    Set Variable    ${cfg['NODES']['${node_id}']['scf_hw_count']['BBMOD']}
    ELSE IF    '${class}'=='SMOD'
        ${number}=    Set Variable    ${cfg['NODES']['${node_id}']['scf_hw_count']['SMOD']}
    ELSE IF    '${class}'=='RMOD'
        ${number}=    Set Variable    ${cfg['NODES']['${node_id}']['scf_hw_count']['RMOD']}
    ELSE IF    '${class}'=='CABLINK'
        ${number}=    Set Variable    ${cfg['NODES']['${node_id}']['scf_hw_count']['CABLINK']}
    ELSE IF    '${class}'=='ASIRMOD'
        ${number}=    Set Variable    ${cfg['NODES']['${node_id}']['scf_hw_count']['ASIRMOD']}
    ELSE IF    '${class}'=='ALD'
        ${number}=    Set Variable    ${cfg['NODES']['${node_id}']['scf_hw_count']['ALD']}
    ELSE
        ${number}=    Set Variable    ${None}
    END
    RETURN    ${number}

STATE Check Node HW status
    [Arguments]    ${bts_id}    ${timeout}=900
    [Documentation]  KW for verification HW state. Only HW with possibility to sw update is taken for inspection.
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | bts_id             | Yes   | current bts id                                                                                |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | timeout            | No    | timoeut to wait for onair after sw update                                                     |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Logging With Timestamp
    ...    message=Checking HW availability
    ...    logs_dir=${CFG.suite_logs_path}
    IF    ${CFG['NODES']['${bts_id}']['scf_hw_count']['RMOD']}
        Run Keyword And Continue On Failure
        ...    STATE Verify States For All
        ...    class=RMOD
        ...    node_id=${bts_id}
        ...    scf_check=${FALSE}
        ...    timeout=${timeout}
    END
    IF    ${CFG['NODES']['${bts_id}']['scf_hw_count']['ASIRMOD']}
        Run Keyword And Continue On Failure
        ...    STATE Verify States For All
        ...    class=ASIRMOD
        ...    node_id=${bts_id}
        ...    scf_check=${FALSE}
        ...    timeout=${timeout}
    END
    IF    ${cfg['NODES']['${bts_id}']['scf_hw_count']['FHS']}
        Run Keyword And Continue On Failure
        ...    STATE Verify States For All
        ...    class=FHS
        ...    node_id=${bts_id}
        ...    scf_check=${FALSE}
        ...    timeout=${timeout}
    END
    Run Keyword And Continue On Failure    STATE Verify States For All    class=SMOD    node_id=${bts_id}    scf_check=${FALSE}    timeout=${timeout}

STATE Verify Product Code
    [Arguments]    ${class}    ${node_id}
    [Documentation]  KW For checking HW type in comparison scf and runtime
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | class              | Yes   | Allowed classes  SMOD|BBMOD|RMOD|ASIRMOD                                                      |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | node_id            | Yes   | current bts id                                                                                |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${class_ids}=    admin.Get Ids For All    ${class}    connection=${node_id}    timeout=${BASIC_ADMIN_PROCEDURES_TIMEOUT}
    ${ids_num}=    Get Length    ${class_ids}
    IF    ${ids_num}==0
        RETURN
    END
    ${assert_output}=    admin.Assert Every    ${class}    operationalState=regex"(?i)Disabled|Enabled"    connection=${node_id}
    ${runtime_prodcodes}=    Create List
    ${scf_prodcodes}=    Create List
    FOR    ${mod}    IN    @{assert_output}
        ${raw_prodcode}=    Get From Dictionary    ${mod}    productCode
        ${stripped_prodcode}=    Strip String    ${raw_prodcode}
        @{prod_code}=    Split String    ${stripped_prodcode}    .
        ${stripped_prodcode}=    Get From List    ${prod_code}    0
        Append To List    ${runtime_prodcodes}    ${stripped_prodcode}
    END
    ${raw_scf_prodcodes_list}=    Evaluate Xpath    ${CFG['NODES']['${node_id}']['scf_file_path']}
    ...    .//managedObject[contains(@class, ':${class}_R')]/p[@name='productCode']/text()
    FOR    ${raw_scf_prodcode}    IN    @{raw_scf_prodcodes_list}
        ${stripped_scf_prodcode}=    Strip String    ${raw_scf_prodcode}
        @{prod_code}=    Split String    ${stripped_scf_prodcode}    .
        ${stripped_scf_prodcode}=    Get From List    ${prod_code}    0
        Append To List    ${scf_prodcodes}    ${stripped_scf_prodcode}
    END
    Sort List    ${runtime_prodcodes}
    Sort List    ${scf_prodcodes}
    ${status}=    Run Keyword And Return Status    Lists Should Be Equal    ${runtime_prodcodes}    ${scf_prodcodes}
    IF    not ${status}
        Logging With Timestamp
        ...    message=${class} prodcodes differs between runtime and scf:${\n}runtime:${runtime_prodcodes}${\n}scf:${scf_prodcodes}
        ...    style=FAIL
        ...    logs_dir=${CFG.suite_logs_path}
        Fail    ${class} prodcodes differs between runtime and scf:${\n}runtime:${runtime_prodcodes}${\n}scf:${scf_prodcodes}
    END

STATE Check Class States
    [Arguments]    ${class}    ${node_id}    ${scf_check}=${TRUE}    ${timeout}=60
    [Documentation]  KW for checking Onair states for desired class. KW also verifies HW product code if
    ...    class is in range SMOD|BBMOD|RMOD|ASIRMOD and scf_check=${TRUE}
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | class              | Yes   | Allowed classes  SMOD|BBMOD|RMOD|ASIRMOD|FHS|ALD|CABLINK|SFP                                  |
    ...    |                    |       | CARRIERGROUPC|GNCEL|WNCEL|LNCEL|NRCEL                                                         |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | node_id            | Yes   | current bts id                                                                                |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | scf_check          | No    |scf check switch, default ${TRUE}                                                              |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | timeout            | No    | timoeut to wait for onair after sw update                                                     |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    STATE Verify States For All    class=${class}    node_id=${node_id}    scf_check=${scf_check}    timeout=${timeout}
    IF    ${scf_check} and '${class}' in 'SMOD|BBMOD|RMOD|ASIRMOD'
        STATE Verify Product Code    ${class}    ${node_id}
    END

STATE Verify BTS states
    [Arguments]
    ...    ${node_id}
    ...    ${expected_BTS_status}=OnAir
    ...    ${HW_check}=${TRUE}
    ...    ${cells_check}=${TRUE}
    ...    ${scf_check}=${TRUE}
    ...    ${timeout}=60
    [Documentation]  KW for checking Onair states for desired bts. HW_check disable/enadle HW states check
    ...    SMOD|BBMOD|RMOD|ASIRMOD|FHS|ALD|SFP|CABLINK. cells_check disable/enadle cells states GNCEL|WNCEL|LNCEL|NRCEL|CARRIERGROUPC.
    ...    scf_check disable/enable scf object counting for SMOD|BBMOD|RMOD|ASIRMOD|FHS|ALD|GNCEL|WNCEL|LNCEL|NRCEL and Prod Code Veryfication.
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument              | Man.  | Description                                                                                   |
    ...    +=======================+=======+===============================================================================================+
    ...    | node_id               | Yes   | current bts id                                                                                |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | expected_BTS_status   | No    | mrbts state to check, default OnAir                                                           |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | HW_check              | No    | HW check switch, default ${TRUE}                                                              |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | cells_check           | No    | cells check switch, default ${TRUE}                                                           |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | scf_check             | No    | scf check switch, default ${TRUE}                                                             |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | timeout               | No    | timoeut to wait for onair after sw update                                                     |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Logging With Timestamp
    ...    message=:::::::::: Initial state management check on BTS-${node_id} :::::::::::
    ...    logs_dir=${CFG.suite_logs_path}
    IF    not ${HW_check}
        Logging With Timestamp    message=HW check is skipped on user demand    logs_dir=${CFG.suite_logs_path}
    END
    IF    ${HW_check}
        ${SMODs_working}=    Run Keyword And Return Status
        ...    STATE Check Class States
        ...    class=SMOD
        ...    node_id=${node_id}
        ...    scf_check=${scf_check}
        ...    timeout=${timeout}
    ELSE
        ${SMODs_working}=    Set Variable    ${TRUE}
    END
    IF    ${HW_check}
        ${BBMODs_working}=    Run Keyword And Return Status
        ...    STATE Check Class States
        ...    class=BBMOD
        ...    node_id=${node_id}
        ...    scf_check=${scf_check}
        ...    timeout=${timeout}
    ELSE
        ${BBMODs_working}=    Set Variable    ${TRUE}
    END
    IF    ${HW_check}
        ${RMODs_working}=    Run Keyword And Return Status
        ...    STATE Check Class States
        ...    class=RMOD
        ...    node_id=${node_id}
        ...    scf_check=${scf_check}
        ...    timeout=${timeout}
    ELSE
        ${RMODs_working}=    Set Variable    ${TRUE}
    END
    IF    ${HW_check}
        ${ASIR_modules_working}=    Run Keyword And Return Status
        ...    STATE Check Class States
        ...    class=ASIRMOD
        ...    node_id=${node_id}
        ...    scf_check=${scf_check}
        ...    timeout=${timeout}
    ELSE
        ${ASIR_modules_working}=    Set Variable    ${TRUE}
    END
    IF    ${HW_check}
        ${FHS_modules_working}=    Run Keyword And Return Status
        ...    STATE Check Class States
        ...    class=FHS
        ...    node_id=${node_id}
        ...    scf_check=${scf_check}
        ...    timeout=${timeout}
    ELSE
        ${FHS_modules_working}=    Set Variable    ${TRUE}
    END
    IF    ${HW_check}
        ${ALDs_working}=    Run Keyword And Return Status
        ...    STATE Check Class States
        ...    class=ALD
        ...    node_id=${node_id}
        ...    scf_check=${scf_check}
        ...    timeout=${timeout}
    ELSE
        ${ALDs_working}=    Set Variable    ${TRUE}
    END
    ${CABLINKs_working}=    Set Variable    ${TRUE}
    ${SFPs_working}=    Set Variable    ${TRUE}
    ${GSM_TRX_onair}=    Set Variable    ${TRUE}
#    ${CABLINKs_working}=    Run Keyword If    ${HW_check}    Run Keyword And Return Status
#    ...    STATE Check Class States    class=CABLINK    node_id=${node_id}    scf_check=${FALSE}
#    ...    ELSE    Set Variable    ${TRUE}
#    ${SFPs_working}=    Run Keyword If    ${HW_check}    Run Keyword And Return Status
#    ...    STATE Check Class States    class=SFP    node_id=${node_id}    scf_check=${FALSE}
#    ...    ELSE    Set Variable    ${TRUE}
    IF    not ${cells_check}
        Logging With Timestamp    message=Cells check is skipped on user demand    logs_dir=${CFG.suite_logs_path}
    END
    IF    ${cells_check}
        ${cells_GSM_onair}=    Run Keyword And Return Status
        ...    STATE Check Class States
        ...    class=GNCEL
        ...    node_id=${node_id}
        ...    scf_check=${scf_check}
        ...    timeout=${timeout}
    ELSE
        ${cells_GSM_onair}=    Set Variable    ${TRUE}
    END
#    ${GSM_TRX_onair}=    Run Keyword If    ${cells_check}    Run Keyword And Return Status
#    ...    STATE Check Class States    class=CARRIERGROUPC    node_id=${node_id}    scf_check=${FALSE}
#    ...    ELSE    Set Variable    ${TRUE}
    IF    ${cells_check}
        ${cells_WCDMA_onair}=    Run Keyword And Return Status
        ...    STATE Check Class States
        ...    class=WNCEL
        ...    node_id=${node_id}
        ...    scf_check=${scf_check}
        ...    timeout=${timeout}
    ELSE
        ${cells_WCDMA_onair}=    Set Variable    ${TRUE}
    END
    IF    ${cells_check}
        ${cells_LTE_onair}=    Run Keyword And Return Status
        ...    STATE Check Class States
        ...    class=LNCEL
        ...    node_id=${node_id}
        ...    scf_check=${scf_check}
        ...    timeout=${timeout}
    ELSE
        ${cells_LTE_onair}=    Set Variable    ${TRUE}
    END
    IF    ${cells_check}
        ${cells_NR_onair}=    Run Keyword And Return Status
        ...    STATE Check Class States
        ...    class=NRCEL
        ...    node_id=${node_id}
        ...    scf_check=${scf_check}
        ...    timeout=${timeout}
    ELSE
        ${cells_NR_onair}=    Set Variable    ${TRUE}
    END
    IF    ${HW_check}
        ${BTS_status}=    Run Keyword And Return Status    STATE Verify BTS Procedural State    ${expected_BTS_status}    ${node_id}
    ELSE
        ${BTS_status}=    Set Variable    ${TRUE}
    END
    ${statuses_dictionary}=    Create Dictionary    BTS_status=${BTS_status}    SMODs_working=${SMODs_working}
    ...    BBMODs_working=${BBMODs_working}    RMODs_working=${RMODs_working}    ASIR_modules_working=${ASIR_modules_working}
    ...    FHS_modules_working=${FHS_modules_working}    ALDs_working=${ALDs_working}    CABLINKs_working=${CABLINKs_working}
    ...    SFPs_working=${SFPs_working}    cells_GSM_onair=${cells_GSM_onair}    cells_GSM_TRX_onair=${GSM_TRX_onair}
    ...    cells_WCDMA_onair=${cells_WCDMA_onair}    cells_LTE_onair=${cells_LTE_onair}    cells_NR_onair=${cells_NR_onair}
    ${pretty_statuses}=    Evaluate    pprint.pformat(${statuses_dictionary}, indent=4)    modules=pprint

    [Teardown]
    ${all_cells_onair}=    Evaluate
    ...    ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair} and ${cells_NR_onair} and ${GSM_TRX_onair}
    ${hw_modules_working}=    Evaluate
    ...    ${SMODs_working} and ${BBMODs_working} and ${RMODs_working} and ${ASIR_modules_working} and ${FHS_modules_working} and ${ALDs_working}
    IF    not (${BTS_status} and ${hw_modules_working} and ${all_cells_onair} and ${CABLINKs_working} and ${SFPs_working})
        Fail    Test failed due to failure of BTS initial check:${\n}${pretty_statuses}.${\n}Skip to teardown!
    END

STATE Verify Multi Node State
    [Arguments]    ${expected_BTS_status}=OnAir    ${HW_check}=${TRUE}    ${cells_check}=${TRUE}    ${scf_check}=${TRUE}    ${timeout}=60
    [Documentation]  KW for checking Onair states for all btses in tested configuration. HW_check disable/enable HW states check
    ...    SMOD|BBMOD|RMOD|ASIRMOD|FHS|ALD|SFP|CABLINK. cells_check disable/enadle cells states GNCEL|WNCEL|LNCEL|NRCEL|CARRIERGROUPC.
    ...    scf_check disable/enable scf object counting for SMOD|BBMOD|RMOD|ASIRMOD|FHS|ALD|GNCEL|WNCEL|LNCEL|NRCEL and Prod Code Veryfication.
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument              | Man.  | Description                                                                                   |
    ...    +=======================+=======+===============================================================================================+
    ...    | expected_BTS_status   | No    | mrbts state to check, default OnAir                                                           |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | HW_check              | No    | HW check switch, default ${TRUE}                                                              |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | cells_check           | No    | cells check switch, default ${TRUE}                                                           |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | scf_check             | No    | scf check switch, default ${TRUE}                                                             |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | timeout               | No    | timoeut to wait for onair after sw update                                                     |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${bts_id_list}=    Get Dictionary Keys    ${CFG.NODES}
    FOR    ${bts_id}    IN    @{bts_id_list}
        STATE Verify BTS states
        ...    node_id=${bts_id}
        ...    expected_BTS_status=${expected_BTS_status}
        ...    HW_check=${HW_check}
        ...    cells_check=${cells_check}
        ...    scf_check=${scf_check}
        ...    timeout=${timeout}
    END

STATE Verify Energy Efficiency On Every RU
    [Arguments]    ${bts_id}
    [Documentation]  KW checks if every RU on bts has correct powerState in case of AWAKE/SLEEP modes.
    ...  KW fails if AWAKE/SLEEP mode is wrongly displayed in runtime.
    ...  If any extensions of KW conditions are required please contact maintainer
    ...  +----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument             | Man.  | Description                                                                                   |
    ...  +======================+=======+===============================================================================================+
    ...  | bts_id               | Yes   | current bts id                                                                                |
    ...  +----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${rus}=    admin.get Frm    connection=${bts_id}    timeout=60
    FOR    ${ru_dict}    IN    @{rus}
        STATE Verify Energy Efficiency On RU    ru_dict=${ru_dict}    bts_id=${bts_id}
    END

STATE Verify Energy Efficiency On RU By Distname
    [Arguments]    ${bts_id}    ${ru_dn}
    [Documentation]  KW checks if desired RU on bts has correct powerState in case of AWAKE/SLEEP modes.
    ...  KW fails if AWAKE/SLEEP mode is wrongly displayed in runtime.
    ...  If any extensions of KW conditions are required please contact maintainer
    ...  +----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument             | Man.  | Description                                                                                   |
    ...  +======================+=======+===============================================================================================+
    ...  | bts_id               | Yes   | current bts id                                                                                |
    ...  +----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | ru_dn                | Yes   | runtime distname                                                                              |
    ...  +----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${rus}=    admin.Get Frm    connection=${bts_id}
    FOR    ${ru_dict}    IN    @{rus}
        IF    "${ru_dict['id']['internal']}"=="${ru_dn}"
            STATE Verify Energy Efficiency On RU    ru_dict=${ru_dict}    bts_id=${bts_id}
            RETURN
        END
    END
    Run Keywords    Logging With Timestamp
    ...    message=Energy Efficiency cannot be veryfied. ${ru_dn} not found on BTS-${bts_id}
    ...    style=FAIL
    ...    AND    Fail    Energy Efficiency cannot be verified. ${ru_dn} not found on BTS-${bts_id}

STATE Verify Energy Efficiency On RU
    [Arguments]    ${ru_dict}    ${bts_id}
    [Documentation]  KW checks if RU has correct powerState in case of AWAKE/SLEEP modes.
    ...  KW fails if AWAKE/SLEEP mode is wrongly displayed in runtime.
    ...  If any extensions of KW conditions are required please contact maintainer
    ...  +----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument             | Man.  | Description                                                                                   |
    ...  +======================+=======+===============================================================================================+
    ...  | ru_dict              | Yes   | ru dict as an output from KW "Get Frm"                                                        |
    ...  +----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | bts_id               | Yes   | current bts id                                                                                |
    ...  +----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${ru_energy_mode_parameter}=    Create List    energySavingMode
    ${param_value}=    admin.Get Parameter By Distname
    ...    dist_name=${ru_dict['id']['configuration']}
    ...    parameter_list=${ru_energy_mode_parameter}    connection=${bts_id}
    ${ru_can_sleep}=    STATE Check If Radio Can Sleep    ${ru_dict['id']['internal']}    ${bts_id}
    ${deep_sleep_cond1}=    Set Variable    "${param_value[0]['parameters']['energySavingMode']}"!="DEEPSLEEP"
    ${usage_state_cond}=    Set Variable    "${ru_dict['status']['usageState']}"=="Active"
    ${power_state_status}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${ru_dict['status']}    powerState
    IF    not ${power_state_status}
        Logging With Timestamp
        ...    message=RU ${ru_dict['id']['runtime']} does not have 'powerState' parameter in runtime. Cannot verify energy efficiency on this RU.
        RETURN
    END
    IF    "${ru_dict['status']['powerState']}"=="SLEEP" and (${ru_can_sleep}==${FALSE} or ${deep_sleep_cond1} or ${usage_state_cond})
        Logging With Timestamp    message=RU ${ru_dict['id']['runtime']} has wrong Power State: ${ru_dict['status']['powerState']}    style=FAIL
        Fail    RU ${ru_dict['id']['runtime']} has wrong Power State: ${ru_dict['status']['powerState']}
    END
    ${deep_sleep_cond2}=    Set Variable    "${param_value[0]['parameters']['energySavingMode']}"=="DEEPSLEEP"
    IF    "${ru_dict['status']['powerState']}"=="AWAKE" and ${ru_can_sleep}==${TRUE} and ${deep_sleep_cond2}
        Logging With Timestamp    message=RU ${ru_dict['id']['runtime']} has wrong Power State: ${ru_dict['status']['powerState']}    style=FAIL
        Fail    RU ${ru_dict['id']['runtime']} has wrong Power State: ${ru_dict['status']['powerState']}
    END

STATE Check If Radio Can Sleep
    [Arguments]    ${ru_dn}    ${bts_id}
    [Documentation]  KW checks if conditions for SLEEP mode on RU are met.
    ...  KW returns TRUE if all cells on RU are locked or in energySaving state.
    ...  KW returns FALSE if both above conditions are not fulfilled.
    ...  If any extensions of KW are required please contact resource maintainer.
    ...  +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument              | Man.  | Description                                                                                   |
    ...  +=======================+=======+===============================================================================================+
    ...  | ru_dn                 | Yes   | ru runtime distname ex. /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-2    |
    ...  +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | bts_id                | Yes   | current bts id                                                                                |
    ...  +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${lock_statuses}=    Create List
    ${energy_saving_statuses}=    Create List
    ${ru_cells}=    admin.Get Cell Mapping By Module Id    module_id=${ru_dn}    connection=${bts_id}
    FOR    ${ru_cell}    IN    @{ru_cells}
        ${cell_info}=    admin.Get Cell Specific Info    cell_id=${ru_cell}    connection=${bts_id}
        ${cell_locked}=    Run Keyword And Return Status    Should Be True    "${cell_info['status']['administrativeState']}".lower()=="locked"
        ${energysaving_on_cell}=    Run Keyword And Return Status    Should Be True    "${cell_info['energySavingState']}".lower()=="energysaving"
        Append To List    ${lock_statuses}    ${cell_locked}
        Append To List    ${energy_saving_statuses}    ${energysaving_on_cell}
    END
    ${all_cells_locked}=    Run Keyword And Return Status    List Should Not Contain Value    ${lock_statuses}    ${FALSE}
    ${all_cells_in energy_saving}=    Run Keyword And Return Status    List Should Not Contain Value    ${energy_saving_statuses}    ${FALSE}
    ${ru_can_sleep}=    Evaluate    ${all_cells_locked} or ${all_cells_in energy_saving}
    RETURN    ${ru_can_sleep}

STATE Check If All Cells Are OnAir
    [Documentation]
    ...  KW checks if all cells on BTS are onAir.
    ...  Default timeout is set to 10 second
    ...
    ...  +------------------+------+---------------------------------------------------------------------------------------------------+
    ...  | Argument         | Man. | Description                                                                                        |
    ...  +==================+======+===================================================================================================+
    ...  | bts_id           | No   |  BTS ID (default: 'default')                                                                      |
    ...  +------------------+------+---------------------------------------------------------------------------------------------------+
    ...  | timeout          | No   |  Timeout in seconds for the check (default: 10)                                                   |
    ...  +------------------+------+---------------------------------------------------------------------------------------------------+
    ...
    ...  **Author:** mateusz.kawka@nokia.com
    ...  **Maintainer**: mateusz.kawka@nokia.com

    [Arguments]    ${bts_id}=default    ${timeout}=10

    ${gncel_list}=    admin.Get Ids For All    GNCEL    connection=${bts_id}    timeout=${BASIC_ADMIN_PROCEDURES_TIMEOUT}
    ${wncel_list}=    admin.Get Ids For All    WNCEL    connection=${bts_id}    timeout=${BASIC_ADMIN_PROCEDURES_TIMEOUT}
    ${lncel_list}=    admin.Get Ids For All
    ...    LNCEL
    ...    connection=${bts_id}
    ...    timeout=${BASIC_ADMIN_PROCEDURES_TIMEOUT}
    ...    search_for_iot_cells=${True}
    ${nrcel_list}=    admin.Get Ids For All    NRCEL    connection=${bts_id}    timeout=${BASIC_ADMIN_PROCEDURES_TIMEOUT}

    IF    len(${lncel_list})!=0
        Run Keyword And Continue On Failure
        ...    STATE Check If All Cells For RAT Are OnAir    LTE    ${timeout}    ${bts_id}
    END

    IF    len(${nrcel_list})!=0
        Run Keyword And Continue On Failure
        ...    STATE Check If All Cells For RAT Are OnAir    NR    ${timeout}    ${bts_id}
    END

    IF    len(${wncel_list})!=0
        Run Keyword And Continue On Failure
        ...    STATE Check If All Cells For RAT Are OnAir    WCDMA    ${timeout}    ${bts_id}
    END

    IF    len(${gncel_list})!=0
        Run Keyword And Continue On Failure
        ...    STATE Check If All Cells For RAT Are OnAir    GSM    ${timeout}    ${bts_id}
    END

STATE Check If Cell Is OnAir
    [Documentation]
    ...  KW checks if cell with runtime_id on BTS are onAir.
    ...  Default timeout is set to 10 second
    ...
    ...  +------------------+------+---------------------------------------------------------------------------------------------------+
    ...  | Argument         | Man. | Description                                                                                        |
    ...  +==================+======+===================================================================================================+
    ...  | rat              | Yes  |  Radio Access Technology (RAT) of the cell, e.g. GSM, WCDMA, LTE, NR                              |
    ...  +------------------+------+---------------------------------------------------------------------------------------------------+
    ...  | id               | Yes  |  Runtime ID of the cell                                                                           |
    ...  +------------------+------+---------------------------------------------------------------------------------------------------+
    ...  | timeout          | No   |  Timeout in seconds for the check (default: 10)                                                   |
    ...  +------------------+------+---------------------------------------------------------------------------------------------------+
    ...  | bts_id           | No   |  BTS ID (default: 'default')                                                                      |
    ...  +------------------+------+---------------------------------------------------------------------------------------------------+
    ...
    ...  Author: mateusz.kawka@nokia.com
    ...  Maintainer: mateusz.kawka@nokia.com

    [Arguments]    ${rat}    ${id}    ${timeout}=10    ${bts_id}=default

    IF    '${rat}'=='GSM'
        admin.Assert    GNCEL    ${id}    ${GNCEL_onair_states}    timeout=${timeout}    connection=${bts_id}
        STATE Assert No For Specified Cell    GNCEL    ${id}    availabilityStatus(.*)[Dd]egraded    ${bts_id}
    ELSE IF    '${rat}'=='WCDMA'
        admin.Assert    WNCEL    ${id}    ${WNCEL_onair_states}    timeout=${timeout}    connection=${bts_id}
        STATE Assert No For Specified Cell    WNCEL    ${id}    availabilityStatus(.*)[Dd]egraded    ${bts_id}
    ELSE IF    '${rat}'=='LTE'
        admin.Assert    LNCEL    ${id}    ${LNCEL_onair_states}    search_for_iot_cells=${True}    timeout=${timeout}    connection=${bts_id}
        STATE Assert No For Specified Cell    LNCEL    ${id}    availabilityStatus(.*)[Dd]egraded    ${bts_id}
    ELSE IF    '${rat}'=='NR'
        admin.Assert    NRCEL    ${id}    ${NRCEL_onair_states}    timeout=${timeout}    connection=${bts_id}
        STATE Assert No For Specified Cell    NRCEL    ${id}    availabilityStatus(.*)[Dd]egraded    ${bts_id}
    ELSE
        Fail    Unsupported RAT: ${rat}
    END

STATE Assert No For Specified Cell
    [Documentation]
    ...  Description:
    ...  KW checks if specified cell doesn't contain a parameter with value given by regex
    ...  KW passes if parameters dict doesn't match regex
    ...
    ...  +----------+------+---------------------------------------------------------------+
    ...  | Argument | Man. | Description                                                   |
    ...  +==========+======+===============================================================+
    ...  | rat      | Yes  | Radio Access Technology (e.g., LTE, GSM)                      |
    ...  +----------+------+---------------------------------------------------------------+
    ...  | id       | Yes  | Identifier of the cell                                        |
    ...  +----------+------+---------------------------------------------------------------+
    ...  | regex    | Yes  | Regular expression to match against the parameters            |
    ...  +----------+------+---------------------------------------------------------------+
    ...  | bts_id   | No   | BTS ID, default is 'default'                                  |
    ...  +----------+------+---------------------------------------------------------------+
    ...
    ...  Author: mateusz.kawka@nokia.com
    ...  Maintainer: mateusz.kawka@nokia.com

    [Arguments]    ${rat}    ${id}    ${regex}    ${bts_id}=default

    ${params}=    admin.Get Parameters For    ${rat}    ${id}    connection=${bts_id}
    Should Not Match Regexp    str(${params})    ${regex}

STATE Check If All Cells For RAT Are OnAir
    [Documentation]
    ...  Description:
    ...  KW checks if cells for RAT are onAir.
    ...  Default timeout is set to 10 seconds
    ...
    ...  +----------+------+---------------------------------------------------------------+
    ...  | Argument | Man. | Description                                                   |
    ...  +==========+======+===============================================================+
    ...  | rat      | Yes  | Radio Access Technology (e.g., GSM, WCDMA, LTE, NR)           |
    ...  +----------+------+---------------------------------------------------------------+
    ...  | timeout  | No   | Timeout in seconds, default is 10                             |
    ...  +----------+------+---------------------------------------------------------------+
    ...  | bts_id   | No   | BTS ID, default is 'default'                                  |
    ...  +----------+------+---------------------------------------------------------------+
    ...
    ...  Author: mateusz.kawka@nokia.com
    ...  Maintainer: mateusz.kawka@nokia.com

    [Arguments]    ${rat}    ${timeout}=10    ${bts_id}=default

    IF    '${rat}'=='GSM'
        admin.Assert Every    GNCEL    ${GNCEL_onair_states}    timeout=${timeout}    connection=${bts_id}
        admin.Assert No    GNCEL    availabilityStatus=regex"[Dd]egraded"    timeout=${timeout}    connection=${bts_id}
    ELSE IF    '${rat}'=='WCDMA'
        admin.Assert Every    WNCEL    ${WNCEL_onair_states}    timeout=${timeout}    connection=${bts_id}
        admin.Assert No    WNCEL    availabilityStatus=regex"[Dd]egraded"    timeout=${timeout}    connection=${bts_id}
    ELSE IF    '${rat}'=='LTE'
        admin.Assert Every    LNCEL    ${LNCEL_onair_states}    search_for_iot_cells=${True}    timeout=${timeout}    connection=${bts_id}
        admin.Assert No
        ...    LNCEL
        ...    availabilityStatus=regex"[Dd]egraded"
        ...    search_for_iot_cells=${True}
        ...    timeout=${timeout}
        ...    connection=${bts_id}
    ELSE IF    '${rat}'=='NR'
        admin.Assert Every    NRCEL    ${NRCEL_onair_states}    timeout=${timeout}    connection=${bts_id}
        admin.Assert No    NRCEL    availabilityStatus=regex"[Dd]egraded"    timeout=${timeout}    connection=${bts_id}
    ELSE
        Fail    Unsupported RAT: ${rat}
    END

STATE BTS Address Is Pingable
    [Documentation]
    ...  Description:
    ...  KW pings provided IP and fails if not succeeded
    ...  You can use it this way to wait for PING:
    ...  STATE BTS Address Is Pingable  host_ip_addr=192.168.255.1  timeout=180s  bts_id=1050
    ...
    ...  +----------+------+---------------------------------------------------------------+
    ...  | Argument     | Man. | Description                                               |
    ...  +==========+======+===============================================================+
    ...  | host_ip_addr | No   | IP address to ping, default: 192.168.255.1                |
    ...  +----------+------+---------------------------------------------------------------+
    ...  | timeout      | No   | Timeout in seconds, default: 180 s                        |
    ...  +----------+------+---------------------------------------------------------------+
    ...  | bts_id       | No   | BTS ID, default: default                                  |
    ...  +----------+------+---------------------------------------------------------------+
    ...
    ...  Author: patryk.niewiejski@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    [Arguments]    ${host_ip_addr}=192.168.255.1    ${timeout}=180    ${bts_id}=default
    ${ip_for_ping}=    Create List    ${host_ip_addr}
    ${remote_host}=    Set Variable If    "${cfg['NODES']['${bts_id}']['bts_alias_type']}"=="localhost"    None
    ...    ${cfg['NODES']['${bts_id}']['vm_ip_LMP_address']}
    ping.Wait For Ping
    ...    ${ip_for_ping}
    ...    timeout=${timeout}
    ...    remote_host_ip=${remote_host}
    ...    remote_host_username=ute
    ...    remote_host_password=ute

STATE BTS Address Is NOT Pingable
    [Documentation]
    ...  Description:
    ...  KW pings provided IP and fails if not succeeded
    ...  You can use it this way to wait for NO PING:
    ...  STATE BTS Address Is NOT Pingable  host_ip_addr=192.168.255.1  timeout=180s  bts_id=1050
    ...
    ...  +----------+------+---------------------------------------------------------------+
    ...  | Argument     | Man. | Description                                               |
    ...  +==========+======+===============================================================+
    ...  | host_ip_addr | No   | IP address to ping, default: 192.168.255.1                |
    ...  +----------+------+---------------------------------------------------------------+
    ...  | timeout      | No   | Timeout in seconds, default: 180 s                        |
    ...  +----------+------+---------------------------------------------------------------+
    ...  | bts_id       | No   | BTS ID, default: default                                  |
    ...  +----------+------+---------------------------------------------------------------+
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    [Arguments]    ${host_ip_addr}=192.168.255.1    ${timeout}=180    ${bts_id}=default
    ${ip_for_ping}=    Create List    ${host_ip_addr}
    ${remote_host}=    Set Variable If    "${cfg['NODES']['${bts_id}']['bts_alias_type']}"=="localhost"    None
    ...    ${cfg['NODES']['${bts_id}']['vm_ip_LMP_address']}
    ping.Wait For No Ping
    ...    ${ip_for_ping}
    ...    timeout=${timeout}
    ...    remote_host_ip=${remote_host}
    ...    remote_host_username=ute
    ...    remote_host_password=ute

STATE Check AvailabilityStatus Is OnAir
    [Arguments]    ${class}    ${node_id}    ${distname}
    [Documentation]
    ...  Description:
    ...  KW uses dictionary with states got from current admin readout and checks if availability is OnAir
    ...
    ...  +----------+------+---------------------------------------------------------------------+
    ...  | Argument     | Man. | Description                                                     |
    ...  +==========+======+=====================================================================+
    ...  | class              | Yes   | Class name for which states should be checked, ex. SMOD  |
    ...  +--------------------+-------+----------------------------------------------------------+
    ...  | node_id            | Yes   | BTS_ID used as alias                                     |
    ...  +--------------------+-------+----------------------------------------------------------+
    ...  | distname           | Yes   | Runtime distname for check                               |
    ...  +--------------------+------+-----------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${param_output}=    admin.Get Parameters For    class_name=${class}    id_num=${distname}    connection=${node_id}
    Dictionary Should Not Contain Key    ${param_output}    availabilityStatus
