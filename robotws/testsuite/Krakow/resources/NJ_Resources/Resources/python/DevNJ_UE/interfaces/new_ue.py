from .common_ue import BasicUe


class NewUe(BasicUe):
    def attach_ue(self):
        print("this is NewUe attach function")

    def detach_ue(self):
        print("this is NewUe detach function")
