*** Settings ***
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    bts_alarms.py
Resource   infomodel.robot

*** Variables ***
&{SIMPLIFIED_ALARM}     severity=${NONE}  faultId=${NONE}  faultName=${NONE}  notifier=${NONE}  number=${NONE}

*** Keywords ***
Get BTS Procedural State
    [Documentation]
    ...  Return BTS proceduralState Info
    ...
    ...  *AUTHOR*
    ...  mateusz.majkusiak@nokia.com

    ${bts_state}    coam.Get Bts Statuses
    ${bts_procedural_state}    Set Variable  ${bts_state['proceduralState']}
    ${bts_procedural_state}    Convert To String    ${bts_procedural_state}
    ${bts_procedural_state}    Set Test Variable    ${bts_procedural_state}

    [Return]  ${bts_procedural_state}

Get BTS ID
    [Documentation]
    ...  Return BTS id in string format
    ...
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    ${bts_info}    coam.Get Bts Info
    ${bts_id}    Set Variable  ${bts_info['mrbtsID']}
    ${bts_id}    Convert To String    ${bts_id}
    
    [Return]  ${bts_id}

Get BTS Name
    [Documentation]
    ...  Return BTS name
    ...
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    ${bts_info}    coam.Get Bts Info
    ${bts_name}    Set Variable  ${bts_info['name']}

    [Return]  ${bts_name}

Get BTS Mplane
    [Documentation]
    ...  Return BTS mplane in string format
    ...
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    ${bts_obj}=    coam.Get Parameters For All  BTS
    ${bts_mplane}    Convert To String  ${bts_obj[0]['btsMplaneIp4V']}

    [Return]  ${bts_mplane}

Get Modules For Interfaces
    [Documentation]
    ...  Return list of modules types and serial numbers
    ...
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    ${smod_param}    coam.Get Parameters For All    SMOD
    ${rmod_param}    coam.Get Parameters For All    RMOD

    @{serial_number_list}=    Create List

    FOR  ${mod}  IN  @{smod_param}
        Append To List  ${serial_number_list}  SMOD_${mod.serialNumber}
    END
    FOR  ${mod}  IN  @{rmod_param}
        Append To List  ${serial_number_list}  RMOD_${mod.serialNumber}
    END

    [Return]  ${serial_number_list}

Check Cells Number
    [Documentation]    Check if number cells detected by admin is as expected
    ...  *AUTHOR*
    ...  michal.kwasniewicz@nokia.com
    ...
    ...  | Parameter              | Mandatory     | Description                           |
    ...  | technology             | Yes           | Cell ID e.g: LNCEL, GNCEL or WNCEL    |
    ...  | expectted_cells_number | Yes           | Expected cells number                 |

    [Arguments]    ${technology}    ${expected_cells_number}
    Run keyword if  ${expected_cells_number}==-1  Run keywords
    ...  Log  ${technology} will be ignored for active software  console=${True}
    ...  AND  Return from keyword  ${True}
    ${id_list}=    coam.Get Ids For All    ${technology}
    ${admin_cells_num}=    Evaluate    len(${id_list})
    Should Be Equal As Integers    ${expected_cells_number}    ${admin_cells_num}
    ...    Admin see different cells number than expected! Expected: ${expected_cells_number} is not equal admin cells num: ${admin_cells_num}.

Check Active Alarms
    [Documentation]
    ...  Alarms checking based on Admin. Fails if any expected alarm is missing or any critical alarm occurred.
    ...  If collect_snapshot is set to True, snapshot is collected when active alarms are detected.
    ...  If ${print_alarms} is set to True, KW will print lists of alarms with level:
    ...  - ERROR - missed expected or found unexpected criticals
    ...  - INFO - found expected and ignored
    ...  - WARN - all other
    ...
    ...  | Parameter            | Man.  | Default | Description |
    ...  | alias                | No    | default | alias of coam instance |
    ...  | expected_patterns    | No    | empty   | List of expected alarms regex patterns, one for each expected alarm |
    ...  | ignored_patterns     | No    | empty   | List of ignored alarms regex patterns, will be used multiply  |
    ...  | critical_patterns    | No    | empty   | List of critical alarms regex patterns, will be used multiply  |
    ...  | timeout              | No    | 90      | Timeout in seconds to wait for getting alarms from Admin |
    ...  | print_alarms         | No    | true    | Boolean to decide whether output lists should be printed with proper level |
    ...  | collect_snapshot     | No    | False   | collect snapshot if active alarms exist |
    ...
    ...  Each key from alarm dictionary can be used for comparison, but only the following are printed:
    ...  faultName, faultId, severity, notifier (can be re-defined using &{SIMPLIFIED_ALARM})
    ...
    ...  1.  Example of KW used without any defined list - will always pass and print WARN if any alarm is found:
    ...  Admin Check Active Alarms
    ...
    ...  2. Example of KW used with one expected alarm definition - will fail if this alarm does not occur,
    ...  any other will be printed with WARN level:
    ...  ${EXPECTED_ALARM1}=     Create Dictionary  faultId=49  notifier=/MRBTS-1/RAT-1/LTS-1/LNBTS_L-1/LNCEL_L-10660
    ...  ${EXPECTED}=            Create List  ${EXPECTED_ALARM1}
    ...  Admin Check Active Alarms  expected_patterns=${EXPECTED}
    ...
    ...  3. Example of KW used with one expected and one critical alarm definition - will fail if expected alarm does not occur,
    ...  or any other alarm with faultID=49 occur, any other will be printed with WARN level:
    ...  ${EXPECTED_ALARM1}=     Create Dictionary  faultId=49  notifier=/MRBTS-1/RAT-1/LTS-1/LNBTS_L-1/LNCEL_L-10660
    ...  ${EXPECTED}=            Create List  ${EXPECTED_ALARM1}
    ...  ${CRITICAL_ALARM1}=     Create Dictionary  faultId=49
    ...  ${CRITICAL}=            Create List  ${CRITICAL_ALARM1}
    ...  Admin Check Active Alarms  expected_patterns=${EXPECTED}  critical_patterns=${CRITICAL}
    ...
    [Arguments]  ${alias}=default  ${expected_patterns}=@{EMPTY}  ${ignored_patterns}=@{EMPTY}
    ...  ${critical_patterns}=@{EMPTY}  ${timeout}=90  ${print_alarms}=${TRUE}  ${collect_snapshot}=${FALSE}

    ${globally_ignored_alarms}=  get variable value  ${GLOBALLY_IGNORED_ALARMS}  @{EMPTY}
    Append to list  ${ignored_patterns}  @{globally_ignored_alarms}
    ${active_alarms}=  coam.Get Active Alarms  timeout=${timeout}  alias=${alias}
    Run Keyword If  not ${active_alarms}  Log  No active alarms have been found.  console=${True}
    ${found expected alarms}  ${not found expected alarms patterns}  ${found critical alarms}  ${found ignored alarms}
    ...  ${found not classified alarms}=  bts_alarms.Get Filtered Alarms  ${active_alarms}
    ...  ${expected_patterns}  ${ignored_patterns}  ${critical_patterns}  ${SIMPLIFIED_ALARM}
    Run Keyword If  ${print_alarms}  bts_alarms.Print Alarms  ${found expected alarms}
    ...  ${not found expected alarms patterns}  ${found critical alarms}  ${found ignored alarms}
    ...  ${found not classified alarms}  simplified_dictionary=${SIMPLIFIED_ALARM}
    Run Keyword If  ${not found expected alarms patterns} or ${found critical alarms}  Fail  Alarm verification failed
    Run keyword if  ${collect_snapshot} and (${not found expected alarms patterns} or ${found critical alarms} or ${found not classified alarms})
    ...  coam.Collect Snapshot
    [Return]  ${found not classified alarms}

Check If Admin CLI Feature Check Is Enabled
    [Documentation]  This keyword check if Admin CLI feature is enabled if no, this keyword enable this feature.
    ...
    ...  | **Author:** artur.juszczak@nokia.com
    ...
    ...  | **Full description:**
    ...  | This keyword check if Admin CLI feature is enabled if no, this keyword enable this feature.
    ...  | Feature is enabled via set to true parameter actCli under FEATCADM.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...  | Parameter                     | Man. | Description                                                         |
    ...  +===============================+======+=====================================================================+
    ...  | skip_parameter_relation_errors| No   | This parameter allow or not to skip relation errors, default='False'|
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...
    ...     Check If Admin CLI Feature Check Is Enabled  True
    ...
    [Arguments]  ${skip_parameter_relation_errors}=False
    ${actCli}=    infomodel.Infomodel Get Objects Parameter    //MNL_A-*/MNLENT_A-*/FEATCADM_A-*    actCli   allow_negative_result=${True}
    Log  Parameter actCli is set as ${actCli[0]}  console=${True}
    Run Keyword Unless    ${actCli[0]}  Run Keywords
    ...  Log  Setting parameter actCli to "True"  console=${True}
    ...  AND  _Change actCli To True  ${skip_parameter_relation_errors}

_Change actCli To True
    [Arguments]  ${skip_parameter_relation_errors}
    ${bts_id}=  bts_states.Get BTS ID
    coam.Perform Parameter Recommissioning
    ...  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1  actCli  update   true  skip_parameter_relation_errors=${skip_parameter_relation_errors}
