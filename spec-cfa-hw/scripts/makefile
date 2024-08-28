default :

install-clean :
	rm -rf ./verif-tools/verilog2smv-1.1.2 ./verif-tools/verilog2smv.sh	

install :
	python3 setup.py

app:
	sh build/run "application" true
	
geiger:
	sh build/run "geiger" true

gps: 
	sh build/run "gps" true
	
mouse: 
	sh build/run "mouse" true
	
syringe_pump:
	sh build/run "syringe_pump" true
	
temperature_sensor:
	sh build/run "temperature_sensor" true
	
ultrasonic_sensor:
	sh build/run "ultrasonic_sensor" true
	
verify:
	sh verif-tools/run

verify-verbose:
	sh verif-tools/run --verbose	

clean :
	rm -rf simv *.mem pmem.inc stimulus.v tmp-build ../logs/*.cflog
