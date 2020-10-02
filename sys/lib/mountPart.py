from esp32 import Partition
import uos
import uerrno

def mntPart(partName, mountName):
    try:
        stat = uos.stat(mountName)
        # if this doesn't fail, then we already have a dir
        return
    except:
        pass
    
    # Try to mount the eeprom partition

    p = Partition.findPartition.TYPE_DATA, label=partName)

    if p != []:
        # we got something, see if we can mount it

        try:
            p = p[0] # p was a list now it is not
            uos.mount(p, mountName)
            return
        except OSError as exc:
            if exc.args[0] == uerrno.ENODEV:
                try:
                    # we need to format the partition
                    uos.VfsLfs2.mkfs(p)
                    uos.mount(p, mountName)
                    return
                except:
                    pass
        
    # we can't fix this, just make a dir
    uos.mkdir(mountName)
    return

mntPart('eeprom', '/eeprom')
mntPart('user', '/user')
