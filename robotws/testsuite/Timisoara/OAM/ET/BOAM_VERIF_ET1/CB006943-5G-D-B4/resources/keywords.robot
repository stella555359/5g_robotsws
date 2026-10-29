*** Settings ***
Library        String
Library        OperatingSystem
Library        BuiltIn
Library        DateTime
Library        OperatingSystem
Library        SSHLibrary
Library        taf.transport.ssh    WITH NAME    ssh

Library     XML    use_lxml=True
Library        Process
Library        taf.gnb.oam.coam.admin.interface.admin   WITH NAME   taf_admin

Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/selenium.robot

*** Variables ***


*** Keywords ***

#Add Credentials To First Account
#    SELENIUM Set Name Of First O-RU Account  user
#    SELENIUM Set Pasword Of First O-RU Account  xranuser-password
#    SELENIUM Send O-RU Account Configuration And Check State Success
#
#Recreate Credentials To First Account in WebEM
#    SELENIUM Set Name Of First O-RU Account  user
#    SELENIUM Set Pasword Of First O-RU Account  xranuser-password
#    SELENIUM Send O-RU Account Configuration And Check State Failed
#
#Set Name Of First Account
#    [Arguments]    ${account_name}
#    ${result_code}=   SELENIUM Set Name Of First Account  ${account_name}
#    [return]  ${result_code}
#
#Add New O-RU Account
#    SELENIUM Add New O-RU Account
#
#Go To Netconf Radio Management Menu
#    SELENIUM Go To Netconf Radio Management
#
#Logout And Close Browser
#    SELENIUM Logout User From Web Element Manager
#    SELENIUM Teardown Environment




