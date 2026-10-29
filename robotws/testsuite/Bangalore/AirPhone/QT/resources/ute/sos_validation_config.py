# 1) AP Snapshot must exist & contain files
ZIP_SNAPSHOT_PATH = "UEAPP1/UEAPP1_snapshot.zip"

# 2) Required conf files
REQUIRED_CONF_FILES = [
    "UEAPP1/conf/iphy.xml",
    "UEAPP1/conf/swconfig.txt",
]

# 2b) TargetBD file
# Example real name: UEAPP1/conf/TargetBD_5G_AP_0004_000000_035294.xml
TARGETBD_REGEX = r'^UEAPP1/conf/TargetBD_5G_AP_[0-9]+_[0-9]+_[0-9]+\.xml$'

# 3) Required non-empty files
REQUIRED_NONEMPTY_FILES = [
    "UEAPP1/fct/startup_DEFAULT.log.xz",
    "UEAPP1/fsp1/journal_LOKIB_fsp1.txt",
    "UEAPP1/fsp1/journal_LOKIA_fsp1.txt",
]

# Accept files names that folder prefix
ALLOW_PREFIX_MATCH = True

# Accept both bases for every expected file
ACCEPT_BOTH_BASES = True
BASE_DIRS = ("UEAPP1", "UEAPP")
