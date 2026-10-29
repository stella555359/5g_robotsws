*** Settings ***
Documentation    ...
#Resource    ./Resources/CB009169_C_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource    ./../CB006137/resources/6137_BO_lib.robot
#Resource    ./../CB006137/resources/CB006137_BB_resource.robot
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    CN1_SG09_SM2
#...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}       ${CURDIR}
#${LOCAL_WTS_DIR}       ${CURDIR}/Config/CB009169_C
#${SCF_DIR}             ${CURDIR}/Config/CB009169_C
#${6CC_IPHY}            ${LOCAL_WTS_DIR}/iphy_6CC.xml
#${IPHY_CB019}          ${LOCAL_WTS_DIR}/iphy_CB019.xml
#${CB023_SCF}           ${SCF_DIR}/SCF_C_CB023.xml
#${CB019_SCF}           ${SCF_DIR}/SCF_C_CB019.xml
#${WTS_CFG_CB023}       basic_setup_CB023.cfg
#${WTS_CFG_CB019}       basic_setup_CB019.cfg
#${3T1F_SCELLS}         ('1', '50', '41'), ('2', '52', '77'), ('3', '54', '66')
#${1T2F_SCELLS_CB019}    ('1', '50', '71'), ('2', '52', '66')
#${CB023_RD}             0x4B000F=1;0x420068=7;0x420062=1;0x580690=1;0x58057a = 4;0x58057b = 1048576;0x58057c = 10240
#${9169_RD}              0x4B000F=1
#${force_reboot}        ${True}
#${CB023_UL_BLER}    900,900,900,900
#${CB019_UL_BLER}    100,100,100,100,100,100,100,100
#${CB019_DL_BLER}    100,100,100,100,100,100,100,100
#&{VENDOR_PARAMS_DICT_1}       maxNumLayerPrbL1Sp=546    maxNumStreamPrbL1Sp=300    maxNumWbStreamPrbL1Sp=1092
#${LIST_NAME_1}                bbL1SpPrbInitCapacity
#${REF_VALUE_1}                ABIO32ULNR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
#${REF_VALUE_2}                ABIO64ULNR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
#&{VENDOR_CHANGE_DICT_CB023_1}       params_dict=&{VENDOR_PARAMS_DICT_1}    list_name=${LIST_NAME_1}    ref_value=${REF_VALUE_1}
#&{VENDOR_PARAMS_DICT_2}       maxNumLayerPrbL1Sp=1092    maxNumStreamPrbL1Sp=1200    maxNumWbStreamPrbL1Sp=1092
#&{VENDOR_CHANGE_DICT_CB023_2}       params_dict=&{VENDOR_PARAMS_DICT_2}    list_name=${LIST_NAME_1}    ref_value=${REF_VALUE_2}
#@{VENDOR_CHANGE_LIST_CB023}    ${VENDOR_CHANGE_DICT_CB023_1}    ${VENDOR_CHANGE_DICT_CB023_2}
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB009169-ET-CB019_UL_CA_T+F_Interworking_with_VoNR_Increased_Transmission_Reliability_in_HO_process
#    [Documentation]
#    ...    Precondition:
#    ...      Voice over NR feature is enabled on the band combination used for FR1 TDD -FDD UL CA
#    ...      DRBs and user contexts configured with 5QI-1 (for VoNR) and 5QI-5 (for IMS signalling) profiles are successfully setup in gNB
#    ...      Intra-frequency Handover is enabled NRBTS/actIntraFreqHoSA
#    ...    Test Steps:
#    ...      Step1: Attach UE1 and UE2 to the FR1 TDD cell
#    ...      Step2: Setup 5QI-1 and 5QI-5
#    ...      Step3: Start DL/UL traffic over 5QI-1 and 5QI-5
#    ...      Step4: Use DL Bler testmode to make high DL Bler
#    ...      Step5: UE report A3 measurements to do handover between intra-cells
#    ...    Check point：
#    ...      1. UE attaches to PCell successfully
#    ...      2. SCell Addition is ok, DL 4CC and UL 2CC
#    ...      3. 5QI-1 and 5QI-5 setup successfully
#    ...      4. HO successfully
#    ...      5. L2-PS uses conservative MCS during the early phase of the session
#    [Tags]    caseCB019    Manual_xinwang    TA_xinwang
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CB019}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${CB019_SCF}    iphy_file=${IPHY_CB019}
#    ...               swconfig_param=${9169_RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#    #step1 & checkpoint1
#    SA Single UE Attach    ue_id=1
#    SA Single UE Attach    ue_id=2
#    Sleep    2s    reason=Wait for log
#    #checkpoint2
#    Get And Check Scell Infos    ${1T2F_SCELLS_CB019}
#    #step2 & checkpoint3
#    Trigger 5QI 5 Setup    1
#    Trigger 5QI 1 Setup    1
#    Trigger 5QI 5 Setup    2
#    Trigger 5QI 1 Setup    2
#    #step3
#    Start SA VONR GBR DL And UL Traffic    1    3    10    10
#    Start SA VONR GBR DL And UL Traffic    1    2    10    10
#    Start SA VONR GBR DL And UL Traffic    2    3    10    10
#    Start SA VONR GBR DL And UL Traffic    2    2    10    10
#    #step4
#    Set BLER Testmode    1    ${CB019_UL_BLER}    ${EMPTY}
#    Set BLER Testmode    1    ${EMPTY}    ${CB019_DL_BLER}
#    CUDU L2 Send Action To GNB    1    bler    activate    1    0
#    CUDU L2 Send Action To GNB    2    bler    activate    1    0
#    #step5 & checkpoint4
#    Trigger A2 MR Scell Release    1    1    1    50
#    A3 Trigger Handover    1    3    61    EXT_ENB-2.11    EXT_ENB-2.12
#    Sleep    2s    reason=Wait for log
#    #checkpoint5
#    Check Conservative MCS
#
#CB009169-ET-CB023_UL_CA_T+F_Interworking_with_Baseband_resource_pooling_of_PRBs_for_TDD
#    [Documentation]
#    ...    Precondition:
#    ...      Activates TDD FR1 UE pooling via configuration as below:
#    ...      3 TDD cells should be deployed in one loki And Pcell TDD should be in a l1subpool with another tdd cell.
#    ...      NRBTS actBbPoolTddFr1 is set to ”true” (CB008940 /DL PRB pooling feature is enabled)
#    ...      NRBTS.actSlowPrbPooling (FDD) is set to "false" (5GC001227 PRB pooling for FDD)
#    ...      rd parameter:
#    ...      0x420068=7   #rdTddPoolingFeaturesEnable : bit 0 -> CB008940 enabled, bit 1->CB008847 enabled , bit 2 ->CB007113 enabled
#    ...      0x420062=1 #RdNewTddCellSlotModel 1:new Cell Slot Model ; 0 Legacy cell Slot ## will remove until 23R4
#    ...      0x580690=1    #rdAllowZeroAllocBypass
#    ...      #Enable following debug flag for BBPooling if needed
#    ...      0x58057a = 4
#    ...      0x58057b = 1048576
#    ...      0x58057c = 10240
#    ...    Test Steps:
#    ...      Step1. Attach CA UE1 to the FR1 TDD cell-3.
#    ...      Step2. Start full UL traffic for UE1.
#    ...      Step3. Use test mode to trigger HARQ retransmissions in cell-3.
#    ...      Step4. Attach Non CA UE2 to the FR1 TDD cell-4.
#    ...      Step5. Attach Non CA UE3 to the FR1 TDD cell-5.
#    ...      Step6. Start small UL traffic for UE2 and UE3.
#    ...      Step7. stop UE1 traffic.
#    ...      Step8. Detach UEs.
#    ...    Check point：
#    ...    1. check BbPoolDeployInfo log during cellsetup, to confirm TDD cell3&TDD cell4 are in the same "l1UlSubPoolId",
#    ...    2. 8626 adapt retransmission happened in 1st cell,when the ul l1 resource limited.
#    ...    3. The CA UE can reach peak throughput in UL over FR1 TDD cell and FDD cell.
#    ...    4. PRB sharing in the same L1SP based on the load.
#    [Tags]    caseCB023    Manual_LiliDong    TA_Susie
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CB023}
#    ...        AND    Suite Setup Update GNB    scf_file=${CB023_SCF}    vendor_change_list=${VENDOR_CHANGE_LIST_CB023}    iphy_file=${6CC_IPHY}
#    ...               swconfig_param=${CB023_RD}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    #step1 & checkpoint1
#    SA Single UE Attach    ue_id=1
#    CB009169_C_resource.Trigger A1 Scell Addition    ${UE_ID}    1    100
#    Sleep    2s    reason=Wait for log
#    Get And Check Scell Infos    ${3T1F_SCELLS}
#    #step2
#    Start SA UE Big UL Traffic Internal    1    mbps=200
#    #checkpoint3
#    Wait Until Keyword Succeeds    2min    10s    Check CA Cell Sum Average Throughput    ${UE_ID}    ul    120    4
#    #step3
#    Set BLER Testmode    4    ${CB023_UL_BLER}
#    CUDU L2 Send Action To GNB    1    bler    activate    4    0
#    ${ue1_pcell_tput1}    Get CA Cell Average Throughput    1    ul    pcell    0
#    #step4
#    Start Ttitrace With Streaming Mode
#    SA Single UE Attach    ue_id=2
#    #step6
#    Start SA UE Big UL Traffic Internal    2    mbps=100
#    Sleep    3s        reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#    ${ue1_pcell_tput2}    Get CA Cell Average Throughput    1    ul    pcell    0
#    #step5
#    SA Single UE Attach    ue_id=3
#    #step6
#    Start SA UE Big UL Traffic Internal    3    mbps=100
#    Sleep    2s    reason=Wait for log
#    ${ue1_pcell_tput3}    Get CA Cell Average Throughput    1    ul    pcell    0
#    CUDU L2 Send Action To GNB    1    bler    deactivate    4    0
#    Wait Until Keyword Succeeds    2min    20s    Check CA Cell Sum Average Throughput    ${UE_ID}    ul    100    4
#    ${ue1_pcell_tput4}    Get CA Cell Average Throughput    1    ul    pcell    0
#    #step7
#    SA Stop Data Traffic Internal    1    1    ul
#    #step8
#    SA 5G Detach    ue_id=1
#    #checkpoint2
#    Check Adapt Retransmission    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    #checkpoint4
#    ${ret1}=    Evaluate    ${ue1_pcell_tput2}<=${ue1_pcell_tput1}
#    Should be True    ${ret1}
#    ${ret2}=    Evaluate    ${ue1_pcell_tput4}>=${ue1_pcell_tput3}
#    Should be True    ${ret2}
#    [Teardown]    Test Teardown Recover Env    vendor_file=${VENDOR_SUITE_BAK_FILE}    GNB_swconfig_file=${GNB_SWCONFIG_SUITE_BAK_FILE}
#
