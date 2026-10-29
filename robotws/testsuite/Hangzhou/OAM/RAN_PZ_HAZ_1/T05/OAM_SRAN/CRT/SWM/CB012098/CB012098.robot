*** Settings ***
Documentation     [PURPOSE]
Resource    ../../SWM/SWM__SW_download_and_activation__SBTS_to_SBTS.robot

*** Keywords ***
CB012098 setup
    [Documentation]    Short description.
    TC Setup
    no validation error in active configuration
    SW update to Base Build
    Update actValidationOnUpgrade

CB012098 teardown
    [Documentation]    Short description.
    Disable actRemoteSyslogTransmission
    Recover Site by Site Reset In Case Of Fault 30 Is Active
    Common Test Teardown

Execute SW activation from webem failed when pdl ERR detected
    [Documentation]    Short description.
    Inject PDL validation Error To Active Configuration
    SW update And Expect Error    ${SW_path_package}
    Fault 30 Verification

Execute SW activation with admin CLI command failed when pdl ERR detected
    [Documentation]    Short description.
    Inject PDL validation Error To Active Configuration
    SW update And Expect Error    ${SW_path_package}
    Fault 30 Verification

Execute SW activation from MantaRay failed when pdl ERR detected
    [Documentation]    Short description.
    Inject PDL validation Error To Active Configuration
    ${ver}=    Get Actual Version From Pkg    ${SW_path_package}
    Integrate MRBTS to NMS
    CB007500_Import_SW_to_NetAct    ${ver}
    Start IP Traffic Capturing
    ${status}=    SW Update From NMS    ${ver}
    Should Be True    '${status}'=='FAILED'
    ${log_file}=    Stop IP Traffic Capturing
    Fault 30 Verification
    NE3S Feedback Verificaiton in Wireshark Log    ${log_file}

Disable feature flag SWM Provision succeed with and without PDL err
    [Documentation]    Short description.
    Update actValidationOnUpgrade    false
    SW update With Pkg Path    ${SW_path_T1_package}
    Update actValidationOnUpgrade    false
    Inject PDL validation Error To Active Configuration
    SW update With Pkg Path    ${SW_path_package}

SW activation for both DU and RU failed on MantaRay when PDL ERR detected
    [Documentation]    Short description.
    Inject PDL validation Error To Active Configuration
    ${ver}=    Get Actual Version From Pkg    ${SW_path_package}
    CB007500_Import_SW_to_NetAct    ${ver}
    Integrate MRBTS to NMS
    Download SW without Activation    ${SW_path_package}
    Start IP Traffic Capturing
    ${status}=    SW Update From NMS    ${ver}    activation
    Should Be True    '${status}'=='FAILED'
    ${log_file}=    Stop IP Traffic Capturing
    Fault 30 Verification
    NE3S Feedback Verificaiton in Wireshark Log    ${log_file}

SW activation for DU only failed on MantaRay when PDL ERR detected
    [Documentation]    Short description.
    Inject PDL validation Error To Active Configuration
    ${ver}=    Get Actual Version From Pkg    ${SW_path_package}
    CB007500_Import_SW_to_NetAct    ${ver}
    Integrate MRBTS to NMS
    Update SW with RU only    ${SW_path_package}
    Download SW without Activation    ${SW_path_package}
    Start IP Traffic Capturing
    ${status}=    SW Update From NMS    ${ver}    activation
    Should Be True    '${status}'=='FAILED'
    ${log_file}=    Stop IP Traffic Capturing
    Fault 30 Verification
    NE3S Feedback Verificaiton in Wireshark Log    ${log_file}

SW activation failed on MantaRay while PDL APP execution failure
    [Documentation]    Short description.
    ${ver}=    Get Actual Version From Pkg    ${SW_path_package}
    CB007500_Import_SW_to_NetAct    ${ver}
    Integrate MRBTS to NMS
    Make Condition For PDL APP Execution Failure
    Download SW without Activation    ${SW_path_package}
    Start IP Traffic Capturing
    ${status}=    SW Update From NMS    ${ver}    activation
    Should Be True    '${status}'=='FAILED'
    ${log_file}=    Stop IP Traffic Capturing
    Fault 30 Verification
    ...     suppl_alarm_Info=SW activation interrupted because BTS cannot execute configuration data validation
    NE3S Feedback Verificaiton in Wireshark Log    ${log_file}
    ...    error_msg=SW activation interrupted because BTS cannot execute configuration data validation

Make Condition For PDL APP Execution Failure
    [documentation]    The user created directory /rom/uri/pdlapp will lead to extract pdl app failed.
    ...    Please double confirm with R&D team if "fault 30 - PDL APP Execution Failure " was not triggered
    Log To console    "Please double confirm with R&D team if "fault 30 - PDL APP Execution Failure " was not triggered"
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh -o StrictHostKeyChecking=no toor4nsn@192.168.255.129
    ...    'mkdir /rom/uri/pdlapp; ls -d /rom/uri/pdlapp' 2> /dev/null
    ${output}=    Run    ${cmd}
    Should Be Equal    ${output}    /rom/uri/pdlapp

Update SW with RU only
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${pkg}: <description>
    [arguments]    ${pkg}
    taf.sbts.oam.coam.admin.update_software    sw_package=${pkg}    independent_sw_update_type=RuSwOnly
    Sleep    2 min
    wait until keyword succeeds    15min    10s    Verify states

Download SW without Activation
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${pkg}: <description>
    [arguments]    ${pkg}
    taf.sbts.oam.coam.admin.wait_sw_update_possible
    taf.sbts.oam.coam.admin.update_software    sw_package=${pkg}    should_activate=${FALSE}

Recover Site by Site Reset In Case Of Fault 30 Is Active
    [Documentation]    Short description.
    ${faults}=    taf.sbts.oam.coam.admin.get_active_alarms
    FOR    ${fault}    IN    @{faults}
        Log Dictionary    ${fault}
        Continue For Loop If    '${fault}[faultId]'!='30'
        taf.sbts.oam.coam.admin.reset_site
        variable_update_define
        wait until keyword succeeds    15min    5s    Check if any cell is onAir
        Return From Keyword
    END

No Validation Error in Active Configuration
    [Documentation]    Short description.
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${scf_file_name}=    Set Variable    SCF_${BTS_INFO.MRBTS}_${timestamp}.xml
    ${scf_file}=    Set Variable    ${TEMP_LOGS_DIR}/${scf_file_name}
    taf.sbts.oam.coam.admin.get_current_scf_file    ${TEMP_LOGS_DIR}    ${scf_file_name}
    taf.sbts.oam.coam.admin.validate_scf_online    ${scf_file}

Inject PDL validation Error To Active Configuration
    [Documentation]    Short description.
    Enable actRemoteSyslogTransmission And Delete remoteSyslogConfig
    ${status}=    Run keyword And Return Status    No Validation Error in Active Configuration
    Should Be True    ${status}==${FALSE}

Inject PDL Warning To Active Configuration
    [documentation]    PDL warning list reference:
    ...    https://nokia.sharepoint.com/sites/InformationModellingSquad/Shared%20Documents/PDL/PDL_warning.xlsx?web=1
    ...    In the keyword we try to use LNBTS::maxNumAnrMoiAllowed and MNL/TCEDAM/TCE::tceIpAddress to inject
    ...    PDL warnning in active configuration.
    ...    But it may fail in race condition: No LNBTS and no NRBTS, etc.
    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects     LNBTS_A
    ${lte_configured}=    Run Keyword And Return Status    Should Not Be Empty    ${objs}
    Run keyword If    ${lte_configured}    Trigger PDL Warning with LNBTS
    Return From Keyword If    ${lte_configured}

    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects     NRBTS_A
    ${nr_configured}=    Run Keyword And Return Status    Should Not Be Empty    ${objs}
    Run keyword If    ${nr_configured}    Trigger PDL Warning with NRBTS
    Return From Keyword If    ${nr_configured}

    Fail    Unable to inject pdl warning

Trigger PDL Warning with LNBTS
    [Documentation]    Short description.
    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects     LNBTS_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/LNBTS_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dn}   maxNumAnrMoiAllowed   update  0
    ...    skip_parameter_relation_errors=${TRUE}
    ${validation_result}=    Run Keyword And Return Status    No Validation Error in Active Configuration
    Run Keyword If    ${validation_result}==${FALSE}    Return From Keyword
    Add LNADJGNB
    ${validation_result}=    Run Keyword And Return Status    No Validation Error in Active Configuration
    Should Be True    ${validation_result}==${FALSE}

Add LNADJGNB
    [Documentation]    Short description.
    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects     LNBTS_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/LNBTS_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    ${lnadjgnb}=    Create Dictionary    adjGnbId=1    adjGnbIdLength=22    administrativeState=locked
    ...    cPlaneIpAddr=    cPlaneIpAddrCtrl=oamControlled
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    ${dn}/LNADJGNB-1    parameter=${lnadjgnb}    operation=create    skip_parameter_relation_errors=${TRUE}
    ${validation_result}=    Run Keyword And Return Status    No Validation Error in Active Configuration
    Should Be True    ${validation_result}

Mplane IP Address Verification
    [Documentation]    Short description.
    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects     MPLANE_L
    ${mplane_ipv4_address}=    Set Test Variable    ${objs}[parameters][ipv4Addr]
    ${mplane_ipv6_address}=    Set Test Variable    ${objs}[parameters][ipv6Addr]
    ${mplane_not_dualstack}=    Run Keyword And Return Status
    ...    Should Be True    '${mplane_ipv4_address}'=='' or '${mplane_ipv6_address}'==''
    Run Keyword If    ${mplane_not_dualstack}==${FALSE}    Fail    Unable to inject pdl warning

Trigger PDL Warning with NRBTS
    [Documentation]    Short description.
    Mplane IP Address Verification
    Add TCEADM
    ${tce_id}    ${tce_identifier}=    Generate TCE ID And Identifier
    Add TCE    ${tce_id}    ${tce_identifier}
    ${validation_result}=    Run Keyword And Return Status    No Validation Error in Active Configuration
    Should Be True    ${validation_result}==${FALSE}

Add TCEADM
    [Documentation]    Short description.
    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects     TCEADM_A
    ${tceadm_configured}=    Run Keyword And Return Status    Should Not Be Empty    ${objs}
    Return From Keyword If    ${tceadm_configured}
    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects     MNL_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/MNL_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    ${tceadm}=    Create Dictionary    tceAdminId=1
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    ${dn}/TCEADM-1    parameter=${tceadm}    operation=create    skip_parameter_relation_errors=${TRUE}

Add TCE
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tce_id}: <description>
    ...        ${tce_identifier}: <description>
    [arguments]    ${tce_id}    ${tce_identifier}
    ${tce_ip}=    Set Variable If    '${mplane_ipv4_address}'==''    10.10.10.10
    ...    '${mplane_ipv6_address}'==''    2a00::1
    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects     TCEADM_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/MNL_A-(\\d+)/TCEADM_A-(\\d+)
    ${tce}=    Create Dictionary    certTypeForTlsAuth=RSA    tceIdentifier=${tce_identifier}    tceIpAddress=${tce_ip}
    ...    tcePortNumber=49151    tlsEnabled=false
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...    ${dn}/TCE-${tce_id}    parameter=${tce}    operation=create    skip_parameter_relation_errors=${TRUE}

Generate TCE ID And Identifier
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${tce_id}: <description>
    ...        ${tce_identifier}: <description>
    ${tce_id}=    Set Varibale    1
    ${tce_identifier}=    Set Varibale    1
    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects     TCE_A
    ${tce_count}=    Get Length    ${objs}
    Return From Keyword If    '${tce_count}'=='0'
    ${tce_id}    ${tce_identifier}=    Run Keyrod If    '${tce_count}'=='10'    Remove Unused TCE
    ${tce_id}    ${tce_identifier}=    Generate Unused TCE ID And Identifier
    [return]    ${tce_id}    ${tce_identifier}

Generate Unused TCE ID And Identifier
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${tce_id}: <description>
    ...        ${tce_identifier}: <description>
    ${tce_id_list}    ${tce_identifier_list}=    Get List of TCE ID and Identifier
    ${tce_id}=    Generate Unused TCE ID    ${tce_id_list}
    ${tce_identifier}=    Generate Unused TCE Identifier    ${tce_identifier_list}
    [return]    ${tce_id}    ${tce_identifier}

Generate Unused TCE ID
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tce_id_list}: <description>
    ...
    ...    Returns:
    ...        ${tce_id}: <description>
    [arguments]    ${tce_id_list}
    ${tce_id}=    set variable    ${EMPTY}
    FOR    ${id}    IN    RANGE    1    10
        ${status}=    Run Keyword and Return Status    Should Contain    ${tce_id_list}    ${id}
        ${tce_id}=    Set Variable If    ${status}==${FALSE}    ${id}    ${EMPTY}
        Exit For Loop If    ${status}==${FALSE}
    END
    Should Not Be True    '${tce_id}'=='${EMPTY}'
    [return]    ${tce_id}

Generate Unused TCE Identifier
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tce_identifier_list}: <description>
    ...
    ...    Returns:
    ...        ${tce_identifier}: <description>
    [arguments]    ${tce_identifier_list}
    ${tce_identifier}=    set variable    ${EMPTY}
    FOR    ${id}    IN    RANGE    0    255
        ${status}=    Run Keyword and Return Status    Should Contain    ${tce_identifier_list}    ${id}
        ${tce_id}=    Set Variable If    ${status}==${FALSE}    ${id}    ${EMPTY}
        Exit For Loop If    ${status}==${FALSE}
    END
    Should Not Be True    '${tce_identifier}'=='${EMPTY}'
    [return]    ${tce_identifier}

Get List of TCE ID and Identifier
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${tce_id_list}: <description>
    ...        ${tce_identifier_list}: <description>
    ${tce_id_list}=    Create List
    ${tce_identifier_list}=    Create List
    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects     TCE_A
    FOR    ${obj}    IN    @{objs}
        ${dist_name}=     Set Variable            ${obj}[distName]
        ${match}=    Get Regexp Matches    ${dist_name}   TCE_A-(\\d+)
        Append To List    ${tce_id_list}    ${match}[0]
        Append To List    ${tce_identifier_list}    ${obj}[parameters][tceIdentifier]
    END
    [return]    ${tce_id_list}    ${tce_identifier_list}

Remove Unused TCE
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${tce_id}: <description>
    ...        ${tce_identifier}: <description>
    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects     TCE_A
    ${tce_id}=    Set Variable    ${EMPTY}
    ${tce_identifier}=    Set Varibale    ${EMPTY}
    FOR    ${obj}    IN    @{objs}
        ${dist_name}=     Set Variable            ${obj}[distName]
        ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/MNL_A-(\\d+)/TCEADM_A-(\\d+)/TCE_A-(\\d+)
        Log     ${match}
        ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
        ${result}=    Run Keyword And Return Status    taf.sbts.oam.coam.admin.perform_object_recommissioning
        ...    ${dn}    parameter=${EMPTY}    operation=delete
        ${tce_id}=    Set Variable    ${match}[0][3]
        ${tce_identifier}=    Set Varibale    ${obj}[tceIdentifier]
        Exit For Loop If    ${result}==${TRUE}
    END
    Run Keyword If    '${tce_id}'=='${EMPTY}'    Fail    Unable to remove any TCE
    [return]    ${tce_id}    ${tce_identifier}

Enable actRemoteSyslogTransmission And Delete remoteSyslogConfig
    [documentation]    The keyword is used to trigger PDL validation by
    ...    - Enbale actRemoteSyslogTransmission and delete remoteSyslogConfig
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     TRBLCADM_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/MNL_A-(\\d+)/MNLENT_A-(\\d+)/TRBLCADM_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dn}   actRemoteSyslogTransmission   update  true
    ...    skip_parameter_relation_errors=${TRUE}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dn}   remoteSyslogConfig   delete  ${EMPTY}
    ...    skip_parameter_relation_errors=${TRUE}

Disable actRemoteSyslogTransmission
    [Documentation]    Short description.
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     TRBLCADM_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/MNL_A-(\\d+)/MNLENT_A-(\\d+)/TRBLCADM_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dn}   actRemoteSyslogTransmission   update  false

Update actValidationOnUpgrade
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${value}: <description>
    [arguments]    ${value}=true
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     FEATCADM_A
#    Return From Keyword If    ${objs}[0][parameters][actValidationOnUpgrade]==${TRUE}
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/MNL_A-(\\d+)/MNLENT_A-(\\d+)/FEATCADM_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dn}   actValidationOnUpgrade   update  ${value}

Fault 30 Verification
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${suppl_alarm_Info}: <description>
    [arguments]    ${suppl_alarm_Info}=PDL validation error
    ${fault_30}=    wait until keyword succeeds    5min    5s    Fault 30 is Active
    Should Be True    '${fault_30}[supplAlarmInfo]'=='${suppl_alarm_Info}'
    Should Be True    '${fault_30}[severity]'=='Minor'
    Should Be True    '${fault_30}[faultName]'=='BTS SW download or activation failed'

Fault 30 is Active
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${fault_30}: <description>
    ${fault_30}=    Create Dictionary
    ${faults}=    taf.sbts.oam.coam.admin.get_active_alarms
    FOR    ${fault}    IN    @{faults}
        Log Dictionary    ${fault}
        ${fault_30}=    Set Variable If    '${fault}[faultId]'=='30'    ${fault}
    END
    Should Be True    '${fault_30}[faultId]'=='30'
    [return]    ${fault_30}

SW update to Base Build
    [Documentation]    Short description.
    SW update With Pkg Path    ${SW_path_T2_package}
    ${matchs}=    Get Regexp Matches    ${SW_path_T2_package}    (SBTS[\\w\\d]+_ENB_\\d+_\\d+_\\d+)    1
    ${active_build}=    Set Variable    ${matchs}[0]
    Set Test Variable    ${ENB_Trunk_Version}    ${active_build}

SW update And Expect Error
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${pkg}: <description>
    [arguments]    ${pkg}
    ${actual_target_version}=    get actual version from pkg    ${pkg}
    ${sw_info}=    taf.sbts.oam.coam.admin.get_software_info
    Run Keyword If    '${actual_target_version}'=='${sw_info}[Active SW version]'
    ...    Fail    tagret version is same as active one.
    ${msg}=    Run Keyword And Expect Error
    ...    *    taf.sbts.oam.coam.admin.update_software    ${pkg}    timeout=3600
    Log    ${msg}
    Should Contain    ${msg}   PDL validation error

SW update With Pkg Path
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${pkg}: <description>
    [arguments]    ${pkg}
    ${actual_target_version}=    get actual version from pkg    ${pkg}
    ${sw_info}=    taf.sbts.oam.coam.admin.get_software_info
    Return From Keyword If    '${actual_target_version}'=='${sw_info}[Active SW version]'
    Run keyword If    '${actual_target_version}'=='${sw_info}[Passive SW version]'
    ...    taf.sbts.oam.coam.admin.passive_synchronize    timeout=900
    ${SW_path_package_tmp}=    Set Variable    ${SW_path_package}
    ${path}=    Remove String Using Regexp    ${pkg}    SBTS.+
    Set Suite Variable    ${SW_path_package}    ${pkg}
    Set Test Variable    ${Target SW dir}    ${path}
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    Run keyword and return status  taf.sbts.oam.coam.admin.Reset admin
    Set Suite Variable    ${SW_path_package}    ${SW_path_package_tmp}

Get Actual Version From Pkg
    [Documentation]    Extract TargetBD file in pkg, and get swReleaseVersionName
    [arguments]    ${pkg}
    ${output}=    Run    unzip -p ${pkg} */TargetBD*
    ${version}=    Get Regexp Matches    ${output}    swReleaseVersionName="([0-9A-Z_]+)    1
    [return]    ${version}[0]

SW Update From NMS
    [Documentation]    ${SW_build} shoule NOT be start with SBTS00
    ...    ${operation}: provision, download, activation, upload, etc.
    [arguments]    ${SW_build}    ${operation}=provision
    Precondition Netact with TAF
    ${operation_id}=    taf.nms.netact.Start SWM Operation    operation_type=provision
    ...    dist_names=PLMN-PLMN/${BTS_INFO.MRBTS}    package=${SW_build}
    ${progress}=    taf.nms.netact.Get Progress Of SWM Operation    ${operation_id}
    Log    ${progress}
    taf.nms.netact.Wait For SWM Operation    ${operation_id}    timeout=1800
    ${progress}=    taf.nms.netact.Get Progress Of SWM Operation    ${operation_id}
    Log    ${progress}
    taf.nms.netact.Upload SW    PLMN-PLMN/${BTS_INFO.MRBTS}
    ${status}=    taf.nms.netact.Get Mo Status    PLMN-PLMN/${BTS_INFO.MRBTS}
    set test variable  ${status}
    Log    ${status}
    [Teardown]    Run keyword and ignore error    Postcondition Netact with TAF
    [return]    ${progress}[Status]

Start IP Traffic Capturing
    [Documentation]    Short description.
    Run Keyword And Ignore Error    taf.sbts.oam.coam.admin.Stop IP Capture File
    taf.sbts.oam.coam.admin.Start IP Capture File    measurement_point=NE_Terminated
    ...     uplane_capturing=${FALSE}    password=${EMPTY}

Stop IP Traffic Capturing
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${log_file}: <description>
    taf.sbts.oam.coam.admin.Stop IP Capture File
    taf.sbts.oam.coam.admin.Generate IP Capture File
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${target_file_name}=    Set Variable    IP_Traffic_${BTS_INFO.MRBTS}_${timestamp}.pcap.gz
    ${log_file}=    Set Variable    ${TEMP_LOGS_DIR}/${target_file_name}
    taf.sbts.oam.coam.admin.Download IP Capture File    target_file_name=${log_file}
    [RETURN]    ${log_file}

NE3S Feedback Verificaiton in Wireshark Log
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${log_file}: <description>
    ...        ${error_msg}: <description>
    [arguments]    ${log_file}    ${error_msg}=PDL validation error
    ${output}=    Run    tshark -r "${log_file}" -Y 'xml.attribute == "name=\\"textualResponse\\""' -T pdml
    Log    ${output}
    Should Contain    ${output}    ${error_msg}

Integrate MRBTS to NMS
    [Documentation]    Short description.
    ${objs}=    taf.sbts.oam.coam.admin.Get Managed Objects     MPLANE_L
    ${mplane_ip}=    Set Variable If    '${objs}[0][parameters][ipv4Addr]'=='None'
    ...    ${objs}[0][parameters][ipv6Addr]    ${objs}[0][parameters][ipv4Addr]
    Set To Dictionary    ${BTS_INFO}    IP=${mplane_ip}
    register MRBTS to NetAct
