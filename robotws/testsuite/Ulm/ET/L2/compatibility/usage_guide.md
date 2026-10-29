# Compatability Tester
## Purpose:
The collection of python scripts in this folder is meant to be used to test if changes to Teal Framework would result in a change in generated output. This can be used to find potential bugs in the new code, provided that the known state (golden state) is correct.

## Usage:
- make sure you are in the robotws .venv when using the script, as it uses deepdiff for analysis, which is available in that enviroment.
- the current directory you are execution the main python script from has no effect.
- make sure to check the `ROBOTWS_PARENT_DIR` in `test_all_json_files`, default path is: `/home/ute/DEVELOPMENT`. At the moment this can not be used with the preinstalled `test_repo` and `test_repository` that is preinstalled on ute testlines.
- start the script to run the check for all files with `python test_all_json_files.py`
- wait for the script to finish, it might take half a minute.
- if you dont have golden files yet, you will have to get them or use the current files as golden files, by copying them to the `golden_files` folder

----------
*for question please contact valentin.hirzel@nokia.com*