/*
* Module         - codec2_encoder_2400
* Top module     - N/A -- Final Module
* Project        - CODEC2_ENCODE_2400
* Developer      - Santhiya S
* Date           - Wed Jul 03 19:25:02 2019
*
* Description    - 
* Input(s)       - 
* Output(s)      - 
* Simulation 	  - 
* 32 bits fixed point representation
   S - E  - M
   1 - 15 - 16
*/


module codec2_encoder_2400 (start_codec2,clk,rst,

							encoded_bits_0,encoded_bits_1,
							/* encoded_bits_2,
							encoded_bits_3,encoded_bits_4,encoded_bits_5,
							encoded_bits_6,encoded_bits_7,encoded_bits_8,encoded_bits_9, */
							
							//sp0,sp1,sp2,sp3,sp4,sp5,sp6,sp7,sp8,sp9,
							quant0,quant1,quant2,quant3,quant4,quant5,quant6,quant7,quant8,quant9,
							c_encode_woe,c_nlp_pitch1,c_nlp_pitch2,
							done_codec2);


//------------------------------------------------------------------
//                 -- Input/Output Declarations --                  
//------------------------------------------------------------------
				parameter N = 32;
				parameter Q = 16;
				parameter BITS_WIDTH = 48;
				parameter N1 = 80;
				parameter Q1 = 16;
	
				input clk,rst,start_codec2;
				
				
				
				output reg [BITS_WIDTH-1 :0] 	encoded_bits_0,encoded_bits_1;
												/* encoded_bits_2,
												encoded_bits_3,encoded_bits_4,encoded_bits_5,
												encoded_bits_6,encoded_bits_7,encoded_bits_8,encoded_bits_9; */
				reg [N-1:0] sp0,sp1,sp2,sp3,sp4,sp5,sp6,sp7,sp8,sp9;
				output reg [N-1:0] c_encode_woe,c_nlp_pitch1,c_nlp_pitch2;
				output reg [4:0] quant0,quant1,quant2,quant3,quant4,quant5,quant6,quant7,quant8,quant9;
				output reg done_codec2;
				
				 reg [N1-1:0] check_sig;
				
				 reg [N1-1:0] clk_count;
				 reg [4:0] count;
//------------------------------------------------------------------
//                  -- State & Reg Declarations  --                   
//------------------------------------------------------------------

parameter START = 3'd0,
          INIT_FOR = 3'd1,
          CHECK_I = 3'd2,
          START_CODEC_ONE_FRAME = 3'd3,
          RUN_CODEC_ONE_FRAME = 3'd4,
          GET_CODEC_ONE_FRAME = 3'd5,
          INCR_I = 3'd6,
          DONE = 3'd7;

reg [2:0] STATE, NEXT_STATE;

reg [9:0] i;

//------------------------------------------------------------------
//                 -- Module Instantiations --                  
//------------------------------------------------------------------

reg start_oneframe;
reg [N-1:0] in_prevf0,in_xq0,in_xq1,c_out_speech,c_read_c2_sn_out;
reg [N1-1:0] in_mem_x,in_mem_y,c_out_mem_fir,c_out_sq;

wire [N1-1:0] out_mem_x,out_mem_y,c_in_mem_fir,c_in_sq;
wire [N-1:0] out_prevf0, out_xq0, out_xq1,c_write_c2_sn;
wire [47 : 0] c_encoded_bits;
wire done_oneframe,c_re_c2_sn,c_we_c2_sn, c_read_fir,c_write_fir;

wire [9:0] c_addr_speech,c_addr_sn,c_addr_mem_fir,c_addr_nlp_sq;
wire  c_read_sq,c_write_sq;
wire [3:0] clsp9;
wire [N-1:0] check_sum,c_sn,c_encode_model_wo,c_pitch1,c_pitch2;


wire [4:0] c_lsp0,c_lsp1,c_lsp2,c_lsp3,c_lsp4,c_lsp5,c_lsp6,c_lsp7,c_lsp8,c_lsp9;
wire [N-1:0] c_speech_lsp0,c_speech_lsp1,c_speech_lsp2,c_speech_lsp3,c_speech_lsp4,
								   c_speech_lsp5,c_speech_lsp6,c_speech_lsp7,c_speech_lsp8,c_speech_lsp9;
wire [9:0] c_cmax1,c_cmax2;
wire [N1-1:0] c_outreal1, c_outreal2, c_check_in_real,c_check_in_imag;

codec2_encoder_2400_one_frame codec2_one_frame	(start_oneframe,clk, rst,

												in_mem_x, in_mem_y , in_prevf0, in_xq0, in_xq1,
												c_out_speech,c_read_c2_sn_out,c_out_mem_fir,c_out_sq,
												
												out_mem_x,out_mem_y, out_prevf0, out_xq0, out_xq1,
												c_encoded_bits,c_addr_speech,c_addr_sn,c_write_c2_sn,
												
												c_re_c2_sn,c_we_c2_sn,
												
												c_addr_mem_fir,c_in_mem_fir,c_read_fir,c_write_fir,
												c_addr_nlp_sq,c_in_sq,c_read_sq,c_write_sq,
												done_oneframe,
												
												clsp9,check_sum,c_sn,
												c_lsp0,c_lsp1,c_lsp2,c_lsp3,c_lsp4,c_lsp5,c_lsp6,c_lsp7,c_lsp8,c_lsp9,
												c_speech_lsp0,c_speech_lsp1,c_speech_lsp2,c_speech_lsp3,c_speech_lsp4,
												c_speech_lsp5,c_speech_lsp6,c_speech_lsp7,c_speech_lsp8,c_speech_lsp9,
												c_encode_model_wo,c_pitch1,c_pitch2,c_cmax1,c_cmax2,c_outreal1, c_outreal2,
												c_check_in_real,c_check_in_imag
												);
												
												
					
												

/*----------- RAM_speech for one_frame - 160 samples ---------------------*/
reg [9:0] addr_speech;
wire [N-1:0] out_speech;
RAM_speech_samples r_speech (addr_speech, clk,,1,0,out_speech); 


reg [9:0] addr_speech_0;
wire [N-1:0] out_speech_0;
RAM_speech_0  r_speech_0(addr_speech_0,clk,,1,0,out_speech_0);

reg [9:0] addr_speech_1;
wire [N-1:0] out_speech_1;
RAM_speech_1  r_speech_1(addr_speech_1,clk,,1,0,out_speech_1);

reg [9:0] addr_speech_2;
wire [N-1:0] out_speech_2;
RAM_speech_2  r_speech_2(addr_speech_2,clk,,1,0,out_speech_2);

reg [9:0] addr_speech_3;
wire [N-1:0] out_speech_3;
RAM_speech_3  r_speech_3(addr_speech_3,clk,,1,0,out_speech_3);

reg [9:0] addr_speech_4;
wire [N-1:0] out_speech_4;
RAM_speech_4  r_speech_4(addr_speech_4,clk,,1,0,out_speech_4);

reg [9:0] addr_speech_5;
wire [N-1:0] out_speech_5;
RAM_speech_5  r_speech_5(addr_speech_5,clk,,1,0,out_speech_5);

reg [9:0] addr_speech_6;
wire [N-1:0] out_speech_6;
RAM_speech_6  r_speech_6(addr_speech_6,clk,,1,0,out_speech_6);

reg [9:0] addr_speech_7;
wire [N-1:0] out_speech_7;
RAM_speech_7  r_speech_7(addr_speech_7,clk,,1,0,out_speech_7);

reg [9:0] addr_speech_8;
wire [N-1:0] out_speech_8;
RAM_speech_8  r_speech_8(addr_speech_8,clk,,1,0,out_speech_8);

reg [9:0] addr_speech_9;
wire [N-1:0] out_speech_9;
RAM_speech_9  r_speech_9(addr_speech_9,clk,,1,0,out_speech_9);

reg [9:0] addr_speech_10;
wire [N-1:0] out_speech_10;
RAM_speech_10 r_speech_10(addr_speech_10,clk,,1,0,out_speech_10);

reg [9:0] addr_speech_11;
wire [N-1:0] out_speech_11;
RAM_speech_11 r_speech_11(addr_speech_11,clk,,1,0,out_speech_11);

reg [9:0] addr_speech_12;
wire [N-1:0] out_speech_12;
RAM_speech_12 r_speech_12(addr_speech_12,clk,,1,0,out_speech_12);

reg [9:0] addr_speech_13;
wire [N-1:0] out_speech_13;
RAM_speech_13 r_speech_13(addr_speech_13,clk,,1,0,out_speech_13);

reg [9:0] addr_speech_14;
wire [N-1:0] out_speech_14;
RAM_speech_14 r_speech_14(addr_speech_14,clk,,1,0,out_speech_14);

reg [9:0] addr_speech_15;
wire [N-1:0] out_speech_15;
RAM_speech_15 r_speech_15(addr_speech_15,clk,,1,0,out_speech_15);

reg [9:0] addr_speech_16;
wire [N-1:0] out_speech_16;
RAM_speech_16 r_speech_16(addr_speech_16,clk,,1,0,out_speech_16);

reg [9:0] addr_speech_17;
wire [N-1:0] out_speech_17;
RAM_speech_17 r_speech_17(addr_speech_17,clk,,1,0,out_speech_17);

reg [9:0] addr_speech_18;
wire [N-1:0] out_speech_18;
RAM_speech_18 r_speech_18(addr_speech_18,clk,,1,0,out_speech_18);

reg [9:0] addr_speech_19;
wire [N-1:0] out_speech_19;
RAM_speech_19 r_speech_19(addr_speech_19,clk,,1,0,out_speech_19);

reg [9:0] addr_speech_20;
wire [N-1:0] out_speech_20;
RAM_speech_20 r_speech_20(addr_speech_20,clk,,1,0,out_speech_20);

reg [9:0] addr_speech_21;
wire [N-1:0] out_speech_21;
RAM_speech_21 r_speech_21(addr_speech_21,clk,,1,0,out_speech_21);

reg [9:0] addr_speech_22;
wire [N-1:0] out_speech_22;
RAM_speech_22 r_speech_22(addr_speech_22,clk,,1,0,out_speech_22);

reg [9:0] addr_speech_23;
wire [N-1:0] out_speech_23;
RAM_speech_23 r_speech_23(addr_speech_23,clk,,1,0,out_speech_23);

reg [9:0] addr_speech_24;
wire [N-1:0] out_speech_24;
RAM_speech_24 r_speech_24(addr_speech_24,clk,,1,0,out_speech_24);

reg [9:0] addr_speech_25;
wire [N-1:0] out_speech_25;
RAM_speech_25 r_speech_25(addr_speech_25,clk,,1,0,out_speech_25);

reg [9:0] addr_speech_26;
wire [N-1:0] out_speech_26;
RAM_speech_26 r_speech_26(addr_speech_26,clk,,1,0,out_speech_26);

reg [9:0] addr_speech_27;
wire [N-1:0] out_speech_27;
RAM_speech_27 r_speech_27(addr_speech_27,clk,,1,0,out_speech_27);

reg [9:0] addr_speech_28;
wire [N-1:0] out_speech_28;
RAM_speech_28 r_speech_28(addr_speech_28,clk,,1,0,out_speech_28);

reg [9:0] addr_speech_29;
wire [N-1:0] out_speech_29;
RAM_speech_29 r_speech_29(addr_speech_29,clk,,1,0,out_speech_29);

reg [9:0] addr_speech_30;
wire [N-1:0] out_speech_30;
RAM_speech_30 r_speech_30(addr_speech_30,clk,,1,0,out_speech_30);

reg [9:0] addr_speech_31;
wire [N-1:0] out_speech_31;
RAM_speech_31 r_speech_31(addr_speech_31,clk,,1,0,out_speech_31);

reg [9:0] addr_speech_32;
wire [N-1:0] out_speech_32;
RAM_speech_32 r_speech_32(addr_speech_32,clk,,1,0,out_speech_32);

reg [9:0] addr_speech_33;
wire [N-1:0] out_speech_33;
RAM_speech_33 r_speech_33(addr_speech_33,clk,,1,0,out_speech_33);

reg [9:0] addr_speech_34;
wire [N-1:0] out_speech_34;
RAM_speech_34 r_speech_34(addr_speech_34,clk,,1,0,out_speech_34);

reg [9:0] addr_speech_35;
wire [N-1:0] out_speech_35;
RAM_speech_35 r_speech_35(addr_speech_35,clk,,1,0,out_speech_35);

reg [9:0] addr_speech_36;
wire [N-1:0] out_speech_36;
RAM_speech_36 r_speech_36(addr_speech_36,clk,,1,0,out_speech_36);

reg [9:0] addr_speech_37;
wire [N-1:0] out_speech_37;
RAM_speech_37 r_speech_37(addr_speech_37,clk,,1,0,out_speech_37);

reg [9:0] addr_speech_38;
wire [N-1:0] out_speech_38;
RAM_speech_38 r_speech_38(addr_speech_38,clk,,1,0,out_speech_38);

reg [9:0] addr_speech_39;
wire [N-1:0] out_speech_39;
RAM_speech_39 r_speech_39(addr_speech_39,clk,,1,0,out_speech_39);

reg [9:0] addr_speech_40;
wire [N-1:0] out_speech_40;
RAM_speech_40 r_speech_40(addr_speech_40,clk,,1,0,out_speech_40);

reg [9:0] addr_speech_41;
wire [N-1:0] out_speech_41;
RAM_speech_41 r_speech_41(addr_speech_41,clk,,1,0,out_speech_41);

reg [9:0] addr_speech_42;
wire [N-1:0] out_speech_42;
RAM_speech_42 r_speech_42(addr_speech_42,clk,,1,0,out_speech_42);

reg [9:0] addr_speech_43;
wire [N-1:0] out_speech_43;
RAM_speech_43 r_speech_43(addr_speech_43,clk,,1,0,out_speech_43);

reg [9:0] addr_speech_44;
wire [N-1:0] out_speech_44;
RAM_speech_44 r_speech_44(addr_speech_44,clk,,1,0,out_speech_44);

reg [9:0] addr_speech_45;
wire [N-1:0] out_speech_45;
RAM_speech_45 r_speech_45(addr_speech_45,clk,,1,0,out_speech_45);

reg [9:0] addr_speech_46;
wire [N-1:0] out_speech_46;
RAM_speech_46 r_speech_46(addr_speech_46,clk,,1,0,out_speech_46);

reg [9:0] addr_speech_47;
wire [N-1:0] out_speech_47;
RAM_speech_47 r_speech_47(addr_speech_47,clk,,1,0,out_speech_47);

reg [9:0] addr_speech_48;
wire [N-1:0] out_speech_48;
RAM_speech_48 r_speech_48(addr_speech_48,clk,,1,0,out_speech_48);

reg [9:0] addr_speech_49;
wire [N-1:0] out_speech_49;
RAM_speech_49 r_speech_49(addr_speech_49,clk,,1,0,out_speech_49);

reg [9:0] addr_speech_50;
wire [N-1:0] out_speech_50;
RAM_speech_50 r_speech_50(addr_speech_50,clk,,1,0,out_speech_50);

reg [9:0] addr_speech_51;
wire [N-1:0] out_speech_51;
RAM_speech_51 r_speech_51(addr_speech_51,clk,,1,0,out_speech_51);

reg [9:0] addr_speech_52;
wire [N-1:0] out_speech_52;
RAM_speech_52 r_speech_52(addr_speech_52,clk,,1,0,out_speech_52);

reg [9:0] addr_speech_53;
wire [N-1:0] out_speech_53;
RAM_speech_53 r_speech_53(addr_speech_53,clk,,1,0,out_speech_53);

reg [9:0] addr_speech_54;
wire [N-1:0] out_speech_54;
RAM_speech_54 r_speech_54(addr_speech_54,clk,,1,0,out_speech_54);

reg [9:0] addr_speech_55;
wire [N-1:0] out_speech_55;
RAM_speech_55 r_speech_55(addr_speech_55,clk,,1,0,out_speech_55);

reg [9:0] addr_speech_56;
wire [N-1:0] out_speech_56;
RAM_speech_56 r_speech_56(addr_speech_56,clk,,1,0,out_speech_56);

reg [9:0] addr_speech_57;
wire [N-1:0] out_speech_57;
RAM_speech_57 r_speech_57(addr_speech_57,clk,,1,0,out_speech_57);

reg [9:0] addr_speech_58;
wire [N-1:0] out_speech_58;
RAM_speech_58 r_speech_58(addr_speech_58,clk,,1,0,out_speech_58);

reg [9:0] addr_speech_59;
wire [N-1:0] out_speech_59;
RAM_speech_59 r_speech_59(addr_speech_59,clk,,1,0,out_speech_59);

reg [9:0] addr_speech_60;
wire [N-1:0] out_speech_60;
RAM_speech_60 r_speech_60(addr_speech_60,clk,,1,0,out_speech_60);

reg [9:0] addr_speech_61;
wire [N-1:0] out_speech_61;
RAM_speech_61 r_speech_61(addr_speech_61,clk,,1,0,out_speech_61);

reg [9:0] addr_speech_62;
wire [N-1:0] out_speech_62;
RAM_speech_62 r_speech_62(addr_speech_62,clk,,1,0,out_speech_62);

reg [9:0] addr_speech_63;
wire [N-1:0] out_speech_63;
RAM_speech_63 r_speech_63(addr_speech_63,clk,,1,0,out_speech_63);

reg [9:0] addr_speech_64;
wire [N-1:0] out_speech_64;
RAM_speech_64 r_speech_64(addr_speech_64,clk,,1,0,out_speech_64);

reg [9:0] addr_speech_65;
wire [N-1:0] out_speech_65;
RAM_speech_65 r_speech_65(addr_speech_65,clk,,1,0,out_speech_65);

reg [9:0] addr_speech_66;
wire [N-1:0] out_speech_66;
RAM_speech_66 r_speech_66(addr_speech_66,clk,,1,0,out_speech_66);

reg [9:0] addr_speech_67;
wire [N-1:0] out_speech_67;
RAM_speech_67 r_speech_67(addr_speech_67,clk,,1,0,out_speech_67);

reg [9:0] addr_speech_68;
wire [N-1:0] out_speech_68;
RAM_speech_68 r_speech_68(addr_speech_68,clk,,1,0,out_speech_68);

reg [9:0] addr_speech_69;
wire [N-1:0] out_speech_69;
RAM_speech_69 r_speech_69(addr_speech_69,clk,,1,0,out_speech_69);

reg [9:0] addr_speech_70;
wire [N-1:0] out_speech_70;
RAM_speech_70 r_speech_70(addr_speech_70,clk,,1,0,out_speech_70);

reg [9:0] addr_speech_71;
wire [N-1:0] out_speech_71;
RAM_speech_71 r_speech_71(addr_speech_71,clk,,1,0,out_speech_71);

reg [9:0] addr_speech_72;
wire [N-1:0] out_speech_72;
RAM_speech_72 r_speech_72(addr_speech_72,clk,,1,0,out_speech_72);

reg [9:0] addr_speech_73;
wire [N-1:0] out_speech_73;
RAM_speech_73 r_speech_73(addr_speech_73,clk,,1,0,out_speech_73);

reg [9:0] addr_speech_74;
wire [N-1:0] out_speech_74;
RAM_speech_74 r_speech_74(addr_speech_74,clk,,1,0,out_speech_74);

reg [9:0] addr_speech_75;
wire [N-1:0] out_speech_75;
RAM_speech_75 r_speech_75(addr_speech_75,clk,,1,0,out_speech_75);

reg [9:0] addr_speech_76;
wire [N-1:0] out_speech_76;
RAM_speech_76 r_speech_76(addr_speech_76,clk,,1,0,out_speech_76);

reg [9:0] addr_speech_77;
wire [N-1:0] out_speech_77;
RAM_speech_77 r_speech_77(addr_speech_77,clk,,1,0,out_speech_77);

reg [9:0] addr_speech_78;
wire [N-1:0] out_speech_78;
RAM_speech_78 r_speech_78(addr_speech_78,clk,,1,0,out_speech_78);

reg [9:0] addr_speech_79;
wire [N-1:0] out_speech_79;
RAM_speech_79 r_speech_79(addr_speech_79,clk,,1,0,out_speech_79);

reg [9:0] addr_speech_80;
wire [N-1:0] out_speech_80;
RAM_speech_80 r_speech_80(addr_speech_80,clk,,1,0,out_speech_80);

reg [9:0] addr_speech_81;
wire [N-1:0] out_speech_81;
RAM_speech_81 r_speech_81(addr_speech_81,clk,,1,0,out_speech_81);

reg [9:0] addr_speech_82;
wire [N-1:0] out_speech_82;
RAM_speech_82 r_speech_82(addr_speech_82,clk,,1,0,out_speech_82);

reg [9:0] addr_speech_83;
wire [N-1:0] out_speech_83;
RAM_speech_83 r_speech_83(addr_speech_83,clk,,1,0,out_speech_83);

reg [9:0] addr_speech_84;
wire [N-1:0] out_speech_84;
RAM_speech_84 r_speech_84(addr_speech_84,clk,,1,0,out_speech_84);

reg [9:0] addr_speech_85;
wire [N-1:0] out_speech_85;
RAM_speech_85 r_speech_85(addr_speech_85,clk,,1,0,out_speech_85);

reg [9:0] addr_speech_86;
wire [N-1:0] out_speech_86;
RAM_speech_86 r_speech_86(addr_speech_86,clk,,1,0,out_speech_86);

reg [9:0] addr_speech_87;
wire [N-1:0] out_speech_87;
RAM_speech_87 r_speech_87(addr_speech_87,clk,,1,0,out_speech_87);

reg [9:0] addr_speech_88;
wire [N-1:0] out_speech_88;
RAM_speech_88 r_speech_88(addr_speech_88,clk,,1,0,out_speech_88);

reg [9:0] addr_speech_89;
wire [N-1:0] out_speech_89;
RAM_speech_89 r_speech_89(addr_speech_89,clk,,1,0,out_speech_89);

reg [9:0] addr_speech_90;
wire [N-1:0] out_speech_90;
RAM_speech_90 r_speech_90(addr_speech_90,clk,,1,0,out_speech_90);

reg [9:0] addr_speech_91;
wire [N-1:0] out_speech_91;
RAM_speech_91 r_speech_91(addr_speech_91,clk,,1,0,out_speech_91);

reg [9:0] addr_speech_92;
wire [N-1:0] out_speech_92;
RAM_speech_92 r_speech_92(addr_speech_92,clk,,1,0,out_speech_92);

reg [9:0] addr_speech_93;
wire [N-1:0] out_speech_93;
RAM_speech_93 r_speech_93(addr_speech_93,clk,,1,0,out_speech_93);

reg [9:0] addr_speech_94;
wire [N-1:0] out_speech_94;
RAM_speech_94 r_speech_94(addr_speech_94,clk,,1,0,out_speech_94);

reg [9:0] addr_speech_95;
wire [N-1:0] out_speech_95;
RAM_speech_95 r_speech_95(addr_speech_95,clk,,1,0,out_speech_95);

reg [9:0] addr_speech_96;
wire [N-1:0] out_speech_96;
RAM_speech_96 r_speech_96(addr_speech_96,clk,,1,0,out_speech_96);

reg [9:0] addr_speech_97;
wire [N-1:0] out_speech_97;
RAM_speech_97 r_speech_97(addr_speech_97,clk,,1,0,out_speech_97);

reg [9:0] addr_speech_98;
wire [N-1:0] out_speech_98;
RAM_speech_98 r_speech_98(addr_speech_98,clk,,1,0,out_speech_98);

reg [9:0] addr_speech_99;
wire [N-1:0] out_speech_99;
RAM_speech_99 r_speech_99(addr_speech_99,clk,,1,0,out_speech_99);

reg [9:0] addr_speech_100;
wire [N-1:0] out_speech_100;
RAM_speech_100 r_speech_100(addr_speech_100,clk,,1,0,out_speech_100);

reg [9:0] addr_speech_101;
wire [N-1:0] out_speech_101;
RAM_speech_101 r_speech_101(addr_speech_101,clk,,1,0,out_speech_101);

reg [9:0] addr_speech_102;
wire [N-1:0] out_speech_102;
RAM_speech_102 r_speech_102(addr_speech_102,clk,,1,0,out_speech_102);

reg [9:0] addr_speech_103;
wire [N-1:0] out_speech_103;
RAM_speech_103 r_speech_103(addr_speech_103,clk,,1,0,out_speech_103);

reg [9:0] addr_speech_104;
wire [N-1:0] out_speech_104;
RAM_speech_104 r_speech_104(addr_speech_104,clk,,1,0,out_speech_104);

reg [9:0] addr_speech_105;
wire [N-1:0] out_speech_105;
RAM_speech_105 r_speech_105(addr_speech_105,clk,,1,0,out_speech_105);

reg [9:0] addr_speech_106;
wire [N-1:0] out_speech_106;
RAM_speech_106 r_speech_106(addr_speech_106,clk,,1,0,out_speech_106);

reg [9:0] addr_speech_107;
wire [N-1:0] out_speech_107;
RAM_speech_107 r_speech_107(addr_speech_107,clk,,1,0,out_speech_107);

reg [9:0] addr_speech_108;
wire [N-1:0] out_speech_108;
RAM_speech_108 r_speech_108(addr_speech_108,clk,,1,0,out_speech_108);

reg [9:0] addr_speech_109;
wire [N-1:0] out_speech_109;
RAM_speech_109 r_speech_109(addr_speech_109,clk,,1,0,out_speech_109);

reg [9:0] addr_speech_110;
wire [N-1:0] out_speech_110;
RAM_speech_110 r_speech_110(addr_speech_110,clk,,1,0,out_speech_110);

reg [9:0] addr_speech_111;
wire [N-1:0] out_speech_111;
RAM_speech_111 r_speech_111(addr_speech_111,clk,,1,0,out_speech_111);

reg [9:0] addr_speech_112;
wire [N-1:0] out_speech_112;
RAM_speech_112 r_speech_112(addr_speech_112,clk,,1,0,out_speech_112);

reg [9:0] addr_speech_113;
wire [N-1:0] out_speech_113;
RAM_speech_113 r_speech_113(addr_speech_113,clk,,1,0,out_speech_113);

reg [9:0] addr_speech_114;
wire [N-1:0] out_speech_114;
RAM_speech_114 r_speech_114(addr_speech_114,clk,,1,0,out_speech_114);

reg [9:0] addr_speech_115;
wire [N-1:0] out_speech_115;
RAM_speech_115 r_speech_115(addr_speech_115,clk,,1,0,out_speech_115);

reg [9:0] addr_speech_116;
wire [N-1:0] out_speech_116;
RAM_speech_116 r_speech_116(addr_speech_116,clk,,1,0,out_speech_116);

reg [9:0] addr_speech_117;
wire [N-1:0] out_speech_117;
RAM_speech_117 r_speech_117(addr_speech_117,clk,,1,0,out_speech_117);

reg [9:0] addr_speech_118;
wire [N-1:0] out_speech_118;
RAM_speech_118 r_speech_118(addr_speech_118,clk,,1,0,out_speech_118);

reg [9:0] addr_speech_119;
wire [N-1:0] out_speech_119;
RAM_speech_119 r_speech_119(addr_speech_119,clk,,1,0,out_speech_119);

reg [9:0] addr_speech_120;
wire [N-1:0] out_speech_120;
RAM_speech_120 r_speech_120(addr_speech_120,clk,,1,0,out_speech_120);

reg [9:0] addr_speech_121;
wire [N-1:0] out_speech_121;
RAM_speech_121 r_speech_121(addr_speech_121,clk,,1,0,out_speech_121);

reg [9:0] addr_speech_122;
wire [N-1:0] out_speech_122;
RAM_speech_122 r_speech_122(addr_speech_122,clk,,1,0,out_speech_122);

reg [9:0] addr_speech_123;
wire [N-1:0] out_speech_123;
RAM_speech_123 r_speech_123(addr_speech_123,clk,,1,0,out_speech_123);

reg [9:0] addr_speech_124;
wire [N-1:0] out_speech_124;
RAM_speech_124 r_speech_124(addr_speech_124,clk,,1,0,out_speech_124);

reg [9:0] addr_speech_125;
wire [N-1:0] out_speech_125;
RAM_speech_125 r_speech_125(addr_speech_125,clk,,1,0,out_speech_125);

reg [9:0] addr_speech_126;
wire [N-1:0] out_speech_126;
RAM_speech_126 r_speech_126(addr_speech_126,clk,,1,0,out_speech_126);

reg [9:0] addr_speech_127;
wire [N-1:0] out_speech_127;
RAM_speech_127 r_speech_127(addr_speech_127,clk,,1,0,out_speech_127);

reg [9:0] addr_speech_128;
wire [N-1:0] out_speech_128;
RAM_speech_128 r_speech_128(addr_speech_128,clk,,1,0,out_speech_128);

reg [9:0] addr_speech_129;
wire [N-1:0] out_speech_129;
RAM_speech_129 r_speech_129(addr_speech_129,clk,,1,0,out_speech_129);

reg [9:0] addr_speech_130;
wire [N-1:0] out_speech_130;
RAM_speech_130 r_speech_130(addr_speech_130,clk,,1,0,out_speech_130);

reg [9:0] addr_speech_131;
wire [N-1:0] out_speech_131;
RAM_speech_131 r_speech_131(addr_speech_131,clk,,1,0,out_speech_131);

reg [9:0] addr_speech_132;
wire [N-1:0] out_speech_132;
RAM_speech_132 r_speech_132(addr_speech_132,clk,,1,0,out_speech_132);

reg [9:0] addr_speech_133;
wire [N-1:0] out_speech_133;
RAM_speech_133 r_speech_133(addr_speech_133,clk,,1,0,out_speech_133);

reg [9:0] addr_speech_134;
wire [N-1:0] out_speech_134;
RAM_speech_134 r_speech_134(addr_speech_134,clk,,1,0,out_speech_134);

reg [9:0] addr_speech_135;
wire [N-1:0] out_speech_135;
RAM_speech_135 r_speech_135(addr_speech_135,clk,,1,0,out_speech_135);

reg [9:0] addr_speech_136;
wire [N-1:0] out_speech_136;
RAM_speech_136 r_speech_136(addr_speech_136,clk,,1,0,out_speech_136);

reg [9:0] addr_speech_137;
wire [N-1:0] out_speech_137;
RAM_speech_137 r_speech_137(addr_speech_137,clk,,1,0,out_speech_137);

reg [9:0] addr_speech_138;
wire [N-1:0] out_speech_138;
RAM_speech_138 r_speech_138(addr_speech_138,clk,,1,0,out_speech_138);

reg [9:0] addr_speech_139;
wire [N-1:0] out_speech_139;
RAM_speech_139 r_speech_139(addr_speech_139,clk,,1,0,out_speech_139);

reg [9:0] addr_speech_140;
wire [N-1:0] out_speech_140;
RAM_speech_140 r_speech_140(addr_speech_140,clk,,1,0,out_speech_140);

reg [9:0] addr_speech_141;
wire [N-1:0] out_speech_141;
RAM_speech_141 r_speech_141(addr_speech_141,clk,,1,0,out_speech_141);

reg [9:0] addr_speech_142;
wire [N-1:0] out_speech_142;
RAM_speech_142 r_speech_142(addr_speech_142,clk,,1,0,out_speech_142);

reg [9:0] addr_speech_143;
wire [N-1:0] out_speech_143;
RAM_speech_143 r_speech_143(addr_speech_143,clk,,1,0,out_speech_143);

reg [9:0] addr_speech_144;
wire [N-1:0] out_speech_144;
RAM_speech_144 r_speech_144(addr_speech_144,clk,,1,0,out_speech_144);

reg [9:0] addr_speech_145;
wire [N-1:0] out_speech_145;
RAM_speech_145 r_speech_145(addr_speech_145,clk,,1,0,out_speech_145);

reg [9:0] addr_speech_146;
wire [N-1:0] out_speech_146;
RAM_speech_146 r_speech_146(addr_speech_146,clk,,1,0,out_speech_146);

reg [9:0] addr_speech_147;
wire [N-1:0] out_speech_147;
RAM_speech_147 r_speech_147(addr_speech_147,clk,,1,0,out_speech_147);

reg [9:0] addr_speech_148;
wire [N-1:0] out_speech_148;
RAM_speech_148 r_speech_148(addr_speech_148,clk,,1,0,out_speech_148);

reg [9:0] addr_speech_149;
wire [N-1:0] out_speech_149;
RAM_speech_149 r_speech_149(addr_speech_149,clk,,1,0,out_speech_149);

/*----------- RAM_speech for one_frame - 320 size ---------------------*/
reg [9:0] addr_sn;
reg [N-1:0] write_c2_sn;
reg re_c2_sn,we_c2_sn;
wire [N-1:0] read_c2_sn_out;
 
RAM_Sn_codec2_enc c2_sn (addr_sn,clk,write_c2_sn,re_c2_sn,we_c2_sn,read_c2_sn_out);   

/*----------- RAM_nlp_mem_fir - size 48 ---------------------*/
reg [9:0] addr_mem_fir;
reg [N1-1:0] in_mem_fir;
reg read_fir, write_fir;
wire [N1-1:0] out_mem_fir;
							 
RAM_nlp_mem_fir_80  mem_fir   (addr_mem_fir,clk,in_mem_fir,read_fir,write_fir,out_mem_fir);	

/*----------- RAM_nlp_sq - size 320 ---------------------*/
reg [9:0] addr_nlp_sq;
reg [N1-1:0] in_sq;
reg read_sq,write_sq;
wire [N1-1:0] out_sq;

RAM_nlp_sq_80    nlp_sq	   (addr_nlp_sq,clk,in_sq,read_sq,write_sq,out_sq);						 


//------------------------------------------------------------------
//                 -- Begin Declarations & Coding --                  
//------------------------------------------------------------------

always@(posedge clk or negedge rst)     // Determine STATE
begin

	if (rst == 1'b0)
		STATE <= START;
	else
		STATE <= NEXT_STATE;

end


always@(*)                              // Determine NEXT_STATE
begin
	case(STATE)

	START:
	begin
		if(start_codec2)
		begin
			NEXT_STATE = INIT_FOR;
		end
		else
		begin
			NEXT_STATE = START;
		end
		
	end

	INIT_FOR:
	begin
		NEXT_STATE = CHECK_I;
	end

	CHECK_I:
	begin
		if(i < 10'd2)
		begin
			NEXT_STATE = START_CODEC_ONE_FRAME;
		end
		else
		begin
			NEXT_STATE = DONE;
		end
	end

	START_CODEC_ONE_FRAME:
	begin
		NEXT_STATE = RUN_CODEC_ONE_FRAME;
	end

	RUN_CODEC_ONE_FRAME:
	begin
		if(done_oneframe)
		begin
			NEXT_STATE = GET_CODEC_ONE_FRAME;
		end
		else
		begin
			NEXT_STATE = RUN_CODEC_ONE_FRAME;
		end
		
						addr_sn = c_addr_sn;
						c_read_c2_sn_out = read_c2_sn_out;
						re_c2_sn = c_re_c2_sn;
						we_c2_sn = c_we_c2_sn;
						write_c2_sn = c_write_c2_sn;
						
						
						//mem_fir[48]
						addr_mem_fir = c_addr_mem_fir;
						c_out_mem_fir = out_mem_fir;
						read_fir = c_read_fir;
						write_fir = c_write_fir;
						in_mem_fir = c_in_mem_fir;
						
						//sq[320]
						addr_nlp_sq = c_addr_nlp_sq;
						c_out_sq = out_sq;
						read_sq = c_read_sq;
						write_sq = c_write_sq;
						in_sq = c_in_sq;
						
	end

	GET_CODEC_ONE_FRAME:
	begin
		NEXT_STATE = INCR_I;
	end

	INCR_I:
	begin
		NEXT_STATE = CHECK_I;
	end

	DONE:
	begin
		NEXT_STATE = DONE;
	end

	endcase
end


always@(posedge clk or negedge rst)     // Determine outputs
begin

	if (rst == 1'b0)
	begin

		done_codec2 <= 1'b0;

	end

	else
	begin
		case(STATE)

		START:
		begin
			done_codec2 <= 1'b0;
			clk_count <= 80'b1;
			count <= 4'd0;
		end

		INIT_FOR:
		begin
			i <= 10'd0;
		end

		CHECK_I:
		begin
			
		end

		START_CODEC_ONE_FRAME:
		begin
			start_oneframe <= 1'b1;
			/* in_mem_x <= 32'b0;
				in_mem_y <= 32'b0;
				in_prevf0 <= {16'd50,16'd0};
				in_xq0 <= 32'b0;
				in_xq1 <= 32'b0; */
				
			
			
			if(i == 10'd0)
			begin
				in_mem_x <= 32'b0;
				in_mem_y <= 32'b0;
				in_prevf0 <= {16'd50,16'd0};
				in_xq0 <= 32'b0;
				in_xq1 <= 32'b0;
				count <= count + 1'd1;
			end
			else
			begin
				in_mem_x <= out_mem_x;
				in_mem_y <= out_mem_y;
				in_prevf0 <= out_prevf0;
				in_xq0 <= out_xq0;
				in_xq1 <= out_xq1;
				
				count <= count + 1'd1;
			end
			
			
			
		end

		RUN_CODEC_ONE_FRAME:
		begin
			start_oneframe <= 1'b0;
			clk_count <= clk_count+1'b1; 
			
			 //Sn[320]
		
						
			
			case(i)
					10'd0:
					begin
					    addr_speech_0 <= c_addr_speech;
					    c_out_speech  <= out_speech_0;
					   //count <= count + 1'd1;
					end
					
					10'd1:
					begin
						//check_sig <= 10'd16;
						addr_speech_1 <= c_addr_speech;
			   		    c_out_speech  <= out_speech_1;
						//count <= count + 1'd1;
					  
					end
					10'd2:
					begin
					   addr_speech_2 <= c_addr_speech;
					   c_out_speech  <= out_speech_2;
					   //count <= count + 1'd1;
					  
					end
					
					10'd3:
					begin
					   addr_speech_3 <= c_addr_speech;
					   c_out_speech  <= out_speech_3;
					end
					10'd4:
					begin
					   addr_speech_4 <= c_addr_speech;
					   c_out_speech  <= out_speech_4;
					end
					10'd5:
					begin
					   addr_speech_5 <= c_addr_speech;
					   c_out_speech  <= out_speech_5;
					end
					10'd6:
					begin
					   addr_speech_6 <= c_addr_speech;
					   c_out_speech  <= out_speech_6;
					end
					10'd7:
					begin
					   addr_speech_7 <= c_addr_speech;
					   c_out_speech  <= out_speech_7;
					end
					10'd8:
					begin
					   addr_speech_8 <= c_addr_speech;
					   c_out_speech  <= out_speech_8;
					end
					10'd9:
					begin
					   addr_speech_9 <= c_addr_speech;
					   c_out_speech  <= out_speech_9;
					end
					
					10'd10:
					begin
						addr_speech_10 <= c_addr_speech;
						c_out_speech  <= out_speech_10;
					end

					10'd11:
					begin
						addr_speech_11 <= c_addr_speech;
						c_out_speech  <= out_speech_11;
					end

					10'd12:
					begin
						addr_speech_12 <= c_addr_speech;
						c_out_speech  <= out_speech_12;
					end

					10'd13:
					begin
						addr_speech_13 <= c_addr_speech;
						c_out_speech  <= out_speech_13;
					end

					10'd14:
					begin
						addr_speech_14 <= c_addr_speech;
						c_out_speech  <= out_speech_14;
					end

					10'd15:
					begin
						addr_speech_15 <= c_addr_speech;
						c_out_speech  <= out_speech_15;
					end

					10'd16:
					begin
						addr_speech_16 <= c_addr_speech;
						c_out_speech  <= out_speech_16;
					end

					10'd17:
					begin
						addr_speech_17 <= c_addr_speech;
						c_out_speech  <= out_speech_17;
					end

					10'd18:
					begin
						addr_speech_18 <= c_addr_speech;
						c_out_speech  <= out_speech_18;
					end

					10'd19:
					begin
						addr_speech_19 <= c_addr_speech;
						c_out_speech  <= out_speech_19;
					end

					10'd20:
					begin
						addr_speech_20 <= c_addr_speech;
						c_out_speech  <= out_speech_20;
					end

					10'd21:
					begin
						addr_speech_21 <= c_addr_speech;
						c_out_speech  <= out_speech_21;
					end

					10'd22:
					begin
						addr_speech_22 <= c_addr_speech;
						c_out_speech  <= out_speech_22;
					end

					10'd23:
					begin
						addr_speech_23 <= c_addr_speech;
						c_out_speech  <= out_speech_23;
					end

					10'd24:
					begin
						addr_speech_24 <= c_addr_speech;
						c_out_speech  <= out_speech_24;
					end

					10'd25:
					begin
						addr_speech_25 <= c_addr_speech;
						c_out_speech  <= out_speech_25;
					end

					10'd26:
					begin
						addr_speech_26 <= c_addr_speech;
						c_out_speech  <= out_speech_26;
					end

					10'd27:
					begin
						addr_speech_27 <= c_addr_speech;
						c_out_speech  <= out_speech_27;
					end

					10'd28:
					begin
						addr_speech_28 <= c_addr_speech;
						c_out_speech  <= out_speech_28;
					end

					10'd29:
					begin
						addr_speech_29 <= c_addr_speech;
						c_out_speech  <= out_speech_29;
					end

					10'd30:
					begin
						addr_speech_30 <= c_addr_speech;
						c_out_speech  <= out_speech_30;
					end

					10'd31:
					begin
						addr_speech_31 <= c_addr_speech;
						c_out_speech  <= out_speech_31;
					end

					10'd32:
					begin
						addr_speech_32 <= c_addr_speech;
						c_out_speech  <= out_speech_32;
					end

					10'd33:
					begin
						addr_speech_33 <= c_addr_speech;
						c_out_speech  <= out_speech_33;
					end

					10'd34:
					begin
						addr_speech_34 <= c_addr_speech;
						c_out_speech  <= out_speech_34;
					end

					10'd35:
					begin
						addr_speech_35 <= c_addr_speech;
						c_out_speech  <= out_speech_35;
					end

					10'd36:
					begin
						addr_speech_36 <= c_addr_speech;
						c_out_speech  <= out_speech_36;
					end

					10'd37:
					begin
						addr_speech_37 <= c_addr_speech;
						c_out_speech  <= out_speech_37;
					end

					10'd38:
					begin
						addr_speech_38 <= c_addr_speech;
						c_out_speech  <= out_speech_38;
					end

					10'd39:
					begin
						addr_speech_39 <= c_addr_speech;
						c_out_speech  <= out_speech_39;
					end

					10'd40:
					begin
						addr_speech_40 <= c_addr_speech;
						c_out_speech  <= out_speech_40;
					end

					10'd41:
					begin
						addr_speech_41 <= c_addr_speech;
						c_out_speech  <= out_speech_41;
					end

					10'd42:
					begin
						addr_speech_42 <= c_addr_speech;
						c_out_speech  <= out_speech_42;
					end

					10'd43:
					begin
						addr_speech_43 <= c_addr_speech;
						c_out_speech  <= out_speech_43;
					end

					10'd44:
					begin
						addr_speech_44 <= c_addr_speech;
						c_out_speech  <= out_speech_44;
					end

					10'd45:
					begin
						addr_speech_45 <= c_addr_speech;
						c_out_speech  <= out_speech_45;
					end

					10'd46:
					begin
						addr_speech_46 <= c_addr_speech;
						c_out_speech  <= out_speech_46;
					end

					10'd47:
					begin
						addr_speech_47 <= c_addr_speech;
						c_out_speech  <= out_speech_47;
					end

					10'd48:
					begin
						addr_speech_48 <= c_addr_speech;
						c_out_speech  <= out_speech_48;
					end

					10'd49:
					begin
						addr_speech_49 <= c_addr_speech;
						c_out_speech  <= out_speech_49;
					end

					10'd50:
					begin
						addr_speech_50 <= c_addr_speech;
						c_out_speech  <= out_speech_50;
					end

					10'd51:
					begin
						addr_speech_51 <= c_addr_speech;
						c_out_speech  <= out_speech_51;
					end

					10'd52:
					begin
						addr_speech_52 <= c_addr_speech;
						c_out_speech  <= out_speech_52;
					end

					10'd53:
					begin
						addr_speech_53 <= c_addr_speech;
						c_out_speech  <= out_speech_53;
					end

					10'd54:
					begin
						addr_speech_54 <= c_addr_speech;
						c_out_speech  <= out_speech_54;
					end

					10'd55:
					begin
						addr_speech_55 <= c_addr_speech;
						c_out_speech  <= out_speech_55;
					end

					10'd56:
					begin
						addr_speech_56 <= c_addr_speech;
						c_out_speech  <= out_speech_56;
					end

					10'd57:
					begin
						addr_speech_57 <= c_addr_speech;
						c_out_speech  <= out_speech_57;
					end

					10'd58:
					begin
						addr_speech_58 <= c_addr_speech;
						c_out_speech  <= out_speech_58;
					end

					10'd59:
					begin
						addr_speech_59 <= c_addr_speech;
						c_out_speech  <= out_speech_59;
					end

					10'd60:
					begin
						addr_speech_60 <= c_addr_speech;
						c_out_speech  <= out_speech_60;
					end

					10'd61:
					begin
						addr_speech_61 <= c_addr_speech;
						c_out_speech  <= out_speech_61;
					end

					10'd62:
					begin
						addr_speech_62 <= c_addr_speech;
						c_out_speech  <= out_speech_62;
					end

					10'd63:
					begin
						addr_speech_63 <= c_addr_speech;
						c_out_speech  <= out_speech_63;
					end

					10'd64:
					begin
						addr_speech_64 <= c_addr_speech;
						c_out_speech  <= out_speech_64;
					end

					10'd65:
					begin
						addr_speech_65 <= c_addr_speech;
						c_out_speech  <= out_speech_65;
					end

					10'd66:
					begin
						addr_speech_66 <= c_addr_speech;
						c_out_speech  <= out_speech_66;
					end

					10'd67:
					begin
						addr_speech_67 <= c_addr_speech;
						c_out_speech  <= out_speech_67;
					end

					10'd68:
					begin
						addr_speech_68 <= c_addr_speech;
						c_out_speech  <= out_speech_68;
					end

					10'd69:
					begin
						addr_speech_69 <= c_addr_speech;
						c_out_speech  <= out_speech_69;
					end

					10'd70:
					begin
						addr_speech_70 <= c_addr_speech;
						c_out_speech  <= out_speech_70;
					end

					10'd71:
					begin
						addr_speech_71 <= c_addr_speech;
						c_out_speech  <= out_speech_71;
					end

					10'd72:
					begin
						addr_speech_72 <= c_addr_speech;
						c_out_speech  <= out_speech_72;
					end

					10'd73:
					begin
						addr_speech_73 <= c_addr_speech;
						c_out_speech  <= out_speech_73;
					end

					10'd74:
					begin
						addr_speech_74 <= c_addr_speech;
						c_out_speech  <= out_speech_74;
					end

					10'd75:
					begin
						addr_speech_75 <= c_addr_speech;
						c_out_speech  <= out_speech_75;
					end

					10'd76:
					begin
						addr_speech_76 <= c_addr_speech;
						c_out_speech  <= out_speech_76;
					end

					10'd77:
					begin
						addr_speech_77 <= c_addr_speech;
						c_out_speech  <= out_speech_77;
					end

					10'd78:
					begin
						addr_speech_78 <= c_addr_speech;
						c_out_speech  <= out_speech_78;
					end

					10'd79:
					begin
						addr_speech_79 <= c_addr_speech;
						c_out_speech  <= out_speech_79;
					end

					10'd80:
					begin
						addr_speech_80 <= c_addr_speech;
						c_out_speech  <= out_speech_80;
					end

					10'd81:
					begin
						addr_speech_81 <= c_addr_speech;
						c_out_speech  <= out_speech_81;
					end

					10'd82:
					begin
						addr_speech_82 <= c_addr_speech;
						c_out_speech  <= out_speech_82;
					end

					10'd83:
					begin
						addr_speech_83 <= c_addr_speech;
						c_out_speech  <= out_speech_83;
					end

					10'd84:
					begin
						addr_speech_84 <= c_addr_speech;
						c_out_speech  <= out_speech_84;
					end

					10'd85:
					begin
						addr_speech_85 <= c_addr_speech;
						c_out_speech  <= out_speech_85;
					end

					10'd86:
					begin
						addr_speech_86 <= c_addr_speech;
						c_out_speech  <= out_speech_86;
					end

					10'd87:
					begin
						addr_speech_87 <= c_addr_speech;
						c_out_speech  <= out_speech_87;
					end

					10'd88:
					begin
						addr_speech_88 <= c_addr_speech;
						c_out_speech  <= out_speech_88;
					end

					10'd89:
					begin
						addr_speech_89 <= c_addr_speech;
						c_out_speech  <= out_speech_89;
					end

					10'd90:
					begin
						addr_speech_90 <= c_addr_speech;
						c_out_speech  <= out_speech_90;
					end

					10'd91:
					begin
						addr_speech_91 <= c_addr_speech;
						c_out_speech  <= out_speech_91;
					end

					10'd92:
					begin
						addr_speech_92 <= c_addr_speech;
						c_out_speech  <= out_speech_92;
					end

					10'd93:
					begin
						addr_speech_93 <= c_addr_speech;
						c_out_speech  <= out_speech_93;
					end

					10'd94:
					begin
						addr_speech_94 <= c_addr_speech;
						c_out_speech  <= out_speech_94;
					end

					10'd95:
					begin
						addr_speech_95 <= c_addr_speech;
						c_out_speech  <= out_speech_95;
					end

					10'd96:
					begin
						addr_speech_96 <= c_addr_speech;
						c_out_speech  <= out_speech_96;
					end

					10'd97:
					begin
						addr_speech_97 <= c_addr_speech;
						c_out_speech  <= out_speech_97;
					end

					10'd98:
					begin
						addr_speech_98 <= c_addr_speech;
						c_out_speech  <= out_speech_98;
					end

					10'd99:
					begin
						addr_speech_99 <= c_addr_speech;
						c_out_speech  <= out_speech_99;
					end

					10'd100:
					begin
						addr_speech_100 <= c_addr_speech;
						c_out_speech  <= out_speech_100;
					end

					10'd101:
					begin
						addr_speech_101 <= c_addr_speech;
						c_out_speech  <= out_speech_101;
					end

					10'd102:
					begin
						addr_speech_102 <= c_addr_speech;
						c_out_speech  <= out_speech_102;
					end

					10'd103:
					begin
						addr_speech_103 <= c_addr_speech;
						c_out_speech  <= out_speech_103;
					end

					10'd104:
					begin
						addr_speech_104 <= c_addr_speech;
						c_out_speech  <= out_speech_104;
					end

					10'd105:
					begin
						addr_speech_105 <= c_addr_speech;
						c_out_speech  <= out_speech_105;
					end

					10'd106:
					begin
						addr_speech_106 <= c_addr_speech;
						c_out_speech  <= out_speech_106;
					end

					10'd107:
					begin
						addr_speech_107 <= c_addr_speech;
						c_out_speech  <= out_speech_107;
					end

					10'd108:
					begin
						addr_speech_108 <= c_addr_speech;
						c_out_speech  <= out_speech_108;
					end

					10'd109:
					begin
						addr_speech_109 <= c_addr_speech;
						c_out_speech  <= out_speech_109;
					end

					10'd110:
					begin
						addr_speech_110 <= c_addr_speech;
						c_out_speech  <= out_speech_110;
					end

					10'd111:
					begin
						addr_speech_111 <= c_addr_speech;
						c_out_speech  <= out_speech_111;
					end

					10'd112:
					begin
						addr_speech_112 <= c_addr_speech;
						c_out_speech  <= out_speech_112;
					end

					10'd113:
					begin
						addr_speech_113 <= c_addr_speech;
						c_out_speech  <= out_speech_113;
					end

					10'd114:
					begin
						addr_speech_114 <= c_addr_speech;
						c_out_speech  <= out_speech_114;
					end

					10'd115:
					begin
						addr_speech_115 <= c_addr_speech;
						c_out_speech  <= out_speech_115;
					end

					10'd116:
					begin
						addr_speech_116 <= c_addr_speech;
						c_out_speech  <= out_speech_116;
					end

					10'd117:
					begin
						addr_speech_117 <= c_addr_speech;
						c_out_speech  <= out_speech_117;
					end

					10'd118:
					begin
						addr_speech_118 <= c_addr_speech;
						c_out_speech  <= out_speech_118;
					end

					10'd119:
					begin
						addr_speech_119 <= c_addr_speech;
						c_out_speech  <= out_speech_119;
					end

					10'd120:
					begin
						addr_speech_120 <= c_addr_speech;
						c_out_speech  <= out_speech_120;
					end

					10'd121:
					begin
						addr_speech_121 <= c_addr_speech;
						c_out_speech  <= out_speech_121;
					end

					10'd122:
					begin
						addr_speech_122 <= c_addr_speech;
						c_out_speech  <= out_speech_122;
					end

					10'd123:
					begin
						addr_speech_123 <= c_addr_speech;
						c_out_speech  <= out_speech_123;
					end

					10'd124:
					begin
						addr_speech_124 <= c_addr_speech;
						c_out_speech  <= out_speech_124;
					end

					10'd125:
					begin
						addr_speech_125 <= c_addr_speech;
						c_out_speech  <= out_speech_125;
					end

					10'd126:
					begin
						addr_speech_126 <= c_addr_speech;
						c_out_speech  <= out_speech_126;
					end

					10'd127:
					begin
						addr_speech_127 <= c_addr_speech;
						c_out_speech  <= out_speech_127;
					end

					10'd128:
					begin
						addr_speech_128 <= c_addr_speech;
						c_out_speech  <= out_speech_128;
					end

					10'd129:
					begin
						addr_speech_129 <= c_addr_speech;
						c_out_speech  <= out_speech_129;
					end

					10'd130:
					begin
						addr_speech_130 <= c_addr_speech;
						c_out_speech  <= out_speech_130;
					end

					10'd131:
					begin
						addr_speech_131 <= c_addr_speech;
						c_out_speech  <= out_speech_131;
					end

					10'd132:
					begin
						addr_speech_132 <= c_addr_speech;
						c_out_speech  <= out_speech_132;
					end

					10'd133:
					begin
						addr_speech_133 <= c_addr_speech;
						c_out_speech  <= out_speech_133;
					end

					10'd134:
					begin
						addr_speech_134 <= c_addr_speech;
						c_out_speech  <= out_speech_134;
					end

					10'd135:
					begin
						addr_speech_135 <= c_addr_speech;
						c_out_speech  <= out_speech_135;
					end

					10'd136:
					begin
						addr_speech_136 <= c_addr_speech;
						c_out_speech  <= out_speech_136;
					end

					10'd137:
					begin
						addr_speech_137 <= c_addr_speech;
						c_out_speech  <= out_speech_137;
					end

					10'd138:
					begin
						addr_speech_138 <= c_addr_speech;
						c_out_speech  <= out_speech_138;
					end

					10'd139:
					begin
						addr_speech_139 <= c_addr_speech;
						c_out_speech  <= out_speech_139;
					end

					10'd140:
					begin
						addr_speech_140 <= c_addr_speech;
						c_out_speech  <= out_speech_140;
					end

					10'd141:
					begin
						addr_speech_141 <= c_addr_speech;
						c_out_speech  <= out_speech_141;
					end

					10'd142:
					begin
						addr_speech_142 <= c_addr_speech;
						c_out_speech  <= out_speech_142;
					end

					10'd143:
					begin
						addr_speech_143 <= c_addr_speech;
						c_out_speech  <= out_speech_143;
					end

					10'd144:
					begin
						addr_speech_144 <= c_addr_speech;
						c_out_speech  <= out_speech_144;
					end

					10'd145:
					begin
						addr_speech_145 <= c_addr_speech;
						c_out_speech  <= out_speech_145;
					end

					10'd146:
					begin
						addr_speech_146 <= c_addr_speech;
						c_out_speech  <= out_speech_146;
					end

					10'd147:
					begin
						addr_speech_147 <= c_addr_speech;
						c_out_speech  <= out_speech_147;
					end

					10'd148:
					begin
						addr_speech_148 <= c_addr_speech;
						c_out_speech  <= out_speech_148;
					end

					10'd149:
					begin
						addr_speech_149 <= c_addr_speech;
						c_out_speech  <= out_speech_149;
					end			
					
			endcase
			
			
			
			
		end

		GET_CODEC_ONE_FRAME:
		begin

			// count <= count + 1'd1;
			 
			 
			 
			 case(i)
			 10'd0:
			 begin
				//encoded_bits_0 <= check_sum;//c_encode_model_wo;//c_check_in_real;	
				encoded_bits_0 <= c_encoded_bits;
				sp0 <= c_speech_lsp0;
				sp1 <= c_speech_lsp1;
				sp2 <= c_speech_lsp2;
				sp3 <= c_speech_lsp3;
				sp4 <= c_speech_lsp4;
				sp5 <= c_speech_lsp5;
				sp6 <= c_speech_lsp6;
				sp7 <= c_speech_lsp7;
				sp8 <= c_speech_lsp8;
				sp9 <= c_speech_lsp9;
				
				quant0 <= c_lsp0;
				quant1 <= c_lsp1;
				quant2 <= c_lsp2;
				quant3 <= c_lsp3;
				quant4 <= c_lsp4;
				quant5 <= c_lsp5;
				quant6 <= c_lsp6;
				quant7 <= c_lsp7;
				quant8 <= c_lsp8;
				quant9 <= c_lsp9;
				
				c_nlp_pitch1 <= c_pitch1;
				c_nlp_pitch2 <= c_pitch2;
				
				c_encode_woe <= c_cmax2;
				
			 end
			 10'd1:
			 begin
				encoded_bits_1 <= c_encoded_bits;
				//encoded_bits_1 <= check_sum;
				
				
			 end
			/*  10'd142:
			 begin
				encoded_bits_2 <= c_encoded_bits;
			 end
			 10'd143:
			 begin
				encoded_bits_3 <= c_encoded_bits;
			 end
			 10'd144:
			 begin
				encoded_bits_4 <= c_encoded_bits;
			 end
			 10'd145:
			 begin
				encoded_bits_5 <= c_encoded_bits;
			 end
			 10'd146:
			 begin
				encoded_bits_6 <= c_encoded_bits;
			 end
			 10'd147:
			 begin
				encoded_bits_7 <= c_encoded_bits;
			 end
			 10'd148:
			 begin
				encoded_bits_8 <= c_encoded_bits;
			 end
			 
			 10'd149:
			 begin
				encoded_bits_9 <= c_encoded_bits;
			 end */
			 
			 default:
			 begin
				//encoded_bits_0 <= 48'b0;
			 end
			
			endcase
			
		end

		INCR_I:
		begin
			i <= i + 10'd1;
			

		end

		DONE:
		begin
			done_codec2 <= 1'b1;
		end

		endcase
	end

end


endmodule