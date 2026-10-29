import os

DOWNLOAD_PATH = '/home/ute/Downloads/'
ROTTA_PATH = '/home/ute/rotta/bilewicz/SKYWATCH_RUNS'
SKYWATCH_PATH = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG_PATH = os.path.join(SKYWATCH_PATH, 'config_65')
IPHY_CONFIG_FILE_NAME = os.path.join(CONFIG_PATH, 'iphy_skywatch.xml')
SCF_FILEPATH = os.path.join(CONFIG_PATH, 'UTE_129_skywatch.xml')
RESET_CMD = 'reset'

MANDATORY_KPIS_26R3 = 3181
ADDITIONAL_KPIS_26R3 = 3183
ADDITIONAL_COUNTERS_26R3 = 3097
