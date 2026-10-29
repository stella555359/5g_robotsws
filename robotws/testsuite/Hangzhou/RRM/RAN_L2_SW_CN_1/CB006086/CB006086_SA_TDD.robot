*** Settings ***
Documentation    ...
#Documentation     this case is to verify ul srs ports number be changed depend on ulsinr profile of AP.
#...
#...               Author: qiqi.luo@nokia-sbell.com
#...
#...               Please do not edit the existing keywords in this file without testing.
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#...               AND    Get Default Ue Capabilities
#Suite Teardown    Run Keywords    Common Suite Teardown
#...               AND    Delta Commission With SCF File    ${RECOV_FILE}
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    FR1    Owner_qiqluo    RAN_5G
#...               SBTS00    SBTS23R1    SBTS22R4
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          Resource/keyword.robot
#
#*** Variables ***
#${SCF_PATH}                       ${CURDIR}/Config
#${DELTA_FILE}                     Delta_conf.json
#${RECOV_FILE}                     Delta_recov.json
#${SRB3_CONF}                      Delta_conf_srb3.json
#${SRB3_RECOV}                     Delta_recov_srb3.json
#${UE_ID}                          1
#${PROFILE_ID}                     1
#${PROFILE_ID1}                    2
#${PROFILE_ID2}                    20
#${SNIR_TARGET_SRS1}               200
#${SNIR_TARGET_SRS2}               -100
#${SNIR_TARGET_PUSCH1}             200
#${SNIR_TARGET_PUSCH2}             -100
#${SNIR_TARGET_PUCCH1}             100
#${SNIR_TARGET_PUCCH2}             100
#${SNIR_TARGET_PREMBLE1}           100
#${SNIR_TARGET_PREMBLE2}           100
#${GNB_ID}                         2
#${CELL_ID}                        1
#${PDU_ID}                         1
#${TRF_ID}                         1
#${DELTA_XML_FILE}                 ${CURDIR}/Config/Delta.xml
#@{LOG_NAME_LIST}                  btslog    snapshot    tcpdump    #tshark | sherpa | #pmcounter
#${CONST_FILE}                     ${CURDIR}/Config/const_customizer.conf
#${UE_NR_CAP_TDD}                  E1A00000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965954C043D6C10101070EF1C39061C001032
#...                               78FAB80027800E0009E00151B133582028680965954C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13758202868096
#...                               5954C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965954C043D6C10101070EF1C39061C00103278FA
#...                               A8000028000000841C4D00000000202682807008089EC1601800140E0601C0C01601C001A0F8000000000000395340004000025965400D2AA
#...                               A0207000B000000040080118B130001020304050607080B101112131921252627284A0
#${EXPECTED_TPUT}                  1
#${TCPDUMP_NAME}                   testVM_Tcpdump
#${1_PORT_LAYER}                   nr-rrc.nrofSRS_Ports == 0 && nr-rrc.maxMIMO_Layers == 1
#${2_PORT_LAYER}                   nr-rrc.nrofSRS_Ports == 1 && nr-rrc.maxMIMO_Layers == 2
#@{1_2_PORT_LAYER_FILTER}          ${1_PORT_LAYER}    ${2_PORT_LAYER}
#${EGATE_PATH}                     /opt/iphy/latest/egate_console.log
#@{PORTS_LIST}                     port1    port1    ports2
#
#*** Test Cases ***
#CB006086_ET_006_Transition_From_Single_Tx_To_Rank2_Then_To_Single_Tx_Transmission_On_PUSCH_With_TDD_SA
#    ${UE_NR_CAP_TDD}    String.Replace String    ${UE_NR_CAP_TDD}    ${SPACE}    ${EMPTY}
#    NSA NR UE Param Set    ${UE_ID}    ${UE_NR_CAP_TDD}
#    #Start Ttitrace With Streaming Mode
#    #Start GNB BIP By Admin Method
#    SA Single UE Attach    ${UE_ID}
#    SA Start UL Traffic Internal    ${UE_ID}    ${PDU_ID}    50    ${TRF_ID}
#    SA UE Testmode NR Profile    ${PROFILE_ID1}    ${SNIR_TARGET_SRS1}    ${SNIR_TARGET_PUSCH1}    ${SNIR_TARGET_PUCCH1}    ${SNIR_TARGET_PREMBLE1}
#    SA UE Testmode NR Profile    ${PROFILE_ID2}    ${SNIR_TARGET_SRS2}    ${SNIR_TARGET_PUSCH2}    ${SNIR_TARGET_PUCCH2}    ${SNIR_TARGET_PREMBLE2}
#    SA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID1}
#    Sleep    60s    reason=Wait For UL Transmission
#    SA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID2}
#    Sleep    60s    reason=Wait For UL Transmission
#    SA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID1}
#    Sleep    60s    reason=Wait For UL Transmission
#    SA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID2}
#    Sleep    60s    reason=Wait For UL Transmission
#    #Stop Gnb BIP By Admin Method    log_path=${TEST_LOG_Directory}
#    #common_Log_capture.Stop Ttitrace    log_dir=${TEST_LOG_Directory}
#    #common_Log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${TEST_LOG_Directory}
#    #Format Tti In Stream Mode    ${TEST_LOG_Directory}/output_dl.csv    ${TEST_LOG_Directory}/output_dl_formated.csv
#    #Format Tti In Stream Mode    ${TEST_LOG_Directory}/output_ul.csv    ${TEST_LOG_Directory}/output_ul_formated.csv
#    Check Egate Console Log    ${EGATE_PATH}    ${PORTS_LIST}
