*** Settings ***
Documentation    LTE trace keywords
Library    taf.sw.dcap.rd

*** Variables ***
${tce_ipv4}    10.21.41.148
${tce_ipv6}    2a00:8a00:8000:10c:1:d:0:402
${tce_ip}    2a00:8a00:8000:10c:1:d:0:402
${lnbts_id}    5050
${tce_utf_user_name}    utfuser
${tce_utf_pwd}    utfadmin!
${tce_utf_ssh_user_name}    ute
${tce_utf_ssh_pwd}    Ut3pa5s#ff97

*** Keywords ***
Enable Tracing Falgs
    [Documentation]    Enable below flags:
    ...    actPCMDReport
    ...    actVendSpecCellTraceEnh
    ...    actCellTrace
    ...    actMDTCellTrace
    ...    actRemoteInterferenceReport
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     LNBTS_A
    Should Not Be Empty    ${objs}
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/LNBTS_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
    ...    ${dn}    actPCMDReport    update    true
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
    ...    ${dn}    actVendSpecCellTraceEnh    update    true
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
    ...    ${dn}    actCellTrace    update    true
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
    ...    ${dn}    actMDTCellTrace    update    true
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
    ...    ${dn}    actRemoteInterferenceReport    update    true
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
    ...    ${dn}    actUeBasedAnrInterFreqLte    update    true
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
    ...    ${dn}    actUeBasedAnrIntraFreqLte    update    true
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
    ...    ${dn}    actUeThroughputMeas    update    true

Get LNBTS ID
    [Documentation]    Short description.
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     LNBTS_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   LNBTS_A-(\\d+)    1
    Set Test Variable    ${lnbts_id}    ${match}[0]

Create CTRLTS
    [Arguments]
    ...    ${extCellTraceRep}=true    ${extUeTraceRep}=false    ${certTypeForTlsAuth}=RSA
    ...    ${tceTracePortNum}=49151    ${tceTlsEnabled}=false    ${maxUeTraceSessions}=60
    ...    ${subscriberMDTObtainLocation}=false    ${netActIpAddr}=127.0.0.1    ${omsTracePortNum}=49392
    ...    ${cellTraceRepMode}=Online    ${ueTraceRepMode}=Online    ${ueTraceInterfaceSelection}=NSNTI
    ...    ${taTracing}=false
    ${parameters}=    Create List
    ${para1_list}=    Create List
    ${para1_dic}=    Create Dictionary    extCellTraceRep=${extCellTraceRep}    extUeTraceRep=${extUeTraceRep}
    Append To List    ${para1_list}     ${para1_dic}
    ${para1}=    Create Dictionary
    ...    parameterName=extTraceReporting    operation=update    value=${para1_list}
    ${para2}=    Create Dictionary
    ...    parameterName=certTypeForTlsAuth    operation=update    value=${certTypeForTlsAuth}
    ${para3}=    Create Dictionary
    ...    parameterName=tceTracePortNum    operation=update    value=${tceTracePortNum}
    ${para4}=    Create Dictionary
    ...    parameterName=tceTlsEnabled    operation=update    value=${tceTlsEnabled}
    ${para5}=    Create Dictionary
    ...    parameterName=maxUeTraceSessions    operation=update    value=${maxUeTraceSessions}
    ${para6}=    Create Dictionary
    ...    parameterName=subscriberMDTObtainLocation    operation=update    value=${subscriberMDTObtainLocation}
    ${para7}=    Create Dictionary
    ...    parameterName=netActIpAddr    operation=update    value=${netActIpAddr}
    ${para8}=    Create Dictionary
    ...    parameterName=omsTracePortNum    operation=update    value=${omsTracePortNum}
    ${para9_dic}=    Create Dictionary    cellTraceRepMode=${cellTraceRepMode}    ueTraceRepMode=${ueTraceRepMode}
    ${para9_list}=    Create List
    Append To List    ${para9_list}     ${para9_dic}
    ${para9}=    Create Dictionary
    ...    parameterName=traceRepMode    operation=update    value=${para9_list}
    ${para10}=    Create Dictionary
    ...    parameterName=ueTraceInterfaceSelection    operation=update    value=${ueTraceInterfaceSelection}
    ${para11_dic}=    Create Dictionary    taTracing=${taTracing}
    ${para11_list}=    Create List
    Append To List    ${para11_list}     ${para11_dic}
    ${para11}=    Create Dictionary
    ...    parameterName=vendorSpecTracing    operation=update    value=${para11_list}
    Append To List    ${parameters}
    ...    ${para1}    ${para2}    ${para3}    ${para4}     ${para5}     ${para6}
    ...    ${para7}    ${para8}    ${para9}    ${para10}    ${para11}
    Log    ${parameters}
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     LNBTS_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/LNBTS_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    ${dn}=  Set Variable    ${dn}/CTRLTS-1
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${dn}    parameter=${parameters}    operation=create

Create MTRACE With Admin
    [Arguments]
    ...    ${tceCellTracePortNum}=49151    ${actPCMDReporting}=true    ${actUeThroughputMR}=true
    ...    ${cellMaxActiveUEsTraced}=100000    ${cellTrcMode}=true    ${cellTaTracing}=false
    ...    ${eutranTraceIdMcc}=262    ${eutranTraceIdMnc}=2    ${eutranTraceIdMncLen}=3
    ...    ${traceId}=65535    ${trcRecSessionRef}=65535
    ...    ${aoATracing}=true    ${pDSCHPRBNumberTracing}=true    ${pHRTracing}=true
    ...    ${pUSCHPRBNumberTracing}=true   ${ripTracing}=true    ${rirTracing}=true
    ...    ${tATracingSynch}=true    ${uEBSRTracing}=true    ${uERankTracing}=true
    ...    ${uLSINRTracing}=true    ${ripReportInterval}=5s    ${ripReportType}=subframe_slot
    ...    ${jobType}=ImmediateMDTAndTrace    ${maxBufferingTime}=2000    ${tceIpAddress}=${tce_ip}
    ...    ${cellMaxActiveMDTUEsTraced}=100   ${iFMDTPercentage}=0
    ...    ${immedMDTAnonymization}=NoIdentity    ${immedMDTForceUEConsent}=true
    ...    ${immedMDTObtainLocation}=false    ${immedMDTPosMethod}=None    ${immedMDTSelectOnlyGNSSUes}=false
    ...    ${traceRrcSetting}=All    ${traceS1Setting}=All    ${traceX2Setting}=All
    ...    ${reportAmount}=infinity    ${reportInterval}=5120ms
    ${parameters}=    Create List
    ${para1}=    Create Dictionary
    ...    parameterName=tceCellTracePortNum    operation=update    value=${tceCellTracePortNum}
    ${para2}=    Create Dictionary
    ...    parameterName=actPCMDReporting    operation=update    value=${actPCMDReporting}
    ${para3}=    Create Dictionary
    ...    parameterName=actUeThroughputMR    operation=update    value=${actUeThroughputMR}
    ${para4}=    Create Dictionary
    ...    parameterName=cellMaxActiveUEsTraced    operation=update    value=${cellMaxActiveUEsTraced}
    ${para5}=    Create Dictionary
    ...    parameterName=cellTrcMode    operation=update    value=${cellTrcMode}
    ${para6_dic}=    Create Dictionary    cellTaTracing=${cellTaTracing}
    ${para6_list}=    Create List
    Append To List    ${para6_list}     ${para6_dic}
    ${para6}=    Create Dictionary
    ...    parameterName=cellVendorSpecTracing    operation=update    value=${para6_list}
    ${para7_dic}=    Create Dictionary    eutranTraceIdMcc=${eutranTraceIdMcc}    eutranTraceIdMnc=${eutranTraceIdMnc}
    ...    eutranTraceIdMncLen=${eutranTraceIdMncLen}
    ...    traceId=${traceId}    trcRecSessionRef=${trcRecSessionRef}
    ${para7_list}=    Create List
    Append To List    ${para7_list}     ${para7_dic}
    ${para7}=    Create Dictionary
    ...    parameterName=eutranTraceId    operation=update    value=${para7_list}
    ${para8_dic}=    Create Dictionary    aoATracing=${aoATracing}    pDSCHPRBNumberTracing=${pDSCHPRBNumberTracing}
    ...    pHRTracing=${pHRTracing}    pUSCHPRBNumberTracing=${pUSCHPRBNumberTracing}    ripTracing=${ripTracing}
    ...    rirTracing=${rirTracing}    tATracingSynch=${tATracingSynch}    uEBSRTracing=${uEBSRTracing}
    ...    uERankTracing=${uERankTracing}    uLSINRTracing=${uLSINRTracing}    ripReportInterval=${ripReportInterval}
    ...    ripReportType=${ripReportType}
    ${para8_list}=    Create List
    Append To List    ${para8_list}     ${para8_dic}
    ${para8}=    Create Dictionary
    ...    parameterName=enhCellVendorSpecTracing    operation=update    value=${para8_list}
    ${para9}=    Create Dictionary
    ...    parameterName=jobType    operation=update    value=${jobType}
    ${para10}=    Create Dictionary
    ...    parameterName=maxBufferingTime    operation=update    value=${maxBufferingTime}
    ${para11}=    Create Dictionary
    ...    parameterName=tceIpAddress    operation=update    value=${tceIpAddress}
    ${para12}=    Create Dictionary
    ...    parameterName=traceRrcSetting    operation=update    value=${traceRrcSetting}
    ${para13}=    Create Dictionary
    ...    parameterName=traceS1Setting    operation=update    value=${traceS1Setting}
    ${para14}=    Create Dictionary
    ...    parameterName=traceX2Setting    operation=update    value=${traceX2Setting}
    ${para15_dic}=    Create Dictionary    cellMaxActiveMDTUEsTraced=${cellMaxActiveMDTUEsTraced}
    ...    iFMDTPercentage=${iFMDTPercentage}    immedMDTAnonymization=${immedMDTAnonymization}
    ...    immedMDTForceUEConsent=${immedMDTForceUEConsent}    immedMDTObtainLocation=${immedMDTObtainLocation}
    ...    immedMDTPosMethod=${immedMDTPosMethod}    immedMDTSelectOnlyGNSSUes=${immedMDTSelectOnlyGNSSUes}
    ${para15_list}=    Create List
    Append To List    ${para15_list}     ${para15_dic}
    ${para15}=    Create Dictionary
    ...    parameterName=immedMDTControl    operation=update    value=${para15_list}
    ${para16_dic}=    Create Dictionary    reportAmount=${reportAmount}    reportInterval=${reportInterval}
    ${para16_list}=    Create List
    Append To List    ${para16_list}     ${para16_dic}
    ${para16}=    Create Dictionary
    ...    parameterName=periodicUeMeas    operation=update    value=${para16_list}

    Append To List    ${parameters}
    ...    ${para1}    ${para2}    ${para3}    ${para4}     ${para5}     ${para6}    ${para7}    ${para8}
    ...    ${para9}    ${para10}    ${para11}    ${para12}    ${para13}    ${para14}    ${para15}    ${para16}
    Log    ${parameters}
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     CTRLTS_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/LNBTS_A-(\\d+)/CTRLTS_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    ${dn}=  Set Variable    ${dn}/MTRACE-1
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${dn}    parameter=${parameters}    operation=create

Delete CTRLTS
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     CTRLTS_A
    ${is_exist}=    Run Keyword And Return Status    Should Not Be Empty    ${objs}
    Return From Keyword If    ${is_exist}==${FALSE}
    ${parameters}=    Create List
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches
    ...    ${dist_name}   MRBTS_A-(\\d+)/LNBTS_A-(\\d+)/CTRLTS_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${dn}    parameter=${parameters}    operation=delete

Read Traced Content From UTF
    [Arguments]    ${bts_id}=5050    ${rat}=LTE
    taf.sw.dcap.rd.connect_to
    ...    host=${tce_ipv4}    port=443    username=${tce_utf_user_name}    password=${tce_utf_pwd}    secure=${TRUE}
    ${trace_files}=    Get Traced Log    bts_id=${bts_id}    rat=${rat}
    ${result}=    taf.sw.dcap.rd.upload_encoded_file    ${trace_files}
    Log     ${result}
    should Be True    '${result}[operation_status]'=='Success'
    ${msg_list}=    Create List
    FOR    ${source_id}    IN    @{result}[source_ids]
        CONTINUE FOR LOOP IF    ${source_id}<0
        ${decoded_content}=    taf.sw.dcap.rd.get_decoded_file_contents_in_json
        ...    ${result}[session_id]    ${source_id}
        Append to List    ${msg_list}    @{decoded_content}[emil_data][rows]
    END
    Log List    ${msg_list}
    [return]    ${msg_list}

Get Traced Log
    [Arguments]    ${count}=2    ${bts_id}=5050    ${rat}=LTE
    Should Be True    "${rat}"=="LTE" or "${rat}"=="NR"
    # ${tracer}=    Set Variable If    "${rat}"=="LTE"    ltetracer    ntracer5g
    ${command}=    Catenate    SEPARATOR=|
    ...    ls /sharedvolume/ntracer/_data/celltrace/*/*/*${bts_id}*
    ...    tail -${count}
    SSHLibrary.Open Connection    ${tce_ipv4}
    SSHLibrary.Login    ${tce_utf_ssh_user_name}   ${tce_utf_ssh_pwd}
    ${output}=    SSHLibrary.Execute Command    ${command}
    ${trace_files_tmp}=    Split String    ${output}    \n
    ${trace_files}=    Create List
    FOR    ${file}    IN    @{trace_files_tmp}
        SSHLibrary.Get File    ${file}    ${Test Results Dir}/
        ${local_name}=    Fetch From Right    ${file}    /
        Append To List  ${trace_files}    ${Test Results Dir}/${local_name}
    END
    SSHLibrary.Close Connection
    [return]    ${trace_files}

Get Message Name List
    [Arguments]    ${msg_list}
    ${message_name_list}=    Create List
    FOR    ${msg}    IN    @{msg_list}
        Append to List    ${message_name_list}    ${msg}[Message_name]
    END
    ${message_name_list}=    Remove Duplicates    ${message_name_list}
    Log List    ${message_name_list}
    [return]    ${message_name_list}

Get User Data List
    [Arguments]    ${msg_list}
    ${user_data_list}=    Create List
    FOR    ${msg}    IN    @{msg_list}
        ${headers}=    Get Dictionary Keys    ${msg}
        ${user_data_exist}=    Run Keyword And Return Status    Should Contain    ${headers}    User_data
        Run keyword If    ${user_data_exist}
        ...    Append to List    ${user_data_list}    ${msg}[User_data]
    END
    ${user_data_list}=    Remove Duplicates    ${user_data_list}
    Log List    ${user_data_list}
    [return]    ${user_data_list}

TCE IP version Check based On Mplane IP
    [Documentation]    TCE IP should be ipv6 if no ipv4 mplane address is configured
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     MPLANE_L
    Log    ${objs}[0][parameters][ipv4Addr]
    ${tce_ip}    Set Variable If    not '${objs}[0][parameters][ipv4Addr]'=='None'    ${tce_ipv4}    ${tce_ipv6}
    Set Test Variable    ${tce_ip}

Fake Setup
    [Documentation]    Short description.
    Set Test Variable    ${TESTLINE_NAME}    10_5_UTESRAN22259
    Set Test Variable   ${release}    SBTS25R3
    Set Test Variable   ${newBTSID}    22259
    taf.sbts.oam.coam.admin.connect to	bts_host=192.168.255.129
    Get LNBTS ID
    Import Variables    /home/ute/testline_configuration/${TESTLINE_NAME}/__init__.py
    Import Variables
        ...     /home/ute/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/T05/OAM_SRAN/Variables/${TESTLINE_NAME}.py

Get BTS ID
    [Documentation]    Short description.
    ${bts_info}=    taf.sbts.oam.coam.admin.get_bts_info
    Set Test Variable    ${nrbts_id}    ${bts_info}[nrBtsId]
    Set Test Variable    ${mrbts_id}    ${bts_info}[mrbtsID]
