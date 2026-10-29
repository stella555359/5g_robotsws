*** Settings ***
Resource           ./../CUDU_L2/common_setup_teardown.robot


*** Test Case ***
Insert Log To Database
    Run    python ${CURDIR}/python/operate_pm_counter_postgres_database.py insert "CB008927_I_E25" "RAT1" "M55308C00093" 88888
