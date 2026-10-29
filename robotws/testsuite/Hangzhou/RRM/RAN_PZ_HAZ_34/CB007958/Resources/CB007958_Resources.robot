*** Settings ***
Documentation         author: Shi Taotao
...                   contact: taotao.shi@nokia-sbell.com
...                   squard group: SG_01
...                   feature: CB007958
Library                urllib
Library                String
Library                taf.sbts.oam.coam.admin                        WITH NAME    sbts
Resource               ../../5GC000496_C/Resources/L3Call.robot
Resource               testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG1/OAM_Interface.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC000092/Resource/5GC000092_Resource.robot


*** Variables ***
${WEBUI_URL}           https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${LMP}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP_Mplane}      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_username}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

${link_to_Artifact_CB}      https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/
${surffix_common_build}    release_BTSSM_downloadable_A54.zip
${UPDATE_FILE_PATH}    /home/ute/Download_gNB_Package

${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${NRBTS_ID}            ${tl.gnbs[0].global_bts_id}

${ALIAS_ASIK}             asik
${ALIAS_ASIK_SLAVE}       asik_slave
${ALIAS_LMP_PRIMARY}      lmp_primary
${ALIAS_LMP_SECONDARY}    lmp_secondary
${ALIAS_UTE}              ute

*** Keywords ***
TC.CB007958-5G_02_BTS Autoconnection without DHCP server_SBTSSW_IPv4
    [Documentation]   Aim to test PnP process is normal with DHCP-less in dual subnet
    ...    Step1: Configuration reset
    ...    Step2: Clear and Restart AC
    ...    Step3: upload SW to NetAct
    ...    Step4: upload PnP plan to NetAct
    ...    Step5: set AC parameters and send
    ...    Step6: check AC status
    ...    Step7: check PnP process
    KW.SBTS_Admin_Login
    log to console    Step1: start to configuration reset
    KW.SBTS_Admin_Configuration_Reset    reset_type=Configuration
    Run Keyword And Ignore error     KW.SBTS_Admin_Logout
    wait until keyword succeeds   3x   1min   KW.SBTS_Admin_Login
    log to console       Step2: Clear and Restart AC
    Run Keyword And Ignore error    sbts.clear_and_reset_auto_connection    connection=${OAM_TYPE}
    sleep   5s
    log to console    Step3: upload SW to NetAct
    log to console    Step4: upload PnP plan to NetAct
    log to console    Step5: set AC parameters and send
    sbts.set_autoconnection_transport_params   &{CASE_INPUT_CB007958}  connection=${OAM_TYPE}
    log to console    Step6: check AC status
    log to console    Step7: check PnP process

TC.CB007958-5G_03_Configuration reset to trigger AC with DHCP less
    [Documentation]
    ...    Step1: Configuration reset
    ...    Step2: Clear and Restart AC
    ...    Step3: set AC parameters and send
    ...    Step4: check AC status
    ...    Step5: recovery environment
    KW.SBTS_Admin_Login
    log to console    Step1: start to configuration reset
    KW.SBTS_Admin_Configuration_Reset    reset_type=Configuration
    Run Keyword And Ignore error     KW.SBTS_Admin_Logout
    wait until keyword succeeds   3x   1min   KW.SBTS_Admin_Login
    log to console       Step2: Clear and Restart AC
    Run Keyword And Ignore error    sbts.clear_and_reset_auto_connection    connection=${OAM_TYPE}
    sleep   5s
    log to console   Step3: set AC parameters and send
    sbts.set_autoconnection_transport_params   &{CASE_INPUT_CB007958}  connection=${OAM_TYPE}
    log to console    Step4: check AC status
    sleep   120s
    #${AC_status}=    Run Keyword And Return Status    sbts.get_trs_autoconnection_status    timeout=${60}    connection=${OAM_TYPE}
    ${result}  run   command=ping ${WEBUI_IP} -c 10
    should contain    ${result}    64 bytes from ${WEBUI_IP}
#---------------------------------Keywords----------------------------------------------#
KW.CaseSetup
    TestCase.Start

KW.CaseTeardown
    Run Keyword And Ignore error     KW.Kill Xvfb in UTE
    Run Keyword And Ignore Error     run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error     BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore error     selenium_coam.disable_virtual_display
    Run Keyword And Ignore error     run    command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error     run    command=killall geckodriver
    Run Keyword And Ignore error     KW.SBTS_Admin_Logout
    TestCase.Stop

KW.Case03Teardown
    Run Keyword And Ignore error    sbts.clear_and_reset_auto_connection    connection=${OAM_TYPE}
    Run Keyword And Ignore error    COAM_Admin.commission
    ...    scf_file=${backupSCF}    bts_host=${ASIK_IP}
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    KW.CaseTeardown

KW.SuiteSetup
    TestSuite.Start
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    gNB.FormatBTSID    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable    ${DIST_NAME}   ${MRBTS_ID}/${NRBTS_ID}
    #gNB.GenerateTestLineSCFs
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    ${sw_version}     coam.get_sw_version    connection=COAM
    ${stream}   ${subversion}    Split String   string=${sw_version}   separator=_     max_split=1
    set suite variable   ${gNB_release}    ${stream}
    COAM_Admin.Logout
    ${backupSCF}    COAM_Admin.BackupSCF
    set suite variable    ${backupSCF}

KW.SuiteTeardown
    TestSuite.Stop

KW.Kill Xvfb in UTE
    ${Xvfb_Cnt}  run  command=ps -ef | grep -i Xvfb |grep -v grep|awk '{print$2}'|awk 'END{print NR}'
    FOR    ${i}    IN RANGE    ${Xvfb_Cnt}
        ${PID1}  run  command=ps -ef|grep -i Xvfb|awk '{{print $2}}'|head -n 1
        Log  message=Killing ${i+1}st Xvfb process with PID ${PID1}.
        run  command=/bin/kill -9 ${PID1.strip()}
    END
    run  command=ps -ef | grep -i Xvfb |grep -v grep

KW.SBTS_Admin_Login
    [Arguments]    ${bts_host}=${LMP}    ${username}=${WEBUI_USERNAME}   ${password}=${WEBUI_PASSWORD}
    ...   ${bts_port}=${443}   ${log_dir}=${OUTPUT_DIR}   ${alias}=COAM
    sbts.connect_to
	...   bts_host=${bts_host}
    ...   bts_port=${bts_port}
    ...   username=${username}
    ...   password=${password}
    ...   use_ssl=${True}
    ...   update_interval=${5000}
    ...   admin_api_log_dir=${log_dir}
    ...   name=${alias}
	...   release=${gNB_release}

KW.SBTS_Admin_Logout
    [Arguments]   ${alias}=COAM
    sbts.teardown    connection=${alias}

KW.SBTS_Admin_Configuration_Reset
    [Arguments]    ${remove_operator_certificates}=${False}    ${remove_user_account_credentials}=${False}
    ...    ${reset_type}=Configuration    ${detailed_output}=${False}    ${alias}=COAM
    sbts.reset_configuration
    ...    remove_operator_certificates=${remove_operator_certificates}
    ...    remove_user_account_credentials=${remove_user_account_credentials}
    ...    connection=${alias}
    ...    detailed_output=${detailed_output}
    ...    reset_type=${reset_type}

