*** Settings ***
Documentation      author: SKY MEI
...                contact: sky.mei@nokia-sbell.com
...                This robot file is for common case.
#Suite Setup       TestSuilt.Start
#Suite Teardown    TestSuilt.Stop
Force Tags               SG_01   5G_RAN
...    PY36
Resource          OAM_Interface.robot
*** Variables ***
##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ENBCTLPC}           ENB_PC                                              ##
${ALIAS_SHP}                SHP                                                 ##
${ALIAS_E500}               E500                                                ##
${ALIAS_PRISMA}             Prisma                                              ##
${ALIAS_REAL_EPC_SERVER}    Real_EPC                                            ##
${ALIAS_LONER}              LONER                                               ##
${ALIAS_ASP_1A}             ASP_1A                                              ##
########################END of alias Define#######################################
*** Test Cases ***
TEST
#    [Documentation]
#    [Setup]    TestCase.Start_2479
#    [Teardown]  TestteardownforWebEM
    log to console    test

TC.NetActAppTest
    [Documentation]
    UTE.CleanFirefox
    KW.NetAct.Init
    NetAct.Login   url=${CASE_INPUT_5GC002479['5GC002479']['NETACT_URL']}
            ...    username=${CASE_INPUT_5GC002479['5GC002479']['NETACT_USER']}
            ...    password=${CASE_INPUT_5GC002479['5GC002479']['NETACT_PASSWORD']}
    NetAct.StartApp  app_name=CM Operations Manager
    NetAct.CloseApp  app_name=CM Operations Manager
    NetAct.Logout

TC.FDSWConnectTest
     UTE.CleanFirefox
     rc.connect_to    ip_address=192.168.255.129    port=443    username=Nemuadmin    password=nemuuser

TC.PrepareENVOnSecondary
    log to console    YAFT Started
    KW.BTS.Init
    set suite variable    ${ASIK_IP}    ${ip}
#    set suite variable    ${UPDATE_FILE_PATH}   /home/ute/SWDownloads/${ip}/
    set suite variable    ${UPDATE_FILE_PATH}   /home/ute/Download_gNB_Package
    run    command=rm -rf ${UPDATE_FILE_PATH}/*
    wait until keyword succeeds    15min    30s   COAM_Admin.Login
	log to console    SSH enable!!!!!!!!!!!!!!!!
	coam.enable_ssh_access    connection=COAM
	COAM_Admin.Logout
    ${filepath}     SoftwareUpdate.DownloadPackageFromWFT  build_version=${version}
    SoftwareUpdate.YAFT    filepath=${filepath}
    run    command=rm -rf ${UPDATE_FILE_PATH}/*
    run    command=rm -rf /opt/ute/YAFT/YAFT_IMAGE/*
    log to console    PrepareENVOnSecondary Success

TC.SoftwareUpdate
    [Documentation]
    #UTE.CleanFirefox
    KW.BTS.Init
    ${swVersion}    COAM_Admin.GetActiveSoftwareVersion
    log to console     ${swVersion}
    ${result}    ${swVersion}    run keyword and ignore error    COAM_Admin.TransferSWVersion   ${swVersion}
    log to console     ${swVersion}
    Run Keyword If    '${swVersion}'=='${TARGET_VERSION}'     Pass Execution    This case status: PASS
    #${check_reset}    set variable if    '${swVersion}'=='${TARGET_VERSION}'    false    true
    log to console    ${TARGET_VERSION}
    ${filepath}    Run Keyword If   '${TARGET_VERSION}'!=''   SoftwareUpdate.DownloadPackageFromWFT  build_version=${TARGET_VERSION}    wftlink=true
    ...    ELSE    SoftwareUpdate.DownloadPackageFromKnife    knife_url = ${KNIFE_URL}
    SoftwareUpdate.SoftwareUpdateFromWebUI      filepath=${filepath}    check_reset=true    check_onair=true
    run    rm -rf ${filepath}

*** Keywords ***
KW.BTS.Init
    set suite variable    ${ASIK_IP}            ${ip}
    set suite variable    ${WEBUI_IP}           ${ip}
    set suite variable    ${WEBUI_URL}          https://${ASIK_IP}
    set suite variable    ${WEBUI_USERNAME}     Nemuadmin
    set suite variable    ${WEBUI_PASSWORD}     nemuuser
    set suite variable    ${UPDATE_FILE_PATH}   /home/ute/SWDownloads/${ip}/
    set suite variable    ${TARGET_VERSION}     ${version}
    set suite variable    ${KNIFE_URL}     ${knifeurl}

KW.NetAct.Init
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479']['StreamPrefix']
    ...    default_value=5G21A_
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479']['NETACT_URL']
    ...    default_value=https://shanxilbwas.sui6.srnhz.nsn-rdnet.net
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479']['NETACT_USER']
    ...    default_value=omc
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479']['NETACT_PASSWORD']
    ...    default_value=Nokia126_
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479']['NETACT_LOGSERVER_IP']
    ...    default_value=10.110.144.140
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479']['NETACT_LOGSERVER_USERNAME']
    ...    default_value=root
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479']['NETACT_LOGSERVER_PASSWORD']
    ...    default_value=arthur
    Set Suite Variable    ${NETACT_LOGSERVER_IP}          ${CASE_INPUT_5GC002479['5GC002479']['NETACT_LOGSERVER_IP']}
    Set Suite Variable    ${NETACT_LOGSERVER_USERNAME}    ${CASE_INPUT_5GC002479['5GC002479']['NETACT_LOGSERVER_USERNAME']}
    Set Suite Variable    ${NETACT_LOGSERVER_PASSWORD}    ${CASE_INPUT_5GC002479['5GC002479']['NETACT_LOGSERVER_PASSWORD']}