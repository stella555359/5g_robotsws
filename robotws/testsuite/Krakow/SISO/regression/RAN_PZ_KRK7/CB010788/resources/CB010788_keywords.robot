*** Settings ***
Documentation
...    Author:          Mateusz Matusik, mateusz.matusik@nokia.com
...    Maintainer:      Mateusz Matusik, mateusz.matusik@nokia.com

Library    ../../CB012194/resources/keywords.py    WITH NAME    CB012194_keywords
Library    json
Library    taf.transport.ssh    WITH NAME    SSH
Library    taf.sbts.oam.coam.admin   WITH NAME   SbtsAdmin
Library    taf.rfrl.bts.devices.du.commissioning.GnbCommissioning          WITH NAME   gnb_scf
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations       WITH NAME   gnb_cell
Resource   common_keywords.robot

*** Variables ***
&{AHFII_credentials}=    username=serviceuser   password=Pl(FzaYj5~c5;q
&{MAJOR}=                4698=0x70 DATA 0x80    4699=0x70 DATA 0x04    4700=0x70 DATA 0x01    4701=0x71 DATA 0x40
&{MINOR}=                4698=0x74 DATA 0x80    4699=0x74 DATA 0x04    4700=0x74 DATA 0x01    4701=0x75 DATA 0x40
&{FRMON_data}=           MAJOR=&{MAJOR}    MINOR=&{MINOR}

*** Keywords ***
Prepare basic config path
    ${SW}=    Get gNB Sw Version
    ${branch}=    Convert Sw Version    ${SW}
    ${base_scfc}=     Convert To String    commissionings/Krakow/7_7_UTE5GCLOUDT8SK030/${branch}/CB010788_GNB0_SCF.xml
    ${base_scfc}=     Set Suite Variable    ${base_scfc}

TC2 Test Setup
    gnb_scf.perform_bts_full_commissioning    ${base_scfc}
    gnb_cell.wait_for_all_cells_to_be_onair    timeout=540

TC2 Test Teardown
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Metadata to Report for All BTSs

TC3 Test Setup
    gnb_scf.perform_bts_full_commissioning    ${base_scfc}
    Wait Until Keyword Succeeds    1 min    10 sec    gnb_cell.wait_for_all_cells_to_be_onair    timeout=540
#    Set FEATCADM.actTransceiverAlarmMonitoring to Transceiver Alarms

TC3 Test Teardown
    Cancel SFP override memory     port_id_on_ru=1
    Terminate SFP Info Agent
    Set FEATCADM.actTransceiverAlarmMonitoring to Transceiver Alarms
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Metadata to Report for All BTSs

TC5 Test Setup
    gnb_scf.perform_bts_full_commissioning    ${base_scfc}
    Wait Until Keyword Succeeds    1 min    10 sec    gnb_cell.wait_for_all_cells_to_be_onair    timeout=540
    SSH.Connect to    ${BTS_HOST_IP}    ${bts_username}    ${bts_password}                  alias=gNB
    SSH.Connect to    asp-1b            ${bts_username}    ${bts_password}    proxy=gNB     alias=gNB-asp

TC5 Test Teardown
    SSH.Disconnect    gNB
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Metadata to Report for All BTSs

Check if FID is not present
    [Arguments]    ${fault_id}
    ${sbts_alarms_list}=    SbtsAdmin.Get Active Alarms
    Verify if alarm is not active    ${fault_id}    ${sbts_alarms_list}

Check if FID is present
    [Arguments]    ${fault_id}
    ${sbts_alarms_list}=    SbtsAdmin.Get Active Alarms
    Verify if alarm is active    ${fault_id}    ${sbts_alarms_list}

Verify that fault ${fault_id} is not present in alarm list
    Wait Until Keyword Succeeds    3 min    45 sec    Reliable not active alarm verification    ${fault_id}

Verify that fault ${fault_id} is present in alarm list
    Wait Until Keyword Succeeds    3 min    45 sec    Reliable active alarm verification    ${fault_id}

Verify that MAJOR fault ${fault_id} is not present in alarm list
    Verify that fault ${fault_id} is not present in alarm list

Verify that MINOR fault ${fault_id} is not present in alarm list
    Verify that fault ${fault_id} is not present in alarm list

Verify that MAJOR fault ${fault_id} is present in alarm list
    Verify that fault ${fault_id} is present in alarm list

Verify that MINOR fault ${fault_id} is present in alarm list
    Verify that fault ${fault_id} is present in alarm list

Reliable active alarm verification
    [Arguments]    ${fault_id}
    SbtsAdmin.Connect To
    Check if FID is present    ${fault_id}
    SbtsAdmin.Teardown

Reliable not active alarm verification
    [Arguments]    ${fault_id}
    SbtsAdmin.Connect To
    Check if FID is not present    ${fault_id}
    SbtsAdmin.Teardown

Verify that faults 4698,4699,4700,4701 are not present in alarm list
    SbtsAdmin.Connect To
    Wait Until Keyword Succeeds    3 min    45 sec    Check if FID is not present    4698,4699,4700,4701
    SbtsAdmin.Teardown

Reconfigure ALARMSUPP object
    [Arguments]    ${json_delta}
    ${json}=    Adjust MRBTS ID in delta file    ${json_delta}
    Wait Until Keyword Succeeds    2 min    50 sec    Perform Delta Commissioning On gNB    delta=${json}    timeout=${600}

Perform full commissionning to reconfigure ALARMSUPP object
    [Arguments]    ${full_scfc}
    gnb_scf.perform_bts_full_commissioning    ${full_scfc}
    gnb_cell.wait_for_all_cells_to_be_onair    timeout=540

Delete NOTE connected to CNI-127210
    ${json}=    Adjust MRBTS ID in delta file    ${delete_notes}
    Wait Until Keyword Succeeds    2 min    50 sec    Perform Delta Commissioning On gNB    delta=${json}    timeout=${600}

Trigger fault 4710 by enabling SyncE Holdover feature
    ${json}=    Adjust MRBTS ID in delta file    ${TC2_holdover_enable}
    Wait Until Keyword Succeeds    2 min    50 sec    Perform Delta Commissioning On gNB    delta=${json}    timeout=${600}

Set FEATCADM.actTransceiverAlarmMonitoring to Off
    ${json}=    Adjust MRBTS ID in delta file    ${TC3_disable_actTransceiverAlarmMonitoring}
    Wait Until Keyword Succeeds    2 min    50 sec    Perform Delta Commissioning On gNB    delta=${json}    timeout=${600}

Set FEATCADM.actTransceiverAlarmMonitoring to Transceiver Alarms
    ${json}=    Adjust MRBTS ID in delta file    ${TC3_enable_actTransceiverAlarmMonitoring}
    Wait Until Keyword Succeeds    2 min    50 sec    Perform Delta Commissioning On gNB    delta=${json}    timeout=${600}

Setup connection to RFMON interface
    [Arguments]     ${rfsw_credentials}
    Set Test Variable   ${rfsw_credentials}   ${rfsw_credentials}
    Log to console    Setting UP FRMON Interface Connection
    Create SFP Info Agent

Reconnect FRMON interface
    Create SFP Info Agent

Disable FRMON interface
    Terminate SFP Info Agent
    forget device handler    GNB0_DU0_RU0_FACTORY

Trigger fault 4698 after gNB reset
    Reconnect FRMON interface
    Trigger MINOR fault 4698 with FRMON interface

Trigger ${alarm_severity} fault ${fault_id} with FRMON interface
    Log to console    Triggering ${alarm_severity} fault ${fault_id} on RU
    ${error_command}=    Set variable   ${FRMON_data['${alarm_severity}']['${fault_id}']}
    SFP Override Memory     port_id_on_ru=1    action=PAGE PAGE_1    fault=${error_command}

Disable ${alarm_severity} fault ${fault_id} with FRMON interface
    Log to console    Disabling ${alarm_severity} fault ${fault_id} on RU
    SFP Override Memory     port_id_on_ru=1    action=PAGE PAGE_1    fault=0x71 DATA 0x40
    Verify that fault ${fault_id} is not present in alarm list

Adjust MRBTS ID in delta file
    [Arguments]    ${json_file_path}
    ${json}=    Get File   ${test_dir}/${json_file_path}
    ${json}=    Replace String    ${json}    MRBTS-1     MRBTS-${MRBTS_ID}
    ${json}=    json.loads    ${json}
    [Return]    ${json}

Reset gNB and wait for cells to be onAir
    Reset gNB
    Wait Until Keyword Succeeds    1 min    10 sec    gnb_cell.wait_for_all_cells_to_be_onair    timeout=540

Trigger fault 4694
    ## find right BBMOD before test
    ## chk -v topo
    ## bmutool -i
    SSH.send_command       command=devmem 0x864000820048 32 0x10    connection=gNB-asp
