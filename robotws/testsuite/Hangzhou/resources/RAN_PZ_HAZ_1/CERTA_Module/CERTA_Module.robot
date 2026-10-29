*** Settings ***
Documentation
...    author: Du Ning
...    contact: ning.du@nokia-sbell.com
...    This is the entrance file for all CERTA modules, you need to import this file to use the modules.
...    The module plan and progress: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/20.+Module+Plan+and+Status

# Import the NFTA module entry file
Resource            ../Module/Module.robot

# Import the CERTA modules
Resource            Temp_Nidd_Check.robot
Resource            Counter_Check_With_RU_Reset.robot
Resource            Fault_1900_Trigger_Clear.robot
# Resource            RRM_Traffic_With_Airphone.robot
# Resource            Traffic_Impact_Check_With_Log_Collection.robot
# Resource            Sleeping_Cell_Check_With_Component_Reset.robot
