#
#
#

SHELL = /bin/sh

RSP_SRC = $(wildcard raw/aes/kat/*.rsp)  $(wildcard raw/sha2/shavs/*/*.rsp)

TARGET_DIR = xml/testvectors
XML_TARGETS = $(patsubst raw/%.rsp,$(TARGET_DIR)/%.xml, $(RSP_SRC))

XML_VALIDATE_TARGETS = $(addsuffix _VALIDATE,$(XML_TARGETS))
SCHEMA_DIR=xml/schema
SCHEMAS=$(wildcard $(SCHEMA_DIR)/*.xsd)

.PHONY: all clean validate

all: $(XML_TARGETS)
	echo $^

validate: $(XML_VALIDATE_TARGETS)


$(TARGET_DIR)/aes/%.xml: raw/aes/%.rsp convert_aes_to_xml.sh
	@mkdir -p $$(dirname $@)
	bash ./convert_aes_to_xml.sh $< $@

$(TARGET_DIR)/sha2/%Msg.xml: raw/sha2/%Msg.rsp convert_sha_kat_to_xml.sh
	@mkdir -p $$(dirname $@)
	bash ./convert_sha_kat_to_xml.sh $< $@

$(TARGET_DIR)/sha2/%Monte.xml: raw/sha2/%Monte.rsp convert_sha_monte_to_xml.sh
	@mkdir -p $$(dirname $@)
	bash ./convert_sha_monte_to_xml.sh $< $@

$(TARGET_DIR)/%.xml_VALIDATE: $(TARGET_DIR)/%.xml $(SCHEMAS)
	@xmllint --noout --schema xml/schema/test-vectors.xsd $<

clean:
	rm -f $(XML_TARGETS)