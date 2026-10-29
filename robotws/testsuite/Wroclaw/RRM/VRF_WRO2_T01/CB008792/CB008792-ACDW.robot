# robocop: disable=not-allowed-char-in-name
*** Settings ***
Documentation
...  author:        Maciej Cupial, Mateusz Cieciura
...  contact:       maciej.cupial@nokia.com, mateusz.cieciura@nokia.com
...  maintainer:    maciej.cupial@nokia.com, mateusz.cieciura@nokia.com
...  feature lead:  Katarzyna Meinhardt (katarzyna.meinhardt@nokia.com)
...  description:   Check if new functionality is working properly for uplink and dowlink and with PUCCH additional
...                 DMRS together (A+C+D subfeautures)

Library         taf.ue
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
#...             Get 5G QXDM and QCAT licenses  ${UE_ALIAS}                    AND
...             Set attenuation and check  lines=${lines_cell1_5G}  value=0   AND
...             Set attenuation and check  lines=${lines_cell2_5G}  value=0   AND
...             Set attenuation and check  lines=${lines_cell3_5G}  value=0   AND
...             Lock all LTE cells

Suite Teardown  Run keywords
...             Unlock all LTE locked cells        AND
...             Turn off attenuation               AND
#...             Release 5G QXDM and QCAT licenses    AND
...             Get and upload default SCF        AND
...             Verify if all cells are onair     AND
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
CB008792-5G-ACDW_Peak.Tput_PDSCH_1AddDMRS_Normall.cell_Vs_2AddDMRS_HS.cell_SA/NSA_PDSCH_mapping_type_A_pos2_FDM_ON
    [Tags]           8792  reg
    [Documentation]  Check if new functionality is working properly for uplink and dowlink and with PUCCH additional
    ...              DMRS together (A+C+D subfeautures)
    CB008792-5G-ACDW_Peak.Tput_PDSCH_1AddDMRS_Normall.cell_Vs_2AddDMRS_HS.cell_SA/NSA_PDSCH_mapping_type_A_pos2_FDM_ON
    Set suite variable  ${8792_flag}  'TRUE'

[1]CB008792-5G-A_1_Activation_and_Deactivation_for_PUSCH_two_additional_DMRS_SA
    [Tags]           8792  reg
    [Documentation]  Tested in CB008792-5G-ACDW_Peak.Tput_PDSCH_1AddDMRS_Normall.cell_Vs_2AddDMRS_HS
    [Setup]  Log to console     Copy status from progenitor TC
    Should be true  ${8792_flag}=='TRUE'
    [Teardown]  Log to console  Status copied.

[1]CB008792-5G-C_18_Peak.Tput_DMRS_SA_PDSCH_256QAM_0kmh
    [Tags]           8792  reg
    [Documentation]  Tested in CB008792-5G-ACDW_Peak.Tput_PDSCH_1AddDMRS_Normall.cell_Vs_2AddDMRS_HS
    [Setup]  Log to console     Copy status from progenitor TC
    Should be true  ${8792_flag}=='TRUE'
    [Teardown]  Log to console  Status copied.

[1]CB008792-5G-D1_01_nonBF_Activation_Deactivation_PUSCH_additional_DMRS_2pos_HS_DL.256QAM_UL.64QAM
    [Tags]           8792  reg
    [Documentation]  Tested in CB008792-5G-ACDW_Peak.Tput_PDSCH_1AddDMRS_Normall.cell_Vs_2AddDMRS_HS
    [Setup]  Log to console     Copy status from progenitor TC
    Should be true  ${8792_flag}=='TRUE'
    [Teardown]  Log to console  Status copied.
