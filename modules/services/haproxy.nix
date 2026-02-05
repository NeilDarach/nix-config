{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-haproxy =
      nixosArgs@{ pkgs, config, ... }:

      let
        update-proxy = pkgs.buildNpmPackage {
          pname = "update-proxy";
          version = "0.1.0";
          src = ./update-proxy;
          buildInputs = with pkgs; [ nodejs ];
          npmDeps = pkgs.importNpmLock { npmRoot = ./update-proxy; };
          npmConfigHook = pkgs.importNpmLock.npmConfigHook;
        };
        unauth = pkgs.writeText "unauth.html" ''
          HTTP/1.0 403 Unauthorized
          Cache-Control: no-cache
          Connection: close
          ContentType: text/html

          <html><body><h1>Access Denied</h1>
          <p>Access via HTTPS is only availble to clients with a certificate</p>
          </body></html>
        '';
        index_template = pkgs.writeText "ha-index.tmpl" ''
          HTTP/1.0 200 Found
          Cache-Control: no-cache
          Connection: close
          ContentType: text/html

          <html><body><h1>Static links</h1>
          <ul><li><a href="//arde.darach.org.uk">OpenWrt Router</a></li>
          </ul>
          <h1>Dynamically registered services</h1><ul>
          {% for service,details in services %}
          <li><a href="//{{service}}.darach.org.uk">{{service}}</a> - {{details.description}} - <a href="http://{{details.host}}:{{details.port}}">{{details.host}}:{{details.port}}</a></li>
          {% endfor %}
          </ul></body></html>
        '';
        cfg_stub = pkgs.writeText "ha-config-stub.cfg" ''
          global
          pidfile  /var/run/haproxy.pid
        '';

        haproxy_config_template = pkgs.writeText "ha-config.tmpl" ''
          global
            daemon
            maxconn 4096
            pidfile /var/run/haproxy.pid
            ssl-default-bind-options ssl-min-ver TLSv1.2

          defaults
            mode tcp
            timeout connect 5s
            timeout client 1m
            timeout server 1m
            option redispatch
            balance roundrobin

          frontend stats
            bind :1936
            mode http
            stats enable
            stats hide-version
            stats uri /

          frontend default
            bind *:80
            bind *:443 ssl crt /var/lib/acme/darach.org.uk/full.pem ca-file /tmp/darach-ca.crt verify optional crl-file /tmp/darach_crl.pem
            http-request set-header X-SSL-Client-DN %{+Q}[ssl_c_s_dn] if { ssl_c_used 1 } { ssl_c_verify 0 }
            http-request set-header X-SSL-Client-CN %{+Q}[ssl_c_s_dn(cn)] if { ssl_c_used 1 } { ssl_c_verify 0 }
            http-request set-header X-Forwarded-Proto https if { ssl_fc }
            http-request set-header X-Forwarded-Proto https unless { ssl_fc }
            http-request set-header X-Forwarded-Port %fp
            mode http
            acl ACL_Local hdr(host) -i gregor.darach.org.uk
            use_backend be_Local if ACL_Local

          {% for service,details in services %}
          {% if not details.bind %}
            acl ACL_{{service}} hdr(host) -i {{service}}.darach.org.uk
          {% endif %}
          {% endfor %}
          {% for service,details in services %}
          {% if not details.bind %}
            use_backend be_{{service}} if ACL_{{service}}
          {% endif %}
          {% endfor %}
            default_backend be_index

          {% for service,details in services %}
          {% if details.bind %}
          frontend fe_{{service}}
            bind *:{{details.bind}}
            mode {% if details.mode %}{{details.mode}}{% else %}http{% endif %}
            use_backend be_{{service}}
          {% endif %}
          {% endfor %}

          backend  be_Local
            mode http
            server Gregor gregor.darach.org.uk:81 check

          backend  be_index
            mode http
            http-request set-log-level silent
            http-request redirect code 302 location http://proxy.darach.org.uk unless { hdr(host) -i proxy.darach.org.uk }
            errorfile 503 /var/lib/haproxy/index.html

          backend be_unauth
            mode http
            http-request set-log-level silent
            errorfile 503 ${unauth}

          {% for service,details in services %}
          backend be_{{service}}
            mode {% if details.mode %}{{details.mode}}{% else %}http{% endif %}
            server {{service}} {{details.host}}:{{details.port}} check
          {% endfor %}
        '';

      in
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options = {
          local.haproxy.enable = lib.mkEnableOption "Haproxy instance to handle dynamic service hostnames";
        };
        config = lib.mkIf config.local.haproxy.enable {
          networking.firewall.allowedTCPPorts = [
            80
            1936
            443
          ];
          users.users.haproxy.extraGroups = [ "acme" ];
          services.haproxy.enable = true;
          services.haproxy.config = "";
          environment.etc."haproxy.cfg".source = lib.mkForce "/var/lib/haproxy/haproxy.cfg";
          systemd.services.haproxy-watcher = {
            description = "Restart the haproxy service when it's config file changes";
            after = [ "network.target" ];
            wantedBy = [
              "multi-user.target"
            ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pkgs.systemd}/bin/systemctl restart haproxy";
            };
          };
          systemd.paths.haproxy-watcher = {
            wantedBy = [
              "multi-user.target"
            ];
            pathConfig = {
              PathChanged = "/var/lib/haproxy";
            };
          };

          systemd.services.update-proxy = {
            description = "Update the haproxy configuration files";
            after = [ "network.target" ];
            path = [ pkgs.haproxy ];
            wantedBy = [
              "multi-user.target"
              "haproxy.service"
            ];
            environment = {
              ETCD_HOST = "192.168.4.1";
              CFG_TEMPLATE = "${haproxy_config_template}";
              INDEX_TEMPLATE = "${index_template}";
            };
            serviceConfig = {
              User = config.services.haproxy.user;
              Group = config.services.haproxy.group;
              Type = "simple";
              ExecStartPre = "${pkgs.coreutils}/bin/cp -v --no-preserve mode,ownership --force ${cfg_stub} /var/lib/haproxy/haproxy.cfg";
              ExecStart = "${update-proxy}/bin/update-proxy";
              Restart = "always";
              RuntimeDirectory = "haproxy";
              WorkingDirectory = "/var/lib/haproxy";
            };
          };
        };
      };
  };
}
