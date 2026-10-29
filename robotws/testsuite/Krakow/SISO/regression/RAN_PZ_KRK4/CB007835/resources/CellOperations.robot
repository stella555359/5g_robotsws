*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007835
...   author: Malgorzata Wegrzyn
...   contact: malgorzata.1.wegrzyn@nokia.com

Resource    taf/rfrl/bts/robot/gnb.robot

*** Keywords ***
Prepare Setup for Attach
    gnb_cells.Block Cell    cell_id=2015
    gnb_cells.Block Cell    cell_id=2025
    gnb_cells.Block Cell    cell_id=2035
    gnb_cells.Block Cell    cell_id=17
    gnb_cells.Block Cell    cell_id=27
    gnb_cells.Block Cell    cell_id=37
    gnb_cells.Block Cell    cell_id=41357
    gnb_cells.Block Cell    cell_id=41358
    gnb_cells.Block Cell    cell_id=41359
    gnb_cells.Block Cell    cell_id=41425
    gnb_cells.Block Cell    cell_id=41426
    gnb_cells.Block Cell    cell_id=41427
    gnb_cells.Block Cell    cell_id=41382
    gnb_cells.Block Cell    cell_id=41383
    gnb_cells.Block Cell    cell_id=41384
    gnb_cells.Block Cell    cell_id=41391
    gnb_cells.Block Cell    cell_id=41392
    gnb_cells.Block Cell    cell_id=41393
    gnb_cells.Block Cell    cell_id=1010
    gnb_cells.Block Cell    cell_id=1020
    gnb_cells.Block Cell    cell_id=1030

After Attach
    gnb_cells.Unblock Cell    cell_id=2015
    gnb_cells.Unblock Cell    cell_id=2025
    gnb_cells.Unblock Cell    cell_id=2035
    gnb_cells.Unblock Cell    cell_id=17
    gnb_cells.Unblock Cell    cell_id=27
    gnb_cells.Unblock Cell    cell_id=37
    gnb_cells.Unblock Cell    cell_id=41357
    gnb_cells.Unblock Cell    cell_id=41358
    gnb_cells.Unblock Cell    cell_id=41359
    gnb_cells.Unblock Cell    cell_id=41425
    gnb_cells.Unblock Cell    cell_id=41426
    gnb_cells.Unblock Cell    cell_id=41427
    gnb_cells.Unblock Cell    cell_id=41382
    gnb_cells.Unblock Cell    cell_id=41383
    gnb_cells.Unblock Cell    cell_id=41384
    gnb_cells.Unblock Cell    cell_id=41391
    gnb_cells.Unblock Cell    cell_id=41392
    gnb_cells.Unblock Cell    cell_id=41393
    gnb_cells.Unblock Cell    cell_id=1010
    gnb_cells.Unblock Cell    cell_id=1020
    gnb_cells.Unblock Cell    cell_id=1030
