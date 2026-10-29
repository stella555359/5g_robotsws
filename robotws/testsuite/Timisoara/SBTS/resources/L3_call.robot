*** Settings ***
#Resource  taf/rfrl/l3_call/call_manager.robot
Library  taf.ue  WITH NAME  ue
Library  taf.hw.rf_attenuator   WITH NAME  attenuator
Library  DateTime
Library  tshark_pcap.py
Library  uuf4all_attach_test.py
#Resource  common.robot

Documentation
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  10.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-92 - add new KWs for attenuator and remote call
...  16.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-94 - add new KW dedicated for Askey
...  20.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-152 - Add possibility to remote call on TL:101035/10814
...  06.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-198 - Add possibility to remote call on TL:101046/10813
...  24.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-305 - Add Xiaomi 12 support
...  07.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-302 - add new KW's "Call For CB008745 LTE", "Start UE DL/UL traffic"
...  09.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-280 - add KWs "Execute Command On UE PC", "Get UE PC Data", "Get YAML Capabilities",
...                                                                 "Airplane Mode On/Off"
...  20.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-329 - add new KW "Get Value From PCAP"
...  08.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-434 - add new KW "Reboot And Open Diagnostic Ports"
...  08.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-408 - Add possibility to remote call on TL:10811, new KW Verify 5G SA Attach
...  08.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-445 - enb10811 added to KW Call For CB008745 LTE
...  26.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-458 - new KW Cell baring for CB008745 and modification of Check attach condition for SA
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - new KW Teardown if call failed
...  07.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-476 - new KW Cell barring for CB008745 LTE
...  07.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-490 - Added enb55201 to L3 call and Call for CB008745 KWs
...  15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-489 - New KWs Unbarring all cells plus NR/LTE variants
...  14.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-489 - Add FID:49 to allowed during L3 call; unblock all cells in teardown
...  26.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-553 - Add enb5098/10810 to KW L3 call
...  xx.xx.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Variables ***
#wireshark filter syntax
${SgNBAdditionRequest}             x2ap.SgNBAdditionRequest_element
${SgNBReconfigurationComplete}     x2ap.SgNBReconfigurationComplete_element
${SgNBAdditionRequestAcknowledge}  x2ap.SgNBAdditionRequestAcknowledge_element
${UEContextRelease}                x2ap.UEContextRelease_element
${UEContextSetupRequest}           f1ap.UEContextSetupRequest_element
${InitialULRRCMessageTransfer}     f1ap.InitialULRRCMessageTransfer_element

#wireshark search filed
${physCellId}                      nr-rrc.physCellId
${measQuantityResults.rsrp}        nr-rrc.measQuantityResults.rsrp
${nRCellIdentity}                  f1ap.nRCellIdentity


*** Keywords ***
##################################
### Remote calls - PowerSaving ###
##################################

Set attenuator value on all ports
    [Documentation]  This keyword set expected attenuation value on all ports, as argument need to set max
    ...  quantity of ports
    [Arguments]  ${set_value_db}

	FOR  ${i}  IN  @{att_port_numbers}
		attenuator.set_attenuation  value=${set_value_db}  port=${i}
		${read_value_db}  attenuator.read_attenuation  port=${i}
		Wait Until Keyword Succeeds  3x  200ms  Should Be Equal  ${read_value_db}  ${set_value_db}
	END


Adjust attenuation value for port
    [Documentation]  This keyword set expected attenuation value on defined port
    [Arguments]  ${set_value_db}  ${port}

    attenuator.set_attenuation  value=${set_value_db}  port=${port}
    ${read_value_db}  attenuator.read_attenuation  port=${port}
    Wait Until Keyword Succeeds  3x  200ms  Should Be Equal  ${read_value_db}  ${set_value_db}


Check Attach Condition
    [Documentation]  In case attach failed, depends on condition KW tries to make recovery action
    ...  by airplane mode on/off or ue reboot.
    [Arguments]  ${attach_condition}

    ${ue_eurtra_cell_id}  ${ue_cell_pci}  ${attach_to_enb}  ${attached_to_nr_state}  Get Info About Attached Cell
    IF  '${attach_condition}'=='True' and '${attached_to_nr_state}'=='5G_SA'
        Log to console  UE Attached To SA:${attached_to_nr_state}
    ELSE IF  '${attach_condition}'=='True' and '${attach_to_enb}'=='${MRBTS_ID}'    #MRBTS_ID podmiana tl.enbs[0].instance_id}
        Log to console  Attach Condition Met
    ELSE IF  '${attach_condition}'=='True' and '${attach_to_enb}'!='${MRBTS_ID}'
        Log to console  UE Attached To Wrong TL:'${attach_to_enb}
        ue.Stop Using UE  ${ue}
        Airplane Mode On/Off
        Attach UE
        Get Info About Attached Cell
        Should Be True  '${attach_to_enb}'=='${MRBTS_ID}'
    ELSE IF  '${attach_condition}'=='False'
        Reboot UE  120
        ue.Stop Using UE  ${ue}
        Attach UE
        Get Info About Attached Cell
        Should Be True  '${attach_to_enb}'=='${MRBTS_ID}'
    END


Get Info About Attached Cell
    ${ue_eurtra_cell_id}  ue.Get Ue Info  ${ue}  CELL_ID
    ${ue_cell_pci}  ue.Get Ue Info  ${ue}  PCI
    ${attach_to_enb}  ue.Get Ue Info  ${ue}  ENB_ID
    ${attached_to_nr_state}  ue.Get Ue Info  ${ue}  NR_STATE
    Set Test Variable  ${ue_eurtra_cell_id}
    Set Test Variable  ${ue_cell_pci}
    Set Test Variable  ${attach_to_enb}
    Set Test Variable  ${attached_to_nr_state}
    Log to console  UE Attached To Cell Id: ${ue_cell_pci} Eutra Id: ${ue_eurtra_cell_id} ENB: ${attach_to_enb}

    RETURN  ${ue_eurtra_cell_id}  ${ue_cell_pci}  ${attach_to_enb}  ${attached_to_nr_state}

Start UE Traffic T&T
    [Arguments]  ${expected_pci}  ${NR_call}  ${dt_name_1}=DT_UL  ${dt_name_2}=DT_DL  ${tput_ul}=300  ${tput_dl}=300  ${duration}=2
    ...  ${5G_type}=NSA  ${ue_id}=0

#    Start tracing on SMOD
    ${attach_condition}  Attach UE  ${ue_id}
    Check Attach Condition  ${attach_condition}
    IF  '${NR_call}'=='${true}' and '${5G_type}'=='NSA'  Wait Until Keyword Succeeds  3x  1min  Verify 5G NSA Attach  ${ue}  ${expected_pci}
    IF  '${NR_call}'=='${true}' and '${5G_type}'=='SA'  Wait Until Keyword Succeeds  3x  1min  Verify 5G SA Attach  ${ue}  ${expected_pci}
    IF  '${NR_call}'=='${false}'  Wait Until Keyword Succeeds  3x  1min  Verify LTE Attach  ${ue}  ${expected_pci}
    ue.Start Data Transfer  ${dt_name_1}  ${ue}  ul  duration=10s  throughput=${tput_ul}Mbits/sec  protocol=udp  packet=1400
	ue.Start Data Transfer  ${dt_name_2}  ${ue}  dl  duration=10s  throughput=${tput_dl}Mbits/sec  protocol=udp  packet=1400
	${duration}  Evaluate  ${duration} - 1
	Sleep  ${duration}s  reason=Wait for throughput stabilization
    ue.Check Data Transfer Is Alive  ${dt_name_1}
    ue.Check Data Transfer Is Alive  ${dt_name_2}
	Sleep  1s
    Check Average Tput  direction=ul  dt_name=${dt_name_1}
    Check Average Tput  direction=dl  dt_name=${dt_name_2}
    ue.Stop Data Transfers For All UEs
    Sleep  5s  reason=Wait for UE reattach
#    ${pcap_path}  IF  '${NR_call}'=='${false}'  Stop Tracing and download logs from SMOD

    [Teardown]  Detach UE and stop using it  ${ue}

Start UE Traffic
    [Arguments]  ${expected_pci}  ${NR_call}  ${dt_name_1}=DT_UL  ${dt_name_2}=DT_DL  ${tput_ul}=300  ${tput_dl}=50  ${duration}=7
    ...  ${5G_type}=NSA  ${ue_id}=0

    Start tracing on SMOD
    ${attach_condition}  Attach UE  ${ue_id}
    Check Attach Condition  ${attach_condition}
    IF  '${NR_call}'=='${true}' and '${5G_type}'=='NSA'  Wait Until Keyword Succeeds  3x  1min  Verify 5G NSA Attach  ${ue}  ${expected_pci}
    IF  '${NR_call}'=='${true}' and '${5G_type}'=='SA'  Wait Until Keyword Succeeds  3x  1min  Verify 5G SA Attach  ${ue}  ${expected_pci}
    IF  '${NR_call}'=='${false}'  Wait Until Keyword Succeeds  3x  1min  Verify LTE Attach  ${ue}  ${expected_pci}
    ue.Start Data Transfer  ${dt_name_1}  ${ue}  ul  duration=120s  throughput=${tput_ul}Mbits/sec  protocol=udp  packet=1400
	ue.Start Data Transfer  ${dt_name_2}  ${ue}  dl  duration=120s  throughput=${tput_dl}Mbits/sec  protocol=udp  packet=1400
	${duration}  Evaluate  ${duration} - 1
	Sleep  ${duration}s  reason=Wait for throughput stabilization
    ue.Check Data Transfer Is Alive  ${dt_name_1}
    ue.Check Data Transfer Is Alive  ${dt_name_2}
	Sleep  1s
    Check Average Tput  direction=ul  dt_name=${dt_name_1}
    Check Average Tput  direction=dl  dt_name=${dt_name_2}
    ue.Stop Data Transfers For All UEs
    Sleep  5s  reason=Wait for UE reattach
    ${pcap_path}  IF  '${NR_call}'=='${false}'  Stop Tracing and download logs from SMOD

    [Teardown]  Detach UE and stop using it  ${ue}


Start UE SA Traffic
    [Arguments]  ${dt_name_1}=DT_UL  ${dt_name_2}=DT_DL  ${tput_ul}=300  ${tput_dl}=50  ${duration}=7
    ...  ${ue_id}=0     #${NR_call}     ${expected_pci}  ${5G_type}=SA

#    Start tracing on SMOD
    ${attach_condition}  Attach UE  ${ue_id}
#    Check Attach Condition  ${attach_condition}
#    IF  '${NR_call}'=='${true}' and '${5G_type}'=='NSA'  Wait Until Keyword Succeeds  3x  1min  Verify 5G NSA Attach  ${ue}  ${expected_pci}
#    IF  '${NR_call}'=='${true}' and '${5G_type}'=='SA'  Wait Until Keyword Succeeds  3x  1min  Verify 5G SA Attach  ${ue}  ${expected_pci}
#    IF  '${NR_call}'=='${false}'  Wait Until Keyword Succeeds  3x  1min  Verify LTE Attach  ${ue}  ${expected_pci}
    ue.Start Data Transfer  ${dt_name_1}  ${ue}  ul  duration=120s  throughput=${tput_ul}Mbits/sec  protocol=udp  packet=1400
	ue.Start Data Transfer  ${dt_name_2}  ${ue}  dl  duration=120s  throughput=${tput_dl}Mbits/sec  protocol=udp  packet=1400
	${duration}  Evaluate  ${duration} - 1
	Sleep  ${duration}s  reason=Wait for throughput stabilization
    ue.Check Data Transfer Is Alive  ${dt_name_1}
    ue.Check Data Transfer Is Alive  ${dt_name_2}
	Sleep  1s
    Check Average Tput  direction=ul  dt_name=${dt_name_1}
    Check Average Tput  direction=dl  dt_name=${dt_name_2}
    ue.Stop Data Transfers For All UEs
    Sleep  5s  reason=Wait for UE reattach
#    ${pcap_path}  IF  '${NR_call}'=='${false}'  Stop Tracing and download logs from SMOD

    [Teardown]  Detach UE and stop using it  ${ue}


Detach UE and stop using it
    [Arguments]  ${ue}

    IF  '${ue}'=='NOKIA83' or '${ue}'=='XIAOMI12' or '${ue}'=='NOKIA83_LTE' or '${ue}'=='NOKIA83_NR' or '${ue}'=='XR20'
        ue.Detach Ue  ${ue}
        ue.Stop Using Ue  ${ue}
    ELSE IF  '${ue}'=='SAMSUNG_J4_PLUS' or '${ue}'=='OP6_LTE' or '${ue}'=='OP9_5G'
        ue.Stop Using Ue  ${ue}
    END


Prepare UE
    [Arguments]  ${ue_id}=${0}  ${ue_cap}=0

	Log To Console  \nUe capability is ${ue_cap}
    Set Test Variable  ${ue}  ${tl.ues[${ue_id}].capabilities[0]}
    ${status}  Run Keyword And Return Status  ue.Require UE  ${ue}  ${ue}
    Log To Console  \nRequire UE ${ue}, status: ${status}
    IF  '${status}'=='False'  Reboot And Open Diagnostic Ports  ${ue}

Reboot And Open Diagnostic Ports
    [Arguments]  ${open_diag_port}

    Execute Command On UE PC  adb -s ${ue_serial_num} reboot
    Log to console  Reboot UE serial number: ${ue_serial_num}
    Sleep  120s  reason=Wait for UE after reboot
    IF  '${open_diag_port}'=='NOKIA83' and '${MRBTS_ID}'=='10812'
        Execute Command On UE PC  adb shell su -c ${diagnostic_port_command}
    ELSE IF  '${open_diag_port}'=='XIAOMI12' and '${MRBTS_ID}'=='8085'
        Execute Command On UE PC  adb shell su -c ${diagnostic_port_command_1}; ${diagnostic_port_command_2}
    END


Attach UE
    [Arguments]  ${ue_id}=${0}

    Prepare UE  ${ue_id}
    Log To Console  Attach UE ${ue}
    ${attach_condition}=  Run Keyword And Return Status  ue.Attach UE  ${ue}  timeout=60

    RETURN  ${attach_condition}


Reboot UE
    [Arguments]  ${reboot_timeout}=60

    Log To Console  Reboot UE ${ue}, waiting ${reboot_timeout}s for UE booting
    ue.Reboot UE  ${ue}  timeout=${reboot_timeout}
    Sleep  5s


Verify LTE Attach
    [Arguments]  ${ue}  ${expected_cell}  ${ue_type}=non_askey

    ${CELL_INFO}  IF  '${ue_type}'=='non_askey'  ue.Get UE Info  ${ue}  infos_list=ALL
    IF  '${ue_type}'=='non_askey' and '${CELL_INFO}[cell_info][cellType]'=='LTE'
        ${pci}  Convert To String  ${CELL_INFO}[cell_info][pci]
    ELSE IF  '${ue_type}'=='non_askey' and '${CELL_INFO}[cell_info][cellType]'=='LTENR'
        ${pci}  Convert To String  ${CELL_INFO}[cell_info][ltePci]
    END
    IF  '${ue_type}'=='non_askey' and '${CELL_INFO}[cell_info][cellType]'=='LTE'
        ${dBm}  Convert To String  ${CELL_INFO}[cell_info][dbm]
    ELSE IF  '${ue_type}'=='non_askey' and '${CELL_INFO}[cell_info][cellType]'=='LTENR'
        ${dBm}  Convert To String  ${CELL_INFO}[cell_info][lteDbm]
    END
    ${CELL_ID}  IF  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  CELL_ID
    ${CELL_ID}  Convert To String  ${CELL_ID}
    ${SIGNAL_STRENGTH}  IF  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  SIGNAL_STRENGTH
    IF  '${ue_type}'=='askey'  Should Be Equal  ${CELL_ID}  ${expected_cell}
    ...  ${ue} not attached to expected cell ID: ${expected_cell}  values=False
    IF  '${ue_type}'=='non_askey'  Should Be Equal  ${pci}  ${expected_cell}
    ...  ${ue} not attached to expected physical cell ID: ${expected_cell}   values=False
    Log To Console  ${ue} attached to LTE:
    IF  '${ue_type}'=='non_askey'
        Log To Console  LNCEL state: CONNECTED, Physical cell ID: ${pci}, cell ID: ${CELL_INFO}[cell_info][ci], RSRP: ${dBm} dBm
    END
    IF  '${ue_type}'=='askey'
        Log To Console  LNCEL state: CONNECTED, Physical cell ID: 'not presented', cell ID: ${CELL_ID}, ${SIGNAL_STRENGTH}
    END


#Start UE DL traffic - Askey
#    [Documentation]  UE data traffic - downlink. Keyword dedicated for Askey.
#    ...
#    ...  **Input Parameters:**
#    ...
#    ...  +-----------------------------+---------+-----------------------------------------------+
#    ...  | Variable                    | NR_call | Cell verification by                          |
#    ...  +=============================+=========+===============================================+
#    ...  | ${expected_cell}=CID        | False   | E-UTRAN cell ID                               |
#    ...  +-----------------------------+---------+-----------------------------------------------+
#    ...  | ${expected_cell}=PID        | True    | Physical layer cell ID                        |
#    ...  +-----------------------------+---------+-----------------------------------------------+
#    ...
#    ...  **Example of simple usage:**
#    ...
#    ...  Start UE DL traffic - Askey  ${ue_capabilities}  expected_cell=85  NR_call=${true}
#    ...
#    [Arguments]  ${ue}  ${expected_cell}  ${NR_call}  ${dt_name}=DT_UL  ${direction}=dl  ${ue_type}=askey
#	Start tracing on SMOD
#	ue.Require UE  ${ue}  ${ue}
#    ue.Attach Ue  ${ue}
#    Run Keyword If  '${NR_call}'=='${true}'  Verify 5G NSA Attach  ${ue}  ${expected_cell}  ${ue_type}
#    ...  ELSE  Verify 4G Attach  ${ue}  ${expected_cell}  ${ue_type}
#    ue.Start Data Transfer  ${dt_name}  ${ue}  ${direction}
#    ...                  buffer=1000M   packet_size=1400  throughput=300 Mbits/sec  protocol=udp  duration=20s
#    ue.Await Data Transfer Finish  ${dt_name}
#    ${pcap_path}  Run Keyword If  '${NR_call}'=='${false}'  Stop Tracing and download logs from SMOD
#    ${status}  Run Keyword And Return Status  ue.Verify Average Throughput  ${dt_name}  tput_min=1 Mbits/sec
#    Run Keyword If  ${status}  Log To Console  Throughput verification done (tput_min=1 Mbits/sec achieved)
#    [Teardown]  Run Keywords  ue.Detach Ue  ${ue}  AND  ue.Stop Using Ue  ${ue}
#
Step0: Call For T&T
        [Arguments]  ${tput_dl}=300
        Start UE Traffic T&T  expected_pci=310  NR_call=${false}  duration=10  tput_dl=${tput_dl}

Call For CB008745 LTE
    [Arguments]  ${tput_dl}=50

    attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
    Set attenuator value on all ports  set_value_db=${90}
    IF  '${MRBTS_ID}'=='10812' and '${2nd_LNCEL_ID}' == '48120'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #PCI-85 PID:0 CID:2767873
        Log to console  Adjust LNCEL 85
        Start UE Traffic  expected_pci=85  NR_call=${false}  duration=75  tput_dl=${tput_dl}
    END
	IF  '${MRBTS_ID}'=='10817' and '${2nd_LNCEL_ID}' == '107'
#       Set attenuator value on all ports  set_value_db=${90}
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}
        Log to console  Adjust LNCEL 107
        Start UE Traffic  expected_pci=107  NR_call=${false}  duration=90  tput_dl=${tput_dl}
    ELSE IF  '${MRBTS_ID}'=='10812' and '${2nd_LNCEL_ID}' == '48121'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #PCI-2 PID:1 CID:2767872
        Log to console  Adjust LNCEL 2
        Start UE Traffic  expected_pci=2  NR_call=${false}  duration=75  tput_dl=${tput_dl}
    ELSE IF  '${MRBTS_ID}'=='10812' and '${2nd_LNCEL_ID}' == '48122'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #PCI-3 PID:2 CID:2767874
        Log to console  Adjust LNCEL 3
        Start UE Traffic  expected_pci=3  NR_call=${false}  duration=75  tput_dl=${tput_dl}
    END
    IF  '${MRBTS_ID}'=='10811' and '${2nd_LNCEL_ID}' == '48111'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-0 PID:0 CID:2767616
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-0 PID:0 CID:2767616
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-0 PID:0 CID:2767616
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-0 PID:0 CID:2767616
        Log to console  Adjust LNCEL 48111
        Start UE Traffic  expected_pci=0  duration=75  NR_call=${false}  ue_id=${1}  tput_dl=${tput_dl}
    ELSE IF  '${MRBTS_ID}'=='10811' and '${2nd_LNCEL_ID}' == '48112'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-1 PID:1 CID:2767617
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-1 PID:1 CID:2767617
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-1 PID:1 CID:2767617
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-1 PID:1 CID:2767617
 	    Log to console  Adjust LNCEL 48112
	    Start UE Traffic  expected_pci=1  duration=75  NR_call=${false}  ue_id=${1}  tput_dl=${tput_dl}
    ELSE IF  '${MRBTS_ID}'=='10811' and '${2nd_LNCEL_ID}' == '48113'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-2 PID:2 CID:2767618
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-2 PID:2 CID:2767618
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-2 PID:2 CID:2767618
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-2 PID:2 CID:2767618
        Log to console  Adjust LNCEL 2
	    Start UE Traffic  expected_pci=2  duration=75   NR_call=${false}  ue_id=${1}  tput_dl=${tput_dl}
	END
	IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48187'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-48187 PID:408 CID:2769429
        Log to console  Adjust LNCEL 48187
        Start UE Traffic  expected_pci=408  NR_call=${false}  duration=75  tput_dl=${tput_dl}
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48148'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-48148
        Log to console  Adjust LNCEL 48148
        Start UE Traffic  expected_pci=342  NR_call=${false}  duration=75  tput_dl=${tput_dl}
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48188'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-48188
        Log to console  Adjust LNCEL 48188
        Start UE Traffic  expected_pci=361  NR_call=${false}  duration=75  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48149'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-48149
        Log to console  Adjust LNCEL 48149
        Start UE Traffic  expected_pci=25  NR_call=${false}  duration=75  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48189'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-48189
        Log to console  Adjust LNCEL 48189
        Start UE Traffic  expected_pci=65  NR_call=${false}  duration=75  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48138'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-48138
        Log to console  Adjust LNCEL 48138
        Start UE Traffic  expected_pci=338  NR_call=${false}  duration=75  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48184'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-48184
        Log to console  Adjust LNCEL 48184
        Start UE Traffic  expected_pci=414  NR_call=${false}  duration=75  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48181'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-48181
        Log to console  Adjust LNCEL 48181
        Start UE Traffic  expected_pci=126  NR_call=${false}  duration=75  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48180'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-48180
        Log to console  Adjust LNCEL 48180
        Start UE Traffic  expected_pci=369  NR_call=${false}  duration=75  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48185'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48185
        Log to console  Adjust LNCEL 48185
        Start UE Traffic  expected_pci=352  NR_call=${false}  duration=75  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48182'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48182
        Log to console  Adjust LNCEL 48182
        Start UE Traffic  expected_pci=7  NR_call=${false}  duration=75  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48140'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48140
        Log to console  Adjust LNCEL 48140
        Start UE Traffic  expected_pci=379  NR_call=${false}  duration=75  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48186'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48186
        Log to console  Adjust LNCEL 48186
        Start UE Traffic  expected_pci=68  NR_call=${false}  duration=75  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48183'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48183
        Log to console  Adjust LNCEL 48183
        Start UE Traffic  expected_pci=41  NR_call=${false}  duration=75  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48147'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48147
        Log to console  Adjust LNCEL 48147
        Start UE Traffic  expected_pci=446  NR_call=${false}  duration=75  tput_dl=${tput_dl}
    END


Call For CB008745 NR
    [Arguments]  ${tput_dl}=90

    attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
    IF  '${MRBTS_ID}'=='10812' and '${2nd_NRCELL_ID}' == '60'
        Set attenuator value on all ports  set_value_db=${90}
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-1 PID 60 CID:177143868
        Log to console  Adjust NRCEL 60
    ELSE IF  '${MRBTS_ID}'=='10812' and '${2nd_NRCELL_ID}' == '61'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #NRCEL-2 PID 61 CID:177143869
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}
        Log to console  Adjust NRCEL 61
    ELSE IF  '${MRBTS_ID}'=='10812' and '${2nd_NRCELL_ID}' == '63'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #NRCEL-3 PID 63 CID:177143871
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}
        Log to console  Adjust NRCEL 63
    END
    IF  '${MRBTS_ID}'=='10812'  Start UE Traffic  expected_pci=${2nd_NRCELL_ID}  NR_call=${true}  duration=75  tput_dl=${tput_dl}
    IF  '${MRBTS_ID}'=='10811' and '${2nd_NRCELL_ID}' == '0'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-0 PID:810 CID:708968448
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-0 PID:810 CID:708968448
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-0 PID:810 CID:708968448
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-0 PID:810 CID:708968448
    ELSE IF  '${MRBTS_ID}'=='10811' and '${2nd_NRCELL_ID}' == '1'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-0 PID:811 CID:708968449
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-0 PID:810 CID:708968449
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-0 PID:810 CID:708968449
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-0 PID:810 CID:708968449
    ELSE IF  '${MRBTS_ID}'=='10811' and '${2nd_NRCELL_ID}' == '2'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-0 PID:812 CID:708968450
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-0 PID:810 CID:708968448
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-0 PID:810 CID:708968448
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-0 PID:810 CID:708968448
	END
    IF  '${MRBTS_ID}'=='10811'  Start UE Traffic  expected_pci=${SA_PCI}  NR_call=${true}  duration=75  tput_dl=${tput_dl}  5G_type=SA
    IF  '${MRBTS_ID}'=='10818' and '${2nd_NRCELL_ID}' == '101'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #LNCEL-4 PID:4 CID:2198532
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #LNCEL-4 PID:4 CID:2198532
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #NRCEL-101 PID:101 CID:140705793
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #NRCEL-101 PID:101 CID:140705793
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #NRCEL-101 PID:101 CID:140705793
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #NRCEL-101 PID:101 CID:140705793
        Log to console  Adjust NRCEL 101
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_NRCELL_ID}' == '103'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #LNCEL-3 PID:3 CID:2198531
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #LNCEL-3 PID:3 CID:2198531
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #NRCEL-103 PID:103 CID:140705795
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #NRCEL-103 PID:103 CID:140705795
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #NRCEL-103 PID:103 CID:140705795
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #NRCEL-103 PID:103 CID:140705795
	    Log to console  Adjust NRCEL 103
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_NRCELL_ID}' == '104'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_23}  #LNCEL-107 PID:107 CID:2198635
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_24}  #LNCEL-107 PID:107 CID:2198635
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}  #NRCEL-104 PID:104 CID:140705796
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #NRCEL-104 PID:104 CID:140705796
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_NRCELL_ID}' == '100'
        Set attenuator value on all ports  set_value_db=${90}
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #LNCEL-3 PID:3 CID:2198531
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #LNCEL-3 PID:3 CID:2198531
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-100 PID:100 CID:140705792
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-100 PID:100 CID:140705792
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-100 PID:100 CID:140705792
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-100 PID:100 CID:140705792
	    Log to console  Adjust NRCEL 100
	END
    IF  '${MRBTS_ID}'=='10818'  Start UE Traffic  expected_pci=${2nd_NRCELL_ID}  NR_call=${true}  duration=75  tput_dl=${tput_dl}
    IF  '${MRBTS_ID}'=='10817'  Allow Fault In Watchdog  faultID=49  #fault_name: Cell blocked
    IF  '${MRBTS_ID}'=='10817' and '${3rd_NRCELL_ID}' == '56'
        Set attenuator value on all ports  set_value_db=${90}
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-56 PID:56 CID:132218936
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-56 PID:56 CID:132218936
        Log to console  Adjust NRCEL 56
    ELSE IF  '${MRBTS_ID}'=='10817' and '${3rd_NRCELL_ID}' == '1'
        Set attenuator value on all ports  set_value_db=${90}
        admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #NRCEL-1 PID:1 CID:132218881
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #NRCEL-1 PID:1 CID:132218881
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #NRCEL-1 PID:1 CID:132218881
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #NRCEL-1 PID:1 CID:132218881
        Log to console  Adjust NRCEL 1
    ELSE IF  '${MRBTS_ID}'=='10817' and '${3rd_NRCELL_ID}' == '2'
        Set attenuator value on all ports  set_value_db=${90}
        admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #NRCEL-2 PID:2 CID:132218882
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #NRCEL-2 PID:2 CID:132218882
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #NRCEL-2 PID:2 CID:132218882
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #NRCEL-2 PID:2 CID:132218882
        Log to console  Adjust NRCEL 2
    ELSE IF  '${MRBTS_ID}'=='10817' and '${3rd_NRCELL_ID}' == '3'
        Set attenuator value on all ports  set_value_db=${90}
        admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_21}  #NRCEL-3 PID:3 CID:132218883
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_22}  #NRCEL-3 PID:3 CID:132218883
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_23}  #NRCEL-3 PID:3 CID:132218883
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_24}  #NRCEL-3 PID:3 CID:132218883
        Log to console  Adjust NRCEL 3
    ELSE IF  '${MRBTS_ID}'=='10817' and '${3rd_NRCELL_ID}' == '4'
        Set attenuator value on all ports  set_value_db=${90}
        admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_21}  #NRCEL-4 PID:4 CID:132218884
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_22}  #NRCEL-4 PID:4 CID:132218884
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_23}  #NRCEL-4 PID:4 CID:132218884
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_24}  #NRCEL-4 PID:4 CID:132218884
        Log to console  Adjust NRCEL 4
    END
#    IF  '${MRBTS_ID}'=='10817'  Start UE Traffic  expected_pci=${2nd_NRCELL_ID}  NR_call=${true}  duration=75  tput_dl=95
    IF  '${MRBTS_ID}'=='10817'  Start UE Traffic  expected_pci=${3rd_NRCELL_ID}  NR_call=${true}  duration=110  tput_dl=95
    IF  '${MRBTS_ID}'=='10817'  Run Keyword and ignore error  Unblock All Cells  rat=NR  timeout=120s
    IF  '${MRBTS_ID}'=='10817'  Wait For Inactive Fault  faultID=49  timeout=2min
    IF  '${MRBTS_ID}'=='10817'  Disallow Fault In Watchdog  faultID=49  #fault_name: Cell blocked
#    IF  '${MRBTS_ID}'=='10819' and '${2nd_NRCELL_ID}' == '551'
    IF  '${MRBTS_ID}'=='10819' and '${3rd_NRCELL_ID}' == '551'
        Set attenuator value on all ports  set_value_db=${90}
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-1 PID:551 CID:708984833
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-55201 PID:551 CID:708968448
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-55201 PID:551 CID:708968448
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-55201 PID:551 CID:708968448
        Log to console  Adjust NRCEL 551 (ciphered ID:02a4242270)
        Set Test variable   ${SA_PCI}  02a4242270
#   ELSE IF  '${MRBTS_ID}'=='10819' and '${2nd_NRCELL_ID}' == '552'
    ELSE IF  '${MRBTS_ID}'=='10819' and '${3rd_NRCELL_ID}' == '552'
        Set attenuator value on all ports  set_value_db=${90}
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #NRCEL-2 PID:811 CID:708984834
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #NRCEL-552012 PID:811 CID:708968449
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #NRCEL-552012 PID:811 CID:708968449
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #NRCEL-552012 PID:811 CID:708968449
        Log to console  Adjust NRCEL 552 (ciphered ID:02a4242280)
        Set Test variable   ${SA_PCI}  02a4242280
#   ELSE IF  '${MRBTS_ID}'=='10819' and '${2nd_NRCELL_ID}' == '553'
     ELSE IF  '${MRBTS_ID}'=='10819' and '${3rd_NRCELL_ID}' == '553'
        Set attenuator value on all ports  set_value_db=${90}
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}  #NRCEL-3 PID:812 CID:708984835
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #NRCEL-552013 PID:812 CID:708968450
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #NRCEL-552013 PID:812 CID:708968450
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #NRCEL-552013 PID:812 CID:708968450
        Log to console  Adjust NRCEL 553 (ciphered ID:02a4242290)
        Set Test variable   ${SA_PCI}  02a4242290
    END
    IF  '${MRBTS_ID}'=='10819'  Start UE Traffic  expected_pci=${SA_PCI}  NR_call=${true}  duration=200  tput_dl=200  5G_type=SA

    IF  '${MRBTS_ID}'=='10811' and '${2nd_NRCELL_ID}' == '0'
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
        Log to console  Adjust NRCEL 0
        Set Test variable   ${SA_PCI}  02a4200000
    ELSE IF  '${MRBTS_ID}'=='10811' and '${2nd_NRCELL_ID}' == '1'
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
	    Log to console  Adjust NRCEL 1
	    Set Test variable   ${SA_PCI}  02a4200010
    ELSE IF  '${MRBTS_ID}'=='10811' and '${2nd_NRCELL_ID}' == '2'
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0
	    Log to console  Adjust NRCEL 2
	    Set Test variable   ${SA_PCI}  02a4200020
	ELSE
	    Log to console  Barring not needed
	END


Cell barring for CB008745 LTE
	IF  '${MRBTS_ID}'=='10811' and '${2nd_LNCEL_ID}' == '48111'
        Log to console  Barring to call LNCEL 48111
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48111
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48112
        Sleep  20s
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48113
		Sleep  20s
    ELSE IF  '${MRBTS_ID}'=='10811' and '${2nd_LNCEL_ID}' == '48112'
        Log to console  Barring to call LNCEL 48112
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48112
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48111
        Sleep  20s
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48113
		Sleep  20s
    ELSE IF  '${MRBTS_ID}'=='10811' and '${2nd_LNCEL_ID}' == '48113'
        Log to console  Barring to call LNCEL 48113
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48113
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48112
        Sleep  20s
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48111
		Sleep  20s
    END
	IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48187'
        Log to console  Barring to call LNCEL 48187  #LNCEL-48187 PID:408 CID:2769429
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48187
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48148
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48148'
	    Log to console  Barring to call LNCEL 48148  #LNCEL-48148
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48148
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48187
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48188'
	    Log to console  Barring to call LNCEL 48188  #LNCEL-48188
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48188
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48149
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48149'
	    Log to console  Barring to call LNCEL 48149  #LNCEL-48149
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48149
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48188
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48189'
	    Log to console  Barring to call LNCEL 48189  #LNCEL-48189
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48189
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48138
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48138'
	    Log to console  Barring to call LNCEL 48138  #LNCEL-48138
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48138
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48189
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48184'
        Log to console  Barring to call LNCEL 48184  #LNCEL-48184
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48184
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48181
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48180
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-41
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48181'
	    Log to console  Barring to call LNCEL 48181  #LNCEL-48181
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48181
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48184
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48180
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-41
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48180'
	    Log to console  Barring to call LNCEL 48180  #LNCEL-48180
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48180
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48184
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48181
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-41
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48185'
	    Log to console  Barring to call LNCEL 48185    #LNCEL-48185
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48185
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48182
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48140
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-42
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-22
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48182'
	    Log to console  Barring to call LNCEL 48182        #LNCEL-48182
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48182
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48185
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48140
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-42
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-22
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48140'
	    Log to console  Barring to call LNCEL 48140     #LNCEL-48140
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48140
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48182
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48185
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-42
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-22
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48186'
	    Log to console  Barring to call LNCEL 48186     #LNCEL-48186
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48186
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48183
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48147
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-43
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-23
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48183'
	    Log to console  Barring to call LNCEL 48183    #LNCEL-48183
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48183
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48186
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48147
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-43
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-23
     ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48147'
	    Log to console  Barring to call LNCEL 48147  #LNCEL-48147
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48147
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48183
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48186
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-43
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-23
    ELSE
        Log to console  Barring not needed
    END


Cell barring for CB008745 NR
    IF  '${MRBTS_ID}'=='10811' and '${2nd_NRCELL_ID}' == '0'
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
        Set Test variable   ${SA_PCI}  02a4200000
    ELSE IF  '${MRBTS_ID}'=='10811' and '${2nd_NRCELL_ID}' == '1'
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
	    Log to console  Adjust NRCEL 1
	    Set Test variable   ${SA_PCI}  02a4200010
    ELSE IF  '${MRBTS_ID}'=='10811' and '${2nd_NRCELL_ID}' == '2'
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0
	    Log to console  Adjust NRCEL 2
	    Set Test variable   ${SA_PCI}  02a4200020
	ELSE
	    Log to console  Barring not needed
    END


Unbarring all LTE cells
    ${SIBs_A}  admin.get managed objects  SIB_A
    FOR  ${SIB_A}  IN  @{SIBs_A}
    ${barring_status}  Get From Dictionary  ${SIB_A['parameters']}  cellBarred
    ${SIB_NAME}  Get From Dictionary  ${SIB_A}  distName
    ${LNCEL_A_name}  Get Regexp Matches  ${SIB_NAME}  LNCEL_A-\\d+
    ${LNCEL_A_id}  string.Split String  ${LNCEL_A_name[0]}  LNCEL_A-
    IF  "${barring_status}"=="barred"
        Log to console  Unbarring LNCEL-${LNCEL_A_id[1]}
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${LNCEL_A_id[1]}
	    Sleep  20s
    END
    END


Unbarring all NR cells
    ${NRCELLS_A}  admin.get managed objects  NRCELL_A
    FOR  ${NRCELL_A}  IN  @{NRCELLS_A}
    ${barring_status}  Get From Dictionary  ${NRCELL_A['parameters']}  cellBarred
    ${NRCELL_A_NAME}  Get From Dictionary  ${NRCELL_A}    distName
    ${NRCELL_A_id}  string.Split String  ${NRCELL_A_name}  NRCELL_A-
    IF  "${barring_status}"=="barred"
        Log to console  Unbarring NRCELL-${NRCELL_A_id[1]}
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_A_id[1]}
    END
    END


Unbarring all cells
    Check which RAT are on given TestLine
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Unbarring all LTE cells
        Unbarring all NR cells
	    Log to console  All LTE and NR cells are unbarred
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Unbarring all LTE cells
	    Log to console  All LTE cells are unbarred
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Unbarring all NR cells
	    Log to console  All NR cells are unbarred
	END


L3 Call
    [Documentation]  This keyword check if attenuator is connected to BTS and call is possible
	Run Keyword If  '${MRBTS_ID}' == '10312'   Run Keywords
    ...  Set Test Variable  ${ue}  XR20
#	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
#	...  AND  Set attenuator value on all ports  set_value_db=${90}
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-1 PID:1 CID:2132737
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-1 PID:1 CID:2132737
#	...  AND  Start UE traffic  expected_pci=1  NR_call=${false}
#
#	...  AND  Set attenuator value on all ports  set_value_db=${90}
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}  #LNCEL-2 PID:2 CID:2132738
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #LNCEL-2 PID:2 CID:2132738
#	...  AND  Start UE traffic  expected_pci=2  NR_call=${false}
#
#	...  AND  Set attenuator value on all ports  set_value_db=${90}
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #LNCEL-3 PID:3 CID:2132739
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #LNCEL-3 PID:3 CID:2132739
#	...  AND  Start UE traffic  expected_pci=3  NR_call=${false}
#
#	...  AND  Set attenuator value on all ports  set_value_db=${90}
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #LNCEL-3 PID:3 CID:2132739
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #LNCEL-3 PID:3 CID:2132739
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #NRCEL-3 PID:61 CID:136495107
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #NRCEL-3 PID:61 CID:136495107
#	...  AND  Start UE traffic  expected_pci=61  NR_call=${true}
#
#	...  AND  Set attenuator value on all ports  set_value_db=${90}
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}   #LNCEL-3 PID:3 CID:2132739
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}   #LNCEL-3 PID:3 CID:2132739
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}   #NRCEL-4 PID:62 CID:136495108
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #NRCEL-4 PID:62 CID:136495108
#	...  AND  Start UE traffic  expected_pci=62  NR_call=${true}
#
#	...  AND  Set attenuator value on all ports  set_value_db=${90}
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}   #LNCEL-3 PID:3 CID:2132739
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}   #LNCEL-3 PID:3 CID:2132739
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_17}  #NRCEL-5 PID:63 CID:136495109
#	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_18}  #NRCEL-5 PID:63 CID:136495109
	...  AND  Start UE traffic  expected_pci=63  NR_call=${true}

	Run Keyword If  '${MRBTS_ID}' == '8085'   Run Keywords
	...  Set Test Variable  ${ue}  XIAOMI12
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #LNCEL-0 PID:0 CID:2069760
    ...  AND  Start UE traffic  expected_pci=0  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #LNCEL-1 PID:1 CID:2069761
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #LNCEL-1 PID:1 CID:2069761
    ...  AND  Start UE traffic  expected_pci=1  NR_call=${false}

    ...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #LNCEL-2 PID:2 CID:2069762
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #LNCEL-2 PID:2 CID:2069762
    ...  AND  Start UE traffic  expected_pci=2  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #LNCEL-1 PID:1 CID:2069761
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #LNCEL-1 PID:1 CID:2069761
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_17}  #NRCEL-1 PID:81 CID:901447681
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_18}  #NRCEL-1 PID:81 CID:901447681
	...  AND  Start UE traffic  expected_pci=81  NR_call=${true}

    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #LNCEL-1 PID:1 CID:2069761
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #LNCEL-1 PID:1 CID:2069761
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #NRCEL-2 PID:82 CID:901447682
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #NRCEL-2 PID:82 CID:901447682
	...  AND  Start UE traffic  expected_pci=82  NR_call=${true}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #LNCEL-1 PID:1 CID:2069761
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #LNCEL-1 PID:1 CID:2069761
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_21}  #NRCEL-2 PID:82 CID:901447682
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_22}  #NRCEL-2 PID:82 CID:901447682
	...  AND  Start UE traffic  expected_pci=83  NR_call=${true}

	Run Keyword If  '${MRBTS_ID}' == '10812'   Run Keywords
    ...  Set Test Variable  ${ue}  NOKIA83
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-1 PID:85 CID:2767873
	...  AND  Start UE traffic  expected_pci=85  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-2 PID:2 CID:2767874
	...  AND  Start UE traffic  expected_pci=2  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-3 PID:3 CID:2767875
	...  AND  Start UE traffic  expected_pci=3  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-1 PID:85 CID:2767873
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-1 PID:60 CID:177143868
	...  AND  Start UE traffic  expected_pci=60  NR_call=${true}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}   #LNCEL-1 PID:85 CID:2767873
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}   #NRCEL-2 PID:61 CID:177143869
	...  AND  Start UE traffic  expected_pci=61  NR_call=${true}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}   #LNCEL-2 PID:2 CID:2767874
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}   #NRCEL-3 PID:63 CID:177143871
	...  AND  Start UE traffic  expected_pci=63  NR_call=${true}

	Run Keyword If  '${MRBTS_ID}' == '10813'   Run Keywords
	...  Set Test Variable  ${ue}  SAMSUNG_J4_PLUS
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-1 PID:1 CID:2768130
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-1 PID:1 CID:2768130
	...  AND  Airplane Mode On/Off
	...  AND  Start UE traffic  expected_pci=1  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-2 PID:2 CID:2768129
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-2 PID:2 CID:25867777
	...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-5
    ...  AND  Start UE traffic  expected_pci=2  NR_call=${false}

	...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-5
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-5 PID:5 CID:2768133
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-5 PID:5 CID:25867781
	...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2
    ...  AND  Start UE traffic  expected_pci=5  NR_call=${false}

	...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2
	...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-3 PID:3 CID:2768131
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-3 PID:3 CID:2768131
	...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-6
	...  AND  Start UE traffic  expected_pci=3  NR_call=${false}

	...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-6
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-6 PID:6 CID:2768134
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-6 PID:6 CID:2768134
	...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-3
	...  AND  Start UE traffic  expected_pci=6  NR_call=${false}
	...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-3
	...  AND  Set attenuator value on all ports  set_value_db=${90}

	Run Keyword If  '${MRBTS_ID}' == '10814'   Run Keywords
	...  Set Test Variable  ${ue}  OP6_LTE
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-1 PID:351 CID:2768385
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-1 PID:351 CID:2768385
	...  AND  Start UE traffic  expected_pci=351  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-2 PID:352 CID:2768386
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-2 PID:352 CID:2768386
    ...  AND  Start UE traffic  expected_pci=352  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-3 PID:353 CID:2768387
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-3 PID:353 CID:2768387
	...  AND  Start UE Traffic  expected_pci=353  NR_call=${false}

	Run Keyword If  '${MRBTS_ID}' == '10809'   Run Keywords
    ...  Set Test Variable  ${ue}  OP9_5G
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-1 PID:9 CID:25867265
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-1 PID:9 CID:25867265
	...  AND  Start UE traffic  expected_pci=9  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-2 PID:202 CID:25867266
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-2 PID:202 CID:25867266
	...  AND  Start UE traffic  expected_pci=202  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-3 PID:203 CID:25867267
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-3 PID:203 CID:25867267
	...  AND  Start UE traffic  expected_pci=203  NR_call=${false}

	Run Keyword If  '${MRBTS_ID}' == '10811'  Run Keywords
	...  Set Test Variable  ${ue}  NOKIA83_NR
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-0 PID:810 CID:708968448
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-0 PID:810 CID:708968448
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-0 PID:810 CID:708968448
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-0 PID:810 CID:708968448
	...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...  AND  Airplane Mode On/Off
    ...  AND  Log To Console  Cell ID 708968448 equals 00831c0000 after being ciphered
    ...  AND  Start UE traffic  expected_pci=02a4200000  NR_call=${true}  5G_type=SA

	...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-1 PID:811 CID:708968449
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-1 PID:811 CID:708968449
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-1 PID:811 CID:708968449
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-1 PID:811 CID:708968449
    ...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...  AND  Airplane Mode On/Off
    ...  AND  Log To Console  Cell ID 708968449 equals 00831c0010 after being ciphered
    ...  AND  Start UE traffic  expected_pci=02a4200010  NR_call=${true}  5G_type=SA

	...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-2 PID:812 CID:708968450
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-2 PID:812 CID:708968450
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-2 PID:812 CID:708968450
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-2 PID:812 CID:708968450
    ...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0
    ...  AND  Airplane Mode On/Off
    ...  AND  Log To Console  Cell ID 708968450 equals 00831c0020 after being ciphered
    ...  AND  Start UE traffic  expected_pci=02a4200020  NR_call=${true}  5G_type=SA

    ...  AND  Set Test Variable  ${ue}  NOKIA83_LTE

	...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-0 PID:0 CID:2767616
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-0 PID:0 CID:2767616
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-0 PID:0 CID:2767616
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-0 PID:0 CID:2767616
	...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-0
    ...  AND  Sleep  2s
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
    ...  AND  Sleep  2s
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2
    ...  AND  Start UE traffic  expected_pci=0  NR_call=${false}  ue_id=${1}

    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-1 PID:1 CID:2767617
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-1 PID:1 CID:2767617
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-1 PID:1 CID:2767617
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-1 PID:1 CID:2767617
    ...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
    ...  AND  Sleep  2s
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-0
    ...  AND  Sleep  2s
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2
    ...  AND  Start UE traffic  expected_pci=1  NR_call=${false}  ue_id=${1}

    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-2 PID:2 CID:2767618
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-2 PID:2 CID:2767618
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-2 PID:2 CID:2767618
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-2 PID:2 CID:2767618
    ...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2
    ...  AND  Sleep  2s
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
    ...  AND  Sleep  2s
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-0
    ...  AND  Start UE traffic  expected_pci=2  NR_call=${false}  ue_id=${1}
    Run keyword if  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48187'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-48187 PID:408 CID:2769429
    ...  AND  Log to console  Adjust LNCEL 48187
    ...  AND  Start UE Traffic  expected_pci=408  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    ...  ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48148'
	...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-48148
    ...  AND  Log to console  Adjust LNCEL 48148
    ...  AND  Start UE Traffic  expected_pci=342  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    ...  ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48188'
	...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-48188
    ...  AND  Log to console  Adjust LNCEL 48188
    ...  AND  Start UE Traffic  expected_pci=361  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	...  ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48149'
	...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-48149
    ...  AND  Log to console  Adjust LNCEL 48149
    ...  AND  Start UE Traffic  expected_pci=25  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	...  ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48189'
	...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-48189
    ...  AND  Log to console  Adjust LNCEL 48189
    ...  AND  Start UE Traffic  expected_pci=65  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	...  ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48138'
	...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-48138
    ...  AND  Log to console  Adjust LNCEL 48138
    ...  AND  Start UE Traffic  expected_pci=338  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	...  ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48184'
	...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-48184
    ...  AND  Log to console  Adjust LNCEL 48184
    ...  AND  Start UE Traffic  expected_pci=414  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	...  ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48181'
	...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-48181
    ...  AND  Log to console  Adjust LNCEL 48181
    ...  AND  Start UE Traffic  expected_pci=126  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	...  ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48180'
	...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-48180
    ...  AND  Log to console  Adjust LNCEL 48180
    ...  AND  Start UE Traffic  expected_pci=369  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	...  ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48185'
	...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48185
    ...  AND  Log to console  Adjust LNCEL 48185
    ...  AND  Start UE Traffic  expected_pci=352  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	...  ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48182'
	...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48182
    ...  AND  Log to console  Adjust LNCEL 48182
    ...  AND  Start UE Traffic  expected_pci=7  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	...  ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48140'
	...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48140
    ...  AND  Log to console  Adjust LNCEL 48140
    ...  AND  Start UE Traffic  expected_pci=379  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	...  ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48186'
	...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48186
    ...  AND  Log to console  Adjust LNCEL 48186
    ...  AND  Start UE Traffic  expected_pci=68  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	...  ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48183'
	...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48183
    ...  AND  Log to console  Adjust LNCEL 48183
    ...  AND  Start UE Traffic  expected_pci=41  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	...  ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48147'
	...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48147
    ...  AND  Log to console  Adjust LNCEL 48147
    ...  AND  Start UE Traffic  expected_pci=446  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    Run Keyword IF  '${MRBTS_ID}'=='10817'    Allow Fault In Watchdog  faultID=49  #fault_name: Cell blocked
    Run Keyword IF  '${MRBTS_ID}'=='10817'  Run keywords
#    ...  Set attenuator value on all ports  set_value_db=${90}
#    ...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-108
#    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-121
#    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-108 PID:108
#    ...  AND  Start UE traffic  expected_pci=108  NR_call=${false}
#    ...  AND  Set attenuator value on all ports  set_value_db=${90}
#    ...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-121
#    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-108
#    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-121 PID:121
#    ...  AND  Start UE traffic  expected_pci=121  NR_call=${false}
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Start UE traffic  expected_pci=107  NR_call=${false}
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-56 PID:56 CID:132218936
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-56 PID:56 CID:132218936
    ...  AND  Start UE Traffic  expected_pci=56  NR_call=${true}
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #NRCEL-1 PID:1 CID:132218881
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #NRCEL-1 PID:1 CID:132218881
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #NRCEL-1 PID:1 CID:132218881
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #NRCEL-1 PID:1 CID:132218881
    ...  AND  Start UE Traffic  expected_pci=1  NR_call=${true}
    ...  AND  Run Keyword and ignore error    Unblock All Cells  rat=NR  timeout=120s
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #NRCEL-2 PID:2 CID:132218882
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #NRCEL-2 PID:2 CID:132218882
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #NRCEL-2 PID:2 CID:132218882
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #NRCEL-2 PID:2 CID:132218882
    ...  AND  Run Keyword and ignore error    Unblock All Cells  rat=NR  timeout=120s
    ...  AND  Start UE Traffic  expected_pci=2  NR_call=${true}
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_21}  #NRCEL-3 PID:3 CID:132218883
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_22}  #NRCEL-3 PID:3 CID:132218883
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_23}  #NRCEL-3 PID:3 CID:132218883
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_24}  #NRCEL-3 PID:3 CID:132218883
    ...  AND  Run Keyword and ignore error    Unblock All Cells  rat=NR  timeout=120s
    ...  AND  Start UE Traffic  expected_pci=3  NR_call=${true}
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_21}  #NRCEL-4 PID:4 CID:132218884
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_22}  #NRCEL-4 PID:4 CID:132218884
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_23}  #NRCEL-4 PID:4 CID:132218884
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_24}  #NRCEL-4 PID:4 CID:132218884
    ...  AND  Run Keyword and ignore error    Unblock All Cells  rat=NR  timeout=120s
    ...  AND  Start UE Traffic  expected_pci=4  NR_call=${true}
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:7 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:7 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #NRCEL-55 PID:55 CID:132218935
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #NRCEL-55 PID:55 CID:132218935
    ...  AND  Start UE Traffic  expected_pci=55  NR_call=${true}
    Run Keyword IF  '${MRBTS_ID}'=='10817'    Wait For Inactive Fault  faultID=49  timeout=2min
    Run Keyword IF  '${MRBTS_ID}'=='10817'    Disallow Fault In Watchdog  faultID=49  #fault_name: Cell blocked

    Run Keyword If  '${MRBTS_ID}' == '10819'  Run Keywords
    ...  Set Test Variable  ${ue}  NOKIA83_NR
    ...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-552011 PID:551 CID:708968448
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-552011 PID:551 CID:708968448
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-552011 PID:551 CID:708968448
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-552011 PID:551 CID:708968448
    ...  AND  Airplane Mode On/Off
    ...  AND  Log To Console  Cell ID 708985383 equals 02a4242270 after being ciphered
    ...  AND  Start UE traffic  expected_pci=02a4242270  NR_call=${true}  5G_type=SA
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #NRCEL-552012 PID:811 CID:708968449
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #NRCEL-552012 PID:811 CID:708968449
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #NRCEL-552012 PID:811 CID:708968449
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #NRCEL-552012 PID:811 CID:708968449
    ...  AND  Airplane Mode On/Off
    ...  AND  Log To Console  Cell ID 708985384 equals 02a4242280 after being ciphered
    ...  AND  Start UE traffic  expected_pci=02a4242280  NR_call=${true}  5G_type=SA
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}  #NRCEL-552013 PID:812 CID:708968450
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #NRCEL-552013 PID:812 CID:708968450
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #NRCEL-552013 PID:812 CID:708968450
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #NRCEL-552013 PID:812 CID:708968450
    ...  AND  Airplane Mode On/Off
    ...  AND  Log To Console  Cell ID 708985385 equals 02a4242290 after being ciphered
    ...  AND  Start UE traffic  expected_pci=02a4242290  NR_call=${true}  5G_type=SA[[O

    Run Keyword If  '${MRBTS_ID}' == '10810'   Run Keywords
    ...  Set Test Variable  ${ue}  XIAOMI12
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-3
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-1 PID:1 CID:2767361
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-1 PID:1 CID:2767361
	...  AND  Start UE traffic  expected_pci=1  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-2 PID:2 CID:2767362
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-2 PID:2 CID:2767362
	...  AND  Start UE traffic  expected_pci=2  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-3
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-3 PID:3 CID:2767368
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-3 PID:3 CID:2767368
	...  AND  Start UE traffic  expected_pci=3  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-3
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-4 PID:4 CID:2767364
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-4 PID:4 CID:2767364
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}  #LNCEL-4 PID:4 CID:2767364
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #LNCEL-4 PID:4 CID:2767364
	...  AND  Start UE traffic  expected_pci=4  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-4 PID:4 CID:2767364
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-4 PID:4 CID:2767364
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-4 PID:4 CID:2767364
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-4 PID:4 CID:2767364
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #NRCEL-0 PID:0 CID:177111040
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #NRCEL-0 PID:0 CID:177111040
	...  AND  Start UE traffic  expected_pci=0  NR_call=${true}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-4 PID:4 CID:2767364
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-4 PID:4 CID:2767364
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-4 PID:4 CID:2767364
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-4 PID:4 CID:2767364
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #NRCEL-1 PID:1 CID:177111041
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #NRCEL-1 PID:1 CID:177111041
	...  AND  Start UE traffic  expected_pci=1  NR_call=${true}

    [Teardown]  Run keywords  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Unbarring all cells


Connect to SMOD
    [Documentation]  Connect to master BTS using variables from __init__.py
    [Arguments]  ${alias}=SMOD_CONNECTION_ALIAS

    ssh.connect_to  hostname=192.168.255.129  username=toor4nsn  password=oZPS0POrRieRtu  alias=${alias}

    RETURN  ${alias}


Start TCPdump ssh
    [Documentation]  Start TCPdump on SMOD via SSH connection
    [Arguments]  ${alias}=SMOD_CONNECTION_ALIAS  ${interface}=any  ${filename}=smod_trace

    ssh.send_command  command=tcpdump -i ${interface} -w "/tmp/${filename}.pcap"  connection=${alias}


Start tracing on SMOD
    [Documentation]  Connect to SMOD and start TCPdump on same SSH session
    [Arguments]  ${filename}=smod_trace  ${interface}=any

    ${connection_alias}  L3_call.Connect to SMOD
    Start TCPdump ssh  ${connection_alias}  ${interface}  ${filename}


Stop tracing and download logs from SMOD
    [Documentation]  Stop tcpdum, download to test_result location and clear SMOD /tmp
    [Arguments]  ${filename}=smod_trace

    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${alias}  L3_call.Connect to SMOD
    ssh.execute  command=killall tcpdump  connection=${alias}
    ssh.execute  command=chmod 777 /tmp/${filename}_${timestamp}.pcap  connection=${alias}
    ssh.download_file  /tmp/${filename}.pcap  ${RESULTS}/${filename}_${timestamp}.pcap  connection=${alias}
    ssh.execute  command=rm "/tmp/${filename}.pcap"  connection=${alias}

    RETURN  ${RESULTS}/${filename}_${timestamp}.pcap


Teardown if call failed
    Log  L3 call failed  WARN
    Run keyword and ignore error  Stop Tracing and download logs from SMOD
    Unbarring all cells
    Run keyword and ignore error  Unblock All Cells  rat=NR  timeout=120s


Get Value From PCAP
    [Documentation]  Reading packets based on Wireshark display filter syntax.
    [Arguments]  ${pcap_file}  ${filter_syntax}  ${field_to_print}

    ${output}  Run  tshark -r ${pcap_file} -Y "${filter_syntax}" -T fields -e ${field_to_print}
    ${output_lines}  split string   ${output}  separator=,
    ${first_request}  Get From List  ${output_lines}  0

    RETURN  ${first_request}


Verify 5G NSA Attach
    [Arguments]  ${ue}  ${expected_cell}  ${ue_type}=non_askey

    Sleep  5s  time to check if atach is stable
    ${pcap_file}  Stop Tracing and download logs from SMOD
    ${nr_pci}  Get Value From PCAP  ${pcap_file}  ${SgNBAdditionRequest}  ${physCellId}
    ${CELL_INFO}  IF  '${ue_type}'=='non_askey'  ue.Get UE Info  ${ue}  CELL_INFO
    IF  '${ue_type}'=='non_askey'  Should Be Equal  ${CELL_INFO}[cellType]  LTENR   ${ue} not attached to 5G NSA  values=False
    ${nr_state}  Set Variable If  '${ue_type}'=='non_askey'  ${CELL_INFO}[nrState]
    ${nr_state}  Set Variable If  '${nr_state}'=='None'  'not presented'  ${nr_state}
    ${nr_ci}  Set Variable If  '${ue_type}'=='non_askey'  ${CELL_INFO}[nci]
    ${nr_ci}  Set Variable If  '${nr_ci}'=='-1'  'not presented'
    ${CELL_ID}  IF  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  CELL_ID
    ${SIGNAL_STRENGTH}  IF  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  SIGNAL_STRENGTH
#    Log To Console  \nUE attach verification
    IF  '${ue_type}'=='non_askey' or '${ue_type}'=='askey'  Should Be Equal  ${expected_cell}  ${nr_pci}
    ...  ${ue} not attached to expected physical cell ID: ${expected_cell}  values=False
    Log To Console  ${ue} attached to 5G NSA:
    IF  '${ue_type}'=='non_askey'
        Log To Console   LNCEL state: CONNECTED, Physical cell ID: ${CELL_INFO}[ltePci], cell ID: ${CELL_INFO}[ci], RSRP: ${CELL_INFO}[lteDbm] dBm
        Log To Console   NRCEL state: ${nr_state}, Physical cell ID: ${nr_pci}, cell ID: ${nr_ci}, RSRP: ${CELL_INFO}[nrDbm] dBm
    END
    IF  '${ue_type}'=='askey'
        Log To Console   LNCEL state: CONNECTED, Physical cell ID: 'not presented', cell ID: ${CELL_ID}, RSRP: 'not presented'
        Log To Console   NRCEL state: CONNECTED, Physical cell ID: ${nr_pci}, cell ID: 'not presented', ${SIGNAL_STRENGTH}
    END


Verify 5G SA Attach
    [Arguments]  ${ue}  ${expected_cell}  ${ue_type}=non_askey

    Sleep  20s  time to check if atach is stable
    ${pcap_file}  Stop Tracing and download logs from SMOD
    ${nr_pci}  Get Value From PCAP  ${pcap_file}  ${InitialULRRCMessageTransfer}  ${nRCellIdentity}
    Log to console  ${nr_pci}
    ${CELL_INFO}  IF  '${ue_type}'=='non_askey'  ue.Get UE Info  ${ue}  CELL_INFO
    IF  '${ue_type}'=='non_askey'  Should Be Equal  ${CELL_INFO}[cellType]  NR   ${ue} not attached to 5G SA  values=False
    ${nr_operator}  Set Variable If  '${ue_type}'=='non_askey'  ${CELL_INFO}[networkOperator]
    ${nr_ci}  Set Variable If  '${ue_type}'=='non_askey'  ${CELL_INFO}[nci]
    ${nr_ci}  Set Variable If  '${nr_ci}'=='-1'  'not presented'
    ${CELL_ID}  IF  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  CELL_ID
    ${SIGNAL_STRENGTH}  IF  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  SIGNAL_STRENGTH
#    Log To Console  \nUE attach verification
    IF  '${ue_type}'=='non_askey' or '${ue_type}'=='askey'  Should Be Equal  ${expected_cell}  ${nr_pci}
    ...  ${ue} not attached to expected physical cell ID: ${expected_cell}  values=False
    Log To Console  ${ue} attached to 5G SA:
    IF  '${ue_type}'=='non_askey'  Log To Console  Physical cell ID: ${nr_pci}, cell ID: ${nr_ci}
    IF  '${ue_type}'=='askey'
        Log To Console  NRCEL state: CONNECTED, Physical cell ID: ${nr_pci}, cell ID: 'not presented', ${SIGNAL_STRENGTH}, operator: ${nr_operator}
    END


Verify 4G Attach
    [Arguments]  ${ue}  ${expected_cell}  ${ue_type}=non_askey

    ${CELL_INFO}  IF  '${ue_type}'=='non_askey'  ue.Get UE Info  ${ue}  CELL_INFO
    IF  '${ue_type}'=='non_askey' and '${CELL_INFO}[cellType]'=='LTE'
        ${pci}  Convert To String  ${CELL_INFO}[pci]
    ELSE IF  '${ue_type}'=='non_askey' and '${CELL_INFO}[cellType]'=='LTENR'
        ${pci}  Convert To String  ${CELL_INFO}[ltePci]
    END
    IF  '${ue_type}'=='non_askey' and '${CELL_INFO}[cellType]'=='LTE'
        ${dBm}  Convert To String  ${CELL_INFO}[dbm]
    ELSE IF  '${ue_type}'=='non_askey' and '${CELL_INFO}[cellType]'=='LTENR'
        ${dBm}  Convert To String  ${CELL_INFO}[lteDbm]
    END
    ${CELL_ID}  IF  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  CELL_ID
    ${CELL_ID}  Convert To String  ${CELL_ID}
    ${SIGNAL_STRENGTH}  IF  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  SIGNAL_STRENGTH
#    Log To Console  \nUE attach verification
    Log To Console  \n
    IF  '${ue_type}'=='askey'  Should Be Equal  ${CELL_ID}  ${expected_cell}
    ...  ${ue} not attached to expected cell ID: ${expected_cell}   values=False
    IF  '${ue_type}'=='non_askey'  Should Be Equal  ${pci}  ${expected_cell}
    ...  ${ue} not attached to expected physical cell ID: ${expected_cell}   values=False
    Log To Console  ${ue} attached to LTE:
    IF  '${ue_type}'=='non_askey'  Log To Console  LNCEL state: CONNECTED, Physical cell ID: ${pci}, cell ID: ${CELL_INFO}[ci], RSRP: ${dBm} dBm
    IF  '${ue_type}'=='askey'  Log To Console  LNCEL state: CONNECTED, Physical cell ID: 'not presented', cell ID: ${CELL_ID}, ${SIGNAL_STRENGTH}


Check Average Tput
    [Arguments]  ${dt_name}  ${direction}

    ${avg_tput}  ue.Get Average Throughput   dt_name=${dt_name}
    ${avg_tput}  Evaluate  ${avg_tput} / 1000
    ${avg_tput}  Evaluate  "%.2f" % ${avg_tput}
    Log To Console  AVERAGE ${direction} TPUT: ${avg_tput} Mbit/s


Execute Command On UE PC
    [Documentation]  Perform adb command on UE PC.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  **Input Parameters:**
    ...
    ...  +--------------------------------------------------+---------------------------------+
    ...  | Command                                          | Description                     |
    ...  +==================================================+=================================+
    ...  | adb reboot                                       | reboot all devices              |
    ...  +--------------------------------------------------+---------------------------------+
    ...  | adb shell svc data enable                        | mobile data on                  |
    ...  +--------------------------------------------------+---------------------------------+
    ...  | adb shell svc data disable                       | mobile data off                 |
    ...  +--------------------------------------------------+---------------------------------+
    ...  | adb shell cmd connectivity airplane-mode enable  | airplane mode on                |
    ...  +--------------------------------------------------+---------------------------------+
    ...  | adb shell cmd connectivity airplane-mode disable | airplane mode off               |
    ...  +--------------------------------------------------+---------------------------------+
    ...  | adb shell svc wifi enable                        | wifi on                         |
    ...  +--------------------------------------------------+---------------------------------+
    ...  | adb shell svc wifi disable                       | wifi off                        |
    ...  +--------------------------------------------------+---------------------------------+
    ...
    ...  **Example of simple usage:**
    ...  Execute Command On UE PC  adb shell cmd connectivity airplane-mode enable
    [Arguments]  ${command}

	Log To Console  \nCommand used is ${command}
    ${ue_pc_ip}  ${ue_pc_log}  ${ue_pc_pass}  Get UE PC Data
    ${if_pingable}  Run Keyword And Return Status  Wait Until Keyword Succeeds  1min  15s  Check If Host Is Reachable  IP=${ue_pc_ip}
    IF  ${if_pingable}
        Log  UE PC is reachable
    ELSE
        Fail  msg= UE PC is not reachable. \nTurn on UE PC.
    END
    ${if_connected}  Run Keyword And Return Status  Wait Until Keyword Succeeds  2min  30s  ssh.connect to  ${ue_pc_ip}  ${ue_pc_log}  ${ue_pc_pass}
    IF  ${if_connected}
        Log  SSH connection to UE PC has been established
        Log To Console  Command execution: ${command}
        ssh.execute  command=${command}
    ELSE
        Fail  SSH connection failed
    END


Get UE PC Data
    [Documentation]  Get init parametrs: ue_pc_ip, login and password.

    ${ue_pc_ip}  Set Variable  ${tl.ues[0].ue_pc_address}
    ${ue_pc_log}  Set Variable  ${tl.ues[0].ssh_connection_details.username}
    ${ue_pc_pass}  Set Variable  ${tl.ues[0].ssh_connection_details.password}

    RETURN  ${ue_pc_ip}  ${ue_pc_log}  ${ue_pc_pass}


Airplane Mode On/Off
    [Documentation]  Set airplane on/off on UE via adb commands.

	Execute Command On UE PC  adb shell cmd connectivity airplane-mode enable
	Log  Airplane mode is enabled  console=${True}
	Sleep  30
	Execute Command On UE PC  adb shell cmd connectivity airplane-mode disable
	Log  Airplane mode is disabled  console=${True}
	Sleep  10


Call For CB010397 LTE
    [Arguments]  ${tput_dl}  ${duration}

    attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
    Set attenuator value on all ports  set_value_db=${90}
    Log To Console  \L3 call preparation
    Log To Console  \MRBTSID is ${MRBTS_ID} and cellID is '${cell_for_call_ID}[0]'
	IF  '${MRBTS_ID}'=='10807' and '${cell_for_call_ID}[0]' == '48071'
        Adjust attenuation value for port  set_value_db=${90}  port=${att_port_1}  #LNCEL-4 PID:4 CID:2198532
        Adjust attenuation value for port  set_value_db=${90}  port=${att_port_2}
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}
        Log to console  Adjust LNCEL 48071
        Start UE Traffic  expected_pci=41  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    END
    IF  '${MRBTS_ID}'=='10807' and '${cell_for_call_ID}[0]' == '48070'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-4 PID:4 CID:2198532
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}
        Adjust attenuation value for port  set_value_db=${90}  port=${att_port_3}
        Adjust attenuation value for port  set_value_db=${90}  port=${att_port_4}
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-58070
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48071
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48072
        Log to console  Adjust LNCEL 48070
        Start UE Traffic  expected_pci=40  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    END
    IF  '${MRBTS_ID}'=='10807' and '${cell_for_call_ID}[0]' == '48072'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-4 PID:4 CID:2198532
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}
        Adjust attenuation value for port  set_value_db=${90}  port=${att_port_3}
        Adjust attenuation value for port  set_value_db=${90}  port=${att_port_4}
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-58072
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48070
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48071
        Log to console  Adjust LNCEL 48072
        Start UE Traffic  expected_pci=42  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    END
    IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48187'
        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-48187 PID:408 CID:2769429
        Log to console  Adjust LNCEL 48187
        Start UE Traffic  expected_pci=408  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48148'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-48148
        Log to console  Adjust LNCEL 48148
        Start UE Traffic  expected_pci=342  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48188'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-48188
        Log to console  Adjust LNCEL 48188
        Start UE Traffic  expected_pci=361  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48149'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-48149
        Log to console  Adjust LNCEL 48149
        Start UE Traffic  expected_pci=25  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48189'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-48189
        Log to console  Adjust LNCEL 48189
        Start UE Traffic  expected_pci=65  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48138'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-48138
        Log to console  Adjust LNCEL 48138
        Start UE Traffic  expected_pci=338  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48184'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-48184
        Log to console  Adjust LNCEL 48184
        Start UE Traffic  expected_pci=414  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48181'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-48181
        Log to console  Adjust LNCEL 48181
        Start UE Traffic  expected_pci=126  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48180'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-48180
        Log to console  Adjust LNCEL 48180
        Start UE Traffic  expected_pci=369  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48185'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48185
        Log to console  Adjust LNCEL 48185
        Start UE Traffic  expected_pci=352  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48182'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48182
        Log to console  Adjust LNCEL 48182
        Start UE Traffic  expected_pci=7  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48140'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48140
        Log to console  Adjust LNCEL 48140
        Start UE Traffic  expected_pci=379  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48186'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48186
        Log to console  Adjust LNCEL 48186
        Start UE Traffic  expected_pci=68  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48183'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48183
        Log to console  Adjust LNCEL 48183
        Start UE Traffic  expected_pci=41  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48147'
	    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48147
        Log to console  Adjust LNCEL 48147
        Start UE Traffic  expected_pci=446  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    END
    Set attenuator value on all ports  set_value_db=${90}
    Log To Console  \L3 Call finished
    [Teardown]  Set attenuator value on all ports  set_value_db=${90}


Call For CB010397 LTE adapted
    [Arguments]  ${tput_dl}  ${duration}  ${setup_att_values}  ${restore_att_values}

    IF  '${setup_att_values}'=='true'
        attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
        Set attenuator value on all ports  set_value_db=${90}
    END
    Log To Console  \L3 call preparation
    Log To Console  \MRBTSID is ${MRBTS_ID} and cellID is '${cell_for_call_ID}[0]'
	IF  '${MRBTS_ID}'=='10807' and '${cell_for_call_ID}[1]' == '48071'
        IF  '${setup_att_values}'=='true'
            Adjust attenuation value for port  set_value_db=${90}  port=${att_port_1}  #LNCEL-4 PID:4 CID:2198532
            Adjust attenuation value for port  set_value_db=${90}  port=${att_port_2}
            Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}
            Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}
        END
        Log to console  Adjust LNCEL 48071
        Start UE Traffic  expected_pci=41  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    END
    IF  '${MRBTS_ID}'=='10807' and '${cell_for_call_ID}[1]' == '48070'
        IF  '${setup_att_values}'=='true'
            Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-4 PID:4 CID:2198532
            Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}
            Adjust attenuation value for port  set_value_db=${90}  port=${att_port_3}
            Adjust attenuation value for port  set_value_db=${90}  port=${att_port_4}
        END
        Log to console  Adjust LNCEL 48070
        Start UE Traffic  expected_pci=40  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    END
    IF  '${MRBTS_ID}'=='10807' and '${cell_for_call_ID}[1]' == '48072'
        IF  '${setup_att_values}'=='true'
            Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-4 PID:4 CID:2198532
            Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}
            Adjust attenuation value for port  set_value_db=${90}  port=${att_port_3}
            Adjust attenuation value for port  set_value_db=${90}  port=${att_port_4}
        END
        Log to console  Adjust LNCEL 48072
        Start UE Traffic  expected_pci=42  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    END
    IF  '${MRBTS_ID}'=='10817' and '${cell_for_call_ID}[1]' == '203'
        IF  '${setup_att_values}'=='true'
            Adjust attenuation value for port  set_value_db=${0}  port=${att_port_17}
            Adjust attenuation value for port  set_value_db=${0}  port=${att_port_18}
        END
        Log to console  Adjust LNCEL 203
        Start UE Traffic  expected_pci=203  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    END
    IF  '${MRBTS_ID}'=='10817' and '${cell_for_call_ID}[1]' == '204'
        IF  '${setup_att_values}'=='true'
            Adjust attenuation value for port  set_value_db=${0}  port=${att_port_17}  #LNCEL-4 PID:4 CID:2198532
            Adjust attenuation value for port  set_value_db=${0}  port=${att_port_18}
        END
        Log to console  Adjust LNCEL 204
        Start UE Traffic  expected_pci=204  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    END
    IF  '${MRBTS_ID}'=='10817' and '${cell_for_call_ID}[1]' == '205'
        IF  '${setup_att_values}'=='true'
            Adjust attenuation value for port  set_value_db=${0}  port=${att_port_17}  #LNCEL-4 PID:4 CID:2198532
            Adjust attenuation value for port  set_value_db=${0}  port=${att_port_18}
        END
        Log to console  Adjust LNCEL 205
        Start UE Traffic  expected_pci=205  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    END
    IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48187'
        IF  '${setup_att_values}'=='true'
            Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-48187 PID:408 CID:2769429
        END
        Log to console  Adjust LNCEL 48187
        Start UE Traffic  expected_pci=408  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48148'
	    IF  '${setup_att_values}'=='true'
	        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-48148
        END
        Log to console  Adjust LNCEL 48148
        Start UE Traffic  expected_pci=342  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48188'
	    IF  '${setup_att_values}'=='true'
	        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-48188
        END
        Log to console  Adjust LNCEL 48188
        Start UE Traffic  expected_pci=361  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48149'
	    IF  '${setup_att_values}'=='true'
	        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-48149
        END
        Log to console  Adjust LNCEL 48149
        Start UE Traffic  expected_pci=25  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48189'
	    IF  '${setup_att_values}'=='true'
	        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-48189
        END
        Log to console  Adjust LNCEL 48189
        Start UE Traffic  expected_pci=65  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48138'
	    IF  '${setup_att_values}'=='true'
	        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-48138
        END
        Log to console  Adjust LNCEL 48138
        Start UE Traffic  expected_pci=338  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48184'
	    IF  '${setup_att_values}'=='true'
	        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-48184
        END
        Log to console  Adjust LNCEL 48184
        Start UE Traffic  expected_pci=414  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48181'
	    IF  '${setup_att_values}'=='true'
	        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-48181
        END
        Log to console  Adjust LNCEL 48181
        Start UE Traffic  expected_pci=126  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48180'
	    IF  '${setup_att_values}'=='true'
	        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-48180
        END
        Log to console  Adjust LNCEL 48180
        Start UE Traffic  expected_pci=369  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48185'
	    IF  '${setup_att_values}'=='true'
	        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48185
        END
        Log to console  Adjust LNCEL 48185
        Start UE Traffic  expected_pci=352  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48182'
	    IF  '${setup_att_values}'=='true'
	        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48182
        END
        Log to console  Adjust LNCEL 48182
        Start UE Traffic  expected_pci=7  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48140'
	    IF  '${setup_att_values}'=='true'
	        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48140
        END
        Log to console  Adjust LNCEL 48140
        Start UE Traffic  expected_pci=379  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48186'
	    IF  '${setup_att_values}'=='true'
	        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48186
        END
        Log to console  Adjust LNCEL 48186
        Start UE Traffic  expected_pci=68  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48183'
	    IF  '${setup_att_values}'=='true'
	        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48183
        END
        Log to console  Adjust LNCEL 48183
        Start UE Traffic  expected_pci=41  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
	ELSE IF  '${MRBTS_ID}'=='10818' and '${cell_for_call_ID}[1]' == '48147'
	    IF  '${setup_att_values}'=='true'
	        Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-48147
        END
        Log to console  Adjust LNCEL 48147
        Start UE Traffic  expected_pci=446  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    END
    IF  '${restore_att_values}'=='true'
        Set attenuator value on all ports  set_value_db=${90}
    END
    Log To Console  \L3 Call finished
	#[Teardown]  Set attenuator value on all ports  set_value_db=${90}

Cell barring for CB010397 LTE
	IF  '${MRBTS_ID}'=='10811' and '${2nd_LNCEL_ID}' == '48111'
        Log to console  Barring to call LNCEL 48111
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48111
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48112
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48113
    ELSE IF  '${MRBTS_ID}'=='10811' and '${2nd_LNCEL_ID}' == '48112'
        Log to console  Barring to call LNCEL 48112
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48112
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48111
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48113
    ELSE IF  '${MRBTS_ID}'=='10811' and '${2nd_LNCEL_ID}' == '48113'
        Log to console  Barring to call LNCEL 48113
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48113
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48112
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48111
	ELSE
	    Log to console  Barring not needed
	END
	IF  '${MRBTS_ID}'=='10817' and '${2nd_LNCEL_ID}' == '203'
        Log to console  Barring to call LNCEL 203
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-203
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-204
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-205
    ELSE IF  '${MRBTS_ID}'=='10817' and '${2nd_LNCEL_ID}' == '204'
        Log to console  Barring to call LNCEL 204
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-204
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-203
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-205
    ELSE IF  '${MRBTS_ID}'=='10817' and '${2nd_LNCEL_ID}' == '205'
        Log to console  Barring to call LNCEL 205
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-205
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-203
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-204
	ELSE
	    Log to console  Barring not needed
	END
	IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48187'
        Log to console  Barring to call LNCEL 48187  #LNCEL-48187 PID:408 CID:2769429
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48187
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48148
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48148'
	    Log to console  Barring to call LNCEL 48148  #LNCEL-48148
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48148
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48187
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48188'
	    Log to console  Barring to call LNCEL 48188  #LNCEL-48188
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48188
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48149
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48149'
	    Log to console  Barring to call LNCEL 48149  #LNCEL-48149
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48149
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48188
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48189'
	    Log to console  Barring to call LNCEL 48189  #LNCEL-48189
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48189
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48138
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48138'
	    Log to console  Barring to call LNCEL 48138  #LNCEL-48138
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48138
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48189
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48184'
        Log to console  Barring to call LNCEL 48184  #LNCEL-48184
        Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48184
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48181
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48180
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-41
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48181'
	    Log to console  Barring to call LNCEL 48181  #LNCEL-48181
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48181
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48184
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48180
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-41
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48180'
	    Log to console  Barring to call LNCEL 48180  #LNCEL-48180
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48180
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48184
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48181
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-41
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48185'
	    Log to console  Barring to call LNCEL 48185    #LNCEL-48185
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48185
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48182
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48140
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-42
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-22
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48182'
	    Log to console  Barring to call LNCEL 48182        #LNCEL-48182
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48182
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48185
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48140
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-42
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-22
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48140'
	    Log to console  Barring to call LNCEL 48140     #LNCEL-48140
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48140
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48182
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48185
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-42
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-22
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48186'
	    Log to console  Barring to call LNCEL 48186     #LNCEL-48186
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48186
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48183
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48147
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-43
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-23
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48183'
	    Log to console  Barring to call LNCEL 48183    #LNCEL-48183
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48183
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48186
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48147
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-43
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-23
	ELSE IF  '${MRBTS_ID}'=='10818' and '${2nd_LNCEL_ID}' == '48147'
	    Log to console  Barring to call LNCEL 48147  #LNCEL-48147
	    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48147
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48183
	    Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-48186
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-43
        Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-23
    ELSE
        Log to console  Barring not needed
    END
