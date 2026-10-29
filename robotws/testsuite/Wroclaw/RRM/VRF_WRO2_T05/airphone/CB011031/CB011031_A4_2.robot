
*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           PY311    CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :author: Joachim Otto
...              :contact: joachim.otto@nokia.com

Resource     CB011031_Keywords_And_Variables.robot

Suite Setup       Run Keywords       Start Default Logging         output_dirpath=${OUTPUT_DIR}/suite_setup_logs
...               AND                Start Multiple Vms Interfaces
...               AND                Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND                Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/iphy.xml
...               AND                Update Iphy Configuration And Modify Swconfig
...                                  iphy_xml_filepath=${CURDIR}/config/inter_iphy.xml
...               AND                Find Scfc And Fix And Send Full Commissioning
...                                  scfc_filename=scfc_inter_freq.xml
...               AND                Check Radios Availability
...               AND                Reach Onair    lua_cfg=${CURDIR}/config/egate_CB011031_inter_freq.lua
...               AND                Stop Default Logging     output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs


*** Test Cases ***
CB011031_A4_2_Inter_Frequency_HO_Between_5G_Cells_With_Different_SSB_Positions
    [Documentation]    This test case describes gNB behaviour during inter frequency HO between 5G cells
    ...                which are having different SSB position in time domain.
    ...                UE supports 40MHz bandwidth on band n48
    ...                actBeamforming is set to False
    ...                Only Single SSB could be configured to the 2nd symbol in slot 1
    ...                Automatic location of SSB ( gscnOrSsPbchArfcn=0,1,2)
    ...                5G Cells are configured with FR1-TDD BW 40MHz: NRCELL.chBw =40MHz, SCS - 30 KHz
    ...                Cell B has configuration with shifted SSB: NRCELL.ssbPositionsInBurst= (slot 1, symbol 2)
    ...                5G_RAN_USR_RRM_22644

    [Setup]    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_add_ssbPositionsInBurst_inter_freq.json
    Attach Ue    ue_id=1
    Establish PDU Session With Traffic    ue_id=1    pdu_id=1    gw_id=1
    Send Ue Measurement Nr Event A2 Handover With Aligned Meas Id    ue_id=1    pcell_id=1    cell_type=SA    phycell_id=51    srsrp_nr=17
    ...                                                              pass_regexp=ServingCellMO is not present in CellGroupConfig
    Sleep    8s    reason=Delay between sending measurements
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=1    phycell_id=51    carrier_freq=632352    srsrp_nr=17    trigger_type=RSRP
    ...                                                     timeout=5    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Sleep    8s    reason=Delay between sending measurements
    Send Ue Measurement Nr Event A2 Handover With Aligned Meas Id    ue_id=1    pcell_id=2    cell_type=SA    srsrp_nr=30    phycell_id=50
    ...                                                              srsrp_nr=17    pass_regexp=ServingCellMO is not present in CellGroupConfig
    Sleep    8s    reason=Delay between sending measurements
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=1    phycell_id=50    carrier_freq=636672    srsrp_nr=17    trigger_type=RSRP
    ...                                                     timeout=5    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    Verify Tcpdump Log    packet_filter=${SIB1_SSBPOSITIONS_DEFAULT_INTER_FREQ}
    Verify Tcpdump Log    packet_filter=${SIB1_SSBPOSITIONS_ON_INTER_FREQ}    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${SIB2_SSBPOSITIONS_ON_INTER_FREQ}    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${SSBPOSITIONS_CELL_50_A2}
    Verify Tcpdump Log    packet_filter=${SSBPOSITIONS_CELL_50_A5}
    Verify Tcpdump Log    packet_filter=${SSBPOSITIONS_CELL_51_A2}
    Verify Tcpdump Log    packet_filter=${SSBPOSITIONS_CELL_51_A5}

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=1
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_add_ssbPositionsInBurst_inter_freq.json
    ...           AND             Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
