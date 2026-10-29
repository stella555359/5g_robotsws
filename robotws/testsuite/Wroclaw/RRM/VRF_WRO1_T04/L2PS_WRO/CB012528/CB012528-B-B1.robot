*** Settings ***
Documentation    :copyright: Nokia

Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ./resources/CB012528_keywords.robot
Library     ../resources/Python/webem_alarms.py
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/configuration_id.robot

Force Tags    CLOUD_5G_I_LO_AP_LOOO    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
...                            iphy_xml_filepath=${CURDIR}/config/iphy_6x20_4DL4UL.xml
...            AND             CB012528 Setup
...            AND             Update SCF And Perform Commissioning    scf_file_name=scf_B_B1_6x20_4DL4UL.xml

Suite Teardown    Run Keywords    Print Active Alarms
...               AND             admin.Teardown All Aliases For Admin
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Send Configuration ID To Scout

*** Test Cases ***
CB012528_B_B1_BBcell_set_CB007804_with_new_L2PS_deployment_on_SNF
    Reach Onair    lua_cfg=${CURDIR}/config/setup_6x20_6UE.lua
    Check L2 Subpool Assignment    cells_amount=6

    FOR    ${i}    IN RANGE    2
        Lock And Unlock NG link
        Attach Multiple UEs And Start Traffic    last_ue=6    dir=dl    mbps=50
        Start Traffic For Multiple UEs           last_ue=6    dir=ul    mbps=50
        Sleep    30s    reason=Wait for throughput stabilization
        Verify Avg Tput For Multiple UEs    last_ue=6    dir=dl    expected_tput=40
        Verify Avg Tput For Multiple UEs    last_ue=6    dir=ul    expected_tput=40
    END
    Execute Egate Command    cmd=sim_reset
    Teardown Egate And Collect Logs

    admin.Setup Admin
    Download Modify And Apply Vendor File
    ...    modified_vendor_file_name=vendor_file_old_deployment.xml
    ...    actTwoCoresL2DeploymentFddFr1=false
    ...    maxNumScheUePdschL2Sp=20
    ...    maxNumScheUePuschL2Sp=16
    Update SCF And Perform Commissioning    scf_file_name=scf_B_B1_6x20_4DL4UL.xml

    Reach Onair    lua_cfg=${CURDIR}/config/setup_6x20_6UE.lua
    Check L2 Subpool Assignment    cells_amount=6    deployment=old

    Attach Multiple UEs And Start Traffic    last_ue=6    dir=dl    mbps=50
    Start Traffic For Multiple UEs           last_ue=6    dir=ul    mbps=50
    Sleep    30s    reason=Wait for throughput stabilization
    Verify Avg Tput For Multiple UEs    last_ue=6    dir=dl    expected_tput=40
    Verify Avg Tput For Multiple UEs    last_ue=6    dir=ul    expected_tput=40
