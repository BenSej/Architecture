module test;

   // these are inputs to "circuit under test"
   reg A=0;
   reg B=0;
   reg Cin=0;
  
   // wires for the outputs of "circuit under test"
   wire S, Cout;
  
   // the circuit under test
   sc2_block sc2(S, Cout, A, B, Cin);  
    
   initial begin               // initial = run at beginning of simulation
                               // begin/end = associate block with initial
      
      $dumpfile("sc2_block.vcd");  // name of dump file to create
      $dumpvars(0, test);     // record all signals of module "test" and sub-modules
                              // remember to change "test" to the correct
                              // module name when writing your own test benches

      // test all input combinations
      A = 0; B = 0; Cin = 0; #10
      A = 0; B = 0; Cin = 1; #10
      A = 0; B = 1; Cin = 0; #10
      A = 0; B = 1; Cin = 1; #10
      A = 1; B = 0; Cin = 0; #10
      A = 1; B = 0; Cin = 1; #10
      A = 1; B = 1; Cin = 0; #10
      A = 1; B = 1; Cin = 1; #10
          
      $finish;        // end the simulation
   end                      
   
   initial begin
     $display("inputs = A B Cin  outputs = S Cout");
     $monitor("inputs = %b %b %b  outputs = %b %b   ",
              A, B, Cin, S, Cout);
   end
endmodule // test
