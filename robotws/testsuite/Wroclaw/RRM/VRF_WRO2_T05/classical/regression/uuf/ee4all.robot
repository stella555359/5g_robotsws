# https://wrgitlab.ext.net.nokia.com/RAN/resource-packages/taf.rfrl.procedures/-/tree/
# master/taf/rfrl/procedures/SISO/ESM?ref_type=heads#sample-esm-configuration-file

*** Settings ***
Documentation
...             maintainer: Sebastian Mikos
...             contact: sebastian.mikos@nokia.com

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        taf/rfrl/procedures/SISO/ESM/resources/ESM.robot
Library         taf.sbts.oam.coam.admin   WITH NAME   admin

Test Setup      admin.Setup Admin      bts_host=${GNB_IP}    alias=connection_alias

Test Teardown   Run Keyword And Ignore Error    admin.Teardown All Aliases For Admin

*** Variables ***
${EE_CONFIG}            testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/uuf/resources/ee_conf.yaml
${GNB_IP}               ${tl.gnbs[0].cu.backhaul_site_oam_ip}
${resource_path}        ${CURDIR}${/}resources

*** Test Cases ***
Sample ETSI Test Case
    ${bts_info}    admin.Get bts info    connection=connection_alias
    ${bts_id}     Get from dictionary    ${bts_info}    mrbtsID
    admin.Perform parameter recommissioning   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                       parameter=actRadioDeepSleepTimeSchedule
    ...                                       operation=update
    ...                                       value=false
    ...                                       skip_parameter_relation_errors=${False}
    ...                                       connection=connection_alias
    ${all_nrp_groups}=    admin.get managed_objects
    ...                   class_name=NRPGRP_A
    ...                   connection=connection_alias
    ${count}=    Get Length    ${all_nrp_groups}

    FOR    ${i}    IN RANGE    1    ${count + 1}
        admin.Perform parameter recommissioning
        ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRPGRP-${i}
        ...    parameter=lbpsLastCellSOEnabled
        ...    operation=update
        ...    value=true
        ...    skip_parameter_relation_errors=${False}
        ...    connection=connection_alias
    END

    Run ESM Measurement Procedure
    ...    connection=connection_alias
    ...    configuration_yaml_file=${EE_CONFIG}