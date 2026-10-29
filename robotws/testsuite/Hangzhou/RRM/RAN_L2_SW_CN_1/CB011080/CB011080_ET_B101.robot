*** Settings ***
Test Teardown     Common Test Teardown
Suite Teardown    Common Suite Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    VRF4_SG11    CB012528    owner_qiaren
Resource          resources/CB011080_resource.robot

Documentation
...     CB011080_ET_B101_Verify_6CC_OAI_PM_Counters_Update

*** Variables ***
${SCF_PATH}                 ${CURDIR}/Config/
${SCFC_FILE}                CB011080_A801_Full_SCF.xml
${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
${WTS_DIR}                  /opt/iphy/latest
${IPHY_XML}                 ${CURDIR}/Config/wts/iphy_CB011080_A801.xml
${WTS_CFG}                  CB011080_A801.lua
${SWCONFIG_PARAM_GNB}       0x890071=1;

${UE_1}                     1
${UE_2}                     2

${MCC}                      311
${MNC}                      489
${AMF1_REGION}              1:2:2
${AMF2_REGION}              2:3:3

${6CC}                  6
@{UE1_3T3F_DL_TPUT}         100    20    45    50    150    100
@{UE2_2T4F_DL_TPUT}         150    150    10    45    100    100
@{UE1_UL_TPUT_LIST}         23    62
@{UE2_UL_TPUT_LIST}         23    100
@{6CC_SCELL_PCI_3T3F}       51    52    53    54    55
@{6CC_SCELL_PCI_2T4F}       50    51    52    53    56

${5_SCELL_ALLOW_OVH_ID}           M55118C00055
${CELL6_COUNTER_PATH}             CELLS/NRCELL-6/NCAC
${CELL7_COUNTER_PATH}             CELLS/NRCELL-7/NCAC


*** Test Cases ***
CB011080_ET_B101_Verify_6CC_OAI_PM_Counters_Update
    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}    #swconfig_param=${SWCONFIG_PARAM_GNB}
    #[Setup]    Run Keywords      Suite Setup Update GNB    force_reboot=True
    ...        AND    Configure IP For UEC2
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
    ...        AND    Common Test Setup
    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
    Two UE Attach And Check Traffic
    Send Assistance Information And Check Scell Active Status    ${UE_1}     0    1    5    deactivated
    Send Assistance Information And Check Scell Active Status    ${UE_2}     0    1    5    deactivated
    Wait Until Keyword Succeeds    20s    2s   Check All Scells Schedule Stop
    Send Assistance Information And Check Scell Active Status    ${UE_1}     5    1    5    activated
    Send Assistance Information And Check Scell Active Status    ${UE_2}     5    1    5    activated
    Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_1}    ${UE1_3T3F_DL_TPUT}    ${6CC}
    Wait Until Keyword Succeeds    30s    5s    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_1}    ${UE1_UL_TPUT_LIST}    ${6CC}
    Wait Until Keyword Succeeds    10min    2min    Check PM Counter for OAI 1th Time
    Send Assistance Information And Check Scell Active Status    ${UE_1}     2    1    3    deactivated
    Send Assistance Information And Check Scell Active Status    ${UE_1}     5    1    5    activated
    Wait Until Keyword Succeeds    10min    2min    Check PM Counter for OAI 2th Time

*** Keywords ***
Two UE Attach And Check Traffic
    Single Ue Attach    ${UE_1}    ${AMF1_REGION}
    Check SA All Scell PhysicalID With UE ID    ${UE_1}    ${6CC_SCELL_PCI_3T3F}    ${6CC}
    Start SA UE Big DL Traffic Internal    ${UE_1}    1500
    Start SA UE Big UL Traffic Internal    ${UE_1}    200
    Single Ue Attach    ${UE_2}    ${AMF2_REGION}
    Check SA All Scell PhysicalID With UE ID    ${UE_2}    ${6CC_SCELL_PCI_2T4F}    ${6CC}
    Start SA UE Big DL Traffic Internal    ${UE_2}    1500
    Start SA UE Big UL Traffic Internal    ${UE_2}    200
    Sleep    10s    reason=wait 30s for traffic statble
    Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_1}    ${UE1_3T3F_DL_TPUT}    ${6CC}
    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_1}    ${UE1_UL_TPUT_LIST}    ${6CC}
    Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_2}    ${UE2_2T4F_DL_TPUT}    ${6CC}
    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_2}    ${UE2_UL_TPUT_LIST}    ${6CC}
    Capture And Check TTitrace Logs    1

Send Assistance Information And Check Scell Active Status
    [Arguments]    ${ue_id}    ${reducedCCsDL}    ${reducedCCsUL}    ${cell_nums}    ${scell_active_status}=activated
    Send OAI To GNB    ${ue_id}    yes    ${reducedCCsDL}    ${reducedCCsUL}
    Check Scell Active Status From Egate    ${cell_nums}    ${scell_active_status}

Check Scell Active Status From Egate
    [Arguments]    ${scell_nums}    ${scell_active_status}=activated
    ${loop}    Evaluate    ${scell_nums}+1
    Log To Console    \nverify Scell Activation or Deactivation Info...
    FOR    ${id}    IN RANGE    1    ${loop}
    Check Scell Status    ${id}    ${scell_active_status}
    END

Check Scell Status
    [Arguments]    ${scell_index}=1    ${scell_active_status}=activated    ${egate_file}=/opt/iphy/latest/egate_console.log.001
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${scell_activation}    Set Variable    SCellIndex ${scell_index} ${scell_active_status} successfully.
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${match_list}    Get Regexp Matches    ${content}    ${scell_activation}
    ${check_rst}    Get Length    ${match_list}
    ${scell_status}    Set Variable If    ${check_rst}>=1    pass    failed
    [Return]    ${scell_status}

Check Scell DL Schedule Stop
    [Arguments]    ${ue_id}    ${scell_index}
    ${scell_TP_DL}    Get CA Cell Average Throughput    ${ue_id}     dl    scell    ${scell_index}
    Log To Console    DL Troughput is ${scell_TP_DL}    console=True
    Should Be True    ${scell_TP_DL}==0

Check Scell UL Schedule Stop
    [Arguments]    ${ue_id}    ${scell_index}
    ${scell_TP_UL}    Get CA Cell Average Throughput    ${ue_id}     ul    scell    ${scell_index}
    Log To Console    DL Troughput is ${scell_TP_UL}    console=True
    Should Be True    ${scell_TP_UL}==0

Check All Scells Schedule Stop
    Check CA UE Pcell Scell Cell TPut On Target    ${UE_1}    dl    pcell    0     195
    Check CA UE Pcell Scell Cell TPut On Target    ${UE_2}    dl    pcell    0     195
    Check Scell DL Schedule Stop    ${UE_1}    1
    Check Scell DL Schedule Stop    ${UE_1}    2
    Check Scell DL Schedule Stop    ${UE_1}    3
    Check Scell DL Schedule Stop    ${UE_1}    4
    Check Scell DL Schedule Stop    ${UE_1}    5
    Check Scell UL Schedule Stop    ${UE_1}    2
    Check Scell DL Schedule Stop    ${UE_2}    1
    Check Scell DL Schedule Stop    ${UE_2}    2
    Check Scell DL Schedule Stop    ${UE_2}    3
    Check Scell DL Schedule Stop    ${UE_2}    4
    Check Scell DL Schedule Stop    ${UE_2}    5
    Check Scell UL Schedule Stop    ${UE_2}    1

Check PM Counter for OAI 1th Time
    Check PM Counter Value    ${5_SCELL_ALLOW_OVH_ID}    ${CELL6_COUNTER_PATH}    1
    Check PM Counter Value    ${5_SCELL_ALLOW_OVH_ID}    ${CELL7_COUNTER_PATH}    1

Check PM Counter Value
    [Arguments]    ${counter_id}    ${counter_path}    ${exp_value}
    ${counter_value}    Get PM Counter Latest Value From Admin    ${counter_id}    ${counter_path}
    should be true    ${counter_value}==${exp_value}

Check PM Counter for OAI 2th Time
    Check PM Counter Value    ${5_SCELL_ALLOW_OVH_ID}    ${CELL6_COUNTER_PATH}    0
    Check PM Counter Value    ${5_SCELL_ALLOW_OVH_ID}    ${CELL7_COUNTER_PATH}    1
