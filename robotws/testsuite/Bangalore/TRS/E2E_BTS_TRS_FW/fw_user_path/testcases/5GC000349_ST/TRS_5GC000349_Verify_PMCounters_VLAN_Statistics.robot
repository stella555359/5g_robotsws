*** Settings ***
Documentation
...     [Procedure] "This testcase is verifying VLAN_Statistics counters,(i) at Normal interval, (ii)at different interval"
...		[Author]     	"Naresh"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     ". . . ."
...     [Feature_ID]            "5GC000349"
...     [Requirement ID]
...     [Funtion_Hash_Tags] "COUNTERS"

...     [Validated_TestLine]    "TBU"
...     [Config]    "This testscript expects Scf with Vlan configurations,vlan statistic interval to be 15 mins"
...     [Runtime param]   "bts_id is provided at run time."


Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops



*** Test Cases ***

[1][1.0] CB005750-5G-EAAM-SyVe_5GC000349_ASIL_ABIO_Parity_5GNB_collect_counters_within_measurement_interval

    Perform Commissioning       scf_file=${ETHERNET_VLAN}   verify_bts_status=False     timeout=400     alias=default
    Sleep       300

    Read vlan from admin
    Read mplane and gateway IP
   Set reference counter values    1..*

    PM Counters Start       analysis=vlan_statistics        counter_analysis_file=${counter_analysis_file_vlan}
    ...     alias=default      pm_interval=15

    Execute Command On GNB   ping -I '${mplaneIP}' '${gatewayIP}' -c 500
    Sleep   10

    Run Keyword and continue on failure     Verify PM Counters      analysis=vlan_statistics
...     counter_analysis_file=${counter_analysis_file_vlan}     alias=default      pm_interval=15


###Now Check counters for different Intrevals 5,30 etc.
    Perform Recommissioning     type=param      rat=common     param_path=${vlan_statistics_interval}       operation=update
...     value=5min      timeout=500     alias=default

    Set reference counter values    1..*

    PM Counters Start       analysis=vlan_statistics        counter_analysis_file=${counter_analysis_file_vlan}
    ...     alias=default      pm_interval=5

    Execute Command On GNB   ping -I '${mplaneIP}' '${gatewayIP}' -c 200
    Sleep   10
    Run Keyword and continue on failure    Verify PM Counters      analysis=vlan_statistics
...     counter_analysis_file=${counter_analysis_file_vlan}     alias=default      pm_interval=5

    Perform Recommissioning     type=param      rat=common     param_path=${vlan_statistics_interval}       operation=update
...     value=30min      timeout=300     alias=default

    PM Counters Start       analysis=vlan_statistics        counter_analysis_file=${counter_analysis_file_vlan}
    ...     alias=default      pm_interval=30

    Execute Command On GNB   ping -I '${mplaneIP}' '${gatewayIP}' -c 1000

    Sleep   10

    Run Keyword and continue on failure    Verify PM Counters      analysis=vlan_statistics
    ...        counter_analysis_file=${counter_analysis_file_vlan}
...     alias=default      pm_interval=30

***Keywords***

Read mplane and gateway IP
        ${mplaneIP}=     Get Parameter   param_path=${mplane_ipv4_moc}
        Set Suite Variable          ${mplaneIP}
        ${gatewayIP}=     Get Parameter   param_path=${GWIP_moc}
        Set Suite Variable          ${gatewayIP}


Set reference counter values
        [Arguments]     ${Class1}
        Set Suite Variable      ${Class1}       ${Class1}

Read vlan from admin
	${mplane1} = 			Get Parameter       rat=common    	param_path=${mplane1_ip_moc_path}
	${mplane1_ipif_dict} = 		Query Admin Infomodel		query=get object ${ipif_moc_path} is [localIpAddr=${mplane1}]
	${mplane1_ipif_moc}=		Get From Dictionary	dictionary=${mplane1_ipif_dict}		key=dist_name
	${mplane1_ipif}=			Replace String Using Regexp		string=${mplane1_ipif_moc}		pattern=${pattern_to_replace_in_moc}
...     replace_with=${EMPTY}
   	@{mplane1_ipif_path}=		Split String From Right		string=${mplane1_ipif}	separator=/
	${mplane_ipif_id}=	Set Variable	@{mplane1_ipif_path}[-2]
	${mplane1_vlan_value} = 	Get Parameter       rat=common  	 	param_path=${mplane_ipif_id}:interfaceDN:vlanId
	${mplane1_vlanif_dict} = 		Query Admin Infomodel		query=get object ${vlanif_moc_path} is [vlanId=${mplane1_vlan_value}]
	${mplane1_vlanif_moc}=				Get From Dictionary	dictionary=${mplane1_vlanif_dict}	key=dist_name
	${mplane1_vlanif}=				Replace String Using Regexp	string=${mplane1_vlanif_moc}	pattern=${pattern_to_replace_in_moc}
...     replace_with=${EMPTY}
	@{mplane1_vlanif_path}=		Split String From Right		string=${mplane1_vlanif}	separator=/
	${mplane_vlanif_id}=	Set Variable	@{mplane1_vlanif_path}[-1]

    @{vlanId_temp}=     Split String From Right     string=${mplane_vlanif_id}    separator=-
    ${vlanId}=      Set Variable     @{vlanId_temp}[-1]
    Set Suite Variable          ${vlanId}