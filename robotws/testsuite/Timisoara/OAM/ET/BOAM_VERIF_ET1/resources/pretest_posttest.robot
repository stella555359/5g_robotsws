*** Settings ***
Documentation
...              Author: krzysztof.gryga@nokia.com, rafal.janik@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com
...              Maintainer: rafal.janik@nokia.com, krzysztof.gryga@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com

Library     XML    use_lxml=True
Library     Collections
Library     String
Resource    ./admin.robot
Resource    ./admin_infomodel.robot
Resource    ./logging.robot
#Resource    ./pdu.robot
Resource    ./system.robot
Library     SyslogCollector.py

*** Variables ***
${OUT_ADMIN_SMOD_PARAMETERS}
${OUT_ADMIN_BTS_PARAMETERS}
${OUT_ADMIN_BTS_NAME}
${OUT_ADMIN_BBMODS_PARAMETERS}
${OUT_ADMIN_RMODS_PARAMETERS}
${OUT_ADMIN_ALDS_PARAMETERS}
${OUT_ADMIN_LNCELS_PARAMETERS}
${OUT_ADMIN_SMODS_AMOUNT}
${OUT_ADMIN_BBMODS_AMOUNT}
${OUT_ADMIN_RMODS_AMOUNT}
${OUT_ADMIN_ALDS_AMOUNT}
${OUT_ADMIN_LNCELS_AMOUNT}
${OUT_ADMIN_SMOD_POSITION}
${OUT_SCF_FILE_PRETEST}
${OUT_SCF_FILE_POSTTEST}
${OUT_SCF_SMOD_COUNT}
${OUT_SCF_BBMOD_COUNT}
${OUT_SCF_RMOD_COUNT}
${OUT_SCF_ALD_COUNT}
${OUT_SCF_LNCEL_COUNT}
${OUT_MRBTS_ID}
${OUT_RMODS_IDS_LIST}
${OUT_RMODS_PRODUCTNAMES_LIST}
${OUT_RMODS_SERIALNUMBERS_LIST}
${OUT_SMODS_IDS_LIST}
${OUT_SMODS_PRODUCT_CODES_LIST}
${OUT_BBMODS_IDS_LIST}
${OUT_CELLS_MAPPED_TO_SMOD}
${OUT_CELLS_MAPPED_TO_BBMOD_1}
${OUT_CELLS_MAPPED_TO_BBMOD_2}

${location_o-ru_package}        home/userbtsoam/share1btsoam/ET_VERIF4/ORU_package
${sw_package}=      /tmp/ORU_package_1_1.zip
${timeout}=  1800
${should_activate}=  ${True}
${xranuser}=            xranuser
${xranpass}=            xran-password
${scf_leftside_dual_core_branch}        ${CURDIR}/scf_sbts22r4.xml
*** Keywords ***

Suite Preconditions
    Log
    ...    message=\n+ Started Suite PREconditions: ${SUITE_NAME}
    ...    console=yes

    Log Variables
    PREPOST Set Local Time
    PREPOST Setup Admin
    PREPOST Collect Scf File Presuite
    SCF Get Mrbts Plane Ip Address
    SCF Get Mme Ip Address
    SCF Get Top Ip Address
    SCF Get Ntp Ip Address
    PREPOST Get Smod Position
    PREPOST Get BTS Side
    PREPOST Get Bts Name
    PREPOST Create List Of Smod Parameters
    PREPOST Create List Of Smod Ids
    PREPOST Create List Of Bbmods Parameters
    PREPOST Create List Of Bbmods Ids
    PREPOST Get Amount Of Bbmods In Admin
    PREPOST Create List Of Bts Parameters
    PREPOST Create List Of Rmods Parameters
    PREPOST Create List Of Rmods Ids
    PREPOST Create List Of Rmods Product Names
    PREPOST Create List Of Rmods Serial Numbers
    PREPOST Get Amount Of Rmods In Admin
    PREPOST Create List Of Alds Parameters
    PREPOST Create List Of Cells Parameters
    PREPOST Create List Of Lncels Ids
    PREPOST Get Amount Of Lncels In Admin
    PREPOST Check Cells Mapping To FSPs
    PREPOST Get Active And Passive Software Versions
    Log
    ...    message=\n+ Finished Suite PREconditions: ${SUITE_NAME}
    ...    console=yes

Suite O-RU_Preconditions
    Log
    ...    message=\n+ Started Suite PREconditions: ${SUITE_NAME}
    ...    console=yes

    Log Variables
    PREPOST Set Local Time
    PREPOST Setup Admin
    PREPOST Collect Scf File Presuite
    SCF Get Mrbts Plane Ip Address
    SCF Get Mme Ip Address
    SCF Get Top Ip Address
    SCF Get Ntp Ip Address
    PREPOST Get Smod Position
    PREPOST Get BTS Side
    PREPOST Get Bts Name
    PREPOST Create List Of Smod Parameters
    PREPOST Create List Of Smod Ids
    PREPOST Create List Of Bbmods Parameters
    PREPOST Create List Of Bbmods Ids
    PREPOST Get Amount Of Bbmods In Admin
    PREPOST Create List Of Bts Parameters
#    PREPOST Create List Of Rmods Parameters
#    PREPOST Create List Of Rmods Ids
#    PREPOST Create List Of Rmods Product Names
#    PREPOST Create List Of Rmods Serial Numbers
#    PREPOST Get Amount Of Rmods In Admin
    PREPOST Create List Of Alds Parameters
    PREPOST Create List Of Cells Parameters
    PREPOST Create List Of Lncels Ids
    PREPOST Get Amount Of Lncels In Admin
    PREPOST Check Cells Mapping To FSPs
    PREPOST Get Active And Passive Software Versions
    Log
    ...    message=\n+ Finished Suite PREconditions: ${SUITE_NAME}
    ...    console=yes

Suite Postconditions
    Log
    ...    message=\n+ Started Suite POSTconditions: ${SUITE_NAME}
    ...    console=yes
    ADMIN Collect Snapshot
    PREPOST Collect Scf File Postsuite
    PREPOST Teardown Admin
    Log Variables
    ADMIN Teardown Admin
    Log
    ...    message=\n+ Finished Suite POSTconditions: ${SUITE_NAME}
    ...    console=yes

Test Preconditions
    Log
    ...    message=\n+ Stated Test PREconditions ${TEST_NAME}
    ...    console=yes
    LOGGING Start Logging
    ${out_mrbts_id}=    taf.gnb.oam.coam.admin.Get Bts Info
    Set Suite Variable    ${OUT_MRBTS_ID}    ${out_mrbts_id['mrbtsID']}
    Log Variables
    Log
    ...    message=\n+ Finished Test PREconditions: ${TEST_NAME}
    ...    console=yes

Test Postconditions
    Log
    ...    message=\n+ Started Test POSTconditions: ${TEST_NAME}
    ...    console=yes
    LOGGING Stop Logging
    Log Variables
    Log
    ...    message=\n+ Finished Test POSTconditions: ${TEST_NAME}
    ...    console=yes

Test Postconditions With Reset Site
    Log    \n+ Common Test Postconditions With Reset Site started    console=yes
    ADMIN Reset Site
    LOGGING Stop Logging
    Log Variables
    Log    \n+ Common Test Postconditions With Reset Site finished    console=yes

PREPOST Set Local Time
    Run    sudo cp /usr/share/zoneinfo/Poland /etc/localtime

PREPOST Setup Admin
    ADMIN Setup Admin
    ...    bts_port=${ADMIN_BTS_PORT}
    ...    alias=${ADMIN_ALIAS}

PREPOST Teardown Admin
    ADMIN Teardown Admin
    ...    alias=${ADMIN_ALIAS}

PREPOST Collect Scf File
    [Arguments]    ${file_name}
    #...            ${alias}
    ADMIN Collect Scf
    ...    local_dir_path=${OUTPUT_DIR}/
    ...    file_name=${file_name}
    ...    alias=${ADMIN_ALIAS}
    [Return]    ${OUTPUT_DIR}/${file_name}

PREPOST Collect Scf File Presuite
    ${out_scf_filename_pretest}=    PREPOST Collect Scf File
    ...    file_name=SCF_Presuite.xml
    #...    alias=${ADMIN_ALIAS}
    Set Suite Variable    ${OUT_SCF_FILE_PRETEST}    ${out_scf_filename_pretest}

PREPOST Collect Scf File Postsuite
    ADMIN Setup Admin
    ...    alias=${ADMIN_ALIAS}
    ${out_scf_filename_posttest}=    PREPOST Collect Scf File
    ...    file_name=SCF_Postsuite.xml
    #...    alias=${ADMIN_ALIAS}
    ADMIN Teardown Admin
    ...    alias=${ADMIN_ALIAS}
    Set Suite Variable    ${OUT_SCF_FILE_POSTTEST}    ${out_scf_filename_posttest}

SCF Get Mrbts Plane Ip Address
    [Arguments]    ${scf_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_mrbt_ipv4}=    Evaluate Xpath
    ...    source=${scf_file_path}
    ...    expression=string(.//managedObject[@class="com.nokia.srbts.tnl:IPADDRESSV4"]/p[@name="localIpAddr"])
    Set Suite Variable    ${OUT_SCF_MRBTS_IP}    ${out_scf_mrbt_ipv4}
    ${out_scf_mrbt_ipv6}=    Evaluate Xpath
    ...    source=${scf_file_path}
    ...    expression=string(.//managedObject[@class="com.nokia.srbts.tnl:IPADDRESSV6"]/p[@name="localIpAddr"])
    Set Suite Variable    ${OUT_SCF_MRBTS_IPV6}    ${out_scf_mrbt_ipv6}

SCF Get Mme Ip Address
    [Arguments]    ${scf_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_mme_ip}=    Evaluate Xpath
    ...    source=${scf_file_path}
    ...    expression=string(.//managedObject[@class="NOKLTE:LNMME"]/p[@name="ipAddrPrim"])
    Set Suite Variable    ${OUT_SCF_MME_IP}    ${out_scf_mme_ip}

SCF Get Top Ip Address
    [Arguments]    ${scf_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_top_ip}=    Evaluate Xpath
    ...    source=${scf_file_path}
    ...    expression=string((.//managedObject[@class="com.nokia.srbts.mnl:TOPF"]//p[@name="masterIpAddr"])[1])
    Set Suite Variable    ${OUT_SCF_TOP_IP}    ${out_scf_top_ip}

SCF Get Ntp Ip Address
    [Arguments]    ${scf_file_path}=${OUT_SCF_FILE_PRETEST}
    ${out_scf_ntp_ip}=    Evaluate Xpath
    ...    source=${scf_file_path}
    ...    expression=string(.//managedObject[@class="com.nokia.srbts.mnl:NTP"]/list[@name="ntpServerIpAddrList"]/p/text()[1])
    Set Suite Variable    ${OUT_SCF_NTP_IP}    ${out_scf_ntp_ip}

SCF Get Parameter Value From SCF File
    [Arguments]    ${path}
    ...            ${scf_file_path}=${OUT_SCF_FILE_PRETEST}
    ${value}=    Evaluate Xpath
    ...    source=${scf_file_path}
    ...    expression=string(${path})
    [Return]    ${value}

PREPOST Get Amount Of Bbmods In Admin
    ${out_bbmods_amount}=    Get Length    ${OUT_ADMIN_BBMODS_PARAMETERS}
    Set Suite Variable    ${OUT_ADMIN_BBMODS_AMOUNT}    ${out_bbmods_amount}

PREPOST Get Amount Of Rmods In Admin
    ${out_rmods_amount}=    Get Length    ${OUT_ADMIN_RMODS_PARAMETERS}
    Set Suite Variable    ${OUT_ADMIN_RMODS_AMOUNT}    ${out_rmods_amount}

PREPOST Get Amount Of Alds In Admin
    ${out_alds_amount}=    Get Length   ${OUT_ADMIN_ALDS_PARAMETERS}
    Set Suite Variable    ${OUT_ADMIN_ALDS_AMOUNT}    ${out_alds_amount}

PREPOST Get Amount Of Lncels In Admin
    ${out_lncels_amount}=    Get Length    ${OUT_LNCELS_IDS_LIST}
    Set Suite Variable    ${OUT_ADMIN_LNCELS_AMOUNT}    ${out_lncels_amount}

PREPOST Get Bts Name
    ${bts_name}=    taf.gnb.oam.coam.admin.Get Bts Info
    Set Suite Variable    ${OUT_ADMIN_BTS_NAME}    ${bts_name['name']}

PREPOST Create List Of Smod Parameters
     ${out_smod_parameters}=    ADMIN Get Parameters For All SMOD
     Set Suite Variable    ${OUT_ADMIN_SMOD_PARAMETERS}    ${out_smod_parameters}

PREPOST Create List Of Bts Parameters
     ${out_bts_parameters}=    ADMIN Get Parameters For All BTS
     Set Suite Variable    ${OUT_ADMIN_BTS_PARAMETERS}    ${out_bts_parameters}

PREPOST Create List Of Bbmods Parameters
     ${out_bbmods_parameters}=    ADMIN Get Parameters For All BBMODs
     Set Suite Variable    ${OUT_ADMIN_BBMODS_PARAMETERS}    ${out_bbmods_parameters}

PREPOST Create List Of Rmods Parameters
    #[Arguments]    ${alias}=${ADMIN_ALIAS}
    ${out_rmods_parameters}=    ADMIN Get Parameters For All RMODs
    Set Suite Variable    ${OUT_ADMIN_RMODS_PARAMETERS}    ${out_rmods_parameters}
    Set Suite Variable    ${SYSTEM_RMOD_LOCAL_IP}    ${OUT_RMODS_PARAMETERS[0]['ipAddress']}

PREPOST Create List Of Alds Parameters
     ${out_alds_parameters}=    ADMIN Get Parameters For All ALDs
     Set Suite Variable    ${OUT_ADMIN_ALDS_PARAMETERS}    ${out_alds_parameters}

PREPOST Create List Of Cells Parameters
    ${out_lncels_parameters}=    ADMIN Get Parameters For All LNCELs
    Set Suite Variable    ${OUT_ADMIN_LNCELS_PARAMETERS}    ${out_lncels_parameters}

PREPOST Create List Of Objects Parameter Values
    [Arguments]    ${parameters_list}
    ...            ${parameter}
    ${out_list}=    Create List
    FOR    ${out_index}    IN    @{parameters_list}
        Log    ${out_index}
        ${out_parameter}=    Get From Dictionary    ${out_index}    ${parameter}
        Append To List    ${out_list}    ${out_parameter}
    END
    [Return]   ${out_list}

PREPOST Create List Of Smod Parameter Value
    [Arguments]    ${parameter}
    ${out_parameter_list}=    PREPOST Create List Of Objects Parameter Values
    ...    parameters_list=${OUT_ADMIN_SMOD_PARAMETERS}
    ...    parameter=${parameter}
    [Return]    ${out_parameter_list}

PREPOST Create List Of Smod Ids
    ${out_smods_id_list}=    PREPOST Create List Of Smod Parameter Value
    ...    parameter=id
    Set Suite Variable    ${OUT_SMODS_IDS_LIST}    ${out_smods_id_list}

PREPOST Create List Of Bbmods Parameter Value
    [Arguments]    ${parameter}
    ${out_parameter_list}=    PREPOST Create List Of Objects Parameter Values
    ...    parameters_list=${OUT_ADMIN_BBMODS_PARAMETERS}
    ...    parameter=${parameter}
    [Return]    ${out_parameter_list}

PREPOST Create List Of Bbmods Ids
    ${out_bbmods_id_list}=    PREPOST Create List Of Bbmods Parameter Value
    ...    parameter=id
    Set Suite Variable    ${OUT_BBMODS_IDS_LIST}    ${out_bbmods_id_list}

PREPOST Create List Of Rmods Parameter Value
    [Arguments]    ${parameter}
    ${out_parameter_list}=    PREPOST Create List Of Objects Parameter Values
    ...    parameters_list=${OUT_ADMIN_RMODS_PARAMETERS}
    ...    parameter=${parameter}
    [Return]    ${out_parameter_list}

PREPOST Create List Of Rmods Ids
    ${out_rmods_id_list}=    PREPOST Create List Of Rmods Parameter Value
    ...    parameter=id
    ${out_rmods_id_list}=    evaluate    sorted(${out_rmods_id_list})
    Set Suite Variable    ${OUT_RMODS_IDS_LIST}    ${out_rmods_id_list}

PREPOST Create List Of Rmods Product Names
    ${out_rmods_productnames_list}=    PREPOST Create List Of Rmods Parameter Value
    ...    parameter=productName
    Set Suite Variable    ${OUT_RMODS_PRODUCTNAMES_LIST}    ${out_rmods_productnames_list}

PREPOST Create List Of Rmods Serial Numbers
    ${out_rmods_serialnumbers_list}=    PREPOST Create List Of Rmods Parameter Value
    ...    parameter=serialNumber
    Set Suite Variable    ${OUT_RMODS_SERIALNUMBERS_LIST}    ${out_rmods_serialnumbers_list}

PREPOST Create List Of Lncels Parameter Values
    [Arguments]    ${parameter}
    ${out_parameter_list}=    PREPOST Create List Of Objects Parameter Values
    ...    parameters_list=${OUT_ADMIN_LNCELS_PARAMETERS}
    ...    parameter=${parameter}
    [Return]    ${out_parameter_list}

PREPOST Create List Of Lncels Ids
    ${out_lncels_ids_list}=    PREPOST Create List Of Lncels Parameter Values
    ...    parameter=id
    ${out_lncels_ids_list}=    evaluate    sorted(${out_lncels_ids_list})
    Set Suite Variable    ${OUT_LNCELS_IDS_LIST}    ${out_lncels_ids_list}

PREPOST Get Smod Position
    ${out_smod_position}=    ADMIN Get Smod Position
    Set Suite Variable    ${OUT_ADMIN_SMOD_POSITION}    ${out_smod_position}

PREPOST Get BTS Side
    ${position}    Convert To String    ${OUT_ADMIN_SMOD_POSITION}
    ${whole}    Run Keyword And Return Status    Should Contain    ${position}    whole
    ${left}    Run Keyword And Return Status    Should Contain    ${position}    left
    ${right}    Run Keyword And Return Status    Should Contain    ${position}    right
    Run Keyword If    '${whole}' == 'True'    Set Suite Variable    ${BTS_Side}    1
    ...               ELSE IF
    ...               '${left}' == 'True'    Set Suite Variable    ${BTS_Side}    1
    ...               ELSE IF
    ...               '${right}' == 'True'    Set Suite Variable    ${BTS_Side}    4
    Run Keyword If    '${whole}' == 'True'    Log    FSMF    console=yes
    ...               ELSE IF
    ...               '${right}' == 'True'    Log    AirScale: Right Side    console=yes
    ...               ELSE IF
    ...               '${left}' == 'True'    Log    AirScale: Left Side    console=yes

PREPOST Get Active Software Versions
    ${out_active_sw}=    Get From Dictionary    @{OUT_ADMIN_BTS_PARAMETERS}    activeSoftwareVersion
    Set Suite Variable    ${OUT_ACTIVE_SW}    ${out_active_sw}

PREPOST Get Passive Software Versions
    ${out_passive_sw}=    Get From Dictionary    @{OUT_ADMIN_BTS_PARAMETERS}    passiveSoftwareVersion
    Set Suite Variable    ${OUT_PASSIVE_SW}    ${out_passive_sw}

PREPOST Get Active And Passive Software Versions
    PREPOST Get Active Software Versions
    PREPOST Get Passive Software Versions

PREPOST Check Cells Mapping To FSPs
    ${out_cells_mapped_to_smod}=    ADMIN Get Cell Mapping By Module Id
    ...    module_id=${OUT_SMODS_IDS_LIST[0]}
    Set Suite Variable    ${OUT_CELLS_MAPPED_TO_SMOD}    ${out_cells_mapped_to_smod}
    FOR    ${out_index}    IN RANGE    0    ${OUT_ADMIN_BBMODS_AMOUNT}
        ${bbmod_number}=    Evaluate    ${out_index}+${1}
        ${out_cells_mapped_to_bbmod}=    ADMIN Get Cell Mapping By Module Id
    ...    module_id=${OUT_BBMODS_IDS_LIST[${out_index}]}
        Set Suite Variable    ${OUT_CELLS_MAPPED_TO_BBMOD_${bbmod_number}}    ${out_cells_mapped_to_bbmod}
    END

UTE TL Preparation O-RU
    [Documentation]     Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    #TO DO:             Add Check for onAir State. For cases when the Suite is run more than one time
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  Configured_SwDownload_SwUpdate_OnAir_O-RU
    ...     ELSE    Log To Console  --- BTS already onAir ---
#    Configured_SwDownload_SwUpdate_OnAir
Get TL Hostname
    ${tl_hostname_temp}  Run  hostname
    @{output}  Split String  ${tl_hostname_temp}  separator=-
    ${tl_hostname}  Catenate  @{output}[0]_@{output}[1]_@{output}[2]
    Set Suite Variable  ${tl_hostname}

Get Software Release
    ${sw_version}    taf.gnb.oam.coam.admin.Get SW Version
    @{split_sw_version}  Split String  ${sw_version}  separator=_
    Run Keyword If  '@{split_sw_version}[0]' == 'SBTS23R2'
    ...     Set Global Variable   ${sw_release}  SBTS00
    ...     ELSE  Set Global Variable  ${sw_release}  ${split_sw_version}[0]

Configured_SwDownload_SwUpdate_OnAir_O-RU
    #TO DO:     Check BBMOD/RMOD status after commissioning
    #TO DO:     Check RU status after SW Upgrade
##    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release
    Set Var For Different Branches
    Delete safe files on gNB
    ADMIN Perform Commissioning
    ...     scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
#    ADMIN Check BTS Commissioned
#    ADMIN Get BBMOD Statuses  1
    Log to console  Start O-RU_container and O-RU1
    Check_and_Stop_O-RU_container  ${oru1}
    Configure_O-RU_default  ${oru1}
    Check_and_Start_O-RU_container  ${oru1}
    Check_and_Start_O-RU  ${oru1}
    Run Keyword If  '${tl_hostname}_SCF.xml' == '12_18_UTE5GBTSOAMVRF1TL003_SCF.xml'     Run Keywords
#    ...     Log to console  Start O-RU_container and O-RU2
    ...     Check_and_Stop_O-RU_container  ${oru2}
    ...   AND    Configure_O-RU_default  ${oru2}
    ...   AND    Check_and_Start_O-RU_container  ${oru2}
    ...   AND    Check_and_Start_O-RU  ${oru2}
    Log to console  Add Netconf Account
    Sleep  60
    SELENIUM Setup
    Go To Netconf Radio Management Menu
    ### Add default O-RU Name and Netconf Account
    ##Or
    ### Add default O-RU Name and Netconf Account Branch
    Log To Console  Netconf account configured...
    Run Keyword If  '${sw_release}' == 'SBTS22R1'  Run Keyword  SELENIUM Add new O-RU Name and Netconf Account Branch  ${xranuser}  ${xranpass}
    ...     ELSE    Run Keyword and Ignore Error  SELENIUM Add new O-RU Name and Netconf Account  ${xranuser}     ${xranpass}
    Sleep  180
#    Log To Console  package for o-ru transfered...
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    Run Keyword If  '${result}' == 'True'   Run Keywords   Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     Run And Return Rc And Output  sshpass -p 'Aikonbtsoam2@' scp userbtsoam@10.5.25.200:/${location_o-ru_package}/* /tmp
    ...     AND     ADMIN Update Software  ${sw_package}  ${should_activate}  ${timeout}  ${alias}
    ...     ELSE    Log To Console  Fault ID23 not found. Wait for onAir State
    Sleep  500
#    Wait Until Keyword Succeeds  600  10   ADMIN Wait Until BTS OnAir

UTE TL Preparation Dual Core
    [Documentation]     Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    #TO DO:             Add Check for onAir State. For cases when the Suite is run more than one time
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  Configured_SwDownload_SwUpdate_OnAir_dual_core
    ...     ELSE    Log To Console  --- BTS already onAir ---

#Get TL Hostname
#    ${tl_hostname_temp}  Run  hostname
#    @{output}  Split String  ${tl_hostname_temp}  separator=-
#    ${tl_hostname}  Catenate  @{output}[0]_@{output}[1]_@{output}[2]
#    Set Suite Variable  ${tl_hostname}

Get Software Release for dual core
    ${sw_version}    taf.gnb.oam.coam.admin.Get SW Version
    @{split_sw_version}  Split String  ${sw_version}  separator=_
    Run Keyword If  '@{split_sw_version}[2]' == '9999'
    ...     Set Suite Variable   ${sw_release}  SBTS00
    ...     ELSE  Set Suite Variable  ${sw_release}  ${split_sw_version}[0]
    Set suite variable   ${sw_version}  ${sw_version}

Configured_SwDownload_SwUpdate_OnAir_dual_core
    #TO DO:     Check BBMOD/RMOD status after commissioning
    #TO DO:     Check RU status after SW Upgrade
    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release for dual core
#    Set Suite Variable    	${sw_version}    ${OUT_ACTIVE_SW}
    ${active_software_split}=    Split String
    ...                          string=${sw_version}
    ...                          separator=_
    ...                          max_split=4
    ${BRANCH}=   Get from list         ${active_software_split}    2
    ADMIN Perform Commissioning
    ...     scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF_3xAEUD.xml
    ...     skip_parameter_relation_errors=True
#    ${version}=  Run Keyword If  '${BRANCH}'=='9999'  ADMIN Perform Commissioning
#    ...     scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF_3xAEUD.xml
#    ...     skip_parameter_relation_errors=True
#    ...     ELSE  Run Keyword  ADMIN Perform Commissioning
#    ...     scf_file=${scf_leftside_dual_core_branch}
#    ...     skip_parameter_relation_errors=True
#    ADMIN Perform Commissioning
#    ...     scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF_3xAEUD.xml
#    ADMIN Check BTS Commissioned
#    ADMIN Get BBMOD Statuses  1
    BuiltIn.Wait Until Keyword Succeeds  1500  10   ADMIN Check BTS Configured
    Sleep  180
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    Run Keyword If  '${result}' == 'True'  Sleep  180
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords   Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     Sleep  300
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found. Wait for onAir State
#    ADMIN Get RU Statuses
    BuiltIn.Wait Until Keyword Succeeds  600  10   ADMIN Wait Until BTS OnAir


UTE TL Preparation
    [Documentation]     Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    #TO DO:             Add Check for onAir State. For cases when the Suite is run more than one time
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  Configured_SwDownload_SwUpdate_OnAir
    ...     ELSE    Log To Console  --- BTS already onAir ---
    ADMIN Teardown Admin

Configured_SwDownload_SwUpdate_OnAir
    #TO DO:     Check BBMOD/RMOD status after commissioning
    #TO DO:     Check RU status after SW Upgrade
    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release
    ADMIN Perform Commissioning
    ...     scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
#    ADMIN Check BTS Commissioned
#    ADMIN Get BBMOD Statuses  1
    ${configured}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    Run Keyword If  '${configured}' == 'True'  Sleep  180
    Run Keyword Unless   ${configured}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    ...    AND     Sleep  180
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords
    ...    Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found.
    ${onair}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Run Keyword Unless   ${onair}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir




