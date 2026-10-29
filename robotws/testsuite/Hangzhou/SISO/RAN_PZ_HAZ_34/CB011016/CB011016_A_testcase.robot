*** Settings ***
Resource    Resources/CB011016_common_keyword.robot
Variables    Resources/CB011016_A_variables.py

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

Force Tags    RAN_5G   RAN_5G_TDD   STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_AQHA_AHPH_2xAHPF   SBTS00   CRT
...   PY39

#Suite Setup    SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${False}
Suite Setup    Run Keywords     SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${True}    AND
...                             CB011016 COAM update lbpsPeriod    lbpsPeriod=${CB011016_lbpsPeriod_List}

*** Variables ***
@{energySavingState_1}    notEnergySaving    notEnergySaving    notEnergySaving
@{energySavingState_2}    reducedEnergySaving    notEnergySaving    notEnergySaving
@{energySavingState_3}    reducedEnergySaving    energySaving    notEnergySaving

@{energySavingState_4}    reducedEnergySaving    notEnergySaving    reducedEnergySaving
@{energySavingState_5}    energySaving    notEnergySaving    reducedEnergySaving
@{energySavingState_6}    energySaving    energySaving    reducedEnergySaving
@{energySavingState_7}    reducedEnergySaving    reducedEnergySaving    notEnergySaving
@{energySavingState_8}    energySaving    reducedEnergySaving    notEnergySaving
@{energySavingState_9}    energySaving    reducedEnergySaving    energySaving
${tl_scf_dir_path}     commissionings/HGZ

*** Test Cases ***
[1]CB011016_A_001_Activate Load-Based Reduced TX Path Power Saving, trigger switch off TX paths on AHPF
    [Setup]    SG2_Common_setup_teardown.Common Case setup    need_Btslog=${True}
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_1}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${CB011016_5GC000431_Enable_Flag}
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_2}    timeOut=1min
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_3}    timeOut=6min
    Sleep    20min
    CB011016 Get PM Counter to Compare
    COAM Update several parameters via rest api    parameters_to_update_via_api=${CB011016_5GC000431_Disable_Flag}
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_1}
    Wait Until Keyword Succeeds   2 min  10s   COAM Wait for gnb ready and cell setup    gnb_type='SA'
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}

[1]CB011016_A_002_Trigger switch on TX paths on AHPF
    [Setup]    SG2_Common_setup_teardown.Common Case setup    need_Btslog=${True}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${CB011016_Enable_Flag}
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_2}
    UE Start Traffic and Check BTS energySavingState    energySavingState=@{energySavingState_1}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${CB011016_Disable_Flag}
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_1}
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}

[1]CB011016_A_005_Activate Load-Based Reduced TX Path Power Saving, trigger switch off TX paths after cell locked on AHPF
    [Setup]    SG2_Common_setup_teardown.Common Case setup    need_Btslog=${True}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${CB011016_Enable_Flag}
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_2}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${CB011016_Lock_Cell}
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_1}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${CB011016_Unlock_Cell}
    Wait Until Keyword Succeeds   2 min  10s   COAM Wait for gnb ready and cell setup    gnb_type='SA'
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_2}    timeOut=1min 30s
    COAM Update several parameters via rest api    parameters_to_update_via_api=${CB011016_Lock_RMOD}
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_1}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${CB011016_Unlock_RMOD}
    Wait Until Keyword Succeeds   2 min  10s   COAM Wait for gnb ready and cell setup    gnb_type='SA'
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_2}    timeOut=1min 30s
    COAM Update several parameters via rest api    parameters_to_update_via_api=${CB011016_Disable_Flag}
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_1}
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}

[1]CB010683-A_TC4_PSG parameters modification at cell level
    [Setup]    SG2_Common_setup_teardown.Common Case setup    need_Btslog=${True}
    ${testline_name}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}/${testline_name}/SCF_10683.xml
    ...                              timeout=500    is_pdl_checking_needed=${False}
    Wait Until Keyword Succeeds   2 min  10s   COAM Wait for gnb ready and cell setup    gnb_type='SA'
    CB011016 COAM update lbpsPeriod    lbpsPeriod=${CB010683_lbpsPeriod_List}
    Connect to gnb coam via ssl
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_2}    timeOut=30s
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_4}
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_5}    timeOut=6min 30s
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_6}    timeOut=6min 30s
    CB011016 COAM update lbpsPeriod    lbpsPeriod=${CB010683_lbpsCellPeriod_List_Update}
    Connect to gnb coam via ssl
    Wait until cluster is on cell on air status    timeout=15 min    is_all_cells_checking_needed=${True}
    #Wait Until Keyword Succeeds   2 min  10s   CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_2}
    Wait Until Keyword Succeeds   2 min  10s   CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_7}
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_8}    timeOut=6min 30s
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState_9}    timeOut=6min 30s
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}
    ...                                                                                             is_need_to_recover=${True}

*** Keywords ***
