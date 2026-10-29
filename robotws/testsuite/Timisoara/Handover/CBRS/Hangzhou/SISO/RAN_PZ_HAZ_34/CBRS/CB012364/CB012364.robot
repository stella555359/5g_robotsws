*** Settings ***
Suite Setup          CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           CBRS Test Setup
Test Teardown        CB012364 CBRS Test Teardown

Resource    Resources/CB012364_common_keywords.robot


Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB012364

Force Tags    CRT_TRUNK


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

@{ALLOWED_FAULT}    ${FAULT_4655}    ${FAULT_61524}    ${FAULT_4654}    ${FAULT_61652}    ${FAULT_61524}
...    ${FAULT_61649}  ${FAULT_9000}  ${FAULT_4592}  ${FAULT_4527}  ${FAULT_1932}  ${FAULT_4334}  ${FAULT_61074}  ${FAULT_61618}
...    ${FAULT_4687}  ${FAULT_4654}  ${FAULT_4655}  ${FAULT_8150}  ${FAULT_7312}  ${FAULT_7313}  ${FAULT_61628}
@{ALLOWED_HISTORY_FAULT}  @{ALLOWED_FAULT}
${ru_type_init}    AEQM    # ??? is this right ? "'AZQC'=='AEQN'" | 'remove fault 4687 from allowed fault list'
@{btslog_dirs}        /opt/btslog     /opt/ute/tools/btslog


*** Test Cases ***
[1]CB012364-A_01_NR_static_Mplane_connect_to_IPV6_Primary_DP_IP_port
    [Tags]    CIT_TRUNK
    CB012364-A_01_NR_static_Mplane_connect_to_IPV6_Primary_DP_IP_port
