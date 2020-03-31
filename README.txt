README.txt This file is contained in the PB-supplied zip archive <reproduce_IBES_results_in_BB2019.zip>,
	as is the tar file <reproduce_IBES_results_in_BB2019.tar>. The zip archive contains a 3rd file,
	which is <Ball+Brown[PBFJ,2019]_annotated.pdf> (explained in the NB below).

How to...
1.	create your (Linux O/S) directory, eg using the Linux command: mkdir my_reproduce_BB2019
2.	move to the newly created directory, using the Linux command: cd my_reproduce_BB2019
3.	copy the PB-supplied zip archive file into this directory ("how to" depends on where the zip archive is currently)
4.	extract the 3 files from the zip archive: unzip reproduce_IBES_results_in_BB2019.zip
5.	extract files from the tar file: tar -xvf reproduce_IBES_results_in_BB2019.tar --exclude ./Country_Results/*
6.	launch the command file: nohup ./commands_IBES_2020.cmd > ./commands_messages.txt &

NB: the file <Ball+Brown[PBFJ,2019]_annotated.pdf> notes some minor differences between BB2019 T5 and T5 generated
by this package. A comment is also added to T3 to explain why some country-level totals differ in T3 v. T5.
