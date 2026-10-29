*** Settings ***
Documentation     [PURPOSE] Set of keywords used in different feature tests cases
...               all Keywords need to be autonomous and provide a generic service
...
...               Automation author           : francois.tourlonnias@nokia.com
...               Modified Date               : 18-Sep-2024 - Scout data

Resource          ../../../../resources/SWENG/robot/Restart.robot
Resource          ../../../../resources/SWENG/robot/Tools.robot
Resource          ../../../../resources/SWENG/robot/Capture.robot
Resource          ../../../../resources/SWENG/robot/CallSetup.robot
Resource          ../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../../resources/SWENG/robot/SetConfig.robot
Resource          ../../../../resources/SWENG/robot/Sherpa.robot
Resource          ../../../../resources/SWENG/robot/WtsCfgConfig.robot
Resource          ../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../resources/SWENG/robot/KPIs.robot

Variables         ../../../../resources/SWENG/python/ReadConfig.py

Resource          TDD_MultiBW_Keywords.robot
Resource          ConfigCollector_Keywords.robot
Resource          ../common/TtiTrace/ttitrace.robot
Resource          ../../../../resources/SWENG/robot/Scf.robot

Library           taf.collectors.btslog         WITH NAME   btslog
Library           taf.sbts.oam.coam.admin       WITH NAME   coam
Library           Collections
Library           OperatingSystem
Library           ute_wtssim

*** Variables ***

# Possible extrnal setting
${DBGlogs}           ${False}    # THIS VARIBLE USE SOME TRACES FOR DEBUGING PUPOSE (see kwmkt_dbg_log instruction)
${KeepConfig}        ${True}     # This setting help you in case you use the script only for configuration purpose / or stay on last config known
# ${NoSnap}            ${False}    # basicaly snapshot are waited. this variable is also settale via external variable
${egatelogoutput}    ${False}
${EnSher}            ${False}
${tti}               ${False}
${DodIsSet}          ${False}
#######

*** Keywords ***

#FTS------------------------------------------------------------------------
kwmkt_SetUExonCelly
    [Documentation]    Associates a UE with a cell.
    ...                Starts a WtsCfgConfig session.
    ...                Retrieves the current cell of the UE.
    ...                Replaces the current cell with the target cell.
    ...                Logs the change in the basic file.
    ...                Stops the WtsCfgConfig session.

    [Arguments]           ${ueid}=1    ${Target_cell}=1
    kwmkt_dbg_log         KW: kwmkt_SetUExonCelly *** SetUE${ueid}onCell${Target_cell} ***

    WtsCfgConfig.startSession
    ${prefix}             Set variable    set_ue simulated id=${ueid} uec=1 release=
    ${oldValue}           getParam        prefix=${prefix}    param=cell    ignore_comments=True
    replaceValue          prefix=${prefix}    occurrence=${-1}
    ...                   param=cell
    ...                   oldValue=${oldValue}
    ...                   newValue=${Target_cell}
    ...                   ignore_comments=True
    Dated log             Basic file Now the ue_id ${ueid} is set on Cell${Target_cell}
    WtsCfgConfig.stopSession

kwmkt_Set_Context_basic
    [Documentation]    Sets the context for WTS CFG redcap for a specific UE.
    ...                Logs the start of the process.
    ...                Step 1: Sets the UE capabilities.
    ...                Step 2: If a release is provided, sets the UE release.
    ...                Step 3: If APPdcpPacketTrunc is true, runs kwmkt_PdcpPacketTrunc.
    ...                Resets APPdcpPacketTrunc to false and logs the new value.
    ...                sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100

    [Arguments]            ${ue_id_used}=51    ${capa}=None    ${release}=15    ${APPdcpPacketTrunc}=${False}
    # WtsCfgConfig.startSession

    kwmkt_dbg_log          KW: *** Set Context_WTS CFG redcap for UE ${ue_id_used}

    #step 1\
    kwmkt_ue_capa          ${ue_id_used}    ${capa}

    #step 2\
    Run Keyword If         '${release}' != ''      kwmkt_UeReleaseSet        ${ue_id_used}    ${release}

    #step 3\
    Run Keyword If         '${APPdcpPacketTrunc}'=='${True}'  kwmkt_PdcpPacketTrunc
    ${APPdcpPacketTrunc}=    Set Variable    ${False}   #already done
    kwmkt_dbg_log            new value for APPdcpPacketTrunc ${APPdcpPacketTrunc}

kwmkt_PdcpPacketTrunc
    [Documentation]      in case of over usage or UEC CPU on huge traffic or under 12bits SN packets traffic,
    ...                  packet trunk like below will help UEC to not cousume a lot of CPU
    ...                  sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100

    Dated Log      KW:*** PdcpPacketTrunc

    ${res}                                          getIndexUsingParam    prefix=set_uec   paramId=id    paramVal=1
    dated log                                       ${res}
    WtsCfgConfig.startSession
    ${line_to_search}                               Set Variable    set_uec
    ${data2insert}           Set Variable    sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100
    dated log                                       Prefix look for ${line_to_search}
    dated log                                       To insert ${data2insert}
    WtsCfgConfig.AddStringBeforeLine                line=${line_to_search}    str=${data2insert}
    WtsCfgConfig.stopSession

kwmkt_ue_capa
    [Documentation]    Sets the UE capabilities.
    ...                Starts a WtsCfgConfig session.
    ...                Retrieves the current UE capabilities.
    ...                Replaces the current capabilities with the new ones.
    ...                Logs the change in the basic file.
    ...                Stops the WtsCfgConfig session.

    [Arguments]                   ${ue_id_used}    ${capa}
    kwmkt_dbg_log                 KW:*** kwmkt_ue_capa

    WtsCfgConfig.startSession
    ${oldValue}                   getParam    prefix=ue_param id=${ue_id_used}    param=ue_nr_capabilities    ignore_comments=True
    replaceValue                  prefix=ue_param id=${ue_id_used}    #occurrence=${-1}
    ...                           param=ue_nr_capabilities
    ...                           oldValue=${oldValue}
    ...                           newValue=${capa}
    ...                           ignore_comments=True
    Dated log                     Basic file nr_capabilities value changed from ${oldValue} --> ${capa}
    WtsCfgConfig.stopSession

kwmkt_UeReleaseSet
    [Documentation]    Sets the UE release.
    ...                Logs the start of the process.
    ...                Starts a WtsCfgConfig session.
    ...                Retrieves the current UE release.
    ...                Replaces the current release with the new one.
    ...                Logs the change in the basic file.
    ...                Stops the WtsCfgConfig session.

    [Arguments]                  ${ue_id_used}=51    ${release}=15
    kwmkt_dbg_log                KW:*** kwmkt_UeReleaseSet

    WtsCfgConfig.startSession
    ${prefix}                     Set variable    set_ue simulated id=${ue_id_used} uec
    ${oldValue}                   getParam        prefix=${prefix}    param=release    ignore_comments=True
    replaceValue                  prefix=${prefix}    #occurrence=${-1}
    ...                           param=release
    ...                           oldValue=${oldValue}
    ...                           newValue=${release}
    ...                           ignore_comments=True
    Dated log                     Basic file set_ue release value changed from ${oldValue} --> ${release}
    WtsCfgConfig.stopSession

kwmkt_dbg_log
    [Documentation]             This KW will help on non regression to see deeper informations
    ...                         on Main Test case .robot file, ${DBGlogs} variable need to be set to ${True} or  ${False}

    [Arguments]                   ${SomethinToTrace}=none

    Run Keyword If                ${DBGlogs}    Dated Log   Debug wwwwwwwwww: ${SomethinToTrace}
    #added to pass RF5.0 sanity
    No Operation
    No Operation
    No Operation

kwmkt_Init_Trace_color
    ${consTraceColor}               Evaluate                    "${CYAN}"
    ${consTraceColorBlack}          Evaluate                    "${BLACK}"
    ${consTraceColorRed}            Evaluate                    "${RED}"
    ${consTraceColorYellow}         Evaluate                    "${YELLOW}"
    ${consTraceColorBgBlue}         Evaluate                    "${BG_BLUE}"
    ${consTraceColorBgYellow}       Evaluate                    "${BG_YELLOW}"
    ${defColor}                     Evaluate                    "${NORMAL}"
    Set Suite Variable              ${consTraceColor}
    Set Suite Variable              ${consTraceColorBlack}
    Set Suite Variable              ${consTraceColorRed}
    Set Suite Variable              ${consTraceColorYellow}
    Set Suite Variable              ${consTraceColorBgBlue}
    Set Suite Variable              ${consTraceColorBgYellow}
    Set Suite Variable              ${defColor}

kwmkt_Init Variables
    [Documentation]
    ...                        Special External interraction possible for this test :
    ...                        -v DBGlogs:    (1)True / (0)False  - if true special display for debug are seen -
    ...                        -v KeepConfig: (1)True / (0)False  - if true backup of previous configuration is not restored at the end of the test
    ...                        -v NoSnap:     (1)True / (0)False  - if true no snpashot or SosReport are launch
    ...                        -v egatelogoutput:  (1)True / (0)False  - if true Egate logs are seen on the console
    ...                        -v EnSher:     (1)True / (0)False  - if true L2 data chanel is open and shaerpa pcap is produced (best effort)
    ...                        for following ${DBGlogs} / ${KeepConfig} / ${NoSnap} variable a default value is declared
    ...                        on the test Variables sections

    Dated Log                      "KW: kwmkt_Init Variables"

    ${status}  ${message}=         Run Keyword And Ignore Error      Variable Should Exist     ${DBGlogs}
    ${DBGlogs}                     set Variable if                  '${status}'=='FAIL'        ${False}
    ...                                                                                        ${DBGlogs}
    kwmkt_dbg_log                  --> ${status} ${message}
    #- `${DBGlogs}`: This is the condition. If the variable `${DBGlogs}` is considered true in a boolean context (i.e., it is not empty,
    # zero, or `False`), then the keyword following the condition will be executed.
    Run Keyword If                 ${DBGlogs}    Dated Log    DBGlogs is ON !!!
    ...         ELSE               Dated Log     DBGlogs is OFF !!!
    Set Suite Variable             ${DBGlogs}

    ${status}  ${message}=         Run Keyword And Ignore Error      Variable Should Exist     ${KeepConfig}
    ${KeepConfig}                  set Variable if                  '${status}'=='FAIL'        ${False}
    ...                                                                                        ${KeepConfig}
    kwmkt_dbg_log                  --> ${status} ${message}
    Run Keyword If                 ${KeepConfig}    Dated Log    KeepConfig is ON !!!
    ...         ELSE               Dated Log     KeepConfig is OFF !!!
    Set Suite Variable             ${KeepConfig}

    ${status}  ${message}=         Run Keyword And Ignore Error      Variable Should Exist     ${NoSnap}
    ${NoSnap}                      set Variable if                  '${status}'=='FAIL'        ${100}
    ...                                                                                        ${NoSnap}
    kwmkt_dbg_log                  --> ${status} ${message}
    Run Keyword If                 ${NoSnap}     Dated Log    NoSnap is ON !!!
    ...         ELSE               Dated Log     NoSnap is OFF !!!
    Set Suite Variable             ${NoSnap}

    ${status}  ${message}=         Run Keyword And Ignore Error      Variable Should Exist     ${egatelogoutput}
    ${egatelogoutput}              set Variable if                  '${status}'=='FAIL'        ${False}
    ...                                                                                        ${egatelogoutput}
    kwmkt_dbg_log                  --> ${status} ${message}
    Run Keyword If                 ${egatelogoutput}     Dated Log    egatelogoutput is ON !!!
    ...         ELSE               Dated Log             egatelogoutput is OFF !!!
    Set Suite Variable             ${egatelogoutput}

    ${status}  ${message}=         Run Keyword And Ignore Error      Variable Should Exist     ${EnSher}
    ${EnSher}                      set Variable if                  '${status}'=='FAIL'        ${False}
    ...                                                                                        ${EnSher}
    kwmkt_dbg_log                  --> ${status} ${message}
    Run Keyword If                 ${EnSher}      Dated Log    EnSher is ON !!!
    ...         ELSE               Dated Log      EnSher is OFF !!!
    Set Suite Variable             ${EnSher}

    ${status}  ${message}=         Run Keyword And Ignore Error      Variable Should Exist     ${tti}
    ${tti}                         set Variable if                  '${status}'=='FAIL'        ${False}
    ...                                                                                        ${tti}
    kwmkt_dbg_log                  --> ${status} ${message}
    #GitHub Copilot: In Python, which Robot Framework is based on, a non-empty string is considered `True`. Therefore,
    #if `${tti}` contains 'json' or any other non-empty string, the condition in the `Run Keyword If` statement will be considered `True`.
    Run Keyword If                 ${tti}         Dated Log    tti is ON !!!
    ...         ELSE               Dated Log      tti is OFF !!!
    Set Suite Variable             ${tti}


    ${status}  ${message}=         Run Keyword And Ignore Error      Variable Should Exist     ${DodIsSet}
    ${DodIsSet}                    set Variable if                  '${status}'=='FAIL'        ${True}
    ...                                                                                        ${DodIsSet}
    kwmkt_dbg_log                  --> ${status} ${message}
    Run Keyword If                 ${DodIsSet}         Dated Log    DodIsSet is ON !!!
    ...         ELSE               Dated Log      DodIsSet is OFF !!!
    Set Suite Variable             ${DodIsSet}

    ${status}  ${message}=         Run Keyword And Ignore Error      Variable Should Exist     ${LoopNb}
    ${LoopNb}                      set Variable if                  '${status}'=='FAIL'    1
    ...                                                                                        ${LoopNb}
    kwmkt_dbg_log                  --> ${status} ${message}
    Run Keyword If                 "${LoopNb}" != "1"         Dated Log    LoopNb is ON for ${LoopNb} loop !!!
    ...         ELSE               Dated Log      LoopNb is OFF !!!
    Set Suite Variable             ${LoopNb}

    ${AutoSaveDebugData}           Set Variable  ${False}   #CIT/CRT to not collect logColltion as SosReport is broken
    Set Global Variable            ${AutoSaveDebugData}

#=== MIRRORING
kwmkt_Capt_session_init
    [Documentation]              This will prepar all session used for Bip collection traces
    ...                          kwmkt_Capture_Start kwmkt_Capture_Stop are KW dependent of this KW

    Dated Log                       *** install Mirroring scripts in GNB

    ${CaptureCPRT_setup}            Capture CPRT Set upon config
    ${CaptureCPRT_setup.filter}     Get Filter For SCTP
    Capture Init                    ${CaptureCPRT_setup}             withTN=True             suffix=_setup

    ${CaptureCore_setup}            Capture CORE Set Upon Config
    Capture Init                    ${CaptureCore_setup}             withTN=True             suffix=_setup

    ${CaptureBIP}                   Capture L1L2 Set Upon Config    airscale=${GNB_DU}       isMirror=${True}
    Capture Init                    ${CaptureBIP}                   withTN=True

    Set Suite Variable              ${CaptureCPRT_setup}
    Set Suite Variable              ${CaptureCore_setup}
    Set Suite Variable              ${CaptureBIP}

    ${CaptureCPRT_attach}           Capture CPRT Set upon config
    ${CaptureCPRT_attach.filter}    Get Filter For SCTP
    Capture Init                    ${CaptureCPRT_attach}            withTN=True             suffix=_attach_ueid_redcap

    ${CaptureCore_attach}           Capture CORE Set Upon Config
    Capture Init                    ${CaptureCore_attach}            withTN=True             suffix=_attach_ueid_redcap

    Set Suite Variable              ${CaptureCPRT_attach}
    Set Suite Variable              ${CaptureCore_attach}

# Test running
kwmkt_Cell_setup
    [Documentation]              This keyword start
    ...                            - bts log  (end will be done on test teardown)
    ...                            - collect alarm list before cell_setup
    ...                            - start a CPRT Bip log
    ...                            - launch the cell_setup on WTS  (check list of cells we looking for)
    ...                            - stop  the CPRT Bip log collection

    [Arguments]                  ${CellList}=None

    Run Keyword If               ${userneed_Btslog}           kwmkt_Start Btslog
    kwmkt_Alarmslist             Beg                          ${logsDir}
    Run Keyword If               ${userneed_PCAP}             kwmkt_Capture_Start    cellSetup

    Critical Step                                             CallSetup.Setup Wtsemu SA    cellList=${CellList}    time_to_wait=15min    #sib late
    Run Keyword If               ${userneed_PCAP}             kwmkt_Capture_Stop     cellSetup

#---------------------------------------------------------------------------
kwmkt_Create_Test_Suite_Folder
    [Documentation]              kwmkt_Create_Test_Suite_Folder
    ...                          This KW help to create a mail directory where
    ...                           - configuration files of the test will be centralized in a dedicated subfolder
    ...                           - log files of the test  will be centralized in a dedicated subfolder

    ${timeStamp}                 get current date    result_format=%Y%m%d_%H%M%S

    #Eventual ${TEST NAME} adaptation
    Dated log                    TEST NAME eventual adaptation from ${TEST NAME} to
    #This regular expression will remove all characters that are not letters (upper and lower case),
    #numbers, underscores (_), period (.), hyphens (-), slashes (/)
    #are commonly used for file and directory names in Linux.
    ${TEST NAME}                 Replace String Using Regexp    ${TEST NAME}    [^a-zA-Z0-9/_.-]      ${EMPTY}
    Dated log                    eventual new TEST NAME: ${TEST NAME}

    Dated log                 \n ${TEST NAME} Folder creation
    Set Suite Variable           ${testSuiteDir}    ${OUTPUT DIR}/Logs/${TEST NAME}_${timeStamp}

    create directory             ${testSuiteDir}

    Set Suite Variable           ${ConfigDir}        ${testSuiteDir}/Config_${timeStamp}
    Create Directory             ${ConfigDir}
    Set Suite Variable           ${logsDir}          ${testSuiteDir}/logs
    Create Directory             ${logsDir}
    Set Suite Variable           ${LOG_PATH}         ${logsDir}               #  /!\  warning LOG_PATH is changed HERE
    Run Keyword If               ${VMmonitoring}     Run keywords
    ...                                              Set Global Variable   ${MoniDir}    ${testSuiteDir}/MONITORING
    ...                          AND                 Create Directory      ${MoniDir}

kwmkt_Start Btslog
    [Documentation]    :Author: Soenke Kullberg
    ...
    ...     KW starts Btslog on Testpc with log-collector
    ...
    ...     https://confluence.int.net.nokia.com/display/EE/EE+BTSlog
    ...
    ...     *Note:* KW works only on ute-vm

    Dated Log                      *** kwmkt_Start Btslog
    Return From Keyword If       '${tl.test_pc.default_ssh_connection_details.username}'!='ute'   message=Works only on Cloud
    ${testpc_ssh_config}=         Create Dictionary
    ...                           host=${tl.test_pc.default_ssh_connection_details.addr}
    ...                           user=${tl.test_pc.default_ssh_connection_details.username}
    ...                           password=${tl.test_pc.default_ssh_connection_details.password}
    ${btslog_collector_name}=     Set Variable    btslog
    btslog.create_btslog_collector
    ...                           name=${btslog_collector_name}
    ...                           executor=${testpc_ssh_config}
    btslog.setup_collectors       names=${btslog_collector_name}
    btslog.start_collectors       names=${btslog_collector_name}
    btslog.set_suite_alias        ${btslog_collector_name}

    Dated log                     =====> kwmkt_Start Btslog
    set Test variable             ${BtsLogStarted}    True

kwmkt_Stop Btslog
    [Documentation]    :Author: Soenke Kullberg
    ...    Stop and fetch btslog from Testpc
    ...
    ...    *Note:* KW works only on ute-vm
    ...    :return path: Path to btslog file
    ...
    ...    :param target_dir: Directory to store the btslog file

    [Arguments]                    ${target_dir}=None
    kwmkt_dbg_log                  *** kwmkt_Stop Btslog
    Return From Keyword If        '${tl.test_pc.default_ssh_connection_details.username}'!='ute'   message=Works only on Cloud

    ${btslog_collector_name}=      Set Variable    btslog
    btslog.stop_collectors         names=${btslog_collector_name}
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    Builtin.Sleep                  15      # wait for btslog to close
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    btslog.collect_collectors      names=${btslog_collector_name}   target_dir=${target_dir}
    btslog.teardown_collectors     names=${btslog_collector_name}
    [RETURN]                       ${target_dir}/${btslog_collector_name}/syslog_files.tgz

kwmkt_Alarmslist
	[Documentation]      This KW collect current OAM alarm and store it on ${testCaseDir}.
    ...                  step will help to categorize time of this collection on the test

    [Arguments]             ${Step}=Beg    ${testCaseDir}=${LOG_PATH}
    Dated log New Line      OAM Get Active Alarms to Save into file
    ${aliasGNB}             OAM Connect                             ${GNB_DU.oam}
    kwmkt_dbg_log           --> alias ${aliasGNB}

    ${active_alarms}        OAM Get Active Alarms                   oam=${GNB_DU.oam}    textFormat=${False}

    ${len}                  Get Length                             ${active_alarms}
    ${alarm_id_list}        Create List
    ${alarm_name_list}      Create List
    ${faultId}=             set variable if                        ${isAiC}        fault_id
    ...                                                                            faultId
    ${faultName}=           set variable if                        ${isAiC}        fault_name
    ...                                                                            faultName
    FOR    ${i}             IN RANGE    ${len}
          ${tmp_id}         Get From Dictionary    ${active_alarms[${i}]}    ${faultId}
          ${tmp_name_id}    Get From Dictionary    ${active_alarms[${i}]}    ${faultName}
          Append To List    ${alarm_id_list}    ${tmp_id}
          Append To List    ${alarm_name_list}    ${tmp_name_id}
    # Dated log     Active alarms: alarm_id_list=${alarm_id_list}
    # Dated log     Active alarms: alarm_name_list=${alarm_name_list}
    END
    Append To File          ${testCaseDir}/OAM_Alarms_${Step}_${TEST_NAME}.txt     Active Alarms Id List:\n${alarm_id_list}\n\n
    Append To File          ${testCaseDir}/OAM_Alarms_${Step}_${TEST_NAME}.txt     Active Alarms Name List:\n${alarm_name_list}\n\n

    OAM Disconnect          ${GNB_DU.oam}
    [Return]                ${alarm_id_list}

kwmkt_Capture_Start
    [Documentation]       need kwmkt_Capt_session_init

    [Arguments]                     ${step}
    Dated Log                       *** kwmkt_Capture_Start
    Run Keyword If                  "${step}" == "cellSetup"         Run Keywords
    ...                             Capture Start                   ${CaptureCPRT_setup}
    ...  AND                        Capture Start                   ${CaptureCore_setup}
    Run Keyword If                  "${step}" == "Attach"            Run Keywords
    ...                             Capture Start                   ${CaptureCPRT_attach}
    ...  AND                        Capture Start                   ${CaptureCore_attach}
    Run Keyword If                  "${step}" == "Traff"            Capture Start
    ...                                                             ${CaptureBIP}

kwmkt_Capture_Stop
    [Documentation]       need kwmkt_Capt_session_init

    [Arguments]                     ${step}
    kwmkt_dbg_log                   *** kwmkt_Capture_Stop
    ${path}    Run Keyword If       "${step}" == "cellSetup"         Run Keywords
    ...                             Capture Stop                     ${CaptureCore_setup}
    ...  AND                        Capture Stop                     ${CaptureCPRT_setup}
    ${path}    Run Keyword If       "${step}" == "Attach"            Run Keywords
    ...                             Capture Stop                     ${CaptureCore_attach}
    ...  AND                        Capture Stop                     ${CaptureCPRT_attach}
    ${path}    Run Keyword If       "${step}" == "Traff"
    ...                             Capture Stop                     ${CaptureBIP}
    ${path}    Run Keyword If       "${step}" == "Traff"             kwmkt_PcapFileTimestamp    ${path}

    [Return]                        ${path}

kwmkt_run_egate_shell
    [Documentation]        This KW help to run any external shell script
    ...                    inputs:
    ...                     $script wil contain exact wts script path
    ...
    ...                    eg /opt/iphy/latest/AP_Classical_Fullstack_startTestwithSosReport.sh

    [Arguments]                     ${script}    ${end_prompt}

    kwmkt_dbg_log                   *** Launch of ${script}

    ${alias_epcsim}                 SSH Wait For Connect            ${HOST_EPCSIM}
    Set Suite Variable              ${alias_epcsim}

    ${cmd}                          set variable                    ${script}
    kwmkt_dbg_log                   *** ${cmd}
    ${output}=     SSH Exec
    ...            command=${cmd}
    ...            alias=${alias}
    ...            debug=${True}
    Dated Log  ${output}
    Should Not Be Empty     ${output}  ${end_prompt}

    [Return]                ${output}

kwmkt_PcapFileTimestamp
    [Documentation]        This KW help to integrate a timestamp on a .pcap file

    [Arguments]                     ${path}
    ${timeStamp}                    get current date    result_format=%Y%m%d_%H%M%S
    ${new_path}=                    Set Variable        ${path[:-5]}_${timeStamp}${path[-5:]}
    kwmkt_dbg_log                   *** new_path ${new_path}

    ${alias_epcsim}                 SSH Wait For Connect            ${HOST_EPCSIM}
    Set Suite Variable              ${alias_epcsim}
    ${cmd}                          set variable                    mv ${path} ${new_path}
    kwmkt_dbg_log                   *** ${cmd}
    SSH Exec                        ${cmd}                          alias=${alias_epcsim}

    [Return]                        ${new_path}

kwmkt_run_script_once
    [Documentation]        This KW start on egate command a script file=<path><file.sce> to perform egate commande
    ...                    recorded on a .sce file

    [Arguments]                    ${script_path_name}
    Dated Log                      Script sce used: ${script_path_name}

    wtsemu.script                  file=${script_path_name}
    ${output}                      wtsemu.read_wtsemu_output_until    PROCESSING    20
    Run Keyword If                ${egatelogoutput}    Dated Log                  output:${output}
    ${output}                      wtsemu.read_wtsemu_output_until_prompt    5
    Run Keyword If                ${egatelogoutput}    Dated Log                  output:${output}
    ${script_status}               wait until keyword succeeds    12hours    1s    kwmkt_is_script_finished
    ${error_in_status}=            Run Keyword And Return Status    Should Contain    ${script_status}    error
    kwmkt_dbg_log                  output:${error_in_status}

    should not match regexp        ${script_status}    error

kwmkt_is_script_finished
    [Documentation]        This KW is a part of kwmkt_run_script_once

    wtsemu.script_status
    ${output}                      wtsemu.read_wtsemu_output_until    Status of script    5
    Run Keyword If                ${egatelogoutput}    Dated Log                  output:${output}
    ${script_status}               wtsemu.read_wtsemu_output_until_prompt    5
    # ${log_string}          remove string using regexp    ${script_status}    (=|-| {6,}|\n)
    # ${log_string}          replace string   ${log_string}    description    description${\n}${SPACE}
    # ${log_string}          catenate    Script status:${\n}    ${log_string}
    # Dated Log              ${log_string}    first=True
    should not match regexp        ${script_status}    ( active | paused )
    [Return]                       ${script_status}

kwmkt_PM_general
    [Documentation]         This KW perform PM collection
    ...
    ...                     2/ evaluation of the next PM possible slot & time to reach this slot
    ...                     3/ ZOI start => Sweng timestamp for PM activity
    ...                     4/ evaluation of exact remaining time before begining of CQI process to be run on the PM slot
    ...                       ( Zoiremining time - secondes_a_attendre ) & Sleep of this time
    ...                     5/ ACTIVITY  like CQI activity
    ...                     6/ PM collect

    #1/
    ${empty}=                       Set Variable                                                       #empty string variable
    ${connection}=                  kwmkt_ConnectToVM

    ${cmd1}=                        Catenate    date | awk -F " " {'print $5'} |awk -F ":" {' print $2 '}
    ${minute1}=                     ssh.execute                         ${cmd1}     connection=${connection}

    ${minute1}=                          Strip String                   ${minute1}                     #remove all non digit
    ${minute1}=                          Replace String Using Regexp    ${minute1}    \D    ${EMPTY}   #remove all non digit
    ${minute1}=                          Run Keyword If                '${minute1}' != '${EMPTY}'    Convert To Integer    ${minute1}

    ${cmd2}=                        Catenate    date | awk -F " " {'print $4'} |awk -F ":" {' print $2 '}
    ${minute2}=                     ssh.execute                         ${cmd2}     connection=${connection}

    ${minute2}=                          Strip String                   ${minute2}                     #remove all non digit
    ${minute2}=                          Replace String Using Regexp    ${minute2}    \D    ${EMPTY}   #remove all non digit
    ${minute2}=                          Run Keyword If                '${minute2}' != '${EMPTY}'    Convert To Integer    ${minute2}

    kwmkt_dbg_log                   minute1 >${minute1}< minute2 >${minute2}<
    ${min_beeing}=                  Set Variable If    '${minute1}' != 'None'    ${minute1}    ${minute2}
    Dated Log                       min_beeing >${min_beeing}< minute1 >${minute1}< minute2 >${minute2}<

    run keyword if                  '${min_beeing}' == '${None}'     Fail      ERROR: not able to collect current minute on VM machine

    kwmkt_dbg_log                   ${cmd1} or ${cmd1} aaa ${min_beeing}

    #2/
    @{occurrencies}=                 Create list     0    5    10    15    20    25    30    35    40    45    50    55
    ${occurrence_suivante}           kwmkt_FindNextOccurency    ${min_beeing}    ${occurrencies}
    ${occurrence_suivante}=          Convert To Integer         ${occurrence_suivante}
    ${min_beeing}=                   Convert To Integer         ${min_beeing}
    ${DurationBeforeNextPMslot}      Evaluate    (${occurrence_suivante} - ${min_beeing}) * 60
    Dated Log                        Wait ${DurationBeforeNextPMslot} seconds before next PM slot.

    #3/
    kwmkt_dbg_log                    PM -->${userneed_PM}
    ${zoi}                           Run Keyword If      ${userneed_PM}      ZOI Start    0    300    60
    ${remainingEndZoi}               ZOI Remaining Sec   ${zoi}

    #4/
    # ${secondes_a_attendre}=          Evaluate    (${remainingEndZoi} - ${DurationBeforeNextPMslot})
    ${secondes_a_attendre}=          Evaluate                      (${remainingEndZoi} - 360)
    Traced Sleep                     ${secondes_a_attendre}s       Time left before 5gnb PM production occurency

    # #5/
    # 7103_Cqi_Param_15-0    ${ListOfUeEngaged}
    # Dated Log                        No special activity yet to coordonate

    #6/
    Run Keyword If       ${userneed_PM}    Run Keywords
    ...                                    Dated log New Line            === Starting collecting PM
    ...  AND                               ZOI Wait End                  zoi=${zoi}
    ...  AND                               kwmkt_PM_check                ${zoi}

kwmkt_ConnectToVM
    [Documentation]     :Author: Soenke Kullberg
    ...                             Setup ssh connection to Test PC and returns connection handle/alias
    ...
    ...                             **Note:** KW sould be called without arguments
    ...
    ...                             :param alias: (optional) alias used for ssh connection
    ...
    ...                             :return alias: for ssh connection to Testpc
    ...
    ...                             **Example:**
    ...
    ...                             | ${tpc_alias}=  ttitrace.Connect to TestPC
    ...                             | ssh.execute  command=ls  connection=${tpc_alias}

    [Arguments]         ${alias}=ssh-test-pc
    ssh.Connect_to      hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 username=${tl.test_pc.default_ssh_connection_details.username}
    ...                 password=${tl.test_pc.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]            ${alias}

kwmkt_FindNextOccurency
    [Documentation]             :    @{occurrencies}   0    5    10    15    20    25    30    35    40    45    50    55
    [Arguments]                 ${minute_actuelle}    ${occurrencies}

    ${taille}                   Get Length    ${occurrencies}
    kwmkt_dbg_log               taille ${taille}
    FOR   ${idx}                IN    @{occurrencies}
          kwmkt_dbg_log         idx ${idx}
          ${idx}                convert to integer   ${idx}
          ${minute_actuelle}    convert to integer   ${minute_actuelle}
          Run Keyword If        ${idx} > ${minute_actuelle}    Return from Keyword    ${idx}
    END

    #other method to try challenge = lower code necessity
    # Run Keyword If    '${occurrencies[${idx}]}' > '${minute_actuelle}'    Return from Keyword    ${occurrencies[${idx}]}
    [Return]    ${idx}

kwmkt_PM_check
    [Documentation]              KW to get counters and store in specific directory with day date
    ...                          Codeorig= CNI-68516/resources/robot/CNI-68516_0920_Resources.robot

    [Arguments]                  ${zoi}
    kwmkt_dbg_log                zoi: ${zoi}
    # Constraints file
    ${constraints}=              Set Variable    ${param.PMdod}
    kwmkt_dbg_log                constraints=${constraints}
    # Wait Until Keyword Succeeds    6min    10s    isPMreaddyToBeChecked    ${zoi}   720  #${GP_DEF} + ${PM_AVAIL_DELAY_DEF}
    Run keywords
    ...                          Dated Log        === PM counter directory: ${logsDir}
    ...  AND                     kwmkt_Collect PM Counters File             ${logsDir}
    ...  AND                     KPI Evaluate                               pmFile=${LATEST_FILE}
    ...                                                                     constraintsFile=${constraints}
    ...                                                                     failOnError=${True}
    # ...  AND                     PM_Counter_Tput_Check_7103    1    #Cellid 1

kwmkt_Collect PM Counters File
    [Documentation]       KW to get counters and store in specific directory with day date
    ...                   Codeorig= CNI-68516/resources/robot/CNI-68516_0920_Resources.robot

    [Arguments]           ${target_dir}=${LOG_PATH}
    kwmkt_dbg_log         *** kwmkt_Collect PM Counters File
    ${date}               Get Current Date
    ${date_in_dir_name}    Convert Date         ${date}     result_format=%d%m%Y_%H%M
    ${log_path_pm}        Set Variable         ${target_dir}/PM_${date_in_dir_name}
    BuiltIn.Log           The PM counters file collected from gnb will be stored under : ${log_path_pm}

    ${pm_latest}          Run Keyword If    ${isAic}    Counters.Collect PM files from BTS    pm_files_path=${log_path_pm}
    ...                                                 optional_files=${True}    posProcess=${True}    node='vdu'    # 3 args for AIC
    ...                               ELSE              Counters.Collect PM files from BTS    pm_files_path=${log_path_pm}

    set Suite Variable    ${LATEST_FILE}       ${pm_latest}
    set Suite Variable    ${log_path_pm}
    BuiltIn.Log           Latest pm counters file : ${LATEST_FILE}

kwmkt_isPMreaddyToBeChecked
    [Documentation]       This keyword will help In case we know how many time the activity monitored by PM is long
    ...                   Args:  Zoi ref  / how long time the monitored event is

    [Arguments]           ${zoi}    ${zoiPlustime}
    Dated Log              === check if ZOI t0 + ${zoiPlustime} is reached

    #PM synchronisation, need to wait ZOI Remaining Sec  <= ${GP_DEF} + ${PM_AVAIL_DELAY_DEF} befor check
    ${RemainingTime}       ZOI Remaining Sec               ${zoi}
    ${GOpmCheck}           Set Variable if                 '${RemainingTime}' <= '${zoiPlustime}'    ${True}    ${False}
    Dated Log              === GOpmCheck ${GOpmCheck} RemainingTime ${RemainingTime}
    Run keyword if        '${GOpmCheck}' == '${False}'    Fail

kwmkt_TTI_capt_pcap
    [Documentation]        Capture a TTI traces for a time and return it
    ...                    Argument details:
    ...                      - tgtDir: target directory to save the TTI pcap (mandatory argument)
    ...                      - suffix: suffix to add to the TTI pcap file name (default EMPTY)
    ...                      - time: time of the capture (default 10s)
    ...                    Returned value:
    ...                      - pathname of the TTI pcap
    [Arguments]            ${tgtDir}    ${suffix}=${EMPTY}    ${time}=10s

    ${dateTime}            Get Current Date
    ${dateTime}            Remove String    ${dateTime.replace(' ','-')}

    ${ttiFileName}         set Variable if    '${suffix}'!='${EMPTY}'    TtiTrace_${dateTime}_${suffix}
    ...                                                                  TtiTrace_${dateTime}

    Dated Log              Start capture TTI Traces for ${time}
    ttitrace.Start TTI Traces in Streaming Mode
    Traced Sleep           ${time}         TTI capture
    Dated Log              Stop capture TTI Traces
    ${TTIpcap}             Stop TTI Traces in Streaming mode    tti_trace_path=${tgtDir}    tti_trace_filename=${ttiFileName}

    [return]               ${TTIpcap}

kwmkt_TTI_convert_pcap
    [Documentation]        Convert a pcap TTI traces into json and csv files
    ...                    Argument details:
    ...                      - TTIpcap: pathname of TTI pcap file (mandatory argument)
    ...                      - nbEventinCSV: number of event to include in the csv (default 100000)
    ...                    Returned value:
    ...                      - pathname of json and csv files
    [Arguments]            ${TTIpcap}    ${nbEventinCSV}=100000

    Dated Log New Line     ===> convert TTI trace ${TTIpcap} in json and csv files
    ${TTIjson}             Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}              decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=${nbEventinCSV}

    [return]               ${TTIjson}    ${TTIcsv}

kwmkt_TTI_capt
    [Documentation]        This keyword start tti traces for a time pass in arg and stop it

    [Arguments]            ${time}=${param.GetTtiTraceTime}    ${cplt}=None
    kwmkt_dbg_log   Arguments kwmkt_TTI_capt: ${time}
    kwmkt_TTI start        time=${time}
    Traced Sleep           ${time}         traffic TP tti collection
    ${repname}             catenate    tti${cplt}
    kwmkt_TTI stop         suffix=TTI_underTraffic          targpath=${logsDir}/${repname}

kwmkt_TTI_start
    [Documentation]        Perform start of tti collection

    [Arguments]     ${time}=1s
    ${tm}                  Get Current Date
    ${tm}=                 Remove String    ${tm.replace(' ','-')}    .
    Set global variable    ${tm}
    Dated Log              Start TTI Traces in Streaming Mode
    ttitrace.Start TTI Traces in Streaming Mode      filter_bitmap2=0x0

    Traced Sleep    ${time}      msg=Waiting for TTI Traces

kwmkt_TTI_start_Multi
    [Documentation]        Perform start of tti collection for multi cells

    [Arguments]     ${time}=1s
    ${tm}                  Get Current Date
    ${tm}=                 Remove String    ${tm.replace(' ','-')}    .
    Set global variable    ${tm}
    Dated Log              Start TTI Traces in Streaming Mode
    ttitrace.Start TTI Traces in Streaming Mode Multi      filter_bitmap2=0x0

    Traced Sleep    ${time}      msg=Waiting for TTI Traces

kwmkt_TTI_stop
    [Documentation]        Perform end of tti collection and process .pcap in a csv or a json file

    [Arguments]            ${suffix}=${EMPTY}   ${time}=1s    ${event_nr_max}=40000    ${targpath}=${LOG_PATH}    ${nm_convert}=${True}

    kwmkt_dbg_log          Arguments suffix:${suffix} time:${time} event_nr_max:${event_nr_max}
    kwmkt_dbg_log          Arguments targpath:${targpath}
    Dated log              Stop TTI Traces in Streaming Mode...

    ${ttiTraceSubDir}      set Variable    TtiTrace-${time}-${tm}
    ${ttiTraceSubDir}      set Variable if    '${suffix}'!='${EMPTY}'      ${ttiTraceSubDir}-${suffix}
    ...                                                                    ${ttiTraceSubDir}
    ${tti_trace_path}=     ttitrace.Stop TTI Traces in Streaming Mode      tti_trace_path=${targpath}/${ttiTraceSubDir}

    ttitrace_tools.decode_tti_traces_using_TtitraceReaderEvtDec            desired_storage_directory=${targpath}/${ttiTraceSubDir}
    ...                                                                    num_of_events=${event_nr_max}

    Run Keyword If    ${nm_convert}        Run Keywords
    ...                                    Dated log    Convert TTI trace from pcap to excelCsv
    ...    AND                             Run keyword and continue on failure     ttitrace.Convert TTI trace from pcap to excelCsv
    ...                                    input_file_path=${tti_trace_path}
    ...                                    output_file_path=${targpath}/${ttiTraceSubDir}
    ...    AND                             Dated log    Convert TTI trace from pcap to json
    ...    AND                             Convert TTItrace from pcap to others    input_file_path=${tti_trace_path}

    [return]               ${targpath}/${ttiTraceSubDir}_dl_and_ul.csv

Convert Traffic Strings to Unit
    [Documentation]    Converts a list of strings with traffic values into numbers in specified unit.
    ...                - ``strings``: Unpacked list of strings
    ...                - ``output_unit``: Unit of output numbers: bps / kbps / mbps
    ...                Example:
    ...                | $\{val1\} | $\{val2\} | Convert Traffic Strings to Unit | 10.0 Mbps | 5.0 Mbps | output_unit=kbps |
    [Arguments]    @{strings}    ${output_unit}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${output_unit}' in ('bps','kbps','mbps')    msg=Invalid KW parameter: output_unit
    #---------------------------------------------------------------------------------------------------------------
    ${converted}    Create List
    ${input_mp}    Create Dictionary    bps=1    Kbps=1000    Mbps=1000000
    ${output_mp}    Create Dictionary    bps=1    kbps=0.001    mbps=0.000001
    FOR    ${string}    IN    @{strings}
      ${match}    ${value}    ${unit}    Run Keyword If    '${string}' == '0'    Create List    zero    0    bps
      ...    ELSE    Should Match Regexp    ${string}    (\\d+.\\d)\\s+([MK]?bps)
      ${output}    Evaluate    ${value} * ${input_mp}[${unit}] * ${output_mp}[${output_unit}]
      Append To List    ${converted}    ${output}
    END
    [Return]    ${converted}

kwmkt_PathLoss_Set
    [Documentation]    Set path loss for a UE in WTS

    [Arguments]    ${ue_id}    ${path_loss}

    ${cmd1}       Set Variable    ul_sinr_testmode_nr profile_id=${ue_id} pathloss=${path_loss}
    ${cmd2}       Set Variable    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr profile_id=${ue_id} action=activate
    ${output1}    ute_wtssim.execute_egate_command    cmd=${cmd1}    alias=egate_1235
    ${output2}    ute_wtssim.execute_egate_command    cmd=${cmd2}    alias=egate_1235
    [Return]      ${output1}    ${output2}

kwmkt_Execute_Egate_Command_Ext
    [Documentation]    Wrapper KW for ``ute_wtssim.execute_egate_command`` with extended functionality.
    ...                - ``cmd``: Egate command to execute
    ...                - ``pass_regexp``: Regexp indicating that the command passed, Default: None
    ...                - ``fail_regexp``: Regexp indicating that the command failed, Default: None
    ...                - ``timeout``: Timeout for finding ``pass_regexp``, Default: 10s
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``should_not_contain``: List or single regexp pattern that command output should not contain,\
    ...                Default: None
    ...                - ``log_msg``: Console log message, Default: Executed command
    ...                - ``cmd_params``: Extra egate command parameters
    [Arguments]    ${cmd}    ${pass_regexp}=${None}    ${fail_regexp}=${None}    ${timeout}=10s
    ...    ${should_contain}=@{Empty}    ${should_not_contain}=@{Empty}    ${log_msg}=${Empty}    &{cmd_params}
    FOR    ${param}    IN    @{cmd_params}
        ${cmd}    Set Variable    ${cmd} ${param}\=${cmd_params}[${param}]
    END
    ${log_msg}    Set Variable If    '${log_msg}' == ''    Executing egate command: ${cmd}    ${log_msg}
    Log To Console    ${log_msg}
    ${output}    ute_wtssim.execute_egate_command
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}    alias=egate_1235  #was a global Var??
    ${is_string}    Run Keyword And Return Status    Should Be String    ${should_contain}
    ${should_contain}    Run Keyword If    ${is_string}
    ...    Create List    ${should_contain}    ELSE    Set Variable    ${should_contain}
    ${is_string}    Run Keyword And Return Status    Should Be String    ${should_not_contain}
    ${should_not_contain}    Run Keyword If    ${is_string}
    ...    Create List    ${should_not_contain}    ELSE    Set Variable    ${should_not_contain}
    FOR    ${pattern}    IN    @{should_contain}
      Should Match Regexp    ${output}    ${pattern}    values=${False}
      ...    msg=Output of egate command does not contain pattern: ${pattern}${\n}cmd: ${cmd}${\n}output:${\n}${output}
    END
    FOR    ${pattern}    IN    @{should_not_contain}
      Should Not Match Regexp    ${output}    ${pattern}    values=${False}
      ...    msg=Output of egate command contains forbidden pattern: ${pattern}${\n}cmd: ${cmd}${\n}output:${\n}${output}
    END
    [Return]    ${output}

kwmkt_Get_UE_Stats_From_Egate
    [Documentation]    Returns output of ``ue_stats_nr`` command as dictionary of scells.
    ...                Reimplements ``size_unit`` parameter of egate command for proper conversion to numbers.
    ...                Display format of egate command set to short.
    ...                - ``ue_id``: UE ID
    ...                - ``size_unit``: Format of traffic values: auto / bps / kbps / mbps, Default: auto
    ...                - ``format``: Egate command display format, Default: short (only option)
    ...                - ``params``: Parameters and their values for command
    ...                Example:
    ...                | &\{stats\} | Get UE Stats From Egate | ue_id=1 | scell=0-6 | type=pdsch | size_unit=kbps |
    [Arguments]    ${ue_id}    ${size_unit}=auto    ${format}=short    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    '${format}' == 'short'    msg=Invalid KW parameter: Only short format allowed
    Should Be True    '${size_unit}' in ('auto','mbps','kbps','bps')    msg=Invalid KW parameter: size_unit
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    ue_stats_nr id=${ue_id}
    ${pass_regexp}    Set Variable    ---.*===
    ${output}    kwmkt_Execute_Egate_Command_Ext    cmd=${cmd}    pass_regexp=${pass_regexp}    &{params}
    ${matches}    Get Lines Matching Regexp    ${output}    ^CellIndex-.*
    @{lines}    Split To Lines    ${matches}
    Should Be True    len(${lines}) > 0    msg=Egate command ue_stats_nr returned no data
    &{ue_stats}    Create Dictionary
    ${ExpReg}      catenate
    ...    (?i)(CellIndex-\\d+)\\s+(0|\\d+\\.?\\d*\\s*[kmb]?bps)\\s+
    ...    (0|\\d+\\.?\\d*\\s*[kmb]?bps)\\s+
    ...    (0|\\d+\\.?\\d*\\s*[kmb]?bps)\\s+
    ...    (0|\\d+\\.?\\d*\\s*[kmb]?bps)

    Dated Log  Expression Reg: ${ExpReg}

    FOR    ${line}    IN    @{lines}
      ${match}    ${scell}    ${cur}    ${min}    ${max}    ${avg}    Should Match Regexp    ${line}    ${ExpReg}

      ${cur}    ${min}    ${max}    ${avg}    Run Keyword If    '${size_unit}' != 'auto'
      ...    Convert Traffic Strings to Unit    ${cur}    ${min}    ${max}    ${avg}    output_unit=${size_unit}
      ...    ELSE    Create List    ${cur}    ${min}    ${max}    ${avg}
      &{scell_stats}    Create Dictionary    Current=${cur}    Minimum=${min}    Maximum=${max}    Average=${avg}
      Set To Dictionary    ${ue_stats}    ${scell}    ${scell_stats}
    END
    [Return]    ${ue_stats}

kwmkt_wtssim_setup_egate
    ute_wtssim.setup_egate          egate_port=${tl.core.egate_port}
    ...                             host_ip=${tl.core.default_ssh_connection_details.addr}
    ...                             tool_dir=${tl.core.dir_path}
    ...                             ssh_user=ute
    ...                             ssh_pass=ute
    ...                             alias=egate_1235

kwmkt_wtssim_UNsetup_egate
    ute_wtssim.teardown_egate       alias=egate_1235

kwmkt_Get_IDs_of_Attached_UEs_From_Egate
        [Documentation]    This keyword returns a list of UE IDs that are not in the OFF state.
        ...    It takes an optional argument ${state} which defaults to None.
        ...    If ${state} is not 'ACTIVE', the command 'ue_disp state=${state}' is executed.
        ...    Otherwise, the command 'ue_disp state=ACTIVE,ACTIVATING,DEACTIVATING,IDLE,IM_ENTERING,IM_EXITING' is executed.
        ...    The output of the command is then filtered to get lines matching the regular expression '^[0-9]+.*INT.*'.
        ...    Each matching line is split into values, and the first value (the UE ID) is appended to the list of UE IDs.
        ...    The list of UE IDs is returned.

        [Arguments]    ${state}=None    ${alias}=egate_1235
        ${cmd}                    Set Variable If    ${state} != 'ACTIVE'    ue_disp state=${state}
        ...                                                                ue_disp state=ACTIVE,ACTIVATING,DEACTIVATING,IDLE,IM_ENTERING,IM_EXITING
        ${out}                    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=---.*===    alias=${alias}
        ${filtered}               Get Lines Matching Regexp    ${out}    ^[0-9]+.*INT.*
        @{lines}                  Split To Lines    ${filtered}
        @{ue_ids}                 Create List
        Return From Keyword If    ${lines} == []    ${ue_ids}
        FOR    ${line}    IN      @{lines}
                                  ${values}    Split String    ${line}
                                  Append To List    ${ue_ids}    ${values}[0]
        END
        [Return]    ${ue_ids}

kwmkt_Block_SBTScell
    [Documentation]
    ...     block a cell on a SBTS.

    [Arguments]    ${cell_id}
    Oam.OAM Cell Lock  cell_id=${cell_id}
    Dated Log   Current status of cell ${cell_id} is blocked

kwmkt_Unblock_SBTScell
    [Documentation]
    ...    Unblock a cell on a SBTS.

    [Arguments]    ${cell_id}
    Oam.OAM Cell Lock  state=UNLOCK     cell_id= ${cell_id}
    Dated Log   Current status of cell ${cell_id} is unblocked


# kwmkt_Connect to COAM ADMIN
#     [documentation]   only one Connect to COAM ADMIN call and coam_gnb alias is used by every coam request
#     [Arguments]    ${gnb_id}=0  ${bts_host}=${EMPTY}
#     ${bts_host}=  Set Variable if  '${bts_host}'=='${EMPTY}'  ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}  ${bts_host}
#     coam.setup_admin    bts_host=${bts_host}    name=coam_gnb

# kwmkt_Block_SBTScell
#     [Documentation]
#     ...    Block a cell on a SBTS and check the alarms raised.

#     [Arguments]  ${Cell_Id}

#     kwmkt_Connect to COAM ADMIN
#     ${NR_CELL_list}=  coam.Get Ids For All  class_name=NRCEL  alias=coam_gnb
#     dated log      NR_CELL_list=${NR_CELL_list}

#     FOR  ${item}  IN  @{NR_CELL_list}
#         # dated log    cell=${item}
#         exit For Loop If     'NRCELL_R-${cellId}' in '${item}'
#     END
#     dated log    NRCELL = ${item}
#     Log  *** Perform "Cell Block" operation on BTS: ${Cell_Id}  console=True
#     coam.Block Cell  dist_name=${item}  timeout=180  connection=coam_gnb
#     BuiltIn.sleep  10


# kwmkt_Unblock_SBTScell
#     [Documentation]
#     ...    Unblock a cell on a SBTS.
#     [Arguments]   ${Cell_Id}
#     ${cell_class_name}=  Set Variable   NRCEL
#     Log  *** Perform "Cell Unblock" operation on BTS: ${Cell_Id}  console=True
#     coam.Unblock Cell  dist_name=${Cell_Id}  timeout=180  connection=coam_gnb
#     BuiltIn.sleep  10


# kwmkt_Test Teardown_hasbeen
#     [Documentation]    Performs teardown operations after a test.
#     ...                Logs the start and end of the teardown process.
#     ...                If the test failed, sets ${save_debug_data} to True and logs interruption.
#     ...                If the test passed, logs natural end.
#     ...                If ${EnSher} is True, deactivates Sherpa and stops collection.
#     ...                Waits for SSH connection to ${HOST_EPCSIM} and sets suite variable.
#     ...                Collects config files used for the test from ${ConfigDir}.
#     ...                Lists alarms at the end and displays diagnosis.
#     ...                If ${AutoSaveDebugData} is True, sets ${save_debug_data} to True.
#     ...                If ${NoSnap} is True, sets ${save_debug_data} to False.
#     ...                If ${BtsLogStarted} is True, stops Btslog.
#     ...                If ${save_debug_data} is True, collects logs.
#     ...                Copies egate_console files to ${logsDir}.

#     Dated log New Line                       Test Teardown ${TEST_NAME} : begin
#     Dated log                                ..............................

#     # ${cmd}=               Catenate  sudo kill ${pid}
#     # Dated Log             comand send : ${cmd}
#     # ${pid}                SSH Exec            command=${cmd}          alias=${alias_epcsim}

#     # Cit/Crt to not collect logColltion as SosReport is broken => addind ${False} on the following line
#     Run Keyword If Test Failed      Set Global Variable    ${save_debug_data}    ${True}
#     Run Keyword If Test Failed      Dated log              TEST - I N T E R R U P T I O N -
#     Run Keyword If Test Passed      Set Global Variable    ${save_debug_data}    ${False}
#     Run Keyword If Test Passed      Dated log              TEST - N A T U R A L - E N D -

#     Run Keyword If                  not ${tti} and ${EnSher}    Run Keywords
#     ...                             Dated log                   SHERPA STOP AND COLLECTION ongoing
#     ...                             AND
#     ...                                                         Deactivate Sherpa and Stop Collect

#     ${alias_epcsim}        SSH Wait For Connect            ${HOST_EPCSIM}
#     Set Suite Variable     ${alias_epcsim}

#     kwmkt_CollectConfigfilesUsedForTest    dir=${ConfigDir}

#     kwmkt_Alarmslist       End    ${logsDir}
#     Dated log              TEST_NAME : ${TEST NAME}
#     Display diagnosis

#     Run Keyword If         ${AutoSaveDebugData} == ${True}    Set Global Variable    ${save_debug_data}    ${True}    ${False}

#     Dated log              save_debug_data : ${save_debug_data}
#     Dated log              AutoSaveDebugData : ${AutoSaveDebugData}

#     ${save_debug_data}=    Set Variable If        ${NoSnap}    ${False}    ${True}
#     Set Global Variable                           ${save_debug_data}
#     #following to uncomment if you don't want any SosReport / Snapshot collection
#     # Set Global Variable             ${save_debug_data}    ${False}

#     Run Keyword If         ${BtsLogStarted}                 kwmkt_Stop Btslog      ${logsDir}
#     Run Keyword If         ${save_debug_data} == ${True}    kwmkt_LogCollection

#     Dated Log              alias_epcsim sur ssh wait For Connect ${alias_epcsim}
#     ${cmd}                 set variable    cp -p ${tl.core.dir_path}/egate_console.* ${logsDir}
#     Dated Log              ${cmd}
#     SSH Exec               ${cmd}                                           alias=${alias_epcsim}

#     Dated log              Test Teardown  ${TEST_NAME} : end

kwmkt_Test Teardown

    Dated log New Line                       Test Teardown NG ${TEST_NAME} : begin
    Dated log                                ..................................
    Produce Scout Data

    Run Keyword If Test Failed      Set Global Variable         ${test_status}    FAIL
    Run Keyword If Test Failed      Dated log                   TEST - I N T E R R U P T I O N -
    Run Keyword If Test Passed      Set Global Variable         ${test_status}    PASS
    Run Keyword If Test Passed      Dated log                   TEST - N A T U R A L - E N D -

    Run Keyword If                  not ${tti} and ${EnSher}    Run Keywords
    ...                             Dated log                   SHERPA STOP AND COLLECTION ongoing
    ...                             AND                         Deactivate Sherpa and Stop Collect

    kwmkt_Alarmslist                End    ${logsDir}
    Dated log                       TEST_NAME : ${TEST NAME}
    Display diagnosis

    ${alias_epcsim}                 SSH Wait For Connect            ${HOST_EPCSIM}
    Set Suite Variable             ${alias_epcsim}

    Dated log                       test_status ${test_status} NoSnap ${NoSnap}

    ${attendu}=                     Set Variable    rien
    ${attendu}=                     Set Variable If    '${nosnap}' == '0' and '${test_status}' == 'FAIL'         Collection    ${attendu}
    ${attendu}=                     Set Variable If    '${nosnap}' == '100' and '${test_status}' == 'FAIL'       Collection    ${attendu}
    ${attendu}=                     Set Variable If    '${nosnap}' == '0' and '${test_status}' == 'PASS'         Collection    ${attendu}

    Dated log                      attendu: ${attendu}
    Run Keyword If                '${attendu}' == 'Collection'    kwmkt_LogCollection    ${logsDir}

    Run Keyword If                  ${BtsLogStarted}                 kwmkt_Stop Btslog      ${logsDir}

    kwmkt_CollectConfigfilesUsedForTest    dir=${ConfigDir}
    Dated Log                       alias_epcsim sur ssh wait For Connect ${alias_epcsim}
    ${cmd}                          set variable    cp -p ${tl.core.dir_path}/egate_console.* ${logsDir}
    Dated Log                      ${cmd}
    SSH Exec                       ${cmd}                                           alias=${alias_epcsim}

    Dated log                       Test Teardown  ${TEST_NAME} : end

kwmkt_CollectConfigfilesUsedForTest
    [Documentation]       Save current scf/iphy/swconfig/basic files used for the test in ${testSuiteDir}

    [Arguments]           ${dir}=${ConfigDir}
    Dated Log                       *** CollectConfigfilesUsedForTest
    kwmkt_Backup Scf      ${dir}
    Backup Files FTS      ${FD_ALL}           ${dir}

    #previou KW collect only original .cfg, not cfg modified by the test => correction of this:
    SSH Exec              rm ${dir}/*.cfg                                                          alias=${alias_epcsim}
    ${cmd}                set variable    cp -p ${tl.core.dir_path}/${tl.core.cfg_filename} ${dir}/${tl.core.cfg_filename}
    Dated Log             ${cmd}
    SSH Exec              ${cmd}                                                                         alias=${alias_epcsim}

    # Set Suite Variable    ${LOG_PATH_bu}      ${LOG_PATH}
    # Set Suite Variable    ${LOG_PATH}         ${dir}
    # # Get Data From Gnb TargetBD File           card_name=${param.RU}
    # Set Suite Variable    ${LOG_PATH}         ${LOG_PATH_bu}

kwmkt_Backup Scf
    [Documentation]       Save the current SCF to a directory done by argument

    [Arguments]           ${dir}=${LOG_PATH}
    ${timeStamp}          get current date    result_format=%Y%m%d_%H%M%S
    ${g_backup_scf}       OAM Get SCF File    dir=${dir}    file=SCF_ofTheTest_${timeStamp}.xml
    Set Suite Variable    ${g_backup_scf}
    Dated Log             SCF backup file = ${g_backup_scf}


kwmkt_LogCollection
    [documentation]       KWM KeyWord Market
    ...                   This KW help to several log file to global ${logsDir} directory

    [Arguments]           ${dir}=${LOG_PATH}
    Dated log   L O G S _ C O L L E C T I O N

    Get Snapshot
    SSH Exec              mv ${LOG_PATH}/SNAPSHOT_GNB*zip ${dir}    alias=${alias_epcsim}

    Get Sos Report
    SSH Exec              mv %{HOME}/SosReport*tgz ${dir}           alias=${alias_epcsim}

    #move pcap file from mirroring
    SSH Exec              mv ${LOG_PATH}/*.pcap ${dir}              alias=${alias_epcsim}

    Run Keyword If 	     '${AutoSaveDebugData}'
    ...                   Run Keyword And Ignore Error
    ...                   SSH Exec       cp -rp ${LOG_PATH}/l2stream3 ${dir}          alias=${alias_epcsim}

kwmkt_Intermed
    [documentation]      KWM KeyWord Market
    ...                  This KW help to prepare tshark filters

    [Arguments]          ${filters}    ${pres}    ${msg}
    kwmkt_dbg_log        Itermed
    # here ${filters} is not empty
    ${f}                 Run Keyword If    '${pres}' == '${False}'    Catenate    ${filters} || ${msg}
    ...     ELSE                                                      Catenate    ${filters}
    [Return]             ${f}


kwmkt_is_value_in_list
    [documentation]      KWM KeyWord Market
    ...                  This KW return True or False according presence or not of a value in a list in robot framework

    [Arguments]          ${value}    ${list}
    kwmkt_dbg_log        kwmkt_is_value_in_list args: >${value}< >${list}<

    ${status}=           run keyword and return status    Should Contain    ${list}    ${value}

    kwmkt_dbg_log        status=${status}
    [Return]             ${status}

Is List
    [Arguments]    @{variable}
    Dated Log  is List args: @{variable}
    ${is_list}=    Evaluate    isinstance($variable, list)
    Dated Log  is List return: ${is_list}
    [Return]    ${is_list}

kwmkt_Get_Variable_Type
    [Arguments]    ${variable}
    ${type}=    Evaluate    type($variable).__name__
    [Return]    ${type}

kwmkt_Check_For_False_In_Nested_List
    [Documentation]    This keyword checks if there is a False value in a nested list.
    ...                The list can have any number of sublists, and the keyword will check all of them recursively.
    ...                If a False value is found anywhere in the list, the keyword will fail the test with the message "Found False in the list".
    ...                If no False value is found, the keyword will pass without doing anything.
    ...                This keyword is useful for validating data that is structured as a nested list.
    ...                It can handle lists that contain elements of different types, including other lists and boolean values.
    ...
    ...                Example usage: kwmkt_Check_For_False_In_Nested List    ${list}
    ...                liste exemple:
    ...     [False, [True, True, 0.55, [615, 85.69, 14.31], [615, 100.0]], [True, True, False, True, True, -13.57, [77, 100.0], [77, 98.7, 1.3]]]

    [Arguments]    ${list}
    kwmkt_dbg_log    Args kwmkt_Check_For_False_In_Nested List ${list}

    # Set the recursion limit to prevent infinite recursion
    ${recursion_limit}=    Evaluate    ${recursion_limit}-1
    Set Global Variable            ${recursion_limit}
    Dated log      recursion_limit:${recursion_limit}
    Run Keyword If    ${recursion_limit} < 0    Fail    Recursion limit reached. The list is too deeply nested.

    Dated log      DODlist: ${list}
    ${length} =    Get Length    ${list}
    FOR            ${index}    IN RANGE     ${length}
                                            ${item}=          Get From List    ${list}    ${index}
                                            kwmkt_dbg_log     index ${index}=${item}
                                            ${type}           kwmkt_Get_Variable_Type    ${item}
                                            Run Keyword If    "${type}" == "bool"
                                            ...               Run Keyword If    ${item} == ${False}    Fail    Found False in the list => DOD KO
                                            ...    ELSE IF    "${type}" == "list"
                                            ...               Run Keyword       kwmkt_Check_For_False_In_${NL}    ${item}
                                            ...    ELSE       kwmkt_dbg_log     Processing item: ${item}
    END
    Dated log      ++ DOD ++ ${list} => OK
#FTS------------------------------------------------------------------------
