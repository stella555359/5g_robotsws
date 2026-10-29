*** Settings ***
Documentation    Graph the data that needs to be checked.
...              Please do not modify the file without notification to author
...              Author: Yu Lu
...              Contact: lu.1.yu@nokia-sbell.com
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/image_output.py

*** Keywords ***
get_image_output
    [Arguments]   ${lists}
    image_output    lists=${lists}    output_dir=${OUTPUT_DIR}/${TEST NAME}

start_Draw_Curve
    [Arguments]   ${goal_data}
    draw_curve    goal_data=${goal_data}    output_dir=${OUTPUT_DIR}/${TEST NAME}
