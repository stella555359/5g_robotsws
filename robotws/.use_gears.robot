# This is a dummy file that is present only to enable usage of TAF Gears in CM.
# It should be removed right after Cloud Manager lets us specify the package in
# the CM schema without having to point to a valid file on a test repository.

*** Settings ***
Default Tags   EXPERIMENTAL_PIPELINE


*** Test Cases ***
Dummy
    Log To Console   Please let me use Gears
