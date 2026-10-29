*** Settings ***
Documentation    author: Charlotte Wu
...              Group: RAN_PZ_HAZ3_SG02
...              contact: charlotte.wu@nokia-sbell.com

Resource          Resources/common_keyword.robot

Suite Setup    CB010870_Suite_Setup
Suite Teardown    CB010870_Suite_Teardown

*** Test Cases ***
[1]CB010870_A_4_DL_channel_FDM_validation_non_share_loki
    [Setup]    case_common_setup
    update_scf    scfpath=${TDD_scf}
    sleep    240s
    ${ue_list}    Create List    1    3
    set test variable    ${ue_list}
    &{ues_dltput}    Create Dictionary    1=350MKbits/sec    3=350MKbits/sec
    &{ues_dlexp}    Create Dictionary    1=600    3=600
    &{ues_ultput}    Create Dictionary    1=0MKbits/sec    3=0MKbits/sec
    &{ues_ulexp}    Create Dictionary    1=0    3=0
    Set PA value    modify_list=${TDD_PA_value}      port_num=${4}
    MultiUE L3 call DLUL and check throughput    ue_list=${ue_list}    apn=${apn0}    ues_dltput=${ues_dltput}
    ...    ues_ultput=${ues_ultput}    ues_dlexp=${ues_dlexp}    ues_ulexp=${ues_ulexp}
    MultiUE Stop traffic    ue_list=${ue_list}    apn=${apn0}
    &{ues_dltput}    Create Dictionary    1=0MKbits/sec    3=0MKbits/sec
    &{ues_dlexp}    Create Dictionary    1=0    3=0
    &{ues_ultput}    Create Dictionary    1=100MKbits/sec    3=100MKbits/sec
    &{ues_ulexp}    Create Dictionary    1=70    3=70
    Set PA value    modify_list=${TDD_PA_value}      port_num=${4}
    MultiUE L3 call DLUL and check throughput    ue_list=${ue_list}    apn=${apn0}    ues_dltput=${ues_dltput}
    ...    ues_ultput=${ues_ultput}    ues_dlexp=${ues_dlexp}    ues_ulexp=${ues_ulexp}
    [Teardown]    run keywords    MultiUE Stop traffic    ue_list=${ue_list}    apn=${apn0}
    ...    AND    case_common_teardown

[1]CB010870_A_6_single_UE_DL_UL_tput_FDD_TDD_carrier_aggregation
    [Setup]    case_common_setup
    update_scf    scfpath=${CA_scf}
    sleep    120s
    ${ue_list}    Create List    1
    set test variable    ${ue_list}
    &{ues_dltput}    Create Dictionary    1=900MKbits/sec
    ${dltput_exp_pcell_scell}    Create List    100    1500
    &{ues_dlexp}    Create Dictionary    1=${dltput_exp_pcell_scell}
    &{ues_ultput}    Create Dictionary    1=56MKbits/sec
    &{ues_dlexp_all}    Create Dictionary    1=1700
    &{ues_ulexp}    Create Dictionary    1=50
    Set PA value    modify_list=${CA_PA_value}      port_num=${4}
#   Start collect log by gnb tool    command=./gnb_logs ${host_addr} -cp -s -c
    MultiUE Prepare    ue_list=${ue_list}
    sleep    10s
    MultiUE Attach    ue_list=${ue_list}
    sleep    10s
    MultiUE Start dlul traffic    ue_list=${ue_list}    apn=${apn0}    ues_dltput=${ues_dltput}
    ...    ues_ultput=${ues_ultput}
    sleep    30s
    ${dltput}    MultiUE Get dl tput on spark with 2CC CA    ue_list=${ue_list}
    ${check_status}    ${error_message}=    Run Keyword And Ignore Error    MultiUE Check dl tput with 2CC CA
    ...    ue_list=${ue_list}    dltput=${dltput}    ues_exp=${ues_dlexp}
    sleep    2s
    IF    '${check_status}' == 'FAIL'
        MultiUE Stop traffic    ue_list=${ue_list}    apn=${apn0}
        sleep    2s
        MultiUE Start dlul traffic    ue_list=${ue_list}    apn=${apn0}    ues_dltput=${ues_dltput}
        ...    ues_ultput=${ues_ultput}
        sleep    30s
        ${dltput}    MultiUE Get dl tput on spark with 2CC CA    ue_list=${ue_list}
        MultiUE Check dl tput with 2CC CA    ue_list=${ue_list}    dltput=${dltput}    ues_exp=${ues_dlexp}
    END
    sleep    10s
#   Stop collect log by gnb tool
#    sleep    10s
#    ${CPlog}    Download CP log to target dir and unzip
#    Check CA activated via rrc log    rrclog=${CPlog}    scellid=74
    [Teardown]    run keywords    MultiUE Stop traffic    ue_list=${ue_list}    apn=${apn0}
    ...    AND    case_common_teardown
