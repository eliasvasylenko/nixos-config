{
  disko.devices.disk.main = {
    # MSI Cubi N (Novatech PC-BX26240 / MS-B0A91). One NVMe: WD Blue
    # SN580 500 GB at pci 04:00.0. USB installer is sda; do not use by-id
    # (that embeds the drive serial).
    device = "/dev/nvme0n1";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          size = "512M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "fmask=0022"
              "dmask=0022"
            ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
