# Configuring Runner Support #

## Setup gitlab-runner for RHEL and Fedora ##

Make sure cockpit in installed.

	sudo dnf -y cockpit
	systemctl enable --now cockpit.socket

Cockpit runs on localhost:9090
If this is a headless system expose port 9090 to the appropriate  subnets.

	sudo firewall-cmd --add-service=cockpit --permanent
	sudo firewall-cmd --reload

**Only install podman or docker-ce not both.**

### Setup gitlab-runner to use podman ###
Install podman before gitlab-runner.

 * RHEL10 | Fedora Server 42 | Fedora Workstation 42
	   sudo dnf -y install podman podman-docker cockpit-podman

### Setup gitlab-runner to use docker ###
Install docker before gitlab-runner

[Installing Docker CE](https://docs.docker.com/engine/install/)

### Installing gitlab-runner  ###

Instructions may change so it is best to validate the current instructions.

[Installing Gitlab Runner doc](https://docs.gitlab.com/runner/install/)

As of Sept 2025

	curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
	sudo dnf -y install gitlab-runner

Validate the gitlab-runner user and group id's
On Fedora Server 42 for example:

	grep gitlab-runner /etc/passwd
	gitlab-runner:x:991:990:GitLab Runner:/home/gitlab-runner:/bin/bash

On RHEL 10 Workstation for example:

	grep gitlab-runner /etc/passwd
	gitlab-runner:x:975:973:GitLab Runner:/home/gitlab-runner:/bin/bash

On RHEL10 and Fedora the service is enabled and started as part of the package
installation process.

Validate the location of configuration file.

	sudo gitlab-runner list
	Runtime platform                                    arch=amd64 os=linux pid=8716 revision=139a0ac0 version=18.4.0
	Listing configured runners                          ConfigFile=/etc/gitlab-runner/config.toml

Register a shell runner to validate installation.

	sudo gitlab-runner register  --url https://<your gitlab instance>  --token <your token>

	sudo gitlab-runner list
	Runtime platform                                    arch=amd64 os=linux pid=8766 revision=139a0ac0 version=18.4.0
	Listing configured runners                          ConfigFile=/etc/gitlab-runner/config.toml
	fedorda42                                           Executor=shell Token=<your gitlab token> URL=https://<your gitlab server>


### Configuring gitlab-runner to use podman ###

Once gitlab-runner is installed you need to do some some addition podman setup.
Make sure you have the following line in your sudoers file:

 <your user name> ALL=(ALL)  NOPASSWD: ALL
 or
 <your user name> ALL=(gitlab-runner)  NOPASSWD: ALL

	sudo systemctl --machine=gitlab-runner@.host --user --now enable podman.socket
	sudo systemctl --machine=gitlab-runner@.host status --user podman.socket

	  * podman.socket - Podman API Socket
	   Loaded: loaded (/usr/lib/systemd/user/podman.socket; enabled; preset: disabled)
	   Active: active (listening) since Mon 2025-09-08 15:40:05 PDT; 6h left
	 Invocation: 09a020fc81e24207bac806dc84bec9a1
	 Triggers: * podman.service
		 Docs: man:podman-system-service(1)
	   Listen: /run/user/975/podman/podman.sock (Stream) # This goes in the config.toml file.
	   CGroup: /user.slice/user-975.slice/user@975.service/app.slice/podman.socket

	loginctl enable-linger gitlab-runner # Replace 'gitlab-runner' with your runner user if different


### Sample config.tmpl ###

On RHEL 10 this located in /etc/gitlab-runner
Items to note 975 is gitlab-runner uid.
Add a docker runner to you configuration
Add this to the config.toml file.


	 [[runners]]
	   name = "rhel10podman"
	   url = "<your gitlab server>"
	   id = 38
	   token = "<a runner token>"
	   token_obtained_at = 2025-09-06T21:05:05Z
	   token_expires_at = 0001-01-01T00:00:00Z
	   executor = "docker"
	   [runners.cache]
		 MaxUploadedArchiveSize = 0
		 [runners.cache.s3]
		 [runners.cache.gcs]
		 [runners.cache.azure]
	   [runners.docker]
		 host = "unix:///run/user/975/podman/podman.sock"
		 tls_verify = false
		 image = "docker.io/library/redhat/ubi10:latest"
		 privileged = false
		 disable_entrypoint_overwrite = false
		 oom_kill_disable = false
		 pull_policy = ["if-not-present"]
		 disable_cache = false
		 volumes = ["/var/cache/gitlab-runner/cache:/cache", "/run/user/975/podman/podman.sock:/var/run/podman/podman.sock"]
		 network_mode = "bridge"
		 shm_size = 0
		 network_mtu = 0

Restart the gitlab-runner service.

	 sudo systemctl restart gitlab-runner

Check the status of the service you many need to increase:

  * concurrency in the global section.
  * request_concurrency for the each runner

Verify the runners.

	  sudo gitlab-runner list
	  Runtime platform                                    arch=amd64 os=linux pid=7344 revision=5a021a1c version=18.3.1
	  Listing configured runners                          ConfigFile=/etc/gitlab-runner/config.toml
	  rhel10server                                        Executor=shell Token=<a token> URL=https://gitlab01.brunoe.net
	  rhel10podman                                        Executor=docker Token=<a token> URL=https://gitlab01.brunoe.net



Sample complete config.toml with shell runner and podman runner

	 concurrent = 3
	 check_interval = 0
	 connection_max_age = "15m0s"
	 shutdown_timeout = 0

	 [session_server]
	   session_timeout = 1800

	 [[runners]]
	   name = "rhel10server"
	   url = <your gitlab server url>"
	   id = 31
	   token = "<a runner token>"
	   token_obtained_at = 2025-09-02T21:59:17Z
	   token_expires_at = 0001-01-01T00:00:00Z
	   executor = "shell"
	   request_concurrency = 2
	   [runners.cache]
		 MaxUploadedArchiveSize = 0
		 [runners.cache.s3]
		 [runners.cache.gcs]
		 [runners.cache.azure]

	 [[runners]]
	   name = "rhel10podman"
	   url = <your gitlab server url>"
	   id = 38 # this will need to changed to match your environment.
	   token = "<a runner token"
	   token_obtained_at = 2025-09-06T21:05:05Z
	   token_expires_at = 0001-01-01T00:00:00Z
	   executor = "docker"
	   request_concurrency = 2
	   [runners.cache]
		 MaxUploadedArchiveSize = 0
		 [runners.cache.s3]
		 [runners.cache.gcs]
		 [runners.cache.azure]
	   [runners.docker]
		 host = "unix:///run/user/975/podman/podman.sock"
		 tls_verify = false
		 image = "docker.io/library/redhat/ubi10:latest"
		 privileged = false
		 disable_entrypoint_overwrite = false
		 oom_kill_disable = false
		 pull_policy = ["if-not-present"]
		 disable_cache = false
		 volumes = ["/var/cache/gitlab-runner/cache:/cache", "/run/user/975/podman/podman.sock:/var/run/podman/podman.sock"]
		 network_mode = "bridge"
		 shm_size = 0
		 network_mtu = 0

## Create and upload build containers to gitlab registry ##

	  podman | docker login gitlab01.brunoe.net:5050
	  podman | docker build -t gitlab01.brunoe.net:5050/ebruno/softwaretrace-ostools/rhel10rpmbuild -t rhel10rpmbuild -f rhel10/Containerfile;
	  podman | docker push gitlab01.brunoe.net:5050/ebruno/softwaretrace-ostools/rhel10rpmbuild;
	  podman | docker build -t gitlab01.brunoe.net:5050/ebruno/softwaretrace-ostools/archlinux -t archlinux -f archlinux/Dockerfile;
	  podman | docker push gitlab01.brunoe.net:5050/ebruno/softwaretrace-ostools/archlinux;

## Setup github runner ##

Github allows you to use runners in your own environment.

To install a gitlab runner for each os see [Self-hosted runners](https://docs.github.com/en/actions/concepts/runners/self-hosted-runners)

Sample installation (allows verify instuctions from the web site).

Create github-runner account.
sudo useradd -m -U github-runner
Create a passwd so you can login to account.
su - gitlab-runner

mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.328.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.328.0/actions-runner-linux-x64-2.328.0.tar.gz
echo "01066fad3a2893e63e6ca880ae3a1fad5bf9329d60e77ee15f2b97c148c3cd4e  actions-runner-linux-x64-2.328.0.tar.gz" | shasum -a 256 -c
tar xzf ./actions-runner-linux-x64-2.328.0.tar.gz
./config.sh --url https://github.com/ebruno/softwaretrace-ostools --token <your github token>

To install as a service:

	sudo ./svc.sh install
	sudo ./svc.sh start

	/etc/systemd/system/actions.runner.ebruno-softwaretrace-ostools.fedora42.service
● actions.runner.ebruno-softwaretrace-ostools.fedora42.service - GitHub Actions Runner (ebruno-softwaretrace-ostools.fedora42)
	 Loaded: loaded (/etc/systemd/system/actions.runner.ebruno-softwaretrace-ostools.fedora42.service; enabled; preset: disabled)
	Drop-In: /usr/lib/systemd/system/service.d
			 └─10-timeout-abort.conf
	 Active: active (running) since Sat 2025-09-20 17:30:16 PDT; 252ms ago
 Invocation: f83c38eb833243f3994a2c6b85d1964a
   Main PID: 11452
	  Tasks: 1 (limit: 4588)
	 Memory: 928K (peak: 1.1M)
		CPU: 9ms
	 CGroup: /system.slice/actions.runner.ebruno-softwaretrace-ostools.fedora42.service
or

	./run.sh

# Use this yaml in your workflow for each job

runs-on: self-hosted

Or other tags assocated with runner in this example Linux, X64 and fedora42.
