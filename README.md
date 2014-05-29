docker-s3-backup
================

A Docker container to act as a Jenkins slave, capable of backing up volumes and MySQL databases to Amazon S3.

Make sure to mount volumes appropriately so that the container has access to them, and specify the SSH user by passing the ADMIN_USER and USER_PASSWORD environment parameters:

```
docker run -d -P \
    -v /folder/on/host:/folder/in/container:ro \
    -e "ADMIN_USER=myadminuser" \
    -e "USER_PASSWORD=myadminpassword"
    bprodoehl/s3-backup

```
