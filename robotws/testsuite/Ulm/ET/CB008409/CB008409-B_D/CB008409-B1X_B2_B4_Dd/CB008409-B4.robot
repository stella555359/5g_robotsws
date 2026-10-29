*** Settings ***

Documentation
...    CLOUD_5G_I_LO_AP_LO  VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...    Author: Ulm SQD 66 / Ulm VRF VT 6
...    Contact: I_MN_RAN_L2_SW_ULM_SQD_66@internal.nsn.com
...    Description: These testcases are validating the gNB behavior to improve link level performance, by reducing number of DL HARQ retransmissions
...                 and reducing overall DL residual BLER (rBLER) for VoNR and SRB 1/2 transmissions, using higher power per PRB for retransmissions.

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    OperatingSystem
Library    String
Library    taf.config.wts    WITH NAME    wts
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Resource   ../../../../resources/Common/gnb.robot
Resource   ../../../L2/resources/robot/test_setup.robot
Resource   ../../../L2/resources/common_keywords.robot
Resource   ../../../L2/resources/robot/tracing.robot
Resource   resources/CB008409-B1X_B2_B4_Dd_scenario_modifications.robot
Resource   ../../CB008409-B_D/resources/CB008409-B_D_scenario_validations.robot


Suite Setup     test_setup.Initialize Test Suite
Suite Teardown  common_keywords.Capture Snapshot And Restore Config
Test Teardown   common_keywords.Stop Logs And Collect Traces


*** Variables ***
${pm_reporting_interval}          5min
${relative_json_path}             ../../CB008409/CB008409-B_D/CB008409-B1X_B2_B4_Dd/CB008409-B4.json
${REINIT_GNB}                     true
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB008409_B_ET_TC_B4_IWK_MultipleBWP
    [Tags]    B4
    common_keywords.Run Test Scenario
    CB008409-B_D_scenario_validations.Prepare Variables For Validations    scenario=scenario_B4
    CB008409-B_D_scenario_validations.Get Key TTI Events
    CB008409-B_D_scenario_validations.Verify MaxNumberOfPRBperSlot
    CB008409-B_D_scenario_validations.Verify Power Boost For ReTx
    CB008409-B_D_scenario_validations.Verify RBG Randomization
    tracing.Check For Errors In Syslog


*** Keywords ***
OFFLINE
    [Tags]    OFFLINE
    # IMPORTANT: do not forget to comment out the Suite/Test Setup/Teardown KWs on top of this file!
    # IMPORTANT: do not forget to comment out the *** Keyowrd ***
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/DEVELOPMENT/robotws/CB008409-B/SBTS00_ENB_9999_240928_000004/20240930_141816
    Set Test Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Test Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB008409-B_D_scenario_validations.Prepare Variables For Validations    scenario=scenario_B4
    # Comment below 2 lines out for pcap to pickle conversion, if needed
    #Extract TTI Trace and Convert to Pickle    path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector_name}/
    #...    ttitrace_streaming.pcap
    Verify maxNumberOfPRBperSlot
    Verify power boost for ReTx
    CB008409-B_D_scenario_validations.Verify RBG Randomization
    Verify Errors and Warnings in SYSLOG Trace


*** Keywords ***
#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]
Make necessary Changes to SCF
    [Documentation]
    Update Requested RnD flags in SW config file
    Delta Json Commission With NIDD Default Value    CB008409-B4_NIDD_Configuration.json
    gnb.Get SCF From GNB    gnb_id=${0}   target_dir=${CONFIGURATION_DIRECTORY}    scf_name=scf_${SUITE_NAME}.xml
    Modify iphy.xml for BWP_PS Cell Setup


Update Basic Configuration File
    [Documentation]  WTS Basic config Prepration:
    ...    add wts core simulator config for HR-DRB on qos_flow 4, assigned to 5QI=7, as configured in gnbSCF
    ...    Modify GSCN for cell1 to map BWP_PS Bandwidth
    wts.Load Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}
      wts.Insert    set_qosflow id=4 5qi=7                          after    set_qosflow id=3
      wts.Insert    set_qosrule id=3 proto=udp qos_flow=4           after    set_qosrule id=2
      wts.Modify    nwslice_set id=1    modification=qos_flows=1,2,3,4 qos_rules=1,2,3
      wts.Modify    set_cell id=1 gnb=2    nr_arfcn=636666:636666 gscn=7867
      wts.Modify    set_cell id=2 gnb=2    nr_arfcn=636666:636666 gscn=7867
    wts.Save Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}


Update Requested RnD flags in SW config file
    [Documentation]     AP tx power alignement is not calibratred by default, fix calibration in FDD cells
    @{AP_MOD_RD_FLAGS}=  create list  0x70700=6400    # Open Loop Power Control for FDD
    Update SW Config file on AP System Module    param_list=${AP_MOD_RD_FLAGS}
    Set suite variable    ${force_reboot}    ${true}


Delta Json Commission With NIDD Default Value
    [Arguments]    ${delta_file_name}    ${gnb_id}=${0}    ${port}=3600    ${alias}=cOAM
    coam.connect_to
    ...    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...    bts_port=${port}    name=${alias}
    coam.Perform_Delta_Recommissioning
    ...    delta_file=${CURDIR}/resources/${delta_file_name}
    ...    skip_parameter_relation_errors=false
    ...    should_activate=true
    ...    timeout=180
    ...    connection=${alias}
    coam.teardown    connection=${alias}


Modify iphy.xml for BWP_PS Cell Setup
    [Documentation]    Reconfigure iphy.xml file to change the GSCN of TDD Cell_1 to match the GSCN in SCF and basic_config
    [Arguments]
    ${ap_alias}    connect . Connect to Airphone Common Unit
    ssh.execute          cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ap_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml        ${CONFIGURATION_DIRECTORY}/new_iphy.xml    connection=${ap_alias}
        ${contents}         OperatingSystem.Get File          ${CONFIGURATION_DIRECTORY}/new_iphy.xml
        ${all_parts}        String.Split String      ${contents}     </vcell>
        ${GSCN_update_0}    String.Replace String Using Regexp    ${all_parts}[0]      GSCN>.*<\/GSCN>   GSCN>7867<\/GSCN>
        ${GSCN_update_1}    String.Replace String Using Regexp    ${all_parts}[1]      GSCN>.*<\/GSCN>   GSCN>7867<\/GSCN>
        ${new contents}     Catenate     SEPARATOR=</vcell>   ${GSCN_update_0}  ${GSCN_update_1}  ${all_parts}[2]  ${all_parts}[3]  ${all_parts}[4]
        OperatingSystem.Create File          ${CONFIGURATION_DIRECTORY}/new_iphy_B4_BWPPS.xml    ${new contents}
    ssh.Upload File      ${CONFIGURATION_DIRECTORY}/new_iphy_B4_BWPPS.xml    /rom/simmode/new_iphy.xml   connection=${ap_alias}


