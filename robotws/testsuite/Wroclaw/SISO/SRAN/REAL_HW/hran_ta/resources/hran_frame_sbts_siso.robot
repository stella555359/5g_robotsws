# robocop: off
*** Settings ***
Documentation
...  general resource for TC setup and teardown

# product-specfic settings:
Library           hran_testline_configuration   ${HW_LOCATION_CODE}  ${TESTLINE_NAME}
#Library           hran_ssh
Library           hran_file_operations
Library           ute_admin_infomodel
#Library           ute_admin
#Library           hran_tools
Library           Collections
Library           OperatingSystem
Library           SSHLibrary
Library           String
Library           DateTime
Library           Process
Library           Telnet
Library           hran_bsc
Library           ute_syslog
Library           taf.sbts.oam.coam.admin  WITH NAME  admin
Library           taf.transport.ssh  WITH NAME  ssh
Library           taf.config.scf  WITH NAME  scf
Library           taf.hw.pdu  WITH NAME  pdu
Library           taf.sw.ping  WITH NAME  ping
Library           ./../../../resources/ims2_parser.py
Library           ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library           taf.sw.scout  WITH NAME  scout
Library           taf.sw.reporting_portal  WITH NAME  rp
Library           XML    use_lxml=true
Library           ../../../resources/truck_roll.py
Library           ../../../resources/qc.py

# common settings:

Resource          ca_siso_general.robot





*** Variables ***
#all needed variables should be given using '--variablefile CONFIG_FILE' or '-V CONFIG_FILE'
@{UDP ports}=                     51000    51001    51003    50011
${RMOD_expected_states}=          administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
    ...                           availabilityStatus=regex"(?i)Online"
${SMOD_expected_states}=          administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
    ...                           availabilityStatus=regex"(?i)"Online"
${BBMOD_expected_states}=         administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
    ...                           availabilityStatus=regex"(?i)Online"
${ALD_expected_states}=           operationalState=regex"(?i)Enabled", availabilityStatus=Online
${cells_LTE_expected_states}=     administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", availabilityStatus=regex"(?i)Online",
    ...                           blockingState=regex"(?i)Unblocked"
${cells_WCDMA_expected_states}=   operationalState=regex"(?i)Enabled", availabilityStatus=regex"(?i)Online",
    ...                           blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${dist_GSM_cell_runtime_view}=    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/GNBTS_R-*/GNBCF_R-*/GNCEL_R-*
${cells_GSM_expected_states}=     administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", availabilityStatus=regex"(?i)Online",
    ...                           blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${cells_NR_expected_states}=      administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", availabilityStatus=regex"(?i)Online",
    ...                           blockingState=regex"(?i)Unblocked"
${COLLECT_SNAPSHOT_FLAG}=         failed_verdict
&{IGNORED_FAULT_61524}=           faultId=61524  faultName=SSH enabled
&{IGNORED_FAULT_61652}=           faultId=61652  faultName=R&D Service Port enabled
&{IGNORED_FAULT_61649}=           faultId=61649  faultName=LMP access via port
&{IGNORED_FAULT_6450}=            faultId=6450  faultName=Diagnostic Files collected
&{IGNORED_FAULT_4655}=            faultId=4655  faultName=Service account root access is enabled
&{IGNORED_FAULT_4654}=            faultId=4654  faultName=Ethernet port security is disabled
&{IGNORED_FAULT_4681}=            faultId=4681  faultName=Sanity Check Error
@{GLOBALLY_IGNORED_ALARMS}=       ${IGNORED_FAULT_61524}  ${IGNORED_FAULT_61652}  ${IGNORED_FAULT_61649}  ${IGNORED_FAULT_6450}
    ...                           ${IGNORED_FAULT_4655}  ${IGNORED_FAULT_4654}  ${IGNORED_FAULT_4681}
${DSC}=                           ${FALSE}
@{REMOTE_TESTLINES_LIST}          @{EMPTY}  #list of aliases of remote testlines;
    ...                                     #to be defined using REMOTE_TESTLINES dictionary in testline configuration file or json
#######hran_admin##################
${ADMIN_SNAPSHOT_TIMEOUT_MASTER}    1200  #timeout for collect snapshot via Admin from MSM (in sec)
${ADMIN_SNAPSHOT_TIMEOUT_ESM}       1500  #timeout for collect snapshot via Admin from ESM (in sec)
#######hran_general################
${DF LOG PATH}=                     ${OUTPUT DIR}/df.log
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
${TESTLINE_NAME}
${HW_LOCATION_CODE}
${ENABLE_TRUCK_ROLL_FLAG}    ${True}
&{TRUCK_ROLL_HW_DICT}

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
    ...  | enable_truck_roll    | TRUE            | Enables Truck Roll preparation |
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
    [Arguments]  ${admin_launch}=${TRUE}       ${syslog_launch}=${TRUE}  ${infomodel_launch}=${TRUE}  #${btssm_launch}=${FALSE}
    ...          ${modules_check}=${TRUE}  ${cells_check}=${TRUE}       ${alarms_check}=${TRUE}  ${bts_host}=192.168.255.129
    ...          ${expected_BTS_status}=OnAir  ${scf_check}=${TRUE}  ${ignored_alarms}=${EMPTY}  ${enable_truck_roll}=${ENABLE_TRUCK_ROLL_FLAG}

    Set Test Variable  ${scf_check}                ${scf_check}
    Set Test Variable  ${btssm_started}            ${FALSE}
    Set Test Variable  ${infomodel_started}        ${FALSE}
    Set Test Variable  ${SMOD1_syslog_started}     ${FALSE}
    Set Test Variable  ${SMOD2_syslog_started}     ${FALSE}
    Set Test Variable  ${admin_started}            ${FALSE}
    Set Test Variable  ${scf_parser_started}       ${FALSE}
    Set Test Variable  ${bts_verification_status}  norun
    Set Test Variable  ${LOG_TX_POWER}           ${TRUE}
    ${REMOTE_TESTLINES_LIST}  Create List
    Set Test Variable  ${REMOTE_TESTLINES_LIST}

    ${additional_variables_exist}=  Run Keyword And Return Status  Variable Should Exist  ${ADDITIONAL_VARIABLES_PATH}
    Run Keyword If  ${additional_variables_exist}  Run Keyword And Ignore Error  Import Variables  ${ADDITIONAL_VARIABLES_PATH}

    ${taf_config_model}=  Run keyword and return status   Variable should exist  ${tl}
    Set test variable  ${TAF_CONFIG_MODEL}  ${taf_config_model}
    Run keyword if  ${TAF_CONFIG_MODEL}  Taf config adapter
    ...       ELSE   hran_testline_configuration.Set Config Variables   @{TESTLINE_CONFIG_VARIABLES}
    Run keyword If  not ${TAF_CONFIG_MODEL}  Siso Clean VM disk space  Master
    Check Local Host Disk Space

    # product-specific part of precondititons:
    Siso Hran_ta Preconditions

    Log  TC executed with configuration files of ${HW_LOCATION_CODE}\\${TESTLINE_NAME}  level=INFO  console=${TRUE}
    Set Tags  ${HW_LOCATION_CODE}\\${TESTLINE_NAME}

    ${ignored_alarms}=  Set Additional Ignored Alarms
    Set Test Variable  ${ADDITIONAL_IGNORED_ALARMS}  ${ignored_alarms}

    Set Raw Alarm History Connection Parameters
    Log Variables  level=DEBUG
    Run Keyword If  ${admin_launch}       Run Keyword And Continue On Failure  Siso Start Admin  bts_host=${bts_host}
    Run Keyword If  ${syslog_launch}      Run Keyword And Continue On Failure  Start syslog on SMOD1
    Run Keyword If  ${infomodel_launch}   Run Keyword And Continue On Failure  Start Infomodel  bts_host=${bts_host}

    Setup SMOD2    ${admin_started}   ${syslog_launch}  #${infomodel_started}

    Run Keyword If  ${infomodel_started}  Run Keyword And Continue On Failure  Print Active And Passive SW Version
    Run keyword If  ${admin_started} and ${scf_check}  Run keyword and continue on failure  Start scf Parser  UNIVERSAL
    Run keyword if  ${admin_started}  Verify BTS states  ${expected_BTS_status}
    ...  ${modules_check}  ${cells_check}  ${alarms_check}  ${ignored_alarms}
    ...        ELSE  Set Test Variable  ${bts_verification_status}  passed

    Run keyword if  ${DSC}  Run Keyword And Continue On Failure  Remote Test Line Setup  remote_host=${PC_IP2}  alias=DSC
    ${remote_testlines_configured}  ${remote_testlines_tmp}=  Run keyword and ignore error  Get dictionary keys  ${REMOTE_TESTLINES}
    ${REMOTE_TESTLINES_LIST}=  Run Keyword If  '${remote_testlines_configured}'=='PASS'  Set Variable  ${remote_testlines_tmp}
    ...  ELSE  Create List
    Set Test Variable  ${REMOTE_TESTLINES_LIST}
    FOR  ${remote_alias}  IN  @{REMOTE_TESTLINES_LIST}
        Verify Configuration And Set Up Remote Test Line  ${modules_check}  ${cells_check}  ${alarms_check}  ${remote_alias}
    END

    Run Keyword If    ${enable_truck_roll}    Prepare HW Variables For Truck Roll    alias=default
    FOR  ${remote_alias}  IN  @{REMOTE_TESTLINES_LIST}
        Run Keyword If    ${enable_truck_roll}    Prepare HW Variables For Truck Roll    alias=${remote_alias}
    END

    Log  End of Common Test Setup  level=INFO  console=${TRUE}


Setup SMOD2
    [Arguments]  ${admin_started}  ${syslog_launch}  #${infomodel_started}
    ${smod2_variable_exists}=   Run keyword and return status  Variable Should Exist  ${SMOD2}
    ${pc_ip2_variable_exists}=  Run keyword and return status  Variable Should Exist  ${PC_IP2}
    ${smods_number}=  SCF Count Smod  ${COMMISSIONING_PATH}
    Run Keyword If  ${smods_number}<2  Run Keywords
    ...  Log  One SMOD or none PC_IP2 was declared in SCF   console=${TRUE}
    ...  AND  Set test variable  ${SMOD2_exists}  ${FALSE}
    ...  AND  Return from keyword
    Run keyword if  '${smod2_variable_exists}'=='${False}' or '${pc_ip2_variable_exists}'=='${False}'    Run keywords
    ...  Log  One SMOD or none PC_IP2 was declared in config   console=${TRUE}
    ...  AND  Set test variable  ${SMOD2_exists}  ${FALSE}
    ...  AND  Return from keyword
    Run keyword if  ${admin_started}  Check SMOD2 in Admin
    ...  ELSE  Run keywords
    ...  Log  Skip checking SMOD2 in Admin  console=${TRUE}
    ...  AND  Set test variable  ${SMOD2_exists}  ${TRUE}

    Run Keyword If  not ${TAF_CONFIG_MODEL}  Run keyword if  ${SMOD2_exists}
    ...  Siso Clean VM disk space  Extension  host_ip=${PC_IP2}  ssh_port=${22}  ssh_username=ute  ssh_password=ute
    Run Keyword If  not ${TAF_CONFIG_MODEL}  Run keyword if  ${SMOD2_exists}
    ...  Siso Check Remote Host Disk Space  /home/ute  2048  ${PC_IP2}  ${22}  ute  ute
    Run Keyword If  ${syslog_launch} and ${SMOD2_exists}  Run Keyword And Continue On Failure  Start syslog on SMOD2

Common Test Teardown
        [Documentation]
    ...  Set of actions which will be launched after each SBTS SOAM test ends (starting from SBTS17).
    ...  List of actions:
    ...  -> Checks occurance of Truck Roll's triggers
    ...  -> Triggers snapshot depends on selected option and test_verdict
    ...  -> Gets and displays siteName information from siteconf.xml for Master and Slave SM (if slave_tech is not GSM)
    ...  -> Collects BTSSM files and stops BTSSM session
    ...  -> Collects Infomodel files and stops Infomodel session
    ...  -> Collects Syslog files ands stops logging
    ...  -> Collects Admin files and stops Admin session
    ...  -> Executes Stop and Fix action in order of Truck Roll elimination
    ...
    ...  | Parameter        | Default        | Description                                |
    ...  | collect_snapshot | failed_verdict | Flag for enabling/disabling snapshot trace |
    ...  | enable_truck_roll| TRUE           | Enables Truck Roll check                   |
    ...
    ...  | Possible collect_snapshot values | Description
    ...  | always                           | Snapshot is collected unless the test verdict is norun |
    ...  | failed_verdict                   | Snapshot is collected if the test verdict is failed or blocked |
    ...  | never                            | Snapshot is not collected |
    ...
    [Arguments]  ${collect_snapshot}=${COLLECT_SNAPSHOT_FLAG}   ${enable_truck_roll}=${ENABLE_TRUCK_ROLL_FLAG}

    ${truck_roll_analyze_failed}    ${truck_roll_email_reason}=    Run Keyword IF    ${enable_truck_roll}    Analyze Truck Roll On All Nodes

    # this is to allow one to override `collect_snapshot` by providing it in a command line / JSON,
    # even if it is set in a TC (as in `Common Test Teardown    collect_snapshot=never`)
    Report Configuration ID
    ${collect_snapshot}=    Set Variable If    '${COLLECT_SNAPSHOT_FLAG}' != 'failed_verdict'    ${COLLECT_SNAPSHOT_FLAG}    ${collect_snapshot}

    Log  Common Test Teardown  level=INFO  console=${TRUE}

    Run Keyword If  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...  Log  Initial verification of BTS states failed, state or alarm verification not succeeded  console=${TRUE}

    Run Keyword If  '${collect_snapshot}'=='never'  Log  Collecting Snapshot skipped on user demand!  console=${TRUE}
    ...  ELSE IF  '${collect_snapshot}'=='failed_verdict'  Run Keyword If Test Failed  Collect Snapshot And TRS
    ...  ELSE IF  '${collect_snapshot}'=='always'  Collect Snapshot And TRS
    Run keyword if  ${DSC}  Remote Test Line Teardown  alias=DSC  verify_states_stability=${True}
    FOR  ${remote_line_alias}  IN  @{REMOTE_TESTLINES_LIST}
        Remote Test Line Teardown  alias=${remote_line_alias}
    END
    Run Keyword If  ${infomodel_started}  Teardown Infomodel
    Teardown All Aliases For Infomodel
    Run Keyword If  ${admin_started}  Run Keywords  Siso Admin Print Active Alarms  AND  Collect Infomodel Via Taf
#    Run Keyword And Ignore Error  Teardown Admin
#    Teardown All Aliases For Admin
    Run Keyword And Ignore Error  admin.Teardown Admin  connection=default
    admin.Teardown All Aliases For Admin
    Collect Syslog
    Run keyword If  ${scf_parser_started}  Teardown scf Parser
    Collect Swconfigs
    Collect RawAlarmHistory
    Log    Move directory ssh_forwarder_log to ${BTS Files}
    Run Keyword And Ignore Error  Move Directory  ${EXECDIR}/ssh_forwarder_log  ${BTS Files}

    # hran_ta postcondititons:
    Siso Hran_ta Postconditions

    # Both lists based on https://confluence.ext.net.nokia.com/display/mnsranprodsisopz/Team
    ${truck_roll_recipients_list}=    Create List
    ...  I_MN_RAN_RD_VRF_WRO4_2_GMS@internal.nsn.com
    ...  I_MN_RAN_RD_VRF_WRO4_7_GMS@internal.nsn.com
    ...  I_SRAN_PROD_SISO_WRO_CRTM@internal.nsn.com
    ${truck_roll_cm_maintainers_list}=    Create List
    ...  piotr.baranowski@nokia.com
    ...  hubert.nowakowski@nokia.com
    ...  kamil.malecki@nokia.com
    ...  patrycjusz.jablonski@nokia.com
    ...  anna.plecha@nokia.com
    ...  karol.bielenny@nokia.com
    ...  mateusz.chryplewicz@nokia.com
    ...  malgorzata.ficek@nokia.com
    ...  tomasz.lojewski@nokia.com
    ...  paulina.ryzner@nokia.com
    ...  ewa.pyrka@nokia.com
    ...  krzysztof.harupa@nokia.com
    ...  tomasz.pawlaczyk@nokia.com
    ...  dariusz.wojarski@nokia.com
    ...  krzysztof.pekala@nokia.com
    ...  artur.kaczybura@nokia.com
    ...  katarzyna.zacharuk@nokia.com
    ...  karol.biernat@nokia.com
    ...  jakub.mortka@nokia.com
    ...  jedrzej.grzelak@nokia.com
    ...  przemyslaw.kempa@nokia.com
    ...  slawomir.jastrzebski@nokia.com
    ...  piotr.korczynski@nokia.com
    ...  anna.maciejewska@nokia.com
    ...  daniel.bartkowiak@nokia.com
    ...  mateusz.kawka@nokia.com
    ...  szymon.natanek@nokia.com
    ...  malgorzata.piecyk-celuch@nokia.com
    ...  krzysztof.malolepszy@nokia.com
    ...  izabela.wencel@nokia.com
    ...  dominika.1.wojcik@nokia.com
    ...  aleksandra.zalewska@nokia.com
    ...  wojciech.bodzek@nokia.com

    # Executing Stop&Fix action if Truck Roll any check failed
    Run Keyword If    ${truck_roll_analyze_failed} and ${enable_truck_roll}    Exec Stop And Fix Action
    ...    recipients_list=${truck_roll_recipients_list}    reply_list=${truck_roll_cm_maintainers_list}    reason_dict=${truck_roll_email_reason}

    Run keyword if  'STOPONFAIL' in @{TEST TAGS} and '${TEST STATUS}' == 'FAIL'
    ...  Fatal error  Execution stopped because critical TC '${TEST NAME}' failed


Siso Clean VM disk space
    [Documentation]
    ...  Wrapper function for KW used for VM cleaning. Cleaning will be perfomrmed on /tmp and ${Temp Logs Dir}. Also
    ...  processes remaining after files deletion would be killed.

    [Arguments]  ${alias}  &{configuration}
    Run keyword if  '${alias}'=='local' or '${alias}'=='Master'  Run keywords
    ...  Siso Clean up directory  /tmp                    720  ${alias}  AND
    ...  Siso Clean up directory  /home/ute/btsauto/logs  240  ${alias}  AND
    ...  Siso Kill processes remained after files deletion on VMs /home partition  ${alias}
    ...  ELSE  Run Keywords
    ...  Siso Clean up directory  /tmp                    720  ${alias}  host_ip=${configuration["host_ip"]}  ssh_port=${configuration["ssh_port"]}
    ...                                             ssh_username=${configuration["ssh_username"]}  ssh_password=${configuration["ssh_password"]}  AND
    ...  Siso Clean up directory  /home/ute/btsauto/logs  240  ${alias}  host_ip=${configuration["host_ip"]}  ssh_port=${configuration["ssh_port"]}
    ...                                             ssh_username=${configuration["ssh_username"]}  ssh_password=${configuration["ssh_password"]}  AND
    ...  Siso Kill processes remained after files deletion on VMs /home partition  ${alias}  host_ip=${configuration["host_ip"]}
    ...                                                                                      ssh_port=${configuration["ssh_port"]}
    ...                                             ssh_username=${configuration["ssh_username"]}  ssh_password=${configuration["ssh_password"]}

Start syslog on ${smod}
    Log    Trying to start syslog on ${smod}   level=INFO  console=${TRUE}
    ${syslog_started}=  Run keyword and return status  Wait until keyword succeeds  5 min  15 sec
    ...  Restart syslog on ${smod}
    Set test variable  ${${smod}_syslog_started}  ${syslog_started}
    Run keyword if  ${${smod}_syslog_started}  Log    Syslog on ${smod} started  level=TRACE  console=${TRUE}
    ...  ELSE  Log  Syslog on ${smod} did not start and will not be collected during TC execution  console=${TRUE}

Restart syslog on SMOD1
    Run Keyword And Ignore Error  Siso Kill Process By Name  btslog
    Run Keyword And Ignore Error  ute_syslog.Stop Syslog  alias=SMOD1
    ${file_limit}=  Get variable value  ${MAX_UDP_SIZE}  0
    ute_syslog.Start Syslog  alias=SMOD1  log_dir=${Temp Logs Dir}  log_name=SMOD1_UDP
    ...  ip=${SMOD1["UDP_IP"]}  ports=@{UDP ports}  file_limit=${file_limit}

Restart syslog on SMOD2
    Start remote syslog  remote_host=${PC_IP2}  udp_ip=${SMOD2["UDP_IP"]}  alias=SMOD2

Start remote syslog
    [Arguments]  ${remote_host}  ${udp_ip}  ${alias}
    Run Keyword And Ignore Error  Siso Kill Process By Name  btslog  local=${FALSE}  host_ip=${remote_host}
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
    Log    ${alias} syslog will be terminated   level=INFO  console=${TRUE}
    ${syslog_collected}=  Run keyword and return status  Collect syslog results  alias=${alias}
    ...  destination=${UDP Logs}/${alias}_UDP.tar.gz  unzip=false
    Run keyword if  ${syslog_collected}  Log  ${alias} syslog collected to 'UDP Logs'  level=INFO  console=${TRUE}
    ...  ELSE  Log  ${alias} syslog collection failed  level=INFO  console=${TRUE}

Start Infomodel
    [Arguments]  ${bts_host}=192.168.255.129
    Log    Trying to setup and connect to infomodel (max 5 min)   level=INFO  console=${TRUE}
    ${infomodel_started}=  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  15 sec  _Single attempt to Start Infomodel  bts_host=${bts_host}
    Set Test Variable  ${infomodel_started}
    Run Keyword If  not ${infomodel_started}
    ...  Fail  Infomodel connection did not start
    Log    Connection to infomodel successfully established!  level=INFO  console=${TRUE}

_Single attempt to Start Infomodel
    [Arguments]  ${bts_host}=192.168.255.129
    Log    Trying to setup infomodel    level=INFO  console=${TRUE}
    Setup Infomodel  address=${bts_host}  port=443  timeout=90  use_ssl=True  admin_api_log_dir=${BTS Files}/
    Log    Trying to connect to infomodel    level=INFO  console=${TRUE}
    ${infomodel_started}=  Run Keyword And Return Status  Connect Infomodel  timeout=90
    Run Keyword If  not ${infomodel_started}  Run keywords  Teardown Infomodel    AND    Fail    Failed to start Infomodel

Collect Infomodel Via Taf
    Log    Collecting infomodel log   level=INFO  console=${TRUE}
    admin.Collect Infomodel Log From Current Session  target_file_name=${BTS Files}/IM/InfoModel_log.ims2
    ...  timeout=300  connection=default
    Log    Infomodel log collected  level=INFO  console=${TRUE}

Siso Start Admin
    [Arguments]  ${bts_host}
    ${admin_taf_started}=  Run Keyword And Return Status  Setup TAF Admin  bts_host=${bts_host}
#    ${admin_ute_started}=  Run Keyword And Return Status  Start Admin
#    Run Keyword If  ${admin_taf_started} and ${admin_ute_started}  Set Test Variable  ${admin_started}  ${TRUE}
    Run Keyword If  ${admin_taf_started}  Set Test Variable  ${admin_started}  ${TRUE}

#Start Admin
#    [Arguments]  ${bts_host}=192.168.255.129  ${bts_port}=443  ${use_ssl}=TRUE  ${alias}=default
#    Log    Trying to connect to ute admin (max 5 min)   level=INFO  console=${TRUE}
#    ${status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  5 min  15 sec
#    ... admin.Setup Admin  admin_api_log_dir=${BTS Files}  bts_host=${bts_host}  bts_port=${bts_port}  use_ssl=${use_ssl}  alias=${alias}
#    ...               update_interval=1000
#    Run Keyword If  not ${status}
#    ...  Fail  Ute Admin connection did not start
#    Log    Connection to ute admin successfully established!  level=INFO  console=${TRUE}

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
    Run Keyword If  not ${scf_parser_started}
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
    Log    Teardown scf Parser   level=INFO  console=${TRUE}
    hran_file_operations.Teardown SCFC Parser

Set Raw Alarm History Connection Parameters
    Log    Set Raw Alarm History Connection Parameters  level=INFO  console=${TRUE}
    hran_file_operations.Rah Set Connection Parameters
    ...  target_path=/tmp/RawAlarmHistory.txt  target_ip=${SMOD1['IP']}  target_username=${SMOD1['USERNAME']}
    ...  target_password=${SMOD1['PASSWORD']}  destination_directory=${BTS Files}/

Find SCF file
    Log  Find SCF file  console=${True}
    ${COMMISSIONING_PATH}=  Siso Get commissioning path  ${active SW version}
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
    ${bb_modules_working}=  Run Keyword If  ${modules_check}  Verify bb modules states
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
    ${ALL_AVAILABLE_CELLS}=  Siso Admin Get ids for all cells
    Set test variable  ${ALL_AVAILABLE_CELLS}

    ${alarms_status}  ${alarms_msg}=  Run Keyword If  ${alarms_check}  Run Keyword And Ignore Error
    ...  Siso Check Unexpected Alarms  skip_fault=${ignored_alarms}
    Run keyword if  '${alarms_status}'=='FAIL'  Log  Unexpected alarms found: ${alarms_msg}  console=${TRUE}

    ${statuses_dictionary}=  Create Dictionary  BTS_state_is_correct=${BTS_state_is_correct}
    ...  system_modules_working=${system_modules_working}  radio_modules_working=${radio_modules_working}
    ...  alds_working=${alds_working}  cells_GSM_onair=${cells_GSM_onair}  cells_WCDMA_onair=${cells_WCDMA_onair}
    ...  cells_LTE_onair=${cells_LTE_onair}  cells_NR_onair=${cells_NR_onair}  alarms_status=${alarms_status}
    ...  bb_modules_working=${bb_modules_working}
    ${pretty_statuses}=  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint

    [Teardown]

    ${cells_count_status}=  Run Keyword And Return Status  should be empty  ${ALL_AVAILABLE_CELLS}

    Run Keyword If  '${BTS_current_status}' == 'NotCommissioned' and ${cells_count_status} and ${BTS_state_is_correct} == ${FALSE}
    ...  Fail  Test failed due to BTS status: NotCommissioned. There are 0 configred cells.\nSkip to teardown!
    ${all_cells_onair}  Evaluate  ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair} and ${cells_NR_onair}
    ${hw_modules_working}  Evaluate  ${system_modules_working} and ${bb_modules_working} and ${radio_modules_working} and ${alds_working}
    Run Keyword If
    ...  ${BTS_state_is_correct} and ${hw_modules_working} and ${all_cells_onair} and '${alarms_status}'!='FAIL'
    ...  Set Test Variable  ${bts_verification_status}  passed
    ...  ELSE  Fail  Test failed due to failure of BTS initial check:\n${pretty_statuses}.\n${alarms_msg}\nSkip to teardown!

Verify BTS proceduralState
    [Arguments]  ${expected_BTS_status}
    Log  Start BTS commissioning verification  console=${True}
    ${current_status}=  admin.Get Mrbts State  connection=default
    ${BTS_in_expected_status}=  Run keyword and return status  Should Match Regexp  ${current_status}  ${expected_BTS_status}
    Run keyword if  ${BTS_in_expected_status}  Log  BTS is in expected status (${current_status})!  console=${TRUE}
    ...  ELSE  Log  BTS has state other than expected.  console=${TRUE}
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
    Run keyword if  ${scf_parser_started}  Set SCF system modules count and verify product numbers SiSo
    Run keyword and return  Verify modules SiSo  SMOD  scf_check=${scf_parser_started}

Verify bb modules states
    [Documentation]
    ...  Wrapper KW for checking BBMOD number against SCF and comparing BBMOD states with states defined in
    ...  ${BBMOD_expected_states} variable
    ...
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com
    ...  | **Released with version:** ---

    Log  Start bb modules verification  console=${True}
    Run keyword if  ${scf_parser_started}  _SiSo SCF Count BBMODS
    Run keyword and return  Verify modules SiSo  BBMOD  scf_check=${scf_parser_started}

_SiSo SCF Count BBMODS
    ${bb_num}=  Evaluate Xpath  ${COMMISSIONING_PATH}
    ...  count(.//managedObject[contains(@class, "BBMOD") and not(contains(@class, "_R"))])
    ${bb_num}=  Convert To Integer  ${bb_num}
    Set test variable  ${SCF_COUNT_BBMOD}  ${bb_num}

Verify radio modules states
    [Documentation]
    ...  Wrapper KW for checking RMOD product numbers against SCF and comparing RMOD states with states defined in
    ...  ${RMOD_expected_states} variable
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** ---

    Log  Start radio modules verification  console=${True}
    Run keyword if  ${scf_parser_started}  Set SCF radio modules count and verify product numbers SiSo
    Run keyword and return  Verify modules SiSo  RMOD  scf_check=${scf_parser_started}

Verify ald states
    [Documentation]
    ...  Wrapper KW for comparing ALD states with states defined in ${ALD_expected_states} variable. Because of ticket
    ...  https://jiradc.int.net.nokia.com/browse/URW-5861, productCode checking is now omitted
    ...
    ...  | **Author:** patryk.furman@nokia.com
    ...  | **Maintainer:** patryk.furman@nokia.com
    ...  | **Released with version:** 50.3

    Log  Start ALD verification  console=${TRUE}
    Run keyword and return  Verify modules SiSo  ALD  scf_check=${FALSE}

Verify ${technology} cells states
    [Documentation]
    ...  Wrapper KW for checking all RATs cells count against SCF and comparing cells states with states defined in
    ...  ${cells_LTE_expected_states}, ${cells_WCDMA_expected_states} and ${cells_GSM_expected_states} variables
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** ---

    Log  Start ${technology} cells verification  console=${True}
    Run keyword if  ${scf_parser_started}  Siso Set SCF cells count  ${technology}
    Run keyword and return  Verify cells SiSo  ${technology}  scf_check=${scf_parser_started}


Print Active And Passive SW Version
    ${bts_info}=  admin.Get Bts Info  connection=default
    ${expected_SW_release}=  Set variable  [A-Z]+[0-9]{2}(?=[0-9A-Z]{0,2}?_[A-Z3-4]+_\\d{4}_\\d{6}_\\d{6})
    ${status}  ${sbts version}=  Run Keyword And Ignore Error  Should Match Regexp  ${bts_info['swInfo']['swVersion']}  ${expected_SW_release}

    Log    Active SW version (MSM): ${bts_info['swInfo']['swVersion']}    console=${TRUE}
    Set tags  MSM_SW_active-${bts_info['swInfo']['swVersion']}

    Run Keyword If  '${status}'=='FAIL'  Fail  Software is not compatible with this frame (expected ${expected_SW_release})

    Set test variable  ${active SW version}    ${bts_info['swInfo']['swVersion']}
    Set test variable  ${sbts version}

Collect Swconfigs
    ${status}  ${result}=  Run Keyword And Ignore Error
    ...  Get File From System Module  source_path=/ffs/run/swconfig.txt  destination_path=${BTS Files}/
    Run Keyword If  '${status}'=='PASS'  Log  swconfig.txt from System module collected  console=${True}
    ...  ELSE  Run Keyword  Log  swconfig.txt could not be retrieved from System Module! Error: ${result}  console=${True}
    Run Keyword If  ${SMOD2_exists}  Get Swconfig From Extension

Get Swconfig From Extension
    ${status}  ${result}=  Run Keyword And Ignore Error
    ...  Get File From System Module  target_ip="192.168.255.7"  source_path=/ffs/run/swconfig.txt  destination_path=${BTS Files}/  via_ip=${PC_IP2}
    Run Keyword If  '${status}'=='PASS'  Run Keywords  Log  swconfig.txt from Extension module collected  console=${True}  AND  Return From Keyword
    ${status}  ${result}=  Run Keyword And Ignore Error
    ...  Get File From System Module  target_ip="192.168.255.1"  source_path=/ffs/run/swconfig.txt  destination_path=${BTS Files}/  via_ip=${PC_IP2}
    Run Keyword If  '${status}'=='PASS'  Run Keyword  Log  swconfig.txt from Extension module collected  console=${True}
    ...  ELSE  Run Keyword  Log  swconfig.txt could not be retrieved from Extension Module!  console=${True}

Collect RawAlarmHistory
    ${status}  ${result}=  Run Keyword And Ignore Error
    ...  Get File From System Module  source_path=/tmp/RawAlarmHistory.txt  destination_path=${BTS Files}/
    Run Keyword If  '${status}'=='PASS'  Log  RawAlarmHistory.txt from System module collected  console=${True}
    ...  ELSE  Run Keyword  Log  RawAlarmHistory.txt could not be retrieved from System Module! Error: ${result}  console=${True}

Set Additional Ignored Alarms
    [Documentation]
    ...  Keyword Adds Alarms definied as ADDITIONAL_IGNORED_ALARMS to default list of ignored alarms defined under "Siso Check Unexpected Alarms"
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

    ${smods}=    admin.Get Ids For All  SMOD  connection=default
    ${smod2_detected}=  Run keyword and return status  Run keyword if  len(${smods}) == 2
    ...  Set Variable  ${TRUE}
    ...  ELSE
    ...  Siso Synchronize SMODs For Setup Purposes
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
    ${sm_state}=  Run Keyword If  ${modules_check}
    ...  Verify modules SiSo  SMOD  alias=${alias}  scf_check=${FALSE}  expected_states=${smod_expected_states}
    ...  ELSE  Set Variable  ${TRUE}
    ${rf_state}=  Run Keyword If  ${modules_check}
    ...  Verify modules SiSo  RMOD  alias=${alias}  scf_check=${FALSE}  expected_states=${rmod_expected_states}
    ...  ELSE  Set Variable  ${TRUE}
    ${modules_working}=  Evaluate  ${sm_state} and ${rf_state}
    ${LTE_expected_states}=     Get cells expected states    LTE  alias=${alias}
    ${WCDMA_expected_states}=   Get cells expected states  WCDMA  alias=${alias}
    ${GSM_expected_states}=     Get cells expected states    GSM  alias=${alias}
    ${NR_expected_states}=     Get cells expected states    NR  alias=${alias}
    ${LTE_working}=      Run Keyword If  ${cells_check}
    ...  Verify cells SiSo  LTE    scf_check=${False}  alias=${alias}  expected_states=${LTE_expected_states}
    ...  ELSE  Set Variable  ${TRUE}
    ${WCDMA_working}=    Run Keyword If  ${cells_check}
    ...  Verify cells SiSo  WCDMA  scf_check=${False}  alias=${alias}  expected_states=${WCDMA_expected_states}
    ...  ELSE  Set Variable  ${TRUE}
    ${GSM_working}=      Run Keyword If  ${cells_check}
    ...  Verify cells SiSo  GSM    scf_check=${False}  alias=${alias}  expected_states=${GSM_expected_states}
    ...  ELSE  Set Variable  ${TRUE}
    ${NR_working}=      Run Keyword If  ${cells_check}
    ...  Verify cells SiSo  NR   scf_check=${False}  alias=${alias}  expected_states=${NR_expected_states}
    ...  ELSE  Set Variable  ${TRUE}
    ${alarms_status}  ${alarms_msg}=  Run Keyword If  ${alarms_check}  Run Keyword And Ignore Error
    ...  Siso Check Unexpected Alarms  connection=${alias}
    ${statuses_dictionary}=  Create Dictionary  modules_working=${modules_working}  LTE_working=${LTE_working}
    ...  WCDMA_working=${WCDMA_working}  GSM_working=${GSM_working}  NR_working=${NR_working}  alarms_status=${alarms_status}
    ${pretty_statuses}=  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint
    Run keyword if  '${alarms_status}'=='FAIL'  Run Keywords
    ...  Log  Unexpected alarms are present on remote BTS (alias: ${alias})  console=${TRUE}
    ...  AND  Fail  Unexpected alarms are present on remote BTS (alias: ${alias})\n${alarms_msg}

    Start remote Infomodel  remote_host=${remote_host}  bts_host=192.168.255.129  alias=${alias}

    [Teardown]  Run Keyword If
    ...  ${modules_working} and ${LTE_working} and ${WCDMA_working} and ${GSM_working} and ${NR_working} and '${alarms_status}'!='FAIL'
    ...  Set Test Variable  ${${alias}_verification_status}  passed
    ...  ELSE  Fail  Test failed due to failure of ${alias} initial check:\n${pretty_statuses}.\nSkip to teardown!

Start remote Admin
    [Arguments]  ${remote_host}  ${alias}
    ${remote_taf_admin_started}=  Run keyword and return status
    ...  admin.Setup Admin  admin_api_log_dir=${BTS Files}  remote_host=${remote_host}  bts_host=192.168.255.129
    ...  bts_port=443  use_ssl=TRUE  update_interval=1000  name=${alias}
#    ${remote_ute_admin_started}=  Run keyword and return status
#    ... admin.Setup Admin  admin_api_log_dir=${BTS Files}  remote_host=${remote_host}  bts_host=192.168.255.129
#    ...  bts_port=443  use_ssl=TRUE  update_interval=1000  alias=${alias}
#    Run Keyword If  ${remote_taf_admin_started} and ${remote_ute_admin_started}  Set Test Variable  ${${alias}_admin_started}  ${TRUE}
    Run Keyword If  ${remote_taf_admin_started}  Set Test Variable  ${${alias}_admin_started}  ${TRUE}

Start remote Infomodel
    [Arguments]  ${remote_host}  ${bts_host}  ${alias}
    Setup infomodel  alias=${alias}  remote_host=${remote_host}  address=${bts_host}  port=443  use_ssl=True  admin_api_log_dir=${BTS Files}/
    ${remote_infomodel_started}=  Run Keyword And Return Status  Connect Infomodel  alias=${alias}
    Set Test Variable  ${${alias}_infomodel_started}  ${remote_infomodel_started}

Remote Test Line Teardown
    [Arguments]  ${alias}  ${verify_states_stability}=${False}
    Log  Remote Test Line Teardown (alias: ${alias})  console=${True}
    ${ims_path}=  Set variable  ${BTS Files}/IM/${alias}.ims2
    Run keyword if  ${${alias}_admin_started}    admin.Collect Infomodel Log From Current Session  target_file_name=${ims_path}
    ...  timeout=300  connection=${alias}
    Run keyword if  ${${alias}_infomodel_started} and ${verify_states_stability} and '${${alias}_verification_status}'=='passed'
    ...     Verify Remote BTS States After Test Case  ims_path=${ims_path}  alias=${alias}
    Run keyword if  ${${alias}_infomodel_started}  Teardown Infomodel  alias=${alias}
    Run keyword if  ${${alias}_SMOD2_syslog_started}       Collect syslog from ${alias}_SMOD2
    Run keyword if  ${${alias}_syslog_started}       Collect syslog from ${alias}
    Run Keyword If  ${${alias}_admin_started}    Run Keyword And Ignore Error  admin.Teardown Admin  connection=${alias}
#    Run Keyword If  ${${alias}_admin_started}  Run Keywords
#    ...  Run Keyword And Ignore Error  admin.Teardown Admin  connection=${alias}
#    ...  AND  Run Keyword And Ignore Error  Teardown Admin  alias=${alias}

Verify Remote BTS States After Test Case
    [Arguments]  ${ims_path}  ${alias}
    Log  Verify remote BTS states after test case (alias: ${alias})  console=${True}

    ${alarms_status}  ${alarms_msg}=  Run Keyword And Ignore Error  Siso Check Unexpected Alarms  connection=${alias}
    Run keyword if  '${alarms_status}'=='FAIL'  Fail  Critical fail while checking alarms: ${alarms_msg}  console=${TRUE}

    ${remote_SMODS}=    admin.Get Ids For All  SMOD  connection=${alias}
    ${remote_RMODS}=    admin.Get Ids For All  RMOD  connection=${alias}
    ${remote_CELLS_L}=  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}  connection=${alias}
    ${remote_CELLS_W}=  admin.Get Ids For All  WNCEL  connection=${alias}
    ${remote_CELLS_G}=  admin.Get Ids For All  GNCEL  connection=${alias}

    Initialize ims2 validator   ${ims_path}  alias=${alias}
    FOR  ${smod}  IN  @{remote_SMODS}
        Log  ${smod}
        Siso Fail if ims2 object change  ${smod}  administrativeState   Unlocked
        Siso Fail if ims2 object change  ${smod}  operationalState      Enabled
        Siso Fail if ims2 object change  ${smod}  availabilityStatus    Online
    END
    FOR  ${rmod}  IN  @{remote_RMODS}
        Log  ${rmod}
        Siso Fail if ims2 object change  ${rmod}  administrativeState   Unlocked
        Siso Fail if ims2 object change  ${rmod}  operationalState      Enabled
        Siso Fail if ims2 object change  ${rmod}  availabilityStatus    Online
        Siso Fail if ims2 object change  ${rmod}  blockingState         Unblocked
    END
    FOR  ${cell}  IN  @{remote_CELLS_L}
        Log  ${cell}
        Siso Fail if ims2 object change  ${cell}  administrativeState   Unlocked
        Siso Fail if ims2 object change  ${cell}  operationalState      Enabled
        Siso Fail if ims2 object change  ${cell}  availabilityStatus    Online
        Siso Fail if ims2 object change  ${cell}  blockingState         Unblocked
    END
    FOR  ${cell}  IN  @{remote_CELLS_W}
        Siso Fail if ims2 object change  ${cell}  operationalState      Enabled
        Siso Fail if ims2 object change  ${cell}  availabilityStatus    Online
        Siso Fail if ims2 object change  ${cell}  blockingState         Unblocked
        Siso Fail if ims2 object change  ${cell}  usageState            Active
    END
    FOR  ${cell}  IN  @{remote_CELLS_G}
        Siso Fail if ims2 object change  ${cell}  administrativeState   Unlocked
        Siso Fail if ims2 object change  ${cell}  operationalState      Enabled
        Siso Fail if ims2 object change  ${cell}  availabilityStatus    Online
        Siso Fail if ims2 object change  ${cell}  blockingState         Unblocked
        Siso Fail if ims2 object change  ${cell}  usageState            Active
    END
    Siso Fail if ims2 event occur   event=reset  alias=${alias}
    Siso Fail if ims2 event occur   event=create /MRBTS-*/RAT-*/FRI-*/ALARM-* [alarmSeverity=Critical]  alias=${alias}

Verify Configuration And Set Up Remote Test Line
    [Documentation]
    ...  Helper for KW Remote Test Line Setup which checks if selected test line is well configured
    ...  (exists in given dictionary and has the key
    [Arguments]  ${modules_check}  ${cells_check}  ${alarms_check}  ${alias}
    ${SMOD1_configured}  ${pc_ip1}=  Run keyword and ignore error  Get from dictionary  ${REMOTE_TESTLINES['${alias}']}  PC_IP1
    Run Keyword If  '${SMOD1_configured}'=='FAIL'  Run Keywords
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
    Run Keyword And Ignore Error  _Siso Get Snapshot Via Admin API   timeout=${ADMIN_SNAPSHOT_TIMEOUT_MASTER}  alias=${alias}
    ${SMOD2_configured}  ${pc_ip2}=  Run keyword and ignore error  Get from dictionary  ${REMOTE_TESTLINES['${alias}']}  PC_IP2
    Run Keyword If  '${SMOD2_configured}'=='FAIL'  Return From Keyword
    Siso Admin Get Snapshot Remotely Via Admin API  bts_host=192.168.255.119  remote_host=${pc_ip2}  snapshot_timeout=${ADMIN_SNAPSHOT_TIMEOUT_ESM}
    ...                                             alias=${alias}_SMOD2

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
    ...  |                                                   availabilityStatus = Degraded, blockingState = Unblocked",
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
    ...  |     "parameters":{ "cells_LTE_expected_states": "administrativeState = Unlocked, operationalState = Enabled,
    ...  |                                                  availabilityStatus = Degraded, blockingState = Unblocked",
    ...  |                    "cells_NR_expected_states":  "administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online,
    ...  |                                                  blockingState=Unblocked",
    ...  |                    "cells_WCDMA_expected_states": "operationalState = Enabled, availabilityStatus = Degraded, blockingState = Unblocked,
    ...  |                                                    usageState = Active",
    ...  |                    "cells_GSM_expected_states": "administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Degraded,
    ...  |                                                  blockingState=Unblocked, usageState=Active",
    ...  |                    "DSC_SMOD_expected_states": "administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online,
    ...  |                                                 blockingState=Unblocked, usageState=Active"
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

Verify modules states SiSo
    [Documentation]
    ...
    ...
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    [Arguments]  ${alias}=default  ${scf_check}=${TRUE}
    ${sm_state}=  Verify modules SiSo  SMOD  alias=${alias}  scf_check=${scf_check}
    ${rf_state}=  Verify modules SiSo  RMOD  alias=${alias}  scf_check=${scf_check}
    ${are_states_as_expected}=  Evaluate  ${sm_state} and ${rf_state}
    [Return]  ${are_states_as_expected}

Verify modules SiSo
    [Documentation]
    ...  Verify modules states
    ...  Default expected states are defined in the Variables section in hran_frame_sbts.
    ...  If `scf_check` is set to True, the number of modules will be compared with the number of respective objects in SCF.
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ...
    ...  | Parameter       | Mandatory | Description                                                                            |
    ...  | class_name       | Yes       | Class name for which states should be checked [SMOD, RMOD]                              |
    ...  | expected_states | No        | Expected states as string, e.g., "administrativeState=Unlocked, operationalState=Enabled" |
    ...

    [Arguments]  ${class_name}  ${expected_states}=${${class_name}_expected_states}  ${alias}=default  ${scf_check}=${TRUE}
    ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=  Get objects with expected states SiSo  ${expected_states}  ${class_name}  alias=${alias}

    Run keyword if  '${check_status}'=='FAIL'  Run keywords  Log  At least one ${class_name} module has state other than expected.  console=${TRUE}
    ...  AND  Return from keyword  ${FALSE}

    ${count_status}=  Run keyword if  ${scf_check}  Siso Check SCF count  ${class_name}  ${RUNTIME_MODS}
    ...  ELSE  Set variable  ${TRUE}

    Run keyword if  ${count_status}  Log  All states of ${class_name} modules are as expected.  console=${TRUE}
    ...  ELSE  Log  At least one ${class_name} module has state other than expected.  console=${TRUE}
    [Return]  ${count_status}


Verify cells SiSo
    [Documentation]
    ...  Verify cells states
    ...  Expected states in default are setted from variables section in hran_frame_sbts
    ...  If scf_check==True, cells count will be verified with scf
    ...
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
    ${check_status}  ${RUNTIME_CELLS}  ${ALL_CELLS}=  Get objects with expected states SiSo  ${expected_states}  ${technology_sign}CEL
    ...                                                                                       alias=${alias}

    Run keyword if  '${check_status}'=='FAIL'  Run keywords  Log  At least one ${technology} cell has state other than expected.  console=${TRUE}
    ...  AND  Return from keyword  ${FALSE}

    ${count_status}=  Run keyword if  ${scf_check}  Siso Check SCF count  ${technology}  ${ALL_CELLS}
    ...  ELSE  Set variable  ${TRUE}

    Run keyword if  ${count_status}  Log  All ${technology} cells are in expected state.  console=${TRUE}
    ...  ELSE  Log  All ${technology} cells are in expected state but the number of cells defined in SCF differs from reported by Admin API.
    ...             console=${TRUE}

    [Return]  ${count_status}

Get objects with expected states SiSo
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
    ...    ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=  Get objects with expected states  operationalState=Enabled, availabilityStatus=Online  ALD

    [Arguments]  ${expected states}  ${class name}  ${alias}=default
    ${class_ids}=  admin.Get Ids For All  ${class name}  search_for_iot_cells=${True}  connection=${alias}
    ${matching_objects}=  Create list
    ${matching_statuses}=  Create list
    FOR  ${item_id}  IN  @{class_ids}
        ${status}  ${item_parameters}=  Run keyword and ignore error  Check object expected states  ${class name}  ${item_id}  ${expected states}
        ...                                                                                         timeout=20  alias=${alias}
        Run keyword if  '${status}'=='PASS'  Run keywords
        ...  Append to list  ${matching_objects}  ${item_parameters}  AND  Append to list  ${matching_statuses}  PASS
        ${iot_cell}=  Run keyword and return status  Should match regexp  ${item_id}  .*BTS_CONF.*SCF.*LNCEL
        Run keyword if  "${status}"=="FAIL" and ${iot_cell}  Append to list  ${matching_statuses}  PASS
        ${status}  ${item_parameters}=  Run keyword if  "${status}"=="FAIL" and not ${iot_cell}
        ...  Run keyword and ignore error  admin.Assert  ${class name}  ${item_id}  availabilityStatus=regex"(?i)Not.?Installed"
        ...  timeout=20  connection=${alias}
        ...  ELSE  Create list  PASS  NONE
        Run keyword if  "${status}"=="FAIL" and not ${iot_cell}  Append to list  ${matching_statuses}  FAIL
    END
    ${status}=  evaluate  "FAIL" if len(${class_ids})!=0 and "FAIL" in "${matching_statuses}" else "PASS"
    [Return]  ${status}  ${matching_objects}  ${class_ids}

Assert parameters for any
    [Arguments]  ${class_name}  ${expected_states}  ${alias}=default
    Should not be empty  ${expected_states}
    ${item_ids}  Get ids for all  ${class_name}  search_for_iot_cells=${True}
    FOR  ${item_id}  IN  @{item_ids}
        ${check_status}  Run keyword and return status  Check object expected states  ${class_name}  ${item_id}  ${expected_states}  alias=${alias}
        Return from keyword if  ${check_status}
    END
    Fail  No one item has expected states!

Assert parameters for every
    [Arguments]  ${class_name}  ${expected_states}  ${alias}=default
    Should not be empty  ${expected_states}
    ${item_ids}  admin.Get ids for all  ${class_name}  search_for_iot_cells=${True}  connection=${alias}
    FOR  ${item_id}  IN  @{item_ids}
        ${check_status}  Run keyword and return status  Check object expected states  ${class_name}  ${item_id}  ${expected_states}  alias=${alias}
        Run keyword if  not ${check_status}  Fail  At least one item has states other than expected!
    END

Assert parameters for no
    [Arguments]  ${class_name}  ${expected_states}  ${alias}=default
    Should not be empty  ${expected_states}
    ${item_ids}  admin.Get ids for all  ${class_name}  search_for_iot_cells=${True}  connection=${alias}
    FOR  ${item_id}  IN  @{item_ids}
        ${check_status}  Run keyword and return status  Check object expected states  ${class_name}  ${item_id}  ${expected_states}  alias=${alias}
        Run keyword if  ${check_status}  Fail  At least one item has expected states!
    END

Check object expected states
    [Arguments]  ${class name}  ${item_id}  ${expected states}  ${timeout}=20  ${alias}=default
    ${expected states}  Split string  ${expected states}  ,${SPACE}
    ${parameters}  admin.Get parameters for  ${class name}  ${item_id}  timeout=${timeout}  connection=${alias}
    FOR  ${state}  IN  @{expected states}
        ${stateName}  ${stateValue}  Split string  ${state}  =
        ${no_state_in_parameters}  Run keyword and return status  Dictionary should not contain key  ${parameters}  ${stateName}
        ${is_online}  Run keyword and return status  Should contain  ${stateValue}  nline
        Continue for loop if  ${no_state_in_parameters} and '${stateName}'=='availabilityStatus' and ${is_online}
        Run keyword if  ${no_state_in_parameters}  Fail  'Parameter "${stateName}" not present. Please check parameter name.'
        ${assert_status}  ${assert_output}  Run keyword and ignore error  admin.Assert  ${class name}  ${item_id}  ${state}
        ...  timeout=${timeout}  connection=${alias}
        Run keyword if  '${assert_status}'=='FAIL'  Fail  ${assert_output}
    END
    [Return]  ${parameters}

Set SCF system modules count and verify product numbers SiSo
    [Documentation]
    ...  Keyword for checking system modules amount and validating its runtime product numbers against these in SCF
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** ---

    ${scf_smods}=  hran_file_operations.Get System Modules
    ${SCF_COUNT_SMOD}=  Get length  ${scf_smods}
    Set test variable  ${SCF_COUNT_SMOD}
    Set test variable  ${scf_smods}

    ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=  Get objects with expected states SiSo  ${SMOD_expected_states}  SMOD
    Run keyword if  '${check_status}'=='PASS'
    ...  Siso Validate Runtime Modules Product Numbers Against scf  ${RUNTIME_MODS}  ${scf_smods}

Set SCF radio modules count and verify product numbers Siso
    [Documentation]
    ...  Keyword for checking radio modules amount and validating its runtime product numbers against these in SCF
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** ---

    ${scf_rmods}=  hran_file_operations.Get Radios
    ${SCF_COUNT_RMOD}=  Get length  ${scf_rmods}
    Set test variable  ${SCF_COUNT_RMOD}

    ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=  Get objects with expected states Siso  ${RMOD_expected_states}  RMOD
    Run keyword if  '${check_status}'=='PASS'
    ...  Siso Validate Runtime Modules Product Numbers Against scf  ${RUNTIME_MODS}  ${scf_rmods}

Siso Check Remote Host Disk Space
    [Documentation]
    ...  Copy of KW 'Check Local Host Disk Space' adapted to run on
    ...  remote machine via SSH protocol.
    ...
    ...  *AUTHOR*  patryk.furman@nokia.com
    ...  *MAINTAINER*  daniel.bartkowiak@nokia.com
    ...
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
    _Siso SSHLibrary_Login_multiway  ${ssh_username}  ${ssh_password}
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

Check Local Host Disk Space
    [Documentation]
    ...  Checks if there is a minimal required available disk space in given directory, sets test as norun if not
    ...  and skips to test teardown. Also dumps `df` output as log from test for future reference.
    ...
    ...  *AUTHOR*  dariusz.suszczewicz@nokia.com
    ...  *MAINTAINER*  daniel.bartkowiak@nokia.com
    ...
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

Collect Snapshot And TRS
    Siso Admin Get Snapshot
    Run keyword if  ${SMOD2_exists}  Siso Admin Get Snapshot for ESM
    Siso Collect Extended TRS Logs
    Collect Snapshot From Remote Test Lines

Siso Fail if ims2 event occur
    [Documentation]
    ...  Validate and fail if event occured
    ...
    ...  | **Author:** sebastian.burniak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com
    ...
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
    ...     Siso Fail if ims2 occur  ${alias}
    ...
    [Arguments]  ${event}  ${alias}=DSC
    Add expected ims2 event  ${event}  alias=${alias}
    ${event_triggered}=  Run keyword and return status  Validate ims2  alias=${alias}
    Run keyword if  ${event_triggered}   Fail  DSC: ${event} event has been found

Siso Fail if ims2 object change
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
    ...
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Initialize ims2 validator   ${BTS Files}/IM/${alias}.ims2  alias=${alias}
    ...     Siso Fail if ims2 object change  ${SMOD_DISTNAME}  administrativeState   Unlocked  ${alias}
    ...
    [Arguments]  ${object}  ${parameter}  ${value}  ${alias}=DSC
    Add expected ims2 event     change ${object} [stateInfo.${parameter}: ${value}->!${value}]  alias=${alias}
    ${status}  Run keyword and return status  Validate ims2  alias=${alias}
    Run keyword if  ${status}  Fail  DSC: ${object} state was changed (${parameter}!=${value})

Siso Admin Get Snapshot
    [Documentation]
    ...    Try to collect snapshot via taf library "Collect Snapshot". If this operation does not succeed, as a workaround
    ...    snapshot is taken using library taf.transport.ssh
    ...
    ...  | Parameter              | Man.  | Default                              | Description                             |
    ...  | snapshot_timeout       | No    | ${ADMIN_SNAPSHOT_TIMEOUT_MASTER}     | timeout for collect snapshot via Admin   |
    ...
    ...    *AUTHOR*
    ...    andrzej.cichon@nokia.com
    ...    *MAINTAINER*
    ...    daniel.bartkowiak@nokia.com
    [Arguments]  ${snapshot_timeout}=${ADMIN_SNAPSHOT_TIMEOUT_MASTER}
    Log    Collecting snapshot.    console=${True}
    ${snapshot_collected}=    Run Keyword And Return Status    _Siso Get Snapshot Via Admin API  ${snapshot_timeout}
    Run Keyword If    ${snapshot_collected}    Run Keywords
    ...    Log    Snapshot collected!    console=${True}
    ...    AND    Return From Keyword
    ${snapshot_collected}=    Run Keyword And Return Status    _Siso Get Snapshot SSH From MSM
    Run Keyword If    ${snapshot_collected}    Run Keywords
    ...    Log    Snapshot collected!    console=${True}
    ...    AND    Return From Keyword
    Log    Snapshot not collected!    console=${True}

Siso Admin Get Snapshot for ESM
    [Documentation]
    ...    Try to collect snapshot for ESM via taf library 'Collect Snapshot'. If this operation does not succeed, as a workaround
    ...    snapshot is taken using taf.transport.ssh .
    ...
    ...  | Parameter              | Man.  | Default                              | Description                              |
    ...  | snapshot_timeout       | No    | ${ADMIN_SNAPSHOT_TIMEOUT_ESM}        | timeout for collect snapshot via Admin   |
    ...
    ...    *AUTHOR*
    ...    alona.kulieshova@nokia.com
    [Arguments]  ${snapshot_timeout}=${ADMIN_SNAPSHOT_TIMEOUT_ESM}
    Log    Collecting snapshot.    console=${True}

    ${snapshot_collected}=    Run Keyword And Return Status    _Siso Get ESM Snapshot Via Admin API  ${snapshot_timeout}
    Run Keyword If    ${snapshot_collected}    Run Keywords
    ...    Log    ESM snapshot collected!    console=${True}
    ...    AND    Return From Keyword

    ${snapshot_collected}=    Run Keyword And Return Status    _Siso Get Snapshot SSH From ESM
    Run Keyword If    ${snapshot_collected}    Run Keywords
    ...    Log    Snapshot from ESM Via SSH collected!    console=${True}
    ...    AND    Return From Keyword

    Log    ESM snapshot not collected!    console=${True}

_Siso Get ESM Snapshot Via Admin API
    [Arguments]     ${snapshot_timeout}=${ADMIN_SNAPSHOT_TIMEOUT_ESM}
    Log    Trying to collect snapshot for ESM via Admin API    console=${True}
    ${snapshot_collected}=  Run Keyword And Return Status
    ...  _Siso Helper For ESM Snapshot Via Admin API  bts_host=192.168.255.119  snapshot_timeout=${snapshot_timeout}
    Return From Keyword If  ${snapshot_collected}
    ${snapshot_collected}=  Run Keyword And Return Status
    ...  _Siso Helper For ESM Snapshot Via Admin API  bts_host=192.168.255.129  snapshot_timeout=${snapshot_timeout}
    Should Be True  ${snapshot_collected}  Failed to collect snapshot for ESM via Admin API

_Siso Helper For ESM Snapshot Via Admin API
    [Arguments]   ${bts_host}  ${snapshot_timeout}=${ADMIN_SNAPSHOT_TIMEOUT_ESM}
    Siso Admin Get Snapshot Remotely Via Admin API  bts_host=${bts_host}  remote_host=${PC_IP2}
    ...  snapshot_timeout=${snapshot_timeout}  alias=ESM

Siso Admin Get Snapshot Remotely Via Admin API
    [Arguments]    ${bts_host}  ${remote_host}  ${snapshot_timeout}  ${alias}
    Run Keyword And Ignore Error  admin.Setup Admin  admin_api_log_dir=${BTS Files}  bts_host=${bts_host}  remote_host=${remote_host}  name=${alias}
    _Siso Get Snapshot Via Admin API   ${snapshot_timeout}  alias=${alias}
    admin.Teardown Admin  connection=${alias}

_Siso Get Snapshot Via Admin API
    [Arguments]  ${timeout}=600  ${alias}=default
    Log    Trying to collect snapshot via Admin API (alias: ${alias})    console=${True}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}_${month}_${day}_${hour}_${min}
    ${suffix_dict}    Create Dictionary  ${alias}=snapshot_${alias}.zip    default=snapshot.zip
    ${suffix}=    Get From Dictionary    ${suffix_dict}    ${alias}
    ${target_file_name}=    Set Variable    ${BTS Files}/${timestamp}_${suffix}
    admin.Collect Snapshot    target_file_name=${target_file_name}  timeout=${timeout}  connection=${alias}

_Siso Get Snapshot SSH From ESM
    [Documentation]
    ...  KW triggers snapshot collection from CLI.
    ...  Copy full log to desired destination under 'local_file_path'
    ...  At the end log is removed from sm
    ...
    ...  *AUTHOR*  daniel.bartkowiak@nokia.com
    ...
    [Arguments]  ${esm_ip}=${SMOD2['IP']}  ${user}=${SMOD2['USERNAME']}  ${pass}=${SMOD2['PASSWORD']}  ${local_file_path}=${BTS Files}
    ...  ${remote_ip}=${PC_IP2}  ${remote_user}=ute  ${remote_pass}=ute
    Log  Trying to collect ESM snapshot via ssh  console=${TRUE}
    ssh.Connect To  hostname=${remote_ip}  username=${remote_user}  password=${remote_pass}  alias=slave_vm
    ssh.Connect To  hostname=${esm_ip}  username=${user}  password=${pass}  proxy=slave_vm
    ssh.Execute  nc localhost 15007 <<< "log -a -z /ffs/run/trs_data/db/esm_snapshot_ssh.zip" 2>/dev/null
    ssh.Download File  /ffs/run/trs_data/db/esm_snapshot_ssh.zip  ${local_file_path}/esm_snapshot_ssh.zip
    ssh.Execute  rm /ffs/run/trs_data/db/esm_snapshot_ssh.zip
    [Teardown]  Run Keywords  ssh.Disconnect  AND  ssh.Disconnect  connection=slave_vm

_Siso Get Snapshot SSH From MSM
    [Documentation]
    ...  KW triggers snapshot collction from CLI.
    ...  Copy full log to desired destination under 'local_file_path'
    ...  At the end log is removed from sm
    ...
    ...  *AUTHOR*  daniel.bartkowiak@nokia.com
    ...
    [Arguments]  ${msm_ip}=${SMOD1['IP']}  ${user}=${SMOD1['USERNAME']}  ${pass}=${SMOD1['PASSWORD']}  ${local_file_path}=${BTS Files}
    Log  Trying to collect MSM snapshot via ssh  console=${TRUE}
    ssh.Connect To  hostname=${msm_ip}  username=${user}  password=${pass}
    ssh.Execute  nc localhost 15007 <<< "log -a -z /ffs/run/trs_data/db/msm_snapshot_ssh.zip" 2>/dev/null
    ssh.Download File  /ffs/run/trs_data/db/msm_snapshot_ssh.zip  ${local_file_path}/msm_snapshot_ssh.zip
    ssh.Execute  rm /ffs/run/trs_data/db/msm_snapshot_ssh.zip
    [Teardown]  ssh.Disconnect

Siso Collect Extended TRS Logs
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

Siso Clean up directory
    [Arguments]  ${clean_directory}  ${older_than_min}  ${alias}=local  &{configuration}
    Log  Removing files older than ${older_than_min} min from "${clean_directory}" on ${alias}  level=INFO  console=${TRUE}
    ${command}=  Set Variable
    ...  if [ "$(ls -A ${clean_directory})" ]; then find ${clean_directory}/* -maxdepth 0 -mmin +${older_than_min} -exec rm -rf {} \\; ; fi
    ${cleaning_rc}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Siso Execute Local Command  ${command}  ELSE
    ...  Siso Execute Remote Command  ${command}  ${alias}  &{configuration}
    ${result}=  Run Keyword And Return Status  Should Be Equal
    ...  ${cleaning_rc}  ${0}  msg=RC of operation clean "${clean_directory}" on ${alias} is not equal 0
    run keyword if  ${result}
    ...  Log  "${clean_directory}" on ${alias} cleaned  level=INFO  console=${TRUE}  ELSE
    ...  Log   Failed to clean "${clean_directory}" on ${alias}  level=INFO  console=${TRUE}
    [Return]  ${result}

Siso Execute Local Command
    [Arguments]  ${command}
    ${command_rc}=  Run And Return Rc  ${command}
    [Return]  ${command_rc}

Siso Execute Remote Command
    [Arguments]  ${command}  ${index_or_alias}  &{configuration}
    _Siso Remote Command Setup  ${index_or_alias}  &{configuration}
    ${command_rc}=  SSHLibrary.Execute Command  ${command}  return_stdout=False  return_rc=True
    [Teardown]  _Siso Remote Command Teardown
    [Return]  ${command_rc}

_Siso Remote Command Setup
    [Arguments]  ${index_or_alias}  &{configuration}
    ${check_connection}=  SSHLibrary.Get Connection  ${index_or_alias}
    Run Keyword If  ${check_connection.index}
    ...  SSHLibrary.Switch Connection  ${index_or_alias}  ELSE
    ...  SSHLibrary.Open Connection  host=${configuration["host_ip"]}  port=${configuration["ssh_port"]}
    _Siso SSHLibrary_Login_multiway  ${configuration["ssh_username"]}  ${configuration["ssh_password"]}

_Siso Remote Command Teardown
    SSHLibrary.Close Connection

_Siso SSHLibrary_Login_multiway
    [Arguments]  ${username}  ${password}
    ${status}=  Run keyword and return status  SSHLibrary.Login  ${username}  ${password}
    Return from keyword if  ${status}
    ${status}=  Run keyword and return status  SSHLibrary.Login with public key  ${username}
    ...  /home/${username}/.ssh/id_rsa
    Run Keyword If  not ${status}  Fail  Remote connection unavailable

Siso Kill processes remained after files deletion on VMs /home partition
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
    ...  | Kill processes remained after files deletion on VMs /home partition | Extension | host_ip=10.42.35.151 | ssh_port=22 | ssh_username=ute
    ...                                                                        | ssh_password=ute |

    [Arguments]  ${alias}=local  &{configuration}
    Log  Kill processes remained after files deletion on /home partition  console=${TRUE}
    ${pids_cmd}=  Set Variable  lsof | grep -P '/home(?!.*(chrome|remote-stderr|remote-stdout)).*deleted' | awk '!seen[$2]++ {print $2}'
    ${pids_str}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Siso Execute Local Command And Return Output  ${pids_cmd}  ELSE
    ...  Siso Execute Remote Command And Return Output  ${pids_cmd}  ${alias}  &{configuration}
    @{pids}=  Split String  ${pids_str}
    ${looped_ps_cmd}=  Create Dictionary  cmd=ps -o comm= -p  args=@{pids}
    Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Siso Execute Local Command In Loop  ${looped_ps_cmd}  ELSE
    ...  Siso Execute Remote Command In Loop  ${looped_ps_cmd}  ${alias}  &{configuration}
    ${looped_kill_cmd}=  Create Dictionary  cmd=kill -9  args=@{pids}
    ${rc}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Siso Execute Local Command In Loop  ${looped_kill_cmd}  ELSE
    ...  Siso Execute Remote Command In Loop  ${looped_kill_cmd}  ${alias}  &{configuration}
    Run keyword if  ${rc}==${0}
    ...  Log  All processes remained after files deletion have been killed  console=${TRUE}  ELSE
    ...  Log  Failed to kill processes remained after files deletion        console=${TRUE}

Siso Execute Local Command And Return Output
    [Arguments]  ${command}
    ${command_stdout}=  Run  ${command}
    [Return]  ${command_stdout}

Siso Execute Remote Command And Return Output
    [Arguments]  ${command}  ${index_or_alias}  &{configuration}
    _Siso Remote Command Setup  ${index_or_alias}  &{configuration}
    ${command_stdout}=  SSHLibrary.Execute Command  ${command}  return_stdout=True  return_rc=False
    [Teardown]  _Siso Remote Command Teardown
    [Return]  ${command_stdout}

Siso Execute Local Command In Loop
    [Arguments]  ${looped_command}
    ${terminal_command_rc}=  _Siso Execute Command In Loop Via  Run And Return Output And Rc  ${looped_command}
    [Return]  ${terminal_command_rc}

_Siso Execute Command In Loop Via
    [Arguments]  ${keyword}  ${looped_command}  @{keyword_args}  &{keyword_kwargs}
    ${terminal_command_rc}=  Set Variable  0
    FOR  ${arg}  IN  @{looped_command["args"]}
        ${command}=  Catenate  ${looped_command["cmd"]}  ${arg}
        ${command_stdout}  ${command_rc}=  Run Keyword  ${keyword}  ${command}  @{keyword_args}  &{keyword_kwargs}
        Log  ${command_stdout}
        ${terminal_command_rc}=  Set Variable If  ${command_rc} != 0  ${command_rc}  ${terminal_command_rc}
    END
    [Return]  ${terminal_command_rc}

Siso Execute Remote Command In Loop
    [Arguments]  ${looped_command}  ${index_or_alias}  &{configuration}
    _Siso Remote Command Setup  ${index_or_alias}  &{configuration}
    ${terminal_command_rc}=  _Siso Execute Command In Loop Via  SSHLibrary.Execute Command  ${looped_command}  return_stdout=True  return_rc=True
    [Teardown]  _Siso Remote Command Teardown
    [Return]  ${terminal_command_rc}

Siso Hran_ta Preconditions
    Log  Common Test Setup  level=INFO  console=${TRUE}
    Siso Get Workspace Version
    Siso Create Dirs For Logs

Siso Hran_ta Postconditions
    Log  End of Common Test Teardown  level=INFO  console=${TRUE}

Siso Get Workspace Version
    ${hran_legacy_path}=  Set variable  /home/ute/btsauto/hran_ta
    ${hran_taf_path}=  Set Variable  /home/ute/MN/UTE/hran_ta

    ${USE_GIT}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${hran_legacy_path}/.git

    ${hran_path}=  Set Variable If  '${USE_GIT}' == '${False}'  ${hran_taf_path}  ${hran_legacy_path}

    Log  Default repository path is: ${hran_path}  level=INFO
    Run keyword if  ${USE_GIT}  Run keyword
    ...  Siso Find workspace version and set tags
    ...  git --git-dir=/home/ute/btsauto/hran_ta/.git/ describe --always --tags | awk -F '[/|-g]' '{print $NF}' | cut -c 1-8
    ...  ELSE
    ...  Siso Find workspace version and set tags
    ...  git --git-dir=/home/ute/MN/UTE/hran_ta/.git/ describe --always --tags | awk -F '[/|-g]' '{print $NF}' | cut -c 1-8

Siso Find workspace version and set tags
    [Arguments]  ${command}
    ${workspace_version} =  OperatingSystem.run  ${command}
    Log  Online workspace version is ${workspace_version}  level=DEBUG  console=${TRUE}
    Set tags  Online workspace version = ${workspace_version}
    [Return]  ${workspace_version}

Siso Create dirs for logs
    [Documentation]
    ...  *AUTHOR* sebastian.burniak@nokia.com
    Siso Create 'Test Results Dir' and Set Test Variable
    Siso Create 'BTSFiles' in '${Test Results Dir}' And Set Test Variable
    Siso Create 'TestFiles' in '${Test Results Dir}' And Set Test Variable
    Siso Create 'UDPLogs' in '${Test Results Dir}' And Set Test Variable
    Siso Create Temp Logs Dir And Set Test Variable

Siso Create 'Test Results Dir' and Set Test Variable
    ${testtimestamp}=    OperatingSystem.Run    date +%F_%H-%M-%S
    ${testresultspath}=    OperatingSystem.Join Path    ${OUTPUT DIR}    ${testtimestamp}_TEST-${TEST NAME}
    Create Directory    ${testresultspath}
    Set Test Variable    ${Test Results Dir}    ${testresultspath}
    Log  'Test Results Dir' created: ${Test Results Dir}  level=DEBUG  console=${TRUE}

Siso Create '${dirname}' in '${rootdir}' And Set Test Variable
    ${dirpath}=    OperatingSystem.Join Path    ${rootdir}    ${dirname}
    Create Directory    ${dirpath}
    Set Test Variable    ${${dirname}}    ${dirpath}
    Log  '${dirname}' created: ${dirpath}  level=DEBUG

Siso Create Temp Logs Dir And Set Test Variable
    ${test_timestamp}=  OperatingSystem.Run  date +%F_%H-%M-%S
    ${TEST NAME WITHOUT BRACKETS}=  Replace String  ${TEST NAME}  [1]  _1_
    ${joined_path}=  OperatingSystem.Join Path  ${TEMP_LOGS_DIR}  ${test_timestamp}_TEST-${TEST NAME WITHOUT BRACKETS}
    Set Test Variable  ${TEMP_LOGS_DIR}  ${joined_path}
    Log  Temp logs Dir created: ${TEMP_LOGS_DIR}  level=DEBUG

Siso Kill process by name
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
    ...  AND  _Siso SSHLibrary_Login_multiway  ${configuration["ssh_username"]}  ${configuration["ssh_password"]}
    ...  AND  SSHLibrary.Execute Command  ${kill_cmd}  return_stdout=${FALSE}
    ...  AND  SSHLibrary.Close Connection
    [Return]  ${TRUE}

Siso Synchronize SMODs For Setup Purposes
    [Arguments]  ${alias}=default
    ${neighbor_dn}=  admin.Get Managed Objects  NEIGHBOR_NODE_R  connection=${alias}
    ${sync_status}=    Run keyword and return status  admin.Start Sync    ${neighbor_dn[0]['distName']}    connection=${alias}
    Run keyword if    ${sync_status}    Run Keywords
    ...  Log  Synchronization succeeded    console=${TRUE}
    ...  AND  Return From Keyword  ${TRUE}
    ...  ELSE    Fail    Synchronization failed

Siso Get commissioning path
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
    ...  *Maintainer*  daniel.bartkowiak@nokia.com
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
        Log to console     Trying to find scf for ${product} (${filename})
        ${commissioning}=  Siso Find commissioning with filename  ${filename}
        ${is_not_empty}=   Run keyword and return status  Should Not Be Empty  ${commissioning}
        Run keyword if  ${is_not_empty}  Return from keyword  ${commissioning}
    END
    [Return]  ${None}

Siso Find commissioning with filename
    [Documentation]
    ...
    ...  Find commissioning in testline configuration directory
    ...  HW_LOCATION_CODE and TESTLINE_NAME will be provided by hran_frame_sbts
    ...
    ...  *Author*  jaroslaw.piszczala@nokia.com
    ...  *Maintainer*  daniel.bartkowiak@nokia.com
    ...
    [Arguments]  ${filename}  ${root}=/home/ute/btsauto/hran_ta/config  ${scf_dir}=commissioning
    ${path}=  Set variable  ${root}/${HW_LOCATION_CODE}/${TESTLINE_NAME}/${scf_dir}/${filename}.xml
    ${is_existing}=  Run keyword and return status  Should Exist  ${path}
    Return from keyword if  ${is_existing}  ${path}
    [Return]  ${None}

Siso Validate Runtime Modules Product Numbers Against scf
    [Documentation]
    ...
    ...
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    [Arguments]  ${runtime modules}  ${scf modules}

    ${runtime mods mapping}=  _Siso Extract Modules Product Codes  ${runtime modules}  productCode  id
    ${scf mods mapping} =  _Siso Extract Modules Product Codes  ${scf modules}  prodCodePlanned  distName

    ${runtime mods product codes}=  Get Dictionary Values  ${runtime mods mapping}
    ${scf mods product codes}=  Get Dictionary Values  ${scf mods mapping}
    Sort List  ${runtime mods product codes}
    Sort List  ${scf mods product codes}

    ${status}=  Run keyword and return status  Lists Should Be Equal  ${runtime mods product codes}  ${scf mods product codes}
    Run Keyword If  not ${status}
    ...  Log  Modules product codes differs between runtime(${runtime mods mapping}) and scf(${scf mods mapping})  console=${True}
    [Return]  ${status}

_Siso Extract Modules Product Codes
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

Siso Check SCF count
    [Documentation]
    ...
    ...  | Parameter       | Mandatory | Description                    |
    ...  | class_name      | Yes       | [LTE, WCDMA, GSM, SMOD, RMOD]  |
    ...  | runtime_objects | Yes       | List of runtime objects        |
    ...
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

Siso Set SCF cells count
    [Documentation]
    ...  type: LTE GSM WCDMA
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    [Arguments]  ${type}
    ${scf_cells_count}=  hran_file_operations.Get Cells Count  technology=${type}
    Set test variable  ${SCF_COUNT_${type}}  ${scf_cells_count}

Siso Admin Get ids for all cells
    [Documentation]
    ...  Get IDs for all items of GNCEL, WNCEL, LNCEL and NRCEL class.
	...
	...  | **Author:** jaroslaw.piszczala@nokia.com
	...  | **Maintainer:** jaroslaw.piszczala@nokia.com
	...  | **Released with version:** 48.0
	[Arguments]  ${alias}=default
    ${GNCEL ids}=  admin.Get Ids For All  GNCEL  connection=${alias}
    ${WNCEL ids}=  admin.Get Ids For All  WNCEL  connection=${alias}
    ${LNCEL ids}=  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}  connection=${alias}
    ${NRCEL ids}=  admin.Get Ids For All  NRCEL  connection=${alias}
    ${CELLS_ids}=  Evaluate  ${GNCEL ids}+${WNCEL ids}+${LNCEL ids}+${NRCEL ids}
    [Return]  ${CELLS_ids}

Siso Admin Print Active Alarms
    ${active_alarms}=  admin.Get Alarms  connection=default
    ${pretty_active_alarms}=  Evaluate  pprint.pformat(${active_alarms}, indent=4)  modules=pprint
    Log  Active alarms: ${pretty_active_alarms}  console=${True}

Setup TAF Admin
    [Documentation]
    ...  KW setup session to admin api using taf library.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
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
    ...  Setup TAF Admin  bts_host=10.13.23.249  connection_name=vm_1

    [Arguments]  ${bts_host}=192.168.255.129  ${connection_name}=default

    ${release}  radio.Get Active Software Release From ENB
    ${status}  ${connection}  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  5x  10s
    ...  admin.Setup Admin  admin_api_log_dir=${BTS Files}/coam_admin  bts_host=${bts_host}  bts_port=443
    ...  use_ssl=True  name=${connection_name}  release=${release}
    Run Keyword If  '${status}'=='FAIL'
    ...  Fail  Admin connection from TAF library did not start after 5 attempts!
    ...  ELSE  Log to console  Connection to Admin via TAF library successfully established!${\n}

    Set Test Variable  ${connection}

Report Configuration ID
    Run Keyword And Ignore Error  Start Testline Scout Monitor
    Run Keyword And Ignore Error  Create Report
    Run Keyword And Ignore Error  Stop Testline Scout Monitor

Request to Scout to fetch SCF
    ${tl_name}  Run  ssh -o LogLevel=quiet localhost sed 's/-/_/g' /etc/hostname
    ${setup_scout_status}  ${scout_alarms_msg}  Run Keyword And Ignore Error  scout.Setup Scout  ${tl_name}
    ${single_run_execution}  Evaluate  [bool(x) for x in ${TEST TAGS} if x.startswith("ute:id")]
    ${setup_scout_status}  Start And Confirm Scout Setup  vm_hostname=${tl_name}  retry=3  delay=60
    Run Keyword If  not ${setup_scout_status}  Log  ${scout_alarms_msg}  level=WARN
    ${scout_id}  Run Keyword If  ${single_run_execution}  scout.Request Scf
    ...  ELSE  scout.Request Scf  use_scout_internal_id=True
    Run Keyword If  ${setup_scout_status} and (not ${single_run_execution})  rp.Add To Test Data  data={"tc_execution_id":"${scout_id}"}
    Run Keyword If  ${scout_id}  Log  Request to Scout to fetch new SCF sent.  console=True
    ...  ELSE  Log  Couldn't fetch SCF for ${tl_name}! Please check connection to Scout.  level=WARN
    [Teardown]  Teardown Scout API

Check Testline Monitor Status Until Running
    [Arguments]  ${limit}=60 seconds
    [Documentation]  Checks if Scout's KW Get Testline Monitor Status returns "running" in key "admin_subscriptions_status_display" for limited time
    ...  Author: patryk.niewiejski@nokia.com
    ...  Maintainer: patryk.niewiejski@nokia.com
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | limit                  | No   | Default '60 seconds'. Provide time unit for timeout or number for  |
    ...  |                        |      | attempts                                                           |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  Return Values:
    ...  +-----------------------+----------------------------------------------------------------------------+
    ...  | Return Value          | Description                                                                |
    ...  +=======================+============================================================================+
    ...  | status                | True if admin_subscriptions_status_display equals running False otherwise  |
    ...  +-----------------------+----------------------------------------------------------------------------+
    TRY
       WHILE  ${True}  limit=${limit}
            Sleep  1s  # Anti spam delay
            ${scout_monitor_dict}  scout.Get Testline Monitor Status
            IF  "${scout_monitor_dict['admin_subscriptions_status_display']}" == "running"  RETURN  ${True}
            IF  "${scout_monitor_dict['admin_subscriptions_status_display']}" == "setting up"  CONTINUE
        END
        Log  Scout Monitor is not running! Its last status was: ${scout_monitor_dict['admin_subscriptions_status_display']}
    EXCEPT  AS  ${error}
        Log  Failed to check Scout Monitor status due to ${error}
    END
    [Return]  ${False}

Start And Confirm Scout Setup
    [Arguments]  ${vm_hostname}  ${retry}=3  ${delay}=60
    [Documentation]  KW checks or retries Scout setup
    ...  Author: patryk.niewiejski@nokia.com
    ...  Maintainer: patryk.niewiejski@nokia.com
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | vm_hostname            | Yes  | VM hostname from Linux command                                     |
    ...  | retry                  | No   | Limit of allowed attempts                                          |
    ...  | delay                  | No   | Sleep time if Scout Monitor is starting up                         |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  Return Values:
    ...  +-----------------------+----------------------------------------------------------------------------+
    ...  | Return Value          | Description                                                                |
    ...  +=======================+============================================================================+
    ...  | scout_setup_status    | Scout setup status. True if set up or False if not set up                  |
    ...  +-----------------------+----------------------------------------------------------------------------+
    FOR  ${try}  IN RANGE  ${retry}
        ${scout_setup_status}  Run Keyword And Return Status  scout.Setup Scout  ${vm_hostname}
        IF  not ${scout_setup_status}  CONTINUE
        ${scout_monitor_status}  Check Testline Monitor Status Until Running
        IF  ${scout_monitor_status}  RETURN  ${True}
        Log  Setting up Scout monitoring attampt ${try} of ${retry} failed!
        Sleep  ${delay}
    END
    Log To Console  Couldn't set up Scout monitoring for ${vm_hostname} after ${retry} attempts! Configuration ID won't be repported!
    [Return]  ${False}

Start Testline Scout Monitor

    ${scout_conf_path}  Set Variable  /home/ute/testline_init_results/agent_scout/results/config_files/scout.conf
    ${venv_cmd}=    Run    if [ -f /home/ute/test_repo/bin/activate ]; then echo "source /home/ute/test_repo/bin/activate"; else echo ":"; fi
    ${cmd_pip_install_scout_cli}=  Catenate  pip install -U --trusted-host artifactory-espoo1.int.net.nokia.com -i
    ...                            https://artifactory-espoo1.int.net.nokia.com/artifactory/api/pypi/pypi-scout-local/simple scout-cli

    ${single_run_execution}  Evaluate  [bool(x) for x in ${TEST TAGS} if x.startswith("ute:id")]
    Run Keyword And Return If  ${single_run_execution}  Log To Console    Cloud execution detected - skipping...

    Run    ssh -o LogLevel=quiet ute@${PC_IP1} ${venv_cmd}; ${cmd_pip_install_scout_cli}
    ${scout_config}  Get Scout Config As Dict  ${PC_IP1}  ${scout_conf_path}

    ${scout_monitor_status}  Get Scout Tesline Monitor Status  ${scout_config["scout_testline_name"]}  ${PC_IP1}  ${scout_conf_path}
    Run Keyword If  not ${scout_monitor_status}
    ...  Run  ssh -o LogLevel=quiet ute@${PC_IP1} source /home/ute/test_repo/bin/activate; scout-cli testline start -c ${scout_conf_path}
    Sleep  5s
    ${scout_monitor_status}=    Get Scout Tesline Monitor Status    ${scout_config["scout_testline_name"]}    ${PC_IP1}    ${scout_conf_path}

    Run Keyword If  not ${scout_monitor_status}    Log To Console    Scout Testline Monitor should not be DISABLED!    level=warn
    Run Keyword If    ${scout_monitor_status}    Log To Console    Scout Testline Monitor is enabled

Get Scout Config As Dict
    [Arguments]    ${PC_IP1}    ${scout_conf_path}
    ${config_exists}=        Run    ssh -o LogLevel=quiet ute@${PC_IP1} [ -f ${scout_conf_path} ]; echo $?
    # Bash way to check if file exist (0->exist; 1->not exist)
    Should Be Equal    ${config_exists}    0    msg=Couldn't find file ${scout_conf_path} on ${PC_IP1}
    ${config_file}=    Run    ssh -o LogLevel=quiet ute@${PC_IP1} cat ${scout_conf_path}
    ${config_dict}=    Evaluate    ${config_file}    # This is file (string) to dict convertion
    Dictionary Should Contain Key    ${config_dict}    scout_testline_id
    Dictionary Should Contain Key    ${config_dict}    scout_testline_name
    Dictionary Should Contain Key    ${config_dict}    testline_token
    [Return]    ${config_dict}

Get Scout Tesline Monitor Status
    [Arguments]    ${hostname}    ${PC_IP1}    ${scout_conf_path}
    ${response}=    Run  ssh -o LogLevel=quiet ute@${PC_IP1} source /home/ute/test_repo/bin/activate; scout-cli testline status -c ${scout_conf_path}
    ${status}=    Run Keyword And Return Status    Should Match Regexp    ${response}    (?im)scout_prod_testline_${hostname}: Up
    [Return]    ${status}

Stop Testline Scout Monitor
    ${scout_conf_path}=    Set Variable    /home/ute/testline_init_results/agent_scout/results/config_files/scout.conf
    ${venv_cmd}=    Run    if [ -f /home/ute/test_repo/bin/activate ]; then echo "source /home/ute/test_repo/bin/activate"; else echo ":"; fi
    ${cmd_pip_install_scout_cli}=  Catenate  pip install -U --trusted-host artifactory-espoo1.int.net.nokia.com -i
    ...                            https://artifactory-espoo1.int.net.nokia.com/artifactory/api/pypi/pypi-scout-local/simple scout-cli

    ${single_run_execution}=     Evaluate    [bool(x) for x in ${TEST TAGS} if x.startswith("ute:id")]
    Run Keyword And Return If    ${single_run_execution}    Log To Console    Cloud execution detected - skipping...

    Run    ssh -o LogLevel=quiet ute@${PC_IP1} ${venv_cmd}; ${cmd_pip_install_scout_cli}
    ${scout_config}=    Get Scout Config As Dict    ${PC_IP1}    ${scout_conf_path}

    ${scout_monitor_status}=    Get Scout Tesline Monitor Status    ${scout_config["scout_testline_name"]}    ${PC_IP1}    ${scout_conf_path}
    Run Keyword If    ${scout_monitor_status}
    ...  Run  ssh -o LogLevel=quiet ute@${PC_IP1} source /home/ute/test_repo/bin/activate; scout-cli testline stop -c ${scout_conf_path}
    ${scout_monitor_status}=    Get Scout Tesline Monitor Status    ${scout_config["scout_testline_name"]}    ${PC_IP1}    ${scout_conf_path}

    Run Keyword If    ${scout_monitor_status}    Log To Console    Scout Testline Monitor is ENABLED - It should not be anymore!    level=warn
    Run Keyword If    not ${scout_monitor_status}    Log To Console    Scout Testline Monitor is disabled


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

Analyze Truck Roll On All Nodes
    Log To Console    \n------------------------------------------------\nStarting analysis of Truck Roll for all nodes...
    ${analyze_status}   Set Variable    ${False}
    ${singlenode_status}    ${truck_roll_email_reason}=    Run Keyword And Continue on Failure    Analyze Truck Roll On Node
    ...    vm_ip=${PC_IP1}    alias=default    node=1
    ${analyze_status}=    Run Keyword If    ${singlenode_status}    Set Variable    ${True}
    FOR  ${remote_line_alias}  IN  @{REMOTE_TESTLINES_LIST}
        ${multinode_status}    ${truck_roll_remote_email_reason}=    Run Keyword And Continue on Failure    Analyze Truck Roll On Node
        ...    vm_ip=${REMOTE_TESTLINES["${remote_line_alias}"]["PC_IP1"]}    alias=${remote_line_alias}    node=2
        ${analyze_status}=    Run Keyword If    ${multinode_status}    Set Variable    ${True}
        ${truck_roll_email_reason}=    Combine Multiline Truck Roll Results    ${truck_roll_email_reason}    ${truck_roll_remote_email_reason}
    END
    Log To Console    End of analysis of Truck Roll for all nodes\n-------------------------------------------\n
    [Return]    ${analyze_status}    ${truck_roll_email_reason}

Analyze Truck Roll On Node
    [Arguments]    ${vm_ip}=${PC_IP1}    ${alias}=default    ${node}=1
    # Variables required for Truck Roll
    ${truck_roll_alarms}=    Evaluate    [10, 1806, 4341, 4352, 4383]
    ${is_multinode}=      Get Length      ${REMOTE_TESTLINES_LIST}
    Log To Console    Truck Roll analysis for node ${node} begins...
    # Truck Roll LMP connectivity check
    ${trigger_lmp_connectivity}  ${mplane_ip}=    Run Keyword And Continue On Failure    Analyze Truck Roll LMP Connectivity
    ...    lmp_addr=${vm_ip}
    ...    log_path=${OUTPUT_DIR}
    Run Keyword If    ${trigger_lmp_connectivity}    Log To Console    Truck Roll LMP connectivity check on node ${node} passed
    Run Keyword If    not ${trigger_lmp_connectivity}    Log To Console    Truck Roll LMP connectivity check on node ${node} FAILED!
    # Truck Roll M-Plane connectivity check
    ${trigger_mplane_connectivity}=    Run Keyword If    ${trigger_lmp_connectivity}    Run Keyword And Continue On Failure
    ...    Analyze Truck Roll MPlane Connectivity
    ...    mplane_addr=${mplane_ip}
    ...    log_path=${OUTPUT_DIR}
    Run Keyword If    ${trigger_mplane_connectivity}    Log To Console    Truck Roll M-Plane connectivity check on node ${node} passed
    Run Keyword If    not ${trigger_mplane_connectivity}    Log To Console    Truck Roll M-Plane connectivity check on node ${node} FAILED!
    # Truck Roll HW detection check
    ${trigger_hw_detection}=    Run Keyword And Continue On Failure    Analyze Truck Roll HW Detection
    ...    alias=${alias}
    ...    smod_list=${TRUCK_ROLL_HW_DICT["${alias}"]["smod"]}
    ...    bbmod_list=${TRUCK_ROLL_HW_DICT["${alias}"]["bbmod"]}
    ...    rmod_list=${TRUCK_ROLL_HW_DICT["${alias}"]["rmod"]}
    Run Keyword If    ${trigger_hw_detection}    Log To Console    Truck Roll HW detection check on node ${node} passed
    Run Keyword If    not ${trigger_hw_detection}    Log To Console    Truck Roll HW detection check on node ${node} FAILED!
    # Truck Roll alarms check
    ${trigger_alarms}=    Run Keyword And Continue On Failure    Analyze Truck Roll Alarms
    ...    alias=${alias}
    ...    truck_roll_alarms=${truck_roll_alarms}
    Run Keyword If    ${trigger_alarms}    Log To Console    Truck Roll alarms check on node ${node} passed
    Run Keyword If    not ${trigger_alarms}    Log To Console    Truck Roll alarms check on node ${node} FAILED!
    # Truck Roll result overall - True if Truck Roll failed, False otherwise
    ${truck_roll_result}=    Set Variable
    ...    not ${trigger_alarms} or not ${trigger_hw_detection} or not ${trigger_lmp_connectivity} or not ${trigger_mplane_connectivity}
    # Reason building for Stop&Fix email notification
    ${truck_roll_email_reason_evaluate_string}=    Catenate    dict(alarms=not ${trigger_alarms}, hw=not ${trigger_hw_detection},
    ...    lmp=not ${trigger_lmp_connectivity}, mplane=not ${trigger_mplane_connectivity})
    ${truck_roll_email_reason}=    Evaluate    ${truck_roll_email_reason_evaluate_string}
    Run Keyword If    not ${truck_roll_result}    Log To Console    All steps of Truck Roll analysis for node ${node} passed
    [Return]    ${truck_roll_result}    ${truck_roll_email_reason}

Prepare HW Variables For Truck Roll
    [Arguments]    ${alias}=default
    ${check_status_smod}  ${RUNTIME_SMOD}  ${ALL_SMOD}=  Get objects with expected states SiSo  ${SMOD_expected_states}  SMOD  alias=${alias}
    ${smod_sn_list}=    Run Keyword If    '${check_status_smod}'=='PASS'
    ...    Evaluate   [smod_sn["serialNumber"] for smod_sn in ${RUNTIME_SMOD}]
    ...    ELSE    Create List
    ${check_status_bbmod}  ${RUNTIME_BBMOD}  ${ALL_BBMOD}=  Get objects with expected states SiSo  ${BBMOD_expected_states}  BBMOD  alias=${alias}
    ${bbmod_sn_list}=    Run Keyword If    '${check_status_bbmod}'=='PASS'
    ...    Evaluate   [bbmod_sn["serialNumber"] for bbmod_sn in ${RUNTIME_BBMOD}]
    ...    ELSE    Create List
    ${check_status_rmod}  ${RUNTIME_RMOD}  ${ALL_RMOD}=  Get objects with expected states SiSo  ${RMOD_expected_states}  RMOD  alias=${alias}
    ${rmod_sn_list}=    Run Keyword If    '${check_status_rmod}'=='PASS'
    ...    Evaluate   [rmod_sn["serialNumber"] for rmod_sn in ${RUNTIME_RMOD}]
    ...    ELSE    Create List
    ${node_hw_dict}    Create Dictionary    smod=${smod_sn_list}    bbmod=${bbmod_sn_list}    rmod=${rmod_sn_list}
    Set To Dictionary    ${TRUCK_ROLL_HW_DICT}    ${alias}    ${node_hw_dict}

Combine Multiline Truck Roll Results
    [Arguments]    ${local_dict}    ${remote_dict}
    FOR  ${key}  IN  @{local_dict}
        ${combined_value}=    Evaluate    ${local_dict["${key}"]} or ${remote_dict["${key}"]}
        Set To Dictionary   ${local_dict}    ${key}=${combined_value}
    END
    [Return]    ${local_dict}

Create Report
    [Arguments]  ${connection}=default
    Run Keyword And Ignore Error  Request to Scout to fetch SCF
    rp.Set Tool  Robot
    ${sw_info}=  admin.Get Software Info  connection=${connection}
    QC Mapping  ${sw_info['Active SW version']}

QC Mapping
    [Arguments]   ${sw_under_test}
    ${ti_entered_manually}=  Run Keyword And Return Status  Should Match Regexp  ${TEST_NAME}  ^\\[\\d*\\].*
    Return From Keyword If   ${ti_entered_manually}
    ${correct_test_name}=    Set Correct Test Instance Based On QC File   ${TEST_NAME}  ${sw_under_test}  ${SUITE_SOURCE}
    Log To Console  Mapping Test Case as ${correct_test_name}
    rp.Map Testcase   ${correct_test_name}
