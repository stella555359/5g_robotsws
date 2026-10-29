*** Settings ***

Documentation     [SUITE PURPOSE]   feature CB013199 Instantaneous Throughput Pooling
...               Prerequisite      : gNB configured with 6 Cells
...               Scope             : cell setup & call setup
...
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 19-09-2024
...               Modified Date               : 19-09-2024
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2419    ying.yw.wu@nokia.com             Creation

# Resource          ../CB008940/resources/robot/CB008940-I-J-Keywords.robot
Resource          ./resources/robot/CB013199-Common-Keywords.robot
Resource          ./resources/robot/CB013199-B-Keywords.robot


Force Tags        CA_5G_SW_FR-Villarceaux    RRM
...               PY39
...               CLOUD_5G_O_H_AP_LOOO    SANSA_FS_ECPRI_CMWV_TDD
...               master_classicalbts_all    SBTS00
...               RAN_5G_TDD     CONFIGURED    5G_RAN    RAN_5G    CRT



Suite Setup       CB013199-Common-Keywords.Suite Setup CB013199
...               yaml_file_path=${CURDIR}/../../../../../custom-config/POOLING/CB013199/CB013199-A/custom_config_13199_A_ASOH.yaml


*** Variables ***
&{TC_4_Cells}                                                       nbCell=4

# ---------------------------------------------------------------------------------------------------------------
*** Test Cases ***


[1]CB013199-A-Throughput-Pooling-Activation
    [Documentation]
    ...     Conditions:
    ...     Actions:        NrCell1:
    ...                     NrCell2:
    ...                     NrCell3:
    ...     Checks:

    TC CB013199-TC-Cell-Setup              ${TC_4_Cells}
    #[Teardown]      CB013199-Common-Keywords.End Of TC

[1]CB013199-B-DL-UL-Throughput-Pooling-With-Mumimo
    [Documentation]
    ...     Conditions:
    ...     Actions:        NrCell1:
    ...                     NrCell2:
    ...                     NrCell3:
    ...                     NrCell4:
    ...     Checks:
    TC CB013199-DL-UL-Mumimo-Cell-Setup-ASOH     ${TC_4_Cells}

[1]CB013199-A-B-DL-Throughput-Pooling
    [Documentation]
    ...     Conditions:
    ...     Actions:        NrCell1:
    ...                     NrCell2:
    ...                     NrCell3:
    ...     Checks:

    TC CB013199-DL-Traffic-Only             UEdefListparam=${UE_Def_DL_List_01}
    #[Teardown]      CB013199-Common-Keywords.End Of TC

[1]CB013199-A-B-UL-Throughput-Pooling
    [Documentation]
    ...     Conditions:
    ...     Actions:        NrCell1:
    ...                     NrCell2:
    ...                     NrCell3:
    ...     Checks:

    TC CB013199-UL-Traffic-Only             UEdefListparam=${UE_Def_UL_List_01}
    #[Teardown]      CB013199-Common-Keywords.End Of TC

[1]CB013199-A-B-DL-UL-Throughput-Pooling
    [Documentation]     CB013199 Basic DL+UL Throughput Allocation
    ...                 Conditions:
    ...                     4 TDD Cells on half ASOH, without mumimo cells
    ...                     PRB Pooling Features activated +
    ...                     CB013199 Tput Pooling Activated
    ...                     AQOH Half Mode 4 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-2 | NRCELL-4  |
    ...                     +----------+----------+----------------------+
    ...                     |     L1 SubPoolId=3  | L1 SubPoolId=2       |
    ...                     +---------------------+----------------------+
    ...                     |                L1 PoolId=12                |
    ...                     +---------------------+----------------------+
    ...                 Actions:
    ...                     1) cell setup with 4 TDD cells in one L1pool on half ASOH, Cell 1 (50) is configured with MUMIMO enabled
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : 1 SA UE, UE id 1, DL 175mbps + UL 75mbps;
    ...                         NRCELL-2 (51) : 1 SA UE, UE id 2, DL 175mbps + UL 75mbps;
    ...                         NRCELL-3 (52) : 1 SA UE, UE id 3, DL 175mbps + UL 75mbps;
    ...                         NRCELL-4 (53) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                     3) Collect TTI traces & gnb snapshot
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit

    TC CB013199-DL-UL-Traffic             UEdefListparam=${UE_Def_DL_UL_List_01}
    #[Teardown]      CB013199-Common-Keywords.End Of TC