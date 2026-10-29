*** Settings ***
Documentation
...    author: Du Ning
...    contact: ning.du@nokia-sbell.com
...    This is the entrance file for all modules, you need to import this file to use the modules.
...    The module plan and progress: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/20.+Module+Plan+and+Status

# Import the module common basic library
Library             ./library/module_utils/module_utils.py

# Import the Robot interface NFTA modules
Resource            Airphone_Operation.robot
Resource            Alarm_Operation.robot
Resource            AT_Operation.robot
Resource            BTS_Operation.robot
Resource            Counter_Operation.robot
Resource            KPI_Operation.robot
Resource            Log_Analysis.robot
Resource            Log_Collection.robot
Resource            Mantaray_Operation.robot
Resource            PA_Operation.robot
Resource            Parameter_Operation.robot
Resource            RU_Operation.robot
Resource            Traffic_UE_Operation.robot

# Import the python interface NFTA modules
Library             Commercial_UE_Operation.py
Library             Traffic_UEBox_Operation.py

