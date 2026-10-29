*** Settings ***
Documentation
...    = Author =
...    _aleksandra.chudzik@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    karol.sadowski@nokia.com
...    elzbieta.wlodarczyk@nokia.com
...    Review link: https://l3-sim-krk-serv.dynamic.nsn-net.net/r/1402/

*** Keywords ***
CBRS_LTE4237_FeVe_04_ET_Change_chBw_value_will_be_reconfigured_to_desiredchBw_again
    [Documentation]    Tested Requirement: OAM_REQ_CBRS_51
    ...                Purpose: Test case verifies the change of chBw by operator to a different value.
    ...                ChBw will reconfigure to desiredChBw value. Since the Grant is not going to be changed,
    ...                the chBw will be set back to the value before the change. Test case also verifies situation
    ...                when there is no resources from SAS to reconfigure chBw to desiredChBw value.
	...                Test Steps:
	...                1.Start SAS Simulator
	...                2.Check if all 4 grants are authorized
	...                3.Change chBw to 10 MHz
	...                4.Verify if chBw is set back to the value before the change
	...                5.Change chBw to 20 MHz
	...                6.Verify if chBw is set back to the value before the change

    #Variables setup
    Log To Console    Preconditions
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}

    Log To Console    Kill SAS if exists
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}

    Replace Variables In File    ${CURDIR}/Data/FeVe04/precondition_delta.json
    ...                          ${OUTPUT_DIR}/precondition_delta.json
    ...                          enb_id=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe04/postcondition_delta.json
    ...                          ${OUTPUT_DIR}/postcondition_delta.json
    ...                          enb_id=${enb_id}

	Log To Console    Recommissioning ongoing: chBw: cells 1-2 20MHz, cells 3-4 10MHz, desiredChBw: 20Mhz, maxGrantChBwRed: 10
    Wait Until Keyword Succeeds    5x    30s    Run Keywords
	...                                         Wait Until BTS Is Not Busy    AND
	...                                         Perform Delta Recommissioning
    ...                                         ${OUTPUT_DIR}/precondition_delta.json
    ...                                         connection=RAT_1ST

    Log To Console    Step 1. Start SAS Simulator
	Log To Console    spectrum_table: 3560-3590, 3610-3640 (60MHz)

    ${sas_pid}    ${sas_logs_dir}   Start SAS Process
    ...                               alias=default
    ...                               port=4433
    ...                               config=${CURDIR}/Data/FeVe04/SAS_Sim.conf

	Log To Console    Step 2. Check if all 4 grants are authorized
	ute_admin_infomodel.Query Infomodel
    ...                   query=every /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-* is [grantState=Authorized]
    ...                   timeout=360
    ...                   alias=RAT_1ST

	Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection

    Log To Console    Step 3. Change chBw to 10 MHz
    Modify Bandwidth For All Cbsd Cells    enb_id=${enb_id}
	...                                    required_chbw=10

	Log To Console    Step 4. Verify if chBw is set back to the value before the change
    Wait For All Cells To Be OnAir
	Wait Until Keyword Succeeds    4x    50s    Verify if chBw Is Set Back To Previous Value

	Log To Console    Step 5. Change chBw to 20 MHz
    Modify Bandwidth For All Cbsd Cells    enb_id=${enb_id}
	...                                    required_chbw=20

	Log To Console    Step 6. Verify if chBw is set back to the value before the change
	#no resources from SAS to reconfigure chBw to desiredChBw value
    Wait For All Cells To Be OnAir    alias=RAT_1ST
	Wait Until Keyword Succeeds    4x    50s    Verify if chBw Is Set Back To Previous Value


	[Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Run Keywords
	...                                                Wait Until BTS Is Not Busy    AND
	...                                                Perform Delta Recommissioning
    ...                                                ${OUTPUT_DIR}/postcondition_delta.json
    ...                                                connection=RAT_1ST    AND
    ...    Kill All SAS Processes


*** Keywords ***

Verify if chBw Is Set Back To Previous Value
    [Documentation]  Description:    Check in IM if all cells are set to certain chBw value  ${\n}
    ...              Return:         none                                                    ${\n}
    ...              Output:         {}                                                      ${\n}
	${cell-1_chbw}   Run Keyword And Return Status    Query Infomodel    alias=RAT_1ST
	...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-1/LNCEL_M-1 is [ulChBw=20000000]
	${cell-2_chbw}   Run Keyword And Return Status    Query Infomodel    alias=RAT_1ST
	...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-2/LNCEL_M-2 is [ulChBw=20000000]
	${cell-3_chbw}   Run Keyword And Return Status    Query Infomodel    alias=RAT_1ST
	...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-3/LNCEL_M-3 is [ulChBw=10000000]
    ${cell-4_chbw}   Run Keyword And Return Status    Query Infomodel    alias=RAT_1ST
    ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-4/LNCEL_M-4 is [ulChBw=10000000]
