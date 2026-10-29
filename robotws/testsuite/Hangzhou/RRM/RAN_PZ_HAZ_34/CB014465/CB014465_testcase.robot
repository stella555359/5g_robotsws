*** Settings ***
Resource    Resources/CB014465_common_keyword.robot
Variables    Resources/CB014465_variable.py

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

#Suite Setup    SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${False}

*** Variables ***
${tl_scf_dir_path}     ${CURDIR}/../../../../../commissionings/HGZ/

${UL_THROUGHPUT}    300M
${DL_THROUGHPUT}    2000M
${UL_THROUGHPUT_TDD}    220
${DL_THROUGHPUT_TDD}    1450
${UL_THROUGHPUT_FDD}    40
${DL_THROUGHPUT_FDD}    150

*** Test Cases ***
[1][1.0] CB014465_A_6_2 SRS symbols in special slot - DL SRS based wideband beamforming_5GC001116
    [Setup]    SG2_Common_setup_teardown.Common Case setup    scf_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_CB014465_pos1.xml
    ...                                                       need_Btslog=${True}
    CB012149 COAM update Parameters    parameters=${CB014465_enable_MulSrsSplSlot}    timeout=${180}
    Sleep    30s
    CB012149 UE prepare UE
    ${cpif_log}    ${bip_log}    ${gnb_log}    ${cpif_rel_log}    ${cpif_attach_log}    UE Start traffic and Get CP-IF BIP TTI log
    ...                                                                                           need_TTI=${True}
    ...                                                                                           ul_target_tdd=${UL_THROUGHPUT_TDD}
    ...                                                                                           dl_target_tdd=${DL_THROUGHPUT_TDD}
    Check TAS and Codebook after DL traffic start or stop    cpif_log=${cpif_log}
    Check TAS and Codebook after DL traffic start or stop    cpif_log=${cpif_rel_log}    enable=${False}
    Check SymbolPosition in Special Slot    bip_log=${bip_log}
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}

[1][1.0] CB014465_A_6_2 SRS symbols in special slot - DL SRS based wideband beamforming_5GC001116 pos2
    [Setup]    SG2_Common_setup_teardown.Common Case setup    scf_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_CB014465_pos2.xml
    ...                                                       need_Btslog=${True}
    CB012149 UE prepare UE
    ${cpif_log}    ${bip_log_1}    ${gnb_log}    ${cpif_rel_log}    ${cpif_attach_log}    UE Start traffic and Get CP-IF BIP TTI log
    ...                                                                                           need_TTI=${True}
    ...                                                                                           ul_target_tdd=${UL_THROUGHPUT_TDD}
    ...                                                                                           dl_target_tdd=${DL_THROUGHPUT_TDD}
    Check SymbolPosition in Special Slot    bip_log=${bip_log_1}
    CB012149 UE prepare UE    ue_index=${2}
    ${cpif_log}    ${bip_log_2}    ${gnb_log}    ${cpif_rel_log}    ${cpif_attach_log}    UE Start traffic and Get CP-IF BIP TTI log
    ...                                                                                           ue_index=${2}
    ...                                                                                           cellid=3
    ...                                                                                           apn=dxdata1
    ...                                                                                           need_TTI=${True}
    ...                                                                                           ul_target_tdd=${UL_THROUGHPUT_TDD}
    ...                                                                                           dl_target_tdd=${DL_THROUGHPUT_TDD}
    Check SymbolPosition in Special Slot    bip_log=${bip_log_2}    codebook_symbol=10    bip_srs_command_template=${bip_srs_command_template_pci503}
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}

[1][1.0] CB014465_A_6_2 SRS symbols in special slot - DL SRS based wideband beamforming_5GC001116 pos3
    [Setup]    SG2_Common_setup_teardown.Common Case setup    scf_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_CB014465_pos3.xml
    ...                                                       need_Btslog=${True}
    CB012149 UE prepare UE
    ${cpif_log}    ${bip_log_1}    ${gnb_log}    ${cpif_rel_log}    ${cpif_attach_log}    UE Start traffic and Get CP-IF BIP TTI log
    ...                                                                                           need_TTI=${True}
    ...                                                                                           ul_target_tdd=${UL_THROUGHPUT_TDD}
    ...                                                                                           dl_target_tdd=${DL_THROUGHPUT_TDD}
    Check SymbolPosition in Special Slot    bip_log=${bip_log_1}    codebook_symbol=11
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}

[1][1.0] CB014465_B_20_Interwork with FR1 TDD + FR1 TDD UL CA and stepwise Scell addition and inter-gNB CA with CB009103-E
    [Setup]    SG2_Common_setup_teardown.Common Case setup    scf_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_CB014465_IWK.xml
    ...                                                       need_Btslog=${True}
    CB012149 UE prepare UE
    ${cpif_log}    ${bip_log}    ${gnb_log}    ${cpif_rel_log}    ${cpif_attach_log}    UE Start traffic and Get CP-IF BIP TTI log
    ...                                                                                           cellid=3
    ...                                                                                           scellid=6
    ...                                                                                           need_TTI=${True}
    ...                                                                                           ul_target_tdd=${UL_THROUGHPUT_TDD}
    ...                                                                                           dl_target_tdd=${DL_THROUGHPUT_TDD}
    Run Keyword And Continue On Failure    Check SymbolPosition in Special Slot    bip_log=${bip_log}
    ...                                                                            bip_srs_command_template=${bip_srs_command_template_iwk}
    Run Keyword And Continue On Failure    Check Bip log for CB008927    bip_log=${bip_log}
    Run Keyword And Continue On Failure    Check logs for CB010938    cpif_log=${cpif_attach_log}
    Run keyword and ignore error    Check ulTxSwitch Related Info during Traffic Procedure    bip_log=${bip_log}
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}