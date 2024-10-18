{
  system.activationScripts.createPersist = "mkdir -p /persist";
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [ "/etc/nixos" "/etc/NetworkManager" "/var/lib/bluetooth" ];

  };
    files = [ "/etc/machine-id" ];
}
