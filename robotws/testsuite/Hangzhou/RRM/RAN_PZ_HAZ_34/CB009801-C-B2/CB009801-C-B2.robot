*** Settings ***
Documentation
...         author: Lixia.tang
...         contact: lixia.tang@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         CB009801 parity feature CB009169 T+F 2CC DL 2CC UL CA test

Force Tags

Resource       Resources/CB009801_Common_Keywords.robot
Variables      Resources/counters.py

Suite Setup    Suite setup
Suite Teardown    Suite teardown

*** Variables ***
${scf_name}    SCF_SBTS00.xml
${ue_type}     mtk
${2cc_duration}    30s
${ul_exp_PCell}    50
${dl_exp_PCell}    500
${ul_exp_SCell}    10
${dl_exp_SCell}    150

*** Test Cases ***
[1]CB009801_CB009169_01_Scell_addition_activation_deactivation_DL_UL_data_scheduling_TDD_FR1_FDD_UL_CA_TDD_as_PCell_SA
    [Documentation]
    ...    This user scenario describes the successful operation of the inter-band TDD - FDD FR1 UL CA feature activation
    ...    when gNB cells are configured in SA Option 2, and DL/UL scheduling can reach peak throughput. During data scheduling,
    ...    the uplink of PCell and SCell supports only 1 layer regardless the signal quality.UL Tx Switching is not supported
    ...    in this feature. In the overlap UL slot of PCell and SCell, only PCell can schedule PUSCH,
    ...    but SCell can not schedule PUSCH, so power split is not needed in overlap UL slot.
    [Tags]
    [Setup]    robot_common_operations.Common Suite Setup
    [Timeout]    40min
    Step1: Scf commission until on-air
    Step2: Prepare UE
    Step3: UE Attach
    Step4: Check 2CC Counters
    Step5: Start traffic and check result    tp_direction=both
    Step6: Stop traffic and check result
    Step7: UE Detach
    [Teardown]    Run Keywords    CaseTeardown

*** Keywords ***
Step1: Scf commission until on-air
    log to console      \n Step1: Scf commission and wait for on-air
    Scf commission and wait for on-air    scf_name=${scf_name}

Step2: Prepare UE
    log to console      \n Step2: Prepare UE
    ADB Reboot UE and Clean ELT Temp Path
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}

Step3: UE Attach
    log to console      \n Step3: UE Attach
    Prepare to caculate PM counter    period=start
    ${status}    run keyword and return status      power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}
    ${Attach Expected Messages} =    Create List     5GMM_REGISTRATION_COMPLETE
    Run keyword and continue on failure      mtk.Expect Messages in Flow
    ...     awaited_messages=${Attach Expected Messages}    flow_alias=MTK_OTA_MESSAGE

Step5: Start traffic and check result
    [Arguments]  ${tp_direction}=both    ${sleep_time}=2m
    log to console      \n Step5: Start traffic and check result
    Start 2CC ULDL traffic    tp_direction=${tp_direction}
    Run keyword and continue on failure    Check 2CC ULDL throughput

Step6: Stop traffic and check result
    log to console      \n Step6: Stop traffic and check result
    Run Keyword And Ignore Error    Stop 2CC traffic    tp_direction=dl
    Run keyword and continue on failure    Check 2CC UL throughput
    Run Keyword And Ignore Error    Stop 2CC traffic    tp_direction=ul

Step4: Check 2CC Counters
    log to console      Step4: Check 2CC Counters
    Prepare to caculate PM counter    period=end
    sleep    40
    ${Release}    Get gNB Release Version
    Run Keyword If    '${Release}' == '24R1'   Run keyword and continue on failure    Check the PM counters should be greater than 1
    ...    counter_id=${counter_list1_great_1}    dic_path=${dic_path_list1_great_1_24R1}
    ...    ELSE    Run keyword and continue on failure    Check the PM counters should be greater than 1
    ...    counter_id=${counter_list1_great_1}    dic_path=${dic_path_list1_great_1}

    Run Keyword If    '${Release}' == '24R1'   Run keyword and continue on failure    Check the PM counters should be value
    ...    counter_id=${counter_list_value_1}    dic_path=${dic_path_list_value_1_24R1}    value=1
    ...    ELSE    Run keyword and continue on failure    Check the PM counters should be value
    ...    counter_id=${counter_list_value_1}    dic_path=${dic_path_list_value_1}    value=1

    Run Keyword If    '${Release}' == '24R1'    Run keyword and continue on failure    Check the PM counters should be value
    ...    counter_id=${counter_list_value_0}    dic_path=${dic_path_list_value_0_24R1}    value=0
    ...    ELSE    Run keyword and continue on failure    Check the PM counters should be value
    ...    counter_id=${counter_list_value_0}    dic_path=${dic_path_list_value_0}    value=0

Step7: UE Detach
    log to console      \n Step7: UE Detach
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}
    ${Detach Expected Messages} =    Create List     NR_RRCRelease
    Run keyword and continue on failure    mtk.Expect Messages in Flow
    ...     awaited_messages=${Detach Expected Messages}    flow_alias=MTK_OTA_MESSAGE
