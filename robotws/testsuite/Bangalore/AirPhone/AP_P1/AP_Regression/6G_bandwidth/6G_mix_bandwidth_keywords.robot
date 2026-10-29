*** Settings ***
Documentation     author: Kusuma S
...               contact: kusuma.s@nokia.com
...               Description: This testcase to test the 6G with different bandwidth

Resource    ../../../gNB_P1/External_L3_Call_Common_Keywords.robot

*** Variables ***
${DEFAULT_AP_IP}              192.168.200.1
${DEFAULT_GNB_IP}             192.168.255.129
${DEFAULT_SIXG}               yes
${DEFAULT_NON_AP_ENV_UPDATE}  true

*** Keywords ***
Test Setup With Bandwidth Config Update
    [Arguments]    ${custom_config}
    ${cmd}    Catenate
    ...    airphone-install config-update
    ...    --custom_config ${custom_config}
    ...    --sixg ${DEFAULT_SIXG}
    ...    --non_ap_env_update ${DEFAULT_NON_AP_ENV_UPDATE}
    ...    --gnb_ip ${DEFAULT_GNB_IP}
    ...    --external_server %{AP_LMP_SERVER}
    ...    --external_server_username %{AP_LMP_SERVER_USER}
    ...    --external_server_password %{AP_LMP_SERVER_PASSWD}
    ...    | tee config_update.log
    ${rc}    ${output}=    Run And Return RC And Output    ${cmd}
    Should Be Equal As Integers    ${rc}    0    Config update failed
    Log To Console    ${output}