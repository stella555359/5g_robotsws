*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB008731 celltrace
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../common_711A_8731/keywords.robot
Resource        ../common_711A_8731/keywords-wts.robot
Resource        CB008731-commissioning-pcmd-celltrace.robot
Resource        CB008731-parameter-settings-pcmd-celltrace.robot
Resource        CB008731-wts.robot
Resource        CB008731-verify-wireshark-celltrace.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/tshark.robot
Resource        ../../../resources/Common/reporting.robot


Suite Setup       Suite Setup CB008731
Suite Teardown    Suite Teardown 711A 8731

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}
${port_trace}                         49151
${ip_trace}                           10.0.1.10
@{UE}                                 1   2

*** Test Cases ***


CB008731_Cell_trace_for_interRAT_HO_from_LTE_to_5G
    [Documentation]    This test case verifies the cell trace
    ...       :Autor: Sylvia Schneider
    [Tags]    t8   CRT
    [Setup]   Perform Preconditions of Test Scenario 8731 celltrace

    Update wts file for TC CB008731 t8
    prepare parameter celltrace
    Update SCF pcmd celltrace

    start wireshark trace
    activate SCF and bring tl onAir t8
    check wts in active state
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    register UE and start PDU session
    trigger handover to LTE
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    start cell trace
    trigger handover to 5G
    stop cell trace
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part3.pcap

    set parameters to disable handover

    start wireshark trace
    register UE and start PDU session   ue_id=2
    trigger handover to LTE             ue_id=2
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part4.pcap

    start wireshark trace
    start cell trace    collector=cell_trace_hoFailure
    trigger handover to 5G which fails   ue_id=2   cause=ho target not allowed
    stop cell trace     collector=cell_trace_hoFailure
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part5.pcap

    set actInterRatHoFromEutraToSA actCellTraceReport
    start wireshark trace
    start cell trace    collector=cell_trace_off
    trigger handover to 5G         ue_id=2
    stop cell trace     collector=cell_trace_off
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part6.pcap

    release UE

    verify wireshark 8731 t8

    [Teardown]   Perform Postconditions of Test Scenario 8731 celltrace





*** Keywords ***

Suite Setup CB008731
    [Documentation]    [PRIVATE]    Prepare TL for CB008731
    ...       :Autor: Sylvia Schneider
    Create ip for cell trace
    Create ips for simulated gnb
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF from gNB
    get version mcc mnc from gNB SCF    ${current_SCF_gnb}
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    Update wts file for TC CB008731 common part


Perform Preconditions of Test Scenario 8731 celltrace
    [Documentation]    [PRIVATE]    preconditions for  8731 celltrace
    ...       :Autor: Sylvia Schneider
    Create a Test Scenario Folder
    Start Netcat for tracing


Perform Postconditions of Test Scenario 8731 celltrace
    [Documentation]    [PRIVATE]    postconditions for 8731 celltrace
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Set SCOUT TC ID for Reporting
    Run Keyword And Continue On Failure   stop wireshark trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Run Keyword And Continue On Failure   Teardown Egate Connection for Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    Run Keyword And Continue On Failure   Stop Netact for tracing
    IF    '${TEST STATUS}'=='FAIL'    Collect snapshot and sos report data     ${resultDir}


Start Netcat for tracing
    Log To Console    Netcat started
    Run     sudo pkill -9 -f 'nc -l ${port_trace} -k'
    ${NC_PROC}=    Start Process  nc  -l  ${port_trace}  -k  stdout=/dev/null  stderr=/dev/null
    Sleep    5
    Run    ps -ef | grep nc
    Set Test Variable    ${NC_PROC}


Stop Netact for tracing
    Log To Console    Netcat stopped
    Terminate Process  ${NC_PROC}


start cell trace
    [Documentation]    [PRIVATE]    start cell trace
    ...       :Autor: Sylvia Schneider
    [Arguments]  ${collector}=cell_trace
    Log To Console    cell trace started
    Start Tshark for Trace Session
    ...   interface=eth3
    ...   trace_port=${port_trace}
    ...   collector=${collector}
    Sleep    1s   reason=wait for trace ready


stop cell trace
    [Documentation]    [PRIVATE]    stop cell trace
    ...       :Autor: Sylvia Schneider
    [Arguments]  ${collector}=cell_trace
    Log To Console    cell trace stopped
    Sleep    2s   reason=wait for all data collected
    Stop Tshark on Test PC
    ...   collector=${collector}
    ...   target_dir=${resultDir}


Create ip for cell trace
    [Documentation]    [PRIVATE]    Create ip for cell trace
    ...       :Autor: Sylvia Schneider
    Log To Console    \nip for cell trace created ${ip_trace}
    Configure IP on VM    ip=${ip_trace}       interface=eth3


set parameters to disable handover
    [Documentation]    [PRIVATE]    execute delta commissioning with parameter
    ...   actInterRatHoFromEutraToSA and save final SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning of parameter started
    Log To Console    actInterRatHoFromEutraToSA set to value false
    ${delta_SCF_template}    Get File       ${CURDIR}/scf_update_t8.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/CB008731-scf_update_t8.xml    ${delta_SCF_update}
    Execute delta commissioning    delta_scf_template=${resultDir}/CB008731-scf_update_t8.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter finished
    get scf coam    ${resultDir}    SCFC_8731A_t8_ho_disabled.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_8731_t8_ho_disabled.xml
