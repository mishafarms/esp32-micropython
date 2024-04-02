from esp32 import Partition
import uos
import uerrno

def mntPart(part_name, mount_name):
    try:
        _ = uos.stat(mount_name)
        # if this doesn't fail, then we already have a dir
        return
    except Exception as _:
        pass
    
    # Try to find the partition by name

    p = Partition.find(Partition.TYPE_DATA, label=part_name)

    if p:
        # we got a partition, see if we can mount it

        try:
            p = p[0]  # p was a list now it is not
            uos.mount(p, mount_name)
            return
        except OSError as exc:
            if exc.args[0] == uerrno.ENODEV:
                try:
                    # we need to format the partition
                    uos.VfsLfs2.mkfs(p)
                    uos.mount(p, mount_name)
                    return
                except Exeception as _:
                    pass
        
    # we can't fix this, just make a dir
    uos.mkdir(mount_name)
    return


# mntPart('eeprom', '/eeprom')
mntPart('user', '/user')
