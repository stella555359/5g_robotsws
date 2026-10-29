*** Settings ***

Documentation     [SUITE PURPOSE]   feature CB013199 Instantaneous Throughput Pooling IWK with CB008927 DL RAT1
...               Prerequisite      : gNB configured with 6 Cells
...               Scope             : cell setup & call setup & DL Tput Pooling & DL Tput limit constraints violation check
...
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : FB2505
...               Modified Date               : FB2505
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2505    ying.yw.wu@nokia.com             Creation


Resource          ./resources/robot/CB013199-Common-Keywords.robot
Resource          ./resources/robot/CB013199-B-Keywords.robot
Resource          ./resources/robot/CB013199-C-Keywords.robot


Suite Setup       CB013199-Common-Keywords.Suite Setup CB013199
...               yaml_file_path=${CURDIR}/../../../../../custom-config/POOLING/CB013199/CB013199-B/custom_config_13199_ABIP_Tdlte_3ms.yaml


*** Variables ***
&{TC_6_Cells}      nbCell=6

&{SA_UE_1}         ueId=1     callType=SA     targetCell=1     dltput=420         ultput=0        pos_profile=1
&{SA_UE_2}         ueId=2     callType=SA     targetCell=2     dltput=140         ultput=0        pos_profile=1
&{SA_UE_3}         ueId=3     callType=SA     targetCell=3     dltput=140         ultput=0        pos_profile=1
&{SA_UE_4}         ueId=4     callType=SA     targetCell=4     dltput=140         ultput=0        pos_profile=1
&{SA_UE_5}         ueId=5     callType=SA     targetCell=5     dltput=140         ultput=0        pos_profile=1
&{SA_UE_6}         ueId=6     callType=SA     targetCell=6     dltput=140         ultput=0        pos_profile=1
&{SA_UE_7}         ueId=7     callType=SA     targetCell=1     dltput=420         ultput=0        pos_profile=2

@{SA_UE_Def_List}       ${SA_UE_1}
...                     ${SA_UE_2}
...                     ${SA_UE_3}
...                     ${SA_UE_4}
...                     ${SA_UE_5}
...                     ${SA_UE_6}
...                     ${SA_UE_7}

# ---------------------------------------------------------------------------------------------------------------
*** Test Cases ***



[1]CB013199-C-Auto-ABIP-Tdlte-3ms-IWK-CB008927-DL-With-Mumimo
    [Documentation]
    ...     Conditions:
    ...     Actions:        NrCell1:
    ...                     NrCell2:
    ...                     NrCell3:
    ...     Checks:

    TC CB013199-IWK-RAT1-DL-Traffic-With-Mumimo     ${SA_UE_Def_List}
    # TC CB013199-TC-Cell-Setup              ${TC_6_Cells}
    #  [Teardown]      CB013199-Common-Keywords.End Of TC


