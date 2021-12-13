
### cdn-layout-tool を解凍する
FROM ubuntu:20.04 as cdn-layout-tool-extractor
RUN set -ex \
    && apt-get update \
    && apt-get install -y curl unzip ca-certificates --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt
ARG CDN_LAYOUT_TOOL_VERSION=0.8.60
RUN curl -LO https://packages.jetbrains.team/maven/p/ij/intellij-shared-indexes-public/com/jetbrains/intellij/indexing/shared/cdn-layout-tool/$CDN_LAYOUT_TOOL_VERSION/cdn-layout-tool-$CDN_LAYOUT_TOOL_VERSION.zip 
RUN unzip cdn-layout-tool-$CDN_LAYOUT_TOOL_VERSION.zip -d /opt/ && mv /opt/cdn-layout-tool-$CDN_LAYOUT_TOOL_VERSION /opt/cdn-layout-tool

FROM ubuntu:20.04 as ubuntu-java-node-intellij-ja-base
ENV DEBIAN_FRONTEND=noninteractive
RUN set -ex \
    && apt-get update \
    && apt-get install -y curl \
    && apt-get install -y --no-install-recommends \
    language-pack-ja-base language-pack-ja locales \
    gnupg build-essential git apt-transport-https imagemagick \
    && locale-gen ja_JP.UTF-8 \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt
# https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/generic-linux-install.html
RUN echo "deb https://apt.corretto.aws stable main" >> /etc/apt/sources.list.d/corretto.list
RUN set -ex \
    && curl https://apt.corretto.aws/corretto.key | apt-key add -  \
    && apt-get update \
    && apt-get install -y --no-install-recommends java-11-amazon-corretto-jdk \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt

# IntelliJ IDEA Ultimateをインストール
RUN set -ex \
    && mkdir /opt/idea \ 
    && curl -L https://download.jetbrains.com/idea/ideaIU-2021.2.1.tar.gz | tar -xz -C /opt/idea --strip-components 1

# https://www.jetbrains.com/help/idea/shared-indexes.html#install-cdn-layout-tool
# cdn-layout-tool をインストール
COPY --from=cdn-layout-tool-extractor /opt/cdn-layout-tool /opt/cdn-layout-tool

# https://www.jetbrains.com/help/idea/shared-indexes.html#prepare-ide
# 共有インデックス作成のための設定
ENV TEMP /tmp/idea-indexes
RUN set -ex \
    && mkdir -p $TEMP/ide-system \
    && mkdir -p $TEMP/ide-config \
    && mkdir -p $TEMP/ide-log
RUN cp /opt/idea/bin/idea.properties $TEMP/ide.properties
RUN set -ex \
    && echo "idea.system.path=$TEMP/ide-system" >> $TEMP/ide.properties \
    && echo "idea.config.path=$TEMP/ide-config" >> $TEMP/ide.properties \
    && echo "idea.log.path=$TEMP/ide-log" >> $TEMP/ide.properties \
    && echo "idea.plugins.path=$TEMP/ide-plugin" >> $TEMP/ide.properties
ENV IDEA_PROPERTIES=$TEMP/ide.properties

# 共有インデックス作成スクリプトを追加
COPY generate-shared-indexes.sh /generate-shared-indexes.sh 

CMD ["bash", "-c", "/generate-shared-indexes.sh"]
