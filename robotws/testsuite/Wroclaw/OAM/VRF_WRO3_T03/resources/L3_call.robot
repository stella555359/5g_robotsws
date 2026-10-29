*** Settings ***
#Resource    taf/rfrl/l3_call/call_manager.robot
Library         taf.ue  WITH NAME  ue
Library         taf.hw.rf_attenuator   WITH NAME  attenuator
Library         DateTime
Library        ../resources/python_lib/tshark_pcap.py
Library        ../resources/python_lib/uuf4all_attach_test.py
Resource       ../resources/common.robot

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
...  20.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-152 - Add possibility to remote call on TL:101035
...  06.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-198 - Add possibility to remote call on TL:101046
...  24.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-305 - Add Xiaomi 12 support
...  07.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-302 - add new KW's "Call For CB008745 LTE", "Start UE DL/UL traffic"
...  09.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-280 - add KWs "Execute Command On UE PC", "Get UE PC Data", "Get YAML Capabilities",
...                                                                 "Airplane Mode On/Off"
...  20.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-329 - add new KW "Get Value From PCAP"
...  08.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-434 - add new KW "Reboot And Open Diagnostic Ports"
...  08.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-408 - Add possibility to remote call on TL:8391, new KW Verify 5G SA Attach
...  08.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-445 - enb8391 added to KW Call For CB008745 LTE
...  26.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-458 - new KW Cell baring for CB008745 and modification of Check attach condition for SA
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - new KW Teardown if call failed
...  07.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-476 - new KW Cell barring for CB008745 LTE
...  07.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-490 - Added enb55201 to L3 call and Call for CB008745 KWs
...  15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-489 - New KWs Unbarring all cells plus NR/LTE variants
...  14.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-489 - Add FID:49 to allowed during L3 call; unblock all cells in teardown
...  26.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-553 - Add enb5098 to KW L3 call
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
	...              quantity of ports
	[Arguments]   ${set_value_db}
	FOR  ${i}  IN  @{att_port_numbers}
		attenuator.set_attenuation  value=${set_value_db}  port=${i}
		${read_value_db}  attenuator.read_attenuation  port=${i}
		Wait Until Keyword Succeeds  3x  200ms  Should Be Equal  ${read_value_db}  ${set_value_db}
	END

Adjust attenuation value for port
    [Documentation]  This keyword set expected attenuation value on defined port
    [Arguments]   ${set_value_db}  ${port}
    attenuator.set_attenuation  value=${set_value_db}  port=${port}
    ${read_value_db}  attenuator.read_attenuation  port=${port}
    Wait Until Keyword Succeeds  3x  200ms  Should Be Equal  ${read_value_db}  ${set_value_db}


Check Attach Condition
    [Documentation]  In case attach failed, depends on condition KW tries to make recovery action
    ...  by airplane mode on/off or ue reboot.
    [Arguments]  ${attach_condition}
    ${ue_eurtra_cell_id}  ${ue_cell_pci}  ${attach_to_enb}  ${attached_to_nr_state}  Get Info About Attached Cell
    Run Keyword If  '${attach_condition}'=='True' and '${attached_to_nr_state}'=='5G_SA'
    ...  Log to console  UE Attached To SA:${attached_to_nr_state}
    ...  ELSE IF  '${attach_condition}'=='True' and '${attach_to_enb}'=='${MRBTS_ID}'    #MRBTS_ID podmiana tl.enbs[0].instance_id}
    ...  Log to console  Attach Condition Met
    ...  ELSE IF  '${attach_condition}'=='True' and '${attach_to_enb}'!='${MRBTS_ID}'  Run Keywords
    ...  Log to console  UE Attached To Wrong TL:'${attach_to_enb}
    ...  AND  ue.Stop Using UE  ${ue}
    ...  AND  Airplane Mode On/Off
    ...  AND  Attach UE
    ...  AND  Get Info About Attached Cell
    ...  AND  Should Be True  '${attach_to_enb}'=='${MRBTS_ID}'
    ...  ELSE IF  '${attach_condition}'=='False'  Run Keywords
    ...  Reboot UE  120
    ...  AND  ue.Stop Using UE  ${ue}
    ...  AND  Attach UE
    ...  AND  Get Info About Attached Cell
    ...  AND  Should Be True  '${attach_to_enb}'=='${MRBTS_ID}'

Get Info About Attached Cell
    ${ue_eurtra_cell_id}=  Get Ue Info  ${ue}  CELL_ID
    ${ue_cell_pci}=  Get Ue Info  ${ue}  PCI
    ${attach_to_enb}=  Get Ue Info  ${ue}  ENB_ID
    ${attached_to_nr_state}=  Get Ue Info  ${ue}  NR_STATE
    Set Test Variable  ${ue_eurtra_cell_id}
    Set Test Variable  ${ue_cell_pci}
    Set Test Variable  ${attach_to_enb}
    Set Test Variable  ${attached_to_nr_state}
    Log to console  UE Attached To Cell Id: ${ue_cell_pci} Eutra Id: ${ue_eurtra_cell_id} ENB: ${attach_to_enb}
    [Return]  ${ue_eurtra_cell_id}  ${ue_cell_pci}  ${attach_to_enb}  ${attached_to_nr_state}


Start UE Traffic
    [Arguments]  ${expected_pci}  ${NR_call}  ${dt_name_1}=DT_UL  ${dt_name_2}=DT_DL  ${tput_ul}=300  ${tput_dl}=50  ${duration}=7
    ...  ${5G_type}=NSA  ${ue_id}=0
    Start tracing on SMOD
    ${attach_condition}=  Attach UE  ${ue_id}
    Check Attach Condition  ${attach_condition}
    Run Keyword If  '${NR_call}'=='${true}' and '${5G_type}'=='NSA'
    ...  Wait Until Keyword Succeeds  3x  1min  Verify 5G NSA Attach  ${ue}  ${expected_pci}
    Run Keyword If  '${NR_call}'=='${true}' and '${5G_type}'=='SA'
    ...  Wait Until Keyword Succeeds  3x  1min  Verify 5G SA Attach  ${ue}  ${expected_pci}
    Run Keyword If  '${NR_call}'=='${false}'
    ...  Wait Until Keyword Succeeds  3x  1min  Verify LTE Attach  ${ue}  ${expected_pci}
    ue.Start Data Transfer  ${dt_name_1}  ${ue}  ul  duration=120s  throughput=${tput_ul}Mbits/sec  protocol=udp  packet=1400
	ue.Start Data Transfer  ${dt_name_2}  ${ue}  dl  duration=120s  throughput=${tput_dl}Mbits/sec  protocol=udp  packet=1400
	${duration}   Evaluate   ${duration} - 1
	Sleep  ${duration}s  reason=Wait for throughput stabilization
    ue.Check Data Transfer Is Alive  ${dt_name_1}
    ue.Check Data Transfer Is Alive  ${dt_name_2}
	Sleep  1s
    Check Average Tput  direction=ul  dt_name=${dt_name_1}
    Check Average Tput  direction=dl  dt_name=${dt_name_2}
    ue.Stop Data Transfers For All UEs
    Sleep  5s  reason=Wait for UE reattach
    ${pcap_path}  Run Keyword If  '${NR_call}'=='${false}'  Stop Tracing and download logs from SMOD
    [Teardown]  Run Keyword If  '${ue}'=='NOKIA83' or '${ue}'=='XIAOMI12' or '${ue}'=='NOKIA83_LTE' or '${ue}'=='NOKIA83_NR'
    ...  Run Keywords  ue.Detach Ue  ${ue}  AND  ue.Stop Using Ue  ${ue}
    ...  ELSE IF  '${ue}'=='SAMSUNG_J4_PLUS' or '${ue}'=='OP6_LTE' or '${ue}'=='OP9_5G'  Run Keyword  ue.Stop Using Ue  ${ue}

Prepare UE
    [Arguments]  ${ue_id}=${0}  ${ue_cap}=0
    Log  ${ue_cap}  console=${True}
    Set Test Variable  ${ue}  ${tl.ues[${ue_id}].capabilities[0]}
    ${status}  Run Keyword And Return Status  ue.Require UE  ${ue}  ${ue}
    Log To Console  \nRequire UE ${ue}, status: ${status}
    Run Keyword If  '${status}'=='False'
    ...  Reboot And Open Diagnostic Ports  ${ue}

Reboot And Open Diagnostic Ports
    [Arguments]  ${open_diag_port}
    Execute Command On UE PC  adb -s ${ue_serial_num} reboot
    Log to console  Reboot UE serial number: ${ue_serial_num}
    Sleep  120s  reason=Wait for UE after reboot
    Run Keyword If  '${open_diag_port}'=='NOKIA83' and '${MRBTS_ID}'=='53103'
    ...  Execute Command On UE PC  adb shell su -c ${diagnostic_port_command}
    ...  ELSE IF  '${open_diag_port}'=='XIAOMI12' and '${MRBTS_ID}'=='8085'
    ...  Execute Command On UE PC  adb shell su -c ${diagnostic_port_command_1}; ${diagnostic_port_command_2}

Attach UE
    [Arguments]  ${ue_id}=${0}
    Prepare UE  ${ue_id}
    Log To Console  Attach UE ${ue}
    ${attach_condition}=  Run Keyword And Return Status  ue.Attach UE  ${ue}  timeout=60
    [Return]  ${attach_condition}

Reattach UE
    [Timeout]  2 minutes
    Run Keyword And Ignore Error  ue.Detach UE  ${ue}
    Sleep  3s  reason=Wait for UE reattach
    Log To Console  Attach UE ${ue}
    Run Keyword And Ignore Error  ue.Attach UE  ${ue}  timeout=60

Reboot UE
    [Arguments]  ${reboot_timeout}=60
    Log To Console  Reboot UE ${ue}, waiting ${reboot_timeout}s for UE booting
    ue.Reboot UE  ${ue}  timeout=${reboot_timeout}
    Sleep  5s

Verify LTE Attach
    [Arguments]  ${ue}  ${expected_cell}  ${ue_type}=non_askey
    ${CELL_INFO}  Run Keyword If  '${ue_type}'=='non_askey'  ue.Get UE Info  ${ue}  infos_list=ALL
    ${pci}  Run Keyword If  '${ue_type}'=='non_askey' and '${CELL_INFO}[cell_info][cellType]'=='LTE'  Convert To String  ${CELL_INFO}[cell_info][pci]
    ...  ELSE IF  '${ue_type}'=='non_askey' and '${CELL_INFO}[cell_info][cellType]'=='LTENR'  Convert To String  ${CELL_INFO}[cell_info][ltePci]
    ${dBm}  Run Keyword If  '${ue_type}'=='non_askey' and '${CELL_INFO}[cell_info][cellType]'=='LTE'  Convert To String  ${CELL_INFO}[cell_info][dbm]
    ...  ELSE IF  '${ue_type}'=='non_askey' and '${CELL_INFO}[cell_info][cellType]'=='LTENR'  Convert To String  ${CELL_INFO}[cell_info][lteDbm]
    ${CELL_ID}  Run Keyword If  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  CELL_ID
    ${CELL_ID}  Convert To String  ${CELL_ID}
    ${SIGNAL_STRENGTH}  Run Keyword If  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  SIGNAL_STRENGTH
    Run Keyword If  '${ue_type}'=='askey'  Should Be Equal  ${CELL_ID}  ${expected_cell}
    ...  ${ue} not attached to expected cell ID: ${expected_cell}   values=False
    Run Keyword If  '${ue_type}'=='non_askey'  Should Be Equal  ${pci}  ${expected_cell}
    ...  ${ue} not attached to expected physical cell ID: ${expected_cell}   values=False
    Log To Console  ${ue} attached to LTE:
    Run Keyword If  '${ue_type}'=='non_askey'
    ...  Log To Console   LNCEL state: CONNECTED, Physical cell ID: ${pci}, cell ID: ${CELL_INFO}[cell_info][ci], RSRP: ${dBm} dBm
    Run Keyword If  '${ue_type}'=='askey'
    ...  Log To Console   LNCEL state: CONNECTED, Physical cell ID: 'not presented', cell ID: ${CELL_ID}, ${SIGNAL_STRENGTH}

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
Call For CB008745 LTE
    [Arguments]  ${tput_dl}=50    ${duration}=45
    Run Keyword if  '${sw_prefix}'=='SBTS24R3'    Set test variable    ${duration}    45
    ...  ELSE  Set test variable    ${duration}    75
    attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
    Set attenuator value on all ports  set_value_db=${90}
    Run keyword if  '${MRBTS_ID}'=='53103' and '${2nd_LNCEL_ID}' == '1'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-85 PID:0 CID:2069760
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}
    ...  AND  Log to console  Adjust LNCEL 85
    ...  AND  Start UE Traffic  expected_pci=85  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    ...  ELSE IF  '${MRBTS_ID}'=='53103' and '${2nd_LNCEL_ID}' == '2'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-2 PID:1 CID:2069761
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-2 PID:1 CID:2069761
    ...  AND  Log to console  Adjust LNCEL 2
    ...  AND  Start UE Traffic  expected_pci=2  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    ...  ELSE IF  '${MRBTS_ID}'=='53103' and '${2nd_LNCEL_ID}' == '3'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-2 PID:2 CID:2069762
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-2 PID:2 CID:2069762
    ...  AND  Log to console  Adjust LNCEL 3
    ...  AND  Start UE Traffic  expected_pci=3  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    Run keyword if  '${MRBTS_ID}'=='8391' and '${2nd_LNCEL_ID}' == '0'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-0 PID:0 CID:2148096
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-0 PID:0 CID:2148096
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-0 PID:0 CID:2148096
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-0 PID:0 CID:2148096
    ...  AND  Log to console  Adjust LNCEL 0
    ...  AND  Start UE Traffic  expected_pci=0  duration=${duration}  NR_call=${false}  ue_id=${1}  tput_dl=${tput_dl}
    ...  ELSE IF  '${MRBTS_ID}'=='8391' and '${2nd_LNCEL_ID}' == '1'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-1 PID:1 CID:2148097
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-1 PID:1 CID:2148097
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-1 PID:1 CID:2148097
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-1 PID:1 CID:2148097
 	...  AND  Log to console  Adjust LNCEL 1
	...  AND  Start UE Traffic  expected_pci=1  duration=${duration}  NR_call=${false}  ue_id=${1}  tput_dl=${tput_dl}
    ...  ELSE IF  '${MRBTS_ID}'=='8391' and '${2nd_LNCEL_ID}' == '2'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-2 PID:2 CID:2148098
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-2 PID:2 CID:2148098
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-2 PID:2 CID:2148098
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-2 PID:2 CID:2148098
    ...  AND  Log to console  Adjust LNCEL 2
	...  AND  Start UE Traffic  expected_pci=2  duration=${duration}   NR_call=${false}  ue_id=${1}  tput_dl=${tput_dl}
	Run keyword if  '${MRBTS_ID}'=='8588' and '${2nd_LNCEL_ID}' == '107'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_23}  #LNCEL-107 PID:107 CID:2198635
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_24}
    ...  AND  Log to console  Adjust LNCEL 107
    ...  AND  Start UE Traffic  expected_pci=107  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    ...  ELSE IF  '${MRBTS_ID}'=='8588' and '${2nd_LNCEL_ID}' == '3'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #LNCEL-3 PID:3 CID:2198531
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #LNCEL-3 PID:3 CID:2198531
    ...  AND  Log to console  Adjust LNCEL 3
    ...  AND  Start UE Traffic  expected_pci=3  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    ...  ELSE IF  '${MRBTS_ID}'=='8588' and '${2nd_LNCEL_ID}' == '4'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #LNCEL-4 PID:4 CID:2198532
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #LNCEL-4 PID:4 CID:2198532
    ...  AND  Log to console  Adjust LNCEL 4
    ...  AND  Start UE Traffic  expected_pci=4  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}


Call For CB008745 NR
    [Arguments]  ${tput_dl}=50    ${duration}=45
    Run Keyword if  '${sw_prefix}'=='SBTS24R3'    Set test variable    ${duration}    45
    ...  ELSE  Set test variable    ${duration}    75
    attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
    Set attenuator value on all ports  set_value_db=${90}
    Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-1 PID:85 CID:13594369
	Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-1 PID:85 CID:13594369
    Run Keyword IF  '${MRBTS_ID}'=='53103' and '${2nd_NRCELL_ID}' == '60'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #NRCEL-1 PID 60 CID:870039553
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #NRCEL-1 PID 60 CID:870039553
    ...  AND  Log to console  Adjust NRCEL 60
    ...  ELSE IF  '${MRBTS_ID}'=='53103' and '${2nd_NRCELL_ID}' == '61'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}  #NRCEL-2 PID 61 CID:870039554
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #NRCEL-2 PID 61 CID:870039554
	...  AND  Log to console  Adjust NRCEL 61
    ...  ELSE IF  '${MRBTS_ID}'=='53103' and '${2nd_NRCELL_ID}' == '63'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #NRCEL-3 PID 63 CID:870039555
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #NRCEL-3 PID 63 CID:870039555
	...  AND  Log to console  Adjust NRCEL 63
    Run Keyword IF  '${MRBTS_ID}'=='53103'  Start UE Traffic  expected_pci=${2nd_NRCELL_ID}  NR_call=${true}  duration=${duration}  tput_dl=${tput_dl}
    Run Keyword IF  '${MRBTS_ID}'=='8391' and '${2nd_NRCELL_ID}' == '0'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-0 PID:810 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-0 PID:810 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-0 PID:810 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-0 PID:810 CID:137478144
    ...  ELSE IF  '${MRBTS_ID}'=='8391' and '${2nd_NRCELL_ID}' == '1'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-0 PID:810 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-0 PID:810 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-0 PID:810 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-0 PID:810 CID:137478144
    ...  ELSE IF  '${MRBTS_ID}'=='8391' and '${2nd_NRCELL_ID}' == '2'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-0 PID:810 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-0 PID:810 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-0 PID:810 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-0 PID:810 CID:137478144
    Run Keyword IF  '${MRBTS_ID}'=='8391'  Start UE Traffic  expected_pci=${SA_PCI}  NR_call=${true}
    ...  duration=${duration}  tput_dl=${tput_dl}  5G_type=SA
    Run Keyword IF  '${MRBTS_ID}'=='8588' and '${2nd_NRCELL_ID}' == '101'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #LNCEL-4 PID:4 CID:2198532
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #LNCEL-4 PID:4 CID:2198532
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #NRCEL-101 PID:101 CID:140705793
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #NRCEL-101 PID:101 CID:140705793
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #NRCEL-101 PID:101 CID:140705793
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #NRCEL-101 PID:101 CID:140705793
    ...  AND  Log to console  Adjust NRCEL 101
    ...  ELSE IF  '${MRBTS_ID}'=='8588' and '${2nd_NRCELL_ID}' == '3'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #LNCEL-3 PID:3 CID:2198531
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #LNCEL-3 PID:3 CID:2198531
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #NRCEL-103 PID:103 CID:140705795
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #NRCEL-103 PID:103 CID:140705795
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #NRCEL-103 PID:103 CID:140705795
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #NRCEL-103 PID:103 CID:140705795
	...  AND  Log to console  Adjust NRCEL 103
    ...  ELSE IF  '${MRBTS_ID}'=='8588' and '${2nd_NRCELL_ID}' == '4'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_23}  #LNCEL-107 PID:107 CID:2198635
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_24}  #LNCEL-107 PID:107 CID:2198635
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}  #NRCEL-104 PID:104 CID:140705796
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #NRCEL-104 PID:104 CID:140705796
	...  ELSE IF  '${MRBTS_ID}'=='8588' and '${2nd_NRCELL_ID}' == '0'
    ...  Run keywords  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #LNCEL-3 PID:3 CID:2198531
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #LNCEL-3 PID:3 CID:2198531
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-100 PID:100 CID:140705792
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-100 PID:100 CID:140705792
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-100 PID:100 CID:140705792
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-100 PID:100 CID:140705792
	...  AND  Log to console  Adjust NRCEL 100
    Run Keyword IF  '${MRBTS_ID}'=='8588'  Start UE Traffic  expected_pci=${2nd_NRCELL_ID}  NR_call=${true}  duration=${duration}  tput_dl=${tput_dl}
    Run Keyword IF  '${MRBTS_ID}'=='8070'    Allow Fault In Watchdog  faultID=49  #fault_name: Cell blocked
    Run Keyword IF  '${MRBTS_ID}'=='8070' and '${2nd_NRCELL_ID}' == '56'
    ...  Run keywords  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-56 PID:56 CID:132218936
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-56 PID:56 CID:132218936
    ...  AND  Log to console  Adjust NRCEL 56
    ...  ELSE IF  '${MRBTS_ID}'=='8070' and '${2nd_NRCELL_ID}' == '1'
    ...  Run keywords  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #NRCEL-1 PID:1 CID:132218881
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #NRCEL-1 PID:1 CID:132218881
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #NRCEL-1 PID:1 CID:132218881
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #NRCEL-1 PID:1 CID:132218881
    ...  AND  Log to console  Adjust NRCEL 1
    ...  ELSE IF  '${MRBTS_ID}'=='8070' and '${2nd_NRCELL_ID}' == '2'
    ...  Run keywords  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #NRCEL-2 PID:2 CID:132218882
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #NRCEL-2 PID:2 CID:132218882
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #NRCEL-2 PID:2 CID:132218882
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #NRCEL-2 PID:2 CID:132218882
    ...  AND  Log to console  Adjust NRCEL 2
    ...  ELSE IF  '${MRBTS_ID}'=='8070' and '${2nd_NRCELL_ID}' == '3'
    ...  Run keywords  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-4
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_21}  #NRCEL-3 PID:3 CID:132218883
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_22}  #NRCEL-3 PID:3 CID:132218883
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_23}  #NRCEL-3 PID:3 CID:132218883
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_24}  #NRCEL-3 PID:3 CID:132218883
    ...  AND  Log to console  Adjust NRCEL 3
    ...  ELSE IF  '${MRBTS_ID}'=='8070' and '${2nd_NRCELL_ID}' == '4'
    ...  Run keywords  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_21}  #NRCEL-4 PID:4 CID:132218884
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_22}  #NRCEL-4 PID:4 CID:132218884
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_23}  #NRCEL-4 PID:4 CID:132218884
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_24}  #NRCEL-4 PID:4 CID:132218884
    ...  AND  Log to console  Adjust NRCEL 4
    Run Keyword IF  '${MRBTS_ID}'=='8070'  Start UE Traffic  expected_pci=${2nd_NRCELL_ID}  NR_call=${true}
    ...  duration=${duration}  tput_dl=${tput_dl}
    Run Keyword IF  '${MRBTS_ID}'=='8070'    Run Keyword and ignore error    Unblock All Cells  rat=NR  timeout=120s
    Run Keyword IF  '${MRBTS_ID}'=='8070'    Wait For Inactive Fault  faultID=49  timeout=2min
    Run Keyword IF  '${MRBTS_ID}'=='8070'    Disallow Fault In Watchdog  faultID=49  #fault_name: Cell blocked
    Run Keyword IF  '${MRBTS_ID}'=='55201' and '${2nd_NRCELL_ID}' == '552011'
    ...  Run keywords  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-552011 PID:551 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-552011 PID:551 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-552011 PID:551 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-552011 PID:551 CID:137478144
    ...  AND  Log to console  Adjust NRCEL 552011 (ciphered ID:035e840010)
	...  AND  Set Test variable   ${SA_PCI}  035e840010
    ...  ELSE IF  '${MRBTS_ID}'=='55201' and '${2nd_NRCELL_ID}' == '552012'
    ...  Run keywords  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #NRCEL-552012 PID:811 CID:137478145
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #NRCEL-552012 PID:811 CID:137478145
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #NRCEL-552012 PID:811 CID:137478145
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #NRCEL-552012 PID:811 CID:137478145
	...  AND  Log to console  Adjust NRCEL 552012 (ciphered ID:035e840020)
	...  AND  Set Test variable   ${SA_PCI}  035e840020
    ...  ELSE IF  '${MRBTS_ID}'=='55201' and '${2nd_NRCELL_ID}' == '552013'
    ...  Run keywords  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}  #NRCEL-552013 PID:812 CID:137478146
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #NRCEL-552013 PID:812 CID:137478146
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #NRCEL-552013 PID:812 CID:137478146
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #NRCEL-552013 PID:812 CID:137478146
	...  AND  Log to console  Adjust NRCEL 552013 (ciphered ID:035e840030)
	...  AND  Set Test variable   ${SA_PCI}  035e840030
    Run Keyword IF  '${MRBTS_ID}'=='55201'  Start UE Traffic  expected_pci=${SA_PCI}  NR_call=${true}  duration=${duration}  tput_dl=100  5G_type=SA

Cell barring for CB008745 NR
    Run Keyword IF  '${MRBTS_ID}'=='8391' and '${2nd_NRCELL_ID}' == '0'
    ...  Run keywords  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-0
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
    ...  AND  Set Test variable   ${SA_PCI}  00831c0000
    ...  ELSE IF  '${MRBTS_ID}'=='8391' and '${2nd_NRCELL_ID}' == '1'
    ...  Run keywords  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-0
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
	...  AND  Log to console  Adjust NRCEL 1
	...  AND  Set Test variable   ${SA_PCI}  00831c0010
    ...  ELSE IF  '${MRBTS_ID}'=='8391' and '${2nd_NRCELL_ID}' == '2'
    ...  Run keywords  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-0
	...  AND  Log to console  Adjust NRCEL 2
	...  AND  Set Test variable   ${SA_PCI}  00831c0020
	...  ELSE  Log to console  Barring not needed

Cell barring for CB008745 LTE
	Run keyword if  '${MRBTS_ID}'=='8391' and '${2nd_LNCEL_ID}' == '0'
    ...  Run keywords  Log to console  Barring to call LNCEL 0
    ...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-0
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2
    ...  ELSE IF  '${MRBTS_ID}'=='8391' and '${2nd_LNCEL_ID}' == '1'
    ...  Run keywords  Log to console  Barring to call LNCEL 1
    ...  AND    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-0
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2
    ...  ELSE IF  '${MRBTS_ID}'=='8391' and '${2nd_LNCEL_ID}' == '2'
    ...  Run keywords  Log to console  Barring to call LNCEL 2
    ...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-0
	...  ELSE  Log to console  Barring not needed

Unbarring all LTE cells
    ${SIBs_A}  admin.get managed objects  SIB_A
    FOR    ${SIB_A}    IN    @{SIBs_A}
    ${barring_status}  Get From Dictionary  ${SIB_A['parameters']}  cellBarred
    ${SIB_NAME}  Get From Dictionary  ${SIB_A}    distName
    ${LNCEL_A_name}=  Get Regexp Matches  ${SIB_NAME}  LNCEL_A-\\d+
    ${LNCEL_A_id}=  string.Split String    ${LNCEL_A_name[0]}  LNCEL_A-
    Run keyword if  "${barring_status}"=="barred"
    ...    Run keywords    Log to console    Unbarring LNCEL-${LNCEL_A_id[1]}
    ...    AND    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${LNCEL_A_id[1]}
    END

Unbarring all NR cells
    ${NRCELLS_A}  admin.get managed objects  NRCELL_A
    FOR    ${NRCELL_A}    IN    @{NRCELLS_A}
    ${barring_status}  Get From Dictionary  ${NRCELL_A['parameters']}  cellBarred
    ${NRCELL_A_NAME}  Get From Dictionary  ${NRCELL_A}    distName
    ${NRCELL_A_id}=  string.Split String    ${NRCELL_A_name}  NRCELL_A-
    Run keyword if  "${barring_status}"=="barred"
    ...    Run keywords    Log to console    Unbarring NRCELL-${NRCELL_A_id[1]}
    ...    AND    Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${NRCELL_A_id[1]}
    END


Unbarring all cells
    Check which RAT are on given TestLine
    Run Keyword If  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'  Run Keywords
    ...  Unbarring all LTE cells
    ...  AND  Unbarring all NR cells
	...  AND  Log to console  All LTE and NR cells are unbarred
    ...  ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'  Run Keywords
    ...  Unbarring all LTE cells
	...  AND  Log to console  All LTE cells are unbarred
    ...  ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'  Run Keywords
    ...  Unbarring all NR cells
	...  AND  Log to console  All NR cells are unbarred

UE Remote Call Teardown
    ue.Detach Ue  ${ue}
    ue.Stop using Ue  ${ue}

L3 Call
    [Documentation]  This keyword check if attenuator is connected to BTS and call is possible
	Run Keyword If  '${MRBTS_ID}' == '8331'   Run Keywords
    ...  Set Test Variable  ${ue}  NOKIA83
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-1 PID:1 CID:2132737
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-1 PID:1 CID:2132737
	...  AND  Start UE traffic  expected_pci=1  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}  #LNCEL-2 PID:2 CID:2132738
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #LNCEL-2 PID:2 CID:2132738
	...  AND  Start UE traffic  expected_pci=2  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #LNCEL-3 PID:3 CID:2132739
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #LNCEL-3 PID:3 CID:2132739
	...  AND  Start UE traffic  expected_pci=3  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #LNCEL-3 PID:3 CID:2132739
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #LNCEL-3 PID:3 CID:2132739
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #NRCEL-3 PID:61 CID:136495107
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #NRCEL-3 PID:61 CID:136495107
	...  AND  Start UE traffic  expected_pci=61  NR_call=${true}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}   #LNCEL-3 PID:3 CID:2132739
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}   #LNCEL-3 PID:3 CID:2132739
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}   #NRCEL-4 PID:62 CID:136495108
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #NRCEL-4 PID:62 CID:136495108
	...  AND  Start UE traffic  expected_pci=62  NR_call=${true}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}   #LNCEL-3 PID:3 CID:2132739
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}   #LNCEL-3 PID:3 CID:2132739
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_17}  #NRCEL-5 PID:63 CID:136495109
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_18}  #NRCEL-5 PID:63 CID:136495109
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

	Run Keyword If  '${MRBTS_ID}' == '53103'   Run Keywords
    ...  Set Test Variable  ${ue}  NOKIA83
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-1 PID:85 CID:13594369
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-1 PID:85 CID:13594369
	...  AND  Start UE traffic  expected_pci=85  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-2 PID:2 CID:13594370
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-2 PID:2 CID:13594370
	...  AND  Start UE traffic  expected_pci=2  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-3 PID:3 CID:13594371
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-3 PID:3 CID:13594371
	...  AND  Start UE traffic  expected_pci=3  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-1 PID:85 CID:13594369
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-1 PID:85 CID:13594369
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #NRCEL-1 PID:60 CID:870006785
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #NRCEL-1 PID:60 CID:870006785
	...  AND  Start UE traffic  expected_pci=60  NR_call=${true}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}   #LNCEL-1 PID:85 CID:13594369
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}   #LNCEL-1 PID:85 CID:13594369
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}   #NRCEL-2 PID:61 CID:870006786
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #NRCEL-2 PID:61 CID:870006786
	...  AND  Start UE traffic  expected_pci=61  NR_call=${true}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}   #LNCEL-2 PID:2 CID:13594370
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}   #LNCEL-2 PID:2 CID:13594370
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #NRCEL-3 PID:63 CID:870006787
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #NRCEL-3 PID:63 CID:870006787
	...  AND  Start UE traffic  expected_pci=63  NR_call=${true}

	Run Keyword If  '${MRBTS_ID}' == '101046'   Run Keywords
	...  Set Test Variable  ${ue}  SAMSUNG_J4_PLUS
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-1 PID:1 CID:25867778
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-1 PID:1 CID:25867778
	...  AND  Airplane Mode On/Off
	...  AND  Start UE traffic  expected_pci=1  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-2 PID:2 CID:25867777
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-2 PID:2 CID:25867777
	...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-5
    ...  AND  Start UE traffic  expected_pci=2  NR_call=${false}

	...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-5
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-5 PID:5 CID:25867781
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-5 PID:5 CID:25867781
	...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2
    ...  AND  Start UE traffic  expected_pci=5  NR_call=${false}

	...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2
	...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-3 PID:3 CID:25867779
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-3 PID:3 CID:25867779
	...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-6
	...  AND  Start UE traffic  expected_pci=3  NR_call=${false}

	...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-6
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-6 PID:6 CID:25867782
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-6 PID:6 CID:25867782
	...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-3
	...  AND  Start UE traffic  expected_pci=6  NR_call=${false}
	...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-3
	...  AND  Set attenuator value on all ports  set_value_db=${90}

	Run Keyword If  '${MRBTS_ID}' == '101035'   Run Keywords
	...  Set Test Variable  ${ue}  OP6_LTE
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #LNCEL-1 PID:351 CID:25864961
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #LNCEL-1 PID:352 CID:25864961
	...  AND  Start UE traffic  expected_pci=351  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #LNCEL-2 PID:352 CID:25864962
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #LNCEL-2 PID:352 CID:25864962
    ...  AND  Start UE traffic  expected_pci=352  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_17}  #LNCEL-3 PID:353 CID:25864963
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_18}  #LNCEL-3 PID:353 CID:25864963
	...  AND  Start UE Traffic  expected_pci=353  NR_call=${false}

	Run Keyword If  '${MRBTS_ID}' == '101044'   Run Keywords
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

	Run Keyword If  '${MRBTS_ID}' == '8391'  Run Keywords
	...  Set Test Variable  ${ue}  NOKIA83_NR
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-0 PID:810 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-0 PID:810 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-0 PID:810 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-0 PID:810 CID:137478144
	...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-0
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
    ...  AND  Airplane Mode On/Off
    ...  AND  Log To Console  Cell ID 137478144 equals 00831c0000 after being ciphered
    ...  AND  Start UE traffic  expected_pci=00831c0000  NR_call=${true}  5G_type=SA

	...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-1 PID:811 CID:137478145
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-1 PID:811 CID:137478145
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-1 PID:811 CID:137478145
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-1 PID:811 CID:137478145
    ...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-0
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
    ...  AND  Airplane Mode On/Off
    ...  AND  Log To Console  Cell ID 137478145 equals 00831c0010 after being ciphered
    ...  AND  Start UE traffic  expected_pci=00831c0010  NR_call=${true}  5G_type=SA

	...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-2 PID:812 CID:137478146
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-2 PID:812 CID:137478146
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-2 PID:812 CID:137478146
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-2 PID:812 CID:137478146
    ...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-0
    ...  AND  Airplane Mode On/Off
    ...  AND  Log To Console  Cell ID 137478146 equals 00831c0020 after being ciphered
    ...  AND  Start UE traffic  expected_pci=00831c0020  NR_call=${true}  5G_type=SA

    ...  AND  Set Test Variable  ${ue}  NOKIA83_LTE

	...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-0 PID:0 CID:2148096
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-0 PID:0 CID:2148096
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-0 PID:0 CID:2148096
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-0 PID:0 CID:2148096
	...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-0
    ...  AND  Sleep  2s
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
    ...  AND  Sleep  2s
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2
    ...  AND  Start UE traffic  expected_pci=0  NR_call=${false}  ue_id=${1}

    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-1 PID:1 CID:2148097
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-1 PID:1 CID:2148097
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-1 PID:1 CID:2148097
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-1 PID:1 CID:2148097
    ...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
    ...  AND  Sleep  2s
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-0
    ...  AND  Sleep  2s
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2
    ...  AND  Start UE traffic  expected_pci=1  NR_call=${false}  ue_id=${1}

    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-2 PID:2 CID:2148098
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-2 PID:2 CID:2148098
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-2 PID:2 CID:2148098
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-2 PID:2 CID:2148098
    ...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-2
    ...  AND  Sleep  2s
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
    ...  AND  Sleep  2s
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-0
    ...  AND  Start UE traffic  expected_pci=2  NR_call=${false}  ue_id=${1}
    Run Keyword If  '${MRBTS_ID}' == '8588'   Run Keywords
    ...  Set Test Variable  ${ue}  NOKIA83
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_23}  #LNCEL-107 PID:107 CID:2198635
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_24}  #LNCEL-107 PID:107 CID:2198635
	...  AND  Start UE traffic  expected_pci=107  NR_call=${false}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #LNCEL-3 PID:3 CID:2198531
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #LNCEL-3 PID:3 CID:2198531
	...  AND  Start UE traffic  expected_pci=3  NR_call=${false}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #LNCEL-4 PID:4 CID:2198532
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #LNCEL-4 PID:4 CID:2198532
    ...  AND  Start UE traffic  expected_pci=4  NR_call=${false}
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_23}  #LNCEL-107 PID:107 CID:2198635
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_24}  #LNCEL-107 PID:107 CID:2198635
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}   #NRCEL-104 PID:104 CID:140705796
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #NRCEL-104 PID:104 CID:140705796
    ...  AND  Start UE traffic  expected_pci=104  NR_call=${true}
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #LNCEL-4 PID:4 CID:2198532
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #LNCEL-4 PID:4 CID:2198532
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #NRCEL-101 PID:101 CID:140705793
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #NRCEL-101 PID:101 CID:140705793
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #NRCEL-101 PID:101 CID:140705793
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #NRCEL-101 PID:101 CID:140705793
    ...  AND  Start UE traffic  expected_pci=101  NR_call=${true}
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #LNCEL-3 PID:3 CID:2198531
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #LNCEL-3 PID:3 CID:2198531
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #NRCEL-103 PID:103 CID:140705795
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #NRCEL-103 PID:103 CID:140705795
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #NRCEL-103 PID:103 CID:140705795
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #NRCEL-103 PID:103 CID:140705795
    ...  AND  Start UE traffic  expected_pci=103  NR_call=${true}
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #LNCEL-3 PID:3 CID:2198531
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #LNCEL-3 PID:3 CID:2198531
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-100 PID:100 CID:140705792
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-100 PID:100 CID:140705792
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-100 PID:100 CID:140705792
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-100 PID:100 CID:140705792
    ...  AND  Start UE traffic  expected_pci=100  NR_call=${true}
    Run Keyword IF  '${MRBTS_ID}'=='8070'    Allow Fault In Watchdog  faultID=49  #fault_name: Cell blocked
    Run Keyword IF  '${MRBTS_ID}'=='8070'  Run keywords
    ...  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-108
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-121
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-108 PID:108
    ...  AND  Start UE traffic  expected_pci=108  NR_call=${false}
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-121
    ...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-108
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-121 PID:121
    ...  AND  Start UE traffic  expected_pci=121  NR_call=${false}
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
    ...  AND  admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #NRCEL-1 PID:1 CID:132218881
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #NRCEL-1 PID:1 CID:132218881
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #NRCEL-1 PID:1 CID:132218881
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #NRCEL-1 PID:1 CID:132218881
    ...  AND  Start UE Traffic  expected_pci=1  NR_call=${true}
    ...  AND  Run Keyword and ignore error    Unblock All Cells  rat=NR  timeout=120s
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}  #NRCEL-2 PID:2 CID:132218882
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #NRCEL-2 PID:2 CID:132218882
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #NRCEL-2 PID:2 CID:132218882
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}  #NRCEL-2 PID:2 CID:132218882
    ...  AND  Run Keyword and ignore error    Unblock All Cells  rat=NR  timeout=120s
    ...  AND  Start UE Traffic  expected_pci=2  NR_call=${true}
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-4
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_19}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_20}  #LNCEL-107 PID:107 CID:2066027
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_21}  #NRCEL-3 PID:3 CID:132218883
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_22}  #NRCEL-3 PID:3 CID:132218883
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_23}  #NRCEL-3 PID:3 CID:132218883
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_24}  #NRCEL-3 PID:3 CID:132218883
    ...  AND  Run Keyword and ignore error    Unblock All Cells  rat=NR  timeout=120s
    ...  AND  Start UE Traffic  expected_pci=3  NR_call=${true}
    ...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  admin.Block cell  MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3
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
    Run Keyword IF  '${MRBTS_ID}'=='8070'    Wait For Inactive Fault  faultID=49  timeout=2min
    Run Keyword IF  '${MRBTS_ID}'=='8070'    Disallow Fault In Watchdog  faultID=49  #fault_name: Cell blocked

    Run Keyword If  '${MRBTS_ID}' == '55201'  Run Keywords
	...  Set Test Variable  ${ue}  NOKIA83_NR
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #NRCEL-552011 PID:551 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #NRCEL-552011 PID:551 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #NRCEL-552011 PID:551 CID:137478144
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #NRCEL-552011 PID:551 CID:137478144
    ...  AND  Airplane Mode On/Off
    ...  AND  Log To Console  Cell ID 904413185 equals 035e840010 after being ciphered
    ...  AND  Start UE traffic  expected_pci=035e840010  NR_call=${true}  5G_type=SA
	...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #NRCEL-552012 PID:811 CID:137478145
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #NRCEL-552012 PID:811 CID:137478145
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #NRCEL-552012 PID:811 CID:137478145
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #NRCEL-552012 PID:811 CID:137478145
    ...  AND  Airplane Mode On/Off
    ...  AND  Log To Console  Cell ID 904413186 equals 035e840020 after being ciphered
    ...  AND  Start UE traffic  expected_pci=035e840020  NR_call=${true}  5G_type=SA
	...  AND  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}  #NRCEL-552013 PID:812 CID:137478146
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #NRCEL-552013 PID:812 CID:137478146
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #NRCEL-552013 PID:812 CID:137478146
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #NRCEL-552013 PID:812 CID:137478146
    ...  AND  Airplane Mode On/Off
    ...  AND  Log To Console  Cell ID 904413187 equals 035e840030 after being ciphered
    ...  AND  Start UE traffic  expected_pci=035e840030  NR_call=${true}  5G_type=SA

    Run Keyword If  '${MRBTS_ID}' == '5098'   Run Keywords
    ...  Set Test Variable  ${ue}  XIAOMI12
	...  AND  attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-3
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_1}  #LNCEL-1 PID:1 CID:1305089
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_2}  #LNCEL-1 PID:1 CID:1305089
	...  AND  Start UE traffic  expected_pci=1  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_3}  #LNCEL-2 PID:2 CID:1305090
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_4}  #LNCEL-2 PID:2 CID:1305090
	...  AND  Start UE traffic  expected_pci=2  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Cell Barred/NotBarred  notBarred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-3
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_5}  #LNCEL-3 PID:3 CID:1305096
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_6}  #LNCEL-3 PID:3 CID:1305096
	...  AND  Start UE traffic  expected_pci=3  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Cell Barred/NotBarred  barred  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-3
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-4 PID:4 CID:1305092
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-4 PID:4 CID:1305092
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}  #LNCEL-4 PID:4 CID:1305092
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #LNCEL-4 PID:4 CID:1305092
	...  AND  Start UE traffic  expected_pci=4  NR_call=${false}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-4 PID:4 CID:1305092
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-4 PID:4 CID:1305092
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}  #LNCEL-4 PID:4 CID:1305092
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #LNCEL-4 PID:4 CID:1305092
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_11}  #NRCEL-0 PID:0 CID:83525632
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_12}  #NRCEL-0 PID:0 CID:83525632
	...  AND  Start UE traffic  expected_pci=0  NR_call=${true}

	...  AND  Set attenuator value on all ports  set_value_db=${90}
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_7}  #LNCEL-4 PID:4 CID:1305092
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_8}  #LNCEL-4 PID:4 CID:1305092
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_9}  #LNCEL-4 PID:4 CID:1305092
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_10}  #LNCEL-4 PID:4 CID:1305092
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_13}   #NRCEL-1 PID:1 CID:83525633
	...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_14}  #NRCEL-1 PID:1 CID:83525633
	...  AND  Start UE traffic  expected_pci=1  NR_call=${true}

    [Teardown]  Run keywords  Set attenuator value on all ports  set_value_db=${90}
    ...  AND  Unbarring all cells

Connect to SMOD
    [Documentation]    Connect to master BTS using variables from __init__.py
    [Arguments]      ${alias}=SMOD_CONNECTION_ALIAS
    ssh.connect_to      hostname=192.168.255.129
    ...                 username=toor4nsn
    ...                 password=oZPS0POrRieRtu
    ...                 alias=${alias}
    [Return]         ${alias}

Start TCPdump ssh
    [Documentation]    Start TCPdump on SMOD via SSH connection
    [Arguments]     ${alias}=SMOD_CONNECTION_ALIAS    ${interface}=any    ${filename}=smod_trace
    ssh.send_command  command=tcpdump -i ${interface} -w "/tmp/${filename}.pcap"  connection=${alias}

Start tracing on SMOD
    [Documentation]    Connect to SMOD and start TCPdump on same SSH session
    [Arguments]       ${filename}=smod_trace    ${interface}=any
    ${connection_alias}     Connect to SMOD
    Start TCPdump ssh   ${connection_alias}     ${interface}    ${filename}

Stop tracing and download logs from SMOD
    [Documentation]    Stop tcpdum, download to test_result location and clear SMOD /tmp
    [Arguments]      ${filename}=smod_trace
    ${timestamp}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${alias}=    Connect to SMOD
    ssh.execute   command=killall tcpdump  connection=${alias}
    ssh.execute  command=chmod 777 /tmp/${filename}_${timestamp}.pcap  connection=${alias}
    ssh.download_file  /tmp/${filename}.pcap  ${RESULTS}/${filename}_${timestamp}.pcap  connection=${alias}
    ssh.execute  command=rm "/tmp/${filename}.pcap"  connection=${alias}
    [Return]    ${RESULTS}/${filename}_${timestamp}.pcap

Teardown if call failed
    Log  L3 call failed  WARN
    Run keyword and ignore error  Stop Tracing and download logs from SMOD
    Unbarring all cells
    Run keyword and ignore error    Unblock All Cells  rat=NR  timeout=120s

Check NSA RRC Reconfiguration
    [Documentation]    check rrcReconfiguration physical cell id and rrcReconfigurationComplete msg
    [Arguments]     ${pcap}    ${physical_cellid}
    ${rrcReconfigurationComplete_status}    check rrcReconfigurationComplete    ${pcap}
    ${rrcReconfigurationPCI_status}    check_rrcReconfig_pci_cell  ${pcap}    ${physical_cellid}
    Should Be True    ${rrcReconfigurationComplete_status}
    Should Be True    ${rrcReconfigurationPCI_status}

Verify PCI
    [Arguments]  ${pcap_file}  ${pci}
#    Log To Console  \nUE attach verification
    Log To Console  Converting pcap to pdml file...
    ${pdml_file}  uuf4all_attach_test.Convert Pcap To Pdml  ${pcap_file}
    Log To Console  Searching physCellId in pdml file...
    ${status}  Run Keyword And Return Status  uuf4all_attach_test.Verify Proper Pci Attach  ${pci}  ${pdml_file}
    Run Keyword If  ${status}  Run  find ${RESULTS} -name '*.xml' -type f -delete

Get Value From PCAP
    [Documentation]  Reading packets based on Wireshark display filter syntax.
    [Arguments]  ${pcap_file}  ${filter_syntax}  ${field_to_print}
    ${output}  Run  tshark -r ${pcap_file} -Y "${filter_syntax}" -T fields -e ${field_to_print}
    ${output_lines} =  split string   ${output}  separator=,
    ${first_request} =  Get From List  ${output_lines}  0
    [Return]  ${first_request}

Verify 5G NSA Attach
    [Arguments]  ${ue}  ${expected_cell}  ${ue_type}=non_askey
    Sleep  5s  time to check if atach is stable
    ${pcap_file}  Stop Tracing and download logs from SMOD
    ${nr_pci}  Get Value From PCAP  ${pcap_file}  ${SgNBAdditionRequest}  ${physCellId}
    ${CELL_INFO}  Run Keyword If  '${ue_type}'=='non_askey'  ue.Get UE Info  ${ue}  CELL_INFO
    Run Keyword If  '${ue_type}'=='non_askey'  Should Be Equal  ${CELL_INFO}[cellType]  LTENR   ${ue} not attached to 5G NSA  values=False
    ${nr_state}  Set Variable If  '${ue_type}'=='non_askey'  ${CELL_INFO}[nrState]
    ${nr_state}  Set Variable If  '${nr_state}'=='None'  'not presented'  ${nr_state}
    ${nr_ci}  Set Variable If  '${ue_type}'=='non_askey'  ${CELL_INFO}[nci]
    ${nr_ci}  Set Variable If  '${nr_ci}'=='-1'  'not presented'
    ${CELL_ID}  Run Keyword If  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  CELL_ID
    ${SIGNAL_STRENGTH}  Run Keyword If  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  SIGNAL_STRENGTH
#    Log To Console  \nUE attach verification
    Run Keyword If  '${ue_type}'=='non_askey' or '${ue_type}'=='askey'  Should Be Equal  ${expected_cell}  ${nr_pci}
    ...  ${ue} not attached to expected physical cell ID: ${expected_cell}  values=False
    Log To Console  ${ue} attached to 5G NSA:
    Run Keyword If  '${ue_type}'=='non_askey'  Run Keywords
    ...  Log To Console   LNCEL state: CONNECTED, Physical cell ID: ${CELL_INFO}[ltePci], cell ID: ${CELL_INFO}[ci], RSRP: ${CELL_INFO}[lteDbm] dBm
    ...  AND  Log To Console   NRCEL state: ${nr_state}, Physical cell ID: ${nr_pci}, cell ID: ${nr_ci}, RSRP: ${CELL_INFO}[nrDbm] dBm
    Run Keyword If  '${ue_type}'=='askey'  Run Keywords
    ...  Log To Console   LNCEL state: CONNECTED, Physical cell ID: 'not presented', cell ID: ${CELL_ID}, RSRP: 'not presented'
    ...  AND  Log To Console   NRCEL state: CONNECTED, Physical cell ID: ${nr_pci}, cell ID: 'not presented', ${SIGNAL_STRENGTH}

Verify 5G SA Attach
    [Arguments]  ${ue}  ${expected_cell}  ${ue_type}=non_askey
    Sleep  20s  time to check if atach is stable
    ${pcap_file}  Stop Tracing and download logs from SMOD
    ${nr_pci}  Get Value From PCAP  ${pcap_file}  ${InitialULRRCMessageTransfer}  ${nRCellIdentity}
    Log to console    ${nr_pci}
    ${CELL_INFO}  Run Keyword If  '${ue_type}'=='non_askey'  ue.Get UE Info  ${ue}  CELL_INFO
    Run Keyword If  '${ue_type}'=='non_askey'  Should Be Equal  ${CELL_INFO}[cellType]  NR   ${ue} not attached to 5G SA  values=False
    ${nr_operator}  Set Variable If  '${ue_type}'=='non_askey'  ${CELL_INFO}[networkOperator]
    ${nr_ci}  Set Variable If  '${ue_type}'=='non_askey'  ${CELL_INFO}[nci]
    ${nr_ci}  Set Variable If  '${nr_ci}'=='-1'  'not presented'
    ${CELL_ID}  Run Keyword If  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  CELL_ID
    ${SIGNAL_STRENGTH}  Run Keyword If  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  SIGNAL_STRENGTH
#    Log To Console  \nUE attach verification
    Run Keyword If  '${ue_type}'=='non_askey' or '${ue_type}'=='askey'  Should Be Equal  ${expected_cell}  ${nr_pci}
    ...  ${ue} not attached to expected physical cell ID: ${expected_cell}  values=False
    Log To Console  ${ue} attached to 5G SA:
    Run Keyword If  '${ue_type}'=='non_askey'  Run Keywords
    Log To Console   Physical cell ID: ${nr_pci}, cell ID: ${nr_ci}
    Run Keyword If  '${ue_type}'=='askey'  Run Keywords
    Log To Console   NRCEL state: CONNECTED, Physical cell ID: ${nr_pci}, cell ID: 'not presented', ${SIGNAL_STRENGTH}, operator: ${nr_operator}

Verify 4G Attach
    [Arguments]  ${ue}  ${expected_cell}  ${ue_type}=non_askey
    ${CELL_INFO}  Run Keyword If  '${ue_type}'=='non_askey'  ue.Get UE Info  ${ue}  CELL_INFO
    ${pci}  Run Keyword If  '${ue_type}'=='non_askey' and '${CELL_INFO}[cellType]'=='LTE'  Convert To String  ${CELL_INFO}[pci]
    ...  ELSE IF  '${ue_type}'=='non_askey' and '${CELL_INFO}[cellType]'=='LTENR'  Convert To String  ${CELL_INFO}[ltePci]
    ${dBm}  Run Keyword If  '${ue_type}'=='non_askey' and '${CELL_INFO}[cellType]'=='LTE'  Convert To String  ${CELL_INFO}[dbm]
    ...  ELSE IF  '${ue_type}'=='non_askey' and '${CELL_INFO}[cellType]'=='LTENR'  Convert To String  ${CELL_INFO}[lteDbm]
    ${CELL_ID}  Run Keyword If  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  CELL_ID
    ${CELL_ID}  Convert To String  ${CELL_ID}
    ${SIGNAL_STRENGTH}  Run Keyword If  '${ue_type}'=='askey'  ue.Get UE Info  ${ue}  SIGNAL_STRENGTH
#    Log To Console  \nUE attach verification
    Log To Console  \n
    Run Keyword If  '${ue_type}'=='askey'  Should Be Equal  ${CELL_ID}  ${expected_cell}
    ...  ${ue} not attached to expected cell ID: ${expected_cell}   values=False
    Run Keyword If  '${ue_type}'=='non_askey'  Should Be Equal  ${pci}  ${expected_cell}
    ...  ${ue} not attached to expected physical cell ID: ${expected_cell}   values=False
    Log To Console  ${ue} attached to LTE:
    Run Keyword If  '${ue_type}'=='non_askey'
    ...  Log To Console   LNCEL state: CONNECTED, Physical cell ID: ${pci}, cell ID: ${CELL_INFO}[ci], RSRP: ${dBm} dBm
    Run Keyword If  '${ue_type}'=='askey'
    ...  Log To Console   LNCEL state: CONNECTED, Physical cell ID: 'not presented', cell ID: ${CELL_ID}, ${SIGNAL_STRENGTH}

Call For CB010397 LTE
    [Arguments]  ${tput_dl}  ${duration}
    attenuator.setup_attenuator  attenuator=${tl.attenuator[0]}
    Set attenuator value on all ports  set_value_db=${90}
	Run keyword if  '${MRBTS_ID}'=='8588' and '${cell_for_call_ID}[0]' == '4'
    ...  Run keywords  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_15}  #LNCEL-4 PID:4 CID:2198532
    ...  AND  Adjust attenuation value for port  set_value_db=${0}  port=${att_port_16}
    ...  AND  Log to console  Adjust LNCEL 4
    ...  AND  Start UE Traffic  expected_pci=4  NR_call=${false}  duration=${duration}  tput_dl=${tput_dl}
    Set attenuator value on all ports  set_value_db=${90}
    [Teardown]  Set attenuator value on all ports  set_value_db=${90}

Check Average Tput
    [Arguments]  ${dt_name}  ${direction}
    ${avg_tput}   ue.Get Average Throughput   dt_name=${dt_name}
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_tput}   Evaluate   "%.2f" % ${avg_tput}
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
    ...
    [Arguments]  ${command}
    Log  ${command}  console=${True}
    ${ue_pc_ip}  ${ue_pc_log}  ${ue_pc_pass}  Get UE PC Data
    ${if_pingable}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  1min  15s  Check If Host Is Reachable  IP=${ue_pc_ip}
    Run Keyword If  ${if_pingable}  Log  UE PC is reachable
    ...  ELSE  Fail  msg= UE PC is not reachable. \nTurn on UE PC.
${if_connected}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  2min  30s  ssh.connect to  ${ue_pc_ip}  ${ue_pc_log}  ${ue_pc_pass}
    Run Keyword If  ${if_connected}  Run Keywords  Log  SSH connection to UE PC has been established
    ...  AND  Log To Console  Command execution: ${command}
    ...  AND  ssh.execute  command=${command}
    ...  ELSE  Fail  SSH connection failed

Get UE PC Data
    [Documentation]  Get init parametrs: ue_pc_ip, login and password.
    ${ue_pc_ip}  Set Variable  ${tl.ues[0].ue_pc_address}
    ${ue_pc_log}  Set Variable  ${tl.ues[0].ssh_connection_details.username}
    ${ue_pc_pass}  Set Variable  ${tl.ues[0].ssh_connection_details.password}
    [Return]  ${ue_pc_ip}  ${ue_pc_log}  ${ue_pc_pass}

Get YAML Capabilities
    [Documentation]  Get yaml capabilities.
    ${UE_NAME}  Set Variable  ${tl.ues[0]['UE_POOLS']['AndroidUePool']['inline_config'].keys()}
    ${UE_NAME}  Convert To List  ${UE_NAME}
    ${config}  Set Variable  ${tl.ues[0]['UE_POOLS']['AndroidUePool']['inline_config']['${UE_NAME[0]}']['CAPABILITIES']}
    Set Test Variable  ${ue}  ${config[0]}

Airplane Mode On/Off
    [Documentation]  Set airplane on/off on UE via adb commands.
	Execute Command On UE PC  adb shell cmd connectivity airplane-mode enable
	Log  Airplane mode is enabled  console=${True}
	Sleep  30
	Execute Command On UE PC  adb shell cmd connectivity airplane-mode disable
	Log  Airplane mode is disabled  console=${True}
	Sleep  10
