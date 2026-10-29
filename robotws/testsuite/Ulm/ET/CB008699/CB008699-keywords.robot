*** Settings ***
Documentation   This is a keyword file for CB008699
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        ../../resources/Common/reporting.robot

*** Variables ***

${WIRESHARK_RUNNING}         false

*** Keywords ***

Create ips for simulated gnb
    [Documentation]    [PRIVATE]    create IPs used for WTS
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncreate IPs 10.0.1.3, 10.0.1.4 and 10.0.1.121 on VM eth3
    Configure IP on VM    ip=10.0.1.3        interface=eth3
    Configure IP on VM    ip=10.0.1.4        interface=eth3
    Configure IP on VM    ip=10.0.1.121      interface=eth3


Suite Setup CB008699
    [Documentation]    [PRIVATE]    Prepare TL for CB008699
    ...       :Autor: Sylvia Schneider
    Create ips for simulated gnb
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF from gNB
    get version mcc mnc from gNB SCF    ${current_SCF_gnb}
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    Update wts file for TC CB008699
    Update SCF file for TC CB008699 common part


Suite Setup CB008699-FR2
    [Documentation]    [PRIVATE]    Prepare TL for CB008699-FR2
    ...       :Autor: Sylvia Schneider
    Create ips for simulated gnb
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF from gNB
    get version mcc mnc from gNB SCF    ${current_SCF_gnb}
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    Update wts file for TC CB008699-FR2
    Update SCF file for TC CB008699-FR2


Perform Preconditions of Test Scenario CB008699
    [Documentation]    [PRIVATE]    preconditions for CB008699
    ...       :Autor: Sylvia Schneider
    Create a Test Scenario Folder


Perform Postconditions of Test Scenario CB008699
    [Documentation]    [PRIVATE]    postconditions for CB008699
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Set SCOUT TC ID for Reporting
    Run Keyword And Continue On Failure   stop wireshark trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Run Keyword And Continue On Failure   end dcap tracing and collect traces
    Run Keyword And Continue On Failure   Teardown Egate Connection for Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect snapshot and sos report data     ${resultDir}


Suite Teardown CB008699
    [Documentation]    [PRIVATE]    suite teardown for 711A CB8731
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   stop wireshark trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    Collect snapshot and sos report data   ${resultBaseDir}
    Reload Stored WTS Config


check all radio units online
    [Documentation]    [PRIVATE]   check that all radio units are online
    ...     :Autor: Sylvia Schneider
    Log To Console    Waiting until all RUs are online
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    wait until keyword succeeds
    ...    10min   20sec
    ...    Verify All Radios are Online    connection=${oam_alias}
    Log to console    RUs ready
    [Teardown]     connect.Teardown OAM http session    node_type=gnb  node_id=${0}


get version mcc mnc from gNB SCF
    [Documentation]    [PRIVATE]    get values from SCF for update commissioning
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${current_SCF_gnb}
    ${parsed_SCF}    parse XML    ${current_SCF_gnb}
    ${version}    get element attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="${bts_distName}"]
    Set To Dictionary    ${SCF}   version   ${version}
    Log To Console    variable SCF.version contains ${SCF.version}
    ${MNL_version}    get element attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="MRBTS-1/MNL-1"]
    Set To Dictionary    ${SCF}   MNL_version   ${MNL_version}
    Log To Console    variable SCF.MNL_version contains ${SCF.MNL_version}
    ${NRPMRNL_version}    get element attribute    ${parsed_SCF}    version     xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    Set To Dictionary    ${SCF}   NRPMRNL_version   ${NRPMRNL_version}
    Log To Console    variable SCF.NRPMRNL_version contains ${SCF.NRPMRNL_version}
    ${NRPMRNL_distName}    get element attribute    ${parsed_SCF}    distName     xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    Set To Dictionary    ${SCF}   NRPMRNL_distName   ${NRPMRNL_distName}
    Log To Console    variable SCF.NRPMRNL_distName contains ${SCF.NRPMRNL_distName}
    ${mcc}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mcc"]
    Set To Dictionary    ${SCF}   mcc   ${mcc}
    Log To Console    variable SCF.mcc contains ${SCF.mcc}
    ${mnc}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mnc"]
    Set To Dictionary    ${SCF}   mnc   ${mnc}
    Log To Console    variable SCF.mnc contains ${SCF.mnc}


get time after ${action}
    [Documentation]    [PRIVATE]    get time after handover, release
    ...       :Autor: Sylvia Schneider
    ${act_time}     DateTime.get current date
    set test variable    ${time_${action}}    ${act_time}
    Log to console    actual time was saved to parameter time_${action} "${time_${action}}"


verify counter CB008699
    [Documentation]    [PRIVATE]    verify counter of CB008699
    ...       :Autor: Sylvia Schneider

    Collect PM Counters
    ${parsed_PmFile}     parse xml    ${pmCounter_xml_file}
    set test variable    ${parsed_PmFile}
    Log Dictionary       ${dict_pm_counter}
    @{dict_keys}         Get Dictionary Keys    ${dict_pm_counter}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_pm_counter}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_PmFile}
    END

    ${diff}    DateTime.subtract date from date    ${time_release}    ${time_handover}
    ${duration}    evaluate    ${diff}+2
    ${packet_rate}  set variable    500
    ${start}   evaluate   ${duration}*${packet_rate}*0.95
    ${end}     evaluate   ${duration}*${packet_rate}

    ${xpath_param}    get from dictionary    ${xpath_vars_pmCounter}    counter_pmFile_coam
    verify counter calculate   counter_name=M55319C11006  start=${start}   end=${end}   xpath_param=${xpath_param}
    verify counter calculate   counter_name=M55319C15006  start=${start}   end=${end}   xpath_param=${xpath_param}


verify counter CB008699 t4
    [Documentation]    [PRIVATE]    verify counter of CB008699 t4
    ...       :Autor: Sylvia Schneider

    Collect PM Counters
    ${parsed_PmFile}     parse xml    ${pmCounter_xml_file}
    set test variable    ${parsed_PmFile}
    Log Dictionary       ${dict_pm_counter}
    @{dict_keys}         Get Dictionary Keys    ${dict_pm_counter}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_pm_counter}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_PmFile}
    END

    ${diff}    DateTime.subtract date from date    ${time_release}    ${time_handover}
    ${duration}    evaluate    ${diff}+2
    ${packet_rate}  set variable    500
    ${start}   evaluate   ${duration}*${packet_rate}*0.95
    ${end}     evaluate   ${duration}*${packet_rate}

    ${xpath_param}    get from dictionary    ${xpath_vars_pmCounter}    counter_pmFile_coam
    verify counter calculate   counter_name=M55319C11006  start=${start}   end=${end}   xpath_param=${xpath_param}
    verify counter calculate   counter_name=M55319C15006  start=${start}   end=${end}   xpath_param=${xpath_param}

    ${packet_rate}  set variable    1000
    ${start}   evaluate   ${duration}*${packet_rate}*0.95
    ${end}     evaluate   ${duration}*${packet_rate}

    ${xpath_param}    get from dictionary    ${xpath_vars_pmCounter}    counter_pmFile_coam
    verify counter calculate   counter_name=M55319C11007  start=${start}   end=${end}   xpath_param=${xpath_param}
    verify counter calculate   counter_name=M55319C15007  start=${start}   end=${end}   xpath_param=${xpath_param}


verify counter calculate
    [Documentation]    [PRIVATE]    calculate counters and verify them
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${counter_name}  ${start}   ${end}   ${xpath_param}

    Log To Console    \nverify counter ${counter_name}
    ${counter_text}        Set Variable    ${${counter_name}}[0]
    ${counter_distName}    Set Variable    PLMN-PLMN/${bts_distName}
    ${counter_meastype}    Set Variable    ${${counter_name}}[1]
    ${xpath_param}    replace variables    ${xpath_param}
    ${counter_value_from_pm_xml}   get element text     ${parsed_PmFile}        xpath=${xpath_param}
    ${result}       Set Variable If    ${start} <= ${counter_value_from_pm_xml} <= ${end}    Passed    Failed
    ${msg1}         Set Variable      \ncounter ${counterName} "${counter_text}" for nrbts
    ${msg2}         Set Variable      ${start} <= pm file value ${counter_value_from_pm_xml} <= ${end}
    IF    '${result}'=='Passed'    Log to console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    report pm counter
    ...   id=${counterName}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}


verify counter CB008699 t6
    [Documentation]    [PRIVATE]    verify counter of CB008699 t6
    ...       :Autor: Sylvia Schneider

    Collect PM Counters
    ${parsed_PmFile}     parse xml    ${pmCounter_xml_file}
    set test variable    ${parsed_PmFile}
    Log Dictionary       ${dict_pm_counter}
    @{dict_keys}         Get Dictionary Keys    ${dict_pm_counter}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_pm_counter}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_PmFile}
    END


verify counter CB008699 FR2
    [Documentation]    [PRIVATE]    verify counter of CB008699 t6
    ...       :Autor: Sylvia Schneider

    Collect PM Counters file coam
    Filter last PM Counters file FR2
    Prepare last pm file FR2
    ${parsed_PmFile}     parse xml    ${pmCounter_xml_file}
    set test variable    ${parsed_PmFile}
    Log Dictionary       ${dict_pm_counter}
    @{dict_keys}         Get Dictionary Keys    ${dict_pm_counter}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_pm_counter}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_PmFile}
    END

    Prepare last pm file FR2 NRMIAF NRMASA
    FOR   ${counter_group}   IN
    ...   miaf
    ...   masa
      verify counters of group ${counter_group}
    END


Filter last PM Counters file FR2
    [Documentation]    [PRIVATE]   filter last pm counter files FR2
    ...     :Autor: Sylvia Schneider
    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${resultDir}/${coam_pm_file_path}/ | grep PM.*ANY.xml
    ${result}    set variable if    '${rc}'=='${0}'    pass    fail
    IF     '${result}'=='fail'    Fail    no measurement file available
    ${temp}    split to lines    ${all_pm_file}
    ${pm_file_name}    set variable    ${temp[0]}
    ${pm_file_name_with_path}    set variable    ${resultDir}/${coam_pm_file_path}/${pm_file_name}

    Move File    ${pm_file_name_with_path}    ${resultDir}/
    Empty Directory    ${resultDir}/${coam_pm_file_path}
    Move File    ${resultDir}/${pm_file_name}   ${resultDir}/${coam_pm_file_path}/
    Set test variable   ${pm_file_name_with_path}


Prepare last pm file FR2
    [Documentation]    [PRIVATE]   Prepare last pm file FR2
    ...     :Autor: Sylvia Schneider
    ${file_string}   Get File   ${pm_file_name_with_path}
    ${file_string}  Replace String    ${file_string}  ><  >\n<   count=-1
    Create File    ${resultDir}/pm.xml    ${file_string}
    Set Test Variable    ${pmCounter_xml_file}    ${resultDir}/pm.xml


Prepare last pm file FR2 NRMIAF NRMASA
    [Documentation]    [PRIVATE]   Prepare last pm file FR2 NRMIAF NRMASA
    ...     :Autor: Sylvia Schneider
    ${pm_file}   get file     ${pm_file_name_with_path}
    Set Test Variable    ${pm_file}


verify counters of group ${counter_group}
    [Documentation]    [PRIVATE]   verify counters belonging to same group
    ${counter_cell}    Set Variable    ${${counter_group}_counter}[0]
    ${counter_id}      Set Variable    ${${counter_group}_counter}[1]
    ${type}            Set Variable    ${${counter_group}_counter}[2]

    ${allCounter}    get all counters from same object and type   ${counter_cell}    ${type}     ${counter_id}
    verify counters of same group   ${counter_group}   ${allCounter}


get all counters from same object and type
    [Documentation]    [PRIVATE]   get all counters from same object and type
    [Arguments]    ${counter_cell}    ${type}     ${counter_id}
    ${s1}  set variable   <DN>PLMN-PLMN/MRBTS-1/NRBTS-1/${counter_cell}</DN></MO><MO dimension="NR${type}">
    ${s2}  set variable   <DN>PLMN-PLMN/${counter_id}</DN></MO><NE-WBTS_1.0 measurementType="${type}">
    Log to console    \nget all counters with ${s1}${s2}
    ${temp1}         Fetch from right      ${pm_file}      ${s1}${s2}
    ${allCounter}    Fetch from left       ${temp1}        </NE-WBTS_1.0>
    Log to console    found "${allCounter}"
    RETURN    ${allCounter}


verify counters of same group
    [Documentation]    [PRIVATE]   verify counters of same group
    ...     :Autor: Sylvia Schneider
    [Arguments]    ${counter_group}   ${allCounter}
    @{dict_keys}         Get Dictionary Keys    ${dict_${counter_group}_counter}
    FOR    ${counterKeyName}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict_${counter_group}_counter}    ${counterKeyName}
        ${temp}   split string   ${counterKeyName}    -
        ${counter}  set variable   ${temp}[0]
        Verify single Counter 2 dimension objects   ${allCounter}   ${counter}    ${counterList}
    END


Verify single Counter 2 dimension objects
    [Documentation]    [PRIVATE]   Verify single Counter 2 dimension objects
    ...     :Autor: Sylvia Schneider
    ...     :param ${counter}: name of counter e.g M55114C00001
    ...     :param ${counterList}: list containing details of counter
    [Arguments]    ${allCounter}   ${counter}    ${counterList}
    ${counter_text}    Set Variable    ${counterList}[0]
    ${counter_expectedValue}    Set Variable    ${counterList}[1]

    ${counter_value_from_pm}   get regexp matches   ${allCounter}   <${counter}>(\\d+)</${counter}>   1
    ${counter_pm}  set variable   ${counter_value_from_pm}[0]
    ${result}       Set Variable If    ${counter_pm}==${counter_expectedValue}    Passed    Failed
    ${msg1}         Set Variable      counter ${counter} "${counter_text}"
    ${msg2}         Set Variable      pm file value ${counter_pm} == expectedValue ${counter_expectedValue}
    IF    '${result}'=='Passed'    Log to console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    report pm counter
    ...   id=${counter}
    ...   value=${counter_pm}
    ...   result=${result}


register UE and start PDU session
    [Documentation]    [PRIVATE]    register UE and start PDU session
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${cell}
    start wireshark trace
    ue change location   ue_id=${ue_id}  cell=${cell}
    register UE          ue_id=${ue_id}
    start PDU session    ue_id=${ue_id}
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_register_pdu_UE${ue_id}.pcap


verify syslog trace
    [Documentation]    [PRIVATE]    verify syslog trace
    ...       :Autor: Sylvia Schneider
    Log to console   verify syslog
    ${syslog_dir}     Set Variable  ${resultDir}/btslog_gnb0
    ${syslog_files}   OperatingSystem.List Files In Directory  ${syslog_dir}  *.tgz
    ${num_of_files}   get length  ${syslog_files}

    ${EXCEPTIONFILE}     Set Variable  ${CURDIR}/SYSLOG_EXCEPTION.TXT
    ${ERRORARRAYFILE}    Set Variable  ${dir_syslog_parser}/SYSLOG_ARRAY.TXT
    ${REQUIREMENTFILE}   Set Variable  ${dir_syslog_parser}/SYSLOG_REQUIREMENT.TXT

    ${error_file}=  IF  ${num_of_files}==1
    ...    find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...    ${syslog_dir}/${syslog_files}[0]
    ...    ignorefname=${EXCEPTIONFILE}
    ...    errordeffname=${ERRORARRAYFILE}
    ...    requirementfname=${REQUIREMENTFILE}
    ...    ELSE    Log to console    No syslog_files.tgz available

    Run Keyword and warn on failure          OperatingSystem.File Should Be Empty  ${error_file}
