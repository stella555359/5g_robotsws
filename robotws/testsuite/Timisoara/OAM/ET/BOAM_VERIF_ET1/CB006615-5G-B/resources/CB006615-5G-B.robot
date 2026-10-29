*** Settings ***
Documentation
...    Author: Moldovan Dan (dan.moldovan@nokia.com)
...    Maintainer: Moldovan Dan (dan.moldovan@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB006615-5G-B
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_VERIF_ET1/CB006615-5G-B/CB006615-5G-B.robot

Library        String
Library        OperatingSystem
Library        Process
Library        taf.transport.ssh   WITH NAME    taf_ssh
Library        taf.gnb.oam.coam.admin.interface.admin   WITH NAME   taf_admin
Library        taf.selenium.gnb.oam.coam.classical      WITH NAME   taf_selenium
Library        DateTime

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot
Resource    ../../resources/admin_infomodel.robot
Resource    ../../resources/faults.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ./keyword.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${DOWNLOAD_HOST}      https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${SW_DESTINATION}      /home/ute/
${jenkins_url}         http://files.ute.nsn-rdnet.net/builds/enb/base/
${BRANCH}              SBTS23R1
${TRUNK_VERSION}       SBTS23R2

${WEBEM_IP}=           https://192.168.255.129
${M-PLANE_IP}=         https://10.5.34.83
${M-PLANE_IP_SEC}=     https://10.5.34.84
${SC_VM_IP}=           10.5.25.176
${SC_VM_IP_SEC}=       10.5.25.177


${soft_activation}      /MRBTS-1/RAT-1/SWM-1/SW_ACTIVATE_REQ-1
${soft_activation_right}      /MRBTS-1/RAT-1/SWM-4/SW_ACTIVATE_REQ-1
${scf_path}             /tmp/
${scf_name}             scf_file.xml
${Primary_Position}      left
${SMOD_R-2}  Primary
${SMOD_R-1}  Secondary

${bts_83certificate}=                       ${CURDIR}/bts-83_cert.p12
${certificate_file}=                        /home/ute/bts-83_cert.p12
${delta_activate_users_activation}=         ${CURDIR}/Delta_Activate_Users_Accounts.json
${scf_leftside_single_core}=                ${CURDIR}/SCF_LeftSide_Single_Core_1xAEUD.xml
${scf_leftside_dual_core}=            ${CURDIR}/actForceAutoReset_True_default.xml
${scf_leftside_dual_core_branch}        ${CURDIR}/scf_sbts22r4.xml
${scf_rightside_single_core}=                  ${CURDIR}/scf_MRBTS-38084_SingleASIB_right_Regression.xml
${scf_singlecore_branch}                ${CURDIR}/scf_single_core_sbts22r4.xml



*** Keywords ***
Secondary_Commisionning
    log to console  Perform commissioning  on BTS
    ADMIN Perform Commissioning
    ...     scf_file=${scf_rightside_single_core}
    ...     skip_parameter_relation_errors=True
    Sleep  10
    log to console  Waiting for BTS onAir
    Wait Until Keyword Succeeds    900    30    ADMIN INFOMODEL Check If BTS Is OnAir
    Sleep   15

Remote_Migration_from_single_core_to_dual_core_leftPrimary
    Log To Console      START Test Case: Remote Migration from Single Core to Dual Core Left Primary
    ADMIN Setup Admin
    Sleep   5
    keyword.Admin Configuration Reset
    Sleep   300
#    Right Side In Single Core
    Left Side In Single Core
    Sleep   20
    Configuration_Reset_on_Secondary
    Left Side Primary in Dual Core Configuration
    SC Modules Visible in WebEM
    Sleep  300
    Get SMODs Role and Position

Configuration_Reset_rejected_on_DualCore_SW_or_Plan_Activation
#    log to console  Perform commissioning  on BTS
#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_leftside_dual_core}
#    ...     skip_parameter_relation_errors=True
#    Sleep  10
#    log to console  Waiting for BTS onAir
#    Wait Until Keyword Succeeds    900    30    ADMIN INFOMODEL Check If BTS Is OnAir
#    Sleep   15

    Log to Console
    ...  START Test Case 1+8: SW Update in Dual-core  Configuration Reset rejected on Dual-core SW or Plan Activation

##    Set Suite Variable  ${OUT_ACTIVE_SW}  SBTS22R1_ENB_9999_210622_000005
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should contain  ${output}  	TargetBD_${OUT_PASSIVE_SW}.xml
    ADMIN Update Software Without Activation
    ...    sw_package=${SW_DESTINATION}${T2_package}
    ...    timeout=3600
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
#    Sleep  30
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/planned/
    should contain  ${output}  	TargetBD_${out_active_sw}T2.xml

    ${CLI_INTERFACE}                               Get Library Instance    taf.gnb.oam.coam.admin
    ADMIN Connect To                               admin_alias=ADMIN_SW_Update_in_background
    keyword.IM SWM usageState Should Be Idle - Slave    admin_alias=ADMIN_SW_Update_in_background
    Sleep  5
    ${output_task_abort_in_background}   taf.gnb.oam.coam.admin.run_keyword_in_background
    ...             interface=${CLI_INTERFACE}
    ...             name=update_software
    ...             sw_package=${SW_DESTINATION}${T2_package}
    ...             should_activate=${TRUE}
    ...             connection=ADMIN_SW_Update_in_background
    Sleep  20
    IM Wait Until SW activation is ongoing    retry=5 min    retry_interval=1 sec
    Sleep  30
    run keyword and expect error  *    keyword.ADMIN Configuration Reset
    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period    650
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    Sleep  360
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	TargetBD_${out_active_sw}T2.xml
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should not contain  ${output}  	planned
    should contain  ${output}  	TargetBD_${out_active_sw}.xml
#    Log to console      Rollback
#    ADMIN Rollback Software
    Sleep   60
    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir


Configuration_Reset_on_Dual_Core
    Log To Console      START Test Case 4: SW Update In Dual Core Mode
    Login To Web Element Manager
    SELENIUM Go to Configuration Reset
    Remove User Accounts and Certificates
    Execute Configuration Reset
    Sleep  120
#    Wait Until Keyword Succeeds  350  30    PREPOST Setup Admin
    Wait Until Keyword Succeeds  700  30    ADMIN Check BTS Not Commisioned
    Wait Until Keyword Succeeds  60    5    SC Response to Ping as Single Core
    User Accounts and Certificate Check
##  At the end Put BTS On Air
    Left Side Primary in Dual Core Configuration

Configuration_Reset_on_Secondary
    Log To Console      START Test Case 4: SW Update In Dual Core Mode
    Login To Web Element Manager via M-PLANE IP
    SELENIUM Go to Configuration Reset
    Execute Configuration Reset
    Sleep  900
    Wait Until Keyword Succeeds  350  30    SC Response to Ping as Single Core


