FROM kalilinux/kali-rolling

ENV PORT=7681
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates wget curl git \
    python3 python3-pip python3-venv \
    tini fastfetch unzip nano vim htop \
    chromium chromium-driver tmux \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
      x86_64|amd64) ttyd_asset="ttyd.x86_64" ;; \
      aarch64|arm64) ttyd_asset="ttyd.aarch64" ;; \
      *) echo "Unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    wget -qO /usr/local/bin/ttyd \
      "https://github.com/tsl0922/ttyd/releases/latest/download/${ttyd_asset}" \
    && chmod +x /usr/local/bin/ttyd

RUN pip install --break-system-packages \
    flask selenium requests flask-cors

RUN echo "fastfetch || true" >> /root/.bashrc && \
    echo "alias python=python3" >> /root/.bashrc && \
    echo "alias pip='pip --break-system-packages'" >> /root/.bashrc

WORKDIR /root

# Copy custom terminal UI
COPY terminal.html /root/index.html

EXPOSE 7681

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "-lc", \
    "/usr/local/bin/ttyd --writable -i 0.0.0.0 -p ${PORT} -c ${USERNAME}:${PASSWORD} --index /root/index.html tmux new-session -A -s main"]
