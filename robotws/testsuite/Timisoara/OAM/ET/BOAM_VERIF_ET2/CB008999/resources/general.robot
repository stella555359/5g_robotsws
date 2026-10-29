*** Settings ***
Documentation
...    Author: Cerbu Madalin(madalin.cerbu@nokia.com)
...    Maintainer: Cerbu Madalin(madalin.cerbu@nokia.com)
...    Group in charge: RAN_BOAM_VERIF
...    References: doors
...    Feature Description: CB008682
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/  /home/ute/MN/UTE/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB008682/general.robot

Library         String
Library         Telnet
Library         OperatingSystem
Library         Process
Library         SSHLibrary
Library         ute_async
Library         collections
Library         XML  lxml=True
Library         ute_admin_infomodel
Library         ${CURDIR}/sw_download.py
Library         ute_fsmaccess
Resource    ../../resources/admin.robot
Resource    ../../resources/admin_infomodel.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot


*** Variables ***
${BTS_IP}=      192.168.255.129
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True
${FDSW_LOGIN}=         False
${SW_DESTINATION}     /home/ute
${jenkins_url}                http://files.ute.nsn-rdnet.net/builds/enb/base/
${DOWNLOAD_HOST}=      http://files.ute.nsn-rdnet.net/builds/enb/base/
${SW_DESTINATION}=         /home/ute/
${SBTS22R2_SCF}=          ${CURDIR}/Configuration_scf_SBTS22R3.xml
${build_T1}=               _release_BTSSM_downloadable_testpackage_T1.zip
${build_normal}=           _release_BTSSM_downloadable.zip
${port}  22
${ssh_alias}  sshenb


*** Keywords ***

Fallback 4082
     SYSTEM Open SSH Connection on gnb
     log to console      Start fallback commands
     ${output1}  SSHLibrary.Write            ddal -s ddal_boot_set_reset_loop_count 3
     SSHLibrary.Read Until       root@
     log to console   ${output1}
     SSHLibrary.Write            ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
     ${output}  SSHLibrary.Read Until       root@
     log to console   ${output}
     Wait Until Keyword Succeeds    1500    20    SYSTEM Check if fault is in active raw alarm  4082  Fallback


SYSTEM Open SSH Connection on gnb
    SSHLibrary.Open Connection    host=${SYSTEM_ENB_LOCAL_IP}    port=${port}    timeout=20    alias=${ssh_alias}
    SSHLibrary.Login    username=${SYSTEM_ENB_SSH_USERNAME}    password=${SYSTEM_ENB_SSH_PASSWORD}    delay=1s


Platform preparation N-1
    log to console    INCEPUT TEST
    ${trunk_build}=    ADMIN Get Sw Version
    ${trunk}=    Replace String    ${trunk_build}   23R1   00
    set suite variable    ${trunk}
    Download and activate testpackage N-1    ${build_T1}
    Sleep  600
    Download and activate testpackage N-1    ${build_normal}
    Sleep  600


Platform preparation N-2
    log to console    INCEPUT TEST
    ${trunk_build}=    ADMIN Get Sw Version
    ${trunk}=    Replace String    ${trunk_build}   23R1   00
    set suite variable    ${trunk}
    Download and activate testpackage N-2    ${build_T1}
    Sleep  600
    Download and activate testpackage N-2    ${build_normal}
    Sleep  600


Rollback and activate from N to N-x
    ADMIN Get Sw Version
    ADMIN Rollback Software
    Sleep  600
    ${var_upd}=    ADMIN Get Sw Version
    set suite variable     ${var_upd}
    Set Suite Variable    ${main_package}    ${var_upd}${build_normal}
    ADMIN Update Software With Activation
     ...            sw_package=${SW_DESTINATION}/${main_package}
     ...            timeout=2000
    Sleep  600
    ADMIN Reset Site
    Sleep  600


Download and activate testpackage N
    Set Suite Variable    ${main_package}    ${trunk}_release_BTSSM_downloadable.zip
    Log    \nDownload SW Package ${main_package}    console=yes
    Run    wget ${jenkins_url}${trunk}/${main_package} -P ${SW_DESTINATION}
    OperatingSystem.File Should Exist    path=/home/ute/${main_package}
    ADMIN Update Software With Activation
     ...            sw_package=${SW_DESTINATION}/${main_package}
     ...            timeout=2000
     Sleep  600


Download and activate testpackage N-2
    [Arguments]    ${build}
    ${var} =      sw_download.Download Newest 22R3
    log to console    ${var}
    set suite variable     ${var}
    Set Suite Variable    ${main_package}    ${var}${build}
    Log    \nDownload SW Package ${main_package}    console=yes
    Run    wget ${jenkins_url}${var}/${main_package} -P ${SW_DESTINATION}
    #Set Test Variable    ${N1_package}    ${SW_DESTINATION}/${main_package}
    OperatingSystem.File Should Exist    path=/home/ute/${main_package}
    ADMIN Update Software With Activation
     ...            sw_package=${SW_DESTINATION}/${main_package}
     ...            timeout=2000


Download and activate testpackage N-1
    [Arguments]    ${build}
    ${var} =      sw_download.Download Newest 22R4
    log to console    ${var}
    set suite variable     ${var}
    Set Suite Variable    ${main_package}    ${var}${build}
    Log    \nDownload SW Package ${main_package}    console=yes
    Run    wget ${jenkins_url}${var}/${main_package} -P ${SW_DESTINATION}
    #Set Test Variable    ${N1_package}    ${SW_DESTINATION}/${main_package}
    OperatingSystem.File Should Exist    path=/home/ute/${main_package}
    ADMIN Update Software With Activation
     ...            sw_package=${SW_DESTINATION}/${main_package}
     ...            timeout=2000
