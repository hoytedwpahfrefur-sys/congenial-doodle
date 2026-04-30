FROM kalilinux/kali-rolling

ENV PORT=7681
ENV DEBIAN_FRONTEND=noninteractive

# Base tools + Chrome deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates wget curl git \
    python3 python3-pip python3-venv \
    tini fastfetch unzip nano vim htop \
    chromium chromium-driver \
    fonts-liberation libappindicator3-1 \
    libasound2 libatk-bridge2.0-0 libatk1.0-0 \
    libcups2 libdbus-1-3 libgdk-pixbuf2.0-0 \
    libnspr4 libnss3 libx11-xcb1 libxcomposite1 \
    libxdamage1 libxrandr2 xdg-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install ttyd
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

# Install Python packages system-wide
RUN pip install --break-system-packages \
    flask selenium requests pyngrok flask-cors

# Useful aliases and fastfetch on login
RUN echo "fastfetch || true" >> /root/.bashrc && \
    echo "alias python=python3" >> /root/.bashrc && \
    echo "alias pip='pip --break-system-packages'" >> /root/.bashrc && \
    echo "export CHROMIUM_FLAGS='--no-sandbox --disable-dev-shm-usage --headless'" >> /root/.bashrc

WORKDIR /root

EXPOSE 7681

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/bash", "-lc", \
    "/usr/local/bin/ttyd --writable -i 0.0.0.0 -p ${PORT} -c ${USERNAME}:${PASSWORD} /bin/bash"]
    
