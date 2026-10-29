*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB013569: RU type

Resource            CommonKeywords.robot


*** Keywords ***
CB013569 Setup
    Log To Console    CB013569 setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}
    Require UE    ue_alias=${UE_ALIAS_1}    capabilities=${CAPABILITIES}

CB013569_A Setup
    Log To Console    CB013569 setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

Test Setup
    Log To Console    Test setup
    # BTS is OnAir
    Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

    # Start the logs
    # Start All Logs

Test Teardown
    Log To Console    Test teardown
    # Save the logs and get Snapshot
    # Get All Logs

    # BTS is OnAir
    Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

# CB013569_TC_11

AHPMDA type
    # SCF is loaded on BTS
    ${status}=    COAM SCF Load    ${bts_addr}    ${CV31_scf_file_13569}
    Log To Console    ${status}

    # BTS is OnAir without alarm
    Wait Until Keyword Succeeds    30 min    1 min    COAM Get 5g status enabled    ${bts_addr}

    #
    # 4G test with 5G cell blocked
    #

    COAM Block Cell    ${bts_addr}    ${gnb_mrbts}/${gnb_nrbts}/${NRCELL}
    Sleep    5s

    Android UE Attach    ${UE_ALIAS_1}
    Sleep    10s

    ${ul_value}=    Android UL Traffic    ${UE_ALIAS_1}    ${DURATION}    ${UL_4G_THROUGHPUT}
    ${dl_value}=    Android DL Traffic    ${UE_ALIAS_1}    ${DURATION}    ${DL_4G_THROUGHPUT}

    Should be True    ${ul_value} > ${UL_4G_MIN_THROUGHPUT}
    Should be True    ${dl_value} > ${DL_4G_MIN_THROUGHPUT}

    Android UE Detach    ${UE_ALIAS_1}
    Sleep    10s

    COAM Unblock Cell    ${bts_addr}    ${gnb_mrbts}/${gnb_nrbts}/${NRCELL}
    Sleep    5s

    #
    # 5G test with 4G cell blocked
    #

    COAM Block Cell    ${bts_addr}    ${gnb_mrbts}/${gnb_lnbts}/${LTECELL}
    Sleep    5s

    Android UE Attach    ${UE_ALIAS_1}
    Sleep    10s

    ${ul_value}=    Android UL Traffic    ${UE_ALIAS_1}    ${DURATION}    ${UL_5G_THROUGHPUT}
    ${dl_value}=    Android DL Traffic    ${UE_ALIAS_1}    ${DURATION}    ${DL_5G_THROUGHPUT}

    Should be True    ${ul_value} > ${UL_5G_MIN_THROUGHPUT}
    Should be True    ${dl_value} > ${DL_5G_MIN_THROUGHPUT}

    Android UE Detach    ${UE_ALIAS_1}
    Sleep    10s

    COAM Unblock Cell    ${bts_addr}    ${gnb_mrbts}/${gnb_lnbts}/${LTECELL}

# CB013569_TC_05

AHPMDG type
    # SCF is loaded on BTS
    ${status}=    COAM SCF Load    ${bts_addr}    ${CV174_scf_file_13569}
    Log To Console    ${status}

    # BTS is OnAir without alarm
    Wait Until Keyword Succeeds    30 min    1 min    COAM Get 5g status enabled    ${bts_addr}

    #
    # 5G test on NRCELL #1 with NRCELL #2 blocked
    #

    COAM Block Cell    ${bts_addr}    ${gnb_mrbts}/${gnb_nrbts}/${NRCELL2}
    Sleep    5s

    Android UE Attach    ${UE_ALIAS_1}
    Sleep    10s

    ${ul_value}=    Android UL Traffic
    ...    ${UE_ALIAS_1}
    ...    ${DURATION}
    ...    ${UL_5G_THROUGHPUT}
    ...    udp
    ...    1000B
    ...    ${UL_PORT}
    ${dl_value}=    Android DL Traffic
    ...    ${UE_ALIAS_1}
    ...    ${DURATION}
    ...    ${DL_5G_THROUGHPUT}
    ...    udp
    ...    1000B
    ...    ${DL_PORT}

    Should be True    ${ul_value} > ${UL_5G_MIN_THROUGHPUT}
    Should be True    ${dl_value} > ${DL_5G_MIN_THROUGHPUT}

    Android UE Detach    ${UE_ALIAS_1}
    Sleep    10s

    COAM Unblock Cell    ${bts_addr}    ${gnb_mrbts}/${gnb_nrbts}/${NRCELL2}
    Sleep    5s

    #
    # 5G test on NRCELL #2 with NRCELL #1 blocked
    #

    COAM Block Cell    ${bts_addr}    ${gnb_mrbts}/${gnb_nrbts}/${NRCELL1}
    Sleep    5s

    Android UE Attach    ${UE_ALIAS_1}
    Sleep    10s

    ${ul_value}=    Android UL Traffic
    ...    ${UE_ALIAS_1}
    ...    ${DURATION}
    ...    ${UL_5G_THROUGHPUT}
    ...    udp
    ...    1000B
    ...    ${UL_PORT}
    ${dl_value}=    Android DL Traffic
    ...    ${UE_ALIAS_1}
    ...    ${DURATION}
    ...    ${DL_5G_THROUGHPUT}
    ...    udp
    ...    1000B
    ...    ${DL_PORT}

    Should be True    ${ul_value} > ${UL_5G_MIN_THROUGHPUT}
    Should be True    ${dl_value} > ${DL_5G_MIN_THROUGHPUT}

    Android UE Detach    ${UE_ALIAS_1}
    Sleep    10s

    COAM Unblock Cell    ${bts_addr}    ${gnb_mrbts}/${gnb_nrbts}/${NRCELL1}

# CB013569_TC_01

AWHKB type
    # SCF is loaded on BTS
    ${status}=    COAM SCF Load    ${bts_addr}    ${CV180_scf_file_13569}
    Log To Console    ${status}

    # BTS is OnAir without alarm
    Wait Until Keyword Succeeds    30 min    1 min    COAM Get 5g status enabled    ${bts_addr}

    #
    # Check 4G cell
    #

    Connect to Spirent Sentinel    ${spirent_sentinel_addr}
    Load Spirent Sentinel Preset    ${spirent_sentinel_addr}    ${spirent_sentinel_preset_4G}

    # Spirent needs to lock on the cell
    Sleep    30s

    Check Spirent Sentinel Is Locked    ${spirent_sentinel_addr}

    #
    # Check 5G cell
    #

    Connect to Spirent Sentinel    ${spirent_sentinel_addr}
    Load Spirent Sentinel Preset    ${spirent_sentinel_addr}    ${spirent_sentinel_preset_5G}

    # Spirent needs to lock on the cell
    Sleep    30s

    Check Spirent Sentinel Is Locked    ${spirent_sentinel_addr}
