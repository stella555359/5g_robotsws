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
${O-RU_username}=                oru
${O-RU_password}=                orusim12

${scf_Delta}                ${CURDIR}/scf_Delta_actECcpriRuMplanSwcurity_Enable.json
#${scf_default_1cell}=       ${CURDIR}/scf_MRBTS-23212_1ORAN2-1Cell.xml

${xranuser}=            xranuser
${xranpass}=            xran-password

*** Keywords ***
Test1 Disable IPsec for O-RUs

    Log to console  Start O-RU
    Check_and_Start_O-RU  ${oru1}

    Delete safe files on gNB
#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_default_1cell}
#    ADMIN Reset Site
#    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is Commissioned
#
#    Log to console  Add Netconf Account
#    SELENIUM Setup
#    Go To Netconf Radio Management Menu
#
#    ### Add default O-RU Name and Netconf Account
#    SELENIUM Add new O-RU Name and Netconf Account  ${xranuser}     ${xranpass}
#
#    ### check before conection O-DU->ORU is ok
#    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir
#
#    log to console  Perform Delta Commissioning  actECcpriRuMplanSwcurity=RuProtectEnable
#    ADMIN Perform Delta Recommissioning     ${scf_Delta}  True
#
#    ### check after conection O-DU->ORU is ok
#    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir
#
#    Log to console  Check Fault 4667
#    Wait Until Keyword Succeeds    100    10    SYSTEM Check if fault is not in active raw alarm  4667  EFaultId_IpSecOnRadioModuleUnsupportedAl
#
#    ADMIN Reset Site
#    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir




