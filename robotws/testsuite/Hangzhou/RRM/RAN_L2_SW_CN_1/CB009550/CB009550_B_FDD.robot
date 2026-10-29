*** Settings ***
Documentation
...
Resource           ./../CUDU_L2/common_setup_teardown.robot
Resource           ./CB009550_resource.robot
Library            ../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb
Library            resources/check_msg2_sib1_osi.py
Suite Setup        Run Keywords    Common Suite Setup 2
...                AND    Prepare QT LOLO Enviroment    TYPE=FDD
Test Teardown      Common Test Teardown 2
Suite Teardown     Common Suite Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    RAN_5G_FDD    RAN_5G
...               SBTS00    CN1_SG09_SM1    CB009550

*** Variables ***
${SCF_PATH}                 ${CURDIR}/config/SCF
${LOCAL_WTS_DIR}            ${CURDIR}/config/WTS
${WTS_DIR}                  /opt/iphy/latest
${iphy_B20}                 ${CURDIR}/config/WTS/iphy_B20.xml
${scf_fdd_cfra}             CB009550_B020.xml
${gnb_swconfig}             /home/ute/testline_init_results/configs/sm_swconfig.txt
${ap_swconfig}              /home/ute/testline_init_results/configs/sim_swconfig.txt
${WTS_CFG_FDD}              CB009550_sansa_fdd.lua
${WTS_CFG_FDD_HO}           wts_fdd_cfra.cfg
${DELTA_FILE_B14}           Delta_Conf_CB009550_B14.xml
${WTS_MULTI_UE_PDU}         multi_ue_sa_script_pdu.lua
${BIP_CSV_NAME}                5GBipL2L1_filtering_off.csv
${FILTER_B003}                 (dldata_pdschsendreql1sw ||dldata_pdschpayloadtbsendreql1sw ||dldata_pdcchsendreql1sw ) && (3gpp.subcellid == 0)
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot    DlData_DciInfoL1sw.rachStatus    DlData_PdschGrantL1sw.startPrb
...                            DlData_PdschGrantL1sw.numOfPrb    nr-rrc.c1    DlData_PdschGrantL1sw.rachStatus

*** Test Cases ***
CB009550-ET-B003_FDM_of_RA_msg2_or_msg4_with_SIB1_and_OSI_in_FDD_SA
    [Documentation]
    ...    Precondition:
    ...      FDD 20M 96PRB
    ...    Test Steps:
    ...      Step1: muliti UE attach to trigger SIB1/OSI multiplex with msg2/msg4
    ...      Check Point:
    ...        1)Check SIB1 OSI can be multiplexed with msg2 and msg4 on same slot and no DTX for msg4
    ...        2)L2-PS shall allocate Msg2/Msg4 contiguous to SIB allocation and shall ensure there is no gap
    ...        in the resource allocation
    [Tags]    caseB007    Manual_qianwu    TA_qianwu
    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_FDD}
    ...        AND    Suite Setup Update GNB
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    #Step1
    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_B003.xml
    Delta Commission With SCF File    ${json_file}
    Verify Coam Site Is Ready
    Suite Setup Start WTS And Check OnAir
    #Checkpoint
    Trigger SIB1/OSI Multi With Msg2 For B003

#CB009550-ET-B014_FDM_of_msg2s_and_msg3s_and_msg4s_in_FDD_SA_with_same_RARNTI
#    [Documentation]
#    ...    Precondition:
#    ...      FDD 20M
#    ...    Test Steps:
#    ...      Step1: Register multi SA Ues on the same PRACH occasion.
#    ...      Step2:Send traffic for two of the multiplexed UEs.
#    ...    Check Points:
#    ...      1)Check msg2s can be multiplexed on same slot,multiple RARs in single MAC PDU in one msg2 for same RARNTI.#
#	...      2)Check msg4s can be multiplexed on same slot,L2-PS shall allocate Msg2s or msg4s contiguous
#    ...      3)Check  msg3s can be multiplexed on same slot,Msg3s shall be allocated contiguously
#    ...      4)Check UL and DL traffic is OK
#    [Tags]    caseB014    Manual_suqian    TA_suqian
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_FDD}
#    ...        AND    Suite Setup Update GNB
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    #Step1
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/${DELTA_FILE_B14}
#    Delta Commission With SCF File    ${json_file}
#    Verify Coam Site Is Ready
#    Copy File For Multi UEs    ${WTS_MULTI_UE_PDU}
#    Suite Setup Start WTS And Check OnAir
#    Multi UEs Attach For B14 By Script And Capture Bip Log    ${WTS_MULTI_UE_PDU}    1    50
#    #Check Point1
#    Check Msg2 Multiplexed With Msg2    A2A_path=A2A_B021
#    #Check Point2
#    Check Msg4 and Msg4 Multiplex
#    #Check Point3
#    Check Msg3 Multiplexed With Msg3
#    #Check Point4
#    #Step2
#    UE L3 Call For B006    21    5    80

CB009550-ET-B020_FDM_of_msg2s_and_msg4s_or_msg2s_with_msg4s_in_FDD_SA_with_CFRA
    [Documentation]
    ...    Precondition:
    ...      FDD 10M 48PRB
    ...    Test Steps:
    ...      Step1: Register multi SA Ues
    ...      Step2: Trigger the Ues HO
    ...      Step3: Send traffic
    ...    Check Point:
    ...        1)Check msg2s can be multiplexed on same slot
    ...        2)Check UL and DL traffic is OK
    [Tags]    caseB020    Manual_dguan   TA_dguan
    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_FDD_HO}
    ...        AND    Suite Setup Update GNB    scf_file=${scf_fdd_cfra}    iphy_file=${iphy_B20}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    Copy File For Multi UEs    ${WTS_MULTI_UE_PDU}
    Suite Setup Start WTS And Check OnAir
    FOR    ${index}    IN RANGE    1    4
        Log To Console    ===============Trigger Time: ${index}==============
        #Step1
        Multi UEs Attach By Script    ${WTS_MULTI_UE_PDU}    1    4
        #Step2
        Trigger FDD Inter GNB Handover With CFRA
        #Checkpoint1
        ${res}    Run Keyword And Return Status    Check Msg2 Multiplexed With Msg2    A2A_path=A2A_B021
        ${Trigger_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
        ${cmd}    Set Variable    ue_deregister id=1-4 ue_deregister_type=switch_off
        Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command    ${cmd}
        Sleep    5s    reason=Wait for all ue dettached.
        Exit For Loop If    '${res}'=='True'
    END
    Should Be True    "${Trigger_sucess_flag}"=="${True}"