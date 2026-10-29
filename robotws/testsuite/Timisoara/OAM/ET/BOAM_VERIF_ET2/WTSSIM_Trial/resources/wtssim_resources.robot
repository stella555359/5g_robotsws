*** Settings ***
Documentation



Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library      taf.transport.ssh   WITH NAME   csn

#Resource    ../resources/keywords.robot
Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/AirPhone/resources/ute/coam.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True


*** Keywords ***
WTSSIM_test
    log to console  test wts sim
#    Verify Coam BTS is onAir
    sleep  5




