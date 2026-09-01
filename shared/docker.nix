{ ... }: {
  virtualisation.docker.enable = true;
  users.users.chris.extraGroups = [
    "docker"
  ];
}
