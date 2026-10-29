# @Time    : 2024/1/23 10:55
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CNI106544.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CNI106544

Suite Setup         MMW5 Common Suite Setup
Suite Teardown      MMW5 Common Suite Teardown
Test Setup          MMW5 Common Case Setup
Test Teardown       MMW5 Common Case Teardown
Force Tags    SBTS00    RAN_5G    PY39
...           RAN_5G_TDD    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASILL_ABIOB1_AEQY_ENB

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Variables ***
@{CUSTOM_PROFILE_L2HI}    L2HiRlc_Component    L2HiPdcp_Component
${L2HI_IN_SNAPSHOT}    L2TraceHi
${L2TRACER_IN_DCAP}    L2_component.pcap
@{CUSTOM_PROFILE_L2LO}    L2Lo_Component
${L2LO_IN_SNAPSHOT}    L2TraceLo.dat

*** Test Cases ***
CNI-106544_2_5G-L2-HI_Component_Trace_in_streaming_mode
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/23 10:57
    [Tags]    c02
    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE_L2HI}

    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=30M    dl_tp=300M    duration=1200

    ${snapshot_file}    MMW5 Collect Snapshot
    ${file_sizes}    get_file_size_from_snapshot_file_list    file_name=${L2HI_IN_SNAPSHOT}    snapshot_file=${snapshot_file}
    ${snapshot_file2}    MMW5 Collect Snapshot
    ${file_sizes2}    get_file_size_from_snapshot_file_list    file_name=${L2HI_IN_SNAPSHOT}    snapshot_file=${snapshot_file2}

    ${dcap_file}    Dcap Stop Trace Via Trace ID    download_trace=true
    ${dcap_files}    get_file_size_from_zip    file_name=${L2TRACER_IN_DCAP}    zip_file=${dcap_file}
    Should Not Be Empty    ${dcap_files}
    ${files}    Get Dictionary Keys    ${dcap_files}
    FOR    ${file}    IN    @{files}
        Should Be True    ${dcap_files["${file}"]}>0
    END

    ${sum_cu1}    ${sum_du1}    Get CU&DU Sum Size From Dual Core    ${file_sizes}
    ${sum_cu2}    ${sum_du2}    Get CU&DU Sum Size From Dual Core    ${file_sizes2}
    Should Be True    ${sum_cu2}!=${sum_cu1}
    Should Be True    ${sum_du2}!=${sum_du1}

    UE Stop Traffic And Release UE

CNI-106544_4_5G-L2-LO_Component_Trace_in_streaming_mode
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/26 15:15
    [Tags]    c04
    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE_L2LO}

    UE Attach With Verify Attach
    UE Start UL&DL UDP Traffic    ul_tp=30M    dl_tp=300M    duration=1200

    ${snapshot_file}    MMW5 Collect Snapshot
    ${file_sizes}    get_file_size_from_snapshot_file_list    file_name=${L2LO_IN_SNAPSHOT}    snapshot_file=${snapshot_file}
    ${snapshot_file2}    MMW5 Collect Snapshot
    ${file_sizes2}    get_file_size_from_snapshot_file_list    file_name=${L2LO_IN_SNAPSHOT}    snapshot_file=${snapshot_file2}

    ${dcap_file}    Dcap Stop Trace Via Trace ID    download_trace=true
    ${dcap_files}    get_file_size_from_zip    file_name=${L2TRACER_IN_DCAP}    zip_file=${dcap_file}
    Should Not Be Empty    ${dcap_files}
    ${files}    Get Dictionary Keys    ${dcap_files}
    FOR    ${file}    IN    @{files}
        Should Be True    ${dcap_files["${file}"]}>0
    END

    ${sum_lo1}    Get L2TraceLo Sum Size From Dual Core    ${file_sizes}
    ${sum_lo2}    Get L2TraceLo Sum Size From Dual Core    ${file_sizes2}
    Should Be True    ${sum_lo2}!=${sum_lo1}

    UE Stop Traffic And Release UE

*** Keywords ***
Get CU&DU Sum Size From Dual Core
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/26 10:21
    [Arguments]    ${file_sizes}    ${sum_cu}=0    ${sum_du}=0
    ${files}    Get Dictionary Keys    ${file_sizes}
    FOR    ${file}    IN    @{files}
        ${is_cu}    Run Keyword And Return Status    Should Contain    ${file}    CU
        ${sum_cu}    Run Keyword If    ${is_cu}==True    Evaluate    ${sum_cu}+${file_sizes["${file}"]}
        ...    ELSE    Set Variable    ${sum_cu}
        ${sum_du}    Run Keyword If    ${is_cu}==False    Evaluate    ${sum_du}+${file_sizes["${file}"]}
        ...    ELSE    Set Variable    ${sum_du}
    END
    [Return]    ${sum_cu}    ${sum_du}

Get L2TraceLo Sum Size From Dual Core
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/26 15:40
    [Arguments]    ${file_sizes}    ${sum_lo}=0
    ${files}    Get Dictionary Keys    ${file_sizes}
    FOR    ${file}    IN    @{files}
        ${is_l2tracelo}    Run Keyword And Return Status    Should Contain    ${file}    ${L2LO_IN_SNAPSHOT}
        ${sum_lo}    Run Keyword If    ${is_l2tracelo}==True    Evaluate    ${sum_lo}+${file_sizes["${file}"]}
        ...    ELSE    Set Variable    ${sum_lo}
    END
    [Return]    ${sum_lo}
