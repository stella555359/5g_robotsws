*** Settings ***
Documentation    ...
#Suite Teardown    Common Suite Teardown    debug
#Test Teardown     Common Test Teardown 2
#Force Tags        CLOUD_5G_I_LPQ_AP_LOO    Owner_Anne
#...               SBTS00    SBTS24R3    Pz4_12    CB008927    RAN_5G    RAN_5G_TDD
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./Resources/CB008927_resource.robot
#
#*** Variables ***
#${WTS_DIR}                        /opt/iphy/latest
#${NUMBER_OF_PAGING_LOOPS}         10
#${SCF_PATH}                       ${CURDIR}/Config
#${FULL_SCF_ET31}                  CB008927_ET_31_scfc.xml
#${WTS_LOCAL}                      ${CURDIR}/Config
#${IPHY_FILE_ET31}                 ${WTS_LOCAL}/iphy_8927_ET31.xml
#${WTS_CFG_ET31}                   basic_setup_8927_I_ET31.cfg
#${RD}                             0x580839=1;0x580345=1;0x58090b=1;0x580954=1
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#
#*** Test Cases ***
#CB008927_31_TDD_RAT1_CMAS
#    [Documentation]
#    ...    Precondition:
#    ...    -  Setup FR1 TDD cell in FD BF (NRBTS.actFdmScheduling ,NRBTS,actFdmEnhancedScheduling )
#    ...    -  Set the preconditions for the TDD cell, as per USCB008927-H#E1:
#    ...            Start PRB Randomization with one dedicated BWP in the cell with multiple PDSCH sub areas.
#    ...    -  Several UEs belonging to the single dedicated BWPs, with different radio conditions(to trigger HARQ retransmission) as mentioned below:
#    ...        - With full buffer traffic scenario that fulfill the largest PDSCH sub-area within the dedicated BWP with FDM PDSCH grants.
#    ...        - With sporadic traffic (ping, small FTP file), to validate the startPrb randomization algorithm in the dedicated BWP
#    ...              and the CORESET#0 within the largest BWP with FDM PDSCH grant
#    ...        - Mixed traffic (VoNR + FTP)
#    ...        -  act beamforming ,2200 is enable.
#    ...    - SA mode
#    ...    - actPRBBlanking =true;nbrOfBlankedPRBsHighEdgeDL not 0,nbrOfBlankedPRBsLowEdgeUL is not 0
#    ...    - ueConnectionEstablishmentMode=dedicated
#    ...    - actCMAS=true
#    ...
#    ...    Configuration:
#    ...    - different Coreset position
#    ...    - type0coresetindex and gscn different
#    ...    - band width=40  MHZ
#    ...    - coreset0 in low edge
#    ...    - SA
#    ...
#    ...    Steps:
#    ...     1 attach UE1, start FULL DL/UL traffic
#    ...     2 AMF paging UE2 continues:
#    ...     3 attach UE3 ,start ping (external traffic mode)
#    ...     4 attach ue4 ,start vonr call
#    ...     5 attach ue5 start small dl/ul traffic
#    ...     6 attach ue6 , start  FULL DL/UL traffic
#    ...     7 ue6 send A1 report to add scell
#    ...     8 trigger CMAS
#    ...
#    ...    Check Points:
#    ...     1 when 1 UE attached with full traffic , 1UE can use all PRB
#    ...     2 check UE prb number and start prb
#    ...     3 check UE prb number and start prb in SSB slot
#    ...     4 check ue prb with dcl1_0  schedule
#    ...     5 check couter MAX_ALLOC_PRB_PDSCH_RAT1, DCI_ALLOC_PDSCH_RAT1, PRB_USED_PDSCH_RAT1,UE_PDSCH_RAT1_ONLY,PRB_USED_PDSCH, PRB_USED_PDSCH_RAT1
#    ...     6 CMAS is ok, all UEs trffic is normal, every UE's PRB is ok in one slot .
#
#
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_ET31}
#    ...        AND    Suite Setup Update GNB    scf_file=${FULL_SCF_ET31}    iphy_file=${IPHY_FILE_ET31}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#    ...        AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Create Test Directory
#    # [Setup]    Create Test Directory
#
#
#    # ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}     save_egate=${True}
#
#    Start GNB Syslog    ${TEST_LOG_DIRECTORY}/attach
#
#     # UE-1 as background UE with full traffic
#    SA Attach    ue_id=1
#    Sleep    1s
#    # UE-2 for paging
#    SA Attach    ue_id=2
#    Sleep    1s
#    # UE-3 for ping
#    SA Attach    ue_id=3    trf_type='external'
#    ${ip}    Get UeIp From Egate
#    Sleep    1s
#    # UE-4 for VONR
#    SA Attach    ue_id=4
#    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue\=4 pdu\=1 qosflows_to_add\=3 by=amf
#    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue\=4 pdu\=1 qosflows_to_add\=4 by=amf
#    Log To Console    \n UE-4 VONR configured
#    Sleep    1s
#    # UE-5 for small DL/UL traffic
#    SA Attach    ue_id=5
#    Sleep    1s
#    # UE-6 for CA
#    SA Attach    ue_id=6
#    ute_wtssim.Execute Egate Command    cmd=ue_measurement_send_nr id\=6 meas_id\=1 event=A1 srsrp_nr\=105
#    Stop And Collect GNB Syslog    ${TEST_LOG_DIRECTORY}/attach
#
#    # Log To Console    \n Start background traffic for UE-1
#    SA Start DL Traffic Internal    ue_id=1    pdu_id=1    mbps=500
#    SA Start UL Traffic Internal    ue_id=1    pdu_id=1    mbps=60
#
#    Check UE Tput
#
#    Log To Console    \n Start paging for UE-2
#    Start Log Capture    log_dir=paging
#    Paging from AMF on UE    ue_id=2    loop_number=${NUMBER_OF_PAGING_LOOPS}
#    Stop Log Capture    log_dir=paging
#    Log To Console    \n Paging OK
#
#    Check UE Tput
#
#    Log To Console    \n Start to PING UE-3
#    Start Log Capture    log_dir=ping
#    Execute ping to UE IP    ${ip}    time=10
#    Stop Log Capture    log_dir=ping
#    Log To Console    \n Ping ${ip} OK
#
#    Check UE Tput
#
#    Log To Console    \n Start to UE-4 VONR traffic
#    Start Log Capture    log_dir=vonr
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=4 pdu\=1 qfi\=3 dir=dl trf_id=\1 rtp_codec=amr_12_2
#    Sleep    1s
#    Stop Log Capture    log_dir=vonr
#
#    Check UE Tput
#
#    Log To Console    \n Start to UE-5 Small traffic
#    Start Log Capture    log_dir=small
#    SA Start DL Traffic Internal    ue_id=5    pdu_id=1    mbps=20
#    SA Start UL Traffic Internal    ue_id=5    pdu_id=1    mbps=20
#    Sleep    1s
#    Stop Log Capture    log_dir=small
#
#    Check UE Tput
#
#    Log To Console    \n Start to UE-6 CA traffic
#    Start Log Capture    log_dir=ca
#    SA Start DL Traffic Internal    ue_id=6    pdu_id=1    mbps=500
#    SA Start UL Traffic Internal    ue_id=6    pdu_id=1    mbps=60
#    Sleep    1s
#    Stop Log Capture    log_dir=ca
#
#    Check UE Tput
#
#    # Start CMAS boradcast
#    Log To Console    \n Start CMAS Boardcast
#    Start GNB Syslog    ${TEST_LOG_DIRECTORY}/cmas
#    Start CMAS Broadcast
#
#    Check UE Tput
#    Stop And Collect GNB Syslog    ${TEST_LOG_DIRECTORY}/cmas
#
#    # Start log capturing for 1 seconds
#    Log To Console    \n Start log capturing
#    Capture Ttitrace for duration '1s' to log dir 'cmas'
#
#
#    Run Keyword And Continue On Failure    Verify ttitrace bler should not high than '0.01' in path 'cmas'
#
#    Start Gnb BIP Log
#    Sleep    1s
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/cmas
#
#    [Teardown]     Run Keywords    SA 5G Detach    ue_id=1-6
#    ...            AND    Stop CMAS Broadcast
#    ...            AND    Common Test Teardown    debug
#
## MyTest
##     ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}     save_egate=${True}
#
##     SA Attach    ue_id=3    trf_type='external'
##     ${ip}    Get UeIp From Egate
##     SA Attach    ue_id=4
##     SA Attach    ue_id=5
##     SA Attach    ue_id=6
#
##     Execute ping to UE IP    ${ip}    time=10
#
#*** Keywords ***
#SA Attach
#    [Arguments]    ${ue_id}    ${pdu_id}=1    ${trf_type}='internal'
#    # Set UEC Reordering Timer
#    SA 5G Attach    ue_id=${ue_id}
#    Sleep    1s
#    Run Keyword If    ${trf_type}=='internal'    SA Set Traffic Type To internal    ue_id=${ue_id}    pdu_id=${pdu_id}
#    Run keyword Unless    ${trf_type}=='internal'    SA Set Traffic Type To external    ue_id=${ue_id}    pdu_id=${pdu_id}
#    Sleep    1s
#    ${output}    SA 5G PDU Session Setup    ${ue_id}    pdu_id=${pdu_id}
#    Sleep    1s
#
#SA Set Traffic Type To external
#    [Arguments]    ${ue_id}    ${pdu_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type=external
#
#Start capture Ttitrace
#    common_Log_capture.Start Ttitrace With Streaming Mode
#
#Start Log Capture
#    [Arguments]    ${log_dir}
#    Start GNB Syslog    ${TEST_LOG_DIRECTORY}/${log_dir}
#    # Start Gnb BIP Log
#    Start capture Ttitrace
#
#Stop Log Capture
#    [Arguments]    ${log_dir}
#    Stop And Collect GNB Syslog    ${TEST_LOG_DIRECTORY}/${log_dir}
#    common_Log_capture.Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/${log_dir}
#    # Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/${log_dir}
#
#Config 5QI-5 for UE
#        [Arguments]    ${id}
#        Log To Console    \n start 5QI-5 Setup for UE-${id}...
#        ${command}    Set Variable    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=3 by=amf
#        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#        ...    ${command}
#        ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
#        ...    timeout=1minutes
#        ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
#        Log To Console    ${output}
#
#Config 5QI-1 for UE
#        [Arguments]    ${id}
#        Log To Console    \n start 5QI-1 Setup for UE-${id}...
#        ${command}    Set Variable    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=4 by=amf
#        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#        ...    ${command}
#        ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
#        ...    timeout=1minutes
#        ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
#        Log To Console    ${output}
#
#Get UeIp From Egate
#    Log To Console    start to get UE ip
#    ${rnti_reg}=    Set Variable    (\\d+\\.\\d+\\.\\d+\\.\\d+)
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
#    ${ipList}=    String.Get Regexp Matches    ${content}    ${rnti_reg}
#    ${ip}=    Set Variable    @{ipList}[-1]
#    Log to Console    \n UE IP is ${ip}
#    [Return]    ${ip}
#
#Execute ping to UE IP
#    [Arguments]    ${ip}    ${time}
#    ${result}    Run    ping -c ${time} ${ip}
#    Log to Console    \n Ping OK
#
#Paging from AMF on UE
#    [Arguments]    ${ue_id}    ${loop_number}
#    ${cmd}    Catenate    amf_paging_start id\=1 ue\=${ue_id}
#    :FOR    ${loop}    IN RANGE    ${loop_number}
#        Make UE to idle    ${ue_id}
#        Log To Console    \n IDLE OK
#        Log To Console    \n Start to paging
#        ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=reestablishment complete
#    END
#
#Make UE to idle
#    [Arguments]    ${ue_id}
#    Log To Console    \n NAS normal release in progress
#    ute_wtssim.Execute Egate Command    cmd=amf_paging_param id\=1 default_drx=128 max_paging_retries\=1
#    ute_wtssim.Execute Egate Command    cmd=ue_ng_ctx_release id\=${ue_id} cause\=NAS_normal_release    pass_regexp=: IS IDLE
#
#Start CMAS Broadcast
#    Log To Console    \n Start CMAS Broadcast
#    ute_wtssim.Execute Egate Command    cmd=cbs_broadcast_start amf=1 type=cmas concurrent=true tai=311:489|788
#    ...                      warning_msg=test repetition=indefinitepass_regexp=SystemInformationBlockType8-NR updated
#    ...                      timeout=10
#
#Stop CMAS Broadcast
#    Log To Console    \n Stop CMAS Broadcase
#    ute_wtssim.Execute Egate Command    cmd=cbs_broadcast_stop amf=1
#
#Check UE Tput
#    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=1-6 type=pusch,pdsch scell=0-31    pass_regexp=EGATE>
