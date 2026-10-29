*** Settings ***
Documentation
...
Resource           ./../CUDU_L2/common_setup_teardown.robot
Resource           ./CB009550_resource.robot
Library            ../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb
Suite Setup        Run Keywords    Common Suite Setup 2
...                AND    Prepare QT LOLO Enviroment    TYPE=TDD
Test Teardown      Run Keywords    Send Swconfig for GNB    ${gnb_swconfig}
...                AND    Send Swconfig for AP    ${ap_swconfig}
...                AND    Modify GSCN On Airphone    ${cell1_ID}    7880
...                AND    Common Test Teardown 2
Suite Teardown     Common Suite Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    CN1_SG09_SM1    CB009550

*** Variables ***
${SCF_PATH}                 ${CURDIR}/config/SCF
${LOCAL_WTS_DIR}            ${CURDIR}/config/WTS
${WTS_DIR}                  /opt/iphy/latest
${FrameStrc_SCF}            ${SCF_PATH}/CB009550_FrameStrc_SCF.xml
${SCF_B033}                 ${SCF_PATH}/CB009550_B033.xml
${gnb_swconfig}         /home/ute/.ute-ca/executions/1/configs/topology_configs/node_1/SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC/swconfig_gnb.txt
${ap_swconfig}          /home/ute/.ute-ca/executions/1/configs/topology_configs/node_1/SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC/swconfig_ap.txt
${SWCONFIG_PARAM_AP}        0x70699=0;
${IPHY_B033}                ${CURDIR}/config/WTS/B033iphy.xml
${SWCONFIG_PARAM_IPY}       0x4B000F=1;
${WTS_CFG_TDD}              CB009550_sansa.lua
${WTS_CFG_B033}             CB009550_sansa_B033.lua
${WTS_MULTI_UE}             multi_ue_sa_script.lua
${WTS_MULTI_UE_PDU}         multi_ue_sa_script_pdu.lua
${WTS_CFG_TDD_40M}          CB009550_sansa_40M.lua
${WTS_CFG_TDD_IntergnbHO}   cfra_basic_setup.cfg
${UE1_ID}                   1
${cell1_ID}                 50
${gscn_B011}                7915
${MAX_Trigger_TIME}         20
${cell_name}                MRBTS-1/NRBTS-1/NRCELL-1
${GNB_WIRESHARK_CMD}        tcpdump -i any -u sctp -w /ffs/run/logs/wireshark_gnb.pcap
${CELL1_SIB}                eNB 2 cell 1: SystemInformationBlockType2-NR updated
${cell2_ID}                 51
${gscn_B034}                8019
${UE_NUM}                   50
${dist_name}                MRBTS-1/NRBTS-1/NRCELL-1
${parameter}                actSmallestRRCSetup
${value}                    true
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}


*** Test Cases ***
#CB009550-ET-B006_FDM_of_transient_UE_with_SIB1_and_OSI_and_Paging_in_TDD_SA_with_beamforming_enabled
#    [Documentation]
#    ...    Precondition:
#    ...      TDD 100M 48PRB
#    ...      Frame structure=1116-3
#    ...    Test Steps:
#    ...      Step1: Register other SA UEs, and setup PDU(tranient UEs).
#    ...      Step2:Send traffic for two of the multiplexed UEs.
#    ...    Check Points:
#    ...      1)Check  SIB1/OSI/ can be multiplexed with transient UEs on same slot.
#	...      2)L2-PS shall allocate Msg2/Msg4/SRB1(Transient UE) contiguous to Paging allocation and
#    ...        shall ensure there is no gap in the resource allocation
#    ...      3)Check UL and DL traffic is OK.
#    [Tags]    caseB006    Manual_suqian    TA_suqian
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_TDD}
#    ...        AND    Suite Setup Update GNB    scf_file=${FrameStrc_SCF}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    #Step1
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_B006.xml
#    Delta Commission With SCF File    ${json_file}
#    Verify Coam Site Is Ready
#    Copy File For Multi UEs    ${WTS_MULTI_UE}
#    Suite Setup Start WTS And Check OnAir
#    Multi UEs Attach By Script    ${WTS_MULTI_UE}    1    50
#    #Step2
#    Trigger multi UEs L3 Call and Capture Bip Log
#    #Check Point1
#    Check TranisentUE Multi With SIB1/OSI
#    #Check Point2
#    Check TransientUE PRB Contiguous
#    #Check Point3
#    UE L3 Call For B006    3    5    10

CB009550-ET-B007_FDM_of_msg2_or_msg4_with_SIB1_and_OSI_in_TDD_SA_with_beamforming_enabled
    [Documentation]
    ...    Precondition:
    ...      TDD 100M 48PRB
    ...      Frame structure=1116-0
    ...    Test Steps:
    ...      Step1: muliti UE attach to trigger SIB1/OSI multiplex with msg2/msg4
    ...      Check Point:
    ...        1)Check SIB1 OSI can be multiplexed with msg2 and msg4 on same slot and no DTX for msg4
    ...        2)L2-PS shall allocate Msg2/Msg4 contiguous to SIB allocation and shall ensure there is no gap
    ...        in the resource allocation
    [Tags]    caseB007    Manual_dguan    TA_dguan
    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_TDD}
    ...        AND    Suite Setup Update GNB    scf_file=${FrameStrc_SCF}    swconfig_param_AP=${SWCONFIG_PARAM_AP}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    #Step1
    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_B007.xml
    Delta Commission With SCF File    ${json_file}
    Verify Coam Site Is Ready
    Suite Setup Start WTS And Check OnAir
    FOR    ${index}    IN RANGE    1    4
        Log To Console    ===============Trigger Time: ${index}==============
        Start Ttitrace With Streaming Mode
        #Step1
        Trigger SIB1/OSI Multi with msg2/msg4 By MUE Testmode
        Stop Ttitrace
        Decode Ttitrace Log    ${OUTPUT_DIR}/ttitrace_streaming/
        #Check Point1 & 2
        ${res}    Run Keyword And Return Status    Check SIB1/OSI Multi with msg2/msg4 and PRB Contiguous
        ${Trigger_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
        ${cmd}    Set Variable    ue_deregister id=1-24 ue_deregister_type=switch_off
        Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command    ${cmd}
        Sleep    5s    reason=Wait for all ue dettached.
        Exit For Loop If    '${res}'=='True'
    END
    Should Be True    "${Trigger_sucess_flag}"=="${True}"

CB009550-ET-B011_Alarm_raised_when_configuring_minRbReservedForNonSiPaging_to_a_wrong_value_when_Coreset0_size_is_48
    [Documentation]
    ...    Precondition:
    ...      TDD 40M 48PRB
    ...      Frame structure=1116-0
    ...    Test Steps:
    ...      Step1: Configure minRbReservedForNonSiPaging=35
    ...      Step2: Configure minRbReservedForNonSiPaging=34
    ...      Step3: UE attach to trigger multiplex
    ...    Check Points:
    ...      1)After step1, in PsCell_CellSetupResp, status=NOK,with cause is MinRBReservedForNonSiPaginExceededTheLimit.
    ...      2)After step2, the alarm should cleard.
    ...      3)Check actFdmSchedulingInitialBWP=true in PsCell_CellSetupReq.
    ...        Check minRbReservedForNonSiPaging and raMsg2TargetRateIndex is right in PsCell_CellSetupReq.
    ...      4)After step3, check msg2 multiplexed with msg4.
    [Tags]    caseB011    Manual_qianwu    TA_qianwu
    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_TDD_40M}
    ...        AND    Modify GSCN On Airphone    ${cell1_ID}    ${gscn_B011}
    ...        AND    Suite Setup Update GNB    scf_file=${FrameStrc_SCF}    swconfig_param_AP=${SWCONFIG_PARAM_AP}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_B011.xml
    Delta Commission With SCF File    ${json_file}
    Verify Coam Site Is Ready
    Suite Setup Start WTS And Check OnAir
    #Step1
    Modify MinRbReservedForNonSiPaging To ExceededTheLimit
    #Step2
    Modify MinRbReservedForNonSiPaging To LessTheLimit
    Check Alarm Reported And Clear
    #Step3
    Trigger Msg2 Multiplexed With Msg4
    Check SIB startPRB Fixed
    Multi UE L3 call    5    5    20

#CB009550-ET-B021_FDM_of_msg2s_in_TDD_SA_with_CFRA
#    [Documentation]
#    ...    Precondition:
#    ...      TDD 100M 48PRB
#    ...      Frame structure=1070
#    ...    Test Steps:
#    ...      Step1: Register multi SA Ues
#    ...      Step2: Trigger the Ues HO
#    ...      Step3: Send traffic
#    ...      Check Point:
#    ...        1)Check msg2s can be multiplexed on same slot
#    ...        2)Check UL and DL traffic is OK
#    [Tags]    caseB021    Manual_dguan    TA_dguan
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_TDD_IntergnbHO}
#    ...        AND    Suite Setup Update GNB    scf_file=${FrameStrc_SCF}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    #Step1
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_B021.xml
#    Delta Commission With SCF File    ${json_file}
#    Verify Coam Site Is Ready
#    Configure VM Interface For CFRA HO    10.0.1.50    10.0.1.51
#    Copy File For Multi UEs    ${WTS_MULTI_UE_PDU}
#    Suite Setup Start WTS And Check OnAir
#    FOR    ${index}    IN RANGE    1    4
#        Log To Console    ===============Trigger Time: ${index}==============
#        #Step1
#        Multi UEs Attach By Script    ${WTS_MULTI_UE_PDU}    1    4
#        #Step2
#        Trigger Inter GNB Handover With CFRA
#        #Checkpoint1
#        ${res}    Run Keyword And Return Status    Check Msg2 Multiplexed With Msg2    A2A_path=A2A_B021
#        ${Trigger_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
#        ${cmd}    Set Variable    ue_deregister id=1-4 ue_deregister_type=switch_off
#        Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command    ${cmd}
#        Sleep    5s    reason=Wait for all ue dettached.
#        Exit For Loop If    '${res}'=='True'
#    END
#    Should Be True    "${Trigger_sucess_flag}"=="${True}"


#CB009550-ET-B033_FDM_of_msg2s_and_msg3s_and_msg4s_and_msg2s_with_msg4s_in_TDD_SA
#    [Documentation]
#    ...    Precondition:
#    ...      TDD 100M 48PRB
#    ...      Frame structure=1208
#    ...    Test Steps:
#    ...      Step1: Register other SA UEs, and setup PDU(tranient UEs).
#    ...      Step2:Send traffic for two of the multiplexed UEs.
#    ...    Check Points:
#    ...      1)Check Msg2 Multiplexed With Msg2 For Different RARNTI
#    ...      2)Check Msg2 Multiplexed With Msg2 For Same RARNTI
#    ...      3)Check Msg3 Multiplexed With Msg3
#    ...      4)Check Msg4 and Msg4 Multiplex
#    [Tags]    caseB033    Manual_yalsun    TA_yalsun
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_TDD}
#    ...        AND    Suite Setup Update GNB    scf_file=${FrameStrc_SCF}    swconfig_param_AP=${SWCONFIG_PARAM_AP}
#    ...        AND    Modify GSCN On Airphone    ${cell2_ID}    ${gscn_B034}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    #Step1
#   ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_B033.xml
#    Delta Commission With SCF File    ${json_file}
#    Verify Coam Site Is Ready
#    Suite Setup Start WTS And Check OnAir
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_TDD}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B033}   iphy_file=${IPHY_B033}   swconfig_param=${SWCONFIG_PARAM_IPY}
#    ...        AND    Suite Setup Copy WTS Config Files From Local     ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    #Step1
#    SA Single UE Attach    ${UE_ID}
#    #Step2
#    #Online Change One Para With Admin    ${dist_name}    ${parameter}    ${value}
#    Set Beam_control_testmode
#    Set Value For MUE Testmode In Same Prach Time
#    CUDU_L2 Send Action To GNB    1-50    mue_prach_control    activate    7
#    Trigger and Check Msg2 Multiplexed With Msg2 For Different RARNTI
#    Trigger and Check Msg2 Multiplexed With Msg2 For Same RARNTI
#    Trigger and Check Msg3 Multiplexed With Msg3
#    Trigger and Check Msg4 and Msg4 Multiplex
#    Trigger Msg2 Multiplexed With Msg4 When BF Enabled

#CB009550-ET-B034_Verify_Counter_RA_CF_STP_TIME_is_right_for_TDD_SA
#    [Documentation]
#    ...    Precondition:
#    ...      TDD 100M 48PRB
#    ...      Frame structure=1208
#    ...    Test Steps:
#    ...      Step1: Register multi SA Ues
#    ...      Step2: Trigger Intra GNB CFRA HO
#    ...      Step3:Check vlaue of M55306C09012
#    ...    Check Points:
#    ...      1)Check vlaue of M55306C09012
#    [Tags]    caseB034    Manual_yalsun    TA_yalsun
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_B033}
#    ...        AND    Suite Setup Update GNB    scf_file=${FrameStrc_SCF}    swconfig_param_AP=${SWCONFIG_PARAM_AP}
#    ...        AND    Modify GSCN On Airphone    ${cell2_ID}    ${gscn_B034}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    #Step1
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_B034.xml
#    Delta Commission With SCF File    ${json_file}
#    Hard Reboot Testline
#    Verify Coam Site Is Ready
#    Suite Setup Start WTS And Check OnAir
#    Set Beam_control_testmode and UE Attach
#    #Step2
#    Set A2 measurement
#    Trigger CFRA HO When BF enabled
#    #Step3
#    Get and Check PM Counter After CFRA HO