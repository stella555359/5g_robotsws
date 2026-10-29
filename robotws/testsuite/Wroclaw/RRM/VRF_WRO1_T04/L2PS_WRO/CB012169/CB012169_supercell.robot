*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Marcin Kotula
...              :contact: Marcin.Kotula@nokia.com

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/common_keywords.robot
Library     ta5g_egate

*** Variables ***
${iphy_CB012169}       ${CURDIR}/config/iphy_supercell.xml
${scf_CB012169}        ${CURDIR}/config/SBTS00/full_CB012169_supercell.xml
${cfg_CB012169}        ${CURDIR}/config/basic_setup_supercell.cfg
@{SWCONFIG_FLAGS}      0x8000A6=0  0x42009d=31

*** Keywords ***
CB009514_H_05_SA_multi_UE_2TDD_2CC_CA_DL_with_BF_CB007922
    Set Beams Supercell
    Attach UEs    num_ue=1
    Start 1 Gbps DL and 200 Mbps UL Traffic
    Verify Tput For PCell
    Verify Tput For SCell

Set Beams Supercell
    Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=1 num_beam_paths=16
    ...     azimuth=0,17,32,46,0,17,32,46,-21,-37,-50,-10,-21,-37,-50,-10
    ...     zenith=4,4,4,4,4,4,4,4,-7,-7,-7,-7,-7,-7,-7,-7
    ...     power=-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250,-250
    Execute Egate Command   cmd=ue_testmode_set_nr id=1 testmode=ue_ul_beam_position action=activate profile_id=1

Verify Tput For PCell
    Verify Tput For UE    ue_id=1   dir=dl   expected_tput=500
    Verify Tput For UE    ue_id=1   dir=dl   expected_tput=100

Verify Tput For SCell
    Verify Tput For UE    ue_id=1   dir=dl   expected_tput=100    cc=1

Start 1 Gbps DL and 200 Mbps UL Traffic
    FOR    ${id}    IN RANGE    1    7
        Start Dl and UL Traffic     ue_id=1    pdu_id=1    dl_mbps=175    ul_mbps=35    trf_id=${id}
    END
    Sleep  30s
