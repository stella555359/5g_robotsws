
class Maybe:
    def __init__(self, val, error=None):
        self.val = val
        self.error = error

    def __getitem__(self, idx):
        try:
            return self.val[idx]
        except IndexError:
            return self.error

    def __call__(self):
        return self.val if self.val else self.error
