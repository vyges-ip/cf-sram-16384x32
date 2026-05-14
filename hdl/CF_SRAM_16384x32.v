// SPDX-FileCopyrightText: 2025 Umbralogic Technologies LLC d/b/a ChipFoundry and its Licensors, All Rights Reserved
// ========================================================================================
//
// This software is proprietary and protected by copyright and other intellectual property
// rights. Any reproduction, modification, translation, compilation, or representation
// beyond expressly permitted use is strictly prohibited.
//
// Access and use of this software are granted solely for integration into semiconductor
// chip designs created by you as part of ChipFoundry shuttles or ChipFoundry managed
// production programs. It is exclusively for Umbralogic Technologies LLC d/b/a ChipFoundry production purposes, and you may
// not modify or convey the software for any other purpose.
//
// DISCLAIMER: UMBRALOGIC TECHNOLOGIES LLC D/B/A CHIPFOUNDRY AND ITS LICENSORS PROVIDE THIS MATERIAL "AS IS," WITHOUT
// WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
// Umbralogic Technologies LLC d/b/a ChipFoundry reserves the right to make changes without notice. Neither Umbralogic Technologies LLC d/b/a ChipFoundry nor its
// licensors assume any liability arising from the application or use of any product or
// circuit described herein. Umbralogic Technologies LLC d/b/a ChipFoundry products are not authorized for use as components
// in life-support devices.
//
// This license is subject to the terms of any separate agreement you have with Umbralogic Technologies LLC d/b/a ChipFoundry
// concerning the use of this software, which shall control in case of conflict.

`timescale 1 ns / 1 ps

`ifdef USE_POWER_PINS
    `define USE_PG_PIN
`endif

module CF_SRAM_16384x32_core (
    output [31:0] DO,
    output ScanOutCC,
    input  [31:0] DI,
    input  [31:0] BEN,
    input  [13:0] AD,      // 14-bit address for 16384 words
    input  EN,
    input  R_WB,
    input  CLKin,
    input  WLBI,
    input  WLOFF,
    input  TM,
    input  SM,
    input  ScanInCC,
    input  ScanInDL,
    input  ScanInDR,
    input  vpwrpc,
    input  vpwrac,
`ifdef USE_POWER_PINS
    input  vgnd,
    input  vnb,
    input  vpb,
    input  vpwra,
    input  vpwrm,
    input  vpwrp
`endif
);

    parameter NB = 32;    // Number of Data Bits
    parameter NA = 14;    // Number of Address Bits (16384 = 2^14)
    parameter NW = 16384; // Number of WORDS
    parameter SEED = 0;   // User can define SEED at memory instantiation

    // Address decoding for the sixteen 1024x32 SRAMs
    // The upper 4 bits of the address select the SRAM macro
    wire [9:0] sram_addr = AD[9:0];  // Lower 10 bits for each 1024x32 SRAM
    wire [15:0] sram_cs;

    assign sram_cs[0] = (AD[13:10] == 4'b0000) && EN;
    assign sram_cs[1] = (AD[13:10] == 4'b0001) && EN;
    assign sram_cs[2] = (AD[13:10] == 4'b0010) && EN;
    assign sram_cs[3] = (AD[13:10] == 4'b0011) && EN;
    assign sram_cs[4] = (AD[13:10] == 4'b0100) && EN;
    assign sram_cs[5] = (AD[13:10] == 4'b0101) && EN;
    assign sram_cs[6] = (AD[13:10] == 4'b0110) && EN;
    assign sram_cs[7] = (AD[13:10] == 4'b0111) && EN;
    assign sram_cs[8] = (AD[13:10] == 4'b1000) && EN;
    assign sram_cs[9] = (AD[13:10] == 4'b1001) && EN;
    assign sram_cs[10] = (AD[13:10] == 4'b1010) && EN;
    assign sram_cs[11] = (AD[13:10] == 4'b1011) && EN;
    assign sram_cs[12] = (AD[13:10] == 4'b1100) && EN;
    assign sram_cs[13] = (AD[13:10] == 4'b1101) && EN;
    assign sram_cs[14] = (AD[13:10] == 4'b1110) && EN;
    assign sram_cs[15] = (AD[13:10] == 4'b1111) && EN;

    // SRAM data outputs
    wire [31:0] sram_do_0, sram_do_1, sram_do_2, sram_do_3;
    wire [31:0] sram_do_4, sram_do_5, sram_do_6, sram_do_7;
    wire [31:0] sram_do_8, sram_do_9, sram_do_10, sram_do_11;
    wire [31:0] sram_do_12, sram_do_13, sram_do_14, sram_do_15;
    wire [31:0] sram_do;

    // Scan chain outputs
    wire sram_scan_out_cc_0, sram_scan_out_cc_1, sram_scan_out_cc_2, sram_scan_out_cc_3;
    wire sram_scan_out_cc_4, sram_scan_out_cc_5, sram_scan_out_cc_6, sram_scan_out_cc_7;
    wire sram_scan_out_cc_8, sram_scan_out_cc_9, sram_scan_out_cc_10, sram_scan_out_cc_11;
    wire sram_scan_out_cc_12, sram_scan_out_cc_13, sram_scan_out_cc_14, sram_scan_out_cc_15;

    // Instantiate the sixteen 1024x32 SRAM macros
    CF_SRAM_1024x32 sram0 (
        .DO(sram_do_0),
        .ScanOutCC(sram_scan_out_cc_0),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[0]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram1 (
        .DO(sram_do_1),
        .ScanOutCC(sram_scan_out_cc_1),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[1]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram2 (
        .DO(sram_do_2),
        .ScanOutCC(sram_scan_out_cc_2),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[2]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram3 (
        .DO(sram_do_3),
        .ScanOutCC(sram_scan_out_cc_3),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[3]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram4 (
        .DO(sram_do_4),
        .ScanOutCC(sram_scan_out_cc_4),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[4]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram5 (
        .DO(sram_do_5),
        .ScanOutCC(sram_scan_out_cc_5),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[5]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram6 (
        .DO(sram_do_6),
        .ScanOutCC(sram_scan_out_cc_6),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[6]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram7 (
        .DO(sram_do_7),
        .ScanOutCC(sram_scan_out_cc_7),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[7]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram8 (
        .DO(sram_do_8),
        .ScanOutCC(sram_scan_out_cc_8),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[8]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram9 (
        .DO(sram_do_9),
        .ScanOutCC(sram_scan_out_cc_9),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[9]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram10 (
        .DO(sram_do_10),
        .ScanOutCC(sram_scan_out_cc_10),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[10]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram11 (
        .DO(sram_do_11),
        .ScanOutCC(sram_scan_out_cc_11),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[11]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram12 (
        .DO(sram_do_12),
        .ScanOutCC(sram_scan_out_cc_12),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[12]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram13 (
        .DO(sram_do_13),
        .ScanOutCC(sram_scan_out_cc_13),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[13]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram14 (
        .DO(sram_do_14),
        .ScanOutCC(sram_scan_out_cc_14),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[14]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    CF_SRAM_1024x32 sram15 (
        .DO(sram_do_15),
        .ScanOutCC(sram_scan_out_cc_15),
        .AD(sram_addr),
        .BEN(BEN),
        .CLKin(CLKin),
        .DI(DI),
        .EN(sram_cs[15]),
        .R_WB(R_WB),
        .ScanInCC(ScanInCC),
        .ScanInDL(ScanInDL),
        .ScanInDR(ScanInDR),
        .SM(SM),
        .TM(TM),
        .WLBI(WLBI),
        .WLOFF(WLOFF),
`ifdef USE_POWER_PINS
        .vgnd(vgnd),
        .vnb(vnb),
        .vpb(vpb),
        .vpwra(vpwra),
        .vpwrm(vpwrm),
        .vpwrp(vpwrp),
`endif
        .vpwrpc(vpwrpc),
        .vpwrac(vpwrac)
    );

    // Mux the read data from the sixteen SRAMs
    assign sram_do = sram_cs[0] ? sram_do_0 :
                     sram_cs[1] ? sram_do_1 :
                     sram_cs[2] ? sram_do_2 :
                     sram_cs[3] ? sram_do_3 :
                     sram_cs[4] ? sram_do_4 :
                     sram_cs[5] ? sram_do_5 :
                     sram_cs[6] ? sram_do_6 :
                     sram_cs[7] ? sram_do_7 :
                     sram_cs[8] ? sram_do_8 :
                     sram_cs[9] ? sram_do_9 :
                     sram_cs[10] ? sram_do_10 :
                     sram_cs[11] ? sram_do_11 :
                     sram_cs[12] ? sram_do_12 :
                     sram_cs[13] ? sram_do_13 :
                     sram_cs[14] ? sram_do_14 :
                                  sram_do_15;

    // Mux the scan chain output
    assign ScanOutCC = sram_cs[0] ? sram_scan_out_cc_0 :
                       sram_cs[1] ? sram_scan_out_cc_1 :
                       sram_cs[2] ? sram_scan_out_cc_2 :
                       sram_cs[3] ? sram_scan_out_cc_3 :
                       sram_cs[4] ? sram_scan_out_cc_4 :
                       sram_cs[5] ? sram_scan_out_cc_5 :
                       sram_cs[6] ? sram_scan_out_cc_6 :
                       sram_cs[7] ? sram_scan_out_cc_7 :
                       sram_cs[8] ? sram_scan_out_cc_8 :
                       sram_cs[9] ? sram_scan_out_cc_9 :
                       sram_cs[10] ? sram_scan_out_cc_10 :
                       sram_cs[11] ? sram_scan_out_cc_11 :
                       sram_cs[12] ? sram_scan_out_cc_12 :
                       sram_cs[13] ? sram_scan_out_cc_13 :
                       sram_cs[14] ? sram_scan_out_cc_14 :
                                    sram_scan_out_cc_15;

    // Output assignment
    assign DO = sram_do;

endmodule

