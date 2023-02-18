overload:
  enabled: true
  package: yandextank.plugins.DataUploader
  token_file: "token.txt"
phantom:
  address: {{ groups['vm'][0] }}:80
  uris:
    - /
  load_profile:
    load_type: rps
    schedule: line(500, 1000, 5m)
console:
  enabled: true
telegraf:
  enabled: false