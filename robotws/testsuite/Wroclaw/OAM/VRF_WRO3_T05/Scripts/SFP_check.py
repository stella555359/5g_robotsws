from taf.gnb.oam.coam.vdu.interface import vdu
import json

vDU_OAM = [
    "10.42.139.159",
    "10.42.139.137",
    "10.42.139.153",
    "10.42.139.138",
    "10.42.139.139",
    "10.42.139.140",
    "10.42.139.157",
    "10.42.139.135",
    "10.42.139.141",
    "10.42.139.136",
    "10.42.139.134",
    "10.42.139.133",
    "10.42.38.223",
    "10.42.139.158",
    "10.42.38.232",
    "10.42.139.162",
    "10.42.139.155",
    "10.42.139.160"
]


def main():
    vdu_instance = vdu()
    grouped_vendor_part_numbers = {}
    for address in vDU_OAM:
        try:
            connection = vdu_instance.connect_to(
                host=address,
                port=443,
                username='Nemuadmin',
                password='Nokia@123',
                secure=True,
                login_disabled=False
            )
            print(f"Connection established to {address}: {connection}")
            sfp_data = vdu_instance.get_diagnostic_info_from_sfp_connections(
                vdu_connection=connection,
                request_timeout=30
            )
            print(f"SFP Diagnostic Data for {address}:", sfp_data)
            data_file = f"data_{address}.txt"
            with open(data_file, 'w') as f:
                json.dump(sfp_data, f, indent=2)
            with open(data_file, 'r') as infile:
                data = json.load(infile)
            vendor_part_numbers = [obj['vendor_part_number'] for obj in data]
            grouped_vendor_part_numbers[address] = vendor_part_numbers
        except Exception as e:
            print(f"Failed to process {address}: {e}")
        finally:
            try:
                vdu_instance.disconnect(connection)
            except Exception as e:
                print(f"Failed to disconnect from {address}: {e}")

    with open("SFP_data_all.txt", 'w') as outfile:
        for address in vDU_OAM:
            if address in grouped_vendor_part_numbers:
                outfile.write(f"{address}:\n")
                for part_number in grouped_vendor_part_numbers[address]:
                    if part_number == "MTRQ-4S1013":
                        outfile.write("***!!!MTRQ-4S1013!!!***\n")
                    else:
                        outfile.write(f"{part_number}\n")
                outfile.write("\n")
            else:
                outfile.write(f"{address}:\n!!! CONNECTION FAILED !!!\n\n")


if __name__ == "__main__":
    main()
