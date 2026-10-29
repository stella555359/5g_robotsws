*** Settings ***
Documentation    Auther:mengping.cai@nokia-sbell.com

Library    BuiltIn
Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ru_soap_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001795/Resources/5GC001795_common.robot
Library    taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library    taf.analyzer.pcap     WITH NAME    cap

*** Variables ***
${BTS_ID}    ${tl.gnbs[0].instance_id}
${tddtimer_path}    ${CURDIR}/../../5GC001795/Resources/tddtimer.conf
&{fault_61652}    faultId=${61652}
&{fault_61524}    faultId=${61524}
&{fault_7319}    faultId=${7319}
&{fault_7300}    faultId=${7300}
&{fault_9000}    faultId=${9000}
&{fault_6450}    faultId=${6450}
@{ALLOWED_FAULT}    &{fault_61652}    &{fault_61524}    &{fault_9000}    &{fault_6450}

*** Keywords ***
702 Case SetUp Tddtimer
    [Arguments]    ${tddtimer_file}=${tddtimer_path}
    1795 Case SetUp
    Check Tddtimer File From RF
    Upload Tddtimer File To RF    path=${tddtimer_file}
    Perform RU Reset
    wait until keyword succeeds    10 min    20 sec    COAM Wait for gnb ready and cell setup

702 Case TearDown Tddtimer
    [Arguments]    ${connection}=GNB_OAM
    ...           ${asik_connection}=ASIK Master
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    connection_alias_store.Connect to Common Unit Master
    Connect to gnb coam via ssl    connection=${connection}
    Check Tddtimer File From RF
    1795 Case TearDown
