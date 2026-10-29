*** Settings ***
Documentation
...    Author: yin.4.chen@nokia-sbell.com
...    Feature CNI-103502 Automation

Resource   Common.robot

*** Keywords ***


Transfer Release SBTS00 Package
    [Arguments]   ${version}
    Return From Keyword If   ${version.find("9999")==-1}   ${version}

    @{string_list}   Split String   ${version}   _
    ${release}   Set Variable   ${string_list[0]}
    ${version}   Replace String   ${version}   ${release}   SBTS00
    [Return]   ${version}


COAM ADMIN Check Cell Onair
    [Arguments]   ${connection}=COAM
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=${60}
    ${cell_info}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['cells']}
    ...   ELSE   Set Variable   ${bts_info['cells']}
    ${cell_list}   Get Dictionary Values   ${cell_info}
    ${cell_list}   Evaluate   [item for sublist in ${cell_list} for item in sublist]

    FOR   ${cell}   IN   @{cell_list}
        ${operationalState}         Get Variable Value   ${cell['status']['operationalState']}      N/A
        ${usageState}               Get Variable Value   ${cell['status']['usageState']}            N/A
        ${proceduralStatus}         Get Variable Value   ${cell['status']['proceduralStatus']}      N/A
        ${administrativeState}      Get Variable Value   ${cell['status']['administrativeState']}   N/A
        ${availabilityStatus}       Get Variable Value   ${cell['status']['availabilityStatus']}    N/A

        Run Keyword If   "${operationalState}"!="N/A"
        ...   Should Be Equal   ${operationalState.lower()}       enabled
        # # Sometimes usageState=Idle
        # Run Keyword If   "${usageState}"!="N/A"
        # ...   Should Be Equal   ${usageState.lower()}             active
        Run Keyword If   "${proceduralStatus}"!="N/A"
        ...   Should Be Equal   ${proceduralStatus.lower()}       configured
        Run Keyword If   "${administrativeState}"!="N/A"
        ...   Should Be Equal   ${administrativeState.lower()}    unlocked
        Run Keyword If   "${availabilityStatus}"!="N/A"
        ...   Should Not Be Equal   ${availabilityStatus.lower()}   degraded
    END



Get IMS2 PM1
    csn.Connect To   hostname=${oam_addr}   username=${oam_username}   password=${oam_password}   alias=ssh
    csn.Download File
    ...   remote_path=/ffs/run/logs/oam/uri/ims/pm_1_im_snapshot.ims2
    ...   local_path=${OUTPUT_DIR}/pm_1_im_snapshot.ims2
    ...   connection=ssh
    ...   timeout=${300}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=ssh


COAM Transfer IMS2 To SCF
    COAM Login
    coam.ims_to_scf
    ...   ims_path=${OUTPUT_DIR}/pm_1_im_snapshot.ims2
    ...   scf_path=${OUTPUT_DIR}/pm_1_scf.xml
    ...   export_type=configurationAndRuntimeObjects
    ...   timeout=${300}
    ...   connection=COAM

    [Teardown]   Run Keyword And Ignore Error   COAM Logout


Selenium Transfer IMS2 To SCF
    COAM WEBUI Login
    selenium_coam.load_ims2   file_path=${OUTPUT_DIR}/pm_1_im_snapshot.ims2
    ${save_bts_configuration}   selenium_coam.save_bts_configuration
    OperatingSystem.Move File   ${save_bts_configuration}   ${OUTPUT_DIR}/pm_1_scf.xml

    [Teardown]   Run Keyword And Ignore Error   COAM WEBUI Logout


Check IMS2 PM1
    [Arguments]   ${scf_path}=${OUTPUT_DIR}/pm_1_scf.xml
    ${scf_xml}   XML.Parse XML   ${scf_path}
    ${pm1_qRxLevMin}   XML.Get Element Text   ${scf_xml}   xpath=cmData/managedObject[@distName="${cell_dn}"]/p[@name="qRxLevMin"]
    Log To Console   IMS2 PM1 qRxLevMin: ${pm1_qRxLevMin}
    Should Be Equal As Strings   ${pm1_qRxLevMin}   ${new_qRxLevMin}


COAM Update qRxLevMin
    COAM Login

    ${delta_id}   Set Variable   CNI_103502
    coam.create_delta   delta_id=${delta_id}

    ${nr_cells}   coam.get_cells_info   connection=COAM
    ${cell_dn}   Set Variable   ${nr_cells[0]["id"]["configuration"]}
    Set Suite Variable   ${cell_dn}

    ${scf_xml}   XML.Parse XML   ${old_version_scf_path}
    ${old_qRxLevMin}   XML.Get Element Text   ${scf_xml}   xpath=cmData/managedObject[@distName="${cell_dn}"]/p[@name="qRxLevMin"]
    ${new_qRxLevMin}   Evaluate   ${old_qRxLevMin} - 5
    Set Suite Variable   ${old_qRxLevMin}
    Set Suite Variable   ${new_qRxLevMin}
    Log To Console   Old qRxLevMin: ${old_qRxLevMin}
    Log To Console   New qRxLevMin: ${new_qRxLevMin}

    coam.append_parameter_update_to_delta
    ...   dist_name=${cell_dn}
    ...   parameter=qRxLevMin
    ...   value=${new_qRxLevMin}
    ...   delta_id=${delta_id}

    ${delta_file}   coam.get_delta   delta_id=${delta_id}
    Log To Console   ${delta_file}

    Log To Console   COAM Perform Delta Recommissioning...
    coam.perform_delta_recommissioning
    ...   delta_file=${delta_file}
    ...   skip_parameter_relation_errors=${false}
    ...   should_activate=${true}
    ...   timeout=${900}
    ...   connection=COAM
    Log To Console   COAM Perform Delta Recommissioning Finished!
    Log To Console   Wait For Cell Onair...
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair   connection=COAM
    Log To Console   Wait For Cell Onair Finished!

    [Teardown]   Run Keyword And Ignore Error   COAM Logout
