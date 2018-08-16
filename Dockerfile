FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN echo 'LC_ALL="en_US.UTF-8"' > /etc/default/locale
# greatly speeds up nokogiri install
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES 1
# dependencies for nokogiri gem
RUN apt-get install -y libxml2 libxml2-dev libxslt1-dev
# eugh, workaround...
RUN gem install nokogiri
RUN bundle install
COPY . /myapp 
