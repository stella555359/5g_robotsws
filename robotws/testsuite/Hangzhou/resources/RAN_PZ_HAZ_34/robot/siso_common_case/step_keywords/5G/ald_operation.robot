*** Settings ***
Documentation    This is common keywords for siso ALD related cases
...              Please do not modify the file without notification to author
...              Author: zhihao.shi
...              Contact: zhihao.shi@nokia-sbell.com
...              Squard: HZ SG4

Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Keywords ***
SISO ALD Test Setup
    Log to console    \n***SISO ALD Test Setup***
    Connect to gnb coam via ssl
    ${scf_file_backup}    COAM Download scf from cluster  scf_dir_path=${SAVE LOG DIRECTORY}
    Set Test Variable    ${scf_file_backup}
    ${scf_file_delete}    Delete ALD Infomation If Exist    ${scf_file_backup}
    ${scf_file_add}    Add ALD information to scf    ${scf_file_delete}
    COAM Commission with scf file    scf_file_path=${scf_file_add}    is_pdl_checking_needed=${if_pdl_check}
    ${status}    run keyword and return status    Wait until ALD AND RAEU status normal    timeout=10 min
    ...    download_dir=${SAVE LOG DIRECTORY}
    Wait until cluster is on cell on air status

SISO ALD ENV Recover
    Log to console    \n***SISO ALD ENV Recover***
    COAM Commission with scf file    scf_file_path=${scf_file_backup}    is_pdl_checking_needed=${if_pdl_check}
    Wait until cluster is on cell on air status

ALD Details Info Check
    Log to console    \n***ALD Details Info Check***
    ${ald_info} =    Get ALD RAEU Information via webUI    download_dir=${SAVE LOG DIRECTORY}
    Run keyword and continue on failure    Should be equal
    ...    ${ald_info["Product code"]}    ${DICT_ALD_INFO}[PRODUCT_CODE]     msg=There is error Product code for ALD
    Run keyword and continue on failure    Should be equal
    ...    ${ald_info["Serial number"]}    ${DICT_ALD_INFO}[SERIAL_NUMBER]     msg=There is error Serial number for ALD
    Run keyword and continue on failure    Should be equal
    ...    ${ald_info["Vendor code"]}     ${DICT_ALD_INFO}[VENDOR_CODE]    msg=There is error Vendor code for ALD
    Run keyword and continue on failure    Should be equal
    ...    ${ald_info["HW version"]}    ${DICT_ALD_INFO}[HW_VERSION]    msg=There is error HW version for ALD
    Run keyword and continue on failure    Should be equal
    ...    ${ald_info["SW version"]}    ${DICT_ALD_INFO}[SW_VERSION]    msg=There is error SW version for ALD

Repeat ${count} Times Enable And Disable DC Voltgae For RET Port ${ald_type}
    FOR    ${index}    IN  RANGE    1    ${count}
        Change DC Voltgae For RET Port    value=false
        run keyword if   '${ald_type}'=='RETU'    set test variable    ${avai_status}    Notinstalled
        ...    ELSE    set test variable    ${availability_status}    PowerOff
        Wait Until Keyword Succeeds   5min  5 sec    Check ALD RAEU Status    administrative_state=Unlocked    availability_status=${avai_status}
        ...    operational_state=Disabled    procedural_status=not initialized    type=ALD
        Wait Until Keyword Succeeds   5min  5 sec    Check ALD RAEU Status    administrative_state=Unlocked    availability_status=${avai_status}
        ...    operational_state=Disabled    procedural_status=not initialized    type=${ald_type}
        Change DC Voltgae For RET Port    value=true
        Wait until ALD AND RAEU status normal    ald_type=${ald_type}
    END

Modify ALD HDLC Parameter
    [Arguments]    ${hdlc_flag}=true
    Selenium Login And Disable Screen Lock
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/RSL-1
    ...    filter_param=HDLC communication enabled
    ...    abbr=hdlcCommunicationAllowed
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/RSL-1
    ...    filter_param=HDLC communication enabled  p_name=hdlcCommunicationAllowed  value=${hdlc_flag}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${currect_status}'!='${hdlc_flag}'    Modify Parameters On Webem    modify_params=${modify_params}
    [Teardown]  Selenium Logout And Close Browser

Modify ALD DC Voltage Parameter
    [Arguments]    ${dcvoltage_flag}=true
    Selenium Login And Disable Screen Lock
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/RSL-1
    ...    filter_param=DC voltage enabled
    ...    abbr=dcVoltageEnabled
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/RSL-1
    ...    filter_param=DC voltage enabled  p_name=dcVoltageEnabled  value=${dcvoltage_flag}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${currect_status}'!='${dcvoltage_flag}'    Modify Parameters On Webem    modify_params=${modify_params}
    [Teardown]  Selenium Logout And Close Browser

Modify ALD antFreqBand Parameter
    [Arguments]    ${antFreqBand_value}=1    ${ald_type}='RAEU'
    Selenium Login And Disable Screen Lock
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-1/${ald_type}-1
    ...    filter_param=Antenna operating frequency band
    ...    abbr=antFreqBand
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-1/${ald_type}-1
    ...    filter_param=Antenna operating frequency band  p_name=antFreqBand  value=${antFreqBand_value}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${currect_status}'!='${antFreqBand_value}'    Modify Parameters On Webem    modify_params=${modify_params}
    [Teardown]  Selenium Logout And Close Browser

Wait until ALD AND RAEU status normal
    [Arguments]    ${timeout}=${5} min   ${download_dir}=${SAVE LOG DIRECTORY}    ${ald_type}=RAEU
    log to console    Wait until ALD AND RAEU status normal
    Wait Until Keyword Succeeds   ${timeout}  30 sec    Check ALD RAEU Status    administrative_state=Unlocked    availability_status=Online
    ...    operational_state=Enabled    procedural_status=-    type=ALD    download_dir=${download_dir}
    Wait Until Keyword Succeeds   ${timeout}  30 sec    Check ALD RAEU Status    administrative_state=Unlocked    availability_status=Online
    ...    operational_state=Enabled    procedural_status=-    type=${ald_type}    download_dir=${download_dir}

Add ALD information to scf
    [Documentation]   Auther: arya.chen@nokia-sbell.com
    [Arguments]    ${scf_file_path}
    log to console    Add ALD information to scf
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${SAVE LOG DIRECTORY}/ALD_add/
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...    _ALD_add.xml
    ${scf_file_update_path}    set variable    ${SAVE LOG DIRECTORY}/ALD_add/${scf_name_for_update}
    scf.Load scf    ${default_scf_file_path}
    ${eqm_version}=    scf.get_mo_attribute    MRBTS-${tl.gnbs[0].instance_id}/EQM-1/APEQM-1    version
    ${if_SBTS}    get stream from version    ${Active_SW_version}
    FOR    ${item}    IN    @{ALD_MOS_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${eqm_version}
    END
    FOR    ${item}    IN    @{ALD_LIST_NAME_PARAMS_TO_ADD}
        Run Keyword if   '${if_SBTS}'=='10.1800' or '${if_SBTS}'=='11.800'
        ...    scf.add list to scf  dist_name=${item}[dist_name]  list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{ALD_LIST_ITEMS_PARAMS_TO_ADD}
        Run Keyword if   '${if_SBTS}'=='10.1800' or '${if_SBTS}'=='11.800'
        ...    scf.add item to list  dist_name=${item}[dist_name]  list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{ALD_LIST_ELEMENTS_PARAMS_TO_ADD}
        Run Keyword if   '${if_SBTS}'=='10.1800' or '${if_SBTS}'=='11.800'
        ...    scf.add elements to list  dist_name=${item}[dist_name]  list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{ALD_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.Save scf    ${scf_file_update_path}
    [Return]    ${scf_file_update_path}

Delete ALD Infomation If Exist
    [Documentation]   Auther: arya.chen@nokia-sbell.com
    [Arguments]    ${scf_file_path}
    log to console    Delete ALD Infomation If Exist
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${SAVE LOG DIRECTORY}/ALD_delete/
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...    _ALD_delete.xml
    ${scf_file_update_path}    set variable    ${SAVE LOG DIRECTORY}/ALD_delete/${scf_name_for_update}
    scf.Load scf    ${default_scf_file_path}
    FOR    ${item}    IN    @{ALD_MOS_PARAMS_TO_ADD}
        ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
        run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    scf.Save scf    ${scf_file_update_path}
    [Return]    ${scf_file_update_path}

Get ALD RAEU Information via webUI
    [Arguments]    ${type}=ALD    ${index}=1    ${download_dir}=${SAVE LOG DIRECTORY}
    Log to console    Info: ready to Get ${type} Information
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${info} =    run keyword if    '${type}'=='ALD'    selenium_coam.get_ald_info    ald_index=${index}
    ...    ELSE IF    '${type}'=='RAEU'    selenium_coam.get_raeu_info    raeu_index=${index}
    ...    ELSE IF    '${type}'=='RETU'    selenium_coam.get_retu_info
    [Return]    ${info}
    [Teardown]    selenium_coam.logout

Check ALD RAEU Status
    [Arguments]    ${administrative_state}
    ...    ${availability_status}
    ...    ${operational_state}
    ...    ${procedural_status}
    ...    ${type}=ALD
    ...    ${index}=1
    ...    ${download_dir}=${SAVE LOG DIRECTORY}
    Log To Console    Info: ready to check ${type} status...
    ${info} =    Get ALD RAEU Information via webUI    type=${type}    index=${index}    download_dir=${download_dir}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${info["Status"]["Administrative state"]}    ${administrative_state}
    ...    msg=Current ${type} administrative_state is not in ${administrative_state} status    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${info["Status"]["Availability status"]}    ${availability_status}
    ...    msg=Current ${type} availability_status is not in ${availability_status} status    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${info["Status"]["Operational state"]}    ${operational_state}
    ...    msg=Current ${type} operational_state is not in ${operational_state} status    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${info["Status"]["Procedural status"]}    ${procedural_status}
    ...    msg=Current ${type} procedural_status is not in ${procedural_status} status    ignore_case=${True}

Check ALD REAU Info
    [Arguments]    ${type}=ALD    ${index}=1    ${download_dir}=${SAVE LOG DIRECTORY}
    ${info} =    Get ALD RAEU Information via webUI    type=${type}    index=${index}    download_dir=${download_dir}
    ${Product_code}    Run keyword If    '${type}'=='ALD'    set variable    ${info['Product code']}
    ${Serial_number}    Run keyword If    '${type}'=='ALD'    set variable    ${info['Serial number']}
    ${Vendor_code}    Run keyword If    '${type}'=='ALD'    set variable    ${info['Vendor code']}
    ${SW_version}    Run keyword If    '${type}'=='ALD'    set variable    ${info['SW version']}
    Run keyword If    '${type}'=='ALD'    Should Not Be Equal    ${Product_code}    -    AND
    ...    Should not be empty   ${Product_code}
    Run keyword If    '${type}'=='ALD'    Should Not Be Equal    ${Serial_number}    -    AND
    ...    Should not be empty   ${Serial_number}
    Run keyword If    '${type}'=='ALD'    Should Not Be Equal    ${Vendor_code}    -    AND
    ...    Should not be empty   ${Vendor_code}
    Run keyword If    '${type}'=='ALD'    Should Not Be Equal    ${SW_version}    -    AND
    ...    Should not be empty   ${SW_version}
    ${Mechanical_Angle}    Run keyword If    '${type}'=='RAEU'     set variable    ${info['Mechanical Angle']}
    Run keyword If    '${type}'=='RAEU'    Should Not Be Equal    ${Mechanical_Angle}    -    AND
    ...    Should not be empty   ${Mechanical_Angle}

Change DC Voltgae For RET Port
    [Arguments]    ${value}=true    ${rmod_index}=1    ${download_dir}=${SAVE LOG DIRECTORY}
    Log to console    Info: Change DC Voltgae For RET Port to ${value}
    &{dcVoltage_param}    Create Dictionary    abbr=dcVoltageEnabled
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/EQM-1/APEQM-1/RMOD-${rmod_index}/RSL-1
    ...    filter_param=DC voltage enabled
    ...    new_value=${value}
    @{dcVoltage_param}    Create List    ${dcVoltage_param}
    COAM Update several parameters via webUI   parameters_to_update_via_webui=${dcVoltage_param}
    ...    download_dir=${download_dir}
