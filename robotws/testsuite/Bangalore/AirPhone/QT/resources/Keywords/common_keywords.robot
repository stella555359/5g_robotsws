*** Settings ***
Documentation     This contains common keywords which are needed to run P1 L3 Calls.
...               :author Shilpa V Swamy

Library    BuiltIn
Library    String
Library    Collections
Library    OperatingSystem
Library    hashlib
Library    taf.wts.runner    WITH NAME    wtsrunner
Library    ../TestCasePreChecks.py
Library     taf.config.wts    WITH NAME    wts_conf
Library    taf.sbts.oam.coam.admin    WITH NAME   admin
Library    taf.hw.pdu    WITH NAME   pdu
Library    ../scripts/Utilities.py
Library    ta_uexgate
Library    taf.ul.sc.perf.testline.TestLineLoader    default_configuration=${True}  autoload=${False}
Library    taf.ul.sc.uesim.cus.executor.Executor     autoconnect=${False}
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME   vDU
Library    ../python/ExternalAPConnect.py    WITH NAME     ExternalAPConnect

Resource    ../../resources/ute/ute_wts_runner.robot
Resource    ../../resources/ute/sosReport.robot
Resource    ../../resources/ute/AP_L1_log_collection.robot
Resource    ../../resources/Variables/common_variables.robot
Resource    ../../../AP_P1Perf/resources/Keywords/p1perf_keywords.robot
Resource    ../../../AP_P1Perf/resources/Variables/p1perf_variables.robot
Resource    ./gnb_keywords.robot
Resource    ./combo_mue_keywords.robot
Resource    ../../resources/Keywords/allowed_alarms.robot

*** Variables ***
@{sysctl_cmds}    sudo sysctl -w net.sctp.sack_timeout=20
...               sudo sysctl -w net.sctp.rto_min=400
...               sudo sysctl -w net.sctp.rto_initial=400
...               sudo sysctl -w net.sctp.rto_max=800
...               sudo sysctl -w net.core.wmem_max=40971520
...               sudo sysctl -w net.core.wmem_default=40971520
...               sudo sysctl -w net.core.rmem_max=40971520
...               sudo sysctl -w net.core.rmem_default=40971520

@{UPF_IP_add_cmds}    sudo ip addr add 10.0.1.5/24 dev eth3
...                   sudo ip addr add 10.0.1.6/24 dev eth3
...                   sudo ip addr add 10.0.1.7/24 dev eth3
...                   sudo ip addr add 10.0.1.8/24 dev eth3
...                   sudo ip addr add 10.0.1.9/24 dev eth3
*** Keywords ***
Common Suite Setup
    [Documentation]    This keyword is used to start the UTE SCTP timeout and WTS related process at the start of suite
    ...                The sos report logs collection will be started
    ...                Modified Date: 29-Apr-2024
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    Run Keyword If    '${temp_install_pip}' == 'true'    Run Keyword And Ignore Error
    ...    Run And Return Rc And Output    pip install ute_admin_infomodel==3.3.0
    Run Keyword and Ignore Error    Create Log folder
    Run Keyword and Ignore Error    Enable BIP Logs
    Get Component Carrier Variables
    Run Keyword and Ignore Error    Kill All Admin Cli Process
    Cleanup tmp and log folders
    Run Keyword and Ignore Error    Kill Syslog Process
    Update GNB IP For 4G5GCombo Setup
    Check and Override Multicell RU Type From File
    Run Keyword Without Failure    Run And Return Rc And Output    rm -f ${vm_logdir}/vm_info.txt
    Run Keyword Without Failure    VM Related Info
    Setup And Connect IM
    Set TCP Flag For Selected Variants
    Check and Disable gNB Logging In startTest_ASIL script
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'    Update SCF File To Enable TCP on Another QCI
    Run Keyword If    '${EXTEND_ORAN}' == 'true'    Load ORAN Config Files
    ${CARR_AGGR}    Get Variable Value    ${CARR_AGGR}    False
    Set Suite Variable    ${CARR_AGGR}
    ${IWF_ENABLED}    Get Variable Value    ${IWF_ENABLE}    False
    Set Suite Variable    ${IWF_ENABLED}
    ${enable_strace}    Get Variable Value    ${STRACE_ENABLE}    False
    Set Suite Variable    ${enable_strace}
    ${EGEN_LOG}    Get Variable Value    ${EGEN_LOG}    False
    Set Suite Variable    ${EGEN_LOG}
    ${COUNTER_VAL}    Get Variable Value    ${QT_COUNTER_VALIDATION}    ${COUNTER_VALIDATION}
    Set Suite Variable    ${COUNTER_VAL}
    ${TRF_UL}    Get Variable Value    ${TRF_UL}    True
    Set Suite Variable    ${TRF_UL}
    ${TRF_DL}    Get Variable Value    ${TRF_DL}    True
    Set Suite Variable    ${TRF_DL}
    ${DEV_TEST}    Get Variable Value    ${DEV_TEST}    False
    Set Suite Variable    ${DEV_TEST}
    Run Keyword If    '${EGEN_LOG}' == 'True'    Check for egen server and trigger egen capture
    Run Keyword If    '${CONDITIONAL_LOGGING}' != 'True'    Wait Coam Site to be Ready
    Run Keyword If    '${apConfiguration}' !='fs_tdd_sa_eCpri_cmwv_E_AP_E_6G'    Remove old gNB and AP BIP Logs
    ${HIGH_THROUGHPUT_FLAG}    Get Variable Value    ${HTp_QT}    False
    Set Suite Variable    ${HIGH_THROUGHPUT_FLAG}
    Run Keyword and Ignore Error    Set High Throughput Flag For Selected Variants
    Run Keyword and Ignore Error    Set Max Throughput Flag For Selected Variants
    Run Keyword and Ignore Error    Assign Variable for QT P0 Configs
    Run Keyword And Ignore Error    Modify Sosreport script for QT
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sa_eCpri_cmwv_E_AP_E_6G'    Set AP External Server Details
    Start UTE WTS
    ${IQ_enable}    Get Variable Value    ${IQ_FLAG}    False
    Run Keyword If    '${IQ_enable}' == 'True'
    ...    Set IQ Flags For Selected Variants
    Run Keyword If    '${IQ_ENABLE_FLAG}' == 'True'    Run Keyword and Ignore Error    Start IQ log Capture
    Run Keyword If    '${variant_name}' != '4G5G_COMBO_MultiUE' and '${variant_name}' != '4G5G_CUS_MultiUE'
    ...    Set WTS Default Log Level to Debug
    Run Keyword If    (('ABIO' in '${gnb_cp_hardware}') or ('ABIN' in '${gnb_cp_hardware}')) and ('${ap_sm_hardware}' == 'ASIK')
    ...    Run Keyword and Ignore Error    Start L1L2biplogs Using Custom ABIO Script
    Run Keyword And Ignore Error    Disable gNB Ports And Update sosScripts
    ${start_sosreport}    Catenate    '${variant_name}' != '4G5G_COMBO_MultiUE' and '${variant_name}' != '4G5G_CUS_MultiUE'
    Run Keyword If    '${apConfiguration}' in "@{AP_P1_CONFIGURATION}"
    ...    Set Suite Variable    ${SAVE_WTS_PCAP_FLAG}    False
    Run Keyword If    ${start_sosreport}    Start sosReport Tcpdump    init
    Run Keyword If    '${TTI_TRACE}' == 'True'    Start TTI Traces    init
    Run Keyword and Ignore Error    Run Keyword If    '${apConfiguration}' in "@{AP_P0_CONFIGURATION}"    Start CPU Utilization Collection
    ${start_time}   Run Keyword And Ignore Error    Get Current DateTime
    Set Suite Variable    ${start_time}
    Run Keyword if    '${apConfiguration}' == 'fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF' and '${HO_flag}' == 'False'
    ...    Run Keywords    Enable BeamForming For SA    AND    Enable BeamForming For NSA
    ${IQ_SYS}    Get Variable Value    ${ENABLE_IQ_SYS_LOG}    False
    Set Suite Variable    ${IQ_SYS}
    Run Keyword if    '${IQ_SYS}' == 'True'    Run Keyword And Ignore Error    Update Radparams for IQ_Syslogs
    ${L2PS_TTI_TRACE}    Get Variable Value    ${ENABLE_L2PS_TTI_TRACE}    True
    Set Suite Variable    ${L2PS_TTI_TRACE}
    ${WTS_UDP_LOG}    Get Variable Value    ${ENABLE_WTS_UDP_LOG}    False
    Set Suite Variable    ${WTS_UDP_LOG}
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${duration}
    Set Suite Variable    ${duration}

Set AP External Server Details
    [Documentation]    This keyword is used to set the Proxy Hop involved in reaching the AP
    ${host}    Evaluate    os.environ.get("AP_LMP_SERVER", "")    modules=os
    Run Keyword If    '${tl.host_ip}' != 'None'   Set Suite Variable    ${JUMP_HOST}    ${tl.host_ip}
    ...   ELSE IF    '${host}' != ''    Set Suite Variable    ${JUMP_HOST}    ${host}
    Log To Console    ${JUMP_HOST}

VM Related Info
    [Documentation]    This keyword is used to get the VM level info where the WTS is run
    ...                Details like CPU core and RAM info are gathered.
    ...                Modified Date: 29-Apr-2024
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    Run And Return Rc And Output    date >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo "\n ---------------------------------------- \n" >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo " cat /etc/os-release" >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    cat /etc/os-release >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo "\n ---------------------------------------- \n" >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo " cat /sys/fs/cgroup/cpuset/cpuset.cpus " >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    cat /sys/fs/cgroup/cpuset/cpuset.cpus >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo "\n ---------------------------------------- \n" >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo " cat /sys/fs/cgroup/cpuset.cpus.effective " >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    cat /sys/fs/cgroup/cpuset.cpus.effective >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo "\n ---------------------------------------- \n" >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo "cat /proc/cpuinfo " >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    cat /proc/cpuinfo >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo "\n ---------------------------------------- \n" >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo "cat /proc/meminfo" >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    cat /proc/meminfo >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo "\n ---------------------------------------- \n" >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo "vmstat" >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    vmstat >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo "\n ---------------------------------------- \n" >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo "free -h" >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    free -h >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo "\n ---------------------------------------- \n" >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo "df -kh" >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    df -kh >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    echo "\n ---------------------------------------- \n" >> ${vm_logdir}/vm_info.txt
    Run And Return Rc And Output    sudo sysctl -a

Enable Suspicious Capture
    Run Keyword If    '${IQ_ENABLE_FLAG}' == 'True'
    ...    Suspicious IQ Capture

Enable Uexgate for CUS
    SSH.Connect To    ${test_pc2}[addr]
    ...               ${test_pc2}[username]
    ...               ${test_pc2}[password]
    ...               alias=VM2
    SSH.Execute    rm -rf ${cus_logs_path}/uex/*    VM2
    SSH.Execute    rm -rf /home/cus/logs/enb_gui_snapshot.zip    VM2
    SSH.Disconnect    VM2
    set host    host=${test_pc2}[addr]
    ${command}    Catenate    hostname -I | awk '{print $1}'
    ${test_pc1}=    Run    ${command}
    ${command}    Catenate    sed -i 's/set_cnode ip=.*/set_cnode ip=${test_pc1}/' ${WTS_DIR}/${SUITE_WTS_CFG}
    ${command_mue}    Catenate
    ...    sed -i "s/\\(set_cnode ip=\\)[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+/\\1${test_pc1}/" ${WTS_DIR}/basic.lua
    Run Keyword If    '${variant_name}' != '4G5G_CUS_MultiUE'    Run    ${command}
    ...    ELSE    Run    ${command_mue}
    ${cmd} =    RUN    ps -ef | grep epmd
    ${pid}    Set Variable    ${cmd.splitlines()[0].split()[8]}
    Run Keyword If    '${pid}'=='${daemon}'
    ...    Log    "Daemon process is running"
    ...    ELSE    Install Daemon Process

Kill All Admin Cli Process
    RUN    ps -ef | pgrep -f "Nemuadmin" | xargs sudo kill -9

Cleanup tmp and log folders
    RUN    rm -rf /tmp/tmp* /tmp/*sos* /tmp/WTSpcap
    RUN    sudo rm -rf /home/ute/logs/*

Install Daemon Process
    ${rc}    Run And Return Rc     sudo apt-get install emssim
    Should Be Equal As Integers     ${rc}    0
    ${cmd} =    RUN    ps -ef | grep epmd
    ${pid}    Set Variable    ${cmd.splitlines()[0].split()[8]}
    Run Keyword If    '${pid}'=='${daemon}'
    ...    Log    "Daemon Process Installed Successfully"

Common Optimized Suite Setup
    [Documentation]    This keyword is used load test suite varaibles dynamically based on TOPOLOGY value
    ...                This keyword need to be removed once individual test suite are removed in repo:
    ...                Modified Date: 17-Aug-2023
    ...                Last Modified by: ramya.2.k@nokia.com
    Run Keyword And Ignore Error    Run    rm ${OUTPUT_DIR}/l3call_tp.txt
    ${WTS_VM_Statistics}    Get Variable Value    ${Collect_WTS_Stats}    False
    Set Suite Variable    ${WTS_VM_Statistics}
    Run Keyword If    '${WTS_VM_Statistics}' == 'True'    Run Keyword and Ignore Error   Start Collecting WTS VM Statistics
    Get AP Suite Configuration Variables
    Run Keyword If    '${4G_5GCombo}' == '1'    Get Secondary Test PC Data
    Run Keyword If    '${4G5G_CUS}' == '1'    Steps Related to CUS
    Run Keyword If    '${Multi_GNB}' == '1'    Assign values related to MultiGNB
    Run Keyword And Ignore Error    Check for log sync mount and set log directory
    Common Suite Setup

Common VDU Suite Setup
    [Documentation]    This keyword is used to start WTS process and check vDU BTS state availability
    ...                for VRAN configuration
    ...                Modified Date: 29-Apr-2024
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    Get AP Suite Configuration Variables
    Get Component Carrier Variables
    Run Keyword Without Failure    Run And Return Rc And Output    rm -f ${EXECDIR}/logs/vm_info.txt
    Run Keyword Without Failure    VM Related Info
    Check and Disable gNB Logging In startTest_ASIL script
    Wait VDU Site to be Ready
    Run Keyword and Ignore Error    Set High Throughput Flag For Selected Variants
    Run Keyword and Ignore Error    Set Max Throughput Flag For Selected Variants
    Run Keyword And Ignore Error    Disable gNB Ports And Update sosScripts
    Run Keyword If    '${apConfiguration}' in "@{AP_P1_CONFIGURATION}"
    ...    Set Suite Variable    ${SAVE_WTS_PCAP_FLAG}    False
    Run Keyword And Ignore Error    Start sosReport Tcpdump    init
    ute_wts_runner.Start UTE WTS
    ${start_time}   Run Keyword And Ignore Error    Get Current DateTime
    Set Suite Variable    ${start_time}

Steps Related to CUS
    Run And Return Rc And Output    sudo ip -s -s neigh flush all    # this step is to perform ARP Flush
    Get Secondary Test PC Data for CUS

Start Collecting WTS VM Statistics
    Start WTS Top Output Capture
    List All WTS Process    Before Start of Test Execution    ${wts_vm_process_suitesetup}

Stop Collecting WTS VM Statistics
    Sleep   2s
    Stop WTS Top Output Capture
    List All WTS Process    After Completion of Test Execution    ${wts_vm_process_suiteteardown}
    Collect WTS VM System Info
    Collect WTS VM Statistics Logs

List All WTS Process
    [Arguments]    ${message}    ${output_file}
    Run    echo "*** Get All process list ${message} ***\n" > ${output_file}
    Run    echo "*** ps -aux command output ***\n" >> ${output_file}
    Run    ps -aux >> ${output_file}
    Run    echo "*** Get All zombie process list if any ***\n" >> ${output_file}
    Run    echo "*** top -b1 -n1 | grep Z command output ***\n" >> ${output_file}
    Run    top -b1 -n1 | grep Z >> ${output_file}
    Run    echo "*** ps -aux | grep 'Z|defunct' ***\n" >> ${output_file}
    Run    ps -aux | grep "Z|defunct" >> ${output_file}

Collect WTS VM System Info
    Run    echo "*** Output of process lists ***\n" > ${wts_vm_system_info}
    Run    echo "\n*** /proc/cpuinfo command output ***\n" >> ${wts_vm_system_info}
    Run    cat /proc/cpuinfo >> ${wts_vm_system_info}
    Run    echo "\n*** free -h command output ***\n" >> ${wts_vm_system_info}
    Run    free -h >> ${wts_vm_system_info}

Start WTS Top Output Capture
    Run    rm -f ${EXECDIR}/${wts_vm_top_results}
    Start Process    top -d 0.1 -b -c -w 512 >> wts_vm_top_results.txt    shell=yes

Stop WTS Top Output Capture
    Run    pkill -f top

Collect WTS VM Statistics Logs
    Run    mkdir WTS_VM_Statistics
    Run    mv ${wts_vm_process_suitesetup} WTS_VM_Statistics
    Run    mv ${wts_vm_process_suiteteardown} WTS_VM_Statistics
    Run    mv ${wts_vm_system_info} WTS_VM_Statistics
    Run    mv ${wts_vm_top_results} WTS_VM_Statistics
    Run    tar -cf WTS_VM_Statistics.tar WTS_VM_Statistics
    Run    mv WTS_VM_Statistics.tar ${EXECDIR}/logs

Remove old gNB and AP BIP Logs
    Wait Until Keyword Succeeds    2min    30sec    SSH.Connect To    ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}
    ...    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    SSH.Execute       rm -rf ${sosReportMainDir}/*.pcap* ${sosReportStbDir}/*.pcap*    ${AP_ASIK}[Connection]
    SSH.Execute       rm -rf ${pcapRunDir}/*.pcap* ${pcapStbDir}/*.pcap*    ${AP_ASIK}[Connection]
    SSH.Execute       rm -rf ${sosReportLogDir}/*.pcap*    ${GNB_ASIK}[Connection]
    SSH.Execute       ls -lh ${sosReportLogDir}    ${GNB_ASIK}[Connection]
    SSH.Disconnect    ${GNB_ASIK.Connection}
    SSH.Disconnect    ${AP_ASIK.Connection}

Common Suite Teardown
    [Documentation]    This keyword is used to stop the Log collection at the end of the Suite
    ...                Teardowns the Edaemon and Egate process at the end of suite
    ...                Modified Date: 04-Apr-2025
    ...                Last Modified by: abhishek.p@nokia.com
    Run Keyword If    '${SUITE STATUS}' == 'FAIL' and '${QT_CONFIG}' == 'false'
    ...    Stop sosReport Tcpdump    init    0
    Run Keyword Without Failure    VM Related Info
    Run Keyword If    '${egen_tl}' == 'True'    stop egenlogs and collect egen logs
    Collect Logs For Run
    Run Keyword and Ignore Error    Set WTS Default Log Level to Error Level
    Run Keyword and Ignore Error    ute_wts_runner.Teardown Edaemon and Egate process
    Run Keyword and Ignore Error    Kill Deleted Process
    ${WTS_VM_Statistics}=    Get Variable Value    ${Collect_WTS_Stats}    False
    Run Keyword If    '${WTS_VM_Statistics}' == 'True'
    ...    Run Keyword and Ignore Error    Stop Collecting WTS VM Statistics
    Run Keyword and Ignore Error    Run Keyword If    '${apConfiguration}' in "@{AP_P0_CONFIGURATION}"    Stop CPU Utilization Collection
    Revert TCP Related Configuration back to Original
    ${gNB_status}    Run Keyword And Return Status    Run Keyword If    'CLOUD_5GC_d' in '${TOPOLOGY}'
    ...              Wait VDU Site to be Ready    ELSE    Wait Coam Site to be Ready
    Run Keyword If    '${gNB_status}' == 'False'    Collect Logs when gNB Status Is not As Expected
    Run Keyword and Ignore Error    Check NIDD and make update
    Run Keyword If    '${4G5G_CUS}' == '1'    Collect CUS Logs and Delete Iptable
    Run Keyword If    '${Multi_GNB}' == '1'    Collect Snapshot on GNB2
    Run Keyword and Ignore Error    Kill All Admin Cli Process
    Run Keyword and Ignore Error    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection

Stopping IQ capture
    Stop IQ log Capture

Collect Logs when gNB Status Is not As Expected
    [Documentation]    This keyword is used to collect the log if gNB is not in expected state.
    ...                Modified Date: 24-May-2022
    ...                Last Modified by: hemanth.kumar_s_n@nokia.com
    Run Keyword And Continue on Failure    Fail    gNB was not in the expected state
    Collect UTE SosReport

Collect CUS Logs and Delete Iptable
    Run    ${cus_iptable}
    SSH.Connect To    ${test_pc2}[addr]
    ...               ${test_pc2}[username]
    ...               ${test_pc2}[password]
    ...               alias=VM2
    ${command}=    Catenate    scp ${CURDIR}/enb_snapshot.robot
    ...            ${test_pc2}[username]@${test_pc2}[addr]:/home/ute/
    Run            ${command}
    ${output}=    Run    ls -la /opt/ute-ca/versions
    ${version}=   Set Variable    ${output.split()[-1]}
    ${command}=    Catenate
    ...    source /opt/ute-ca/versions/${version}/envs/ute-ca-venv/bin/activate &&
    ...    sudo chown -R $USER /opt/ute-ca/versions/${version}/envs/ute-ca-venv/ &&
    ...    pip install robotframework &&
    ...    robot -L TRACE /home/ute/enb_snapshot.robot && deactivate
    ${result}=    SSH.Execute    ${command}    VM2
    Log To Console    enb Snapshot is collected Successfully
    ${command}    Catenate    hostname -I | awk '{print $1}'
    ${test_pc1}=    Run    ${command}
    SSH.Execute    scp -r ${cus_logs_path} ute@${test_pc1}:${EXECDIR}/logs    VM2
    SSH.Execute    scp /home/ute/log.html ute@${test_pc1}:${EXECDIR}/logs/enb_log.html    VM2
    SSH.Disconnect    VM2

X2 Connection Test Setup
    [Documentation]    This keyword is used to start the sosReport for the cell setup at the TestCase Level for X2 Connection
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Stop Tcpdump For Init
    Start sosReport Tcpdump    cell_setup

UE Register Test Setup
    [Documentation]    This keyword is used to start the sosReport for the cell setup at the TestCase Level for UE Register
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Stop Tcpdump For Init
    Start sosReport Tcpdump    cell_setup

UE Deregister Test Teardown for SANSA
    [Documentation]    This keyword is used at the Testcase level to stop attach and data traffic
    ...                and collects the UTE sos report for the UE Deregister for SANSA Variants
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Run Keyword if    '${MAX_THROUGHPUT}' == 'True'    Log To Console    Skipping TCP DUMP for MAX THPT to Collect EM Logs
    ...     ELSE    Stop Attach and Data Traffic TCPDUMP    UE_DEG

UE Register Test Setup for SANSA
    [Arguments]    ${prefix}=attach_traffic
    [Documentation]    This keyword is used at the Testcase level to stop sos report TCPDUMP
    ...                and start attach and data traffic TCPDUMP for UE Register for SANSA variants
    ...                Modified Date: 16-Dec-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Run Keyword If    '${4G5G_Combo}'=='0'   Requires Tc    X2 Connection
    ${exclude_pcap}=   Set Variable If   '${CONDITIONAL_LOGGING}' == 'True'   1   0
    Run Keyword Without Failure    Stop sosReport Tcpdump    init    ${exclude_pcap}
    Run Keyword if    '${MAX_THROUGHPUT}' == 'True'    Log To Console    Skipping TCP DUMP for MAX THPT to Collect EM Logs
    ...       ELSE        Start Attach and Data Traffic TCPDUMP    ${prefix}

UE Register Test Setup for SA
    [Arguments]    ${prefix}=attach_traffic
    [Documentation]    This keyword is used at the Testcase level to stop sos report TCPDUMP
    ...                and start attach and data traffic TCPDUMP for UE Register for SA variant
    ...                Modified Date: 17-July-2023
    ...                Last Modified by: sudha.v@nokia.com
    ${exclude_pcap}=   Set Variable If   '${CONDITIONAL_LOGGING}' == 'True'   1   0
    Run Keyword Without Failure    Stop sosReport Tcpdump    init    ${exclude_pcap}
    Run Keyword if    '${MAX_THROUGHPUT}' == 'True'    Log To Console    Skipping TCP DUMP for MAX THPT to Collect EM Logs
    ...       ELSE        Start Attach and Data Traffic TCPDUMP    ${prefix}

Stop Tcpdump For Init
    [Documentation]    This keyword is used to stop the sosReport Tcpdump for Init at the TestCase Level for NSA Variants
    ...                Modified Date: 16-Dec-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    ${exclude_pcap}=   Set Variable If   '${CONDITIONAL_LOGGING}' == 'True'   1   0
    Run Keyword Without Failure    Stop sosReport Tcpdump    init   ${exclude_pcap}

Configure CUS Executor should be Successful
    taf.ul.sc.perf.testline.TestlineLoader.load_default_configuration  host=${test_pc2}[addr]
    taf.ul.sc.uesim.cus.executor.Executor.connect
    taf.ul.sc.uesim.cus.executor.Executor.update_local_configuration
    taf.ul.sc.uesim.cus.executor.Executor.update_remote_configuration
    Wait Until Keyword Succeeds    10min    30sec    Coam Site Should be Ready
    ${data}=  taf.ul.sc.uesim.cus.executor.Executor.get_endc_wts
    Run Keyword If    '${variant_name}' != '4G5G_CUS_MultiUE'    Verify GTPU Port    ${data}
    ...    ELSE    Verify GTPU Port For MultiUE    ${data}
    Stop Edaemon Egate
    Power Reset From PDU
    Wait Until Keyword Succeeds    15min    30sec    Coam Site Should be Ready
    Start WTS For CUS
    NG Link Should be UP
    Address Distribution should be Successful
    UE SIB Decoding should be Successful

Verify GTPU Port
    [Arguments]    ${data}
    ${GTPU}=    Set Variable    ${data[0]['uplane'].split(':')[-1]}
    Run Keyword If    '${GTPU}'=='${GTPU_port}'
    ...    Log    "Egate and CUS Executor are in Sync"
    ...    ELSE    Log    "Egate and CUS Executor are not in Sync"

Verify GTPU Port For MultiUE
    [Arguments]    ${data}
    @{gnb_ids}    Create List
    FOR    ${item}    IN    @{data}
        ${GTPU}=    Set Variable    ${item['uplane'].split(':')[-1]}
        Run Keyword If    '${GTPU}'=='${GTPU_port}'    Append To List    ${gnb_ids}    ${item['gnb_id']}
    END
    ${result}=    Run Keyword and Return Status    Lists Should Be Equal    ${gnb_values}    ${gnb_ids}
    Run Keyword If    '${result}'=='True'
    ...    Log    "Egate and CUS Executor are in Sync"
    ...    ELSE    Log    "Egate and CUS Executor are not in Sync"

Stop Tcpdump For CellSetup
    [Documentation]    This keyword is used to stop the sosReport Tcpdump for cell setup at the TestCase Level for NSA Variants
    ...                Modified Date: 16-Dec-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    ${exclude_pcap}=   Check If PCAP Is To Be Excluded
    Run Keyword Without Failure    Stop sosReport Tcpdump    cell_setup   ${exclude_pcap}

Stop Tcpdump for Attach and Dta Traffic
   [Documentation]    This keyword is used to stop the sosReport Tcpdump for Traffic at the TestCase Level for NSA Variants
    ...                Modified Date: 16-Dec-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
   ${exclude_pcap}=   Check If PCAP Is To Be Excluded
   Run Keyword Without Failure    Stop sosReport Tcpdump    attach_traffic   ${exclude_pcap}
   Run Keyword and Ignore Error    Delete PCAPs from gNB and AP

UE Re-register Test Setup
    [Documentation]    This keyword is used at the start of UE Re-Register where the sosReport is stopped for the cell setup
    ...                And starts the TCPDUMP for Attach and Data Traffic
    ...                Modified Date: 16-Dec-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Requires Tc   UE Deregister
    Run Keyword Without Failure    Stop sosReport Tcpdump    cell_setup
    Start Attach and Data Traffic TCPDUMP

NG Link Should be UP
    [Documentation]    This keyword checks if the NG link is up for the SA variant in egate_console.log file
    ...                Modified Date: 10-Jun-2021
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}
    ...    NG link check using AMF Link Status    ${AMF_ID}    ${TARGET_GNB}
    Run Keyword If    ('${4G5G_Combo}'=='1' or '${4G5G_CUS}'=='1')
    ...    S1 link check for eNB

NG link lock and unlock
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    CoamAdmin.lock_ng_link    dist_name=MRBTS-1/NRBTS-1/SERVEDAMF-1    timeout=300	 connection=default
	Check Alarm Raised
	Sleep    20sec
    ${ng_link_status}=    CoamAdmin.unlock_ng_link    dist_name=MRBTS-1/NRBTS-1/SERVEDAMF-1    timeout=300    connection=default
	Check Alarm Cleared
    Should Be Equal As Strings    ${ng_link_status}
    ...    completed    ignore_case=${TRUE}
    CoamAdmin.Teardown

Check Alarm Raised
    Wait Until Keyword Succeeds       2min    20s      7107 alarm should be exist

Check Alarm Cleared
    Wait Until Keyword Succeeds       2min    20s      7107 alarm should be not exist

7107 alarm should be exist
    set test variable    ${7107alarm_flag}    ${false}
    @{alarm_lsit}    coamadmin.get_active_alarms    connection=default
	FOR    ${alarm}    IN    @{alarm_lsit}
	      Run keyword if   "${alarm["alarmId"]}"=="${Alarm_id}" and "${alarm["faultId"]}"=="${Fault_ID}"
	      ...    set test variable    ${7107alarm_flag}    ${true}
	      Run keyword if   "${alarm["alarmId"]}"=="${Alarm_id}" and "${alarm["faultId"]}"=="${Fault_ID}"
	      ...     Exit For Loop
	END
	Should be True    ${7107alarm_flag}
	Should be True    "${alarm["alarmDetail"]}"=="${Alarm_detail}"

7107 alarm should be not exist
    set test variable    ${7107alarm_flag}    ${true}
    @{alarm_lsit}    coamadmin.get_active_alarms    connection=default
	FOR    ${alarm}    IN    @{alarm_lsit}
	      Run keyword if   "${alarm["alarmId"]}"=="${Alarm_id}" and "${alarm["faultId"]}"=="${Fault_ID}"
	      ...    set test variable    ${7107alarm_flag}    ${false}
	      Run keyword if   "${alarm["alarmId"]}"=="${Alarm_id}" and "${alarm["faultId"]}"=="${Fault_ID}"
	      ...    Exit For Loop
	END
	Should be True    ${7107alarm_flag}

Address Distribution should be Successful
    [Documentation]    This keyword checks if the Address Distribution is completed for the SA variant in egate_console.log file
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Check Pattern in APL3 Log    ${Address_distribution_pattern}

Address Distribution should be Successful For 6G
    [Documentation]    This keyword checks if the Address Distribution is completed for the SA variant in egate_console.log file
    ...                Modified Date: 14-Nov-2023
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    Check Pattern in APEgate Console Log    Address Distribution is complete

AP Cell Setup should be Successful
    [Documentation]    This keyword checks if the Cell Setup completed in egate_console.log file
    ...                Modified as part of FCA_5GA-99181
    ...                Modified Date: 13-05-2025
    ...                Last Modified by: abhishek.p@nokia.com
    Run Keyword And Return If    '${custom_cell}' == 'True'    AP Cell Setup should be Successful for Custom Cell
    Run Keyword If    '${apConfiguration}' in "@{QT_stability_cfg}"    wtsrunner.sim_param_set    disable_events_on_telnet_session=on
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_GMC'    Set Suite Variable    ${component_carrier}    4
    FOR   ${cell_id}   IN RANGE    ${min_cell_id}    ${component_carrier}
        ${validation_string}=    Set Variable    ${EMPTY}
        Run Keyword If    '${apConfiguration}' in "@{BFCfg}" and ${cell_id} == 1
        ...    Continue For Loop
        ${validation_string}=    Catenate    ${Cell_setup_complete_pattern}     for \\[CELL_ID:${cell_id + 1}\\]
        Check Pattern in APL3 Log    ${validation_string}
    END
    Run Keyword If    '${CELL_BLOCK_UNBLOCK}' == 'True'    Perform Cell Block Unblock For All Cells
    Run Keyword If    '${RU_LOCK_UNLOCK}' == 'True' and '${apConfiguration}' in "@{AP_P0_CONFIGURATION}"
    ...    Perform RU lock and unlock
    Run Keyword If    '${4G5G_Combo}'=='1'
    ...    Check Pattern in Egate Console Log    cell ${enb_cell_id}: ${UE_SIB_decoding_pattern_eNB}
    Run Keyword If    '${4G5G_CUS}'=='1'
    ...    Check Pattern in Egate Console Log    cell ${cell_id + 1}: ${UE_SIB_decoding_pattern_eNB}
    sleep              5s

AP Cell Setup should be Successful for Custom Cell
    [Documentation]    This keyword checks if the Cell Setup completed in egate_console.log file for a custom cell config
    ...                Modified Date: 11-02-2025
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    FOR   ${cell_id}   IN    @{cell_configuration}
        ${validation_string}=    Set Variable    ${EMPTY}
        ${validation_string}=    Catenate    ${Cell_setup_complete_pattern}     for \\[CELL_ID:${cell_id}\\]
        Check Pattern in APL3 Log    ${validation_string}
    END

Perform Cell Block Unblock For All Cells Check
    [Documentation]    This keyword is used to block and unblock the cells and check if the cells have comeup along with cell setup
    Log to console    Performing Cell Block Unblock for all cells!!!
    wtsrunner.script    file=${run_script_log_set}   entry=sim_log_set_flush()
    wtsrunner.sim_param_set    disable_events_on_telnet_session=on
    FOR    ${i}    IN RANGE    ${CELL_BLOCK_UNBLOCK_ITERATION}
        Perform Cell Block Unblock
        sleep              5s
    END
    Second Validate Cell Setup Pattern After Cell Block Unblock
    wtsrunner.script    file=${run_script_log_set}   entry=sim_log_set_flush()

Second Validate Cell Setup Pattern After Cell Block Unblock
    [Documentation]    This keyword checks the no of times cell setup complete msg appears in egate console for each cell
    ...                Modified Date: 21-May-2025
    ...                Last Modified by:chaithra.r_l@nokia.com
    FOR   ${cell_id}   IN RANGE    ${min_cell_id}    ${component_carrier}
        ${validation_string}=    Set Variable    ${EMPTY}
        Run Keyword If    '${apConfiguration}' in "@{BFCfg}" and ${cell_id} == 1
        ...    Continue For Loop
        ${validation_string}=    Catenate    ${Cell_setup_complete_pattern}     for \\[CELL_ID:${cell_id + 1}\\]
		wtsrunner.script    file=${run_script_log_set}   entry=sim_log_set_flush()
		sleep    20s
        ${count}=    Get Count of String Occurrences    ${validation_string}
        ${expected_count}=    Evaluate    ${CELL_BLOCK_UNBLOCK_ITERATION} + ${CELL_BLOCK_UNBLOCK_ITERATION} + 1
        Should Be Equal As Integers    ${count}    ${expected_count}
    END

Perform Cell Block Unblock For All Cells
    [Documentation]    This keyword is used to block and unblock the cells and check if the cells have comeup along with cell setup
    Log to console    Performing Cell Block Unblock for all cells!!!
    FOR    ${i}    IN RANGE    ${CELL_BLOCK_UNBLOCK_ITERATION}
        Perform Cell Block Unblock
        sleep    5s
    END
    Validate Cell Setup Pattern After Cell Block Unblock
    wtsrunner.script    file=${run_script_log_set}   entry=sim_log_set_flush()

Perform Cell Block Unblock
    [Documentation]    This keyword is used to block and unblock the cells
    Wait Until Keyword Succeeds    5min    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    CoamAdmin.block_all_cells    rat=NR    detailed_output=True
    sleep    2s
    Check State Of All Cells    Blocked
    CoamAdmin.unblock_all_cells    rat=NR    detailed_output=True
    sleep    2s
    Check State Of All Cells    Unblocked
    CoamAdmin.Teardown

Validate Cell Setup Pattern After Cell Block Unblock
    [Documentation]    This keyword checks the no of times cell setup complete msg appears in egate console for each cell
    ...                Modified Date: 08-May-2024
    ...                Last Modified by:m.sangeetha@nokia.com
    FOR   ${cell_id}   IN RANGE    ${min_cell_id}    ${component_carrier}
        ${validation_string}=    Set Variable    ${EMPTY}
        Run Keyword If    '${apConfiguration}' in "@{BFCfg}" and ${cell_id} == 1
        ...    Continue For Loop
        ${validation_string}=    Catenate    ${Cell_setup_complete_pattern}     for \\[CELL_ID:${cell_id + 1}\\]
        wtsrunner.script    file=${run_script_log_set}   entry=sim_log_set_flush()
        sleep    5s    # Timer is added to avoid the delay in cell validation during cell BU scenario
        ${count}=    Get Count of String Occurrences    ${validation_string}
        ${expected_count}=    Evaluate    ${CELL_BLOCK_UNBLOCK_ITERATION} + 1
        Should Be Equal As Integers    ${count}    ${expected_count}
    END

Get Count of String Occurrences
    [Arguments]    ${validation_string}
    ${count}=    RUN    grep -o "${validation_string}" ${WTS_DIR}/egate_console.log | wc -l
    [Return]    ${count}

Check State Of All Cells
    [Documentation]    This keyword checks whether cells are blocked or unblocked from GUI
    ...                Modified Date: 19-Mar-2024
    ...                Last Modified by: anil.1.pachauri@nokia.com
    [Arguments]    ${cell_status}
    ${cell_info}=    CoamAdmin.get_cells_info
    ${list_len}=    Get Length    ${cell_info}
    FOR    ${cell_id}   IN RANGE    ${list_len}
        Should Be Equal As Strings    ${cell_info[${cell_id}]['status']['blockingState']}
        ...    ${cell_status}    ignore_case=${TRUE}
    END

AP Cell Setup should be Successful For 6G
    [Documentation]    This keyword checks if the Cell Setup completed in egate_console.log file
    ...                Modified Date: 14-Nov-2023
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    FOR   ${cell_id}   IN RANGE    ${min_cell_id}    ${total_cells}
        ${validation_string}=    Set Variable    ${EMPTY}
        ${validation_string}=    Catenate    ${Cell_setup_complete_pattern}     for \\[CELL_ID:${cell_id + 1}\\]
        Check Pattern in APL3 Log in External AP server    ${validation_string}
    END

UE SIB Decoding should be Successful
    [Documentation]    This keyword checks if the UE sib decoding is completed for the SA variant in egate_console.log file
    ...                Modified Date: 17-Aug-2023
    ...                Last Modified by: ramya.2.k@nokia.com
    Run Keyword And Return If    '${custom_cell}' == 'True'    UE SIB Decoding should be Successful for Custom Cell Config
    FOR   ${cell_id}   IN RANGE    ${min_cell_id}    ${component_carrier}
        ${validation_string}=    Set Variable    ${EMPTY}
        Run Keyword If    '${apConfiguration}' in "@{BFCfg}" and ${cell_id} == 1
        ...    Continue For Loop
        ${validation_string}=    Catenate    eNB ${eNB_target} cell ${cell_id + 1}:     ${UE_SIB_decoding_pattern}
        ${status}    Run Keyword And Return Status    Check Pattern in Egate Console Log    ${validation_string}
        Run Keyword If    '${4G5G_Combo}'=='1'
        ...    UE SIB Decoding should be Successful for TRS    ${cell_id}
        Run Keyword If    '${4G5G_CUS}'=='1'
        ...    UE SIB Decoding should be Successful for CUS    ${cell_id}
        Run keyword if    '${status}' == 'False'    Fail    msg=UE SIB decoding failed
    END

UE SIB Decoding should be Successful for Custom Cell Config
    [Documentation]    This keyword checks SIB Decoding for custom cell configuration
    ...                Modified Date: 11-Feb-2025
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    @{status_array}    Create List
    FOR   ${cell_id}   IN     @{cell_configuration}
        ${validation_string}=    Catenate    eNB ${eNB_target} cell ${cell_id}:     ${UE_SIB_decoding_pattern}
        ${status}    Run Keyword And Return Status    Check Pattern in Egate Console Log    ${validation_string}
        Append To List    ${status_array}    ${status}
    END
    Run Keyword If    'False' in ${status_array}    Fail    msg=UE SIB decoding failed

UE SIB Decoding should be Successful for TRS
    [Arguments]    ${cell_id}
    [Documentation]    This keyword checks if the UE sib decoding is completed for the SA variant in egate_console.log file
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: anil.1.pachauri@nokia.com
    ${validation_string}=    Set Variable    eNB 2 cell ${cell_id + 1}: ${UE_SIB_decoding_pattern}
    ${status}    Run Keyword And Return Status    wtsrunner.read_wtsemu_output_until_re
    ...          expected=${validation_string}     timeout=300
    Run Keyword If    '${status}' == 'False'
    ...    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}
    ...    Check SIB Decoding for TRS    ${validation_string}

UE SIB Decoding should be Successful for CUS
    [Arguments]    ${cell_id}
    [Documentation]    This keyword checks if the UE sib decoding is completed for the SA variant in egate_console.log file
    ...                Modified Date: 20-March-2023
    ...                Last Modified by: kokila.b@nokia.com
    ${validation_string}=    Set Variable    eNB 2 cell ${cell_id + 1}: ${UE_SIB_decoding_pattern}
    ${status}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}
    ...    Check SIB Decoding for TRS    ${validation_string}
    Run Keyword If    '${status}' == 'False'
    ...    wtsrunner.read_wtsemu_output_until_re    expected=${validation_string}     timeout=300

Check SIB Decoding for TRS
    [Arguments]    ${pattern}    ${file}=${run_script_log_set}
    [Documentation]    This keyword checks if the ${pattern} is present in the egate_console.log file for TRS
    ...                Modified Date: 16-Dec-2021
    ...                Last Modified by: anil.1.pachauri@nokia.com
    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    Search pattern should Exists In EGATE    ${WTS_DIR}/egate_console.log     ${pattern}

Check Pattern in Egate Console Log
    [Arguments]    ${pattern}    ${file}=${run_script_log_set}
    [Documentation]    This keyword checks if the ${pattern} is present in the egate_console.log file
    ...                Modified Date: 14-Nov-2023
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    Log    ${file}!!!
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Verify Pattern in Egate Log    ${pattern}

Verify Pattern in Egate Log
    [Arguments]    ${pattern}    ${file}=${run_script_log_set}
    [Documentation]    This keyword checks if the ${pattern} is present in the egate_console.log file
    ...                Modified Date: 14-Nov-2023
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    Run Keyword If    '${variant_name}' != '4G5G_COMBO_MultiUE'
    ...    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    Search pattern should Exists In EGATE
    ...                            ${WTS_DIR}/egate_console.log     ${pattern}

Reset Site and Check BTS Status
    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Log To Console     Performing site reset
    CoamAdmin.reset_site    timeout=300    connection=default
    Wait Until Keyword Succeeds    5min    30sec    Verify BTS is onAir
    [Teardown]    CoamAdmin.Teardown

Reset System Module Cards and check status
    FOR    ${i}    IN RANGE    ${BBMOD_RESET_ITERATION}
        BBMOD Reset And Check BTS Status    ${i}
        sleep              5s
    END

BBMOD Reset And Check BTS Status
    [Arguments]    ${Iteration}
    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    ${Num}=    Evaluate    ${Iteration} + 1
    Log To Console     Performing Card reset Iterartion ${Num}
    CoamAdmin.reset_unit    dist_name=${ABIO_CARD}    reset_type=Warm    detailed_output=True    timeout=300	 connection=default
    Wait Until Keyword Succeeds    10min    30sec    Verify BTS is onAir
    Log To Console    Sleep for 180 seconds
    Sleep    180s
    [Teardown]    CoamAdmin.Teardown

Check Pattern in APL3 Log
    [Arguments]    ${pattern}
    [Documentation]    This keyword checks if the ${pattern} is present in AP L3 log.
    ...                Modified Date: 17-Aug-2023
    ...                Last Modified by: ramya.2.k@nokia.com
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search grep pattern should Exists
    ...    /tmp/${ap_log}    ${pattern}

Check Pattern in APL3 Log in External AP server
    [Arguments]    ${pattern}
    [Documentation]    This keyword checks if the ${pattern} is present in AP L3 log.
    ...                Modified Date: 17-Aug-2023
    ...                Last Modified by: ramya.2.k@nokia.com
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search grep pattern should Exists in external AP server
    ...    /tmp/${ap_log}    ${pattern}

Perform RU lock and unlock
    Wait Until Keyword Succeeds    5min    30sec    Coam.Connect To    bts_host=${GNB_ASIK.Ip}
    Get RMOD Count
    FOR    ${i}    IN RANGE    ${RU_LOCK_UNLOCK_ITERATION}
        FOR    ${item}    IN RANGE   ${rmod_count}
		    ${rmod_id}=    Evaluate    ${item} + 1
            Run Keyword If    '${apConfiguration}' in "@{BFCfg}" and ${rmod_id} == 2
            ...    Continue For Loop
            coam.lock    dist_name=MRBTS-1/EQM-1/APEQM-1/RMOD-${rmod_id}   timeout=300	 connection=default
            sleep    10s
			wtsrunner.script    file=${run_script_log_set}   entry=sim_log_set_flush()
            coam.unlock    dist_name=MRBTS-1/EQM-1/APEQM-1/RMOD-${rmod_id}   timeout=300	 connection=default
			wtsrunner.script    file=${run_script_log_set}   entry=sim_log_set_flush()
			sleep    10s
        END
        Wait Until Keyword Succeeds    10min    30sec    Verify BTS is onAir
    END
    [Teardown]    coam.teardown    connection=default

Get RMOD Count
    Wait Until Keyword Succeeds    5min    30sec    Coam.Connect To    bts_host=${GNB_ASIK.Ip}
    ${rmods}=    coam.get_rmod_fan_info
    ${rmod_count}=  Get Length    ${rmods}
    ${rmod_count}=    Run Keyword If    '${apConfiguration}' in "@{BFCfg}"
    ...    Set Variable    ${BF_RU_RESET}    ELSE    Set Variable    ${rmod_count}
    Set Suite Variable    ${rmod_count}

Verify BTS is onAir
    ${bts_state}    CoamAdmin.Get Mrbts State
    Should Contain Any    ${bts_state}    onAir    ignore_case=${TRUE}

UE Register should be Successful
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.ue_register   id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}    nwslice=${nwslice_ID}    gw=${gw_ID}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    Log                first_ue_register_is_ok

UE Register should be Successful for SA
    [Arguments]    ${UE_ID}=${UE_ID}    ${gw_ID}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SANSA variant
    ...                Modified Date: 23-May-2024
    ...                Last Modified by: abhishek.p@nokia.com
    wtsrunner.ue_register   id=${UE_ID}
    wtsrunner.script    file=${run_script_log_set}   entry=set_log_flush()
    Run Keyword If    '${apConfiguration}' in "@{QT_stability_cfg}"    wtsrunner.sim_param_set    disable_events_on_telnet_session=off
    wtsrunner.read_wtsemu_output_until_re    expected=${Register_complete_pattern}    timeout=${Timeout_SA}
    Check Pattern in Egate Console Log     ${Register_complete_pattern}    ${Timeout_SA}
    Check Pattern in Egate Console Log     ${Initial_UE_success_message}    ${Timeout_SA}
    wtsrunner.set_pdu_param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    wtsrunner.read_wtsemu_output_until_re    expected=${Initial_context_setup_pattern}    timeout=${Timeout_SA}
    Check Pattern in Egate Console Log    ${Initial_context_setup_pattern}    ${Timeout_SA}
    Log To Console    UE ${UE_ID} Registered Successfully

UE Register should be Successful for SANSA
    [Documentation]    This keyword checks the message for the completion of UE Registration in the output file for the SANSA variant
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Run Keyword If    '${apConfiguration}' in "@{QT_stability_cfg}"    wtsrunner.sim_param_set    disable_events_on_telnet_session=on
    FOR   ${ueid}    ${gwid}   IN ZIP   ${sa_ueids}    ${gw_ids}
        UE Register should be Successful for SA    ${ueid}    ${gwid}
    END

UE Register should be Successful for Multi BeamForming SANSA
    [Documentation]    This keyword checks the message for the completion of UE Registration in the output file for the
    ...    SANSA variant with multi Beam enabled
    ...                Modified Date: 21-May-2025
    ...                Last Modified by: chaithra.r_l@nokia.com
    FOR   ${ueid}    ${gwid}    IN ZIP   ${sa_ueids_multi_BF}    ${gw_ids_multi_BF}
        UE Register should be Successful for SA    ${ueid}    ${gwid}
    END

LTE Attach should be Successful for Multi BeamForming
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ...                Modified Date: 21-May-2025
    ...                Last Modified by: chaithra.r_l@nokia.com
    FOR   ${ueid}   IN   @{nsa_ueids_multi_BF}
        LTE Attach should be Successful for NSA    ${ueid}
    END

UE Attach should be Successful for Multi BeamForming
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ...                Modified Date: 21-May-2025
    ...                Last Modified by: chaithra.r_l@nokia.com
    FOR   ${ueid}    ${targetcell}   IN ZIP   ${nsa_ueids_multi_BF}    ${targetcell_ids_multi_BF}
        UE Attach should be Successful for NSA    ${ueid}    ${targetcell}
    END

UE Reregister should be Successful for SANSA
    [Documentation]    This keyword checks the message for the completion of UE Reregistration in the output file for the SANSA variant
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Sleep    ${UE_Reregister_sleep}
    FOR   ${ueid}    ${gwid}   IN ZIP   ${sa_ueids}    ${gw_ids}
        UE Register should be Successful for SA    ${ueid}    ${gwid}
    END

UE Reregister should be Successful
    [Documentation]    This keyword checks the message for the completion of UE re-registration in the output file for the SA variant
    ...                Modified Date: 01-June-2021
    ...                Last Modified by: praveen.t_k @nokia.com
    wtsrunner.ue_register   id=${UE_ID}
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${Register_complete_pattern}    ${Timeout_SA}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param   ue=${UE_ID}   pdu=${Pdu_session_ID}   trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}   ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    Log                second_ue_register_is_ok

Initial Success Message for UE Register and Reregister
    [Arguments]    ${output}
    [Documentation]    This keyword checks the Initial status message for the completion of UE Registration
    ...                And UE Re-registration in the output file for the SA variant
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Should Contain    ${output}    ${Initial_UE_message_pattern}    ignore_case=True
    Print Matching Lines from Output File    ${output}    ${Initial_UE_success_pattern}

UE Deregister should be Successful for SA
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.ue_deregister    id=${UE_ID}    ue_deregister_type=switch_off
    Read WTS Output For Pattern And Print matching Lines    ${UE_deregister_pattern}    ${Timeout_SA}

UE Deregister should be Successful
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Run Keyword And Ignore Error    Set WTS Default Log Level to Debug
    FOR   ${ueid}   IN   @{sa_ueids}
        UE Deregister should be Successful for SA    ${ueid}
    END

Traffic for SA should be Successful
    [Documentation]    This keyword starts and Validates the Traffic for the SA variant
    ...                Modified Date: 04-Jul-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${duration}
    Run Keyword If    '${MAX_THROUGHPUT}' == 'True'    HighThroughput SUE QT Traffic SA    ${duration}
    ...    ELSE    UDP and TCP Traffic for SA    ${duration}

HighThroughput SUE QT Traffic SA
    [Arguments]    ${duration}
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Start CPU Utilization Collection
    Generate SA Traffic for High Throughput
    Sleep    ${duration}
    Log To Console    Running Traffic for ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    Run Keyword If    '${DEV_TEST}' == 'True'    Log Bearer stats without verification SA Sequential
    ...              ELSE    Log Bearer stats without verification
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s
    ...    Verify UE_stats Throughput Average Rate for SA
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf
    Run Keyword If    '${HO_flag}' == 'True'    UE Register SA HO TDD FDD
    Stop SA Max throughput traffic
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run keyword if    '${status}' == 'False'    Fail    msg=SA Traffic Failed

Traffic for SA should be Successful for 6G
    [Documentation]    This keyword starts and Validates the Traffic for the SA variant
    ...                Modified Date: 04-Jul-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${duration}
    Run Keyword If    '${MAX_THROUGHPUT}' == 'True'    HighThroughput SUE QT Traffic SA for 6G    ${duration}
    ...    ELSE    UDP and TCP Traffic for SA    ${duration}

HighThroughput SUE QT Traffic SA for 6G
    [Arguments]    ${duration}
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Start CPU Utilization Collection
    Generate SA Traffic for High Throughput for 6G
    Sleep    ${duration}
    Log To Console    Running Traffic for ${duration}
    Log Bearer stats without verification for 6G
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s
    ...    Verify Average Date Rate for SA For UEC Integrated AP Using UE Stats    ${UE_ID}    ${traffic_dl_rate}    ${traffic_ul_rate}
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf
    Run Keyword If    '${HO_flag}' == 'True'    UE Register SA HO TDD FDD
    Stop SA Max throughput traffic for 6G
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run keyword if    '${status}' == 'False'    Fail    msg=SA Traffic Failed

Traffic for SA should be Successful for DL UL sequential flow
    [Documentation]    This keyword starts and Validates the Traffic for the SA variant
    ...                Modified Date: 04-Jul-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Run Keyword And Ignore Error    Set WTS Default Log Level to None
    Run Keyword If    '${MAX_THROUGHPUT}' == 'True'    HighThroughput SUE QT Traffic SA SEQ

HighThroughput SUE QT Traffic SA SEQ
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Start CPU Utilization Collection
    Generate SA Traffic for High Throughput Seq Flow

UE Register SA HO TDD FDD
    UE Register SA FW HO TDD FDD
    UE Register SA RV HO TDD FDD

UE Register SA FW HO TDD FDD
    Intra gNB-Inter Freq SA HO TDD_FDD    ${sa_ueids_HO[0]}    ${meas_id_A2_TDD_FDD_HO[0]}
    ...    ${meas_id_A3_TDD_FDD_HO[0]}    ${phy_id_TDD_FDD_HO[0]}
    Intra gNB-Intra Freq SA HO FDD    ${sa_ueids_HO[1]}    ${meas_id_A3_FDD_HO[0]}
    ...    ${phy_id_FDD_HO[0]}

UE Register SA RV HO TDD FDD
    Intra gNB-Inter Freq SA HO TDD_FDD    ${sa_ueids_HO[0]}    ${meas_id_A2_TDD_FDD_HO[1]}
    ...    ${meas_id_A3_TDD_FDD_HO[1]}    ${phy_id_TDD_FDD_HO[1]}
    Intra gNB-Intra Freq SA HO FDD    ${sa_ueids_HO[1]}    ${meas_id_A3_FDD_HO[0]}
    ...    ${phy_id_FDD_HO[1]}

Intra gNB-Inter Freq SA HO TDD_FDD
    [Arguments]    ${ue_id}=${sa_ueid}    ${meas_id_A2}=${meas_id_A2_TDD_FDD}
    ...    ${meas_id_A3}=${meas_id_A3_TDD_FDD}    ${phy_id}=${phy_id_TDD_FDD}
    wtsrunner.ue_disp    id=${ue_id}
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    sleep    2s
    wtsrunner.ue_meas_cfg_disp    id=${ue_id}    meas_obj_type=nr
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    sleep    2s
    wtsrunner.ue_measurement_send_nr    event=${event_A2}    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    ...    meas_id=${meas_id_A2}    id=${ue_id}
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    sleep    2s
    wtsrunner.ue_measurement_send_nr    event=${event_A3}    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    ...    phycell_id=${phy_id}    nrsrp_nr=${nrsrp_nr}    nrsrq_nr=${nrsrq_nr}    meas_id=${meas_id_A3}    id=${ue_id}
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    sleep    30s
    Read WTS Output For Pattern And Print matching Lines    ${HO_pattern_SA}    ${Timeout_SA}
    Log To Console    ue_reg_HO_is_ok
    Sleep    2mins
    ${status}=    Run Keyword And Return Status    Verify UE_stats Throughput Average Rate for SA
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf

Intra gNB-Intra Freq SA HO FDD
    [Arguments]    ${ue_id}=${sa_ueid}    ${meas_id_A3}=${meas_id_A3_FDD}    ${phy_id}=${phy_id_FDD}
    wtsrunner.ue_disp    id=${ue_id}
    wtsrunner.ue_meas_cfg_disp    id=${ue_id}    meas_obj_type=nr
    wtsrunner.ue_measurement_send_nr    event=${event_A3}    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    ...    phycell_id=${phy_id}    nrsrp_nr=${nrsrp_nr}    nrsrq_nr=${nrsrq_nr}    meas_id=${meas_id_A3}    id=${ue_id}
    Read WTS Output For Pattern And Print matching Lines    ${HO_pattern_SA}    ${Timeout_SA}
    Log To Console    ue_reg_HO_is_ok
    Sleep    2mins
    ${status}=    Run Keyword And Return Status    Verify UE_stats Throughput Average Rate for SA
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf

UDP and TCP Traffic for SA
    [Arguments]    ${duration}
    ${dataloss_validate_list}=    Create List
    ${tput_validate_list}=    Create List
    ${tcp_dataloss_validate_list}=    Create List
    ${tcp_tput_validate_list}=    Create List
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True'
    ...    HighThroughput    ${duration}
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Start CPU Utilization Collection
    FOR   ${ueid}   IN   @{sa_ueids}
        Start UDP Traffic For SA   ${ueid}    ${traffic_dl_rate}    ${traffic_ul_rate}    ${duration}
        Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'    Start TCP Traffic for SA    ${ueid}
    END
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True' and '${HIGH_THROUGHPUT_TCPDUMP}' == 'True'
    ...    Stop tcp dump for high throughput Scenario
    ...    ELSE    Sleep    ${duration}
    FOR   ${ueid}   IN   @{sa_ueids}
        ${trf_sa_status}    Run Keyword And Ignore Error    Validate Traffic Throughput Average Rate for SA
        ...    ${traffic_dl_rate}    ${traffic_ul_rate}    ${ueid}
        ${tcp_trf_sa_status}    Run Keyword And Ignore Error    Validate TCP Traffic Throughput Average Rate for SA
        ...    ${DL_TCP_data_rate}    ${UL_TCP_data_rate}    ${ueid}
        ${udp_status}    Run Keyword And Ignore Error    Should Be True    '${trf_sa_status[0]}' == 'PASS'
        ...    msg=UDP Traffic failed, see error above!
        ${tcp_status}    Run Keyword And Ignore Error    Should Be True    '${tcp_trf_sa_status[0]}' == 'PASS'
        ...    msg=TCP Traffic failed, see error above!
        Append To List    ${tput_validate_list}    ${udp_status[0]}
        Append To List    ${tcp_tput_validate_list}    ${tcp_status[0]}
        Stop Traffic For SA    ${ueid}
        Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'    Stop Traffic For SA   ${ueid}    qfi=2
        ${trf_dataloss_status}    Run Keyword And Ignore Error    Validate Traffic Data Loss For SA    ${traffic_dl_rate}
        ...    ${traffic_ul_rate}    ${ueid}
        ${tcp_trf_dataloss_status}    Run Keyword And Ignore Error    Validate TCP Traffic Data Loss for SA    ${DL_TCP_data_rate}
        ...    ${UL_TCP_data_rate}    ${ueid}
        ${dataloss_status}    Run Keyword And Ignore Error    Should Be True    '${trf_dataloss_status[0]}' == 'PASS'
        ...    msg=UDP Traffic failed, see error above!
        Append To List    ${dataloss_validate_list}    ${dataloss_status[0]}
        ${tcp_dataloss_status}    Run Keyword And Ignore Error    Should Be True    '${tcp_trf_dataloss_status[0]}' == 'PASS'
        ...    msg=TCP Traffic failed, see error above!
        Append To List    ${tcp_dataloss_validate_list}    ${tcp_dataloss_status[0]}
    END
    Run Keyword And Ignore Error    Set WTS Default Log Level to Debug
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run Keyword and Continue on Failure    Is Traffic stats with tolerance    ${tput_validate_list}    type=Throughput
    ...    protocol=UDP
    Run Keyword and Continue on Failure    Is Traffic stats with tolerance    ${dataloss_validate_list}    type=DataLoss
    ...    protocol=UDP
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'    Validate TCP related results
    ...    ${tcp_tput_validate_list}    ${tcp_dataloss_validate_list}


Traffic should be successful for SA
    [Arguments]    ${traffic_dl_rate}=${Traffic_dl_rate}    ${traffic_ul_rate}=${Traffic_ul_rate_SA}    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword starts and Validates the Traffic for the SA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    ute_wts_runner.Start and Validate Traffic For SA    dl_rate=${traffic_dl_rate}    ul_rate=${traffic_ul_rate}    UE_ID=${UE_ID}

X2AP Link Should be UP
    [Documentation]    This keyword is used to Create a X2 connection with gNB
    ...                And checks if the X2AP link with the gNB is UP in the output file.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    wtsrunner.enb_x2_link_up    enb=${enb_id}    target=${eNB_target}
    Read WTS Output For Pattern And Print matching Lines    ${X2_link_pattern}    ${Timeout_NSA}

Add Bearer For TCP Traffic
    [Arguments]    ${UE_ID}
	[Documentation]    This keyword is for adding the an additional bearer for doing TCP traffic
    ...                Modified Date: 12-May-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    wtsrunner.bearer_add    ue=${UE_ID}    id=${TCP_BEARER_ID}    filter=0    precedence=3
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Bearer-${TCP_BEARER_ID} .*[\\n\\r].*created    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UE${UE_ID}: PGW-initiated Bearer Creation    partial_match=${TRUE}

LTE Attach should be Successful for NSA
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    wtsrunner.ue_attach    id=${UE_ID}
    Read WTS Output For Pattern And Print matching Lines    ${LTE_attach_pattern}    ${Timeout_NSA}

LTE Attach should be Successful for 4G5GCUS
    [Arguments]    ${UE_ID}=${UE_ID}    ${enb_cell_id}=${enb_cell_id}    ${enb_id}=${enb_id}
    ...    ${file}=${run_script_log_set}
    ${ue_eutra_capabilities}    Run
    ...    cat ${WTS_DIR}/${SUITE_WTS_CFG} | grep "ue_param id=${UE_ID} ue_eutra_capabilities" | awk -F " " '{print $3}' | cut -d "=" -f2
    ${ue_nr_capabilities}    Run
    ...    cat ${WTS_DIR}/${SUITE_WTS_CFG} | grep "ue_param id=${UE_ID} ue_eutra_capabilities" | awk -F " " '{print $4}' | cut -d "=" -f2
    ${ue_eutra_nr_capabilities}    Run
    ...    cat ${WTS_DIR}/${SUITE_WTS_CFG} | grep "ue_param id=${UE_ID} ue_eutra_capabilities" | awk -F " " '{print $5}' | cut -d "=" -f2
    Run UEx command    ue_param    id=${UE_ID}    ue_nr_capabilities=${ue_nr_capabilities}
    Run UEx command    ue_param    id=${UE_ID}    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Run UEx command    ue_param    id=${UE_ID}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Run UEx command    ue_attach    id=${UE_ID}    enb=${enb_id}    cell=${enb_cell_id}    selected_plmn=${nr_cgi_plmns_ident}
	...    scg_ul_dist_percent=${scg_ul_dist_percent}
    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search pattern should Exists In EGATE
    ...                            ${WTS_DIR}/egate_console.log     ${LTE_attach_pattern}

LTE Attach should be Successful with CUS
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ...                Modified Date: 02-Feb-2023
    ...                Last Modified by: kokila.b@nokia.com
    FOR   ${ueid}   IN   @{nsa_ueids}
        LTE Attach should be Successful for 4G5GCUS    ${ueid}
    END

LTE Attach should be Successful with eNB
    [Arguments]    ${UE_ID}=${UE_ID}    ${cell_id}=${enb_cell_id}    ${enb_id}=${enb_id}
    ...    ${file}=${run_script_log_set}
    Run UEx command    ue_attach    id=${UE_ID}    enb=${enb_id}    cell=${cell_id}
    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search pattern should Exists In EGATE
    ...                            ${WTS_DIR}/egate_console.log     ${LTE_attach_pattern}

LTE Attach should be Successful
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    FOR   ${ueid}   IN   @{nsa_ueids}
        LTE Attach should be Successful for NSA    ${ueid}
    END
    Run Keyword If    '${CARR_AGGR}' == 'True'    Scell Addition for Carrier Aggregation

UE Attach should be Successful with CUS
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ...                Modified Date: 02-Feb-2023
    ...                Last Modified by: kokila.b@nokia.com
    FOR   ${ueid}    IN   @{lte_ueids}
        LTE Attach should be Successful with eNB    ${ueid}
    END

UE Attach should be Successful with eNB
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ...                Modified Date: 30-July-2021
    ...                Last Modified by: kokila.b@nokia.com
    FOR   ${ueid}   IN   @{lte_ueids}
        LTE Attach should be Successful for NSA    ${ueid}
    END

UE Attach should be Successful for CUSNSA
    [Arguments]    ${UE_ID}=${UE_ID}    ${4G5G_phycellid}=${4G5G_phycellid}    ${file}=${run_script_log_set}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ...                Modified Date: 30-July-2021
    ...                Last Modified by: kokila.b@nokia.com
    Run UEx command    ue_measurement_send    event=${event}    id=${UE_ID}    phycell_id=${4G5G_phycellid}
    ...     srsrp=${CUS_VAR.srsrp}     srsrq=${CUS_VAR.srsrq}    nrsrp=${CUS_VAR.nrsrp}    nrsrq=${CUS_VAR.nrsrq}    nsinr=${CUS_VAR.nsinr}
    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}

UE Attach should be Successful for 4G5GComboNSA
    [Arguments]    ${UE_ID}=${UE_ID}    ${nrsrp}=${nrsrp}   ${4G5G_phycellid}=${4G5G_phycellid}     ${nrsrp}=${nrsrp}
    ...    ${nr_cgi_plmn_ident_info_id}=${nr_cgi_plmn_ident_info_id}   ${nr_cgi_cell_ident}=${nr_cgi_cell_ident}
    ...    ${nr_cgi_plmns_ident}=${nr_cgi_plmns_ident}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ...                Modified Date: 30-July-2021
    ...                Last Modified by: kokila.b@nokia.com
    wtsrunner.ue_measurement_send    id=${UE_ID}    phycell_id=${4G5G_phycellid}
    ...    nr_cgi_plmn_ident_info_id=${nr_cgi_plmn_ident_info_id}    nr_cgi_cell_ident=${nr_cgi_cell_ident}
    ...    nr_cgi_plmns_ident=${nr_cgi_plmns_ident}    nrsrp=${nrsrp}    event=${event}
    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}

UE Attach should be Successful for NSA
    [Arguments]    ${UE_ID}=${UE_ID}    ${Target_Cells}=${Target_Cells}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ...                Modified Date: 12-May-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    ${Target_Cells}=    Set Variable If    '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO'    ${Target_Cell_3}    ${Target_Cells}
    ${Target_Cells}=    Set Variable If    '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_2S_4CC'    ${Target_Cell_3}    ${Target_Cells}
    ${Target_Cells}=    Set Variable If    '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_CA_HO'    ${Target_Cell_3}    ${Target_Cells}
    ${Target_Cells}=    Set Variable If    '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_GMC'    ${Target_Cell_3}    ${Target_Cells}
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'
    ...    Add Bearer For TCP Traffic    ${UE_ID}
    ${bearer_info}    Set Variable If    '${DATA_TCP_ENABLE_FLAG}' == 'True'    ${Bearer_ID},${TCP_BEARER_ID}    ${Bearer_ID}
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${UE_ID}
    ...                         bearer=${bearer_info}    type=split_scg
    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}

UE Attach should be Successful
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    FOR   ${ueid}    ${targetcell}   IN ZIP   ${nsa_ueids}    ${targetcell_ids}
        UE Attach should be Successful for NSA    ${ueid}    ${targetcell}
    END

UE Attach should be Successful for 4G5GCUS
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ...                Modified Date: 02-Feb-2023
    ...                Last Modified by: kokila.b@nokia.com
    FOR   ${ueid}   IN   @{nsa_ueids}
        UE Attach should be Successful for CUSNSA    ${ueid}
    END

UE Attach should be Successful for 4G5GCombo
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ...                Modified Date: 30-July-2021
    ...                Last Modified by: kokila.b@nokia.com
    FOR   ${ueid}   IN   @{nsa_ueids}
        UE Attach should be Successful for 4G5GComboNSA    ${ueid}
    END

Traffic should be Successful for NSA
    [Arguments]    ${ue_id}=${UE_ID}    ${traffic_dl_rate}=${Traffic_dl_rate}
    ...    ${traffic_ul_rate}=${Traffic_ul_rate_${duplexing}}
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD variants
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    ute_wts_runner.Start Traffic    UE_ID=${ue_id}    dl_rate=${traffic_dl_rate}    ul_rate=${traffic_ul_rate}

Traffic for NSA should be Successful
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD/TDD variants
    ...                Modified Date: 21-Jun-2022
    ...                Last Modified by: sravani.k@nokia.com
    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${duration}
    Run Keyword If    '${MAX_THROUGHPUT}' == 'True'    HighThroughput SUE QT Traffic NSA    ${duration}
    ...       ELSE     UDP and TCP Traffic for NSA    ${duration}

HighThroughput SUE QT Traffic NSA
    [Arguments]    ${duration}
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Start CPU Utilization Collection
    Run Keyword If    '${DEV_TEST}' == 'True'    Log Bearer stats without verification NSA Sequential
    Generate NSA Traffic for High Throughput
    Sleep    ${duration}
    Log To Console    Running Traffic for ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    Run Keyword If    '${DEV_TEST}' == 'True'    Log Bearer stats without verification NSA Sequential
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s
    ...    Verify UE_stats Throughput Average Rate for NSA
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf
	Run Keyword If    '${HO_flag}' == 'True'    UE Attach NSA HO TDD FDD
    Stop NSA Max throughput traffic
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run keyword if    '${status}' == 'False'    Fail    msg=NSA Traffic Failed

Traffic for NSA should be Successful for DL UL sequential flow
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD/TDD variants
    ...                Modified Date: 21-Jun-2022
    ...                Last Modified by: sravani.k@nokia.com
    Run Keyword And Ignore Error    Set WTS Default Log Level to None
    Run Keyword If    '${MAX_THROUGHPUT}' == 'True'    HighThroughput SUE QT Traffic NSA Seq

HighThroughput SUE QT Traffic NSA Seq
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Start CPU Utilization Collection
    Generate NSA Traffic for High Throughput Seq Flow

UE Attach NSA HO TDD FDD
    UE Attach NSA FW HO TDD FDD
    UE Attach NSA RV HO TDD FDD

UE Attach NSA FW HO TDD FDD
    Intra gNB-Inter Freq NSA HO TDD_FDD    ${nsa_ueids_HO[0]}    ${nsa_meas_id_A2_TDD_FDD_HO[0]}
	...    ${nsa_meas_id_A3_TDD_FDD_HO[0]}    ${phy_id_TDD_FDD_HO[0]}
    Intra gNB-Intra Freq NSA HO FDD    ${nsa_ueids_HO[1]}    ${meas_id_A3_FDD_HO[0]}
	...    ${phy_id_FDD_HO[0]}

UE Attach NSA RV HO TDD FDD
    Intra gNB-Inter Freq NSA HO TDD_FDD    ${nsa_ueids_HO[0]}    ${nsa_meas_id_A2_TDD_FDD_HO[1]}
	...    ${nsa_meas_id_A3_TDD_FDD_HO[1]}    ${phy_id_TDD_FDD_HO[1]}
    Intra gNB-Intra Freq NSA HO FDD        ${nsa_ueids_HO[1]}    ${meas_id_A3_FDD_HO[0]}
	...    ${phy_id_FDD_HO[1]}

Intra gNB-Inter Freq NSA HO TDD_FDD
    [Arguments]    ${ue_id}=${nsa_ueid}    ${meas_id_A2}=${nsa_meas_id_A2_TDD_FDD}
	...    ${meas_id_A3}=${nsa_meas_id_A3_TDD_FDD}    ${phy_id}=${phy_id_TDD_FDD}
    wtsrunner.ue_disp    id=${ue_id}
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    sleep    2s
    wtsrunner.ue_enb_param    id=${ue_id}    measurement_gap=${meas_gap}    mgta=${mgta}
    ...    gap_purpose=perUE    gap_trigger=gnb_triggered
    sleep     5s
    wtsrunner.ue_meas_cfg_disp    id=${ue_id}    meas_obj_type=nr
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    sleep    2s
    wtsrunner.ue_measurement_send_nr    event=${event_A2}    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    ...    meas_id=${meas_id_A2}    id=${ue_id}
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    sleep    2s
    wtsrunner.ue_meas_cfg_disp    id=${ue_id}    meas_obj_type=nr
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    sleep    2s
    wtsrunner.ue_measurement_send_nr    event=${event_A3}    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    ...    phycell_id=${phy_id}    nrsrp_nr=${nrsrp_nr}    nrsrq_nr=${nrsrq_nr}    meas_id=${meas_id_A3}    id=${ue_id}
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    sleep    1mins
    Read WTS Output For Pattern And Print matching Lines    ${HO_pattern_NSA1}    ${Timeout_NSA}
    Read WTS Output For Pattern And Print matching Lines    ${HO_pattern_NSA2}    ${Timeout_NSA}
    Sleep    2mins
    ${status}=    Run Keyword And Return Status    Verify UE_stats Throughput Average Rate for NSA
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf

Intra gNB-Intra Freq NSA HO FDD
    [Arguments]    ${ue_id}=${nsa_ueid}    ${meas_id_A3}=${meas_id_A3_FDD}    ${phy_id}=${phy_id_FDD}
    wtsrunner.ue_disp    id=${ue_id}
    wtsrunner.ue_meas_cfg_disp    id=${ue_id}    meas_obj_type=nr
    wtsrunner.ue_measurement_send_nr    event=${event_A3}    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    ...    phycell_id=${phy_id}    nrsrp_nr=${nrsrp_nr}    nrsrq_nr=${nrsrq_nr}    meas_id=${meas_id_A3}    id=${ue_id}
    Read WTS Output For Pattern And Print matching Lines    ${HO_pattern_NSA1}    ${Timeout_NSA}
    Read WTS Output For Pattern And Print matching Lines    ${HO_pattern_NSA2}    ${Timeout_NSA}
    Sleep    2mins
    ${status}=    Run Keyword And Return Status    Verify UE_stats Throughput Average Rate for NSA
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf

Stop SA Max throughput traffic
    Stop Traffic For SA    ${sa_ueid_tdd_HTpQT}
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Stop Traffic For SA    ${sa_ueid_fdd_HTpQT}

Stop SA Max throughput traffic for 6G
    Stop Traffic For SA for 6G UL    ${sa_ueid_tdd_HTpQT}
    Stop Traffic For SA for 6G DL    ${sa_ueid_tdd_HTpQT}
    Run Keyword if    '${FR1_TDD_FDD}' == 'True'    Stop Traffic For SA    ${sa_ueid_fdd_HTpQT}

Stop NSA Max throughput traffic
    Stop Traffic For NSA    ${nsa_ueid_tdd_HTpQT}
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Stop Traffic For NSA    ${nsa_ueid_fdd_HTpQT}

Verify UE_stats Throughput Average Rate for NSA
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Verify UE_stats Average Rate for NSA_TDD_FDD
    ...    ELSE    Verify UE_stats Average Rate for NSA    ${UE_ID_SANSA}    ${traffic_dl_rate}    ${traffic_ul_rate}

Verify UE_stats Average Rate for NSA_TDD_FDD
    Verify UE_stats Average Rate for NSA    ${nsa_ueid_tdd_HTpQT}    ${traffic_nsa_tdd_dl_rate}    ${traffic_nsa_tdd_ul_rate}
    Verify UE_stats Average Rate for NSA    ${nsa_ueid_fdd_HTpQT}    ${traffic_nsa_fdd_dl_rate}    ${traffic_nsa_fdd_ul_rate}

Verify UE_stats Throughput Average Rate for SA
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Verify UE_stats Average Rate for SA_TDD_FDD
    ...    ELSE    Verify UE_stats Average Rate for SA    ${UE_ID}    ${traffic_dl_rate}    ${traffic_ul_rate}

Verify UE_stats Average Rate for SA_TDD_FDD
    Verify UE_stats Average Rate for SA    ${sa_ueid_tdd_HTpQT}    ${traffic_sa_tdd_dl_rate}    ${traffic_sa_tdd_ul_rate}
    Verify UE_stats Average Rate for SA    ${sa_ueid_fdd_HTpQT}    ${traffic_sa_fdd_dl_rate}    ${traffic_sa_fdd_ul_rate}

UDP and TCP Traffic for NSA
    [Arguments]    ${duration}
    ${dataloss_validate_list}=    Create List
    ${tcp_dataloss_validate_list}=    Create List
    ${tput_validate_list}=    Create List
    ${tcp_tput_validate_list}=    Create List
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True'
    ...    HighThroughput    ${duration}
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Start CPU Utilization Collection
    FOR   ${ueid}   IN   @{nsa_ueids}
        Start UDP Traffic For NSA   ${ueid}    ${traffic_dl_rate}    ${traffic_ul_rate}    ${duration}
        Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'    Start TCP Traffic for NSA    ${ueid}
    END
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True' and '${HIGH_THROUGHPUT_TCPDUMP}' == 'True'
    ...    Stop tcp dump for high throughput Scenario
    ...    ELSE    Sleep    ${duration}
    FOR   ${ueid}   IN   @{nsa_ueids}
        ${trf_nsa_status}    Run Keyword And Ignore Error    Validate Traffic Throughput Average Rate for NSA
        ...    ${traffic_dl_rate}    ${traffic_ul_rate}    ${ueid}
        ${tcp_trf_nsa_status}    Run Keyword And Ignore Error     Validate TCP Traffic Throughput Average Rate for NSA   ${DL_TCP_data_rate}
        ...    ${UL_TCP_data_rate}    ${ueid}
        ${udp_status}    Run Keyword And Ignore Error    Should Be True    '${trf_nsa_status[0]}' == 'PASS'
        ...    msg=UDP Traffic failed, see error above!
        ${tcp_status}    Run Keyword And Ignore Error    Should Be True    '${tcp_trf_nsa_status[0]}' == 'PASS'
        ...    msg=TCP Traffic failed, see error above!
        Append To List    ${tput_validate_list}    ${udp_status[0]}
        Append To List    ${tcp_tput_validate_list}    ${tcp_status[0]}
        Stop Traffic For NSA    ${ueid}
        Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'    Stop Traffic For NSA   ${ueid}
        ...    bearer_id=${TCP_BEARER_ID}
        ${trf_dataloss_status}    Run Keyword And Ignore Error    Validate Traffic Data Loss For NSA    ${traffic_dl_rate}
        ...    ${traffic_ul_rate}    ${ueid}
        ${tcp_trf_dataloss_status}    Run Keyword And Ignore Error    Validate TCP Traffic Data Loss for NSA    ${DL_TCP_data_rate}
        ...    ${UL_TCP_data_rate}    ${ueid}
        ${dataloss_status}    Run Keyword And Ignore Error    Should Be True    '${trf_dataloss_status[0]}' == 'PASS'
        ...    msg=UDP Traffic failed, see error above!
        Append To List    ${dataloss_validate_list}    ${dataloss_status[0]}
        ${tcp_dataloss_status}    Run Keyword And Ignore Error    Should Be True    '${tcp_trf_dataloss_status[0]}' == 'PASS'
        ...    msg=TCP Traffic failed, see error above!
        Append To List    ${tcp_dataloss_validate_list}    ${tcp_dataloss_status[0]}
    END
    Run Keyword And Ignore Error    Set WTS Default Log Level to Debug
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run Keyword and Continue on Failure    Is Traffic stats with tolerance    ${tput_validate_list}    type=Throughput
    ...    protocol=UDP
    Run Keyword and Continue on Failure    Is Traffic stats with tolerance    ${dataloss_validate_list}    type=DataLoss
    ...    protocol=UDP
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'    Validate TCP related results
    ...    ${tcp_tput_validate_list}    ${tcp_dataloss_validate_list}


LTE Traffic should be Successful for 4G5GCUS
    [Arguments]    ${ue_id}=${UE_ID}    ${dl_rate_CUS}=${dl_rate_CUS}    ${ul_rate_CUS}=${ul_rate_CUS}
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD variants
    ...                Modified Date: 02-Feb-2023
    ...                Last Modified by: kokila.b@nokia.com
    FOR   ${ueid}   IN   @{lte_ueids}
        ute_wts_runner.Start LTE Traffic for CUS    UE_ID=${ue_id}    dl_rate_CUS=${dl_rate_CUS}    ul_rate_CUS=${ul_rate_CUS}
    END

LTE Traffic should be Successful
    [Arguments]    ${ue_id}=${UE_ID}    ${traffic_dl_rate}=${Traffic_dl_rate}
    ...     ${traffic_ul_rate}=${Traffic_ul_rate_${duplexing}}
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD/TDD variants
    ...                Modified Date: 30-July-2021
    ...                Last Modified by: kokila.b@nokia.com

    FOR   ${ueid}   IN   @{lte_ueids}
        LTE Traffic    ${ueid}    ${traffic_dl_rate}    ${traffic_ul_rate}
    END

Traffic for NSA should be Successful for 4G5GCUS
    [Arguments]    ${ue_id}=${UE_ID}    ${dl_rate_CUS}=${dl_rate_CUS}    ${ul_rate_CUS}=${ul_rate_CUS}
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD/TDD variants
    ...                Modified Date: 02-Feb-2023
    ...                Last Modified by: kokila.b@nokia.com

    FOR   ${ueid}   IN   @{nsa_ueids}
        ute_wts_runner.Start LTE Traffic for CUS    UE_ID=${ue_id}    dl_rate_CUS=${dl_rate_CUS}    ul_rate_CUS=${ul_rate_CUS}
    END

LTE Traffic
    [Arguments]    ${ue_id}=${UE_ID}    ${traffic_dl_rate}=${Traffic_dl_rate}
    ...    ${traffic_ul_rate}=${Traffic_ul_rate_${duplexing}}
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD variants
    ...                Modified Date: 08-Aug-2021
    ...                Last Modified by: kokila.b@nokia.com
    ute_wts_runner.Start LTE Traffic    UE_ID=${ue_id}    dl_rate=${traffic_dl_rate}    ul_rate=${traffic_ul_rate}

UE 5GDetach should be Successful for NSA
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword is used to Detach the UE from 5G connection with gNB and checks the completion message in output file.
    ...                Enhance the keyword to detach SANSA UE as well.
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.enb_ue_dc_release    ue=${UE_ID}    bearer=${Bearer_ID}    by=enb    cause=off
    Read WTS Output For Pattern And Print matching Lines    ${UE_5GDetach_pattern}    ${Timeout_NSA}

UE 5GDetach should be Successful
    [Documentation]    This keyword is used to Detach the UE from 5G connection with gNB and checks the completion message in output file.
    ...                Enhance the keyword to detach SANSA UE as well.
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    FOR   ${ueid}   IN   @{nsa_ueids}
        UE 5GDetach should be Successful for NSA    ${ueid}
    END

UE Detach should be Successful with CUS
    [Arguments]    ${file}=${run_script_log_set}
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    ...                Modified Date: 02-Feb-2023
    ...                Last Modified by: kokila.b@nokia.com
    FOR   ${ueid}   IN   @{lte_ueids}
        Run UEx command    ue_detach    id=${ueid}
        wtsrunner.script    file=${file}    entry=sim_log_set_flush()
        Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}     Search pattern should Exists In EGATE
        ...                            ${WTS_DIR}/egate_console.log     ${UE_Detach}
    END

UE Detach for NSA should be Successful
    [Arguments]    ${file}=${run_script_log_set}
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    ...                Modified Date: 30-July-2021
    ...                Last Modified by: kokila.b@nokia.com
    FOR   ${ueid}   IN   @{nsa_ueids}
        Run UEx command    ue_detach    id=${ueid}
        wtsrunner.script    file=${file}    entry=sim_log_set_flush()
        Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}     Search pattern should Exists In EGATE
        ...                            ${WTS_DIR}/egate_console.log     ${UE_Detach}
    END

UE Detach should be Successful with eNB
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    ...                Modified Date: 30-July-2021
    ...                Last Modified by: kokila.b@nokia.com
    FOR   ${ueid}   IN   @{lte_ueids}
        UE Detach should be Successful for NSA    ${ueid}
    END

UE Detach should be Successful for NSA
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    ...                Modified Date: 31-March-2021
    ...                Last Modified by: anil.1.pachauri@nokia.com
    wtsrunner.ue_detach    id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_detach_pattern}    ${Timeout_NSA}
    Print Matching Lines from Output File    ${output}    ${UE_detach_pattern}

UE Detach should be Successful
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    FOR   ${ueid}   IN   @{nsa_ueids}
        UE Detach should be Successful for NSA    ${ueid}
    END

UE Reattach should be Successful for NSA
    [Arguments]    ${UE_ID}=${UE_ID}    ${Target_Cells}=${Target_Cells}     ${4G5G_Combo}=${4G5G_Combo}
    [Documentation]    This keyword is used to Reattach the UE with gNB and checks the completion message in the output file.
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Sleep    ${UE_Reattach_sleep}
    LTE Attach should be Successful for NSA    ${UE_ID}
    Run Keyword If    '${4G5G_Combo}'=='0'
    ...    UE Attach should be Successful for NSA    ${UE_ID}    ${Target_Cells}    ELSE
    ...    UE Attach should be Successful for 4G5GComboNSA    ${UE_ID}

UE Reattach should be Successful with CUS
    [Documentation]    This keyword is used to Reattach the UE with gNB and checks the completion message in the output file.
    ...                Modified Date: 02-Feb-2023
    ...                Last Modified by: kokila.b@nokia.com
    Sleep    ${UE_Reattach_sleep}
    FOR    ${ueid}    IN    @{lte_ueids}
        LTE Attach should be Successful with eNB    ${ueid}
        Log    ue_reattach_is_ok
    END

UE Reattach should be Successful with eNB
    [Documentation]    This keyword is used to Reattach the UE with gNB and checks the completion message in the output file.
    ...                Modified Date: 30-July-2021
    ...                Last Modified by: kokila.b@nokia.com
    Sleep    ${UE_Reattach_sleep}
    FOR    ${ueid}    IN    @{lte_ueids}
        LTE Attach should be Successful for NSA    ${ueid}
    END

UE Reattach for NSA should be Successful
    [Documentation]    This keyword is used to Reattach the UE with gNB and checks the completion message in the output file.
    ...                Modified Date: 02-Feb-2023
    ...                Last Modified by: kokila.b@nokia.com
    Sleep    ${UE_Reattach_sleep}
    LTE Attach should be Successful with CUS
    UE Attach should be Successful for 4G5GCUS

UE Reattach should be Successful
    [Documentation]    This keyword is used to Reattach the UE with gNB and checks the completion message in the output file.
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    FOR   ${ueid}    ${targetcell}   IN ZIP   ${nsa_ueids}    ${targetcell_ids}
        UE Reattach should be Successful for NSA   ${ueid}   ${targetcell}
    END

Read WTS Output For Pattern And Print matching Lines
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks if the ${pattern} is present in the output file and prints the line matching the pattern.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${output}    Read WTS Output Until Pattern Matches   ${pattern}    ${timeout}
    Print Matching Lines from Output File    ${output}    ${pattern}
    [Return]    ${output}

Read WTS Output Until Pattern Matches
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks the output file until the ${pattern} matches in the file.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=${pattern}
    ...    timeout=${timeout}
    [Return]    ${output}

Print Matching Lines from Output File
    [Arguments]    ${output}    ${pattern}
    [Documentation]    This keyword Prints the lines which contains the ${pattern} from the output file ${output}
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${output}        Get Lines Matching Regexp    ${output}    ${pattern}
    ...               partial_match=${TRUE}
    Log to Console    \n${output}

Check if AP L1 Log needs to be Collected
    [Arguments]    ${status}
    [Documentation]    This keyword is used to check if AP L1 log needs to be collected based on flags
    ...                Modified Date: 17-May-2021
    ...                Last Modified by: ramya.2.k@nokia.com
    Return From Keyword If    '${CONDITIONAL_LOGGING}' == 'True' and '${status}' == 'PASS'
    ${l1_log}=    Set Variable If    '${AP_L1_Log}' == 'True' or '${status}' == 'FAIL'    1    0
    [Return]   ${l1_log}

Collect AP L1 Log
    [Arguments]    ${folder}    ${status}
    [Documentation]    This keyword is used to collect ring buffer dump and register dump.
    ...                Modified Date: 17-May-2021
    ...                Last Modified by: ramya.2.k@nokia.com
    ${l1_log}    Check if AP L1 Log needs to be Collected    ${status}
    Run Keyword If    '${l1_log}' == '1' and '${l1}' == 'FS'
    ...    Run Keyword And Ignore Error    Airphone L1 Log Collection    ${folder}

Get AP Suite Configuration Variables
    [Documentation]    This keyword will identify the variables related to ap_configurations
    ...                Modified Date: 14-April-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    ${var}=    Get Variable Value    ${TOPOLOGY}
    ${var_exists}=      Set Variable If    "${var}" != 'None'    ${True}    ${False}
    Run Keyword If    '${var_exists}' == 'False'
    ...   Get AP Suite Configuration From File   ELSE
    ...   Set AP Suite Configuration Variables   ${TOPOLOGY}

Get Component Carrier Variables
    ${var}=    Get Variable Value    ${COMPONENT_CARRIER}
    ${var_exists}=      Set Variable If    "${var}" != 'None'    ${True}    ${False}
    Run Keyword If    '${var_exists}' == 'False'
    ...   Get Component Carrier Value From File   ELSE
    ...   Set Component Carrier Variables    ${COMPONENT_CARRIER}

Check and Override Multicell RU Type From File
    ${var}=    Get Variable Value    ${TOPOLOGY}
    ${var_exists}=      Set Variable If    "${var}" != 'None'    ${True}    ${False}
    Return From Keyword If    '${var_exists}' == 'False'
    Run Keyword If    '${TOPOLOGY}'=='CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD' and '${component_carrier}'=='1'
    ...    Set RU Type From File

Set RU Type From File
    ${value}=    Get Param Value From File   ${test_property_file}    RMOD=(\\w+)
    Set Suite Variable    ${RU_type}    ${value}

Get Secondary Test PC Data
    ${hostname}=    Get Hostname Details
    ${init_file}=   Get Init File Details     ${testline_results_path}    configs/${hostname}/__init__.py
    ${cloned_init_file}=    Run Keyword If    '${init_file}' == 'FAIL'
    ...   Clone Testline Configuration Repo    ${hostname}
    Run Keyword If    '${init_file}' != 'FAIL'    Set Secondary Test PC Credentials    ${init_file}
    ...   ELSE    Set Secondary Test PC Credentials    ${cloned_init_file}
    Log    ${test_pc2}

Get Secondary Test PC Data for CUS
    ${hostname}=    Get Hostname Details
    ${init_file}=   Get Init File Details for CA     ${ute_ca_logs_path}    __init__.py    ${hostname}
    ${cloned_init_file}=    Run Keyword If    '${init_file}' == 'FAIL'
    ...   Clone Testline Configuration Repo    ${hostname}
    Run Keyword If    '${init_file}' != 'FAIL'    Set Secondary Test PC Credentials    ${init_file}
    ...   ELSE    Set Secondary Test PC Credentials    ${cloned_init_file}

Get Init File Details for CA
    [Arguments]    ${main_path}    ${init_file_path}    ${hostname}
    ${init_file}=    Catenate      SEPARATOR=/    ${main_path}    TL_${hostname}    ${init_file_path}
    ${result}   ${value}=     Run Keyword And Ignore Error    File Should Exist    ${init_file}
    Run Keyword if    '${result}' == 'PASS'    Set Suite Variable    ${init_file}
    Return From Keyword If    '${result}' == 'PASS'      ${init_file}
    ${init_file_ca}=    Run Keyword If    '${result}' == 'FAIL'    Get Init File From Single Run Path    ${init_file_path}
    Run Keyword if    '${init_file_ca}' != 'FAIL'    Set Suite Variable    ${init_file_ca}
    Return From Keyword If    '${init_file_ca}' != 'FAIL'      ${init_file_ca}
    Return From Keyword If    '${init_file_ca}' == 'FAIL'      FAIL

Get Init File From Single Run Path
    [Arguments]    ${init_file_path}
    ${init_file}=    Catenate      SEPARATOR=/    ${ute_ca_singlerun_path}    ${init_file_path}
    ${result}   ${value}=     Run Keyword And Ignore Error    File Should Exist    ${init_file}
    Run Keyword if    '${result}' == 'PASS'    Set Suite Variable    ${init_file}
    Return From Keyword If    '${result}' == 'PASS'      ${init_file}
    Return From Keyword If    '${result}' == 'FAIL'    FAIL

Update GNB IP For 4G5GCombo Setup
    Run Keyword If    '${4G5G_Combo}'=='1'    Update 4G5GCombo Dictionary for GNB IP
    Run Keyword If    '${4G5G_CUS}'=='1'    Update 4G5GCombo Dictionary for GNB IP

Update 4G5GCombo Dictionary for GNB IP
    Set To Dictionary     ${GNB_ASIK}    Ip    ${4G5G_Combo_GNB_IP}
    Set To Dictionary     ${GNB_BTS}     Ip    ${4G5G_Combo_GNB_IP}
    Set Suite Variable    &{GNB_BTS}     &{GNB_BTS}
    Set Suite Variable    &{GNB_ASIK}    &{GNB_ASIK}
    LogMany    &{GNB_ASIK}
    LogMany    &{GNB_BTS}

Update the gNB Mirroring config file for ASIB Variants
    [Arguments]    ${initial_number}    ${modify_number}
    [Documentation]    This keyword is used to update the Number of files present in the gNBMirroringConfig.sh file
    ...                for ASIB Variants.
    ...                Modified Date: 29-Sept-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${command}    Catenate    sed -i -z "s/NUMBER_OF_FILES=${initial_number}/NUMBER_OF_FILES=${modify_number}/g"
    ...                   ${scriptPath}/${gnbMirroringConfig}
    SSH.Execute       ${command}    ${GNB_ASIK}[Connection]

Update the BBSlot value in gNB Mirroring script for FDD ASIB ABIO
    [Documentation]    This keyword is used to update the BB Slot values present in the gNBMirroringConfig.sh file
    ...                for FDD ASIB ABIO Variants.
    ...                Modified Date: 22-Dec-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${command}    Catenate    sed -i -e "s/BB_SLOT_1=true/BB_SLOT_1=false/g" -e "s/BB_SLOT_5=false/BB_SLOT_5=true/g"
    ...                   ${scriptPath}/${gnbMirroringConfig}
    SSH.Execute       ${command}    ${GNB_ASIK}[Connection]

Update SCF File To Enable TCP on Another QCI
    [Documentation]    This keyword is used to update SCF file on NRDRB profile and actMultiDrbNSA
    ...                Modified Date: 11-Oct-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    [Arguments]     ${actMultiDrbNSA}=true    ${nsa3xBearerAllowed}=true
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Set BTS ID and DIST_NAME
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    actMultiDrbNSA=${actMultiDrbNSA}
    Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-2    nsa3xBearerAllowed=${nsa3xBearerAllowed}
    ${delta_store}    Collect Delta Store
    ${comm_status}    Run Keyword And Return Status    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Run Keyword If    '${comm_status}' == 'False'    Run Keywords    Log    Delta Commisioning Failed For TCP Update Please check it    WARN    AND
    ...    Set Suite Variable     ${DATA_TCP_ENABLE_FLAG}    False

Revert TCP Related Configuration back to Original
    [Documentation]    This keyword is used to update WTS config file and SCF to defaults
    ...                Modified Date: 12-May-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Return From Keyword If    '${DATA_TCP_ENABLE_FLAG}' != 'True'
    Run And Return Rc And Output   cp ${WTS_DIR}/${SUITE_WTS_CFG} ${WTS_DIR}/${SUITE_WTS_CFG}_tcp_run
    Run And Return Rc And Output   cp ${WTS_DIR}/${SUITE_WTS_CFG}_repo ${WTS_DIR}/${SUITE_WTS_CFG}
    ${var_status}    Run Keyword And Return Status    Variable Should Exist    ${coamSCF}
    Run Keyword If    ${var_status}    Run And Return Rc And Output    cp ${coamSCF} ${EXECDIR}/logs/gnb_coam_scf_tcp.xml
    Update SCF File To Enable TCP on Another QCI    actMultiDrbNSA=false    nsa3xBearerAllowed=false
    Get Coam SCF

Set TCP Flag For Selected Variants
    [Documentation]    We will pump TCP data for selected topology
    ...                Modified Date: 11-Oct-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    ${valid_config}=    Catenate    '${apConfiguration}' in    "@{TCP_Data_Variants}"
    ...                              and '${AP_P1Perf}' != 'True' and '${AP_P1Perf_mmwv}' != 'True'
    ...                              and '${EXTEND_ORAN}' != 'true' and '${START_TCP_TRAFFIC}' == 'True'
    ...                              and '${AP_P1Perf_ABIL}' != 'True' and '${4G5G_CUS}' != '1'
    Run Keyword If    ${valid_config}    Set Suite Variable    ${DATA_TCP_ENABLE_FLAG}    True

Load ORAN Config Files
    [Documentation]    This is highlevel keyword to bringup TL in ORAN mode.
    ...                Modified Date: 25-Jul-2022
    ...                Last Modified by: anil.1.pachauri@nokia.com
    Get ORAN Config Files
    Get Testline Init File
    Log to console    Cleanup config files...
    AP Configs Cleanup And Set Iphy
    GNB Config Cleanup
    Reset AP And GNB
    Wait Until Keyword Succeeds    10min    5sec    Verify BBMOD Status
    sleep    30s
    Log to console    Perform SCF commissioning...
    Apply ORAN SCF
    Wait Until Keyword Succeeds    5min    5sec    Verify BBMOD Status
    sleep    30s
    Log to console    Add netconf account...
    Netconf User Addition
    sleep   10s
    Reset AP And GNB
    Log to console    Waiting For Requred State...
    Wait Until Keyword Succeeds    15min    5min    Wait Coam Site to be Ready
    Reset WTS

Reset WTS
    Log to console    Reset WTS...
    Run     sudo pkill edaemon && sudo pkill egate
    Run     cd /opt/wts/latest && rm -rf *.log.* && rm -rf SosReport*.tgz
    ${AP_BUILD}                    Run    ls -l /opt/wts/ | grep latest
    ${AP_build_number}             Fetch From Right    ${AP_BUILD}    /opt/wts/
    Run     rm -rf /opt/wts/latest && ln -f -s /opt/wts/${AP_build_number} /opt/wts/latest

Get ORAN Config Files
    Set Variable Stream NR
    Set ORAN Files

Set Variable Stream NR
    Wait Until Keyword Succeeds    5min    5sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    ${sw_version}                 CoamAdmin.get_sw_version
    @{sw_version_list}=           Split String    ${sw_version}    separator=_
    ${stream_num}=   Run Keyword And Return Status   BuiltIn.Should Start With   ${sw_version_list}[2]   9
    ${stream_nr}=    Run Keyword if    "SBTS" in "${sw_version_list}[0]"
    ...             Set Variable if  "${stream_num}"=="True"   SBTS00    ${sw_version_list}[0]
    ...              ELSE    python_keywords.parse_sw_to_stream    ${sw_version}
    Set Global Variable           ${stream_nr}
    CoamAdmin.Teardown

Set ORAN Files
    Set Suite Variable    ${AP_configs}    ${EXECDIR}/testconfigs
    ${config_yaml}=    Set Variable    ${AP_configs}/${stream_nr}/${deployment}/${l1}/config.yaml
    ${dic}=    parser.parse_yaml    ${config_yaml}    ${duplexing}    ${RF_type}
    ...    ${wavelength}    ${RU_type}    ${gnb_sm_hardware}    ${gnb_cp_hardware}
    ...    ${ap_sm_hardware}    ${ap_cp_hardware}    ${component_carrier}
    ${ap_iphy_file}=    Get From Dictionary    ${dic}   AP_iphy_xml
    ${gnb_scf_file}=    Get From Dictionary    ${dic}   gNB_DU_scf
    ${gnb_swconfig_file}=    Get From Dictionary    ${dic}   gNB_swconfig
    ${wts_cfg}=    Get From Dictionary    ${dic}   WTS_config
    Run     cp ${AP_configs}/${ap_iphy_file} ${AP_configs}/iphy_ORAN.xml
    Run     scp ${AP_configs}/iphy_ORAN.xml ${AP_ASIK.Username}@${AP_ASIK.Ip}:/ffs/run/simmode
    Set Suite Variable    ${gnb_scf_file}    ${AP_configs}/${gnb_scf_file}
    Run     scp ${AP_configs}/${gnb_swconfig_file} ${GNB_ASIK.Username}@${GNB_ASIK.Ip}:/ffs/run/

    Run     mkdir -p ${EXECDIR}/logs
    Run     cp ${gnb_scf_file} ${EXECDIR}/logs/gnb_coam_scf.xml
    Run     cp ${AP_configs}/${gnb_swconfig_file} ${EXECDIR}/logs/swconfig_gnb.txt
    Run     cp ${AP_configs}/${wts_cfg} ${EXECDIR}/logs/

Get Testline Init File
    ${hostname}=    Get VM Hostname Details
    ${init_file}=    Get Init File    configs/${hostname}/__init__.py    ${hostname}

Get VM Hostname Details
    ${result}   ${value}=     Run Keyword And Ignore Error    Get Param Value From File
    ...    ${testline_results_file}    HOSTNAME:\\s+(\\w+.*\\w+)
    ${hostname}=    Replace String Using Regexp    ${value}    -    _
    Return From Keyword If    '${result}' == 'PASS'    ${hostname}
    ${value}=    Run Keyword If    '${result}' == 'FAIL'    Run Command Locally And Return Output    hostname
    ${hostname}=    Replace String Using Regexp    ${value}    -    _
    [Return]    ${hostname}

Get Init File
    [Arguments]    ${init_file_path}    ${hostname}
    ${init_file}=    Catenate      SEPARATOR=/    ${testline_init_path}    ${init_file_path}
    ${result}   ${value}=     Run Keyword And Ignore Error    File Should Exist    ${init_file}
    Run Keyword if    '${result}' == 'PASS'    Set Suite Variable    ${init_file}
    Return From Keyword If    '${result}' == 'PASS'      ${init_file}
    ${init_file}=    Catenate      SEPARATOR=/    ${testline_config_path}    ${hostname}/__init__.py
    ${result}   ${value}=     Run Keyword And Ignore Error    File Should Exist    ${init_file}
    Run Keyword if    '${result}' == 'PASS'    Set Suite Variable    ${init_file}
    Return From Keyword If    '${result}' == 'PASS'      ${init_file}
    Run Keyword If    '${result}' == 'FAIL'    Get Init File From Result Path    ${init_file_path}
    Return From Keyword If    '${result}' == 'FAIL'      FAIL

Get Init File From Result Path
    [Arguments]    ${init_file_path}
    ${init_file}=    Catenate      SEPARATOR=/    ${testline_results_path}    ${init_file_path}
    ${result}   ${value}=     Run Keyword And Ignore Error    File Should Exist    ${init_file}
    Run Keyword if    '${result}' == 'PASS'    Set Suite Variable    ${init_file}
    Return From Keyword If    '${result}' == 'PASS'      ${init_file}

Reset AP Power
    ${rc}       ${output}=    Run and Return RC and Output
    ...    grep -A 0 _pdu ${init_file}|cut -d'(' -f1 | head -n 1 | cut -d' ' -f3
    Set Suite Variable    ${model}    ${output}
    ${init_path}    Split String From Right    ${init_file}    /    1
    ${command}=    Catenate    cd ${init_path}[0] &&
    ...       python -c
    ...       "from __init__ import tl;print(tl.ues[0].l1.common_units[0].pdu_port.pdu.addr)"
    ${ap_pdu_ip}=    Run    ${command}
    ${command}=    Catenate    cd ${init_path}[0] &&
    ...       python -c
    ...       "from __init__ import tl;print(tl.ues[0].l1.common_units[0].pdu_port.port_no)"
    ${ap_pdu_port}=    Run    ${command}
    Reset Power Ports    ${ap_pdu_ip}    ${ap_pdu_port}    model=${model}

Reset GNB Power
    ${init_path}    Split String From Right    ${init_file}    /    1
    ${command}=    Catenate    cd ${init_path}[0] &&
    ...       python -c
    ...       "from __init__ import tl;print(tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr)"
    ${gnb_pdu_ip}=    Run    ${command}
    ${command}=    Catenate    cd ${init_path}[0] &&
    ...       python -c
    ...       "from __init__ import tl;print(tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no)"
    ${gnb_pdu_port}=    Run    ${command}
    Reset Power Ports    ${gnb_pdu_ip}    ${gnb_pdu_port}    model=${model}

Reset AP And GNB
    Reset AP Power
    Reset GNB Power

Reset Power Ports
    [Arguments]         ${PDU_IP}    ${PDU_PORT}    ${alias}=atenpdu    ${model}=ATEN
    Log To Console      \n Reset ongoing for PDU ${PDU_IP}, port ${PDU_PORT}
    pdu.setup_pdu       host=${PDU_IP}
    ...                 model=${model}
    ...                 alias=${alias}
    pdu.power_off       port=${PDU_PORT}
    ...                 pdu_device=${alias}
    sleep               5s
    pdu.power_on        port=${PDU_PORT}
    ...                 pdu_device=${alias}
    Sleep               5s

AP Configs Cleanup And Set Iphy
    SSH.Connect To   ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    SSH.Execute    rm -rf /ffs/fs*/boardcfg/1/C/mcu-aspa/boot/const_customizer.conf    connection=${AP_ASIK}[Connection]
    SSH.Execute    cd /ffs/run/simmode && ln -fs *ORAN.xml iphy.xml    connection=${AP_ASIK}[Connection]
    SSH.Disconnect    ${AP_ASIK.Connection}

Disable FW on GNB
    SSH.Connect To    ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Execute     cd /ffs/run/ && mv gNB_swconfig*_ORAN.txt swconfig.txt    connection=${GNB_ASIK}[Connection]
    SSH.Execute    echo "0x1A1300\=0" >> /ffs/run/swconfig.txt
    ...    connection=${GNB_ASIK}[Connection]
    SSH.Execute    echo "0x1A0020\=1" >> /ffs/run/swconfig.txt
    ...    connection=${GNB_ASIK}[Connection]
    SSH.Execute    echo "0x19000A\=1" >> /ffs/run/swconfig.txt
    ...    connection=${GNB_ASIK}[Connection]
    SSH.Execute    echo "0x30000F\=1" >> /ffs/run/swconfig.txt
    ...    connection=${GNB_ASIK}[Connection]
    SSH.Execute    cd /ffs/run/ && crasign swconfig.txt && craverify swconfig.txt swconfig.txt.p7
    ...    connection=${GNB_ASIK}[Connection]
    SSH.Disconnect    ${GNB_ASIK.Connection}

GNB Config Cleanup
    Disable FW on GNB
    SSH.Connect To    ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Execute     rm -rf /ffs/fs*/config/fallbackCause.txt      connection=${GNB_ASIK}[Connection]
    SSH.Execute     rm -rf /ffs/fs*/config/Role.txt      connection=${GNB_ASIK}[Connection]
    SSH.Execute     rm -rf /ffs/fs*/config/SCFC_*.xml      connection=${GNB_ASIK}[Connection]
    SSH.Execute     rm -rf /ffs/fs*/config/model_*.ims2      connection=${GNB_ASIK}[Connection]
    SSH.Execute     rm -rf /ffs/fs*/config/NCF.xml      connection=${GNB_ASIK}[Connection]
    SSH.Execute     rm -rf /ffs/fs*/config/hwf.bin.gz   connection=${GNB_ASIK}[Connection]
    SSH.Execute     rm -rf /ffs/fs*/boardcfg/1/C/mcu-aspa/boot/const_customizer.conf
    ...    connection=${GNB_ASIK}[Connection]
    SSH.Execute     rm -rf /ffs/fs*/config/IPAddressSet.txt    connection=${GNB_ASIK}[Connection]
    SSH.Execute     rm -rf /ffs/fs*/config/FRIps.txt    connection=${GNB_ASIK}[Connection]
    ...    connection=${GNB_ASIK}[Connection]
    SSH.Disconnect    ${GNB_ASIK.Connection}

Netconf User Addition
    Wait Until Keyword Succeeds    2min    10sec    admin.Connect To    bts_host=${GNB_ASIK.Ip}
    admin.Configure Netconf Radio Management    authentication_method=NoAuthentication
    ...    id=1    name=${oran_user}     password=${oran_pwd}    dist_name=${EMPTY}
    ...    unsecure_ciphering=False     format=${EMPTY}    value=${EMPTY}
    admin.Teardown

Apply ORAN SCF
    Modify SCF Vlan    input_scf=${gnb_scf_file}    output_scf=${gnb_scf_file}
    ${command}=    Catenate    cd ${CURDIR}/../scripts/ &&
    ...       python -c
    ...       "import scf_comm_script;scf_comm_script.scf_comm('${GNB_BTS.Ip}', '${gnb_scf_file}')"
    Run    ${command}
    Run     cp ${gnb_scf_file} ${EXECDIR}/logs/gnb_coam_scf.xml

Modify SCF Vlan
    [Arguments]    ${input_scf}=${input_scf}    ${output_scf}=${output_scf}    ${dist}=${dist}    ${ID}=${ID}
    ${command}    Catenate    sed -nr 's/^.*vlan_id=//p' ${init_file} | cut -d')' -f1 | head -n 1
    ${vlan_id}    Run    ${command}
    scf.load_scf    ${input_scf}
    Run Keyword    scf.modify_scf_element    value=${vlan_id}    dist_name=${dist}    p_name=${ID}
    scf.save_scf    ${output_scf}

Verify BBMOD Status
   Wait Until Keyword Succeeds    5min    10sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
   ${bts_hw_info}    CoamAdmin.Get Bts Info
   ${bbmod_state}    Set Variable    ${bts_hw_info['basebandModules'][0]['status']['operationalState']}
   Should Be Equal As Strings    ${bbmod_state}    enabled    ignore_case=${TRUE}
   CoamAdmin.Teardown

Send Log To File
    [Arguments]         ${log_text}
    Append To File    /home/ute/logs/ap_testcase_log.txt    ${log_text}\n

IQ log Capture
    SSH.Connect To   ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...    alias=middle
    ${grep_ipv6_cmd} =    Set Variable    ifconfig etha01.212 | grep inet6 | grep -i global | grep -oE '(\\w{1,4}\\:){7}(\\w{1,4})'
    SSH.Connect To    ${gNB_bsh_ip_1_1}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    proxy=middle    alias=target
    ${slave_ip}=    ssh.Execute    command=${grep_ipv6_cmd}    connection=target
    ${slave_ip}=    Strip String    ${slave_ip}
    Set Suite Variable    ${slave_ip}
    SSH.Connect To    ${GNB_ASIK.Ip}     ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=middle
    SSH.Force Reconnect    middle
    SSH.Connect To    ${slave_ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...    alias=target    proxy=middle

Suspicious IQ Capture
    IQ log Capture
    SSH.Send Command    command=${Suspicious_IQ1}    timeout=60    connection=target
    ${grep_ipv6_cmd1} =    Set Variable    ifconfig etha01.212 | grep inet6 | grep -i global | grep -oE '(\\w{1,4}\\:){7}(\\w{1,4})'
    SSH.Connect To    ${gNB_bsh_ip_1_2}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    proxy=middle    alias=target
    ${slave_ip2} =    ssh.Execute    command=${grep_ipv6_cmd}    connection=target
    ${slave_ip2}=    Strip String    ${slave_ip2}
    Set Suite Variable    ${slave_ip2}
    SSH.Connect To    ${GNB_ASIK.Ip}     ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=endtarget
    SSH.Force Reconnect    target
    SSH.Connect To    ${slave_ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...    alias=endtarget    proxy=target
    SSH.Send Command    command=${Suspicious_IQ2}    timeout=60    connection=target
    ssh.Disconnect    endtarget
    ssh.Disconnect    target
    ssh.Disconnect    middle

Start IQ log Capture
    IQ log Capture
    SSH.Send Command    command=${IQ_Path}    timeout=60    connection=target
    SSH.Send Command    command=${IQ_sed1}    timeout=60    connection=target
    SSH.Send Command    command=${IQ_sed2}    timeout=60    connection=target
    SSH.Send Command    command=${IQ_sed3}    timeout=60    connection=target
    SSH.Send Command    command=${IQ_sed4}    timeout=60    connection=target
    SSH.Send Command    command=${IQ_etcpath}    timeout=60    connection=target
    SSH.Send Command    command=${IQ_Start}    timeout=60    connection=target
    sleep    15s

Stopping IQ logs
    ${exclude_pcap}=   Check If PCAP Is To Be Excluded
    ${exclude_pcap}=   Set Variable if    '${test_state}' == 'True'    0    ${exclude_pcap}
    IQ log Capture
    SSH.Send Command    command=${IQ_Stop}    timeout=60    connection=target
    sleep    ${IQ_Stop_Time}
    Collect & Stop IQ log Collection    ${exclude_pcap}

Stop IQ log Capture
    Run Keyword If    '${IQ_ENABLE_FLAG}' == 'True'
    ...    Stopping IQ logs

Collect & Stop IQ log Collection
    [Arguments]    ${exclude_pcap}=0
    Run    mkdir -p ${vm_logdir}/IQ
    SSH.Send Command    command=${IQ_copy}    timeout=60    connection=target
    Run Keyword If     ${exclude_pcap} == 1
    ...    Run Keywords    SSH.Execute    command=rm -rf /ram/L1Log/Snapshot/slot_*/soc_*/*    connection=target
    ...    AND    Return From Keyword
    ${files}=    SSH.Execute    command=cd /ram/L1Log/Snapshot/slot_*/soc_*/ && ls *bin    connection=target
    ${files}=    Split String    ${files}
    FOR  ${file}  IN  @{files}
        ssh.Download File    /tmp/${file}    ${vm_logdir}/IQ/${file}    connection=target
    END
    SSH.Send Command    command=mkdir /tmp/mine;cd /tmp/mine/;lococtl .    timeout=60    connection=target
	sleep     60s
    SSH.Send Command    command=cd /tmp/mine/AntennaSnapshotFiles;lococtl . 'IQ_SAVE_BUFFER';    timeout=60    connection=target
    ssh.execute    cd /tmp/;tar czvf /ffs/run/logs/SuspiciousIQ.tgz mine/   connection=target
    sleep    60s
	ssh.Download File       /ffs/run/logs/SuspiciousIQ.tgz
    ...                     ${vm_logdir}/SuspiciousIQ.tgz     connection=middle
    ssh.Disconnect    target
    ssh.Disconnect    middle
    ZIP IQ Logs

ZIP IQ Logs
    Run    cd ${vm_logdir}; tar czvf ${vm_logdir}/IQ/gNodeB_eCPRI_IQ.tgz IQ/
    sleep    60s
    Run    rm -rf ${vm_logdir}/IQ/*.bin

Set IQ Flags For Selected Variants
    ${valid_config}=    Catenate    '${apConfiguration}' in    "@{IQ_Variants}"
    Run Keyword If    ${valid_config} and '${AP_P1Perf}' != 'True' and '${AP_P1Perf_mmwv}' != 'True'
    ...    Set Suite Variable    ${IQ_ENABLE_FLAG}    True

Test Teardown for UE_Register
    ${exclude_pcap}=    Check If PCAP Is To Be Excluded
    ${test_state}=   Set Variable If   ${exclude_pcap} == 0    True
    Set Suite Variable    ${test_state}
    Run Keyword if    '${TEST STATUS}' != 'PASS' and '${Collect_Sosreport}' == 'True' and '${QT_CONFIG}' == 'True'    Collect Sosreport and Snapshot
    Run Keyword If    "${apConfiguration}" == "fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO"
    ...               Run Keywords    Run Keyword and Ignore Error    Stopping IQ capture    AND
    ...               Run Keyword If     '${QT_CONFIG}' == 'True' and '${L2PS_TTI_TRACE}' == 'True'    Collect L2PS TTI Traces    INIT_TTI    AND
    ...               Run Keyword If    '${TTI_TRACE}' == 'True'    Stop and Copy TTI Traces    init    ${exclude_pcap}    AND
    ...               Stop Attach and Data Traffic TCPDUMP    init

Pre_Check
    Run Keyword and Ignore Error    Stopping IQ capture
    Run Keyword If    '${MAX_THROUGHPUT}' == 'True' or '${apConfiguration}' == 'fs_tdd_sansa_eCpri_cmwv_LO_AP_LO_ORAN'
    ...      Stop Attach and Data Traffic TCPDUMP    init   ELSE    Log To Console    Skipping TCP DUMP for MAX THPT to Collect EM Logs
    ${exclude_pcap}=   Check If PCAP Is To Be Excluded
    ${exclude_pcap}=   Set Variable if    '${test_state}' == 'True'    0    ${exclude_pcap}
    Run Keyword If     '${QT_CONFIG}' == 'True' and '${L2PS_TTI_TRACE}' == 'True'    Collect L2PS TTI Traces    INIT_TTI
    Run Keyword if    '${TEST STATUS}' != 'PASS' and '${Collect_Sosreport}' == 'True' and '${QT_CONFIG}' == 'True'    Collect Sosreport and Snapshot
    Run Keyword If    '${TTI_TRACE}' == 'True'    Stop and Copy TTI Traces    init    ${exclude_pcap}
    Run Keyword if    '${CARR_AGGR}' == 'True'    Check Scell addition for Carrier Aggregation success

Generate SA Traffic for High Throughput
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Generate SA TDD FDD Traffic
    ...    ELSE    Generate SA Traffic QT
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'
    ...    Generate SA Traffic for Highthroughput QT    ${ueid}    ${DL_TCP_data_rate}    dl
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'
    ...    Generate SA Traffic for Highthroughput QT    ${ueid}    ${UL_TCP_data_rate}    ul

Generate SA Traffic for High Throughput Seq Flow
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Generate SA TDD FDD Traffic Seq Flow
    ...    ELSE    Generate SA Traffic QT SEQ

Generate SA Traffic for High Throughput for 6G
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Generate SA TDD FDD Traffic
    ...    ELSE    Generate SA Traffic QT for 6G
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'
    ...    Generate SA Traffic for Highthroughput QT    ${ueid}    ${DL_TCP_data_rate}    dl
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'
    ...    Generate SA Traffic for Highthroughput QT    ${ueid}    ${UL_TCP_data_rate}    ul

Generate SA Traffic QT
    Highthroughput datarates for SA QT
    Generate SA Traffic for Highthroughput QT    ${ueid}    ${traffic_dl_rate}    dl
    Generate SA Traffic for Highthroughput QT    ${ueid}    ${traffic_ul_rate}    ul

Generate SA Traffic QT SEQ
    Highthroughput datarates for SA QT
    Run Keyword If    '${TRF_UL}' == 'True'    Generate SA Traffic for Uplink
    Run Keyword If    '${TRF_DL}' == 'True'    Generate SA Traffic for Downlink

Generate SA Traffic for Downlink
    Generate SA Traffic for Highthroughput QT    ${ueid}    ${traffic_dl_rate}    dl
    Sleep    ${duration}
    Log To Console    Running Traffic for ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    Log Bearer stats without verification
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s
    ...    Verify UE_stats Throughput Average Rate for SA_DL
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf
    Stop SA Max throughput traffic
    Run keyword if    '${status}' == 'False'    Fail    msg=SA Traffic Failed

Generate SA Traffic for Uplink
    Generate SA Traffic for Highthroughput QT    ${ueid}    ${traffic_ul_rate}    ul
    Sleep    ${duration}
    Log To Console    Running Traffic for ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    Log Bearer stats without verification
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s
    ...    Verify UE_stats Throughput Average Rate for SA_UL
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf
    Stop SA Max throughput traffic
    Run keyword if    '${status}' == 'False'    Fail    msg=SA Traffic Failed

Generate SA Traffic QT for 6G
    Highthroughput datarates for SA QT
    Generate SA Traffic for Highthroughput QT for 6G DL    ${ueid}    ${traffic_dl_rate}    dl
    Generate SA Traffic for Highthroughput QT for 6G UL  ${ueid}    ${traffic_ul_rate}    ul

Generate SA Traffic for Highthroughput QT for 6G DL
    [Arguments]    ${ue_id}    ${rate_mbps}    ${dir}
    ${num_trf}    ${last_trf_rate}=    Calculate number of Traffic Id    ${rate_mbps}
    ${num_trf_for_loop}=    Evaluate    int(${num_trf}+1)
    FOR   ${trf_id}    IN RANGE    1    ${num_trf_for_loop}
    Run Keyword If    ${trf_id}<${num_trf}    Generate SA Traffic for Max Data rate Supported for DL    ${ue_id}
    ...    ${trf_id}    ${num_trf}    ${dir}
    Run Keyword If    ${trf_id}==${num_trf}    Generate SA Traffic for Last Data rate    ${ue_id}    ${trf_id}
    ...    ${num_trf}    ${dir}    ${last_trf_rate}
    END

Generate SA Traffic for Highthroughput QT for 6G UL    # should be run in AP egate.
    [Arguments]    ${ue_id}    ${rate_mbps}    ${dir}
    ${num_trf}    ${last_trf_rate}=    Calculate number of Traffic Id    ${rate_mbps}
    ${num_trf_for_loop}=    Evaluate    int(${num_trf}+1)
    FOR   ${trf_id}    IN RANGE    1    ${num_trf_for_loop}
    Run Keyword If    ${trf_id}<${num_trf}    Generate SA Traffic for Max Data rate Supported for UL   ${ue_id}
    ...    ${trf_id}    ${num_trf}    ${dir}
    Run Keyword If    ${trf_id}==${num_trf}    Generate SA Traffic for Last Data rate for UL    ${ue_id}    ${trf_id}
    ...    ${num_trf}    ${dir}    ${last_trf_rate}
    END

Generate SA Traffic for Max Data rate Supported for DL
    [Arguments]    ${ue_id}    ${trf_id}    ${num_trf}    ${dir}
    wtsrunner.trf_data_start  ue=${ueid}  trf_id=${trf_id}  mbps=${max_data_rate}  dir=${dir}  pdu=${Pdu_session_ID}
    ...    qfi=${qfi_id_1}  size=${burst_size}
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'
    ...    Generate SA TCP Traffic for Max Data rate Supported   ${ue_id}    ${trf_id}    ${num_trf}    ${dir}

Generate SA Traffic for Max Data rate Supported for UL    # should be in AP egate
    [Arguments]    ${ue_id}    ${trf_id}    ${num_trf}    ${dir}
    ExternalAPConnect.Connect Ap Egate To External Ap Server    ${JUMP_HOST}    ${JUMP_USERNAME}
    ...    ${JUMP_PASSWORD}    ${JUMP_PORT}
    ${cmd}=    Catenate    trf_data_start ue=${ueid} trf_id=${trf_id} mbps=${max_data_rate} dir=${dir}
    ...    pdu=${Pdu_session_ID} qfi=${qfi_id_1} size=${burst_size}
    ExternalAPConnect.Execute Ap Egate Command    ${cmd}
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'
    ...    Generate SA TCP Traffic for Max Data rate Supported   ${ue_id}    ${trf_id}    ${num_trf}    ${dir}
    [Teardown]    ExternalAPConnect.Disconnect External Ap Server

Generate NSA Traffic for High Throughput
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${duration}
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Generate NSA TDD FDD Traffic
    ...    ELSE    Generate NSA Traffic QT
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'
    ...    Generate NSA Traffic for Highthroughput QT	  ${UE_ID_SANSA}    ${DL_TCP_data_rate}    dl
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'
    ...    Generate NSA Traffic for Highthroughput QT	  ${UE_ID_SANSA}    ${UL_TCP_data_rate}    ul

Generate NSA Traffic for High Throughput Seq Flow
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Generate NSA TDD FDD Traffic Seq Flow
    ...    ELSE    Generate NSA Traffic QT SEQ

Generate NSA Traffic QT SEQ
    Highthroughput datarates for NSA QT
    Run Keyword If    '${TRF_UL}' == 'True'    Generate NSA Traffic for Uplink
    Run Keyword If    '${TRF_DL}' == 'True'    Generate NSA Traffic for Downlink

Generate NSA Traffic for Uplink
    Generate NSA Traffic for Highthroughput QT	  ${UE_ID_SANSA}    ${traffic_dl_rate}    dl
    Log To Console    Running Traffic for ${duration}
    Sleep    ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s
    ...    Verify UE_stats Throughput Average Rate for NSA_UL
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf
	Run Keyword If    '${HO_flag}' == 'True'    UE Attach NSA HO TDD FDD
    Stop NSA Max throughput traffic
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run keyword if    '${status}' == 'False'    Fail    msg=NSA Traffic Failed

Generate NSA Traffic for Downlink
    Generate NSA Traffic for Highthroughput QT	  ${UE_ID_SANSA}    ${traffic_dl_rate}    dl
    Log To Console    Running Traffic for ${duration}
    Sleep    ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s
    ...    Verify UE_stats Throughput Average Rate for NSA_DL
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf
	Run Keyword If    '${HO_flag}' == 'True'    UE Attach NSA HO TDD FDD
    Stop NSA Max throughput traffic
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run keyword if    '${status}' == 'False'    Fail    msg=NSA Traffic Failed

Generate NSA Traffic QT
    Highthroughput datarates for NSA QT
    Generate NSA Traffic for Highthroughput QT    ${UE_ID_SANSA}    ${traffic_dl_rate}    dl
    Generate NSA Traffic for Highthroughput QT	  ${UE_ID_SANSA}    ${traffic_ul_rate}    ul

Generate SA TDD FDD Traffic
    Highthroughput datarates for SA TDD_FDD QT
    Generate SA Traffic for Highthroughput QT    ${sa_ueid_tdd_HTpQT}    ${traffic_sa_tdd_ul_rate}    ul
    Generate SA Traffic for Highthroughput QT    ${sa_ueid_tdd_HTpQT}    ${traffic_sa_tdd_dl_rate}    dl
    Generate SA Traffic for Highthroughput QT    ${sa_ueid_fdd_HTpQT}    ${traffic_sa_fdd_ul_rate}    ul
    Generate SA Traffic for Highthroughput QT    ${sa_ueid_fdd_HTpQT}    ${traffic_sa_fdd_dl_rate}    dl

Generate SA TDD FDD Traffic Seq Flow
    Highthroughput datarates for SA TDD_FDD QT
    Run Keyword If    '${TRF_UL}' == 'True'    Generate SA Traffic for TDD FDD Uplink
    Run Keyword If    '${TRF_DL}' == 'True'    Generate SA Traffic for TDD FDD Downlink

Generate SA Traffic for TDD FDD Uplink
    Log Bearer stats without verification SA Sequential
    Generate SA Traffic for Highthroughput QT    ${sa_ueid_tdd_HTpQT}    ${traffic_sa_tdd_ul_rate}    ul
    Generate SA Traffic for Highthroughput QT    ${sa_ueid_fdd_HTpQT}    ${traffic_sa_fdd_ul_rate}    ul
    Log To Console    Running Traffic for ${duration}
    Sleep    ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    Log Bearer stats without verification SA Sequential
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s
    ...    Verify UE_stats Throughput Average Rate for SA_UL
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf
    Stop SA Max throughput traffic
    Run keyword if    '${status}' == 'False'    Fail    msg=SA Traffic Failed

Generate SA Traffic for TDD FDD Downlink
    Log Bearer stats without verification SA Sequential
    Generate SA Traffic for Highthroughput QT    ${sa_ueid_tdd_HTpQT}    ${traffic_sa_tdd_dl_rate}    dl
    Generate SA Traffic for Highthroughput QT    ${sa_ueid_fdd_HTpQT}    ${traffic_sa_fdd_dl_rate}    dl
    Log To Console    Running Traffic for ${duration}
    Sleep    ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    Log Bearer stats without verification SA Sequential
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s
    ...    Verify UE_stats Throughput Average Rate for SA_DL
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf
    Stop SA Max throughput traffic
    Run keyword if    '${status}' == 'False'    Fail    msg=SA Traffic Failed

Verify UE_stats Throughput Average Rate for SA_UL
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Verify UE_stats Average Rate for SA_TDD_FDD_UL
    ...    ELSE    Verify UE_stats Average Rate for SA_UL    ${UE_ID}    ${traffic_ul_rate}

Verify UE_stats Average Rate for SA_TDD_FDD_UL
    Verify UE_stats Average Rate for SA_UL    ${sa_ueid_tdd_HTpQT}    ${traffic_sa_tdd_ul_rate}
    Verify UE_stats Average Rate for SA_UL    ${sa_ueid_fdd_HTpQT}    ${traffic_sa_fdd_ul_rate}

Verify UE_stats Throughput Average Rate for SA_DL
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Verify UE_stats Average Rate for SA_TDD_FDD_DL
    ...    ELSE    Verify UE_stats Average Rate for SA_DL    ${UE_ID}    ${traffic_dl_rate}

Verify UE_stats Average Rate for SA_TDD_FDD_DL
    Verify UE_stats Average Rate for SA_DL    ${sa_ueid_tdd_HTpQT}    ${traffic_sa_tdd_dl_rate}
    Verify UE_stats Average Rate for SA_DL    ${sa_ueid_fdd_HTpQT}    ${traffic_sa_fdd_dl_rate}

Generate NSA TDD FDD Traffic
    Highthroughput datarates for NSA TDD_FDD QT
    Generate NSA Traffic for Highthroughput QT    ${nsa_ueid_tdd_HTpQT}    ${traffic_nsa_tdd_ul_rate}    ul
    Generate NSA Traffic for Highthroughput QT    ${nsa_ueid_tdd_HTpQT}    ${traffic_nsa_tdd_dl_rate}    dl
    Generate NSA Traffic for Highthroughput QT    ${nsa_ueid_fdd_HTpQT}    ${traffic_nsa_fdd_ul_rate}    ul
    Generate NSA Traffic for Highthroughput QT    ${nsa_ueid_fdd_HTpQT}    ${traffic_nsa_fdd_dl_rate}    dl

Generate NSA TDD FDD Traffic Seq Flow
    Highthroughput datarates for NSA TDD_FDD QT
    Run Keyword If    '${TRF_UL}' == 'True'    Generate NSA Traffic for TDD FDD Uplink
    Run Keyword If    '${TRF_DL}' == 'True'    Generate NSA Traffic for TDD FDD Downlink

Generate NSA Traffic for TDD FDD Uplink
    Log Bearer stats without verification NSA UL
    Generate NSA Traffic for Highthroughput QT    ${nsa_ueid_tdd_HTpQT}    ${traffic_nsa_tdd_ul_rate}    ul
    Generate NSA Traffic for Highthroughput QT    ${nsa_ueid_fdd_HTpQT}    ${traffic_nsa_fdd_ul_rate}    ul
    Log To Console    Running Traffic for ${duration}
    Sleep    ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s
    ...    Verify UE_stats Throughput Average Rate for NSA_UL
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf
	Run Keyword If    '${HO_flag}' == 'True'    UE Attach NSA HO TDD FDD
    Log Bearer stats without verification NSA UL
    Stop NSA Max throughput traffic
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run keyword if    '${status}' == 'False'    Fail    msg=NSA Traffic Failed

Generate NSA Traffic for TDD FDD Downlink
    Log Bearer stats without verification NSA DL
    Generate NSA Traffic for Highthroughput QT    ${nsa_ueid_tdd_HTpQT}    ${traffic_nsa_tdd_dl_rate}    dl
    Generate NSA Traffic for Highthroughput QT    ${nsa_ueid_fdd_HTpQT}    ${traffic_nsa_fdd_dl_rate}    dl
    Log To Console    Running Traffic for ${duration}
    Sleep    ${duration}
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    ${status}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min    12s
    ...    Verify UE_stats Throughput Average Rate for NSA_DL
    Run Keyword If    '${status}' == 'False'    Collection of em traces and em Perf
	Run Keyword If    '${HO_flag}' == 'True'    UE Attach NSA HO TDD FDD
    Log Bearer stats without verification NSA DL
    Stop NSA Max throughput traffic
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run keyword if    '${status}' == 'False'    Fail    msg=NSA Traffic Failed

Verify UE_stats Throughput Average Rate for NSA_UL
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Verify UE_stats Average Rate for NSA_TDD_FDD_UL
    ...    ELSE    Verify UE_stats Average Rate for NSA_UL    ${UE_ID_SANSA}    ${traffic_ul_rate}

Verify UE_stats Average Rate for NSA_TDD_FDD_UL
    Verify UE_stats Average Rate for NSA_UL    ${nsa_ueid_tdd_HTpQT}    ${traffic_nsa_tdd_ul_rate}
    Verify UE_stats Average Rate for NSA_UL    ${nsa_ueid_fdd_HTpQT}    ${traffic_nsa_fdd_ul_rate}

Verify UE_stats Throughput Average Rate for NSA_DL
    Run Keyword if    '${FR1_TDD_FDD}' == 'True' or '${ORAN_TDD_FDD}' == 'True'    Verify UE_stats Average Rate for NSA_TDD_FDD_DL
    ...    ELSE    Verify UE_stats Average Rate for NSA_DL    ${UE_ID_SANSA}    ${traffic_dl_rate}

Verify UE_stats Average Rate for NSA_TDD_FDD_DL
    Verify UE_stats Average Rate for NSA_DL    ${nsa_ueid_tdd_HTpQT}    ${traffic_nsa_tdd_dl_rate}
    Verify UE_stats Average Rate for NSA_DL    ${nsa_ueid_fdd_HTpQT}    ${traffic_nsa_fdd_dl_rate}

Highthroughput datarates for SA QT
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sansa_eCpri_cmwv_LO_AP_LO'
    ...    Highthroughput for QT FR1 SA
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO'
    ...    Highthroughput for QT FR2 SA
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_GMC'
    ...    Highthroughput for QT FR2 SA
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_2S_4CC'
    ...    Highthroughput for QT FR2 SA
	Run Keyword If    '${apConfiguration}' == 'fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_GMC'
    ...    Highthroughput for QT FR1 SA
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO'
    ...    MaxThroughput for MP AP LO TDD
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_CA_HO'
    ...    Highthroughput for QT FR2 SA
    Run Keyword If    '${apConfiguration}' == 'fs_fdd_sansa_cpri_cmwv_LO_AP_LO_2S_1CC'
    ...    Highthroughput for QT FR1 FDD SA
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sa_eCpri_cmwv_E_AP_E_6G'
    ...    MaxThroughput for 6G SA TDD
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sansa_ecpri_dRNIC_1vDU_P_AP_LO_SWFH_cmwv'
    ...    MaxThroughput for VRAN SA TDD
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO_CIT'
    ...    MaxThroughput for MP AP LO TDD

Highthroughput datarates for NSA QT
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sansa_eCpri_cmwv_LO_AP_LO'
    ...    Highthroughput for QT FR1 NSA
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_nsa_eCpri_mmwv_LO_AP_LO'
    ...    Highthroughput for QT FR2 NSA
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_nsa_eCpri_mmwv_LO_AP_LO_GMC'
    ...    Highthroughput for QT FR2 NSA
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO'
    ...    Highthroughput for QT FR2 NSA
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_2S_4CC'
    ...    Highthroughput for QT FR2 NSA
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_CA_HO'
    ...    Highthroughput for QT FR2 NSA
    Run Keyword If    '${apConfiguration}' == 'fs_fdd_sansa_cpri_cmwv_LO_AP_LO_2S_1CC'
    ...    Highthroughput for QT FR1 FDD NSA
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sansa_ecpri_dRNIC_1vDU_P_AP_LO_SWFH_cmwv'
    ...    MaxThroughput for VRAN NSA TDD

Generate SA Traffic for Highthroughput QT
    [Arguments]    ${ue_id}    ${rate_mbps}    ${dir}
    ${num_trf}    ${last_trf_rate}=    Calculate number of Traffic Id    ${rate_mbps}
    ${num_trf_for_loop}=    Evaluate    int(${num_trf}+1)
    FOR   ${trf_id}    IN RANGE    1    ${num_trf_for_loop}
    Run Keyword If    ${trf_id}<${num_trf}    Generate SA Traffic for Max Data rate Supported    ${ue_id}
    ...    ${trf_id}    ${num_trf}    ${dir}
    Run Keyword If    ${trf_id}==${num_trf}    Generate SA Traffic for Last Data rate    ${ue_id}    ${trf_id}
    ...    ${num_trf}    ${dir}    ${last_trf_rate}
    END

Generate SA Traffic for Max Data rate Supported
    [Arguments]    ${ue_id}    ${trf_id}    ${num_trf}    ${dir}
    wtsrunner.trf_data_start  ue=${ueid}  trf_id=${trf_id}  mbps=${max_data_rate}  dir=${dir}  pdu=${Pdu_session_ID}
    ...    qfi=${qfi_id_1}  size=${burst_size}
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'
    ...    Generate SA TCP Traffic for Max Data rate Supported   ${ue_id}    ${trf_id}    ${num_trf}    ${dir}

Generate SA TCP Traffic for Max Data rate Supported
    [Arguments]    ${ue_id}    ${trf_id}    ${num_trf}    ${dir}
    Log    ${num_trf}!!!
    wtsrunner.trf_data_start  ue=${ueid}  trf_id=${trf_id}  mbps=${max_data_rate}  dir=${dir}  pdu=${Pdu_session_ID}
    ...     qfi=${qfi_id_2}  size=${burst_size}  protocol=tcp

Generate SA Traffic for Last Data rate
    [Arguments]    ${ue_id}    ${trf_id}    ${num_trf}    ${dir}    ${last_trf_rate}
    wtsrunner.trf_data_start  ue=${ueid}  trf_id=${trf_id}  mbps=${last_trf_rate}  dir=${dir}  pdu=${Pdu_session_ID}
    ...    qfi=${qfi_id_1}  size=${burst_size}
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'
    ...    Generate SA TCP Traffic for Last Data rate   ${ue_id}    ${trf_id}    ${num_trf}    ${dir}    ${last_trf_rate}

Generate SA Traffic for Last Data rate for UL
    [Arguments]    ${ue_id}    ${trf_id}    ${num_trf}    ${dir}    ${last_trf_rate}
    ExternalAPConnect.Connect Ap Egate To External Ap Server    ${JUMP_HOST}    ${JUMP_USERNAME}
    ...    ${JUMP_PASSWORD}    ${JUMP_PORT}
    ${cmd}=    Catenate    trf_data_start ue=${ueid} trf_id=${trf_id} mbps=${last_trf_rate} dir=${dir}
    ...    pdu=${Pdu_session_ID} qfi=${qfi_id_1} size=${burst_size}
    ExternalAPConnect.Execute Ap Egate Command    ${cmd}
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'
    ...    Generate SA TCP Traffic for Last Data rate   ${ue_id}    ${trf_id}    ${num_trf}    ${dir}    ${last_trf_rate}
    [Teardown]    ExternalAPConnect.Disconnect External Ap Server

Generate SA TCP Traffic for Last Data rate
    [Arguments]    ${ue_id}    ${trf_id}    ${num_trf}    ${dir}    ${last_trf_rate}
    Log    ${num_trf}!!!
    wtsrunner.trf_data_start  ue=${ueid}  trf_id=${trf_id}  mbps=${last_trf_rate}  dir=${dir}  pdu=${Pdu_session_ID}
    ...    qfi=${qfi_id_2}  size=${burst_size}    protocol=tcp

Generate NSA Traffic for Highthroughput QT
    [Arguments]    ${ue_id}    ${rate_mbps}    ${dir}
    ${num_trf}    ${last_trf_rate}=    Calculate number of Traffic Id    ${rate_mbps}
    ${num_trf_for_loop}=    Evaluate    int(${num_trf}+1)
    FOR   ${trf_id}    IN RANGE    1    ${num_trf_for_loop}
    Run Keyword If    ${trf_id}<${num_trf}    Generate NSA Traffic for Max Data rate Supported    ${ue_id}
    ...    ${trf_id}    ${num_trf}    ${dir}
    Run Keyword If    ${trf_id}==${num_trf}    Generate NSA Traffic for Last Data rate    ${ue_id}    ${trf_id}
    ...    ${num_trf}    ${dir}    ${last_trf_rate}
    END

Generate NSA Traffic for Max Data rate Supported
    [Arguments]    ${ue_id}    ${trf_id}    ${num_trf}    ${dir}
    wtsrunner.trf_data_start  ue=${ueid}  trf_id=${trf_id}  id=${Bearer_ID}  mbps=${max_data_rate}  dir=${dir}  size=${burst_size}
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'
    ...    Start NSA TCP Traffic for Max Data Rate supported on TRF Cls   ${ue_id}    ${trf_id}    ${num_trf}    ${dir}

Start NSA TCP Traffic for Max Data Rate supported on TRF Cls
    [Arguments]    ${ue_id}    ${trf_id}    ${num_trf}    ${dir}
    Log    ${num_trf}!!!
	wtsrunner.trf_data_start  ue=${ueid}  trf_id=${trf_id}  id=${Bearer_ID}  mbps=${max_data_rate}
    ...    dir=${dir}  size=${burst_size}  protocol=tcp

Generate NSA Traffic for Last Data rate
    [Arguments]    ${ue_id}    ${trf_id}    ${num_trf}    ${dir}    ${last_trf_rate}
    wtsrunner.trf_data_start  ue=${ueid}  trf_id=${trf_id}  id=${Bearer_ID}  mbps=${last_trf_rate}  dir=${dir}  size=${burst_size}
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'
    ...    Start NSA TCP Traffic for Last Data Rate on TRF Cls   ${ue_id}    ${trf_id}    ${num_trf}    ${dir}    ${last_trf_rate}

Start NSA TCP Traffic for Last Data Rate on TRF Cls
    [Arguments]    ${ue_id}    ${trf_id}    ${num_trf}    ${dir}    ${last_trf_rate}
    Log    ${num_trf}!!!
    wtsrunner.trf_data_start  ue=${ueid}  trf_id=${trf_id}  id=${Bearer_ID}  mbps=${last_trf_rate}  dir=${dir}
    ...    size=${burst_size}  protocol=tcp

Test Setup for SA Traffic
    [Arguments]    ${prefix}=SA_TRF
    [Documentation]    This keyword is used to start the TCPDUMP for SA Traffic
    ...                Modified Date: 26-june-2023
    ...                Last Modified by: m.sangeetha@nokia.com
    Run Keyword If    '${IQ_ENABLE_FLAG}' == 'True'    Run Keyword and Ignore Error    Stopping IQ capture
    Run Keyword if    '${MAX_THROUGHPUT}' == 'True' and '${SA_Traffic_BIP}' == 'True'    Start sosReport Tcpdump    ${prefix}
    Run Keyword If    '${TTI_TRACE}' == 'True'    Start TTI Traces    SA_TRF
    Run Keyword If    '${QT_CONFIG}' == 'True' and '${L2PS_TTI_TRACE}' == 'True'    Start L2PS TTI Traces
    Run Keyword If    '${WTS_UDP_LOG}' == 'True'    Start WTS tcpdump for Traffic    UDP_SA_TRF

Test Teardown for SA Traffic
    [Arguments]    ${prefix}=SA_TRF
    [Documentation]    This keyword is used to stop the TCPDUMP for SA Traffic
    ...                Modified Date: 26-june-2023
    ...                Last Modified by: m.sangeetha@nokia.com
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    ${exclude_pcap}=   Check If PCAP Is To Be Excluded
    Run Keyword If    '${WTS_UDP_LOG}' == 'True'    Stop WTS tcpdump for Traffic    UDP_SA_TRF    ${exclude_pcap}
    Run Keyword if    '${MAX_THROUGHPUT}' == 'True' and '${SA_Traffic_BIP}' == 'True'    Stop Attach and Data Traffic TCPDUMP   ${prefix}
    Run Keyword If     '${QT_CONFIG}' == 'True' and '${L2PS_TTI_TRACE}' == 'True'    Collect L2PS TTI Traces    TTI_SA_TRF
    Run Keyword if    '${TEST STATUS}' != 'PASS' and '${Collect_Sosreport}' == 'True' and '${QT_CONFIG}' == 'True'    Collect Sosreport and Snapshot
    Run Keyword If    '${TTI_TRACE}' == 'True'    Stop and Copy TTI Traces    SA_TRF    ${exclude_pcap}

Test Setup for NSA Traffic
    [Arguments]    ${prefix}=NSA_TRF
    [Documentation]    This keyword is used to start the TCPDUMP for NSA Traffic
    ...                Modified Date: 26-june-2023
    ...                Last Modified by: m.sangeetha@nokia.com
    Run Keyword if    '${MAX_THROUGHPUT}' == 'True' and '${NSA_Traffic_BIP}' == 'True'    Start sosReport Tcpdump    ${prefix}
    Run Keyword If    '${TTI_TRACE}' == 'True'    Start TTI Traces    NSA_TRF
    Run Keyword If     '${QT_CONFIG}' == 'True' and '${L2PS_TTI_TRACE}' == 'True'    Start L2PS TTI Traces
    Run Keyword If    '${WTS_UDP_LOG}' == 'True'    Start WTS tcpdump for Traffic    UDP_NSA_TRF

NSA Traffic Teardown
    Run Keyword If    '${COUNTER_VAL}' == 'True'    QT Traffic Throughput Counter Collection and Validation
    ${exclude_pcap}=   Check If PCAP Is To Be Excluded
    Run Keyword If    '${WTS_UDP_LOG}' == 'True'    Stop WTS tcpdump for Traffic    UDP_NSA_TRF    ${exclude_pcap}
    Run Keyword if    '${MAX_THROUGHPUT}' == 'False'    Stop Attach and Data Traffic TCPDUMP    NSA_TRF
    Run Keyword if    '${MAX_THROUGHPUT}' == 'True' and '${NSA_Traffic_BIP}' == 'True'    Stop Attach and Data Traffic TCPDUMP    NSA_TRF
    Run Keyword If     '${QT_CONFIG}' == 'True' and '${L2PS_TTI_TRACE}' == 'True'    Collect L2PS TTI Traces    TTI_NSA_TRF
    Run Keyword if    '${TEST STATUS}' != 'PASS' and '${Collect_Sosreport}' == 'True' and '${QT_CONFIG}' == 'True'    Collect Sosreport and Snapshot
    Run Keyword If    '${TTI_TRACE}' == 'True'    Stop and Copy TTI Traces    NSA_TRF    ${exclude_pcap}

Collection of em traces and em Perf
    Run Keyword And Ignore Error    Get L2RT container ID
    Run Keyword And Ignore Error    Collection of em traces
    ...    ${TEST_NAME}    ${L2RT_container_ID}
    Run    mv ${EXECDIR}/em_traces/*.tar ${vm_logdir}/
    sleep    30sec
    Run Keyword And Ignore Error    Collection of em perf Stats
    ...    ${TEST_NAME}    ${L2RT_container}
    Run    mv ${EXECDIR}/em_perf_Stats/*.log ${vm_logdir}/

Assign SAUEID for GNB2
    [Documentation]    This keyword assigns SA UE IDs for gNB2 in multiGNB configuration
    ...                Modified Date: 17-Aug-2023
    ...                Last Modified by: ramya.2.k@nokia.com
    @{sa_ueids_gnb2}=   Create List
    FOR    ${value}    IN RANGE    ${component_carrier}+1    ${max_cell_id}+1
       Append To List    ${sa_ueids_gnb2}   ${value}
    END
    [Return]    @{sa_ueids_gnb2}

Assign GWID for GNB2
    [Documentation]    This keyword assigns gwid for SA call on gNB2 in multiGNB configuration
    ...                Modified Date: 17-Aug-2023
    ...                Last Modified by: ramya.2.k@nokia.com
    @{gw_ids_gnb2}=   Create List
    FOR    ${value}    IN RANGE    ${component_carrier}+1    ${max_cell_id}+1
       Append To List    ${gw_ids_gnb2}   ${value}
    END
    [Return]    @{gw_ids_gnb2}

Assign NSAUEID for GNB2
    [Documentation]    This keyword assigns NSA UE ID for gNB2 in multiGNB configuration
    ...                Modified Date: 17-Aug-2023
    ...                Last Modified by: ramya.2.k@nokia.com
    @{nsa_ueids_gnb2}=   Create List
    FOR    ${value}    IN RANGE    ${component_carrier}+11    ${max_cell_id}+11
       Append To List    ${nsa_ueids_gnb2}   ${value}
    END
    [Return]    @{nsa_ueids_gnb2}

Assign Targetcell for GNB2
    [Documentation]    This keyword assigns Target cell ID for NSA call on gNB2 in multiGNB configuration
    ...                Modified Date: 17-Aug-2023
    ...                Last Modified by: ramya.2.k@nokia.com
    @{targetcell_ids_gnb2}=   Create List
    FOR    ${value}    IN RANGE    ${component_carrier}+1    ${max_cell_id}+1
       Append To List    ${targetcell_ids_gnb2}   ${value}
    END
    [Return]    @{targetcell_ids_gnb2}

Collect Snapshot on GNB2
    [Documentation]    This keyword collects BTS snapshot from gNB2 in multiGNB configuration
    ...                Modified Date: 17-Aug-2023
    ...                Last Modified by: ramya.2.k@nokia.com
    SSH.Connect To    ${test_pc2}[addr]
    ...               ${test_pc2}[username]
    ...               ${test_pc2}[password]
    ...               alias=VM2
    ${command}=    Catenate    scp ${CURDIR}/enb_snapshot.robot
    ...            ${test_pc2}[username]@${test_pc2}[addr]:/home/ute/
    Run            ${command}
    ${output}=    Run    ls -la /opt/ute-ca/versions
    ${version}=   Set Variable    ${output.split()[-1]}
    ${command}=    Catenate
    ...    source /opt/ute-ca/versions/${version}/envs/ute-ca-venv/bin/activate &&
    ...    sudo chown -R $USER /opt/ute-ca/versions/${version}/envs/ute-ca-venv/ &&
    ...    pip install robotframework &&
    ...    robot -L TRACE -v enb_ip:192.168.255.129 -v target_file_name:/home/ute/logs/GNB2_snapshot.zip /home/ute/enb_snapshot.robot
    ...    && deactivate
    ${result}=    SSH.Execute    ${command}    VM2
    Log To Console    GNB2 Snapshot is collected Successfully
    ${command}    Catenate    hostname -I | awk '{print $1}'
    ${test_pc1}=    Run    ${command}
    SSH.Execute    scp /home/ute/logs/GNB2_snapshot.zip ute@${test_pc1}:${EXECDIR}/logs    VM2
    SSH.Execute    scp /home/ute/log.html ute@${test_pc1}:${EXECDIR}/logs/gnb2_log.html    VM2
    SSH.Disconnect    VM2

Assign values related to MultiGNB
    [Documentation]    This keyword assigns test PC details and IDs related to gNB2 in multiGNB configuration
    ...                Modified Date: 17-Aug-2023
    ...                Last Modified by: ramya.2.k@nokia.com
    Get Secondary Test PC Data for MultiGNB
    Assign IDs for GNB2

Get Secondary Test PC Data for MultiGNB
    [Documentation]    This keyword gets test PC details for GNB2 from init.py file
    ...                Modified Date: 17-Aug-2023
    ...                Last Modified by: ramya.2.k@nokia.com
    ${hostname}=    Get Hostname Details
    ${init_file}=   Get Init File Details for CA     ${ute_ca_logs_path}    __init__.py    ${hostname}
    ${cloned_init_file}=    Run Keyword If    '${init_file}' == 'FAIL'
    ...   Clone Testline Configuration Repo    ${hostname}
    Run Keyword If    '${init_file}' != 'FAIL'    Set Secondary Test PC Credentials for MultiGNB    ${init_file}
    ...   ELSE    Set Secondary Test PC Credentials for MultiGNB    ${cloned_init_file}

Set Secondary Test PC Credentials for MultiGNB
    [Documentation]    This keyword assigns test PC details related to gNB2
    ...                Modified Date: 17-Aug-2023
    ...                Last Modified by: ramya.2.k@nokia.com
    [Arguments]    ${init_file}
    ${ip_addr}=    set variable    ${tl.test_pcs[${test_pc}-${1}].default_ssh_connection_details.addr}
    ${user}=    set variable    ${tl.test_pcs[${test_pc}-${1}].default_ssh_connection_details.username}
    ${passwd}=    set variable    ${tl.test_pcs[${test_pc}-${1}].default_ssh_connection_details.password}
    &{test_pc2}=    Create Dictionary    addr=${ip_addr}    username=${user}    password=${passwd}
    Set Suite Variable     &{test_pc2}
    Set Suite Variable     ${init_file}

Assign IDs for GNB2
    [Documentation]    This keyword assigns SA UEID, GWID, NSA UEID and TargetcellIDs
    ...                required for L3 call on GNB2 in multiGNB configuration
    ...                Modified Date: 17-Aug-2023
    ...                Last Modified by: ramya.2.k@nokia.com
    @{sa_ueids_gnb2}    Assign SAUEID for GNB2
    Set Suite Variable    @{sa_ueids_gnb2}
    @{gw_ids_gnb2}    Assign GWID for GNB2
    Set Suite Variable    @{gw_ids_gnb2}
    @{nsa_ueids_gnb2}    Assign NSAUEID for GNB2
    Set Suite Variable    @{nsa_ueids_gnb2}
    @{targetcell_ids_gnb2}    Assign Targetcell for GNB2
    Set Suite Variable    @{targetcell_ids_gnb2}

Verify RU status from egate log
    ${status}=    Run Keyword And Return Status    Check Pattern in Egate Console Log    UeAppOam RU detection from DU
    Run Keyword If    '${status}' == 'False'	FAIL	Msg=RU not detected by UeAppOam
    ${status}=    Run Keyword And Return Status    Check Pattern in Egate Console Log    RU Synchronized
    Run Keyword If    '${status}' == 'False'    FAIL    Msg=RU not synchronised

Lock Cell In vDU
    [Documentation]    This keyword is used to lock cells in vRAN
    ...                Modified Date: 18-04-2024
    ...                Last Modified by: harsha.harsha@nokia.com
    [Arguments]    @{cell_ids}
    Log to Console    Start locking cells: ${cell_ids}
    Connection to vRAN
    FOR    ${cell_id}    IN    @{cell_ids}
        ${out}    vDU.lock_cells    ${cell_id}
        Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Get state of locking cells    ${out}
    END

Get state of locking cells
    [Arguments]    ${out}
    ${lock_status}    vdu.get_operation_state_of_locking_cells    ${out['id']}
    Should Be Equal As Strings    ${lock_status['status']}    success    ignore_case=${TRUE}

Unlock Cell In vDU
    [Documentation]    This keyword is used to unlock cells in vRAN
    ...                Modified Date: 18-04-2024
    ...                Last Modified by: harsha.harsha@nokia.com
    [Arguments]    @{cell_ids}
    Log to Console    Start unlocking cells: ${cell_ids}
    Connection to vRAN
    FOR    ${cell_id}    IN    @{cell_ids}
        ${out}    vDU.unlock_cells    ${cell_id}
        Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Get state of unlocking cells    ${out}
    END

Get state of unlocking cells
    [Arguments]    ${out}
    ${unlock_status}    vdu.get_operation_state_of_unlocking_cells    ${out['id']}
    Should Be Equal As Strings    ${unlock_status['status']}    success    ignore_case=${TRUE}

Connection to vRAN
    Wait Until Keyword Succeeds    2min    5sec   vDU.connect_to   host=192.168.255.129   port=443   username=Nemuadmin   password=Nokia@123
    ...    secure=True    connection_name=defaultassword=Nokia@123    secure=True    connection_name=default

Disconnect UEs
    [Documentation]    This is a common keyword used to disconnect SA and NSA UEs
    ...                Modified Date: 23-04-2024
    ...                Last Modified by: harsha.harsha@nokia.com
    UE 5GDetach should be Successful
    UE Detach should be Successful
    UE Deregister should be Successful

Parallel Traffic Teardown
    Stop Attach and Data Traffic TCPDUMP    PRL_TRF
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run Keyword if    '${TEST STATUS}' != 'PASS' and '${Collect_Sosreport}' == 'True' and '${QT_CONFIG}' == 'True'    Collect Sosreport and Snapshot

Check LTE cell status
    Wait Until Keyword Succeeds    ${Total_Timeout}    30sec    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    Wait Until Keyword Succeeds    ${Total_Timeout}    30sec    Verify LTE cell is Online
    [Teardown]    CoamAdmin.Teardown

Verify LTE cell is Online
    ${bts_hw_info}                CoamAdmin.Get Bts Info
    ${cells_info}                 CoamAdmin.Get Cells Info
    ${operationalState}    Set Variable    ${bts_hw_info['cells']['lte'][0]['status']['operationalState']}
    Run keyword And Continue On Failure    Should Be Equal    ${operationalState}    enabled

Update sysctl values suitable for Airphone
    [Documentation]    This is a common keyword used to add sysctl for 6G
    ...                Modified Date: 04-03-2025
    ...                Last Modified by: skusuma@nokia.com
    FOR    ${sys_cmd}    IN    @{sysctl_cmds}
        OperatingSystem.Run And Return Rc And Output    ${sys_cmd}
    END

Update UPF IPs for VM
    [Documentation]    This is a common keyword used to add sysctl for 6G
    ...                Modified Date: 04-03-2025
    ...                Last Modified by: skusuma@nokia.com
    FOR    ${UPF_IP}    IN    @{UPF_IP_add_cmds}
        OperatingSystem.Run And Return Rc And Output    ${UPF_IP}
    END

Get Jenkins Environment Variable values
    ${WEEK_NO}    Get Environment Variable    WEEK_NO
    Set Suite Variable    ${WEEK_NO}
    ${BUILD_NO}    Get Environment Variable    BUILD_NUMBER
    Set Suite Variable    ${BUILD_NO}
    ${result}    Catenate    SEPARATOR=_    ${WEEK_NO}    ${BUILD_NO}
    [Return]    ${result}

Set log collection flags false for non Log sync VM
    Set Suite Variable    ${SA_Traffic_BIP}        False
    Set Suite Variable    ${NSA_Traffic_BIP}       False

Check for log sync mount and set log directory
    Check for log sync mount
    Run Keyword if    ${LOG_SYNC} == False and '${apConfiguration}' in "@{AP_P0_CONFIGURATION}"
    ...              Set log collection flags false for non Log sync VM
    Return From Keyword If    ${LOG_SYNC} == False
    ${result}    Get Jenkins Environment Variable values
    Set log directory for LOG_SYNC    ${result}

Check for log sync mount
    ${output}    RUN    df -h | grep "/mnt/log-sync"
    ${status}    Run Keyword And Return Status    Should Contain    ${output}    log-sync
    ${LOG_SYNC_TMP}    Set Variable If    ${status} == True    True    False
    ${RUN_LOGSYNC}    Get Environment Variable    RUN_LOGSYNC    False
    ${RUN_LOGSYNC}    Evaluate    str('${RUN_LOGSYNC}').lower() == 'true'
    ${LOG_SYNC}    Set Variable If    ${LOG_SYNC_TMP} == True and ${RUN_LOGSYNC} == True    True    False
    set suite variable    ${LOG_SYNC}

Set log directory for LOG_SYNC
    [Arguments]    ${result}
    ${log_folder}=    Create HASH Folder for LOG_SYNC    '${result}'
    Set Suite Variable    ${log_folder}
    IF  ${LOG_SYNC} == True
        Set Suite Variable    ${vm_logdir}    /mnt/log-sync/${log_folder}/rotta_logs
    ELSE
        Set Suite Variable    ${vm_logdir}    ${EXECDIR}/logs
    END
    RUN    mkdir -p ${vm_logdir}
    Run Keyword if    ${LOG_SYNC} == True    Run    ln -s ${vm_logdir} ${EXECDIR}/current_log_sync

Create HASH Folder for LOG_SYNC
    [Arguments]    ${result}
    ${hash_name}=    Evaluate    hashlib.sha256(${result}.encode()).hexdigest()    modules=hashlib
    ${half_length}=    Evaluate    len('${hash_name}') // 2
    ${hash_folder}=    Set Variable    ${hash_name}[:${half_length}]
    Create File     ${EXECDIR}/${LOG_SYNC_FILE}     ${hash_folder}
    [Return]    ${hash_folder}

Test Setup for Parallel Traffic
    [Arguments]    ${prefix}=PRL_TRF
    [Documentation]    This keyword is used at the Testcase level to stop sos report TCPDUMP
    ...                and start  traffic TCPDUMP  for SANSA variants
    ...                Modified Date: 3-mar-2025
    ...                Last Modified by: abhishek.p@nokia.com
    ${exclude_pcap}=   Set Variable If   '${CONDITIONAL_LOGGING}' == 'True'   1   0
    Run Keyword if    '${MAX_THROUGHPUT}' == 'True'    Log To Console    Skipping TCP DUMP for MAX THPT to Collect EM Logs
    ...       ELSE        Start Attach and Data Traffic TCPDUMP    ${prefix}

Create Log folder
    RUN    mkdir -p ${vm_logdir}
    RUN    mkdir -p ${EXECDIR}/logs

Get all cells from BTS
     admin.Setup admin
     ${cell_details}=    admin.Get cells info
     ${cells_info}=    Set Variable    ${cell_details}
     ${nrcell_distnames}=    Create List
     FOR    ${cell}    IN    @{cells_info}
         ${id_dict}=    Get From Dictionary    ${cell}    id
         ${config}=    Get From Dictionary    ${id_dict}    configuration
         Append To List    ${nrcell_distnames}    ${config}
         Log    NRCELL Dist Names: ${nrcell_distnames}
     END
     Set Suite Variable    ${nrcell_distnames}
    [Return]    ${cells_info}

Perform NR Cell Lock and Unlock
    Get all cells from BTS
    FOR    ${each_cell}    IN    @{nrcell_distnames}
        Lock cell and verify the cell state    ${each_cell}
        Unlock cell and verify gnb state    ${each_cell}
    END
    [Teardown]    Unlock the cell incase of failure after cell locked successfully    ${each_cell}

Lock cell and verify the cell state
    [Arguments]    ${cell_distname}
    Lock NRCELL    ${cell_distname}
    sleep    10s   msg=Sleeping for 10s
    Verify cell is in expected state    cell_distname=${cell_distname}     expected_adm_state=Locked
    Log to console     ${cell_distname} is locked successfully

Unlock cell and verify gnb state
    [Arguments]    ${cell_distname}
    Unlock NRCELL    ${cell_distname}
    sleep    10s   msg=Sleeping for 10s
    Verify cell is in expected state    cell_distname=${cell_distname}     expected_adm_state=Unlocked
    Log to console     ${cell_distname} is locked successfully

Verify cell is in expected state
    [Arguments]    ${cell_distname}     ${expected_adm_state}=${EMPTY}
    admin.Connect To
    ${param_list}=    Create List    administrativeState
    ${output}    admin.Get Parameter By Distname    dist_name=${cell_distname}    parameter_list=${param_list}
    ${administrative_state}=    Set Variable    ${output[0]['parameters']['administrativeState']}
    Run Keyword If    '${administrative_state}' == '${expected_adm_state}'     Log    Cell ${cell_distname} is ${administrative_state}
    ...    ELSE    Fail    Cell ${cell_distname} is not ${administrative_state}
    Run Keyword If    '${expected_adm_state}' == 'Locked'   Set Test Variable   ${Lock_status}    True
    ...   ELSE    Set Test Variable   ${Lock_status}    False
    [Teardown]    admin.Teardown

Unlock the cell incase of failure after cell locked successfully
    [Arguments]    ${cell_distname}
    Run keyword If    ${Lock_status}    Unlock cell and verify gnb state    ${cell_distname}

Lock NRCELL
    [Arguments]    ${cell_distname}
    admin.Connect To
    admin.lock    dist_name=${cell_distname}    timeout=300
    [Teardown]    admin.Teardown

Unlock NRCELL
    [Arguments]    ${cell_distname}
    admin.Connect To
    admin.unlock    dist_name=${cell_distname}    timeout=300
    [Teardown]    admin.Teardown

UE status check
        [Documentation]    UE status check
    ...                Modified Date: 21-Feb-2025
    ...                Last Modified by: kusuma.s@nokia.com
    wtsrunner.ue_disp
    wtsrunner.read_wtsemu_output_until_re    expected=IsUEInCusMode     timeout=30

AP Cell Setup should be Successful for multiple cellsetup
    [Documentation]    This keyword checks if the Cell Setup completed in egate_console.log file
    ...                Modified Date: 21-11-2025
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    [Arguments]    ${count}=2
    Run Keyword And Return If    '${custom_cell}' == 'True'    AP Cell Setup should be Successful for Custom Cell
    FOR   ${cell_id}   IN RANGE    ${min_cell_id}    ${component_carrier}
        ${validation_string}=    Set Variable    ${EMPTY}
        Run Keyword If    '${apConfiguration}' in "@{BFCfg}" and ${cell_id} == 1
        ...    Continue For Loop
        ${validation_string}=    Catenate    ${Cell_setup_complete_pattern}     for \\[CELL_ID:${cell_id + 1}\\]
        Check Pattern in APL3 Log for muliple cellsetup    ${validation_string}    ${count}
    END
    Run Keyword If    '${CELL_BLOCK_UNBLOCK}' == 'True'    Perform Cell Block Unblock For All Cells
    Run Keyword If    '${4G5G_Combo}'=='1'
    ...    Check Pattern in Egate Console Log    cell ${enb_cell_id}: ${UE_SIB_decoding_pattern_eNB}
    Run Keyword If    '${4G5G_CUS}'=='1'
    ...    Check Pattern in Egate Console Log    cell ${cell_id + 1}: ${UE_SIB_decoding_pattern_eNB}
    sleep              5s

Check Pattern in APL3 Log for muliple cellsetup
    [Arguments]    ${pattern}    ${count}=2
    [Documentation]    This keyword checks if the ${pattern} is present in AP L3 log.
    ...                Modified Date: 21-Nov-2025
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search grep pattern should Exists mutipletimes
    ...    /tmp/${ap_log}    ${pattern}    count=${count}

Search grep pattern should Exists mutipletimes
    [Arguments]    ${file}    ${expected}    ${connection}=${AP_ASIK.Connection}    ${grepArgs}=grep -i    ${sudo}=${EMPTY}    ${count}=2
    [Documentation]    This keyword checks if the ${expected} is present in ${file} log of Airphone.
    ...                Modified Date: 21-Nov-2025
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    ${command}        Catenate    ${sudo} ${grepArgs} '${expected}' ${file}
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...               alias=${AP_ASIK.Connection}
    ${actual}         SSH.Execute    ${command}    ${connection}
    SSH.Disconnect    ${AP_ASIK.Connection}
    ${result}         Run Keyword And Return Status
    ...               Should Match Regexp    ${actual}    ${expected}    msg=No match for ${expected}
    ${matches}=    Get Regexp Matches    ${actual}    CELL_ID:(\\d+)
    Length Should Be    ${matches}    ${count}
    Should be True    ${result}    msg=File or pattern does not exist!

UE Deregister should be Successful for lock and unlock
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    ...                Modified Date: 15-april-2025
    ...                Last Modified by: kusuma.s@nokia.com
    Run Keyword And Ignore Error    Set WTS Default Log Level to Debug
    FOR   ${ueid}   IN   @{sa_ueids}
        Run Keyword And Ignore Error    UE Deregister should be Successful for SA    ${ueid}
    END

Enable BIP Logs
    Run    sed -i "s/ENABLE_BIP_LOG=0/ENABLE_BIP_LOG=1/" /opt/wts/latest/${sosReportCfg}
    Run    sed -i "s/SYSCOM_MIRRORING='false'/SYSCOM_MIRRORING='true'/" ${gNB_Mirroring_script}

Test Teardown for Cell Setup
    Run Keyword If    '${QT_CONFIG}' == 'True' and '${L2PS_TTI_TRACE}' == 'True'    Start L2PS TTI Traces
    Run Keyword If    '${TEST STATUS}' != 'PASS' and '${QT_CONFIG}' == 'True'    Collect Sosreport and Snapshot

Assign Variable for QT P0 Configs
    ${QT_CONFIG}    set variable if    '${apConfiguration}' in "@{AP_P0_CONFIGURATION}"    True    False
    Set Suite Variable    ${QT_CONFIG}

UE SIB Decoding should be Successful For 6G
    [Documentation]    This keyword checks if the UE sib decoding is completed for the SA variant in egate_console.log file
    ...                Modified Date: 25-Aug-2025
    ...                Last Modified by: kusuma.s@nokia.com
    FOR   ${cell_id}   IN RANGE    ${min_cell_id}    ${total_cells}
        ${validation_string}=    Set Variable    ${EMPTY}
        Run Keyword If    '${apConfiguration}' in "@{BFCfg}" and ${cell_id} == 1
        ...    Continue For Loop
        ${validation_string}=    Catenate    eNB ${eNB_target} cell ${cell_id + 1}:     ${UE_SIB_decoding_pattern}
        ${validation_string_1}=  Catenate    ${UE_SIB_pattern_startup_l3_log}    cellId:${cell_id + 1}, enbId ${eNB_target}
        ${status}    Run Keyword And Return Status    Check Pattern in APEgate Console Log    ${validation_string}
        ${status_1}   Run Keyword And Return Status    Check Pattern in APL3 Log in External AP server    ${validation_string_1}
        Run Keyword If    ${status} or ${status_1}    Log    At least one pattern found
        ...    ELSE    Fail    UE SIB decoding failed
    END

Check Pattern in APEgate Console Log
    [Arguments]    ${pattern}    ${file}=${AP_DIR}/egate_console.log
    [Documentation]    This keyword checks if the ${pattern} is present in the egate_console.log file
    ...                Modified Date: 14-Nov-2023
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    Log    ${file}!!!
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search grep pattern should Exists in external AP server EGATE
    ...    ${file}    ${pattern}

Search grep pattern should Exists in external AP server EGATE
    [Arguments]    ${file}    ${pattern}    ${grepArgs}=grep -i
    [Documentation]    This keyword checks if the ${pattern} is present in the egate_console.log file
    ...                Modified Date: 14-Nov-2023
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    ${command}        Catenate    ${grepArgs} '${pattern}' ${file}
    ExternalAPConnect.connect_ssh_to_external_ap_server    ${JUMP_HOST}    ${JUMP_USERNAME}
    ...    ${JUMP_PASSWORD}    ${JUMP_PORT}
    ${result}    ExternalAPConnect.execute_ssh_commands_on_external_ap    ${command}
    Log               ${result}
    Should Contain    """${result}"""    ${pattern}    ignore_case=${TRUE}
    [Teardown]    ExternalAPConnect.Disconnect Ssh External Ap Server

Search grep pattern should Exists in external AP server
    [Arguments]    ${file}    ${pattern}    ${grepArgs}=grep -i
    [Documentation]    This keyword checks if the ${pattern} is present in the egate_console.log file
    ...                Modified Date: 14-Nov-2023
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    ${command}        Catenate    ${grepArgs} '${pattern}' ${file}
    ExternalAPConnect.connect_ssh_to_external_ap_server    ${JUMP_HOST}    ${JUMP_USERNAME}
    ...    ${JUMP_PASSWORD}    ${JUMP_PORT}
    ${output}    ExternalAPConnect.execute_ssh_commands_on_external_ap    ${command}
    Log               ${output}
    ${result}         Run Keyword And Return Status
    ...               Should Match Regexp    ${output}    ${pattern}    msg=No match for ${pattern}
	Should Be True    ${result}    msg=File or pattern does not exist!
    [Teardown]    ExternalAPConnect.Disconnect Ssh External Ap Server

UE Register should be Successful for SANSA For 6G
    [Documentation]    This keyword checks the message for the completion of UE Registration in the output file for the SANSA variant
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Run Keyword If    '${apConfiguration}' in "@{QT_stability_cfg}"    wtsrunner.sim_param_set    disable_events_on_telnet_session=on
    FOR   ${ueid}    ${gwid}   IN ZIP   ${sa_ueids}    ${gw_ids}
        UE Register should be Successful for SA for 6G    ${ueid}    ${gwid}
    END

UE Register should be Successful for SA for 6G
    [Arguments]    ${UE_ID}=${UE_ID}    ${gw_ID}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SANSA variant
    ...                Modified Date: 23-May-2024
    ...                Last Modified by: abhishek.p@nokia.com
    ExternalAPConnect.Connect Ap Egate To External Ap Server    ${JUMP_HOST}    ${JUMP_USERNAME}
    ...    ${JUMP_PASSWORD}    ${JUMP_PORT}
    ExternalAPConnect.Execute Ap Egate Command    ue_register id=${UE_ID} mode=ccsrt
    wtsrunner.read_wtsemu_output_until_re    expected=${Register_complete_pattern}    timeout=${Timeout_SA}
    Check Pattern in Egate Console Log     ${Register_complete_pattern}    ${Timeout_SA}
    Check Pattern in Egate Console Log     ${Initial_UE_success_message}    ${Timeout_SA}
    ExternalAPConnect.Execute Ap Egate Command     set_pdu_param ue=${UE_ID} pdu=${Pdu_session_ID} trf_type=${Trf_type}
    ExternalAPConnect.Execute Ap Egate Command    ue_pdu_session_setup pdu=${Pdu_session_ID} ue=${UE_ID} nwslice=${nwslice_ID} gw=${gw_ID}
    wtsrunner.read_wtsemu_output_until_re    expected=${Initial_context_setup_pattern}    timeout=${Timeout_SA}
    Check Pattern in Egate Console Log    ${Initial_context_setup_pattern}    ${Timeout_SA}
    [Teardown]    ExternalAPConnect.Disconnect External Ap Server

UE Deregister should be Successful For 6G
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Run Keyword And Ignore Error    Set AP Default Log Level to Debug
    FOR   ${ueid}   IN   @{sa_ueids}
        UE Deregister should be Successful for SA for 6G    ${ueid}
    END

Set AP Default Log Level to Debug
     [Arguments]    ${level}=0
    [Documentation]    Debug level set to 0 during L3call
    wtsrunner.sim_debug_log    level=${level}

UE Deregister should be Successful for SA for 6G
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    ExternalAPConnect.Connect Ap Egate To External Ap Server    ${JUMP_HOST}    ${JUMP_USERNAME}
    ...    ${JUMP_PASSWORD}    ${JUMP_PORT}
    ExternalAPConnect.Execute Ap Egate Command    ue_deregister id=${UE_ID} ue_deregister_type=switch_off by=ue
    Read WTS Output For Pattern And Print matching Lines for 6G    ${UE_deregister_pattern}    ${Timeout_SA}
    [Teardown]    ExternalAPConnect.Disconnect External Ap Server

Read WTS Output For Pattern And Print matching Lines for 6G
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks if the ${pattern} is present in the output file and prints the line matching the pattern.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${output}    Read WTS Output Until Pattern Matches for 6G   ${pattern}    ${timeout}
    Print Matching Lines from Output File    ${output}    ${pattern}
    [Return]    ${output}

Read WTS Output Until Pattern Matches for 6G
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks the output file until the ${pattern} matches in the file.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=${pattern}
    ...    timeout=${timeout}
    [Return]    ${output}

UE Reregister should be Successful for SANSA for 6G
    [Documentation]    This keyword checks the message for the completion of UE Reregistration in the output file for the SANSA variant
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Sleep    ${UE_Reregister_sleep}
    FOR   ${ueid}    ${gwid}   IN ZIP   ${sa_ueids}    ${gw_ids}
        UE Register should be Successful for SA for 6G    ${ueid}    ${gwid}
    END

Get Average data from APEgate UE Stats Command
    [Arguments]    ${ue}    ${dl_ul}
	 ExternalAPConnect.Connect Ap Egate To External Ap Server    ${JUMP_HOST}    ${JUMP_USERNAME}
    ...    ${JUMP_PASSWORD}    ${JUMP_PORT}
    ${bearer_stat_dl}      ExternalAPConnect.Execute Ap Egate Command    ue_disp id=${ue}
	ExternalAPConnect.Execute Ap Egate Command    sim_log_set flush
    ${ue_stats_output}=    Run Keyword if    '${dl_ul}' == 'UL'
    ...    ExternalAPConnect.Execute Ap Egate Command    ue_stats_nr id=1 type=pusch scell=primary,secondary format=long    Statistics
    ...    ELSE    ExternalAPConnect.Execute Ap Egate Command    ue_stats_nr id=1 type=pdsch scell=primary,secondary format=long    Statistics
	${output}    Get Lines Containing String    ${ue_stats_output}    CellIndex
    # Extract average throughput (4th column) from each CellIndex-N line
    @{matches}    Get Regexp Matches    ${output}
    ...    CellIndex-\\d\\s*(?:(?:(?:\\d+\\.\\d+|\\d+)\\s(?:Mbps|Kbps)?\\s*){3}(?:((?:\\d+\\.\\d+|\\d+)\\s(?:Mbps|Kbps)?)\\s*))*    1
    ${bps_list}=    Create List
    FOR    ${val}    IN    @{matches}
        ${parts}=    Split String    ${val}
        ${value}=    Set Variable    ${parts[0]}
        ${unit}=     Set Variable    ${parts[1]}
        ${bps}=    Evaluate    float(${value}) * (1000000 if '${unit}' == 'Mbps' else 1000)
        Log    ${bps}
        Append To List    ${bps_list}    ${bps}
    END
    ${tput}=    Evaluate    sum(${bps_list})
    Return From Keyword    ${tput}
    [Teardown]    ExternalAPConnect.Disconnect External Ap Server

Verify Average Date Rate for SA For UEC Integrated AP Using UE Stats
    [Arguments]    ${ueid}    ${DL_RATE}    ${UL_RATE}
    ${data_rate}      Get Average data from APEgate UE Stats Command    ue=${ueid}    dl_ul=DL
    ${dl_avg_traffic1}=    Evaluate    (${DL_RATE}*0.9)*1000000
    ${dl_avg_traffic2}=    Evaluate    (${DL_RATE}*1.2)*1000000
    Should Be True    ${data_rate} >= ${dl_avg_traffic1}    msg=DL avg Traffic Failed! for Cell
    ${status}    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${dl_avg_traffic2}    msg=DL avg Traffic is more than actual
    Run Keyword If    '${status}' == 'False'    Log To Console    DL avg Traffic is more than actual
    ${data_rate}      Get Average data from APEgate UE Stats Command    ue=${ueid}    dl_ul=UL
    ${ul_avg_traffic1}=   Evaluate    (${UL_RATE}*0.9)*1000000
    ${ul_avg_traffic2}=   Evaluate    (${UL_RATE}*1.2)*1000000
    Should Be True    ${data_rate} >= ${ul_avg_traffic1}    msg=UL avg Traffic Failed! for Cell
    ${status_1}    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${ul_avg_traffic2}    msg=UL avg Traffic is more than actual
    Run Keyword If    '${status_1}' == 'False'    Log To Console    UL avg Traffic is more than actual

Trigger Log Collection From WTS For 6G
    [Documentation]    This keyword Collects BTS and WTS logs from the WTS VM.
    ...                Modified Date: 07-Jul-2025
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    [Timeout]    40 minutes
    Run And Return Rc And Output    cp /opt/wts/latest/ota/ota_log_collector* /opt/wts/latest/
    ${rc}    ${output}    Run And Return Rc And Output    cd /opt/wts/latest/ && ./ota_log_collector.sh
    ${output}    Set Variable    ${output}[-200:]
    ${file}    Get Regexp Matches    ${output}    otaLogCollector.*tgz
    ${sos_file}    Set Variable    ${file}[0]
    Run And Return Rc And Output    cp /opt/wts/latest/${sos_file} ${EXECDIR}/logs/
    Run And Return Rc And Output    cp /opt/wts/latest/egate_console.log ${EXECDIR}/logs/wts_egate_console.log
    Run And Return Rc And Output    ls -ltr ${EXECDIR}/logs/

Trigger Log Collection From AP for 6G
    [Documentation]    This keyword collects the External AP side logs.
    ...                Modified Date: 07-Jul-2025
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    [Timeout]    40 minutes
    ExternalAPConnect.Connect Ssh To External Ap Server    ${JUMP_HOST}    ${JUMP_USERNAME}
    ...    ${JUMP_PASSWORD}    ${JUMP_PORT}
    ${sosreport_cmd}    Catenate    cd /opt/AirPhone/egate_uec_edaemon/tools &&
    ...                 ./sosReport_OTA.sh
    ${output}    ExternalAPConnect.execute_ssh_commands_on_external_ap     ${sosreport_cmd}    timeout=600
    ${output}    Set Variable    ${output}[-200:]
    ${file}    Get Regexp Matches    ${output}    SosReport.*tgz
    ${sos_file}    Set Variable    ${file}[0]
    ExternalAPConnect.download_file_from_ap    /opt/AirPhone/egate_uec_edaemon/tools/${sos_file}    ${EXECDIR}/logs/${sos_file}
    Run Keyword And Ignore Error    ExternalAPConnect.download_file_from_ap    /user/egate/egate_console.log
    ...    ${EXECDIR}/logs/ap_egate_console.log
    Run And Return Rc And Output    ls -ltr ${EXECDIR}/logs/
    [Teardown]    Run Keyword And Ignore Error    ExternalAPConnect.disconnect_ssh_external_ap_server

Collect Logs For 6G
    [Documentation]    This keyword collects the required logs for 6G configuration.
    ...                Modified Date: 07-Jul-2025
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    Trigger Log Collection From AP for 6G
    Trigger Log Collection From WTS for 6G

QT Traffic Throughput Counter Collection and Validation
    Run keyword And Continue On Failure    QT Counter Validation

QT Counter Validation
    [Documentation]    This keyword creates a PM Counter List and calls the Keyword which
    ...    returns the Counter Value from the XML file and then does the processing
    ...                Modified Date: 20-Aug-2025
    ...                Last Modified by: kushal.j@nokia.com
    Create PM Counter List QT
    Fetch Counter value for QT    ${COUNTER_LIST}
    ${dl_tput}=    QT Traffic Convert Bits to Mbps    ${pm_counter_list[0]}
    Set Suite Variable    ${dl_tput}
    ${ul_tput}=    QT Traffic Convert Bits to Mbps    ${pm_counter_list[1]}
    Set Suite Variable    ${ul_tput}
    QT Traffic Validation DLandUL    ${dl_tput}    ${ul_tput}

Fetch Counter value for QT
    [Arguments]    ${counter_list}
    [Documentation]    This keyword does the TAF call to fetch the Counter Value from GNB BTS
    ...                Modified Date: 20-Aug-2025
    ...                Last Modified by: kushal.j@nokia.com
    Wait Until Keyword Succeeds    5min    1min
    ...    Fetch Counter Value from GNB BTS QT
    FOR    ${counter}    IN    @{counter_list}
        Calling XML counter fetch for QT Traffic    ${counter}
    END

Fetch Counter Value from GNB BTS QT
    [Arguments]    ${target_dir}=/home/ute/gnb_pm_counters    ${ip}=192.168.255.129    ${name}=gnb_pm_counters    ${duration}=5 minutes
    [Documentation]    TAF call to fetch the Counter Value from GNB BTS
    ...                Modified Date: 20-Aug-2025
    ...                Last Modified by: kushal.j@nokia.com
    RUN    rm -rf ${target_dir}
    ${webservice}=    Create Dictionary    host=${ip}    user=${GNB_BTS.Username}
    ...    password=${GNB_BTS.Password}    port=${GNB_BTS.Port}
    gnb_pmcounters.create PM collector    name=${name}    webservice=${webservice}    for_last=${duration}
    gnb_pmcounters.setup_collectors    names=${name}
    gnb_pmcounters.collect_collectors    names=${name}    target_dir=${target_dir}
    Directory Should Not Be Empty    ${target_dir}
    [Teardown]    gnb_pmcounters.teardown_collectors    names=${name}

Create PM Counter List QT
    ${pm_counter_list}=    Create List
    Set Suite Variable    @{pm_counter_list}

Calling XML counter fetch for QT Traffic
    [Arguments]    ${counter}
    Log To Console    Fetching the Value of the counter ${counter}
    ${value}=    Fetch counter value from XML file QT    ${counter}    ${Counter_directory}
    Append To List    ${pm_counter_list}    ${value[0]}
    Set Suite Variable    ${pm_counter_list}

QT Traffic Convert Bits to Mbps
    [Arguments]    ${bits}
    ${achieved_tput}=    Evaluate    (${bits}*8)/float(60000*5)
    ${achieved_tput}=    Evaluate    "%.2f" % ${achieved_tput}
    [Return]    ${achieved_tput}

QT Traffic Validation DLandUL
    [Arguments]    ${dl_tput}    ${ul_tput}
    ${tput_dl_data}=    Set Variable    "DL RATE":"${dl_tput}"
    Log To Console    Achieved DL Throughput from Counters: ${tput_dl_data}
    ${tput_ul_data}=    Set Variable    "UL RATE":"${ul_tput}"
    Log To Console    Achieved UL Throughput from Counters: ${tput_ul_data}

Fetch counter value from XML file QT
    [Arguments]    ${COUNTER}    ${Counter_directory}
    [Documentation]    Fetches the Counter Value from the XML File
    ...                Modified Date: 20-Aug-2025
    ...                Last Modified by: kushal.j@nokia.com
    ${single_counter}=    Create List
    ${pm_file_latest}=    Run    find ${Counter_directory} -type f -iname "*.xml" | sort -r | head -1
    ${pm_file}=    Set Variable    ${pm_file_latest}
    ${cmd_output}=    Fetch from Left    ${pm_file}    \r
    ${cmd_output}=    Run    cat ${cmd_output}
    ${counter_list}=    Get Regexp Matches    ${cmd_output}     \<${COUNTER}\>([0-9]+)
    Run Keyword If    ${counter_list} == []
    ...    Fail    Expected counter '${COUNTER}' is not present in the XML file.
    FOR    ${index}    IN    @{counter_list}
        ${counter_string}=    Convert to String    ${index}
        ${counter_string}=    Fetch From Right    ${counter_string}    >
        ${counter_string}=    Fetch From Left    ${counter_string}    '
        ${counter_value}=    Convert to Integer    ${counter_string}
        Run Keyword If    '${counter_value}' >= '0'
        ...    Append To List    ${single_counter}    ${counter_value}
    END
    RUN    cp /home/ute/gnb_pm_counters/* ${EXECDIR}/logs/
    [Return]    ${single_counter}

Perform Operation on System
    [Arguments]    ${keyword_val}='None'
    [Documentation]    Perform either the given operation or a pre-determined operation
    ...                Modified Date: 01-Sep-2025
    ...                Last Modified by: gopalakrishnan.nallasivan@nokia.com
    ${keyword_val}    Set Variable If    ${keyword_val} != 'None'    ${keyword_val}
    ...    ${operation_keyword['${apConfiguration}']}
    Run Keyword    ${keyword_val}
    Sleep    60s
