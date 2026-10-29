*** Settings ***
Documentation    ...
#Documentation     this case is to verify ul srs ports number be changed depend on ulsinr profile of AP.
#...
#...               Author: qiqi.luo@nokia-sbell.com
#...
#...               Please do not edit the existing keywords in this file without testing.
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${DELTA_FILE}    swconfig_param=0x590108=2
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#...               AND    Get Default Ue Capabilities
#Suite Teardown    Run Keywords    Common Suite Teardown
#...               AND    Delta Commission With SCF File    ${RECOV_FILE}
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    FR1    Owner_qiqluo    RAN_5G
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
#${UE_NR_CAP_TDD}                  E120700047D0FFB17DE8E6BC0A03406939F3489E7C003018807C07C0203F000B6F3800007BDEB70D0645020E0000275C0228B64B540B027C8
#...                               73E808F18E7CC31E50B0381C3C19BCE00401EF7ADC341914083800009D7008A2D92D502C09F21CFA023C639F30C7942C0E070F066F380D807
#...                               BDEB70D0645020E0000275C0228B64B540B027C873E808F18E7CC31E50B0381C3C19BCF89A01EF7ADC341914083800009D7008A2D92D502C0
#...                               9F21CFA023C639F30C7942C0E070F0527FC9FF6F3802007BDEB70D0645020E0000275C0228B64B540B027C873E808F18E7CC31E50B0381C3C
#...                               19BCE00C01EF7ADC341914083800009D7008A2D92D502C09F21CFA023C639F30C7942C0E070F066F3803807BDEB70D0645020E0000275C022
#...                               8B64B540B027C873E808F18E7CC31E50B0381C3C19BCE02601EF7ADC341914083800009D7008A2D92D502C09F21CFA023C639F30C7942C0E0
#...                               70F066F3812807BDEB70D0645020E0000275C0228B64B540B027C873E808F18E7CC31E50B0381C3C19BCE04E01EF7ADC341914083800009D7
#...                               008A2D92D502C09F21CFA023C639F30C7942C0E070F066F3814007BDEB70D0645020E0000275C0228B64B540B027C873E808F18E7CC31E50B
#...                               0381C3C19BCE09801EF7ADC341914083800009D7008A2D92D502C09F21CFA023C639F30C7942C0E070F06FE0000002C03E002B1C0C0381F82
#...                               80381F000E5A00000E0000E54D00018000096525003CAADA0207000F003502A0004080C0E26020616202224321830363E824A4C4E5048A900
#${EXPECTED_TPUT}                  1
#${EGATE_PATH}                     /opt/iphy/latest/egate_console.log
#${EXPECTED_PORTS}                 ports2
#
#
#*** Test Cases ***
#CB006086_ET_005_Use_Measurements_From_ENB_At_Sgnb_Addition_To_Judge_Radio_Conditions_And_Decide_Initial_Transmission_Mode_UL_Closed_Loop_Mimo_Rank_2
#    ${UE_ID}=    Set Variable If    "${GNBCUTYPE}"=="SANSA"    11    ${UE_ID}
#    Set Suite Variable    ${UE_ID}    ${UE_ID}
#    ${UE_NR_CAP_TDD}    String.Replace String    ${UE_NR_CAP_TDD}    ${SPACE}    ${EMPTY}
#    NSA NR UE Param Set    ${UE_ID}    ${UE_NR_CAP_TDD}
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    Add Scell Range To NSA
#    Set UE Measurement    ${UE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA UE Testmode NR Profile    ${PROFILE_ID2}    ${SNIR_TARGET_SRS2}    ${SNIR_TARGET_PUSCH2}    ${SNIR_TARGET_PUCCH2}    ${SNIR_TARGET_PREMBLE2}
#    NSA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID2}
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    50    ${TRF_ID}
#    NSA Check Average Traffic Bigger Than Target    ${UE_ID}    ${BEARER_ID}    ul    ${EXPECTED_TPUT}
#    Sleep    5s    reason=Wait For UL Transmission
#    NSA LTE Detach    ${UE_ID}
#    Check Egate Console Log Single Port    ${EGATE_PATH}    ${EXPECTED_PORTS}
#
#CB006086_ET_004_UE_Reconfiguration_With_Number_Of_SRS_Ports_One_Fail
#    ${UE_ID}=    Set Variable If    "${GNBCUTYPE}"=="SANSA"    11    ${UE_ID}
#    Set Suite Variable    ${UE_ID}    ${UE_ID}
#    ${UE_NR_CAP_TDD}    String.Replace String    ${UE_NR_CAP_TDD}    ${SPACE}    ${EMPTY}
#    NSA NR UE Param Set    ${UE_ID}    ${UE_NR_CAP_TDD}
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    Add Scell Range To NSA
#    Set UE Measurement    ${UE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#    NSA UE Testmode NR Profile    ${PROFILE_ID2}    ${SNIR_TARGET_SRS2}    ${SNIR_TARGET_PUSCH2}    ${SNIR_TARGET_PUCCH2}    ${SNIR_TARGET_PREMBLE2}
#    NSA UE Testmode NR Profile    ${PROFILE_ID1}    ${SNIR_TARGET_SRS1}    ${SNIR_TARGET_PUSCH1}    ${SNIR_TARGET_PUCCH1}    ${SNIR_TARGET_PREMBLE1}
#    NSA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID2}
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    50    ${TRF_ID}
#    Set X2 Failure
#    NSA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID1}
#    Sleep    20s    reason=Wait For RRC Reconfig SRS Ports Number
#    NSA LTE Detach    ${UE_ID}
#    Check Egate Console Log Single Port    ${EGATE_PATH}    ${EXPECTED_PORTS}
