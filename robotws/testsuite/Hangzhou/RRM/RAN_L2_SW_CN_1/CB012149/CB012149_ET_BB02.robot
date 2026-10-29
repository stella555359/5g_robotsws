*** Settings ***
Documentation    ...
#Resource           ./CB012149_resource.robot
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup        Common Suite Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_LPQ_AP_LOO    SBTS00
#...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
#
#*** Variables ***
#${SCF_PATH}                   ${CURDIR}/Config/SCF
#${WTS_DIR}                    /opt/iphy/latest
#${WTS_CFG_BB01}               wts_CB012149_BB02.cfg
#${LOCAL_WTS_DIR}              ${CURDIR}/Config/WTS/
#${SCF_BB01}                   ${SCF_PATH}/CB012149_BB02.xml
#${iphy_BB01}                  ${CURDIR}/Config/IPHY/iphy_BB01.xml
#${SWCONFIG_BB01}              0x4B000F=1;
#${UE_ID1}                     1
#${UE_ID2}                     2
#${UE_ID3}                     3
#${T+F_SCELLS}                ('1', '55', '77')
#
#
#*** Test Cases ***
#CB012149ET-BB002 F+T Scell UE UL TX switch with cell configuration PUSCH typeB
#    [Documentation]
#    ...    Precondition:
#    ...    FDD 20M ,TDD with 1116 0 ms frame structure.
#    ...    beam=6
#    ...    2.NRBTS.sCellActivationMethod=qpsk_4psk
#    ...    3.sCellAdditionMethod =Blind
#    ...    4. RREL sCellOperationalMode =1(dlAndUl)
#    ...    NRBTS/NRDU/ulTxSwitchingSupportList = 520:ca_Fr1T_F_Sa_switchedUl
#    ...    5. <p name="pucchF3MaxCodeRate">zeroDot15</p><p name="pucchF3ModulationScheme">qpsk_4psk</p>
#    ...    6. NRBTS/actFdmScheduling = TRUE
#    ...    7. NRBTS/NRCELL/srPeriodicity = slots20
#    ...    8.NRBTS/NRCELL/sCellActivationLevel = 5TTI is apply for DL.
#    ...    NRBTS/NRCELL/sCellActivationLevelUL = 5 TTI is apply for UL.
#    ...    NRBTS/periodicBSRTimer=sf10
#    ...    9.TDD pcell with 3BWP for TDD pcell and 2 TDD scell.
#    ...    10.puschMappingType=TypeB for FDD and TDD cells.
#    ...    11.dmrsTypeAPosition=2
#    ...    12.NRBTS.actMultipleDedicatedBWPs=enable
#    ...    NRCELL.actEnhMultipleDedicatedBWPs = TRUE
#
#    [Tags]    caseBB01    Manual_Yalsun    TA_Yalsun
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB01}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_BB01}    iphy_file=${iphy_BB01}    swconfig_param=${SWCONFIG_BB01}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    Sleep    5s
#    SA Single UE Attach    ${UE_ID1}
#    Get And Check Scell Infos    ${T+F_SCELLS}
#	Setup Ttitrace
#	Start Gnb BIP Log
#	Start SA UE Big DL Traffic Internal    ${UE_ID1}    1000
#    SA Start UL Traffic Internal    ${UE_ID1}    1    175
#	Run Keyword And Continue On Failure    Check UL And DL DTX From Ttitrace Quickly    BB_01    2
#	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/1
#	Run Keyword And Continue On Failure    Check Rank In File As Expected    BB_01    55    ulFdSchedData.numOfLayers    RANK2
#	Run Keyword And Continue On Failure    Check FDD Schedule Is Not Overlap With Tdd Slot    BB_01    UL_01    slot    2
#	Run Keyword And Continue On Failure    Check FDD Schedule Is Not Overlap With Tdd Slot    BB_01    ulFdSchedData.dciFormat    slot    7
#	Run Keyword And Continue On Failure    Check SLIV is Correct As Expected    BB_01    1     55
#	Run Keyword And Continue On Failure    Check SLIV is Correct As Expected    BB_01    3     53
#	Start Gnb BIP Log
#	SA Start UL Traffic Internal    ${UE_ID1}    1    2
#	Run Keyword And Continue On Failure    Check UL And DL DTX From Ttitrace Quickly    BB_02    3
#	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/2
#	Start Gnb BIP Log
#	SA Start DL Traffic Internal    ${UE_ID1}    1    2
#	Run Keyword And Continue On Failure    Check UL And DL DTX From Ttitrace Quickly    BB_03    3
#	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/3
#	Start SA UE Big DL Traffic Internal    ${UE_ID1}    1000
#    SA Start UL Traffic Internal    ${UE_ID1}    1    175
#	Start Gnb BIP Log
#	Run Keyword And Continue On Failure    Check UL And DL DTX From Ttitrace Quickly    BB_04    3
#	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/4
#
#*** Keywords ***
