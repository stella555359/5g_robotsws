*** Settings ***
Documentation    ...
#Resource           ./CB012149_resource.robot
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup        Common Suite Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_BOO_AP_LOO    SBTS00
#...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
#
#*** Variables ***
#${SCF_PATH}                   ${CURDIR}/Config/SCF
#${WTS_DIR}                    /opt/iphy/latest
#${WTS_CFG_DA01}               wts_CB012149_DA01.cfg
#${LOCAL_WTS_DIR}              ${CURDIR}/Config/WTS/
#${SCF_DA01}                   ${SCF_PATH}/CB012149_DA01_PSBWP.xml
#${iphy_DA01}                  ${CURDIR}/Config/IPHY/iphy_DA01.xml
#${SWCONFIG_DA01}              0x4B000F=1;
#${UE_ID1}                     1
#${3T2F_SCELLS}                ('1', '51', '25'), ('2', '52', '41'), ('3', '53', '41'), ('4', '54', '66')
#
#
#*** Test Cases ***
#CB012149ET-DA001 3T2F with 3 dedicate BWP for Pcell and Scell
#    [Documentation]
#    ...    Precondition:
#    ...    FDD 20M ,TDD with 1116 0 ms frame structure.
#    ...    beam=6
#    ...    2.NRBTS.sCellActivationMethod=Blind
#    ...    3.sCellAdditionMethod =Blind
#    ...    4. RREL sCellOperationalMode =1(dlAndUl)
#    ...    NRBTS/NRDU/ulTxSwitchingSupportList = 520:ca_Fr1T_F_Sa_switchedUl
#    ...    5. <p name="pucchF3MaxCodeRate">zeroDot08</p><p name="pucchF3ModulationScheme">BPSK</p>
#    ...    6. NRBTS/actFdmScheduling = TRUE
#    ...    7. NRBTS/NRCELL/srPeriodicity = slots20
#    ...    8.NRBTS/NRCELL/sCellActivationLevel = 1TTI is apply for DL.
#    ...    NRBTS/NRCELL/sCellActivationLevelUL = 1 TTI is apply for UL.
#    ...    NRBTS/periodicBSRTimer=sf10
#    ...    9.TDD pcell with 3BWP for TDD pcell and 2 TDD scell.
#    ...    10.puschMappingType=TypeA for FDD and TDD cells.
#    ...    11.dmrsTypeAPosition=2
#    ...    12.NRBTS.actMultipleDedicatedBWPs=enable
#    ...    NRCELL.actEnhMultipleDedicatedBWPs = TRUE
#
#    [Tags]    caseDA01    Manual_Yalsun    TA_Yalsun
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_DA01}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_DA01}    iphy_file=${iphy_DA01}    swconfig_param=${SWCONFIG_DA01}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    SA Single UE Attach    ${UE_ID1}
#    Get And Check Scell Infos    ${3T2F_SCELLS}
#	Setup Ttitrace
#	Start Gnb BIP Log
#	Start SA UE Big DL Traffic Internal    ${UE_ID1}    1000
#    SA Start UL Traffic Internal    ${UE_ID1}    1    175
#	Run Keyword And Continue On Failure    Run Keyword And Continue On Failure    Check UL And DL DTX From Ttitrace Quickly    DA_01    2
#	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/1
#	Run Keyword And Continue On Failure    Check Data In File As Expected    DA_01    55    csiRsSchedData.numOfPrb    104
#    Run Keyword And Continue On Failure    Check Data In File As Expected    DA_01    52    csiRsSchedData.numOfPrb    132
#	Run Keyword And Continue On Failure    Check Data In File As Expected    DA_01    53    csiRsSchedData.numOfPrb    273
#	Run Keyword And Continue On Failure    Check Rank In File As Expected    DA_01    55    ulFdSchedData.numOfLayers    RANK2
#	Run Keyword And Continue On Failure    Check FDD Schedule Is Not Overlap With Tdd Slot    DA_01    UL_01    slot    2
#	Run Keyword And Continue On Failure    Check FDD Schedule Is Not Overlap With Tdd Slot    DA_01    ulFdSchedData.dciFormat    slot    7
#	Run Keyword And Continue On Failure    Check SLIV is Correct As Expected    DA_01    1     55
#	Run Keyword And Continue On Failure    Check SLIV is Correct As Expected    DA_01    3     53
#	Start Gnb BIP Log
#	SA Stop Data Traffic Internal    ${UE_ID1}    1    ul
#	CUDU_L2 Capture And Decode TTitrace Quickly   DA_02     2
#	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/2
#	Start Gnb BIP Log
#	SA Start UL Traffic Internal    ${UE_ID1}    1    175
#	Start SA UE Big DL Traffic Internal    ${UE_ID1}    1000
#	CUDU_L2 Capture And Decode TTitrace Quickly   DA_03     2
#	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/3
#	SA Stop DLUL Traffic
#	Start Gnb BIP Log
#	CUDU_L2 Capture And Decode TTitrace Quickly   DA_04     2
#	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/4
#
#*** Keywords ***
