*** Settings ***
Documentation     [PURPOSE] COMPA TCs - keywords to check bts states in other technologies
Library           OperatingSystem
Library           lib/AlarmAnalysis.py
Library           ute_btssm
Resource          ca_swm_general.robot
Resource          ca_swm_rescue_console.robot
Resource          hran_btssm.robot
Resource          hran_admin.robot
Resource          hran_general.robot


*** Variable ***
&{SIMPLIFIED_SBTS16_ALARM}  faultId=${NONE}  number=${NONE}  severity=${NONE}  text=${NONE}  faultSource=${NONE}
&{SIMPLIFIED_BTSSM_ALARM}   faultId=${NONE}  severity=${NONE}  description=${NONE}  source=${NONE}


*** Keywords ***
Check modules in bim
    [Documentation]
    ...     Verifies if all important modules states has proper states
    ...     *PRODUCT*  SBTS16
    ...     *AUTHOR*   sebastian.burniak@nokia.com
    [Arguments]  ${print}=${TRUE}
    ${frm_status}=      Rest read frm status    uri=/mz/p/v1/pbts/1
    ${fsm_status}=      Rest read fsm status    uri=/mz/p/v1/pbts/1
    ${status_verdict}=  hran_compa.Parse modules status    ${frm_status}    ${fsm_status}
    Run keyword if    ${status_verdict}    Log    All modules working    console=${print}
    ...       ELSE    Fail    msg=NOT all modules working properly

Check cells in bim
    [Documentation]
    ...     Verifies if all cells has proprer states
    ...     *PRODUCT*  SBTS16
    ...     *AUTHOR*   sebastian.burniak@nokia.com
    [Arguments]  ${print}=${TRUE}
    ${cells_id}=  REST read all cell ids    uri=/mz/p/v1/pbts/1
    FOR  ${cell_id}  IN  @{cells_id}
        ${cell_status}=  REST read cell status  ${cell_id}    uri=/mz/p/v1/pbts/1
        Run keyword if  '&{cell_status}[availabilityStatus]'!='online' and '&{cell_status}[operationalState]'!='enabled'
        ...  Fail    msg=Cell ${cell_id} NOT working properly
        ...  ELSE
        ...  Log
        ...  Cell ${cell_id}|availabilityStatus:&{cell_status}|operationalState:&{cell_status}[operationalState]
        ...  level=DEBUG
    END
    Log    All cells working    console=${print}

Check alarms in bim
    [Documentation]
    ...     Verifies if no active alarms presents
    ...     *PRODUCT*  SBTS16
    ...     *AUTHOR*   sebastian.burniak@nokia.com
    ${alarms_dict}=    Rest read active alarm SBTS16
    Run keyword if    ${alarms_dict}=={}    Log    Lack of active alarms    console=${TRUE}
    ...       ELSE    Fail    msg=Active alarms occured ${alarms_dict}

BTS procedural status should be configured
    [Documentation]
    ...     Check via REST if BTS procedural_status==configured, if not, keyword will fail.
    ...     For best performance use this keyword with builtin kw `Wait Until Keyword Succeeds`
    ...     *PRODUCT*  SBTS16
    ...     *AUTHOR*   jaroslaw.piszczala@nokia.com
    ...
    ${procedural_status}=  REST get parameter for given uri  uri=/mz/p/v1/pbts/1  parameter=proceduralStatus
    Run keyword if  '${procedural_status}'!='configured'  Fail
    ...  BTS procedural status==${procedural_status} (should be configured)

Check SBTS16 Alarms
    [Documentation]
    ...  Alarms checking based on Rest. Fails if any expected alarm is missing or any critical alarm occurred.
    ...  If ${print_alarms} is set to True, KW will print lists of alarms with level:
    ...  - ERROR - missed expected or found unexpected criticals
    ...  - INFO - found expected and ignored
    ...  - WARN - all other
    ...
    ...  | Parameter            | Man.  | Default | Description |
    ...  | expected_patterns    | No    | empty   | List of expected alarms regex patterns, one for each expected alarm|
    ...  | ignored_patterns     | No    | empty   | List of ignored alarms regex patterns, will be used multiply  |
    ...  | critical_patterns    | No    | empty   | List of critical alarms regex patterns, will be used multiply  |
    ...  | print_alarms         | No | true| Boolean to decide whether output lists should be printed with proper level|
    ...
    ...  Each key from alarm dictionary can be used for comparison, but only the following are printed:
    ...  faultName, faultId, severity, notifier (can be re-defined using &{SIMPLIFIED_SBTS16_ALARM})
    ...
    ...  1.  Example of KW used without any defined list - will always pass and print WARN if any alarm is found:
    ...  Check SBTS16 Alarms
    ...
    ...  2. Example of KW used with one expected alarm definition - will fail if this alarm does not occur,
    ...  any other will be printed with WARN level:
    ...  ${EXPECTED_ALARM1}=     Create Dictionary  faultId=49  severity=2
    ...  ${EXPECTED}=            Create List  ${EXPECTED_ALARM1}
    ...  Check SBTS16 Alarms  expected_patterns=${EXPECTED}
    ...
    ...  3. Example of KW used with one expected and one critical alarm definition -
    ...  will fail if expected alarm does not occur,
    ...  or any other alarm with faultID=49 occur, any other will be printed with WARN level:
    ...  ${EXPECTED_ALARM1}=     Create Dictionary  faultId=49  severity=2
    ...  ${EXPECTED}=            Create List  ${EXPECTED_ALARM1}
    ...  ${CRITICAL_ALARM1}=     Create Dictionary  faultId=49
    ...  ${CRITICAL}=            Create List  ${CRITICAL_ALARM1}
    ...  Check SBTS16 Alarms  expected_patterns=${EXPECTED}  critical_patterns=${CRITICAL}
    ...
    ...  4. Example of KW used to set test verdict and fail if major|critical alarm exist
    ...  ${CRITICAL_ALARM}=      Create dictionary  severity=2|3
    ...  ${CRITICAL}=            Create list  ${CRITICAL_ALARM}
    ...  ${status}  ${alarms_msg}=  Run keyword and ignore error  Check SBTS16 Alarms  critical_patterns=${CRITICAL}
    ...  Run keyword if  '${status}'=='FAIL'   Set Test Failed    Critical fail while checking alarms: ${alarms_msg}
    ...  ...  ELSE IF  ${alarms_msg}  Set Test Restriction        Unexpected alarms are present: ${alarms_msg}
    ...
    ...     *PRODUCT*  SBTS16
    ...     *AUTHOR*   jaroslaw.piszczala@nokia.com
    [Arguments]  ${expected_patterns}=@{EMPTY}  ${ignored_patterns}=@{EMPTY}
    ...  ${critical_patterns}=@{EMPTY}  ${print_alarms}=${TRUE}
    ${active_alarms}=  REST get value from bim  fsm/*/faultManagement/activeAlarms
    Run Keyword If  not ${active_alarms}  Log  No active alarms have been found.  console=${TRUE}
    ${found expected alarms}  ${not found expected alarms patterns}  ${found critical alarms}  ${found ignored alarms}
    ...  ${found not classified alarms}=  AlarmAnalysis.Get Filtered Alarms  ${active_alarms}
    ...  ${expected_patterns}  ${ignored_patterns}  ${critical_patterns}  ${SIMPLIFIED_SBTS16_ALARM}
    Run Keyword If  ${print_alarms}  AlarmAnalysis.Print Alarms  ${found expected alarms}
    ...  ${not found expected alarms patterns}  ${found critical alarms}  ${found ignored alarms}
    ...  ${found not classified alarms}  simplified_dictionary=${SIMPLIFIED_SBTS16_ALARM}
    Run Keyword If  ${not found expected alarms patterns} or ${found critical alarms}  Fail  Alarm verification failed
    [Return]  ${found not classified alarms}

#Check BTSSM Alarms
#    [Documentation]
#    ...  Alarms checking based on BTSSM. Fails if any expected alarm is missing or any critical alarm occurred.
#    ...  If ${print_alarms} is set to True, KW will print lists of alarms with level:
#    ...  - ERROR - missed expected or found unexpected criticals
#    ...  - INFO - found expected and ignored
#    ...  - WARN - all other
#    ...
#    ...  | Parameter            | Man.  | Default | Description |
#    ...  | expected_patterns    | No    | empty | List of expected alarms regex patterns, one for each expected alarm |
#    ...  | ignored_patterns     | No    | empty | List of ignored alarms regex patterns, will be used multiply  |
#    ...  | critical_patterns    | No    | empty   | List of critical alarms regex patterns, will be used multiply  |
#    ...  | print_alarms      | No| true| Boolean to decide whether output lists should be printed with proper level |
#    ...  | alias                | No    | MSM     | BTSSM alias |
#    ...
#    ...  The keyword name and arguments work as in`Check SBTS16 Alarms`. See `Check SBTS16 Alarms` for a usage example.
#    ...
#    ...     *PRODUCT*  LTE, WCDMA
#    ...     *AUTHOR*   jaroslaw.piszczala@nokia.com
#    [Arguments]  ${expected_patterns}=@{EMPTY}  ${ignored_patterns}=@{EMPTY}
#    ...  ${critical_patterns}=@{EMPTY}  ${print_alarms}=${TRUE}  ${alias}=MSM
#    ${result_files}=  ute_btssm.Get Active Alarms  alias=${alias}
#    Copy File  ${result_files[-1]}  ${Test Files}/
#    ${content}=  OperatingSystem.Get File  ${result_files[-1]}
#    ${active_alarms}=  hran_alarms_analysis.Get BTSSM Alarms From File  alarm_file=${content}
#    Run Keyword If  not ${active_alarms}  Log  No active alarms have been found.  console=${TRUE}
#    ${found expected alarms}  ${not found expected alarms patterns}  ${found critical alarms}  ${found ignored alarms}
#    ...  ${found not classified alarms}=  hran_alarms_analysis.Get Filtered Alarms  ${active_alarms}
#    ...  ${expected_patterns}  ${ignored_patterns}  ${critical_patterns}  ${SIMPLIFIED_BTSSM_ALARM}
#    Run Keyword If  ${print_alarms}  hran_alarms_analysis.Print Alarms  ${found expected alarms}
#    ...  ${not found expected alarms patterns}  ${found critical alarms}  ${found ignored alarms}
#    ...  ${found not classified alarms}  simplified_dictionary=${SIMPLIFIED_BTSSM_ALARM}
#    Run Keyword If  ${not found expected alarms patterns} or ${found critical alarms}  Fail  Alarm verification failed
#    [Return]  ${found not classified alarms}

Catch first ping after reset and create Timestamp
    [Documentation]
    ...  Keyword checks of ping is succesful and creates test variable ping_regained_time.
    ...  Value of the variable will be ${False} if ping fails and timestamp if it is succesful.
    ...  Keyword also returns ${True} / ${False}, depending on ping outcome.
    ...
    ...  | Parameter    | Man.  | Default              | Description |
    ...  | bts_host     | No    | ${SMOD1['TRS_IP']}   | IP to be pinged |
    ...
    ...     *PRODUCT*       any
    ...     *AUTHOR*        agata.maslowska@nokia.com
    ...     *MAINTAINER*    jaroslaw.piszczala@nokia.com

    [Arguments]  ${bts_host}=${SMOD1['TRS_IP']}
    Log  Will now check if bts ping is restored  console=True
    ${ping regained check}  ${ping regained output}  Run keyword and ignore error
    ...  Wait for target to be reachable  hostname=${bts_host}  timeout=3
    Run keyword if  '${ping regained check}'=='FAIL'  Run keywords
    ...  Set Test Variable  ${ping_regained_time}   ${False}
    ...  AND  Return from keyword  ${False}
    ${ping_regained_time_local}=  get time
    Run keyword if  '${ping_regained_time}'=='${False}'
    ...  Set test variable  ${ping_regained_time}  ${ping_regained_time_local}
    [Return]  ${True}

Setup Admin and create Timestamp
    [Documentation]
    ...  Keyword performs Admin setup. If action possible, test variable 'admin_started' is being set to ${True},
    ...  and 'admin_setup_time' is created with a timestamp value
    ...  Keyword also returns ${True} / ${False}, depending on setup outcome
    ...
    ...  | Parameter | Man.  | Default            | Description                 |
    ...  | bts_host  | No    | ${SMOD1['TRS_IP']} | IP to to connect with admin |
    ...  | bts_port  | No    | 443                | Port to connect with admin  |
    ...
    ...     *PRODUCT*       SOAM
    ...     *AUTHOR*        agata.maslowska@nokia.com
    ...     *MAINTAINER*    jaroslaw.piszczala@nokia.com

    [Arguments]  ${bts_host}=${SMOD1['TRS_IP']}  ${bts_port}=443
    Log  Trying to connect to admin (max 5 min)   level=INFO  console=${TRUE}
    ${admin setup status}  ${admin setup response}  Run keyword and ignore error
    ...    taf.sbts.oam.coam.admin.Setup Admin
    ...  bts_host=${bts_host}  bts_port=${bts_port}  use_ssl=True  admin_api_log_dir=${BTSFiles}/  timeout=300
    Return from keyword if  '${admin setup status}'=='FAIL'  ${False}
    ${admin_setup_time}=  get time
    set test variable  ${admin_setup_time}
    Set Test Variable  ${admin_started}  ${True}
    [Return]  ${True}

BTS up check
    [Documentation]
    ...  Keyword checks if BTS is up after reset, where by 'up' it is meant:
    ...     1. Ping is regained
    ...     2. Admin Setup is possible
    ...     3. Stable ping of 360 s is acchieved
    ...     4. admin_infomodel connection is also created, but its failure has no bearing on the keyword result
    ...
    ...     Keyword also returns ${True} / ${False}, depending on the outcome
    ...
    ...     *PRODUCT*       SOAM
    ...     *AUTHOR*        agata.maslowska@nokia.com
    ...     *MAINTAINER*    jaroslaw.piszczala@nokia.com

    ${First ping status}  Catch first ping after reset and create Timestamp
    Run keyword if    not ${First ping status}  Return from keyword  ${False}
    ${Admin connection status}  Setup Admin and create Timestamp
    Run keyword if    not ${Admin connection status}  Return from keyword  ${False}
    Start Infomodel Connection
    ${Continous ping status}  Continous ping check
    Run keyword if    not ${Continous ping status}  Return from keyword  ${False}
    [Return]  ${True}

Start Infomodel Connection
    [Documentation]
    ...  Keyword performs Infomodel setup and connect. If action possible,
    ...  test variable 'infomodel_started' is being set to ${True}.
    ...  Keyword also returns ${True} / ${False}, depending on setup outcome
    ...
    ...  | Parameter    | Man.  | Default              | Description |
    ...  | bts_host     | No    | ${SMOD1['TRS_IP']}   | IP to be pinged |
    ...
    ...     *PRODUCT*       SOAM
    ...     *AUTHOR*        agata.maslowska@nokia.com
    ...     *MAINTAINER*    jaroslaw.piszczala@nokia.com

    [Arguments]  ${bts_host}=${SMOD1['TRS_IP']}
    Log    Trying to connect to infomodel (max 5 min)   level=INFO  console=${TRUE}
    ${IM setup status}  ${IM setup response}  Run keyword and ignore error
    ...  Setup Infomodel  address=${bts_host}  port=443  use_ssl=True  admin_api_log_dir=${BTS Files}/  timeout=300
    Return from keyword if  '${IM setup status}'=='FAIL'  ${False}
    ${IM connect status}  ${IM connect response}
    ...  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  5 min  15 sec  Connect Infomodel
    Return from keyword if  '${IM connect status}'=='FAIL'  ${False}
    Set Test Variable  ${infomodel_started}  ${True}
    [Return]  ${True}

Verify SSH connection and enable if necessary
    [Documentation]
    ...  Verify if ssh connection is enabled
    ...  If not, try enable ssh via TRS or Admin
    ...
    ...  Test will be blocked if ssh connection will be still disabled
    ...
    ...  *AUTHOR*   jaroslaw.piszczala@nokia.com
    Log  Verify SSH connection and enable if necessary  console=${TRUE}
    ${is_ssh_enabled}=  Check if SSH is enabled
    Run keyword if  ${is_ssh_enabled}  Run Keyword And Return  Log  SSH is enabled  console=${TRUE}
    ${is_ssh_enabled}=  Enable SSH in Independent Execution Context on SBTS SOAM
    Run keyword if  ${is_ssh_enabled}  Run Keyword And Return  Log  SSH is enabled  console=${TRUE}
    ${is_ssh_enabled}=  Enable Ssh By Trs
    Run keyword if  ${is_ssh_enabled}  Run Keyword And Return  Log  SSH is enabled  console=${TRUE}
    ${is_ssh_enabled}=  BTSSM Enable SSH By Recommissioning
    Run keyword if  ${is_ssh_enabled}  Run Keyword And Return  Log  SSH is enabled  console=${TRUE}
    ${is_ssh_enabled}=  Enable SSH via Rescue Console
    Run keyword if  ${is_ssh_enabled}  Run Keyword And Return  Log  SSH is enabled  console=${TRUE}
    Set Test Blocked  SSH is not enabled

Disable port security via BTSSM
    [Documentation]
    ...  Disable BTS port security via BTSSM
    ...  Set test restriction if Port Security is still enabled
    ...
    ...     *PRODUCT*  LTE
    ...     *AUTHOR*   jaroslaw.piszczala@nokia.com
    [Arguments]  ${btssm_alias}=MSM
    ${disable_status}  Run Keyword And Return Status  ute_btssm.Disable Bts Port Security  alias=${btssm_alias}
    Run keyword if  ${disable_status}
    ...  Log  Disabling Bts Port Security status: ${disable_status}  console=${TRUE}
    ...  ELSE
    ...  Set test restriction  Disabling Bts Port Security status: ${disable_status}

Install software using yaft
    [Documentation]
    ...  Find in software_directory software matching software_pattern and install using yaft
    ...  Used in test cases COMPA__*_installing_using_YAFT
    ...
    ...  | Parameter            | Man. | Default | Description                                          |
    ...  | software_pattern     | Yes  | -       | Pattern for software, which should be installed.     |
    ...  | software_directory   | Yes  | -       | Directory with software packages                     |
    ...  | swconfig_path        | Yes  | -       | Path to swconfig which should be copied to BTS       |
    ...  | sign_dirs            | No   | None    | Optional directories with files to sign ex."foo|bar" |
    ...
    ...  Keyword is using global variables from env_config files (${SMOD1['USERNAME']}, ${SMOD1['PASSWORD']})
    ...
    ...     *AUTHOR*   jaroslaw.piszczala@nokia.com
    [Arguments]  ${software_pattern}  ${software_directory}  ${swconfig_path}  ${sign_dirs}=${None}
    ...  ${msm_ip}=${SMOD1['TRS_IP']}
    ${yaft_status}=  Install software from directory using yaft  software_pattern=${software_pattern}
    ...  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}  msm_ip=${msm_ip}
    ...  packages_directory=${software_directory}  swconfig_path=${swconfig_path}  log_directory=${TestFiles}
    ...  sign_dirs=${sign_dirs}
    Run keyword if    not ${yaft_status}  Set Test Failed  YAFT error. Check log for more information.  fail_fast=${True}
    Log  Install with yaft ended successfully.  console=${TRUE}

Set tags for software
    [Documentation]
    ...  Active and passive software will be visible in log file, in tag section.
    ...
    ...  | Parameter            | Man. | Description        |
    ...  | operation_type       | Yes  | Operation type     |
    ...  | active_sw_version    | Yes  | Active software    |
    ...  | passive_sw_version   | Yes  | Passive software   |
    ...
    ...     *AUTHOR*   jaroslaw.piszczala@nokia.com
    [Arguments]  ${operation_type}  ${active_sw_version}  ${passive_sw_version}
    Set tags  ${operation_type}_active-${active_sw_version}
    Set tags  ${operation_type}_passive-${passive_sw_version}

Check if software match software pattern
    [Documentation]
    ...  Verify sw with given patterns with "Should match regexp" keyword
    ...  Set test failed if active sw does not match sw pattern
    ...
    ...  | Parameter        | Man. | Default    | Description                                                        |
    ...  | sw               | Yes  | -          | Software version                                                   |
    ...  | sw_pattern       | Yes  | -          | Pattern in regex format to verify active_sw                        |
    ...  | set_test_status  | No   | Failed     | If sw does not match pattern, kw 'Set test (var)' will be executed |
    ...
    ...     *AUTHOR*   jaroslaw.piszczala@nokia.com
    [Arguments]  ${sw}  ${sw_pattern}  ${set_test_status}=Failed
    ${active_status}=  Run keyword and return status  Should Match Regexp  ${sw}  (?i)${sw_pattern}
    Run keyword if    not ${active_status}  Set test ${set_test_status}  ${sw} doesn't match ${sw_pattern} pattern.
    Log  Software ${sw} match software pattern.  console=${TRUE}

Software Fallback
    [Documentation]
    ...  Run fallback_command for given sm_variand and reboot on BTS, then wait for target to be not reachable
    ...  Set test failed if reboot will be not perform
    ...
    ...  | Parameter    | Man. | Description                 |
    ...  | sm_variant   | Yes  | System module variant       |
    ...  | reset_method | Yes  | Method for triggering reset |
    ...
    ...     *AUTHOR*   jacek.mnich@nokia.com
    [Arguments]  ${sm_variant}  ${reset_method}=process_kill
    Set Connection Parameters  ${SMOD1['TRS_IP']}
    Set Reset Loop Counter  sm_variant=${sm_variant}  rlc_number=3
    Run Keyword If  '${reset_method}'=='process_kill'
    ...  Trigger autonomic reset by killing process  process_name=opt/DEM/DEM$
    ...    ELSE IF  '${reset_method}'=='reset_command'  Trigger reset by command  sm_variant=${sm_variant}
    ...       ELSE  Set Test Norun  Unknown reset_method:${reset_method} chosen
    Check If SBTS Lost Ping After Reset

Software Fallback secondary
    [Documentation]
    ...  Run fallback_command for given sm_variand and reboot on BTS, then wait for target to be not reachable
    ...  Set test failed if reboot will be not perform
    ...
    ...  | Parameter    | Man. | Description                 |
    ...  | sm_variant   | Yes  | System module variant       |
    ...  | reset_method | Yes  | Method for triggering reset |
    ...
    ...     *AUTHOR*   jacek.mnich@nokia.com
    [Arguments]  ${sm_variant}  ${reset_method}=process_kill
    ${get_command _to_secondary_core}  Run Keyword  Get Command To Secondary Core  sm_variant=${sm_variant}
    set connection parameters  ${get_command _to_secondary_core}    via_ip=192.168.255.1
    Set Reset Loop Counter  sm_variant=${sm_variant}  rlc_number=3
    Run Keyword If  '${reset_method}'=='process_kill'
    ...  Trigger autonomic reset by killing process  process_name=opt/DEM/DEM$
    ...    ELSE IF  '${reset_method}'=='reset_command'  Trigger reset by command  sm_variant=${sm_variant}
    ...       ELSE  Set Test Norun  Unknown reset_method:${reset_method} chosen
    #Check If SBTS Lost Ping After Reset
    #secondary_Lost ping   3-5min
    #fault critical 4082
    #upgrade by netact

Set Reset Loop Counter
    [Documentation]
    ...  Set Reset Loop Counter
    ...
    ...  | Parameter    | Man. | Description           |
    ...  | sm_variant   | Yes  | System module variant |
    ...
    ...     *AUTHOR*   jacek.mnich@nokia.com
    [Arguments]  ${sm_variant}  ${rlc_number}=3
    ${set_rlc_command}  Run Keyword
    ...  Get Command For Setting Reset Loop Counter  rlc_number=${rlc_number}  sm_variant=${sm_variant}
    ${get_rlc_command}  Run Keyword  Get Command For Getting Reset Loop Counter  sm_variant=${sm_variant}
    ${rlc_before}  Run Remote Linux Command  ${get_rlc_command}
    Log  Reset loop counter before: ${rlc_before}  console=${TRUE}
    Log  Setting reset loop counter to ${rlc_number}: ${set_rlc_command}  console=${TRUE}
    Run Remote Linux Command  ${set_rlc_command}
    ${rlc_after}  Run Remote Linux Command  ${get_rlc_command}
    Log  Reset loop counter after: ${rlc_after}  console=${TRUE}

Trigger Autonomic Reset By Killing Process
     [Documentation]
    ...  Trigger autonomic reset by killing process
    ...
    ...  | Parameter    | Man. | Description               |
    ...  | process_name | Yes  | Process name to be killed |
    ...
    ...     *AUTHOR*   jacek.mnich@nokia.com
    [Arguments]  ${process_name}
    Log  Killing key process: ${process_name} to triger autonomic reset  console=${TRUE}
    ${processes_matching_pattern}  Run Remote Linux Command  ps aux | grep ${process_name}
    Log  Process to be killed: ${processes_matching_pattern}  console=${TRUE}
    ${process_id}  Run Remote Linux Command  pgrep -f ${process_name}
    Log  Process id: ${process_id}  console=${TRUE}
    ${process_id}  Run Remote Linux Command  kill -9 ${process_id}
    Run Remote Linux Command  pgrep -f ${process_name}  expected_return_code=1
    Log  Process: ${process_name} killed  console=${TRUE}

Trigger Reset By Command
     [Documentation]
    ...  Trigger reset by command
    ...
    ...  | Parameter    | Man. | Description           |
    ...  | sm_variant   | Yes  | System module variant |
    ...
    ...     *AUTHOR*   jacek.mnich@nokia.com
    [Arguments]  ${sm_variant}
    ${reset_command}  Get Reset Command  ${sm_variant}
    Log  Running command: ${reset_command}  console=${TRUE}
    Run Remote Linux Command  ${reset_command}

Get Command To Secondary Core
     [Documentation]
    ...  Return reset command for given system module variant
    ...
    ...  | Parameter    | Man. | Description           |
    ...  | sm_variant   | Yes  | System module variant |
    ...
    ...     *AUTHOR*   jaroslaw.piszczala@nokia.com
    ...     *MAINTAINER*   jacek.mnich@nokia.com
    [Arguments]  ${sm_variant}
    Run keyword if  'FSMF' in '${sm_variant}'   Return from keyword  192.168.255.7
    ...  ELSE IF    'FSIH' in '${sm_variant}'   Return from keyword  192.168.255.7
    ...  ELSE IF    'ASIA' in '${sm_variant}'   Return from keyword  fct-4a
    ...  ELSE IF    'ASIB' in '${sm_variant}'   Return from keyword  fct-4a
    ...  ELSE IF    'ASIAB' in '${sm_variant}'  Return from keyword  fct-4a
    ...  ELSE IF    'ASIL' in '${sm_variant}'  Return from keyword  fct-4a
    ...  ELSE IF    'ASIM' in '${sm_variant}'  Return from keyword  fct-4a

Get Reset Command
     [Documentation]
    ...  Return reset command for given system module variant
    ...
    ...  | Parameter    | Man. | Description           |
    ...  | sm_variant   | Yes  | System module variant |
    ...
    ...     *AUTHOR*   jaroslaw.piszczala@nokia.com
    ...     *MAINTAINER*   jacek.mnich@nokia.com
    [Arguments]  ${sm_variant}
    Run keyword if  'FSMF' in '${sm_variant}'   Return from keyword  ddal -s ddal_reboot_graceful
    ...  ELSE IF    'FSIH' in '${sm_variant}'   Return from keyword  reboot
    ...  ELSE IF    'ASIA' in '${sm_variant}'   Return from keyword
    ...  ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    ...  ELSE IF    'ASIB' in '${sm_variant}'
    ...  Return from keyword  ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    ...  ELSE IF    'ASIAB' in '${sm_variant}'
    ...  Return from keyword  ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    ...  ELSE IF    'ASIL' in '${sm_variant}'
    ...  Return from keyword  ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    ...  ELSE IF    'ASIM' in '${sm_variant}'
    ...  Return from keyword  ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN

Get Command For Setting Reset Loop Counter
     [Documentation]
    ...  Return fallback command for given system module variant
    ...
    ...  | Parameter    | Man. | Description           |
    ...  | sm_variant   | Yes  | System module variant |
    ...
    ...     *AUTHOR*   jaroslaw.piszczala@nokia.com
    ...     *MAINTAINER*   jacek.mnich@nokia.com
    [Arguments]  ${rlc_number}   ${sm_variant}
    Run keyword if  'FSMF' in '${sm_variant}'   Return from keyword  uboot_env -r set reset_counter=${rlc_number}
    ...  ELSE IF    'FSIH' in '${sm_variant}'   Return from keyword  uboot_env -r set reset_counter=${rlc_number}
    ...  ELSE IF    'ASIA' in '${sm_variant}'
    ...  Return from keyword  ddal -s ddal_boot_set_reset_loop_count ${rlc_number}
    ...  ELSE IF    'ASIB' in '${sm_variant}'
    ...  Return from keyword  ddal -s ddal_boot_set_reset_loop_count ${rlc_number}
    ...  ELSE IF    'ASIAB' in '${sm_variant}'
    ...  Return from keyword  ddal -s ddal_boot_set_reset_loop_count ${rlc_number}
    ...  ELSE IF    'ASIL' in '${sm_variant}'  Return from keyword  ddal -s ddal_boot_set_reset_loop_count ${rlc_number}
    ...  ELSE IF    'ASIM' in '${sm_variant}'  Return from keyword  ddal -s ddal_boot_set_reset_loop_count ${rlc_number}
    ...  ELSE IF    'ASOE' in '${sm_variant}'  Return from keyword  ddal -s ddal_boot_set_reset_loop_count ${rlc_number}
    ...  ELSE IF    'ASOF' in '${sm_variant}'  Return from keyword  ddal -s ddal_boot_set_reset_loop_count ${rlc_number}
    ...  ELSE                                   Log  Wrong SM vartiant given  level=ERROR

Get Command For Getting Reset Loop Counter
     [Documentation]
    ...  Return fallback command for given system module variant
    ...
    ...  | Parameter    | Man. | Description           |
    ...  | sm_variant   | Yes  | System module variant |
    ...
    ...     *AUTHOR*   jaroslaw.piszczala@nokia.com
    ...     *MAINTAINER*   jacek.mnich@nokia.com
    [Arguments]  ${sm_variant}
    Run keyword if  'FSMF' in '${sm_variant}'   Return from keyword  uboot_env -r get reset_counter
    ...  ELSE IF    'FSIH' in '${sm_variant}'   Return from keyword  uboot_env -r get reset_counter
    ...  ELSE IF    'ASIA' in '${sm_variant}'   Return from keyword  ddal -s ddal_boot_get_reset_loop_count
    ...  ELSE IF    'ASIB' in '${sm_variant}'   Return from keyword  ddal -s ddal_boot_get_reset_loop_count
    ...  ELSE IF    'ASIAB' in '${sm_variant}'  Return from keyword  ddal -s ddal_boot_get_reset_loop_count
    ...  ELSE IF    'ASIL' in '${sm_variant}'  Return from keyword  ddal -s ddal_boot_get_reset_loop_count
    ...  ELSE IF    'ASIM' in '${sm_variant}'  Return from keyword  ddal -s ddal_boot_get_reset_loop_count
    ...  ELSE IF    'ASOE' in '${sm_variant}'  Return from keyword  ddal -s ddal_boot_get_reset_loop_count
    ...  ELSE IF    'ASOF' in '${sm_variant}'  Return from keyword  ddal -s ddal_boot_get_reset_loop_count
    ...  ELSE                                   Log  Wrong SM vartiant given  level=ERROR

Check If SBTS Lost Ping After Reset
     [Documentation]
    ...  Fail if BTS doesn't lose ping
    ...
    ...  | Parameter    | Man. | Description           |
    ...  | sm_variant   | Yes  | System module variant |
    ...
    ...     *AUTHOR*   jacek.mnich@nokia.com
    Log  Waiting for target to be not reachable  console=${TRUE}
    ${reboot_status}=  Run keyword and return status  Wait for target to be not reachable  ${SMOD1['TRS_IP']}
    Run keyword if    not ${reboot_status}  Set test failed  BTS didn't loose ping, reset not perfomed.  fail_fast=${True}
    Log  Software fallback triggered.  console=${TRUE}

Check if BTS is on air via Siteconf
    [Documentation]
    ...  Check if BTS is on air state via siteconf
    ...  Fail if any of BTS states is not as expected
    ...  Use with `Wait untill keywords succeeds` for best performance
    ...
    ...  Checked states:
    ...     SM   (workingState=working in default, operationalState=${_Enabled})
    ...     RF   (workingState=working, operationalState=${_Enabled})
    ...     CELL (operationalState=${_Enabled}, cellAvailability=active, workingState=working)
    ...
    ...     *PRODUCT*  LTE, WCDMA
    ...     *AUTHOR*   jaroslaw.piszczala@nokia.com
    [Arguments]  ${SM_workingState}=working  ${SM_ext_workingState}=degraded
    Set test variable  ${verification verdict}  PASS
    ${siteconf_path}=  hran_general.Download Siteconf.xml With Timestamp  MSM  ${BTSFiles}/siteconf
    ${status list}  Create list
    Set test variable  ${status list}
    _Check state and add verdict to list
    ...  ${status list}  ${siteconf path}  SM_workingState      ${SM_workingState}  ${SM_ext_workingState}
    _Check state and add verdict to list  ${status list}  ${siteconf path}  SM_operationalState  enabled
    _Check state and add verdict to list  ${status list}  ${siteconf path}  RF_workingState      working
    _Check state and add verdict to list  ${status list}  ${siteconf path}  RF_operationalState  enabled
    _Check state and add verdict to list  ${status list}  ${siteconf path}  CELL_operationalState  enabled
    _Check state and add verdict to list  ${status list}  ${siteconf path}  CELL_cellAvailability  active
    _Check state and add verdict to list  ${status list}  ${siteconf path}  CELL_workingState      working
    Siteconf Get states and create table  ${siteconf path}  SMODs
    Siteconf Get states and create table  ${siteconf path}  RMODs
    Siteconf Get states and create table  ${siteconf path}  CELLs
    Log  ${status list}
    Run keyword if  '${verification verdict}'=='FAIL'  FAIL  BTS verification status is: FAIL

_Check state and add verdict to list
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${list name}: <description>
    ...        ${siteconf path}: <description>
    ...        ${state}: <description>
    ...        ${desired value}: <description>
    ...        ${additional value}: <description>
    [Arguments]  ${list name}  ${siteconf path}  ${state}  ${desired value}  ${additional value}=${None}
    ${status}  Siteconf Verify Multiple Occurrence Of Given State In Siteconf By Name
    ...  ${siteconf path}  ${state}  ${desired value}  ${additional value}
    Collections.append to list  ${list name}  ${status[0]}
    Log  ${state} check status is: ${status[0]} (expected: ${desired value})
    Run keyword if  '${status[0]}'=='FAIL'  Set test variable  ${verification verdict}  FAIL

Check if BTS is commisioned for SBTS16
    [Arguments]  ${ip}
    [Documentation]
    ...  Check if BTS is is commisioned
    ...  To calculate verdict, files and procedural status will be checked:
    ...     obligatory files (bim.json)
    ...     optional files (SBTS_SCF.xml, SCFC_MZ.xml, bim_repo_delta.json, bim_siteoam.json,
    ...  siteoam_bim_repo_delta.json, profiles)
    ...     BTS proceduralStatus==configured
    ...
    ...     *PRODUCT*  SBTS16
    ...     *AUTHOR*   jaroslaw.piszczala@nokia.com
    ${obligatory_files}=  Create List  bim.json
    ${optional_files}=  Create List  SBTS_SCF.xml  SCFC_MZ.xml  bim_repo_delta.json  bim_siteoam.json
    ...  siteoam_bim_repo_delta.json  profiles
    ${files_status}=  Verify files from given path  ${ip}  /flash/config  ${obligatory_files}  ${optional_files}
    Run keyword if  ${files_status}  Wait Until Keyword Succeeds  5m  1m  BTS procedural status should be configured
    ${procedural_status}=  REST get parameter for given uri  uri=/mz/p/v1/pbts/1  parameter=proceduralStatus
    Run keyword if  ${files_status} and '${procedural_status}'=='configured'
    ...  Return from keyword  ${True}
    [Return]  ${False}

Check SBTS16 Alarms and fail on critical and major alarms
    [Documentation]    Short description.
    ${CRITICAL_ALARM}=      Create dictionary  severity=2|3
    ${CRITICAL}=            Create list  ${CRITICAL_ALARM}
    ${status}  ${alarms_msg}=  Run keyword and ignore error  Check SBTS16 Alarms  critical_patterns=${CRITICAL}
    Run keyword if  '${status}'=='FAIL'   Set Test Failed    Critical fail while checking alarms: ${alarms_msg}
    ...  ELSE IF  ${alarms_msg}  Set Test Restriction        Unexpected alarms are present: ${alarms_msg}
