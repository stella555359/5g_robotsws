*** Settings ***
Documentation    ...
#Documentation                           Author :zhachen
#...                                     Squad group : SG_06
#...                                     Feature : 5GC002546-D DSS
#Suite Setup                             Prepare ENV PH3    ${SCF_FILE_20M}    ${WTS_CFG_20M}
#Suite Teardown                          Common Suite Teardown
#Test Setup                              Common Test Setup
#Test Teardown                           Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G    RAN_5G_TDD    CN1_SQ6    SBTS00    SBTS23R1
#...               SBTS22R4
#Resource                                5GC002546_common_keywords.robot
#
#*** Test Cases ***
#
#5GC002546_ET_D012_Bufferbased_CA_4UE_DSS_Ph2_20MHz_SA
#    SA Attach    sa_ue_id=1
#    Check CA UE Scell PhycellID    1    52
#    SA Attach    sa_ue_id=2
#    Check CA UE Scell PhycellID    2    52
#	SA Attach    sa_ue_id=3
#    Check CA UE Scell PhycellID    3    52
#    SA Attach    sa_ue_id=4
#    Check CA UE Scell PhycellID    4    52
#    Check UE Pcell Scell Tput On Target
#
#5GC002546_ET_D022_Bufferbased_CA_4UE_20MHz_DSS_PrbblankHi_SA
#    Clean Edaemon And Egate
#    Prepare ENV    ${SCF_FILE_20M_PRB}    ${WTS_CFG_20M}
#    SA Attach    sa_ue_id=1
#    A1 Triggered Scell Addition    ueId=1    rsrpnr=75
#    Check CA UE Scell PhycellID    1    52
#    SA Attach    sa_ue_id=2
#    A1 Triggered Scell Addition    ueId=2    rsrpnr=75
#    Check CA UE Scell PhycellID    2    52
#    SA Attach    sa_ue_id=3
#    A1 Triggered Scell Addition    ueId=3    rsrpnr=75
#    Check CA UE Scell PhycellID    3    52
#    SA Attach    sa_ue_id=4
#    A1 Triggered Scell Addition    ueId=4    rsrpnr=75
#    Check CA UE Scell PhycellID    4    52
#    SA Attach    sa_ue_id=9
#    A1 Triggered Scell Addition    ueId=9    rsrpnr=75
#    Check CA UE Scell PhycellID    9    52
#    Check UE Pcell Scell Tput On Target PRB
#
