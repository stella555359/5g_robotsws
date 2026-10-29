*** Settings ***
Suite Setup          CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           CBRS Test Setup
Test Teardown        CBRS Test Teardown

Variables    testsuite/Timisoara/Handover/CBRS/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/5GC001321/TestData/1321_variables.py
Resource    Resources/5GC001321_common_keywords.robot

Documentation
...    Author:linjiangjing & cailanwen & wangqingqing
...    contact:jiangjing.lin@nokia-sbell.com    lanwen.cai@nokia-sbell.com    qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature 5GC001321

Force Tags            RAN_5G_TDD    5G_RAN_TDD    master_classicalbts_all    RAN_5G    5G_RAN    STATE_SW_UPLOADED
...    21A_classicalbts    SBTS00    CLOUD_5G_CLASSICAL_ASKEY_SA_ASILL_ABIOB1_AZQC    CRT_22R4    CRT_23R1


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
[1]5GC001321_A_17_Verify_the_registration_with_groupID_groupType_configured_is_successful
    [Tags]    CIT_TRUNK    CDRT_22R2
    5GC001321_A_17_Verify_the_registration_with_groupID_groupType_configured_is_successful

[1]5GC001321_A_64_Verify_the_behavior_of_gNB_CBSD_Cell_Grant_Transmission_Timer_Expiry
    [Tags]    CIT_TRUNK    CDRT_22R2    CDRT_22R3
    5GC001321_A_64_Verify_the_behavior_of_gNB_CBSD_Cell_Grant_Transmission_Timer_Expiry

[1]5GC001321_A_66_Verify_the_behavior_of_heartbeat_Suspend_for_first_Grant_in_granted_status
    [Tags]    CIT_TRUNK    CDRT_22R2    CDRT_22R3
    5GC001321_A_66_Verify_the_behavior_of_heartbeat_Suspend_for_first_Grant_in_granted_status

[1]5GC001321_A_69_Verify_the_behavior_of_heartbeat_termination_for_first_Grant
    [Tags]    CIT_TRUNK    CDRT_22R2    CDRT_22R3
    5GC001321_A_69_Verify_the_behavior_of_heartbeat_termination_for_first_Grant

[1]5GC001321_A_71_Verify_the_behavior_of_CBSD_second_grant_successfully
    [Tags]    CIT_TRUNK    CDRT_22R2    CDRT_22R3
    5GC001321_A_71_Verify_the_behavior_of_CBSD_second_grant_successfully

[1]5GC001321_A_72_Verify_the_gNB_CBSD_reset_successfully
    [Tags]    CIT_TRUNK    CDRT_22R2    CDRT_22R3
    5GC001321_A_72_Verify_the_gNB_CBSD_reset_successfully

[1]5GC001321-E_3_Connect to SAS Mode Online Change from through https proxy to direct connect to SAS
    [Tags]    CRT_TRUNK    CDRT_22R2
    5GC001321-E_3_Connect to SAS Mode Online Change from through https proxy to direct connect to SAS
[1]5GC001321-E_6_Connect to SAS Mode Online Change from direct connect to SAS to through Domain Proxy
    [Tags]    CRT_TRUNK    CDRT_22R2
    5GC001321-E_6_Connect to SAS Mode Online Change from direct connect to SAS to through Domain Proxy
