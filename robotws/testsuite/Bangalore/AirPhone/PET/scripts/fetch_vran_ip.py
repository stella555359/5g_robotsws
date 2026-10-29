import re
import sys


def extract_ipv6_addresses(file_path):
    with open(file_path, 'r') as file:
        content = file.read()

    vdu_match = re.search(
        r"_vdu_oam_http_connection_details\s*=\s*HttpConnectionDetails\(\s*addr\s*=\s*\"([a-fA-F0-9:]+)\"", content
    )
    vcu_match = re.search(
        r"_cu\s*=\s*CU\(.*?oam_http_connection_details\s*=\s*HttpConnectionDetails\(\s*addr\s*=\s*\"([a-fA-F0-9:]+)\"",
        content,
        re.DOTALL,
    )

    vdu_ip = vdu_match.group(1) if vdu_match else None
    vcu_ip = vcu_match.group(1) if vcu_match else None

    return vdu_ip, vcu_ip


def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py <input_file_path>")
        sys.exit(1)

    file_path = sys.argv[1]

    vdu_ip, vcu_ip = extract_ipv6_addresses(file_path)

    if vdu_ip:
        print(f"vDUip={vdu_ip}")
    else:
        print("Could not extract vDU IPv6 address.")

    if vcu_ip:
        print(f"vCUip={vcu_ip}")
    else:
        print("Could not extract vCU IPv6 address.")


if __name__ == "__main__":
    main()
