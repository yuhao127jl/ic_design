 /*                                                                      
 Copyright 2020 Blue Liang, liangkangnan@163.com
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
 Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */

`include "defines.v"


// core local interruptor module
// �����жϹ����ٲ�ģ��
module clint(

    input wire clk,
    input wire rst,

    // from core
    input wire[`INT_BUS] int_flag_i,         // �ж������ź�

    // from id
    input wire[`InstBus] inst_i,             // ָ������
    input wire[`InstAddrBus] inst_addr_i,    // ָ���ַ

    // from ctrl
    input wire[`Hold_Flag_Bus] hold_flag_i,  // ��ˮ����ͣ��־

    // from csr_reg
    input wire[`RegBus] data_i,              // CSR�Ĵ�����������

    // to csr_reg
    output reg we_o,                         // дCSR�Ĵ�����־
    output reg[`MemAddrBus] waddr_o,         // дCSR�Ĵ�����ַ
    output reg[`MemAddrBus] raddr_o,         // ��CSR�Ĵ�����ַ
    output reg[`RegBus] data_o,              // дCSR�Ĵ�������

    // to ex
    output reg[`InstAddrBus] int_addr_o,     // ���жϵ�ָ���ַ
    output reg int_assert_o                  // �жϱ�־

    );


    // ״̬����
    localparam STATE_IDLE      = 4'b0001;
    localparam STATE_ASSERT    = 4'b0010;
    localparam STATE_WAIT_MRET = 4'b0100;
    localparam STATE_MRET      = 4'b1000;

    reg[3:0] state;
    reg[3:0] next_state;


    // ״̬����
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            state <= STATE_IDLE;
        end else begin
            state <= next_state;
        end
    end

    // ״̬�л�
    always @ (*) begin
        if (rst == `RstEnable) begin
            next_state <= STATE_IDLE;
        end else begin
            case (state)
                STATE_IDLE: begin
                    // ĿǰֻҪ�������ж��źŷ�����������Ӧ.
                    // ���������ж����ȼ�(Ƕ��)ʱ��Ҫ�޸�������߼�
                    if (int_flag_i != `INT_NONE) begin
                        next_state <= STATE_ASSERT;
                    end else begin
                        next_state <= STATE_IDLE;
                    end
                end
                STATE_ASSERT: begin
                    next_state <= STATE_WAIT_MRET;
                end
                STATE_WAIT_MRET: begin
                    if (inst_i == `INST_MRET) begin
                        next_state <= STATE_MRET;
                    end else begin
                        next_state <= STATE_WAIT_MRET;
                    end
                end
                STATE_MRET: begin
                    next_state <= STATE_IDLE;
                end
                default: begin
                    next_state <= STATE_IDLE;
                end
            endcase
        end
    end

    // ���ݲ�ͬ��״̬����ȡ��Ӧ��CSR�Ĵ���
    always @ (*) begin
        if (rst == `RstEnable) begin
            raddr_o <= `ZeroWord;
        end else begin
            case (state)
                STATE_IDLE: begin
                    raddr_o <= {20'h0, `CSR_MTVEC};
                end
                STATE_ASSERT: begin
                    raddr_o <= {20'h0, `CSR_MTVEC};
                end
                STATE_WAIT_MRET: begin
                    raddr_o <= {20'h0, `CSR_MEPC};
                end
                STATE_MRET: begin
                    raddr_o <= {20'h0, `CSR_MEPC};
                end
                default: begin
                    raddr_o <= {20'h0, `CSR_MTVEC};
                end
            endcase
        end
    end

    // �����ж��ź�
    // �ж���Ӧ���жϷ���ʱ��Ҫ��
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            int_assert_o <= `INT_DEASSERT;
            int_addr_o <= `ZeroWord;
        end else begin
            case (state)
                STATE_ASSERT: begin
                    int_assert_o <= `INT_ASSERT;
                    int_addr_o <= data_i;
                end
                STATE_MRET: begin
                    int_assert_o <= `INT_ASSERT;
                    int_addr_o <= data_i;
                end
                default: begin
                    int_assert_o <= `INT_DEASSERT;
                    int_addr_o <= `ZeroWord;
                end
            endcase
        end
    end

    // ���ݲ�ͬ��״̬��д��Ӧ��CSR�Ĵ���
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            we_o <= `WriteDisable;
            waddr_o <= `ZeroWord;
            data_o <= `ZeroWord;
        end else begin
            if (state == STATE_ASSERT) begin
                we_o <= `WriteEnable;
                waddr_o <= {20'h0, `CSR_MEPC};
                data_o <= inst_addr_i;
            end else begin
                we_o <= `WriteEnable;
                waddr_o <= {20'h0, `CSR_MCAUSE};
                data_o <= {24'h0, int_flag_i};
            end
        end
    end

endmodule
