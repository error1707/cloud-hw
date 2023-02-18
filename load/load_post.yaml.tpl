overload:
  enabled: true
  package: yandextank.plugins.DataUploader
  token_file: "token.txt"
phantom:
  address: {{ groups['vm'][0] }}:80
  ammofile: "ammofile.txt"
  ammo_type: phantom
  load_profile:
    load_type: rps
    schedule: step(0.25, 2, 0.25, 50)
console:
  enabled: true
telegraf:
  enabled: false