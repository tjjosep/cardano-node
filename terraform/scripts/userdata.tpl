#cloud-config
packages:
  - awscli
cloud_final_modules:
  - [scripts-user, always]