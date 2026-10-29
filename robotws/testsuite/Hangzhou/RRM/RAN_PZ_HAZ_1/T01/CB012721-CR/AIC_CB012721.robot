*** Settings ***
Documentation
...   Author: Zhan Yangjun
...   Contact: yangjun.zhan@nokia-sbell.com
...   Description: CB012721-CR NFTA2.0
...    Deprecated case removed by civen.chen
#
#Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
#
#Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    STATE_SKIP_AGENT
#...               CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG01_ST_RRM    TA_LEVEL_22
#Suite Setup       Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC
#Test Setup        Common Test Setup For AIC
#Test Teardown     Common Test Teardown For AIC
#
#
#
#*** Variables ***
#${scf_path_file_test1}    ${CURDIR}/TC33_34.xml
#${scf_path_file_test2}    ${CURDIR}/TC37_38.xml
#${gnb_index}    0
##QC part
#${TC33_passed}    ${False}
#
#${INSTALL_BUILD}    NO
#
#*** Test Cases ***
#TC33_BTS_Operation_Commission
#    [Tags]    CRT   QC_117732
#    [Documentation]
#    ...    Author: Zhan Yangjun
#    ...    history change: <date>,<who>,<what and how>
#    ...    16.10.2024, yangjun.zhan@nokia-sbell.com, draft
#    [Setup]    Common Test Setup For AIC
#    [Timeout]    72h
#
#    CU Check Maximum Plan Number And Delete One If Reach Maximum Number
#    ${res}   vCU Update Full SCF And Only Validate Plan      path_of_commission_file=${scf_path_file_test1}
#    Should Be True    ${res['total']}==0
#    CU Check Maximum Plan Number And Delete One If Reach Maximum Number
#    ${res}   vCU Update Full SCF And Only Validate Plan      path_of_commission_file=${scf_path_file_test2}
#    Should Be True    ${res['total']}==18
#    Set Suite Variable    ${TC33_passed}    ${True}
#    [Teardown]    Common Test Teardown For AIC
#
#[1][1.0] CB012721_TC34
#    [Documentation]
#    [Tags]    CRT   QC_117733
#    [Setup]    Empty Setup
#    should be true    ${TC33_passed}
#    [Teardown]
#
#*** Keywords ***
#
#CU Check Maximum Plan Number And Delete One If Reach Maximum Number
#    Login To vCU By Rest
#    ${all_plans}   cu.get_staged_plans_list
#    Should Be True  ${all_plans.__len__()}<=3
#    Run Keyword If  ${all_plans.__len__()}==3   Log To Console  ${all_plans[0]["plan_name"]}/${all_plans[0]["plan_id"]} will be deleted!
#    Run Keyword If  ${all_plans.__len__()}==3   cu.plan_delete   plan_id=${all_plans[0]["plan_id"]}
#    Run Keyword And Ignore Error  Logout To vCU By Rest
#
#Empty Setup
#    Log To Console  Ok
