*** Settings ***
Documentation
...     description:    Test cases for the CB006017 feature.

Resource                ../Resources/6017_Keywords.robot
Resource                ../../../common_resources/commissioning/parameters.robot
*** Keywords ***
CB006017-5G-A_02_Manually_trigger_the_Service_Account_synchronization_to_RU_RF_MODULE_with_WebEM
    Activate RU Synchronization via Netact
    Manually trigger the Service Account synchronization to RU RF MODULE
    [Teardown]      Deactivate RU Synchronization via Netact

CB006017-5G-A_04_Activate_Service_Account_synchronization_to_RU_RF_module_with_NetAct_NSP
    Activate RU Synchronization via Netact
    Hashes from BTS and RU for user should be equal           user=serviceuser
    [Teardown]      Deactivate RU Synchronization via Netact

CB006017-5G-A_05_Configure_SBTS_login_banner_text_from_NetAct
    ${default_banner}=     Get default value from initial SCF      p_name=platLoginBannerText
    ${new_banner}=         Set Variable                            ~!@#$%^&*()_+|}{:"?><,./;'[05 Test Banner]\=-`
    Change SSH parameter value via Netact                          parameter=platLoginBannerText
    ...                                                            value=${new_banner}
    Activate RU Synchronization via Netact
    Banners on RU and BTS should be equal
    [Teardown]     Run Keywords
    ...            Change SSH parameter value via Netact           parameter=platLoginBannerText
    ...                                                            value=${default_banner}
    ...            AND
    ...            Deactivate RU Synchronization via Netact

CB006017-5G-A_07_BTS_Service_Account_Password_Provisioning_via_WebEM
    Change password for user                                  user=serviceuser
    ...                                                       new_password=${SERVICEUSER_NEW_PASSWORD}
    ...                                                       old_password=${SERVICEUSER_DEFAULT_PASSWORD}
    Activate RU Synchronization via Netact
    Hashes from BTS and RU for user should be equal           user=serviceuser
    ...                                                       ru_password=${SERVICEUSER_NEW_PASSWORD}
    Check if login on RU was successful for user              user=serviceuser
    ...                                                       password=${SERVICEUSER_NEW_PASSWORD}
    [Teardown]     Run Keywords
    ...            Change password for user                   user=serviceuser
    ...                                                       new_password=${SERVICEUSER_DEFAULT_PASSWORD}
    ...                                                       old_password=${SERVICEUSER_NEW_PASSWORD}
    ...            AND
    ...            Sleep                                      time_=60s
    ...                                                       reason=Waiting for the password to change
    ...            AND
    ...            Deactivate RU Synchronization via Netact

CB006017-5G-A_10_BTS_SSH_Client_Alive_Timer_Provisioning_via_NetAct
    ${default_value}=       Get default value from initial SCF                       p_name=sshClientAliveTimer
    ${new_value}=           Evaluate    ${default_value} + ${5}
    Change SSH parameter value via Netact                                            parameter=sshClientAliveTimer
    ...                                                                              value=${new_value}
    Activate RU Synchronization via Netact
    SSH Parameters on RU and BTS should be equal
    [Teardown]      Run Keywords
    ...             Change SSH parameter value via Netact                            parameter=sshClientAliveTimer
    ...                                                                              value=${default_value}
    ...             AND
    ...             SSH Parameters on RU and BTS should be equal
    ...             AND
    ...             Deactivate RU Synchronization via Netact

CB006017-5G-A_11_BTS_ssh_Session_Login_Delay_Provisioning_via_NetAct
    ${default_value}=       Get default value from initial SCF                       p_name=sshSessionLoginDelayTimer
    ${new_value}=           Evaluate    ${default_value} + ${5}
    Change SSH parameter value via Netact                                            parameter=sshSessionLoginDelayTimer
    ...                                                                              value=${new_value}
    Activate RU Synchronization via Netact
    Values for sshLoginDelayTimer should be equal on BTS and RU
    [Teardown]      Run Keywords
    ...             Change SSH parameter value via Netact                            parameter=sshSessionLoginDelayTimer
    ...                                                                              value=${default_value}
    ...             AND
    ...             Values for sshLoginDelayTimer should be equal on BTS and RU
    ...             AND
    ...             Deactivate RU Synchronization via Netact

CB006017-5G-A_14_SSH_Login_parameters_Synchronization
    Download SCF    local_path=${CURDIR}
    ${client_alive_default_value}=          Get default value from initial SCF          p_name=sshClientAliveTimer
    ${login_delay_default_value}=           Get default value from initial SCF          p_name=sshSessionLoginDelayTimer
    ${banner_default_value}=                Get default value from initial SCF          p_name=platLoginBannerText
    ${client_alive_new_value}=              Evaluate    ${client_alive_default_value} + ${5}
    ${login_delay_new_value}=               Evaluate    ${login_delay_default_value} + ${5}
    ${banner_new_value}=                    Set Variable        ~!@#$%^&*()_+|}{:"?><,./;'[14 Test Banner]\=-`
    Change Multiple Parameters on BTS
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...    sshClientAliveTimer=${client_alive_new_value}
    ...    sshSessionLoginDelayTimer=${login_delay_new_value}
    ...    platLoginBannerText=${banner_new_value}
    Change Parameter on BTS
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...    param_name=actSyncToRU
    ...    param_value=true
    Banners on RU and BTS should be equal
    SSH Parameters on RU and BTS should be equal
    [Teardown]  Run Keyword And Ignore Error
    ...                     Change Multiple Parameters on BTS     dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                                           sshClientAliveTimer=${client_alive_default_value}
    ...                                                           sshSessionLoginDelayTimer=${login_delay_default_value}
    ...                                                           platLoginBannerText=${banner_default_value}
    ...                                                           actSyncToRU=false


CB006017-5G-A_15_Root_access_disable_on_RU_check
    ${sw_ver}=         Get Software Release Name
    Run Keyword If     """${sw_ver}""" == """SBTS22R1"""
    ...                Check if login on RU was successful for user        user=root        password=${RU_ROOT_PASSWORD}
    ...        ELSE    Check if login on RU was not successful for user    user=root        password=${RU_ROOT_PASSWORD}
    Activate RU Synchronization via Netact
    Check if login on RU was not successful for user    user=root           password=${RU_ROOT_PASSWORD}
    Check if login on RU was successful for user        user=serviceuser    password=${SERVICEUSER_DEFAULT_PASSWORD}
    [Teardown]        Deactivate RU Synchronization via Netact
