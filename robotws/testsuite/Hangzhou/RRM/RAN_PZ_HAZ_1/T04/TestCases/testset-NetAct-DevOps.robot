*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com

Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      TRUNK             #Tag Item
...      DevOps             #Tag Item

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../CB009881/VRAN_SyVe_CB009881_CB006543_001_CM_Verify_Data_Filtering_For_Upload_And_notification_Via_NetAct.robot
Resource          ../CB008936/VRAN_SyVe_CM_Delta_Plan_Online_Validation_with_Validation_Scope_Setting_CB008936_003.robot
Resource          ../CB008660/VRAN_SyVe_CM_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity_CB008660-A_004.robot

Library           ute_reporting_portal
Variables         ../TestCases/My_NetAct.py

*** Variables ***
${cu_ip}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${cu_release}    23R2VCU
${cu_mr}    MRC-CB006543/MR-vCU
${du_ip}     ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
${du_release}    23R2VDU
${du_mr}    MRC-CB006543/MR-vCU
${build}    vDUCNF00_0.300.11240
${vDU_id}           ${tl.gnbs[0].dus[0].instance_id}
${vCU_id}           ${tl.gnbs[0].instance_id}
${Report_Rep}     ${False}
&{plan_info_8660_004}      scf_distName=MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1
...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1  parent_param=e2Plane    param_name=mPlaneIpv4AddressDN
...    shortenedDN=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2  incorrect_shortenedDN=IPADDRESSV4-2
...    originDN=MRBTS-${vDU_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
${TNL_OBJ}    MRBTS-${vDU_id}/TNLSVC-1/TNL-1
${DUMMY_OBJ}     MRBTS-${vDU_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2

## for vDU-11085
#&{plan_info_8660_004}      scf_distName=MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1
#...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1  parent_param=e2Plane    param_name=mPlaneIpv4AddressDN
#...    shortenedDN=TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-2  incorrect_shortenedDN=IPADDRESSV4-2
#...    originDN=MRBTS-${vDU_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1
#
#${TNL_OBJ}    MRBTS-${vDU_id}/TNLSVC-1/TNL-1
#${DUMMY_OBJ}     MRBTS-${vDU_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-2

*** Test Cases ***
CB008936_003
    [Tags]    CB008936
    [Timeout]    120 minutes
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    10.01.2022, lixin.kang@nokia-sbell.com, draft
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CM_Delta_Plan_Online_Validation_with_Validation_Scope_Setting_CB008936_003
    ...    AND    Case Precondition    False    False    #True    True
    TC__VRAN_SyVe_CM_Delta_Plan_Online_Validation_with_Validation_Scope_Setting_CB008936_003
    [Teardown]    Run Keywords    Case Postcondition
    #...    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    #...    Report To Reporting Portal
    #...    [1.0] RAN_SyVe_CB008936_003_CM_Delta plan online validation in Netact with validation scope setting    483802

CB009881_CB006543_001
    [Tags]    CB009881
    [Timeout]    120 minutes
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    28.12.2022, yuyan.xu@nokia-sbell.com, draft
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CB009881_CB006543_001_CM_Verify_Data_Filtering_For_Upload_And_notification_Via_NetAct
    ...    AND    Case Precondition    False    False
    VRAN_SyVe_CB009881_CB006543_001_CM_Verify_Data_Filtering_For_Upload_And_notification_Via_NetAct
    [Teardown]    Run Keywords    Case Postcondition
    #...    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    #...    Report To Reporting Portal
    #...    [1.0] vRAN_SyVe_CB009881_CB006543_001_CM_Verify data filtering for upload&notification operation from NMS    472308

CB008660-A_004
    [Tags]    CB008660_004
    [Timeout]    120 minutes
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    30.01.2022, lixin.kang@nokia-sbell.com, draft
    [Setup]    Run Keywords    Set Library Search Order
    ...    VRAN_SyVe_CM_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity_CB008660-A_004
    ...    AND    Case Precondition    False    False    #True    True
    TC__VRAN_SyVe_CM_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity_CB008660-A_004
    [Teardown]    Run Keywords    Case Postcondition
    #...    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    #...    Report To Reporting Portal
    #...    [1.0] VRAN_SyVe_CB008660-A_004_CM_Adding an object breaking (or not) existing distname unambiguity to the live NE    502735

*** Keywords ***
Report To Reporting Portal
    [Arguments]    ${test_run}    ${qc_instance_id}    ${status}=passed
    [Documentation]    Keyword send report to reporting portal and return link
    Run Keyword If  "${Report_Rep}"=="${False}"    Return From Keyword
    ${qc_domain}=    set variable    MN_RAN
    ${qc_project}=    set variable    RAN_VRF
    ${ca}=    convert to string    RAN_PZ_HAZ_1
    &{empty_dict}=    Create Dictionary
    ${add_info}    Create List
    ${testline_name}    Set Variable    5G_Hangzhou_UTE5GAIC015T0011083
    log    ${testline_name}    console=${True}
    ${active_sw_version}    Get vDU Version
    ${current_prefix}    Set Variable    ${active_sw_version.split('_')[0].strip()}
    ${current_release}    Set Variable If    "${current_prefix}" == "${Trunk_Prefix}"    vDUCNF00    ${current_prefix}
    ${version_num}    Fetch From Right    ${active_sw_version}    _
    ${build}    Set Variable    ${current_release}_${version_num}
    ${link_to_reporting_portal}=    report to rp    qc_domain=${qc_domain}    qc_project=${qc_project}
    ...    name=${test_run}    result=${status}    ca=${ca}    build=${build}    links=&{empty_dict}    tool=Robot
    ...    add_info=${add_info}    testline=${testline_name}    qc_id=${qc_instance_id}
    set suite variable    ${LINK_TO_RP}    ${link_to_reporting_portal}
