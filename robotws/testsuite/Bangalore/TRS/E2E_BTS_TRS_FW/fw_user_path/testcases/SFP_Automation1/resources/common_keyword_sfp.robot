*** Settings ***
Documentation
    ...     [Procedure]             "This testcase covers check for 10G,1G and 50G SFP"
    ...     [Date]                  "01-09-23"
    ...     [Author]                "Sushma R"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "SFP"
    ...     [Feature_ID]            "RP000502,RP000371,CB007839"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "5G-3907"
	...     [Config]    			"Basic SCF with ETHLK-1,2 and 3 connected with 10G,1G,50G SFP respectively"

Variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot

*** Keywords ***
Vendor Details
    ${vendor_Name_status_dict} =     Query Admin Infomodel    query=get list //CABINET_R-1/SMOD_R-1/SFP_R-*
    FOR	${i}	 IN	@{vendor_Name_status_dict}
    	${physicalPort} =      Get From Dictionary    ${i}    physicalPort
    	Run Keyword if      '${physicalPort}'== '${working_port}'       Run keywords	Set Suite Variable
    	...     ${vendor_Name_status_dict_new}		${i}
    	...		AND		Set Suite Variable 		${vendor_Name_status_dict_new}		${vendor_Name_status_dict_new}
    END

    ${physicalPort} =      Get From Dictionary    ${vendor_Name_status_dict_new}    physicalPort
    Log		${physicalPort}
    Set Suite Variable     	${physicalPort}      ${physicalPort}
    Should Not Be Empty		${physicalPort}
    ${vendor_name} =      Get From Dictionary    ${vendor_Name_status_dict_new}    vendorName
	Log		${vendor_name}
    Set Suite Variable      ${vendor_name}      ${vendor_name}
	${nokiaPN} =      Get From Dictionary    ${vendor_Name_status_dict_new}    nokiaPN
	Log		${nokiaPN}
    Set Suite Variable      ${nokiaPN}      ${nokiaPN}

	${vendor_Part_Number} =      Get From Dictionary    ${vendor_Name_status_dict_new}    vendorPartNumber
	Log		${vendor_Part_Number}
    Set Suite Variable      ${vendor_Part_Number}      ${vendor_Part_Number}
	${compliance_Code} =      Get From Dictionary    ${vendor_Name_status_dict_new}    complianceCode
    Log		${compliance_Code}
    Set Suite Variable      ${compliance_Code}      ${compliance_Code}
    Should Not Be Empty     ${compliance_Code}
	${wavelength} =      Get From Dictionary    ${vendor_Name_status_dict_new}    waveLength
	Log		${waveLength}
    Set Suite Variable      ${waveLength}      ${waveLength}
    Should Not Be Empty     ${waveLength}
	${transmissionRate} =      Get From Dictionary    ${vendor_Name_status_dict_new}    transmissionRate
	Log		${transmissionRate}
    Set Suite Variable      ${transmissionRate}      ${transmissionRate}
    Should Not Be Empty     ${transmissionRate}
	${rxPowerHighAlarmThreshold} =      Get From Dictionary    ${vendor_Name_status_dict_new}
	...     rxPowerHighAlarmThreshold
	Log		${rxPowerHighAlarmThreshold}
    Set Suite Variable      ${rxPowerHighAlarmThreshold}      ${rxPowerHighAlarmThreshold}
    Should Not Be Empty     ${rxPowerHighAlarmThreshold}
	${rxPowerHighWarnThreshold} =      Get From Dictionary    ${vendor_Name_status_dict_new}    rxPowerHighWarnThreshold
	Log		${rxPowerHighWarnThreshold}
    Set Suite Variable      ${rxPowerHighWarnThreshold}      ${rxPowerHighWarnThreshold}
    Should Not Be Empty     ${rxPowerHighWarnThreshold}
	${rxPowerLowAlarmThreshold} =      Get From Dictionary    ${vendor_Name_status_dict_new}    rxPowerLowAlarmThreshold
	Log		${rxPowerLowAlarmThreshold}
    Set Suite Variable      ${rxPowerLowAlarmThreshold}      ${rxPowerLowAlarmThreshold}
    Should Not Be Empty     ${rxPowerLowAlarmThreshold}
	${rxPowerLowWarnThreshold} =      Get From Dictionary    ${vendor_Name_status_dict_new}	rxPowerLowWarnThreshold
	Log		${rxPowerLowWarnThreshold}
    Set Suite Variable      ${rxPowerLowWarnThreshold}      ${rxPowerLowWarnThreshold}
    Should Not Be Empty     ${rxPowerLowWarnThreshold}
	${txPowerHighAlarmThreshold} =      Get From Dictionary     ${vendor_Name_status_dict_new}
    ...     txPowerHighAlarmThreshold
	Log		${txPowerHighAlarmThreshold}
    Set Suite Variable      ${txPowerHighAlarmThreshold}      ${txPowerHighAlarmThreshold}
    Should Not Be Empty     ${txPowerHighAlarmThreshold}
	${txPowerHighWarnThreshold} =      Get From Dictionary    ${vendor_Name_status_dict_new}    txPowerHighWarnThreshold
	Log		${txPowerHighWarnThreshold}
    Set Suite Variable      ${txPowerHighWarnThreshold}      ${rxPowerHighWarnThreshold}
    Should Not Be Empty     ${txPowerHighWarnThreshold}
	${txPowerLowAlarmThreshold} =      Get From Dictionary    ${vendor_Name_status_dict_new}    txPowerLowAlarmThreshold
	Log		${txPowerLowAlarmThreshold}
    Set Suite Variable      ${txPowerLowAlarmThreshold}      ${txPowerLowAlarmThreshold}
    Should Not Be Empty     ${txPowerLowAlarmThreshold}
	${txPowerLowWarnThreshold} =      Get From Dictionary    ${vendor_Name_status_dict_new}	 txPowerLowWarnThreshold
	Log		${txPowerLowWarnThreshold}
    Set Suite Variable      ${txPowerLowWarnThreshold}      ${txPowerLowWarnThreshold}
    Should Not Be Empty     ${txPowerLowWarnThreshold}
	${temperatureHighAlarmThreshold} =      Get From Dictionary    ${vendor_Name_status_dict_new}
	...     temperatureHighAlarmThreshold
	Log		${temperatureHighAlarmThreshold}
    Set Suite Variable      ${temperatureHighAlarmThreshold}      ${temperatureHighAlarmThreshold}
    Should Not Be Empty     ${temperatureHighAlarmThreshold}
	${temperatureLowAlarmThreshold} =      Get From Dictionary    ${vendor_Name_status_dict_new}
	...     temperatureLowAlarmThreshold
	Log		${temperatureLowAlarmThreshold}
    Set Suite Variable      ${temperatureLowAlarmThreshold}      ${temperatureLowAlarmThreshold}
    Should Not Be Empty     ${temperatureLowAlarmThreshold}
	${transceiverComplianceCode} =      Get From Dictionary    ${vendor_Name_status_dict_new}
	...     transceiverComplianceCode
	Log		${transceiverComplianceCode}
    Set Suite Variable      ${transceiverComplianceCode}      ${transceiverComplianceCode}
    Should Not Be Empty     ${transceiverComplianceCode}
	${dateCode} =      Get From Dictionary    ${vendor_Name_status_dict_new}	dateCode
	Log		${dateCode}
    Set Suite Variable      ${dateCode}      ${dateCode}
    Should Not Be Empty     ${dateCode}
	${diagMonType} =      Get From Dictionary    ${vendor_Name_status_dict_new}	diagMonType
	Log		${diagMonType}
    Set Suite Variable      ${diagMonType}      ${diagMonType}
    Should Not Be Empty     ${diagMonType}
	${vendorRevision} =      Get From Dictionary    ${vendor_Name_status_dict_new}    vendorRevision
	Log		${vendorRevision}
    #Should be Equal     ${vendorRevision}
	${product_Code} =      Get From Dictionary    ${vendor_Name_status_dict_new}    productCode
	Log		${product_Code}
    Set Suite Variable      ${product_Code}     ${product_Code}
	${transceiver_Compliance_Code} =      Get From Dictionary    ${vendor_Name_status_dict_new}
	...     transceiverComplianceCode
	Log		${transceiver_Compliance_Code}
	${connectorType} =      Get From Dictionary    ${vendor_Name_status_dict_new}    connectorType
    Log     ${connectorType}
    Should be Equal    ${connectorType}     LC
	${diagMonType} =      Get From Dictionary    ${vendor_Name_status_dict_new}	 diagMonType
	Log		${diagMonType}
    Set Suite Variable      ${diagMonType}      ${diagMonType}
    Should Not Be Empty     ${diagMonType}

    ${serialNumber} =      Get From Dictionary    ${vendor_Name_status_dict_new}    serialNumber
    Log     ${serialNumber}
    Should Not Be Empty         ${serialNumber}

    ${cool_transceiver} =      Get From Dictionary    ${vendor_Name_status_dict_new}    cooledTransceiverDeclaration
    Log     ${cool_transceiver}
    ${cool} =    Convert To String      ${cool_transceiver}
    ${all_dat} =       Catenate        ${vendor_name}  ${vendor_Part_Number}
    ${all_data} =     Evaluate    '${all_dat}'.replace(' ','')
    Set Suite Variable      ${all_data}     ${all_data}


Checking Tx and Rx Power
    Setup Remote Access    remote_device=bts     alias=conn26
    Execute Interactive Remote Command      command=timeout 60 /opt/trs/bin/trs-eth-d monitor >c.txt     alias=conn26
    ${output}=  Remote Command Execute  command=grep -oh "\w*OpticalRxPower.:.[0-9]*" c.txt | grep -oh "[0-9]*" -m2
    ...     alias=conn26
    @{rx_power}=    Split String    ${output}
    FOR    ${rx_power1}  IN  @{rx_power}
        ${rx_power1}=  Convert To Integer     ${rx_power1}
        Should Be True  ${rx_power1}<=200000
        Log    ${rx_power1}
    END
    ${output}=  Remote Command Execute  command=grep -oh "\w*OpticalTxPower.:.[0-9]*" c.txt | grep -oh "[0-9]*" -m2
    ...     alias=conn26
    @{tx_power}=    Split String    ${output}
    FOR    ${tx_power1}  IN  @{tx_power}
        ${tx_power1}=  Convert To Integer     ${tx_power1}
        Should Be True  ${tx_power1}<=200000
        Log    ${tx_power1}
    END
    Teardown Remote Access   alias=conn26

Checking Important Parameters
    [Arguments]     ${all_data}     ${product_Code}
    Setup Remote Access     remote_device=asim_1    alias=conn27
    Remote Command Execute  command=${sfp_details_fetch}   alias=conn27
    Remote Command Execute  command=mv /home/ute/sfp_details.txt ${CURDIR}/   alias=conn27
    Teardown Remote Access   alias=conn27
    ${contents}=    OperatingSystem.Get File    ${CURDIR}/sfp_details.txt
    Log     ${contents}
    @{list}=    Split to lines  ${contents}
    FOR  ${line}  IN  @{list}
       ${data}=     Get Variable Value     ${line}
       Log     ${data}
       ${data_1} =        Remove String    ${data}       ${SPACE}
       ${data_2} =        Strip String     ${data_1}
       ${data_3} =        Replace String   ${data_2}    \n\r    ${empty}
       ${data_4} =        Replace String Using Regexp      ${data_3}    ${SPACE}+   ${SPACE}
       ${data_mod} =     Evaluate    '${data_4}'.replace('\t','')
       Log     ${data_mod}
       ${data_last} =      Convert To String   ${data_mod}
        ${result_1} =    Run Keyword And Return Status      Should Contain  ${data_last}     ${all_data}
        ${result_2} =    Run Keyword And Return Status      Should Contain  ${data_last}     ${product_Code}
       ${new_counter} =   Evaluate       ${counter}+1
        ${counter} =   Set Variable If     ${result_1}       ${new_counter}      ${counter}
    END
    Log     ${counter}
    Should Be True  ${counter}>0

Change on other ASIM Setup
    [Arguments]     ${make_changes}
    Setup Oamops    dut=chained_bts    alias=asim2
    Run Keyword If  '${make_changes}' == 'lock'     Perform Recommissioning      type=param
    ...     param_path=ETHLK-3:administrativeState   operation=update    value=locked      alias=asim2
    Run Keyword If  '${make_changes}' == 'unlock'   Perform Recommissioning      type=param
    ...     param_path=ETHLK-3:administrativeState   operation=update    value=unlocked      alias=asim2
    Teardown Oamops     dut=chained_bts    alias=asim2

Change speed on other ASIM setup
    [Arguments]     ${make_changes}
    Setup Oamops    dut=chained_bts    alias=asim2
    Perform Recommissioning      type=param     param_path=ETHLK-3:speedAndDuplex   operation=update
    ...     value=${make_changes}      alias=asim2
    Teardown Oamops     dut=chained_bts    alias=asim2

Preconditions
    Perform Commissioning       scf_file=${Full_Configuration}   verify_bts_status=False
    ...     timeout=400     alias=default
    Sleep   100
    Perform Recommissioning     type=delta      delta_file=${delta_scf_set_ethlk2_ethlk3}
    ...     skip_parameter_relation_errors=${True}      timeout=300
    Sleep   100


Verify Alarm Name
    [Arguments]     ${output}   ${alarmname}
    ${length}=   Get Length  ${output}
    Log     ${length}
    FOR     ${i}     IN RANGE   ${length}
        ${fetch_alarm_name}=  Get From List  ${output}   ${i}
        Log    ${fetch_alarm_name}
        ${alarm_name_present}=  Run Keyword And Return Status
        ...     Dictionary Should Contain item     ${fetch_alarm_name}    alarmName    ${alarmname}
        Run Keyword If  '${alarm_name_present}' == '${True}'    Log     Alarm Present
    END
