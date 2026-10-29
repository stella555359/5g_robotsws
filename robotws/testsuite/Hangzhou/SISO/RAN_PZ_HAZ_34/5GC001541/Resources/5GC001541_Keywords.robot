*** Settings ***
Documentation
...   author: Liu Zheng
...   contact: zheng.4.liu@nokia-sbell.com
...   squad group: SG_04
...   Feature 5GC001541 in 5G19A program

Resource     ./5GC001541_Variables.robot
Resource     ../../../../OAM/RAN_PZ_HAZ_34/5GC000980/Resources/5GC000980_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/SISO_Pre.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/MTK_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/common/connection_with_hostname.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000920/Resources/5GC000920_Keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_average_throughput.py
#Library      ../../../../../resources/python_libs/TestCaseRequirement.py    WITH NAME    TestCaseRequirement
Variables    ../TestData/5GC001541_modify_nidd.py
Variables    ../TestData/5GC001541_scf_modify.py


*** Variables ***
&{fault_10}       faultId=${10}    source=RMOD_R-1    severity=Critical    # No connection to unit
&{fault_61524}    faultId=${61524}    source=SMOD_R-1    #faultId:SSH_ENABLED  source:RU1
&{fault_61652}    faultId=${61652}    source=SMOD_R-1    #faultId:R&D_SERVICE_PORT_ENABLED  source:RU1
&{fault_9000}    faultId=${9000}    source=SMOD_R-1    #faultId:BTS booted due to software restart  source:RU1
&{fault_7319}    faultId=${7319}    source=NRBTS     #faultId:EFaultId_X2LinkNotAvailableAl
&{fault_7300}    faultId=${7300}    source=NRBTS     #faultId:EFaultId_NoneX2LinkAvailableAl
&{fault_1844}    faultId=${1844}    source=ALD_R    # Fault: RET Antenna control failure. Can be ignored in future
&{fault_1845}    faultId=${1845}    source=ALD_R    # This alarm is related with ALD, when SW is ready need to remove it from allowed_fault_list
@{ALLOWED_FAULT_LIST}    &{fault_61524}    &{fault_61652}    &{fault_9000}    &{fault_1845}    &{fault_1844}
@{ALARMS_SOURCE_LIST}    RMOD_R-1


*** Keywords ***

Attach with Power UE
    [Documentation]   Author: Wang Yixiang
    ...               Description: start the DL traffic via iperf with power UE
    ...               UE_TYPE can be huawei,qct_dx50, define in testline configuration file
    [Arguments]    ${ue_type}=${UE_TYPE}    ${retry_time}=2
    Prepare for power UE 1541    ue_type=${ue_type}
    FOR    ${i}    IN RANGE    ${retry_time}
       ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}    hwcheck_index=${0}
       ${status}    run keyword and return status    power_ue.Verify attach    ue_type=${ue_type}
       ...    4G_check=False    5Grach_ed=${5Grach_ed}
       exit for loop if    ${status}==${True}
    END
    run keyword if    ${status}==${False}    Fail    5G attach failed.

Prepare for power UE 1541
    [Documentation]   Author: Wang Yixiang
    ...     Prepare UE for L3 call test.
    ...     param  ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    [Arguments]    ${ue_type}=${UE_TYPE}
    power_ue.Prepare UE    ue_type=${ue_type}

Start DL traffic with Power UE 1541
    [Documentation]   Author: Wang Yixiang
    ...     Start DL traffic with Power UE
    [Arguments]    ${dl_throughput}    ${ue_index}=${0}    ${ue_type}=${UE_TYPE}    ${duration}=${DL_TIME}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}   duration=${duration}
    ...    iperf_port=${DL_PORT}    ue_index=${ue_index}    cap_index=${0}    buffer_size=1024B

Start UL traffic with Power UE
    [Documentation]   Author: Wang Yixiang
    ...     Start UL traffic with Power UE
    [Arguments]    ${ul_throughput}    ${ue_index}=${0}    ${ue_type}=${UE_TYPE}    ${duration}=${UL_TIME}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}   duration=${duration}
    ...    iperf_port=${UL_PORT}    ue_index=${ue_index}    cap_index=${0}    buffer_size=1024B

Case preparation 1541
    [Documentation]  Author: Wang Yixiang
    ...              2020/04/27 Cui Lingxue: add btslog capture
    COAM Create log directory
    Wait until cluster is on cell on air status    timeout=3 min    is_all_cells_checking_needed=${True}
    Connect to Common Unit Master    alias=ASIK Master
    Connect to Capacity Unit Loner case    master_alias=ASIK Master
    @{RUS_ALIAS}    Connect to all rus with allocated IP
    Set suite variable    ${RUS_ALIAS}
    Connect to Capacity Unit Slave case     alias=ABIL Slave
