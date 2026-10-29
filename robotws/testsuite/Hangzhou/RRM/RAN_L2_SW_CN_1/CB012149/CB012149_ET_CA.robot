*** Settings ***
Resource           ./CB012149_resource.robot
Resource           ./../CUDU_L2/common_setup_teardown.robot
Suite Setup        Common Suite Setup 2
Test Teardown      Common Test Teardown 2
Suite Teardown     Common Suite Teardown 2
Force Tags         CLOUD_5G_I_BOO_AP_LOO    SBTS00
...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

*** Variables ***
${SCF_PATH}                   ${CURDIR}/Config/SCF
${WTS_DIR}                    /opt/iphy/latest
${WTS_CFG_CA01}               wts_CB012149_CA01.cfg
${LOCAL_WTS_DIR}              ${CURDIR}/Config/WTS/
${SCF_CA01}                   ${SCF_PATH}/CB012149_CA01.xml
${iphy_CA01}                  ${CURDIR}/Config/IPHY/iphy_CA01.xml
${SWCONFIG_CA01}              0x4B000F=1;
${UE_ID}                      1
${1T1F_SCELLS}                ('1', '51', '25')
${1116_0DL_SLOT}              [0, 1, 2, 6, 7, 8, 9, 10, 11, 12, 16, 17, 18, 19]
${1116_0UL_SLOT}              [4, 5, 14, 15]
${FDD_MUTE_SLOT}              [0, 1, 3, 4, 5, 6, 8, 9]
${FDD_UNMUTE_SLOT}            [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
${WTS_CFG_CA09}               wts_CB012149_CA09.cfg
${SCF_CA09}                   ${SCF_PATH}/CB012149_CA09.xml
${iphy_CA09}                  ${CURDIR}/Config/IPHY/iphy_CA09.xml
${2CC_DL_DATA}                900
${2CC_UL_DATA}                175
@{2CC_UE_LIST}                10    11    12
@{2CC_UE_LIST_2UE}            10    11
@{2CC_SCELL_PHYSICALID_LIST}  ${2CC_SCELL_PHYSICALID}    ${2CC_SCELL_PHYSICALID}    ${2CC_SCELL_PHYSICALID}
@{2CC_SCELL_PHYSICALID}       51
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB012149ET-CA01_T-F schueld on both Pcell and scell
    [Documentation]
    ...    Precondition:
    ...      FDD 20M and pcell TDD with 1116 0ms frame structure.
    ...      :with beam=4 and refine beam is enable
    ...      NRBTS/NRCELL-maxNumOfUlCaUeParallelTx=2
    ...      A1 based scell added configured.
    ...    Test Steps:
    ...      Step1: Attach UE1 to TDD Pcell and make SA call.
    ...      Step2: Send A1 report, 1 scell is added
    ...      Step3: start big DL and UL traffic and capture logs.
    ...      Step4: start small UL traffic and capture logs.
    ...      Step5: start big UL traffic and capture logs.
    ...      Step6: UE released.

    ...    Check point：
    ...      1. GNB schedule UL data on both TDD pcell and FDD scell even slot overlap.
    ...      2. after step4, the slot of FDD overlap with TDD will not be scheduled.
    ...      3. After step5, GNB will schedule UL data on both TDD pcell and FDD scell at same overlap slot again.
    ...      4. No DTX/CRC NOK
    [Tags]    caseCA01    Manual_qianwu    TA_qianwu
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_CA01}
    ...        AND    Suite Setup Update GNB    scf_file=${SCF_CA01}    iphy_file=${iphy_CA01}    swconfig_param=${SWCONFIG_CA01}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
    #Step1
    SA Single UE Attach    ${UE_ID}
    #Step2
    CB012149_resource.Trigger A1 Scell Addition    ${UE_ID}
    Sleep    2s    reason=Wait for log
    #checkpoint 2
    Get And Check Scell Infos    ${1T1F_SCELLS}
    #Step3
    Send Large Traffic Over DRB1
    Start SA UE Big DL Traffic Internal    1    mbps=300
    Start Gnb BIP Log
    Sleep    1s    reason=Wait for log
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/1/
    CUDU_L2 Capture And Decode TTitrace    1   2
    #Step4
    Send Small Traffic over DRB1
    CUDU_L2 Capture And Decode TTitrace    2   2
	#step5
    Start SA UE Big UL Traffic Internal    1    mbps=300
    sleep    10s    #sleep for stable traffic
    CUDU_L2 Capture And Decode TTitrace    3   2
    #step6
    SA 5G Detach    ue_id=1
    #checkpoint 1
    Check AllowList In TTI    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv
    Check Slot For FDD    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv     ulFdSchedData.numOfPrb    51    ${FDD_UNMUTE_SLOT}
    #checkpoint 2
    #Check Overlap In TTI    ${TEST_LOG_DIRECTORY}/ttitrace/2/output_ul.csv
    #checkpoint 3
    Check AllowList In TTI    ${TEST_LOG_DIRECTORY}/ttitrace/3/output_ul.csv
    Check Slot For FDD    ${TEST_LOG_DIRECTORY}/ttitrace/3/output_ul.csv     ulFdSchedData.numOfPrb    51    ${FDD_UNMUTE_SLOT}
    CUDU_L2 Check DTXNACK Rate    3
    CUDU_L2 Check UL DTXCRC Rate    3

CB012149ET-CA09_UE_can_not_enter_to_allow_list_when__number_of__UE_in_UL_pre-scheduler_expires
    [Documentation]
    ...    Precondition:
    ...      FDD 20M and pcell TDD with 1116 0ms frame structure.
    ...      :with beam=4 and refine beam is enable
    ...      NRBTS/NRCELL-maxNumOfUlCaUeParallelTx=2
    ...      maxNumPuschAllocationPerSlot=6
    ...      NRBTS.sCellActivationMethod=blind sCellAdditionMethod =0:blind
    ...    Test Steps:
    ...      Step1: UE1,UE2 and UE3 attach to TDD cell as pcell.
    ...      Step2: start big UL and DL data for each UE.
    ...      Step3: start small UL data for UE3.
    ...    Check point:
    ...      1. Verify after big data transfer,the slot of FDD overlap with TDD will not be scheduled.
    ...      2. Verify after step3,UE1 and UE2 will use UL FDD scell full schedule due to small data for UE3.
    ...      3. No DTX/CRC NOK
    [Tags]    caseCA09    Manual_dguan   TA_dguan
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_CA09}
    ...        AND    Suite Setup Update GNB    scf_file=${SCF_CA09}    iphy_file=${iphy_CA09}    swconfig_param=${SWCONFIG_CA01}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
    #Step1 & Step2
    SA Multi UE Attach With Scell Blind Addition    ${2CC_UE_LIST}    ${2CC_SCELL_PHYSICALID_LIST}    2
    #Step3
    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST}    ${2CC_DL_DATA}    ${2CC_UL_DATA}
    Sleep    5s    reason=wair for data is stable
    CUDU_L2 Capture And Decode TTitrace    1   2
    #checkpoint 1
    Check SlotNum Of UL In TTI    1    51    8
    #Step4
    SA Multi UE Stop DL And UL Traffic    ${2CC_UE_LIST}
    Sleep    5s    reason=wait for data is stable
    SA 5G Detach    ue_id=12
    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST_2UE}    ${2CC_DL_DATA}    ${2CC_UL_DATA}
    Sleep    5s    reason=wait for data is stable
    CUDU_L2 Capture And Decode TTitrace    2   2
    #checkpoint 2
    Check AllowList In TTI    ${TEST_LOG_DIRECTORY}/ttitrace/2/output_ul.csv
    Check SlotNum Of UL In TTI    2    51    10
    #checkpoint 3
    CUDU_L2 Check UL DTXCRC Rate    2

*** Keywords ***
