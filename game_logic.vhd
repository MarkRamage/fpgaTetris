library ieee;
use ieee.std_logic_1164.all;

package board_pkg is
	type board_type is array(30 downto 0, 10 downto 0) of std_logic;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.board_pkg.all;

entity game_logic is
	port(rotate_cw, rotate_ccw, move_left, move_right, clk_50, reset : in std_logic;
		  output_matrix : out board_type);
end game_logic;

architecture behavioral of game_logic is

type state_type is (H, V, A, B, C, D);
type board_type is array(30 downto 0, 10 downto 0) of std_logic;
signal state : state_type;
signal key, move: std_logic;
signal col, row, colinc : integer;
signal gameboard : board_type;
signal displayboard : board_type;
signal new_block : std_logic;
signal clk_1Hz : std_logic;
signal clk_8Hz : std_logic;
signal lefty: std_logic;
signal righty: std_logic;
signal count, count2 : std_logic_vector(27 downto 0);

begin

	key <= rotate_cw or rotate_ccw;
	move <= not move_left or not move_right;
	

	
	--This process creates a 1Hz clock
	process(clk_50)
	begin
		if rising_edge(clk_50) then
			if count < X"17d7840" then
				count <= count + 1;
				clk_1Hz <= '0';
			else 
				count <= X"0000000";
				clk_1Hz <= '1';
			end if;
			if count2 < x"2faf08" then
				count2 <= count2+1;
				clk_8Hz <= '0';
			else
				count2 <= X"0000000";
				clk_8Hz <= '1';
			end if;
		end if;
		
	end process;
	
	-- This process represents a state machine which handles the rotation of the blocks 
	--based on user input
	process(key, new_block)
	begin
		-- This sets the state of the new block based on a randomly generated number
		if new_block = '1' then
			--TODO: SET STATE BASED ON RANDOM NUMBER
			state <= A;
			--new_block <= 0;
		elsif rising_edge(key) then
			case state is
				--State H represents horizontal line
				when H =>
					state <= V;
				--State V represents a vertical line	
				when V =>
					state <= H;
				
			   --State A represents :*
				when A =>
					if (rotate_cw = '1') then
						state <= B;
					elsif (rotate_ccw = '1') then
						state <= D;
					end if;
				--State B represents *:		
				when B =>
					if (rotate_cw = '1') then
						state <= C;
					elsif (rotate_ccw = '1') then
						state <= A;
					end if;
				--State C represents .:	
				when C =>
					if (rotate_cw = '1') then
						state <= D;
					elsif (rotate_ccw = '1') then
						state <= B;
					end if;
				--State D represent :.		
				when D =>
					if (rotate_cw = '1') then
						state <= A;
					elsif (rotate_ccw = '1') then
						state <= C;
					end if;
				when others => 
					state <= H;
			end case;
		end if;
	end process;
--	process (move_left, move_right)
--	begin
--		move <= move_left or move_right;
--	end process;
--	
--	process (move_right)
--	begin
--		if rising_edge(move_right) then
--			righty<= '1';
--		end if;
--	end process;
	--This process updates column value of block when the left or right buttons are pressed
	process(move)
	begin
		--if rising_edge(move) then
			if (move_left='0') and col > 0 then
				colinc <= -1;
			elsif (move_right='0') and col < 8 then
				colinc <= 1;
			else
				colinc <= 0;
			end if;
		--end if;
	end process;
	process(new_block,clk_1Hz)
	begin
		-- This sets a new starting point for new block to generate in randomly
		if new_block = '1' then
			-- TODO: RANDOM NUMBER GENERATION
			col <= 4;
	--	elsif lefty = '1' then
	--		if move_left = '1' then
--		elsif rising_edge(move) then
--			if move_left = '0' then
--				if col > 0 then
--					col <= col - 1;
--					lefty <= '0';
--				end if;
--		--elsif righty = '1' then
--			--if col > 8 then
--				--	col <= col + 1;
--					--righty <= '0';
--				--end if;
--			elsif move_right = '0' then
--				if state = V then
--					if col < 9 then
--						col <= col + 1;
--					end if;
--				elsif state = H then
--					if col < 7 then
--						col <= col + 1;
--					end if;
--				else
--					if col < 8 then
--						col <= col + 1;
--					end if;
--				end if; -- right or left
--			end if; -- move
		else
			if (clk_1Hz = '1')  then
					col <= col+ colinc;
			end if;
		end if; -- newblock
	end process;
				
					
		--Checks whether block can continue moving down the grid or if new block should be generated	process(clk_1Hz, state, col)
	process(clk_1Hz, state, col, new_block, reset)
	begin
		if reset = '1' then
			new_block <= '1';
			for i in 30 downto 0 loop
				for j in 10 downto 0 loop
					gameboard(i, j) <= '0';
				end loop;
			end loop;
	
		-- Sets row of new block back to 0 
		elsif new_block = '1' then
			row <= 0;
			new_block <= '0';
		
		elsif rising_edge(clk_1Hz) then
--			if state = V then
--				if gameboard(row+3, col) = '0' and row < 28 then
--					row <= row + 1;
--				else 
--					new_block <= '1';
--				end if;
--			elsif state = H then
--				if gameboard(row+1, col) = '0' and gameboard(row+1, col+1) = '0' and gameboard(row+1, col+2) = '0' and row < 30 then
--					row <= row + 1;
--				else 
--					new_block <= '1';
--				end if;
--			elsif state = C or state = D then
--				if gameboard(row+2, col) = '0' and gameboard(row+2, col+1) = '0' and row < 29 then
--					row <= row + 1;
--				else 
--					new_block <= '1';
--				end if;
			if state = A then
				if gameboard(row+2, col) = '0' and gameboard(row+1, col+1) = '0' and row < 28 then
					row <= row + 1;
				else 
					new_block <= '1';
					gameboard(row, col) <= '1';
					gameboard(row+1, col) <= '1';
					gameboard(row, col+1) <= '1';
				end if;
--			elsif state = B then
--				if gameboard(row+1, col) = '0' and gameboard(row+2, col+1) = '0' and row < 29 then
--					row <= row + 1;
--				else 
--					new_block <= '1';
--				end if;
			end if;
--			row <= row + 1;
		end if;
	end process;
	
	-- This process updates the gameboard 
	process(row, col, state, reset)
	begin
		displayboard<=gameboard;
		
		case state is
			when H =>
				if new_block = '0' then
					displayboard(row, col) <= '1';
					displayboard(row, col+1) <= '1';
					displayboard(row, col+2) <= '1';
				end if;
			
			when V =>
				if new_block = '0' then
					displayboard(row, col) <= '1';
					displayboard(row+1, col) <= '1';
					displayboard(row+2, col) <= '1';
				end if;
				
			when A =>
				if new_block = '0' then
					displayboard(row, col) <= '1';
					displayboard(row+1, col) <= '1';
					displayboard(row, col+1) <= '1';
				end if;
				
			when B =>
				if new_block = '0' then
					displayboard(row, col) <= '1';
					displayboard(row+1, col+1) <= '1';
					displayboard(row, col+1) <= '1';
				end if;
				
			when C =>
				if new_block = '0' then
					displayboard(row, col+1) <= '1';
					displayboard(row+1, col) <= '1';
					displayboard(row+1, col+1) <= '1';
				end if;

			when D =>
				if new_block = '0' then
					displayboard(row, col) <= '1';
					displayboard(row+1, col) <= '1';
					displayboard(row+1, col+1) <= '1';
				end if;
		end case;
	end process;
	
	-- This process writes the updated matrix to the output to be displayed by the display module
	process(displayboard)
	begin
		for i in 30 downto 0 loop
			for j in 10 downto 0 loop
				output_matrix(i, j) <= displayboard(i, j);
			end loop;
		end loop;
	end process;
		
end architecture behavioral;
			