*** Settings ***
Documentation
...    copyright: Nokia

Resource    CB010944_keywords.robot
Resource    ../CB007813/connect.robot
Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ../resources/configuration_id.robot
Resource    ../resources/common_keywords.robot
Library     vendor_file_modifier.py
Library     ../resources/Python/webem_alarms.py
Library     ../resources/Python/traffic_management.py

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_4xAVQL.xml
    ...                        swconfig_flags_list=@{L2PS_BIP_SIZE}
    ...        AND             Start Default Logging
    ...        AND             Perform Commissioning With Limited PRB In L1 Pool    scf=7_2_e_4xAVQL
    ...        AND             Check Radios Availability
    ...        AND             Get and Update BSR File
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_4_cells.cfg
    ...        AND             Enable Emf
    ...        AND             Active beam

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{L2PS_BIP_SIZE}      0x3F007C=50     0x8000A6=0
${PROFILE_UE1}        ul_ue_beam_pos_nr profile_id=1 num_beam_paths=2 azimuth=0,20 zenith=0,0 power=-300,-300
${SET_PROFILE_UE1}    ue_testmode_set_nr id=1 testmode=ue_ul_beam_position profile_id=1 action=activate
${tshark_filter}      (nr_l1dl_l2ps_dldata_pdschsendreql1sw_t) && (DlData_PdschGrantL1sw.patternId_item) && (DlData_PdschGrantL1sw.numOfPrb)

*** Test Cases ***
CB010944-A#B16_Interworking_with_BBPooling_72e
    Verify Target Beam Candidates
    Check Selected Beam Candidates    NRBEAM_EMF-1
    Set Internal Traffic Type To UE    ue_id=1    pdu_id=1
    Set Ue Position
    Attach SA UE And Verify msg2TPC     ue_id=1      msg2TPC_value=3
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In DL
    Sleep    20s
    Start Gathering BIP Logs And Wait 5s
    Stop gnbMirroring And Gather L1L2 Bip Logs
    Verify Tput For UE    ue_id=1   dir=dl    expected_tput=158
    Verify Max PRB for Emf And Ue
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE    ue_num=1
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Verify Tput For UE
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}

Set Ue Position
      Execute Egate Command    cmd=ue_change_location id=1 cell=4
      Execute Egate Command    cmd=${PROFILE_UE1}
      Sleep    1s
      Execute Egate Command    cmd=${SET_PROFILE_UE1}

Start Data Traffic In DL
     Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=150 trf_id=1
     Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=150 trf_id=2
     Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=150 trf_id=3
     Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=150 trf_id=4
     Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=150 trf_id=5

Perform Commissioning With Limited PRB In L1 Pool
    [Arguments]  ${scf}
    ${oam_alias}=    connect.Setup OAM session
    ${vendor_path}=    Set Variable    ${OUTPUT_DIR}/vendor_lte.xml
    admin.download_vendor_file    target_file_name=${vendor_path}    connection=${oam_alias}
    Backup Vendor File  file_path=${vendor_path}
    Modify Vendor File For ABIP With Limited PRB In L1 Pool
    admin.set_vendor_file  vendor_file=${vendor_path}  connection=${oam_alias}
    Find And Fix Scfc   scfc_filename=${scf}.xml
    ${paths} =    List Directory    ${OUTPUT_DIR}    ${scf}*MOD*.xml
    admin.perform_commissioning    scf_file=${OUTPUT_DIR}/${paths}[0]
    ...                            connection=${oam_alias}
    ...                            skip_parameter_relation_errors=True
    ...                            timeout=600
    connect.Teardown OAM session    connection=${oam_alias}

Modify Vendor File For ABIP With Limited PRB In L1 Pool
    [Arguments]  ${LOG_PATH}=${OUTPUT_DIR}   ${maxNumLayerPrbL1Sp}=650

    ${filter_criteria}=    Create Dictionary
    ...  bbHwVariant=ABIP
    ...  direction=DL
    ...  l1PoolType=NR_L1Pool_Thor_TDD_FR1_eCPRI_7_2e
    ${data_to_be_modified}=    Create Dictionary
    ...  maxNumLayerPrbL1Sp=${maxNumLayerPrbL1Sp}

    ${path_in_xml}=  vendor_file_modifier.get_xml_path_for_list  listname=bbL1SpPrbInitCapacity
    vendor_file_modifier.modify_vendor_file
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${LOG_PATH}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${LOG_PATH}/vendor_lte.xml
    ...  xml_path=${path_in_xml}

    ${filter_criteria}=    Create Dictionary
    ...  xEc=20

    ${data_to_be_modified}=    Create Dictionary
    ...  xEc=14


    ${path_in_xml}=  vendor_file_modifier.get_xml_path_for_xec
    vendor_file_modifier.modify_vendor_file
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${OUTPUT_DIR}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${OUTPUT_DIR}/vendor_lte.xml
    ...  xml_path=${path_in_xml}

Verify Max PRB for Emf And Ue
    Convert pcap file to pdml    tshark_filters=${tshark_filter}
    verify_PRB_for_subcellid    pdml_path=${OUTPUT_DIR}/BIP_log_1.pdml    subcellid=0
    ...    num_prb=273    bip_mesg=nr_l1dl_l2ps_dldata_pdschsendreql1sw_t
    verify_PRB_for_subcellid    pdml_path=${OUTPUT_DIR}/BIP_log_1.pdml    subcellid=10
    ...    num_prb=48    bip_mesg=nr_l1dl_l2ps_dldata_pdschsendreql1sw_t
