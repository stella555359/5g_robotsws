*** Settings ***
Documentation
    ...  This test case is created to perform changes on platLoginBannerText parameter.
    ...  Connect on VM via SSH.
    ...  Reading the initial value of platLoginBannerText.
    ...  Change platLoginBannerText parameter
    ...  Verify if parameter was change.
    ...  Change platLoginBannerText parameter in initial value.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Check_platLoginBannerText
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22351
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 16.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22351 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS21

    Step1: Change PlatLoginBannerText Parameter


Step1: Change PlatLoginBannerText Parameter
    Log  Step1: Change platLoginBannerText parameter  console=true
    Log  Trying to connect on VM via SSH!  console=true
    ssh.Connect To  ${PC_IP1}  ute  ute  alias=vm
    ${plat_login_banner_before_change}  ssh.Execute  sshpass -p ${SMOD1}[PASSWORD] ssh 192.168.255.129 -l ${SMOD1}[USERNAME] & sleep 5 ; exit
    ...  connection=vm  timeout=30s
    ${plat_login_banner_before_change}  Fetch From Right  ${plat_login_banner_before_change}  .\r\r\n
    ${plat_login_banner_before_change}  Fetch From Left  ${plat_login_banner_before_change}  \r\nLast login
    Log  \n platLoginBannerText initial value is: ${plat_login_banner_before_change}  console=true
    ${status}  Run Keyword And Return Status
    ...  Change PlatLoginBannerText Parameter  example_text
    Run Keyword If  ${status}
    ...  Log  \n platLoginBannerText parameter value is changed![OK]  console=true
    ...  ELSE
    ...  Fail  \n platLoginBannerText parameter value is not change![NOK]
    ${login_output}  ssh.Execute  sshpass -p ${SMOD1}[PASSWORD] ssh 192.168.255.129 -l ${SMOD1}[USERNAME] & sleep 5 ; exit  connection=vm
    ...  timeout=30s
    ${text1}  Fetch From Right  ${login_output}  .\r\r\n
    ${plat_login_banner_after_change}  Fetch From Left  ${text1}  \r\nLast login
    ${status_after_change}  Run Keyword And Return Status
    ...  Should Contain  ${plat_login_banner_after_change}  example_text
    Run Keyword If  ${status_after_change}
    ...  Log  \n platLoginBannerText value after change is: ${plat_login_banner_after_change}!  console=true
    ...  ELSE
    ...  Fail  \n platLoginBannerText value after change is incorrect![NOK]
    ${status}  Run Keyword And Return Status
    ...  Change PlatLoginBannerText Parameter  ${plat_login_banner_before_change}
    Run Keyword If  ${status}
    ...  Log  platLoginBannerText parameter value is changed to ${plat_login_banner_before_change}![OK]  console=true
    ...  ELSE
    ...  Fail  platLoginBannerText parameter value is not change![NOK]


Change PlatLoginBannerText Parameter
    [Arguments]  ${plat_login_banner_text}

    ${bts_info}  Get_bts_info
    ${mrbts}  Set Variable  ${bts_info["id"]["configuration"]}
    Perform_parameter_recommissioning  dist_name=${mrbts}/MNL-1/MNLENT-1/SECADM-1  parameter=platLoginBannerText  value=${plat_login_banner_text}
    ...  operation=update  skip_parameter_relation_errors=true  timeout=900
    Log  \n Parameter value will be change into: ${plat_login_banner_text}!  console=true


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
