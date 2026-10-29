*** Settings ***
Documentation
...   Author: zhifu.xu@nokia-sbell.com
...   Contact: zhifu.xu@nokia-sbell.com
...   Description: This set of robot cases is used for CB010414
...    Deprecated case removed by civen.chen
#
#Suite Setup        Common Suite Setup For AIC For Any Testline Test
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
#${vDU_SCF_Path_10544}    ${CURDIR}/SCF/MRBTS-10872_DU_CB010544_24R3.xml
#${vCU_SCF_Path_10544}    ${CURDIR}/SCF/MRBTS-10872_CU_CB010544_24R3.xml
#*** Test Cases ***
#CB010414_CB010240_SA_Online_activation_of_ reporting_of_DL_MAC_SDU_user_throughput_PM_counters
#    [Tags]    QC_32465         QCD_MN_RAN      QCP_RAN_VRF
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
#CB010784_D_IWK1_Configuration_of_cell_with_additional_delay_to_be_compensated
#    [Tags]    QC_32462           QCD_MN_RAN      QCP_RAN_VRF
#    [Documentation]
#    ...    Author: zhifu.xu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    13.04.2024, zhifu.xu@nokia-sbell.com, draft
#    [Setup]    Common Case Precondition
#    [Timeout]    1h
#    Precondition Full Commission
#    Set Parameter addExtDelayCompensation    addExtDelayCompensation=60    prachConfigurationIndex=157
#    wait until keyword succeeds   15min  30s    Verify All Cells Onair
#    Verify guardPeriodLength
#    sleep  1min
#    Set Parameter addExtDelayCompensation    addExtDelayCompensation=0    prachConfigurationIndex=98
#    wait until keyword succeeds   15min  30s    Verify All Cells Onair
#    [Teardown]    Common Case Postcondition For CB010414
#
#CB010414_CB010544_UE_attach_with_RACH_not_inside_the_PowerSavingBWP
#    [Tags]    QC_32464      QCD_MN_RAN      QCP_RAN_VRF
#    [Documentation]
#    ...    Author: zhifu.xu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    27.05.2024, zhifu.xu@nokia-sbell.com, draft
#    [Setup]    Common Case Precondition
#    [Timeout]    72h
#    Precondition Full Commission SCF
#    Set PA Operation To Max
#    PA Operation For 10872
#    Prepare And Attach UE    ue_index=2
#    Start DL Call For UE    Tput=1k
#    Step31 Check PS BWP Counter M55351C00001 M55351C00002 Greater Zero
#    Start DL Call For UE    Tput=20M
#    Step41 Check PS BWP Counter M55351C00001 M55351C00002 Equal Zero
#    [Teardown]    Common Case Postcondition For CB010414
#
#*** Keywords ***
#Get Branch Name Test
#    @{lst}    Get Regexp Matches    ${ENB_BUILD}    vDUCNF[A-Za-z0-9]*_(\\d+\.\\d+)\.\\d+   1
#    [Return]    ${lst}[0]
#
#Common Suite Setup For AIC For Any Testline Test
#    Run Keyword And Ignore Error    Get TestLine Name From UTE Cloud
##    ${TL_NAME}=    Get TestLine Name
#    ${BRANCH_NAME}=    Get Branch Name Test
##    Set Suite Variable    ${TL_NAME}
#    Set Suite Variable    ${BRANCH_NAME}
#    Set Suite Variable    ${DEFAULT_SCF_PATH}    ${CURDIR}/../../../../../commissionings/RRM/SRAN_5G/${TestLine_Name}
#    ${cell_status}=     Run Keyword And Ignore Error    Check All Cells On Air In vCU
#    Run Keyword If     '${cell_status}[0]'=='FAIL'    Load Default SCF
#    Common Suite Setup For AIC
#
#Precondition Full Commission
#    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=full_commission   product_type=vcu
#    ...                                                                                scf_path=${vCU_SCF_Path}
#    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=full_commission   product_type=vdu
#    ...                                                                                scf_path=${vDU_SCF_Path}
#    sleep  1min
#    log to console    start check cell status
#    wait until keyword succeeds   15min  30s    vDU Check All Cells Status Should Be Onair For All DUs     gnb_index=${0}
#
#Precondition Full Commission SCF
#    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=full_commission   product_type=vcu
#    ...                                                                                scf_path=${vCU_SCF_Path_10544}
#    ${case_result}    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=full_commission   product_type=vdu
#    ...                                                                                scf_path=${vDU_SCF_Path_10544}
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
#Check DU Counter Update PS BWP
#    [Arguments]    ${comparison}=greater
#    ${du_counter_id_list1}    Create List    M55351C00001    M55351C00002
#    ${du_counter_values_final_list1}    Create List
#    FOR    ${du_counter_id1}    IN    @{du_counter_id_list1}
#        ${du_counter_values_final_list1}    Check Counter For vDU   counter_id=${du_counter_id1}
#        ...                                            dimension_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#        ...                                            expected_value=0
#        ...                                            get_number=3
#        ...                                            comparison=${comparison}
#    END
#
#Check DU Counter Update PS BWP Equal zero
#    [Arguments]    ${comparison}=equal
#    ${du_counter_id_list1}    Create List    M55351C00001    M55351C00002
#    ${du_counter_values_final_list1}    Create List
#    FOR    ${du_counter_id1}    IN    @{du_counter_id_list1}
#        ${du_counter_values_final_list1}    Check Counter For vDU   counter_id=${du_counter_id1}
#        ...                                            dimension_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#        ...                                            expected_value=0
#        ...                                            get_number=3
#        ...                                            comparison=${comparison}
#    END
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
#Set Parameter addExtDelayCompensation
#    [Arguments]    ${addExtDelayCompensation}     ${prachConfigurationIndex}
#    @{para_list}          Create List    addExtDelayCompensation    prachConfigurationIndex
#    ...                                  tddFrameStructure/0/guardPeriodLength
#    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    ...                                  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    @{value_list_true}    Create List    ${addExtDelayCompensation}    ${prachConfigurationIndex}    2Symbols
#    ${out}                Parameter Operation    operation=parameter_update    product_type=vdu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
#    Log To Console        VDU paramter update result: ${out}
#
#Verify guardPeriodLength
#    @{para_list}      Create List    tddFrameStructure/0/guardPeriodLength
#    @{mo_list_vcu}    Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    ${out}            Parameter Operation    operation=parameter_value_check   product_type=vdu
#    ...                                      para_list=@{para_list}    mo_list=@{mo_list_vcu}
#    Log To Console    VDU Parameter Check Result: ${out}
#    ${result}    Convert To String    ${out}
#    Should Contain    ${result}    3Symbols
#
#Verify All Cells Onair
#    BTS Operation    operation=verify    gnb_index=0
#    ...              product_type=vdu    distname_id=NRCELL-ALL    verify_status=CELL_ONAIR
#
#Step3 Attch UE and Make VONR
#    Prepare UE0 And Attach UE0
#    Start Voice Call For UE0
#    Sleep    30s    reason=Waiting For Voice Call
#
#Step31 Check PS BWP Counter M55351C00001 M55351C00002 Greater Zero
#    wait until keyword succeeds   30min  30s   Check DU Counter Update PS BWP
#
#Step4 Attach UE and Start UDP Traffic
#    Prepare UE0 And Attach UE0
#    Start DL Call For UE0    Tput=20M
#
#Step41 Check PS BWP Counter M55351C00001 M55351C00002 Equal Zero
#    Sleep    300
#    wait until keyword succeeds   30min  30s   Check DU Counter Update PS BWP Equal zero
#
#Prepare And Attach UE
#    [Arguments]    ${ue_index}=${0}    ${ui_version}=default
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
#    Log to Console    \n***Prepare UE***
#    Prepare UE    ${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
#    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
##    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
##    Sleep    60s    reason=wait attach UE Successfully
#    [Return]     ${ue_${ue_index}_type}
#
#Start DL Call For UE
#    [Arguments]    ${Tput}=200M    ${duration}=${6000}
#    Log To Console    \nStart the DL TPUT
#    Start traffic    ue_type=${ue_2_type}    ue_index=${2}    direction=dl    dt_index=${0}
#	...              throughput=${Tput}    duration=${duration}
