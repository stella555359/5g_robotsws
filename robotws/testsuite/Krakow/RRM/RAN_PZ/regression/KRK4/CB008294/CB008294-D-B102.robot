*** Settings ***
Documentation
...              author: Mateusz Plinta, Dominik Dudek
...              maintainer: Bartlomiej Kolacz
...              contact: bartlomiej.kolacz@nokia.com
...              description: CB008294-D#B102 RRC re-establishment of FR2 SA CA UE with rrcReestabTypeSA set as sameGNB in same PCell
...              topology: CLOUD_5G_I_BOO_AP_LOO

Resource         resources/common_keywords.robot

Suite Setup      Suite Environment Preparation    scf_filename=scf_D_B102.xml
Suite Teardown   Run Keyword And Ignore Error    Collect Admin Api Logs    subdir=${SUITE_NAME}
...                                                                        dir_name=admin_api_logs

*** Test Cases ***
CB008294_D_B102_02_8CC_DL_4CC_UL_RRCreastablishment_sameGNB_different_cell_group
    [Tags]    CRT
    [Setup]    Test Environment Preparation For D_B102    sib_reception_dict={2:[1,9]}    mib_reception_list=[1,2,3,4,5,6,7,8,9,10]
    Create Ue Alias  alias=UE_1    ue_id=1    id_type=wts_5g
    EXPECT FLOW[timeout=30]: UE_1 NR-RRC 2*RRCSetup
    EXPECT FLOW[timeout=30]: UE_1 NR-RRC 2*RRCSetupComplete
    Perform 5G Attach With TTI Collection
    Validate Scells State In Egate By Exact Cell    cells_to_validate_map={0: [60]}
    Expect message flow
    ...    UE_1:NR-RRC_RRCReestablishmentRequest
    ...    UE_1:NR-RRC_RRCReestablishment
    ...    UE_1:NR-RRC_RRCReestablishmentComplete
    ...    alias=reestabFlow    overall_timeout=30
    Perform ReEstablishment    cell=1
    FAIL FLOW[timeout=30]: UE_1 NR-RRC 2*RRCSetup
    FAIL FLOW[timeout=30]: UE_1 NR-RRC 2*RRCSetupComplete
    Flow occurred as expected    alias=reestabFlow

#    ReEstablishment Flow Validation    validation_type=sameGNB
#    Perform ReEstablishment    cell=1
    Start Traffic    traffic_direction=dl    dl_mbps=800    size=${1400}
    Start Traffic    traffic_direction=ul    ul_mbps=150    size=${1400}
    Validate Scells State In Egate By Exact Cell    cells_to_validate_map={0: [52, 53, 54, 55, 56, 57, 58]}
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,)
    ...    dl_mbps=800
    ...    ul_mbps=150
    Collect Traffic TTI Traces
    Validate Traffic By Egate Cell Indexes    traffic_direction=dl    cells_idxs_with_traffic=(0,1,2,3,4,5,6,7)
    Validate Traffic By Egate Cell Indexes    traffic_direction=ul    cells_idxs_with_traffic=(0,1,2,3)
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Perform 5G Detach With TTI Collection
    [Teardown]    Run Keywords    Teardown Collecting Logs In Robot
    ...                    AND    Restore Default Iphy
