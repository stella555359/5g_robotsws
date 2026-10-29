*** Settings ***
Documentation
...   Max tput

Force Tags    CA_RAN_PZ_WRO_2   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP
...           CIT   PY310
...           SBTS00__WITH__CLOUD_5G_CLASSICAL_NSA_HMD_ASIKL_ABILB1_3xAHCA_ENB

Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/max_tput/resources/pz2_wro6_max_tput.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/common.robot
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py

Suite Setup    Run keywords
...            Prepare testline                                      AND
...            taf_ue.Require Ue  ${UE_ALIAS}  capabilities=REAL_UE

Test Teardown  Run Keywords
...            taf_ue.Detach Ue  ${UE_ALIAS}                         AND
...            what_is_wrong_with_pdu                                AND
...            wake_up_samurai                                       AND
...            Set Scout Configuration ID                            AND
...            Max Tput Test Teardown

*** Test Cases ***
# SPLIT UDP
[1]Bi_directional_noDss_Nsa_TputNsaSplitUDP_AhcaS2_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    [1]Bi_directional_noDss_Nsa_TputNsaSplitUDP_AhcaS2_DL4x4CL_UL2x2CL_Bw5MhzAr178000

# TCP SPLIT
[1]Bi_directional_noDss_Nsa_TputNsaSplitTCP_AhcaS1_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    [1]Bi_directional_noDss_Nsa_TputNsaSplitTCP_AhcaS1_DL4x4CL_UL2x2CL_Bw5MhzAr178000

[1]Bi_directional_noDss_Nsa_TputNsaSplitTCP_AhcaS2_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    [1]Bi_directional_noDss_Nsa_TputNsaSplitTCP_AhcaS2_DL4x4CL_UL2x2CL_Bw5MhzAr178000

[1]Bi_directional_noDss_Nsa_TputNsaSplitTCP_AhcaS3_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    [1]Bi_directional_noDss_Nsa_TputNsaSplitTCP_AhcaS3_DL4x4CL_UL2x2CL_Bw5MhzAr178000
