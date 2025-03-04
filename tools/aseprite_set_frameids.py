#!/usr/bin/env python3

import struct

class AsepriteUnknownChunk(object):
    def __init__(self):
        self.type = 0
        self.data = b''

class AsepriteFrame(object):
    def __init__(self):
        self.duration = 0
        self.unused = 0
        self.chunks = []

class AsepriteFile(object):
    def __init__(self):
        self.width = 0
        self.height = 0
        self.color_depth = 0 # 32=RGBA, 16=Gray, 8=Indexed
        self.flags = 0
        self.deprecated_speed = 0
        self.unused_1 = 0
        self.unused_2 = 0
        self.palette_transparent_index = 0
        self.unused_3 = 0
        self.unused_4 = 0
        self.unused_5 = 0
        self.num_colors = 0
        self.pixel_width = 0
        self.pixel_height = 0
        self.grid_x = 0
        self.grid_y = 0
        self.grid_width = 0
        self.grid_height = 0
        self.frames = []
    
    @classmethod
    def load(cls, f):
        header = f.read(128)

        ase = cls()

        (filesize,
        magic,
        num_frames,
        ase.width,
        ase.height,
        ase.color_depth,
        ase.flags,
        ase.deprecated_speed,
        ase.unused_1,
        ase.unused_2,
        ase.palette_transparent_index,
        ase.unused_3,
        ase.unused_4,
        ase.unused_5,
        ase.num_colors,
        ase.pixel_width,
        ase.pixel_height,
        ase.grid_x,
        ase.grid_y,
        ase.grid_width,
        ase.grid_height) = struct.unpack('<IHHHHHIHIIBBBBHBBhhHH', header[0:44])
        
        if magic != 0xA5E0:
            raise RuntimeError("Aseprite magic number did not match - this isn't an ASE file")
        
        ase.frames = []
        for i in range(num_frames):
            frame = AsepriteFrame()
            
            frame_header = f.read(16)
            num_chunks = struct.unpack('<I', frame_header[12:16])[0]
            if num_chunks == 0:
                num_chunks = struct.unpack('<H', frame_header[6:8])[0]
            frame.duration = struct.unpack('<H', frame_header[8:10])[0]
            frame.unused = struct.unpack('<H', frame_header[10:12])[0]
            frame.chunks = []
            
            for j in range(num_chunks):
                chunk_size, chunk_type = struct.unpack('<IH', f.read(6))
                chunk_data = f.read(chunk_size - 6)
                
                if chunk_type == 0x2004: # Layer chunk
                    pass
                elif chunk_type == 0x2005: # Cel chunk
                    pass
                elif chunk_type == 0x2020: # User Data chunk
                    pass
                else:
                    chunk = AsepriteUnknownChunk()
                    chunk.type = chunk_type
                    chunk.data = chunk_data
                frame.chunks.append(chunk)
            
            ase.frames.append(frame)
        
        return ase
    
    @staticmethod
    def dumps():
        return b''


with open("../../void/asset_sources/mantis.ase", "rb") as f:
    ase = AsepriteFile.load(f)
