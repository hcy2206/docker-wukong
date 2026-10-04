/* Compatibility for an amd64 Go process under qemu-user on a 16 KiB host.
 * QEMU supplies AT_PAGESZ=4096. Go uses that value for NetlinkRIB's receive
 * buffer, which truncates the host's >4 KiB link dump after creating a TUN.
 * glibc calls shared-library constructors before Go reads the initial auxv.
 * This library has no dependencies and is preloaded only into tsinvc-linux.
 */
__attribute__((constructor))
static void host_pagesize(int argc, char **argv, char **envp)
{
    (void)argc;
    (void)argv;
    while (*envp) ++envp;
    unsigned long *auxv = (unsigned long *)(envp + 1);
    for (; auxv[0]; auxv += 2) {
        if (auxv[0] == 6 && auxv[1] == 4096) { /* AT_PAGESZ */
            auxv[1] = 16384;
            return;
        }
    }
}
