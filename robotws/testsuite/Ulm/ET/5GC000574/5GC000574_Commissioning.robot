*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Delta Commissioning for 574

Resource          5GC000574_Keywords.robot

*** Keywords ***

# SCF handling
Execute Delta Commissioning for 574
    [Documentation]    :Author: G. Sankaran and L. Medico
    ...    what this delta commissioning will do
    ...    most probably to be modified below scf_precondition_tc10.xml
    ${delta_scf}=            Prepare Delta Commissioning for 574
    ${delta_size}=           Get File Size  ${delta_scf}
    IF  ${delta_size} <= 2   RETURN
    Log To Console    Perform delta commissioning...
    admin.Setup Admin    alias=cOAM
    admin.Perform Delta Recommissioning
    ...    delta_file=${delta_scf}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    ...    alias=cOAM
    [Teardown]    Run Keyword And Ignore Error    admin.Teardown Admin    alias=cOAM


Prepare Delta Commissioning for 574
    [Documentation]    :Author: G. Sankaran and L. Medico
    ...    parameter to be changed in gNB
    scf.load_scf             ${P_ORIG_SCF}

    scf.modify_scf_element   value=true  dist_name=NRBTS-1                   p_name=actInterMeNBMobility
    scf.modify_scf_element   value=5min  dist_name=MNL-1/MNLENT-1/PMCADM-1   p_name=reportingIntervalPm
    scf.modify_scf_element   value=5min  dist_name=NRBTS-1/NRPMRNL-1         p_name=miNrLteMobilityReport
    scf.modify_scf_element   value=5min  dist_name=NRBTS-1/NRPMRNL-1         p_name=miNrX2CC
    scf.modify_scf_element   value=5min  dist_name=NRBTS-1/NRPMRNL-1         p_name=miNrX2CB
    Add NRREL to Cell        cell_id=1
    Add NRREL to Cell        cell_id=2

    ${ts_conf_dir}=          Get Test Suite Config Directory
    ${new_scf}=              Set Variable   ${ts_conf_dir}/scf_574.xml
    ${delta_scf}=            Set Variable   ${ts_conf_dir}/delta_scf_574.json
    scf.save_scf             ${new_scf}
    Set Suite Variable    ${scf_to_be_loaded}    ${new_scf}
    scf.calculate_delta_scf  ${new_scf}  ${P_ORIG_SCF}  ${delta_scf}
    RETURN    ${delta_scf}
