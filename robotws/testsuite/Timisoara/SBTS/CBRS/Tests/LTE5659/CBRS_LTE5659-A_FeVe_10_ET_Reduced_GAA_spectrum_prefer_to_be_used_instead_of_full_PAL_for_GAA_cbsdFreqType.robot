*** Settings ***
Documentation
...    = Author =
...    karol.sadowski@nokia.com
...    = Maintainer =
...    karol.sadowski@nokia.com
...    = Reviewer =
...    aleksandra.chudzik@nokia.com
...    elzbieta.wlodarczyk@nokia.com
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    http://l3-sim-krk-serv.dynamic.nsn-net.net/r/1259/

*** Keywords ***
CBRS_LTE5659-A_FeVe_10_ET_Reduced_GAA_spectrum_prefer_to_be_used_instead_of_full_PAL_for_GAA_cbsdFreqType
    [Documentation]    The purpose of this test case is to verify that CBSD will prefer to request reduced GAA channel resources
    ...                when there is 20M PAL channel resource and cbrsFreqType set to GAA.
    ...                Tested Requirement: OAM_REQ_CBRS_4, OAM_REQ_CBRS_6, OAM_REQ_CBRS_14, OAM_REQ_CBRS_22, OAM_REQ_CBRS_20,
    ...                                    OAM_REQ_CBRS_38m, OAM_REQ_FMRECOV_1004, OAM_REQ_FMRECOV_1006
    ...    TEST STEPS:
    ...    1. Setup BTS: chbw=20MHz, maxGrantChBwRed=10, cbrsFreqType=GAA
    ...    2. Setup SAS: pal_reserved_channel = 3550,3555,3560,3565,3570,3575,3580,3585,3590,3595,3600,3605,3610,3615,3620,3625
    ...    3. Expected result: After enabling CBRS & start SAS cell's should reconfigure and go onAir with grantID's: (4x 10MHz GAA)
    ...                        3630000000_3640000000  3650000000_3660000000  3670000000_3680000000  3690000000_3700000000

#    ${expected_alarms}   Create List    SAS Registration Failure
    ${supported_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585
    ...                                      3590    3595    3600    3605    3610    3615    3620    3625
    ...                                      3630    3635    3650    3655    3670    3675    3690    3695

    Log To Console    Step 1. Prepare Test Enviornment...
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Start Watchdog Alarm Detection

    Replace Variables In File    ${CURDIR}/Data/FeVe_10/precondition_delta.json
    ...                          ${OUTPUT_DIR}/precondition_delta.json
    ...                          enb_id=${testlines.${testline_id}.enb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_10/postcondition_delta.json
    ...                          ${OUTPUT_DIR}/postcondition_delta.json
    ...                          enb_id=${testlines.${testline_id}.enb_id}

    Wait Until Keyword Succeeds    4x    5s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/precondition_delta.json    connection=RAT_1ST

    Set Supported Spectrum    bts_id=${testlines.${testline_id}.enb_id}    target_spectrum_list=${supported_spectrum}

    Log To Console    Step 2. Start SAS & enable CBRS feature on BTS...

    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/FeVe_10/SAS_Sim.conf

    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB

    Log To Console    Step 3. Wait 2 minutes for cells to go onAir...
    Wait For All Cells To Be OnAir    wait_time=2min

    Log To Console    Step 4. Check GrantId's and compare them with expected result...

    ${current_result}   List Values of GrantId For All Cells    enb_id=${testlines.${testline_id}.enb_id}
    ${expected_result}   Create List    3630000000_3640000000    3650000000_3660000000    3670000000_3680000000    3690000000_3700000000
    List Should Contain Sub List    ${current_result}    ${expected_result}    msg=CBSD acquired different GrantID than expected!

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until BTS Is Not Busy    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
           ...    ${OUTPUT_DIR}/postcondition_delta.json    connection=RAT_1ST    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Kill All SAS Processes    AND
    ...    Check If Cells Are Disabled    enb_id=${testlines.${testline_id}.enb_id}
