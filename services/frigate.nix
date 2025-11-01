{ ... }:
{
  services.frigate = {
    enable = false;
    hostname = "video.vasylenko.uk";

    settings = {
      mqtt.enabled = false;

      detectors.ov = {
       type = "openvino";
       device = "AUTO";
       model.path = "/var/lib/frigate/openvino-model/ssdlite_mobilenet_v2.xml";
      };

      record = {
        enabled = true;
        retain = {
          days = 2;
          mode = "all";
        };
      };

      ffmpeg.hwaccel_args = "preset-vaapi";

      cameras."doorbell" = {
        ffmpeg.inputs = [
          {
            path = "rtsp://127.0.0.1:8554/test1";
            input_args = "preset-rtsp-restream";
            roles = [ "record" ];
          }
        ];
      };
      cameras."back" = {
        ffmpeg.inputs = [
          {
            path = "rtsp://localaccount:localaccount@172.20.65.103:554/stream1";
            roles = [
              "record"
              "detect"
            ];
          }
        ];
      };
    };
  };

  # hwdec for amdgpu
  systemd.services.frigate = {
    serviceConfig = {
      SupplementaryGroups = [
        "render"
        "video"
      ]; # for access to dev/dri/*
      AmbientCapabilities = "CAP_PERFMON";
    };
  };

  services.go2rtc = {
    enable = false;
    settings = {
      streams = {
        "test1" = [
          "rtsp://10.83.16.12/11"
        ];
      };
      rtsp.listen = ":8554";
      webrtc.listen = ":8555";
    };
  };
}
