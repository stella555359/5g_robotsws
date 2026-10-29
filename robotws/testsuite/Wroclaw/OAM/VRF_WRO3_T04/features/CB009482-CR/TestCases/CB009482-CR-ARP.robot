*** Settings ***
Documentation    Suite for testing common_resources for cloud

Library         taf.transport.ssh       WITH NAME    ssh
Library         taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library         taf.nms.netact          WITH NAME    nms
Library         OperatingSystem
Resource        taf/rfrl/cbts/utilities/init_variables.robot
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/parameters/parameters.robot
Resource        ../../../../cloud_common_resources/alarms/alarms.robot
Resource        ../../../../cloud_common_resources/certificates/certificates.robot
Resource        ../../../../cloud_common_resources/resets/resets.robot
Resource        ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource        taf/rfrl/cbts/robot/webem_operations.robot
Resource        ../../../cloud_common_resources/mantaray/mantaray.robot
Resource        ../../../cloud_common_resources/test_pc/test_pc.robot
Resource        ../Resources/Keywords.robot
Resource        ../../../cloud_common_resources/counters/counters.robot
Resource        taf/rfrl/cbts/robot/netact/netact.robot
Library         taf.config.scf  WITH NAME  scf
Library         DateTime

*** Variables ***
${IP_TEST_PC}=     10.42.63.239
${LOGIN_TEST_PC}=  trs
${PASS_TEST_PC}=   YT_xk39b
${OAM_USERNAME}=        ${tl.gnbs[0].dus[0].oam_http_connection_details.username}
${OAM_PASSWORD}=        ${tl.gnbs[0].dus[0].oam_http_connection_details.password}
${VDU_MRBTS_ID}=        ${tl.gnbs[0].instance_id}
${timestamp_offset}=    10min
${NMS_USERNAME}    omc
${NMS_PASSWORD}    Medsql!_1893
${MAC_Addres}=     92:c7:72:87:34:76
${TNL-ID}=         6

*** Keywords ***
CB009482-X_Cloud_Rate_limit_for_ARP_packets-ipRmDropPcktsRtLimARP_vDU
    [Arguments]  ${Test_PC_interface}
    Change Parameter on BTS  MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1  oamTls  off  hw_type=vDU
    ${NMS_LAB}    Integrate Cloud BTS with NMS Lab without TLS    preferred_lab=srnclab1047   hw_type=vDU
    ${ARP_counter}    Set Variable    ipRmDropPcktsRtLimArp
    log  change intervals ipFilteringInterval, reportingIntervalPm to 5 min  console=yes
    Change Parameter on BTS  MRBTS-${MRBTS}/TNLSVC-1/PMTNLINT-1  ipFilteringInterval  5min  hw_type=vDU
    Change Parameter on BTS  MRBTS-${MRBTS}/MNL-1/MNLENT-1/PMCADM-1  reportingIntervalPm  5min  hw_type=vDU
    Sleep    11min    reason=Wait until correct counters will be collected properly
    ${M51328C17_before}    Wait For Next Counter Interval and Get Counter Timestamp with Value
    ...    counter_id=M51328C17     ip_address=${LMP_VDU_IP}    hw_type=vDU
    ${number_of_packets}    Set Variable    0
    ${number_of_iteration}    Set Variable    0
    WHILE    ${number_of_packets} < ${M51328C17_PACKETS} * 0.8
        Log    Numer iteracji to ${number_of_iteration}    console=true
        Start Tcpdump For M51328C17 Counter vDU    ${Test_PC_interface}
        ${MAC1}    Get MAC Address
        Send Packets For M51328C17 Counter To CBTS   ${MAC1}   ${M51328C17_PPS}   ${M51328C17_PACKETS}   ${Test_PC_interface}
        Sleep    15s
        Kill Tcpdump For M51328C17 Counter vDU
        ${number_of_packets}=  Get Number Of Packets After Packets Flood For M51328C17 vDU
        ${number_of_iteration}=    Evaluate    ${number_of_iteration}+1
        Run Keyword If    ${number_of_iteration} > 10    Fail
    END
    ${M51328C17_after_equation}=     Set Variable    ${False}
    WHILE    not ${M51328C17_after_equation}
        ${M51328C17_after}    Wait For Next Counter Interval and Get Counter Timestamp with Value
        ...    counter_id=M51328C17     ip_address=${LMP_VDU_IP}    hw_type=vDU
        ${M51328C17_after_value}    Get Dictionary Values    ${M51328C17_after}
        ${M51328C17_after_equation}    Evaluate
        ...    ${M51328C17_after_value}[0] > ${M51328C17_VALUE} - (${M51328C17_VALUE} * ${M51328C17_ERROR})
        IF    not ${M51328C17_after_equation}
            Sleep    1sec
        END
    END
    ${M51328C17_after1}    Get Dictionary Values    ${M51328C17_after}
    Log     ${M51328C17_after1}     console=true
    ${M51328C17_after_date}    Get Dictionary Keys    ${M51328C17_after}
    Log     ${M51328C17_after_date}    console=true
    ${M51328C17_after_date_cvt}=   Convert Date From WebEM To NMS Format   ${M51328C17_after_date}
    Log     ${M51328C17_after_date_cvt}    console=true
    ${counter}=     Set Variable    0
    ${max_attempts}=     Set Variable    2
    WHILE    ${counter} < ${max_attempts}
        ${status}   ${result}=    Run Keyword And Ignore Error     Get PM Counters from Mantaray
        ...    mrbts_id=${MRBTS}   counters=${ARP_counter}    alias=${NMS_LAB}
        Run Keyword If      '${status}'=='PASS'   Exit For Loop
        ${counter}=    Evaluate    ${counter} + 1
    END
    ${is_date_visible}=     Set Variable    ${False}
    ${attempt}=        Set Variable    0
    WHILE    not ${is_date_visible} and ${attempt} < 4
        ${ctr_mantaray}    Get PM Counters from Mantaray    mrbts_id=${MRBTS}   counters=${ARP_counter}    alias=${NMS_LAB}
        ${date}=    Evaluate    [i['period_start_time'] for i in ${ctr_mantaray}][-1]
        ${is_date_visible}=    Run Keyword and Return Status    Should Be Equal    ${date}    ${M51328C17_after_date_cvt}
        ${attempt}=    Evaluate    ${attempt} + 1
        IF    not ${is_date_visible}
            Sleep    5min
        END
    END
    ${counter_object}=   counters._Get Counter Object From WebEM Via Address    ip_address=${LMP_VDU_IP}    hw_type=vDU
    ${counter_value_MantaRay}=   Evaluate
    ...  [i['${ARP_counter}'] for i in ${ctr_mantaray} if i['period_start_time']=='${M51328C17_after_date_cvt}' and '${counter_object}' in i['dn']]
    Log    ${counter_value_MantaRay}    console=true
    ${check_status}=    Run Keyword And Return Status   Should be Equal As Numbers   ${counter_value_MantaRay[0]}   ${M51328C17_after1[0]}
    IF    ${check_status}
        Log   The M51328C17 counter values match: MantaRay = ${counter_value_MantaRay[0]}, WebEM = ${M51328C17_after1[0]}.
    ELSE
        Fail   The M51328C17 counter values mismatch: MantaRay = ${counter_value_MantaRay[0]}, WebEM = ${M51328C17_after1[0]}!
    END
    ${equation_WebEm}=  Evaluate
    ...  (${M51328C17_VALUE} - (${M51328C17_VALUE} * 0.1) < ${M51328C17_after1[0]} < ${M51328C17_VALUE} + (${M51328C17_VALUE} * 0.1))
    ${equation_Mantaray} =  Evaluate
    ...  (${M51328C17_VALUE} - (${M51328C17_VALUE} * 0.1) < ${counter_value_MantaRay[0]} < ${M51328C17_VALUE} + (${M51328C17_VALUE} * 0.1))
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_Mantaray}
    log  packets were successfully collected in M51328C17 transport counter  console=yes
    [Teardown]    Deintegrate Cloud BTS from NMS Lab  ${NMS_LAB}  vDU

Get MAC Address
    ${x}    counters._Get Counter Object From WebEM Via Address   ${LMP_VDU_IP}    vDU    3
    ${y}    Set Variable    ${x}/ETHSVC-1/ETHIF-1/ETHIF_R-1
    ${temp_conn}=        Connect to ADMIN    hw_type=vDU
    Create Directory    ${OUTPUT_DIR}/${TEST_NAME}
    vdu_admin.get_current_plan_file
    ...           local_dir_path=${OUTPUT_DIR}/${TEST_NAME}  filename=x.xml   include_runtime_data=${True}
    ...           vdu_connection=${temp_conn}
    scf.load_scf      ${OUTPUT_DIR}/${TEST_NAME}/x.xml
    ${value}=         scf.get_value_from_scf    dist_name=${y}   p_name=macAddr
    [Return]          ${value}
    [Teardown]    Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

Convert Date From WebEM To NMS Format
    [Arguments]    ${M51328C17_after_date}
    ${date_string}=     Set Variable     ${M51328C17_after_date}[0]
    ${parsed}=          convert date     ${date_string}     result_format=%Y-%m-%d %H:%M:%S
    ${final}=           Set Variable     ${parsed}.0
    [Return]    ${final}
