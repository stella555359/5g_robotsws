*** Settings ***
Documentation
...     [Author]        	"Megha H D"
...     [Maintenance]   	"TRS I & V Tools Bangalore Team"
variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../../resources/common_Cloud_keywords.robot

*** Keywords ***
Collect logs in cloud
    Run Keywords    Setup Oamops    dut=vcu      alias=default   AND     Collect Snapshot
    ...     dut=vcu  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
    ...      dut=vcu     alias=default
    Run Keywords    Setup Oamops    dut=vdu	alias=default   AND     Collect Snapshot
    ...     dut=vdu	operation_timeout=600   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
    ...      dut=vdu	alias=default

Load basic ipsec SCFC
	[Arguments]     ${dut}
	Setup Oamops	dut=${dut}      alias=${dut}
	Perform Commissioning    dut=${dut}	scf_file=${basic_scfc_${dut}_ipsec}
	...    verify_bts_status=False	timeout=300     alias=${dut}
	Sleep	60

Configure cmpserver with Expired EE certificate
	[Arguments]     ${dut}
	Setup Oamops    dut=${dut}      alias=${dut}
	Perform Recommissioning    dut=${dut}  type=delta  delta_file=${Conf_cmpserver_9741_expiry}
	...    timeout=300     alias=${dut}
	Sleep	60

Configure cmpserver with Revoked EE certificate
	[Arguments]     ${dut}
	Setup Oamops    dut=${dut}      alias=${dut}
	Perform Recommissioning    dut=${dut}  type=delta  delta_file=${Conf_cmpserver_9741_revoke}
	...    timeout=300     alias=${dut}
    	Sleep	60

Triger IR to install certificate
    [Arguments]     ${keypoolType}      ${dut}
    Setup Oamops    dut=${dut}      alias=${dut}
    Certificate Configure   dut=${dut}     operation=restore_vendor_certificate  alias=${dut}
    Sleep   60
    Certificate Configure   dut=${dut}     operation=set_certificate_automatic_management
    ...     reference_number=16092  preshared_key=this_is_very_secret   key_pool_type=${keypoolType}   alias=${dut}
    Sleep   60
    Certificate Configure   dut=${dut}    operation=install_cmp_certificate     timeout=300
    ...     key_pool_type=${keypoolType}  alias=${dut}
    Sleep   300

Verify cmp certificate state
	[Arguments]     ${dut}
	${CMP_state}=     Get Parameter     param_path=${cmp_r_moc_path}	dut=${dut}	alias=${dut}
	Should Be Equal     ${CMP_state}       CMP_InitializationOK

Copy Expired EE certificate to strongswan
	Run    sudo cp ${CURDIR}/Expired_EEcert/${cloud_9741_EE_Expired} /etc/ipsec.d/certs/
	Run    sudo cp ${CURDIR}/Expired_EEcert/${cloud_9741_privatekey_Expired} /etc/ipsec.d/private/
	Run    sudo cp ${CURDIR}/Expired_EEcert/${cloud_9741_Expired_EE_TA} /etc/ipsec.d/cacerts/
	Run    sudo cp ${CURDIR}/ipsec.conf /etc/
	Run    sudo cp ${CURDIR}/ipsec.secrets /etc/
	Run    sudo ipsec restart
	Sleep   30

Copy Revoked EE certificate to strongswan
	Run    sudo cp ${CURDIR}/Revoked_EEcert/${cloud_9741_EE_Revoked} /etc/ipsec.d/certs/
	Run    sudo cp ${CURDIR}/Revoked_EEcert/${cloud_9741_privatekey_Revoked} /etc/ipsec.d/private/
	Run    sudo cp ${CURDIR}/Revoked_EEcert/${cloud_9741_Revoked_EE_TA} /etc/ipsec.d/cacerts/
	Run    sudo cp ${CURDIR}/ipsec.conf /etc/
	Run    sudo cp ${CURDIR}/ipsec.secrets /etc/
	Run    sudo ipsec restart
	Sleep   30

Configure Mplane with ignorePeerCertValidity enabled
	[Arguments]     ${dut}
	Setup Oamops    dut=${dut}      alias=${dut}
	Sleep	10
	Perform Recommissioning    dut=${dut}  type=delta  delta_file=${Conf_ipsec_mplane_9741_${dut}}
	...	    timeout=300     alias=${dut}
	Run	sudo ipsec stop
	Sleep	10
	Run	sudo ipsec restart
	Sleep	20

Disable Mplane ignorePeerCertValidity and verify alarm is cleared
	[Arguments]     ${dut}
	Setup Oamops    dut=${dut}      alias=${dut}
	Perform Recommissioning    dut=${dut}  type=delta  delta_file=${disable_ignorePeerCertValidity}
	...    timeout=300     alias=${dut}
	Run    sudo ipsec restart
	Sleep	60
	Run    sudo ipsec restart
	Sleep	30
	Setup Oamops    dut=${dut}      alias=${dut}
	Verify Alarm	faultid=${faultnum_mplane_invalidpeercert}	should_exist=${false}	dut=${dut}	alias=${dut}
	Verify Alarm	faultid=61644       occurrences=5	dut=${dut}      alias=${dut}
	[Teardown]	Teardown Oamops     dut=${dut}     alias=${dut}

Verify Peer certificate lifetime is Expired alarm
	[Arguments]     ${dut}
	Setup Oamops	dut=${dut}		alias=${dut}
	${AlarmList}=	Verify Alarm	faultid=${faultnum_mplane_invalidpeercert}	should_exist=${True}
	...	load_history=${TRUE}	dut=${dut}      alias=${dut}
	FOR	${alarm}	IN	@{AlarmList}
		${Fault_ID}=	Get From Dictionary	${alarm}	FAULT ID
		Continue For Loop If	${Fault_ID}!=${faultnum_mplane_invalidpeercert}
		${additional_info}=	Get From Dictionary	${alarm}	ADDITIONAL INFO
		Should contain		${additional_info}	Peer certificate lifetime is Expired
		Exit For Loop If    ${Fault_ID}==61012
	END

Verify alarm with Peer certificate lifetime is Expired
	[Arguments]     ${dut}
	Setup Oamops	dut=${dut}		alias=${dut}
	Verify Alarm	faultid=61644       occurrences=4	dut=${dut}      alias=${dut}
	${AlarmList}=	Verify Alarm	faultid=${faultnum_mplane_invalidpeercert}	should_exist=${True}
	...	load_history=${TRUE}	dut=${dut}      alias=${dut}
	FOR	${alarm}	IN	@{AlarmList}
		${Fault_ID}=	Get From Dictionary	${alarm}	FAULT ID
		Continue For Loop If	${Fault_ID}!=${faultnum_mplane_invalidpeercert}
		${additional_info}=	Get From Dictionary	${alarm}	ADDITIONAL INFO
		Should contain		${additional_info}	Peer certificate lifetime is Expired
		Exit For Loop If    ${Fault_ID}==61012
	END

Verify alarm with Peer certificate is revoked
	[Arguments]     ${dut}
	Setup Oamops	dut=${dut}		alias=${dut}
	Run	sudo ipsec restart
	Sleep	30
	Verify Alarm	faultid=61644       occurrences=4	dut=${dut}      alias=${dut}
	${AlarmList}=	Verify Alarm	faultid=${faultnum_mplane_invalidpeercert}	should_exist=${True}
	...	load_history=${TRUE}	dut=${dut}      alias=${dut}
	FOR	${alarm}	IN	@{AlarmList}
		${Fault_ID}=	Get From Dictionary	${alarm}	FAULT ID
		Continue For Loop If	${Fault_ID}!=${faultnum_mplane_invalidpeercert}
		${additional_info}=	Get From Dictionary	${alarm}	ADDITIONAL INFO
		Should contain		${additional_info}	Peer certificate is revoked
		Exit For Loop If    ${Fault_ID}==61012
	END

Reset vcu and check alarm persistance
	Setup Oamops    dut=vcu      alias=vcu
	Reset     operation=reset_bts    rat=5g     dut=vcu    alias=vcu
	...     should_be_onair=${False}     verify_bts=${True}
	Sleep   120
	Run    sudo ipsec restart
	Sleep	30
	Setup Oamops    dut=vcu    alias=vcu
	Verify Alarm	faultid=${faultnum_mplane_invalidpeercert}	severity=major
	...       occurrences=1	dut=vcu      alias=vcu
	Verify Alarm	faultid=61644       occurrences=4	dut=vcu      alias=vcu
	[Teardown]	Teardown Oamops     dut=vcu     alias=vcu
