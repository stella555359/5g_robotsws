*** Settings ***
Documentation
...        [Procedure]        "CB005994_SBTS_Slice_Addition_Deletion_modification_V4_V6"
...        [Date]             "08-06-2022"
...        [Author]           "Dineshkumar"
...        [Feature_ID]       "CB005994"
...        [Maintenance]      "TRS I & V Tools Bangalore Team"
...        [Funtion_Hash_Tags] "Netact ,Network slicing"
...        [DELTA_FILE_DEPENDENCY]  "create_slice2.json,delete_slice2.json"
...        [Validated_TestLine]     "2005"
...        [Precondition]             "ENodeB should be integrated to Netact"

variables       ta_e2e_bts_trs_fw

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Library     random
Library        taf.sw.scout    WITH NAME   scout

Suite Setup		Pre-conditions for testsuite
Suite Teardown	Post-conditions for testteardown

*** Variables ***
${SA_slicing_moc}   //SNSSAI_R
${min_slice_value}      1
${max_slice_value}        2
${5G_UE}     5g:device_1:data
${AMFID}    1

***Test Cases***
[1][1.0] CB005994_SBTS_Slice_Addition_Deletion_modification_V4_V6

    Verify build and load SCF
    Verify AMF link and Onair status
    ${min_slice_value}=  Convert to Integer    1
    ${max_slice_value}=  Convert to Integer    2
    ${slice_id}=  random.randint    ${min_slice_value}     ${max_slice_value}
    set suite variable   ${slice_id}    ${slice_id}
    Add slice and check status of slices
    Modify and check the slice status
    Delete slice and check the status of slice

*** Keywords ***
Add slice and check status of slices
	Perform Recommissioning    type=delta      delta_file=${create_slice_2}      skip_parameter_relation_errors=False
    Sleep   30
    ${Slice_status_moc}=             Query Admin Infomodel    query=get object ${SA_slicing_moc}-1   timeout=60
	${status}=     Get From Dictionary     dictionary=${Slice_status_moc}      key=operationalState
    Should be equal     ${status}       enabled
    Verify AMF link and Onair status
    Verify 5G UE call
    Analyze Slice id_1 from wireshark

Modify and check the slice status
    Perform Recommissioning     type=param      param_path=MRBTS-2348/NRBTS-2348/SNSSAI-${min_slice_value}:administrativeState   operation=update
    ...   value=Locked
    Sleep   10
    Perform Recommissioning     type=param      param_path=MRBTS-2348/NRBTS-2348/SNSSAI-${min_slice_value}:sd   operation=update   value=13714343
    Sleep   10
    Perform Recommissioning     type=param      param_path=MRBTS-2348/NRBTS-2348/SNSSAI-${min_slice_value}:administrativeState   operation=update
    ...   value=Unlocked
    Sleep   10
    ${Slice_status_moc}=             Query Admin Infomodel    query=get object ${SA_slicing_moc}-1   timeout=60
    ${status}=     Get From Dictionary     dictionary=${Slice_status_moc}      key=operationalState
    Should be equal     ${status}       enabled
    Verify AMF link and Onair status
    Perform Recommissioning     type=param      param_path=MRBTS-2348/NRBTS-2348/SNSSAI-${min_slice_value}:administrativeState   operation=update
    ...   value=Locked
    Sleep   10
    Perform Recommissioning     type=param      param_path=MRBTS-2348/NRBTS-2348/SNSSAI-${min_slice_value}:sd   operation=update   value=13714341
    Sleep   10
    Perform Recommissioning     type=param      param_path=MRBTS-2348/NRBTS-2348/SNSSAI-${min_slice_value}:administrativeState   operation=update
    ...   value=Unlocked
    Sleep   10
    ${Slice_status_moc}=             Query Admin Infomodel    query=get object ${SA_slicing_moc}-1   timeout=60
    ${status}=     Get From Dictionary     dictionary=${Slice_status_moc}      key=operationalState
    Should be equal     ${status}       enabled
    Verify AMF link and Onair status
    Verify 5G UE call
    Analyze Slice id_1 from wireshark

Delete slice and check the status of slice
    Perform Recommissioning     type=param      param_path=MRBTS-2348/NRBTS-2348/SNSSAI-${max_slice_value}:administrativeState   operation=update
    ...   value=Locked
    Sleep   10
	Perform Recommissioning    type=delta      delta_file=${delete_slice_2}      skip_parameter_relation_errors=False
    Sleep   30
	Perform Recommissioning     type=param      param_path=MRBTS-2348/NRBTS-2348/SNSSAI-${min_slice_value}:administrativeState   operation=update
    ...   value=Locked
	Sleep	10
    Perform Recommissioning     type=param      param_path=MRBTS-2348/NRBTS-2348/SNSSAI-${min_slice_value}:administrativeState   operation=update
    ...   value=Unlocked
	${Slice_status_moc}=             Query Admin Infomodel    query=get object ${SA_slicing_moc}-1  timeout=60
    ${status}=     Get From Dictionary     dictionary=${Slice_status_moc}      key=operationalState
    Should be equal     ${status}       enabled
    Verify AMF link and Onair status
    Verify 5G UE call
    Analyze Slice id_1 from wireshark

Verify build and load SCF
    ${active_sw}    ${passive_sw} =    Get Sw Version    timeout=30    alias=default
    ${split}=    Split String    ${active_sw}    _
    ${build_version}=  Set Variable    ${split[2]}
    Log    ${build_version}
    Run Keyword If      '${build_version}' == '9999'     Load Trunk SCF      ELSE    Load Branch SCF

Load Trunk SCF
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${Base_slicing_scf_tr}   verify_bts_status=False
    ...      timeout=400     alias=default     skip_parameter_relation_errors=${True}
    Sleep   180
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm   faultid=${Core_dump}  severity=major  should_exist=false
    ...   occurrences=0

Load Branch SCF
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${Base_slicing_scf_br}   verify_bts_status=False
    ...      timeout=400     alias=default     skip_parameter_relation_errors=${True}
    Sleep   180
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm   faultid=${Core_dump}  severity=major  should_exist=false
    ...   occurrences=0

Verify 5G UE call
    Enable Airplane mode
    Traffic Capture Start        capture_device=oam_device   mode=file   measurement_point=NE_Terminated  uplane_capturing=True   timeout=120
    Initiate 5G Call and Verify UE IP
    Call Start      5g=device_1:data        profile=udp_100M_dl       iperf_section=device1
    BuiltIn.Sleep    20
    Call Stop       5g=device_1:data        profile=udp_100M_dl        iperf_section=device1
    Call Teardown        5g=device_1:data
    ${5g_pcap}=   taf.ul.trs_e2e_fw.lib.traffic.traffic_interface.Traffic Capture Stop     mode=file     timeout=120
    Analyse Pcap        pcap_filename=${5g_pcap}   analysis=nr_registration_accept
    Set Suite Variable      ${5g_pcap}

Analyze Slice id_2 from wireshark
    Analyse Pcap        pcap_filename=${5g_pcap}   analysis=slice2

Analyze Slice id_1 from wireshark
    Analyse Pcap        pcap_filename=${5g_pcap}   analysis=slice1

Initiate 5G Call and Verify UE IP
    ${ue_ip_dict}=  Call Setup      5g=device_1:data    parallel=${False}         verify_attach=${False}
    ${ip}=    Get From Dictionary    ${ue_ip_dict}    ${5G_UE}
    Set Suite Variable    ${${5G_UE}}    ${ip}
    Log    UE IP for NR set to: ${ip}
    BuiltIn.Should Match Regexp    ${ip}    ^(10|9a00)

Enable Airplane mode
    Setup Remote Access         remote_device=remote_pi
    Remote Command Execute              command=adb -s RZCW918YZ1F shell cmd connectivity airplane-mode enable

Verify AMF link and Onair status
    ${nglink}=    Query Admin Infomodel    query=get object //SERVEDAMF_R-${AMFID}
    ${Static_ngLinkStatus}=     Get From Dictionary     dictionary=${nglink}      key=ngLinkStatus
    Should Be Equal As Strings      ${Static_ngLinkStatus}     Active
    Verify Bts Status   should_be_onair=${True}     req_rat=nr