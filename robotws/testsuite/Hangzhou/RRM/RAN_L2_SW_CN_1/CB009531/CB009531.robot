*** Settings ***
Suite Setup       Run Keywords    Common Suite Setup 2
...               AND    Prepare QT LOLO Enviroment    TYPE=FDD  
Suite Teardown     Common Suite Teardown 2
Force Tags         CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    SBTS00
...                RAN_5G    RAN_5G_FDD
Library           Resources/A002_check_drx.py
Library           Resources/check_ap_syslog.py
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource           ./CB009531_resource.robot

*** Variables ***
${SCF_PATH}                    ${CURDIR}/config/SCF
${WTS_DIR}                     /opt/iphy/latest
${wts_CB009531_B014}          wts_CB009531_B014.cfg
${LOCAL_WTS_DIR}              ${CURDIR}/config/WTS/
${CB009531_B014_SCF}          ${SCF_PATH}/CB009531_SCF_B014.xml
${iphy_B014}                  ${CURDIR}/config/IPHY/iphy_B014.xml
${SWCONFIG_B014}              0x58057a=3;0x58057f=0x8000000;0x58075A=1;
${SWCONFIG_A_002}              0x4B000F=1;0x58057f=0x8000000;0x58057a=3;
${UE1_ID}                      1
${BIP_CSV_NAME}                5GBipL2L1_filtering_off.csv
${FILTER_A002}                 dldata_pdcchsendreq ||uldata_pucchreceiverespharqd
@{COLUMN_NAME}                 frame.time    3gpp.sfn    3gpp.slot    DlData_DciInfo.dciSize    dci.dci11.HARQ_ProcessNumber
...                            dci.dci11.FrequencyDomainResourceAssignment    dci.dci11.TimeDomainResourceAssignment
...                            dci.dci11.MCS_TB1    data.data
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***

CB009531-ET-B014_Verify_UL_Retransmission_can_be_scheduled_when_UL_DRX_retransmission_timer_is_ON_with_PUSCH_decoded_as_NACK_with_CG2_in_1208_TDD_cell
    [Documentation]
    ...    Precondition:
    ...      TDD 1208 Frame Struncture with both UL DRX Retransmission and CG2 activated.
    ...    Test Steps:
    ...      Step1: UE attach to TDD cell.
    ...      Step2: Start small UL data to trigger UE enter to DRX inactive.For DL send 175Mbps traffic.
    ...      Step3: Use AP test mode to trigger CG2 UL bler.
    ...      Step4: Release call.

    ...    Check Points:
    ...      1)Verify UL DRX retransmission processed as expected.
    ...      2)Verify CG2 function activa
    [Tags]    caseB014    Manual_lading    TA_lading
    [Setup]   Run Keywords    Set Test Variable    ${wts_cfg}    ${wts_CB009531_B014}
    ...        AND    Suite Setup Update GNB        scf_file=${CB009531_B014_SCF}    swconfig_param=${SWCONFIG_B014}    iphy_file=${iphy_B014}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    #Step1
    Verify Coam Site Is Ready
    Suite Setup Start WTS And Check OnAir
    SA Single UE Attach    ${UE1_ID}
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
##    #Step2,3
    Set AP L2rt Debug Level
    Set CG2 DRX BLER Testmode
    CUDU L2 Send Action To GNB    ue_id=${UE1_ID}    testmode=configured_grant    action=activate    profile_id=1 scell=0
    ${CMD_UL_DATA_CG2}    Set Variable    trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 bps=6000000 dir=ul
    ute_wtssim.Execute Egate Command    cmd=${CMD_UL_DATA_CG2}
    ${CMD_DL_DATA}    Set Variable    trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=175 dir=dl
    ute_wtssim.Execute Egate Command    cmd=${CMD_DL_DATA}
    Sleep    2s
    CUDU_L2 Capture And Decode TTitrace    log_id=1    duration=3
    Stop And Collect Syslog    ${TEST_LOG_DIRECTORY}
    Check RetxTimerStatus For B014 in TTI
    Check CSRNTI in ulConfiguredGrantType2Data
    OperatingSystem.Move File    ${TEST_LOG_DIRECTORY}/AP_syslog.tar.gz    ${TEST_LOG_DIRECTORY}/01/

    [Teardown]    Case Teardown    ${UE1_ID}

*** Keywords ***
