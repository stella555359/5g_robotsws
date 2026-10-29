from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

STREAM_INFO = {
    "11.800": {"StreamPrefix": "21A", "GoldenSCF": "/21A/GoldenSCF_6Cell_v24.xml"},
    "SBTS00_ENB_9999": {
        "StreamPrefix": "SBTS",
        "GoldenSCF": "/Trunk/GoldenSCF_6Cell.xml",
    },
}

# For test case TC.54_General_SiSo_Automatic_factory_RFSW_update
TCCB005845_TC54 = {'target_old_version': 'SBTS00_ENB_9999_210710_000012'}
