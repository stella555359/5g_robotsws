*** Settings ***
Documentation    ...
#Resource    ./keywords_CB008532_common_AP.robot
#Resource    ../CUDU_L2/common_setup_teardown.robot
#Resource    ../CUDU_L2/common_CA.robot
#Suite Setup    Common Suite Setup
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS00    SBTS23R1     CN1_SQ
#...               RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${REAL_GNB_ID}                 2
#${SIM_GNB_ID}                  3
#${SIM_CELL_ID}                 1
#${SIM_CELL_PCI}                49
#${D06_HO_3CC_SCELLS}           ('1', '50', '25'), ('2', '51', '66'), ('3', '54', '71')
#${SCF_60_60_20_10_5_D}         SCF_2T3F_60M_60M_20M_10M_5M.xml
#${SCF_60_60_20_10_5_D06}       SCF_60M_60M_20M_10M_5M_D06.xml
#${SCF_60_60_20_10_5_D18}       SCF_2T3F_60M_60M_20M_10M_5M_D18.xml
#${IPHY_60_60_20_10_5_D}        iphy_2T3F_60M_60M_20M_10M_5M.xml
#${IPHY_60_60_20_10_5_D06}      iphy_60M_60M_20M_10M_5M_D06.xml
#${WTS_CFG_60_60_20_10_5_D}     wts_cfg_ASIB_ABIO_60M_60M_20M_10M_5M.cfg
#${WTS_CFG_60_60_20_10_5_D18}    wts_cfg_ASIB_ABIO_60M_60M_20M_10M_5M_D18.cfg
#${WTS_CFG_60_60_20_10_5_D06}    wts_cfg_ASIB_ABIO_60M_60M_20M_10M_5M_D06.cfg
#${SCF_20_20_20_10_5_D12}       SCF_2T3F_20M_20M_20M_10M_5M_D12.xml
#${WTS_CFG_20_20_20_10_5_D12}    wts_cfg_ASIB_ABIO_20M_20M_20M_10M_5M_D12.cfg
#${IPHY_20_20_20_10_5_D12}        iphy_2T3F_20M_20M_20M_10M_5M_D12.xml
#${SCF_20_20_20_10_5_D}    SCF_2T3F_20M_20M_20M_10M_5M.xml
#${IPHY_20_20_20_10_5_D}    iphy_2T3F_20_20_20_10_5_D.xml
#${WTS_CFG_20_20_20_10_5_D}    wts_cfg_ASIB_ABIO_20M_20M_20M_10M_5M.cfg
#${gNB_swconfig}               swconfig_gnb.txt
#
#${Egatelog_path}    ${CURDIR}
#
#*** Test Cases ***
#
#CB008532_ET_D23_Sell_change_4CC_CA_T_F_F_F_to_T_T_to_T
#    [Tags]     Owner_Junying    case_D023
#    [Setup]    Setup TL For Each Case    ${SCF_20_20_20_10_5_D}    ${IPHY_20_20_20_10_5_D}    ${WTS_CFG_20_20_20_10_5_D}    ${gNB_swconfig}
#    Clear PM Counter Reports
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/CA
#    Setup X2 Connection
#    SA 5G Attach    ue_id=1
#    SA 5G PDU Session Setup    ue_id=1
#    Start UDP DL Traffic By Iperf    400
#    Start UDP UL Traffic By Iperf    50
#
#    Log To Console    \nAdd 3 scells(F),1T+3F...\n
#    Trigger A1 Event    1    100
#    Log To Console    \nCheck UE is configured 4CC,1T+3F\n
#    Save Egate Log    log_path=${Egatelog_path}
#    ${Scellindex_list}    Get Scellindex
#    Check 4CC Cell 1T3F    ${Scellindex_list}
#
#    Log To Console    \nScell change form 3F to 1T,1T+1T\n
#    Trigger A1 Event    6    120
#    Log To Console    \nCheck scell change activated successfully,Ue is configured 2cc,1T+1F...\n
#    Save Egate Log    log_path=${Egatelog_path}
#    ${Scellindex_list}    Get Scellindex
#    Check 4CC Cell Contain TDD    ${Scellindex_list}
#
#    Log To Console    \nRelease scell(T),UE is confirure 1cc,1T...\n
#    Trigger A2 Release    UE_ID=1    meas_id=7    SCellIndex=4
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    sleep    5s
#    Save Egate Log    log_path=${Egatelog_path}
#    ${sCellToReleaseList}    Get sCellToReleaseList
#    Log To Console    \nScellindex_list is ${sCellToReleaseList}\n
#    List Should Contain Value    ${sCellToReleaseList}    4
#
#    Log To Console    \nTrigger 3 scells(F) addition again,ue is confirured 4cc 1T+3F...\n
#    Trigger A1 Event    8    100
#    Log To Console    \nCheck UE is configured 4CC,1T+3F again\n
#    Save Egate Log    log_path=${Egatelog_path}
#    ${Scellindex_list}    Get Scellindex
#    Log To Console    \nScellindex_list is ${Scellindex_list}\n
#    Check 4CC Cell 1T3F Again    ${Scellindex_list}
#
#    Stop DL UL Traffic Of Iperf
#    Log To Console    \nCheck counter...\n
#    Wait Until Keyword Succeeds    10min    5min    Check PM Counter For CAD23
#    Log To Console    \nCB008532_ET_D23,the end.\n
#
#
#
##CB008532_ET_D04_A1_measurement_based_SCell_addition_of_4CC_CA_1T_3F
##    [Tags]     Owner_Yulei    case_D004
##    [Setup]    Setup TL For Each Case    ${SCF_60_60_20_10_5_D}    ${IPHY_60_60_20_10_5_D}    ${WTS_CFG_60_60_20_10_5_D}  ${gNB_swconfig}
##    Attach SA UE1 Before A1    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
##    Save Egate Log    log_path=${Egatelog_path}
##    ${measIdA1}=    Get MeasID A1
##    Trigger T+FFF A1 Scell Addition    UE_ID=1    meas_id=${measIdA1}
##    Save Egate Log    log_path=${Egatelog_path}
##    ${Scellindex_list}    Get Scellindex
##    Check 4CC Cell 1T3F    ${Scellindex_list}
##
##CB008532_ET_D05_number_of_SRS_port_reconfigured
##    [Tags]     Owner_Yulei    case_D005
##    [Setup]    Setup TL For CaseD005    ${SCF_60_60_20_10_5_D}    ${IPHY_60_60_20_10_5_D}    ${WTS_CFG_60_60_20_10_5_D}   ${gNB_swconfig}
##    Attach SA UE1 Before A1    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
##    Save Egate Log    log_path=${Egatelog_path}
##    ${measIdA1}=    Get MeasID A1
##    ${SRSport_list}=    Get SRSport In Egatelog Before A1ScellAddition
##    Check SRSport Before A1ScellAddition    ${SRSport_list}
##    Trigger 2T+2F A1 Scell Addition    UE_ID=1    meas_id=${measIdA1}
##    Save Egate Log    log_path=${Egatelog_path}
##    ${SRSport_list}=    Get SRSport In Egatelog After A1ScellAddition
##    Check SRSport After A1ScellAddition    ${SRSport_list}
##
##CB008532_ET_D06_handover_measurement_for_target_PCell_is_met_for_SCell_addition
##    [Tags]     Owner_lilidong    case_D006
##    [Setup]    Setup TL For CaseD006    ${SCF_60_60_20_10_5_D06}    ${IPHY_60_60_20_10_5_D06}    ${WTS_CFG_60_60_20_10_5_D06}   ${gNB_swconfig}
##    Configure UE History Info For HO    ${REAL_GNB_ID}    ${PCELL_ID}    ${SIM_GNB_ID}    ${SIM_CELL_ID}
##    Attach SA UE1 Before A1    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
##    Intra-frequency HO To Sim GNB For UE1    ${SIM_CELL_PCI}
##    Save Egate Log    log_path=${Egatelog_path}
##    Sleep    10s
##    Intra-frequency HO To Real GNB For UE1    ${PCELL_PCI}    ${REAL_GNB_ID}
##    Save Egate Log    log_path=${Egatelog_path}
##    ${scell_act_nums}=    Create List    1    1    1
##    Check Scell Activition Info    4    ${scell_act_nums}
##    Get And Check Scell Infos    ${D06_HO_3CC_SCELLS}
##
##CB008532_ET_D10_A2_SCell_release_FDD_and_TDD_RSRP_thresholds_for_SCell_addition_with_different_values
##    [Tags]     Owner_Yulei    case_D010
##    [Setup]    Setup TL For Each Case    ${SCF_60_60_20_10_5_D}    ${IPHY_60_60_20_10_5_D}    ${WTS_CFG_60_60_20_10_5_D}    ${gNB_swconfig}
##    Attach SA UE1 Before A1    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
##    Save Egate Log    log_path=${Egatelog_path}
##    ${measIdA1}=    Get MeasID A1
##    Trigger 2T+2F A1 Scell Addition    UE_ID=1    meas_id=${measIdA1}
##    Trigger TDD A2 Release    UE_ID=1    meas_id=4
##    Save Egate Log    log_path=${Egatelog_path}
##    ${A1Threshold_list}=    Get A1Threshold After TDDcell Release
##    Check A1Threshold After TDDcell Release    ${A1Threshold_list}
##    Trigger FDD1 A2 Release    UE_ID=1    meas_id=3
##    Trigger FDD2 A2 Release    UE_ID=1    meas_id=2
##    Save Egate Log    log_path=${Egatelog_path}
##    ${A1Threshold_list}=    Get A1Threshold After FDDcell AllRelease
##    Check A1Threshold After FDDcell AllRelease    ${A1Threshold_list}
##
##CB008532_ET_D12_a2BasedPCellSwitchPriority_same_value
##    [Tags]     Owner_Abby    case_D012
##    [Setup]    Setup TL For Each Case    ${SCF_20_20_20_10_5_D12}    ${IPHY_20_20_20_10_5_D12}    ${WTS_CFG_20_20_20_10_5_D12}   ${gNB_swconfig}
##    Clear PM Counter Reports
##    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/CA
##    Attach SA UE1 Before A1    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
##    Save Egate Log    log_path=${Egatelog_path}
##    ${measIdA1}=    Get MeasID A1
##    ${output1}    Trigger A1 Event    meas_id=${measIdA1}   srsrp=120
##    Check Activated Cell Id    ${output1}    1    50
##    Check Activated Cell Id    ${output1}    2    51
##    Check Activated Cell Id    ${output1}    3    53
##    Sleep    30s    reason=wait for A1 handling
##    Trigger A2 Event    5    40    66    115    115    115    115    70    70    51
##    Wait Until Keyword Succeeds    20min    3min    Check Counters For Pcell Change
##    ${output2}    Trigger A1 Event    meas_id=7   srsrp=100
##    Check Activated Cell Id    ${output2}    1    50
##    Check Activated Cell Id    ${output2}    2    54
##
##CB008532_ET_D18_a2BasedPCellSwitchPriority_set_lower_value_for_cell2
##    [Tags]     Owner_Susie    case_D018
##    [Setup]    Setup TL For Each Case    ${SCF_60_60_20_10_5_D18}    ${IPHY_60_60_20_10_5_D}    ${WTS_CFG_60_60_20_10_5_D18}   ${gNB_swconfig}
##    Clear PM Counter Reports
##    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/CA
##    Attach SA UE1 Before A1    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
##    Save Egate Log    log_path=${Egatelog_path}
##    ${measIdA1}=    Get MeasID A1
##    ${output1}    Trigger A1 Event    meas_id=${measIdA1}   srsrp=101
##    Check Activated Cell Id    ${output1}    1    50
##    Check Activated Cell Id    ${output1}    2    51
##    Check Activated Cell Id    ${output1}    3    54
##    Sleep    30s    reason=wait for A1 handling
##    Trigger A2 Event    3    40    66    115    115    100    100    115    115    51
##    Wait Until Keyword Succeeds    20min    3min    Check Counters For Pcell Change
##    ${output2}    Trigger A1 Event    meas_id=4   srsrp=100
##    Check Activated Cell Id    ${output2}    1    50
#
#*** Keywords ***
#
#Change UE Capacity for N2N1
#    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG_60_60_20_10_5_D}
#    @{old_params_list}    Create List    ue_nr_capabilities=[0-9a-zA-Z]+
#    ${UE_CAPACITY_n2n1}=    Catenate    SEPARATOR=    ue_nr_capabilities=E9A09000575F5A13160003C12016093170019C3D0304D90
#    ...    61CF9863CA160704C020311C04EE3614606B04610D04083A40236B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C
#    ...    00FFC0070005F0002400702A0D883AC1184341020F1008CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB
#    ...    0000001200381546C4DD608C21A081074804616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF800E007FE0004800E
#    ...    0541B11B582308682041E201195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000002400702A0D831AC
#    ...    1184341020F1008CAD931562439F11C7B027C62471E439F51CF9863CA1607038784FFF800003FFE00000120038024F0F1340038820000
#    ...    042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13400388C0000042C0AC5C46000E208007
#    ...    10400002858158B89A001C41000E140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E2080
#    ...    0710400001058158B89A001C41000E230000020B02B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E23
#    ...    0000030B02B1F0A0003850001C18000E208000070B02B1F0A0003830001C41000E230000080B02B1F0A0003850001C18000E230000070
#    ...    B02B1F0A0003850001C41000E230000070B020120234028809B010600C02ADD09428913639F0E14489B1CF870A244D8E7C3851226C73E
#    ...    1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081
#    ...    B1CF811204081B1CF810A040D8E7C0850206C73E0428103639F0214081B1CF8001B1218C6318C6318C6318C6318C1E81E00F000A07030
#    ...    0E0600A80E000C0480080C07C120040000000200000401000000008000010040000100200000C01000008008000050040020080200800
#    ...    006004000038020010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15A
#    ...    CA5AC99AC05AC0DAC04AC08AC1DA0702000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA
#    ...    48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B29202000042CA480669555D2AAAA55
#    ...    174AA2A82C55058AA0D154A62A93455018AA051549AAA83C5030BC04A8140A05028140A05028140A05028140A05028140A001010100C0
#    ...    18040080108080100402018030804008010100C018040300608080600C02018030804008010100C018040080110080600C02018030080
#    ...    600C101002008040080218080101E02004078080600C02018030C04008010100C01804030060100C0186A87C0004080C10181C282C303
#    ...    44044484C5060646C70747C8494989CA0A4A8B4BD05060B4
#    @{new_params_list}    Create List    ${UE_CAPACITY_n2n1}
#    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}
#
#Setup TL For CaseD005
#    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}    ${gNB_swconfig}
#    Verify Coam Site Is Ready
#    Common Test Setup 2
#    Send Swconfig for GNB    ${LOCAL_CFG_DIR}/${gNB_swconfig}
#    ###Send Swconfig for AP     ${LOCAL_CFG_DIR}/${ap_swconfig}
#    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
#    ###Configure Gnb With Full SCF For Local TL    ${scf_file}
#    Full Commission With SCF File    ${scf_file}
#    #Full Commission With SCF File For UTE    ${scf_file}
#    Sleep     60s     \nFor Site reset
#    Verify Coam Site Is Ready With New Cfg
#    Set WTS Files Name For Each Cases    ${wts_cfg_name}
#    Change UE Capacity for N2N1
#    Start UTE WTS And Check Cell Setup    ${wts_cfg_name}
#
#Start GNB Syslog
#    [Arguments]    ${log_dir}
#    Run Keyword And Ignore Error    ute_syslog.Stop Syslog    alias=${GNB_SYSLOG.alias}
#    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${log_dir}
#    ...    log_name=${GNB_SYSLOG.log_name}    ip=${GNB_SYSLOG.ip}    alias=${GNB_SYSLOG.alias}
#
#Stop And Collect Syslog
#    [Arguments]    ${log_dir}
#    ute_syslog.Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=False    destination=${log_dir}/Gnb_syslog.tar.gz
#    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    tar -xzvf ${log_dir}/Gnb_syslog.tar.gz
#    Set Test Variable    ${btslog}    ${CURDIR}/${output}
#
#Setup TL For CaseD006
#    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}   ${gNB_swconfig}
#    Verify Coam Site Is Ready
#    Common Test Setup 2
#   Send Swconfig for GNB    ${LOCAL_CFG_DIR}/${gNB_swconfig}
#    ###Send Swconfig for AP     ${LOCAL_CFG_DIR}/${ap_swconfig}
#    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
#    #Configure Gnb With Full SCF For Local TL    ${scf_file}
#    Full Commission With SCF File    ${scf_file}
#    #Full Commission With SCF File For UTE    ${scf_file}
#    Sleep     60s     \nFor Site reset
#    Verify Coam Site Is Ready With New Cfg
#    Set WTS Files Name For Each Cases    ${wts_cfg_name}
#    Configure VM Interface For HO    ${GNB2_XN_ADDR}    ${GNB2_NG_ADDR}    ${PROXY_SERVER2_IP}
#    Start UTE WTS And Check Cell Setup    ${wts_cfg_name}
