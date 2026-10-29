*** Settings ***
Documentation    ...
Suite Setup        Run Keywords    Common Suite Setup
...                AND    Prepare QT LOLO Enviroment    TYPE=TDD
Test Setup         Create Test Directory
Test Teardown      Common Test Teardown    check_tl=False
Force Tags         Classical    IPV4    IPV6    FR1    Owner_suqian    PRI-High
...                CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    RAN_5G_TDD
...                5GC001695    RAN_5G    SBTS00    SBTS23R1    SBTS22R4    SBTS22R2    SBTS22R3
Resource           ./../CUDU_L2/common_setup_teardown.robot
Resource           ./Resources/5GC001695_keyword.robot

*** Variables ***
${beamset4}    beamSet_4_2
${EdgeAngle1}    60
${numberOfTransmittedSsBlocks2}    6 beams
${SCF}                 ${CURDIR}/Config/TDD_scfc.xml
${IPHY}                ${CURDIR}/Config/TDD_iphy.xml
${WTS_CFG_A004}             TDD_basic_setup.cfg
${LOCAL_WTS_DIR}            ${CURDIR}/Config
${WTS_DIR}                  /opt/iphy/latest

*** Test Cases ***

5GC001695_A004 Transmission of 6 SSPBCH Blocks with Basic Beam set #4#2 during cell setup for 64TRX RRU
    [Tags]    case4    CDRT    CIT
    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_A004}
    ...        AND    Suite Setup Update GNB    scf_file=${SCF}    iphy_file=${IPHY}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    Set SCF Parameter For 1695    ${beamset4}    ${EdgeAngle1}    ${numberOfTransmittedSsBlocks2}
	Reboot Testline and Check 1695 Cell Onair
    capture bip    A004_120_tcpdumpL2L1_filtering_off.pcap0
    #Download MCShark To UTE    ${SW_VERSION_TOTAL}
    Convert BIP To CSV By MCShark For DlData_SsBlockSendReq    A004_120_tcpdumpL2L1_filtering_off.pcap0
    A2A_Check_CSV_Table    ${CURDIR}/Resources/A004.ini    ${LOG_PATH}/ssblock.csv

*** Keywords ***
Set SCF Parameter For 1695
    [Arguments]    ${beamset}    ${EdgeAngle}    ${numberOfTransmittedSsBlocks}
    ${delta_file}    Set Variable    ${CURDIR}/Delta_1695.json
    @{old_params_list}    Create List    "basicBeamSet": "[0-9a-zA-Z_]+"    "leftEdgeAngle": "[0-9]+"    "rightEdgeAngle": "[0-9]+"
    ...    "value": "[0-9] beams"
    @{new_params_list}    Create List    "basicBeamSet": "${beamset}"    "leftEdgeAngle": "${EdgeAngle}"    "rightEdgeAngle": "${EdgeAngle}"
    ...    "value": "${numberOfTransmittedSsBlocks}"
    Modify Text File    ${delta_file}    ${old_params_list}    ${new_params_list}
    Delta Commission Json File With Admin    ${delta_file}    600

Set SCF Parameter For abnormal
    ${delta_file}    Set Variable    ${CURDIR}/Delta_1695_abnormal.json
    Delta Commission Json File With Admin    ${delta_file}