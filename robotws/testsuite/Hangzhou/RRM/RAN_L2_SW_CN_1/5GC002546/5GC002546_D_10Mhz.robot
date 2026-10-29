*** Settings ***
Documentation    ...
#Documentation                           Author :zhachen
#...                                     Squad group : SG_06
#...                                     Feature : 5GC002546-D DSS
#Suite Setup                             Suite Setup DSS
#Suite Teardown                          Common Suite Teardown
#Test Setup                              Common Test Setup
#Test Teardown                           Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G    RAN_5G_TDD    CN1_SQ6    SBTS00    SBTS23R1
#...               SBTS22R4
#Resource                                5GC002546_common_keywords.robot
#
#*** Test Cases ***
#5GC002546_ET_D021_Blind_CA_4UE_10MHz_DSS_Ph2_SA
#    SA Attach    sa_ue_id=1
#    Check CA UE Scell PhycellID    1    52
#    SA Attach    sa_ue_id=2
#    Check CA UE Scell PhycellID    2    52
#    SA Attach    sa_ue_id=3
#    Check CA UE Scell PhycellID    3    52
#    SA Attach    sa_ue_id=4
#    Check CA UE Scell PhycellID    4    52
#    Check UE Pcell Scell Tput On Target 10M
#
#5GC002546_ET_D020_Blind_CA_4UE_Ph2_10MHz_Prbblanklow_SA
#    Clean Edaemon And Egate
#    Prepare ENV    ${SCF_FILE_10M_PRB}    ${WTS_CFG_10M}
#    SA Attach    sa_ue_id=1
#    Check CA UE Scell PhycellID    1    52
#    SA Attach    sa_ue_id=2
#    Check CA UE Scell PhycellID    2    52
#    SA Attach    sa_ue_id=3
#    Check CA UE Scell PhycellID    3    52
#    SA Attach    sa_ue_id=4
#    Check CA UE Scell PhycellID    4    52
#    Check UE Pcell Scell Tput On Target 10M
#
#
#
