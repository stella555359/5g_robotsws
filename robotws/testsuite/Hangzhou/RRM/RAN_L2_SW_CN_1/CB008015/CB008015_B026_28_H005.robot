*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Make TL Ready
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup For Cases Combination
#Test Teardown     Common Test Teardown For Cases Combination
#Resource          ./../CUDU_L2/common_dss_command.robot
#Resource          ./resources/CB008015_lib.robot
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G    RAN_5G_TDD    Owner_qiaren
#...               CN1_SQ6    CB008015    SBTS00    SBTS23R1    SBTS22R4
#
#*** Variables ***
#${SCF_PATH}                ${CURDIR}/config/
#${FULL_SCFC}               8015_full_scfc.xml
#${IPHY_XML}                ${CURDIR}/config/wts/iphy_4F_2T.xml
#${LOCAL_WTS_DIR}           ${CURDIR}/config/wts
#${WTS_DIR}                 /opt/wts/latest/
#${WTS_CFG}                  basic_8015_DSS.cfg
#${WTS_AP_XML}               airphone.xml
#${SA_UE}                   1,6
#${REORDERING_WINDOW_SIZE}    500
#${REORDERING_TIMER}          300
#${UE_NUM}                  8
#
#*** Test Cases ***
#CB008015_B_026_Blind_CA_10MHz_DSS_4UE_SA
#    Online Change MaxNumOfSCellAlloc For Cell6
#    Four SA CA UE Attach And Scell Check
#    Start DL UL Traffic For Ues
#    Wait Until Keyword Succeeds    1min    5s    Check Pcell And Scell Throughput For 4UE
#    Wait Until Keyword Succeeds    1min    5s    Check SA UE Throughput For 4UE
#    Run Keyword And Ignore Error     Start And Stop Tti Trace
#
#CB008015_B_028_Blind_CA_10MHz_DSS_Prbblanklow_SA
#    Online Change MaxNumOfSCellAlloc For Cell6
#    Four SA CA UE Attach And Scell Check
#    Start DL UL Traffic For Ues
#    Wait Until Keyword Succeeds    1min    5s    Check Pcell And Scell Throughput For 4UE
#    Wait Until Keyword Succeeds    1min    5s    Check SA UE Throughput For 4UE
#    Run Keyword And Ignore Error     Start And Stop Tti Trace
#
#CB008015_H_005_Enhance_FDM_20MHz_ABIO
#    SA Attach   sa_ue_id=3
#    Check SA Scell PhysicalID With UE ID     3     52    1
#    Start SA DL Big Traffic Internal    ue_id=3     mbps=400
#    SA Start UL Traffic Internal    3    1    5
#    Multi NonCA UE Attach And Do Traffic    ${UE_NUM}
#    Check UE Pcell Scell TP On Target   ue_id=3     dir=dl    cell_type=pcell    scell_index=0    target_tp=10
#    Check UE Pcell Scell TP On Target  ue_id=3     dir=dl    cell_type=scell    scell_index=1    target_tp=320
#    #Start And Stop Tti Trace
#    #Check DL Per Slot Ue Numbers    ${TEST_LOG_DIRECTORY}    ${UE_NUM}
#    #Check UL Per Slot Ue Numbers    ${TEST_LOG_DIRECTORY}    ${UE_NUM}
#    Wait Until Keyword Succeeds    10min    1min    Verify Two PM Counters
#
#
#*** Keywords ***
#Suite Setup Make TL Ready
#    Suite Setup Update GNB     scf_file=${FULL_SCFC}       iphy_file=${IPHY_XML}
#    #Suite Setup Update GNB
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#
#
#Start DL UL Traffic For Ues
#    Start SA DL Big Traffic Internal    ue_id=5    mbps=300
#    SA Start UL Traffic Internal    ue_id=5    pdu_id=1    mbps=50    trf_id=1
#    Start SA DL Big Traffic Internal    ue_id=11    mbps=300
#    SA Start UL Traffic Internal    ue_id=11    pdu_id=1    mbps=50    trf_id=1
#    @{sa_ue_list}    Split String    ${SA_UE}    ,
#    Start Multi SA UE Traffic       @{sa_ue_list}     trf_type=dl    mbps=150
#    SA Start UL Traffic Internal    ue_id=${SA_UE}    pdu_id=1    mbps=50    trf_id=1
#
#Start And Stop Tti Trace
#    Start GNB TTI Trace
#    Sleep    1s    reason=get *L2TtiTrace_EventsSnapshot
#    Stop And Decode GNB TTI Trace    ${TEST_LOG_DIRECTORY}
#
#Online Change MaxNumOfSCellAlloc For Cell6
#    Log To Console    Online change maxNumOfSCellAlloc for cell6...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-6    maxNumOfSCellAlloc    1
#
#Four SA CA UE Attach And Scell Check
#    [Documentation]    This keyword is to attach 4 CA UE:
#    ...    Fdd cell1:20MHz DSS, Tdd cell3:60MHz, Tdd cell6 60MHz
#    ...    UE1 Fdd cell1+Tdd cell3
#    ...    UE5 Tdd cell3+Tdd cell6
#    ...    UE6 Tdd cell3+Fdd cell1
#    ...    UE11 Tdd cell6+Tdd cell3
#    SA Attach   sa_ue_id=5
#    Wait Until Keyword Succeeds    5s    1s    Check SA Scell PhysicalID With UE ID     ue_id=5     scell_physicalid=55    scell_index=1
#    SA Attach   sa_ue_id=11
#    Wait Until Keyword Succeeds    5s    1s    Check SA Scell PhysicalID With UE ID     ue_id=11     scell_physicalid=52    scell_index=1
#    SA Attach   sa_ue_id=1
#    Wait Until Keyword Succeeds    5s    1s    Check SA Scell PhysicalID With UE ID     ue_id=1     scell_physicalid=52    scell_index=1
#    SA Attach   sa_ue_id=6
#    Wait Until Keyword Succeeds    5s    1s    Check SA Scell PhysicalID With UE ID     ue_id=6     scell_physicalid=50    scell_index=1
#
#Check Pcell And Scell Throughput For 4UE
#    Check UE Pcell Scell TP On Target    ue_id=5    dir=dl    cell_type=pcell    scell_index=0    target_tp=70
#    Check UE Pcell Scell TP On Target    ue_id=5    dir=dl    cell_type=scell    scell_index=1    target_tp=160
#    Check UE Pcell Scell TP On Target    ue_id=11    dir=dl    cell_type=pcell    scell_index=0    target_tp=160
#    Check UE Pcell Scell TP On Target    ue_id=11    dir=dl    cell_type=scell    scell_index=1    target_tp=70
#    Check UE Pcell Scell TP On Target    ue_id=1    dir=dl    cell_type=pcell    scell_index=0    target_tp=5
#    Check UE Pcell Scell TP On Target    ue_id=1    dir=dl    cell_type=scell    scell_index=1    target_tp=70
#    Check UE Pcell Scell TP On Target    ue_id=6    dir=dl    cell_type=pcell    scell_index=0    target_tp=70
#    Check UE Pcell Scell TP On Target    ue_id=6   dir=dl    cell_type=scell    scell_index=1    target_tp=5
#    Check Fdd Cell TP    target_tp=22
#
#Check SA UE Throughput For 4UE
#    SA UE Check Throughput    5    130    10
#    SA UE Check Throughput    11    130    40
#    SA UE Check Throughput    1    40    10
#    SA UE Check Throughput    6    50    10
#
#Check Fdd Cell TP
#    [Arguments]    ${target_tp}
#    ${as_pcelltp}    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=pcell    scell_index=0
#    ${as_scelltp}    Get CA Cell Average Throughput    ue_id=6    dir=dl    cell_type=scell    scell_index=1
#    ${cell_tp}    Evaluate    ${as_pcelltp}+${as_scelltp}
#    ${tp_delta}    Evaluate    ${cell_tp}-${target_tp}
#    Should Be True    ${tp_delta}>=0    fdd cell Throughtput is not in the accetable range
#    Log To Console    The FDD cell tput is on target: ${target_tp}Mb \n
#
#Common Test Setup For Cases Combination
#    Do Delta Commission If Needed
#    Suite Setup Start WTS And Check OnAir With Workaround
#    Setup XP LINK
#    Set LTE NR DSS Mode
#    Setup XP And Config Resource
#    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#    Common Test Setup
#
#Multi NonCA UE Attach And Do Traffic
#     [Arguments]    ${ue_num}
#    : FOR    ${ue_id}    IN RANGE    21    ${ue_num}+21
#    \    SA Attach    sa_ue_id=${ue_id}
#    \    SA Start DL Traffic Internal    ${ue_id}    1    20
#    \    SA Start UL Traffic Internal    ${ue_id}    1    10
#
#Check DL Per Slot Ue Numbers
#    [Arguments]    ${tti_csv_dir}    ${number}
#    ${filters}    Set Variable    dlFdSchedData
#    ${out_file_name}    Set Variable    ${tti_csv_dir}/dlFdSchedData.csv
#    ${result}    Set Variable    ${False}
#    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    *L2TtiTrace_EventsSnapshot.bin.*dl.csv    ${True}
#    FOR    ${file}    IN    @{tti_csv_files}
#    Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
#    ${result}    Verify DL Per Slot Ue Numbers In Target File    ${out_file_name}    ${number}
#    Exit For Loop If    ${result}==${True}
#    END
#    Should Be True    ${result}==${True}
#
#Verify DL Per Slot Ue Numbers In Target File
#    [Arguments]    ${tti_csv_name}    ${number}
#    [Documentation]    tti csv file contains only dlFdSchedData msg, please refer to tti_convert.py for more infos
#    ${times}    Evaluate    ${number}-1
#    ${full_patt}    Set Variable    dlFdSchedData,(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:dlFdSchedData,(?P=sfn),(?P=slot).+\\n){${times}}
#    ${rnti_patt}    Set Variable    dlFdSchedData,\\d+,\\d+,(?P<rnti>\\d+)
#    ${content}    OperatingSystem.Get File    ${tti_csv_name}
#    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
#    ${check_result}    Set Variable    ${False}
#    FOR    ${item}    IN    @{matches}
#    ${rnti_vals}    String.Get Regexp Matches    ${item}    ${rnti_patt}    rnti
#    ${count}    Evaluate    len(set(${rnti_vals}))
#    ${check_result}    Run Keyword And Return Status    Should Be Equal As Integers    ${count}    ${number}
#    Exit For Loop If    ${check_result}==${True}
#    END
#    [Return]    ${check_result}
#
#Check UL Per Slot Ue Numbers
#    [Arguments]    ${tti_csv_dir}    ${number}
#    ${filters}    Set Variable    ulFdSchedData
#    ${out_file_name}    Set Variable    ${tti_csv_dir}/ulFdSchedData.csv
#    ${result}    Set Variable    ${False}
#    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    *L2TtiTrace_EventsSnapshot.bin.*ul.csv    ${True}
#    FOR    ${file}    IN    @{tti_csv_files}
#    Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
#    ${result}    Verify UL Per Slot Ue Numbers In Target File    ${out_file_name}    ${number}
#    Exit For Loop If    ${result}==${True}
#    END
#    Should Be True    ${result}==${True}
#
#Verify UL Per Slot Ue Numbers In Target File
#    [Arguments]    ${tti_csv_name}    ${number}
#    [Documentation]    tti csv file contains only ulFdSchedData msg, please refer to tti_convert.py for more infos
#    ${times}    Evaluate    ${number}-1
#    ${full_patt}    Set Variable    ulFdSchedData,(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:ulFdSchedData,(?P=sfn),(?P=slot).+\\n){${times}}
#    ${rnti_patt}    Set Variable    ulFdSchedData,\\d+,\\d+,(?P<rnti>\\d+)
#    ${content}    OperatingSystem.Get File    ${tti_csv_name}
#    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
#    ${check_result}    Set Variable    ${False}
#    FOR    ${item}    IN    @{matches}
#    ${rnti_vals}    String.Get Regexp Matches    ${item}    ${rnti_patt}    rnti
#    ${count}    Evaluate    len(set(${rnti_vals}))
#    ${check_result}    Run Keyword And Return Status    Should Be Equal As Integers    ${count}    ${number}
#    Exit For Loop If    ${check_result}==${True}
#    END
#    [Return]    ${check_result}
#
#Verify Two PM Counters
#    Verify PM Counters Value    M55308C17002     8
#    Verify PM Counters Value    M55308C18002     8
#
#Verify PM Counters Value
#    [Arguments]    ${counter_id}    ${threshold_value}
#    ${counter_values}    Get Latest PM Counter Value With Admin    ${counter_id}
#    Should Be True     ${counter_values} == ${threshold_value}
#
#Do Delta Commission If Needed
#     ${delta_full_path}=    Join Config File Path WithOut Check    ${TEST NAME}_delta.json
#     ${KW_status}    ${files_check_status}    run_keyword_and_ignore_error    file_should_exist    path=${delta_full_path}
#     run_keyword_if    '${KW_status}'=='PASS'    Delta Commission With SCF File     ${delta_full_path}
#	 Reboot TL And Check Configured
#
#Join Config File Path WithOut Check
#    [Arguments]    ${config_file}
#    ${suite_path}    ${suite_file}=    OperatingSystem.Split Path    ${SUITE SOURCE}
#    ${scf_path_define_in_robot}=    Get Variable Value    ${SCF_PATH}    ${suite_path}/config
#    ${join_config_path}=    OperatingSystem.Join Path    ${scf_path_define_in_robot}    ${SW_BRANCH}    SCF    ${config_file}
#    [Return]    ${join_config_path}
#
#Common Test Teardown For Cases Combination
#    ute_wtssim.Execute Egate Command    reset
#    Common Test Teardown
