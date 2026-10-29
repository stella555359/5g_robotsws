*** Settings ***
Documentation
...      todo:clean


*** Keywords ***
Get test variables and upload start SCF Ext01
    import variables        %{ABSTRACT_LIB_CONFIG}
    ${allGlobalVariables} =    Get Variables
    Run keyword and ignore error    Check TL Infos

    ${gnbs_count} =   Get Length  ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnbs_count}
       # range: cloud, classical    -- info from init: CloudBts, ClassicalBts
       ${temp}=    get from dictionary          ${P_GNBTYPE}    gnb_${gnb_id}
       set suite variable    ${gnb_${gnb_id}_bts_type}     ${temp}
       log to console    \ngnb_${gnb_id} bts_type contains "${gnb_${gnb_id}_bts_type}"

       #range: coam, cloud_coam
       ${temp}=    get from dictionary          ${P_OAMTYPE}    gnb_${gnb_id}
       set suite variable    ${gnb_${gnb_id}_oam_type}     ${temp}
       log to console    \ngnb_${gnb_id} oam_type contains "${gnb_${gnb_id}_oam_type}"

       Get testline specific data Ext01    gnb_id=${gnb_id}
       run keyword     get scf ${gnb_${gnb_id}_oam_type} ext01   gnb_id=${gnb_id}   dir=${resultBaseDir}   scf=SCFC_start_gnb_${gnb_id}.xml

       Run keyword if    '${realEnb}' == 'true' and '${NO_ENB}' == 'False'
       ...    Get scf enb ext01    enb_id=${gnb_id}   dir=${resultBaseDir}    scf=SCFC_start_enb_${gnb_id}.xml

       extract nrbts distname from SCF Ext01    gnb_id=${gnb_id}
       extract pmcadm distname from SCF Ext01   gnb_id=${gnb_id}
       Run keyword if    '${realEnb}' == 'true' and '${NO_ENB}' == 'False'
       ...    extract lnbts distname from SCF    enb_id=${gnb_id}
    END

Get testline specific data Ext01
    [Documentation]    [PRIVATE]    get specific data for testline: bts_type, gnb_sw_version, oam_type, ue_type, eNB data
    ...       :Autor: Sylvia Schneider
    ...       :ext01  Gerard Bonhaure   to manage multi gNB
    [Arguments]    ${gnb_id}=0

    #sw version from DU
    Run Keyword If   '${gnb_${gnb_id}_oam_type}' == 'cloud_coam'    Fetch cloud COAM SW version of all DUs    gnb_id=${gnb_id}
    Run Keyword If   '${gnb_${gnb_id}_oam_type}' == 'cloud_coam'    show DU sw version                      gnb_id=${gnb_id}
    ...         ELSE                              show classical sw version ext01                gnb_id=${gnb_id}

    #sw version from CU
    Run Keyword If    '${gnb_${gnb_id}_oam_type}' == 'cloud_coam'   Get and display sw version from CU Ext01   gnb_id=${gnb_id}

    #range: viavi, qualcomm, airphone   -- info from init: TM500, Android, Airphone
    # ${ue_type}=    get from dictionary          ${P_UETYPE}    ue_0
    # set suite variable    ${ue_type}
    # log to console    \nue_type contains "${ue_type}"

    #param realEnb set - range: true, false
    keywordbook-2056.Get eNB data    enb_id=${gnb_id}

Get and display sw version from CU Ext01
    [Documentation]    [PRIVATE]     get sw version of cloud gnb CU and display
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}:      gnb instance id in init file
    [Arguments]    ${gnb_id}=0
    Fetch cloud COAM SW version of CU               gnb_id=${gnb_id}
    ${temp}=    get from dictionary          ${P_GNBSWVERSION}    gnb_${gnb_id}_cu
    set suite variable     ${gnb_${gnb_id}_cu_swVersion}    ${temp}
    log to console     \ngnb${gnb_id} cu sw version is "${gnb_${gnb_id}_cu_swVersion}"

get scf cloud_coam ext01
    [Documentation]    [PRIVATE]    get config scf of CU and DU from cloud gNB coam
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :name of uploaded CU SCF:    CU_${scf}
    ...     :name of uploaded DU SCF:    DU<du_id>_${scf}
    ...     :param ${gnb_id}: gNB instance id
    ...     :param ${dir}: directory where the file is stored
    ...     :param ${scf}: name of stored scf file
    [Arguments]	   ${gnb_id}=0    ${dir}=${resultDir}    ${scf}=SCFC.xml
    upload cloud coam SCF CU       dir=${dir}    scf=${scf}    gnb_id=${gnb_id}
    upload cloud coam all SCF DU   dir=${dir}    scf=${scf}    gnb_id=${gnb_id}

get scf coam ext01
    [Documentation]    [PRIVATE]     get config scf from classical gNB
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    ...     :param ${dir}: directory where the file is stored
    ...     :param ${scf}: name of stored scf file
    [Arguments]   ${gnb_id}=0   ${dir}=${resultDir}    ${scf}=SCFC.xml
    BuiltIn.log to console     \nstarting coam_get_scf ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    BuiltIn.log to console     \n saving file to ${dir}/${scf}
    admin.connect_to
    ...    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...    name=gnb
    BuiltIn.Log To Console     \nget scf started
    ${path_SCF}     admin.get current scf file
    ...    ${dir}
    ...    ${scf}
    ...    timeout=120
    ...    connection=gnb
    BuiltIn.Log To Console     \nget scf finished
    [Teardown]        admin.teardown    connection=gnb

get scf enb ext01
    [Documentation]    [PRIVATE]     get config scf from eNB
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   duplicate function to manage multi eNB
    ...     :param ${enb_id}: eNB instance id
    ...     :param ${dir}: directory where the file is stored
    ...     :param ${scf}: name of stored scf file
    [Arguments]   ${enb_id}=0   ${dir}=${resultDir}    ${scf}=SCFC.xml
    BuiltIn.log to console     \nstarting enb_get_scf ${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}
    BuiltIn.log to console     \n saving file to ${dir}/${scf}
    admin.connect_to
    ...    bts_host=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}
    ...    name=enb
    BuiltIn.Log To Console     \nget scf started
    ${path_SCF}     admin.get current scf file
    ...    ${dir}
    ...    ${scf}
    ...    timeout=10
    ...    connection=enb
    BuiltIn.Log To Console     \nget scf finished
    [Teardown]        admin.teardown    connection=enb

extract nrbts distname from SCF Ext01
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]	   ${gnb_id}=0
    Run Keyword If      '${gnb_${gnb_id}_oam_type}' == 'cloud_coam'       get nrbts distname from SCF CU DU ext01   gnb_id=${gnb_id}
    ...         ELSE    get nrbts distname from SCF ext01      ${resultBaseDir}/SCFC_start_gnb_${gnb_id}.xml   gnb_id=${gnb_id}

extract pmcadm distname from SCF Ext01
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]	   ${gnb_id}=0
    Run Keyword If      '${gnb_${gnb_id}_oam_type}' == 'cloud_coam'       get pmcadm distname from SCF CU DU ext01   gnb_id=${gnb_id}
    ...         ELSE    get pmcadm distname from SCF ext01      ${resultBaseDir}/SCFC_start_gnb_${gnb_id}.xml    gnb_id=${gnb_id}

get nrbts distname from SCF CU DU ext01
    [Documentation]    [PRIVATE]    for coam cloud gnb
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    get nrbts distname from SCF ext01    ${resultBaseDir}/CU_SCFC_start_gnb_${gnb_id}.xml    ${gnb_id}    CU
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
        get nrbts distname from SCF ext01    ${resultBaseDir}/DU${du_id}_SCFC_start_gnb_${gnb_id}.xml   ${gnb_id}   DU    ${du_id}
    END

get pmcadm distname from SCF CU DU ext01
    [Documentation]    [PRIVATE]    for coam cloud gnb
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    get pmcadm distname from SCF ext01    ${resultBaseDir}/CU_SCFC_start_gnb_${gnb_id}.xml    ${gnb_id}    CU
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
        get pmcadm distname from SCF ext01   ${resultBaseDir}/DU${du_id}_SCFC_start_gnb_${gnb_id}.xml   ${gnb_id}   DU   ${du_id}
    END

get nrbts distname from SCF ext01
    [Documentation]    [PRIVATE]     extract nrbts distname from SCF
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${scf_file}: SCF file with path
    ...     :param ${gnb_id}: gNB instance id
    ...     :param ${unit}:  used only for cloud coam gnb - CU or DU
    ...     :param ${du_id}: used only for cloud coam DU - DU instance
    [Arguments]       ${scf_file}   ${gnb_id}=0    ${unit}=${EMPTY}      ${du_id}=${EMPTY}

    ${parsed_SCF}    parse xml     ${scf_file}
    ${xpath}         get from dictionary    ${xpath_vars_SCF}    distName_NRBTS
    ${nrbts_dist}    get element attribute    ${parsed_SCF}    distName    xpath=${xpath}
    ${splitted_mrbts_distName}   ${splitted_nrbts_distName}=     Split String From Right  ${nrbts_dist}   /   1

    Run Keyword If   '${gnb_${gnb_id}_oam_type}' == 'cloud_coam' and '${unit}' == 'CU'
    ...       set suite variable    ${gnb_${gnb_id}_CU_bts_distName}     ${nrbts_dist}
    ...   ELSE IF   '${gnb_${gnb_id}_oam_type}' == 'cloud_coam' and '${unit}' == 'DU'
    ...       set suite variable    ${gnb_${gnb_id}_DU${du_id}_bts_distName}     ${nrbts_dist}
    ...   ELSE
    ...       set suite variable    ${gnb_${gnb_id}_bts_distName}        ${nrbts_dist}
    Run Keyword If   '${gnb_${gnb_id}_oam_type}' == 'cloud_coam' and '${unit}' == 'CU'
    ...       set suite variable    ${gnb_${gnb_id}_CU_mrbts_distName}   ${splitted_mrbts_distName}
    ...   ELSE IF   '${gnb_${gnb_id}_oam_type}' == 'cloud_coam' and '${unit}' == 'DU'
    ...       set suite variable    ${gnb_${gnb_id}_DU${du_id}_mrbts_distName}   ${splitted_mrbts_distName}
    ...   ELSE
    ...       set suite variable    ${gnb_${gnb_id}_mrbts_distName}      ${splitted_mrbts_distName}
    Run Keyword If   '${gnb_${gnb_id}_oam_type}' == 'cloud_coam' and '${unit}' == 'CU'
    ...       set suite variable    ${gnb_${gnb_id}_CU_nrbts_distName}   ${splitted_nrbts_distName}
    ...   ELSE IF   '${gnb_${gnb_id}_oam_type}' == 'cloud_coam' and '${unit}' == 'DU'
    ...       set suite variable    ${gnb_${gnb_id}_DU${du_id}_nrbts_distName}     ${splitted_nrbts_distName}
    ...   ELSE
    ...       set suite variable    ${gnb_${gnb_id}_nrbts_distName}      ${splitted_nrbts_distName}
    Log to console    \ngnb_${gnb_id} ${unit}_${du_id} bts_distName: "${nrbts_dist}"
    Log to console    \ngnb_${gnb_id} ${unit}_${du_id} mrbts_distName: "${splitted_mrbts_distName}"
    Log to console    \ngnb_${gnb_id} ${unit}_${du_id} nrbts_distName: "${splitted_nrbts_distName}"

get pmcadm distname from SCF ext01
    [Documentation]    [PRIVATE]     extract pmcadm distname from SCF
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${scf_file}: SCF file with path
     ...     :param ${gnb_id}: gNB instance id
    ...     :param ${unit}: used only for cloud coam gnb - CU or DU
    ...     :param ${du_id}: used only for cloud coam DU - DU instance
    [Arguments]       ${scf_file}   ${gnb_id}=0   ${unit}=${EMPTY}   ${du_id}=${EMPTY}
    ${parsed_SCF}    parse xml     ${scf_file}
    ${xpath}         get from dictionary    ${xpath_vars_SCF}    distName_PMCADM
    ${pmcadm_dist}    get element attribute    ${parsed_SCF}    distName    xpath=${xpath}
    Run Keyword If        '${gnb_${gnb_id}_oam_type}' == 'cloud_coam' and '${unit}' == 'CU'
    ...       set suite variable   ${gnb_${gnb_id}_CU_pmcadm_distName}    ${pmcadm_dist}
    ...   ELSE IF   '${gnb_${gnb_id}_oam_type}' == 'cloud_coam' and '${unit}' == 'DU'
    ...       set suite variable   ${gnb_${gnb_id}_DU${du_id}_pmcadm_distName}    ${pmcadm_dist}
    ...   ELSE
    ...       set suite variable   ${gnb_${gnb_id}_pmcadm_distName}    ${pmcadm_dist}
    Log to console    \ngnb_${gnb_id} ${unit}_${du_id} pmcadm_distName: "${pmcadm_dist}"

show classical sw version ext01
    [Documentation]    [PRIVATE]     show sw version of classical gnb and set suite variable
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}:      gnb instance in init file
    [Arguments]    ${gnb_id}=0
    ${gnb_swVersion}    Get from dictionary    ${P_GNBSWVERSION}    gnb_${gnb_id}
    set suite variable    ${gnb_swVersion}
    log to console    \ngnb_${gnb_id}_swVersion contains "${gnb_swVersion}"

json delta commissioning coam ext01
    [Documentation]    [PRIVATE]   delta commissioning coam
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${param_list}: list of dictionaries containing parameters and values, which are updated
    ...     :param ${gnb_id}:      gnb instance in init file
    [Arguments]     ${param_list}     ${gnb_id}=0
    admin.connect_to
    ...    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...    name=gnb
    BuiltIn.Log To Console    \ndelta commissioning started on gnb_${gnb_id}
    ${update_status}    ${delta_store_file}    Update List of SCF parameters
    ...    parameters=${param_list}
    ...    timeout=600
    ...    alias=gnb
    admin.teardown    connection=gnb
    BuiltIn.Log To Console    delta commissioning finished


Wait until coam gNB to be onair state and cells enabled ext01
    [Documentation]    [PRIVATE]   on classical gnb check and wait, that all created cells are enabled
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}:            gnb instance in init file
    ...     :param ${num_of_disabled_cells}  number od created cells which are not enabled
    [Arguments]     ${gnb_id}   ${num_of_disabled_cells}=0
    admin.connect_to
    ...    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    name=gnb
    ${scf_content}     admin.get_scf  parameters_save_variant=actualValues    connection=gnb    timeout=${30}
    ${list_cells}      string.Get Regexp Matches    ${scf_content}    class="com.nokia.srbts.nrbts:NRCELL"
    ${num_of_cells}    collections.Count Values In List  ${list_cells}   class="com.nokia.srbts.nrbts:NRCELL"
    Wait Cell Enabled with COAM ext01
    ...      gnb_id=${gnb_id}   num_of_cells=${num_of_cells}   num_of_disabled_cells=${num_of_disabled_cells}
    [Teardown]  admin.teardown    connection=gnb

Wait Cell Enabled with COAM ext01
    [Documentation]    [PRIVATE]   check and wait, that all created cells are enabled
    ...     :Autor: Sylvia Schneider
    ...     :param ${num_of_cells}: number of created cells
    ...     :param ${timeout}: max time until cells must be enabled
    ...     :ext01  Gerard Bonhaure   to manage multi gNB and any disabled cells
    ...     :param ${gnb_id}: gnb instance in init file
    ...     :param ${num_of_disabled_cells}: number of not enable cells among created cells
    [Arguments]     ${gnb_id}   ${num_of_cells}   ${num_of_disabled_cells}    ${timeout}=1200 sec
    BuiltIn.Log To Console     \nWaiting for all cells having operationalState Enabled
    Wait until keyword succeeds     ${timeout}      20 sec
    ...     Compare number of enabled cells with number of cells with ${gnb_${gnb_id}_oam_type} ext01
    ...     ${num_of_cells}   ${num_of_disabled_cells}
    BuiltIn.Log To Console     All cells operationalState Enabled\n

Compare number of enabled cells with number of cells with coam ext01
    [Documentation]    [PRIVATE]   on classical gnb verify if all created cells are enabled
    ...     :Autor: Sylvia Schneider
    ...     :param ${num_of_cells}: number of created cells
    ...     :ext01  Gerard Bonhaure   to manage multi gNB and any disabled cells
    ...     :param ${num_of_disabled_cells}: number of not enable cells among created cells
    [Arguments]     ${num_of_cells}    ${num_of_disabled_cells}
    BuiltIn.Log To Console     .   no_newline=true
    @{cell_status}=     admin.get_cells_info     connection=gnb
    # set test variable   ${num_of_enabled_cells}   0
    ${num_of_enabled_cells}  set variable    0
    FOR    ${index}    IN RANGE    ${num_of_cells}
        &{temp}    set variable  ${cell_status}[${index}]
        &{temp1}    get from dictionary    ${temp}    status
        ${cell_operationalState}   Get From Dictionary   ${temp1}    operationalState
        ${num_of_enabled_cells}
        ...    Run keyword if    '${cell_operationalState}'=='enabled' or '${cell_operationalState}'=='Enabled'
        ...            Evaluate    ${num_of_enabled_cells}+1
    END
    ${real_num_of_cells}    Evaluate    ${num_of_cells}-${num_of_disabled_cells}
    Should Be True   '${real_num_of_cells}'=='${num_of_enabled_cells}'    msg=${num_of_enabled_cells} Cell(s) of ${real_num_of_cells} Enabled

Collect PM Counters ext01
    [Documentation]    [PRIVATE]   collect pm counter files
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}:      gnb instance in init file
    [Arguments]    ${gnb_id}=0     ${time_before_detach}=${EMPTY}

    #bypass robocop
    ${time_before_detach}=    Set Variable    ${time_before_detach}
    Run Keyword If    '${gnb_${gnb_id}_oam_type}' == 'coam'
    ...        Collect PM Counters file and filter last file coam ext01    gnb_id=${gnb_id}
    ...    ELSE
    ...        Collect PM Counters file CU DU ext01    gnb_id=${gnb_id}

Collect PM Counters file and filter last file coam ext01
    [Documentation]    [PRIVATE]   collect pm counter files for coam classical gnb
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}:      gnb instance in init file
    [Arguments]    ${gnb_id}=0
    Collect PM Counters file coam ext01    gnb_id=${gnb_id}
    Filter last PM Counters file coam ext01    gnb_id=${gnb_id}

Collect PM Counters file CU DU ext01
    [Documentation]    [PRIVATE]   collect pm counter files for coam cloud gnb
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}:      gnb instance in init file
    [Arguments]    ${gnb_id}=0
   Collect pm counter file CU ext01    gnb_id=${gnb_id}
   Collect pm counter file for all DU ext01    gnb_id=${gnb_id}

Collect pm counter file for all DU ext01
    [Documentation]    [PRIVATE]   collect pm counter files for coam cloud gnb for all DUs
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
        Create Directory    ${resultDir}/counter_gNB${gnb_id}_DU${du_id}
        Collect pm counter file DU ext01    gnb_id=${gnb_id}    du_id=${du_id}
    END

Collect pm counter file DU ext01
    [Documentation]    [PRIVATE]   collect pm counter files for coam cloud gnb for single DU
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    ...     :param ${du_id}: DU instance id
    [Arguments]    ${gnb_id}=0    ${du_id}=0
    ${name}    Set Variable     counter_gNB${gnb_id}_DU${du_id}

    BuiltIn.Log To Console    \nuploading pm file from coam GNB${gnb_id} DU${du_id} and store in directory :
    BuiltIn.Log To Console    ${resultDir}/${name}
    Create Directory    ${resultDir}/${name}
    ${webservice}				Create Dictionary
    ...            host=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_ip}
    ...            user=Nemuadmin
    ...            password=nemuuser
    ...            port=443

    tafpmcounters.create pm collector
    ...    name=${name}
    ...    webservice=${webservice}
    ...    oam_type=coam
    tafpmcounters.setup collectors
    ...    names=${name}
    tafpmcounters.collect collectors
    ...    names=${name}
    ...    target_dir=${resultDir}
    tafpmcounters.teardown collectors
    ...    names=${name}

Collect pm counter file CU ext01
    [Documentation]    [PRIVATE]   collect pm counter files for coam cloud gnb for CU
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    BuiltIn.Log To Console    \nuploading pm file from gNB${gnb_id} coam CU and store in directory ${resultDir}/counter_gNB${gnb_id}_CU
    Create Directory    ${resultDir}/counter_gNB${gnb_id}_CU
    BuiltIn.Wait Until Keyword Succeeds    30    5
    ...    ssh.connect to    ${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...                      ${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                      ${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ...                      alias=OAM-local-conn
    ssh.execute  ls -r ${path_CU_pm_files} > /tmp/dir_allPmFileCu.txt  connection=OAM-local-conn
	  ssh.Download File    /tmp/dir_allPmFileCu.txt   ${resultDir}/counter_gNB${gnb_id}_CU/dir_allPmFileCu.txt    connection=OAM-local-conn
    ${pm_file_list}    Get File     ${resultDir}/counter_gNB${gnb_id}_CU/dir_allPmFileCu.txt
    ${last_pm_file_name}   Get Line     ${pm_file_list}     2
    ${last_pm_file_dateTime}   Get Regexp Matches    ${last_pm_file_name}     -(\\d{8}\\.\\d{4})+
    ssh.execute   cd ${path_CU_pm_files}; tar cvf /tmp/cu_pm.tar -C ${path_CU_pm_files}/ *@{last_pm_file_dateTime}[0]*   connection=OAM-local-conn
    ssh.Download File    /tmp/cu_pm.tar   ${resultDir}/counter_gNB${gnb_id}_CU/cu_pm.tar      connection=OAM-local-conn
    ${rc}    Run And Return Rc    cd ${resultDir}/counter_gNB${gnb_id}_CU; tar xvf cu_pm.tar
    ${result}    set variable if    '${rc}'=='${0}'    pass    fail
    run keyword if     '${result}'=='fail'    Fail    ERROR - counter CU PM file
    ${local_pm_gz_files}    List Files In Directory    ${resultDir}/counter_gNB${gnb_id}_CU     *.gz
    FOR    ${file}   IN    @{local_pm_gz_files}
        Run    gunzip ${resultDir}/counter_gNB${gnb_id}_CU/${file}
    END
    [Teardown]    BuiltIn.Run Keyword And Ignore Error    ssh.disconnect    connection=OAM-local-conn

Filter PM Counters file coam CU ext01
    [Documentation]    [PRIVATE]   filter last pm counter files for coam cloud gnb for CU
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${meas_type}: gnB pm counter measurement id
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${meas_type}    ${gnb_id}=0
    ${local_pm_xml_files}    List Files In Directory    ${resultDir}/counter_gNB${gnb_id}_CU     *.xml
    ${result}    set Variable       ${EMPTY}
    FOR    ${file}   IN    @{local_pm_xml_files}
        ${result}       OperatingSystem.Grep File     ${resultDir}/counter_gNB${gnb_id}_CU/${file}     ${meas_type}
        ${length_result}        Get Length        ${result}
        Continue For Loop If         ${length_result}==0
        Set Test Variable     ${pmCounter_xml_file_CU_${meas_type}}     ${resultDir}/counter_gNB${gnb_id}_CU/${file}
        Exit For Loop
    END
    Variable Should Exist   ${pmCounter_xml_file_CU_${meas_type}}     ERROR - no counter CU ${meas_type} PM file
    BuiltIn.Log To Console    \nCU counter ${meas_type} pm file: ${pmCounter_xml_file_CU_${meas_type}}

Collect PM Counters file coam ext01
    [Documentation]    [PRIVATE]   collect pm counter files for coam classical gnb
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    ${name}    Set Variable     counter_gNB${gnb_id}

    BuiltIn.Log To Console    \nuploading gNB${gnb_id} pm file from coam
    ${webservice}				Create Dictionary
    ...            host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...            user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...            password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...            port=443

    tafpmcounters.create pm collector
    ...    name=${name}
    ...    webservice=${webservice}
    ...    oam_type=sbts
    tafpmcounters.setup collectors
    ...    names=${name}
    tafpmcounters.collect collectors
    ...    names=${name}
    ...    target_dir=${resultDir}
    tafpmcounters.teardown collectors
    ...    names=${name}

Filter last PM Counters file coam ext01
    [Documentation]    [PRIVATE]   filter last pm counter files for coam classical gnb
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${resultDir}/counter_gNB${gnb_id}/ | grep PM.*ANY.xml
    ${result}    set variable if    '${rc}'=='${0}'    pass    fail
    run keyword if     '${result}'=='fail'    Fail    no measurement file available
    ${temp}    split to lines    ${all_pm_file}
    ${pm_file_name}    set variable    ${temp[0]}
    ${pm_file_name_with_path}    set variable    ${resultDir}/counter_gNB${gnb_id}/${pm_file_name}

    Move File    ${pm_file_name_with_path}    ${resultDir}/
    Run       rm -rf /tmp/counter_gNB${gnb_id}
    Move directory    ${resultDir}/counter_gNB${gnb_id}   /tmp/counter_gNB${gnb_id}
    Move File    ${resultDir}/${pm_file_name}   ${resultDir}/counter_gNB${gnb_id}/

  # BHR begin: with pyhton 27 --> 38 upgrade ${file_string} is considered as binary
  # ${file_string}   Get Binary File   ${pm_file_name_with_path}
    ${binary_string}   Get Binary File   ${pm_file_name_with_path}
    ${file_string}     Decode Bytes To String   bytes=${binary_string}  encoding=UTF-8   errors=ignore
  # BHR end
    ${file_string}  Replace String    ${file_string}  ><  >\n<   count=-1
    Create File    ${resultDir}/counter_gNB${gnb_id}/pm.xml    ${file_string}

    BuiltIn.Set Suite Variable    ${pmCounter_xml_file_gNB${gnb_id}}    ${resultDir}/counter_gNB${gnb_id}/pm.xml
    [Return]     ${pmCounter_xml_file_gNB${gnb_id}}

Filter last PM Counters file coam DU ext01
    [Documentation]    [PRIVATE]   filter last pm counter files for coam cloud gnb for DU
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    ...     :param ${du_id}: DU instance id
    [Arguments]    ${gnb_id}    ${du_id}=0
    ${rc}   ${all_pm_file}   Run And Return Rc And Output   ls -r ${resultDir}/counter_gNB${gnb_id}_DU${du_id}/ | grep PM.*ANY.xml
    ${result}    set variable if    '${rc}'=='${0}'    pass    fail
    run keyword if     '${result}'=='fail'    Fail    no measurement file available on DU ${du_id}
    ${temp}    split to lines    ${all_pm_file}
    ${pm_file_name}    set variable    ${temp[0]}
    ${pm_file_name_with_path}    set variable    ${resultDir}/counter_gNB${gnb_id}_DU${du_id}/${pm_file_name}

    Move File    ${pm_file_name_with_path}    ${resultDir}/
    Move directory    ${resultDir}/counter_gNB${gnb_id}_DU${du_id}   /tmp/counter_gNB${gnb_id}_DU${du_id}
    Move File    ${resultDir}/${pm_file_name}   ${resultDir}/counter_gNB${gnb_id}_DU${du_id}/

    ${file_string}   Get Binary File   ${pm_file_name_with_path}
    ${file_string}  Replace String    ${file_string}  ><  >\n<   count=-1
    Create File    ${resultDir}/pm${du_id}.xml    ${file_string}

    BuiltIn.Set Test Variable    ${pmCounter_xml_file}    ${resultDir}/pm${du_id}.xml


Verify Counter Ext01
    [Documentation]    [PRIVATE]   verify counter expected value and value from pm file
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${counterName}: name of counter e.g M55114C00001
    ...     :param ${counterList}: list containing details of counter
    ...     :param ${parsed_PmFile}: pm file in which counter is searched for
    ...     :param ${unit}: empty if classical gnb, CU if cloud coam CU, DU if cloud coam DU
    ...     :param ${du_id}: DU instance id
    ...     :param ${gnb_id}: gNB instance id
    ...     :param ${operation_type} type of verification between ctr val and expected ctr val range: egal, upper
    [Arguments]    ${counterName}    ${counterList}    ${parsed_PmFile}      ${unit}=${EMPTY}      ${du_id}=0   ${gnb_id}=0
    ${counter_text}             Set Variable    ${counterList}[0]
    ${counter_expectedValue}    Set Variable    ${counterList}[1]
    ${counter_gnb}              Set Variable    ${counterList}[2]
    ${counter_cell}             Set Variable    ${counterList}[3]
    ${counter_meastype}         Set Variable    ${counterList}[4]
    ${operation_type}           Set Variable    ${counterList}[5]

    ${temp}=      Get Variable Value    ${gnb_${gnb_id}_oam_type}
    ${temp1}      Get Variable Value    ${oam_type}
    ${oam}=       Set Variable If       '${temp}' == 'None' and '${temp1}' != 'None'
    ...    ${oam_type}       other
    Run Keyword If   '${oam}' != 'other'     Set Suite Variable     ${gnb_${gnb_id}_oam_type}    ${oam}

    ${temp}=      Get Variable Value    ${gnb_${gnb_id}_CU_bts_distName}
    ${temp1}=     Get Variable Value    ${CU_bts_distName}
    ${cudist}=    Set Variable If       '${temp}' == 'None' and '${temp1}' != 'None'
    ...    ${CU_bts_distName}       other
    Run Keyword If    '${cudist}' != 'other'     Set Suite Variable   ${gnb_${gnb_id}_CU_bts_distName}    ${cudist}

    ${temp}=      Get Variable Value    ${gnb_${gnb_id}_DU${du_id}_bts_distName}
    ${temp1}=     Get Variable Value    ${DU${du_id}_bts_distName}
    ${dudist}=    Set Variable If       '${temp}' == 'None' and '${temp1}' != 'None'
   ...    ${DU${du_id}_bts_distName}      other
    Run Keyword If    '${dudist}' != 'other'   Set Suite Variable    ${gnb_${gnb_id}_DU${du_id}_bts_distName}    ${dudist}

    ${temp}=      Get Variable Value    ${gnb_${gnb_id}_bts_distName}
    ${temp1}=     Get Variable Value   ${bts_distName}
    ${dist}=      Set Variable If    '${temp}' == 'None' and '${temp1}' != 'None'    ${bts_distName}   other
    Run Keyword If    '${dist}' != 'other'     Set Suite Variable    ${gnb_${gnb_id}_bts_distName}    ${dist}

    ${counter_distName}
    ...  Run Keyword If
    ...   '${gnb_${gnb_id}_oam_type}' == 'cloud_coam' and '${unit}' == 'CU' and '${counter_cell}' == '${EMPTY}'
    ...        Set Variable  PLMN-PLMN/${gnb_${gnb_id}_CU_bts_distName}
    ...    ELSE IF       '${gnb_${gnb_id}_oam_type}' == 'cloud_coam' and '${unit}' == 'CU'
    ...        Set Variable    PLMN-PLMN/${gnb_${gnb_id}_CU_bts_distName}/${counter_cell}
    ...    ELSE IF       '${gnb_${gnb_id}_oam_type}' == 'cloud_coam' and '${unit}' == 'DU'
    ...        Set Variable    PLMN-PLMN/${gnb_${gnb_id}_DU${du_id}_bts_distName}/${counter_cell}

    ...    ELSE IF       '${gnb_${gnb_id}_oam_type}' == 'coam' and '${counter_cell}' == '${EMPTY}'
    ...        Set Variable    PLMN-PLMN/${gnb_${gnb_id}_bts_distName}
    ...    ELSE
    ...        Set Variable    PLMN-PLMN/${gnb_${gnb_id}_bts_distName}/${counter_cell}

    ${xpath_param}=    get from dictionary    ${xpath_vars_pmCounter}    counter_pmFile_${gnb_${gnb_id}_oam_type}${unit}
    ${xpath_param}    replace variables    ${xpath_param}
    ${counter_value_from_pm_xml}    get element text     ${parsed_PmFile}        xpath=${xpath_param}

    ${result}    Run Keyword If
    ...    '${operation_type}' == 'egal'
    ...        Set Variable If    ${counter_value_from_pm_xml}==${counter_expectedValue}    Passed    Failed
    ...    ELSE IF   '${operation_type}' == 'upper'
    ...        Set Variable If    ${counter_value_from_pm_xml}>${counter_expectedValue}     Passed    Failed
    ${msg1}         Set Variable      \ncounter ${counterName} "${counter_text}" for cell ${counter_cell}
    ${msg2}         Set Variable      pm file value ${counter_value_from_pm_xml} == expectedValue ${counter_expectedValue}\n
    Run Keyword If    '${result}'=='Passed'    BuiltIn.Log to console    ${msg1} passed: ${msg2}
    Run Keyword If    '${result}'=='Failed'    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    report pm counter
    ...   id=${counterName}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}

restore parameter values with full commissioning ext01
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ${gnbs_count} =   Get Length  ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnbs_count}
        Run Keyword If    '${gnb_${gnb_id}_oam_type}' == 'coam' and '${DEBUG}'=='False'
        ...        restore SCF coam ext01    gnb_id=${gnb_id}
        ...    ELSE IF    '${gnb_${gnb_id}_oam_type}' == 'cloud_coam' and '${DEBUG}'=='False'
        ...        restore SCF CU DU ext01    gnb_id=${gnb_id}
        ...    ELSE IF    '${DEBUG}'=='True'
        ...        Log To Console    \nDEBUG mode : no restoration needed !!!
        ...    ELSE
        ...        Log To Console     \nERROR : No SCF restoration possible !!!
    END

    Return From Keyword If           '${NO_ENB}' == 'True'
    ${enbs_count} =   Get Length  ${tl.enbs}
    FOR    ${enb_id}    IN RANGE    ${enbs_count}
        keywordbook-2056.Get eNB data    enb_id=${enb_id}
        Run Keyword If    '${realEnb}' == 'true' and '${DEBUG}'=='False'
        ...    restore SCF eNB ext01    enb_id=${enb_id}    scf=SCFC_start_enb_${enb_id}.xml
    END


restore SCF coam ext01
    [Documentation]    [PRIVATE] restore SCF on classical gnb
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]     ${gnb_id}=0
    builtIn.Log To Console    \nfull commissioning on coam gnb-${gnb_id} started
    admin.connect_to
    ...    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...    name=gnb
    admin.perform_commissioning
    ...   scf_file=${resultBaseDir}/SCFC_start_gnb_${gnb_id}.xml
    ...   skip_parameter_relation_errors=True
    ...   should_activate=${TRUE}
    ...   timeout=660
    ...   connection=gnb
    admin.teardown    connection=gnb
    builtIn.Log To Console    full commissioning on coam gnb-${gnb_id} finished

restore SCF eNB ext01
    [Documentation]    [PRIVATE] restore SCF on eNB
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi eNB
    ...     :param ${enb_id}: eNB instance id
    ...     :param ${scf}: scf file name
    [Arguments]     ${enb_id}=0    ${scf}=SCFC_start_enb_0.xml
    builtIn.Log To Console    \nfull commissioning on enb-${enb_id} started
    admin.connect_to
    ...    bts_host=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}
    ...    name=enb
    admin.perform_commissioning
    ...   scf_file=${resultBaseDir}/${scf}
    # ...   scf_file=${resultBaseDir}/SCFC_start_enb_${enb_id}.xml
    ...   skip_parameter_relation_errors=True
    ...   should_activate=${TRUE}
    ...   timeout=660
    ...   connection=enb
    admin.teardown    connection=enb
    builtIn.Log To Console    \nfull commissioning on enb-${enb_id} scf ${scf} finished

restore SCF CU DU ext01
    [Documentation]    [PRIVATE] restore SCFs on cloud coam gnb
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]     ${gnb_id}=0
    restore SCF CU ext01       gnb_id=${gnb_id}
    restore SCF all DU ext01   gnb_id=${gnb_id}

restore SCF CU ext01
    [Documentation]    [PRIVATE]    restore CU SCF
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]     ${gnb_id}=0
    BuiltIn.Log To Console     \nfull commissioning of CU
    BuiltIn.Log To Console     ${SPACE*3}using CU SCF ${resultBaseDir}/CU_SCFC_start_gnb_${gnb_id}.xml
    BuiltIn.Log To Console     ${SPACE*3}starting upload to gNB
    ${oam_alias}   connect.Setup OAM session	gnb_id=${gnb_id}    component=CU
    ${result_upload}    coam_cu.upload_plan_file    ${resultBaseDir}/CU_SCFC_start_gnb_${gnb_id}.xml    connection=${oam_alias}
    Teardown OAM session	component=CU    connection=${oam_alias}
    wait until keyword succeeds    60s   5s  check if CU Plan Upload successful
    ...    ${result_upload["action_id"]}
    BuiltIn.Log To Console     ${SPACE*3}starting validate of plan file
    ${oam_alias}   connect.Setup OAM session	gnb_id=${gnb_id}    component=CU
    ${validate_result}   coam_cu.plan_validation    ${result_upload["plan_id"]}   connection=${oam_alias}
    Teardown OAM session	component=CU    connection=${oam_alias}
    wait until keyword succeeds    60s   5s  check if CU Plan Validate successful
    ...    ${result_upload["plan_id"]}
    ...    ${validate_result["action_id"]}
    BuiltIn.Log To Console     ${SPACE*3}starting activation of plan file
    ${oam_alias}   connect.Setup OAM session	gnb_id=${gnb_id}    component=CU
    ${activate_result}   coam_cu.plan_activation   ${result_upload["plan_id"]}   connection=${oam_alias}
    Teardown OAM session	component=CU    connection=${oam_alias}
    wait until keyword succeeds    300s   30s  check if CU Plan Activate successful
    ...    ${result_upload["plan_id"]}
	...    ${activate_result["id"]}
    BuiltIn.Log To Console     full commissioning of CU SCF finished

restore SCF all DU ext01
    [Documentation]    [PRIVATE]    restore all DU SCF
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
         restore SCF DU ext01    ${gnb_id}   ${du_id}
    END

restore SCF DU ext01
    [Documentation]    [PRIVATE]    restore SCF on DU with instance ${du_id}
    ...     :Autor: Sylvia Schneider
    ...     :ext01  Gerard Bonhaure   to manage multi gNB
    ...     :param ${gnb_id}: gNB instance id
    ...     :param ${du_id}: du instance id
    [Arguments]    ${gnb_id}=0   ${du_id}=0
    builtIn.Log To Console    \nfull commissioning on gnb-${gnb_id} DU-${du_id} started
    ${alias_du}    connect oam DU   gnb_id=${gnb_id}   du_id=${du_id}
    admin.perform_commissioning
    ...   scf_file=${resultBaseDir}/DU${du_id}_SCFC_start_gnb_${gnb_id}.xml
    ...   skip_parameter_relation_errors=True
    ...   should_activate=${TRUE}
    ...   timeout=660
    ...   connection=${alias_du}
    builtIn.Log To Console    full commissioning on gnb-${gnb_id} DU-${du_id} finished
    [Teardown]    disconnect oam DU    alias_du=${alias_du}

Collect snapshot ext01
    [Documentation]    [PRIVATE]
    ...     :Autor: Sylvia Schneider
    Run Keyword If     '${realEnb}'=='false'    generate AP sosReport
    ${gnbs_count} =   Get Length  ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnbs_count}
        Create Directory    ${resultBaseDir}/snapshot_gnb_${gnb_id}
        BuiltIn.Log To Console     \nsnapshot save directory "${resultBaseDir}/snapshot_gnb_${gnb_id}"
        Run Keyword If    '${gnb_${gnb_id}_oam_type}' == 'coam'     Collect snapshot coam ext01    gnb_id=${gnb_id}
        ...         ELSE                                            Collect snapshot CU DU ext01   gnb_id=${gnb_id}
    END

Collect snapshot CU DU ext01
    [Documentation]    [PRIVATE]   collect snapshot on cloud coam gnb for CU and all DUs
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    ${oam_alias}   connect.Setup OAM session	gnb_id=${gnb_id}    component=CU
    BuiltIn.Log To Console     \nsnapshot on CU started
    coam_cu.get_local_snapshot    ${resultBaseDir}/snapshot_gnb_${gnb_id}    180     600   connection=${oam_alias}
    BuiltIn.Log To Console     snapshot on CU finished
    Teardown OAM session	component=CU    connection=${oam_alias}
    collect snapshot all DU ext01     gnb_id=${gnb_id}

collect snapshot all DU ext01
    [Documentation]    [PRIVATE]   collect snapshot on cloud coam gnb for all DUs
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    ${du_num}=    Get length    ${tl.gnbs[${gnb_id}].dus}
    FOR    ${du_id}    IN RANGE    ${du_num}
        collect snapshot DU ext01    ${gnb_id}   ${du_id}
    END

collect snapshot DU ext01
    [Documentation]    [PRIVATE]  collect snapshot on DU with instance ${du_id}
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    ...     :param ${du_id}: du instance id
    [Arguments]    ${gnb_id}=0   ${du_id}=0
    builtIn.Log To Console    \nsnapshot on DU ${du_id} started
    ${alias_du}    connect oam DU   gnb_id=${gnb_id}   du_id=${du_id}
    ${path_SCF}     admin.get snapshot
    ...    target_file_name=${resultBaseDir}/snapshot_gnb_${gnb_id}/DU${du_id}_snapshot.zip
    ...    coverage=Full
    ...    force=True
    ...    timeout=600
    ...    connection=${alias_du}
    disconnect oam DU    alias_du=${alias_du}
    BuiltIn.Log To Console    \nsnapshot on DU ${du_id} finished

Collect snapshot coam ext01
    [Documentation]    [PRIVATE]   collect snapshot on classical coam gnb
    ...     :Autor: Sylvia Schneider
    ...     :param ${gnb_id}: gNB instance id
    [Arguments]    ${gnb_id}=0
    builtIn.Log To Console    \nsnapshot coam started gnb gnb_${gnb_id}
    admin.connect_to
    ...    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...    name=gnb

    ${path_SCF}     admin.get snapshot
    ...    target_file_name=${resultBaseDir}/snapshot_gnb_${gnb_id}/snapshot.zip
    ...    coverage=Full
    ...    force=True
    ...    timeout=240
    ...    connection=gnb

    admin.teardown    connection=gnb
    BuiltIn.Log To Console    snapshot coam finished for gnb gnb_${gnb_id}

Start wireshark gnb ext01
    [Documentation]    Starts TcpDump on gNB OAM on interface (default=fronthaul)
    ...     :Author: Soenke Kullberg
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param option: (default="") Addtional options for tcpdump
    ...     :param interface: (default=fronthaul) Interface of gNB OAM for tcpdump
    ...     :param collector: (default gnb-${gnb_id}-oam-${interface}-tcpdump)  Name of collector *Impact on log filename*
    ...
    [Arguments]     ${gnb_id}=0        ${option}=${EMPTY}    ${interface}=any  ${collector}=gnb-${gnb_id}-oam-${interface}-tcpdump
    &{gnb_oam_ssh}=  Create Dictionary
    ...     host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...     user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...     password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    &{gnb_cpif_ssh}    Create Dictionary
    ...  host=cpif-0.local
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ...  proxy=${gnb_oam_ssh}
    ${executor}    Set Variable If    '${gnb_${gnb_id}_oam_type}' == 'cloud_coam'    ${gnb_cpif_ssh}    ${gnb_oam_ssh}
    ${interface}   Set variable If    '${gnb_${gnb_id}_oam_type}' == 'cloud_coam'    x2                 any

    tcpdump.create_tcpdump_collector
    ...     name=${collector}
    ...     options=-i ${interface} ${option}
    ...     executor=${executor}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias     ${collector}
    [Return]    ${collector}

Stop wireshark gnb ext01
    [Arguments]     ${collector}=none
    Run Keyword And Continue On Failure  tcpdump.stop_collectors
    ...    names=${collector}
    BuiltIn.Sleep    1s
    Run Keyword And Continue On Failure  tcpdump.collect_collectors
    ...    names=${collector}
    ...    target_dir=${resultDir}
    Run Keyword And Continue On Failure  tcpdump.teardown_collectors
    ...    names=${collector}

Stop wireshark gnb ext02
    [Arguments]     ${collector}=none    ${file_name}=none
    Run Keyword And Continue On Failure  tcpdump.stop_collectors
    ...    names=${collector}
    BuiltIn.Sleep    1s
    Run Keyword And Continue On Failure  tcpdump.collect_collectors
    ...    names=${collector}
    ...    target_dir=${resultDir}
    Run Keyword And Continue On Failure  tcpdump.teardown_collectors
    ...    names=${collector}
    Run Keyword And Continue On Failure   Move File
    ...    ${resultDir}/${collector}    ${resultDir}/${file_name}

Start wireshark LTE ext01
    [Documentation]    for real LTE eNB
    [Arguments]   ${enb_id}=0
    &{lte_oam_ssh}    Create Dictionary
    ...  host=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.addr}
    ...  user=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.username}
    ...  password=${tl.enbs[${enb_id}].airscale.common_units[0].lmp_connection.password}

    tcpdump.create_tcpdump_collector
    ...     name=lte_x2_dump
    ...     options=-i br1.${source_enb_vlan_id}
    ...     executor=${lte_oam_ssh}

    tcpdump.Set Suite Alias     lte_x2_dump

    tcpdump.setup_collectors
    ...    names=lte_x2_dump
    tcpdump.start_collectors
    ...    names=lte_x2_dump

Stop wireshark LTE ext01
    Run Keyword And Continue On Failure  tcpdump.stop_collectors
    ...    names=lte_x2_dump
    BuiltIn.Sleep    1s
    Run Keyword And Continue On Failure  tcpdump.collect_collectors
    ...    names=lte_x2_dump
    ...    target_dir=${resultDir}
    Run Keyword And Continue On Failure  tcpdump.teardown_collectors
    ...    names=lte_x2_dump
    Run Keyword And Continue On Failure  Move File    ${resultDir}/lte_x2_dump/lte_x2_dump.pcap    ${resultDir}/S1X2.pcap

wait for next measurement interval ext01
    [Arguments]    ${additional-waiting-time}=70s    ${is_reduce_waiting-time}=false    ${waiting-time_thresold}=7
    @{act_time}    Get Time    hour min sec
    ${min}    set variable    ${act_time[1]}
    ${minute}    convert to integer    ${min}
    ${int}    Evaluate    int(${minute}/${measurement_period_in_min})
    ${CSV-creation-interval-begin}    Evaluate    int(${minute}/${measurement_period_in_min}) * ${measurement_period_in_min}
    ${waiting-time}    Evaluate    ${CSV-creation-interval-begin}+${measurement_period_in_min}-${minute}
    Run keyword if    ${waiting-time} > ${waiting-time_thresold} and '${is_reduce_waiting-time}' == 'true'
    ...    Return From Keyword    ${waiting-time}
    Sleep    ${waiting-time} minutes
    Sleep    ${additional-waiting-time}


SetFlagOnSwConfig ext01
    [Arguments]       ${flag}      ${value}   ${gnb_id}=0
    ${asik_cnx}       BuiltIn.Wait Until Keyword Succeeds    30    5
    ...               ssh.connect to    ${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...                      ${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                      ${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ...                      alias=OAM-local-conn

    swconf.set_flag
    ...     ${asik_cnx}
    ...     /ffs/run/swconfig.txt
    ...     ${flag}
    ...     ${value}

    ssh.disconnect  connection=${asik_cnx}
