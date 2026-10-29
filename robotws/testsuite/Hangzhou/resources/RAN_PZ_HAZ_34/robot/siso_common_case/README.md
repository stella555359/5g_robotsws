# Cloud SISO common case

## Case Path

#### Cloud only Cases: 
* testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Cloud

## Variable

testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Cloud.robot

## Keywords source
* If a keyword from 5G can be used in Cloud, it should be moved into Common folder.
* If some cloud common resources from other tribes can be used and not existed in taf.rfrl.cbts, they should be commit into taf.rfrl.cbts.
* Only below source of keywords should be directly import in Cloud SISO common case file.

Libraries

    1. taf.rfrl.cbts
    2. taf libraries

Robot

    1. testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud
    2. testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common

Python

    1. testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib

## Documentation
### Case Documentation Example
```
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to execute the downlink testing in Test Model and verify its results.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Enter to TDS mode.
    ...        2. Go through the frc_index_list and execute the downlink testing in Test Model.
    ...        3. Exit TDS mode.
    ...    - [EXPECTED RESULTS] Enter TDS mode and the downlink versification should be passed,
    ...    cells should be on air for both CU and vDU after exit from TDS mode.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | test_model_list | Yes | The list of test models to be executed.|
    ...    | cell_id | No | The cell ID, default 'all' |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    * Owner: xxx.xxx@nokia-sbell.com
    ...    * Group: VRF_HAZx_xx
    ...    *******************
```

### Keyword Documentation Example
```
    [Documentation]    *****************
    ...    This keyword is used to enter the Test Mode in the Cloud.
    ...    - [Keyowrd Details]
    ...    This keyword accepts the vDU index and gNB index as arguments.
    ...    It then generates a unique string and uses it to connect to the vDU.
    ...    It deletes the SWRESETREQ-1 MO by Delta Plan and resets the vDU with check cell on air.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | vdu index in testline configuration file. Default is 0. |
    ...    | gnb_index | No | gnb index in testline configuration file. Default is 0. |
    ...    | local_output_dir | No | The local directory path to save the SCF file. Default is ${SAVE LOG DIRECTORY}. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    * Owner: xxx.xxx@nokia-sbell.com
    ...    * Group: VRF_HAZx_xx
    ...    *******************
```

## Review

For code change in testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case, MR should be created with:

    1. What are the changes
    2. Why are they changed
    3. Test log file on onwer testline -- Confirm case can be run
    4. Test log file on other teams testline -- Confirm is a common case

And @**HAZ34_CLOUD_SISO_COMMON** as reviewer. Assign to **Civen Chen**.

For Code change in **taf.rfrl.cbts**, please contact Civen Chen for developer access, add Cheng Xianbiao and file author in MR as reviewer.


## Contact

HAZ34_CLOUD_SISO_COMMON
* Civen Chen [civen.chen@nokia-sbell.com]
* Tingting Zhong [tingting.zhong@nokia-sbell.com]
* Deng Aaron [aaron.deng@nokia-sbell.com]
* Ge Gao [ge.gao@nokia-sbell.com]
* Jiayi Tang [jiayi.tang@nokia-sbell.com]
* Qunfang Zeng [qunfang.zeng@nokia-sbell.com]
* Xiangli Kong [xiangli.kong@nokia-sbell.com]
* Shifu Lan [shifu.lan@nokia-sbell.com]
