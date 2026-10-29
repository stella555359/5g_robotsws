*** Settings ***
Documentation     author: y63li&wu xia
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: ying.15.li@nokia-sbell.com

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/siso_resource.robot
Library           5GC001250-AA.py
Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py    WITH NAME    lib
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           taf.ul.oam.netact.cm     WITH NAME     netact_cm
Library           taf.transport.ssh    WITH NAME    csn
Library           OperatingSystem
Library           Collections
Library           taf.pdu
Library           String
Library           Process

*** Variables ***
${DU_OAM_IP}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${CU_OAM_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}

${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ROOT_USERNAME}=           toor4nsn
${ROOT_PASSWORD}=           oZPS0POrRieRtu
${SERVICEUSER_USERNAME}=    serviceuser
${SERVICEUSER_PASSWORD}=    Pl(FzaYj5~c5;q


${BACKHAUL_OAM_IP}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}

${NETACT_USERNAME}=   omc
${NETACT_PASSWORD}=   Nokia123!
${filename}=  pcap_file.pcap
${path}=  /home/ute/logs
${scf_name}    scf_5GC001250.xml
${tmp_log_dir}    /home/ute/logs
${testline}  7_5_UTE5G401T906
${connection}    DU_OAM
${Max_loop_number}    5
@{linkspeed_list}      Cpri2    Cpri3    Cpri5    Cpri6    Cpri7
@{linkspeed_list1}      Obsai3Gbps    Obsai6Gbps

${delta_RMOD_ADD}=   ${CURDIR}/RMOD_Link.json
${CABLINK_ID}    14
${Rmod_ID}    12
${Rmod_ID_05}    1

*** Keywords ***
#-------------------Common keyword for all cases--------------------------------------------------------------------------------
5GC001250_Common Suite Setup for COAM
#    CI_interface.Common Suite Setup
    Set Suite Variable    ${TS_LOG_PATH_BASE}    ${tmp_log_dir}
    5GC001250_COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}
    Create directory    ${epc_log_path}
    Admin Get MrbtsId And NrbtsId

5GC001250_Common Suite Teardown for COAM
    Run Keyword And Ignore Error    AdminCli disconnection and Test teardown

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=${connection}


5GC001250_Generate suite log path
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to DU via ssl
    ${sw_version} =     coam.get_sw_version    connection=${connection}
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Set Suite Variable    ${sw_version}
    Create directory    ${SUITE_LOG_PATH}

5GC001250_COAM Create log directory
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    5GC001250_Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

Connect to DU via ssl
    [Arguments]  ${connection}=${connection}    ${bts_host}=${DU_OAM_IP}
    ...    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

Precondition: All cells can be on air
    log to console  \n***** Precondition: All cells can be on air *****
    wait until keyword succeeds    3 min    10s    Check If BTS Is OnAir

Case Teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    Change actServiceAccountSsh parameter value to true in SECADM on connection
    Change actServicePortState parameter value to true in SECADM on connection
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=${connection}
    CI_interface.Common Case Teardown

Admin Get MrbtsId And NrbtsId
    run keyword and ignore error    admin_cli.Teardown
    admin_cli.get_current_scf_file    local_dir_path=${epc_log_path}    file_name=${scf_name}    connection=${connection}
    ${commission_file}    set variable    ${epc_log_path}/${scf_name}
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${commission_file}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${commission_file}
    ${BTS_NAME}   lib.Get_BTS_name    scf_path=${commission_file}
    Set Suite Variable     ${mrbtsId}
    Set Suite Variable     ${nrbtsId}
    Set Suite Variable     ${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Set Suite Variable     ${commission_file}
    Set Suite Variable     ${BTS_NAME}

Check If BTS Is OnAir
    Connect to DU via ssl
    ${bts_statuses_response}=    admin_cli.Get Bts Info    connection=${connection}
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=OnAir

Connect to cOAM as toor4nsn
    [Arguments]    ${alias}=${connection}
    csn.Connect To    hostname=${DU_OAM_IP}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${alias}

Disconnect from cOAM
    [Arguments]  ${connection}=${connection}
    ssh.disconnect  connection=${connection}

Perform Parameter Update
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${operation}
    ...            ${connection}=${connection}
    ...            ${skip_parameter_relation_errors}=True
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}

ADMIN Collect Snapshot
    coam.get_snapshot     target_file_name=${epc_log_path}/Snapshot.zip    timeout=720    connection=${connection}

Check fault Cancelled on WebEM
    [Arguments]    ${alarm_filter}
    wait until keyword succeeds    3min    1min    siso_resource.WEBUI Login
    @{alarm info}=    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=60
    should be empty    ${alarm_info}
    run keyword and ignore error    selenium_coam.logout

Case Setup
    Log To Console    \n *** Case Setup
    Precondition: All cells can be on air

Netact Get SW Version
    [Arguments]  ${MRBTS_ID}  ${PLMN}=PLMN-PLMN
    [Timeout]  15 minutes
    csn.send_command    swmCLI.sh mo-status -dn ${PLMN}/MRBTS-${MRBTS_ID}
    ${version}=    csn.read output
    #Should Contain Any   ${version}   SUCCESS
    [Return]    ${version}

Connect to Netact
     csn.connect_to          hostname=${NetAct_dmgr}
     ...                     username=${NETACT_USERNAME}
     ...                     password=${NETACT_PASSWORD}


Disconnect from Netact
    [Timeout]           30 seconds
     csn.disconnect

#-------------------5GC001250-AA-02-KW--------------------------------------------------------------------------------
Add MO RMOD
    log to console     Add MO RMOD
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_RMOD_ADD}
    ...                                                 skip_parameter_relation_errors=True

ADMIN Perform Delta Recommissioning
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=${False}
    ...            ${should_activate}=${True}
    ...            ${timeout}=300
    ...            ${connection}=${connection}

    taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...                                        delta_file=${delta_file}
    ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                        should_activate=${should_activate}
    ...                                        timeout=${timeout}
    ...                                        connection=${connection}

Add MO CABLINK
    log to console     Add MO CABLINK
    Run Keyword And Continue On Failure    ADD One CABLINK object

Restore test line
    log to console     Restore test line
    #Run Keyword And Continue On Failure      wait until keyword succeeds    1 min    0s    Delete One CABLINK object
    Run Keyword And Continue On Failure      wait until keyword succeeds    1 min    0s    Delete RMOD object
    ...    Rmod_ID=${Rmod_ID}

Delete RMOD object
    [Arguments]    ${Rmod_ID}
    ${recommission_result1}=    admin_cli.perform_object_recommissioning    dist_name=MRBTS-${mrbtsId}/EQM-1/APEQM-1/RMOD-${Rmod_ID}
    ...                                         parameter=@{empty}
    ...                                         operation=delete
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}
    ...                                         connection=${connection}
    ${activate_result}=    Get From Dictionary    ${recommission_result1['commissioningResult']['activationResult']['resultNode']['parameters']}
    ...                                          result
    [Return]    ${activate_result}


Check MO CABLINK_R for BBMOD
    log to console     Check MO CABLINK_R for BBMOD
      Get CABLINK Detection Results
      Get Cablink distname of RF    status=operationalState    CABLINK_STATUSES=${CABLINK_STATUSES}
     ...    CABLINK_STATUSES_A=${CABLINK_STATUSES_A}
     ${distname_RF}    Get RMOD Detection Results

Get CABLINK Detection Results
     ${CABLINK_STATUSES}=    admin_cli.get_managed_objects    class_name=CABLINK_R  connection=${connection}
     ${CABLINK_STATUSES_A}=    admin_cli.get_managed_objects    class_name=CABLINK_A  connection=${connection}
     Set Suite Variable    ${CABLINK_STATUSES_A}
     Set Suite Variable    ${CABLINK_STATUSES}

Get Cablink distname of RF
    [Documentation]
    ...  gets all CABLINK-R* objects and:
    ...  1) checks if CABLINK is backplane or optical link
    ...  2) for optical links checks the status of link -
    ...  availabilityStatus: Online means link is detected between RMOD and BBMOD
    [Arguments]    ${status}    ${CABLINK_STATUSES}    ${CABLINK_STATUSES_A}
    ${len}=    Get Length    ${CABLINK_STATUSES}

    FOR    ${index}    IN RANGE    ${len}
        ${response}=    Get From Dictionary    ${CABLINK_STATUSES[${index}]['parameters']['stateInfo']}    ${status}
        Run Keyword If    '${response}'=='None'        Get CABLINK information    CABLINK_STATUSES=${CABLINK_STATUSES}
    ...    index=${index}
    END

    @{distname_L}   Create List
    ${len_A}=    Get Length    ${CABLINK_STATUSES_A}
    @{distname_Cablink_RF}   Create List
    FOR    ${index}    IN RANGE    ${len_A}
        ${distname1}=    Get From Dictionary    ${CABLINK_STATUSES_A[${index}]}     distName
       ${Cablink_ID}=    Fetch From Right    ${distname1}    marker=CABLINK_A-
        Append To List   ${distname_L}   MRBTS-${mrbts_id}/EQM-1/HWTOP-1/CABLINK-${Cablink_ID}
        ${response}=    Get From Dictionary    ${CABLINK_STATUSES_A[${index}]['parameters']}    firstEndpointLabel
        Run Keyword If    '${response}'!='BACKPLANE'    Append To List   ${distname_Cablink_RF}   ${mrbts_id}/EQM-1/HWTOP-1/CABLINK-${Cablink_ID}
    END
    Set Suite Variable    @{distname_L}
    Set Suite Variable    @{distname_Cablink_RF}

Get CABLINK information
    [Arguments]    ${CABLINK_STATUSES}    ${index}
    ${firstEndpointLabel}=     Get From Dictionary    ${CABLINK_STATUSES[${index}]['parameters']}     firstEndpointLabel
    ${firstEndpointPortId}=     Get From Dictionary    ${CABLINK_STATUSES[${index}]['parameters']}     firstEndpointPortId
    ${secondEndpointLabel}=     Get From Dictionary    ${CABLINK_STATUSES[${index}]['parameters']}     secondEndpointLabel
    ${secondEndpointPortId}=     Get From Dictionary    ${CABLINK_STATUSES[${index}]['parameters']}     secondEndpointPortId
     Should Be Equal    ${firstEndpointLabel}    BACKPLANE
     Should Be True    ${firstEndpointPortId}==1
     Should Be Equal    ${secondEndpointLabel}    BACKPLANE
     Should Be True    ${secondEndpointPortId}==1

Get RMOD Detection Results
    ${RMODs}=    admin_cli.get_frm    connection=${connection}
    ${RF_len}=    Get Length      ${RMODs}
    @{distname_RF}   Create List
    FOR    ${index}    IN RANGE    ${RF_len}
        ${distname1}=    Get From Dictionary    ${RMODs[${index}]['id']}    configuration
        ${distname2}     Convert To String    ${distname1}
        Append To List   ${distname_RF}   ${distname2}
    END
    Set Suite Variable    @{distname_RF}
    [Return]    @{distname_RF}

Create RMOD Object
    [Documentation]     to create RMOD object with required parameters
    [Arguments]    ${Max_loop_number}    ${distname_RF}
    ${mandatory_params}   params to create rmod obj
    ${mandatory_params1}   params to create phyand obj
    Set Suite Variable    ${mandatory_params}
    FOR    ${index}    IN RANGE    ${Max_loop_number}
         ${activate_result}    ${Rmod_ID}   ADD RMOD object    Max_loop_number=${Max_loop_number}   distname_RF=${distname_RF}
         Exit For Loop If  '${activate_result}'=='Success'
    END
    [Return]    ${Rmod_ID}

ADD RMOD object
    [Arguments]    ${Max_loop_number}    ${distname_RF}
    FOR    ${index}    IN RANGE    ${Max_loop_number}
        ${Rmod_ID}    evaluate    random.randint(1,24)    random
        Set Suite Variable    ${Rmod_ID}
        ${distname1}    Set Variable    ${mrbtsId}/EQM-1/APEQM-1/RMOD-${Rmod_ID}
        Run Keyword If  '${distname1}' not in @{distname_RF}    Exit for loop
    END
    ${recommission_result1}=    admin_cli.perform_object_recommissioning    dist_name=MRBTS-${mrbtsId}/EQM-1/APEQM-1/RMOD-${Rmod_ID}
    ...                                         parameter=${mandatory_params}
    ...                                         operation=create
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}
    ...                                         connection=${connection}
    ${activate_result}=    Get From Dictionary    ${recommission_result1['commissioningResult']['activationResult']['resultNode']['parameters']}
    ...                     result
    [Return]    ${activate_result}    ${Rmod_ID}

#-------------------5GC001250-AA-05-KW--------------------------------------------------------------------------------
Config CABLINKs parameter
    log to console     Config CABLINKs parameter
    Connect to DU via ssl
    Run Keyword And Continue On Failure    ADD One CABLINK object

Modify CABLINKs parameter and check pdl result
    log to console     Modify CABLINKs parameter and check pdl result
    #Modify CABLINK linkspeed and check pdl result

Delete One CABLINK object
    ${mandatory_params}   params to create new cablink obj      mrbtsId=${mrbtsId}    rmodid=${Rmod_ID_05}
    ${distname}    Set Variable    MRBTS-${mrbtsId}/EQM-1/HWTOP-1/CABLINK-${CABLINK_ID_05}
    ${recommission_result}=    admin_cli.perform_object_recommissioning    dist_name=MRBTS-${mrbtsId}/EQM-1/HWTOP-1/CABLINK-${CABLINK_ID_05}
    ...                                         parameter=${mandatory_params}
    ...                                         operation=delete
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}
    ...                                         connection=${connection}
    ${activate_result}=    Get From Dictionary    ${recommission_result['commissioningResult']['activationResult']['resultNode']['parameters']}
    ...                                         result
    [Return]    ${activate_result}

ADD One CABLINK object
    ${mandatory_params}   params to create new cablink obj      mrbtsId=${mrbtsId}    rmodid=${Rmod_ID_05}
    ${NEW_CABLINK_ID}    evaluate    random.randint(1,65)    random
    Set Suite Variable        ${CABLINK_ID_05}    ${NEW_CABLINK_ID}
    ${distname}    Set Variable    MRBTS-${mrbtsId}/EQM-1/HWTOP-1/CABLINK-${CABLINK_ID_05}
    ${recommission_result}=    admin_cli.perform_object_recommissioning    dist_name=MRBTS-${mrbtsId}/EQM-1/HWTOP-1/CABLINK-${CABLINK_ID_05}
    ...                                         parameter=${mandatory_params}
    ...                                         operation=create
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}
    ...                                         connection=${connection}
    ${activate_result}=    Get From Dictionary    ${recommission_result['commissioningResult']['activationResult']['resultNode']['parameters']}
    ...                                         result
    [Return]    ${activate_result}

Check DU version via ADMIN and Netact
       Connect to Netact
       ${version_NetAct}=    Netact Get SW Version   ${mrbtsId}
       convert to string    ${version_NetAct}
       should contain     ${sw_version}    ${sw_version}
       Disconnect from Netact

#-------------------5GC001250-HA_5GC000263_001------------------------------------------------------------------
Save snapshot
    Log To Console    Save snapshot    console=yes
    ADMIN Collect Snapshot

Check if RFSW logs exist in snapshot
    Log To Console    Check if RFSW logs exist in snapshot    console=yes
    Verify if the snapshot contains the RFSW logs    snapshot_file=${epc_log_path}/Snapshot.zip

Verify if the snapshot contains the RFSW logs
    [Arguments]    ${snapshot_file}
    Extract zip file    ${snapshot_file}    /tmp/snapshot
    ${filecontents}     Grep file           /tmp/snapshot/snapshot_file_list.txt            *_RMOD_L_[0-9]_
    Log to Console      \n RMOD Files :\n${filecontents}
    Should contain      ${filecontents}     _RMOD_L_1_startup.zip       ignore_case=True
    Should contain      ${filecontents}     _RMOD_L_1_runtime.zip       ignore_case=True

#-------------------5GC001250-NA_5GC000325_001------------------------------------------------------------------

SSH to gNB with toor4nsn by password and check RUEM log
    Log    \n SSH to gNB with toor4nsn by password and check RUEM log   console=yes
    Change systemAcctPermEnable parameter value to false in FEATCADM on connection
    Connect to cOAM as toor4nsn
    csn.send command    command=ls -l /ffs/run/config/users.json |awk '{print $5}'     connection=${connection}
    ${file_size}    csn.Read Output    connection=${connection}
    ${file_size} =    Convert To Integer    ${file_size}
    should be true    ${file_size} > 0

Change ${parameter_name} parameter value to ${value} in ${SECADM_or_FEATCADM} on connection
     Connect to DU via ssl
     admin_cli.perform_parameter_recommissioning         dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/${SECADM_or_FEATCADM}-1
     ...                                           parameter=${parameter_name}
     ...                                           operation=update
     ...                                           value=${value}
     ...                                           skip_parameter_relation_errors=${True}
     ...                                           should_activate=${True}
     ...                                           connection=${connection}

SSH to gNB with toor4nsn by password and check RUEM log_2
    Log    \n SSH to gNB with toor4nsn by password    console=yes
   Change systemAcctPermEnable parameter value to false in FEATCADM on connection
   sleep    10s
   #Run Keyword And Ignore Error    ConnectFailedError:*   Connect to cOAM as toor4nsn
   Change actServiceAccountSsh parameter value to true in SECADM on connection
   Change actServicePortState parameter value to true in SECADM on connection
   Connect to cOAM as toor4nsn
   csn.send command    command=ls -l /ffs/run/config/users.json |awk '{print $5}'     connection=${connection}
   ${file_size}    csn.Read Output    connection=${connection}
   ${file_size} =    Convert To Integer    ${file_size}
   should be true    ${file_size} > 0

#-------------------5GC001250-OA_5GC000326_002------------------------------------------------------------------

Log to DU WebEM
    Log    \n Log to DU WebEM    console=yes
    Connect to cOAM as toor4nsn
    ssh.send command    command=timeout 60 tcpdump -i fp0 -w /user/toor4nsn/${filename}    connection=${connection}

Changes TLS mode parameter from OFF to FORCED
    Log    \n Changes TLS mode parameter from OFF to FORCED    console=yes
    Change oamTls parameter value to off in MPLANENW on connection
    Change oamTls parameter value to forced in MPLANENW on connection
    BuiltIn.Sleep   130

Analyse wireshark logs_02
    Log    \n Analyse wireshark log    console=yes
    ssh.send command    command=pkill tcpdump    connection=${connection}
    Download pcap file
    Change oamTls parameter value to off in MPLANENW on connection
    Check wireshark Message_02

Download pcap file
    ssh.download_file   /user/toor4nsn/${filename}    ${path}/${filename}
    ...                 connection=${connection}
    ssh.send_command    command=rm ${filename}
    ...                 connection=${connection}

Check wireshark Message_02
    cap.read_cap      cap_file=${path}/${filename}    display_filter=tls
    ${filter} =    Catenate    tls.record.version == 0x0303
    cap.Check Expression    ${filter}

Start Capture Wireshark
    Log    \n Start Capture Wireshark    console=yes
    Connect to cOAM as toor4nsn
    ssh.send command    command=timeout 60 tcpdump -i fp0 -w /user/toor4nsn/${filename}    connection=${connection}
    wait until keyword succeeds    2min    10s    siso_resource.WEBUI Login
    BuiltIn.Sleep   65
    ssh.send command    command=pkill tcpdump    connection=${connection}

Log to DU WebEM_04
    Log    \n Log to DU WebEM    console=yes
    Download pcap file
    Run Keyword And Ignore Error    siso_resource.WEBUI Logout

Analyse wireshark logs_04
    Log    \nStep3: Analyse wireshark log    console=yes
    Check wireshark Message_04

Check wireshark Message_04
    cap.read_cap      cap_file=${path}/${filename}    display_filter=tls
    ${filter_1} =    Catenate    tls.handshake.type == 16
    cap.Check Expression    ${filter_1}
    ${filter_2} =    Catenate    tls.handshake.type == 12
    cap.Check Expression    ${filter_2}

Check wireshark Message_06
    cap.read_cap      cap_file=${path}/${filename}    display_filter=tls
    ${filter} =    Catenate    tls.handshake.type == 2 and tls.handshake.ciphersuite == 0xc030
    cap.Check Expression    ${filter}
