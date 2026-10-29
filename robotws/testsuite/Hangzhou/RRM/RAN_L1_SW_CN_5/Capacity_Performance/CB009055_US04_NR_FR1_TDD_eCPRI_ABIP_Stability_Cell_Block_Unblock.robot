*** Settings ***
Documentation
...    Author:  Hou Yuguo
...    Contact: yuguo.hou@nokia-sbell.com
...    Feature: CB009055
...    Release:

Suite Setup    Common Suite Setup And Setup Airphone Env
#Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
#Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LOOO
...    SBTS00    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Library           taf.selenium.sbts  WITH NAME  selenium_coam
Resource    ../resources/Airphone/Airphone_resource.robot
Resource    ../resources/common_resource_bts.robot
Library         ./random_select_cells.py

*** Variables ***
${active_sw}     SBTS23R3_ENB_9999_230417_000003
&{GNB_ASIB}       ip=192.168.255.129    username=toor4nsn
...               password=oZPS0POrRieRtu    connection=GnbAsik

*** Test Cases ***
CB009055_US04_NR_FR1_TDD_eCPRI_ABIP_Stability_Cell_Block_Unblock
    [Documentation]
    ...    This case is to verify ABIP NR FR1 TDD eCPRI cell block and unblock stability
    ...    1. random select 3cells a,b,c
    ...    2. block a,b,c
    ...    3. random select 3cells d,e,f
    ...    4. unblock a, block d
    ...    5. unblock b, block e
    ...    6. unblock c, block f
    ...    7. attach UEs and start traffic data for cell a, b, c
    ...    8. random select 3cells g,h,i
    ...    9. unblock d, block g
    ...    10. unblock e, block h
    ...    11. unblock f, block i
    ...    12. attach UEs and start traffic data for cell d,e,f
    ...       13. unblock g,h,i
    ##cell ids and ue ids directory
    [Tags]    C&P
    ${cells_ues_dict}=    Create Dictionary    1    1-20    2    21-40    3    41-60    4    61-80
    ...                   5    81-100    6    101-120
    Set Test Variable    ${cells_ues_dict}
    ${cells_id}=    Get Dictionary Keys    ${cells_ues_dict}
    Set Test Variable    ${cells_id}
    Ue Attach to cells${cells_id} and start 5G L3 call
    Log To Console  start to block and unblock cells every 600 seconds
    FOR    ${i}    IN RANGE    2
        ${sub_cells_list}=    random select 3group cells in cell ${cells_id}
        log    ${sub_cells_list[0]}
        block cell list ${sub_cells_list[0]}
        Perform unblock cell${sub_cells_list[0][0]} block cell${sub_cells_list[1][0]}
        Perform unblock cell${sub_cells_list[0][1]} block cell${sub_cells_list[1][1]}
        Perform unblock cell${sub_cells_list[1][0]} block cell${sub_cells_list[2][0]}
        Perform unblock cell${sub_cells_list[1][1]} block cell${sub_cells_list[2][1]}
        unblock cell list ${sub_cells_list[2]}
        multiple_ue_throughput_verify    ue_num=120    start_ue=1    dl_mbps=5    ul_mbps=5
    END
    IQ capture for cell1
    Collect Snapshot GNB1
    traffic_data_stop    ue_id=1-120
    Ue Pdu Session Release    ue_id=1-120
    release_ues    ue_id=1-120

*** Keywords ***

Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env  tl_type=AP_LOOO/tdd_sansa_cmwv/FS/6cell_ecpri    cfg=wts.cfg

random select ${number}group cells in cell ${cells}
    #${cells_id_list}    Split String    ${cells}   ,
    @{sub_cells}=    random_split_list    ${cells}    ${number}
    [Return]    ${sub_cells}

block cell list ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        stop traffic data and release ues for cell${cell}
        Perform 5G Cell block ${cell} via AdminCLI
    END

unblock cell list ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Perform 5G Cell unblock ${cell} via AdminCLI
        Sleep    10s
        attach 20ues and start dl 5M ul 5M traffic data for cell${cell}
    END

Perform unblock cell${unblock_cell} block cell${block_cell}
    Perform 5G Cell unblock ${unblock_cell} via AdminCLI
    Sleep    10s
    attach 20ues and start dl 5M ul 5M traffic data for cell${unblock_cell}
    stop traffic data and release ues for cell${block_cell}
    Perform 5G Cell block ${block_cell} via AdminCLI

Ue Attach to cells${cells} and start 5G L3 call
    FOR    ${cell}    IN    @{cells}
        attach 20ues and start dl 5M ul 5M traffic data for cell${cell}
    END

attach ${ue_number}ues and start dl ${dl_data}M ul ${ul_data}M traffic data for cell${number}
    ${ue_ids}=    Get From Dictionary    ${cells_ues_dict}    ${number}
    ${start_end_ues}=    Split String    ${ue_ids}    -
    ${start_ue}=    Get From List    ${start_end_ues}    0
    multiple_ue_register_and_traffic_start    ue_num=${ue_number}    start_ue=${start_ue}    cell_id=${number}
    ...                                       dl_mbps=${dl_data}    ul_mbps=${ul_data}

stop traffic data and release ues for cell${number}
    ${ue_ids}=    Get From Dictionary    ${cells_ues_dict}    ${number}
    traffic_data_stop    ue_id=${ue_ids}
    Ue Pdu Session Release    ue_id=${ue_ids}
    release_ues    ue_id=${ue_ids}

cell block unblock every ${sleep_time} seconds ${times}times
    Log To Console  start to block and unblock cells every ${sleep_time} seconds
    FOR    ${i}    IN RANGE    ${times}
        sleep    ${sleep_time}
        test cell block unblock
    END

IQ capture for cell1
    ${ul_subcell_index_list}=    Create List    [BBMOD_R-1(ABIP)] [PCI: 50]NRCELL-1: Subcell 0
    ${dl_subcell_index_list}=    Create List    [BBMOD_R-1(ABIP)] [PCI: 50]NRCELL-1: Subcell 0
    Configure IQ capture via webUI     ul_subcell_index_list=${ul_subcell_index_list}    dl_subcell_index_list=${dl_subcell_index_list}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    ADMIN Set RAD debug parameters    NrUlPhy    phyEventEnableExt    2147483648
    ADMIN Set RAD debug parameters    NrDlPhy    dlPhyEventEnable    1
    Wait Until Keyword Succeeds    2min    30s    Get Event Trigger Count on BBMOD    bsh 1:1    NR
    Run keyword    Save SnapShot

Save SnapShot
    [Arguments]    ${log_dir}=${TEST_LOG_DIR}
    ${coam_connection}    sbts_admin.Connect To    bts_host=${GNB_ASIB.ip}
    sbts_admin.Get SnapShot    target_file_name=${log_dir}/snapShot.zip
    ...                        coverage=Full    force=True    connection=${coam_connection}
