import string


def convert_cellidentity_to_tcpdump_filter(cellidentity):
    cellidentity_hex = hex(int(cellidentity))
    cellidentity_hex = (cellidentity_hex[2:] + '0').rjust(10, '0')
    cellidentity_filter = ':'.join(x+y for x, y in zip(cellidentity_hex[::2], cellidentity_hex[1::2]))
    return cellidentity_filter


if __name__ == "__main__":
    print("DEBUG")
