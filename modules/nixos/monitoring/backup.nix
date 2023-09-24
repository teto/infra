{ config, ... }:
{
  services.postgresqlBackup = {
    enable = true;
    compression = "none";
    startAt = "daily";
  };

  sops.secrets.hetzner-borgbackup-ssh = { };

  systemd.services.borgbackup-job-monitoring = {
    after = [ "postgresqlBackup.service" ];
    serviceConfig.ReadWritePaths = [
      "/var/log/telegraf"
    ];
  };

  services.borgbackup.jobs.monitoring = {
    paths = [
      "/var/backup/postgresql"
    ];
    repo = "u348918@u348918.your-storagebox.de:/./monitoring";
    encryption.mode = "none";
    compression = "auto,zstd";
    startAt = "daily";
    environment.BORG_RSH = "ssh -oPort=23 -i ${config.sops.secrets.hetzner-borgbackup-ssh.path}";
    preHook = ''
      set -x
    '';
    postHook = ''
      cat > /var/log/telegraf/borgbackup-job-monitoring.service <<EOF
      task,frequency=daily last_run=$(date +%s)i,state="$([[ $exitStatus == 0 ]] && echo ok || echo fail)"
      EOF
    '';

    prune.keep = {
      within = "1d"; # Keep all archives from the last day
      daily = 7;
      weekly = 4;
      monthly = 0;
    };
  };

}
