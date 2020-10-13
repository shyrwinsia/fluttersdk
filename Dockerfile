# Flutter Linux CI
# A trimmed Docker image with Flutter for CI
FROM openjdk:8

# Prep
RUN apt update -y \
  && apt install -y --no-install-recommends \
  locales \
  libstdc++6 \
  lib32stdc++6 \
  libglu1-mesa \
  build-essential \
  curl \
  && locale-gen en_US en_US.UTF-8 \
  && dpkg-reconfigure locales \
  && apt autoremove -y \
  && rm -rf /var/lib/apt/lists/*

# Android Tools
ARG ANDROID_SDK_TOOLS="commandlinetools-linux-6609375_latest.zip"
ARG ANDROID_SDK_URL="https://dl.google.com/android/repository/${ANDROID_SDK_TOOLS}"
ARG ANDROID_SDK_ARCHIVE="/tmp/android.zip"

ENV ANDROID_SDK_ROOT="/usr/local/android"

RUN mkdir -p "${ANDROID_SDK_ROOT}" \
  && curl --output "${ANDROID_SDK_ARCHIVE}" --url "${ANDROID_SDK_URL}" \
  && unzip -q -d "${ANDROID_SDK_ROOT}" "${ANDROID_SDK_ARCHIVE}" \
  && rm "${ANDROID_SDK_ARCHIVE}"

# Android SDK
ARG ANDROID_SDK_MAJOR=29
ARG ANDROID_SDK_MINOR=0
ARG ANDROID_SDK_PATCH=0
ARG ANDROID_SDK_VERSION="${ANDROID_SDK_MAJOR}.${ANDROID_SDK_MINOR}.${ANDROID_SDK_PATCH}"

RUN yes "y" | \
  ${ANDROID_SDK_ROOT}/tools/bin/sdkmanager --sdk_root="${ANDROID_SDK_ROOT}" \
  "tools" \
  "platform-tools" \
  "extras;android;m2repository" \
  "extras;google;m2repository" \
  "patcher;v4" \
  "build-tools;${ANDROID_SDK_VERSION}" \
  "platforms;android-${ANDROID_SDK_MAJOR}"

# Flutter
ARG FLUTTER_SDK_CHANNEL="stable"
ARG FLUTTER_SDK_VERSION="1.22.1"
ARG FLUTTER_SDK_URL="https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${FLUTTER_SDK_VERSION}-${FLUTTER_SDK_CHANNEL}.tar.xz"
ARG FLUTTER_SDK_ARCHIVE="/tmp/flutter.tar.xz"

ENV FLUTTER_ROOT="/usr/local/flutter"

RUN curl --output "${FLUTTER_SDK_ARCHIVE}" --url "${FLUTTER_SDK_URL}" \
  && tar --extract --file="${FLUTTER_SDK_ARCHIVE}" --directory=$(dirname ${FLUTTER_ROOT}) \
  && rm "${FLUTTER_SDK_ARCHIVE}"

RUN yes "y" | ${FLUTTER_ROOT}/bin/flutter doctor --android-licenses \
  && ${FLUTTER_ROOT}/bin/flutter doctor

# Paths
ENV DART_SDK="${FLUTTER_ROOT}/bin/cache/dart-sdk"
ENV PUB_CACHE="${FLUTTER_ROOT}/.pub-cache"
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/build-toos/${ANDROID_SDK_VERSION}"
ENV PATH="${PATH}:${FLUTTER_ROOT}/bin"
ENV PATH="${PATH}:${DART_SDK}/bin:${PUB_CACHE}/bin"
