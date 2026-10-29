*** Settings ***
Documentation
...   Keywords with robot utilities used across 5GC000955-B testing
...
...   author: kasper.biegun@nokia.com
...   maintainer: kasper.biegun@nokia.com


*** Keywords ***
Setup keywords override for 5GC000955-B
    [Documentation]   Sets library search order to allow keywords override for 5GC000955-B testing
    Set Library Search Order   \
    ...   override_keywords
    ...   resources_5GC000955-A-a
