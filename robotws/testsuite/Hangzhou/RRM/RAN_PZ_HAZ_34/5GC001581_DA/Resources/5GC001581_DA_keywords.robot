*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library     taf.gnb.oam.coam.cu   WITH NAME   api_cu
Library     OperatingSystem


*** Variables ***
${TSHARK_PATH}            /usr/bin/tshark
${PDML_CONVERT_F1AP_TEMPLATE}      {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
${PDML_CONVERT_X2AP_TEMPLATE}      {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
${PATH_UE_NR1}  nr-rrc.ue_CapabilityInfo/nr-rrc.UE_CapabilityRAT_ContainerList/*[@show="Item 1"]
${PATH_UE_NR2}  nr-rrc.UE_CapabilityRAT_Container_element/nr-rrc.ue_CapabilityRAT_Container/nr-rrc.UE_NR_Capability_element
${PATH_UE_MRDC1}  nr-rrc.ue_CapabilityInfo/nr-rrc.UE_CapabilityRAT_ContainerList//nr-rrc.UE_CapabilityRAT_Container_element
${PATH_UE_MRDC2}  nr-rrc.ue_CapabilityRAT_Container/nr-rrc.UE_MRDC_Capability_element
${PATH_RF_PARAMETER}        nr-rrc.rf_Parameters_element/nr-rrc.supportedBandListNR//nr-rrc.BandNR_element
${PATH_BANDCOMBINATION}  nr-rrc.rf_ParametersMRDC_element/nr-rrc.supportedBandCombinationList//nr-rrc.BandCombination_element
${RECOVERY_TIMEOUT}    10 min
${SCF_DEFAULT_DU_FILE_PATH}      /home/ute/Projects/mmw1_config/${testline_name}/scf/GNB_SCF_DU_MMW1_TL${tl.gnbs[0].instance_id}.xml
${TIMEOUT}     10min
${P_console}    False


*** Keywords ***
Suite preparation
    [Documentation]    Author: Zhang Ningning
    ${SCF_DEFAULT_FILE_PATH_CU}    Get SCF template path for CU
    Set suite variable    ${SCF_DEFAULT_FILE_PATH_CU}
    Common suite setup preparation    cu_scf_parameters_list=${None}    cu_scf_template_path=${SCF_DEFAULT_FILE_PATH_CU}
    ...    du_scf_parameters_list=${None}    du_scf_template_path=${SCF_DEFAULT_DU_FILE_PATH}
    ...    cu_timeout=10min
    ...    is_pdl_checking_needed=${False}


Case preparation
    [Documentation]  Author: Zhang Ningning
    ...              Description: Precondition for case 028, which need configuration for 2*2
    Common case setup
    Cloud DU connect to gnb coam via ssl


Check ue capabilities
    [Documentation]    Author: Zhang Ningning
    ...    This keyword is for checking UE capability in f1ap:UEContextSetupRequest in CG-ConfigInfor
      [Arguments]  ${file_path}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${file_path}  tshark_path=${TSHARK_PATH}
    ...   command_template=${PDML_CONVERT_F1AP_TEMPLATE}
    ${UE_MRDC_Capability_msg}     cap.get_field_value_by_xpath    pdml_list=${all_packets}
    ...      xpath=.//${PATH_UE_MRDC1}/${PATH_UE_MRDC2}
    ...     attribute_name=showname
    run keyword and continue on failure  should be equal as strings     ${UE_MRDC_Capability_msg[0]}  UE-MRDC-Capability
    ...  msg=check UE_MRDC_Capability_msg failed!
    ${UE_NR_Capability_msg}     cap.get_field_value_by_xpath    pdml_list=${all_packets}
    ...      xpath=.//${PATH_UE_NR1}/${PATH_UE_NR2}
    ...     attribute_name=showname
    run keyword and continue on failure  should be equal as strings     ${UE_NR_Capability_msg[0]}    UE-NR-Capability
    ...  msg=check UE_NR_Capability_msg failed!
    ${BandCombination_msg}     cap.get_field_value_by_xpath    pdml_list=${all_packets}
    ...      xpath=.//${PATH_UE_MRDC1}/${PATH_UE_MRDC2}/${PATH_BANDCOMBINATION}
    ...     attribute_name=showname
    run keyword and continue on failure  should not be empty     ${BandCombination_msg}    msg=check BandCombination_msg failed!
    ${BandNR_msg}     cap.get_field_value_by_xpath    pdml_list=${all_packets}
    ...      xpath=.//${PATH_UE_NR1}/${PATH_UE_NR2}/${PATH_RF_PARAMETER}
    ...     attribute_name=showname
    run keyword and continue on failure  should not be empty     ${BandNR_msg}     msg=check BandNR_msg failed!
    ${pdcp_Parameters_msg}     cap.get_field_value_by_xpath    pdml_list=${all_packets}
    ...      xpath=.//${PATH_UE_NR1}/${PATH_UE_NR2}/nr-rrc.pdcp_Parameters_element
    ...     attribute_name=showname
    run keyword and continue on failure  should be equal as strings     ${pdcp_Parameters_msg[0]}     pdcp-Parameters
    ...  msg=check pdcp_Parameters_msg failed!
    ${rlc_Parameters_msg}     cap.get_field_value_by_xpath    pdml_list=${all_packets}
    ...      xpath=.//${PATH_UE_NR1}/${PATH_UE_NR2}/nr-rrc.rlc_Parameters_element
    ...     attribute_name=showname
    run keyword and continue on failure  should be equal as strings     ${rlc_Parameters_msg[0]}     rlc-Parameters
    ...  msg=check rlc_Parameters_msg failed!
    ${phy_Parameters_msg}     cap.get_field_value_by_xpath    pdml_list=${all_packets}
    ...      xpath=.//${PATH_UE_NR1}/${PATH_UE_NR2}/nr-rrc.phy_Parameters_element
    ...     attribute_name=showname
    run keyword and continue on failure  should be equal as strings     ${phy_Parameters_msg[0]}      phy-Parameters
    ...   msg=check phy_Parameters_msg failed!
    ${mimo_ParametersPerBand_msg}     cap.get_field_value_by_xpath    pdml_list=${all_packets}
    ...      xpath=.//${PATH_UE_NR1}/${PATH_UE_NR2}/${PATH_RF_PARAMETER}/nr-rrc.mimo_ParametersPerBand_element
    ...     attribute_name=showname
    run keyword and continue on failure  should not be empty     ${mimo_ParametersPerBand_msg}
    ...  msg=check mimo_ParametersPerBand_msg failed!

Check dldata forwarding didn't be supported
    [Documentation]    Author: Zhang Ningning
    ...    This keyword is for checking not support dldata forwarding
    ...   in x2ap:SgNBAdditionRequestAcknowledge. RRC Reconfiguration
    [Arguments]     ${file_path}    ${key_string}=x2ap.dL_Forwarding_GTPtunnelEndpoint_element
    ${all_packets}=  cap.load_pcap_file    pcap_file=${file_path}    tshark_path=${TSHARK_PATH}
    ...  command_template=${PDML_CONVERT_X2AP_TEMPLATE}

    ${output}   OperatingSystem.grep file    ${file_path}
    ...    ${key_string}    encoding_errors=replace
    run keyword and continue on failure  should be empty    ${output}  msg=check dldata forwarding failed!


Modify CU param and commission
    [Documentation]    Author: Zhang Nningning
    [Arguments]     ${scf_parameters_list}    ${scf_template_path}=${SCF_DEFAULT_CU_FILE_PATH}
    ...    ${local_scf_path}=${SUITE_LOG_PATH}
    Modify CU parameter and commission case   scf_template_path=${scf_template_path}
    ...    scf_parameters_list=${scf_parameters_list}    local_scf_path=${local_scf_path}
    Perform Cloud DU reboot
    COAM GNB Wait CU and DU cells are on air status

Modify CU parameter and commission case
    [Documentation]    Author: Wang Yixiang
    [Arguments]     ${scf_template_path}    ${scf_parameters_list}    ${local_scf_path}=${SUITE_LOG_PATH}
    Log to console    Start to modify CU scf files and commission, please wait..
    ${default_scf_file_path}    Copy file    ${scf_template_path}    ${local_scf_path}
    Run   sed -i '/timerX2DataFwdGuard/d' ${default_scf_file_path}
    ${output_scf_file_path}    coam_gnb_classical.COAM Modify scf file
    ...    scf_file_path=${default_scf_file_path}
    ...    scf_parameters_list=${scf_parameters_list}
    CU Full Commission  path_of_commission_file=${output_scf_file_path}
