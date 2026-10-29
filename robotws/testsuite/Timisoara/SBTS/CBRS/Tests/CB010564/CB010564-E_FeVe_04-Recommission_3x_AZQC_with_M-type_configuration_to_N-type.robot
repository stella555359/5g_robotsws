*** Settings ***
Documentation
...    = Author =
...    karol.sadowski@nokia.com
...    = Maintainer =
...    karol.sadowski@nokia.com
...    = Reviewer =
...    aleksandra.chudzik@nokia.com
...    piotr.lukaszewicz@nokia.com
...    Review link:

*** Keywords ***
CB010564-E_FeVe_04-Recommission_3x_AZQC_with_M-type_configuration_to_N-type
    [Documentation]    Requirement: SRAN_SFS_SISO.3871, SRAN_SFS_SISO.3905, OAM_REQ_CBRS_556
    ...                Purpose:This test case verifies BTS behaviour during recommissioning from M-type to N-type
    ...                in cross-sector configuration. Validatig enabling/disabling feature by modyfying IM objects.
    ...
    ...                Test Steps:
    ...                Step 0: Prepare BTS N-type (cross-sector) and SAS configuration
    ...                Step 1: Start SAS simulator and enable CBRS on BTS
    ...                Step 2: Check cells status and alarms
    ...                Step 3: Perform delta recommissioning to M-type (non cross-sector)
    ...                Step 4: Check cells status and alarms
    ...                Step 5: Perform delta recommissioning to N-type (cross-sector)
    ...                Step 6: Check cells status and alarms


    ${bts_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST

    Log To Console    ${\n}Step 0:${\n}Preparing disabling/enabling feature SCF files..

    Enable CBRS Feature On eNB

    Wait Until Keyword Succeeds    15x     15s     Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Get Current Scf File
           ...   local_dir_path=${OUTPUT_DIR}
           ...   file_name=enable_cross_sector_SCF.xml
           ...   timeout=30
           ...   connection=${alias}

    Load Scf    file_path=${OUTPUT_DIR}/enable_cross_sector_SCF.xml

    Remove List From Scf    dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}/CBSD-1    list_name=antlDNList
    Remove List From Scf    dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}/CBSD-2    list_name=antlDNList
    Remove List From Scf    dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}/CBSD-3    list_name=antlDNList

    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/SECANT-1
    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/SECANT-2
    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/SECANT-3

    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1/ANTL-1    p_name=secantDN
    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1/ANTL-2    p_name=secantDN
    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1/ANTL-3    p_name=secantDN
    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1/ANTL-4    p_name=secantDN
    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-2/ANTL-1    p_name=secantDN
    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-2/ANTL-2    p_name=secantDN
    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-2/ANTL-3    p_name=secantDN
    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-2/ANTL-4    p_name=secantDN
    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-3/ANTL-1    p_name=secantDN
    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-3/ANTL-2    p_name=secantDN
    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-3/ANTL-3    p_name=secantDN
    Remove Element From Scf    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-3/ANTL-4    p_name=secantDN

    Modify Scf Element
    ...    value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1/ANTL-3
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-1/CHANNELGROUP-1/CHANNEL-5
    ...    p_name=antlDN
    Modify Scf Element
    ...    value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1/ANTL-3
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-1/CHANNELGROUP-1/CHANNEL-6
    ...    p_name=antlDN
    Modify Scf Element
    ...    value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1/ANTL-4
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-1/CHANNELGROUP-1/CHANNEL-7
    ...    p_name=antlDN
    Modify Scf Element
    ...    value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1/ANTL-4
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-1/CHANNELGROUP-1/CHANNEL-8
    ...    p_name=antlDN

    Modify Scf Element
    ...    value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-2/ANTL-3
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-2/CHANNELGROUP-1/CHANNEL-1
    ...    p_name=antlDN
    Modify Scf Element
    ...    value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-2/ANTL-3
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-2/CHANNELGROUP-1/CHANNEL-2
    ...    p_name=antlDN
    Modify Scf Element
    ...    value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-2/ANTL-4
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-2/CHANNELGROUP-1/CHANNEL-3
    ...    p_name=antlDN
    Modify Scf Element
    ...    value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-2/ANTL-4
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-2/CHANNELGROUP-1/CHANNEL-4
    ...    p_name=antlDN

    Modify Scf Element
    ...    value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-3/ANTL-3
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1/CHANNEL-10
    ...    p_name=antlDN
    Modify Scf Element
    ...    value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-3/ANTL-4
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1/CHANNEL-11
    ...    p_name=antlDN
    Modify Scf Element
    ...    value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-3/ANTL-4
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1/CHANNEL-12
    ...    p_name=antlDN
    Modify Scf Element
    ...    value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-3/ANTL-3
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1/CHANNEL-9
    ...    p_name=antlDN

    Save Scf    file_path=${OUTPUT_DIR}/disable_cross_sector_SCF.xml

    Log To Console    Preparing test environment...

    Wait Until BTS Is Not Busy

    Disable CBRS Feature On eNB
    Kill All SAS Processes

    Wait Until Keyword Succeeds    5x     15s     Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Commissioning
           ...    bts_id=${bts_id}
           ...    scf_file=${OUTPUT_DIR}/disable_cross_sector_SCF.xml
           ...    timeout=720
           ...    connection=${alias}

    Log To Console    Step 1: Starting SAS simulator...

    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe_04/SAS_Sim.conf

    Wait Until Keyword Succeeds    10x    15s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${bts_id}

    Start Watchdog Alarm Detection

    Wait For All Cells To Be OnAir    wait_time=10min

    Log To Console    Step 2: Enable cross-sector

    Wait Until Keyword Succeeds    5x     15s     Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Commissioning
           ...    bts_id=${bts_id}
           ...    scf_file=${OUTPUT_DIR}/enable_cross_sector_SCF.xml
           ...    timeout=720
           ...    connection=${alias}

    Wait For All Cells To Be OnAir    wait_time=10min

    Log To Console    Step 3: Disable cross-sector

    Wait Until Keyword Succeeds    5x     15s     Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Commissioning
           ...    bts_id=${bts_id}
           ...    scf_file=${OUTPUT_DIR}/disable_cross_sector_SCF.xml
           ...    timeout=720
           ...    connection=${alias}

    Wait For All Cells To Be OnAir    wait_time=10min

    Log To Console    Step 4: Checking logs

    Wait Until Keyword Succeeds    6x    10s    Check If TS Version Is As Expected    ${bts_id}    ${alias}    2.0

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Disable CBRS Feature On eNB    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Wait Until Keyword Succeeds    5x     15s    Perform Commissioning
                                  ...    bts_id=${bts_id}
                                  ...    scf_file=${OUTPUT_DIR}/enable_cross_sector_SCF.xml
                                  ...    timeout=720
                                  ...    connection=${alias}    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${bts_id}
