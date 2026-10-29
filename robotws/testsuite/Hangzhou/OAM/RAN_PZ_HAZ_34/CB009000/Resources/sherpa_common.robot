*** Settings ***
Documentation
...  author: Han Ruiyu
...  contact: ruiyu.han@nokia-sbell.com

Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001681_794/resources/case_steps.robot
#Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
#Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py

*** Variables ***
${DCAP_HOST}   ${tl.gnbs[0].dcap.connection_details.addr}
${DCAP_port}    ${EMPTY}

&{bts_classical}      alias=gnb_dcap    host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    username=Nemuadmin    password=nemuuser
    ...     port=443    bts_id=${tl.gnbs[0].global_bts_id}

@{gnb_custom_type}    L2Ps_Sherpa

*** Keywords ***
Sherpa log Start Collect
    [Arguments]    ${gnb_custom_profile}=${gnb_custom_type}
    log to console   \Uplane log Setup
    common.Set Output Log Path
    Start Dcap Basic trace    gnb_custom_profile=${gnb_custom_profile}


Sherpa log Stop Collect and Convert CSV
    ${downloaded_emil_file_path}    Stop Dcap Basic trace
    ${emil_log_file_list}    ${sherpa_log_file_list}    Exact Dcap log    downloaded_emil_file_path=${downloaded_emil_file_path}
    set suite variable     ${sherpa_log_file_list}
    Convert Pcaps to CSV    local_sherpa_list=${sherpa_log_file_list}


Sherpa log Process Teardown
    run keyword and ignore error    Stop DCAP log
    run keyword and ignore error    Dcap delete trace    trace_id=${result_id}
    run keyword and ignore error    Dcap delete bts    bts_id=${dcap_create_id}

Decode Log and Get Value
    [Arguments]   ${filepath}    ${filter_params}    ${filter_value}
    ${filters}    Set Variable
    FOR   ${param}   IN   @{filter_params}
         ${filters}   Catenate   SEPARATOR=*   ${filters}   ${param}
     END
    ${ret} =	Grep File	${filepath}  	${filters}
    should not be empty    ${ret}    msg=no matching info in ${filepath} for the filter parameters!
    ${value_list}    Get Regexp Matches    ${ret}    ${filter_value}   1
    ${number_list}    Create List
    FOR  ${str}   IN    @{value_list}
        ${number}    convert to number    ${str}
        Append to List    ${number_list}    ${number}
     END
    [Return]   ${number_list}

Check L1L2 value from Sherpa Log
    [Arguments]    ${direction}    ${globlecellid}    ${filter}    ${max_value}   ${ave_value}
    log to console   \n Check L1L2 value from Sherpa Log
    ${filter_list}    Create List
    ${nrCellIdentity}    Get Nrcellid by Globlecellid    gloablecellid=${globlecellid}
    ${cellid_hex}    Convert To Hex    ${nrCellIdentity}   prefix=0x
    ${filter_value}     set variable   ${filter}=(\\d),
    Append to List    ${filter_list}    Type=${direction}    NRCellid=${cellid_hex.lower()}    ${filter}
    ${number_list}    Decode Log and Get Value    filepath=${OUTPUT_LOG_PATH}/Sherpa_l1l2Trace.csv
    ...  filter_params=${filter_list}   filter_value=${filter_value}
    ${avevalue_calc}    evaluate   float(sum(${number_list})/len(${number_list}))
    ${ave_value}    convert to number    ${ave_value}
    ${status} =	Evaluate	${ave_value}<= ${avevalue_calc} <= ${max_value}
    should be True    ${status}   msg=[FAIL]average value:${avevalue_calc} not in ranage ${ave_value}-${max_value}!
    ${maxvalue_calc}    evaluate   float(max(${number_list}))
    ${max_value}    convert to number    ${max_value}
    ${status} =	Evaluate	${maxvalue_calc} <= ${max_value}
    should be True    ${status}   msg=[FAIL]max value:${maxvalue_calc} bigger than ${max_value}!

Check Average Range Value from Sherpa Log
    [Arguments]    ${direction}    ${globlecellid}    ${filter}    ${ave_value}    ${range_value}
    log to console   \n Check Average Range Value from Sherpa Log
    ${filter_list}    Create List
    ${nrCellIdentity}    Get Nrcellid by Globlecellid    gloablecellid=${globlecellid}
    ${cellid_hex}    Convert To Hex    ${nrCellIdentity}   prefix=0x
    ${filter_value}     set variable   ${filter}=(\\d*),
    Append to List    ${filter_list}    Type=${direction}    NRCellid=${cellid_hex.lower()}    ${filter}
    ${number_list}    Decode Log and Get Value    filepath=${OUTPUT_LOG_PATH}/Sherpa_l1l2Trace.csv
    ...  filter_params=${filter_list}   filter_value=${filter_value}
    ${avevalue_calc}    evaluate   float(sum(${number_list})/len(${number_list}))
    ${ave_value}    convert to number    ${ave_value}
    ${min_value}    evaluate    ${ave_value}-${range_value}
    ${max_value}    evaluate    ${ave_value}+${range_value}
    ${status} =	Evaluate	${min_value}<= ${avevalue_calc} <= ${max_value}
    should be True    ${status}   msg=[FAIL]average value:${avevalue_calc} not in ranage ${min_value}-${max_value}!


Check Cell List Value from L1L2trace
    [Arguments]   ${direction}    ${filter}    ${cell_value_dic}    ${range_value}
    FOR    ${cell}   IN   @{cell_value_dic}
        Check Average Range Value from Sherpa Log    direction=${direction}    filter=${filter}    globlecellid=${cell}
        ...   ave_value=${cell_value_dic['${cell}']}    range_value=${range_value}
     END



Get Nrcellid by Globlecellid
    [Arguments]   ${gloablecellid}
    ${gnbidlength}    COAM Get Parameter Value By XPath
    ...    xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="gNbIdLength"]
    ${nrCellIdentity}    Evaluate    int(${MRBTS_ID})*(int(2)**(${36}-int(${gnbidlength})))+int(${gloablecellid})
    [Return]    ${nrCellIdentity}
