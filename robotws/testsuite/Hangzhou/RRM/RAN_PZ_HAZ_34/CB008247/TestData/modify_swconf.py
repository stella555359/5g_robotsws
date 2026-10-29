SWCONFIG_BEAM_SWITCH = [
    '0x590104=1',
    '0x580477=1',
    '0x580264=0x1F'
]

SWCONFIG_REUSE_1 = [
    '0x590103=1',      # rdSrsCodebookAndTas,0-not reuse,1-reuse
    '0x580477=1',
    '0x580264=0x1F'
]

SWCONFIG_REUSE_0 = [
    '0x590103=0',       # rdSrsCodebookAndTas,0-false,1-true
    '0x580477=1',
    '0x580264=0x1F'
]

SWCONFIG_1UE_SPECIFIC = [
    'rdNumberOfUeCsirsSymbol=1',
    '0x580477=1',
    '0x580264=0x1F'
]

SWCONFIG_SRS_DEBUG = [
    '0x580477=1',
    '0x580264=0x1F'
]

swconfig_C007_FLAG = [
    '0x58057b=0x201',
]
