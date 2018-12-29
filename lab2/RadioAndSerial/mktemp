COMPONENT=RadioAndSerialAppC
PFLAGS+=-DCC2420_DEF_CHANNEL=9
BUILD_EXTRA_DEPS += RadioAndSerial.class
CLEAN_EXTRA = *.class RadioAndSerialMsg.java

CFLAGS += -I$(TOSDIR)/lib/T2Hack

RadioAndSerial.class: $(wildcard *.java) RadioAndSerialMsg.java
	javac -target 1.4 -source 1.4 *.java

RadioAndSerialMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=RadioAndSerialMsg RadioAndSerial.h test_serial_msg -o $@


include $(MAKERULES)