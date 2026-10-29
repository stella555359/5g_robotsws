# **Department`s common resources way of work** 

### Acronyms: 
**CG** - department code guards - [I_MN_RAN_RD_VRF_WRO3_TA_TL](mailto:I_MN_RAN_RD_VRF_WRO3_TA_TL@internal.nsn.com)  
**TA Guild** - department test automation guild  
**common_resource** - common resource locations which content can be reused between teams e.g. `common_cloud_resource/` 

## For Tester:
Before starting automation:
- usually, resources should be identified following **Early Automation** process _(CP1-CP3)_
- check Jira board for existing common_resource activity if applicable
- check following for already written code:
  - department common_resource [testsuite/Wroclaw/OAM/common_resources](https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Wroclaw/OAM/common_resources), [testsuite/Wroclaw/OAM/cloud_common_resources](https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Wroclaw/OAM/cloud_common_resources)
  - robot framework resource library [taf.rfrl.cbts](https://wrgitlab.int.net.nokia.com/RAN/resource-packages/taf.rfrl.cbts) - remember anyone can contribute here
  - other team's folders in department `testsuite/Wroclaw/OAM/VRF_WRO3_T0x/`
  - other departments and site's locations
- plan and propose moving any found resource to common_resource with **CG**, this also includes another team folder refactor
- if you have an idea for a new common resource or refactoring of existing one propose it to **CG**

### Refactoring:
- if common resource refactor is needed - plan and propose it to **CG**
- refactor of existing resource should be prioritized before adding similar resource
- refactor must consider existing functionality to not break other team regression
- refactor may require change other teams code, so it should be consulted with **CG** and involved teams

### Remember:
- at stage of code development periodically add your **CG** to _Merge Request_ as a reviewer 
- useful code must be copied to our department location as cannot import files from other locations, also responsibility for code maintenance must be taken 
- if you are not sure if the code is useful, consult with **CG**
- follow coding standard for adding new and refactoring existing code [https://nokia.sharepoint.com/sites/code-guards/SitePages/Test-Automation-Coding-Standard.aspx](https://nokia.sharepoint.com/sites/code-guards/SitePages/Test-Automation-Coding-Standard.aspx)
- always prepare changes history even if not present, add it to file _[Documentation]_ section or doc strings of file (it should contain author date and the changes)
  ```robot
  *** Settings ***
  Documentation  This is a test suite for testing the example library.
      ... Change history:
      ... 31.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Legacy test
      ... 08.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - changed timeout after unblock from 360 to 600 seconds
      ... 21.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-420 - robotws migration and small hotfixes
      ... 18.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-517 - Resolve Blocked BTS after failed iteration and small hotfixe`s
  ```
- always prepare variables usage in _[Documentation]_ section or doc strings of file 
  ```robot
  *** Keywords ***
  Prepare SAS Files
      [Documentation]  Description:           Prepare fresh SAS files with specific configuration.${\n}
      ...              Return:                none${\n}
      ...              Output:                {}${\n}
      ...              Author:                pawel.rokicki@nokia.com${\n}
      ...              Maintainer:            CBRS Team${\n}
      ...              Last Modification:     17-02-2022 made by karol.sadowski@nokia.com${\n}
      [Arguments]      ${alias}=default       # SAS alias: by default it will be crated in /home/ute/SASSim/default
      ...              ${port}=4433           # IP port
      ...              ${config}=None         # SASSim.conf file if not provided than default one will be created
      ...              ${version}=2.0         # SAS version 2.0 or 1.2 or 1.0 only
      ...              ${repository}=/home/ute/SASSimRepo    # dir where SAS repo is stored
  ```
- confirm any doubtful situation with your **CG** 
- **CG** will consult most of the situations with other **CGs** on **TA Guild** meetings, so his involvement is crucial 
- in case of deprecated keywords, use * DEPRECATED * tag in _[Documentation]_ to inform others about it; [https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#deprecating-keywords](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#deprecating-keywords)
  ```python
  def example_keyword(argument):
    """*DEPRECATED!!* Use keyword `Other Keyword` instead.
    This keyword does something to given ``argument`` and returns results.
    """
    return do_something(argument)
  ```
## For Code Guard:
- check code for quality
- always consider maintenance and new person enabling cost
- consult common_resource with other **CGs** 
- consider **TAF** involvement 
- raise department ticket for tracking commons  if applicable
