*** Settings ***
Documentation
...             maintainer: Marcin Bednarski
...             contact: marcin.bednarski@nokia.com

Resource        taf/rfrl/procedures/SISO/ESM/resources/ESM.robot
Library         taf.sbts.oam.coam.admin   WITH NAME   taf_admin

Test Setup      taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=connection_alias
Test Teardown   Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin

*** Variables ***
${EE_CONFIG}    testsuite/Wroclaw/RRM/VRF_WRO2_T08/integration/MRBTS_50844/resources/ee_conf.yaml
${GNB_IP}       ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}

*** Test Cases ***
Sample ETSI Test Case
    Run ESM Measurement Procedure
    ...    connection=connection_alias
    ...    configuration_yaml_file=${EE_CONFIG}
