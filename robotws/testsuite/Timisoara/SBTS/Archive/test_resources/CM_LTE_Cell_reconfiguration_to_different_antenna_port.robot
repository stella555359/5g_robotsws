*** Settings ***
Resource    ../../common_resources/ca_CIT_general.robot


*** Variables ***
${TIMEOUT}   		600          # Timeout
${DELTA_PATH}		             # Put absolute path to delta json file


*** Keywords ***
TC__CM_LTE_Cell_reconfiguration_to_different_antenna_port
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-15819
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Remapping LTE cell another ANTL port.
    ...  Reconfiguration is performed in according to delta JSON file, which needs to be defined by tester.
    ...	 Delta JSON file can be obtained from Admin (with developer login) or created manually.
    ...  Delta JSON example:
    ...  [
    ...   {
    ...      "distName":"MRBTS-XXXXX/LNBTS-XXXXX/LNCEL-XXXXX/LNCEL_FDD-0",
    ...      "operation":"update",
    ...      "parameters":[
    ...	  {
    ...	     "parameterName":"earfcnDL",
    ...		 "value":"2950",
    ...		 "operation":"update"
    ...	  },
    ...	  {
    ...	     "parameterName":"earfcnUL",
    ...    ...		 "value":"20950",
    ...		 "operation":"update"
    ...	  }
    ...	  ]
    ...   },
    ...   {
    ...      "distName":"MRBTS-XXXXX/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-6/CHANNELGROUP-1/CHANNEL-1",
    ...	  "operation":"update",
    ...	  "parameters":[
    ...	  {
    ...	     "parameterName":"antlDN",
    ...		 "value":"MRBTS-XXXXX/EQM-1/APEQM-1/RMOD-6/ANTL-1",
    ...		 "operation":"update"
    ...	  }
    ...	  ]
    ...	},
    ...   {
    ...	  "distName":"MRBTS-XXXXX/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-6/CHANNELGROUP-1/CHANNEL-2",
    ...	  "operation":"update",
    ...	  "parameters":[
    ...	  {
    ...	     "parameterName":"antlDN",
    ...		 "value":"MRBTS-XXXXX/EQM-1/APEQM-1/RMOD-6/ANTL-1",
    ...		 "operation":"update"
    ...	  }
    ...	  ]
    ...	},
    ...	{
    ...	  "distName":"MRBTS-XXXXX/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-6/CHANNELGROUP-1/CHANNEL-3",
    ...	  "operation":"update",
    ...	  "parameters":[
    ...	  {
    ...	     "parameterName":"antlDN",
    ...		 "value":"MRBTS-XXXXX/EQM-1/APEQM-1/RMOD-6/ANTL-2",
    ...		 "operation":"update"
    ...	  }
    ...	  ]
    ...	},
    ...	{
    ...	  "distName":"MRBTS-XXXXX/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-6/CHANNELGROUP-1/CHANNEL-4",
    ...	  "operation":"update",
    ...	  "parameters":[
    ...	  {
    ...		 "parameterName":"antlDN",
    ...		 "value":"MRBTS-XXXXX/EQM-1/APEQM-1/RMOD-6/ANTL-2",
    ...		 "operation":"update"
    ...	  }
    ...	  ]
    ...	}
    ...  ]
    ...
    ...
    ...	 In the end of the test an original configuration is restored.
    ...
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-15819 - Test creation
    ...  - 26.02.2020 - https://jira3.int.net.nokia.com/browse/TAT-18412 - Necessary modifications for CIT
	...
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/blob/master/CM_LTE_Cell_reconfiguration_to_different_antenna_port.png

    Set Tags    CA-CM    OWNER-lukasz.rudzinski@nokia.com    MAINTAINER-vlad.slivilescu@nokia.com
    ...    AUTHOR-daniel.bartkowiak@nokia.com    PHASE-CRT    SW-SBTS19A    FEATURE-LTE2060    GROUP_IN_CHARGE-TIM_2_Vrf

    Preconditions
    Step 1: Performing Cell Remapping
    Step 2: Verifying Post Conditions


Preconditions
    Log  === Preconditions started ===   console=True
    Check If Config Is LWG
    OperatingSystem.File Should Exist  ${DELTA_PATH}
	Collect Scf  ${Test Files}/initial_SCF.xml
    Get JSON content
	Log  === End of preconditions ===   console=True

Step 1: Performing Cell Remapping
	Log  === Step 1: Performing Cell Remapping ===  console=True
	Validate if delta is not included into SCF before delta recommissioning  ${DELTA_JSON}  ${Test Files}/initial_SCF.xml
	Perform Delta Recommissioning  delta_file=${DELTA_PATH}  timeout=${TIMEOUT}
	${reset_triggered}=  Infomodel Check IM Log If BTS Reset Was Triggered  ${BTS Files}/IM/InfoModel_log_for_reset_check.ims2
    Run Keyword If  ${reset triggered}  Fail  msg=SBTS reset was triggered after delta commissioning! Stopping test.

Step 2: Verifying Post Conditions
    Log  === Step 2: Verifying Post Conditions ===  console=True
    Check Configuration After Recommissioning
    Check Alarms
    Assert All Cells Are In Expected State

Check if Config Is LWG
	${lte_status}=    Query infomodel  //MRBTS_M-*/LNBTS_M-* is [stateInfo.proceduralState=NotCommissioned]  allow_negative_result=True
    ${wcdma_status}=  Query infomodel  //WNCEL_R-*/WNBTS_M-* is [stateInfo.proceduralState=NotCommissioned]  allow_negative_result=True
    ${gsm_status}=    Query infomodel  //GNCEL_R-*/GNBTS_M-* is [stateInfo.proceduralState=NotCommissioned]  allow_negative_result=True
	Run Keyword If  ${lte_status} and ${wcdma_status} and ${gsm_status}  Fail  Config is not LWG. Please execute TC on 3 RAT test line

Get JSON Content
    ${json}=  OperatingSystem.Get File  ${DELTA_PATH}
    ${json}=  Evaluate  json.loads('''${json}''')  json
    Set test variable  ${DELTA_JSON}  ${json}

Check Configuration After Recommissioning
    Collect Scf  ${Test Files}/SCF_after_recommissioning.xml
    ${scf_xml}=  Parse xml  ${Test Files}/SCF_after_recommissioning.xml
    FOR  ${scf_object}  IN  @{DELTA_JSON}
        Log  === Checking delta object with distName ${scf_object['distName']} === console=True
        Verify parameters values in SCF object  ${SCF_XML}  ${scf_object['distName']}  ${scf_object['parameters']}
    END
    Log  === All parameters in delta JSON have the same values as parameters in SCF ===  console=True

Check Alarms
    ${alarms_status}  ${alarms_msg}=  Run Keyword And Ignore Error  Admin Check Active Alarms TAF
    Run Keyword If  ${alarms_msg}  Set test restriction  Unexpected alarms are present: ${alarms_msg}

Custom Test Teardown
    Admin Get bts_id and perform commissioning   ${Test Files}/initial_SCF.xml  True  ${TIMEOUT}
    Wait until keyword succeeds  15 min  15 sec  Assert All Cells Are In Expected State
    Common Test Teardown


TC Setup
    Common Test Setup

TC Teardown
    Custom Test Teardown
