{ pkgs, ... }:
let
  # nixpkgs Frigate still has a TODO for this IR (nixpkgs#401399). Docker
  # builds it at image build; until the package ships it, fetch the same
  # FP16 conversion NixOS configs use.
  openvinoSsdlite = pkgs.runCommand "ssdlite-mobilenet-v2-openvino" { } ''
    mkdir -p $out
    cp ${
      pkgs.fetchurl {
        name = "ssdlite_mobilenet_v2_fp16.xml";
        url = "https://huggingface.co/katuni4ka/ssdlite_mobilenet_v2_fp16/resolve/0a2b9ed3ae647216fe0e6147b4560f0dd3db456a/ssdlite_mobilenet_v2_fp16.xml";
        hash = "sha256-fj4qmst8eAx1lD2pgnQMNyo3RZ15DScKmGNfOnZjFHo=";
      }
    } $out/ssdlite_mobilenet_v2_fp16.xml
    cp ${
      pkgs.fetchurl {
        name = "ssdlite_mobilenet_v2_fp16.bin";
        url = "https://huggingface.co/katuni4ka/ssdlite_mobilenet_v2_fp16/resolve/0a2b9ed3ae647216fe0e6147b4560f0dd3db456a/ssdlite_mobilenet_v2_fp16.bin";
        hash = "sha256-6a5hSZtAEUT2+jvAh4XVW9+7ircGtYyHB1WDDMBGY9M=";
      }
    } $out/ssdlite_mobilenet_v2_fp16.bin
  '';
  # Same local ONVIF user as the previous Tapo-style URL. Change if the
  # Dahua/Reolink logins differ.
  camUser = "localaccount";
  camPass = "localaccount";
  go2rtcStreams = {
    # Dahua (RTSP on :554). subtype 0 = main, 1 = sub.
    back = [
      "rtsp://${camUser}:${camPass}@peepy-owl.lan.vasylenko.uk:554/cam/realmonitor?channel=1&subtype=0"
    ];
    back_sub = [
      "rtsp://${camUser}:${camPass}@peepy-owl.lan.vasylenko.uk:554/cam/realmonitor?channel=1&subtype=1"
    ];
    # Reolink doorbell: :554 is closed, HTTP-FLV on :80 is the supported path.
    front_door = [
      "ffmpeg:http://chirpy-robin.lan.vasylenko.uk/flv?port=1935&app=bcs&stream=channel0_main.bcs&user=${camUser}&password=${camPass}#video=copy#audio=copy#audio=opus"
    ];
    front_door_sub = [
      "ffmpeg:http://chirpy-robin.lan.vasylenko.uk/flv?port=1935&app=bcs&stream=channel0_ext.bcs&user=${camUser}&password=${camPass}#video=copy"
    ];
  };
in
{
  services.frigate = {
    enable = true;
    hostname = "video.vasylenko.uk";
    vaapiDriver = "iHD";

    settings = {
      mqtt.enabled = false;

      detectors.ov = {
        type = "openvino";
        device = "GPU";
      };

      model = {
        width = 300;
        height = 300;
        input_tensor = "nhwc";
        input_pixel_format = "bgr";
        path = "${openvinoSsdlite}/ssdlite_mobilenet_v2_fp16.xml";
        labelmap_path = "${pkgs.frigate}/share/frigate/coco_91cl_bkgr.txt";
      };

      record = {
        enabled = true;
        retain = {
          days = 2;
          mode = "all";
        };
      };

      ffmpeg.hwaccel_args = "preset-vaapi";

      go2rtc.streams = go2rtcStreams;

      cameras.back = {
        ffmpeg.inputs = [
          {
            path = "rtsp://127.0.0.1:8554/back";
            input_args = "preset-rtsp-restream";
            roles = [ "record" ];
          }
          {
            path = "rtsp://127.0.0.1:8554/back_sub";
            input_args = "preset-rtsp-restream";
            roles = [ "detect" ];
          }
        ];
      };
      cameras.front_door = {
        ffmpeg.inputs = [
          {
            path = "rtsp://127.0.0.1:8554/front_door";
            input_args = "preset-rtsp-restream";
            roles = [ "record" ];
          }
          {
            path = "rtsp://127.0.0.1:8554/front_door_sub";
            input_args = "preset-rtsp-restream";
            roles = [ "detect" ];
          }
        ];
      };
    };
  };

  users.users.frigate.extraGroups = [
    "render"
    "video"
  ];

  services.nginx.virtualHosts."video.vasylenko.uk".serverAliases = [
    "snoopy-badger.lan.vasylenko.uk"
  ];

  networking.firewall.allowedTCPPorts = [ 80 ];

  services.go2rtc = {
    enable = true;
    settings = {
      streams = go2rtcStreams;
      rtsp.listen = ":8554";
      webrtc.listen = ":8555";
    };
  };
}
