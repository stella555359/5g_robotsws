*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ONAP.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ONAP.robot
Library            taf.sbts.oam.coam.admin
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py
Library           taf.transport.ssh    WITH NAME    ssh
Library           lxml    WITH NAME    xml
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py    WITH NAME    ta_xml
Library           taf.hw.pdu
Library           OperatingSystem


*** Variables ***
${TARGET_SW_NAME}    ${None}    # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}    /home/ute/btsauto/TARGET_SW/    # Directory in which TC should look for sw package. If not given,
${UPDATE_TIMEOUT}    1500    # Timeout for Download and Activation [sec]
${SW Download Timeout}    1800
${SW Activation Timeout}                          150  # Given in seconds; That is a timeout for SW download and activation
${Ping loss timeout}                              420  # Timeout for ping loss during reset
${Ping regain timeout}                            600  # Timeout for ping regain during reset
${BTS_OnAir_Timeout}                               15  # Timeout for BTS on Air (in minutes)
${Test_Timeout}                                    30  # Test timeout (in minutes)
${ONAP_server}	                        10.110.73.138
${BTS_INFO}          10.106.243.13
${HW_OFF_ID_LIST}
${NUMBER_OF_RMODS_TO_TURN_OFF}                 1
${RM_DETECTION_TIMEOUT}            20min
${Need_turn_on}      False


*** Keywords ***
TC_CB007010_ST_HWM_05_02_Generate_and_Process_Configuration_Change_Notification_via_O1
    [Documentation]    ********************
    ...    1. Basic information
    ...    ********************
    ...
    ...    **Request ID:** TAT-14706
    ...
    ...    ***********************************************************
    ...    2. Description
    ...    ***********************************************************
    ...    Main purpose of this test is to BTS allows to copy SW and configuration on the active
    ...    partition to the passive partition.
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    [Timeout]    50 minutes

    Set Tags    CA-SWM    PHASE-CRT    SW-SBTS22R2    FEATURE-CB007335

    #ONAP Simulater installation for Vespoint
   # Step 1: full commision scf to enable onap integrate
    Step 2: Select target RMOD
    #Step 3: check wanted RMOD status on ONAP notification file
    Step 4: turn off target RRU
    #Step 5: get status on onap after turn off
    Step 6: Power on RRU

Step 1: full commision scf to enable onap integrate
    [Documentation]    Short description.
    ${fingerprint}=    Get finger print
    #${vesip}=    Select correct vespoint ip
    ${fingerprint}=      Fetch From Right      ${fingerprint}    =
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning      dist_name=MRBTS-${BTS_INFO.ID}  parameter=priorityLabel
    ...  operation=update    value=1
    &{dict} =	Create Dictionary	certFingerPrint=02:${fingerprint}    mapType=specified    userName=fm-pm
    @{list} =	Create List
    Append To List	    ${list}      ${dict}
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning      dist_name=MRBTS-${BTS_INFO.ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...    parameter=certToNameMappingList
    ...  operation=update      value=@{list}
    ...  skip_parameter_relation_errors=True
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${BTS_INFO.ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-1   parameter=vesEndpointIpAddress
    ...  operation=update    value=${BTS_PC_INFO.IP}
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${BTS_INFO.ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-1   parameter=vesEndpointPortNumber
    ...  operation=update    value=30510

Step 2: Select target RMOD
    [Documentation]    Short description.
    ${interfaces_modules}  Get Turned ON RMODs
    Log  All RMODs from interface.yaml:${\n}${interfaces_modules}  console=${TRUE}
    @{hw_off_id_list}  Evaluate  random.sample(${interfaces_modules},${NUMBER_OF_RMODS_TO_TURN_OFF})  random
    Set test variable  ${hw_off_id_list}
    ${RMOD_number}=      Fetch From Right      ${hw_off_id_list[0]}    RMOD
    Set test variable  ${RMOD_number}

Get NIDD and Invanit ID from SCF
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${scf_path}: <description>
    ...        ${RMOD_num}: <description>
    ...
    ...    Returns:
    ...        ${nidd}: <description>
    ...        ${ids}: <description>
  [Arguments]  ${scf_path}  ${RMOD_num}
  ${xml_1}    OperatingSystem.Get File     ${scf_path}
  ${xml} =	Parse XML	  ${xml_1}
  ${onap_config}=    Set Test Variable      ${xml}

  ${ID} =	     Get Element    ${xml}
  ...    xpath=//p[@name='runtimeDN' and text()='MRBTS-${BTS_INFO.ID}/EQM_R-1/APEQM_R-1/RMOD_R-${RMOD_num}']/../@distName
  ${NIDD} =	    Get Element    ${xml}
  ...    xpath=//p[@name='runtimeDN' and text()='MRBTS-${BTS_INFO.ID}/EQM_R-1/APEQM_R-1/RMOD_R-${RMOD_num}']/../@version
  ${ids}=    Fetch From Right    ${ID}     -
  ${NIDD}=     Convert To Lower Case   ${NIDD}
  [Return]    ${NIDD}    ${ids}

Check HW info from notification
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${scf_path}: <description>
    ...        ${notification_info}: <description>
    ...        ${RMOD_num}: <description>
  [Arguments]  ${scf_path}     ${notification_info}    ${RMOD_num}

  ${xml_1}    OperatingSystem.Get File     ${scf_path}
  ${xml} =	Parse XML	  ${xml_1}
  ${onap_config}=    Set Test Variable      ${xml}

  ${configDN} =	     Get Element Text   ${xml}
  ...    xpath=//p[@name='runtimeDN' and text()='MRBTS-${BTS_INFO.ID}/EQM_R-1/APEQM_R-1/RMOD_R-${RMOD_num}']/../p[@name='configDN']
  ${configDN} =	Replace String    ${configDN}   /   ,
  ${configDN_right} =	Fetch from Right    ${configDN}    MRBTS-${BTS_INFO.ID}
  ${configDN_right} =	Replace String    ${configDN_right}   -   =
  ${configDN}=    Catenate   SEPARATOR=	   MRBTS-${BTS_INFO.ID}	     ${configDN_right}
  ${configDN} =	Convert To Upper Case	   ${configDN}
  ${inventoryUnitType} =	    Get Element Text    ${xml}
  ...   xpath=//p[@name='runtimeDN' and text()='MRBTS-${BTS_INFO.ID}/EQM_R-1/APEQM_R-1/RMOD_R-${RMOD_num}']/../p[@name='inventoryUnitType']
  ${serialNumber} =	     Get Element Text    ${xml}
  ...   xpath=//p[@name='runtimeDN' and text()='MRBTS-${BTS_INFO.ID}/EQM_R-1/APEQM_R-1/RMOD_R-${RMOD_num}']/../p[@name='serialNumber']
  ${vendorName} =	     Get Element Text   ${xml}
  ...  xpath=//p[@name='runtimeDN' and text()='MRBTS-${BTS_INFO.ID}/EQM_R-1/APEQM_R-1/RMOD_R-${RMOD_num}']/../p[@name='vendorName']
  ${vendorUnitFamilyType} =	     Get Element Text    ${xml}
  ...    xpath=//p[@name='runtimeDN' and text()='MRBTS-${BTS_INFO.ID}/EQM_R-1/APEQM_R-1/RMOD_R-${RMOD_num}']/../p[@name='vendorUnitFamilyType']
  ${vendorUnitTypeNumber} =	     Get Element Text    ${xml}
  ...    xpath=//p[@name='runtimeDN' and text()='MRBTS-${BTS_INFO.ID}/EQM_R-1/APEQM_R-1/RMOD_R-${RMOD_num}']/../p[@name='vendorUnitTypeNumber']
  ${versionNumber} =	     Get Element Text   ${xml}
  ...    xpath=//p[@name='runtimeDN' and text()='MRBTS-${BTS_INFO.ID}/EQM_R-1/APEQM_R-1/RMOD_R-${RMOD_num}']/../p[@name='versionNumber']

  Should Contain   	${notification_info}	     "configDN":"ManagedElement=${configDN}"	      	ignore_case=True
  Should Contain 	${notification_info}	     "inventoryUnitType":"${inventoryUnitType}"	     	ignore_case=True
  Should Contain 	${notification_info}	     "serialNumber":"${serialNumber}"	      	ignore_case=True
  Should Contain 	${notification_info}	     "vendorName":"${vendorName}"	   	ignore_case=True
  Should Contain 	${notification_info}	     "vendorUnitFamilyType":"${vendorUnitFamilyType}"	     	ignore_case=True
  Should Contain 	${notification_info}	     "vendorUnitTypeNumber":"${vendorUnitTypeNumber}"	    	ignore_case=True
  Should Contain 	${notification_info}	     "versionNumber":"${versionNumber}"    	ignore_case=True

Step 3: check wanted RMOD status on ONAP notification file
    [Documentation]    Short description.
     taf.sbts.oam.coam.admin.Collect Scf    ${CURDIR}/SCF.xml     export_type=configurationAndRuntimeObjects   timeout=600
     ${NIDD}    ${INVUNIT_ID}=    Get NIDD and Invanit ID from SCF    ${CURDIR}/SCF.xml    ${RMOD_number}

     Set Test Variable    ${NIDD}   ${NIDD}
     Set Test Variable    ${INVUNIT_ID}   ${INVUNIT_ID}
     Log To Console    ${INVUNIT_ID}

Step 4: turn off target RRU
    [Documentation]    Short description.
    Log Step Header  step4 Poweroff RRU

    ${NUMBER_OF_RMODS_TO_TURN_OFF}  Get Length	${hw_off_id_list}

    Log Important Message  List of RMODs to be turned OFF:${hw_off_id_list}${\n}How many:${NUMBER_OF_RMODS_TO_TURN_OFF} module/s
    State change if needed  ${hw_off_id_list}  Off
    ${current_date} =   Get Time
    Log  Check if turned off RMODs are disabled in ADMIN  console=${TRUE}
    sleep  30s
    Wait until keyword succeeds  ${RM_DETECTION_TIMEOUT}  20s     Check if right amount RMODs disabled
    Log  All turned off RMODs are disabled  console=${TRUE}
    #and choose rmod on randomS

Step 5: get status on onap after turn off
    [Documentation]    Short description.
    Sleep    25s
    ${cmd}=     Catenate      SEPARATOR=       tac /home/ute/ONAP_simulater/ves/log_text.text
    ...    |grep /_3gpp-common-managed-element:ManagedElement=MRBTS-${BTS_INFO.ID}/nokia-ran-bts-${NIDD}_00:HW=1
    ...     /INVUNIT=${INVUNIT_ID}/attributes|head -1

    ${output_off}=     Run Local Linux Command       ${cmd}
    Should Contain X Times	${output_off}	     "state":"faulty"	   1   	ignore_case=True
    Check HW info from notification    ${CURDIR}/SCF.xml    ${output_off}    ${RMOD_number}

Step 6: Power on RRU
    [Documentation]    Short description.
    Log Step Header    Step3 Poweron RRU
    State change if needed    ${hw_off_id_list}   On

    Log  Will now check if all radio modules are available...  console=${TRUE}
    ${status}  Run keyword and return status  Wait until keyword succeeds  ${RM_DETECTION_TIMEOUT}  20s
    ...    Check if all radio modules are available
    Run keyword if  ${status}  Log Important Message  All RMODs ON
    ...  ELSE
    ...  Set test blocked  Not all radio modules are available
    Wait RRU detected
    #${cmd}=     Catenate      SEPARATOR=       tac /home/ute/ONAP_simulater/ves/log_text.text|
    #...    grep /_3gpp-common-managed-element:ManagedElement=MRBTS-${BTS_INFO.ID}/nokia-ran-bts-${NIDD}_00:HW=1/
   # ...     INVUNIT=${INVUNIT_ID}/attributes|head -1
   # ${output_on}=    Run Local Linux Command      ${cmd}
    #Write    cat 5339_noti.txt
    #${output_on}=	 Read     delay=2s
   # Log To Console      ${output_on}
    #Write    rm 5339_noti.txt
   # Should Contain X Times	${output_on}	     "state":"working"	   1   	ignore_case=True
   # Check HW info from notification    ${CURDIR}/SCF.xml    ${output_on}    ${RMOD_number}
   # Set Test Variable   ${Need_turn_on}    False

State change if needed
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${hw_id_list}: <description>
    ...        ${pdu_target_state}: <description>
    [Arguments]  ${hw_id_list}  ${pdu_target_state}
    FOR  ${hw_id}  IN  @{hw_id_list}
      ${hw_state}  Pdu BTS Interface Get Status  ${hw_id}
      ${hw_target_state}  Set Variable  ${pdu_target_state}
      Run Keyword If  '${hw_state}'!='${hw_target_state}'  Change Pdu State And Check Status  ${hw_id}  ${hw_target_state}
      ...  ELSE  Log  ${hw_id} status already correct: ${hw_state}  console=${TRUE}
    END

Check if right amount RMODs disabled
    [Documentation]    Short description.
    ${turned_off_rmods_serial_numbers}  Create list
    FOR  ${rmods_id}  IN  @{hw_off_id_list}
        #${serial_number}  Should Match Regexp  ${rmods_id}  [A-Z0-9]{6,20}
        ${serial_number}  Should Match Regexp  ${INTERFACES['${rmods_id}']['SERIAL_NUMBER']}  [A-Z0-9]{6,20}
        Append To List  ${turned_off_rmods_serial_numbers}  ${serial_number}
    END
    ${rmods_parameters}  taf.sbts.oam.coam.admin.Get Parameters For All  RMOD
    FOR  ${module_parameters}  IN  @{rmods_parameters}
        Run keyword if  '${module_parameters['serialNumber']}'in @{turned_off_rmods_serial_numbers}
        ...  Should Match Regexp  ${module_parameters['operationalState']}     disabled
        Log  RMOD:${module_parameters['serialNumber']}${\n}operationalState:${module_parameters['operationalState']}
        ...    console=${TRUE}
    END

Change Pdu State And Check Status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${hw_id}: <description>
    ...        ${interface_state}: <description>
    [Arguments]  ${hw_id}  ${interface_state}  #state value should be: On/Off
    Log  Turn Pdu ${interface_state} And Check Status for: ${hw_id}  console=${TRUE}
    Run Keyword If  '${interface_state}'=='Off'  Pdu BTS Interface Off  ${hw_id}
    ...  ELSE IF  '${interface_state}'=='On'
    ...  Pdu BTS Interface On  ${hw_id}
    Sleep  1
    ${hw_status}  Pdu BTS Interface Get Status  ${hw_id}
    Log  hw_status after ${interface_state} operation: ${hw_status}  console=${TRUE}

Get finger print
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${fingerprint}: <description>
    ${fingerprint}=     Run Local Linux Command
    ...    cd /home/ute/ONAP_simulater/ves && openssl x509 -in ca-certificate.pem -noout -fingerprint
    [Return]    ${fingerprint}

Wait RRU detected
    [Documentation]    Short description.
    Log Step Header    Step4 Wait RRU detected
    sleep  300

Customs TearDown
    [Documentation]    Short description.
    Run Keyword If   ${Need_turn_on}==True    power_on_rru
    TC Teardown

power_on_rru
    [Documentation]    Short description.
    Log Step Header    Teadown Poweron RRU
    State change if needed    ${hw_off_id_list}   On
    Log  Will now check if all radio modules are available...  console=${TRUE}
    ${status}  Run keyword and return status  Wait until keyword succeeds  ${RM_DETECTION_TIMEOUT}  20s
    ...    Check if all radio modules are available
    Run keyword if  ${status}  Log Important Message  All RMODs ON
    ...  ELSE
    ...  Set test blocked  Not all radio modules are available
    Wait RRU detected
