import re


def update_tshark_plugin_lua_file():
    replacements = [
        (r"tree_arr\[1\]:add\(f_hdr_enb_id,\s*enb_id\)",
         r"tree_arr[1]:add(f_hdr_enb_id, buffer(offset, 2):uint(enb_id))"),
        (r"tree_arr\[1\]:add\(f_hdr_cell_id,\s*cell_id\)",
         r"tree_arr[1]:add(f_hdr_cell_id, buffer(offset + 2, 2):uint(cell_id))")
    ]
    file_path = '/home/ute/.local/lib/wireshark/plugins/packet_iphy.lua'

    try:
        with open(file_path, 'r') as file:
            content = file.read()

        for pattern, replacement in replacements:
            content = re.sub(pattern, replacement, content)

        with open(file_path, 'w') as file:
            file.write(content)

        print(f"Replacements completed successfully in file: {file_path}")

    except FileNotFoundError:
        print(f"File not found: {file_path}")
    except Exception as e:
        print(f"An error occurred: {e}")
