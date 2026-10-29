class BitsetHelper:
    def __init__(self, bitset):
        self.bitset = bitset

    @staticmethod
    def size():
        return len(self.bitset)

    def is_set(self, pos):
        return self.bitset[pos]

    def is_one_bit_set(self):
        return any(self.bitset)
