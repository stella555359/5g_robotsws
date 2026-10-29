*** Settings ***
Documentation
...  author:        Maciej Cupial, Mateusz Cieciura
...  contact:       maciej.cupial@nokia.com, mateusz.cieciura@nokia.com
...  maintainer:    maciej.cupial@nokia.com, mateusz.cieciura@nokia.com
...  feature lead:  Katarzyna Meinhardt (katarzyna.meinhardt@nokia.com)
...  description:   CB008792-A
...                 Tagging concept: [TC number] [additional tag]
...                 eirp - EIRP, ca - Carrier Agregation, sa - standalone, noUE - TC without ue

Library         taf.ue
Library         BuiltIn
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008792/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008792/resources/tests_CB008792.robot

Force Tags      CA_5G_RRM  QCD_MN_5G  QCP_5G  RAN_5G  CRT

Suite Setup     Run keywords
...             setup_teardown.Get BTS id and set as suite variable                          AND
...             Connect with runtime release  ${GNB_ALIAS}                    AND
...             Perform commissioning with 8792 SCF                           AND
...             Delete pyro_server UEPC                                       AND
...             Remove tmp btslog dir                                         AND
...             Setup attenuators                                             AND
...             Set attenuation and check  lines=${lines_cell1_5G}  value=0   AND
...             Set attenuation and check  lines=${lines_cell2_5G}  value=0   AND
...             Set attenuation and check  lines=${lines_cell3_5G}  value=0

Suite Teardown  Run keywords
...             Turn off attenuation

Test Setup      Run keywords
...             Download SCF
...             Start syslog capture

Test Teardown   Run Keywords
...             Collect Snapshot
...             Stop syslog capture
...             Set Scout Configuration ID
...             Recommission to default
...             ssh.reset_cache

*** Test Cases ***
[1]CB008792-5G-A_1_Activation_and_Deactivation_for_PUSCH_two_additional_DMRS_SA
    [Tags]       8792    sa    trunk
    [Documentation]
    ...  This user scenario describes the common gNB behaviour at activation and deactivation
    ...  for PUSCH two additional DMRS SA mode
    [1]CB008792-5G-A_1_Activation_and_Deactivation_for_PUSCH_two_additional_DMRS_SA

[1]CB008792-5G-A_4-PUSCH_two_additional_DMRS_for_normal_cell_SA_PUSCH_mapping_type_A_pos2_FDM_ON_PUSCH_256QAM_0kmh
    [Tags]    8792    sa
    [Documentation]
    ...  This test verifies the user's throughput under different propagation conditions with both one additional DMRS
    ...  and two additional DMRS for normal cell
    [1]CB008792-5G-A_4-PUSCH_two_additional_DMRS_for_normal_cell_SA_PUSCH_mapping_type_A_pos2_FDM_ON_PUSCH_256QAM_0kmh
#    [Teardown]  Run Keywords
#    ...         Release 5G QXDM and QCAT licenses
#    ...         Collect Snapshot
#    ...         Stop syslog capture
#    ...         Recommission to default
#    ...         ssh.reset_cache
