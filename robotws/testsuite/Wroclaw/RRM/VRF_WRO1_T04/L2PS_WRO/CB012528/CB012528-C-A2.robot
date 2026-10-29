*** Settings ***
Documentation
...    author: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    maintainer: Anna Chabik
...    release: 24R2


Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ./resources/CB012528_keywords.robot
Library     ../resources/Python/webem_alarms.py
Resource     ../resources/configuration_id.robot


*** Variables ***
${iphy_CB012528}               ${CURDIR}/config/iphy_12x20_4DL4UL.xml
${scf_CB012528}                ${CURDIR}/config/SBTS00/scf_C_A2_12x20_4DL4UL.xml
${lua_CB012528}                ${CURDIR}/config/setup_12x20_12UE.lua

*** Keywords ***
CB012528_C_A2_BBcell_set_CB009014_with_new_L2PS_deployment_MRL
    Attach Multiple UEs And Start Traffic    last_ue=12    dir=dl    mbps=50
    Start Traffic For Multiple UEs           last_ue=12    dir=ul    mbps=50
    Sleep    30s    reason=Wait for throughput stabilization
    Verify Avg Tput For Multiple UEs    last_ue=12    dir=dl    expected_tput=40
    Verify Avg Tput For Multiple UEs    last_ue=12    dir=ul    expected_tput=40
    Execute Egate Command    cmd=sim_reset
    Teardown Egate And Collect Logs
    admin.Setup Admin
    Download Modify And Apply Vendor File
    ...    modified_vendor_file_name=vendor_file_old_deployment.xml
    ...    actTwoCoresL2DeploymentFddFr1=false
    ...    maxNumScheUePdschL2Sp=20
    ...    maxNumScheUePuschL2Sp=16
    Update SCF And Perform Commissioning    scf_file_name=scf_C_A2_12x20_4DL4UL.xml
    Reach Onair    lua_cfg=${CURDIR}/config/setup_12x20_12UE.lua
    Check L2 Subpool Assignment    cells_amount=12    deployment=old
    Attach Multiple UEs And Start Traffic    last_ue=12    dir=dl    mbps=50
    Start Traffic For Multiple UEs           last_ue=12    dir=ul    mbps=50
    Sleep    30s    reason=Wait for throughput stabilization
    Verify Avg Tput For Multiple UEs    last_ue=12    dir=dl    expected_tput=40
    Verify Avg Tput For Multiple UEs    last_ue=12    dir=ul    expected_tput=40
    [Teardown]    Send Configuration ID To Scout
