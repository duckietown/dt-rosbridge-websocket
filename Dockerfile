# parameters
ARG REPO_NAME="dt-rosbridge-websocket"

# arguments
ARG PORT=9001

# ==================================================>
# ==> Do not change this code
ARG ARCH=arm32v7
ARG MAJOR=devel20
ARG BASE_TAG=${MAJOR}-${ARCH}

# define base image
FROM duckietown/dt-ros-commons:${BASE_TAG}

# define repository path
ARG REPO_PATH="${CATKIN_WS_DIR}/src/${REPO_NAME}"
WORKDIR "${REPO_PATH}"

# create repo directory and copy the source code
RUN mkdir -p "${REPO_PATH}"
COPY . "${REPO_PATH}/"

# install apt dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    $(awk -F: '/^[^#]/ { print $1 }' dependencies-apt.txt | uniq) \
  && rm -rf /var/lib/apt/lists/*

# install python dependencies
RUN pip install -r ${REPO_PATH}/dependencies-py.txt

# build packages
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
  catkin build \
    --workspace ${CATKIN_WS_DIR}/
# <== Do not change this code
# <==================================================

ENV LAUNCHFILE="${REPO_PATH}/rosbridge_websocket.launch"
ENV WEBSOCKET_BRIDGE_PORT $PORT

# define command
CMD [ \
  "bash", "-c", \
    "roslaunch", \
      "--wait", \
      "${LAUNCHFILE}", \
      "port:=${WEBSOCKET_BRIDGE_PORT}" \
]

# maintainer
LABEL maintainer="Andrea F. Daniele (afdaniele@ttic.edu)"
