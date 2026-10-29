*** Settings ***

Documentation     [SUITE PURPOSE]   feature CB013199 Instantaneous Throughput Pooling
...               Prerequisite      : gNB configured with 6 Cells with framestruct tdlte 3ms canada
...               Scope             : cell setup
...
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : FB2501
...               Modified Date               : FB2501
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2501    ying.yw.wu@nokia.com             Creation


Resource          ./resources/robot/CB013199-Common-Keywords.robot
Resource          ./resources/robot/CB013199-B-Keywords.robot


Force Tags        CA_5G_SW_FR-Villarceaux    RRM
...               PY39
...               CLOUD_5G_I_MP_AP_LOOO    SANSA_FS_ECPRI_CMWV_TDD
...               master_classicalbts_all    SBTS00
...               RAN_5G_TDD     CONFIGURED    5G_RAN    RAN_5G    CRT



Suite Setup       CB013199-Common-Keywords.Suite Setup CB013199
...               yaml_file_path=${CURDIR}/../../../../../custom-config/POOLING/CB013199/CB013199-A/custom_config_13199_A.yaml


*** Variables ***
&{TC_6_Cells}                                                       nbCell=6

# ---------------------------------------------------------------------------------------------------------------
*** Test Cases ***

[1]CB013199-B-ABIP-Canada-Throughput-Pooling-With-Mumimo
    [Documentation]
    ...     Conditions:
    ...     Actions:        NrCell1:
    ...                     NrCell2:
    ...                     NrCell3:
    ...                     NrCell4:
    ...     Checks:
    TC CB013199-DL-UL-Mumimo-Cell-Setup     ${TC_6_Cells}