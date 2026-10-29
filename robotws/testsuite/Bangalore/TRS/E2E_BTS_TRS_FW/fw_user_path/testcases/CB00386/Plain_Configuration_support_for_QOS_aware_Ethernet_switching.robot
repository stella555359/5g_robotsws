*** Settings ***
Documentation
...     [Documentation]
...     [Author]                        "Spandana N"
...     [Maintenance]                   "TRS I & V Tools Bangalore Team"
...     [Scenario]                      "To verify L2 QoS"
...     [Date]                          "* "
...     [Description]                   "To verify L2 QoS and verify shaping in wireshark"
...     [QC_Path]                       "QC_Path in Test Plan"
...     [QC_ID]                         "QC_ID in Tiest Lab for reporting"




variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot


#Suite Setup     Setup Oamops
#Suite Teardown      Teardown Oamops

Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for test teardown


***variables***
${def_trf_sent}    2
${filter}         ip.src==10.0.1.2

*** Test Cases ***
[1][2.0] Plain Configuration support for QOS aware Ethernet switching

    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=true     timeout=400     alias=default
    Sleep    300
    Enable L2 QoS
    Call Setup  lte=Plain_config_CUS:data   parallel=${False}    verify_attach=${False}       attach=${False}
    Verify BTS status   should_be_onair=${True}
    Sleep     10
    Send traffic and verify wireshark
    Verify shaping with default values
    Modify l2shaperRate
    Stop calls
    Change to PCP and verify shaping

***Keywords***

Enable L2 QoS
    Perform Recommissioning     type=delta      rat=lte     delta_file=${delta_enable_l2QoS}     timeout=300
    Sleep    30
Stop calls
    Configure UE      lte=Plain_config_CUS:data     command=ue_detach id=1

Send traffic and verify wireshark
    Traffic Capture Start         capture_device=vm_eth3_interface      alias=l2_qos_packets
    Sleep   60
    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=52
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=15 protocol=udp
    Sleep   400

    ${Wireshark_file} =      Traffic Capture Stop        alias=l2_qos_packets

    Verify Data Rate in wireshark   ${Wireshark_file}    ${filter}    15

Verify shaping with default values
    Perform Recommissioning     type=delta      rat=lte     delta_file=delta_update_default_values.xml      timeout=300
    Sleep    300

    Traffic Capture Start         capture_device=vm_eth3_interface      alias=l2_qos_packets
    Sleep   200
    ${Wireshark_file} =      Traffic Capture Stop        alias=l2_qos_packets

    Verify Data Rate in wireshark   ${Wireshark_file}    ${filter}    15


Modify l2shaperRate
    Perform Recommissioning     type=param      param_path=${l2_shaper_rate}   operation=update    value=${changed_value}     timeout=300
    Sleep   300
    Perform Recommissioning     type=param      param_path=${l2_shaper_rate_1}   operation=update    value=${changed_value_1}     timeout=300
    Sleep   300

    Traffic Capture Start         capture_device=vm_eth3_interface      alias=l2_qos_packets
    Sleep   60
    Sleep   120

    ${Wireshark_file} =      Traffic Capture Stop        alias=l2_qos_packets

    Verify Data Rate in wireshark   ${Wireshark_file}    ${filter}    1000

Change to PCP and verify shaping
    Perform Recommissioning     type=param      param_path=L2SWI-1:qosClassificationCriteria     operation=update    value=PCP     timeout=300
    Sleep   300
    Traffic Capture Start         capture_device=vm_eth3_interface      alias=l2_qos_packets
    Sleep   60

    Configure UE      lte=Plain_config_CUS:data     command=ue_attach id=1 cell=52
    Sleep   10
    Configure UE      lte=Plain_config_CUS:data     command=trf_data_start ue=1 dir=ul Mbps=20 protocol=udp
    Sleep   320
    ${Wireshark_file} =      Traffic Capture Stop        alias=l2_qos_packets

    Verify Data Rate in wireshark   ${Wireshark_file}    ${filter}    1000



Verify Data Rate in wireshark
    [Arguments]         ${Wireshark_file}        ${filter}       ${expected_data_rate}
    Run  tshark -o esp.enable_encryption_decode:TRUE -r ${Wireshark_file} -Y "${filter}" -w ${EXECDIR}/ue_shaping 2>/dev/null
    ${data_rate}=  Run  capinfos ${EXECDIR}/ue_shaping -i | tail -1 | awk '{ print $4 }' | tr -dc '0-9'
    ${data_rate}=        Remove String       ${data_rate}     ,
    Set Suite Variable     ${data_rate}
    ${higher_limit}=        Evaluate        ${expected_data_rate}+300
    ${lower_limit}=         Evaluate            ${expected_data_rate}-300
    Should Be True      ${data_rate}>${lower_limit}
    Should Be True      ${data_rate}<${higher_limit}
