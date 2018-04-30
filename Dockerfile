FROM debian:9 AS build
RUN apt-get update && apt-get install -y wget unzip openjdk-8-jre-headless ocaml-nox ocaml-native-compilers --no-install-recommends

# Based on https://tla.msr-inria.inria.fr/tlaps/content/Download/Source.html

WORKDIR /tmp
RUN wget https://tla.msr-inria.inria.fr/tlatoolbox/dist/tla.zip
RUN wget https://tla.msr-inria.inria.fr/tlaps/dist/current/tlaps-1.4.3.tar.gz
RUN tar -xzf tlaps-1.4.3.tar.gz
RUN wget http://isabelle.in.tum.de/website-Isabelle2011-1/dist/Isabelle2011-1_bundle_x86_64-linux.tar.gz
RUN tar -xzf Isabelle2011-1_bundle_x86_64-linux.tar.gz

WORKDIR /opt
RUN unzip /tmp/tla.zip

WORKDIR /tmp/tlaps-1.4.3/zenon
RUN apt-get install make
RUN ./configure && make && make install 

RUN apt-get install -y --no-install-recommends
WORKDIR /tmp/tlaps-1.4.3/tlapm
RUN ./configure && make all
RUN make install

FROM debian:9
ADD LICENSE /TLA-LICENSE
ENV CLASSPATH=/opt/tla
RUN apt-get update && apt-get install -y procps texlive-latex-base openjdk-8-jre-headless --no-install-recommends
# TLC and TLATEX:
COPY --from=build /opt/tla /opt/tla
# TLAPS stuff:
COPY --from=build /tmp/Isabelle2011-1/ /opt/Isabelle
COPY --from=build /usr/local/bin/tlapm /usr/bin/
COPY --from=build /usr/local/lib/tlaps /usr/local/lib/tlaps
COPY --from=build /usr/local/bin/zenon /usr/bin/
COPY --from=build /tmp/Isabelle2011-1/contrib/z3-3.1/x86-linux/z3 /usr/bin/
COPY --from=build /tmp/Isabelle2011-1/contrib/spass-3.7/x86-linux/bin/* /usr/bin/

RUN ln -s /opt/Isabelle/bin/* /usr/bin/
