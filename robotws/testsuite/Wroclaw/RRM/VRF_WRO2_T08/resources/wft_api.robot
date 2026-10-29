*** Settings ***
Documentation
...   maintainer: Tomasz Sobania
...   contact: tomasz.sobania@nokia.com

Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/wft_api.py
Library     taf.sbts.oam.coam.admin       WITH NAME   admin

*** Keywords ***
Get Software Builds
    [Arguments]  ${branch}=${None}  ${release_state}=${None}  ${promotion_tags}=${None}
    Wait Until Keyword Succeeds  10x  60sec  admin.setup_admin  alias=sw_checker
    setup admin connection  sw_checker
    ${gnb_build}  ${branch}=  Get Latest Build  branch=${branch}  release_state=${release_state}  promotion_tags=${promotion_tags}
    ${mode}=  Check Bts Mode  ${EXEC_DIR}  ${branch}
    ${enb_build}=  IF  '${mode}' == 'NSA'  Find Enb Build  ${branch}  ${gnb_build}
    RETURN  ${gnb_build}  ${enb_build}
    [Teardown]  admin.Teardown admin  alias=sw_checker
