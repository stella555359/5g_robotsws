*** Settings ***
Suite Setup       Common Suite Setup And Setup BTS Env For CNI101440
Suite Teardown    Common Suite Teardown And Remove TRACE
Test Setup        Common Test Setup For CNI101440
Test Teardown     Common Test Teardown For CNI101440

Documentation    Suite description
...    author:      Zhang Jun
...    contact:     jun.15.zhang@nokia-sbell.com
...    squad group: MMW_SG7
...    Feature:     CNI101440

Force Tags    5G_RRM   PY39

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resource/Common_Keywords.robot

*** Variables ***
${tl_info}    7_5_UTE5G402T2452
${L1_TYPE}    FS

${DEBUG}                      ${True}
${EMIL_FLAG}                  ${True}
${SYSCOM_FLAG}                ${True}
${GNB_BIP_FLAG}               ${True}
${TTITRACE_FLAG}              ${False}
${AUTO_ANALYSIS_FLAG}         ${False}
${RESOURCES_LEAKAGE_FLAG}     ${False}
${RECREATE_WIRESHARK_FLAG}    ${False}
${SNAPSHOT_FLAG}              pass:False,fail:True

${Trf_Check}    ${True}
${Periodic_Count}    1

@{PARAMS_IN_SWCONFIG}
...    0x5A0609=1              #L2-HI rdDebugPcmdNrt
...    0x5A0610=1              #L2-HI rdDebugPcmdRt
...    0x5B0609=1              #L2-HI rdDebugPcmdNrt
...    0x5B0610=1              #L2-HI rdDebugPcmdRt
...    0x57000E=1              #enable L2-LO NRT PCMD debug logs
...    0x58057a=4              #L2-PS rdFeatureFlagBitmapLevel 4DEBUG
...    0x58057b=8              #L2-PSrdFeatureFlagBitmap0 3PCMD
...    0x58057c=20000          #L2-PSrdFeatureFlagBitmap1
...    0x580582=3              #L2-PSrdFeatureFlagBitmap7 0PCMD.L2NRT 1PCMD.L2RT
...    0x58057f=0x10000000     #L2-PSrdFeatureFlagBitmap4

#PA config:
@{all_cell_ids}    ${1}   ${3}
${PA_Max_Value}    ${127}    #some PA value range [0 dB, 63 dB]
${PA_Mid_Value}    ${50}
${PA_Min_Value}    ${35}
@{IntergNB_Ports}    ${5}    ${6}
@{CELL3_Ports}    ${7}    ${8}
@{CELL1_Ports}    ${9}    ${10}
@{CELLs_Ports}    @{IntergNB_Ports}    @{CELL3_Ports}    @{CELL1_Ports}
@{PA_Def_Value}    ${PA_Max_Value}    ${PA_Max_Value}    ${PA_Mid_Value}    ${PA_Mid_Value}    ${PA_Min_Value}    ${PA_Min_Value}

@{RRC_Setup_PCMD}
...    (nsetapx.rrcSetupRecord)
...    (nsetapx.bearerRecord)
@{RRE_Periodic_PCMD}
...    (nsetapx.ulSchedulingRecord)
...    (nsetapx.dlSchedulingRecord)
...    (nsetapx.ulRbRlcMeasRecord)
...    (nsetapx.dlRbRlcMeasRecord)
...    (nsetapx.beamUsageRecord)
...    (nsetapx.timingAdvanceRecord)
...    (nsetapx.ulRbRlcThroughputRecord)

${Cell1}                                 (nsetapx.cellIdentity == 02:47:78:00:10)
${Cell3}                                 (nsetapx.cellIdentity == 02:47:78:00:30)
${rrcReestablishmentRequest}             (!nsetapx.data && nr-rrc.rrcReestablishmentRequest_element && nr-rrc.reestablishmentCause == 2)
${rrcReestablishment}                    (!nsetapx.data && nr-rrc.rrcReestablishment_element && nr-rrc.nextHopChainingCount == 0)
${rrcReestablishmentComplete}            (!nsetapx.data && nr-rrc.rrcReestablishmentComplete_element)
${initialUeRrcMessageTransferSndTime}    (nsetapx.ueCtxSetupRecord && nsetapx.initialUeRrcMessageTransferSndTime_element)
${ueCtxSetupReqRcvTime}                  (nsetapx.ueCtxSetupRecord && nsetapx.ueCtxSetupReqRcvTime_element)
${ueCtxSetupCmplSndTime}                 (nsetapx.ueCtxSetupRecord && nsetapx.ueCtxSetupCmplSndTime_element)
${startRecordingSession_CU}              (nsetapx.TraceMessage == 4 && nsetapx.nodeType == 0)
${startRecordingSession_DU}              (nsetapx.TraceMessage == 4 && nsetapx.nodeType == 2)
${stopRecordingSession_CU}               (nsetapx.TraceMessage == 5 && nsetapx.nodeType == 0)
${stopRecordingSession_DU}               (nsetapx.TraceMessage == 5 && nsetapx.nodeType == 2)

#RRC_REESTAB_OTHER_FAILURE       NRRCC:M55124C00505
#REESTAB_ACC_OTHER_FAIL          NRRCC:M55124C00512
#REESTAB_RRCRECONFIG_SUCC        NRRCC:M55124C00516
#RRC_REESTAB_FALLBACK            NRRCC:M55124C00502
#REESTAB_ACC_FALLBACK            NRRCC:M55124C00515
#REESTAB_ADMISSION_CTRL          NRRCC:M55124C00519
#RRC_REESTAB_OTHER_FAILURE_DU    NRRCD:M55127C00503
#REESTAB_ACC_OTHER_FAIL_DU       NRRCD:M55127C00512
#RRC_REESTAB_DISCARD_DU          NRRCD:M55127C00513

*** Test Cases ***
CNI101440_ST_B001_RRE_To_Origin_Cell
    [Documentation]
    ...    1. The purpose of this test case is 
    ...    UE no CA capa, only none-CA PCMD msg checked.
    ...    2. Test Case Steps:
    [Tags]    B001
    Clear Counter Files    wait=${False}
    Delta Commission Parameters    ${PARAMS_FOR_RRE}
    Start UE Attach With Power UE    ue_index=${0}    4G_check=${False}
    UE Trigger RRE To Origin Cell    attach_cell=${1}
    Check Wireshark And Counters For B001

CNI101440_ST_B002_RRE_To_Other_Cell
    [Documentation]
    ...    1. The purpose of this test case is
    ...    2. Test Case Steps:
    [Tags]    B002
    Clear Counter Files    wait=${False}
    #Delta Commission Parameters    ${PARAMS_FOR_RRE}
    Start UE Attach With Power UE    ue_index=${0}    4G_check=${False}
    UE Trigger RRE To Other Cell    attach_cell=${1}    target_cell=${3}
    Check Wireshark And Counters For B002

CNI101440_ST_B003_RRE_FB_To_Origin_Cell
    [Documentation]
    ...    1. The purpose of this test case is 
    ...    2. Test Case Steps:
    [Tags]    B003
    Clear Counter Files    wait=${False}
    Delta Commission Parameters    ${PARAMS_FOR_RRE_FB}
    Start UE Attach With Power UE    ue_index=${0}    4G_check=${False}
    UE Trigger RRE To Origin Cell    attach_cell=${1}    tag=B003
    Check Wireshark And Counters For B003

CNI101440_ST_B004_RRE_FB_To_Other_Cell
    [Documentation]
    ...    1. The purpose of this test case is
    ...    2. Test Case Steps:
    [Tags]    B004
    Clear Counter Files    wait=${False}
    #Delta Commission Parameters    ${PARAMS_FOR_RRE_FB}
    Start UE Attach With Power UE    ue_index=${0}    4G_check=${False}
    UE Trigger RRE To Other Cell    attach_cell=${1}    target_cell=${3}    tag=B004
    Check Wireshark And Counters For B004

*** Keywords ***
Common Suite Setup And Setup BTS Env for CNI101440
    Setup BTS env and set keyword prority    scf=SCF_SBTS00_3Cells.xml
    Delta Commission For CNI101440

Common Suite Teardown And Remove TRACE
    Delta Commission Parameters    ${Post_Config}
    Common Suite Teardown And Restore BTS Configuration Parameters

Delta Commission For CNI101440
    Delta Commission Parameters    ${DELETE_TRACE}
    Delta Commission Parameters    ${PARAMS_CNI101440}

Common Test Setup For CNI101440
    Common Test Setup And Start To Capture Logs
    Cells Should Be OnAir    cell_id=1
    Cells Should Be OnAir    cell_id=3
    Set Test Variable    ${TS_CASE_LOG_PATH}     ${TEST_LOG_DIR}
    run keyword if   ${Trf_Check}    Set Test Variable    ${Periodic_Count}    30
    Prepare PA And Set Default Value

Common Test Teardown For CNI101440
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    Common Test Teardown With Scout

Prepare PA And Set Default Value
    BuiltIn.Log    Prepare PA And Set Default Value...    console=${True}
    attenuator.setup_attenuator    attenuator=${tl.attenuator}
    Adjust Cells HBTE Attenuation Value To Default

Adjust Cells HBTE Attenuation Value To Default
    [Arguments]    ${port_value_list}=${PA_Def_Value}
    ${numberOfPorts}    Get Length    ${CELLs_Ports}
    FOR    ${index}    IN RANGE    ${numberOfPorts}
        attenuator.set_attenuation     port=${CELLs_Ports[${index}]}    value=${port_value_list[${index}]}
        attenuator.read_attenuation    port=${CELLs_Ports[${index}]}
    END

UE Start Trf And Check Tput
    [Arguments]    ${ue_index}=0    ${cellid}=1    ${dl_tp}=10    ${ul_tp}=5    ${duration}=10    ${ue_detach}=${False}
    BuiltIn.Log    Start L3 Call With Power UE...    console=${True}
    Start L3 Call With Power UE    ue_index=${ue_index}
    BuiltIn.Log    Check Tput With Power UE...    console=${True}
    @{direction_component_list}    Create List    UL_L2LO    DL_L2LO
    Check Tput With Power UE    cellid=${cellid}    expect_ul_tput=${ue_index}    expect_dl_tput=${dl_tp}    expect_ul_tput=${ul_tp}
    ...    duration=${duration}    direction_component_list=@{direction_component_list}    target_avg_percent=0.95    min_percent=0.85
    BuiltIn.Log    Stop Traffic With Power UE...    console=${True}
    [Teardown]    Run Keywords    Move Tput Check File To TEST LOG DIR
    ...    AND    Stop Traffic With Power UE     ue_index=${ue_index}    is_detach=${ue_detach}

Move Tput Check File To TEST LOG DIR
    [Documentation]
    ...    Collect Tput: Aasys_CCS_MCU.txt path: ${OUTPUT_DIR}/${current_time}_${log_name}
    ...    Check Tput: path: ${OUTPUT_DIR}/${TEST NAME}/
    ...    find /home/ute/MN/UTE/robotws/ -maxdepth 1 -name "*aasyslog_tput.txt" -exec cp {} 
    ...    /home/ute/MN/UTE/robotws/CNI101440_ST_B001_B002_20240327_20240327011129/CNI101440_ST_B001_RRE_To_Origin_Cell \;
    Execute Cmd On Pc    find ${OUTPUT_DIR} -maxdepth 1 -name "*aasyslog_tput.txt" -exec mv {} ${TEST_LOG_DIR} \\;
    Execute Cmd On Pc    mv -f ${OUTPUT_DIR}/${TEST NAME}/* ${TEST_LOG_DIR}
    Execute Cmd On Pc    rm -f ${OUTPUT_DIR}/${TEST NAME}/

UE Trigger RRE To Origin Cell
    [Arguments]    ${attach_cell}=${1}    ${tag}=B001
    BuiltIn.Log    UE Trigger RRE To Origin Cell...    console=${True}
    Start To Capture Wireshark Log    ${tag}
    ${other_cell}    Copy List    ${all_cell_ids}
    Remove Values From List    ${other_cell}    ${attach_cell}
    run keyword if   ${other_cell}    Adjust Cells HBTE Attenuation Value To Max    cellid_list=@{other_cell}
    Adjust Attach Cell HBTE Attenuation Value To Max And Recover Immediately    attach_cell=${attach_cell}
    Sleep    15s
    run keyword if   ${Trf_Check}    UE Start Trf And Check Tput    ue_detach=True
    [Teardown]    Stop Capture Wireshark Log

Adjust Attach Cell HBTE Attenuation Value To Max And Recover Immediately
    [Arguments]    ${attach_cell}=${1}
    BuiltIn.Log    Adjust Attach Cell HBTE Attenuation Value To Max And Recover Immediately...    console=${True}
    Adjust Cell HBTE Attenuation Value    cellid=${attach_cell}    port_value=${PA_Max_Value}
    Sleep    1s
    Adjust Cell HBTE Attenuation Value    cellid=${attach_cell}    port_value=${PA_Min_Value}

Adjust Cells HBTE Attenuation Value To Max
    [Arguments]    ${cellid_list}
    FOR    ${cellid}    IN    @{cellid_list}
        Adjust Cell HBTE Attenuation Value    cellid=${cellid}    port_value=${PA_Max_Value}
    END

UE Trigger RRE To Other Cell
    [Arguments]    ${attach_cell}=${1}    ${target_cell}=${3}    ${tag}=B002
    BuiltIn.Log    UE trigger RRE To Other Cell...    console=${True}
    Start To Capture Wireshark Log    ${tag}
    ${other_cell}    Copy List    ${all_cell_ids}
    Remove Values From List    ${other_cell}    ${attach_cell}
    Remove Values From List    ${other_cell}    ${target_cell}
    run keyword if   ${other_cell}    Adjust Cells HBTE Attenuation Value To Max    cellid_list=@{other_cell}
    Adjust Target Cell HBTE Attenuation Value To Min And Attach Cell To Max Immediately    attach_cell=${attach_cell}    target_cell=${target_cell}
    Sleep    15s
    run keyword if   ${Trf_Check}    UE Start Trf And Check Tput    cellid=${target_cell}    ue_detach=True
    [Teardown]    Stop Capture Wireshark Log

Adjust Target Cell HBTE Attenuation Value To Min And Attach Cell To Max Immediately
    [Arguments]    ${attach_cell}=${1}    ${target_cell}=${3}
    BuiltIn.Log    Adjust Target Cell HBTE Attenuation Value To Min And Attach Cell To Max Immediately...    console=${True}
    Adjust Cell HBTE Attenuation Value    cellid=${target_cell}    port_value=${PA_Min_Value}
    Adjust Cell HBTE Attenuation Value    cellid=${attach_cell}    port_value=${PA_Max_Value}

Adjust Cell HBTE Attenuation Value
    [Arguments]    ${cellid}    ${port_value}
    FOR    ${port}    IN    @{CELL${cellid}_Ports}
        attenuator.set_attenuation     port=${port}    value=${port_value}
        attenuator.read_attenuation    port=${port}
    END

Check Wireshark And Counters For B001
    BuiltIn.Log    Check Wireshark By Tshark For B001...    console=${True}
    Run Keyword And Continue On Failure    Check Wireshark By Tshark For B001
    BuiltIn.Log    Check Counters For B001...    console=${True}
    Check Counters    ${PM_COUNTER_B001}

Check Wireshark And Counters For B002
    BuiltIn.Log    Check Wireshark By Tshark For B002...    console=${True}
    Run Keyword And Continue On Failure    Check Wireshark By Tshark For B002
    BuiltIn.Log    Check Counters For B002...    console=${True}
    Check Counters    ${PM_COUNTER_B002}

Check Wireshark And Counters For B003
    BuiltIn.Log    Check Wireshark By Tshark For B003...    console=${True}
    Run Keyword And Continue On Failure    Check Wireshark By Tshark For B003
    BuiltIn.Log    Check Counters For B003...    console=${True}
    Check Counters    ${PM_COUNTER_B003}

Check Wireshark And Counters For B004
    BuiltIn.Log    Check Wireshark By Tshark For B004...    console=${True}
    Run Keyword And Continue On Failure    Check Wireshark By Tshark For B004
    BuiltIn.Log    Check Counters For B004...    console=${True}
    Check Counters    ${PM_COUNTER_B004}

Check Wireshark By Tshark For B001
    ${File_Name}    Catenate    ${SAVE LOG DIRECTORY}${/}/wireshark_B001.pcap
    Check RRE Event PCMD Records    File_Name=${File_Name}    cellinfo=${Cell1}
    Check Periodic PCMD Records    File_Name=${File_Name}    cellinfo=${Cell1}

Check RRE Event PCMD Records
    [Arguments]    ${File_Name}    ${cellinfo}=${Cell1}
    ${Count}    Get Wireshark Message Count    ${File_Name}    ${rrcReestablishmentRequest}
    Should Be True    ${Count}>=1
    ${Count}    Get Wireshark Message Count    ${File_Name}    ${rrcReestablishment}
    Should Be True    ${Count}>=1
    ${Count}    Get Wireshark Message Count    ${File_Name}    ${rrcReestablishmentComplete}
    #Should Be True    ${Count}>=1
    ${Count}    Get Wireshark Message Count    ${File_Name}    ${initialUeRrcMessageTransferSndTime} && ${cellinfo}
    Should Be True    ${Count}>=1
    FOR    ${filter}    IN    @{RRC_Setup_PCMD}
        ${Count}    Get Wireshark Message Count    ${File_Name}    ${filter} && ${cellinfo}
        Should Be True    ${Count}>=0
    END

Check RRE FB Event PCMD Records
    [Arguments]    ${File_Name}    ${cellinfo}=${Cell1}
    ${Count}    Get Wireshark Message Count    ${File_Name}    ${rrcReestablishmentRequest}
    Should Be True    ${Count}>=1
    ${Count}    Get Wireshark Message Count    ${File_Name}    ${rrcReestablishment}
    Should Be True    ${Count}>=0
    ${Count}    Get Wireshark Message Count    ${File_Name}    ${rrcReestablishmentComplete}
    Should Be True    ${Count}>=0
    ${Count}    Get Wireshark Message Count    ${File_Name}    ${ueCtxSetupReqRcvTime} && ${cellinfo}
    Should Be True    ${Count}>=1
    ${Count}    Get Wireshark Message Count    ${File_Name}    ${ueCtxSetupCmplSndTime} && ${cellinfo}
    Should Be True    ${Count}>=1
    FOR    ${filter}    IN    @{RRC_Setup_PCMD}
        ${Count}    Get Wireshark Message Count    ${File_Name}    ${filter} && ${cellinfo}
        Should Be True    ${Count}>=1
    END

Check Periodic PCMD Records
    [Arguments]    ${File_Name}    ${cellinfo}=${Cell1}
    FOR    ${filter}    IN    @{RRE_Periodic_PCMD}
        ${Count}    Get Wireshark Message Count    ${File_Name}    ${filter} && ${cellinfo}
        Should Be True    ${Count}>=${Periodic_Count}
    END

Check Wireshark By Tshark For B002
    ${File_Name}    Catenate    ${SAVE LOG DIRECTORY}${/}/wireshark_B002.pcap
    Check RRE Event PCMD Records    File_Name=${File_Name}    cellinfo=${Cell3}
    Check Periodic PCMD Records    File_Name=${File_Name}    cellinfo=${Cell3}

Check Wireshark By Tshark For B003
    ${File_Name}    Catenate    ${SAVE LOG DIRECTORY}${/}/wireshark_B003.pcap
    Check RRE FB Event PCMD Records    File_Name=${File_Name}    cellinfo=${Cell1}
    Check Periodic PCMD Records    File_Name=${File_Name}    cellinfo=${Cell1}

Check Wireshark By Tshark For B004
    ${File_Name}    Catenate    ${SAVE LOG DIRECTORY}${/}/wireshark_B004.pcap
    Check RRE FB Event PCMD Records    File_Name=${File_Name}    cellinfo=${Cell3}
    Check Periodic PCMD Records    File_Name=${File_Name}    cellinfo=${Cell3}
