# devme

## Bash script I created to facilitate setting up websites on my dev server.

**Assumes:**
* Server has a full LAMP stack
* Server has [virtualhost](https://github.com/RoverWire/virtualhost) cli tool installed to the `PATH`.
* Server has the `create-databse.sh` script installed to the `PATH` (to be uploaded here)
* Server has a disk mounted at `/data` where sites/files will live
* Client and server both use folder structure, `example.com/(web|sql)`. eg:
* * /data/Sites/example.com/web (web root)
* * /data/Sites/example.com/sql (database backups)
* On the client, this script is executed in the `/data/Sites/example.com` directory.
* * Script assumes current working directory is the sub/domain of the site.
* * Script assumes `web/` and `sql/` subdirectories in the current working directory

**Other Notes:**
* Server is a single AWS EC2 instance
* My dev server lives at 34.236.35.23
* Sites are set up as subdomains of `dev.unhingedweb.com` (e.g. `example.dev.unhingedweb.com`)
* All remote commands are executed via SSH.
* All files live on the `/data` mount for persistant, cheap AWS storage

**Script actions**

1. Creates a virtual host on server.
2. Removes default web folder. 
* * `virtualhost` tool creates website on `/var/www`
* * I need sites be on `/data` of persistence and budget
3. Create web and sql folders on `/data`
4. Soft link web root to original `var/www` location 
5. Upload (`rsync`) files to server
6. If database backup exists on client's machine, find the newest one and upload it.
7. Create database on server by executing a `create-database.sh` script on the server.
