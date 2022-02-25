module keypad(valid, number, a, b, c, d, e, f, g);
   output 	valid;
   output [3:0] number;
   input 	a, b, c, d, e, f, g;
   wire w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15, w16;

   or ov1(w1, d, e, f);
   and av1(w2, a, w1);
   or ov2(w3, d, e, f, g);
   and av2(w4, b, w3);
   and av3(w5, c, w1);
   or oValid(valid, w2, w4, w5);

   or oZero1(w6, a, c);
   and aZero1(w7, d, w6);
   and aZero2(w8, f, w6);
   and aZero3(w9, a, b);
   or oZero(number[0], w7, w8, w9);

   or oOne1(w10, b, c);
   and aOne1(w11, d, w10);
   and aOne2(w12, c, e);
   and aOne3(w13, a, f);
   or oOne(number[1], w11, w12, w13);

   and aTwo1(w14, a, f);
   or oTwo(number[2], e, w14);

   and aThree1(w15, b, f);
   and aThree2(w16, c, f);
   or oThree(number[3], w15, w16);



endmodule // keypad
