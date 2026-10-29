*** Settings ***
Documentation    This is a testsuite with which we test changes to agent_taf
...              in Cloud Manager

*** Test Cases ***
Dummy
    ${path}=    Evaluate    pprint.pformat(sys.path)
    ...    modules=sys,pprint
    ${env}=     Evaluate    pprint.pformat(dict(sorted(os.environ.items())))
    ...    modules=os,pprint
    ${rf}=      Evaluate    robot.__version__
    ...    modules=robot
    ${py}=      Evaluate    sys.version
    ...    modules=sys
    Log    ${path}
    Log    ${env}
    Log    RF: ${rf}
    Log    Python: ${py}
