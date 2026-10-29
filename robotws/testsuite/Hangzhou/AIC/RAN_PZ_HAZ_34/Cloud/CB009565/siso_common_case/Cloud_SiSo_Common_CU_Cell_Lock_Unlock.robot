*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   ./Resource/common.robot


*** Variables ***
${times}    50

*** Test Cases ***
Cloud_SiSo_Common_vDU_Cell_Block_Unblock
    [Setup]
    FOR    ${time}   IN RANGE   ${times}
         Log To Console    this is ${time} Cell_Block_Unblock!
        Single_Cloud_SiSo_Common_CU_Cell_Lock_Unlock
    END
    [Teardown]   Run Keyword If Test Failed  COAM VCU Log Collection


*** Keywords ***
Single_Cloud_SiSo_Common_CU_Cell_Lock_Unlock
    COAM CU Login

    ${tmp_scf_name}   Set Variable   tmp_cu_cell_lock_unlock.xml
    COAM CU Backup Current SCF   path=${OUTPUT_DIR}/${tmp_scf_name}
    ${scf_xml}   XML.Parse XML  ${OUTPUT_DIR}/${tmp_scf_name}
    ${cell_elems}   XML.Get Elements   ${scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    @{cell_id_list}   Create List
    FOR   ${cell_elem}   IN   @{cell_elems}
        ${cell_dn}   XML.Get Element Attribute   ${cell_elem}   distName   xpath=.
        ${cell_dn}   ${cell_id}   Should Match Regexp   ${cell_dn}   NRCELL-(\\d+)
        Append To List   ${cell_id_list}   ${cell_id}
    END
    Log To Console   ${cell_id_list}

    COAM CU Lock Cells   cell_ids=${cell_id_list}
    Sleep   3s
    Wait Until Keyword Succeeds   2m   10s   COAM CU Check All Cell Status Locked


    COAM CU Unlock Cells   cell_ids=${cell_id_list}
    Sleep   3s

    Wait Until Keyword Succeeds   5m   20s   COAM CU Check All Cell Status

    [Teardown]   Run Keyword And Ignore Error   COAM CU Logout
