{ config, lib, pkgs, hostName, ... }:

{
  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        # enable flow offloading for better throughput
        #flowtable f {
        #  hook ingress priority 0;
        #  devices = { ppp0, lan };
        #}

        chain output {
          type filter hook output priority 0; policy accept;
        }

        chain input {
          type filter hook input priority 0; policy drop;

          tcp dport { 80, 443 } ct state new,established accept # Open HTTP(S) ports

          iifname "lan" accept comment "Allow trusted networks to access the router"

          iifname "ppp0" ct state { established, related } counter accept comment "Allow returning traffic from ppp0"
          iifname "ppp0" icmp type { echo-request, destination-unreachable, time-exceeded } counter accept comment "Allow select ICMP"
          iifname "ppp0" counter drop comment "Drop all other unsolicited traffic from wan"

          iifname "lo" accept comment "Accept everything from loopback interface"
        }

        chain forward {
          type filter hook forward priority 0; policy drop;

          iifname "ppp0" tcp flags syn tcp option maxseg size set rt mtu comment "MSS Clamping"
          oifname "ppp0" tcp flags syn tcp option maxseg size set rt mtu comment "MSS Clamping"

          #ip protocol { tcp, udp } flow offload @f comment "Enable flow offloading for better throughput"

          iifname "lan" oifname "ppp0" accept comment "Allow trusted LAN to WAN"
          iifname "ppp0" oifname "lan" ct state { established, related } accept comment "Allow established back to LANs"
        }
      }

      table ip nat {
        chain postrouting {
          type nat hook postrouting priority filter; policy accept;
          oifname "ppp0" masquerade comment "Setup NAT masquerading on the ppp0 interface"
        }
      }
    '';
  };
}