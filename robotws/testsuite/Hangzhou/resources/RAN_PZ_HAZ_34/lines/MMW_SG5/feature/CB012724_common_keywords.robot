# @Time    : 2025/1/22 10:57
# @Author  : Echo.1.Xu
# @Email   : echo.xu@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB009514_common_keywords.robot
# @Software: PyCharm
# @Doc     : This is common robot keywords template
*** Settings ***
Documentation
...    Feature CB012724

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***





Restore PA
    Log to console    restor all RU
    gnb_classical_hangzhou.Get Initial Attenuation Values For RU    vendor=HBTE
    ${channels_to_modify}    create dictionary    5=0    6=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=0
    ${channels_to_modify}    create dictionary    3=0    4=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=1
    ${channels_to_modify}    create dictionary    9=0    10=0    11=0    12=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    ${channels_to_modify}    create dictionary    1=0    2=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=6
    ${channels_to_modify}    create dictionary    7=0    8=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=12
    ${channels_to_modify}    create dictionary    13=127   14=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=10
Set PA for RU-11 CALL
    Log to console    Set PA for RU11 CALL
    gnb_classical_hangzhou.Get Initial Attenuation Values For RU    vendor=HBTE
    ${channels_to_modify}    create dictionary    5=127    6=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=0
    ${channels_to_modify}    create dictionary    3=127    4=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=1
    ${channels_to_modify}    create dictionary    9=127    10=127    11=127    12=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    ${channels_to_modify}    create dictionary    1=127    2=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=6
    ${channels_to_modify}    create dictionary    7=127    8=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=12
	  ${channels_to_modify}    create dictionary    13=0   14=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=10

