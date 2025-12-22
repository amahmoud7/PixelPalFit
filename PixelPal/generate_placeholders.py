import os
import struct
import zlib

def write_png(filename, width, height, color):
    # Simple PNG writer
    # Color is (r, g, b)
    
    # Signature
    png_sig = b'\x89PNG\r\n\x1a\n'
    
    # IHDR
    ihdr_data = struct.pack('!IIBBBBB', width, height, 8, 2, 0, 0, 0)
    ihdr_crc = zlib.crc32(b'IHDR' + ihdr_data)
    ihdr = struct.pack('!I', len(ihdr_data)) + b'IHDR' + ihdr_data + struct.pack('!I', ihdr_crc)
    
    # IDAT
    # 8-bit RGB
    raw_data = b''
    for y in range(height):
        raw_data += b'\x00' # Filter type 0
        for x in range(width):
            raw_data += struct.pack('BBB', *color)
            
    compressed_data = zlib.compress(raw_data)
    idat_crc = zlib.crc32(b'IDAT' + compressed_data)
    idat = struct.pack('!I', len(compressed_data)) + b'IDAT' + compressed_data + struct.pack('!I', idat_crc)
    
    # IEND
    iend_crc = zlib.crc32(b'IEND')
    iend = struct.pack('!I', 0) + b'IEND' + struct.pack('!I', iend_crc)
    
    with open(filename, 'wb') as f:
        f.write(png_sig)
        f.write(ihdr)
        f.write(idat)
        f.write(iend)

assets_dir = '/Users/akrammahmoud/.gemini/antigravity/scratch/PixelPal/RawAssets'
os.makedirs(assets_dir, exist_ok=True)

# Vital: Green
write_png(os.path.join(assets_dir, 'vital_1.png'), 32, 32, (0, 255, 0))
write_png(os.path.join(assets_dir, 'vital_2.png'), 32, 32, (0, 200, 0))

# Neutral: Blue
write_png(os.path.join(assets_dir, 'neutral_1.png'), 32, 32, (0, 0, 255))
write_png(os.path.join(assets_dir, 'neutral_2.png'), 32, 32, (0, 0, 200))

# Low Energy: Gray
write_png(os.path.join(assets_dir, 'low_1.png'), 32, 32, (128, 128, 128))
write_png(os.path.join(assets_dir, 'low_2.png'), 32, 32, (100, 100, 100))

print("Placeholders generated.")
