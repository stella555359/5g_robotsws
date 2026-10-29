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

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${oru1}=                        10.5.53.237
${O-RU_username}=                o-ru_simulation
${O-RU_password}=                o-ru_4321

${SW_DESTINATION}=     /home/ute/Downloads/
${SW_TARGET}=           SBTS22R2_ENB_0000_000496_000000_release_BTSSM_downloadable_A54.zip

${AZQI-RMOD1}=          /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1
${scf_default_1cell}=     ${CURDIR}/scf_MRBTS-23212_1ORAN2_1cell.xml
${xranuser}=            xranuser
${xranpass}=            xran-password

${xranuser2}=            xranuser2
${xranpass2}=            xran2-password

*** Keywords ***
Test1 Rollback with original SSD Data change before upgrade retry

#    Log to console  Start O-RUs
#    Check_and_Start_O-RU  ${oru1}
#
#    Delete safe files on gNB
#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_default_1cell}
#
#
#    Wait Until Keyword Succeeds    200    20    ADMIN INFOMODEL Check If BTS Is Commissioned
#
#    SELENIUM Setup
#    Go To Netconf Radio Management Menu
#
#    ### Add default O-RU Name and Netconf Account
#    SELENIUM Add new O-RU Name and Netconf Account Branch  ${xranuser}     ${xranpass}
#
#    ### check before conection O-DU->ORU is ok
#
#    Wait Until Keyword Succeeds    300    20    ADMIN INFOMODEL Check AvailabilityStatus Value
#    ...      dist_name=${AZQI-RMOD1}
#    ...      value=Online
#
#    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir
#
#    Log to console  first SWR to ${SW_TARGET}
#    ADMIN Update Software With Activation
#    ...    sw_package=${SW_DESTINATION}${SW_TARGET}
#    ...    timeout=3600
#
#    ### check after conection O-DU->ORU is ok
    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir


    Log to console  Rollback to 22R1
    ADMIN Rollback Software
    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir


    SELENIUM Setup
    Go To Netconf Radio Management Menu

    ### Additional netconf account
    SELENIUM Add new and additional O-RU Name and Netconf Account Branch  ${xranuser}   ${xranpass}   ${xranuser2}   ${xranpass2}

    Log to console  second SWR to ${SW_TARGET}
    ADMIN Update Software With Activation
    ...    sw_package=${SW_DESTINATION}${SW_TARGET}
    ...    timeout=3600

    ### check after conection O-DU->ORU is ok
    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir






