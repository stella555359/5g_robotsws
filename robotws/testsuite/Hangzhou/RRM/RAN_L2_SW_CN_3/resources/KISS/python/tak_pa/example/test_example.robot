*** Settings ***
Resource     ../../../robot/common_resource.robot

*** Variables ***



*** Test Cases ***
Single vendor

        ${arg1}    create list    FC:1.1.1.1:5000:1:50,100,110       #vendor:port:channel:value1,value2,value3
        Set Attenuation Arbitrary Values    ${arg1}
        
multi vendor mixed
        ${arg1}    create list    HJ:1.1.1.1:1:50000:5,7,8,25,30    JX:1.1.1.2:80:2:1,2,3,4,5,6    JX:1.1.1.3:1000:3:9,8,7,6,5,4,3,2,1
        Set Attenuation Arbitrary Values    ${arg1}    0.5

period test
        set_attenuation_periodical_values    HJ:1.1.1.1:50000:1:5,25,5


csv set value
      set_attenuation_by_csv       FC:1.1.1.1:5000     ${CURDIR}/64x16.csv


*** Keywords ***


