*** Settings ***
Documentation
...          Test to validate the Suite Setup and Custom Config with no CU scf

Resource                            ../Tools.robot
Resource                            ../Setup.robot
Resource                            ../Topology.robot

Library                             ../../python/StringTool.py
Library                             ../../python/OsTool.py
Library                             ../../python/Setup.py
Library                             ../../python/XmlConfig.py       WITH NAME   XmlConfig


# Test to validate the Suite Setup and Custom Config with no CU scf
Suite Setup                 Suite Setup     scfcPathname=/home/ute/CrtRoot/scfc_du.xml
...                                         iphyPathname=/home/ute/CrtRoot/iphy.xml
...                                         basicPathname=/home/ute/CrtRoot/basic.cfg
...                                         debug=${False}

*** Variables ***
${yamlPathname}                     /home/ute/CrtRoot/test_config.yaml
${ScfPathname}                      /home/ute/CrtRoot/scfc.xml
${duScfPathname}                    /home/ute/CrtRoot/scfc_du.xml
${cuScfPathname}                    /home/ute/CrtRoot/scfc_cu.xml
${cardName}                         AEQE_E1
${cardName_isAic}                   AEQP_E1


*** Test Cases ***

Test1 To Get Topo From Agent Log File
    Dated Log New Line              ${EMPTY}
    # Check Topo is Classical or Vran:
    ${isTopoVR}                     setup.checkTopoFromAgentLogFile
    Dated Log New Line              isTopoVR = ${isTopoVR}

*** Keywords ***

My Test to validate the Get Info From YAML File
    Dated Log New Line              ${EMPTY}
    Dated Log                       yamlPathname= ${yamlPathname}

    Dated Log New Line              Will get the SCFC for DU Id 1:
    ${file_path}                    Get Info From YAML File     yaml_file=${yamlPathname}
    ...                                                         file_type=scfc
    ...                                                         hw_type=du
    ...                                                         hw_id=1
    Dated Log                       The DU_1 SCFC file name is: ${file_path}

    Dated Log New Line              Will get the SCFC for CU id 1:
    ${file_path}                    Get Info From YAML File     yaml_file=${yamlPathname}
    ...                                                         file_type=scfc
    ...                                                         hw_type=cu
    ...                                                      hw_id=1
    Dated Log                       The CU_1 SCFC file name is: ${file_path}

    Dated Log New Line              Will get the IPHY for AIRPHONE:
    ${file_path}                    Get Info From YAML File     yaml_file=${yamlPathname}
    ...                                                         file_type=iphy_xml
    ...                                                         hw_type=airphone
    ...                                                         hw_id=1
    Dated Log                       The AIRPHONE IPHY file name is: ${file_path}

    Dated Log New Line              Will get the BASIC for VM:
    ${file_path}                    Get Info From YAML File     yaml_file=${yamlPathname}
    ...                                                         file_type=wts_cfg
    ...                                                         hw_type=vm
    ...                                                         hw_id=1
    Dated Log                       The VM IPHY file name is: ${file_path}

    Dated Log New Line              Check What Happens If Missing yaml_file Input Parameter:
    ${err_msg}                      Run Keyword And Ignore Error
    ...                             Get Info From YAML File     file_type=scfc
    ...                                                         hw_type=du
    ...                                                         hw_id=1
    Dated Log                       Returned Error is: ${err_msg}

    Dated Log New Line              Check What Happens If Missing file_type Input Parameter:
    ${err_msg}                      Run Keyword And Ignore Error
    ...                             Get Info From YAML File     yaml_file=${yamlPathname}
    ...                                                         hw_type=du
    ...                                                         hw_id=1
    Dated Log                       Returned Error is: ${err_msg}

    Dated Log New Line              Check What Happens If Missing hw_type Input Parameter:
    ${err_msg}                      Run Keyword And Ignore Error
    ...                             Get Info From YAML File     yaml_file=${yamlPathname}
    ...                                                         file_type=scfc
    ...                                                         hw_id=1
    Dated Log                       Returned Error is: ${err_msg}

    Dated Log New Line              Check What Happens If Missing ALL Input Parameters:
    ${err_msg}                      Run Keyword And Ignore Error
    ...                             Get Info From YAML File
    Dated Log                       Returned Error is: ${err_msg}

    Dated Log New Line              Check What Happens With SCFC for CU_2:
    ${err_msg}                      Run Keyword And Ignore Error
    ...                             Get Info From YAML File     yaml_file=${yamlPathname}
    ...                                                         file_type=scfc
    ...                                                         hw_type=cu
    ...                                                         hw_id=2
    Dated Log                       Returned Error is: ${err_msg}


# ======================================
# IPHY UPDATE : prototype non valide
# ======================================

Get Data From Gnb TargetBD File
    [Documentation]                 Download the "TargetBD*.xml" from GNB airscale then extract
    ...                             resourceSWVersion and swKeyFile associated with the provided "card_name"
    ...                             (card_name = LTX_AEQI, LTX_AAHF_C1, ...)
    ...
    ...                             The keyword returns the suite variables ${gnb_swVersion} and ${gnb_swFileKey}
    ...
    ...                             *Argument details:*
    ...                             - card_name: Radio unit card name (ex: "LTX_AAHF_C1")
    ...                             - debug: debug flag for display
    [Arguments]                     ${card_name}
    ...                             ${debug}=${True}

    ${local_file}=                  Set Variable                         ${LOG_PATH}/TargetBD.xml
    ${hwResource_xpath}=            set variable if       ${isAic}
    ...       /targetBD_RFSW/hwResource[contains(@resourceBuildKey,\"${card_name}\")]
    ...       /targetBD/hwResource[contains(@resourceBuildKey,\"${card_name}\")]

    Run Keyword If                  ${isAic}
    ...                             Download Aic TargetBD File           local_file=${local_file}
    ...       ELSE
    ...                             Download Classical TargetBD File     local_file=${local_file}

    # update the local SCF file
    XmlConfig.startSession          path=${local_file}

    Dated Log                       hwResource_xpath = ${hwResource_xpath}
    ${g_resource_swVersion}=        XmlConfig.getFirstEltAttrValue       path=${hwResource_xpath}
    ...                                                                  attr_name=resourceSWVersion
    ...                                                                  debug=${debug}
    Dated Log                       g_resource_swVersion = ${g_resource_swVersion}
    ${g_resource_swFileKey}=        XmlConfig.getFirstEltTagValue        path=${hwResource_xpath}
    ...                                                                  tag=swFileKey
    ...                                                                  debug=${debug}
    Dated Log                       g_resource_swFileKey = ${g_resource_swFileKey}
    Set Suite Variable              ${g_resource_swVersion}
    Set Suite Variable              ${g_resource_swFileKey}


Download Aic TargetBD File
    [Documentation]                 Copy the TargetBD*.xml file from VDU to a local directory
    ...                             Return the path of the copied file
    [Arguments]                     ${local_file}
    ...                             ${debug}=${True}
    # get the filename on the VDU
    ${kcmd}                         Set Variable
    ...                             ls /ffs/run/RFSW | grep TargetBD_v | grep CNF
    ${result}                       K8s cmd
    ...                             k8s=${GNB_DU}       podName=oamfh-0     containerName=oamfh
    ...                             cmd=${kcmd}         debug=${debug}
    ${bd_file}                      getStringFromCmdReturn    ${result}
    Run keyword If                  ${debug}
    ...                             Dated Log           VDU TargetBD filename : bd_file=[${bd_file}]

    # copy the file to a local directory on the VDU
    ${tmp_path}                     Set Variable
    ...                             /tmp/${bd_file}
    ${kcmd}                         Set Variable
    ...                             cat /ffs/run/RFSW/${bd_file} > ${tmp_path}
    ${result}                       K8s cmd
    ...                             k8s=${GNB_DU}       podName=oamfh-0     containerName=oamfh
    ...                             cmd=${kcmd}         debug=${debug}
    Run keyword If                  ${debug}
    ...                             Dated Log           Temporary TargetBD filepath on VDU : tmp_path=[${tmp_path}]

    # copy the file from the VDU to the local directory
    ${ssh_data}                     Set Variable        ${GNB_DU.mainNode.k8s.master_node.ssh_connection_details}
    ${ssh_ip}                       Set Variable        ${ssh_data.addr}
    ${ssh_username}                 Set Variable        ${ssh_data.username}
    ${ssh_password}                 Set Variable        ${ssh_data.password}
    Run keyword If                  ${debug}
    ...                             Dated Log           ssh_ip=${ssh_ip}, ssh_username=${ssh_username}, ssh_password=${ssh_password}
    ${result}                       Run
    ...                             sshpass -p ${ssh_password} scp ${ssh_username}@${ssh_ip}:${tmp_path} ${local_file}
    Run keyword If                  ${debug}
    ...                             Dated Log           scp result = ${result}
    Should Exist                    ${local_file}

    Dated Log                       Local file = ${local_file}
    [Return]                        ${local_file}


Download Classical TargetBD File
    [Documentation]                 INTERNAL USAGE
    ...                             Download the "TargetBD_SBTS*.xml" from GNB and store it in a local directory
    ...                             (Filename example : TargetBD_SBTS24R2_ENB_9999_240221_000006.xml)
    [Arguments]                     ${local_file}
    ${remote_org_file}=             Set Variable                         /ffs/run/TargetBD_SBTS*.xml
    ${remote_tmp_file}=             Set Variable                         /tmp/TargetBD.xml
    ${alias_gnb}                    SSH Wait For Connect                 ${GNB_DU.entryCard[0]}
    SSH Cmd                         cp ${remote_org_file} ${remote_tmp_file}                   alias=${alias_gnb}
    csn.download_file               remote_path=${remote_tmp_file}
    ...                             local_path=${local_file}
    ...                             connection=${alias_gnb}
    Dated Log                       Downloaded TargetBD file = ${local_file}
