*** Settings ***
Documentation
...		[Author]     	"Umadevi Aravindan"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"
...       [Procedure]        "[1]TRS_RP002025_asib_verification_of_right_rack_BEIF1_port_enable_disable_operation"
...        [Feature_ID]    "RP002025"
...        [Maintenance]    "TRS I & V Tools Bangalore Team"
...        [Funtion_Hash_Tags] "Backplane Port"
...        [Author]           "Dineshkumar"
...        [Validation_Staus]     "validated"
...        [Config_Comments]         "Chained setup with BEIF1 connector"
...        [Precondition]             "ENodeB should be integrated to Netact"


variables       ta_e2e_bts_trs_fw

Resource    	${CURDIR}/../resources/common_keywords.robot
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource    	${CURDIR}/../resources/Admin_Common_Library.robot
Library  random
Library        taf.sw.scout    WITH NAME   scout

Suite Setup		Run Keywords	Pre-conditions for testsuite
...	AND		Setup Oamops		dut=chained_bts     alias=Secondary
Suite Teardown	Run Keywords	Post-conditions for testteardown
...	AND		Teardown Oamops		dut=chained_bts     alias=Secondary

***Test Cases***
[1][1.0] TRS_RP002025_asib_verification_of_right_rack_BEIF1_port_enable_disable_operation

    Load scf in Primary BTS and verify Onair status
    Load scf in Secondary BTS and verify Onair status
    Enable BEIF port in Primary BTS
    Enable BEIF port in Secondary BTS
    Verify QOS status
	Check Connector Label
	Check Port Status Primary
    Check Port Status Secondary
    Verify Alarm        faultid=${LOS_on_BEIF1}    severity=major     should_exist=${False}     occurrences=1
    Disable and Enable BEIF on Primary BTS
	Verify Primary link status and Onair
    Verify Alarm        faultid=${LOS_on_BEIF1}    severity=major     should_exist=${False}     occurrences=1
    Disable and Enable BEIF on Secondary BTS
    Verify Alarm        faultid=${LOS_on_BEIF1}    severity=major     should_exist=${False}     occurrences=1   alias=Secondary
    Reset Primary BTS
    Verify BEIF status in secondary BTS after Reset
    Reset Secondary BTS
    Verify BEIF status in primary BTS after Reset
    Perform Recommissioning     type=param     param_path=ETHLK-2:administrativeState     operation=update        value=locked     timeout=1300
    Sleep   20
    Perform Recommissioning     type=param     param_path=ETHLK-2:administrativeState     operation=update        value=locked     timeout=1300
    ...    alias=Secondary
    Sleep   20

***Keywords***
Reset Primary BTS
    Reset Bts   verify_bts=False    should_be_onair=False
    Verify Alarm    faultid=6450    should_exist=${false}

Reset Secondary BTS
    Reset Bts   verify_bts=False    should_be_onair=False   wait_for=0    alias=Secondary
    Verify Alarm    faultid=6450    should_exist=${false}   alias=Secondary

Verify BEIF status in secondary BTS
    ${port_operational_status_dict} =     Query Admin Infomodel    query=get object //ETHLK-2/ETHLK_R-1     alias=Secondary
    Log    ${port_operational_status_dict}
    ${port_operational_status} =      Get From Dictionary    ${port_operational_status_dict}    operationalState
    Should Be Equal As Strings      ${port_operational_status}      disabled
    Verify Alarm        faultid=${LOS_on_BEIF1}    severity=major     should_exist=${True}     occurrences=1    alias=Secondary

Verify BEIF status in primary BTS
    ${port_operational_status_dict} =     Query Admin Infomodel    query=get object //ETHLK-2/ETHLK_R-1
    Log    ${port_operational_status_dict}
    ${port_operational_status} =      Get From Dictionary    ${port_operational_status_dict}    operationalState
    Should Be Equal As Strings      ${port_operational_status}      disabled
    Verify Alarm        faultid=${LOS_on_BEIF1}    severity=major     should_exist=${True}     occurrences=1

Verify BEIF status in secondary BTS after Reset
    ${dict} =     Query Admin Infomodel           query=get object //ETHLK_CONF_M-1/ETHLK_R-1   alias=Secondary
    ${port_status}     Get From Dictionary     dictionary=${dict}      key=operationalState
    Should Be Equal As Strings      ${port_status}      enabled
    Verify Alarm        faultid=${LOS_on_BEIF1}    severity=major     should_exist=${False}     occurrences=1    alias=Secondary

Verify BEIF status in primary BTS after Reset
    ${dict} =     Query Admin Infomodel           query=get object //ETHLK_CONF_M-1/ETHLK_R-1
    ${port_status}     Get From Dictionary     dictionary=${dict}      key=operationalState
    Should Be Equal As Strings      ${port_status}      enabled
    Verify Alarm        faultid=${LOS_on_BEIF1}    severity=major     should_exist=${False}     occurrences=1

Enable BEIF port in Primary BTS
    Perform Recommissioning    type=delta      delta_file=${enable_beif_pri}      skip_parameter_relation_errors=False
    Sleep   60

Enable BEIF port in Secondary BTS
    Perform Recommissioning    type=delta      delta_file=${enable_beif_sec}      skip_parameter_relation_errors=False      alias=Secondary
    Sleep   60

Load scf in Primary BTS and verify Onair status
    Perform Commissioning        scf_file=${pri_bts_scf}   verify_bts_status=False
    ...      timeout=400        skip_parameter_relation_errors=${True}
    Sleep   180
    Verify Alarm   faultid=${Core_dump}  severity=major  should_exist=false   occurrences=0
	Verify Primary link status and Onair

Load scf in Secondary BTS and verify Onair status
    Perform Commissioning        scf_file=${sec_bts_scf}   verify_bts_status=False
    ...      timeout=400     alias=Secondary     skip_parameter_relation_errors=${True}
    Sleep   180
    Verify Alarm   faultid=${Core_dump}  severity=major  should_exist=false   occurrences=0     alias=Secondary
	Verify Bts Status   should_be_onair=${True}     req_rat=nr

Verify QOS status
    ${QOS_status}=       Query Admin Infomodel    query=get object //L2SWI_A-1	timeout=100
    Log Dictionary    ${QOS_status}
    ${output}=      Get From Dictionary       ${QOS_status}      l2QoSEnabled
    Should be True    '${output}'=='True'
    ${QOS_status}=       Query Admin Infomodel    query=get object //L2SWI_A-1  timeout=100     alias=Secondary
    Log Dictionary    ${QOS_status}
    ${output}=      Get From Dictionary       ${QOS_status}      l2QoSEnabled
    Should be True    '${output}'=='True'

Check Connector Label
    ${pri_connectorLabel} =    Get Parameter	param_path=ETHLK-2:connectorLabel
    Log      ${pri_connectorLabel}
    Should Be Equal As Strings      ${pri_connectorLabel}   B-EIF1
    ${sec_connectorLabel} =    Get Parameter   param_path=ETHLK-2:connectorLabel   alias=Secondary
    Log      ${sec_connectorLabel}
    Should Be Equal As Strings      ${sec_connectorLabel}   B-EIF1

Check Port Status Primary
    ${dict} =     Query Admin Infomodel           query=get object //ETHLK_CONF_M-1/ETHLK_R-1
    ${port_status}     Get From Dictionary     dictionary=${dict}      key=operationalState
    Should Be Equal As Strings      ${port_status}      enabled

Check Port Status Secondary
    ${dict} =     Query Admin Infomodel           query=get object //ETHLK_CONF_M-1/ETHLK_R-1   alias=Secondary
    ${port_status}     Get From Dictionary     dictionary=${dict}      key=operationalState
    Should Be Equal As Strings      ${port_status}      enabled

Disable and Enable BEIF on Primary BTS
    Perform Recommissioning  	type=param     param_path=ETHLK-2:administrativeState     operation=update        value=locked     timeout=1300
    Sleep   20
    Perform Recommissioning     type=param     param_path=ETHLK-2:administrativeState     operation=update        value=unlocked     timeout=1300
    Sleep   20

Disable and Enable BEIF on Secondary BTS
    Perform Recommissioning     type=param     param_path=ETHLK-2:administrativeState     operation=update        value=locked     timeout=1300
    ...    alias=Secondary
    Sleep   20
    Perform Recommissioning     type=param     param_path=ETHLK-2:administrativeState     operation=update        value=unlocked     timeout=1300
    ...     alias=Secondary
    Sleep   20

Verify Primary link status and Onair
	${MMElinkstatus}=   Get Parameter   param_path=MRBTS-2309/LNBTS-2309/LNMME-0:s1LinkStatus
    Should Be Equal    ${MMElinkstatus}       available
	Verify Bts Status   should_be_onair=${True}     req_rat=lte