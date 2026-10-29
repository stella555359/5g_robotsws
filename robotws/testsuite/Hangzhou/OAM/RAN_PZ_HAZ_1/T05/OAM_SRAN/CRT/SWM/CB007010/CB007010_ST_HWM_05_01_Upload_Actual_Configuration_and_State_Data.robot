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
Library            taf.sbts.oam.coam.admin
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py
Library           taf.transport.ssh    WITH NAME    ssh
Library           lxml    WITH NAME    xml
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py    WITH NAME    ta_xml
Library           taf.hw.pdu
Library           OperatingSystem


*** Variables ***
${TARGET_SW_NAME}    ${None}    # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}    /home/ute/btsauto/TARGET_SW/    # Directory in which TC should look for sw package. RGET
${UPDATE_TIMEOUT}    1500    # Timeout for Download and Activation [sec]
${SW Download Timeout}    1800
${SW Activation Timeout}                          150  # Given in seconds; That is a timeout for SW download a
${Ping loss timeout}                              420  # Timeout for ping loss during reset
${Ping regain timeout}                            600  # Timeout for ping regain during reset
${BTS_OnAir_Timeout}                               15  # Timeout for BTS on Air (in minutes)
${Test_Timeout}                                    30  # Test timeout (in minutes)
${ONAP_server}	                        10.110.73.138
${BTS_INFO}          10.106.243.13
${HW_OFF_ID_LIST}
${NUMBER_OF_RMODS_TO_TURN_OFF}                 1
${RM_DETECTION_TIMEOUT}            20min
#02:D1:EA:04:F5:A1:04:CE:D7:E8:43:55:FD:E4:AB:07:5A:41:5B:6E:2D


*** Keywords ***
TC_CB007010_ST_HWM_05_01_Upload Actual Configuration and State Data
    [Documentation]    ********************
    ...    1. Basic information
    ...    ********************
    ...
    ...    **Request ID:** TAT-14706
    ...
    ...    ***********************************************************
    ...    2. Description
    ...    ***********************************************************
    ...    Main purpose of this test is to BTS allows to copy SW and configuration
    ...    on the active partition to the passive partition.
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    [Timeout]    50 minutes
    Set Tags    CA-SWM    PHASE-CRT    SW-SBTS22R2    FEATURE-CB007335
    #ONAP Simulater installation for NetConf
    #Step 1: full commision scf to enable onap integrate
    #Step 2: migrate bts to O1 and get status
    #Step 3: check output length is same as real
    Step 4: select lucky RRU and power off
   # Step 5: get status on onap after turn off
    Step 6: Power on RRU
    #Step 6: check status on BTS

Step 1: full commision scf to enable onap integrate
    [Documentation]    Short description.
    ${fingerprint}=    Get finger print
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

Step 2: migrate bts to O1 and get status
    [Documentation]    Short description.
      ${str_cmd}=     Catenate
      ...    bash -c "echo -e 'connect --tls --host IPSEC --key /home/ute/ONAP_simulater/ves/ca-key.pem
      ...    --cert /home/ute/ONAP_simulater/ves/ee_cert.pem --trusted /home/ute/ONAP_simulater/ves/ca-certificate.pem \n
      ...    get --filter-xpath ManagedElement//HW --out /tmp/5339.xml' | netopeer2-cli"
      ${stdout2}=    Run Local Linux Command      ${str_cmd}
      Log To Console      ${stdout2}

Step 3: check output length is same as real
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Collect Scf    ${CURDIR}/../../../scf.xml    export_type=configurationAndRuntimeObjects   timeout=600
    ${xml_1}    OperatingSystem.Get File     ${CURDIR}/../../../scf.xml
    ${xml_2}    OperatingSystem.Get File     /tmp/5339.xml

    ${xml} =	Parse XML	  ${xml_1}
    ${onap_config}=    Set Test Variable      ${xml}
    ${xml_scf} =	Parse XML	${xml_2}
    ${bts_config}=    Set Test Variable      ${xml_scf}
    ${element} =	Get Element Count      ${xml}	   xpath=//INVUNIT
    ${element_scf} =	Get Element Count      ${xml_scf}
    ...    xpath=//*[contains(@distName,'MRBTS-5339/HW-1/INVUNIT') and @class='com.nokia.eqm.hw:INVUNIT']
    Should Be Equal As Integers      ${element}    ${element_scf}

    Set Test Variable      ${xml_1}     ${xml_1}
    Set Test Variable      ${xml_2}    ${xml_2}
    FOR    ${index}    IN RANGE    1    ${element}
        ${HWlist_xpath_1}    set Variable
        ...    *|//*[@distName='MRBTS-5339/HW-1/INVUNIT-${index}'and @class='com.nokia.eqm.hw:INVUNIT']
        ${HWlist_xpath_2}    set Variable       *|//HW/INVUNIT[id=${index}]/attributes

        ${HWlist}=    ta_xml.read_xml   ${xml_2}   ${HWlist_xpath_2}

        set suite variable    ${HWlist}
        ${HWIN}    Change XMLOBJECT to DIC    ${HWlist}
        ${HWlist_ADMIN}=     ta_xml.read_xml     ${xml_1}   ${HWlist_xpath_1}
        ${HWIN_ADMIN}    Change XMLOBJECT to DIC    ${HWlist_ADMIN}
        #dictionaries should be equal    ${HWIN_ADMIN}    ${HWIN}
        dictionary should contain sub dictionary        ${HWIN_ADMIN}    ${HWIN}
        #douhao,,,kongge
    END

Step 6: Power on RRU
    [Documentation]    Short description.
    Log Step Header    Step3 Poweron RRU
    State change if needed    ${hw_off_id_list}   On
    Log  Will now check if all radio modules are available...  console=${TRUE}
    ${status}  Run keyword and return status  Wait until keyword succeeds  ${RM_DETECTION_TIMEOUT}
    ...     20s  Check if all radio modules are available
    Run keyword if  ${status}  Log Important Message  All RMODs ON
    ...  ELSE
    ...  Set test blocked  Not all radio modules are available
    Wait RRU detected

Step 4: select lucky RRU and power off
    [Documentation]    Short description.
    Log Step Header  step3 Poweroff RRU
    ${hw_off_id_list}  Split String  ${HW_OFF_ID_LIST}  ,
    Run Keyword If  '${hw_off_id_list[0]}'==''  Choose RMOD on random
    ${NUMBER_OF_RMODS_TO_TURN_OFF}  Get Length	${hw_off_id_list}
    Log Important Message
    ...    List of RMODs to be turned OFF:${hw_off_id_list}${\n}How many:${NUMBER_OF_RMODS_TO_TURN_OFF} module/s
    State change if needed  ${hw_off_id_list}  Off
    Log  Check if turned off RMODs are disabled in ADMIN  console=${TRUE}
    sleep  30s
    Wait until keyword succeeds  ${RM_DETECTION_TIMEOUT}  20s     Check if right amount RMODs disabled
    Log  All turned off RMODs are disabled  console=${TRUE}
    #and choose rmod on random
    set test variable    ${hw_off_id_list}

Step 5: get status on onap after turn off
    [Documentation]    Short description.
     ${cmd} =     Catenate
     ...    bash -c "echo -e 'connect --tls --host IPSEC --key /home/ute/ONAP_simulater/ves/ca-key.pem
     ...    --cert /home/ute/ONAP_simulater/ves/ee_cert.pem --trusted /home/ute/ONAP_simulater/ves/ca-certificate.pem \n
     ...    get --filter-xpath ManagedElement//HW --out /tmp/5339_off.xml' | netopeer2-cli"
     ${stdout3}=    Run Local Linux Command     ${cmd}
     Log To Console      ${stdout3}
     Check Diffrence Between Files

get current HW-1 status from ONAP
    [Documentation]    Short description.
     ${cmd} =     Catenate
     ...    bash -c "echo -e 'connect --tls --host IPSEC --key /home/ute/ONAP_simulater/ves/ca-key.pem
     ...    --cert /home/ute/ONAP_simulater/ves/ee_cert.pem --trusted /home/ute/ONAP_simulater/ves/ca-certificate.pem \n
     ...    get --filter-xpath ManagedElement//HW --out /tmp/5339_off.xml' | netopeer2-cli"
    Run Local Linux Command        ${cmd}

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

Choose RMOD on random
    [Documentation]    Short description.
    ${interfaces_modules}  Get Turned ON RMODs
    Log  All RMODs from interface.yaml:${\n}${interfaces_modules}  console=${TRUE}
    @{hw_off_id_list}  Evaluate  random.sample(${interfaces_modules},${NUMBER_OF_RMODS_TO_TURN_OFF})  random
    Set test variable  ${hw_off_id_list}

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
        Log  RMOD:${module_parameters['serialNumber']}${\n}operationalState:${module_parameters['operationalState']}  console=${TRUE}
    END

Check Diffrence Between Files
    [Documentation]    Short description.
    ${output}=     OperatingSystem.Run   diff /tmp/5339_off.xml /tmp/5339.xml |grep state
    Log To Console     ${output}
    ${number}=     Get Line Count    ${output}
    @{new_string}    Get Regexp Matches   ${output}     <state>(.*?)</state>
    #Log To Console     @{new_string}
    Should Be Equal    ${new_string[0]}    <state>faulty</state>
    Should Be Equal    ${new_string[1]}    <state>working</state>
    Should Be Equal As Numbers    ${number}    2

Change XMLOBJECT to DIC
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${MO}: <description>
    ...
    ...    Returns:
    ...        ${INVUNIT}: <description>
    [Arguments]    ${MO}
    ${linenum}    get line count    ${MO}
    ${INVUNIT}    create dictionary    test    1
    FOR   ${index}   IN RANGE   1    ${linenum}
        ${line}    get line    ${MO}     ${index}
        Log to Console   ${line}
        ${name}    get regexp matches     ${line}    "(.*?)"
        ${text}    get regexp matches     ${line}    >(.*?)<
        set to dictionary   ${INVUNIT}    '${name}'=${text}
        ${index}     evaluate      ${index}+1
    END
    [Return]     ${INVUNIT}

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

check info
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    ...        @{list}: <description>
    ...
    ...    Returns:
    ...        ${Bool}: <description>
    [Arguments]     ${index}    @{list}
    ${DN}=    Set Variable         MRBTS-5339

    FOR    ${item}    IN     @{list}
        ${element_versionNumber} =	Run Keyword And Ignore Error    Get Element Text      ${xml}
        ...    xpath=ManagedElement/HW/INVUNIT[id=${index}]//${item}
        Log To Console    ${element_versionNumber}
        Continue For Loop If   '${element_versionNumber}[1]' ==''
        ${element_scf_versionNumber} =	Run Keyword And Ignore Error     Get Element Text      ${xml_scf}
        ...    xpath=text|//*[@distName='${DN}/HW-1/INVUNIT-${index}' and @class='com.nokia.eqm.hw:INVUNIT']//p[@name='${item}']
        Log To Console    ${element_scf_versionNumber}
        ${BOol} =   Set Variable If   '${element_scf_versionNumber}[1]'not in '${element_versionNumber}[1]'   False
    END
    [Return]    ${Bool}
    ${RRU_name} =	Get Element Text      ${xml}	   xpath=//HW/INVUNIT[${element}]/attributes/inventoryUnitType
    Set Test Variable     ${target_RRU}     ${RRU_name}
