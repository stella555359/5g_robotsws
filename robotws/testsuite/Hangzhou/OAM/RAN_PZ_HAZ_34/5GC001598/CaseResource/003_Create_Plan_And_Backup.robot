*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Create_Plan_And_Backup
    Step1: Create Plan Multiple
    Step2: Backup Plan SCF And Check File

Case Setup: Create_Plan_And_Backup
    Common Setup

Case Teardown: Create_Plan_And_Backup
    Common Teardown

Step1: Create Plan Multiple
    FOR   ${index}    IN RANGE    ${5}
       COAM WEBUI Create Plan   config_name=003_SCF_${index}
    END

Step2: Backup Plan SCF And Check File
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/003_SCF.xml
    OperatingSystem.File Should Exist   ${OUTPUT_DIR}/003_SCF.xml
