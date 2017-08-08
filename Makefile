#
#
#

SHELL = /bin/sh

RSP_SRC = $(wildcard raw/aes/kat/*.rsp)  $(wildcard raw/sha2/shavs/*/*.rsp)

TARGET_DIR = xml/testvectors
XML_TARGETS = $(patsubst raw/%.rsp,$(TARGET_DIR)/%.xml, $(RSP_SRC))

XML_VALIDATE_TARGETS = $(addsuffix _VALIDATE,$(XML_TARGETS))

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

$(TARGET_DIR)/aes/%.xml_VALIDATE: $(TARGET_DIR)/aes/%.xml xml/schema/block-cipher_kat.xsd
	@xmllint --noout --schema xml/schema/block-cipher_kat.xsd $<

$(TARGET_DIR)/sha2/%Msg.xml_VALIDATE: $(TARGET_DIR)/sha2/%Msg.xml xml/schema/hash-function_kat.xsd
	@xmllint --noout --schema xml/schema/hash-function_kat.xsd $<

$(TARGET_DIR)/sha2/%Monte.xml_VALIDATE: $(TARGET_DIR)/sha2/%Monte.xml xml/schema/hash-function_monte.xsd
	@xmllint --noout --schema xml/schema/hash-function_monte.xsd $<

clean:
	rm -f $(XML_TARGETS)