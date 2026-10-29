*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ./resources/CB008229_keywords.robot
Resource    ../resources/configuration_id.robot
Library     ../resources/Python/webem_alarms.py
Library     resources/CB008229_keywords.py
Library     taf.sbts.oam.coam.admin    WITH NAME    admin

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
...                            iphy_xml_filepath=${CURDIR}/config/A_B2_iphy_ahfii_n25.xml
...    AND                     Start Default Logging
...    AND                     Find Scfc And Fix And Send Full Commissioning    scfc_filename=A_B2.xml
...    AND                     Check Radios Availability
...    AND                     Reach Onair    lua_cfg=${CURDIR}/config/A_B2.cfg
...    AND                     admin.Setup Admin

Suite Teardown    Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB008229-A_B2_UE_attach_and_traffic_after_cell_block_unblock_SA_DFT_OFDM
    Enable PDSCH decoding in the multiplexed slots
    FOR    ${index}    IN RANGE    10
           Set Internal Traffic Type To UE
           Execute Egate Command And Wait For Data    cmd=ue_register id=1
           ...                                        pass_regexp=UE1: UE performed Registration type INITIAL_REGISTRATION
           ...                                        timeout=10
           Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1 session_type=ipv4
           ...                                        pass_regexp=UE-1 PDU SESSION ID-1 setup/reestablishment complete
           ...                                        timeout=10
           Start DL and UL Data Traffic    dl_tput=100    ul_tput=100    quantity=3
           Verify Max Tput For UE SA    ue_id=1    dir=dl    expected_tput=216
           Verify Max Tput For UE SA    ue_id=1    dir=ul    expected_tput=210
           admin.Block all cells    rat=NR
           Sleep    5s
           admin.Unblock all cells    rat=NR
           admin.assert_every    class_name=BTS    proceduralState=OnAir    timeout=30s
           Stop All Data Transfers And Detach UE SA
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    admin.Unblock all cells    rat=NR
    ...           AND             admin.Teardown Admin
    ...           AND             Send Configuration ID To Scout
