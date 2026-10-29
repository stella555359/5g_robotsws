*** Settings ***
Documentation    author: Cheng Jiajing
...               contact: jiajing.1.cheng@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC000876
Resource          ../../5GC000496_C/Resources/L3Call.robot
#Variables         ${CFGFILE_PATH}/Delta_SCF.py
Library           ../../5GC000638/Resources/coam_close.py

*** Variables ***
${UPDATE_FILE_PATH}    /opt/ute/tmp/
#${CFGFILE_PATH}    /home/ute/TAF/cfgfile/
#${lua_script_path}    /home/ute/TAF/cfgfile/luashark/generated_luashark/luashark.lua
${Original_CFGFILE}      /home/ute/TAF/cfgfile/Configuration_scf_TL206_3Cell.xml

${MRBTS}    ${tl.gnbs[0].instance_id}
${NRBTS}    ${tl.gnbs[0].global_bts_id}

${EGATE_CFG_NAME}    ${tl.core.cfg_filename}
${WTS_FILE_PATH}    ${tl.core.dir_path}
${ASIK_IP}        ${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.addr}

${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${RU_TYPE}        ${tl.gnbs[0].du.rus[0].radio_type}
${AEQA_IP}        ${tl.gnbs[0].du.rus[0].default_ssh_connection_details.addr}    # 192.168.254.34
${UTE_IP}         ${tl.core.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.core.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.core.default_ssh_connection_details.password}

${PB_PORT}        4001
${PB_ASIK_IP}     ${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}    ${tl.gnbs[0].du.airscale.common_units[0].pdu_port.port_no}
${PB_5GRU_IP}     ${tl.gnbs[0].du.rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}    ${tl.gnbs[0].du.rus[0].pdu_port.port_no}

${IMSI_UE1}           262032001002986
${IMSI_UE2}           262032001002987
${IMSI_UE3}           262032001002989
${IMSI_UE4}           262032001002993
${AMF_IP}             10.110.149.10
${AMF_USERNAME}       cmm
${AMF_PASSWORD}       Nokia@2019!

${E500_IP}        ${tl.ues[0].tma_host.addr}
${E500_PORT}      ${tl.ues[0].tma_command_port}
${E500_ASC_PORT}    ${10011}
${E500_USERNAME_DOMAIN}    ${tl.ues[0].tma_host.username}
${E500_USERNAME}    ${tl.ues[0].tma_host.username}
${E500_PASSWORD}    ${tl.ues[0].tma_host.password}
${E500_TMA_PATH_Pre0}    /cygdrive/c/Program Files (x86)/Aeroflex/TM500/
${E500_TMA_PATH_Pre1}    TM500_NR_5G_EXT-MUE_Release_NLA_4_11_0_NG12042019_1/Test Mobile Application/TmaApplication.exe
${E500_TMA_PATH}      ${E500_TMA_PATH_Pre0}${E500_TMA_PATH_Pre1}
${E500_SCRIPT_DIR}    ${CURDIR}/E500_scripts/
${UE_ATTACH_W_PDU}     UE_Attach_SA_PDU.txt


${Check_Content_UE1_RA}  CMPI L2 Random Access Complete :UE Id:1
${Check_Content_UE2_RA}  CMPI L2 Random Access Complete :UE Id:2
${Check_Content_UE3_RA}  CMPI L2 Random Access Complete :UE Id:3
${Check_Content_UE4_RA}  CMPI L2 Random Access Complete :UE Id:4
${Check_Content_UE1_PDU1}  CMPI MTE 0 NR REGISTRATION IND:UE Id:1\r\n${SPACE * 2}Selected PLMN: 26203F\r\n${SPACE * 1}
    ...                    Pdu Session Id: 1\r\n${SPACE * 2}Data Network Name: wap1.nokia.com\r\n${SPACE * 2}IPv4 Address:
${Check_Content_UE2_PDU1}  CMPI MTE 0 NR REGISTRATION IND:UE Id:2\r\n${SPACE * 2}Selected PLMN: 26203F\r\n${SPACE * 1}
    ...                    Pdu Session Id: 1\r\n${SPACE * 2}Data Network Name: wap1.nokia.com\r\n${SPACE * 2}IPv4 Address:
${Check_Content_UE3_PDU1}  CMPI MTE 0 NR REGISTRATION IND:UE Id:3\r\n${SPACE * 2}Selected PLMN: 26203F\r\n${SPACE * 1}
    ...                    Pdu Session Id: 1\r\n${SPACE * 2}Data Network Name: wap1.nokia.com\r\n${SPACE * 2}IPv4 Address:
${Check_Content_UE4_PDU1}  CMPI MTE 0 NR REGISTRATION IND:UE Id:4\r\n${SPACE * 2}Selected PLMN: 26203F\r\n${SPACE * 1}
    ...                    Pdu Session Id: 1\r\n${SPACE * 2}Data Network Name: wap1.nokia.com\r\n${SPACE * 2}IPv4 Address:
${Check_Content_UE1_PDU2}  CMPI MTE 0 NR PDU SESSION ESTABLISHMENT IND:UE Id:1\r\n${SPACE * 3}Pdu Session Id:2 \r\n\r\n${SPACE * 1}
    ...                    Data Network Name: wap2.nokia.com\r\n${SPACE * 2}IPv4 Address:
${Check_Content_UE2_PDU2}  CMPI MTE 0 NR PDU SESSION ESTABLISHMENT IND:UE Id:2\r\n${SPACE * 3}Pdu Session Id:2 \r\n\r\n${SPACE * 1}
    ...                    Data Network Name: wap2.nokia.com\r\n${SPACE * 2}IPv4 Address:
${Check_Content_UE3_PDU2}  CMPI MTE 0 NR PDU SESSION ESTABLISHMENT IND:UE Id:3\r\n${SPACE * 3}Pdu Session Id:2 \r\n\r\n${SPACE * 1}
    ...                    Data Network Name: wap2.nokia.com\r\n${SPACE * 2}IPv4 Address:
${Check_Content_UE1_PDU1_Fail}  CMPI MTE 0 NR PDU SESSION ESTABLISHMENT IND: UE Id: 1 \r\n${SPACE * 2}
    ...                         NAS: Pdu Session Establishment Failure\r\n${SPACE * 3}Pdu Session Id:1
${Check_Content_UE1_PDU2_Fail}  CMPI MTE 0 NR PDU SESSION ESTABLISHMENT IND: UE Id: 1 \r\n${SPACE * 2}
    ...                         NAS: Pdu Session Establishment Failure\r\n${SPACE * 3}Pdu Session Id:2
${Check_Content_UE2_PDU1_Fail}  CMPI MTE 0 NR PDU SESSION ESTABLISHMENT IND: UE Id: 2 \r\n${SPACE * 2}
    ...                         NAS: Pdu Session Establishment Failure\r\n${SPACE * 3}Pdu Session Id:1
${Check_Content_UE2_PDU2_Fail}  CMPI MTE 0 NR PDU SESSION ESTABLISHMENT IND: UE Id: 2 \r\n${SPACE * 2}
    ...                         NAS: Pdu Session Establishment Failure\r\n${SPACE * 3}Pdu Session Id:2
${Check_Content_UE1_ReleasePDU2}  CMPI MTE 0 NR PDU SESSION RELEASE IND:UE Id:1\r\n${SPACE * 2}
    ...                           Pdu Session Id:2 \r\n\r\n${SPACE * 1}UE Initiated Procedure
${Check_Content_UE3_RA_Fail}  CMPI MTE 0 NR CONNECTION FAILED IND:UE Id:3
${Check_Content_UE1_Detach}  CMPI MTE 0 NR DEREGISTRATION IND:UE Id:1\r\n${SPACE * 4}Detach Cause: UE Initiated
${Check_Content_UE2_Detach}  CMPI MTE 0 NR DEREGISTRATION IND:UE Id:2\r\n${SPACE * 4}Detach Cause: UE Initiated
${Check_Content_UE3_Detach}  CMPI MTE 0 NR DEREGISTRATION IND:UE Id:3\r\n${SPACE * 4}Detach Cause: UE Initiated
${Check_Content_UE4_Detach}  CMPI MTE 0 NR DEREGISTRATION IND:UE Id:4\r\n${SPACE * 4}Detach Cause: UE Initiated

${Check_Content_UE1_PDU1_2}  CMPI MTE 0 NR PDU SESSION ESTABLISHMENT IND:UE Id:1\r\n${SPACE * 3}Pdu Session Id:1 \r\n\r\n${SPACE * 1}
    ...                      Data Network Name: wap1.nokia.com\r\n${SPACE * 2}IPv4 Address:
${Check_Content_UE2_PDU1_2}  CMPI MTE 0 NR PDU SESSION ESTABLISHMENT IND:UE Id:2\r\n${SPACE * 3}Pdu Session Id:1 \r\n\r\n${SPACE * 1}
    ...                      Data Network Name: wap1.nokia.com\r\n${SPACE * 2}IPv4 Address:
${Check_Content_UE3_PDU1_2}  CMPI MTE 0 NR PDU SESSION ESTABLISHMENT IND:UE Id:3\r\n${SPACE * 3}Pdu Session Id:1 \r\n\r\n${SPACE * 1}
    ...                      Data Network Name: wap1.nokia.com\r\n${SPACE * 2}IPv4 Address:

${AF_PATH}           1
##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_ABIL}                abil                                               ##
${ALIAS_ABIL_SLAVE}         abil_slave                                          ##
${ALIAS_LONER}              loner                                               ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ENBCTLPC}           ENB_PC                                              ##
${ALIAS_SHP}                SHP                                                 ##
${ALIAS_E500}               E500                                                ##
${ALIAS_PRISMA}             Prisma                                              ##
${ALIAS_AMF}                AMF                                                 ##
########################END of alias Define#######################################

*** Keywords ***
Process.ModifyAndCommissionAndCheckOnAir
    [Documentation]   1. Modify SCF
    ...                2. Commission Modified SCF
    ...                3. Wait gNB start and verify gNB is On Air until timeout.
    [Arguments]       ${original_cfgfile}
        ...            ${modified_cfgfile}
        ...            ${parameters_to_modify}
    ModifyParametersToSCF   input_scf=${original_cfgfile}    output_scf=${modified_cfgfile}
    ...                     modify_parameters_lists=${parameters_to_modify}
    COAM_Admin.commission         scf_file=${modified_cfgfile}    timeout=900
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady

Process.PrintTLInformation
    log many    ${EGATE_CFG_NAME}    ${WTS_FILE_PATH}    ${ASIK_IP}    ${AEQA_IP}
    log many    ${UTE_IP}    ${UTE_USERNAME}    ${UTE_PASSWORD}
    log many    ${PB_PORT}    ${PB_ASIK_IP}    ${PB_ASIK_PORT}
    log many    ${PB_5GRU_IP}    ${PB_5GRU_PORT}

ModifyParametersToSCF
    [Documentation]   Modify Parameters in ${modify_parameters_lists} to ${input_scf}
    [Arguments]    ${input_scf}    ${output_scf}    ${modify_parameters_lists}
    ${exist}=    run keyword and return status    OperatingSystem.File Should Exist    ${CFGFILE_PATH}/Delta_SCF.py
    run keyword if    ${exist}    commissioning.modify_scf    input_scf=${input_scf}
    ...    output_scf=${output_scf}    parameters_lists=${modify_parameters_lists}

E500.ConnectCellSearchAndAttach
    [Documentation]   1. PowerCycle VIAVI
    ...                2. Open tma software and run SA init_config script to connect to cobham
    ...                3. Run SA cell config script and check
    ...                4. Run SA ue attach script and check
    [Arguments]   ${alias}=${ALIAS_E500_APP}   ${username}=test2    ${group}=test2
    [Timeout]    20 minutes
    E500.ReInitForRetry    ${username}   ${group}
    E500.ConnectToViavi
    sleep   30s
    ${response}=  e500.send script  ${E500_SCRIPT_DIR}Cell_Search_SA.txt  alias=${alias}
    Should Not Contain    ${response}    failure
    Should Not Contain    ${response}    Failure
    Should Contain    ${response}    NR-BCCH-BCH-Message
    Should Contain    ${response}    NR-BCCH-DL-SCH-Message
    Should Contain    ${response}    FORW 0x00 Ok MTE NRSETMUERADIOCONTEXTCELL: RETURN CODE:0 SUCCEEDED
    ${response}=  e500.send script  filename=${E500_SCRIPT_DIR}UE_Attach_SA.txt  alias=${alias}
    Should Contain    ${response}    Random Access Complete
    Run Keyword And Ignore error    Should Not Contain    ${response}    failure
    Run Keyword And Ignore error    Should Not Contain    ${response}    Failure
    sleep   10s

E500.ConnectToViavi
    [Documentation]   Run init_config script to connect to cobham
    [Arguments]   ${alias}=${ALIAS_E500_APP}
    [Timeout]    5 minutes
    ${response}=  e500.send script  filename=${E500_SCRIPT_DIR}Init_Config_SA.txt  alias=${alias}
    Should Not Contain    ${response}    failure
    Should Not Contain    ${response}    Failure
    sleep   30s

KW.MultiRunCases
    [Arguments]   ${keyword}    ${times}=2
    FOR    ${i}    IN RANGE    ${times}
         ${res}    Run Keyword And Ignore error    ${keyword}
         Return From Keyword if   '${res[0]}'=='PASS'
    END
    Fail  Run '${keyword}' failed after retry '${times}' times

COAM.SetParameterValue
    [Arguments]    ${distname}    ${paraname}    ${value}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=${paraname}    new_value=${value}

ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    Run Keyword If    '${activate_plan_despite_errors}'=='True'   selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE      selenium_coam.activate_plan

ConnectToLoner
    [Arguments]    ${alias}=${ALIAS_LONER}
    ssh.Connect to  ${LONER_IP}  ${ASIK_USERNAME}  ${ASIK_PASSWORD}
    ...                alias=${alias}  proxy=${ALIAS_ASIK}

gNB.EnableDebugLog
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.Execute  cmd=cp /user/toor4nsn/wa/cp_runtime.ini /rom/   alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

Collect Snapshot
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

Setup suite
#    Import Variables    ${CFGFILE_PATH}/Delta_SCF.py
    Create Log Directories
    set suite variable    ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
    ${value}    config.getvalue    ${CFGFILE_PATH}/TA.ini    SectionVIAVI    VIAVI_PATH
    set global variable    ${E500_TMA_PATH}    ${value}
    set suite variable   ${OAM_TYPE}    COAM
    Set Suite Variable   ${CASE_ECECUTED}    NO
    Set Suite Variable    ${TargetCounter}  0
    gNB.EnableDebugLog
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore error   run   command=killall geckodriver
    Conn.ResetCache

Teardown case
    Run Keyword And Ignore error    E500.StopAllWithSSH
    Run Keyword And Ignore error    COAM_WebEM.Logout
    Run Keyword And Ignore error    Collect Snapshot
    Run Keyword And Ignore error    coam_close.force_close_coam_webdriver
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    ${gNB_logName}=    catenate    SEPARATOR=_    ${TEST NAME.replace(" ", "_")}    gNB.log
    Run Keyword And Ignore Error    gnb.collectlog    ${gNB_logName}
    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Conn.ResetCache



