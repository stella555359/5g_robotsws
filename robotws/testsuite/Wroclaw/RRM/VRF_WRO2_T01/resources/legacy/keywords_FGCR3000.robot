*** Settings ***
Documentation
...  author:
...  contact:

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py
Library         taf.transport.ssh  WITH NAME  ssh
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library         taf.collectors.pmcounters  WITH NAME  pm
Library         testsuite.Wroclaw.RRM.resources.webui.interface.WebuiInterface   WITH NAME  WebUI
Library         taf.collectors.btslog  WITH NAME   btslog
Library         taf.hw.rf_attenuator    WITH NAME    att
Library         taf.ue
Library         SSHLibrary
Library         Collections
Library         DateTime
Library         OperatingSystem
Resource        testsuite/Wroclaw/RRM/resources/connections.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pmcounters.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/math.robot
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.l2_trace    WITH NAME    l2_trace
Library         taf.collectors.tcpdump     WITH NAME    tcpdump
Library         taf.collectors.core        WITH NAME    core
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/transmission_checker.py
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.installers.TTIDecoderInstaller    WITH NAME    tti
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot


*** Variables ***
${ATTEN_IP}                  ${tl.attenuator.ip_addr}
${ATT_API_PORT}              ${tl.attenuator.port}
${ATTEN_PORTS}               ${tl.attenuator.attenuator_ports}
${ATTEN_MODEL}               ${tl.attenuator.model}
${ATTEN_VENDOR}              TopYoung
${MAX_ATTENUATION_VALUE}     ${90}
@{LINES_CELL1_5G}       1    2    3    4
@{LINES_CELL2_5G}       5    6    7    8
@{LINES_CELL3_5G}       9    10   11   12
${VM_IP}   ${tl.test_pc.default_ssh_connection_details.addr}


*** Keywords ***
Suite setup attenuators
    att.Setup attenuator    ip_addr=${ATTEN_IP}    port=${ATT_API_PORT}
    ...    attenuation_port_numbers=${ATTEN_PORTS}    max_attenuation=${MAX_ATTENUATION_VALUE}    vendor=${ATTEN_VENDOR}
    ...    model=${ATTEN_MODEL}

Perform commissioning FGCR 3000
    [Arguments]
    ...                	${ulDataPath}=ulOverNr
    ...                 ${ulDataSplitThreshold}=infinity
    ...                 ${actDynUlDataSplitMode}=true
    ...                 ${alias}=coam

    Log to console      __Perform commissioning with given parameters.
    &{nsaDrbParam}      Create dictionary       ulDataPath=${ulDataPath}
    ...                                         ulDataSplitThreshold=${ulDataSplitThreshold}
    ...                                         actPrioritizeX2AfterInactivity=false
    ...                                         dlDataSplitBufferBuildUpThreshold=5
    ...                                         dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
    ...                                         dlDataSplitGainThreshold=5
    ...                                         dlDataSplitMode=dlOverF1UX2U
    ...                                         dlNumOfCongOrGainDdds=2
    ...                                         inactivityThresholdForPrioritizeX2=300
    ...                                         inactivityThresholdForRestartPrioritizeX2=100
    ...                                         initialDLTrafficRouting=initDLoverX2U
    ...                                         nsa3xBearerAllowed=true
    ...                                         prioritizeX2Period=500
    ...                                         actX2DuplicateTxNSA3x=false
    ${cell_ids}    Get cell ids
    Initialise delta store
    Connect with runtime release    ${alias}
    ${nrdrb_path}           Set variable    MRBTS-${bts_id}/NRBTS-${bts_id}/NRDRB-
    ${nrdrb_objects}        coam.Get managed objects    class_name=NRDRB_A   connection=${alias}
    FOR  ${nrdrb}  IN  @{nrdrb_objects}
        ${index}            Fetch from right  ${nrdrb['distName']}  -
        Add list parameters to delta  ${nrdrb_path}${index}          nsaDrbParam                     &{nsaDrbParam}
    END
    ${object_path}          Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-
    ${nrcell_objects}       coam.Get managed objects    class_name=NRCELL_A   connection=${alias}
    ${first_cell_id}=    Get Global Cell Id Of First Cell
    Add Param To Delta    ${object_path}${first_cell_id}    actDynUlDataSplitMode                      value=${actDynUlDataSplitMode}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}

Perform commissioning FGCR 3000__Trunk
    [Arguments]
    ...                	${ulDataPath}=ulOverNr
    ...                 ${ulDataSplitThreshold}=infinity
    ...                 ${actDynUlDataSplitMode}=true
    ...                 ${alias}=coam

    Log to console      __Perform commissioning with given parameters.
    &{nsaDrbParam}      Create dictionary       ulDataPath=${ulDataPath}
    ...                                         ulDataSplitThreshold=${ulDataSplitThreshold}
    ...                                         actPrioritizeX2AfterInactivity=false
    ...                                         dlDataSplitBufferBuildUpThreshold=5
    ...                                         dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
    ...                                         dlDataSplitGainThreshold=5
    ...                                         dlDataSplitMode=dlOverF1UX2U
    ...                                         dlNumOfCongOrGainDdds=2
    ...                                         inactivityThresholdForPrioritizeX2=300
    ...                                         inactivityThresholdForRestartPrioritizeX2=100
    ...                                         initialDLTrafficRouting=initDLoverX2U
    ...                                         nsa3xBearerAllowed=true
    ...                                         prioritizeX2Period=500
    ...                                         actX2DuplicateTxNSA3x=false
    ...                                         dlPreferredPath=F1-U
    ${cell_ids}    Get cell ids
    Initialise delta store
    Connect with runtime release    ${alias}
    ${nrdrb_path}           Set variable    MRBTS-${bts_id}/NRBTS-${bts_id}/NRDRB-
    ${nrdrb_objects}        coam.Get managed objects    class_name=NRDRB_A   connection=${alias}
    FOR  ${nrdrb}  IN  @{nrdrb_objects}
        ${index}            Fetch from right  ${nrdrb['distName']}  -
        Add list parameters to delta  ${nrdrb_path}${index}          nsaDrbParam                     &{nsaDrbParam}
    END
    ${object_path}          Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-
    ${nrcell_objects}       coam.Get managed objects    class_name=NRCELL_A   connection=${alias}
    ${first_cell_id}=    Get Global Cell Id Of First Cell
    Add Param To Delta    ${object_path}${first_cell_id}    actDynUlDataSplitMode                      value=${actDynUlDataSplitMode}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}

Increase and decrease attenuation
    [Arguments]    ${attenuation_value}
    Set attenuation and check    lines=${LINES_CELL1_5G}    value=${attenuation_value}
    sleep    7s
    Set attenuation and check    lines=${LINES_CELL1_5G}    value=0
    sleep   35s

FGCR-3000_A_101_Reconfiguration_From_NR_Only_To_LTE_Only_Detection_UL_Quality_Is_Bad
    [Arguments]  ${attenuation_treshold}

    Perform commissioning FGCR 3000
    ...   	ulDataPath=ulOverNr
    ...     ulDataSplitThreshold=infinity

    Set attenuation and check    lines=${LINES_CELL2_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL3_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL1_5G}    value=0

    taf.ue.Detach ue    UE
    Sleep   3s
    taf.ue.Attach ue    UE
    Sleep   3s

    Start UL
    ...  protocol=udp
    ...  tput_duration=3600s
    Start tcpdump collector
    Sleep    7s

    Set attenuation and check  lines=${LINES_CELL1_5G}  value=${attenuation_treshold}
    sleep    10s

    Stop tcpdump collector   FGCR-3000
    taf.ue.Stop Data Transfer  dt_name=DT_UL

    l2_trace.decode pcap file   FGCR-3000
    check if transmission changed   NR_TO_LTE


FGCR-3000_B_201_Reconfig_From_LTE_Only_To_NR_Only_Detection_UL_Quality_Is_Improved
    [Arguments]  ${attenuation_treshold}

    Perform commissioning FGCR 3000
    ...   	ulDataPath=ulOverNr
    ...     ulDataSplitThreshold=infinity

    Set attenuation and check    lines=${LINES_CELL2_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL3_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL1_5G}    value=0

    taf.ue.Detach ue    UE
    Sleep   3s
    taf.ue.Attach ue    UE
    Sleep   3s

    Start UL
    ...  protocol=udp
    ...  tput_duration=3600s
    sleep    3s

    Start Tcpdump Collector
    Increase and decrease attenuation    attenuation_value=${attenuation_treshold}
    sleep    180s

    Stop tcpdump collector   FGCR-3000
    taf.ue.Stop Data Transfer  dt_name=DT_UL

    decode pcap file   FGCR-3000
    check if transmission changed   LTE_TO_NR

FGCR-3000_A_110_Reconfig_From_NR+LTE_To_LTE_Only_Detection_Of_Bad_UL_Channel_Quality
    [Arguments]  ${attenuation_treshold}

    Perform commissioning FGCR 3000
    ...   	ulDataPath=ulOverLteNr_PrimaryPathOverNr
    ...     ulDataSplitThreshold=b100

    Set attenuation and check    lines=${LINES_CELL2_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL3_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL1_5G}    value=0

    taf.ue.Detach ue    UE
    Sleep   3s
    taf.ue.Attach ue    UE
    Sleep   3s

    Start UL
    ...  protocol=udp
    ...  tput_duration=3600s
    Start tcpdump collector
    Sleep    7s

    Set attenuation and check  lines=${LINES_CELL1_5G}  value=${attenuation_treshold}
    sleep    10s

    Stop tcpdump collector   FGCR-3000
    taf.ue.Stop Data Transfer  dt_name=DT_UL

    decode pcap file   FGCR-3000
    check if transmission changed   NR_TO_LTE

FGCR-3000_B_206_Reconfig_From_LTE_Only_To_NR+LTE_Detection_UL_Quality_Is_Improved
    [Arguments]  ${attenuation_treshold}

       Perform commissioning FGCR 3000
    ...   	ulDataPath=ulOverLteNr_PrimaryPathOverNr
    ...     ulDataSplitThreshold=b100

    Set attenuation and check    lines=${LINES_CELL2_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL3_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL1_5G}    value=0

    taf.ue.Detach ue    UE
    Sleep   3s
    taf.ue.Attach ue    UE
    Sleep   3s

    Start UL
    ...  protocol=udp
    ...  tput_duration=3600s
    sleep    3s

    Start Tcpdump Collector
    Increase and decrease attenuation    attenuation_value=${attenuation_treshold}
    sleep    180s

    Stop tcpdump collector   FGCR-3000
    taf.ue.Stop Data Transfer  dt_name=DT_UL

    decode pcap file   FGCR-3000
    check if transmission changed   LTE_TO_NR

FGCR-3000_A_101_Reconfiguration_From_NR_Only_To_LTE_Only_Detection_UL_Quality_Is_Bad__Trunk
    [Arguments]  ${attenuation_treshold}

    Perform commissioning FGCR 3000__Trunk
    ...   	ulDataPath=ulOverNr
    ...     ulDataSplitThreshold=infinity

    Set attenuation and check    lines=${LINES_CELL2_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL3_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL1_5G}    value=0

    taf.ue.Detach ue    UE
    Sleep   3s
    taf.ue.Attach ue    UE
    Sleep   3s

    Start UL
    ...  protocol=udp
    ...  tput_duration=3600s
    Start tcpdump collector
    Sleep    7s

    Set attenuation and check  lines=${LINES_CELL1_5G}  value=${attenuation_treshold}
    sleep    10s

    Stop tcpdump collector   FGCR-3000
    taf.ue.Stop Data Transfer  dt_name=DT_UL

    l2_trace.decode pcap file   FGCR-3000
    check if transmission changed   NR_TO_LTE


FGCR-3000_B_201_Reconfig_From_LTE_Only_To_NR_Only_Detection_UL_Quality_Is_Improved__Trunk
    [Arguments]  ${attenuation_treshold}

    Perform commissioning FGCR 3000__Trunk
    ...   	ulDataPath=ulOverNr
    ...     ulDataSplitThreshold=infinity

    Set attenuation and check    lines=${LINES_CELL2_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL3_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL1_5G}    value=0

    taf.ue.Detach ue    UE
    Sleep   3s
    taf.ue.Attach ue    UE
    Sleep   3s

    Start UL
    ...  protocol=udp
    ...  tput_duration=3600s
    sleep    3s

    Start Tcpdump Collector
    Increase and decrease attenuation    attenuation_value=${attenuation_treshold}
    sleep    180s

    Stop tcpdump collector   FGCR-3000
    taf.ue.Stop Data Transfer  dt_name=DT_UL

    decode pcap file   FGCR-3000
    check if transmission changed   LTE_TO_NR

FGCR-3000_A_110_Reconfig_From_NR+LTE_To_LTE_Only_Detection_Of_Bad_UL_Channel_Quality__Trunk
    [Arguments]  ${attenuation_treshold}

    Perform commissioning FGCR 3000__Trunk
    ...   	ulDataPath=ulOverLteNr_PrimaryPathOverNr
    ...     ulDataSplitThreshold=b100

    Set attenuation and check    lines=${LINES_CELL2_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL3_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL1_5G}    value=0

    taf.ue.Detach ue    UE
    Sleep   3s
    taf.ue.Attach ue    UE
    Sleep   3s

    Start UL
    ...  protocol=udp
    ...  tput_duration=3600s
    Start tcpdump collector
    Sleep    7s

    Set attenuation and check  lines=${LINES_CELL1_5G}  value=${attenuation_treshold}
    sleep    10s

    Stop tcpdump collector   FGCR-3000
    taf.ue.Stop Data Transfer  dt_name=DT_UL

    decode pcap file   FGCR-3000
    check if transmission changed   NR_TO_LTE

FGCR-3000_B_206_Reconfig_From_LTE_Only_To_NR+LTE_Detection_UL_Quality_Is_Improved__Trunk
    [Arguments]  ${attenuation_treshold}

       Perform commissioning FGCR 3000__Trunk
    ...   	ulDataPath=ulOverLteNr_PrimaryPathOverNr
    ...     ulDataSplitThreshold=b100

    Set attenuation and check    lines=${LINES_CELL2_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL3_5G}    value=90
    Set attenuation and check    lines=${LINES_CELL1_5G}    value=0

    taf.ue.Detach ue    UE
    Sleep   3s
    taf.ue.Attach ue    UE
    Sleep   3s

    Start UL
    ...  protocol=udp
    ...  tput_duration=3600s
    sleep    3s

    Start Tcpdump Collector
    Increase and decrease attenuation    attenuation_value=${attenuation_treshold}
    sleep    180s

    Stop tcpdump collector   FGCR-3000
    taf.ue.Stop Data Transfer  dt_name=DT_UL

    decode pcap file   FGCR-3000
    check if transmission changed   LTE_TO_NR
