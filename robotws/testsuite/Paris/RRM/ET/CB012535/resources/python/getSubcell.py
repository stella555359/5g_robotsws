"""
Version    Date          Author                                Notes
0.1        2024/06/12    tony.huynh-quang@nokia.com            Creation
"""

import csv


def getSubcellCsv(csvPathName, phycells):
    """
    """
    nbcells = len(phycells)
    subcells = []

    for i in range(nbcells):
        subcells.append(255)

    for phyc in phycells:
        print('phycell=', phyc)

    ulcellSetupList = []

    with open(csvPathName) as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            ulcellSetupList.append(row)

    for msg in ulcellSetupList:
        for i in range(nbcells):
            if msg['UlCell_SetupReq_t.physCellId'] == phycells[i]:
                subcells[i] = msg['3gpp.subcellid']

    return subcells
