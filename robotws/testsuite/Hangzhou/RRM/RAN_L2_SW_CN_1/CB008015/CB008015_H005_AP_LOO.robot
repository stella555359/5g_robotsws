*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Make TL Ready
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Resource          ./../CUDU_L2/common_dss_command.robot
#Resource          ./resources/CB008015_lib.robot
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G    RAN_5G_TDD    Owner_qiaren
#...               CN1_SQ6    CB008015    SBTS00    SBTS23R1    SBTS22R4
#*** Variables ***
#${SCF_PATH}               ${CURDIR}/config/
#${FULL_SCFC}               8015_full_scfc_AP_LOO.xml
#${DELTA_SCFC}              CB008015_H005.json
#${IPHY_XML}                ${CURDIR}/config/wts/iphy_4F_2T_AP_LOO.xml
#${LOCAL_WTS_DIR}           ${CURDIR}/config/wts
#${WTS_DIR}                 /opt/wts/latest/
#${WTS_CFG}                  basic_8015_AP_LOO.cfg
#${WTS_AP_XML}               airphone.xml
#${UE_NUM}                  8
#
#*** Test Cases ***
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
#*** Keywords ***
#Suite Setup Make TL Ready
#    Suite Setup Update GNB     scf_file=${FULL_SCFC}       iphy_file=${IPHY_XML}
#    #Suite Setup Update GNB
#    Delta Commission With SCF File     ${DELTA_SCFC}
#    Verify Coam Site Is Ready
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#
#Start And Stop Tti Trace
#    Start GNB TTI Trace    L2RT_id=21
#    Sleep    1s    reason=get *L2TtiTrace_EventsSnapshot
#    Stop And Decode GNB TTI Trace    ${TEST_LOG_DIRECTORY}
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
