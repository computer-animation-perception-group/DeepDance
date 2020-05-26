class Node:
    def __init__(self, root=False):
        self.name = None
        self.channels = []
        self.offset = (0, 0, 0)
        self.children = []
        self._is_root = root
        self.order = ""
        self.pos_idx = []
        self.exp_idx = []
        self.rot_idx = []
        self.quat_idx = []
        self.parent = []
