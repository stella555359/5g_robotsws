*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    CN1_SQ6    CB009169
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
##Common variables
#${SCF_PATH}                     ${CURDIR}/Config
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${WTS_CFG}                      CB009169_BB202.cfg
#@{2CC_SCELL_PHYSICALID_LIST}    ${2CC_SCELL_PHYSICALID}    ${2CC_SCELL_PHYSICALID}
#@{2CC_SCELL_PHYSICALID}         50
#@{COUNTER_ID_LIST1}             ${COUNTER_1}    ${COUNTER_2}
#&{COUNTER_1}                    counter_id=M55118C10001    counter_path=CELLS/NRCELL-3/NCAC    min_value=1    max_value=3
#&{COUNTER_2}                    counter_id=M55118C10002    counter_path=CELLS/NRCELL-3/NCAC    min_value=1    max_value=3
#@{COUNTER_ID_LIST2}             ${COUNTER_3}    ${COUNTER_4}
#&{COUNTER_3}                    counter_id=M55118C10005    counter_path=CELLS/NRCELL-3/NCAC    min_value=599    max_value=601
#&{COUNTER_4}                    counter_id=M55118C10006    counter_path=CELLS/NRCELL-1/NCAC    min_value=599    max_value=601
##BB202
#${Delta_SCF_BB202}              Delta_SCF_BB202.json
#${2CC_DL_DATA}                  500
#${2CC_UL_DATA}                  90
#${NON_ULCA_EXP_TPUT}            90
#@{2CC_UE_LIST}                  20     21
#@{2CC_EXP_DL_TPUT_BB202}        130    30
#@{2CC_EXP_UL_TPUT_BB202}        15     15
##BB302
#${Delta_SCF_BB302}              Delta_SCF_BB302.json
#${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_BB302.xml
#@{2CC_SMALL_BWP_UE}             32     33
#${2CC_HIGH_DL_DATA}             510
#${2CC_HIGH_UL_DATA}             90
#@{2CC_EXP_DL_TPUT_BB302}        120    30
#@{2CC_EXP_UL_TPUT_BB302}        20     10
#
#*** Test Cases ***
#CB009169-ET-BB202_Verify_Multiple_UEs_T_F_ULCA_Interworking_With_Dyn_UL_Resource_Allocation_In_TDD_Cell_Single_Dedicated_BWP_With_Beamforming
#    [Tags]    Owner_j8shen
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${Delta_SCF_BB202}    swconfig_param=0x580692=1
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    SA Multi UE Attach With Scell Blind Addition    ${2CC_UE_LIST}    ${2CC_SCELL_PHYSICALID_LIST}    2
#    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST}    ${2CC_DL_DATA}    ${2CC_UL_DATA}
#    Wait Until PM Counter Update
#    Sleep    20s    reason=wait PM Counter stable
#    Check Multi PM COUNTERs Latest Value From Admin    ${COUNTER_ID_LIST1}
#    Multi Non CA UEs Attach And Start Traffic
#    Sleep    30s    reason=Wait Until All UEs Traffic Stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CC_UE_LIST}    ${2CC_EXP_UL_TPUT_BB202}    ${2CC_EXP_DL_TPUT_BB202}    2
#    Check Multi Non CA UEs Throughput
#    Get All CA Non CA UEs CRNTI
#    Capture Convert Format Ttitrace With Streaming Mode    2s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB009169_BB${/}ttitrace_BB202.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#    Wait Until PM Counter Update
#    Sleep    20s    reason=wait PM Counter stable
#    Check Multi PM COUNTERs Latest Value From Admin    ${COUNTER_ID_LIST2}
#    [Teardown]    Common Test Teardown
#
#CB009169-ET-BB302_Verify_Multiple_UEs_T_F_ULCA_Interworking_With_Dyn_UL_Resource_Allocation_In_TDD_Cell_Multiple_Dedicated_PowerSaving_Small_BWP
#    [Documentation]    This case is to verify dynamic UL resource share in multiple BWP configs.
#    ...    And verify power saving switch for small BWP CA UE.
#    ...    The T+F CA UE32 UE33 with Small BWP in pcell and scell.
#    [Tags]    Owner_j8shen
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${Delta_SCF_BB302}    iphy_file=${IPHY_FILE}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    SA Multi UE Attach With Scell Blind Addition    ${2CC_SMALL_BWP_UE}    ${2CC_SCELL_PHYSICALID_LIST}    2
#    SA Multi UE Start DL And UL Traffic    ${2CC_SMALL_BWP_UE}    ${2CC_HIGH_DL_DATA}    ${2CC_HIGH_UL_DATA}
#    Wait Until PM Counter Update
#    Sleep    20s    reason=wait PM Counter stable
#    Check Multi PM COUNTERs Latest Value From Admin    ${COUNTER_ID_LIST1}
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CC_SMALL_BWP_UE}    ${2CC_EXP_UL_TPUT_BB302}    ${2CC_EXP_DL_TPUT_BB302}    2
#    Check UE Swith From Power Saving BWP By Egate Log
#    Capture Convert Format Ttitrace With Streaming Mode    5s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/swtich_from_ps/
#    A2A Check UE Switch From Power Saving BWP Also Verify Dynamic UL Resources Allocation On Pcell
#    Wait Until PM Counter Update
#    Sleep    20s    reason=wait PM Counter stable
#    Check Multi PM COUNTERs Latest Value From Admin    ${COUNTER_ID_LIST2}
#    Start Low Traffic To Triger Switch To Power Saving BWP
#    A2A Check UE Switch To Power Saving BWP
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#Multi Non CA UEs Attach And Start Traffic
#    SA Multi Continuous NonCA UE Attach    22    23
#    SA Multi Continuous UE Start DL And UL Traffic    22    23    200    60
#    Sleep    5s    reason=wait for traffic stable
#    SA Multi Continuous NonCA UE Attach    24    25
#    SA Multi Continuous UE Start DL And UL Traffic    24    25    100    60
#    Sleep    5s    reason=wait for traffic stable
#
#Check Multi Non CA UEs Throughput
#    FOR    ${TDD_UE_ID}    IN RANGE    22    24
#        SA UE Check Throughput    ${TDD_UE_ID}    10    10
#    END
#    FOR    ${FDD_UE_ID}    IN RANGE    24    26
#        SA UE Check Throughput    ${FDD_UE_ID}    10    10
#    END
#
#Get All CA Non CA UEs CRNTI
#    ${UE20_CRNTI}=    Get Crnti From Egate Log    20
#    Set Suite Variable    ${UE20_CRNTI}
#    ${UE21_CRNTI}=    Get Crnti From Egate Log    21
#    Set Suite Variable    ${UE21_CRNTI}
#    ${UE22_CRNTI}=    Get Crnti From Egate Log    22
#    Set Suite Variable    ${UE22_CRNTI}
#    ${UE23_CRNTI}=    Get Crnti From Egate Log    23
#    Set Suite Variable    ${UE23_CRNTI}
#
#Check UE Swith From Power Saving BWP By Egate Log
#    ${UE32_CRNTI}=    Get Crnti From Egate Log    ${2CC_SMALL_BWP_UE[0]}
#    ${UE33_CRNTI}=    Get Crnti From Egate Log    ${2CC_SMALL_BWP_UE[1]}
#    Set Suite Variable    ${UE32_CRNTI}
#    Set Suite Variable    ${UE33_CRNTI}
#    Run Keyword And Ignore Error    Save Egate Console Log And Grep UE BWP Switch Keyword    swtich_from_ps    Bwp Switched from bwpId 2 to 1
#
#A2A Check UE Switch From Power Saving BWP Also Verify Dynamic UL Resources Allocation On Pcell
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB009169_BB${/}ttitrace_BB302_swtich_from_ps.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming/swtich_from_ps/
#
#Start Low Traffic To Triger Switch To Power Saving BWP
#    SA Multi UE Start Low DL And UL Traffic    ${2CC_SMALL_BWP_UE}
#    Sleep    30s    reason=wait traffic decrease and switch to Powersaving BWP
#    Save Egate Console Log And Grep UE BWP Switch Keyword    swtich_to_ps    Bwp Switched from bwpId 1 to 2
#
#A2A Check UE Switch To Power Saving BWP
#    Capture Convert Format Ttitrace With Streaming Mode    5s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/swtich_to_ps/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB009169_BB${/}ttitrace_BB302_switch_to_ps.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming/swtich_to_ps/
#
#SA Multi UE Start Low DL And UL Traffic
#    [Arguments]    ${ue_id_list}
#    FOR    ${ue_id}    IN    @{ue_id_list}
#        SA Start Small DL Traffic Internal    ${ue_id}    pdu_id=1    kbps=10    trf_id=1
#        SA Start Small DL Traffic Internal    ${ue_id}    pdu_id=1    kbps=10    trf_id=2
#        SA Start Small DL Traffic Internal    ${ue_id}    pdu_id=1    kbps=10    trf_id=3
#        Sleep    10s    reason=wait for DL decrease first and finnal trigger PS switch via UL DCI
#        SA Start Small UL Traffic Internal    ${ue_id}    pdu_id=1    kbps=40    trf_id=1
#    END
#
#SA Start Small DL Traffic Internal
#    [Arguments]    ${ue_id}    ${pdu_id}=1    ${kbps}=5    ${trf_id}=1
#    Log To Console    UE${ue_id} start low DL ${kbps}k traffic...
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=dl kbps\=${kbps} trf_id\=${trf_id}
#    Sleep    2s    reason=wait DL traffic is stable
#
#SA Start Small UL Traffic Internal
#    [Arguments]    ${ue_id}    ${pdu_id}=1    ${kbps}=5    ${trf_id}=1
#    Log To Console    \nStart UE${ue_id} low UL ${kbps}k traffic...
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=ul kbps\=${kbps} trf_id\=${trf_id}
#    Sleep    2s    reason=wait UL traffic is stable
#
#Save Egate Console Log And Grep UE BWP Switch Keyword
#    [Arguments]    ${egate_log_tag}    ${grep_keyword}
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/egate/${egate_log_tag}
#    ${pw_switch_tag}    Grep File    ${TEST_LOG_DIRECTORY}/egate/${egate_log_tag}/egate_console.log    ${grep_keyword}
#    Should Not Be Empty    ${pw_switch_tag}
