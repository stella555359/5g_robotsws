*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Library     BuiltIn
Library     String
Library     Process
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.sw.scout        WITH NAME   scout
Library     taf.nms.netact      WITH NAME   nms
Library     taf.transport.ssh   WITH NAME   csn
Library     taf.analyzer.pcap   WITH NAME   wireshark
Library     taf.selenium.sbts   WITH NAME   selenium_sbts
Library     taf.ul.oam_kpi_calculations   WITH NAME   oam_kpi
Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Library     taf.collectors.btslog   WITH NAME   btslog
Library     taf.collectors.core   WITH NAME   core

# Library     ../../libraries/nms_vars.py

# Library     ../Library/pcmd_message.py
# Library     ../Library/common.py
Library     ../Library/UUF_Utils.py
Library     ../Library/UUF_COAM.py

Resource    UUF_CheckPoint.robot
Resource    UUF_CheckPointWait.robot
Resource    UUF_LogCollection.robot
Resource    UUF_Prepare.robot
Resource    UUF_Reset.robot
Resource    UUF_Reset_Activation.robot
Resource    UUF_Rollback.robot
Resource    UUF_Upgrade.robot

Resource    AsyncProcess.robot
Resource    COAM.robot
Resource    CommonUtility.robot
Resource    DownloadUtility.robot
Resource    Execution_Results.robot
Resource    Firmware.robot
Resource    L3Call.robot
Resource    NetAct.robot
Resource    NetAct_Integration.robot
Resource    RecoveryAction.robot
Resource    RemoteSSH.robot
Resource    RU.robot
Resource    Scout.robot

# Resource    ../../common/taf_coam.robot
# Resource    ../../common/NetAct_selenium.robot
# Resource    ../../common/qc_tag.robot
# Resource    ../../common/gnb.robot
# Resource    ../../common/RU.robot

# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/L3CALL_NEW.robot

# Variables   ../../libraries/global_vars.py
# Variables   ../Library/pcmd_var.py
# Variables   ../Library/emil_vars.py
Variables   ../Config/UUF_Vars.py
Variables   ../Config/UUF_Config.py
Variables   ../Config/UUF_Alarms.py
Variables   ../Config/UUF_Constant.py
Variables   ../Config/UUF_NMS_Vars.py
Variables   ../Config/UUF_Scout_Testline.py


*** Keywords ***
UUF Common Suite Setup
    Log To Console   ${EMPTY}
    Log To Console   //TODO: UUF Common Suite Setup
    # Get Suite Setup Start Time
    ${SUITE_SETUP_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   SUITE_SETUP_START: ${SUITE_SETUP_START}
    Set Suite Variable   ${SUITE_SETUP_START}


    # UUF Get Variables From Testline Configuration
    UUF Truck Roll Check

    UUF Backup All Testline SCF   scf_prefix=SCF_Prepare
    UUF Get Variables From Backup SCF   scf_prefix=SCF_Prepare

    UUF Get Variables From Others
    UUF Get Testline Type


    # Prepare Env Check
    UUF Remove Precheck Testline Log
    UUF Check Env VM
    UUF Prepare Load Build
    UUF Check Env Testline

    UUF Check TMO Decoupling
    UUF Check Independent DU SW Upgrade

    # Prepare for Source Build
    ${package_type}   Set Variable If   "${UUF_FUNCTION}"=="reset"   target   source
    UUF Switch To Specified Load Build   upgrade_sequence=${PREPARE_SEQUENCE}   package_type=${package_type}

    UUF Backup All Testline SCF   scf_prefix=SCF_${package_type.capitalize()}
    UUF Get Variables From Backup SCF   scf_prefix=SCF_${package_type.capitalize()}
    run keyword if  ${l3_call.count('Y')}>0 and ('${TESTLINE_IDENTITY}' in ${UUF_L3Call})
    ...   UUF Get Variables From L3CALL    scf_prefix=SCF_${package_type.capitalize()}

    UUF ALL WorkAround
    UUF Log ALL Suite Variables

    # Get Suite Setup END Time
    ${SUITE_SETUP_END}   DateTime.Get Current Date   result_format=epoch
    Log To Console   SUITE_SETUP_END: ${SUITE_SETUP_END}
    Set Suite Variable   ${SUITE_SETUP_END}

    # UUF Requset ConfigurationID From Scout
    Run Keyword And Ignore Error   UUF Requset ConfigurationID

    # Initialize Execution Results
    Run Keyword And Ignore Error   UUF Initialize Execution Results JSON Suite Setup
    # Run Keyword And Ignore Error   UUF Suite Setup Update Execution Results JSON Dictionary


UUF Common Suite Teardown
    Log To Console   ${EMPTY}
    Log To Console   //TODO: UUF Common Suite Teardown
    # UUF Pass Execution

    Run Keyword And Ignore Error   UUF Clear Execution Results JSON Dictionary
    Run Keyword And Ignore Error   UUF Save Execution Results JSON File

    # UUF Truck Roll Check
    # # UUF Clear Logs
    Run Keyword And Ignore Error   UUF Upload Log To FTP Server


UUF Common Test Setup
    Log To Console   ${EMPTY}
    Log To Console   //TODO: UUF Common Test Setup
    ${UUF_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   UUF_PROCESS_START: ${UUF_PROCESS_START}
    Set Test Variable   ${UUF_PROCESS_START}

    # UUF Pass Execution

    # # UUF Get ALL Test Variables
    #     # ->  TestName: WEBEM or NetAct. Upgrade or Rollback or Reset.
    #     # ->  Set Test Variable
    #     # ->  others?
    Set Test Variable   ${UUF_PROCESS}   others
    Run Keyword If   "${TEST_NAME.lower().find('upgrade')}"!="-1"   Set Test Variable   ${UUF_PROCESS}   upgrade
    Run Keyword If   "${TEST_NAME.lower().find('rollback')}"!="-1"   Set Test Variable   ${UUF_PROCESS}   rollback
    Run Keyword If   "${TEST_NAME.lower().find('reset')}"!="-1"   Set Test Variable   ${UUF_PROCESS}   reset
    Log To Console   UUF_PROCESS: ${UUF_PROCESS}

    Run Keyword If   "${TEST_NAME.upper().find('T1')}"!="-1"   Set Test Variable   ${UUF_PROCESS_T1}   ${True}
    ...   ELSE   Set Test Variable   ${UUF_PROCESS_T1}   ${False}


    Run Keyword And Ignore Error   UUF Initialize Execution Results JSON Test Setup

    # Check Software Version Before UUF Process. Fatal Error.
    ${package_type}   Set Variable If
    ...   "${UUF_PROCESS}"=="upgrade"   source
    ...   "${UUF_PROCESS}"=="rollback"   target
    ...   "${UUF_PROCESS}"=="reset" and ${UUF_PROCESS_T1}   target
    ...   "${UUF_PROCESS}"=="reset" and not ${UUF_PROCESS_T1}   testpackage
    ...   others

    Log To Console   Check Software Version Before UUF Process Started: UUF_PROCESS: ${UUF_PROCESS}, package_type: ${package_type}
    ${sw_version_match}   Run Keyword And Return Status   Run Keyword If   not ${DEBUG}
    ...   UUF Check All Testline SW Version   package_type=${package_type}
    Set Suite Variable   ${UUF_PROCESS_SW_VERSION_MATCH}   ${sw_version_match}
    Run Keyword If   not ${UUF_PROCESS_SW_VERSION_MATCH}   Fatal Error   msg=[ERROR] Software Version Not Match, Exit UUF Process.

    UUF Initialize ALL Check Point Error
    UUF Truck Roll Check
    UUF Start Log Collection Process
    ${UUF_Test_Setup_END}   DateTime.Get Current Date   result_format=epoch
    Log To Console   UUF_Test_Setup_END: ${UUF_Test_Setup_END}
    Set Test Variable   ${UUF_Test_Setup_END}


UUF Common Test Teardown
    Log To Console   ${EMPTY}
    Log To Console   //TODO: UUF Common Test Teardown
    # UUF Pass Execution

    Run Keyword If   not ${UUF_PROCESS_SW_VERSION_MATCH}   Fatal Error   msg=[ERROR] Software Version Not Match, Exit UUF Process.

    UUF Stop Log Collection Process
    UUF Catch All Logs
    UUF Truck Roll Check
    ${notRecovery}   UUF Recovery Action
    ${isStatusOK}   Run Keyword And Return Status   UUF Check Testlines Status
    Run Keyword If   "${notRecovery}"!="${True}" or (not ${isStatusOK})   UUF Catch Snapshot   prefix=AfterRecovery
    Run Keyword If   not ${isStatusOK}   FAIL   msg=UUF Common Test Teardown: After Recovery Failed.


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================

UUF Get Variables From Testline Configuration
    Log To Console   ${EMPTY}
    Log To Console   //TODO: UUF Get Variables From Testline Configuration
    # testline identity get from gnb_0 instance id? or from suite name?
    # Set Suite Variable   ${TESTLINE_IDENTITY}   ${tl.gnbs[0].instance_id}


UUF Check TMO Decoupling
    ${gnb_target_version}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['gnb']['target']['version']}   ${EMPTY}
    ${enb_target_version}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['enb']['target']['version']}   ${EMPTY}

    ${TMO_DECOUPLING}   Set Variable If
    # ...   ("${TESTLINE_IDENTITY}" in ${TMO_DECOUPLING_TL}) and ("${gnb_target_version}"!="${enb_target_version}")
    ...   "${gnb_target_version}"!="${enb_target_version}"
    ...   ${True}   ${False}
    Set Suite Variable   ${TMO_DECOUPLING}


UUF Check Independent DU SW Upgrade
    ${INDEPENDENT_DU_SW_UPGRADE}   Set Variable If   "${TESTLINE_IDENTITY}" in ${INDEPENDENT_DU_SW_UPGRADE_TL}   ${True}   ${False}
    Set Suite Variable   ${INDEPENDENT_DU_SW_UPGRADE}

    ${SEQUENTIAL_RU_SW_UPGRADE}   Set Variable If   "${TESTLINE_IDENTITY}" in ${SEQUENTIAL_RU_SW_UPGRADE_TL}   ${True}   ${False}
    Set Suite Variable   ${SEQUENTIAL_RU_SW_UPGRADE}

# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
UUF Get Variables From Backup SCF
    Log To Console   //TODO: UUF Get Variables From Backup SCF
    # Example backup SCF file name: SCF_Prepare_gnb_0.xml
    # UUF Backup All Testline SCF   scf_prefix=SCF_Prepare

    [Arguments]   ${scf_prefix}=SCF_Prepare
    ${ALL_CONFIG_SCF}   Create Dictionary
    @{ALL_IP_LIST}   Create List
    FOR   ${testline}   IN   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}
        ${testline_scf_dict}   Create Dictionary

        ${testline_type}   ${testline_index}   Split String   ${testline}   _

        ${scf_path}   Set Variable   ${OUTPUT_DIR}/${scf_prefix}_${testline}.xml
        ${scf_xml}   XML.Parse XML   ${scf_path}

        ${localIpAddr_list}   Get Elements Texts   ${scf_xml}
        ...   xpath=cmData/managedObject[@class="com.nokia.srbts.tnl:IPADDRESSV4"]/p[@name="localIpAddr"]
        Append To List   ${ALL_IP_LIST}   @{localIpAddr_list}

        ${dist_name}   XML.Get Element Attribute   ${scf_xml}   name=distName   xpath=cmData/managedObject[@class="com.nokia.srbts:MRBTS"]
        Set To Dictionary   ${testline_scf_dict}   dist_name=${dist_name}

        ${MNL_DN}   XML.Get Element Attribute   ${scf_xml}   name=distName   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:MNL"]
        Set To Dictionary   ${testline_scf_dict}   MNL_DN=${MNL_DN}

        ${AMGR_DN}   XML.Get Element Attribute   ${scf_xml}   name=distName   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:AMGR"]
        Set To Dictionary   ${testline_scf_dict}   AMGR_DN=${AMGR_DN}

        ${FEATCADM_DN}   XML.Get Element Attribute   ${scf_xml}   name=distName   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]
        Set To Dictionary   ${testline_scf_dict}   FEATCADM_DN=${FEATCADM_DN}

        ${btsName}   XML.Get Element Text   ${scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts:MRBTS"]/p[@name="btsName"]
        Set To Dictionary   ${testline_scf_dict}   btsName=${btsName}

        ${oamtls}   XML.Get Element Text   ${scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:MPLANENW"]/p[@name="oamTls"]
        Set To Dictionary   ${testline_scf_dict}   oamtls=${oamtls}

        ${rmod_serial_list}   UUF Get RMOD SerialNumber List   source=${scf_xml}
        Set To Dictionary   ${testline_scf_dict}   rmod_serial_list=${rmod_serial_list}

        ${rmod_dn_list}   UUF Get RMOD DN List   source=${scf_xml}
        Set To Dictionary   ${testline_scf_dict}   rmod_dn_list=${rmod_dn_list}

        ${rmod_detail_list}   UUF Get RMOD Detail List   source=${scf_xml}
        Set To Dictionary   ${testline_scf_dict}   rmod_detail_list=${rmod_detail_list}

        ${rmod_serial_mapping}   UUF Get RMOD SerialNumber Mapping   source=${scf_xml}
        Set To Dictionary   ${testline_scf_dict}   rmod_serial_mapping=${rmod_serial_mapping}

        ${rmod_dn_mapping}   UUF Get RMOD DN Mapping   source=${scf_xml}
        Set To Dictionary   ${testline_scf_dict}   rmod_dn_mapping=${rmod_dn_mapping}

        ${cablink_mapping}   UUF Get Cablink Mapping   source=${scf_xml}
        Set To Dictionary   ${testline_scf_dict}   cablink_mapping=${cablink_mapping}

        ${TDD_FDD_variant}   UUF Get TDD FDD Variant   source=${scf_xml}
        Set To Dictionary   ${testline_scf_dict}   TDD_FDD_variant=${TDD_FDD_variant}

        ${hw_config}   UUF Get Hardware Config   source=${scf_xml}
        Set To Dictionary   ${testline_scf_dict}   hw_config=${hw_config}

        ${syncInputType}   XML.Get Elements Texts   source=${scf_xml}
        ...   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:CLOCK"]/list/item/p[@name="syncInputType"]
        Set To Dictionary   ${testline_scf_dict}   syncInputType=${syncInputType}

        ${XP_Type}   Run Keyword And Return Status   XML.Element Should Exist   source=${scf_xml}
        ...   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:XPIFREMOTE"]
        Set To Dictionary   ${testline_scf_dict}   XP_Type=${XP_Type}

        ${actPowerMeter_dn}   XML.Get Element Attribute   ${scf_xml}
        ...   name=distName   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]
        Set To Dictionary   ${testline_scf_dict}   actPowerMeter_dn=${actPowerMeter_dn}

        ${actPowerMeter}   XML.Get Element Text   ${scf_xml}
        ...   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]/p[@name="actPowerMeter"]
        Set To Dictionary   ${testline_scf_dict}   actPowerMeter=${actPowerMeter}

        Run Keyword If   "${testline_type}"=="gnb"
        ...   UUF Get GNB Variables From Backup SCF   scf_xml=${scf_xml}   testline_scf_dict=${testline_scf_dict}

        Run Keyword If   "${testline_type}"=="enb"
        ...   UUF Get ENB Variables From Backup SCF   scf_xml=${scf_xml}   testline_scf_dict=${testline_scf_dict}

        Set To Dictionary   ${ALL_CONFIG_SCF}   ${testline}=${testline_scf_dict}
    END

    # ${ALL_CONFIG_SCF}   Evaluate   json.dumps(${ALL_CONFIG_SCF})   json
    # ${ALL_CONFIG_SCF}   Evaluate   json.loads('${ALL_CONFIG_SCF}')   json
    Set Suite Variable   ${ALL_CONFIG_SCF}
    Log   ${ALL_CONFIG_SCF}

    Set Suite Variable   ${ALL_IP_LIST}
    Log To Console   ALL_IP_LIST: ${ALL_IP_LIST}


UUF Get GNB Variables From Backup SCF
    [Arguments]   ${scf_xml}   ${testline_scf_dict}
    Log To Console   //TODO: UUF Get GNB Variables From Backup SCF
    ${gNbCuType}   XML.Get Element Text   ${scf_xml}
    ...   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="gNbCuType"]
    Set To Dictionary   ${testline_scf_dict}   sw_config=${gNbCuType}

    ${X2_Type}   Set Variable If   "${gNbCuType}"=="NSA" or "${gNbCuType}"=="SA+NSA"   ${True}   ${False}
    ${SA_Type}   Set Variable If   "${gNbCuType}"=="SA" or "${gNbCuType}"=="SA+NSA"   ${True}   ${False}
    Set To Dictionary   ${testline_scf_dict}   X2_Type=${X2_Type}
    Set To Dictionary   ${testline_scf_dict}   SA_Type=${SA_Type}

    # miNrCellAvailability
    ${pm_dn}   XML.Get Element Attribute   ${scf_xml}
    ...   name=distName   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    ${pm_value_r}   XML.Get Element Text   ${scf_xml}
    ...   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]/p[@name="miNrCellAvailability"]

    Set To Dictionary   ${testline_scf_dict}   pm_dn=${pm_dn}
    Set To Dictionary   ${testline_scf_dict}   pm_param=miNrCellAvailability
    Set To Dictionary   ${testline_scf_dict}   pm_value=5min
    Set To Dictionary   ${testline_scf_dict}   pm_value_r=${pm_value_r}

    # actIndSwUpgradeForSharedRU
    ${SharedRU_elements}   XML.Get Elements   ${scf_xml}
    ...   xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:RMOD"]/p[@name="actIndSwUpgradeForSharedRU" and text()="true"]
    ${SharedRU_DN_List}   Create List
    FOR   ${element}   IN  @{SharedRU_elements}
        ${SharedRU_dn}   XML.Get Element Attribute   ${element}   name=distName   xpath=..
        Log To Console   ${SharedRU_dn}
        Append To List   ${SharedRU_DN_List}   ${SharedRU_dn}
    END
    Set To Dictionary   ${testline_scf_dict}   SharedRU_DN_List=${SharedRU_DN_List}


UUF Get ENB Variables From Backup SCF
    [Arguments]   ${scf_xml}   ${testline_scf_dict}
    Log To Console   //TODO: UUF Get ENB Variables From Backup SCF

    # mtCellAvailability
    ${pm_dn}   XML.Get Element Attribute   ${scf_xml}   name=distName   xpath=cmData/managedObject[@class="NOKLTE:PMRNL"]
    ${pm_value_r}   XML.Get Element Text   ${scf_xml}   xpath=cmData/managedObject[@class="NOKLTE:PMRNL"]/p[@name="mtCellAvailability"]
    Set To Dictionary   ${testline_scf_dict}   pm_dn=${pm_dn}
    Set To Dictionary   ${testline_scf_dict}   pm_param=mtCellAvailability
    Set To Dictionary   ${testline_scf_dict}   pm_value=15min
    Set To Dictionary   ${testline_scf_dict}   pm_value_r=${pm_value_r}

    # X2_Type
    ${isGnbLinkStatusExist}   Run Keyword And Return Status   Element Should Exist   ${scf_xml}
    ...   xpath=cmData/managedObject[@class="NOKLTE:LNADJGNB"]/p[@name="x2ToGnbLinkStatus"]
    ${isAdministrativeStateExist}   Run Keyword And Return Status   Element Should Exist   ${scf_xml}
    ...   xpath=cmData/managedObject[@class="NOKLTE:LNADJGNB"]/p[@name="administrativeState"]
    ${X2_Type}   Set Variable If
    ...   ${isGnbLinkStatusExist} and ${isAdministrativeStateExist}   ${True}
    ...   ${False}
    Set To Dictionary   ${testline_scf_dict}   X2_Type=${X2_Type}


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
UUF Get Variables From Others
    Log To Console   //TODO: UUF Get Variables From Others
    # ${SUITE_NAME}   Set Variables   UUF_TL852_Webui_1
    # ${SUITE_NAME}   Set Variables   UUF_TL852_NetAct_2
    # ${SUITE_NAME}   Set Variables   UUF_TL852_Rest_3
    # ${SUITE_NAME}   Set Variables   Webui_C2C_UUF
    # ${SUITE_NAME}   Set Variables   NetAct_C2C_UUF
    # ${SUITE_NAME}   Set Variables   Webui_Reset
    # ${UUF}   ${testline_id}   ${UUF_FUNCTION}   ${Repetation}   Split String   ${SUITE_NAME}   _

    Set Suite Variable   ${UUF_FUNCTION}   others
    Run Keyword If   "${SUITE_NAME.lower().find('webui')}"!="-1"   Set Suite Variable   ${UUF_FUNCTION}   webui
    Run Keyword If   "${SUITE_NAME.lower().find('netact')}"!="-1"   Set Suite Variable   ${UUF_FUNCTION}   netact
    Run Keyword If   "${SUITE_NAME.lower().find('reset')}"!="-1"   Set Suite Variable   ${UUF_FUNCTION}   reset

    # Get Testline Name from cmd line parameters
    ${args}   Evaluate   sys.argv   sys
    ${index}   Get Index From List   ${args}   -V
    ${variables_path}   Get Variable Value   ${args[int(${index})+1]}   UUF4ALL
    ${variables_path}   Set Variable If   "${variables_path[-1]}"=="/"   ${variables_path[:-1]}   ${variables_path}
    ${variables_path}   Split String   ${variables_path}   /
    Set Suite Variable   ${TESTLINE_NAME}   ${variables_path[-1]}
    Log To Console      TESTLINE_NAME: ${TESTLINE_NAME}

    # Get NetAct IP LIST From NetAct Config File
    ${status}   ${NetAct_HOST_LIST}   Run Keyword And Ignore Error   Get NetAct Host IP List From Config File
    Run Keyword If   "${status}"=="FAIL"   Set Suite Variable   ${NetAct_HOST_LIST}   ${EMPTY}
    ...   ELSE   Set Suite Variable   ${NetAct_HOST_LIST}
    Log To Console      NetAct_HOST_LIST: ${NetAct_HOST_LIST}

    # Download Package VM List
    @{Download_Package_VM_List}   Create List
    Set Suite Variable   ${DOWNLOAD_PACKAGE_VM_LIST}

    # Set Log Flags
    UUF Set Log Collection Flags

    # Set Testline Flags From Others
    ${ALL_CONFIG_OTHERS}   Create Dictionary
    FOR   ${testline}   IN   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}
        ${testline_others_dict}   Create Dictionary

        ${common_units}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['common_units']}
        ${common_units_number}   Get Length   ${common_units}
        ${isDualCore}   Set Variable If   ${common_units_number} == 2   ${True}   ${False}
        Set To Dictionary   ${testline_others_dict}   isDualCore=${isDualCore}

        ${return_dict}   UUF Get Hostname And Container ID   testline=${testline}
        Set To Dictionary   ${testline_others_dict}   &{return_dict}

        Set To Dictionary   ${ALL_CONFIG_OTHERS}   ${testline}=${testline_others_dict}
    END
    Set Suite Variable   ${ALL_CONFIG_OTHERS}

    # Set Testline Flags From Others
    &{SCOUT_TESTLINE_MAPPING}   Create Dictionary
    FOR   ${testline}   IN   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}
        ${testline_ip_addr}   Get Variable Value   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}   ${EMPTY}
        Continue For Loop If   "${testline_ip_addr}"=="${EMPTY}"

        ${testline_scout_name}   Get Variable Value   ${SCOUT_IP_MAPPING["${testline_ip_addr}"]}   ${EMPTY}
        Continue For Loop If   "${testline_scout_name}"=="${EMPTY}"

        Set To Dictionary   ${SCOUT_TESTLINE_MAPPING}   ${testline}=${testline_scout_name}
    END
    Set Suite Variable   ${SCOUT_TESTLINE_MAPPING}



# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================


UUF Get Variables From L3CALL
    [Arguments]   ${scf_prefix}=SCF_Prepare

    #Get cell rmod mapping and cell arfcn mapping list
    ${L3CALL_CONFIG_SCF}   Create Dictionary
    ${multitl_total_cellnum}    set variable   0
    FOR   ${testline}   IN   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}
        ${testline_scf_dict}   Create Dictionary

        ${testline_type}   ${testline_index}   Split String   ${testline}   _

        ${scf_path}   Set Variable   ${OUTPUT_DIR}/${scf_prefix}_${testline}.xml
        ${scf_xml}   XML.Parse XML   ${scf_path}

        ${rmod_cell_mapping}   ${singletl_total_cellnum}    UUF Get RMOD SN Cell Mapping From Full SCF   source=${scf_xml}
        Set To Dictionary   ${testline_scf_dict}   rmod_cell_mapping=${rmod_cell_mapping}

        Run Keyword If   "${testline_type}"=="gnb"
        ...   UUF Get NRCELL ARFCN List   source=${scf_xml}   testline_scf_dict=${testline_scf_dict}

        Set To Dictionary   ${L3CALL_CONFIG_SCF}   ${testline}=${testline_scf_dict}
        ${multitl_total_cellnum}    run keyword if    ('${testline}' in ${UUF_L3Call["${TESTLINE_IDENTITY}"]})
        ...   evaluate    ${singletl_total_cellnum}+${${multitl_total_cellnum}}
        ...   ELSE   Set Variable    ${multitl_total_cellnum}

    END
    Set Suite Variable   ${L3CALL_CONFIG_SCF}
    Set Suite Variable   ${multitl_total_cellnum}



    # Set  L3CALL list inclue PCI,  CELLDN,  ARFCN,  BAND, celltechnology
    ${ALL_CONFIG_L3CALL}   Create Dictionary
    FOR   ${testline}   IN   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}
        ${testline_L3CALL_dict}   Create Dictionary

        ${bts_info}   UUF Get Bts Info    testline=${testline}
        Set To Dictionary   ${testline_L3CALL_dict}   &{bts_info}

        UUF Set L3CALL Cells List ALL UE   source=${scf_xml}
        ...    testline_L3CALL_dict=${testline_L3CALL_dict}    btsinfo=${btsinfo}    testline=${testline}

        Set To Dictionary   ${ALL_CONFIG_L3CALL}   ${testline}=${testline_L3CALL_dict}
    END
    Set Suite Variable   ${ALL_CONFIG_L3CALL}


UUF Set L3CALL Cells List ALL UE
    [Arguments]   ${source}   ${testline_L3CALL_dict}    ${btsinfo}    ${testline}
    ${value}    get variable value    ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${testline}"]}
    Return From Keyword If    ${value}==${None}
    FOR   ${ue_index}    IN   @{UUF_L3Call["${TESTLINE_IDENTITY}"]["${testline}"].keys()}
        ${L3CALL_cell_list}
        ...    UUF Get Cells List for L3CALL Per UE
        ...    source=${source}    btsinfo=${btsinfo}    testline=${testline}   ue_index=${ue_index}
        Set To Dictionary   ${testline_L3CALL_dict}   UE${ue_index}_L3CALL_cell_list=${L3CALL_cell_list}
    END


UUF Get Testline Type
    Log To Console   //TODO: UUF Get Testline Type
    UUF Get UUF Testline Category
    UUF Get Same RU Testline Mapping
    UUF Get UUF Procedure Sequence


UUF Get UUF Testline Category
    ${gnb_list}   Create List
    ${concurrent_enb_list}   Create List
    ${x2_enb_list}   Create List

    ${isMoRAN}   Set Variable   ${False}
    ${isConCurrent}   Set Variable   ${False}
    ${isMultiGnb}   Set Variable   ${False}
    ${isSingleGnb}   Set Variable   ${False}

    ${all_gnb_ru_sn}   Create List
    FOR   ${testline}   IN   @{ALL_GNB_LIST}
        # ${gnb_ru_sn_list}   UUF Get RMOD SerialNumber List   full_scf_path=SCF_Prepare_${testline}.xml
        ${gnb_ru_sn_list}   Set Variable   ${ALL_CONFIG_SCF["${testline}"]["rmod_serial_list"]}
        ${isMoRAN}   Set Variable If   len([c for c in ${all_gnb_ru_sn} if c in ${gnb_ru_sn_list}]) != 0   ${True}   ${isMoRAN}
        # Run Keyword If   len([c for c in ${all_gnb_ru_sn} if c in ${gnb_ru_sn_list}]) != 0   Set Suite Variable   ${isMoRAN}   ${True}
        Append To List   ${all_gnb_ru_sn}   @{gnb_ru_sn_list}
        Append To List   ${gnb_list}   ${testline}
    END

    FOR   ${testline}   IN   @{ALL_ENB_LIST}
        # ${enb_ru_sn_list}   UUF Get RMOD SerialNumber List   full_scf_path=SCF_Prepare_${testline}.xml
        ${enb_ru_sn_list}   Set Variable   ${ALL_CONFIG_SCF["${testline}"]["rmod_serial_list"]}
        Run Keyword If   len([c for c in ${all_gnb_ru_sn} if c in ${enb_ru_sn_list}]) != 0   Append To List   ${concurrent_enb_list}   ${testline}
        ...   ELSE   Append To List   ${x2_enb_list}   ${testline}
    END

    # UUF Get Testline Category
    # Usage: classify different testline category, use for UUF process or others
    # Example:
    #       GNB_LIST: ['gnb_0']
    #       CONCURRENT_ENB_LIST: ['enb_1', 'enb_2']
    #       X2_ENB_LIST: ['enb_0']
    Set Suite Variable   ${GNB_LIST}
    Set Suite Variable   ${CONCURRENT_ENB_LIST}
    Set Suite Variable   ${X2_ENB_LIST}

    Log To Console   GNB_LIST: ${GNB_LIST}
    Log To Console   CONCURRENT_ENB_LIST: ${CONCURRENT_ENB_LIST}
    Log To Console   X2_ENB_LIST: ${X2_ENB_LIST}

    # UUF Set Testline Category Flag
    ${isMoRAN}   Set Variable If   len(${gnb_list}) >= 2 and ${isMoRAN}   ${True}   ${False}
    ${isConCurrent}   Set Variable If   len(${concurrent_enb_list}) != 0   ${True}   ${False}
    ${isSingleGnb}   Set Variable If   len(${gnb_list}) == 1 and not ${isConCurrent}   ${True}   ${False}
    ${isMultiGnb}   Set Variable If   len(${gnb_list}) >= 2 and not ${isMoRAN}   ${True}   ${False}

    Set Suite Variable   ${isMoRAN}
    Set Suite Variable   ${isConCurrent}
    Set Suite Variable   ${isMultiGnb}
    Set Suite Variable   ${isSingleGnb}

    Log To Console   isMoRAN: ${isMoRAN}
    Log To Console   isConCurrent: ${isConCurrent}
    Log To Console   isMultiGnb: ${isMultiGnb}
    Log To Console   isSingleGnb: ${isSingleGnb}


UUF Get Same RU Testline Mapping
    @{ALL_Testline_List}   Create List   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}
    &{all_ru_sn}   Create Dictionary
    FOR   ${testline}   IN   @{ALL_Testline_List}
        # ${ru_sn_list}   UUF Get RMOD SerialNumber List   full_scf_path=SCF_Prepare_${testline}.xml
        ${ru_sn_list}   Set Variable   ${ALL_CONFIG_SCF["${testline}"]["rmod_serial_list"]}
        Set To Dictionary   ${all_ru_sn}   ${testline}=${ru_sn_list}
    END

    # ${list}   Evaluate   [(i,j) for i in ${all_ru_sn} for j in ${all_ru_sn} if i!=j and [c for c in ${all_ru_sn}\[i\] if c in ${all_ru_sn}\[j\]]]
    # ${list}   Evaluate   [(i,j) for i in ${all_ru_sn} for j in ${all_ru_sn} if i!=j and bool(set(${all_ru_sn}\[i\]) & set(${all_ru_sn}\[j\]))]
    ${list}   Evaluate   [(i,j) for i in ${all_ru_sn} for j in ${all_ru_sn} if not set(${all_ru_sn}\[i\]).isdisjoint(${all_ru_sn}\[j\])]

    # Get Same RU Testline Mapping
    # Usage: Use for catch mapping testline snapshot when a testline failed
    # Example: {'gnb_0': ['gnb_0', 'enb_1', 'enb_2'], 'enb_0': ['enb_0'], 'enb_1': ['gnb_0', 'enb_1'], 'enb_2': ['gnb_0', 'enb_2']}
    &{ALL_SAME_RU_TESTLINE_MAPPING}   Create Dictionary
    &{ALL_SAME_RU_SERIALNUMBER_MAPPING}   Create Dictionary
    FOR   ${testline_mapping}   IN   @{list}
        ${testline_key}   Set Variable   ${testline_mapping[0]}
        ${testline_value}   Set Variable   ${testline_mapping[1]}

        @{testline_list}   Get Variable Value   ${ALL_SAME_RU_TESTLINE_MAPPING['${testline_key}']}   @{EMPTY}
        @{new_mapping}   Create List   @{testline_list}   ${testline_value}
        Set To Dictionary   ${ALL_SAME_RU_TESTLINE_MAPPING}   ${testline_key}=${new_mapping}

        @{sn_list}   Get Variable Value   ${ALL_SAME_RU_SERIALNUMBER_MAPPING['${testline_key}']}   @{EMPTY}
        @{new_sn_list}   Create List   @{sn_list}   @{all_ru_sn["${testline_value}"]}
        Set To Dictionary   ${ALL_SAME_RU_SERIALNUMBER_MAPPING}   ${testline_key}=${new_sn_list}
    END
    Log To Console   ALL_SAME_RU_TESTLINE_MAPPING: ${ALL_SAME_RU_TESTLINE_MAPPING}
    Set Suite Variable   ${ALL_SAME_RU_TESTLINE_MAPPING}


    # Get Same RU Serial Number Mapping
    # Usage: Use for MoRAN actIndSwUpgradeForSharedRU
    # Example: {'gnb_0': ['1M212807211', '4H210730017', '1M212706011'], 'gnb_1': ['1M212807211', '4H210730017', '1M212706011'], 'enb_0': []}
    FOR   ${testline}   IN   @{ALL_SAME_RU_SERIALNUMBER_MAPPING}
        ${sn_list}   Set Variable   ${ALL_SAME_RU_SERIALNUMBER_MAPPING["${testline}"]}
        ${sn_list}   Evaluate   [item for item, count in collections.Counter(${sn_list}).items() if count > 1]   collections
        Set To Dictionary   ${ALL_SAME_RU_SERIALNUMBER_MAPPING}   ${testline}=${sn_list}
    END
    Log To Console   ALL_SAME_RU_SERIALNUMBER_MAPPING: ${ALL_SAME_RU_SERIALNUMBER_MAPPING}
    Set Suite Variable   ${ALL_SAME_RU_SERIALNUMBER_MAPPING}


UUF Get UUF Procedure Sequence
    ${gnb_list}   Evaluate   random.sample(${GNB_LIST}, len(${GNB_LIST}))   random
    ${concurrent_enb_list}   Evaluate   random.sample(${CONCURRENT_ENB_LIST}, len(${CONCURRENT_ENB_LIST}))   random
    ${x2_enb_list}   Evaluate   random.sample(${X2_ENB_LIST}, len(${X2_ENB_LIST}))   random

    # Set UUF Sequence BY Default
    ${UPGRADE_SEQUENCE}   Create List   @{GNB_LIST}   @{CONCURRENT_ENB_LIST}
    ${ROLLBACK_SEQUENCE}   Create List   @{CONCURRENT_ENB_LIST}   @{GNB_LIST}
    ${RESET_SEQUENCE}   Create List   @{GNB_LIST}   @{CONCURRENT_ENB_LIST}

    # Set UUF Sequence BY UUF_Config
    ${Specific_Upgrade_TL_Keys}   Get Dictionary Keys   ${Specific_Upgrade_TL}
    ${Specific_Rollback_TL_Keys}   Get Dictionary Keys   ${Specific_Rollback_TL}
    ${Specific_Reset_TL_Keys}   Get Dictionary Keys   ${Specific_Reset_TL}

    ${UPGRADE_SEQUENCE}   Set Variable If   "${TESTLINE_IDENTITY}" in ${Specific_Upgrade_TL_Keys}
    ...   ${Specific_Upgrade_TL['${TESTLINE_IDENTITY}']}   ${UPGRADE_SEQUENCE}
    ${ROLLBACK_SEQUENCE}   Set Variable If   "${TESTLINE_IDENTITY}" in ${Specific_Rollback_TL_Keys}
    ...   ${Specific_Rollback_TL['${TESTLINE_IDENTITY}']}   ${ROLLBACK_SEQUENCE}
    ${RESET_SEQUENCE}   Set Variable If   "${TESTLINE_IDENTITY}" in ${Specific_Reset_TL_Keys}
    ...   ${Specific_Reset_TL['${TESTLINE_IDENTITY}']}   ${RESET_SEQUENCE}

    ${PREPARE_SEQUENCE}   Set Variable If   "${UUF_FUNCTION}"=="reset"   ${RESET_SEQUENCE}   ${UPGRADE_SEQUENCE}

    # UUF Get UUF Procedure Sequence
    # Usage:
    # Example:
    #       UPGRADE_SEQUENCE: ['gnb_0', 'enb_1', 'enb_2']
    #       ROLLBACK_SEQUENCE: ['enb_1', 'enb_2', 'gnb_0']
    #       RESET_SEQUENCE: ['gnb_0', 'enb_1', 'enb_2']
    Set Suite Variable   ${PREPARE_SEQUENCE}
    Set Suite Variable   ${UPGRADE_SEQUENCE}
    Set Suite Variable   ${ROLLBACK_SEQUENCE}
    Set Suite Variable   ${RESET_SEQUENCE}

    Log To Console   PREPARE_SEQUENCE: ${PREPARE_SEQUENCE}
    Log To Console   UPGRADE_SEQUENCE: ${UPGRADE_SEQUENCE}
    Log To Console   ROLLBACK_SEQUENCE: ${ROLLBACK_SEQUENCE}
    Log To Console   RESET_SEQUENCE: ${RESET_SEQUENCE}


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
UUF Log ALL Suite Variables
    Log To Console   Log ALL Suite Variables:
    # Run Keyword And Ignore Error   Log To Console   ${MRBTS_ID}
    # Run Keyword And Ignore Error   Log To Console   GNB Source Build: ${origin_version}
    # Run Keyword And Ignore Error   Log To Console   GNB Target Build: ${upgrade_version}
    # Run Keyword And Ignore Error   Log To Console   ENB Source Build: ${enb_source_version}
    # Run Keyword And Ignore Error   Log To Console   ENB Target Build: ${enb_target_version}

    Run Keyword And Ignore Error   Log To Console   TESTLINE_IDENTITY: ${TESTLINE_IDENTITY}

    Run Keyword And Ignore Error   Log To Console   ALL_CONFIG_INIT: \n${ALL_CONFIG_INIT}
    Run Keyword And Ignore Error   Log To Console   ALL_CONFIG_SCF: \n${ALL_CONFIG_SCF}
    # Run Keyword And Ignore Error   Log To Console   ${ALL_CONFIG_OTHERS}
    Run Keyword And Ignore Error   Log To Console   ALL_GNB_LIST: ${ALL_GNB_LIST}
    Run Keyword And Ignore Error   Log To Console   ALL_ENB_LIST: ${ALL_ENB_LIST}

    Run Keyword And Ignore Error   Log To Console   gnb_list: ${gnb_list}
    Run Keyword And Ignore Error   Log To Console   concurrent_enb_list: ${concurrent_enb_list}
    Run Keyword And Ignore Error   Log To Console   x2_enb_list: ${x2_enb_list}

    Run Keyword And Ignore Error   Log To Console   UPGRADE_SEQUENCE: ${UPGRADE_SEQUENCE}
    Run Keyword And Ignore Error   Log To Console   ROLLBACK_SEQUENCE: ${ROLLBACK_SEQUENCE}
    Run Keyword And Ignore Error   Log To Console   RESET_SEQUENCE: ${RESET_SEQUENCE}

    Run Keyword And Ignore Error   Log To Console   isMoRAN: ${isMoRAN}
    Run Keyword And Ignore Error   Log To Console   isConCurrent: ${isConCurrent}
    Run Keyword And Ignore Error   Log To Console   isMultiGnb: ${isMultiGnb}
    Run Keyword And Ignore Error   Log To Console   isSingleGnb: ${isSingleGnb}

    Run Keyword And Ignore Error   Log To Console   UPGRADE_BUILD_INFO_DICT: \n${UPGRADE_BUILD_INFO_DICT}

    Run Keyword And Ignore Error   Log To Console   NETACT_IP: ${NETACT_IP}


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
UUF Remove Precheck Testline Log
    Run Keyword And Ignore Error   OperatingSystem.Run
    ...   sudo rm -rf /opt/transformers.dynamic.nsn-net.net/HZ_*/workspace/UUF_NEW/Master/Precheck_Testline


UUF Check Env VM
    Log To Console   //TODO: UUF Check Env VM
    # Download Golden SCF Project
    Download Golden SCF Project
    Log To Console   Golden SCF Project Dir: ${GOLDEN_SCF_DIR}\n

    Download UBOOT Scripts
    Log To Console   UBOOT Scripts Project Dir: ${UBOOT_SCRIPTS_DIR}\n

    # Check VM Available Space
    Check VM Available Space

    # Update Ping command permission
    Run Keyword And Ignore Error   OperatingSystem.Run   sudo chmod +s /usr/bin/ping


UUF Check Env Testline
    Log To Console   //TODO: UUF Check Env Testline
    # if test_mode == UUF
    #     Precheck RU Flags
    #     Check and Ensure btslog Flag in Swconfig File
    #     Check Flag in FSMF
    #     Check if Other Flag Added
    # ->  others?

    @{check_sequence}   Create List   @{ALL_GNB_LIST}   @{ALL_ENB_LIST}

    FOR   ${testline}   IN   @{check_sequence}
        COAM Login
        ...   bts_host=${webem_addr}
        ...   username=${webem_username}
        ...   password=${webem_password}
        ...   alias=${testline}

        ${status}   Run Keyword And Return Status   UUF Wait Times BBMOD Enabled   testline=${testline}   retry=5m
        Run Keyword If   ${status}    Run Keyword And Ignore Error   COAM Logout   connection=${testline}
        continue for loop if   ${status}

        ${testline_list}   Create List   ${testline}

        ${fail_log_dir}   Set Variable   ${OUTPUT_DIR}/${SUITE_NAME}
        log to console    fail_log_dir is ${fail_log_dir}!
        ${fail_log_dir_not_exist}   Run Keyword And Return Status   Directory Should Not Exist   ${fail_log_dir}
        Run Keyword If   ${fail_log_dir_not_exist}   OperatingSystem.Create Directory   ${fail_log_dir}
        log to console    Start to collect snapshot because BBMOD status is ${status}!

        Run Keyword And Ignore Error   UUF Catch Snapshot   testline_list=${testline_list}    log_dir=${fail_log_dir}   prefix=FAIL_TestSuite
        Log To Console   Recovery Action: Reset Site: ${testline}

        Run Keyword And Ignore Error   COAM Reset Site   connection=${testline}
        Run Keyword And Continue On Failure   UUF Wait Times For Cell OnAir   testline=${testline}

        log to console    Start to collect snapshot after recovery action!
        Run Keyword And Ignore Error   UUF Catch Snapshot   testline_list=${testline_list}   log_dir=${fail_log_dir}
        ...   prefix=FAIL_TestSuite_After_Recovery

        Run Keyword And Ignore Error   COAM Logout   connection=${testline}
    END

# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================

UUF ALL WorkAround
    Log To Console   //TODO: UUF ALL WorkAround
    # all wa before uuf upgrade
    #     ->  modify scf
    #     ->  enable ssh
    #     ->  ?

    # remove source build after upgrade to source package
    # rm -rf ${UPGRADE_BUILD_INFO_DICT['enb']['source']['path']}
    # rm -rf ${UPGRADE_BUILD_INFO_DICT['gnb']['source']['path']}

    #check DSS testline
        # ->  ignore alarm

    #Modify miNrCellAvailability
    # MRBTS-89/NRBTS-11647/NRPMRNL-1
    # miNrCellAvailability
    # MRBTS-89/LNBTS-89/PMRNL-1
    # mtCellAvailability

    Return From Keyword If   ${DEBUG}

    # UUF Modify PM Report Parameter
    UUF WorkAround Update SCF Configuration
    Check All Testline Flag in Swconfig File

    UUF Enable RU LMI Connection Through Testline
    Check ALL RU swconfig From LMI


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================

UUF Pass Execution
    ${package_version}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['gnb']['target']['version']}   ${EMPTY}
    ${source_package_version}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['gnb']['source']['version']}   ${EMPTY}
    # Run Keyword If   "${package_version}"==""   Set Sutie Variable   ${PASS_UUF_PROCESS}   ${True}
    Pass Execution If   "${package_version}"=="" or "${package_version}"=="${None}" or "${package_version}"=="${source_package_version}"
    ...   Skip UUF Process.
