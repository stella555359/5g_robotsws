*** Settings ***
Documentation     [PURPOSE] admin General keywords
Library             Collections
Library             OperatingSystem
Resource            hran_general.robot
Library             lib/AlarmAnalysis.py
Library             lib/verdict.py
#Library             taf.sbts.oam.coam.admin    WITH NAME 	admin
Library             taf.sbts.oam.coam.admin
Library             String


*** Variables ***
&{SIMPLIFIED_ALARM}     severity=${NONE}  faultId=${NONE}  faultName=${NONE}  notifier=${NONE}  number=${NONE}
${ADMIN_SNAPSHOT_TIMEOUT_MASTER}  1200  #timeout for collect snapshot via Admin from MSM (in sec)
${ADMIN_SNAPSHOT_TIMEOUT_ESM}     1500  #timeout for collect snapshot via Admin from ESM (in sec)
&{IGNORED_FAULT_61524}    faultId=61524    faultName=SSH enabled
&{IGNORED_FAULT_61652}    faultId=61652    faultName=R&D Service Port enabled
&{IGNORED_FAULT_61649}    faultId=61649    faultName=LMP access via port
&{IGNORED_FAULT_6450}    faultId=6450    faultName=Diagnostic Files collected
&{IGNORED_FAULT_61074}    faultId=61074    faultName=CRL Update Failure
&{IGNORED_FAULT_4655}    faultId=4655    faultName=Service account root access is enabled
&{IGNORED_FAULT_4654}    faultId=4654    faultName=Ethernet port security is disabled
&{IGNORED_FAULT_4293}    faultId=4293    faultName=IP Traffic Capacity Limit
&{IGNORED_FAULT_61510}    faultId=61510    faultName=Automatic BTS Operator Certificate retrieval unsuccessful
@{GLOBALLY_IGNORED_ALARMS}    ${IGNORED_FAULT_61524}    ${IGNORED_FAULT_61652}
...  ${IGNORED_FAULT_61649}    ${IGNORED_FAULT_6450}    ${IGNORED_FAULT_61074}
...  ${IGNORED_FAULT_4655}    ${IGNORED_FAULT_4654}    ${IGNORED_FAULT_4293}    ${IGNORED_FAULT_61510}


*** Keywords ***
Admin Check Active Alarms
    [Documentation]
    ...  Alarms checking based on Admin. Fails if any expected alarm is missing or any critical alarm occurred.
    ...  If collect_snapshot is set to True, snapshot is collected when active alarms are detected.
    ...  If ${print_alarms} is set to True, KW will print lists of alarms with level:
    ...  - ERROR - missed expected or found unexpected criticals
    ...  - INFO - found expected and ignored
    ...  - WARN - all other
    ...
    ...  | Parameter            | Man.  | Default | Description |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...  | expected_patterns    | No  | empty   | List of expected alarms regex patterns, one for each expected alarm|
    ...  | ignored_patterns     | No  | empty   | List of ignored alarms regex patterns, will be used multiply  |
    ...  | critical_patterns    | No   | empty   | List of critical alarms regex patterns, will be used multiply  |
    ...  | timeout              | No    | 90      | Timeout in seconds to wait for getting alarms from Admin |
    ...  | print_alarms     | No | true| Boolean to decide whether output lists should be printed with proper level |
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
    ...  3. Example of KW used with one expected and one critical alarm definition
    ...  - will fail if expected alarm does not occur,
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
    ${userdefinealarm1}=     Create Dictionary  faultId=1838  faultName=VSWR minor alarm
	${userdefinealarm2}=     Create Dictionary  faultId=17  faultName=BTS RNC interface signalling link failure
    ${userdefinealarm3}=     Create Dictionary  faultId=7107
	...  faultName=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    Append to list  ${ignored_patterns}  @{globally_ignored_alarms}
    ${var_exists}    Run Keyword And Return Status    Variable should exist    ${ADDITIONAL_IGNORED_ALARMS}
    Run Keyword If    ${var_exists}    Append to list  ${ignored_patterns}  @{ADDITIONAL_IGNORED_ALARMS}
    Append to list  ${ignored_patterns}  ${userdefinealarm1}
	Append to list  ${ignored_patterns}  ${userdefinealarm2}
	Get_QCID
	${QCID_NUM}  fetch from right  ${QC_ID}  _
	Run keyword if    '${QCID_NUM}' in '[33433,687931,33431,33432,33436,33337,33442,33435,33434]'
	...    Append to list    ${ignored_patterns}    ${userdefinealarm3}
    ${active_alarms}=  taf.sbts.oam.coam.admin.Get Active Alarms  timeout=${timeout}  alias=${alias}
    Run Keyword If  not ${active_alarms}  Log  No active alarms have been found.  console=${TRUE}
    ${found expected alarms}  ${not found expected alarms patterns}  ${found critical alarms}  ${found ignored alarms}
    ...  ${found not classified alarms}=  AlarmAnalysis.Get Filtered Alarms  ${active_alarms}
    ...  ${expected_patterns}  ${ignored_patterns}  ${critical_patterns}  ${SIMPLIFIED_ALARM}
    Run Keyword If  ${print_alarms}  AlarmAnalysis.Print Alarms  ${found expected alarms}
    ...  ${not found expected alarms patterns}  ${found critical alarms}  ${found ignored alarms}
    ...  ${found not classified alarms}  simplified_dictionary=${SIMPLIFIED_ALARM}
    #Run Keyword If  ${not found expected alarms patterns} or ${found critical alarms}  Fail  Alarm verification failed
    Run Keyword If  ${not found expected alarms patterns}  Fail  Alarm verification failed
    ${temp}=   Evaluate
    ...  ${not found expected alarms patterns} or ${found critical alarms} or ${found not classified alarms}
    Run keyword if    ${collect_snapshot} and ${temp}    Admin Get Snapshot
    [Return]  ${found not classified alarms}

Admin Set Test Restriction If Active Alarms Exist
    [Documentation]  If Active alarms exist set test restriction (pass with restriction).
    ...  If collect_snapshot is set to True, snapshot is collected when active alarms are detected.
    ...
    ...  | Parameter            | Man.  | Default | Description                             |
    ...  | collect_snapshot     | No    | False   | collect snapshot if active alarms exist |
    ...
    ...    *AUTHOR*
    ...    michal.kwasniewicz@nokia.com

    [Arguments]  ${collect_snapshot}=${False}

    Log  Check if active alarms exist  console=yes
    ${list_of_active_alarms}=  Get Active Alarms  timeout=60
    ${length}=  Get Length  ${list_of_active_alarms}

    Run Keyword If  ${length}>0
    ...  Set Test Restriction  Active alarms exist: ${list_of_active_alarms}
    ...  ELSE
    ...  Log  No active alarms  console=${True}

    Run Keyword If  ${length}>0 and ${collect_snapshot}
    ...  Admin Get Snapshot

Admin Get Snapshot
    [Documentation]
    ...    Try to collect snapshot via taf.sbts.oam.coam.admin.Collect Snapshot. If this operation does not succeed,
    ...  as a workaround
    ...    snapshot is taken using Collect Snapshot Via SSH.
    ...
    ...  | Parameter              | Man.  | Default                              | Description                   |
    ...  | snapshot_timeout  | No    | ${ADMIN_SNAPSHOT_TIMEOUT_MASTER}     | timeout for collect snapshot via Admin |
    ...
    ...    *AUTHOR*
    ...    andrzej.cichon@nokia.com
    [Arguments]  ${snapshot_timeout}=${ADMIN_SNAPSHOT_TIMEOUT_MASTER}
    Log    Collecting snapshot.    console=${True}

    ${snapshot_collected}=    Run Keyword And Return Status    _Get Snapshot Via Admin API  ${snapshot_timeout}
    Run Keyword If    ${snapshot_collected}    Run Keywords
    ...    Log    Snapshot collected!    console=${True}
    ...    AND    Return From Keyword

    ${snapshot_collected}=    Run Keyword And Return Status    _Get Snapshot Via SSH
    Run Keyword If    ${snapshot_collected}    Run Keywords
    ...    Log    Snapshot collected!    console=${True}
    ...    AND    Return From Keyword

    Log    Snapshot not collected!    console=${True}

_Get Snapshot Via Admin API
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${timeout}: <description>
    ...        ${alias}: <description>
    [Arguments]  ${timeout}=600  ${alias}=default
    Log    Trying to collect snapshot via Admin API (alias: ${alias})    console=${True}
    Start Admin    alias=Snap1
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}_${month}_${day}_${hour}_${min}
    ${suffix_dict}    Create Dictionary  ${alias}=snapshot_${alias}.zip    default=snapshot.zip
    ${suffix}=    Get From Dictionary    ${suffix_dict}    ${alias}
    ${target_file_name}=    Set Variable    ${Snapshot}/${timestamp}_${suffix}
    #Collect Snapshot    target_file_name=${target_file_name}  timeout=${timeout}    alias=${alias}
    taf.sbts.oam.coam.admin.Collect Snapshot    target_file_name=${target_file_name}  timeout=${timeout}    connection=Snap1
    [Teardown]    taf.sbts.oam.coam.admin.teardown admin    connection=Snap1

_Get Snapshot Via ESM Admin API
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${timeout}: <description>
    ...        ${alias}: <description>
    [Arguments]  ${timeout}=600  ${alias}=default
    Log    Trying to collect snapshot via ESM Admin API (alias: ${alias})    console=${True}
#    Start Admin    alias=${alias}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}_${month}_${day}_${hour}_${min}
    ${suffix_dict}    Create Dictionary  ${alias}=snapshot_${alias}.zip    default=snapshot.zip
    ${suffix}=    Get From Dictionary    ${suffix_dict}    ${alias}
    ${target_file_name}=    Set Variable    ${Snapshot}/${timestamp}_${suffix}
    #Collect Snapshot    target_file_name=${target_file_name}  timeout=${timeout}    alias=${alias}
    taf.sbts.oam.coam.admin.Collect Snapshot    target_file_name=${target_file_name}  timeout=${timeout}    connection=${alias}
    [Teardown]    taf.sbts.oam.coam.admin.teardown admin    connection=${alias}

_Get Snapshot Via SSH
    [Documentation]    Short description.
    Log    Trying to collect snapshot via SSH    console=${True}
    Collect Snapshot Via SSH    ${Snapshot}

Admin Get Snapshot for ESM
    [Documentation]
    ...    Try to collect snapshot for ESM via taf.sbts.oam.coam.admin.Collect Snapshot.
    ...    If this operation does not succeed, as a workaround
    ...    snapshot is taken using Collect Snapshot Via SSH***********.
    ...
    ...  | Parameter              | Man.  | Default                         | Description                              |
    ...  | snapshot_timeout       | No    | ${ADMIN_SNAPSHOT_TIMEOUT_ESM}   | timeout for collect snapshot via Admin   |
    ...
    ...    *AUTHOR*
    ...    alona.kulieshova@nokia.com
    [Arguments]  ${snapshot_timeout}=${ADMIN_SNAPSHOT_TIMEOUT_ESM}
    Log    Collecting snapshot.    console=${True}

    ${snapshot_collected}=    Run Keyword And Return Status    _Get ESM Snapshot Via Admin API  ${snapshot_timeout}
    Run Keyword If    ${snapshot_collected}    Run Keywords
    ...    Log    ESM snapshot collected!    console=${True}
    ...    AND    Return From Keyword

    ${snapshot_collected}=    Run Keyword And Return Status    _Get ESM Snapshot Via SSH
    Run Keyword If    ${snapshot_collected}    Run Keywords
    ...    Log    Snapshot from ESM Via SSH collected!    console=${True}
    ...    AND    Return From Keyword

    Log    ESM snapshot not collected!    console=${True}

_Get ESM Snapshot Via Admin API
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${snapshot_timeout}: <description>
    [Arguments]     ${snapshot_timeout}=${ADMIN_SNAPSHOT_TIMEOUT_ESM}
    Log    ${snapshot_timeout}
    Log    Trying to collect snapshot for ESM via Admin API    console=${True}
    ${snapshot_collected}=    Run Keyword And Return Status
    ...  _Helper For ESM Snapshot Via Admin API  bts_host=192.168.255.119
    Return From Keyword If  ${snapshot_collected}
    ${snapshot_collected}=    Run Keyword And Return Status
    ...  _Helper For ESM Snapshot Via Admin API  bts_host=192.168.255.129
    Should Be True  ${snapshot_collected}  Failed to collect snapshot for ESM via Admin API

_Helper For ESM Snapshot Via Admin API
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bts_host}: <description>
    [Arguments]     ${bts_host}
    Admin Get Snapshot Remotely Via Admin API  bts_host=${bts_host}  remote_host=${PC_IP2}
    ...  snapshot_timeout=${ADMIN_SNAPSHOT_TIMEOUT_ESM}  alias=ESM

Admin Get Snapshot Remotely Via Admin API
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bts_host}: <description>
    ...        ${remote_host}: <description>
    ...        ${snapshot_timeout}: <description>
    ...        ${alias}: <description>
    [Arguments]    ${bts_host}  ${remote_host}  ${snapshot_timeout}  ${alias}
    Run Keyword And Ignore Error  taf.sbts.oam.coam.admin.Setup Admin
    ...  admin_api_log_dir=${Snapshot}  bts_host=${bts_host}  remote_host=${remote_host}  alias=${alias}
    _Get Snapshot Via ESM Admin API    timeout=${snapshot_timeout}  alias=${alias}

_Get ESM Snapshot Via SSH
    [Documentation]    Short description.
    Log    Trying to collect snapshot from ESM via SSH    console=${True}
    Collect Snapshot Via Ssh From ESM    ${Snapshot}  ${PC_IP2}

Admin Get BTS ID
    [Documentation]
    ...    Gets BTS ID
    ...    *AUTHOR*
    ...    alona.kulieshova@nokia.com
    ${bts_obj} =  taf.sbts.oam.coam.admin.Get parameters for all  BTS
    ${bts_id} =  Convert To String  ${bts_obj[0].btsId}
    [Return]  ${bts_id}

Admin Get MPLANE IP
    [Documentation]
    ...    Get MPLANE IP
    ...
    ...    *AUTHOR*
    ...    andrzej.cichon@nokia.com
    ...
    ...    The parameter is called `btsMplane` in SBTS17A, and `btsMplaneIp4V` in SBTS18A (TAT-12793)
    ...
    ${bts_obj}=    taf.sbts.oam.coam.admin.Get parameters for all    BTS
    ${bts_obj}=    Get From List    ${bts_obj}    0

    ${expected_keys}=    Create List    btsMplane    btsMplaneIp4V
    ${btsMplane_key}=    Evaluate    [key for key in ${bts_obj} if key in ${expected_keys}][0]

    ${mplane_ip}=    Get From Dictionary    ${bts_obj}    ${btsMplane_key}
    ${mplane_ip}=    Convert To String    ${mplane_ip}
    [Return]    ${mplane_ip}

Admin Get LTE SW Version
    [Documentation]
    ...  Helper keyword providing LTE SW versions.
    ...  KW is returning a list of SW versions on active and passive partitions.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter                                     | Description                                          |
    ...  | ${${alias} active SW}  ${${alias} passive SW} | List of SW versions on active and passive partitions |

    [Arguments]  ${alias}=default

    ${LTE_SW_Info}=   taf.sbts.oam.coam.admin.Get software info  alias=${alias}
    ${Active_SW}=  Get from dictionary  ${LTE_SW_Info}  Active SW version
    ${Passive_SW}=  Get from dictionary  ${LTE_SW_Info}  Passive SW version
    Set test variable  ${${alias} active SW}  ${Active_SW}
    Set test variable  ${${alias} passive SW}  ${Passive_SW}
    Log To Console  ${alias} active SW: ${${alias} active SW}
    Log To Console  ${alias} passive SW: ${${alias} passive SW}
    [Return]  ${${alias} active SW}  ${${alias} passive SW}

Admin Get BTS SW Version
    [Documentation]
    ...  Helper keyword providing NR or LTE SW versions.
    ...  KW is returning a list of SW versions on active and passive partitions.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter                                     | Description                                          |
    ...  | ${${alias} active SW}  ${${alias} passive SW} | List of SW versions on active and passive partitions |

    [Arguments]  ${alias}=default

    ${BTS_SW_Info}=   taf.sbts.oam.coam.admin.Get software info  alias=${alias}
    ${Active_SW}=  Get from dictionary  ${BTS_SW_Info}  Active SW version
    ${Passive_SW}=  Get from dictionary  ${BTS_SW_Info}  Passive SW version
    Set test variable  ${${alias} active SW}  ${Active_SW}
    Set test variable  ${${alias} passive SW}  ${Passive_SW}
    Log To Console  ${alias} active SW: ${${alias} active SW}
    Log To Console  ${alias} passive SW: ${${alias} passive SW}
    [Return]  ${${alias} active SW}  ${${alias} passive SW}

Admin Get BTS siteName information
    [Documentation]
    ...  Helper keyword providing LTE siteName info.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description       |
    ...  | LTE_SiteName         | LTE siteName info |

    [Arguments]  ${alias}=default
    ${BTS_PARAM_LIST}=  taf.sbts.oam.coam.admin.Get Parameters For All  BTS  alias=${alias}
    ${LTE_SiteName}=  Create List
    FOR  ${item}  IN  @{BTS_PARAM_LIST}
        ${LTE_SiteName}=  Get Variable Value  ${item.btsName}  UNKNOWN
    END
    Set Tags  Site name - ${alias} = ${LTE_SiteName}
    Log  Site name - ${alias} = ${LTE_SiteName}  level=INFO  console=${TRUE}
    [Return]  ${LTE_SiteName}

Admin Get LTE BTS state info
    [Documentation]
    ...  Helper keyword providing LTE BTS states info.
    ...  KW is returning a list of BTS states info as below:
    ...  - distName, proceduralState, blockingState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description        |
    ...  | LTE_BTS_STATE_LIST   | List of BTS states |

    [Arguments]  ${alias}=default
    ${BTS_PARAM_LIST}=  taf.sbts.oam.coam.admin.Get Parameters For All  BTS  alias=${alias}
    ${LTE_BTS_STATE_LIST}=  Create List
    FOR  ${item}  IN  @{BTS_PARAM_LIST}
        Append To List  ${LTE_BTS_STATE_LIST}  ${item.id}  ${item.proceduralState}  ${item.blockingState}
    END
    [Return]  ${LTE_BTS_STATE_LIST}

Admin Get BTS state info
    [Documentation]
    ...  Helper keyword providing BTS states info.
    ...  KW is returning a list of BTS states info as below:
    ...  - distName, proceduralState, blockingState
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description        |
    ...  | BTS_STATE_LIST       | List of BTS states |

    [Arguments]  ${alias}=default
    ${BTS_PARAM_LIST}=  taf.sbts.oam.coam.admin.Get Parameters For All  BTS  alias=${alias}
    ${BTS_STATE_LIST}=  Create List
    FOR  ${item}  IN  @{BTS_PARAM_LIST}
        Append To List  ${BTS_STATE_LIST}  ${item.id}  ${item.proceduralState}  ${item.blockingState}
    END
    [Return]  ${BTS_STATE_LIST}

Admin Get LTE SMOD state info
    [Documentation]
    ...  Helper keyword providing LTE system module states info.
    ...  KW is returning a list of SMOD states info as below:
    ...  - name, distName, productName, operationalState, administrativeState, availabilityStatus, usageState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                    |
    ...  | LTE_SMOD_STATE_LIST  | List of lists with SMOD states |

    [Arguments]  ${alias}=default
    ${SMOD_ID_LIST}=  taf.sbts.oam.coam.admin.Get Ids For All  SMOD  alias=${alias}
    Sort List  ${SMOD_ID_LIST}
    ${LTE_SMOD_STATE_LIST}=  Create List
    FOR  ${item}  IN  @{SMOD_ID_LIST}
        ${SMOD_PARAM_LIST}=  taf.sbts.oam.coam.admin.Get Parameters For  SMOD  ${item}  alias=${alias}
        ${SMOD_label}=  Fetch From Right  ${SMOD_PARAM_LIST['id']}  /
        @{temp}=  Create List
        ...  ${SMOD_label}
        ...  ${SMOD_PARAM_LIST['id']}
        ...  ${SMOD_PARAM_LIST['productName']}
        ...  ${SMOD_PARAM_LIST['operationalState']}
        ...  ${SMOD_PARAM_LIST['administrativeState']}
        ...  ${SMOD_PARAM_LIST['availabilityStatus']}
        ...  ${SMOD_PARAM_LIST['usageState']}
        Append To List  ${LTE_SMOD_STATE_LIST}  ${temp}
    END
    Sort List  ${LTE_SMOD_STATE_LIST}
    [Return]  ${LTE_SMOD_STATE_LIST}

Admin Get LTE RMOD state info
    [Documentation]
    ...  Helper keyword providing LTE radio modules states info based on InfoModel class name.
    ...  KW is returning a list of lists with RMOD states info as below:
    ...  - name, distName, productName, operationalState, administrativeState,
     ...  availabilityStatus, blockingState, usageState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                    |
    ...  | LTE_RMOD_STATE_LIST  | List of lists with RMOD states |

    [Arguments]  ${alias}=default
    ${RMOD_ID_LIST}=  taf.sbts.oam.coam.admin.Get Ids For All  RMOD  alias=${alias}
    Sort List  ${RMOD_ID_LIST}
    ${LTE_RMOD_STATE_LIST}=  Create List
    FOR  ${item}  IN  @{RMOD_ID_LIST}
        ${RMOD_PARAM_LIST}=  taf.sbts.oam.coam.admin.Get Parameters For  RMOD  ${item}  alias=${alias}
        ${RMOD_label}=  Fetch From Right  ${RMOD_PARAM_LIST['id']}  /
        @{temp}=  Create List
        ...  ${RMOD_label}
        ...  ${RMOD_PARAM_LIST['id']}
        ...  ${RMOD_PARAM_LIST['productName']}
        ...  ${RMOD_PARAM_LIST['operationalState']}
        ...  ${RMOD_PARAM_LIST['administrativeState']}
        ...  ${RMOD_PARAM_LIST['availabilityStatus']}
        ...  ${RMOD_PARAM_LIST['blockingState']}
        ...  ${RMOD_PARAM_LIST['usageState']}
        Append To List  ${LTE_RMOD_STATE_LIST}  ${temp}
    END
    Sort List  ${LTE_RMOD_STATE_LIST}
    [Return]  ${LTE_RMOD_STATE_LIST}

Admin Get BBMOD info
     [Documentation]
    ...  Helper keyword providing BBMOD states info based on InfoModel class name.
    ...  KW is returning a list of lists with BBMOD states info as below:
    ...  - name, distName, operationalState, administrativeState, availabilityStatus
    ...
    ...  *AUTHOR*
    ...  adelina.ivan@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter        | Description                    |
    ...  | BBMOD_list       | List of lists with BBMOD states |

    [Arguments]  ${alias}=default
    Log  Get all BBMODs  console=True
    ${BBMOD_ID_list}=  taf.sbts.oam.coam.admin.Get Ids For All  BBMOD  alias=${alias}
    Sort List  ${BBMOD_ID_list}
    ${BBMOD_count}=  Get Length  ${BBMOD_ID_list}
    Run Keyword If  ${BBMOD_count} > 0
    ...  Log  NR BBMOD found: ${BBMOD_ID_list}  console=True
    ...  ELSE
    ...  Fail  No NR BBMOD are present in runtime view configuration!

    ${BBMOD_list}=  Create List  @{EMPTY}
    FOR  ${item}  IN  @{BBMOD_ID_list}
        ${BBMOD_PARAM_LIST}=     taf.sbts.oam.coam.admin.Get Parameters For  BBMOD  ${item}  alias=${alias}
        ${BBMOD_label}=     Fetch From Right  ${BBMOD_PARAM_LIST['id']}  /
        ${BBMOD_label_name}=    Replace String  ${BBMOD_label}  _R-  -
        @{temp}=     Create List
        ...  ${BBMOD_label_name}
        ...  ${BBMOD_PARAM_LIST['id']}
        ...  ${BBMOD_PARAM_LIST['operationalState']}
        ...  ${BBMOD_PARAM_LIST['administrativeState']}
        ...  ${BBMOD_PARAM_LIST['availabilityStatus']}
        Append To List  ${BBMOD_list}  ${temp}
    END
    Sort List  ${BBMOD_list}
    [Return]  ${BBMOD_list}

Admin Check BBMOD state
    [Documentation]
    ...  Helper keyword checking BBMOD administrative state info.
    ...
    ...  *AUTHOR*
    ...  adelina.ivan@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                   |
    ...  | bts_info_id          | Yes   | default | BTS ID from SCF               |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance   |
    ...
    [Arguments]  ${bts_info_id}  ${alias}=default
    ${BBMOD_LIST}=  Admin Get BBMOD info  ${alias}

    FOR  ${item}  IN  @{BBMOD_LIST}
        Run Keyword If  '${item[3]}'=='Locked'  Run Keywords
        ...  taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
        ...  dist_name=MRBTS-${bts_info_id}/EQM-1/APEQM-1/CABINET-1/${item[0]}
        ...  parameter=administrativeState  operation=update  value=Unlocked
        ...  skip_parameter_relation_errors=True  should_activate=True  timeout=900  alias=Master
        ...  AND  Log  BBMOD ${item[1]} Unlock indicated  console=True
    END

Admin Get RMOD state info
    [Documentation]
    ...  Helper keyword providing NR and LTE radio modules states info based on InfoModel class name.
    ...  KW is returning a list of lists with RMOD states info as below:
    ...  - name, distName, productName, operationalState, administrativeState, availabilityStatus, blockingState,
    ...  usageState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter        | Description                    |
    ...  | RMOD_STATE_LIST  | List of lists with RMOD states |

    [Arguments]  ${alias}=default
    ${RMOD_ID_LIST}=  taf.sbts.oam.coam.admin.Get Ids For All  RMOD  alias=${alias}
    Sort List  ${RMOD_ID_LIST}
    ${RMOD_STATE_LIST}=  Create List
    FOR  ${item}  IN  @{RMOD_ID_LIST}
        ${RMOD_PARAM_LIST}=  taf.sbts.oam.coam.admin.Get Parameters For  RMOD  ${item}  alias=${alias}
        ${RMOD_label}=  Fetch From Right  ${RMOD_PARAM_LIST['id']}  /
        @{temp}=  Create List
        ...  ${RMOD_label}
        ...  ${RMOD_PARAM_LIST['id']}
        ...  ${RMOD_PARAM_LIST['productName']}
        ...  ${RMOD_PARAM_LIST['operationalState']}
        ...  ${RMOD_PARAM_LIST['administrativeState']}
        ...  ${RMOD_PARAM_LIST['availabilityStatus']}
        ...  ${RMOD_PARAM_LIST['blockingState']}
        ...  ${RMOD_PARAM_LIST['usageState']}
        Append To List  ${RMOD_STATE_LIST}  ${temp}
    END
    Sort List  ${RMOD_STATE_LIST}
    [Return]  ${RMOD_STATE_LIST}

Admin Get LTE CELL state info
    [Documentation]
    ...  Helper keyword providing LTE cells states info.
    ...  KW is returning a list of lists with CELL states info as below:
    ...  - name, distName, operationalState, administrativeState, availabilityStatus,
    ...  blockingState, proceduralState. usageState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                    |
    ...  | LTE_CELL_STATE_LIST  | List of lists with CELL states |

    [Arguments]  ${alias}=default
    ${CELL_ID_LIST}  ${EMPTY}=  Admin Get LTE CELL Ids list  alias=${alias}
    ${LTE_CELL_STATE_LIST}=  Create List
    FOR  ${item}  IN  @{CELL_ID_LIST}
        ${CELL_PARAM_LIST}=  taf.sbts.oam.coam.admin.Get Parameters For  LNCEL  ${item}  alias=${alias}
        ${CELL_label}=  Fetch From Right  ${CELL_PARAM_LIST['id']}  /
        @{temp}=  Create List
        ...  ${CELL_label}
        ...  ${CELL_PARAM_LIST['id']}
        ...  ${CELL_PARAM_LIST['operationalState']}
        ...  ${CELL_PARAM_LIST['administrativeState']}
        ...  ${CELL_PARAM_LIST['availabilityStatus']}
        ...  ${CELL_PARAM_LIST['blockingState']}
        ...  ${CELL_PARAM_LIST['proceduralState']}
        ...  ${CELL_PARAM_LIST['usageState']}
        Append To List  ${LTE_CELL_STATE_LIST}  ${temp}
    END
    Sort List  ${LTE_CELL_STATE_LIST}
    [Return]  ${LTE_CELL_STATE_LIST}

Admin Get SBTS CELL state info
    [Documentation]
    ...  Helper keyword providing SBTS cells states info.
    ...  KW is returning a list of lists with CELL states info as below:
    ...  - operationalState, availabilityStatus, blockingState
    ...
    ...  *AUTHOR*
    ...  serban.hamza@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | Yes   |   N/A   | alias of taf.sbts.oam.coam.admin instance |
    ...  | tech_init            | Yes   |   N/A   | L=LTE, W=WCDMA, G=GSM       |
    ...
    ...  *RETURN*
    ...  | Parameter             | Description                    |
    ...  | SBTS_CELL_STATE_LIST  | List of lists with CELL states |

    [Arguments]  ${alias}  ${tech_init}
    ${CELL_ID_LIST}=  Admin Get LN WN GN CELL Ids list  ${alias}  ${tech_init}
    ${CELL_STATE_LIST}=  Create List
    FOR  ${item}  IN  @{CELL_ID_LIST}
        ${CELL_PARAM_LIST}=  taf.sbts.oam.coam.admin.Get Parameters For  ${tech_init}NCEL  ${item}  alias=${alias}
        ${CELL_label}=  Fetch From Right  ${CELL_PARAM_LIST['id']}  /
        @{temp}=  Create List
        ...  ${CELL_label}
        ...  ${CELL_PARAM_LIST['id']}
        ...  ${CELL_PARAM_LIST['operationalState']}
        ...  ${CELL_PARAM_LIST['availabilityStatus']}
        ...  ${CELL_PARAM_LIST['blockingState']}
        Append To List  ${CELL_STATE_LIST}  ${temp}
    END
    Sort List  ${CELL_STATE_LIST}
    [Return]  ${CELL_STATE_LIST}

Admin Get NR CELL state info
    [Documentation]
    ...  Helper keyword providing NR cells states info.
    ...  KW is returning a list of lists with CELL states info as below:
    ...  - name, distName, operationalState, administrativeState, availabilityStatus,
    ...  blockingState, proceduralStatus. usageState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter        | Description                    |
    ...  | CELL_STATE_LIST  | List of lists with CELL states |

    [Arguments]  ${alias}
    ${alias_upper}=  Convert to Uppercase  ${alias}
    ${CELL_ID_LIST}  ${EMPTY}=  Admin Get CELL Ids list  alias=${alias}
    ${CELL_STATE_LIST}=  Create List
    FOR  ${item}  IN  @{CELL_ID_LIST}
        ${CELL_PARAM_LIST}=  taf.sbts.oam.coam.admin.Get Parameters For  NRCEL  ${item}  alias=${alias}
        ${CELL_label}=  Fetch From Right  ${CELL_PARAM_LIST['id']}  /
        @{temp}=  Create List
        ...  ${CELL_label}
        ...  ${CELL_PARAM_LIST['id']}
        ...  ${CELL_PARAM_LIST['operationalState']}
        ...  ${CELL_PARAM_LIST['administrativeState']}
        ...  ${CELL_PARAM_LIST['availabilityStatus']}
        ...  ${CELL_PARAM_LIST['blockingState']}
        ...  ${CELL_PARAM_LIST['proceduralStatus']}
        ...  ${CELL_PARAM_LIST['usageState']}
        Append To List  ${CELL_STATE_LIST}  ${temp}
    END
    Sort List  ${CELL_STATE_LIST}
    [Return]  ${CELL_STATE_LIST}

Admin Check LTE Procedural and Blocking states
    [Documentation]
    ...  Helper keyword checking LTE proceduralState and blockingState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default   | Description                 |
    ...  | alias                | No    | default   | alias of taf.sbts.oam.coam.admin instance |
    ...  | exp pro state        | No    | OnAir     | expected proceduralState    |
    ...  | exp blk state        | No    | Unblocked | expected blockingState      |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description |
    ...  | Passed or Failed     | Fails if the given condition are not true |

    [Arguments]  ${alias}=default  ${exp pro state}=OnAir  ${exp blk state}=Unblocked  ${timeout}=90
    Log    ${timeout}
    ${BTS_state}=  Admin Get LTE BTS state info  alias=${alias}
    Log  ${BTS_state}
    Should Be True  '@{BTS_state}[1]'=='${exp pro state}' and '@{BTS_state}[2]'=='${exp blk state}'

Admin Check BTS Procedural and Blocking states
    [Documentation]
    ...  Helper keyword checking BTS proceduralState and blockingState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default   | Description                 |
    ...  | alias                | No    | default   | alias of taf.sbts.oam.coam.admin instance |
    ...  | exp pro state        | No    | OnAir     | expected proceduralState    |
    ...  | exp blk state        | No    | Unblocked | expected blockingState      |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description |
    ...  | Passed or Failed     | Fails if the given condition are not true |

    [Arguments]  ${exp_pro_state}=OnAir  ${exp_blk_state}=Unblocked  ${timeout}=90  ${alias}=default
    ${bts_id}=  taf.sbts.oam.coam.admin.Get Id For Current  BTS  timeout=${timeout}  alias=${alias}
    taf.sbts.oam.coam.admin.Assert  BTS  ${bts_id}  proceduralState=${exp_pro_state}, blockingState=${exp_blk_state}
    ...  timeout=${timeout}  alias=${alias}

Admin Check if BTS is unblocked
    [Documentation]
    ...  Helper keyword checking BTS blocking state info. If needed perform unblock BTS.
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                   |
    ...  | bts_dist_name        | Yes   |         | block target object dist_name |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance   |
    ...
    [Arguments]  ${bts_dist_name}  ${alias}=default
    ${LTE_BTS_STATE_LIST}=  Admin Get LTE BTS state info  ${alias}
    Run Keyword If  '${LTE_BTS_STATE_LIST[2]}'=='Blocked'  Run Keywords
    ...  Unblock  ${bts_dist_name}  alias=${alias}  timeout=600
    ...  AND  Log  BTS ${bts_dist_name} unblock indicated  console=True

Admin Check if all cells are unblocked
    [Documentation]
    ...  Helper keyword checking CELL blocking state info. If needed perform unblock CELL.
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    [Arguments]  ${alias}=default
    ${LTE_CELL_STATE_LIST}=  Admin Get LTE CELL state info  ${alias}
    FOR  ${item}  IN  @{LTE_CELL_STATE_LIST}
        Run Keyword If  '${item[5]}'=='Blocked'  Run Keywords
        ...  Unblock  ${item[1]}  alias=${alias}
        ...  AND  Sleep  30s  Wait for Cell ${item[0]} establish
        ...  AND  Log  Cell ${item[0]} unblock indicated  console=True
    END

Admin Check all cells to be unblocked
    [Documentation]
    ...  Helper keyword checking CELL blocking state info. If needed perform unblock CELL.
    ...
    ...  *AUTHOR*
    ...  serban.hamza@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | Yes   | N/A     | alias of taf.sbts.oam.coam.admin instance |
    ...  | tech_init            | Yes   | N/A     | L=LTE, W=WCDMA, G=GSM       |
    ...
    [Arguments]  ${alias}  ${tech_init}
    ${CELL_STATE_LIST}=  Admin Get SBTS CELL state info  ${alias}  ${tech_init}
    FOR  ${item}  IN  @{CELL_STATE_LIST}
        Run Keyword If  '${item[4]}'=='Blocked'  Run Keywords
        ...  Unblock  ${item[1]}  alias=${alias}
        ...  AND  Sleep  30s  Wait for Cell ${item[0]} establish
        ...  AND  Log  Cell ${item[0]} unblock indicated  console=True
    END

Admin Check if RMOD are unblocked
    [Documentation]
    ...  Helper keyword checking RMOD blocking state info. If needed perform unblock RMOD.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    [Arguments]  ${alias}=default
    ${LTE_RMOD_STATE_LIST}=  Admin Get LTE RMOD state info  ${alias}
    FOR  ${item}  IN  @{LTE_RMOD_STATE_LIST}
        Run Keyword If  '${item[6]}'=='Blocked'  Run Keywords
        ...  Unblock  ${item[1]}  alias=${alias}
        ...  AND  Sleep  30s  Wait for RMOD ${item[0]} establish
        ...  AND  Log  RMOD ${item[0]} unblock indicated  console=True
    END

Admin Collect scf.xml with timestamp
    [Documentation]
    ...  KW for collecting scf.xml from BTS to destination directory. Scf.xml gets name in form 'scf_time'
    ...  where time is the current time.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter   | Man. | Description                 |
    ...  | alias       | No   | alias of taf.sbts.oam.coam.admin instance |
    ...  | folder_path | No   | path of logs folder         |
    ...  | export_type | No   | configuration, configurationAndRuntimeObjects or runtimeObjects.
    ...  None means default Admin API behavior.
    ...                         By default is None |
    ...
    ...  *RETURN*
    ...  | Parameter     | Description                |
    ...  | ${alias}_scf  | Path to downloaded scf.xml |
    ...
    #[Arguments]  ${alias}=default  ${folder_path}=/home/ute/btsauto/logs  ${export_type}=${NONE}
    [Arguments]  ${alias}=default  ${folder_path}=/home/ute/btsauto/logs  ${export_type}=configurationAndRuntimeObjects
    ${time}=  Get time
    Set Test Variable  ${scf_path}  ${folder_path}/scf_${time}.xml
    taf.sbts.oam.coam.admin.Collect Scf  export_type=${export_type}  target_file_name=${scf_path}  alias=${alias}
    [Return]  ${scf_path}

Admin Get bts_id and perform commissioning
    [Documentation]
    ...  Helper keyword for commissioning via ADMIN. KW gets btsId from ADMIN and passes
    ...  it into original ute-admin.Perform Commissioning KW.
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                      | Man. | Default | Description |
    ...  | commissioning_path             | Yes  | empty   | Path to commissioning .xml file  |
    ...  | skip_parameter_relation_errors | No| true  | Boolean value: should parameter relation errors be skipped |
    ...  | timeout | No | 600   | Timeout for commissioning procedure (scf load, reset trigger, wait for reconnection)|

    [Arguments]  ${commissioning_path}  ${skip_parameter_relation_errors}=${TRUE}  ${timeout}=600
    ${bts_id}=   Admin Get BTS ID
    Log  Parameter bts_id: ${bts_id}                console=True
    Log  Commissioning via ADMIN will be performed  console=True
    Perform Commissioning   ${bts_id}  ${commissioning_path}
    ...  skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                     timeout=${timeout}

Admin Check Alarm Filtering Time
    [Documentation]
    ...  Keyword for checking if alarm appears in Admin within correct filtering time (specified in seconds).
    ...
    ...  *AUTHOR*
    ...  michal.grabas@nokia.com
    ...
    ...  *INPUT*
    ...  |  Parameter         |  Man. |  Description                                            |
    ...  |  parent_dist_name  |  Yes  |  DN of parent object for expected alarm                 |
    ...  |  filtering_time    |  Yes  |  Expected filtering time [s]                            |
    ...  |  delta             |  Yes  |  Acceptable deviation from expected filtering time [s]  |
    ...  |  fault_id          |  Yes  |  Expected fault ID                                      |

    [Arguments]  ${parent_dist_name}  ${filtering_time}  ${delta}  ${fault_id}
    ${start} =  Get Time  epoch
    ${filtering_time_max} =  Evaluate  ${filtering_time} + ${delta}
    ${filtering_time_min} =  Evaluate  ${filtering_time} - ${delta}
    ${object_exist} =  Check Infomodel Object  ${parent_dist_name}
    Run keyword if    not ${object_exist}  Fail  msg=No object found with given parent dist_name
    ${alarm_object} =  Run Keyword And Return Status  Wait For Alarm Presence
    ...  parent_dist_name=${parent_dist_name}  timeout=${filtering_time_max}  faultId=${fault_id}
    Run Keyword If  ${alarm_object}
    ...  Log  Alarm found  console=true  ELSE  Fail  msg=Alarm was not found within given filtering time
    ${stop} =  Get Time  epoch
    ${measured_filt_time} =  Evaluate  ${stop} - ${start}
    Should Be True  ${measured_filt_time} > ${filtering_time_min}  msg=Alarm appeared earlier than expected

Admin Check BTS state
    [Documentation]
    ...  KW for checking BTS proceduralState via ADMIN
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com

    [Arguments]  ${proc_state_value}
    ${bts_id}=  get id for current  BTS
    taf.sbts.oam.coam.admin.Assert  BTS  ${bts_id}  proceduralState=${proc_state_value}

Admin Get Wncel Ids
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${wcell_ids}: <description>
    ${wcell_ids}=  Create list  @{EMPTY}
    ${cells_dn}=   taf.sbts.oam.coam.admin.Get Ids for all  WNCEL
    FOR  ${cell_dn}  IN  @{cells_dn}
        ${wcell_id}=  Fetch from right  ${cell_dn}  -
        Append to list  ${wcell_ids}  ${wcell_id}
    END
    Sort list  ${wcell_ids}
    [Return]  ${wcell_ids}

Admin Get Modules For Interfaces
    [Documentation]
    ...  Return list of modules types and serial numbers
    ...
    ...  *AUTHOR*
    ...  michal.kwasniewicz@nokia.com

    ${smod_param}=    taf.sbts.oam.coam.admin.Get Parameters For All    SMOD
    ${rmod_param}=    taf.sbts.oam.coam.admin.Get Parameters For All    RMOD

    @{serial_number_list}=    Create List

    FOR  ${mod}  IN  @{smod_param}
        Append To List  ${serial_number_list}  SMOD_${mod.serialNumber}
    END
    FOR  ${mod}  IN  @{rmod_param}
        Append To List  ${serial_number_list}  RMOD_${mod.serialNumber}
    END
    [Return]  ${serial_number_list}

Verify modules states
    [Documentation]
    ...
    ...
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    [Arguments]  ${alias}=default  ${scf_check}=${TRUE}
    ${sm_state}=  Verify modules  SMOD  alias=${alias}  scf_check=${scf_check}
    ${rf_state}=  Verify modules  RMOD  alias=${alias}  scf_check=${scf_check}
    ${are_states_as_expected}=  Evaluate  ${sm_state} and ${rf_state}
    [Return]  ${are_states_as_expected}

Verify modules
    [Documentation]
    ...  Verify modules states
    ...  Default expected states are defined in the Variables section in hran_frame_sbts.
    ...  If `scf_check` is set to True,
    ...  the number of modules will be compared with the number of respective objects in SCF.
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ...
    ...  | Parameter       | Mandatory | Description                                                               |
    ...  | class_name       | Yes       | Class name for which states should be checked [SMOD, RMOD]|
    ...  | expected_states| No| Expected states as string,
    ...                                         e.g., "administrativeState=${_Unlocked}, operationalState=${_Enabled}"|
    ...

    [Arguments]  ${class_name}  ${expected_states}=${${class_name}_expected_states}
    ...  ${alias}=default  ${scf_check}=${TRUE}
    ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=
    ...  Get objects with expected states  ${expected_states}  ${class_name}  alias=${alias}

    Run keyword if  '${check_status}'=='FAIL'  Run keywords
    ...  Log  At least one ${class_name} module has state other than expected.  console=${TRUE}
    ...  AND  Return from keyword  ${FALSE}

    ${count_status}=  Run keyword if  ${scf_check}  Check SCF count  ${class_name}  ${RUNTIME_MODS}
    ...  ELSE  Set variable  ${TRUE}

    Run keyword if  ${count_status}  Log  All states of ${class_name} modules are as expected.  console=${TRUE}
    ...  ELSE  Log  At least one ${class_name} module has state other than expected.  console=${TRUE}
    [Return]  ${count_status}

Verify cells
    [Documentation]
    ...  Verify cells states
    ...  Expected states in default are setted from variables section in hran_frame_sbts
    ...  If scf_check==True, cells count will be verified with scf
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ...
    ...  | Parameter       | Mandatory | Description                                              |
    ...  | technology      | Yes       | Cell ID for which states should be checked [SMOD, RMOD] |
    ...  | expected_states | No        | Expected states as string
    ...                                       ex. "administrativeState=${_Unlocked}, operationalState=${_Enabled}" |
    ...
    ...  Return
    ...  False if at least one cell has state other than expected, or cells count in scf is not equal runtime cells
    ...
    [Arguments]  ${technology}  ${expected_states}=${cells_${technology}_expected_states}
    ...  ${alias}=default  ${scf_check}=${TRUE}
    ${technology_sign}=  Run keyword if  '${technology}'=='NR'
    ...    set variable    NR
    ...    ELSE
    ...    set variable    ${technology[0]}N
    ${check_status}  ${RUNTIME_CELLS}  ${ALL_CELLS}=
    ...  Get objects with expected states  ${expected_states}  ${technology_sign}CEL  alias=${alias}

    Run keyword if  '${check_status}'=='FAIL'  Run keywords
    ...  Log  At least one ${technology} cell has state other than expected.  console=${TRUE}
    ...  AND  Return from keyword  ${FALSE}

    ${count_status}=  Run keyword if  ${scf_check}  Check SCF count  ${technology}  ${ALL_CELLS}
    ...  ELSE  Set variable  ${TRUE}
    ${str1}=	Catenate	SEPARATOR=
    ...   All ${technology} cells are in expected state but the number of cells
    ...   defined in SCF differs from reported by Admin API.
    Run keyword if  ${count_status}  Log  All ${technology} cells are in expected state.  console=${TRUE}
    ...  ELSE  Log   ${str1}    console=${TRUE}

    # in case of specific RAT not configured
    ${cells_count}=     Get Length    ${ALL_CELLS}
    ${count_status}=  Set Variable If   '${cells_count}'=='0'    ${TRUE}    ${count_status}

    [Return]  ${count_status}

Get objects with expected states
    [Documentation]
    ...  Get objects from ADMIN and ensure their states
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** ---
    ...
    ...  | **Full description**
    ...  | All objects from given class (BTS, SMOD, BBU, RMOD, ALD, LNCEL, GNCEL or WNCEL) are fetched from BTS via
    ...  | ADMIN interface and their runtime states are compared to states passed in ${expected_states} variable.
    ...  | KW returns three variables - ${status} of whole KW (PASS, FAIL), ${matching_objects} - list of objects which
    ...  | matches expected states and ${class_ids} - a list of all dist names for given class fetched via ADMIN
    ...
    ...  **Input parameters**
    ...
    ...  +-----------------+------+----------------------------------------------------------------------------------+
    ...  | Parameter name  | Man. | Description                                                                 |
    ...  +=================+======+===========================================================================+
    ...  | expected states | yes  | Comma separated states with their valies
    ...                                          (i.e administrativeState=${_Unlocked}, operationalState=${_Enabled})  |
    ...  +-----------------+------+-----------------------------------------------------------------------------------+
    ...  | class_name      | yes  | ADMIN object class name (BTS, SMOD, BBU, RMOD, ALD, LNCEL, GNCEL or WNCEL)  |
    ...  +-----------------+------+---------------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=
    ...                                          Get objects with expected states  operationalState=${_Enabled},    ALD

    [Arguments]  ${expected states}  ${class name}  ${alias}=default
    ${class_ids}=  taf.sbts.oam.coam.admin.Get ids for all  ${class name}  alias=${alias}
    ${matching_objects}=  Create list
    ${matching_statuses}=  Create list
    FOR  ${item_id}  IN  @{class_ids}
        ${status}  ${item_parameters}=    run keyword if
        ...  'LNCEL_A' in '${item_id}'
        ...  set variable  FAIL    None
        ...  ELSE    Run keyword and ignore error
        ...  taf.sbts.oam.coam.admin.Assert  ${class name}  ${item_id}  ${expected states}  timeout=120  alias=${alias}
        #${status}  ${item_parameters}
        #=  Run keyword and ignore error  Assert  ${class name}
        #${item_id}  ${expected states}  timeout=600  alias=${alias}
        Run keyword if  '${status}'=='PASS'  Run keywords
        ...  Append to list  ${matching_objects}  ${item_parameters}  AND  Append to list  ${matching_statuses}  PASS
        ${iot_cell}=  Run keyword and return status  Should match regexp  ${item_id}  .*BTS_CONF.*SCF.*LNCEL
        Run keyword if  "${status}"=="FAIL" and ${iot_cell}  Append to list  ${matching_statuses}  PASS
        ${status}  ${item_parameters}=  Run keyword if  "${status}"=="FAIL" and not ${iot_cell}
        ...  Run keyword and ignore error
        ...  taf.sbts.oam.coam.admin.Assert  ${class name}  ${item_id}  availabilityStatus=NotInstalled  timeout=20
        ...  ELSE  Create list  PASS  NONE
        Run keyword if  "${status}"=="FAIL" and not ${iot_cell}  Append to list  ${matching_statuses}  FAIL
    END
    ${status}=  evaluate  "FAIL" if len(${class_ids})!=0 and "FAIL" in "${matching_statuses}" else "PASS"
    [Return]  ${status}  ${matching_objects}  ${class_ids}

Admin Check Cells Number
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
    ${id_list}=    taf.sbts.oam.coam.admin.Get Ids For All    ${technology}
    ${admin_cells_num}=    Evaluate    len(${id_list})
    Should Be Equal As Integers    ${expected_cells_number}    ${admin_cells_num}
    ...    Admin see different cells number than expected! Expected: ${expected_cells_number}
    ...  is not equal admin cells num: ${admin_cells_num}.

Reset admin and infomodel connection if broken
    [Documentation]    Check if Admin operations are possible. If not, reset admin and infomodel connections.
    ...  If allowed, and reset cause is other than soamif version change, will set TC restriction.
    ...  *AUTHOR*
    ...  agata.maslowska@nokia.com
    ...
    ...  *MAINTAINER*
    ...  tomasz.1.filipek@nokia.com
    [Arguments]  ${allowed_to_set_restriction}=${True}

    ${soamif exception}  set variable  Invalid soamIf version

    ${BTS_statecheck_status}  ${BTS_state}  Run keyword and ignore error  taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  '${BTS_statecheck_status}'=='PASS'  return from keyword  ${True}

    ${soamif change check}  Run keyword and return status  Should contain  ${BTS_state}  ${soamif exception}
    Run keyword if
    ...  ${soamif change check}  Log  Soamif change detected. Will reset admin and infomodel connection.  console=True
    ${should set restriction}  Evaluate  (${allowed_to_set_restriction}==${True}) and (${soamif change check}==${False})
    Run keyword if  ${should set restriction}  set test restriction  Admin reset required, no soamif change detected

    ${admin_reset_status}  Run keyword and return status  taf.sbts.oam.coam.admin.reset admin
    Log  Admin reset status: ${admin_reset_status}  console=True
    ${infomodel_reset_status}  Run keyword and return status
    ...  ute_admin_infomodel.reset infomodel  filename=${BTS Files}/IM/InfoModel_untilReset.ims2
    Log  Infomodel reset status: ${infomodel_reset_status}  console=True
    ${BTS_statecheck_status_after_reset}  ${BTS_state_after_reset}  Run keyword and ignore error  taf.sbts.oam.coam.admin.Get mrbts state
    ${temp_bool}=    Evaluate      ${admin_reset_status}==${True}
    ${temp_bool_1}=  Evaluate      ${infomodel_reset_status}==${True}
    ${temp_bool_2}=   Evaluate     '${BTS_statecheck_status_after_reset}'=='PASS'
    ${resets_status}     Evaluate   ${temp_bool} and ${temp_bool_1} and ${temp_bool_2}

    [Return]  ${resets_status}

Admin Enable SSH in Independent Execution Context
    [Documentation]
    ...  Enable SSH with admin instance independent of the one from hran_frame_sbts.
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    [Arguments]  ${bts_host}=192.168.255.129  ${bts_port}=443  ${use_ssl}=TRUE
    Log  Admin Enable SSH with setup (timeout=5 min) and teardown  console=${True}
    ${admin_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  5 min  15 sec
    ...  taf.sbts.oam.coam.admin.Setup Admin  admin_api_log_dir=${BTS Files}
    ...  bts_host=${bts_host}  bts_port=${bts_port}  use_ssl=${use_ssl}  alias=ssh
    ${ssh_status}=  Run keyword if  ${admin_status}  Run keyword and return status  Enable ssh access  alias=ssh
    Run keyword if  ${admin_status}  taf.sbts.oam.coam.admin.Teardown Admin  alias=ssh
    [Return]  ${ssh_status}

Admin Get cells connected to two RMODs
    [Documentation]
    ...  Get list with cells connected to at least two RMODs
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ${rmods_list}=  taf.sbts.oam.coam.admin.Get Ids For All  RMOD
    @{all_cells_list}=  Create list
    FOR  ${item}  IN  @{rmods_list}
        ${rmod_cells}=  Get Cell Mapping By Module Id  ${item}
        Append to list  ${all_cells_list}  @{rmod_cells}
    END
    ${cells_to_two_rmods}=  Evaluate
    ...  [item for item, count in collections.Counter(${all_cells_list}).items() if count > 1]  modules=collections
    [Return]  ${cells_to_two_rmods}

Set Test Norun if tested rmod have cells connected to two RMODs
    [Arguments]  ${rmod_cells}
    [Documentation]
    ...  Set Test Norun if tested rmod have cells connected to two RMODs
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ${cells_list}=  Admin Get cells connected to two RMODs
    FOR  ${cell}  IN  @{rmod_cells}
        ${status}=  Run keyword and return status  List Should Not Contain Value	 ${cells_list}  ${cell}
        Run keyword if    not ${status}  Set Test Norun  Test case doesn't support this configuration.
    END

Admin Collect PM Files
    [Documentation]
    ...  Procedure for PM collection as below:
    ...  - create ${folder_path} if it doesn't exist
    ...  - collect PM archive from BTS to VM
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    | Parameter       | Man. | Default                     | Description                   |
    ...    | alias           | no   | default                     | alias of taf.sbts.oam.coam.admin instance   |
    ...    | folder_path     | no   | ${Test Results Dir}/PMFiles | folder path for PM collection |
    ...    | PM_archive_name | no   | PM_LTE.zip                  | PM archive name               |

    [Timeout]  10 min
    [Arguments]  ${alias}=default  ${folder_path}=${Test Results Dir}/PMFiles  ${PM_archive}=PM_LTE.zip

    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${folder_path}
    Run keyword if    not ${status}  Create Directory  ${folder_path}

    Set Test Variable  ${${alias}_PM_ARCHIVE}  ${PM_archive}
    ${status}=  Run Keyword And Return Status
    ...  Collect Pm Files  target_file_name=${folder_path}/${${alias}_PM_ARCHIVE}  alias=${alias}
    Run keyword if    not ${status}  Run Keywords
    ...  Set Test Variable  ${PM_collect}  ${False}
    ...  AND  Log  ${alias} PM archive collection failed!  level=WARN

    Run Keyword If  ${PM_collect}  Check PM archive transfer  ${alias}  ${folder_path}/${${alias}_PM_ARCHIVE}

Admin Get LTE RM-CELL mapping list
    [Documentation]
    ...  Keyword providing LTE RM-CELL mapping information.
    ...  It outputs list which consist of [RM_DN, [CELL_DN]]
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter        | Description                 |
    ...  | LTE_RM_CELL_list | List of LTE-RM-CELL details |
    ...
    ...  *EXAMPLE*
    ...  | ${LTE_RM_CELL_list}= | Admin Get LTE RM-CELL mapping list | Master |

    [Arguments]  ${alias}=default
    ${RMOD_ID_LIST}=  taf.sbts.oam.coam.admin.Get Ids For All  RMOD  alias=${alias}
    Sort List  ${RMOD_ID_LIST}
    ${LTE_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{RMOD_ID_LIST}
        ${CELL_ID_LIST}=  Get Cell Mapping By Module Id  ${item}  alias=${alias}
        @{temp}=  Create List  ${item}  ${CELL_ID_LIST}
        Append To List  ${LTE_RM_CELL_list}  ${temp}
    END
    Sort List  ${LTE_RM_CELL_list}
    [Return]  ${LTE_RM_CELL_list}

Admin Get LTE CELL-RM mapping list
    [Documentation]
    ...  Keyword providing LTE CELL-RM mapping information.
    ...  It outputs list which consist of [CELL_DN, CELL_dlMimoMode,
    ...  CELL_syncSigTxMod, CELL_actOtdoa, CELL_actPrsTxDiv, [RM_DN]]
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter        | Description                 |
    ...  | LTE_CELL_RM_list | List of LTE_CELL_RM details |
    ...
    ...  *EXAMPLE*
    ...  | ${LTE_CELL_RM_list}= | Admin Get LTE CELL-RM mapping list | Master |

    [Arguments]  ${alias}=default
    ${LTE_LNBTS_parameters_list}=  Infomodel Get LTE txPathFailureMode  alias=${alias}
    ${LTE_CELL_parameters_list}=  Admin Get LTE CELL parameters list  alias=${alias}
    ${LTE_CELL_RM_list}=  Create List
    FOR  ${item}  IN  @{LTE_CELL_parameters_list}
        ${RM_list}=  Admin Get LTE RM mapped list  ${item[0]}  ${alias}
        @{temp}=  Create List  ${item[0]}  ${item[4]}  ${item[6]}  ${item[7]}  ${item[8]}  ${RM_list}
        Append To List  ${LTE_CELL_RM_list}  ${temp}
    END
    Sort List  ${LTE_CELL_RM_list}
    [Return]  ${LTE_CELL_RM_list}

Admin Get LTE CELL parameters list
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${alias}: <description>
    ...
    ...    Returns:
    ...        ${LTE_CELL_parameters_list}: <description>
    [Arguments]  ${alias}
    ${LTE_CELL_list}=  taf.sbts.oam.coam.admin.Get Cell List  alias=${alias}
    Set Test Variable  ${LTE_CELL_list}
    ${LTE_CELL_parameters_list}=  Create List
    FOR  ${item}  IN  @{LTE_CELL_list['cells']['lte']}
        ${LNCEL_A_param}=  Query Infomodel  query=get object //LNCEL_A-${item['globalCellId']}  alias=${alias}
        Continue For Loop If  '${LNCEL_A_param['cellTechnology']}' not in ['FDD','TDD']
        ${LNCEL_TECHNO_A_param}=  Query Infomodel
        ...  query=get object //LNCEL_A-${item['globalCellId']}/LNCEL_${LNCEL_A_param['cellTechnology']}_A-0
        ...  alias=${alias}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${item['globalCellId']}
        ...  ${item['cellName']}
        ...  ${item['eutranCellId']}
        ...  ${item['downlinkMimoMode']}
        ...  ${item['technology']}
        ...  ${LNCEL_TECHNO_A_param['syncSigTxMode']}
        ...  ${LNCEL_A_param['actOtdoa']}
        ...  ${LNCEL_A_param['actPrsTxDiv']}
        Append To List  ${LTE_CELL_parameters_list}  ${temp}
    END
    Sort List  ${LTE_CELL_parameters_list}
    [Return]  ${LTE_CELL_parameters_list}

Admin Get LTE CELL parameters list_exclude_LNCEL-A
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${alias}: <description>
    ...
    ...    Returns:
    ...        ${LTE_CELL_parameters_list}: <description>
    [Arguments]  ${alias}
    ${LTE_CELL_list}=  taf.sbts.oam.coam.admin.Get Cell List  alias=${alias}
    Set Test Variable  ${LTE_CELL_list}
    ${LTE_CELL_parameters_list}=  Create List
    FOR  ${item}  IN  @{LTE_CELL_list['cells']['lte']}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${item['globalCellId']}
        ...  ${item['cellName']}
        ...  ${item['eutranCellId']}
        ...  ${item['downlinkMimoMode']}
        ...  ${item['technology']}
        Append To List  ${LTE_CELL_parameters_list}  ${temp}
    END
    Sort List  ${LTE_CELL_parameters_list}
    [Return]  ${LTE_CELL_parameters_list}

Admin Get LTE RM mapped list
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${CELL_DN}: <description>
    ...        ${alias}: <description>
    ...
    ...    Returns:
    ...        ${RM_TxRx_mapped_list}: <description>
    [Arguments]  ${CELL_DN}  ${alias}
    ${LTE_RM_CELL_list}=  Admin Get LTE RM-CELL mapping list  alias=${alias}
    ${LTE_RM_mapped_list}=  Create List
    FOR  ${item}  IN  @{LTE_RM_CELL_list}
        ${map}=  Run Keyword And Return Status  List Should Contain Value  ${item[1]}  ${CELL_DN}
        Run Keyword If  '${map}' == 'True'  Append To List  ${LTE_RM_mapped_list}  ${item[0]}
    END
    Sort List  ${LTE_RM_mapped_list}
    ${RM_TxRx_mapped_list}=  Create List
    FOR  ${item}  IN  @{LTE_RM_mapped_list}
        ${RM_TxRx_list}=  Get RM TxRx List  ${CELL_DN}  ${item}
        Append To List  ${RM_TxRx_mapped_list}  ${RM_TxRx_list}
    END
    [Return]  ${RM_TxRx_mapped_list}

Get RM TxRx List
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Cell_DN}: <description>
    ...        ${RM_DN}: <description>
    ...
    ...    Returns:
    ...        ${RM_TxRx_list}: <description>
    [Arguments]  ${Cell_DN}  ${RM_DN}
    FOR  ${item}  IN  @{LTE_CELL_list['cells']['lte']}
        ${RM_TxRx_list}=  Run Keyword If  '${item['id']['internal']}' == '${Cell_DN}'
        ...  Get RM TxRx Info  ${item['carrierList']}  ${item['globalCellId']}  ${item['id']['internal']}  ${RM_DN}
        Exit For Loop If  '${item['id']['internal']}' == '${Cell_DN}'
    END
    [Return]  ${RM_TxRx_list}

Get RM TxRx Info
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${carrierList}: <description>
    ...        ${globalCellId}: <description>
    ...        ${Cell_DN}: <description>
    ...        ${RM_DN}: <description>
    ...
    ...    Returns:
    ...        ${RM_TxRx_list}: <description>
    [Arguments]  ${carrierList}  ${globalCellId}  ${Cell_DN}  ${RM_DN}
    Log    ${Cell_DN}
    ${RM_TxRx_list}=  Create List
    ${TxRx_list}=  Create List
    FOR  ${item}  IN  @{carrierList}
        ${cell_id}=  Get Regexp Matches  ${item['id']['configuration']}  LNCEL-\\d+
        ${cell_globalCellId}=  Should Match Regexp  ${cell_id[0]}  \\d+
        ${rm_id}=  Fetch From Left  ${item['antennaLineId']['internal']}  /ANTL_R
        Run Keyword If  '${cell_globalCellId}' == '${globalCellId}' and '${rm_id}' == '${RM_DN}'
        ...  Append To List  ${TxRx_list}  ${item['direction']}
    END
    Append To List  ${RM_TxRx_list}  ${RM_DN}  ${TxRx_list}
    [Return]  ${RM_TxRx_list}

Create dictionary of connections between cells and radio modules
    [Documentation]
    ...  Create a dictionary of connections between cells and radio modules in which
    ...  each item consists of a cell dist_name as key and a list of radio module dist_names as value.
    ...
    ...  Sets "CELL_TO_RMOD_CABLINK" as global dictionary
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                                   |
    ...  | CELL_TO_RMOD_CABLINK | Dictionary of rmods list connected with cells |
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ${lncel}=   taf.sbts.oam.coam.admin.Get ids for all  LNCEL
    ${wncel}=   taf.sbts.oam.coam.admin.Get ids for all  WNCEL
    ${gncel}=   taf.sbts.oam.coam.admin.Get ids for all  GNCEL
    ${cells_list}=  Evaluate  ${lncel}+${wncel}+${gncel}
    ${CELL_TO_RMOD_CABLINK}=  Evaluate  {cell:[] for cell in ${cells_list}}
    Set test variable  ${CELL_TO_RMOD_CABLINK}
    ${rmods_list}=  taf.sbts.oam.coam.admin.Get Ids For All  RMOD
    FOR  ${rm}  IN  @{rmods_list}
        ${cells_for_rm}=  Get Cell Mapping By Module Id  ${rm}
        _Update_cell_to_rmods_mapping  ${cells_for_rm}  ${rm}
    END
    [Return]  ${CELL_TO_RMOD_CABLINK}

_Update_cell_to_rmods_mapping
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${cells}: <description>
    ...        ${rm}: <description>
    [Arguments]  ${cells}  ${rm}
    FOR  ${cell}  IN  @{cells}
        ${rms_list}=  Get From Dictionary  ${CELL_TO_RMOD_CABLINK}  ${cell}
        ${rms_list}=  Evaluate  ${rms_list}+['${rm}']
        Set To Dictionary  ${CELL_TO_RMOD_CABLINK}  ${cell}  ${rms_list}
    END

Admin Validate SCF
    [Documentation]
    ...  KW for SCF validation. SCF can be provided as input argument:
    ...  - if valued with absolute file path of stored SCF
    ...  - if empty, current SCF will be collected and validated.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter          | Man. | Description                                                     |
    ...  | scf_path_file      | No   | SCF file  path                                                  |
    ...  | skip_param_rel_err | No   | skip parameter relation errors                                  |
    ...  | alias              | No   | alias of taf.sbts.oam.coam.admin instance                       |
    ...  | export_type        | No   | configuration, configurationAndRuntimeObjects or runtimeObjects |
    ...  | timeout            | No   | time to wait for positive procedure result                      |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                        |
    ...  | definition_errors_file | Path to definition_errors_file.txt |
    ...  | relation_errors_file   | Path to relation_errors_file.txt   |
    ...  | hardware_errors_file   | Path to hardware_errors_file.txt   |
    ...
    [Arguments]  ${scf_path_file}=${EMPTY}  ${skip_param_rel_err}=${TRUE}  ${alias}=default
    ...  ${export_type}=configuration  ${timeout}=180

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${scf_path_file}=  Run Keyword If  '${scf_path_file}' == '${EMPTY}'
    ...  Set Variable  ${Test Results Dir}/SCF_Validation/SCF_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.xml
    ...  ELSE  Set Variable  ${scf_path_file}

    Run Keyword If  '${scf_path_file}' != '${EMPTY}'
    ...  taf.sbts.oam.coam.admin.Collect Scf  target_file_name=${scf_path_file}
    ...    export_type=${export_type}  timeout=${timeout}  alias=${alias}

    Log  ${\n}=============  console=True
    Log  Validate SCF: ${scf_path_file}  console=True
    FOR  ${cycle}  IN RANGE  1  4
        Log  ${\n}=====================  console=True
        Log  SCF Validation cycle: ${cycle}  console=True
        ${errors_dict}  Validate scf  scf_file=${scf_path_file}
        ...  skip_parameter_relation_errors=${skip_param_rel_err}  timeout=${timeout}  alias=${alias}
        Log  ${\n}====================================  console=True
        Log  SCF Validation for Definition Errors  console=True
        ${definitionErrorsSize}=  Run Keyword If
        ...  '${errors_dict["niddValidationResult"]["logs"]["definitionErrors"]}'=='None'  Set Variable  0
        ...  ELSE  Get Length  ${errors_dict["niddValidationResult"]["logs"]["definitionErrors"]}
        ${def_err_evaluated}  Evaluate  str(${errors_dict["niddValidationResult"]})
        ${definition_errors_file}  Set Variable
        ...  ${Test Results Dir}/SCF_Validation/Definition_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
        Append To File  ${definition_errors_file}  ${def_err_evaluated}
        Run Keyword If  "${errors_dict["niddValidationResult"]["status"]}"=="OK"  Run Keywords
        ...  Log  Definition Errors Count: ${definitionErrorsSize}  level=INFO  console=True
        ...  AND  Log  Definition Errors Verdict: NIDD validation succeeded.  level=INFO  console=True
        ...  ELSE  Run Keywords
        ...  Log  Definition Errors Count: ${definitionErrorsSize}  level=INFO  console=True
        ...  AND  Log  Definition Errors Verdict:
        ...  Parameter validation errors: ${definitionErrorsSize}, please check ${definition_errors_file}!  level=WARN

        Log  ${\n}==================================  console=True
        Log  SCF Validation for Relation Errors  console=True
        ${relationErrorsSize}=  Get Length  ${errors_dict["pdlValidationResult"]["logs"]["relationErrors"]}
        ${rel_err_evaluated}  Evaluate  str(${errors_dict["pdlValidationResult"]["logs"]["relationErrors"]})
        ${relation_errors_file}
        ...  Set Variable
        ...  ${Test Results Dir}/SCF_Validation/Relation_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
        Append To File  ${relation_errors_file}  ${rel_err_evaluated}
        Run Keyword If  "${errors_dict["pdlValidationResult"]["status"]}"!="OK" and ${relationErrorsSize}!=0
        ...  Run Keywords
        ...  Log  Relation Errors Count: ${relationErrorsSize}  level=INFO  console=True
        ...  AND
        ...  Log  Relation Errors Verdict: Parameter validation errors present, please check ${relation_errors_file}
        ...  level=WARN
        ...  ELSE  Run Keywords
        ...  Log  Relation Errors Count: ${relationErrorsSize}  level=INFO  console=True
        ...  AND  Log  Relation Errors Verdict: Parameter relation validation succeeded.  level=INFO  console=True

        Log  ${\n}==================================  console=True
        Log  SCF Validation for Hardware Errors  console=True
        ${hardwareErrorsSize}=  Get Length  ${errors_dict["pdlValidationResult"]["logs"]["hardwareErrors"]}
        ${hard_err_evaluated}  Evaluate  str(${errors_dict["pdlValidationResult"]["logs"]["hardwareErrors"]})
        ${hardware_errors_file}  Set Variable
        ...  ${Test Results Dir}/SCF_Validation/Hardware_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
        Append To File  ${hardware_errors_file}  ${hard_err_evaluated}
        Run Keyword If  "${errors_dict["pdlValidationResult"]["status"]}"!="OK" and ${hardwareErrorsSize}!=0
        ...  Run Keywords
        ...  Log  Hardware Errors Count: ${hardwareErrorsSize}  level=INFO  console=True
        ...  AND
        ...  Log  Hardware Errors Verdict: Parameter validation errors present, please check ${relation_errors_file}
        ...  level=WARN
        ...  ELSE  Run Keywords
        ...  Log  Hardware Errors Count: ${hardwareErrorsSize}  level=INFO  console=True
        ...  AND  Log  Hardware Errors Verdict: Hardware relation validation succeeded.  level=INFO  console=True
        Run Keyword If  ${definitionErrorsSize} == 0 and ${relationErrorsSize} == 0 and ${hardwareErrorsSize} == 0
        ...  Return From Keyword  ${definition_errors_file}  ${relation_errors_file}  ${hardware_errors_file}
     END

    [Return]  ${definition_errors_file}  ${relation_errors_file}  ${hardware_errors_file}

Admin Validate SCF With Detected Hardware
    [Documentation]
    ...  KW for SCF validation with Detected Hardware. SCF can be provided as input argument:
    ...  - if valued with absolute file path of stored SCF
    ...  - if empty, current SCF will be collected and validated.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter          | Man. | Description                                                     |
    ...  | scf_path_file      | No   | SCF file  path                                                  |
    ...  | skip_param_rel_err | No   | skip parameter relation errors                                  |
    ...  | alias              | No   | alias of taf.sbts.oam.coam.admin instance                                     |
    ...  | export_type        | No   | configuration, configurationAndRuntimeObjects or runtimeObjects |
    ...  | timeout            | No   | time to wait for positive procedure result                      |
    ...
    ...  *RETURN*
    ...  | Parameter                     | Description                               |
    ...  | detected_hardware_errors_file | Path to detected_hardware_errors_file.txt |
    ...
    [Arguments]  ${scf_path_file}=${EMPTY}  ${skip_param_rel_err}=${TRUE}  ${alias}=default
    ...  ${export_type}=configuration  ${timeout}=180

    ${KW_err}=  Set Variable  No support for "validateScf"

    ${verdict}  ${result}=  Run Keyword And Ignore Error
    ...  taf.sbts.oam.coam.admin.Validate Scf Online  scf_file=${scf_path_file}
    ...  validation_type=DETECTED_HW  skip_parameter_relation_errors=${skip_param_rel_err}  timeout=${timeout}
    ...  alias=${alias}

    ${KW_exception}  Run Keyword And Return Status  Should contain  ${result}  ${KW_err}
    Run Keyword If  ${KW_exception}  Run Keywords
    ...  Log  Validate SCF With Detected Hardware not available in Admin CLI!  level=WARN
    ...  AND  Return From Keyword

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${scf_path_file}=  Run Keyword If  '${scf_path_file}' == '${EMPTY}'
    ...  Set Variable  ${Test Results Dir}/SCF_Validation/SCF_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.xml
    ...  ELSE  Set Variable  ${scf_path_file}

    Run Keyword If  '${scf_path_file}' != '${EMPTY}'
    ...  taf.sbts.oam.coam.admin.Collect Scf  target_file_name=${scf_path_file}  export_type=${export_type}  timeout=${timeout}  alias=${alias}

    Log  ${\n}=============  console=True
    Log  Validate SCF: ${scf_path_file}  console=True
    FOR  ${cycle}  IN RANGE  1  4
        Log  ${\n}=====================  console=True
        Log  SCF Validation cycle: ${cycle}  console=True
        ${errors_dict}  taf.sbts.oam.coam.admin.Validate Scf Online  scf_file=${scf_path_file}
        ...  validation_type=DETECTED_HW  skip_parameter_relation_errors=${skip_param_rel_err}  timeout=${timeout}
        ...  alias=${alias}
        Log  ${\n}=====================================  console=True
        Log  SCF Validation with Detected Hardware  console=True
        ${detectedhardwareErrorsSize}=
        ...  Get Length  ${errors_dict["requestMessage"]["detectedHwValidationResult"]["logs"]}
        ${detectedhardware_err_evaluated}  Evaluate  str(${errors_dict["requestMessage"]["detectedHwValidationResult"]})
        ${detectedhardware_errors_file}
        ...  Set Variable
        ...  ${Test Results Dir}/SCF_Validation/Detected_Hardware_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
        Append To File  ${detectedhardware_errors_file}  ${detectedhardware_err_evaluated}
        Run Keyword If
        ...  "${errors_dict["requestMessage"]["detectedHwValidationResult"]["status"]}"!="OK"
        ...  and ${detectedhardwareErrorsSize}!=0  Run Keywords
        ...  Log  Detected Hardware Errors Count: ${hardwareErrorsSize}  level=INFO  console=True
        ...  AND  Log  Detected Hardware Errors
        ...  Verdict: Parameter validation errors present, please check ${detectedhardware_errors_file}  level=WARN
        ...  ELSE  Run Keywords
        ...  Log  Detected Hardware Errors Count: ${detectedhardwareErrorsSize}  level=INFO  console=True
        ...  AND  Log  Detected Hardware Errors Verdict: Hardware relation validation succeeded.
        ...  There are no detected hardware errors.  level=INFO  console=True
        Run Keyword If  ${detectedhardwareErrorsSize} == 0
        ...  Return From Keyword  ${detectedhardwareErrorsSize}
    END
    [Return]  ${detectedhardwareErrorsSize}

Admin Get LTE CELL Ids list
    [Documentation]
    ...  Helper keyword providing LTE cells Ids for FDD+TDD and IOT (inband, guardband and standalone) technologies .
    ...  KW is returning two lists for FDD+TDD and IOT cells Ids
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter             | Man.  | Default | Description                 |
    ...  | alias                 | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter             | Description               |
    ...  | LTE_CELL_IDS_LIST     | List of FDD+TDD cells Ids |
    ...  | LTE_IOT_CELL_IDS_LIST | List of IOT cells Ids     |

    [Arguments]  ${alias}=default
    ${CELL_ID_LIST}=  taf.sbts.oam.coam.admin.Get Ids For All  LNCEL  alias=${alias}
    Sort List  ${CELL_ID_LIST}
    ${LTE_CELL_IDS_LIST}=  Create List
    ${LTE_IOT_CELL_IDS_LIST}=  Create List
    FOR  ${item}  IN  @{CELL_ID_LIST}
        ${CELL_PARAM_LIST}=  taf.sbts.oam.coam.admin.Get Parameters For  LNCEL  ${item}  alias=${alias}
        ${CELL_technology_found}=  Run Keyword And Return Status
        ...  Variable Should Exist  ${CELL_PARAM_LIST['technology']}
        ${CELL_cellTechnology_found}=
        ...  Run Keyword And Return Status  Variable Should Exist  ${CELL_PARAM_LIST['nbIoTCell']['cellTechnology']}
        ${CELL_nbIoTMode_found}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_PARAM_LIST['nbIoTMode']}
        Run Keyword If  ${CELL_technology_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['technology']}'=='FDD' or '${CELL_PARAM_LIST['technology']}'=='TDD'
        ...  Append To List  ${LTE_CELL_IDS_LIST}  ${CELL_PARAM_LIST['id']}
        Run Keyword If  ${CELL_cellTechnology_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['nbIoTCell']['cellTechnology']}'=='NB-IoT-FDD'
        ...  Append To List  ${LTE_IOT_CELL_IDS_LIST}  ${CELL_PARAM_LIST['nbIoTCell']['distName']}
        Run Keyword If  ${CELL_technology_found} and ${CELL_nbIoTMode_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['technology']}'=='NB-IoT-FDD'
        ...  and '${CELL_PARAM_LIST['nbIoTMode']}'=='standalone'
        ...  Append To List  ${LTE_IOT_CELL_IDS_LIST}  ${CELL_PARAM_LIST['id']}
    END
    Sort List  ${LTE_CELL_IDS_LIST}
    Sort List  ${LTE_IOT_CELL_IDS_LIST}

    [Return]  ${LTE_CELL_IDS_LIST}  ${LTE_IOT_CELL_IDS_LIST}

Admin Get CELL Ids list
    [Documentation]
    ...  Helper keyword providing NR or LTE cells Ids for FDD+TDD and IOT (inband, guardband and standalone)
    ...  technologies
    ...  KW is returning two lists for FDD+TDD and IOT cells Ids
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter             | Man.  | Default | Description                 |
    ...  | alias                 | Yes   | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter         | Description               |
    ...  | CELL_IDS_LIST     | List of FDD+TDD cells Ids |
    ...  | IOT_CELL_IDS_LIST | List of IOT cells Ids     |

    [Arguments]  ${alias}
    ${alias_upper}=  Convert to Uppercase  ${alias}
    ${alias_upper}=    Create List    LTE    WCDMA
    ${CELL_className}=  Run Keyword If  '${${alias_upper}\['${alias_upper}_TECH']}'=='LTE'  Set Variable  LNCEL
    ...  ELSE IF  '${${alias_upper}\['${alias_upper}_TECH']}'=='NR'  Set Variable  NRCEL
    ${CELL_ID_LIST}=  taf.sbts.oam.coam.admin.Get Ids For All  ${CELL_className}  alias=${alias}
    Sort List  ${CELL_ID_LIST}
    ${CELL_IDS_LIST}=  Create List
    ${IOT_CELL_IDS_LIST}=  Create List
    FOR  ${item}  IN  @{CELL_ID_LIST}
        ${CELL_PARAM_LIST}=  taf.sbts.oam.coam.admin.Get Parameters For  ${CELL_className}  ${item}  alias=${alias}
        ${CELL_technology_found}=
        ...  Run Keyword And Return Status  Variable Should Exist  ${CELL_PARAM_LIST['technology']}
        ${CELL_cellTechnology_found}=  Run Keyword And Return Status
        ...  Variable Should Exist  ${CELL_PARAM_LIST['nbIoTCell']['cellTechnology']}
        ${CELL_nbIoTMode_found}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_PARAM_LIST['nbIoTMode']}
        Run Keyword If  ${CELL_technology_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['technology']}'=='FDD' or '${CELL_PARAM_LIST['technology']}'=='TDD'
        ...  Append To List  ${CELL_IDS_LIST}  ${CELL_PARAM_LIST['id']}
        Run Keyword If  ${CELL_cellTechnology_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['nbIoTCell']['cellTechnology']}'=='NB-IoT-FDD'
        ...  Append To List  ${IOT_CELL_IDS_LIST}  ${CELL_PARAM_LIST['nbIoTCell']['distName']}
        Run Keyword If  ${CELL_technology_found} and ${CELL_nbIoTMode_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['technology']}'=='NB-IoT-FDD'
        ...  and '${CELL_PARAM_LIST['nbIoTMode']}'=='standalone'
        ...  Append To List  ${IOT_CELL_IDS_LIST}  ${CELL_PARAM_LIST['id']}
    END
    Sort List  ${CELL_IDS_LIST}
    Sort List  ${IOT_CELL_IDS_LIST}

    [Return]  ${CELL_IDS_LIST}  ${IOT_CELL_IDS_LIST}

Admin Get LN WN GN CELL Ids list
    [Documentation]
    ...  Helper keyword providing LTE/WCDMA/GSM cells Ids DNs.
    ...  KW is returning a list for LTE/WCDMA/GSM cells Ids
    ...
    ...  *AUTHOR*
    ...  serban.hamza@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter             | Man.  | Default | Description                 |
    ...  | alias                 | Yes   |   N/A   | alias of taf.sbts.oam.coam.admin instance |
    ...  | tech_init             | Yes   |   N/A   | L=LTE, W=WCDMA, G=GSM       |
    ...
    ...  *RETURN*
    ...  | Parameter               | Description                |
    ...  | TECH_CELL_IDS_LIST      | List of all TECH cells Ids |

    [Arguments]  ${alias}  ${tech_init}
    ${CELL_ID_LIST}=  taf.sbts.oam.coam.admin.Get Ids For All  ${tech_init}NCEL  alias=${alias}
    Sort List  ${CELL_ID_LIST}
    ${TECH_CELL_IDS_LIST}=  Create List
    FOR  ${item}  IN  @{CELL_ID_LIST}
        ${CELL_PARAM_LIST}=  taf.sbts.oam.coam.admin.Get Parameters For  ${tech_init}NCEL  ${item}  alias=${alias}
        Append To List  ${TECH_CELL_IDS_LIST}  ${CELL_PARAM_LIST['id']}
    END
    Sort List  ${TECH_CELL_IDS_LIST}

    [Return]  ${TECH_CELL_IDS_LIST}

Admin Check mplane connection
    [Documentation]
    ...  Check mplane connection on admin
	...
	...  | **Author:** jaroslaw.piszczala@nokia.com
	...  | **Maintainer:** jaroslaw.piszczala@nokia.com
	...  | **Released with version:** 45.0
    ...
	...  **Input Parameters:**
	...
	...  +----------------+------+------------------+------------------------------------------------------------------+
	...  | Parameter name | Man. | Default          | Description                                                      |
	...  +================+======+==================+==================================================================+
	...  | bts_host       | no   | ${MPLANE_IP}     | BTS ip to connect, in default MPLANE_IP from node configuration  |
	...  +----------------+------+------------------+------------------------------------------------------------------+
	...  | bts_port       | no   | 443              | BTS port to connect                                              |
	...  +----------------+------+------------------+------------------------------------------------------------------+
	...  | use_ssl        | no   | TRUE             | SSL flag                                                         |
	...  +----------------+------+------------------+------------------------------------------------------------------+
	...  | timeout        | no   | 1 min            | Timeout for connection to admin                                  |
	...  +----------------+------+------------------+------------------------------------------------------------------+
	...  | alias          | no   | mplane           | Connection alias                                                 |
	...  +----------------+------+------------------+------------------------------------------------------------------+
	...
    [Arguments]  ${bts_host}=${MPLANE_IP}  ${bts_port}=443  ${use_ssl}=TRUE  ${timeout}=1 min  ${alias}=mplane
    Log  Check mplane connection on Admin  console=${TRUE}
    Log  Trying to connect to admin (max ${timeout})   level=INFO  console=${TRUE}
    ${admin_started}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout}  15 sec
    ...  taf.sbts.oam.coam.admin.Setup Admin  admin_api_log_dir=${BTS Files}  bts_host=${bts_host}  bts_port=${bts_port}
    ...  use_ssl=${use_ssl}  alias=${alias}
    Return From Keyword If  '${admin_started}'=='False'  ${False}
    Log  Connection to admin with mplane (${bts_host}) successfully established!  level=INFO  console=${TRUE}

    ${BTS_statecheck_status}  ${BTS_state}  Run keyword and ignore error  taf.sbts.oam.coam.admin.Get mrbts state  alias=${alias}
    Return from keyword if  '${BTS_statecheck_status}'=='PASS'  ${True}
    [Return]  ${False}
    [Teardown]  taf.sbts.oam.coam.admin.Teardown Admin  alias=${alias}

Admin Get ids for all cells
    [Documentation]
    ...  Get IDs for all items of GNCEL, WNCEL and LNCEL class.
	...
	...  | **Author:** jaroslaw.piszczala@nokia.com
	...  | **Maintainer:** jaroslaw.piszczala@nokia.com
	...  | **Released with version:** 48.0
	...
    ${GNCEL ids}=  taf.sbts.oam.coam.admin.Get ids for all    GNCEL
    ${WNCEL ids}=  taf.sbts.oam.coam.admin.Get ids for all    WNCEL
    ${LNCEL ids}=  taf.sbts.oam.coam.admin.Get ids for all    LNCEL
    ${CELLS_ids}=  Evaluate  ${GNCEL ids}+${WNCEL ids}+${LNCEL ids}
    [Return]  ${CELLS_ids}

Admin Get ids for all cells TAF
    [Documentation]
    ...  Get IDs for all items of GNCEL, WNCEL, LNCEL and NRCEL class.
	...
	...  | **Author:** jaroslaw.piszczala@nokia.com
	...  | **Maintainer:** jaroslaw.piszczala@nokia.com
	...  | **Released with version:** 48.0
	...
    ${GNCEL ids}=  taf.sbts.oam.coam.admin.Get ids for all    GNCEL
    ${WNCEL ids}=  taf.sbts.oam.coam.admin.Get ids for all    WNCEL
    ${LNCEL ids}=  taf.sbts.oam.coam.admin.Get ids for all    LNCEL
    ${NRCEL ids}=  taf.sbts.oam.coam.admin.Get ids for all    NRCEL
    ${CELLS_ids}=  Evaluate  ${GNCEL ids}+${WNCEL ids}+${LNCEL ids}+${NRCEL ids}
    [Return]  ${CELLS_ids}

Admin Check SBTS cells, modules and alarms
    [Documentation]
    ...  Wrapper for methods used for system modules, radio modules, cells and alarms checking.
    ...
    ...  | **Author:** tomasz.1.filipek@nokia.com
	...  | **Maintainer:** tomasz.1.filipek@nokia.com
	...  | **Released with version:** 47.0
	...
	...  | **Full description:**
	...  | Verification is done via ADMIN interface. Additionally modules SNs and amount of cells and HW is compared
	...  | with SCF. User can pass alarm patterns which should be treat as critical or ignored. For patterns
	...  | documentation, please refer to Admin Check Active Alarms KW
	...
	...  **Input Parameters:**
	...
	...  +--------------------+------+------------+-------------------------------------------------------------------+
    ...  | Parameter name     | Man. | Default    | Description                                                        |
    ...  +====================+======+============+===================================================================+
    ...  | critical_patterns  | No   | @{EMPTY}   | Patterns of critical alarms which, if found, should fail the KW   |
    ...  +--------------------+------+------------+--------------------------------------------------------------+
    ...  | ignored_patterns   | No   | @{EMPTY}   | Patterns of ignored alarms which, if found, should
    ...                                                                                        not be taken into count |
    ...  +--------------------+------+------------+-------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${IGNORED_ALARM}=     Create Dictionary  faultId=49  notifier=/MRBTS-1/RAT-1/LTS-1/LNBTS_L-1/LNCEL_L-10660
    ...     ${IGNORED}=           Create List  ${IGNORED_ALARM}
    ...     ${CRITICAL_ALARM}=    Create Dictionary  faultId=21
    ...     ${CRITICAL}=          Create List  ${CRITICAL_ALARM}
    ...     Admin Check SBTS cells, modules and alarms  critical_patterns=${CRITICAL}  ignored_patterns=${IGNORED}

    [Arguments]  ${critical_patterns}=@{EMPTY}  ${ignored_patterns}=@{EMPTY}
    ${system_modules_working}=  Verify system modules states
    ${radio_modules_working}=  Verify radio modules states
    ${cells_GSM_onair}=  Verify GSM cells states
    ${cells_WCDMA_onair}=  Verify WCDMA cells states
    ${cells_LTE_onair}=  Verify LTE cells states
    ${alarms_status}  ${alarms_msg}=  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms  critical_patterns=${critical_patterns}  ignored_patterns=${ignored_patterns}
    [Teardown]  Run keyword if    not ${system_modules_working} and ${radio_modules_working}
    ...  and ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair} and '${alarms_status}'!='FAIL'
    ...  Fail  At least one module or cell indicates a faulty state or some critical alarms detected!

Admin Check Overall BTS Procedural State
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${expected_BTS_status}: <description>
    [Arguments]  ${expected_BTS_status}=OnAir
    Log  Verify BTS proceduralState  console=${True}
    ${bts_params}=  taf.sbts.oam.coam.admin.Get Parameters For All  BTS
    ${BTS_in_expected_status}=  Run keyword and return status  Should Match Regexp
    ...  ${bts_params[0].proceduralState}  ${expected_BTS_status}
    Run keyword if  ${BTS_in_expected_status}
    ...  Log  BTS Name: ${bts_params[0].btsName} is ${bts_params[0].proceduralState}!  console=${TRUE}
    ...  ELSE  Fail  BTS ${bts_params[0].btsName} has state other than expected. Expected: ${expected_BTS_status}
    ...  and received: ${bts_params[0].proceduralState}

Admin Get BTS CELL parameters list
   [Documentation]
    ...  Helper keyword providing LTE, WCDMA and GSM cell parameters info.
    ...  KW is returning three lists of lists with CELL parameters as below:
    ...  LTE_CELL_parameters_list:
    ...  - distName, globalCellId, narrowbandIotMode, cellName, eutranCellId, downlinkMimoMode,technology
    ...  WCDMA_CELL_parameters_list:
    ...  - distName, cellId
    ...  GSM_CELL_parameters_list:
    ...  - distName, gsmSectorID
    ...
    ...  *AUTHOR*
    ...  ana.tugui@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter                   | Description                              |
    ...  | LTE_CELL_parameters_list    | List of lists with LTE CELL parameters   |
    ...  | WCDMA_CELL_parameters_list  | List of lists with WCDMA CELL parameters |
    ...  | GSM_CELL_parameters_list    | List of lists with GSM CELL parameters   |

    ${BTS_CELL_list}=  taf.sbts.oam.coam.admin.Get Cell List
    ${LTE_CELL_parameters_list}=  Create List
    ${WCDMA_CELL_parameters_list}=  Create List
    ${GSM_CELL_parameters_list}=  Create List
    FOR  ${item}  IN  @{BTS_CELL_list['cells']['lte']}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${item['globalCellId']}
        ...  ${item['narrowbandIotMode']}
        ...  ${item['cellName']}
        ...  ${item['eutranCellId']}
        ...  ${item['downlinkMimoMode']}
        ...  ${item['technology']}
        Append To List  ${LTE_CELL_parameters_list}  ${temp}
    END
    Sort List  ${LTE_CELL_parameters_list}
    FOR  ${item}  IN  @{BTS_CELL_list['cells']['wcdma']}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${item['cellId']}
        Append To List  ${WCDMA_CELL_parameters_list}  ${temp}
    END
    Sort List  ${WCDMA_CELL_parameters_list}
    FOR  ${item}  IN  @{BTS_CELL_list['cells']['gsm']}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${item['gsmSectorID']}
        Append To List  ${GSM_CELL_parameters_list}  ${temp}
    END
    Sort List  ${GSM_CELL_parameters_list}
    [Return]  ${LTE_CELL_parameters_list}  ${WCDMA_CELL_parameters_list}  ${GSM_CELL_parameters_list}

Admin Get IDs for all LTE cells
    [Documentation]
    ...  Get ids for all lte cells
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.coml
    ...  | **Released with version:** 54.0
    ...
    ${lncel}=       taf.sbts.oam.coam.admin.Get parameters for all  LNCEL
    ${cell_ids}=    Evaluate  [cell['id'] for cell in ${lncel} if 'IoT' not in cell['technology'] ]
    [Return]  ${cell_ids}

Admin Get IDs for all IoT cells
    [Documentation]
    ...  Get ids for all iot cells
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** 56.0
    ...
    ${iot_standalone}=  Admin Get IDs for standalone IoT cells
    ${iot_inband}=      Admin Get IDs for inband IoT cells
    ${iot_ids}=         Evaluate  ${iot_standalone} + ${iot_inband}
    [Return]  ${iot_ids}

Admin Get IDs for standalone IoT cells
    [Documentation]
    ...  Get ids for all standalone iot cells
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** 56.0
    ...
    ${lncel}=           taf.sbts.oam.coam.admin.Get parameters for all  LNCEL
    ${iot_standalone}=  Evaluate  [cell['id'] for cell in ${lncel} if 'IoT' in cell['technology'] ]
    [Return]  ${iot_standalone}

Admin Get IDs for inband IoT cells
    [Documentation]
    ...  Get ids for all inband iot cells
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** 56.0
    ...
    ${lncel}=           taf.sbts.oam.coam.admin.Get parameters for all  LNCEL
    ${iot_inband}=      Evaluate  [cell['nbIoTCell']['distName'] for cell in ${lncel} if cell['nbIoTCell']]
    [Return]  ${iot_inband}

Admin Get LTE CELL IOT mapping list
    [Documentation]
    ...  Helper keyword providing LTE cells information related to IOT mapping
    ...  KW is returning a dictionary described as beneath:
    ...  - key: LTE cell DN
    ...  - value: LTE IOT cell DN (if IOT activated) or None (if IOT not activated)
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter             | Man.  | Default | Description                 |
    ...  | alias                 | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description           |
    ...  | LTE_cell_IOT_mapping_dict | Dictionary of LTE cells mapping IOT feature |

    [Arguments]  ${alias}=default
    ${LTE_cell_ids}  ${LTE_IOT_cell_ids}=  Admin Get LTE CELL Ids list  ${alias}
    Sort List  ${LTE_cell_ids}
    ${LTE_cell_IOT_mapping_dict}=  Create Dictionary
    FOR  ${item}  IN  @{LTE_cell_ids}
        ${cell_param_list}=  taf.sbts.oam.coam.admin.Get Parameters For  LNCEL  ${item}  alias=${alias}
        ${key_exist}=  Run keyword and return status  Get From Dictionary  ${cell_param_list}  nbIoTMode
        ${value}=  Set Variable If
        ...  '${key_exist}' == 'False'  None
        ...  '${cell_param_list['nbIoTMode']}' == 'disabled'  None
        ...  '${cell_param_list['nbIoTMode']}' != 'disabled'  ${CELL_PARAM_LIST['nbIoTCell']['distName']}
        Set To Dictionary  ${LTE_cell_IOT_mapping_dict}  ${item}  ${value}
    END
    [Return]  ${LTE_cell_IOT_mapping_dict}

Synchronize SMODs
    [Documentation]
    ...  Synchronize two System Modules if NotCommissioned state
    ...
    ...  *AUTHOR*
    ...  sebastian.burniak@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter             | Man.  | Default                      | Description                               |
    ...  | alias                 | No    | default                      | alias of taf.sbts.oam.coam.admin instance  |
    ...
    ...  *RETURN*

    [Arguments]   ${alias}=default
    Log    Synchronize SMODs   level=DEBUG
    ${im_object}=    ute_admin_infomodel.Get infomodel object    //RUNTIME_VIEW-*//NEIGHBOR_NODE_R-*
    ${sync_status}=    Run keyword and return status  taf.sbts.oam.coam.admin.Start sync    ${im_object['dist_name']}
    ...  alias=${alias}
    Run keyword if    ${sync_status}    Log   Synchronization succeeded    console=${TRUE}
    ...       ELSE    Fail    Synchronization failed

Admin Get E-UTRAN Cell IDs
    [Documentation]
    ...  Collect E-UTRAN cell ID from all LNCELs visible in ADMIN.
    ...
    ...  If there are no LNCELs or execution of this keyword fails, empty list is returned.
    ...
    ...  | **Author:** remigiusz.otocki@nokia.com
    ...  | **Maintainer:** remigiusz.otocki@nokia.com
    ...  | **Released with version:** 62.0
    ...
    ${eutran_cids}=  Create list
    ${status}  ${lncels}=  Run keyword and ignore error  taf.sbts.oam.coam.admin.Get parameters for all  LNCEL
    Run keyword if  '${status}' == 'FAIL'  Run keywords
    ...  Log  Collection of LNCEL objects from ADMIN API failed.  level=WARN
    ...  AND  Return from keyword  ${eutran_cids}

    FOR  ${lncel}  IN  @{lncels}
        ${lncel_id}=  Fetch from right  ${lncel['id']}  -
        ${eutran_cell_id_exists}=  Run keyword and return status  Get from dictionary  ${lncel}  eutraCelId
        ${cell_id}=  Convert to string  ${lncel['eutraCelId']}
        Run keyword if  ${eutran_cell_id_exists}  Append to list  ${eutran_cids}  ${cell_id}
    END
    Sort list  ${eutran_cids}
    [Return]  ${eutran_cids}

Admin Get LNCEL ID by E-UTRAN Cell ID
    [Documentation]
    ...  Request an LNCEL object and match the value under its "eutraCelId" key
    ...  to the value given by the user. Return LNCEL ID if these two values match.
    ...
    ...  If E-UTRAN Cell ID cannot be mapped to any LNCEL ID or "eutraCelId" key does not exist
    ...  in the object returned from ADMIN API, -1 is returned as a string.
    ...
    ...  | **Author:** remigiusz.otocki@nokia.com
    ...  | **Maintainer:** remigiusz.otocki@nokia.com
    ...  | **Released with version:** 55.0
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+-----------------------------------------------------+
    ...  | Parameter name | Man. | Description                                         |
    ...  +================+======+=====================================================+
    ...  | cell_id        | yes  | E-UTRAN cell ID that will be mapped to its LNCEL ID |
    ...  +----------------+------+-----------------------------------------------------+
    ...
    [Arguments]  ${eutran_cell_id}
    ${lncels}=  taf.sbts.oam.coam.admin.Get parameters for all  LNCEL
    FOR  ${lncel}  IN  @{lncels}
        ${lncel_id}=  Fetch from right  ${lncel['id']}  -
        ${eutran_cell_id_exists}=  Run keyword and return status  Get from dictionary  ${lncel}  eutraCelId
        ${cell_id}=  Convert to string  ${lncel['eutraCelId']}
        Return from keyword if  ${eutran_cell_id_exists} and ('${cell_id}' == '${eutran_cell_id}')  ${lncel_id}
    END
    [Return]  -1

Admin and Infomodel connections reset
    [Documentation]
    ...  Helper KW for Admin and Infomodel connections reset based on following triggers:
    ...  - SOAMIF change
    ...  - Admin issues
    ...  - on demand
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter             | Man.  | Default | Description                                                  |
    ...  | reset_req             | No    | False   | reset request for Admin and Infomodel connections, by default
    ...                                                                                                        False |
    ...  | alias                 | No    | default | alias of taf.sbts.oam.coam.admin instance                    |

    [Arguments]  ${reset_req}=${False}  ${alias}=default

    ${soamif_exception}=  Set Variable  Invalid soamIf version

    ${verdict}  ${result}=  Run Keyword And Ignore Error  taf.sbts.oam.coam.admin.Get Mrbts State  timeout=60  alias=${alias}
    Run Keyword If  '${verdict}' == 'PASS' and '${reset_req}' == '${False}'  Run Keywords
    ...  Log  No need for Admin and Infomodel connections reset.  console=True
    ...  AND  Return From Keyword

    ${filepath}=  Set Variable If  '${alias}' == 'default'  ${BTSFiles}  ${BTSFiles}/${alias}
    ${soamif_change_check}=  Run Keyword And Return Status  Should Contain  ${result}  ${soamif_exception}
    Run Keyword If  ${reset_req}  Run Keywords
    ...  Log  Admin and Infomodel connections are being reset on demand  console=True
    #...  AND  Reset Admin  alias=${alias}
    ...  AND  Customize_Reset_Admin
    ...  AND  Sleep  3s
    ...  AND  Customize_Reset_Infomodel
    #...  AND  Reset Infomodel  filename=${filepath}/InfoModel_untilReset.ims2  alias=${alias}
    ...  ELSE IF  ${soamif_change_check}  Run Keywords
    ...  Log  Admin and Infomodel connections are being reset due to Admin soamif change detected: ${result}
    ...  console=True
    ...  AND  taf.sbts.oam.coam.admin.Reset Admin  alias=${alias}
    ...  AND  Sleep  3s
    ...  AND  Reset Infomodel  filename=${filepath}/InfoModel_untilReset.ims2  alias=${alias}
    ...  ELSE IF  '${verdict}' != 'PASS'  Run Keywords
    ...  Log  Admin and Infomodel connections are being reset due to Admin error: ${result}  console=True
    ...  AND  taf.sbts.oam.coam.admin.Reset Admin  alias=${alias}
    ...  AND  Sleep  3s
    ...  AND  Reset Infomodel  filename=${filepath}/InfoModel_untilReset.ims2  alias=${alias}

    ${status}=  Run Keyword And Return Status  taf.sbts.oam.coam.admin.Get Mrbts State  timeout=60  alias=${alias}
    Run Keyword If  ${status}  Log  Admin and Infomodel connections are up after reset  console=True
    ...  ELSE  Fail  Admin and Infomodel connections are failed after reset

Customize_Reset_Admin
    [Documentation]    Short description.
    Run keyword and ignore error   taf.sbts.oam.coam.admin.Teardown All Aliases for Admin
    Start Admin

Customize_Reset_Infomodel
    [Documentation]    Short description.
     Run keyword and ignore error    Teardown All Aliases For Infomodel
     Start Infomodel

Admin Print Active Alarms
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${alias}: <description>
    ...        ${timeout}: <description>
    ...        ${output_file}: <description>
    [Arguments]  ${alias}=default  ${timeout}=300  ${output_file}=${EMPTY}
    ${active_alarms}=  taf.sbts.oam.coam.admin.Get Alarms  timeout=${timeout}  alias=${alias}
    ${pretty_active_alarms}=  Evaluate  pprint.pformat(${active_alarms}, indent=4)  modules=pprint
    Run keyword if    not '${output_file}'==''  Create File  ${output_file}  ${pretty_active_alarms}
    Log  Active alarms: ${pretty_active_alarms}  console=${True}

Admin Get Shared And Dedicated RM List
    [Documentation]
    ...  Helper keyword providing NR and LTE shared and dedicated radio modules
    ...  KW is returning lists of NR and LTE shared and dedicated radio modules
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter                | Description                |
    ...  | NR_shared_RMOD_list      | List of NR shared RMOD     |
    ...  | NR_dedicated_RMOD_list   | List of NR dedicated RMOD  |
    ...  | LTE_shared_RMOD_list     | List of LTE shared RMOD    |
    ...  | LTE_dedicated_RMOD_list  | List of LTE dedicated RMOD |

    ${NR_RMOD_id_list}=  taf.sbts.oam.coam.admin.Get Ids For All  RMOD  alias=Master
    Sort List  ${NR_RMOD_id_list}
    ${LTE_RMOD_id_list}=  taf.sbts.oam.coam.admin.Get Ids For All  RMOD  alias=Slave
    Sort List  ${LTE_RMOD_id_list}

    Get RMOD SN List  Master
    Get RMOD SN List  Slave

    ${NR_shared_RMOD_list}=  Create List  @{EMPTY}
    Set Test Variable  ${NR_shared_RMOD_list}
    ${LTE_shared_RMOD_list}=  Create List  @{EMPTY}
    Set Test Variable  ${LTE_shared_RMOD_list}

    FOR  ${item}  IN  @{NR_RMOD_id_list}
        Get NR and LTE Shared RMOD List  ${item}
    END

    Set Test Variable  ${NR_dedicated_RMOD_list}  ${NR_RMOD_id_list}
    Set Test Variable  ${LTE_dedicated_RMOD_list}  ${LTE_RMOD_id_list}
    FOR  ${item}  IN  @{NR_shared_RMOD_list}
        Remove Values From List  ${NR_dedicated_RMOD_list}  ${item}
    END
    FOR  ${item}  IN  @{LTE_shared_RMOD_list}
        Remove Values From List  ${LTE_dedicated_RMOD_list}  ${item}
    END
    [Return]  ${NR_shared_RMOD_list}  ${LTE_shared_RMOD_list}  ${NR_dedicated_RMOD_list}  ${LTE_dedicated_RMOD_list}

Admin Get Shared And Dedicated RM List for Master and Slave
    [Documentation]
    ...  Generic keyword providing shared and dedicated radio modules via Admin for Master-Slave configurations
    ...  KW will return 4 lists: Master_Shared_RMOD_list, Slave_Shared_RMOD_list, Master_dedicated_RMOD_list,
    ...  Slave_dedicated_RMOD_list
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter             | Man.  | Default | Description                                                   |
    ...  | alias_master          | Yes   | Master  | alias of master taf.sbts.oam.coam.admin instance              |
    ...  | alias_slave           | Yes   | Slave   | alias of slave taf.sbts.oam.coam.admin instance               |
    ...
    ...  *RETURN*
    ...  | Parameter                  | Description                                           |
    ...  | Master_Shared_RMOD_list    | List of Master shared RMOD                            |
    ...  | Slave_Shared_RMOD_list     | List of Slave shared RMOD                             |
    ...  | Master_dedicated_RMOD_list | List of Master dedicated RMOD                         |
    ...  | Slave_dedicated_RMOD_list  | List of Slave dedicated RMOD                          |

    [Arguments]  ${alias_master}=Master  ${alias_slave}=Slave

    ${Master_RMOD_id_list}=  taf.sbts.oam.coam.admin.Get Ids For All  RMOD  alias=${alias_master}
    Sort List  ${Master_RMOD_id_list}
    ${Slave_RMOD_id_list}=  taf.sbts.oam.coam.admin.Get Ids For All  RMOD  alias=${alias_slave}
    Sort List  ${Slave_RMOD_id_list}

    Get RMOD SN List  ${alias_master}
    Get RMOD SN List  ${alias_slave}

    ${Master_SN_RMOD_id_mapping}=  Create Dictionary
    ${Slave_SN_RMOD_id_mapping}=  Create Dictionary
    ${Shared_RMOD_SN_List}=  Create List  @{EMPTY}
    ${Master_Dedicated_RMOD_SN_List}=  Create List  @{EMPTY}
    ${Slave_Dedicated_RMOD_SN_List}=  Create List  @{EMPTY}
    ${Master_shared_RMOD_list}=  Create List  @{EMPTY}
    ${Slave_shared_RMOD_list}=  Create List  @{EMPTY}
    ${Master_dedicated_RMOD_list}=  Create List  @{EMPTY}
    ${Slave_dedicated_RMOD_list}=  Create List  @{EMPTY}

    FOR  ${SN_item}  IN  @{MASTER_RMOD_SN_list}
        Set To Dictionary  ${Master_SN_RMOD_id_mapping}  ${SN_item[0]}  ${SN_item[1]}
    END

    FOR  ${SN_item}  IN  @{SLAVE_RMOD_SN_list}
        Set To Dictionary  ${Slave_SN_RMOD_id_mapping}  ${SN_item[0]}  ${SN_item[1]}
    END

    FOR  ${SN_item}  IN  @{MASTER_RMOD_SN_list}
        Run Keyword If  '${SN_item[0]}' in @{Slave_SN_RMOD_id_mapping.keys()}
        ...  Append To List  ${Shared_RMOD_SN_List}  ${SN_item[0]}
        ...  ELSE  Append To List  ${Master_Dedicated_RMOD_SN_List}  ${SN_item[0]}
    END

    FOR  ${SN_item}  IN  @{SLAVE_RMOD_SN_list}
        Run Keyword If  '${SN_item[0]}' not in ${Shared_RMOD_SN_List}
        ...  Append To List  ${Slave_Dedicated_RMOD_SN_List}  ${SN_item[0]}
    END

    FOR  ${SN_item}  IN  @{Shared_RMOD_SN_List}
        ${value}=  Get From Dictionary  ${Master_SN_RMOD_id_mapping}  ${SN_item}
        Append To List  ${Master_shared_RMOD_list}  ${value}
        ${value}=  Get From Dictionary  ${Slave_SN_RMOD_id_mapping}  ${SN_item}
        Append To List  ${Slave_shared_RMOD_list}  ${value}
    END

    FOR  ${SN_item}  IN  @{Master_Dedicated_RMOD_SN_List}
        ${value}=  Get From Dictionary  ${Master_SN_RMOD_id_mapping}  ${SN_item}
        Append To List  ${Master_dedicated_RMOD_list}  ${value}
    END

    FOR  ${SN_item}  IN  @{Slave_Dedicated_RMOD_SN_List}
        ${value}=  Get From Dictionary  ${Slave_SN_RMOD_id_mapping}  ${SN_item}
        Append To List  ${Slave_dedicated_RMOD_list}  ${value}
    END

    Set Test Variable  ${Master_SN_RMOD_id_mapping}
    Set Test Variable  ${Slave_SN_RMOD_id_mapping}

    [Return]  ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}
    ...  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}

Get RMOD SN List
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${alias}: <description>
    [Arguments]  ${alias}
    ${alias_connection}=  Convert to Uppercase  ${alias}
    ${RMOD_SN_list}=  Create List  @{EMPTY}
    ${RMOD_param}=  taf.sbts.oam.coam.admin.Get Parameters For All  RMOD  alias=${alias}
    FOR  ${item}  IN  @{RMOD_param}
        ${Rmod_label}=  Fetch From Right  ${item.id}  /
        @{temp}=  Create List  ${item.serialNumber}  ${item.id}
        Append To List  ${RMOD_SN_list}  ${temp}
    END
    Sort List  ${RMOD_SN_list}
    Set Test Variable  ${${alias_connection}_RMOD_SN_list}  ${RMOD_SN_list}

Get NR and LTE Shared RMOD List
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${NR_RMOD_id}: <description>
    [Arguments]  ${NR_RMOD_id}
    FOR  ${item}  IN  @{MASTER_RMOD_SN_list}
        Run Keyword If  '${item[1]}' == '${NR_RMOD_id}'
        ...  Set NR and LTE Shared RMOD List  ${item[0]}  ${NR_RMOD_id}
    END

Set NR and LTE Shared RMOD List
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RMOD_SN}: <description>
    ...        ${RMOD_id}: <description>
    [Arguments]  ${RMOD_SN}  ${RMOD_id}
    FOR  ${item}  IN  @{SLAVE_RMOD_SN_list}
        Run Keyword If   '${item[0]}' == '${RMOD_SN}'  Run Keywords
        ...  Append To List  ${NR_shared_RMOD_list}  ${RMOD_id}
        ...  AND  Set Test Variable  ${NR_shared_RMOD_list}
        ...  AND  Append To List  ${LTE_shared_RMOD_list}  ${item[1]}
        ...  AND  Set Test Variable  ${LTE_shared_RMOD_list}
        ...  AND  Exit For Loop
    END

Admin Check if all cells are unlocked
    [Documentation]
    ...  Helper keyword checking CELL administrative state info. If needed perform unlock CELL.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    [Arguments]  ${alias}=default
    ${NR_CELL_list}=  taf.sbts.oam.coam.admin.Get Ids For All  NRCEL  alias=${alias}
    FOR  ${item}  IN  @{NR_CELL_list}
        ${status}=  Run Keyword And Return Status
        ...  taf.sbts.oam.coam.admin.Assert  NRCEL  ${item}  administrativeState=Locked  timeout=3  alias=${alias}
        Run Keyword If  ${status}  Run Keywords
        ...  Unlock  ${item}  alias=${alias}
        ...  AND  Sleep  30s  Wait for Cell ${item} establish
        ...  AND  Log  Cell ${item} unlock indicated  console=True
    END

Admin Check if all rmod are unlocked
    [Documentation]
    ...  Helper keyword checking RMOD administrative state info. If needed perform unlock RMOD.
    ...
    ...  *AUTHOR*
    ...  serban.hamza@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    [Arguments]  ${alias}=default
    ${NR_RMOD_list}=  taf.sbts.oam.coam.admin.Get Ids For All  RMOD  alias=${alias}
    FOR  ${item}  IN  @{NR_RMOD_list}
        ${status}=  Run Keyword And Return Status
        ...  taf.sbts.oam.coam.admin.Assert  RMOD  ${item}  administrativeState=Locked  timeout=3  alias=${alias}
        Run Keyword If  ${status}  Run Keywords
        ...  Unlock  ${item}  alias=${alias}
        ...  AND  Sleep  30s  Wait for RMOD ${item} establish
        ...  AND  Log  RMOD ${item} unlock indicated  console=True
    END

Admin Check BTS RAT Procedural State
    [Documentation]
    ...  Helper keyword checking BTS each RAT Procedural State based on cells state: at least one cell should be with
    ...  operationalState=${_Enabled},
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man.  | Default                                             | Description                 |
    ...  | exp state | No    | operationalState=${_Enabled},   | expected states             |
    ...  | alias     | No    | Master                                      | alias of taf.sbts.oam.coam.admin instance|
    ...  | timeout   | No    | 90 sec                                              | timeout                     |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description |
    ...  | Passed or Failed     | Fails if the given condition is not true |

    [Arguments]  ${exp_state}=operationalState=${_Enabled},    ${alias}=Master  ${timeout}=90
    Log    ${exp_state}
    ${LTE_cells_operational}=  Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_LTE_cell_ids}
    ...  Run Keyword And Return Status  taf.sbts.oam.coam.admin.Assert Any  LNCEL  operationalState=${_Enabled},    ${timeout}  ${alias}

    ${WCDMA_cells_operational}=  Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_WCDMA_cell_ids}
    ...  Run Keyword And Return Status  taf.sbts.oam.coam.admin.Assert Any  WNCEL  operationalState=${_Enabled},    ${timeout}  ${alias}

    ${GSM_cells_operational}=  Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_GSM_cell_ids}
    ...  Run Keyword And Return Status  taf.sbts.oam.coam.admin.Assert Any  GNCEL  operationalState=${_Enabled},    ${timeout}  ${alias}

    Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_LTE_cell_ids}
    ...  Run Keyword If  ${LTE_cells_operational}
    ...  Log  LTE RAT - ProceduralState: OnAir  level=INFO  console=True
    Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_LTE_cell_ids}
    ...  Run keyword if    not ${LTE_cells_operational}  Run Keywords
    ...  Log  LTE RAT - ProceduralState: not OnAir!  level=ERROR
    ...  AND  Fail  LTE RAT - ProceduralState: not OnAir!

    Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_WCDMA_cell_ids}
    ...  Run Keyword If  ${WCDMA_cells_operational}
    ...  Log  WCDMA RAT - ProceduralState: OnAir  level=INFO  console=True
    Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_WCDMA_cell_ids}
    ...  Run keyword if    not ${WCDMA_cells_operational}  Run Keywords
    ...  Log  WCDMA RAT - ProceduralState: not OnAir!  level=ERROR
    ...  AND  Fail  WCDMA RAT - ProceduralState: not OnAir!

    Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_GSM_cell_ids}
    ...  Run Keyword If  ${GSM_cells_operational}
    ...  Log  GSM RAT - ProceduralState: OnAir  level=INFO  console=True
    Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_GSM_cell_ids}
    ...  Run keyword if    not ${GSM_cells_operational}  Run Keywords
    ...  Log  GSM RAT - ProceduralState: not OnAir!  level=ERROR
    ...  AND  Fail  GSM RAT - ProceduralState: not OnAir!

Admin Get SBTS RM-CELL mapping list
    [Documentation]
    ...  Keyword providing SBTS RM-CELL mapping information.
    ...  It outputs list which consist of [RM_DN, [CELL_DN]]
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter        | Description                 |
    ...  | SBTS_RM_CELL_list | List of SBTS-RM-CELL details |
    ...
    ...  *EXAMPLE*
    ...  | ${SBTS_RM_CELL_list}= | Admin Get SBTS RM-CELL mapping list | Master |

    [Arguments]  ${alias}=default
    ${RMOD_ID_LIST}=  taf.sbts.oam.coam.admin.Get Ids For All  RMOD  alias=${alias}
    Sort List  ${RMOD_ID_LIST}
    ${SBTS_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{RMOD_ID_LIST}
        ${CELL_ID_LIST}=  Get Cell Mapping By Module Id  ${item}  alias=${alias}
        @{temp}=  Create List  ${item}  ${CELL_ID_LIST}
        Append To List  ${SBTS_RM_CELL_list}  ${temp}
    END
    Sort List  ${SBTS_RM_CELL_list}
    [Return]  ${SBTS_RM_CELL_list}

Admin Get SBTS CELL-RM mapping list
    [Documentation]
    ...  Keyword providing SBTS CELL-RM mapping information.
    ...  It outputs for each RAT list which consist of [CELL_DN, CELL_dlMimoMode,
    ...  CELL_syncSigTxMod, CELL_actOtdoa, CELL_actPrsTxDiv, [RM_DN]]
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter        | Description                 |
    ...  | SBTS_CELL_RM_list | List of SBTS_CELL_RM details |
    ...
    ...  *EXAMPLE*
    ...  | ${LTE_CELL_RM_list}  ${WCDMA_CELL_RM_list}= | Admin Get SBTS CELL-RM mapping list | Master |

    [Arguments]  ${alias}=default
    ${LTE_LNBTS_parameters_list}=  Infomodel Get LTE txPathFailureMode  alias=${alias}
    ${LTE_CELL_parameters_list}=  Admin Get LTE CELL parameters list  alias=${alias}
    ${LTE_CELL_RM_list}=  Create List
    FOR  ${item}  IN  @{LTE_CELL_parameters_list}
        ${RM_list}=  Admin Get LTE RM mapped list  ${item[0]}  ${alias}
        @{temp}=  Create List  ${item[0]}  ${item[4]}  ${item[6]}  ${item[7]}  ${item[8]}  ${RM_list}
        Append To List  ${LTE_CELL_RM_list}  ${temp}
    END
    Sort List  ${LTE_CELL_RM_list}
    ${WCDMA_CELL_parameters_list}=  Admin Get SBTS-WCDMA CELL parameters list  alias=${alias}
    ${WCDMA_CELL_RM_list}=  Create List
    FOR  ${item}  IN  @{WCDMA_CELL_parameters_list}
        ${RM_list}=  Admin Get SBTS-WCDMA RM mapped list  ${item[0]}  ${alias}
        @{temp}=  Create List  ${item[0]}  ${item[2]}  ${item[3]}  ${RM_list}
        Append To List  ${WCDMA_CELL_RM_list}  ${temp}
    END
    Sort List  ${WCDMA_CELL_RM_list}
    [Return]  ${LTE_CELL_RM_list}  ${WCDMA_CELL_RM_list}

Admin Get SBTS-WCDMA CELL parameters list
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${alias}: <description>
    ...
    ...    Returns:
    ...        ${WCDMA_CELL_parameters_list}: <description>
    [Arguments]  ${alias}
    ${BTS_CELL_list}=  taf.sbts.oam.coam.admin.Get Cell List  alias=${alias}
    Set Test Variable  ${BTS_CELL_list}
    ${WCDMA_CELL_parameters_list}=  Create List
    FOR  ${item}  IN  @{BTS_CELL_list['cells']['wcdma']}
        ${WNCEL_A_param}=  Query Infomodel  query=get object //WNCEL_A-${item['cellId']}  alias=${alias}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${item['cellId']}
        ...  ${WNCEL_A_param['mimoType']}
        ...  ${WNCEL_A_param['vamEnabled']}
        Append To List  ${WCDMA_CELL_parameters_list}  ${temp}
    END
    Sort List  ${WCDMA_CELL_parameters_list}
    [Return]  ${WCDMA_CELL_parameters_list}

Admin Get SBTS-WCDMA RM mapped list
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${CELL_DN}: <description>
    ...        ${alias}: <description>
    ...
    ...    Returns:
    ...        ${RM_TxRx_mapped_list}: <description>
    [Arguments]  ${CELL_DN}  ${alias}
    ${SBTS_RM_CELL_list}=  Admin Get SBTS RM-CELL mapping list  alias=${alias}
    ${WCDMA_RM_mapped_list}=  Create List
    FOR  ${item}  IN  @{SBTS_RM_CELL_list}
        ${map}=  Run Keyword And Return Status  List Should Contain Value  ${item[1]}  ${CELL_DN}
        Run Keyword If  '${map}' == 'True'  Append To List  ${WCDMA_RM_mapped_list}  ${item[0]}
    END
    Sort List  ${WCDMA_RM_mapped_list}
    ${RM_TxRx_mapped_list}=  Create List
    FOR  ${item}  IN  @{WCDMA_RM_mapped_list}
        ${RM_TxRx_list}=  Get SBTS-WCDMA RM TxRx List  ${CELL_DN}  ${item}
        Append To List  ${RM_TxRx_mapped_list}  ${RM_TxRx_list}
    END
    [Return]  ${RM_TxRx_mapped_list}

Get SBTS-WCDMA RM TxRx List
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Cell_DN}: <description>
    ...        ${RM_DN}: <description>
    ...
    ...    Returns:
    ...        ${RM_TxRx_list}: <description>
    [Arguments]  ${Cell_DN}  ${RM_DN}
    Log    ${Cell_DN}
    FOR  ${item}  IN  @{BTS_CELL_list['cells']['wcdma']}
        ${RM_TxRx_list}=  Run Keyword If  '${item['id']['internal']}' == '${Cell_DN}'
        ...  Get SBTS-WCDMA RM TxRx Info  ${item['carrierList']}  ${item['cellId']}  ${item['id']['internal']}  ${RM_DN}
        Exit For Loop If  '${item['id']['internal']}' == '${Cell_DN}'
    END
    [Return]  ${RM_TxRx_list}

Get SBTS-WCDMA RM TxRx Info
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${carrierList}: <description>
    ...        ${cellId}: <description>
    ...        ${Cell_DN}: <description>
    ...        ${RM_DN}: <description>
    ...
    ...    Returns:
    ...        ${RM_TxRx_list}: <description>
    [Arguments]  ${carrierList}  ${cellId}  ${Cell_DN}  ${RM_DN}
    Log    ${Cell_DN}
    ${RM_TxRx_list}=  Create List
    ${TxRx_list}=  Create List
    FOR  ${item}  IN  @{carrierList}
        ${cell_id}=  Get Regexp Matches  ${item['id']['configuration']}  WNCEL-\\d+
        ${cell_cellId}=  Should Match Regexp  ${cell_id[0]}  \\d+
        ${rm_id}=  Fetch From Left  ${item['antennaLineId']['internal']}  /ANTL_R
        Run Keyword If  '${cell_id[0]}' == '${cellId[0]}' and '${rm_id}' == '${RM_DN}'
        ...  Append To List  ${TxRx_list}  ${item['direction']}
    END
    Append To List  ${RM_TxRx_list}  ${RM_DN}  ${TxRx_list}
    [Return]  ${RM_TxRx_list}

Check SBTS cell state
    [Documentation]
    ...  Keyword used to check SBTS cell state on any choosen technology (LNCEL, WNCEL, GNCEL) according to:
    ...  availabilityStatus, blockingState, operationalState.
    ...
    ...  *AUTHOR*
    ...  serban.hamza@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Description                          |
    ...  | cell_class_name      | Yes   | e.g. LNCEL, GNCEL or WNCEL           |
    ...  | alias                | No    | alias of taf.sbts.oam.coam.admin instance          |
    ...  | availabilityStatus   | Yes   | Possible values Online or Offline    |
    ...  | blockingState        | Yes   | Possible values Blocked or Unblocked |
    ...  | operationalState     | Yes   | Possible values Enabled or Disabled  |
    ...
    ...  *EXAMPLE*
    ...  Check SBTS cell state | LNCEL | Online | Unblocked | Enabled |

    [Arguments]  ${cell_class_name}  ${alias}  ${availabilityStatus}  ${blockingState}  ${operationalState}
    Log  Check SBTS ${cell_class_name} cells state:  console=True
    taf.sbts.oam.coam.admin.Assert Every  ${cell_class_name}  availabilityStatus=${availabilityStatus}, blockingState=${blockingState},
    ...  operationalState=${operationalState}  timeout=30  alias=${alias}

Admin Check if BTS cells are unblocked
    [Documentation]
    ...  Helper keyword checking CELL administrative state info. If needed perform unlock CELL.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                 |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...
    [Arguments]  ${alias}=default
    ${BTS_LTE_CELL_list}=  taf.sbts.oam.coam.admin.Get Ids For All  LNCEL  alias=${alias}
    FOR  ${item}  IN  @{BTS_LTE_CELL_list}
        ${status}=  Run Keyword And Return Status
        ...  taf.sbts.oam.coam.admin.Assert  LNCEL  ${item}  blockingState=Blocked  timeout=3  alias=${alias}
        Run Keyword If  ${status}  Run Keywords
        ...  Unblock  ${item}  alias=${alias}
        ...  AND  Sleep  30s  Wait for Cell ${item} establish
        ...  AND  Log  Cell ${item} unblock indicated  console=True
    END
    ${BTS_WCDMA_CELL_list}=  taf.sbts.oam.coam.admin.Get Ids For All  WNCEL  alias=${alias}
    FOR  ${item}  IN  @{BTS_WCDMA_CELL_list}
        ${status}=  Run Keyword And Return Status
        ...  taf.sbts.oam.coam.admin.Assert  WNCEL  ${item}  blockingState=Blocked  timeout=3  alias=${alias}
        Run Keyword If  ${status}  Run Keywords
        ...  Unblock  ${item}  alias=${alias}
        ...  AND  Sleep  30s  Wait for Cell ${item} establish
        ...  AND  Log  Cell ${item} unblock indicated  console=True
    END
    ${BTS_GSM_CELL_list}=  taf.sbts.oam.coam.admin.Get Ids For All  GNCEL  alias=${alias}
    FOR  ${item}  IN  @{BTS_GSM_CELL_list}
        ${status}=  Run Keyword And Return Status
        ...  taf.sbts.oam.coam.admin.Assert  GNCEL  ${item}  blockingState=Blocked  timeout=3  alias=${alias}
        Run Keyword If  ${status}  Run Keywords
        ...  unblock  ${item}  alias=${alias}
        ...  AND  Sleep  30s  Wait for Cell ${item} establish
        ...  AND  Log  Cell ${item} unblock indicated  console=True
    END

Admin Check if SBTS TRX are unblocked
    [Documentation]
    ...  Helper keyword checking SBTS GSM TRXs blocking state info. If needed perform unblock SBTS GSM TRX.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                   |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance   |
    ...
    [Arguments]  ${alias}=default
    ${SBTS_GSM_CELL_list}=  taf.sbts.oam.coam.admin.Get Ids For All  GNCEL  alias=${alias}
    FOR  ${item}  IN  @{SBTS_GSM_CELL_list}
        ${TRX_list}=  Query Infomodel  get list ${item}/CARRIERGROUPC_R-*  alias=${alias}
        Unblock SBTS GSM TRXs  ${TRX_list}  ${alias}
    END

Unblock SBTS GSM TRXs
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${TRX_list}: <description>
    ...        ${alias}: <description>
    [Arguments]  ${TRX_list}  ${alias}=default
    FOR  ${item}  IN  @{TRX_list}
        ${TRX_state}=  Query Infomodel  get object ${item['dist_name']}  alias=${alias}
        Run Keyword If  '${TRX_state['stateInfo']['blockingState']}'=='Blocked'  Run Keywords
        ...  Unblock  ${item['dist_name']}  timeout=180  alias=${alias}
        ...  AND  Log  SBTS GSM  ${item} unblock indicated  console=True
    END

Admin check if SBTS GSM BCF is unblocked from WEBEM
    [Documentation]
    ...  Helper keyword checking SBTS GSM BCF blocking state. If needed perform unblock SBTS GSM BCF.
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description                    |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance    |
    ...  | bcf_distname         | Yes   | N/A     | SBTS GSM BCF distname to check |
    ...
    [Arguments]  ${bcf_distname}  ${alias}=default
    ${object}=  Query infomodel  get object ${bcf_distname}  alias=${alias}  allow_negative_result=True
    Run Keyword If
    ...  '${object['stateInfo']['blockingState']}' == 'Blocked'
    ...  Unblock    ${bcf_distname}    timeout=30s  alias=${alias}
    ...  ELSE IF  '${object['stateInfo']['blockingState']}' == 'Unblocked'
    ...  Log  SBTS GSM BCF ${bcf_distname} is unblocked!  console=True
    ...  ELSE  Log  SBTS GSM BCF ${bcf_distname}
    ...  blocking state is unexpected: ${object['stateInfo']['blockingState']}  level=WARN
