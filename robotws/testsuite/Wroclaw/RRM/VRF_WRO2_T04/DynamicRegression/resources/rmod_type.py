class Rmod:
    def __init__(self, rmod_info):
        self.rmod_info = rmod_info

    @property
    def name(self):
        return self.rmod_info['productName']

    @property
    def distname(self):
        return self.rmod_info['id']

    @property
    def rmod_id(self):
        return self.distname.split('/')[-1]

    def __str__(self):
        return self.name

    def __repr__(self):
        return f'{self.name}'
