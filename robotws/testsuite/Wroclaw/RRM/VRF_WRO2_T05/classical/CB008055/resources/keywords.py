messages_8055_A = [
    r'"sCellToAddModList":\s?\[\s[A-Za-z0-9\s{}":,]{10,350}"physCellId":\s?200',
    r'"physCellId": 210',
    r'"physCellId": 215',
    r'"physCellId": 700'
]

messages_8055_B = [
    r'"sCellToAddModList":\s?\[\s[A-Za-z0-9\s{}":,]{10,350}"physCellId":\s?100',
    r'"physCellId": 200',
    r'"physCellId": 210',
    r'"physCellId": 215',
    r'"physCellId": 700',
    r'"UEContextModificationRequest"',
    r'"F1AP: UEContextModificationResponse"',
    r'"CUtoDURRCInformation":\s?{\s{1,70}"measConfig":',
    r'"reportConfigToAddModList"',
    r'"eventA4"'
]

messages_8055_C = [
    r'"sCellToAddModList":\s?\[\s[A-Za-z0-9\s{}":,]{10,350}"physCellId":\s?100',
    r'"physCellId": 200',
    r'"physCellId": 210',
    r'"physCellId": 215',
    r'"UEContextModificationRequest"',
    r'"F1AP: UEContextModificationResponse"',
    r'"uplinkConfigCommon":\s?{\s*"frequencyInfoUL":\s?{\s*"frequencyBandList":\s?\[\s{1,85}25',
    r'SCell Addition,\s?NR CI:\s?830898276'
]

messages_8055_D = [
    r'"reconfigurationWithSync":\s?{\n\s{1,70}"spCellConfigCommon":\s{\n\s{1,80}"physCellId":\s?100'
]

subcells_8055 = 5
