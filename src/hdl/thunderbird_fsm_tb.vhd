--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture behavior of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
      port (
        i_clk, i_reset  : in    std_logic;
        i_left, i_right : in    std_logic;
        o_lights_L      : out   std_logic_vector(2 downto 0);
        o_lights_R      : out   std_logic_vector(2 downto 0)
    );
	end component thunderbird_fsm;

	-- test I/O signals
	signal w_sw : std_logic_vector(15 downto 0) := (others => '0');
    signal w_reset : std_logic := '0';
    signal w_clk : std_logic := '0';
    signal w_led : std_logic_vector(15 downto 0) := (others => '0');

    	
	-- constants
	constant k_clk_period : time := 10 ns;

	
begin
	-- PORT MAPS ----------------------------------------
   uut: thunderbird_fsm port map (
           i_reset => w_reset,
           i_left => w_sw(0),
           i_right => w_sw(15),
           i_clk => w_clk,
           o_lights_R(0) => w_led(2),
           o_lights_R(1) => w_led(1),
           o_lights_R(2) => w_led(0),
           o_lights_L(0) => w_led(13),
           o_lights_L(1) => w_led(14),
           o_lights_L(2) => w_led(15)

         );	
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    clk_proc : process
    begin
        w_clk <= '0';
        wait for k_clk_period/2;
        w_clk <= '1';
        wait for k_clk_period/2;
    end process;
    
	-----------------------------------------------------
	
	-- Test Plan Process --------------------------------
	sim_proc: process
    begin
        w_reset <= '1';
        wait for k_clk_period*1;
            assert w_led = "0" report "bad reset" severity failure;
            
        w_reset <= '0';
        wait for k_clk_period*1;

		w_sw(0) <= '1'; wait for k_clk_period;
            assert w_led = "000000000000100" report "bad right first state" severity failure;
        wait for k_clk_period;
            assert w_led = "000000000000110" report "bad right second state" severity failure;
        wait for k_clk_period;
            assert w_led = "000000000000111" report "bad right third state" severity failure;

        -- car shows up at red light
        w_sw(0) <= '0'; wait for k_clk_period;
        w_sw(15) <= '1'; wait for k_clk_period;
            assert w_led = "001000000000000" report "bad left first state" severity failure;   
        wait for k_clk_period;
            assert w_led = "011000000000000" report "bad right second state" severity failure;  
        wait for k_clk_period;
            assert w_led = "111000000000000" report "bad right third state" severity failure; 
             
        w_sw(0) <= '1';
        w_sw(15) <= '1'; wait for k_clk_period;            
            assert w_led = "111000000000111" report "bad hazard state" severity failure;

                                     
	wait;
	end process;
	
end behavior;
