*** Settings ***
Documentation  This suite contains general KWs used by TCs form LOGs dir and resources.

# product-specfic settings:
Library           SSHLibrary
Library           hran_file_operations
Library           ute_admin_infomodel
Library           Collections
Library           OperatingSystem
Library           Process
Library           String
Library           DateTime
Library           taf.sbts.oam.coam.admin  WITH NAME  coam
Library           taf.transport.ssh  WITH NAME  ssh
Library           taf.config.scf  WITH NAME  scf
Library           taf.hw.pdu  WITH NAME  pdu
Library           taf.sw.ping  WITH NAME  ping
Library           taf.sw.scout  WITH NAME  scout
Library           XML    use_lxml=true
# common settings:
#Resource          pm_logs_general.robot
Library           ute_syslog



*** Variables ***
#${NETACT_LAB}    &{srnclab1019}
#all needed variables should be given using '--variablefile CONFIG_FILE' or '-V CONFIG_FILE'
@{UDP ports}=                       51000    51001    51003    50011
${RMOD_expected_states}=           administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
    ...                            availabilityStatus=regex"(?i)Online"
${SMOD_expected_states}=           administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
    ...                            availabilityStatus=regex"(?i)"Online"
${ALD_expected_states}=            operationalState=regex"(?i)Enabled", availabilityStatus=Online
${cells_LTE_expected_states}=      administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
    ...                            availabilityStatus=regex"(?i)Online", blockingState=regex"(?i)Unblocked"
${cells_WCDMA_expected_states}=    operationalState=regex"(?i)Enabled", availabilityStatus=regex"(?i)Online",
    ...                            blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${dist_GSM_cell_runtime_view}=     /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/GNBTS_R-*/GNBCF_R-*/GNCEL_R-*
${cells_GSM_expected_states}=      administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
    ...                            availabilityStatus=regex"(?i)Online", blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${cells_NR_expected_states}=       administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
${COLLECT_SNAPSHOT_FLAG}=          failed_verdict
${SEND_LOGS_TO_ROTTA_FLAG}=        yes
&{IGNORED_FAULT_61524}=            faultId=61524  faultName=SSH enabled
&{IGNORED_FAULT_61652}=            faultId=61652  faultName=R&D Service Port enabled
&{IGNORED_FAULT_61649}=            faultId=61649  faultName=LMP access via port
&{IGNORED_FAULT_4655}=             faultId=4655  faultName=Service account root access is enabled
&{IGNORED_FAULT_4654}=             faultId=4654  faultName=Ethernet port security is disabled
&{IGNORED_FAULT_4681}=             faultId=4681  faultName=Sanity Check Error
&{IGNORED_FAULT_4590}=             faultId=4590  faultName=Fault signature for crash or failure
&{IGNORED_FAULT_61074}=            faultId=61074  faultName=CRL Update Failure
&{IGNORED_FAULT_4458}=             faultId=4458  faultName=SSH Login Configuration failed

@{GLOBALLY_IGNORED_ALARMS}=        ${IGNORED_FAULT_61524}  ${IGNORED_FAULT_61652}  ${IGNORED_FAULT_61649}    ${IGNORED_FAULT_61074}
    ...                            ${IGNORED_FAULT_4655}  ${IGNORED_FAULT_4654}  ${IGNORED_FAULT_4681}  ${IGNORED_FAULT_4590}  ${IGNORED_FAULT_4458}
${DSC}=                            ${FALSE}
@{REMOTE_TESTLINES_LIST}           @{EMPTY}  #list of aliases of remote testlines; to be defined using REMOTE_TESTLINES dictionary in
                                             #...  testline configuration file or json
#######hran_admin##################
${ADMIN_SNAPSHOT_TIMEOUT_MASTER}   1200  #timeout for collect snapshot via Admin from MSM (in sec)
${ADMIN_SNAPSHOT_TIMEOUT_ESM}      1500  #timeout for collect snapshot via Admin from ESM (in sec)
#######hran_general################
${DF LOG PATH}=                    ${OUTPUT DIR}/df.log
####### hran_infomodel ############
${dist_radio}=              //EQM_L-1//RMOD_L-*
${dist_smod}=               //EQM_L-1//SMOD_L-*
${dist_LTE_cell}=           /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/LNBTS_M-*/CELL_M-*
${dist_WCDMA_cell}=         /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-*
${dist_GSM_cell}=           /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/GNBTS_M-*/CELL_M-*
${dist_NR_cell}=            /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1/NRBTS_M-*/CELL_M-*
${dist_cells}=              /MRBTS-1/RAT-1//BBTOP_M-1/MRBTS_M-1//CELL_M-*
${dist_bts}=                /MRBTS-1/RAT-1/BTS_L-*/LNBTS-1
${dist_LTE_bts}=            /MRBTS-1/RAT-1//LNBTS-1
${dist_SW_version}=         /MRBTS-1/RAT-1//BTS_CONF-1
${dist_commissioning}=      /MRBTS-1/RAT-1//BTS_CONF-1/CONFIGURATION_FILE-1
${HW_LOCATION_CODE}               ${EMPTY}
${TESTLINE_NAME}                  ${EMPTY}
#${TEAM_PATH_TO_ROTTA}       VRF_TSR1/RAN_VRF_TSR_1_SG07/CRT
${TEAM_PATH_TO_ROTTA}       VRF_TSR/VRF_TSR_T05/TT/CRT/AP

*** Keyword ***
TAF Config Adapter
    @{configuration}=   Split String  ${CONFIGURATION}  .
    @{tl_params}=       Split String  ${configuration}[1]  _
    Set suite variable  ${HW_LOCATION_CODE}        ${configuration}[0]
    Set suite variable  ${TESTLINE_NAME}           ${tl_params}[0]_${tl_params}[1]_${tl_params}[2]
    Set suite variable  ${TEMP_LOGS_DIR}            /home/ute/btsauto/logs
    Import Library      hran_testline_configuration   ${HW_LOCATION_CODE}  ${TESTLINE_NAME}
    hran_testline_configuration.Set taf config variables


Common Test Setup
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
    ...  -> Starts BTSSM on all sites
    ...  -> Gets and displays SW versions
    ...  -> Checks cells and modules state and active alarms
    ...
    ...  | Parameter            | Default         | Description                                                         |
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
    ...  | ignored_alarms       | empty           | Possible to add FaultIDs (separated by comma) to default ignored alarms list |
    ...
    ...  | To run setup for DSC, variable ${DSC}=${True} should be visible in env_config or test parameters in json
    ...  | To run setup for remote testlines, dictionary REMOTE_TESTLINES has to be added to env_config, example entry:
    ...  | REMOTE_TESTLINES:
    ...  |   TESTLINE1:
    ...  |     PC_IP1: <ip_address_of_msm_host>
    ...  |     PC_IP2: <ip_address_of_esm_host>
    ...  |
    ...  | User can import global variables from file in common test setup; ${ADDITIONAL_VARIABLES_PATH} need to be included in json file

    [Timeout]    15 minutes
    [Arguments]  ${admin_launch}=${TRUE}       ${syslog_launch}=${TRUE}  ${infomodel_launch}=${TRUE}
    ...          ${modules_check}=${TRUE}  ${cells_check}=${TRUE}       ${alarms_check}=${TRUE}
    ...          ${expected_BTS_status}=OnAir  ${scf_check}=${TRUE}  ${ignored_alarms}=${EMPTY}

    Verify VM Time Zone

    Set Test Variable  ${scf_check}                ${scf_check}
    Set Test Variable  ${btssm_started}            ${FALSE}
    Set Test Variable  ${infomodel_started}        ${FALSE}
    Set Test Variable  ${SMOD1_syslog_started}     ${FALSE}
    Set Test Variable  ${SMOD2_syslog_started}     ${FALSE}
    Set Test Variable  ${admin_started}            ${FALSE}
    Set Test Variable  ${scf_parser_started}       ${FALSE}
    Set Test Variable  ${bts_verification_status}  norun
    Set Test Variable  ${ACTIVE_SW}

    #TAT-26884:
    @{LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}=    Create List
#    Set Test Variable  ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}

    ${additional_variables_exist}=  Run Keyword And Return Status  Variable Should Exist  ${ADDITIONAL_VARIABLES_PATH}
    Run Keyword If  ${additional_variables_exist}  Run Keyword And Ignore Error  Import Variables  ${ADDITIONAL_VARIABLES_PATH}

    ${taf_config_model}=  Run keyword and return status   Variable should exist  ${tl}
    Set test variable  ${TAF_CONFIG_MODEL}  ${taf_config_model}
    Run keyword if  ${TAF_CONFIG_MODEL}  Taf config adapter
    ...       ELSE
    ...       Run Keywords
    ...       Import Library      hran_testline_configuration   ${HW_LOCATION_CODE}  ${TESTLINE_NAME}  AND
    ...       hran_testline_configuration.Set Config Variables   @{TESTLINE_CONFIG_VARIABLES}
#    Run keyword unless  ${TAF_CONFIG_MODEL}  Clean VM disk space  Master
    Run keyword if    not ${TAF_CONFIG_MODEL}  Clean VM disk space  Master
    Check Local Host Disk Space

    Log  Common Test Setup  level=INFO  console=${True}
    Get Workspace Version
    Create Directories For Logs

    Log  TC executed with configuration files of ${HW_LOCATION_CODE}\\${TESTLINE_NAME}  level=INFO  console=${True}
    Set Tags  ${HW_LOCATION_CODE}\\${TESTLINE_NAME}

    ${ignored_alarms}=  Set Additional Ignored Alarms
    Set Test Variable  ${ADDITIONAL_IGNORED_ALARMS}  ${ignored_alarms}

    Set Raw Alarm History Connection Parameters
    Log Variables  level=DEBUG
    Run Keyword If  ${admin_launch}       Run Keyword And Continue On Failure  Start Admin
    ${bts_info}=  coam.Get Bts Info  connection=default
    Set Test Variable  ${bts_info}
    Run Keyword If  ${syslog_launch}      Run Keyword And Continue On Failure  Start syslog on SMOD1
    Run Keyword If  ${infomodel_launch}   Run Keyword And Continue On Failure  Start Infomodel

    Setup SMOD2    ${admin_started}  ${syslog_launch}

    Run Keyword If  ${infomodel_started}  Run Keyword And Continue On Failure  Print Active And Passive SW Version
    Run keyword If  ${admin_started} and ${scf_check}  Run keyword and continue on failure  Start scf Parser  UNIVERSAL
    Run keyword if  ${admin_started}
    ...  Verify BTS states  ${expected_BTS_status}  ${modules_check}  ${cells_check}  ${alarms_check}  ${ignored_alarms}
    ...        ELSE  Set Test Variable  ${bts_verification_status}  passed

    Run keyword if  ${DSC}  Run Keyword And Continue On Failure  Remote Test Line Setup  remote_host=${PC_IP2}  alias=DSC


    ${remote_testlines_configured}  ${remote_testlines_tmp}=  Run keyword and ignore error  Get dictionary keys  ${REMOTE_TESTLINES}
    ${REMOTE_TESTLINES_LIST}=  Run Keyword If  '${remote_testlines_configured}'=='PASS'  Set Variable  ${remote_testlines_tmp}
    ...  ELSE  Create List
    Set Test Variable  ${REMOTE_TESTLINES_LIST}
    FOR  ${remote_alias}  IN  @{REMOTE_TESTLINES_LIST}
        Verify Configuration And Set Up Remote Test Line  ${modules_check}  ${cells_check}  ${alarms_check}  ${remote_alias}
    END

    Log  End of Common Test Setup  level=INFO  console=${True}


Setup SMOD2
    [Arguments]  ${admin_started}  ${syslog_launch}
    ${smod2_variable_exists}=   Run keyword and return status  Variable Should Exist  ${SMOD2}
    ${pc_ip2_variable_exists}=  Run keyword and return status  Variable Should Exist  ${PC_IP2}
    ${smods_number}=  SCF Count Smod  ${COMMISSIONING_PATH}
    Run Keyword If  ${smods_number}<2  Run Keywords
    ...  Log  One SMOD or none PC_IP2 was declared in SCF  console=${True}
    ...  AND  Set test variable  ${SMOD2_exists}  ${FALSE}
    ...  AND  Return from keyword
    Run keyword if  '${smod2_variable_exists}'=='${False}' or '${pc_ip2_variable_exists}'=='${False}'    Run keywords
    ...  Log  One SMOD or none PC_IP2 was declared in config  console=${True}
    ...  AND  Set test variable  ${SMOD2_exists}  ${FALSE}
    ...  AND  Return from keyword
    Run keyword if  ${admin_started}  Check SMOD2 in Admin
    ...  ELSE  Run keywords
    ...  Log  Skip checking SMOD2 in Admin  console=${True}
    ...  AND  Set test variable  ${SMOD2_exists}  ${TRUE}

    Run keyword if  not ${TAF_CONFIG_MODEL}  Run keyword if  ${SMOD2_exists}  Clean VM disk space  Extension  host_ip=${PC_IP2}
    ...                                                                                            ssh_port=${22}  ssh_username=ute  ssh_password=ute
    Run keyword if    not ${TAF_CONFIG_MODEL}  Run keyword if  ${SMOD2_exists}  Check Remote Host Disk Space  /home/ute  2048  ${PC_IP2}
    ...                                                                                                     ${22}  ute  ute
    Run Keyword If  ${syslog_launch} and ${SMOD2_exists}  Run Keyword And Continue On Failure  Start syslog on SMOD2

Common Test Teardown L3
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
    ...  | failed_verdict                   | Snapshot is collected if the test verdict is failed or blocked |
    ...  | never                            | Snapshot is not collected |
    ...
    [Arguments]  ${collect_snapshot}=${COLLECT_SNAPSHOT_FLAG}    ${send_logs_to_rotta}=${SEND_LOGS_TO_ROTTA_FLAG}

    # this is to allow one to override `collect_snapshot` by providing it in a command line / JSON,
    # even if it is set in a TC (as in `Common Test Teardown    collect_snapshot=never`)
#    Report Configuration ID
    ${collect_snapshot}=    Set Variable If    '${COLLECT_SNAPSHOT_FLAG}' != 'failed_verdict'    ${COLLECT_SNAPSHOT_FLAG}    ${collect_snapshot}

    Log  Common Test Teardown  level=INFO  console=${True}

#    Wait Until Keyword Succeeds    6min    30s    coam.Assert alarm inactive    faultId=7300, severity=Major
#    Wait Until Keyword Succeeds    1min    30s    coam.Assert alarm inactive    faultId=7319, severity=Major

#    Run Keyword If  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
#    ...  Log  Initial verification of BTS states failed, state or alarm verification not succeeded  console=${True}
#
#    Run Keyword If  '${collect_snapshot}'=='never'  Log  Collecting Snapshot skipped on user demand!  console=${True}
#    ...  ELSE IF  '${collect_snapshot}'=='failed_verdict'  Run Keyword If Test Failed  Collect Snapshot And TRS
#    ...  ELSE IF  '${collect_snapshot}'=='always'  Collect Snapshot And TRS
#
#    Run keyword if  ${DSC}  Remote Test Line Teardown  alias=DSC  verify_states_stability=${True}
#    FOR  ${remote_line_alias}  IN  @{REMOTE_TESTLINES_LIST}
#        Remote Test Line Teardown  alias=${remote_line_alias}
#    END
#    Run Keyword If  ${infomodel_started}  Teardown Infomodel
#    Teardown All Aliases For Infomodel
#    Run Keyword If  ${admin_started}  Run Keywords  Admin Print Active Alarms  AND  Collect Infomodel Via Taf
#
#    ${post_alarms_status}  ${post_alarms_msg}=  Run Keyword And Ignore Error
#    ...  pm_logs_general.Check Unexpected Alarms  skip_fault=${ADDITIONAL_IGNORED_ALARMS}
#    Run keyword if  '${post_alarms_status}'=='FAIL'  Fail  Unexpected alarms found after test: ${post_alarms_msg}
#
#    Run Keyword And Ignore Error  coam.Teardown Admin
#    coam.Teardown All Aliases For Admin
#    Run Keyword And Ignore Error  coam.Teardown Admin  connection=default
#    coam.Teardown All Aliases For Admin
#    Collect Syslog
#    Run keyword If  ${scf_parser_started}  Teardown scf Parser
#    Collect Swconfigs
#    Collect RawAlarmHistory
#    Log    Move directory ssh_forwarder_log to ${BTS Files}
#    Run Keyword And Ignore Error  Move Directory  ${EXECDIR}/ssh_forwarder_log  ${BTS Files}
#
#    Run keyword if  'STOPONFAIL' in @{TEST TAGS} and '${TEST STATUS}' == 'FAIL'  Fatal error
#    ...  Execution stopped because critical TC '${TEST NAME}' failed
    Copy Logs To Rotta    ${send_logs_to_rotta}

    Log  End of Common Test Teardown  level=INFO  console=${True}

    #TAT-26884:
#    Run keyword if  ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}!='[]'    Remove All Directories After Unpack

Remove All Directories After Unpack
    [Documentation]
    ...  *AUTHOR* marcin.berkowski@nokia.com
    ...  This keyword is romoving all temporary directories created during unpacking files
    ...  from global list variable named: "LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK"
    ...  For more details please check in TAT-26884 https://jiradc.ext.net.nokia.com/browse/TAT-26884

    FOR  ${dir_to_del}  IN  @{LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}
      Run    rm -rf ${dir_to_del}
    END

Copy Logs To Rotta
    [Documentation]
    ...  | Parameter              | Default    | Description                                       |
    ...  | send_logs_to_rotta     | yes        | Flag for enabling/disabling sending logs to rotta |
    ...
    ...  | send_logs_to_rotta values           | Description
    ...  | yes                                 | logs will be send to rotta    |
    ...  | no                                  | logs will not be send to rotta|

    [Arguments]    ${send_logs_to_rotta}

    Run Keyword If  '${send_logs_to_rotta}'=='yes'  Run Keywords
    ...  Log  Copy Logs To Rotta  console=${True}
    ...  AND  Logs To Rotta Copy
    ...  ELSE IF  '${send_logs_to_rotta}'=='no'    Log  Sending logs to Rotta skipped on user demand!  console=${True}

Logs To Rotta Copy
    [Documentation]
    ...  The keyword checks whether the Rotta is mapped; if not, it will be connected.
    ...  Subsequently, two paths are created for the trunk and branch, and the keyword checks software release.
    ...  Finally, logs are copied to the Rotta.
    ...
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    ${rotta_available}    Run Keyword and Return Status    OperatingSystem.Directory Should Exist    /home/ute/Rotta
    ${rotta_directory_not_empty}    Run Keyword and Return Status    Directory Should Not Be Empty    /home/ute/Rotta

#    ${burak_available}    Run Keyword and Return Status    OperatingSystem.Directory Should Exist    /media/burak
#    ${burak_directory_not_empty}    Run Keyword and Return Status    Directory Should Not Be Empty    /media/burak

    Run Keyword If    ${rotta_available}==True and ${rotta_directory_not_empty}==True    Run Keyword
    ...    Log    rotta available
    ...    ELSE   Mount Rotta

#    Run Keyword If    ${burak_available}==True and ${burak_directory_not_empty}==True    Run Keyword
#    ...    Log    burak available
#    ...    ELSE   Mount Burak

    Set Test Variable    ${ACTIVE_SW}    ${bts_info['swInfo']['swVersion']}
    Set Test Variable    ${Case_NAME}    5G001756_all_tests
    Run Keyword and Ignore Error      Get mrbtsid from BTS
    ${testline_name}=    Get From Dictionary    ${BTS_Info}    name
    Set Test Variable    ${BTS_NAME}     ${testline_name}
    ${release1}    Fetch From Left  ${ACTIVE_SW}  _ENB
    ${release}     Fetch From Right  ${release1}  SBTS
    ${BR_path}     Set Variable   /home/ute/Rotta/MN_RAN/RAN_VRF/${release}/Regression/${TEAM_PATH_TO_ROTTA}
    ${TR_path}     Set Variable   /home/ute/Rotta/MN_RAN/RAN_VRF/Trunk/${TEAM_PATH_TO_ROTTA}
    ${Test Results Dir}    Set Variable    ${OUTPUT_DIR}

    ${check_if_trunk}    Run Keyword And Return Status    Should contain      ${ACTIVE_SW}    9999
    Run Keyword If    ${check_if_trunk}==True    Run Keyword
    ...    Set Test Variable    ${patch_copy_logs}    ${TR_path}
    ...    ELSE    Set Test Variable    ${patch_copy_logs}    ${BR_path}

    ${current_date}           DateTime.Get Current Date  time_zone=UTC  exclude_millis=True  result_format=%Y-%m-%d
    Run    mkdir -p ${patch_copy_logs}/${BTS_NAME}/${current_date}/${Case_NAME}
    Run    rsync -av --progress --mkpath ${Test Results Dir} ${patch_copy_logs}/${BTS_NAME}/${current_date}/${Case_NAME}/


Mount Rotta
    [Documentation]
    ...  KW Mount Rotta using technical pmlogs account
    ...
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com
    ...

    ${password}       Set Variable    Trbs07!@
    ${username}       Set Variable    tsr1logs
    ${global_p}       Set Variable    //nescrotta.nesc.nokia.net/rotta
    ${local_p}        Set Variable    /home/ute/Rotta
    ${domain}         Set Variable    NSN-INTRA

    Run    sudo mkdir -p /home/ute/Rotta
    Run  sudo mount -t cifs -o noperm,auto,rw,vers=3.0,username=${username},password=${password},domain=${domain},users,nounix ${global_p} ${local_p}

#Mount Burak
#    [Documentation]
#    ...  KW Mount burak
#    ...
#    ...  *AUTHOR*
#    ...  jakub.kokoszka@nokia.com
#    ...
#
#    ${password}       Set Variable    wro6pass
#    ${username}       Set Variable    sranwro6
#    ${global_p}       Set Variable    //burak2.intra.noklab.net/IAV_WCDMA
#    ${local_p}        Set Variable    /media/burak
#    ${domain}         Set Variable    noklab
#
#    Run    sudo mkdir /media/burak
#    Run  sudo mount -t cifs -o noperm,auto,rw,vers=3.0,username=${username},password=${password},domain=${domain},users,nounix ${global_p} ${local_p}

Start syslog on ${smod}
    Log    Trying to start syslog on ${smod}   level=INFO  console=${True}
    ${syslog_started}=  Run keyword and return status  Wait until keyword succeeds  5 min  15 sec
    ...  Restart syslog on ${smod}
    Set test variable  ${${smod}_syslog_started}  ${syslog_started}
    Run keyword if  ${${smod}_syslog_started}    Log    Syslog on ${smod} started  level=TRACE  console=${True}
    ...  ELSE  Log  Syslog on ${smod} did not start and will not be collected during TC execution  console=${True}

Restart syslog on SMOD1
    Run Keyword And Ignore Error  Kill Process By Name  btslog
    Run Keyword And Ignore Error  ute_syslog.Stop Syslog  alias=SMOD1
    ${file_limit}=  Get variable value  ${MAX_UDP_SIZE}  0
    ute_syslog.Start Syslog  alias=SMOD1  log_dir=${Temp Logs Dir}  log_name=SMOD1_UDP
    ...  ip=${SMOD1["UDP_IP"]}  ports=@{UDP ports}  file_limit=${file_limit}

Restart syslog on SMOD2
    Start remote syslog  remote_host=${PC_IP2}  udp_ip=${SMOD2["UDP_IP"]}  alias=SMOD2

Start remote syslog
    [Arguments]  ${remote_host}  ${udp_ip}  ${alias}
    Run Keyword And Ignore Error  Kill Process By Name  btslog  local=${FALSE}  host_ip=${remote_host}
    ...  ssh_port=22  ssh_username=ute  ssh_password=ute
    Run Keyword And Ignore Error  ute_syslog.Stop Syslog  alias=${alias}
    ${file_limit}=  Get variable value  ${MAX_UDP_SIZE}  0
    ${syslog_started}  Run keyword and return status  ute_syslog.Start Syslog  alias=${alias}
    ...  log_dir=${Temp Logs Dir}  log_name=${alias}_UDP  ip=${udp_ip}  ports=@{UDP ports}  host_ip=${remote_host}
    ...  file_limit=${file_limit}
    Set test variable  ${${alias}_syslog_started}  ${syslog_started}

Collect syslog
    Run keyword if  ${SMOD1_syslog_started}  Collect syslog from SMOD1
    Run keyword if  ${SMOD2_syslog_started}  Collect syslog from SMOD2

Collect syslog from ${alias}
    Log    ${alias} syslog will be terminated   level=INFO  console=${True}
    ${syslog_collected}=  Run keyword and return status  Collect syslog results  alias=${alias}
    ...  destination=${UDP Logs}/${alias}_UDP.tar.gz  unzip=false
    Run keyword if  ${syslog_collected}  Log  ${alias} syslog collected to 'UDP Logs'  level=INFO  console=${True}
    ...  ELSE  Log  ${alias} syslog collection failed  level=INFO  console=${True}

Start Infomodel
    [Arguments]  ${bts_host}=192.168.255.129
    Log    Trying to setup and connect to infomodel (max 5 min)   level=INFO  console=${True}
    ${infomodel_started}=  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  15 sec  _Single attempt to Start Infomodel  bts_host=${bts_host}
    Set Test Variable  ${infomodel_started}
    Run Keyword if  not ${infomodel_started}
    ...  Fail  Infomodel connection did not start
    Log    Connection to infomodel successfully established!  level=INFO  console=${True}

_Single attempt to Start Infomodel
    [Arguments]  ${bts_host}=192.168.255.129
    Log    Trying to setup infomodel    level=INFO  console=${True}
    Setup Infomodel  address=${bts_host}  port=443  timeout=90  use_ssl=True  admin_api_log_dir=${BTS Files}/
    Log    Trying to connect to infomodel    level=INFO  console=${True}
    ${infomodel_started}=  Run Keyword And Return Status  Connect Infomodel  timeout=90
    Run keyword if  not ${infomodel_started}  Run keywords  Teardown Infomodel    AND    Fail    Failed to start Infomodel

Collect Infomodel Via Taf
    Log    Collecting infomodel log   level=INFO  console=${True}
    coam.Collect Infomodel Log From Current Session  target_file_name=${BTS Files}/IM/InfoModel_log.ims2
    ...  timeout=300  connection=default
    Log    Infomodel log collected  level=INFO  console=${True}

Start Admin
    ${admin_taf_started}=  Run Keyword And Return Status  Setup Admin Connection
    Run Keyword If  ${admin_taf_started}   Set Test Variable  ${admin_started}  ${TRUE}


Start SCF Parser
    [Documentation]
    ...  Start SCFC Parser from library hran_file_operations with given parser technology.
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com
    ...
    ...  | Parameter    | Man. | Description                                          |
    ...  | parser_tech  | No   | Parser technology (UNIVERSAL, SBTS, WCDMA, LTE, GSM) |

    [Arguments]  ${parser_tech}=SBTS
    _Set SW_TYPE
    _Set COMMISSIONING_PATH
    Log  SCF which will be used to verify BTS (${COMMISSIONING_PATH})  console=${True}
    ${scf_parser_started}=  hran_file_operations.Setup SCFC Parser  ${COMMISSIONING_PATH}  parser_technology=${parser_tech}
    Set test variable   ${scf_parser_started}
    Run Keyword if  not ${scf_parser_started}
    ...  Fail  SCF Parser did not start

_Set SW_TYPE
    ${regex}=  Set variable  (?i)(wn\\d+_fl\\d+_gf\\d+_)?(?P<product>(SBTS|FL|WN|WBTS|FDSW|TL)[0-9]*)(?P<postfix>[a-zA-Z0-9\.]*)
    ${result}=  Get Regexp Matches  ${ACTIVE_SW_VERSION}  ${regex}  product  postfix
    ${product}  ${postfix}=  Set variable  ${result[0]}
    ${product}=  Convert To Uppercase  ${product}
    ${postfix}=  Convert To Uppercase  ${postfix}
    Set test variable  ${SW_TYPE}  ${product}${postfix}

_Set COMMISSIONING_PATH
    ${custom_scf_path}=  Get Variable Value  ${COMMISSIONING_PATH}  ${EMPTY}
    Return from keyword if  '${custom_scf_path}'!=''
    Run keyword if  ${TAF_CONFIG_MODEL}  Find SCF file in robotlte configs
    ...  ELSE  Find SCF file

Teardown SCF Parser
    Log    Teardown scf Parser   level=INFO  console=${True}
    hran_file_operations.Teardown SCFC Parser

Set Raw Alarm History Connection Parameters
    Log    Set Raw Alarm History Connection Parameters  level=INFO  console=${True}
    hran_file_operations.Rah Set Connection Parameters
    ...  target_path=/tmp/RawAlarmHistory.txt  target_ip=${SMOD1['IP']}  target_username=${SMOD1['USERNAME']}
    ...  target_password=${SMOD1['PASSWORD']}  destination_directory=${BTS Files}/

Find SCF file
    Log  Find SCF file  console=${True}
    ${COMMISSIONING_PATH}=  Get commissioning path  ${active SW version}
    Set test variable  ${COMMISSIONING_PATH}

Find SCF file in robotlte configs
    Log  Find SCF file in robotlte TAF configs  console=${True}

    ${commissionings_directory}=  Set Variable  /home/ute/robotlte/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/node1
    @{enb_build_split}=  Split String  ${ENB_BRANCH}  _
    Set test variable  ${COMMISSIONING_PATH}  ${commissionings_directory}/BTS_${tl.tl_cloud_topology}_${enb_build_split}[0].xml

Verify BTS states
    [Arguments]  ${expected_BTS_status}=OnAir  ${modules_check}=${TRUE}  ${cells_check}=${TRUE}  ${alarms_check}=${TRUE}  ${ignored_alarms}=${EMPTY}
    ...  ${BTS_state_is_correct}=${FALSE}  ${system_modules_working}=${FALSE}  ${radio_modules_working}=${FALSE}
    ...  ${cells_GSM_onair}=${FALSE}  ${cells_WCDMA_onair}=${FALSE}  ${cells_LTE_onair}=${FALSE}  ${cells_NR_onair}=${FALSE}  ${alarms_status}=FAIL
    ${BTS_state_is_correct}  ${BTS_current_status}=  Verify BTS proceduralState  ${expected_BTS_status}
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
    ${ALL_AVAILABLE_CELLS}=  Admin Get ids for all cells
    Set test variable  ${ALL_AVAILABLE_CELLS}

    Wait Until Keyword Succeeds    6min    30s    coam.Assert alarm inactive    faultId=7300, severity=Major
    Wait Until Keyword Succeeds    1min    30s    coam.Assert alarm inactive    faultId=7319, severity=Major

    ${alarms_status}  ${alarms_msg}=  Run Keyword If  ${alarms_check}  Run Keyword And Ignore Error
    ...  pm_logs_general.Check Unexpected Alarms  skip_fault=${ignored_alarms}
    Run keyword if  '${alarms_status}'=='FAIL'  Log  Unexpected alarms found before test: ${alarms_msg}  console=${True}

    ${statuses_dictionary}=  Create Dictionary  BTS_state_is_correct=${BTS_state_is_correct}
    ...  system_modules_working=${system_modules_working}  radio_modules_working=${radio_modules_working}
    ...  alds_working=${alds_working}  cells_GSM_onair=${cells_GSM_onair}  cells_WCDMA_onair=${cells_WCDMA_onair}
    ...  cells_LTE_onair=${cells_LTE_onair}  cells_NR_onair=${cells_NR_onair}  alarms_status=${alarms_status}
    ${pretty_statuses}=  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint

    [Teardown]

    ${cells_count_status}=  Run Keyword And Return Status  should be empty  ${ALL_AVAILABLE_CELLS}

    Run Keyword If  '${BTS_current_status}' == 'NotCommissioned' and ${cells_count_status} and ${BTS_state_is_correct} == ${FALSE}
    ...  Fail  Test failed due to BTS status: NotCommissioned. There are 0 configred cells.\nSkip to teardown!

    ${HW_states_and_alds}=  Set Variable If  ${BTS_state_is_correct} and ${system_modules_working} and ${radio_modules_working} and ${alds_working}
    ...  ${True}  ${False}
    ${Cells_states_and_alarms}=
    ...  Set Variable If  ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair} and ${cells_NR_onair} and '${alarms_status}'!='FAIL'
    ...  ${True}  ${False}
    Run Keyword If  ${HW_states_and_alds} and ${Cells_states_and_alarms}
    ...  Set Test Variable  ${bts_verification_status}  passed
    ...  ELSE  Fail  Test failed due to failure of BTS initial check:\n${pretty_statuses}.\n${alarms_msg}\nSkip to teardown!



Verify BTS proceduralState
    [Arguments]  ${expected_BTS_status}
    Log  Start BTS commissioning verification  console=${True}
    ${current_status}=  coam.Get Mrbts State  connection=default
    ${BTS_in_expected_status}=  Run keyword and return status  Should Match Regexp  ${current_status}  ${expected_BTS_status}
    Run keyword if  ${BTS_in_expected_status}  Log  BTS is in expected status (${current_status})!  console=${True}
    ...  ELSE  Log  BTS has state other than expected.  console=${True}
    [Return]  ${BTS_in_expected_status}  ${current_status}

Verify system modules states
    [Documentation]
    ...  Wrapper KW for checking SMOD product numbers against SCF and comparing SMOD states with states defined in
    ...  ${SMOD_expected_states} variable
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** ---

    Log  Start system modules verification  console=${True}
    Run keyword if  ${scf_parser_started}  Set SCF system modules count and verify product numbers
    Run keyword and return  Verify modules  SMOD  scf_check=${scf_parser_started}

Verify radio modules states
    [Documentation]
    ...  Wrapper KW for checking RMOD product numbers against SCF and comparing RMOD states with states defined in
    ...  ${RMOD_expected_states} variable
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** ---

    Log  Start radio modules verification  console=${True}
    Run keyword if  ${scf_parser_started}  Set SCF radio modules count and verify product numbers
    Run keyword and return  Verify modules  RMOD  scf_check=${scf_parser_started}

Verify ald states
    [Documentation]
    ...  Wrapper KW for comparing ALD states with states defined in ${ALD_expected_states} variable. Because of ticket
    ...  https://jiradc.int.net.nokia.com/browse/URW-5861, productCode checking is now omitted
    ...
    ...  | **Author:** patryk.furman@nokia.com
    ...  | **Maintainer:** patryk.furman@nokia.com
    ...  | **Released with version:** 50.3

    Log  Start ALD verification  console=${True}
    Run keyword and return  Verify modules  ALD  scf_check=${FALSE}

Verify ${technology} cells states
    [Documentation]
    ...  Wrapper KW for checking all RATs cells count against SCF and comparing cells states with states defined in
    ...  ${cells_LTE_expected_states}, ${cells_WCDMA_expected_states} and ${cells_GSM_expected_states} variables
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** ---

    Log  Start ${technology} cells verification  console=${True}
    Run keyword if  ${scf_parser_started}  Set SCF cells count  ${technology}
    Run keyword and return  Verify cells  ${technology}  scf_check=${scf_parser_started}


Print Active And Passive SW Version
    ${expected_SW_release}=  Set variable  [A-Z]+[0-9]{2}(?=[0-9A-Z]{0,2}?_[A-Z3-4]+_\\d{4}_\\d{6}_\\d{6})
    ${status}  ${sbts version}=  Run Keyword And Ignore Error  Should Match Regexp  ${bts_info['swInfo']['swVersion']}  ${expected_SW_release}

    Log    Active SW version (MSM): ${bts_info['swInfo']['swVersion']}    console=${TRUE}
    Set Test Variable    ${ACTIVE_SW}    ${bts_info['swInfo']['swVersion']}
    Set tags  MSM_SW_active-${bts_info['swInfo']['swVersion']}

    Run keyword if  not '${status}'=='PASS'  Fail  Software is not compatible with this frame (expected ${expected_SW_release})

    Set test variable  ${active SW version}    ${bts_info['swInfo']['swVersion']}
    Set test variable  ${sbts version}

Collect Swconfigs
    ${status}  ${result}=  Run Keyword And Ignore Error  Get File From System Module  source_path=/ffs/run/swconfig.txt
    ...                                                                               destination_path=${BTS Files}/
    Run Keyword If  '${status}'=='PASS'  Log  swconfig.txt from System module collected  console=${True}
    ...  ELSE  Run Keyword  Log  swconfig.txt could not be retrieved from System Module! Error: ${result}  console=${True}
    Run Keyword If  ${SMOD2_exists}  Get Swconfig From Extension

Get Swconfig From Extension
    ${status}  ${result}=  Run Keyword And Ignore Error  Get File From System Module  target_ip="192.168.255.7"  source_path=/ffs/run/swconfig.txt
    ...                                                                               destination_path=${BTS Files}/  via_ip=${PC_IP2}
    Run Keyword If  '${status}'=='PASS'  Run Keywords  Log  swconfig.txt from Extension module collected  console=${True}  AND  Return From Keyword
    ${status}  ${result}=  Run Keyword And Ignore Error  Get File From System Module  target_ip="192.168.255.1"  source_path=/ffs/run/swconfig.txt
    ...                                                                               destination_path=${BTS Files}/  via_ip=${PC_IP2}
    Run Keyword If  '${status}'=='PASS'  Run Keyword  Log  swconfig.txt from Extension module collected  console=${True}
    ...  ELSE  Run Keyword  Log  swconfig.txt could not be retrieved from Extension Module!  console=${True}

Collect RawAlarmHistory
    ${status}  ${result}=  Run Keyword And Ignore Error  Get File From System Module  source_path=/tmp/RawAlarmHistory.txt
    ...                                                                               destination_path=${BTS Files}/
    Run Keyword If  '${status}'=='PASS'  Log  RawAlarmHistory.txt from System module collected  console=${True}
    ...  ELSE  Run Keyword  Log  RawAlarmHistory.txt could not be retrieved from System Module! Error: ${result}  console=${True}

Set Additional Ignored Alarms
    [Documentation]
    ...  Keyword Adds Alarms definied as ADDITIONAL_IGNORED_ALARMS to default list of ignored alarms defined under
    ...  "pm_logs_general.Check Unexpected Alarms"
    ...  ADDITIONAL_IGNORED_ALARMS varaible need to be set as string (individual FaultId separated by comma)
    ...  ${ADDITIONAL_IGNORED_ALARMS}= 49,1780,1901
    ...
    ...  | **Author:** jacek.mnich@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${var_exists}  Run Keyword And Return Status  Variable should exist  ${ADDITIONAL_IGNORED_ALARMS}
    Return From Keyword If  not ${var_exists}  ${EMPTY}
    Log  Setting Additional Ignored Alarms:${ADDITIONAL_IGNORED_ALARMS}  console=${True}
    Return From Keyword If  ${var_exists}  ${ADDITIONAL_IGNORED_ALARMS}

Check SMOD2 in Admin
    [Documentation]
    ...  Tries to synchronize SMODs in Admin and set ${SMOD2_exists} variable to True
    ...
    ...  | **Full description:**
    ...  | Keyword tries to synchronize SMODs in Admin and sets True in ${SMOD2_exists} variable.
    ...  | In case SMODs cannot be synchronized TC verdict is set to Failed
    ...
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${smods}=    coam.Get Ids For All  SMOD  connection=default
    ${smod2_detected}=  Run keyword and return status  Run keyword if  len(${smods}) == 2
    ...  Set Variable  ${TRUE}
    ...  ELSE
    ...  Synchronize SMODs For Setup Purposes
    Run Keyword If  ${smod2_detected}  Run keywords
    ...  Log  Two SMODs were detected  console=${TRUE}
    ...  AND  Set test variable  ${SMOD2_exists}  ${TRUE}
    ...  ELSE  Fail  Extension System Module not detected despite declared in config file.

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
    [Arguments]  ${remote_host}  ${udp_ip1}=192.168.255.126  ${remote_host2}=${EMPTY}  ${udp_ip2}=192.168.255.126  ${alias}=remote
    ...  ${modules_check}=${TRUE}  ${cells_check}=${TRUE}  ${alarms_check}=${TRUE}
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
    Run Keyword If  ${${alias}_SMOD2_exists}  Start remote syslog  remote_host=${remote_host2}  udp_ip=${udp_ip2}  alias=${alias}_SMOD2
    Start remote Admin  remote_host=${remote_host}  alias=${alias}

    ${smod_expected_states}=  Get modules expected states  SMOD  alias=${alias}
    ${rmod_expected_states}=  Get modules expected states  RMOD  alias=${alias}
    ${sm_state}=  Run Keyword If  ${modules_check}  Verify modules  SMOD  alias=${alias}  scf_check=${FALSE}  expected_states=${smod_expected_states}
    ...  ELSE  Set Variable  ${TRUE}
    ${rf_state}=  Run Keyword If  ${modules_check}  Verify modules  RMOD  alias=${alias}  scf_check=${FALSE}  expected_states=${rmod_expected_states}
    ...  ELSE  Set Variable  ${TRUE}
    ${modules_working}=  Evaluate  ${sm_state} and ${rf_state}
    ${LTE_expected_states}=     Get cells expected states    LTE  alias=${alias}
    ${WCDMA_expected_states}=   Get cells expected states  WCDMA  alias=${alias}
    ${GSM_expected_states}=     Get cells expected states    GSM  alias=${alias}
    ${NR_expected_states}=     Get cells expected states    NR  alias=${alias}
    ${LTE_working}=    Run Keyword If  ${cells_check}  Verify cells  LTE    scf_check=${False}  alias=${alias}  expected_states=${LTE_expected_states}
    ...  ELSE  Set Variable  ${TRUE}
    ${WCDMA_working}=  Run Keyword If  ${cells_check}  Verify cells  WCDMA  scf_check=${False}  alias=${alias}
    ...                                                                     expected_states=${WCDMA_expected_states}
    ...  ELSE  Set Variable  ${TRUE}
    ${GSM_working}=    Run Keyword If  ${cells_check}  Verify cells  GSM    scf_check=${False}  alias=${alias}  expected_states=${GSM_expected_states}
    ...  ELSE  Set Variable  ${TRUE}
    ${NR_working}=      Run Keyword If  ${cells_check}  Verify cells  NR   scf_check=${False}  alias=${alias}  expected_states=${NR_expected_states}
    ...  ELSE  Set Variable  ${TRUE}
    ${alarms_status}  ${alarms_msg}=  Run Keyword If  ${alarms_check}  Run Keyword And Ignore Error
    ...               pm_logs_general.Check Unexpected Alarms  connection=${alias}
    ${statuses_dictionary}=  Create Dictionary  modules_working=${modules_working}  LTE_working=${LTE_working}
    ...  WCDMA_working=${WCDMA_working}  GSM_working=${GSM_working}  NR_working=${NR_working}  alarms_status=${alarms_status}
    ${pretty_statuses}=  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint
    Run keyword if  '${alarms_status}'=='FAIL'  Run Keywords
    ...  Log  Unexpected alarms are present on remote BTS (alias: ${alias})  console=${TRUE}
    ...  AND  Fail  Unexpected alarms are present on remote BTS (alias: ${alias})\n${alarms_msg}

    Start remote Infomodel  remote_host=${remote_host}  bts_host=192.168.255.129  alias=${alias}

    [Teardown]  Run Keyword If  ${modules_working} and ${LTE_working} and ${WCDMA_working} and ${GSM_working} and ${NR_working} and
    ...                         '${alarms_status}'!='FAIL'
    ...  Set Test Variable  ${${alias}_verification_status}  passed
    ...  ELSE  Fail  Test failed due to failure of ${alias} initial check:\n${pretty_statuses}.\nSkip to teardown!

Start remote Admin
    [Arguments]  ${remote_host}  ${alias}
    ${remote_taf_admin_started}=  Run keyword and return status
    ...  coam.Setup Admin  admin_api_log_dir=${BTS Files}  remote_host=${remote_host}  bts_host=192.168.255.129
    ...  bts_port=443  use_ssl=TRUE  update_interval=1000  name=${alias}
    ${remote_ute_admin_started}=  Run keyword and return status
    ...  coam.Setup Admin  admin_api_log_dir=${BTS Files}  remote_host=${remote_host}  bts_host=192.168.255.129
    ...  bts_port=443  use_ssl=TRUE  update_interval=1000  alias=${alias}
    Run Keyword If  ${remote_taf_admin_started} and ${remote_ute_admin_started}  Set Test Variable  ${${alias}_admin_started}  ${TRUE}

Start remote Infomodel
    [Arguments]  ${remote_host}  ${bts_host}  ${alias}
    Setup infomodel  alias=${alias}  remote_host=${remote_host}  address=${bts_host}  port=443  use_ssl=True  admin_api_log_dir=${BTS Files}/
    ${remote_infomodel_started}=  Run Keyword And Return Status  Connect Infomodel  alias=${alias}
    Set Test Variable  ${${alias}_infomodel_started}  ${remote_infomodel_started}

Remote Test Line Teardown
    [Arguments]  ${alias}  ${verify_states_stability}=${False}
    Log  Remote Test Line Teardown (alias: ${alias})  console=${True}
    ${ims_path}=  Set variable  ${BTS Files}/IM/${alias}.ims2
    Run keyword if  ${${alias}_admin_started}    coam.Collect Infomodel Log From Current Session  target_file_name=${ims_path}
    ...  timeout=300  connection=${alias}
    Run keyword if  ${${alias}_infomodel_started} and ${verify_states_stability} and '${${alias}_verification_status}'=='passed'
    ...     Verify Remote BTS States After Test Case  ims_path=${ims_path}  alias=${alias}
    Run keyword if  ${${alias}_infomodel_started}  Teardown Infomodel  alias=${alias}
    Run keyword if  ${${alias}_SMOD2_syslog_started}       Collect syslog from ${alias}_SMOD2
    Run keyword if  ${${alias}_syslog_started}       Collect syslog from ${alias}
    Run Keyword If  ${${alias}_admin_started}  Run Keywords
    ...  Run Keyword And Ignore Error  coam.Teardown Admin  connection=${alias}
    ...  AND  Run Keyword And Ignore Error  coam.Teardown Admin  alias=${alias}

Verify Remote BTS States After Test Case
    [Arguments]  ${ims_path}  ${alias}
    Log  Verify remote BTS states after test case (alias: ${alias})  console=${True}

    ${alarms_status}  ${alarms_msg}=  Run Keyword And Ignore Error  pm_logs_general.Check Unexpected Alarms  connection=${alias}
    Run keyword if  '${alarms_status}'=='FAIL'  Fail  Critical fail while checking alarms: ${alarms_msg}

    ${remote_SMODS}=    coam.Get Ids For All  SMOD  connection=${alias}
    ${remote_RMODS}=    coam.Get Ids For All  RMOD  connection=${alias}
    ${remote_CELLS_L}=  coam.Get Ids For All  LNCEL  connection=${alias}
    ${remote_CELLS_W}=  coam.Get Ids For All  WNCEL  connection=${alias}
    ${remote_CELLS_G}=  coam.Get Ids For All  GNCEL  connection=${alias}

    Initialize ims2 validator   ${ims_path}  alias=${alias}
    FOR  ${smod}  IN  @{remote_SMODS}
        Log  ${smod}
        Fail if ims2 object change Remote Trstline  ${smod}  administrativeState   Unlocked
        Fail if ims2 object change Remote Trstline  ${smod}  operationalState      Enabled
        Fail if ims2 object change Remote Trstline  ${smod}  availabilityStatus    Online
    END
    FOR  ${rmod}  IN  @{remote_RMODS}
        Log  ${rmod}
        Fail if ims2 object change Remote Trstline  ${rmod}  administrativeState   Unlocked
        Fail if ims2 object change Remote Trstline  ${rmod}  operationalState      Enabled
        Fail if ims2 object change Remote Trstline  ${rmod}  availabilityStatus    Online
        Fail if ims2 object change Remote Trstline  ${rmod}  blockingState         Unblocked
    END
    FOR  ${cell}  IN  @{remote_CELLS_L}
        Log  ${cell}
        Fail if ims2 object change Remote Trstline  ${cell}  administrativeState   Unlocked
        Fail if ims2 object change Remote Trstline  ${cell}  operationalState      Enabled
        Fail if ims2 object change Remote Trstline  ${cell}  availabilityStatus    Online
        Fail if ims2 object change Remote Trstline  ${cell}  blockingState         Unblocked
    END
    FOR  ${cell}  IN  @{remote_CELLS_W}
        Fail if ims2 object change Remote Trstline  ${cell}  operationalState      Enabled
        Fail if ims2 object change Remote Trstline  ${cell}  availabilityStatus    Online
        Fail if ims2 object change Remote Trstline  ${cell}  blockingState         Unblocked
        Fail if ims2 object change Remote Trstline  ${cell}  usageState            Active
    END
    FOR  ${cell}  IN  @{remote_CELLS_G}
        Fail if ims2 object change Remote Trstline  ${cell}  administrativeState   Unlocked
        Fail if ims2 object change Remote Trstline  ${cell}  operationalState      Enabled
        Fail if ims2 object change Remote Trstline  ${cell}  availabilityStatus    Online
        Fail if ims2 object change Remote Trstline  ${cell}  blockingState         Unblocked
        Fail if ims2 object change Remote Trstline  ${cell}  usageState            Active
    END
    Fail if ims2 event occur On Remote Testline   event=reset  alias=${alias}
    Fail if ims2 event occur On Remote Testline   event=create /MRBTS-*/RAT-*/FRI-*/ALARM-* [alarmSeverity=Critical]  alias=${alias}

Verify Configuration And Set Up Remote Test Line
    [Documentation]
    ...  Helper for KW Remote Test Line Setup which checks if selected test line is well configured
    ...  (exists in given dictionary and has the key "PC_IP1") and if it is, it starts setup
    [Arguments]  ${modules_check}  ${cells_check}  ${alarms_check}  ${alias}
    ${SMOD1_configured}  ${pc_ip1}=  Run keyword and ignore error  Get from dictionary  ${REMOTE_TESTLINES['${alias}']}  PC_IP1
    Run Keyword if  not '${SMOD1_configured}'=='PASS'  Run Keywords
    ...  Log  There is no PC_IP1 defined for ${alias} in REMOTE TESTLINES dict  console=${True}
    ...  AND  Return From Keyword

    ${udp_ip1_configured}  ${udp_ip1}=  Run keyword and ignore error  Get from dictionary  ${REMOTE_TESTLINES['${alias}']}  UDP_IP1
    ${udp_ip1}=  Set variable if  '${udp_ip1_configured}'=='PASS'  ${udp_ip1}  192.168.255.126

    ${SMOD2_configured}  ${pc_ip2}=  Run keyword and ignore error  Get from dictionary  ${REMOTE_TESTLINES['${alias}']}  PC_IP2
    ${pc_ip2}=  Set variable if  '${SMOD2_configured}'=='PASS'  ${pc_ip2}  ${EMPTY}

    ${udp_ip2_configured}  ${udp_ip2}=  Run keyword and ignore error  Get from dictionary  ${REMOTE_TESTLINES['${alias}']}  UDP_IP2
    ${udp_ip2}=  Set Variable If  '${udp_ip2_configured}'=='PASS'  ${udp_ip2}  192.168.255.126

    Remote Test Line Setup  modules_check=${modules_check}  cells_check=${cells_check}  alarms_check=${alarms_check}  remote_host=${pc_ip1}
    ...                     udp_ip1=${udp_ip1}  remote_host2=${pc_ip2}  udp_ip2=${udp_ip2}  alias=${alias}

Collect Snapshot From Remote Test Lines
    FOR  ${remote_line_alias}  IN  @{REMOTE_TESTLINES_LIST}
        Verify Configuration And Get Snapshot From Remote Test Line  ${remote_line_alias}
    END

Verify Configuration And Get Snapshot From Remote Test Line
    [Documentation]
    ...  Helper for KW Remote Testline Snapshot which checks if selected test line is well configured
    ...  (exists in given dictionary and has the key "PC_IP1") and if it is, it starts this KW
    [Arguments]  ${alias}
    Run Keyword And Ignore Error  _Collect Snapshot Via Admin API   timeout=${ADMIN_SNAPSHOT_TIMEOUT_MASTER}  alias=${alias}
    ${SMOD2_configured}  ${pc_ip2}=  Run keyword and ignore error  Get from dictionary  ${REMOTE_TESTLINES['${alias}']}  PC_IP2
    Run Keyword if  not '${SMOD2_configured}'=='PASS'  Return From Keyword
    Collect Snapshot Remotely Via Admin API  bts_host=192.168.255.119  remote_host=${pc_ip2}  snapshot_timeout=${ADMIN_SNAPSHOT_TIMEOUT_ESM}
    ...                                      alias=${alias}_SMOD2

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
    ...  |     "parameters":{ "cells_LTE_expected_states": "administrativeState = Unlocked, operationalState = Enabled, availabilityStatus = Degraded,
    ...  |                                                  blockingState = Unblocked",
    ...  |                    "cells_NR_expected_states":  "administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online,
    ...  |                                                  blockingState=Unblocked",
    ...  |                    "cells_WCDMA_expected_states": "operationalState = Enabled, availabilityStatus = Degraded, blockingState = Unblocked,
    ...  |                                                    usageState = Active",
    ...  |                    "cells_GSM_expected_states": "administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Degraded,
    ...  |                                                  blockingState=Unblocked, usageState=Active",
    ...  |                    "DSC_cells_LTE_expected_states": "administrativeState = Unlocked, operationalState = Enabled,
    ...  |                                                      availabilityStatus = Online, blockingState = Unblocked",
    ...  |                    "DSC_cells_WCDMA_expected_states": "operationalState = Enabled, availabilityStatus = Online, blockingState = Unblocked,
    ...  |                                                        usageState = Active",
    ...  |                    "DSC_cells_GSM_expected_states": "administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online,
    ...  |                                                      blockingState=Unblocked, usageState=Active"
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
    ${variable_exist}=  Run keyword and Return status   Variable should exist  ${${alias}_cells_${technology}_expected_states}
    Run keyword if  ${variable_exist}  Return from keyword  ${${alias}_cells_${technology}_expected_states}
    ...       ELSE  Return from keyword  ${cells_${technology}_expected_states}

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
    ...  |     "parameters":{ "cells_LTE_expected_states": "administrativeState = Unlocked, operationalState = Enabled, availabilityStatus = Degraded,
    ...  |                                                  blockingState = Unblocked",
    ...  |                    "cells_NR_expected_states":  "administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online,
    ...  |                                                  blockingState=Unblocked",
    ...  |                    "cells_WCDMA_expected_states": "operationalState = Enabled, availabilityStatus = Degraded, blockingState = Unblocked,
    ...  |                                                    usageState = Active",
    ...  |                    "cells_GSM_expected_states": "administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Degraded,
    ...  |                                                  blockingState=Unblocked, usageState=Active",
    ...  |                    "DSC_SMOD_expected_states": "administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online,
    ...  "                                                 blockingState=Unblocked, usageState=Active"
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
    ...  If `scf_check` is set to True, the number of modules will be compared with the number of respective objects in SCF.
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ...  source: hran_admin
    ...  | Parameter       | Mandatory | Description                                                                            |
    ...  | class_name       | Yes       | Class name for which states should be checked [SMOD, RMOD]                              |
    ...  | expected_states | No        | Expected states as string, e.g., "administrativeState=Unlocked, operationalState=Enabled" |
    ...

    [Arguments]  ${class_name}  ${expected_states}=${${class_name}_expected_states}  ${alias}=default  ${scf_check}=${TRUE}
    ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=  Get objects with expected states  ${expected_states}  ${class_name}  alias=${alias}

    Run keyword if  '${check_status}'=='FAIL'  Run keywords  Log  At least one ${class_name} module has state other than expected.  console=${TRUE}
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
    ...  source: hran_admin
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ...
    ...  | Parameter       | Mandatory | Description                                                                            |
    ...  | technology      | Yes       | Cell ID for which states should be checked [SMOD, RMOD]                              |
    ...  | expected_states | No        | Expected states as string ex. "administrativeState=Unlocked, operationalState=Enabled" |
    ...
    ...  Return
    ...  False if at least one cell has state other than expected, or cells count in scf is not equal runtime cells
    ...
    [Arguments]  ${technology}  ${expected_states}=${cells_${technology}_expected_states}  ${alias}=default  ${scf_check}=${TRUE}
    ${technology_sign}=  Run keyword if  '${technology}'=='NR'
    ...  Set variable  NR
    ...  ELSE
    ...  Set variable  ${technology[0]}N
    ${check_status}  ${RUNTIME_CELLS}  ${ALL_CELLS}=  Get objects with expected states  ${expected_states}  ${technology_sign}CEL  alias=${alias}

    Run keyword if  '${check_status}'=='FAIL'  Run keywords  Log  At least one ${technology} cell has state other than expected.  console=${TRUE}
    ...  AND  Return from keyword  ${FALSE}

    ${count_status}=  Run keyword if  ${scf_check}  Check SCF count  ${technology}  ${ALL_CELLS}
    ...  ELSE  Set variable  ${TRUE}

    Run keyword if  ${count_status}  Log  All ${technology} cells are in expected state.  console=${TRUE}
    ...  ELSE
    ...  Log  All ${technology} cells are in expected state but the number of cells defined in SCF differs from reported by AdminAPI.  console=${TRUE}

    [Return]  ${count_status}

Get objects with expected states
    [Documentation]
    ...  Get objects from ADMIN and ensure their states
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** iuliia.taupeka@nokia.com
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
    ...  +-----------------+------+--------------------------------------------------------------------------------------------------------+
    ...  | Parameter name  | Man. | Description                                                                                            |
    ...  +=================+======+========================================================================================================+
    ...  | expected states | yes  | Comma separated states with their valies (i.e administrativeState=Unlocked, operationalState=Enabled)  |
    ...  +-----------------+------+--------------------------------------------------------------------------------------------------------+
    ...  | class_name      | yes  | ADMIN object class name (BTS, SMOD, BBU, RMOD, ALD, LNCEL, GNCEL or WNCEL)                             |
    ...  +-----------------+------+--------------------------------------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=  Get objects with expected states  operationalState=Enabled, availabilityStatus=Online  ALD

    [Arguments]  ${expected states}  ${class name}  ${alias}=default
    ${class_ids}=  coam.Get Ids For All  ${class name}  connection=${alias}
    ${matching_objects}=  Create list
    ${matching_statuses}=  Create list
    FOR  ${item_id}  IN  @{class_ids}
        ${status}  ${item_parameters}=
        ...  Run keyword and ignore error  Check object expected states  ${class name}  ${item_id}  ${expected states}  timeout=40  alias=${alias}
        Run keyword if  '${status}'=='PASS'  Run keywords
        ...  Append to list  ${matching_objects}  ${item_parameters}  AND  Append to list  ${matching_statuses}  PASS
        ${iot_cell}=  Run keyword and return status  Should match regexp  ${item_id}  .*BTS_CONF.*SCF.*LNCEL
        Run keyword if  "${status}"=="FAIL" and ${iot_cell}  Append to list  ${matching_statuses}  PASS
        ${status}  ${item_parameters}=  Run keyword if  "${status}"=="FAIL" and not ${iot_cell}
        ...  Run keyword and ignore error  coam.Assert  ${class name}  ${item_id}  availabilityStatus=regex"(?i)Not.?Installed"
        ...  timeout=20  connection=${alias}
        ...  ELSE  Create list  PASS  NONE
        Run keyword if  "${status}"=="FAIL" and not ${iot_cell}  Append to list  ${matching_statuses}  FAIL
    END
    ${status}=  evaluate  "FAIL" if len(${class_ids})!=0 and "FAIL" in "${matching_statuses}" else "PASS"
    [Return]  ${status}  ${matching_objects}  ${class_ids}

Assert parameters for any
    [Arguments]  ${class_name}  ${expected_states}  ${alias}=default
    Should not be empty  ${expected_states}
    ${item_ids}  Get ids for all  ${class_name}
    FOR  ${item_id}  IN  @{item_ids}
        ${check_status}  Run keyword and return status  Check object expected states  ${class_name}  ${item_id}  ${expected_states}  alias=${alias}
        Return from keyword if  ${check_status}
    END
    Fail  No one item has expected states!

Assert parameters for every
    [Arguments]  ${class_name}  ${expected_states}  ${alias}=default
    Should not be empty  ${expected_states}
    ${item_ids}  coam.Get ids for all  ${class_name}  connection=${alias}
    FOR  ${item_id}  IN  @{item_ids}
        ${check_status}  Run keyword and return status  Check object expected states  ${class_name}  ${item_id}  ${expected_states}  alias=${alias}
        Run keyword if  not ${check_status}  Fail  At least one item has states other than expected!
    END

Assert parameters for no
    [Arguments]  ${class_name}  ${expected_states}  ${alias}=default
    Should not be empty  ${expected_states}
    ${item_ids}  coam.Get ids for all  ${class_name}  connection=${alias}
    FOR  ${item_id}  IN  @{item_ids}
        ${check_status}  Run keyword and return status  Check object expected states  ${class_name}  ${item_id}  ${expected_states}  alias=${alias}
        Run keyword if  ${check_status}  Fail  At least one item has expected states!
    END

Check object expected states
    [Arguments]  ${class name}  ${item_id}  ${expected states}  ${timeout}=30  ${alias}=default
    ${expected states}  Split string  ${expected states}  ,${SPACE}
    ${parameters}  coam.Get parameters for  ${class name}  ${item_id}  timeout=${timeout}  connection=${alias}
    FOR  ${state}  IN  @{expected states}
        ${stateName}  ${stateValue}  Split string  ${state}  =
        ${no_state_in_parameters}  Run keyword and return status  Dictionary should not contain key  ${parameters}  ${stateName}
        ${is_online}  Run keyword and return status  Should contain  ${stateValue}  nline
        Continue for loop if  ${no_state_in_parameters} and '${stateName}'=='availabilityStatus' and ${is_online}
        Run keyword if  ${no_state_in_parameters}  Fail  'Parameter "${stateName}" not present. Please check parameter name.'
        ${assert_status}  ${assert_output}  Run keyword and ignore error  coam.Assert  ${class name}  ${item_id}  ${state}
        ...  timeout=${timeout}  connection=${alias}
        Run keyword if  '${assert_status}'=='FAIL'  Fail  ${assert_output}
    END
    [Return]  ${parameters}

Set SCF system modules count and verify product numbers
    [Documentation]
    ...  Keyword for checking system modules amount and validating its runtime product numbers against these in SCF
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  source: hran_general.robot

    ${scf_smods}=  hran_file_operations.Get System Modules
    ${SCF_COUNT_SMOD}=  Get length  ${scf_smods}
    Set test variable  ${SCF_COUNT_SMOD}
    Set test variable  ${scf_smods}

    ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=  Get objects with expected states  ${SMOD_expected_states}  SMOD
    Run keyword if  '${check_status}'=='PASS'
    ...  Validate Runtime Modules Product Numbers Against SCF  ${RUNTIME_MODS}  ${scf_smods}

Set SCF radio modules count and verify product numbers
    [Documentation]
    ...  Keyword for checking radio modules amount and validating its runtime product numbers against these in SCF
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com

    ${scf_rmods}=  hran_file_operations.Get Radios
    ${SCF_COUNT_RMOD}=  Get length  ${scf_rmods}
    Set test variable  ${SCF_COUNT_RMOD}

    ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=  Get objects with expected states  ${RMOD_expected_states}  RMOD
    Run keyword if  '${check_status}'=='PASS'
    ...  Validate Runtime Modules Product Numbers Against SCF  ${RUNTIME_MODS}  ${scf_rmods}




Collect Snapshot And TRS
    Collect Local Snapshot
    Run keyword if  ${SMOD2_exists}  Collect Local Snapshot for ESM
    Collect TRS Extended Logs
    Collect Snapshot From Remote Test Lines

Fail if ims2 event occur On Remote Testline
    [Documentation]
    ...  Validate and fail if event occured
    ...  | **Author:** sebastian.burniak@nokia.com
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+----------------------------+
    ...  | Parameter name   | Man. | Description                |
    ...  +==================+======+============================+
    ...  | event            | yes  | ims2 event to be validated |
    ...  +------------------+------+----------------------------+
    ...  | alias            | no   | ute_admin_infomodel alias  |
    ...  +------------------+------+----------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Initialize ims2 validator    ${BTS Files}/IM/InfoModel_log.ims2  alias=${alias}
    ...     Fail if ims2 event occur On Remote Testline  ${alias}
    ...
    [Arguments]  ${event}  ${alias}=DSC
    Add expected ims2 event  ${event}  alias=${alias}
    ${event_triggered}=  Run keyword and return status  Validate ims2  alias=${alias}
    Run keyword if  ${event_triggered}   Fail  DSC: ${event} event has been found

Fail if ims2 object change Remote Trstline
    [Documentation]
    ...  Validate if object parameter in IMS2 was not changed
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+---------------------------+
    ...  | Parameter name   | Man. | Description               |
    ...  +==================+======+===========================+
    ...  | object           | yes  | object distname           |
    ...  +------------------+------+---------------------------+
    ...  | parameter        | yes  | object parameter          |
    ...  +------------------+------+---------------------------+
    ...  | value            | yes  | parameter value           |
    ...  +------------------+------+---------------------------+
    ...  | alias            | no   | ute_admin_infomodel alias |
    ...  +------------------+------+---------------------------+
    ...  **Example of simple usage:**
    ...  .. code-block:: robotframework
    ...
    ...     Initialize ims2 validator   ${BTS Files}/IM/${alias}.ims2  alias=${alias}
    ...     Fail if ims2 object change Remote Trstline  ${SMOD_DISTNAME}  administrativeState   Unlocked  ${alias}
    ...
    [Arguments]  ${object}  ${parameter}  ${value}  ${alias}=DSC
    Add expected ims2 event     change ${object} [stateInfo.${parameter}: ${value}->!${value}]  alias=${alias}
    ${status}  Run keyword and return status  Validate ims2  alias=${alias}
    Run keyword if  ${status}  Fail  DSC: ${object} state was changed (${parameter}!=${value})

Collect Local Snapshot
    [Documentation]
    ...    Try to collect snapshot from WebEM via taf library "Collect Snapshot". If this operation does not succeed, as a workaround
    ...    snapshot is taken using library taf.transport.ssh (using local command to getting snapshot from system module directly).
    ...
    ...  | Parameter              | Man.  | Default                              | Description                             |
    ...  | snapshot_timeout       | No    | ${ADMIN_SNAPSHOT_TIMEOUT_MASTER}     | timeout for collect snapshot via Admin   |
    ...    KW comes from hran_admin.robot
    ...    *AUTHOR*
    ...    andrzej.cichon@nokia.com
    ...    *MAINTAINER*
    ...    iuliia.taupeka@nokia.com
    [Arguments]  ${snapshot_timeout}=${ADMIN_SNAPSHOT_TIMEOUT_MASTER}
    Log    Collecting snapshot.    console=${True}
    ${snapshot_collected}=    Run Keyword And Return Status    _Collect Snapshot Via Admin API  ${snapshot_timeout}
    Run Keyword If    ${snapshot_collected}    Run Keywords
    ...    Log    Snapshot collected via admin api!    console=${True}
    ...    AND    Return From Keyword
    ${snapshot_collected}=    Run Keyword And Return Status    _Collect Snapshot Via SSH From MSM

    Run Keyword If    ${snapshot_collected}    Run Keywords
    ...    Log    Snapshot collected via SSH!    console=${True}
    ...    AND    Return From Keyword

    Log    Snapshot not collected!    console=${True}

Collect Local Snapshot for ESM
    [Documentation]
    ...    Try to collect snapshot for ESM via taf library 'Collect Snapshot'. If this operation does not succeed, as a workaround
    ...    snapshot is taken using taf.transport.ssh .
    ...
    ...  | Parameter              | Man.  | Default                              | Description                              |
    ...  | snapshot_timeout       | No    | ${ADMIN_SNAPSHOT_TIMEOUT_ESM}        | timeout for collect snapshot via Admin   |
    ...
    ...    *AUTHOR*
    ...    alona.kulieshova@nokia.com
    Log    Collecting snapshot.    console=${True}

    ${snapshot_collected}=    Run Keyword And Return Status    _Collect ESM Snapshot Via Admin API
    Run Keyword If    ${snapshot_collected}    Run Keywords
    ...    Log    ESM snapshot collected!    console=${True}
    ...    AND    Return From Keyword

    ${snapshot_collected}=    Run Keyword And Return Status    _Collect Snapshot Via SSH From ESM
    Run Keyword If    ${snapshot_collected}    Run Keywords
    ...    Log    Snapshot from ESM Via SSH collected!    console=${True}
    ...    AND    Return From Keyword

    Log    ESM snapshot not collected!    console=${True}

_Collect ESM Snapshot Via Admin API
    Log    Trying to collect snapshot for ESM via Admin API    console=${True}
    ${snapshot_collected}=    Run Keyword And Return Status    _Helper For ESM Snapshot Via Admin API  bts_host=192.168.255.119
    Return From Keyword If  ${snapshot_collected}
    ${snapshot_collected}=    Run Keyword And Return Status  _Helper For ESM Snapshot Via Admin API  bts_host=192.168.255.129
    Should Be True  ${snapshot_collected}  Failed to collect snapshot for ESM via Admin API

_Helper For ESM Snapshot Via Admin API
    [Arguments]     ${bts_host}
    Collect Snapshot Remotely Via Admin API  bts_host=${bts_host}  remote_host=${PC_IP2}
    ...  snapshot_timeout=${ADMIN_SNAPSHOT_TIMEOUT_ESM}  alias=ESM

Collect Snapshot Remotely Via Admin API
    [Arguments]    ${bts_host}  ${remote_host}  ${snapshot_timeout}  ${alias}
    Run Keyword And Ignore Error  coam.Setup Admin  admin_api_log_dir=${BTS Files}  bts_host=${bts_host}  remote_host=${remote_host}  name=${alias}
    _Collect Snapshot Via Admin API   timeout=${snapshot_timeout}  alias=${alias}
    coam.Teardown Admin  connection=${alias}

_Collect Snapshot Via Admin API
    [Arguments]  ${timeout}=600  ${alias}=default
    Log    Trying to collect snapshot via Admin API (alias: ${alias})    console=${True}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}_${month}_${day}_${hour}_${min}
    ${suffix_dict}    Create Dictionary  ${alias}=snapshot_${alias}.zip    default=snapshot.zip
    ${suffix}=    Get From Dictionary    ${suffix_dict}    ${alias}
    ${target_file_name}=    Set Variable    ${BTS Files}/${timestamp}_${suffix}
    coam.Collect Snapshot    target_file_name=${target_file_name}  timeout=${timeout}  connection=${alias}

_Collect Snapshot Via SSH From ESM
    [Documentation]
    ...  KW triggers snapshot collection from ESM via SSH connection.
    ...  Copy full collected esm_snapshot.zip to desired destination under 'local_file_path'
    ...  At the end archived snapshot is removed from esm
    ...
    [Arguments]  ${esm_ip}=${SMOD2['IP']}  ${user}=${SMOD2['USERNAME']}  ${pass}=${SMOD2['PASSWORD']}  ${local_file_path}=${BTS Files}
    ...  ${remote_ip}=${PC_IP2}  ${remote_user}=ute  ${remote_pass}=ute
    Log  Trying to collect ESM snapshot via ssh  console=${TRUE}
    ssh.Connect To  hostname=${remote_ip}  username=${remote_user}  password=${remote_pass}  alias=slave_vm
    ssh.Connect To  hostname=${esm_ip}  username=${user}  password=${pass}  proxy=slave_vm
    ssh.Execute  nc localhost 15007 <<< "log -a -z /ffs/run/esm_snapshot.zip" 2>/dev/null
    ssh.Download File  /ffs/run/esm_snapshot_ssh.zip  ${local_file_path}/esm_snapshot.zip
    ssh.Execute  rm /ffs/run/esm_snapshot_ssh.zip
    [Teardown]  Run Keywords  ssh.Disconnect  AND  ssh.Disconnect  connection=slave_vm

_Collect Snapshot Via SSH From MSM
    [Documentation]
    ...  KW triggers snapshot collction from master system module via SSH directly.
    ...  Copy full log to desired destination under 'local_file_path'
    ...  At the end zipped Snapshot is removed from sm
    [Arguments]  ${msm_ip}=${SMOD1['IP']}  ${user}=${SMOD1['USERNAME']}  ${pass}=${SMOD1['PASSWORD']}  ${local_file_path}=${BTS Files}
    Log  Trying to collect MSM snapshot via ssh  console=${TRUE}
    ssh.Connect To  hostname=${msm_ip}  username=${user}  password=${pass}
    ssh.Execute  nc localhost 15007 <<< "log -a -z /ffs/run/msm_snapshot.zip" 2>/dev/null
    ssh.Download File  /ffs/run/msm_snapshot_ssh.zip  ${local_file_path}/msm_snapshot.zip
    ssh.Execute  rm /ffs/run/msm_snapshot.zip
    [Teardown]  ssh.Disconnect

Collect TRS Extended Logs
    [Documentation]
    ...  KW collects TRS extended logs using ssh from SMOD.
    ...
    ...  *AUTHOR*  daniel.bartkowiak@nokia.com
    ...
    Log  Collecting extended TRS logs  console=${TRUE}
    ${trs_logs_collected}=  Run Keyword And Return Status  Run Keywords
    ...  ssh.Connect To  hostname=${SMOD1['IP']}  username=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
    ...  AND
    ...  ssh.Execute  /opt/trs/etc/collect_tech_logs.sh --filename\=/ffs/run/logs/TRSExtendedLogs.tar.xz
    ...  AND
    ...  ssh.Download File  /ffs/run/logs/TRSExtendedLogs.tar.xz  ${BTS Files}/TRSExtendedLogs.tar.xz
    Run Keyword If  ${trs_logs_collected}  Run Keywords
    ...  Log  Extended TRS logs collected  console=${TRUE}
    ...  AND
    ...  Return From Keyword
    Log  Extended TRS logs not collected!  console=${TRUE}
    [Teardown]  ssh.Disconnect



_SSHLibrary_Login_multiway
    [Arguments]  ${username}  ${password}
    ${status}=  Run keyword and return status  SSHLibrary.Login  ${username}  ${password}
    Return from keyword if  ${status}
    ${status}=  Run keyword and return status  SSHLibrary.Login with public key  ${username}
    ...  /home/${username}/.ssh/id_rsa
    Run keyword if  not ${status}  Fail  Remote connection unavailable

Kill processes remained after files deletion on VMs /home partition
    [Documentation]
    ...  Get all processes which are listed in Linux command
    ...  'lsof | grep -P '/home(?!.*(chrome|remote-stderr|remote-stdout)).*deleted'' and kill them.
    ...  Command can be run locally or remotely (after giving configuration details).
    ...  Command ommits Chrome processes to let the browser remain untouched, and also processes related to RemoteSwingLibrary.
    ...  Looping is used to provide introspection into which process caused the problem (ps stdout is logged).
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  | Parameter     | Man. | Description                                                                    |
    ...  | alias         | No   | Alias (Master or local in case of local machine or other in case of remote one |
    ...  | configuration | No   | KW arguments consisting with host_ip, ssh_port, ssh_username and ssh_password  |
    ...
    ...  *EXAMPLE*
    ...  | Kill processes remained after files deletion on VMs /home partition | Master |
    ...  | Kill processes remained after files deletion on VMs /home partition | Extension |
    ...  | ...  host_ip=10.42.35.151 | ssh_port=22 | ssh_username=ute | ssh_password=ute |

    [Arguments]  ${alias}=local  &{configuration}
    Log  Kill processes remained after files deletion on /home partition  console=${TRUE}
    ${pids_cmd}=  Set Variable  lsof | grep -P '/home(?!.*(chrome|remote-stderr|remote-stdout)).*deleted' | awk '!seen[$2]++ {print $2}'
    ${pids_str}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command And Return Output  ${pids_cmd}  ELSE
    ...  Execute Remote Command And Return Output  ${pids_cmd}  ${alias}  &{configuration}
    @{pids}=  Split String  ${pids_str}
    ${looped_ps_cmd}=  Create Dictionary  cmd=ps -o comm= -p  args=@{pids}
    Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command In Loop  ${looped_ps_cmd}  ELSE
    ...  Execute Remote Command In Loop  ${looped_ps_cmd}  ${alias}  &{configuration}
    ${looped_kill_cmd}=  Create Dictionary  cmd=kill -9  args=@{pids}
    ${rc}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command In Loop  ${looped_kill_cmd}  ELSE
    ...  Execute Remote Command In Loop  ${looped_kill_cmd}  ${alias}  &{configuration}
    Run keyword if  ${rc}==${0}
    ...  Log  All processes remained after files deletion have been killed  console=${TRUE}  ELSE
    ...  Log  Failed to kill processes remained after files deletion        console=${TRUE}

#####VM MODULE#####
Clean VM disk space
    [Documentation]
    ...  Wrapper function for KW used for VM cleaning. Cleaning will be perfomrmed on /tmp and ${Temp Logs Dir}. Also
    ...  processes remaining after files deletion would be killed.
    ...  (hran_frame_sbts)
    ...  ${aliast}  possible values are 'Master' or 'Extension'
    [Arguments]  ${alias}  &{configuration}
    Run keyword if  '${alias}'=='local' or '${alias}'=='Master'  Run keywords
    ...  Clean up directory  /tmp    720  ${alias}
    ...  AND
    ...  Clean up directory  /home/ute/btsauto/logs  240  ${alias}
    ...  AND
    ...  Kill processes remained after files deletion on VMs /home partition  ${alias}
    ...  ELSE  Run Keywords
    ...  Clean up directory  /tmp    720  ${alias}  host_ip=${configuration["host_ip"]}      ssh_port=${configuration["ssh_port"]}
    ...                                                                                      ssh_username=${configuration["ssh_username"]}
    ...                                                                                      ssh_password=${configuration["ssh_password"]}
    ...  AND
    ...  Clean up directory  /home/ute/btsauto/logs  240  ${alias}  host_ip=${configuration["host_ip"]}  ssh_port=${configuration["ssh_port"]}
    ...                                                                                             ssh_username=${configuration["ssh_username"]}
    ...                                                                                             ssh_password=${configuration["ssh_password"]}
    ...  AND
    ...  Kill processes remained after files deletion on VMs /home partition  ${alias}  host_ip=${configuration["host_ip"]}
    ...                                                                                 ssh_port=${configuration["ssh_port"]}
    ...                                                                                 ssh_username=${configuration["ssh_username"]}
    ...                                                                                 ssh_password=${configuration["ssh_password"]}

Clean up directory
    [Arguments]  ${clean_directory}  ${older_than_min}  ${alias}=local  &{configuration}
    [Documentation]
    ...  Cleaning up directory given in arguments (KW from hran_general.robot)
    Log  Removing files older than ${older_than_min} min from "${clean_directory}" on ${alias}  level=INFO  console=${TRUE}
    ${command}=  Set Variable
    ...  if [ "$(ls -A ${clean_directory})" ]; then find ${clean_directory}/* -maxdepth 0 -mmin +${older_than_min} -exec rm -rf {} \\; ; fi
    ${cleaning_rc}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command  ${command}  ELSE
    ...  Execute Remote Command  ${command}  ${alias}  &{configuration}
    ${result}=  Run Keyword And Return Status  Should Be Equal
    ...  ${cleaning_rc}  ${0}  msg=RC of operation clean "${clean_directory}" on ${alias} is not equal 0
    run keyword if  ${result}
    ...  Log  "${clean_directory}" on ${alias} cleaned  level=INFO  console=${TRUE}  ELSE
    ...  Log   Failed to clean "${clean_directory}" on ${alias}  level=INFO  console=${TRUE}
    [Return]  ${result}

Check Local Host Disk Space
    [Documentation]
    ...  Checks if there is a minimal required available disk space in given directory, sets test as norun if not
    ...  and skips to test teardown. Also dumps `df` output as log from test for future reference.
    ...  *AUTHOR*  dariusz.suszczewicz@nokia.com
    ...  *MAINTAINER*  iuliia.taupeka@nokia.com
    ...  *INPUT*
    ...  | Parameter        | Mandatory | Description                                  |
    ...  | this much        | No       | Minimum expected free space in MB             |
    ...  | directory        | No       | Directory (or file) path to verify            |
    ...
    ...  *RETURN*  None
    [Arguments]  ${directory}=/home/ute  ${this_much}=2048
    Run  echo "[$(date -u)] - ${TEST NAME} \n $(df -h) \n" >> ${DF LOG PATH}
    ${exists}  ${message}=  Run Keyword And Ignore Error  Should Exist  ${directory}
    Run Keyword If  "${exists}" == "FAIL"  Run Keywords  Log  ${message}  level=WARN  AND  Return From Keyword
    ${available space}=  Run  df -BM --output=avail ${directory} | sed 1d | sed -e 's/M//'
    ${not_enough_space}=  Run Keyword If  ${available space} < ${this much}  Set Variable  ${TRUE}
    Run Keyword If  ${not_enough_space}  Run Keywords
    ...  Set Test Variable  ${COLLECT_SNAPSHOT_FLAG}  never
    ...  AND
    ...  Fail  ${available space}MB available in ${directory} is less than required ${this_much}MB

Check Remote Host Disk Space
    [Documentation]
    ...  Copy of KW 'Check Local Host Disk Space' adapted to run on
    ...  remote machine via SSH protocol.
    ...  *AUTHOR*  patryk.furman@nokia.com
    ...  *INPUT*
    ...  | Parameter     | Mandatory | Description                         |
    ...  | space_amount  | Yes       | Minimum expected free space in MB   |
    ...  | dir_path      | Yes       | Directory (or file) path to verify  |
    ...  | host_ip       | Yes       | IP address of host machine          |
    ...  | ssh_port      | Yes       | Port for SSH connection             |
    ...  | ssh_username  | Yes       | Username for log in to host via SSH |
    ...  | ssh_password  | Yes       | Password for log in to host via SSH |

    [Arguments]  ${dir_path}  ${space_amount}  ${host_ip}  ${ssh_port}  ${ssh_username}  ${ssh_password}
    SSHLibrary.Open Connection  host=${host_ip}  port=${ssh_port}
    _SSHLibrary_Login_multiway  ${ssh_username}  ${ssh_password}
    SSHLibrary.Execute Command  echo "[$(date -u)] - ${TEST NAME} \n $(df -h) \n" >> ${DF LOG PATH}  return_stdout=False  return_rc=True
    ${exists}  ${message}=  Run Keyword And Ignore Error  SSHLibrary.Directory Should Exist  ${dir_path}
    Run Keyword If  "${exists}" == "FAIL"  Run Keywords  Log  ${message}  level=WARN  AND  Return From Keyword
    ${available space}=  SSHLibrary.Execute Command  df -BM --output=avail ${dir_path} | sed 1d | sed -e 's/M//'
    ${not_enough_space}=  Run Keyword If  ${available space} < ${space_amount}
    ...  Set Variable  ${TRUE}
    [Teardown]  Run Keywords
    ...  SSHLibrary.Close Connection
    ...  AND
    ...  Run Keyword If  ${not_enough_space}  Set Test Variable  ${COLLECT_SNAPSHOT_FLAG}  never
    ...  AND
    ...  Run Keyword If  ${not_enough_space}  Fail  ${available space}MB available in ${dir_path} is less than required ${space_amount}MB

Get Workspace Version
    [Documentation]
    ...  KW coming from hran_general module. Gets workspace version.
    ${hran_legacy_path}=  Set variable  /home/ute/btsauto/hran_ta
    ${hran_taf_path}=  Set Variable  /home/ute/MN/UTE/hran_ta

    ${USE_GIT}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${hran_legacy_path}/.git

    ${hran_path}=  Set Variable If  '${USE_GIT}' == '${False}'  ${hran_taf_path}  ${hran_legacy_path}

    Log  Default repository path is: ${hran_path}  level=INFO
    Run keyword if  ${USE_GIT}  Run keyword
    ...  Find workspace version and set tags
    ...  git --git-dir=/home/ute/btsauto/hran_ta/.git/ describe --always --tags | awk -F '[/|-g]' '{print $NF}' | cut -c 1-8
    ...  ELSE
    ...  Find workspace version and set tags
    ...  git --git-dir=/home/ute/MN/UTE/hran_ta/.git/ describe --always --tags | awk -F '[/|-g]' '{print $NF}' | cut -c 1-8

Find workspace version and set tags
    [Arguments]  ${command}
    ${workspace_version} =  OperatingSystem.run  ${command}
    Log  Online workspace version is ${workspace_version}  level=DEBUG  console=${TRUE}
    Set tags  Online workspace version = ${workspace_version}
    [Return]  ${workspace_version}

Create Directories For Logs
    [Documentation]
    ...  *AUTHOR* sebastian.burniak@nokia.com
    Create 'Test Results Dir' and Set Test Variable
    Create 'BTSFiles' in '${Test Results Dir}' And Set Test Variable
    Create 'TestFiles' in '${Test Results Dir}' And Set Test Variable
    Create 'UDPLogs' in '${Test Results Dir}' And Set Test Variable
    Create Temp Logs Dir And Set Test Variable

Create 'Test Results Dir' and Set Test Variable
    ${testtimestamp}=    OperatingSystem.Run    date +%F_%H-%M-%S
    ${testresultspath}=    OperatingSystem.Join Path    ${OUTPUT DIR}    ${testtimestamp}_TEST-${TEST NAME}
    Create Directory    ${testresultspath}
    Set Test Variable    ${Test Results Dir}    ${testresultspath}
    Log  'Test Results Dir' created: ${Test Results Dir}  level=DEBUG  console=${TRUE}

Create '${dirname}' in '${rootdir}' And Set Test Variable
    ${dirpath}=    OperatingSystem.Join Path    ${rootdir}    ${dirname}
    Create Directory    ${dirpath}
    Set Test Variable    ${${dirname}}    ${dirpath}
    Log  '${dirname}' created: ${dirpath}  level=DEBUG

Create Temp Logs Dir And Set Test Variable
    ${test_timestamp}=  OperatingSystem.Run  date +%F_%H-%M-%S
    ${TEST NAME WITHOUT BRACKETS}=  Replace String  ${TEST NAME}  [1]  _1_
    ${joined_path}=  OperatingSystem.Join Path  ${TEMP_LOGS_DIR}  ${test_timestamp}_TEST-${TEST NAME WITHOUT BRACKETS}
    Set Test Variable  ${TEMP_LOGS_DIR}  ${joined_path}
    Log  Temp logs Dir created: ${TEMP_LOGS_DIR}  level=DEBUG

Kill process by name
    [Arguments]  ${process_name}  ${local}=${TRUE}  &{configuration}
    [Documentation]
    ...  Keyword killing group of process specified by name (case insensitive).
    ...
    ...  *AUTHOR* tomasz.1.filipek@nokia.com
    ...
    ...  | Parameter   | Man. | Description                                                    |
    ...  | process_name       | Yes  | string       |
    ...  | local | Yes  | boolean |
    ...  | configuration | Yes  | if local==false host_ip=<remote_host_ip>, ssh_port=<port>, ssh_username=<usenrame>, ssh_passsword=<password> |
    ${kill_cmd}=  Set Variable  kill -KILL $(ps -ef | grep -i ${process_name} | awk '{print $2}')
    Run Keyword If  ${local}  Process.Run process  ${kill_cmd}  shell=${TRUE}
    ...  ELSE  Run Keywords
    ...  SSHLibrary.Open Connection  host=${configuration["host_ip"]}  port=${configuration["ssh_port"]}
    ...  AND  _SSHLibrary_Login_multiway  ${configuration["ssh_username"]}  ${configuration["ssh_password"]}
    ...  AND  SSHLibrary.Execute Command  ${kill_cmd}  return_stdout=${FALSE}
    ...  AND  SSHLibrary.Close Connection
    [Return]  ${TRUE}
#####END OF VM MODULE#####



#####EXECUTE COMMANDS MODULE#####
#KWs comes from sbts_general module
Execute Local Command
    [Arguments]  ${command}
    ${command_rc}=  Run And Return Rc  ${command}
    [Return]  ${command_rc}

Execute Local Command And Return Output
    [Arguments]  ${command}
    ${command_stdout}=  Run  ${command}
    [Return]  ${command_stdout}

Execute Remote Command
    [Arguments]  ${command}  ${index_or_alias}  &{configuration}
    _Remote Command Setup  ${index_or_alias}  &{configuration}
    ${command_rc}=  SSHLibrary.Execute Command  ${command}  return_stdout=False  return_rc=True
    [Teardown]  _Remote Command Teardown
    [Return]  ${command_rc}

Execute Remote Command And Return Output
    [Arguments]  ${command}  ${index_or_alias}  &{configuration}
    _Remote Command Setup  ${index_or_alias}  &{configuration}
    ${command_stdout}=  SSHLibrary.Execute Command  ${command}  return_stdout=True  return_rc=False
    [Teardown]  _Remote Command Teardown
    [Return]  ${command_stdout}

Execute Local Command In Loop
    [Arguments]  ${looped_command}
    ${terminal_command_rc}=  _Execute Command In Loop Via  Run And Return Output And Rc  ${looped_command}
    [Return]  ${terminal_command_rc}

_Execute Command In Loop Via
    [Arguments]  ${keyword}  ${looped_command}  @{keyword_args}  &{keyword_kwargs}
    ${terminal_command_rc}=  Set Variable  0
    FOR  ${arg}  IN  @{looped_command["args"]}
        ${command}=  Catenate  ${looped_command["cmd"]}  ${arg}
        ${command_stdout}  ${command_rc}=  Run Keyword  ${keyword}  ${command}  @{keyword_args}  &{keyword_kwargs}
        Log  ${command_stdout}
        ${terminal_command_rc}=  Set Variable If  ${command_rc} != 0  ${command_rc}  ${terminal_command_rc}
    END
    [Return]  ${terminal_command_rc}

Execute Remote Command In Loop
    [Arguments]  ${looped_command}  ${index_or_alias}  &{configuration}
    _Remote Command Setup  ${index_or_alias}  &{configuration}
    ${terminal_command_rc}=  _Execute Command In Loop Via  SSHLibrary.Execute Command  ${looped_command}  return_stdout=True  return_rc=True
    [Teardown]  _Remote Command Teardown
    [Return]  ${terminal_command_rc}

_Remote Command Setup
    [Arguments]  ${index_or_alias}  &{configuration}
    ${check_connection}=  SSHLibrary.Get Connection  ${index_or_alias}
    Run Keyword If  ${check_connection.index}
    ...  SSHLibrary.Switch Connection  ${index_or_alias}  ELSE
    ...  SSHLibrary.Open Connection  host=${configuration["host_ip"]}  port=${configuration["ssh_port"]}
    _SSHLibrary_Login_multiway  ${configuration["ssh_username"]}  ${configuration["ssh_password"]}

_Remote Command Teardown
    SSHLibrary.Close Connection
#####EXECUTE COMMANDS MODULE#####




Synchronize SMODs For Setup Purposes
    [Arguments]  ${alias}=default
    ${neighbor_dn}=  coam.Get Managed Objects  NEIGHBOR_NODE_R  connection=${alias}
    ${sync_status}=    Run keyword and return status  coam.Start Sync    ${neighbor_dn[0]['distName']}    connection=${alias}
    Run keyword if    ${sync_status}    Run Keywords
    ...  Log  Synchronization succeeded    console=${TRUE}
    ...  AND  Return From Keyword  ${TRUE}
    ...  ELSE    Fail    Synchronization failed

Get commissioning path
    [Documentation]
    ...
    ...  Find commissioning in testline configuration directory which match given sw_version
    ...  You can set your own COMMISSIONING_PATH to ommit searching commissioning in config directory
    ...  You can set your own SCF_ID to find scf for technology with exact scf_id value
    ...
    ...  *Example*
    ...  For sw_version=WN18_FL18_GF18_SBTS18SP_ENB_1000_000609_000000 KW will try to find
    ...  SCF_01_SBTS18SP or SCF_01_SBTS18 or SCF_01_TRUNK
    ...
    ...  For sw_version=WN18_FL18_GF18_SBTS17A_ENB_1000_000609_000000 and SCF_ID=02 KW will try to find
    ...  SCF_02_SBTS18SP or SCF_02_SBTS18 or SCF_02_TRUNK
    ...
    ...  *Author*  jaroslaw.piszczala@nokia.com
    ...  source: hran_general.robot
    ...
    [Arguments]  ${sw_version}

    ${regex}=  Set variable  (?i)(wn\\d+_fl\\d+_gf\\d+_)?(?P<product>(SBTS|FL|WN|WBTS|FDSW|TL)[0-9]*)(?P<postfix>[a-zA-Z0-9\.]*)
    ${result}=  Get Regexp Matches  ${sw_version}  ${regex}  product  postfix
    ${PRODUCT}  ${POSTFIX}=  Set variable  ${result[0]}
    ${PRODUCT}=  Convert To Uppercase  ${PRODUCT}
    ${POSTFIX}=  Convert To Uppercase  ${POSTFIX}
    Set test variable  ${SW_TYPE}  ${PRODUCT}${POSTFIX}

    ${scf_id}=  Get Variable Value  ${SCF_ID}  01

    ${product_list}=  Create list  ${PRODUCT}${POSTFIX}  ${PRODUCT}  TRUNK
    FOR  ${product}  IN  @{product_list}
        ${filename}=  Set variable  SCF_${scf_id}_${product}
        Log  Trying to find scf for ${product} (${filename})  console=${True}
        ${commissioning}=  Find commissioning with filename  ${filename}
        ${is_not_empty}=   Run keyword and return status  Should Not Be Empty  ${commissioning}
        Run keyword if  ${is_not_empty}  Return from keyword  ${commissioning}
    END
    [Return]  ${None}

Find commissioning with filename
    [Documentation]
    ...
    ...  Find commissioning in testline configuration directory
    ...  HW_LOCATION_CODE and TESTLINE_NAME will be provided by hran_frame_sbts
    ...
    ...  *Author*  jaroslaw.piszczala@nokia.com
    ...  source: hran_general.robot
    ...
    [Arguments]  ${filename}  ${root}=/home/ute/btsauto/hran_ta/config  ${scf_dir}=commissioning
    ${path}=  Set variable  ${root}/${HW_LOCATION_CODE}/${TESTLINE_NAME}/${scf_dir}/${filename}.xml
    ${is_existing}=  Run keyword and return status  Should Exist  ${path}
    Return from keyword if  ${is_existing}  ${path}
    [Return]  ${None}

Validate Runtime Modules Product Numbers Against SCF
    [Documentation]
    ...  Validate Runtime Modules Product Numbers Against SCF
    ...  source: hran_general.robot
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    [Arguments]  ${runtime modules}  ${scf modules}

    ${runtime mods mapping}=  _Extract Modules Product Codes  ${runtime modules}  productCode  id
    ${scf mods mapping} =  _Extract Modules Product Codes  ${scf modules}  prodCodePlanned  distName

    ${runtime mods product codes}=  Get Dictionary Values  ${runtime mods mapping}
    ${scf mods product codes}=  Get Dictionary Values  ${scf mods mapping}
    Sort List  ${runtime mods product codes}
    Sort List  ${scf mods product codes}

    ${status}=  Run keyword and return status  Lists Should Be Equal  ${runtime mods product codes}  ${scf mods product codes}
    Run keyword if  not ${status}
    ...    Log  Modules product codes differs between runtime(${runtime mods mapping}) and scf(${scf mods mapping})  console=${True}
    [Return]  ${status}

_Extract Modules Product Codes
    [Documentation]
    ...  Source: hran_general.robot
    [Arguments]  ${modules_obj_list}  ${product code key}  ${dist name key}

    ${mods mapping} =  Create Dictionary

    FOR  ${mod}  IN  @{modules_obj_list}
        ${raw product code}  Get From Dictionary  ${mod}  ${product code key}
        ${stripped product code}=  Strip String  ${raw product code}
        @{product code}=  Split String  ${stripped product code}  .
        ${stripped product code}=  Get From List  ${product code}  0
        ${dist name}=  Get From Dictionary  ${mod}  ${dist name key}
        Set To Dictionary  ${mods mapping}  ${dist name}  ${stripped product code}
    END
    [Return]  ${mods mapping}

Check SCF count
    [Documentation]
    ...
    ...  | Parameter       | Mandatory | Description                    |
    ...  | class_name      | Yes       | [LTE, WCDMA, GSM, SMOD, RMOD]  |
    ...  | runtime_objects | Yes       | List of runtime objects        |
    ...  source: hran_general.robot
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    [Arguments]  ${class_name}  ${runtime_objects}
    Run keyword if  ${SCF_COUNT_${class_name}}==0  Run keywords
    ...  Log  ${class_name} not found in SCF  console=${True}
    ...  AND  Return from keyword  ${True}

    Run keyword if  ${SCF_COUNT_${class_name}}==-1  Run keywords
    ...  Log  ${class_name} will be ignored for active software  console=${True}
    ...  AND  Return from keyword  ${True}

    ${final_status}=  Evaluate  ${SCF_COUNT_${class_name}}==len(${runtime_objects})
    [Return]  ${final_status}

Set SCF cells count
    [Documentation]
    ...  type: NR, LTE, GSM, WCDMA
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    [Arguments]  ${type}
    ${scf_cells_count}=  hran_file_operations.Get Cells Count  technology=${type}
    Set test variable  ${SCF_COUNT_${type}}  ${scf_cells_count}

#####ADMIN SECTION
Admin Get ids for all cells
    [Documentation]
    ...  Get IDs for all items of GNCEL, WNCEL, LNCEL and NRCEL class.
	...
	...  | **Author:** jaroslaw.piszczala@nokia.com
	...  | **Maintainer:** jaroslaw.piszczala@nokia.com
	...  | **Released with version:** 48.0
	[Arguments]  ${alias}=default
    ${GNCEL ids}=  coam.Get Ids For All  GNCEL  connection=${alias}
    ${WNCEL ids}=  coam.Get Ids For All  WNCEL  connection=${alias}
    ${LNCEL ids}=  coam.Get Ids For All  LNCEL  connection=${alias}
    ${NRCEL ids}=  coam.Get Ids For All  NRCEL  connection=${alias}
    ${CELLS_ids}=  Evaluate  ${GNCEL ids}+${WNCEL ids}+${LNCEL ids}+${NRCEL ids}
    [Return]  ${CELLS_ids}

Admin Print Active Alarms
    ${active_alarms}=  coam.Get Alarms  connection=default
    ${pretty_active_alarms}=  Evaluate  pprint.pformat(${active_alarms}, indent=4)  modules=pprint
    Log  Active alarms: ${pretty_active_alarms}  console=${True}

Setup Admin Connection
    [Documentation]
    ...  KW setup session to admin api.
    ...
    ...  | **Maintainer:** iuliia.taupeka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | bts_host         | No   | Host IP, local or remote (mplane)                                |
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | connection_name  | No   | Connection name for `name` argument  (alias)                     |
    ...  +------------------+------+------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  Setup Admin Connection  bts_host=10.42.18.251  connection_name=mplane_1

    [Arguments]  ${bts_host}=192.168.255.129  ${connection_name}=default

    ${status}  ${connection}  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  5x  10s
    ...  coam.Setup Admin  admin_api_log_dir=${BTS Files}/admin_api  bts_host=${bts_host}  bts_port=443
    ...  name=${connection_name}
    Run Keyword If  '${status}'=='FAIL'
    ...  Fail  Admin connection did not start after 5 attempts!
    ...  ELSE  Log  Connection to Admin successfully established!${\n}  console=${True}
    Set Test Variable  ${connection}
####ADMIN SECTION END


####SEARCH ORDER SECTION
Modify Resource Search Order
    [Arguments]    ${resource_name}
    [Documentation]  Adjust Robot's library search order for the Robot-based (as opposed to JSON-based)
    ...    test sets. The KW adds a new entry at the end of the search order list (to retain search order defined
    ...    in TC Setup). To be used in [Setup] section as follows (presented here in a convenient tabular form):
    ...
    ...    [Setup] | Run Keywords | res_name.TC Setup | AND | Modify Resource Search Order | res_name
    ...
    ...    in pair with `Restore Resource Search Order` in [Teardown]:
    ...
    ...    [Teardown] | Run Keywords | res_name.TC Teardown | AND | Restore Resource Search Order
    ...
    ...    Non-existing resurces (`dummy_resource_name`) are ignored.
    [Tags]  robot:no-dry-run
    ${dummy_search_order}=    Create List    dummy_resource_name
    ${search_order}=   Set Library Search Order
    ${ORIGINAL_SEARCH_ORDER}=    Set Variable If    len(${search_order})    ${search_order}    ${dummy_search_order}
    Set Test Variable    ${ORIGINAL_SEARCH_ORDER}
    Set Library Search Order    ${resource_name}    @{search_order}

Restore Resource Search Order
    [Documentation]    To be used in pair with `Modify Resource Search Order`
    [Tags]  robot:no-dry-run
    ${search_order}=    Create List    @{ORIGINAL_SEARCH_ORDER}
    Remove Values From List    ${search_order}    dummy_resource_name
    Set Library Search Order   @{search_order}
####END OF SEARCH ORDER SECTION

#Report Configuration ID
#    Run Keyword And Ignore Error  Request to Scout to fetch SCF
#
#Request to Scout to fetch SCF
#    ${bts_obj}  coam.Get parameters for all  BTS
#    ${BTS_count}  Get Length  ${bts_obj}
#    ${bts_id}  Convert to string  ${bts_obj[0].btsId}
#    Run Keyword If  ${BTS_count} > 1  scout.Setup Scout  ${TESTLINE_NAME}_${bts_id}
#    ...  ELSE  scout.Setup Scout  ${TESTLINE_NAME}
#    scout.Request Scf
#    [Teardown]  Teardown Scout API

SCF Count Smod
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns count of SMOD from SCFC file.
    ...
    ...  Arguments:
    ...  +======================+======+==================================================================+
    ...  | Argument             | Man. | Description                                                      |
    ...  +======================+======+==================================================================+
    ...  | scfc_file_path       | Yes  | Path to the scfc file                                            |
    ...  +----------------------+------+------------------------------------------------------------------+

    ${smod_count}=
    ...  Evaluate Xpath  ${scfc_file_path}  count(.//managedObject[@class="SMOD" or @class="com.nokia.srbts.eqm:SMOD"])
    ${smod_count}=  Convert To Integer  item=${smod_count}
    [Return]  ${smod_count}

Verify VM Time Zone
    [Arguments]  ${timezone}=Europe/Bucharest
    ${verdict}=  Run Keyword And Return Status  Check VM Time Zone  ${timezone}
    Run Keyword If  not ${verdict}  Run Keywords
    ...  Set VM Time Zone  ${timezone}
    ...  AND  Check VM TimeZone  ${timezone}

Set VM Time Zone
    [Arguments]  ${expected_timezone}
    ${regex}=  Set Variable  Time zone:\\s(?P<timezone>[a-zA-Z/]*)\\s\\((?P<time>.*)\\)
    ${timedatectl}=  Run  timedatectl
    ${result}=  Get Regexp Matches  ${timedatectl}  ${regex}  timezone  time
    ${timezone}  ${time}=  Set Variable  ${result[0]}
    Run Keyword If  '${timezone}'!='${expected_timezone}'  Run Keywords
    ...  Log To Console  Changing VM time zone: ${timezone} to ${expected_timezone}
    ...  AND  Run  sudo timedatectl set-timezone "${expected_timezone}"
    ...  AND  Sleep  70s

Check VM Time Zone
    [Arguments]  ${expected_timezone}
    ${regex}=  Set Variable  Time zone:\\s(?P<timezone>[a-zA-Z/]*)\\s\\((?P<time>.*)\\)
    ${timedatectl}=  Run  timedatectl
    ${result}=  Get Regexp Matches  ${timedatectl}  ${regex}  timezone  time
    ${timezone}  ${time}=  Set Variable  ${result[0]}
    Should Be True  '${timezone}'=='${expected_timezone}'
