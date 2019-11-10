FROM ruby:2.3.0

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git  build-essential libsqlite3-dev postgresql-server-dev-all libxml2-dev libxslt-dev ca-certificates wget

WORKDIR /root
RUN git clone https://github.com/agnanachandran/InternCompass.git
RUN gem install bundler:1.13.6
WORKDIR InternCompass
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install

RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
RUN chmod u+x nodesource_setup.sh && ./nodesource_setup.sh
RUN apt-get update && apt-get install -y nodejs
RUN nodejs -v

RUN npm install -g webpack
RUN npm install
RUN cd client && npm install
RUN apt-get install -y postgresql-9.4 postgresql-client-9.4
RUN service postgresql start && \
    su - postgres -c "psql -U postgres -d postgres -c \"UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';\"" && \
    su - postgres -c "psql -U postgres -d postgres -c \"DROP DATABASE template1;\"" && \
    su - postgres -c "psql -U postgres -d postgres -c \"CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';\"" && \
    su - postgres -c "psql -U postgres -d postgres -c \"UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';;\"" && \
    su - postgres -c "psql -U postgres -d template1 -c \"VACUUM FREEZE;\"" && \
    su - postgres -c "psql -U postgres -d postgres -c \"alter user postgres with password 'password';\""
RUN apt-get install -y vim
ENTRYPOINT tail -f /var/log/dpkg.log
#COPY ./entry.sh /entry.sh
#RUN chmod u+x /entry.sh
#ENTRYPOINT /entry.sh
