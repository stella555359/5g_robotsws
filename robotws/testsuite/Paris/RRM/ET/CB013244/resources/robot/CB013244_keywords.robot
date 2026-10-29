*** Settings ***
Documentation     [SUITE PURPOSE]  Generic keywords for CB013244
...
...               Test Case automation author : laurent.puchelle@nokia.com
...               Test Case automation contact: laurent.puchelle@nokia.com
...               Creation Date               : 01-Nov-2025
...               Last Modified by            :
...               Modification:
...                       01-Nov-2025         | Creation


Library             taf.sbts.oam.coam.admin     WITH NAME       sbts_coam
Library             taf.wts.runner              WITH NAME       wtsemu
Library             taf.config.scf              WITH NAME       scf
Library             ta5g_syslog                 WITH NAME       ta5g
Library             ../../../resources/python/luashark_tools.py
Library             ../../../../../resources/SWENG/python/CoamParameter.py    WITH NAME    coam_parameter

Variables           ../python/Constants.py

Resource            ../../../../../resources/SWENG/robot/CallSetup.robot
Resource            ../../../../../resources/SWENG/robot/Tools.robot
Resource            ../../../../../resources/SWENG/robot/Capture.robot
Resource            ../../../../../resources/SWENG/robot/SetConfig.robot
Resource            ../../../../../resources/SWENG/robot/Traffic.robot
Resource            ../../../../../resources/SWENG/robot/CaptureFilter.robot
Resource            ../../../../../resources/SWENG/robot/Restart.robot
Resource            ../../../../../resources/SWENG/robot/Counters.robot
Resource            ../../../../../resources/SWENG/robot/Oam.robot
Resource            ../../../../../resources/SWENG/robot/CfgFilesTools.robot
Resource            ../../../../../resources/SWENG/robot/Setup.robot
Resource            ../../../../../resources/SWENG/robot/Scf.robot
Resource            ../../../../../resources/SWENG/robot/KPIs.robot
Resource            ../../../../../resources/SWENG/robot/Syslogs.robot
Resource            ../../../resources/common/TtiTrace/ttitrace.robot

Variables           ../../../../../resources/SWENG/python/Colors.py


*** Variables ***

# Keys must be the exact name of the parameters
&{Default_CB013244_act}
...    actPreventBWPSwitchInBadConditions=false
...    actDLSchedInactiveBwp=false
...    actEnhPsBwpAndRACH=false
...    actEnhPsBwpAndDRX=false

# Keys must be the exact name of the parameters
&{Default_TMO_powerSavingBwpSwitching}
...    avgCQIToForceBWPSwitchFromPsBwp=1
...    avgCQIToPreventBWPSwitchToPsBwp=2
...    dlBufferEmptyRatioFromPsBwp=30
...    dlBufferEmptyRatioToPsBwp=90
...    dlRateThresholdFromPsBwp=50
...    dlRateThresholdToPsBwp=35
...    mcsThresholdVoNRFromPsBwp=0
...    mcsThresholdVoNRToPsBwp=0
...    measurementDurationFromPsBwp=20
...    measurementDurationToPsBwp=640
...    ulBufferEmptyRatioFromPsBwp=30
...    ulBufferEmptyRatioToPsBwp=90
...    ulRateThresholdNoVoNRFromPsBwp=50
...    ulRateThresholdNoVoNRToPsBwp=35
...    ulRateThresholdVoNRFromPsBwp=50
...    ulRateThresholdVoNRToPsBwp=35


*** Keywords ***

CB013244 Full Commissioning
    [Arguments]                 ${PSswitchingParam}=&{EMPTY}    ${featAct}=&{EMPTY}    ${suffix}=${EMPTY}

    IF    '${suffix}' != '${EMPTY}'
        ${SCF}                      Set Variable    ${LOG_PATH}/SCF_${suffix}.xml
    ELSE
        ${SCF}                      Set Variable    ${LOG_PATH}/SCF.xml
    END

    ${SCForig}                      OAM Get SCF File    file=SCF_original.xml
    ${std_output}                   Run         cp ${SCForig} ${SCF}

    SCF StartSession                scf_file=${SCF}

    ${cellDistName}             Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${TDD_Cell_list[0].nrCellId}
    FOR    ${param}    ${value}    IN    &{featAct}
        SCF Set element             dist_name=${cellDistName}
        ...                         element_name=${param}
        ...                         element_value=${value}
    END

    ${NRBTSdistName}            Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    FOR    ${param}    ${value}    IN    &{PSswitchingParam}
        SCF Set element in List     dist_name=${NRBTSdistName}      list_name=powerSavingBwpSwitching
        ...                         element_name=${param}        element_value=${value}
    END

    SCF StopSession                 scf_file=${SCF}

    Dated Log new line          ${trcColor}=== Perform full commissioning ${defColor}
    OAM Perform Full Commissioning    scf_file=${SCF}
    OAM wait available

    [Return]        ${SCF}


CB013244 Build Power Saving delta JSON
    [Arguments]                 ${SCFsrc}    ${PSswitchingParam}=&{EMPTY}    ${featAct}=&{EMPTY}    ${suffix}=${EMPTY}

    IF    '${suffix}' != '${EMPTY}'
        ${SCFtgt}                   Set Variable    ${LOG_PATH}/SCF_${suffix}.xml
        ${deltaJSON}                Set Variable    ${LOG_PATH}/DELTA_${suffix}.json
        ${deltaJSONback}            Set Variable    ${LOG_PATH}/DELTA_${suffix}_back.json
    ELSE
        ${SCFtgt}                   Set Variable    ${LOG_PATH}/SCF.xml
        ${deltaJSON}                Set Variable    ${LOG_PATH}/DELTA.json
        ${deltaJSONback}            Set Variable    ${LOG_PATH}/DELTA_back.json
    END
    ${std_output}                   Run         cp ${SCFsrc} ${SCFtgt}


    SCF StartSession                scf_file=${SCFtgt}

    ${cellDistName}             Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${TDD_Cell_list[0].nrCellId}
    FOR    ${param}    ${value}    IN    &{featAct}
        SCF Set element             dist_name=${cellDistName}
        ...                         element_name=${param}
        ...                         element_value=${value}
    END

    ${NRBTSdistName}            Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    FOR    ${param}    ${value}    IN    &{PSswitchingParam}
        SCF Set element in List     dist_name=${NRBTSdistName}      list_name=powerSavingBwpSwitching
        ...                         element_name=${param}        element_value=${value}
    END

    SCF StopSession                 scf_file=${SCFtgt}

    scf.calculate_delta_scf  target_scf_path=${SCFtgt}    actual_scf_path=${SCFsrc}    delta_scf_path=${deltaJSON}
    scf.calculate_delta_scf  target_scf_path=${SCFsrc}    actual_scf_path=${SCFtgt}    delta_scf_path=${deltaJSONback}

    [Return]        ${SCFtgt}    ${deltaJSON}    ${deltaJSONback}


CB013244 SA Attach
    [Arguments]                     ${ueSetting}    ${CPRTcapture}=${False}
    Dated Log new line              ${trcColor}--- SA call UE ${ueSetting.ue} ${defColor}
    Run Keyword If                  ${CPRTcapture} == ${True}
    ...                             CB013244 Start Capture Attach       UEid=${ueSetting.ue}
    UE Register                     ue=${ueSetting.ue}
    Launch PDU Session              ue=${ueSetting.ue}    pdu=${ueSetting.pdu}    gw=${ueSetting.ue}
    Run Keyword If                  ${CPRTcapture} == ${True}
    ...                             CB013244 Capture Stop               Attach


CB013244 NSA Attach
    [Arguments]                     ${ueSetting}    ${CPRTcapture}=${False}
    Dated Log new line              ${trcColor}--- NSA call UE ${ueSetting.ue} ${defColor}
    Run Keyword If                  ${CPRTcapture} == ${True}
    ...                             CB013244 Start Capture Attach       UEid=${ueSetting.ue}
    UE Attach Enb                   ueSetting=${ueSetting}
    UE Attach Gnb                   ueSetting=${ueSetting}
    Run Keyword If                  ${CPRTcapture} == ${True}
    ...                             CB013244 Capture Stop               Attach


########################  Traces KWs  ########################
CB013244 Start Capture After GNB Ready
    ${CaptureCPRT_setup}            Capture CPRT Set upon config
    ${TestNameWOspace}              getFormattedTestName

    ${CaptureCPRT_setup.filter}     Get Filter For SCTP
    # Filter to use when CNI-78299 will be implemented again instead of SCTP:
    #${CaptureCPRT_setup.filter}     Get Filter For TCP
    Capture Init                    ${CaptureCPRT_setup}             withTN=True             suffix=_setup

    ${CaptureCore_setup}            Capture CORE Set Upon Config
    Capture Init                    ${CaptureCore_setup}             withTN=True             suffix=_setup

    Capture Start                   ${CaptureCPRT_setup}
    Capture Start                   ${CaptureCore_setup}
    Set Suite Variable              ${CaptureCPRT_setup}
    Set Suite Variable              ${CaptureCore_setup}

CB013244 Start Capture Attach
    [Arguments]                     ${UEid}=1
    ${TestNameWOspace}              getFormattedTestName

    ${CaptureCPRT_attach}           Capture CPRT Set upon config
    ${CaptureCPRT_attach.filter}    Get Filter For SCTP
    # Filter to use when CNI-78299 will be implemented again instead of SCTP:
    #${CaptureCPRT_attach.filter}    Get Filter For TCP
    Capture Init                    ${CaptureCPRT_attach}            withTN=True             suffix=_attach_${UEid}

    ${CaptureCore_attach}           Capture CORE Set Upon Config
    Capture Init                    ${CaptureCore_attach}            withTN=True             suffix=_attach_${UEid}

    Capture Start                   ${CaptureCPRT_attach}
    Capture Start                   ${CaptureCore_attach}
    Set Suite Variable              ${CaptureCPRT_attach}
    Set Suite Variable              ${CaptureCore_attach}

CB013244 Capture Stop
    [Arguments]                     ${step}
    Run Keyword If                  "${step}" == "cellSetup"         Run Keywords
    ...                             Capture Stop                     ${CaptureCore_setup}
    ...                             AND
    ...                             Capture Stop                     ${CaptureCPRT_setup}
    Run Keyword If                  "${step}" == "Attach"            Run Keywords
    ...                             Capture Stop                     ${CaptureCore_attach}
    ...                             AND
    ...                             Capture Stop                     ${CaptureCPRT_attach}

CB013244 Start Syslog gNB
    ta5g.start_syslog_for_enb      logs_dirpath=${LOG_PATH}    log_filename_prefix=SYSLOG_gNB
    ...                            remote_hosts=127.0.0.1    alias=alias_gNB

CB013244 Start Syslog AP
    ta5g.start_syslog_for_iphy     logs_dirpath=${LOG_PATH}    log_filename_prefix=SYSLOG_AP
    ...                            remote_hosts=127.0.0.1    alias=alias_AP

CB013244 Stop Syslog gNB
    [Arguments]                    ${suffix}
    ta5g.stop_syslog               alias=alias_gNB
    ${ta5gSYSLOG}                  Set Variable       ${LOG_PATH}/SYSLOG_gNB127.0.0.1.log
    ${SYSLOGsplit}                 Set Variable If    '${suffix}' != '${EMPTY}'    ${LOG_PATH}/SYSLOG_gNB_${suffix}_    ${LOG_PATH}/SYSLOG_gNB_
    ${std_output}                  Run   split -C 400m --additional-suffix=.log --numeric-suffixes=1 ${ta5gSYSLOG} ${SYSLOGsplit}
    ${std_output}                  Run   rm ${ta5gSYSLOG}; gzip ${SYSLOGsplit}*.log

CB013244 Stop Syslog AP
    [Arguments]                    ${suffix}
    ta5g.stop_syslog               alias=alias_AP
    ${ta5gSYSLOG}                  Set Variable       ${LOG_PATH}/SYSLOG_AP127.0.0.1.log
    ${SYSLOGsplit}                 Set Variable If    '${suffix}' != '${EMPTY}'    ${LOG_PATH}/SYSLOG_AP_${suffix}_    ${LOG_PATH}/SYSLOG_AP_
    ${std_output}                  Run   split -C 400m --additional-suffix=.log --numeric-suffixes=1 ${ta5gSYSLOG} ${SYSLOGsplit}
    ${std_output}                  Run   rm ${ta5gSYSLOG}; gzip ${SYSLOGsplit}*.log

CB013244 Get Internal Cell Id
    [Documentation]                 Argument cell must be as MRBTS-2/NRBTS-1/NRCELL-1
    [Arguments]                     ${cell}
    ${gnb_alias}                    Set Variable        gNB
    sbts_coam.connect_to            name=${gnb_alias}

    ${cells_info}                   sbts_coam.get_cells_info    cell_type=nr     connection=${gnb_alias}
    @{cell_nr}                      Create List
    FOR    ${cellInf}    IN    @{cells_info}
       IF    '${cellInf}[id][configuration]' == '${cell}'
         RETURN    ${cellInf}[id][internal]
       END
    END
    RETURN                          ${EMPTY}

CB013244 Convert TTI pcap
    [Arguments]                     ${pcapList}
    Dated Log New Line        ${trcColor}=== Convert TTI pcaps ${defColor}
    FOR    ${TTIpcap}    IN    @{pcapList}
       ${TTIjson}                   Convert TTItrace from pcap to others     input_file_path=${TTIpcap}
       ${std_output}                Run     zip -jm ${TTIjson}.zip ${TTIjson}
    END


#########################  Check KWs  #########################
CB013244 Wait Next PM period
    Dated Log New Line              ${trcColor}--- Wait end of PM period ${defColor}
    Wait PM availability            pmAvailDelay=0

CB013244 KPI Evaluate
    [Arguments]                     ${pm_path}    ${constraintsFile}    ${nbPMfileToCheck}=1

    @{PMfilesList}                  List Files In Directory    ${pm_path}    pattern=*.xml    absolute=True
    ${totalNbPMfiles}               Get Length    ${PMfilesList}

    ${firstPMfileId}                Evaluate    ${totalNbPMfiles} - ${nbPMfileToCheck}
    @{PMfilesFailed}                Create List
    FOR   ${PMfileId}    IN RANGE    ${firstPMfileId}    ${totalNbPMfiles}
       ${KPIstatus}                  KPI Evaluate    pmFile=${PMfilesList}[${PMfileId}]
       ...                                           constraintsFile=${constraintsFile}
       ...                                           failOnError=False

       IF    not ${KPIstatus}
           ${path}    ${file}        Split Path    ${PMfilesList}[${PMfileId}]
           Append to list            ${PMfilesFailed}    ${file}
       END
    END

    ${nbErrors}                     Get Length    ${PMfilesFailed}
    IF    ${nbErrors} != 0
       FOR    ${errorId}    IN RANGE    0    ${nbErrors}
          Dated Log New Line        ${trcColor}=== KPI error in PM file: ${errColor}${PMfilesFailed}[${errorId}] ${defColor}
       END
       RETURN                       False
    END
    RETURN                          True


####################  Setup/Teardown KWs  ####################
CB013244 Test Setup
    [Documentation]             Perform needed actions at the begining of a test case
    Init Trace color
    Get External Variables

CB013244 Test Teardown
    [Documentation]             Perform needed actions at the end of a test case
    Restore Files               listFileDesc=${FD_ALL}
    # "Test Teardown" KW from Setup.robot
    Test Teardown

Init Trace color
    ${trcColor}                 Evaluate    "${CYAN}"
    ${defColor}                 Evaluate    "${NORMAL}"
    ${okColor}                  Evaluate    "${GREEN}"
    ${errColor}                 Evaluate    "${RED}"
    Set Suite Variable          ${trcColor}
    Set Suite Variable          ${defColor}
    Set Suite Variable          ${okColor}
    Set Suite Variable          ${errColor}

Get External Variables
    # =========================
    # Configure variables from external one if exists, else set to a default value
    # =========================
    ${robNb}                    Get Variable Value    ${robNb}    1
    ${loopNb}                   Get Variable Value    ${loopNb}   10
    ${ttiCapt}                  Get Variable Value    ${tti}      0
    ${result}                   Run Keyword And Ignore Error    Convert To Integer   ${robNb}
    IF    '${result}[0]' == 'FAIL'
        ${robNb}                Set Variable   1
    ELSE
        ${robNb}                Set Variable   ${result}[1]
    END
    ${result}                   Run Keyword And Ignore Error    Convert To Integer   ${loopNb}
    IF    '${result}[0]' == 'FAIL'
        ${loopNb}               Set Variable   10
    ELSE
        ${loopNb}               Set Variable   ${result}[1]
    END
    ${result}                   Run Keyword And Ignore Error    Convert To Integer   ${tti}
    IF    '${result}[0]' == 'FAIL'
        ${tti}                  Set Variable   0
    ELSE
        ${tti}                  Set Variable   ${result}[1]
    END
    Set Suite Variable          ${robNb}
    Set Suite Variable          ${loopNb}
    Set Suite Variable          ${ttiCapt}

