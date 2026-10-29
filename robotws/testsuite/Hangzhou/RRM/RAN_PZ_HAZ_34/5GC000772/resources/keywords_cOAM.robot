*** Settings ***
Library     taf.sbts.oam.coam.admin                WITH NAME    coam
Library     taf.config.scf                         WITH NAME    scf
Library     taf.transport.ssh                      WITH NAME    ssh
Library     String
Library     OperatingSystem
Library     DateTime
Library     XML
Library     Collections
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot 

*** Variables ***
${qc_test_set_name}    CDRX_CPRI features
${qc_test_set_path}    Root\\Test_Sets\\Trunk\\Regression\\SRAN_ENG2_PZ_HZ\\SRAN_ENG2_PZ_HZ_2 

${GN_OAM_ADDR}=                 ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${GN_OAM_USR}=                  ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${GN_OAM_PWD}=                  ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${GN_WEBUI}=                    https://${GN_OAM_ADDR}
${TL_Number}=                   ${tl.gnbs[0].instance_id}
# Modif 09/07 creation of IP address to reach ASIK locally
${GN_WEBUI_ASIK}=               192.168.255.129

${GN_WEBUI_user}=               Nemuadmin
${GN_WEBUI_pwd}=                nemuuser

# CV36 elements:
${CV36_NRBTS}=                  MRBTS-36/NRBTS-23116
${CV36_NRCELL_1}=               MRBTS-36/NRBTS-23116/NRCELL-1
${CV36_NRCELL_2}=               MRBTS-36/NRBTS-23116/NRCELL-2
${CV36_NSA_NRBTS}=              MRBTS-10036/NRBTS-23116
${CV36_NSA_NRCELL_1}=           MRBTS-10036/NRBTS-23116/NRCELL-1
${CV36_NSA_NRCELL_2}=           MRBTS-10036/NRBTS-23116/NRCELL-2
${CV36_SA_NRBTS}=               MRBTS-36/NRBTS-23116
${CV36_SA_NRCELL_1}=            MRBTS-36/NRBTS-23116/NRCELL-1
${CV36_SA_NRCELL_2}=            MRBTS-36/NRBTS-23116/NRCELL-2

# CV39 elements:
${CV39_NRBTS}=                  MRBTS-39/NRBTS-23178
${CV39_NRCELL_1}=               MRBTS-39/NRBTS-23178/NRCELL-1
${CV39_NRCELL_2}=               MRBTS-39/NRBTS-23178/NRCELL-2
${CV39_NSA_NRBTS}=              MRBTS-39/NRBTS-23178
${CV39_NSA_NRCELL_1}=           MRBTS-39/NRBTS-23178/NRCELL-1
${CV39_NSA_NRCELL_2}=           MRBTS-39/NRBTS-23178/NRCELL-2
${CV39_SA_NRBTS}=               MRBTS-39/NRBTS-23138
${CV39_SA_NRCELL_1}=            MRBTS-39/NRBTS-23138/NRCELL-1
${CV39_SA_NRCELL_2}=            MRBTS-39/NRBTS-23138/NRCELL-2

# CV49 elements:
${CV49_NRCELL_1}=               MRBTS-49/NRBTS-23154/NRCELL-1
${CV49_NRCELL_2}=               MRBTS-49/NRBTS-23154/NRCELL-2
${CV49_NRBTS}=                  MRBTS-49/NRBTS-23154

# CV1992 elements:
${CV1992_NRBTS}=                  MRBTS-19290/NRBTS-10290
${CV1992_NRCELL_1}=               MRBTS-10290/NRBTS-10290/NRCELL-1
${CV1992_NSA_NRBTS}=              MRBTS-10290/NRBTS-10290
${CV1992_NSA_NRCELL_1}=           MRBTS-10290/NRBTS-10290/NRCELL-1
${CV1992_SA_NRBTS}=               MRBTS-10290/NRBTS-10290
${CV1992_SA_NRCELL_1}=            MRBTS-10290/NRBTS-10290/NRCELL-1
 

# CV1991 elements:
${CV1991_NRBTS}=                  MRBTS-1991/NRBTS-10289
${CV1991_NRCELL_1}=               MRBTS-1991/NRBTS-10289/NRCELL-1
${CV1991_NSA_NRBTS}=              MRBTS-1991/NRBTS-10289
${CV1991_NSA_NRCELL_1}=           MRBTS-1991/NRBTS-10289/NRCELL-1
${CV1991_SA_NRBTS}=               MRBTS-1991/NRBTS-10289
${CV1991_SA_NRCELL_1}=            MRBTS-1991/NRBTS-10289/NRCELL-1
 

# CV1998 elements:
${CV1998_NRBTS}=                  MRBTS-1998/NRBTS-10294
${CV1998_NRCELL_1}=               MRBTS-1998/NRBTS-10294/NRCELL-1
${CV1998_NSA_NRBTS}=              MRBTS-1998/NRBTS-10294
${CV1998_NSA_NRCELL_1}=           MRBTS-1998/NRBTS-10294/NRCELL-1
${CV1998_SA_NRBTS}=               MRBTS-1998/NRBTS-10294
${CV1998_SA_NRCELL_1}=            MRBTS-1998/NRBTS-10294/NRCELL-1

# CV63 elements_AEQA:
${CV63_dBFCSV_Directory}        ${CURDIR}/../Feature_523/dBFCSV_Directory
${CV63_SCF_directory}           ${CURDIR}/../Feature_523/SCF_directory
${CV63_Swconfig_Directory}      ${CURDIR}/../Feature_523/Swconfig_Directory
${CV63_TDDtimer_Directory}      ${CURDIR}/../Feature_523/TDDtimer_Directory

#CV63 elements_AEQN
#${CV63_dBFCSV_Directory}         ${CURDIR}/../Feature_523/dBFCSV_Directory
${CV63_SCF_AEQN_directory}        ${CURDIR}/../Feature_523/SCF_directory
#${CV63_Swconfig_Directory}       ${CURDIR}/../Feature_523/Swconfig_Directory

# CV36 elements AEQA:
${CV36_dBFCSV_Directory}        ${CURDIR}/../Feature_772/dBFCSV_Directory
${CV36_SCF_directory}           ${CURDIR}/../Feature_772/SCF_Directory
${CV36_Swconfig_Directory}      ${CURDIR}/../Feature_772/Swconfig_Directory

# CV39 elements AEQA:
${CV39_dBFCSV_Directory}        ${CURDIR}/../FGCR_3077B/dBFCSV_Directory
${CV39_SCF_directory}           ${CURDIR}/../FGCR_3077B/SCF_Directory
${CV39_Swconfig_Directory}      ${CURDIR}/../FGCR_3077B/Swconfig_Directory

#CV29 elements_AEQA
${CV29_dBFCSV_Directory}         ${CURDIR}/../Feature_523/dBFCSV_Directory
${CV29_SCF_directory}            ${CURDIR}/../Feature_523/SCF_directory
${CV29_Swconfig_Directory}       ${CURDIR}/../Feature_523/Swconfig_Directory

# Richard - 07 avril 2020 -
# Mise en commentaire de ces parametres qui sont définis dans l environnement eCLAT de chaque TL
# Désolé si certains servaient vraiment, mais peut-etre devriez-vous mettre à jour votre environnement eCLAT
#${GN_WEBUI}                     10.14.48.63
#${GN_OAM_USER}                  toor4nsn
#${GN_OAM_PSWD}                  oZPS0POrRieRtu
#${SCF}                          AEQN_L1R5.2_CV63_NodBF.xml
#${RU_ADDR}                      192.168.254.52
#${RU_USERNAME}                  root
#${RU_PASSWORD}                  root



*** Keywords ***

#######################################
# gNB SCF READ and WRITE
#######################################

gNB Get SCF Content
    [Documentation]     Get SCF content
    coam.connect_to     bts_host=${GN_OAM_ADDR}
    ${content}=         coam.get_current_scf_content
    [Return]            ${content}
    [Teardown]          coam.teardown


gNB Get Attribute value in SCF
    [Documentation]     Get element value in SCF content
    [Arguments]         ${dist_name}    ${p_name}
    ${content}=         gNB Get SCF Content
    ${xml_root}=        XML.Parse XML    ${content}
 
    
    ${result}=          XML.Get Element    ${xml_root}
    ...                 .//managedObject[@distName="${dist_name}"]/p[@name="${p_name}"]
    [Return]            ${result.text}


Check Cell Availability Status is online
    [Documentation]     Check cell status is online in WebEM
    [Arguments]         ${cell_number}
    coam_gnb_classical.Connect to gnb coam via ssl
    coam_gnb_classical.COAM Check GNB cell on air
    coam_gnb_classical.COAM Teardown gnb connections


WebUI gNB Set Attribute Value
	[Documentation]     Set gNB Param Value using webUI
    [Arguments]         ${dist_name}    ${p_name}    ${new_value}
    coam.connect_to     bts_host=${GN_OAM_ADDR}
    Log                 logged in webUI. begin modif of ${dist_name} ${p_name} to ${new_value}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${p_name}    operation=update
    ...                                       value=${new_value}    skip_parameter_relation_errors=False
    ...    timeout=600
    [Teardown]          coam.teardown


Perfom SCF commissioning
    [Documentation]
    [Arguments]         ${SCF}     ${SCF_directory}

    coam.connect_to              bts_host=${GN_OAM_ADDR}   name=coam_admin
    coam.perform_commissioning   ${SCF_directory}/${SCF}   skip_parameter_relation_errors=False  connection=coam_admin
    ...  timeout=600
    [Teardown]                   coam.teardown             connection=coam_admin

Check Cell Status
    coam.connect_to          bts_host=${GN_OAM_ADDR}   name=coam_admin
    @{cells_info}=           coam.get_cells_info       cell_type=nr     connection=coam_admin
    Log                      \nCells_info: ${cells_info[0]['status']['operationalState']}
    FOR    ${elem}    IN    @{cells_info}
         Should contain     ${elem['status']['operationalState']}      Enabled
         Should contain     ${elem['status']['availabilityStatus']}    Online
    END
    [Teardown]               coam.teardown             connection=coam_admin


Check Cell Status Operational state
    coam.connect_to          bts_host=${GN_OAM_ADDR}   name=coam_admin
    @{cells_info}=           coam.get_cells_info       cell_type=nr     connection=coam_admin
    Log                      \nCells_info: ${cells_info[0]['status']['operationalState']}
    FOR    ${elem}    IN    @{cells_info}
         Should contain     ${elem['status']['operationalState']}      Enabled
    END
    [Teardown]               coam.teardown             connection=coam_admin


#######################################
# FEATURES ACTIVATION-DEACTIVATION
#######################################

WebEM Activate Feature 772
    [Documentation]     Activate the Feature 772 (common DRX) using the webUI
    [Arguments]         ${cell_number}
    Check Cell Availability Status is online    ${cell_number}
    sleep               1s
    ${CurrentValue}     gNB Get Attribute value in SCF     dist_name=${CV${TL_Number}_NRCELL_${cell_number}}
    ...                 p_name=actCDrx
    Run Keyword if      '${CurrentValue}'=='false'         Activate Feature 772    ${cell_number}
    sleep               1s


Activate Feature 772
    [Arguments]         ${cell_number}
    wait until keyword succeeds    2x    5s
    ...     WebUI gNB Set Attribute Value    dist_name=${CV${TL_Number}_NRCELL_${cell_number}}    p_name=actCDrx
    ...     new_value=true
    ${ModifiedValue}    gNB Get Attribute value in SCF     dist_name=${CV${TL_Number}_NRCELL_${cell_number}}
    ...                 p_name=actCDrx
    should be equal     true    ${ModifiedValue}
    sleep               1s
    Check Cell Availability Status is online    ${cell_number}


WebEM Deactivate Feature 772
    [Documentation]     Deactivate the Feature 772 (common DRX) using the webUI
    [Arguments]         ${cell_number}
    Check Cell Availability Status is online    ${cell_number}
    sleep    1s
    ${CurrentValue}     gNB Get Attribute value in SCF     dist_name=${CV${TL_Number}_NRCELL_${cell_number}}
    ...                 p_name=actCDrx
    Run Keyword if      '${CurrentValue}'=='true'          Deactivate Feature 772    ${cell_number}
    sleep               1s


Deactivate Feature 772
    [Arguments]         ${cell_number}
    wait until keyword succeeds    2x    5s
    ...     WebUI gNB Set Attribute Value    dist_name=${CV${TL_Number}_NRCELL_${cell_number}}    p_name=actCDrx
    ...    new_value=false
    ${ModifiedValue}    gNB Get Attribute value in SCF     dist_name=${CV${TL_Number}_NRCELL_${cell_number}}
    ...    p_name=actCDrx
    should be equal     false    ${ModifiedValue}
    sleep               1s
    Check Cell Availability Status is online    ${cell_number}


WebEM Activate Feature 578
    [Documentation]     Activate the Feature 578 (SRB3) using the webUI
    ${distName}=        catenate                          ${CV${TL_Number}_NRBTS}
    ${CurrentValue}     gNB Get Attribute value in SCF    dist_name=${distName}        p_name=srb3SupportEnabled
    Run Keyword if      '${CurrentValue}'=='false'        Activate Feature 578         dist_name=${distName}


Activate Feature 578
    [Arguments]         ${distName}
    wait until keyword succeeds    2x    5s
    ...     WebUI gNB Set Attribute Value    dist_name=${CV${TL_Number}_NRBTS}    p_name=srb3SupportEnabled
    ...    new_value=true
    ${ModifiedValue}    gNB Get Attribute value in SCF    dist_name=${CV${TL_Number}_NRBTS}  p_name=srb3SupportEnabled
    should be equal     true    ${ModifiedValue}
    sleep               1s


WebEM Deactivate Feature 578
    [Documentation]     Deactivate the Feature 578 (SRB3) using the webUI
    ${distName}=        catenate                          ${CV${TL_Number}_NRBTS}
    ${CurrentValue}     gNB Get Attribute value in SCF    dist_name=${distName}        p_name=srb3SupportEnabled
    Run Keyword if     '${CurrentValue}'=='true'          Deactivate Feature 578       dist_name=${distName}


Deactivate Feature 578
    [Arguments]         ${distName}
    wait until keyword succeeds    2x    5s
    ...     WebUI gNB Set Attribute Value    dist_name=${distName}    p_name=srb3SupportEnabled    new_value=false
    ${ModifiedValue}    gNB Get Attribute value in SCF    dist_name=${distName}    p_name=srb3SupportEnabled
    should be equal     false    ${ModifiedValue}
    sleep               1s


#######################################
# 772 DRX feature Keywords
#######################################

WebEM Change DRX Parameters
    [Documentation]                  Change one or more DRX parameters via the webUI
    [Arguments]                      ${CellId}=1
    ...                              ${drxInactivityTimer}=10ms
    ...                              ${drxLongCycle}=40ms
    ...                              ${drxOnDurationTimer}=10ms
    ...                              ${drxRetransTimerDl}=16slot
    ...                              ${drxRetransTimerUl}=16slot

    # Create the DRX parameters list
    ${dict}=    create dictionary    drxInactivityTimer=${drxInactivityTimer}
    ...                              drxLongCycle=${drxLongCycle}
    ...                              drxOnDurationTimer=${drxOnDurationTimer}
    ...                              drxRetransTimerDl=${drxRetransTimerDl}
    ...                              drxRetransTimerUl=${drxRetransTimerUl}
    ${NewValue}=    Create list      ${dict}

    # New DRX parameters setup:
    Log                              New DRX parameters will be: ${NewValue}
    WebUI gNB Set Attribute Value    dist_name=${CV${TL_Number}_NRCELL_${CellId}}    p_name=drxProfile1
    ...    new_value=${NewValue}
    sleep                            1s

    # Get the new DRX parameters values:
    Log                              Get all DRX parameters values
    ${new_DRX_parameters}=           WebEM Get All DRX Parameters    ${CellId}

    # Read and check all DRX parameters one by one:
    ${read_param_0}=                 Get From List           ${new_DRX_parameters}    0
    should be equal                  ${read_param_0.text}    ${drxInactivityTimer}
    ${read_param_1}=                 Get From List           ${new_DRX_parameters}    1
    should be equal                  ${read_param_1.text}    ${drxLongCycle}
    ${read_param_2}=                 Get From List           ${new_DRX_parameters}    2
    should be equal                  ${read_param_2.text}    ${drxOnDurationTimer}
    ${read_param_3}=                 Get From List           ${new_DRX_parameters}    3
    should be equal                  ${read_param_3.text}    ${drxRetransTimerDl}
    ${read_param_4}=                 Get From List           ${new_DRX_parameters}    4
    should be equal                  ${read_param_4.text}    ${drxRetransTimerUl}


WebEM Get All DRX Parameters
    [Documentation]                  Read all DRX parameters via the webUI
    [Arguments]                      ${CellId}=1
    # Get and parse the SCF
    ${content}=                      gNB Get SCF Content
    ${xml_root}=                     XML.Parse XML    ${content}

    # Get all DRX parameters from WebEM
    ${drx_parameters}=               XML.Get Child Elements    ${xml_root}
    ...    .//managedObject[@distName="${CV${TL_Number}_NRCELL_${CellId}}"]/list[@name="drxProfile1"]/item

    # Read all parameters one by one:
    ${drxInactivityTimer}=           Get From List    ${drx_parameters}    0
    ${drxLongCycle}=                 Get From List    ${drx_parameters}    1
    ${drxOnDurationTimer}=           Get From List    ${drx_parameters}    2
    ${drxRetransTimerDl}=            Get From List    ${drx_parameters}    3
    ${drxRetransTimerUl}=            Get From List    ${drx_parameters}    4
    Log                              DRX Parameters are :
    Log                              drxInactivityTimer: ${drxInactivityTimer.text}
    Log                              drxLongCycle : ${drxLongCycle.text}
    Log                              drxOnDurationTimer: ${drxOnDurationTimer.text}
    Log                              drxRetransTimerDl : ${drxRetransTimerDl.text}
    Log                              drxRetransTimerUl : ${drxRetransTimerUl.text}

    # Return the parameters list:
    [Return]                         ${drx_parameters}


Select The Drx Counters Ratio
    coam.connect_to                    bts_host=${GN_OAM_ADDR}
    ${SW_Version}=                     coam.get_sw_version
    Run Keyword if                     '5G19A' in '${SW_Version}'     Set DRX Ratio For 5G19A Load
    Run Keyword if                     '5G19B' in '${SW_Version}'     Set DRX Ratio For 5G19B Load
    Run Keyword if                     '5G20A' in '${SW_Version}'     Set DRX Ratio For 5G20A Load
    coam.teardown


Set DRX Ratio For 5G20A Load
    Log                                A 5G20A has been detected
    set suite variable                 ${firstRatio_Min}      23
    set suite variable                 ${firstRatio_Max}      28
    set suite variable                 ${secondRatio_Min}     11
    set suite variable                 ${secondRatio_Max}     22


Set DRX Ratio For 5G19B Load
    Log                                A 5G19B has been detected
    set suite variable                 ${firstRatio_Min}      23
    set suite variable                 ${firstRatio_Max}      28
    set suite variable                 ${secondRatio_Min}     11
    set suite variable                 ${secondRatio_Max}     22


Set DRX Ratio For 5G19A Load
    Log                                A 5G19A has been detected
    set suite variable                 ${firstRatio_Min}      23
    set suite variable                 ${firstRatio_Max}      27
    set suite variable                 ${secondRatio_Min}     11
    set suite variable                 ${secondRatio_Max}     14


#######################################
# COUNTERS
#######################################

WebEM Get XML Counter Files
    [Documentation]                  Get the list of all XML files containing the PM counters
    [Arguments]                      ${GN_OAM_ADDR}

    ssh.Connect To                   ${GN_OAM_ADDR}    ${GN_OAM_USR}    ${GN_OAM_PWD}    alias=asik_master
    ${result}=                       ssh.Execute       command=ls /tmp | grep PM.BTS.*.gz | sort
    ...                                                connection=asik_master
    ssh.Disconnect                   connection=asik_master
    @{files_list}=                   Split String    ${result}    ${\n}
    ${xmlList}=                      mylibpython.cOamCreateXMLFilesList    ${files_list}
    [Return]                         ${xmlList}


WebEM Download XML files
    [Documentation]                  Download all files of xmlList from asik master and put them in localPath
    [Arguments]                      ${GN_OAM_ADDR}       ${xmlList}    ${localPath}

    ssh.Connect To                   ${GN_OAM_ADDR}    ${GN_OAM_USR}    ${GN_OAM_PWD}    alias=asik_master
    FOR    ${file}     IN           @{xmlList}
           ssh.Execute              command=gunzip -k /tmp/${file}    connection=asik_master
           ${file}=                 replace string    ${file}    .gz    ${EMPTY}
           ssh.Download File        remote_path=/tmp/${file}    local_path=${localPath}/${file}
           ...    connection=asik_master
           ssh.Execute              command=rm -f /tmp/${file}    connection=asik_master
    END
    [Teardown]                       ssh.Disconnect    connection=asik_master


WebEM Get Drx Counter Value
    [Documentation]                  For each time slot
    [Arguments]                      ${xmlList}    ${xmlPathname}    ${timeSlot}    ${counterName}

    ${totalValue}=                   Evaluate        0
    FOR    ${element}               IN    @{timeSlot}
           ${Value}=                mylibpython.cOamGetPMCounterValue   ${xmlList}   ${xmlPathname}   ${element}
           ...   ${counterName}
           ${totalValue}=           Evaluate    ${totalValue} + ${Value}
    END
    [Return]                         ${totalValue}

WebEM Get Drx Counter Value II
    [Documentation]                  For each time slot
    [Arguments]                      ${xmlList}    ${xmlPathname}    ${timeSlot}    ${counterName}

    ${totalValue}=                   Evaluate        0
    FOR    ${element}               IN    @{timeSlot}
           ${Value}=                mylibpython.cOamGetPMCounterValue   ${xmlList}   ${xmlPathname}   ${element}
           ...   ${counterName}
           ${totalValue}=           Evaluate    ${totalValue} * ${Value}
    END
    [Return]                         ${totalValue}

WebEM Get Counter Value
    [Documentation]                  For each time slot
    [Arguments]                      ${xmlList}    ${xmlPathname}    ${timeSlot}    ${counterName}    ${cellName}
    ${totalValue}=          Evaluate   0
 
    FOR    ${element}       IN    @{timeSlot}
           ${Value}=        mylibpython.cOamGetPMCounterValueForSpecifiedCell  ${xmlList}  ${xmlPathname}  ${element}
           ...  ${counterName}  ${cellName}
           ${totalValue}=   Evaluate   ${totalValue} + ${Value}
    END
    [Return]                ${totalValue}

UTE Get XML Counter Files
    [Documentation]                  Get the list of all XML files containing the PM counters
    [Arguments]                      ${xml_path}

    ${result}=                       OperatingSystem.Run    ls ${xml_path} | sort
    @{files_list}=                   Split String    ${result}    ${\n}
    ${xmlList}=                      mylibpython.cOamCreateXMLFilesList    ${files_list}
    [Return]                         ${xmlList}

################################################################
# Ajout 523 for snapshot
################################################################
gNB Get snapshot coam
    [Documentation]    Get the snapshot
    [Arguments]        ${Snapshot_File}
    coam.connect_to    bts_host=${GN_OAM_ADDR}   name=Create_Snapshot
    coam.get_snapshot  target_file_name=${Snapshot_File}       coverage=Full
    ...                force=True     connection=Create_Snapshot    timeout=600s
    [Teardown]         Run keyword and continue on failure          coam.teardown     connection=Create_Snapshot
################################################################


Get list XML counter files
    [Documentation]     Get the list of all XML files containing the PM counters from the call
    [Arguments]         ${GN_OAM_ADDR}    ${StartCallDate}    ${EndCallDate}
    ssh.Connect To      ${GN_OAM_ADDR}    ${GN_OAM_USR}    ${GN_OAM_PWD}    alias=asik_master
    ${result}=          ssh.Execute       command=ls /tmp | grep PM.*.gz | sort
    ...                                   connection=asik_master
    ssh.Disconnect      connection=asik_master

    @{files_list}=      Split String        ${result}       ${\n}

    ${xmlList}=    mylibpython.filterXMLFilesList        ${files_list}         ${StartCallDate}        ${EndCallDate}
    [Return]            ${xmlList}


Download XML files
    [Documentation]     Download all files of xmlList from asik master and put them in localPath
    [Arguments]         ${GN_OAM_ADDR}    ${xmlList}    ${localPath}
    ssh.Connect To      ${GN_OAM_ADDR}    ${GN_OAM_USR}    ${GN_OAM_PWD}    alias=asik_master
    FOR    ${file}    IN    @{xmlList}
           ssh.Download File   remote_path=/tmp/node_0xe000/tmp/pm/reports/${file}   local_path=${localPath}/${file}
           ...   connection=asik_master
    END
    [Teardown]          ssh.Disconnect    connection=asik_master


Get Counter Value
    [Documentation]     Get the summed value of a counter in every XML files in xmlList
    [Arguments]         ${xmlList}    ${xmlPath}    ${counterName}
    ${sum}=     Catenate      0
    FOR    ${file}    IN    @{xmlList}
           ${root}=        Parse XML    ${xmlPath}/${file}
           ${Element}=     Get Element    ${root}    .//${counterName}
           ${Value}=       Get Element Text    ${Element}
           ${sum}=         Evaluate    ${sum} + ${Value}
           Log               ${Value}
    END
    Log                 ${sum}
    [Return]            ${sum}


Create Traces directory
    [Documentation]       Create the directory where all traces of the tests will be put
    ${StartTestDate}=     Get Current Date    result_format=%Y%m%d_%H%M%S
    CreateDirectory       /home/ute/traces/robot/${SUITE_NAME}_${StartTestDate}
    set suite variable    ${TRACES_DIRECTORY}    /home/ute/traces/robot/${SUITE_NAME}_${StartTestDate}


Connect to every modules classical
    [Documentation]     Connect to every modules in classical
    [Arguments]         ${GN_OAM_ADDR}
    ssh.Connect To      ${GN_OAM_ADDR}    ${GN_OAM_USR}    ${GN_OAM_PWD}    alias=fct0_a
    ssh.Connect To      192.168.253.17    ${GN_OAM_USR}    ${GN_OAM_PWD}    proxy=fct0_a    alias=fct0_b
    ssh.Connect To      192.168.253.20    ${GN_OAM_USR}    ${GN_OAM_PWD}    proxy=fct0_a    alias=aspa1_a
    ssh.Connect To      192.168.253.21    ${GN_OAM_USR}    ${GN_OAM_PWD}    proxy=fct0_a    alias=aspa1_b
    ssh.Connect To      192.168.253.22    ${GN_OAM_USR}    ${GN_OAM_PWD}    proxy=fct0_a    alias=aspa1_c


Disconnect every modules classical
    [Documentation]     Disconnect every modules in classical
    ssh.Disconnect      connection=aspa1_c
    ssh.Disconnect      connection=aspa1_b
    ssh.Disconnect      connection=aspa1_a
    ssh.Disconnect      connection=fct0_b
    ssh.Disconnect      connection=fct0_a


Get Journalctl classical
    [Documentation]     Download journalctl of every module
    [Arguments]         ${GN_OAM_ADDR}
    Connect to every modules classical    ${GN_OAM_ADDR}
    ${journal_fct0_a}=    ssh.Execute    command=journalctl --utc -o short-iso-precise -n 10000
    ...                   | cat connection=fct0_a    timeout=900
    Create File           ${TRACES_DIRECTORY}/journalctl_fct0_a.log    ${journal_fct0_a}
    ${journal_fct0_b}=    ssh.Execute    command=journalctl --utc -o short-iso-precise -n 10000
    ...                   | cat connection=fct0_b    timeout=900
    Create File           ${TRACES_DIRECTORY}/journalctl_fct0_b.log        ${journal_fct0_b}
    ${journal_aspa1_a}=   ssh.Execute     command=journalctl --utc -o short-iso -n 10000
    ...                   | cat connection=aspa1_a    timeout=900
    Create File           ${TRACES_DIRECTORY}/journalctl_aspa1_a.log        ${journal_aspa1_a}
    ${journal_aspa1_b}=   ssh.Execute     command=journalctl --utc -o short-iso -n 10000
    ...                   | cat connection=aspa1_b    timeout=900
    Create File           ${TRACES_DIRECTORY}/journalctl_aspa1_b.log        ${journal_aspa1_b}
    ${journal_aspa1_c}=   ssh.Execute     command=journalctl --utc -o short-iso -n 10000
    ...                   | cat connection=aspa1_c    timeout=900
    Create File           ${TRACES_DIRECTORY}/journalctl_aspa1_c.log        ${journal_aspa1_c}
    [Teardown]          Disconnect every modules classical


Start collecting pcap
    [Arguments]         ${GN_OAM_ADDR}    ${module}    ${interface}
    Connect to every modules classical    ${GN_OAM_ADDR}
    ssh.send command    command=tcpdump -i ${interface} -w /tmp/tcpdump_${module}_${interface}.pcap
    ...                 connection=${module}
    Disconnect every modules classical


Stop collecting pcap
    [Arguments]         ${GN_OAM_ADDR}    ${module}    ${interface}
    Connect to every modules classical    ${GN_OAM_ADDR}
    ssh.Execute    command=pkill -f "tcpdump -i ${interface}"    connection=${module}
    ssh.download file    /tmp/tcpdump_${module}_${interface}.pcap
    ...                  ${TRACES_DIRECTORY}/tcpdump_${module}_${interface}.pcap
    ...                  connection=${module}
    Disconnect every modules classical


#################################################################
#
# Gestion des scf, swconfig et autres csv beam files
#
#################################################################

dBF activation on AEQA
    [Arguments]          ${CSV}      ${SCF}      ${SWconfig}

    #Swconfig load and Crasign
    ssh.Connect To       ${GN_OAM_ADDR}    ${GN_OAM_USR}    ${GN_OAM_PWD}    alias=fct0_a
    ssh.Upload File      local_path=${CV63_Swconfig_Directory}/${SWconfig}        remote_path=/ffs/run/swconfig.txt
    ...   connection=fct0_a
    ssh.Execute          command=crasign /ffs/run/swconfig.txt               connection=fct0_a
    ssh.disconnect       fct0_a

    #SCF load
    Perfom SCF commissioning       ${SCF}     ${CV63_SCF_directory}
    Wait Until Keyword Succeeds    10m          60s        Check Cell Availability Status is online     1

    #bfloader
    ssh.Connect To       ${GN_OAM_ADDR}    ${GN_OAM_USR}    ${GN_OAM_PWD}    alias=fct0_a
    ssh.Connect To       192.168.254.54    root             umniedziala      alias=AEQA   proxy=fct0_a
    ssh.Upload File      local_path=${CV63_dBFCSV_Directory}/${CSV}    remote_path=/ram/${CSV}    connection=AEQA
    ssh.Execute          command=/mnt/scripts/bfloader -l gen3lf/BfCoefVector -w -f /ram/${CSV} -a fpga -o 0Xa00 -d 4
    ...  connection=AEQA
    ssh.disconnect       AEQA
    ssh.disconnect       fct0_a
    [Teardown]           coam.teardown     connection=coam_admin


dBF activation on AEQA CV36
    [Documentation]    Apply the SCF and the swconfig.txt files on ASIK board and the digitalBeamForming config on RU
    [Arguments]          ${CSV}    ${SCF}    ${SWconfig}    ${RUIpAddress}

    # Step 1 : swconfig load and crasign
    ssh.Connect To       ${GN_OAM_ADDR}    ${GN_OAM_USR}    ${GN_OAM_PWD}     alias=fct0_a
    ssh.Upload File      local_path=${CV36_Swconfig_Directory}/${SWconfig}    remote_path=/ffs/run/swconfig.txt
    ...   connection=fct0_a
    ssh.Execute          command=crasign /ffs/run/swconfig.txt                connection=fct0_a
    ssh.disconnect       fct0_a

    # Step2: SCF load
    Perfom SCF commissioning       ${SCF}        ${CV36_SCF_directory}
    Wait Until Keyword Succeeds    10m    60s    Check Cell Availability Status is online    1

    # Step3: bfloader on RU (updated by Richard 2020.04.09)
    ${bfPath}=           Catenate          /mnt/scripts
    ${bfScript}=         Catenate          ${bfPath}/${CSV}
    ssh.Connect To       ${GN_OAM_ADDR}    ${GN_OAM_USR}    ${GN_OAM_PWD}     alias=fct0_a
    ssh.Connect To       ${RUIpAddress}    root             umniedziala       alias=AEQA    proxy=fct0_a
    ssh.Upload File  local_path=${CV36_dBFCSV_Directory}/${CSV}    remote_path=${bfPath}/${CSV}    connection=AEQA
    ssh.Execute          command=chmod 777 ${bfScript}      connection=AEQA
    ssh.Execute    command=bfloader -l gen3lf/BfCoefVector -w -f ${bfScript} -a fpga -o 0Xa00 -d 4    connection=AEQA
    Log                  bfloader command returns: ${CmdReturn}
    sleep                1s
    ssh.disconnect       AEQA
    ssh.disconnect       fct0_a

    [Teardown]           coam.teardown     connection=coam_admin


dBF Setup on GNB CV39
    [Documentation]      Apply the SCF and the swconfig.txt files on CV39 ASIK board
    [Arguments]          ${SCF}    ${SWconfig}

    # Step 1 : swconfig load and crasign
    ssh.Connect To       ${GN_OAM_ADDR}    ${GN_OAM_USR}    ${GN_OAM_PWD}     alias=fct0_a
    ssh.Upload File      local_path=${CV39_Swconfig_Directory}/${SWconfig}    remote_path=/ffs/run/swconfig.txt
    ...   connection=fct0_a
    ssh.Execute          command=crasign /ffs/run/swconfig.txt                connection=fct0_a
    ssh.disconnect       fct0_a

    # Step2: SCF load
    Perfom SCF commissioning       ${SCF}        ${CV39_SCF_directory}
    Wait Until Keyword Succeeds    10m    60s    Check Cell Availability Status is online    1

    [Teardown]           coam.teardown     connection=coam_admin


dBF Setup on AEQA CV39
    [Documentation]      Apply the digitalBeamForming config on CV39 RU
    [Arguments]          ${CSV}    ${RUIpAddress}

    # Step1: bfloader on RU
    ${bfPath}=           Catenate          /mnt/scripts
    ${bfScript}=         Catenate          ${bfPath}/${CSV}
    ssh.Connect To       ${GN_OAM_ADDR}    ${GN_OAM_USR}    ${GN_OAM_PWD}     alias=fct0_a
    ssh.Connect To       ${RUIpAddress}    root             umniedziala       alias=AEQA    proxy=fct0_a
    ssh.Upload File      local_path=${CV39_dBFCSV_Directory}/${CSV}    remote_path=${bfPath}/${CSV}    connection=AEQA
    ssh.Execute          command=chmod 777 ${bfScript}      connection=AEQA
    ssh.Execute    command=bfloader -l gen3lf/BfCoefVector -w -f ${bfScript} -a fpga -o 0Xa00 -d 4    connection=AEQA
    sleep                1s
    ssh.disconnect       AEQA
    ssh.disconnect       fct0_a

    [Teardown]           coam.teardown     connection=coam_admin


TDD Timer Loader on AEQN CV63
    [Documentation]      Apply TDDtimer configuration file to RU for having specific frame structure!
    [Arguments]          ${tddtimerconf}

    Log                  The file is ${tddtimerconf}
    ssh.Connect To       ${GN_OAM_ADDR}     ${GN_OAM_USR}    ${GN_OAM_PWD}    alias=GNB
    ssh.Connect To       192.168.254.52     root             root             proxy=GNB       alias=RU_AEQN
    Log                  Connected to RU, transfer file started.
    ssh.Upload File    local_path=${CV63_TDDtimer_Directory}/${tddtimerconf}     remote_path=/mnt/factory/configs/unit
    ...   connection=RU_AEQN
    ssh.Send Command     mv /mnt/factory/configs/unit/${tddtimerconf} /mnt/factory/configs/unit/tddtimer.conf
    ...    connection=RU_AEQN
    Log                  Transfer file finished, now rebooting RU
    ssh.Send Command     Sync      connection=RU_AEQN
    ssh.Send Command     Reboot    connection=RU_AEQN
    ssh.Disconnect       RU_AEQN
    ssh.Disconnect       GNB
    

dBF Setup on GNB CV29
    [Documentation]      Apply the SCF and the swconfig.txt files on CV29 ASIK board
    [Arguments]          ${SCF}   	 ${SWconfig}

    # Step 1 : swconfig load and crasign
    ssh.Connect To       ${GN_OAM_ADDR}    ${GN_OAM_USR}    ${GN_OAM_PWD}     alias=fct0_a
    ssh.disconnect       fct0_a

    # Step2: SCF load
    Perfom SCF commissioning       ${SCF}        ${CV29_SCF_directory}
    Wait Until Keyword Succeeds    10m    60s    Check Cell Availability Status is online    1


dBF Setup on AEQA CV29
    [Documentation]      Apply the digitalBeamForming config on CV29 RU
    [Arguments]          ${CSV}    ${RUIpAddress}

    # Step1: bfloader on RU
    ${bfPath}=           Catenate          /ram
    ${bfScript}=         Catenate          ${bfPath}/${CSV}
    ssh.Connect To       ${GN_OAM_ADDR}    ${GN_OAM_USR}    ${GN_OAM_PWD}     alias=fct0_a
    ssh.Connect To       ${RUIpAddress}    root             umniedziala       alias=AEQA    proxy=fct0_a
    ssh.Upload File      local_path=${CV29_dBFCSV_Directory}/${CSV}           remote_path=${bfPath}/${CSV}
    ...      connection=AEQA
    ssh.Execute          command=chmod 777 ${bfScript}      connection=AEQA
    ssh.Execute          command=bfloader -l gen3lf/BfCoefVector -w -f ${bfScript} -a fpga -o 0Xa00 -d 4
    ...        connection=AEQA
    sleep                1s
    ssh.disconnect       AEQA
    ssh.disconnect       fct0_a
    
gNB Get CellId and BTSId DN in SCF
    # add
   
    ${content}=    gNB Get SCF Content
    ${parsed_xml}=    XML.Parse Xml    ${content}
    ${cell_elements}=     XML.Get Elements    ${parsed_xml}
    ...    cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"] 
    BuiltIn.Should Not Be Empty    ${cell_elements} 
    ${cell_num}=    BuiltIn.Get Length    ${cell_elements}
    Set Suite Variable    ${cell_num} 
    BuiltIn.Set Suite Variable    ${CV_NRCELL_1}    ${cell_elements[${cell_num}-1].attrib['distName']}
    BuiltIn.Set Suite Variable    ${CV_NSA_NRCELL_1}    ${cell_elements[${cell_num}-1].attrib['distName']}
    BuiltIn.Set Suite Variable    ${CV_SA_NRCELL_1}    ${cell_elements[${cell_num}-1].attrib['distName']} 
    BuiltIn.Set Suite Variable    ${CV_NRBTS}    ${cell_elements[${cell_num}-1].attrib['distName'].split('/NRCELL')[0]}
    BuiltIn.Set Suite Variable    ${CV_NSA_NRBTS}
    ...        ${cell_elements[${cell_num}-1].attrib['distName'].split('/NRCELL')[0]}
    BuiltIn.Set Suite Variable    ${CV_SA_NRBTS}        ${CV_NSA_NRBTS}
    ${result}=          XML.Get Element    ${parsed_xml}
    ...                 .//managedObject[@distName="${CV_NRCELL_1}"]/p[@name="physCellId"]
    BuiltIn.Set Suite Variable            ${physCellId}    ${result.text}    
    Run Keyword If    '${cell_num}' == '2'    BuiltIn.Set Suite Variable    ${CV_NRCELL_2}
    ...    ${cell_elements[0].attrib['distName']}
    Run Keyword If    '${cell_num}' == '2'    BuiltIn.Set Suite Variable    ${CV_NSA_NRCELL_2}
    ...    ${cell_elements[0].attrib['distName']}
    Run Keyword If    '${cell_num}' == '2'    BuiltIn.Set Suite Variable    ${CV_SA_NRCELL_2}
    ...    ${cell_elements[0].attrib['distName']}
    
    Run Keyword If    '${cell_num}' > '2'    BuiltIn.Set Suite Variable    ${CV_NRCELL_1}
    ...    ${cell_elements[0].attrib['distName']}
    Run Keyword If    '${cell_num}' > '2'    BuiltIn.Set Suite Variable    ${CV_NSA_NRCELL_1}
    ...    ${cell_elements[0].attrib['distName']}
    Run Keyword If    '${cell_num}' > '2'    BuiltIn.Set Suite Variable    ${CV_NRBTS}
    ...    ${cell_elements[0].attrib['distName'].split('/NRCELL')[0]}
    Run Keyword If    '${cell_num}' > '2'    BuiltIn.Set Suite Variable    ${CV_NSA_NRBTS}
    ...        ${cell_elements[0].attrib['distName'].split('/NRCELL')[0]}
 
    
    ${time_elements}=     XML.Get Elements    ${parsed_xml}
    ...    cmData/managedObject[@class="com.nokia.srbts.mnl:TIME"] 
    BuiltIn.Should Not Be Empty    ${time_elements} 
    ${time_num}=    BuiltIn.Get Length    ${time_elements}
    Set Suite Variable    ${time_num}
 
    FOR    ${index}    IN RANGE    ${time_num}
        BuiltIn.Set Suite Variable    ${Time_${index}}    ${time_elements[${index}].attrib['distName']}
 
    END  


WebEM Get Counter Value III
    [Documentation]                  For each time slot
    [Arguments]       ${xmlList}    ${xmlPathname}    ${timeSlot}    ${counterName}   ${counterName1}   ${cellName}

    ${result}=    Evaluate    1
    FOR    ${element}       IN    @{timeSlot}
           ${result}=        mylibpython.cOamCheckSleepStatusForSpecifiedCell
           ...             ${xmlList}  ${xmlPathname}  ${element}  ${counterName}  ${counterName1}    ${cellName}
           Run KeyWord If    ${result}==0    Exit For Loop
    END
    [Return]                ${result}