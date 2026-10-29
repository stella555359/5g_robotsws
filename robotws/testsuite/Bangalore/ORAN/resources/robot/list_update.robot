*** Settings ***

Library           taf.sbts.oam.coam.admin    WITH NAME    coamsbts


*** Variables ***

&{dict1}          a2HysteresishoSsbRsrp=0  a2ThresholdhoSsbRsrp=66   a2TimeToTriggerhoSsbRsrp=ms256
@{list1}         &{dict1}
&{dict2}          a3HysteresisSsbRsrp=0  a3OffsetSsbRsrp=5  a3TimeToTriggerSsbRsrp=ms64
@{list2}         &{dict2}
&{dict3}          a5HysteresisSsbRsrp=0  a5Threshold1SsbRsrp=52  a5Threshold2SsbRsrp=48	a5TimeToTriggerSsbRsrp=ms640
@{list3}         &{dict3}


#*** Test Cases ***

#====================================#
# IMPORTANT: keep TC names unique!!! #
#====================================#


*** Keywords ***
SCF_ListUpdate
      [Arguments]    ${NRCELLID}
      BuiltIn.Log Variables
	  BuiltIn.Log  		${NRCELLID}
      coamsbts.connect to    bts_host=192.168.255.129    bts_port=3600    name=default
      coamsbts.perform parameter recommissioning    parameter=a2MeashoSsbRsrp    value=${list1}    dist_name=MRBTS-1003/NRBTS-1003/NRCELL-10031
	  ...    operation=update    timeout=60  
      coamsbts.perform parameter recommissioning    parameter=a3MeasSsbRsrp    value=${list2}   dist_name=MRBTS-1003/NRBTS-1003/NRCELL-10031
	  ...    operation=update    timeout=60
      coamsbts.teardown


SCF_a235MeashoEnabled_List
#      ${NRCELLID}    Run    ${awkNRCELLIDinfo}
#	  Set Test variable    ${NRCELLID}
#	  Builtin.log		${NRCELLID}	
      [Arguments]    ${NRCELLID}     ${NRCELLID1}
      BuiltIn.Log Variables
      BuiltIn.Log Many      ${NRCELLID}     ${NRCELLID1}
	  coamsbts.connect to    bts_host=192.168.255.129    bts_port=3600    name=default
      coamsbts.perform parameter recommissioning    parameter=a2MeashoSsbRsrp    value=${list1}    dist_name=${NRCELLID}
	  ...    operation=update    timeout=60  
      coamsbts.perform parameter recommissioning    parameter=a3MeasSsbRsrp    value=${list2}   dist_name=${NRCELLID}
	  ...    operation=update    timeout=60
	  coamsbts.perform parameter recommissioning    parameter=a5MeasSsbRsrp    value=${list3}   dist_name=${NRCELLID}
	  ...    operation=update    timeout=60
      coamsbts.perform parameter recommissioning    parameter=a5MeasSsbRsrp    value=${list3}   dist_name=${NRCELLID1}
	  ...    operation=update    timeout=60
      coamsbts.teardown

SCF_a235MeashoEnabled_List_intergnb
#      ${NRCELLID}    Run    ${awkNRCELLIDinfo}
#     Set Test variable    ${NRCELLID}
#     Builtin.log       ${NRCELLID} 
      [Arguments]    ${NRCELLID}
      BuiltIn.Log Variables
      BuiltIn.Log       ${NRCELLID}
      coamsbts.connect to    bts_host=192.168.255.129    bts_port=3600    name=default
      coamsbts.perform parameter recommissioning    parameter=a2MeashoSsbRsrp    value=${list1}    dist_name=${NRCELLID}
	  ...    operation=update    timeout=60
      coamsbts.perform parameter recommissioning    parameter=a3MeasSsbRsrp    value=${list2}   dist_name=${NRCELLID}
	  ...    operation=update    timeout=60
      coamsbts.perform parameter recommissioning    parameter=a5MeasSsbRsrp    value=${list3}   dist_name=${NRCELLID}
	  ...    operation=update    timeout=60
#      coamsbts.perform parameter recommissioning    parameter=a5MeasSsbRsrp    value=${list3}   dist_name=${NRCELLID1}
     ...    operation=update    timeout=60
      coamsbts.teardown
