{ lib, ... }:

{
  disko.devices.disk.main = {
    # Wyse 3040 onboard eMMC. These boxes have two SDHCI hosts: PCI mmc0
    # fails to init, ACPI mmc1 is the chip. Other 3040s should look the
    # same; do not use by-id (that embeds the card serial).
    device = "/dev/mmcblk1";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          size = "256M";
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
