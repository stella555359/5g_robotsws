*** Settings ***
Documentation                       How to merge two json files

Library                             ../../python/CoamParameter.py      WITH NAME     coam_parameter
Resource                            ../Tools.robot


*** Variables ***
${jsonFile1}                        /home/ute/CrtRoot/1_Delta_Configuration_scf_MPAPLOisoLOAPLO_WITH_BF_Cell1.json
${jsonFile2}                        /home/ute/CrtRoot/2_Delta_Configuration_scf_UL_CL_powerCtrl_Cell1.json
${jsonFile3}                        /home/ute/CrtRoot/3_Delta_Configuration_UlDftsOfdm_activ_cell1.json

${badJsonFile}                      /home/ute/CrtRoot/nonExistingFile.json


*** Test Cases ***
Test title
    Dated Log                       START
    ${mergedJsonFile1}              set variable        ${OUTPUT DIR}/Merged_Json_File1.json
    ${mergedJsonFile2}              set variable        ${OUTPUT DIR}/Merged_Json_File2.json
    ${mergedJsonFile3}              set variable        ${OUTPUT DIR}/Merged_Json_File3.json
    ${bad_mergedJsonFile}           set variable        ${OUTPUT DIR}/NonExistingDirectory/Merged_Json_File3.json

    ${jsonFilesList_1}              create list         ${jsonFile1}

    ${jsonFilesList_2}              create list         ${jsonFile1}
    ...                                                 ${jsonFile2}

    ${jsonFilesList_3}              create list         ${jsonFile1}
    ...                                                 ${jsonFile2}
    ...                                                 ${jsonFile3}

    ${bad_jsonFilesList}            create list         ${jsonFile1}
    ...                                                 ${badJsonFile}
    ...                                                 ${jsonFile3}

    # case1 : all input parameters are missing
    run keyword and ignore error    coam_parameter.combine_json_files

    # case1 : first parameters is missing
    run keyword and ignore error    coam_parameter.combine_json_files       mergedJsonFile=${mergedJsonFile1}

    # case2 : second parameters is missing
    run keyword and ignore error    coam_parameter.combine_json_files       jsonFilesList=${jsonFilesList_3}

    # case3 : all parameters are set BUT only 1 file in list
    run keyword and ignore error    coam_parameter.combine_json_files       jsonFilesList=${jsonFilesList_1}
    ...                                                                     mergedJsonFile=${mergedJsonFile1}

    # case4 : all parameters are set BUT 1 file in list is not correctly defined
    run keyword and ignore error    coam_parameter.combine_json_files       jsonFilesList=${bad_jsonFilesList}
    ...                                                                     mergedJsonFile=${mergedJsonFile2}

    # case5 : all parameters are set BUT the merge file is not correctly defined
    run keyword and ignore error    coam_parameter.combine_json_files       jsonFilesList=${jsonFilesList_2}
    ...                                                                     mergedJsonFile=${bad_mergedJsonFile}

    # case6 : all parameters are set AND 2 files in list
    run keyword and ignore error    coam_parameter.combine_json_files       jsonFilesList=${jsonFilesList_2}
    ...                                                                     mergedJsonFile=${mergedJsonFile2}

    # case7 : all parameters are set AND 3 files in list
    run keyword and ignore error    coam_parameter.combine_json_files       jsonFilesList=${jsonFilesList_3}
    ...                                                                     mergedJsonFile=${mergedJsonFile3}
