*** Settings ***
Documentation    author：Pengliang Wu
...              contact: pengliang.wu@nokia.com
...              squad group: VRF HAZ7


Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008927-N-Airphone/Resources/CB008927_common_keyword.py
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008927-N-Airphone/Resources/CB008927_common_keyword.robot
Library     ./Resources/kpi_check_keyword.py

Suite Setup       CB008927 Suit Setup
Suite Teardown    CB008927 Suit Teardown


*** Test Cases ***

[1]CNI-144631_14_4F_2T_scell_add_success_relate_KPI
    [Tags]  CRT_TRUNK   t721
    [Setup]    Test Case Setup    scf_name=_144631
    ${loop}    set variable    ${10}
    ${ue_id_list}    generate_ue_id_list    ue_id_start=${21}    ue_id_end=${50}
    FOR    ${i}    IN RANGE    ${loop}
        Log to console    Testing Loop - ${i}
        SA UE Attach on cell    if_ul=${False}    if_dl=${True}    trf_num=${2}    ue_id_list=${ue_id_list}    dl_mbps=${170}
        sleep    20s
        Stop Traffic and release UE    ue_id_list=${ue_id_list}
        sleep    10s
    END
    Log to console    sleep 6min wait for counters update...
    sleep    6min
    Generate KPI csv file And Check KPI    output_path=${output_dir}/${TEST_NAME[:30]}
    [Teardown]    Case Teardown

*** Keywords ***
Generate KPI csv file And Check KPI
    [Arguments]    ${bts_host}=${gNB_ip}    ${output_path}=${output_dir}
    Log to console    Start get and calculate Kpi from BTS
    ${output_result}    calculate_kpi_via_counter    bts_host=${bts_host}
    ...    counter_object_patterns=/NRCELL-1/,/NRCELL-2/,/NRCELL-3/,/NRCELL-4/,/NRCELL-5/,/NRCELL-6/
    ...    output_path=${output_path}    kpi_ids=NR_1473a,NR_5523c,NR_46a
    ...    filename=CNI_144631_kpi    calculate_kpi=${True}
    Log to console    kpi saved: ${output_result}[output_file]
    Log to console    kpi value: ${output_result}[kpi_dict]
    ${kpi_dict}    set variable    ${output_result}[kpi_dict]
    ${kpi_name}    get dictionary keys    ${kpi_dict}
    FOR    ${kpi}    IN    @{kpi_name}
        ${kpi_value}    set variable    ${kpi_dict}[${kpi}]
        ${diff}    Evaluate    ${kpi_value}-${100}
        Run Keyword And Continue On Failure    Should Be True    ${diff}==${0}    msg=${kpi}, ${kpi_value}% != 100%, pls check!!!
    END