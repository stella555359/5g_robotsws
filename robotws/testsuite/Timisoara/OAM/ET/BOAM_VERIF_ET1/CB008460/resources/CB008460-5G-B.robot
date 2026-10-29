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

Resource     ../../resources/pretest_posttest.robot
Resource     ../../resources/get_build_wft.robot
Resource     ../../resources/system.robot
Resource     ./keywords.robot
Resource    ../../resources/selenium.robot
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

${scf_default}=         ${CURDIR}/Configuration_scf_MRBTS-10212_ORAN2-2Cells_20220510-1047.xml
${xranuser}=            xranuser
${xranpass}=            xran-password

${dist_name}=           /MRBTS-10616/EQM-1/APEQM-1/RMOD-1
${dist_name_oru_sw}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1

${pub_key_format}=      ssh-rsa
${AZQI-RMOD1}=          /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1

${location_o-ru_package1}        /media/share1BTSOAM-mnt/ET_VERIF4/ORU_package
${location_o-ru_package2}        /media/share1BTSOAM-mnt/ET_VERIF4/ORU_package2

${lterel_disc}=   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build

${wft_url}         http://files.ute.nsn-rdnet.net/builds/enb/base/
${CLI_INTERFACE}                          Get Library Instance    taf.gnb.oam.coam.admin
${ADMIN_CLI_scripts_location}=  ${CURDIR}/../scripts

${timeout}=  1800
${should_activate}=  ${True}


${SW_DESTINATION}     /home/ute
${ADMIN_CLI_scripts_location}=    ${CURDIR}/../scripts
${location_remote_swr_cert}  home/userbtsoam/share1btsoam/ET_VERIF4/Remote_swr_cert
${local_remote_swr_cert}=     ${CURDIR}
${Cacert_FILE}  ${CURDIR}/cacert105.pem

${SYSTEM_ENB_LOCAL_IP}=        192.168.255.1
${SYSTEM_ENB_SSH_USERNAME}=    toor4nsn
${SYSTEM_ENB_SSH_PASSWORD}=    oZPS0POrRieRtu
${port}  22
${ssh_alias}  sshenb
*** Keywords ***

Software_Upgrade_from_N-x_to_N

    Update Software With Activation

Software_Rollback_from_N_to_N-x

    log to console  Rollback
    ADMIN Rollback Software
    Sleep  100
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir
    log to console  check if SW version is correct
    Check initial SW version


Software_Fallback_to_N-x

    log to console  Fallback test started.

    Fallback 4082

    log to console  Check Fault_4082
    Wait Until Keyword Succeeds    900    20    SYSTEM Check if fault is in active raw alarm  4082  Fallback
    Check initial SW version after Fallback

System_Upgrade_from_Remote_server_N-x_to_N

    log to console  Remote SWR test started
    Add targetBD in script file
#    Transfer Remote Certificate
#    ADD Remote SWR Certificate
    Prepare ADMIN_CLI
    Transfer SW to webdav
    Remote SWR
