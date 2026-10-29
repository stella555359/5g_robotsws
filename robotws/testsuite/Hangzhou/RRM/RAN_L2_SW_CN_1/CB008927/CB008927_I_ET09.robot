*** Settings ***
Suite Teardown    Common Suite Teardown    debug
Test Teardown     Common Test Teardown 2
Force Tags        CLOUD_5G_I_LPQ_AP_LOO    Owner_Anne
...               SBTS00    SBTS24R3    Pz4_12    CB008927    RAN_5G    RAN_5G_TDD
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./Resources/CB008927_resource.robot

*** Variables ***
${WTS_DIR}                        /opt/iphy/latest
${NUMBER_OF_PAGING_LOOPS}         1
${SCF_PATH}                       ${CURDIR}/Config
${FULL_SCF_ET09}                  CB008927_ET_09_scfc.xml
${WTS_LOCAL}                      ${CURDIR}/Config
${IPHY_FILE_ET09}                 ${WTS_LOCAL}/iphy_8927_ET09.xml
${WTS_CFG_ET09}                   basic_setup_8927_I_ET09.cfg
${RD}                             0x580839=1;0x580345=1;0x58090b=1;0x580954=1
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}


*** Test Cases ***
CB008927_ET_09_TDD_RAT1_BBpooling_with_3_bwp_refinebeam
    [Documentation]
    ...    Precondition:
    ...    - Setup FR1 TDD cell in FD BF (NRBTS.actFdmScheduling ,NRBTS,actFdmEnhancedScheduling )
    ...    - Set the preconditions for the TDD cell, as per USCB008927-H#E1:
    ...         Start PRB Randomization with one dedicated BWP in the cell with multiple PDSCH sub areas.
    ...      Several UEs belonging to the single dedicated BWPs, with different radio conditions (to trigger HARQ retransmission) as mentioned below:
    ...    - With full buffer traffic scenario that fulfill the largest PDSCH sub-area within the dedicated BWP with FDM PDSCH grants.
    ...    - With sporadic traffic (ping, small FTP file), to validate the startPrb randomization algorithm in the dedicated BWP
    ...         and the CORESET#0 within the largest BWP with FDM PDSCH grant
    ...    - Mixed traffic (VoNR + FTP)
    ...    - cell bandwidth : 30/40/100
    ...    - SA mode
    ...    - actPRBBlanking =true;nbrOfBlankedPRBsHighEdgeDL not 0,nbrOfBlankedPRBsLowEdgeUL is not 0
    ...    - ueConnectionEstablishmentMode=dedicated
    ...    - actCMAS=true
    ...    - 8954 is enable
    ...
    ...    Steps:
    ...     // For every 6 UEs on one BWP:
    ...     1 attach UE1, start FULL DL/UL traffic
    ...     2 AMF paging UE2 continues: amf_paging_start id=2 ue=2
    ...     3 attach UE3, start ping (external traffic mode)
    ...     4 attach ue4, start vonr call
    ...     5 attach ue5, start small dl/ul traffic
    ...     6 attach ue6, start  FULL DL/UL traffic
    ...     7 ue6 send 1A report to add scell
    ...     8 trigger CMAS
    ...
    ...    Check Points:
    ...     1 when 1 UE attached with full traffic , 1UE can use all PRB
    ...     2 check UE prb number and start prb,check prb number is limited by pooling
    ...     3 check UE prb number and start prb in SSB slot
    ...     4 check ue prb with dcl1_0  schedule
    ...     5 check couter MAX_ALLOC_PRB_PDSCH_RAT1, DCI_ALLOC_PDSCH_RAT1, PRB_USED_PDSCH_RAT1, UE_PDSCH_RAT1_ONLY,PRB_USED_PDSCH,
    ...          PRB_USED_PDSCH_RAT1
    ...     6 CMAS is ok, all UEs trffic is normal , every UE's PRB is ok in one slot .


    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_ET09}
    ...        AND    Suite Setup Update GNB    scf_file=${FULL_SCF_ET09}    iphy_file=${IPHY_FILE_ET09}    swconfig_param=${RD}
    ...        AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
    ...        AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
    ...        AND    Create Test Directory
    # [Setup]    Create Test Directory


    # ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}     save_egate=${True}

    Start GNB Syslog    ${TEST_LOG_DIRECTORY}/attach

    # Attach UE 1~18: 1/4/7/10/13/16 on 100M BWP, 2/5/8/11/14/17 on 40M BWP, 3/6/9/12/15/18 on 30M BWP
    # UE 1 ~ 3: Background UE with big traffic
    # UE 4 ~ 6: Paging
    # UE 7 ~ 9: VONR
    # UE 10 ~ 12: Small traffic
    # UE 13 ~ 15: CA
    # UE 16 ~ 18: Ping

    # UE 1 ~ 15 with intertnal traffic type
    FOR    ${id}    IN RANGE    1    16
        SA Attach    ue_id=${id}
    END

    # UE 16 ~ 18 with external traffic type
    FOR    ${id}    IN RANGE    16    19
        SA Attach    ue_id=${id}    trf_type='external'
    END

    # Get external IP for UE 16 ~ 18
    @{ips}    Get UeIp From Egate

    # Config VONR for UE 7 ~ 9
    FOR    ${id}    IN RANGE    7    10
        Config 5QI-5 for UE    ${id}
        Config 5QI-1 for UE    ${id}
        Log To Console    \n UE-${id} VONR configured
        Sleep    1s
    END

    # Config CA for UE 13 ~ 15
    FOR    ${id}    IN RANGE    13    16
        ute_wtssim.Execute Egate Command    cmd=ue_measurement_send_nr id\=${id} meas_id\=1 event=A1 srsrp_nr\=105
        ...    pass_regexp=SCellIndex \\d+ activated successfully at airphone
        Log To Console    \n UE-${id} CA configured
        Sleep    1s
    END

    Stop And Collect GNB Syslog    ${TEST_LOG_DIRECTORY}/attach

    # UE 1 ~ 3 as background UE
    Log To Console    \n Start background traffic for UE 1 ~ 3
    FOR    ${id}    IN RANGE    1    4
        SA Start DL Traffic Internal    ue_id=${id}    pdu_id=1    mbps=500
        SA Start UL Traffic Internal    ue_id=${id}    pdu_id=1    mbps=40
    END
    Check UE Tput    1    3

    # UE 4 ~ 6 for Paging
    FOR    ${id}    IN RANGE    4    7
        Log To Console    \n Start paging for UE-${id}
        Start GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}/paging_ue_${id}
        Paging from AMF on UE    ue_id=${id}    loop_number=${NUMBER_OF_PAGING_LOOPS}
        Stop And Collect GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}/paging_ue_${id}
        Check UE Tput   1    ${id}
        Log To Console    \n Paging UE-${id} OK
    END

    # UE 7 ~ 9 for VONR
    FOR    ${id}    IN RANGE    7    10
        Log To Console    \n Start to UE-${id} VONR traffic
        Start GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}/vonr_ue_${id}
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${id} pdu\=1 qfi\=3 dir=dl trf_id=\1 rtp_codec=amr_12_2
        # Sleep    1s
        Stop And Collect GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}/vonr_ue_${id}
    END
    Check UE Tput    1    9

    # UE 10 ~ 12 for small traffic
    FOR    ${id}    IN RANGE    10    13
        Log To Console    \n Start to UE-${id} Small traffic
        Start GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}/small_ue_${id}
        SA Start DL Traffic Internal    ue_id=${id}    pdu_id=1    mbps=20
        SA Start UL Traffic Internal    ue_id=${id}    pdu_id=1    mbps=20
        # Sleep    1s
        Stop And Collect GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}/small_ue_${id}
    END
    Check UE Tput    1    12

    # UE 13 ~ 15 for CA traffic
    FOR    ${id}    IN RANGE    13    16
        Log To Console    \n Start to UE-${id} CA traffic
        Start GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}/ca_${id}
        SA Start DL Traffic Internal    ue_id=${id}    pdu_id=1    mbps=500
        SA Start UL Traffic Internal    ue_id=${id}    pdu_id=1    mbps=50
        Sleep    1s
        Stop And Collect GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}/ca_${id}
    END
    Check UE Tput    1    15

    # UE 16 ~ 18 for Ping
    Start GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}/ping
    FOR    ${ip}    IN    @{ips}
        Log To Console    \n Start to PING UE-${ip}
        Execute ping to UE IP    ${ip}    time=3
        Check UE Tput    1    18
        Log To Console    \n Ping ${ip} OK
    END
    Stop And Collect GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}/ping

    # Start CMAS boradcast
    Log To Console    \n Start CMAS Boardcast
    Start GNB Syslog    ${TEST_LOG_DIRECTORY}/cmas
    Start CMAS Broadcast

    Check UE Tput    1    18
    Stop And Collect GNB Syslog    ${TEST_LOG_DIRECTORY}/cmas

    # Start log capturing for 1 seconds
    Log To Console    \n Start log capturing
    Capture Ttitrace for duration '1s' to log dir 'cmas'

    Start GNB BIP By Admin Method
    Stop Gnb BIP By Admin Method    ${TEST_LOG_DIRECTORY}/cmas

    # Check BLER via ttitrace
    Run Keyword And Continue On Failure    Verify ttitrace bler should not high than '0.01' in path 'cmas'

    # Check Point for UPD002: For two subarea case, 1 PRB in one subarea should be OK
    ${result}    Verify 1 PRB scheduled in small subarea    log_id=cmas    cell_id=55    numOfPrb=dlFdSchedData.numOfPrb
    ...    startOfPrb=dlFdSchedData.startPrb
    Should Be True    ${result}


    [Teardown]     Run Keywords    SA 5G Detach    ue_id=1-18
    ...            AND    Stop CMAS Broadcast
    ...            AND    Common Test Teardown    debug

# MyTest
#     ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}     save_egate=${True}

#     # UE 16 ~ 18 with external traffic type
#     FOR    ${id}    IN RANGE    16    19
#         SA Attach    ue_id=${id}    trf_type='external'
#     END

#     # Get external IP for UE 16 ~ 18
#     @{ips}    Get UeIp From Egate

#     FOR    ${ip}    IN    @{ips}
#         Log To Console    \n Start to PING UE-${ip}
#         Execute ping to UE IP    ${ip}    time=10
#         Check UE Tput
#         Log To Console    \n Ping ${ip} OK
#     END


*** Keywords ***
SA Attach
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${trf_type}='internal'
    # Set UEC Reordering Timer
    SA 5G Attach    ue_id=${ue_id}
    Sleep    1s
    Run Keyword If    ${trf_type}=='internal'    SA Set Traffic Type To internal    ue_id=${ue_id}    pdu_id=${pdu_id}
    Run keyword Unless    ${trf_type}=='internal'    SA Set Traffic Type To external    ue_id=${ue_id}    pdu_id=${pdu_id}
    Sleep    1s
    ${output}    SA 5G PDU Session Setup    ${ue_id}    pdu_id=${pdu_id}
    Sleep    1s

SA Set Traffic Type To external
    [Arguments]    ${ue_id}    ${pdu_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type=external

Config 5QI-5 for UE
        [Arguments]    ${id}
        Log To Console    \n start 5QI-5 Setup for UE-${id}...
        ${command}    Set Variable    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=3 by=amf
        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
        ...    ${command}
        ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
        ...    timeout=1minutes
        ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
        Log To Console    ${output}

Config 5QI-1 for UE
        [Arguments]    ${id}
        Log To Console    \n start 5QI-1 Setup for UE-${id}...
        ${command}    Set Variable    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=4 by=amf
        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
        ...    ${command}
        ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
        ...    timeout=1minutes
        ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
        Log To Console    ${output}

Get UeIp From Egate
    Log To Console    start to get UE ip
    ${rnti_reg}=    Set Variable    (\\d+\\.\\d+\\.\\d+\\.\\d+)
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${ipList}=    String.Get Regexp Matches    ${content}    ${rnti_reg}
    @{ipListNew}    Create List
    FOR    ${id}    IN RANGE    1    4
        Append To List    ${ipListNew}    ${ipList}[-${id}]
        Log to Console    \n UE IP is ${ipList}[-${id}]
    END
    [Return]    @{ipListNew}

Execute ping to UE IP
    [Arguments]    ${ip}    ${time}
    ${result}    Run    ping -c ${time} ${ip}
    Log to Console    \n Ping OK

Paging from AMF on UE
    [Arguments]    ${ue_id}    ${loop_number}
    ${cmd}    Catenate    amf_paging_start id\=1 ue\=${ue_id}
    FOR    ${loop}    IN RANGE    ${loop_number}
        Make UE to idle    ${ue_id}
        Log To Console    \n IDLE OK
        Log To Console    \n Start to paging
        ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=reestablishment complete
    END

Make UE to idle
    [Arguments]    ${ue_id}
    Log To Console    \n NAS normal release in progress
    ute_wtssim.Execute Egate Command    cmd=amf_paging_param id\=1 default_drx=128 max_paging_retries\=1
    ute_wtssim.Execute Egate Command    cmd=ue_ng_ctx_release id\=${ue_id} cause\=NAS_normal_release    pass_regexp=: IS IDLE

Start CMAS Broadcast
    Log To Console    \n Start CMAS Broadcast
    ute_wtssim.Execute Egate Command    cmd=cbs_broadcast_start amf=1 type=cmas concurrent=true tai=311:489|788 warning_msg=test repetition=indefinite
    ...                      pass_regexp=SystemInformationBlockType8-NR updated
    ...                      timeout=10

Stop CMAS Broadcast
    Log To Console    \n Stop CMAS Broadcase
    ute_wtssim.Execute Egate Command    cmd=cbs_broadcast_stop amf=1

Check UE Tput
    [Arguments]    ${ue_start}    ${ue_end}
    FOR    ${ue}    IN RANGE    ${ue_start}    ${ue_end}+1
        ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue} type=pdsch,pusch scell=0-31    timeout=60    return_output=True
    END

Verify 1 PRB scheduled in small subarea
    [Arguments]     ${log_id}    ${cell_id}    ${numOfPrb}    ${startOfPrb}

    # To list all sfn+slot with numOfPrb=1 & startPrb=2
    ${sfn_slot}    Read Csv Columns    ${TEST_LOG_DIRECTORY}/${log_id}/output_dl.csv    sfn    slot
	...    filter=((${numOfPrb}==1)&(${startOfPrb}==2)&(physCellId=${cell_id}))

    ${sfns}    Set Variable    ${sfn_slot}[0]
    ${slots}    Set Variable    ${sfn_slot}[1]

    # To find out there should be sib slot (rnti=65535) among these numOfPrb=1 & startPrb=2 slots
    FOR    ${index}    IN RANGE    len(${sfns})
        ${rntis}    Read Csv Columns    ${TEST_LOG_DIRECTORY}/${log_id}/output_dl.csv    rnti
        ...    filter=((sfn==${sfns}[${index}])&(slot==${slots}[${index}])&(physCellId=${cell_id}))
        ${is_sib_slot}    Evaluate    65535 in ${rntis}
        Exit For Loop If    ${is_sib_slot}
    END

    [Return]    ${is_sib_slot}
