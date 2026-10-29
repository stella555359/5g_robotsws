*** Settings ***
Documentation
...    Maintainer: I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
...    Common KWs related to all cases.
...    ******************
...    History of changes
...    ******************

Library           hran_testline_configuration    ${HW_LOCATION_CODE}    ${TESTLINE_NAME}
Library           ute_admin_infomodel
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.nms.netact    WITH NAME    netact
Library           taf.nms.nom    WITH NAME    nom
Library           Screenshot
#Library           RemoteSwingLibrary
#Library           SeleniumLibrary    timeout=30s    implicit_wait=0.2s    run_on_failure=Screenshot.Take Screenshot
Library           Selenium2Library    timeout=30s    implicit_wait=0.2s    run_on_failure=Screenshot.Take Screenshot
Resource          hran_general.robot    # common settings:
Resource          hran_infomodel.robot
Resource          hran_admin.robot
Resource          taf/rfrl/common_resources/common_step/interface.robot
Resource          ca_HZ_SBTS_AdminAPI_CM.robot
Resource          SBTS_WEM_Service_Logic_Processor.robot
Resource          SBTS_WEM_Basic_Operations.robot
Resource          SBTS_WebEM_TAF.robot
#Resource         SBTS_AdminAPI_CM.robot
Resource          cm_ONAP.robot
#Library           ute_syslog
Library           taf.sw.syslog    WITH NAME    taf_syslog
Library           Collections
Library           taf.sw.scout    WITH NAME    scout
Library           taf.transport.ssh    WITH NAME    tafssh
#Library           ../resources/python/gnb_tool.py
Library           python/file_operation.py
Library           taf.config.scf  WITH NAME  scf
Library           taf.pdu    WITH NAME    pdu
Library           taf.fdsw.rc    WITH NAME    fdswrc
Library           taf.rfrl.common_resources.python.reset_bts_configuration    WITH NAME    rfrlrestconfig
Library           ute_reporting_portal
############# Module ##########
Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Variables ***
#all needed variables should be given using '--variablefile CONFIG_FILE' or '-V CONFIG_FILE'
@{UDP ports}      51000    51001    51003    50011
&{SIMPLIFIED_NETACT_ALARM}    alarmId=${NONE}    faultId=${NONE}    alarmName=${NONE}    severity=${NONE}
&{SIMPLIFIED_BTS_ALARM}    alarmId=${NONE}    faultId=${NONE}    technology=${NONE}    notifier=${NONE}
...    faultName=${NONE}    detailsAlarmId=${NONE}    severity=${NONE}
${APPLICATION_CLOSING_TIME}    30
${COLLECT_SNAPSHOT_FLAG}=           failed_verdict
${COLLECT_SYSLOG_FLAG}=             ${TRUE}
&{IGNORED_FAULT_61524}=             faultId=61524  faultName=SSH enabled
&{IGNORED_FAULT_61652}=             faultId=61652  faultName=R&D Service Port enabled
&{IGNORED_FAULT_61649}=             faultId=61649  faultName=LMP access via port
#&{IGNORED_FAULT_6450}=              faultId=6450  faultName=Diagnostic Files collected
&{IGNORED_FAULT_4655}=              faultId=4655  faultName=Service account root access is enabled
&{IGNORED_FAULT_4654}=              faultId=4654  faultName=Ethernet port security is disabled
@{GLOBALLY_IGNORED_ALARMS}=     ${IGNORED_FAULT_61524}   ${IGNORED_FAULT_61652}   ${IGNORED_FAULT_61649}
...    ${IGNORED_FAULT_4655}   ${IGNORED_FAULT_4654}    #${IGNORED_FAULT_6450}
${DSC}      ${FALSE}
#list of aliases of remote testlines; to be defined using REMOTE_TESTLINES dictionary in testline configuration file or json
@{REMOTE_TESTLINES_LIST}            @{EMPTY}
${Trunk_Prefix}    SBTS26R3
${Enabled_}    regex"Enabled|enabled"
${Disabled_}    regex"Disabled|disabled"
${Online_}    regex"Online|None"              # None is not used, maybe will be removed
${Offline_}    regex"Offline|off line"
${Degraded_}    regex"Degraded|degraded"
${NotInstalled_}    regex"NotInstalled|not installed"
${Failed_}    regex"Failed|failed"
${Unlocked_}    regex"Unlocked|unlocked"
${Locked_}    regex"Locked|locked"
${ShuttingDown_}    regex"ShuttingDown|Shutting Down"
${Dependency_}    regex"Dependency|dependency"
${PowerOff_}    regex"PowerOff|power off"
${Testing_}    regex"Testing|testing"
${Initializing_}    regex"Initializing|initializing"
${Commissioned_}    regex"Commissioned|commissioned"
${NotCommissioned_}    regex"NotCommissioned|notCommissioned"
${IntegratedToRan_}    regex"IntegratedToRan|integrated to RAN"
${OnAir_}    regex"OnAir|onAir"
${Test_}    regex"Test|test"
${Configured_}    regex"Configured|configured"
${Blocked_}    Blocked
${Unblocked_}    Unblocked
${Blocking_}    Blocking
${Unblocking_}    Unblocking
${Idle_}    Idle
${Active_}    regex"Active|active"  #should be only Active, "active" must be removed after CNI is deliverd, cause is error from NIDD
${Busy_}    Busy
${OnAirDone_}    OnAirDone
${Validated_}    Validated
${RMOD_expected_states}      administrativeState=${Unlocked_}, operationalState=${Enabled_}
${SMOD_expected_states}      administrativeState=${Unlocked_}, operationalState=${Enabled_}
${ALD_expected_states}       operationalState=${Enabled_}, availabilityStatus=${Online_}
${cells_LTE_expected_states}      administrativeState=${Unlocked_}, operationalState=${Enabled_}, blockingState=${Unblocked_}
${cells_WCDMA_expected_states}    operationalState=${Enabled_}, blockingState=${Unblocked_}, usageState=${Active_}
${dist_GSM_cell_runtime_view}     /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/GNBTS_R-*/GNBCF_R-*/GNCEL_R-*
${cells_GSM_expected_states}      administrativeState=${Unlocked_}, operationalState=${Enabled_}, blockingState=${Unblocked_}, usageState=${Active_}
${cells_NR_expected_states}       administrativeState=${Unlocked_}, operationalState=${Enabled_}, blockingState=${Unblocked_}
${SEND_REP_PYTHON_CODE_PATH}    /home/ute/btsauto/hran_ta/resources/python/UploadTCDataToRep_CRT.py
&{Artifactory_INFO}        path=/shared/TA2021/TA_Case/.netrc
...                        USERNAME=root
...                        PASSWORD=uteadmin
...                        Host=10.56.198.140
...                        local_path=/home/ute/.netrc
&{Logserver_INFO}          USERNAME=ute
...                        PASSWORD=Ut3pa5s#ff97
...                        Host=10.69.69.233
${MoveLog}    FALSE    #Move Log to Log Server. 2024-8-14:default FALSE, move to UTE Hangzhou log server. tribe local log server not existed.
#${virtualenv_dir}    /home/ute/.pyenv/versions/3.9.14/envs/test_repo
${virtualenv_dir}    /home/ute/.pyenv/versions/3.11.9/envs/test_repo
#${virtualenv_dir}    /home/ute/.pyenv/versions/3.10.12/envs/test_repo

*** Keyword ***
TAF Config Adapter
    @{configuration}=   Split String  ${CONFIGURATION}  .
    @{tl_params}=       Split String  ${configuration}[1]  _
    Set suite variable  ${HW_LOCATION_CODE}        ${configuration}[0]
    Set suite variable  ${TESTLINE_NAME}           ${tl_params}[0]_${tl_params}[1]_${tl_params}[2]
    Set suite variable  ${TEMP_LOGS_DIR}            /home/ute/btsauto/logs
    Import Library      hran_testline_configuration   ${HW_LOCATION_CODE}  ${TESTLINE_NAME}
    hran_testline_configuration.Set taf config variables

Common Suite Setup
    [Documentation]
    ...  Common Suite Setup.
    [Arguments]    ${reintegrate}=${TRUE}    ${mr}=MRC-COMMON/MR-COMMON    ${security_mode}=no TLS
    Log  Common Suite Setup  level=INFO  console=${TRUE}
    Log    Trying to connect to ADMIN (max 5 min)    level=INFO    console=True
    ${admin_started}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    5 min    15 sec    coam.Setup Admin    admin_api_log_dir=/home/ute/test_results
    ...    bts_host=192.168.255.129    bts_port=443    use_ssl=TRUE    name=suitesetup
    Run Keyword If    ${admin_started}    Log    ADMIN successfully started!    level=INFO    console=True
    Setup NetAct By TAF
    ${swRelease}    coam.get_sw_release_name    connection=suitesetup
    Run Keyword If    ${reintegrate}    Integrate NE To NetAct    mrbts_addr=${MPLANE_IP}    dist_name=${MRBTS_DN}    release_version=${swRelease}
    ...    mr=${mr}    security_mode=${security_mode}
    [Teardown]    Run Keyword And Ignore Error    Run Keywords    coam.Teardown Admin    connection=suitesetup    AND    Teardown NetAct By TAF

Common Suite Teardown
   [Documentation]
    ...  Common Suite Teardown.
    Log  Common Suite Teardown  level=INFO  console=${TRUE}
    Run Keyword And Ignore Error    Run keyword If    "${MoveLog.lower()}"=="true"
    ...    Move All Test Result To Log Server

Common Test Setup SBTS
    [Documentation]
    ...  Set of actions which will be launched before each SBTS SOAM test (starting from SBTS17).
    ...  List of actions:
    ...  -> Hran_ta Preconditions: Gets hran_ta workspace version based on information from SVN
    ...                            Creates log directories
    ...                            Initializes variables used for test_verdict calculation
    ...  -> Deletes content of /tmp and /home/ute/btsauto/logs in order to free up space, to ensure Robot test can run
    ...  -> Starts Admin connection
    ...  -> Starts Syslogs collecting
    ...  -> Starts infomodel on LTE site
    ...  -> Gets and displays SW versions
    ...  -> Checks cells and modules state and active alarms
    ...
    ...  | Parameter            | Default         | Description                                   |
    ...  | admin_launch         | TRUE            | Whether to initialise/or not Admin connection |
    ...  | syslog_launch        | TRUE            | Whether to collect/or not syslog during TC execution |
    ...  | infomodel_launch     | TRUE            | Whether to initialise/or not InfoModel connection |
    ...  | btssm_launch         | TRUE            | Whether to initialise/or not btssm library |
    ...  | bts_host             | 192.168.255.129 | IP address to connect with BTS |
    ...  | modules_check        | TRUE            | Flag for enabling/disabling modules precheck |
    ...  | cells_check          | TRUE            | Flag for enabling/disabling cells precheck |
    ...  | alarms_check         | TRUE            | Flag for enabling/disabling alarms precheck |
    ...  | expected_BTS_status  | OnAir           | Expected BTS status|
    ...  | scf_check            | TRUE            | Whether to initialise/or not SCF parrser, and checking with SCF |
    ...  | expected_alarms      | empty          | List of expected alarms regex patterns, one for each expected alarm |
    ...  | ignored_alarms       | empty           | List of ignored alarms regex patterns, will be used multiply  |
    ...  | critical_alarms      | empty           | List of critical alarms regex patterns, will be used multiply  |
    ...
    ...  | To run setup for DSC, variable ${DSC}=${True} should be visible in env_config or test parameters in json
    ...  | To run setup for remote testlines, dictionary REMOTE_TESTLINES has to be added to env_config, example entry:
    ...  | REMOTE_TESTLINES:
    ...  |   TESTLINE1:
    ...  |     PC_IP1: <ip_address_of_msm_host>
    ...  |     PC_IP2: <ip_address_of_esm_host>
    ...  |
    ...  | User can import global variables from file in common test setup;
    ...    ${ADDITIONAL_VARIABLES_PATH} need to be included in json file
    ...    *HISTORY*
    ...    2022.9.29  Update for hran_ta merge to robotws by lixin.kang@nokia-sbell.com.
    [Timeout]    15 minutes
    [Arguments]  ${admin_launch}=${TRUE}       ${syslog_launch}=${COLLECT_SYSLOG_FLAG}  ${infomodel_launch}=${TRUE}
    ...    ${btssm_launch}=${FALSE}
    ...    ${bts_host}=192.168.255.129   ${modules_check}=${TRUE}  ${cells_check}=${TRUE}     ${alarms_check}=${TRUE}
    ...    ${expected_BTS_status}=OnAir  ${scf_check}=${TRUE}  ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}
    ...    ${critical_alarms}=@{EMPTY}    ${SetValidatePlanAgainstDetectedHW}=${FALSE}
    Log    ${btssm_launch}
    Log    ${bts_host}
    Log    ${SetValidatePlanAgainstDetectedHW}
    Set Test Variable  ${scf_check}                ${scf_check}
    Set Test Variable  ${btssm_started}            ${FALSE}
    Set Test Variable  ${infomodel_started}        ${FALSE}
    Set Test Variable  ${SMOD1_syslog_started}     ${FALSE}
    Set Test Variable  ${SMOD2_syslog_started}     ${FALSE}
    Set Test Variable  ${admin_started}            ${FALSE}
    Set Test Variable  ${bts_verification_status}  norun
    ${additional_variables_exist}=  Run Keyword And Return Status  Variable Should Exist  ${ADDITIONAL_VARIABLES_PATH}
    Run Keyword If  ${additional_variables_exist}  Run Keyword And Ignore Error
    ...    Import Variables  ${ADDITIONAL_VARIABLES_PATH}
    ${taf_config_model}=  Run keyword and return status   Variable should exist  ${tl}
    Set test variable  ${TAF_CONFIG_MODEL}  ${taf_config_model}
    Run keyword if  ${TAF_CONFIG_MODEL}  Taf config adapter
    ...       ELSE   hran_testline_configuration.Set Config Variables   @{TESTLINE_CONFIG_VARIABLES}
    Run keyword If    not ${TAF_CONFIG_MODEL}  Clean VM disk space  Master
    There should be at least 2048 MB of disk space available in /home/ute
    # product-specific part of precondititons:
    hran_general.Hran_ta Preconditions
    Log    TC executed with configuration files of ${HW_LOCATION_CODE}\\${TESTLINE_NAME}    level=INFO    console=${TRUE}
    Set Tags  ${HW_LOCATION_CODE}\\${TESTLINE_NAME}
    Set Additional Ignored Alarms
    Log Variables  level=DEBUG
    Run Keyword If  ${admin_launch}       Run Keyword And Continue On Failure  Start Admin  bts_host=${SMOD1['TRS_IP']}
    Run Keyword If  ${syslog_launch}      Run Keyword And Continue On Failure  Start syslog on SMOD1
    Run Keyword If  ${infomodel_launch}   Run Keyword And Continue On Failure  Start Infomodel
    Setup SMOD2    ${admin_started}  ${infomodel_started}   ${syslog_launch}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    3x    30s    Get SCF Internal Id By Scout    no_ute=${False}
    Run Keyword If  ${infomodel_started}  Run Keyword And Continue On Failure  Print Active And Passive SW Version
    _Set SW_TYPE
    _Set COMMISSIONING_PATH
    #2025-01-17:Added by Yuyan Xu for alarm watchddog
    Run Keyword And Ignore Error    Start Alarm Watch Dog
    ${BTS_scf}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    #2025-03-04:remove due to CB014041-B onwards: MNL.validatePlanAgainstDetectedHW is frozen
    #${BTS_scf_initial}    Set ValidatePlanAgainstDetectedHW Value SCF    ${BTS_scf}    false
    Set Test Variable    ${BTS_scf_initial}    ${BTS_scf}
    Run keyword if  ${admin_started}  Verify BTS states  ${expected_BTS_status}
    ...  ${modules_check}  ${cells_check}  ${alarms_check}  ${expected_alarms}  ${ignored_alarms}  ${critical_alarms}
    ...        ELSE  Set Test Variable  ${bts_verification_status}  passed
    Run keyword if  ${DSC}  Run Keyword And Continue On Failure  Remote Test Line Setup  remote_host=${PC_IP2}  alias=DSC
    ${remote_testlines_configured}  ${remote_testlines_tmp}=  Run keyword and ignore error
    ...    Get dictionary keys  ${REMOTE_TESTLINES}
    ${REMOTE_TESTLINES_LIST}=  Run Keyword If  '${remote_testlines_configured}'=='PASS'
    ...    Set Variable  ${remote_testlines_tmp}
    ...  ELSE  Create List
    Set Test Variable  ${REMOTE_TESTLINES_LIST}
    FOR  ${remote_alias}  IN  @{REMOTE_TESTLINES_LIST}
        Verify Configuration And Set Up Remote Test Line  ${modules_check}  ${cells_check}  ${alarms_check}  ${remote_alias}
    END
    Log    End of Common Test Setup    level=INFO  console=${TRUE}
    Set Expected Object Status
    ${mrbts_id}    ${nrbts_id}    ${lnbts_id}    ${wnbts_id}    ${gnbts_id}    Fetch BTS IDs
    Set Test Variable    ${mrbts_id}
    Set Test Variable    ${nrbts_id}
    Set Test Variable    ${lnbts_id}
    Set Test Variable    ${wnbts_id}
    Set Test Variable    ${gnbts_id}
    Set Test Variable    ${MRBTS_DN}    PLMN-PLMN/MRBTS-${mrbts_id}
    #${bts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    #2025-03-04:remove due to CB014041-B onwards: MNL.validatePlanAgainstDetectedHW is frozen
    #Run Keyword If    ${SetValidatePlanAgainstDetectedHW}    Set ValidatePlanAgainstDetectedHW Value Admin   ${mrbts_id}    true
    Run Keyword And Ignore Error    Prepare Netrc On VM

Common Test Teardown SBTS
        [Documentation]
    ...  Set of actions which will be launched after each SBTS SOAM test ends (starting from SBTS17).
    ...  List of actions:
    ...  -> Triggers snapshot depends on selected option and test_verdict
    ...  -> Gets and displays siteName information from siteconf.xml for Master and Slave SM (if slave_tech is not GSM)
    ...  -> Collects BTSSM files and stops BTSSM session
    ...  -> Collects Infomodel files and stops Infomodel session
    ...  -> Collects Syslog files ands stops logging
    ...  -> Collects Admin files and stops Admin session
    ...
    ...  | Parameter        | Default        | Description                                |
    ...  | collect_snapshot | failed_verdict | Flag for enabling/disabling snapshot trace |
    ...
    ...  | Possible collect_snapshot values | Description
    ...  | always                           | Snapshot is collected unless the test verdict is norun |
    ...  | failed_verdict           | Snapshot is collected if the test verdict is failed or blocked |
    ...  | passed_with_restriction  | Snapshot is collected if the test verdict is failed,
    ...                               blocked or passed_with_restriction |
    ...  | never                            | Snapshot is not collected |
    ...
    ...    *HISTORY*
    ...    2022.9.29  Update for hran_ta merge to robotws by lixin.kang@nokia-sbell.com.
    [Arguments]  ${collect_snapshot}=${COLLECT_SNAPSHOT_FLAG}

    # this is to allow one to override `collect_snapshot` by providing it in a command line / JSON,
    # even if it is set in a TC (as in `Common Test Teardown    collect_snapshot=never`)
    ${collect_snapshot}=    Set Variable If
    ...    '${COLLECT_SNAPSHOT_FLAG}' != 'failed_verdict'    ${COLLECT_SNAPSHOT_FLAG}    ${collect_snapshot}

    Log  Common Test Teardown  level=INFO  console=${TRUE}
    ${bts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    #2025-03-04:remove due to CB014041-B onwards: MNL.validatePlanAgainstDetectedHW is frozen
    #Run Keyword And Ignore Error    Set ValidatePlanAgainstDetectedHW Value Admin    ${bts_id}    false
    Run Keyword And Ignore Error    Remove Netrc On VM
    Run Keyword And Ignore Error    Run Keyword If Test Passed    Report To Rep With SCF Id

    Run Keyword If  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Log   Initial verification of BTS states was not completed due to timeout, or some unit indicates a faulty state    level=ERROR

    ${collect_snapshot_condition_1}=  set variable  '${collect_snapshot}'=='always'
    ${collect_snapshot_condition_2}=  set variable  '${collect_snapshot}'=='failed_verdict' and '${TEST STATUS}' == 'FAIL'
    ${collect_snapshot_condition_3}=  set variable
    ...    '${collect_snapshot}'=='passed_with_restriction' and '${TEST STATUS}' == 'FAIL'
    Run keyword if  ${collect_snapshot_condition_1} or ${collect_snapshot_condition_2} or ${collect_snapshot_condition_3}
    ...    Run keywords    Admin Get Snapshot
    ...    AND  Run keyword if  ${SMOD2_exists}  Admin Get Snapshot for ESM
    ...    AND  Collect Extended TRS Logs
    ...    AND  Collect Snapshot From Remote Test Lines

    Run keyword if  ${DSC}  Remote Test Line Teardown  alias=DSC  verify_states_stability=${True}
    FOR  ${remote_line_alias}  IN  @{REMOTE_TESTLINES_LIST}
        Remote Test Line Teardown  alias=${remote_line_alias}
    END
    #2022-07-07:Xu Yuyan add for Enable Sleeping Cell feature
    Run Keyword And Ignore Error    interface.Common step trigger

    Run Keyword If    ${infomodel_started}    Collect Infomodel
    Teardown All Aliases For Infomodel
    Run Keyword If  ${admin_started}   Admin Print Active Alarms TAF
    ...    output_file=${Test Results Dir}/teardown_active_alarms.json
    coam.Teardown All Aliases For Admin
    Collect Syslog
    Collect Swconfigs
    Collect RawAlarmHistory
    Log    Move directory ssh_forwarder_log to ${BTS Files}
    Run Keyword And Ignore Error  Move Directory  ${EXECDIR}/ssh_forwarder_log  ${BTS Files}

    # hran_ta postcondititons:
    hran_general.Hran_ta Postconditions
    Run keyword if  'STOPONFAIL' in @{TEST TAGS} and '${TEST STATUS}' == 'FAIL'
    ...    Fatal error  Execution stopped because critical TC '${TEST NAME}' failed
	#gnb_tool.stop_and_fix    #Stop&Fix process ending, so comment at 2024-10-17
	#2025-01-17:Added by Yuyan Xu for alarm watchddog
	Run Keyword And Ignore Error    Stop And Analysis Alarm Watch Dog

Common Test Setup
    [Arguments]    ${PrecheckConf}=${TRUE}    ${PrecheckCells}=${TRUE}    ${PrecheckModules}=${TRUE}    ${SetValidatePlanAgainstDetectedHW}=${FALSE}
    [Documentation]    Set of actions which will be launched before each test.
    ...    A failure of any step here leads to the Jenkins TcVerdict set to NoRun.
    ...    List of actions:
    ...    -> Hran_ta Preconditions: Gets hran_ta workspace version based on information from GIT
    ...    Creates log directories
    ...    Initializes variables used for test_verdict calculation
    ...    -> Deletes content of /tmp and /home/ute/btsauto/logs in order to free up space,
    ...    to insure robot tests are able to run
    ...    -> Starts Admin connection
    ...    -> Starts Syslogs collecting
    ...    -> Starts Infomodel on LTE site
    ...    -> Gets and displays SW versions
    ...    -> Checks cells and modules state and active alarms
    ...    -> For TcVerdict calculations, checks SyVe Customizable Preconditions (BTS configuration,
    ...    cells and modules state) ...
    ...    | Parameter | Man. | Description |
    ...    | PrecheckConf | No | Flag for enabling BTS configuration precheck, result used for TcVerdict evaluation |
    ...    | PrecheckCells | No | Flag for enabling/disabling cells precheck, result used for TcVerdict evaluation |
    ...    | PrecheckModules | No | Flag for enabling radio modules precheck, result used for TcVerdict evaluation |
    ...
    ...    *EXAMPLE*
    ...    | Common Test Setup | ${TRUE} | ${FALSE} | ${TRUE} | all | ${FALSE} |
    ...    | Common Test Setup |
    ...    | Common Test Setup | PrecheckCells=${FALSE} |
    ...    *HISTORY*
    ...    2022.9.29  Update for hran_ta merge to robotws by lixin.kang@nokia-sbell.com.
    [Timeout]    20 minutes
    hran_general.Hran_ta Preconditions
    Create 'NetActLogs' in '${Test Results Dir}' And Set Test Variable
    Set Test Variable    ${SMOD1_syslog_started}    ${FALSE}
    Set Test Variable    ${SMOD2_syslog_started}    ${FALSE}
    Set Test Variable    ${admin_started}    ${FALSE}
    Set Test Variable    ${SnapshotTriggerEndTest}    NO
    Set Test Variable    ${SkipCellsAndRmsNumberCheck}    False
    Screenshot.Set Screenshot Directory    path=${Test Results Dir}/NetActLogs
    Clean VM disk space    Master
    There should be at least 2048 MB of disk space available in /home/ute
    # product-specific part of precondititons:
    Log    TC executed with configuration files of ${HW_LOCATION_CODE}\\${TESTLINE_NAME}    level=INFO    console=True
    Set Tags    ${HW_LOCATION_CODE}\\${TESTLINE_NAME}
    ${hran_config_model}=    Run Keyword And Return Status
    ...    hran_testline_configuration.Set Config Variables    @{TESTLINE_CONFIG_VARIABLES}
    Run keyword if    ${hran_config_model}    Run Keywords    Log    Running tests in HRAN_TA mode    console=True
    ...    AND    Clean VM disk space    Master
    ...    ELSE    Run Keywords    Log    Running tests from UTE_CLOUD    console=True
    ...    AND    Additional variables loader
    #2024-3-21:Xu Yuyan add for varibles get from __init__.py
    ${taf_config_model}=  Run keyword and return status   Variable should exist  ${tl}
    Set test variable  ${TAF_CONFIG_MODEL}  ${taf_config_model}
    Run keyword if  ${TAF_CONFIG_MODEL}  Taf config adapter
    Run keyword If    not ${TAF_CONFIG_MODEL}  Clean VM disk space  Master
    #2024-3-21:end Xu Yuyan add for varibles get from __init__.py
    Log Variables    level=DEBUG
    Run Keyword And Continue On Failure    Start Admin    bts_host=${SMOD1['TRS_IP']}
    Check if SMOD2 exists    ${admin_started}
    Run Keyword If    ${SMOD2_exists}    Clean VM disk space    Extension
    ...    host_ip=${PC_IP2}    ssh_port=${22}    ssh_username=ute    ssh_password=uteUTE!
    Run Keyword If    ${SMOD2_exists}  Check if remote host directory has enough space    /home/ute  2048
    ...    ${PC_IP2}    ${22}    ute    ute
    Run Keyword And Continue On Failure    Start Infomodel
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    3x    30s    Get SCF Internal Id By Scout    no_ute=${False}
    Run Keyword And Continue On Failure    Setup NetAct By TAF
    Run Keyword And Continue On Failure    Print Active And Passive SW Version
    Set Expected Object Status
    Set Service Access Configuration SyVe    False
    Set Ethernet Port Security    False
    Run Keyword And Continue On Failure    Start Syslog On All SMODs
    SyVe Customizable Preconditions    CheckConf=${PrecheckConf}    CheckCells=${PrecheckCells}
    ...    CheckModules=${PrecheckModules}
    #2025-01-17:Added by Yuyan Xu for alarm watchddog
    Run Keyword And Ignore Error    Start Alarm Watch Dog
    ${mrbts_id}    ${nrbts_id}    ${lnbts_id}    ${wnbts_id}    ${gnbts_id}    Fetch BTS IDs
    Set Test Variable    ${mrbts_id}
    Set Test Variable    ${nrbts_id}
    Set Test Variable    ${lnbts_id}
    Set Test Variable    ${wnbts_id}
    Set Test Variable    ${gnbts_id}
    #2024-11-3: Added for CNI-127255
    Run Keyword If    "${mrbts_id}"=="1"    Update MRBTSID And Integrate To NetAct
    Set Test Variable    ${MRBTS_DN}    PLMN-PLMN/MRBTS-${mrbts_id}
    #${bts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Log    ${SetValidatePlanAgainstDetectedHW}
    #2025-03-04:remove due to CB014041-B onwards: MNL.validatePlanAgainstDetectedHW is frozen
    #Run Keyword If    ${SetValidatePlanAgainstDetectedHW}    Set ValidatePlanAgainstDetectedHW Value Admin   ${mrbts_id}    true
    Run Keyword And Ignore Error    Prepare Netrc On VM
    Log    End of Common Test Setup    level=TRACE    console=True

Common Test Teardown
    [Arguments]    ${SNAPSHOT ON FAILURE}=YES    ${ERROR NUMBER TRESHOLD}=0
    [Documentation]    This is a set of actions which will be launched after each SyVe test ends.
    ...    A failure of any step here leads to the Jenkins TcVerdict set to Passed_With_Restriction,
    ...    if the other parts of the test are passed. Otherwise, a failure here will not influence the TcVerdict.
    ...    List of actions:
    ...    -> Triggers snapshot if test result is Passed_With_Restriction or Failed or if an Error
    ...    was logged.
    ...    Snapshot can be disabled by argument ${Snapshot On Failure} != YES.
    ...    Snapshot triggering can be conditioned be done if more than a treshold number of errors found.
    ...    -> Collect RM logs if test result is Failed or if an Error was logged.
    ...    -> Gets and displays siteName information
    ...    -> Collects files and stops ADMIN sessions
    ...    -> Collects ADMIN_INFOMODEL files and stops ADMIN_INFOMODEL session
    ...    -> Collects Syslog files ands stops logging
    ...    -> Runs Hran_ta Postconditions: Currently only logs a message signalling end of Common Test Teardown.
    ...
    ...    | Parameter | Man. | Description |
    ...    | SNAPSHOT ON FAILURE | No | Flag for enabling/disabling snapshot trace in case of Test case failure |
    ...    | ERROR NUMBER TRESHOLD | No | Flag indicating the number of ERRORs logged needed to trigger snapshot trace|
    ...
    ...    *EXAMPLE*
    ...    | Common Test Teardown | YES | 2 |
    ...    | Common Test Teardown | SNAPSHOT ON FAILURE=YES |
    ...    | Common Test Teardown |
    ...    -> Snapshot activated in case of failure, or in case of more than 2 errors logged
    ...    *HISTORY*
    ...    2022.9.29  Update for hran_ta merge to robotws by lixin.kang@nokia-sbell.com.
    Log    Common Test Teardown    level=TRACE    console=True
    ${bts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    #Run Keyword And Ignore Error    Set ValidatePlanAgainstDetectedHW Value Admin    ${bts_id}    false
    Run Keyword And Ignore Error    Remove Netrc On VM
    Run Keyword And Ignore Error    Run Keyword If Test Passed    Report To Rep With SCF Id
    ${errors}    Get Variable Value    ${error_message_count}    ${0}
    ${condition1}    Set Variable
    ...    ('${SnapshotTriggerEndTest}' == 'YES' or '${TEST STATUS}' == 'FAIL' or ${errors} > ${ERROR NUMBER TRESHOLD})
    Run Keyword If    ${condition1} and '${SNAPSHOT ON FAILURE}' == 'YES'    Get Snapshot and Active Alarms
    #2022-07-07:Xu Yuyan add for Enable Sleeping Cell feature
    Run Keyword And Ignore Error    interface.Common step trigger
    # product-specific part of precondititons:
    Run Keyword And Continue On Failure    BTS SiteName information
    Run Keyword And Continue On Failure    Collect Admin
    Run Keyword And Continue On Failure    Collect Infomodel
    Run Keyword And Continue On Failure    Collect syslog
    Run Keyword And Continue On Failure    Collect Swconfigs
    Run Keyword And Continue On Failure    Teardown NetAct By TAF
    # hran_ta postcondititons:
    hran_general.Hran_ta Postconditions
	#gnb_tool.stop_and_fix     #Stop&Fix process ending, so comment at 2024-10-17
	#2025-01-17:Added by Yuyan Xu for alarm watchddog
	Run Keyword And Ignore Error    Stop And Analysis Alarm Watch Dog

Integrate NE To NetAct
    [Arguments]    ${mrbts_addr}    ${dist_name}    ${release_version}    ${mr}=MRC-COMMON/MR-COMMON    ${security_mode}=no TLS
    [Documentation]   Integrate NE To NetAct
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
   ...   | mrbts_addr    | yes | mrbts ip |
    ...   | dist_name    | yes | mrbts dist name on NetAct |
    ...   | release_version | yes | mrbts release version |
    ...   | mr  | no | mrbts MR, default is MRC-COMMON/MR-COMMON |
    ...   | security_mode  | no | security mode, default is no TLS |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example    |Integrate NE To NetAct | mrbts_addr=10.68.159.212 | dist_name=PLMN-PLMN/MRBTS-1816 | release_version=24R2 |
    ...  | mr=MRC-COMMON/MR-COMMON | security_mode=no TLS |

    Run Keyword And Ignore Error    Deintegrate NE From NetAct    ${dist_name}
    sleep    15s
    ${integration_status}    Run Keyword And Return Status    netact.Integrate MRBTS with Netact
    ...    mrbts_address=${mrbts_addr}    dist_name=${dist_name}    release=${release_version}    mr=${mr}    security_mode=${security_mode}
    NetAct CM Upload    dist_names=${MRBTS_DN}
    Run Keyword If    ${integration_status}    log to console    BTS is connected to expected NetAct
    ...    ELSE    FAIL   BTS is not connected to expected NetAct

Deintegrate NE From NetAct
    [Arguments]     ${dist_name}
    [Documentation]   Deintegrate NE From NetAct
    ...    Author: yuyan xu
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | dist_name    | yes | mrbts dist name on NetAct |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | Deintegrate NE From NetAct | dist_name=PLMN-PLMN/MRBTS-1816 |
    ${deintegration_status}    Run Keyword And Return Status    netact.deintegrate mrbts from netact    dist_name=${dist_name}
    Run Keyword If    ${deintegration_status}    log to console    NE deintegrate from NetAct success
    ...    ELSE    run keywords    log to console    NE deintegrate from NetAct failed    AND    FAIL   NE deintegrate from NetAct Failed

Verify BTS states
    [Documentation]
    ...    *HISTORY*
    ...    2022.9.29  Update for hran_ta merge to robotws by lixin.kang@nokia.com.
    [Arguments]  ${expected_BTS_status}=OnAir  ${modules_check}=${TRUE}  ${cells_check}=${TRUE}  ${alarms_check}=${TRUE}
    ...    ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}
    ...    ${BTS_state_is_correct}=${FALSE}  ${system_modules_working}=${FALSE}  ${radio_modules_working}=${FALSE}
    ...    ${cells_GSM_onair}=${FALSE}  ${cells_WCDMA_onair}=${FALSE}  ${cells_LTE_onair}=${FALSE}
    ...    ${cells_NR_onair}=${FALSE}  ${alarms_status}=FAIL
    ${BTS_state_is_correct}  ${BTS_current_status}=  hran_frame_taf_oam.Verify BTS proceduralState  ${expected_BTS_status}
    ${system_modules_working}=  Run Keyword If  ${modules_check}  Verify system modules states
    ...  ELSE  Set Variable  ${TRUE}
    ${radio_modules_working}=   Run Keyword If  ${modules_check}  Verify radio modules states
    ...  ELSE  Set Variable  ${TRUE}
    ${alds_working}=            Run Keyword If  ${modules_check}  Verify ald states
    ...  ELSE  Set Variable  ${TRUE}
    ${cells_GSM_onair}=         Run Keyword If  ${cells_check}    Verify GSM cells states
    ...  ELSE  Set Variable  ${TRUE}
    ${cells_WCDMA_onair}=       Run Keyword If  ${cells_check}    Verify WCDMA cells states
    ...  ELSE  Set Variable  ${TRUE}
    ${cells_LTE_onair}=         Run Keyword If  ${cells_check}    Verify LTE cells states
    ...  ELSE  Set Variable  ${TRUE}
    ${cells_NR_onair}=         Run Keyword If  ${cells_check}    Verify NR cells states
    ...  ELSE  Set Variable  ${TRUE}
    ${ALL_AVAILABLE_CELLS}=  Admin Get ids for all cells TAF
    Set test variable  ${ALL_AVAILABLE_CELLS}

    ${alarms_status}  ${alarms_msg}=  Run Keyword If  ${alarms_check}  Run Keyword And Ignore Error
    ...    Admin Check Active Alarms TAF
    ...    expected_patterns=${expected_alarms}    ignored_patterns=${ignored_alarms}    critical_patterns=${critical_alarms}
    Run keyword if  '${alarms_status}'=='FAIL'    Log    Critical fail while checking alarms: ${alarms_msg}    console=${TRUE}
    ...    ELSE IF  ${alarms_msg}    Log     Unexpected alarms are present: ${alarms_msg}     level=WARN

    ${statuses_dictionary}=  Create Dictionary  BTS_state_is_correct=${BTS_state_is_correct}
    ...  system_modules_working=${system_modules_working}  radio_modules_working=${radio_modules_working}
    ...  alds_working=${alds_working}  cells_GSM_onair=${cells_GSM_onair}  cells_WCDMA_onair=${cells_WCDMA_onair}
    ...  cells_LTE_onair=${cells_LTE_onair}  cells_NR_onair=${cells_NR_onair}  alarms_status=${alarms_status}
    ${pretty_statuses}=  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint
    ${cells_count_status}=  Run Keyword And Return Status  should be empty  ${ALL_AVAILABLE_CELLS}
    Run Keyword If
    ...  '${BTS_current_status}' == 'NotCommissioned' and ${cells_count_status} and ${BTS_state_is_correct} == ${FALSE}
    ...  Fail  Test blocked due to BTS status: NotCommissioned. There are 0 configred cells.\nSkip to teardown!

    ${con1}    Set Variable    ${BTS_state_is_correct}
    ${con2}    Set Variable    ${system_modules_working}
    ${con3}    Set Variable    ${radio_modules_working}
    ${con4}    Set Variable    ${alds_working}
    ${con5}    Set Variable    ${cells_GSM_onair}
    ${con6}    Set Variable    ${cells_WCDMA_onair}
    ${con7}    Set Variable    ${cells_LTE_onair}
    ${con8}    Set Variable    ${cells_NR_onair}
    ${con9}    Set Variable    ${alarms_status}

    Run Keyword If
    ...  ${con1} and ${con2} and ${con3} and ${con4} and ${con5} and ${con6} and ${con7} and ${con8} and '${con9}'!='FAIL'
    ...  Set Test Variable  ${bts_verification_status}  passed
    ...  ELSE   Fail     Test blocked due to failure of BTS initial check:\n${pretty_statuses}.\nSkip to teardown!

Verify BTS proceduralState
    [Arguments]  ${expected_BTS_status}
    Log    Start BTS commissioning verification    console=${True}
    ${current_status}=  coam.Get Mrbts State
    ${BTS_in_expected_status}=  Run keyword and return status
    ...    Should Match Regexp  ${current_status}  ${expected_BTS_status}
    Run keyword if    ${BTS_in_expected_status}    Log   BTS is in expected status (${current_status})!    console=${TRUE}
    ...    ELSE     Log    BTS has state other than expected.    console=${TRUE}
    [Return]  ${BTS_in_expected_status}  ${current_status}

Verify system modules states
    [Documentation]
    ...  Wrapper KW for checking SMOD product numbers against SCF and comparing SMOD states with states defined in
    ...  ${SMOD_expected_states} variable
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** ---

    Log    Start system modules verification    console=${True}
    Set SCF system modules count and verify product numbers
    Run keyword and return  Verify modules TAF  SMOD  scf_check=${TRUE}

Verify radio modules states
    [Documentation]
    ...  Wrapper KW for checking RMOD product numbers against SCF and comparing RMOD states with states defined in
    ...  ${RMOD_expected_states} variable
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** ---

    Log    Start radio modules verification    console=${True}
    Set SCF radio modules count and verify product numbers
    Run keyword and return  Verify modules TAF  RMOD  scf_check=${TRUE}

Verify ald states
    [Documentation]
    ...  Wrapper KW for comparing ALD states with states defined in ${ALD_expected_states} variable. Because of ticket
    ...  https://jiradc.int.net.nokia.com/browse/URW-5861, productCode checking is now omitted
    ...
    ...  | **Author:** patryk.furman@nokia.com
    ...  | **Maintainer:** patryk.furman@nokia.com
    ...  | **Released with version:** 50.3

    Log  Start ALD verification  console=${TRUE}
    Run keyword and return  Verify modules TAF  ALD  scf_check=${FALSE}

Verify ${technology} cells states
    [Documentation]
    ...  Wrapper KW for checking all RATs cells count against SCF and comparing cells states with states defined in
    ...  ${cells_LTE_expected_states}, ${cells_WCDMA_expected_states} and ${cells_GSM_expected_states} variables
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** ---

    Log    tart ${technology} cells verification    console=${True}
    Set SCF cells count  ${technology}
    Run keyword and return  Verify cells TAF  ${technology}  scf_check=${TRUE}

Setup SMOD2
    [Arguments]  ${admin_started}  ${infomodel_started}  ${syslog_launch}
    ${smod2_variable_exists}=   Run keyword and return status  Variable Should Exist  ${SMOD2}
    ${pc_ip2_variable_exists}=  Run keyword and return status  Variable Should Exist  ${PC_IP2}
    Run keyword if  '${smod2_variable_exists}'=='${False}' or '${pc_ip2_variable_exists}'=='${False}'    Run keywords
    ...    Log  One SMOD or none PC_IP2 was declared in config   console=${TRUE}
    ...    AND  Set test variable  ${SMOD2_exists}  ${FALSE}
    ...    AND  Return from keyword
    Run keyword if  ${admin_started} and ${infomodel_started}   Check SMOD2 in Admin
    ...    ELSE  Run keywords    Log   Skip checking SMOD2 in Admin    console=${TRUE}
    ...    AND  Set test variable  ${SMOD2_exists}  ${TRUE}

    Run Keyword If    not ${TAF_CONFIG_MODEL}  Run keyword if  ${SMOD2_exists}
    ...    Clean VM disk space  Extension  host_ip=${PC_IP2}  ssh_port=${22}  ssh_username=ute  ssh_password=uteUTE!
    Run Keyword If    not ${TAF_CONFIG_MODEL}  Run keyword if  ${SMOD2_exists}
    ...    Check if remote host directory has enough space  /home/ute  2048  ${PC_IP2}  ${22}  ute  ute
    Run Keyword If  ${syslog_launch} and ${SMOD2_exists}  Run Keyword And Continue On Failure  Start syslog on SMOD2


Collect Extended TRS Logs
    [Documentation]
    ...    *HISTORY*
    ...    2022.9.29  Update for hran_ta merge to robotws by lixin.kang@nokia.com.
    Log  Collecting extended TRS logs  console=${True}
    ${trs_logs_collected}=  Run Keyword And Return Status  Run Keywords
    ...    SSHLibrary.Open Connection    ${SMOD1['TRS_IP']}
    ...    AND    SSHLibrary.Login    ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}
    ...    AND    SSHLibrary.Execute Command
    ...    command=/opt/trs/etc/collect_tech_logs.sh --filename=/ffs/run/logs/TRSExtendedLogs.tar.xz
    ...    AND    Get File From System Module
    ...    source_path=/ffs/run/logs/TRSExtendedLogs.tar.xz  destination_path=${BTS Files}/TRSExtendedLogs.tar.xz
    Run Keyword If  ${trs_logs_collected}  Run Keywords  Log  Extended TRS logs collected  console=${True}
    ...  AND  Return From Keyword
    Log  Extended TRS logs not collected!  console=${True}

Collect Swconfigs
    [Documentation]
    ...    *HISTORY*
    ...    2022.9.29  Update for hran_ta merge to robotws by lixin.kang@nokia.com.
    ${status}  ${result}=  Run Keyword And Ignore Error  Get File From System Module
    ...    source_path=/ffs/run/swconfig.txt  destination_path=${BTS Files}/swconfig.txt
    Run Keyword If  '${status}'=='PASS'  Log  swconfig.txt from System module collected  console=${True}
    ...  ELSE  Run Keyword  Log  swconfig.txt could not be retrieved from System Module! Error: ${result}  console=${True}
    Run Keyword If  ${SMOD2_exists}  Get Swconfig From Extension

Collect RawAlarmHistory
    [Documentation]
    ...    *HISTORY*
    ...    2022.9.29  Update for hran_ta merge to robotws by lixin.kang@nokia.com.
    ${status}  ${result}=  Run Keyword And Ignore Error
    ...  Get File From System Module  source_path=/tmp/RawAlarmHistory.txt  destination_path=${BTS Files}/RawAlarmHistory.txt
    Run Keyword If  '${status}'=='PASS'  Log  RawAlarmHistory.txt from System module collected  console=${True}
    ...  ELSE  Run Keyword
    ...    Log  RawAlarmHistory.txt could not be retrieved from System Module! Error: ${result}  console=${True}

Set Additional Ignored Alarms
    [Documentation]
    ...  Keyword Adds Alarms definied as ADDITIONAL_IGNORED_ALARMS to GLOBALLY_IGNORED_ALARMS
    ...  https://jira3.int.net.nokia.com/browse/TAT-12375, Ignored alarms from Common Test Setup can be set in json
    ...  ADDITIONAL_IGNORED_ALARMS can be defined in job.json test parameters as list of lists
    ...  eg."ADDITIONAL_IGNORED_ALARMS": ["faultId", "23", "Severity", "Major"],[ "faultId", "4082", "alarmId", "7651"]
    ...
    ...  | **Author:** jacek.mnich@nokia.com
    ...  | **Maintainer:** jacek.mnich@nokia.com
    ...  | **Released with version:** 53.1

    ${var_exists}  Run Keyword And Return Status  Variable should exist  ${ADDITIONAL_IGNORED_ALARMS}
    Return From Keyword If  not ${var_exists}
    Log  Setting Additional Ignored Alarms:${ADDITIONAL_IGNORED_ALARMS}  console=${True}
    ${ADDITIONAL_IGNORED_ALARMS}  Evaluate  ${ADDITIONAL_IGNORED_ALARMS}
    FOR  ${alarm}  IN  @{ADDITIONAL_IGNORED_ALARMS}
        ${ignored_alarm}  Create Dictionary
        Set To Dictionary  ${ignored_alarm}  @{alarm}
        Append To List   ${GLOBALLY_IGNORED_ALARMS}  ${ignored_alarm}
    END

Clean VM disk space
    [Arguments]    ${alias}    &{configuration}
    [Documentation]    Wrapper function for KW used for VM cleaning.
    ...   Cleaning will be perfomrmed on /tmp and ${TEMP_LOGS_DIR}. Also
    ...    processes remaining after files deletion would be killed.
    Run Keyword If    '${alias}'=='local' or '${alias}'=='Master'    Run Keywords
    ...    hran_general.Clean up directory    /tmp    720    ${alias}
    ...    AND    hran_general.Clean up directory    /home/ute/btsauto/logs    240    ${alias}
    ...    AND    hran_general.Kill processes remained after files deletion on VMs /home partition    ${alias}
    ...    ELSE    Run Keywords    hran_general.Clean up directory    /tmp    720    ${alias}
    ...    host_ip=${configuration["host_ip"]}    ssh_port=${configuration["ssh_port"]}
    ...    ssh_username=${configuration["ssh_username"]}    ssh_password=${configuration["ssh_password"]}
    ...    AND    hran_general.Clean up directory    /home/ute/btsauto/logs    240    ${alias}
    ...    host_ip=${configuration["host_ip"]}
    ...    ssh_port=${configuration["ssh_port"]}    ssh_username=${configuration["ssh_username"]}
    ...    ssh_password=${configuration["ssh_password"]}
    ...    AND    hran_general.Kill processes remained after files deletion on VMs /home partition
    ...    ${alias}    host_ip=${configuration["host_ip"]}    ssh_port=${configuration["ssh_port"]}
    ...   ssh_username=${configuration["ssh_username"]}
    ...    ssh_password=${configuration["ssh_password"]}

Start syslog on ${smod}
    [Documentation]
    ...    *HISTORY*
    ...    2022.9.29  Update for hran_ta merge to robotws by lixin.kang@nokia.com.
    Log    Trying to start syslog on ${smod}   level=INFO  console=${TRUE}
    ${syslog_started}=  Run keyword and return status  Wait until keyword succeeds  5 min  15 sec
    ...  Restart syslog on ${smod}
    Set test variable  ${${smod}_syslog_started}  ${syslog_started}
    Run keyword if  ${${smod}_syslog_started}  Log    Syslog on ${smod} started  level=TRACE  console=${TRUE}
    ...  ELSE    Fail    Syslog on ${smod} did not start and will not be collected during TC execution

Restart syslog on SMOD1
    Run Keyword And Ignore Error  hran_general.Kill Process By Name  btslog
    Run Keyword And Ignore Error  taf_syslog.Stop Syslog  alias=SMOD1
    ${file_limit}=  Get variable value  ${MAX_UDP_SIZE}  0
    taf_syslog.Start Syslog  alias=SMOD1  log_dir=${Temp Logs Dir}  log_name=SMOD1_UDP
    ...  ip=${SMOD1["UDP_IP"]}  ports=@{UDP ports}  file_limit=${file_limit}    virtualenv_dir=${virtualenv_dir}

Start Syslog On All SMODs
    Log    Trying to start SYSLOG on all SMODs    level=INFO    console=TRUE
    Run Keyword And Ignore Error    taf_syslog.Teardown All Aliases For Syslog
    ${syslog_started_smod1}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    5 min    15 sec    Start syslog    alias=SMOD1     host_ip=127.0.0.1
    ...    virtualenv_dir=${virtualenv_dir}
    Set Test Variable    ${SMOD1_syslog_started}    ${syslog_started_smod1}
    Run Keyword If    ${SMOD1_syslog_started}    Log    SYSLOG on SMOD1 successfully started   level=TRACE   console=True
    Run Keyword If    ${SMOD2_exists}    Run Keywords    Wait Until Keyword Succeeds    5 min    15 sec    Start syslog
    ...    alias=SMOD2    host_ip=${PC_IP2}    virtualenv_dir=${virtualenv_dir}
    ...    AND    Log    SYSLOG on SMOD2 successfully started    level=TRACE    console=True
    ...    AND    Set Test Variable    ${SMOD2_syslog_started}    ${TRUE}

Ensure that SMOD2 is detected inside ADMIN
    ${smods}=    coam.Get Ids For All    SMOD
    Run Keyword If    len(${smods}) != 2    Fail    SMOD2 wasn't detected inside ADMIN
    [Return]    ${TRUE}

Restart syslog on SMOD2
    Start remote syslog  remote_host=${PC_IP2}  udp_ip=${SMOD2["UDP_IP"]}  alias=SMOD2    virtualenv_dir=${virtualenv_dir}

Start remote syslog
    [Arguments]  ${remote_host}  ${udp_ip}  ${alias}    ${virtualenv_dir}=None
    Run Keyword And Ignore Error  hran_general.Kill Process By Name  btslog  local=${FALSE}  host_ip=${remote_host}
    ...  ssh_port=22  ssh_username=ute  ssh_password=ute
    Run Keyword And Ignore Error  taf_syslog.Stop Syslog  alias=${alias}
    ${file_limit}=  Get variable value  ${MAX_UDP_SIZE}  0
    ${syslog_started}  Run keyword and return status  taf_syslog.Start Syslog  alias=${alias}
    ...  log_dir=${Temp Logs Dir}  log_name=${alias}_UDP  ip=${udp_ip}  ports=@{UDP ports}  host_ip=${remote_host}
    ...  file_limit=${file_limit}    virtualenv_dir=${virtualenv_dir}
    Set test variable  ${${alias}_syslog_started}  ${syslog_started}

Check if SMOD2 exists
    [Arguments]    ${is_admin_started}
    ${smod2_variable_exists}=    Run Keyword And Return Status    Variable Should Exist    ${SMOD2}
    ${pc_ip2_variable_exists}=    Run Keyword And Return Status    Variable Should Exist    ${PC_IP2}
    ${smod2_detected}=    Run Keyword If
    ...    ${smod2_variable_exists} and ${pc_ip2_variable_exists} and ${is_admin_started}
    ...    Wait Until Keyword Succeeds    15m    30 sec    Ensure that SMOD2 is detected inside ADMIN
    ...    ELSE IF    ${smod2_variable_exists} and ${pc_ip2_variable_exists} and not ${is_admin_started}
    ...    Set Variable    ${TRUE}
    ...    ELSE    Set Variable    ${NONE}
    Run Keyword If    ${smod2_detected}    Run keywords    Log    Two SMODs were detected    console=True
    ...    AND    Set test variable    ${SMOD2_exists}    ${TRUE}
    ...    ELSE    Run keywords    Log    One SMOD was detected    console=True
    ...    AND    Set test variable    ${SMOD2_exists}    ${FALSE}

Start syslog
    [Arguments]    ${alias}    ${host_ip}    ${virtualenv_dir}=None
    ${file_limit}=    Get variable value    ${MAX_UDP_SIZE}    0
    ${UDP_IP}    Get From Dictionary    ${${alias}}    UDP_IP
    taf_syslog.Start Syslog    alias=${alias}    log_dir=${UDP Logs}    log_name=${alias}_UDP
    ...    ip=${UDP_IP}    ports=@{UDP ports}    host_ip=${host_ip}
    ...    file_limit=${file_limit}    virtualenv_dir=${virtualenv_dir}

Collect syslog
    Run Keyword If    ${SMOD1_syslog_started}    Collect syslog from SMOD1
    Run Keyword If    ${SMOD2_syslog_started}    Collect syslog from SMOD2
    Run Keyword And Ignore Error    taf_syslog.Teardown All Aliases For Syslog

Collect syslog from ${alias}
    ${syslog_collected}=    Run Keyword And Return Status
    ...    Collect syslog results    alias=${alias}    destination=${UDP Logs}/${alias}_UDP.tar.gz    unzip=false
    Run Keyword If    ${syslog_collected}
    ...    Log    SYSLOG on ${alias} successfully collected to ${UDP Logs}/${alias}_UDP.tar.gz   level=INFO   console=True
    ...    ELSE    Log    SYSLOG on ${alias} collection failed!.    level=INFO    console=True

Start Infomodel
    [Arguments]    ${bts_host}=192.168.255.129    ${bts_port}=443    ${use_ssl}=True
    Log    Trying to connect to ADMIN INFOMODEL (max 5 min)    level=INFO    console=True
    Setup Infomodel    address=${bts_host}    port=${bts_port}    use_ssl=${use_ssl}
    ...    admin_api_log_dir=${BTS Files}/    timeout=300
    ${infomodel_started}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    5 min    15 sec    Connect Infomodel
    Set Test Variable    ${infomodel_started}
    Log    ADMIN INFOMODEL successfully started!    level=INFO    console=True

Collect Infomodel
    Save Infomodel Log    filename=${BTS Files}/InfoModel_log.ims2    timeout=300
    Log    ADMIN INFOMODEL successfully collected to ${BTS Files}/InfoModel_log.ims2    level=INFO    console=True
    Teardown Infomodel
    Log    ADMIN INFOMODEL successfully finished!    level=INFO    console=True

Start Admin
    [Arguments]    ${bts_host}=192.168.255.129    ${bts_port}=443    ${use_ssl}=TRUE
    Log    Trying to connect to ADMIN (max 5 min)    level=INFO    console=True
    ${admin_started}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    5 min    15 sec    coam.Setup Admin    admin_api_log_dir=${BTS Files}
    ...    bts_host=${bts_host}    bts_port=${bts_port}    use_ssl=${use_ssl}
    Set Test Variable    ${admin_started}
    Log    ADMIN successfully started!    level=INFO    console=True

Collect Admin
    coam.Teardown Admin
    Log    ADMIN successfully finished!    level=INFO    console=True

_Set SW_TYPE
    ${regex}=  Set variable
    ...    (?i)(wn\\d+_fl\\d+_gf\\d+_)?(?P<product>(SBTS|5G|FL|WN|WBTS|FDSW|TL)[0-9]*)(?P<postfix>[a-zA-Z0-9\.]*)
    ${result}=  Get Regexp Matches  ${ACTIVE_SW_VERSION}  ${regex}  product  postfix
    ${product}  ${postfix}=  Set variable  ${result[0]}
    ${product}=  Convert To Uppercase  ${product}
    ${postfix}=  Convert To Uppercase  ${postfix}
    Set test variable  ${SW_TYPE}  ${product}${postfix}

_Set COMMISSIONING_PATH
    ${custom_scf_path}=  Get Variable Value  ${COMMISSIONING_PATH}  ${EMPTY}
    Return from keyword if  '${custom_scf_path}'!=''
    Run keyword If    ${TAF_CONFIG_MODEL}  Find SCF file in UTE configs
    ...  ELSE  Find SCF file

Find SCF file
    Log  Find SCF file  console=${True}
    ${COMMISSIONING_PATH}=  Get commissioning path  ${active SW version}
    Set test variable  ${COMMISSIONING_PATH}

Find SCF file in UTE configs
    Log  Find SCF file in UTE configs  console=${True}
    ${path_status}  Run Keyword and return status  OperatingSystem.Directory Should Exist
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}
    ${config_path}  Set Variable If  ${path_status}
    ...  /home/ute/testline_configuration/${TESTLINE_NAME}
    ...  /home/ute/robotlte/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}
    ${commissionings_directory}=  Set Variable  ${config_path}/node1
    @{enb_build_split}=  Split String  ${ENB_BRANCH}  _
    Set test variable  ${COMMISSIONING_PATH}
    ...    ${commissionings_directory}/BTS_${tl.tl_cloud_topology}_${enb_build_split}[0].xml

Print Active And Passive SW Version
    ${status}    ${active SW version msm}=
    ...    Run Keyword And Ignore Error    Infomodel Get Active SW Version    module=MSM
    ${status}    ${passive SW version msm}=
    ...    Run Keyword And Ignore Error    Infomodel Get Passive SW Version    module=MSM
    ${status}    ${sbts version}=    Run Keyword And Ignore Error
    ...    Should Match Regexp    ${active SW version msm}    SBTS17|SBTS18
    Log    Active SW version (SMOD1): ${active SW version msm}    console=True
    Set tags    SMOD1_SW_active-${active SW version msm}
    Log    Passive SW version (SMOD1): ${passive SW version msm}    console=True
    Set tags    SMOD1_SW_passive-${passive SW version msm}
    Set Test Variable    ${QC MSM Active SW}    ${active SW version msm}
    Set Test Variable    ${active SW version}    ${active SW version msm}
    Set Test Variable    ${sbts version}
    ${status}    ${active SW version esm}=    Run Keyword And Ignore Error
    ...    Infomodel Get Active SW Version    module=ESM
    Run Keyword If    '${status}'=='PASS' and '${active SW version esm}'
    ...    Run keywords    Log    Active SW version (SMOD2): ${active SW version esm}    console=True
    ...    AND    Set tags    SMOD2_SW_active-${active SW version esm}
    Set Test Variable    ${QC ESM Active SW}    ${active SW version esm}
    ${status}    ${passive SW version esm}=    Run Keyword And Ignore Error
    ...    Infomodel Get Passive SW Version    module=ESM
    Run Keyword If    '${status}'=='PASS' and '${passive SW version esm}'    Run keywords
    ...    Log    Passive SW version (SMOD2): ${passive SW version esm}    console=True
    ...    AND    Set tags    SMOD2_SW_passive-${passive SW version esm}
    Set Qc Parameter    qc_tc_swbuild    ${QC MSM Active SW}; ${QC ESM Active SW}

Get Swconfig From Extension
    [Documentation]
    ...   Get Swconfig From Extension
    ...  *AUTHOR*
    ...  lixin.kang@nokia.com
    ...
    ...  *HISTORY*
    ...   2022.9.29  Update for hran_ta merge to robotws.
    ${status}    ${result}=    Run Keyword And Ignore Error
    ...    Get File From System Module    target_ip="192.168.255.119"
    ...    source_path=/ffs/run/swconfig.txt    destination_path=${BTS Files}/ext_swconfig.txt
    ...    via_ip=${PC_IP2}
    Run Keyword If    '${status}'=='PASS'    Run Keywords
    ...    Log    swconfig.txt from SMOD2 successfully collected to ${BTS Files}    console=True
    ...    AND    Return From Keyword
    ${status}    ${result}=    Run Keyword And Ignore Error
    ...    Get File From System Module    target_ip="192.168.255.129"
    ...    source_path=/ffs/run/swconfig.txt    destination_path=${BTS Files}/ext_swconfig.txt
    ...    via_ip=${PC_IP2}
    Run Keyword If    '${status}'=='PASS'    Run Keyword
    ...    Log    swconfig.txt from SMOD2 successfully collected to ${BTS Files}    console=True
    ...    ELSE    Run Keyword    Log    swconfig.txt could not be retrieved from SMOD2!    console=True

Set Qc Parameter
    [Arguments]    ${qc_parameter}    ${value}
    [Documentation]    Keyword used to set OS environment variable which will be used by test reporter in order to
    ...    report QC paramater to test instance or tets run
    ...
    ...    *AUTHOR*
    ...    catalin.chiorean@nokia.com
    ...
    ...    *USAGE*
    ...    | Parameter | Man. | Description |
    ...    | qc_parameter | YES | qc paramater to be exported as env variable |
    ...    | value | YES | qc paramater value |
    ...
    ...    *EXAMPLE*
    ...    Set Qc Parameter | qc_tc_swbuild | FL17A_234
    ...
    ...    *ALLOWED QC PARAMETERS*
    ...    Currently the implemeted paramaters exporeted as variable are:
    ...    - "qc_tc_swbuild" coresponding to "SW Build" qc parameter name
    ${allowed_paramaters}=    Set Variable    qc_tc_swbuild
    Run Keyword If    '${qc_parameter}' == 'qc_tc_swbuild'    Set Environment Variable    ${qc_parameter}    ${value}
    ...    ELSE    Log    Parameter not allowed, list of allowed parameters: ${allowed_paramaters}    console=True

Set LTE alarms lists
    [Arguments]    ${LTE_alarm_dict}
    FOR    ${key}    IN    @{LTE_alarm_dict.keys()}
        Set Test Variable    ${${key}}    ${${LTE_alarm_dict["${key}"]}}
    END

Set Service Access Configuration SyVe
    [Arguments]    ${value}=False
    [Documentation]    Set Service Access Configuration feature: accepted values False or True
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ${FEATCADM_object_found}=    Check Infomodel Object    dist_name=//FEATCADM_CONF_M-1
    Run Keyword If    not ${FEATCADM_object_found}    Run Keywords
    ...    Log    Feature LTE2647 BTS LINUX System account permissions is not available on running SW!    console=True
    ...    AND    Return From Keyword
    ${BTS_eq}=    coam.Get Parameters For All    BTS
    ${SCF_dn}=    Set Variable    MRBTS-${BTS_eq[0].btsId}/MNL-1/MNLENT-1/FEATCADM-1
    ${IM_dn}=    Set Variable If    '${SMOD1['HW_TYPE']}'!='ASIA'    //FEATCADM_CONF_M-1
    ...    //RUNTIME_VIEW-${SUBRACK}//FEATCADM_CONF_M-1
    ${Feature_status}=    Query infomodel    query=get object ${IM_dn}
    ${systemAcctPermEnable_found}=    Run Keyword And Return Status
    ...    Variable Should Exist    ${Feature_status.systemAcctPermEnable}
    Run Keyword If    ${systemAcctPermEnable_found}   Run Keyword If    '${Feature_status.systemAcctPermEnable}'!='${value}'
    ...    Run Keywords    Log
    ...    BTS system account permissions enable: ${Feature_status.systemAcctPermEnable}, need commissioning to ${value}!
    ...    console=True
    ...    AND    coam.Perform Parameter Recommissioning    dist_name=${SCF_dn}
    ...    parameter=systemAcctPermEnable    operation=update    value=${value.lower()}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    AND    Log    BTS system account permissions enable: ${value}, successfully commissioned!    console=True
    Run Keyword If    ${systemAcctPermEnable_found}    Run Keyword If    '${Feature_status.systemAcctPermEnable}'=='${value}'
    ...    Log    BTS system account permissions enable: ${Feature_status.systemAcctPermEnable}, commissioning not needed!
    ...    console=True
    Run Keyword If    not ${systemAcctPermEnable_found}
    ...    Log    Feature LTE2647 BTS LINUX System account permissions is not available on running SW!    console=True

Get Snapshot and Active Alarms
    [Documentation]    Author: Valentin Marian/Radu Andronache/Gabriel Stanculescu/Emanuel SZIJJ(SOAM)/Emanuel SZIJJ(SyVe)
    ...    Keyword generates name for snapshot folder, triggers snapshot generation
    ...    Triggers check if file has been generated at intended location.
    ${yyyy}    ${mm}    ${dd}    ${hh}    ${min}    ${ss}=    Get Time
    ...    format=year,month,day,hour,min,sec
    ${snapshot_and_alarms_dir}=    Set Variable    ${Test Results Dir}/Snapshot__${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}
    Log    Initial snapshot and active alarms location: ${TEMP_LOGS_DIR}    console=True    level=INFO
    Log    Final snapshot and active alarms location: ${snapshot_and_alarms_dir}    console=True    level=INFO
    Log    Getting active alarms    console=True
    ${active_alarms}=    Get Active Alarms From ADMIN
    ${active_alarms_string}=    Convert to string    ${active_alarms}
    Create File    ${snapshot_and_alarms_dir}/active_alarms.txt    ${active_alarms_string}
    Log    Active alarms available at: ${snapshot_and_alarms_dir}/active_alarms.txt    console=True
    coam.Collect Snapshot
    ...    ${snapshot_and_alarms_dir}/ADMIN_Snapshot_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.zip    timeout=600
    ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Exist
    ...    ${snapshot_and_alarms_dir}/ADMIN_Snapshot_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.zip
    Run Keyword If    ${status}   Log   Snapshot file available at ${snapshot_and_alarms_dir}   level=INFO   console=True
    ...    ELSE    Run Keywords
    ...    Log   Snapshot file not available at ${snapshot_and_alarms_dir}   level=ERROR   console=True
    ...    AND    Fail    Snapshot file not available at ${snapshot_and_alarms_dir}

Get Active Alarms From ADMIN
    [Arguments]    ${alias}=default
    [Documentation]    Keyword is used to get active alarms from ADMIN
    ...
    ...
    ...    *AUTHOR*
    ...    emanuel.szijj@nokia.com
    ${active_alarms}=    coam.Get Active Alarms    alias=${alias}
    [Return]    ${active_alarms}

Get LTE Active Category Alarms Parameter Syve
    [Documentation]    LTE Active Category Alarms parameter check
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | alias | Yes | Master or Slave |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | actCategoryAlarms | True or False |
    ${IM_dn}=    Set Variable If    '${SMOD1['HW_TYPE']}'!='ASIA'    //FMCADM_A-1    //BTS_L-1//FMCADM_A-1
    ${FMCADM_object_found}=    Check Infomodel Object    dist_name=${IM_dn}
    Run Keyword If    not ${FMCADM_object_found}    Return From Keyword    False
    ${FMCADM_object}=    Query Infomodel    query=get object ${IM_dn}
    ${actCategoryAlarms_found}=    Run Keyword And Return Status
    ...    Variable Should Exist    ${FMCADM_object.actCategoryAlarms}
    ${actCategoryAlarms}=    Set Variable If    ${actCategoryAlarms_found}    ${FMCADM_object.actCategoryAlarms}   False
    [Return]    ${actCategoryAlarms}

BTS SiteName information
    [Documentation]    Helper keyword providing BTS siteName info.
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | BTS_SiteName | BTS siteName info |
    ${BTS_PARAM_LIST}=    coam.Get Parameters For All    BTS
    ${BTS_SiteName}=    Create List
    FOR    ${item}    IN    @{BTS_PARAM_LIST}
        ${BTS_SiteName}=    Set Variable    ${item.btsName}
    END
    Set Tags    Site name = ${BTS_SiteName}
    Log    Site name = ${BTS_SiteName}    level=INFO    console=${TRUE}
    [Return]    ${BTS_SiteName}

Setup NetAct By TAF
    [Documentation]    Keyword used for set up of NetAct and its cwwas node
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    netact.Add Node    cmwas    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    netact.Add Node    fmwas    ${NETACT['fm_host']}    ${NETACT['user']}    ${NETACT['password']}
    ${web_url}=    netact.Detect Web Url
    netact.Add WEB URL    ${web_url}    ${NETACT['user']}    ${NETACT['password']}

Teardown NetAct By TAF
    [Documentation]    Keyword used to tear down NetAct and its cwwas node
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    netact.Delete Node    cmwas
    netact.Delete Node    fmwas
    netact.Clean All

Block or Unblock one cell from WebEM
    [Arguments]    ${cell_class_name}    ${action}=Block
    [Documentation]    Keyword used to block or unblock one cell from WebEM
    ...    based on specific technology distName
    ...
    ...    *AUTHOR*
    ...    ana.tugui@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | cell_class_name | Yes | LNCEL, WNCEL, GNCEL|
    ...    | action | Yes | Block or Unblock |
    ${LNCEL_parameters_list}   ${WNCEL_parameters_list}   ${GNCEL_parameters_list}    Admin Get BTS CELL parameters list
    ${cell_exist}=    Run Keyword And Return Status    Should Not Be Empty    ${${cell_class_name}_parameters_list}
    Run Keyword If    ${cell_exist}    coam.${action}    ${${cell_class_name}_parameters_list[0][0]}    timeout=200
    ...    ELSE    Run Keywords    Log    No ${cell_class_name} cells available on BTS!    level=ERROR
    ...    AND    Fail    No ${cell_class_name} cells available on BTS!
    ${CELL_PARAM_LIST}=    coam.Get Parameters For    ${cell_class_name}    ${${cell_class_name}_parameters_list[0][0]}
    ${cell_status}=    Run Keyword And Return Status    coam.Assert    ${cell_class_name}
    ...    ${${cell_class_name}_parameters_list[0][0]}    blockingState=${action}ed
    Set Test Variable    ${cell_status}
    Run Keyword If    ${cell_status}    Log    ${cell_class_name} successfully ${action}ed!    console=True
    ...    ELSE    Run Keywords    Log    ${cell_class_name} not ${action}ed!    level=ERROR
    ...    AND    Fail    ${cell_class_name} not ${action}ed!

SyVe Customizable Preconditions
    [Arguments]    ${CheckConf}    ${CheckCells}    ${CheckModules}
    [Documentation]    Helper keyword used to determine whether checks for BTS configuration,
    ...    cells and modules states are needed
    ...    in order to compute the test verdict based on following:
    ...    - Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    - Check operational states for cells and radio modules
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | CheckConf | Yes | Enable/disable BTS configuration precheck used for TcVerdict evaluation |
    ...    | CheckCells | Yes | Enable/disable cells states precheck used for TcVerdict evaluation |
    ...    | CheckModules | Yes | Enable/disable radio modules states precheck used for TcVerdict evaluation |
    ...
    ...    Output set flags for TC verdict decision as beneath:
    ...    If PreconditionBTSConf=False -> TC verdict: Blocked
    ...    If PreconditionCellsOnAir=False -> TC verdict: Blocked
    ...    If PreconditionModulesWorking=False -> TC verdict: PassedWithRestriction
    ...
    ...    *HISTORY*
    ...    add NRBTS rat cell check yuyan.xu@nokia-sbell.com \
    [Timeout]    10 min
    Log    SyVe Customizable Preconditions    level=TRACE    console=True
    ${BTS_scf}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    #${BTS_scf_initial}    Set ValidatePlanAgainstDetectedHW Value SCF    ${BTS_scf}    false
    Set Test Variable    ${BTS_scf_initial}    ${BTS_scf}
    ${NRBTS_runtime_cell_number}    ${LTE_runtime_cell_number}    ${LTE_IOT_runtime_cell_number}
    ...    ${WCDMA_runtime_cell_number}    ${GSM_runtime_cell_number}    ${BTS_runtime_rmod_number}
    ...    Get WebEM Runtime Cells And RMODs Number
    Set Test Variable    ${NRBTS_runtime_cell_number}
    Set Test Variable    ${LTE_runtime_cell_number}
    Set Test Variable    ${LTE_IOT_runtime_cell_number}
    Set Test Variable    ${WCDMA_runtime_cell_number}
    Set Test Variable    ${GSM_runtime_cell_number}
    Set Test Variable    ${BTS_runtime_rmod_number}
    ${PreconditionBTSConf}=    Run Keyword If    ${CheckConf}    Check BTS Configuration SyVe    ${BTS_scf_initial}
    Set Test Variable    ${PreconditionBTSConf}
    Run Keyword If    ${CheckConf}    Run Keyword If    ${PreconditionBTSConf}
    ...   Log    BTS SCF configured cells and radio modules number are in line with WebEM running view number!
    ...    level=INFO    console=True
    Run Keyword If    ${CheckConf}    Run Keyword If    not ${PreconditionBTSConf}    Run Keywords
    ...   Log    BTS SCF configured cells and radio modules number are not in line with WebEM running view number!
    ...    level=ERROR
    ...    AND    Fail    Testline not ready due to wrong BTS configuration, triggering recovery...    BLOCKED-TESTS
    ${PreconditionCellsOnAir}=    Run Keyword If    ${CheckCells}    Check All Cells State SyVe
    Set Test Variable    ${PreconditionCellsOnAir}
    Run Keyword If    ${CheckCells}    Run Keyword If    ${PreconditionCellsOnAir}
    ...    Log    All BTS cells are operational!    level=INFO
    ...    console=True
    Run Keyword If    ${CheckCells}    Run Keyword If    not ${PreconditionCellsOnAir}    Run Keywords
    ...   Log    At least one BTS cell is not operational!
    ...    level=ERROR
    ...    AND    Fail    Testline not ready due to cells not being operational, triggering recovery...    BLOCKED-TESTS
    ${PreconditionModulesWorking}=    Run Keyword If    ${CheckModules}    Check All RMODs State SyVe
    Set Test Variable    ${PreconditionModulesWorking}
    Run Keyword If    ${CheckModules}    Run Keyword If    ${PreconditionModulesWorking}
    ...   Log    All BTS radio modules are operational!    level=INFO
    ...    console=True
    Run Keyword If    ${CheckModules}    Run Keyword If    not ${PreconditionModulesWorking}
    ...   Log    At least one BTS radio module is not operational!    level=WARN

Check BTS Configuration SyVe
    [Arguments]    ${BTS_scf}
    [Documentation]    Helper keyword checking if number of configured cells and radio modules in SCF are properly mapped on
    ...    WebEM running view.
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | BTS_scf | Yes | BTS SCF file full path |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | BTSConf | True or False |
    ...
    ...    *HISTORY*
    ...    add NRBTS rat yuyan.xu@nokia-sbell.com \
    ${NRBTS_scf_cell_number}    ${LTE_scf_cell_number}    ${LTE_IOT_scf_cell_number}    ${WCDMA_scf_cell_number}
    ...    ${GSM_scf_cell_number}    ${BTS_scf_rmod_number}=    Get SCF Configured Cells And RMODs Number   ${BTS_scf}
    ${NRBTS_cell_conf}=    Run Keyword And Return Status
    ...    Should be equal    ${NRBTS_runtime_cell_number}    ${NRBTS_scf_cell_number}
    ${all_LTE_runtime_cell_number}    Evaluate    ${LTE_runtime_cell_number}+${LTE_IOT_runtime_cell_number}
    ${LTE_cell_conf}=    Run Keyword And Return Status
    ...    Should be equal    ${all_LTE_runtime_cell_number}    ${LTE_scf_cell_number}
    ${LTE_IOT_cell_conf}=    Run Keyword And Return Status
    ...    Should be equal    ${LTE_IOT_runtime_cell_number}    ${LTE_IOT_scf_cell_number}
    ${WCDMA_cell_conf}=    Run Keyword And Return Status
    ...    Should be equal    ${WCDMA_runtime_cell_number}    ${WCDMA_scf_cell_number}
    ${GSM_cell_conf}=    Run Keyword And Return Status
    ...    Should be equal    ${GSM_runtime_cell_number}    ${GSM_scf_cell_number}
    ${BTS_rmod_conf}=    Run Keyword And Return Status
    ...   Should be equal    ${BTS_runtime_rmod_number}    ${BTS_scf_rmod_number}
    ${cell_conf}    Set Variable
    ...    ${NRBTS_cell_conf} and ${LTE_cell_conf} and ${LTE_IOT_cell_conf} and ${WCDMA_cell_conf} and ${GSM_cell_conf}
    ${BTSConf}=    Set Variable If    ${cell_conf} and ${BTS_rmod_conf}    ${TRUE}    ${FALSE}
    Log    NRBTS configured/running cells number: ${NRBTS_scf_cell_number}/${NRBTS_runtime_cell_number}    console=True
    Log    LTE configured/running cells number: ${LTE_scf_cell_number}/${all_LTE_runtime_cell_number}    console=True
    Log    LTE IOT configured/running cells number: ${LTE_IOT_scf_cell_number}/${LTE_IOT_runtime_cell_number}  console=True
    Log    WCDMA configured/running cells number: ${WCDMA_scf_cell_number}/${WCDMA_runtime_cell_number}    console=True
    Log    GSM configured/running cells number: ${GSM_scf_cell_number}/${GSM_runtime_cell_number}    console=True
    Log    BTS configured/running radio modules number: ${BTS_scf_rmod_number}/${BTS_runtime_rmod_number}    console=True
    [Return]    ${BTSConf}

Get WebEM Runtime Cells And RMODs Number
    [Documentation]    Helper keyword providing number of cells and radio modules from WebEM running view.
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | NRBTS_runtime_cell_number | WebEM runtime view NRBTS cells number |
    ...    | LTE_runtime_cell_number | WebEM runtime view LTE cells number |
    ...    | LTE_IOT_runtime_cell_number | WebEM runtime view LTE IOT cells number |
    ...    | WCDMA_runtime_cell_number | WebEM runtime view WCDMA cells number |
    ...    | GSM_runtime_cell_number | WebEM runtime view GSM cells number |
    ...    | BTS_runtime_rmod_number | WebEM runtime view BTS radio modules number |
    ...
    ...    *HISTORY*
    ...    add NRBTS rat yuyan.xu@nokia-sbell.com \
    ${NRBTS_cell_ids}=    coam.Get Ids For All    NRCEL
    Set Test Variable    ${NRBTS_cell_ids}
    ${NRBTS_runtime_cell_number}=    Get Length    ${NRBTS_cell_ids}
    ${LTE_cell_ids}    ${LTE_IOT_cell_ids}=    Admin Get LTE CELL Ids list
    Set Test Variable    ${LTE_cell_ids}
    Set Test Variable    ${LTE_IOT_cell_ids}
    ${LTE_runtime_cell_number}=    Get Length    ${LTE_cell_ids}
    ${LTE_IOT_runtime_cell_number}=    Get Length    ${LTE_IOT_cell_ids}
    ${WCDMA_cell_ids}=    coam.Get Ids For All    WNCEL
    Set Test Variable    ${WCDMA_cell_ids}
    ${WCDMA_runtime_cell_number}=    Get Length    ${WCDMA_cell_ids}
    ${GSM_cell_ids}=    coam.Get Ids For All    GNCEL
    Set Test Variable    ${GSM_cell_ids}
    ${GSM_runtime_cell_number}=    Get Length    ${GSM_cell_ids}
    ${BTS_rmod_ids}=    coam.Get Ids For All    RMOD
    Set Test Variable    ${BTS_rmod_ids}
    ${BTS_runtime_rmod_number}=    Get Length    ${BTS_rmod_ids}
    [Return]    ${NRBTS_runtime_cell_number}    ${LTE_runtime_cell_number}    ${LTE_IOT_runtime_cell_number}
    ...   ${WCDMA_runtime_cell_number}    ${GSM_runtime_cell_number}    ${BTS_runtime_rmod_number}

Get SCF Configured Cells And RMODs Number
    [Arguments]    ${BTS_scf}
    [Documentation]    Helper keyword providing number of cells and radio modules configured in SCF
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | scf_file | Yes | BTS SCF file full path |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | NRBTS_scf_cell_number | SCF configured NRBTS cells number |
    ...    | LTE_scf_cell_number | SCF configured LTE cells number |
    ...    | LTE_IOT_scf_cell_number | SCF configured LTE IOT cells number |
    ...    | WCDMA_scf_cell_number | SCF configured WCDMA cells number |
    ...    | GSM_scf_cell_number | SCF configured GSM cells number |
    ...    | BTS_scf_rmod_number | SCF configured BTS radio modules number |
    ...
    ...    *HISTORY*
    ...    add NRBTS rat yuyan.xu@nokia-sbell.com
    ...    2022.9.29 Update for hran_ta merge to robotws by lixin.kang@nokia-sbell.com
    ...    2023.11.17 Add test variable for Cell DNs list, and relationship for NBIOT linked Cells

    Import Library    XML    use_lxml=True    WITH NAME    L_XML_RUNTIME
    ${scf_xml}=    L_XML_RUNTIME.Parse Xml    ${BTS_scf}
    ${NRBTS_scf_cell_number}=    L_XML_RUNTIME.Get Element Count    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    ${LTE_scf_cell_number}=    L_XML_RUNTIME.Get Element Count    ${scf_xml}    .//managedObject[@class="NOKLTE:LNCEL"]
    ${LTE_IOT_scf_cell_number}=    L_XML_RUNTIME.Get Element Count
    ...    ${scf_xml}    .//managedObject[@class="NOKLTE:LNCEL"]/p[@name="cellTechnology" and text()="NB-IoT-FDD"]
    ${WCDMA_scf_cell_number}=    L_XML_RUNTIME.Get Element Count    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.wcdma:WNCEL"]
    ${GSM_scf_cell_number}=    L_XML_RUNTIME.Get Element Count    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.gsm:GNCEL"]
    ${BTS_scf_rmod_number}=    L_XML_RUNTIME.Get Element Count    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.eqm:RMOD"]
    ${LTE_NB_IoT_FDD_SCF_DIC}    Create Dictionary
    ${elements}    L_XML_RUNTIME.Get Elements
    ...    ${scf_xml}    .//managedObject[@class="NOKLTE:LNCEL"]/p[@name="cellTechnology" and text()="NB-IoT-FDD"]/..
    FOR    ${element}    IN    @{elements}
        ${nbIoTMode}    L_XML_RUNTIME.Get Element Text    ${element}    p[@name="nbIoTMode"]
        Continue For Loop If    '${nbIoTMode}'=='standalone'
        ${distName}    L_XML_RUNTIME.Get Element Attribute    ${element}    distName
        ${nbIotLinkedCellId}    L_XML_RUNTIME.Get Element Text    ${element}    p[@name="nbIotLinkedCellId"]
        ${host_cell_dn}    L_XML_RUNTIME.Get Element Attribute    ${scf_xml}    distName
        ...    .//managedObject[@class="NOKLTE:LNCEL"]/p[@name="lcrId" and text()="${nbIotLinkedCellId}"]/..
        Set To Dictionary    ${LTE_NB_IoT_FDD_SCF_DIC}    ${host_cell_dn}    ${distName}
    END
    Set Test Variable    ${LTE_NB_IoT_FDD_SCF_DIC}
    ${ALL_NR_CELL_SCF_DN}    Create List
    ${elements}    L_XML_RUNTIME.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    FOR    ${element}    IN    @{elements}
        ${distName}    L_XML_RUNTIME.Get Element Attribute    ${element}    distName
        Append To List    ${ALL_NRCELL_SCF_DN}    ${distName}
    END
    ${elements}    L_XML_RUNTIME.Get Elements    ${scf_xml}    .//managedObject[@class="NOKLTE:LNCEL"]
    ${ALL_LTE_CELL_SCF_DN}    Create List
    FOR    ${element}    IN    @{elements}
        ${distName}    L_XML_RUNTIME.Get Element Attribute    ${element}    distName
        Append To List    ${ALL_LTE_CELL_SCF_DN}    ${distName}
    END
    ${elements}    L_XML_RUNTIME.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.wcdma:WNCEL"]
    ${ALL_WCDMA_CELL_SCF_DN}    Create List
    FOR    ${element}    IN    @{elements}
        ${distName}    L_XML_RUNTIME.Get Element Attribute    ${element}    distName
        Append To List    ${ALL_WCDMA_CELL_SCF_DN}    ${distName}
    END
    ${elements}    L_XML_RUNTIME.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.gsm:GNCEL"]
    ${ALL_GSM_SCF_DN}    Create List
    FOR    ${element}    IN    @{elements}
        ${distName}    L_XML_RUNTIME.Get Element Attribute    ${element}    distName
        Append To List    ${ALL_GSM_SCF_DN}    ${distName}
    END
    ${elements}    L_XML_RUNTIME.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.eqm:RMOD"]
    ${ALL_RMOD_SCF_DN}    Create List
    FOR    ${element}    IN    @{elements}
        ${distName}    L_XML_RUNTIME.Get Element Attribute    ${element}    distName
        Append To List    ${ALL_RMOD_SCF_DN}    ${distName}
    END
    Set Test Variable    ${ALL_NR_CELL_SCF_DN}
    Set Test Variable    ${ALL_LTE_CELL_SCF_DN}
    Set Test Variable    ${ALL_WCDMA_CELL_SCF_DN}
    Set Test Variable    ${ALL_GSM_SCF_DN}
    Set Test Variable    ${ALL_RMOD_SCF_DN}
    [Return]    ${NRBTS_scf_cell_number}    ${LTE_scf_cell_number}    ${LTE_IOT_scf_cell_number}    ${WCDMA_scf_cell_number}
    ...    ${GSM_scf_cell_number}    ${BTS_scf_rmod_number}

Get Relationship Of NB IoT Cell
    [Arguments]    ${mo}
    [Documentation]    Helper keyword providing NBIOT host and child cell.
    ...    ${LTE_NB_IoT_FDD_RUNTIME_DIC} created by kw 'hran_admin.Admin Get LTE CELL Ids list'.
    ...    ${LTE_NB_IoT_FDD_SCF_DIC} created by kw 'hran_frame_taf_oam.Get SCF Configured Cells And RMODs Number'.
    ...    *AUTHOR*
    ...    bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | mo | Yes | runtime DN or SCF DN of NBIOT host cell |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | target_dic | dictionary as {"host_cell_dn":"child_cell_dn"}. |
    ...    If given mo is not a NBIOT host cell, return an empty dic.
    ...    *Example*
    ...    | ${target_dic_scf} | Get Relationship Of NB IoT Cell | MRBTS-1894/LNBTS-3552/LNCEL-6 |
    ...    | ${target_dic_rt} | Get Relationship Of NB IoT Cell | /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-3552/LNCEL_R-6 |
    ...    ${target_dic_scf}={'MRBTS-1894/LNBTS-3552/LNCEL-6': 'MRBTS-1894/LNBTS-3552/LNCEL-3'}
    ...    ${target_dic_rt}=
    ...    {'/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-3552/LNCEL_R-6':'/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-3552/LNCEL_R-3'}
    ${is_runtime_mo}    Run Keyword And Return Status    Should Match Regexp    ${mo}    /LNCEL_R-\\d+\$
    ${dic_to_trace}    Set Variable If    ${is_runtime_mo}    ${LTE_NB_IoT_FDD_RUNTIME_DIC}    ${LTE_NB_IoT_FDD_SCF_DIC}
    ${parent_lte_cell}    Get Dictionary Keys    ${dic_to_trace}
    ${target_dic}    Create Dictionary
    FOR    ${parent}    IN    @{parent_lte_cell}
        Run Keyword If    "${parent}"=="${mo}" or "${dic_to_trace['${parent}']}"=="${mo}"
        ...    Set To Dictionary    ${target_dic}    ${parent}    ${dic_to_trace['${parent}']}
    END
    [Return]    ${target_dic}

Check SBTS SMOD RMOD Cells Alarms
    [Arguments]    ${timeout}=10 sec    ${print_table}=${False}
    [Documentation]    KW for wrapping functions for checking SBTS SMODs, RMODs, cell states and presence of active alarms
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...    *HISTORY*
    ...    2021.03.08 Refactored by yuki and added in this resource by lixin.kang@nokia-sbell.com.
    ...    2022.09.29 Refactored by  lixin.kang@nokia-sbell.com for hran_ta merge to robotws
    LOG    Checking SBTS SMOD RMOD Cells status and Alarms    console=${True}
    ${dic_btsInfo}    coam.Get BTS info
    ${gNbCuType}    Pop From Dictionary    ${dic_btsInfo}    gNbCuType    SA
    ${dic_ratState}    Pop From Dictionary    ${dic_btsInfo}    ratState
    ${productVariantPlanned}    Get ProductVariantPlanned Value
    ${are_smods_online}    Check If All Objects Are Online    SMOD    ${timeout}
    ${are_rmods_online}    Check If All Objects Are Online    RMOD    ${timeout}
    ${are_gcells_online}    Check If All Objects Are Online    GNCEL    ${timeout}
    ...    administrativeState=${_Com_Unlocked_}    blockingState=${_Unblocked_}    operationalState=${_Enabled_}
    ${are_wcells_online}    Check If All Objects Are Online    WNCEL    ${timeout}    blockingState=${_Unblocked_}
    ...    operationalState=${_Enabled_}
    ${are_lcells_online}    Check If All Objects Are Online    LNCEL    ${timeout}    administrativeState=${_Unlocked_}
    ...    blockingState=${_Unblocked_}    operationalState=${_Enabled_}    proceduralState=${_OnAirDone_}
    ${are_nrcells_online}     Check If All Objects Are Online    NRCEL    ${timeout}
    ...    administrativeState=${_Com_Unlocked_}    blockingState=${_Unblocked_}    operationalState=${_Enabled_}
    Admin Check Active Alarms TAF    print_alarms=${print_table}
    #5G Rat service dependent on 4G if NSA
    ${mod_online}    Set Variable    "${are_smods_online}"=="PASS" and "${are_rmods_online}"=="PASS"
    ${cell_online}    Set Variable
    ...    "${are_gcells_online}"=="PASS" and "${are_wcells_online}"=="PASS" and "${are_lcells_online}"=="PASS"
    Run Keyword If
    ...    '${gNbCuType}'=='NSA' and '${dic_ratState['lte']}'=='NO_CELLS' and '${productVariantPlanned}'!='5gClassicalBTS'
    ...     Should be true    ${mod_online} and ${cell_online}    Not all conditions were satisfied!
    ...     ELSE    Should be true    ${mod_online} and ${cell_online} and "${are_nrcells_online}"=="PASS"
    ...     Not all conditions were satisfied!

Check If All Objects Are Online
    [Arguments]    ${path}    ${timeout}=5m    @{parameters_list}
    [Documentation]    Admin Check If All Objects From Path Are Online. Get status and table to log.
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...    *HISTORY*
    ...    2021.03.08 Created by yuki and added in this resource by lixin.kang@nokia-sbell.com.
    ...    2022.09.29 Refactored by  lixin.kang@nokia-sbell.com for hran_ta merge to robotws
    ...    **Input Parameters:**
    ...
    ...    +-------------------+------+-----------------------------------------------------------------------------+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+=============================================================================+
    ...    | path | yes | Path to checked objects.  |
    ...    +-------------------+------+-----------------------------------------------------------------------------+
    ...    | timeout | no | Time of waiting. You can use robot framework time syntax (1s,1m,1h etc.) | 5m |
    ...    +-------------------+------+-----------------------------------------------------------------------------+
    ...    | *parameters_list | no | Parameters to check. Use name=value form
    ...                               | availabilityStatus=Online operationalState=Enabled |
    ...    +-------------------+------+-----------------------------------------------------------------------------+
    ...    **Return Parameters:**
    ...
    ...    +----------------+----------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+========================================================================================+
    ...    | ${status} | True if all objects are online, false if not. |
    ...    +----------------+----------------------------------------------------------------------------------------+
    ...
    ...    **Example of simple usage:**
    ...    .. code-block:: robotframework
    ...    ${status} Check If All Objects Are Online  RMOD availabilityStatus=Online
    Log    ${timeout}
    ${all_cels_status}    ${all_cels}    Run Keyword And Ignore Error    coam.Assert Any    ${path}
    Return From Keyword If    "${all_cels_status}"=="FAIL"    PASS
    ${parameters_lst}=    Run Keyword If    ${parameters_list}    Set Variable    ${parameters_list}
    ...    ELSE    Create List    operationalState=${_Enabled_}
    @{states_names}    Create list
    FOR    ${state}    IN    @{parameters_lst}
        ${state_name}    ${state_value}=    Split String    ${state}    separator==
        Append To List    ${states_names}    ${state_name}
    END
    ${parameters_list_string}    Catenate    SEPARATOR=,    @{parameters_lst}
    ${status}    ${cells}    Run Keyword And Ignore Error    coam.Assert Every    ${path}    ${parameters_list_string}

    # deal with availabilityStatus change in CNI-61110
    ${dic_btsInfo}    coam.Get BTS info
    ${gNbCuType}    Pop From Dictionary    ${dic_btsInfo}    gNbCuType    SA
    ${dic_ratState}    Pop From Dictionary    ${dic_btsInfo}    ratState
    Return From Keyword If    '${path}'=='NRCEL' and '${gNbCuType}'=='NSA' and '${dic_ratState['lte']}'=='NO_CELLS'    PASS
    Wait Until Keyword Succeeds    3x    10s    Check AvailabilityStatus    ${path}
    [Return]    ${status}

Check AvailabilityStatus
    [Arguments]     ${obj_path}
    ${all_obj_status}    ${all_obj}    Run Keyword And Ignore Error    coam.Assert Any    ${obj_path}
    FOR    ${obj}    IN    @{all_obj}
        ${has_availStatus}    Run Keyword And Return Status    Dictionary Should Contain Key   ${obj}   availabilityStatus
        Run Keyword If    ${With_CNI61110}    Should Not Be True    ${has_availStatus}
        ...    ELSE     Should Be Equal As Strings    ${obj['availabilityStatus']}    Online
    END

Get States Values from object by Admin
    [Arguments]    ${states_list}    ${cell_object}
    [Documentation]    Admin get state value from object.
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...    *HISTORY*
    ...    2021.03.08 Created by yuki and added in this resource by lixin.kang@nokia-sbell.com.
    ${values_list}=    create list
    FOR    ${state}    IN    @{states_list}
        ${obj_state}    Get From Dictionary    ${cell_object}    ${state}
        Append to list    ${values_list}    ${obj_state}
    END
    [Return]    @{values_list}

Check All Cells State SyVe
    [Documentation]  Helper keyword checking states of all BTS cells: operationalState=Enabled, availabilityStatus=Online
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | BTS_cells_operational | True or False |
    ...
    ...    *HISTORY*
    ...    add NRBTS rat yuyan.xu@nokia-sbell.com \
    ${NRBTS_cells_operational}=    Run Keyword If    ${NRBTS_cell_ids}    Run Keyword And Return Status
    ...    coam.Assert Every    NRCEL    ${cells_NR_expected_state}
    ...    ELSE    Set Variable    ${TRUE}
    ${LTE_cells_operational}=    Run Keyword If    ${LTE_cell_ids}    Run Keyword And Return Status
    ...    coam.Assert Every    LNCEL    ${cells_LTE_expected_state}
    ...    ELSE    Set Variable    ${TRUE}
    ${WCDMA_cells_operational}=    Run Keyword If    ${WCDMA_cell_ids}    Run Keyword And Return Status
    ...    coam.Assert Every    WNCEL    ${cells_WCDMA_expected_state}
    ...    ELSE    Set Variable    ${TRUE}
    ${GSM_cells_operational}=    Run Keyword If    ${GSM_cell_ids}    Run Keyword And Return Status
    ...    coam.Assert Every    GNCEL    ${cells_GSM_expected_state}
    ...    ELSE    Set Variable    ${TRUE}
    Run Keyword If    ${NRBTS_cell_ids}    Run Keyword If    ${NRBTS_cells_operational}
    ...    Log    All NRBTS cells are operational!    level=INFO
    ...    console=True
    Run Keyword If    ${NRBTS_cell_ids}    Run Keyword If    not ${NRBTS_cells_operational}
    ...    Log    At least one NRBTS cell is not operational!    level=INFO
    ...    console=True
    Run Keyword If    ${LTE_cell_ids}    Run Keyword If    ${LTE_cells_operational}
    ...    Log    All LTE cells are operational!    level=INFO
    ...    console=True
    Run Keyword If    ${LTE_cell_ids}    Run Keyword If    not ${LTE_cells_operational}
    ...   Log    At least one LTE cell is not operational!    level=INFO
    ...    console=True
    Run Keyword If    ${WCDMA_cell_ids}    Run Keyword If    ${WCDMA_cells_operational}
    ...    Log    All WCDMA cells are operational!    level=INFO
    ...    console=True
    Run Keyword If    ${WCDMA_cell_ids}    Run Keyword If    not ${WCDMA_cells_operational}
    ...    Log    At least one WCDMA cell is not operational!    level=INFO
    ...    console=True
    Run Keyword If    ${GSM_cell_ids}    Run Keyword If    ${GSM_cells_operational}
    ...    Log    All GSM cells are operational!    level=INFO
    ...    console=True
    Run Keyword If    ${GSM_cell_ids}    Run Keyword If    not ${GSM_cells_operational}
    ...    Log    At least one GSM cell is not operational!    level=INFO
    ...    console=True
    ${BTS_cells_operational}=    Set Variable If
    ...  ${NRBTS_cells_operational} and ${LTE_cells_operational} and ${WCDMA_cells_operational} and ${GSM_cells_operational}
    ...   ${TRUE}    ${FALSE}
    [Return]    ${BTS_cells_operational}

Check All RMODs State SyVe
    [Documentation]    Helper keyword checking states of all BTS RMODs: operationalState=Enabled, availabilityStatus=Online
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | BTS_rmods_operational | True or False |
    ${BTS_rmods_operational}=    Run Keyword If    ${BTS_rmod_ids}    Run Keyword And Return Status
    ...    coam.Assert Every    RMOD    ${RMOD_expected_state}
    [Return]    ${BTS_rmods_operational}

Get Active Alarms From Netact
    [Arguments]    ${dist_name}=NoDistName
    [Documentation]    Keyword used for LTE active alarms capture from Netact
    ...    Returns a list of alarm dictionaries
    ...    *Author*
    ...    valentin.marian@nokia.com
    ${active_alarms}=    netact.Get Alarms    dist_name=${dist_name}
    ${structured_active_alarms}=    Create List
    FOR    ${alarm_dict}    IN    @{active_alarms}
        ${structured_alarm_dict}=    Restructure alarms dict    ${alarm_dict}
        Append to list    ${structured_active_alarms}    ${structured_alarm_dict}
    END
    [Return]    ${structured_active_alarms}

Restructure alarms dict
    [Arguments]    ${alarm_dict}
    [Documentation]    Restructures alarms dict like received from Netact, to match the hran_ta structure.
    ...    Returns an alarm contained in a dictionary with a different structure than the KW argument dictionary
    ...    *Author*
    ...    valentin.marian@nokia.com
    ...    *HISTORY*
    ...    2022.9.29  Modified for hran_ta merge to robotws.
    ...    To replace hran_alarms_analysis.Get Filtered Alarms by bin.7.liu@nokia.com
    ${alarm_dict_keys}=    Get Dictionary Keys    ${alarm_dict}
    ${simplified_alarm_dict_keys}=    Get Dictionary Keys    ${SIMPLIFIED_SYVE_ALARM}
    ${structured_alarm_dict}=    Create Dictionary
    ${alarmId}    Convert To Integer    ${alarm_dict['specificProblem'].__str__().strip()}
    Set to dictionary    ${structured_alarm_dict}    alarmId    ${alarmId}
    ${fault_id}    Fetch from left    ${alarm_dict['additionalText3'].__str__().strip()}    ${SPACE}
    ${has_faultId}    Run Keyword And Return Status    Should Match Regexp    ${fault_id.strip()}    ^\\d+$
    ${fault_id}    Run Keyword If    ${has_faultId}    Convert To Integer    ${fault_id.strip()}
    Set to dictionary    ${structured_alarm_dict}    faultId    ${fault_id}
    Set to dictionary    ${structured_alarm_dict}    severity    ${alarm_dict['perceivedSeverity'].__str__().strip()}
    Set to dictionary    ${structured_alarm_dict}    alarmName    ${alarm_dict['alarmText'].__str__().strip()}
    FOR    ${key}    IN    @{alarm_dict_keys}
        Run Keyword If    '${key}' in @{simplified_alarm_dict_keys}    Set to dictionary    ${structured_alarm_dict}
        ...    ${key}    ${alarm_dict['${key}'].__str__().strip()}
    END
    [Return]    ${structured_alarm_dict}

Get and Check Alarms SyVe
    [Arguments]    ${expected_alarms}=@{EMPTY}    ${unexpected_alarms}=@{EMPTY}    ${ignored_alarms}=@{EMPTY}
    ...    ${critical_alarms}=@{EMPTY}    ${timeout}=30 sec    ${dist_name}=None    ${source}=Bts
    [Documentation]    KW used to get and check LTE critical, expected or unexpected alarms.
    ...    It fails if any of below exception case is present:
    ...    - critical alarms are present
    ...    - not all expected alarms are present
    ...    - unexpected alarms are present
    ...    Report errors/warnings for failed cases or report that alarm status is ok.
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com / emanuel.szijj@nokia.com (SOAM) / valentin.marian@nokia.com (SYVE)
    ...    *HISTORY*
    ...    2022.9.29  Modified for hran_ta merge to robotws.
    ...    To replace hran_alarms_analysis.Get Filtered Alarms by bin.7.liu@nokia.com
    ...
    ...    | Parameter | Man. | Description |
    ...    | expected_alarms | No | Alarms which need to be present.Error raised if any of these is missing |
    ...    | ignored_alarms | No | Alarms which can be ignored if present |
    ...    | critical_alarms | No | Alarms which must not be present.Error raised if any of these is found |
    ...    | timeout | No | Time to wait for possitive query result |
    ...    | source | No | Netact / Bts source where the alarms are read from |
    ...    | dist_name | No | Distinguished name of object on which the alarms are raised |
    ...
    ...    *EXAMPLE*
    ...    Get and Check Alarms SyVe | Master | 10 min | 10 sec | 2 min | expected_alarms=${EXPECTED_NETACT_ALARMS} |
    ...    ignored_alarms=${IGNORED_NETACT_ALARMS} | critical_alarms=${CRITICAL_NETACT_ALARMS} | source=Bts |
    ...    dist_name=PLMN-PLMN/MRBTS-512
    [Timeout]    30 min
    Set Test Variable    ${detected critical alarms}    ${FALSE}
    ${SIMPLIFIED_SYVE_ALARM}   Set Variable If   '${source}'=='Netact'  ${SIMPLIFIED_NETACT_ALARM}  ${SIMPLIFIED_BTS_ALARM}
    Set Test Variable    ${SIMPLIFIED_SYVE_ALARM}
    Run Keyword If    '${source}'=='Netact'    Run Keyword And Return Status    netact.Upload alarms    ${dist_name}
    Eval Current Alarms SyVe    expected_alarms=${expected_alarms}    unexpected_alarms=${unexpected_alarms}
    ...    ignored_alarms=${ignored_alarms}   critical_alarms=${critical_alarms}  timeout=${timeout}  dist_name=${dist_name}
    ...    source=${source}

Eval Current Alarms SyVe
    [Arguments]    ${expected_alarms}=@{EMPTY}    ${unexpected_alarms}=@{EMPTY}    ${ignored_alarms}=@{EMPTY}
    ...    ${critical_alarms}=@{EMPTY}    ${timeout}=30 sec    ${source}=Bts
    ...    ${dist_name}=None
    [Documentation]    KW used to get and check critical or expected alarms.
    ...    It fails if any of below exception case is present:
    ...    - critical alarms are present
    ...    - not all expected alarms are present
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com / emanuel.szijj@nokia.com (SOAM) / valentin.marian@nokia.com (SyVe)
    ...    *HISTORY*
    ...    2022.9.29  Modified for hran_ta merge to robotws.
    ...    To replace hran_alarms_analysis.Get Filtered Alarms by bin.7.liu@nokia.com
    ...
    ...    | Parameter | Man. | Description |
    ...    | expected_alarms | No | Alarms which need to be present.Error raised if any of these is missing |
    ...    | ignored_alarms | No | Alarms which can be ignored if present |
    ...    | critical_alarms | No | Alarms which must not be present.Error raised if any of these is found |
    ...    | timeout | No | Time to wait for possitive query result |
    ...    | source | No | Netact / Bts source where the alarms are read from |
    ...    | dist_name | No | Distinguished name of object on which the alarms are raised |
    ...
    ...    *EXAMPLE*
    ...    Eval Current Alarms SyVe | Master | expected_alarms=${EXPECTED_NETACT_ALARMS} |
    ...    ignored_alarms=${IGNORED_NETACT_ALARMS} |
    ...    critical_alarms=${CRITICAL_NETACT_ALARMS} | source=Bts | dist_name=PLMN-PLMN/MRBTS-512
    ${alarm_retrieval_kw}=    Set Variable If    '${source}'=='Netact'    Get Active Alarms From Netact    coam.Get Active Alarms
    ${argument_dict_bts}=    Create Dictionary    timeout=${timeout}    alias=default
    ${argument_dict_netact}=    Create Dictionary    dist_name=${dist_name}
    ${argument_dict}=    Set Variable If    '${source}'=='Netact'    ${argument_dict_netact}    ${argument_dict_bts}
    ${active_alarms}=    Run Keyword    ${alarm_retrieval_kw}    &{argument_dict}
    Check Alarms    ${active_alarms}   ${expected_alarms}   ${unexpected_alarms}   ${ignored_alarms}   ${critical_alarms}

Final Checks SyVe
    [Arguments]    ${wait_timer}=5 min    ${BTS_scf}=${BTS_scf_initial}
    [Documentation]    Helper keyword checking if any errors ocurred during BTS Checks SyVe
    ...    If errors occured, snapshot will be taken and test will be passed with restriction
    ...    The inside KW BTS Checks Syve can be customized with BTS SCF full path: if this argument is not given, it will
    ...    have the initial BTS SCF downloaded in PREConditions
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com, emanuel.szijj@nokia.com
    ${errors}=    Get Variable Value    ${error_message_count}    0
    Wait Until Keyword Succeeds    ${wait_timer}    10 sec    BTS Checks SyVe    ${BTS_scf}
    ${errors_after}=    Get Variable Value    ${error_message_count}    0
    ${errors_final}=    Evaluate    ${errors_after} - ${errors}
    Run Keyword If    ${errors_final} > 0    Log    Snapshot will be taken due to ERRORs during BTS final checks!
    ...    level=WARN

BTS Checks SyVe
    [Arguments]    ${BTS_scf}
    [Documentation]    Helper keyword providing information related to following final checks:
    ...    - Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    - Check operational states for cells and radio modules
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *HISTORY*
    ...    Invoke kw:Get WebEM Runtime Cells And RMODs Number again to get runtime cell number and cell ids.
     ...   \ \ yuyan.xu@nokia-sbell.com
    ${NRBTS_runtime_cell_number}    ${LTE_runtime_cell_number}    ${LTE_IOT_runtime_cell_number}
    ...    ${WCDMA_runtime_cell_number}    ${GSM_runtime_cell_number}    ${BTS_runtime_rmod_number}
    ...    Get WebEM Runtime Cells And RMODs Number
    Set Test Variable    ${NRBTS_runtime_cell_number}
    Set Test Variable    ${LTE_runtime_cell_number}
    Set Test Variable    ${LTE_IOT_runtime_cell_number}
    Set Test Variable    ${WCDMA_runtime_cell_number}
    Set Test Variable    ${GSM_runtime_cell_number}
    Set Test Variable    ${BTS_runtime_rmod_number}
    ${PostconditionBTSConf}=    Check BTS Configuration SyVe    ${BTS_scf}
    Run Keyword If    ${PostconditionBTSConf}
    ...    Log    BTS SCF configured cells and radio modules number are in line with WebEM running view number!
    ...    level=INFO    console=True
    ...    ELSE    Run Keywords
    ...    Log    BTS SCF configured cells and radio modules number are in not line with WebEM running view number!
    ...    level=ERROR
    ...    AND    Fail    BTS SCF configured cells and radio modules number are not in line with WebEM running view number!
    ${PostconditionCellsOnAir}=    Check All Cells State SyVe
    Run Keyword If    ${PostconditionCellsOnAir}    Log    All BTS cells are operational!    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    At least one BTS cell is not operational!    level=ERROR
    ...    AND    Fail    At least one BTS cell is not operational!
    ${PostconditionModulesWorking}=    Check All RMODs State SyVe
    Run keyword If    ${PostconditionModulesWorking}    Log    All BTS radio modules are operational!    level=INFO
    ...    console=True
    ...    ELSE    Log    At least one BTS radio module is not operational!    level=WARN

Check BTS RAT Procedural State
    [Documentation]    Helper keyword checking BTS each RAT Procedural State based on cells state:
    ...    at least one cell should be with
    ...    operationalState=Enabled, availabilityStatus=Online
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *HISTORY*
    ...    add NRBTS rat yuyan.xu@nokia-sbell.com
    ${NRBTS_cells_operational}=    Run Keyword If    ${NRBTS_cell_ids}    Run Keyword And Return Status
    ...    coam.Assert Any    NRCEL    ${cells_NR_expected_state}
    ${LTE_cells_operational}=    Run Keyword If    ${LTE_cell_ids}    Run Keyword And Return Status
    ...    coam.Assert Any    LNCEL    ${cells_LTE_expected_state}
    ${WCDMA_cells_operational}=    Run Keyword If    ${WCDMA_cell_ids}    Run Keyword And Return Status
    ...    coam.Assert Any    WNCEL    ${cells_WCDMA_expected_state}
    ${GSM_cells_operational}=    Run Keyword If    ${GSM_cell_ids}    Run Keyword And Return Status
    ...    coam.Assert Any    GNCEL    ${cells_GSM_expected_state}
    Run Keyword If    ${NRBTS_cell_ids}    Run Keyword If    ${NRBTS_cells_operational}
    ...    Log    NRBTS RAT - ProceduralState: OnAir    level=INFO
    ...    console=True
    Run Keyword If    ${NRBTS_cell_ids}    Run Keyword If    not ${NRBTS_cells_operational}    Run Keywords
    ...    Log    All NRBTS cells are not operational!
    ...    level=ERROR
    ...    AND    Fail    All NRBTS cells are not operational!
    Run Keyword If    ${LTE_cell_ids}    Run Keyword If    ${LTE_cells_operational}
    ...    Log    LTE RAT - ProceduralState: OnAir    level=INFO
    ...    console=True
    Run Keyword If    ${LTE_cell_ids}    Run Keyword If    not ${LTE_cells_operational}    Run Keywords
    ...    Log    All LTE cells are not operational!
    ...    level=ERROR
    ...    AND    Fail    All LTE cells are not operational!
    Run Keyword If    ${WCDMA_cell_ids}    Run Keyword If    ${WCDMA_cells_operational}
    ...    Log    WCDMA RAT - ProceduralState: OnAir    level=INFO
    ...    console=True
    Run Keyword If    ${WCDMA_cell_ids}    Run Keyword If    not ${WCDMA_cells_operational}    Run Keywords
    ...    Log    All WCDMA cells are not operational!
    ...    level=ERROR
    ...    AND    Fail    All WCDMA cells are not operational!
    Run Keyword If    ${GSM_cell_ids}    Run Keyword If    ${GSM_cells_operational}
    ...    Log    GSM RAT - ProceduralState: OnAir    level=INFO
    ...    console=True
    Run Keyword If    ${GSM_cell_ids}    Run Keyword If    not ${GSM_cells_operational}    Run Keywords
    ...    Log    All GSM cells are not operational!
    ...    level=ERROR
    ...    AND    Fail    All GSM cells are not operational!

Check ${techno} RAT Procedural State
    [Documentation]    Helper keyword checking ${techno} RAT Procedural State based on cells state:
    ...    at least one cell should be with
    ...    operationalState=Enabled, availabilityStatus=Online
    ...    ${techno} can be LTE, WCDMA or GSM
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ${cells_operational}=    Run Keyword If    ${${techno}_cell_ids}    Run Keyword And Return Status
    ...    coam.Assert Any    ${techno[0]}NCEL    ${cells_${techno}_expected_state}
    Run Keyword If    ${${techno}_cell_ids}    Should Be True    ${cells_operational}

Check if all BTS cells are unblocked from WebEM
    [Documentation]    Helper keyword checking all BTS cells blocking state info. If needed perform unblock BTS cell.
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    Run Keyword If    ${LTE_cell_ids}    Unblock all BTS LTE cells
    Run Keyword If    ${WCDMA_cell_ids}    Unblock all BTS WCDMA cells
    Run Keyword If    ${GSM_cell_ids}    Unblock all BTS GSM cells

Unblock all BTS ${techno} cells
    FOR    ${item}    IN    @{${techno}_cell_ids}
        ${cell_param}=    coam.Get Parameters For    ${techno[0]}NCEL    ${item}
        Run Keyword If    '${cell_param['blockingState']}' == 'Blocked'    Run Keywords    coam.Unblock    ${item}
        ...    AND    Sleep    30s    Wait for Cell ${item[0]} establish
        ...    AND    Log    Cell ${item} unblock indicated    console=True
    END

NetAct Create And Edit Plan
    [Arguments]    ${name}    ${description}    ${mo_id}    ${scf_distName}    &{parameters_dict}
    [Documentation]    Helper keyword used for create new plan and parameter edit
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | name | Yes | Plan Name |
    ...    | description | Yes | Plan description |
    ...    | mo_id | Yes | MO distName |
    ...    | scf_distName | Yes | SCF distName of MO for given parameter |
    ...    | parameters_dict | Yes | parameters_dict (dictionary format - key:value) |
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}=    NetAct Create Plan    ${name}    ${description}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${scf_distName}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${mo_id}    &{parameters_dict}
    [Return]    ${plan}

NetAct Create Plan And Objects
    [Arguments]    ${name}    ${description}    ${mo_id}
    [Documentation]    Helper keyword used for create new plan and parameter edit
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | name | Yes | Plan Name |
    ...    | description | Yes | Plan description |
    ...    | mo_id | Yes | MO distName |
    ...    | scf_distName | Yes | SCF distName of MO for given parameter |
    ...    | parameters_dict | Yes | parameters_dict (dictionary format - key:value) |
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}=    NetAct Create Plan    ${name}    ${description}
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${mo_id}    &{parameters_dict}
    [Return]    ${plan}

NetAct Create Plan
    [Arguments]    ${name}    ${description}
    ${plan}=    netact.Create Plan Configuration    ${name}    ${description}
    ${status}=    Run Keyword And Return Status    netact.Get Plan Configuration    ${name}
    Run Keyword If    ${status}    Log    Plan successfully created: ${plan}    console=True
    ...    ELSE    Run Keywords    Log    Plan creation failed!    level=ERROR
    ...    AND    Fail    Plan creation failed!
    [Return]    ${plan}

NetAct Create Managed Object-obsolete
    [Arguments]    ${plan}    ${meta_class}    ${meta_version}    ${mo_id}    ${operation}=UPDATE    &{parameters_dict}
    ${managed_object}=    netact.Create Managed Object    plan=${plan}    meta_class=${meta_class}
    ...    meta_version=${meta_version}    mo_id=${mo_id}    operation=${operation}   &{parameters_dict}
    ${status}=    Run Keyword And Return Status    netact.Get Managed Object    configuration=${plan}    mo_id=${mo_id}
    Run Keyword If    ${status}    Run Keywords    Log    MO successfully created: ${managed_object}    console=True
    ...    AND    Log    Parameters were set with plan ${plan}    console=True
    ...    ELSE    Run Keywords    Log    MO creation failed!    level=ERROR
    ...    AND    Fail    MO creation failed!

NetAct Create Managed Object
    [Arguments]    ${plan}    ${meta_class}    ${meta_version}    ${mo_id}    ${operation}=UPDATE    &{parameters_dict}
    [Documentation]    Create mo which not existed in plan, or edit/delete mo which existed in plan.
    ...    Author: yuyan xu
    ${status}    ${managed_object_get}    Run Keyword And Ignore Error    netact.Get Managed Object    configuration=${plan}    mo_id=${mo_id}
    ${managed_object_create}     Run Keyword If    "${status}"!="PASS"    netact.Create Managed Object    plan=${plan}
    ...    meta_class=${meta_class}    meta_version=${meta_version}    mo_id=${mo_id}    operation=${operation}   &{parameters_dict}
    Run Keyword If    "${status}"=="PASS"    netact.Edit Managed Object    ${managed_object_get}     ${operation}    &{parameters_dict}
    ${status}=    Run Keyword And Return Status    netact.Get Managed Object    configuration=${plan}    mo_id=${mo_id}
    Run Keyword If    ${status}    Run Keywords    Log    MO successfully created or edit: ${mo_id}    console=True
    ...    AND    Log    Parameters were set with plan ${plan}    console=True
    ...    ELSE    Run Keywords    Log    MO creation failed!    level=ERROR
    ...    AND    Fail    MO creation failed!

NetAct Delete Plan
    [Arguments]    ${name}    ${plan}
    netact.Delete Plan    ${name}
    ${status}=    Run Keyword And Return Status    netact.Get Plan Configuration    ${name}
    Run Keyword If    ${status}    Run Keywords    Log    Plan deletion failed!    level=ERROR
    ...    AND    Fail    Plan deletion failed!
    ...    ELSE    Log    Plan successfully deleted: ${plan}    console=True

NetAct Check Actual Configuration Parameters
    [Arguments]    ${dist_name}    ${ui_values}=false    &{parameter_dict}
    ${status}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${dist_name}
    ...    ui_values=${ui_values}    &{parameter_dict}
    Run Keyword If    ${status}
    ...    Log    For ${dist_name}, parameters config has expected values in actual configuration!    console=True
    ...    ELSE    Run Keywords
    ...    Log    For ${dist_name}, parameters config has not expected values in actual configuration!    level=ERROR
    ...    AND    Fail    For ${dist_name}, parameters config has not expected values in actual configuration!

NetAct Export Plan
    [Arguments]    ${local_dir}    ${file_name}    ${dist_names}    ${plan_name}    ${operation_type}=plan    ${ui_values}=None
    [Documentation]    Helper keyword used for export plan from NetAct to local_dir/file_name place
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | local_dir | Yes | Path to local directory where NetAct plan should be stored |
    ...    | file_name | Yes | File name for local stored plan |
    ...    | dist_names | Yes | MO distName |
    ...    | plan_name | Yes | Name of plan on NetAct |
    ...    | operation_type | No|Specifies the type of the export operation (plan/actual/reference/template/siteTemplate|
    ...    | ui_values | No | Specifies if the file should be exported with UI parameters' values. Default value is false. |
    ${status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${local_dir}
    Run Keyword If    not ${status}    Create Directory    ${local_dir}
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${local_dir}
    ...    file_name=${file_name}    operation_type=${operation_type}    dist_names=${dist_names}
    ...    plan_name=${plan_name}    ui_values=${ui_values}
    ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    Run Keyword If    ${status}    Log    Plan ${plan_name} available at ${local_dir}/${file_name}    level=INFO
    ...    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} not available at ${local_dir}/${file_name}    level=ERROR
    ...    AND    Fail    Plan ${plan_name} not available at ${local_dir}/${file_name}

NetAct Import Plan
    [Arguments]    ${local_dir}    ${file_name}    ${plan_name}    ${ui_values}=false
    [Documentation]    Helper keyword used for Import plan to NetAct from local_dir/file_name place
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | local_dir | Yes | Path to local directory where NetAct plan should be stored |
    ...    | file_name | Yes | File name for local stored plan |
    ...    | plan_name | Yes | Name of plan on NetAct |
    ...    | ui_values | No | Whether need import with ui values |
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${plan_name}    ${plan}
    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    ${status}=    Run Keyword And Return Status    netact.Import Configuration    local_dir=${local_dir}
    ...    file_name=${file_name}    plan_name=${plan_name}    ui_values=${ui_values}
    Run Keyword If    ${status}    Log    Plan ${plan_name} at ${local_dir}/${file_name} import success.    level=INFO
    ...    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} at ${local_dir}/${file_name} is fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} at ${local_dir}/${file_name} is fail.

NetAct CM Upload
    [Arguments]    ${dist_names}
    ${status}=    Run Keyword And Return Status    netact.Upload Configuration    dist_names=${dist_names}
    Run Keyword If    ${status}    Log    CM Upload operation succesfully finished for ${dist_names}    console=True
    ...    ELSE    Run Keywords    Log    CM Upload operation failed for ${dist_names}    level=ERROR
    ...    AND    Fail    CM Upload operation failed for ${dist_names}

NetAct Provision Plan
    [Arguments]    ${plan_name}    ${dist_names}    ${backup_plan_name}    ${create_backup_plan}
    ...    ${provisioning_operation}    ${ignore_errors}=False
    [Documentation]    Helper keyword used for provision plan
    ...
    ...    *AUTHOR*
    ...    ana.tugui@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | name | Yes | Plan Name |
    ...    | dist_names | Yes | MO distName |
    ...    | backup_plan_name | Yes | Backup plan name |
    ...    | create_backup_plan | Yes | Create backup plan; True or False |
    ...    | provisioning_operation| Yes | Specifies a provisioning operation (activate/preactivate) |
    log    ${backup_plan_name}    console=True
    ${status}=    Run Keyword And Return Status    netact.Provision Plan    plan_name=${plan_name}    dist_names=${dist_names}
    ...    backup_plan_name=${backup_plan_name}    create_backup_plan=${create_backup_plan}
    ...    provisioning_operation=${provisioning_operation}    ignore_errors=${ignore_errors}
    Run Keyword If    ${status}    Log    Provision plan ${plan_name} successfully done!    console=True
    ...    ELSE    Run Keywords    Log    Provision plan ${plan_name} failed!    level=ERROR
    ...    AND    Fail    Provision plan ${plan_name} failed!

Check If Netact Plan Is Deleted
    [Arguments]    ${plan_name}
    [Documentation]    Helper keyword for checking if netact plan is deleted.
    ...    If needed perform delete plan.
    ...
    ...    *AUTHOR*
    ...    ana.tugui@nokia.com
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    netact.Delete Plan    ${plan_name}

Check WebEM After Modify Parameters
    [Arguments]    ${scf_distName}    ${export_type}=${NONE}    &{parameters_dict}
    [Documentation]    Helper keyword used for check webEM after modify parameters
    ...
    ...    *AUTHOR*
    ...    ana.tugui@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | scf_distName | Yes | SCF distName of MO for given parameter |
    ...    | parameters_dict | Yes | parameters_dict(dictionary format - key:value) e.q. see netact_plan.yaml file |
    ${BTS_scf}=    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}    export_type=${export_type}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf}
    ${result_value}=    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${scf_distName}"]/p
    ${result_value_dict}=    Create dictionary
    FOR    ${item}    IN    @{result_value}
        ${key}=    L_XML.Get Element Attribute    ${item}    name
        ${value}=    L_XML.Get Element Text    ${item}
        Set To Dictionary    ${result_value_dict}    ${key}=${value}
    END
    Dictionary Should Contain Sub Dictionary    ${result_value_dict}    ${parameters_dict}

NetAct Alarm Upload
    [Arguments]    ${dist_name}
    ${status}=    Run Keyword And Return Status    netact.Upload Alarms    dist_name=${dist_name}
    Run Keyword If    ${status}    Log    Alarm Upload operation succesfully finished for ${dist_name}    console=True
    ...    ELSE    Run Keywords    Log    Alarm Upload operation failed for ${dist_name}    level=ERROR
    ...    AND    Fail    Alarm Upload operation failed for ${dist_name}

NetAct Import Build
    [Arguments]    ${SW_name}    ${SW_load}    ${SW_dir_path}    ${mo_type}=MRBTS
    ${SW_exist}=    ta_netact_swm_importer.Is Imported    version_id=${SW_name}    mo_type=${mo_type}
    Run Keyword If    ${SW_exist}    Run Keywords    Log    SW load ${SW_name} already available on NetAct   console=True
    ...    AND    Return From Keyword
    ${status}=    Run Keyword And Return Status    ta_netact_swm_importer.Import Build
    ...    file_path=${SW_dir_path}/${SW_load}    mo_type=${mo_type}
    Run Keyword If    ${status}    Log    Import Build ${SW_name} operation succesfully finished    console=True
    ...    ELSE    Run Keywords    Log    Import Build ${SW_name} operation failed    level=ERROR
    ...    AND    Fail    Import Build ${SW_name} operation failed
    ${SW_exist}=    ta_netact_swm_importer.Is Imported    version_id=${SW_name}    mo_type=${mo_type}
    Run Keyword If    ${SW_exist}    Log    SW load ${SW_name} available on NetAct    console=True
    Set Test Variable    ${SW_NetAct_import}    ${TRUE}

NetAct SW Upload
    [Arguments]    ${mo_name}
    [Documentation]    Helper keyword used for SW Upload
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | mo_name | Yes | MO distName |
    ${status}=    Run Keyword And Return Status    ta_netact_swm_operations.Swm Upload    mo_name=${mo_name}
    Run Keyword If    ${status}    Log    SW Upload successfully finished for ${mo_name}    console=True
    ...    ELSE    Run Keywords    Log    SW Upload failed!    level=ERROR
    ...    AND    Fail    SW Upload failed!

NetAct SW Provision
    [Arguments]    ${mo_name}    ${package_name}
    [Documentation]    Helper keyword used for SW provision
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | mo_name | Yes | MO distName |
    ...    | package_name | Yes | SW load name |
    ${status}=    Run Keyword And Return Status    ta_netact_swm_operations.Swm Provision    mo_name=${mo_name}
    ...    package_name=${package_name}
    Run Keyword If    ${status}    Log    SW Provision ${package_name} successfully finished for ${mo_name}   console=True
    ...    ELSE    Run Keywords    Log    SW Provision ${package_name} failed!    level=ERROR
    ...    AND    Fail    SW Provision ${package_name} failed!

NetAct SW Rollback
    [Arguments]    ${mo_name}
    [Documentation]    Helper keyword used for SW rollback
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | mo_name | Yes | MO distName |
    ${status}=    Run Keyword And Return Status    ta_netact_swm_operations.Swm Rollback    mo_name=${mo_name}
    Run Keyword If    ${status}    Log    SW Rollback successfully finished for ${mo_name}    console=True
    ...    ELSE    Run Keywords    Log    SW Rollback failed!    level=ERROR
    ...    AND    Fail    SW Rollback failed!

Get BTS RESET info from blackbox file SyVe
    [Arguments]    ${when}    ${target_ip}
    [Documentation]    Get RESET timestamp and reason info from blackbox file
    [Timeout]    5 min
#    ${reset_counter}    ${reset_reason}=    Get Reset Reason Info SyVe    target_ip=${target_ip}
    ${reset_reason}=    Get Reset Reason Info SyVe    target_ip=${target_ip}
    Set Test Variable    ${reset_reason_${when}}    ${reset_reason}
#    Set Test Variable    ${reset_counter_${when}}    ${reset_counter}    #comment for counter number check in file
    Log    BTS RESET timestamp and reason: ${reset_reason_${when}}[-1]    console=True

Get Reset Reason Info SyVe
    [Arguments]    ${target_ip}
    [Documentation]    *AUTHOR* dinu.olariu@nokia.com
    ...
    ...    *RETURN VALUE*
    ...    | reset_reason_info | list of all reset reasons from blackbox file |
    [Timeout]    5 min
    ${blackbox_path_file}=    Get Blackbox From BTS By FTP SyVe    target_ip=${target_ip}
#    ${reset_counter}    ${reset_reason_info}=    Get Reset Info From File    ${blackbox_path_file}
    ${reset_reason_info}=    Get Reset Info From File    ${blackbox_path_file}
#    [Return]    ${reset_counter}    ${reset_reason_info}
    [Return]    ${reset_reason_info}

Get Blackbox From BTS By FTP SyVe
    [Arguments]    ${target_ip}    ${source_path}=/rom/logs/lifetimedata/blackbox_reset    ${destination_path}=${BTSFiles}
    [Documentation]    *AUTHOR* dinu.olariu@nokia.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | target_ip | Yes | BTS Ip address |
    ...    | source_path | No | Blackbox full path on BTS (from the file is transferred) |
    ...    | destination_path | No | Blackbox full path on VM (where the file is transferred) |
    ...
    ...    *RETURN VALUE*
    ...    | blackbox_path_file | Blackbox full path on VM (where the file is available as ${timestamp}_blackbox) |
    [Timeout]    5 min
    ${timestamp}    Get Current Date    result_format=%Y-%m-%d_%H-%M-%S
    ${status}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${destination_path}
    Run Keyword If    not ${status}    Create Directory    ${destination_path}
    Set Test Variable    ${blackbox_file}    ${timestamp}_blackbox
    ${blackbox_path_file}    Join Path    ${destination_path}    ${blackbox_file}
    Get File From System Module    target_ip=${target_ip}    source_path=${source_path}
    ...    destination_path=${blackbox_path_file}
    ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${blackbox_path_file}
    Run Keyword If    ${status}    Log    BTS Blackbox file ${blackbox_file} available at ${destination_path}
    ...    console=True
    ...    ELSE    Run Keywords    Log    BTS Blackbox file ${blackbox_file} not available at ${destination_path}
    ...    level=ERROR
    ...    AND    Fail    BTS Blackbox file ${blackbox_file} not available at ${destination_path}
    [Return]    ${blackbox_path_file}

Check BTS RESET behavior SyVe
    [Arguments]    ${expected_reset_number}
    [Timeout]    10 min
    ${blackbox_reset_verdict}    Run Keyword And Return Status    Check Blackbox reset behavior
    ...    ${reset_reason_initial}    ${reset_reason_final}    ${expected_reset_number}
    #comment for counter number check in file
#    ${reset_counter_initial}    Convert To Integer   ${reset_counter_initial}
#    ${reset_counter_final}    Convert To Integer   ${reset_counter_final}
#    ${diff}    Evaluate    ${reset_counter_final}-${reset_counter_initial}
#    Should Be Equal As Integers  ${blackbox_reset_number}    ${diff}
    Run Keyword If    ${blackbox_reset_verdict}
    ...   Log
    ...   BTS reset behavior as expected (expected/found reset number: ${expected_reset_number}/${blackbox_reset_number})!
    ...   console=True
    ...   ELSE    Run Keywords
    ...   Log
    ...   BTS reset behavior not as expected(expected/found reset number:${expected_reset_number}/${blackbox_reset_number})!
    ...   level=ERROR
    ...   AND    Fail
    ...   BTS reset behavior not as expected(expected/found reset number:${expected_reset_number}/${blackbox_reset_number})!

NetAct GUI Prepare Environment
    [Documentation]    Needed to be able to use RemoteSwingLibrary and SeleniumLibrary
    ...
    ...    *AUTHOR*
    ...    gabriel.stanculescu@nokia.com
    ${display_status}    ${display_value}=    OperatingSystem.Run And Return Rc And Output
    ...    ps -ef \| grep -o -E 'vnc*.+:[0-9]' \| awk -F':' {'print $2'}
    Run Keyword If    '${display_value}'==''    Run Keywords    Set Test Variable    ${display_number}    0
    ...    AND    Log    Display value not in expected range. Setting to ${display_number}    console=True
    ...    ELSE    Run Keywords    Set Test Variable    ${display_number}    ${display_value}
    ...    AND    Log    Display value is ${display_number}    console=True
    Set Environment Variable    DISPLAY    :${display_number}
    Start Process    sudo Xvfb :${display_number} -ac -screen 0 1680x1050x24    shell=yes

NetAct GUI Start Application
    [Arguments]    ${alias}    ${jnlp_file}    ${window_name}    ${timeout}=600
    [Documentation]    Keyword used to open specific jnlp sent as argument
    ...
    ...    *AUTHOR*
    ...    gabriel.stanculescu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | alias | Yes | Alias used to start specific application |
    ...    | jnlp_file | Yes | Full path to the jnlp file |
    ...    | window_name | No | Window name to select after starting application/can be a regexp |
    ...    | timeout | No | timeouut for the start application to be performed. Default value 600s |
    RemoteSwingLibrary.Start Application    ${alias}    javaws ${jnlp_file} -silent    ${timeout}
    ...    close_security_dialogs=True
    RemoteSwingLibrary.Set Jemmy Dispatch Model    ROBOT
    RemoteSwingLibrary.Set Jemmy Timeouts    10
    # WA for when application starts minimized
    ${window_name_clean}=    Replace String    ${window_name}    .*    ${EMPTY}
    ${matches_list}=    Get Regexp Matches    ${NETACT['web_url']}    ^\\w{7}
    ${len}=    Get Length    ${matches_list}
    ${netact_label}=    Set Variable If    ${len}==1    ${matches_list[0]}    ${None}
    Run Keyword If    '${netact_label}' != '${None}'    Log    NetAct label detected: ${netact_label}    console=True
    ...    ELSE    Log    Could not detect NetAct label in ${NETACT['web_url']}!    level=WARN
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    5min    30s
    ...    NetAct GUI Ensure application maximizes    window_name=${window_name_clean} - ${netact_label}
    Run Keyword If    ${status}    Log    Window succesfully maximized!    console=True
    ...    ELSE    Log    Window maximizing failed!    console=True
    RemoteSwingLibrary.Switch To Application    ${alias}
    Wait Until Keyword Succeeds    1min    2s    RemoteSwingLibrary.Select Window    regexp=${window_name}.*
    RemoteSwingLibrary.Select Window    regexp=${window_name}.*
    RemoteSwingLibrary.Close All Dialogs
    [Teardown]    Screenshot.Take Screenshot

NetAct GUI Ensure application maximizes
    [Arguments]    ${window_name}
    [Documentation]    Keyword used to ensure that NetAct GUI application properly starts maximized
    ...
    ...    *AUTHOR*
    ...    gabriel.stanculescu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | window_name | Yes | Keyword in the window title that ensures application has properly started |
    ${RC}=    OperatingSystem.Run And Return Rc    wmctrl -a "${window_name}"
    Run Keyword If    '${RC}' == '0'    Log    Window ${window_name} properly maximized!    console=True
    ...    ELSE    Fail    Could not maximize window ${window_name}!
    [Teardown]    Screenshot.Take Screenshot

NetAct GUI Go To Tree Node
    [Arguments]    ${tree_id}    ${path}    ${relative_path}=None
    [Documentation]    Keyword used to navigate to a specific tree node inside jnlp
    ...
    ...    *AUTHOR*
    ...    gabriel.stanculescu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | tree_id | Yes | Tree ID inside jnlp |
    ...    | path | Yes | Delta path from relative path to tree node needed. Nodes separated by "|" |
    ...    | relative_path | No | By default, starts from root node. Nodes must be separated by "|" |
    ${tree_nodes_list}=    Split String    ${path}    |
    ${tree_nodes_number}=    Get length    ${tree_nodes_list}
    Run Keyword If    '${tree_nodes_number}' == '0'    Fail    Could not find tree nodes in the provided path!
    ${tree_node_full_path}=    Set Variable    ${relative_path}
    FOR    ${index}    IN RANGE    0    ${tree_nodes_number}
        {tree_node_full_path}=    Run Keyword If    '${tree_node_full_path}' == 'None'
        ...    Set Variable    ${tree_nodes_list[${index}]}
        ...    ELSE    Catenate    SEPARATOR=|    ${tree_node_full_path}    ${tree_nodes_list[${index}]}
        Netact GUI Expand Tree Node    ${tree_id}    ${tree_node_full_path}
    END
    [Teardown]    Screenshot.Take Screenshot
    [Return]    ${tree_node_full_path}

NetAct GUI Expand Tree Node
    [Arguments]    ${tree_id}    ${node_path}
    [Documentation]    Keyword used to expand one single tree node inside jnlp
    ...
    ...    *AUTHOR*
    ...    gabriel.stanculescu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | tree_id | Yes | Tree ID inside jnlp |
    ...    | node_path | Yes | Complete path to tree node separated by "|" |
    Wait Until Keyword Succeeds    10s    2s    RemoteSwingLibrary.Tree Node Should Be Visible    ${tree_id}    ${node_path}
    Wait Until Keyword Succeeds    10s    2s    RemoteSwingLibrary.Click On Tree Node    ${tree_id}    ${node_path}
    Sleep    2s
    Wait Until Keyword Succeeds    10s    2s    RemoteSwingLibrary.Expand Tree Node    ${tree_id}    ${node_path}
    [Teardown]    Screenshot.Take Screenshot

NetAct GUI Tree Node Should Contain Child Nodes
    [Arguments]    ${tree_id}    ${parent_node_path}
    [Documentation]    Helper Keyword used check if a specific tree node contains child nodes
    ...
    ...    *AUTHOR*
    ...    gabriel.stanculescu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | tree_id | Yes | Tree ID inside jnlp |
    ...    | parent_node_path | Yes | Complete path to parent tree node separated by "|" |
    ${tree_node_childs}=    RemoteSwingLibrary.Get Tree Node Child Names    ${tree_id}    ${parent_node_path}
    Should Not Be Empty    ${tree_node_childs}
    [Return]    ${tree_node_childs}

NetAct GUI Perform Tree Node Popup Menu Operation
    [Arguments]    ${tree_id}   ${node_path}   ${operation}   ${confirmation_dialog}=None   ${confirmation_btn_name}=None
    [Documentation]    Keyword used to perform a specific operation from popup menu of a tree node.
    ...    If multiple selections needed from the menu
    ...    they will be sent separated by |
    ...
    ...    *AUTHOR*
    ...    gabriel.stanculescu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | tree_id | Yes | Tree ID inside jnlp |
    ...    | node_path | Yes | Complete path to tree node separated by "|" |
    ...    | operation | Yes | What to select from the popup menu |
    ...    | confirmation_dialog | No | Name of confirmation dialog to pop up |
    ...    | confirmation_btn_name | No | Name of confirmation button to be pressed |
    RemoteSwingLibrary.Click On Tree Node    ${tree_id}    ${node_path}
    Wait Until Keyword Succeeds    1min    2s    RemoteSwingLibrary.Select From Tree Node Popup Menu    ${tree_id}
    ...    ${node_path}    ${operation}
    Screenshot.Take Screenshot
    Run Keyword If    '${confirmation_dialog}' == 'None'    Return From Keyword
    ${dlg}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    10s    2s
    ...    RemoteSwingLibrary.Dialog Should Be Open    ${confirmation_dialog}
    Run Keyword If    ${dlg}    Run Keywords    RemoteSwingLibrary.Select Dialog    ${confirmation_dialog}
    ...    AND    Screenshot.Take Screenshot
    ...    AND    RemoteSwingLibrary.Push Button    ${confirmation_btn_name}
    [Teardown]    Screenshot.Take Screenshot

NetAct GUI Close Application
    [Arguments]    ${alias}    ${timeout}=60
    [Documentation]    Keyword used to close specific jnlp application identified by alias
    ...
    ...    *AUTHOR*
    ...    gabriel.stanculescu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | alias | Yes | Alias used to start specific application |
    [Timeout]    1 minute 30 seconds
    RemoteSwingLibrary.Switch To Application    ${alias}
    RemoteSwingLibrary.Close All Dialogs
    RemoteSwingLibrary.Ensure application should close    ${timeout}    Select From Main Menu    File|Exit
    [Teardown]    Screenshot.Take Screenshot

NetAct Download JNLP file
    [Arguments]    ${start_page_url}   ${user}   ${pass}   ${application_name}   ${application_location}   ${jnlp_name}
    [Documentation]    Keyword donwloads jnlp-file of a Java application from NetAct start page
    ...
    ...    *AUTHOR*
    ...    gabriel.stanculescu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | start_page_url | Yes | Netact start page |
    ...    | user | Yes | user login for Netact start page |
    ...    | pass | Yes | password login for Netact start page |
    ...    | application_name | Yes | Which application to open. Example: CM Editor, Monitor |
    ...    | application_location | Yes | Where the application is stored relatively to the start page. |
    ...    Example: netact/public/jws/cm3apps/cmedit.jnlp
    ...    | jnlp_name | Yes | How to save the jnlp file locally: Example: cmpedit.jnlp |
    Log    Start ${jnlp_name} download    console=True
    Log    ${application_location}
    NetAct Select Or Open Start Page    ${start_page_url}    ${user}    ${pass}
    Set Test Variable    ${jnlp_location}    ${Test Results Dir}/NetActLogs/${jnlp_name}
    SeleniumLibrary.Click Image    ${application_name}
    Screenshot.Take Screenshot
    OperatingSystem.Move File    /home/ute/btsauto/${jnlp_name}    ${jnlp_location}
    OperatingSystem.File Should Exist    ${jnlp_location}
    ...    ${jnlp_name} download failed; not available in ${Test Results Dir}/NetActLogs!
    Log    End ${jnlp_name} download    console=True

NetAct Select Or Open Start Page
    [Arguments]    ${start_page_url}    ${user}    ${pass}
    [Documentation]    Keyword selects NetAct Start Page if it is open or opens it with given credentials.
    ...
    ...    *AUTHOR*
    ...    gabriel.stanculescu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | start_page_url | Yes | Netact start page |
    ...    | user | Yes | user login for Netact start page |
    ...    | pass | Yes | password login for Netact start page |
    NetAct Close Browser If Session Expired
    ${out_previous_kw}=    SeleniumLibrary.Register Keyword To Run On Failure    Nothing
    ${out_status}    ${out_result}=    Run Keyword And Ignore Error    SeleniumLibrary.Select Window
    SeleniumLibrary.Register Keyword To Run On Failure    ${out_previous_kw}
    ${out_browser_id}=    Run Keyword If    '${out_status}' != 'PASS'    NetAct Open Start Page    ${start_page_url}
    ...    ${user}    ${pass}
    ${out_window_title}=    SeleniumLibrary.Get Title
    Should Contain    ${out_window_title}    Start Page
    [Return]    ${out_browser_id}

NetAct Close Browser If Session Expired
    [Documentation]    Keyword Closes the current browser, if it is running and NetAct session is expired,
    ...    closed or there is a server error
    ...
    ...    *AUTHOR*
    ...    gabriel.stanculescu@nokia.com
    ${out_previous_kw}=    SeleniumLibrary.Register Keyword To Run On Failure    Nothing
    ${out_status}    ${out_result}=    Run Keyword And Ignore Error    SeleniumLibrary.Select Window
    SeleniumLibrary.Register Keyword To Run On Failure    ${out_previous_kw}
    Return From Keyword If    '${out_status}' != 'PASS'
    ${out_server_error_element_count}=    SeleniumLibrary.Get Element Count
    ...    xpath=//div[@style='visibility: visible;' and @id='session-server-error-overlay']
    ${out_session_expired_element_count}=    SeleniumLibrary.Get Element Count
    ...    xpath=//div[@style='visibility: visible;' and @id='session-expired-overlay']
    ${out_session_closed_element_count}=    SeleniumLibrary.Get Element Count
    ...    xpath=//div[@style='visibility: visible;' and @id='session-closed-overlay']
    ${out_session_problem_element_count}=    Evaluate
    ...    ${out_server_error_element_count} + ${out_session_expired_element_count} + ${out_session_closed_element_count}
    Run Keyword If    ${out_session_problem_element_count} > 0    SeleniumLibrary.Close Browser

NetAct Open Start Page
    [Arguments]    ${start_page_url}    ${user}    ${pass}
    [Documentation]    Keyword donwloads jnlp-file of a Java application from NetAct start page
    ...
    ...    *AUTHOR*
    ...    gabriel.stanculescu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | start_page_url | Yes | Netact start page |
    ...    | user | Yes | user login for Netact start page |
    ...    | pass | Yes | password login for Netact start page |
    ${out_status}=    set variable
    ${out_show_app_toggle}=    set variable    xpath=//span[span="Show applications by folder"]/span
    ${out_show_all_apps}=    set variable    xpath=//a[span="Show all applications"]/span
    ${out_browser_id}=    Browser Open Firefox    url=${start_page_url}
    FOR    ${out_index}    IN RANGE    3
        SeleniumLibrary.Wait Until Page Contains Element    login:loginButton    240
        SeleniumLibrary.Wait Until Element Is Visible    login:loginButton    240
        SeleniumLibrary.Wait Until Element Is Visible    login:username    240
        SeleniumLibrary.Wait Until Element Is Visible    login:password    240
        SeleniumLibrary.Maximize Browser Window
        Run Keyword And Ignore Error    SeleniumLibrary.Input Text    login:username    ${user}
        Run Keyword And Ignore Error    SeleniumLibrary.Input Text    login:password    ${pass}
        Run Keyword And Ignore Error    SeleniumLibrary.Element Should Be Visible    login:loginButton
        Run Keyword And Ignore Error    SeleniumLibrary.Element Should Be Enabled    login:loginButton
        Run Keyword And Ignore Error    SeleniumLibrary.Click Button    login:loginButton
        ${out_status}    ${out_result}=    Run Keyword And Ignore Error
        ...    Wait Until Keyword Succeeds    10    5    SeleniumLibrary.Page Should Not Contain
        ...    Login failed
        Run Keyword If    '${out_status}'!='PASS'    Fatal Error    Login to NetAct startpage failed! Terminating test run
        Run Keyword And Ignore Error    Wait Until Keyword Succeeds    15    3
        ...    SeleniumLibrary.Element Should Be Visible    login:legalPanelCloseButton
        Run Keyword And Ignore Error    SeleniumLibrary.Element Should Be Enabled    login:legalPanelCloseButton
        Run Keyword And Ignore Error    SeleniumLibrary.Click Button    login:legalPanelCloseButton
        ${out_status}    ${out_result}=    Run Keyword And Ignore Error
        ...    Wait Until Keyword Succeeds    10s    2s    SeleniumLibrary.Element Should Be Visible
        ...    ${out_show_app_toggle}    10 s
        Run Keyword If    '${out_status}'=='PASS'    Exit For Loop
    END
    Run Keyword If    '${out_status}'=='FAIL'    Fail    Cannot open NetAct ${start_page_url} start page!
    Log    Successfully logged in to NetAct Web Page ${start_page_url}!    console=yes
    Wait Until Keyword Succeeds    10s    2s    SeleniumLibrary.Element Should Be Visible    ${out_show_app_toggle}
    SeleniumLibrary.Click Element    ${out_show_app_toggle}
    Wait Until Keyword Succeeds    10s    2s    SeleniumLibrary.Element Should Be Visible    ${out_show_all_apps}
    SeleniumLibrary.Click Element    ${out_show_all_apps}
    [Teardown]    Screenshot.Take Screenshot
    [Return]    ${out_browser_id}

Browser Open Firefox
    [Arguments]    ${url}    ${geckodriver_path}=/home/ute/btsauto/drivers/gecko/geckodriver
    [Documentation]    Keyword used to open firefox using SeleniumLibrary
    ...
    ...    *AUTHOR*
    ...    gabriel.stanculescu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | url | Yes | WEB URL |
    ...    | geckodriver_path | No | Full path to the geckodriver executable |
    ${geckodriver_locations} =    Create list    geckodriver    /home/ute/btsauto/geckodriver    ${geckodriver_path}
    ${ff_binary}=    Evaluate
    ...    sys.modules['selenium.webdriver.firefox.firefox_binary'].FirefoxBinary(firefox_path='/usr/bin/firefox-esr')
    ...    sys, selenium.webdriver
    ${profile_directory}   Set Variable    profile_directory='${Test Results Dir}/NetActLogs'
    ${ff_profile}=    Evaluate
    ...    sys.modules['selenium.webdriver.firefox.firefox_profile'].FirefoxProfile(${profile_directory})
    ...    sys, selenium.webdriver
    ${ff_desired_caps}=    Evaluate
    ...    sys.modules['selenium.webdriver.common.desired_capabilities'].DesiredCapabilities().FIREFOX.copy()
    ...    sys, selenium.webdriver
    #Accept untrusted certs
    Call Method    ${ff_profile}    set_preference    accept_untrusted_certs    ${True}
    Call Method    ${ff_profile}    set_preference    security.tls.version.min    ${0}
    Call Method    ${ff_profile}    set_preference    security.tls.version.max    ${0}
    Call Method    ${ff_profile}    set_preference    security.ssl.version.min    ${0}
    Call Method    ${ff_profile}    set_preference    security.ssl.version.max    ${0}
    Call Method    ${ff_profile}    set_preference    security.ssl.enable_ocsp_stapling    ${False}
    #Disable auto update
    Call Method    ${ff_profile}    set_preference    app.update.auto    ${False}
    Call Method    ${ff_profile}    set_preference    app.update.backgroundErrors    ${2}
    Call Method    ${ff_profile}    set_preference    app.update.enabled    ${False}
    Call Method    ${ff_profile}    set_preference    dom.file.createInChild    ${True}
    #Download dir
    Call Method    ${ff_profile}    set_preference    browser.helperApps.alwaysAsk.force    ${False}
    Call Method    ${ff_profile}    set_preference    browser.download.manager.showWhenStarting    ${False}
    Call Method    ${ff_profile}    set_preference    browser.download.panel.shown    ${True}
    Call Method    ${ff_profile}    set_preference    browser.download.folderList    ${2}
    Call Method    ${ff_profile}    set_preference    browser.download.dir    /home/ute/btsauto
    ${preferenc1}    Set Variable    application/x-java-jnlp-file;application/csv;application/xml;text/xml;application/pdf;
    ${preferenc2}    Set Variable    application/vnd.ms-excel;application/zip;application/octet-stream;application/x-zip;
    ${preferenc3}    Set Variable    application/x-zip-compressed;application/x-download;multipart/x-zip;application/x-zip;
    ${preferenc4}    Set Variable
    ...  application/x-rar-compressed;application/zip-archive;application/x-compress;application/x-compressed;application/*
    Call Method    ${ff_profile}    set_preference    browser.helperApps.neverAsk.saveToDisk
    ...    ${preferenc1}${preferenc2}${preferenc3}${preferenc4}
    ${preferenc1}    Set Variable   application/x-java-jnlp-file;application/csv;application/xml;text/xml;application/pdf;
    ${preferenc2}    Set Variable
    ...   application/vnd.ms-excel;application/zip;application/octet-stream;application/x-zip;application/x-zip-compressed;
    ${preferenc3}    Set Variable
    ...    application/x-download;multipart/x-zip;application/x-zip;application/x-rar-compressed;application/zip-archive;
    ${preferenc4}    Set Variableapplication/x-compress;application/x-compressed;application/*
    Call Method    ${ff_profile}    set_preference    browser.helperApps.neverAsk.openFile
    ...    ${preferenc1}${preferenc2}${preferenc3}${preferenc4}
    Call Method    ${ff_profile}    set_preference    plugin.disable_full_page_plugin_for_types    application/pdf
    #Proxy
    Call Method    ${ff_profile}    set_preference    network.cookie.prefsMigrated    ${True}
    Call Method    ${ff_profile}    set_preference    network.proxy.autoconfig_url
    ...    http://proxyconf.glb.nsn-net.net/proxy.pac
    Call Method    ${ff_profile}    set_preference    network.proxy.type    ${0}
    Call Method    ${ff_profile}    update_preferences
    #Update caps
    Set To Dictionary    ${ff_desired_caps}    acceptInsecureCerts    True
    Set To Dictionary    ${ff_desired_caps}    marionette    True
    Set To Dictionary    ${ff_desired_caps}    firefox_profile    ${ff_profile.encoded}
    #Log user.js
    Run Keyword And Ignore Error    OperatingSystem.Log File    ${ff_profile.path}/user.js
    FOR    ${geckodriver_location}    IN    @{geckodriver_locations}
        ${result}    ${out_browser_id}=    Run Keyword and Ignore Error    SeleniumLibrary.Create Webdriver    Firefox
        ...    firefox_binary=${ff_binary}    capabilities=${ff_desired_caps}
        ...    service_log_path=${Test Results Dir}/NetActLogs/geckodriver.log    executable_path=${geckodriver_location}
        Exit For Loop If    '${result} '=='PASS '
    END
    Should Be True    '${result} '=='PASS '    msg=Create Webdriver Unsuccessful
    SeleniumLibrary.Go To    url=${url}
    [Return]    ${out_browser_id}

NetAct Close Monitor
    Sleep    1 sec
    Wait Until Keyword Succeeds    3x    3s    RemoteSwingLibrary.Switch To Application    Monitor
    Sleep    1 sec
    Wait Until Keyword Succeeds    3x    3s    RemoteSwingLibrary.Close All Dialogs
    Sleep    1 sec
    Wait Until Keyword Succeeds    3x    3s    RemoteSwingLibrary.Select From Main Menu    File|Exit
    Sleep    1 sec
    Wait Until Keyword Succeeds    3x    3s    RemoteSwingLibrary.Select Dialog    Save
    Sleep    1 sec
    Wait Until Keyword Succeeds    3x    3s    RemoteSwingLibrary.Ensure Application Should Close
    ...    ${APPLICATION_CLOSING_TIME}    pushButton    Discard All
    Sleep    1 sec
    [Teardown]    Screenshot.Take Screenshot

Get MO SW Version From NetAct GUI
    [Arguments]    ${MO_type}    ${MO_dn}
    [Documentation]    Helper KW for retrieving MO SW version from NetAct Start Page -> Software Manager -> Network Status
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | MO_type | Yes | MO type info |
    ...    | MO_dn | Yes | MO distinguished name info |
    NetAct GUI Prepare Environment
    ${window_title}=    NetAct Launch Application From Start Page    start_page_url=https://${NETACT['web_url']}
    ...    user=${NETACT['user']}    pass=${NETACT['password']}    application_name=Software Manager
    NetAct Select MO from Software Manager (Network Status)    MO_type=${MO_type}    MO_dn=${MO_dn}
    ${Active_SW_version}    ${Passive_SW_version}=    NetAct Software Manager Get MO Software Version
    [Teardown]    NetAct Close Application
    [Return]    ${Active_SW_version}    ${Passive_SW_version}

NetAct Launch Application From Start Page
    [Arguments]    ${start_page_url}    ${user}    ${pass}    ${application_name}
    [Documentation]    Helper KW for launching applications from NetAct Start Page
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | start_page_url | Yes | URL for Netact start page |
    ...    | user | Yes | user login for Netact Start Page |
    ...    | pass | Yes | password login for Netact Start Page |
    ...    | application_name | Yes | application name available in Netact Start Page |
    ${browser_id}=    NetAct Select Or Open Start Page    ${start_page_url}    ${user}    ${pass}
    Wait Until Keyword Succeeds    3x    1    Run Keywords    SeleniumLibrary.Click Image    ${application_name}
    ...    AND    Wait Until Keyword Succeeds    30    3    NetAct Select The Latest Opened Window    ${browser_id}
    ...    ${application_name}
    ${window_title}=    SeleniumLibrary.Get Title
    [Return]    ${window_title}

NetAct Select The Latest Opened Window
    [Arguments]    ${browser_id}    ${value}
    SeleniumLibrary.Switch Browser    ${browser_id}
    SeleniumLibrary.Select Window    locator=NEW
    ${selected_window_title}=    Wait Until Keyword Succeeds    10    2    NetAct Window Title Should Contain    ${value}
    SeleniumLibrary.Maximize Browser Window
    [Return]    ${selected_window_title}

NetAct Window Title Should Contain
    [Arguments]    ${expected_title}
    ${window_title}=    SeleniumLibrary.Get Title
    Should Contain    ${window_title}    ${expected_title}
    [Return]    ${window_title}

NetAct Select MO from Software Manager (Network Status)
    [Arguments]    ${MO_type}    ${MO_dn}
    [Documentation]    Helper KW for Software Manager -> Network Status objects selection
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    Sleep    2 sec
    ${Object_label}=    Set Variable    MO type
    ${Object_field}=    Set Variable    id=ccMOTypecomboboxField
    ${Object_value}=    Set Variable    ${MO_type}
    NetAct Software Manager Set Object Into Field    Object_label=${Object_label}    Object_field=${Object_field}
    ...    Object_value=${Object_value}
    Sleep    2 sec
    ${Object_label}=    Set Variable    View
    ${Object_field}=    Set Variable    id=TreeViewcomboboxField
    ${Object_value}=    Set Variable    Parent
    NetAct Software Manager Set Object Into Field    Object_label=${Object_label}    Object_field=${Object_field}
    ...    Object_value=${Object_value}
    Sleep    2 sec
    ${Object_label}=    Set Variable    PLMN-PLMN
    ${Object_checkbox}=    Set Variable    id=mot::PLMN-PLMN::c
    NetAct Software Manager Set Object Checkbox    Object_label=${Object_label}    Object_checkbox=${Object_checkbox}
    Sleep    2 sec
    ${Object_label}=    Set Variable    Select all MOs
    ${Object_checkbox}=    Set Variable
    ...    xpath=//div[@id="swmTable_networkView_header"]/table/thead/tr[2]/th[1]/span/div[1]/input
    NetAct Software Manager Set Object Checkbox    Object_label=${Object_label}    Object_checkbox=${Object_checkbox}
    Sleep    2 sec
    ${Object_label}=    Set Variable    MO DN
    ${Object_field}=    Set Variable    xpath=//div[@id="swmTable_networkView_header"]/table/thead/tr[2]/th[3]/div/input
    ${Object_value}=    Set Variable    ${MO_dn}
    NetAct Software Manager Set Object Into Field    Object_label=${Object_label}    Object_field=${Object_field}
    ...    Object_value=${Object_value}
    Sleep    2 sec

NetAct Software Manager Set Object Into Field
    [Arguments]    ${Object_label}    ${Object_field}    ${Object_value}
    [Documentation]    Helper KW for Software Manager -> Network Status objects selection
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | Object_label | Yes | Object label info |
    ...    | Object_field | Yes | Object field info |
    ...    | Object_value | Yes | Object value |
    Wait Until Keyword Succeeds    30    3    SeleniumLibrary.Element Should Be Visible    ${Object_field}
    ${status}=    Run Keyword And Return Status    SeleniumLibrary.Textfield Value Should Be    ${Object_field}
    ...    ${Object_value}
    Run Keyword If    ${status}    Run Keywords    Log    ${Object_label}: ${Object_value} already set into field
    ...    console=True
    ...    AND    Return From Keyword
    Run Keyword If    not ${status}    Wait Until Keyword Succeeds    3x    3    Run Keywords
    ...    SeleniumLibrary.Input Text    ${Object_field}    ${Object_value}
    ...    AND    NetAct Software Manager Press Enter    ${Object_field}
    ...    AND    Screenshot.Take Screenshot
    ${status}=    Run Keyword And Return Status    SeleniumLibrary.Textfield Value Should Be    ${Object_field}
    ...    ${Object_value}
    Run Keyword If    ${status}    Log    ${Object_label}: ${Object_value} properly set into field    console=True
    ...    ELSE    Run Keywords    Log    ${Object_value} failed set into field    level=ERROR
    ...    AND    Fail    ${Object_value} failed set into field

NetAct Software Manager Set Object Checkbox
    [Arguments]    ${Object_label}    ${Object_checkbox}
    [Documentation]    Helper KW for Software Manager -> Network Status objects checkbox set
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | Object_label | Yes | Object label info |
    ...    | Object_checkbox | Yes | Object checkbox info |
    Wait Until Keyword Succeeds    30    3    SeleniumLibrary.Element Should Be Visible    ${Object_checkbox}
    ${status}=    Run Keyword And Return Status    SeleniumLibrary.Checkbox Should Be Selected    ${Object_checkbox}
    Run Keyword If    ${status}    Run Keywords    Log    ${Object_label} checkbox already set    console=True
    ...    AND    Return From Keyword
    Run Keyword If    not ${status}  Wait Until Keyword Succeeds  3x    3    Run Keywords  SeleniumLibrary.Select Checkbox
    ...    ${Object_checkbox}
    ...    AND    Screenshot.Take Screenshot
    ${status}=    Run Keyword And Return Status    SeleniumLibrary.Checkbox Should Be Selected    ${Object_checkbox}
    Run Keyword If    ${status}    Log    ${Object_label} checkbox properly set    console=True
    ...    ELSE    Run Keywords    Log    ${Object_label} checkbox failed set    level=ERROR
    ...    AND    Fail    ${Object_label} checkbox failed set

NetAct Software Manager Press Enter
    [Arguments]    ${Object}
    SeleniumLibrary.Press Key    ${Object}    \\13

NetAct Software Manager Get MO Software Version
    [Documentation]    Helper KW providing MO SW version from Software Manager -> Network Status
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | Active_SW_version | MO active SW version |
    ...    | Passive_SW_version | MO passive SW version |
    ${Active_SW_ID_field}=    Set Variable    xpath=//td[@class="columnActiveSwIdNS"]/span
    ${Passive_SW_ID_field}=    Set Variable    xpath=//td[@class="columnPassiveSwIdNS"]/span
    ${Active_SW_version}=    Wait Until Keyword Succeeds    3x    1    SeleniumLibrary.Get Text    ${Active_SW_ID_field}
    ${Passive_SW_version}=    Wait Until Keyword Succeeds    3x    1    SeleniumLibrary.Get Text    ${Passive_SW_ID_field}
    [Return]    ${Active_SW_version}    ${Passive_SW_version}

NetAct Close Application
    [Documentation]    Helper KW for application close procedure
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    SeleniumLibrary.Close All Browsers
    [Teardown]    Screenshot.Take Screenshot

Get MO SW Version From NetAct
    [Arguments]    ${MO_type}    ${MO_dn}
    [Documentation]    Helper KW for retrieving MO SW version from NetAct based on CLI and GUI
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | MO_type | Yes | MO type info |
    ...    | MO_dn | Yes | MO distinguished name info |
    ...
    ...    *RETURN VALUE*
    ...    | Active_SW_NetAct | MO active SW from NetAct |
    ...    | Passive_SW_NetAct | MO passive SW from NetAct |
    ${result}    ${info}=    Run Keyword And Ignore Error    Get Mo Status    dist_names=${MO_dn}
    Run Keyword If    '${result}' == 'PASS'    Return From Keyword    ${info['${MO_dn}']['active_sw']}
    ...    ${info['${MO_dn}']['passive_sw']}
    ${Active_SW_NetAct}    ${Passive_SW_NetAct}=    Get MO SW Version From NetAct GUI    MO_type=${MO_type}
    ...    MO_dn=${MO_dn}
    [Return]    ${Active_SW_NetAct}    ${Passive_SW_NetAct}

NetAct Activate Plan
    [Arguments]    ${plan_name}    ${dist_names}
    [Documentation]    Helper keyword used for activate the preactived plan
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | plan_name | Yes | Plan Name |
    ...    | dist_names | Yes | MO distName |
    ${status}=    Run Keyword And Return Status    netact.Activate Preactivated Plan    plan_name=${plan_name}
    ...    dist_names=${dist_names}
    Run Keyword If    ${status}    Log    Activate plan ${plan_name} successfully done!    console=True
    ...    ELSE    Run Keywords    Log    Activate plan ${plan_name} failed!    level=ERROR
    ...    AND    Fail    Activate plan ${plan_name} failed!

Check File Exist From SBTS Local
    [Arguments]    ${file_path}    ${file_name}    ${flag}
    [Documentation]    Helper keyword used for check specific file exist or not on SBTS
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | file_path | Yes | File Path |
    ...    | file_name | Yes | File Name
    ...    | flag | Yes | exist True or False
    SSHLibrary.Open Connection    ${SMOD1['TRS_IP']}
    SSHLibrary.Login    ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}
    @{result}    SSHLibrary.Execute Command    cd ${file_path} \ && ls    return_stderr=${True}
    Run keyword if    ${flag}    SSHLibrary.File Should Exist    ${file_path}/${file_name}
    ...    ELSE    SSHLibrary.File Should Not Exist    ${file_path}/${file_name}
    SSHLibrary.close_connection

Should Contain Error
    [Arguments]    ${error}    ${exp_error_mo}    ${exp_error_message}
    [Documentation]    Helper keyword used for check expected error message should contain in error,
    ...    and the error mo is expected error mo.
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | error | Yes | the error return by validate keyword(Provision Plan) from NetAct|
    ...    | exp_error_mo | Yes | expected error manage object, like:PLMN-PLMN/MRBTS-1895/MNL-1|
    ...    | exp_error_message | Yes | expected error message should contain in the error,
    ...    like:Whenever MNL-1 having MNL-1.productVariantPlanned (value: lteBTS) equal to lteBTS|
    ${validate_sta_list}    Split String    ${error}    5G/LTE/SRAN plan validate started.
    ${message_end_list}    Split String    ${validate_sta_list}[1]    5G/LTE/SRAN plan validate failed.
    ${items_list}    Split String    ${message_end_list}[0]    Feedback received:
    ${error_result}    Set Variable    ${False}
    FOR    ${item}    IN    @{items_list}
        ${length}    Get Length    ${item}
        Continue For Loop If    ${length}==${1}
        ${detail}    Split String    ${item}    Details:
        ${length}    Get Length    ${detail}
        Continue For Loop If    ${length}==${1}
        ${error_lines_string}    Get Lines Containing String    ${detail[1]}    ERROR TEXT #
        ${error_lines_list}    Split To Lines    ${error_lines_string}
        ${head_detail}    Remove String    ${detail[1]}    ${error_lines_string}
        ${head_lines_list}    Split To Lines    ${head_detail}
        ${error_dic}    Set Error To Dictionary    ${head_lines_list}    ${error_lines_list}
        ${mo_result}    Run Keyword And Return Status    Should Be Equal    ${error_dic["MANAGED OBJECT"]}    ${exp_error_mo}
        Continue For Loop If    ${mo_result}==${False}
        ${error_result}    Check Error Contains in Errors    ${exp_error_message}    ${error_dic["ERROR TEXT"]}
        Exit For Loop If    ${error_result}==${True}
    END
    Should Be True    ${error_result}

Set Error To Dictionary
    [Arguments]    ${head_lines_list}    ${error_lines_list}
    [Documentation]    Helper keyword used for converte each one error to dictionary.
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | head_lines_list| Yes | each one error's head info: mo, mo class, operation, status|
    ...    | error_lines_list| Yes | each one error's error text:ERROR TEXT #0001, ERROR TEXT #0002...|
    ...
    ...    *OUTPUT*
    ...    | detail_dic|return detail error dictionary include error head info and error texts|
    ...
    ...    Example:
    ...    ${head_lines_list}=[' ',
    ...    'MANAGED OBJECT \ \ \ : MRBTS-1895/MNL-1',
    ...    ' MO CLASS \ \ \ \ \ \ \ \ : MNL',
    ...    ' OPERATION \ \ \ \ \ \ \ : UPDATE',
    ...    ' STATUS \ \ \ \ \ \ \ \ \ \ : FAILURE',
    ...    '']
    ...    ${error_lines_list}=[' ERROR TEXT #0001 : {"Severity": "Error", "Assertion": "638", "Text": "2
    ...    Cabinets can be configured only when productVariantPlanned is set to sBTS.", "Detail": "Assertion not met:
    ...    MNL((every CABINET have cardinality = 2)) have productVariantPlanned = \'sBTS\'"}',
    ...    ' ERROR TEXT #0002 : {"Severity": "Error", "Assertion": "7299", "Text": "Whenever MNL-1
    ...    having MNL-1.productVariantPlanned (value: lteBTS) equal to lteBTS, it is required that embedded assertion
    ...    valid (Namely: It is required that there not exist MOs FPMUX)",
    ...    "Detail": "Assertion not met: MNL(productVariantPlanned = \'lteBTS\')
    ...    have (every TNLSVC/TNL/IPAPP/FPMUX not exist)"}',
    ...    ' ERROR TEXT #0003 : {"Severity": "Error", "Assertion": "7307", "Text": "Whenever MNL-1
    ...    having MNL-1.productVariantPlanned (value: lteBTS) equal to lteBTS, it is
    ...    required that embedded assertion valid (Namely: It is required that there not exist MOs WNBTS)",
    ...    "Detail": "Assertion not met: MNL(productVariantPlanned = \'lteBTS\') have (every WNBTS not exist)"}',
    ...    ' ERROR TEXT #0004 : {"Severity": "Error", "Assertion": "7308", "Text": "Whenever MNL-1 having
    ...    MNL-1.productVariantPlanned (value: lteBTS) equal to lteBTS, it is required that embedded assertion
    ...    valid (Namely: It is required that there not exist MOs GNBTS)", "Detail": "Assertion not met:
    ...    MNL(productVariantPlanned = \'lteBTS\') have (every GNBTS not exist)"}',
    ...    ' ERROR TEXT #0005 : {"Severity": "Error", "Assertion": "7311", "Text": "Whenever MNL-1 having
    ...    MNL-1.productVariantPlanned (value: lteBTS) equal to lteBTS, it is required that embedded assertion
    ...    valid (Namely: It is required that PMTNL.pppLinkStatisticsInterval equal to disabled)", "Detail":
    ...     "Assertion not met: MNL(productVariantPlanned = \'lteBTS\') have (every TNLSVC/TNL/PMTNL
    ...    have pppLinkStatisticsInterval = \'disabled\')"}',
    ...    ' ERROR TEXT #0006 : {"Severity": "Error", "Assertion": "7312", "Text": "Whenever MNL-1
    ...    having MNL-1.productVariantPlanned (value: lteBTS) equal to lteBTS, it is required that embedded assertion
    ...   valid (Namely: It is required that PMTNL.pppMultiLinkStatisticsInterval equal to disabled)", "Detail":
    ...   "Assertion not met: MNL(productVariantPlanned = \'lteBTS\') have (every TNLSVC/TNL/PMTNL have
    ...    pppMultiLinkStatisticsInterval = \'disabled\')"}',
    ...    ' ERROR TEXT #0007 : {"Severity": "Error", "Assertion": "7313", "Text": "Whenever MNL-1 having
    ...   MNL-1.productVariantPlanned (value: lteBTS) equal to lteBTS, it is required that embedded assertion valid
    ...   (Namely: It is required that PMTNL.pppSingleLinkStatisticsInterval equal to disabled)", "Detail":
    ...   "Assertion not met: MNL(productVariantPlanned = \'lteBTS\') have (every TNLSVC/TNL/PMTNL
    ...   have pppSingleLinkStatisticsInterval = \'disabled\')"}'] ]
    ${detail_dic}    Create Dictionary
    FOR    ${line}    IN    @{head_lines_list}
        Continue For Loop If    "${line.strip()}"==""
        ${key}    Fetch From Left    ${line}    :
        ${tmp_value}    Remove String    ${line}    ${key}
        ${value}    Remove String    ${tmp_value}    :
        Set To Dictionary    ${detail_dic}    ${key.strip()}    ${value.strip()}
    END
    ${error_dic}    Create Dictionary
    FOR    ${error_line}    IN    @{error_lines_list}
        ${error_key}    Fetch From Left    ${error_line}    :
        ${tmp_error_value}    Remove String    ${error_line}    ${error_key}
        ${error_value}    Get Substring    ${tmp_error_value}    1
        ${not_dictionary_like}    Run Keyword and Return Status    Should Not Start With    ${error_value.strip()}    \{
        Continue For Loop If    ${not_dictionary_like}
        ${not_dictionary_like}    Run Keyword and Return Status    Should Not End With    ${error_value.strip()}    \}
        Continue For Loop If    ${not_dictionary_like}
        Set To Dictionary    ${error_dic}    ${error_key.strip()}    ${error_value.strip()}
    END
    Set To Dictionary    ${detail_dic}    ERROR TEXT    ${error_dic}
    [Return]    &{detail_dic}

Check Error Contains in Errors
    [Arguments]    ${exp_error_message}    ${error_item_dic}
    [Documentation]    Helper keyword used for check expected error message should contain in one of ERROR TEXT
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | exp_error_message | Yes | expected error message should contain in the error, like:Whenever MNL-1 having
    ...    MNL-1.productVariantPlanned (value: lteBTS) equal to lteBTS|
    ...    | error_item_dic | Yes | all ERROR TEXT|
    ...
    ...    *OUTPUT*
    ...    |error_result|True or False, if expected errpr message contain in one of ERROR TEXT's "Text", return True,
    ...    else return False.
    ${err_keys_list}    Get Dictionary Keys    ${error_item_dic}
    ${error_result}    Set Variable    ${False}
    FOR    ${err_item_key}    IN    @{err_keys_list}
        ${error_item_detail_dic}    Evaluate    ${error_item_dic["${err_item_key}"]}
        ${error_result}    Run Keyword And Return Status    Should Contain    ${error_item_detail_dic["Text"]}
        ...    ${exp_error_message}
        Exit For Loop If    ${error_result}
    END
    [Return]    ${error_result}

Convert Variables Of VALIDATE_INFO
    [Documentation]    Replace undefined variables in ${VALIDATE_INFO} contained in
    ...    config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/testdata file.
    ...
    ...    *AUTHOR*
    ...    bin.7.liu@nokia-sbell.com
    ${lst}    Query infomodel    get list //LNBTS-*
    ${lnbts_id}    Set Variable
    FOR    ${item}    IN    @{lst}
        Continue For Loop If    '${item["btsId"]}'=='${0}'
        ${lnbts_id}    Set Variable    ${item["btsId"]}
        Exit For Loop
    END
    ${mrbts_name}    Fetch From Right    ${MRBTS_DN}    /
    ${MRBTS}    Set Variable    ${mrbts_name}
    ${LNBTS}    Set Variable    LNBTS-${lnbts_id}
    ${tmp_str}    Convert To String    ${VALIDATE_INFO}
    ${tmp_validate_str}    Replace Variables    ${tmp_str}
    ${validate_data_list}    Evaluate    ${tmp_validate_str}
    ${count}    Get Length    ${validate_data_list}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    Set Test Variable    ${VALIDATE_DATA}    ${validate_data_list[${index}]}

#--------------------------------------------------------*Status Check:Start*---------------------------------------------------#
Verify SBTS Online State From IMS2
    [Arguments]    ${ims2_file_path_name}
    [Documentation]    Check BTS online status: no BTS reset,RAT reset,Cell Block/Unblock or
    ...   Cell lock/unlock happened after CM operation
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | ims2_file_path_name | Yes | ims2 file generate path and name
    ${reset_was_triggered}    Infomodel Check IM log if BTS reset was triggered    ${ims2_file_path_name}
    Run Keyword If    '${reset_was_triggered}' == 'False'    Log    No Reset for SBTS after CM operation    console=True
    ...    ELSE    Fail    SBTS was reset after CM operation
    ${LTE_status_change_not_trigger}    Run Keyword And Return Status
    ...    Infomodel check if cells in RAT were operational according to IM log    LTE    ${ims2_file_path_name}
    Run Keyword If    '${LTE_status_change_not_trigger}' == 'True'
    ...    Log     No Reset,Cell Block/Unblock or Cell lock/unlock happened for SBTS after user operation    console=True
    ...    ELSE    Fail    LTE RAT has Reset,Cell Block/Unblock or Cell lock/unlock happened after CM operation
    ${NR_status_change_not_trigger}    Run Keyword And Return Status
    ...    Infomodel check if cells in RAT were operational according to IM log    NR    ${ims2_file_path_name}
    Run Keyword If    '${NR_status_change_not_trigger}' == 'True'
    ...    Log    No Reset,Cell Block/Unblock or Cell lock/unlock happened for NR after user operation    console=True
    ...    ELSE    Fail    NR RAT has Reset,Cell Block/Unblock or Cell lock/unlock happened after CM operation
    ${WCDMA_status_change_not_trigger}    Run Keyword And Return Status
    ...    Infomodel check if cells in RAT were operational according to IM log    WCDMA    ${ims2_file_path_name}
    Run Keyword If    '${WCDMA_status_change_not_trigger}' == 'True'
    ...    Log    No Reset for SBTS after CM operation    console=True
    ...    ELSE    Fail    WCDMA RAT has Reset,Cell Block/Unblock or Cell lock/unlock happened after CM operation
    ${GSM_status_change_not_trigger}    Run Keyword And Return Status
    ...    Infomodel check if cells in RAT were operational according to IM log    GSM    ${ims2_file_path_name}
    Run Keyword If    '${GSM_status_change_not_trigger}' == 'True'
    ...    Log    No Reset for SBTS after CM operation    console=True
    ...    ELSE    Fail    GSM RAT has Reset,Cell Block/Unblock or Cell lock/unlock happened after CM operation

Verify RATs State Changed From IMS2
    [Arguments]    ${ims2_file_path_name}    @{list_changed_RATs}
    [Documentation]    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    Check RATs state has been changed or not changed as expected in IMs.
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | ims2_file_path_name | Yes | ims2 file generate path and name |
    ...    | list_changed_RATs | Yes | list of RATs expected state has been changed |
    ...
    ...    *Example*
    ...    | Verify RATs State Changed From IMS2 | ${file_name} | GSM |
    ...    | Verify RATs State Changed From IMS2 | ${file_name} | LTE | NR |
    ...    | Verify RATs State Changed From IMS2 | ${file_name} |
    ...    | ${changed_rats} | Create List | GSM | WCDMA |
    ...    | Verify RATs State Changed From IMS2 | ${file_name} | @{changed_rats} |
    ute_admin_infomodel.Save Infomodel Log    ${ims2_file_path_name}    timeout=120
    ${list_not_changed_RATs}    Create List    GSM    WCDMA    LTE    NR
    Remove Values From List    ${list_not_changed_RATs}    @{list_changed_RATs}
    FOR    ${rat}    IN    @{list_not_changed_RATs}
        ${status_change_not_triggered}    Run Keyword And Return Status
        ...    Infomodel check if cells in RAT were operational according to IM log    ${rat}    ${ims2_file_path_name}
        Run Keyword If    '${status_change_not_triggered}' == 'True'
        ...    Log    No Reset,Cell Block/Unblock or Cell lock/unlock happened for ${rat} after user operation    console=True
        ...    ELSE    Fail    ${rat} RAT has Reset,Cell Block/Unblock or Cell lock/unlock happened after CM operation
    END
    FOR    ${rat}    IN    @{list_changed_RATs}
        ${status_change_triggered}    Run Keyword And Return Status
        ...    Infomodel check if cells in RAT were non-operational according to IM log    ${rat}    ${ims2_file_path_name}
        Run Keyword If    '${status_change_triggered}' == 'True'
        ...    Log    Reset happened for ${rat} after CM operation    console=True
        ...    ELSE    Fail    ${rat} RAT not has Reset after CM operation
    END

Verify Cells State Changed From IMS2
    [Arguments]    ${ims2_file_path_name}    @{list_changed_cells}
    [Documentation]    *AUTHOR* yuyan.xu@nokia-sbell.com
    ...    only support changed cells on one rat now, can optimize.
    ...    Check Cells state has been changed or not changed as expected in IMs.
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | ims2_file_path_name | Yes | ims2 file generate path and name |
    ...    | list_changed_cells | Yes | list of cells expected state has been changed. LNCEL-1,WNCEL-2,NRCELL-0
    ...
    ...    *Example*
    ...    | Verify Cells State Changed From IMS2 | ${file_name} | GNCEL-1, GNCEL-2 |
    ...    | Verify Cells State Changed From IMS2 | ${file_name} | WNCEL-1 | LNCEL-2 | NRCELL-0 |
    ...    | Verify Cells State Changed From IMS2 | ${file_name} |
    ...    | Verify Cells State Changed From IMS2 | ${file_name} | @{list_changed_cells} |
    ute_admin_infomodel.Save Infomodel Log    ${ims2_file_path_name}    timeout=120
    ${list_changed_RATs}    Create List
    ${list_changed_cells_GSM}    Create List
    ${list_changed_cells_WCDMA}    Create List
    ${list_changed_cells_LTE}    Create List
    ${list_changed_cells_NR}    Create List
    FOR    ${cell}    IN    @{list_changed_cells}
        Run Keyword If    "${cell.split("-")[0]}"=="GNCEL"    Run Keywords
        ...    Append To List    ${list_changed_RATs}    GSM    AND  Append To List    ${list_changed_cells_GSM}    ${cell}
        ...    ELSE IF    "${cell.split("-")[0]}"=="WNCEL"    Run Keywords
        ...    Append To List    ${list_changed_RATs}    WCDMA    AND  Append To List    ${list_changed_cells_WCDMA}    ${cell}
        ...    ELSE IF    "${cell.split("-")[0]}"=="LNCEL"    Run Keywords
        ...    Append To List    ${list_changed_RATs}    LTE    AND  Append To List    ${list_changed_cells_LTE}    ${cell}
        ...    ELSE IF    "${cell.split("-")[0]}"=="NRCELL"    Run Keywords
        ...    Append To List    ${list_changed_RATs}    NR    AND  Append To List    ${list_changed_cells_NR}    ${cell}
    END
    ${list_not_changed_RATs}    Create List    GSM    WCDMA    LTE    NR
    Remove Values From List    ${list_not_changed_RATs}    @{list_changed_RATs}
    FOR    ${rat}    IN    @{list_not_changed_RATs}
        ${status_change_not_triggered}    Run Keyword And Return Status
        ...    Infomodel check if cells in RAT were operational according to IM log    ${rat}    ${ims2_file_path_name}
        Run Keyword If    '${status_change_not_triggered}' == 'True'
        ...    Log    No Reset,Cell Block/Unblock or Cell lock/unlock happened for ${rat} after user operation    console=True
        ...    ELSE    Fail    ${rat} RAT has Reset,Cell Block/Unblock or Cell lock/unlock happened after CM operation
    END
    FOR    ${rat}    IN    @{list_changed_RATs}
        ${status_change_triggered}    Run Keyword And Return Status
        ...    Infomodel check if partial cells in RAT were non-operational according to IM log
        ...    ${rat}    ${ims2_file_path_name}    ${list_changed_cells_${rat}}
        Run Keyword If    '${status_change_triggered}' == 'True'
        ...    Log    Cell status changed happened for ${rat} after CM operation    console=True
        ...    ELSE    Fail    ${rat} cell status not has changed after CM operation
    END



#--------------------------------------------------------*Status Check:END*---------------------------------------------------#
Fetch LNBTS ID
    [Documentation]    Fetch and return LNBTS ID
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    ...
    ...    *OUTPUT*
    ...    | lnbts_id| LNBTS ID
    ...    *HISTORY*
    ...    2021.03.03: update to replace infomodel by admin
    ${lst}    coam.Get Ids For All    LNBTS
    ${lnbts_r}=    Fetch From Right    ${lst[0]}    /
    ${lnbts_id}=    Get Substring    ${lnbts_r}    8
    [Return]    ${lnbts_id}

Load And Convert Json File
    [Arguments]    ${file_path}
    [Documentation]    Read json file and replace the variables, load the data from json and return a dictionary
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | file_path | Yes | json file directory
    ...    *OUTPUT*
    ...    | test_data|return data dictionary
    ${file_content}    OperatingSystem.Get File    ${file_path}
    ${file_content}    Replace Variables    ${file_content}
    ${test_data}    Evaluate    ${file_content}
    [Return]    ${test_data}

Fetch NRBTS ID
    [Documentation]    Fetch and return NRBTS ID
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...
    ...    *OUTPUT*
    ...    | nrbts_id| NRBTS ID
    ${lst}    Query infomodel    get list //NRBTS_A-*
    ${nrbts_id}    Set Variable
    FOR    ${item}    IN    @{lst}
        Continue For Loop If    '${item["dist_name"]}'=='${0}'
        ${nrbts_dn}    Set Variable    ${item["dist_name"]}
        ${nrbts_id}    Fetch From Right    ${nrbts_dn}    -
        Exit For Loop
    END
    [Return]    ${nrbts_id}

Fetch Cells Mapping From Infomodel
    [Arguments]    ${Rat_Type}
    [Documentation]    Fetch cells mapping in SCF and Runtime View
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | Rat_Type | Yes | e.g. GNBTS,WNBTS,LNBTS,NRBTS
    ...    *OUTPUT*
    ...    | cells_mapping|return data dictionary
    &{cells_mapping}    Create Dictionary
    ${cell_RT_path}    Set Variable If    "${Rat_Type}" == "GNBTS"    //GNBTS_R-*/GNBCF_R-*/GNCEL_CONF_M-*/GNCEL_R-*
    ...    "${Rat_Type}" == "WNBTS"    //WNBTS_R-*/WNCEL_R-*    "${Rat_Type}" == "LNBTS"
    ...    //LNBTS_R-*/LNCEL_R-*    "${Rat_Type}" == "NRBTS"    //NRBTS_R-*/NRCELL_R-*
    ${cells_RT_obj}    Query infomodel    get list ${cell_RT_path}
    FOR    ${cell_RT_obj}    IN    @{cells_RT_obj}
        ${cell_RT}    Set Variable    ${cell_RT_obj["dist_name"]}
        ${cell_RT_REF}    Query infomodel    get list ${cell_RT_obj["dist_name"]}/CONF_REF-1
        ${cell_CONF_A}    Set Variable    ${cell_RT_REF[0]["distName"]}
        ${cell_CONF_id}    Fetch From Right    ${cell_CONF_A}    -
        ${cell_CONF}    Set Variable    NRCELL-${cell_CONF_id}
        ${cell_CONF}    Set Variable If    "${Rat_Type}" == "GNBTS"    GNCEL-${cell_CONF_id}    "${Rat_Type}" == "WNBTS"
        ...    WNCEL-${cell_CONF_id}    "${Rat_Type}" == "LNBTS"
        ...    LNCEL-${cell_CONF_id}    "${Rat_Type}" == "NRBTS"    NRCELL-${cell_CONF_id}
        Set To Dictionary    ${cells_mapping}    ${cell_CONF}    ${cell_RT}
    END
    [Return]    ${cells_mapping}

Random Select Parameter From Json
    [Arguments]    ${testdatas}
    [Documentation]    Helper keyword used for random seletect parameter from json file
    ...    (e.g./home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}
    ...    /testdata/PremeterModifyTriggerAction/NRObject_Locking/CM_NR_Locking_para.json)
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | testdatas | Yes | SCF json file place |
    ...
    ...    *OUTPUT*
    ...    | plan_info | Yes | return plan info dictionary |
    ${TEST_DATA}    Load And Convert Json File    ${testdatas}
    Set Test Variable    ${TEST_DATA}
    ${count}    Get Length    ${TEST_DATA}
    ${random}    Evaluate    random.randint(0, ${count-1})    modules=random, sys
    Set Test Variable    ${TEST_DATA_SELECTED}    ${TEST_DATA}[${random}]
    Set Test Variable    ${scf_distName}    ${TEST_DATA_SELECTED["Parameters"][0]["scf_distName"]}
    Set Test Variable    ${mo_id}    ${TEST_DATA_SELECTED["Parameters"][0]["mo_id"]}
    ${param_names}    Get Dictionary Keys    ${TEST_DATA_SELECTED["Parameters"][0]["parameters"][0]}
    ${param_values}    Get Dictionary Values    ${TEST_DATA_SELECTED["Parameters"][0]["parameters"][0]}
    ${current_param_value}    Get Parameter Value From WebEM    ${TEST_DATA_SELECTED["Parameters"][0]["scf_distName"]}
    ...    ${param_names[0]}
    Remove Values From List    ${param_values[0]}    ${current_param_value}
    ${values_count}    Get Length    ${param_values[0]}
    ${random}    Evaluate    random.randint(0, ${values_count-1})    modules=random, sys
    &{parameter}    Create Dictionary
    Set Test Variable    &{parameter}    ${param_names[0]}=${param_values[0][${random}]}
    &{plan_info}    Create Dictionary    mo_id=${mo_id}    scf_distName=${scf_distName}    parameter=&{parameter}
    [Return]    &{plan_info}

Get Parameter Value From WebEM
    [Arguments]    ${scf_distName}    ${param_name}    ${alias}=default    ${export_type}=configuration
    [Documentation]    Helper keyword used for get parameter value from WebEM, if not find this parameter,
    ...    will fail this keyword.
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | scf_distName | Yes | SCF distName of MO for given parameter |
    ...    | param_name | Yes | parameters name | \ parameter_name unfit parameter in list
    ${result}    Set Variable    False
    ${BTS_scf}=    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}    alias=${alias}    export_type=${export_type}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf}
    ${result_value}=    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${scf_distName}"]/p
    ${result_value_dict}=    Create dictionary
    FOR    ${item}    IN    @{result_value}
        ${name}    L_XML.Get Element Attribute    ${item}    name
        ${value}    L_XML.Get Element Text    ${item}
        ${result}    Set Variable If    '${name}' == '${param_name}'    True
        Return From Keyword If    '${name}' == '${param_name}'    ${value}
    END
    Should Be True    ${result}    True

Check NRBTS Cells Onair
    [Documentation]    Check NRBTS Cell are onair
    ...    If do not have NRBTS cell will return from keyword with pass, if existed NRBTS cells, NRcells must onair.
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...    lixin.kang@nokia-sbell.com
    ...    *OUTPUT*
    ...    | cells_RT_obj_count | return NRcell number
    ...    *HISTORY*
    ...    2021/03/02: Updated to replace infomodel check by admin check
    ...    2021/04/30: Add fail scenario to cover not onair logic
    ${NR_cell_ids}=    coam.Get Ids For All    NRCEL
    ${cells_RT_obj_count}=    Get Length    ${NR_cell_ids}
    ${NR_cells_operational}=    Run Keyword If    ${NR_cell_ids}    Run Keyword And Return Status    coam.Assert Every
    ...    NRCEL    administrativeState=Unlocked, operationalState=enabled
    ...    ELSE    Set Variable    ${TRUE}
    Run Keyword If    ${NR_cell_ids}    Run Keyword If    ${NR_cells_operational}    Log    All NR cells are operational!
    ...    level=INFO
    ...    console=True
    Run Keyword If    ${NR_cell_ids}    Run Keyword If    not ${NR_cells_operational}    Run Keywords
    ...    Log    Not all NR cells are operational!
    ...    level=ERROR
    ...    AND    Fail    Not all NR cells are operational!
    [Return]    ${cells_RT_obj_count}

Fetch ID Mapping From Admin For Module
    [Arguments]    ${identifier}=${NONE}    ${identifier_type}=configuration    ${mod_type}=RMOD
    [Documentation]    Fetch ID Mapping From Admin For Module
    ...    If do not have NRBTS cell will return from keyword with pass, if existed NRBTS cells, NRcells must onair.
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    ...    | identifier | if not provided, a list of Module mappings will be returned
    ...    |identifier_type|
    ...    internal, e.g. /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2
    ...    configuration, e.g.MRBTS-1896/EQM-1/APEQM-1/RMOD-3
    ...    runtime:MRBTS-1896/EQM_R-1/APEQM_R-1/RMOD_R-
    ...    default is internal
    ...    | mod_type | RMOD,SMOD or BBMOD. Default is RMOD
    ...    2021/03/02: Updated to replace infomodel check by admin check
    ${id_dic}=    Create Dictionary
    ${id_mapping_list}=    Create List
    ${bts_all_info}=    coam.Get Bts Info
    ${radioModules_info}=    Get From Dictionary    ${bts_all_info}    radioModules
    ${rmod_info_list}=    Get From Dictionary    ${radioModules_info}    rmod
    ${smod_info_list}=    Get From Dictionary    ${bts_all_info}    systemModules
    ${bbmod_info_list}=    Get From Dictionary    ${bts_all_info}    basebandModules
    ${mod_info_list_to_fetch}=    Set Variable If    '${mod_type}'=='RMOD'    ${rmod_info_list}    '${mod_type}'=='SMOD'
    ...    ${smod_info_list}    '${mod_type}'=='BBMOD'
    ...    ${bbmod_info_list}
    FOR    ${item}    IN    @{mod_info_list_to_fetch}
        ${id}=    Get From Dictionary    ${item}    id
        Append To List    ${id_mapping_list}    ${id}
    END
    Return From Keyword If    '${identifier}' == '${NONE}'    ${id_mapping_list}
    FOR    ${item}    IN    @{mod_info_list_to_fetch}
        ${id}=    Get From Dictionary    ${item}    id
        ${identifier_type_value}=    Get From Dictionary    ${id}    ${identifier_type}
        ${id_dic}=    Set Variable If    '${identifier_type_value}' == '${identifier}'    ${id}
        Exit For Loop If    '${identifier_type_value}'=='${identifier}'
    END
    Run Keyword If    ${id_dic} == ${NONE}    Run Keywords    Log    Can't find the mapping with identifier: ${identifier}
    ...    level=ERROR
    ...    AND    Fail    Can't find the mapping with identifier: ${identifier}. Please check the input parameters!
    [Return]    ${id_dic}

Excepted Alarm Be Cleared From NetAct And WebEM
    [Arguments]    ${alarmId}    ${faultId}
    [Documentation]    Expected Alarm Be Cleared From NetAct And WebEM
    ...    Check if expected alarm not have in NetAct active alarm and WebEM active Alarm.
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...    | Parameter | Mandatory | Description |
    ...    | alarmId | Yes | filed "specificProblem" in NetAct active alarm list
    ...    | faultId | Yes | \ filed "additionalText3" in NetAct active alarm list.
    ...    2021/04/16: Check expected alarm cleared from netact and webem.
    Log    Excepted Alarm Be Cleared From NetAct And WebEM    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${active_alarms}    netact.Get Alarms    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}
    ${current_alarm_list}    Create List
    ${find_alarm}    Set Variable    ${False}
    FOR    ${alarm}    IN    @{active_alarms}
        Continue For Loop If    "${alarm}[additionalText3]" == "None"
        @{faultId_list}    Split String    ${alarm}[additionalText3]
        ${alarm_dic}    Evaluate    {"alarmId":"${alarm}[specificProblem]","faultId":"${faultId_list[0]}"}
        Append To List    ${current_alarm_list}    ${alarm_dic}
        ${find_alarm_NetAct}    Set Variable If
        ...    "${alarm}[specificProblem]"=="${alarmId}" and "${faultId_list[0]}" == "${faultId}"    ${True}
        Exit For Loop If    ${find_alarm_NetAct}
    END
    Should Not Be True    ${find_alarm_NetAct}
    ${find_alarm_WebEM}    ${message}    Run Keyword And Ignore Error
    ...    coam.Assert alarm active    alarmId=${alarmId}, faultId=${faultId}
    Should Be True    "${find_alarm_WebEM}" == "FAIL"

Fetch ID Mapping From Admin For Cells
    [Arguments]    ${rat_type}=ALL    ${identifier}=${NONE}    ${identifier_type}=configuration    ${alias}=default
    [Documentation]    Fetch ID Mapping From Admin For Cell
    ...    If do not have NRBTS cell will return from keyword with pass, if existed NRBTS cells, NRcells must onair.
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...    | rat_type | ALL, GSM, WCDMA, LTE or NRBTS. Default is ALL
    ...    | identifier | e.g. MRBTS-1816/WNBTS-1/WNCEL-2, will return WNCEL-2 mapping dic. Default is ${NONE},
    ...    will return all rat_type cells dic will return.
    ...    |identifier_type| internal, configuration
    ...    internal, e.g. /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-2
    ...    configuration, e.g.MRBTS-1816/WNBTS-1/WNCEL-2
    ...    default is configuration
    ...    2021/03/29: Updated to replace infomodel check by admin check
    ${result}    Set Variable    ${False}
    ${id_dic}    Create Dictionary
    ${id_mapping_list}    Create List
    ${bts_all_info}    coam.Get Bts Info    connection=${alias}
    ${cells_info}    Get From Dictionary    ${bts_all_info}    cells
    ${gsm_info_list}    Get From Dictionary    ${cells_info}    gsm
    ${wcdma_info_list}    Get From Dictionary    ${cells_info}    wcdma
    ${lte_info_list}    Get From Dictionary    ${cells_info}    lte
    ${nr_info_list}    Get From Dictionary    ${cells_info}    nr
    ${all_info_list}    Combine Lists    ${gsm_info_list}    ${wcdma_info_list}    ${lte_info_list}    ${nr_info_list}
    ${cell_info_list_to_fetch}    Set Variable If    '${rat_type}'=='GSM'    ${gsm_info_list}    '${rat_type}'=='WCDMA'
    ...    ${wcdma_info_list}    '${rat_type}'=='LTE'
    ...    ${lte_info_list}    '${rat_type}'=='NRBTS'    ${nr_info_list}    '${rat_type}'=='ALL'    ${all_info_list}
    FOR    ${item}    IN    @{cell_info_list_to_fetch}
        ${id}=    Get From Dictionary    ${item}    id
        Append To List    ${id_mapping_list}    ${id}
    END
    Log    ${id_mapping_list}
    Return From keyword If    '${identifier}'=='${NONE}'    ${id_mapping_list}
    FOR    ${item}    IN    @{id_mapping_list}
        ${identifier_type_value}=    Get From Dictionary    ${item}    ${identifier_type}
        ${id_dic}    Set Variable If    '${identifier_type_value}'=='${identifier}'    ${item}
        ${result}    Set Variable If    '${identifier_type_value}'=='${identifier}'    ${True}
        Exit For Loop If    '${identifier_type_value}'=='${identifier}'
    END
    Should Be True    ${result}    Can't find the identified id by givin path
    [Return]    ${id_dic}

Additional Variables Loader
    [Tags]    robot:no-dry-run
    ${interfaces_status}=    Run Keyword And Return Status    Import Variables    ${INTERFACES}
    ${netact_plan_status}=    Run Keyword And Return Status    Import Variables    ${NETACT_PLAN}
    Set Suite Variable    ${TEMP_LOGS_DIR}    /home/ute/btsauto/logs
    Run Keyword If    ${interfaces_status}    Run Keyword
    ...    Log    TAF Additional Variables : INTERFACES configuration variables loaded Successfully    console=True
    Run Keyword If    ${netact_plan_status}    Run Keyword
    ...    Log    TAF Additional Variables : NETACT_PLAN configuration variables Loaded Successfully    console=True

Get Current Name And Status Of All Cells
    [Arguments]    ${cell_name_type}=SCF_NAME
    [Documentation]    Get cell configuration names or internal names and their statuses.
    ...    Return two dictionaries, first dictionary contains mapping of cell onfiguration name and cell internal name,
    ...    second dictionary contains cell statuses.
    ...    Key of dictionaries shall be configuration name if ${cell_name_type} is 'SCF_NAME'
    ...    Key of dictionaries shall be configuration name if ${cell_name_type} is 'RUNTIME_NAME'
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Man. | Description |
    ...    | cell_name_type|No| Keys of dictionaries is configuration name or internal name, default vaule is SCF_NAME |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | scf_runtime_name_mapper \ | Dictionary contains mapping of cell onfiguration name and cell internal name |
    ...    | all_cell_status | Dictionary contains cell statuses |
    ...
    ...    *EXAMPLE*
    ...    | ${scf_runtime_name_mapper} | ${all_cell_status} | Get Current Name And Status Of All Cells | |
    ...    ${scf_runtime_name_mapper} = {'MRBTS-1815/GNBTS-1/GNBCF-1/GNCEL-1':
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/GNBTS_R-1/GNBCF_R-1/GNCEL_CONF_M-1/GNCEL_R-1',
    ...    'MRBTS-1815/LNBTS-3542/LNCEL-1': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-3542/LNCEL_R-1',
    ...    'MRBTS-1815/NRBTS-5487/NRCELL-1': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-5487/NRCELL_R-1',
    ...    'MRBTS-1815/WNBTS-1/WNCEL-19081': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/WNBTS_R-1/WNCEL_R-19081'}
    ...    ${all_cell_status} = {'MRBTS-1815/GNBTS-1/GNBCF-1/GNCEL-1': {'administrativeState': 'Unlocked',
    ...  'availabilityStatus': 'Online','blockingState': 'Unblocked','operationalState': 'Enabled','usageState': 'Active'},
    ...    'MRBTS-1815/LNBTS-3542/LNCEL-1': {'administrativeState': 'Unlocked','availabilityStatus':
    ...    'Online','blockingState': 'Unblocked','operationalState': 'Enabled','usageState': 'Idle'},
    ...    'MRBTS-1815/NRBTS-5487/NRCELL-1': {'administrativeState': 'Unlocked','availabilityStatus':
    ...    'Online','blockingState': 'Unblocked','operationalState': 'Enabled','proceduralStatus':
    ...    'configured','usageState': 'Active'},
    ...    'MRBTS-1815/WNBTS-1/WNCEL-19081': {'availabilityStatus': 'Online','blockingState':
    ...    'Unblocked','operationalState': 'Enabled','usageState': 'Active'}}
    ...
    ...    | ${scf_runtime_name_mapper} | ${all_cell_status} | Get Current Name And Status Of All Cells | RUNTIME_NAME |
    ...    ${scf_runtime_name_mapper} = {
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/GNBTS_R-1/GNBCF_R-1/GNCEL_CONF_M-1/GNCEL_R-1':
    ...   'MRBTS-1815/GNBTS-1/GNBCF-1/GNCEL-1',
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-3542/LNCEL_R-1': 'MRBTS-1815/LNBTS-3542/LNCEL-1',
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-5487/NRCELL_R-1': 'MRBTS-1815/NRBTS-5487/NRCELL-1',
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/WNBTS_R-1/WNCEL_R-19081': 'MRBTS-1815/WNBTS-1/WNCEL-19081'}
    ...    ${all_cell_status} = {'/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/GNBTS_R-1/GNBCF_R-1/GNCEL_CONF_M-1/GNCEL_R-1'
    ...    : {'administrativeState': 'Unlocked','availabilityStatus': 'Online','blockingState':
    ...    'Unblocked','operationalState': 'Enabled','usageState': 'Active'},
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-3542/LNCEL_R-1': {'administrativeState': 'Unlocked',
    ...  'availabilityStatus': 'Online','blockingState': 'Unblocked','operationalState': 'Enabled','usageState': 'Idle'},
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-5487/NRCELL_R-1': {'administrativeState':
    ...    'Unlocked','availabilityStatus': 'Online','blockingState': 'Unblocked','operationalState': 'Enabled',
    ...    'proceduralStatus': 'configured','usageState': 'Active'},
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/WNBTS_R-1/WNCEL_R-19081': {'availabilityStatus': 'Online',
    ...    'blockingState': 'Unblocked','operationalState': 'Enabled','usageState': 'Active'}}
    ${ignore_status}    Create List    usageState
    ${cell_list}    coam.Get Cell List
    ${name_type_mapper}    Create Dictionary    SCF_NAME=configuration    RUNTIME_NAME=internal
    ${name_type}    Pop From Dictionary    ${name_type_mapper}    ${cell_name_type}
    ${value_list}    Get Dictionary Values    ${name_type_mapper}
    ${value_type}    Set Variable    ${value_list[0]}
    ${empty_list}    Create List
    ${GSM_cells}    Pop From Dictionary    ${cell_list['cells']}    gsm    ${empty_list}
    ${WCDMA_cells}    Pop From Dictionary    ${cell_list['cells']}    wcdma    ${empty_list}
    ${LTE_cells}    Pop From Dictionary    ${cell_list['cells']}    lte    ${empty_list}
    ${NR_cells}    Pop From Dictionary    ${cell_list['cells']}    nr    ${empty_list}
    ${scf_runtime_name_mapper}    Create Dictionary
    ${all_cell_status}    Create Dictionary
    FOR    ${cell}    IN    @{GSM_cells}
        ${tmp_dic}    Create Dictionary
        Set To Dictionary    ${scf_runtime_name_mapper}    ${cell['id']['${name_type}']}    ${cell['id']['${value_type}']}
        Remove From Dictionary    ${cell['status']}    @{ignore_status}
        Convert Status According To CNI61110    ${cell['status']}
        Set To Dictionary    ${all_cell_status}    ${cell['id']['${name_type}']}    ${cell['status']}
    END
    FOR    ${cell}    IN    @{WCDMA_cells}
        ${tmp_dic}    Create Dictionary
        Set To Dictionary    ${scf_runtime_name_mapper}    ${cell['id']['${name_type}']}    ${cell['id']['${value_type}']}
        ${w_cell_administrator_state}    Pop From Dictionary    ${cell['status']}    administrativeState    NotKnown
        Run Keyword If    "${w_cell_administrator_state}"=="NotKnown"    Set To Dictionary    ${cell['status']}
        ...    administrativeState    Unlocked
        Remove From Dictionary    ${cell['status']}    @{ignore_status}
        Convert Status According To CNI61110    ${cell['status']}
        Set To Dictionary    ${all_cell_status}    ${cell['id']['${name_type}']}    ${cell['status']}
    END
    FOR    ${cell}    IN    @{LTE_cells}
        ${tmp_dic}    Create Dictionary
        Set To Dictionary    ${scf_runtime_name_mapper}    ${cell['id']['${name_type}']}    ${cell['id']['${value_type}']}
        Remove From Dictionary    ${cell['status']}    @{ignore_status}
        Convert Status According To CNI61110    ${cell['status']}
        Set To Dictionary    ${all_cell_status}    ${cell['id']['${name_type}']}    ${cell['status']}
    END
    FOR    ${cell}    IN    @{NR_cells}
        ${tmp_dic}    Create Dictionary
        Set To Dictionary    ${scf_runtime_name_mapper}    ${cell['id']['${name_type}']}    ${cell['id']['${value_type}']}
        Remove From Dictionary    ${cell['status']}    @{ignore_status}
        Convert Status According To CNI61110    ${cell['status']}
        Set To Dictionary    ${all_cell_status}    ${cell['id']['${name_type}']}    ${cell['status']}
    END
    [Return]    ${scf_runtime_name_mapper}    ${all_cell_status}

Check Actual Configuration Parameters
    [Arguments]    ${dist_name}    ${ui_values}=false    &{parameters_dict}
    [Documentation]    Check Actual Configuration Paramters
    ...
    ...    *AUTHOR*
    ...    yuyan.xu@nokia-sbell.com
    ...    lixin.kang@nokia-sbell.com
    ...    | dist_name| distName of element
    ...    | ui_values| default is false
    ...    | parameters_dict| Parameters with expected values
    ...   *HISTORY*
    ...    10/12/2021: updated by lixin.kang to add more scenarios for array/structure expected value
    ...    04/09/2025: updated by yuyxu.xu: add scenario: check simple parameter not existerd in netact plan
    Log    Check Actual Configuration Parameters    console=True
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs
    ...    file_name=check_netact_plan.xml    dist_names=${dist_name}    ui_values=${ui_values}
    ${param_names}    Get Dictionary Keys    ${parameters_dict}
    ${param_values}    Get Dictionary Values    ${parameters_dict}
    ${param_count}    Get Length    ${param_names}
    ${scf_xml}=    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/check_netact_plan.xml
    ${object}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${dist_name}"]
    ${obj_count}    Get Length    ${object}
    Should Be Equal As Integers    ${obj_count}    ${1}
    FOR    ${index}    IN RANGE    0    ${param_count}
        ${status}    ${paramObject}    Run Keyword And Ignore Error    L_XML.Get Element
        ...    ${scf_xml}    .//managedObject[@distName="${dist_name}"]/p[@name="${param_names[${index}]}]
        Run Keyword If    "${param_values[${index}]}"=="${EMPTY}"    Run Keywords     Should Be Equal As Strings    ${status}    FAIL
        ...    AND   Continue For Loop
        ${is_string}    Run Keyword And Return Status    Should Be String    ${param_values[${index}]}
        Run Keyword If    ${is_string}    Compare String Value In XML    ${scf_xml}    ${ui_values}    ${dist_name}
        ...    ${param_names[${index}]}    ${param_values[${index}]}
        ...    ELSE    Compare Unstring Value In XML    ${scf_xml}    ${ui_values}    ${dist_name}
        ...    ${param_names[${index}]}    ${param_values[${index}]}
    END

Get Parameter For NetAct Plan Due To TestData
    [Arguments]    ${scf_xml}    ${dic_param}
    [Documentation]    Get parameters for KW "ta_netact_cm_editor.Create Managed Object" from parsed scf due to testdata.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    | Parameter | Man. | Description |
    ...    | ${scf_xml} | Yes | Parsed SCF |
    ...    | ${dic_param} | Yes | dictionary contains information of parameters |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | ${expect_status} | String, describe the status of some MOs should appear after provision |
    ...    | ${sub_list_param_for_create_plan} | List, parameters for KW "ta_netact_cm_editor.Create Managed Object" |
    ...
    ...    *EXAMPLE*
    ...    | ${scf_xml} | L_XML.Parse xml | ${scf_file_path} |
    ...    | ${sub_expect_status} | ${sub_list_param_for_create_plan} | Get Parameter For NetAct Plan Due To TestData
    ...    | ${scf_xml} | ${dic_param} |
    ...
    ...    ${dic_param} = {"class": "com.nokia.srbts.nrbts:NRCELL","operation": "update","parameters":
    ...    {"actPciBasedCsiImRandomization":["true","false"]},"expect_status":"${DN}:availabilityStatus:Offline
    ...    ${DN}:operationalState:Disabled"}
    ...
    ...    ${sub_expect_status} = MRBTS-1896/LNBTS-3560/LNCEL-1:availabilityStatus:Offline MRBTS-1896/LNBTS-3560/
    ...    LNCEL-1:operationalState:Disabled MRBTS-1896/LNBTS-3560/LNCEL-2:availabilityStatus:Offline MRBTS-1896/
    ...    LNBTS-3560/LNCEL-2:operationalState:Disabled MRBTS-1896/LNBTS-3560/LNCEL-3:availabilityStatus:Offline
    ...    MRBTS-1896/LNBTS-3560/LNCEL-3:operationalState:Disabled
    ...
    ...    ${sub_list_param_for_create_plan} = [{'meta_class': b'NOKLTE:LNCEL','meta_version': b'xL22R1_2107_200',
    ...   'mo_id': b'MRBTS-1896/LNBTS-3560/LNCEL-1','operation': b'update','parameters': {b'allowPbIndexZero': b'true'}},
    ...    {'meta_class': b'NOKLTE:LNCEL','meta_version': b'xL22R1_2107_200','mo_id': b'MRBTS-1896/LNBTS-3560/LNCEL-2','
    ...    operation': b'update','parameters': {b'allowPbIndexZero': b'false'}},
    ...    {'meta_class': b'NOKLTE:LNCEL','meta_version': b'xL22R1_2107_200','mo_id': b'MRBTS-1896/LNBTS-3560/LNCEL-3',
    ...    'operation': b'update','parameters': {b'allowPbIndexZero': b'true'}}]
    ${all_elements}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="${dic_param['class']}"]
    ${all_count}    Get Length    ${all_elements}
    ${mo_count}    Pop From Dictionary    ${dic_param}    mo_count    -1
    ${need_random_pick}    Evaluate    -1<${mo_count}<${all_count}
    ${mo_count}    Set Variable If    ${need_random_pick}    ${mo_count}    ${all_count}
    ${list_n}    Evaluate    random.sample(range(${all_count}),${mo_count})    modules=random, sys
    ${elements}    Create List
    FOR    ${n}    IN    @{list_n}
        Append To List    ${elements}    ${all_elements[${n}]}
    END
    ${sub_list_param_for_create_plan}    Create List
    ${expect_status}    Set Variable
    FOR    ${element}    IN    @{elements}
        ${param_set}    Copy Dictionary    ${dic_param}    ${True}
        ${DN}    L_XML.Get Element Attribute    ${element}    distName
        ${version}    L_XML.Get Element Attribute    ${element}    version
        ${dic_param_value}    Get Value To Set    ${DN}    ${scf_xml}    ${param_set}
        ${dic_param_for_create_plan}    Create Dictionary    meta_class=${param_set['class']}    meta_version=${version}
        ...    mo_id=${DN}    operation=${param_set['operation']}
        ...    parameters=&{dic_param_value}
        Append To List    ${sub_list_param_for_create_plan}    ${dic_param_for_create_plan}
        ${copy_of_status}    Set Variable    ${param_set['expect_status']}
        ${sub_expect_status}    Replace Variables    ${copy_of_status}
        ${expect_status}    Set Variable    ${expect_status};${sub_expect_status}
        Set To Dictionary    ${dic_param_for_create_plan}    expect_status=${sub_expect_status}
    END
    ${expect_status}    Set Variable    ${expect_status[1:].strip()}
    [Return]    ${expect_status}    ${sub_list_param_for_create_plan}

Get Parameters For NetAct Plan Due To Json File
    [Arguments]    ${json_path}    ${list_type}    ${scf_file_path}
    [Documentation]    Get parameters for KW "ta_netact_cm_editor.Create Managed Object" from parsed scf due to Json file.
    ...    The JSON file should be similar to /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}
    ...   /testdata/PremeterModifyTriggerAction/Multi/test_data.json
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    | Parameter | Man. | Description |
    ...    | ${json_path} | Yes | Path of JSON file |
    ...    | ${list_type} | Yes | Contains the keys in the JSON file, which will be used to generate parameters |
    ...    | ${scf_file_path} | Yes | SCF file path |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | ${expect_status} | String, describe the status of some MOs should appear after provision |
    ...    | ${list_param_for_create_plan} | List, parameters for KW "ta_netact_cm_editor.Create Managed Object" |
    ...
    ...    *EXAMPLE*
    ...    | ${expect_status} | ${list_param_for_create_plan} | Get Parameters For NetAct Plan Due To Json File |
    ...    ${TEST_DATA_FILE}
    ...    | ${SELECTED_TYPE} | ${BTS_scf_initial} |
    ...
    ...    ${TEST_DATA_FILE} = /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/
    ...    testdata/PremeterModifyTriggerAction/Multi/test_data.json
    ...
    ...    ${SELECTED_TYPE} = ['LTE_CELL_LOCK', 'GSM_RAT_RESET', 'WCDMA_RAT_RESET']
    ...
    ...    ${expect_status} = MRBTS-1896/LNBTS-3560/LNCEL-1:availabilityStatus:Offline MRBTS-1896/LNBTS-3560/LNCEL-1:
    ...   operationalState:Disabled MRBTS-1896/LNBTS-3560/LNCEL-2:availabilityStatus:Offline MRBTS-1896/LNBTS-3560/LNCEL-2:
    ...   operationalState:Disabled MRBTS-1896/LNBTS-3560/LNCEL-3:availabilityStatus:Offline MRBTS-1896/LNBTS-3560/LNCEL-3:
    ...    operationalState:Disabled \ RAT:gsm:ALL_DISABLED \ RAT:wcdma:ALL_DISABLED'
    ...
    ...    ${list_param_for_create_plan} = [{'meta_class': b'NOKLTE:LNCEL','meta_version': b'xL22R1_2107_200','mo_id':
    ...    b'MRBTS-1896/LNBTS-3560/LNCEL-1','operation': b'update','parameters': {b'allowPbIndexZero': b'true'}},
    ...    {'meta_class': b'NOKLTE:LNCEL','meta_version': b'xL22R1_2107_200','mo_id': b'MRBTS-1896/LNBTS-3560/LNCEL-2',
    ...    'operation': b'update','parameters': {b'allowPbIndexZero': b'false'}},
    ...    {'meta_class': b'NOKLTE:LNCEL','meta_version': b'xL22R1_2107_200','mo_id': b'MRBTS-1896/LNBTS-3560/LNCEL-3',
    ...    'operation': b'update','parameters': {b'allowPbIndexZero': b'true'}},
    ...    {'meta_class': b'com.nokia.srbts.gsm:GNBCF','meta_version': b'GSM21B_2101_001','mo_id': b'MRBTS-1896/GNBTS-1
    ...    /GNBCF-1','operation': b'update','parameters': {b'iuaAckTimerOmuSig': b'4'}},
    ...    {'meta_class': b'com.nokia.srbts.wcdma:WNBTS','meta_version': b'WCDMA21B_2105_001','mo_id':
    ...    b'MRBTS-1896/WNBTS-1','operation': b'update','parameters': {b'tti2msNonFdpchUserIncEnabled': b'true'}}]
    ${file_content}    OperatingSystem.Get File    ${json_path}
    ${test}    Evaluate    ${file_content}
    ${list_param_set_to_update}    Create List
    FOR    ${type}    IN    @{list_type}
        ${count}    Get Length    ${test["${type}"]}
        ${index}    Evaluate    random.randint(0, ${count-1})    modules=random, sys
        Append To List    ${list_param_set_to_update}    @{test["${type}"][${index}]}
    END
    LOG List    ${list_param_set_to_update}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${scf_file_path}
    ${expect_status}    Set Variable
    ${list_param_for_create_plan}    Create List
    FOR    ${dic_param}    IN    @{list_param_set_to_update}
        ${sub_expect_status}    ${sub_list_param_for_create_plan}    Get Parameter For NetAct Plan Due To TestData
        ...    ${scf_xml}    ${dic_param}
        ${expect_status}    Set Variable    ${expect_status};${sub_expect_status}
        Append To List    ${list_param_for_create_plan}    @{sub_list_param_for_create_plan}
    END
    ${expect_status}    Set Variable    ${expect_status[1:].strip()}
    [Return]    ${expect_status}    ${list_param_for_create_plan}

Get Value To Set
    [Arguments]    ${DN}    ${scf_xml}    ${param_set}
    [Documentation]    This keyword is called by keyword "Get Parameter For NetAct Plan Due To TestData" ,
    ...   not suitable for direct call
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ${list_param}    Get Dictionary Keys    ${param_set["parameters"]}
    ${dic_param_value}    Create Dictionary
    FOR    ${param}    IN    @{list_param}
        ${param_count}    L_XML.Get Element Count    ${scf_xml}    .//managedObject[@distName="${DN}"]/p[@name="${param}"]
        ${cur_value}    Run Keyword If    ${param_count}!=${0}    L_XML.Get Element Text    ${scf_xml}
        ...    .//managedObject[@distName="${DN}"]/p[@name="${param}"]
        ${cur_value}    Set Variable If    ${param_count}==${0}    ${EMPTY}    ${cur_value}
        Remove Values From List    ${param_set["parameters"]["${param}"]}    ${cur_value}
        ${count}    Get Length    ${param_set["parameters"]["${param}"]}
        ${index}    Evaluate    random.randint(0, ${count-1})    modules=random, sys
        ${value_to_set}    Set Variable    ${param_set["parameters"]["${param}"][${index}]}
        Set To Dictionary    ${dic_param_value}    ${param}=${value_to_set}
    END
    [Return]    ${dic_param_value}

Get BTS Key MOs Status
    [Arguments]    ${name_type}=SCF_NAME
    [Documentation]    Get key MOs configuration names or internal names and their statuses.
    ...    Return two dictionaries, first dictionary contains mapping of key MOs onfiguration
    ...    name and key MOs internal name, second dictionary contains key MOs statuses.
    ...    Key of dictionaries shall be configuration name if ${name_type} is 'SCF_NAME'
    ...    Key of dictionaries shall be internal name if ${name_type} is 'RUNTIME_NAME'
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Man. | Description |
    ...    | name_type | No | Keys of dictionaries is configuration name or internal name, default vaule is SCF_NAME |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | ret_mapping | Dictionary contains mapping of key MOs onfiguration name and key MOs internal name |
    ...    | ret_status | Dictionary contains key MOs statuses |
    ...
    ...    *EXAMPLE*
    ...    | ${scf_runtime_name_mapper} | ${dic_bts_infor} | Get BTS BTS Key MOs Status |
    ...
    ...    ${scf_runtime_name_mapper} = {
    ...    'bbmod': {
    ...    'MRBTS-1896/EQM-1/APEQM-1/CABINET-1/BBMOD-1':
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-2',
    ...    'MRBTS-1896/EQM-1/APEQM-1/CABINET-1/BBMOD-2':
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1'
    ...    },
    ...    'cell': {
    ...    'MRBTS-1896/GNBTS-1/GNBCF-1/GNCEL-1':
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_CONF_M-1/GNCEL_R-1',
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-1': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-3560/LNCEL_R-1',
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-2': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-3560/LNCEL_R-2',
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-3': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-3560/LNCEL_R-3',
    ...    'MRBTS-1896/WNBTS-1/WNCEL-18961': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-18961',
    ...    'MRBTS-1896/WNBTS-1/WNCEL-18962': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-18962',
    ...    'MRBTS-1896/WNBTS-1/WNCEL-18963': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-18963'
    ...    },
    ...    'rmod': {
    ...    'MRBTS-1896/EQM-1/APEQM-1/RMOD-1': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-3',
    ...    'MRBTS-1896/EQM-1/APEQM-1/RMOD-2': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1',
    ...    'MRBTS-1896/EQM-1/APEQM-1/RMOD-3': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2'
    ...    },
    ...    'site': {
    ...    'MRBTS-1896': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1'
    ...    },
    ...    'smod': {
    ...    'MRBTS-1896/EQM-1/APEQM-1/CABINET-1/SMOD-1':
    ...   '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-2',
    ...    'MRBTS-1896/EQM-1/APEQM-1/CABINET-1/SMOD-2':
    ...    '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1'
    ...    }
    ...    }
    ...
    ...    ${dic_bts_infor} = {
    ...    'bbmod': {
    ...    'MRBTS-1896/EQM-1/APEQM-1/CABINET-1/BBMOD-1': {
    ...    'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online',
    ...    'operationalState': 'Enabled',
    ...    'proceduralStatus': 'configured'
    ...    },
    ...    'MRBTS-1896/EQM-1/APEQM-1/CABINET-1/BBMOD-2': {
    ...    'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online',
    ...    'operationalState': 'Enabled',
    ...    'proceduralStatus': 'configured'
    ...    }
    ...    },
    ...    'cell': {
    ...    'MRBTS-1896/GNBTS-1/GNBCF-1/GNCEL-1': {
    ...    'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online',
    ...    'blockingState': 'Unblocked',
    ...    'operationalState': 'Enabled'
    ...    },
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-1': {
    ...    'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online',
    ...    'blockingState': 'Unblocked',
    ...    'operationalState': 'Enabled'
    ...    },
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-2': {
    ...    'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online',
    ...    'blockingState': 'Unblocked',
    ...    'operationalState': 'Enabled'
    ...    },
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-3': {
    ...    'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online',
    ...    'blockingState': 'Unblocked',
    ...    'operationalState': 'Enabled'
    ...    },
    ...    'MRBTS-1896/WNBTS-1/WNCEL-18961': {
    ...    'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online',
    ...    'blockingState': 'Unblocked',
    ...    'operationalState': 'Enabled'
    ...    },
    ...    'MRBTS-1896/WNBTS-1/WNCEL-18962': {
    ...    'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online',
    ...    'blockingState': 'Unblocked',
    ...    'operationalState': 'Enabled'
    ...    },
    ...    'MRBTS-1896/WNBTS-1/WNCEL-18963': {
    ...    'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online',
    ...    'blockingState': 'Unblocked',
    ...    'operationalState': 'Enabled'
    ...    }
    ...    },
    ...    'rat': {
    ...    'gsm': 'ALL_ENABLED',
    ...    'lte': 'ALL_ENABLED',
    ...    'nr': 'NO_CELLS',
    ...    'wcdma': 'ALL_ENABLED'
    ...    },
    ...    'rmod': {
    ...    'MRBTS-1896/EQM-1/APEQM-1/RMOD-1': {
    ...    'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online',
    ...    'operationalState': 'Enabled',
    ...    'proceduralStatus': 'configured'
    ...    },
    ...    'MRBTS-1896/EQM-1/APEQM-1/RMOD-2': {
    ...    'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online',
    ...    'operationalState': 'Enabled',
    ...    'proceduralStatus': 'configured'
    ...    },
    ...    'MRBTS-1896/EQM-1/APEQM-1/RMOD-3': {
    ...    'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online',
    ...    'operationalState': 'Enabled',
    ...    'proceduralStatus': 'configured'
    ...    }
    ...    },
    ...    'site': {
    ...    'MRBTS-1896': {
    ...    'blockingState': 'Unblocked',
    ...    'operationalState': 'Enabled',
    ...    'proceduralState': 'OnAir'
    ...    }
    ...    },
    ...    'smod': {
    ...    'MRBTS-1896/EQM-1/APEQM-1/CABINET-1/SMOD-1': {
    ...    'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online',
    ...    'operationalState': 'Enabled',
    ...    'proceduralStatus': 'configured'
    ...    },
    ...    'MRBTS-1896/EQM-1/APEQM-1/CABINET-1/SMOD-2': {
    ...    'administrativeState': 'Unlocked',
    ...    'availabilityStatus': 'Online',
    ...    'operationalState': 'Enabled',
    ...    'proceduralStatus': 'configured'
    ...    }
    ...    }
    ...    }
    ${dic_bts_infor}    coam.Get Bts Info
    ${ignore_status}    Create List    usageState
    ${dic_rat_status}    Pop From Dictionary    ${dic_bts_infor}    ratState
    ${name_type_mapper}    Create Dictionary    SCF_NAME=configuration    RUNTIME_NAME=internal
    ${name_type}    Pop From Dictionary    ${name_type_mapper}    ${name_type}
    ${value_list}    Get Dictionary Values    ${name_type_mapper}
    ${value_type}    Set Variable    ${value_list[0]}
    ${dic_site_mapping}    Create Dictionary    ${dic_bts_infor["id"]["${name_type}"]}
    ...    ${dic_bts_infor["id"]["${value_type}"]}
    Convert Status According To CNI61110    ${dic_bts_infor["status"]}
    Remove From Dictionary    ${dic_bts_infor["status"]}    availabilityStatus
    ${site_status}    Create Dictionary    ${dic_bts_infor["id"]["${name_type}"]}    ${dic_bts_infor["status"]}
    ${dic_bbmod_mapping}    Create Dictionary
    ${dic_bbmod_status}    Create Dictionary
    ${list_bbmod_info}    Pop From Dictionary    ${dic_bts_infor}    basebandModules
    FOR    ${info}    IN    @{list_bbmod_info}
        Set To Dictionary    ${dic_bbmod_mapping}    ${info["id"]["${name_type}"]}    ${info["id"]["${value_type}"]}
        Remove From Dictionary    ${info["status"]}    @{ignore_status}
        Convert Status According To CNI61110    ${info["status"]}
        Set To Dictionary    ${dic_bbmod_status}    ${info["id"]["${name_type}"]}    ${info["status"]}
    END
    ${dic_smod_mapping}    Create Dictionary
    ${dic_smod_status}    Create Dictionary
    ${list_smod_info}    Pop From Dictionary    ${dic_bts_infor}    systemModules
    FOR    ${info}    IN    @{list_smod_info}
        Set To Dictionary    ${dic_smod_mapping}    ${info["id"]["${name_type}"]}    ${info["id"]["${value_type}"]}
        Remove From Dictionary    ${info["status"]}    @{ignore_status}
        Convert Status According To CNI61110    ${info["status"]}
        Set To Dictionary    ${dic_smod_status}    ${info["id"]["${name_type}"]}    ${info["status"]}
    END
    ${dic_rmod_mapping}    Create Dictionary
    ${dic_rmod_status}    Create Dictionary
    ${list_rmod_info}    Set Variable    ${dic_bts_infor['radioModules']["rmod"]}
    FOR    ${info}    IN    @{list_rmod_info}
        Set To Dictionary    ${dic_rmod_mapping}    ${info["id"]["${name_type}"]}    ${info["id"]["${value_type}"]}
        Remove From Dictionary    ${info["status"]}    @{ignore_status}
        Convert Status According To CNI61110    ${info["status"]}
        Set To Dictionary    ${dic_rmod_status}    ${info["id"]["${name_type}"]}    ${info["status"]}
    END
    ${empty_list}    Create List
    ${GSM_cells}    Pop From Dictionary    ${dic_bts_infor['cells']}    gsm    ${empty_list}
    ${WCDMA_cells}    Pop From Dictionary    ${dic_bts_infor['cells']}    wcdma    ${empty_list}
    ${LTE_cells}    Pop From Dictionary    ${dic_bts_infor['cells']}    lte    ${empty_list}
    ${NR_cells}    Pop From Dictionary    ${dic_bts_infor['cells']}    nr    ${empty_list}
    ${cell_mapper}    Create Dictionary
    ${all_cell_status}    Create Dictionary
    FOR    ${cell}    IN    @{GSM_cells}
        ${tmp_dic}    Create Dictionary
        Set To Dictionary    ${cell_mapper}    ${cell['id']['${name_type}']}    ${cell['id']['${value_type}']}
        Remove From Dictionary    ${cell['status']}    @{ignore_status}
        Convert Status According To CNI61110    ${cell['status']}
        Set To Dictionary    ${all_cell_status}    ${cell['id']['${name_type}']}    ${cell['status']}
    END
    FOR    ${cell}    IN    @{WCDMA_cells}
        ${tmp_dic}    Create Dictionary
        Set To Dictionary    ${cell_mapper}    ${cell['id']['${name_type}']}    ${cell['id']['${value_type}']}
        ${w_cell_administrator_state}    Pop From Dictionary    ${cell['status']}    administrativeState    NotKnown
        Run Keyword If    "${w_cell_administrator_state}"=="NotKnown"    Set To Dictionary    ${cell['status']}
        ...    administrativeState    Unlocked
        Remove From Dictionary    ${cell['status']}    @{ignore_status}
        Convert Status According To CNI61110    ${cell['status']}
        Set To Dictionary    ${all_cell_status}    ${cell['id']['${name_type}']}    ${cell['status']}
    END
    FOR    ${cell}    IN    @{LTE_cells}
        ${tmp_dic}    Create Dictionary
        Set To Dictionary    ${cell_mapper}    ${cell['id']['${name_type}']}    ${cell['id']['${value_type}']}
        Remove From Dictionary    ${cell['status']}    @{ignore_status}
        Convert Status According To CNI61110    ${cell['status']}
        Set To Dictionary    ${all_cell_status}    ${cell['id']['${name_type}']}    ${cell['status']}
    END
    FOR    ${cell}    IN    @{NR_cells}
        ${tmp_dic}    Create Dictionary
        Set To Dictionary    ${cell_mapper}    ${cell['id']['${name_type}']}    ${cell['id']['${value_type}']}
        Remove From Dictionary    ${cell['status']}    @{ignore_status}
        Convert Status According To CNI61110    ${cell['status']}
        Set To Dictionary    ${all_cell_status}    ${cell['id']['${name_type}']}    ${cell['status']}
    END
    ${ret_mapping}    Create Dictionary    site    ${dic_site_mapping}    bbmod    ${dic_bbmod_mapping}    smod
    ...    ${dic_smod_mapping}    rmod    ${dic_rmod_mapping}    cell    ${cell_mapper}
    ${ret_status}    Create Dictionary    site    ${site_status}    bbmod    ${dic_bbmod_status}    smod
    ...    ${dic_smod_status}    rmod    ${dic_rmod_status}    cell    ${all_cell_status}    rat
    ...    ${dic_rat_status}
    LOG Dictionary    ${ret_mapping}
    LOG Dictionary    ${ret_status}
    ${gNbCuType}    Pop From Dictionary    ${ret_status}    gNbCuType    SA
    Set Test Variable    ${GNB_CU_TYPE}    ${gNbCuType}
    [Return]    ${ret_mapping}    ${ret_status}

Remove Duplicates From Dictionaries
    [Arguments]    ${dic_1}    ${dic_2}
    [Documentation]    Remove the items which in both dic_1 and dic_2
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ${keys1}    Get Dictionary Keys    ${dic_1}
    ${keys2}    Get Dictionary Keys    ${dic_2}
    FOR    ${key}    IN    @{keys1}
        ${is_contain}    Run Keyword And Return Status    Dictionary Should Contain Item    ${dic_2}    ${key}
        ...    ${dic_1["${key}"]}
        Continue For Loop If    not ${is_contain}
        Remove From Dictionary    ${dic_2}    ${key}
        Remove From Dictionary    ${dic_1}    ${key}
    END
    FOR    ${key}    IN    @{keys2}
        ${is_contain}    Run Keyword And Return Status    Dictionary Should Contain Item    ${dic_1}    ${key}
        ...    ${dic_2["${key}"]}
        Continue For Loop If    not ${is_contain}
        Remove From Dictionary    ${dic_2}    ${key}
        Remove From Dictionary    ${dic_1}    ${key}
    END

Remove Duplicates From Bistratal Dictionaries
    [Arguments]    ${dic_1}    ${dic_2}
    [Documentation]    Remove the items which in both dic_1 and dic_2.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    Remove Duplicates From Dictionaries    ${dic_1}    ${dic_2}
    LOG Dictionary    ${dic_1}
    LOG Dictionary    ${dic_2}
    ${key1}    Get Dictionary Keys    ${dic_1}
    ${key2}    Get Dictionary Keys    ${dic_2}
    ${keys}    Combine Lists    ${key1}    ${key2}
    ${keys}    Remove Duplicates    ${keys}
    FOR    ${key}    IN    @{keys}
        ${not_contain1}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${dic_1}    ${key}
        ${not_contain2}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${dic_2}    ${key}
        Continue For Loop If    ${not_contain1} or ${not_contain2}
        Remove Duplicates From Dictionaries    ${dic_1["${key}"]}    ${dic_2["${key}"]}
    END
    LOG Dictionary    ${dic_1}
    LOG Dictionary    ${dic_2}

Get Current BTS Key MOs Status Changes
    [Arguments]    ${bts_infor_to_compare}    ${name_type}=SCF_NAME
    [Documentation]    Get Current BTS Key MOs Status and compare with ${bts_infor_to_compare} , return the differences.
    ...    ${bts_infor_to_compare} Could be get from keyword "Get BTS BTS Key MOs Status"
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Man. | Description |
    ...    | bts_infor_to_compare | Yes | BTS Key MOs Status to be compared |
    ...    | name_type | No | Keys of dictionaries is configuration name or internal name, default vaule is SCF_NAME |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | bts_infor_cur | Dictionary contains current BTS key MOs statuses |
    ...    | bts_infor|Dictionary contains BTS key MOs statuses of bts_infor_to_compare which different from currently|
    ...    | bts_infor1 | Dictionary contains BTS key MOs statuses currently which different from bts_infor_to_compare|
    ...
    ...    *EXAMPLE*
    ...    | ${dic_mapping} | ${dic_all_status} | Get BTS BTS Key MOs Status | SCF_NAME |
    ...    | ${cur_bts_infor} | ${diff_bts_infor1} | ${diff_bts_infor2} | Get Current BTS Key MOs Status Changes |
    ...    ${dic_all_status} | ${name_type} |
    ...
    ...    ${diff_bts_infor1} = {'bbmod': {},
    ...    'cell': {'MRBTS-1896/LNBTS-3560/LNCEL-1': {'availabilityStatus': 'Online','operationalState': 'Enabled'},
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-2': {'availabilityStatus': 'Online','operationalState': 'Enabled'}},
    ...    'rat': {'lte': 'PARTIALLY_DISABLED'},
    ...    'rmod': {},
    ...    'site': {'MRBTS-1896': {'operationalState': 'Enabled','proceduralState': 'OnAir'}},
    ...    'smod': {}}
    ...
    ...    ${diff_bts_infor2} = {'bbmod': {},
    ...    'cell': {'MRBTS-1896/LNBTS-3560/LNCEL-1': {'availabilityStatus': 'Offline','operationalState': 'Disabled'},
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-2': {'availabilityStatus': 'Offline','operationalState': 'Disabled'}},
    ...    'rat': {'lte': 'ALL_DISABLED'},
    ...    'rmod': {},
    ...    'site': {'MRBTS-1896': {'operationalState': 'Disabled','proceduralState': 'IntegratedToRan'}},
    ...    'smod': {}}
    ${empty_dic}    Create Dictionary
    ${bts_infor}    Copy Dictionary    ${bts_infor_to_compare}    ${True}
    ${dic_mapping1}    ${bts_infor_cur}    Get BTS Key MOs Status    ${name_type}
    ${bts_infor1}    Copy Dictionary    ${bts_infor_cur}    ${True}
    ${is_all_equal}    Run Keyword And Return Status    Dictionaries Should Be Equal    ${bts_infor}    ${bts_infor1}
    Return From Keyword If    ${is_all_equal}    ${bts_infor_cur}    ${empty_dic}    ${empty_dic}
    Remove Duplicates From Dictionaries    ${bts_infor["rat"]}    ${bts_infor1["rat"]}
    ${types}    Create List    bbmod    cell    rmod    site    smod
    FOR    ${type}    IN    @{types}
        Remove Duplicates From Bistratal Dictionaries    ${bts_infor["${type}"]}    ${bts_infor1["${type}"]}
    END
    LOG Dictionary    ${bts_infor}
    LOG Dictionary    ${bts_infor1}
    [Return]    ${bts_infor_cur}    ${bts_infor}    ${bts_infor1}

Check BTS Key MOs Status All Online
    [Arguments]    ${dic_all_status}    ${dic_state_fields}=${None}
    [Documentation]    Check whether all current BTS Key MOs online.
    ...    ${dic_all_status} Could be get from keyword "Get BTS BTS Key MOs Status"
    ...    ${dic_state_fields} to define standard of online, it will be {'availabilityStatus'='Online',
    ...    'operationalState'='Enabled','administrativeState'='Unlocked'} by default
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Man. | Description |
    ...    | dic_all_status | Yes | BTS Key MOs Status to be checked |
    ...    | dic_state_fields | No | dictionary, define standard of online |
    ...
    ...    *EXAMPLE*
    ...    | ${dic_mapping} | ${cur_bts_infor} | Get BTS BTS Key MOs Status |
    ...    | Check BTS Key MOs Status All Online | ${cur_bts_infor} |
    ${types}    Create List    bbmod    cell    rmod    smod
    ${empty_dic}    Create Dictionary
    ${dic_offline_status}    Create Dictionary
    ${all_rats}    Get Dictionary Keys    ${dic_all_status['rat']}
    FOR    ${rat}    IN    @{all_rats}
        Continue For Loop If
        ...    "${dic_all_status['rat']['${rat}']}"=="ALL_ENABLED" or "${dic_all_status['rat']['${rat}']}"=="NO_CELLS"
        Set To Dictionary    ${dic_offline_status}    rat    ${dic_all_status['rat']}
        Exit For Loop
    END
    ${dic_site_status}    Copy Dictionary    ${dic_all_status['site']}    ${True}
    ${site_status}    Get Dictionary Values    ${dic_site_status}
    ${online_status_standard}    Evaluate
    ...    {"blockingState": "Unblocked","operationalState": "Enabled","proceduralState": "OnAir"}
    Convert Status According To CNI61110    ${online_status_standard}
    Remove Duplicates From Dictionaries    ${online_status_standard}    ${site_status[0]}
    Run Keyword If    "${site_status[0].__len__()}"!="0"    Set To Dictionary
    ...    ${dic_offline_status}    site    ${site_status[0]}
    FOR    ${type}    IN    @{types}
        ${MOs_states_unexpected}    Check MOs Status As Expected    ${dic_all_status['${type}']}    ${dic_state_fields}
        ${no_unexpected}    Run Keyword And Return Status    Should Be Empty    ${MOs_states_unexpected}
        Continue For Loop If    ${no_unexpected}
        Set To Dictionary    ${dic_offline_status}    ${type}    ${MOs_states_unexpected}
    END
    Should Be Empty    ${dic_offline_status}    Some MO(s) is not online.

Check MOs Status As Expected
    [Arguments]    ${all_MO_status}    ${dic_state_fields}=${None}
    [Documentation]    Check MOs States As Expected. Return an empty dictionary when all MOs status are as expected,
    ...                      otherwise ,return the unexpected.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    | Parameter | Man. | Description |
    ...    | ${all_MO_status} | Yes | states of all MOs |
    ...    | ${dic_state_fields} | No |
    ...     Default is {'availabilityStatus': 'Online', 'operationalState': 'Enabled'} while given value is ${None} |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | ${MOs_states_unexpected} | dictionary, unexpected different states |
    ...
    ...    *EXAMPLE*
    ${default_dic_state_fields}    Create Dictionary    availabilityStatus=Online    operationalState=Enabled
    ...    administrativeState=Unlocked
    Convert Status According To CNI61110    ${default_dic_state_fields}
    ${dic_state_fields}    Set Variable If    ${dic_state_fields} is None    ${default_dic_state_fields}
    ...    ${dic_state_fields}
    ${MOs}    Get Dictionary Keys    ${all_MO_status}
    ${MOs_states_unexpected}    Create Dictionary
    FOR    ${MO}    IN    @{MOs}
        ${is_as_expected}    Run Keyword And Return Status
        ...    Dictionary Should Contain Sub Dictionary    ${all_MO_status["${MO}"]}    ${default_dic_state_fields}
        Continue For Loop If    ${is_as_expected}
        Set To Dictionary    ${MOs_states_unexpected}    ${MO}=${all_MO_status["${MO}"]}
    END
    [Return]    ${MOs_states_unexpected}

Check BTS Key MOs Status Changed As Expected
    [Arguments]    ${expected_status}    ${diff_bts_infor}
    [Documentation]    Check whether the changes of BTS Key MOs as expected.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Man. | Description |
    ...    | expected_status | Yes | String, describe the status of some MOs should appear after provision |
    ...    | diff_bts_infor | Yes | dictionary, can get from keyword 'Get Current BTS Key MOs Status Changes' |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | not_achieve_status | Sub string of expected_status those not achieved |
    ...
    ...    *EXAMPLE*
    ...    | ${dic_mapping} | ${cur_bts_infor} | Get BTS BTS Key MOs Status |
    ...    | ${cur_bts_infor} | ${diff_bts_infor1} | ${diff_bts_infor2} | Get Current BTS Key MOs Status Changes
    ...                                                                 | ${cur_bts_infor} |
    ...    | ${not_achieve_status}|Check BTS Key MOs Status Changed As Expected|${expected_status}|${diff_bts_infor2}|
    ...
    ...    ${expected_status} = MRBTS-1896/LNBTS-3560/LNCEL-1:availabilityStatus:Offline;MRBTS-1896/LNBTS-3560/LNCEL-1:
    ...    operationalState:Disabled;MRBTS-1896/LNBTS-3560/LNCEL-2:availabilityStatus:Offline;MRBTS-1896/LNBTS-3560/LNCEL-2
    ...   :operationalState:Disabled;MRBTS-1896/LNBTS-3560/LNCEL-3:availabilityStatus:Offline;MRBTS-1896/LNBTS-3560/LNCEL-3:
    ...   operationalState:Disabled;RAT:gsm:ALL_DISABLED;RAT:wcdma:ALL_DISABLED
    ...
    ...    ${diff_bts_infor2} = {'bbmod': {},'cell': {'MRBTS-1896/LNBTS-3560/LNCEL-1': {'availabilityStatus': 'Offline'
    ...    ,'operationalState': 'Disabled'},'MRBTS-1896/LNBTS-3560/LNCEL-2': {'availabilityStatus': 'Offline',
    ...    'operationalState':
    ...    'Disabled'},'MRBTS-1896/LNBTS-3560/LNCEL-3': {'availabilityStatus': 'Offline','operationalState': 'Disabled'}},
    ...    'rat': {'lte': 'ALL_DISABLED'},'rmod': {},'site': {},'smod': {}}
    ...
    ...    ${not_achieve_status} = 'RAT:gsm:ALL_DISABLED \ RAT:wcdma:ALL_DISABLED'
    LOG    ${diff_bts_infor}    console=${True}
    LOG    expected_status is ${expected_status}    console=${True}
    ${is_achieve}    Set Variable    ${True}
    ${not_achieve_status}    Set Variable    ${expected_status}
    #${type_MO_mapper} define type of Key MOs
    ${tmp_str1}    Set Variable    "BBMOD":"bbmod","RMOD":"rmod","SMOD":"smod","RAT":"rat","MRBTS":"site",
    ${tmp_str2}    Set Variable    "NRCELL":"cell","LNCEL":"cell","WNCEL":"cell","GNCEL":"cell"
    ${type_MO_mapper}    Evaluate    {${tmp_str1}${tmp_str2}}
    ${all_filters}    Split String    ${expected_status}    ;
    FOR    ${filter}    IN    @{all_filters}
        Continue For Loop If    '${filter.strip()}'==''
        ${p_list}    Split String    ${filter}    :
        ${MO}    ${param}    ${value}    Set Variable    ${p_list[0]}    ${p_list[1]}
        ...    ${p_list[2]}
        ${type_str}    Set Variable    ${MO.split('/')[-1].split('-')[0].split('_')[0].strip()}
        ${type}    Get From Dictionary    ${type_MO_mapper}    ${type_str}
        ${is_contain_type}    ${cur_status}    Run Keyword And Ignore Error    Set Variable If    "${type}"=="rat"
        ...    ${diff_bts_infor["${type}"]}
        ...    ${diff_bts_infor["${type}"]["${MO}"]}
        Continue For Loop If    "${is_contain_type}"=="FAIL"    #Ignore if MO is not type of key MOs
        ${s_val_upper}    Convert To Upper Case    ${value}
        ${s_val_upper_no_space}    Remove String Using Regexp    ${s_val_upper}    \\s+
        ${is_contian_status}    Run Keyword And Return Status    Dictionary Should Contain Item    ${cur_status}
        ...    ${param}    ${s_val_upper_no_space}
        Continue For Loop If    not ${is_contian_status}
        ${not_achieve_status}    Remove String Using Regexp    ${not_achieve_status}    ${filter}(;*)
        LOG    Removed filter:${filter}, rest: ${not_achieve_status}    console=${True}
    END
    [Return]    ${not_achieve_status}

Get BTS Key MOs Status Duration Until Expected Changes
    [Arguments]    ${expected_status}    ${retry}=300    ${interval}=1    ${name_type}=SCF_NAME
    [Documentation]   Get the changes until the expected change of MO(s) happens. Fail if it has not happens in retiry time.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Man. | Description |
    ...    | expected_status | Yes | String, describe the status of some MOs should appear after provision |
    ...    | retry | No | Number of retries |
    ...    | interval | No | The interval between retries, in seconds |
    ...    | name_type | No | Keys of dictionaries is configuration name or internal name, default vaule is SCF_NAME |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | list_record_of_change | List of dictionary, dictionary contains changes of BTS key MOs statuses |
    ...
    ...    *EXAMPLE*
    ...    | ${list_record_of_change1} | Get BTS Key MOs Status Duration Until Expected Changes | ${EXPECT_STATUS} |
    ...
    ...    ${EXPECT_STATUS} = "MRBTS-1896/LNBTS-3560/LNCEL-1:availabilityStatus:Offline MRBTS-1896/LNBTS-3560/LNCEL-1:
    ...    operationalState:Disabled MRBTS-1896/LNBTS-3560/LNCEL-2:availabilityStatus:Offline
    ...    MRBTS-1896/LNBTS-3560/LNCEL-2:operationalState:Disabled MRBTS-1896/LNBTS-3560/LNCEL-3:availabilityStatus:
    ...    Offline MRBTS-1896/LNBTS-3560/LNCEL-3:operationalState:Disabled \ RAT:gsm:ALL_DISABLED \RAT:wcdma:ALL_DISABLED"
    ...
    ...    ${list_record_of_change} = [{'bbmod': {},
    ...    'cell': {'MRBTS-1896/LNBTS-3560/LNCEL-1': {'availabilityStatus': 'Offline','operationalState': 'Disabled'},
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-2': {'availabilityStatus': 'Offline','operationalState': 'Disabled'},
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-3': {'availabilityStatus': 'Offline','operationalState': 'Disabled'}},
    ...    'rat': {'lte': 'ALL_DISABLED'},
    ...    'rmod': {},
    ...    'site': {},
    ...    'smod': {}
    ...    },
    ...    {'bbmod': {},
    ...    'cell': {'MRBTS-1896/GNBTS-1/GNBCF-1/GNCEL-1': {'availabilityStatus': 'Offline','operationalState':'Disabled'}},
    ...    'rat': {'gsm': 'ALL_DISABLED'},
    ...    'rmod': {},
    ...    'site': {},
    ...    'smod': {}
    ...    },{'bbmod': {},
    ...    'cell': {
    ...    'MRBTS-1896/WNBTS-1/WNCEL-18962': {'availabilityStatus': 'Offline','operationalState': 'Disabled'}},
    ...    'rat': {'wcdma': 'PARTIALLY_DISABLED'},
    ...    'rmod': {},
    ...    'site': {},
    ...    'smod': {}
    ...    },{
    ...    'bbmod': {},
    ...    'cell': {'MRBTS-1896/WNBTS-1/WNCEL-18961': {'availabilityStatus': 'Offline','operationalState': 'Disabled'},
    ...    'MRBTS-1896/WNBTS-1/WNCEL-18963': {'availabilityStatus': 'Offline','operationalState': 'Disabled'}},
    ...    'rat': {'wcdma': 'ALL_DISABLED'},
    ...    'rmod': {},
    ...    'site': {'MRBTS-1896': {'operationalState': 'Disabled','proceduralState': 'IntegratedToRan'}},
    ...    'smod': {}}]
    LOG    Get BTS Key MOs Status Duration Until Expected Status START    console=${True}
    ${dic_mapping}    ${cur_bts_infor}    Get BTS Key MOs Status    ${name_type}
    Sleep    ${interval}
    ${list_record_of_change}    Create List
    FOR    ${step}    IN RANGE    0    ${retry}
        Exit For Loop If    "${expected_status.strip()}"==""
        ${cur_bts_infor}    ${diff_bts_infor1}    ${diff_bts_infor2}
        ...    Get Current BTS Key MOs Status Changes    ${cur_bts_infor}    ${name_type}
        Sleep    ${interval}
        Continue For Loop If    "${diff_bts_infor2.__len__()}"=="0"
        Append To List    ${list_record_of_change}    ${diff_bts_infor2}
        ${not_achieve_status}    Check BTS Key MOs Status Changed As Expected    ${expected_status}    ${diff_bts_infor2}
        ${expected_status}    Set Variable    ${not_achieve_status.strip()}
    END
    LOG    Get BTS Key MOs Status Duration Until Expected Status END    console=${True}
    Should Be Empty    ${expected_status}    Some status is not achieved.
    LOG List    ${list_record_of_change}
    [Return]    ${list_record_of_change}

Get BTS Key MOs Status Duration Until All Online
    [Arguments]    ${retry}=300    ${interval}=1    ${name_type}=SCF_NAME    ${dic_state_fields}=${None}
    [Documentation]    Get the changes until the all BTS key MOs online,
    ...    fail if not all BTS key MOs online after retries. ${dic_state_fields} to define standard of online,
    ...    it will be {'availabilityStatus'='Online','operationalState'='Enabled','administrativeState'='Unlocked'}
    ...    by default
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Man. | Description |
    ...    | retry | No | Number of retries |
    ...    | interval | No | The interval between retries, in seconds |
    ...    | name_type | No | Keys of dictionaries is configuration name or internal name, default vaule is SCF_NAME |
    ...    | dic_state_fields | No | dictionary, define standard of online |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | list_record_of_change | List of dictionary, dictionary contains changes of BTS key MOs statuses |
    ...
    ...    *EXAMPLE*
    ...    | ${list_record_of_change1} | Get BTS Key MOs Status Duration Until All Online |
    ...
    ...    ${list_record_of_change} = [ {'bbmod': {},
    ...    'cell': {'MRBTS-1896/LNBTS-3560/LNCEL-1': {'availabilityStatus': 'Offline','operationalState': 'Disabled'},
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-2': {'availabilityStatus': 'Offline','operationalState': 'Disabled'},
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-3': {'availabilityStatus': 'Offline','operationalState': 'Disabled'}},
    ...    'rat': {'lte': 'ALL_DISABLED'},
    ...    'rmod': {},
    ...    'site': {},
    ...    'smod': {}},
    ...    {'bbmod': {},
    ...    'cell': {'MRBTS-1896/GNBTS-1/GNBCF-1/GNCEL-1': {'availabilityStatus':'Offline','operationalState':'Disabled'}},
    ...    'rat': {'gsm': 'ALL_DISABLED'},
    ...    'rmod': {},
    ...    'site': {},
    ...    'smod': {}},
    ...    {'bbmod': {},
    ...    'cell': {'MRBTS-1896/WNBTS-1/WNCEL-18962': {'availabilityStatus': 'Offline','operationalState': 'Disabled'}},
    ...    'rat': {'wcdma': 'PARTIALLY_DISABLED'},
    ...    'rmod': {},
    ...    'site': {},
    ...    'smod': {}},
    ...    {'bbmod': {},
    ...    'cell': {'MRBTS-1896/WNBTS-1/WNCEL-18961': {'availabilityStatus': 'Offline','operationalState': 'Disabled'},
    ...    'MRBTS-1896/WNBTS-1/WNCEL-18963': {'availabilityStatus': 'Offline','operationalState': 'Disabled'}},
    ...    'rat': {'wcdma': 'ALL_DISABLED'},
    ...    'rmod': {},
    ...    'site': {'MRBTS-1896': {'operationalState': 'Disabled','proceduralState': 'IntegratedToRan'}},
    ...    'smod': {}}]
    LOG    Get BTS Key MOs Status Duration Until All Online START.    console=${True}
    ${dic_mapping}    ${cur_bts_infor}    Get BTS Key MOs Status    ${name_type}
    ${list_record_of_change}    Create List
    FOR    ${step}    IN RANGE    0    ${retry}
        ${as_expected}    Run Keyword And Return Status
        ...    Check BTS Key MOs Status All Online    ${cur_bts_infor}    ${dic_state_fields}
        Exit For Loop If    ${as_expected}
        ${cur_bts_infor}    ${diff_bts_infor1}    ${diff_bts_infor2}
        ...    Get Current BTS Key MOs Status Changes    ${cur_bts_infor}    ${name_type}
        Run Keyword If    "${diff_bts_infor2.__len__()}"!="0"
        ...    Append To List    ${list_record_of_change}    ${diff_bts_infor2}
        Sleep    ${interval}
    END
    LOG    Get BTS Key MOs Status Duration Until All Online END.    console=${True}
    LOG List    ${list_record_of_change}
    Should Be True    ${as_expected}    Some MO(s) is not online.
    [Return]    ${list_record_of_change}

Combine Changes Of BTS Key MOs Status
    [Arguments]    ${list_record_of_change}
    [Documentation]    Convert the list of BTS key MOs status change to a dictionary
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Man. | Description |
    ...    | list_record_of_change | Yes | List of BTS key MOs status change. |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...    | dic_Key_MOs_status_duration | Dictionary contains changes of BTS key MOs statuses |
    ...
    ...    *EXAMPLE*
    ...    | ${dic_key_MOs_status_duration} | Combine Changes Of BTS Key MOs Status | ${list_record_of_change} |
    ...
    ...    ${list_record_of_change} = [{'bbmod': {},
    ...    'cell': {'MRBTS-1896/LNBTS-3560/LNCEL-1': {'availabilityStatus': 'Offline','operationalState': 'Disabled'},
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-2': {'availabilityStatus': 'Offline','operationalState': 'Disabled'},
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-3': {'availabilityStatus': 'Offline','operationalState': 'Disabled'}},
    ...    'rat': {'lte': 'ALL_DISABLED'},
    ...    'rmod': {},
    ...    'site': {},
    ...    'smod': {}},
    ...    {'bbmod': {},
    ...    'cell': {'MRBTS-1896/GNBTS-1/GNBCF-1/GNCEL-1': {'availabilityStatus':'Offline','operationalState':'Disabled'}},
    ...    'rat': {'gsm': 'ALL_DISABLED'},
    ...    'rmod': {},
    ...    'site': {},
    ...    'smod': {}}]
    ...
    ...    ${dic_key_MOs_status_duration} = {'bbmod': {},
    ...    'cell': {'MRBTS-1896/LNBTS-3560/LNCEL-1': {'availabilityStatus': 'Offline','operationalState': 'Disabled'},
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-2': {'availabilityStatus': 'Offline','operationalState': 'Disabled'},
    ...    'MRBTS-1896/LNBTS-3560/LNCEL-3': {'availabilityStatus': 'Offline','operationalState': 'Disabled'},
    ...    'MRBTS-1896/GNBTS-1/GNBCF-1/GNCEL-1': {'availabilityStatus': 'Offline','operationalState': 'Disabled'}},
    ...    'rat': {'lte': 'ALL_DISABLED','gsm': 'ALL_DISABLED'},
    ...    'rmod': {},
    ...    'site': {},
    ...    'smod': {}}
    ${dic_Key_MOs_status_duration}    Create Dictionary
    ${dic_Key_MOs_status_duration}    Evaluate    {"site": [],"bbmod": [],"smod": [],"rmod": [],"rat": [],"cell": []}
    ${type}    Set Variable    bbmod
    FOR    ${record_of_change}    IN    @{list_record_of_change}
        Run Keyword If    '${record_of_change["${type}"].__len__()}'!='0'
        ...    Append To List    ${dic_Key_MOs_status_duration["${type}"]}    ${record_of_change["${type}"]}
    END
    ${type}    Set Variable    cell
    FOR    ${record_of_change}    IN    @{list_record_of_change}
        Run Keyword If    '${record_of_change["${type}"].__len__()}'!='0'
        ...    Append To List    ${dic_Key_MOs_status_duration["${type}"]}    ${record_of_change["${type}"]}
    END
    ${type}    Set Variable    rmod
    FOR    ${record_of_change}    IN    @{list_record_of_change}
       Run Keyword If    '${record_of_change["${type}"].__len__()}'!='0'
        ...    Append To List    ${dic_Key_MOs_status_duration["${type}"]}    ${record_of_change["${type}"]}
    END
    ${type}    Set Variable    site
    FOR    ${record_of_change}    IN    @{list_record_of_change}
        Run Keyword If    '${record_of_change["${type}"].__len__()}'!='0'
        ...    Append To List    ${dic_Key_MOs_status_duration["${type}"]}    ${record_of_change["${type}"]}
    END
    ${type}    Set Variable    smod
    FOR    ${record_of_change}    IN    @{list_record_of_change}
        Run Keyword If    '${record_of_change["${type}"].__len__()}'!='0'
        ...    Append To List    ${dic_Key_MOs_status_duration["${type}"]}    ${record_of_change["${type}"]}
    END
    ${type}    Set Variable    rat
    FOR    ${record_of_change}    IN    @{list_record_of_change}
        Run Keyword If    '${record_of_change["${type}"].__len__()}'!='0'
        ...    Append To List    ${dic_Key_MOs_status_duration["${type}"]}    ${record_of_change["${type}"]}
    END
    [Return]    ${dic_Key_MOs_status_duration}

Filter Cell Status Duration
    [Arguments]    ${MO}    ${dic_key_MOs_status_duration}    ${reserved_praram}=${None}
    [Documentation]    When some type of cell status changed, the type of the RAT status could be ignored.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    Log    ${reserved_praram}
    ${type_str}    Set Variable    ${MO.split('/')[-1].split('-')[0].split('_')[0].strip()}
    ${cell_rat_mapper}    Evaluate    {"NRCELL":"nr","LNCEL":"lte","WNCEL":"wcdma","GNCEL":"gsm"}
    ${rat_type}    Get From Dictionary    ${cell_rat_mapper}    ${type_str}
    ${list_rat_status_duration}    Get From Dictionary    ${dic_key_MOs_status_duration}    rat
    FOR    ${rat_status}    IN    @{list_rat_status_duration}
        ${status}    Pop From Dictionary    ${rat_status}    ${rat_type}    ${None}
    END
    ${cell_status_duration}    Get From Dictionary    ${dic_key_MOs_status_duration}    cell
    FOR    ${cell_status}    IN    @{cell_status_duration}
        Remove From Dictionary    ${cell_status}    ${MO}
    END
    ${empty_dic}    Create Dictionary
    Remove Values From List    ${list_rat_status_duration}    ${empty_dic}
    Remove Values From List    ${cell_status_duration}    ${empty_dic}

Filter RAT Status Duration
    [Arguments]    ${MO}    ${dic_key_MOs_status_duration}    ${GNB_CU_TYPE}=NSA
    [Documentation]    When some type of RAT status changed, the type of the cells status could be ignored.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ${rat_cell_mapper}    Evaluate    {"nr":"NRCELL","lte":"LNCEL","wcdma":"WNCEL","gsm":"GNCEL"}
    ${cell_type}    Get From Dictionary    ${rat_cell_mapper}    ${MO}
    ${list_rat_status_duration}    Get From Dictionary    ${dic_key_MOs_status_duration}    rat
    FOR    ${rat_status}    IN    @{list_rat_status_duration}
        Remove From Dictionary    ${rat_status}    ${MO}
        Continue For Loop If    '${MO}'!='lte' or '${GNB_CU_TYPE}'!='SA'
        Remove From Dictionary    ${rat_status}    nr
    END
    ${cell_status_duration}    Get From Dictionary    ${dic_key_MOs_status_duration}    cell
    FOR    ${cell_status}    IN    @{cell_status_duration}
        ${cell_MOs}    Get Dictionary Keys    ${cell_status}
        ${cell_MOs_to_remove}    Get Matches    ${cell_MOs}    regexp=.\+/${cell_type}-\\d\+
        Remove From Dictionary    ${cell_status}    @{cell_MOs_to_remove}
        Continue For Loop If    '${MO}'!='lte' or '${GNB_CU_TYPE}'!='SA'
        ${nr_cell_MOs_to_remove}    Get Matches    ${cell_MOs}    regexp=.\+/NRCELL-\\d\+
        Remove From Dictionary    ${cell_status}    @{nr_cell_MOs_to_remove}
    END
    ${empty_dic}    Create Dictionary
    Remove Values From List    ${list_rat_status_duration}    ${empty_dic}
    Remove Values From List    ${cell_status_duration}    ${empty_dic}

Filter RMOD Status Duration
    [Arguments]    ${MO}    ${dic_key_MOs_status_duration}    ${reserved_praram}=${None}
    Log    ${reserved_praram}
    ${list_rmod_status_duration}    Get From Dictionary    ${dic_key_MOs_status_duration}    rmod
    FOR    ${rmod_status}    IN    @{list_rmod_status_duration}
        ${status}    Pop From Dictionary    ${rmod_status}    ${MO}    ${None}
    END
    ${empty_dic}    Create Dictionary
    Remove Values From List    ${list_rmod_status_duration}    ${empty_dic}

Check BTS Key MOs Status Duration
    [Arguments]    ${dic_key_MOs_status_duration}    ${expected_status}    @{ignore_type}
    [Documentation]    Check that the status change process of the SBTS key MOs is as expected and no un-expeceted
    ...                changes happened.
    ...
    ...    *AUTHOR* bin.7.liu@nokia-sbell.com
    ...
    ...    *INPUT*
    ...    | Parameter | Man. | Description |
    ...    | dic_key_MOs_status_duration | Yes | Dictionary contains changes of BTS key MOs statuses |
    ...    | expected_status | Yes | String, describe the status of some MOs should appear after provision |
    ...    | ignore_type | No | The type of BTS key MO can be ignored |
    ...
    ...    *RETURN*
    ...    | Parameter | Description |
    ...
    ...
    ...    *EXAMPLE*
    ...    | ${dic_key_MOs_status_duration} | Combine Changes Of BTS Key MOs Status | ${list_record_of_change} |
    ...    | ${ignore_type} | Create List | site | rmod | bbmod |
    ...    | Check BTS Key MOs Status Duration | ${dic_key_MOs_status_duration} | ${EXPECT_STATUS} | @{ignore_type} |
    ...
    ...    ${EXPECT_STATUS} = 'RAT:lte:ALL_DISABLED \ RAT:gsm:ALL_DISABLED \ RAT:wcdma:ALL_DISABLED'
    ...
    ...    ${dic_key_MOs_status_duration} = {"bbmod":[],
    ...    "cell":[{"MRBTS-1896/GNBTS-1/GNBCF-1/GNCEL-1":{"availabilityStatus":"Offline","operationalState":"Disabled"}},
    ...    {"MRBTS-1896/LNBTS-3560/LNCEL-3":{"availabilityStatus":"Offline","operationalState":"Disabled"},
    ...    "MRBTS-1896/WNBTS-1/WNCEL-18963":{"availabilityStatus":"Offline","operationalState":"Disabled"}},
    ...    {"MRBTS-1896/WNBTS-1/WNCEL-18961":{"availabilityStatus":"Offline","operationalState":"Disabled"},
    ...    "MRBTS-1896/WNBTS-1/WNCEL-18962":{"availabilityStatus":"Offline","operationalState":"Disabled"}},
    ...    {"MRBTS-1896/LNBTS-3560/LNCEL-1":{"availabilityStatus":"Offline","operationalState":"Disabled"},
    ...    "MRBTS-1896/LNBTS-3560/LNCEL-2":{"availabilityStatus":"Offline","operationalState":"Disabled"}},
    ...    {"MRBTS-1896/LNBTS-3560/LNCEL-1":{"availabilityStatus":"Failed"},"MRBTS-1896/LNBTS-3560/LNCEL-2":
    ...    {"availabilityStatus":"Failed"},"MRBTS-1896/LNBTS-3560/LNCEL-3":{"availabilityStatus":"Failed"},
    ...    "MRBTS-1896/WNBTS-1/WNCEL-18961":{"availabilityStatus":"Failed"},"MRBTS-1896/WNBTS-1/WNCEL-18962"
    ...    :{"availabilityStatus":"Failed"},"MRBTS-1896/WNBTS-1/WNCEL-18963":{"availabilityStatus":"Failed"}},
    ...    {"MRBTS-1896/GNBTS-1/GNBCF-1/GNCEL-1":{"availabilityStatus":"Failed"}},
    ...    {"MRBTS-1896/WNBTS-1/WNCEL-18961":{"availabilityStatus":"Offline"},"MRBTS-1896/WNBTS-1/WNCEL-18962":
    ...    {"availabilityStatus":"Offline"},"MRBTS-1896/WNBTS-1/WNCEL-18963":{"availabilityStatus":"Offline"}},
    ...    {"MRBTS-1896/GNBTS-1/GNBCF-1/GNCEL-1":{"availabilityStatus":"Offline"}},
    ...    {"MRBTS-1896/LNBTS-3560/LNCEL-1":{"availabilityStatus":"Offline"}},
    ...    {"MRBTS-1896/GNBTS-1/GNBCF-1/GNCEL-1":{"availabilityStatus":"Degraded","operationalState":"Enabled"},
    ...    "MRBTS-1896/LNBTS-3560/LNCEL-1":{"availabilityStatus":"Online","operationalState":"Enabled"},
    ...    "MRBTS-1896/LNBTS-3560/LNCEL-2":{"availabilityStatus":"Offline"},"MRBTS-1896/LNBTS-3560/LNCEL-3":
    ...    {"availabilityStatus":"Offline"}},
    ...    {"MRBTS-1896/GNBTS-1/GNBCF-1/GNCEL-1":{"availabilityStatus":"Online"}},
    ...    {"MRBTS-1896/LNBTS-3560/LNCEL-2":{"availabilityStatus":"Online","operationalState":"Enabled"},
    ...    "MRBTS-1896/LNBTS-3560/LNCEL-3":{"availabilityStatus":"Online","operationalState":"Enabled"},
    ...    "MRBTS-1896/WNBTS-1/WNCEL-18961":{"availabilityStatus":"Online","operationalState":"Enabled"},
    ...    "MRBTS-1896/WNBTS-1/WNCEL-18962":{"availabilityStatus":"Online","operationalState":"Enabled"}},
    ...    {"MRBTS-1896/WNBTS-1/WNCEL-18963":{"availabilityStatus":"Online","operationalState":"Enabled"}}],
    ...    "rat":[{"gsm":"ALL_DISABLED"},{"lte":"PARTIALLY_DISABLED","wcdma":"PARTIALLY_DISABLED"},
    ...    {"wcdma":"ALL_DISABLED"},{"lte":"ALL_DISABLED"},{"lte":"ALL_FAILED","wcdma":"ALL_FAILED"},
    ...    {"gsm":"ALL_FAILED"},{"wcdma":"ALL_DISABLED"},{"gsm":"ALL_DISABLED"},{"lte":"ALL_DISABLED"},
    ...    {"gsm":"ALL_ENABLED","lte":"PARTIALLY_DISABLED"},{"lte":"ALL_ENABLED","wcdma":"PARTIALLY_DISABLED"},
    ...    {"wcdma":"ALL_ENABLED"}],
    ...    "rmod":[],
    ...    "site":[{"MRBTS-1896":{"operationalState":"Disabled","proceduralState":"IntegratedToRan"}},
    ...    {"MRBTS-1896":{"proceduralState":"Commissioned"}},{"MRBTS-1896":{"proceduralState":"Configured"}},
    ...    {"MRBTS-1896":{"proceduralState":"IntegratedToRan"}},{"MRBTS-1896":{"operationalState":"Enabled",
    ...    "proceduralState":"OnAir"}}],
    ...    "smod":[]}
    ${tmp_str1}    Set Variable   "BBMOD":"bbmod","RMOD":"rmod","SMOD":"smod","RAT":"rat","MRBTS":"site",
    ${tmp_str2}    Set Variable   "NRCELL":"cell","LNCEL":"cell","WNCEL":"cell","GNCEL":"cell"
    ${type_MO_mapper}    Evaluate    {${tmp_str1}${tmp_str2}}
    ${all_filters}    Split String    ${expected_status}    ;
    FOR    ${filter}    IN    @{all_filters}
        Continue For Loop If    '${filter.strip()}'==''
        ${p_list}    Split String    ${filter}    :
        ${MO}    ${param}    ${value}    Set Variable    ${p_list[0]}    ${p_list[1]}
        ...    ${p_list[2]}
        ${type_str}    Set Variable    ${MO.split('/')[-1].split('-')[0].split('_')[0].strip()}
        ${type}    Get From Dictionary    ${type_MO_mapper}    ${type_str}
        ${MO}    Set Variable If    "${type}"=="rat"    ${param}    ${MO}
        Run Keyword    Filter ${type} Status Duration    ${MO}    ${dic_key_MOs_status_duration}    ${GNB_CU_TYPE}
    END
    Remove From Dictionary    ${dic_key_MOs_status_duration}    @{ignore_type}
    ${list_all_status}    Get Dictionary Values    ${dic_key_MOs_status_duration}
    FOR    ${all_status}    IN    @{list_all_status}
        Should Be Empty    ${all_status}    Some MOs status changed unexpected.
    END

Establish SSH to SBTS
    [Arguments]    ${host_ip}    ${user}=toor4nsn    ${pwd}=oZPS0POrRieRtu    ${alias}=None
    [Documentation]    SSH to SBTS
    ...
    ...    | **Author:** bin7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin7.liu@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | host_ip | Yes | smod1 ssh ip|
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | ssh_index | the index of ssh session |
    ${ssh_index}    SSHLibrary.Open Connection    host=${host_ip}    prompt=>    alias=${alias}
    SSHLibrary.Login    ${user}    ${pwd}
    [Return]    ${ssh_index}

Execute CMD Via SSH connection
    [Arguments]    ${cmd}    ${expect_console}    ${index_or_alias}=${None}    ${console_delay}=2s
    [Documentation]    Execute cmd via connected ssh connection or new connection,
    ...    wait until expected console output and return them.
    ...
    ...    | **Author:** bin7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin7.liu@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | cmd | Yes | smod1 ssh ip|
    ...    | expect_console | Yes | expected console outpuut |
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | output | console output |
    #Run Keyword Unless    ${index_or_alias} is None    SSHLibrary.Switch Connection    ${index_or_alias}
    Run Keyword If    ${index_or_alias} != ${None}    SSHLibrary.Switch Connection    ${index_or_alias}
    SSHLibrary.Set Client Configuration  timeout=8s
    SSHLibrary.Write    ${cmd}
    ${output}    Wait Until Keyword Succeeds    3x    ${console_delay}    SSHLibrary.Read Until Regexp    ${expect_console}
    [Return]    ${output}

Get ProductVariantPlanned Value
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${BTS_scf_content}=  coam.Get SCF    export_type=configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_content}
    ${productVariantPlanned}=    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1"]/p[@name="productVariantPlanned"]
    [Return]    ${productVariantPlanned}

Get Actual Parameter Value From NetAct
    [Documentation]    Get and return the actual value of the given parameter
    ...
    ...    | **Author:** lixin.kang@nokia-sbell.com
    ...    | **Maintainer:** lixin.kang@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | dist_name| distName of element
    ...    | param| Specifical parameter to check
    ...    | ui_values| default is false
    ...
    ...    **Return Parameters:**
    ...    +----------------+------------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+==========================================================================================+
    ...    | actual_value | actual parameter value from NetAct |
    [Arguments]    ${dist_name}    ${param}    ${ui_values}=false
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}    Run Keyword And Return Status    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs
    ...    file_name=get_param_value_from_netact_plan.xml    dist_names=${MRBTS_DN}    ui_values=${ui_values}
    ${scf_xml}=    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/get_param_value_from_netact_plan.xml
    ${actual_value}   L_XML.Get Element Text   ${scf_xml}   .//managedObject[@distName="${dist_name}"]/p[@name="${param}"]
    [Return]      ${actual_value}

Compare String Value In XML
    [Documentation]    Compare String Value In XML
    ...
    ...    | **Author:** lixin.kang@nokia-sbell.com
    ...    | **Maintainer:** lixin.kang@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | scf_xml| scf xml file content
    ...    | ui_values| default is false
    ...    | dist_name| distName of element
    ...    | param_name| Parameters name
    ...    | expected_value| Parameters with expected values
    ...
    [Arguments]     ${scf_xml}    ${ui_values}    ${dist_name}    ${param_name}    ${expected_value}
    ${expected_value_formatted}    Run Keyword If    '${ui_values}'=='false'
    ...    Set Variable If      '${expected_value}'=='true'    1
    ...    '${expected_value}'=='false'    0
    ...    '${expected_value}'!='true'and '${expected_value}'!='false'    ${expected_value}
    ...    ELSE    Set Variable    ${expected_value}
    ${actual_value}    L_XML.Get Element Text     ${scf_xml}
    ...    .//managedObject[@distName="${dist_name}"]/p[@name="${param_name}"]
    Should Be Equal    ${actual_value}    ${expected_value_formatted}

Compare Unstring Value In XML
    [Documentation]    Compare Unstring Value In XML
    ...
    ...    | **Author:** lixin.kang@nokia-sbell.com
    ...    | **Maintainer:** lixin.kang@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | scf_xml| scf xml file content
    ...    | ui_values| default is false
    ...    | dist_name| distName of element
    ...    | param_name| Parameters name
    ...    | expected_value| Parameters with expected values
    ...
    [Arguments]     ${scf_xml}    ${ui_values}    ${dist_name}    ${param_name}    ${expected_value}
    ## ${expected_value}=[LNCEL_FDD-actAutoPucchAlloc,LNCEL_FDD-mimoOlConfig,LNCEL_FDD-mimoOlConfig.mimoOlCqiThD]
    ## or ${exepcted_value}=["ulTransPrecodeOffSinrThresh":"20","ulTransPrecodeOnSinrThresh":"1.5",
    ## "ulTransPrecodePi2Bpsk":"true","ulTransPrePi2BpskPwrBoost":"false"]
    ${is_string}    Run Keyword If    len(${expected_value})>0
    ...    Run Keyword And Return Status    Should Be String    ${expected_value[0]}
    ...    ELSE    Set Variable    True
    ${actual_value}    Run Keyword If    ${is_string}
    ...    Compare List Value In XML    ${scf_xml}    ${dist_name}    ${param_name}    ${expected_value}
    ...    ELSE    Compare Structure Value In XML    ${scf_xml}    ${ui_values}    ${dist_name}
    ...    ${param_name}    ${expected_value}

Compare List Value In XML
    [Documentation]    Compare List Value In XML
    ...
    ...    | **Author:** lixin.kang@nokia-sbell.com
    ...    | **Maintainer:** lixin.kang@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | scf_xml| scf xml file content
    ...    | dist_name| distName of element
    ...    | param_name| Parameters name
    ...    | expected_value| Parameters with expected values
    ...
    [Arguments]     ${scf_xml}    ${dist_name}    ${param_name}    ${expected_value}
    ${actual_value}    L_XML.Get Elements Texts    ${scf_xml}
    ...    .//managedObject[@distName="${dist_name}"]/list[@name="${param_name}"]/p
    ${actual_value}    Convert To List    ${actual_value}
    Lists Should Be Equal    ${actual_value}    ${expected_value}

Compare Structure Value In XML
    [Documentation]    Compare Structure Value In XM
    ...
    ...    | **Author:** lixin.kang@nokia-sbell.com
    ...    | **Maintainer:** lixin.kang@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | scf_xml| scf xml file content
    ...    | ui_values| default is false
    ...    | dist_name| distName of element
    ...    | param_name| Parameters name
    ...    | expected_value| Parameters with expected values
    ...
    [Arguments]     ${scf_xml}    ${ui_values}    ${dist_name}    ${param_name}    ${expected_value}
    ${element_dic}    Create Dictionary
    ${actual_items}    L_XML.Get Child Elements    ${scf_xml}
    ...    .//managedObject[@distName="${dist_name}"]/list[@name="${param_name}"]/item
    FOR    ${item}    IN    @{actual_items}
        ${p_name}    L_XML.Get Element Attribute    ${item}    name
        ${p_value}    L_XML.Get Element Text    ${item}
        Set To Dictionary    ${element_dic}    ${p_name}    ${p_value}
    END
    ${actual_value}    Create List    ${element_dic}
    ${actual_value}    Convert To List    ${actual_value}
    ${expected_value_formatted}    Create List
    FOR    ${item}    IN    @{expected_value}
        ${expected_item_formatted}    Run Keyword If    '${ui_values}'=='false'
        ...   Convert Boolean Value From UI_Value To Internal_Value For Structure    ${item}
        ...    ELSE    Set Variable     ${item}
        Append To List    ${expected_value_formatted}    ${expected_item_formatted}
    END
    Lists Should Be Equal    ${actual_value}    ${expected_value_formatted}

Convert Boolean Value From UI_Value To Internal_Value For Structure
    [Documentation]    Convert Boolean Value From UI_Value To Internal_Value For Structure
    ...
    ...    | **Author:** lixin.kang@nokia-sbell.com
    ...    | **Maintainer:** lixin.kang@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | structure_values| the structure format values
    ...    **Return Values:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | structure_values| the formateed structure format values
    ...
    [Arguments]    ${structure_values}
    ${keys}     Get Dictionary Keys    ${structure_values}
    FOR    ${key}    IN    @{keys}
         ${value}    Get From Dictionary    ${structure_values}    ${key}
         ${convert_value}    Set Variable If
         ...    '${value}'=='true'    1
         ...    '${value}'=='false'    0
         ...    '${value}'!='true' and '${value}'!='false'    ${value}
         Set To Dictionary    ${structure_values}    ${key}    ${convert_value}
    END
    [Return]    ${structure_values}

Check SMOD2 in Admin
    [Arguments]  ${block_test_on_fiasco}=${TRUE}
    [Documentation]
    ...  Ensure that SMOD2 exists in Admin and set ${SMOD2_exists} variable to True
    ...
    ...  | **Full description:**
    ...  | Keyword ensures existence SMOD2 in Admin and sets True in ${SMOD2_exists} variable.
    ...  | In case SMOD2 does not exists and 'block_test_on_fiasco' variable equals True, TC verdict is set to BLOCKED,
    ...  | or FAILED in other cases
    ...
    ...  | **Author:** sebastian.burniak@nokia.com
    ...  | **Maintainer:** sebastian.burniak@nokia.com
    ...  | **Released with version:** 56.0
    ...  | **Last changes done with version:** 58.0

    ...  +-----------------------+------+------------------------------------------------------------------+
    ...  | Parameter name        | Man. | Description                                                      |
    ...  +=======================+======+==================================================================+
    ...  | block_test_on_fiasco  | yes  | If True, test verdict set to BLOCKED, FAILED in other cases      |
    ...  +-----------------------+------+------------------------------------------------------------------+

    ${im_status}  ${im_sync_objects_tmp}=  Run Keyword And Ignore Error  Query Infomodel  get list //IM_SYNC_L-1
    ${im_sync_objects}=  Run keyword if  '${im_status}'=='PASS'  Set Variable  ${im_sync_objects_tmp}
    ...    ELSE  Query Infomodel  get list /MRBTS-1/EQM-1/SMOD-*/IM_SYNC-1

    ${connectionState}   Infomodel Get Object Connection Status  ${im_sync_objects}[0][dist_name]

    ${smod2_detected}=  Run keyword and return status  Run keyword if  '${connectionState}'=='Connected'
    ...                                                Ensure that SMOD2 is detected inside ADMIN

    ...   ELSE    Run keywords  Synchronize SMODs TAF  AND  Ensure that SMOD2 is detected inside ADMIN
    Run keyword if  ${smod2_detected}  Run keywords  Log  Two SMODs were detected  console=${TRUE}
    ...    AND  Set test variable  ${SMOD2_exists}  ${TRUE}
    ...    ELSE IF  ${block_test_on_fiasco}   Fail   Extension System Module not detected despite declared in config file.
    ...    ELSE     Fail     Extension System Module not detected despite being declared in config file.

Remote Test Line Setup
    [Documentation]
    ...  Setup verification for remote test line
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** tomasz.1.filipek@nokia.com
    ...  | **Released with version:** 62.0
    ...
    ...  | **Full description:**
    ...
    ...  | **Input Parameters:**
    ...
    ...  +------------------+------+------------------------+
    ...  | Parameter name   | Man. | Description            |
    ...  +==================+======+========================+
    ...  | alias            | no   | ute alias              |
    ...  +------------------+------+------------------------+
    ...  | remote_host      | no   | IP to remote_host      |
    ...  +------------------+------+------------------------+
    ...
    [Arguments]  ${remote_host}  ${udp_ip1}=192.168.255.126  ${remote_host2}=${EMPTY}  ${udp_ip2}=192.168.255.126
    ...    ${alias}=remote
    ...    ${modules_check}=${TRUE}  ${cells_check}=${TRUE}  ${alarms_check}=${TRUE}
    Log  Remote Test Line Setup (alias: ${alias})  console=${True}
    Set Test Variable  ${${alias}_verification_status}      failed
    Set Test Variable  ${${alias}_admin_started}            ${False}
    Set Test Variable  ${${alias}_infomodel_started}        ${False}
    Set Test Variable  ${${alias}_syslog_started}           ${False}
    Set Test Variable  ${${alias}_SMOD2_exists}     ${False}
    Set Test Variable  ${${alias}_SMOD2_syslog_started}     ${False}
    ${modules_working}=     Set variable  ${False}
    ${LTE_working}=         Set variable  ${False}
    ${WCDMA_working}=       Set variable  ${False}
    ${GSM_working}=         Set variable  ${False}
    ${NR_working}=          Set variable  ${False}
    ${alarms_status}=       Set variable  FAIL

    ${SMOD2_exists}=  Set Variable If  '${remote_host2}'!=''  ${True}  ${False}
    Set Test Variable  ${${alias}_SMOD2_exists}  ${SMOD2_exists}

    Start remote syslog  remote_host=${remote_host}  udp_ip=${udp_ip1}  alias=${alias}
    Run Keyword If  ${${alias}_SMOD2_exists}  Start remote syslog  remote_host=${remote_host2}  udp_ip=${udp_ip2}
    ...    alias=${alias}_SMOD2
    Start remote Admin  remote_host=${remote_host}  alias=${alias}

    ${smod_expected_states}=  Get modules expected states  SMOD  alias=${alias}
    ${rmod_expected_states}=  Get modules expected states  RMOD  alias=${alias}
    ${sm_state}=  Run Keyword If  ${modules_check}  Verify modules TAF  SMOD  alias=${alias}  scf_check=${FALSE}
    ...  expected_states=${smod_expected_states}
    ...  ELSE  Set Variable  ${TRUE}
    ${rf_state}=  Run Keyword If  ${modules_check}  Verify modules TAF  RMOD  alias=${alias}  scf_check=${FALSE}
    ...    expected_states=${rmod_expected_states}
    ...  ELSE  Set Variable  ${TRUE}
    ${modules_working}=  Evaluate  ${sm_state} and ${rf_state}
    ${LTE_expected_states}=     Get cells expected states    LTE  alias=${alias}
    ${WCDMA_expected_states}=   Get cells expected states  WCDMA  alias=${alias}
    ${GSM_expected_states}=     Get cells expected states    GSM  alias=${alias}
    ${NR_expected_states}=     Get cells expected states    NR  alias=${alias}
    ${LTE_working}=      Run Keyword If    ${cells_check}    Verify cells TAF  LTE    scf_check=${False}    alias=${alias}
    ...    expected_states=${LTE_expected_states}
    ...    ELSE    Set Variable    ${TRUE}
    ${WCDMA_working}=    Run Keyword If    ${cells_check}    Verify cells TAF  WCDMA    scf_check=${False}    alias=${alias}
    ...    expected_states=${WCDMA_expected_states}
    ...    ELSE    Set Variable  ${TRUE}
    ${GSM_working}=      Run Keyword If    ${cells_check}    Verify cells TAF    GSM    scf_check=${False}    alias=${alias}
    ...    expected_states=${GSM_expected_states}
    ...    ELSE    Set Variable  ${TRUE}
    ${NR_working}=      Run Keyword If     ${cells_check}    Verify cells TAF    NR    scf_check=${False}     alias=${alias}
    ...    expected_states=${NR_expected_states}
    ...     ELSE    Set Variable  ${TRUE}
    ${alarms_status}  ${alarms_msg}=  Run Keyword If  ${alarms_check}  Run Keyword And Ignore Error
    ...    Admin Check Active Alarms TAF    alias=${alias}
    ${statuses_dictionary}=  Create Dictionary  modules_working=${modules_working}   LTE_working=${LTE_working}
    ...    WCDMA_working=${WCDMA_working}  GSM_working=${GSM_working}  NR_working=${NR_working}
    ...    alarms_status=${alarms_status}
    ${pretty_statuses}=  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)   modules=pprint
    Run keyword if  '${alarms_status}'=='FAIL'   Log  Critical fail while checking alarms: ${alarms_msg}    console=${TRUE}
    ...    ELSE IF  ${alarms_msg}    Log     Unexpected alarms are present on remote BTS (alias: ${alias}): ${alarms_msg}
    ...    level=WARN

    Start remote Infomodel  remote_host=${remote_host}  bts_host=192.168.255.129  alias=${alias}

    ${cell_status}    Set Variable    ${LTE_working} and ${WCDMA_working} and ${GSM_working} and ${NR_working}

    [Teardown]  Run Keyword If
    ...  ${modules_working} and ${cell_status} and '${alarms_status}'!='FAIL'
    ...  Set Test Variable  ${${alias}_verification_status}  passed
    ...  ELSE   Fail    Test blocked due to failure of ${alias} initial check:\n${pretty_statuses}.\nSkip to teardown!

Start remote Admin
    [Arguments]  ${remote_host}  ${alias}
    ${remote_admin_started}=  Run keyword and return status
    ...  coam.Setup Admin  admin_api_log_dir=${BTS Files}  remote_host=${remote_host}  bts_host=192.168.255.129
    ...  bts_port=443  use_ssl=TRUE  update_interval=1000  alias=${alias}
    Set Test Variable  ${${alias}_admin_started}  ${remote_admin_started}

Start remote Infomodel
    [Arguments]  ${remote_host}  ${bts_host}  ${alias}
    Setup infomodel  alias=${alias}  remote_host=${remote_host}  address=${bts_host}  port=443  use_ssl=True
    ...    admin_api_log_dir=${BTS Files}/
    ${remote_infomodel_started}=  Run Keyword And Return Status  Connect Infomodel  alias=${alias}
    Set Test Variable  ${${alias}_infomodel_started}  ${remote_infomodel_started}

Remote Test Line Teardown
    [Arguments]  ${alias}  ${verify_states_stability}=${False}
    Log    Remote Test Line Teardown (alias: ${alias})  console=${True}
    ${ims_path}=    Set variable  ${BTS Files}/IM/${alias}.ims2
    Run keyword if    ${${alias}_infomodel_started}    Save infomodel log  filename=${ims_path}  timeout=300  alias=${alias}
    ${condistions}    Set Variable
    ...    ${${alias}_infomodel_started} and ${verify_states_stability} and '${${alias}_verification_status}'=='passed'
    Run keyword if     ${condistions}    Verify Remote BTS States After Test Case  ims_path=${ims_path}  alias=${alias}
    Run keyword if   ${${alias}_infomodel_started}  Teardown Infomodel  alias=${alias}
    Run keyword if   ${${alias}_SMOD2_syslog_started}       Collect syslog from ${alias}_SMOD2
    Run keyword if   ${${alias}_syslog_started}       Collect syslog from ${alias}

Verify Remote BTS States After Test Case
    [Arguments]  ${ims_path}  ${alias}
    Log  Verify remote BTS states after test case (alias: ${alias})  console=${True}

    ${alarms_status}  ${alarms_msg}=  Run Keyword And Ignore Error  Admin Check Active Alarms TAF  alias=${alias}
    Run keyword if  '${alarms_status}'=='FAIL'   Fail  Critical fail while checking alarms: ${alarms_msg}  console=${TRUE}
    ...    ELSE IF  ${alarms_msg}    Log     Unexpected alarms are present on remote BTS (alias: ${alias}): ${alarms_msg}
    ...    level=WARN

    ${remote_SMODS}=    coam.Get Ids For All  SMOD  alias=${alias}
    ${remote_RMODS}=    coam.Get Ids For All  RMOD  alias=${alias}
    ${remote_CELLS_L}=  coam.Get Ids For All  LNCEL  alias=${alias}
    ${remote_CELLS_W}=  coam.Get Ids For All  WNCEL  alias=${alias}
    ${remote_CELLS_G}=  coam.Get Ids For All  GNCEL  alias=${alias}

    Initialize ims2 validator   ${ims_path}  alias=${alias}
    FOR  ${smod}  IN  @{remote_SMODS}
        Log  ${smod}
        Fail if ims2 object change  ${smod}  administrativeState   ${Unlocked_}
        Fail if ims2 object change  ${smod}  operationalState      ${Enabled_}
    END
    FOR  ${rmod}  IN  @{remote_RMODS}
        Log  ${rmod}
        Fail if ims2 object change  ${rmod}  administrativeState   ${Unlocked_}
        Fail if ims2 object change  ${rmod}  operationalState      ${Enabled_}
        Fail if ims2 object change  ${rmod}  blockingState         ${Unblocked_}    #Should be removed ?
    END
    FOR  ${cell}  IN  @{remote_CELLS_L}
        Log  ${cell}
        Fail if ims2 object change  ${cell}  administrativeState   ${Unlocked_}
        Fail if ims2 object change  ${cell}  operationalState      ${Enabled_}
        Fail if ims2 object change  ${cell}  blockingState         ${Unblocked_}
    END
    FOR  ${cell}  IN  @{remote_CELLS_W}
        Fail if ims2 object change  ${cell}  operationalState      ${Enabled_}
        Fail if ims2 object change  ${cell}  blockingState         ${Unblocked_}
        Fail if ims2 object change  ${cell}  usageState            ${Active_}
    END
    FOR  ${cell}  IN  @{remote_CELLS_G}
        Fail if ims2 object change  ${cell}  administrativeState   ${Unlocked_}
        Fail if ims2 object change  ${cell}  operationalState      ${Enabled_}
        Fail if ims2 object change  ${cell}  blockingState         ${Unblocked_}
        Fail if ims2 object change  ${cell}  usageState            ${Active_}
    END
    Fail if ims2 event occur   event=reset  alias=${alias}
    Fail if ims2 event occur   event=create /MRBTS-*/RAT-*/FRI-*/ALARM-* [alarmSeverity=Critical]  alias=${alias}

Verify Configuration And Set Up Remote Test Line
    [Documentation]
    ...  Helper for KW Remote Test Line Setup which checks if selected test line is well configured
    ...    (exists in given dictionary and has the key "PC_IP1") and if it is, it starts setup
    [Arguments]  ${modules_check}  ${cells_check}  ${alarms_check}  ${alias}
    ${SMOD1_configured}  ${pc_ip1}=  Run keyword and ignore error  Get from dictionary
    ...    ${REMOTE_TESTLINES['${alias}']}  PC_IP1
    Run Keyword If  '${SMOD1_configured}'！='PASS'  Run Keywords
    ...    Log  There is no PC_IP1 defined for ${alias} in REMOTE TESTLINES dict  console=${True}
    ...  AND  Return From Keyword

    ${udp_ip1_configured}  ${udp_ip1}=  Run keyword and ignore error
    ...    Get from dictionary  ${REMOTE_TESTLINES['${alias}']}  UDP_IP1
    ${udp_ip1}=  Set variable if  '${udp_ip1_configured}'=='PASS'  ${udp_ip1}  192.168.255.126

    ${SMOD2_configured}  ${pc_ip2}=  Run keyword and ignore error
    ...    Get from dictionary  ${REMOTE_TESTLINES['${alias}']}  PC_IP2
    ${pc_ip2}=  Set variable if  '${SMOD2_configured}'=='PASS'  ${pc_ip2}  ${EMPTY}

    ${udp_ip2_configured}  ${udp_ip2}=  Run keyword and ignore error
    ...    Get from dictionary  ${REMOTE_TESTLINES['${alias}']}  UDP_IP2
    ${udp_ip2}=  Set Variable If  '${udp_ip2_configured}'=='PASS'  ${udp_ip2}  192.168.255.126

    Remote Test Line Setup  modules_check=${modules_check}  cells_check=${cells_check}
    ...    alarms_check=${alarms_check}  remote_host=${pc_ip1}  udp_ip1=${udp_ip1}  remote_host2=${pc_ip2}
    ...    udp_ip2=${udp_ip2}  alias=${alias}

Collect Snapshot From Remote Test Lines
    FOR  ${remote_line_alias}  IN  @{REMOTE_TESTLINES_LIST}
        Verify Configuration And Get Snapshot From Remote Test Line  ${remote_line_alias}
    END

Verify Configuration And Get Snapshot From Remote Test Line
    [Documentation]
    ...  Helper for KW Remote Testline Snapshot which checks if selected test line is well configured
    ...    (exists in given dictionary and has the key "PC_IP1") and if it is, it starts this KW
    [Arguments]  ${alias}
    ${SMOD1_configured}  ${pc_ip1}=  Run keyword and ignore error
    ...    Get from dictionary  ${REMOTE_TESTLINES['${alias}']}  PC_IP1
    Run Keyword If  '${SMOD1_configured}'!='PASS'  Return From Keyword
    Admin Get Snapshot Remotely Via Admin API  bts_host=192.168.255.129
    ...    remote_host=${pc_ip1}  snapshot_timeout=${ADMIN_SNAPSHOT_TIMEOUT_ESM}  alias=${alias}
    ${SMOD2_configured}  ${pc_ip2}=  Run keyword and ignore error
    ...    Get from dictionary  ${REMOTE_TESTLINES['${alias}']}  PC_IP2
    Run Keyword If  '${SMOD2_configured}'!='PASS'  Return From Keyword
    Admin Get Snapshot Remotely Via Admin API  bts_host=192.168.255.119  remote_host=${pc_ip2}
    ...    snapshot_timeout=${ADMIN_SNAPSHOT_TIMEOUT_ESM}  alias=${alias}_SMOD2

Get cells expected states
    [Documentation]
    ...  Get cells expected states in particular technology for remote host
    ...
    ...  | **Author:** sebastian.burniak@nokia.com
    ...  | **Maintainer:** sebastian.burniak@nokia.com
    ...  | **Released with version:** 71.0
    ...
    ...  | **Full description:**
    ...  | Keyword added for DSC and carrier aggregation feature. In case if remote host
    ...  | (one or more) has different expected state than tested one, there is a need to
    ...  | declare new variables. According to alias for remote host ('DSC' for DSC feature)
    ...  | variables in .json file should look like:
    ...  | {{{ "test": "LOGS_Snapshot",
    ...  |     "timeout": 14400,
    ...  |     "runs": 1,
    ...  |     "DSC": true,
    ...  |     "filename": "/home/ute/btsauto/hran_ta/testsuite/SBTS/LOGS/LOGS_Snapshot.robot",
    ...  |     "parameters":{ "cells_LTE_expected_states": "administrativeState = Unlocked, operationalState = Enabled,
    ...         availabilityStatus = Degraded, blockingState = Unblocked",
    ...  |     "cells_NR_expected_states":  "administrativeState=Unlocked, operationalState=Enabled,
    ...        availabilityStatus=Online, blockingState=Unblocked",
    ...  |     "cells_WCDMA_expected_states": "operationalState = Enabled, availabilityStatus = Degraded,
    ...        blockingState = Unblocked, usageState = Active",
    ...  |     "cells_GSM_expected_states": "administrativeState=Unlocked, operationalState=Enabled,
    ...        availabilityStatus=Degraded, blockingState=Unblocked, usageState=Active",
    ...  |     "DSC_cells_LTE_expected_states": "administrativeState = Unlocked, operationalState = Enabled,
    ...        availabilityStatus = Online, blockingState = Unblocked",
    ...  |     "DSC_cells_WCDMA_expected_states": "operationalState = Enabled, availabilityStatus = Online,
    ...        blockingState = Unblocked, usageState = Active",
    ...  |     "DSC_cells_GSM_expected_states": "administrativeState=Unlocked, operationalState=Enabled,
    ...        availabilityStatus=Online, blockingState=Unblocked, usageState=Active"
    ...  |  }}}
    ...
    ...  | **Input Parameters:**
    ...
    ...  +------------------+------+-------------------------------------+
    ...  | Parameter name   | Man. | Description                         |
    ...  +==================+======+=====================================+
    ...  | technology       | yes  | Cells technology to be checked      |
    ...  +------------------+------+-------------------------------------+
    ...  | alias            | no   | remote host alias, default DSC      |
    ...  +------------------+------+-------------------------------------+
    ...
    [Arguments]  ${technology}  ${alias}=DSC
    ${variable_exist}=  Run keyword and Return status   Variable should exist    ${${alias}_cells_${technology}_expected_states}
    Run keyword if  ${variable_exist}  Return from keyword   ${${alias}_cells_${technology}_expected_states}
    ...     ELSE  Return from keyword   ${cells_${technology}_expected_states}

Get modules expected states
    [Documentation]
    ...  Get modules expected states for remote host
    ...
    ...  | **Author:** sebastian.burniak@nokia.com
    ...  | **Maintainer:** sebastian.burniak@nokia.com
    ...  | **Released with version:** 71.0
    ...
    ...  | **Full description:**
    ...  | Keyword added for DSC and carrier aggregation feature. In case if remote host
    ...  | (one or more) has different expected state than tested one, there is a need to
    ...  | declare new variables. According to alias for remote host ('DSC' for DSC feature)
    ...  | variables in .json file should look like:
    ...  | {{{ "test": "LOGS_Snapshot",
    ...  |     "timeout": 14400,
    ...  |     "runs": 1,
    ...  |     "DSC": true,
    ...  |     "filename": "/home/ute/btsauto/hran_ta/testsuite/SBTS/LOGS/LOGS_Snapshot.robot",
    ...  |     "parameters":{ "cells_LTE_expected_states": "administrativeState = Unlocked,
    ...        operationalState = Enabled, availabilityStatus = Degraded, blockingState = Unblocked",
    ...  |     "cells_NR_expected_states":  "administrativeState=Unlocked, operationalState=Enabled,
    ...        availabilityStatus=Online, blockingState=Unblocked",
    ...  |     "cells_WCDMA_expected_states": "operationalState = Enabled, availabilityStatus = Degraded,
    ...        blockingState = Unblocked, usageState = Active",
    ...  |     "cells_GSM_expected_states": "administrativeState=Unlocked, operationalState=Enabled,
    ...       availabilityStatus=Degraded, blockingState=Unblocked, usageState=Active",
    ...  |     "DSC_SMOD_expected_states": "administrativeState=Unlocked, operationalState=Enabled,
    ...       availabilityStatus=Online, blockingState=Unblocked, usageState=Active"
    ...  |  }}}
    ...
    ...  | **Input Parameters:**
    ...
    ...  +------------------+------+-------------------------------------+
    ...  | Parameter name   | Man. | Description                         |
    ...  +==================+======+=====================================+
    ...  | class_name       | yes  | BTS module class name SMOD or RMOD  |
    ...  +------------------+------+-------------------------------------+
    ...  | alias            | no   | remote host alias, default DSC      |
    ...  +------------------+------+-------------------------------------+
    ...
    [Arguments]  ${class_name}  ${alias}=DSC
    ${variable_exist}=  Run keyword and Return status   Variable should exist  ${${alias}_${class_name}_expected_states}
    Run keyword if  ${variable_exist}  Return from keyword  ${${alias}_${class_name}_expected_states}
    ...       ELSE  Return from keyword  ${${class_name}_expected_states}

Verify cells TAF
    [Documentation]
    ...  Verify cells states
    ...  Expected states in default are setted from variables section in hran_frame_sbts
    ...  If scf_check==True, cells count will be verified with scf
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ...
    ...  | Parameter       | Mandatory | Description                                          |
    ...  | technology      | Yes  | Cell ID for which states should be checked [SMOD, RMOD]   |
    ...  | expected_states | No   | Expected states as string ex. "administrativeState=Unlocked,
    ...                             operationalState=Enabled" |
    ...  Return
    ...  False if at least one cell has state other than expected, or cells count in scf is not equal runtime cells
    ...
    [Arguments]  ${technology}    ${expected_states}=${cells_${technology}_expected_states}     ${alias}=default    ${scf_check}=${TRUE}
    ${technology_sign}=  Run keyword if  '${technology}'=='NR'
    ...  Set variable  NR
    ...  ELSE
    ...  Set variable  ${technology[0]}N
    ${check_status}  ${RUNTIME_CELLS}  ${ALL_CELLS}=  Get objects with expected states TAF
    ...   ${expected_states}  ${technology_sign}CEL  alias=${alias}

    Run keyword if  '${check_status}'=='FAIL'  Run keywords
    ...    Log  At least one ${technology} cell has state other than expected.  console=${TRUE}
    ...    AND  Return from keyword  ${FALSE}

    ${count_status}=  Run keyword if  ${scf_check}  Check SCF count  ${technology}  ${ALL_CELLS}
    ...  ELSE  Set variable  ${TRUE}

    Run keyword if  ${count_status}  Log  All ${technology} cells are in expected state.  console=${TRUE}
    ...    ELSE   Run Keywords    Log    All ${technology} cells are in expected state     console=${TRUE}
    ...    AND   Log   but the number of cells defined in SCF differs from reported by Admin API.    console=${TRUE}

    [Return]  ${count_status}

Get objects with expected states TAF
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
    ...  +-----------------+------+------------------------------------------------------------+
    ...  | Parameter name  | Man. | Description                                                |
    ...  +=================+======+============================================================+
    ...  | expected states | yes  | Comma separated states with their valies
    ...                            (i.e administrativeState=Unlocked, operationalState=Enabled) |
    ...  +-----------------+------+--------------------------------------------------------------+
    ...  | class_name      | yes  | ADMIN object class name (BTS, SMOD, BBU, RMOD, ALD, LNCEL, GNCEL or WNCEL)                             |
    ...  +-----------------+------+-------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=  Get objects with expected states
    ...    operationalState=Enabled, availabilityStatus=Online  ALD

    [Arguments]  ${expected states}  ${class name}  ${alias}=default
    ${class_ids}=  coam.Get Ids For All  ${class name}  alias=${alias}
    ${matching_objects}=  Create list
    ${matching_statuses}=  Create list
    FOR  ${item_id}  IN  @{class_ids}
        ${status}  ${item_parameters}=  Run keyword and ignore error  Check object expected states
        ...    ${class name}  ${item_id}  ${expected states}  timeout=20  alias=${alias}
        Run keyword if  '${status}'=='PASS'  Run keywords
        ...  Append to list  ${matching_objects}  ${item_parameters}  AND  Append to list  ${matching_statuses}  PASS
        ${iot_cell}=  Run keyword and return status  Should match regexp  ${item_id}  .*BTS_CONF.*SCF.*LNCEL
        Run keyword if  "${status}"=="FAIL" and ${iot_cell}  Append to list  ${matching_statuses}  PASS
        ${status}  ${item_parameters}=  Run keyword if  "${status}"=="FAIL" and not ${iot_cell}
        ...  Run keyword and ignore error  coam.Assert  ${class name}  ${item_id}  availabilityStatus=${NotInstalled_}  timeout=20
        ...  ELSE  Create list  PASS  NONE
        Run keyword if  "${status}"=="FAIL" and not ${iot_cell}  Append to list  ${matching_statuses}  FAIL
    END
    ${status}=  evaluate  "FAIL" if len(${class_ids})!=0 and "FAIL" in "${matching_statuses}" else "PASS"
    [Return]  ${status}  ${matching_objects}  ${class_ids}

Check object expected states
    [Arguments]  ${class name}  ${item_id}  ${expected states}  ${timeout}=20  ${alias}=default
    ${expected states}  Split string  ${expected states}  ,${SPACE}
    ${parameters}  coam.Get Parameters For  ${class name}  ${item_id}  timeout=${timeout}  alias=${alias}
    FOR  ${state}  IN  @{expected states}
        ${stateName}  ${stateValue}  Split string  ${state}  =
        ${no_state_in_parameters}  Run keyword and return status  Dictionary should not contain key  ${parameters}  ${stateName}
        ${is_online}  Run keyword and return status  Should contain  ${stateValue}  nline
        Continue for loop if  ${no_state_in_parameters} and '${stateName}'=='availabilityStatus' and ${is_online}
        Run keyword if  ${no_state_in_parameters}  Fail  'Parameter "${stateName}" not present. Please check parameter name.'
        ${assert_status}  ${assert_output}  Run keyword and ignore error  coam.Assert  ${class name}  ${item_id}  ${state}
        ...    timeout=${timeout}  alias=${alias}
        Run keyword if  '${assert_status}'=='FAIL'  Fail  ${assert_output}
    END
    [Return]  ${parameters}

Verify modules TAF
    [Documentation]
    ...  Verify modules states
    ...  Default expected states are defined in the Variables section in hran_frame_sbts.
    ...  If `scf_check` is set to True, the number of modules will be compared with the number of respective objects in SCF.
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ...
    ...  | Parameter       | Mandatory | Description                           |
    ...  | class_name       | Yes       | Class name for which states should be checked [SMOD, RMOD]  |
    ...  | expected_states | No        | Expected states as string, e.g., "administrativeState=Unlocked,
    ...                                  operationalState=Enabled" |

    [Arguments]  ${class_name}  ${expected_states}=${${class_name}_expected_states}  ${alias}=default  ${scf_check}=${TRUE}
    ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=  Get objects with expected states TAF
    ...    ${expected_states}  ${class_name}  alias=${alias}

    Run keyword if  '${check_status}'=='FAIL'  Run keywords
    ...    Log  At least one ${class_name} module has state other than expected.  console=${TRUE}
    ...    AND  Return from keyword  ${FALSE}

    ${count_status}=  Run keyword if  ${scf_check}  Check SCF count  ${class_name}  ${RUNTIME_MODS}
    ...  ELSE  Set variable  ${TRUE}

    Run keyword if  ${count_status}  Log  All states of ${class_name} modules are as expected.  console=${TRUE}
    ...  ELSE  Log  At least one ${class_name} module has state other than expected.  console=${TRUE}
    [Return]  ${count_status}

Set Expected Object Status
    [Documentation]    Keyword used for set expected object status according to CNI-61110 (online status,blocked status
    ...     ,locked status,offline status)
    ...
    ...    | **Author:** yuyan.xu@nokia-sbell.com
    ...    | **Maintainer:** yuyan.xu@nokia-sbell.com
    ${without_CNI_version}    Create List    SBTS21A    SBTS21B    SBTS22R1    SBTS22R2
    ${bts_SW_list}=    Admin Get BTS SW Version
    ${active SW version}    Set Variable    ${bts_SW_list[0]}
    ${current_release}    Fetch From Left    ${active SW version}   _
    ${With_CNI61110}    Run Keyword And Return Status    List Should Not Contain Value    ${without_CNI_version}
    ...    ${current_release}
    Set Test Variable    ${With_CNI61110}
    ${_Enabled_}    Set Variable If    ${With_CNI61110}    enabled    Enabled
    ${_Disabled_}    Set Variable If    ${With_CNI61110}    disabled    Disabled
    ${_Online_}    Set Variable If    ${With_CNI61110}    None    Online
    ${_Offline_}    Set Variable If    ${With_CNI61110}    off line    Offline
    ${_Degraded_}    Set Variable If    ${With_CNI61110}    degraded    Degraded
    ${_NotInstalled_}    Set Variable If    ${With_CNI61110}    not installed    NotInstalled
    ${_Failed_}    Set Variable If    ${With_CNI61110}    failed    Failed
    ${_Unlocked_}    Set Variable If    ${With_CNI61110}    unlocked    Unlocked
    ${_Locked_}    Set Variable If    ${With_CNI61110}    locked    Locked
    ${_Com_ShuttingDown_}    Set Variable If    ${With_CNI61110}    Shutting Down    ShuttingDown
    ${_ShuttingDown_}    Set Variable If    ${With_CNI61110}    shutting down    ShuttingDown
    ${_Dependency_}    Set Variable If    ${With_CNI61110}    dependency    Dependency
    ${_PowerOff_}    Set Variable If    ${With_CNI61110}    power off    PowerOff
    ${_Testing_}    Set Variable If    ${With_CNI61110}    testing    Testing
    ${_Initializing_}    Set Variable If    ${With_CNI61110}    initializing    Initializing
    ${_Commissioned_}    Set Variable If    ${With_CNI61110}    commissioned    Commissioned
    ${_NotCommissioned_}    Set Variable If    ${With_CNI61110}    notCommissioned    NotCommissioned
    ${_IntegratedToRan_}    Set Variable If    ${With_CNI61110}    integrated to RAN    IntegratedToRan
    ${_OnAir_}    Set Variable If    ${With_CNI61110}    onAir    OnAir
    ${_Test_}    Set Variable If    ${With_CNI61110}    test    Test
    ${_Configured_}    Set Variable If    ${With_CNI61110}    configured    Configured
    Set Test Variable    ${_Enabled_}
    Set Test Variable    ${_Disabled_}
    Set Test Variable    ${_Online_}
    Set Test Variable    ${_Offline_}
    Set Test Variable    ${_Degraded_}
    Set Test Variable    ${_NotInstalled_}
    Set Test Variable    ${_Failed_}
    Set Test Variable    ${_Unlocked_}
    Set Test Variable    ${_Locked_}
    Set Test Variable    ${_ShuttingDown_}
    Set Test Variable    ${_Com_ShuttingDown_}
    Set Test Variable    ${_Dependency_}
    Set Test Variable    ${_PowerOff_}
    Set Test Variable    ${_Testing_}
    Set Test Variable    ${_Initializing_}
    Set Test Variable    ${_Commissioned_}
    Set Test Variable    ${_NotCommissioned_}
    Set Test Variable    ${_IntegratedToRan_}
    Set Test Variable    ${_OnAir_}
    Set Test Variable    ${_Test_}
    Set Test Variable    ${_Configured_}
    Set Test Variable    ${_Com_Unlocked_}    Unlocked
    Set Test Variable    ${_Com_Locked_}    Locked
    Set Test Variable    ${_Com_Disabled_}    Disabled
    Set Test Variable    ${_Com_Enabled_}    Enabled
    Set Test Variable    ${_Com_Test_}    Test
    Set Test Variable    ${_Blocked_}    Blocked
    Set Test Variable    ${_Unblocked_}    Unblocked
    Set Test Variable    ${_Blocking_}    Blocking
    Set Test Variable    ${_Unblocking_}    Unblocking
    Set Test Variable    ${_Idle_}    Idle
    Set Test Variable    ${_Active_}    Active
    Set Test Variable    ${_Busy_}    Busy
    Set Test Variable    ${_OnAirDone_}    OnAirDone
    Set Test Variable    ${_Validated_}    Validated
    #online status
    Set Test Variable    ${RMOD_expected_state}
    ...    administrativeState=${_Com_Unlocked_}, operationalState=${_Enabled_}, usageState=${_Active_}
    Set Test Variable    ${SMOD_expected_state}
    ...    administrativeState=${_Com_Unlocked_}, operationalState=${_Enabled_}, usageState=${_Active_}
    Set Test Variable    ${BBMOD_expected_state}
    ...    administrativeState=${_Com_Unlocked_}, operationalState=${_Enabled_}, usageState=regex${_Active_}|${_Busy_}
    Set Test Variable    ${ALD_expected_state}    operationalState=${_Enabled_}, availabilityStatus=${_Online_}
    ${basic_state}    Set Variable
    ...    administrativeState=${_Com_Unlocked_}, operationalState=${_Enabled_}, blockingState=${_Unblocked_}
    Set Test Variable    ${cells_GSM_expected_state}
    ...  ${basic_state}, usageState=${_Active_}
    Set Test Variable    ${cells_WCDMA_expected_state}
    ...    operationalState=${_Enabled_}, blockingState=${_Unblocked_}, usageState=${_Active_}
    ${basic_state}    Set Variable
    ...    administrativeState=${_Unlocked_}, operationalState=${_Enabled_}, blockingState=${_Unblocked_}
    Set Test Variable    ${cells_LTE_expected_state}
    ...    ${basic_state}, proceduralState=${_OnAirDone_}
    Set Test Variable    ${cells_NR_expected_state}
    ...    administrativeState=${_Com_Unlocked_}, operationalState=${_Enabled_}, blockingState=${_Unblocked_}
    Set Test Variable    ${dist_GSM_cell_runtime_view}
    ...    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/GNBTS_R-*/GNBCF_R-*/GNCEL_R-*
    #locked status
    Set Test Variable    ${RMOD_locked_state}    administrativeState=${_Com_Locked_}, operationalState=${_Enabled_}
    Set Test Variable    ${SMOD_locked_state}    administrativeState=${_Com_Locked_}, operationalState=${_Enabled_}
    Set Test Variable    ${BBMOD_locked_state}    administrativeState=${_Com_Locked_}, operationalState=${_Enabled_}
    ${basic_state}    Set Variable
    ...    administrativeState=${_Com_Locked_}, operationalState=${_Disabled_}, availabilityStatus="${_Offline_}"
    Set Test Variable    ${cells_GSM_locked_state}    ${basic_state}, blockingState=${_Unblocked_}
    Set Test Variable    ${cells_WCDMA_locked_state}    ${basic_state}, blockingState=${_Unblocked_}
    ${basic_state}    Set Variable
    ...    administrativeState=${_Locked_}, operationalState=${_Disabled_}, availabilityStatus="${_Offline_}"
    Set Test Variable    ${cells_LTE_locked_state}    ${basic_state}, blockingState=${_Unblocked_}
    ${basic_state}    Set Variable
    ...    administrativeState=${_Com_Locked_}, operationalState=${_Disabled_}, availabilityStatus="${_Offline_}"
    Set Test Variable    ${cells_NR_locked_state}    ${basic_state}, blockingState=${_Unblocked_}
    #blocked status
    Set Test Variable    ${cells_GSM_blocked_state}    ${basic_state} , blockingState=${_Blocked_}
    Set Test Variable    ${cells_WCDMA_blocked_state}
    ...  operationalState=${_Disabled_}, availabilityStatus="${_Offline_}", blockingState=${_Blocked_}
    ${basic_state}    Set Variable
    ...    administrativeState=${_Unlocked_}, operationalState=${_Disabled_}, availabilityStatus="${_Offline_}"
    Set Test Variable    ${cells_LTE_blocked_state}    ${basic_state}, blockingState=${_Blocked_}
    ${basic_state}    Set Variable
    ...    administrativeState=${_Com_Unlocked_}, operationalState=${_Disabled_}, availabilityStatus="${_Offline_}"
    Set Test Variable    ${cells_NR_blocked_state}    ${basic_state}, blockingState=${_Blocked_}
    #offline status
    Set Test Variable    ${cells_GSM_offline_state}
    ...  blockingState=${_Unblocked_}, operationalState=${_Disabled_}, availabilityStatus="${_Offline_}"
    Set Test Variable    ${cells_WCDMA_offline_state}
    ...  blockingState=${_Unblocked_}, operationalState=${_Disabled_}, availabilityStatus="${_Offline_}"
    Set Test Variable    ${cells_LTE_offline_state}
    ...  blockingState=${_Unblocked_}, operationalState=${_Disabled_}, availabilityStatus="${_Offline_}"
    Set Test Variable    ${cells_NR_offline_state}
    ...  blockingState=${_Unblocked_}, operationalState=${_Disabled_}, availabilityStatus="${_Offline_}"

Convert Status According To CNI61110
    [Arguments]    ${status}
    [Documentation]    Conver the status to ignore lower/upper case of status.
    ...
    ...    | **Author:** bin7.liu@nokia-sbell.com
    ...    | **Maintainer:** bin7.liu@nokia-sbell.com
    ${availabilityStatus}    Pop From Dictionary    ${status}    availabilityStatus    online
    Set To Dictionary    ${status}    availabilityStatus    ${availabilityStatus}
    ${s_keys}    Get Dictionary Keys    ${status}
    FOR    ${s_key}    IN    @{s_keys}
        ${s_val}    Pop From Dictionary    ${status}    ${s_key}
        ${s_val_upper}    Convert To Upper Case    ${s_val}
        ${s_val_upper_no_space}    Remove String Using Regexp    ${s_val_upper}    \\s+
        Set To Dictionary    ${status}    ${s_key}    ${s_val_upper_no_space}
    END

Get File From System Module
    [Documentation]
    ...    Get File From System Module
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia.com
    ...
    ...    *HISTORY*
    ...    2022.9.29  Add for hran_ta merge to robotws.
    ...     To replace hran_file_operations.hran_file_operations.Get File From System Module
    [Arguments]    ${source_path}    ${destination_path}    ${target_ip}=${SMOD1['TRS_IP']}
    ...    ${target_username}=${SMOD1['USERNAME']}
    ...    ${target_password}=${SMOD1['PASSWORD']}   ${via_ip}=None   ${via_username}=ute    ${via_password}=uteUTE!
    Run Keyword If    '${via_ip}' != 'None'    Get File From Extension    ${source_path}    ${destination_path}
    ...    ${target_username}
    ...    ${target_password}    ${target_ip}    ${via_ip}    ${via_username}    ${via_password}
    ...    ELSE    Get File From Master Sysmod    ${source_path}    ${destination_path}    ${target_username}
    ...    ${target_password}    ${target_ip}

Get File From Master Sysmod
    [Documentation]
    ...    Get File From Master Sysmod
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia.com
    ...
    ...    *HISTORY*
    ...    2022.9.29  Add for hran_ta merge to robotws.
    ...    To replace hran_file_operations.Get File From System Module
    [Arguments]    ${source_path}    ${destination_path}    ${username}=toor4nsn    ${password}=oZPS0POrRieRtu
    ...    ${ip}=192.168.255.129
    SSHLibrary.Open Connection    ${ip}
    SSHLibrary.Login    ${username}    ${password}
    ${file_exists}    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${source_path}
    Run Keyword If    ${file_exists}    SSHLibrary.Get File    ${source_path}    ${destination_path}
    OperatingSystem.File Should Exist    ${destination_path}

Get File From Extension
    [Documentation]
    ...    Get File From Extension
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia.com
    ...
    ...    *HISTORY*
    ...    2022.9.29  Add for hran_ta merge to robotws.
    ...    To replace hran_file_operations.Get File From System Module
    [Arguments]    ${source_path}    ${destination_path}    ${username}=toor4nsn    ${password}=oZPS0POrRieRtu
    ...    ${target_ip}=192.168.255.119    ${via_ip}=''     ${via_username}=ute     ${via_password}=uteUTE!
    SSHLibrary.Open Connection    ${via_ip}
    SSHLibrary.Login    ${via_username}    ${via_password}
    SSHLibrary.Write    ssh ${username}@${target_ip}
    ${output}    Wait Until Keyword Succeeds    5x    5s    SSHLibrary.Read Until Regexp    \[P\|p\]assword:
    SSHLibrary.Write    ${password}
    Wait Until Keyword Succeeds    5x    5s    SSHLibrary.Read Until     >
    SSHLibrary.Write    ls ${source_path}
    ${output}    SSHLibrary.Read    delay=0.5s
    ${file_exists}    Run Keyword And Return Status    Should Contain    ${output}    ${source_path}
    Run Keyword If    ${file_exists}    Run Keywords
    ...    Log    Fail to collect file from Ext model    level=WARN
    ...    AND    Return From Keyword
    ${filename}    Fetch From Right    ${source_path}    /
    SSHLibrary.Write    scp ${source_path} toor4nsn@192.168.255.129:/user/toor4nsn/
    ${output}    Wait Until Keyword Succeeds    5x    5s    SSHLibrary.Read Until Regexp    \[P\|p\]assword:
    SSHLibrary.Write    oZPS0POrRieRtu
    ${output}    SSHLibrary.Read    delay=0.5s
    Wait Until Keyword Succeeds    10s    1s     Should Contain    ${output}    100%
    SSHLibrary.Write    exit
    SSHLibrary.Write    exit
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Get File    /user/toor4nsn/${filename}    ${destination_path}
    SSHLibrary.Write    rm -rf /user/toor4nsn/${filename}
    OperatingSystem.File Should Exist    ${destination_path}

Get Reset Info From File
    [Documentation]
    ...    Get Reset Info From File
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia.com
    ...
    ...    *HISTORY*
    ...    2022.9.29  Add for hran_ta merge to robotws.
    ...    To replace hran_file_operations.Get Reset Info From File
    [Arguments]     ${blackbox_file_path}
    ${file_content}    OperatingSystem.Get File    ${blackbox_file_path}
    #${match}    ${key}    ${rest_count}    Should Match Regexp    ${file_content}    (RESET COUNTER): (\\d+)
    ${file_content}    Fetch From Right     ${file_content}    |\n
    #${file_content}    Fetch From Left    ${file_content}    \nSW VERSION
    ${reset_reason_list}    Split String    ${filecontent}    \n
#    [Return]    ${rest_count}    ${reset_reason_list}
    [Return]    ${reset_reason_list}

Report To Rep With SCF Id
    [Documentation]    This kw is used to send test result to rep with scf id
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | NA| NA| NA |
    ...
    ...    Example
    ...    | Report To Rep With SCF Id |
    Log    Report To Rep With SCF Id    console=True
    ${qc_domain}    Set Variable    MN_RAN
    ${qc_project}    Set Variable    RAN_VRF
    ${ca}    Set Variable    RAN_PZ_HAZ_1
    ${case_result}    Set Variable    passed
    #${testline_id}
    ${testline_id_existed}    Run Keyword And Return Status    Variable Should Exist    ${testline_id}
    ${bts_info}    coam.get_bts_info
    ${current_bts_id}    Set Variable    ${bts_info["mrbtsID"]}
    ${testline_id1}    Set Variable If    ${testline_id_existed}    ${testline_id}    10_5_SRAN-MRBTS-${current_bts_id}
    ${testline_id2}    Set Variable If    ${testline_id_existed}    ${testline_id}    10_5_UTESRAN${current_bts_id}
    ${tl_id}    Set Variable If    ${testline_id_existed}    ${testline_id}    ${current_bts_id}
    #${build}
    ${build_existed}    Run Keyword And Return Status    Variable Should Exist    ${build}
    ${bts_SW_list}=    Admin Get BTS SW Version
    ${active SW}    Set Variable    ${bts_SW_list[0]}
    ${active_prefix}    Fetch From Left    ${active SW}    _
    ${current_build}    Run Keyword If    "${active_Prefix}" == "${Trunk_Prefix}"    Replace String    ${active SW}    ${active_prefix}    SBTS00
    ...    ELSE    Set Variable    ${active SW}
    ${build}    Set Variable If    ${build_existed}    ${build}    ${current_build}
    #${scf_id}
    ${Report_Rep_existed}    Run Keyword And Return Status    Variable Should Exist    ${Report_Rep}
    ${Report_Rep}    Set Variable If    ${Report_Rep_existed}    ${Report_Rep}    False
    ${no_ute}    Set Variable If    "${Report_Rep.upper()}" == "TRUE"    ${True}    ${False}
    ${scf_id_status1}    ${scf_id1}    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    bts_id=${testline_id1}    no_ute=${no_ute}
    ${scf_id_status2}    ${scf_id2}    Run Keyword If    "${scf_id_status1}" != "PASS"    Run Keyword And Ignore Error
    ...    Get SCF Internal Id By Scout    bts_id=${testline_id2}    no_ute=${no_ute}
    Return From Keyword If    "${Report_Rep.upper()}" != "TRUE"
    ${scf_id}    Set Variable If    "${scf_id_status1}" == "PASS"    ${scf_id1}    ${scf_id2}
    ${qc_id}    Set Variable    ${qc_instance_id}
    ${case_name}    Set Variable    ${test_run}
    #${tl_name}
    ${tl_name_existed}    Run Keyword And Return Status    Variable Should Exist    ${tl_name}
    ${tl_name}    Set Variable If    ${tl_name_existed}    ${tl_name}    SRAN_Hangzhou_${tl_id}
    ${qc_update_variables}    Set Variable
    ...    '${qc_domain}' '${qc_project}' '${ca}' '${case_name}' '${case_result}' '${build}' '${tl_name}' '${qc_id}' '${scf_id}'
#    ${send_cmd}    Catenate    python ${SEND_REP_PYTHON_CODE_PATH} ${qc_update_variables}
#    run keyword if    "${scf_id_status1}" != "PASS" and "${scf_id_status2}" != "PASS"    Fail    Get Scf id from Scout failed!
#    ${ret}    OperatingSystem.Run    ${send_cmd}
#    Log To Console    ${ret}
     ${link_to_reporting_portal}=
    ...  ute_reporting_portal.report to rp
    ...  name=${case_name}
    ...  result=${case_result}
    ...  ca=${ca}
    ...  testline=${tl_name}
    ...  build=${build}
    ...  qc_domain=${qc_domain}
    ...  qc_project=${qc_project}
    ...  qc_id=${qc_id}
    #...  comment=${comment}
    ...  tc_execution_id=${scf_id}
    Log To Console    ${link_to_reporting_portal}

Get SCF Internal Id By Scout
    [Arguments]    ${bts_id}=${TESTLINE_NAME}    ${no_ute}=${True}
    [Documentation]    This kw is used to get scf id from scout by testline id
    ...    Author: Xu Yuyan
    ...    | Input Parameters | Man. | Description |
    ...    | bts_id | yes | use the scout testline id ,usually is bts id |
    ...    | no_ute | yes | if you use CM single run or auto trigger, please set False |
    ...
    ...    | Return Value | Description |
    ...    | scf_id | the internal id from scout |
    ...
    ...    Example
    ...    | Get SCF Internal Id By Scout | testline_name=6141 |
    [Timeout]    3 minutes
    scout.setup_scout    ${bts_id}
    ${scf_id}    scout.request_scf    use_scout_internal_id=${no_ute}
    Log to Console    scf id is: ${scf_id}
    [Teardown]    scout.teardown_scout_api
    [Return]    ${scf_id}

NOM Common Test Setup
    [Arguments]   ${PrecheckConf}=${TRUE}   ${PrecheckCells}=${TRUE}   ${PrecheckModules}=${TRUE}
    ...    ${ReIntegrateNE}=${TRUE}
    [Documentation]    Set of actions which will be launched before each test.
    ...    A failure of any step here leads to the Jenkins TcVerdict set to NoRun.
    ...    List of actions:
    ...    -> Hran_ta Preconditions: Gets hran_ta workspace version based on information from GIT
    ...    Creates log directories
    ...    Initializes variables used for test_verdict calculation
    ...   -> Deletes content of /tmp and /home/ute/btsauto/logs in order to free up space,
    ...    to insure robot tests are able to run
    ...   -> Starts Admin connection
    ...   -> Starts Infomodel on LTE site
    ...   -> Gets and displays SW versions
    ...   -> Checks cells and modules state and active alarms
    ...   -> For TcVerdict calculations, checks NOM Customizable Preconditions (BTS configuration,
    ...    cells and modules state) ...
    ...    | Parameter | Man. | Description |
    ...    | PrecheckCells | No | Flag for enabling/disabling cells precheck, result used for TcVerdict evaluation |
    ...    | PrecheckModules | No | Flag for enabling radio modules precheck, result used for TcVerdict evaluation |
    ...
    ...    *EXAMPLE*
    ...    | Common Test Setup | ${TRUE} | ${FALSE} | ${TRUE} | all | ${FALSE} |
    ...    | Common Test Setup |
    ...    | Common Test Setup | PrecheckCells=${FALSE} |
    [Timeout]    20 minutes
    hran_general.Hran_ta Preconditions
    Create 'NOMLogs' in '${Test Results Dir}' And Set Test Variable
    Set Test Variable    ${admin_started}    ${FALSE}
    Set Test Variable    ${SnapshotTriggerEndTest}    NO
    Set Test Variable    ${SkipCellsAndRmsNumberCheck}    False
    Screenshot.Set Screenshot Directory    path=${Test Results Dir}/NOMLogs
    Clean VM Disk Space    Master
    There should be at least 2048 MB of disk space available in /home/ute
    # product-specific part of precondititons:
    Log    TC executed with configuration files of ${HW_LOCATION_CODE}\\${TESTLINE_NAME}    level=INFO    console=True
    Set Tags    ${HW_LOCATION_CODE}\\${TESTLINE_NAME}
    ${hran_config_model}    Run Keyword And Return Status    hran_testline_configuration.Set Config Variables
    ...    @{TESTLINE_CONFIG_VARIABLES}
    Run keyword if    ${hran_config_model}    Run Keywords    Log    Running tests in HRAN_TA mode    console=True
    ...    AND    Clean VM Disk Space    Master
    ...    ELSE    Run Keywords    Log    Running tests from UTE_CLOUD    console=True
    ...    AND    Additional variables loader
    Log Variables    level=DEBUG
    Run Keyword And Continue On Failure    Start Admin    bts_host=${SMOD1['TRS_IP']}
    Run Keyword And Continue On Failure    Start Infomodel
    Run Keyword And Continue On Failure    Setup NOM By TAF
    Run Keyword And Continue On Failure    Print Active And Passive SW Version
    Set Service Access Configuration SyVe    False
    Set Expected Object Status
    Set Ethernet Port Security    False
    SyVe Customizable Preconditions   CheckConf=${PrecheckConf}   CheckCells=${PrecheckCells}
    ...    CheckModules=${PrecheckModules}
    Setup Global NE Variables
    ${timestamp}    Generate Formatted Timestamp
    Run Keyword If   ${ReIntegrateNE}   NOM Integrate NE   ${integrate_plan_path}   ${integrate_plan_name}_${timestamp}
    Log    End of Common Test Setup   level=TRACE    console=True

NOM Common Test Teardown
    [Arguments]    ${SNAPSHOT ON FAILURE}=YES    ${ERROR NUMBER TRESHOLD}=0
    [Documentation]    This is a set of actions which will be launched after each NOM test ends.
    ...    A failure of any step here leads to the Jenkins TcVerdict set to Passed_With_Restriction,
    ...    if the other parts of the test are passed. Otherwise, a failure here will not influence the TcVerdict.
    ...    List of actions:
    ...    -> Triggers snapshot if test result is Passed_With_Restriction or Failed or if an Error
    ...    was logged.
    ...    Snapshot can be disabled by argument ${Snapshot On Failure} != YES.
    ...    Snapshot triggering can be conditioned be done if more than a treshold number of errors found.
    ...    -> Collect RM logs if test result is Failed or if an Error was logged.
    ...    -> Gets and displays siteName information
    ...    -> Collects files and stops ADMIN sessions
    ...    -> Collects ADMIN_INFOMODEL files and stops ADMIN_INFOMODEL session
    ...    -> Runs Hran_ta Postconditions: Currently only logs a message signalling end of Common Test Teardown.
    ...
    ...    | Parameter | Man. | Description |
    ...    | SNAPSHOT ON FAILURE | No | Flag for enabling/disabling snapshot trace in case of Test case failure |
    ...    | ERROR NUMBER TRESHOLD | No | Flag indicating the number of ERRORs logged needed to trigger snapshot trace|
    ...
    ...    *EXAMPLE*
    ...    | Common Test Teardown | YES | 2 |
    ...    | Common Test Teardown | SNAPSHOT ON FAILURE=YES |
    ...    | Common Test Teardown |
    ...    -> Snapshot activated in case of failure, or in case of more than 2 errors logged
    Log    Common Test Teardown    level=TRACE    console=True
    Run Keyword And Ignore Error    Run Keyword If Test Passed    Report To Rep With SCF Id
    ${errors}    Get Variable Value    ${error_message_count}    ${0}
    ${condition1}    Set Variable
    ...    ('${SnapshotTriggerEndTest}' == 'YES' or '${TEST STATUS}' == 'FAIL' or ${errors} > ${ERROR NUMBER TRESHOLD})
    Run Keyword If    ${condition1} and '${SNAPSHOT ON FAILURE}' == 'YES'
    ...    Get Snapshot and Active Alarms
    #2022-07-07:Xu Yuyan add for Enable Sleeping Cell feature
    Run Keyword And Ignore Error    interface.Common step trigger
    # product-specific part of precondititons:
    Run Keyword And Continue On Failure    BTS SiteName information
    Run Keyword And Continue On Failure    Collect Admin
    Run Keyword And Continue On Failure    Collect Infomodel
    Run Keyword And Continue On Failure    Teardown NOM By TAF
    # hran_ta postcondititons:
    hran_general.Hran_ta Postconditions

Setup Global NE Variables
    ${CM_NE_ID}    Fetch From Right    ${MRBTS_DN}    /
    ${NE_INTEGRATED_ID}    Create List    ${CM_NE_ID}
    Set Test Variable     ${NE_INTEGRATED_ID}
    Set Test Variable     ${CM_NE_ID}
    ${NE_LNBTS}    Run Keyword If    ${LTE_cell_ids}    Fetch Class_NOKLTE:LNBTS From SCF_${BTS_scf_initial}
    ...    ELSE    Set Variable    LNBTS-0
    ${NE_NRBTS}   Run Keyword If  ${NRBTS_cell_ids}  Fetch Class_com.nokia.srbts.nrbts:NRBTS From SCF_${BTS_scf_initial}
    ...    ELSE    Set Variable    NRBTS-0
    Set Test Variable    ${NE_LNBTS}
    Set Test Variable    ${NE_NRBTS}

Set Variable For Multi NE
    [Arguments]    ${second_ne}
    ${NE_INTEGRATED_ID_MULTI}    Create List    ${CM_NE_ID}    ${second_ne}
    Set Test Variable    ${NE_INTEGRATED_ID_MULTI}
    ${ne_list}    Create List    ${second_ne}
    ${export_plan}   Set Variable     ${Test Results Dir}/NOMLogs/cm_export_actual_plan_sec_ne.xml
    CM Export Actual Configuration NOM Open API    ${ne_list}   ${export_plan}
    ${NE_LNBTS2}    Run Keyword If    ${LTE_cell_ids}    Fetch Class_NOKLTE:LNBTS From SCF_${export_plan}
    ...    ELSE    Set Variable    LNBTS-0
    ${NE_NRBTS2}   Run Keyword If    ${NRBTS_cell_ids}   Fetch Class_com.nokia.srbts.nrbts:NRBTS From SCF_${export_plan}
    ...    ELSE    Set Variable    NRBTS-0
    Set Test Variable    ${NE_LNBTS2}
    Set Test Variable    ${NE_NRBTS2}

Fetch Class_${SPEC_RAT_CLASS} From SCF_${SPEC_BTS_SCF}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${SPEC_BTS_SCF}
    ${obj}=    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@class,"${SPEC_RAT_CLASS}")]
    ${tmp_dn}    Run Keyword If    ${obj}    L_XML.Get Element Attribute    ${obj[0]}    distName
    ${DN}    Fetch From Right    ${tmp_dn}    /
    [Return]     ${DN}

Setup NOM By TAF
    [Documentation]    Keyword used to delete existing client and setup NOM
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    Run Keyword And Ignore Error    Delete Existing Client   ${NOM['NOM_OPEN_API_CLIENT_ID']}
    ...    ${NOM['NOM_OPEN_API_USERNAME']}
    ...    ${NOM['NOM_OPEN_API_PASSWORD']}   ${NOM['NOM_OPEN_API_GW']}
    ${NOM_OPEN_API_CLIENT_SECRET}    nom.Register The Client    ${NOM['NOM_OPEN_API_CLIENT_ID']}
    ...    ${NOM['NOM_OPEN_API_USERNAME']}    ${NOM['NOM_OPEN_API_PASSWORD']}    ${NOM['NOM_OPEN_API_GW']}
    ${status}    Run Keyword And Return Status    nom.Connect To    ${NOM['BASE_DOMAIN']}
    ...    ${NOM['NOM_OPEN_API_GW']}
    ...    ${NOM['NOM_OPEN_API_CLIENT_ID']}    ${NOM_OPEN_API_CLIENT_SECRET}     443    ${NOM['NOM_OPEN_API_USERNAME']}
    ...    ${NOM['NOM_OPEN_API_PASSWORD']}    nom_v1    True
    Run Keyword If    ${status}    Log    Setup NOM session success    console=True
    ...    ELSE    FAIL    Setup NOM session fail!

Teardown NOM By TAF
    [Documentation]    Keyword used to tear down NOM and delete client
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    Run Keyword And Ignore Error    Delete Existing Client    ${NOM['NOM_OPEN_API_CLIENT_ID']}
    ...    ${NOM['NOM_OPEN_API_USERNAME']}
    ...    ${NOM['NOM_OPEN_API_PASSWORD']}   ${NOM['NOM_OPEN_API_GW']}

Delete Existing Client
    [Arguments]    ${client_id}    ${openapi_username}    ${openapi_password}    ${openapi_gw}
    [Documentation]    This keyword deletes the client id from user management application
    nom.Delete The Client    ${client_id}     ${openapi_username}    ${openapi_password}    ${openapi_gw}

CM Plan Import NOM Open API
    [Arguments]    ${plan_path}    ${plan_name}
    [Documentation]    Import CM plan to CM persistence service through NOM Open API
    ${status}=    Run Keyword And Return Status    nom.Import Plan    ${plan_path}    name=${plan_name}
    Run Keyword If    ${status}    Log    Plan ${plan_name} import success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} import fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} import is fail!

CM Plan Download NOM Open API
    [Arguments]     ${plan_name}    ${timeout}=30s
    [Documentation]    Download CM plan through NOM Open API
    ${status}=    Run Keyword And Return Status    nom.Download Plan    ${plan_name}    ${timeout}
    Run Keyword If    ${status}    Log    Plan ${plan_name} download success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} download fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} download is fail!

CM Plan Validate NOM Open API
    [Arguments]     ${plan_name}    ${timeout}=120s
    [Documentation]    Validate CM plan through NOM Open API
    ${status}=    Run Keyword And Return Status    nom.Validate Plan    ${plan_name}    ${timeout}
    Run Keyword If    ${status}    Log    Plan ${plan_name} validate success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} validate fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} validate is fail!

CM Plan Activate NOM Open API
    [Arguments]     ${plan_name}    ${timeout}=120s
    [Documentation]    Activate CM plan through NOM Open API
    ${status}=    Run Keyword And Return Status    nom.Activate Plan    ${plan_name}    ${timeout}
    Run Keyword If    ${status}    Log    Plan ${plan_name} Activate success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} Activate fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} Activate is fail!

CM Plan Provision NOM Open API
    [Arguments]     ${plan_name}    ${rollback_plan_generation}=False    ${timeout}=150s
    [Documentation]    Provision CM plan through NOM Open API
    ${status}=    Run Keyword And Return Status    nom.Provision Plan    ${plan_name}
    ...    ${rollback_plan_generation}    ${timeout}
    Run Keyword If    ${status}    Log    Plan ${plan_name} Provision success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} Provision fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} Provision is fail!

NOM Integrate NE
    [Arguments]   ${integrate_plan_path}   ${integrate_plan_name}   ${timeout}=120s   ${reintegrate}=True   ${tls}=off
    ${commission_str1}    Set Variable
    ...    [{"distName": "${CM_NE_ID}/MNL-1/MNLENT-1/MPLANENW-1", "operation": "update",
    ${commission_str2}    Set Variable
    ...    "parameters": [{"parameterName": "oamTls", "operation": "update", "value": "${tls}"}]}]
    coam.perform_delta_recommissioning    ${commission_str1} ${commission_str2}    True
    CM Plan Import NOM Open API    ${integrate_plan_path}   ${integrate_plan_name}
    ${status}    Run Keyword And Return Status    nom.Integrate NE
    ...    ${integrate_plan_name}    ${timeout}   ${reintegrate}
    Run Keyword If    ${status}    Log    Integration ${MRBTS_DN} success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Integration ${MRBTS_DN} fail.    level=ERROR
    ...    AND    Fail    Integration ${MRBTS_DN} fail!

Generate Formatted Timestamp
    [Documentation]
    ...  *AUTHOR*
    ...  lixin.kang@nokia-sbell.com
    ${year}    ${month}    ${day}    ${hour}    ${min}    ${sec}=    Get Time    format=year,month,day,hour,min,sec
    ${current_time}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}-${sec}
    [Return]  ${current_time}

CM Parameter Upload NOM Open API
    [Arguments]    ${integrated_ids}    ${timeout}=120s
    [Documentation]    Trigger CM Upload
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    ${status}    Run Keyword And Return Status    nom.Upload Parameter    ${integrated_ids}    ${timeout}
    Run Keyword If    ${status}    Log    CM parameter upload finished successful.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    CM parameter upload fail.    level=ERROR
    ...    AND    Fail    CM parameter upload fail!

CM Export Actual Configuration NOM Open API
    [Arguments]     ${integrated_dns}    ${output_actuals_file}
    [Documentation]   Export actual plan from NOM Open API for one or more NE
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    Create File    ${output_actuals_file}
    ${file_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${output_actuals_file}
    ${status}    Run Keyword And Return Status    nom.Export Plan    ${output_actuals_file}    ${integrated_dns}
    Run Keyword If    ${status} and ${file_exist}
    ...    Log    Export actual plan finished successful.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Export actual plan fail.    level=ERROR
    ...    AND    Fail    Export actual plan fail!

Check CM Parameter Value From NOM Actual Plan
    [Arguments]    ${integrated_dn}    ${dist_name}    &{parameters_dict}
    [Documentation]    Check Actual Configuration Paramters
    ...
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    Log    Check Actual Configuration Parameters    console=True
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}=    Run Keyword And Return Status    CM Export Actual Configuration NOM Open API
    ...    ${integrated_dn}    ${Test Results Dir}/NOMLogs/cm_export_actual_plan.xml
    ${param_names}    Get Dictionary Keys    ${parameters_dict}
    ${param_values}    Get Dictionary Values    ${parameters_dict}
    ${param_count}    Get Length    ${param_names}
    ${scf_xml}=    L_XML.Parse Xml    ${Test Results Dir}/NOMLogs/cm_export_actual_plan.xml
    ${object}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${dist_name}"]
    ${obj_count}    Get Length    ${object}
    Should Be Equal As Integers    ${obj_count}    ${1}
    FOR    ${index}    IN RANGE    0    ${param_count}
        ${actual_value}    Set Variable If    '${param_values[${index}]}'=='None'    ${EMPTY}    ${param_values[${index}]}
        ${is_string}    Run Keyword And Return Status    Should Be String    ${actual_value}
        Run Keyword If    ${is_string}    Compare String Value In XML
        ...    ${scf_xml}    true    ${dist_name}    ${param_names[${index}]}    ${actual_value}
        ...    ELSE    Compare Unstring Value In XML    ${scf_xml}   true    ${dist_name}    ${param_names[${index}]}
        ...    ${actual_value}
    END

Get Actual Parameter Value From NOM
    [Arguments]    ${integrated_dn}    ${dist_name}    ${param}
    [Documentation]    Get and return the actual value of the given parameter
    ...
    ...    | **Author:** lixin.kang@nokia-sbell.com
    ...    | **Maintainer:** lixin.kang@nokia-sbell.com
    ...    | **Released with version:**
    ...
    ...    **Input Parameters:**
    ...    +-------------------+------+----------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+======================================================================+=====+
    ...    | dist_name| distName of element
    ...    | param| Specifical parameter to check
    ...    | ui_values| default is false
    ...
    ...    **Return Parameters:**
    ...    +----------------+---------------------------------------------------------------------------------------+
    ...    | Parameter name | Description |
    ...    +================+======================================================================================+
    ...    | actual_value | actual parameter value from NetAct |
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}    Run Keyword And Return Status    CM Export Actual Configuration NOM Open API
    ...    ${integrated_dn}   ${Test Results Dir}/NOMLogs/cm_export_actual_plan.xml
    ${scf_xml}=    L_XML.Parse Xml    ${Test Results Dir}/NOMLogs/cm_export_actual_plan.xml
    ${actual_value}   L_XML.Get Element Text   ${scf_xml}   .//managedObject[@distName="${dist_name}"]/p[@name="${param}"]
    [Return]    ${actual_value}

Deploy CMP Client Parameters
    [Arguments]     ${integrated_ids}    ${cmp_attr}    ${timeout}=120s
    ${status}   Run Keyword And Return Status   nom.Configure CMP   ${integrated_ids}   ${cmp_attr}   ${timeout}
    Run Keyword If    ${status}    Log    CMP parameters config success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    CMP parameters config fail.    level=ERROR
    ...    AND    Fail    CMP parameters config fail!

Initial CMP Configurations
    [Arguments]     ${integrated_ids}    ${timeout}=180s
    ${status}    Run Keyword And Return Status   nom.Initialize CMP    ${integrated_ids}    ${timeout}
    Run Keyword If    ${status}    Log    CMP config initialized success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    CMP config initialized fail.    level=ERROR
    ...    AND    Fail    CMP config initialized fail!

Trigger CMP Key Update
    [Arguments]     ${integrated_ids}    ${timeout}=180s
    ${status}    Run Keyword And Return Status   nom.Update CMP Key    ${integrated_ids}    ${timeout}
    Run Keyword If    ${status}    Log    CMP Key Update success.    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    CMP Key Update fail.    level=ERROR
    ...    AND    Fail    CMP Key Update fail!

Generate CM Plan With Timestamp from XML Template For NOM Open API
    [Arguments]    ${plan_template_path}
    [Documentation]     Generate json file from a json template NOM Open API
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    ${timestamp}=    Generate Formatted Timestamp
    Set Test Variable    ${timestamp}
    Set Test Variable    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}    ${timestamp}_${PLAN_FILE_GENERATED_NOM_OPEN_API}
    ${file_content}    OperatingSystem.Get File    ${plan_template_path}
    ${file_content}    Replace Variables    ${file_content}
    Create File     ${NOMLogs}/${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}   ${file_content}
    Set Test Variable    ${PLAN_FILE_IMPORT_PATH}    ${NOMLogs}/${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}

Generate Random Test Data
    [Arguments]    ${actual_plan}    ${source_json}    ${index}=${EMPTY}
    [Documentation]    Generate random test data for plan xml from parameters json file and set data as test variables.
    ...               The variables will replace the ones in xml plan file
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    Set Test Variable    ${ORIGINAL_VALUE${index}}    ${EMPTY}
    ${file_content}    OperatingSystem.Get File    ${source_json}
    ${file_content}    Replace Variables    ${file_content}
    ${file_content_formatted}    Replace String    ${file_content}    ${CM_NE_ID}     ${CM_NE_ID${index}}
    ${file_content_formatted}    Replace String    ${file_content_formatted}    ${NE_LNBTS}     ${NE_LNBTS${index}}
    ${file_content_formatted}    Replace String    ${file_content_formatted}    ${NE_NRBTS}     ${NE_NRBTS${index}}
    ${TEST_DATA}    Evaluate    ${file_content_formatted}
    Set Test Variable    ${TEST_DATA}
    ${count}    Get Length    ${TEST_DATA}
    ${random}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    Set Test Variable    ${TEST_DATA_SELECTED}   ${TEST_DATA[${random}]}
    Set Test Variable    ${DN_NAME${index}}    ${TEST_DATA_SELECTED["Parameters"][0]["distName"]}
    Set Test Variable    ${OPERATION${index}}    ${TEST_DATA_SELECTED["Parameters"][0]["operation"]}
    ${PARAM_NAMES}    Get Dictionary Keys    ${TEST_DATA_SELECTED["Parameters"][0]["parameters"][0]}
    Set Test Variable    ${PARAM_NAME${index}}    ${PARAM_NAMES[0]}
    ${PARAM_VALUES}    Get Dictionary Values    ${TEST_DATA_SELECTED["Parameters"][0]["parameters"][0]}
    ${cur_value}    Get CM Parameter Value From SCF    ${actual_plan}    ${DN_NAME${index}}    ${PARAM_NAME${index}}
    ${cur_value}    Set Variable If   '${cur_value}'=='Not found'    ${EMPTY}    ${cur_value}
    Run Keyword If    '${ORIGINAL_VALUE${index}}'==''
    ...    Set Test Variable    ${ORIGINAL_VALUE${index}}    ${cur_value}
    Remove Values From List    ${PARAM_VALUES[0]}    ${ORIGINAL_VALUE${index}}
    ${count}    Get Length    ${PARAM_VALUES[0]}
    ${random}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    Set Test Variable    ${PARAM_VALUE${index}}    ${PARAM_VALUES[0][${random}]}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${actual_plan}
    ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${DN_NAME${index}}"]
    Set Test Variable    ${cmplan_moclass_version_in_actuals${index}}    ${MO_items['version']}
    Set Test Variable    ${cmplan_moclass_in_actuals${index}}    ${MO_items['class']}

Create Random Test Data JSON
    [Arguments]    ${source_json}    ${target_json}=${NOMLogs}/tmp_data.json
    [Documentation]    Generate random test data and generate json file with admin supported format
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    ${TEST_DATA} =     Get Test Data From Json     ${source_json}
    Set Test Variable    ${TEST_DATA}
    ${count}    Get Length    ${TEST_DATA}
    ${random}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    Set Test Variable    ${TEST_DATA_SELECTED}    ${TEST_DATA[${random}]}
    Set Test Variable    ${DN_NAME}    ${TEST_DATA_SELECTED["Parameters"][0]["distName"]}
    Set Test Variable    ${OPERATION}    ${TEST_DATA_SELECTED["Parameters"][0]["operation"]}
    ${PARAM_NAMES}    Get Dictionary Keys    ${TEST_DATA_SELECTED["Parameters"][0]["parameters"][0]}
    Set Test Variable    ${PARAM_NAME}    ${PARAM_NAMES[0]}
    ${PARAM_VALUES}    Get Dictionary Values    ${TEST_DATA_SELECTED["Parameters"][0]["parameters"][0]}
    ${BTS_scf}=    Admin Collect SCF.xml With Timestamp    folder_path=${BTSFiles}
    ${current_param_value}=    Get Original Parameter Value From SCF    ${BTS_scf}    ${DN_NAME}    ${PARAM_NAME}
    Remove Values From List    ${PARAM_VALUES[0]}    ${current_param_value}
    ${count}    Get Length    ${PARAM_VALUES[0]}
    ${random}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    Set Test Variable    ${PARAM_VALUE}    ${PARAM_VALUES[0][${random}]}
    ${template_content}    Get Test Data From Json    ${TEST_DATA_PATH}/${DELTA_COMMISSION_TEMPLATE}
    ${file_str} =     Convert To String     ${template_content}
    Create File     ${target_json}     ${file_str.replace("'",'"')}

Get Test Data From Json
    [Arguments]    ${json_file}
    [Documentation]    Get content from Json file and format it to test data
    ...
    ...    | **Author:** yuyan.xu@nokia-sbell.com
    ...    | **Maintainer:** yuyan.xu@nokia-sbell.com
    ...    | **Released with version:** ---
    ...
    ...    **Input Parameters:**
    ...
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | json_file | yes | Path for source json file |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...
    ...    **Return Parameters:**
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...    | Parameter name | Man. | Description | Default |
    ...    +===================+======+==========================================================================+=====+
    ...    | test_data | formatted test data string |
    ...    +-------------------+------+--------------------------------------------------------------------------+-----+
    ...
    ...    **Example of simple usage:**
    ...    Get Test Data From Json TestDataSet/DeltaCommission/${TEST_NAME}.json
    ${file_content}    OperatingSystem.Get File    ${json_file}
    ${file_content}    Replace Variables    ${file_content}
    ${test_data}    Evaluate    ${file_content}
    [Return]    ${test_data}

Get Original Parameter Value From SCF
    [Arguments]    ${original_scf}    ${scf_distName}    ${param_name}
    [Documentation]    Get parameter value from the SCF saved by admin
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${original_scf}
    ${result_value}=    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${scf_distName}"]/p
    ${result_value_dict}=    Create dictionary
    FOR    ${item}    IN    @{result_value}
        ${name}    L_XML.Get Element Attribute    ${item}    name
        ${value}    L_XML.Get Element Text    ${item}
        Return From Keyword If    '${name}' == '${param_name}'    ${value}
    END

Get CM Parameter Value From SCF
    [Arguments]     ${plan}    ${scf_distName}    ${param}
    [Documentation]    Get parameter value from SCF plan
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${plan}
    ${status}    ${actual_value}   Run Keyword And Ignore Error     L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${scf_distName}"]/p[@name="${param}"]
    ${actual_value}    Set Variable If    '${status}'!='PASS'    Not found     ${actual_value}
    [Return]    ${actual_value}

Change Password For NE
    [Arguments]    ${NE_ACCOUNT_TYPE}    ${NE_ID}    ${NE_PWD_RESET_USER}    ${NE_PWD_RESET_PASSWORD}
    [Documentation]    Change NE password for specific user type through nom open api
    ...    *AUTHOR*
    ...    lixin.kang@nokia-sbell.com
    &{NE_DATA}    Create Dictionary    account_type=${NE_ACCOUNT_TYPE}
    ...    element_id=${NE_ID}
    ...    username=${NE_PWD_RESET_USER}
    ...    password=${NE_PWD_RESET_PASSWORD}
    ${status}    Run Keyword And Return Status    nom.Reset Network Elements Password     ${NE_DATA}
    Run Keyword If    ${status}
    ...    Log    Change NE password success for ${NE_ACCOUNT_TYPE}:${NE_PWD_RESET_USER}   level=INFO    console=True
    ...    ELSE   Run Keywords   Log   Change NE password fail for ${NE_ACCOUNT_TYPE}:${NE_PWD_RESET_USER}.  level=ERROR
    ...    AND    Fail    Change NE password fail for ${NE_ACCOUNT_TYPE}:${NE_PWD_RESET_USER}!

Download SBTS SW Build
    [Arguments]    ${target_sw_name}    ${target_sw_path}=/home/ute/Downloads    ${release_name}=SBTS00    ${clean_folder}=${TRUE}
    [Documentation]    Helper keyword for downloading SBTS sw builds
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | target_sw_name | Yes | e.g. SBTS00_ENB_9999_230301_000013 |
    ...    | target_sw_path | Yes | the path you want to save in local vm |
    ...    | release_name | Yes | default is: SBTS00 |
    ${download_command}    Set Variable    wget    #sudo wget --progress=dot:giga -T 600 -t 2
    ${download_source_path}    Set Variable
    ...    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/${release_name}
    ${status}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${target_sw_path}
    Run Keyword If    not ${status}    OperatingSystem.Create Directory    ${target_sw_path}
    ${remove_files_cmd}    Set Variable    sudo rm -rf ${target_sw_path}/*
    Run Keyword If    ${clean_folder}    OperatingSystem.Run    ${remove_files_cmd}
    Log To Console    \nStart Download SW:${target_sw_name}...........
    ${target_sbts_pkg_name}    Set Variable    ${target_sw_name}_release_BTSSM_downloadable_A54.zip
    Wait Until Keyword Succeeds    20 minutes    5s    OperatingSystem.Run
    ...    ${download_command} ${download_source_path}/${target_sw_name}/${target_sbts_pkg_name} -O ${target_sw_path}/${target_sw_name}.zip
    Log To Console    \nComplete Download SW:${target_sw_name}...........

Admin Upgrade SBTS SW
    [Arguments]    ${target_sw_name}    ${target_sw_path}=/home/ute/Downloads
    [Documentation]   Upgrade SBTS sw build from Admin
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | target_sw_path | Yes | the path where the targe build saved in local vm|
    ...    | target_sw_name | Yes | the target sw build name to upgrade|
    Log    Start SW Upgrade to ${target_sw_name}...........    console=${TRUE}
    ${sw_update_result}    ${sw_update_msg}=    Run Keyword And Ignore Error
    ...    coam.Update Software    ${target_sw_path}/${target_sw_name}.zip    True    5400
    Run keyword if    '${sw_update_result}'=='FAIL'    Fail    Software update failed: ${sw_update_msg}
    Log    Finish SW Upgrade to ${target_sw_name}...........    console=${TRUE}
    Sleep   2m
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

Import SBTS SW Build To NetAct
    [Arguments]    ${target_sw_name}    ${target_sw_path}=/home/ute/Downloads    ${netact_swm_path}=/d/oss/global/swmanager/swm_temp
    [Documentation]    Helper keyword for importing SBTS sw builds to NetAct
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | target_sw_name | Yes | e.g. SBTS00_ENB_9999_230301_000013.zip|
    ...    | target_sw_path | Yes | the pkg saved in local vm path |
    ...    | netact_swm_path | Yes | pkg path in NetAct:/d/oss/global/swmanager/swm_temp|
    ${netactcon}    tafssh.Connect To    ${NETACT['was_host']}    root    arthur
    Log To Console    \nStart Copy SW to NetAct...........
    tafssh.Upload File    ${target_sw_path}/${target_sw_name}.zip    ${netact_swm_path}/${target_sw_name}.zip
    Log To Console    \nFinish Copy SW to NetAct...........
    tafssh.Send Command     chmod 777 ${netact_swm_path}/${target_sw_name}.zip
    Log To Console    \nStart Import SBTS SW:${target_sw_name}...........
    netact.Import Build   ${netact_swm_path}/${target_sw_name}.zip    clean_temp_storage=True
    Log To Console    \nComplete Import SBTS SW:${target_sw_name}...........
    [Teardown]    Run Keyword And Ignore Error    tafssh.Disconnect    ${netactcon}

#--------------------------------------------------------*Wireshark*---------------------------------------------------#
Start TCPDump On SBTS Common
    [Arguments]     ${tcpdump_file_name}=${TEST_NAME}
    [Documentation]    Start wireshark log collection on SBTS
    ...    Contact: lixin.kang@nokia-sbell.com
    ${hosts_of_NetAct}    Get Dictionary Values    ${NETACT}
    FOR    ${value}    IN    @{hosts_of_NetAct}
        ${is_ip_address}    Run Keyword And Return Status    Should Match Regexp    ${value}
        ...    ^((25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d)))\\.){3}(25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d)))$
        Continue For Loop If    ${is_ip_address}
        Remove Values From List    ${hosts_of_NetAct}    ${value}
    END
    ${host_str}    Catenate    SEPARATOR=${SPACE}or${SPACE}host${SPACE}    @{hosts_of_NetAct}
    ${ssh_connection}    Establish SSH to SBTS    ${SMOD1['IP']}
    Execute CMD Via SSH connection
    ...    nohup tcpdump -i any -w ~/${tcpdump_file_name}.pcap host ${host_str} > out.log 2>&1 &    root\@
    SSHLibrary.Close Connection

Stop TCPDump On SBTS Common
    [Documentation]    Stop wireshark log collection on SBTS
    ...    Contact: lixin.kang@nokia-sbell.com
    ${ssh_connection}    Establish SSH to SBTS    ${SMOD1['IP']}
    Execute CMD Via SSH connection    pkill -f \ tcpdump    root\@
    SSHLibrary.Close Connection

Clear TCPDump Process And Log
    [Arguments]     ${tcpdump_file_name}
    [Documentation]    kill process of TCPDump Process and clean log from /user/toor4nsn
    ...    Contact: lixin.kang@nokia-sbell.com
    ${ssh_connection}    Establish SSH to SBTS    ${SMOD1['IP']}
    Execute CMD Via SSH connection    pkill -f \ tcpdump    root\@
    Execute CMD Via SSH connection    rm ~/${tcpdump_file_name}.pcap    root\@
    SSHLibrary.Close Connection

Save TCPDump File On Local And Get Content
    [Arguments]     ${source_tcpdump_file_name}=${TEST_NAME}    ${target_tcpdump_file_name}=tcpDump_on_SBTS_with_NetAct
    ...    ${target_tcpdump_save_path}=${TestFiles}
    [Documentation]    Helper keyword for getting wireshark log to local folder and return formatted content. Also clean the log saved on BTS
    ...    Contact: lixin.kang@nokia-sbell.com
    ${time}    Get Time    epoch
    ${formatted_tcpdump_file_name}    Set Variable    ${target_tcpdump_file_name}_${time}
    ${cmdstr1}    Set Variable    sshpass -p ${SMOD1['PASSWORD']} scp ${SMOD1['USERNAME']}@${SMOD1['IP']}:
    ${cmdstr2}   Set Variable   ~/${source_tcpdump_file_name}.pcap ${target_tcpdump_save_path}/${formatted_tcpdump_file_name}.pcap \
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmdstr1}${cmdstr2}
    File Should Not Be Empty    ${target_tcpdump_save_path}/${formatted_tcpdump_file_name}.pcap
    ${cmdstr1}    Set Variable    tshark -r "${target_tcpdump_save_path}/${formatted_tcpdump_file_name}.pcap"
    ${cmdstr2}   Set Variable     -Y "(http)" -x -V > "${target_tcpdump_save_path}/tmppcap_${time}.txt"
    OperatingSystem.Run And Return Rc And Output    ${cmdstr1} ${cmdstr2}
    Wait Until Keyword Succeeds    10    5s    File Should Not Be Empty    ${target_tcpdump_save_path}/tmppcap_${time}.txt
    OperatingSystem.Run And Return Rc And Output
    ...    cp ${target_tcpdump_save_path}/tmppcap_${time}.txt ${target_tcpdump_save_path}/noHexPcap_${time}.txt
    Wait Until Keyword Succeeds    10    5s    File Should Not Be Empty    ${target_tcpdump_save_path}/noHexPcap_${time}.txt
    OperatingSystem.Run And Return Rc And Output    sed -i '/^\\w\\{4\\}\\s\\{2\\}/d' ${target_tcpdump_save_path}/noHexPcap_${time}.txt
    ${file_content}    OperatingSystem.Get File    ${target_tcpdump_save_path}/noHexPcap_${time}.txt
    [Teardown]    Clear TCPDump Process And Log    ${source_tcpdump_file_name}
    [Return]     ${file_content}

Check Spend Time KPI For Plan Provision
    [Arguments]     ${tcpdump_file_content}    ${provision_success_msg}
    [Documentation]    Helper keyword for checking  spend time as expected in wireshark log for plan provision
    ...    Contact: lixin.kang@nokia-sbell.com
    #check provision request  spend time
    ${start_time}     Get Epoch Time From Wireshark Log    ${tcpdump_file_content}    <provision
    #check provision response spend time
    ${end_time}     Get Epoch Time From Wireshark Log    ${tcpdump_file_content}    <ne3scommon:provisionResponse>
    ${delta_time}    Evaluate    ${end_time[0]}-${start_time[0]}
    Run Keyword If    ${delta_time}>20    FAIL    Too long time for plan provision
    #check TransferNotificationRequest
    ${end_time}    Get Epoch Time From Wireshark Log    ${tcpdump_file_content}    ${provision_success_msg}
    ${delta_time}    Evaluate    ${end_time[0]}-${start_time[0]}
    Run Keyword If    ${delta_time}>300    FAIL    Too long time for plan provision

Get Epoch Time From Wireshark Log
    [Arguments]    ${file_content}    ${checkpoint_msg}
    [Documentation]    Helper keyword for getting epoch time from wireshark log
    ...    Contact: lixin.kang@nokia-sbell.com
    ${expected_msg}    Fetch From Left    ${file_content}    ${checkpoint_msg}
#    ${target_msg_content}    Fetch From Right    ${expected_msg}    Arrival Time:
    ${target_msg_content}    Fetch From Right    ${expected_msg}    UTC Arrival Time:
    ${epchtimeflag}    Set Variable    regex"Epoch Time|Epoch Arrival Time"
#    ${time}    Get Regexp Matches    ${target_msg_content}    Epoch Time: (\\d+\.\\d+) seconds    1
    ${time}    Get Regexp Matches    ${target_msg_content}    Epoch Arrival Time: (\\d+\.\\d+)    1
    [Return]    ${time}

Check TransferNotificationResponse According To Param Update
    [Arguments]     ${tcpdump_content}    ${param_name}
    [Documentation]    Helper keyword for check TransferNotificationResponse from wireshark log;
    ...                  one request has one response even many parameters update in one plan provosion
    ...    Contact: lixin.kang@nokia-sbell.com
    ${tmp_plan_content}    Fetch From Left    ${tcpdump_content}    name="${param_name}">
    ${tcp_header}    Fetch From Right     ${tmp_plan_content}    Transmission Control Protocol
    ${next_seq_num}    Get Regexp Matches    ${tcp_header}     Next Sequence Number: (\\d+)    1
    ${next_seq}    Fetch From Right    ${tcpdump_content}    Acknowledgment Number: ${next_seq_num[0]}
#    ${tmp_file_content}    Fetch From Right     ${next_seq}    Arrival Time
    ${tmp_file_content}    Fetch From Right     ${next_seq}    UTC Arrival Time
    Should Contain    ${tmp_file_content}    transferNotificationResponse>

Stop TCPDump And Check CCN Messages For Param Update
    [Arguments]     ${param_dic}    ${need_check_time_kpi}=${False}   ${eventChangeOriginType}=plan originated
    ...    ${source_tcpdump_file_name}=${TEST_NAME}    ${target_tcpdump_file_name}=tcpDump_on_SBTS_with_NetAct
    ...    ${target_tcpdump_save_path}=${TestFiles}
    [Documentation]    Stop wireshark and check ccn message for parameter value update
    ...    Contact: lixin.kang@nokia-sbell.com
    Stop TCPDump On SBTS Common
    ${file_content}    Save TCPDump File On Local And Get Content
    ...    ${source_tcpdump_file_name}    ${target_tcpdump_file_name}    ${target_tcpdump_save_path}
    ${success_msg}    Set Variable    The operation was successfully completed.:Activation successful:Provision of the plan was successful.
    #check operation status report
    Should Contain    ${file_content}    ${success_msg}
    Run Keyword If    ${need_check_time_kpi}    Check Spend Time KPI For Plan Provision    ${file_content}    ${success_msg}
    ${param_names}    Get Dictionary Keys    ${param_dic}
    ${eventChange_str}    Set Variable   <p\\s\+name="eventChangeOrigin">\\s\*${eventChangeOriginType}\\s\*</p>
    FOR    ${param_name}    IN    @{param_names}
        Should Match Regexp    ${file_content}
        ...    ${eventChange_str}\\s\*[\\w\\W]\*</extension>\\s\*<p\\s\+name="${param_name}">\\s\*${param_dic["${param_name}"]}\\s\*</p>
    END
    #check TransferNotificationResponse
    Check TransferNotificationResponse According To Param Update    ${file_content}    ${param_names[0]}

Stop TCPDump And Check CCN Messages For Full Plan
    [Arguments]     ${param_dic}    ${eventChangeOriginType}=network originated
    [Documentation]    Stop wireshark and check ccn message after full commission
    ...    Contact: lixin.kang@nokia-sbell.com
    Stop TCPDump On SBTS Common
    ${file_content}    Save TCPDump File On Local And Get Content
    ${param_names}    Get Dictionary Keys    ${param_dic}
    ${eventChange_str}    Set Variable   <p\\s\+name="eventChangeOrigin">\\s\*${eventChangeOriginType}\\s\*</p>
    FOR    ${param_name}    IN    @{param_names}
        Should Match Regexp    ${file_content}
        ...    ${eventChange_str}\\s\*[\\w\\W]\*</extension>\\s\*<p\\s\+name="${param_name}">\\s\*${param_dic["${param_name}"]}\\s\*</p>
    END
    #check TransferNotificationResponse
    Check TransferNotificationResponse According To Param Update    ${file_content}    ${param_names[0]}

#----------------------------------------------------------------------------------------------------------------------#

SBTS Admin Reset Configuration AirScale
    [Arguments]    ${remove_operator_certificates}=False    ${remove_user_account_credentials}=False    ${repair_center_reset}=False
    ...    ${timeout}=500    ${connection}=default    ${detailed_output}=False    ${reset_type}=Configuration    ${fdsw_ip}=192.168.255.129
    ...    ${fdsw_username}=Nemuadmin    ${fdsw_password}=nemuuser
    [Documentation]    Trigger configuration reset for AS SBTS through Admin
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | remove_operator_certificates | No | whether remove operation certificates on active partition |
    ...    | remove_user_account_credentials | No | whether remove user account credentials on active partition |
    ...    | repair_center_reset | No | whether remove all from both partitions |
    ...    | timeout | No | timeout for the operation |
    ...    | connection | No | AdminConnection|
    ...    | detailed_output | No | return full request response when True, defaults set to False. |
    ...    | reset_type | No | Type of the performed reset - used only for legacy solution.
    ...        Added via CNI-70685. One of: ["Configuration"|
    ...        "ConfigurationWithSecurityCredentials"|"ConfigurationWithOperatorCertificates"|
    ...        "ConfigurationWithLocalUserCredentials"|"ConfigurationWithResetOnlyActivePartitionAndRestoreNcf"] |
    ...    | fdsw_ip | No | Mplane or LMP ip address|
    ...    | fdsw_username | No | FDSW API username |
    ...    | fdsw_password | No | FDSW API password |
    Log To Console    Start config reset and start from fdswrc...
    ${pc2_exist}    Run Keyword And Return Status    Should Match Regexp    ${PC_IP2}    \^\\d+.\\d+.\\d+.\\d+\$
    Run Keyword If     ${pc2_exist}    SBTS Admin Reset Configuration Dual Core AirScale    ${remove_operator_certificates}
    ...    ${remove_user_account_credentials}    ${repair_center_reset}    ${timeout}    ${connection}    ${detailed_output}    ${reset_type}
    ...    ${fdsw_ip}    ${fdsw_username}    ${fdsw_password}
    ...    ELSE    rfrlrestconfig.reset_bts_configuration    ${remove_operator_certificates}    ${remove_user_account_credentials}
    ...    ${repair_center_reset}    ${timeout}    ${connection}    ${detailed_output}    ${reset_type}
    ...    ${fdsw_ip}    ${fdsw_username}    ${fdsw_password}
	Log To Console   Teardown Admin
	Run Keyword And Continue On Failure    coam.Teardown All Aliases For Admin
	Log To Console   Teardown Infomodel
    Run Keyword And Continue On Failure    Collect Infomodel
	Log To Console   Start Admin
    Run Keyword And Continue On Failure    Start Admin    bts_host=${SMOD1['TRS_IP']}
	Log To Console   Start Infomodel
	Run Keyword And Continue On Failure    Start Infomodel
    ${btsState}    Wait Until Keyword Succeeds    6m    30s    coam.Get Mrbts State    timeout=30s
    Should Be Equal As Strings     ${btsState}    NotCommissioned
    ${current_sw}    Wait Until Keyword Succeeds    6x    10s    coam.Get SW Version
    Should Be Equal As Strings     ${current_sw}    ${active SW version}

SBTS Admin Reset Configuration Dual Core AirScale
    [Arguments]    ${remove_operator_certificates}=False    ${remove_user_account_credentials}=False    ${repair_center_reset}=False
    ...    ${timeout}=500    ${connection}=default    ${detailed_output}=False    ${reset_type}=Configuration    ${fdsw_ip}=192.168.255.129
    ...    ${fdsw_username}=Nemuadmin    ${fdsw_password}=nemuuser
    [Documentation]    Trigger configuration reset for dual core AS SBTS through Admin
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | remove_operator_certificates | No | whether remove operation certificates on active partition |
    ...    | remove_user_account_credentials | No | whether remove user account credentials on active partition |
    ...    | repair_center_reset | No | whether remove all from both partitions |
    ...    | timeout | No | timeout for the operation |
    ...    | connection | No | AdminConnection|
    ...    | detailed_output | No | return full request response when True, defaults set to False. |
    ...    | reset_type | No | Type of the performed reset - used only for legacy solution.
    ...        Added via CNI-70685. One of: ["Configuration"|
    ...        "ConfigurationWithSecurityCredentials"|"ConfigurationWithOperatorCertificates"|
    ...        "ConfigurationWithLocalUserCredentials"|"ConfigurationWithResetOnlyActivePartitionAndRestoreNcf"] |
    ...    | fdsw_ip | No | Mplane or LMP ip address|
    ...    | fdsw_username | No | FDSW API username |
    ...    | fdsw_password | No | FDSW API password |
    Log To Console    SBTS Admin Reset Configuration Dual Core AirScale...
    ${without_7500_version}    Create List    SBTS21A    SBTS21B    SBTS22R1    SBTS22R2    SBTS22R3    SBTS22R4    SBTS23R1    SBTS23R2
    ${active_sw_version}    coam.Get SW Version
    ${current_release}    Set Variable    ${active_sw_version.split('_')[0].strip()}
    ${With_7500}    Run Keyword And Return Status    List Should Not Contain Value    ${without_7500_version}    ${current_release}
    Run Keyword If      ${With_7500}    Reset Configuration Dual Core After CB007500   ${remove_operator_certificates}
    ...    ${remove_user_account_credentials}    ${repair_center_reset}    ${timeout}   ${connection}   ${detailed_output}
    ...    ${fdsw_ip}    ${fdsw_username}    ${fdsw_password}
    ...    ELSE    coam.reset_configuration    remove_operator_certificates=${remove_operator_certificates}
    ...    remove_user_account_credentials=${remove_user_account_credentials}    timeout=${timeout}
    ...    connection=${connection}    detailed_output=${detailed_output}    reset_type=${reset_type}

Reset Configuration Dual Core After CB007500
    [Arguments]    ${remove_operator_certificates}=False    ${remove_user_account_credentials}=False    ${repair_center_reset}=False
    ...    ${timeout}=500    ${connection}=default    ${detailed_output}=False    ${fdsw_ip}=192.168.255.129
    ...    ${fdsw_username}=Nemuadmin    ${fdsw_password}=nemuuser
    [Documentation]    Trigger configuration reset for dual core after CB007500 delever
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | remove_operator_certificates | No | whether remove operation certificates on active partition |
    ...    | remove_user_account_credentials | No | whether remove user account credentials on active partition |
    ...    | repair_center_reset | No | whether remove all from both partitions |
    ...    | timeout | No | timeout for the operation |
    ...    | connection | No | AdminConnection|
    ...    | detailed_output | No | return full request response when True, defaults set to False. |
    ...    | fdsw_ip | No | Mplane or LMP ip address|
    ...    | fdsw_username | No | FDSW API username |
    ...    | fdsw_password | No | FDSW API password |
    Log To Console    Reset Configuration Dual Core After CB007500...
    Log    ${connection}
    Log    ${detailed_output}
    ${response}    Run Keyword And Return Status    coam.reset_configuration    reset_type=ConfigurationWithDiagnosticAndRecoverySw     timeout=120
    Wait Until Keyword Succeeds    15m    2m    fdswrc.Connect To    ${fdsw_ip}    443    ${fdsw_username}    ${fdsw_password}    name=fdswcon
    ${sw_inventory}    fdswrc.Get All Software Inventory    connection=fdswcon
    Log To Console    ${sw_inventory}
    ${target_slot_id}   fdswrc.Get Active SW Partition    connection=fdswcon
    ${rollback_restType_tmp}    Get Proper Reset Type
    ...    ${remove_operator_certificates}    ${remove_user_account_credentials}    ${repair_center_reset}
    ${DR_SWversion}    Get D&R Mode SW Version    ${sw_inventory}
    ${fdswRelCurrent}    Get Regexp Matches    ${DR_SWversion}      FDSW+\\d{2}\\w{1}
    ${oldRelease}    Create List     FDSW23B    FDSW23C
    ${status}    Run Keyword And Return Status    Should Contain    ${oldRelease}    ${fdswRelCurrent[0]}
    ${rollback_restType}    Run Keyword If    ${status}    Set Variable    ${rollback_restType_tmp}
    ...    ELSE    Create List    ${rollback_restType_tmp}
    fdswrc.Software Rollback    sw_slot_id=${target_slot_id}    reset_type=${rollback_restType}    timeout=${timeout}    connection=fdswcon
    ## Execute robot case on secondary PC
    SSHLibrary.Open Connection    ${PC_IP2}
#    SSHLibrary.Login    ute    uteUTE!
    _SSHLibrary_Login_multiway    ute    uteUTE!
    ${tmp_cmd1}    Set Variable    -d /home/ute/test_results/config_reset
    ${tmp_cmd2}    Set Variable    -v remove_operator_certificates:${remove_operator_certificates}
    ${tmp_cmd3}    Set Variable    -v remove_user_account_credentials:${remove_user_account_credentials}
    ${tmp_cmd4}    Set Variable    -v repair_center_reset:${repair_center_reset} -v active_SW_version:${active SW version}
    ${tmp_cmd5}    Set Variable    -V /home/ute/testline_configuration/${TESTLINE_NAME}
    ${base_dir}    Set Variable    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM
    ${tmp_cmd6}    Set Variable    ${base_dir}/RAN_PZ_HAZ_1/T04/CM/Common_Reset_Configuration_CB007500_Secondary_Core.robot
    SSHLibrary.Write   rm -rf /home/ute/test_results/config_reset/*.*
    SSHLibrary.Write   robot -L TRACE ${tmp_cmd1} ${tmp_cmd2} ${tmp_cmd3} ${tmp_cmd4} ${tmp_cmd5} ${tmp_cmd6}
    Wait Until Keyword Succeeds    15m    30s     SSHLibrary.File Should Exist    /home/ute/test_results/config_reset/log.html
    ${target_log_file_path}    Set Variable    ${Test Results Dir}/TestFiles/log.html
    SSHLibrary.Get File    /home/ute/test_results/config_reset/log.html    ${target_log_file_path}
    OperatingSystem.File Should Exist    ${target_log_file_path}
    ${file_content}    OperatingSystem.Get File    ${target_log_file_path}
    Should Contain    ${file_content}    "All Tests","pass":1

Get Proper Reset Type
    [Arguments]    ${remove_operator_certificates}=False    ${remove_user_account_credentials}=False    ${repair_center_reset}=False
    [Documentation]    Generate real reset type for CB007500
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | remove_operator_certificates | No | whether remove operation certificates on active partition |
    ...    | remove_user_account_credentials | No | whether remove user account credentials on active partition |
    ...    | repair_center_reset | No | whether remove all from both partitions |
    ${reset_type}    Set Variable If    ${repair_center_reset}    RepairCenterReset
    ...    ${remove_operator_certificates} and ${remove_user_account_credentials}   WithCertsAndCredsFromActive
    ...    ${remove_operator_certificates}    WithCertFromActive
    ...    ${remove_user_account_credentials}    WithCredsFromActive
    ...    FromActive
    [Return]    ${reset_type}

Get D&R Mode SW Version
    [Arguments]    ${sw_inventory}
    [Documentation]    Get SW version of D&R mode
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ${version}    Set Variable
    FOR    ${item}    IN     @{sw_inventory["slots"]}
        ${version}    Run Keyword If    "${item["mode"]}"=="D&R"    Set Variable    ${item["version"]}
        Exit For Loop If    "${item["mode"]}"=="D&R"
    END
    [Return]    ${version}

SBTS Admin Reset Configuration FSMF
    [Documentation]    Trigger configuration reset for FSMF SBTS through Admin
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    coam.reset_configuration    reset_type=Configuration     timeout=600
    ${btsState}    Wait Until Keyword Succeeds    6m    30s    coam.Get Mrbts State    timeout=30s
    Should Be Equal As Strings     ${btsState}    NotCommissioned
    ${current_sw}    Wait Until Keyword Succeeds    6x    10s    coam.Get SW Version
    Should Be Equal As Strings     ${current_sw}    ${active SW version}

Prepare Netrc On VM
    ${exist_netrc}    Run Keyword And Return Status     OperatingSystem.File Should Exist
    ...    ${Artifactory_INFO.local_path}
    Return From Keyword If    ${exist_netrc}
    tafssh.connect_to    hostname=${Artifactory_INFO.Host}
    ...    username=${Artifactory_INFO.USERNAME}
    ...    password=${Artifactory_INFO.PASSWORD}
    ...    alias=netrc_server
    tafssh.download_file    remote_path=${Artifactory_INFO.path}
    ...    local_path=${Artifactory_INFO.local_path}
    ...    connection=netrc_server
    ${ret}    OperatingSystem.File Should Exist    ${Artifactory_INFO.local_path}
    OperatingSystem.Run    chmod u+r ${Artifactory_INFO.local_path}
    [Teardown]    Run Keyword And Ignore Error    tafssh.disconnect    connection=netrc_server

Remove Netrc On VM
    OperatingSystem.Run    rm ${Artifactory_INFO.local_path}
    OperatingSystem.File Should Not Exist
    ...    ${Artifactory_INFO.local_path}

Download FCE Modules For Current SW
    [Documentation]    Helper keyword for downloading fce and fct for current software build
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ${active_sw_version}    coam.Get SW Version
    ${current_prefix}    Set Variable    ${active_sw_version.split('_')[0].strip()}
    ${current_release}    Set Variable If   "${current_prefix}" == "${Trunk_Prefix}"    SBTS00    ${current_prefix}
    ${version_num}    Fetch From Right     ${active_sw_version}    _ENB_
    ${current_version}    Set Variable    ${current_release}_ENB_${version_num}
    ${fce_worker}    ${fct_files}    Download FCE And FCT    target_version=${current_version}
    ...    target_download_path=${Test Results Dir}/TestFiles    release_name=${current_release}   clean_folder=${FALSE}
    [Return]     ${fce_worker}    ${fct_files}

Download FCE And FCT
    [Arguments]    ${target_version}    ${target_download_path}=/home/ute/Downloads    ${release_name}=SBTS00    ${clean_folder}=${TRUE}
    [Documentation]    Helper keyword for downloading fce and fct
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | target_version | Yes | e.g. SBTS00_ENB_9999_230608_000013 |
    ...    | target_download_path | Yes | the path you want to save in local vm |
    ...    | release_name | Yes | default is: SBTS00 |
    ${download_command}    Set Variable    wget    #sudo wget --progress=dot:giga -T 600 -t 2
    ${download_source_path}    Set Variable
    ...    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/${release_name}
    ${status}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${target_download_path}
    Run Keyword If    not ${status}    OperatingSystem.Create Directory    ${target_download_path}
    ${remove_files_cmd}    Set Variable    sudo rm -rf ${target_download_path}/*
    Run Keyword If    ${clean_folder}    OperatingSystem.Run    ${remove_files_cmd}
    ${fce_worker}    Set Variable    ${target_version}_fce-worker.zip
    ${fct_files}    Set Variable    ${target_version}_fct-files.zip
    Log To Console    \nStart Download FCE For ${target_version}...........
    ${output}    Wait Until Keyword Succeeds    5m    5s    OperatingSystem.Run
    ...    ${download_command} ${download_source_path}/${target_version}/${fce_worker} -O ${target_download_path}/${fce_worker}
    #Should Contain    ${output}    100%
    Log To Console    \nComplete Download FCE For ${target_version}...........
    Log To Console    \nStart Download FCT For ${target_version}...........
    ${output}    Wait Until Keyword Succeeds    5m    5s    OperatingSystem.Run
    ...    ${download_command} ${download_source_path}/${target_version}/${fct_files} -O ${target_download_path}/${fct_files}
    #Should Contain    ${output}    100%
    Log To Console    \nComplete Download FCT For ${target_version}...........
    OperatingSystem.File Should Exist    ${target_download_path}/${fce_worker}
    OperatingSystem.File Should Exist    ${target_download_path}/${fct_files}
    [Return]     ${fce_worker}    ${fct_files}

Check Parameter Value From SCF For PDCCH
    [Arguments]    ${scf_content}    ${object_dn}    ${addParam_dic}
    [Documentation]    keyword for checking all parameters and values under pdcchAutoConfig for FCT feature CB009451
    ...    Author: Xu Yuyan
    ${pdcchParams}   L_XML.Get Child Elements    ${scf_content}    .//managedObject[@distName="${object_dn}"]/list[@name="pdcchAutoConfig"]/item
    ${pdcchParamsName_list}     Create List
    ${addParam_dic_keys}    Get Dictionary Keys    ${addParam_dic}
    ${need_prefix}    Set Variable If  '${addParam_dic_keys[0].split('.')[0]}'=='pdcchIntent'    True    False
    Sort List    ${addParam_dic_keys}
    FOR    ${param}    IN    @{pdcchParams}
        ${paramName}    L_XML.Get Element Attribute    ${param}    name
        ${paramValue}    L_XML.Get Element Text    ${param}
        Run Keyword If    ${need_prefix}    Run Keywords
        ...    Append To List    ${pdcchParamsName_list}    pdcchIntent.${paramName}
        ...    AND    Should Be Equal As Strings    ${paramValue}    ${addParam_dic['pdcchIntent.${paramName}']}
        ...    ELSE    Run Keywords
        ...    Append To List    ${pdcchParamsName_list}    ${paramName}
        ...    AND    Should Be Equal As Strings    ${paramValue}    ${addParam_dic['${paramName}']}
    END
    Sort List    ${pdcchParamsName_list}
    Lists Should Be Equal    ${pdcchParamsName_list}    ${addParam_dic_keys}

Install FCT On NetAct
    [Arguments]    ${remote_fct_file}
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command
    ...    racclimx.sh -op FCT_Install -inputFile ${remote_fct_file} -v    return_stderr=${True}    return_rc=${True}
    Should Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    Install FCT Operation finished.
    [Teardown]     SSHLibrary.Close Connection
    [Return]    ${stdout}

Get FCT Features On NetAct
    [Arguments]    ${filter}=${EMPTY}
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command    racclimx.sh -op FCT_List -v    return_stderr=${True}    return_rc=${True}
    Should Be Equal As Integers    ${rc}    ${0}
    ${detail_line}    Should Match Regexp    ${stdout}    \\[.*\\]
    ${FCT_features}    Evaluate    ${detail_line}
    Return From Keyword If    "${filter}"==""    ${FCT_features}
    FOR    ${feature}    IN    @{FCT_features}
        ${is_match}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary    ${feature}    ${filter}
        Continue For Loop If    ${is_match}
        Remove Values From List    ${FCT_features}    ${feature}
    END
    [Teardown]     SSHLibrary.Close Connection
    [Return]    ${FCT_features}

Get FCT Metadata On NetAct
    [Arguments]    ${adaptationVersions}    ${type}=additionalInputParameters    ${toolName}=PDCCH
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command
    ...    racclimx.sh -op FCT_Get_Configuration_Help -toolName "${toolName}" -adaptationVersions "${adaptationVersions}" -v
    ...    return_stderr=${True}    return_rc=${True}
    Should Be Equal As Integers    ${rc}    ${0}
    ${detail_line}    Should Match Regexp    ${stdout}    \\{.*\\}
    ${FCT_meta_datas}    Evaluate    ${detail_line}
    ${ret_meta}    Set Variable If    "${type}"==""    ${FCT_meta_datas}    ${FCT_meta_datas["${type}"]}
    [Teardown]     SSHLibrary.Close Connection
    [Return]    ${ret_meta}

Audit On NetAct And Check Results
    [Arguments]     ${targetObjs}    ${addInputParameters}    ${adaptationVersions}    ${outputPlanName}    ${planName}=None
    ...    ${inputConfType}=actual   ${toolName}=PDCCH    ${compareFeedbackLevel}=parameterLevel
    ...    ${compareExportDifferenceReport}=AuditReportFromInputPlan
    [Documentation]    Configuration audit allow identifying, visualizing, and correcting differences between
    ...    selected BTSs configurations and recommended configuration for given feature after calculation of selected FCT tool
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...     | targetObjs  | Yes       | Specifies the scope of the operation (comma-separated Distinguished ames without spaces).
    ...                                 At least one of the arguments planName or targetObjects must be defined
    ...     | addInputParameters| Yes| Specifies the additional input parameters
    ...     | adaptationVersions | Yes |    Specifies the adaptationVersions of the operation (comma-separated Distinguished Names without spaces).
    ...     | planName  | No      | Specifies a plan name. At least one of the arguments planName or targetObjects must be defined.
    ...     | outputPlanName | Yes | Specifies a plan name.
    ...     | inputConfType |  Yes | Specifies the type of input plan (plan or actual)
    ...     | toolName | Yes     | Specifies the name of FCT Tools
    ...     | compareFeedbackLevel  | No | Specifies the level of feedback (summaryLevel/objectLevel/parameterLevel).
    ...                                         Default value is summaryLevel.
    ...     | compareExportDifferenceReport | No | Specifies a file name or a path for the exported differences between the plan
    ...                                             and actual configuration.If the directory is not given, the file is written to
    ...                                             the default directory: $VARROOT/global/racops/export/. Supported file format is CSV.
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log To Console    Start Audit...
    ${tmpcmd1}    Set Variable    -targetObjects '${targetObjs}' -inputConfigurationType ${inputConfType} -toolName ${toolName}
    ${tmpcmd2}    Set Variable If    '${planName}'!='None'
    ...    -additionalInputParameters '${addInputParameters}' -adaptationVersions ${adaptationVersions} -planName ${planName}
    ...    -additionalInputParameters '${addInputParameters}' -adaptationVersions ${adaptationVersions}
    ${tmpcmd3}    Set Variable    -outputPlanName ${outputPlanName} -compareFeedbackLevel ${compareFeedbackLevel}
    ${tmpcmd4}    Set Variable    -compareExportDifferenceReport ${compareExportDifferenceReport} -v
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command
    ...    racclimx.sh -op FCT_Audit_Configuration ${tmpcmd1} ${tmpcmd2} ${tmpcmd3} ${tmpcmd4}
    ...    return_stderr=${True}
    ...    return_rc=${True}
    Should Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    Status received: Finished
    Log To Console    Audit Finished Success...
    [Teardown]         SSHLibrary.Close Connection
    [Return]     ${stdout}

Calculate And Check Results On NetAct
    [Arguments]     ${targetObjs}    ${addInputParameters}    ${adaptationVersions}    ${outputPlanName}    ${planName}=None
    ...    ${inputConfType}=actual   ${toolName}=PDCCH
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log To Console    Start Calculate...
    ${tmpcmd1}    Set Variable    -targetObjects ${targetObjs} -inputConfigurationType "${inputConfType}" -toolName "${toolName}"
    ${tmpcmd2}    Set Variable If    "${planName}"!="None"
    ...    -additionalInputParameters '${addInputParameters}' -adaptationVersions ${adaptationVersions} -planName ${planName}
    ...    -additionalInputParameters '${addInputParameters}' -adaptationVersions ${adaptationVersions}
    ${tmpcmd3}    Set Variable    -outputPlanName ${outputPlanName} -v
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command
    ...    racclimx.sh -op FCT_Create_Configuration_Plan ${tmpcmd1} ${tmpcmd2} ${tmpcmd3}
    ...    return_stderr=${True}
    ...    return_rc=${True}
    Should Be Equal As Integers    ${rc}    ${0}
    ${detail_line}    Should Match Regexp    ${stdout}    \\[.*\\]
    Should Contain    ${stdout}    Status received: Finished
    Log To Console    Calculate Finished Success...
    [Teardown]         SSHLibrary.Close Connection

Generate Random FCT ADDIN Params
    [Arguments]    ${additionalInputParameters}
    ${parameters}    Create Dictionary
    # 2024-04-03 Kang Lixin: specicial case on crt envs startCRBOfCoreset0 need select from 1 to 3
    ${startCRBOfCoreset0_values}    Create List    0    1    2    3
    # 2024-08-27 Kang Lixin: specicial case on crt envs fineTuneMode can not select mode2 on 1813,1894
    # pdcchAutoConfig.fineTuneMode 'mode2' only apply to FDD 30MHz, 35MHz and 40MHz
    ${fineTuneMode_values}    Create List    disabled    mode1    mode3
    FOR    ${p}    IN    @{additionalInputParameters}
        ${has_tag}    ${tag}    Run Keyword And Ignore Error
        ...    Should Match Regexp    ${p["fullName"]}
        ...    \\(rel \\>=\\w+\\)|\\(rel \\<=\\w+\\)|\\(rel \\<\\w+\\)|\\(rel \\>\\w+\\)|\\(rel \\=\\w+\\)
        ${compare_result}    Run Keyword If    '${has_tag}'=='PASS'
        ...    Compare Additional Param Support Version With Current SW From Tag     ${tag}
        Continue For Loop If    '${has_tag}'=='PASS' and '${compare_result}'!='True'
        ${allowdValues_list}    Set Variable If    '${p["fullName"]}' == 'startCRBOfCoreset0'
        ...    ${startCRBOfCoreset0_values}    ${p["allowedValues"]}
        ${allowdValues_list}    Set Variable If    '${p["fullName"]}' == 'fineTuneMode'
        ...    ${fineTuneMode_values}    ${allowdValues_list}
        ${val}    Evaluate    random.choice(${allowdValues_list})    modules=random, sys
        Set To Dictionary    ${parameters}    ${p["name"]}    ${val}
    END
    [Return]    ${parameters}

Compare Additional Param Support Version With Current SW From Tag
    [Arguments]     ${tag}
    [Documentation]    Keyword used to deal with specific parameter that has tag (rel<=xx) or (rel >=xx). Compare current software
    ...    version and the version in tag. Return the actual comparation result
    ...    Author: Kang Lixin
    ...    Contact: lixin.kang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | tag | Yes | e.g. (rel<=24R1)|
    ...
    ...    | Return Value | Description |
    ...    | compare_result | return the comparation result for current sw release and tag|
    ...    Example
    ...    | ${compare_result} | Compare Additional Param Support Version With Current SW From Tag | ${tag} |
    ${current_release}    Set Variable    ${active_sw_version.split('_')[0].strip().replace('SBTS','')}
    ${cur_rel_y_num}    Set Variable    ${current_release.split('R')[0]}
    ${cur_rel_q_num}    Set Variable    ${current_release.split('R')[1]}
    ${formatted_tag}    Set Variable    ${tag.replace('(rel','').replace(')','').strip()}
    ${tag_release}    Should Match Regexp     ${formatted_tag}    \\w+
    ${tag_symbol}    Remove String    ${formatted_tag}    ${tag_release}
    ${tag_rel_y_num}    Set Variable    ${tag_release.split('R')[0]}
    ${tag_rel_q_num}    Set Variable    ${tag_release.split('R')[1]}
    ${compare_result}     Run Keyword If    ${cur_rel_y_num}==${tag_rel_y_num}
    ...    Run Keyword And Return Status    Should Be True    ${cur_rel_q_num} ${tag_symbol} ${tag_rel_q_num}
    ...    ELSE    Run Keyword And Return Status    Should Be True    ${cur_rel_y_num} ${tag_symbol} ${tag_rel_y_num}
    [Return]     ${compare_result}

Generate Random FCT ADDIN Params For TargetDNs
    [Arguments]    ${list_target_DN}    ${additionalInputParameters}
    ${list_ADDIN_params}    Create List
    FOR    ${dn}    IN    @{list_target_DN}
        ${params_of_DN}    Create Dictionary
        ${parameters}    Generate Random FCT ADDIN Params    ${additionalInputParameters}
        Set To Dictionary    ${params_of_DN}    distName=${dn}    parameters=${parameters}
        Append To List    ${list_ADDIN_params}    ${params_of_DN}
    END
    [Return]    ${list_ADDIN_params}

Get File From NetAct CMWAS Node
    [Arguments]     ${target_file_path}    ${destination_path}
    Run Keyword And Ignore Error    SSHLibrary.Close All Connections
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${file_exists}    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${target_file_path}
    Run Keyword If    ${file_exists}    SSHLibrary.Get File    ${target_file_path}    ${destination_path}
    OperatingSystem.File Should Exist    ${destination_path}
    [Teardown]      SSHLibrary.Close Connection

Random Select TestData Of Trigger Action Parameters From Json
    [Arguments]     ${test_data_file}    ${selected_type}
    [Documentation]    Keyword used for random select one parameter from one set parameters
    ${expect_status}    ${list_param_for_create_plan}    Get Parameters For NetAct Plan Due To Json File
    ...    ${test_data_file}    ${selected_type}    ${BTS_scf_initial}
    ${count}    Get Length    ${list_param_for_create_plan}
    ${index}    Evaluate    random.randint(0, ${count-1})    modules=random, sys
    ${param_for_create_plan}    Set Variable    ${list_param_for_create_plan[${index}]}
    ${expect_status_for_param}    Set Variable    ${param_for_create_plan['expect_status']}
    ${plan_info}    Create Dictionary    mo_id=PLMN-PLMN/${param_for_create_plan['mo_id']}    scf_distName=${param_for_create_plan['mo_id']}
    ...    parameter=${param_for_create_plan['parameters']}
    ${params_ui}    Copy Dictionary    ${plan_info['parameter']}    deepcopy=True
    ${plan_info_ui}    Create Dictionary    scf_distName=${plan_info['scf_distName']}    parameter=${params_ui}
    ${file_content}    OperatingSystem.Get File    ${test_data_file}
    ${test}    Evaluate    ${file_content}
    ${mapper}    Pop From Dictionary    ${test["netact_ui_inter_value_mapping"]}    ${param_for_create_plan['meta_class']}    ${None}
    ${param_names}    Get Dictionary Keys    ${params_ui}
    FOR    ${param_name}    IN    @{param_names}
        Continue For Loop If    ${mapper} is None
        ${ui_dic}    Pop From Dictionary    ${mapper}    ${param_name}    ${None}
        Continue For Loop If    ${ui_dic} is None
        Set To Dictionary    ${plan_info['parameter']}    ${param_name}    ${ui_dic["${plan_info['parameter']['${param_name}']}"]}
    END
    [Return]     ${plan_info}    ${plan_info_ui}    ${expect_status_for_param}

Select One Set TestData Of Trigger Action Parameters From Json
    [Arguments]     ${test_data_file}    ${selected_type}    ${bts_scf}=${BTS_scf_initial}
    [Documentation]    Keyword used for random select one set parameters(>=1 parameter) which can provision multiple parameters in one plan.
    ...    Author: Xu Yuyan
    ${expect_status}    ${list_param_for_create_plan}    Get Parameters For NetAct Plan Due To Json File
    ...    ${test_data_file}    ${selected_type}    ${bts_scf}
    ${Param_plan_dic_list}    Create List
    FOR    ${param_for_create_plan}    IN    @{list_param_for_create_plan}
        ${param_plan_dic}    Create Dictionary
        ${expect_status_for_param}    Set Variable    ${param_for_create_plan['expect_status']}
        ${plan_info}    Create Dictionary    mo_id=PLMN-PLMN/${param_for_create_plan['mo_id']}    scf_distName=${param_for_create_plan['mo_id']}
        ...    parameter=${param_for_create_plan['parameters']}
        ${params_ui}    Copy Dictionary    ${plan_info['parameter']}    deepcopy=True
        ${plan_info_ui}    Create Dictionary    scf_distName=${plan_info['scf_distName']}    parameter=${params_ui}
        ${file_content}    OperatingSystem.Get File    ${test_data_file}
        ${test}    Evaluate    ${file_content}
        ${mapper}    Pop From Dictionary    ${test["netact_ui_inter_value_mapping"]}    ${param_for_create_plan['meta_class']}    ${None}
        ${param_names}    Get Dictionary Keys    ${params_ui}
        FOR    ${param_name}    IN    @{param_names}
            Continue For Loop If    ${mapper} is None
            ${ui_dic}    Pop From Dictionary    ${mapper}    ${param_name}    ${None}
            Continue For Loop If    ${ui_dic} is None
            Set To Dictionary    ${plan_info['parameter']}    ${param_name}    ${ui_dic["${plan_info['parameter']['${param_name}']}"]}
        END
        Set To Dictionary    ${param_plan_dic}    plan_info=${plan_info}    plan_info_ui=${plan_info_ui}
        ...    expect_status_for_param=${expect_status_for_param}
        Log    ${param_plan_dic}
        Append To List    ${Param_plan_dic_list}    ${param_plan_dic}
    END
    Log    ${Param_plan_dic_list}
    [Return]    ${Param_plan_dic_list}

Install Certificate On SBTS
    [Arguments]    ${cert_file}    ${cert_type}    ${cert_format}    ${password}=None    ${timeout}=60
    [Documentation]    Keyword used for install certificate on SBTS
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | cert_file        | yes  | certificate file path |
    ...   | cert_type       | yes  | Certificate type, one of: ["BtsTrustChain","AdditionalCa","CBRSVendorChain","CBRSAdditionalCa"] |
    ...   | cert_format     | yes  | Certificate format, one of: ["PEM","P12","DER"] |
    ...   | password       | no  | Certificate password |
    ...   | timeout        | no  | timeout |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...    Example
    ...    | Install Certificate On SBTS | cert_file=tampere_CB007010.p12| cert_type=BtsTrustChain | cert_format=P12 | password=ute |
    Log To Console    Install Certificate On SBTS
    ${result}    coam.install_certificate    ${cert_file}    ${cert_type}    ${cert_format}    ${password}    ${timeout}
    Should Be Equal As Strings     ${result}    Succeeded

Restore Vendor Certificate On SBTS
    [Documentation]    Keyword used for Restore Vendor Certificate On SBTS
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | NA              | NA  | NA |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...    Example
    ...    | Restore Vendor Certificate On SBTS |
    Log To Console    Restore Vendor Certificate
    ${result}    coam.restore_vendor_certificate
    Should Be Equal As Strings     ${result}    Succeeded

Get Certificate List On SBTS
    [Arguments]    ${cert_type}    ${timeout}=60
    [Documentation]    Keyword used for Get Certificate List On SBTS
    ...    Author: Xu Yuyan
    ...    Contact: yuyan.xu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | cert_type       | yes  | Certificate type,
    ...   one of:["BTS"|"RA"|"Vendor"|"TA"|"CA"|"All"|"CBRSVendor"|"CBRSCA"|"CBRSAll"|"CBRSTA"|"CBRSAdditional"|"Additional"] |
    ...   | timeout        | no  | timeout |
    ...
    ...   | Return Value | Description |
    ...   | certificates | list |
    ...
    ...    Example
    ...    | Install Certificate On SBTS | cert_file=tampere_CB007010.p12| cert_type=BtsTrustChain | cert_format=P12 | password=ute |
    Log To Console    Get Certificate List
    log    ${timeout}
    ${certificates}    coam.get_certificate_list    ${cert_type}
    [Return]    ${certificates}

Get Relationship Between BBMODs And Cells
    [Arguments]     ${alias}=default
    [Documentation]    Get the relationship between all bbmods and all 2G/3G/4G/5G cells.
    ...    Example: https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/94131
    ${btsInfo}    coam.Get Bts Info    connection=${alias}
    Set Test Variable    ${bbmod_list}     ${btsInfo['basebandModules']}
    log    ${bbmod_list}
    ${bbmods_cells_mapping}    Create Dictionary
    ${full_scf}    coam.Get Scf    configurationAndRuntimeObjects    connection=${alias}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${full_scf_xml}    L_XML.Parse Xml    ${full_scf}
	${mrbts_id}    ${nrbts_id}    ${lnbts_id}    ${wnbts_id}    ${gnbts_id}  Fetch BTS IDs     alias=${alias}
    Set Test Variable    ${mrbts_id}
    Set Test Variable    ${nrbts_id}
    Set Test Variable    ${lnbts_id}
    FOR    ${bbmod}    IN    @{bbmod_list}
        ${cell_dic}    Get BBMOD Related Cells    ${bbmod['id']['runtime']}    ${full_scf_xml}    ${alias}
        Set To Dictionary    ${bbmods_cells_mapping}    ${bbmod['id']['internal']}    ${cell_dic}
    END
    [Return]    ${bbmods_cells_mapping}


Get BBMOD Related Cells
    [Arguments]    ${BBMOD_MO_R}    ${full_scf_xml}    ${alias}=default
    [Documentation]    Get 2G/3G/4G/5G cells related to one BBMOD.
    ${empty_list}    Create List
    ${cell_dic}    Create Dictionary    GSM=${empty_list}    WCDMA=${empty_list}    LTE=${empty_list}    5G=${empty_list}
    ${bbpool_has_bbmod_r}    L_XML.Get Elements    ${full_scf_xml}
    ...    .//managedObject[@class="com.nokia.srbts.mnl:BBPOOL"]/list[@name="bbPwrGroupDNList"]/p[contains(text(),"${BBMOD_MO_R}")]
    ${cnt}     Get Length    ${bbpool_has_bbmod_r}
    Return From Keyword If    ${cnt}==0    ${cell_dic}
    ${MO_BBPOOL}    L_XML.Get Elements    ${full_scf_xml}    .//managedObject[@class="com.nokia.srbts.mnl:BBPOOL"]
    FOR    ${MO}    IN    @{MO_BBPOOL}
        ${bbPwrGroupDNList}    L_XML.Get Elements    ${MO}    .//list[@name="bbPwrGroupDNList"]/p[contains(text(),"${BBMOD_MO_R}")]
        Run Keyword If    ${bbPwrGroupDNList}    Get Tech Cells Mapping From BBPOOL     ${MO}     ${cell_dic}    ${full_scf_xml}    ${alias}
    END
    [Return]    ${cell_dic}

Get Tech Cells Mapping From BBPOOL
    [Arguments]     ${bbpool_elememt}    ${cell_dic}    ${full_scf_xml}    ${alias}=default
    [Documentation]    Invoke by KW:Get BBMOD Related Cells
    ${bbPoolTech}    L_XML.Get Element Text    ${bbpool_elememt}    .//p[@name="bbPoolTech"]
    ${bbPoolCellsList}    L_XML.Get Elements Texts    ${bbpool_elememt}    .//list[@name="bbPoolCellsList"]/p
    ${bbmod_related_cells_id}    Run Keyword If    '${bbPoolTech}'=='WCDMA'
    ...    Fetch WCDMA Cell List By Cellmapping ID    ${bbPoolCellsList}    ${full_scf_xml}    ${alias}
    ...    ELSE    Fetch NON-WCDMA Cell List By Cellmapping ID BB   ${bbPoolCellsList}    ${bbPoolTech}    ${alias}
    ${tmp_list}    Combine Lists    ${cell_dic['${bbPoolTech}']}    ${bbmod_related_cells_id}
    ${tmp_list}    Remove Duplicates    ${tmp_list}
    Set To Dictionary    ${cell_dic}    ${bbPoolTech}    ${tmp_list}

Fetch NON-WCDMA Cell List By Cellmapping ID BB
    [Arguments]     ${cellmappings}    ${bbPoolTech}    ${alias}=default
    [Documentation]    Invoke by KW:Get Tech Cells Mapping From BBPOOL
    ${cell_list}    Create List
    FOR    ${cellmid}    IN    @{cellmappings}
        ${cell_dn}    Run Keyword If
        ...    '${bbPoolTech}'=='GSM'    Set Variable    MRBTS-${mrbts_id}/GNBTS-1/GNBCF-1/GNCEL-${cellmid}
        #...    '${bbPoolTech}'=='LTE'    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${cellmid}
        ...    ELSE IF    '${bbPoolTech}'=='LTE'    Get Cell DistName By Lcrid for LTE Or NR Cell    ${cellmid}    lte    alias=${alias}
        #...    '${bbPoolTech}'=='5G'    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellmid}
        ...    ELSE IF    '${bbPoolTech}'=='5G'    Get Cell DistName By Lcrid for LTE Or NR Cell    ${cellmid}    nr    alias=${alias}
        ${cell_id_mapping}    Fetch ID Mapping From Admin For Cells    identifier=${cell_dn}    identifier_type=configuration    alias=${alias}
        Append To List     ${cell_list}    ${cell_id_mapping['internal']}
    END
    [Return]     ${cell_list}

Get Cell DistName By Lcrid for LTE Or NR Cell
    [Arguments]     ${Lcrid}    ${rat_type}    ${alias}=default
    ${cells}    coam.Get Cell List    connection=${alias}
    ${cells_list}    Set Variable    ${cells['cells']['${rat_type}']}
    ${cell_dn}    Set Variable
    FOR    ${cell}    IN    @{cells_list}
        ${cell_config}    Set Variable    ${cell['id']['configuration']}
        ${cell_lcrid}    Get Parameter Value From WebEM    ${cell_config}    lcrId    alias=${alias}
        Return From Keyword If    "${cell_lcrid}"=="${Lcrid}"    ${cell_config}
    END
    [Return]    ${cell_dn}

Fetch WCDMA Cell List By Cellmapping ID
    [Arguments]     ${cellmappings}    ${full_scf_xml}=${full_scf_xml}    ${alias}=default
    [Documentation]    Invoke by KW:Get Tech Cells Mapping From BBPOOL,Get RMOD Related Cells
    ${wncell_list}    Create List
    FOR    ${cellmid}    IN    @{cellmappings}
        ${cellmapping_dn}    Set Variable     MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELW-${cellmid}
        ${wncell_item}    L_XML.Get Element    ${full_scf_xml}    .//managedObject[@class="com.nokia.srbts.wcdma:WNCEL"][p="${cellmapping_dn}"]
        ${wncell_dn}    L_XML.Get Element Attribute    ${wncell_item}    distName
        ${wncell_id_mapping}    Fetch ID Mapping From Admin For Cells    WCDMA    ${wncell_dn}    configuration    alias=${alias}
        Append To List     ${wncell_list}    ${wncell_id_mapping['internal']}
    END
    [Return]     ${wncell_list}

Get Relationship Between RMODs And Cells
    [Documentation]    Get the relationship between all rmods and all 2G/3G/4G/5G cells.
    ...    Example: https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/94131
    ${btsInfo}    coam.Get Bts Info
    Set Test Variable    ${rmod_list}     ${btsInfo['radioModules']['rmod']}
    log    ${rmod_list}
    ${full_scf}    coam.Get Scf    configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${full_scf_xml}    L_XML.Parse Xml    ${full_scf}
    ${mrbts}    L_XML.Get Element    ${full_scf_xml}    .//managedObject[@class="com.nokia.srbts:MRBTS"]
    ${mrbts_dn}    L_XML.Get Element Attribute    ${mrbts}    distName
    ${mrbts_id}    Fetch From Right    ${mrbts_dn}    -
    ${status}    ${lnbts}    Run Keyword And Ignore Error    L_XML.Get Element    ${full_scf_xml}    .//managedObject[@class="NOKLTE:LNBTS"]
    ${lnbts_dn}    Run Keyword If    "${status}"=="PASS"    L_XML.Get Element Attribute    ${lnbts}    distName
    #${lnbts}    L_XML.Get Element    ${full_scf_xml}    .//managedObject[@class="NOKLTE:LNBTS"]
    #${lnbts_dn}    L_XML.Get Element Attribute    ${lnbts}    distName
    ${lnbts_id}    Run Keyword If    "${status}"=="PASS"    Fetch From Right    ${lnbts_dn}    -

    ${status}    ${nrbts}    Run Keyword And Ignore Error    L_XML.Get Element
    ...    ${full_scf_xml}   .//managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
    ${nrbts_dn}    Run Keyword If    "${status}"=="PASS"    L_XML.Get Element Attribute    ${nrbts}    distName
    #${nrbts}    L_XML.Get Element    ${full_scf_xml}    .//managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
    #${nrbts_dn}    L_XML.Get Element Attribute    ${nrbts}    distName
    ${nrbts_id}    Run Keyword If    "${status}"=="PASS"    Fetch From Right    ${nrbts_dn}    -
    Set Test Variable    ${mrbts_id}
    Set Test Variable    ${nrbts_id}
    Set Test Variable    ${lnbts_id}
    FOR    ${item}    IN    @{rmod_list}
        ${rmod_scf_dn}    Set Variable    ${item['id']['configuration']}
        ${status}    ${radioMasterDN}    Run Keyword And Ignore Error    Get Parameter Value From WebEM    ${rmod_scf_dn}    radioMasterDN
        ${is_rfsharing_slave}    Run Keyword And Return Status    Should Contain    ${radioMasterDN}    MRBTS-${mrbts_id}/EQM-1/SMOD_EXT-
        Run Keyword If    ${is_rfsharing_slave}   Remove Values From List    ${rmod_list}    ${item}
    END
    ${rmods_cells_mapping}    Create Dictionary
    FOR    ${rmod}    IN    @{rmod_list}
        ${cell_dic}    Get RMOD Related Cells    ${rmod['id']['runtime']}    ${full_scf_xml}
        Set To Dictionary    ${rmods_cells_mapping}    ${rmod['id']['internal']}    ${cell_dic}
    END
    [Return]     ${rmods_cells_mapping}

Get RMOD Related Cells
    [Arguments]    ${RMOD_MO_R}    ${full_scf_xml}
    [Documentation]    Get 2G/3G/4G/5G cells related to one RMOD.
    ${empty_list}    Create List
    ${cell_dic}    Create Dictionary    activeGsmCellsList=${empty_list}    activeWcdmaCellsList=${empty_list}    activeLteCellsList=${empty_list}
    ...    activeNrCellsList=${empty_list}
    ${full_scf}    coam.Get Scf    configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${full_scf_xml}    L_XML.Parse Xml    ${full_scf}
    Set Test Variable    ${full_scf_xml}
    ${cell_list_item}    L_XML.Get Elements    ${full_scf_xml}    .//managedObject[@distName="${RMOD_MO_R}"]/list
    FOR    ${item}    IN    @{cell_list_item}
        ${key}    L_XML.Get Element Attribute    ${item}    name
        ${value}     L_XML.Get Elements Texts    ${item}   p
        ${rmod_related_cells_id}    Run Keyword If    '${key}'=='activeWcdmaCellsList'
        ...    Fetch WCDMA Cell List By Cellmapping ID    ${value}    ${full_scf_xml}
        ...    ELSE    Fetch NON-WCDMA Cell List By Cellmapping ID RF   ${value}    ${key}
        ${tmp_list}    Combine Lists    ${cell_dic['${key}']}    ${rmod_related_cells_id}
        ${tmp_list}    Remove Duplicates    ${tmp_list}
        Set To Dictionary    ${cell_dic}    ${key}    ${tmp_list}
    END
    [Return]    ${cell_dic}

Fetch NON-WCDMA Cell List By Cellmapping ID RF
    [Arguments]     ${cellmappings}    ${tech}
    [Documentation]    Invoke by KW:Get RMOD Related Cells
    ${cell_list}    Create List
    FOR    ${cellmid}    IN    @{cellmappings}
        ${cell_dn}    Run keyword If
        ...    '${tech}'=='activeGsmCellsList'    Set Variable    MRBTS-${mrbts_id}/GNBTS-1/GNBCF-1/GNCEL-${cellmid}
        #...    '${tech}'=='activeLteCellsList'    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${cellmid}
        ...    ELSE IF    '${tech}'=='activeLteCellsList'    Get Cell DistName By Lcrid for LTE Or NR Cell    ${cellmid}    lte
        #...    '${tech}'=='activeNrCellsList'    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellmid}
        ...    ELSE IF    '${tech}'=='activeNrCellsList'    Get Cell DistName By Lcrid for LTE Or NR Cell    ${cellmid}    nr
        ${cell_id_mapping}    Fetch ID Mapping From Admin For Cells    identifier=${cell_dn}    identifier_type=configuration
        Append To List     ${cell_list}    ${cell_id_mapping['internal']}
    END
    [Return]     ${cell_list}

Get Relationship Between SMODs And BBMODs
    [Arguments]     ${alias}=default
    [Documentation]    Get the relationship between all smods and bbmods.
    ...    Author: yuyan xu
    Log To Console    Get Relationship Between SMODs And BBMODs
    ${smods_bbmods_mapping}    Create Dictionary
    ${scf}    coam.Get Scf    connection=${alias}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse Xml    ${scf}
    ${smods}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.eqm:SMOD"]
    FOR    ${smod}    IN    @{smods}
        ${smod_dn}    L_XML.Get Element Attribute    ${smod}    distName
        ${bbmods_list}    Get SMOD Related BBMODs    ${smod_dn}    ${scf_xml}
        Set To Dictionary    ${smods_bbmods_mapping}    ${smod_dn}    ${bbmods_list}
    END
    [Return]    ${smods_bbmods_mapping}

Get SMOD Related BBMODs
    [Arguments]    ${smod_dn}    ${scf_xml}
    [Documentation]    Get bbmods related to one SMOD. Invoke by KW:Get Relationship Between SMODs And BBMODs
    ${bbmods_list}    Create List
    ${cablinks}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.eqm:CABLINK"]
    FOR    ${cablink}    IN    @{cablinks}
        ${firstendpoint}    L_XML.Get Element Text    ${cablink}    .//p[@name="firstEndpointDN"]
        ${secondendpoint}    L_XML.Get Element Text    ${cablink}    .//p[@name="secondEndpointDN"]
        Run Keyword If    "${firstendpoint}"=="${smod_dn}"    Append To List    ${bbmods_list}    ${secondendpoint}
    END
    [return]    ${bbmods_list}

Get SMODs Role
    [Arguments]     ${alias}=default
    [Documentation]    Get the role of SMODs. return role: {SMOD-DN: Primary/Secondary}.
    ${smods_role}    Create Dictionary
    ${full_scf}    coam.Get Scf    configurationAndRuntimeObjects    connection=${alias}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${full_scf_xml}    L_XML.Parse Xml    ${full_scf}
    ${smods_r}    L_XML.Get Elements    ${full_scf_xml}    .//managedObject[@class="com.nokia.srbts.eqmr:SMOD_R"]
    FOR    ${smod_r}    IN    @{smods_r}
        ${role}    Set Variable    Primary
        ${smod_r_dn}    L_XML.Get Element Attribute    ${smod_r}    distName
        ${smod_dn}    L_XML.Get Element Text    ${full_scf_xml}    .//managedObject[@distName="${smod_r_dn}"]/p[@name="configDN"]
        ${status}    ${role_tmp}    Run Keyword And Ignore Error    L_XML.Get Element Text    ${full_scf_xml}
        ...    .//managedObject[@distName="${smod_r_dn}"]/p[@name="activeRole"]
        ${role}    Set Variable If    "${status}"=="PASS"    ${role_tmp}    ${role}
        Set To Dictionary    ${smods_role}    ${smod_dn}    ${role}
    END
    [Return]    ${smods_role}

Set ValidatePlanAgainstDetectedHW Value Admin
    [Arguments]    ${bts_id}    ${expect_value}
    [Documentation]    Helper keyword used for set parameter ValidatePlanAgainstDetectedHW to expect_value from admin.
    ${origin_value}    Get Parameter Value From WebEM    MRBTS-${bts_id}/MNL-1    validatePlanAgainstDetectedHW
    Return From Keyword If    "${origin_value}"=="${expect_value}"    ${origin_value}
    coam.Create Delta
    coam.Append Parameter Update To Delta    dist_name=MRBTS-${bts_id}/MNL-1   parameter=validatePlanAgainstDetectedHW    value=${expect_value}
    ${json}    coam.Get Delta
    coam.Perform Delta Recommissioning    ${json}
    Check SBTS SMOD RMOD Cells Alarms
	Check WebEM After Modify Parameters    MRBTS-${bts_id}/MNL-1    validatePlanAgainstDetectedHW=${expect_value}
    [Return]    ${origin_value}

Set ValidatePlanAgainstDetectedHW Value SCF
    [Arguments]    ${scf_path}    ${expect_value}
	[Documentation]    Helper keyword used for modify parameter ValidatePlanAgainstDetectedHW to expect_value in SCF file.
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${scf_path}
    ${obj}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts:MRBTS"]
    ${mrbts_distname}    L_XML.Get Element Attribute    ${obj[0]}  distName
    ${origin_value}    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${mrbts_distname}/MNL-1"]/p[@name="validatePlanAgainstDetectedHW"]
    &{param_dic}    Create Dictionary    validatePlanAgainstDetectedHW=${expect_value}
    &{dn_param_dic}    Create Dictionary    ${mrbts_distname}/MNL-1=&{param_dic}
    ${modified_scf_path}    Run Keyword If    '${origin_value}'!='${expect_value}'    Generate Full SCF With Params Update For Multi Object
    ...    ${dn_param_dic}   ${scf_path}
    ...    ELSE    Set Variable    ${scf_path}
	[Return]    ${modified_scf_path}

Move All Test Result To Log Server
    [Documentation]    This kw is used to copy test result folder to log server
    ...    Author: Xu Yuyan
    [Arguments]    ${testline}=${TESTLINE_NAME}
    ...    ${get_team_kw}=Get Team Name By suite path
    ...    ${local_test_result}=/home/ute/test_results/
    log    ${testline}
    ${is_singlerun}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${UTE_EXECUTION_JSON}
    #Return From Keyword If    ${is_singlerun}==${False}
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${team_name}    Run Keyword    ${get_team_kw}
    tafssh.connect_to    hostname=${Logserver_INFO.Host}
    ...    username=${Logserver_INFO.USERNAME}
    ...    password=${Logserver_INFO.PASSWORD}
    ...    alias=log_server
    ${remote_log_path}    catenate    /data/logs/${team_name}/${TESTLINE_NAME}_${timestamp}
    tafssh.execute    command=cd /data/logs/${team_name};mkdir ${TESTLINE_NAME}_${timestamp}
    ...    connection=log_server
    ${cmd}    catenate    sshpass -p ${Logserver_INFO.PASSWORD}
    ...    scp -r ${local_test_result}
    ...    ${Logserver_INFO.USERNAME}@${Logserver_INFO.Host}:${remote_log_path}
    OperatingSystem.Run    command=${cmd}
    ${files}    get_all_files_in_dictionary    ${local_test_result}
    FOR    ${file}    IN    @{files}
        ${new_file_path}    Replace String    ${file}    /home/ute/    ${remote_log_path}${/}
        ${file_exist}    tafssh.File Exists    ${new_file_path}
        ...    connection=log_server
        Should Be True    ${file_exist}
    END
    Log    message=The new log link: http://10.69.69.233${remote_log_path}   level=WARN    	console=yes
    Log    message=The test_results will be removed    level=WARN    	console=yes
    ${all_dir_in_testresult}    OperatingSystem.List Directories In Directory    ${local_test_result}
    FOR    ${d}    IN    @{all_dir_in_testresult}
        Log To Console    ${d}
        ${clear_path}    Join Path    ${local_test_result}    ${d}
        Remove Directory    ${clear_path}    recursive=${True}
    END

Get Team Name By suite path
    [Documentation]    This kw is used to get teamname from suite place
    ...    Author: Xu Yuyan
    ...    | Return Value | Description |
    ...    | team_id | the team id |
    ...
    ...    Example
    ...    | ${team_id} | Get Team Name By suite path |
    ...
    ${matches}    Get Regexp Matches    ${SUITE SOURCE}    RAN_PZ_HAZ_1${/}HAZ\\d+
    Should Not Be Empty    ${matches}
    ${match}    Split String    ${matches}[0]    ${/}
    [Return]    ${match}[-1]

Recovery SBTS Configuration Via Full Commissioning
    [Documentation]    This kw is common for site scf recovery
    ...    Author: Kang Lixin
    [Arguments]     ${skip_parameter_relation_errors}=${TRUE}  ${timeout}=600
    ${bts_id}   Admin Get BTS ID
    ${init_scf_exit}    Run Keyword And Return Status    Variable Should Exist    ${BTS_scf_initial}
    ${testline_commission_file_path}    Set Variable    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ${commissioning_path}    Set Variable If    ${init_scf_exit}     ${BTS_scf_initial}    ${testline_commission_file_path}
    OperatingSystem.File Should Exist     ${commissioning_path}
    #2025-03-04:remove due to CB014041-B onwards: MNL.validatePlanAgainstDetectedHW is frozen
    #${modified_commission_file_path}    Set ValidatePlanAgainstDetectedHW Value SCF    ${commissioning_path}    false
    Log To Console     Parameter bts_id: ${bts_id}
    Log To Console     Commissioning via ADMIN will be performed
    coam.Perform Commissioning      ${bts_id}     ${commissioning_path}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    timeout=${timeout}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Generate Full SCF With Params Update For Multi Object
    [Documentation]    This kw is used to modify a collection of dn and parameters in specific scf xml file and save to scf file for use
    ...    Author: Kang Lixin
    [Arguments]     ${objDN_param_dic}    ${source_xml_path}    ${target_xml_path}=${BTSFiles}/modified_init_scf_file.xml
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${source_xml_path}
    L_XML.Set Elements Attribute    ${scf_xml}    operation    create    cmData/managedObject
    ${DNs}    Get Dictionary Keys    ${objDN_param_dic}
    FOR    ${dn}    IN    @{DNs}
        ${scf_xml}    Generate Full XML With Params Update For Specific Object    ${scf_xml}    ${dn}    ${objDN_param_dic['${dn}']}
    END
    L_XML.Save XML    ${scf_xml}    ${target_xml_path}
    ${file_content}    OperatingSystem.Get File    ${target_xml_path}
    ${file_content}    Replace String    ${file_content}    \&\#13;    ${EMPTY}
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    L_XML.Save XML    ${scf_xml}    ${target_xml_path}
    [Return]     ${target_xml_path}

Generate Full XML With Params Update For Specific Object
    [Documentation]    This kw is used to modify parameter for specific dn in specific scf xml file
    ...    Author: Kang Lixin
    [Arguments]    ${source_xml}    ${objDN}    ${param_dic}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${keys}    Get Dictionary Keys    ${param_dic}
    FOR    ${param}    IN    @{keys}
        L_XML.Set Element Text    ${source_xml}    ${param_dic['${param}']}   \r\n
        ...    cmData/managedObject[@distName="${objDN}"]/p[@name="${param}"]
    END
    [Return]     ${source_xml}

Remote BTS Setup
    [Documentation]    This kw is used to connect remote admin, infomodel, syslog
    ...    Author: Xu Yuyan
    [Arguments]    ${remote_host}    ${remote_host_username}    ${remote_host_password}    ${remote_alias}
    Log To Console    Remote BTS Setup
    ${file_limit}    Get Variable Value    ${MAX_UDP_SIZE}    0
    coam.Setup Admin    admin_api_log_dir=${BTS Files}    bts_host=${SMOD1['TRS_IP']}    bts_port=443    use_ssl=TRUE
    ...    alias=${remote_alias}    update_interval=1000    remote_host=${remote_host}
    ...    remote_host_username=${remote_host_username}    remote_host_password =${remote_host_password}
    ute_admin_infomodel.Setup Infomodel    address=${SMOD1['TRS_IP']}    port=443    timeout=90    use_ssl=True
    ...    admin_api_log_dir=${BTS Files}    alias=${remote_alias}    remote_host=${remote_host}
    ...    remote_host_username=${remote_host_username}    remote_host_password =${remote_host_password}
    taf_syslog.start_syslog    alias=${remote_alias}    log_dir=${Temp Logs Dir}    log_name=REMOTE_SMOD_UDP_1
    ...    ip=${SMOD1["UDP_IP"]}    host_ip=${remote_host}    ports=@{UDP ports}    file_limit=${file_limit}
    ...    ssh_username=${remote_host_username}    ssh_password=${remote_host_password}
    ...    virtualenv_dir=${virtualenv_dir}

Config Redundancy
    [Documentation]    This kw is used to config redundancy
    ...    Author: Xu Yuyan
    [Arguments]    ${MRBTS_ID}    ${operation}    ${parameters_dic}    ${alias}=default
    Log To Console    Config Redundancy On SBTS${MRBTS_ID}
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/REDUNDANCY-1
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${MRBTS_ID}_${time}
    ${param_names}    Run Keyword If    '${operation}'=='delete'    Create List    ELSE    Get Dictionary Keys    ${parameters_dic}
    coam.append_managed_object_to_delta    ${dist_name}    ${operation}    ${MRBTS_ID}_${time}
    FOR    ${param}    IN     @{param_names}
        Run Keyword If    "${parameters_dic["${param}"]}"=="empty"
        ...    coam.append_parameter_delete_to_delta    ${dist_name}    ${param}    ${MRBTS_ID}_${time}
        ...    ELSE    coam.append_parameter_update_to_delta    ${dist_name}    ${param}    ${parameters_dic["${param}"]}    ${MRBTS_ID}_${time}
    END
    ${delta_json}    coam.get_delta    delta_id=${MRBTS_ID}_${time}
    ${result}    coam.perform_delta_recommissioning    ${delta_json}    connection=${alias}

Check BTS Interfaces
    [Documentation]    This kw is used to check bts interfaces for 4G and 5G
    ...    Author: Xu Yuyan
    [Arguments]    ${alias}=default    ${s1LinkStatus}=available    ${x2LinkStatus_4g}=available    ${x2ToGnbLinkStatus}=available
    ...    ${ngLinkStatus}=Active    ${x2LinkStatus_5g}=available    ${xnLinkStatus}=available
    Log To Console    Check BTS Interfaces
    ${full_scf}    Admin Collect scf.xml with timestamp TAF    alias=${alias}    folder_path=${BTSFiles}   export_type=configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${full_scf}
    #4G interfaces
    ${obj_LNMME}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="NOKLTE:LNMME"]
    FOR    ${object}    IN    @{obj_LNMME}
        ${s1LinkSta}    L_XML.Get Element Text    ${object}    .//p[@name="s1LinkStatus"]
        Should Be Equal    ${s1LinkSta}    ${s1LinkStatus}
    END
    ${obj_LNADJ}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="NOKLTE:LNADJ"]
    FOR    ${object}    IN    @{obj_LNADJ}
        ${x2LinkSta_4g}    L_XML.Get Element Text    ${object}    .//p[@name="x2LinkStatus"]
        Should Be Equal    ${x2LinkSta_4g}    ${x2LinkStatus_4g}
    END
    ${obj_LNADJGNB}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="NOKLTE:LNADJGNB"]
    FOR    ${object}    IN    @{obj_LNADJGNB}
        ${x2ToGnbLinkSta}    L_XML.Get Element Text    ${object}    .//p[@name="x2ToGnbLinkStatus"]
        Should Be Equal    ${x2ToGnbLinkSta}    ${x2ToGnbLinkStatus}
    END
    #5G interfaces
    ${obj_SERVEDAMF}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.nrbts:SERVEDAMF"]
    FOR    ${object}    IN    @{obj_SERVEDAMF}
        ${ngLinkSta}    L_XML.Get Element Text    ${object}    .//p[@name="ngLinkStatus"]
        Should Be Equal    ${ngLinkSta}    ${ngLinkStatus}
    END
    ${obj_LTEENB}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.nrbts:LTEENB"]
    FOR    ${object}    IN    @{obj_LTEENB}
        ${x2LinkSta_5g}    L_XML.Get Element Text    ${object}    .//p[@name="x2LinkStatus"]
        Should Be Equal    ${x2LinkSta_5g}    ${x2LinkStatus_5g}
    END
    ${obj_XNLINK}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.nrbts:XNLINK"]
    FOR    ${object}    IN    @{obj_XNLINK}
        ${xnLinkSta}    L_XML.Get Element Text    ${object}    .//p[@name="xnLinkStatus"]
        Should Be Equal    ${xnLinkSta}    ${xnLinkStatus}
    END

Check SBTS Redundancy States
    [Documentation]    This kw is used to check bts redundancy state
    ...    Author: Xu Yuyan
    [Arguments]    ${self_role}    ${peer_role}    ${group}    ${timeout}=60    ${expected_LTE_states}=${cells_LTE_expected_state}
	...    ${expected_NR_states}=${cells_NR_expected_state}    ${alias}=default
    Run Keyword If    '${alias}'!='default'    ute_admin_infomodel.connect_infomodel    alias=${alias}
    ${self_redundancy_query}    Set Variable If    '${self_role}'=='empty'    none //REDUNDANCY_A-*
    ...    //REDUNDANCY_A-1 is [redundancyRole=${self_role},redundancyGroupId=${group}]
    ${LNCEL_ids}    coam.Get ids for all    LNCEL    connection=${alias}
    ${NRCEL_ids}    coam.Get ids for all    NRCEL    connection=${alias}
    Run Keyword If    ${LNCEL_ids}    coam.assert_every    LNCEL    ${expected_LTE_states}    timeout=${timeout}    alias=${alias}
    Run Keyword If    ${NRCEL_ids}    coam.assert_every    NRCEL    ${expected_NR_states}    timeout=${timeout}    alias=${alias}
    ute_admin_infomodel.query_infomodel    every //NRCELL_R-* is [${expected_NR_states}]    timeout=${timeout}    alias=${alias}
    ute_admin_infomodel.query_infomodel    ${self_redundancy_query}    timeout=${timeout}    alias=${alias}
    ute_admin_infomodel.query_infomodel    //SMOD_EXT_R-* is [redundancyRole=${peer_role}]    timeout=${timeout}    alias=${alias}

Collect Remote Syslog Informodel And Snapshot
    [Documentation]    This kw is used to collect syslog, infomodel and snapshot
    ...    Author: Xu Yuyan
    [Arguments]     ${alias}
    _Get Snapshot Via Admin API    timeout=300    alias=${alias}
    ute_admin_infomodel.Save infomodel log    ${BTS Files}/IM/${alias}_InfoModel_log.ims2    timeout=300    alias=${alias}
    Collect syslog from ${alias}

Run RF Diagnostic Test
    [Arguments]    ${cell_id}    ${cellType}    ${alias}=default
    coam.start_rf_diagnostic_test    True    ${cell_id}    ${cellType}    8    -8    3    -140    -30
    ...    alias=${alias}

Get And Check RF Diagnostic Test Result 5G
    [Arguments]    ${alias}=default
    ${test_result}=    coam.save_rf_diagnostic_test_results    alias=${alias}
    log many   ${test_result}
    ${out_len}    Get Length    ${test_result}
    Run Keyword If    '${out_len}' == '0'    Fail
    ${out_test_info}    Set Variable    ${test_result[0]}
    ${t_info}    Set Variable    ${out_test_info["results"]}
    Check RF Diagnostic Test Result 5G    ${t_info}

Check RF Diagnostic Test Result 5G
    [Arguments]    ${test_info}
    ${out_rtwp}  Evaluate   float(${test_info["rtwp"]}) != 0
	Should Start With    ${test_info["testOutcome"]}    Pass
    Should Start With    ${test_info["rvrsTestDisp"]}    Pass
    Should Start With    ${test_info["fwdTestDisp"]}    Pass
	#Should Be True    ${out_rtwp}
    ${detail_info}     Set Variable    ${test_info["rfAntResults"]}
    ${out_len}    Get Length    ${detail_info}
    FOR    ${index}    IN RANGE   0   ${out_len}
        ${antld_info}    Set Variable    ${detail_info[${index}]}
        ${out_sinr}  Evaluate   float(${antld_info["sinr"]}) != 0
	    Should Be True    ${out_sinr}
    END

Fetch BTS IDs
    [Arguments]     ${alias}=default
    [Documentation]   Fetch BTS IDs
    ...    Author: yuyan xu
    Log To Console    Fetch BTS IDs
    ${scf}    coam.Get Scf    connection=${alias}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse Xml    ${scf}
    ${mrbts_id}    Set Variable
    ${nrbts_id}    Set Variable
    ${lnbts_id}    Set Variable
    ${wnbts_id}    Set Variable
    ${gnbts_id}    Set Variable
    ${status}    ${mrbts}    Run Keyword And Ignore Error    L_XML.Get Element    ${scf_xml}    .//managedObject[@class="com.nokia.srbts:MRBTS"]
    ${mrbts_dn}    Run Keyword If    "${status}"=="PASS"    L_XML.Get Element Attribute    ${mrbts}    distName
    ${mrbts_id}    Run Keyword If    "${status}"=="PASS"    Fetch From Right    ${mrbts_dn}    -
    ${status}    ${nrbts}    Run Keyword And Ignore Error    L_XML.Get Element    ${scf_xml}   .//managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
    ${nrbts_dn}    Run Keyword If    "${status}"=="PASS"    L_XML.Get Element Attribute    ${nrbts}    distName
    ${nrbts_id}    Run Keyword If    "${status}"=="PASS"    Fetch From Right    ${nrbts_dn}    -
    ${status}    ${lnbts}    Run Keyword And Ignore Error    L_XML.Get Element    ${scf_xml}    .//managedObject[@class="NOKLTE:LNBTS"]
    ${lnbts_dn}    Run Keyword If    "${status}"=="PASS"    L_XML.Get Element Attribute    ${lnbts}    distName
    ${lnbts_id}    Run Keyword If    "${status}"=="PASS"    Fetch From Right    ${lnbts_dn}    -
    ${status}    ${wnbts}    Run Keyword And Ignore Error    L_XML.Get Element    ${scf_xml}   .//managedObject[@class="com.nokia.srbts.wcdma:WNBTS"]
    ${wnbts_dn}    Run Keyword If    "${status}"=="PASS"    L_XML.Get Element Attribute    ${wnbts}    distName
    ${wnbts_id}    Run Keyword If    "${status}"=="PASS"    Fetch From Right    ${wnbts_dn}    -
    ${status}    ${gnbts}    Run Keyword And Ignore Error    L_XML.Get Element    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.gsm:GNBTS"]
    ${gnbts_dn}    Run Keyword If    "${status}"=="PASS"    L_XML.Get Element Attribute    ${gnbts}    distName
    ${gnbts_id}    Run Keyword If    "${status}"=="PASS"    Fetch From Right    ${gnbts_dn}    -
    [Return]    ${mrbts_id}    ${nrbts_id}    ${lnbts_id}    ${wnbts_id}    ${gnbts_id}

Check All Cells Status As Expected Status
    [Arguments]     ${Impacted_Cells}    ${Impacted_Cell_Status}    ${alias}=default
    [Documentation]    Check All Cells Status As Expected Status
    ...    Author: yuyan xu
    ...    example:
    ...    Impacted_Cells:
    ...    {'NRCEL': ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-10368/NRCELL_R-1',
    ...              '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-10368/NRCELL_R-2'],
    ...      'LNCEL': [],
    ...      'WNCEL': [],
    ...      'GNCEL': []}
    ...    Impacted_Cell_Status:
    ...    {'NRCEL': operationalState=${_Disabled_}, availabilityStatus=${_Dependency_}, blockingState=${_Unblocked_}
    ...      'LNCEL': operationalState=${_Disabled_}, availabilityStatus=${_Dependency_}, blockingState=${_Unblocked_},
    ...      'WNCEL': operationalState=${_Disabled_}, availabilityStatus=${_Dependency_}, blockingState=${_Unblocked_},
    ...      'GNCEL': operationalState=${_Disabled_}, availabilityStatus=${_Dependency_}, blockingState=${_Unblocked_}}
    Log To Console    Check All Cells Status As Expected
    ${online_GNCEL_ids}    coam.Get ids for all    GNCEL    connection=${alias}
    ${online_WNCEL_ids}    coam.Get ids for all    WNCEL    connection=${alias}
    ${online_LNCEL_ids}    coam.Get ids for all    LNCEL    connection=${alias}
    ${online_NRCEL_ids}    coam.Get ids for all    NRCEL    connection=${alias}
    Set Test Variable     ${online_GNCEL_ids}
    Set Test Variable     ${online_WNCEL_ids}
    Set Test Variable     ${online_LNCEL_ids}
    Set Test Variable     ${online_NRCEL_ids}
    ${Impacted_Cells_ratTypes}    Get Dictionary Keys    ${Impacted_Cells}
    FOR    ${tech}    IN    @{Impacted_Cells_ratTypes}
        ${cell_id_list}    Set Variable    ${Impacted_Cells["${tech}"]}
        ${expected_status}    Set Variable    ${Impacted_Cell_Status["${tech}"]}
        Run Keyword If    "${cell_id_list.__len__()}"=="${0}"    Continue For Loop
        Check Impacted Cells Status As Expected    ${tech}    ${cell_id_list}    ${expected_status}    alias=${alias}
    END
    Check Online Cells Status As Expected    GNCEL    ${online_GNCEL_ids}    ${cells_GSM_expected_state}    alias=${alias}
    Check Online Cells Status As Expected    WNCEL    ${online_WNCEL_ids}    ${cells_WCDMA_expected_state}    alias=${alias}
    Check Online Cells Status As Expected    LNCEL    ${online_LNCEL_ids}    ${cells_LTE_expected_state}    alias=${alias}
    Check Online Cells Status As Expected    NRCEL    ${online_NRCEL_ids}    ${cells_NR_expected_state}    alias=${alias}

Check Impacted Cells Status As Expected
    [Arguments]     ${tech_cell}    ${cell_id_list}    ${expected_status}    ${alias}=default
    [Documentation]    Invoke by KW:Check All Cells Status As Expected
	Return From Keyword If    "${cell_id_list.__len__()}"=="${0}"
    FOR    ${cell_id}    IN    @{cell_id_list}
        Remove Values From List    ${online_${tech_cell}_ids}    ${cell_id}
        coam.Assert    ${tech_cell}    ${cell_id}    ${expected_status}    timeout=45s    connection=${alias}
    END

Check Online Cells Status As Expected
    [Arguments]     ${tech_cell}    ${cell_id_list}    ${expected_status}    ${alias}=default
    [Documentation]    Invoke by KW:Check All Cells Status As Expected
	Return From Keyword If    "${cell_id_list.__len__()}"=="${0}"
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${dic_cell_state}    coam.Assert    ${tech_cell}    ${cell_id}    ${expected_status}    timeout=45s    connection=${alias}
    END

Create Plan To Delete LNCELL Via NetAct
    [Arguments]    ${lncell_DN}    ${plan_name}=${EMPTY}    ${BTS_scf}=${BTS_scf_initial}    ${local_Dir}=${Test Results Dir}
    [Documentation]    Create Plan To Delete LNCELL Via NetAct
    ...    Author: yuyan xu
    Log To Console   Create LNCell Deletion Plan Via NetAct
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${name}    Set Variable If   "${plan_name}"=="${EMPTY}"    Create_LNCell_Deletion_Plan_${timestamp}    ${plan_name}
    ${plan}    Run Keyword If   "${plan_name}"=="${EMPTY}"    NetAct Create Plan    ${name}    Automation for ${name}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Should Be True    '${status}' == 'PASS'
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf}
    #${elements_for_lncell}    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@distName,"${lncell_DN}")]
    ${elements_for_lncell}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${lncell_DN}" or contains(@distName,"${lncell_DN}/")]
    ${selected_lncell_lcrid}    Get CM Parameter Value From SCF    ${BTS_scf}    ${lncell_DN}    lcrId
    #${lncell_cellmapping_str}    catenate    SEPARATOR=    LCELL-    ${selected_lncell_lcrid}
    ${lncell_cellmapping_str}    catenate    SEPARATOR=    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-    ${selected_lncell_lcrid}
    #${elements_for_cellMapping}    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@distName,"${lncell_cellmapping_str}")]
    ${elements_for_cellMapping}    L_XML.Get Elements    ${scf_xml}
    ...    .//managedObject[@distName="${lncell_cellmapping_str}" or contains(@distName,"${lncell_cellmapping_str}/")]
    ${elements_to_delete}    Combine Lists    ${elements_for_lncell}    ${elements_for_cellMapping}
    FOR    ${element}    IN    @{elements_to_delete}
        ${MO_items}    L_XML.Get Element Attributes    ${element}
        NetAct Create Managed Object    plan=${plan}
        ...    meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
        ...    mo_id=PLMN-PLMN/${MO_items["distName"]}    operation=DELETE    &{EMPTY}
    END
    #NRDCPR
    ${element_nrdcpr}    L_XML.Get Elements    ${scf_xml}     .//managedObject[@class="NOKLTE:NRDCPR"]
    FOR    ${nrdcpr}    IN    @{element_nrdcpr}
        Set Test Variable    ${nrdcpr_needUpdate}    ${False}
        ${MO_NRDCPR}    L_XML.Get Element Attributes    ${nrdcpr}
        ${nrdcpr_dic_list}    Create List
        ${MO_items}    L_XML.Get Elements    ${nrdcpr}
        ...    .//list[@name="dynTriggerLteNrDcConfList"]/item
        FOR    ${item}    IN    @{MO_items}
            ${match_count}    L_XML.Get Element Count    ${item}
            ...    p[@name="lcrId" and text()="${lncell_DN.split("-")[-1]}"]
            Run Keyword If  "${match_count}">"${0}"    Run keywords
            ...    Set Test Variable    ${nrdcpr_needUpdate}    ${True}    AND    Continue For Loop
            ${params}    L_XML.Get Elements    ${item}    p
            ${nrdcpr_dic}    Create Dictionary
            FOR    ${param}    IN    @{params}
                ${param_attr}    L_XML.Get Element Attributes    ${param}
                ${param_value}    L_XML.Get Element Text    ${param}
                ${param_value}    Run Keyword If    '${param_value}'=='coverageBased'    Set Variable    10
                ...    ELSE IF     '${param_value}'=='coverageAndBufferBased'    Set Variable    20
                ...    ELSE IF     '${param_value}'=='coverageAndDlUlBufferBased'    Set Variable    30
                ...    ELSE    Set Variable    ${param_value}
                Set To Dictionary    ${nrdcpr_dic}    ${param_attr['name']}    ${param_value}
            END
            Append To List  ${nrdcpr_dic_list}    ${nrdcpr_dic}
            Log    ${nrdcpr_dic_list}
        END
        Log    ${nrdcpr_dic_list}
        ${nrdcpr_dic_list_dic}    Create Dictionary    dynTriggerLteNrDcConfList    ${nrdcpr_dic_list}
        Run Keyword If    ${nrdcpr_needUpdate}    NetAct Create Managed Object    plan=${plan}
        ...    meta_class=${MO_NRDCPR['class']}    meta_version=${MO_NRDCPR['version']}
        ...    mo_id=PLMN-PLMN/${MO_NRDCPR["distName"]}    &{nrdcpr_dic_list_dic}
    END
    #NRDCDPR
    ${element_nrdcdpr}    L_XML.Get Elements    ${scf_xml}     .//managedObject[@class="NOKLTE:NRDCDPR"]
    FOR    ${nrdcdpr}    IN    @{element_nrdcdpr}
        Set Test Variable    ${nrdcdpr_needUpdate}    ${False}
        ${MO_NRDCDPR}    L_XML.Get Element Attributes    ${nrdcdpr}
        ${nrdcdpr_dic_list}    Create List
        ${MO_items}    L_XML.Get Elements    ${nrdcdpr}
        ...    .//list[@name="dynTriggerLteNrDcConfList"]/item
        FOR    ${item}    IN    @{MO_items}
            ${match_count}    L_XML.Get Element Count    ${item}
            ...    p[@name="lcrId" and text()="${lncell_DN.split("-")[-1]}"]
            Run Keyword If  "${match_count}">"${0}"    Run keywords
            ...    Set Test Variable    ${nrdcdpr_needUpdate}    ${True}    AND    Continue For Loop
            ${params}    L_XML.Get Elements    ${item}    p
            ${nrdcdpr_dic}    Create Dictionary
            FOR    ${param}    IN    @{params}
                ${param_attr}    L_XML.Get Element Attributes    ${param}
                ${param_value}    L_XML.Get Element Text    ${param}
                ${param_value}    Run Keyword If    '${param_value}'=='coverageBased'    Set Variable    10
                ...    ELSE IF     '${param_value}'=='coverageAndBufferBased'    Set Variable    20
                ...    ELSE IF     '${param_value}'=='coverageAndDlUlBufferBased'    Set Variable    30
                ...    ELSE    Set Variable    ${param_value}
                Set To Dictionary    ${nrdcdpr_dic}    ${param_attr['name']}    ${param_value}
            END
            Append To List  ${nrdcdpr_dic_list}    ${nrdcdpr_dic}
            Log    ${nrdcdpr_dic_list}
        END
        Log    ${nrdcdpr_dic_list}
        ${nrdcdpr_dic_list_dic}    Create Dictionary    dynTriggerLteNrDcConfList    ${nrdcdpr_dic_list}
        Run Keyword If    ${nrdcdpr_needUpdate}    NetAct Create Managed Object    plan=${plan}
        ...    meta_class=${MO_NRDCDPR['class']}    meta_version=${MO_NRDCDPR['version']}
        ...    mo_id=PLMN-PLMN/${MO_NRDCDPR["distName"]}    &{nrdcdpr_dic_list_dic}
    END
    #PSGRP
    ${element_psgrp}    L_XML.Get Elements    ${scf_xml}     .//managedObject[@class="NOKLTE:PSGRP"]
    FOR    ${psgrp}    IN    @{element_psgrp}
        Set Test Variable    ${psgrp_needUpdate}    ${False}
        ${MO_PSGRP}    L_XML.Get Element Attributes    ${psgrp}
        ${psgrp_dic_list}    Create List
        ${MO_items}    L_XML.Get Elements    ${psgrp}
        ...    .//list[@name="lbpsCellList"]/item
        FOR    ${item}    IN    @{MO_items}
            ${match_count}    L_XML.Get Element Count    ${item}
            ...    p[@name="lnCelId" and text()="${lncell_DN.split("-")[-1]}"]
            Run Keyword If  "${match_count}">"${0}"    Run keywords
            ...    Set Test Variable    ${psgrp_needUpdate}    ${True}    AND    Continue For Loop
            ${params}    L_XML.Get Elements    ${item}    p
            ${psgrp_dic}    Create Dictionary
            FOR    ${param}    IN    @{params}
                ${param_attr}    L_XML.Get Element Attributes    ${param}
                ${param_value}    L_XML.Get Element Text    ${param}
                Set To Dictionary    ${psgrp_dic}    ${param_attr['name']}    ${param_value}
            END
            Append To List  ${psgrp_dic_list}    ${psgrp_dic}
            Log    ${psgrp_dic_list}
        END
        Log    ${psgrp_dic_list}
        ${psgrp_dic_list_dic}    Create Dictionary    lbpsCellList    ${psgrp_dic_list}
        Run Keyword If    ${psgrp_needUpdate}    NetAct Create Managed Object    plan=${plan}
        ...    meta_class=${MO_PSGRP['class']}    meta_version=${MO_PSGRP['version']}
        ...    mo_id=PLMN-PLMN/${MO_PSGRP["distName"]}    &{psgrp_dic_list_dic}
    END
    NetAct Export Plan    local_dir=${local_Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan
    [Return]   ${name}

Create Plan To Delete NRCELL Via NetAct
    [Arguments]    ${nrcell_DN}     ${BTS_scf}=${BTS_scf_initial}    ${Local_Dir}=${Test Results Dir}    ${plan_name}=${EMPTY}
    [Documentation]    Create Plan To Delete NRCELL Via NetAct
    ...    Author: yuyan xu
    ...    Updated: lixin kang add nrrel deleting on 6/27
    Log To Console   Create NRCell Deletion Plan Via NetAct
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${name}    Set Variable If   "${plan_name}"=="${EMPTY}"    Create_NRCell_Deletion_Plan_${timestamp}    ${plan_name}
    ${plan}    Run Keyword If   "${plan_name}"=="${EMPTY}"    NetAct Create Plan    ${name}    Automation for ${name}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Should Be True    '${status}' == 'PASS'
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf}
    #${elements_for_nrcell}    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@distName,"${nrcell_DN}")]
    ${elements_for_nrcell}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${nrcell_DN}" or contains(@distName,"${nrcell_DN}/")]
    ${selected_nrcell_lcrid}    Get CM Parameter Value From SCF    ${BTS_scf}    ${nrcell_DN}    lcrId
    #${nrcell_cellmapping_str}    catenate    SEPARATOR=    LCELNR-    ${selected_nrcell_lcrid}
    ${nrcell_cellmapping_str}    catenate    SEPARATOR=    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-    ${selected_nrcell_lcrid}
    #${elements_for_cellMapping}    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@distName,"${nrcell_cellmapping_str}")]
    ${elements_for_cellMapping}    L_XML.Get Elements    ${scf_xml}
    ...    .//managedObject[@distName="${nrcell_cellmapping_str}" or contains(@distName,"${nrcell_cellmapping_str}/")]
    #NRREL
    ${element_nrrels}    L_XML.Get Elements    ${scf_xml}     .//managedObject[@class="com.nokia.srbts.nrbts:NRREL"]
    ${elements_for_nrrel}    Create List
    FOR    ${element}    IN    @{element_nrrels}
        ${MO_items}    L_XML.Get Element Attributes    ${element}
        ${lcrid}    L_XML.Get Element Text    ${scf_xml}   .//managedObject[@distName="${MO_items['distName']}"]/p[@name="lcrId"]
        ${nrcell_cellmapping_id}    Fetch From Right    ${nrcell_cellmapping_str}    -
        Run Keyword If    '${lcrid}'=='${nrcell_cellmapping_id}'    Append To List    ${elements_for_nrrel}    ${element}
    END
    ${elements_to_delete}    Combine Lists    ${elements_for_nrcell}    ${elements_for_cellMapping}     ${elements_for_nrrel}
    FOR    ${element}    IN    @{elements_to_delete}
        ${MO_items}    L_XML.Get Element Attributes    ${element}
        NetAct Create Managed Object    plan=${plan}
        ...    meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
        ...    mo_id=PLMN-PLMN/${MO_items["distName"]}    operation=DELETE    &{EMPTY}
    END
    #Cellgroup
    ${elements_for_nrcellGroup}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]
    ${cellgroup_dns}    Create List
    FOR    ${cellgroup}    IN    @{elements_for_nrcellGroup}
        ${MO_items}    L_XML.Get Element Attributes    ${cellgroup}
        Append To List    ${cellgroup_dns}    ${MO_items}
    END
    ${selected_nrcellgroup}    Set Variable
    FOR    ${cellgroup}    IN    @{elements_for_nrcellGroup}
        ${MO_items}    L_XML.Get Element Attributes    ${cellgroup}
        ${nrCellList}    L_XML.Get Elements Texts    ${scf_xml}   .//managedObject[@distName="${MO_items['distName']}"]/list[@name="nrCellList"]
        ${formatedNRCellList}    Formatted NRCellList    ${nrCellList}
        ${isSlected_nrcell_cellgroup}    Run Keyword And Return Status
        ...    List Should Contain Value    ${formatedNRCellList}    ${nrcell_DN.split("-")[-1]}
        Continue For Loop If    not ${isSlected_nrcell_cellgroup}
        Remove Values From List    ${formatedNRCellList}    ${nrcell_DN.split("-")[-1]}
        Set Test Variable    ${formatedNRCellList}
        ${len}    Get Length    ${formatedNRCellList}
        ${nrcellgroup_operation}    Set Variable If    '${len}'=='0'   delete    update
        ${selected_nrcellgroup}    Set Variable    ${MO_items}
        Exit For Loop
    END
    Remove Values From List    ${cellgroup_dns}    ${selected_nrcellgroup}
    ${other_cellgroup_ids}    Create List
    FOR    ${cellgroup}    IN    @{cellgroup_dns}
        ${distName}    Set Variable    ${cellgroup['distName']}
        ${grp_id}    Fetch From Right    ${distName}    -
        Append To List    ${other_cellgroup_ids}    ${grp_id}
    END
    Run Keyword If    '${nrcellgroup_operation}'=='delete'    NetAct Create Managed Object    plan=${plan}
    ...    meta_class=${selected_nrcellgroup['class']}    meta_version=${selected_nrcellgroup['version']}
    ...    mo_id=PLMN-PLMN/${selected_nrcellgroup["distName"]}    operation=DELETE    &{EMPTY}
    ...    ELSE    NetAct Create Managed Object    plan=${plan}    meta_class=${selected_nrcellgroup['class']}
    ...    meta_version=${selected_nrcellgroup['version']}    mo_id=PLMN-PLMN/${selected_nrcellgroup["distName"]}   nrCellList=${formatedNRCellList}
    #NRDU
    ${element_nrdu}    L_XML.Get Elements    ${scf_xml}     .//managedObject[@class="com.nokia.srbts.nrbts:NRDU"]
    ${MO_NRDU}    L_XML.Get Element Attributes    ${element_nrdu[0]}
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_NRDU['class']}
    ...    meta_version=${MO_NRDU['version']}    mo_id=PLMN-PLMN/${MO_NRDU["distName"]}    refNrCellGroup=${other_cellgroup_ids}
    #NRPGRP
    ${lbpsCellSOMethod}    Create Dictionary    cell switch off=0    TX switch off=1    mixed switch off=2
    ${lbpsCellDayOfWeek}    Create Dictionary    Sun=0    Mon=1    Tue=2    Wed=3   Thu=4    Fri=5    Sat=6
    ${element_nrpgrp}    L_XML.Get Elements    ${scf_xml}     .//managedObject[@class="com.nokia.srbts.nrbts:NRPGRP"]
    FOR    ${nrpgrp}    IN    @{element_nrpgrp}
        ${MO_NRPGRP}    L_XML.Get Element Attributes    ${nrpgrp}
        #lbpsCellList
        Set Test Variable    ${nrpgrp_needUpdate}    ${False}
        ${nrpgrp_dic_list}    Create List
        ${MO_items}    L_XML.Get Elements    ${nrpgrp}
        ...    .//list[@name="lbpsCellList"]/item
        ${MO_items_len}    Get Length   ${MO_items}
        FOR    ${item}    IN    @{MO_items}
            ${match_count}    L_XML.Get Element Count    ${item}
            ...    p[@name="nrCellId" and text()="${nrcell_DN.split("-")[-1]}"]
            Run Keyword If  "${match_count}">"${0}"    Run keywords
            ...    Set Test Variable    ${nrpgrp_needUpdate}    ${True}    AND    Continue For Loop
            ${params}    L_XML.Get Elements    ${item}    p
            ${nrpgrp_dic}    Create Dictionary
            FOR    ${param}    IN    @{params}
                ${param_attr}    L_XML.Get Element Attributes    ${param}
                ${param_value}    L_XML.Get Element Text    ${param}
                Set To Dictionary    ${nrpgrp_dic}    ${param_attr['name']}    ${param_value}
            END
            Append To List  ${nrpgrp_dic_list}    ${nrpgrp_dic}
            Log    ${nrpgrp_dic_list}
        END
        Log    ${nrpgrp_dic_list}
        ${nrpgrp_dic_list_dic}    Create Dictionary    lbpsCellList    ${nrpgrp_dic_list}
        Run Keyword If    ${nrpgrp_needUpdate} and "${MO_items_len}"=="${1}"    Run Keywords
        ...    NetAct Create Managed Object    plan=${plan}
        ...    meta_class=${MO_NRPGRP['class']}    meta_version=${MO_NRPGRP['version']}
        ...    mo_id=PLMN-PLMN/${MO_NRPGRP["distName"]}    operation=DELETE    &{EMPTY}
        ...    AND    Continue For Loop
        Run Keyword If    ${nrpgrp_needUpdate}    NetAct Create Managed Object    plan=${plan}
        ...    meta_class=${MO_NRPGRP['class']}    meta_version=${MO_NRPGRP['version']}
        ...    mo_id=PLMN-PLMN/${MO_NRPGRP["distName"]}    &{nrpgrp_dic_list_dic}
        #lbpsCellPeriodList
        Set Test Variable    ${nrpgrp_needUpdate2}    ${False}
        ${nrpgrp_dic_list2}    Create List
        ${MO_items2}    L_XML.Get Elements    ${nrpgrp}
        ...    .//list[@name="lbpsCellPeriodList"]/item
        FOR    ${item}    IN    @{MO_items2}
            ${match_count}    L_XML.Get Element Count    ${item}
            ...    p[@name="nrCellId" and text()="${nrcell_DN.split("-")[-1]}"]
            Run Keyword If  "${match_count}">"${0}"    Run keywords
            ...    Set Test Variable    ${nrpgrp_needUpdate2}    ${True}    AND    Continue For Loop
            ${params}    L_XML.Get Elements    ${item}    p
            ${nrpgrp_dic2}    Create Dictionary
            FOR    ${param}    IN    @{params}
                ${param_attr}    L_XML.Get Element Attributes    ${param}
                ${param_value}    L_XML.Get Element Text    ${param}
                ${param_value}    Set Variable If    "${param_attr['name']}"=="lbpsCellDayOfWeek"
                ...    ${lbpsCellDayOfWeek["${param_value}"]}    ${param_value}
                ${param_value}    Set Variable If    "${param_attr['name']}"=="lbpsCellSOMethod"
                ...    ${lbpsCellSOMethod["${param_value}"]}    ${param_value}
                Set To Dictionary    ${nrpgrp_dic2}    ${param_attr['name']}    ${param_value}
            END
            Append To List  ${nrpgrp_dic_list2}    ${nrpgrp_dic2}
            Log    ${nrpgrp_dic_list2}
        END
        Log    ${nrpgrp_dic_list2}
        ${nrpgrp_dic_list_dic2}    Create Dictionary    lbpsCellPeriodList    ${nrpgrp_dic_list2}
        Run Keyword If    ${nrpgrp_needUpdate2}    NetAct Create Managed Object    plan=${plan}
        ...    meta_class=${MO_NRPGRP['class']}    meta_version=${MO_NRPGRP['version']}
        ...    mo_id=PLMN-PLMN/${MO_NRPGRP["distName"]}    &{nrpgrp_dic_list_dic2}
    END
    NetAct Export Plan    local_dir=${Local_Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan
    [Return]   ${name}

Formatted NRCellList
    [Arguments]     ${nrCellList}
    [Documentation]    Invoke by KW:Create Plan To Delete NRCELL Via NetAct
    ${formatedNRCellList}    Create List
    FOR    ${item}    IN    @{nrCellList}
        ${cellid}    Set Variable    ${item.strip()}
        Append To List    ${formatedNRCellList}    ${cellid}
    END
    [Return]     ${formatedNRCellList}

Cleanup pdcchAutoConfig via Delta Recomission
    [Arguments]    ${alias}=default
    [Documentation]    delete parameter pdcchAutoConfig in current configuration through delta recomission
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    coam.Get SCF    connection=${alias}
    ${element_cnt}    L_XML.Get Element Count   ${scf_content}
    ...    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/list[@name="pdcchAutoConfig"]
    Return From Keyword If   ${element_cnt}==0
    ${nrcell_elements}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    ${nrcell_dn_list}    Create List
    FOR    ${element}    IN    @{nrcell_elements}
        ${nrcell}    L_XML.Get Element Attribute    ${element}   distName
        Append To List   ${nrcell_dn_list}    ${nrcell}
    END
    ${timestamp}    Generate Formatted Timestamp
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${delta_id}    Set Variable    preparation_${mrbts_id}_${timestamp}
    coam.Create Delta    ${delta_id}
    FOR    ${nrcell_dn}    IN    @{nrcell_dn_list}
        coam.Append Parameter Delete To Delta    ${nrcell_dn}   pdcchAutoConfig    ${delta_id}
    END
    ${delta_json}    coam.Get Delta    ${delta_id}
    coam.Perform Delta Recommissioning    ${delta_json}    True    connection=${alias}
    ${scf_content}    coam.Get SCF    connection=${alias}
    ${element_cnt}    L_XML.Get Element Count   ${scf_content}
    ...    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/list[@name="pdcchAutoConfig"]
    Should Be True    ${element_cnt} ==0

Cleanup pdcchAutoConfig in SCF
    [Arguments]    ${scf_path}
    [Documentation]    delete parameter pdcchAutoConfig in SCF file
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse xml    ${scf_path}
    ${element_cnt}    L_XML.Get Element Count   ${scf_content}
    ...    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/list[@name="pdcchAutoConfig"]
    Return From Keyword If   ${element_cnt}==0    ${scf_path}
    L_XML.Remove Elements    ${scf_content}
    ...    cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/list[@name="pdcchAutoConfig"]  remove_tail=${True}
    L_XML.Save XML    ${scf_content}    ${scf_path}

Enable CB012523 Feature
    [Arguments]    ${cellDNConfig_list}    ${maxCellDisableTimeWhenNmsLost}=30    ${shutdownWindow}=180    ${alias}=default
    [Documentation]    Enable CB012523 Feature
    ...    Author: yuyan xu
    Log To Console    Enable CB012523 Feature
    ${nrbts_dn}    Fetch From Left    ${cellDNConfig_list[0]}    /NRCELL-
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=enableFeature_${time}
    FOR    ${cellDNConfig}    IN    @{cellDNConfig_list}
        coam.append_managed_object_to_delta    ${cellDNConfig}    update    enableFeature_${time}
        coam.append_parameter_update_to_delta    ${cellDNConfig}
        ...    disableCellWhenNmsLost    true    enableFeature_${time}
    END
    coam.append_managed_object_to_delta    ${nrbts_dn}    update    enableFeature_${time}
    coam.append_parameter_update_to_delta    ${nrbts_dn}
    ...    maxCellDisableTimeWhenNmsLost    ${maxCellDisableTimeWhenNmsLost}    enableFeature_${time}
    coam.append_parameter_update_to_delta    ${nrbts_dn}    shutdownWindow    ${shutdownWindow}    enableFeature_${time}
    ${delta_json}    coam.get_delta    delta_id=enableFeature_${time}
    ${result}    coam.perform_delta_recommissioning    ${delta_json}    connection=${alias}


Check NMS State
    [Arguments]    ${expected_state}    ${alias}=default
    [Documentation]    Check NMS State as ${expected_state}
    ...    Author: yuyan xu
    Log To Console    Check NMS State
    ${nms_state}    coam.get_nms_state    connection=${alias}
    ${dl_state}    Set Variable    ${nms_state[0]["downlinkFromNMS"]}
    Log To Console    ${dl_state}
    Should Be True    "${dl_state}"=="${expected_state}"

Disconnect NMS Link By mPlaneIpv4AddressDN
    [Arguments]    ${localIpAddr}    ${alias}=default
    [Documentation]    Disconnect NMS Link By mPlaneIpv4AddressDN
    ...    Author: yuyan xu
    Log To Console    Disconnect NMS Link By mPlaneIpv4AddressDN
    ${scf}    coam.Get Scf    connection=${alias}
    ${mrbts_dn}     Get Regexp Matches    ${scf}    distName="MRBTS-\\d+
    ${mrbts_id}   Set Variable    ${mrbts_dn[0].split("-")[-1]}
    ${mPlaneIpv4AddressDN_origin}    Get Parameter Value From WebEM
    ...    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1    mPlaneIpv4AddressDN    alias=${alias}
    ${mPlaneIpv4AddressDN_prefix}    Fetch From Left    ${mPlaneIpv4AddressDN_origin}    /IPADDRESSV4-
    ${Ipv4adds}     Get Regexp Matches    ${scf}    distName="${mPlaneIpv4AddressDN_prefix}/IPADDRESSV4-\\d+
    ${Ipv4add_nums}    Create List
    FOR    ${item}    IN    @{Ipv4adds}
        ${number}    Evaluate    int(${item.split("-")[-1]})
        Append To List    ${Ipv4add_nums}    ${number}
    END
    ${max_number}    Evaluate    max(${Ipv4add_nums})
    Log To Console    ${${max_number}+1}
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${mrbts_id}_${time}
    coam.append_managed_object_to_delta
    ...    ${mPlaneIpv4AddressDN_prefix}/IPADDRESSV4-${${max_number}+1}    create    ${mrbts_id}_${time}
    coam.append_managed_object_to_delta
    ...    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1    update    ${mrbts_id}_${time}
    coam.append_parameter_update_to_delta    ${mPlaneIpv4AddressDN_prefix}/IPADDRESSV4-${${max_number}+1}
    ...    localIpPrefixLength    26    ${MRBTS_ID}_${time}
    coam.append_parameter_update_to_delta    ${mPlaneIpv4AddressDN_prefix}/IPADDRESSV4-${${max_number}+1}
    ...    ipAddressAllocationMethod    MANUAL    ${MRBTS_ID}_${time}
    coam.append_parameter_update_to_delta    ${mPlaneIpv4AddressDN_prefix}/IPADDRESSV4-${${max_number}+1}
    ...    localIpAddr    ${localIpAddr}    ${MRBTS_ID}_${time}
    coam.append_parameter_update_to_delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1
    ...    mPlaneIpv4AddressDN    ${mPlaneIpv4AddressDN_prefix}/IPADDRESSV4-${${max_number}+1}    ${MRBTS_ID}_${time}
    ${delta_json}    coam.get_delta    delta_id=${mrbts_id}_${time}
    ${result}    coam.perform_delta_recommissioning    ${delta_json}    connection=${alias}
    ${mPlaneIpv4AddressDN_new}    Set Variable    ${mPlaneIpv4AddressDN_prefix}/IPADDRESSV4-${${max_number}+1}
    [Return]    ${mPlaneIpv4AddressDN_origin}    ${mPlaneIpv4AddressDN_new}

Update MRBTSID And Integrate To NetAct
    [Arguments]    ${alias}=default
    [Documentation]    For CNI-127255. Update MRBTSID And Integrate To NetAct，
    ${output}    OperatingSystem.Run    ip addr show | grep "inet " | awk '{print $2}' | cut -d/ -f1
    ${lines}    Split To Lines    ${output}
    ${Ip_string}    Set Variable
    ${VM_IP}     Set Variable
    FOR    ${line}    IN    @{lines}
        ${status}    ${ip}    Run Keyword And Ignore Error    Should Match Regexp    ${line}    10.[1-9]\\d+\\.\\d+\\.\\d+
        ${Ip_string}    Run Keyword If    "${status}"=="PASS"    Set Variable    ${ip.replace('.','')}
        ${VM_IP}    Run Keyword If    "${status}"=="PASS"    Set Variable    ${ip}
        Exit For Loop If    "${status}"=="PASS"
    END
    Log To Console    ${Ip_string}
    ${source_scf}    coam.Get Scf    connection=${alias}
    ${target_scf}    Set Variable    ${BTSFiles}/modified_btsid_scf_file.xml
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    #${file_content}    OperatingSystem.Get File    ${source_scf}
    ${file_content}    Replace String    ${source_scf}    MRBTS-1    MRBTS-${Ip_string}
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    L_XML.Save XML    ${scf_xml}    ${target_scf}
    Log To Console    ${target_scf}
    coam.Perform Commissioning      1     ${target_scf}
    ...    skip_parameter_relation_errors=${TRUE}    timeout=600
    Set Test Variable    ${MRBTS_DN}    PLMN-PLMN/MRBTS-${Ip_string}
    Set Test Variable    ${mrbts_id}    MRBTS-${Ip_string}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    #Wait Until Keyword Succeeds    3x    15s
    #...    Integrate NE To NetAct    ${VM_IP}    PLMN-PLMN/MRBTS-${Ip_string}    ${Trunk_Prefix.replace('SBTS','')}     #25R1
    Wait Until Keyword Succeeds    3x    15s    netact.Integrate MRBTS with Netact    mrbts_address=${VM_IP}
    ...    dist_name=PLMN-PLMN/MRBTS-${Ip_string}    release=${Trunk_Prefix}    mr=MRC-COMMON/MR-COMMON    security_mode=no TLS
	NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${Ip_string}

Get Auto Create Obj Info From SCF
    [Arguments]     ${obj_xpath}    ${scf_xml}=${BTS_scf_initial}
    [Documentation]    get auto create obj info for CB009175 from SCF by given scf and element xpath
    ...    Author: kang lixin
    ...    scf_xml: site init scf file before testing
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse xml    ${scf_xml}
    ${obj_element}    L_XML.Get Elements    ${scf_content}    ${obj_xpath}
    ${obj_dn_list}    Create List
    FOR    ${item}    IN    @{obj_element}
        ${dn}    L_XML.Get Element Attribute    ${item}    distName
        Append To List    ${obj_dn_list}    ${dn}
    END
    Sort List    ${obj_dn_list}
    ${need_auto_create_obj}    Set Variable    ${obj_dn_list[0]}
    Remove Values From List     ${obj_dn_list}    ${need_auto_create_obj}
    [Return]    ${obj_dn_list}    ${need_auto_create_obj}


Create Plan To Enable CB009936 And CB009175 On NetAct
    [Arguments]    ${nrcell_DNs}    ${mo_params}    ${plan_name}=${EMPTY}    ${BTS_scf}=${BTS_scf_initial}    ${local_dir}=${Test Results Dir}
    [Documentation]    Create Plan On NetAct to enable CB009936 And CB009175, or enable CB009175
    ...    if ${plan_name} is ${EMPTY} will create plan, or use the given plan_name
    ...    Author: Yuyan Xu
    ...    | Parameter | Mandatory | Description |
    ...    | nrcell_DNs | Yes | list e.g. ['MRBTS-1815/NRBTS-5487/NRCELL-2', 'MRBTS-1815/NRBTS-5487/NRCELL-1'] |
    ...    | mo_params | Yes | dic e.g. {'MRBTS-1815/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1': {'actSimplChConfMAA': 'true'},
    ...                                  'MRBTS-1815/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2': {'actSimplChConfMAA': 'true'} |
    ...    | name | No | Plan name e.g. Enable_Features_20220217123456 |
    ...    | Return |
    ...    | name | Yes | Plan name e.g. Enable_Features_20220217123456 |
    ...    example:
    ...    Create Plan To Enable CB009936 And CB009175 On NetAct    ${nrcell_DNs}    ${mo_params}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${name}    Set Variable If   "${plan_name}"=="${EMPTY}"    Enable_Features_${timestamp}    ${plan_name}
    ${plan}    Run Keyword If   "${plan_name}"=="${EMPTY}"    NetAct Create Plan    ${name}    Automation for ${name}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Should Be True    '${status}' == 'PASS'
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf}
    ${MO_dns}    Get Dictionary Keys    ${mo_params}
    FOR    ${MO_dn}    IN    @{MO_dns}
        ${mo_attrs}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${MO_dn}"]
        ${parameters}    Create Dictionary
        ${parameters}    Set Variable    ${mo_params["${MO_dn}"]}
        NetAct Create Managed Object    plan=${plan}    meta_class=${mo_attrs['class']}
        ...    meta_version=${mo_attrs['version']}    mo_id=PLMN-PLMN/${MO_dn}    &{parameters}
    END
    FOR    ${nrcell_DN}    IN    @{nrcell_DNs}
        ${nrcell_lcrid}    Get CM Parameter Value From SCF    ${BTS_scf}    ${nrcell_DN}    lcrId
        ${cellmapping_dn_str}    Set Variable    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${nrcell_lcrid}
        ${channelgroup_dn_list}    ${auto_create_channelgroup}    Get Auto Create Obj Info From SCF
        ...    obj_xpath=.//managedObject[@class="com.nokia.srbts.mnl:CHANNELGROUP" and contains(@distName,"${cellmapping_dn_str}")]
        FOR    ${MO_dn}    IN    @{channelgroup_dn_list}
            ${mo_attrs}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${channelgroup_dn_list[0]}"]
            NetAct Create Managed Object    plan=${plan}
            ...    meta_class=${mo_attrs['class']}    meta_version=${mo_attrs['version']}
            ...    mo_id=PLMN-PLMN/${MO_dn}    operation=DELETE    &{EMPTY}
        END
        ${channel_dn_list}    ${auto_create_channel}    Get Auto Create Obj Info From SCF
        ...    obj_xpath=.//managedObject[@class="com.nokia.srbts.mnl:CHANNEL" and contains(@distName,"${cellmapping_dn_str}")]
        FOR    ${MO_dn}    IN    @{channel_dn_list}
            ${mo_attrs}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${channel_dn_list[0]}"]
            NetAct Create Managed Object    plan=${plan}
            ...    meta_class=${mo_attrs['class']}    meta_version=${mo_attrs['version']}
            ...    mo_id=PLMN-PLMN/${MO_dn}    operation=DELETE    &{EMPTY}
        END
    END
    NetAct Export Plan    local_dir=${local_dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan
    [Return]    ${name}