*** Settings ***
Documentation
...              [Author]      "Meghana J"
...              [Maintenance] "TRS I & V Tools Bangalore Team"
Resource		${CURDIR}/../../resources/Admin_Common_Library.robot

*** Keywords ***
Perform BASIC Commisioning
    Perform Commissioning       scf_file=${SR001936_SCF}        verify_bts_status=False         timeout=600         alias=default
    Sleep   300

Check EIFi link is up
    ${reference_value}=    Query Admin Infomodel    query=get list //ETHLK_R-*
    Log    ${reference_value}
    FOR    ${ethlk_moc}    IN    @{reference_value}
        ${status}=    Get From Dictionary    ${ethlk_moc}    operationalState
        Should Be Equal    ${status}    enabled
    END

Checking Tx and Rx Power
    Execute command on ENodeB   timeout 60 ${tx_rx_power_cmd}
	Execute command on gNB   timeout 60 ${tx_rx_power_cmd}
    Execute command on ENodeB   grep -oh "\w*OpticalRxPower.:.[0-9]*" c.txt | grep -oh "[0-9]*" -m2
	Execute command on gNB   grep -oh "\w*OpticalRxPower.:.[0-9]*" c.txt | grep -oh "[0-9]*" -m2
    ${rx_power}=    Split String    ${stdout}
	FOR    ${rx_power1}    IN    @{rx_power}
		${rx_power1}=    Convert To Integer    ${rx_power1}
		Should Be True    ${rx_power1} <= 200000
		Log    ${rx_power1}
	END
	Execute Command On ENodeB    grep -oh "\w*OpticalTxPower.:.[0-9]*" c.txt | grep -oh "[0-9]*" -m2
	Execute Command On gNB       grep -oh "\w*OpticalTxPower.:.[0-9]*" c.txt | grep -oh "[0-9]*" -m2
	${tx_power}=    Split String    ${stdout}

	FOR    ${tx_power1}    IN    @{tx_power}
		${tx_power1}=    Convert To Integer    ${tx_power1}
		Should Be True    ${tx_power1} <= 200000
		Log    ${tx_power1}
	END

Checking Important Parameters
    ${contents}=    OperatingSystem.Get File    ${sfp_data_file}
    ${counter}=		Convert to Integer	${counter}
    Log     ${contents}
    ${list}=    Split to lines  ${contents}
	FOR  ${line}  IN  @{list}
		${data}=     Get Variable Value     ${line}
		Log     ${data}
		${data_1}=        Remove String    ${data}       ${SPACE}
		${data_2}=        Strip String     ${data_1}
		${data_3}=        Replace String   ${data_2}    \n\r    ${empty}
		${data_4}=        Replace String Using Regexp      ${data_3}    ${SPACE}+   ${SPACE}
		${data_mod}=     Evaluate    '${data_4}'.replace('\t','')
		Log     ${data_mod}
		${data_last}=      Convert To String   ${data_mod}
		${result_1}=    Run Keyword And Return Status      Should Contain  ${data_last}     ${all_data}
		${new_counter}=   Evaluate       ${counter}+1
		${counter}=   Set Variable If     ${result_1}       ${new_counter}      ${counter}
		Exit For Loop IF    ${counter} == 1
	END

Checking physical hardware
    ${smod_hardware}=    Query Admin Infomodel    query=get object //CABINET_R-1/SMOD_R-1
    ${variant}=    Get From Dictionary    ${smod_hardware}    productName
    Log    ${variant}
    Should Contain    ${variant}    ASIL

Vendor Details Advanced
    ${vendor_Name_status_dict} =     Query Admin Infomodel    query=get list //CABINET_R-1/SMOD_R-1/SFP_R-*
	FOR    ${i}    IN    @{vendor_Name_status_dict}
		${physicalPort}=    Get From Dictionary    ${i}    physicalPort
		Run Keyword If    '${physicalPort}' == '${working_port}'    Run Keywords    Set Suite Variable    ${vendor_Name_status_dict}    ${i}
		...    AND    Set Suite Variable    ${vendor_Name_status_dict}    ${vendor_Name_status_dict}
	END