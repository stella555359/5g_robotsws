*** Settings ***
Documentation     [PURPOSE] SiteManager General keywords from HZ
Library         ute_btssm
Library         lib/tool_ping.py
Library         OperatingSystem
Library         Collections


*** Keywords ***
BTSSM Start BTSSM on '${alias}'
    [Documentation]
    ...    Cloned from hran_frame_rfs. Changed to be compliant with yaml config file
    ...    *RETURN VALUE*
    ...    None
    [Timeout]  1 min
    ${host}=  Set Variable If  '${alias}'=='Master'  127.0.0.1  ${PC_IP2}
    Wait until keyword succeeds  5 min  15 sec  ute_btssm.Setup BTSSM  alias=${alias}  rc_only=${True}
    ...  host_ip=${host}  log_path=${Temp Logs Dir}  timeout=60s  ne=${SMOD1['TRS_IP']}
    Log  BTSSM on '${alias}' started  level=TRACE  console=${TRUE}

BTSSM Get installed SEM versions
    [Documentation]
    ...    *AUTHOR* sebastian.burniak@nokia.com
    ...    Save as test variable list of installed SEMs on VM.
    ...    *RETURN VALUE*
    ...    None
    Log  Get SEM installed versions    console=true
    ${status}  ${value}  run keyword and ignore error  get installed btssm versions  alias=Master
    Run Keyword If  '${status}'=='FAIL'
    ...  SWBT Fail with QL  ENV
    ...  Cannot get installed sem version. ENV issue.  error during getting_installed_btssm_versions
    Run Keyword If  '${status}'=='PASS'  Log  installed btssm: ${value}    console=true
    Set test variable  ${installed sems}  ${value}

BTSSM install SEM
    [Documentation]
    ...    *AUTHOR* sebastian.burniak@nokia.com
    ...    Installs Site Manager app
    ...    *RETURN VALUE*
    ...    None
    Log  Install SEM from ${sem_dir}/${sem name}    console=${True}
    ${status}  ${value}  run keyword and ignore error  install btssm  ${sem_dir}/${sem name}  alias=Master  mode=Normal
    Run Keyword If  '${status}'=='FAIL'  SWBT Fail with QL  ENV  error during btssm installation
    Run Keyword If  '${status}'=='PASS'  Log  btssm installed succesfully    console=true

BTSSM Commissioning
    [Documentation]
    ...    *AUTHOR* sebastian.burniak@nokia.com
    ...    Perform full commissioning and wait for reset
    ...    | Input Parameters | Man. | Description                                  |
    ...    | scf path         | Yes  | Path to SCFC file                            |
    ...    *RETURN VALUE*
    ...    None
    [Arguments]  ${scf path}
    Log  Start commissioning using ${scf path} file    console=${True}
    ${status}  Run keyword and return status
    ...  Perform full commissioning and wait for reset  ${scf path}  validate=${True}  alias=Master  timeout=10min
    [Return]    ${status}

BTSSM Enable SSH By Recommissioning
    [Documentation]
    ...    *AUTHOR* mnich@nokia.com
    ...    BTSSM Enable SSH By Recommissioning actServiceAccountSsh and systemAcctPermEnable                         |
    ...    *RETURN VALUE*
    ...    True/False
    Log  BTSSM Enable SSH By Recommissioning    console=${True}
    Kill process by name  btsmanager
    ${btssm_started}=  Run Keyword And Return Status  Wait until keyword succeeds  2 times  5 sec
    ...  ute_btssm.Setup BTSSM  log_path=${Temp Logs Dir}  timeout=30s  ne=${SMOD1['TRS_IP']}  alias=ssh_enabler
    Return From Keyword If  not ${btssm_started}  ${False}
    Log  BTSSM Enable SSH By setting actServiceAccountSsh:true    console=${True}
    ${status}  Run keyword and return status
    ...  Perform Parameter Commissioning  actServiceAccountSsh:true  alias=ssh_enabler
    ${is_ssh_enabled}=  Check if SSH is enabled
    Return From Keyword If  ${is_ssh_enabled}  ${True}
    Log  BTSSM Enable SSH By setting systemAcctPermEnable:false    console=${True}
    ${status}  Run keyword and return status
    ...  Perform Parameter Commissioning  systemAcctPermEnable:false  alias=ssh_enabler
    ${is_ssh_enabled}=  Check if SSH is enabled
    Return From Keyword If  ${is_ssh_enabled}  ${True}
    [Teardown]  Run Keyword And Return Status  Teardown Btssm  alias=ssh_enabler
    [Return]    ${False}

Get SWBT SW versions
    [Documentation]
    ...    *AUTHOR* sebastian.burniak@nokia.com
    ...    Download file CheckSWVersions from MSM and try to match the proper pattern
    ...     to find active and passive version of SW
    ...    | Input Parameters | Man. | Description                                  |
    ...    | device           | Yes  | Master device to get SW version        |
    ...    *RETURN VALUE*
    ...    Active and passive SW version of MSM
    [Arguments]  ${device}
    ${active pattern}=  Set variable  TargetBD\\s*\\S*\\s*(\\S*)\\s*Yes\\s*\\S*\\s*1
    ${passive pattern}=  Set variable  TargetBD\\s*\\S*\\s*(\\S*)\\s*No\\s*\\S*\\s*1
    Sleep  5
    @{paths}  ute_btssm.Get Sw Versions  alias=${device}
    FOR    ${path}    IN    @{paths}
        Continue For Loop If  'CheckSWVersions' not in '${path}'
        Copy file  ${path}  ${Test Files}
        ${CheckSWVersions path}=  Set Variable  ${path}
        Exit For Loop
    END
    ${content}=  OperatingSystem.Get file  ${CheckSWVersions path}
    ${match}  ${active SW}=  Run keyword and ignore error  Should Match Regexp  ${content}  ${active pattern}
    Run keyword if
    ...  '${match}' != 'PASS'  Fail
    ...  ${device} SM is not supported or this type of module does not exist in this configuration
    ${match}  ${passive SW}=  Run keyword and ignore error  Should Match Regexp  ${content}  ${passive pattern}
    Run keyword and ignore error  Set test variable  ${${device} active SW}  @{active SW}[1]
    Run keyword if  '${match}' == 'PASS'
    ...  Run keyword and ignore error  Set test variable  ${${device} passive SW}  @{passive SW}[1]
    ...         ELSE    Set test variable  ${${device} passive SW}  ${None}
    Log  ${device} active SW: ${${device} active SW}  console=True
    Log  ${device} passive SW: ${${device} passive SW}  console=True
    [Return]  ${${device} active SW}  ${${device} passive SW}

BTSSM Get SW Versions
    [Documentation]
    ...  *AUTHOR*
    ...  tomasz.1.filipek@nokia.com
    ...
    ...  *INPUT VALUES*
    ...  :param alias:      string, relation to active ute_btssm session
    ...
    ...  *RETURN VALUE*
    ...  :return:           list with active and passive SW
    ...
    [Arguments]    ${alias}=default
    ${active pattern}=    Set Variable  TargetBD\\s*\\S*\\s+(\\S+)\\s*Yes
    ${passive pattern}=   Set Variable  TargetBD\\s*\\S*\\s+(\\S+)\\s*No
    @{paths}  ute_btssm.Get Sw Versions  alias=${alias}
    FOR    ${path}    IN    @{paths}
        Continue For Loop If  'CheckSWVersions' not in '${path}'
        Copy file  ${path}  ${Test Files}
        ${CheckSWVersions path}=  Set Variable  ${path}
        Exit For Loop
    END
    ${content}=  OperatingSystem.Get file  ${CheckSWVersions path}
    ${match}  ${active SW}=  Run keyword and ignore error  Should Match Regexp  ${content}  ${active pattern}
    Run keyword if
    ...  '${match}' != 'PASS'  Fail
    ...  ${alias} SM is not supported or this type of module does not exist in this configuration
    Set test variable  ${${alias} active SW}  @{active SW}[1]
    ${match}  ${passive SW}=  Run keyword and ignore error  Should Match Regexp  ${content}  ${passive pattern}
    ${temp passive SW}=  Set variable if  '${match}' == 'PASS'  @{passive SW}[1]  UNKNOWN
    Set test variable  ${${alias} passive SW}  ${temp passive SW}
    Log  ${alias} active SW: ${${alias} active SW}  console=${TRUE}
    Log  ${alias} passive SW: ${${alias} passive SW}  console=${TRUE}
    [Return]  ${${alias} active SW}  ${${alias} passive SW}

Upload RAH and find active alarm by id
    [Documentation]
    ...    *AUTHOR* sebastian.burniak@nokia.com
    ...    Checks active alarms from new uploaded RAH file
    ...    | Input Parameters | Man. | Description                                  |
    ...    | alarm id         | Yes  | Alarm id to check if is active               |
    ...    *RETURN VALUE*
    ...    boolean
    [Arguments]    ${alarm_id}
    ${timestamp} =  Get Time
    ${timestamp} =  Replace String Using Regexp  ${timestamp}  (${SPACE}|:|-)  _
    ${rel}=  Set Variable  ${SMOD1['HW_TYPE']}
    ${rah_path}=  Set Variable  &{rah_path_dict}[${rel}]
    ${status}  ${value}=  Run Keyword and Ignore Error  ute_btssm.Upload rawalarms bts file    alias=Master
    Run Keyword If  '${status}'=='FAIL'  Fail  Couldn't upload rah
    ...       ELSE   Copy file  ${value[0]}  ${Test Results Dir}/Logs/${timestamp}_rah.txt
    ${status}  ${alarm_found}=  Run Keyword And Ignore Error  Find active alarm in rah  ${value[0]}  ${alarm_id}
    Run Keyword If  '${status}'=='FAIL'  Fail  Couldn't parse rah
    [Return]    ${alarm_found}

SWBT Get reset info from blackbox
    [Documentation]
    ...    *AUTHOR* sebastian.burniak@nokia.com
    ...    Downloads blackbox file from bts and returns reset counter and last reset reason
    ...    | Input Parameters           | Man. | Description                                                     |
    ...    | blackbox bts path          | No   | Path to blackbox file, default - /rom/config/lifedata/blackbox  |
    ...    *RETURN VALUE*
    ...    reset counter, last reset reason
    [Arguments]  ${blackbox_bts_path}=/rom/config/lifedata/
    ${timestamp} =  Get Time
    ${timestamp} =  Replace String Using Regexp  ${timestamp}  (${SPACE}|:|-)  _
    ${status}  ${value}=  Run Keyword and Ignore Error  hran_general.Get file from BTS
    ...  ${blackbox_bts_path}  blackbox
    Run Keyword If  '${status}'=='PASS'  Log  Blackbox file successfully uploaded  console=${True}
    ...     ELSE    Log    Error found while trying to get blackbox file from BTS    console=${TRUE}    level=WARN
    ${blackbox_uploaded_path}  Set Variable  ${value}
    ${reset_counter}  ${last_reset_reason}=  Get reset info from file  ${blackbox_uploaded_path}
    Copy file  ${blackbox_uploaded_path}  ${Test Results Dir}/Logs/${timestamp}_blackbox.txt
    [Return]  ${reset_counter}  ${last_reset_reason}

Download alarms
    [Documentation]
    ...    *AUTHOR* sebastian.burniak@nokia.com
    ...    KW downloads active alarms from BTS and saves ActiveAlarms_Summary text file into Test Files directory.
    ...    | Input Parameters           | Man. | Description                                                       |
    ...    *RETURN VALUE*
    ...    content
    Log  Download active alarms from BTS  console=${True}
    ${result_files}=  ute_btssm.Get active alarms  alias=Master
    Copy file  ${result_files[-1]}  ${Test Files}/
    ${content}=  OperatingSystem.Get file  ${result_files[-1]}
    [Return]  ${content}

BTSSM Upload Bts Scfc File
    [Documentation]
    ...  Perform upload Bts Scfc File
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    | Parameter      | Man.  | Default | Description                 |
    ...    | alias          | no    |         | alias of ute_btssm instance |
    ...
    ...    *RETURN VALUE*
    ...    | Parameter      | Description                         |
    ...    | SCF_PATH       | path where SCF file is stored on VM |
    ...    | SCF_FILE       | SCF file name stored on VM          |

    [Timeout]  20 min
    [Arguments]  ${alias}=default
    ${SCF_INFO}=  Upload Bts Scfc File  alias=${alias}
    OperatingSystem.File Should Exist  ${SCF_info[0]}
    ${SCF_PATH}  ${SCF_FILE}=  Split Path  ${SCF_info[0]}
    Set Test Variable  ${SCF_PATH}  ${SCF_PATH}
    Set Test Variable  ${SCF_FILE}  ${SCF_FILE}
    [Return]  ${SCF_PATH}  ${SCF_FILE}

BTSSM Upload Fullcoverage Bts File
    [Documentation]
    ...  Perform upload Fullcoverage Bts File
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    | Parameter      | Man.  | Default | Description                 |
    ...    | alias          | no    |         | alias of ute_btssm instance |
    ...
    ...    *RETURN VALUE*
    ...    | Parameter      | Description                              |
    ...    | SNAPSHOT_PATH  | path where SNAPSHOT file is stored on VM |
    ...    | SNAPSHOT_FILE  | SNAPSHOT file name stored on VM          |

    [Timeout]  20 min
    [Arguments]  ${alias}=default
    ${SNAPSHOT_INFO}=  Upload Fullcoverage Bts File  alias=${alias}
    OperatingSystem.File Should Exist  ${SNAPSHOT_INFO[0]}
    ${SNAPSHOT_PATH}  ${SNAPSHOT_FILE}=  Split Path  ${SNAPSHOT_INFO[0]}
    Set Test Variable  ${SNAPSHOT_PATH}  ${SNAPSHOT_PATH}
    Set Test Variable  ${SNAPSHOT_FILE}  ${SNAPSHOT_FILE}
    [Return]  ${SNAPSHOT_PATH}  ${SNAPSHOT_FILE}

BTSSM Upload Pm Counters Bts Files
    [Documentation]
    ...  Perform upload Pm Counters Bts Files
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    | Parameter      | Man.  | Default | Description                 |
    ...    | alias          | no    |         | alias of ute_btssm instance |
    ...
    ...    *RETURN VALUE*
    ...    | Parameter           | Description                           |
    ...    | PM_PATH             | path where PM archive is stored on VM |
    ...    | ${alias}_PM_ARCHIVE | PM archive name stored on VM          |

    [Timeout]  5 min
    [Arguments]  ${alias}=default
    ${PM_INFO}=  Upload Pm Counters Bts Files  alias=${alias}
    OperatingSystem.File Should Exist  ${PM_INFO[0]}
    ${PM_PATH}  ${PM_ARCHIVE}=  Split Path  ${PM_INFO[0]}
    Set Test Variable  ${PM_PATH}  ${PM_PATH}
    Set Test Variable  ${${alias}_PM_ARCHIVE}  ${PM_ARCHIVE}
    [Return]  ${PM_PATH}  ${${alias}_PM_ARCHIVE}
