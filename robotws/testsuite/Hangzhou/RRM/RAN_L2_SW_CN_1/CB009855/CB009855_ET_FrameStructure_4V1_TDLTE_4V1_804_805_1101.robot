*** Settings ***
Suite Setup       Suite Setup Update GNB
Suite Teardown    Common Suite Teardown    debug
Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT
...               SBTS00    CN1_SQ6    CB009855
Resource          ./Resources/CB009855_resource.robot
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./../CUDU_L2/common_CA_DSS.robot

*** Variables ***
### Suite level ###                    
#${SWCONFIG_PARAM}                      0x590004=4;0x5900a8=1;0x58057a=4;0x58057b=4096;0x58057d=536870912
${SCF_PATH}                            ${CURDIR}/Config
${FULL_SCF_9855_1V4_TDLTE_1V4_MBWP}    Full_SCF_CB009855_A_4v1_tdlte_4v1_mBWP.xml
${WTS_CFG_3T3F_MBWP}                   basic_3T_3F_1v4_tdlte_mBWP.cfg
${WTS_LOCAL}                           ${CURDIR}/Resources/wts
${3T2F_IPHY_MBWP}                      ${CURDIR}/Resources/wts/iphy_1v4_tdlte_mBWP.xml
@{LOG_NAME_LIST}                       snapshot    btsLog
@{LOG_NAME_SUITE_SETUP_ASIK}           snapshot
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

#### B804 ###                          
${5CC_DL_TRF_804}                      600
${5CC_UL_TRF_804}                      50
@{5CC_UE_LIST_804}                     1    2    3    4
@{5CC_SCELL_PCI_1}                     50    51    54    55
@{5CC_SCELL_PCI_2}                     51    53    54    55
@{5CC_SCELL_PCI_3}                     50    51    54    55
@{5CC_SCELL_PCI_4}                     51    53    54    55
@{SCELL_PHYSICALID_LIST_804}           ${5CC_SCELL_PCI_1}    ${5CC_SCELL_PCI_2}    ${5CC_SCELL_PCI_3}    ${5CC_SCELL_PCI_4}
${CC_NUM}                              5
@{5CC_UE_LIST_804_3T2F}                2    4
@{5CC_UE_LIST_804_2T3F}                1    3
@{5CC_EXP_UL_TPUT_LIST_804_3T2F}       10    5
@{5CC_EXP_DL_TPUT_LIST_804_3T2F}       100    20    100    20    100
@{5CC_EXP_UL_TPUT_LIST_804_2T3F}       10    5
@{5CC_EXP_DL_TPUT_LIST_804_2T3F}       100    20    20    20    100
${ATTACH_DETACH_TIMES}                 2
#@{NONCA_UE_LIST_804}                  21    22    23    14    25    26
#${NONCA_DL_TRF_804}                   100
#${NONCA_UL_TRF_804}                   20
### B805 ###
${5CC_DL_TRF_805}                      600
${5CC_UL_TRF_805}                      30
${5CC_DL_TRF_5QI8_805}                 100
${5CC_UL_TRF_5QI8_805}                 30
${5CC_5QI8_QFI_805}                    2
${5CC_5QI8_ID_805}                     8
${5QI8_EXP_TPUT_DL_805}                1
${5QI8_EXP_TPUT_UL_805}                1

###B1101###
${FULL_SCF_9855_1V4_TDLTE_1V4_DSS}    Full_SCF_CB009855_A_4v1_tdlte_4v1_DSS.xml
${WTS_CFG_3T3F_DSS}                   basic_3T_3F_1v4_tdlte_DSS.cfg
${3T2F_IPHY_DSS}                      ${CURDIR}/Resources/wts/iphy_1v4_tdlte_DSS.xml
${ENB_GNB_SAMECELL_1}    1
${ENBID}                 2
${GNBID}                 1
${ANTP_NUM}              2 
${NORMAL_SUBFRAME}       1111110110-0111011110-1111110110-1111011111-0111111110-0111011111-1111011110-0111011111
${UL_PRB_LIST}           0,5|5,25|30,20
${DL_PRB_LIST_P1}    0:0,50+1:1,3|5,3+2:20,2+5:0,100+9:0,100+15:0,100+19:0,100+25:0,100+29:0,100+35:0,100+39:0,100+
${DL_PRB_LIST_P2}    45:0,100+49:0,100+55:0,100+59:0,100+65:0,100+69:0,100+75:0,100+79:0,100
@{5CC_UE_LIST_1101}                     1    2
@{5CC_SCELL_PCI_1}                     50    51    54    55
@{5CC_SCELL_PCI_2}                     51    53    54    55
@{SCELL_PHYSICALID_LIST_1101}           ${5CC_SCELL_PCI_1}    ${5CC_SCELL_PCI_2}
@{5CC_UE_LIST_1101_3T2F}                2
@{5CC_UE_LIST_1101_2T3F}                1
@{5CC_EXP_UL_TPUT_LIST_1101_3T2F}       20     20
@{5CC_EXP_DL_TPUT_LIST_1101_3T2F}       100    30    100    30    100
@{5CC_EXP_UL_TPUT_LIST_1101_2T3F}       20     5
@{5CC_EXP_DL_TPUT_LIST_1101_2T3F}       100    30    30    30    100
${5CC_DL_TRF_1101}                      1200
${5CC_UL_TRF_1101}                      100
${UPDATE_A2A_1_4_17}                    pip install ta-a2a==1.4.17
*** Test Cases ***
CB009855-ET-B804_Verify_3T2F_2T3F_Multiue_MultiBWP_Attach_detach
    [Documentation]
    ...                   cell1     cell2      cell3     cell4     cell5    cell6
    ...                   N71(F)    N25(F)     N41(T)    N41(T)    N25(F)    N77
    ...               PCI:  50       51         52        53        54       55
    ...    UE1/2T3F/L_BWP:  S1       S2         P                   S3       S4
    ...    UE3/2T3F/S_BWP:  S1       S2         P                   S3       S4
    ...    UE2/3T2F/L_BWP:           S1         P         S2        S3       S4
    ...    UE4/3T2F/S_BWP:           S1         P         S2        S3       S4
    [Tags]    Owner_naliu
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_9855_1V4_TDLTE_1V4_MBWP}    iphy_file=${3T2F_IPHY_MBWP}
    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_3T3F_MBWP}
    ...    AND    Suite Setup Start WTS And Check OnAir
    ...    AND    Common Test Setup
    SA Multi UE Attach With Scell Blind Addition    ${5CC_UE_LIST_804}    ${SCELL_PHYSICALID_LIST_804}    ${CC_NUM}
    SA Multi UE Start DL And UL Traffic    ${5CC_UE_LIST_804}    ${5CC_DL_TRF_804}    ${5CC_UL_TRF_804}
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5min    30sec    Check MultiUE MultiBWP Tput
    Run Keyword And Continue On Failure    Attach Detach And Check Tput    ${ATTACH_DETACH_TIMES}
    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}    iphy_file=${IPHY_TEST_BAK_FILE}
CB009855-ET-B805_Verify_3T2F_2T3F_Multiue_MultiBWP_Attach_detach
    [Tags]    Owner_naliu
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_9855_1V4_TDLTE_1V4_MBWP}    iphy_file=${3T2F_IPHY_MBWP}
    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_3T3F_MBWP}
    ...    AND    Suite Setup Start WTS And Check OnAir
    ...    AND    Common Test Setup
    SA Multi UE Attach With Scell Blind Addition    ${5CC_UE_LIST_804}    ${SCELL_PHYSICALID_LIST_804}    ${CC_NUM}
    SA Multi UE Start DL And UL Traffic    ${5CC_UE_LIST_804}    ${5CC_DL_TRF_805}    ${5CC_UL_TRF_805}
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5min    30sec    Check MultiUE MultiBWP Tput
    Run Keyword And Continue On Failure    MultiBearer Attach Detach And Check Tput    ${ATTACH_DETACH_TIMES}
    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}    iphy_file=${IPHY_TEST_BAK_FILE}
CB009855-ET-B1101_Verify_2T3F_5CC_UE_IWK_DSS_PH3
    [Documentation]
    ...            cell1(DSS)     cell2      cell3     cell4     cell5    cell6
    ...              N71(F)        N25(F)     N41(T)    N41(T)    N25(F)    N77
    ...         PCI:  50           51         52        53        54       55
    ...    UE1/2T3F:  S1           S2         P                   S3       S4
    ...    UE2/3T2F:               S1         P         S2        S3       S4 
    ...    CS1 Block on Slot#9 on cell50 for UE1: Event printed in ttitrace log with scheduling slot(K2)
    ...          'UlPreTdBlockUEData' with reson 'CS1_ULOVERLAPPINGSLOTFORTDDFDDULCA'
    [Tags]    Owner_naliu
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_9855_1V4_TDLTE_1V4_DSS}    iphy_file=${3T2F_IPHY_DSS}
#    ...           swconfig_param=${SWCONFIG_PARAM}
    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_3T3F_DSS}
    ...    AND    Suite Setup Start WTS And and load cfg file    enb_id=2    gnb_id=1
    ...    AND    Common Test Setup
    ...    AND    Run Cmd On PC    ${UPDATE_A2A_1_4_17}
    Configure CELL1 DSS    30    100    20    70
    SA Multi UE Attach With Scell Blind Addition    ${5CC_UE_LIST_1101}    ${SCELL_PHYSICALID_LIST_1101}    ${CC_NUM}
    SA Multi UE Start DL And UL Traffic    ${5CC_UE_LIST_1101}    ${5CC_DL_TRF_1101}    ${5CC_UL_TRF_1101}
    Run Keyword And Continue On Failure    Check DSS UE Tput AND Bler
    [Teardown]      Common Test Teardown

*** Keywords ***
Configure CELL1 DSS
    [Arguments]    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${minul_dss_ratio}    ${maxul_dss_ratio}
    Setup X2 Connection    ${ENBID}    ${GNBID}
    Setup XP LINK    ${ENBID}    ${GNBID}
    ute_wtssim.Execute Egate Command    cmd=enb_disp id=${ENBID} type=xp_info
    Enable DSS DMS3 Feature On    ${ENBID}
    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${ENB_GNB_SAMECELL_1}    ${ANTP_NUM}
    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${ENB_GNB_SAMECELL_1}
    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${ENB_GNB_SAMECELL_1}
    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${ENB_GNB_SAMECELL_1}    DL
    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${ENB_GNB_SAMECELL_1}
    ${DL_PRB_LIST}    catenate    SEPARATOR=    ${DL_PRB_LIST_P1}    ${DL_PRB_LIST_P2}
    Cell Allocation    ${NORMAL_SUBFRAME}    ${UL_PRB_LIST}    ${ENBID}    ${GNBID}    ${ENB_GNB_SAMECELL_1}    ${DL_PRB_LIST}
    common_setup_teardown.UE SIB Decoding Should Be Successful
    Sleep    10s    reason=waiting for SIB for all cells
Attach NonCA UE And Trf
    SA Multi NonCA UE Attach    ${NONCA_UE_LIST_804}
    SA Multi UE Start DL And UL Traffic    ${NONCA_UE_LIST_804}    ${NONCA_DL_TRF_804}    ${NONCA_UL_TRF_804}
    Display Multi UE Throughput    21-26
Add NonGBR Bearer And Start DL UL Traffic
    [Arguments]    ${ue_id_list}    ${dl_trf}    ${ul_trf}    ${qfi_id}    ${5qi_id}
    FOR    ${UE_ID}    IN    @{ue_id_list}
        Log To Console    start 5QI-${5qi_id} Setup for UE${ue_id}...
        ${command}    Set Variable    ue_pdu_session_modify ue\=${UE_ID} pdu\=1 qosflows_to_add\=${qfi_id} by\=amf
        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
        ...    ${command}
        ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
        ...    timeout=1minutes
        ${output}    String.Get Lines Matching Regexp    ${output}
        ...    Added QosFlow with QFI:${qfi_id} 5QI:${5qi_id} SEID:${ue_id_list}partial_match=${true}
        Log To Console    setup 5QI-${5qi_id} success
        Sleep    1s    reason=wait for bearer add complete
        Start DL Traffic For Dedicated Bearer    ${UE_ID}    ${dl_trf}    ${qfi_id}
        Start UL Traffic For Dedicated Bearer    ${UE_ID}    ${ul_trf}    ${qfi_id}
    END

Start DL Traffic For Dedicated Bearer
    [Arguments]    ${ue_id}    ${mbps}    ${qfi_id}    ${pdu_id}=1    ${trf_id}=1
    [Documentation]    This keyword is to start single UE big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
        ${tmp_trf_id}    Evaluate    ${trf_id}+${t_time}-1
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi=${qfi_id} dir=dl mbps\=175 trf_id\=${tmp_trf_id}
        Log To Console    \nUE${ue_id}_qfi_${qfi_id} Start DL 175M Traffic for trf_id=${tmp_trf_id}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    ${last_trf_id}    Evaluate    ${trf_id}+${dl_times}
    Run Keyword If    '${last_mbps}'!='0'    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi=${qfi_id} dir=dl mbps\=${last_mbps} trf_id\=${last_trf_id}
    Run Keyword If    '${last_mbps}'!='0'    Log To Console    \nUE${ue_id}_qfi_${qfi_id} Start DL ${last_mbps}M Traffic for trf_id=${last_trf_id}
Start UL Traffic For Dedicated Bearer
    [Arguments]    ${ue_id}    ${mbps}    ${qfi_id}    ${pdu_id}=1    ${trf_id}=1
    [Documentation]    This keyword is to start single UE big dl udp traffic which more than 175.
    ${ul_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${ul_times}+1
        ${tmp_trf_id}    Evaluate    ${trf_id}+${t_time}-1
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi=${qfi_id} dir=ul mbps\=175 trf_id\=${tmp_trf_id}
        Log To Console    \nUE${ue_id}_qfi_${qfi_id} Start UL 175M Traffic for trf_id=${tmp_trf_id}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${ul_times}
    ${last_trf_id}    Evaluate    ${trf_id}+${ul_times}
    Run Keyword If    '${last_mbps}'!='0'    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi=${qfi_id} dir=ul mbps\=${last_mbps} trf_id\=${last_trf_id}
    Run Keyword If    '${last_mbps}'!='0'    Log To Console     \nUE${ue_id}_qfi_${qfi_id} Start UL ${last_mbps}M Traffic for trf_id=${last_trf_id}
Dedicated Bearer Add And Tput Check
    [Arguments]    ${ue_id_list}
    Sleep    30s    reason=waiting UE is table
    Add NonGBR Bearer And Start DL UL Traffic    ${5CC_UE_LIST_804}    ${5CC_DL_TRF_5QI8_805}    ${5CC_UL_TRF_5QI8_805}
    ...    ${5CC_5QI8_QFI_805}    ${5CC_5QI8_ID_805}
    Sleep    10s    reason=waiting Trff is tableConsole
    Run Keyword And Continue On Failure    Check 5QI8 DLUL Tput    ${ue_id_list}

Check 5QI8 DLUL Tput
    [Arguments]    ${ue_id_list}
    FOR    ${ue_id}    IN    @{ue_id_list}
        Wait Until Keyword Succeeds    2min    10sec    SA UE Check Throughput    ${ue_id}        ${5QI8_EXP_TPUT_DL_805}
    ...    ${5QI8_EXP_TPUT_UL_805}    ${5CC_5QI8_QFI_805}
    END
Attach Detach
    [Arguments]    ${times}
    FOR    ${index}    IN RANGE    1    ${times}+1
    Log To Console    AttachDetach_${index}
    SA Multi UE Detach    ${5CC_UE_LIST_804}
    Sleep    2s    reason=wait for ue detach
    SA Multi UE Attach With Scell Blind Addition    ${5CC_UE_LIST_804}    ${SCELL_PHYSICALID_LIST_804}    ${CC_NUM}
    SA Multi UE Start DL And UL Traffic    ${5CC_UE_LIST_804}    ${5CC_DL_TRF_804}    ${5CC_UL_TRF_804}
    END
Attach Detach And Check Tput
    [Arguments]    ${times}
    Attach Detach    ${times}
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    10min    30sec    Check MultiUE MultiBWP Tput
    Capture Tti To Check FDM And Bler

MultiBearer Attach Detach And Check Tput
    [Arguments]    ${times}
    Dedicated Bearer Add And Tput Check    ${5CC_UE_LIST_804}
    Attach Detach    ${times}
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5min    30sec    Check MultiUE MultiBWP Tput
    Capture Tti To Check FDM And Bler
Check MultiUE MultiBWP Tput
    Sleep    5s    reason=wait traffic is stable
    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${5CC_UE_LIST_804_3T2F}    ${5CC_EXP_UL_TPUT_LIST_804_3T2F}
    ...    ${5CC_EXP_DL_TPUT_LIST_804_3T2F}    ${CC_NUM}
    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${5CC_UE_LIST_804_2T3F}    ${5CC_EXP_UL_TPUT_LIST_804_2T3F}
    ...    ${5CC_EXP_DL_TPUT_LIST_804_2T3F}    ${CC_NUM}

Get DLCA SCell L1 Average Throughput
    [Arguments]    ${ue_id}    ${dl_cc_num}
    [Documentation]    This keyword is to get Pcell/Scell Average throughput,1Mbps=1000Kbps
    ...    The unit of return throughput is Mbps.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id |
    ...    | ${dl_cc_num} | Yes | 2/3/4...|
    ...
    ...    | Examples: |
    ...    | ${ul_scell_tput} | Get ULCA SCell L1 Average Throughput | 1 | 4 |
    ...
    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=pdsch scell\=1-${dl_cc_num}
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${cell_tp}=    Evaluate    sum(map(float,${avg_tp_list}))
    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    ...    '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    ...    ${cell_tp}
    [Return]    ${cell_tput_Mbps}

Capture Ttitrace And Check
    Capture Convert Format Ttitrace With Streaming Mode    3s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming2/
    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_B${/}CB009855_1602_Tti_NackRatio.ini
    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming2
    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_B${/}CB009855_1602_Tti_ULMut.ini
    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming2

Check DL UL Bler
    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis
    ...    ${CURDIR}${/}A2A/CB009855_B${/}CB009855_1602_Tti_NackRatio.ini
    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming1

Check DL UL FDM4
    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis
    ...    ${CURDIR}${/}A2A/CB009855_B${/}CB009855_804_FDM.ini
    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming1

Capture Tti To Check FDM And Bler
    Capture Convert Format Ttitrace With Streaming Mode    1s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming1/
    Check DL UL Bler
    Check DL UL FDM4
Check DSS UE Tput AND Bler
    Sleep    5s    reason=wait traffic is stable
    Run Keyword And Continue On Failure    Check 3T2F Tput
    Run Keyword And Continue On Failure    Check 2T3F Tput
    Capture Convert Format Ttitrace With Streaming Mode    1s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming1/
    Check DL UL Bler
    Check DSS Scheduling On Slots059
Check 3T2F Tput
    Wait Until Keyword Succeeds    5min    20sec    Check Multi UE DLCA And 2CCULCA L1 Cell Tput
    ...    ${5CC_UE_LIST_1101_3T2F}    ${5CC_EXP_UL_TPUT_LIST_1101_3T2F}    ${5CC_EXP_DL_TPUT_LIST_1101_3T2F}
    ...    ${CC_NUM}
Check 2T3F Tput
    Wait Until Keyword Succeeds    5min    20sec    Check Multi UE DLCA And 2CCULCA L1 Cell Tput
    ...    ${5CC_UE_LIST_1101_2T3F}    ${5CC_EXP_UL_TPUT_LIST_1101_2T3F}    ${5CC_EXP_DL_TPUT_LIST_1101_2T3F}
    ...    ${CC_NUM}
Check DSS Scheduling On Slots059
    ${UE1_CRNTI}=    Get Crnti From Egate Log    ${5CC_UE_LIST_1101_2T3F}
    Set Suite Variable    ${UE1_CRNTI}
    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis
    ...    ${CURDIR}${/}A2A/CB009855_B${/}CB009855_1101_DSS.ini
    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming1
