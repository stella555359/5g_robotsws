*** Settings ***
Documentation
...  author:        Piotr Szlegel
...  contact:       piotr.szlegel@nokia.com
...  maintainer:    piotr.szlegel@nokia.com
...  Description:  Keyword designed to lock cells for all RMOD pluged to BBMod
...                Using keyword example:  Block BBmod Cells   ABIL AirScale Capacity
...                Keyword not tested under full rack!
...                To unlock cells in same test use Run keyword and ignore error  BBmod cells unlock


Library    taf.sbts.oam.coam.admin
Library    String


*** Variables ***

${ADMIN_ALIAS}

*** Keywords ***


Block BBmod Cells
    [Arguments]   ${Unit}
    Connect with runtime release  ${ADMIN_ALIAS}
    ${BBMOD}   coam.get_ids_for_all   BBU   connection=${ADMIN_ALIAS}
    FOR  ${BB}  IN   @{BBMOD}
        set test variable  ${BB}
        ${BBU}  string.Fetch From right  ${BB}   /
        ${BBMOD_L}  string.remove string   ${BB}    /${BBU}
        set test variable  ${BBMOD_L}
        Run Keyword And Ignore error  Check bbmod and lock cells  ${Unit}
    END
    [Teardown]      coam.Teardown  connection=${ADMIN_ALIAS}

Check bbmod and lock cells
        [Arguments]    ${Unit}
        ${param}   coam.get_parameters  ${BBMOD_L}  connection=${ADMIN_ALIAS}
        ${product}    Set variable   ${param['productName']}
        Run keyword if   '${product}'=='${Unit}'
        ...            cell maping
        Run keyword if   '${product}'=='${Unit}'
        ...            BBmod cells lock   ${cells_BB}

BBmod cells lock
    [Arguments]     ${cells_BB}
    FOR    ${cell}  IN   @{cells_BB}
        coam.lock    ${cell}
    END

Cell maping
     ${cells_BB}  coam.Get Cell Mapping By Module Id   ${BB}
    set test variable    ${cells_BB}

BBmod cells unlock
    coam.Connect_to     name=${ADMIN_ALIAS}
    FOR    ${cell}  IN   @{cells_BB}
        coam.unlock    ${cell}
    END
    [Teardown]      coam.Teardown  connection=${ADMIN_ALIAS}
