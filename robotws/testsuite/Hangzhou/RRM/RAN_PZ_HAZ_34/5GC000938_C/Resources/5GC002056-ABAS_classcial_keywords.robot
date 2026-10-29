*** Settings ***
Documentation     author: fraxu
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: frank.1.xu@nokia-sbell.com

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    taf.ul.oam.selenium_coam    WITH NAME    seleniumC
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME   coam_classical
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands

Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot

*** Variables ***
${OAM_IP}                       ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_LOGIN}                     toor4nsn
${DU_PASSWORD}                  oZPS0POrRieRtu
${remote_path_DU}               /tmp
${BTS_PATH}                     MRBTS-10042/NRBTS-10042
${WEBUI_USER}                   Nemuadmin
${WEBUI_PWD}                    nemuuser
${WEBUI_URL}                    https://${OAM_IP}
${SCF_TEMPLATE_PATH}            ${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G402T923
${SCF_name}                     SCF_PCMD.xml



*** Keywords ***
Modify actPCMDReport to true On Local gNB
    [Arguments]    ${actPCMDReport}
    BuiltIn.Log    Modify actPCMDReport paramter...     console=${True}
#    Create cOAM session with alias    port=443
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-10042/NRBTS-10042    parameter=actPCMDReport
    ...    operation=update    value=${actPCMDReport}    connection=COAM
    #Update SCF parameter    value=${actPCMDReport}    parameter=actPCMDReport
    #...    dist_name=MRBTS-10042/NRBTS-10042
    [Teardown]    Teardown cOAM session

Modify actPCMDReport to false On Local gNB
    [Arguments]    ${actPCMDReport}
    BuiltIn.Log    Modify actPCMDReport paramter...     console=${False}
#    Create cOAM session with alias    port=443
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-10042/NRBTS-10042    parameter=actPCMDReport
    ...    operation=update    value=${actPCMDReport}    connection=COAM
    #Update SCF parameter    value=${actPCMDReport}    parameter=actPCMDReport
    #...    dist_name=${dist_name}
    [Teardown]    Teardown cOAM session

NOM WebEM Login
    [Documentation]    NOM login via webui
    ...                login url is defined in variables.robot as NOM_1_WEBUI_LINK
    ...  author:             hongping.rao@nokia-sbell.com
    ...  modified by:        <31-July-2020>, <horao>, <initial created>
    ...    | Input Parameters | Man. | Description |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | NOM WebEM Login |
    nom_selenium.Login    ${NOM_1_WEBUI_LINK}

NOM WebEM Logout
    [Documentation]    NOM WebEM Logout
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...   None
    ...    Example
    ...   | NOM WebEM Logout |
    nom_selenium.logout

Common Suite Setup for COAM
    CI_interface.Common Suite Setup

Common Suite Teardown for COAM
    Run Keyword And Ignore Error    AdminCli disconnection and Test teardown

Check ESTABLISHED Not Empty
    [Arguments]   ${connection}=COAM
    ${output}    csn.execute    netstat -ant|grep 48151 |grep 10.68.88.254 | awk '{print $4}'| tail -n 1    connection=ASIB_Mater
    Should not be empty    ${output}

Check ESTABLISHED Empty
    [Arguments]   ${connection}=COAM
    ${output}    csn.execute    netstat -ant|grep 48151 |grep 10.68.88.254 | awk '{print $4}'| tail -n 1    connection=ASIB_Mater
    Should be empty    ${output}

Connect to DU
    ssh.connect_to              hostname=${OAM_IP}      username=${DU_LOGIN}        password=${DU_PASSWORD}    alias=ASIB_Mater

Disconnect from DU
    ssh.disconnect    connection=ASIB_Mater

COAM.GetParameterValue
    [Arguments]    ${distName}=MRBTS-322    ${abbr}=BTS name
    ${value}   Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.get_parameter_value    dist_name=${distName}    search_text=${abbr}
    [Return]       ${value}

COAM.SetParameterValue
    [Arguments]    ${distName}=MRBTS-10042    ${abbr}=BTS name    ${value}=TL923
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value    dist_name=${distName}    search_text=${abbr}    new_value=${value}    timeout=40

COAM.ValidateAndActiveParameters
    Sleep  10
    ${error}    selenium_coam.validate_plan
    #${error}    selenium_megazone.get_validation_error
    #should be empty    ${error}
    Sleep  10
    selenium_coam.activate_plan     activate_plan_despite_errors=True
    Sleep  10

