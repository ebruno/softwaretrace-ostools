# Setup up container support with gitlab-runner #

Make sure cockpit in installed.

	sudo dnf -y cockpit

Cockpit runs on localhost:9090

**Only install podman or docker-ce not both.**

## Setup gitlab-runner to use podman ##
Install podman before gitlab-runner.
 * RHEL10
	 sudo dnf -y install podman cockpit-podman



## Setup gitlab-runner to use docker ##
Install docker before gitlab-runner

[Installing Docker CE](https://docs.docker.com/engine/install/)

## Installing gitlab-runner ##

[Installing Gitlab Runner doc](https://docs.gitlab.com/runner/install/)

Once gitlab-runner is installed you need to do some some addition podman setup.

	sudo -u gitlab-runner systemctl --user --now enable podman.socket
	sudo -u gitlab-runner systemctl --user --now start podman.socket
	loginctl enable-linger gitlab-runner # Replace 'gitlab-runner' with your runner user if different
	sudo -u gitlab-runner systemctl status --user podman.socket

	  * podman.socket - Podman API Socket
	   Loaded: loaded (/usr/lib/systemd/user/podman.socket; enabled; preset: disabled)
	   Active: active (listening) since Mon 2025-09-08 15:40:05 PDT; 6h left
	 Invocation: 09a020fc81e24207bac806dc84bec9a1
	 Triggers: * podman.service
		 Docs: man:podman-system-service(1)
	   Listen: /run/user/975/podman/podman.sock (Stream) # This goes in the config.toml file.
	   CGroup: /user.slice/user-975.slice/user@975.service/app.slice/podman.socket


## Sample config.tmpl ##

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

Verify the runners.

	  sudo gitlab-runner list
	  Runtime platform                                    arch=amd64 os=linux pid=7344 revision=5a021a1c version=18.3.1
	  Listing configured runners                          ConfigFile=/etc/gitlab-runner/config.toml
	  rhel10server                                        Executor=shell Token=<a token> URL=https://gitlab01.brunoe.net
	  rhel10podman                                        Executor=docker Token=<a token> URL=https://gitlab01.brunoe.net



Sample complete config.toml with shell runner and podman runner

	 concurrent = 1
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
	   [runners.cache]
		 MaxUploadedArchiveSize = 0
		 [runners.cache.s3]
		 [runners.cache.gcs]
		 [runners.cache.azure]

	 [[runners]]
	   name = "rhel10podman"
	   url = <your gitlab server url>"
	   id = 38
	   token = "<a runner token"
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

## Create and upload build containers to gitlab registry ##

Change URL to match your gitlab repo.

	  export GITHUB_URL="gitlab01.brunoe.net:5050/ebruno";
	  podman | docker login "${GITHUB_URL}"
	  podman | docker build -t ${GITHUB_URL}/softwaretrace-ostools/rhel10rpmbuild -t rhel10rpmbuild -f rhel10/Containerfile .;
	  podman | docker push ${GITHUB_URL}/softwaretrace-ostools/rhel10rpmbuild;
	  podman | docker build -t ${GITHUB_URL}/softwaretrace-ostools/archlinux -t archlinux -f archlinux/Dockerfile .;
	  podman | docker push ${GITHUB_URL}/softwaretrace-ostools/archlinux;

## Create and upload containers to github container registry ##

Change URL to match your github repo.

	  # set CR_PAT to your Container Repo Personal Access Token
	  export GITHUB_URL="ghcr.io/ebruno"
	  echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
	  docker build -t ${GITHUB_URL}/softwaretrace-ostools/archlinux:latest -t archlinux -f archlinux/Dockerfile .;
	  docker push ${GITHUB_URL}/softwaretrace-ostools/archlinux:latest;
