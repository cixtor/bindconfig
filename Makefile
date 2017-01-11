CONFIGURATION := example.conf
BINDPATH := /usr/local/etc/bind
INSTALLATION := /usr/local/opt/bind
NAMEDCONF := /usr/local/etc/bind/named.conf
REMOTEKEYS := "http://ftp.isc.org/isc/bind9/keys/9.8/bind.keys.v9_8"
TEMPLATE := "em9uZSAiRE9NQUlOIiB7CiAgICB0eXBlIFpPTkVUWVBFOwogICAgZmlsZSAiRklMRVBBVEgiOwp9Ow=="

install:
	mkdir -pv -- ${BINDPATH}/zones

	rndc-confgen -a -c ${BINDPATH}/rndc.key
	wget -q ${REMOTEKEYS} -O ${BINDPATH}/bind.keys
	cat ${CONFIGURATION} | sed "s;BINDPATH;${BINDPATH};g" 1> ${NAMEDCONF}

	cp -- example.conf ${BINDPATH}/
	cp -- zones.rfc1918 ${BINDPATH}/
	cp -- zones/*.db ${BINDPATH}/zones/
	cp -- service.xml ${INSTALLATION}/homebrew.mxcl.bind.plist

	@for FILENAME in $$(ls -1 zones/); do \
		ZONETYPE="master"; \
		FILEPATH="zones/$${FILENAME}"; \
		DOMAIN=$$(echo "$$FILENAME" | rev | cut -c4-100 | rev); \
		if [[ "$$DOMAIN" == "root" ]]; then \
			ZONETYPE="hint"; \
			DOMAIN="."; \
		fi; \
		echo "Creating DNS zone file for: $${DOMAIN}"; \
		echo 1>> ${NAMEDCONF}; \
		echo ${TEMPLATE} \
		| base64 --decode \
		| sed "s;DOMAIN;$$DOMAIN;g" \
		| sed "s;ZONETYPE;$$ZONETYPE;g" \
		| sed "s;FILEPATH;$$FILEPATH;g" 1>> ${NAMEDCONF}; \
	done

uninstall:
	rm -rfv -- ${BINDPATH}

update:
	wget "https://www.internic.net/zones/named.cache" -O zones/root.db
