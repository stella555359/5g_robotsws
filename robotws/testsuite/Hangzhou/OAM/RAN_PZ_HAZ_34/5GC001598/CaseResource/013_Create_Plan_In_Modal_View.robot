*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Create_Plan_In_Modal_View
    Step0: Get All Parameter Values
    Step1: Go To CW Page
    Step2: General BTS/Site Settings
    Step3: System Module Configuration
    Step4: Baseband Module Settings
    Step5: Radio Module Settings
    Step6: Radio Module Link Configuration
    Step7: FDD Basic Cell Settings
    Step8: FDD Cell Carriers
    Step9: Basic Group Settings
    Step10: NR Cell Assignment to Group
    # Step11: Basic NR RAT Configuration

Case Setup: Create_Plan_In_Modal_View
    Common Setup

Case Teardown: Create_Plan_In_Modal_View
    Common Teardown

Step0: Get All Parameter Values
    ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/old_commission.xml
    ${smod_pc}   XML.Get Element Text   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.eqm:SMOD"]/p[@name="prodCodePlanned"]
    ${bbmod_pc}   XML.Get Element Text   ${scf_xml}   (cmData/managedObject[@class="com.nokia.srbts.eqm:BBMOD"]/p[@name="prodCodePlanned"])[1]
    ${rmod_pc}   XML.Get Element Text   ${scf_xml}   (cmData/managedObject[@class="com.nokia.srbts.eqm:RMOD"]/p[@name="prodCodePlanned"])[1]
    ${cell_type}   XML.Get Element Text   ${scf_xml}   (cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/p[@name="cellTechnology"])[1]
    Set Test Variable   ${smod_pc}   ${smod_pc.split(".")[0]}
    Set Test Variable   ${bbmod_pc}   ${bbmod_pc.split(".")[0]}
    Set Test Variable   ${rmod_pc}   ${rmod_pc.split(".")[0]}
    Set Test Variable   ${cell_type}

Step1: Go To CW Page
    COAM WEBUI Create Plan   is_copy=${False}
    Enter Into CW Page

Step2: General BTS/Site Settings
    Open CW Modal View   step_name=General BTS/Site Settings
    Select Parameter In CW Modal View   parameter_name=Time Zone   value=Asia/Shanghai
    Modify Input Parameter In CW Modal View   parameter_name=BTS name   value=013_CW
    Modify Input Parameter In CW Modal View   parameter_name=BTS ID   value=${BTS_ID}
    Done CW Modal View

Step3: System Module Configuration
    Open CW Modal View   step_name=System Module Configuration
    Add SMOD IN CW Modal View   product_code=${smod_pc}
    Done CW Modal View

Step4: Baseband Module Settings
    Open CW Modal View   step_name=Baseband Module Settings
    ADD BBMOD IN CW Modal View   product_code=${bbmod_pc}
    Done CW Modal View

Step5: Radio Module Settings
    Open CW Modal View   step_name=Radio Module Settings
    ADD RMOD IN CW Modal View
    Done CW Modal View

Step6: Radio Module Link Configuration
    Open CW Modal View   step_name=Radio Module Link Configuration
    # 474020B ABIL
    # 475266A ABIO
    ${start_point}   Set Variable If
    ...   '${bbmod_pc}'=='474020B'   S-RF1
    ...   '${bbmod_pc}'=='475266A'   RF1
    ...   ${True}   S-RF1
    Add RMOD Link IN CW Modal View   start_point=${start_point}
    Done CW Modal View

Step7: FDD Basic Cell Settings
    Open CW Modal View Cell Page   cell_type=NR FDD   step_name=Basic Cell Settings
    Add NRCELL IN CW Modal View
    &{ant_set}   Create Dictionary   1=TXRX   2=TXRX
    Cell Antennas Settings   ant_set=${ant_set}
    Done CW Modal View

Step8: FDD Cell Carriers
    Open CW Modal View Cell Page   cell_type=NR FDD   step_name=Cell Carriers
    Modify Cell Carriers
    ...   freqBand=2
    ...   cell_power=26.0
    ...   chBwDl=5MHz
    ...   chBwUl=5MHz
    ...   nrarfcnDl=392000
    ...   nrarfcnUl=376000
    ...   cell_type=FDD
    ...   cell_obj=NRCELL-0
    Done CW Modal View

Step9: Basic Group Settings
    Open CW Modal View   step_name=Basic Group Settings
    Add NR Cell Group IN CW Modal View
    Done CW Modal View

Step10: NR Cell Assignment to Group
    Open CW Modal View   step_name=NR Cell Assignment to Group
    NR Cell Assignment to Group
    Done CW Modal View

