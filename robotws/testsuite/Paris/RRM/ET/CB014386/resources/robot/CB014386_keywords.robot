*** Settings ***
Documentation
...               Common keywords for Automation of Feature CB014386 sub-feature B
...
...               Test Case Scenario author   : loic.marzin@nokia.com
...               Test Case Scenario contact  : loic.marzin@nokia.com
...               Test Case automation author : loic.marzin@nokia.com
...               Test Case automation contact: loic.marzin@nokia.com
...               Creation Date               : 23-Sep-2025
...               Modified Date               : 17-Oct-2025

Resource          ../../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../../resources/SWENG/robot/Connect.robot
Resource          ../../../../../resources/SWENG/robot/Tools.robot
Resource          ../../../../../resources/SWENG/robot/Restart.robot
Resource          ../../../../../resources/SWENG/robot/Setup.robot
Resource          ../../../../../resources/SWENG/robot/Capture.robot
Resource          ../../../../../resources/SWENG/robot/CaptureFilter.robot
Resource          ../../../../../resources/SWENG/robot/CallSetup.robot
Resource          ../../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/Oam.robot
Variables         ../../../../../resources/SWENG/python/ReadConfig.py
Resource          ../../../../../resources/SWENG/robot/Sherpa.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../resources/robot/KeyWordMarket.robot

Library           ../../../resources/python/luashark_tools.py
Library          ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME     coam_parameter

Library           luashark_tools.analyzer       WITH NAME       analyzer
Library           Collections
Library           BuiltIn
Library           DateTime
Library           ute_wtssim                    WITH NAME       wts
Library           ute_common_store.Store        WITH NAME       ute_store
Library           taf.sbts.oam.coam.admin       WITH NAME       CoamAdmin

*** Variables ***
${CB014386_B_B5_delta_file}=     ${CURDIR}/../config/Delta_Configuration_B_B5.json
${CB014386_B_B5_ActPrewhite_delta_file}=    ${CURDIR}/../config/Delta_Configuration_B_B5_ActPrewhitening.json
${CB014386_B_B11_delta_file}=    ${CURDIR}/../config/Delta_Configuration_B_B11.json

*** Keywords ***
Setup 14386_B_B5
    Suite Setup From Scratch    keepAllUeDataInCfgFile=${True}

Setup 14386_B_B11
    ${yamlPath}       Set Variable    ${CURDIR}/../config/Config_B_B11.yaml
    Suite Setup from scratch    yamlPathname=${yamlPath}    listBackupFiles=${FD_ALL}    keepAllUeDataInCfgFile=${True}

Perform_Delta_SCF_Commision_B_B5
    Dated log           => performing scf delta commission to configure CB014386-B_B5
    ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}
    coam_parameter.perform_scf_delta_commission
    ...                              delta_file=${CB014386_B_B5_delta_file}
    ...                              connection=${aliasGNB}
    Restart TL

Perform_Delta_SCF_Commision_B_B11
    Dated log           => performing scf delta commission to configure CB014386-B_B11
    ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}
    coam_parameter.perform_scf_delta_commission
    ...                              delta_file=${CB014386_B_B11_delta_file}
    ...                              connection=${aliasGNB}
    Restart TL

Activate_PreWhitening
    Dated log           => performing scf delta commission to deactivate Pre-whitening
    ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}
    coam_parameter.perform_scf_delta_commission
    ...                              delta_file=${CB014386_B_B5_ActPrewhite_delta_file}
    ...                              connection=${aliasGNB}

Setup Wtsemu NSA
    [Documentation]                WTSEmu Setup for NSA call. This is a call to keyword 'WTS Setup':
    ...                            | WTS Setup
    ...                            | ...   telnet_egate_addr=${tl.core.default_ssh_connection_details.addr}
    ...                            | ...   nbUe=1
    ...                            | ...   nbSaUe=${nbSaUe}
    ...                            | ...   shouldUseLua=${shouldUseLua}
    ...                            | ...   bypassX2Setup=${False}
    ...                            | ...   bypassSIB=${False}
    ...                            | ...   nbCell=${nbCell}
    ...                            See keyword 'WTS Setup' for more details.
    ...
    ...                            *Argument details:*
    ...                            - *nbSaUe*: number of SA UE to use (default value = 1, should be >= 1)
    ...                            - *nbCell*: number of cell to check for SystemInformationBlock-NR (default value= 0 dynamically retrieved)
    ...                            - *shouldUseLua*: flag to choose between cfg or lua basic-setup file (default value = False)
    ...                            - *list_of_UE_tobe_created*: list of UEs structure to be created when using lua (default value = None)
    ...                                 mandatory params: ue & target_cells &{my_UE_SA}     ue=1    target_cells=2
    ...                            - *time_to_wait*: time to wait the SIB (default value = 5min)

    [Arguments]        ${nbUe}=1    ${nbCell}=0    ${cellList}=${None}    ${nbSaUe}=1
    ...                ${shouldUseLua}=${False}    ${list_of_UE_tobe_created}=${None}
    ...                ${shouldSaveBasicCfg}=${False}       ${time_to_wait}=5min
    CallSetup.WTS Setup         nbUe=${nbUe}    nbSaUe=${nbSaUe}    nbCell=${nbCell}   cellList=${cellList}    bypassX2Setup=${False}
    ...                         shouldUseLua=${shouldUseLua}    list_of_UE_tobe_created=${list_of_UE_tobe_created}   time_to_wait=${time_to_wait}
    Run Keyword If              "${shouldSaveBasicCfg}"=="${True}"
    ...                         UteTools.Save Used Basic File

Cell_Setup_NSA
    [Documentation]    Play NSA Cell_setup with 6 cells
    [Tags]  Cell_Setup

    ${nb}                  Set Variable      6
    Setup Wtsemu NSA       nbCell=${nb}

UE_Register_Multi_SA
    [Documentation]    start a set of ue_register done in parameter

    FOR    ${current_elem}    IN      @{param}
         Dated log  Ue_id ${current_elem.ue} is Registering
         CallSetup.UE Register  ue=${current_elem.ue}
         sleep   2s
    END

PDU_Session_Multi_SA
    [Documentation]    start a set of PDU_Session done in parameter

    FOR    ${current_elem}    IN      @{param}
         Dated log  Ue_id ${current_elem.ue} PDU session establishment on going
         CallSetup.Launch PDU Session  ue=${current_elem.ue}  pdu=${current_elem.pdu}  gw=${current_elem.gw}
         sleep   2s
    END

Traffic_DL_UL_Mbps_Multi_SA
    [Documentation]    * Start UL / DL traffic for this TC

    FOR    ${current_elem}    IN      @{param}
         ${TptDL}         Set Variable     ${current_elem.throughput}
         ${TptUL}         Set Variable     ${current_elem.throughput}
         ${MaxTptTrf}     Set Variable     ${current_elem.maxThroughputPerTransfer}
         Traffic MONO UE UL DL MBPS        ueSetting=${current_elem}    ulThroughput=${TptUL}    dlThroughput=${TptDL}
         ...                               maxThroughputPerTransfer=${MaxTptTrf}
    END

Traffic MONO UE UL DL MBPS
    [Documentation]                 Start a UL and DL data traffic.
    ...                             A check is performed to verify obtained traffic rate is in line with expected one.
    ...
    ...                             *Argument details:*
    ...                             - *ueSetting*:          Reference to UE Settings (default value: UE_NO_PROFILE).
    ...                             - *throughput*:         Traffic in Mega (default value: NO_THROUGHPUT).
    ...                             - *shouldBeCheck*:      Indicate if traffic check is needed (default value: True)
    ...                             - *maxThroughputPerTransfer*:  maxThroughputPerTransfer (default value: 140)
    ...                             - *rtp_codec*:          rtp_codec (default value: None). When used throughput MUST be set to None
    ...                             - *protocol*:           tcp or udp (default value: None)
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic en Mega
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic check is needed
    ...                             ${ulThroughput}=None                    # Uplink traffic in Kilo
    ...                             ${dlThroughput}=None                    # Downlink traffic in Kilo
    ...                             ${maxThroughputPerTransfer}=${MAX_THROUGHPUT_PER_TRANSFER}
    ...                             ${protocol}=${None}
    ...                             ${rtp_codec}=${None}
    ${shouldBeCheck}                Set Variable If                         '${rtp_codec}'!='${None}'
    ...                             ${False}                                ${shouldBeCheck}
    ${alias}                        SSH Wait For Connect                    host=${HOST_EPCSIM}

    ${ul_traffic_throughput}        Set Variable If
    ...                             '${ulThroughput}'!='None'               ${ulThroughput}             ${throughput}
    ${dl_traffic_throughput}        Set Variable If
    ...                             '${dlThroughput}'!='None'               ${dlThroughput}             ${throughput}
    ${ueRetUl}                      Traffic Start                           ueSetting=${ueSetting}      dir=ul
    ...                             throughput=${ul_traffic_throughput}     maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...                             protocol=${protocol}                    rtp_codec=${rtp_codec}
    ${ueRetDl}                      Traffic Start                           ueSetting=${ueSetting}      dir=dl
    ...                             throughput=${dl_traffic_throughput}     maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...                             protocol=${protocol}                    rtp_codec=${rtp_codec}

Traffic MONO UE UL DL KBPS
    [Documentation]                 Start a UL and DL data traffic during a particular <duration>, then stop it.
    ...                             A check is performed to verify obtained traffic rate is in line with expected one.
    ...                             Optionnaly, a capture can be launched during first second of traffic (BIP Messages for instance).
    ...
    ...                             *Argument details:*
    ...                             - *ueSetting*:          Reference to UE Settings (default value: UE_NO_PROFILE).
    ...                             - *throughput*:         Traffic in Mega (default value: NO_THROUGHPUT).
    ...                             - *capture*:            Associated <Capture> structure if Callback is provided (default value: None).
    ...                             - *shouldBeCheck*:      Indicate if traffic check is needed (default value: True).
    ...                             - *maxThroughputPerTransfer*:  maxThroughputPerTransfer (default value: 140).
    ...                             - *rtp_codec*:          rtp_codec (default value: None). When used throughput MUST be set to None.
    ...                             - *protocol*:           tcp or udp (default value: None).
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}           # Reference to UE Settings
    ...                             ${throughput}=${NO_THROUGHPUT}          # Traffic en Mega
    ...                             ${shouldBeCheck}=${True}                # Indicate if traffic check is needed
    ...                             ${ulThroughput}=None                    # Uplink traffic in Kilo
    ...                             ${dlThroughput}=None                    # Downlink traffic in Kilo
    ...                             ${maxThroughputPerTransfer}=${MAX_THROUGHPUT_PER_TRANSFER}
    ...                             ${protocol}=${None}
    ...                             ${rtp_codec}=${None}
    ${shouldBeCheck}                Set Variable If                         '${rtp_codec}'!='${None}'
    ...                             ${False}                                ${shouldBeCheck}
    ${alias}                        SSH Wait for connect                    host=${HOST_EPCSIM}

    ${ul_traffic_throughput}        Set Variable If
    ...                             '${ulThroughput}'!='None'               ${ulThroughput}             ${throughput}
    ${dl_traffic_throughput}        Set Variable If
    ...                             '${dlThroughput}'!='None'               ${dlThroughput}             ${throughput}
    ${ueRetUl}                      Kbps Traffic Start                       ueSetting=${ueSetting}      dir=ul
    ...                             throughput=${ul_traffic_throughput}     maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...                             protocol=${protocol}                    rtp_codec=${rtp_codec}
    ${ueRetDl}                      kbps Traffic Start                       ueSetting=${ueSetting}      dir=dl
    ...                             throughput=${dl_traffic_throughput}     maxThroughputPerTransfer=${maxThroughputPerTransfer}
    ...                             protocol=${protocol}                    rtp_codec=${rtp_codec}

Kbps Traffic Start
    [Documentation]                 INTERNAL USAGE
    ...                             Launch start traffic command on WTS, on a particular UE profile, in a particular direction (ul or dl)
    ...                             with a particular throughput
    [Arguments]                     ${ueSetting}=${UE_NO_PROFILE}
    ...                             ${dir}=ul
    ...                             ${throughput}=${NO_THROUGHPUT}
    ...                             ${maxThroughputPerTransfer}=${MAX_THROUGHPUT_PER_TRANSFER}
    ...                             ${size}=${None}
    ...                             ${protocol}=${None}
    ...                             ${rtp_codec}=${None}

    ${ueRet}                        Traffic Set Throughput                  ueSetting=${ueSetting}      throughput=${throughput}

    Dated Log New line
    ...    Start ${dir} data traffic: UE=${ueRet.ue} Bearer=${ueRet.bearer} TRF=${ueRet.trf_id} Throughput=${ueRet.throughput}K Burst=${ueRet.burst}

    ${nb_trf}                       Get Number Of Transfers
    ...                             throughput=${ueRet.throughput}
    ...                             maxThroughputPerTransfer=${maxThroughputPerTransfer}

    ${remaining_throughput}         Set Variable    ${ueRet.throughput}
    FOR  ${idx}    IN RANGE     ${nb_trf}
        ${trf_id}                   Evaluate    ${ueRet.trf_id}+${idx}
        ${trfThroughput}            Set Variable If
        ...                         ${ueRet.burst}!=${None} and ${ueRet.period_ms}!=${None}    ${None}
        ...                         ${remaining_throughput}==${None}                            ${None}
        ...                         ${remaining_throughput}>=${maxThroughputPerTransfer}        ${maxThroughputPerTransfer}
        ...                         ${remaining_throughput}<${maxThroughputPerTransfer}         ${remaining_throughput}
        wtsemu.Trf Data Start       ue=${ueRet.ue}
        ...                         id=${ueRet.bearer}                  dir=${dir}
        ...                         kbps=${trfThroughput}               trf_id=${trf_id}
        ...                         qfi=${ueRet.qfi}                    pdu=${ueRet.pdu}
        ...                         burst=${ueRet.burst}                size=${size}
        ...                         protocol=${protocol}                rtp_codec=${rtp_codec}
        ...                         period_ms=${ueRet.period_ms}
        ${remaining_throughput}     Run Keyword If                      ${remaining_throughput}!=${None} and ${ueRet.period_ms}==${None}
        ...                         Evaluate                            ${remaining_throughput}-${trfThroughput}
    END

Check Modulo
    [Arguments]    ${count}
    ${mod}=    Evaluate    (${count}%2)
    [Return]    ${mod}

Traffic_DL_UL_Kbps_Mbps_Multi_SA
    [Documentation]    * Start UL / DL traffic for this TC

    FOR    ${current_elem}    IN      @{param}
           ${TptDL}         Set Variable     ${current_elem.throughput}
           ${TptUL}         Set Variable     ${current_elem.throughput}
           ${MaxTptTrf}     Set Variable     ${current_elem.maxThroughputPerTransfer}
           ${mod}  Check Modulo   ${current_elem.ue}
           Run Keyword if   '${mod}'!='${0}'       Traffic MONO UE UL DL KBPS        ueSetting=${current_elem}    ulThroughput=${TptUL}
           ...                                     dlThroughput=${TptDL}    maxThroughputPerTransfer=${MaxTptTrf}
           Run Keyword if   '${mod}'=='${0}'       Traffic MONO UE UL DL MBPS        ueSetting=${current_elem}    ulThroughput=${TptUL}
           ...                                     dlThroughput=${TptDL}    maxThroughputPerTransfer=${MaxTptTrf}
    END

Activate_UL_interference
    Dated Log                Activating UL Interferance
    kwmkt_run_script_once    ${CURDIR}/../egate/egCmd_ULInter_Cells1234.sce


Setup WTS
    WTS Setup    shouldUseLua=${False}


Check_Counters_B_B5_Before_PreWhitening
    [Documentation]                 Retrieve and Check PM counter and KPI values are as expected
    ...                             M55165C00006 M55165C00005 M55303C13001 M55303C14001 Counters
    Traced sleep   10m  msg=Pool_Size + PUCCH_F1_DTX PM Counters
    ${date}                         Get Current Date
    ${date_in_dir_name}             Convert Date         ${date}     result_format=%d%m%Y_%H%M
    ${log_path_pm}                  Set Variable         ${LOG_PATH}/PM_${date_in_dir_name}
    Dated Log                       The PM counters file collected from gnb will be stored under : ${log_path_pm}
    ${pm_latest}                    Counters.Collect PM files from BTS      ${log_path_pm}
    set Suite Variable              ${LATEST_PM_FILE}       ${pm_latest}
    set Suite Variable              ${log_path_pm}

    Dated Log                       Latest pm counters file : ${LATEST_PM_FILE}
    Dated Log                       ===> check counter and KPI constraints is started
    KPI Evaluate                    pmFile=${LATEST_PM_FILE}
    ...                             constraintsFile=${CURDIR}/../kpi/CB014386-B_B5_Before_PreWhitening.csv
    ...                             failOnError=${True}
    Dated Log                       ===> check counter and KPI constraints is ended


Check_Counters_B_B5_After_PreWhitening
    [Documentation]                 Retrieve and Check PM counter and KPI values are as expected
    ...                             M55165C00006 M55165C00005 M55303C13001 M55303C14001 Counters
    Traced sleep   10m  msg=Pool_Size + PUCCH_F1_DTX PM Counters
    ${date}                         Get Current Date
    ${date_in_dir_name}             Convert Date         ${date}     result_format=%d%m%Y_%H%M
    ${log_path_pm}                  Set Variable         ${LOG_PATH}/PM_${date_in_dir_name}
    Dated Log                       The PM counters file collected from gnb will be stored under : ${log_path_pm}
    ${pm_latest}                    Counters.Collect PM files from BTS      ${log_path_pm}
    set Suite Variable              ${LATEST_PM_FILE}       ${pm_latest}
    set Suite Variable              ${log_path_pm}

    Dated Log                       Latest pm counters file : ${LATEST_PM_FILE}
    Dated Log                       ===> check counter and KPI constraints is started
    KPI Evaluate                    pmFile=${LATEST_PM_FILE}
    ...                             constraintsFile=${CURDIR}/../kpi/CB014386-B_B5_After_PreWhitening.csv
    ...                             failOnError=${True}
    Dated Log                       ===> check counter and KPI constraints is ended

Check_Counters_B_B11
    [Documentation]                 Retrieve and Check PM counter and KPI values are as expected
    ...                             M55165C00006 M55165C00005 M55165C00004 M55165C00003 M55303C13001 M55303C14001 Counters
    Traced sleep   10m  msg=Pool_Size + PUCCH_F1_DTX PM Counters
    ${date}                         Get Current Date
    ${date_in_dir_name}             Convert Date         ${date}     result_format=%d%m%Y_%H%M
    ${log_path_pm}                  Set Variable         ${LOG_PATH}/PM_${date_in_dir_name}
    Dated Log                       The PM counters file collected from gnb will be stored under : ${log_path_pm}
    ${pm_latest}                    Counters.Collect PM files from BTS      ${log_path_pm}
    set Suite Variable              ${LATEST_PM_FILE}       ${pm_latest}
    set Suite Variable              ${log_path_pm}

    Dated Log                       Latest pm counters file : ${LATEST_PM_FILE}
    Dated Log                       ===> check counter and KPI constraints is started
    KPI Evaluate                    pmFile=${LATEST_PM_FILE}
    ...                             constraintsFile=${CURDIR}/../kpi/CB014386-B_B11.csv
    ...                             failOnError=${True}
    Dated Log                       ===> check counter and KPI constraints is ended

Start TTI Capture
    Dated Log                                   ===> configuration and get TTI is started
    # TTI capture configuration
    ${TTIdir}=                                  Get TTI Trace Path
    Start TTI Traces in Streaming mode          src_ip=10.0.1.2
    Set Suite Variable                          ${TTIdir}

Stop TTI Capture
    ${TTIPrefix}                                Set Variable         TTI_CB014386_
    ${TTIFileName}                              set Variable         ${TTIPrefix}${LogFileSuffix}
    Traced sleep   30s  msg=Stopping TTI Logs
    Dated Log                                   ===> stop and get TTI Logs is started
    ${TTIpcap}=                                 Stop TTI Traces in Streaming mode    tti_trace_path=${TTIdir}    tti_trace_filename=${TTIFileName}
    Dated Log                                   ===> convert TTI to json and csv is started
    ${TTIjson}=                                 Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}=                                  decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}
    Set Suite Variable                          ${TTIFileName}
    Set Suite Variable                          ${TTIcsv}

Format TTI Capture
    ${filteredFilePath}                         Format TTI Trace

Format TTI Trace
    [Documentation]             1/ Filter all lines containing ulFdSchedData
    ...                         then remove  lines containing DL_10 in TTI Capture
    ...                         (match "Dl_PdcchSendReq UL grant 0-1" or " Dl_PdcchSendReq DL grant 1-1" or "Ul_PuschReceiveReq" in Sherpa)
    ...                            and redirect the output in a file named "TTI_5GC001013_TestCase#_Filtered.csv"
    ...                         2/ Only keep MSGID, SFN, and Format columns.
    ...                         then format the 2 colums SFN Slot in one column SFN.Slot
    ...                         then add first line header describing colums
    ...                         and redirect the output in a file named "TTI_5GC001013_TestCase#_Formatted.csv"

    ${TTI_LOG_PATH}      Set variable    ${LOG_PATH}/TTITraces
    ${inputFilePath}     Set variable    ${TTIcsv}
    ${outputFilePath}    Set variable    ${TTI_LOG_PATH}/${TTIFileName}_Filtered.csv
    ${command}           Set variable
    ...                  grep -i -E "(ulFdSchedData)" <${inputFilePath} >${outputFilePath}
    ${returnCode}        Run And Return Rc    ${command}
    Should Be Equal As Integers    ${returnCode}    0
    Dated Log New Line     Filtered CSV File: ${outputFilePath}


    ${inputFilePath}     Set variable       ${outputFilePath}
    ${outputFilePath}    Set variable       ${TTI_LOG_PATH}/${TTIFileName}_Formatted.csv
    ${command}           Set variable
    ...                  awk -F';' '{printf("%d %.2d %s %s %s %s %s %s %s\\n", $6, $8, $12, $16, $47, $62, $146, $148, $156)}' <${inputFilePath} \|
    ${command}           Set variable
    ...                  ${command} awk -F' ' '{print $1 "." $2 ";" $3 ";" $4 ";" $5 ";" $6 ";" $7 ";" $8 ";" $9}' \|
    ${command}           Set variable
    ...                  ${command} sed -e '1i\AIR TTI;RNTI;PHYSCELLID;MCSTABLE;STARTPRB;SEARCHSPACEID;DCIFORMAT;CELLBWPID' \|
    ${command}           Set variable
    ...                  ${command} grep -i -vwE "(INVALID)" >${outputFilePath}
    ${returnCode}        Run And Return Rc    ${command}
    Should Be Equal As Integers    ${returnCode}    0
    Dated Log New Line     Formatted CSV File: ${outputFilePath}

    [Return]            ${outputFilePath}

Collect EGATE console Logs
    [Documentation]    This keyword is used to collect egate_console.log from the /opt/wts/latest/ folder
    ...                This is collected in the Test Log Folder
    ${LogFileName}               set Variable                            egate_console_CB011436_${LogFileSuffix}.log

    CallSetup.Empty Buffer For Egate
    Traced sleep   10s  msg=wait 10s for flush
    # Connect to WTS  alias=alias_wts
    ${alias_wts}                    SSH Wait For Connect                ${HOST_EPCSIM}
    Dated Log      Collecting ${tl.core.dir_path}/egate_console.log...
    csn.download_file               remote_path=${tl.core.dir_path}/egate_console.log
    ...                             local_path=${LOG_PATH}/${LogFileName}
    ...                             connection=${alias_wts}
    Dated Log                  egate_console.log file stored to ${LOG_PATH}

Teardown 14386
    Produce Scout Data
    ${message}=  Evaluate  "\\033[44mCollect and Download egate_console.log\\033[0m"
    Dated Log                  ${message}
    Collect EGATE console Logs
    Setup.Suite Teardown       reset_ap=${True}
