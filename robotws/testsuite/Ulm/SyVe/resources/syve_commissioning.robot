*** Settings ***
Documentation
...    author: I_MN_RAN_RD_VRF_ULM_VT2_GMS
...    contact: I_MN_RAN_RD_VRF_ULM_VT2@internal.nsn.com
...    Description: Common commissioning keywords for SyVe


Library    taf.sbts.oam.coam.admin            WITH NAME   admin

Resource   ../../resources/Common/connect.robot


*** Keywords ***
Execute commissioning of enb delta Json file
    [Documentation]
    ...  Open OAM http session to eNB, perform Delta commissioning, remove Delta file and teardown OAM session.
    [Arguments]     ${delta}   ${enb_id}
    ${oam}  connect.Setup OAM HTTP Session  node_id=${enb_id}  node_type=enb
    admin.Perform Delta Recommissioning    ${delta}  skip_parameter_relation_errors=${True}  connection=${oam}
    admin.Remove Delta
    admin.Teardown   connection=${oam}


Execute commissioning of delta Json file
    [Documentation]
    ...  Open OAM http session to eNB, perform Delta commissioning, remove Delta file and teardown OAM session.
    [Arguments]     ${delta}   ${gnb_id}
    ${oam}  connect.Setup OAM HTTP Session  node_id=${gnb_id}  node_type=gnb
    admin.Perform Delta Recommissioning    ${delta}  skip_parameter_relation_errors=${True}  connection=${oam}
    admin.Remove Delta
    admin.Teardown   connection=${oam}


Execute Recommissioning With Delta SCF File
    [Documentation]
    ...  Open OAM http session, perform delta commissioning with given delta file and teardown OAM session.
    [Arguments]   ${node_type}  ${node_id}   ${delta_scf_recommissioning_name}   ${skip_error_validation}=${True}
    ${oam}  connect.Setup OAM HTTP Session  node_id=${node_id}  node_type=${node_type}
    admin.Perform Delta Recommissioning    delta_file=${delta_scf_recommissioning_name}
    ...  skip_parameter_relation_errors=${skip_error_validation}
    ...  connection=${oam}
    admin.Teardown   connection=${oam}


Execute Full Commissioning With SCF File
    [Documentation]  Perform full commissioning with given SCF File.
    [Arguments]   ${node_type}  ${node_id}   ${scf_file_path}   ${skip_error_validation}=${True}  ${activate_plan_automatically}=${True}
                ...  ${timeout_for_commissioning}=${300}
    ${oam}  connect.Setup OAM HTTP Session  node_id=${node_id}  node_type=${node_type}
    admin.Perform Commissioning    bts_id=${node_id}  scf_file=${scf_file_path}  skip_parameter_relation_errors=${skip_error_validation}
    ...  should_activate=${activate_plan_automatically}  timeout=${timeout_for_commissioning}  connection=${oam}
    admin.Teardown  connection=${oam}
