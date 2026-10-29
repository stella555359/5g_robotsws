*** Settings ***
Documentation
...     [Procedure]             "SOE verification with parameter disable, enable and persistency check after upgrade"
...     [Author]                "Nandini P"
...     [Maintenance]           "TRS I & V Bangalore Team"
...     [Function_Hash_Tags]    "SOE"


#Comment : Verify SOE with TWAMP configuration , TWAMP should not have nay impact on SOE

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

[1][1.0] TD.TT.LTE593_07_02_Online_enable_SOE_Ethernet_verification
       Perform Commissioning       scf_file=${SOE_enabled_commissioning}   verify_bts_status=${False}     timeout=500     alias=default
       Verify SOE is enabled
       Check snapshot collection and IM snapshot is successful
       SSH and R&D should not have any impact
       Verify alarm        expected_alarms=${expected_alarms}

       Perform Recommissioning     type=param           param_path=${SOE_Moc}  operation=update    value=false     timeout=300
       Verify SOE is disabled
       Check snapshot collection and IM snapshot is successful
       SSH and R&D should not have any impact
       Perform Recommissioning     type=param           param_path=${SOE_Moc}  operation=update    value=true     timeout=300
       Verify SOE is enabled

       Perform software upgrade and Check SOE is enabled
     Change Ethernet port security       enable=${False}   timeout=120     alias=default
     Verify SOE is disabled
     SSH and R&D should not have any impact

     Change Ethernet port security       enable=${True}  timeout=120     alias=default
     Verify SOE is enabled
     SSH and R&D should not have any impact

***Keywords***
Change SOE status with save config network plan
    open browser     https://192.168.255.129/       firefox
     Maximize Browser window
     Sleep   2
    Input Text      userName        Nemuadmin
    Input password      password    nemuuser
    Click Button        Login
    Sleep   10
    Click Button        Confirm
    Sleep  2
    Sleep   20
    Click Element    xpath=/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[7]
    Sleep   2
    Click Element   xpath=/html/body/main-view/div/div[1]/app-header/main-menu/nav-item[7]/div/ng-transclude/div/div[2]
    Sleep   5
    Click Element         xpath=//*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/div/div[1]/ethernet
    ... -port-security/procedure-execution/div/ng-transclude/div/div/div[2]/ui-button/button
    Sleep    30
    [Teardown]      Close Browser

Perform software upgrade and Check SOE is enabled
       Perform software download and update     wft_profile=sbtstrunk_00    package=auto        activate_sw=true        update_timeout=1200
       sleep    300
       Verify SOE is enabled
       ${soe_status}=      Get Parameter      param_path=${SOE_Moc}
       Should Be True     '${soe_status}'=='True'
       Verify alarm        expected_alarms=${expected_alarms}