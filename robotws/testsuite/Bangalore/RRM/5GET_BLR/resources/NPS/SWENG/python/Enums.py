import enum


# ===============================================================================================
# Enum classes
# ===============================================================================================
class MyEnum(enum.Enum):
    def __str__(self):
        return self.name


class HW(MyEnum):
    GNB = 1
    AP = 2


class Unit(MyEnum):
    CU = 1
    DU = 2
