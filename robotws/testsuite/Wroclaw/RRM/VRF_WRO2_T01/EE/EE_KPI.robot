*** Settings ***
Documentation
...             maintainer: Pawel Wisniewski, Wiktor Jarosinski
...             contact: pawel.1.wisniewski@nokia.com

Resource        taf/rfrl/procedures/SISO/ESM/resources/ESM.robot
Library         taf.sbts.oam.coam.admin   WITH NAME   taf_admin

Test Setup      taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=connection_alias
Test Teardown   Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin


*** Variables ***
${yaml}         ${CURDIR}/yaml_resources/${BTS_ID}.yaml
${GNB_IP}       ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${BTS_ID}       ${tl.gnbs[0].global_bts_id}

*** Test Cases ***
Sample ETSI Test Case
    # Remember to connect to ADMIN CLI and then pass the connection to the keyword
    Run ESM Measurement Procedure
    ...    connection=connection_alias
    ...    configuration_yaml_file=${yaml}