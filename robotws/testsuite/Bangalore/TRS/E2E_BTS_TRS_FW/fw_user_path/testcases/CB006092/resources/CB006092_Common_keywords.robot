*** Settings ***
Documentation
...            [Author]         "Nandini R"

Resource        ${CURDIR}/../../resources/common_keywords.robot
Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot

*** Keywords ***

Restore Vendor Certificates
	Certificate Configure    dut=vcu_cran12      operation=restore_vendor_certificate
	Sleep	30

Initialize CMP Certificate
 	[Arguments]     ${cert_type}
	Certificate Configure     dut=vcu_cran12       operation=install_cmp_certificate       key_pool_type=${cert_type}    timeout=120
	Sleep   30

Fetch Certs from vCU and Configure Netconf
	[Arguments]		${cert_type}
	Run	cd /home/ute ; mkdir netconf
	Run	rm /home/ute/netconf/*
	Setup Remote Access	remote_device=vcu_cran12.ocp
	Sleep	10
	${key}=		Run Keyword If		'${cert_type}'=='RSA'	Set Variable	${rsa_privetkey}	ELSE	Set Variable	${ecdsa_privetkey}
	${cert}=	Run Keyword If		'${cert_type}'=='RSA'	Set Variable	${rsa_servercert}	ELSE	Set Variable	${ecdsa_servercert}
	${ta}=		Run Keyword If		'${cert_type}'=='RSA'	Set Variable	${rsa_cacert}		ELSE	Set Variable	${ecdsa_cacert}

	Execute Interactive Remote Command	command=kubectl exec -it -n ${namespace} ${oam_pod} -c ${cert_container} -- cat ${key} > ${privatekey}
	Execute Interactive Remote Command	command=kubectl exec -it -n ${namespace} ${oam_pod} -c ${cert_container} -- cat ${cert} > ${servercert}
	Execute Interactive Remote Command	command=kubectl exec -it -n ${namespace} ${oam_pod} -c ${cert_container} -- cat ${ta} > ${cacert}
	Get File From Remote Host	${privatekey}	${netconf_privatekey}
	Get File From Remote Host	${servercert}	${netconf_servercert}
	Get File From Remote Host	${cacert}		${netconf_cacert}
	[Teardown]		Teardown Remote Access
	Run	sudo cp /home/ute/netconf/*.pem ${pano_cert_path_1}
	Run	sudo cp /home/ute/netconf/*.pem ${pano_cert_path_2}

Get fingerprint and Configure MPLANEONAP and VES with '${cert_type}' certificate
	${fingerprint}=		Run		openssl x509 -in ${netconf_cacert} -noout -fingerprint | cut -d "=" -f 2
	Run		cp ${CB006092_template_file} ${CB006092_delta_file}
	Run		sed -i 's/{{fingerprint}}/02:${fingerprint}/g' ${CB006092_delta_file}
	Run		sed -i 's/{{cert_type}}/${cert_type}/g' ${CB006092_delta_file}
	Perform Recommissioning	    dut=vcu_cran12	type=delta      delta_file=${CB006092_delta_file}     timeout=400

Verify heartbeat notifications and time interval
	Should Match Regexp		${pano_output}		Received event: 3gppNotifyHeartBeat
	Should Match Regexp		${pano_output}		"eventName":"StndDefined_vCu-Nokia_3gppNotifyHeartBeat"
	Verify VES source name		${VES_name}

	${time}=	Run	cat ${pano_log} | grep "eventName: StndDefined_vCu-Nokia_3gppNotifyHeartBeat" | awk '{print $2}'
	${time_list}=	Split To Lines	${time}
	${length}=	Get Length	${time_list}
	FOR	${index}	IN RANGE	1	${length}
		${prev_index}=		Evaluate	${index}-1
		${time}=    Subtract Time From Time     ${time_list}[${index}]        ${time_list}[${prev_index}]
		Run Keyword And Ignore Error	Should Be Equal     ${time}     ${30}
	END

Verify VES source name
	[Arguments]		${source_name}
	Should Match Regexp     ${pano_output}     "reportingEntityName":"${source_name}"
	Should Match Regexp     ${pano_output}     "sourceName":"${source_name}"

Verify MOI notification change messages
	Should Match Regexp     ${pano_output}     Received event: 3gppNotifyMoiChanges
	Should Match Regexp     ${pano_output}     "eventName":"StndDefined_vCu-Nokia_3gppNotifyMoiChanges"
	Should Match Regexp     ${pano_output}     "eventId":"stndDefined-3gppCmProvisioning

Verify CM Feedback notification messages and time interval
	[Documentation]		Use Operation values provision, validation, etc
	[Arguments]		${operation}
	Should Match Regexp     ${pano_output}     Received event: VsCmOperationFeedbackNotification
	Should Match Regexp     ${pano_output}     Event VsCmOperationFeedbackNotification count: \\d{1}
	Should Match Regexp     ${pano_output}     "eventName":"Other_vCu-Nokia_VsCmOperationFeedbackNotification"
	Should Match Regexp     ${pano_output}     "eventId":"other-vsCmOperation\\d+FeedbackNotification
	Should Match Regexp     ${pano_output}     "operationName":"${operation}"
	Should Match Regexp     ${pano_output}     "status":"ongoing"
	Should Match Regexp     ${pano_output}     "status":"completed"
	Should Match Regexp     ${pano_output}     "messageResult":"ok"

	${time}=	Run	cat ${pano_log} | grep "Received event: VsCmOperationFeedbackNotification" | awk '{print $2}'
	${time_list}=	Split To Lines	${time}
	${length}=	Get Length	${time_list}
	FOR	${index}	IN RANGE	1	${length}
		${prev_index}=		Evaluate	${index}-1
		${time}=    Subtract Time From Time     ${time_list}[${index}]        ${time_list}[${prev_index}]
		Run Keyword And Ignore Error	Should Be Equal     ${time}     ${10}
	END

Start Netconf server and verify status
	[Arguments]		${hostname}
	${status}=		Run		expect ${CURDIR}/netconf_connect_client.exp ${hostname}
	Should Match Regexp		${status}	Current NETCONF session
	Should Match Regexp		${status}	Transport   : TLS
	Should Match Regexp     ${status}	Host.*: ${vCU_Mplane_IP}
	Should Match Regexp     ${status}	Port.*: 6513

Start Netconf server and verify session couldnt be connected
	[Arguments]		${hostname}
	${status}=		Run		expect ${CURDIR}/netconf_connect_client.exp ${hostname}
	Should Match Regexp		${status}	Client is not connected to any NETCONF server.

Start Pano and Activate Oran O1 and CM Events Flag
	Verify Alarm       dut=vcu_cran12       faultid=4639	severity=minor		should_exist=${True}      timeout=120
	Start Pano server and log collection
	Perform Recommissioning	    dut=vcu_cran12    type=delta      delta_file=${Onap_delta}    skip_parameter_relation_errors=${True}    timeout=120
	Sleep   120
	Verify Alarm       dut=vcu_cran12       faultid=4639	severity=minor		should_exist=${False}      timeout=120
	[Teardown]		Stop Pano server

Start Pano and Perform delta Operations via BTS
	Run     rm ${pano_log}
	Run     nohup pano start-ves >> ${pano_log} &
	Perform Recommissioning	    dut=vcu_cran12    type=delta      delta_file=${modify_delta}    skip_parameter_relation_errors=${True}    timeout=120
	Sleep   30
	[Teardown]      Stop Pano server

Start Pano and Perform delta Operations via netconf
	[Arguments]		${hostname}		${operation}
	Verify Alarm       dut=vcu_cran12       faultid=4639	severity=minor		should_exist=${True}      timeout=120
	Start Pano server and log collection
	Verify editconfig operations from netconf		${hostname}		${operation}
	Sleep	10
	Verify Alarm       dut=vcu_cran12       faultid=4639	severity=minor		should_exist=${False}      timeout=120
	[Teardown]      Stop Pano server

Verify editconfig operations from netconf
	[Arguments]		${hostname}		${operation}
	${status}=      Run     expect ${CURDIR}/netconf_get_config_filter.exp ${hostname} ${netconf_VES_delta}
	OperatingSystem.File Should Exist			${netconf_VES_delta}
	OperatingSystem.File Should Not Be Empty	${netconf_VES_delta}
	Run		sed -i '1d;$d' ${netconf_VES_delta}
	Run		sed -i 's/${VES_name}/${new_VES_name}/g' ${netconf_VES_delta}
	${status}=      Run     expect ${CURDIR}/netconf_delta.exp ${hostname} ${netconf_VES_delta} ${operation}

Verify get getconfig and validate operations from netconf
	[Arguments]		${hostname}
	${status}=      Run     expect ${CURDIR}/netconf_get_and_get_config.exp ${hostname} ${SCF_via_get} ${SCF_via_get_config}
	OperatingSystem.File Should Exist			${SCF_via_get_config}
	OperatingSystem.File Should Not Be Empty	${SCF_via_get_config}
	OperatingSystem.File Should Exist			${SCF_via_get}
	OperatingSystem.File Should Not Be Empty	${SCF_via_get}
	Run		sed -i '1d;$d' ${SCF_via_get_config}
	Start Pano server and log collection
	${status}=      Run     expect ${CURDIR}/netconf_validate.exp ${hostname} ${SCF_via_get_config}
	[Teardown]		Stop Pano server

Start Pano server and log collection
	Run     rm ${pano_log}
	Run     nohup pano start-ves >> ${pano_log} &

Stop Pano server
	Run     pano stop-ves
	${pano_output}=      Run     cat ${pano_log}
	Set Suite Variable		${pano_output}		${pano_output}