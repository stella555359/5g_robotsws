*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ald_operation.robot
*** Variables ***

*** Keywords ***
Manual_SiSo_ALD_Detect_and_setup_AL_devices_Start-up
    [Arguments]    ${ALD_num}=${1}
    FOR    ${i}    IN RANGE   ${1}    ${ALD_num}+1
        Check ALD RAEU Status    administrative_state=Unlocked    availability_status=-
        ...    operational_state=Enabled    procedural_status=-    type=ALD    index=${i}
        Check ALD REAU Info    type=ALD    index=${i}
        Check ALD RAEU Status    administrative_state=Unlocked    availability_status=-
        ...    operational_state=Enabled    procedural_status=-    type=RAEU    index=${i}
        Check ALD REAU Info    type=RAEU    index=${i}
    END
