_**Implementation Overview:**_
Input : The script processes DCAP Logs containing TTILogs(.pcap) and SCF files.
Output : It generates a comprehensive report detailing the Overall Result, 
the number of UEs (User Equipment), and the number of SSSG (Search Space Set Group) switches  analyzed.

_**Pre-requisites to run the script:**_
Make sure you have python >= 3.13

_**Initial Setup**_
In the script directory, right click and open a terminal
run -> 
python setup.py   [ this is required for the first time]
An environment named .tti_env is created where required packages are installed

_**Script Usage:**_
EveryTime you need to activate the environment with this command:
Environment activation command:  ./.tti_env/Scripts/activate
To run the script after the environment is activated:

**For Zipped Logs:**
python main.py zip_path     provide the path to your zip file is here
python main.py rotta_path   It also accepts zip path from rotta
                            If the path is rotta path, zip file is downloaded into downloads folder and decoded in the parent directory of tti_trace_verification_script

Example: 
python .\main.py C:\Users\hsomu\Documents\tti_trace_verification_script\downloads\UTFLab_2026-01-05T05_44_07.666Z

python .\main.py "\\nescrotta.nesc.nokia.net\rotta\MN_RAN\RAN_VRF\26R2\New_Features\VRF_BLR1\T10\CB012631\precheck-21\FDD_HO_disabled-to-Enabled_UecontextReleas\UTFLab_2026-01-05T05_44_07.666Z.zip"
You can refer the terminal logs to see where your logs are downloaded to your pc from rotta

**For Decoded Logs:**
python main.py decoded_folder_path --decoded        Use this option if the logs are also decoded by TtiTraceHelper

Example:
python main.py C:\Users\hsomu\Documents\tti_trace_verification_script\downloads\UTFLab_2026-01-05T05_44_07.666Z --decoded

**Provide Destination path:**
python main.py zip_path --destination_path path_to_your_desitnation_folder
Example:
python main.py C:\Users\hsomu\Documents\tti_trace_verification_script\downloads\UTFLab_2026-01-05T05_44_07.666Z.zip --destination_path C:\Users\Downloads

**If no scf in the zip:**
python main.py zip_path --scf_file path_to_scf_file

_**Output**_
Output is printed in terminal, as well as it stores all the output logs in a folder called logs_timestamp in that particular subfolder

Example:
_**Before**_
zip_folder/
└── 2085003052/
    ├── 0800/
    │   ├── ssgEvaluationData.csv
    │   ├── ulDci_decode.csv
    │   └── dl_dci_decode.csv
    └── 0900/
        ├── ssgEvaluationData.csv
        ├── ulDci_decode.csv
        └── ulDci_decode.csv


After Script execution:
zip_folder/
└── 2085003052/
    ├── 0800/
    │   └── logs_20260105_143022/
    │       ├── ValidationResult.log
    │       └── fileLoadlog.json
    └── 0900/
        └── logs_20260105_152345/
            ├── ValidationResult.log
            └── fileLoadlog.json

_**Loaded Thresholds are saved with respective names**_
Example: 23605_NONREDCAP_thresholds
         25445_NONREDCAP_thresholds
This is debug to whether the thrsholds from .scf are corectly loaded or not.
is_fall back flag is set to True when defined range is not there is sssgEvaluationState
    The last row in that excel is taken as the end range
You can refer these logs in the subfolders for the script execution done.