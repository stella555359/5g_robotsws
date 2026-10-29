*** Settings ***
Documentation
	...		[Procedure]				"Ths script has common keywords for 5G network sclicing (5GC000988) feature "
	...		[Date]					"07-10-2020"
	...		[Author]				"Madhu Chinthakindi"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"COMMON SLICE"
	...   	[Feature_ID]         	"5GC00988"
	...  	[Validation_status]  	"Partially Validated"
	...   	[Validated TestLine] 	"5G_9047"


Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/common_keywords.robot
Library         random



*** Keywords ***

GetSliceCount
   [Documentation]		This keywrod is to get number of SNSSAI configured
    @{slice_Objects_dict_list} =    Query Admin Infomodel    query=get list ${slice_a_moc_path}*
#   *
    ${SliceCount}=    Get Length    ${slice_Objects_dict_list}
    Set Suite Variable     ${SliceCount}

GetSliceIds
   [Documentation]		This keywrod is to get all  cnfigured SNSSAI ids
    @{sliceindex_list}=   Create List
    FOR    ${sliceindex}    IN RANGE    1    21
       ${output}=         Run Keyword And Return Status     Query Admin Infomodel    query=get object ${slice_a_moc_path}${sliceindex}
       Run Keyword If     ${output} == True     Append To List	    ${sliceindex_list}    ${sliceindex}
    END
    Set Suite Variable     ${sliceindex_list}

GetSNSSAIDetails
   [Documentation]		This keywrod is to SNSSAI detais of given SNSSAI id. Arg ${sliceindexvar} is SNSSAI ID to be verify
   [Arguments]         ${sliceindexvar}
   ${sliceObjects_dict} =    Query Admin Infomodel    query=get object ${slice_a_moc_path}${sliceindexvar}
   ${administrativeState}=    Get From Dictionary    dictionary=${sliceObjects_dict}    key=administrativeState
   ${operationalState}=    Get From Dictionary    dictionary=${sliceObjects_dict}    	key=operationalState
   ${SliceDifferentiator}=    Get From Dictionary    dictionary=${sliceObjects_dict}    key=sd
   ${SliceServiceType}=    Get From Dictionary    dictionary=${sliceObjects_dict}    	key=sst
   #${snssaiId}=    		Get From Dictionary    dictionary=${sliceObjects_dict}    	key=snssaiId
   ${nGuIp}=    Get Parameter    param_path=${sliceSrcIpAddrDN}:ipV4AddressDN1
   ${nGuIp6}=    Get Parameter    param_path=${sliceSrcIpAddrDN}:ipV6AddressDN1
   Set Suite Variable       ${administrativeState}
   Set Suite Variable       ${operationalState}
   Set Suite Variable       ${SliceDifferentiator}
   Set Suite Variable       ${SliceServiceType}
   Set Suite Variable       ${nGuIp}
   Set Suite Variable       ${nGuIp6}
   #Set Suite Variable       ${snssaiId}

Trigger Call and with sclice id
	[Documentation]		This keywrod is to trigger call and verify slicing is successful.Arg ${nwSliceid} is on which perticuler sclice
	...                 the call should be intiated.Arg ${ipv4_ipv6} is for ipv4 or ipv6 call type
	[Arguments]         ${nwSliceid}		${ipv4_ipv6}=ipv4
	Traffic Capture Start   		capture_device=vm_eth3_interface     alias=${sliceVerification}
	Perform 5G call for uplink traffic   ${nwSliceid}		${ipv4_ipv6}
	${pcap_name}=    Traffic Capture Stop    	alias=${sliceVerification}
	Set Suite Variable       ${pcap_name}
	Analyse Pcap    	pcap_filename=${pcap_name}    analysis=VerificationNetworkSlicing    filter_file_name=${traffic_filter_file_name}
	[Teardown]      Run Keyword And Ignore Error         Traffic Capture Stop   	 alias=${sliceVerification}

Trigger Call and verify no network scling
	[Documentation]		This keywrod is to trigger normal call and without slicing.
	Traffic Capture Start   		capture_device=vm_eth3_interface     alias=${noSlice}
	Perform 5G call for uplink traffic
	${pcap_name}=    Traffic Capture Stop    	alias=${noSlice}
	Set Suite Variable       ${pcap_name}
	Analyse Pcap    	pcap_filename=${pcap_name}    analysis=VerificationNoNetworkSlicing    filter_file_name=${traffic_filter_file_name}
	[Teardown]      Run Keyword And Ignore Error         Traffic Capture Stop   	 alias=${sliceVerification}

Perform 5G call for uplink traffic
    [Arguments]         ${scliceID}     ${ipver}
    Log     ${scliceID}
    Log     ${ipver}
	[Documentation]		This keywrod is to trigger 5G Call
    Call Setup      5g=NwSliceCall:data  parallel=${False}  verify_attach=${False}  ipv4_or_6=ipv4
    Sleep   5
    Verify Bts Status     req_rat=5g   should_be_onair=${True}
    Perform UE attach and send traffic
    Sleep   15
    Run Keyword And Ignore Error    Call Stop  5g=device1:data  profile=udp_ul
    [Teardown]      Call Teardown   5g=device1:data

Perform Call setup
    Call Setup      5g=NwSliceCall:data  parallel=${False}  verify_attach=${False}  ipv4_or_6=ipv4


Perform UE attach and send traffic
     Configure UE       5g=NwSliceCall:data  command=ue_register  id=${ue_id}  profile=${slice_number}
     sleep  10
     Configure UE       5g=NwSliceCall:data  command=set_pdu_param  ue=${ue_id}   pdu=${slice_number}  trf_type=internal
     sleep  10
     Configure UE       5g=NwSliceCall:data  command=ue_pdu_session_setup  pdu=${slice_number}  ue=${ue_id}  nwslice=${slice_number}
     ...                 gw=${slice_number}
     sleep  10
     Configure UE       5g=NwSliceCall:data  command=trf_data_start  ue=${ue_id}  pdu=${slice_number}    qfi=1   dir=ul   mbps=20
     sleep  10
