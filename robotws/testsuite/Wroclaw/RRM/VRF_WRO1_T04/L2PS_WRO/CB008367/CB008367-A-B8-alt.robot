*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00

Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ../CB009086/resources/9086_keywords.robot
Resource    resources/CB008367-A_keywords.robot
Resource    ../CB007813/connect.robot
Library    ../resources/Python/webem_alarms.py
Library    CB008367.py
Library    ../CB007813/CB007813-B_keywords.py
Library    ../CB007813/vendor_file_modifier.py
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_1AEQE_GSCN_7853.xml
    ...                        swconfig_flags_list=@{SWCONFIG_FLAGS}
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB008367_A_B8_alt.xml
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_A_B8.cfg
    ...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...    AND    Send Configuration ID To Scout

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=      0x5808FF=2
# 0x580900-5 and 0x5808FF=1 - flags related to CB008367 events visibility in TTI Trace

${search_space_id_large} =          8
${search_space_id_small} =            13
${search_space_id_ps} =          18

*** Test Cases ***
CB008367-A_B8_multi-UE_tput_large-BWP_multi-UE_tput_small-BWP_and_multi-UE_tput_PS-BWP_starting_PRB_0_0_0
    Attach And Pdu Session For Ues
    ...    ues=${68}
    ...    pass_regex=Bwp switch received from bwpId 1 to 2

    Start 1 Mbps Uplink Traffic For UEs 1-2
    Start Downlink Traffic 1 Mbps For UEs 1-2

    Start Uplink Traffic With Period For UEs 3-16
    Start Downlink Traffic 30 Mbps For UEs 3-16

    Start 5 kbps Uplink Traffic For UEs 17-68
    Start Downlink Traffic 500 kbps For UEs 17-68

    Sleep    5s
    Display Actual Traffic For UEs 1-68
    Start TTI trace
    Sleep    1s
    Stop TTI trace
    Convert TTI trace from pcap to excelCsv

    CB008367.Check Pdsch Correctness For Large Small Ps A B8    csv_path=${OUTPUT_DIR}/${SUITENAME}/${TESTNAME}/
    ...    filename=output_dl.csv
    ...    search_space_id_large=${search_space_id_large}
    ...    search_space_id_small=${search_space_id_small}
    ...    search_space_id_ps=${search_space_id_ps}
    ...    pdcch_start_symbol_large=17
    ...    pdcch_start_symbol_small=17
    ...    pdcch_start_symbol_ps=17

    Deregister 68 UEs
