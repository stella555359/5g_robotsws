# SiSo cases

## Usage
### Use common path variable to have shorter import path.
```
Suite Setup          SBTS Suite Setup
Suite Teardown       SBTS Suite Teardown
Test Setup           SBTS Test Setup
Test Teardown        SBTS Test Teardown

# Import variable file you need
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot

# Import setup teardown file
Resource    ${BASIC_PATH_COMMON}/5G_Setup_And_Teardown.robot

# Import cases keywords from 5G/LTE/Common
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
# Resource    ${BASIC_PATH_COMMON}/General_SiSo_RF_module_power_reset.robot
# Resource    ${BASIC_PATH_LTE}/General_SiSo_RF_module_power_reset.robot
```
### Example Cases
* [LTE_TEST.robot](testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/SBTS_LTE/LTE_TEST.robot)
* [5G_TEST.robot](testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/SBTS_5G/5G_TEST.robot)

## Common resources

### Cases level resources
* Each case keyword should be an individual resource file with same name with case.
* Each file should only import the keyword file this import used

Structure
```
siso_common_cases/cases
|- 5G      (For 5G only cases)
|- Common  (For Cases common for 5G and LTE)
|- LTE     (For LTE only cases)
```
### Keywords level resources
Structure
```
siso_common_cases/step_keywords
|- 5G      (For 5G only keywords)
|- Common  (For keywords common for 5G and LTE)
|- LTE     (For LTE only keywords)
```
### Variables
Structure
```
siso_common_cases/variable
|- Variables_5G.robot   (For suite file execute cases on 5G env, import Variables_5G to get params from 5G TL)
|- Variables_LTE.robot  (For suite file execute cases on LTE env, import Variables_LTE to get params from LTE TL)
```
