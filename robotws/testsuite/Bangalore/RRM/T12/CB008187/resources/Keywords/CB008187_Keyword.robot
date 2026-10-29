*** Settings ***
Documentation    This File contains all the commmon keywords required for the Feature CB008187
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         Collections
Variables       ta5g_global_var
Library         ute_fsmaccess
Library         ta5g_pm_counters
Library         ${CURDIR}/../../../resources/PythonLib/UTILS.py
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/PCMD_Related_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${TOPOLOGY}         CLOUD_5G_I_LO_AP_LO
${f1ap_UEContextSetupRequest_filter}                    f1ap.procedureCode == 5 and nr-rrc.c1 == 0
${xnap_HandoverRequestAcknowledge_filter}               xnap.procedureCode == 0 and xnap.id == 79
${f1ap_RRCSetup_filter}                                 f1ap.procedureCode==12 and nr-rrc.c1==1
${e1ap_BearerContextSetupRequest_filter}                e1ap.procedureCode ==8 and e1ap.id == 15
${ngap_InitialUEMessage_filter}                         ngap.procedureCode == 15 and nas_5gs.mm.message_type == 0x41
${ngap_HandoverRequestAcknowledge_filter}               ngap.procedureCode == 13 and ngap.id == 53
${DeltaConfigDir}                                       ${CURDIR}/../../config/scf/
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts


*** Keywords ***
Prepare for test Case - CB008187_A01_B14
    [Documentation]     This Keyword is specifically used for setting up testcase A01 B14 for feature CB008187
    ...                 where we are testing f1ap,ngap,e1ap and RAN UE IDs for initial Access in NSA call
    ${Log_Path}    Create Log Directory        CB008187_A01_B14
    Link SCOUT SCF To Configuration ID For Reporting
    Add Preferences To Wireshark Config
    GNB Delta commission                ${DeltaConfigDir}/Delta_Configuration_TC1_8187Changes.json
    log to console                      Rebooting GNB wait for 360 seconds...
    GNB Reboot
    sleep   360s
    Wait Coam Site to be Ready
    Start Tcp Pcap on wts               log_dirpath=${Log_Path}
    Start pcap collection in gNB CU     gnbTcpdump              -f sctp -i any -s0
    Configure PCMD Server
    Start UTE WTS                       basic_setup.cfg
    Basic Bring up
    [Return]                            ${Log_Path}

Tear Down for test Case - CB008187_A01_B14
    [Documentation]     This Keyword is used for reverting back all changes we have made to testcase TC1 for feature CB008187
    unconfigure PCMD server
    Stop Tcp Pcap on wts
    Collect Logs For The Test           ${Log_Path}
    GNB Delta commission                ${DeltaConfigDir}/Delta_Configuration_TC1_8187_Changes_Reverse.json

Prepare for test Case - CB008187_B03_B10_2
    [Documentation]     This Keyword is specifically used for setting up testcase TC2 and TC3 for feature CB008187
     ...                where we are testing f1ap,ngap,e1ap and RAN UE IDs for rrc reconfiguration robustness test
    ${Log_Path}=    Create Log Directory        CB008187_B03_B10_2_3
    Link SCOUT SCF To Configuration ID For Reporting
    Add Preferences To Wireshark Config
    GNB Delta commission                ${DeltaConfigDir}/Delta_Configuration_TC2_8187Changes.json
    log to console                      Rebooting GNB wait for 360 seconds...
    GNB Reboot
    sleep                               360s
    Wait Coam Site to be Ready
    Configure PCMD Server
    Start UTE WTS                       basic_setup.cfg
    Basic Bring up
    [Return]                            ${Log_Path}

Tear Down for test Case - CB008187_B03_B10_2
    [Documentation]     This Keyword is used for reverting back all changes we have made to testcase TC2 and TC3 for feature CB008187
    UE Deregister should be Successful for SA
    unconfigure PCMD server
    Collect Logs For The Test           ${Log_Path}
    GNB Delta commission                ${DeltaConfigDir}/Delta_Configuration_TC2_8187_Changes_Reverse.json

Basic Bring up for gnb
    [Documentation]     This keyword is for basic bring up the setup it setup config file and then
    ...                 Make sure NG link , X2AP link  and AP cell setup are done to reach on air
    ...                 Arguments passed is the cfg file from config/wts/setupfile.cfg
    [Arguments]         ${config_wts_basic_setup}=basic_setup.cfg
    Start UTE WTS       ${config_wts_basic_setup}
    log to console      config setup Done
    NG Link Should be UP
    log to console      NG link is up
    X2AP Link Should be UP
    log to console      X2AP link should be Up
    Sleep               60s

Disable celltrace PCMD and SBA traces
    [Documentation]     This Keyword Disabling NIDD parameter as per the requirement of the feature CB008187
    Log to Console      Disabling feature flag
    admin.Setup admin
    Online NIDD parameter change    paramName=actCellTraceReport            paramValue=false
    ...                             paramDst=MRBTS-1/NRBTS-1
    Online NIDD parameter change    paramName=actPCMDReport                 paramValue=false
    ...                             paramDst=MRBTS-1/NRBTS-1
    Online NIDD parameter change    paramName=actSubscriberTraceReport      paramValue=false
    ...                             paramDst=MRBTS-1/NRBTS-1
    sleep               60s
    [Teardown]          admin.Teardown admin

Enable celltrace PCMD and SBA traces
    [Documentation]     This Keyword Enabling NIDD parameter as per the requirement of the feature CB008187
    Log to Console      Enabling feature flag
    admin.Setup admin
    Online NIDD parameter change    paramName=actCellTraceReport            paramValue=true
    ...                             paramDst=MRBTS-1/NRBTS-1
    Online NIDD parameter change    paramName=actPCMDReport                 paramValue=true
    ...                             paramDst=MRBTS-1/NRBTS-1
    Online NIDD parameter change    paramName=actSubscriberTraceReport      paramValue=true
    ...                             paramDst=MRBTS-1/NRBTS-1
    sleep                               60s
    [Teardown]          admin.Teardown admin

get ngap id from pcap
    [Documentation]      this keyword helps to get "ngap.RAN_UE_NGAP_ID" from the pcap file
    ...                  [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                  ngap_ID_filter  =   need to pass the filter for the ngap.RANUE_NGAP_ID
    ...                  [return]        ngap_id         =   integer
    [Arguments]         ${pcap_file}            ${ngap_ID_filter}=${ngap_InitialUEMessage_filter}
    ${ngap_ids}         Get Fields from Pcap    ${pcap_file}        ${ngap_ID_filter}           ${NGAP_UE_RAN_ID}
    @{ngap_id_list}     split string and return list                ${ngap_ids}                 \n
    ${ngap_id}          Convert To Integer      ${ngap_id_list}[0]
    [return]            ${ngap_id}

get f1ap id from pcap
    [Documentation]      this keyword helps to get "f1ap.GNB_CU_UE_F1AP_ID" from the pcap file
    ...                 [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                 f1ap_UE_filter  =   need to pass the filter for the f1ap.GNB_CU_UE_F1AP_ID
    ...                 [return]        f1ap_id         =   integer
    [Arguments]         ${pcap_file}            ${f1ap_UE_filter}=${f1ap_RRCSetup_filter}
    ${f1ap_ids}         Get Fields from Pcap    ${pcap_file}        ${f1ap_UE_filter}           ${F1AP_UE_ID}
    @{f1ap_id_list}     split string and return list                ${f1ap_ids}                 \n
    ${f1ap_id}          Convert To Integer      ${f1ap_id_list}[0]
    [return]            ${f1ap_id}

get e1ap id from pcap
    [Documentation]      this keyword helps to get "e1ap.GNB_CU_CP_UE_E1AP_ID" from the pcap file
    ...                 [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                 e1ap_UE_filter  =   need to pass the filter for the f1ap.GNB_CU_UE_F1AP_ID
    ...                 [return]        e1ap_id         =   integer
    [Arguments]         ${pcap_file}            ${e1ap_UE_filter}=${e1ap_BearerContextSetupRequest_filter}
    ${e1ap_ids}         Get Fields from Pcap    ${pcap_file}        ${e1ap_UE_filter}           ${E1AP_UE_ID}
    @{e1ap_id_list}     split string and return list                ${e1ap_ids}                 \n
    ${e1ap_id}          Convert To Integer      ${e1ap_id_list}[0]
    [return]            ${e1ap_id}

get xnap id from pcap
    [Documentation]      this keyword helps to get "xnap.RAN_UE_NGAP_ID" from the pcap file
    ...                  [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                  xnap_ID_filter  =   need to pass the filter for the ngap.RANUE_NGAP_ID
    ...                  [return]        xnap_id         =   integer
    [Arguments]          ${pcap_file}             ${xnap_ID_filter}=${xnap_HandoverRequestAcknowledge_filter}
    ${xnap_ids}          Get Fields from Pcap     ${pcap_file}        ${xnap_ID_filter}           ${XNAP_RAN_NODE_UE_XNAPID}
    @{xnap_id_list}      split string and return list                 ${xnap_ids}         ,
    ${xnap_id}           Convert To Integer       ${xnap_id_list}[-1]
    [return]             ${xnap_id}

verify f1ap e1ap and ngap IDs are equal
    [Documentation]      this Keyword is checking if f1ap,ngap,e1ap values which are passed as arguments is equal and
    ...                  returns converted Hex format string as expected RANUEID format
    ...                  [Arguments]        f1ap_id     =   Run time we capture f1ap_id and passing here to check if equal
    ...                                     e1ap_id     =   Run time we capture e1ap_id and passing here to check if equal
    ...                                     ngap_id     =   Run time we capture ngap_id and passing here to check if equal
    ...                  [return]           pcmd_ranId  =   Expected RANUEID
    [Arguments]         ${f1ap_id}          ${e1ap_id}      ${ngap_id}
    ${expected_id}      set variable        ${f1ap_id}
    Should Be Equal     ${expected_id}      ${e1ap_id}
    Should Be Equal     ${expected_id}      ${ngap_id}
    ${hex_f1ap_id}      convert to hex      ${f1ap_id}
    ${pcmd_ranId}       add zero padding    ${hex_f1ap_id}
    [return]            ${pcmd_ranId}

verify f1ap e1ap and xnap IDs are equal
    [Documentation]      this Keyword is checking if f1ap,ngap,e1ap values which are passed as arguments is equal and
    ...                  returns converted Hex format string as expected RANUEID format
    ...                  [Arguments]        f1ap_id     =   Run time we capture f1ap_id and passing here to check if equal
    ...                                     e1ap_id     =   Run time we capture e1ap_id and passing here to check if equal
    ...                                     xnap_id     =   Run time we capture xnap_id and passing here to check if equal
    ...                  [return]           pcmd_ranId  =   Expected RANUEID
    [Arguments]         ${f1ap_id}          ${e1ap_id}      ${xnap_id}
    ${expected_id}      set variable        ${f1ap_id}
    Should Be Equal     ${expected_id}      ${e1ap_id}
    Should Be Equal     ${expected_id}      ${xnap_id}
    ${hex_f1ap_id}      convert to hex      ${f1ap_id}
    ${pcmd_ranId}       add zero padding    ${hex_f1ap_id}
    [return]            ${pcmd_ranId}

verify f1ap and ngap IDs are equal
    [Documentation]      this Keyword is checking if f1ap,ngap values which are passed as arguments is equal and
    ...                  returns converted Hex format string as expected RANUEID format
    ...                  [Arguments]            f1ap_id             =   Run time we capture f1ap_id and passing here to check if equal
    ...                                         ngap_id             =   Run time we capture ngap_id and passing here to check if equal
    ...                  [return]               pcmd_ranId          =   Expected RANUEID
    [Arguments]          ${f1ap_id}             ${ngap_id}
    Should Be Equal      ${f1ap_id}             ${ngap_id}
    ${hex_f1ap_id}       convert to hex         ${f1ap_id}
    ${pcmd_ranId}        add zero padding       ${hex_f1ap_id}
    [return]             ${pcmd_ranId}

verify f1ap and e1ap IDs are equal
    [Documentation]      this Keyword is checking if f1ap,e1ap values which are passed as arguments is equal and
    ...                  returns converted Hex format string as expected RANUEID format
    ...                  [Arguments]            f1ap_id             =   Run time we capture f1ap_id and passing here to check if equal
    ...                                         e1ap_id             =   Run time we capture e1ap_id and passing here to check if equal
    ...                  [return]               pcmd_ranId          =   Expetted RANUEID
    [Arguments]          ${f1ap_id}             ${e1ap_id}
    Should Be Equal      ${f1ap_id}             ${e1ap_id}
    ${hex_f1ap_id}       convert to hex         ${f1ap_id}
    ${pcmd_ranId}        add zero padding       ${hex_f1ap_id}
    [return]             ${pcmd_ranId}

verify RAN UE ID in stoprecordings nsetapx
    [Documentation]      this Keyword is checking stop recording session SBA CU ,stop recording session MBA CU and stop recording session MBA DU
    ...                  [Arguments]     generated_RAN_UE_id   =     Expected RANUEID Value passed run time such as 00:00:00:00:00:00:00:00
    ...                                  eth_pcap_file         =     pcap file in whcih we should check the expected values
    [Arguments]          ${generated_RAN_UE_id}          ${eth_pcap_file}=eth3_tcp.pcap
    verify RAN UE ID in nsetpx stop recording session SBA CU            ${generated_RAN_UE_id}          pcap_file=${eth_pcap_file}
    verify RAN UE ID in nsetpx stop recording session MBA CU            ${generated_RAN_UE_id}          pcap_file=${eth_pcap_file}
    verify RAN UE ID in nsetpx stop recording session MBA DU            ${generated_RAN_UE_id}          pcap_file=${eth_pcap_file}

verify RAN UE ID in startrecordings nsetapx
    [Documentation]      this Keyword is checking start recording session SBA CU ,start recording session MBA CU and start recording session MBA DU
    ...                     [Arguments]    generated_RAN_UE_id    =     Expected RANUEID Value passed run time such as 00:00:00:00:00:00:00:00
    ...                                    eth_pcap_file          =     pcap file in whcih we should check the expected values
    [Arguments]             ${generated_RAN_UE_id}         ${eth_pcap_file}=eth3_tcp.pcap
    verify RAN UE ID in nsetpx start recording session SBA CU           ${generated_RAN_UE_id}          pcap_file=${eth_pcap_file}
    verify RAN UE ID in nsetpx start recording session MBA CU           ${generated_RAN_UE_id}          pcap_file=${eth_pcap_file}
    verify RAN UE ID in nsetpx start recording session MBA DU           ${generated_RAN_UE_id}          pcap_file=${eth_pcap_file}

verify RAN UE ID in reports nsetapx
    [Documentation]      this Keyword is checking cu celltrace report , cu PCMD report , du celltrace report and sba celltrace report
    ...                  [Arguments]    generated_start_RAN_UE_id   =     Expected RANUEID Value passed run time such as 00:00:00:00:00:00:00:00
    ...                                 enerated_stop_RAN_UE_id     =     Expected RANUEID Value passed run time such as 00:00:00:00:00:00:00:00
    ...                                 eth_pcap_file               =     pcap file in whcih we should check the expected values
    [Arguments]         ${generated_start_RAN_UE_id}        ${generated_stop_RAN_UE_id}=00:00:00:00:00:00:00:00
    ...                 ${eth_pcap_file}=eth3_tcp.pcap
    @{generated_RAN_UE_ids}             Create List         ${generated_start_RAN_UE_id}     ${generated_stop_RAN_UE_id}
    verify RAN UE ID in nsetpx cu celltrace report          ${generated_RAN_UE_ids}          pcap_file=${eth_pcap_file}
    verify RAN UE ID in nsetpx cu pcmd report               ${generated_RAN_UE_ids}          pcap_file=${eth_pcap_file}
    verify RAN UE ID in nsetpx du pcmd report               ${generated_RAN_UE_ids}          pcap_file=${eth_pcap_file}
    verify RAN UE ID in nsetpx sba celltrace report         ${generated_RAN_UE_ids}          pcap_file=${eth_pcap_file}

verify RAN UE ID in nsetpx start recording session SBA CU
    [Arguments]             ${generated_RAN_UE_id}          ${filter}=${NSETAPX_START_RECORDING_SESSION_SBA_CU}
    ...                     ${pcap_file}=eth3_tcp.pcap      ${alias}=tcp_pcap
    @{RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}=       Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    List Should Contain Value          ${RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}        ${generated_RAN_UE_id}

verify RAN UE ID in nsetpx stop recording session SBA CU
    [Arguments]             ${generated_RAN_UE_id}              ${filter}=${NSETAPX_STOP_RECORDING_SESSION_SBA_CU}
    ...                     ${pcap_file}=eth3_tcp.pcap          ${alias}=tcp_pcap
    @{RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}=            Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file2.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    List Should Contain Value          ${RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}        ${generated_RAN_UE_id}

verify RAN UE ID in nsetpx start recording session MBA CU
    [Arguments]             ${generated_RAN_UE_id}              ${filter}=${NSETAPX_START_RECORDING_SESSION_MBA_CU}
    ...                     ${pcap_file}=eth3_tcp.pcap          ${alias}=tcp_pcap
    @{RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}=           Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    List Should Contain Value          ${RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}        ${generated_RAN_UE_id}

verify RAN UE ID in nsetpx stop recording session MBA CU
    [Arguments]             ${generated_RAN_UE_id}              ${filter}=${NSETAPX_STOP_RECORDING_SESSION_MBA_CU}
    ...                     ${pcap_file}=eth3_tcp.pcap          ${alias}=tcp_pcap
    @{RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}=            Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file2.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    List Should Contain Value          ${RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}        ${generated_RAN_UE_id}

verify RAN UE ID in nsetpx start recording session MBA DU
    [Arguments]             ${generated_RAN_UE_id}              ${filter}=${NSETAPX_START_RECORDING_SESSION_MBA_DU}
    ...                     ${pcap_file}=eth3_tcp.pcap          ${alias}=tcp_pcap
    @{RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}=           Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    List Should Contain Value          ${RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}        ${generated_RAN_UE_id}

verify RAN UE ID in nsetpx stop recording session MBA DU
    [Arguments]             ${generated_RAN_UE_id}              ${filter}=${NSETAPX_STOP_RECORDING_SESSION_MBA_DU}
    ...                     ${pcap_file}=eth3_tcp.pcap          ${alias}=tcp_pcap
    @{RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}=            Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file2.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    List Should Contain Value          ${RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}        ${generated_RAN_UE_id}

verify RAN UE ID in nsetpx cu celltrace report
    [Arguments]             ${generated_RAN_UE_ids}             ${filter}=${NSETAPX_CU_CELLTRACE_REPORT}
    ...                     ${pcap_file}=eth3_tcp.pcap          ${alias}=tcp_pcap
    @{RANUEID_UNDER_CU_CELLTRACE_REPORT}=                       Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file3.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                 ${RANUEID_UNDER_CU_CELLTRACE_REPORT}
    List Should Contain Sub List        ${generated_RAN_UE_ids}         ${RANUEID_UNDER_CU_CELLTRACE_REPORT}

verify RAN UE ID in nsetpx cu pcmd report
    [Arguments]             ${generated_RAN_UE_ids}             ${filter}=${NSETAPX_CU_PCMD_REPORT}
    ...                     ${pcap_file}=eth3_tcp.pcap          ${alias}=tcp_pcap
    @{RANUEID_UNDER_CU_PCMD_REPORT}=                            Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file4.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                 ${RANUEID_UNDER_CU_PCMD_REPORT}
    List Should Contain Sub List        ${generated_RAN_UE_ids}      ${RANUEID_UNDER_CU_PCMD_REPORT}

verify RAN UE ID in nsetpx du pcmd report
    [Arguments]             ${generated_RAN_UE_ids}             ${filter}=${NSETAPX_DU_PCMD_REPORT}
    ...                     ${pcap_file}=eth3_tcp.pcap          ${alias}=tcp_pcap
    @{RANUEID_UNDER_DU_PCMD_REPORT}=                            Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file5.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                 ${RANUEID_UNDER_DU_PCMD_REPORT}
    List Should Contain Sub List        ${generated_RAN_UE_ids}      ${RANUEID_UNDER_DU_PCMD_REPORT}

verify RAN UE ID in nsetpx sba celltrace report
    [Arguments]             ${generated_RAN_UE_ids}             ${filter}=${NSETAPX_SBA_CELLTRACE_REPORT}
    ...                     ${pcap_file}=eth3_tcp.pcap          ${alias}=tcp_pcap
    @{RANUEID_UNDER_SBA_CELLTRACE_REPORT}=                      Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file6.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                     ${RANUEID_UNDER_SBA_CELLTRACE_REPORT}
    List Should Contain Sub List            ${generated_RAN_UE_ids}         ${RANUEID_UNDER_SBA_CELLTRACE_REPORT}

Register and establish Non-GBR call
    [Documentation]     This keyword shall register UE and establish Non-GBR data call
    ...                 [arguments]     UE_ID           :   parse UE ID
    ...                                 gw_ID           :   Gateway Id is required else it will take deffault value
    ...                                 Pdu_session_ID  :   PDU Session Id is required deffault value set is 1
    ...                                 traffic_dl_rate :   traffic downlink data rate is required deffault value set is 1
    ...                                 traffic_ul_rate :   traffic uplink data rate is required deffault value set is 1
    [Arguments]         ${UE_ID}=${UE_ID}           ${Pdu_session_ID}=${Pdu_session_ID}
    ...                 ${traffic_dl_rate}=${traffic_dl_rate}               ${traffic_ul_rate}=${traffic_ul_rate}
    Enable Internal TG           ${UE_ID}           ${Pdu_session_ID}
    UE Register should be Successful
    Sleep               10s
    Traffic should be successful for SA             ${traffic_dl_rate}          ${traffic_ul_rate}            ${UE_ID}
    Sleep               10s

Stop pcap collection in gNB CU
    [Documentation]    This keyword is to stop PCAP logs from gnB
    ...     [arguments]    name     : This is file name where pcap logs will be collected, default name is gnbTcpdump
    ...                    Log_path : Path where pcap log file will be stored, default path is Log_Path
    ...     [return]    pcap_file   : pcap file path captured on wts
    ...     [usage]     Stop pcap collection in gNB
    ...                 Stop pcap collection in gNB     name=PCAPLOG    Log_Path= dir/dir/filename
    ...                 Stop pcap collection in gNB     gnbTcpdump1     dir/dir/filename
    [Arguments]                     ${name}=gnbTcpdump                  ${Log_Path}=${Log_Path}
    core.stop_collectors            names=${name}
    core.collect_collectors         names=${name}       target_dir=${Log_Path}
    core.teardown_collectors        names=${name}
    ${pcap_file}    Join Path       ${Log_Path}         ${name}         ${name}.pcap
    log to console                  pcap capture is stopped
    [Return]                        ${pcap_file}

verify RAN UE ID in stoprecordings CU and DU
    [Documentation]      this Keyword is checking stop recording session SBA CU ,stop recording session MBA CU and stop recording session MBA DU
    ...                  [Arguments]     generated_RAN_UE_id   =     Expected RANUEID Value passed run time such as 00:00:00:00:00:00:00:00
    ...                                  eth_pcap_file         =     pcap file in whcih we should check the expected values
    [Arguments]          ${generated_RAN_UE_id}          ${eth_pcap_file}=eth3_tcp.pcap
    verify RAN UE ID in nsetpx stop recording session MBA CU            ${generated_RAN_UE_id}          pcap_file=${eth_pcap_file}
    verify RAN UE ID in nsetpx stop recording session MBA DU            ${generated_RAN_UE_id}          pcap_file=${eth_pcap_file}

verify RAN UE ID in startrecordings CU and DU
    [Documentation]      this Keyword is checking start recording session SBA CU ,start recording session MBA CU and start recording session MBA DU
    ...                     [Arguments]    generated_RAN_UE_id    =     Expected RANUEID Value passed run time such as 00:00:00:00:00:00:00:00
    ...                                    eth_pcap_file          =     pcap file in whcih we should check the expected values
    [Arguments]             ${generated_RAN_UE_id}         ${eth_pcap_file}=eth3_tcp.pcap
    verify RAN UE ID in nsetpx start recording session MBA CU           ${generated_RAN_UE_id}          pcap_file=${eth_pcap_file}
    verify RAN UE ID in nsetpx start recording session MBA DU           ${generated_RAN_UE_id}          pcap_file=${eth_pcap_file}

verify RAN UE ID in reports CU and DU
    [Documentation]      this Keyword is checking cu celltrace report , cu PCMD report , du celltrace report and sba celltrace report
    ...                  [Arguments]    generated_start_RAN_UE_id   =     Expected RANUEID Value passed run time such as 00:00:00:00:00:00:00:00
    ...                                 enerated_stop_RAN_UE_id     =     Expected RANUEID Value passed run time such as 00:00:00:00:00:00:00:00
    ...                                 eth_pcap_file               =     pcap file in whcih we should check the expected values
    [Arguments]         ${generated_start_RAN_UE_id}        ${generated_stop_RAN_UE_id}=00:00:00:00:00:00:00:00
    ...                 ${eth_pcap_file}=eth3_tcp.pcap
    @{generated_RAN_UE_ids}             Create List         ${generated_start_RAN_UE_id}     ${generated_stop_RAN_UE_id}
    verify RAN UE ID in nsetpx cu celltrace report          ${generated_RAN_UE_ids}          pcap_file=${eth_pcap_file}
    verify RAN UE ID in nsetpx cu pcmd report               ${generated_RAN_UE_ids}          pcap_file=${eth_pcap_file}
    verify RAN UE ID in nsetpx du pcmd report               ${generated_RAN_UE_ids}          pcap_file=${eth_pcap_file}

Make NSA Call for 8187
    [Arguments]             ${UE_ID_NSA}=101         ${dl_rate}=5        ${ul_rate}=5       ${duration}=60s
    LTE Attach should be Successful for NSA      ${UE_ID_NSA}
    UE Attach should be Successful for NSA      ${UE_ID_NSA}
    Start LTE Traffic       ${UE_ID_NSA}            ${dl_rate}          ${ul_rate}         ${duration}

NSA Call UE Detach
    [Arguments]             ${UE_ID_NSA}=101
    UE 5GDetach should be Successful for NSA    ${UE_ID_NSA}
    UE Detach should be Successful for NSA      ${UE_ID_NSA}
