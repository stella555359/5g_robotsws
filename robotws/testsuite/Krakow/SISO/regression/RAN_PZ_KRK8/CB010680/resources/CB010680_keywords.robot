*** Settings ***
Documentation
...     Keywords for testing CB0010680 feature
...     Author: Natalia Czech, Bartosz Odziomek
...     Contact: natalia.czech@nokia.com, bartosz.odziomek@nokia.com


Library              testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB010680/resources/keywords.py
Resource             testsuite/Krakow/resources/RAN_PZ_KRK8/keywords.robot
Resource             taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Variables            testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB010680/resources/parameters.py
Variables            taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
${sw_config_path}               testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/UUF4ALL/resources/swconfig.txt
${BTS_config_A}                 A
${BTS_config_B}                 B
${BTS_config_F}                 F
${BTS_config_C}                 C
${BTS_config_H}                 H
${BTS_config_J}                 J
${BTS_config_main}              B
${path_to_snapshot}             /home/ute/snapshot/SNAPSHOT
${path_to_unzip}                /home/ute/snapshot/UNZIPSNAPSHOT
