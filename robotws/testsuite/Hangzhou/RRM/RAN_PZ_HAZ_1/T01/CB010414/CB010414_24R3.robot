*** Settings ***
Documentation
...   Author: zhifu.xu@nokia-sbell.com
...   Contact: zhifu.xu@nokia-sbell.com
...   Description: This set of robot cases is used for CB010414
...    Deprecated case removed by civen.chen
#
#Suite Setup        Common Suite Setup For AIC For Any Testline
#Suite Teardown     RRM2_Resource.Custom Suite Teardown For AIC
#
#Force Tags
#...   PY36
#...   RAN_5G
#...   RAN_PZ_HAZ_1
#
#Test Timeout       75h
#
#Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
#Resource           ../Resources/RRM2_Resource.robot
#Resource           ../../T01/Resources/Case_Common_Resource.robot
#Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/Parameter_Operation.robot
#Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/PA_Operation.robot
#Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/BTS_Operation.robot
#
#*** Variables ***
#${vDU_SCF_Path}    ${CURDIR}/SCF/MRBTS-10872_DU_CB010414_24R3.xml
#${vCU_SCF_Path}    ${CURDIR}/SCF/MRBTS-10872_CU_CB010414_24R3.xml
#
#*** Test Cases ***
#CB010414_CB010240_SA_Online_activation_of_ reporting_of_DL_MAC_SDU_user_throughput_PM_counters
#    [Tags]    QC_82828        QCD_MN_RAN      QCP_RAN_VRF
#    [Documentation]
#    ...    Author: zhifu.xu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    13.04.2024, zhifu.xu@nokia-sbell.com, draft
#    ...    for vDU parameter part: miNrHighRlcCellNrpmqap=5min，actNrpmqapProfiles= true, miNrHighRlcCell=5min，
#    ...    actMacUserThpt = true  miNrMacSduReport  actPerCellMacUserThpt=true
#    ...    for vCU parameter part:actNrpmqapProfiles= true，miNrPdcpCellNrpmqap=5min，actMacUserThpt = true
#    ...    actIpThpt=true
#    [Setup]    Common Case Precondition
#    [Timeout]    1h
#    Precondition Full Commission
#    Set PA Operation To Max
#    PA Operation For 10872
#    Prepare UE0 And Attach UE0
#    Start DL Call For UE0    Tput=200M
#    sleep  3min
#    Run Keyword And Ignore Error    Stop DL Call For UE0
#    ${DU_counter_ids}    Create List    M55349C03002   M55349C04002    M55309C00002    M55309C00003
#    ${DU_counter_ids_PMQAP}    Create List    M55353C00002   M55353C00003
#    wait until keyword succeeds   10min  30s    Make Sure DU Counters Updated    ${DU_counter_ids}    comparison=greater
#    wait until keyword succeeds   1min  30s    Make Sure DU Counters Updated For PMQAP    ${DU_counter_ids_PMQAP}    comparison=greater
#    ${CU_counter_ids}    Create List    M55352C01002    M55352C01003
#    wait until keyword succeeds   10min  30s    Make Sure CU Counters Updated    ${CU_counter_ids}    M55352C    comparison=greater
#    [Teardown]    Common Case Postcondition For CB010414
#
#CB008072-PUSCH mapping type A co-existence with DFT-s-OFDM and PUSCH 256QAM for TDD FR1
#    [Tags]    QC_82727       QCD_MN_RAN    QCP_RAN_VRF
#    [Documentation]
#    ...    Author: xiaokang.qu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    11.22.2023, xiaokang.qu@nokia-sbell.com, draft
#    [Setup]    Common Case Precondition
#    [Timeout]    1h
#    Set Test Variable  ${ul_tput}  30M
#    Set Test Variable  ${dl_tput}  100M
#    Online Set vDU Parameters For USCB008072-A-6
#    Online Set vCU Parameters For USCB008072-A-6
#    wait until keyword succeeds   10min  30s   Check All Cells On Air In vCU
#    Step1 Change PA
#    Step2 Attach UE and Start UDP Traffic
#    Start UL Call For UE0    Tput=30M
#    Start DL Call For UE0    Tput=100M
#    Sleep    2m   reason=time for doing DL and DL
#    Get DL and UL Tput By K8s Log     duration=2m
#    Show Tput report
#    [Teardown]    Common Case Postcondition For CB010414
#
#*** Keywords ***
#Precondition Full Commission
#    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=full_commission   product_type=vcu
#    ...                                                                                scf_path=${vCU_SCF_Path}
#    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=full_commission   product_type=vdu
#    ...                                                                                scf_path=${vDU_SCF_Path}
#    sleep  1min
#    log to console    start check cell status
#    wait until keyword succeeds   15min  30s    vDU Check All Cells Status Should Be Onair For All DUs     gnb_index=${0}
#
#Common Case Precondition
#    log to console    Case Precondition
#    Common Test Setup For AIC
#    ${NEW_PLAN_NAME}   Get Test Case Name
#    Set Test Variable  ${NEW_PLAN_NAME}
#
#Common Case Postcondition For CB010414
#    Run Keyword And Ignore Error    Case_Common_Resource.Detach UE0
#    Run Keyword And Ignore Error    Prepare PA
#    Common Case Postcondition
#
#Common Case Postcondition
#    log to console    Case Postcondition
#    Common Test Teardown For AIC
#    vDU Login By Rest
#    Run Keyword And Ignore Error  plan_name=${NEW_PLAN_NAME}
#    Run Keyword And Ignore Error  svdu.Delete Plan  plan_name=${NEW_PLAN_NAME}
#    Run Keyword And Ignore Error  vDU Logout By Rest
#    Run Keyword And Ignore Error    Case_Common_Resource.Detach UE0
#    Run Keyword And Ignore Error    wireshark.stop_wireshark_log    pod_name=${pod_name}    namespace=${ns}
#    ...                                                             conn=${conn}    timeout=${timeout}
#
#Make Sure DU Counters Updated
#    [Arguments]    ${counter_ids}    ${comparison}=greater
#    ${counter_values}    Create List
#    FOR    ${id}    IN    @{counter_ids}
#        ${counter_values}    Check Counter For vDU   counter_id=${id}
#        ...           dimension_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#        ...           expected_value=0    comparison=${comparison}
#        ...           get_number=2
#    END
#
#Make Sure DU Counters Updated For PMQAP
#    [Arguments]    ${counter_ids}    ${comparison}=greater
#    ${counter_values}    Create List
#    FOR    ${id}    IN    @{counter_ids}
#        ${counter_values}    Check Counter For vDU   counter_id=${id}
#        ...           dimension_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1/NRPMQAP-1
#        ...           expected_value=0    comparison=${comparison}
#        ...           get_number=2
#    END
#
#Make Sure CU Counters Updated
#    [Arguments]    ${counter_ids}    ${measure_id}    ${comparison}=greater
#    ${counter_values}    Create List
#    FOR    ${id}    IN    @{counter_ids}
#        ${counter_values}    Check Counter For vCU   counter_id=${id}
#        ...                                            measurement_id=${measure_id}
#        ...                                            dimension_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1/NRPMQAP-1
#        ...                                            expected_value=0    comparison=${comparison}
#        ...                                            get_number=3
#    END
#
#Set PA Operation To Max
#    ${source_pa_port_list}     Create List     1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16
#    ${source_pa_value_list}    Create List     0    127
#    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
#    ...                               step=${127}    pa_type=16*16
#    PA Operation    source=&{source}    target=none
#
#PA Operation For 10872
#    ${source_pa_port_list}     Create List     7    8
#    ${source_pa_value_list}    Create List     0    2
#    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
#    ...                               step=${2}    pa_type=16*16
#    PA Operation    source=&{source}    target=none
#
#Verify All Cells Onair
#    BTS Operation    operation=verify    gnb_index=0
#    ...              product_type=vdu    distname_id=NRCELL-ALL    verify_status=CELL_ONAIR
#
#Start DL Call For UE
#    [Arguments]    ${Tput}=200M    ${duration}=${6000}
#    Log To Console    \nStart the DL TPUT
#    Start traffic    ue_type=${ue_2_type}    ue_index=${2}    direction=dl    dt_index=${0}
#	...              throughput=${Tput}    duration=${duration}
#
#Online Set vDU Parameters For USCB008072-A-6
#    Log To Console    \nSetting Parameters For USCB008072-A-6
#    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    &{parameter_dict}    Create Dictionary  puschMappingType=TypeA  actUlDftSOfdm=true
#    ...                                     actUl256Qam=true  actAperCsi=true
#    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#    ...                                                                      mo_parameter_dict=&{parameter_dict}
#    vDU Login By Rest
#    Run Keyword If  &{parameter_dict1} != &{Empty}
#    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#	...                                          updated_paras_list=${parameter_dict}
#	...                                          operation=replace
#	...                                          activate=${True}
#    ...                                          force_reset=${False}
#    ...                                          auto_lock_cells=${True}
#    ...                                          wait_vdu_up=${False}
#    vDU Logout By Rest
#
#Online Set vCU Parameters For USCB008072-A-6
#    ${mo_dn1}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#
#    ${value}    Set Variable    true
#    &{param_dict}    create dictionary    operation_type=replace    parameter_path=/actAperCsi
#    ...                                                                         value=${value}
#    @{updated}    Create List    ${param_dict}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actAperCsi
#    ...                                                   updated_paras_dict=${updated}
#    ...                                                   compare_value=${value}
#    ...                                                   mo_dn=${mo_dn1}
#
#Step1 Change PA
#    Set PA Operation To Max
#    PA Operation For 10872 Cell1
#
#Step2 Attach UE and Start UDP Traffic
#    Prepare UE0 And Attach UE0
#    Start DL Call For UE0    Tput=20M
#
#PA Operation For 10872 Cell1
#    ${source_pa_port_list}     Create List     7    8
#    ${source_pa_value_list}    Create List     0    2
#    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
#    ...                               step=${2}    pa_type=16*16
#    PA Operation    source=&{source}    target=none
