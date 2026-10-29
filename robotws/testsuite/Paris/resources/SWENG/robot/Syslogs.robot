*** Settings ***
Documentation
...             == Purpose ==
...             Library to manage SYSLOG, meaning to start/stop generation, then to parse logs and perform some evaluations/statistics.
...
...             == Description ==
...             *Concepts:*
...
...             A SYSLOG session is a sequence of SYSLOG Start and SYSLOG STOP, where we start logging ENB traces in a file.
...             Each trace is timestamped. Then, we are able to compute rate A of traces, and raise an error if this rate is too high.
...             An exclusion file is a CSV file, in which first column is a comment and second one is a pattern of trace to exclude.
...             Exclusion file can be either in SWENG or in a feature.
...             In both case, they should be in <scope>/config/syslog/exclusion path.
...             For instance : resources/SWENG/config/syslog/exclusion/Platform.csv
...                 or : RRM/ET/5GC001527/config/syslog/exclusion/Global.csv
...             Also, Exclusion files may have some include directives. Syntax is as follow:
...             include <scope>.<filename>.
...             Example : include SWENG.Platform.csv
...                 or  : include 5GC001527.MySpecifics.csv
...
...
...             *Evaluation:*
...
...             While parsing generated syslog file, followings are done:
...              - counting of all traces.
...              - exclusion of traces matching one of patterns from specified exclusion files.
...              - detection and counting of ERROR (ERR) or WARNING (WRN).
...              - computing distribution of all found traces (number of occurences in file).
...              - computing of rate of traces, raising an error in case this rate is higher than a particular threshold.
...              - display of synthesis, errors...
...              - generation of a statistic file, sorting from higher to lower distribution of all pattern of traces found.
...
...             See in 5GC001527, KPI.robot for an example.
...
...             *Scope:*
...
...             For the moment, syslog for vRAN 2.0 is not explicitely supported.

Resource            Connect.robot
Library            ../python/Syslogs.py

*** Keywords ***
SYSLOG Start
    [Documentation]                 Launch a session of SYSLOG generation on ENB.
    ...                             argument ${host} is the target host on which syslog will be launched, then collected
    ...                             argument ${name} is a string to tag the syslog file name with.
    ...                             Returned value is a reference on a Syslog object (kind of syslog manager)
    [Arguments]                     ${host}                                 ${name}
    ${alias}                        SSH Connect                             ${host}
    ${syslog}                       Syslogs.newSyslog
    ...                                 path=${LOG_PATH}
    ...                                 name=${name}
    ...                                 alias=${alias}
    [Return]                        ${syslog}


SYSLOG Stop
    [Documentation]                 Stop a session of SYSLOG generation, then store logs in a file.
    ...                             Path is : ${LOG_PATH}/SYSLOG/SYSLOG.<HostALias>.<Name>.log.
    ...                             Expected argument is a reference on a syslog (previously created thanks to SYSLOG Start KW)
    [Arguments]                     ${syslog}
    ${syslogPath}                   call method
    ...                             ${syslog}                               stop
    [Return]                        ${syslogPath}


SYSLOG Evaluate
    [Documentation]                 Parse a logs from a syslog session previously executed thru SYSLOG Start/Stop.
    ...                             Argument ${syslog} is a reference on a syslog session.
    ...                             Argument ${exclusion} is the specification of a exclusion file.
    ...                             Argument ${maxRate} is the maximum rate of traces per seconds that is allowed.
    ...                             Once this threshold is reached, an ERROR will also be logged in this same SYSLOG file.
    [Arguments]                     ${syslog}
    ...                             ${exclusion}
    ...                             ${maxRate}=400
    ...                             ${nolimit}=${false}
    ${return}                       call method
    ...                             ${syslog}                               evaluate
    ...                             exclusion=${exclusion}
    ...                             maxRate=${maxRate}
    ...                             nolimit=${nolimit}
    [Return]                        ${return}
