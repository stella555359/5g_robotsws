*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB006627: New SFN0 offset management

Resource            CommonKeywords.robot


*** Keywords ***
CB008004 Setup
    Log To Console    CB008004 setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

CB008004-CC Setup
    Log To Console    CB008004-CC setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}
    Require UE    ue_alias=${UE_ALIAS_1}    capabilities=${CAPABILITIES}

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

# 8004_A TC_05

DomainId sent to RU
    # SCF is loaded on BTS
    #${status}=    COAM SCF Load    ${bts_addr}    ${scf_file_8004_a_tc_05}
    #Log To Console    ${status}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # Find AZQO RU
    # ${index}=    Get RU Index    ${ru_name}
    # Should Be True    ${index} >= 0
    # ${ru_username}=    Set Variable    ${tl.gnbs[0].dus[0].rus[${index}].default_ssh_connection_details.username}
    # ${ru_password}=    Set Variable    ${tl.gnbs[0].dus[0].rus[${index}].default_ssh_connection_details.password}

    ${ru_username}=    Set Variable    ${azqo_username}
    ${ru_password}=    Set Variable    ${azqo_password}

    # Parameter changes
    ${param1}=    Create List
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1
    ...    eCpriMasterDomainNumber
    ...    ${new_ptp_domain_id}
    ${param2}=    Create List
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
    ...    topDomainNumber
    ...    ${new_ptp_domain_id}
    ${params}=    Create List    ${param1}    ${param2}
    COAM Delta Commissioning    ${bts_addr}    ${params}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # Connect to RU through eCPRI to start tcpdump
    ${RU_shell}=    Connect to RU with Type
    ...    ${bts_addr}
    ...    ${bts_smod_username}
    ...    ${bts_smod_password}
    ...    ${ru_username}
    ...    ${ru_password}
    ...    ${ru_name}
    ${tcpdump_pid}=    Start Remote Tcpdump    ${RU_shell}    arb0p0
    Sleep  10s
    Stop Remote Tcpdump    ${RU_shell}    ${tcpdump_pid}
    Get PCAP from RU    ${RU_shell}    ${ru_username}    ${ru_password}    ${ru_name}

    # Check domainid in ptp messages in pcap
    ${number_of_ptp_messages}=    Run    tshark -r /tmp/ru_tcpdump.pcap -Y ptp.v2.subdomainnumber | wc -l
    ${number_of_good_ptp_messages}=    Run
    ...    tshark -r /tmp/ru_tcpdump.pcap -Y ptp.v2.subdomainnumber==${new_ptp_domain_id} | wc -l
    ${number_of_bad_ptp_messages}=    Run
    ...    tshark -r /tmp/ru_tcpdump.pcap -Y ptp.v2.subdomainnumber!=${new_ptp_domain_id} | wc -l

    Log To Console    ${number_of_ptp_messages}
    Log To Console    ${number_of_good_ptp_messages}
    Log To Console    ${number_of_bad_ptp_messages}

    # All PTP messages should use newly set domainid
    Should Be Equal    ${number_of_ptp_messages}    ${number_of_good_ptp_messages}
    Should Be Equal    ${number_of_bad_ptp_messages}    0

# 8004_CE TC_06

Cell Timing Offset Modification On Scorpio eCPRI
    # SCF is loaded on BTS
    ${status}=    COAM SCF Load    ${bts_addr}    ${scf_file_8004_ce_tc_06}
    Log To Console    ${status}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    Connect to Spirent Sentinel    ${spirent_sentinel_addr}
    Load Spirent Sentinel Preset    ${spirent_sentinel_addr}    ${spirent_sentinel_preset_ce}

    # Spirent needs to lock on the cell
    Sleep    30s

    ${spirent_offset}=    Get Spirent Sentinel Offset    ${spirent_sentinel_addr}

    ${status}=    Should Be Quite Equal    ${CE_framestartoffset_1}    ${spirent_offset}    0.8
    Should Be True    ${status}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/${gnb_nrbts}/${CE_TDDCELL_2}
    ...    sfnOffset
    ...    ${CE_sfnOffset_2}

    # Wait alarm FaultId: 4677 : Inconsistency of air interface timing offset configuration to appear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${bts_addr}    4677

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/${gnb_nrbts}/${CE_TDDCELL_2}
    ...    sfnOffset
    ...    ${CE_sfnOffset_1}

    # Wait for alarm FaultId 4677 to disappear : Inconsistency of air interface timing offset configuration    to disappear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault not Displayed in webEM    ${bts_addr}    4677

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # Spirent needs to lock on the cell
    Sleep    10s

    ${spirent_offset}=    Get Spirent Sentinel Offset    ${spirent_sentinel_addr}

    ${status}=    Should Be Quite Equal    ${CE_framestartoffset_1}    ${spirent_offset}    0.8
    Should Be True    ${status}

# 9055 TC_06

Cell Timing Offset Modification On Scorpio eCPRI With ABIP
    # SCF is loaded on BTS
    ${status}=    COAM SCF Load    ${bts_addr}    ${scf_file_9055_tc_06}
    Log To Console    ${status}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    Connect to Spirent Sentinel    ${spirent_sentinel_addr}
    Load Spirent Sentinel Preset    ${spirent_sentinel_addr}    ${spirent_sentinel_preset_abip}

    # Spirent needs to lock on the cell
    Sleep    10s

    ${spirent_offset}=    Get Spirent Sentinel Offset    ${spirent_sentinel_addr}

    ${status}=    Should Be Quite Equal    ${ABIP_framestartoffset_1}    ${spirent_offset}    0.8
    Should Be True    ${status}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/${gnb_nrbts}/${ABIP_TDDCELL_2}
    ...    sfnOffset
    ...    ${ABIP_sfnOffset_2}

    # Wait alarm FaultId: 4677 : Inconsistency of air interface timing offset configuration to appear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${bts_addr}    4677

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/${gnb_nrbts}/${ABIP_TDDCELL_2}
    ...    sfnOffset
    ...    ${ABIP_sfnOffset_1}

    # Wait for alarm FaultId 4677 to disappear : Inconsistency of air interface timing offset configuration    to disappear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault not Displayed in webEM    ${bts_addr}    4677

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # Spirent needs to lock on the cell
    Sleep    30s

    ${spirent_offset}=    Get Spirent Sentinel Offset    ${spirent_sentinel_addr}

    ${status}=    Should Be Quite Equal    ${ABIP_framestartoffset_1}    ${spirent_offset}    0.8
    Should Be True    ${status}

# 8004_CD TC_02

Cell Timing Offset Modification On Zodiac
    # SCF is loaded on BTS
    ${status}=    COAM SCF Load    ${bts_addr}    ${scf_file_8004_cd_tc_02}
    Log To Console    ${status}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # Parameter changes
    ${param1}=    Create List    ${gnb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1    actCellTimingOffsetCpriN    true
    ${fs_tmp}=    Evaluate    10000 * ${CD_framestartoffset_1}
    ${param2}=    Create List    ${enb_mrbts}/${enb_lnbts}/${CD_4GCELL_1}    frameStartOffset    ${fs_tmp}
    ${param3}=    Create List    ${enb_mrbts}/${enb_lnbts}/${CD_4GCELL_1}    sfnOffset    ${CD_sfnoffset_1}
    ${param4}=    Create List    ${enb_mrbts}/${enb_lnbts}/${CD_4GCELL_2}    frameStartOffset    ${fs_tmp}
    ${param5}=    Create List    ${enb_mrbts}/${enb_lnbts}/${CD_4GCELL_2}    sfnOffset    ${CD_sfnoffset_1}
    ${param6}=    Create List    ${gnb_mrbts}/${gnb_nrbts}/${CD_5GCELL_1}    frameStartOffset    ${fs_tmp}
    ${param7}=    Create List    ${gnb_mrbts}/${gnb_nrbts}/${CD_5GCELL_1}    sfnOffset    ${CD_sfnoffset_1}
    ${param8}=    Create List    ${gnb_mrbts}/${gnb_nrbts}/${CD_5GCELL_2}    frameStartOffset    ${fs_tmp}
    ${param9}=    Create List    ${gnb_mrbts}/${gnb_nrbts}/${CD_5GCELL_2}    sfnOffset    ${CD_sfnoffset_1}

    ${params}=    Create List
    ...    ${param1}
    ...    ${param2}
    ...    ${param3}
    ...    ${param4}
    ...    ${param5}
    ...    ${param6}
    ...    ${param7}
    ...    ${param8}
    ...    ${param9}

    COAM Delta Commissioning    ${bts_addr}    ${params}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    Connect to Spirent Sentinel    ${spirent_sentinel_addr}
    Load Spirent Sentinel Preset    ${spirent_sentinel_addr}    ${spirent_sentinel_preset_cd}

    # Spirent needs to lock on the cell
    Sleep    30s

    ${spirent_offset}=    Get Spirent Sentinel Offset    ${spirent_sentinel_addr}

    ${status}=    Should Be Quite Equal    ${CD_framestartoffset_1}    ${spirent_offset}    0.8
    Should Be True    ${status}

    ${fs_tmp}=    Evaluate    10000 * ${CD_framestartoffset_2}
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${enb_mrbts}/${enb_lnbts}/${CD_4GCELL_1}
    ...    frameStartOffset
    ...    ${fs_tmp}

    ${fs_tmp}=    Evaluate    10000 * ${CD_framestartoffset_3}
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${enb_mrbts}/${enb_lnbts}/${CD_4GCELL_2}
    ...    frameStartOffset
    ...    ${fs_tmp}

    # Wait alarm FaultId: 4677 : Inconsistency of air interface timing offset configuration to appear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${bts_addr}    4677

    ${fs_tmp}=    Evaluate    10000 * ${CD_framestartoffset_2}
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${enb_mrbts}/${enb_lnbts}/${CD_4GCELL_2}
    ...    frameStartOffset
    ...    ${fs_tmp}

    # Wait for alarm FaultId 4677 to disappear: Inconsistency of air interface timing offset configuration    to disappear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault not Displayed in webEM    ${bts_addr}    4677

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # Spirent needs to lock on the cell
    Sleep    10s

    Connect to Spirent Sentinel    ${spirent_sentinel_addr}
    Load Spirent Sentinel Preset    ${spirent_sentinel_addr}    ${spirent_sentinel_preset_cd}
    ${spirent_offset}=    Get Spirent Sentinel Offset    ${spirent_sentinel_addr}

    ${status}=    Should Be Quite Equal    ${CD_framestartoffset_2}    ${spirent_offset}    0.8
    Should Be True    ${status}

# 8004_CC TC_02

Configure Feature on Concurrent 4G TDD 5G TDD
    # SCF is loaded on BTS
    ${branch}=    COAM Get SW Branch    ${bts_addr}
    ${scf_file}=    Set Variable If
    ...    "${branch}" == "SBTS23R4"
    ...    ${scf_file_8004_cc_tc_02_23R4}
    ...    ${scf_file_8004_cc_tc_02}

    ${status}=    COAM SCF Load    ${bts_addr}    ${scf_file}
    Log To Console    ${status}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # Parameter changes
    ${param1}=    Create List    ${gnb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1    actCellTimingOffsetCpriN    true
    ${fs_tmp}=    Evaluate    10000 * ${CC_framestartoffset_4G}
    ${param2}=    Create List    ${enb_mrbts}/${enb_lnbts}/${CC_4GCELL}    frameStartOffset    ${fs_tmp}
    ${param3}=    Create List    ${enb_mrbts}/${enb_lnbts}/${CC_4GCELL}    sfnOffset    ${CC_sfnoffset_4G}
    ${fs_tmp}=    Evaluate    10000 * ${CC_framestartoffset_5G}
    ${param4}=    Create List    ${gnb_mrbts}/${gnb_nrbts}/${CC_5GCELL}    frameStartOffset    ${fs_tmp}
    ${param5}=    Create List    ${gnb_mrbts}/${gnb_nrbts}/${CC_5GCELL}    sfnOffset    ${CC_sfnoffset_5G}
    ${param6}=    Create List    ${gnb_mrbts}/${gnb_nrbts}/${CC_5GCELL}    lteToNrTimeOffset    30
    &{myDict}=    Create Dictionary
    ...    frameStructureType=tdLte    guardPeriodLength=4Symbols    lteToNrFrameShift=3ms
    ...    tdLteUlDlConfig=tdLteConfig2    ulDlDataSlotRatio=2/8
    ${myList}=    create list    ${myDict}
    ${param7}=    Create List    ${gnb_mrbts}/${gnb_nrbts}/${CC_5GCELL}    tddFrameStructure    ${myList}
    ${param8}=    Create List    ${gnb_mrbts}/${gnb_nrbts}/${CC_5GCELL}    prachConfigurationIndex    151

    ${params}=    Create List
    ...    ${param1}
    ...    ${param2}
    ...    ${param3}
    ...    ${param4}
    ...    ${param5}
    ...    ${param6}
    ...    ${param7}
    ...    ${param8}

    COAM Delta Commissioning    ${bts_addr}    ${params}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # There is no alarm FaultId 4677 or 4678
    Run Keyword And Continue on failure    COAM Check Fault not Displayed in webEM    ${bts_addr}    4677
    Run Keyword And Continue on failure    COAM Check Fault not Displayed in webEM    ${bts_addr}    4678

    Android UE Attach    ${UE_ALIAS_1}
    Sleep    10s
    ${ul_value}=    Android UL Traffic    ${UE_ALIAS_1}    ${DURATION}    ${UL_THROUGHPUT}
    ${dl_value}=    Android DL Traffic    ${UE_ALIAS_1}    ${DURATION}    ${DL_THROUGHPUT}

    Should be True    ${ul_value} > ${UL_MIN_THROUGHPUT}
    Should be True    ${dl_value} > ${DL_MIN_THROUGHPUT}

L3Call Only
    Run Keyword And Continue on failure    Attach Ue    ue_alias=${UE_ALIAS_1}    success_ratio=100%
    Log To Console    UE attached
    Sleep    10s

    Run Keyword And Continue on failure
    ...    Start Data Transfer
    ...    ue_alias=${UE_ALIAS_1}
    ...    dt_name=DT_1
    ...    direction=dl
    ...    duration=${DURATION}
    ...    throughput=${L3CALL_DL_THPUT}
    ...    protocol=${PROTOCOL}
    ...    packet=${PACKET}
    ...    port=${DL_PORT}

    Log To Console    DL Data transfer started
    Sleep    10s
    Run Keyword And Continue on failure    Await Data Transfer Finish    dt_name=DT_1

    ${dl_thput}=    Run Keyword And Continue on failure    Get Average Throughput    DT_1
    ${str_dl_thput}=    Convert To String    ${dl_thput}

    Log To Console    ------------
    Log To Console    Requested DL throughput = ${L3CALL_DL_THPUT}
    Log To Console    Obtained DL throughput = ${str_dl_thput}
    Log To Console    ------------
    Log To Console    DL Data transfer finish

    Run Keyword And Continue on failure    Stop Data Transfer    DT_1

    Sleep    10s

    Run Keyword And Continue on failure
    ...    Start Data Transfer
    ...    ue_alias=${UE_ALIAS_1}
    ...    dt_name=DT_2
    ...    direction=ul
    ...    duration=${DURATION}
    ...    throughput=${L3CALL_UL_THPUT}
    ...    protocol=${PROTOCOL}
    ...    packet=${PACKET}
    ...    port=${UL_PORT}

    Log To Console    UL Data transfer started
    Sleep    10s
    Run Keyword And Continue on failure    Await Data Transfer Finish    dt_name=DT_2

    ${ul_thput}=    Run Keyword And Continue on failure    Get Average Throughput    DT_2
    ${str_ul_thput}=    Convert To String    ${ul_thput}

    Log To Console    ------------
    Log To Console    Requested UL throughput = ${L3CALL_UL_THPUT}
    Log To Console    Obtained UL throughput = ${str_ul_thput}
    Log To Console    ------------
    Log To Console    UL Data transfer finish

    Run Keyword And Continue on failure    Stop Data Transfer    DT_2

    Sleep    10s

    Run keyword and ignore error    Detach Ue    ${UE_ALIAS_1}
    Log To Console    UE detached

Test PR
    FOR    ${index}    IN RANGE    100
        COAM Lock RU    ${bts_addr}    MRBTS-2173/EQM-1/APEQM-1/RMOD-2

        Run Keyword And Continue on failure    COAM Parameter Online update
        ...    ${bts_addr}    ${gnb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1    actCellTimingOffsetCpriN    true

        COAM Unlock RU    ${bts_addr}    MRBTS-2173/EQM-1/APEQM-1/RMOD-2

        # BTS is OnAir
        Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

        Run Keyword And Continue on failure    Attach Ue    ue_alias=${UE_ALIAS_1}
        Log To Console    UE attached
        Sleep    10s
        Run keyword and ignore error    Detach Ue    ${UE_ALIAS_1}
        Log To Console    UE detached

        Run Keyword And Continue on failure    COAM Parameter Online update
        ...    ${bts_addr}    ${gnb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1    actCellTimingOffsetCpriN    false
    END

Test Sentinel
    Connect to Spirent Sentinel    ${spirent_sentinel_addr}
    Load Spirent Sentinel Preset    ${spirent_sentinel_addr}    ${spirent_sentinel_preset_cd}
    ${spirent_offset}=    Get Spirent Sentinel Offset    ${spirent_sentinel_addr}
    # Disconnect from Spirent Sentinel    ${spirent_sentinel_addr}

    Connect to Spirent Sentinel    ${spirent_sentinel_addr}
    Load Spirent Sentinel Preset    ${spirent_sentinel_addr}    ${spirent_sentinel_preset_cd}
    ${spirent_offset}=    Get Spirent Sentinel Offset    ${spirent_sentinel_addr}
    # Disconnect from Spirent Sentinel    ${spirent_sentinel_addr}
