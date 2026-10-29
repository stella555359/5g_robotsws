# Copyright (c) 2019 Nokia. All rights reserved.

*** Settings ***
Documentation     This contains common keywords which are needed to collect the logs.
...               :author Anil

Library    BuiltIn
Library    Process
Library    OperatingSystem
Library    String
Library    Collections
Library    DateTime
Library    taf.wts.runner    WITH NAME    wtsrunner
Library    taf.transport.ssh  WITH NAME  SSH
Library    taf.collectors.pmcounters    WITH NAME   gnb_pmcounters
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.core    WITH NAME    core
Resource    archive.robot
Resource    ../../resources/Keywords/common_keywords.robot


*** Variables ***
${sosReportScript}     sosReport_ASIL/sosReport_ASIL.sh
${sosReportLogDir}     /tmp/sosreport
${VMsosReportLogDir}   /tmp/sosReport
${sosReportCfg}        sosReport.cfg
${sosReportMainDir}    /ffs/run/config/toor4nsn/logs
${sosReportStbDir}     /ffs/stb/config/toor4nsn/logs
${pcapRunDir}          /ffs/fs1/config/toor4nsn
${pcapStbDir}          /ffs/fs2/config/toor4nsn
${GnbBIPLogDir}        /tmp
${sosReportStart}      sosReport_ASIL/startTest_ASIL.sh
${sosReportStop}       sosReport_ASIL/stopTest_ASIL.sh
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
${Start_sos_ASIL}      startTest.sh
${Stop_sos_ASIL}       stopTest.sh
${Disable_gNB_Log_Collection}    False

#IQ_Syslog_Variables
${CFG}             confmgmtdefscli
${NR_DOMAIN}       NrUeDlPhy
@{RAD_PARAMS}      radIqDumpInSyslog=13    radIqDumpInSyslogSlotBitmask=1    radIqDumpInSyslogSfnPeriodicity=2
@{TARGET_BSH_IPs_AP}      192.168.253.85    192.168.253.86

${gNB_bsh_ip_1_1}    192.168.253.37
${gNB_bsh_ip_0_1}    192.168.253.33
${AP_bsh_ip_0_1}     192.168.253.81
${gNB_bsh_ip_1_0}    192.168.253.36
${gNB_bsh_ip_1_2}    192.168.253.38

*** Keywords ***
Start L1l2bipLogs on gNB
    Run Keyword If    '${ap_sm_hardware}' == 'ASIK'    Start Mirroring on gNB using admin api

Start Mirroring on gNB using admin api
    [Arguments]    ${interface}=${interface_case}    ${destination}=${destination}    ${mirroring_time}=${mirroring_time}
    admin.Connect To
    admin.interface_mirroring    operation=Start    interface=${interface}    destination=${destination}
    ...    mirroring_time=${mirroring_time}
    [Teardown]    admin.Teardown

Stop Mirroring on gNB using admin api
    [Arguments]    ${prefix}    ${exclude_pcap}=0    ${interface}=${interface_case}    ${destination}=${destination}
    ...    ${mirroring_time}=${mirroring_time}
    admin.Connect To
    admin.interface_mirroring    operation=Stop    interface=${interface}    destination=${destination}
    ...    mirroring_time=${mirroring_time}
    Log    ${exclude_pcap}!!!
    sleep                 5s
    Run    mkdir -p ${vm_logdir}/BIP/
    admin.collect_mirroring_logs    output_file_name=${vm_logdir}/BIP/interface_mirroring_${prefix}.zip
    ...    timeout=${mirroring_timeout}
    [Teardown]    admin.Teardown

Start Port mirroring on gNB SA TDD L1by
    SSH.Connect To        ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    ${tmp_var}            Mirror Ports loop
    Log To Console        ${tmp_var}
    SSH.Execute           ${tmp_var}    ${GNB_ASIK}[Connection]
    sleep                 5s
    SSH.Disconnect        ${GNB_ASIK.Connection}

Check and Disable gNB Logging In startTest_ASIL script
    Return From Keyword If    "${Disable_gNB_Log_Collection}" == "False"
    ${command}          catenate    sed -i -z 's/GNB_LOG=true/GNB_LOG=false/1'    /opt/wts/latest/sosReport_ASIL/startTest_ASIL.sh
    Run And Return Rc And Output    ${command}

Mirror Ports loop
    ${tmp_var}    Set Variable    ${EMPTY}
    FOR   ${dport_id}    IN    @{dport}
          ${tmp_var}    catenate    SEPARATOR=${SPACE}    ${tmp_var}    dbgrrc mirror sport ${dport_id} dport 2 e b &&
    END
    [Return]    ${tmp_var}

Start L1L2biplogs Using gNb Mirroring Script
    [Arguments]    ${prefix}=${EMPTY}
    SSH.Connect To        ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Execute           mkdir -p ${scriptPath}    ${GNB_ASIK}[Connection]
    ${command}            Catenate    scp ${CURDIR}/gnbMirroring*
    ...                   ${GNB_ASIK.Username}@${GNB_ASIK.Ip}:${scriptPath}
    Run                   ${command}
    SSH.Execute           ls -lrt ${scriptPath}    ${GNB_ASIK}[Connection]
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sansa_ASIB_cmwv' or '${apConfiguration}' == 'fs_fdd_sansa_ASIB_cmwv'
    ...    Update the gNB Mirroring config file for ASIB Variants    40    20
    Run Keyword If    '${apConfiguration}' == '${HTpCfg}[2]'
    ...    Update the BBSlot value in gNB Mirroring script for FDD ASIB ABIO
    SSH.Execute           chmod 777 ${scriptPath}/gnbMirroring*    ${GNB_ASIK}[Connection]
    ${command}            Set Variable    --filtering=${prefix}
    SSH.Send Command      sh ${scriptPath}/${gnbMirroring} ${command} &     connection=${GNB_ASIK}[Connection]
    sleep                 10s
    SSH.Disconnect        ${GNB_ASIK.Connection}

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
    Run Keyword If    '${4G_5GCUS}' == '1'    Update sosScripts for Combo
    Run    cp ${uteEpcDir}/${sosReportStart} ${EXECDIR}/logs
    Run    cp ${uteEpcDir}/${sosReportStop} ${EXECDIR}/logs

Update sosScripts for Combo
    ${command}    Catenate    sed -i -z 's/BTS_IP_1=${GNB_BTS_IP}\\b/BTS_IP_1=${4G5G_Combo_GNB_IP}/1'
    ...    ${uteEpcDir}/${sosReportCfg}
    Run    ${command}

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

Start BIP logs for APoverABIO
    [Arguments]    ${prefix}=${EMPTY}
    Run Keyword If    '${SAVE_WTS_PCAP_FLAG}' == 'True'
    ...    Run Keyword and Ignore Error    Start WTS sosReport pcap    ${prefix}
    Run    sudo chmod 777 ${uteEpcDir}/${Start_sos_ASIL}
    Log to Console        ${uteEpcDir}/${Start_sos_ASIL}
    Run    sudo chmod 777 ${CURDIR}/sosreport_in_bg.sh
    SSH.Connect To        127.0.0.1    ute    ute    alias=sosReportConnection
    ${result}             Run Keyword If    '${CONDITIONAL_LOGGING}' == 'True'
    ...    Run    sh ${CURDIR}/sosreport_in_bg.sh start
    ...    ELSE    SSH.Send Command    ${uteEpcDir}/${Start_sos_ASIL}    connection=sosReportConnection    timeout=30s
    Log to Console        ${result}

Stop BIP and collect SOS for APoverABIO
    [Arguments]    ${prefix}=${EMPTY}    ${exclude_pcap}=0
    Run Keyword If    '${SAVE_WTS_PCAP_FLAG}' == 'True'
    ...    Run Keyword And Ignore Error    stop and collect wts tcpdump    ${prefix}    ${exclude_pcap}
    Run    sudo chmod 777 ${uteEpcDir}/${Stop_sos_ASIL}
    ${command}               Catenate    cd ${uteEpcDir} && ./${Stop_sos_ASIL} -o
    Log To Console           ${command}
    Run    sudo chmod 777 ${CURDIR}/sosreport_in_bg.sh
    Run Keyword If    '${CONDITIONAL_LOGGING}' == 'True' and '${exclude_pcap}' != 1
    ...    Run    sh ${CURDIR}/sosreport_in_bg.sh stop    ELSE    Run    ${command}
    Run Keyword If    '${QT_CONFIG}' == 'True'    Run Keyword and Ignore Error    Bundle AP And gNB BIP Logs    ${prefix}    ${exclude_pcap}
    Move BIP logs from ap and gnb    ${prefix}    ${exclude_pcap}

Start sosReport Capture
    [Arguments]    ${prefix}=${EMTPY}    ${option}=${EMPTY}
    ${backslashEpcDir}    Replace String    ${uteEpcDir}    /    \\/
    ${l1}                 Set Variable If    "fs_" in "${apConfiguration}"    fullstack    l1bypass
    SSH.Connect To        ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=ap_middle
    SSH.Connect To        ${AP_bsh_ip_0_1}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    proxy=ap_middle    alias=ap_target
    SSH.Connect To        ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=gnb_middle
    SSH.Execute           ${gNB_bsh_ip_0_1}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    proxy=gnb_middle    alias=gnb_target
    SSH.Execute           command=rm -fv *pcap*.*    connection=gnb_target
    SSH.Execute           command=rm -fv *pcap*.*    connection=ap_target
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
    ...    ELSE IF    ('ABIP' in '${gnb_cp_hardware}')   Update Options For SosReport Script    ${options}    ${sosreport_options_ABIP}
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

Update Options For SosReport Script
   [Arguments]   ${options}    ${options_exclude}
   ${options}             Catenate    ${options}    ${options_exclude}
   [Return]    ${options}

Start WTS sosReport pcap
    [Arguments]    ${prefix}=${EMPTY}
    ${condition}      Catenate    "${prefix}" == "detach" or "fullstack" not in "${SUITE NAME}"
    Run Keyword if    ${condition}
    ...               Setup and Start WTS Tcpdump collectors    ${prefix}

Start sosReport Tcpdump
    [Arguments]    ${prefix}=${EMPTY}
    [Timeout]    10 minutes
        Run Keyword If     '${apConfiguration}' == 'fs_fdd_tdd_sansa_cmwv_h_ap_loo'
    ...    Run Keywords    Log To Console    Skipping the mirroring and BIP log collection
    ...    AND    Return From Keyword
    Log    ${prefix}!!!!
    Start BIP logs for APoverABIO    ${prefix}

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
    Create Directory    ${vm_logdir}/WTSpcap/
    Run                   sudo pkill tcpdump
    Kill Deleted Process
    Run Keyword If   '${exclude_pcap}' == '1'   Run    sudo rm -rf ${vm_logdir}/WTS.pcap.tgz ${vm_logdir}/WTS.pcap ${vm_logdir}/WTSpcap
    ...         ELSE    Stop WTS Tcpdump    fileName=${vm_logdir}/WTS.pcap
    Return From Keyword If   '${exclude_pcap}' == '1'
    Run                 sudo chown ute ${vm_logdir}/*WTS.pcap.tgz
    Run                 cd ${EXECDIR}/logs && ls *WTS.pcap.tgz | xargs -i mv {} ${vm_logdir}/WTSpcap/${prefix}_{}
    List Directory      ${vm_logdir}/WTSpcap/

Kill Deleted Process
    Run And Return Rc And Output    sudo pkill tcpdump
    Run And Return Rc And Output    sudo ps -aef | grep -i tcpdump
    Run And Return Rc And Output    lsof +L1

Stop sosReport Capture
    [Arguments]    ${prefix}   ${exclude_pcap}=0
    ${backslashEpcDir}       Replace String    ${uteEpcDir}    /    \\/
    ${l1}                    Set Variable If    "fs_" in "${apConfiguration}"    fullstack    l1bypass
    Run Keyword If    '${SAVE_WTS_PCAP_FLAG}' == 'True'
    ...    Run Keyword And Ignore Error    stop and collect wts tcpdump    ${prefix}    ${exclude_pcap}
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
    @{configs}               Create List    /ffs/run/swconfig.txt    /rom/simmode/iphy.xml
    ${apCaptureFile}         SSH.Execute    ls -1h ${sosReportLogDir}    ${AP_ASIK}[Connection]
    Log To Console           ${apCaptureFile}
    ${gnbCaptureFile}        SSH.Execute    ls -1h ${sosReportLogDir}    ${GNB_ASIK}[Connection]
    Log To Console           ${gnbCaptureFile}
    SSH.Disconnect           ${AP_ASIK.Connection}
    SSH.Disconnect           ${GNB_ASIK.Connection}

Stop sosReport Tcpdump
    [Arguments]    ${prefix}   ${exclude_pcap}=0
    [Timeout]    40 minutes
    Run Keyword if    '${ap_sm_hardware}' != 'ASIK'   Stop BIP and collect SOS for APoverABIO    ${prefix}    ${exclude_pcap}
    ...    ELSE    Run Keyword and Ignore Error    Stop BIP and collect Logs for APoverASIK    ${prefix}   ${exclude_pcap}

Stop BIP and collect Logs for APoverASIK
    [Arguments]    ${prefix}   ${exclude_pcap}=0
    Stop Mirroring on gNB using admin api    ${prefix}   ${exclude_pcap}
    Stop sosReport Capture    ${prefix}   ${exclude_pcap}

Move BIP logs from ap and gnb
    [Arguments]    ${prefix}=${EMPTY}    ${exclude_pcap}=0
    SSH.Connect To           ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    Run Keyword If           '${exclude_pcap}' == '0'    Bundle pcap files    ${AP_ASIK}[Connection]    ${prefix}
    SSH.Disconnect           ${AP_ASIK.Connection}
    Run Keyword If    "${Disable_gNB_Log_Collection}" == "False"    Move BIP logs from gNB    ${prefix}    ${exclude_pcap}

Move BIP logs from gNB
    [Arguments]    ${prefix}=${EMPTY}    ${exclude_pcap}=0
    SSH.Connect To           ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Execute              pkill -2 tcpdump    ${GNB_ASIK}[Connection]
    Run Keyword If           '${exclude_pcap}' == '0'    Bundle pcap files    ${GNB_ASIK}[Connection]    ${prefix}
    SSH.Disconnect           ${GNB_ASIK.Connection}

Bundle pcap files
    [Arguments]    ${connection}    ${prefix}=${EMPTY}
    SSH.Execute    mkdir -p /tmp/bip    ${connection}
    SSH.Execute    chmod 777 /tmp/bip    ${connection}
    SSH.Execute    mv -v /tmp/*.pcap* /tmp/bip/    ${connection}
    SSH.Execute    mv -v /tmp/sosreport/*.pcap* /tmp/bip/    ${connection}
    SSH.Execute    mv -v /tmp/sosReport/*.pcap* /tmp/bip/    ${connection}
    SSH.Execute    df -kh    ${connection}
    SSH.Execute    ls -ltr /tmp/bip/    ${connection}
    SSH.Execute    mkdir -p ${sosReportLogDir}     ${connection}
    ${status}    ${value}    Run Keyword And Ignore Error    SSH.Execute    cd /tmp/ && tar -czvf ${prefix}_pcap.tar.gz /tmp/bip/    ${connection}
    Run Keyword If    "${status}" == "PASS"    SSH.Execute    rm -r /tmp/bip/*.pcap*    ${connection}
    Run Keyword If    "${status}" == "PASS"    SSH.Execute    mv -v /tmp/${prefix}_bip_pcap.tar.gz ${sosReportLogDir}    ${connection}
    ...    ELSE    SSH.Execute    mv -v /tmp/bip/* ${sosReportLogDir}    ${connection}

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
    ...                       > ${vm_logdir}/sosReport.log 2>\&1
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
    ...            ${path}=${EXECDIR}/${ymlUteWtsLogDir}[wts]${uteEpcDir}
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

Setup and Start WTS Tcpdump collectors
    [Arguments]    ${prefix}
    tcpdump.create_tcpdump_collector
    ...    name=wts
    ...    options=-i any sctp
    ...    target_file_name=${prefix}_wts.pcap
    core.setup_collectors    names=wts
    core.start_collectors    names=wts
    core.set_suite_alias     wts

stop and collect wts tcpdump
    [Arguments]    ${prefix}    ${exclude_pcap}=0
    core.stop_collectors    names=wts
    core.collect_collectors    names=wts    target_dir=${vm_logdir}/${prefix}
    core.teardown_collectors    names=wts
    Run Keyword If    ${exclude_pcap}==1    RUN    sudo rm -rf ${vm_logdir}/${prefix}/*

Stop WTS Tcpdump
    [Arguments]    ${fileName}=${EMPTY}
    [Documentation]    Stops tcpdump and compress pcap when given a filename.
    Run Keyword If    "${fileName}" != "${EMPTY}"
    ...                   Compress Tcpdump file    ${fileName}
    Run                   sudo rm -rf ${vm_logdir}/*WTS.pcap ${VMsosReportLogDir}

Start WTS tcpdump for Traffic
    [Arguments]    ${prefix}
    RUN    mkdir -p ${EXECDIR}/logs/${prefix}/
    RUN    sudo tcpdump -i eth3 udp -w ${EXECDIR}/logs/${prefix}/eth3_${prefix}.gz -C 500 -s 100 -z gzip -Z ute > /dev/null 2>&1 &
    RUN    sudo tcpdump -i eth4 udp -w ${EXECDIR}/logs/${prefix}/eth4_${prefix}.gz -C 500 -s 100 -z gzip -Z ute > /dev/null 2>&1 &

Stop WTS tcpdump for Traffic
    [Arguments]    ${prefix}    ${exclude_pcap}
    ${result}=    Run Process    bash    -c    ps -ef | grep ${prefix}    stdout=PIPE    stderr=PIPE    shell=True
    ${output}=    Set Variable    ${result.stdout}
    ${lines}=     Split String    ${output}    \n
    ${pids}=      Create List
    FOR    ${line}    IN    @{lines}
        ${line}=    Strip String    ${line}
        Run Keyword If    '${line}' != ''    Append To List    ${pids}    ${line.split()[1]}
    END
    FOR    ${pid}    IN    @{pids}
        RUN    sudo kill -9 ${pid}
    END
    Copy WTS UDP pcap files    ${exclude_pcap}    ${prefix}

Copy WTS UDP pcap files
    [Arguments]    ${exclude_pcap}    ${prefix}
    Run Keyword If    ${LOG_SYNC} == True    Move WTS Pcap To Log Sync Folder    ${exclude_pcap}    ${prefix}
    ...    ELSE    Keep logs in Execution folder    ${exclude_pcap}    ${prefix}

Keep logs in Execution folder
    [Arguments]    ${exclude_pcap}    ${prefix}
    Run Keyword If    '${exclude_pcap}' == '1'    RUN    rm -rf ${EXECDIR}/logs/${prefix}/*${prefix}.gz*

Move WTS Pcap To Log Sync Folder
    [Arguments]    ${exclude_pcap}    ${prefix}
    RUN    mkdir -p ${vm_logdir}/${prefix}
    Run Keyword If    '${exclude_pcap}' == '1'    RUN    rm -rf ${EXECDIR}/logs/${prefix}/*${prefix}.gz*    ELSE
    ...    RUN    mv -f ${EXECDIR}/logs/${prefix}/*.gz* ${vm_logdir}/${prefix}/

Compress Tcpdump file
    [Arguments]    ${fileName}=${EMPTY}
     ${Status}    ${tar}    Run Keyword And Ignore Error    Run    sudo tar -czvf ${fileName}.tgz ${fileName}
     Run Keyword if    "${Status}" == "FAIL"    Run Keywords
     ...    Run    rm -rf ${vm_logdir}/*WTS.pcap    AND
     ...    BuiltIn.Log    No space left on device was seen and pcap were delected    level=WARN
     Log To Console       ${tar}    ${Status}

Start WTS Tcpdump
    [Arguments]    ${pcapFile}
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

WTS Debug Log Level for NSA L1by
    [Arguments]    ${level}=4
    [Documentation]    Debug level set to 4(Error) during data traffic
    wtsrunner.sim_debug_log    level=${level}

WTS Default Log Level for NSA L1by
    [Arguments]    ${level}=0
    [Documentation]    Default debug level set after data traffic
    wtsrunner.sim_debug_log    level=${level}

Set WTS Default Log Level to Debug
    [Arguments]    ${level}=0
    [Documentation]    Debug level set to 0 during L3call
    wtsrunner.sim_debug_log    level=${level}

Set WTS Default Log Level to Error Level
    [Arguments]    ${level}=4
    [Documentation]    Log level set to 4 post L3call
    ${level}=    Set Variable If    '${DEV_TEST}' == 'True'    6    4
    wtsrunner.sim_debug_log    level=${level}

Set WTS Default Log Level to VIP Level
    [Arguments]    ${level}=5
    [Documentation]    Log level set to 5 post L3call
    wtsrunner.sim_debug_log    level=${level}

Set WTS Default Log Level to None
    [Arguments]    ${level}=6
    [Documentation]    Log level set to 6 post L3call
    wtsrunner.sim_debug_log    level=${level}

UE Attach test setup for NSA
    [Arguments]    ${prefix}=NSA_attach
    Run Keyword If    '${4G5G_Combo}'=='0'   Requires Tc    X2 Connection
    ${exclude_pcap}=   Set Variable If   '${CONDITIONAL_LOGGING}' == 'True'   1   0
    Run Keyword Without Failure    Stop sosReport Tcpdump    ${prefix}    ${exclude_pcap}
    Start Attach and Data Traffic TCPDUMP    ${prefix}

Start Attach and Data Traffic TCPDUMP
   [Arguments]    ${prefix}=traffic
   Start sosReport Tcpdump    ${prefix}
   Log                        "Starting gNBMirroring Script..."


Stop Attach and Data Traffic TCPDUMP
   [Arguments]    ${prefix}=attach_traffic
   ${exclude_pcap}=   Check If PCAP Is To Be Excluded
   Run Keyword Without Failure    Stop sosReport Tcpdump    ${prefix}   ${exclude_pcap}

Delete Pcaps from Traffic
   Run Keyword and Ignore Error    Delete PCAPs from gNB and AP

Check If PCAP Is To Be Excluded
    ${exclude_pcap}=   Set Variable If   '${CONDITIONAL_LOGGING}' == 'True' and '${TEST STATUS}' == 'PASS'   1   0
    [Return]   ${exclude_pcap}

Check if Log needs to be Collected
    ${skip_logs}=   Set Variable If   '${CONDITIONAL_LOGGING}' == 'True' and '${SUITE STATUS}' == 'PASS'   1   0
    [Return]   ${skip_logs}

Collect Logs For Run
    [Arguments]    ${file}=${run_script_log_set}
    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    ${skip_logs}=   Check if Log needs to be Collected
    Run Keyword If   '${skip_logs}' == '1'   Delete UDP Syslog
    Run Keyword If    "${skip_logs}" == "1"    Run Keyword And Ignore Error   Run   rm ${vm_logdir}/btslog/*
    Return From Keyword If   '${skip_logs}' == '1'
    Run Keyword If  "${SUITE STATUS}" == "FAIL" or "${EXCLUDE_LOGS}" == "1"    Collect UTE Logs
    ...         ELSE    Collect UTE Configs
    Run Keyword If   '${skip_logs}' == '0'   Collect gnb PM Counter Logs
    Run Keyword If   '${skip_logs}' == '0' and '${ap_sm_hardware}' != 'ASIK'
    ...   Run Keyword And Ignore Error    collect additional logs for LOKI

Delete UDP Syslog
    [Documentation]   Delete UDP Syslog to speed up copy Rota Server.
    Stop btslogger and collect syslogs

Delete PCAPs from gNB and AP
    [Documentation]   Removing pcaps to free up the space to avoid unexpected issues
    ...               in case of long runs like Concurrent Mode execution where consumes lot of memory.
    ...               below boards are picked up based on tcpdump cmds from sosReportStart script.
    [Timeout]    5 minutes
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=middle
    SSH.Connect To    ${AP_bsh_ip_0_1}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    proxy=middle    alias=target
    Run Keyword And Ignore Error    SSH.Execute    command=rm -rf *.pcap*    connection=target
    SSH.Disconnect    target
    SSH.Disconnect    middle
	Run Keyword If    "${Disable_gNB_Log_Collection}" == "False"    Delete PCAPs in gNB

Delete PCAPs in gNB
    SSH.Connect To    ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=middle
    SSH.Connect To    ${gNB_bsh_ip_1_0}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    proxy=middle    alias=target
    Run Keyword And Ignore Error   SSH.Execute    command=rm -rf *.pcap*    connection=middle
    Run Keyword And Ignore Error   SSH.Execute    command=rm -rf *.pcap*    connection=target
    SSH.Disconnect    target
    SSH.Disconnect    middle

collect coldreset techLogSnapshot logs for LOKI
    SSH.Connect To   ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    SSH.Execute    command=cd /ffs/run/logs; tar zcvf coldreset.tgz coldreset
    ...            connection=${AP_ASIK}[Connection]
    SSH.Download File    remote_path=/ffs/run/logs/coldreset.tgz    local_path=${vm_logdir}/coldreset.tgz
    ...            connection=${AP_ASIK}[Connection]
    SSH.Execute    command=cd /ffs/run/logs; tar zcvf techLogSnapshot.tgz techLogSnapshot
    ...            connection=${AP_ASIK}[Connection]
    SSH.Download File    remote_path=/ffs/run/logs/techLogSnapshot.tgz    local_path=${vm_logdir}/techLogSnapshot.tgz
    ...            connection=${AP_ASIK}[Connection]
    SSH.Disconnect           ${AP_ASIK.Connection}

Collect additional logs for LOKI
    collect coldreset techLogSnapshot logs for LOKI
    Collect JounralCtl for Loki gNB

Collect JounralCtl for Loki gNB
    SSH.Connect To    ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=middle
    SSH.Connect To    ${gNB_bsh_ip_1_1}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    proxy=middle    alias=target
    Run Keyword And Ignore Error   SSH.Execute    command=journalctl -ab > /ffs/run/logs/gNB_journalctl.txt    connection=target
    SSH.Download File    remote_path=/ffs/run/logs/gNB_journalctl.txt    local_path=${vm_logdir}/gNB_journalctl.txt
    ...              connection=middle
    SSH.Disconnect    middle
    SSH.Disconnect    target

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
    ${status}   Run Keyword And Return Status    File Should Exist    ${single_run_info_for_ca}
    Run Keyword If    '${status}' == 'True'    Get INFO File CommonAgent    ${single_run_info_for_ca}
    Return From Keyword If    '${status}' == 'True'
    ${status}   Run Keyword And Return Status    File Should Exist    ${single_run_info_path_for_ca}
    Run Keyword If    '${status}' == 'True'    Get INFO File CommonAgent    ${single_run_info_path_for_ca}
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

Get INFO File CommonAgent
    [Arguments]    ${file_path}
    ${file_content}    OperatingSystem.Get File    ${file_path}
    ${file_reservation_content}    OperatingSystem.Get File    /opt/ute/reservation.context.json
    ${label}    Should Match Regexp        ${file_content}    LABEL\\s*:\\s*(\\S+)
    ${variant}    Should Match Regexp        ${file_reservation_content}    "VARIANT_([^"]+)"
    ${topology} =    Set Variable If    '${variant[1]}'== 'None'    ${label[1]}    ${label[1]}_${variant[1]}
    Log    SINGLE_RUNS_TOPOLOGY=${topology}
    Set AP Suite Configuration Variables    ${topology}

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
    Run Keyword If    '${status}' == 'PASS' and '${4G5G_CUS}' != '1'    Set Suite Variable    ${variant_name}    ${value}
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
    ${AP_P1Perf_mmwv}=    Get Variable Value    ${AP_P1Perf_mmwv}    False
    Set Suite Variable    ${AP_P1Perf_mmwv}
    ${sa_ueids_val}=    Get Variable Value    ${sa_ueids}
    ${nsa_ueids_val}=    Get Variable Value    ${nsa_ueids}
    ${lte_ueids_val}=    Get Variable Value    ${lte_ueids}
    ${targetcell_ids_val}=    Get Variable Value    ${targetcell_ids}
    ${gw_ids_val}=    Get Variable Value    ${gw_ids}

    @{sa_ueids}=   Create List
    @{nsa_ueids}=   Create List
    @{targetcell_ids}=   Create List
    @{gw_ids}=   Create List
    @{lte_ueids}=   Create List

    ${sa_ueids}=    Override Test Variables with Default Variables    ${sa_ueids_val}    ${sa_ueids}
    ${nsa_ueids}=    Override Test Variables with Default Variables    ${nsa_ueids_val}    ${nsa_ueids}
    ${lte_ueids}=    Override Test Variables with Default Variables    ${lte_ueids_val}    ${lte_ueids}
    ${targetcell_ids}=    Override Test Variables with Default Variables    ${targetcell_ids_val}    ${targetcell_ids}
    ${gw_ids}=    Override Test Variables with Default Variables    ${gw_ids_val}    ${gw_ids}

    Set Suite Variable    @{sa_ueids}
    Set Suite Variable    @{nsa_ueids}
    Set Suite Variable    @{lte_ueids}
    Set Suite Variable    @{gw_ids}
    Set Suite Variable    @{targetcell_ids}

    ${4G5G_ueid}    Catenate    '${4G5G_CUS}' == '1' and '${variant_name}' == '4G5G_CUS_MultiUE'
    Run Keyword if    ${4G5G_ueid}    Update ueids for Combo MultiUE    ue_count=20
    Append Test Property File For UE_IDs
    ${condition}    Catenate    '${apConfiguration}' in @{Multi_UE_TDD_FDD_Configs}
    Run Keyword If    ${condition}    Create List of UE ids for TDD+FDD
    ...    ELSE IF    '${apConfiguration}' in "@{BFCfg}"
    ...    Create List of UE ids for TDD+FDD BF
    ...    ELSE IF    '${apConfiguration}' in @{RINLINE}    Create List of UE ids for new cfg format
    ...    ELSE IF    '${custom_cell}' == 'True'    Create List of UE ids for Custom Cell
    ...    ELSE IF    '${variant_name}' != '4G5G_CUS_MultiUE'    Create List of UE ids

Create List of UE ids
    ${Cfg}   Catenate    '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO'
    ...    or '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_2S_4CC'
    ...    or '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_CA_HO'
    ...    or '${apConfiguration}' == 'fs_tdd_sansa_eCpri_cmwv_LO_AP_LO_ORAN'
    ...    or '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_GMC'
    FOR    ${value}    IN RANGE    ${component_carrier}
        Append To List    ${targetcell_ids}   ${value+1}
        Append To List    ${gw_ids}   ${value+1}
        Append To List    ${sa_ueids}   ${value+1}
        Run Keyword If    ${Cfg}
        ...    Append To List    ${nsa_ueids}   ${value+${UE_ID_SANSA}}    ELSE    Append To List    ${nsa_ueids}   ${value+11}
        Append To List    ${lte_ueids}   ${value+21}
    END

Create List of UE ids for Custom Cell
    Append To List    ${sa_ueids}    1    21    31    41    51    71    81    91
    Append To List    ${gw_ids}    1    2    3    4    5    6    7    8
    Append To List    ${nsa_ueids}    101    111   121   131    141    151
    Append To List    ${targetcell_ids}    1    2   3   4   10    11
    @{cell_configuration}    Create List
    Append To List    ${cell_configuration}    1    2   3   4   7    8    10    11
    Set Suite Variable    ${cell_configuration}


Create List of UE ids for new cfg format
    Append To List    ${sa_ueids}    1    21    31    41    51    61
    Append To List    ${gw_ids}    1    2    3    4    5    6
    Append To List    ${nsa_ueids}    101    121   231   241    251    255
    Append To List    ${targetcell_ids}    1    2   3   4   5    6
    @{cell_configuration}    Create List
    Append To List    ${cell_configuration}    1    2   3   4   5    6
    Set Suite Variable    ${cell_configuration}


Create List of UE ids for TDD+FDD
    FOR    ${value}    IN RANGE    ${component_carrier}
        Append To List    ${targetcell_ids}   ${value+1}
        Append To List    ${gw_ids}   ${value+1}
    END
    Append To List    ${sa_ueids}     ${sa_ueid_tdd_HTpQT}
    Append To List    ${nsa_ueids}    ${nsa_ueid_tdd_HTpQT}
    Append To List    ${sa_ueids}     ${sa_ueid_tdd_HTpQT_Cell2}     ${sa_ueid_fdd_HTpQT}     ${sa_ueid_fdd_HTpQT_Cell4}
    Append To List    ${nsa_ueids}    ${nsa_ueid_tdd_HTpQT_Cell2}    ${nsa_ueid_fdd_HTpQT}    ${nsa_ueid_fdd_HTpQT_Cell4}

Create List of UE ids for TDD+FDD BF
    FOR    ${value}    IN RANGE    ${component_carrier}
        Run Keyword If    ${value} == 1    Continue For Loop
        Append To List    ${targetcell_ids}   ${value+1}
        Append To List    ${gw_ids}   ${value+1}
    END
    Append To List    ${sa_ueids}     ${sa_ueid_tdd_HTpQT}
    Append To List    ${nsa_ueids}    ${nsa_ueid_tdd_HTpQT}
    Append To List    ${sa_ueids}     ${sa_ueid_fdd_HTpQT}     ${sa_ueid_fdd_HTpQT_Cell4}
    Append To List    ${nsa_ueids}    ${nsa_ueid_fdd_HTpQT}    ${nsa_ueid_fdd_HTpQT_Cell4}

Update ueids for Combo MultiUE
    [Arguments]    ${ue_count}

    ${sa_ueids_val}=    Get Variable Value    ${sa_combo_mue_ueids}
    ${nsa_ueids_val}=    Get Variable Value    ${nsa_combo_mue_ueids}
    ${lte_ueids_val}=    Get Variable Value    ${lte_combo_mue_ueids}

    @{sa_ueids}=   Create List
    @{nsa_ueids}=   Create List
    @{lte_ueids}=   Create List

    FOR    ${value}    IN RANGE    ${ue_count}
       Append To List    ${sa_ueids}   ${value+51}
       Append To List    ${nsa_ueids}   ${value+21}
       Append To List    ${lte_ueids}   ${value+1}
    END

    ${sa_ueids}=    Override Test Variables with Default Variables    ${sa_ueids_val}    ${sa_ueids}
    ${nsa_ueids}=    Override Test Variables with Default Variables    ${nsa_ueids_val}    ${nsa_ueids}
    ${lte_ueids}=    Override Test Variables with Default Variables    ${lte_ueids_val}    ${lte_ueids}

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

Get Hostname Details
    ${result}   ${value}=     Run Keyword And Ignore Error    Get Param Value From File
    ...    ${testline_results_file}    HOSTNAME:\\s+(\\w+.*\\w+)
    ${hostname}=    Replace String Using Regexp    ${value}    -    _
    ${hostname}    ${last}=    Split String From Right    ${hostname}    _    1
    Return From Keyword If    '${result}' == 'PASS'    ${hostname}
    ${value}=    Run Keyword If    '${result}' == 'FAIL'    Run Command Locally And Return Output    hostname
    ${hostname}=    Replace String Using Regexp    ${value}    -    _
    ${hostname}    ${last}=    Split String From Right    ${hostname}    _    1
    [Return]    ${hostname}

Run Command Locally And Return Output
    [Arguments]    ${command}
    ${rc}	${output}=	    Run and Return RC and Output     ${command}
    [Return]    ${output}

Get Init File Details
    [Arguments]    ${main_path}    ${init_file_path}
    ${init_file}=    Catenate      SEPARATOR=/    ${main_path}    ${init_file_path}
    ${result}   ${value}=     Run Keyword And Ignore Error    File Should Exist    ${init_file}
    Return From Keyword If    '${result}' == 'PASS'      ${init_file}
    Return From Keyword If    '${result}' == 'FAIL'      FAIL

Clone Testline Configuration Repo
    [Arguments]    ${hostname}
    Run    git clone "ssh://ca_ute_gerrit@gerrit.ext.net.nokia.com:29418/MN/UTE/testline_configuration"
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
    ${result}   ${value}=     Run Keyword And Ignore Error    Get Matching Lines From Regex
    ...    ${output}    (\\s+addr=.*)
    @{lines}=    Split String  ${value}    \n
    Length Should Be    ${lines}   2   Not able to find Test PC2 Setup Details from '${init_file}'
    ${matched_value}    Should Match Regexp        ${lines[1]}    \\s+addr="(.*)",\\s+username="(.*)",\\s+password="(.*)"
    &{test_pc2}=    Create Dictionary    addr=${matched_value[1]}    username=${matched_value[2]}    password=${matched_value[3]}
    Set Suite Variable     &{test_pc2}
    Set Suite Variable     ${init_file}

Activate TTI Trace Streaming
    wtsrunner.sim_tti_trace    on_mask=0xff    enb=2    cell=1

Trigger TTI traces
    [Arguments]    ${prefix}
    RUN    mkdir -p ${EXECDIR}/logs/TTI_TRACES_${prefix}/
    RUN    chmod 777 ${EXECDIR}/logs/TTI_TRACES_${prefix}/
    RUN    sudo tcpdump -i any -s0 udp port 5678 -C 100 -z gzip -w ${EXECDIR}/logs/TTI_TRACES_${prefix}/${prefix}_AP_tti.pcap.gz > /dev/null 2>&1 &

Deactivate TTI Streaming
    wtsrunner.sim_tti_trace    on_mask=0    enb=2    cell=1

Stop and Copy TTI Traces
    [Arguments]    ${prefix}    ${exclude_pcap}=0
    RUN    sudo pkill tcpdump
    Kill Deleted Process
    Deactivate TTI Streaming
    Run Keyword If     ${exclude_pcap} == 1
    ...    Run Keywords    RUN    sudo rm -rf ${EXECDIR}/logs/TTI_TRACES_${prefix}/${prefix}_AP_tti*
    ...    AND    Return From Keyword
    RUN    sudo tar -czvf TTI_TRACES_${prefix}.tgz -C ${EXECDIR}/logs TTI_TRACES_${prefix}
    RUN    sudo rm -rf ${EXECDIR}/logs/TTI_TRACES_${prefix}
    RUN    mv ${EXECDIR}/TTI_TRACES_${prefix}.tgz ${vm_logdir}/

Start TTI Traces
    [Arguments]    ${prefix}
    Activate TTI Trace Streaming
    Trigger TTI traces    ${prefix}

Collect Sosreport and Snapshot
    Collect UTE SosReport
    Run Keyword And Ignore Error    Collect gNB Snapshot via adminAPI
    Set Suite Variable     ${Collect_Sosreport}    False

Start L2PS TTI Traces
    Set Physical Cell id
    ${webservice}=    Create Dictionary    host=${GNB_BTS.Ip}    user=${GNB_BTS.Username}
    ...    password=${GNB_BTS.Password}    port=${GNB_BTS.Port}
    ${l2_stream_config_l2ps}=  Create Dictionary
    ...  nr_phy_cell_ids=${phy_cellid}
    ...  up_sw=L2Ps
    ...  trace_type=Component
    @{l2_stream_configuration}    Create List    ${l2_stream_config_l2ps}
    Log To Console    Startin TTI TCP Dump for L2PS
    tcpdump.create tcpdump collector
    ...  name=l2ps_tti
    ...  options=-i eth3 udp and dst 10.0.1.1 and dst port 5678
    ...  target_file_name=tti.pcap
    ...  sudo_password=ute
    l2stream3.create sbts l2stream collector
    ...  name=l2stream3
    ...  webservice=${webservice}
    ...  destination_ip_addr=10.0.1.1
    ...  collector=l2ps_tti
    ...  l2_stream_configuration=${l2_stream_configuration}
    Run Keyword And Ignore Error    l2stream3.set_global_alias    alias=l2stream3
    Run Keyword And Ignore Error    core.set_global_alias    alias=core
    core.setup_collectors    names=l2stream3
    core.start_collectors    names=l2stream3

Collect L2PS TTI Traces
    [Arguments]    ${prefix}
    core.stop_collectors    names=l2stream3
    Run Keyword If     '${TEST STATUS}' == 'PASS'    core.teardown_collectors    names=l2stream3
    Run Keyword If     '${TEST STATUS}' != 'PASS'    RUN    mkdir -p ${vm_logdir}/${prefix}
    Run Keyword If     '${TEST STATUS}' != 'PASS'    Start Process    bash    -c    sudo mv /tmp/*tti.pcap ${vm_logdir}/${prefix}

Set Physical Cell id
    IF    '${FR1_TDD_FDD}' == 'True'
        ${phy_cellid}    Set Variable    ${phy_cell_id_fr1}
    ELSE IF    "${apConfiguration}" == "fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO"
        ${phy_cellid}    Set Variable    ${phy_cell_id_mp}
    ELSE IF    "ORAN" in "${apConfiguration}"
        ${phy_cellid}    Set Variable    ${phy_cell_id_oran}
    ELSE
        ${phy_cellid}    Set Variable    ${phy_cell_id}
    END
    Set Suite Variable    ${phy_cellid}

Modify Sosreport script for QT
    Run    sed -i 's/chk lx/ls/g' /opt/wts/latest/sosReport_ASIL/sosReport_ASIL.sh

Check for egen server and trigger egen capture
    ${hostname}=    Run    hostname
    ${hostname}=    Strip String    ${hostname}
    Run Keyword If    '${hostname}' in "@{egen_server_tl}"    Set Suite Variable    ${egen_tl}    True
    Run Keyword If    '${egen_tl}' == 'True'    Start egen capture

Start egen capture
    ${eGen_IP}    Get Environment Variable    eGen_IP
    Set Suite Variable    ${eGen_IP}
    ${eGen_pass}    Get Environment Variable    eGen_pass
    Set Suite Variable    ${eGen_pass}
    Connect to KVM and start egen tcpdump

Connect to KVM and start egen tcpdump
    ssh.Connect to   ${eGen_IP}    ute    ${eGen_pass}    alias=egen_proxy
    ssh.execute    echo "uteadmin" | su -c "cd /home/ute/; ls -ltrh"    connection=egen_proxy    timeout=${120}
    Sleep    2s
    ssh.execute    echo "uteadmin" | su -c "cd /home/ute/; ls -ltrh"    connection=egen_proxy    timeout=${120}
    Sleep    2s
    ssh.send_command
    ...    command=echo "uteadmin" | su -c "cd /home/ute/ && ./egen --cores 1-4 --port ${egen_port_1} --capture /home/ute/APeGen_logs.pcap"
    ...    connection=egen_proxy
    ...    timeout=${10}
    Log To Console    "Starting to capture AP egen from kvm"
    ${cmd_1}=    Catenate    echo "uteadmin" | su -c "cd /home/ute/ && ./egen --cores 1-4
    ${cmd_2}=    Catenate    --port ${egen_port_2} --port ${egen_port_3}
    ${cmd_3}=    Catenate    --capture /home/ute/gNBeGen_logs.pcap --packet-buf-size 3000000"
    ${cmd}=      Catenate    ${cmd_1} ${cmd_2} ${cmd_3}
    ssh.send_command    command=${cmd}
    ...    connection=egen_proxy
    ...    timeout=${10}
    Log To Console    "Starting to capture gNB egen from kvm"

stop egenlogs and collect egen logs
    Log To Console    ***************egen logs collection procedure started ******************
    ${vm_path}    Catenate    ${egen_tl_IP}:/mnt/log-sync/${log_folder}/rotta_logs/
    ssh.send_command    command=echo "uteadmin" | su -c "pkill -9 egen"    connection=egen_proxy
    ssh.execute    echo "uteadmin" | su -c "mkdir -p /home/ute/eGEN"    connection=egen_proxy
    ssh.execute    echo "uteadmin" | su -c "mv *.pcap /home/ute/eGEN"    connection=egen_proxy
    ssh.execute    echo "uteadmin" | su -c "cd /home/ute/eGEN; tar -zcvf egen_logs.tgz *.pcap"    connection=egen_proxy
    ssh.execute    sshpass -p "${egen_tl_Passwd}" scp -r /home/ute/eGEN/*.tgz ute@${vm_path}    connection=egen_proxy
    ssh.execute    echo "uteadmin" | su -c "rm -rf /home/ute/eGEN/*"    connection=egen_proxy
    Log To Console    ***************egen logs collection procedure Done ******************

Update Radparams for IQ_Syslogs
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=middle
    FOR    ${ip}    IN    @{TARGET_BSH_IPs_AP}
        SSH.Connect To    ${ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    proxy=middle    alias=${ip}
        Run Radparam Updates    ${CFG}    ${NR_DOMAIN}    ${ip}
        SSH.Disconnect    ${ip}
    END
    SSH.Disconnect    middle

Run Radparam Updates
    [Arguments]    ${cfg}    ${nr}    ${alias}
    FOR    ${param}    IN    @{RAD_PARAMS}
        ${n}    ${v}=    Split String    ${param}    =
        ${set_cmd}=    Catenate    ${cfg} set --domain ${nr} --name ${n} --value ${v} --change-type persistent --timeout 5 --apply-to-cm
        ${read_cmd}=   Catenate    ${cfg} read --domain ${nr} --name ${n} --timeout 5
        SSH.Execute    ${set_cmd}    connection=${alias}
        SSH.Execute    ${read_cmd}   connection=${alias}
    END

Bundle AP And gNB BIP Logs
    [Arguments]    ${prefix}    ${exclude_pcap}=0
    Run Keyword If   '${exclude_pcap}' == '1'   RUN    rm -rf /home/ute/logs/*
    Return From Keyword If    '${exclude_pcap}' == '1'
    ${process1}=    Start Process    bash    ${CURDIR}/bundle_pcap.sh    /home/ute/logs/AP_BIP/    AP_BIP_${prefix}.tar.zst    shell=True
    ${process2}=    Start Process    bash    ${CURDIR}/bundle_pcap.sh    /home/ute/logs/gNB_BIP/    gNB_BIP_${prefix}.tar.zst   shell=True
    Wait For Process    ${process1}    timeout=300
    Wait For Process    ${process2}    timeout=300
    RUN    mv /home/ute/logs/AP_BIP/* ${vm_logdir}/
    RUN    mv /home/ute/logs/gNB_BIP/* ${vm_logdir}/
