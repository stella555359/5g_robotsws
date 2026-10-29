*** Settings ***
Documentation
...             == Purpose ==
...             Library to manage (Suite or test) Setup/Teardown steps
...
...             == Description ==
...             This library is providing some default services for :
...
...             | Test Setup     | nothing for the moment                                                    |
...             | Test Teardown  | Sos repot and snapshot generation is test is failed                       |
...             | Suite Setup    | Dynamic discovery, init of all global variables, backup of some key files |
...             | Suite Teardown | restore of backuped files                                                 |
...
...             Also, at Suite Setup, a flag should be provided, that indicate the kind of expected behavior.
...             This flag is named : automaticTeardown, and its possible values are :
...
...             | True      | Teardown is launched after every failed tests                     |
...             | False     | Teardown is never launched (default value for PASSED test)        |
...             | Force     | Teardown is launched at suite teardown                            |
...             | FirstFail | Teardown is launched ONLY after first failed test                 |
...
...             Concerning Suite Setup, 2 services are proposed :
...
...             | Suite Setup              | Basic suite setup            |
...             | Suite Setup From Scratch | Same as previous + WTS clear |
...             Interest of Suite Setup (not from scratch) is that it is not destructive.
...             It means a Suite Setup can be launched on a TL in // of another test runnning.
...
...             Reading of topology in test setup gives details and display it field by field
...             It has been moved before "Setup Ute Env if required" in order
...             to initiate variable nbVMwts early
...
...             This is important to record early nb of VMwts to manage multi VMwts support.
...
...             the setup then initializes hosts and logs the initial state of DicHOSTSwts. It configures each host's SSH connection
...             and updates DicHOSTSwts with alias and object.
...             This is done by calling Connect.initialize_hosts, which returns a dictionary of hosts.
...                OrderedDict([("VMwts_1", <Hosts.Host object at 0x7f3f0525e230>), ...,
...                             ("AVMwts__n", <Hosts.Host object at 0x7f3f05016ec0>)])
...
...             * Sequence :*
...
...             One important point is that many global variables are pre-set in some .py or .robot files
...             but they are fully evaluated and set during dynamic discovery, which will discover and update
...             all hosts, and also host for captures, script definition, Files descriptions for bcakup,...
...             So, invoking "Suite Setup" or "Suite Setup From Scratch" somewhere in your Suite Setup step of
...             a suite tests is a MANDATORY !!!!.
...             Otherwise, all GNB_DU,... variables won't be set and all tests will be failed.
...

Library                             DateTime
Library                             OperatingSystem
Library                             taf.ul.ue.sim.env_setup
Library                             taf.sw.scout                    WITH NAME   taf_scout
Library                             taf.sw.ping                     WITH NAME   ping
Resource                            Tools.robot
Resource                            Connect.robot
Resource                            Oam.robot
Resource                            Container.robot
Resource                            CallSetup.robot
Resource                            Backup.robot
Resource                            Topology.robot
Resource                            UteTools.robot
Resource                            Workaround.robot
Resource                            Counters.robot

Library                             ../python/StringTool.py
Library                             ../python/Archi.py
Library                             ../python/Setup.py
Library                             ../python/Backup.py
Library                             ../python/Captures.py
Library                             ../python/Connect.py
Library                             ../python/OsTool.py
Library                             ../../../RRM/ET/resources/python/robot_extension.py   WITH NAME       robot_extension
Library                             ../python/Hosts.py

*** Variables ***
${STATUS_FILE_NAME}                 Status_Before_Testsuite.txt
${PMAUDIT_FILE_NAME}                PM_Audit.txt
@{NO_BACKUP_FILES}
${enable_sherpa}
${generate_sos_report}
${FIRST_SA_UE_ID}
${FIRST_NSA_UE_ID}
${TIMEOUT}    300  # Timeout in seconds

*** Keywords ***
#=======================================================================================================================
# Suite/Test setup/teardown
#=======================================================================================================================
Test Setup
    [Documentation]                 Generic Test setup part if it is used in tests
    ...                             Currently, does nothing
    Dated Log                       Start Test Setup

Suite Setup From Scratch
    [Documentation]
    ...                        == Generic Suite Setup for tests ==
    ...                             Update all global variables, discover topology, read SCFs, backup config files
    ...                             Also, WTS is resetted
    ...
    ...                        *Argument details:*
    ...                             -*listBackupFiles* : contains the list of file description to be backuped
    ...                                 By default, no files are backuped. The global variables @{FD_ALL} may be used
    ...                                 to backup all config files. See Backup.robot and Backup.py for more details.
    ...                             -*automaticTeardown* : indicates how to proceed for teardown
    ...                                 Default value is False, possible values are:
    ...                                 automaticTeardown=True         launched after every failed tests
    ...                                 automaticTeardown=False        never launched (default value)
    ...                                 automaticTeardown=Force        launched at suite teardown
    ...                                 automaticTeardown=FirstFail    launched ONLY after first failed test
    ...                             -*keepAllUeDataInCfgFile* : set to "True" to keep all UE data in the basic.cfg file
    ...                                        Default value = "False" (i.e. remove all UE data excepted the first SA UE and first NSA UE)
    ...                             The following parameters were created following the removal of custom_config in the new agentCA.
    ...                             The possible combinations are:
    ...                             1- No parameter: it was the case until this code evolution
    ...                             2- Only the yamlPathname param: all requested custom config files should be setup in a YAML file.
    ...                             3- The yamlPathname and vendor_params params: same as option 2 but requested vendor params will be setup
    ...                             4- DU/CU scfcPathname and/or iphyPathname and/or basicPathname and/or rad_params list and/or vendor_params list:
    ...                                 this allows to install one or several files and on classical BTS, the vendor and/or rad parameters.
    ...                                 If vendor_params (not allowed with VRAN) is set then the scfcPathname param is mandatory,
    ...                                 as a full commissionning is mandatory to activate new vendor parameters.
    ...                             -*yamlPathname* : Path to the YAML file which contains all custom config files to be installed.
    ...                                        Default value: ${EMPTY}
    ...                             -*scfcPathname* : Path to the DU SCF.xml file to be installed at the beginning of the suite setup.
    ...                                        Default value: ${EMPTY}
    ...                             -*cuScfcPathname* : Path to the CU SCF.xml file to be installed at the beginning of the suite setup.
    ...                                        Default value: ${EMPTY}
    ...                             -*iphyPathname* : Path to the IPHY.xml file to be installed at the beginning of the suite setup.
    ...                                        Default value: ${EMPTY}
    ...                             -*basicPathname* : Path to the basic_setup.cfg file to be installed at the beginning of the suite setup.
    ...                                        Default value: ${EMPTY}
    ...                             -*rad_params* : List of rad parameters to be set (NOT MANAGED WITH VRAN TL).
    ...                                        Default value: ${EMPTY}
    ...                             -*vendor_params* : List of vendor parameters to be set (NOT MANAGED WITH VRAN TL).
    ...                                        Default value: ${EMPTY}
    ...                             -*listBackupFiles* : List of file descriptions to be backed up.
    ...                                        Default value: ${NO_BACKUP_FILES}
    ...                             -*automaticTeardown* : Indicates how to proceed for teardown.
    ...                                        Default value: ${False}
    ...                             -*keepAllUeDataInCfgFile* : Set to "True" to keep all UE data in the basic.cfg file.
    ...                                        Default value: ${False}
    ...                             -*edaemonPort* : Port number for edaemon.
    ...                                        Default value: 22222
    ...                             -*egatePort* : Port number for egate.
    ...                                        Default value: 9880
    ...                             -*debug* : Set to "True" to enable debug mode.
    ...                                        Default value: ${False}
    [Arguments]                     ${listBackupFiles}=${NO_BACKUP_FILES}
    ...                             ${automaticTeardown}=${False}
    ...                             ${keepAllUeDataInCfgFile}=${False}
    ...                             ${edaemonPort}=${22222}
    ...                             ${egatePort}=${9880}
    ...                             ${yamlPathname}=${EMPTY}
    ...                             ${scfcPathname}=${EMPTY}
    ...                             ${cuScfcPathname}=${EMPTY}
    ...                             ${iphyPathname}=${EMPTY}
    ...                             ${basicPathname}=${EMPTY}
    ...                             ${rad_params}=${EMPTY}
    ...                             ${vendor_params}=${EMPTY}
    ...                             ${debug}=${False}
    Suite Setup                     listBackupFiles=${listBackupFiles}
    ...                             automaticTeardown=${automaticTeardown}
    ...                             keepAllUeDataInCfgFile=${keepAllUeDataInCfgFile}
    ...                             edaemonPort=${edaemonPort}
    ...                             egatePort=${egatePort}
    ...                             yamlPathname=${yamlPathname}
    ...                             scfcPathname=${scfcPathname}
    ...                             cuScfcPathname=${cuScfcPathname}
    ...                             iphyPathname=${iphyPathname}
    ...                             basicPathname=${basicPathname}
    ...                             rad_params=${rad_params}
    ...                             vendor_params=${vendor_params}
    ...                             debug=${debug}
    WTS Clear

Suite Setup
    [Documentation]                 Generic Suite Setup for tests, excluding WTS reset.
    ...                             Please see the "Suite setup from scratch" documentation to know how to use this keyword.
    [Arguments]                     ${listBackupFiles}=${NO_BACKUP_FILES}
    ...                             ${automaticTeardown}=${False}
    ...                             ${keepAllUeDataInCfgFile}=${False}
    ...                             ${edaemonPort}=${22222}
    ...                             ${egatePort}=${9880}
    ...                             ${yamlPathname}=${EMPTY}
    ...                             ${scfcPathname}=${EMPTY}
    ...                             ${cuScfcPathname}=${EMPTY}
    ...                             ${iphyPathname}=${EMPTY}
    ...                             ${basicPathname}=${EMPTY}
    ...                             ${rad_params}=${EMPTY}
    ...                             ${vendor_params}=${EMPTY}
    ...                             ${debug}=${False}
    Log to console                  Suite Setup
    Setup AgentType
    Setup Init Variables            automaticTeardown=${automaticTeardown}
    Setup Custom Config             yamlPathname=${yamlPathname}
    ...                             scfcPathname=${scfcPathname}
    ...                             cuScfcPathname=${cuScfcPathname}
    ...                             iphyPathname=${iphyPathname}
    ...                             basicPathname=${basicPathname}
    ...                             rad_params=${rad_params}
    ...                             vendor_params=${vendor_params}
    # --- Early topology detection without TLConfig (TLConfig is None here) ---
    # Instantiate a Topology object directly from Python and read the raw topology string.
    # This uses the agent log file (LABEL:/VARIANT:) just like TOPO Read will later.
    ${early_topo_obj}=    Evaluate    __import__('Topology').Topology.quick_topology_detection()
    ${early_topo_str}=    Set Variable    ${early_topo_obj.topoStr}
    Log To Console    Early topology raw string: ${early_topo_str}
    ${is_aic_early}=      Evaluate    '5GC_dRNIC' in '${early_topo_str}'
    ${is_vran_early}=     Evaluate    any(x in '${early_topo_str}' for x in ['vDU','VDU','vDUCNF'])
    IF    not ${is_aic_early} and not ${is_vran_early}
        ${is_bsoc_installed}=    temporary_bsoc_reinstall
    END
    # Skip waiting sequence for Cloud / AIC / vRAN or if reinstall already done.
    # If topology not yet detectable (empty string), we keep the original waiting behavior.
    IF     not ${is_aic_early} and not ${is_vran_early}
        IF    ${is_bsoc_installed}
            Waiting keyword
            Sleep    30s
            Loop Until IsOk Is True Or Timeout
        END
    END

    Run Keyword if                  ${debug}==${True}           return from keyword
    TOPO Read
    Setup Ute Env if required       edaemonPort=${edaemonPort}
    ...                             egatePort=${egatePort}

    IF    ${nbVMwts} <= 1
            StringTool.printHeaderLine      name=EDAEMON PORT           value=${tl.core.edaemon_port}
            StringTool.printHeaderLine      name=EGATE PORT             value=${tl.core.egate_port}
    ELSE
            FOR    ${idx}      IN RANGE    0      ${nbVMwts}
                StringTool.printHeaderLine      name=AP ${idx} EDAEMON PORT  value=${tl.core[${idx}].edaemon_port}
                StringTool.printHeaderLine      name=AP ${idx} EGATE PORT    value=${tl.core[${idx}].egate_port}
            END

    END

    get_l1_mode                     ${TLConfig}
    call method                     ${TLConfig}                 printConfig
    Get TL Info
    TL Information
    # Now the topology is known => we can decide to use or not the new basic.cfg treatment
    Cleanup WTS Config File         keepAllUeDataInCfgFile=${keepAllUeDataInCfgFile}
    OAM Get SCF Files
    UpdateCapture
    IF    ${nbVMwts} <= 1    initBackupFilesDesc
    # UpdateBackupFilesDesc
    Suite Backup Files              listBackupFiles=${listBackupFiles}
    Check Network Type
    Set Gscn Parameter Name
    # TBD - The 2 following CloudBTS cases could be removed
    Run Keyword if                  ${TLConfig.isGnbCloud}==${True} and not ${isAic}
    ...                             WorkAround for CloudBTS X2AP link issue
    Run Keyword if                  ${TLConfig.isGnbCloud}==${True} and not ${isAic}
    ...                             WorkAround for CloudBTS Traffic issue
    Run Keyword if                  ${isAic}
    ...                             Clean PM on AiC TL
    ...         ELSE                Purge Log Files     path=/ffs/run/logs      extension=pcap
    # Get all FDD TDD Cells info needed by testers
    OAM Build FDD TDD Cells Dict


TL Information
    [Documentation]                 INTERNAL USAGE
    ...                             Print TL information in the log.
    Topo.printTLInfoInLog           tlconfig=${TLConfig}        isConsole=${False}


Call Scout Services
    [Documentation]                 INTERNAL USAGE
    ...                             Launch Scout services to produce data for RP.
    ...                             For Cloud RAN testlines (AIC/vRAN), SCF collection is skipped as admin_cli is not available.
    [Arguments]                     ${wait_for_success}    ${timeout}   ${use_scout_internal_id}    ${alias}

    # Check if testline monitor has admin_cli running (required for SCF collection)
    # Use timeout to prevent hanging if Scout is unreachable
    ${monitor_status}=              Wait Until Keyword Succeeds    300s    1s
    ...                             Run Keyword And Ignore Error
    ...                             taf_scout.get_testline_monitor_status   alias=${alias}
    ${has_admin_cli}=               Set Variable    ${False}

    IF    '${monitor_status}[0]' == 'PASS'
        ${has_key}=                 Run Keyword And Return Status
        ...                         Dictionary Should Contain Key    ${monitor_status}[1]    admin_cli_status_display
        IF    ${has_key}
            ${admin_cli_status}=    Get From Dictionary    ${monitor_status}[1]    admin_cli_status_display
            ${has_admin_cli}=       Evaluate    '${admin_cli_status}' == 'running'
        END
    END

    # Only request SCF if admin_cli is running (Classical BTS)
    # Cloud RAN testlines don't have admin_cli and cannot collect SCF via Scout
    IF    ${has_admin_cli}
        Log    Scout SCF collection: admin_cli is running, requesting SCF    console=True
        ${scout_scf_id}=            taf_scout.request_scf                   wait_for_success=${wait_for_success}
        ...                                                             timeout=${timeout}
        ...                                                             use_scout_internal_id=${use_scout_internal_id}
        ...                                                             alias=${alias}
    ELSE
        Log    Scout SCF collection skipped: Cloud RAN testline detected (admin_cli not available)    console=True
        Log    Cloud RAN testlines (AIC/vRAN) use different SCF management and cannot collect SCF via Scout    WARN
    END

Produce Scout Data
    [Documentation]                 Prepare Scout environment then call Scout service to produce data for Reporting Portal.
    [Arguments]                     ${wait_for_success}=True
    ...                             ${timeout}=60
    ...                             ${alias}=conn_alias
    ${status}    ${tl_name}=        Run Keyword and Ignore Error    OsTool.get_testline_name
    Run Keyword and Ignore Error    taf_scout.setup_scout               scout_testline_name=${tl_name}      alias=conn_alias
    ${use_scout_internal_id}=       Set Variable                    ${False}

    Run Keyword and Ignore Error    Call Scout Services             wait_for_success=${wait_for_success}
    ...                                                             timeout=${timeout}
    ...                                                             use_scout_internal_id=${use_scout_internal_id}
    ...                                                             alias=${alias}
    Run Keyword and Ignore Error    taf_scout.teardown_scout_api        alias=${alias}


Test Teardown
    [Documentation]                 Generic Test teardown:
    ...                             - Call the SCOUT services to produce data for the Reporting Portal.
    ...                             - Save the current egate_console.log file in LOG_PATH and then delete it.
    ...                             - Get SOS report and snapshot only if test is fail.
    Dated Log                       Start Test Teardown
    Produce Scout Data
    Save and Clear Egate Console Log          pattern=TestTeardown
    Run keyword if                  '${TEST_STATUS}'=='FAIL'
    ...                             Test Teardown if Fail

Test Teardown_V2
    [Documentation]                 Generic Test teardown:
    ...                             - Call the SCOUT services to produce data for the Reporting Portal.
    ...                             - Save the current egate_console.log file in LOG_PATH and then delete it.
    ...                             - Get SOS report and snapshot only if test is fail.
    Dated Log                       Start Test Teardown
    # Produce Scout Data
    Save and Clear Egate Console Log          pattern=TestTeardown
    Run keyword if                  '${TEST_STATUS}'=='FAIL'
    ...                             Test Teardown if Fail

Test Teardown if Fail
    [Documentation]                 Get SOS report and Snapshot. Should be invoked ONLY if test is FAIL.
    Dated log                       Get Sos Report
    Run Keyword If                  "${generate_sos_report}"=="True"        Get Sos Report
    ...         ELSE                Dated Log       WARNING : Sos Report creation is disabled by the tester
    Dated log                       Get Snapshot
    Get Snapshot

Suite Teardown
    [Documentation]                 Restore config files and SCFs if required.
    ...                             Argument reset_ap is a toggle to indicate if AP should be rebooted or not.
    ...
    ...                             Save the current egate_console.log file in LOG_PATH.
    ...
    [Arguments]                     ${reset_ap}=${False}        ${ignore_err}=${True}
    Log to console                  Suite Teardown
    Save Egate Console Log          pattern=SuiteTeardown
    Audit Counters in Tests
    Run keyword if                  '${ignore_err}'=='${True}'
    ...                             robot_extension.Run Keyword And Warn On Failure      Suite Teardown Actual        ${reset_ap}
    ...         ELSE                Suite Teardown Actual        ${reset_ap}

Suite Teardown Actual
    [Documentation]                 Restore config files and SCFs if required.
    ...                             Argument reset_ap is a toggle to indicate if AP should be rebooted or not.
    [Arguments]                     ${reset_ap}=${False}
    Log to console                  Suite Teardown Actual
    Run Keyword if                  ${isAic}    Clean Plan
    ...         ELSE                Purge Log Files     path=/ffs/run/logs      extension=pcap
    Suite Restore Files
    OAM Restore Files               reset_ap=${reset_ap}
    ...                             disconnect_oam=${True}
    Run keyword if                  "${automaticTeardown}"=="Force"         Test Teardown if Fail

Audit Counters in Tests
    [Documentation]                 Log and Store PM Audit with TC.
    ${ulist1}=                      RmDeplicate             ${AUDIT_CPT_TO_BE_TESTED}
    ${ulist2}=                      RmDeplicate             ${AUDIT_TC_CPT_TO_BE_TESTED}
    FOR    ${c}    IN    @{ulist1}
        # Dated log                  audit_counter=${c}
        Log and Store PM Audit with TC        ${c}
    END
    FOR    ${c}    IN    @{ulist2}
        # Dated log                  audit_counter_with_value=${c}
        Log and Store PM Audit with TC        ${c}
    END

#=======================================================================================================================
# Setup variables
#=======================================================================================================================
Setup Init Variables
    [Documentation]                 INTERNAL USAGE
    ...                             Set some global variables for test suite execution
    printLineWithTitle              title=Initializing some global variables
    [Arguments]                     ${automaticTeardown}=${False}
    # temp var to manage non existing value
    ${hire_sherpa} =                Get Variable Value                      ${hire_a_sherpa}
    ...                             False
    # the boolean good variable
    ${enable_sherpa} =              Set Variable If                         '${hire_sherpa}'=='True'
    ...                             ${True}                                 ${False}
    Set Suite Variable              ${enable_sherpa}
    StringTool.printHeaderLine      name=enable_sherpa                      value=${enable_sherpa}
    # temp var to manage non existing value
    ${tmp_sos_report} =             Get Variable value                      ${sos_report}
    ...                             True
    # the boolean good variable
    ${generate_sos_report} =        Set Variable If                         '${tmp_sos_report}'=='True'
    ...                             ${True}                                 ${False}
    Set Suite Variable              ${generate_sos_report}
    StringTool.printHeaderLine      name=generate_sos_report                value=${generate_sos_report}
    # temp var to manage non existing value
    ${tmp_no_python_update} =       Get Variable Value                      ${NO_PYTHON_UPDATE}
    ...                             False
    # the boolean good variable
    ${no_python_update} =           Set Variable If                         '${tmp_no_python_update}'=='True'
    ...                             ${True}                                 ${False}
    Set Suite Variable              ${no_python_update}
    StringTool.printHeaderLine      name=no_python_update                   value=${no_python_update}
    # Compute LOG path
    # Replace " " with "_" to have a correct file name (because stupid robot replace _ with spaces)
    ${timestamp}                    DateTime.Get Current Date               result_format=%Y%m%d_%H%M%S%f
    ${fullSuiteName}                getFormattedSuiteName
    Set Suite Variable              ${LOG_PATH}
    ...                             ${OUTPUT DIR}/Logs/${timestamp}.${fullSuiteName}
    Create Directory                ${LOG_PATH}
    StringTool.printHeaderLine      name=LOG_PATH                           value=${LOG_PATH}
    # Create temp path
    ${TEMP_PATH}                    OperatingSystem.run                     mktemp -d
    Set Suite Variable              ${TEMP_PATH}
    StringTool.printHeaderLine      name=TEMP_PATH                          value=${TEMP_PATH}
    Set Suite Variable              ${snapshot_path}                        ${LOG_PATH}/Snapshot.zip
    setTestTeardownFlag             ${automaticTeardown}
    # Explore the basic_setup.cfg file
    ${BasicPathname}                set variable                            /opt/iphy/latest/basic_setup.cfg
    ${SaUeId_FindCmd}               set variable                            grep -n suci ${BasicPathname}
    ${NsaUeId_FindCmd}              set variable                            grep -n imsi ${BasicPathname}
    ${getFirstItemCmd}              set variable                            cut -d '=' -f2 | cut -d ' ' -f1 | sort -n | head -1
    ${FIRST_SA_UE_ID}               OperatingSystem.run                     ${SaUeId_FindCmd} | ${getFirstItemCmd}
    ${FIRST_NSA_UE_ID}              OperatingSystem.run                     ${NsaUeId_FindCmd} | ${getFirstItemCmd}
    Set Suite Variable              ${FIRST_SA_UE_ID}
    Set Suite Variable              ${FIRST_NSA_UE_ID}
    Init PM Audit

Setup Ute Env if required
    [Documentation]                 INTERNAL USAGE
    ...                             Update tl structure by adding WTS information if TL is an UTE one
    [Arguments]                     ${edaemonPort}=${22222}
    ...                             ${egatePort}=${9880}

    # FTS adding
    @{alias_list}=    Create List
    Set Global Variable    @{alias_list}

    # Update tl.core fields igf we are in UTE
    Run Keyword if                  ${TLConfig.isUTE}
    ...                             UteTools.Update TL for UTE Env          edaemonPort=${edaemonPort}        egatePort=${egatePort}

    # port for PM with TL ute
    Run Keyword If                  ${TLConfig.isUTE}                       Set suite variable
    ...                             ${tl.gnbs[0].cu.oam_http_connection_details.port}    443

    # FTS modifying/adding
    IF    ${nbVMwts} <= 1
    # Update EPCSIM ssh connection (all cases)
        call method                 ${HOST_EPCSIM}                          setSshConnection
        ...                         ${tl.core.default_ssh_connection_details}
    ELSE
        Dated Log                    DEBUG: Initialize Hosts
        Run Keyword                  Evaluate    Connect.initialize_hosts(${nbVMwts})    modules=Connect

        FOR    ${idx}      IN RANGE    0      ${nbVMwts}
            ${host_alias}=           Evaluate    Connect.get_alias_by_index(${idx})    modules=Connect
            ${host_object}=          Evaluate    Connect.get_host("${host_alias}")    modules=Connect

            call Method              ${host_object}           setSshConnection    ${tl.test_pcs[${idx}].default_ssh_connection_details}

            # The setSshConnection keyword does not actually open an SSH connection. It only configures the connection
            # parameters (address, user, password, port, etc.) on the host object. The real SSH connection will be opened
            # later, when a keyword is called that executes a remote command or explicitly initiates the network connection.
            Run Keyword              Connect.update_host_and_alias_by_index    ${idx}    ${host_object}    ${host_alias}

            Set Suite Variable       ${tl.test_pcs[${idx}].host_ap}        ${host_object}
            Set Suite Variable       ${tl.test_pcs[${idx}].alias_ap}       ${host_alias}

            # Print DicHOSTSwts elements for information as Connect.method used here induce this dictionary updated
            Dated Log                DEBUG: Full DicHOSTSwts content: ${Connect.DicHOSTSwts}
        END

    END



Init PM Audit
    [Documentation]                 INTERNAL USAGE
    @{AUDIT_CPT_TO_BE_TESTED}       Create List
    Set Suite Variable              ${AUDIT_CPT_TO_BE_TESTED}
    @{AUDIT_TC_CPT_TO_BE_TESTED}    Create List
    Set Suite Variable              ${AUDIT_TC_CPT_TO_BE_TESTED}


Cleanup WTS Config File
    [Documentation]                 INTERNAL USAGE
    ...                             Goal: Select the right method to normalize the basic.cfg file in order to keep only the first SA and NSA UEs.
    ...                             The cleanup is depending of the topology: until now, the first SA UE Id is 1 and first NSA Ue Id is 11,
    ...                             but now, on the new LO_AP_LO topo with variant, the first SA UE Id is 1 and first NSA Ue Id is 101.
    [Arguments]                     ${keepAllUeDataInCfgFile}=${False}
    Return from Keyword If          ${keepAllUeDataInCfgFile}!=${False}     Basic.cfg will be kept as it was delivered by Agent-CA
    Dated log                       Basic_wts_step2.cfg will be purged to keep only SA UE Id=${FIRST_SA_UE_ID} and NSA UE Id=${FIRST_NSA_UE_ID}
    Normalize WTS Config File       firstSaUeId=${FIRST_SA_UE_ID}
    ...                             firstNsaUeId=${FIRST_NSA_UE_ID}

Normalize WTS Config File
    [Documentation]                 INTERNAL USAGE
    ...                             Remove all lines concerning UE id different from first SA UE Id and from first NSA Ue Id
    ...                             So, we remove them to come back to a known normalized state with only 1 SA UE and 1 NSA UE
    [Arguments]                     ${firstSaUeId}=${EMPTY}
    ...                             ${firstNsaUeId}=${EMPTY}
    ${cfg_path}                     Set Variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${myfirstSaUeId}                set variable if         '${firstSaUeId}' == '${EMPTY}'        None    ${firstSaUeId}
    ${myfirstNsaUeId}               set variable if         '${firstNsaUeId}' == '${EMPTY}'       None    ${firstNsaUeId}
    StringTool.printHeaderLine      name=EPCSIM:Removing ids not in (${myfirstSaUeId},${myfirstNsaUeId}) in:
    ...                             value=${cfg_path}
    FOR     ${i}    IN RANGE    1    255
            Run Keyword if      ${i}!=${myfirstSaUeId} and ${i}!=${myfirstNsaUeId}
            ...                 Run Keywords    Run     sed -i -e '/^set_ue simulated id=${i} /d' ${cfg_path}
            ...                         AND     Run     sed -i -e '/^ue_param id=${i} /d' ${cfg_path}
            ...                         AND     Run     sed -i -e '/^set_pdu_gateway id=${i} /d' ${cfg_path}
            ...                         AND     Run     sed -i -e '/^set_bearer id=2 ue=${i} /d' ${cfg_path}
            # In some cases, we have to keep alive the first PDN_IP...
            Run Keyword if      '${i}'!='1' and ${i}!=${myfirstSaUeId} and ${i}!=${myfirstNsaUeId}
            ...                                 Run     sed -i -e '/^set PDN_IP${i}=/d' ${cfg_path}
    END
    OsTool.saveBasicFileWithPattern     pathname=${tl.core.dir_path}
    ...                                 fileName=${tl.core.cfg_filename}
    ...                                 logpath=${LOG_PATH}
    ...                                 pattern=Normalized_
    StringTool.printHeaderLine      name=Normalized basic_wts_step2.cfg file is saved:
    ...                             value=${LOG_PATH}

#=======================================================================================================================
# Get TL Info
#=======================================================================================================================
Get TL Info
    [Documentation]                 INTERNAL USAGE
    ...                             Retrieve several info from TL: content of hardware and information from OAM
    ...                             Information retrieved are :
    ...                                 BTS_INFO, MRBTS_ID, NRCELL_DIST_NAME, NRCELL_DN, NRCELL_ID, NRCELL_DN_LIST, NRCELL_ID_LIST, NRCELL_NB,
    ...                                 GNB software version
    ...                                 GNB alarms
    Get TL Info Struct
    FOR   ${i}      IN RANGE        ${nbGNB}
        Get TL Info From Oam            entity=${TGNB_DU[${i}]}
        Get TL Info From Oam            entity=${TGNB_CU[${i}]}
    END

Get TL Info Struct
    [Documentation]                 Dynamic discovery of cards and hosts on TL,
    ...                             then dynamic discovery of containers
    ...                             GNB_DU, GNB_CU, AP_DU and AP_CU are the 4 global variables that should be used
    ...                             to access to all hosts/containers

    # FTS. buildEntity is cloned to let multi VMwts support
    IF    ${nbVMwts} <= 1
        Set global variable             ${KWtoplay}                            buildEntity
    ELSE
        Set global variable             ${KWtoplay}                            buildEntitymwts

    END
    printLineWithTitle              title=Get INFO on TL (Dynamic discovery)
    # GNB_DU and GNB_CU are now lists (multi GNBs support)
    @{TGNB_DU}                      Create List
    @{TGNB_CU}                      Create List
    @{T_POWER_SAVING_STATE}         Create List
    Set global variable             ${TGNB_DU}
    Set global variable             ${TGNB_CU}
    FOR     ${i}    IN RANGE        ${nbGNB}
        ${temp}   ${flag_cu}        Run Keyword    ${KWtoplay}              hw=GNB   unit=CU     index=${i}
        Append to list              ${TGNB_CU}                              ${temp}
        # Set global variable         ${TGNB_CU[${i}]}                      # RF5.0 Update
        ${temp}   ${flag_du}        Run Keyword    ${KWtoplay}              hw=GNB   unit=DU     index=${i}
        Append to list              ${TGNB_DU}                              ${temp}
        Append to list              ${T_POWER_SAVING_STATE}                 ${flag_du}
        # Set global variable         ${TGNB_DU[${i}]}                      # RF5.0 Update
        # Set global variable         ${T_POWER_SAVING_STATE[${i}]}         # RF5.0 Update
    END
    Set global variable             ${TGNB_CU}                              # RF5.0 Update
    Set global variable             ${TGNB_DU}                              # RF5.0 Update
    Set global variable             ${T_POWER_SAVING_STATE}                 # RF5.0 Update

    # DO NOT REPLACE name="GNB_XXX" with "TGNB_XXX[0]" !!!!!!
    ${GNB_DU}                       Set variable                            ${TGNB_DU[0]}
    ${GNB_CU}                       Set variable                            ${TGNB_CU[0]}
    # While AP is still managed as a single entity
    ${AP_CU}   ${flag_ap}           Run Keyword    ${KWtoplay}              hw=AP    unit=CU
    ${AP_DU}   ${flag_ap}           Run Keyword    ${KWtoplay}              hw=AP    unit=DU
    # Setting all variables as global ones
    Set global variable             ${GNB_DU}
    Set global variable             ${AP_DU}
    Set global variable             ${GNB_CU}
    Set global variable             ${AP_CU}

    Get Fhgw Ssh Data
    Return From Keyword if          ${isAic}
    # Dynamic discovery of containers
    WA Update Nodes and Logs Def


Get TL Info From Oam
    [Documentation]                 INTERNAL USAGE
    ...                             Retrieve from an OAM some key ids, such as NRBTS_ID, MRBTS_ID, ...
    ...                             But also, Version and alarms
    ...                             These information are put in some global variables, then stored in a file in Logs
    [Arguments]                     ${entity}=${TGNB_DU[${0}]}
    return from keyword if          '${entity}'=='None'
    StringTool.printLineWithTitle   Get TL info from OAM ${entity.oam.alias} : [${entity.oam}]
    @{alarms}                       OAM Get Active Alarms                   oam=${entity.oam}
    ${alias}                        OAM Connect                             ${entity.oam}
    ${entity.GNB_VERSION}           OAM Get SW Version                      oam=${entity.oam}
    OAM Get GNB BTS Info            oam=${entity.oam}
    # For each variable, display it, store in file, and eventually store in global variable
    Append To File                  ${LOG_PATH}/${STATUS_FILE_NAME}         GNB=${entity.prefix}\n
    ${postfix}                      OAM Get Postfix                         ${entity.oam}
    ${endStr}                       Set Variable                            ${postfix}\[${entity.index}]
    ${i}                            Set variable                            ${0}
    FOR    ${alarm}   IN    @{alarms}
        ${i}                        evaluate                                ${i}+${1}
        Trace and Store             val=${alarm}                            name=GNB${postfix}_OAM_ALARM[${i}]
    END

    Trace and Store                 val=${entity.GNB_VERSION}               name=SW${endStr}
    Trace and Store                 val=${TMRBTS_ID${endStr}}               name=TMRBTS_ID${endStr}
    Trace and Store                 val=${TNRBTS_ID${endStr}}               name=TNRBTS_ID${endStr}
    Trace and Store                 val=${TNRCELL_GRP${endStr}}             name=TNRCELL_GRP${endStr}
    Trace and Store                 val=${TNRCELL_DIST_NAME${endStr}}       name=TNRCELL_DIST_NAME${endStr}
    Trace and Store                 val=${TNRCELL_DN${endStr}}              name=TNRCELL_DN${endStr}
    Trace and Store                 val=${TNRCELL_ID${endStr}}              name=TNRCELL_ID${endStr}
    Trace and Store                 val=${TNRCELL_DN_LIST${endStr}}         name=TNRCELL_DN_LIST${endStr}
    Trace and Store                 val=${TNRCELL_ID_LIST${endStr}}         name=TNRCELL_ID_LIST${endStr}
    Trace and Store                 val=${TNRCELL_NB${endStr}}              name=TNRCELL_NB${endStr}

    [Teardown]                      Run keyword if                          '${entity}'!='None'
    ...                             OAM Disconnect                          ${entity.oam}

Trace and Store
    [Documentation]                 INTERNAL USAGE
    ...                             Trace in console and in status file and information and its value
    [Arguments]                     ${val}                                  ${name}
    Dated log                       \t${name}=${val}
    # Store in log file
    Append To File                  ${LOG_PATH}/${STATUS_FILE_NAME}         ${SPACE} ${name}=${val}\n

Log and Store PM Audit with TC
    [Documentation]                 INTERNAL USAGE
    ...                             Log and store in PM audit file
    [Arguments]                     ${el}
    ${plist}=                       ConvertFormatForPM             ${el}
    Append To File                  ${LOG_PATH}/${PMAUDIT_FILE_NAME}         ${plist}\n


Get Fhgw Ssh Data
    [Documentation]                 INTERNAL USAGE
    ...                             Retrieve FHGW SSH data from __init__.py

    ${AIC_FHGW_IP}                   Call method                             ${TLConfig}    GetFhgwIp
    ${AIC_FHGW_USER}                 Call method                             ${TLConfig}    GetFhgwUser
    ${AIC_FHGW_PASSWORD}             Call method                             ${TLConfig}    GetFhgwPassword

    Set global variable             ${AIC_FHGW_IP}
    Set global variable             ${AIC_FHGW_USER}
    Set global variable             ${AIC_FHGW_PASSWORD}
    Dated log                       \tAIC_FHGW :IP=${AIC_FHGW_IP} (user=${AIC_FHGW_USER}/pass=${AIC_FHGW_PASSWORD})

#=======================================================================================================================
# Snapshot and SOS report
#=======================================================================================================================
Get Sos Report
    [Documentation]                 Get Sos Report on WTS
    ${alias}                        SSH Connect                             ${HOST_EPCSIM}
    Dated Log                       \tStart generating Sos Report
    #${output}                       SSH Exec                                rm %{HOME}/SosReport*tgz
    ${output}                       SSH Exec                                rm ${tl.core.dir_path}/SosReport*.tgz
    ...                             alias=${alias}
    # the .tgz file is generated in $HOME directory
    # ${output}                       SSH Cmd                                 ${tl.core.dir_path}/sosReport.sh -nr -c -s
    # ...                             alias=${alias}                          timeout=900
    # should contain                  ${output}                               _complete_iphy1.tgz created
    # the .tgz file is generated in ${tl.core.dir_path} directory
    ${output}                       SSH Cmd
    ...                                 cd ${tl.core.dir_path}; ${tl.core.dir_path}/sosReport_ASIK_ASIL.sh
    ...                                 alias=${alias}
    ...                                 timeout=900
    ${checkResult}                  Run     grep SosReport ${tl.core.dir_path}/sosReport_ASIK_ASIL.sh.log | grep complete | grep created | wc -l
    Should Be True                  ${checkResult}==1
    # rename the SOS Report file
    ${current_date}=                DateTime.Get Current Date               result_format=%Y%m%d
    # ${sos_src_file}                 set variable                            %{HOME}/SosReport${current_date}_*.tgz
    ${sos_src_file}                 set variable                            ${tl.core.dir_path}/SosReport${current_date}_*.tgz
    # remove space and ' from TEST_NAME (otherwise the filename is invalid)
    ${tmp1_test_name}               replace string                          ${TEST_NAME}         ${SPACE}    ${EMPTY}
    ${tmp_test_name}                replace string                          ${tmp1_test_name}    \u2019      ${EMPTY}
    ${sos_dst_file}                 set variable                            %{HOME}/SosReport_${tmp_test_name}.tgz
    ${output}                       SSH Exec                                mv ${sos_src_file} ${sos_dst_file}
    ...                             alias=${alias}
    # download the SOS report to the local dir
    ${timestamp}=                   DateTime.Get Current Date               result_format=%Y%m%d-%H%M%S
    ${local_sos_file}               Set variable                            ${LOG_PATH}/SosReport_${tmp_test_name}.tgz
    csn.download_file               remote_path=${sos_dst_file}
    ...                             local_path=${local_sos_file}
    ...                             connection=${alias}
    Dated Log                       \tSos Report = ${local_sos_file}

Get Snapshot
    [Documentation]                 Get GNB snapshots (DU and CU if required)
    Dated Log                       \tStart getting snapshot from OAM DU
    ${snapshot_path}=               OAM Get Snapshot
    Dated Log                       \tSnapshot DU = ${snapshot_path}
    Run Keyword if                  ${TLConfig.isGnbCloud}==${True}         Get Snapshot CU

Get Snapshot CU
    [Documentation]                 INTERNAL USAGE
    ...                             Get GNB CU snapshot
    Dated Log                       \tStart getting snapshot from OAM CU
    ${cu_snapshot_path}=            OAM Get Snapshot                        oam=${GNB_CU.oam}
    ${res}                          Run                                     mv ${LOG_PATH}/Snapshot_2*.zip ${cu_snapshot_path}
    Dated Log                       \tCU Snapshot = ${cu_snapshot_path}

#=======================================================================================================================
# Miscellaneous tools
#=======================================================================================================================
Check Network Type
    [Documentation]                 INTERNAL USAGE
    ...                             TO BE COMPLETED
    ${gNbCuType}                    Run       grep -m 1 gNbCuType ${SCF_SETUP_PATH}|awk -F'>' '{print $2}'|cut -d"<" -f1
    ${cellDepType}                  Run       grep -m 1 cellDepType ${SCF_SETUP_PATH}|awk -F'>' '{print $2}'|cut -d"<" -f1
    should contain                  ${gNbCuType}                            ${cellDepType}
    set suite variable              ${NWtype}                               ${gNbCuType}
    ${nb_SA_cells}                  Run       grep cellDepType ${SCF_SETUP_PATH} |grep ">SA<" |wc -l
    ${nb_NSA_cells}                 Run       grep cellDepType ${SCF_SETUP_PATH} |grep ">NSA<" |wc -l
    ${nb_SA+NSA_cells}              Run       grep cellDepType ${SCF_SETUP_PATH} |grep ">SA+NSA<" |wc -l
    ${max_nb_SA_cells}              Set Variable if     ${nb_SA_cells} > ${nb_SA+NSA_cells}     ${nb_SA_cells}      ${nb_SA+NSA_cells}
    set suite variable              ${nb_of_SA_cells}                       ${max_nb_SA_cells}
    set suite variable              ${nb_of_NSA_cells}                      ${nb_NSA_cells}


Set Gscn Parameter Name
    [Documentation]                 INTERNAL USAGE
    ...                             TO BE COMPLETED
    ${gscnPattern} =                OperatingSystem.Grep File               ${SCF_SETUP_PATH}           gscnOrSsPbchArfcn
    ${nomalizedPattern} =           set variable    ${gscnPattern.replace('\r','\\r').replace('\n','\\n')}
    ${gscnParameterName}            set variable if                         '${nomalizedPattern}' == '${EMPTY}'
    ...                             gscn                                    gscnOrSsPbchArfcn
    set suite variable              ${gscnParameterName}
    Dated Log                       GSCN:Parameter name=${gscnParameterName}


Clean Plan
    Call method                     ${GNB_CU.oam}               remove_all_plan
    Call method                     ${GNB_DU.oam}               remove_all_plan


Clean Simu Basic Files
    [Documentation]                 Erase all basic step2 cfg and lua files
    ${alias}                        SSH Connect                 ${HOST_EPCSIM}
    ${myCommand}=                   set variable                rm -f ${tl.core.dir_path}/basic*step2*.*;rm -rf /tmp/ute/
    ${result}=                      SSH Exec                    command=${myCommand}
    ...                                                         alias=${alias}


Purge Log Files
    [Documentation]                 Purge the specified directory of files with the specified extension. ClassicalBTS only
    ...
    ...                             *Argument details:*
    ...                             - *path*: full pathname to directory where files should be removed (default value = /ffs/run/logs )
    ...                             - *extension*: file extension (default value = pcap)
    ...                             - *gnb_id*: allow to select the GNB in case of multiGNB topology (default value = 0)
    ...                             - *du_id*: allow to select the DU in case of multiDU topology (default value = 0)
    ...                             - *cu_id*: allow to select the CU in case of multiCU topology(default value = 0)
    ...                             - *board_id*: Board Id (default value = 1)
    ...                             - *cpu_id*: COU id (default value = 0)
    [Arguments]                     ${path}=/ffs/run/logs
    ...                             ${extension}=pcap
    ...                             ${gnb_id}=0
    ...                             ${du_id}=0
    ...                             ${cu_id}=0
    ...                             ${board_id}=1
    ...                             ${cpu_id}=0
    ${hostname}                     set variable        ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${cu_id}].lmp_connection.addr}
    ${username}                     set variable        ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${cu_id}].lmp_connection.username}
    ${password}                     set variable        ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${cu_id}].lmp_connection.password}
    ${target}                       set variable        ${path}/*.${extension}
    ${files_list_before}=           OperatingSystem.Run   sshpass -p ${password} ssh ${username}@${hostname} bsh ${board_id}:${cpu_id} ls -l ${target}
    ${result}=                      OperatingSystem.Run   sshpass -p ${password} ssh ${username}@${hostname} bsh ${board_id}:${cpu_id} rm ${target}


Get Number of Cells
    [Documentation]                 Return the total number of NR cells
    [Arguments]                     ${entity}=${TGNB_DU[${0}]}
    return from keyword if          '${entity}'=='None'
    StringTool.printLineWithTitle   Get TL info from OAM ${entity.oam.alias} : [${entity.oam}]
    ${postfix}                      OAM Get Postfix                         ${entity.oam}
    ${endStr}                       Set Variable                            ${postfix}\[${entity.index}]
    [Return]                        ${TNRCELL_NB${endStr}}


Get Cell Info
    [Documentation]                 Return the requested FDD or TDD Cell info, depending of input parameter
    ...
    ...                             *Argument details:*
    ...                             - cellType: Either FDD or TDD.
    ...                             - cellRank: Rank of the cell.
    ...                             - cellParam: Either physCellId, cellDepType or nrCellId
    ...
    ...                             *Example:*
    ...                             | ${Tdd_Cell2_cellType} | Get Cell Info | cellType=TDD | cellRank=2 | cellParam=nrCellId |
    ...                             The ${Tdd_Cell2_cellType} variable will receive either "SA+NSA" or "SA" or "NSA" value.

    [Arguments]                     ${cellType}
    ...                             ${cellRank}
    ...                             ${cellParam}
    # First, we process the error cases:
    Should Be True                  '${cellType}'=='FDD' or '${cellType}'=='TDD'    msg=ERROR - WRONG CELL TYPE: ${cellType}
    # No imagined error detected, we can process the user request
    ${value}                        Get FDD or TDD Cell Info        cellType=${cellType}
    ...                                                             cellRank=${cellRank}
    ...                                                             cellParam=${cellParam}
    ${str_value} =                  Convert To String               ${value}
    should not contain              ${str_value}                    ERROR                   msg=${str_value}
    Dated Log                       ${cellType} Cell Rank ${cellRank}: ${cellParam}=${value}
    [Return]                        ${value}


Get FDD or TDD Cell Info
    [Documentation]                 INTERNAL USAGE
    ...                             Return the requested TDD or FDD Cell info
    [Arguments]                     ${cellType}
    ...                             ${cellRank}
    ...                             ${cellParam}=None
    # First, we process the error cases:
    ${listLenght}                   get length                              ${${cellType}_Cell_list}
    Should Be True                  '${listLenght}'>'0'                     msg=ERROR - THERE IS NO ${cellType} CELL!!
    Should Be True                  '${cellRank}'<='${listLenght}'          msg=ERROR - WRONG CELL INDEX: ${cellRank} > ${listLenght}
    ${id}                           evaluate                                ${cellRank} - ${1}
    ${IsKeyExist}                   run keyword and return status
    ...                             Dictionary should contain key           ${${cellType}_Cell_list[${id}]}    ${cellParam}
    Should Be True                  ${IsKeyExist}                           msg=ERROR - THE "${cellParam}" KEY DOES NOT EXIST!!
    # No imagined error detected, we can read the dictionary:
    return from keyword             ${${cellType}_Cell_list[${id}].${cellParam}}


Setup AgentType
    [Documentation]                 INTERNAL USAGE
    ${agentType}                    OsTool.isAgentCAOrAgentSim
    set global variable             ${agentType}


#=======================================================================================================================
# Apply Custom Config - Could be used during testcase execution
#=======================================================================================================================
Apply Custom Config
    [Documentation]                 Allow to install customised files like SCF and/or IPHY and/or BASIC files
    ...                             and allow to set parameters like Rad Params and/or Vendor Params.
    ...
    ...                             IMPORTANT: Rad Params and Vendor Params ARE NOT MANAGED ON VRAN testlines.
    ...
    ...                             IMPORTANT: On Classical, Rad Params and Vendor Params modification require to provide a SCF file.
    ...
    ...                             Vendor parameters and Rad Parameters should be declared through a list:
    ...                             | @{myVendorParams}     | NRBTS.bbPoolCapacity.maxNumDlSubcellL1Pool=3  |
    ...                             | ...                   | LNBTS.dddsPeriod=10ms                         |
    ...                             | ...                   | NRBTS.cbtsFlowControlProf.dddsPeriod=3        |
    ...                             | @{myRadParams}        | 0x580117=1                                    |
    ...                             |                       | 0x1A1300 = 0                                  |
    ...
    ...                             Examples:
    ...                             | Apply Custom Config   | scfc=${CURDIR}/config/myNewSCF.xml            |
    ...                             |                       | vendor_params=${myVendorParams}               |
    ...                             |                       | rad_params=${myRadParams}                     |
    ...
    ...                             | Apply Custom Config   | scfc=${CURDIR}/config/myNewDU_SCF.xml         |
    ...                             |                       | vcu_scfc=${CURDIR}/config/myNewCU_SCF.xml     |
    ...
    [Arguments]                     ${scfc}=${EMPTY}
    ...                             ${vcu_scfc}=${EMPTY}
    ...                             ${iphy}=${EMPTY}
    ...                             ${cfg}=${EMPTY}
    ...                             ${rad_params}=${EMPTY}
    ...                             ${vendor_params}=${EMPTY}

    Set Suite variable              ${launch_conf}                      ${False}
    ${setup_case}                   Check Custom Config params          yamlPathname=${EMPTY}
    ...                                                                 scfcPathname=${scfc}
    ...                                                                 cuScfcPathname=${vcu_scfc}
    ...                                                                 iphyPathname=${iphy}
    ...                                                                 basicPathname=${cfg}
    ...                                                                 rad_params=${rad_params}
    ...                                                                 vendor_params=${vendor_params}
    Should Be True                  '${setup_case}'!='ERROR'            ERROR: Please check input parameters.

    Setup.save_original_files       target=${LOG_PATH}/Backup_DeliveredFiles
    Setup.save_custom_config_files  scfc=${scfc}
    ...                             cuScfc=${vcu_scfc}
    ...                             iphy=${iphy}
    ...                             basic=${cfg}
    ...                             target=${LOG_PATH}/Backup_CustomConfig

    Run Keyword If                  not ${isAic}
    ...                             Apply Custom SCFC File              scfc=${scfc}
    ...                                                                 rad_params=${rad_params}
    ...                                                                 vendor_params=${vendor_params}
    ...         ELSE                Apply Custom DU and CU SCFC Files   vdu_scfc=${scfc}
    ...                                                                 vcu_scfc=${vcu_scfc}

    Run Keyword If                  '${iphy}'!='${EMPTY}'
    ...                             Run keywords
    ...                                     Dated Log                   Custom iphy=/tmp/iphy.xml = local copy of ${iphy}
    ...                             AND     OperatingSystem.Run         cp -p ${iphy} /tmp/iphy.xml
    ...                             AND     add simulator               sim_type=airphone           config=/tmp/iphy.xml
    ...                             AND     Set Suite variable          ${launch_conf}              ${True}

    Run Keyword If                  '${cfg}'!='${EMPTY}'
    ...                             Run keywords
    ...                                     Dated Log                   Custom basic=${cfg}
    ...                             AND     Save Custom Basic File      basic=${cfg}
    ...                             AND     add 5gc                     config=${cfg}
    ...                             AND     Set Suite variable          ${launch_conf}              ${True}

    Run Keyword If                  '${launch_conf}'=='${True}'
    ...                             Run keywords
    ...                                     Dated Log                   Configure Environment in progress...
    ...                             AND     WTS Kill All eGate
    ...                             AND     configure environment
    ...         ELSE                Dated Log New Line                  WARNING: No input parameters => Nothing to do !

    # If SCF is used, we have to update global variables: GNB_BTS_INFO, MRBTS_ID, NRCELL_DIST_NAME, NRBTS_ID and NRCELL_GRP
    Run Keyword If                  '${scfc}'!='${EMPTY}'
    ...                             Run keywords
    ...                                     Dated Log                   New scfc => global variables update
    ...                             AND     Get TL Info From Oam        entity=${TGNB_DU[${0}]}
    ...                             AND     OAM Build FDD TDD Cells Dict


Apply Custom SCFC File
    [Documentation]                 INTERNAL USAGE
    ...                             This KW will apply the SCFC, rad and vendor params if they exist.
    ...                             Return True or False depending if configure envrionment should be run or not.
    [Arguments]                     ${scfc}=${EMPTY}
    ...                             ${rad_params}=${EMPTY}
    ...                             ${vendor_params}=${EMPTY}
    Run Keyword If                  '${scfc}'!='${EMPTY}'
    ...                             Run keywords
    ...                                     Dated Log                   Custom scfc=${scfc}
    ...                             AND     Dated Log                   Custom rad_params=${rad_params}
    ...                             AND     Dated Log                   Custom vendor_params=${vendor_params}
    ...                             AND     add gnb configuration       scfc=${scfc}
    ...                                                                 rad_params=${rad_params}
    ...                                                                 vendor_params=${vendor_params}
    ...                             AND     Set Suite variable          ${launch_conf}          ${True}
    ...         ELSE IF             "${rad_params}"!="${EMPTY}"
    ...                             Run keywords
    ...                                     Dated Log                   Custom rad_params=${rad_params}
    ...                             AND     add gnb configuration       rad_params=${rad_params}
    ...                             AND     Set Suite variable          ${launch_conf}          ${True}


Apply Custom DU and CU SCFC Files
    [Documentation]                 INTERNAL USAGE
    ...                             This KW will apply the DU SCF and CU SCFC if they exist.
    ...                             It updates the launch_conf variable to True/False depending if configure_environment should be run or not.
    [Arguments]                     ${vdu_scfc}=${EMPTY}
    ...                             ${vcu_scfc}=${EMPTY}

    return from keyword if          '${vdu_scfc}'=='${EMPTY}' and '${vcu_scfc}'=='${EMPTY}'             ERROR: NO SCFC FILES FOUND!
    ${vdu_scfc}                     Set Variable If                     '${vdu_scfc}'=='${EMPTY}'       None    ${vdu_scfc}
    ${vcu_scfc}                     Set Variable If                     '${vcu_scfc}'=='${EMPTY}'       None    ${vcu_scfc}
    Dated Log                       Custom DU SCFC=${vdu_scfc}
    Dated Log                       Custom CU SCFC=${vcu_scfc}
    add_cloud_bts_configuration     vdu_scfc=${vdu_scfc}                vcu_scfc=${vcu_scfc}
    Set Suite variable              ${launch_conf}                      ${True}


Save Custom Basic File
    [Documentation]                 INTERNAL USAGE
    ...                             This KW will backup the custom basic cfg file into /opt/wts/latest repository.
    [Arguments]                     ${basic}=${EMPTY}
    ${BasicFileName}                getFileNameFromPath                 ${basic}
    OperatingSystem.Run             cp -pu /opt/wts/latest/basic_setup.cfg /opt/wts/latest/basic_setup.cfg.ori
    OperatingSystem.Run             cp ${basic} /opt/wts/latest/${BasicFileName}
    OperatingSystem.Run             ln -sf /opt/wts/latest/${BasicFileName} /opt/wts/latest/basic_wts_step2.cfg


#=======================================================================================================================
# Custom Config Tools - Used Only During "Suite Setup" process - Classical and VRAN BTS
#=======================================================================================================================
Setup Custom Config
    [Documentation]                 INTERNAL USAGE
    ...                             Either install all files indicated into the Custom YAML file,
    ...                             Or install individual custom files,
    ...                             Or do nothing if all arguments are empty
    ...                             For VRAN BTS, the rad params are not managed => use the KW in Airframes.robot.
    ...
    [Arguments]                     ${yamlPathname}=${EMPTY}
    ...                             ${scfcPathname}=${EMPTY}
    ...                             ${cuScfcPathname}=${EMPTY}
    ...                             ${iphyPathname}=${EMPTY}
    ...                             ${basicPathname}=${EMPTY}
    ...                             ${rad_params}=${EMPTY}
    ...                             ${vendor_params}=${vendor_params}
    ${setup_case}                   Check Custom Config params          yamlPathname=${yamlPathname}
    ...                                                                 scfcPathname=${scfcPathname}
    ...                                                                 cuScfcPathname=${cuScfcPathname}
    ...                                                                 iphyPathname=${iphyPathname}
    ...                                                                 basicPathname=${basicPathname}
    ...                                                                 rad_params=${rad_params}
    ...                                                                 vendor_params=${vendor_params}
    Should Be True                 '${setup_case}'!='ERROR'             ERROR: Please check the Suite Setup parameters.
    set suite variable              ${TL_ConfigType}                    ${setup_case}
    StringTool.printHeaderLine      name=CUSTOM_CONFIG_TYPE             value=${TL_ConfigType}
    ${isTopoVR}                     setup.checkTopoFromAgentLogFile
    set suite variable              ${isTopoVR}
    Run Keyword If                  '${TL_ConfigType}'=='YAML_CUSTOM_CONFIG'
    ...                             YAML Custom Config                  yamlPathname=${yamlPathname}
    ...                                                                 vendor_params=${vendor_params}
    ...                                                                 rad_params=${rad_params}
    ...         ELSE IF            '${TL_ConfigType}'=='UNITARY_CUSTOM_CONFIG'
    ...                             Unitary Custom Config               scfcPathname=${scfcPathname}
    ...                                                                 cuScfcPathname=${cuScfcPathname}
    ...                                                                 iphyPathname=${iphyPathname}
    ...                                                                 basicPathname=${basicPathname}
    ...                                                                 rad_params=${rad_params}
    ...                                                                 vendor_params=${vendor_params}
    ...                                                                 rootPathname=${EMPTY}


YAML Custom Config
    [Documentation]                 INTERNAL USAGE
    ...                             Parse the yaml file to get full location of requested files. Then call the file installation tool
    [Arguments]                     ${yamlPathname}=${EMPTY}
    ...                             ${vendor_params}=${EMPTY}
    ...                             ${rad_params}=${EMPTY}
    ${scfc}  ${cuScfc}  ${iphy}  ${basic}  ${path}       Analyze The Yaml File       ${yamlPathname}
    Run Keyword If                  not ${isTopoVR} and '${scfc}'=='${EMPTY}' and "${vendor_params}"!="${EMPTY}"
    ...                             Should Be True      ${True}==${False}           ERROR: vendor_params is set but there is no vDU SCF in YAML file!
    Run Keyword If                  ${isTopoVR} and "${vendor_params}"!="${EMPTY}"
    ...                             Should Be True      ${True}==${False}           ERROR: vendor_params is not allowed on VRAN TL!
    Run Keyword If                  ${isTopoVR} and "${rad_params}"!="${EMPTY}"
    ...                             Should Be True      ${True}==${False}           ERROR: rad_params is not allowed on VRAN TL!
    Unitary Custom Config           scfcPathname=${scfc}
    ...                             cuScfcPathname=${cuScfc}
    ...                             iphyPathname=${iphy}
    ...                             basicPathname=${basic}
    ...                             rad_params=${rad_params}
    ...                             vendor_params=${vendor_params}
    ...                             rootPathname=${path}


Analyze The Yaml File
    [Documentation]                 INTERNAL USAGE
    ...                             First, it analyzes the yaml file to get requested custom config files
    ...                             Then, it saves the requested custom config files in ${LOG_PATH}/CUSTOM_FILES/
    ...                             And then, it returns 4 pathnames: one per files (scfc, iphy, basic and swconfig)
    [Arguments]                     ${yamlPathname}=${EMPTY}
    ${scfc}                         Set variable        ${EMPTY}
    ${cuScfc}                       Set variable        ${EMPTY}
    ${iphy}                         Set variable        ${EMPTY}
    ${basic}                        Set variable        ${EMPTY}
    ${path}                         Set variable        ${EMPTY}
    ${scfc} =                       Get Info From YAML File     yaml_file=${yamlPathname}     file_type=scfc        hw_type=du          hw_id=1
    ${cuScfc} =                     Get Info From YAML File     yaml_file=${yamlPathname}     file_type=scfc        hw_type=cu          hw_id=1
    ${iphy} =                       Get Info From YAML File     yaml_file=${yamlPathname}     file_type=iphy_xml    hw_type=airphone    hw_id=1
    ${basic} =                      Get Info From YAML File     yaml_file=${yamlPathname}     file_type=wts_cfg     hw_type=vm          hw_id=1
    ${path} =                       Setup.root_to_custom_config_dir
    # RDH: line put in comment as not sure it is usefull for vran and classical case:
    # ${path}                         Setup.get_pathname          pathname=${yamlPathname}
    [Return]                        ${scfc}    ${cuScfc}    ${iphy}    ${basic}    ${path}


Get Info From YAML File
    [Documentation]                 Analyze the YAML file to return the requested file path.
    ...                             IMPORTANT: the YAML structure should respect this order and this syntax (double quote characters are mandatory):
    ...                             - file_type: "scfc"
    ...                             - file_path: "TSCF_DU0_Setup.xml"
    ...                             - hw_id: 1
    ...                             - hw_type: "du"
    ...
    ...                             Input Parameters:
    ...                             - yaml_file: pathname to YAML file
    ...                             - file_type: scfc, swconfig, iphy_xml, wts_cfg or dockerfile (not yet implemented)
    ...                             - hw_type: du, cu, vm or airphone
    ...                             - hw_id (def.val=1): allow to select a specific CU in case there are several CUs
    ...
    ...                             Return: the file_path associated to the input parameters
    ...
    [Arguments]                     ${yaml_file}=None
    ...                             ${file_type}=None
    ...                             ${hw_type}=None
    ...                             ${hw_id}=1

    # Input parameters check:
    return from keyword if          "${yaml_file}"=="None" or "${file_type}"=="None" or "${hw_type}"=="None"        ERROR: BAD INPUT PARAMETERS

    # reformat file_type and hw_type data by adding double quote characters around them to be compliant with YAML file format:
    ${file_type}                    set variable        "${file_type}"
    ${hw_type}                      set variable        "${hw_type}"
    # create crucial commands:
    ${fileType_cmd}                 set variable        awk -v n=0 '/${file_type}/ { mLine = NR } mLine && NR == mLine +n' ${yaml_file}
    ${filePath_cmd}                 set variable        awk -v n=1 '/${file_type}/ { mLine = NR } mLine && NR == mLine +n' ${yaml_file}
    ${hwType_cmd}                   set variable        awk -v n=2 '/${file_type}/ { mLine = NR } mLine && NR == mLine +n' ${yaml_file}
    ${hwId_cmd}                     set variable        awk -v n=3 '/${file_type}/ { mLine = NR } mLine && NR == mLine +n' ${yaml_file}
    ${hwType_cmd2}                  set variable        awk -v n=3 '/${file_type}/ { mLine = NR } mLine && NR == mLine +n' ${yaml_file}
    ${hwId_cmd2}                    set variable        awk -v n=2 '/${file_type}/ { mLine = NR } mLine && NR == mLine +n' ${yaml_file}

    # calculate the number of file_type present in the YAML file:
    ${nb_item} =                    run     ${fileType_cmd} | wc -l
    ${nb_item} =                    convert to integer      ${nb_item}

    # return file_path if it correspond to input data
    ${response}                     set variable        None
    FOR   ${item}   IN RANGE   0   ${nb_item}
        # some setup:
        ${i} =                      evaluate            ${item} + 2
        ${cut_cmd}                  set variable        cut -d ":" -f2 | tr -d "\\n" | cut -d " " -f${i}
        ${del_quote}                set variable        tr -d '"'
        # get info from YAML file:
        ${filePath_val}             run                 ${filePath_cmd} | ${cut_cmd} | ${del_quote}
        ${hwType_val}               run                 ${hwType_cmd} | ${cut_cmd}
        ${len}                      Get Length          ${hwType_val}
        ${hwId_val}                 run keyword if      ${len}>2
        ...                                             run     ${hwId_cmd} | ${cut_cmd}
        ...                                     ELSE    run     ${hwId_cmd2} | ${cut_cmd}
        ${hwType_val}               run keyword if      ${len}>2
        ...                                             run     ${hwType_cmd} | ${cut_cmd}
        ...                                     ELSE    run     ${hwType_cmd2} | ${cut_cmd}
        ${hwId_val} =               convert to integer  ${hwId_val}
        # check if specified file is found or not:
        ${response}                 Set Variable If     ${hwId_val}==${hw_id} and ${hwType_val}==${hw_type}         ${filePath_val}
        Return from keyword if      "${response}" != "None"         ${response}
    END
    return from keyword             ${EMPTY}


Unitary Custom Config
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${scfcPathname}=${EMPTY}
    ...                             ${cuScfcPathname}=${EMPTY}
    ...                             ${iphyPathname}=${EMPTY}
    ...                             ${basicPathname}=${EMPTY}
    ...                             ${rad_params}=${EMPTY}
    ...                             ${vendor_params}=${EMPTY}
    ...                             ${rootPathname}=${EMPTY}
    Setup.save_original_files       target=${LOG_PATH}/Backup_DeliveredFiles
    Setup.save_custom_config_files  scfc=${scfcPathname}
    ...                             cuScfc=${cuScfcPathname}
    ...                             iphy=${iphyPathname}
    ...                             basic=${basicPathname}
    ...                             target=${LOG_PATH}/Backup_CustomConfig
    ...                             root=${rootPathname}
    Install Custom Files            iphy=${iphyPathname}
    ...                             basic=${basicPathname}
    ...                             path=${rootPathname}
    # Some essential initializations:
    Add WTS IP Addresses
    Kill egate edaemon
    Sleep                           1s
    # now let's continue:
    Run Keyword If                  not ${isTopoVR}
     ...                            Apply YAML Custom Config        scfc=${scfcPathname}
    ...                                                             iphy=${iphyPathname}
    ...                                                             basic=${basicPathname}
    ...                                                             rad_params=${rad_params}
    ...                                                             vendor_params=${vendor_params}
    ...                                                             path=${rootPathname}
    ...         ELSE                Apply YAML Custom Config VRAN   vdu_scfc=${scfcPathname}
    ...                                                             vcu_scfc=${cuScfcPathname}
    ...                                                             iphy=${iphyPathname}
    ...                                                             basic=${basicPathname}
    ...                                                             path=${rootPathname}
    Kill egate edaemon
    Traced Sleep                    duration=180sec                    msg=SIBs Setup Detection Improvement.
    Run                             cp /opt/iphy/latest/egate_console.log ${LOG_PATH}/egate_console_afterCustomConfig.log


Install Custom Files
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${iphy}=${EMPTY}
    ...                             ${basic}=${EMPTY}
    ...                             ${path}=${EMPTY}
    Run Keyword if                  '${basic}'!='${EMPTY}'              Setup.copy_custom_basic_file        file=${path}/${basic}
    Run Keyword if                  '${iphy}'!='${EMPTY}'               Setup.copy_custom_iphy_file         file=${path}/${iphy}


Apply YAML Custom Config
    [Documentation]                 INTERNAL USAGE
    ...                             Install customised files on a Classical BTS.
    ...                             It means: SCF, iphy, basic, rad_param and vendor_param
    [Arguments]                     ${scfc}=${EMPTY}
    ...                             ${iphy}=${EMPTY}
    ...                             ${basic}=${EMPTY}
    ...                             ${rad_params}=${EMPTY}
    ...                             ${vendor_params}=${EMPTY}
    ...                             ${path}=${EMPTY}
    StringTool.printHeaderLine      name=CUSTOM CONFIG DIR              value=${path}
    StringTool.printHeaderLine      name= - SCFC file                   value=${scfc}
    StringTool.printHeaderLine      name= - IPHY file                   value=${iphy}
    StringTool.printHeaderLine      name= - BASIC file                  value=${basic}
    StringTool.printHeaderLine      name= - Rad Params                  value=${rad_params}
    StringTool.printHeaderLine      name= - Vendor Params               value=${vendor_params}
    ${launch_conf}                  set variable                        ${False}
    Run Keyword If                  '${scfc}'!='${EMPTY}'
    ...                             Run keywords
    ...                                     add gnb configuration       scfc=${path}/${scfc}
    ...                                                                 rad_params=${rad_params}
    ...                                                                 vendor_params=${vendor_params}
    ...                             AND     Set Suite variable          ${launch_conf}          ${True}
    ...         ELSE IF             "${rad_params}"!="${EMPTY}"
    ...                             Run keywords
    ...                                     add gnb configuration       rad_params=${rad_params}
    ...                             AND     Set Suite variable          ${launch_conf}          ${True}
    Run Keyword If                  '${iphy}'!='${EMPTY}'
    ...                             Run keywords
    ...                                     Dated Log                   Creation of /tmp/iphy.xml = local copy of ${path}/${iphy}
    ...                             AND     OperatingSystem.Run         cp -p ${path}/${iphy} /tmp/iphy.xml
    ...                             AND     add simulator               sim_type=airphone       config=/tmp/iphy.xml
    ...                             AND     Set Suite variable          ${launch_conf}          ${True}
    Run Keyword If                  '${basic}'!='${EMPTY}'
    ...                             Run keywords
    ...                                     add 5gc                     config=${path}/${basic}
    ...                             AND     Set Suite variable          ${launch_conf}          ${True}
    Run Keyword If                  '${launch_conf}'=='${True}'
    ...                             Run keywords
    ...                                     StringTool.printHeaderLine  name=Configure Environment in progress...
    ...                                                                 value=> please wait
    ...                             AND     WTS Kill All eGate
    ...                             AND     configure environment
    ...         ELSE                Dated Log New Line                  WARNING: No input parameters => Nothing to do !


Apply YAML Custom Config VRAN
    [Documentation]                 INTERNAL USAGE
    ...                             Install customised files on a VRAN BTS.
    ...                             It means: SCF DU, SCF CU, iphy, basic
    [Arguments]                     ${vdu_scfc}=${None}
    ...                             ${vcu_scfc}=${None}
    ...                             ${iphy}=${EMPTY}
    ...                             ${basic}=${EMPTY}
    ...                             ${path}=${EMPTY}

    ${launch_conf}                  set variable                        ${False}
    ${path_to_vdu_scfc}             Set Variable If                     '${vdu_scfc}'!='${None}' and '${path}'=='${EMPTY}'
    ...                                                                 ${vdu_scfc}         ${path}/${vdu_scfc}
    ${path_to_vcu_scfc}             Set Variable If                     '${vcu_scfc}'!='${None}' and '${path}'=='${EMPTY}'
    ...                                                                 ${vcu_scfc}         ${path}/${vcu_scfc}
    ${path_to_iphy}                 Set Variable If                     '${iphy}'!='${EMPTY}' and '${path}'=='${EMPTY}'
    ...                                                                 ${iphy}             ${path}/${iphy}
    ${path_to_basic}                Set Variable If                     '${basic}'!='${EMPTY}' and '${path}'=='${EMPTY}'
    ...                                                                 ${basic}            ${path}/${basic}

    StringTool.printHeaderLine      name=CUSTOM CONFIG DIR              value=${path}
    StringTool.printHeaderLine      name= - DU SCFC file                value=${path_to_vdu_scfc}
    StringTool.printHeaderLine      name= - CU SCFC file                value=${path_to_vcu_scfc}
    StringTool.printHeaderLine      name= - IPHY file                   value=${path_to_iphy}
    StringTool.printHeaderLine      name= - BASIC file                  value=${path_to_basic}

    Run Keyword If                  '${path_to_vdu_scfc}'!='${None}' or '${path_to_vcu_scfc}'!='${None}'
    ...                             run keywords
    ...                                     add_cloud_bts_configuration     vdu_scfc=${path_to_vdu_scfc}    vcu_scfc=${path_to_vcu_scfc}
    ...                             AND     Set Suite variable              ${launch_conf}                  ${True}

    Run Keyword If                  '${path_to_iphy}'!='${EMPTY}'
    ...                             Run keywords
    ...                                     Dated Log                   Creation of /tmp/iphy.xml = local copy of ${path}/${iphy}
    ...                             AND     OperatingSystem.Run         cp -p ${path_to_iphy} /tmp/iphy.xml
    ...                             AND     add simulator               sim_type=airphone       config=/tmp/iphy.xml
    ...                             AND     Set Suite variable          ${launch_conf}          ${True}

    Run Keyword If                  '${path_to_basic}'!='${EMPTY}'
    ...                             Run keywords
    ...                                     add 5gc                     config=${path_to_basic}
    ...                             AND     Set Suite variable          ${launch_conf}          ${True}

    Run Keyword If                  '${launch_conf}'=='${True}'
    ...                             Run keywords
    ...                                     StringTool.printHeaderLine  name=Configure Environment in progress...
    ...                                                                 value=> please wait
    ...                             AND     WTS Kill All eGate
    ...                             AND     configure environment
    ...         ELSE                Dated Log New Line                  WARNING: No input parameters => Nothing to do !


Kill egate edaemon
    [Documentation]                 INTERNAL USAGE
    ...                             Clean all remaining and unexpected egate and edaemon processes.
    OperatingSystem.Run             sudo pkill -9 egate; sudo pkill -9 edaemon


Save Egate Console Log
    [Arguments]                     ${pattern}=${EMPTY}
    OsTool.saveFileWithDateFilePattern
    ...                             pathname=${tl.core.dir_path}
    ...                             fileName=egate_console.log
    ...                             logpath=${LOG_PATH}
    ...                             pattern=${pattern}


Save and Clear Egate Console Log
    [Arguments]                     ${pattern}=${EMPTY}
    OsTool.saveFileWithDateFilePattern
    ...                             pathname=${tl.core.dir_path}
    ...                             fileName=egate_console.log
    ...                             logpath=${LOG_PATH}
    ...                             pattern=${pattern}
    OperatingSystem.run             rm -f ${tl.core.dir_path}/egate_console.*


Add WTS IP Addresses
    [Documentation]                 INTERNAL USAGE
    ...                             Add mandatory IP addresses defined by IP_LIST list in UteTools.robot file.
    FOR    ${ip}    IN              @{IP_LIST}
        OperatingSystem.Run         sudo ip addr add ${ip}/24 dev eth3
    END

Loop Until IsOk Is True Or Timeout
    ${start_time}=    Get Time    epoch
    WHILE    ${True}
        ${power}    ${isOk}=    Archi.checkSleepingStateOrNot    hw=GNB    unit=DU
        Run Keyword If    ${isOk}    Exit For Loop
        ${current_time}=    Get Time    epoch
        ${elapsed_time}=    Evaluate    ${current_time} - ${start_time}
        Run Keyword If    ${elapsed_time} >= ${TIMEOUT}    Fail    Timeout reached while waiting for isOk to be True
        Sleep    20s  # Optional: Add a small delay to avoid excessive looping
    END

Waiting keyword
    [Documentation]    INTERNAL USAGE
    ...    Wait for a ping to be successful on a given IP address.
    ...    If the ping is not successful within the timeout, it will retry at specified intervals.
    [Arguments]    ${ip}=192.168.255.129    ${timeout}=50s    ${retry_interval}=10    ${successful_ping_count}=4
    @{IPs}    Create List    ${ip}
    Wait Until Keyword Succeeds     600s      250s     wait_for_ping
    ...            timeout=${timeout}    ip_addresses=${IPs}    retry_interval=${retry_interval}
    ...            successful_ping_count=${successful_ping_count}
