*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Force Tags    CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD    RAN_5G    RAN_5G_FDD    CRT     SBTS00    SBTS22R4    SBTS23R1

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.core    WITH NAME    core
Library    CB007813-B_keywords.py
Library      ../CB007262/CB007262_A/CB007262_keywords.py


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AHFIB_7813_B.xml
    ...                        swconfig_flags_list=@{SWCONFIG_FLAGS}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_cb007813_AHFIB_4x4_52PRB.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_7813-B.cfg


Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SMOD}    ASIB
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu
@{SWCONFIG_FLAGS}=     0x340000 = 5

*** Test Cases ***
CB007813_B2_FDD_Cell_configuration_and_setup_with_BW_30MHz_DL_and_10MHz_UL_nulling_middle_PRBs_DL__CSI-IM_and_TRS_configured_52PRBs
    Collect BIP logs and verify CSI-RS scheduling
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start High Data Traffic In DL And In UL
    Verify Tput For UE    ue_id=1   dir=ul    expected_tput=72
    Verify Tput For UE    ue_id=1   dir=dl    expected_tput=250
    [Teardown]    Stop All Data Transfers And Detach UE SA

*** Keywords ***
Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Start High Data Traffic In DL And In UL
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=1
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=80 trf_id=2
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:2
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=73
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Sleep    30s

Verify Tput For UE
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}

Stop All Data Transfers And Detach UE SA
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Setup And Start Bip Logs
    [Arguments]    ${target_file_name}=tcpdump
     ${webservice}=  Create Dictionary
     ...  host=192.168.255.129
     ...  user=Nemuadmin
     ...  password=nemuuser
     ...  port=443

     create_interface_mirroring_l1l2bip_collector
     ...  name=tcpdump
     ...  webservice=${webservice}
     ...  target_file_name=tcpdump
     ...  timeout=240
     ...  remove_zip_file=False
     core.setup_collectors    names=tcpdump
     core.start_collectors    names=tcpdump
     core.Set Suite Alias     ${target_file_name}

Stop And Collect Bip Logs
     core.stop_collectors    names=tcpdump
     core.collect_collectors    names=tcpdump    target_dir=${OUTPUT_DIR}
     core.teardown_collectors    names=tcpdump

Convert pcap file to pdml
    [Documentation]     Using luashark converting BIP log from pcap to pdml.
    [Arguments]   ${input_file}=${OUTPUT_DIR}/${TEST_NAME}/tcpdump.pcap
    Create Directory    ${OUTPUT_DIR}/${TEST_NAME}
#    Move File    ${OUTPUT_DIR}/CB007813-B-B1/tcpdump.pcap    ${OUTPUT_DIR}/${TEST_NAME}    #old bip collecting method
    Move File    ${OUTPUT_DIR}/tcpdump/BTS*.pcap    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump.pcap
    Remove Directory    ${OUTPUT_DIR}/tcpdump/
    Log to console    Converting pcap to pdml
        ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -Y dldata_csirssendreq
    ...    -T pdml > ${OUTPUT_DIR}/${TEST_NAME}/BIP_log_CSIRS.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...

Verify CSI-RS scheduling
    verify_csi_rs_split    pdml_path=${OUTPUT_DIR}/${TEST_NAME}/BIP_log_CSIRS.pdml
    verify_trs_split_52prb    pdml_path=${OUTPUT_DIR}/${TEST_NAME}/BIP_log_CSIRS.pdml

Collect BIP logs and verify CSI-RS scheduling
    Setup And Start Bip Logs
    Sleep    3s
    Stop And Collect Bip Logs
    Convert pcap file to pdml
    Verify CSI-RS scheduling
