*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    CRT
...           SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Dariusz Maciocha
...              :contact: dariusz.maciocha@nokia.com

Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T06/CB008490/resources/feature_keywords.robot
Library      ta5g_testline_management
Library      ta5g_enb
Library      ta5g_iphy
Library      ta5g_throughput
Library      ta5g_ue_measurements
Library      ta5g_tshark
Library      ta5g_pm_counters
Library      testsuite/Wroclaw/RRM/resources/scout_report.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/airphone/resources/keywords.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/DeltaFixer.py
Library      testsuite/Wroclaw/RRM/resources/syslog_checker.py
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/airphone/CB014151/resources/test_variables.py

Suite Setup      Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
Test Teardown    Run Keywords     Add Scout Scf Id To Test Data
...         AND                   Stop Default Processes And Gather Logs    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...         AND                   Run Keyword If Test Passed    Find Suspicious Logs

*** Test Cases ***
CB014151-A_B1_Feature_Activation_with_Migration_Veryfication
    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy.xml
    ...    AND    Activate CA SDL Feature
    ...    AND    Trigger Site Reset
    ...    AND    Check Radios Availability
    ...    AND    Reach Onair    lua_cfg=${CURDIR}/config/cfg.lua    mplane_cells=4
    ...    AND    Execute egate command    cmd=enb_x2_link_up enb=1 target=2    pass_regexp=ENB-1: X2AP Link with GNB-2.*is up
    ...    AND    Wait For Next Full Pm Interval
    ...    AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Execute Egate Command    cmd=ue_enb_endc_param id=1,2,3 serving_cell_index_range_scg=1:8
    Attach Ue To Enb    ue_id=1
    Start Gnb Addition Procedure    target_cells=3    bearer=1    dc_type=split_scg    timeout=10
    Attach Ue To Enb    ue_id=2
    Start Gnb Addition Procedure    ue=2    target_cells=1,3    bearer=1    dc_type=split_scg    timeout=10
    ${delta}=    Create List    ca_Fdd_Fdd    ca_Fr1Tdd_Fdd_Nsa    ca_Fdd_Sdl_Nsa
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRDU-1    parameter=carrierAggregationSupportList  value=${delta}
    Attach Ue To Enb    ue_id=3
    Start Gnb Addition Procedure    ue=3    target_cells=1,3    bearer=1    dc_type=split_scg    timeout=10
    Verify Message Flow    ${CB014151_FLOW}
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Verify Syslog For Correct Prints    ${OUTPUT_DIR}/${TEST_NAME}    ${SYSLOG_ALGORITHM_PSCELL}

CB014151-B_B2_A1_Measurement_triggered_buffer_based_Scell_addition
    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_buffer_based_with_measurement.xml
    ...    AND    Find Scfc And Fix And Send Full Commissioning    scfc_filename=scf_buffer_based_with_measurement.xml
    ...    AND    Check Radios Availability
    ...    AND    Reach Onair    lua_cfg=${CURDIR}/config/cfg_buffer_based_with_measurement.lua    mplane_cells=2
    ...    AND    Execute egate command    cmd=enb_x2_link_up enb=1 target=2    pass_regexp=ENB-1: X2AP Link with GNB-2.*is up
    ...    AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Execute Egate Command    cmd=ue_enb_endc_param id=1 serving_cell_index_range_scg=1:8
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Attach Ue To Enb    ue_id=1
    Start Gnb Addition Procedure    target_cells=1    bearer=1    dc_type=split_scg    timeout=10
    ...    pass_regexp=SgNB Modification is successful
    Sleep    2s
    Execute Egate Command    cmd=ue_send_measurement_nr id=1 meas_id=3 event=A1 phycell_id=52 srsrp_nr=61
    Sleep    5s
    Start Data Traffic    ues=1    direction=dl    bearer_id=1    throughput=150Mbps    traffic_period=10
    Verify Message Flow    ${CB014151_BUFFER_BASED_FLOW}

*** Keywords ***
Verify PM Counters
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55118C02000    1      RRC_RECONF_1_SCELL_DL_ATT
        ...    M55118C03000    1      RRC_RECONF_1_SCELL_DL_SUCC
        ...    M55118C04000    >0     UE_PSCELL_1_CONF_SCELL_DL
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
        ...    file_path=${pm_counter_file}
    Verify Any Counters In File
        ...    M55118C05000    >0     UE_SCELL_1_CONF_SCELL_DL
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
        ...    file_path=${pm_counter_file}

Tshark Verification
    [Arguments]     ${packet_filter}    ${number_of_messages}=1    ${relation_symbol}= ==
    Verify Tshark
    ...    alias=default_s1_x2
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=default

Verify Message Flow
    [Arguments]    ${messages}
    FOR    ${msg}    IN    @{messages}
        ${length}=    Get Length    ${msg}
        IF    ${length} != 2    Tshark Verification    packet_filter=${msg}
        ...    ELSE    Tshark Verification    packet_filter=${msg}[0]    number_of_messages=${msg}[1]
    END

Activate CA SDL Feature
    ${delta}=    Get Commissioning File For Enb Release Name    delta.json
    Send Delta Commissioning With Fixer    ${delta}
