from __future__ import print_function
import warnings
from taf.sbts.oam.coam.admin import admin

warnings.filterwarnings(action='ignore', module='.*paramiko.*')

try:
    try:
        api = admin()
        api.teardown_all_aliases_for_admin()
        connection = api.connect_to(bts_host='192.168.255.1')
        result = connection.get_synchronization_information()
        print("\nDetected synchronization sources:")
        for key in result['syncSourceInfo']:
            print("-", key['syncInputType'])
            if key['syncInputType'] == "1pps/ToD from external GNSS receiver":
                gps_found = True

        if gps_found:
            print("Detected following GNSS-GPS devices:")
            result = connection.get_gnsses_statuses()
            for key in result:
                print(key)
            result = connection.get_gnss_sat_status(target_fsm='primary')
            for key in result:
                for satellite in key['satellitesList']:
                    print("ID:", satellite['satelliteId'], "SIGNAL:", satellite['signalLevel'], "STATUS:",
                          satellite['status'])

                print("Dist name:", key['distName'])

                print("\n\nSky visibility:", key['skyVisibility'], "\n\n")

        api.teardown()
    except Exception as e:
        print("EXCEPTION CATCHED, TEARINGDOWN ADMIN")
        print(e)
        api.teardown()
except Exception as e:
    print("ANOTHER EXCEPTION CATCHED DURING TEARDOWN OF ADMIN")
