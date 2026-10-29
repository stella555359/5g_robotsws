*** Settings ***
Documentation
...            author:       Hubert Chrzan, hubert.chrzan@nokia.com
...            maintainer:   Hubert Chrzan, hubert.chrzan@nokia.com

Library      String
Library      OperatingSystem
Library      taf.rfrl.bts.devices.du.cell_operations.GenericCellOperations           WITH NAME    Cells
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                   WITH NAME    Du
Library      taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations                   WITH NAME    Radio
Resource     testsuite/Krakow/resources/former_l3_sw2/main_cls.robot
Variables    status_regex.py

*** Keywords ***
Check And Stop Egate And Edaemon Then Reboot If Necessary
    [Documentation]            Checks if egate or edaemon process is running. If any is running, stops both processes and reboots AirPhone.
    ${edaemon_stdout}          Run Process    pgrep    'edaemon'    shell=${True}
    ${edaemon_running}         Set Variable If    ${edaemon_stdout.rc} == 0    ${True}    ${False}
    ${egate_stdout}            Run Process    pgrep    'egate'    shell=${True}
    ${egate_running}           Set Variable If    ${egate_stdout.rc} == 0    ${True}    ${False}
    ${any_process_running}     Evaluate    ${edaemon_running} or ${egate_running}
    ${console_log}             Set Variable If    ${any_process_running}
    ...                        INF: Egate or Edaemon process is running on host! Executing stop and reboot commands.
    ...                        INF: Neither Egate nor Edaemon process is running on host.
    Log To Console             ${console_log}
    IF    ${any_process_running}
        Stop Edaemon and Egate processes
        Reboot GNB and AP
    END
    [Return]    ${any_process_running}

Stop Edaemon and Egate processes
    [Documentation]   Kill edaemon and egate if already running.
    Log To Console    Stopping Edaemon/Egate process
    Run Process       sudo pkill -9 edaemon    shell=${True}
    Run Process       pkill -9 egate    shell=${True}

Wait for gNB To Be Ready
    Log To Console                  Check if all modules are ready
    Wait Until Keyword Succeeds     15min     30sec     Du.verify_bts_states    procedural_state=${bts_up_state}
    Wait Until Keyword Succeeds     15min     30sec     Radio.verify_all_radio_units_are_online
    Wait Until Keyword Succeeds     15min     30sec     Cells.verify_all_cells_statuses    procedural_status=${cell_state}

Check GNB and AP Backhaul Links APs
    [Arguments]    ${check_ap_bh_ip2}=${False}
    [Documentation]    Checks ping to GNB and AP Backhaul.
    ...                Optionally checks a second AP Backhaul if ${check_ap_bh_ip2} is True.
    ${gnb_bh_ip}    Set Variable    10.0.1.2
    ${ap_bh_ip}     Set Variable    10.0.2.80
    ${ap_bh_ip2}    Set Variable    10.0.2.90
    Log to Console                 Waiting for GNB backhaul link...    no_newline=${True}
    Wait Until Process Succeeds    ping    -c    1    ${gnb_bh_ip}    timeout=120s
    ...                            msg=Timeout waiting for ping to GNB backhaul (${gnb_bh_ip}).
    Log To Console                 OK
    Log to Console                 Waiting for AP1 backhaul link...    no_newline=${True}
    Wait Until Process Succeeds    ping    -c    1    ${ap_bh_ip}    timeout=120s
    ...                            msg=Timeout waiting for ping to AP1 backhaul (${ap_bh_ip}).
    Log To Console                 OK
    IF    ${check_ap_bh_ip2}
        Log to Console                 Waiting for AP2 backhaul link...    no_newline=${True}
        Wait Until Process Succeeds    ping    -c    1    ${ap_bh_ip2}    timeout=120s
        ...                            msg=Timeout waiting for ping to AP2 backhaul (${ap_bh_ip2}).
        Log to Console                 OK
    END
