"""
author: Dawid Chuchnowski, dawid.chuchnowski@nokia.com
maintainer: Dawid Chuchnowski, dawid.chuchnowski@nokia.com
"""

from taf.sbts.oam.coam.admin import admin


def reset_bts():
    """Connects to BTS, performs site reset and teardowns connection"""
    coam_admin = admin()
    try:
        coam_admin.setup_admin()
        coam_admin.reset_site()
        return 0
    finally:
        coam_admin.teardown_admin()


if __name__ == "__main__":
    exit(reset_bts())
