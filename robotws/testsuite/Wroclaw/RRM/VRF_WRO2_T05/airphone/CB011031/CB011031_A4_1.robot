*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           PY311    CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :author: Dominik Borkowski
...              :contact: dominik.borkowski@nokia.com

Resource    CB011031_Keywords_And_Variables.robot

Suite Setup       Run Keywords       Start Default Logging         output_dirpath=${OUTPUT_DIR}/suite_setup_logs
...               AND                Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND                Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/iphy.xml
...               AND                Start Multiple Vms Interfaces
...               AND                Update Iphy Configuration And Modify Swconfig
...                                  iphy_xml_filepath=${CURDIR}/config/iphy_intra.xml
...               AND                Find Scfc And Fix And Send Full Commissioning
...                                  scfc_filename=scfc_intra_freq.xml
...               AND                Check Radios Availability
...               AND                Reach Onair    lua_cfg=${CURDIR}/config/egate_CB011031_intra_freq.lua
...               AND                Stop Default Logging     output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

*** Test Cases ***
CB011031_A4_1_Intra_Frequency_HO_Between_5G_Cells_With_Different_SSB_Positions
    [Documentation]    This test case describes gNB behaviour during intra frequency HO between 5G cells
    ...                which are having different SSB position in time domain.
    ...                UE supports 40MHz bandwidth on band n78
    ...                actBeamforming is set to False
    ...                Only Single SSB could be configured to the 2nd symbol in slot 1
    ...                Automatic location of SSB ( gscnOrSsPbchArfcn=0,1,2)
    ...                5G Cells are configured with FR1-TDD BW 40MHz: NRCELL.chBw =40MHz, SCS - 30 KHz
    ...                Cell B has configuration with shifted SSB: NRCELL.ssbPositionsInBurst= (slot 1, symbol 2)
    ...                5G_RAN_USR_RRM_22644

    [Setup]    Run Keywords    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    test_name=${TEST_NAME}
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_add_ssbPositionsInBurst.json
    ...        AND             Attach Ue    ue_id=1
    ...        AND             Establish PDU Session With Traffic    ue_id=1    pdu_id=1    gw_id=1
    Send Ue Measurement Nr Event A5 With Aligned Meas Id
    ...                              ue_id=1    srsrp_nr=19    carrier_freq=635328    phycell_id=51    nrsrp_nr=68
    ...                              pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Sleep                            5s    reason=Delay between sending measurements
    Send Ue Measurement Nr Event A5 With Aligned Meas Id
    ...                              ue_id=1    srsrp_nr=19    carrier_freq=635328    phycell_id=50    nrsrp_nr=68
    ...                              pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    Verify Tcpdump Log               packet_filter=${SIB1_SSBPOSITIONS_DEFAULT}
    Verify Tcpdump Log               packet_filter=${SIB1_SSBPOSITIONS_ON}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log               packet_filter=${SIB2_SSBPOSITIONS_ON}    number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log               packet_filter=${SSBPOSITIONS_CELL_50}
    Verify Tcpdump Log               packet_filter=${SSBPOSITIONS_CELL_51}
    Verify Existing NRREL

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=1
    ...           AND             Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
