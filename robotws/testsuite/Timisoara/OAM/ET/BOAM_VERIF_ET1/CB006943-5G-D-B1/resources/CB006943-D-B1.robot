*** Settings ***
Documentation

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
Resource    ./keywords.robot
Resource    ../../resources/selenium.robot
Resource    ./selenium.robot
Resource    ../../resources/orusim.robot
Resource    ../../resources/selenium_oru.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${oru1}=                    10.5.55.152
${oru2}=                    10.5.53.238

#${scf_default_1cell}=     ${CURDIR}/scf_MRBTS_23212_1ORAN2_1Cell.xml
${scf_default_1cell}=     ${CURDIR}/scf_MRBTS_23212_2ORAN2_2Cell.xml
${scf_default_2cell}=     ${CURDIR}/scf_MRBTS_23212_2ORAN2_2Cell.xml
${xranuser}=            xranuser
${xranpass}=            xran-password
${xranpasswrong}=       xran-passwor

${xranuser1}=            xranuser1
${xranpass1}=            xran1-password
${xranuser2}=            xranuser2
${xranpass2}=            xran2-password

${dist_name}=           MRBTS-10616/EQM-1/APEQM-1/RMOD-1
${pub_key_format}=      ssh-rsa
${AZQI-RMOD1}=          /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1
${AZQI-RMOD2}=          /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2

#${pub_key_value}=  SEPARATOR=
#...  AAAAB3NzaC1yc2EAAAADAQABAAABAQCp3cKcAb1WVmjg0p6Ud/GE8Ucu7GsCBvk4XUU1V+fxkVAM5QH32ySgwtdM1bNrdg1GLDy6hJAxYNxuw4W0ocMjUPZnsSCtLzA7bRbtSO
#...  mxS0evMtfku7KGpLb9u9ktQwKFXCmyQQzShkEH6DRCDENLChdNGyEGtsgvTAkh6X6jHavj9GgIQX1XKL0hU2Ujg9uUHWgm7cJOPLqk3rvigazgSwYPSUHSZ0nf4qKbDb04YPDi
#...  a7goDyJ3ZUdLlbDZRLlrHVCTVvNxGMPHs0QDZFJq+fVpnT8yC+wjUVx53xKKEG6QRbVu33vlAqTqqBd0Zc+jT4Cx+DpvV1l6JW+1Z8PV

${pub_key_value}=  SEPARATOR=
...  AAAAB3NzaC1yc2EAAAADAQABAAABAQDMUBFJ9gV/sqv8kJc/+honsh/wMemXtdzKZsSxXnlh8Mr1v0O+aRP7Rpg3cEqH3pttRm5UFNPW57TisrFEVYHQ65LojwofLhmAy2SPtr
...  S0+phquRNAMtTypenIynt5R0ShWkEpQzc/Z3F0IHPR4fUCOo053L3xTgisgF4dohcqYim446wibCdfmWpO3okYRp56udVOONaBncEobAXE+ltfAcb4G0gsPPvOmxnOxjf+NGFn
...  L5FwO1PKjLC8HmrL/O73gHuO687xGi4Rg5sdgPAuM1Nay5qjJ6eQqspVOmZjNhjkLR6VCC+xvqM4AKDZ4qDIoqE+Jr8YztId4/ptOtM3

${pub_key_value_wrong}=  SEPARATOR=
...  BBBBC3NzaC1yc2EAAAADAQABAAABAQCp3cKcAb1WVmjg0p6Ud/GE8Ucu7GsCBvk4XUU1V+fxkVAM5QH32ySgwtdM1bNrdg1GLDy6hJAxYNxuw4W0ocMjUPZnsSCtLzA7bRbtSO
...  mxS0evMtfku7KGpLb9u9ktQwKFXCmyQQzShkEH6DRCDENLChdNGyEGtsgvTAkh6X6jHavj9GgIQX1XKL0hU2Ujg9uUHWgm7cJOPLqk3rvigazgSwYPSUHSZ0nf4qKbDb04YPDi
...  a7goDyJ3ZUdLlbDZRLlrHVCTVvNxGMPHs0QDZFJq+fVpnT8yC+wjUVx53xKKEG6QRbVu33vlAqTqqBd0Zc+jT4Cx+DpvV1l6JW+1Z8PV


*** Keywords ***

Test12_Declare different default sudo Netconf account

    Log to console  Stop  O-RU
    Check_and_Stop_O-RU  ${oru1}
    Check_and_Stop_O-RU  ${oru2}

    Delete safe files on gNB
#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_default_2cell}
    ADMIN Reset Site
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is Commissioned

    SELENIUM Setup
    Go To Netconf Radio Management Menu

    SELENIUM Select Server DEACT SSH

    Log to console  Add New O-RU Account
    SELENIUM Add new O-RU Name and Netconf Account  ${xranuser}     ${xranpass}

    Log to console  Start O-RU1
    Check_and_Start_O-RU  ${oru1}


    Log to console   Check operationalstate online for RMOD_R-1
    Wait Until Keyword Succeeds    300    20    ADMIN INFOMODEL Check OperationalState Value
    ...      dist_name=${AZQI-RMOD1}
    ...      value=enabled

    Log to console  Add Second O-RU Account
    SELENIUM Add new second O-RU Name and Netconf Account  ${xranuser1}     ${xranpass1}


    Log to console  Start O-RU2
    Check_and_Start_O-RU  ${oru2}

    Log to console  Check operationalstate online for RMOD_R-2
    Wait Until Keyword Succeeds    300    20    ADMIN INFOMODEL Check OperationalState Value
    ...      dist_name=${AZQI-RMOD2}
    ...      value=enabled

    Log to console  Stop  O-RUs
    Check_and_Stop_O-RU  ${oru1}
    Check_and_Stop_O-RU  ${oru2}
    sleep  30
    Log to console  Start O-RUs
    Check_and_Start_O-RU  ${oru1}
    Check_and_Start_O-RU  ${oru2}
    sleep  60
    #####check operationalstate -online for RMOD_R-1
    Wait Until Keyword Succeeds    300    20    ADMIN INFOMODEL Check OperationalState Value
    ...      dist_name=${AZQI-RMOD1}
    ...      value=enabled
        #####check operationalstate -online for RMOD_R-2
    Wait Until Keyword Succeeds    300    20    ADMIN INFOMODEL Check OperationalState Value
    ...      dist_name=${AZQI-RMOD2}
    ...      value=enabled

Test14_Creation of additional sudo Netconf account

    Delete safe files on gNB
#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_default_2cell}
    ADMIN Reset Site
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is Commissioned

    Log to console  Stop  O-RU
    Check_and_Stop_O-RU  ${oru1}
    Check_and_Stop_O-RU  ${oru2}

    SELENIUM Setup
    Go To Netconf Radio Management Menu

    Log to console  Add First O-RU Account with additional netconf account
    Add New O-RU Account
    sleep  5
    SELENIUM Set Name Of First O-RU Account  ${xranuser}
    SELENIUM Set Pasword Of First O-RU Account  ${xranpass}
    ##Additional netconf account
    SELENIUM Configure Additional Netconf Account
    sleep  2
    SELENIUM Set Name Of Additional O-RU Account  ${xranuser2}
    SELENIUM Set Pasword Of Additional O-RU Account  ${xranpass2}
    sleep  2
#    SELENIUM Send O-RU Account Configuration And Check State Success
#    sleep  5

    Log to console  Add Second O-RU Account with different additional netconf account than SSDORU1

    Add New Second O-RU Account
    sleep  5
    SELENIUM Set Name Of First O-RU Account  ${xranuser1}
    SELENIUM Set Pasword Of First O-RU Account  ${xranpass1}
    ##Additional netconf account
    SELENIUM Configure Additional Netconf Account
    sleep  2
    SELENIUM Set Name Of Additional O-RU Account  ${xranuser1}
    SELENIUM Set Pasword Of Additional O-RU Account  ${xranpass1}
    sleep  2
#   SELENIUM Send O-RU Account Configuration And Check State Success
    Check Additional Netconf
    sleep  5

    Log to console  Add Second O-RU Account with same additional netconf account as SSDORU1
#   SELENIUM Configure Additional Netconf Account
    sleep  2
    SELENIUM Set Name Of Additional O-RU Account  ${xranuser2}
    SELENIUM Set Pasword Of Additional O-RU Account  ${xranpass2}
    sleep  2
    SELENIUM Send O-RU Account Configuration And Check State Success

    Log to console  Start O-RUs
    Check_and_Start_O-RU  ${oru1}
    Check_and_Start_O-RU  ${oru2}

    Logout And Close Browser
#### check conection O-DU->ORU is ok
    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir

Test9_SSH server authentication failure FID 4642

    Log to console   Preconditions
    Check_and_Stop_O-RU   ${oru1}

    Delete safe files on gNB
#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_default_1cell}
    ADMIN Reset Site
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is Commissioned

    Log to console   Start Selenium
    SELENIUM Setup
    Go To Netconf Radio Management Menu

    Log to console   Create default Netconf user account Public key based with wrong key

    SELENIUM Create default Netconf user account Public key based   ${pub_key_value_wrong}


    Log to console  Start O-RU
    Check_and_Start_O-RU  ${oru1}

    Log to console  Check Fault 4642
    Wait Until Keyword Succeeds    500    10    SYSTEM Check if fault is in active raw alarm  4642  EFaultId_SshServerAuthenticationFailureAl

    SELENIUM Close Pop If Visible
    Log to console   Correct default Netconf user account pub_key_value
    SELENIUM Set O-RU target key value    ${pub_key_value}
    SELENIUM Send O-RU Account Configuration And Check State Success

    Log to console  Check Fault 4642
    Wait Until Keyword Succeeds    300    10    SYSTEM Check if fault is not in active raw alarm  4642  EFaultId_SshServerAuthenticationFailureAl

    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir

#    Logout And Close Browser


Test6_Public key based SSH server authentication

    Log to console  Stop  O-RU
    Check_and_Stop_O-RU  ${oru1}

    Delete safe files on gNB
#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_default_1cell}
#    ...     skip_parameter_relation_errors=True
    ADMIN Reset Site
    Wait Until Keyword Succeeds    600    20    ADMIN INFOMODEL Check If BTS Is Commissioned

    SELENIUM Setup
    Go To Netconf Radio Management Menu

    ###  Create default Netconf user account Public key based
    SELENIUM Create default Netconf user account Public key based   ${pub_key_value}
    sleep  15
#    Logout And Close Browser
    Log to console  Start O-RU
    Check_and_Start_O-RU  ${oru1}

#### check conection O-DU->ORU is ok
    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir

    Log to console  Stop  O-RU
    Check_and_Stop_O-RU  ${oru1}

#    SELENIUM Setup
#    Go To Netconf Radio Management Menu
    Log to console   Public key based with wrong key
    SELENIUM Set O-RU target key value    ${pub_key_value_wrong}
    SELENIUM Send O-RU Account Configuration And Check State Success
#
#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_default_1cell}
#    ...     skip_parameter_relation_errors=True
    ADMIN Reset Site
    Wait Until Keyword Succeeds    400    20    ADMIN INFOMODEL Check If BTS Is Commissioned

    Log to console  Start O-RU
    Check_and_Start_O-RU  ${oru1}

   ## Check Fault 4642
    Wait Until Keyword Succeeds    300    2    SYSTEM Check if fault is in active raw alarm  4642  EFaultId_SshServerAuthenticationFailureAl

    Log to console  Stop  O-RU
    Check_and_Stop_O-RU  ${oru1}

    SELENIUM Click CLOSE BTN
    ###    SELENIUM Select Server NO AUTH METHODE

    SELENIUM Select Server NO AUTH
    sleep  5
    SELENIUM CONTINUE Pop If Visible

    sleep  5
    ### Add default O-RU Name and Netconf Account
    SELENIUM Add new O-RU Name and Netconf Account  ${xranuser}     ${xranpass}

    Log to console  Start O-RU
    Check_and_Start_O-RU  ${oru1}

    Wait Until Keyword Succeeds    300    2    SYSTEM Check if fault is not in active raw alarm  4642  EFaultId_SshServerAuthenticationFailureAl
    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir

Test8_SSH client authentication failure FID 4641

    Log to console  Stop the o-ru simulator
    Check_and_Stop_O-RU   ${oru1}

    Delete safe files on gNB
#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_default_1cell}
    ADMIN Reset Site
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is Commissioned


    SELENIUM Setup
    Go To Netconf Radio Management Menu
    Add New O-RU Account
    ## Set name with wrong password
    SELENIUM Set Name Of First O-RU Account  ${xranuser}
    SELENIUM Set Pasword Of First O-RU Account  ${xranpasswrong}
    SELENIUM Send O-RU Account Configuration And Check State Not Success
    sleep  10

    Log to console  Check  O-RU1 is started
    Check_and_Start_O-RU  ${oru1}
    sleep  5
    ## Check Fault 4641
    Wait Until Keyword Succeeds    600    2    SYSTEM Check if fault is in active raw alarm  4641  EFaultId_SshClientAuthenticationFailureAl
    ## Correct the password
    SELENIUM Set Pasword Of First O-RU Account  ${xranpass}
    SELENIUM Send O-RU Account Configuration And Check State Success
    sleep  10

    ## Check Fault 4641 cleared
    Wait Until Keyword Succeeds    200    20    SYSTEM Check if fault is not in active raw alarm  4641   EFaultId_SshClientAuthenticationFailureAl

    ###   Additional netconf account
    SELENIUM Configure Additional Netconf Account
    sleep  2
    SELENIUM Set Name Of Additional O-RU Account  ${xranuser2}
    SELENIUM Set Pasword Of Additional O-RU Account  ${xranpass2}
    sleep  2
    SELENIUM Send O-RU Account Configuration And Check State Success

    Wait Until Keyword Succeeds    300    20    SYSTEM Check if fault is in active raw alarm  0010  EFaultId_NoConnectionToUnitAl

    Wait Until Keyword Succeeds    900    20    ADMIN Check BTS onair

#    Logout And Close Browser

Test13_Netconf_user_account_format

    SELENIUM Setup
    Go To Netconf Radio Management Menu
    Add New O-RU Account
    Check User Name Entry Do Not Accept 2 Characters
    Check User Name Entry Do Not Accept First Leter Capital
    Check User Name Entry Do Not Accept 33 Characters
    Check User Name Entry Accept 4 Characters
    Check User Name Entry Accept 32 Characters
#    Logout And Close Browser

Test18_Default Netconf account setup failure_FID 4644

    ########## 1-st part ###########
    Log to console   Preconditions
    Check_and_Stop_O-RU   ${oru1}

    Delete safe files on gNB
#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_default_1cell}
    ADMIN Reset Site
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is Commissioned

    SELENIUM Setup
    Go To Netconf Radio Management Menu
    ### Send BTS level configuration ###

    sleep  5
    SELENIUM Send O-RU Account Configuration And Check State Success
    sleep   10
    Change_dir_rights_on_gNB  safe  555

    ADMIN Reset Site
    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is Commissioned
    SELENIUM Close Pop If Visible

    Go To Netconf Radio Management Menu
    Add New O-RU Account
    sleep  10
    ## Set name with ok password
    SELENIUM Set Name Of First O-RU Account  ${xranuser}
    SELENIUM Set Pasword Of First O-RU Account  ${xranpass}
#    SELENIUM Send O-RU Account Configuration And Check State Success
    SELENIUM Send O-RU Account Configuration And Check State Not Success
#  Check Fault 4644
    Wait Until Keyword Succeeds    120    20    SYSTEM Check if fault is in active raw alarm  4644  EFaultId_DefaultNetconfAccountCreationFailureAl

####### 2-nd part ###########

    ### Start the o-ru simulator ###
    Check_and_Start_O-RU      ${oru1}
    ### Change  safe dir rights ###
    Change_dir_rights_on_gNB  safe  777
    Delete safe files on gNB

#    ### Create O-RU Account ###

#    Go To Netconf Radio Management Menu
#    Add New O-RU Account
    sleep  10
    ## Set name with ok password
    SELENIUM Set Name Of First O-RU Account  ${xranuser}
    SELENIUM Set Pasword Of First O-RU Account  ${xranpass}
    SELENIUM Send O-RU Account Configuration And Check State Success
##  Check Fault 4644
    Wait Until Keyword Succeeds
    ...  120
    ...  20
    ...  SYSTEM Check if fault is not in active raw alarm  4644  EFaultId_DefaultNetconfAccountCreationFailureAI

#   Logout And Close Browser


Test23_LTE_OPR_REQ_27999_O-DU_shall_support_the_decommission_of_O-RUs

    Log to console   Preconditions
    Check_and_Stop_O-RU   ${oru1}

    Delete safe files on gNB
#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_default_1cell}
    ADMIN Reset Site

    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is Commissioned

    ## Start the o-ru simulator ###
    Check_and_Start_O-RU    ${oru1}

    SELENIUM Setup
    ### Scenario account cannot be delete only if O-RU was decomissioned
    Go To Netconf Radio Management Menu
    sleep  5
    ### Add default O-RU Name and Netconf Account
    SELENIUM Add new O-RU Name and Netconf Account  ${xranuser}     ${xranpass}

    Wait Until Keyword Succeeds    900    20    ADMIN Check BTS onair
    ### Delete default O-RU Account should fail
    Delete Credentials To First Account in WebEM Success
    SELENIUM Send O-RU Account Configuration And Check State Not Success

    ### Stop the o-ru simulator ###
    Check_and_Stop_O-RU   ${oru1}

    Wait Until Keyword Succeeds    120    20    SYSTEM Check if fault is in active raw alarm  0010  EFaultId_NoConnectionToUnitAl

    ### Add default O-RU Name and Netconf Account
    SELENIUM Add new O-RU Name and Netconf Account  ${xranuser}     ${xranpass}


    ###  Delete default O-RU Account success
    Delete Credentials To First Account in WebEM Success
    SELENIUM Send O-RU Account Configuration And Check State Success

#    Logout And Close Browser





