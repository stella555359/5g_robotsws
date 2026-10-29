*** Settings ***

Documentation     Keywords related to Airphone, specifically by accessing AP Airscale modules


Library     taf.transport.ssh           WITH NAME    ssh

Resource    connect.robot


*** Keywords ***

Get Number Of MPlaneOnly Cells
    [Documentation]
    ...    Airphone as a feature/workaround to limit the support of a cell to OAM only.
    ...    Those cells will not support a real cell setup.
    ...
    ...    With this KW we fetch the number of those 'MPlaneOnly' cells from the iphy.xml file.
    ...    So if we have to check the successful cell setup for all cells we can ignore cells without
    ...    full AP support.
    ...
    ...    *Returns*   number of MPlaneOnly=true tags found in iphy.xml of the Airphone
    ...
    ${ap_alias}    connect.Connect To Airphone Common Unit
    ${nbr_of_mplaneonly_cells}   ssh.Execute
                                 ...   command=grep -i MPlaneOnly.true /rom/simmode/iphy.xml | wc -l | tr -d '\r\n'
                                 ...   connection=${ap_alias}
                                 ...   timeout=30s

    RETURN   ${nbr_of_mplaneonly_cells}
