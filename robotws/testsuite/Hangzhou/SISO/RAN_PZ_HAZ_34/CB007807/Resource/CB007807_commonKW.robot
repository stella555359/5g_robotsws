*** Settings ***
Documentation     author: annie hu
...               Group: HGZ_SG5
...               contact: annie.hu@nokia-sbell.com

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC000433/Resource/5GC000433_common_KW.robot
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot

*** Keywords ***
Case Teardown
    Connect to gnb coam via ssl
    ${cell_list}   Get All Cell Id   connection=GNB_OAM
    #:FOR   ${cell_idx}   IN   @{cell_list}
        #Perform cell unlock via rest api   cell_idx=${cell_idx}   connection=GNB_OAM
     #END
     Run Keyword And Continue On Failure    Perform cell unlock via rest api    cell_idx=${1}
     #Wait Until Keyword Succeeds   600 sec   60 sec   COAM Check All Cells Onair     connection=GNB_OAM
     Wait Until Keyword Succeeds    480 sec   5 sec     COAM Check GNB cell on air
     COAM Teardown gnb connections
     #Run Keyword And Ignore Error    admin_cli.teardown    connection=${connection}
    sleep    30s

Check real time measurements of RMOD
    [Arguments]    ${interval}
    FOR  ${i}  IN RANGE  ${3}
	    ${Power}    Get master real time measurements via Webem for RMOD     interval=${interval}
	    Should be True    ${Power} > 0
        #Should be True    ${Power} > 0
	    exit for loop if   ${i} == 2
	    sleep    ${wait_time}
	    sleep    10
	END

Check real time measurements of SMOD
    [Arguments]    ${interval}
    #selenium login and disable screen lock
    FOR  ${i}  IN RANGE  ${3}
	    #${Voltage}    ${Power}    ${wait_time}
	    ${Power}      Get master real time measurements via Webem for SMOD    interval=${interval}
	    #Should be True    ${Voltage} > 0
        Should be True    ${Power} > 0
	    exit for loop if   ${i} == 2
	    sleep    ${wait_time}
	    sleep    10
	END

Get RMOD Power Measurement via Webem
     [Arguments]    ${interval}
     ${rmod_power_measure}  Convert to number  0
     FOR  ${i}  IN RANGE  ${3}
          ${rmod_power}     Get master real time measurements via Webem for RMOD    interval=${interval}
          #@{measure}  Split string     ${output}
          #${power}    convert to number  ${measure[-3]}    2
          #${index}    Evaluate  ${index}+1
          ${rmod_power_measure}  Evaluate  ${rmod_power_measure}+${rmod_power}
          sleep    ${wait_time}
          Sleep  5
     END
     ${rmod_average}   Evaluate   ${rmod_power_measure}/3
     ${rmod_power}   Convert to number   ${rmod_average}    1
     log   \nrmodpower_average = ${rmod_power}     console=yes
     [Return]    ${rmod_power}

Get SMOD Power Measurement via Webem
     [Arguments]    ${interval}
     ${smod_power_measure}  Convert to number  0
     FOR  ${i}  IN RANGE  ${3}
          ${smod_power}     Get master real time measurements via Webem for SMOD    interval=${interval}
          #@{measure}  Split string     ${output}
          #${power}    convert to number  ${measure[-3]}    2
          #${index}    Evaluate  ${index}+1
          ${smod_power_measure}  Evaluate  ${smod_power_measure}+${smod_power}
          sleep    ${wait_time}
          Sleep  5
     END
     ${smod_average}   Evaluate   ${smod_power_measure}/3
     ${smod_power}   Convert to number   ${smod_average}    1
     log   \nsmodpower_average = ${smod_power}     console=yes
     [Return]    ${smod_power}

Get master real time measurements via Webem for RMOD
    [Arguments]    ${interval}
    ${content}    selenium_coam.get_real_time_measurements    object_names=RMOD
    ${value_list}    get dictionary values    ${content}
    ${time_list}    get dictionary keys   ${value_list[1]}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    Connect to Common Unit Master
    ${current_time}   get time from gnb
    ${end_time}    add_time_to_date    ${last_time}    ${interval}
    ${diff}    subtract_date_from_date    ${end_time}    ${current_time}
    ${diff1}    subtract_time_from_time    ${diff}    ${interval}
    should be true    ${diff1}<0
    ${wait_time}=  evaluate  ${diff1} + 60
    Set Suite Variable    ${wait_time}
    ${power_voltage}    get_from_dictionary   ${value_list[1]}    ${last_time}
    ${Voltage}    get_from_dictionary    ${power_voltage}    Voltage
    ${Power}    get_from_dictionary    ${power_voltage}    Power
    [Return]     ${Power}

Get master real time measurements via Webem for SMOD
    [Arguments]    ${interval}
    ${content}    selenium_coam.get_real_time_measurements    object_names=SMOD
    ${value_list}    get dictionary values    ${content}
    ${time_list}    get dictionary keys   ${value_list[0]}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    Connect to Common Unit Master
    ${current_time}   get time from gnb
    ${end_time}    add_time_to_date    ${last_time}    ${interval}
    ${diff}    subtract_date_from_date    ${end_time}    ${current_time}
    ${diff1}    subtract_time_from_time    ${diff}    ${interval}
    should be true    ${diff1}<0
    ${wait_time}=  evaluate  ${diff1} + 60
    Set Suite Variable    ${wait_time}
    ${power_voltage}    get_from_dictionary   ${value_list[0]}    ${last_time}
    ${Voltage}    get_from_dictionary    ${power_voltage}    Voltage
    ${Power}    get_from_dictionary    ${power_voltage}    Power
    [Return]     ${Power}

General_Feature_Micro-DTX_deactivate_microDtxEnabled_false
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify Micro-DTX deactivation
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 07.11.2022 - - Created
    ...    *******************
    ...    Owner_annie.hu@nokia-sbell.com
    #log to console   \n*** set precondition: Micro-DTX deactivate ***
    #Modify RMOD Power Parameter    power_status=true
    #sleep  20
    #Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4308
    log to console   \n*** Micro-DTX deactivate ***
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    run keyword if  '${stream}'<'SBTS25R1'   Modify RMOD Power Parameter    power_status=false
    sleep  20
    #Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4308
    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to Common Unit Master
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
        ${soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        Check SOAP message Micro-DTX status on mRRH   soapLog_path=${soap_path}    lteOfdmSymbolsMutingEnabled=${FALSE}
        ${soap_file_path}    Run Keyword And Ignore Error    OperatingSystem.Copy File    ${soap_path}    ${SAVE LOG DIRECTORY}
        csn.Disconnect    connection=ASIK Master
    END

General_Feature_Micro-DTX_activate_microDtxEnabled_true
    #Modify RMOD Power Parameter    power_status=false
    #sleep  20
    #Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4308
    log to console   \n*** Micro-DTX activate ***
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    run keyword if  '${stream}'<'SBTS25R1'   Modify RMOD Power Parameter    power_status=true
    sleep  20
    #Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4308
    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to Common Unit Master    alias=ASIK Master
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
        ${soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        Check SOAP message Micro-DTX status on mRRH    soapLog_path=${soap_path}    lteOfdmSymbolsMutingEnabled=${TRUE}
        ${soap_file_path}    Run Keyword And Ignore Error    OperatingSystem.Copy File    ${soap_path}    ${SAVE LOG DIRECTORY}
        csn.Disconnect    connection=ASIK Master
    END

Check SOAP message Micro-DTX status on mRRH
    [Arguments]   ${soapLog_path}    ${lteOfdmSymbolsMutingEnabled}=${TRUE}
    log to console  \n*** Check Micro-DTX statusk in SOAP message ***
    soapp.check_soapmsg_parvaluechangeind    log_path=${soapLog_path}    class_value=TxArray
    ...     parameterName=lteOfdmSymbolsMutingEnabled   newValue=${lteOfdmSymbolsMutingEnabled}
