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
Resource    ../../resources/selenium_oru.robot
Resource    ../../resources/orusim.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${oru1}=                    10.5.55.152
${oru2}=                    10.5.53.238
${O-RU_username}=                oru
${O-RU_password}=                orusim12
${SYSTEM_ALIAS_ORU}=             oru


${xranuser}=            xranuser
${xranpass}=            xran-password

${dist_name}=           /MRBTS-10616/EQM-1/APEQM-1/RMOD-1
${dist_name_oru_sw}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1

${pub_key_format}=      ssh-rsa
${lterel_disc}=   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
${SW_DESTINATION}     /home/ute
${ADMIN_CLI_scripts_location}=    ${CURDIR}/../scripts
${location_o-ru_package}=       home/userbtsoam/share1btsoam/ET_VERIF4/ORU_package
${location_o-ru_package2}=      home/userbtsoam/share1btsoam/ET_VERIF4/ORU_package2

*** Keywords ***
Local SWR with automatic reset enabled

    Log to console  ADMIN_CLI download in progress
    ADMIN_CLI Suite Setup
    Log To Console  ADMIN_CLI is ready and scripts were transferred


    Log to console  O-RU SWR in progress
    ORU SWR1

    Log To Console   Precondition is done. Start test

    ADMIN Perform Parameter Recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
   ...                                        parameter=oruDisableSWUpdate
   ...                                        operation=update
   ...                                        value=true

    ORU SWR2blocked

    ADMIN Perform Parameter Recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
   ...                                        parameter=oruDisableSWUpdate
   ...                                        operation=update
   ...                                        value=false

    Log to console  O-RU SWR in progress
    ORU SWR2


Local SWR with automatic reset disabled

    Log to console  ADMIN_CLI download in progress
    ADMIN_CLI Suite Setup
    Log To Console  ADMIN_CLI is ready and scripts were transferred


    Log to console  O-RU SWR in progress
    ORU SWR1

    Log To Console   Precondition is done. Start test

    ORU SWR2 autorr disabled  ##Start oru swr with radio reset disabled

    Reset RMOD  rmod_dist_name=MRBTS-${OUT_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    Sleep  5
    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir

    ${oruRunningSw}    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=${dist_name_oru_sw}
    ...    dict_param=runningSwVersion
    Should Contain  ${oruRunningSw}  oru-sw-r1_1.2
    ${oruActiveSw}    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=${dist_name_oru_sw}
    ...    dict_param=activeSwVersion
    Should Contain  ${oruActiveSw}  oru-sw-r1_1.2
    log to console   ORU active and running SW version is 1.2
