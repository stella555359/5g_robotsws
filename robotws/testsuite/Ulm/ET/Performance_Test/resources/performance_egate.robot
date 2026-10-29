*** Settings ***
Documentation    Test variable and keyword resource file for Performance_Test

Library     Collections

Library     taf.transport.ssh                            WITH NAME   ssh
Library     python/bash_helper.py
Library     python/bearer_stats_fast.py
Library     python/perf_timer.py
Library     python/scripts.py

Resource    ../../../resources/Common/connect.robot
Resource    ../../../resources/Common/wts_ue.robot

Resource    ../../resources/SQD60/sqd60_tools.robot

Resource    performance_egate.robot
Resource    performance_verification.robot
Resource    performance_log_collection.robot

*** Variables ***
@{T_COMMON_EGATE_ERRORS}    ERR: UEC-.: Lost connection with proxy to eNB 2 cell .! Deactivating! No Hearbeat Response recieved on time.
...                         \[CellId:[0-9]+\]\[PhysCellId:[0-9]+\] CellSyncProcedure failed after 60 timeout to retrieve the beam infos

                            # egate should not change state configured mid test
...                         CHANGE STATE: CONFIGURED

                            # unknown cause
...                         T300 expiration: No response to RRCSetupRequest

                            # unknown cause
...                         .*RRC Reject was received.*

                            # Check the nrarfcn values
...                         enbId: [0-9]+ CellId: [0-9]+. DL\/UL central frequencies mismatch. configured: [0-9]+\/[0-9]+, received [0-9]+\/[0-9]+

                            # Check the lua files
...                         Warning: UE [0-9]+: Can not start DL traffic . Pdu Session Id: [0-9]+ does not exist

                            # Check the lua files
...                         UE-[0-9]+ is not configured

                            # Check iphy.xml and SCF cell mapping
...                         CellId from Gnb SCF is not defined in AP iphy.xml list of cells

                            # unknown cause
...                         CHANGE STATE: OOS. Application reported an error

                            # unknown cause
...                         Configuration mismatch: proxy .* has [0-9]+ cell.s., e.g. eNB[0-9]+ Cell[0-9]+, missing.*configuration .check iphy.xml.

                            # ue is not active, check which UE
...                         Warning.*\[OFF\] isn.t active/idle to start data sending

                            # unknown
...                         UEC-[0-9]+: UE[0-9]+: eNB [0-9]+ cell [0-9]+: No response from proxy for CTRL_ADD_MOD_RB

                            # unknown
...                         UEC-[0-9]+: UE[0-9]+: UE[0-9]+: SdapCtx did not exist for PDU session ID:[0-9]+

*** Keywords ***
UE Context Release Req should not be present
    ${ret}    Run Keyword And Return Status    Egate Console Log Should Match Regexp
    ...                                        Received UE CONTEXT RELEASE REQUEST from GNB-2 handled successfully
    Run Keyword And Continue On Failure        Should Not Be True    ${ret}    msg='UE CONTEXT RELEASE REQUEST' Present in egate_console.log

Run Test Script
    [Arguments]    ${entry}    ${pass_regexp}=.*script completed.*    ${fail_regexp}=${none}
    ...            ${custom_lua_file}=${NONE}    ${timeout}=1200
    ${test_script_st}    perf_timer.Start
    IF    "${SUITE METADATA["Duplex Mode Info"]}"=="${NONE}"
    ...               Log    Duplex Mode Info should be defined! (TDD will be default)
    ...                      level=WARN    console=${P_console}

    ${lua_file}=    Set Variable If    "${SUITE METADATA["Duplex Mode Info"]}"=="FDD"    commands_fdd.lua      commands_tdd.lua
    ${lua_file}=    Set Variable If    "${custom_lua_file}"!="${NONE}"                   ${custom_lua_file}    ${lua_file}

    Run lua script    ${lua_file}    ${entry}    pass_regexp=${pass_regexp}    timeout=${timeout}    fail_regexp=${fail_regexp}
    perf_timer.Stop    msg=Test Script:    start_time=${test_script_st}

Check for egate errors
    [Arguments]    ${regexps}=${T_COMMON_EGATE_ERRORS}
    FOR    ${regexp}    IN     @{regexps}
        ${ret}    Run Keyword And Return Status    Egate Console Log Should Match Regexp    ${regexp}
        Run Keyword And Warn On Failure    Should Not Be True    ${ret}    msg='${regexp}' Present in egate_console.log
    END

Run Sansa configuration script
    [Arguments]    ${lua_file}=sansa_tdd_1cell.lua    ${start_cell}=1    ${end_cell}=1    ${entry}=run_configuration()
    ...            ${active_cells}=${TS_LIST_ALL}
    Log to console    ${bar_b}\nConfigure:\n${SPACE} ${SPACE} ${lua_file} -> ${entry}\n
    TRY
        Send Egate Command And Verify Output
        ...    timeout=600    cmd=cfg_sim file=${lua_file} entry=${entry}
        ...    pass_regexp=SimMode is ready now
    EXCEPT    .*NoRegexpMatch: It was not possible to find string after .* secs to match regexp .SimMode is ready now. in output.*    type=regexp
        Run Keyword And Continue On Failure    FAIL    [${lua_file}] Not Found in Egate: SimMode is ready now
    EXCEPT
        Run Keyword And Continue On Failure    FAIL    [${lua_file}] Failed to Configure
    END

    # IF     "${TP.DISABLE_EVENTS_ON_TELNET_SESSION}"!="null"
    # ...    Run Keyword And Warn On Failure    Disable events on telnet session    value=${TP.DISABLE_EVENTS_ON_TELNET_SESSION}

    # Run keyword and warn on failure    Show Sim State Disp
    IF    "${TP.CFG_BIP_CELLSETUP_GNB_DURATION}"!="null"
        performance_log_collection.Quick BIP Collection    subfolder=cellsetup    duration=${TP.CFG_BIP_CELLSETUP_GNB_DURATION}
    END
    IF    "${TP.CFG_BIP_CELLSETUP_AP_DURATION}"!="null"
        performance_log_collection.Quick BIP Collection AP    subfolder=cellsetup    duration=${TP.CFG_BIP_CELLSETUP_AP_DURATION}
    END

    Run Keyword And Continue On Failure    Wait For Airphone Cell Setup    start_cell=${start_cell}    end_cell=${end_cell}
    ...                                                                    active_cells=${active_cells}
    Wait for SIB                    start_cell=${start_cell}    end_cell=${end_cell}    active_cells=${active_cells}

    Log to console    Wait until all gNBs to be onair state\n
    gnb.Wait until all gNBs to be onair state

    Sleep  15s  reason=stabilize

Run lua script
    [Arguments]    ${lua_file}    ${entry}    ${sleep}=1s    ${pass_regexp}=${none}    ${timeout}=600    ${fail_regexp}=${none}
    ${entry_str}    Replace String Using Regexp    ${entry}    \\(.*\\)    ${empty}

    Log to console    ${bar_b}\nRun lua script:\n${SPACE} ${SPACE} ${lua_file} -> ${entry_str}\n
    Log    ${SPACE}- Wait for regex -> ${pass_regexp}\n    console=${P_console}
    TRY
        Send Egate Command and verify output
        ...    timeout=${timeout}    cmd=script file=${lua_file} entry=${entry}
        ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
        Sleep  ${sleep}  reason=stabilize
    EXCEPT    .*NoRegexpMatch: It was not possible to find string after.*secs to match regexp.*in output.*    type=regexp
        Run Keyword And Continue On Failure    FAIL    Lua Script Failed: (NoRegexpMatch) ${lua_file} entry=${entry}
    EXCEPT
        Run Keyword And Continue On Failure    FAIL    Lua Script Failed: ${lua_file} entry=${entry}
    END

Disable events on telnet session
    [Arguments]    ${value}=on
    Log    disable_events_on_telnet_session=${value}    console=${P_console}
    Send Egate Command and verify output
    ...    cmd=sim_param_set disable_events_on_telnet_session=${value}
    ...    pass_regexp=${None}    fail_regexp=${None}

Show Sim State Disp
    ${output}=    Send Egate Command and verify output
    ...    cmd=sim_state_disp
    ...    pass_regexp=${None}    fail_regexp=${None}
    Log    ${output}    console=${P_console}

Wait for SIB
    [Arguments]    ${start_cell}=1    ${end_cell}=1    ${timeout}=5 mins
    ...            ${active_cells}=${TS_LIST_ALL}    ${sibtype}=1    ${celltype}=-NR    ${enb}=2
    Log to Console    \nWait for SIB Type ${sibtype} (${celltype}) (enb ${enb})
    ${end_cell}    Convert To Integer    ${end_cell}
    ${start_cell}    Convert To Integer    ${start_cell}
    ${sib_status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    ${timeout}    15
    ...                                               Check SIB    start_cell=${start_cell}    end_cell=${end_cell}    active_cells=${active_cells}
    ...                                                            sibtype=${sibtype}    celltype=${celltype}    enb=${enb}
    FOR    ${cell}    IN RANGE    ${start_cell}    ${end_cell+1}    1
        ${cel_str}    Format String    {:0>2}    ${cell}
        Log to Console    ${SPACE}- Cell ${cel_str}: ${TC_SIB_CELL_${cell}}
    END
    Set Test Variable    $TC_SIB_STATUS    ${sib_status}
    IF    not ${sib_status}    Log     SIB check failed!    level=WARN
    Should be true    ${sib_status}    msg=SIB check failed!

Wait for Airphone Cell Setup
    [Arguments]    ${start_cell}=1    ${end_cell}=1    ${timeout}=5 mins    ${active_cells}=${TS_LIST_ALL}
    Log to Console    \nWait for Airphone Cell Setup
    ${end_cell}    Convert To Integer    ${end_cell}
    ${start_cell}    Convert To Integer    ${start_cell}
    ${ap_cell_status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    ${timeout}    15
    ...                                               Check for Airphone Cell Setup    start_cell=${start_cell}
    ...                                                                                end_cell=${end_cell}
    ...                                                                                active_cells=${active_cells}
    FOR    ${cell}    IN RANGE    ${start_cell}    ${end_cell+1}    1
        ${cel_str}    Format String    {:0>2}    ${cell}
        Log to Console    ${SPACE}- Cell ${cel_str}: ${TC_AP_CELL_${cell}}
    END
    Set Test Variable    $TC_AP_CELL_STATUS    ${ap_cell_status}
    IF    not ${ap_cell_status}    Log     AP Cell Setup check failed!    level=WARN
    Should be true    ${ap_cell_status}    msg=AP Cell Setup check failed!

Check for Airphone Cell Setup
    [Arguments]    ${start_cell}=1    ${end_cell}=1    ${active_cells}=${TS_LIST_ALL}
    wts_ue.Sim Log Set Flush
    FOR    ${cell}    IN RANGE    ${start_cell}    ${end_cell+1}    1
        ${cell_setup_ap}    Run Keyword And Return Status
        ...    sqd60_tools.Egate Console Log Should Match Regexp   Airphone. Cell Setup completed for .CELL_ID.${cell}.     flush=${False}
        Set Test Variable    ${TC_AP_CELL_${cell}}    ${cell_setup_ap}

        ${all_cell}    performance_verification.Is Item In List    ${cell}    ${active_cells}
        ${cell_included}    Evaluate    ${active_cells}==${TS_LIST_ALL} or ${all_cell}
        IF    "${TP.ASSERT_ONLY_AP_CELL_ON_ACTIVE_CELLS}"=="true" and not ${cell_included}
            Set Test Variable    ${TC_AP_CELL_${cell}}    ${cell_setup_ap} (Skipped!)
        ELSE
            Run Keyword And Continue On Failure    Should Be True    ${cell_setup_ap}    msg=Cell ${cell}: AP Cell Setup Not Completed!
        END
    END

Check SIB
    [Arguments]    ${start_cell}=1    ${end_cell}=1    ${active_cells}=${TS_LIST_ALL}    ${sibtype}=1    ${celltype}=-NR   ${enb}=2
    wts_ue.Sim Log Set Flush
    FOR    ${cell}    IN RANGE    ${start_cell}    ${end_cell+1}    1
        ${sib_found}    Run Keyword And Return Status    sqd60_tools.Egate Console Log Should Match Regexp
        ...    eNB ${enb} cell ${cell}. SystemInformationBlockType${sibtype}${celltype} updated    flush=${False}
        Set Test Variable    ${TC_SIB_CELL_${cell}}    ${sib_found}

        ${all_cell}    performance_verification.Is Item In List    ${cell}    ${active_cells}
        ${cell_included}    Evaluate    ${active_cells}==${TS_LIST_ALL} or ${all_cell}
        IF    "${TP.ASSERT_ONLY_SIB_ON_ACTIVE_CELLS}"=="true" and not ${cell_included}
            Set Test Variable    ${TC_SIB_CELL_${cell}}    ${sib_found} (Skipped!)
        ELSE
            Run Keyword And Continue On Failure    Should Be True    ${sib_found}    msg=Cell ${cell}: SIB Type${sibtype} not found!
        END
    END

Wait NG link
    [Arguments]    ${start_amf}    ${end_amf}    ${ip}=10.0.1.2    ${timeout}=5 mins
    ${start_amf}    Convert To Integer    ${start_amf}
    ${end_amf}      Convert To Integer    ${end_amf}

    ${ng_link}    Run Keyword And Return Status    Wait Until Keyword Succeeds    ${timeout}    15
    ...           Check for NG Link AMF    ${start_amf}    ${end_amf}    ${ip}

    FOR    ${amf}    IN RANGE    ${start_amf}    ${end_amf+1}    1
        ${amf_str}    Format String    {:0>2}    ${amf}
        Log to Console    ${SPACE}- AMF ${amf_str}: ${TC_AMF_${amf}}
    END
    Should be true    ${ng_link}    msg=NG Link check failed!

Check for NG Link AMF
    [Arguments]    ${start_amf}    ${end_amf}    ${ip}
    FOR    ${amf}    IN RANGE    ${start_amf}    ${end_amf+1}    1
        ${nglink_up}    Run Keyword And Return Status    Egate Console Log Should Match Regexp
        ...             AMF-${amf}: AMF - IP:${ip} NG link is Up
        Set Test Variable    ${TC_AMF_${amf}}    ${nglink_up}

        Run Keyword And Continue On Failure    Should Be True    ${nglink_up}    msg=AMF ${amf}: NG link not up
    END

Stop Traffic
    [Arguments]    ${ue_id}    ${pdu}=1    ${trf_id}=1
    IF    'DL' in '${TEST_NAME}' or "${TRAFFIC_DIRECTION}"=="dl" or "${TRAFFIC_DIRECTION}"=="both"
    ...               Stop Data Traffic in Egate    ue_id=${ue_id}    pdu=${pdu}    direction=dl    trf_id=${trf_id}

    IF    'UL' in '${TEST_NAME}' or "${TRAFFIC_DIRECTION}"=="ul" or "${TRAFFIC_DIRECTION}"=="both"
    ...               Stop Data Traffic in Egate    ue_id=${ue_id}    pdu=${pdu}    direction=ul    trf_id=${trf_id}

Detach UEs
    [Arguments]    ${delay}=10s
    Log to console    \nDetach UEs
    ${detach_start_time}=    perf_timer.Start

    Run Keyword And Continue On Failure    wts_ue.Send Egate Command And Verify Output
    ...   cmd=ue_deregister id=all ue_deregister_type=switch_off by=ue
    ...   timeout=300
    Sleep     ${delay}     reason=Wait for better failure cause, so that there is only one print
    Wait until keyword succeeds   10x   10s   Verify Total Number of Active UEs    expected=0    insert_db=${false}
    perf_timer.Stop    msg=Detach UEs:    start_time=${detach_start_time}

Update UE Capabilities for CB008246
    ${core_alias}    connect.Connect to Core
    ssh.execute    command=sed -n 's/UE_CAP=/UE_CAP_ORIG=/p' /opt/iphy/latest/capability.cfg    connection=${core_alias}
    ssh.execute    command=sed -n 's/UE_CAP_8246=/UE_CAP=/p' /opt/iphy/latest/capability.cfg    connection=${core_alias}

Restore UE Capabilities
    ${core_alias}    connect.Connect to Core
    ssh.execute    command=sed -n 's/UE_CAP_ORIG=/UE_CAP=/p' /opt/iphy/latest/capability.cfg    connection=${core_alias}
    ssh.execute    command=sed -n 's/UE_CAP=/UE_CAP_8246=/p' /opt/iphy/latest/capability.cfg    connection=${core_alias}

Create Lua files
    Run keyword    Create Lua ${SUITE METADATA["Duplex Mode Info"]}
    Create Lua TDD_FDD

Create Lua TDD
    Create Lua sansa_tdd
    Create Lua sansa_tdd_3_cell
    Create Lua sansa_tdd_4_cell
    Create Lua sansa_tdd_6_cell
    Create Lua sansa_tdd_8_cell
    Create Lua sansa_tdd_12_cell
    Create Lua sansa_tdd_1_cell_12_onair
    Create Lua sansa_tdd_1_cell_configured
    Create Lua sansa_tdd_6_cell_same_nrarfcn

Create Lua TDD_FDD
    Create Lua sansa_tdd_3_cell_fdd_6_cell

Create Lua FDD
    Create Lua sansa_fdd_1cell
    Create Lua sansa_fdd_3cell
    Create Lua sansa_fdd_4cell
    Create Lua sansa_fdd_6cell
    Create Lua sansa_fdd_12_cell
    Create Lua sansa_fdd_15_cell
    Create Lua sansa_fdd_24_cell
    Create Lua sansa_fdd_24_cell_6AMF
    IF    "ASOE" in "${TL_DATA['GNB_CU_TYPE']}"   Create Lua sansa_fdd_asoe

Create Lua sansa_fdd_1cell
    ${arfcn_table}=  Catenate  {"381000:397000","381000:397000","381000:397000","135760:126380","135760:126380","135760:126380",
    ...                         "381000:397000","381000:397000","381000:397000","135760:126380","135760:126380","135760:126380"}
    Create Lua From Template    ${CURDIR}/egate/sansa_fdd_template.lua    sansa_fdd_1cell.lua
    ...           NUMBER_OF_CELLS=12
    ...           UE_COUNT_ON_CELL=100
    ...           SA_CELLID=FIRST_CELL_ID
    ...           NSA_CELLID=FIRST_CELL_ID
    ...           END_UE_SA_CELL=1 * UE_COUNT_ON_CELL
    ...           NR_ARFCN_TABLE=${arfcn_table}

Create Lua sansa_fdd_3cell
    ${pci_table}=    Set Variable  { "16:2","17:0","17:1"}
    ${arfcn_table}=   Set Variable    {"349500:368500","349500:368500","349500:368500"}
    Create Lua From Template    ${CURDIR}/egate/sansa_fdd_template.lua    sansa_fdd_3cell.lua
    ...           NUMBER_OF_CELLS=3
    ...           UE_COUNT_ON_CELL=200
    ...           GSCN=4556
    ...           NR_ARFCN_TABLE=${arfcn_table}
    ...           PCI_TABLE=${pci_table}

Create Lua sansa_fdd_4cell
    ${pci_table}=    Set Variable  { "16:2","17:0","17:1","17:2"}
    ${arfcn_table}=   Set Variable    {"349500:368500","349500:368500","349500:368500","349500:368500"}
    Create Lua From Template    ${CURDIR}/egate/sansa_fdd_template.lua    sansa_fdd_4cell.lua
    ...           NUMBER_OF_CELLS=4
    ...           UE_COUNT_ON_CELL=200
    ...           GSCN=4604
    ...           NR_ARFCN_TABLE=${arfcn_table}
    ...           PCI_TABLE=${pci_table}

Create Lua sansa_fdd_6cell
    ${pci_table}=    Set Variable  { "16:2","17:0","17:1","17:2","18:0","18:1"}
    ${arfcn_table}=   Set Variable    {"349500:368500","349500:368500","349500:368500","349500:368500","349500:368500","349500:368500"}
    Create Lua From Template    ${CURDIR}/egate/sansa_fdd_template.lua    sansa_fdd_6cell.lua
    ...           NUMBER_OF_CELLS=6
    ...           UE_COUNT_ON_CELL=200
    ...           GSCN=4604
    ...           NR_ARFCN_TABLE=${arfcn_table}
    ...           PCI_TABLE=${pci_table}

Create Lua sansa_fdd_12_cell
    Create Lua From Template    ${CURDIR}/egate/sansa_fdd_template.lua    sansa_fdd_12cell.lua
    ...           NUMBER_OF_CELLS=12
    ...           UE_COUNT_ON_CELL=200
    ...           UE_GROUP_COUNT=NUMBER_OF_CELLS

Create Lua sansa_fdd_15_cell
    ${pci_table}=    Set Variable  {"16:2","17:0","17:1","17:2","18:0","18:1","18:2","19:0","19:1","19:2","20:0","20:1","20:2","21:0","21:1"}
    ${arfcn_table}=  Catenate  {"376000:392000","376000:392000","167800:176800","376000:392000","167800:176800","376000:392000","376000:392000",
    ...              "376000:392000","167800:176800","376000:392000","167800:176800","376000:392000","376000:392000","167800:176800","376000:392000"}
    Create Lua From Template    ${CURDIR}/egate/sansa_fdd_template.lua    sansa_fdd_15cell.lua
    ...           NUMBER_OF_CELLS=15
    ...           UE_COUNT_ON_CELL=230
    ...           UE_GROUP_COUNT=NUMBER_OF_CELLS
    ...           PCI_TABLE=${pci_table}
    ...           NR_ARFCN_TABLE=${arfcn_table}

Create Lua sansa_fdd_24_cell
    ${pci_table}=    Catenate  {"16:2","17:0","17:1","17:2","18:0","18:1","18:2","19:0","19:1","19:2","20:0","20:1","20:2","21:0","21:1","21:2",
    ...                         "22:0","22:1","22:2","23:0","23:1","23:2","24:0","24:1"}
    ${arfcn_table}=  Catenate  {"135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380",
    ...                         "135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380",
    ...                         "135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380",
    ...                         "135760:126380","135760:126380","135760:126380"}
    Create Lua From Template    ${CURDIR}/egate/sansa_fdd_template.lua    sansa_fdd_24cell.lua
    ...           NUMBER_OF_CELLS=24
    ...           UE_COUNT_ON_CELL=200
    ...           UE_GROUP_COUNT=NUMBER_OF_CELLS
    ...           PCI_TABLE=${pci_table}
    ...           NR_ARFCN_TABLE=${arfcn_table}

Create Lua sansa_fdd_24_cell_6AMF
    ${pci_table}=    Catenate  {"16:2","17:0","17:1","17:2","18:0","18:1","18:2","19:0","19:1","19:2","20:0","20:1","20:2","21:0","21:1","21:2",
    ...                         "22:0","22:1","22:2","23:0","23:1","23:2","24:0","24:1"}
    ${arfcn_table}=  Catenate  {"135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380",
    ...                         "135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380",
    ...                         "135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380",
    ...                         "135760:126380","135760:126380","135760:126380"}
    performance_egate.Create Lua From Template    ${CURDIR}/egate/sansa_fdd_template.lua    sansa_fdd_24cell_6amf.lua
    ...           NUMBER_OF_CELLS=24
    ...           UE_COUNT_ON_CELL=200
    ...           AMF_COUNT=6
    ...           UE_GROUP_COUNT=NUMBER_OF_CELLS
    ...           PCI_TABLE=${pci_table}
    ...           NR_ARFCN_TABLE=${arfcn_table}


Create Lua sansa_fdd_asoe
    Create Lua sansa_fdd_asoe_1cell
    Create Lua sansa_fdd_asoe_8_cell
    Create Lua sansa_fdd_asoe_16_cell
    Create Lua sansa_fdd_asoe_16_cell_6amf

Create Lua sansa_fdd_asoe_1cell
    Create Lua From Template    ${CURDIR}/egate/sansa_fdd_template.lua    sansa_fdd_asoe_1cell.lua
    ...           NUMBER_OF_CELLS=6
    ...           SA_CELLID=FIRST_CELL_ID

Create Lua sansa_fdd_asoe_16_cell
    ${pci_table}=    Catenate  {"16:2","17:0","17:1","17:2","18:0","18:1","18:2","19:0","19:1","19:2","20:0","20:1","20:2","21:0","21:1","21:2"}
    ${arfcn_table}=  Catenate  {"135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380",
    ...                         "135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380",
    ...                         "135760:126380","135760:126380"}
    Create Lua From Template    ${CURDIR}/egate/sansa_fdd_template.lua    sansa_fdd_asoe_16cell.lua
    ...           NUMBER_OF_CELLS=16
    ...           UE_COUNT_ON_CELL=200
    ...           UE_GROUP_COUNT=NUMBER_OF_CELLS
    ...           PCI_TABLE=${pci_table}
    ...           NR_ARFCN_TABLE=${arfcn_table}

Create Lua sansa_fdd_asoe_16_cell_6amf
    ${pci_table}=    Catenate  {"16:2","17:0","17:1","17:2","18:0","18:1","18:2","19:0","19:1","19:2","20:0","20:1","20:2","21:0","21:1","21:2"}
    ${arfcn_table}=  Catenate  {"135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380",
    ...                         "135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380",
    ...                         "135760:126380","135760:126380"}
    Create Lua From Template    ${CURDIR}/egate/sansa_fdd_template.lua    sansa_fdd_asoe_16cell.lua
    ...           NUMBER_OF_CELLS=16
    ...           UE_COUNT_ON_CELL=200
    ...           AMF_COUNT=6
    ...           UE_GROUP_COUNT=NUMBER_OF_CELLS
    ...           PCI_TABLE=${pci_table}
    ...           NR_ARFCN_TABLE=${arfcn_table}

Create Lua sansa_fdd_asoe_8_cell
    ${pci_table}=    Catenate  {"16:2","17:0","17:1","17:2","18:0","18:1","18:2","19:0"}
    ${arfcn_table}=  Catenate  {"135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380","135760:126380",
    ...                         "135760:126380"}
    Create Lua From Template    ${CURDIR}/egate/sansa_fdd_template.lua    sansa_fdd_asoe_8cell.lua
    ...           NUMBER_OF_CELLS=8
    ...           UE_COUNT_ON_CELL=200
    ...           UE_GROUP_COUNT=NUMBER_OF_CELLS
    ...           PCI_TABLE=${pci_table}
    ...           NR_ARFCN_TABLE=${arfcn_table}


Create Lua sansa_tdd
    Create Lua From Template    ${CURDIR}/egate/sansa_tdd_template.lua    sansa_tdd_1cell.lua
    ...           NUMBER_OF_CELLS=6
    ...           UE_COUNT_ON_CELL=100
    ...           UE_GROUP_COUNT=1
    ...           SA_CELLID=FIRST_CELL_ID
    ...           NSA_CELLID=FIRST_CELL_ID
    ...           END_UE_SA_CELL=1 * UE_COUNT_ON_CELL
    ...           END_UE_NSA_CELL=1 * UE_COUNT_ON_CELL
    ...           PERFORMANCE_SRS_ENABLED_CELLS={1,2,3,4,5,6}

Create Lua sansa_tdd_3_cell
    Create Lua From Template    ${CURDIR}/egate/sansa_tdd_template.lua    sansa_tdd_3cell.lua
    ...           NUMBER_OF_CELLS=3
    ...           UE_COUNT_ON_CELL=100
    ...           PERFORMANCE_SRS_ENABLED_CELLS={1,2,3}

Create Lua sansa_tdd_4_cell
    Create Lua From Template    ${CURDIR}/egate/sansa_tdd_template.lua    sansa_tdd_4cell.lua
    ...           NUMBER_OF_CELLS=4
    ...           UE_COUNT_ON_CELL=100
    ...           PERFORMANCE_SRS_ENABLED_CELLS={1,2,3,4}

Create Lua sansa_tdd_6_cell
    Create Lua From Template    ${CURDIR}/egate/sansa_tdd_template.lua    sansa_tdd_6cell.lua
    ...           NUMBER_OF_CELLS=6
    ...           UE_COUNT_ON_CELL=1500
    ...           PERFORMANCE_SRS_ENABLED_CELLS={1,2,3,4,5,6}

Create Lua sansa_tdd_6_cell_same_nrarfcn
    Create Lua From Template    ${CURDIR}/egate/sansa_tdd_template.lua    sansa_tdd_6cell_same_nrarfcn.lua
    ...           NUMBER_OF_CELLS=6
    ...           UE_COUNT_ON_CELL=200
    ...           PERFORMANCE_SRS_ENABLED_CELLS={1,2,3,4,5,6}
    ...           NR_ARFCN_TABLE={"636666:636666","636666:636666","636666:636666","636666:636666","636666:636666","636666:636666"}

Create Lua sansa_tdd_8_cell
    Create Lua From Template    ${CURDIR}/egate/sansa_tdd_template.lua    sansa_tdd_8cell.lua
    ...           NUMBER_OF_CELLS=8
    ...           PERFORMANCE_SRS_ENABLED_CELLS={1,2,3,4,5,6,7,8}

Create Lua sansa_tdd_12_cell
    ${nr_arfcn_table}=    Catenate    SEPARATOR=    {"636666:636666","643330:643330","649994:649994","635600:635600","640000:640000","649200:649200",
    ...                                              "649200:649200","636666:636666","643330:643330","649994:649994","635600:635600","640000:640000"
    ...                                             }
    Create Lua From Template    ${CURDIR}/egate/sansa_tdd_template.lua    sansa_tdd_12cell.lua
    ...           NUMBER_OF_CELLS=12
    ...           UE_COUNT_ON_CELL=100
    ...           PERFORMANCE_SRS_ENABLED_CELLS={1,2,3,4,5,6,7,8,9,10,11,12}
    ...           NR_ARFCN_TABLE=${nr_arfcn_table}

Create Lua sansa_tdd_1_cell_12_onair
    Create Lua From Template    ${CURDIR}/egate/sansa_tdd_template.lua    sansa_tdd_1_cell_12_onair.lua
    ...           NUMBER_OF_CELLS=12
    ...           UE_COUNT_ON_CELL=100
    ...           SA_CELLID=FIRST_CELL_ID
    ...           NSA_CELLID=FIRST_CELL_ID
    ...           END_UE_SA_CELL=1 * UE_COUNT_ON_CELL
    ...           END_UE_NSA_CELL=1 * UE_COUNT_ON_CELL
    ...           PERFORMANCE_SRS_ENABLED_CELLS={1,2,3,4,5,6,7,8,9,10,11,12}

Create Lua sansa_tdd_1_cell_configured
    Create Lua From Template    ${CURDIR}/egate/sansa_tdd_template.lua    sansa_tdd_1_cell_configured.lua
    ...           NUMBER_OF_CELLS=1
    ...           UEC_COUNT=1
    ...           UE_COUNT_ON_CELL=1500
    ...           UE_GROUP_COUNT=1
    ...           SA_CELLID=FIRST_CELL_ID
    ...           NSA_CELLID=FIRST_CELL_ID
    ...           SEQ_GROUP_COUNT=40
    ...           END_UE_SA_CELL=1 * UE_COUNT_ON_CELL
    ...           END_UE_NSA_CELL=1 * UE_COUNT_ON_CELL
    ...           PERFORMANCE_SRS_ENABLED_CELLS={1}

Create Lua sansa_tdd_3_cell_fdd_6_cell
    ${nr_arfcn_table}=    Catenate    SEPARATOR=    {"636666:636666","636666:636666","636666:636666","145600:156600","145600:156600","145600:156600",
    ...                                                "145600:156600","145600:156600","145600:156600","145600:156600","145600:156600","640000:640000"
    ...                                             }
    Create Lua From Template    ${CURDIR}/egate/sansa_tdd_template.lua    sansa_tdd_3_cell_fdd_6_cell.lua
    ...           NUMBER_OF_CELLS=9
    ...           GSCN_TDD=7854
    ...           GSCN_FDD=1956
    ...           NR_ARFCN_TABLE=${nr_arfcn_table}

Create Lua From Template
    [Arguments]    ${lua_template_path}    ${result_lua}   &{params}

    ${final_lua}       Set Variable     /opt/iphy/latest/${result_lua}
    ${core_alias}    connect.Connect to Core

    Log    \nCreating file: ${final_lua} from ${lua_template_path}        console=${P_console}
    ssh.execute    command=cp ${lua_template_path} ${final_lua}    connection=${core_alias}

    FOR   ${key}   IN   @{params}
       ${value}   Collections.Get From Dictionary   ${params}   ${key}
       ${cmd}    Catenate    sed -iE 's@\\(^\\s*${key}\\s*=\\)\\s*.*$@\\1 ${value}@g' ${final_lua}
       ssh.execute    command=${cmd}    connection=${core_alias}
       Log        ${SPACE}- ${result_lua}: ${key} = ${value}    console=${P_console}
    END
    RETURN    ${final_lua}

Copy egate Scripts to wts folder
    # Copy Files    ${CURDIR}/egate/*                /opt/iphy/latest/
    bash_helper.run_bash_subprocess    cp -r ${CURDIR}/egate/* /opt/iphy/latest/

Copy specific egate Scripts to wts folder
    [Arguments]    ${feature}    ${file}=*
    bash_helper.run_bash_subprocess    cp -r ${CURDIR}/egate/${feature}/${file} /opt/iphy/latest/

Setup Bearer Stats Egate alias
    ${egate_connection}=  bearer_stats_fast.Setup Egate Connection    # bearer stats setup
    Set Test Variable  ${egate_connection}


Collect Bearer Stats
    [Arguments]    ${cell_ue_mapping}    ${iterations}=${10}    ${subfolder}=${empty}
    Log to console    Collect Bearer Stats
    # Setup Bearer Stats Egate alias    # tmp to fix connection issue?
    ${dfs}=  Create List
    ${ues}=  Get Active Ues Comma Separated    chunk_size=${50}    cell_ue_mapping=${cell_ue_mapping}
    FOR    ${i}    IN RANGE    1    ${iterations}
        ${df}=  bearer_stats_fast.Collect Stats For All Ues  ues=${ues}  egate_object=${egate_connection}
        Append To List    ${dfs}  ${df}
    END
    ${pkl_path}  ${csv_path}  bearer_stats_fast.Concat Dataframes    ${dfs}
    ...    pkl_path=${P_resultTestDir}/${subfolder}/bearer_stats.pkl
    ...    csv_path=${P_resultTestDir}/${subfolder}/bearer_stats.csv
    perf_log_collection.Queue Logs To Turandot    ${pkl_path}    subfolder=${subfolder}
    Log    pkl Path = ${pkl_path}     console=${P_console}
    perf_log_collection.Queue Logs To Turandot    ${csv_path}    subfolder=${subfolder}
    Log    csv Path = ${csv_path}     console=${P_console}


Save Egate Logs to Turandot
    [Arguments]    ${subfolder}=${empty}
    ${_}    ${egate_log}        Run Keyword And Ignore Error    wts_ue.Save Current Egate Console Log
    perf_log_collection.Queue Logs To Turandot    ${tl.core.dir_path}/egate_console.*    archive_name=egate_console    tar=${True}
    ...                                           subfolder=${subfolder}
