FROM debian:9 AS build
RUN apt-get update && apt-get install -y build-essential libz-dev wget unzip openjdk-8-jre-headless ocaml-nox ocaml-native-compilers --no-install-recommends

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

# Instructions don't mention this, but you get an error about missing "ls4" and
# I found this on GitHub...
WORKDIR /tmp
RUN wget https://github.com/quickbeam123/ls4/archive/v1.0.tar.gz
RUN tar xf v1.0.tar.gz
RUN make -C ls4-1.0/core rs

# Maybe this is important too?
RUN wget http://cgi.csc.liv.ac.uk/~konev/software/trp++/translator/translate.tar.bz2
RUN tar xf translate.tar.bz2
WORKDIR /tmp/translate
RUN ./buildb.sh

# Build the "Isabelle TLA+ heap". Whatever that is. TLAPS complains if it can't find it.
WORKDIR /tmp/tlaps-1.4.3/isabelle
RUN make heap-only PATH=/tmp/Isabelle2011-1/bin:$PATH

FROM debian:9
ADD LICENSE /TLA-LICENSE
ENV CLASSPATH=/opt/tla
RUN apt-get update && apt-get install -y procps texlive-latex-base openjdk-8-jre-headless cvc3 --no-install-recommends
# TLC and TLATEX:
COPY --from=build /opt/tla /opt/tla
# TLAPS stuff:
COPY --from=build /tmp/ls4-1.0/core/ls4_static /usr/bin/ls4
COPY --from=build /tmp/translate/fotranslate.bin /usr/bin/ptl_to_trp
COPY --from=build /tmp/Isabelle2011-1/ /opt/Isabelle
COPY --from=build /usr/local/bin/tlapm /usr/bin/
COPY --from=build /usr/local/lib/tlaps /usr/local/lib/tlaps
COPY --from=build /usr/local/bin/zenon /usr/bin/
COPY --from=build /tmp/Isabelle2011-1/contrib/z3-3.1/x86-linux/z3 /usr/bin/
COPY --from=build /tmp/Isabelle2011-1/contrib/spass-3.7/x86-linux/bin/* /usr/bin/
ADD tlc /usr/bin/
COPY --from=build /root/.isabelle/Isabelle2011-1/heaps/polyml-5.4.0_x86_64-linux/TLA+ /opt/Isabelle/heaps/polyml-5.4.0_x86_64-linux/

RUN ln -s /opt/Isabelle/bin/* /usr/bin/
