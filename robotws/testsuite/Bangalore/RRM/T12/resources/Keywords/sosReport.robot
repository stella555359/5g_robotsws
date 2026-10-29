*** Settings ***
Documentation        SosReport related Keywrods are written in this file.
Library      BuiltIn
Library      Process
Library      OperatingSystem
Library      String
Library      Collections
Library      DateTime
Library      taf.wts.runner    WITH NAME    wtsrunner
Library      taf.transport.ssh  WITH NAME  SSH
Library      taf.collectors.pmcounters    WITH NAME   gnb_pmcounters
Resource     ${CURDIR}/common_keywords.robot

*** Variables ***
${sosReportScript}     sosReport.sh
${sosReportLogDir}     /tmp/sosreport
${VMsosReportLogDir}   /tmp/sosReport
${sosReportCfg}        sosReport.cfg
${sosReportMainDir}    /ffs/run/config/toor4nsn/logs
${sosReportStbDir}     /ffs/stb/config/toor4nsn/logs
${pcapRunDir}          /ffs/fs1/config/toor4nsn
${pcapStbDir}          /ffs/fs2/config/toor4nsn
${GnbBIPLogDir}        /tmp
${sosReportStart}      AP_Classical_Fullstack_startTestwithSosReport.sh
${sosReportStop}       AP_Classical_Fullstack_stopTestwithSosReport.sh
${sosReportResult}     SosReport
@{dport}               3    4    5    6   7   14   15    20    21    22    25

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
${gnbMirroring}    gnbMirroring.sh
${gnbMirroringConfig}    gnbMirroringConfig.sh
${scriptPath}    /ffs/run/config/scripts
${gnbMirroring_abio}    ABIO_mirror.sh
${gnbMirroring_abio_dir}    ${CURDIR}${/}../
${APMirroring_Loki}    Loki_AP_mirror.sh
${gnbMirroring_Loki}   Loki_gnb_mirror.sh
${Start_sos_ASIL}      sosReport_ASIL/startTest_ASIL.sh
${Stop_sos_ASIL}       sosReport_ASIL/stopTest_ASIL.sh

*** Keywords ***
Start Port mirroring on gNB SA TDD L1by
    SSH.Connect To        ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    ${tmp_var}            Mirror Ports loop
    Log To Console        ${tmp_var}
    SSH.Execute           ${tmp_var}    &{GNB_ASIK}[Connection]
    sleep                 5s
    SSH.Disconnect        ${GNB_ASIK.Connection}

Mirror Ports loop
    ${tmp_var}    Set Variable    ${EMPTY}
    FOR   ${dport_id}    IN    @{dport}
          ${tmp_var}    catenate    SEPARATOR=${SPACE}    ${tmp_var}    dbgrrc mirror sport ${dport_id} dport 2 e b &&
    END
    [RETURN]    ${tmp_var}

Start L1L2biplogs Using Custom ABIO Script
    # For LOKI AP, the mirroring procedure will be checked later
    log to console        starting bip logs for abio
    SSH.Connect To        ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Execute           mkdir -p ${scriptPath}    ${GNB_ASIK}[Connection]
    ${command}            Catenate    scp ${gnbMirroring_abio_dir}/${gnbMirroring_abio}
    ...                   ${GNB_ASIK.Username}@${GNB_ASIK.Ip}:${scriptPath}
    Run                   ${command}
    SSH.Execute           ls -lrt ${scriptPath}    ${GNB_ASIK}[Connection]
    SSH.Execute           chmod 777 ${scriptPath}/${gnbMirroring_abio}    ${GNB_ASIK}[Connection]
    SSH.Execute           sh ${scriptPath}/${gnbMirroring_abio} ${TOPOLOGY}    ${GNB_ASIK}[Connection]
    sleep                 10s
    SSH.Disconnect        ${GNB_ASIK.Connection}

Start L1L2biplogs for LOKI
    Return From Keyword If    '${apConfiguration}' == 'fs_tdd_sansa_eCpri_cmwv_ASOE_AP_LO'
    Start L1L2biplogs for LOKI AP and GNB    AP_ASIK    ${APMirroring_Loki}
    Start L1L2biplogs for LOKI AP and GNB    GNB_ASIK   ${gnbMirroring_Loki}

Start L1L2biplogs for LOKI AP and GNB
    [Documentation]    Temporary addition to collect bip logs on AP and gNB for Loki Configuration.
    [Arguments]    ${board_type}    ${file_name}
    log to console        starting bip logs for LOKI
    SSH.Connect To        ${${board_type}.Ip}    ${${board_type}.Username}    ${${board_type}.Password}    alias=${${board_type}.Connection}
    SSH.Execute           mkdir -p ${scriptPath}    ${${board_type}}[Connection]
    ${command}            Catenate    scp ${gnbMirroring_abio_dir}/${file_name}
    ...                   ${${board_type}.Username}@${${board_type}.Ip}:${scriptPath}
    Run                   ${command}
    SSH.Execute           ls -lrt ${scriptPath}    ${${board_type}}[Connection]
    SSH.Execute           chmod 777 ${scriptPath}/${file_name}    ${${board_type}}[Connection]
    SSH.Execute           sh ${scriptPath}/${file_name}     ${${board_type}}[Connection]
    sleep                 10s
    SSH.Disconnect        ${${board_type}.Connection}

Move gNB L1l2bipLogs
    SSH.Connect To        ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Execute           ps -eaf|grep tcpdump    ${GNB_ASIK}[Connection]
    SSH.Execute           killall tcpdump    ${GNB_ASIK}[Connection]
    SSH.Execute           mkdir -p ${sosReportLogDir}    ${GNB_ASIK}[Connection]
    SSH.Execute           mv -v *.pcap*.* ${sosReportLogDir}    ${GNB_ASIK}[Connection]
    SSH.Execute           ls -lh ${sosReportLogDir}    ${GNB_ASIK}[Connection]
    SSH.Disconnect        ${GNB_ASIK.Connection}

Disable gNB Ports And Update sosScripts
    [Documentation]    Disabling gNB mirroring cmds and updating cmds in sosReport scripts.
    ${command}            Catenate    sed -i -z 's/CHUNK_SIZE=20\\b/CHUNK_SIZE=200/1'
    ...                   ${uteEpcDir}/${sosReportCfg}
    Run    ${command}
    Run    cp ${uteEpcDir}/${sosReportStart} ${EXECDIR}/logs
    Run    cp ${uteEpcDir}/${sosReportStop} ${EXECDIR}/logs

Update tcpdump commands for LOKI
    [Documentation]    Temporary addition to collect bip logs on AP and gNB for Loki Configuration.
    Log    "..Update tcpdump cmd interface for ASIL card on AP side for Loki in start sosScript.."
    ${AP_command}   Catenate
    ...          sed -i -z 's/\$ssh $TL_USER@$IPHY_FCT_IP_1 *\"bsh 0:1 tcpdump -i pepbp1/$ssh $TL_USER@$IPHY_FCT_IP_1 "tcpdump -i nac_eth2/1'
    ...          ${uteEpcDir}/${sosReportStart}
    Run    ${AP_command}
    Log    "..Update tcpdump cmd interface for ASIL card on gNB side for Loki in start sosScript.."
    ${gnb_command}   Catenate    sed -i -z 's/BTS_IP_1 *\"bsh 1:1 tcpdump -i ethbp1/BTS_IP_1  \"bsh 1:0 tcpdump -i nac_eth4/1'
    ...          ${uteEpcDir}/${sosReportStart}
    Run    ${gnb_command}
    ${command}   Catenate    sed -i -z 's/\$ssh $TL_USER@$BTS_IP_1 *\"bsh 1:2 tcpdump -i rlan0/#$ssh $TL_USER@$BTS_IP_1 "bsh 1:2 tcpdump -i rlan0/1'
    ...          ${uteEpcDir}/${sosReportStart}
    Run    ${command}
    ${command}   Catenate    sed -i -z 's/\enablePortMirroringFS $IPHY_FCT_IP_1/#enablePortMirroringFS $IPHY_FCT_IP_1/1'
    ...          ${uteEpcDir}/${sosReportStart}
    Run    ${command}
    ${command}    catenate    sed -i -z 's/$ssh $TL_USER@$IPHY_FCT_IP_1 "bsh 1:2 tcpdump/#$ssh $TL_USER@$IPHY_FCT_IP_1 "bsh 1:2 tcpdump/g'
    ...          ${uteEpcDir}/${sosReportStart}
    Run    ${command}

    ${command}    Catenate    sed -i -z "s/bsh 1:1 killall tcpdump/bsh 1:0 killall tcpdump/g"
    ...          ${uteEpcDir}/${sosReportStop}
    Run    ${command}

    ${command}    Catenate    sed -i -z "s/bsh 1:1 ls -ll/bsh 1:0 ls -ll/g"
    ...          ${uteEpcDir}/${sosReportStop}
    Run    ${command}

    ${command}    Catenate    sed -i -z "s/$BTS_IP_1 1:1/$BTS_IP_1 1:0/g"
    ...          ${uteEpcDir}/${sosReportStop}
    Run    ${command}

    ${command}    Catenate    sed -i -z "s/\$IPHY_FCT_IP_1 0:1/\$IPHY_FCT_IP_1 0:0/g"
    ...          ${uteEpcDir}/${sosReportStop}
    Run    ${command}

Check sosReport Script Exist
    File Should Exist    ${uteEpcDir}/${sosReportScript}
    File Should Exist    ${uteEpcDir}/${sosReportStart}
    File Should Exist    ${uteEpcDir}/${sosReportStop}

Copy sosReport Files
    Copy File    ${uteSosReportUtilityDir}/${sosReportStart}    ${uteEpcDir}/
    Copy File    ${uteSosReportUtilityDir}/${sosReportStop}     ${uteEpcDir}/

Start BIP logs for APoverABIO
    [Arguments]    ${prefix}=${EMPTY}
    Run Keyword and Ignore Error    Start WTS sosReport pcap    ${prefix}
    Run    sudo chmod 777 ${uteEpcDir}/${Start_sos_ASIL}
    Log to Console        ${uteEpcDir}/${Start_sos_ASIL}
    SSH.Connect To        127.0.0.1    ute    ute    alias=sosReportConnection
    ${result}             SSH.Execute    ${uteEpcDir}/${Start_sos_ASIL}    sosReportConnection
    Log to Console        ${result}

Stop BIP and collect SOS for APoverABIO
    [Arguments]    ${prefix}=${EMPTY}    ${exclude_pcap}=0
    Run Keyword And Ignore Error
    ...                      Stop WTS sosReport pcap    ${prefix}   ${exclude_pcap}
    Run    sudo chmod 777 ${uteEpcDir}/${Stop_sos_ASIL}
    ${command}               Catenate    cd ${uteEpcDir} && ./${Stop_sos_ASIL} -o
    Log To Console           ${command}
    Run                      ${command}
    Move BIP logs from ap and gnb    ${prefix}    ${exclude_pcap}

Start sosReport Capture
    [Arguments]    ${prefix}=${EMTPY}    ${option}=${EMPTY}
    ${backslashEpcDir}    Replace String    ${uteEpcDir}    /    \\/
    ${l1}                 Set Variable If    "fs_" in "${apConfiguration}"    fullstack    l1bypass
    SSH.Connect To        ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    SSH.Connect To        ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Execute           bsh 0:1 rm -fv *pcap*.*    ${AP_ASIK}[Connection]
    SSH.Execute           bsh 0:1 rm -fv *pcap*.*    ${GNB_ASIK}[Connection]
    SSH.Execute           rm -fv ${sosReportMainDir}/*.pcap*    ${AP_ASIK}[Connection]
    SSH.Execute           rm -fv ${sosReportMainDir}/*.pcap*    ${GNB_ASIK}[Connection]
    SSH.Disconnect        ${AP_ASIK.Connection}
    SSH.Disconnect        ${GNB_ASIK.Connection}
    ${options}            Catenate
    ...                       ${option}
    ...                       --gnbMirrorProcedure=E
    ...                       --apMirrorProcedure=PH13
    ...                       -l1=${l1}
    ...                       -asikDIR=${sosReportMainDir}
    ...                       -iphyIP=${AP_ASIK}[Ip]
    ...                       -iphyDIR=${backslashEpcDir}
    ...                       -btsIP=${GNB_ASIK}[Ip]
    ...                       -btsDIR=${backslashEpcDir}
    ...                       -p=${prefix}
    ${options}=    run keyword if  (('ABIO' in '${gnb_cp_hardware}') or ('ABIN' in '${gnb_cp_hardware}')) and ('${ap_sm_hardware}' != 'ASIL')
    ...    Update options on Airphone scripts for using custom ABIO Script  ${options}
    ...    ELSE IF    ('${ap_sm_hardware}' == 'ASIL')   Update options for LOKI   ${options}
    ...    ELSE IF    ('${apConfiguration}' == 'l1b_tdd_sansa_cmwv')   Update options for ASIK ABIL L1b    ${options}
    ...    ELSE    Update options on Airphone scripts for using gNB MirroringScript   ${options}
    #Specific workaround on robot for local launch of sosReportStart
    Log to Console        ${uteEpcDir}/${sosReportStart} ${options}
    SSH.Connect To        127.0.0.1    ute    ute    alias=sosReportConnection
    ${result}             SSH.Execute    ${uteEpcDir}/${sosReportStart} ${options}    sosReportConnection
    Log to Console        ${result}

Update options on Airphone scripts for using custom ABIO Script
   [Arguments]   ${options}
   ${gnb_cp_hw}=   run keyword if  ('ABIO' in '${gnb_cp_hardware}')    Set Variable    ABIO
   ...    ELSE IF    ('ABIN' in '${gnb_cp_hardware}')    Set Variable    ABIN
   ${options}             Catenate
   ...                    ${options}
   ...                    -exclude=enableFPGAMirroringOnGnb,enablePortMirroringFSOnGnb,wait_for_interfacesOnGnb
   ...                    -gnb_sm_hw=${gnb_sm_hardware}
   ...                    -gnb_cp_hw=${gnb_cp_hw}
   [Return]    ${options}

Update options on Airphone scripts for using gNB MirroringScript
   [Arguments]   ${options}
   ${options}             Catenate
   ...                    ${options}
   ...                    -exclude=enableFPGAMirroringOnGnb,enablePortMirroringFSOnGnb,startTcpDumpOnGnb
   [Return]    ${options}

Update options for ASIK ABIL L1b
   [Arguments]   ${options}
   ${options}             Catenate
   ...                    ${options}
   ...                    -exclude=enableFPGAMirroringOnGnb,enablePortMirroringFSOnGnb
   [Return]    ${options}

Update options for LOKI
   [Arguments]   ${options}
   ${options}             Catenate
   ...                    ${options}
   ...                    -exclude=enableFPGAMirroringOnGnb,enablePortMirroringFSOnGnb,enablePortMirroringFSonAP
   [Return]    ${options}

Start WTS sosReport pcap
    [Arguments]    ${prefix}=${EMPTY}
    ${condition}      Catenate    "${prefix}" == "detach" or "fullstack" not in "${SUITE NAME}"
    Run Keyword if    ${condition}
    ...               Start WTS Tcpdump    ${EXECDIR}/logs/WTS.pcap
    Log               pcap started on wts

Move sosReport Traces
    [Arguments]    ${connection}
    SSH.Execute       mkdir -p ${sosReportLogDir}    ${connection}
    Log To Console    ${sosReportLogDir}
    SSH.Execute        gzip -9 -f ${GnbBIPLogDir}/tcpdump_L2L1_bip_filtering*    ${connection}
    SSH.Execute        mv -v ${GnbBIPLogDir}/*.pcap* ${sosReportLogDir}    ${connection}
    SSH.Execute        mv -v ${sosReportMainDir}/*.pcap* ${sosReportLogDir}    ${connection}
    ${captureFiles}    SSH.Execute    ls -lh ${sosReportLogDir}    ${connection}
    Log To Console     ${captureFiles}

Stop WTS sosReport pcap
    [Arguments]    ${prefix}   ${exclude_pcap}=0
    Create Directory    ${EXECDIR}/logs/WTSpcap/
    Run                   sudo pkill tcpdump
    Run Keyword If   '${exclude_pcap}' == '1'   Run    sudo rm ${EXECDIR}/logs/WTS.pcap.tgz ${EXECDIR}/logs/WTS.pcap ${EXECDIR}/logs/WTSpcap
    ...         ELSE    Stop WTS Tcpdump    fileName=${EXECDIR}/logs/WTS.pcap
    Return From Keyword If   '${exclude_pcap}' == '1'
    Run                 sudo chown ute ${EXECDIR}/logs/*WTS.pcap.tgz
    Run                 cd ${EXECDIR}/logs && ls *WTS.pcap.tgz | xargs -i mv {} ${EXECDIR}/logs/WTSpcap/${prefix}_{}
    List Directory      ${EXECDIR}/logs/WTSpcap/
    #Run Keyword And Ignore Error    Create directory    ${EXECDIR}/logs/WTSpcap
    #Run    mv /tmp/WTSpcap/* ${EXECDIR}/logs/WTSpcap/

Stop sosReport Capture
    [Arguments]    ${prefix}   ${exclude_pcap}=0
    ${backslashEpcDir}       Replace String    ${uteEpcDir}    /    \\/
    ${l1}                    Set Variable If    "fs_" in "${apConfiguration}"    fullstack    l1bypass
    Run Keyword And Ignore Error
    ...                      Stop WTS sosReport pcap    ${prefix}   ${exclude_pcap}
    ${options}               Catenate
    ...                             --gnbMirrorProcedure=E
    ...                             --apMirrorProcedure=PH13
    ...                             -l1=${l1}
    ...                             -asikDIR=${sosReportMainDir}
    ...                             -iphyIP=${AP_ASIK}[Ip]
    ...                             -iphyDIR=${backslashEpcDir}
    ...                             -btsIP=${GNB_ASIK}[Ip]
    ...                             -btsDIR=${backslashEpcDir}
    ...                             -p=${prefix}
    ${options_with_exclude}=   Catenate   ${options}   --exclude
    ${options}=   Set Variable If   '${exclude_pcap}' == '0'   ${options}   ${options_with_exclude}
    ${command}               Catenate    cd ${uteEpcDir} && ./${sosReportStop} ${options} --only
    Log To Console           ${command}
    Run                      ${command}
    SSH.Connect To           ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    SSH.Connect To           ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Execute              pkill -2 tcpdump    ${GNB_ASIK}[Connection]
    Run Keyword If   '${exclude_pcap}' == '0'   Move sosReport Traces    ${AP_ASIK}[Connection]
    Run Keyword If   '${exclude_pcap}' == '0'   Move sosReport Traces    ${GNB_ASIK}[Connection]
    ${apCaptureFile}         SSH.Execute    ls -1h ${sosReportLogDir}    ${AP_ASIK}[Connection]
    Log To Console           ${apCaptureFile}
    ${gnbCaptureFile}        SSH.Execute    ls -1h ${sosReportLogDir}    ${GNB_ASIK}[Connection]
    Log To Console           ${gnbCaptureFile}
    SSH.Disconnect           ${AP_ASIK.Connection}
    SSH.Disconnect           ${GNB_ASIK.Connection}

Stop sosReport Tcpdump
    [Arguments]    ${prefix}   ${exclude_pcap}=0
    [Timeout]    40 minutes
     Run Keyword if    '${ap_sm_hardware}' == 'ASIL'   Stop BIP and collect SOS for APoverABIO    ${prefix}    ${exclude_pcap}
    ...    ELSE    Run Keyword and Ignore Error    Stop sosReport Capture    ${prefix}   ${exclude_pcap}

Move BIP logs from ap and gnb
    [Arguments]    ${prefix}=${EMPTY}    ${exclude_pcap}=0
    SSH.Connect To           ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    SSH.Connect To           ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Execute              pkill -2 tcpdump    ${GNB_ASIK}[Connection]
    Run Keyword If           '${exclude_pcap}' == '0'    Bundle pcap files    ${AP_ASIK}[Connection]    ${prefix}
    Run Keyword If           '${exclude_pcap}' == '0'    Bundle pcap files    ${GNB_ASIK}[Connection]    ${prefix}
    SSH.Disconnect           ${AP_ASIK.Connection}
    SSH.Disconnect           ${GNB_ASIK.Connection}

Bundle pcap files
    [Arguments]    ${connection}    ${prefix}=${EMPTY}
    SSH.Execute    mkdir -p /tmp/bip    ${connection}
    SSH.Execute    chmod 777 /tmp/bip    ${connection}
    SSH.Execute    mv -v /tmp/*.pcap* /tmp/bip/    ${connection}
    SSH.Execute    cd /tmp/ && tar -czvf ${prefix}_pcap.tar.gz /tmp/bip/    ${connection}
    SSH.Execute    mkdir -p ${sosReportLogDir}     ${connection}
    SSH.Execute    mv -v /tmp/${prefix}_bip_pcap.tar.gz ${sosReportLogDir}    ${connection}

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
    ...                       -iphyIP=${AP_ASIK}[Ip]
    ...                       -iphyDIR=${backslashEpcDir}
    ...                       -btsIP=${GNB_ASIK}[Ip]
    ...                       -btsDIR=${backslashEpcDir}
    ${command}            Catenate    cd ${path} && ${uteEpcDir}/${sosReportScript}
    ...                       -nr -d -split ${options}
    ...                       > ${EXECDIR}/logs/sosReport.log 2>\&1
    Run                   ${command}

Stop WTS Tcpdump
    [Arguments]        ${fileName}=${EMPTY}
    [Documentation]    Stops tcpdump and compress pcap when given a filename.
    Run Keyword If       "${fileName}" != "${EMPTY}"
    ...                   Compress Tcpdump file    ${fileName}
    Run                   sudo rm -rf ${EXECDIR}/logs/*WTS.pcap ${VMsosReportLogDir}

Compress Tcpdump file
    [Arguments]    ${fileName}=${EMPTY}
    ${tar}               Run    sudo tar -czvf ${fileName}.tgz ${fileName}
    Log To Console       ${tar}

Start WTS Tcpdump
    [Arguments]    ${pcapFile}
    Run                   sudo rm -f ${pcapFile}
    Run                   sudo tcpdump -i any -w ${pcapFile} > /dev/null 2>&1 &
    ${check}              Run    sudo pgrep -l tcpdump
    Log To Console        ${check} ${pcapFile}
    ${disown}             Run    disown --help
    Log To Console        ${disown}

Start Attach and Data Traffic TCPDUMP
   [Arguments]    ${prefix}=attach_traffic
   Start sosReport Tcpdump    ${prefix}
   Log                        "Starting gNBMirroring Script..."

Stop Attach and Data Traffic TCPDUMP
   [Arguments]    ${prefix}=attach_traffic
   ${exclude_pcap}=   Check If PCAP Is To Be Excluded
   Run Keyword and Ignore Error    Stop sosReport Tcpdump    ${prefix}   ${exclude_pcap}
   Run Keyword and Ignore Error    Delete PCAPs from gNB and AP

Check If PCAP Is To Be Excluded
    ${exclude_pcap}=   Set Variable If   '${CONDITIONAL_LOGGING}' == 'True' and '${TEST STATUS}' == 'PASS'   1   0
    [Return]   ${exclude_pcap}

Check if Log needs to be Collected
    ${skip_logs}=   Set Variable If   '${CONDITIONAL_LOGGING}' == 'True' and '${SUITE STATUS}' == 'PASS'   1   0
    [Return]   ${skip_logs}

Collect Logs For Run
   [Arguments]    ${file}=${run_script_log_set}
   wtsrunner.Script    file=${file}    entry=sim_log_set_flush()
   wtsrunner.Script    file=${file}    entry=sim_log_re()
   ${skip_logs}=   Check if Log needs to be Collected
   Return From Keyword If   '${skip_logs}' == '1'
   Run Keyword If  "${SUITE STATUS}" == "FAIL" or "${EXCLUDE_LOGS}" == "1"     Collect UTE Logs
   ...         ELSE    Collect UTE Configs
   Run Keyword If   '${skip_logs}' == '0'   Collect gnb PM Counter Logs
   Run Keyword If   '${skip_logs}' == '0' and '${ap_sm_hardware}' == 'ASIL'
   ...   Run Keyword And Ignore Error    collect additional logs for LOKI

Delete PCAPs from gNB and AP
    [Documentation]   Removing pcaps to free up the space to avoid unexpected issues
    ...               in case of long runs like Concurrent Mode execution where consumes lot of memory.
    ...               below boards are picked up based on tcpdump cmds from sosReportStart script.
    [Timeout]    5 minutes
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    SSH.Connect To    ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Execute    bsh 0:1 ls -lrt    ${AP_ASIK}[Connection]
    Run Keyword And Ignore Error    SSH.Execute    bsh 0:1 rm -rf *.pcap*   ${AP_ASIK}[Connection]
    SSH.Execute    ls -lrt && bsh 1:0 ls -lrt    ${GNB_ASIK}[Connection]
    Run Keyword And Ignore Error   SSH.Execute    rm -rf *.pcap*    ${GNB_ASIK}[Connection]
    Run Keyword And Ignore Error   SSH.Execute    bsh 1:0 rm -rf *.pcap*    ${GNB_ASIK}[Connection]
    SSH.Disconnect           ${AP_ASIK.Connection}
    SSH.Disconnect           ${GNB_ASIK.Connection}

collect coldreset techLogSnapshot logs for LOKI
    SSH.Connect To   ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    SSH.Execute    command=cd /ffs/run/logs; tar zcvf coldreset.tgz coldreset
    ...            connection=${AP_ASIK}[Connection]
    SSH.Download File    remote_path=/ffs/run/logs/coldreset.tgz    local_path=${EXECDIR}/logs/coldreset.tgz
    ...            connection=${AP_ASIK}[Connection]
    SSH.Execute    command=cd /ffs/run/logs; tar zcvf techLogSnapshot.tgz techLogSnapshot
    ...            connection=${AP_ASIK}[Connection]
    SSH.Download File    remote_path=/ffs/run/logs/techLogSnapshot.tgz    local_path=${EXECDIR}/logs/techLogSnapshot.tgz
    ...            connection=${AP_ASIK}[Connection]
    SSH.Disconnect           ${AP_ASIK.Connection}

Collect additional logs for LOKI
    collect coldreset techLogSnapshot logs for LOKI
    Collect JounralCtl for Loki gNB

Collect JounralCtl for Loki gNB
    SSH.Connect To    ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Execute    bsh 1:1 journalctl -ab > /ffs/run/logs/gNB_journalctl.txt    connection=${GNB_ASIK}[Connection]
    SSH.Download File    remote_path=/ffs/run/logs/gNB_journalctl.txt    local_path=${EXECDIR}/logs/gNB_journalctl.txt
    ...              connection=${GNB_ASIK}[Connection]
    SSH.Disconnect    ${GNB_ASIK.Connection}

Collect gnb PM Counter Logs
    ${end_time}   Run Keyword And Ignore Error    Get Current DateTime
    ${duration}   Run Keyword And Ignore Error    Get Execution Duration
    ...    ${start_time[1]}    ${end_time[1]}
    Run Keyword And Ignore Error    Collect PM Counters     duration=${duration[1]}

Get Current DateTime
    ${date}=    Get Current Date      exclude_millis=yes
    ${DATE_TIME} =    Convert Date   ${date}     result_format=%Y.%m.%d %H:%M
    LogToConsole    ${DATE_TIME}
    [Return]    ${DATE_TIME}

Get Execution Duration
    [Arguments]    ${start_time}    ${end_time}
    [Documentation]    This keyword is used to calculate the duration for collecting gNB PM Counters

    ${DIFFERNCE_IN_TIME}=    Subtract Date from Date    ${end_time}    ${start_time}    verbose
    ${status}    ${match_group}=     Run Keyword And Ignore Error
    ...    Should Match Regexp        ${DIFFERNCE_IN_TIME}    ^(\\d+\\s+hour)s?\\s+(\\d+\\s+minute)
    ${duration}=    Run Keyword If    '${status}' == 'PASS'     Catenate
    ...    ${match_group[1]}     ${match_group[2]}
    Return From Keyword If    '${status}' == 'PASS'    ${duration}

    ${status}    ${duration}=      Run Keyword And Ignore Error
    ...    Should Match Regexp        ${DIFFERNCE_IN_TIME}    ^(\\d+\\s+minute)
    Return From Keyword If    '${status}' == 'PASS'    ${duration[1]}

Collect PM Counters
    [Documentation]   Collect gNB PM Counters Data
    [Arguments]      ${name}=gnb_pm_counters   ${duration}=${EMPTY}    ${intervals}=${EMPTY}    ${target_dir}=${EXECDIR}/logs

    ${webservice}=  Create Dictionary    host=${GNB_BTS.Ip}    user=${GNB_BTS.Username}    password=${GNB_BTS.Password}    port=${GNB_BTS.Port}
    Run Keyword If    '${duration}' and '${intervals}' == '${EMPTY}'
    ...     create PM collector   name=${name}    webservice=${webservice}   for_last=${duration}
    Run Keyword If    '${intervals}' and '${duration}'=='${EMPTY}'
    ...     create PM collector   name=${name}    webservice=${webservice}   intervals=${intervals}
    Run Keyword If    '${intervals}' != '${EMPTY}' and '${duration}' != '${EMPTY}'
    ...     create PM collector   name=gnb_pm_counters    webservice=${webservice}   for_last=${duration}    intervals=${intervals}
    Run Keyword If    '${duration}' == '${EMPTY}' and '${intervals}' == '${EMPTY}'
    ...     create PM collector   name=${name}    webservice=${webservice}

    gnb_pmcounters.setup_collectors    names=${name}
    gnb_pmcounters.collect_collectors    names=${name}    target_dir=${target_dir}
    gnb_pmcounters.teardown_collectors    names=${name}

Get AP Suite Configuration From File
    ${status}   Run Keyword And Return Status    File Should Exist    ${test_property_file}
    Run Keyword If    '${status}' == 'True'    Get PROPERTY File Data    ${test_property_file}
    Return From Keyword If    '${status}' == 'True'
    ${status}   Run Keyword And Return Status    File Should Exist    ${single_run_info_file}
    Run Keyword If    '${status}' == 'True'    Get INFO File Data    ${single_run_info_file}
    Return From Keyword If    '${status}' == 'True'
    Run Keyword If    '${status}' == 'False'    FAIL   TOPOLOGY:<TOPOLOGY_VALUE> Test Variable is Expected.

Get PROPERTY File Data
    [Arguments]    ${file_path}
    ${file_content}    OperatingSystem.Get File    ${file_path}
    ${topology}    Should Match Regexp        ${file_content}    NODE_TOPOLOGY=(\\S+)
    Log   JENKINS_RUN_TOPOLOGY=${topology[1]}
    Set AP Suite Configuration Variables    ${topology[1]}

Get INFO File Data
    [Arguments]    ${file_path}
    ${file_content}    OperatingSystem.Get File    ${file_path}
    ${topology}    Should Match Regexp        ${file_content}    LABEL:\\s+(\\S+)
    Log   SINGLE_RUNS_TOPOLOGY=${topology[1]}
    Set AP Suite Configuration Variables    ${topology[1]}

Set AP Suite Configuration Variables
    [Arguments]    ${TOPOLOGY}
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${${TOPOLOGY}}
    ${error}=    Catenate    User has passed wrong <TOPOLOGY> value. \n(OR)\n
                     ...   Mapping details is not defined for topology '${TOPOLOGY}' in common_variables file.
    Run Keyword If    '${status}' == 'FAIL'    FAIL    ${error}
    Set Suite Variable    ${TOPOLOGY}    ${TOPOLOGY}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END
    ${status}   ${value}=    Run Keyword And Ignore Error    Get Param Value From File    ${test_property_file}
    ...    variant_name=(\\S+)
    Run Keyword If    '${status}' == 'PASS'    Set Suite Variable    ${variant_name}    ${value}
    ...   ELSE   Set Suite Variable    ${variant_name}    ${variant_name}

Get Component Carrier Value From File
    [Documentation]    Keyword is used to fetch the component_carrier parm value from test properties
    ${result}   ${value}=    Run Keyword And Ignore Error    Get Param Value From File    ${test_property_file}
    ...    component_carrier=(\\d+)
    Run Keyword If    '${result}' == 'PASS'     Set Component Carrier Variables    component_carrier=${value}
    Return From Keyword If    '${result}' == 'PASS'
    Run Keyword If    '${result}' == 'FAIL'    Set Default Component Carrier Value

Get Param Value From File
    [Arguments]    ${file_path}    ${search_string}
    ${file_content}    OperatingSystem.Get File    ${file_path}
    ${matched_value}    Should Match Regexp        ${file_content}    ${search_string}
    Log   ${matched_value[1]}
    [Return]    ${matched_value[1]}

Set Default Component Carrier Value
   Log    COMPONENT_CARRIER details not found, so setting to default 1.
   Set Component Carrier Variables   component_carrier=1

Set Component Carrier Variables
    [Arguments]    ${component_carrier}
    ${status}    Run Keyword And Return Status    Should Match Regexp        ${component_carrier}    ^([1-9]+)$
    Run Keyword If    '${status}' == 'False'
    ...   FAIL    Format of the COMPONENT_CARRIER value is wrong. Please provide like 1 or 2 or 3..
    ${value}=   Convert To Integer    ${component_carrier}
    Set Suite Variable    ${component_carrier}    ${value}
    ${AP_P1Perf}=    Get Variable Value    ${AP_P1Perf}    False
    Set Suite Variable    ${AP_P1Perf}
    ${p1perf_ue_count}=    Get Variable Value    ${p1perf_ue_count}    2
    ${result}     Run Keyword If    '${AP_P1Perf}' == 'True'    Set Variable     ${P1Perf_ue_count}
    ${component_carrier}=      Set Variable If    "${result}" == 'None'    ${component_carrier}    ${result}
    ${AP_P1Perf_mmwv}=    Get Variable Value    ${AP_P1Perf_mmwv}    False
    Set Suite Variable    ${AP_P1Perf_mmwv}
    ${p1perf_mmwv_ue_count}=    Get Variable Value    ${p1perf_mmwv_ue_count}    20
    ${result}     Run Keyword If    '${AP_P1Perf_mmwv}' == 'True'    Set Variable     ${p1perf_mmwv_ue_count}
    ${component_carrier}=      Set Variable If    "${result}" == 'None'    ${component_carrier}    ${result}
    ${sa_ueids_val}=    Get Variable Value    ${sa_ueids}
    ${nsa_ueids_val}=    Get Variable Value    ${nsa_ueids}
    ${lte_ueids_val}=    Get Variable Value    ${lte_ueids}
    ${targetcell_ids_val}=    Get Variable Value    ${targetcell_ids}
    ${gw_ids_val}=    Get Variable Value    ${gw_ids}

    @{sa_ueids_temp}=             Create List
    @{nsa_ueids_temp}=            Create List
    @{targetcell_ids_temp}=       Create List
    @{gw_ids_temp}=                    Create List
    @{lte_ueids_temp}=                 Create List

    FOR    ${value}    IN RANGE    ${component_carrier}
        Append To List    ${targetcell_ids_temp}   ${value+1}
        Append To List    ${gw_ids_temp}           ${value+1}
        Append To List    ${sa_ueids_temp}         ${value+1}
        Append To List    ${nsa_ueids_temp}        ${value+11}
        Append To List    ${lte_ueids_temp}        ${value+21}
    END
    ${sa_ueids}=          Override Test Variables with Default Variables    ${sa_ueids_val}          ${sa_ueids_temp}
    ${nsa_ueids}=         Override Test Variables with Default Variables    ${nsa_ueids_val}         ${nsa_ueids_temp}
    ${lte_ueids}=         Override Test Variables with Default Variables    ${lte_ueids_val}         ${lte_ueids_temp}
    ${targetcell_ids}=    Override Test Variables with Default Variables    ${targetcell_ids_val}    ${targetcell_ids_temp}
    ${gw_ids}=            Override Test Variables with Default Variables    ${gw_ids_val}            ${gw_ids_temp}

    Set Suite Variable    @{sa_ueids}
    Set Suite Variable    @{nsa_ueids}
    Set Suite Variable    @{lte_ueids}
    Set Suite Variable    @{gw_ids}
    Set Suite Variable    @{targetcell_ids}

    Run Keyword if    '${4G5G_Combo}' == '1' and '${variant_name}' == '4G5G_COMBO_MultiUE'
    ...    Update ueids for Combo MultiUE    ue_count=20
    Append Test Property File For UE_IDs

Update ueids for Combo MultiUE
    [Arguments]    ${ue_count}
    ${sa_ueids_val}=    Get Variable Value    ${sa_combo_mue_ueids}
    ${nsa_ueids_val}=    Get Variable Value    ${nsa_combo_mue_ueids}
    ${lte_ueids_val}=    Get Variable Value    ${lte_combo_mue_ueids}
    @{sa_ueids_temp}=    Create List
    @{nsa_ueids_temp}=   Create List
    @{lte_ueids_temp}=   Create List
    FOR    ${value}    IN RANGE    ${ue_count}
       Append To List    ${sa_ueids_temp}    ${value+51}
       Append To List    ${nsa_ueids_temp}   ${value+21}
       Append To List    ${lte_ueids_temp}   ${value+1}
    END
    ${sa_ueids}=    Override Test Variables with Default Variables    ${sa_ueids_val}    ${sa_ueids_temp}
    ${nsa_ueids}=    Override Test Variables with Default Variables    ${nsa_ueids_val}    ${nsa_ueids_temp}
    ${lte_ueids}=    Override Test Variables with Default Variables    ${lte_ueids_val}    ${lte_ueids_temp}
    Set Suite Variable    @{sa_ueids}
    Set Suite Variable    @{nsa_ueids}
    Set Suite Variable    @{lte_ueids}

Override Test Variables with Default Variables
   [Arguments]    ${variable_value}    ${generated_value}
   Return From Keyword If      '${variable_value}' == 'None'    ${generated_value}

   @{temp_list}=    Split String    ${variable_value}    ,
   [Return]    ${temp_list}

Append Test Property File For UE_IDs
   ${status}   Run Keyword And Return Status    File Should Exist    ${test_property_file}
   Run Keyword If    '${status}' == 'True'     Update Property File For UE_ID Values

Update Property File For UE_ID Values
   Append To File     ${test_property_file}    ${\n}sa_ueids=@{sa_ueids}${\n}
   Append To File     ${test_property_file}    nsa_ueids=@{nsa_ueids}${\n}
   Append To File     ${test_property_file}    lte_ueids=@{lte_ueids}${\n}
   Append To File     ${test_property_file}    gw_ids=@{gw_ids}${\n}
   Append To File     ${test_property_file}    targetcell_ids=@{targetcell_ids}${\n}

Run Command Locally And Return Output
    [Arguments]    ${command}
    ${rc}	       ${output}=	    Run and Return RC and Output     ${command}
    Log            ${rc}
    [Return]       ${output}

Get Init File Details
    [Arguments]    ${main_path}    ${init_file_path}
    ${init_file}=    Catenate      SEPARATOR=/    ${main_path}    ${init_file_path}
    ${result}   ${value}=     Run Keyword And Ignore Error    File Should Exist    ${init_file}
    Return From Keyword If    '${result}' == 'PASS'      ${init_file}
    Return From Keyword If    '${result}' == 'FAIL'      FAIL
    [Return]    ${value}

Clone Testline Configuration Repo
    [Arguments]    ${hostname}
    Run    git clone "https://gerrit.ext.net.nokia.com/gerrit/MN/UTE/testline_configuration"
    ${result}=   Get Init File Details     testline_configuration    ${hostname}/__init__.py
    Return From Keyword If    '${result}' != 'FAIL'      ${result}
    ${error}=    Catenate    Not finding '${hostname}' details in 'testline_configuration' repo.
                    ...   Please check the host details existance for Testline ${hostname}.
                    ...   https://gerrit.ext.net.nokia.com/gerrit/#/admin/projects/MN/UTE/testline_configuration
    Run Keyword If    '${result}' == 'FAIL'   FAIL    ${error}

Get Matching Lines From Regex
    [Arguments]    ${output}    ${search_string}
    ${matched_value}=    Get Lines Matching Regexp    ${output}    ${search_string}
    [Return]    ${matched_value}

Set Secondary Test PC Credentials
    [Arguments]    ${init_file}
    ${output}=    Run Command Locally And Return Output    grep -A 2 TestPc ${init_file}
    ${rc}   ${value}=     Run Keyword And Ignore Error    Get Matching Lines From Regex
    ...    ${output}    (\\s+addr=.*)
    @{lines}=    Split String  ${value}    \n
    Log    ${rc}
    Length Should Be    ${lines}   2   Not able to find Test PC2 Setup Details from '${init_file}'
    ${matched_value}    Should Match Regexp        ${lines[1]}    \\s+addr="(.*)",\\s+username="(.*)",\\s+password="(.*)"
    &{test_pc2}=    Create Dictionary    addr=${matched_value[1]}    username=${matched_value[2]}    password=${matched_value[3]}
    Set Suite Variable     &{test_pc2}
    Set Suite Variable     ${init_file}

