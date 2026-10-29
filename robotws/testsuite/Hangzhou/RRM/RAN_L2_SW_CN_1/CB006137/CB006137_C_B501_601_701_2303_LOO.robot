*** Settings ***
Documentation    ...
#Library            taf.transport.ssh    WITH NAME    csn
#Resource           ./CB006137_resource.robot
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup        Common Suite Setup
#Test Setup         Common Test Setup 2
#Test Teardown      Run Keyword And Ignore Error    Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1    SBTS22R4    CN1_SG09_SM3    RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${UE_ID}                    1
#${PROFILE_ID}               1
#${GNB_ID}                   2
#${CELL_ID}                  1
#${BEARER_ID}                2
#${Egatelog_path}            ${CURDIR}
#${SCF_DIR}                  ${CURDIR}/config
#${LOCAL_IPHY_DIR}           ${CURDIR}/config
#${LOCAL_WTS_DIR}            ${CURDIR}/config
#${WTS_DIR}                  /opt/iphy/latest
#${WTS_CFG}                  basic_setup_BOO_5cell_C_B1.cfg
#${WTS_CFG_C_2303}           wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_FS_2T3F.cfg
#${6137_C_B1_SCF}            SCF_BO_5cell_C_B1.xml
#${6137_C_B2303_SCF}         SCF_C_B2303.xml
#${IPHY}                     iphy_2T3F_LOO.xml
#${CU_addr}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#${CU_username}              ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
#${CU_password}              ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
#${number_ue}                3
#
#*** Test Cases ***
#CB006137-ET-C-B501_Verify_Reset_of_5G_L3_SW_5G-CP-UE
#    [Tags]     caseCB501    Manual_Krihu    TA_krihu
#    [Setup]    Setup TL For Each Case    ${6137_C_B1_SCF}    ${IPHY}    ${WTS_CFG}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG}
#    Attach Multi SA UE    3
#    A1 triggered Scell Addition
#    Multi SA UE Start Traffic and Check
#    Trigger CPUE auto reset
#    Wait Until Keyword Succeeds    3min    5s    Check If Alarm Appeared    4383
#    Wait Until Keyword Succeeds    3min    5s    Check If Alarm Disappeared    4383
#    Wait Until Keyword Succeeds    15min    10s    Verify All Cells Are OnAir
#    #Check after CPUE auto reset
#
#CB006137-ET-C-B601_Verify_Reset_of_5G_L2_NRT_SW_5G-L2-HI
#    [Tags]     caseCB601    Manual_Krihu    TA_krihu
#    [Setup]    Setup TL For Each Case    ${6137_C_B1_SCF}    ${IPHY}    ${WTS_CFG}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG}
#    Attach Multi SA UE    3
#    A1 triggered Scell Addition
#    Multi SA UE Start Traffic and Check
#    #Trigger UPUE auto reset
#    #Wait Until Keyword Succeeds    3min    5s    Check If Alarm Appeared    7313
#    #Wait Until Keyword Succeeds    3min    5s    Check If Alarm Disappeared    7313
#    Wait Until Keyword Succeeds    15min    10s    Verify All Cells Are OnAir
#    #Check after UPUE auto reset
#
#CB006137-ET-C-B701_Verify_Reset_of_5G_L2_RT_SW_5G-L2-LO_and_5G-L2-PS
#    [Tags]     caseCB701    Manual_Johnny    TA_krihu
#    [Setup]    Setup TL For Each Case    ${6137_C_B1_SCF}    ${IPHY}    ${WTS_CFG}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG}
#    Attach Multi SA UE    3
#    A1 triggered Scell Addition
#    Multi SA UE Start Traffic and Check
#    #Trigger L2RT auto reset
#    #Wait Until Keyword Succeeds    3min    5s    Check If Alarm Appeared    7313
#    #Wait Until Keyword Succeeds    3min    5s    Check If Alarm Disappeared    7313
#    Wait Until Keyword Succeeds    15min    10s    Verify All Cells Are OnAir
#    #Check after L2RT auto reset
#
#CB006137-ET-C-B2303_Verify_IWK_with_Both_PCell_and_SCell_UL_NACK_flood_are_triggered
#    [Documentation]
#    ...   Precondition:  sCellActivationMethod = bufferBased configured
#    ...   Test Steps:
#    ...   # Step1: UE attach
#    ...   # Step2: Start enough DL&UL traffic and activate Scell
#    ...   # Step3: Add UL Bler For both pcell and scell to trigger nackflood
#    ...   # Step4: Capture ttilog, Check pcell and scell nackflood process
#    ...            Check point  1.bufferSplitTrigger is 1 not 15 when Both_PCell_and_SCell_UL_NACK_flood_are_triggered
#    ...                         2.laTimer.event start,stop when enterNFD,exitNFD
#    ...                         3.When enter NFD, ulLaDeltaSinr.rrmPauseUeInUlScheduling=0 and stop UL Scheduling
#    ...                           When exit NFD, ulLaDeltaSinr.rrmPauseUeInUlScheduling=1 and start UL Scheduling
#    ...                         4.After rdPeriodUlScheduling(pscell both 100ms, 10SFN), time out, if receive 5 crc nok,
#    ...                           wait rdPeriodUlScheduling again
#    ...   rd parameter:0x58067c # d6137SubCEnable
#    ...                0x580641,0x58057F,0x58057a # UlCaDynamicPowerSplit related;
#    ...                0x5801FC # rdMinCrcNackIndUlEnhancedSCell
#    ...                0x580161 # rdMinCrcNackIndUlEnhanced
#    ...                0x5801FB # rdPeriodUlSchedulingSCell
#    [Tags]    caseCB2303    Manual_Krihu    TA_krihu
#    [Setup]    Run Keywords    Add RD Parameters To GNB Swconfig File
#    ...        0x58067c=0x1;0x580641=1;0x58057F=16;0x58057a=4;0x5801FC=3;0x580161=3;0x5801FB=100
#    ...        AND      Setup TL For Each Case    ${6137_C_B2303_SCF}    ${IPHY}    ${WTS_CFG_C_2303}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_C_2303}
#    Basic L3 Call and Traffic
#    Capture And Decode TTitrace When NACKFLOOD Trigger
#    Run Keyword And Ignore Error    Check NACKFLOOD From TTI    ${TEST_LOG_DIRECTORY}/ttitrace/2303
#
#*** Keywords ***
#Basic L3 Call and Traffic
#    [Arguments]    ${ul_tp_set}=50    ${dl_tp_set}=100
#    Attach SA UE
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=1 mbps\=${dl_tp_set} dir=dl seconds=9999
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=1 mbps\=${ul_tp_set} dir=ul seconds=9999
#
#Force DTX Pusch For PSCELL to make NACKFLOOD
#    ute_wtssim.Execute Egate Command    cmd=forced_dtx_testmode_nr profile_id=1 force_dtx_pusch=100:0
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${UE_ID} scell=0,1 testmode=forced_dtx profile_id=1 action=activate
#
#Capture And Decode TTitrace When NACKFLOOD Trigger
#    Start Ttitrace With Streaming Mode
#    Force DTX Pusch For PSCELL to make NACKFLOOD
#    Sleep    3s    reason=Wait for log collection...
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2303
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2303
#
#Check NACKFLOOD From TTI
#    [Arguments]    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_nfd.ini    output_ul.csv    ${csv_file_path}
#
#Check after CPUE auto reset
#    [Arguments]    ${dl_tp_threshold}=10    ${ul_tp_threshold}=10
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=1    dir=ul    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=pcell    scell_index=1
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=1    dir=ul    cell_type=pcell    scell_index=1
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=2    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=2    dir=ul    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=3    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=3    dir=ul    cell_type=pcell    scell_index=0
#    ${pcell_dl_tp1}=    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=pcell    scell_index=0
#    ${pcell_ul_tp1}=    Get CA Cell Average Throughput    ue_id=1    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_dl_tp1}=    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=pcell    scell_index=1
#    ${scell_ul_tp1}=    Get CA Cell Average Throughput    ue_id=1    dir=ul    cell_type=pcell    scell_index=1
##    Should Be True    ${pcell_ul_tp}==0
##    Should Be True    ${pcell_dl_tp}==0
##    Should Be True    ${scell_ul_tp}==0
##    Should Be True    ${scell_dl_tp}==0
##    Should Be True    ${pcell_ul_tp}>${ul_tp_threshold}
##    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
##    Should Be True    ${scell_ul_tp}>${ul_tp_threshold}
##    Should Be True    ${scell_dl_tp}>${dl_tp_threshold}
##    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=2 type=pdsch scell=0
##    ...          pass_regexp=UE2: NR UEStats are supported only for Active UE    timeout=5min
#    ${pcell_dl_tp2}=    Get CA Cell Average Throughput    ue_id=2    dir=dl    cell_type=pcell    scell_index=0
#    ${pcell_ul_tp2}=    Get CA Cell Average Throughput    ue_id=2    dir=ul    cell_type=pcell    scell_index=0
##    Should Be True    ${pcell_ul_tp}>${ul_tp_threshold}
##    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
#    ${pcell_dl_tp3}=    Get CA Cell Average Throughput    ue_id=3    dir=dl    cell_type=pcell    scell_index=0
#    ${pcell_ul_tp3}=    Get CA Cell Average Throughput    ue_id=3    dir=ul    cell_type=pcell    scell_index=0
##    Should Be True    ${pcell_ul_tp}>${ul_tp_threshold}
##    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
#     ${checkpoint_ue1}=    Catenate    ${pcell_ul_tp1}>${ul_tp_threshold} or ${pcell_dl_tp1}>${dl_tp_threshold}
#     ...    or ${scell_ul_tp1}>${ul_tp_threshold} or ${scell_dl_tp1}>${dl_tp_threshold}
#     ${checkpoint_ue2}=    Catenate    ${pcell_ul_tp2}>${ul_tp_threshold} or ${pcell_dl_tp2}>${dl_tp_threshold}
#     ${checkpoint_ue3}=    Catenate    ${pcell_ul_tp3}>${ul_tp_threshold} or ${pcell_dl_tp3}>${dl_tp_threshold}
#     Should Be True    ${checkpoint_ue1} or ${checkpoint_ue2} or ${checkpoint_ue3}    UE has no TP.
#
#
#Check after UPUE auto reset
#    [Arguments]    ${dl_tp_threshold}=10    ${ul_tp_threshold}=10
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=1    dir=ul    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=pcell    scell_index=1
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=1    dir=ul    cell_type=pcell    scell_index=1
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=2    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=2    dir=ul    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=3    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=3    dir=ul    cell_type=pcell    scell_index=0
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=pcell    scell_index=0
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=1    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_dl_tp}=    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=pcell    scell_index=1
#    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=1    dir=ul    cell_type=pcell    scell_index=1
#    Should Be True    ${pcell_ul_tp}==0
#    Should Be True    ${pcell_dl_tp}==0
#    Should Be True    ${scell_ul_tp}==0
#    Should Be True    ${scell_dl_tp}==0
##    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=2 type=pdsch scell=0
##    ...          pass_regexp=UE2: NR UEStats are supported only for Active UE    timeout=5min
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=2    dir=dl    cell_type=pcell    scell_index=0
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=2    dir=ul    cell_type=pcell    scell_index=0
#    Should Be True    ${pcell_ul_tp}==0
#    Should Be True    ${pcell_dl_tp}==0
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=3    dir=dl    cell_type=pcell    scell_index=0
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=3    dir=ul    cell_type=pcell    scell_index=0
##    Should Be True    ${pcell_ul_tp}==0
##    Should Be True    ${pcell_dl_tp}==0
#    Should Be True    ${pcell_ul_tp}>${ul_tp_threshold}
#    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
#
#Check after L2RT auto reset
#    [Arguments]    ${dl_tp_threshold}=10    ${ul_tp_threshold}=10
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=1    dir=ul    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=pcell    scell_index=1
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=1    dir=ul    cell_type=pcell    scell_index=1
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=2    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=2    dir=ul    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=3    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Ignore Error    Get CA Cell Average Throughput    ue_id=3    dir=ul    cell_type=pcell    scell_index=0
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=pcell    scell_index=0
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=1    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_dl_tp}=    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=pcell    scell_index=1
#    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=1    dir=ul    cell_type=pcell    scell_index=1
#    Should Be True    ${pcell_ul_tp}==0
#    Should Be True    ${pcell_dl_tp}==0
#    Should Be True    ${scell_ul_tp}==0
#    Should Be True    ${scell_dl_tp}==0
#    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=2 type=pdsch scell=0
#    ...          pass_regexp=UE2: NR UEStats are supported only for Active UE    timeout=5min
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=3    dir=dl    cell_type=pcell    scell_index=0
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=3    dir=ul    cell_type=pcell    scell_index=0
##    Should Be True    ${pcell_ul_tp}==0
##    Should Be True    ${pcell_dl_tp}==0
#    Should Be True    ${pcell_ul_tp}>${ul_tp_threshold}
#    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
#
#Attach Multi SA UE
#    [Arguments]    ${number_ue}
#    :FOR    ${index}    IN RANGE    1    ${number_ue}+1
#    \    SA 5G Attach    ue_id=${index}
#    \    SA Set Traffic Type To Internal    ue_id=${index}     pdu_id=1
#    \    SA 5G PDU Session Setup    ue_id=${index}
#
#Start Multi SA UE Traffic
#    [Arguments]    ${number_ue}    ${dl_tp_set}    ${ul_tp_set}
#    :FOR    ${index}    IN RANGE    1    ${number_ue}+1
#    \    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${index} pdu=1 qfi=1 trf_id=1 mbps\=${dl_tp_set} dir=dl seconds=9999
#    \    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${index} pdu=1 qfi=1 trf_id=1 mbps\=${ul_tp_set} dir=ul seconds=9999
#
#Connect to ABIO
#    csn.connect_to    hostname=${CU_addr}    username=${CU_username}    password=${CU_password}    alias=ABIO
#
#Trigger CPUE auto reset
#   Connect to ABIO
#   ${pidinfo}   csn.Execute    command=bsh 1:0 lxc-attach -n 0x2734 -- pkill -11 -f '/opt/CCS/CCSDaemonExe'
#   ...          connection=ABIO
#   Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO
#
#Trigger UPUE auto reset
#    Connect to ABIO
#    ${pidinfo}   csn.Execute    command=bsh 1:0 lxc-attach -n 0x2731 -- pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe'
#    ...          connection=ABIO
#    Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO
#
#Trigger L2RT auto reset
#    Connect to ABIO
#    ${pidinfo}   csn.Execute    command=bsh 1:0 lxc-attach -n 0x2730 -- pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe'
#    ...          connection=ABIO
#    Run Keyword And Ignore Error    csn.Disconnect    connection=ABIO
#
#A1 triggered Scell Addition
#    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A1 srsrp_nr=100
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}
#    ...    pass_regexp=rrcReconfigurationComplete
#    ...    timeout=3minutes
#
#Multi SA UE Start Traffic and Check
#    [Arguments]    ${dl_tp_threshold}=10    ${ul_tp_threshold}=10
#    Log To Console    Start Traffic and Check
#    Start Multi SA UE Traffic    3    175    100
#    Sleep    20s    reason=wait Traffic stable
#    :FOR    ${index}    IN RANGE    1    ${number_ue}+1
#    \    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${index}    dir=dl    cell_type=pcell    scell_index=0
#    \    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${index}    dir=ul    cell_type=pcell    scell_index=0
#    \    Should Be True    ${pcell_ul_tp}>${ul_tp_threshold}
#    \    Should Be True    ${pcell_dl_tp}>${dl_tp_threshold}
#    ${scell_dl_tp}=    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=scell    scell_index=1
#    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=1    dir=ul    cell_type=scell    scell_index=1
#    Should Be True    ${scell_ul_tp}>${ul_tp_threshold}
#    Should Be True    ${scell_dl_tp}>${dl_tp_threshold}
#
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}
#    OperatingSystem.Run    cp ${local_wts_dir}/${WTS_CFG} ${WTS_DIR}
#    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_CFG}
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    #Add RD Parameters To GNB Swconfig File    0x580591=0;
#
##Common Test Teardown 2
##    [Arguments]    ${snapshot}=${False}    ${egate}=${True}
##    Stop And Collect Syslog    ${TEST_LOG_DIRECTORY}
##    Run Keyword And Ignore Error    Save Egate Log    log_path=${TEST_LOG_DIRECTORY}
##    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ram/node_CPRT00/tmp/startup_cp_rt.log* ${TEST_LOG_DIRECTORY}
##    OperatingSystem.Run    cp -r ${OUTPUT_DIR}/bip_attach/ ${TEST_LOG_DIRECTORY}
##    Get Current Testline Config Files    log_path=${TEST_LOG_DIRECTORY}/myconfigs/
##    Run Keyword If    "${snapshot}"=="${True}"    Collect GNB SnapShot Via AaShell    log_dir=${TEST_LOG_DIRECTORY}
##    Run Keyword If    "${snapshot}"=="${True}"    Collect UTE SosReport    log_dir=${TEST_LOG_DIRECTORY}
##    Run Keyword If    "${egate}"=="${True}"    Clean Edaemon And Egate
##    #Run    cp Gnb_syslog.tar.gz ${TEST_LOG_DIRECTORY}
##    Run Keyword And Ignore Error    Filter ERR WRN Message From Syslog By Log Path    ${TEST_LOG_DIRECTORY}
##    ...    ${CURDIR}/filter_msg.txt    ${TEST_LOG_DIRECTORY}/case_fatal_log.txt
