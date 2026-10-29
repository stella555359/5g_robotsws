*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    owner-flora.du    team-DevHZ5_SG2
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5GC000704-C    STATE_CONFIGURED    release-5G19A
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
#${EMIL_DOCKER_COMPOSE_FILE}    ${CURDIR}/scripts/emil/docker-compose.yml
#${EMIL_START_CMD}    ${CURDIR}/scripts/emil/emil_start_cmd.txt
#${mplane_ip}    10.0.1.2

@{PARAMS_IN_SCF}    @{HO_PARAMS}    @{A5_PARAMS}    @{NRREL_PARAMS}    @{NRADJGNB}
...    @{NRADJNRCELL}    @{cipherPrefL}    @{XNLINK-1}    @{A3_PARAMS}

@{HO_PARAMS}
...    NRBTS-1:actConflictConfiguration=true
...    NRBTS-1:actIncXn=true

@{A3_PARAMS}
...    NRBTS-1/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRBTS-1/NRCELL-1:absThreshSsbRsrqConsolidation=1
...    NRBTS-1/NRCELL-1:sMeasConfigSsbRsrp=1

...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS-1/NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40

@{A5_PARAMS}
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=11
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=20
...    MRBTS-1/NRBTS-1:actConflictConfiguration=false
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms320

@{NRREL_PARAMS}
...    NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-1:gNbId=35
...    NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=24
...    NRBTS-1/NRCELL-1/NRREL-1:lcrId=1
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{NRADJNRCELL}
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=24
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3

@{NRADJGNB}
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=24
...    MRBTS-1/NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3

@{XNLINK-1}
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.124

@{cipherPrefL}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{PARAMS_TO_ENABLE_SA_A3_RSRP}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min

${SUCC_HO_NRREL}    M55153C00002
${ATT_HO_NRREL}    M55153C00001

@{PM_Counter_HO_RLF}
...    ${SUCC_HO_NRREL}=0
...    ${ATT_HO_NRREL}=1

@{PARAMS_IN_SWCONFIG}    0x340002=1    0x340006=55153
#enable OAM debug log

*** Test Cases ***
5GC000704_C001_Verify_HO_Failure_by_T304_And_RLF_TestCase
    [Documentation]
    ...    This case verify Unsuccessful intra-frequency handover due to T304 expiry
    ...    Message check: 
    ...    nr-rrc.reestablishmentCause == 1 and f1ap.F1AP_PDU == 0
    ...    xnap_16_7_0_2109_n03.procedureCode == 0 and xnap_16_7_0_2109_n03.radioNetwork == 1 and nr-rrc.physCellId == 381
    ...    Counter check:
    [Tags]    5GC000704_T304    QC_125787
    Check Xn link available
    Delta Commission Parameters    ${PARAMS_TO_ENABLE_SA_A3_RSRP}
    Clear Counter Files
    Prepare UE History Information
    UE Attach To Cell1
    Handover From gNB to Sim Should failed when RLF or T304
    Check Wireshark Log    ${CURDIR}${/}a2a_T304${/}a2a_t304.ini
    Check Counters    ${PM_Counter_HO_RLF}
    #Stop And Collect Emil Log
    UE Deregister From gNB    ue_id=1

*** Keywords ***
Modify Cfg
    BuiltIn.Log    update CFG    console=${True}
    ${GNB3_CFG}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:24 
    ...    daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${GNB3_CFG}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=true
    ${CELL_381}    Catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg    ${CELL_381}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
    Check Xn link available

Check Xn link available
    BuiltIn.Log    check expect xnlink setup as expect    console=${True}
    Object Should Exist    XNLINK-1:xnLinkStatus=available

UE Attach To Cell1
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1
    Execute Egate Command    ue_register id=1    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1    pass_regexp=QoS Routing Table

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    UE${ue_id}: detached

Handover From gNB to Sim Should failed when RLF or T304
    ${rlf_cmd}    Catenate
    ...    ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=2 cause=handoverFailure
    Execute Egate Command    ${rlf_cmd} 
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency   ue_id=1    carrierfreq=636576    event_type=A3
    ${a3_rsrq_cmd}    Catenate
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=381 nrsrp_nr=40 nrsrq_nr=40
    Execute Egate Command    ${a3_rsrq_cmd}    pass_regexp=reestablishmentCause handoverFailure
    Sleep    2s    # waiting for the UE IDLE
    Execute Egate Command    ue_disp id=1    IDLE

Prepare UE History Information
    ${cmd_1}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ${cmd_1}
    ${cmd_2}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ${cmd_2}
    ${cmd_3}    Catenate    ue_history_information_list id=1 action=commit
    Execute Egate Command    ${cmd_3}
    ${cmd_4}    Catenate    ue_enb_param id=1 ue_history_list=1
    Execute Egate Command    ${cmd_4}


Start Emil Container At First Time
    [Arguments]    ${force_start}=${False}
    ${ret}=    Run Keyword And Return Status    Check Docker Started Healthy
    run keyword if    "${ret}"=="${False}"    Start Emil Container

Check Docker Started Healthy
    ${ret}=    OperatingSystem.Run    sudo docker ps|grep condor-worker-1
    Should Contain    ${ret}    healthy

Start Emil Container
    OperatingSystem.Run    sudo docker-compose -f ${EMIL_DOCKER_COMPOSE_FILE} kill; sudo rm -rf /home/sharedvolume
    OperatingSystem.Run    sudo mkdir /home/sharedvolume
    OperatingSystem.Run    sudo ln -s /home/sharedvolume /sharedvolume
    OperatingSystem.Run    sudo chown -R ute:ute /home/sharedvolume
    OperatingSystem.Run    mkdir -p /sharedvolume/condor
    #create docker by docker-compose.yml under current execuate dir
    #Run    cd ${CURDIR}; sudo docker-compose up -d
    ${ret}=    OperatingSystem.Run    sudo docker-compose -f ${EMIL_DOCKER_COMPOSE_FILE} up -d
    Log    ${ret}
    Wait Until Keyword Succeeds    240s    10s    Check Docker Started Healthy

Start Emil Log
    Run    sudo docker stop $(sudo docker ps -aq);sudo docker rm $(sudo docker ps -aq);sudo docker rmi $(sudo docker images -q)
    ${start_emil_time}=    Print Time    start emil log time
    ${start_emil_time}=    String.Replace String    ${start_emil_time}    ${SPACE}    T
    Set Suite Variable    ${start_emil_time}
    Run    sudo docker logs -t --since="${start_emil_time}" condor-worker-1 > ${OUTPUT_DIR}/docker_log_start.txt
    Start Emil Container
    Start Emil Container At First Time
    Run    cp ${EMIL_START_CMD} ${SAVE LOG DIRECTORY}
    Run    sed -i s"/10.0.1.2/${mplane_ip}/" ${SAVE LOG DIRECTORY}/emil_start_cmd.txt
    ${cmd}=    OperatingSystem.Get File    ${SAVE LOG DIRECTORY}/emil_start_cmd.txt
    Log    ${cmd}
    Run    ${cmd}
    ${ret}=    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 netstat -an|grep 15067
    Should Contain    ${ret}    ESTABLISHED
    [Teardown]    Run    sudo docker logs -t --since="${start_emil_time}" condor-worker-1 > ${SAVE LOG DIRECTORY}/docker_log_start.txt

Stop And Collect Emil Log
    [Arguments]    ${log_dir}=${SAVE LOG DIRECTORY}
    Stop Emil Log
    Collect Emil Log
    [Teardown]    Run    sudo docker logs -t --since="${start_emil_time}" condor-worker-1 > ${SAVE LOG DIRECTORY}/docker_log_stop.txt

Stop Emil Log
    ${ret}=    OperatingSystem.Run    curl -X DELETE http://172.21.0.11:10009/dataCollections/CPlane_Traces_5G-10.0.1.2-172.21.0.11
    Should Contain    ${ret}    <h1>Ok</h1>

Collect Emil Log
    [Arguments]    ${log_dir}=${SAVE LOG DIRECTORY}
    ${ret}=    OperatingSystem.Run    find /sharedvolume/condor |grep .5gm
    ${emil_files}=    String.Split To Lines    ${ret}
    OperatingSystem.Copy File    ${emil_files}[0]    ${log_dir}

Print Time
    [Arguments]    ${info}
    ${time}    Get Current Date    result_format=timestamp
    Log To Console    \n${time}:${info}
    [Return]    ${time}
