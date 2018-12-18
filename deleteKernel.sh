#!/bin/bash

if [ "$EUID" -ne 0 ]; then #Comprobamos que sea root
	echo "Ejecutame como root prro! >:v"
	exit

else
	rpm -q kernel > kernel.txt
	lines="$(rpm -q kernel | wc -l)" #Conteo de lineas

	#Construye la ruta si hay más de un kernel a la vez
	if [ "$lines" -gt 1 ]; then
		toRun="dnf remove"

		for i in $(seq 1 $(expr $lines - 1)); do
			toMod='sed '$i!d' kernel.txt'
			kernel=$(eval $toMod)
			kernelCore=${kernel//kernel/kernel-core}
			kernelDevel=${kernel//kernel/kernel-devel}
			toRun="$toRun $kernelCore $kernelDevel "
		done

		toRun="$toRun && freshclam && grub2-mkconfig -o /boot/grub2/grub.cfg"
		eval $toRun #Ejecuta
	fi

	if [ -f "./kernel.txt" ]; then #Elimina archivo temporal tras uso
		rm kernel.txt
	fi
fi