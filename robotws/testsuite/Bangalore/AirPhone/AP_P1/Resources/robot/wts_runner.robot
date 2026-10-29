*** Settings ***
Documentation    This contains basic wts related keywords which are needed to run the Airphone TC using wtsrunner.
...              :author Gopalakrishnan N<gopalakrishnan.n@nokia.com>

Library    OperatingSystem
Library    taf.wts.runner.wts    WITH NAME    wtsrunner
Library    taf.transport.ssh     WITH NAME    ssh
Library    ../Python/bearer_utilities.py   WITH NAME   bearer_utilities

*** Variables ***
${NOKIA_PASS}              oZPS0POrRieRtu

*** Keywords ***
Connect To WTS
    [Arguments]    ${alias}=WTSRunner
    [Documentation]	Establish a ssh connection to the WTS machine where the simulator is present
    ...                 Creation Date: 2-Apr-2020
    ...                 Modified Date:
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    ssh.Connect to     hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...                username=${tl.test_pc.default_ssh_connection_details.username}
    ...                password=${tl.test_pc.default_ssh_connection_details.password}
    ...                alias=${alias}

Start WTS Binary
    [Documentation]	Starts WTSsimulator edaemon(Starts all simulated components like
    ...                                        sim_uec-simulates User Equipments L3 and PDCP,
    ...                                        sim_enb-simulates eNB,
    ...                                        sim_mme,sim_pgw,sim_sgw - simulates Core Network)
    ...                 and Egate - User Interface
    ...		        egate console
    ...                 Creation Date: 2-Apr-2020
    ...                 Modified Date:
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    [Arguments]    ${dir_path}     ${alias}
    Connect To WTS       alias=${alias}
    ssh.execute    command=pkill egate     connection=${alias}
    ssh.execute    command=sudo pkill edaemon     connection=${alias}
    wtsrunner.Configure Wtsemu Edaemon       edaemon_ssh_alias=${alias}
    ...                                   directory_path=${dir_path}
    ...                                   port=${edaemon_port}
    ...                                   sudo_password=ute
    wtsrunner.Configure Wtsemu Egate         egate_ssh_alias=${alias}
    ...                                   directory_path=${dir_path}
    ...                                   port=${egate_port}
    wtsrunner.Start Wtsemu                   egate_console_ip=${tl.test_pc.default_ssh_connection_details.addr}
    ...                                   egate_port=${egate_port}

Load Config File
    [Documentation]	 pre-requisite for this keyword is WTSsimulator edaemon and egate should be started
    ...                  WTS Simulator is started using the cfg file given in the argument
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    [Arguments]      ${cfg_filename}=None    ${deployment_type}=NSA    ${timeout}=60s
    ${NSA_expected_msg}    Set Variable    CHANGE STATE: ACTIVE - SimMode is ready now
    ${SA_expected_msg}    Set Variable    SystemInformationBlockType1-NR updated
    ${reg_expected}   set variable if  '${deployment_type}'=='NSA'    ${NSA_expected_msg}    ${SA_expected_msg}
    wtsrunner.Configure                      file=${cfg_filename}
    wtsrunner.Read wtsemu Output Until Re    expected=${reg_expected}      timeout=${timeout}

Start and configure epcsim
    [Arguments]    ${epcsim_cfg_path}    ${alias}=WTSRunner    ${cfg_path}=/opt/wts/latest/    ${deployment_type}=NSA
    ...            ${timeout}=60s
    [Documentation]	     The WTSsimulator  is started using the cfg file given in the argument
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    Connect To WTS    ${alias}
    Start WTS Binary    ${dir_path}     ${alias}
    Load Config File    ${epcsim_cfg_path}    ${deployment_type}    ${timeout}
    Ensure Egate state

Ensure Egate state
    [Documentation]	   This Keyword confirms that the Simulator is now in ACTIVE state by checking the status
    ...                every 15 sec for over a period of 2 mins
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    Wait Until Keyword Succeeds
    ...    120sec
    ...    15sec
    ...    Simulator Status Should Be Active

Simulator Status Should Be Active
    [Documentation]	   This Keyword executes the simulator status commands and checks for ACTIVE state confirmation
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    wtsrunner.Sim State Disp
    wtsrunner.Read wtsemu Output Until Re    expected=The state is ACTIVE    timeout=15

Establish X2 link
    [Arguments]   ${enb_id}   ${gnb_id}
    [Documentation]	   This Keyword extablishes the X2 link of the MeNB
    ...                | enb_id | ID of the MeNB configured in the cfg file |
     ...               | gnb_id | ID of the SgNB configured in the cfg file |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    wtsrunner.Enb X2 Link Up    enb=1    target=2
    wtsrunner.Read Wtsemu Output Until Re
    ...    expected=ENB-1: X2AP Link with [EG]NB-2 .*(\\n)?? (\\n)??i(\\n)??s(\\n)?? (\\n)??u(\\n)??p    timeout=10

Ensure cell setup completed
    [Arguments]   ${AP_IP}
    [Documentation]	   This Keyword confirms the Cell setup is successful in Airphone
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    ${rc}=    Run and return rc
    ...       sshpass -p ${NOKIA_PASS} ssh toor4nsn@${AP_IP} 'grep -i "cell setup completed" /tmp/startup_l3.log'
    Should be Equal as Integers     ${rc}      0

Ensure UE attach passed
    [Arguments]   ${AP_IP}
    [Documentation]	   This Keyword verifies that UE attach was successful in the Airphone logs
    ...                | AP_IP | IP of the Airphone in the TL |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    ${rc}=    Run and return rc
    ...       sshpass -p ${NOKIA_PASS} ssh toor4nsn@${AP_IP} 'grep -i "Sm User Ue Connection Established Ind message status OK" /tmp/startup_l3.log'
    Should be Equal as Integers     ${rc}     0

Add Bearer
    [Arguments]   ${ue_id}   ${bearer_id}   ${filter}=0
    ...           ${precedence}=0   ${pass_regexp}=created   ${timeout}=30
    [Documentation]	   This Keyword adds a new bearer for the UE
    ...                | ue_id | ID of the UE configured in the cfg file |
    ...                | bearer_id | ID of the Bearer configured in the cfg file |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    wtsrunner.Bearer Add    ue=${ue_id} id=${bearer_id} filter=${filter} precedence=${precedence}
    wtsrunner.Read Wtsemu Output Until Re   ${pass_regexp}    timeout=${timeout}
    [Return]

SGNB Addition For Bearer
   [Arguments]    ${ue_id}   ${target_gnb}   ${target_cells}   ${bearer}   ${type}=split_scg
   ...            ${pass_regexp}=reported successful RA
   [Documentation]	   This Keyword triggers the sgNBAdiition procedure for 5G Attach
    ...                | ue_id | ID of the UE configured in the cfg file |
    ...                | target_gnb | gNB ID where you want to connect in the cfg file |
    ...                | target_cells | gNB Cell ID where you want to connect in the cfg file |
    ...                | bearer | ID of bearer to establish for the UE. Multi bearer is given separated by comma |
    ...                | type | whehter we want to split traffic or have traffic only on 5G etc |
    ...                | pass_regexp | The msg we want to check if the attach is successful |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    wtsrunner.Enb Ue Dc Start    ue=${ue_id}    target_gnb=${target_gnb}
    ...    target_cells=${target_cells}    bearer=${bearer}    type=split_scg
    wtsrunner.Read Wtsemu Output Until Re    reported successful RA    timeout=20
   [Return]

UE Attach
   [Arguments]   ${ue_id}   ${profile_id}   ${pass_regexp}=UE IS ACTIVE   ${timeout}=30
   [Documentation]	   This Keyword does the MeNB attach
    ...                | ue_id | ID of the UE configured in the cfg file |
    ...                | profile_id | Profile in which you want the UE to operate |
    ...                | ue_id | ID of the UE configured in the cfg file |
    ...                | pass_regexp | The msg we want to check if the attach is successful |
    ...                | timeout | Time we want to wait to check if the attach is successful |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
   wtsrunner.Ue Attach    id=${ue_id}    profile=${profile_id}
   wtsrunner.Read Wtsemu Output Until Re    expected=UE IS ACTIVE    timeout=${timeout}

Start Uplink Data Transfer
   [Arguments]   ${bearer}   ${ue_id}   ${speed}
   [Documentation]	   This Keyword generate traffic on the Uplink for the UE we need
    ...                | bearer | ID of the bearer in which you want to pump traffic as configured in the cfg file |
    ...                | ue_id | ID of the UE configured in the cfg file |
    ...                | speed | The speed at which we want to pump the data |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
   wtsrunner.Trf Data Start    id=${bearer}    ue=${ue_id}    dir=ul    mbps=${speed}
   [Return]

Start Downlink Data Transfer
   [Arguments]   ${bearer}   ${ue_id}   ${speed}
   [Documentation]	   This Keyword generate traffic on the Downlink for the UE we need
    ...                | bearer | ID of the bearer in which you want to pump traffic as configured in the cfg file |
    ...                | ue_id | ID of the UE configured in the cfg file |
    ...                | speed | The speed at which we want to pump the data |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
   wtsrunner.Trf Data Start    id=${bearer}    ue=${ue_id}    dir=dl    mbps=${speed}
   [Return]

Verify if average DL is correct
    [Arguments]   ${bearer}   ${ue_id}   ${limit}
    [Documentation]	   This Keyword verifies if average Downlink traffic is as expected
    ...                | bearer | ID of the bearer in which you want to pump traffic as configured in the cfg file |
    ...                | ue_id | ID of the UE configured in the cfg file |
    ...                | limit | The speed that we want to verify |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    wtsrunner.Bearer Stats    id=${bearer}    ue=${ue_id}    dir=dl
    ${out}    wtsrunner.Read Wtsemu Output Until Prompt
    Create File       ${OUTPUT_DIR}/dl_${bearer}.txt    ${out}
    ${average_dl}=      Run    cat ${OUTPUT_DIR}/dl_${bearer}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG DL : ${average_dl}    WARN
    Should Be True    ${average_dl} > ${limit}

Verify if average UL is correct
    [Arguments]   ${bearer}   ${ue_id}   ${limit}
    [Documentation]	   This Keyword verifies if average Uplink traffic is as expected
    ...                | bearer | ID of the bearer in which you want to pump traffic as configured in the cfg file |
    ...                | ue_id | ID of the UE configured in the cfg file |
    ...                | limit | The speed that we want to verify |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    wtsrunner.Bearer Stats    id=${bearer}    ue=${ue_id}    dir=ul
    ${out}    wtsrunner.Read Wtsemu Output Until Prompt
    Create File       ${OUTPUT_DIR}/ul_${bearer}.txt    ${out}
    ${average_ul}=      Run    cat ${OUTPUT_DIR}/ul_${bearer}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG UL : ${average_ul}    WARN
    Should Be True    ${average_ul} > ${limit}

Check average data transfer
    [Arguments]   ${bearer}   ${ue_id}  ${speed}
    [Documentation]	   This Keyword verifies if average Downlink and Uplink traffic is as expected
    ...                | bearer | ID of the bearer in which you want to pump traffic as configured in the cfg file |
    ...                | ue_id | ID of the UE configured in the cfg file |
    ...                | limit | The speed that we want to verify |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    ${limit}=   Get Throughput Limit   ${speed}
    Verify if average DL is correct   bearer=${bearer}   ue_id=${ue_id}   limit=${limit}
    Verify if average UL is correct   bearer=${bearer}   ue_id=${ue_id}   limit=${limit}

Get Throughput Limit
    [Arguments]   ${speed}
    [Documentation]	   This Keyword returns the speed in bits per second accounting for deviation
    ...                | speed | The speed that we want to verify |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    ${limit}=   bearer_utilities.get_throughput_limit_bits_with_deviation   speed=${speed}
    [Return]    ${limit}

UE Detach
   [Arguments]   ${ue_id}   ${pass_regexp}=detached
   [Documentation]	   This Keyword is used to Detach UE
    ...                | ue_id | ID of the UE configured in the cfg file |
    ...                | pass_regexo | The string needed to verify that detach was successful |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
   wtsrunner.ue_detach     id=${ue_id}
   wtsrunner.Read wtsemu Output Until Re    ${pass_regexp}    timeout=30s

Release ENDC Bearer
   [Arguments]   ${ue_id}   ${bearer}   ${cause}=RN_action_desirable_for_radio_reasons
   ...           ${pass_regexp}=Successfully reconfigured dual connectivity   ${timeout}=30
   [Documentation]	   This Keyword verifies if average Downlink traffic is as expected
    ...                | ue_id | ID of the UE configured in the cfg file |
    ...                | bearer | ID of the bearer in which you want to pump traffic as configured in the cfg file |
    ...                | cause | The reason for release of bearer |
    ...                | pass_regexp | The string that verifies that release of bearer was successful |
    ...                | timeout | The time we need to wait for the command to be successful |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
   wtsrunner.enb_ue_dc_release    ue=${ue_id}    bearer=${bearer}    by=enb    cause=${cause}
   wtsrunner.Read wtsemu Output Until Re    ${pass_regexp}    timeout=${timeout}

Stop All Data Transfer
   [Arguments]   ${ue_id}   ${bearer}
   [Documentation]	   This Keyword is used to stop all uplink and downlink data trasnfer for an UE bearer combination
    ...                | ue_id | ID of the UE configured in the cfg file |
    ...                | bearer | ID of the bearer in which you want to pump traffic as configured in the cfg file |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
   wtsrunner.trf_data_stop    ue=${ue_id}    id=${bearer}    dir=ul
   wtsrunner.trf_data_stop    ue=${ue_id}    id=${bearer}    dir=dl
   [Return]

Modify ENDC Add Bearer
   [Arguments]   ${ue_id}   ${bearer}   ${cause}=RN_CauseRadioNetwork_unspecified
   ...           ${pass_regexp}=Successfully reconfigured dual connectivity
   [Documentation]	   This Keyword is used to modify the details of the bearer we mish to add
    ...                | ue_id | ID of the UE configured in the cfg file |
    ...                | bearer | ID of the bearer in which you want to pump traffic as configured in the cfg file |
    ...                | cause | The reason for addition of bearer |
    ...                | pass_regexp | The string that verifies that addition of bearer was successful |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
   wtsrunner.enb_ue_dc_modify    ue=${UE_ID}    bearer_to_add=${bearer}    by=enb    cause=${cause}    type=split_scg
   wtsrunner.Read wtsemu Output Until Re    ${pass_regexp}    timeout=30s
   [Return]

Modify ENDC Release Bearer
   [Arguments]   ${ue_id}   ${bearer}   ${cause}=RN_CauseRadioNetwork_unspecified
   ...           ${pass_regexp}=Successfully reconfigured dual connectivity
   [Documentation]	   This Keyword is used to release the dual connectivity bearer
    ...                | bearer | ID of the bearer in which you want to pump traffic as configured in the cfg file |
    ...                | ue_id | ID of the UE configured in the cfg file |
    ...                | cause | The reason for release of bearer |
    ...                | pass_regexp | The string that verifies that release of bearer was successful |
    ...                  Creation Date: 2 - Apr - 2020
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
   wtsrunner.enb_ue_dc_modify    ue=${UE_ID}    bearer_to_release=${bearer}    by=enb    cause=${cause}
   ...    type=split_scg
   wtsrunner.Read wtsemu Output Until Re    ${pass_regexp}    timeout=30s
   [Return]
