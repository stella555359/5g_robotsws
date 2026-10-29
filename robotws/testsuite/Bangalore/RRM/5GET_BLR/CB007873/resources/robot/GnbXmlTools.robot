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

*** Keywords ***

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

    # Get "TargteBD*.xml" file from gNB (Ex : TargetBD_5G20B_GNB_0000_000800_001949.xml)
    ${remote_org_file}=             Set Variable                         /ffs/run/TargetBD_*.xml
    ${remote_tmp_file}=             Set Variable                         /tmp/TargetBD.xml
    ${alias_gnb}                    SSH Wait For Connect                 ${GNB_DU.entryCard[0]}
    SSH Cmd                         cp ${remote_org_file} ${remote_tmp_file}                   alias=${alias_gnb}
    ${local_tmp_file}=              Set Variable                         ${LOG_PATH}/TargetBD.xml
    csn.download_file               remote_path=${remote_tmp_file}
    ...                             local_path=${local_tmp_file}
    ...                             connection=${alias_gnb}
    Dated Log                       Download SCF file = ${local_tmp_file}
    # update the local SCF file
    XmlConfig.startSession          path=${local_tmp_file}
    ${hwResource_xpath}=            Set Variable    /targetBD/hwResource[contains(@resourceBuildKey,\"${card_name}\")]
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
