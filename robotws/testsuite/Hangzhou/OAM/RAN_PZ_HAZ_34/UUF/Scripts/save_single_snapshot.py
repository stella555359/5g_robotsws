import sys
from taf.sbts.oam.coam.admin import admin as coam_admin

coam = coam_admin()


def save_snapshot(ip, username, password, snapshotPath, aliasName):
    coam.connect_to(bts_host=ip, username=username, password=password, name=aliasName)
    try:
        coam.get_snapshot(target_file_name=snapshotPath, timeout=2700, connection=aliasName)
    finally:
        coam.teardown(connection=aliasName)


if __name__ == "__main__":
    ip = sys.argv[1]
    username = sys.argv[2]
    password = sys.argv[3]
    snapshotPath = sys.argv[4]
    aliasName = sys.argv[5]
    print("save snapshot...")
    save_snapshot(ip, username, password, snapshotPath, aliasName)
