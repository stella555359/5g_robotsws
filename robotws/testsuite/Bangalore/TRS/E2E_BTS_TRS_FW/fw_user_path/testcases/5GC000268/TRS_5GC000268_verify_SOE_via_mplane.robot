*** Settings ***
Documentation
...     [Procedure]     "SOE verification after configuration reset and with mplane ip , and without mplane ip configuration"
...     [Author]        "Nandini P"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Function_Hash_Tags]    "SOE"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/resources/5G_Common_SOE.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Library         Selenium2Library

Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops


***Test Cases***
[1]TRS_5GC000268_verify_SOE_with_configuration_reset
##configuration reset is performed
       Reset   operation=reset_configuration    remove_user_account_credentials=True   remove_operator_certificates=True
       Sleep    900
       Verify SOE is enabled

       Change Ethernet port security       enable=${False}   timeout=120     alias=default
       Verify SOE is disabled

       Change Ethernet port security       enable=${True}  timeout=120     alias=default
       Verify SOE is enabled

[1][1.0] TRS_5GC000268_verify_SOE_via_mplane
        Perform Commissioning       scf_file=${SOE_enabled_commissioning}   verify_bts_status=${False}     timeout=600     alias=default
        Sleep    900
        Verify SOE is enabled
        Read mplane IP
        Check nmap status for '${mplane_ipv4}' '${NMAP_COMMAND}'
        Check nmap status for '${mplane_ipv6}' '${NMAP6_COMMAND}'

       Perform Recommissioning     type=param      param_path=${SOE_Moc}  operation=update    value=true     timeout=300
       Verify SOE is enabled

        'Disable' Ethernet port security via '${mplane_ipv4}'
          Verify SOE is disabled

        'Enable' Ethernet port security via '${mplane_ipv4}'
        Verify SOE is enabled

        'Disable' Ethernet port security via '${mplane_ipv6}'
        Verify SOE is disabled

        'Enable' Ethernet port security via '${mplane_ipv6}'
        Verify SOE is enabled

verify SOE without mplane being configured
       Perform Recommissioning     type=param      param_path=${dual_stack_mplane_flag}  operation=delete     value=''   timeout=300
       Perform Recommissioning     type=param      param_path=${mplane_ipv4_DN}  operation=delete    value=' '      timeout=300
       Perform Recommissioning     type=param      param_path=${mplane_ipv6_DN}  operation=delete     value=' '      timeout=300

      Perform Recommissioning     type=param       param_path=${SOE_Moc}  operation=update    value=true     timeout=300
      Verify SOE is enabled

       Change Ethernet port security       enable=${False}   timeout=120     alias=default
       Verify SOE is disabled

      Change Ethernet port security       enable=${True}  timeout=120     alias=default
      Verify SOE is enabled

***Keywords***
Change SOE status with save config network plan
      open browser     https://192.168.255.129/       gc
     Maximize Browser window
     Sleep   2
    Input Text      userName        Nemuadmin
    Input password      password    nemuuser
    Click Button        Login
    Sleep   10
    Click Button        Confirm
    Sleep  2
    Sleep   2
    Click Element    xpath=/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[7]
    Sleep   2
    Click Element   xpath=/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[7]/div/ng-transclude/div/div[2]
    Sleep   5
    Click Element         xpath=//*[@id="TA-Checkbox-smallcheck"]/span
    Sleep  5
    Click Element         xpath=//*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/div/div[1]/
    ... ethernet-port-security/div/div/div[2]/div[2]/ui-button/button
    Sleep    30
    [Teardown]      Close Browser

Read mplane IP
        ${mplane_ipv4}=     Get Parameter   param_path=${mplane_ipv4_ip_moc}
        Set Suite Variable          ${mplane_ipv4}

        ${mplane_ipv6}=     Get Parameter   param_path=${mplane_ipv6_ip_moc}
        Set Suite Variable          ${mplane_ipv6}
