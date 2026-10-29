*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Marcin Kotula
...              :contact: marcin.kotula@nokia.com

Resource    resources/CB009843_keywords.robot
Resource    ../resources/common_keywords.robot

*** Variables ***
${iphy_CB009843}                ${CURDIR}/config/iphy_6xAVQL.xml
${scf_CB009843}                 ${CURDIR}/config/SBTS00/full_CB009843_6xAVQL_MIX_celltype_BW.xml
${cfg_CB009843}                 ${CURDIR}/config/basic_setup_CB009843.cfg
@{SWCONFIG_FLAGS_CB009843}      0x8000A6=0  0x42009d=31
@{cell_ids}                     1  2  3  4  5  6

*** Keywords ***
General_SiSo_Cell_block_and_unblock
    Set Beams CB009843
    Attach UEs    num_ue=6
    Start Dl and UL Data Traffic For All UEs    num_ue=6    dl_mbps=175    ul_mbps=100
    Check DL and UL TPUT For All Cells
    Lock Single Cell    cell_id=1      timeout=60
    Check DL and UL TPUT After Cell-1 Block
    Unlock Single Cell    cell_id=1      timeout=120
    Sleep   30s
    Attach UE From Locked Cell     ue_id=1
    Start Dl and UL Traffic     ue_id=1    pdu_id=1    dl_mbps=175    ul_mbps=100
    Lock Single Cell    cell_id=3      timeout=60
    Check DL and UL TPUT After Cell-3 Block
    Unlock Single Cell    cell_id=3      timeout=120
    Sleep   30s
    Attach UE From Locked Cell     ue_id=3
    Start Dl and UL Traffic     ue_id=3    pdu_id=3    dl_mbps=175    ul_mbps=100
    Lock Single Cell    cell_id=6      timeout=60
    Check DL and UL TPUT After Cell-6 Block
    Unlock Single Cell    cell_id=6      timeout=120
    Sleep   30s
    Attach UE From Locked Cell     ue_id=6
    Start Dl and UL Traffic     ue_id=6    pdu_id=6    dl_mbps=175    ul_mbps=100
    Stop All Data Transfers And Detach UE    ue_num=6

Manual_SiSo_CM_Recommissioning
    Set Beams CB009843
    Attach UEs    num_ue=6
    Start Dl and UL Data Traffic For All UEs    num_ue=6    dl_mbps=175    ul_mbps=100
    Check DL and UL TPUT For All Cells
    Perform Parameter Commissioning    dist_name=MRBTS-1/MNL-1
    ...     parameter=timeZone    value=(GMT+5.5) Asia/Calcutta
    Check Radios Availability
    Wait Until Cells Are Onair  timeout=600    enb_id=2    cell_ids=@{cell_ids}
    Attach UEs    num_ue=6
    Start Dl and UL Data Traffic For All UEs    num_ue=6    dl_mbps=175    ul_mbps=100
    Check DL and UL TPUT For All Cells
    Perform Parameter Commissioning For dlMuMaxNumLayerPerMuRbg
    Check DL and UL TPUT For All Cells
    Stop All Data Transfers And Detach UE    ue_num=6


General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    Set Beams CB009843
    Attach UEs    num_ue=6
    Start Dl and UL Data Traffic For All UEs    num_ue=6    dl_mbps=175    ul_mbps=100
    Sleep   180s
    Check DL and UL TPUT For All Cells
    Stop All Data Transfers And Detach UE    ue_num=6


Perform Parameter Commissioning For dlMuMaxNumLayerPerMuRbg
    FOR    ${id}    IN RANGE    1    7
        Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1
        ...     parameter=dlMuMaxNumLayerPerMuRbg    value=6
    END
    Sleep   10s


Check DL and UL TPUT For All Cells
    Verify Tput For UE    ue_id=1   dir=ul    expected_tput=80
    Verify Tput For UE    ue_id=1   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=2   dir=ul    expected_tput=90
    Verify Tput For UE    ue_id=2   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=3   dir=ul    expected_tput=90
    Verify Tput For UE    ue_id=3   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=4   dir=ul    expected_tput=90
    Verify Tput For UE    ue_id=4   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=5   dir=ul    expected_tput=60
    Verify Tput For UE    ue_id=5   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=6   dir=ul    expected_tput=20
    Verify Tput For UE    ue_id=6   dir=dl    expected_tput=150

Check DL and UL TPUT After Cell-1 Block
    Verify Tput For UE    ue_id=2   dir=ul    expected_tput=90
    Verify Tput For UE    ue_id=2   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=3   dir=ul    expected_tput=90
    Verify Tput For UE    ue_id=3   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=4   dir=ul    expected_tput=90
    Verify Tput For UE    ue_id=4   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=5   dir=ul    expected_tput=60
    Verify Tput For UE    ue_id=5   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=6   dir=ul    expected_tput=20
    Verify Tput For UE    ue_id=6   dir=dl    expected_tput=150

Check DL and UL TPUT After Cell-3 Block
    Verify Tput For UE    ue_id=1   dir=ul    expected_tput=80
    Verify Tput For UE    ue_id=1   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=2   dir=ul    expected_tput=90
    Verify Tput For UE    ue_id=2   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=4   dir=ul    expected_tput=90
    Verify Tput For UE    ue_id=4   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=5   dir=ul    expected_tput=60
    Verify Tput For UE    ue_id=5   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=6   dir=ul    expected_tput=20
    Verify Tput For UE    ue_id=6   dir=dl    expected_tput=150

Check DL and UL TPUT After Cell-6 Block
    Verify Tput For UE    ue_id=1   dir=ul    expected_tput=80
    Verify Tput For UE    ue_id=1   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=2   dir=ul    expected_tput=90
    Verify Tput For UE    ue_id=2   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=3   dir=ul    expected_tput=90
    Verify Tput For UE    ue_id=3   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=4   dir=ul    expected_tput=90
    Verify Tput For UE    ue_id=4   dir=dl    expected_tput=150
    Verify Tput For UE    ue_id=5   dir=ul    expected_tput=60
    Verify Tput For UE    ue_id=5   dir=dl    expected_tput=150

Set Beams CB009843
    Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=1 num_beam_paths=16
    ...     azimuth=0,17,32,46,0,17,32,46,-21,-37,-50,-10,-21,-37,-50,-10
    ...     zenith=4,4,4,4,4,4,4,4,-7,-7,-7,-7,-7,-7,-7,-7
    ...     power=-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250
    Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=2 num_beam_paths=16
    ...     azimuth=0,-17,-32,-46,0,-17,-32,-46,21,37,50,10,21,37,50,10
    ...     zenith=-4,-4,-4,-4,-4,-4,-4,-4,7,7,7,7,7,7,7,7
    ...     power=-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250
    Execute Egate Command   cmd=ue_testmode_set_nr id=1 testmode=ue_ul_beam_position action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=2 testmode=ue_ul_beam_position action=activate profile_id=2
    Execute Egate Command   cmd=ue_testmode_set_nr id=3 testmode=ue_ul_beam_position action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=4 testmode=ue_ul_beam_position action=activate profile_id=2
    Execute Egate Command   cmd=ue_testmode_set_nr id=5 testmode=ue_ul_beam_position action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=6 testmode=ue_ul_beam_position action=activate profile_id=2

Attach UE From Locked Cell
    [Arguments]    ${ue_id}
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${ue_id}
    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session    ue_id=${ue_id}     pdu_id=${ue_id}     gw_id=${ue_id}
