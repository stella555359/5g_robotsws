*** Settings ***
Suite Setup          CB009365-C CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           Run keywords    CB009365-C CBRS Test Setup    AND    AlarmWatchdog.add_allow_alarms    fault_id=16
Test Teardown        CB009365-C CBRS Test Teardown

Resource    resources/CB009365_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB009365

Force Tags    SBTS00


*** Variables ***
${if_update_swconfig}    ${FALSE}
${if_pdl_check}    ${TRUE}
&{FAULT_4655}     faultId=4655
&{FAULT_61524}    faultId=61524
&{FAULT_4654}     faultId=4654
&{FAULT_61652}    faultId=61652
&{FAULT_61649}    faultId=61649
&{FAULT_9000}     faultId=9000
&{FAULT_4592}     faultId=4592
&{FAULT_4527}     faultId=4527
&{FAULT_1932}     faultId=1932
&{FAULT_4334}     faultId=4334
&{FAULT_61074}    faultId=61074
&{FAULT_61618}    faultId=61618
&{FAULT_4687}     faultId=4687
&{FAULT_8150}     faultId=8150
&{FAULT_7312}     faultId=7312
&{FAULT_7313}     faultId=7313
&{FAULT_61628}    faultId=61628
&{FAULT_61029}    faultId=61029

@{ALLOWED_FAULT}    ${FAULT_4655}    ${FAULT_61524}    ${FAULT_4654}    ${FAULT_61652}    ${FAULT_61524}
...    ${FAULT_61649}  ${FAULT_9000}  ${FAULT_4592}  ${FAULT_4527}  ${FAULT_1932}  ${FAULT_4334}  ${FAULT_61074}  ${FAULT_61618}
...    ${FAULT_4687}  ${FAULT_4654}  ${FAULT_4655}  ${FAULT_8150}  ${FAULT_7312}  ${FAULT_7313}  ${FAULT_61628}  ${FAULT_61029}
@{ALLOWED_HISTORY_FAULT}  @{ALLOWED_FAULT}
${ru_type_init}    AWHQU    # ??? is this right ? "'AZQC'=='AEQN'" | 'remove fault 4687 from allowed fault list'
@{btslog_dirs}        /opt/btslog     /opt/ute/tools/btslog


*** Test Cases ***
[1]CB009365-C_A_16_Online_delete_higher_priority_CBRS_cell_in 2x2T2R split mode
    [Tags]    CRT_TRUNK    CIT_23R4
    CB009365-C_A_16_Online_delete_higher_priority_CBRS_cell_in 2x2T2R split mode

[1]CB009365-C_11_Frequency Selection Algorithm of one BTSes in 2x2T2R split mode with overlaping
    [Tags]    CRT_TRUNK    CIT_23R4
    CB009365-C_11_Frequency Selection Algorithm of one BTSes in 2x2T2R split mode with overlaping

[1]CB009365-C_64_online_add_and_delete_NR_cell_under_inter_BTS_split_mode
    [Tags]    CRT_TRUNK
    CB009365-C_64_online_add_and_delete_NR_cell_under_inter_BTS_split_mode
