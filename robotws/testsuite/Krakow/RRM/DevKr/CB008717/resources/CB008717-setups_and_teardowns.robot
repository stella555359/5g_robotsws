*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Adrianna Zenczak <adrianna.zenczak@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

*** Variables ***

*** Keywords ***
Prepare test environment I-B1a
    Log to console    Prepare test environment I-B1a
    Configure    ${yaml_I_B1a}
    discover bts   bts_id=1
    Verify state of SA and NRDCSN cells

Cleanup after test I-B1a
    Log to console    Cleanup after test I-B1a
    Detach and kill UE1
    Detach and kill UE8

Prepare test environment I-B1b
    Log to console    Prepare test environment I-B1b
    Configure    ${yaml_I_B1b}
    discover bts   bts_id=1
    Verify state of SA and two NRDCSN cells

Cleanup after test I-B1b
    Log to console    Cleanup after test I-B1b
    Detach and kill UE4

Prepare test environment I-B1c I-B1f
    Log to console    Prepare test environment I-B1c, I-B1f - with CFRA
    Configure    ${yaml_I_B1c}
    # When cbraPreamblesPerSsb is smaller than totalNumberOfRAPreambles then CFRA is present
    discover bts   bts_id=1
    Verify state of SA and NRDCSN cells

Cleanup after test I-B1c
    Log to console    Cleanup after test I-B1c
    Detach and kill UE1

Cleanup after test I-B1f
    Log to console    Cleanup after test I-B1f
    Detach and kill UE9

Prepare test environment I-B1d
    Log to console    Prepare test environment I-B1d - with DRX
    Configure    ${yaml_I_B1d}
    discover bts   bts_id=1
    Verify state of SA and NRDCSN cells

Cleanup after test I-B1d
    Log to console    Cleanup after test I-B1d
    Detach and kill UE10
    Detach and kill UE11
    Configure  {'MOC': 'NRCELL', 'ID': '1', 'actCDrx': 'false'}

Prepare test environment I-B1e
    Log to console    Prepare test environment I-B1e
    Configure    ${yaml_I_B1c}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'timerRRCGuard': '6000'}
    discover bts   bts_id=1
    Verify state of SA and NRDCSN cells

Prepare test environment I-B1e-fail
    Log to console    Prepare test environment I-B1e-fail
    Configure    ${yaml_I_B1c}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'timerRRCGuard': '2500'}
    discover bts   bts_id=1
    Verify state of SA and NRDCSN cells

Cleanup after test I-B1e
    Log to console    Cleanup after test I-B1e
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'timerRRCGuard': '2500'}
    Detach and kill UE12
    Detach and kill UE13

Prepare test environment I-B1i
    Log to console    Prepare test environment I-B1i
    Configure    ${yaml_I_B2}
    discover bts   bts_id=1
    Verify state of SA and two NRDCSN cells

Cleanup after test I-B1i
    Log to console    Cleanup after test I-B1i
    Detach and kill UE2

Prepare test environment I-B2a
    Log to console    Prepare test environment I-B2a
    Configure    ${yaml_I_B2}
    discover bts   bts_id=1
    Verify state of SA and two NRDCSN cells

Cleanup after test I-B2a
    Log to console    Cleanup after test I-B2a
    Detach and kill UE5

Prepare test environment I-B2b
    Log to console    Prepare test environment I-B2b
    Configure    ${yaml_I_B2}
    Configure    {'MOC': 'NRREL', 'ID': '1-2', 'nrDcAllowed': 'true'}
    discover bts   bts_id=1
    Verify state of SA and two NRDCSN cells

Cleanup after test I-B2b
    Log to console    Cleanup after test I-B2b
    Detach and kill UE6

Prepare test environment I-B2c
    Log to console    Prepare test environment I-B2c
    Configure    ${yaml_I_B2}
    discover bts   bts_id=1
    Verify state of SA and two NRDCSN cells
    Start observing measurements  UE_7  technology=5G

Cleanup after test I-B2c
    Log to console    Cleanup after test I-B2c
    Detach and kill UE7
    Stop observing measurements  UE_7

Prepare test environment I-B2b-NSA
    Log to console    Prepare test environment I-B2b-NSA
    Configure    ${yaml_I_B2}
    discover bts   bts_id=1
    Verify state of two SA, NRDCSN and NSA cells

Cleanup after test I-B2b-NSA
    Log to console    Cleanup after test I-B2b
    Detach and kill UE6

Prepare test environment B_B1a
    Configure       ${yaml_B1a}
    Verify state of SA and NRDCSN cells
    discover bts   bts_id=1
    Log To Console    Start of the test C-B1a
    #Wait for new PM Counter collecting period

Cleanup after test C_B1a
    Log To Console    End of the test C-B1a
    Detach and kill UE1
    Detach and kill UE2

Prepare test environment D-B1a
    Wait Until Keyword Succeeds  2 min   5 sec  Check SA cell state for NRCELL: 2 and NRDCSN cell state for NRCELL: 1
    discover bts   bts_id=1

Prepare test environment D-B1b
    Log to console    Prepare test environment D-B1b
    Configure    ${yaml_D_B1b}
    Configure    {'MOC': 'NRBTS', 'rejectSuppBcs': 'none', 'actBcsCheck': 'enabled_NRDC'}
    discover bts   bts_id=1
    Verify state of SA and NRDCSN cells
    #Wait for new PM Counter collecting period
    start_observing_measurements      UE_3       technology=5G

Prepare test environment D-B1c
    Wait Until Keyword Succeeds  3 min   5 sec  Check SA cell state for NRCELL: 2 and NRDCSN cell state for NRCELL: 1,3

Cleanup after test D-B1c
    Detach and kill UE1

Prepare test environment D-B3a
    Verify state of SA and NRDCSN cells

Prepare test environment D-B5a
    Log to console    Prepare test environment D-B5a
    Prepare test environment D-B1c

Prepare test environment HA-B1a_B1c
    Log to console    Prepare test environment HA-B1a_B1c
    Prepare test environment D-B1c
    Start observing measurements  UE_1  technology=5G

Prepare test environment HA-B1d-1
    Log to console    Prepare test environment HA-B1d-1
    Prepare test environment D-B1c

Prepare test environment HA-B1f
    Log to console    Prepare test environment HA-B1f
    Prepare test environment D-B1c
    Start observing measurements  UE_1  technology=5G

Prepare test environment HA-B1d-2
    Log to console    Prepare test environment HA-B1d-2
    Prepare test environment D-B1c
    start_observing_measurements      UE_1       technology=5G

Prepare test environment E-B1a
    Prepare test environment D-B1c
    Execute egate command   cmd=amf_param release_old_ue_context=on id=1
    start_observing_measurements      UE_1       technology=5G

Prepare test environment E-B1b
    Prepare test environment D-B1c
    ${yaml_paths_to_configure}      Create List
    append to list     ${yaml_paths_to_configure}     ${yaml_E-B1b}    ${yaml_rd_counters}
    Configure    ${yaml_paths_to_configure}  node_id=1
    start_observing_measurements      UE_1       technology=5G

Prepare test environment E-B2-1
    Prepare test environment D-B1c
    Set UE IDLE timers on gNB: drbInactivityTimerSA=10 srbInactivityTimerSA=10

Prepare test environment E-B2-2
    Prepare test environment D-B1c
    Configure    ${yaml_E_B2_2}
    Set UE IDLE timers on gNB: drbInactivityTimerSA=10 srbInactivityTimerSA=10

Prepare test environment E-B2b-1
    Prepare test environment D-B1c
    Set UE IDLE timers on gNB: drbInactivityTimerSA=10 srbInactivityTimerSA=10
    Configure    {'MOC': 'NRBTS', 'ID': '1', 'timerNGSignalingConnGuard': '2500'}

Prepare test environment D-B6a
    Configure    {'MOC': 'NRCELL', 'ID': '1', 'maxNumOfNrDcSnUsers': '0', 'maxNumOfSCellAlloc': '0'}
    Configure    {'MOC': 'NRCELL', 'ID': '3', 'maxNumOfNrDcSnUsers': '0', 'maxNumOfSCellAlloc': '0'}
    Log to console    Prepare test environment D-B6a

Prepare test environment D-EC5b
    Configure    ${yaml_D_EC5b}
    Log to console    Prepare test environment D-EC5b

Prepare test environment E-B7
    Prepare test environment D-B1c

Prepare test environment E-B9a
    Log to console    Prepare test environment E-B9a

Prepare test environment E-B9c
    Log to console    Prepare test environment E-B9c

Cleanup after test B-B1b
    Detach and kill UE5
    Detach and kill UE6

Cleanup after test D-B1a
    Log to console    Cleanup after test D-B1a
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3

Cleanup after test D-B1b
    Log to console    Cleanup after test D-B1b
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Detach and kill UE6
    Detach and kill UE7
    Detach and kill UE8
    Configure    {'MOC': 'NRBTS', 'rejectSuppBcs': 'none', 'actBcsCheck': 'enabled_NRDC'}

Cleanup after test D-B3a
    Detach and kill UE4
    Detach and kill UE5

Cleanup after test D-B4a_B4b_B4c
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE4
    Detach and kill UE5
    Configure    ${yaml_D_B4c_default}

Cleanup after test D-B5a
    Log to console    Cleanup after test D-B5a
    Reset QoS Flow settings on SMF
    Detach and kill UE1
    Exclude UECaps from ICS for UE1
    Detach and kill UE2
    Exclude UECaps from ICS for UE2
    Detach and kill UE3
    Exclude UECaps from ICS for UE3

Cleanup after test HA-B1a_B1c
    Log to console    Cleanup after test HA-B1a_B1c
    Reset QoS Flow settings on SMF
    Detach and kill UE1
    Exclude UECaps from ICS for UE1

Cleanup after test HA-B1f
    Log to console    Cleanup after test HA-B1f
    Reset QoS Flow settings on SMF
    Detach and kill UE1

Cleanup after test HA-B1d-1
    Log to console    Cleanup after test HA-B1d-1
    Reset QoS Flow settings on SMF
    Detach and kill UE1
    Exclude UECaps from ICS for UE1
    Detach and kill UE2
    Exclude UECaps from ICS for UE2

Cleanup after test HA-B1d-2
    Log to console    Cleanup after test HA-B1d-2
    Configure    ${yaml_HA_B1d_dafault}
    Sleep    2
    Reset QoS Flow settings on SMF
    Detach and kill UE1
    Exclude UECaps from ICS for UE1

Cleanup after test D-B6a
    Configure    {'MOC': 'NRCELL', 'ID': '1', 'maxNumOfNrDcSnUsers': '275', 'maxNumOfSCellAlloc': '250'}
    Configure    {'MOC': 'NRCELL', 'ID': '3', 'maxNumOfNrDcSnUsers': '275', 'maxNumOfSCellAlloc': '250'}
    Detach and kill UE1

Cleanup after test D-EC5b
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Detach and kill UE4
    Configure    ${yaml_D_EC5b_default}

Cleanup after test E-B1a
    Stop observing measurements  UE_1
    Detach and kill UE1
    Detach and kill UE2
    Execute egate command   cmd=amf_param release_old_ue_context=off id=1

Cleanup after test E-B1b
    Detach and kill UE1

Cleanup after test E-B2-1
    Detach and kill UE1

Cleanup after test E-B2-2
    Detach and kill UE1
    Detach and kill UE2

Cleanup after test E-B4
    Detach and kill UE1
    Execute egate command   cmd=ue_testmode_set_nr id=1 testmode=rlf action=deactivate profile_id=1

Cleanup after test E-B9a
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3

Cleanup after test E-B9c
    Cleanup after test E-B9a

Prepare test environment D-B4a_B4b_B4c
    Configure    ${yaml_D_B4a}
    Prepare test environment D-B1c

Prepare test environment D_B4d
    Configure    ${yaml_D_B4d}
    Wait Until Keyword Succeeds  2 min   5 sec  Check SA cell state for NRCELL: 2 and NRDCSN cell state for NRCELL: 1

Cleanup after test D-B4d
    Log to console    Cleanup after test D-B4d
    Reset QoS Flow settings on SMF
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3

Prepare test environment E-B4a
    Wait Until Keyword Succeeds  5 min   20 sec   Prepare test environment D-B1c
    Configure       {'MOC': 'NRBTS', 'ID': '1', 'actGnbInitRlf': 'true', 'tWaitingRlRecoverSA': '500ms'}
    #Wait for new PM Counter collecting period

Prepare test environment E-B3a
    Log to console    Prepare test environment E-B3a
    Configure    ${yaml_E_B3a}
    discover bts   bts_id=1
    Prepare test environment D-B1c

Cleanup after test E-B3a
    Log to console    Cleanup after test E-B3a
    Detach and kill UE1
    Detach and kill UE2

Prepare test environment E-B3b
    Log to console    Prepare test environment E-B3b
    Configure    ${yaml_E_B3b}
    discover bts   bts_id=1
    Prepare test environment D-B1c

Cleanup after test E-B3b
    Log to console    Cleanup after test E-B3b
    Detach and kill UE2
    Detach and kill UE3

Prepare test environment E-B10
    Log to console    Prepare test environment E-B10
    Configure    ${yaml_E_B10}
    discover bts   bts_id=1
    Create AMF device with alias 'AMF2' identified by ip=10.0.1.11
    Create AMF device with alias 'AMF3' identified by ip=10.0.1.12
    Prepare test environment D-B1c
    Log To Console  Start test case E-B10
    #Wait for new PM Counter collecting period

Cleanup after test E-B10
    Log to console    Cleanup after test E-B10
    Detach and kill UE1
    Unlock NG-C link to AMF2
    Unlock NG-C link to AMF1

Prepare test environment D-EC5a-1
    Log to console    Prepare test environment D-EC5a-1
    ${yaml_paths_to_configure}      Create List
    append to list     ${yaml_paths_to_configure}     ${yaml_D_EC5a_1}    ${yaml_rd_counters}
    Configure    ${yaml_paths_to_configure}  node_id=1
    discover bts   bts_id=1
    Start observing measurements  UE_1  technology=5G

Cleanup after test D-EC5a-1
    Configure    ${yaml_D_EC5a_1_default}
    Reset QoS Flow settings on SMF
    Detach and kill UE1

Prepare test environment D-EC5a-2
    Log to console    Prepare test environment D-EC5a-2
    Configure    ${yaml_D_EC5a_2}
    discover bts   bts_id=1
    Start observing measurements  UE_2  technology=5G

Cleanup after test D-EC5a-2
    Configure    ${yaml_D_EC5a_2_default}
    Detach and kill UE2

Prepare test environment D-EC6a
    Log to console    Prepare test environment D-EC6a
    Prepare test environment D-B1c
    Configure    ${yaml_rd_counters}
    Configure    {'MOC': 'NRDU', 'ID': '1', 'maxNumOfRrcConUEsPerDU': '5'}
    discover bts   bts_id=1
    Start observing measurements  UE_3  technology=5G

Cleanup after test D-EC6a
    Configure    {'MOC': 'NRDU', 'ID': '1', 'maxNumOfRrcConUEsPerDU': '26928'}
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3

Prepare test environment E-B6a
    Log to console    Prepare test environment E-B6a
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'keyRefrMarg': '4294967295'}
    discover bts   bts_id=1

Cleanup after test E-B6a
    Log to console    Cleanup after test E-B6a
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'keyRefrMarg': '4294967295'}
    Detach and kill UE1

Prepare test environment E-EC2
    Log to console    Prepare test environment E-EC2
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'timerRRCGuard': '1000'}
    discover bts   bts_id=1

Cleanup after test E-EC2
    Log to console    Cleanup after test E-EC2
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'timerRRCGuard': '6000'}
    Set delay RRCReconfigurationComplete by 0ms for UE1
    Detach and kill UE1

Prepare test environment for XN HOs
    Log to console    Prepare test environment for XN HOs
    Wait Until Keyword Succeeds  2 min   5 sec  Check SA cell state for NRCELL: 1,2,4,5 and NRDCSN cell state for NRCELL: 3,6
    Object attributes should be    XNLINK-2    xnLinkStatus=available

    Execute egate command
    ...    cmd=gnb_param measEvent=A3 id=3

    Configure ue_history for UE1 to enable handovers from gNB3
    Configure ue_history for UE2 to enable handovers from gNB3

Cleanup after test DE-PM2_1
    Clear UE3 from ignore RRCReconfiguration
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Detach and kill UE4
    Detach and kill UE5

Prepare test environment for NG HOs
    Log to console    Prepare test environment for NG HOs
    Configure    ${yaml_DE_NG_HO}
    Execute egate command
    ...    cmd=gnb_param measEvent=A3 sa_ho=ng_based id=3

    Configure ue_history for UE1 to enable handovers from gNB3
    Configure ue_history for UE2 to enable handovers from gNB3
    Configure ue_history for UE6 to enable handovers from gNB3
    Configure ue_history for UE7 to enable handovers from gNB3

    Execute egate command   cmd=amf_param id=1 intra5gs_data_forwarding=off

    Start observing measurements  UE_8  technology=5G
    Start observing measurements  UE_9  technology=5G

    Set UE8 InterRAT insufficient NRDC capability in ue_param
    Set UE9 InterRAT insufficient NRDC capability in ue_param

Cleanup after test DE-PM2_2
    Execute egate command
    ...    cmd=gnb_param measEvent=A3 sa_ho=xn_based id=3

    Set UE8 InterRAT insufficient NRDC capability in ue_param
    Set UE9 InterRAT insufficient NRDC capability in ue_param

    Stop observing measurements  UE_8
    Stop observing measurements  UE_9

    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE6
    Detach and kill UE7
    Detach and kill UE8
    Detach and kill UE9

    Configure    {'MOC': 'NRBTS', 'ID': '1', 'actInterRatHoFromEutraToSA': 'false', 'actInterRatHoSA': 'false'}

Prepare test environment DE-PM3-3
    Configure    ${yaml_rd_counters}
    discover bts   bts_id=1
    Log To Console    Start of the test DE-PM3-3
    Set UE IDLE timers on gNB: drbInactivityTimerSA=10 srbInactivityTimerSA=10
    #Wait for new PM Counter collecting period

Prepare test environment DE-exploratory
    ${yaml_paths_to_configure}      Create List
    append to list     ${yaml_paths_to_configure}     ${interaction_with_CB008225}    ${yaml_rd_counters}
    Configure    ${yaml_paths_to_configure}  node_id=1
    discover bts   bts_id=1
    Log To Console    Start of the test DE-exploratory
    Set UE IDLE timers on gNB: drbInactivityTimerSA=10 srbInactivityTimerSA=10
    #Wait for new PM Counter collecting period
    ${command_amf}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=yes ue_identity_index_value=1
    ...                       ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute egate command
    ...     cmd=${command_amf}

Cleanup after test DE-PM3-3
    Detach and kill UE1
    Detach and kill UE2
    Execute egate command    cmd=amf_ue_ctx_release_param id=1 ue=1 reset

Cleanup after test DE-exploratory
    Detach and kill UE1

Enable InterRAT HO configuration on gNB
    Configure   ${yaml_DE_InterRAT_HO}
    Configure   ${yaml_DE_IDs_for_InterRAT_MOCs}

Prepare test environment for inter RAT handover
    Configure   ${yaml_M_InterRAT_HO}
    Configure  {'MOC': 'NRCELL', 'ID': '2', 'actCDrx': 'false'}
    Start observing measurements  UE_1  technology=5G
    Start observing measurements  UE_2  technology=5G
    Start observing measurements  UE_3  technology=5G
    Start observing measurements  UE_8  technology=5G
    Start observing measurements  UE_9  technology=5G

Prepare test environment DE-PM1-4
    Log to console    Prepare test environment DE-PM1-4
    Configure    ${yaml_rd_counters}
    discover bts   bts_id=1

Cleanup after test DE-PM1-4
    Log to console    Cleanup after test DE-PM1-4
    Detach and kill UE1

Prepare test environment DE-PM1-3
    Log to console    Prepare test environment DE-PM1-3
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'timerRRCGuard': '1000'}
    Configure    ${yaml_rd_counters}
    Start observing measurements  UE_1  technology=5G
    Start observing measurements  UE_2  technology=5G
    discover bts   bts_id=1

Cleanup after test DE-PM1-3
    Log to console    Cleanup after test DE-PM1-4
    Execute egate command    cmd=ue_nr_rrc_reconf_param id=2 reset
    Detach and kill UE1
    Detach and kill UE2

Check SA cell state for NRCELL: ${sa_cells} and NRDCSN cell state for NRCELL: ${nrdcsn_cells}
    @{sa_cell_ids}=    Split String    ${sa_cells}    ,
    FOR    ${cell}    IN    @{sa_cell_ids}
        Log to console     \nChecking state for NRCELL-${cell}
        Object attributes should be    NRCELL-${cell}    cellDepType=SA
        Object attributes should be    NRCELL-${cell}    operationalState=enabled
    END
    @{nrdcsn_cell_ids}=    Split String    ${nrdcsn_cells}    ,
    FOR    ${cell}    IN    @{nrdcsn_cell_ids}
        Log to console     \nChecking state for NRCELL-${cell}
        Object attributes should be    NRCELL-${cell}    cellDepType=NR-DC-SN
        Object attributes should be    NRCELL-${cell}    operationalState=enabled
    END

Prepare test environment for M-B2-B11
    Log to console    Prepare test environment for M-B2-B11
    Wait Until Keyword Succeeds  5 min   5 sec  Check SA cell state for NRCELL: 1,2,4,5 and NRDCSN cell state for NRCELL: 3,6

    Configure   ${yaml_M_InterRAT_HO}

    Start observing measurements  UE_1  technology=5G
    Start observing measurements  UE_3  technology=5G
    Start observing measurements  UE_5  technology=5G
    Start observing measurements  UE_6  technology=5G
    Start observing measurements  UE_9  technology=5G

    start collecting syslog       prefix=CB008717-M-B2-B11

Prepare test environment for JA-B1abc-B2ab
    Log to console    Prepare test environment for JA-B1abc-B2ab
    ${config}    Catenate    [{'MOC': 'NRCELL', 'ID': '1', 'actCDrx': 'false'},
    ...                       {'MOC': 'NRCELL', 'ID': '2', 'actCDrx': 'false'},
    ...                       {'MOC': 'NRBTS', 'ID': '1', 'rrcReestabTypeSA': 'sameGNB'},
    ...                       {'MOC': 'NRBTS', 'ID': '1', 'actPucchF3BasedTaGrantsRed': 'false'}]
    Configure    ${config}
    Sleep  10
    Wait Until Keyword Succeeds  2 min   5 sec  Check SA cell state for NRCELL: 1,2,4,5 and NRDCSN cell state for NRCELL: 3,6
    Start observing measurements  UE_1  technology=5G
    Start observing measurements  UE_2  technology=5G
    Start observing measurements  UE_3  technology=5G
    Start observing measurements  UE_4  technology=5G
    Start observing measurements  UE_5  technology=5G

Cleanup after test M-B2-B11
    Log to console    Cleanup test environment for M-B2-B11
    Detach and kill UE1
    Detach and kill UE3
    Detach and kill UE5
    Detach and kill UE6
    Detach and kill UE9

    stop collecting syslog

Cleanup after test JA-B1abc-B2ab
    Log to console    Cleanup test environment for JA-B1abc-B2ab
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Detach and kill UE4
    Detach and kill UE5

Cleanup after test M-B8-B9-B12-EC1
    Log to console    Cleanup test environment for M-B8-B9-B12-EC1
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Detach and kill UE8
    Detach and kill UE9

Prepare test environment for M-B4-B5-B12
    Log to console    Prepare test environment for M-B4-B5-B12
    Wait Until Keyword Succeeds  5 min   5 sec  Check SA cell state for NRCELL: 1,2,4,5 and NRDCSN cell state for NRCELL: 3,6
    Object attributes should be    XNLINK-2    xnLinkStatus=available

    Execute egate command
    ...    cmd=gnb_param measEvent=A3 id=3

    Configure   ${yaml_M_InterRAT_HO}

    Start observing measurements  UE_1  technology=5G
    Start observing measurements  UE_2  technology=5G
    Start observing measurements  UE_3  technology=5G
    Start observing measurements  UE_5  technology=5G
    Start observing measurements  UE_6  technology=5G
    Start observing measurements  UE_7  technology=5G

    Configure ue_history for UE1 to enable handovers from gNB3
    Configure ue_history for UE2 to enable handovers from gNB3
    Configure ue_history for UE3 to enable handovers from gNB3
    Configure ue_history for UE5 to enable handovers from gNB3
    Configure ue_history for UE6 to enable handovers from gNB3
    Configure ue_history for UE7 to enable handovers from gNB3

    start collecting syslog       prefix=CB008717-M-B4-B5-B12

Cleanup after test M-B4-B5-B12
    Log to console    Cleanup test environment for M-B4-B5-B12
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Detach and kill UE5
    Detach and kill UE6
    Detach and kill UE7

    stop collecting syslog

Prepare test environment M-B6-B7-B12
    Log to console    Prepare test environment for M-B6
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${yaml_DE_NG_HO}     ${yaml_M_InterRAT_HO}
    Configure    ${yaml_paths_to_configure}  node_id=1
    Configure  {'MOC': 'NRCELL', 'ID': '2', 'actCDrx': 'false'}
    Execute egate command
    ...    cmd=gnb_param measEvent=A3 sa_ho=ng_based id=3

    Configure ue_history for UE1 to enable handovers from gNB3
    Configure ue_history for UE2 to enable handovers from gNB3
    Configure ue_history for UE3 to enable handovers from gNB3
    Configure ue_history for UE4 to enable handovers from gNB3
    Configure ue_history for UE5 to enable handovers from gNB3
    Configure ue_history for UE6 to enable handovers from gNB3
    Execute egate command   cmd=amf_param id=1 intra5gs_data_forwarding=off
    Start observing measurements  UE_1  technology=5G
    Start observing measurements  UE_2  technology=5G
    Start observing measurements  UE_3  technology=5G
    Start observing measurements  UE_4  technology=5G
    Start observing measurements  UE_5  technology=5G
    Start observing measurements  UE_6  technology=5G

    start collecting syslog       prefix=CB008717-M-B6-B7-B12

Cleanup after test M-B6-B7-B12
    Configure  {'MOC': 'NRCELL', 'ID': '2', 'actCDrx': 'false'}
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Detach and kill UE4
    Detach and kill UE5
    Detach and kill UE6

    stop collecting syslog

Prepare test environment for PMQAP counters check
    Configure    ${yaml_PMQAP}
    Configure  {'MOC': 'NRCELL', 'ID': '2', 'actNonVoNRGbrService': 'true'}
    Configure  {'MOC': 'NRCELL', 'ID': '1', 'maxNumOfNrDcSnUsers': '5', 'maxNumOfSCellAlloc' : '5'}
    Start observing measurements  UE_3  technology=5G

Cleanup after test DE-PM2-5
    Log to console    Cleanup after test DE-PM2-5
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Detach and kill UE4
    Detach and kill UE5
    Detach and kill UE6
    Configure  {'MOC': 'NRCELL', 'ID': '1', 'maxNumOfNrDcSnUsers': '275', 'maxNumOfSCellAlloc' : '275'}
    Stop observing measurements  UE_3

Prepare test environment for DE-PM3-5
    Prepare test environment D-B1c
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'timerRRCGuard': '6000'}

Cleanup after test DE-PM3-5
    Log to console    Cleanup after test DE-PM3-5
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'timerRRCGuard': '2500'}

Prepare test environment for HA-B1a-B1b
    Log to console    Prepare test environment for HA-B1a-B1b
    Wait Until Keyword Succeeds  5 min   5 sec  Check SA cell state for NRCELL: 2 and NRDCSN cell state for NRCELL: 1,3

Cleanup after test HA-B1a-B1b
    Log to console    Cleanup test environment for HA-B1a-B1b
    Detach and kill UE1
    Detach and kill UE2

Prepare test environment for M-B15-B16
    Log to console    Prepare test environment for M-B15-B16
    Wait Until Keyword Succeeds  5 min   5 sec  Check SA cell state for NRCELL: 1,2,4,5 and NRDCSN cell state for NRCELL: 3,6
    Object attributes should be    XNLINK-2    xnLinkStatus=available

    Execute egate command
    ...    cmd=gnb_param measEvent=A3 id=3

    Configure    ${yaml_M_InterRAT_HO}
    ${config}    Catenate    [{'MOC': 'NRHOIF', 'ID': '2-1', 'a4MeasNrDcEnabled': 'none'},
    ...                      {'MOC': 'NRHOIF', 'ID': '2-2', 'a4MeasNrDcEnabled': 'none'}]
    Configure    ${config}

    Start observing measurements  UE_5  technology=5G
    Configure ue_history for UE5 to enable handovers from gNB3

    start collecting syslog       prefix=CB008717-M-B15-B16

Cleanup after test M-B15-B16
    Log to console    Cleanup test environment for M-B15-B16
    Detach and kill UE1
    Detach and kill UE5

    stop collecting syslog

Prepare test environment for M-B13-B14
    Wait Until Keyword Succeeds  2 min   5 sec  Check SA cell state for NRCELL: 1,2,4,5 and NRDCSN cell state for NRCELL: 3,6
    Configure   ${yaml_M_InterRAT_HO}

    Start observing measurements  UE_1  technology=5G
    Start observing measurements  UE_2  technology=5G
    Start observing measurements  UE_3  technology=5G

    start collecting syslog       prefix=CB008717-M-B13-B14

Cleanup after test M-B13-B14
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3

    Stop observing measurements  UE_1
    Stop observing measurements  UE_2
    Stop observing measurements  UE_3

    stop collecting syslog

Prepare test environment for HA-B3b
    Log to console    Prepare test environment for HA-B3b
    Wait Until Keyword Succeeds  3 min   5 sec  Check SA cell state for NRCELL: 2 and NRDCSN cell state for NRCELL: 1,3
    start_observing_measurements      UE_1       technology=5G

Cleanup after test HA-B3b
    set indexToRFSP for UE1 to 87 using DL NAS Transport message
    Detach and kill UE1
    Stop observing measurements  UE_1
    stop collecting syslog

Prepare test environment for HA-B3c
    Log to console    Prepare test environment for HA-B3a
    Wait Until Keyword Succeeds  3 min   5 sec  Check SA cell state for NRCELL: 2 and NRDCSN cell state for NRCELL: 1,3
    start_observing_measurements      UE_1       technology=5G
    Create new plan
    Edit Planned Object Attributes   NRBTS-1  timerRRCGuard=5000
    Edit Planned Object Attributes   NRCELL-2  a4PeriodicMeasControlSA.a4RetryTimer[0]=2
    Apply planned changes

Cleanup after test HA-B3c
    Detach and kill UE1
    Stop observing measurements  UE_1
    Set delay RRCReconfigurationComplete by 0ms for UE1
    stop collecting syslog
    Create new plan
    Edit Planned Object Attributes   NRBTS-1  timerRRCGuard=2500
    Edit Planned Object Attributes   NRCELL-2  a4PeriodicMeasControlSA.a4RetryTimer[0]=10
    Apply planned changes

Prepare test environment for JA-B1fgh
    Log to console    Prepare test environment for JA-B1fgh
    Wait Until Keyword Succeeds  5 min   5 sec  Check SA cell state for NRCELL: 1,2,4,5 and NRDCSN cell state for NRCELL: 3,6

    ${config}    Catenate    [{'MOC': 'NRCELL', 'ID': '1', 'actCDrx': 'false'},
    ...                       {'MOC': 'NRCELL', 'ID': '2', 'actCDrx': 'false'},
    ...                       {'MOC': 'NRBTS', 'rrcReestabTypeSA': 'viaRRCSetup'}]
    Configure    ${config}

Cleanup after test JA-B1fgh
    Log to console    Cleanup test environment for JA-B1fgh
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Detach and kill UE4

Prepare test environment for JA-B3a-B3b
    Wait Until Keyword Succeeds  5 min   5 sec  Check SA cell state for NRCELL: 1,2,4,5 and NRDCSN cell state for NRCELL: 3,6
    ${config}    Catenate    [{'MOC': 'NRHOIF', 'ID': '2-1', 'a4MeasNrDcEnabled': 'none'},
    ...                      {'MOC': 'NRHOIF', 'ID': '2-2', 'a4MeasNrDcEnabled': 'none'},
    ...                      {'MOC': 'NRBTS', 'rrcReestabTypeSA': 'sameGNB'}]
    Configure    ${config}
    Configure    ${yaml_M_InterRAT_HO}
    Start observing measurements  UE_1  technology=5G
    Start observing measurements  UE_2  technology=5G

Cleanup after test JA-B3a-B3b
    Detach and kill UE1
    Detach and kill UE2
    Stop observing measurements  UE_1
    Stop observing measurements  UE_2

Prepare test environment for JA-B3c
    Log To Console    Prepare test environment for JA-B3c
    Wait Until Keyword Succeeds  5 min   5 sec  Check SA cell state for NRCELL: 1,2,4,5 and NRDCSN cell state for NRCELL: 3,6
    Object attributes should be    XNLINK-2    xnLinkStatus=available
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${yaml_DE_NG_HO}     ${yaml_M_InterRAT_HO}    ${yaml_JA_B3c}
    Configure    ${yaml_paths_to_configure}  node_id=1
    Start observing measurements  UE_1  technology=5G
    Start observing measurements  UE_2  technology=5G
    Configure ue_history for UE1 to enable handovers from gNB3
    Configure ue_history for UE2 to enable handovers from gNB3

    Execute egate command   cmd=gnb_param measEvent=A3 sa_ho=xn_based id=3
    Execute egate command   cmd=gnb_param id=3 ciphering_algorithm=nea0 integrityprotection_algorithm=nia2
    Execute egate command   cmd=gnb_xn_handover_preparation_param id=3 include_security_config=true sec_config_nea=nea0 sec_config_nia=nia2
    Execute egate command   cmd=gnb_param id=3 srb1_rlc_sn_field_size=size_12
    Execute egate command   cmd=amf_param id=1 intra5gs_data_forwarding=off
    Sleep    1

Cleanup after test JA-B3c
    Log To Console    Cleanup after test JA-B3c
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 reset
    Detach and kill UE1
    Detach and kill UE2
    Stop observing measurements  UE_1
    Stop observing measurements  UE_2
