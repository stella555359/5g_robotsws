*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Create_Plan_In_Site_View
    Step0: Get HW Product Code
    Step1: Create Empty Plan
    Step2: Add Modules In Site View
    Step3: Check Object Created

Case Setup: Create_Plan_In_Site_View
    Common Setup

Case Teardown: Create_Plan_In_Site_View
    Common Teardown

Step0: Get HW Product Code
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/old_commission.xml
    ${smod_pc}   XML.Get Element Text   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.eqm:SMOD"]/p[@name="prodCodePlanned"]
    ${bbmod_pc}   XML.Get Element Text   ${scf_xml}   (cmData/managedObject[@class="com.nokia.srbts.eqm:BBMOD"]/p[@name="prodCodePlanned"])[1]
    ${rmod_pc}   XML.Get Element Text   ${scf_xml}   (cmData/managedObject[@class="com.nokia.srbts.eqm:RMOD"]/p[@name="prodCodePlanned"])[1]
    ${cell_type}   XML.Get Element Text   ${scf_xml}   (cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/p[@name="cellTechnology"])[1]
    Set Test Variable   ${smod_pc}   ${smod_pc.split(".")[0]}
    Set Test Variable   ${bbmod_pc}   ${bbmod_pc.split(".")[0]}
    Set Test Variable   ${rmod_pc}   ${rmod_pc.split(".")[0]}
    Set Test Variable   ${cell_type}

Step1: Create Empty Plan
    COAM WEBUI Create Plan   is_copy=${False}
    Enter Into CW Page

Step2: Add Modules In Site View
    Add HW In CW Site View   hw_module=System Module   product_code=${smod_pc}
    Add HW In CW Site View   hw_module=BBMOD   product_code=${bbmod_pc}
    Add HW In CW Site View   hw_module=Radio   product_code=${rmod_pc}
    Add Cell In CW Site View   cell_type=NRCELL ${cell_type}

Step3: Check Object Created
    COAM WEBUI Save BTS Configuration   SCF_path=${OUTPUT_DIR}/new_plan.xml
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/new_plan.xml
    XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.eqm:SMOD"]
    XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.eqm:BBMOD"]
    XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.eqm:RMOD"]
    XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    XML.Element Text Should Be   ${scf_xml}   ${cell_type}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/p[@name="cellTechnology"]
