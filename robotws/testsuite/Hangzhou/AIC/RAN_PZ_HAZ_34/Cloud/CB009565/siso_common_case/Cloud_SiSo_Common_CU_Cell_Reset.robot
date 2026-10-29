*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   ./Resource/common.robot


*** Variables ***
${times}    50


*** Test Cases ***
Cloud_SiSo_Common_CU_Cell_Reset
    [Setup]
    FOR    ${time}   IN RANGE   ${times}
         Log To Console    this is ${time} CU_Cell_Reset!
        Single_Cloud_SiSo_Common_CU_Cell_Reset
    END
    [Teardown]   Run Keyword If Test Failed  COAM VCU Log Collection


*** Keywords ***
Single_Cloud_SiSo_Common_CU_Cell_Reset
    COAM CU Login

    ${tmp_scf_name}   Set Variable   tmp_cu_cell_reset.xml
    COAM CU Backup Current SCF   path=${OUTPUT_DIR}/${tmp_scf_name}
    ${scf_xml}   XML.Parse XML  ${OUTPUT_DIR}/${tmp_scf_name}
    ${cell_elems}   XML.Get Elements   ${scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    @{cell_dn_list}   Create List
    FOR   ${cell_elem}   IN   @{cell_elems}
        ${cell_dn}   XML.Get Element Attribute   ${cell_elem}   distName   xpath=.
        Append To List   ${cell_dn_list}   ${cell_dn}
        COAM CU Reset Cell   cell_dn=${cell_dn}
    END
    Log To Console   ${cell_dn_list}

    Wait Until Keyword Succeeds   15m   1m   COAM CU Check All Cell Status

    [Teardown]   Run Keyword And Ignore Error   COAM CU Logout
