# Create and upload containers to gitlab registry #

User podman or docker to create the images to be uploaded.

	  podman | docker login gitlab01.brunoe.net:5050
	  podman | docker build -t gitlab01.brunoe.net:5050/ebruno/softwaretrace-ostools/rhel10rpmbuild -t rhel10rpmbuild -f rhel10/Containerfile;
	  podman | docker push gitlab01.brunoe.net:5050/ebruno/softwaretrace-ostools/rhel10rpmbuild;
	  podman | docker build -t gitlab01.brunoe.net:5050/ebruno/softwaretrace-ostools/archlinux -t archlinux -f archlinux/Dockerfile;
	  podman | docker push gitlab01.brunoe.net:5050/ebruno/softwaretrace-ostools/archlinux;
