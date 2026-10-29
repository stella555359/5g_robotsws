*** Settings ***
Documentation    ...
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource           ./CB009854_resource.robot
#Suite Setup        Common Suite Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1
#...                RAN_5G    RAN_5G_TDD
#*** Variables ***
#${SCF_PATH}                    ${CURDIR}/config/SCF
#${LOG_PATH}                    ${OUTPUT DIR}
#${LOCAL_WTS_DIR}               ${CURDIR}/config/WTS
#${WTS_DIR}                     /opt/iphy/latest
#${scf_ca_fdd_tdd}              ${SCF_PATH}/scf_CB009854_3F3T.xml
#${scf_ca_AB06}                 ${SCF_PATH}/AB06_SCF.xml
#${iphy_CB009854_3F4T}          ${CURDIR}/config/IPHY/iphy_CB009854_3F4T.xml
#${iphy_CB009854_AB06}          ${CURDIR}/config/IPHY/iphy_CB009854_AB06.xml
#${WTS_CFG_CA}                  wts_CB009854.cfg
#${WTS_CFG_AB06}                wts_9854_AB06.cfg
#${SWCONFIG_AA_02}              0x4B000F=1;0x3F007C=1024;0x58012d=4;
#${UE3_ID}                      3
#${UE30_ID}                     30
#${4CC_2F2T_SCELL}             ('1', '51', '25'), ('2', '52', '66'), ('3', '54', '41')
#${5CC_3F2T_SCELL}             ('1', '51', '25'), ('2', '52', '66'), ('3', '54', '41'), ('4', '55', '41')
#${5CC_2F3T_SCELL}             ('1', '51', '25'), ('2', '54', '41'), ('3', '55', '41'), ('4', '56', '77')
#${5CC_3F2T_SRS_SCELL}         ('1', '51', '66'), ('2', '52', '66'), ('3', '54', '77'), ('4', '56', '77')
#@{5CC_scell_index}            1    2    3    4
#${egate_console_log}          /opt/wts/latest/egate_console.log
#${Egatelog_path}              ${CURDIR}
#@{dlonly_scell_index}         1    3    4
#@{no_scell_index}             2
#${scf_ca_fdd_tdd5QI5}              ${SCF_PATH}/scf_CB009854_3F3T_5QI5.xml
#${WTS_CFG_AA06}                wts_CB0098545QI5.cfg
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
##CB009854AA-ET-002_Online_to_enable_5CC_and_trigger_scell_active_
##    [Documentation]
##    ...    Precondition:
##    ...      3FDD+2TDD
##    ...      Frame structure=1208
##    ...      maxNumSCellsDlFr1 = 3
##    ...    Test Steps:
##    ...      Step1: UE3 attach to FDD cell as pcell
##    ...      Step2: Modify NIDD parameter maxNumSCellsDlFr1 = 4
##    ...      Step3: UE30 attach to FDD cell as pcell
##    ...      Step4: Modify NIDD parameter maxNumSCellsDlFr1 = 3，detach UE30
##    ...      Step5: UE30 attach to FDD cell as pcell
##    ...      Step6: Release all UEs.
##    ...    Check Points:
##    ...      1)After step1, only 3Scells addition, UL and DL data transfer successfully, Verify no DTX.
##    ...      2)After step3, 4Scells (2F+2T) active successfully, UL and DL data transfer successfully, Verify no DTX.
##    ...      3)After step5, only 3Scells addition, UL and DL data transfer successfully, Verify no DTX.
##    ...      3)After step6, Release all UEs.
##    [Tags]     case_AA02    Manual_dguan    TA_qianwu    CRT
##    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CA}
##    ...        AND    Suite Setup Update GNB    scf_file=${scf_ca_fdd_tdd}    swconfig_param=${SWCONFIG_AA_02}    iphy_file=${iphy_CB009854_3F4T}
##    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
##    ...        AND    Common Test Setup 2
##    Online Modify NIDD    ${SCF_PATH}/maxNumSCellsDlFr1_3.xml
##    CB009854_resource.Start WTS And Check OnAir
##    #Step1
##    L3 Call For UE    ${UE3_ID}    ${4CC_2F2T_SCELL}    200    100
##    Check UL And DL DTX From Ttitrace    log_id=1    duration=2
##    #Step2
##    Online Modify NIDD    ${SCF_PATH}/maxNumSCellsDlFr1_4.xml
##    #Step3
##    L3 Call For UE    ${UE30_ID}    ${5CC_3F2T_SCELL}    200    100
##    Check UL And DL DTX From Ttitrace    log_id=2    duration=2
##    #Step4
##    Online Modify NIDD    ${SCF_PATH}/maxNumSCellsDlFr1_3.xml
##    SA 5G Detach    ${UE30_ID}
##    #Step5
##    L3 Call For UE    ${UE30_ID}    ${4CC_2F2T_SCELL}    200    100
##    Check UL And DL DTX From Ttitrace    log_id=3    duration=2
##    #Step6
##    SA 5G Detach    ${UE3_ID}
##    SA 5G Detach    ${UE30_ID}
#
##CB009854AA-ET-003_Buffer_based_scell_active_and_deactive_
##    [Documentation]
##    ...    Precondition:
##    ...      2FDD+3TDD
##    ...      Frame structure=1116 0ms
##    ...    Test Steps:
##    ...      Step1: UE3 attach to FDD cell as pcell
##    ...      Step2: UE report A1 to trigger scells additon
##    ...      Step3: Start big DL data transfer to trigger all scell active
##    ...      Step4: start UL data then Stop Dl data
##    ...      Step5: Stop UL data
##    ...      Step6: start UL data transfer
##    ...      Step7: Start big DL data transfer
##    ...      Step8: Relase call
##    ...    Check Points:
##    ...      1)After step1, Verify FTTT Scell addditon successfully.
##    ...      2)After step3, Verify all the scell active at same time by DL data transfer.
##    ...      3)After step4, only UL+DL scell keep activing due to UL data transfer.
##    ...      4)After step5, UL+DL scell deactive
##    ...      5)After step6, UL+DL scell active again.
##    ...      6)After step7, all scell shcedule correctly.
##    ...      7)After step8, Release all UEs.
##    [Tags]     case_AA03    Manual_dguan    TA_suqian   CRT
##    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CA}
##    ...        AND    Suite Setup Update GNB    scf_file=${scf_ca_fdd_tdd}    swconfig_param=${SWCONFIG_AA_02}    iphy_file=${iphy_CB009854_3F4T}
##    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
##    ...        AND    Common Test Setup 2
#
##    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_AA03.xml
##    Delta Commission With SCF File    ${json_file}
##    CB009854_resource.Start WTS And Check OnAir
##    #step1
##    SA Single UE Attach    ${UE3_ID}
##    #step2
##    Trigger A1 Scell Addition    ${UE3_ID}    85    53
##    Get And Check Scell Infos    ${5CC_2F3T_SCELL}
##    #step3
##    Start SA UE Big DL Traffic Internal    ${UE3_ID}    1000
##    Sleep    5s    reason=Wait for traffic stable
##    Verify Scells Are Activation    5
##    #step4
##    Start SA UE Big UL Traffic Internal    ${UE3_ID}    200
##    Sleep    5s    reason=Wait for traffic stable
##    SA Stop Data Traffic Internal    ue_id=${UE3_ID}    pdu_id=1    dir=dl
##    Sleep    5s    reason=Wait for traffic stable
##    Verfiy Scells Are All Deactivation    ${dlonly_scell_index}
##    #step5
##    SA Stop Data Traffic Internal    ue_id=${UE3_ID}    pdu_id=1    dir=ul
##    Sleep    5s    reason=Wait for traffic stable
##    Verfiy Scells Are All Deactivation    ${no_scell_index}
##    #step6
##    Start SA UE Big UL Traffic Internal    ${UE3_ID}    200
##    #step7
##    Start SA UE Big DL Traffic Internal    ${UE3_ID}    1000
##    Sleep    5s    reason=Wait for traffic stable
##    Verify Scells Are Activation    5
##    Check UL And DL DTX From Ttitrace    log_id=1    duration=2
##    #Step8
##    SA 5G Detach    ${UE3_ID}
#
##CB009854AB-ET-006_SRS_based_beamforming__for_UE_configured__2F3T
##    [Documentation]
##    ...    Precondition:
##    ...      3FDD+2TDD
##    ...      Frame structure=1208
##    ...    Test Steps:
##    ...      Step1: UE3 attach to FDD cell as pcell
##    ...      Step2: UE report A1 to trigger scells additon
##    ...      Step3: Start UL and DL data transfer.
##    ...      Step4: UE send periodic SRS , CSI report for beam and CQI.
##    ...      Step5: Stop data to trigger DRX inactive.
##    ...      Step6: start big data for UL and DL.
##    ...      Step7: UE report A2 UL+DL scell release.
##    ...      Step8: UE report A1 for UL+DL scell addition.
##    ...      Step9: Release call.
##    ...    Check Points:
##    ...      1)After step1, Verify Scell addditon successfully.
##    ...      2)After step2, Scell addition successfully.
##    ...      3)After step3, data transfer on pcell and scell correctly,Verify CSI report and  periodic SRS receive from scell , no coma DTX.
##    ...      4)After step5, UE enter to DRX inactive status.  GNB will not receive periodc SRS and CSI report.
##    ...      5)After step6, UL and DL data transfer again. Verify CSI report and  periodic SRS receive from scell , no coma DTX.
##    ...      6)After step7, UL+DL TDD scell release. ther are no periodic SRS due to TDD UL scell release.
##    ...      7)After step8, UL+DL scell scheudle again,Verify CSI report and  periodic SRS receive from scell , no coma DTX.
##    ...      8)After step9, UE releases
##    [Tags]     case_AB06    Manual_dguan    TA_suqian   CRT
##    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_AB06}
##    ...        AND    Suite Setup Update GNB    scf_file=${scf_ca_AB06}    swconfig_param=${SWCONFIG_AA_02}    iphy_file=${iphy_CB009854_AB06}
##    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
##    ...        AND    Common Test Setup 2
##    #step1
##    CB009854_resource.Start WTS And Check OnAir
##    SA Single UE Attach    ${UE3_ID}
##    #step2
##    Trigger A1 Scell Addition    ${UE3_ID}    85    53
##    Get And Check Scell Infos    ${5CC_3F2T_SRS_SCELL}
##    #step3
##    Start SA UE Big DL Traffic Internal    ${UE3_ID}    1000
##    Start SA UE Big UL Traffic Internal    ${UE3_ID}    200
##    #Sleep    5s    reason=Wait for traffic stable
##    Common log check for Srs    1
##    #step5
##    SA Stop Data Traffic Internal    ue_id=${UE3_ID}    pdu_id=1
##    Sleep    5s    reason=Wait for traffic stable
##    Common log check for No Srs    2
##    #step6
##    Start SA UE Big DL Traffic Internal    ${UE3_ID}    1000
##    Start SA UE Big UL Traffic Internal    ${UE3_ID}    200
##    Sleep    5s    reason=Wait for traffic stable
##    Common log check for Srs    3
##    #step7
##    trigger A2 Release For Scells
##    Sleep    5s    reason=Wait for stable
##    Common log check for No Srs    4
##    #step8
##    Trigger A1 Scell Addition    ${UE3_ID}    85    53    6
##    Verify Scells Are Activation    5
##    Common log check for Srs    5
##    Check UL And DL DTX From Ttitrace    log_id=1    duration=2
##    #Step9
##    SA 5G Detach    ${UE3_ID}
#
##CB009854AB-ET-001_SCell_deactivation_via_overheating_assistance_functionality
##    [Documentation]
##    ...    Precondition:
##    ...      2FDD+3TDD
##    ...      Frame structure=1208
##    ...    Test Steps:
##    ...      Step1: UE attach to FDD cell as pcell
##    ...      Step2: UEs report A1 to trigger TDD scell additon.
##    ...      Step3: Start UL and DL data transfer.
##    ...      Step4: UE report Assistance Information message containing reducedCCsDL=0 and reducedCCsUL=1
##    ...      Step5: UE report Assistance Information message containing reducedCCsDL=4 and reducedCCsUL=2
##    ...      Step6: UE report Assistance Information message containing reducedCCsDL=4 and reducedCCsUL=0
##    ...      Step7: UE report Assistance Information message containing reducedCCsDL=4 and reducedCCsUL=1
##    ...      Step8: UE report Assistance Information message containing reducedCCsDL=3 and reducedCCsUL=0
##    ...      Step9: UE report Assistance Information message containing reducedCCsDL=1 and reducedCCsUL=0
##    ...    Check Points:
##    ...      1)Verify Scell addditon successfully
##    ...      2)data transfer on pcell and scells DL and UL correctly
##    ...      3)After step4, All scells deactived
##    ...      4)After step5 all the scells active and data on DL&UL for each cells successfully
##    ...      5)After step6 UL+DL scell deactive
##    ...      6)After step7 UL+DL scell active again and one of DL scell release by the ADR algorithm
##    ...      7)After step8, Dl only scell active again and DL+UL scell deactive
##    ...      8)After step9, only one DLonly scell activing. all others scell deactived
##    ...      9)Verify no DTX on PUCCH F1&F3 for HARQ & CSI repot
##    [Tags]     case_AB01    Manual_qianwu    TA_dguan   CRT
##    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CA}
##    ...        AND    Suite Setup Update GNB    scf_file=${scf_ca_fdd_tdd}    swconfig_param=${SWCONFIG_AA_02}    iphy_file=${iphy_CB009854_3F4T}
##    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
##    ...        AND    Common Test Setup 2
#
##    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_AB01.xml
##    Delta Commission With SCF File    ${json_file}
##    CB009854_resource.Start WTS And Check OnAir
##   #step1
##    SA Single UE Attach    ${UE3_ID}
##    #step2
##    #Scell Addition Triggered By A1 Event    ${UE3_ID}    1    85
##    Trigger A1 Scell Addition    ${UE3_ID}    85    53
##    Get And Check Scell Infos    ${5CC_2F3T_SCELL}
##    #step3 scell1-4 activated
##    Start SA UE Big DL Traffic Internal    ${UE3_ID}    1000
##    Start SA UE Big UL Traffic Internal    ${UE3_ID}    200
##    Sleep    5s    reason=Wait for traffic stable
##    Check Scell ActiveDeactivate Times    1    5    activated    1
##    #step4 scell1-4 deactivated
##    Send OAI To GNB    3    yes    0    1
##    Check Scell ActiveDeactivate Times    1    5    deactivated    1
##    #step5 scell1-4 activated
##    Send OAI To GNB    3    yes    4    2
##    Check Scell ActiveDeactivate Times    1    5    activated    2
##    #step6 scell2 deactivate
##    Send OAI To GNB    3    yes    4    0
##    Check Scell ActiveDeactivate Times    2    3    deactivated    2
##    Check UL And DL DTX From Ttitrace    log_id=1    duration=2
##    #step7 scell2 activate
##    Send OAI To GNB    3    yes    4    1
##    Check Scell ActiveDeactivate Times    2    3    activated    3
##    Check UL And DL DTX From Ttitrace    log_id=2    duration=2
##    #step8 scell2 deactivate
##    Send OAI To GNB    3    yes    3    0
##    Check Scell ActiveDeactivate Times    2    3    deactivated    3
##    #step9 scell1&4 deactivate
##    Send OAI To GNB    3    yes    1    0
##    Check Scell ActiveDeactivate Times    1    2    deactivated    2
##    Check Scell ActiveDeactivate Times    3    4    deactivated    2
##    Check UL And DL DTX From Ttitrace    log_id=3    duration=2
#
#
#CB009854AA-ET-006_Voice_call_and_none_GBR_call__on_5CC_CA_
#    [Documentation]
#    ...    Precondition:
#    ...      2FDD+3TDD
#    ...      Frame structure=1116 0ms
#    ...    Test Steps:
#    ...      Step1: UE3 attach to FDD cell as pcell
#    ...      Step2: Start big DL data transfer to trigger all scell active
#    ...      Step3: start DL BLER
#    ...      Step5: check highestClassPriority
#    ...      Step6: Relase call
#    ...    Check Points:
#    ...      1)After step1, Verify FTTT Scell addditon successfully.
#    ...      2)After step3, Verify all the scell active at same time by DL data transfer.
#    ...      3)After step4, check DL BLER successfully
#    ...      4)After step5, check highestClassPriority
#    ...      5)After step8, Release all UEs.
#    [Tags]     case_AA03    Manual_dguan    TA_suqian   CRT
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_AA06}
#    ...        AND    Suite Setup Update GNB    scf_file=${scf_ca_fdd_tdd5QI5}    swconfig_param=${SWCONFIG_AA_02}
#    ...               iphy_file=${iphy_CB009854_3F4T}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#
#    #step1
#    CB009854_resource.Start WTS And Check OnAir
#    SA Single UE Attach    ${UE3_ID}
#    #step2
#    Start SA UE Big DL Traffic Internal    ${UE3_ID}    1000
#    Start SA UE Big UL Traffic Internal    ${UE3_ID}    200
#    Sleep    5s    reason=Wait for traffic stable
#    Check Scell ActiveDeactivate Times    1    5    activated    1
#    Start Ttitrace With Streaming Mode
#    #Step1
#    Set Value For BLER Testmode    profile_id=31    dl_bler=1000,1000,1000,1000,0,0,0,0
#    CUDU L2 Send Action To GNB    ue_id=${UE3_ID}    testmode=bler    action=activate    profile_id=31    scell=1
#    Sleep    2s    reason=Wait for traffic stable
#    Stop Ttitrace
#    Decode Ttitrace Log    ${OUTPUT_DIR}/ttitrace_streaming/
#    ${prioriy_list}=    TTITRACEANALYZER.FiLter Source Column Return Self    ${OUTPUT_DIR}/ttitrace_streaming/output_dl.csv
#    ...    dlPreSchedData.highestClassPriority
#    Should Contain Any    ${prioriy_list}    7.0    2.0
#
#*** Keywords ***
#
#
