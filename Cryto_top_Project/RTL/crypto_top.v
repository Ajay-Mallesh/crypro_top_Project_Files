// ==========================================================================
// MULTI-VOLTAGE PHYSICAL DESIGN RTL
// ==========================================================================
// PROJECT        : Multi-Voltage Crypto Core
// AUTHOR         : AJAYMALLESH
// VERSION        : 1.0 (Silicon-Ready RTL)
// GENERATION DATE: 25/04/2026 01:19:26 PM
// DESCRIPTION    : Verilog Code 
// ==========================================================================

module crypto_top #(
    parameter DATA_W = 128,
    parameter NUM_ROUNDS = 64
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire [DATA_W-1:0] plaintext_in,
    input  wire              valid_in,
    output wire [DATA_W-1:0] ciphertext_out,
    output wire              valid_out
);

    // 0.75V outputs coming from the Low Power domain
    wire [DATA_W-1:0] lp_key_stream;
    wire              lp_key_valid;

    // THE BRIDGE: 0.95V Top-Domain Registers to legally step up the voltage
    reg [DATA_W-1:0] top_key_stream;
    reg              top_key_valid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            top_key_stream <= {DATA_W{1'b0}};
            top_key_valid  <= 1'b0;
        end else begin
            top_key_stream <= lp_key_stream;
            top_key_valid  <= lp_key_valid;
        end
    end

    // Instance: Low Power Domain (0.75V)
    key_schedule_lp #(
        .DATA_W(DATA_W)
    ) u_key_gen_lp (
        .clk        (clk),
        .rst_n      (rst_n),
        .valid_in   (valid_in),
        .key_stream (lp_key_stream),
        .key_valid  (lp_key_valid)
    );

    // Instance: Top Domain Cipher (0.95V)
    cipher_core_hp #(
        .DATA_W(DATA_W),
        .NUM_ROUNDS(NUM_ROUNDS)
    ) u_cipher_hp (
        .clk            (clk),
        .rst_n          (rst_n),
        .data_in        (plaintext_in),
        .key_stream     (top_key_stream), 
        .valid_in       (valid_in & top_key_valid),
        .data_out       (ciphertext_out),
        .valid_out      (valid_out)
    );
endmodule

module key_schedule_lp #(
    parameter DATA_W = 128
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              valid_in,
    output reg  [DATA_W-1:0] key_stream,
    output reg               key_valid
);
    reg [DATA_W-1:0] lfsr_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr_reg   <= {DATA_W{1'b1}}; 
            key_stream <= {DATA_W{1'b0}};
            key_valid  <= 1'b0;
        end else if (valid_in) begin
            lfsr_reg <= {lfsr_reg[DATA_W-2:0], lfsr_reg[127] ^ lfsr_reg[126] ^ lfsr_reg[121] ^ lfsr_reg[8]};
            key_stream <= lfsr_reg;
            key_valid  <= 1'b1;
        end else begin
            key_valid  <= 1'b0;
        end
    end
endmodule

module cipher_core_hp #(
    parameter DATA_W = 128,
    parameter NUM_ROUNDS = 64
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire [DATA_W-1:0] data_in,
    input  wire [DATA_W-1:0] key_stream,
    input  wire              valid_in,
    output reg  [DATA_W-1:0] data_out,
    output reg               valid_out
);
    reg [DATA_W-1:0] round_data  [0:NUM_ROUNDS];
    reg              round_valid [0:NUM_ROUNDS];
    wire [DATA_W-1:0] sub_perm_out [0:NUM_ROUNDS-1];

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i <= NUM_ROUNDS; i = i + 1) begin
                round_data[i]  <= {DATA_W{1'b0}};
                round_valid[i] <= 1'b0;
            end
        end else begin
            round_data[0]  <= data_in;
            round_valid[0] <= valid_in;
            for (i = 0; i < NUM_ROUNDS; i = i + 1) begin
                if (round_valid[i]) begin
                    round_data[i+1] <= sub_perm_out[i] ^ key_stream;
                    round_valid[i+1] <= 1'b1;
                end else begin
                    round_valid[i+1] <= 1'b0;
                end
            end
        end
    end

    genvar g;
    generate
        for (g = 0; g < NUM_ROUNDS; g = g + 1) begin : SPN_ROUNDS
            spn_round_logic #(.ROUND_ID(g)) u_spn (
                .data_in (round_data[g]),
                .data_out(sub_perm_out[g])
            );
        end
    endgenerate

    always @(*) begin
        data_out  = round_data[NUM_ROUNDS];
        valid_out = round_valid[NUM_ROUNDS];
    end
endmodule

module spn_round_logic #(parameter ROUND_ID = 0) (
    input  wire [127:0] data_in,
    output wire [127:0] data_out
);
    wire [127:0] sbox_out;
    genvar k;
    generate
        for (k = 0; k < 32; k = k + 1) begin : SBOX_ARRAY
            sbox_4bit u_sbox (
                .in_nibble (data_in[(k*4)+3 : k*4]),
                .out_nibble(sbox_out[(k*4)+3 : k*4])
            );
        end
    endgenerate
    assign data_out = {sbox_out[63:0], sbox_out[127:64]}; 
endmodule

module sbox_4bit (
    input  wire [3:0] in_nibble,
    output reg  [3:0] out_nibble
);
    always @(*) begin
        case (in_nibble)
            4'h0: out_nibble = 4'hC; 4'h1: out_nibble = 4'h5;
            4'h2: out_nibble = 4'h6; 4'h3: out_nibble = 4'hB;
            4'h4: out_nibble = 4'h9; 4'h5: out_nibble = 4'h0;
            4'h6: out_nibble = 4'hA; 4'h7: out_nibble = 4'hD;
            4'h8: out_nibble = 4'h3; 4'h9: out_nibble = 4'hE;
            4'hA: out_nibble = 4'hF; 4'hB: out_nibble = 4'h8;
            4'hC: out_nibble = 4'h4; 4'hD: out_nibble = 4'h7;
            4'hE: out_nibble = 4'h1; 4'hF: out_nibble = 4'h2;
            default: out_nibble = 4'h0;
        endcase
    end
endmodule