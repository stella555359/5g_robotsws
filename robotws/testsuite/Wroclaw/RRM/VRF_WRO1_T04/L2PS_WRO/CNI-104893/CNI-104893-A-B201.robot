*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT    SBTS00    RAN_5G
...   RAN_5G_TDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource    ../CB007813/connect.robot
Library    ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    ../CB007813/CB007813-B_keywords.py
Library    Collections
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_2_AEQE_2_AHLOA.xml
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CNI_104893_A_B201_100MHz.xml
    ...        AND             Check Radios Availability
    ...        AND             Start Default Logging And Reach Onair
    ...                        lua_cfg_filepath=${CURDIR}/config/basic_setup.cfg
    ...                        output_dirpath=${OUTPUT_DIR}

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${drx_Config_release}=    (nr-rrc.MeasGapConfig_element) && (nr-rrc.drx_Config == 0)
${DRXConfigurationIndicator_release}=    (nr-rrc.MeasConfig_element) && (f1ap.DRXConfigurationIndicator == 0)

*** Test Cases ***
CNI-104893_F1AP_UeContextModificationRequest_improvement_actOfA3_A5_B2_measurements
    Set Internal Traffic Type To UE    ue=1    pdu=1
    Set Internal Traffic Type To UE    ue=2    pdu=2
    Attach Ue    ue_id=1
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=1     pdu_id=1     gw_id=1
    Establish Pdu Session    ue_id=2     pdu_id=2     gw_id=2
    Start DL and UL Data Traffic For Both UEs
    Send A2 Measurement For UE1 And Get Measurement B2
    Send A2 Measurement For UE2 And Get Measurement A5
    Verify DRXConfigurationIndicator Is Set To Release In UEContextModificationRequest
    Verify drx-Config Is Set To Release In UEContextModificationResponse
    [Teardown]    Send Configuration ID To Scout


*** Keywords ***
Set Internal Traffic Type To UE
    [Arguments]   ${ue}=1    ${pdu}=1
    Execute Egate Command   cmd=set_pdu_param ue=${ue} pdu=${pdu} trf_type=internal

Send A2 Measurement For UE1 And Get Measurement B2
	${meas_id}=  Get Measurement id    EventA2   ue_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} index=0 nrs_result=125:125:0 event=A2 phycell_id=150 nrsrq_nr=125 srsrq_nr=17
    ...    pass_regexp=eventId eventB2
    ...    timeout=20

Send A2 Measurement For UE2 And Get Measurement A5
	${meas_id}=  Get Measurement id    EventA2   ue_id=2
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=2 meas_id=${meas_id} index=0 nrs_result=125:125:0 event=A2 phycell_id=150 nrsrq_nr=125 srsrq_nr=17
    ...    pass_regexp=eventId eventA5
    ...    timeout=20

Verify DRXConfigurationIndicator Is Set To Release In UEContextModificationRequest
    Verify Tcpdump Log
    ...    packet_filter=${DRXConfigurationIndicator_release}
    ...    number_of_messages=2

Verify drx-Config Is Set To Release In UEContextModificationResponse
    Verify Tcpdump Log
    ...    packet_filter=${drx_Config_release}
    ...    number_of_messages=2

Get Measurement id
    [Arguments]  ${event_type}  ${ue_id}  ${matching_line}=0
    ${measurements}=    Execute Egate Command And Wait For Data    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=${event_type}  timeout=10s
    ${matching_lines}=  Get Lines Containing String  ${measurements}  ${event_type}
    ${first_line}=  Get Line  ${matching_lines}  ${matching_line}
    @{words}=  Split String  ${first_line}
    Log to console  MeasId: ${words}[0] for event: ${words}[2] found for RAT: ${words}[1]
    [Return]  ${words}[0]

Start DL and UL Data Traffic For Both UEs
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=10
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=10
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=2 pdu=2 dir=dl mbps=10
    ...    pass_regexp=UE2: Started Downlink Internal traffic Receiver on Ue:2 Pdu:2 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=2 pdu=2 dir=ul mbps=10
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:2 UpfId:1 Pdu:2 Qfi:1 TrfId:1
    Sleep    10s
