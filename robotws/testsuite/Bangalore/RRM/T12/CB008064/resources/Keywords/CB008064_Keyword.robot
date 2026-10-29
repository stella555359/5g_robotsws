*** Settings ***
Documentation    This File contains all the common keywords specific to the Feature CB008064
...              for all the test cases setup and teardown and other specific keywords.
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         Collections
Variables       ta5g_global_var
Library         ute_fsmaccess
Library         ta5g_pm_counters
Library         ${CURDIR}/../../../resources/PythonLib/UTILS.py
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/PCMD_Related_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${TOPOLOGY}                 CLOUD_5G_I_LO_AP_LO
${DeltaConfigDir}           ${CURDIR}/../../config/scf/
${TC1_TCE1_IP_PORT}         ip.dst == 10.0.1.1 && tcp.dstport == 49145
${TC1_TCE2_IP_PORT}         ip.dst == 10.0.1.1 && tcp.dstport == 49150
${TC1_TCE3_IP_PORT}         ip.dst == 10.0.1.1 && tcp.dstport == 49149
${TC1_TCE4_IP_PORT}         ip.dst == 10.0.1.1 && tcp.dstport == 49148
${TC1_TCE5_IP_PORT}         ip.dst == 10.0.1.1 && tcp.dstport == 49147
${SBA_TCE6_IP_PORT}         ip.dst == 10.0.1.7 && tcp.dstport == 49146
${TCE1_IP_PORT}             ip.dst == 10.0.1.1 && tcp.dstport == 49145
${TCE2_IP_PORT}             ip.dst == 10.0.1.3 && tcp.dstport == 49145
${TCE3_IP_PORT}             ip.dst == 10.0.1.4 && tcp.dstport == 49145
${TCE4_IP_PORT}             ip.dst == 10.0.1.5 && tcp.dstport == 49145
${TCE5_IP_PORT}             ip.dst == 10.0.1.6 && tcp.dstport == 49145
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts


*** Keywords ***
Prepare for test Case - CB008064_B01
    [Documentation]     This Keyword is specifically used for setting up testcase CB008064_B01
    ${Log_Path}        Create Log Directory        CB008064_B01
    Link SCOUT SCF to Configuration ID for Reporting
    Add Preferences To Wireshark Config
    GNB Delta commission        ${DeltaConfigDir}/Delta_Configuration_TC1_8064_Changes.json         ${False}
    log to console              Rebooting GNB wait for 360 seconds...
    GNB Reboot
    sleep               360s
    Wait Coam Site to be Ready
    Create Basic Interface on UTE
    Adding required IPs for different TCE severs for 8064
    configure pcmd          ip=10.0.1.1        port=49145        technology=5G        asn1per_decoding=${True}        clients=1
    configure pcmd          ip=10.0.1.1        port=49150        technology=5G        asn1per_decoding=${True}        clients=1
    configure pcmd          ip=10.0.1.1        port=49149        technology=5G        asn1per_decoding=${True}        clients=1
    configure pcmd          ip=10.0.1.1        port=49148        technology=5G        asn1per_decoding=${True}        clients=1
    configure pcmd          ip=10.0.1.1        port=49147        technology=5G        asn1per_decoding=${True}        clients=1
    configure pcmd          ip=10.0.1.7        port=49146        technology=5G        asn1per_decoding=${True}        clients=1
    sleep                           2s
    Start collecting PCMD reports on single TCE      ip=10.0.1.1      port=49145
    Start collecting PCMD reports on single TCE      ip=10.0.1.1      port=49150
    Start collecting PCMD reports on single TCE      ip=10.0.1.1      port=49149
    Start collecting PCMD reports on single TCE      ip=10.0.1.1      port=49148
    Start collecting PCMD reports on single TCE      ip=10.0.1.1      port=49147
    Start collecting PCMD reports on single TCE      ip=10.0.1.7      port=49146
    Start Tcp Pcap on wts       log_filename=${pcapfile1}              log_dirpath=${Log_Path}
    Basic Bring up gnb          basic_8064.cfg
    [Return]                    ${Log_Path}

Tear Down for test Case - CB008064_B01
    [Documentation]     This Keyword is used for reverting back all changes we have made to testcase CB008064_B01
    Stop collecting PCMD reports on single TCE      ip=10.0.1.1      port=49145
    Stop collecting PCMD reports on single TCE      ip=10.0.1.1      port=49150
    Stop collecting PCMD reports on single TCE      ip=10.0.1.1      port=49149
    Stop collecting PCMD reports on single TCE      ip=10.0.1.1      port=49148
    Stop collecting PCMD reports on single TCE      ip=10.0.1.1      port=49147
    Stop collecting PCMD reports on single TCE      ip=10.0.1.7      port=49146
    sleep       2s
    deconfigure PCMD      ip=10.0.1.1      port=49145
    deconfigure PCMD      ip=10.0.1.1      port=49150
    deconfigure PCMD      ip=10.0.1.1      port=49149
    deconfigure PCMD      ip=10.0.1.1      port=49148
    deconfigure PCMD      ip=10.0.1.1      port=49147
    deconfigure PCMD      ip=10.0.1.7      port=49146
    Get SCF Value from file
    Deleting required IPs for different TCE severs for 8064
    Delete Basic Interface on UTE
    GNB Delta commission        ${DeltaConfigDir}/Delta_Configuration_TC1_8064_Changes_Reverse.json         ${False}
    Collect Logs For The Test           ${Log_Path}

Prepare for test Case - CB008064_B02
    [Documentation]     This Keyword is specifically used for setting up testcase CB008064_B02
    ${Log_Path}        Create Log Directory        CB008064_B02
    Link SCOUT SCF to Configuration ID for Reporting
    Add Preferences To Wireshark Config
    GNB Delta commission        ${DeltaConfigDir}/Delta_Configuration_TC2_8064_Changes.json         ${False}
    log to console              Rebooting GNB wait for 360 seconds...
    GNB Reboot
    sleep               360s
    Wait Coam Site to be Ready
    Create Basic Interface on UTE
    Adding required IPs for different TCE severs for 8064
    Configure PCMD server and start collecting report for same ip diff ports in 8064
    Basic Bring up gnb          basic_8064.cfg
    [Return]                    ${Log_Path}

Tear Down for test Case - CB008064_B02
    [Documentation]     This Keyword is used for reverting back all changes we have made to testcase CB008064_B02
    Unconfigure PCMD server and start collecting report for same ip diff ports in 8064
    Get SCF Value from file
    Deleting required IPs for different TCE severs for 8064
    Delete Basic Interface on UTE
    GNB Delta commission         ${DeltaConfigDir}/Delta_Configuration_TC2_8064_Changes_Reverse.json         ${False}
    Collect Logs For The Test           ${Log_Path}

Prepare for test Case - CB008064_B03
    [Documentation]     This Keyword is specifically used for setting up testcase CB008064_B03
    ${Log_Path}         Create Log Directory        CB008064_B03
    Link SCOUT SCF to Configuration ID for Reporting
    Add Preferences To Wireshark Config
    GNB Delta commission        ${DeltaConfigDir}/Delta_Configuration_TC3_8064_Changes.json        ${False}
    log to console              Rebooting GNB wait for 360 seconds...
    GNB Reboot
    Sleep               360s
    Wait Coam Site to be Ready
    Create Basic Interface on UTE
    Adding required IPs for different TCE severs for 8064
    Basic Bring up gnb          basic_8064.cfg
    Configure PCMD server and start collecting report for same ip diff ports in 8064
    [Return]                    ${Log_Path}

Tear Down for test Case - CB008064_B03
    [Documentation]     This Keyword is used for reverting back all changes we have made to testcase CB008064_B03
    Unconfigure PCMD server and start collecting report for same ip diff ports in 8064
    Get SCF Value from file
    Deleting required IPs for different TCE severs for 8064
    Delete Basic Interface on UTE
    GNB Delta commission         ${DeltaConfigDir}/Delta_Configuration_TC3_8064_Changes_Reverse.json
    Collect Logs For The Test           ${Log_Path}
    Link SCOUT SCF to Configuration ID for Reporting

Basic Bring up gnb
    [Documentation]     This keyword is for basic bring up the setup it setup config file and then
    ...                 Make sure NG link, X2AP link  and AP cell setup are done to reach on air
    ...                 Arguments passed is the cfg file from config/wts/setupfile.cfg
    [Arguments]         ${config_wts_basic_setup}=basic_setup.cfg
    Start UTE WTS       ${config_wts_basic_setup}
    log to console      config setup Done
    NG Link Should be UP
    log to console      NG link is up
    X2AP Link Should be UP
    log to console      X2AP link should be Up
    Sleep    60s

Adding required IPs for different TCE severs for 8064
    Run     sudo ip addr add 10.0.1.3/24 dev eth3 brd 10.0.1.255
    Run     sudo ip addr add 10.0.1.4/24 dev eth3 brd 10.0.1.255
    Run     sudo ip addr add 10.0.1.5/24 dev eth3 brd 10.0.1.255
    Run     sudo ip addr add 10.0.1.6/24 dev eth3 brd 10.0.1.255
    RUN     sudo ip addr add 10.0.1.7/24 dev eth3 brd 10.0.1.255

Deleting required IPs for different TCE severs for 8064
    Run     sudo ip addr del 10.0.1.3/24 dev eth3 brd 10.0.1.255
    Run     sudo ip addr del 10.0.1.4/24 dev eth3 brd 10.0.1.255
    Run     sudo ip addr del 10.0.1.5/24 dev eth3 brd 10.0.1.255
    Run     sudo ip addr del 10.0.1.6/24 dev eth3 brd 10.0.1.255
    Run     sudo ip addr del 10.0.1.7/24 dev eth3 brd 10.0.1.255

Disable NRBTS level celltrace and PCMD NIDD parameters
    [Documentation]     This Keyword Disabling NIDD parameter as per the requirement of the feature CB008064
    Log to Console      Disabling feature flag
    admin.Setup admin
    Online NIDD parameter change    paramName=actCellTraceReport            paramValue=false
    ...                             paramDst=MRBTS-1/NRBTS-1
    Online NIDD parameter change    paramName=actPCMDReport                 paramValue=false
    ...                             paramDst=MRBTS-1/NRBTS-1
    Online NIDD parameter change    paramName=actSubscriberTraceReport      paramValue=false
    ...                             paramDst=MRBTS-1/NRBTS-1
    sleep               30s
    [Teardown]          admin.Teardown admin

Trigger SBA trace recording with PDU setup from AMF
    [Arguments]    ${ue_id}=1    ${tce_ip}=0.0.0.0      ${trace_ref_id}=1       ${trace_rec_session_ref_id}=1
    wtsrunner.amf_ue_ics_param  id=1    ue=${ue_id}     object_id=1     location_reporting_reference_id=1
    ...     trace_activation=on     trace_plmn=311:489
    ...     trace_ref_id=${trace_ref_id}      trace_rec_session_ref_id=${trace_rec_session_ref_id}
    ...     trace_depth=medium      ifaces_to_trace=Uu,NG-C,Xn-C    tce_ip=${tce_ip}
    Sleep    2s

suite teardown for 8064
    RAT Block Unblock
    Common Suite Teardown

Configure PCMD server and start collecting report for same ip diff ports in 8064
    configure pcmd          ip=10.0.1.1      port=49145          technology=5G            asn1per_decoding=${True}      clients=1
    configure pcmd          ip=10.0.1.3      port=49145          technology=5G            asn1per_decoding=${True}      clients=1
    configure pcmd          ip=10.0.1.4      port=49145          technology=5G            asn1per_decoding=${True}      clients=1
    configure pcmd          ip=10.0.1.5      port=49145          technology=5G            asn1per_decoding=${True}      clients=1
    configure pcmd          ip=10.0.1.6      port=49145          technology=5G            asn1per_decoding=${True}      clients=1
    configure pcmd          ip=10.0.1.7      port=49146          technology=5G            asn1per_decoding=${True}      clients=1
    sleep                           2s
    Start collecting PCMD reports on single TCE     ip=10.0.1.1      port=49145
    Start collecting PCMD reports on single TCE     ip=10.0.1.3      port=49145
    Start collecting PCMD reports on single TCE     ip=10.0.1.4      port=49145
    Start collecting PCMD reports on single TCE     ip=10.0.1.5      port=49145
    Start collecting PCMD reports on single TCE     ip=10.0.1.6      port=49145
    Start collecting PCMD reports on single TCE     ip=10.0.1.7      port=49146

Unconfigure PCMD server and start collecting report for same ip diff ports in 8064
    Stop collecting PCMD reports on single TCE     ip=10.0.1.1      port=49145
    Stop collecting PCMD reports on single TCE     ip=10.0.1.3      port=49145
    Stop collecting PCMD reports on single TCE     ip=10.0.1.4      port=49145
    Stop collecting PCMD reports on single TCE     ip=10.0.1.5      port=49145
    Stop collecting PCMD reports on single TCE     ip=10.0.1.6      port=49145
    Stop collecting PCMD reports on single TCE     ip=10.0.1.7      port=49146
    sleep       2s
    deconfigure PCMD    ip=10.0.1.1      port=49145
    deconfigure PCMD    ip=10.0.1.3      port=49145
    deconfigure PCMD    ip=10.0.1.4      port=49145
    deconfigure PCMD    ip=10.0.1.5      port=49145
    deconfigure PCMD    ip=10.0.1.6      port=49145
    deconfigure PCMD    ip=10.0.1.7      port=49146

Verify TraceIds in SBA CU moc
    [Arguments]        ${pcap_file}=CB008064_B01.pcap        ${alias}=tcp_pcap
    ${Sba_start_RANUEID}         Run Keyword And Ignore Error
    ...     verify RAN UE ID in nsetpx start recording session SBA CU      pcap_file=${pcap_file}      alias=${alias}
    ${Sba_stop_RANUEID}         Run Keyword And Ignore Error
    ...     verify RAN UE ID in nsetpx stop recording session SBA CU       pcap_file=${pcap_file}      alias=${alias}
    # Lists Should be Equal        ${Sba_start_RANUEID}                          ${Sba_stop_RANUEID}
    verify No MBA Messages in moc                                    pcap_file=${pcap_file}      alias=${alias}
    verify traceId in nsetpx start recording session SBA CU          pcap_file=${pcap_file}      alias=${alias}
    verify traceId in nsetpx sba celltrace report                    pcap_file=${pcap_file}      alias=${alias}
    verify traceId in nsetpx stop recording session SBA CU           pcap_file=${pcap_file}      alias=${alias}

verify traceId in nsetpx start recording session SBA CU
    [Arguments]     ${filter}=${NSETAPX_START_RECORDING_SESSION_SBA_CU}    ${pcap_file}=eth3_tcp.pcap    ${alias}=tcp_pcap
    @{TRACEID_UNDER_NSETAPX_START_RECORDING_SESSION}       Get Attribute Values From Tshark Messages     alias=${alias}
    ...     filter=${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${TRACEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    @{TRACEID}      Remove Duplicates       ${TRACEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    @{Expected_TraceId_list}        Create List         00:00:06
    Lists Should Be Equal           ${TRACEID}          ${Expected_TraceId_list}

verify traceId in nsetpx stop recording session SBA CU
    [Arguments]             ${filter}=${NSETAPX_STOP_RECORDING_SESSION_SBA_CU}
    ...                     ${pcap_file}=eth3_tcp.pcap          ${alias}=tcp_pcap
    @{TRACEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}=            Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file2.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${TRACEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    @{TRACEID}      Remove Duplicates       ${TRACEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    @{Expected_TraceId_list}        Create List         00:00:06
    Lists Should Be Equal           ${TRACEID}          ${Expected_TraceId_list}

verify traceId in nsetpx sba celltrace report
    [Arguments]             ${filter}=${NSETAPX_SBA_CELLTRACE_REPORT}
    ...                     ${pcap_file}=eth3_tcp.pcap          ${alias}=tcp_pcap
    @{TRACEID_UNDER_SBA_CELLTRACE_REPORT}=                      Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file6.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                     ${TRACEID_UNDER_SBA_CELLTRACE_REPORT}
    @{TRACEID}      Remove Duplicates       ${TRACEID_UNDER_SBA_CELLTRACE_REPORT}
    @{Expected_TraceId_list}        Create List         00:00:06
    Lists Should Be Equal           ${TRACEID}          ${Expected_TraceId_list}

Verify TraceIds in MBA DU moc
    [Arguments]    ${filter}=${TCE1_IP_PORT}    ${id}=1     ${pcap_file}=CB008064_B04.pcap    ${alias}=tcp_pcap
    ${Sba_start_RANUEID}     Run Keyword And Ignore Error
    ...    verify RAN UE ID in nsetpx start recording session in MBA DU    ${filter}    ${pcap_file}    ${alias}
    ${Sba_stop_RANUEID}     Run Keyword And Ignore Error
    ...          verify RAN UE ID in nsetpx start recording session in MBA DU    ${filter}    ${pcap_file}    ${alias}
    # Lists Should Be Equal        ${Sba_start_RANUEID}           ${Sba_stop_RANUEID}
    verify No SBA Messages in moc    filter=${filter}   pcap_file=${pcap_file}   alias=${alias}
    Verify traceId in Start Recording for MBA DU    filter=${filter}    id=${id}    pcap_file=${pcap_file}    alias=${alias}
    Verify traceId in MBA DU PCMD Reports           filter=${filter}    id=${id}    pcap_file=${pcap_file}    alias=${alias}
    Verify traceId in Stop Recording for MBA DU     filter=${filter}    id=${id}    pcap_file=${pcap_file}    alias=${alias}

Verify traceId in MBA DU PCMD Reports
    [Arguments]             ${filter}=${TCE1_IP_PORT}        ${id}=1
    ...                     ${pcap_file}=CB008064_B01.pcap       ${alias}=tcp_pcap
    @{TRACEID_UNDER_DU_PCMD_REPORT}=                            Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter} && ${NSETAPX_DU_PCMD_REPORT}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file5.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty    ${TRACEID_UNDER_DU_PCMD_REPORT}
    @{TRACEID}      Remove Duplicates       ${TRACEID_UNDER_DU_PCMD_REPORT}
    @{Expected_TraceId_list}        Create List         00:00:0${id}
    Lists Should Be Equal           ${TRACEID}          ${Expected_TraceId_list}

Verify traceId in Start Recording for MBA DU
    [Arguments]             ${filter}=${TCE1_IP_PORT}        ${id}=1
    ...                     ${pcap_file}=CB008064_B01.pcap       ${alias}=tcp_pcap
    @{TRACEID_UNDER_NSETAPX_START_RECORDING_SESSION}=        Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${NSETAPX_START_RECORDING_SESSION_MBA_DU} && ${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty    ${TRACEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    @{TRACEID}      Remove Duplicates       ${TRACEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    @{Expected_TraceId_list}        Create List         00:00:0${id}
    Lists Should Be Equal           ${TRACEID}          ${Expected_TraceId_list}

Verify traceId in Stop Recording for MBA DU
    [Arguments]             ${filter}=${TCE1_IP_PORT}       ${id}=1
    ...                     ${pcap_file}=CB008064_B01.pcap      ${alias}=tcp_pcap
    @{TRACEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}=        Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${NSETAPX_STOP_RECORDING_SESSION_MBA_DU} && ${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty    ${TRACEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    @{TRACEID}      Remove Duplicates       ${TRACEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    @{Expected_TraceId_list}        Create List         00:00:0${id}
    Lists Should Be Equal           ${TRACEID}          ${Expected_TraceId_list}

Verify TraceIds in MBA CU moc with PCMD Only
    [Arguments]            ${filter}=${TCE1_IP_PORT}                 ${id}=1
    ...                    ${pcap_file}=CB008064_B04.pcap            ${alias}=tcp_pcap
    ${Sba_start_RANUEID}     Run Keyword And Ignore Error
    ...      verify RAN UE ID in nsetpx start recording session in MBA CU      ${filter}    ${pcap_file}    ${alias}
    ${Sba_stop_RANUEID}     Run Keyword And Ignore Error
    ...      verify RAN UE ID in nsetpx stop recording session in MBA CU       ${filter}    ${pcap_file}     ${alias}
    # Lists Should Be Equal       ${Sba_start_RANUEID}               ${Sba_stop_RANUEID}
    verify No SBA Messages in moc                           filter=${filter}                pcap_file=${pcap_file}      alias=${alias}
    verify No Celltrace Report Messages in moc              filter=${filter}                pcap_file=${pcap_file}      alias=${alias}
    Verify traceId in Start Recording for MBA CU            filter=${filter}    id=${id}    pcap_file=${pcap_file}      alias=${alias}
    Verify traceId in MBA CU PCMD Reports                   filter=${filter}    id=${id}    pcap_file=${pcap_file}      alias=${alias}
    Verify traceId in Stop Recording for MBA CU             filter=${filter}    id=${id}    pcap_file=${pcap_file}      alias=${alias}

Verify TraceIds in MBA CU moc with Celltrace Only
    [Arguments]            ${filter}=${TCE1_IP_PORT}                ${id}=1
    ...                    ${pcap_file}=CB008064_B04.pcap           ${alias}=tcp_pcap
    ${Sba_start_RANUEID}     Run Keyword And Ignore Error
    ...    verify RAN UE ID in nsetpx start recording session in MBA CU      ${filter}        ${pcap_file}      ${alias}
    ${Sba_stop_RANUEID}     Run Keyword And Ignore Error
    ...    verify RAN UE ID in nsetpx stop recording session in MBA CU       ${filter}        ${pcap_file}      ${alias}
    # Lists Should Be Equal       ${Sba_start_RANUEID}                ${Sba_stop_RANUEID}
    verify No SBA Messages in moc                            filter=${filter}                pcap_file=${pcap_file}      alias=${alias}
    verify No PCMD Report Messages in moc               filter=${filter}                pcap_file=${pcap_file}      alias=${alias}
    Verify traceId in Start Recording for MBA CU             filter=${filter}    id=${id}    pcap_file=${pcap_file}      alias=${alias}
    Verify traceId in MBA CU Celltrace Reports               filter=${filter}    id=${id}    pcap_file=${pcap_file}      alias=${alias}
    Verify traceId in Stop Recording for MBA CU              filter=${filter}    id=${id}    pcap_file=${pcap_file}      alias=${alias}

Verify TraceIds in MBA CU moc with PCMD and Celltrace
    [Arguments]            ${filter}=${TCE1_IP_PORT}                ${id}=1
    ...                    ${pcap_file}=CB008064_B04.pcap           ${alias}=tcp_pcap
    ${Sba_start_RANUEID}     Run Keyword And Ignore Error
    ...    verify RAN UE ID in nsetpx start recording session in MBA CU      ${filter}        ${pcap_file}      ${alias}
    ${Sba_stop_RANUEID}     Run Keyword And Ignore Error
    ...    verify RAN UE ID in nsetpx stop recording session in MBA CU       ${filter}        ${pcap_file}      ${alias}
    # Lists Should Be Equal       ${Sba_start_RANUEID}                ${Sba_stop_RANUEID}
    verify No SBA Messages in moc                                   filter=${filter}                pcap_file=${pcap_file}      alias=${alias}
    Verify traceId in Start Recording for MBA CU                    filter=${filter}    id=${id}    pcap_file=${pcap_file}      alias=${alias}
    Verify traceId in MBA CU PCMD and celltrace Reports             filter=${filter}    id=${id}    pcap_file=${pcap_file}      alias=${alias}
    Verify traceId in Stop Recording for MBA CU                     filter=${filter}    id=${id}    pcap_file=${pcap_file}      alias=${alias}

Verify traceId in Start Recording for MBA CU
    [Arguments]             ${filter}=${TC1_TCE1_IP_PORT}        ${id}=1
    ...                     ${pcap_file}=CB008064_B01.pcap       ${alias}=tcp_pcap
    @{TRACEID_UNDER_NSETAPX_START_RECORDING_SESSION}=        Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${NSETAPX_START_RECORDING_SESSION_MBA_CU} && ${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty    ${TRACEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    @{TRACEID}      Remove Duplicates       ${TRACEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    @{Expected_TraceId_list}        Create List         00:00:0${id}
    Lists Should Be Equal           ${TRACEID}          ${Expected_TraceId_list}

Verify traceId in Stop Recording for MBA CU
    [Arguments]             ${filter}=${TC1_TCE1_IP_PORT}       ${id}=1
    ...                     ${pcap_file}=CB008064_B01.pcap      ${alias}=tcp_pcap
    @{TRACEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}=        Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${NSETAPX_STOP_RECORDING_SESSION_MBA_CU} && ${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty    ${TRACEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    @{TRACEID}      Remove Duplicates       ${TRACEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    @{Expected_TraceId_list}        Create List         00:00:0${id}
    Lists Should Be Equal           ${TRACEID}          ${Expected_TraceId_list}

Verify traceId in MBA CU PCMD Reports
    [Arguments]             ${filter}=${TC1_TCE1_IP_PORT}        ${id}=1
    ...                     ${pcap_file}=CB008064_B01.pcap       ${alias}=tcp_pcap
    @{TRACEID_UNDER_CU_PCMD_REPORT}=         Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${NSETAPX_CU_PCMD_REPORT} && ${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file4.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty    ${TRACEID_UNDER_CU_PCMD_REPORT}
    @{TRACEID}      Remove Duplicates       ${TRACEID_UNDER_CU_PCMD_REPORT}
    @{Expected_TraceId_list}        Create List         00:00:0${id}
    Lists Should Be Equal           ${TRACEID}          ${Expected_TraceId_list}

Verify traceId in MBA CU Celltrace Reports
    [Arguments]             ${filter}=${TC1_TCE1_IP_PORT}        ${id}=1
    ...                     ${pcap_file}=CB008064_B01.pcap       ${alias}=tcp_pcap
    @{TRACEID_UNDER_CU_CELLTRACE_REPORT}=         Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${NSETAPX_CU_CELLTRACE_REPORT} && ${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file4.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty    ${TRACEID_UNDER_CU_CELLTRACE_REPORT}
    @{TRACEID}      Remove Duplicates       ${TRACEID_UNDER_CU_CELLTRACE_REPORT}
    @{Expected_TraceId_list}        Create List         00:00:0${id}
    Lists Should Be Equal           ${TRACEID}          ${Expected_TraceId_list}

Verify traceId in MBA CU PCMD and celltrace Reports
    [Arguments]             ${filter}=${TC1_TCE1_IP_PORT}        ${id}=1
    ...                     ${pcap_file}=CB008064_B01.pcap       ${alias}=tcp_pcap
    @{TRACEID_UNDER_CU_PCMD_AND_CELLTRACE_REPORT}=         Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${NSETAPX_CELLTRACE_REPORT} && ${NSETAPX_CU_PCMD_REPORT} && ${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file4.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty    ${TRACEID_UNDER_CU_PCMD_AND_CELLTRACE_REPORT}
    @{TRACEID}      Remove Duplicates       ${TRACEID_UNDER_CU_PCMD_AND_CELLTRACE_REPORT}
    @{Expected_TraceId_list}        Create List         00:00:0${id}
    Lists Should Be Equal           ${TRACEID}          ${Expected_TraceId_list}

Verify traceId in Start Recording for MBA CUUP
    [Arguments]             ${filter}=${TC1_TCE1_IP_PORT}        ${id}=1
    ...                     ${pcap_file}=CB008064_B01.pcap       ${alias}=tcp_pcap
    @{TRACEID_UNDER_NSETAPX_START_RECORDING_SESSION}=        Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${NSETAPX_START_RECORDING_SESSION_MBA_CUUP} && ${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty    ${TRACEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    @{TRACEID}      Remove Duplicates       ${TRACEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    @{Expected_TraceId_list}        Create List         00:00:0${id}
    Lists Should Be Equal           ${TRACEID}          ${Expected_TraceId_list}

Verify traceId in Stop Recording for MBA CUUP
    [Arguments]            ${filter}=${TC1_TCE1_IP_PORT}       ${id}=1
    ...                    ${pcap_file}=CB008064_B01.pcap      ${alias}=tcp_pcap
    @{TRACEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}=        Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${NSETAPX_STOP_RECORDING_SESSION_MBA_CUUP} && ${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty    ${TRACEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    @{TRACEID}      Remove Duplicates       ${TRACEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    @{Expected_TraceId_list}        Create List         00:00:0${id}
    Lists Should Be Equal           ${TRACEID}          ${Expected_TraceId_list}

Verify traceId in MBA CUUP PCMD Reports
    [Arguments]            ${filter}=${TC1_TCE1_IP_PORT}        ${id}=1
    ...                    ${pcap_file}=CB008064_B01.pcap       ${alias}=tcp_pcap
    @{TRACEID_UNDER_CUUP_PCMD_REPORT}=         Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${NSETAPX_CUUP_PCMD_REPORT} && ${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file4.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty    ${TRACEID_UNDER_CUUP_PCMD_REPORT}
    @{TRACEID}      Remove Duplicates       ${TRACEID_UNDER_CUUP_PCMD_REPORT}
    @{Expected_TraceId_list}        Create List         00:00:0${id}
    Lists Should Be Equal           ${TRACEID}          ${Expected_TraceId_list}

Verify traceId in MBA CUUP
    [Arguments]            ${filter}=${TCE1_IP_PORT}                   ${id}=1
    ...                    ${pcap_file}=CB008064_B01.pcap              ${alias}=tcp_pcap
    ${Sba_start_RANUEID}     Run Keyword And Ignore Error
    ...    verify RAN UE ID in nsetpx start recording session in MBA CUUP      ${filter}        ${pcap_file}      ${alias}
    ${Sba_stop_RANUEID}     Run Keyword And Ignore Error
    ...    verify RAN UE ID in nsetpx stop recording session in MBA CUUP       ${filter}        ${pcap_file}      ${alias}
    # Lists Should be Equal        ${Sba_start_RANUEID}        ${Sba_stop_RANUEID}
    verify No SBA Messages in moc                       ${filter}                   ${pcap_file}        ${alias}
    Verify traceId in Start Recording for MBA CUUP      ${filter}       ${id}       ${pcap_file}        ${alias}
    Verify traceId in Stop Recording for MBA CUUP       ${filter}       ${id}       ${pcap_file}        ${alias}
    Verify traceId in MBA CUUP PCMD Reports             ${filter}       ${id}       ${pcap_file}        ${alias}

verify RAN UE ID in nsetpx start recording session SBA CU
    [Arguments]             ${filter}=${SBA_TCE6_IP_PORT}
    ...                     ${pcap_file}=CB008064_B01.pcap        ${alias}=tcp_pcap
    @{RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}=       Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter} && ${NSETAPX_START_RECORDING_SESSION_SBA_CU}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    ${RANUE_ID_Start}       Remove Duplicates       ${RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    [Return]                ${RANUE_ID_Start}

verify RAN UE ID in nsetpx stop recording session SBA CU
    [Arguments]             ${filter}=${SBA_TCE6_IP_PORT}
    ...                     ${pcap_file}=CB008064_B01.pcap         ${alias}=tcp_pcap
    @{RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}=            Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter} && ${NSETAPX_STOP_RECORDING_SESSION_SBA_CU}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file2.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    ${RANUE_ID_Stop}        Remove Duplicates       ${RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    [Return]                ${RANUE_ID_Stop}

verify RAN UE ID in nsetpx start recording session in MBA CU
    [Arguments]             ${filter}=${TCE1_IP_PORT}
    ...                     ${pcap_file}=CB008064_B01.pcap        ${alias}=tcp_pcap
    @{RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}=       Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter} && ${NSETAPX_START_RECORDING_SESSION_MBA_CU}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    ${RANUE_ID_Start}       Remove Duplicates       ${RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    [Return]                ${RANUE_ID_Start}

verify RAN UE ID in nsetpx stop recording session in MBA CU
    [Arguments]             ${filter}=${TCE1_IP_PORT}
    ...                     ${pcap_file}=CB008064_B01.pcap         ${alias}=tcp_pcap
    @{RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}=            Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter} && ${NSETAPX_STOP_RECORDING_SESSION_MBA_CU}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file2.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    ${RANUE_ID_Stop}        Remove Duplicates       ${RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    [Return]                ${RANUE_ID_Stop}

verify RAN UE ID in nsetpx start recording session in MBA DU
    [Arguments]             ${filter}=${TCE1_IP_PORT}
    ...                     ${pcap_file}=CB008064_B01.pcap        ${alias}=tcp_pcap
    @{RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}=       Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter} && ${NSETAPX_START_RECORDING_SESSION_MBA_DU}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    ${RANUE_ID_Start}       Remove Duplicates       ${RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    [Return]                ${RANUE_ID_Start}

verify RAN UE ID in nsetpx stop recording session in MBA DU
    [Arguments]             ${filter}=${TCE1_IP_PORT}
    ...                     ${pcap_file}=CB008064_B01.pcap         ${alias}=tcp_pcap
    @{RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}=            Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter} && ${NSETAPX_START_RECORDING_SESSION_MBA_DU}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file2.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    ${RANUE_ID_Stop}        Remove Duplicates       ${RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    [Return]                ${RANUE_ID_Stop}

verify No MBA Messages in moc
    [Arguments]             ${filter}=${SBA_TCE6_IP_PORT}
    ...                     ${pcap_file}=eth3_tcp.pcap      ${alias}=tcp_pcap
    @{TRACEID_UNDER_MBA_MOC}=       Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${NSETAPX_MBA} && ${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Be Empty                ${TRACEID_UNDER_MBA_MOC}

verify No SBA Messages in moc
    [Arguments]             ${filter}=${TCE1_IP_PORT}
    ...                     ${pcap_file}=eth3_tcp.pcap      ${alias}=tcp_pcap
    @{TRACEID_UNDER_MBA_MOC}=       Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${NSETAPX_SBA} && ${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Be Empty                ${TRACEID_UNDER_MBA_MOC}

verify No Celltrace Report Messages in moc
    [Arguments]             ${filter}=${TCE1_IP_PORT}
    ...                     ${pcap_file}=eth3_tcp.pcap      ${alias}=tcp_pcap
    @{TRACEID_UNDER_MBA_MOC}=       Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${NSETAPX_CELLTRACE_REPORT} && ${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Be Empty                ${TRACEID_UNDER_MBA_MOC}

verify No PCMD Report Messages in moc
    [Arguments]             ${filter}=${TCE1_IP_PORT}
    ...                     ${pcap_file}=eth3_tcp.pcap      ${alias}=tcp_pcap
    @{TRACEID_UNDER_MBA_MOC}=           Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${NSETAPX_PCMD_REPORT} && ${filter}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.traceId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Be Empty                ${TRACEID_UNDER_MBA_MOC}

verify RAN UE ID in nsetpx start recording session in MBA CUUP
    [Arguments]             ${filter}=${TCE1_IP_PORT}
    ...                     ${pcap_file}=CB008064_B01.pcap        ${alias}=tcp_pcap
    @{RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}=       Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter} && ${NSETAPX_START_RECORDING_SESSION_MBA_CUUP}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file1.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    ${RANUE_ID_Start}       Remove Duplicates       ${RANUEID_UNDER_NSETAPX_START_RECORDING_SESSION}
    [Return]                ${RANUE_ID_Start}

verify RAN UE ID in nsetpx stop recording session in MBA CUUP
    [Arguments]             ${filter}=${TCE1_IP_PORT}
    ...                     ${pcap_file}=CB008064_B01.pcap         ${alias}=tcp_pcap
    @{RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}=            Get Attribute Values From Tshark Messages       alias=${alias}
    ...     filter=${filter} && ${NSETAPX_STOP_RECORDING_SESSION_MBA_CUUP}
    ...     output_pdml_filepath=/home/ute/log_cu_test/pdml_tmp_file2.pdml
    ...     element_xpath=.//field[@name="nsetapx.ranUeId"]
    ...     attribute_xpath=.
    ...     attribute=show
    ...     pcap_file_path=${Log_Path}/${pcap_file}
    Should Not Be Empty                ${RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    ${RANUE_ID_Stop}        Remove Duplicates       ${RANUEID_UNDER_NSETAPX_STOP_RECORDING_SESSION}
    [Return]                ${RANUE_ID_Stop}

