# DEV
Robot test suite for test cases used to prepare TL for execution.

## Test line requirements
No specific test line requirements.

## Test cases

### DEV__Emil_env_preparation
The purpose of this test is to prepare TL for test that requires EMIL logs.

#### Test specific Preconditions
* On eNB side:
  * None
* On gNB side:
  * None
There is no configuration check for this test.

* Owner: monika.ceglarek@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
* Step 1: Install Emil if required by user
* Step 2: Download Sack if required by user
* Step 3: Copy Sack To Windows if required by user
* Step 4: Create CSV For EMIL if required by user


#### Pass criteria
* EMIL is successfully installed
* SACK is successfully downloaded
* SACK is successfully copied to Windows
* CSV is successfully created

#### Automatic TC steps
* Step 1: Install Emil
* Step 2: Download Sack
* Step 3: Copy Sack To Windows
* Step 4: Create CSV For EMIL

#### Developer test case notes
* 'Step 1: Install Emil' requires for EMIL installation file for Linux to be located on remote Windows
  host. Remote Windows host is defined in first UE in ta_ue_config.yaml (not a problem if all remote
  hosts have the same data)
* 'Step 2: Download Sack' uses SW version that is currently installed on ENB to search for SACK
  for this SW on 'http://files.ute.nsn-rdnet.net/builds/enb/base/'. 
* 'Step 3: Copy Sack To Windows' uses current SW version installed on ENB to determine SACK directory
  name. Destination path for SACK directory on Windows needs to start from cygwin directory (cygdrive).
  Connection data for Windows remote host is taken from first UE in ta_ue_config.yaml
* 'Step 4: Create CSV For EMIL' creates CSV file with BTS name '4G_SBTS' this name is used for connecting
  to BTS with EMIL. Active profiles used: 'Full Call Scenarios'.


#### History of changes
* 23.11.2020 - https://jiradc.ext.net.nokia.com/browse/IWK-532 - Initial creation
* 22.12.2020 - https://jiradc.ext.net.nokia.com/browse/IWK-562 - Changed default values of SACK directory,
               now SACKs should be downloaded to the directory with the same name, now SACKs
               can be copied to '/opt/nokia/emil/Sacks' directory
             - https://jiradc.ext.net.nokia.com/browse/IWK-563 - Modified test so that SACKs for other
               SW versions can be downloaded and uploaded to Windows PC
* 15.09.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-715 - Modified and moved to resources
               KW 'Get SW version'
             - https://jiradc.ext.net.nokia.com/browse/IWK-716 - Removed duplicated documentation
               and moved required history notes to correct one
* 01.08.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-864 - Modified TC to work with python 3.6
* 22.08.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-884 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-982 - Moved documentation to robotws
* 18.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-991 - Fixed library imports
* 26.08.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1333 - added ${release} to Download Sack KW
* 28.02.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1433 - Replaced Run Keyword Unless with IF block 
* 05.08.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1521 - Remove the argument ${is_trunk_sw} from Get SW Version and use Get Regexp Matches to verify if the Active Version matches the branch regular expression.


### DEV__VoNR_env_preparation
The purpose of this test is to prepare TL for test 'IWK__Feature_activation__CB006797'.

#### Test specific Preconditions
* On eNB side:
  * None
* On gNB side:
  * None

* Owner: monika.ceglarek@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
* Step 1: Perform recommissioning on gNB for following parameters and verify BTS state:
  * MRBTS/NRBTS/NRCELL/actEnhancedVoNR=true
  * MRBTS/NRBTS/NRCELL/actVoNR=true
  * MRBTS/NRBTS/NRCELL/n310VoNR=n10
  * MRBTS/NRBTS/NRCELL/t310VoNR=2000ms
  * MRBTS/NRBTS/NRCELL/actGBRAdmissionControl=EnhancedVoNR
  * optional parameter if needed for current software release: MRBTS/NRBTS/NRCELL/tmpActFeat1=1
* Step 2: Download Luashark

#### Pass criteria
* Recommissioning is successfully performed on BTS, all cells are on air, no unexpected alarms
* Luashark is successfully downloaded

#### Automatic TC steps
* Step 1: Prepare gNB
* Step 2: Download Luashark

#### Developer test case notes
* 'Step 1: Prepare gNB' performs recommissioning of parameters required before test case
  'IWK__Feature_activation__CB006797' and checks BTS state. As noted by 'IWK__Feature_activation__CB006797'
  test owner in the request parameter 'tmpActFeat1' is temporary in 5G21A and will be removed
  before SW release to customer. This is the reason why it may be omitted during delta creation
  by setting 'MODIFY_TMP_ACT_FEAT1' to False. 
* 'Step 2: Download Luashark' will remove previous luashark directory using 'sudo rm -rf <dir_name>'
  please make sure that you passed correct directory name
* 'Step 2: Download Luashark' will download luashark for SW version that is currently installed
  on gNB from http://files.ute.nsn-rdnet.net/builds/enb/base/ unless 'USER_SW_VERSION' is specified.
* 'Step 2: Download Luashark' will use 'USER_LUASHARK_URL' if it is specified it still uses SW version
  either from BTS or defined by user for directory name in case there are multiple directories  with luashark
  download directory.
* If 'Step 1: Prepare gNB' is executed test collects full logs and checks all BTS states,
  if only 'Step 2: Download Luashark' test only collects ADMIN logs and does not check BTS states.
* 'COLLECT_SNAPSHOT' is applicable only if 'Step 1: Prepare gNB' is executed.
* Each step can be executed separately. Each step has variable which can toggle
  whether it is executed or not.


#### History of changes
* 01.04.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-621 - Initial creation
* 10.05.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-653 - Modified way of downloading luashark
* 15.09.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-715 - Modified and moved to resources
               KW 'Get SW version'
* 21.09.2021 - https://jiradc.ext.net.nokia.com/browse/IWK-714 - Updated TC for 'actGbrLoadRepDss' and 'tmpActFeat1'
* 22.08.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-886 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-982 - Moved documentation to robotws


### DEV__files_preparation
Purpose of this test case is to prepare files required for tests.

#### Test specific Preconditions
None

* Owner: monika.ceglarek@nokia.com
* Author: monika.ceglarek@nokia.com
* Maintainer: monika.ceglarek@nokia.com

#### Test scenario defined by owner
* Step 1: Download MCShark


#### Pass criteria
* Step 1: MCShark is correctly downloaded to destination directory

#### Automatic TC steps
* Step 1: Download MCShark

#### Developer test case notes
* For MCShark to work a correct version of Wireshark needs to be installed, please refer
  to MCShark documentation for more information. Confluence page may be useful as well:
  https://confluence.ext.net.nokia.com/display/Wireshark/MCShark#
* 'Step 1: Download MCShark' will remove previous MCShark files using regular expression:
  '.*mcshark.*' please make sure that you passed correct destination directory name
* 'Step 1: Download MCShark' will download MCShark for SW version that is currently installed
  on gNB if 'USE_GNB_SW' is True or eNB if the value is False.
* 'Step 1: Download MCShark' will search and download MCShark from URL:
  https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/
  unless 'USER_MCSHARK_URL' is specified. The file will be downloaded for either software
  version that is currently on BTS (please set 'IS_TRUNK_SW' to True in case of TRUNK
  software) or software defined in 'USER_SW_VERSION' variable.
* Since names of MCShark files have some unpredictable values (most likely wireshark version)
  to create the final URL path the text on https://artifactory-hz1.int.net.nokia.com/
  artifactory/mcshark-local/<sw_version> is read and correct file address is extracted
  using regular expression: 'href.+so\"\\>(mcshark.+\\+buster\\.so)\\<\\/a\\>'.
  This is not an issue in case of 'USER_MCSHARK_URL' since it needs to lead to file
  which should be downloaded, still the name from 'USER_MCSHARK_URL' is extracted
  for other purposes (name of downloaded file).
* Name of downloaded MCShark file in destination directory will be the same as the one
  on the site from which it was downloaded, e.g.
  mcshark-3.4-1.14.1-SBTS21B_ENB_0000_002102_000000+buster.so 
* Currently test only collects ADMIN logs and does not check BTS states.
* If more steps are added to this test case it is recommended they are possible to be executed
  separately. Each step should have variable which can toggle whether it is executed or not.


#### History of changes
* 02.02.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-783 - Initial creation
* 11.04.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-820 - Modified TC for use with TLs
               without separate gNB
* 22.08.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-885 - Moved TC to robotws
* 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/IWK-982 - Moved documentation to robotws
