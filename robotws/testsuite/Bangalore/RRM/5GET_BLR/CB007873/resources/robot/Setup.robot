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
...             | True      | Test Teardown is launched after every failed tests      |
...             | False     | Test Teardown is never launched (default value)         |
...             | Force     | Test Teardown is launched at suite teardown             |
...             | FirstFail | Test Teardown is launched ONLY after first failed test  |
...
...             Concerning Suite Setup, 2 services are proposed :
...
...             | Suite Setup              | Basic suite setup            |
...             | Suite Setup From Scratch | Same as previous + WTS clear |
...             Interest of Suite Setup (not from scratch) is that it is not destructive.
...             It means a Suite Setup can be launched on a TL in // of another test runnning.
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
Resource                            Tools.robot
Resource                            Connect.robot
Resource                            Oam.robot
Resource                            Container.robot
Resource                            CallSetup.robot
Resource                            Backup.robot
Resource                            Topology.robot
Resource                            UteTools.robot
Resource                            Workaround.robot

Library                             ../../../resources/NPS/SWENG/python/StringTool.py
Library                             ../../../resources/NPS/SWENG/python/Archi.py
# Library                             ../python/Airscales.py
Library                             ../../../resources/NPS/SWENG/python/Setup.py
Library                             ../../../resources/NPS/SWENG/python/Backup.py
Library                             ../../../resources/NPS/SWENG/python/Captures.py
Library                             ../../../resources/NPS/SWENG/python/Connect.py

*** Variables ***
${STATUS_FILE_NAME}                 Status_Before_Testsuite.txt
@{NO_BACKUP_FILES}
${enable_sherpa}
*** Keywords ***
#=======================================================================================================================
# Suite/Test setup/teardown
#=======================================================================================================================
Test Setup
    [Documentation]                 Generic Test setup part if it is used in tests
    ...                             Cuurently, does nothing
    Dated Log                       Start Test Setup

Suite Setup From Scratch
    [Documentation]                 Generic Suite Setup for tests
    ...                             Update all global variables, discover topology, read SCFs, backup config files
    ...                             Also, WTS is resetted
    ...                             Argument : listBackupFiles : contains the list of file description to be backuped
    ...                             Argument : automaticTeardown : indicates how to proceed for teardown
    ...                             Default value is false, possible values:
    ...                             automaticTeardown=True         launched after every failed tests
    ...                             automaticTeardown=False        Never launched (default value)
    ...                             automaticTeardown=Force        launched at suite teardown
    ...                             automaticTeardown=FirstFail    launched ONLY after first failed test
    ...                             also, the argument <listBackupFiles> provides the list of config file to be backuped
    ...                             By default, no files are backuped. The global variables @{FD_ALL} may be used
    ...                             to backup all config files. See Backup.robot and Backup.py for more details.
    ...                             Argument : keepAllUeDataInCfgFile : set to "True" to keep all UE data in the basic.cfg file
    ...                                        Default value = "False" (i.e. remove all UE data execpted for UE 1 and UE 11)
    [Arguments]                     ${listBackupFiles}=${NO_BACKUP_FILES}
    ...                             ${automaticTeardown}=${False}
    ...                             ${keepAllUeDataInCfgFile}=${False}
    Suite Setup                     listBackupFiles=${listBackupFiles}
    ...                             automaticTeardown=${automaticTeardown}
    ...                             keepAllUeDataInCfgFile=${keepAllUeDataInCfgFile}
    WTS Clear

Suite Setup
    [Documentation]                 Generic Suite Setup for tests, excluding WTS reset
    [Arguments]                     ${listBackupFiles}=${NO_BACKUP_FILES}
    ...                             ${automaticTeardown}=${False}
    ...                             ${keepAllUeDataInCfgFile}=${False}
    Log to console                  Suite Setup
    Setup Init Variables            automaticTeardown=${automaticTeardown}
    Setup Ute Env if required       keepAllUeDataInCfgFile=${keepAllUeDataInCfgFile}
    get_l1_mode                     ${TLConfig}
    call method                     ${TLConfig}                             printConfig
    TOPO Read
    Get TL Info
    Return From Keyword if          ${isAic}
    OAM Get SCF Files
    UpdateCapture
    UpdateBackupFilesDesc
    Suite Backup Files              listBackupFiles=${listBackupFiles}
    Check Network Type
    Set Gscn Parameter Name
    Run Keyword if                  ${TLConfig.isGnbCloud}==${True}         WorkAround for CloudBTS X2AP link issue
    Run Keyword if                  ${TLConfig.isGnbCloud}==${True}         WorkAround for CloudBTS Traffic issue

Test Teardown
    [Documentation]                 Generic Test teardown
    ...                             Get sos report and snapshot only if test is fail
    Dated Log                       Start Test Teardown
    Run keyword if                  '${TEST_STATUS}'=='FAIL'
    ...                             Test Teardown if Fail

Test Teardown if Fail
    [Documentation]                 Get SOS report and Snashot. Should be invoked ONLY if test is FAIL
    Dated log                       Get Sos Report and Snapshot
    Get Sos Report
    Get Snapshot

Suite Teardown
    [Documentation]                 Restore config files and SCFs if required
    ...                             Argument reset_ap is a toggle to indicate if AP should be rebooted or not
    [Arguments]                     ${reset_ap}=${False}
    Log to console                  Suite Teardown
    Suite Restore Files
    OAM Restore Files               reset_ap=${reset_ap}
    Run keyword if                  "${automaticTeardown}"=="Force"         Test Teardown if Fail

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
    # Compute LOG path
    # Replace " " with "_" to have a correct file name (because stupid robot replace _ with spaces)
    ${timestamp}                    Get Current Date                        result_format=%Y%m%d_%H%M%S%f
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

Setup Ute Env if required
    [Documentation]                 INTERNAL USAGE
    ...                             Update tl structure by adding WTS information if TL is an UTE one
    ...                             Argument : keepAllUeDataInCfgFile : set to "True" to keep all UE data in the basic.cfg file
    ...                                        Default value = "False" (i.e. remove all UE data execpted for UE 1 and UE 11)
    [Arguments]                     ${keepAllUeDataInCfgFile}=${False}
    # Update tl.core fields igf we are in UTE
    Run Keyword if                  ${TLConfig.isUTE}
    ...                             UteTools.Update TL for UTE Env
    # port for PM with TL ute
    Run Keyword If                  ${TLConfig.isUTE}                       Set suite variable
    ...                             ${tl.gnbs[0].cu.oam_http_connection_details.port}    443
    # Update EPCSIM ssh connection (all cases)
    call method                     ${HOST_EPCSIM}                          setSshConnection
    ...                             ${tl.core.default_ssh_connection_details}
    StringTool.printHeaderLine      name=EPCSIM:path to config file         value=${tl.core.dir_path}/${tl.core.cfg_filename}
    Run Keyword If                  ${keepAllUeDataInCfgFile}==${False}      Normalize WTS Config File

Normalize WTS Config File
    [Documentation]                 INTERNAL USAGE
    ...                             Remove all lines concerning UE id different from 1 or 11 in basic.cfg file from WTS
    ...                             On LO configuration, some additional id (2, 12, ...° may appear
    ...                             So, we remove them to come back to a known normalized state with only 1 and 11 ids
    ${cfg_path}                     Set Variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    StringTool.printHeaderLine      name=EPCSIM:Removing ids not in (1,11) in:
    ...                             value=${cfg_path}
    Run                             sed -i -e '/^set_ue simulated id=[0,2-9]/d' -e '/^set_ue simulated id=[0-9][0,2-9]/d' ${cfg_path}
    Run                             sed -i -e '/^ue_param id=[0,2-9]/d' -e '/^ue_param id=[0-9][0,2-9]/d' ${cfg_path}
    Run                             sed -i -e '/^set_pdu_gateway id=[0,2-9]/d' -e '/^set_pdu_gateway id=[0-9][0,2-9]/d' ${cfg_path}
    Run                             sed -i -e '/^set_bearer id=2 ue=[0,2-9]/d' -e '/^set_bearer id=2 ue=[0-9][0,2-9]/d' ${cfg_path}

#=======================================================================================================================
# Get TL Info
#=======================================================================================================================
Get TL Info
    [Documentation]                 INTERNAL USAGE
    ...                             Retrieve several info from TL: content of hardware and information from OAM
    ...                             Information retrieved are :
    ...                                 BTS_INFO, MRBTS_ID, NRCELL_DIST_NAME, NRCELL_DN, NRCELL_ID, NRCELL_DN_LIST, NRCELL_ID_LIST
    ...                                 GNB software version
    ...                                 GNB alarms
    Get TL Info Struct
    Return From Keyword if          ${isAic}
    Get TL Info From Oam            entity=${GNB_DU}                        create=${True}
    Get TL Info From Oam            entity=${GNB_CU}                        create=${False}

Get TL Info Struct
    [Documentation]                 Dynamic discovery of cards and hosts on TL,
    ...                             then dynamic discovery of containers
    ...                             GNB_DU, GNB_CU, AP_DU and AP_CU are the 4 global variables that should be used
    ...                             to access to all hosts/containers
    printLineWithTitle              title=Get INFO on TL (Dynamic discovery)
    ${GNB_CU}                       buildEntity                             hw=GNB   unit=CU
    ${GNB_DU}                       buildEntity                             hw=GNB   unit=DU
    ${AP_CU}                        buildEntity                             hw=AP    unit=CU
    ${AP_DU}                        buildEntity                             hw=AP    unit=DU
    Set global variable             ${GNB_DU}
    Set global variable             ${AP_DU}
    Set global variable             ${GNB_CU}
    Set global variable             ${AP_CU}
    Return From Keyword if          ${isAic}
    # Dynamic discovery of containers
    WA Update Nodes and Logs Def

Get TL Info From Oam
    [Documentation]                 INTERNAL USAGE
    ...                             Retrieve from an OAM some key ids, such as NRBTS_ID, MRBTS_ID, ...
    ...                             But also, Version and alamrs
    ...                             These information are put in some global variables, then stored in a file in Logs
    [Arguments]                     ${entity}=${GNB_DU}                     ${create}=${True}
    return from keyword if          '${entity}'=='None'
    StringTool.printLineWithTitle   Get TL info from OAM ${entity.oam.alias}
    @{alarms}                       OAM Get Active Alarms                   oam=${entity.oam}
    ${alias}                        OAM Connect                             ${entity.oam}
    ${version}                      OAM Get SW Version                      oam=${entity.oam}
    OAM Get GNB BTS Info            oam=${entity.oam}
    # Open file if required
    run keyword if                  ${create}
    ...                             Create File                             ${LOG_PATH}/${STATUS_FILE_NAME}
    # For each variable, display it, store in file, and eventually store in global variable
    ${postfix}                      OAM Get Postfix                         ${entity.oam}
    ${i}                            Set variable                            ${0}
    FOR  ${alarm}       IN          @{alarms}
        ${i}                        evaluate                                ${i}+${1}
        Trace and Store             val=${alarm}                            name=GNB${postfix}_OAM_ALARM[${i}]
    END
    # Trace and Store                 val=${alarms}                           name=GNB${postfix}_OAM_ALARMS
    Trace and Store                 val=${version}                          name=SW${postfix}
    Trace and Store                 val=${MRBTS_ID${postfix}}               name=MRBTS_ID${postfix}
    Trace and Store                 val=${NRBTS_ID${postfix}}               name=NRBTS_ID${postfix}
    Trace and Store                 val=${NRCELL_GRP${postfix}}             name=NRCELL_GRP${postfix}
    Trace and Store                 val=${NRCELL_DIST_NAME${postfix}}       name=NRCELL_DIST_NAME${postfix}
    Trace and Store                 val=${NRCELL_DN}                        name=NRCELL_DN
    Trace and Store                 val=${NRCELL_ID}                        name=NRCELL_ID
    Trace and Store                 val=${NRCELL_DN_LIST}                   name=NRCELL_DN_LIST
    Trace and Store                 val=${NRCELL_ID_LIST}                   name=NRCELL_ID_LIST
    [Teardown]                      Run keyword if                          '${entity}'!='None'
    ...                             OAM Disconnect                          ${entity.oam}

Trace and Store
    [Documentation]                 INTERNAL USAGE
    ...                             Trace in console and in status file and information and its value
    [Arguments]                     ${val}                                  ${name}
    Dated log                       \t${name}=${val}
    # Store in log file
    Append To File                  ${LOG_PATH}/${STATUS_FILE_NAME}         ${name}=${val}\n\n

#=======================================================================================================================
# Snapshot and SOS report
#=======================================================================================================================
Get Sos Report
    [Documentation]                 Get Sos Report on WTS
    ${alias}                        SSH Connect                             ${HOST_EPCSIM}
    Dated Log                       \tStart generating Sos Report
    ${output}                       SSH Exec                                rm %{HOME}/SosReport*tgz
    ...                             alias=${alias}
    # the .tgz file is generated in $HOME directory
    ${output}                       SSH Cmd                                 ${tl.core.dir_path}/sosReport.sh -nr -c -s
    ...                             alias=${alias}                          timeout=900
    should contain                  ${output}                               _complete_iphy1.tgz created
    # rename the SOS Report file
    ${current_date}=                DateTime.Get Current Date               result_format=%Y%m%d
    ${sos_src_file}                 set variable                            %{HOME}/SosReport${current_date}_*.tgz
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
    should be true                  '${cellDepType}'=='${gNbCuType}'
    set suite variable              ${NWtype}                               ${gNbCuType}

Set Gscn Parameter Name
    [Documentation]                 INTERNAL USAGE
    ...                             TO BE COMPLETED
    ${gscnPattern} =                OperatingSystem.Grep File               ${SCF_SETUP_PATH}           gscnOrSsPbchArfcn
    ${nomalizedPattern} =           set variable    ${gscnPattern.replace('\r','\\r').replace('\n','\\n')}
    ${gscnParameterName}            set variable if                         '${nomalizedPattern}' == '${EMPTY}'
    ...                             gscn                                    gscnOrSsPbchArfcn
    set suite variable              ${gscnParameterName}
    Dated Log                       GSCN:Parameter name=${gscnParameterName}
