from taf.sbts.oam.coam.admin import admin


def set_admin_connection():
    admin.store.add(admin.store.get("REST_GNB0_DU0"), "admin")
