FROM debian:stable-slim

ARG UID=1000
ARG GID=1000

ARG CONDA_VERSION="py310_23.3.1-0"
ARG CONDA_SHA256="aef279d6baea7f67940f16aad17ebe5f6aac97487c7c03466ff01f4819e5a651"
ARG CONDA_DIR="/opt/conda"

COPY root /

ENV DEBIAN_FRONTEND=noninteractive

RUN addgroup --system --gid "$GID" app && \
  adduser --system --home /home/app --uid "$UID" --gid "$GID" app && \
  chown -R app:app /home/app && \
  apt-get update && \
  apt-get install -y curl python3 git libglib2.0-0 libsm6 libxrender1 && \
  install-miniconda3 "${CONDA_VERSION}" "${CONDA_SHA256}" "${CONDA_DIR}"

USER app

ENTRYPOINT ["bash", "-ci"]
