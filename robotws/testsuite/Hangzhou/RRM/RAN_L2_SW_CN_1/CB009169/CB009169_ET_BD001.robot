*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    CN1_SQ6    CB009169
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                     ${CURDIR}/Config
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${WTS_DIR}                      /opt/wts/latest
#${WTS_CFG}                      CB009169_BB202.cfg
#${DELTA_SCF_BD001}              Delta_SCF_BD001.json
#${DL_TRF}                       10
#${UL_TRF}                       40
#${2CC_UE}                       20
#${PCELL}                        52
#${SCELL}                        50
#${A1RSRP}                       105
#${DL_TARGET}                    5
#${UL_TARGET}                    35
#${RSRP_A2}                      30
#${BIP_CSV_NAME}                 5GBipL2L1_filtering_off.csv
#${FILTER}                       dldata_pdcchsendreq
#@{COLUMN_NAME}                  dci.dci01.TPCforScheduledPUSCH
#${PREFERENCE}                   preferences_BD001
#
#*** Test Cases ***
#CB009169-ET-BD001_UL_CA_Call_with_PUSCH_uplink_closed_loop_power_control_on_ABIO
#    [Tags]    Owner_j8shen
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${DELTA_SCF_BD001}    swconfig_param=0x580692=1
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    Singel CA UE Add Scell With A1 And Check DL UL Througput
#    Start Gnb BIP Log
#    Modify Sinr To Trigger TPC UP When attenuation increase
#	Sleep   5s    reason=wait until stable
#    Modify Sinr To Trigger TPC Down When attenuation decrease
#    Wait Until Keyword Succeeds    60s    3sec    Check CA Cell Sum Average Throughput    ${2CC_UE}    ul    ${UL_TARGET}    2
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    Convert Multi BIP Logs To Csv By MCShark    ${TEST_LOG_DIRECTORY}    5GBipL2L1_filtering_off    ${FILTER}    ${COLUMN_NAME}
#    ...    ${CURDIR}/Resources/${PREFERENCE}
#    Verify TPC Value Large
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#Singel CA UE Add Scell With A1 And Check DL UL Througput
#    SA 5G CA Attach    ${2CC_UE}
#    Trigger A1 Scell Addition    ${2CC_UE}    ${A1RSRP}    ${PCELL}
#    Check SA Scell PhysicalID With UE ID     ${2CC_UE}    ${SCELL}    1
#    Start SA UE Big DL Traffic Internal    ${2CC_UE}    ${DL_TRF}
#    Start SA UE Big UL Traffic Internal    ${2CC_UE}    ${UL_TRF}
#    Sleep    20s    reason=wait for traffic stable
#    Check CA Cell Sum Average Throughput    ${2CC_UE}    dl    ${DL_TARGET}    2
#    Check CA Cell Sum Average Throughput    ${2CC_UE}    ul    ${UL_TARGET}    2
#
#Modify Sinr To Trigger TPC UP When attenuation increase
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-300
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_testmode_set_nr id=20 testmode=ul_sinr profile_id=1 action=activate scell=0
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_cell_noise_testmode_nr profile_id=1 noise_pusch=-500
#    ute_wtssim.Execute Egate Command
#    ...    cmd=cell_testmode_set_nr gnb=2 cell_id=3 testmode=ul_cell_noise profile_id=1 action=activate
#    Sleep    8s    reason=wait for adjust TPC UP when attenuation increase
#
#Modify Sinr To Trigger TPC Down When attenuation decrease
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_cell_noise_testmode_nr profile_id=1 noise_pusch=-800
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=0
#    Sleep    6s    reason=wait for adjust TPC Down when attenuation decrease
#
#Verify TPC Value Large
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB009169_BD${/}CB009169_BD001.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}
