*** Settings ***
Documentation
...  author:        Maciej Cupial, Mateusz Cieciura
...  contact:       maciej.cupial@nokia.com, mateusz.cieciura@nokia.com
...  maintainer:    maciej.cupial@nokia.com, mateusz.cieciura@nokia.com
...  feature lead:  katarzyna.meinhardt@nokia.com
...  description:   CB008792-B
...                 Tagging concept: [TC number] [additional tag]
...                 eirp - EIRP, ca - Carrier Agregation, sa - standalone, noUE - TC without ue

Library         taf.ue
Library         BuiltIn
Library         ute_syslog
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008792/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008792/resources/tests_CB008792.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_6898.robot

Force Tags      CA_5G_RRM  QCD_MN_5G  QCP_5G  RAN_5G  CRT

Suite Setup     Run keywords
...             power on testline                                             AND  #UTE
...             sleep    3m                                                   AND  #UTE
...             Prepare testline before test                                  AND  #UTE
...             setup_teardown.Get BTS id and set as suite variable                          AND
...             Connect to gNB and eNB                                        AND
...             Perform commissioning with 8792 SCF                           AND
...             Delete pyro_server UEPC                                       AND
...             Remove tmp btslog dir                                         AND
...             Setup attenuators                                             AND
...             Set attenuation and check  lines=${lines_cell1_5G}  value=0   AND
...             Set attenuation and check  lines=${lines_cell2_5G}  value=0   AND
...             Set attenuation and check  lines=${lines_cell3_5G}  value=0   AND
...             Lock all LTE cells

Suite Teardown  Run keywords
...             Unlock all LTE locked cells
...             Turn off attenuation
...             Get and upload default SCF
...             Verify if all cells are onair
...             power off testline  #UTE

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
[1]CB008792-5G-B_23_Activation_and_deactivation_for_uplink_DMRS+PTRS_highspeedcell_SA_NSA_ulFreqDensityTreshNrb0=279
    [Tags]           8792
    [Documentation]  This user scenario describes the common gNB behaviour at activation and deactivation for PUSCH PTRS
    ...              and partially PDSCH PTRS in highspeed cell
    [1]CB008792-5G-B_23_Activation_and_deactivation_for_uplink_DMRS+PTRS_highspeedcell_SA_NSA_ulFreqDensityTreshNrb0=279

[1]CB008792-5G-B_27_PUSCH_DMRS+PTRS_SA_PUSCH_capable_0kmh
    [Tags]           8792  sa  reg
    [Documentation]  This test verifies the static user's peak throughput in high speed cell with activated UL PTRS
    [1]CB008792-5G-B_27_PUSCH_DMRS+PTRS_SA_PUSCH_capable_0kmh
#    [Teardown]  Run Keywords
#    ...         Release 5G QXDM and QCAT licenses
#    ...         Collect Snapshot
#    ...         Stop syslog capture
#    ...         Recommission to default
#    ...         ssh.reset_cache
