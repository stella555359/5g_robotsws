*** Settings ***
Documentation    ...
#Documentation     this case is to verify ul srs ports number be changed depend on ulsinr profile of AP.
#...
#...               Author: qiqi.luo@nokia-sbell.com
#...
#...               Please do not edit the existing keywords in this file without testing.
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SRB3_CONF}    swconfig_param=0x590108=2
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#...               AND    Get Default Ue Capabilities
#Suite Teardown    Run Keywords    Common Suite Teardown
#...               AND    Delta Commission With SCF File    ${SRB3_RECOV}
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD    CIT    RAN_5G_TDD    FR1    Owner_k3chen    RAN_5G
#...               SBTS00    SBTS23R1    SBTS22R4    SBTS22R3    CDRT
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ../CB006086/Resource/keyword.robot
#
#*** Variables ***
#${SCF_PATH}                       ${CURDIR}/../CB006086/Config
#${DELTA_FILE}                     Delta_conf.json
#${RECOV_FILE}                     Delta_recov.json
#${SRB3_CONF}                      Delta_conf_srb3.json
#${SRB3_RECOV}                     Delta_recov_srb3.json
#${UE_ID}                          11
#${PROFILE_ID}                     1
#${PROFILE_ID1}                    1
#${PROFILE_ID2}                    2
#${SNIR_TARGET_SRS1}               -100
#${SNIR_TARGET_SRS2}               300
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
#${DELTA_XML_FILE}                 ${CURDIR}/../CB006086/Config/Delta.xml
#@{LOG_NAME_LIST}                  btslog    snapshot    tcpdump    #tshark | sherpa | #pmcounter
#${CONST_FILE}                     ${CURDIR}/../CB006086/Config/const_customizer.conf
#${UE_NR_CAP_TDD}                  0300000002000800000180008002002000100965968004000000DE00000000000004E80002000012CB2C0023B6
#${UE_EUTRA_NR_CAP_TDD}            010804028004136200000001008010020200400808010020
#${EXPECTED_TPUT}                  1
#${TCPDUMP_NAME}                   testVM_Tcpdump
#${1_PORT_LAYER}                   nr-rrc.nrofSRS_Ports == 0 && nr-rrc.maxMIMO_Layers == 1
#${2_PORT_LAYER}                   nr-rrc.nrofSRS_Ports == 1 && nr-rrc.maxMIMO_Layers == 2
#@{1_2_PORT_LAYER_FILTER}          ${1_PORT_LAYER}    ${2_PORT_LAYER}
#${EGATE_PATH}                     /opt/iphy/latest/egate_console.log
#@{PORTS_LIST}                     ports2
#
#*** Test Cases ***
#5GC002226_ET_D001_Successful_UE_Reconfiguration_Of_Number_Of_SRS_Ports_With_Support_Of_SRB3
#    NSA NR UE Param Set    ${UE_ID}    ${UE_NR_CAP_TDD}
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    Add Scell Range To NSA
#    Set UE Measurement    ${UE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA UE Testmode NR Profile    ${PROFILE_ID2}    ${SNIR_TARGET_SRS2}    ${SNIR_TARGET_PUSCH2}    ${SNIR_TARGET_PUCCH2}    ${SNIR_TARGET_PREMBLE2}
#    NSA UE Testmode NR Profile    ${PROFILE_ID1}    ${SNIR_TARGET_SRS1}    ${SNIR_TARGET_PUSCH1}    ${SNIR_TARGET_PUCCH1}    ${SNIR_TARGET_PREMBLE1}
#    NSA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID2}
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    50    ${TRF_ID}
#    Sleep    5s    reason=Wait For UL Transmission
#    NSA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID1}
#    Sleep    5s    reason=Wait For UL Transmission
#    NSA LTE Detach    ${UE_ID}
#    CORE.Collect Collectors    names=${TCPDUMP_NAME}    target_dir=${test_log_directory}
#    Check Egate Console Log    ${EGATE_PATH}    ${PORTS_LIST}
#    CORE.Teardown Collectors    names=${TCPDUMP_NAME}