*** Settings ***
Documentation    This is a Robot File, for feature 5GC000480 and 5GC001836
#-------------------------------------------------------------------------------------------------------------
Library          Process                         WITH NAME    process
Library          ArchiveLibrary                  WITH NAME    archive

Library          ../../resources/Common/python/coam_parameter.py
Resource         ../../resources/Common/coam_ulm.robot
Resource         ../../resources/Common/connect.robot
Resource         ../../resources/Common/gnb.robot
Resource         ../../resources/Common/tcpdump.robot
Resource         ../../resources/Common/testline.robot
Resource         ../../resources/Common/ute_workarounds.robot
Resource         ../../resources/Common/wts_ue.robot
Resource         ../../resources/Common/snapshot.robot

Library          taf.transport.ssh               WITH NAME    ssh
Library          taf.config.scf                  WITH NAME    scf
Library          ute_wtssim
Library          taf.sw.reporting_portal
Library          ute_tshark
Library          taf.collectors.pmcounters      WITH NAME     tafpmcounters
Library          taf.collectors.core            WITH NAME     core
Library          taf.collectors.tcpdump         WITH NAME     tcpdump

Library         XML
Library         String


Variables       xpath_vars.yaml
Variables       wireshark_filter.yaml



*** Variables ***
${SSH_OAM_AUTHENTICATION_TIMEOUT}       10 min
${SSH_AUTHENTICATION_RETRY_INTERVAL}    5 s
${SSH_AUTHENTICATION_TIMEOUT}           5 min

${coam_pm_file_path}   gnb_pm_counters

@{operationalState_enabled}     enabled     Enabled


*** Keywords ***

Perform Preconditions of Test Scenario 480-A-B-K
    [Documentation]    [PRIVATE]    preconditions for 480-A, 480-B, 480-K
    ...       :Autor: Sylvia Schneider
    Create a Test Scenario Folder
    Bring Airphone TL to on Air status
    get_enb_data_from_simulated_eNB


Perform Postconditions of Test Scenario 480-A-B-K
    [Documentation]    [PRIVATE]    postconditions for 480-A, 480-B, 480-K
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Teardown Egate Connection for Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect snapshot and sos report data     ${resultDir}


Suite Teardown 5GC000480-A-B-K
    Reload Stored WTS Config


get_enb_data_from_simulated_eNB
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    ${file}     Get File     ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${matched_line}    Get Lines Containing String     ${file}    ENB1_X2_ADDR="
    ${tmp}    split string     ${matched_line}     "
    set suite variable     ${enb_ip}     ${tmp}[1]
    log to console    \nsimulated enb_ip: ${enb_ip}


replace pdn_ip in set_bearer
   [Documentation]    [PRIVATE]    replace $PDN_IP in set bearer command with ip configured in set PDN_IP command
    ...       :Autor: Sylvia Schneider
   [Arguments]   ${pdn_line}    ${set_bearer}
   ${pdn_part}    Split String       ${pdn_line}   "
   ${pdn}         set variable        ${pdn_part}[1]
   ${pdn_tmp}     Split String      ${pdn}    .
   ${pdn_ip}      set variable      ${pdn_tmp}[3]
   ${set_bearer}  replace string   ${set_bearer}   $PDN_IP    ${pdn}
   RETURN     ${set_bearer}


Get testline specific data
    [Documentation]    [PRIVATE]    get specific data for testline: bts_type, gnb_sw_version, oam_type, ue_type
    ...       :Autor: Sylvia Schneider
    Check TL Infos
    show classical sw version


show classical sw version
    [Documentation]    [PRIVATE]     show sw version of classical gnb and set suite variable
    ...     :Autor: Sylvia Schneider
    ...     :param ${nb_id}:      gnb instance in init file
    ${gnb_swVersion}    Get from dictionary    ${P_GNBSWVERSION}    gnb_0
    set suite variable    ${gnb_swVersion}
    log to console    \ngnb_swVersion contains "${gnb_swVersion}"


update edaemon port in wts file
    [Documentation]    [PRIVATE]     update edaemon port taken from __init__.py in wts file
    ...     :Autor: Sylvia Schneider
    ...     :param ${script_for_wts_updated}:   wts file after update

    [Arguments]    ${script_for_wts_updated}

    ${new_edaemon_setting}    Set Variable    set DAEMON_PORT=${tl.core.edaemon_port}
    ${file}    Get File       ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${lines}    Get lines containing string     ${file}     set DAEMON_PORT=              case_insensitive=true
    ${file}     Replace String    ${file}    ${lines}     \n${new_edaemon_setting}\n
    Create File    ${script_for_wts_updated}    ${file}


get nrbts distname from SCF
    [Documentation]    [PRIVATE]     get nrbts distname from SCF
    ...     :Autor: Sylvia Schneider
    ...     :param ${scf_file}: SCF file with path
    [Arguments]    ${scf_file}

    ${parsed_SCF}    parse xml     ${scf_file}
    ${xpath}         get from dictionary    ${xpath_vars_SCF}    distName_NRBTS
    ${nrbts_dist}    get element attribute    ${parsed_SCF}    distName    xpath=${xpath}

    set suite variable   ${bts_distName}      ${nrbts_dist}
    log to console    \nbts_distName: "${bts_distName}"


get pmcadm distname from SCF
    [Documentation]    [PRIVATE]     get pmcadm distname from SCF
    ...     :Autor: Sylvia Schneider
    ...     :param ${scf_file}: SCF file with path
    [Arguments]    ${scf_file}
    ${parsed_SCF}    parse xml     ${scf_file}
    ${xpath}         get from dictionary    ${xpath_vars_SCF}    distName_PMCADM
    ${pmcadm_dist}    get element attribute    ${parsed_SCF}    distName    xpath=${xpath}
    set suite variable   ${pmcadm_distName}    ${pmcadm_dist}
    log to console    \npmcadm_distName: "${pmcadm_distName}"


get scf coam
    [Documentation]    [PRIVATE]     get config scf from classical gNB
    ...     :Autor: Sylvia Schneider
    ...     :param ${dir}: directory where the file is stored
    ...     :param ${scf}: name of stored scf file
    [Arguments]    ${dir}=${resultDir}    ${scf}=SCFC.xml
    log to console     \nget scf from gNB started
    Get SCF from gNB with cOAM    gnbScfName=${scf}    resultConfigDir=${dir}
    log to console     \nget scf from gNB finished


json delta commissioning coam
    [Documentation]    [PRIVATE]   delta commissioning coam
    ...     :Autor: Sylvia Schneider
    ...     :param ${param_list}: list of dictionaries containing parameters and values, which are updated
    [Arguments]     ${param_list}
    ${oam_alias}   connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    \ndelta commissioning started
    Update List of SCF parameters
    ...    parameters=${param_list}
    ...    timeout=600
    ...    alias=${oam_alias}
    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    Log To Console    \ndelta commissioning finished
    Wait until coam gNB to be onair state and cells enabled


wait for next measurement interval
    [Arguments]    ${additional-waiting-time}=70s
    @{act_time}    Get Time    hour min sec
    ${min}    set variable    ${act_time[1]}
    ${minute}    convert to integer    ${min}
    ${CSV-creation-interval-begin}    Evaluate    int(${minute}/${measurement_period_in_min}) * ${measurement_period_in_min}
    ${waiting-time}    Evaluate    ${CSV-creation-interval-begin}+${measurement_period_in_min}-${minute}
    Sleep    ${waiting-time} minutes
    Sleep    ${additional-waiting-time}


Collect PM Counters
    [Documentation]    [PRIVATE]   collect pm counter files
    ...     :Autor: Sylvia Schneider
    Collect PM Counters file and filter last file coam


Collect PM Counters file and filter last file coam
    [Documentation]    [PRIVATE]   collect pm counter files for coam classical gnb
    ...     :Autor: Sylvia Schneider
    Collect PM Counters file coam
    Filter last PM Counters file coam


Collect PM Counters file coam
    [Documentation]    [PRIVATE]   collect pm counter files for coam classical gnb
    ...     :Autor: Sylvia Schneider
    Log To Console    \nuploading pm file from coam
    ${webservice}    Create Dictionary
    ...            host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...            password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...            port=443

    tafpmcounters.create pm collector
    ...    name=gnb_pm_counters
    ...    webservice=${webservice}
    tafpmcounters.setup collectors
    ...    names=gnb_pm_counters
    tafpmcounters.collect collectors
    ...    names=gnb_pm_counters
    ...    target_dir=${resultDir}
    tafpmcounters.teardown collectors
    ...    names=gnb_pm_counters


Filter last PM Counters file coam
    [Documentation]    [PRIVATE]   filter last pm counter files for coam classical gnb
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

    ${file_string}   Get File   ${pm_file_name_with_path}
    ${file_string}  Replace String    ${file_string}  ><  >\n<   count=-1
    Create File    ${resultDir}/pm.xml    ${file_string}

    Set Test Variable    ${pmCounter_xml_file}    ${resultDir}/pm.xml
    RETURN     ${pmCounter_xml_file}


Verify Counter
    [Documentation]    [PRIVATE]   verify counter expected value and value from pm file
    ...     :Autor: Sylvia Schneider
    ...     :param ${counterName}: name of counter e.g M55114C00001
    ...     :param ${counterList}: list containing details of counter
    ...     :param ${parsed_PmFile}: pm file in which counter is searched for
    [Arguments]    ${counterName}    ${counterList}    ${parsed_PmFile}
    ${counter_text}    Set Variable    ${counterList}[0]
    ${counter_expectedValue}    Set Variable    ${counterList}[1]
    ${counter_cell}    Set Variable    ${counterList}[2]
    # next 2 variables will raise a linter warning I0920 but are used in KW 'Replace Variables'!
    ${counter_meastype}    Set Variable    ${counterList}[3]
    ${counter_distName}    Set Variable    PLMN-PLMN/${bts_distName}/${counter_cell}

    ${xpath_param}    get from dictionary    ${xpath_vars_pmCounter}    counter_pmFile_coam
    ${xpath_param}    replace variables    ${xpath_param}
    ${counter_value_from_pm_xml}    get element text     ${parsed_PmFile}        xpath=${xpath_param}
    ${result}       Set Variable If    ${counter_value_from_pm_xml}==${counter_expectedValue}    Passed    Failed
    ${msg1}         Set Variable      \ncounter ${counterName} "${counter_text}" for cell ${counter_cell}
    ${msg2}         Set Variable      pm file value ${counter_value_from_pm_xml} == expectedValue ${counter_expectedValue}\n
    IF    '${result}'=='Passed'    Log to console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    report pm counter
    ...   id=${counterName}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}


Attach UE
    [Arguments]    ${actual_UE}
    Log to Console    \nAttach UE ${actual_UE}
    Attach UE to LTE    ue_id=${actual_UE}
    Sleep    2s
    Trigger LTE-NR dual connectivity for bearers    ue_id=${actual_UE}    bearer_id=2


Attach UE unsuccessful gNB addition
    [Documentation]    [PRIVATE]   attach UE is expected to fail
    ...     :Autor: Sylvia Schneider
    ...     :param ${UE}:   number of UE
    [Arguments]     ${UE}
    Attach UE to LTE    ue_id=${UE}
    Sleep    2s
    run keyword and ignore error    ute_wtssim.execute egate command and wait for data
    ...           cmd=ue_dc_enb_start ue=${UE} target_gnb=2 target_cells=1 bearer=2 type=split_scg   alias=ap_egate
    Sleep    2s


Detach UE
    [Arguments]    ${actual_UE}
    Log to Console    \nDetach UE ${actual_UE}
    Detach UE from LTE     ue_id=${actual_UE}


Create a Test Scenario Folder
    ${tc_name}    Fetch From Right   ${TEST NAME}     ${SPACE}
    Set Test Variable      ${resultDir}    ${resultBaseDir}/${tc_name}
    create directory    ${resultDir}
    Set Test Variable      ${traceDir}    ${resultDir}/traces
    create directory    ${traceDir}


Get test variables and upload start SCF
    ${allGlobalVariables} =    Get Variables
    Get testline specific data
    get scf coam                           ${resultBaseDir}    SCFC_start.xml
    get nrbts distname from SCF            ${resultBaseDir}/SCFC_start.xml
    get pmcadm distname from SCF           ${resultBaseDir}/SCFC_start.xml


Create Test Suite Folders
    ${timeStamp}    robot.libraries.DateTime.get current date    result_format=%Y%m%d_%H%M%S
    Set Suite Variable    ${resultBaseDir}    ${OUTPUT_DIR}/${SUITE_NAME}/0000/${timeStamp}
    create directory    ${resultBaseDir}
    testline.Set Console Output


Wait until coam gNB to be onair state and cells enabled
    [Documentation]    [PRIVATE]   on classical gnb check and wait, that all created cells are enabled
    ...     :Autor: Sylvia Schneider
    admin.connect_to
    ...    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    name=gnb
    ${scf_content}     admin.get_scf    parameters_save_variant=actualValues
    ...                                 connection=gnb
    ...                                 timeout=${30}
    ...                                 with_auto_configured_parameters=${True}

    ${list_cells}      string.Get Regexp Matches    ${scf_content}    class="com.nokia.srbts.nrbts:NRCELL"
    ${num_of_cells}    collections.Count Values In List  ${list_cells}   class="com.nokia.srbts.nrbts:NRCELL"
    Wait Cell Enabled with COAM    ${num_of_cells}
    [Teardown]  admin.teardown    connection=gnb


Wait Cell Enabled with COAM
    [Documentation]    [PRIVATE]   check and wait, that all created cells are enabled
    ...     :Autor: Sylvia Schneider
    ...     :param ${num_of_cells}: number of created cells
    ...     :param ${timeout}: max time until cells must be enabled
    [Arguments]     ${num_of_cells}    ${timeout}=1200 sec
    Log To Console     \nwaiting for all cells having operationalState Enabled
    Wait until keyword succeeds     ${timeout}      20 sec
    ...     Compare number of enabled cells with number of cells with coam   ${num_of_cells}


Compare number of enabled cells with number of cells with coam
    [Documentation]    [PRIVATE]   on classical gnb verify if all created cells are enabled
    ...     :Autor: Sylvia Schneider
    ...     :param ${num_of_cells}: number of created cells
    [Arguments]     ${num_of_cells}
    Log To Console     .   no_newline=true
    @{cell_status}=     admin.get_cells_info     connection=gnb
    ${num_of_enabled_cells}    set variable   ${0}
    FOR    ${index}    IN RANGE    ${num_of_cells}
        &{temp}    set variable  ${cell_status}[${index}]
        &{temp1}    get from dictionary    ${temp}    status
        ${value}    Get From Dictionary    ${temp1}    operationalState
        List Should Contain Value    ${operationalState_enabled}    ${value}
        ${num_of_enabled_cells}    Evaluate             ${num_of_enabled_cells}+1
    END
    Should Be True   '${num_of_cells}'=='${num_of_enabled_cells}'    msg=${num_of_enabled_cells} Cell(s) of ${num_of_cells} Enabled


restore parameter values with full commissioning
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    restore SCF coam


restore SCF coam
    [Documentation]    [PRIVATE] restore SCF on classical gnb
    ...     :Autor: Sylvia Schneider
    admin.connect_to
    ...    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    name=gnb
    admin.Perform Commissioning
    ...   scf_file=${resultBaseDir}/SCFC_start.xml
    ...   skip_parameter_relation_errors=False
    ...   should_activate=${TRUE}
    ...   timeout=660
    ...   connection=gnb
    admin.teardown    connection=gnb


Collect snapshot and sos report data
    [Documentation]    [PRIVATE]    save snapshot and sos report
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${store_dir}
    Run keyword and ignore error     Check TL connectivity and PDU status
    Log To Console    \ncollecting snapshot data and storing in directory ${store_dir}/snapshot
    Create Directory    ${store_dir}/snapshot
    Collect snapshot from gNB    target_dir=${store_dir}/snapshot
    Log To Console    \ncollecting sos report data and storing in directory ${store_dir}/sosreport
    Create Directory    ${store_dir}/sosreport
    Collect sos report logs      target_dir=${store_dir}/sosreport
    Set Suite Variable     ${logs_collected}       True


Collect snapshot
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    generate AP sosReport
    Create Directory    ${resultBaseDir}/snapshot
    Log To Console     \nsnapshot save directory "${resultBaseDir}/snapshot"
    Collect snapshot coam


generate AP sosReport
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    Log To Console     \nstarting sos report in order to get AP logs, save directory "${resultBaseDir}/sosreport"
    Create Directory    ${resultBaseDir}/sosreport
    Collect sos report logs   target_dir=${resultBaseDir}/sosreport
    Log To Console     \nsos report finished


Collect snapshot coam
    [Documentation]    [PRIVATE]   collect snapshot on classical coam gnb
    ...     :Autor: Sylvia Schneider
    Log To Console    \nsnapshot coam started
    admin.connect_to
    ...    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    name=gnb

    admin.get snapshot
    ...    target_file_name=${resultBaseDir}/snapshot/snapshot.zip
    ...    coverage=Full
    ...    force=True
    ...    timeout=240
    ...    connection=gnb

    admin.teardown    connection=gnb
    Log To Console    \nsnapshot coam finished

