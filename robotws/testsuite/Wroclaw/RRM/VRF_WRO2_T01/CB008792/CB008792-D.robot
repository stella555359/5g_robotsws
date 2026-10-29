# robocop: disable=not-allowed-char-in-name
*** Settings ***
Documentation
...  author:        Maciej Cupial, Mateusz Cieciura
...  contact:       maciej.cupial@nokia.com, mateusz.cieciura@nokia.com
...  maintainer:    maciej.cupial@nokia.com, mateusz.cieciura@nokia.com
...  feature lead:  Katarzyna Meinhardt (katarzyna.meinhardt@nokia.com)
...  description:   CB008792-D

Library         taf.ue
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
CB008792-5G-D1_01_nonBF_Activation_Deactivation_PUSCH_additional_DMRS_2pos_HS_DL.256QAM_UL.64QAM
    [Tags]           8792
    [Documentation]  8792D
    CB008792-5G-D1_01_nonBF_Activation_Deactivation_PUSCH_additional_DMRS_2pos_HS_DL.256QAM_UL.64QAM
