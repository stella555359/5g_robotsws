*** Settings ***
Documentation    ...
#Documentation     this case is to verify ul srs ports number be changed depend on ulsinr profile of AP.
#...
#...               0x590021=0 means uePushTranscoherence.This is needed to activate your feature (5GC002226).
#...               The radparmeter overwrites the value from ueCapabilities.
#...               Author: qiqi.luo@nokia-sbell.com
#...
#...               Please do not edit the existing keywords in this file without testing.
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}    swconfig_param=0x590021=0
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#...               AND    Get Default Ue Capabilities
#Suite Teardown    Run Keywords    Common Suite Teardown
#...               AND    Delta Commission With SCF File    ${RECOV_FILE}
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LN_AP_LO    CRT    RAN_5G_FDD    FR1    Owner_qiqluo    RAN_5G
#...               SBTS00
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          Resource/keyword.robot
#
#*** Variables ***
#${SCF_PATH}                       ${CURDIR}/Config
#${SCF_FILE}                       full_FDD_SCF.xml
#${DELTA_FILE}                     Delta_conf.json
#${RECOV_FILE}                     Delta_recov.json
#${SRB3_CONF}                      Delta_conf_srb3.json
#${SRB3_RECOV}                     Delta_recov_srb3.json
#${LOCAL_WTS_DIR}                  ${CURDIR}/Config/wts
#${WTS_CFG}                        FDD_setup.cfg
#${IPHY_FILE}                      ${CURDIR}/Config/wts/FDD_iphy.xml
#${UE_ID}                          1
#${PROFILE_ID}                     1
#${PROFILE_ID1}                    1
#${PROFILE_ID2}                    2
#${SNIR_TARGET_SRS1}               -100
#${SNIR_TARGET_SRS2}               200
#${SNIR_TARGET_PUSCH1}             -100
#${SNIR_TARGET_PUSCH2}             200
#${SNIR_TARGET_PUCCH1}             100
#${SNIR_TARGET_PUCCH2}             100
#${SNIR_TARGET_PREMBLE1}           100
#${SNIR_TARGET_PREMBLE2}           100
#${GNB_ID}                         2
#${CELL_ID}                        1
#${BEARER_ID}                      2
#${TRF_ID}                         1
#${DELTA_XML_FILE}                 ${CURDIR}/Config/Delta.xml
#@{LOG_NAME_LIST}                  btslog    snapshot    tcpdump    #tshark | sherpa | #pmcounter
#${CONST_FILE}                     ${CURDIR}/Config/const_customizer.conf
#${UE_NR_CAP_FDD}                  E1201000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A61000A0F88DAC3
#...                               1B47498A823F96525CA01105B260901831E31FF9863CA160703878089C0270000841808DC9A1F00E41000000
#...                               A41000002A41000004A494000069807C0DBCA9BC0DADD600A0800004B29282000032CA4A0800014B29282000
#...                               072CA4A0800024B292920000AA5949405D03BBA557740EEE955CD2AB8AEDC0107801A0100800000080
#${UE_EUTRA_NR_CAP_FDD}            A10181102C0C0388C000000888160641C460000024400401C0463002100008040401803080008020200C0180
#${EGATE_PATH}                     /opt/iphy/latest/egate_console.log
#@{PORTS_LIST}                     port1    ports2
#
#*** Test Cases ***
#CB006086_ET_003_UE_Reconfiguration_With_Number_Of_SRS_Ports_Two_Fail
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_FILE}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#        ...    AND    Common Test Setup
#    ${UE_ID}=    Set Variable If    "${GNBCUTYPE}"=="SANSA"    11    ${UE_ID}
#    Set Suite Variable    ${UE_ID}    ${UE_ID}
#    ${UE_NR_CAP_FDD}    String.Replace String    ${UE_NR_CAP_FDD}    ${SPACE}    ${EMPTY}
#    NSA NR UE Param Set    ${UE_ID}    ${UE_NR_CAP_FDD}
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    Add Scell Range To NSA
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA UE Testmode NR Profile    ${PROFILE_ID2}    ${SNIR_TARGET_SRS2}    ${SNIR_TARGET_PUSCH2}    ${SNIR_TARGET_PUCCH2}    ${SNIR_TARGET_PREMBLE2}
#    NSA UE Testmode NR Profile    ${PROFILE_ID1}    ${SNIR_TARGET_SRS1}    ${SNIR_TARGET_PUSCH1}    ${SNIR_TARGET_PUCCH1}    ${SNIR_TARGET_PREMBLE1}
#    NSA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID1}
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    50    ${TRF_ID}
#    Set X2 Failure
#    NSA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID2}
#    Sleep    5s    reason=Wait For UL Transmission
#    NSA LTE Detach    ${UE_ID}
#    Check Egate Console Log    ${EGATE_PATH}    ${PORTS_LIST}
