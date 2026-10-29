*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   ./Resource/common.robot


*** Variables ***
${times}    50


*** Test Cases ***
Cloud_SiSo_Common_CU_Lock_vDU
    [Setup]
    FOR    ${time}   IN RANGE   ${times}
        Log To Console    this is ${time} Cloud_SiSo_Common_CU_Lock_vDU!
        Single_Cloud_SiSo_Common_CU_Lock_vDU
    END
    [Teardown]   Run Keyword If Test Failed  COAM VCU Log Collection


*** Keywords ***
Single_Cloud_SiSo_Common_CU_Lock_vDU
    COAM CU Login

    ${tmp_scf_name}   Set Variable   tmp_cu_lock_vdu.xml
    COAM CU Backup Current SCF   path=${OUTPUT_DIR}/${tmp_scf_name}
    ${scf_xml}   XML.Parse XML  ${OUTPUT_DIR}/${tmp_scf_name}
    ${vdu_elems}   XML.Get Elements   ${scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRDU"]
    ${vdu_id_list}   Create List
    FOR   ${vdu_elem}   IN   @{vdu_elems}
        ${vdu_dn}   XML.Get Element Attribute   ${vdu_elem}   distName   xpath=.
        ${vdu_dn}   ${vdu_id}   Should Match Regexp   ${vdu_dn}   NRDU-(\\d+)
        Append To List   ${vdu_id_list}   ${vdu_id}
    END
    Log To Console   ${vdu_id_list}

    COAM CU Lock vDUs   vdu_id_list=${vdu_id_list}
    Wait Until Keyword Succeeds   1m   10s   COAM CU Check All vDUs Locked

    COAM CU Unlock vDUs   vdu_id_list=${vdu_id_list}
    Wait Until Keyword Succeeds   1m   10s   COAM CU Check All vDUs Unlocked

    Wait Until Keyword Succeeds   15m   20s   COAM CU Check All Cell Status

    [Teardown]   Run Keyword And Ignore Error   COAM CU Logout
