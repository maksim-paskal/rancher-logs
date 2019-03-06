FROM debian:stretch

COPY fluent.conf /fluentd/fluent.conf
COPY Gemfile /fluentd/Gemfile

ENV PATH /fluentd/vendor/bundle/ruby/2.3.0/bin:$PATH
ENV GEM_PATH /fluentd/vendor/bundle/ruby/2.3.0
ENV GEM_HOME /fluentd/vendor/bundle/ruby/2.3.0

RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev libffi-dev" \
  && apt update \
  && apt install -y --no-install-recommends ruby2.3 ca-certificates $buildDeps \
  && gem install bundler --version 1.16.2 \
  && bundle config silence_root_warning true \
  && bundle install --gemfile=/fluentd/Gemfile --path=/fluentd/vendor/bundle \
  && SUDO_FORCE_REMOVE=yes \
  apt-get purge -y --auto-remove \
  -o APT::AutoRemove::RecommendsImportant=false \
  $buildDeps \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

CMD ["fluentd","-c","/fluentd/fluent.conf"]