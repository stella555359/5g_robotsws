***Settings***
Documentation
    ...     [Procedure]             "CB006886-B verify IPDV counters"
	...		[SCF]					"scfc_vlan_ipv4.xml"
    ...     [Date]                  "21-06-01"
    ...     [Author]                "Nandini Periyaswamy"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB006886"
    ...     [Validation_status]     "Validated"
    ...     [Validated_TestLine]    "5G-9001"

#Force Tags    SM TRSIV Test 3    QCD_MN_5G    QCP_5G    CRT
#robot -L trace -b trace.txt -v bts_id:9001 -v scfc_name:SCF_100_TWAMP_metric_enabled.xml
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot



Suite Setup     Pre-conditions for testsuite
Suite Teardown     Post-conditions for testteardown

*** Test Cases ***
[1]CB006886B_US12_13_14 Enable and Disabe Enhanced metrics and verify 15 and 5min PM interval_03_03
    Precondition
    Bring setup on-air
    Perform Recommissioning     type=delta       delta_file=${100_twampsender_IPDV}        skip_parameter_relation_errors=${True}      timeout=300
    Verify unexpected alarms

#Verification of IPDV counters,there is internal calculation made to calculate the IPDV.Verifying only whether IPDV counters are incrementing or not.
#minusIPDV and mindsIPDV ,can be 0
    Sleep    120
    Perform Recommissioning     type=delta       delta_file=${unlock_100_Twamp_sender}        skip_parameter_relation_errors=${True}      timeout=300
    ${twampy_command}=    Set Variable    python /home/ute/Downloads/Base_SCF/New_TWAMPY/twampy.py responder --load_json
    ...     /home/ute/Downloads/Base_SCF/New_TWAMPY/sample.json --section s1 s2 --padding 100 -d >twamp.txt & echo $! > pid.txt
    Run     ${twampy_command}
    sleep    360
	Pm Counters Start     analysis=Verify_IPDV_counters       pm_interval=15    counter_analysis_file=${CB006886_traffic_filter}
    Sleep    180
    Verify Pm Counters      analysis=Verify_IPDV_counters       pm_interval=15   counter_analysis_file=${CB006886_traffic_filter}
    Kill twampy
#verification of packet duplication,in sample.json file number of upstream packet duplication is specified.in scf twamp message rate is keep
#as 10 packets persecond.And for each session 10 duplicate packets are introduced.Hence verifying the same in counters.
    sleep       60
    Send upstream duplicated twamp packets and check counters           enabled
    Sleep   60

    Send downstream duplicated twamp packets and check counters         enabled

    Sleep    60
    Disable enhanced metric flag and check duplicate counters are not incremented
    Sleep    60
    Enable enhanced metric flag and check duplicate counters are incremented
    Verify unexpected alarms
    [Teardown]          Keywords to run at end


*** Keywords ***

Bring setup on-air
    Call Setup  lte=Plain_config_CUS:data    parallel=${False}    verify_attach=${False}    attach=${False}
    Sleep    60
    Verify Bts Status       req_rat=all
    ${link_status}=   Get Parameter       param_path=${mme_moc}-0:${s1_link}
    Should Be True    '${link_status}'=='available'


Disable enhanced metric flag and check duplicate counters are not incremented
	Perform Recommissioning     type=delta       delta_file=${disable_enhanced_metric}        skip_parameter_relation_errors=${True}      timeout=300
    Send upstream duplicated twamp packets and check counters          disabled
    Sleep    120
    Send downstream duplicated twamp packets and check counters        disabled

Enable enhanced metric flag and check duplicate counters are incremented
	Perform Recommissioning     type=delta       delta_file=${enable_enhanced_metric}        skip_parameter_relation_errors=${True}      timeout=300
    Send upstream duplicated twamp packets and check counters        enabled
    Sleep    60
    Send downstream duplicated twamp packets and check counters      enabled

Send upstream duplicated twamp packets and check counters
    [Arguments]             ${enhanced_metric}
    Copy File   ${counter_path}/${CB006886_traffic_filter}     ${counter_path}/${CB006886_traffic_filter_bkp}
    ${sed_command}=    Set Variable    sudo sed -i "s/anamoly_counter/${us_dup_counter_moc}/g" ${counter_path}/${CB006886_traffic_filter}
    Run     ${sed_command}
#a    sleep    180
#   Pm Counters Start     analysis=Verify_anamoly_twamp_counters       pm_interval=5     counter_analysis_file=${CB006886_traffic_filter}
    Pm Counters Start     analysis=Verify_anamoly_twamp_counters       pm_interval=15     counter_analysis_file=${CB006886_traffic_filter}
    Traffic Capture Start       capture_device=vm_eth3_interface         alias=us_session
    ${twampy_command_US_Dup}=    Set Variable    python /home/ute/Downloads/Base_SCF/New_TWAMPY/twampy.py responder --load_json /home/ute/Downloads
    ...     /Base_SCF/New_TWAMPY/sample.json --section us_duplicate_1 us_duplicate_2 --padding 100 -d >twamp.txt & echo $! > pid.txt
    Run     ${twampy_command_US_Dup}
    Sleep  120
    ${TWAMP_Traffic} =      Traffic Capture Stop    alias=us_session
#   sleep   30
    Set Suite Variable      ${TWAMP_Traffic}
    FOR    ${i}        IN RANGE    1       101
           ${port}=         Run Keyword IF     ${i}<10        Set Variable        500${i}
    ...     ELSE IF    ${i}==10       Set Variable        50${i}
    ...     ELSE IF    ${i}==100       Evaluate     5${i}+10
    ...     ELSE        Evaluate        50${i}+10
           Count number of packets duplicated in upstream       ${port}
           Run Keyword if      '${enhanced_metric}'=='enabled'            Set Suite Variable      ${anamoly_cnt_${i}}       ${dup_pkt}
           ...           ELSE   Set Suite Variable      ${anamoly_cnt_${i}}       0
    END
    Verify Pm Counters      analysis=Verify_anamoly_twamp_counters       pm_interval=15   counter_analysis_file=${CB006886_traffic_filter}
    Kill twampy
    Copy File   ${counter_path}/${CB006886_traffic_filter_bkp}     ${counter_path}/${CB006886_traffic_filter}


Send downstream duplicated twamp packets and check counters
    [Arguments]             ${enhanced_metric}
    Copy File   ${counter_path}/${CB006886_traffic_filter}     ${counter_path}/${CB006886_traffic_filter_bkp}
    ${sed_command_Dup}=    Set Variable    sudo sed -i "s/anamoly_counter/${ds_dup_counter_moc}/g" ${counter_path}/${CB006886_traffic_filter}
    Run     ${sed_command_Dup}
	Pm Counters Start     analysis=Verify_anamoly_twamp_counters       pm_interval=15     counter_analysis_file=${CB006886_traffic_filter}
	Traffic Capture Start 		capture_device=vm_eth3_interface		 alias=ds_session
    ${twampy_command_DS_Dup}=    Set Variable    python /home/ute/Downloads/Base_SCF/New_TWAMPY/twampy.py responder --load_json /home/ute/Downloads/
    ...     Base_SCF/New_TWAMPY/sample.json --section ds_duplicate_1 ds_duplicate_2 --padding 100 -d >twamp.txt & echo $! > pid.txt
    Run     ${twampy_command_DS_Dup}
    sleep	120
	${TWAMP_Traffic} =		Traffic Capture Stop 	alias=ds_session
#	sleep	30
    Set Suite Variable      ${TWAMP_Traffic}
    FOR    ${i}        IN RANGE    1       101
           ${port}=         Run Keyword IF     ${i}<10        Set Variable        500${i}
    ...     ELSE IF    ${i}==10       Set Variable        50${i}
    ...     ELSE IF    ${i}==100       Evaluate     5${i}+10
    ...     ELSE        Evaluate        50${i}+10
           Count number of packets duplicated in downstream       ${port}
           Run Keyword if      '${enhanced_metric}'=='enabled'             Set Suite Variable      ${anamoly_cnt_${i}}       ${dup_pkt}       ELSE
           ...           Set Suite Variable      ${anamoly_cnt_${i}}       0
    END
    Verify Pm Counters      analysis=Verify_anamoly_twamp_counters       pm_interval=15   counter_analysis_file=${CB006886_traffic_filter}
    Kill twampy
    Copy File   ${counter_path}/${CB006886_traffic_filter_bkp}     ${counter_path}/${CB006886_traffic_filter}

Count number of packets duplicated in upstream
    [Arguments]        ${twamp_port}
    ${output}=    Set Variable    tshark -o twamp.port:5000-5200 -r ${TWAMP_Traffic} -Y "udp.dstport == ${twamp_port} " -T fields
    ...     -e twamp.seqnum.sender 2>/dev/null
    Run     ${output}
    log     ${output}
    ${sender_sequence_number}=          Split to lines   ${output}
	${SSN_length}=		Get Length		${sender_sequence_number}
    ${output1}=    Set Variable        tshark -o twamp.port:5000-5200 -r ${TWAMP_Traffic} -Y "udp.dstport == ${twamp_port} " -T fields
    ...     -e twamp.seqnum.reflector 2>/dev/null
    Run     ${output1}
    log     ${output1}
    ${reflector_sequence_number}=          Split to lines   ${output1}
    ${dup_pkt}=      Set Variable    0
	${RSN_length}=		Get Length		${reflector_sequence_number}
    FOR    ${i}        IN RANGE    0       ${SSN_length}-1
           ${curr_pkt}=        Evaluate     ${i}+1
           ${status}=      Run Keyword and return status       Should Be True     ${sender_sequence_number}[${curr_pkt}]==${sender_sequence_number}
           ...      [${i}] and ${reflector_sequence_number}[${curr_pkt}]>${reflector_sequence_number}[${i}]
           ${dup_pkt}=         Run Keyword If     '${status}'=='True'      Evaluate  ${dup_pkt}+1        ELSE      Set Variable     ${dup_pkt}
           Set Suite Variable       ${dup_pkt}
    END
    Set Suite Variable       ${dup_pkt}
    Should not be equal    ${dup_pkt}     0


Count number of packets duplicated in downstream
    [Arguments]        ${twamp_port}
    ${output}=    Set Variable    tshark -o twamp.port:5000-5200 -r ${TWAMP_Traffic} -Y "udp.dstport == ${twamp_port} " -T fields
    ...     -e twamp.seqnum.sender 2>/dev/null
    Run     ${output}
    log     ${output}
    ${sender_sequence_number}=          Split to lines   ${output}
	${SSN_length}=		Get Length		${sender_sequence_number}
    ${output1}=    Set Variable        tshark -o twamp.port:5000-5200 -r ${TWAMP_Traffic} -Y "udp.dstport == ${twamp_port} " -T fields
    ...     -e twamp.seqnum.reflector 2>/dev/null
    Run     ${output1}
    log     ${output1}
    ${reflector_sequence_number}=          Split to lines   ${output1}
    ${dup_pkt}=      Set Variable    0
	${RSN_length}=		Get Length		${reflector_sequence_number}
    FOR    ${i}        IN RANGE    0       ${SSN_length}-1
           ${curr_pkt}=        Evaluate     ${i}+1
           ${status}=      Run Keyword and return status       Should Be True     ${sender_sequence_number}[${curr_pkt}]==${sender_sequence_number}
           ...      [${i}] and ${reflector_sequence_number}[${curr_pkt}]==${reflector_sequence_number}[${i}]
           ${dup_pkt}=         Run Keyword If     '${status}'=='True'      Evaluate  ${dup_pkt}+1        ELSE      Set Variable     ${dup_pkt}
           Set Suite Variable       ${dup_pkt}
    END
    Set Suite Variable       ${dup_pkt}
    Should not be equal    ${dup_pkt}     0

Precondition
     ${interface_adddress_last_octet}=        Set Variable        209
     ${interface_adddress_last_octet_IPv6}=      Set Variable        0X06
     ${sim_ip}=            Set Variable     20

    Copy File     ${delta_dir}/${delta_4_vlan}    ${delta_dir}/${delta_4_vlan_copy}
    ${vlan_id}=    Set Variable     ${vlan_ids}[1]
    FOR        ${i}        IN RANGE    0       5
           ${nw_ipv4}=         Evaluate            ${interface_adddress_last_octet}-1
           ${nw_ipv6}=         Evaluate            hex(${interface_adddress_last_octet_IPv6}-2)
           ${nw_ipv6}=         Evaluate            hex(${nw_ipv6}).lstrip("0x")
           ${broadcast_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+2
           ${interface_adddress_last_octet_IPv6_hex}=      Evaluate        hex(${interface_adddress_last_octet_IPv6}).lstrip("0x")
           Bring IPv4 VLAN VM Interfaces       ${vlan_id}            10.0.3.${interface_adddress_last_octet}
           ...      10.0.3.${broadcast_adddress_last_octet}     30
           Run         sudo ifconfig eth3.${vlan_id} inet6 add fc00::3:${interface_adddress_last_octet_IPv6_hex}/126
           ${ENB_interface_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+1
           ${interface_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+4
           ${interface_adddress_last_octet_IPv6}=          Evaluate        hex(${interface_adddress_last_octet_IPv6}+4)
            Run     sudo sed -i "s/{{vlan_id${i}}}/${vlan_id}/g" ${delta_dir}/${delta_4_vlan}
            ${vlan_id}=      Evaluate      ${vlan_id}+1
    END
#     FOR    ${i}    IN RANGE        0       13
#           Run         sudo ip a a 10.0.1.${sim_ip}/24 dev eth3.${vlan_ids}[0]
#           ${sim_ip}=    Evaluate   ${sim_ip}+1
#     END

    Perform Recommissioning     type=delta      delta_file=${delta_4_vlan}     timeout=300
    Sleep     60

    [Teardown]           Copy File     ${delta_dir}/${delta_4_vlan_copy}    ${delta_dir}/${delta_4_vlan}


Bring IPv4 VLAN VM Interfaces
    [Arguments]             ${Vlan_ID}          ${interface_address}        ${broadcast_ip_address}         ${sunbet_mask}
    Run Keyword And Ignore Error    sudo ip link add link eth3 name eth3.${Vlan_ID} type vlan id ${Vlan_ID}
    Run     sudo ip addr add ${interface_address}/${sunbet_mask} brd ${broadcast_ip_address} dev eth3.${Vlan_ID}
    Run     sudo ip link set dev eth3.${Vlan_ID} up


Kill twampy
    ${pid}=   Run    'ps -eaf | grep twampy | awk '{print $2}''
    @{id}=          Split to lines   ${pid}
     ${length}=   Get Length      ${id}
     FOR     ${i}    IN RANGE    0    ${length}
          Run Keyword And Ignore Error    sudo kill -9 ${id}[${i}]
     END

Keywords to run at end
    Kill twampy
    Copy File   ${counter_path}/${CB006886_traffic_filter_bkp}     ${counter_path}/${CB006886_traffic_filter}
    Run Keyword And Ignore Error         Traffic Capture Stop   alias=us_session
    Run Keyword And Ignore Error         Traffic Capture Stop   alias=ds_session

Verify unexpected alarms
    [Documentation]    apart from the alarm id present the expected_alarms list , keyword will fail
    Verify alarm        expected_alarms=${expected_alarms}    check_unexpected_alarms=True