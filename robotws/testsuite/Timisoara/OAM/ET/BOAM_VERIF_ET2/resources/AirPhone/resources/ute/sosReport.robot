# Copyright (c) 2019 Nokia. All rights reserved.

*** Settings ***
Library    BuiltIn
Library    Process
Library    OperatingSystem
Library    String
Library    Collections
Library    taf.wts.runner    WITH NAME    wtsrunner
Library    taf.transport.ssh  WITH NAME  SSH
Resource    archive.robot


*** Variables ***
${sosReportScript}     sosReport.sh
${sosReportLogDir}     /tmp/sosreport
${sosReportCfg}        sosReport.cfg
${sosReportMainDir}    /ffs/run/config/toor4nsn/logs
${sosReportStart}      AP_Classical_Fullstack_startTestwithSosReport.sh
${sosReportStop}       AP_Classical_Fullstack_stopTestwithSosReport.sh
${sosReportResult}     SosReport

# to do more properly ...
${uteEpcDir}                 /opt/wts/latest
${uteHomePath}               /home/ute/workspace/UTE_E2E/PROD/E2E_TESTS/e2e_tests
${uteSosReportUtilityDir}    entitytests/resources/common/utilityFiles/sosreport
${PCAP_SOSREPORT}          1
${EXCLUDE_LOGS_IF_FAIL}    0
${COLLECT_LOGS}            1
#Conditional Logging is to be used during time critical QT Runs like AP QT-in Gate.
#Conditional logging if set to true will skip log collection if suite/testcase is passed.
${CONDITIONAL_LOGGING}   False
&{AP_ASIK}     Ip=192.168.200.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=ApAsik
&{GNB_ASIK}    Ip=192.168.255.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=GnbAsik
${gnbMirroring}    gnbMirroring.sh
${gnbMirroringConfig}    gnbMirroringConfig.sh
${scriptPath}    /ffs/run/config/scripts

*** Keywords ***
Start L1l2bipLogs on gNB
    SSH.Connect To        ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Execute           mkdir -p ${scriptPath}    &{GNB_ASIK}[Connection]
    ${command}            Catenate    scp ${EXECDIR}/${uteSosReportUtilityDir}/gnbMirroring*
    ...                   ${GNB_ASIK.Username}@${GNB_ASIK.Ip}:${scriptPath}
    Run                   ${command}
    SSH.Execute           ls -lrt ${scriptPath}    &{GNB_ASIK}[Connection]
    SSH.Execute           chmod 777 ${scriptPath}/gnbMirroring*    &{GNB_ASIK}[Connection]
    SSH.Execute           sh ${scriptPath}/${gnbMirroring}     &{GNB_ASIK}[Connection]
    sleep                 10s
    SSH.Disconnect        ${GNB_ASIK.Connection}

Move gNB L1l2bipLogs
    SSH.Connect To        ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Execute           ps -eaf|grep tcpdump    &{GNB_ASIK}[Connection]
    SSH.Execute           killall tcpdump    &{GNB_ASIK}[Connection]
    SSH.Execute           mkdir -p ${sosReportLogDir}    &{GNB_ASIK}[Connection]
    SSH.Execute           mv -v *.pcap*.* ${sosReportLogDir}    &{GNB_ASIK}[Connection]
    SSH.Execute           ls -lh ${sosReportLogDir}    &{GNB_ASIK}[Connection]
    SSH.Disconnect        ${GNB_ASIK.Connection}

Disable gNB Ports And Update sosScripts
    [Documentation]    Disabling gNB mirroring cmds and updating cmds in sosReport scripts.
    ${command}            Catenate    sed -i -z 's/enableFPGAMirroringOnGnb/#enableFPGAMirroringOnGnb/2'
    ...                   ${uteEpcDir}/${sosReportStart}
    Run    ${command}
    ${command}            Catenate    sed -i -z 's/enablePortMirroringFS $BTS_IP_1/#enablePortMirroringFS $BTS_IP_1/1'
    ...                   ${uteEpcDir}/${sosReportStart}
    Run    ${command}
    Log    "..Update tcpdump cmd interface for ASIB card in start sosScript.."
    ${command}            Catenate    sed -i -z 's/BTS_IP_1 *\"bsh 1:1/BTS_IP_1  \"bsh 1:0/1'
    ...                   ${uteEpcDir}/${sosReportStart}
    Run    ${command}
    Log    "..Update tcpdump cmd interface for ASIK card in start sosScript.."
    ${command}    Catenate    sed -i -z 's/BTS_IP_1 *\"bsh 1:2 tcpdump -i rlan0/BTS_IP_1 \"bsh 0:0 tcpdump -i etha01/1'
    ...                   ${uteEpcDir}/${sosReportStart}
    Run    ${command}
    Log     "...Update cmds in stop sosScript to pull the BIP logs..."
    ${command}    Catenate    sed -i -z "s/BTS_IP_1 *'(bsh 1:1 killall tcpdump)/BTS_IP_1 '(bsh 1:0 killall tcpdump)/g"
    ...                   ${uteEpcDir}/${sosReportStop}
    Run    ${command}
    ${command}    Catenate    sed -i -z "s/BTS_IP_1 *'(bsh 1:1 ls -ll)/BTS_IP_1 '(bsh 1:0 ls -ll)/g"
    ...                   ${uteEpcDir}/${sosReportStop}
    Run    ${command}
    Run    sed -i -z "s/BTS_IP_1 *1:1/BTS_IP_1 1:0/g" ${uteEpcDir}/${sosReportStop}
    ${command}    Catenate    sed -i -z "s/BTS_IP_1 *'(bsh 1:2 killall tcpdump)/BTS_IP_1 '(bsh 0:0 killall tcpdump)/g"
    ...                   ${uteEpcDir}/${sosReportStop}
    Run    ${command}
    ${command}    Catenate    sed -i -z "s/BTS_IP_1 *'(bsh 1:2 ls -ll)/BTS_IP_1 '(bsh 0:0 ls -ll)/g"
    ...                   ${uteEpcDir}/${sosReportStop}
    Run    ${command}
    Run    sed -i -z "s/BTS_IP_1 *1:2/BTS_IP_1 0:0/g" ${uteEpcDir}/${sosReportStop}
    Run    cp ${uteEpcDir}/${sosReportStart} ${EXECDIR}/logs
    Run    cp ${uteEpcDir}/${sosReportStop} ${EXECDIR}/logs

Check sosReport Script Exist
    File Should Exist    ${uteEpcDir}/${sosReportScript}
    File Should Exist    ${uteEpcDir}/${sosReportStart}
    File Should Exist    ${uteEpcDir}/${sosReportStop}

Copy sosReport Files
    Copy File    ${uteSosReportUtilityDir}/${sosReportStart}    ${uteEpcDir}/
    Copy File    ${uteSosReportUtilityDir}/${sosReportStop}     ${uteEpcDir}/

Upload sosReport Scripts
    [Timeout]    5 minutes
    Run Keyword And Ignore Error    Change sosReport Config

Change sosReport Config
    [Timeout]    5 minutes
    Copy sosReport Files
    Check sosReport Script Exist

Disable Mirroring of DCI Port
    Run    sed -i -e 's/\(dbgrrc mirror sport 15 dport 21 e b\)/#\1/' ${uteEpcDir}/${sosReportStart}
    Run    sed -i -e 's/\(dbgrrc mirror sport 15 dport 3 e b\)/#\1/' ${uteEpcDir}/${sosReportStart}
    ${check}    Run    grep dbgrrc ${uteEpcDir}/${sosReportStart}
    Log To Console    ${check}

Start sosReport Capture
    [Arguments]    ${prefix}=${EMTPY}    ${option}=${EMPTY}
    ${backslashEpcDir}    Replace String    ${uteEpcDir}    /    \\/
#    ${apConfiguration}    Get Environment Variable    AP_CONFIGURATION
    ${l1}                 Set Variable If    "fs_" in "${apConfiguration}"    fullstack    l1bypass
    Run Keyword And Ignore Error    Disable gNB Ports And Update sosScripts
    SSH.Connect To        ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    SSH.Connect To        ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Execute           bsh 0:1 rm -fv *pcap*.*    &{AP_ASIK}[Connection]
    SSH.Execute           bsh 0:1 rm -fv *pcap*.*    &{GNB_ASIK}[Connection]
    SSH.Execute           rm -fv ${sosReportMainDir}/*.pcap*    &{AP_ASIK}[Connection]
    SSH.Execute           rm -fv ${sosReportMainDir}/*.pcap*    &{GNB_ASIK}[Connection]
    SSH.Disconnect        ${AP_ASIK.Connection}
    SSH.Disconnect        ${GNB_ASIK.Connection}
    ${options}            Catenate
    ...                       ${option}
    ...                       --gnbMirrorProcedure=E
    ...                       --apMirrorProcedure=PH7
    ...                       -l1=${l1}
    ...                       -asikDIR=${sosReportMainDir}
    ...                       -iphyIP=&{AP_ASIK}[Ip]
    ...                       -iphyDIR=${backslashEpcDir}
    ...                       -btsIP=&{GNB_ASIK}[Ip]
    ...                       -btsDIR=${backslashEpcDir}
    ...                       -p=${prefix}
    #Specific workaround on robot for local launch of sosReportStart
    Log to Console        ${uteEpcDir}/${sosReportStart} ${options}
    SSH.Connect To        127.0.0.1    ute    ute    alias=sosReportConnection
    ${result}             SSH.Execute    ${uteEpcDir}/${sosReportStart} ${options}    sosReportConnection
    Log to Console        ${result}

Start WTS sosReport pcap
    [Arguments]    ${prefix}=${EMPTY}
    ${condition}      Catenate    "${prefix}" == "detach" or "fullstack" not in "${SUITE NAME}"
    Run Keyword if    ${condition}
    ...               Start WTS Tcpdump    /tmp/WTS.pcap

Start sosReport Tcpdump
    [Arguments]    ${prefix}=${EMPTY}
    [Timeout]    5 minutes
    Run Keyword if                  "cell" in "${prefix}"
    ...                             Disable Mirroring of DCI Port
    Run Keyword and Ignore Error    Start L1l2bipLogs on gNB
    Run Keyword and Ignore Error    Start sosReport Capture    ${prefix}
    Run Keyword and Ignore Error    Start WTS sosReport pcap    ${prefix}

Move sosReport Traces
    [Arguments]    ${connection}
    SSH.Execute       mkdir -p ${sosReportLogDir}    ${connection}
    Log To Console    ${sosReportLogDir}
    SSH.Execute        mv -v ${sosReportMainDir}/*.pcap*.gz ${sosReportLogDir}    ${connection}
    ${captureFiles}    SSH.Execute    ls -lh ${sosReportLogDir}    ${connection}
    Log To Console     ${captureFiles}

Stop WTS sosReport pcap
    [Arguments]    ${prefix}   ${exclude_pcap}=0
    Create Directory    /tmp/WTSpcap/
    Stop WTS Tcpdump    fileName=/tmp/WTS.pcap
    Run Keyword If   '${exclude_pcap}' == '1'   Run   sudo rm /tmp/WTS.pcap.tgz /tmp/WTS.pcap
    Return From Keyword If   '${exclude_pcap}' == '1'
    Run                 sudo chown ute /tmp/*WTS.pcap.tgz
    Run                 cd /tmp/ && ls *WTS.pcap.tgz | xargs -i mv {} /tmp/WTSpcap/${prefix}_{}
    List Directory      /tmp/WTSpcap/
    Run Keyword And Ignore Error    Create directory    ${EXECDIR}/logs/WTSpcap
    Run    mv /tmp/WTSpcap/* ${EXECDIR}/logs/WTSpcap/

Stop sosReport Capture
    [Arguments]    ${prefix}   ${exclude_pcap}=0
    ${backslashEpcDir}       Replace String    ${uteEpcDir}    /    \\/
#    ${apConfiguration}       Get Environment Variable    AP_CONFIGURATION
    ${l1}                    Set Variable If    "fs_" in "${apConfiguration}"    fullstack    l1bypass
    Run Keyword And Ignore Error
    ...                      Stop WTS sosReport pcap    ${prefix}   ${exclude_pcap}
    ${options}               Catenate
    ...                             --gnbMirrorProcedure=E
    ...                             --apMirrorProcedure=PH7
    ...                             -l1=${l1}
    ...                             -asikDIR=${sosReportMainDir}
    ...                             -iphyIP=&{AP_ASIK}[Ip]
    ...                             -iphyDIR=${backslashEpcDir}
    ...                             -btsIP=&{GNB_ASIK}[Ip]
    ...                             -btsDIR=${backslashEpcDir}
    ...                             -p=${prefix}
    ${options_with_exclude}=   Catenate   ${options}   --exclude
    ${options}=   Set Variable If   '${exclude_pcap}' == '0'   ${options}   ${options_with_exclude}
    ${command}               Catenate    cd ${uteEpcDir} && ./${sosReportStop} ${options} --only
    Log To Console           ${command}
    Run                      ${command}
    SSH.Connect To           ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    SSH.Connect To           ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    Run Keyword If   '${exclude_pcap}' == '0'   Move sosReport Traces    &{AP_ASIK}[Connection]
    Run Keyword If   '${exclude_pcap}' == '0'   Move sosReport Traces    &{GNB_ASIK}[Connection]
    @{configs}               Create List    /ffs/run/swconfig.txt    /rom/simmode/iphy.xml
    ${apCaptureFile}         SSH.Execute    ls -1h ${sosReportLogDir}    &{AP_ASIK}[Connection]
    Log To Console           ${apCaptureFile}
    ${gnbCaptureFile}        SSH.Execute    ls -1h ${sosReportLogDir}    &{GNB_ASIK}[Connection]
    Log To Console           ${gnbCaptureFile}
    SSH.Disconnect           ${AP_ASIK.Connection}
    SSH.Disconnect           ${GNB_ASIK.Connection}

Stop sosReport Tcpdump
    [Arguments]    ${prefix}   ${exclude_pcap}=0
    [Timeout]    40 minutes
    Run Keyword and Ignore Error    Stop sosReport Capture    ${prefix}   ${exclude_pcap}

Execute sosReport
    [Arguments]    ${path}    ${snapshot}=${TRUE}    ${withPcapCapture}=${TRUE}
    ${backslashEpcDir}    Replace String    ${uteEpcDir}    /    \\/
    Move Files            /tmp/WTSpcap/*WTS.pcap.tgz    /tmp/
    ${options}            Set Variable if    "${snapshot}" == "${TRUE}"
    ...                   -c -s    -s
    ${options}            Set Variable if    "${withPcapCapture}" == "${FALSE}"
    ...                   ${options} -e    ${options}
    ${options}            Catenate    ${options}
    ...                       -asikDIR=${sosReportLogDir}
    ...                       -iphyIP=&{AP_ASIK}[Ip]
    ...                       -iphyDIR=${backslashEpcDir}
    ...                       -btsIP=&{GNB_ASIK}[Ip]
    ...                       -btsDIR=${backslashEpcDir}
    ${command}            Catenate    cd ${path} && ${uteEpcDir}/${sosReportScript}
    ...                       -nr -d -split ${options}
    ...                       > ${EXECDIR}/logs/sosReport.log 2>\&1
    Run                   ${command}

Check sosReport Logs Exist
    [Arguments]    ${path}
    ${captureFile}                  Execute Ls on Path then Egrep    ${path}
    ...                             egrep=${sosReportResult}.*\.tgz
    ${result}                       Run    cd ${path} && ls -ll
    Log to Console                  ${result}
    ${result}                       Run    cd ${path} && ls ${captureFile} | tail -1
    Should Contain                  ${result}    ${sosReportResult}    msg=No SosReport Found
    Run Keyword and Ignore Error    Store In Archive Server    ${path}    ${captureFile}
    [Return]    ${result}

Execute sosReport Collection
    [Arguments]    ${withPcapCapture}=${TRUE}    ${btsSnapshot}=${FALSE}
    ...            ${path}=${EXECDIR}/&{ymlUteWtsLogDir}[wts]${uteEpcDir}
    [Timeout]    30 minutes
    Create Directory              ${path}
    Execute sosReport             ${path}    ${btsSnapshot}    ${withPcapCapture}
    Check sosReport Logs Exist    ${path}
    [Teardown]    Remove Files    /tmp/*WTS.pcap*

Collect sosReport
    Flush Egate
    Run Keyword if    "${PCAP_SOSREPORT}" == "1"
    ...               Execute sosReport Collection    withPcapCapture=${TRUE}    btsSnapshot=${TRUE}
    ...               ELSE IF    "${SUITE STATUS}" == "FAIL" and "${EXCLUDE_LOGS_IF_FAIL}" == "0"
    ...               Execute sosReport Collection    withPcapCapture=${TRUE}    btsSnapshot=${TRUE}
    ...               ELSE IF    "${SUITE STATUS}" == "PASS" and "${EXCLUDE_LOGS_IF_FAIL}" == "0"
    ...               Execute sosReport Collection    withPcapCapture=${FALSE}    btsSnapshot=${FALSE}
    ...               ELSE IF    "${SUITE STATUS}" == "PASS" and "${COLLECT_LOGS}" == "1"
    ...               Execute sosReport Collection    withPcapCapture=${TRUE}    btsSnapshot=${TRUE}
    ...               ELSE IF    "${SUITE STATUS}" == "FAIL"
    ...               Execute sosReport Collection    withPcapCapture=${TRUE}    btsSnapshot=${TRUE}

Stop WTS Tcpdump
    [Arguments]    ${fileName}=${EMPTY}
    [Documentation]    Stops tcpdump and compress pcap when given a filename.
    Run                   sudo pkill tcpdump
    Run Keyword Unless    "${fileName}" == "${EMPTY}"
    ...                   Compress Tcpdump file    ${fileName}

Compress Tcpdump file
    [Arguments]    ${fileName}=${EMPTY}
    ${tar}               Run    sudo tar -czvf ${fileName}.tgz ${fileName}
    Log To Console       ${tar}

Start WTS Tcpdump
    [Arguments]    ${pcapFile}    ${args}=-vvv
    Run                   sudo rm -f ${pcapFile}
    Run                   sudo tcpdump -i any -w ${pcapFile} > /dev/null 2>&1 &
    ${check}              Run    sudo pgrep -l tcpdump
    Log To Console        ${check} ${pcapFile}
    ${disown}             Run    disown --help
    Log To Console        ${disown}


Flush Egate
    Execute Egate Command    cmd=sim_log_set flush    alias=egate

Flush Egate UTE
    Execute Egate Command    cmd=sim_log_set flush

Set WTS Debug Log Level for Traffic
    [Arguments]    ${level}=2
    [Documentation]    Remove once PR is fixed
    wtsrunner.sim_debug_log    upf=1    level=${level}

Set WTS Default Debug Log Level
    [Arguments]    ${level}=1
    [Documentation]    Remove once PR is fixed
    wtsrunner.sim_debug_log    upf=1    level=${level}

Start Attach and Data Traffic TCPDUMP
   Start sosReport Tcpdump    attach_traffic
   Log                        "Starting gNBMirroring Script..."
   Run Keyword and Ignore Error    Start L1l2bipLogs on gNB

Stop Attach and Data Traffic TCPDUMP
   ${exclude_pcap}=   Check If PCAP Is To Be Excluded
   Log                "Moving gNB BIP Logs..."
   Run Keyword If    '${exclude_pcap}' == '0'    Move gNB L1l2bipLogs
   Run Keyword and Ignore Error    Stop sosReport Tcpdump    attach_traffic   ${exclude_pcap}

Check If PCAP Is To Be Excluded
    ${exclude_pcap}=   Set Variable If   '${CONDITIONAL_LOGGING}' == 'True' and '${TEST STATUS}' == 'PASS'   1   0
    [Return]   ${exclude_pcap}

Check if Log needs to be Collected
    ${skip_logs}=   Set Variable If   '${CONDITIONAL_LOGGING}' == 'True' and '${SUITE STATUS}' == 'PASS'   1   0
    [Return]   ${skip_logs}

Collect Logs For Run
   ${skip_logs}=   Check if Log needs to be Collected
   Run Keyword If   '${skip_logs}' == '1'   Delete UDP Syslog
   Return From Keyword If   '${skip_logs}' == '1'
   Run Keyword If  "${SUITE STATUS}" == "FAIL" or "${EXCLUDE_LOGS}" == "1"     Collect UTE Logs
   ...         ELSE    Collect UTE Configs

Delete UDP Syslog
   [Documentation]   Delete UDP Syslog to speed up copy Rota Server.
   Run Keyword And Ignore Error   Run   rm ${EXECDIR}/logs/udpsyslog/*
