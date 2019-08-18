/*
 * Parser interpretera języka imperatywnego do projektu z JFTT2018
 *
 * Autor: Wojciech Rafałowski
 * 236616
 * 2018-12-20
*/
%{
	#define YYSTYPE std::string
	#include <iostream>
	#include <fstream>
	#include <tuple>
	#include <vector>
	#include <map>
	#include <unordered_map>
	#include <stdexcept>
	#include <stdio.h>
	#include <math.h>
	#include <string.h>
	#include <string>
	#include <algorithm>
	#include "instructions.hh"
	
	using namespace std;
	
	// IMPORTANT FIELDS
	
	map< string, tuple<long long, 	bool> > 			*declaredVar = new map< string, tuple<long long, bool> >;
		//name	memory
	map< string, long long > 								*declared_var_for = new map< string, long long >;
	
	map< string, tuple<long long, long long, long long, bool*> > 	*declaredArr = new map< string, tuple<long long, long long, long long, bool*> >;
		//name			a			b			a_add	init*?
		//	name(a:b);			-	declaration
	
	
	
	map< long long, tuple< string,	bool, 	string, map<long long, tuple<long long, string, string>>* >  > *data_map =  new map< long long, tuple< string,	bool, 	string, map<long long, tuple<long long, string, string>>* >  >;
	//	key,		 name,		init,	reg_value, 		commands
	
	
	
	unordered_map<string, string> *registered_registers = new unordered_map<string, string>;
	
	map<long long, map<long long, tuple<long long, string, string>>* >* coms_help_to_initialize_header_of_loop = new map<long long, map<long long, tuple<long long, string, string>>* >;
	
	
	// ASSISTANT  VARIABLES
	long long memory = 0;
	long long freeRegister = 0;
	bool settingVariable = false;
	bool declaringVariables = false;
	
	long long index_of_current = -1;
	string name_of_current = "";
	
	long long id_index = -1;
	string id_name = "";

	string commands_in_for = "";
	long long number_of_block = 0;
	
	// IMPORTANT METHODS
	void make_array				(string name, string a, string b);
	void make_variable			(string message);
	
	void erase_variable (string name);
	void erase_variable_last_FOR (string name);
	
	
	// COMMANDS to MR
	map< long long, tuple<long long, string, string> >*   addition_MR			( string reg1, string reg2 );
	map< long long, tuple<long long, string, string> >*   subtration_MR			( string reg1, string reg2 );
	map< long long, tuple<long long, string, string> >*   division_MR			( string reg1, string reg2 );
	map< long long, tuple<long long, string, string> >*   modulation_MR			( string reg1, string reg2 );
	map< long long, tuple<long long, string, string> >*   multiplication_MR		( string key1,  string key2);
	
	
	map< long long, tuple<long long, string, string> >*   negate_MR 			( string reg1, string reg2 );					//ASSISTANT
	
	map< long long, tuple<long long, string, string> >*   is_equal_MR 			( string reg1, string reg2 );
	map< long long, tuple<long long, string, string> >*   is_not_equal_MR 		( string reg1, string reg2 );
	map< long long, tuple<long long, string, string> >*   is_smaller_MR 		( string reg1, string reg2 );
	map< long long, tuple<long long, string, string> >*   is_greater_MR 		( string reg1, string reg2 );
	map< long long, tuple<long long, string, string> >*   is_smaller_or_equal_MR( string reg1, string reg2 );
	map< long long, tuple<long long, string, string> >*   is_greater_or_equal_MR( string reg1, string reg2 );
	map< long long, tuple<long long, string, string> >*   is_smaller_or_equal_with_registers_MR ( string reg1,  string reg2);
	map< long long, tuple<long long, string, string> >*   is_greater_or_equal_with_registers_MR ( string reg1,  string reg2);
	
	
	map< long long, tuple<long long, string, string> >*	  make_number_log_MR    ( long long number, string reg_res				);
	map< long long, tuple<long long, string, string> >*	  make_number_log_MR    ( long long number, string r_res, string r_help	);
	map< long long, tuple<long long, string, string> >*   load_memory_arr_var_MR( string arrName, string var, string reg_A		);
	
	
	map< long long, tuple<long long, string, string> >*   load_arr_var_MR 		( string arrName, string var, string reg		);
	map< long long, tuple<long long, string, string> >*   load_arr_num_MR 		( long long idx, string reg		);
	map< long long, tuple<long long, string, string> >*   load_MR 				( string varName, string reg					);
	map< long long, tuple<long long, string, string> >*   load_MR 				( string varName, string reg, string reg_help	);
	map< long long, tuple<long long, string, string> >*   copy_MR 				( string varName, string reg					);
	map< long long, tuple<long long, string, string> >*   store_MR 				( string reg									);
	map< long long, tuple<long long, string, string> >*	  jzero_MR      		( string reg, long long val						);
	map< long long, tuple<long long, string, string> >*	  jump_MR      			( long long val									);
	map< long long, tuple<long long, string, string> >*   halt_MR      			();
	map< long long, tuple<long long, string, string> >*	  get_MR      			( string reg 					);
	map< long long, tuple<long long, string, string> >*	  put_MR      			( string reg 					);
	map< long long, tuple<long long, string, string> >*	  dec_MR      			( string reg 					);
	map< long long, tuple<long long, string, string> >*   inc_MR      			( string reg 					);
	map< long long, tuple<long long, string, string> >*   dec_from_memory_MR    ( string name 					);
	map< long long, tuple<long long, string, string> >*   inc_from_memory_MR    ( string name 					);
	// ASSISTANT FUNCTIONS
	
	map< long long, tuple<long long, string, string> >*   make_variable_last_FOR 			( string name, string key_1		);
	map< long long, tuple<long long, string, string> >*   make_variable_last_FOR_DOWNTO	    ( string name, string key_1		);
	map< long long, tuple<long long, string, string> >*   load_variable_last_FOR 			( string name, string reg_val	);
	
	
	map<long long, tuple<long long, string, string>>* get_help_commands_to_initialize_header_of_loop (long long mem);
	
	void put_help_commands_to_FOR_TO 		(string name, string key_1, string key_2);
	void put_help_commands_to_FOR_DOWNTO 	(string name, string key_1, string key_2);
	
	
	void set_initialized(string name, long long idx);
	bool exists_array (string name);										// CONTAINABLE
	bool exists_variable (string name);
	bool contains_variable_or_array (string var);
	string parseCommand (long long com);
	
	
	long long get_commands_size (string key_str);
	map<long long, tuple<long long, string, string>>* get_commands (string key_str);
	bool is_initialized (string key_str);
	string get_name (string key_str);
	string get_reg (string key_str);
	
	
	string 	get_from_register_manager ();
	void	register_register (string key, string reg);
	string	release_register (string reg, string com);
	bool 	contains_register (string reg);
	
	void put( map<long long, tuple<long long, string, string> >* list, long long com, string par1, string par2 );
	
	
	string	put_data_map 	( string name, bool initialized, string reg, map<long long, tuple<long long, string, string>> *commands);
	
	void concat_commands ( map< long long, tuple<long long, string, string> >* target_map, map< long long, tuple<long long, string, string> >* commands );
	
	long long my_stoi (string var, string com);
	
	long long key_of_commands;
	
	// CALLED in MAIN()
	void myError(string message);
	extern long long yylineno;
	long long yylex( void );
	void yyset_in( FILE * in_str );
	void yyset_out( FILE * out_str );
	
	void run_parser( FILE * in_str, FILE * out_str );
	void yyerror( const char* s);
%}

%token ';'
%token ':' '=' '>' '<' '!'
%token '-' '+'
%token '*' '/'
%token '%'
%token '('
%token ')'
%token num
%token ERROR
%token DECLARE IN END IF THEN ELSE ENDIF WHILE DO ENDWHILE ENDDO FOR FROM TO ENDFOR DOWNTO READ WRITE
%token pidentifier

%%

program      : DECLARE { declaringVariables = true;} declarations { declaringVariables = false;} IN commands END {
					
					key_of_commands = my_stoi($6, "171");
			}
;


declarations : declarations pidentifier';' {
					
					if ( contains_variable_or_array($2) ) 
						myError("ERROR! Variable already declared: " + $2);
					else
						make_variable($2);
	   		}


             | declarations pidentifier '(' num ':' num ')' ';'             {
					
					if ( contains_variable_or_array($2) )
						myError("ERROR! Variable already declared: " + $2);
					else {
							if (my_stoi($4, "191") > my_stoi($6, "191"))
								myError("ERROR! Incorrect Array indexes: " + $2);
							else
								make_array($2, $4, $6);
					}
              }
			  
             | %empty
;


commands     : commands command {
					
					concat_commands( get_commands($1), get_commands($2) );
					$$ = $1;
			 }
             | command						{
					$$ = $1;
			 }
;

command      :  { settingVariable = true; }  identifier   {
																settingVariable = false;  
																if (id_name == commands_in_for) myError("ERROR! Iterator cannot be assigned: " + id_name); 
																name_of_current = id_name; 
																index_of_current = id_index;
																
															}   ':' '=' expression';'    {
						
						map<long long, tuple<long long, string, string>>* coms_store_1  = copy_MR("A", get_reg ($2));
						map<long long, tuple<long long, string, string>>* coms_store_2  = store_MR(get_reg ($6));
						map<long long, tuple<long long, string, string>>* coms2 = get_commands ($2);
						map<long long, tuple<long long, string, string>>* coms6 = get_commands ($6);
						
						concat_commands( coms2, coms6 );
						concat_commands( coms2, coms_store_1 );
						concat_commands( coms2, coms_store_2 );
						
						release_register(get_reg($2), "222");
						release_register(get_reg($6), "223");
						$$ = $2;
						set_initialized(name_of_current, index_of_current);
			}


             | IF condition THEN commands ELSE commands ENDIF  {
					
					string reg = get_reg($2);
					
					map<long long, tuple<long long, string, string>>* coms_cond  = get_commands($2);
					map<long long, tuple<long long, string, string>>* coms_1  = get_commands($4);
					map<long long, tuple<long long, string, string>>* coms_2  = get_commands($6);
					
					long long size_1 = get_commands_size($4);
					long long size_2 = get_commands_size($6);
					
					map<long long, tuple<long long, string, string>>* jump_small = jzero_MR (reg, 2);
					map<long long, tuple<long long, string, string>>* jump_big_1 = jump_MR (size_1 + 2);
					map<long long, tuple<long long, string, string>>* jump_big_2 = jump_MR (size_2 + 1);
					
					concat_commands(coms_cond, jump_small);
					concat_commands(coms_cond, jump_big_1);
					concat_commands(coms_cond, coms_1);
					concat_commands(coms_cond, jump_big_2);
					concat_commands(coms_cond, coms_2);
					
					release_register(get_reg($2), "253");
					release_register(get_reg($4), "254");
					release_register(get_reg($6), "255");
					$$ = $2;
			 }
			 
			 
			 
             | IF condition THEN commands ENDIF  {
					
					string reg = get_reg($2);
					
					map<long long, tuple<long long, string, string>>* coms_cond	= get_commands($2);
					map<long long, tuple<long long, string, string>>* coms_1  	= get_commands($4);
					
					long long size = get_commands_size($4);
					
					map<long long, tuple<long long, string, string>>* jump_small = jzero_MR (reg, 2);
					map<long long, tuple<long long, string, string>>* jump_big = jump_MR (size+1);
					
					concat_commands(coms_cond, jump_small);
					concat_commands(coms_cond, jump_big);
					concat_commands(coms_cond, coms_1);
					
					release_register(get_reg($2), "276");
					release_register(get_reg($4), "277");
					$$ = $2;
			 }
			 
			 
             | WHILE condition DO { release_register(get_reg($2), "303"); } commands ENDWHILE  {
					
					string reg = get_reg($2);
					
					map<long long, tuple<long long, string, string>>* coms_cond	= get_commands($2);
					map<long long, tuple<long long, string, string>>* coms  	= get_commands($5);
					
					long long size_cond = get_commands_size($2);
					long long size_coms = get_commands_size($5);
					
					map<long long, tuple<long long, string, string>>* jump_small = jzero_MR (reg, 2);
					map<long long, tuple<long long, string, string>>* jump_big = jump_MR (size_coms + 2);
					map<long long, tuple<long long, string, string>>* jump_minus_big = jump_MR ((-1)*(size_coms + size_cond + 2));
					
					concat_commands(coms_cond, jump_small);
					concat_commands(coms_cond, jump_big);
					concat_commands(coms_cond, coms);
					concat_commands(coms_cond, jump_minus_big);
					
					release_register(get_reg($5), "302");
					$$ = $2;
					
					number_of_block--;
			 }
			 
			 
             | DO { number_of_block++; } commands WHILE condition ENDDO  {
					
					string reg = get_reg($3);
					
					map<long long, tuple<long long, string, string>>* coms  	= get_commands($3);
					map<long long, tuple<long long, string, string>>* coms_cond	= get_commands($5);
					
					long long size_coms = get_commands_size($3);
					long long size_cond = get_commands_size($5);
					
					map<long long, tuple<long long, string, string>>* jump_minus_big = jzero_MR (reg, (-1)*(size_coms + size_cond));
					
					concat_commands(coms, coms_cond);
					concat_commands(coms, jump_minus_big);
					
					release_register(get_reg($3), "322");
					release_register(get_reg($5), "323");
					$$ = $3;
					
					number_of_block-=2;
			 }
			 
             | FOR pidentifier FROM value TO value DO { put_help_commands_to_FOR_TO($2, $4, $6); } commands ENDFOR {
//					$2				$4			$6													$9
								
								map<long long, tuple<long long, string, string>>* coms2 = get_help_commands_to_initialize_header_of_loop( get<0>( declaredVar->find($2)->second ) );
								
								string reg_first = get_from_register_manager();
								register_register(reg_first, "");
								map<long long, tuple<long long, string, string>>* coms_load_first  = load_MR ($2, reg_first );
								
								string reg_last  = get_from_register_manager();
								register_register(reg_last, "");
								map<long long, tuple<long long, string, string>>* coms_load_last   = load_variable_last_FOR ($2, reg_last);
								
								map<long long, tuple<long long, string, string>>* comparison = is_smaller_or_equal_with_registers_MR(reg_first, reg_last );
								
								
								map<long long, tuple<long long, string, string>>* jump_small = jzero_MR ( reg_first, 2 );
								
								map<long long, tuple<long long, string, string>>* coms9 = get_commands ($9);
								
								map<long long, tuple<long long, string, string>>* inc_first = inc_from_memory_MR ( $2 );
								
								map<long long, tuple<long long, string, string>>* jump_big = jump_MR  ( coms9->size() + inc_first->size() + 2 );
								
								map<long long, tuple<long long, string, string>>* jump_minus_big = jump_MR ( (-1)*(inc_first->size() + coms9->size() + 2 + comparison->size() + coms_load_first->size() + coms_load_last->size()) );
								
								
								concat_commands( coms2, coms_load_first );
								concat_commands( coms2, coms_load_last );
								concat_commands( coms2, comparison );
								concat_commands( coms2, jump_small );
								concat_commands( coms2, jump_big );
								concat_commands( coms2, coms9 );
								concat_commands( coms2, inc_first );
								concat_commands( coms2, jump_minus_big );
								
								erase_variable ($2);
								erase_variable_last_FOR($2);
								
								$$ = put_data_map ( $2, true, "", coms2 );
								
								commands_in_for = "";
								
								number_of_block--;
			 }
			 
			 
			 
             | FOR pidentifier FROM value DOWNTO value DO { put_help_commands_to_FOR_DOWNTO($2, $4, $6); } commands ENDFOR {
//					$2				$4			$6															$9
					
								map<long long, tuple<long long, string, string>>* coms2 = get_help_commands_to_initialize_header_of_loop( get<0>( declaredVar->find($2)->second ) );
								
								string reg_first = get_from_register_manager();
								register_register(reg_first, "");
								map<long long, tuple<long long, string, string>>* coms_load_first  = load_MR ($2, reg_first );
								
								string reg_last  = get_from_register_manager();
								register_register(reg_last, "");
								map<long long, tuple<long long, string, string>>* coms_load_last   = load_variable_last_FOR ($2, reg_last);
								
								map<long long, tuple<long long, string, string>>* comparison = is_greater_or_equal_with_registers_MR(reg_first, reg_last );
								
								
								map<long long, tuple<long long, string, string>>* jump_small = jzero_MR ( reg_first, 2 );
								
								map<long long, tuple<long long, string, string>>* coms9 = get_commands ($9);
								
								map<long long, tuple<long long, string, string>>* dec_first = dec_from_memory_MR ( $2 );
								
								map<long long, tuple<long long, string, string>>* jump_big = jump_MR  ( coms9->size() + dec_first->size() + 2 );
								
								map<long long, tuple<long long, string, string>>* jump_minus_big = jump_MR ( (-1)*(dec_first->size() + coms9->size() + 2 + comparison->size() + coms_load_first->size() + coms_load_last->size()) );
								
								
								concat_commands( coms2, coms_load_first );
								concat_commands( coms2, coms_load_last );
								concat_commands( coms2, comparison );
								concat_commands( coms2, jump_small );
								concat_commands( coms2, jump_big );
								concat_commands( coms2, dec_first );
								concat_commands( coms2, coms9 );
								concat_commands( coms2, jump_minus_big );
								
								erase_variable ($2);
								erase_variable_last_FOR($2);
								
								$$ = put_data_map ( $2, true, "", coms2 );
								
								commands_in_for = "";
								
								number_of_block--;
			 }
             
			 
			 
			 |  { settingVariable = true; }  READ  identifier';' {
					
					settingVariable = false;
					if (id_name == commands_in_for)
						myError("ERROR! Iterator cannot be assigned: " + id_name);
					
					string reg = get_reg($3);
					map<long long, tuple<long long, string, string>>* coms = copy_MR( "A", reg );
					concat_commands(coms, get_MR(reg) );
					concat_commands(coms, store_MR(reg) );
					
					concat_commands(get_commands($3), coms );
					release_register(reg, "467");
					
					set_initialized(id_name, id_index);
					$$ = $3;
			 }
			 
			 
             | WRITE value';'  {
						
						map<long long, tuple<long long, string, string>>* coms = put_MR( get_reg($2) );
						map<long long, tuple<long long, string, string>>* coms2 = get_commands($2);
						
						concat_commands( coms2, coms );
						$$ = $2;
			 }
;

expression   : value {
				$$ = $1;
			}
			
             | value '+' value 		{
				 
						map<long long, tuple<long long, string, string>>* coms1 = get_commands($1);
						map<long long, tuple<long long, string, string>>* coms3 = get_commands($3);
						concat_commands(coms1, coms3);
						map<long long, tuple<long long, string, string>>* coms2 = addition_MR($1, $3);
						concat_commands(coms1, coms2);
				$$ = $1;
			}
			
             | value '-' value		{
				 
						map<long long, tuple<long long, string, string>>* coms1 = get_commands($1);
						map<long long, tuple<long long, string, string>>* coms3 = get_commands($3);
						concat_commands(coms1, coms3);
						map<long long, tuple<long long, string, string>>* coms2 = subtration_MR($1, $3);
						concat_commands(coms1, coms2);
				$$ = $1;
			}
			
             | value '*' value		{
				 
						map<long long, tuple<long long, string, string>>* coms1 = get_commands($1);
						map<long long, tuple<long long, string, string>>* coms3 = get_commands($3);
						concat_commands(coms1, coms3);
						map<long long, tuple<long long, string, string>>* coms2 = multiplication_MR($1, $3);
						concat_commands(coms1, coms2);
				$$ = $1;
			}
			
             | value '/' value		{
				 
						map<long long, tuple<long long, string, string>>* coms1 = get_commands($1);
						map<long long, tuple<long long, string, string>>* coms3 = get_commands($3);
						concat_commands(coms1, coms3);
						map<long long, tuple<long long, string, string>>* coms2 = division_MR($1, $3);
						concat_commands(coms1, coms2);
				$$ = $1;
			}
			
             | value '%' value		{
				 
						map<long long, tuple<long long, string, string>>* coms1 = get_commands($1);
						map<long long, tuple<long long, string, string>>* coms3 = get_commands($3);
						concat_commands(coms1, coms3);
						map<long long, tuple<long long, string, string>>* coms2 = modulation_MR($1, $3);
						concat_commands(coms1, coms2);
				$$ = $1;
			}
;

													// 	0	:	TRUE
													// 	1	:	FALSE
condition    : value '=' value			{
	
						map<long long, tuple<long long, string, string>>* coms1 = get_commands($1);
						map<long long, tuple<long long, string, string>>* coms3 = get_commands($3);
						concat_commands(coms1, coms3);
						map<long long, tuple<long long, string, string>>* coms2 = is_equal_MR($1, $3);
						concat_commands(coms1, coms2);
				$$ = $1;
				number_of_block++;
			}
             | value '!' '=' value		{
				 
						map<long long, tuple<long long, string, string>>* coms1 = get_commands($1);
						map<long long, tuple<long long, string, string>>* coms4 = get_commands($4);
						concat_commands(coms1, coms4);
						map<long long, tuple<long long, string, string>>* coms2 = is_not_equal_MR($1, $4);
						concat_commands(coms1, coms2);
				$$ = $1;
				number_of_block++;
			}
             | value '<' value			{
				 
						map<long long, tuple<long long, string, string>>* coms1 = get_commands($1);
						map<long long, tuple<long long, string, string>>* coms3 = get_commands($3);
						concat_commands(coms1, coms3);
						map<long long, tuple<long long, string, string>>* coms2 = is_smaller_MR($1, $3);
						concat_commands(coms1, coms2);
				$$ = $1;
				number_of_block++;
			}
             | value '>' value			{
				 
						map<long long, tuple<long long, string, string>>* coms1 = get_commands($1);
						map<long long, tuple<long long, string, string>>* coms3 = get_commands($3);
						concat_commands(coms1, coms3);
						map<long long, tuple<long long, string, string>>* coms2 = is_greater_MR($1, $3);
						concat_commands(coms1, coms2);
				$$ = $1;
				number_of_block++;
			}
             | value '<' '=' value		{
				
						map<long long, tuple<long long, string, string>>* coms1 = get_commands($1);
						map<long long, tuple<long long, string, string>>* coms4 = get_commands($4);
						concat_commands(coms1, coms4);
						map<long long, tuple<long long, string, string>>* coms2 = is_smaller_or_equal_MR($1, $4);
						concat_commands(coms1, coms2);
				$$ = $1;
				number_of_block++;
			}
             | value '>' '=' value		{
				
						map<long long, tuple<long long, string, string>>* coms1 = get_commands($1);
						map<long long, tuple<long long, string, string>>* coms4 = get_commands($4);
						concat_commands(coms1, coms4);
						map<long long, tuple<long long, string, string>>* coms2 = is_greater_or_equal_MR($1, $4);
						concat_commands(coms1, coms2);
				$$ = $1;
				number_of_block++;
			}
;


value        : num {
				
				string reg = get_from_register_manager();
				register_register(reg, "");
				
				map<long long, tuple<long long, string, string>>* coms = make_number_log_MR (my_stoi($1, "531"), reg);
				$$ = put_data_map("", true, reg, coms);
			}
             | identifier		{
				 
				 if (is_initialized ($1))
					$$ = $1;
			}
;


identifier   : pidentifier {
				if ( !declaringVariables ) {
						
						if ( exists_array($1) )
								myError("ERROR! Variable used incorrectly: " + $1);
						else 
						if ( !exists_variable($1) )
								myError("ERROR! Variable not declared: " + $1);
						else 
						{
							
							string reg = get_from_register_manager();
							register_register(reg, "");
							if (settingVariable) {
									long long mem = get<0>( declaredVar->find($1)->second );
									map<long long, tuple<long long, string, string>>* coms = make_number_log_MR (mem, reg);
									
									$$ = put_data_map($1, true, reg, coms);
									
							} else {
									bool initialized = get<1> ( declaredVar->find($1)->second );
									
									
									map<long long, tuple<long long, string, string>>* coms = load_MR ($1, reg);
									$$ = put_data_map($1, initialized, reg, coms);
							}
						}
						
						id_index = -1;
						id_name = $1;
				}
			}
			
			
			
             | pidentifier '(' pidentifier ')' {
				 
				if ( exists_variable($1) )
						myError("ERROR! Array used incorrectly: " + $1);
				else
				if ( !exists_array($1) )
						myError("ERROR! Array not declared: " + $1);
				else
				if ( !exists_variable($3) ) {
						myError("ERROR! Variable not declared: " + $3);
				}
				else{
							bool initialized = get<1>( declaredVar->find($3)->second );
									
									string reg = get_from_register_manager();
									register_register(reg, "");
									
									if ( settingVariable ) {
											map<long long, tuple<long long, string, string>>* coms = load_memory_arr_var_MR ($1, $3, reg);
											$$ = put_data_map($1, true, reg, coms);
											
									} else {
											map<long long, tuple<long long, string, string>>* coms = load_arr_var_MR ($1, $3, reg);
											$$ = put_data_map($1, true, reg, coms);
									}
									
									id_index = -1;
									id_name = $1;
					}
				}
			
			
			
             | pidentifier '(' num ')'   {

				long long idx=0;
				idx = my_stoi($3, "615");
				
				if ( !exists_array($1) )
						myError("ERROR! Array not declared: " + $1);
				else
				if ( exists_variable($1) )
						myError("ERROR! Array used incorrectly: " + $1);
				else {
						
						map< string, tuple<long long, long long, long long, bool*>>::iterator arr_map = declaredArr->find($1);
						tuple <long long, long long, long long, bool*> arr_tuple = arr_map->second;
						if ( idx < get<0>(arr_tuple) || idx > get<1>(arr_tuple) )   myError("ERROR! Incorrect index of Array: " + $1);
						
						else {
								
								long long first        = get<0>(arr_tuple);
								long long last         = get<1>(arr_tuple);
								long long memory_first = get<2>(arr_tuple);
								bool* init_arr   = get<3>(arr_tuple);
								
								long long memory_idx = memory_first + idx - first;
								
								string reg = get_from_register_manager();
								register_register(reg, "");
								
								if ( settingVariable ) {
											
										map<long long, tuple<long long, string, string>>* coms = make_number_log_MR (memory_idx, reg);
										$$ = put_data_map($1, true, reg, coms);
								} else {
										
										map<long long, tuple<long long, string, string>>* coms = load_arr_num_MR (memory_idx, reg);
										$$ = put_data_map($1, init_arr[memory_idx], reg,  coms);
								}
								id_index = idx;
								id_name = $1;
						}
				}
			}
;
%%









void	put_help_commands_to_FOR_TO (string name, string key_4, string key_6) {
	
	if (exists_variable(name))
		myError("ERROR! Variable already declared: " + name); 
	else if ( exists_array(name) ) 
		myError("ERROR! Array already declared: " + name); 
	else
		make_variable(name);
	
	commands_in_for = name;
	
	string reg_2 = get_from_register_manager();
	register_register(reg_2, "");
	
	long long mem = get<0>( declaredVar->find(name)->second );
	map<long long, tuple<long long, string, string>>* result = make_number_log_MR (mem, reg_2);
	map<long long, tuple<long long, string, string>>* coms4 = get_commands (key_4);
	
	
	map<long long, tuple<long long, string, string>>* coms_store = copy_MR ("A", reg_2);
	release_register(reg_2, "346");
	
	concat_commands(coms_store, store_MR(get_reg (key_4)));
	
	release_register(get_reg (key_4), "");
	
	map<long long, tuple<long long, string, string>>* coms6 = get_commands (key_6);
	map<long long, tuple<long long, string, string>>* coms_set_last_val  = make_variable_last_FOR ( name, key_6 );

	release_register(get_reg (key_6), "");
	
	concat_commands( result, coms4 );
	concat_commands( result, coms_store );
	concat_commands( result, coms6 );
	concat_commands( result, coms_set_last_val );
	
	coms_help_to_initialize_header_of_loop->emplace(mem, result);
	
	set_initialized(name, -1);
	
	number_of_block++;
}





void	put_help_commands_to_FOR_DOWNTO (string name, string key_4, string key_6) {
	
	if (exists_variable(name))
		myError("ERROR! Variable already declared: " + name); 
	else if ( exists_array(name) ) 
		myError("ERROR! Array already declared: " + name); 
	else
		make_variable(name);
	
	commands_in_for = name;
	
	string reg_2 = get_from_register_manager();
	register_register(reg_2, "");
	
	long long mem = get<0>( declaredVar->find(name)->second );
	map<long long, tuple<long long, string, string>>* result = make_number_log_MR (mem, reg_2);
	map<long long, tuple<long long, string, string>>* coms4 = get_commands (key_4);
	
	
	map<long long, tuple<long long, string, string>>* coms_store = copy_MR ("A", reg_2);
	release_register(reg_2, "346");
	
	put(coms_store, INC, get_reg(key_4), "");
	
	concat_commands (coms_store, store_MR( get_reg(key_4) ));
	
	release_register ( get_reg(key_4), "" );
	
	map<long long, tuple<long long, string, string>>* coms6 = get_commands (key_6);
	map<long long, tuple<long long, string, string>>* coms_set_last_val  = make_variable_last_FOR_DOWNTO ( name, key_6 );

	release_register(get_reg (key_6), "");
	
	concat_commands ( result, coms4 );
	concat_commands ( result, coms_store );
	concat_commands ( result, coms6 );
	concat_commands ( result, coms_set_last_val );
	
	coms_help_to_initialize_header_of_loop->emplace(mem, result);
	
	set_initialized(name, -1);
	
	number_of_block++;
}


map<long long, tuple<long long, string, string>>*		get_help_commands_to_initialize_header_of_loop	(long long mem) {
	return coms_help_to_initialize_header_of_loop->find(mem)->second;
}




void    make_array    (string name, string a, string b) {
	
	long long size = my_stoi(b, "668") - my_stoi(a, "669") + 1;
	bool* forth = new bool[size];
	for (long long i=0; i<size; i++) forth[i]=false;
	declaredArr->emplace(name, make_tuple(my_stoi(a, "672"), my_stoi(b, "673"), memory, forth ));
	
	memory+=size;
}

void    make_variable    (string name) {
	
	declaredVar->emplace(name, make_tuple( memory, false));
	
	memory++;
}

void    erase_variable    (string name) {
	declaredVar->erase(name);
}

void    erase_variable_last_FOR    (string name) {
	declared_var_for->erase(name);
}






map<long long, tuple<long long, string, string>>* inc_from_memory_MR (string name) {
	
	long long mem = get<0>( declaredVar->find(name)->second );
	
	string reg = get_from_register_manager();
	register_register(reg, "");
	

	map<long long, tuple<long long, string, string>>* result = make_number_log_MR (mem, reg);
	release_register(reg, "");
	
	concat_commands( result, copy_MR("A", reg) );
	put(result, LOAD, reg, "");
	put(result, INC, reg, "");
	put(result, STORE, reg, "");
	
	return result;	
}

map< long long, tuple<long long, string, string> >*    make_variable_last_FOR_DOWNTO	    (string name, string key_1 ) {
	
	declared_var_for->emplace(name, memory);
	
	memory++;
	
	
	map< long long, tuple<long long, string, string> >* result;
	
	string reg_val = get_from_register_manager();
	register_register(reg_val, "");
	

	result = make_number_log_MR (memory-1, reg_val);
	
	put(result, INC, get_reg(key_1), "");
	concat_commands( result, copy_MR("A", reg_val) );
	concat_commands( result, store_MR( get_reg(key_1) ) );
	
	release_register(reg_val, "");
	return result;
}

map< long long, tuple<long long, string, string> >*    make_variable_last_FOR	    (string name, string key_1 ) {
	
	declared_var_for->emplace(name, memory);
	
	memory++;
	
	
	map< long long, tuple<long long, string, string> >* result;
	
	string reg_val = get_from_register_manager();
	register_register(reg_val, "");
	

	result = make_number_log_MR (memory-1, reg_val);
	
	concat_commands( result, copy_MR("A", reg_val) );
	concat_commands( result, store_MR( get_reg(key_1) ) );
	
	release_register(reg_val, "");
	return result;
}

map< long long, tuple<long long, string, string> >*    load_variable_last_FOR	    (string name, string reg_val ) {
	
	long long mem = declared_var_for->find(name)->second;
	
	map< long long, tuple<long long, string, string> >* result = make_number_log_MR (mem, reg_val);

	
	concat_commands( result, copy_MR("A", reg_val) );
	put(result, LOAD, reg_val, "");
	
	return result;
}






















map< long long, tuple<long long, string, string> >*   negate_MR ( string reg1, string reg2 ) {						//	ASSISTANT
	map< long long, tuple<long long, string, string> >* result = new map< long long, tuple<long long, string, string> >;
	put( result, SUB,  reg2, reg2);
	put( result, INC,  reg2, "");
	put( result, SUB,  reg2, reg1);
	put( result, COPY,  reg1, reg2);
	
	return result;
}

map< long long, tuple<long long, string, string> >*   is_equal_MR ( string key1,  string key2) {
	
	string reg1 = get_reg(key1);
	string reg2 = get_reg(key2);
	
	map< long long, tuple<long long, string, string> >* result = new map< long long, tuple<long long, string, string> >;
	
	string regHelp = get_from_register_manager();
	
	put( result, COPY, regHelp, reg1);
	put( result, SUB,  regHelp, reg2);
	put( result, JZERO, regHelp, "2");
	put( result, JUMP,  "4", "");
	put( result, COPY, regHelp, reg2);
	put( result, SUB,  regHelp, reg1);
	put( result, JZERO, regHelp, "4");
	put( result, SUB,  reg1, reg1);
	put( result, INC,  reg1, "");
	put( result, JUMP,  "2", "");
	put( result, SUB,  reg1, reg1);
	
	release_register(reg1, "972");
	release_register(reg2, "972");
	return result;
}


map< long long, tuple<long long, string, string> >*   is_not_equal_MR ( string key1,  string key2) {
	
	string reg1 = get_reg(key1);
	string reg2 = get_reg(key2);
	
	map< long long, tuple<long long, string, string> >* result = is_equal_MR( key1, key2 );
	concat_commands ( result, negate_MR(reg1, reg2) );
	
	return result;
}


map< long long, tuple<long long, string, string> >*   is_smaller_MR ( string key1,  string key2) {
	
	string reg1 = get_reg(key1);
	string reg2 = get_reg(key2);
	
	map< long long, tuple<long long, string, string> >* result = is_greater_or_equal_MR( key1, key2 );
	concat_commands ( result, negate_MR(reg1, reg2) );
	
	return result;
}


map< long long, tuple<long long, string, string> >*   is_greater_MR ( string key1,  string key2) {
	
	string reg1 = get_reg(key1);
	string reg2 = get_reg(key2);
	map< long long, tuple<long long, string, string> >* result = is_smaller_or_equal_MR( key1, key2 );
	concat_commands ( result, negate_MR(reg1, reg2) );
	
	return result;
}


map< long long, tuple<long long, string, string> >*   is_smaller_or_equal_MR ( string key1,  string key2) {
	
	string reg1 = get_reg(key1);
	string reg2 = get_reg(key2);
	
	map< long long, tuple<long long, string, string> >* result = new map< long long, tuple<long long, string, string> >;
	
	put( result, SUB, reg1, reg2);
	put( result, JZERO, reg1, "3");
	put( result, SUB, reg1, reg1);
	put( result, INC, reg1, "");
	put( result, COPY, reg1, reg1);
	
	release_register(reg1, "1030");
	release_register(reg2, "1031");
	return result;
}


map< long long, tuple<long long, string, string> >*   is_smaller_or_equal_with_registers_MR ( string reg1,  string reg2) {
	map< long long, tuple<long long, string, string> >* result = new map< long long, tuple<long long, string, string> >;
	
	put( result, SUB, reg1, reg2);
	put( result, JZERO, reg1, "3");
	put( result, SUB, reg1, reg1);
	put( result, INC, reg1, "");
	put( result, COPY, reg1, reg1);
	
	release_register(reg1, "361");
	release_register(reg2,  "360");
	
	return result;
}


map< long long, tuple<long long, string, string> >*   is_greater_or_equal_with_registers_MR ( string reg1,  string reg2) {
	map< long long, tuple<long long, string, string> >* result = new map< long long, tuple<long long, string, string> >;
	
	put( result, SUB, reg2, reg1);
	put( result, JZERO, reg2, "4");
	put( result, SUB, reg1, reg1);
	put( result, INC, reg1, "");
	put( result, JUMP, "2", "");
	put( result, SUB, reg1, reg1);
	put( result, COPY, reg1, reg1);
	
	
	release_register(reg1, "361");
	release_register(reg2,  "360");
	return result;
}


map< long long, tuple<long long, string, string> >*   is_greater_or_equal_MR ( string key1,  string key2) {
	
	string reg1 = get_reg(key1);
	string reg2 = get_reg(key2);
	
	map< long long, tuple<long long, string, string> >* result = new map< long long, tuple<long long, string, string> >;
	
	put( result, SUB, reg2, reg1);
	put( result, JZERO, reg2, "4");
	put( result, SUB, reg1, reg1);
	put( result, INC, reg1, "");
	put( result, JUMP, "2", "");
	put( result, SUB, reg1, reg1);
	put( result, COPY, reg1, reg1);
	
	release_register(reg1, "1081");
	release_register(reg2, "1082");
	return result;
}







map< long long, tuple<long long, string, string> >*   addition_MR ( string key1, string key2 ) {
	
	map< long long, tuple<long long, string, string> >*   result = new  map< long long, tuple<long long, string, string> >;	
	put(result, ADD  , get_reg(key1), get_reg(key2));
	
	release_register(get_reg(key2), "1012");
	return result;
}


map< long long, tuple<long long, string, string> >*   subtration_MR ( string key1, string key2 ) {
	
	map< long long, tuple<long long, string, string> >*   result = new  map< long long, tuple<long long, string, string> >;	
	put(result, SUB, get_reg(key1), get_reg(key2));
	
	release_register(get_reg(key2), "1022");
	return result;
}




map< long long, tuple<long long, string, string> >*   multiplication_MR ( string key1,  string key2) {
	
	string reg1 = get_reg(key1);
	string reg2 = get_reg(key2);
	map< long long, tuple<long long, string, string> >*   result = new  map< long long, tuple<long long, string, string> >;
	
	
	string reg3 = get_from_register_manager();
	register_register(reg3, "");
	string reg4 = get_from_register_manager();
	register_register(reg4, "");
	string reg5 = get_from_register_manager();
	register_register(reg5, "");
	
	
	put(result, SUB, reg4, reg4);
	put(result, JZERO, reg1, "32");
	put(result, JZERO, reg2, "31");
	
	put(result, SUB, reg3, reg3);
	put(result, INC, reg3, "");
	put(result, COPY, reg5, reg2);
	put(result, INC, reg2, "");
	put(result, SUB, reg2, reg3);
	put(result, JZERO, reg2, "7");
	
	put(result, DEC, reg2, "");
	put(result, JZERO, reg2, "7");
	
	put(result, COPY, reg2, reg5);
    put(result, ADD, reg1, reg1);
    put(result, ADD, reg3, reg3);
    put(result, JUMP, "-9", "" );
	
    put(result, HALF, reg3, "");
    put(result, HALF, reg1, "");
    put(result, COPY, reg2, reg5);
    put(result, SUB, reg2, reg3);
    put(result, ADD, reg4, reg1);
	put(result, JZERO, reg2, "13" );
	
    put(result, COPY, reg5, reg2);
    put(result, INC, reg2, "");
    put(result, SUB, reg2, reg3);
    put(result, JZERO, reg2, "5" );
	
    put(result, COPY, reg2, reg5);
    put(result, SUB, reg2, reg3);
    put(result, ADD, reg4, reg1);
    put(result, JUMP, "-8", "" );
	
    put(result, COPY, reg2, reg5);
    put(result, HALF, reg3, "");
    put(result, HALF, reg1, "");
    put(result, JUMP, "-11", "" );
	
    put(result, COPY, reg1, reg4);
	
	release_register(reg2, "1008");
	release_register(reg3, "1009");
	release_register(reg4, "1010");
	release_register(reg5, "1011");
	
	return result;
}





map< long long, tuple<long long, string, string> >*   division_MR ( string key1,  string key2) {
	
	string reg1 = get_reg(key1);
	string reg2 = get_reg(key2);
	map< long long, tuple<long long, string, string> >*   result = new  map< long long, tuple<long long, string, string> >;
	
	
	string reg3 = get_from_register_manager();
	register_register(reg3, "");
	string reg4 = get_from_register_manager();
	register_register(reg4, "");
	string reg5 = get_from_register_manager();
	register_register(reg5, "");
	
	
	
	put(result, SUB, reg4, reg4);
	put(result, JZERO, reg1, "31" );
	put(result, JZERO, reg2, "30" );
	
	put(result, SUB, reg3, reg3);
	put(result, INC, reg3, "");
	put(result, COPY, reg5, reg1);
	put(result, INC, reg1, "");
	put(result, SUB, reg1, reg2);
	put(result, JZERO, reg1, "7" );
	
	put(result, DEC, reg1, "");
	put(result, JZERO, reg1, "7" );
	
	put(result, COPY, reg1, reg5);
	put(result, ADD, reg2, reg2);
	put(result, ADD, reg3, reg3);
	put(result, JUMP, "-9", "" );
	
	put(result, HALF, reg3, "");
	put(result, HALF, reg2, "");
	put(result, COPY, reg1, reg5);
	put(result, SUB, reg1, reg2);
	put(result, ADD, reg4, reg3);
	put(result, JZERO, reg3, "12" );
	
	put(result, COPY, reg5, reg1);
	put(result, INC, reg1, "");
	put(result, SUB, reg1, reg2);
	put(result, JZERO, reg1, "4" );
	
	put(result, DEC, reg1, "");
	put(result, ADD, reg4, reg3);
	put(result, JUMP, "-7", "" );
	
	put(result, COPY, reg1, reg5);
	put(result, HALF, reg3, "");
	put(result, HALF, reg2, "");
	put(result, JUMP, "-10", "" );
	
	put(result, COPY, reg1, reg4);
			
			
	release_register(reg2, "1208");
	release_register(reg3, "1209");
	release_register(reg4, "1210");
	release_register(reg5, "1211");
	
	return result;
}




map< long long, tuple<long long, string, string> >*   modulation_MR ( string key1,  string key2) {
	
	string reg1 = get_reg(key1);
	string reg2 = get_reg(key2);
	map< long long, tuple<long long, string, string> >*   result = new  map< long long, tuple<long long, string, string> >;
	
	
	string reg3 = get_from_register_manager();
	register_register(reg3, "");
	string reg4 = get_from_register_manager();
	register_register(reg4, "");
	string reg5 = get_from_register_manager();
	register_register(reg5, "");
	

	
	
	put( result, SUB, reg4, reg4);
	put( result, JZERO, reg1, "31" );
	put( result, JZERO, reg2, "30" );
	
	put( result, SUB, reg3, reg3);
	put( result, INC, reg3, "");
	put( result, COPY, reg5, reg1);
	put( result, INC, reg1, "");
	put( result, SUB, reg1, reg2);
	put( result, COPY, reg4, reg5);
	put( result, JZERO, reg1, "7" );
	
	put( result, DEC, reg1, "");
	put( result, JZERO, reg1, "20");
	
	put( result, COPY, reg1, reg5);
	put( result, ADD, reg2, reg2);
	put( result, ADD, reg3, reg3);
	put( result, JUMP, "-9", "" );
	
	put( result, HALF, reg3, ""); 
	put( result, HALF, reg2, "");
	put( result, COPY, reg1, reg5);
	put( result, JZERO, reg3, "13" ); 
	
	put( result, COPY, reg5, reg1);
	put( result, INC, reg1, "");
	put( result, SUB, reg1, reg2);
	put( result, JZERO, reg1, "4" );
	
	put( result, DEC, reg1, "");
	put( result, SUB, reg4, reg2);
	put( result, JUMP, "-6", "" );
	
	put( result, COPY, reg1, reg5);
	put( result, HALF, reg3, "");
	put( result, HALF, reg2, "");
	put( result, JUMP, "-11", "" );
	
	put( result, SUB, reg4, reg4);
	put( result, COPY, reg1, reg4);
			
			
	release_register(reg2, "1208");
	release_register(reg3, "1209");
	release_register(reg4, "1210");
	release_register(reg5, "1211");
	
	return result;
}




















map< long long, tuple<long long, string, string> >*        make_number_log_MR        (long long number, string reg_res) {
	string reg_help = get_from_register_manager();
	return make_number_log_MR(number, reg_res, reg_help);
}



map< long long, tuple<long long, string, string> >*        make_number_log_MR        (long long number, string reg_res, string reg_help) {
	
	map< long long, tuple<long long, string, string> >*   result = new  map< long long, tuple<long long, string, string> >;
	
	put(result, SUB, reg_help, reg_help);
	put(result, SUB, reg_res, reg_res);
	put(result, INC, reg_help, "");
	
	long long res = 0;
    long long iq = 1;

    while (2*iq<number){
        iq = 2*iq;
        put(result, ADD, reg_help, reg_help);
    }
	
    while(res!=number){
        while (res+iq > number){
            iq = iq/2;
            put(result, HALF, reg_help, "");
        }
        res += iq;
        put(result, ADD, reg_res, reg_help);
    }
	
	return result;
}













map<long long, tuple<long long, string, string> > *      load_arr_num_MR     (long long memory_idx, string reg) {
	
	map<long long, tuple<long long, string, string> > * result = new map<long long, tuple<long long, string, string> >;
	string reg_help = get_from_register_manager();
	
	result = make_number_log_MR( memory_idx, reg, reg_help);

	put (result, COPY, "A", reg);
	put (result, LOAD, reg, "");
	return result;
}




map<long long, tuple<long long, string, string> > *      load_memory_arr_var_MR     (string arrName, string var, string reg_A) {
	
	map<long long, tuple<long long, string, string> > * result = new map<long long, tuple<long long, string, string> >;
	tuple <long long, long long, long long, bool*> arrTuple = declaredArr->find(arrName)->second;
	
	long long first        = get<0>(arrTuple);
	long long last         = get<1>(arrTuple);
	long long memory_first = get<2>(arrTuple);
	
	string reg = get_from_register_manager();
	string reg_help = get_from_register_manager();
//	memory_idx := memory_first - first + load_MR(var);
	
	result = load_MR( var, reg_A, reg_help );
	concat_commands( result, make_number_log_MR(memory_first, reg, reg_help) );

	put ( result, ADD, reg_A, reg );
	concat_commands( result, make_number_log_MR(first, reg, reg_help) );

	put ( result, SUB, reg_A, reg );
	
	return result;
}






map<long long, tuple<long long, string, string> > *      load_arr_var_MR     (string arrName, string var, string reg) {
	
	map<long long, tuple<long long, string, string> > * result = new map<long long, tuple<long long, string, string> >;
	
	tuple <long long, long long, long long, bool*> arrTuple = declaredArr->find(arrName)->second;
	
	long long first        = get<0>(arrTuple);
	long long last         = get<1>(arrTuple);
	long long memory_first = get<2>(arrTuple);
//	memory_idx := memory_first - first + load_MR(var);
	
	string reg_help = get_from_register_manager();

	result = load_MR( var, "A", reg_help );
	concat_commands( result, make_number_log_MR(memory_first, reg, reg_help) );

	put ( result, ADD, "A", reg );
	concat_commands( result, make_number_log_MR(first, reg, reg_help) );

	put ( result, SUB, "A", reg );
	put ( result, LOAD, reg, "");
	
	return result;
}









map<long long, tuple<long long, string, string> >*         load_MR       (string varName, string reg, string reg_help_to_make) {
	
	map< long long, tuple<long long, string, string>>* result;
	
	map< string, tuple<long long, bool>>::iterator var_map = declaredVar->find(varName);
	
	
	tuple <long long, bool> varTuple = var_map->second;
	bool initialized = get<1>(varTuple);
	
	result = make_number_log_MR(get<0>(varTuple), reg, reg_help_to_make);

	
	put(result, COPY, "A", reg);
	put(result, LOAD, reg, "");
	
	return result;
}



map<long long, tuple<long long, string, string> >*         load_MR       (string varName, string reg) {
	
	map< long long, tuple<long long, string, string>>* result;
	
	map< string, tuple<long long, bool>>::iterator var_map = declaredVar->find(varName);
	
	tuple <long long, bool> varTuple = var_map->second;
	bool initialized = get<1>(varTuple);
	long long mem = get<0>(varTuple);
	
	result = make_number_log_MR(mem, reg);
	
	
	put(result, COPY, "A", reg);
	put(result, LOAD, reg, "");
	
	return result;
}




map<long long, tuple<long long, string, string> >*         copy_MR      ( string reg1, string reg2 ) {
	
	map< long long, tuple<long long, string, string>>* result = new map< long long, tuple<long long, string, string>>;
	put(result, COPY, reg1, reg2);
	return result;	
}




map<long long, tuple<long long, string, string> >*         put_MR      ( string reg ) {
	
	map< long long, tuple<long long, string, string>>* result = new map< long long, tuple<long long, string, string>>;
	put(result, PUT, reg, "");
	
	release_register(reg, "1320");
	return result;	
}



map<long long, tuple<long long, string, string> >*         get_MR      ( string reg ) {
	
	map< long long, tuple<long long, string, string>>* result = new map< long long, tuple<long long, string, string>>;
	put(result, GET, reg, "");
	return result;	
}





map<long long, tuple<long long, string, string> >*         store_MR      (string reg) {
	
	map< long long, tuple<long long, string, string>>* result = new map< long long, tuple<long long, string, string>>;
	put(result, STORE, reg, "");
	return result;	
}



map<long long, tuple<long long, string, string> >*         jump_MR      (long long val) {
	
	map< long long, tuple<long long, string, string>>* result = new map< long long, tuple<long long, string, string>>;
	put(result, JUMP, to_string(val), "");
	return result;	
}



map<long long, tuple<long long, string, string> >*         jzero_MR      (string reg, long long val) {
	
	map< long long, tuple<long long, string, string>>* result = new map< long long, tuple<long long, string, string>>;
	put( result, JZERO, reg, to_string(val) );
	return result;	
}



map<long long, tuple<long long, string, string> >*         halt_MR      () {
	
	map< long long, tuple<long long, string, string>>* result = new map< long long, tuple<long long, string, string>>;
	put(result, HALT, "", "");
	return result;	
}



map<long long, tuple<long long, string, string> >*         dec_MR      (string reg) {
	
	map< long long, tuple<long long, string, string>>* result = new map< long long, tuple<long long, string, string>>;
	put(result, DEC, reg, "");
	return result;
}



map<long long, tuple<long long, string, string> >*         inc_MR      (string reg) {
	
	map< long long, tuple<long long, string, string>>* result = new map< long long, tuple<long long, string, string>>;
	put(result, INC, reg, "");
	return result;	
}

map<long long, tuple<long long, string, string> >*         dec_from_memory_MR      (string name) {
	
	long long mem = get<0>( declaredVar->find(name)->second );
	string reg = get_from_register_manager();
	register_register(reg, "");
	
	map< long long, tuple<long long, string, string>>* result = make_number_log_MR(mem, reg);

	concat_commands( result, copy_MR( "A", reg ) );
	
	put(result, LOAD, reg, "");
	put(result, DEC, reg, "");
	put(result, STORE, reg, "");
	
	release_register(reg, "1380");
	return result;
}







string	put_data_map 	( string name,   bool initialized,   string reg,   map<long long, tuple<long long, string, string>>* commands ) {
	long long key = data_map->size();
	data_map->emplace	( key,	make_tuple( name, initialized, reg, commands ));
	
	return to_string(key);
}








void    put     (map<long long, tuple<long long, string, string> >* list, long long com, string par1, string par2) {
	list->emplace(list->size(), make_tuple(com, par1, par2));
}





void   concat_commands       ( map< long long, tuple<long long, string, string> >* result, map< long long, tuple<long long, string, string> >* commands ) {
	
	for (unsigned long long i = 0; i < commands->size(); i++ ) {
		tuple<long long, string, string> comT = commands->find(i)->second;
		put(result, get<0>(comT), get<1>(comT), get<2>(comT));
	}
}




long long my_stoi (string var, string com) {
	try {
		long long i = stoi(var);
		return i;
	} catch (const std::invalid_argument& ia) {
		cout<<"WRONG CONVERSION: "<<var<<"  com: "<<com<<endl;
		return -1;
	}
}




void set_initialized (string name, long long idx) {
	
	if (idx == -1) {
		
//		cout<<"set_initialized:  "<<name<<"  "<<idx<<endl;
		std::map<string, tuple<long long, bool> >::iterator it = declaredVar->find(name); 
		tuple<long long, bool> data = it->second;
		
		long long add = get<0>(data);
		
		it->second = make_tuple(add, true);		
		
	} else {
		
		std::map< string, tuple<long long, long long, long long, bool*> >::iterator it = declaredArr->find(name); 
		tuple<long long, long long, long long, bool*> data = it->second;
		
		long long first = get<0>(data);
		long long last = get<1>(data);
		long long add = get<2>(data);
		bool* init=get<3>(data);
		
		
		long long memory_idx = add + idx - first;
		init[memory_idx]=true;
		
		it->second = make_tuple(first, last, add, init);		
		
	}
}







long long get_commands_size (string key_str) {
	
	long long key = my_stoi(key_str, "1234");
	
	tuple <string, bool, string, map<long long, tuple<long long, string, string>>* > var_data = data_map->find(key)->second;
	
	map<long long, tuple<long long, string, string>>* commands = get<3>(var_data);
	return commands->size();
}



map<long long, tuple<long long, string, string>>* get_commands (string key_str) {
	
	long long key = my_stoi(key_str, "1247");
	
	tuple <string, bool, string, map<long long, tuple<long long, string, string>>* > var_data = data_map->find(key)->second;
	
	map<long long, tuple<long long, string, string>>* commands = get<3>(var_data);
	return commands;
}


string get_name (string key_str) {
	
	long long key = my_stoi(key_str, "1259");
	
	tuple <string, bool, string, map<long long, tuple<long long, string, string>>* > var_data = data_map->find(key)->second;
	
	string name = get<0>(var_data);
	
	return name;
}
bool is_initialized (string key_str) {
	
	long long key = my_stoi(key_str, "1271");
	
	tuple <string, bool, string, map<long long, tuple<long long, string, string>>* > var_data = data_map->find(key)->second;
	
	bool init 	= get<1>(var_data);
	string name = get<0>(var_data);
	if ( !init && number_of_block==0 ) {
		myError("ERROR! Variable uninitialized: " + name);
	}
	return init;
}




string get_reg (string key_str) {
	
	long long key = my_stoi(key_str, "1286");
	
	tuple <string, bool, string, map<long long, tuple<long long, string, string>>* > var_data = data_map->find(key)->second;
	
	string reg = get<2>(var_data);
	return reg;
}





void	register_register (string reg, string shit) {
	
	registered_registers->emplace(reg, shit);
}



string	release_register (string reg, string com) {
	
	if (!contains_register(reg)) {
		return "";
	}
	string shit = registered_registers->find(reg)->second;
	registered_registers->erase(reg);
	return shit;
}




bool contains_register (string reg) {
	return (registered_registers->find(reg) != registered_registers->end());
}



string get_from_register_manager () {
	
	bool found = false;
	string reg = "";
	int loops = 0;

	while (!found) {
			switch (freeRegister) {
				case 0:
					if (!contains_register("B")) {
						reg = "B";
						found=true;
					}
					freeRegister++;
					break;
				case 1:
					if (!contains_register("C")) {
						reg = "C";
						found=true;
					}
					freeRegister++;
					break;
				case 2:
					if (!contains_register("D")) {
						reg = "D";
						found=true;
					}
					freeRegister++;
					break;
				case 3:
					if (!contains_register("E")) {
						reg = "E";
						found=true;
					}
					freeRegister++;
					break;
				case 4:
					if (!contains_register("F")) {
						reg = "F";
						found=true;
					}
					freeRegister++;
					break;
				case 5:
					if (!contains_register("G")) {
						reg = "G";
						found=true;
					}
					freeRegister++;
					break;
				case 6:
					if (!contains_register("H")) {
						reg = "H";
						found=true;
					}
					freeRegister=0;
					break;
			}
			
			loops++;
	}
	
	return reg;
}






bool 	 exists_variable 				(string name) {
	
	if ( declaredVar->find(name) != declaredVar->end() ) {
		return true;
	}
	else return false;
}



bool	 exists_array 					(string name) {
	
	if (declaredArr->find(name) != declaredArr->end() ) {
		return true;
	}
	else return false;
}



bool	 contains_variable_or_array		(string name) {
	
	if ( declaredVar->find(name) != declaredVar->end() ) {
		return true;
	}
	
	if (declaredArr->find(name) != declaredArr->end() ) {
		return true;
	}
	return false;
}





string parseCommand (long long com) {
	string reg = "";
	switch(com) {
		case GET:
			reg = "GET";
			break;
		case PUT:
			reg = "PUT";
			break;
		case LOAD:
			reg = "LOAD";
			break;
		case STORE:
			reg = "STORE";
			break;
		case COPY:
			reg = "COPY";
			break;
		case ADD:
			reg = "ADD";
			break;
		case SUB:
			reg = "SUB";
			break;
		case HALF:
			reg = "HALF";
			break;
		case INC:
			reg = "INC";
			break;
		case DEC:
			reg = "DEC";
			break;
		case JUMP:
			reg = "JUMP";
			break;
		case JZERO:
			reg = "JZERO";
			break;
		case JODD:
			reg = "JODD";
			break;
		case HALT:
			reg = "HALT";
			break;
		default:
			reg = "ERROR";
	}
	return reg;
}




void myError(string message) {
	const char * c = message.c_str();
	yyerror(c);
}



void yyerror(const char *s) {
	std::cerr << "Line " << yylineno << ": " << s << std::endl;
	exit(-1);
}



void run_parser( FILE * data, FILE * out, char const * name_of_out ) {
	std::cout << "Reading of the file." << std::endl;
	yyset_in( data );
	yyparse();
	
	
	
	fstream fs;
	fs.open (name_of_out, std::fstream::in | std::fstream::out | std::fstream::app);
	
	put_data_map( "", true, "", halt_MR() );
	
	
	tuple<  string,  bool,  string,  map< long long, tuple<long long,string,string> >*  > all_data = data_map->find(key_of_commands)->second;
	map< long long, tuple<long long,string,string> >* commands = get<3>(all_data);
	
	for (unsigned long long j = 0; j < commands->size(); j++) {
		
		tuple<long long,string,string> com = commands->find(j)->second;
		
		long long command_name = get<0>(com);
		fs <<parseCommand(command_name)<<" ";
		
		
		
		if ( command_name == JUMP) {
			fs<<j + my_stoi(get<1>(com), "1469") <<" "<< get<2>(com)<<endl;
			
		} else if ( command_name == JZERO || command_name ==JODD ) {
			fs<<get<1>(com)<<" "<<j + my_stoi(get<2>(com), "1473")<<endl;
			
		} else {
			fs<<get<1>(com)<<" "<<get<2>(com)<<endl;
		}
		
	}
	
	
	fs<<"HALT"<<endl;
	fs.close();
	
	
	
	
	yyset_out( out );
	std::cout << "Reading ended."<< std::endl;
}

int main( int argc, char const * argv[] ){
  	FILE * data;
  	FILE * out;
	
	
	if( argc!=3 )
	{
		std::cerr << "The way of using program is \"kompilator <input_file> <output_file>\"" << std::endl;
		return -1;
	}

  	data = fopen( argv[1], "r" );
  	out = fopen( argv[2], "w" );
  	if( !data )
  	{
    	std::cerr << "ERROR: Cannot open file: " << argv[1] << std::endl;
    	return -1;
  	}
	if( !out )
	{
    	std::cerr << "ERROR: Cannot open file: " << argv[2] << std::endl;
    	return -1;
  	}
	
	run_parser( data, out,  argv[2]);
	
	
	fclose( data );
	fclose( out );
	return 0;
}