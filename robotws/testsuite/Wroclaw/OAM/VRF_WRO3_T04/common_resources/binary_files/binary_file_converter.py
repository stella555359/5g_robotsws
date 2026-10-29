import binascii
import os


def convert_to_hex_string(file_name, output_directory):
    with open(file_name, 'rb') as f:
        content = f.read()
        hex_ascii = binascii.hexlify(content)
        hex_string = hex_ascii.decode('ascii')

    hex_string_file_name = os.path.splitext(os.path.basename(file_name))[0] + '_hex_string.txt'
    print(os.path.join(output_directory, hex_string_file_name))

    with open(os.path.join(output_directory, hex_string_file_name), 'w') as f:
        f.write(hex_string)


def generate_binary_file(hex_string_file_name, binary_file_name):
    with open(hex_string_file_name, 'r') as f:
        hex_string = f.read()

    binary_data = binascii.unhexlify(hex_string)

    with open(binary_file_name, 'wb') as f:
        f.write(binary_data)


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Convert binary file to hex-string text file.')
    parser.add_argument('file', help='binary filename path')
    parser.add_argument('-o', '--output', help='output hex-string file path', default=os.curdir)
    args = parser.parse_args()

    output_hex_string_file_path = args.output
    binary_file_path = args.file

    convert_to_hex_string(binary_file_path, output_hex_string_file_path)
