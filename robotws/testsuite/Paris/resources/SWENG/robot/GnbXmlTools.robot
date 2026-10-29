*** Settings ***
Documentation
...            == Purpose ==
...            Library to manage services related to the GNB TargetBD xml file.
...
...            == Description ==
...            Based on Radio card name, the keyword will search the swFileKey and resourceSWVersion tags
...            in the GNB TargetBD_xxx.xml file. Extracted data are then declared as global variables.
...
...            *Main keyword is:*
...            | =Keyword Name=                                   | =Param1=    | =Param2= |
...            | Get Data From Gnb TargetBD File                  | <card_name> | <debug>  |
...
...            *Result:*
...            Global variables are named as following:
...            - ${g_resource_swVersion}
...            - ${g_resource_swFileKey}


Library                             Collections
Library                             ../python/XmlConfig.py  WITH NAME   XmlConfig
Library                             ../python/StringTool.py


*** Keywords ***

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


Download Aic TargetBD File
    [Documentation]                 INTERNAL USAGE
    ...                             Copy the TargetBD*.xml file from VDU to a local directory
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

