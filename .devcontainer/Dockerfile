# Sử dụng image Ubuntu có cài sẵn cấu hình cơ bản
FROM ubuntu:20.04

# Tránh bị hệ thống hỏi múi giờ gây treo khi cài đặt
ENV DEBIAN_FRONTEND=noninteractive

# Thiết lập các biến môi trường cho Flutter
ENV FLUTTER_HOME=/opt/flutter \
    PATH=$PATH:/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin

# Cài đặt các công cụ cần thiết (đã thêm wget)
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa wget \
    && rm -rf /var/lib/apt/lists/*

# Tải và cài đặt Google Chrome để hiển thị giao diện App
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update \
    && apt-get install -y ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb

# Tải và cài đặt Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME

# Phân quyền cho workspace (Đã đổi tên chuẩn theo folder của bạn)
RUN git config --global --add safe.directory /workspaces/flutter_app