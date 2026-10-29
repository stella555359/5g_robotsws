*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.

# Resource          common_resource.robot
# Resource          ../../../robot/qualcomm_common_keywords.robot
# Resource          ../../../robot/check_android_ue_l3_call_process.robot
# Resource          ../../../robot/traffic_via_iperf.robot
# Resource          ../../../robot/robot_common_operations/interface.robot
# Import the module common basic library
Library             ../../../../RAN_PZ_HAZ_1/Module/library/module_utils/module_utils.py

# Import the Robot interface NFTA modules
Resource            ../../../../RAN_PZ_HAZ_1/Module/Airphone_Operation.robot
Resource            ../../../../RAN_PZ_HAZ_1/Module/Alarm_Operation.robot
Resource            ../../../../RAN_PZ_HAZ_1/Module/AT_Operation.robot
Resource            ../../../../RAN_PZ_HAZ_1/Module/BTS_Operation.robot
Resource            ../../../../RAN_PZ_HAZ_1/Module/Counter_Operation.robot
Resource            ../../../../RAN_PZ_HAZ_1/Module/KPI_Operation.robot
Resource            ../../../../RAN_PZ_HAZ_1/Module/Log_Analysis.robot
Resource            ../../../../RAN_PZ_HAZ_1/Module/Log_Collection.robot
Resource            ../../../../RAN_PZ_HAZ_1/Module/Mantaray_Operation.robot
Resource            ../../../../RAN_PZ_HAZ_1/Module/PA_Operation.robot
Resource            ../../../../RAN_PZ_HAZ_1/Module/Parameter_Operation.robot
Resource            ../../../../RAN_PZ_HAZ_1/Module/RU_Operation.robot
Resource            ../../../../RAN_PZ_HAZ_1/Module/Traffic_UE_Operation.robot

# Import the python interface NFTA modules
Library             ../../../../RAN_PZ_HAZ_1/Module/Traffic_UEBox_Operation.py

