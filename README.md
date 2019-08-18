# Compiler
Project of the Compiler of a simple declarative language.
Additionally Project contains a simulation of a Processor of a Assembly code.

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	Author:
		Wojciech Karol Rafałowski
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	Description:
	
	Project was written at C++ language. More of that it uses Bison and Flex tools. To be possible to run this project at device with UNIX system,
	you have to install proper libraries by commands:
		-	apt-get install g++;
		-	apt-get install bison;
		-	apt-get install flex.
	
	
	Main project is in the src/compiler directory and contains:
		-	parser.y		-	parser of a compiler. Uses Bison library. Besides contains main() function of a project and most of the methods.
		-	lexer.l			-	lexer analyzer of a compiler. Uses Flex library.
		-	README			-	this document.
		-	Instruction.hh	-	file with tokens to analyze by grammar.
		-	Makefile
	
	
	To compile the project you should run command: "make". After that commands from "Makefile" will start. Files like "parser.cc", "parser.hh", "compiler" etc. would be created.
	To run executable file "compiler", you should use a "./compiler [input] [output]" command, where:
		[input] 	-	path to the input file;
		[output] 	-	path to the file of output of machine code to register machine.
	
	An attempt of running another way will cause errors.
	
	
  After creating a file with machine code you can run it in register machine.
  It is a simulator of that, how processor works. This machine runs Assembly-like code.
  To run it, go to the src/register_machine catalog. Run "make" command and then: "register-machine [input]".
  It will execute code specified at [input] file.
  
  
