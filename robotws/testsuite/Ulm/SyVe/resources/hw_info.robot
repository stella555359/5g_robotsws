*** Settings ***

Documentation     Keywords related to gNB HW information
...             ...
...             Created to remove KW duplications in several SyVe test suites
...             ...


Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ../../resources/Common/connect.robot


*** Variables ***
${P_console}         ${False}

*** Keywords ***
Get HW info from gNB with cOAM
    [Arguments]     ${gnb_id}=${0}
    [Documentation]    get HW info from gNB
    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${hw_info}  admin.get_detected_hw_info    timeout=${30}    connection=${oam_alias}
    RETURN  ${hw_info}





### Private ###
