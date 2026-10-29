*** Settings ***
Force Tags     CRT    CLOUD_ASOG_4CUS      SBTS00    RAN_4G    RAN_4G_FDD    SBTS23R1   PY36

Documentation
...  AUTHOR          :   vaibhav.3.tyagi@nokia.com
...  MAINTAINER      :   vaibhav.3.tyagi@nokia.com
...  INTRODUCTION    :  CB011153 feature about fast ue release when T301 timer is running
...  TEST SET NAME   :   CB011153
...  TESTING SPLIT   :   SPLIT-A
...  REFERENCES      :   CFAM CB011153



#Library          taf.sw.scout    WITH NAME     scout
Resource     ./CB011153_resource.robot


#Suite Setup         Run Keyword and Ignore Error      Setup.Suite setup from scratch
##                    ...                 AND    Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
##                    ...                 AND     gnb.Perform gNB reboot


*** Variables ***
${local_cell_id_1}=                 DN:NE-LNBTS-1/LNCEL-1
${r&d_parameter}      0x10040=1;0x10041=5;0x13001E=1;0x13001F=1;0x130020=1;0x450027=1;
                   ...    0x19012=1;0x30000F=1;0x190074=0;
                   ...    0x4F0031=0;0x1A0077=0;0x1A0020=1;

*** Test Cases ***
CB011153_01_Feature_configuration_activation_and_de_activation

#     taf.sw.syslog.Start Syslog    log_dir=/tmp    log_name=feat_act.log    alias=feat_act  ip=192.168.255.126
     Find Scfc And Send Delta Commissioning      featureactivate.json
     sleep   200s
     Find Scfc And Send Delta Commissioning      Delta_config.json
     sleep    300s
     Attach "UE_2"
     Attach UE and Start Data Traffic    ${2}    ${2}
#     Start egate collection
#     Configure Env for CB011153
     Run Keyword and Ignore Error    Trigger E-RAB releases due to RLF     1
#     Teardown egate and edaemon
#     Stop egate collection
#     Verify if UEContextReleaseRequest with UE lost cause is send from ENB to MME

     Find Scfc And Send Delta Commissioning      featuredeactivate.json
#     common_log_collection.Stop Log    btslog
#     taf.sw.syslog.Stop Syslog
     sleep    300s
     Run Keyword and Ignore Error    Verify Counters CB011153
#
     [Teardown]     Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting

