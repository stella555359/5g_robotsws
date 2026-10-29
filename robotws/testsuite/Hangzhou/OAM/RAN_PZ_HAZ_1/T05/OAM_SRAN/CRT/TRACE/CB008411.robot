*** Settings ***
Documentation    CB008411 keywords
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/UeHandler.robot
Resource    ../SWM/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    LTE_TRACE.robot
Library     taf.sw.dcap.rd
Library     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/core_simulator.py

*** Variables ***
${UE}    Mate_30_Pro_5G
${tce_ipv4}    10.21.41.148
${tce_ipv6}    2a00:8a00:8000:10c:1:d:0:402
${tce_ip}    2a00:8a00:8000:10c:1:d:0:402
${tce_port}    49148
${mcc}    262
${mnc}    03
${imsi}    ${EMPTY}
${eutraCelId}    183123974
${AMF_IP_with_SBA}    10.110.115.149
${tceIdentifier}    1
${core_simulator_IP}    10.97.92.238
${core_simulator_username}    ute
${core_simulator_password}    UTE.debian12
${core_simulator_home_dir}    /opt/iphy/WTS/
${core_simulator_cfg}    WTS_SA.cfg

*** Keywords ***
Activation of the Subscriber Trace with PCMD content related to CB008411
    [Documentation]    Short description.
    Enable Feature Flags for CB008411
    Create NRSTRACECU
    Start IP Traffic Capturing From Admin
#    core_simulator.reinit_simulator
#    Add Core Simulator As AMF And Lock Other AMFs    ${core_simulator_IP}
#    Activation of Subscriber Trace From Core Simulator
    Make A Call
    ${file}=    Download IP Traffic Capturing File From Admin
    Verify Traca Activation On 5G Core    ${file}
    Collect And Verify Trace Data From DCAP For CUCP

Activation of the Subscriber Trace with PCMD content related to CB008411 AP
    Enable Feature Flags for CB008411
    Create NRSTRACECU
    Start IP Traffic Capturing From Admin
    Make A Call with AP
    Download IP Traffic Capturing File From Admin
    Verify Trace Data From UTF For CUCP New

CB008411-B B01 PCMD Records from gNB-CU-UP in SBA Session for a UE
    [Documentation]    Short description.
    Enable Feature Flags for CB008411
    Create NRSTRACECUUP
    Start IP Traffic Capturing From Admin
    core_simulator.reinit_simulator
    Add Core Simulator As AMF And Lock Other AMFs    ${core_simulator_IP}
    Activation of Subscriber Trace From Core Simulator
    Make A Call
    Download IP Traffic Capturing File From Admin
    Collect And Verify Trace Data From DCAP For CUUP

CB008411-B B01 PCMD Records from gNB-CU-UP in SBA Session for a UE AP
    Enable Feature Flags for CB008411
    Create NRSTRACECUUP
    Start IP Traffic Capturing From Admin
    core_simulator.init_simulator    reset=${TRUE}
    Add Core Simulator As AMF And Lock Other AMFs    ${core_simulator_IP}
    Make A Call with AP
    Download IP Traffic Capturing File From Admin
    Verify Trace Data From UTF For CUUP New

Verify Traca Activation On 5G Core
    [arguments]    ${file}
    ${output}=    Run    tshark -r "${file}" -Y 'ngap.id == 108' -T pdml
    Log    ${output}
    Should Contain    ${output}    TraceActivation

Make A Call
    [Documentation]    Short description.
    Attach UE And Start ICMP Ping		UE_alias=${UE}		required_ue=${UE}   ping_count=999
    Sleep    60s
    Detach UE And Stop Traffic      ${UE}

Adding Target TCE To Configuration
    [Documentation]    Short description.
    ${is_tce_configured}=    Is Target TCE Configured    ${tce_ip}
    Return From Keyword If    ${is_tce_configured}
    ${tceId}    ${tceIdentifier}=    Generate tceId and tceIdentifier
    Set Test Variable     ${tceId}
    Set Test Variable     ${tceIdentifier}
    Create TCE    ${tceId}    ${tceIdentifier}    ${tce_ip}

Create TCE
    [arguments]    ${tceId}    ${tceIdentifier}    ${tce_ip}
    Create TCEADM
    ${parameters}=    Create List
    ${pra1}=    Create Dictionary
    ...    parameterName=certTypeForTlsAuth    operation=update    value=RSA
    ${pra2}=    Create Dictionary
    ...    parameterName=tlsEnabled    operation=update    value=false
    ${pra3}=    Create Dictionary
    ...    parameterName=tceIdentifier    operation=update    value=${tceIdentifier}
    ${pra4}=    Create Dictionary
    ...    parameterName=tceIpAddress    operation=update    value=${tce_ip}
    ${pra5}=    Create Dictionary
    ...    parameterName=tcePortNumber    operation=update    value=${tce_port}
    Append To List    ${parameters}    ${pra1}    ${pra2}    ${pra3}    ${pra4}    ${pra5}
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     TCEADM_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/MNL_A-(\\d+)/TCEADM_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    ${dn}=  Set Variable    ${dn}/TCE-${tceId}
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${dn}    parameter=${parameters}    operation=create

Create TCEADM
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     TCEADM_A
    ${TCEADM_exist}=    Run Keyword and return status    Should not be empty    ${objs}
    Return from keyword If    ${TCEADM_exist}
    ${parameters}=    Create List
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     MNL_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/MNL_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    ${dn}=  Set Variable    ${dn}/TCEADM-1
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${dn}    parameter=${parameters}    operation=create

Is Target TCE Configured
    [Documentation]    Short description.
    [arguments]    ${tce_ip}
    ${is_tce_configured}=    Set Variable    ${FALSE}
    ${dist_name}=    Set Variable    ${EMPTY}
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     TCE_A
    FOR    ${obj}    IN    @{objs}
        ${is_tce_configured}=    Set Variable If
        ...    '${obj}[parameters][tceIpAddress]'=='${tce_ip}'    ${TRUE}    ${is_tce_configured}
        ${tceIdentifier}=    Set Variable If
        ...    '${obj}[parameters][tceIpAddress]'=='${tce_ip}'    ${obj}[parameters][tceIdentifier]    ${tceIdentifier}
        Set Test Variable     ${tceIdentifier}
        Exit For Loop If    ${is_tce_configured}
    END
    [return]    ${is_tce_configured}

Generate tceId and tceIdentifier
    [Documentation]    Short description.
    ${tceId}=    set variable    1
    ${tceIdentifier}=    set variable    0
    ${tceIds}=    Create List
    ${tceIdentifiers}=    Create List
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     TCE_A
    FOR    ${obj}    IN    @{objs}
        ${dist_name}=    Set Variable    ${obj}[distName]
        ${match}=    Get Regexp Matches    ${dist_name}   TCE_A-(\\d+)    1
        ${tce_id}=    Set Variable    ${match}[0]
        Append To List    ${tceIds}    ${${tce_id}}
        Append To List    ${tceIdentifiers}    ${obj}[parameters][tceIdentifier]
    END
    Log    ${tceIds}
    Log    ${tceIdentifiers}
    FOR    ${id}    IN RANGE    1    11
        ${tceid_not_included}=    Run Keyword And Return Status    Should Not Contain    ${tceIds}    ${id}
        ${tceId}    Set Variable If    ${tceid_not_included}    ${id}    ${tceId}
        Exit For Loop If    ${tceid_not_included}
        Run Keyword If    ${id}>=10 and ${tceid_not_included}
        ...    Fail    No suiteable tceId allowed
    END
    FOR    ${id}    IN RANGE    0    256
        ${tceIdentifier_not_included}=    Run Keyword And Return Status
        ...    Should Not Contain    ${tceIdentifiers}    ${id}
        ${tceIdentifier}    Set Variable If    ${tceIdentifier_not_included}    ${id}    ${tceIdentifier}
        Exit For Loop If    ${tceIdentifier_not_included}
        Run Keyword If    ${id}>=255 and ${tceIdentifier_not_included}
        ...    Fail    No suiteable tceIdentifier allowed
    END
    [return]    ${tceId}    ${tceIdentifier}

CB008411 setup
    [Documentation]    Short description.
    TC Setup
    SW update to Target Build
    Get BTS ID
    Update actPCMDReport and actSubscriberTraceReport    actPCMDReport=false    actSubscriberTraceReport=false
    TCE IP version Check based On Mplane IP
    Run Keyword and ignore error    taf.sbts.oam.coam.admin.block_rat    LTE
    Add AMF with SBA Trace And Lock Other AMFs    ${AMF_IP_with_SBA}
    Adding Target TCE To Configuration
    Set Up UE       ${UE}
    Run Keyword And Ignore Error    change_network_mode    ${UE}    NR_only

CB008411 fake setup
    Set Test Variable    ${TESTLINE_NAME}    10_5_UTESRAN22259
    Set Test Variable   ${release}    SBTS26R1
    taf.sbts.oam.coam.admin.connect to	bts_host=192.168.255.129
    Import Variables    /home/ute/testline_configuration/${TESTLINE_NAME}/__init__.py
    Import Variables
        ...     /home/ute/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/T05/OAM_SRAN/Variables/${TESTLINE_NAME}.py
    Adding Target TCE To Configuration
#    core_simulator.connect_to
#    ...    host_ip=${core_simulator_IP}
#    ...    username=${core_simulator_username}
#    ...    password=${core_simulator_password}
#    ...    home_directory=${core_simulator_home_dir}
#    ...    cfg_file=${core_simulator_cfg}
#    Add Core Simulator As AMF And Lock Other AMFs    ${core_simulator_IP}
#    taf.sbts.oam.coam.admin.block_rat    LTE
#    Set Up UE       ${UE}
#    core_simulator.reinit_simulator
#    Add Core Simulator As AMF And Lock Other AMFs    ${core_simulator_IP}
#    make a call
#    core_simulator.reinit_simulator
#    Add Core Simulator As AMF And Lock Other AMFs    ${core_simulator_IP}
#    make a call
#    core_simulator.reinit_simulator
#    Add Core Simulator As AMF And Lock Other AMFs    ${core_simulator_IP}
#    make a call

CB008411 setup For AP
    [Documentation]    setup for airephone
    Log    ${TESTLINE_NAME}
    Set Test Variable    ${tce_ipv4}    10.0.1.1
    Set Test Variable    ${tce_ip}    ${tce_ipv4}
    Import Library    ${CURDIR}/../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/airphone.py
    Create Dirs For Logs
    Deploy DCAP on UTE
    airphone.init_simulator
    Start Admin
    Get Running Version
    Get BTS ID
    Wait Until Keyword Succeeds  5 min  15 sec    NG Link Is Active
    Update actPCMDReport and actSubscriberTraceReport    actPCMDReport=false    actSubscriberTraceReport=false

Deploy DCAP on UTE
	${utf_deployed}=    run keyword and return status  taf.sw.dcap.rd.connect_to
	...    host=${tce_ip}    port=9443    secure=${TRUE}
	Return From Keyword If    ${utf_deployed}
    File Should Exist    /home/ute/utf_lab_installer.sh
    ${output}=    Run    sudo UTE_CLOUD=1 EMIL_JSON_SERVER=1 bash /home/ute/utf_lab_installer.sh ${tce_ip}
    log    ${output}
    taf.sw.dcap.rd.connect_to    host=${tce_ip}    port=9443    secure=${TRUE}

Make A Call with AP
    ${cmd}=    Catenate    amf_ue_ics_param id=1 ue=1 object_id=1 location_reporting_reference_id=1 trace_activation=on
    ...    trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1 trace_depth=maximum
    ...    ifaces_to_trace=NG-C,Xn-C,Uu,E1,F1-C tce_ip=${tce_ipv4}
    ${output}=    airphone.execute_command    ${cmd}
    Log    ${output}
    Should Not Contain    ${output}    error    ignore_case=True

    ${cmd}=    set variable    ue_register id=1
    ${output}=    airphone.execute_command    ${cmd}
    Log    ${output}

    ${cmd}=    set variable    ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    ${output}=    airphone.execute_command    ${cmd}
    Log    ${output}

    ${cmd}=    set variable    trf_data_start ue=1 pdu=1 qfi=1 dir=dl trf_id=1 protocol=udp mbps=10
    ${output}=    airphone.execute_command    ${cmd}
    Log    ${output}

    ${cmd}=    set variable    trf_data_start ue=1 pdu=1 qfi=1 dir=ul trf_id=2 protocol=udp mbps=10
    ${output}=    airphone.execute_command    ${cmd}
    Log    ${output}

    Log    ${output}
    Sleep    30s

    ${cmd}=    set variable    trf_data_stop ue=1 pdu=1 qfi=1 dir=dl
    ${output}=    airphone.execute_command    ${cmd}
    Log    ${output}

    ${cmd}=    set variable    trf_data_stop ue=1 pdu=1 qfi=1 dir=ul
    ${output}=    airphone.execute_command    ${cmd}
    Log    ${output}

    ${cmd}=    set variable    ue_pdu_session_release ue=1 pdu=1
    ${output}=    airphone.execute_command    ${cmd}
    Log    ${output}

    ${cmd}=    set variable    ue_deregister id=1 ue_deregister_type=switch_off by=ue
    ${output}=    airphone.execute_command    ${cmd}
    Log    ${output}

#TCE IP version Check based On Mplane IP
#    [Documentation]    TCE IP should be ipv6 if no ipv4 mplane address is configured
#    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     MPLANE_L
#    Log    ${objs}[0][parameters][ipv4Addr]
#    ${tce_ip}    Set Variable If    not '${objs}[0][parameters][ipv4Addr]'=='None'    ${tce_ipv4}    ${tce_ipv6}

Unlock NG Links And Lock NG Link For Core Simulator
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${core_simulator_IP}: <description>
    [arguments]    ${core_simulator_IP}
    taf.sbts.oam.coam.admin.unlock_ng_link    ${EMPTY}
    ${is_serving_amf}    ${administrativeState}    ${dist_name}    Is AMF In Serving    ${core_simulator_IP}
    Run Keyword If    ${is_serving_amf} and '${administrativeState}'=='Locked'
    ...    taf.sbts.oam.coam.admin.lock_ng_link    ${dist_name}
    Wait Until Keyword Succeeds  5 min  15 sec    NG Link Is Active

Add Core Simulator As AMF And Lock Other AMFs
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${core_simulator_IP}: <description>
    [arguments]    ${core_simulator_IP}
    taf.sbts.oam.coam.admin.lock_ng_link    ${EMPTY}
    ${is_serving_amf}    ${administrativeState}    ${dist_name}    Is AMF In Serving    ${core_simulator_IP}
    Run Keyword If    ${is_serving_amf} and '${administrativeState}'=='Locked'
    ...    taf.sbts.oam.coam.admin.unlock_ng_link    ${dist_name}
    Run Keyword If    not ${is_serving_amf}    Add New AMF    ${core_simulator_IP}
#    Lock All AMFs Exclude Core Simulator    ${core_simulator_IP}
    Wait Until Keyword Succeeds  5 min  15 sec    NG Link Is Active

Add AMF with SBA Trace And Lock Other AMFs
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${AMF_IP}: <description>
    [arguments]    ${AMF_IP}
    taf.sbts.oam.coam.admin.lock_ng_link    ${EMPTY}
    ${is_serving_amf}    ${administrativeState}    ${dist_name}    Is AMF In Serving    ${AMF_IP}
    Run Keyword If    ${is_serving_amf} and '${administrativeState}'=='Locked'
    ...    taf.sbts.oam.coam.admin.unlock_ng_link    ${dist_name}
    Run Keyword If    not ${is_serving_amf}    Add New AMF    ${AMF_IP}
    Wait Until Keyword Succeeds  5 min  15 sec    NG Link Is Active

NG Link Is Active
    [Documentation]    Short description.
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     SERVEDAMF_L
    ${is_active}=    Set Variable    ${FALSE}
    FOR    ${obj}    IN    @{objs}
        ${is_active}=    Set Variable If    '${obj}[parameters][ngLinkStatus]'=='Active'    ${TRUE}    ${FALSE}
        Exit For Loop If    ${is_active}
    END
    Should Be True    ${is_active}

Add New AMF
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${amf_IP}: <description>
    [arguments]    ${amf_IP}
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     SERVEDAMF_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/NRBTS_A-(\\d+)/SERVEDAMF_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dn}   amfIPAddress   update  ${amf_IP}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dn}   administrativeState   update  Unlocked

Lock All AMFs Exclude Core Simulator
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${exclued_amf_IP}: <description>
    [arguments]    ${exclued_amf_IP}
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     SERVEDAMF_A
    FOR    ${obj}    IN    @{objs}
        Continue For Loop If    '${obj}[parameters][amfIPAddress]'=='${exclued_amf_IP}'
        Continue For Loop If    '${obj}[parameters][administrativeState]'=='Locked'
        ${dn}=     Set Variable            ${obj}[distName]
        ${match}=    Get Regexp Matches    ${dn}   MRBTS_A-(\\d+)/NRBTS_A-(\\d+)/SERVEDAMF_A-(\\d+)
        ${dist_name}=  replace string  ${match}[0]    _A  ${EMPTY}
        taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dist_name}   administrativeState   update  Locked
    END

Is AMF In Serving
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${amf_IP}: <description>
    ...
    ...    Returns:
    ...        ${is_serving_amf}: <description>
    ...        ${administrativeState}: <description>
    ...        ${dist_name}: <description>
    [arguments]    ${amf_IP}
    ${is_serving_amf}=    Set Variable    ${FALSE}
    ${administrativeState}=    Set Variable    locked
    ${dist_name}=    Set Variable    ${EMPTY}
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     SERVEDAMF_A
    FOR    ${obj}    IN    @{objs}
        ${is_serving_amf}=    Set Variable If
        ...    '${obj}[parameters][amfIPAddress]'=='${amf_IP}'    ${TRUE}    ${is_serving_amf}
        ${administrativeState}    Set Variable If    ${is_serving_amf}    ${obj}[parameters][administrativeState]
        ${dn}=     Set Variable            ${obj}[distName]
        ${match}=    Get Regexp Matches    ${dn}   MRBTS_A-(\\d+)/NRBTS_A-(\\d+)/SERVEDAMF_A-(\\d+)
        ${dist_name}=  replace string  ${match}[0]    _A  ${EMPTY}
        Exit For Loop If    ${is_serving_amf}
    END
    [return]    ${is_serving_amf}    ${administrativeState}    ${dist_name}

Fake Setup
    [Documentation]    Short description.
    Set Test Variable    ${TESTLINE_NAME}    10_5_UTESRAN22259
    Set Test Variable   ${release}    SBTS24R3
    Set Test Variable   ${newBTSID}    22259
    taf.sbts.oam.coam.admin.connect to	bts_host=192.168.255.129
    Import Variables    /home/ute/testline_configuration/${TESTLINE_NAME}/__init__.py
    Import Variables
        ...     /home/ute/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ12/OAM_SRAN/Variables/${TESTLINE_NAME}.py

Start IP Traffic Capturing
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.start_ip_capture_file    measurement_point=${measurement_point}
    ...     uplane_capturing=${FALSE}    password=${EMPTY}

TCE check
    [Documentation]    Short description.
    Log    TDB

Enable Feature Flags for CB008411
    [Documentation]    Short description.
    Update actPCMDReport and actSubscriberTraceReport

Update actPCMDReport and actSubscriberTraceReport
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${actPCMDReport}: <description>
    ...        ${actSubscriberTraceReport}: <description>
    [arguments]    ${actPCMDReport}=true    ${actSubscriberTraceReport}=true
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NRBTS_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/NRBTS_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    ${parameters}=    Create List
    ${pra1}=    Create Dictionary
    ...    parameterName=actPCMDReport    operation=update    value=${actPCMDReport}
    ${pra2}=    Create Dictionary     parameterName=actSubscriberTraceReport    operation=update
    ...    value=${actSubscriberTraceReport}
    Append To List    ${parameters}    ${pra1}    ${pra2}
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${dn}    parameter=${parameters}    operation=update

Create NRSTRACECUUP
    [Documentation]    Short description.
    Delete NRCTRLTSCUUP
    Create NRCTRLTSCUUP
    ${parameters}=    Create List
    ${pra1}=    Create Dictionary
    ...    parameterName=actPCMDReporting    operation=update    value=true
    ${pra2}=    Create Dictionary
    ...    parameterName=applyDefNrTceForAllSessions    operation=update    value=true
    ${pra3}=    Create Dictionary
    ...    parameterName=certTypeForTlsAuth    operation=update    value=RSA
    ${pra4}=    Create Dictionary
    ...    parameterName=maxBufferingTime    operation=update    value=2000
    ${pra5}=    Create Dictionary
    ...    parameterName=nrTcePortNumber    operation=update    value=${tce_port}
    ${pra6}=    Create Dictionary
    ...    parameterName=tlsEnabled    operation=update    value=false
    ${tracePCMDSetting}=    Create List    all
    ${pra7}=    Create Dictionary
    ...    parameterName=tracePCMDSetting    operation=update    value=${tracePCMDSetting}
    Append To List    ${parameters}    ${pra1}    ${pra2}    ${pra3}    ${pra4}    ${pra5}    ${pra6}    ${pra7}
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NRCTRLTSCUUP_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}
    ...    MRBTS_A-(\\d+)/NRBTS_A-(\\d+)/NRCUUP_A-(\\d+)/NRCTRLTSCUUP_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    ${dn}=  Set Variable    ${dn}/NRSTRACECUUP-1
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${dn}    parameter=${parameters}    operation=create

Delete NRCTRLTSCUUP
    [Documentation]    Short description.
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NRSTRACECUUP_A
    ${is_exist}=    Run Keyword And Return Status    Should Not Be Empty    ${objs}
    Return From Keyword If    ${is_exist}==${FALSE}
    ${parameters}=    Create List
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches
    ...    ${dist_name}   MRBTS_A-(\\d+)/NRBTS_A-(\\d+)/NRCUUP_A-(\\d+)/NRCTRLTSCUUP_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${dn}    parameter=${parameters}    operation=delete

Create NRSTRACECU
    [Documentation]    Short description.
    Create NRCTRLTS
    Delete NRSTRACECU
    ${parameters}=    Create List
    ${pra1}=    Create Dictionary
    ...    parameterName=actPCMDReporting    operation=update    value=true
    ${pra2}=    Create Dictionary
    ...    parameterName=applyDefNrTceForAllSessions    operation=update    value=true
    ${pra3}=    Create Dictionary
    ...    parameterName=certTypeForTlsAuth    operation=update    value=RSA
    ${pra4}=    Create Dictionary
    ...    parameterName=maxBufferingTime    operation=update    value=2000
    ${pra5}=    Create Dictionary
    ...    parameterName=nrTcePortNumber    operation=update    value=${tce_port}
    ${pra6}=    Create Dictionary
    ...    parameterName=tlsEnabled    operation=update    value=false
    ${tracePCMDSetting}=    Create List    all
    ${pra7}=    Create Dictionary
    ...    parameterName=tracePCMDSetting    operation=update    value=${tracePCMDSetting}
    ${para8}=   Create Dictionary
    ...    parameterName=defaultNrTceIdentifier    operation=update    value=${tceIdentifier}
    Append To List    ${parameters}    ${pra1}    ${pra2}    ${pra3}    ${pra4}    ${pra5}
    ...    ${pra6}    ${pra7}    ${para8}
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NRCTRLTS_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/NRBTS_A-(\\d+)/NRCTRLTS_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    ${dn}=  Set Variable    ${dn}/NRSTRACECU-1
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${dn}    parameter=${parameters}    operation=create

Create NRCTRLTS
    [Documentation]    Short description.
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NRCTRLTS_A
    ${is_exist}=    Run Keyword And Return Status    Should Not Be Empty    ${objs}
    Return From Keyword If    ${is_exist}
    ${parameters}=    Create List
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NRBTS_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/NRBTS_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    ${dn}=  Set Variable    ${dn}/NRCTRLTS-1
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${dn}    parameter=${parameters}    operation=create

Create NRCTRLTSCUUP
    [Documentation]    Short description.
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NRCTRLTSCUUP_A
    ${is_exist}=    Run Keyword And Return Status    Should Not Be Empty    ${objs}
    Return From Keyword If    ${is_exist}
    ${parameters}=    Create List
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NRCUUP_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/NRBTS_A-(\\d+)/NRCUUP_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    ${dn}=  Set Variable    ${dn}/NRCTRLTSCUUP-1
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${dn}    parameter=${parameters}    operation=create

Delete NRSTRACECU
    [Documentation]    Short description.
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NRSTRACECU_A
    ${is_exist}=    Run Keyword And Return Status    Should Not Be Empty    ${objs}
    Return From Keyword If    ${is_exist}==${FALSE}
    ${parameters}=    Create List
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches
    ...    ${dist_name}   MRBTS_A-(\\d+)/NRBTS_A-(\\d+)/NRCTRLTS_A-(\\d+)/NRSTRACECU_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    dist_name=${dn}    parameter=${parameters}    operation=delete

Activation of Subscriber Trace From Core Simulator
    [Documentation]    Short description.
    ${result}=    Activation of Subscriber Trace of Single UE By IMSI    ${imsi}
    Return From Keyword If    ${result}
    Log To Console    .
    Log To Console    IMSI unknown, activate SBA trace for all configured UEs
    ${ue_ids}    ${imsis}=    core_simulator.get_configured_ues
    FOR    ${id}    IN    @{ue_ids}
        Activate Subscriber Trace of Single UE    ${id}    ${id}
    END

Activation of Subscriber Trace of Single UE By IMSI
    [arguments]    ${imsi}
    ${ue_ids}    ${imsis}=    core_simulator.get_configured_ues
    ${index}=    Get Index From List    ${imsis}    ${imsi}
    Log    ${imsis}
    Log    ${imsi}
    Run keyword If    '${index}'!='-1'
    ...    Activate Subscriber Trace of Single UE    ${ue_ids}[${index}]    ${ue_ids}[${index}]
    Return From Keyword If    '${index}'!='-1'
    ${result}=    Set Variable If    '${index}'=='-1'    ${FALSE}    ${TRUE}
    [return]    ${result}

Activate Subscriber Trace of Single UE
    [arguments]    ${ue_id}=1    ${trace_ref_id}=1    ${mcc}=262    ${mnc}=03
    ${cmd}    Catenate    amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1
    ...    trace_activation=on trace_plmn=${mcc}:${mnc} trace_ref_id=${trace_ref_id} trace_rec_session_ref_id=8
    ...    trace_depth=maximum ifaces_to_trace=NG-C,Xn-C,Uu,E1,F1-C tce_ip=${tce_ip}
    ${output}=    core_simulator.execute_command    ${cmd}
    Should Not Contain    ${output}    error    ignore_case=True
    Log    ${output}
    ${cmd}=    Set Variable    amf_ue_ics_param id=1 ue=${ue_id}
    ${output}=    core_simulator.execute_command    ${cmd}
    Should Not Contain    ${output}    error    ignore_case=True
    Should Match Regexp    ${output}    trace_activation\\s+on
    Should Match Regexp    ${output}    tce_ip\\s+${tce_ip}

Activation of Subscriber Trace From AP
    ${cmd}    Catenate    amf_ue_ics_param id=1 ue=1 object_id=1 location_reporting_reference_id=1 trace_activation=on
    ...    trace_plmn=${mcc}:${mnc} trace_ref_id=1 trace_rec_session_ref_id=8 trace_depth=maximum
    ...    ifaces_to_trace=NG-C,Xn-C,Uu,E1,F1-C tce_ip=${tce_ip}
    ${output}=    airphone.execute_command    ${cmd}
    Should Not Contain    ${output}    error    ignore_case=True
    Log    ${output}
    Length Should Be    ${output}    10

Start IP Traffic Capturing From Admin
    [Documentation]    Short description.
    ${is_capturing_ongoing}=    Is IP Traffic Capturing Ongoing
    Run Keyword If    ${is_capturing_ongoing}    taf.sbts.oam.coam.admin.Stop IP Capture File
    taf.sbts.oam.coam.admin.start_ip_capture_file    measurement_point=NE_Terminated
    ...     uplane_capturing=${TRUE}    password=${EMPTY}

Is IP Traffic Capturing Ongoing
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${fault_61641_is_active}: <description>
    ${alarms}=    taf.sbts.oam.coam.admin.get_managed_objects     ALARM
    ${fault_61641_is_active}=    Set Variable    ${FALSE}
    FOR    ${alarm}    IN    @{alarms}
        ${fault_61641_is_active}=    Set Variable If    '${alarm}[parameters][faultId]'=='61641'    ${TRUE}    ${FALSE}
        Exit For Loop If    ${fault_61641_is_active}
    END
    [return]    ${fault_61641_is_active}

Download IP Traffic Capturing File From Admin
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Stop IP Capture File
    taf.sbts.oam.coam.admin.Generate IP Capture File
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${target_file_name}=    Set Variable    ${Test Results Dir}${/}IP_Traffic_MRBTS-${mrbts_id}_${timestamp}.pcap.gz
    taf.sbts.oam.coam.admin.Download IP Capture File    target_file_name=${target_file_name}
    [return]    ${target_file_name}

Collect And Verify Trace Data From DCAP For CUCP
    [Documentation]    Short description.
    ${msg_list}=    Read Traced Content From UTF    ${nrbts_id}    NR
    Log List    ${msg_list}
    ${msg_name_list}=    Get Message Name List    ${msg_list}
    Log List    ${msg_name_list}
    ${user_data_list}=    Get User Data List    ${msg_list}
    Log List    ${user_data_list}
    Should Contain Match    ${user_data_list}    *UeDuConnectivityTraceRecord
    Should Contain Match    ${user_data_list}    *CuRrcSetupTraceRecord

PCMD message Verification
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${message_list}: <description>
    ...        ${expected_message_name}: <description>
    [arguments]    ${message_list}    ${expected_message_name}
    ${msg_exist}=    Set Variable    ${FALSE}
    FOR    ${msg}    IN    @{message_list}
        ${msg_exist}=    Set Variable If    '${msg}[Message name]'=='${expected_message_name}'    ${TRUE}
        Exit For Loop If    ${msg_exist}
    END
    Should Be True    ${msg_exist}

PCMD message Verification New
    [arguments]    ${message_list}    ${expected_message_name}
    ${msg_exist}=    Set Variable    ${FALSE}
    FOR    ${msg}    IN    @{message_list}
        Log    ${msg}
        ${msg_exist}=    Run Keyword And Return Status
        ...    Should Contain    ${msg}[User_data]    ${expected_message_name}
#        ${msg_exist}=    Set Variable If    '${msg}[User_data]'=='${expected_message_name}'    ${TRUE}
        Exit For Loop If    ${msg_exist}
    END
    Should Be True    ${msg_exist}

Collect And Verify Trace Data From DCAP For CUUP
    [Documentation]    Short description.
    ${msg_list}=    Read Traced Content From UTF    ${nrbts_id}    NR
    Log List    ${msg_list}
    ${msg_name_list}=    Get Message Name List    ${msg_list}
    Log List    ${msg_name_list}
    ${user_data_list}=    Get User Data List    ${msg_list}
    Log List    ${user_data_list}
    Should Contain Match    ${user_data_list}    *UeCuUpConnectivityTraceRecord
    Should Contain Match    ${user_data_list}    *CuUpDlRadioBearerPdcpMeasTraceRecord
    Should Contain Match    ${user_data_list}    *CuUpUlRadioBearerPdcpMeasTraceRecord

Verify Trace Data From UTF For CUUP New
    ${msg_list}=    Get Traced Content From UTF
    PCMD message Verification New    ${msg_list}    UeCuUpConnectivityTraceRecord
    PCMD message Verification New    ${msg_list}    CuUpDlRadioBearerPdcpMeasTraceRecord
    PCMD message Verification New    ${msg_list}    CuUpUlRadioBearerPdcpMeasTraceRecord

Get Traced Content From UTF
    ${output}=    Run    cp -r /sharedvolume/ntracer5g/_data/celltrace/ ${Test Results Dir}${/}
    ${output}=    Run    ls /sharedvolume/ntracer5g/_data/celltrace/*/*/*
    ${trace_files}=    Split String    ${output}    \n
    ${result}=    taf.sw.dcap.rd.upload_encoded_file    ${trace_files}
    Log     ${result}
    should Be True    '${result}[operation_status]'=='Success'
    ${decoded_content}=    taf.sw.dcap.rd.get_decoded_file_contents_in_json    ${result}[session_id]
    ...    ${result}[source_ids][0]
    ${msg_list}=    Set Variable    ${decoded_content}[emil_data][rows]
    [return]    ${msg_list}

Verify Trace Data From UTF For CUCP New
    ${msg_list}=    Get Traced Content From UTF
    PCMD message Verification New    ${msg_list}    UeDuConnectivityTraceRecord
    PCMD message Verification New    ${msg_list}    CuRrcSetupTraceRecord

Clear traced loges
    Run    rm /sharedvolume/ntracer5g/_data/celltrace/*/* -rf

CB008411 teardown
    [Documentation]    Short description.
    Run keyword and ignore error    taf.sbts.oam.coam.admin.unblock_rat    LTE
    ${is_capturing_ongoing}=    Is IP Traffic Capturing Ongoing
    run keyword if    ${is_capturing_ongoing}    taf.sbts.oam.coam.admin.Stop IP Capture File
    Common Test Teardown

CB008411 teardown For AP
    Clear traced loges
    ${is_capturing_ongoing}=    Is IP Traffic Capturing Ongoing
    run keyword if    ${is_capturing_ongoing}    taf.sbts.oam.coam.admin.Stop IP Capture File
    Run keyword if    '${TEST_STATUS}'=='PASS'    Update test result
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin

Update test result
    ${hostname}=    Run    hostname
    ${TESTLINE_NAME}=    Replace String    ${hostname}    -    _
    Get_QCID
    ${QCID_NUM}  fetch from right  ${QC_ID}  _
    Run keyword and ignore error
    ...  Send ReP With Scf Id  ${QCID_NUM}  bts_id=${TESTLINE_NAME}  sw=${ENB_Trunk_Version}

Get Running Version
    ${active_version}    taf.sbts.oam.coam.admin.get_sw_version
    ${is_trunk}=    Run Keyword And Return Status    Should Contain    ${active_version}    _ENB_9999_
    ${ENB_Trunk_Version}    run keyword if    ${is_trunk}
    ...  Replace String Using Regexp    ${active_version}    [0-9][0-9][A-Z][0-9]?    00
    ...    ELSE    set variable    ${active_version}
    set test variable    ${ENB_Trunk_Version}
