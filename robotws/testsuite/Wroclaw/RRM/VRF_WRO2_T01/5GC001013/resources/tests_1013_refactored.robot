# robocop: disable=not-allowed-char-in-name
*** Settings ***
Documentation
...       Editor: Wiktor Jarosiński
...       Contact Person: Paweł Wiśniewski
...       Edit Reason: Robocop Clean
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/5GC001013/resources/keywords_refactored.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/cplane_collector.robot

*** Variables ***
${scf_path_branch}      commissionings/RRM/WRO_RRM9/AHLOA_CLASS041/7_16_UTE5G286CLASS041_SCF_AHLOA_branch.xml
${scf_path_trunk}       commissionings/RRM/WRO_RRM9/AHLOA_CLASS041/7_16_UTE5G286CLASS041_SCF_AHLOA_trunk.xml
@{lines_cell1_5G}       1    2    3    4
@{lines_cell2_5G}       5    6    7    8
@{lines_cell3_5G}       9    10   11   12
@{lines_cell1_LTE}      13   14
@{lines_cell2_LTE}      15   16
@{slots_not_expected}   20    21    22    23    24
${loop_count}           20
${max_att}              45

*** Keywords ***
[1]5GC001013-A.B2_FDD_RRM_Classical_MG_setup_SgNB_Addition_CP_REF
    [Arguments]  ${ue_alias_1013}=AT_BASED_UE_1
    keywords_refactored.Perform commissioning 1013 REF
    Setup cplane tcpdump collector
    Turn on attenuation
    Detach ue  ${ue_alias_1013}
    Set attenuation and check  ${lines_cell1_LTE}  value=0
    Set attenuation and check  ${lines_cell2_LTE}  value=0
    Set attenuation and check  ${lines_cell1_5G}  value=0
    Start cplane logs
    Attach ue  ${ue_alias_1013}
    slow attenuate cell  ${lines_cell1_LTE}  max_value=${max_att}
    slow attenuate cell to zero  ${lines_cell1_5G}   max_value=90  step=15
    Set attenuation and check  ${lines_cell1_5G}  value=0
    slow attenuate cell to zero  ${lines_cell1_LTE}  max_value=${max_att}  step=15
    Set attenuation and check  ${lines_cell1_LTE}  value=0
    Set attenuation and check  ${lines_cell2_LTE}  value=0
    Set attenuation and check  ${lines_cell1_5G}  value=30
    Set attenuation and check  ${lines_cell2_5G}  value=0
    Set attenuation and check  ${lines_cell1_5G}  value=20
    Set attenuation and check  ${lines_cell1_5G}  value=10
    Set attenuation and check  ${lines_cell1_5G}  value=0
    Set attenuation and check  ${lines_cell2_5G}  value=0
    Stop cplane logs

    Parse and check cplane logs
    [Teardown]  Turn off attenuation

[1]5GC001013-A.B2_FDD_RRM_Classical_MG_setup_SgNB_Addition_CP_REF__23r3
    keywords_refactored.Perform commissioning 1013 REF __23r3
    Setup cplane tcpdump collector
    Turn on attenuation
#    taf.ue.Detach ue  ${ue_alias_1013}
    Set attenuation and check  ${lines_cell1_LTE}  value=0
    Start cplane logs
#    taf.ue.Attach ue  ${ue_alias_1013}
    slow attenuate cell  ${lines_cell1_LTE}  max_value=${max_att}
    slow attenuate cell to zero  ${lines_cell1_5G}   max_value=90  step=15
    slow attenuate cell to zero  ${lines_cell1_LTE}  max_value=${max_att}  step=15
    Stop cplane logs
    Parse and check cplane logs
    [Teardown]  Turn off attenuation

[1]5GC001013-A.B1_FDD_RRM_Classical_MG_setup_SgNB_Modification_DRX_CP_REF
    [Arguments]  ${ue_alias_1013}=AT_BASED_UE_1
    keywords_refactored.Perform commissioning 1013 REF
    Setup cplane tcpdump collector
    Turn on attenuation
    Detach ue  ${ue_alias_1013}
    Set attenuation and check  ${lines_cell1_LTE}  value=0
    Set attenuation and check  ${lines_cell2_LTE}  value=0
    Set attenuation and check  ${lines_cell1_5G}  value=0
    Start cplane logs
    Attach ue  ${ue_alias_1013}
    slow attenuate cell  ${lines_cell1_LTE}  max_value=${max_att}
    slow attenuate cell to zero  ${lines_cell1_5G}   max_value=90  step=15
    Set attenuation and check  ${lines_cell1_5G}  value=0
    slow attenuate cell to zero  ${lines_cell1_LTE}  max_value=${max_att}  step=15
    Set attenuation and check  ${lines_cell1_LTE}  value=0
    Set attenuation and check  ${lines_cell2_LTE}  value=0
    Set attenuation and check  ${lines_cell1_5G}  value=30
    Set attenuation and check  ${lines_cell2_5G}  value=0
    Set attenuation and check  ${lines_cell1_5G}  value=20
    Set attenuation and check  ${lines_cell1_5G}  value=10
    Set attenuation and check  ${lines_cell1_5G}  value=0
    Set attenuation and check  ${lines_cell2_5G}  value=0
    Stop cplane logs
    Parse and check cplane logs B
    [Teardown]  Turn off attenuation

[1]5GC001013-B#B1_03_FDD_Classical_MG_release_during_SgNB_Modification_activDRX_offSRB3_CP_REF
    [Arguments]  ${ue_alias_1013}=AT_BASED_UE_1
    keywords_refactored.Perform commissioning 1013 REF  actCDrx=true
    Setup cplane tcpdump collector
    Turn on attenuation
    Detach ue  ${ue_alias_1013}
    Set attenuation and check  ${lines_cell1_LTE}  value=0
    Set attenuation and check  ${lines_cell2_LTE}  value=0
    Set attenuation and check  ${lines_cell1_5G}  value=0
    Start cplane logs
    Attach ue  ${ue_alias_1013}
    slow attenuate cell  ${lines_cell1_LTE}  max_value=${max_att}
    slow attenuate cell to zero  ${lines_cell1_5G}   max_value=90  step=15
    Set attenuation and check  ${lines_cell1_5G}  value=0
    slow attenuate cell to zero  ${lines_cell1_LTE}  max_value=${max_att}  step=15
    Set attenuation and check  ${lines_cell1_LTE}  value=0
    Set attenuation and check  ${lines_cell2_LTE}  value=0
    Set attenuation and check  ${lines_cell1_5G}  value=30
    Set attenuation and check  ${lines_cell2_5G}  value=0
    Set attenuation and check  ${lines_cell1_5G}  value=20
    Set attenuation and check  ${lines_cell1_5G}  value=10
    Set attenuation and check  ${lines_cell1_5G}  value=0
    Set attenuation and check  ${lines_cell2_5G}  value=0
    Stop cplane logs
    Parse and check cplane logs B
    [Teardown]  Turn off attenuation
