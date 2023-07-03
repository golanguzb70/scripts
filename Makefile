CURRENT_DIR=$(shell pwd)

do-ls:
	ls ${CURRENT_DIR}

# Ubuntu server
install-docker:
	bash ${CURRENT_DIR}/ubuntu-server/install-docker.sh