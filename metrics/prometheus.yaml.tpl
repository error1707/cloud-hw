global:
  scrape_interval: 15s

scrape_configs:
- job_name: node
  static_configs:
  - targets: ['{{ groups["vm"][0] }}:9100']
- job_name: app
  static_configs:
  - targets: ['{{ groups["vm"][0] }}:80']