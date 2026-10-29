*** Settings ***
Documentation    ...
#Resource    ./CB006137_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1
#...                RAN_5G    RAN_5G_TDD    CRT    CN1_SG09_SM3
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}               ${CURDIR}
#${SCF_DIR}                     ${CURDIR}/config
#${gnb_swconfig}                ${SCF_DIR}/swconfig_drx.txt
#${LOCAL_IPHY_DIR}              ${CURDIR}/config
#${SCF_PATH}    ${CURDIR}/config
#${6137_C_1701_SCF}           SCF_C1701.xml
#${6137_C_1602_SCF}           SCF_C1602.xml
#${6137_C_B201_SCF}           SCF_C_B201.xml
#${6137_C_B101_SCF}           SCF_C_B101.xml
#${WTS_CFG_C}              basic_setup_BOO_5cell_C_1701.cfg
#${WTS_CFG_CB201}              basic_setup_BOO_5cell_C_B201.cfg
#${WTS_CFG_CB101}              basic_setup_BOO_5cell_C_B101.cfg
#${WTS_multiUEscript}      multi_ue_sa_script.lua
#${iphy_2T3F_C}     iphy_2T3F_LOO.xml
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB006137-ET-C-IWK1701_Verify_Multiple_UEs_FDM_IWK_with_CB006878_Dyn_UL_Resource_Allocation_in_TDD_multiple_dedicated_BWP_without_beamforming
#    [Documentation]
#    ...   Precondition:  sCellActivationMethod = bufferBased configured
#    ...   Test Steps:
#    ...   # Step1: multi UE attach
#    ...   # Step2: Start enough DL&UL traffic and activate Scell
#    ...   # Step3: Capture ttilog, Check TDD cell PRB num
#    ...    Check point  1.multi UE attach right
#    ...                 2.Scell activated successfully
#    ...                 3.traffic is normal both on Pcell and Scell
#    ...                 4.check tti trace numofPRB of TDD scell is right due to pusch Configuration
#    ...   rd parameter:0x58067c # d6137SubCEnable
#    ...                0x580641,0x58057F,0x58057a # UlCaDynamicPowerSplit related;
#    [Tags]    caseC1701    trshen    CRT
#    [Setup]    Setup TL For Each Case    ${6137_C_1701_SCF}    ${iphy_2T3F_C}    ${WTS_CFG_C}
#    Copy WTS MultiUE Script    ${WTS_multiUEscript}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_C}
#    # Step1: multi UE attach and Step2: Start enough DL&UL traffic and activate Scell
#    Attach Multi SA CA UE And Do Traffic
#    Check UE Throughput For All UE
#    # Step3: Capture ttilog, Check TDD cell PRB num
#    ${log_dir}=    Capture And Decode TTitrace    C1701
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/CIWK_16_17/ttitrace_ul_prb.ini    ${log_dir}/format_output_ul.csv    ${log_dir}
#
#
#CB006137-ET-C-IWK1602_Verify_Multiple_UEs_FDM_IWK_with_CB006878_Dyn_UL_Resource_Allocation_in_TDD_single_dedicated_BWP_with_beamforming
#    [Documentation]
#    ...   Precondition:  sCellActivationMethod = bufferBased configured
#    ...   Test Steps:
#    ...   # Step1: multi UE attach
#    ...   # Step2: Start enough DL&UL traffic and activate Scell
#    ...   # Step3: Capture ttilog, Check TDD cell PRB num
#    ...    Check point: 1.multi UE attach right
#    ...                 2.Scell activated successfully
#    ...                 3.traffic is normal both on Pcell and Scell
#    ...                 4.check tti trace numofPRB of TDD scell is right due to pusch Configuration
#    ...   rd parameter:0x58067c # d6137SubCEnable
#    ...                0x580641,0x58057F,0x58057a # UlCaDynamicPowerSplit related;
#    [Tags]    caseC1602    Manual_Yulei    TA_MaYue
#    [Setup]    Setup TL For Each Case    ${6137_C_1602_SCF}    ${iphy_2T3F_C}    ${WTS_CFG_C}
#    Copy WTS MultiUE Script    ${WTS_multiUEscript}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_C}
#    # Step1: multi UE attach and Step2: Start enough DL&UL traffic and activate Scell
#    Attach Multi SA CA UE And Do Traffic
#    Check UE Throughput For All UE
#    # Step3: Capture ttilog, Check TDD cell PRB num
#    ${log_dir}=    Capture And Decode TTitrace    C1602
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/CIWK_16_17/ttitrace_ul_prb.ini    ${log_dir}/format_output_ul.csv    ${log_dir}
#
#CB006137-ET-C-UPD004-B201_Verify_FDDTDD_UL_CA_for_PC2_UEs_with_and_without_parallelTxSRS_capability_with_USCB008247-B-B2
#    [Documentation]
#    ...    Precondition:  actUeCsirsCoexistCellCsirs = false, pMaxNROwnCell=20dBm
#    ...    frameStructureType = tdLte,guardPeriodLength = 6 symbols (SSF6),lteToNrFrameShift = 0ms,
#    ...    prachConfiguration = 158 (format B4 in subframe 7)
#    ...   Test Steps:
#    ...   # Step1: 2 UEs attach
#    ...   # Step2: Start enough DL&UL traffic and activate Scell
#    ...   # Step3: Capture bip, Check numOfPuschSymbols
#    ...   Check point: numOfPuschSymbols=PCS14,means long PUCSH
#    [Tags]    caseCB201    Manual_Anne    TA_MaYue
#    [Setup]    Setup TL For Each Case    ${6137_C_B201_SCF}    ${iphy_2T3F_C}    ${WTS_CFG_CB201}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_CB201}
#    Attach SA CA UE and Get Throughput    UE_ID=1-2    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=10    ul_tp_threshold=10    A1_add=${False}
#    ...    A2_rel=${False}
#    Capture BIP    CB201
#    ${log_dir}=    Convert BIP To CSV By MCShark For numOfPuschSymbols    CB201
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/CB201/bip_numOfPuschSymbols.ini    ${log_dir}/numOfPuschSymbols.csv    ${log_dir}
#
#CB006137-ET-C-UPD004-B101_Verify_CB_SRS_for_DL_BF_for_signle_UE_on_critical_BC
#    [Documentation]
#    ...    Precondition:  actUeCsirsCoexistCellCsirs = false, pMaxNROwnCell=20dBm
#    ...    frameStructureType = tdLte,guardPeriodLength = 6 symbols (SSF6),lteToNrFrameShift = 0ms,
#    ...    prachConfiguration = 158 (format B4 in subframe 7)
#    ...   Test Steps:
#    ...   # Step1: 1 UEs attach
#    ...   # Step2: Start enough DL&UL traffic and activate Scell
#    ...   # Step3: Capture bip, Check numOfPuschSymbols
#    ...   Check point:
#    ...            1.On Scell, periodic code book SRS is allocated for UE
#    ...            2.numOfPuschSymbols=PCS14,means long PUCSH
#    [Tags]    caseCB101    Manual_Johnny   TA_Trshen
#    [Setup]    Setup TL For Each Case    ${6137_C_B101_SCF}    ${iphy_2T3F_C}    ${WTS_CFG_CB101}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_CB101}
#    # Step1: 1 UEs attach
#    # Step2: Start enough DL&UL traffic and activate Scell
#    Attach SA CA UE and Get Throughput    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=10    ul_tp_threshold=10    A1_add=${False}
#    ...    A2_rel=${False}
#    #1.On Scell, periodic code book SRS is allocated for UE
#    Check SRS Usage From Egate
#    #2.numOfPuschSymbols=PCS14,means long PUCSH
#    Capture BIP    CB101
#    ${log_dir}=    Convert BIP To CSV By MCShark For numOfPuschSymbols    CB101
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/CB201/bip_numOfPuschSymbols.ini    ${log_dir}/numOfPuschSymbols.csv    ${log_dir}
#
#*** Keywords ***
#Attach SA UE Do UL Traffic
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup CA    ue_id=${UE_ID}
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    Sleep    10s
#    ${TDDpcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#
#Common Suite Setup
#    Suite Setup Update GNB    swconfig_param=0x580591=0;0x58056B=0;0x58067c=0x1    log=${False}    skip_reboot=${True}
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Configure UTE ETH For GNB3
#
#Configure UTE ETH For GNB3
#    [Documentation]    This keyword is to configure VM interfaces.
#    Log To Console    configure VM interfaces...
#    OperatingSystem.Run    sudo ip addr add 10.0.3.151/32 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.3.153/32 dev eth1
#    OperatingSystem.Run    sudo ip addr add 192.168.6.252/32 dev eth4
#
#Save Egate Log
#    [Arguments]    ${log_path}=${SUITE_LOG_DIRECTORY}
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    OperatingSystem.Run    cp /opt/iphy/latest/egate_console.log ${log_path}
#
#Lock Cell
#    [Arguments]    ${cell_name}
#    Log To Console    Cell ${cell_name} Locked
#    Setup Admin
#    Block Cell    dist_name=${cell_name}
#    Sleep    30s    reason=wait for gnb ok
#    Teardown Admin
#
#Attach Multi SA CA UE And Do Traffic
#    ute_wtssim.Execute Egate Command    cmd=script file\=${WTS_multiUEscript} entry=run_SA_Internal_traffic(1,6,both,50,175,5)
#    ...    pass_regexp=SCellIndex 1 activated successfully at airphone    timeout=5min
#    Sleep    5s    reason=Wait for all ue info printed in egate console log.
#    ute_wtssim.Execute Egate Command    cmd=script file\=${WTS_multiUEscript} entry=monitor_multiue_traffic(1,6,2,both)
#    ...    pass_regexp=EGATE    timeout=5min
#    Sleep    5s    reason=Wait for all ue info printed in egate console log.
#
#Check UE Throughput For All UE
##    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=1-6 type=pdsch,pusch scell=0-31
##    ...    pass_regexp=EGATE    timeout=5min
#    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=1-6 type=pdsch,pusch scell=0-31
#    ...    sleep_time=1
#    Sleep    5s    reason=Wait for all ue info printed in egate console log.
#
#Set Power Class Cmd PC2A For UE 1
#    ute_wtssim.Execute Egate Command    cmd=phr_override_testmode_nr profile_id=1 pc_max=23
#    ...    sleep_time=1
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=phr_override action=activate profile_id=1 scell=0
#    ...    sleep_time=1
#    ute_wtssim.Execute Egate Command    cmd=phr_override_testmode_nr profile_id=2 pc_max=23
#    ...    sleep_time=1
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=phr_override action=activate profile_id=2 scell=1
#    ...    sleep_time=1
#
#Set Power Class Cmd PC2B For UE 2
#    [Documentation]    TDD = FDD  = 23dBM
#    ute_wtssim.Execute Egate Command    cmd=phr_override_testmode_nr profile_id=3 pc_max=23
#    ...    sleep_time=1
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=2 testmode=phr_override action=activate profile_id=3 scell=0
#    ...    sleep_time=1
#    ute_wtssim.Execute Egate Command    cmd=phr_override_testmode_nr profile_id=4 pc_max=26
#    ...    sleep_time=1
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=2 testmode=phr_override action=activate profile_id=4 scell=1
#    ...    sleep_time=1
#
#Check NumOfPRB On TDD Cell
#    [Arguments]    ${case_id}    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/C1602/ttitrace_pcsi.ini    output_ul.csv    ${csv_file_path}
#
#Check SRS Usage From Egate
#    Save Egate Log    log_path=${Egatelog_path}
#    ${Usage}=    Get SRS Usage
#    Should Be True    '${Usage}'=='codebook'
#
#Get SRS Usage
#    ${Usageregex}=    Set Variable    usage (?P<usage>\\S{1,10})\\S
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${Usage_list}=    String.Get Regexp Matches    ${content}    ${Usageregex}    usage
#    ${usage}=    Set Variable    @{Usage_list}[1]
#    [Return]    ${usage}
#
#Capture And Decode TTitrace
#    [Arguments]    ${log_id}=1    ${duration}=1
#    Log To Console     start ttitrace...
#    Start Ttitrace With Streaming Mode
#    Sleep    ${duration}s    reason=Wait for logs
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#    [Return]    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#
#Capture BIP
#    [Arguments]    ${log_id}=1    ${duration}=1
#    Log To Console     start bip...
#    Start Gnb BIP Log
#    Sleep    ${duration}s    reason=Wait for logs
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/${log_id}
#
#Convert BIP To CSV By MCShark For numOfPuschSymbols
#    [Arguments]    ${log_id}
#    ${filter}=    Set Variable    uldata_puschreceivereq
#    @{csv_title_list}=    Create List    UlData_puschReceiveReqGrant_t.numOfPuschSymbols
#    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${log_id}    5GBipL2L1_filtering_off*.pcap    ${True}
#    Convert BIP To CSV By MCShark   @{bip_names}    ${TEST_LOG_DIRECTORY}/${log_id}/numOfPuschSymbols.csv    ${filter}
#    ...    ${csv_title_list}
#    [Return]    ${TEST_LOG_DIRECTORY}/${log_id}/
#
#Attach SA CA UE and Get Throughput
#    [Arguments]    ${UE_ID}=3    ${dl_tp_set}=350    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
#    ...    ${A1_add}=${False}    ${A2_rel}=${False}
#    _Attach Muli SA CA UE Traffic And Setup PDU    ${UE_ID}    ${A1_add}
#    Set Power Class Cmd PC2A For UE 1
#    Set Power Class Cmd PC2B For UE 2
#    _Start Multi SA CA UE Traffic    ${UE_ID}    ${dl_tp_set}    ${ul_tp_set}
#    ${list_tp_all}=    _Get Multi SA CA UE Traffic    ${UE_ID}
##    _Stop Multi SA CA UE Traffic    ${UE_ID}
##    _Detach Multi SA CA UE    ${UE_ID}    ${A2_rel}
#    _Check Muti SA CA UE DL Throughput    ${dl_tp_threshold}    ${list_tp_all}
#    _Check Muti SA CA UE UL Throughput    ${ul_tp_threshold}    ${list_tp_all}
#    run keyword and ignore error    Check UE Throughput For All UE
#
#_Attach Muli SA CA UE Traffic And Setup PDU
#    [Arguments]    ${UE_ID}    ${A1_add}=${False}
#    @{ids} =    String.Split String    ${UE_ID}    -
#    FOR    ${UE_ID}    IN    @{ids}
#        SA 5G Attach    ue_id=${UE_ID}
#        SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#        SA CA 5G PDU Session Setup    ue_id=${UE_ID}    A1_add=${A1_add}
#    END
#
#_Start Multi SA CA UE Traffic
#    [Arguments]    ${UE_ID}    ${dl_tp_set}    ${ul_tp_set}
#    @{ids} =    String.Split String    ${UE_ID}    -
#    FOR    ${UE_ID}    IN    @{ids}
#        SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
#        SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    END
#    Sleep    5s    reason=Wait traffic stable
#
#_Get Multi SA CA UE Traffic
#    [Arguments]    ${UE_ID}
#    @{ids} =    String.Split String    ${UE_ID}    -
#    @{list_tp_all}=    Create List
#    FOR    ${UE_ID}    IN    @{ids}
#        ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
#        ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
#        ${pcell_dl}=    Wait Until Keyword Succeeds    3min    5s
#        ...    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#        ${scell_dl}=    Wait Until Keyword Succeeds    3min    10s
#        ...    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
#        ${pcell_ul}=    Wait Until Keyword Succeeds    3min    5s
#        ...    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#        ${scell_ul}=    Wait Until Keyword Succeeds    3min    10s
#        ...    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=1
#        &{dic_tp_ue}=    Create Dictionary    pcell_dl    ${pcell_dl}    scell_dl    ${scell_dl}
#        ...    pcell_ul    ${pcell_dl}    scell_ul    ${scell_dl}
#        Collections.Append To List    ${list_tp_all}    ${dic_tp_ue}
#    END
#    [Return]    ${list_tp_all}
#
#_Stop Multi SA CA UE Traffic
#    [Arguments]    ${UE_ID}
#    @{ids} =    String.Split String    ${UE_ID}    -
#    FOR    ${UE_ID}    IN    @{ids}
#        SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    END
#
#_Detach Multi SA CA UE
#    [Arguments]    ${UE_ID}    ${A2_rel}
#    @{ids} =    String.Split String    ${UE_ID}    -
#    FOR    ${UE_ID}    IN    @{ids}
#        Run Keyword If    ${A2_rel}    _Trigger A2 Scell Release    ${UE_ID}
#        SA 5G Detach    ue_id=${UE_ID}
#    END
#
#_Check Muti SA CA UE DL Throughput
#    [Arguments]    ${dl_tp_threshold}    ${list_tp_all}
#    FOR    ${dic_tp_ue}    IN    @{list_tp_all}
#        Should Be True    ${dic_tp_ue.pcell_dl}>${dl_tp_threshold} and ${dic_tp_ue.scell_dl}>${dl_tp_threshold}
#    END
#
#_Check Muti SA CA UE UL Throughput
#    [Arguments]    ${ul_tp_threshold}    ${list_tp_all}
#    FOR    ${dic_tp_ue}    IN    @{list_tp_all}
#        Should Be True    ${dic_tp_ue.pcell_ul}>${ul_tp_threshold} and ${dic_tp_ue.scell_ul}>${ul_tp_threshold}
#    END
