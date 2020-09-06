// copyright damien pretet 2020
// distributed under the mit license
// https://opensource.org/licenses/mit-license.php

parameter AGENT1 = 1;
parameter AGENT2 = 2;

/// Check if the agent index to use is correct
/// Finish simulation if don't use a correct index
task checkAgent(input integer agent);
    if (agent < AGENT1) begin
        `ERROR("Agent index can't lower than 1");
        $finish;
    end
    if (agent > AGENT2) begin
        `ERROR("No more than 2 agents are supported in this testbench");
        $finish;
    end
endtask

task write_address(input integer agent, input addr);

    `ifdef VERBOSE
        string msg;
        $sformat(msg, "Write address for agent %0d", agent);
        `INFO(msg);
    `endif

    checkAgent(agent);

    if (agent == AGENT1) begin
        @ (posedge aclk_wr1);
        awvalid1 = 1'b1;
        awaddr1 = addr;
    end
    if (agent == AGENT2) begin
        @ (posedge aclk_wr2);
        awvalid2 = 1'b1;
        awaddr2 = addr;
    end

    `ifdef VERBOSE
        `INFO("Address written");
    `endif

endtask

task disable_write_address(input integer agent);

    `ifdef VERBOSE
        string msg;
        $sformat(msg, "Write address for agent %0d", agent);
        `INFO(msg);
    `endif

    checkAgent(agent);

    if (agent == AGENT1) begin
        awvalid1 = 1'b0;
    end
    if (agent == AGENT2) begin
        awvalid2 = 1'b0;
    end
    `ifdef VERBOSE
        `INFO("Address access now disabled");
    `endif

endtask

task write_data(input integer agent, input data);

    `ifdef VERBOSE
        string msg;
        $sformat(msg, "Write data for agent %0d", agent);
        `INFO(msg);
    `endif

    checkAgent(agent);

    if (agent == AGENT1) begin
        @ (posedge aclk_wr1);
        wvalid1 = 1'b1;
        wdata1 = data;
    end
    if (agent == AGENT2) begin
        @ (posedge aclk_wr2);
        wvalid2 = 1'b1;
        wdata2 = data;
    end
    `ifdef VERBOSE
        `INFO("Data written");
    `endif

endtask

task disable_write_data(input integer agent);

    `ifdef VERBOSE
        string msg;
        $sformat(msg, "Write data for agent %0d", agent);
        `INFO(msg);
    `endif

    checkAgent(agent);

    if (agent == AGENT1) begin
        wvalid1 = 1'b0;
    end
    if (agent == AGENT2) begin
        wvalid2 = 1'b0;
    end
    `ifdef VERBOSE
        `INFO("Data access disable");
    `endif

endtask

task ack_cmpl(input integer agent, input resp);

    `ifdef VERBOSE
        string msg;
        $sformat(msg, "Read completion for agent %0d", agent);
        `INFO(msg);
    `endif

    checkAgent(agent);

    if (agent == AGENT1) begin
        @ (posedge aclk_wr1);
        bready1 = 1'b1;
    end
    if (agent == AGENT2) begin
        @ (posedge aclk_wr2);
        bready2 = 1'b1;
    end

    `assert(resp, "Except BRESP = 0");

    `ifdef VERBOSE
        `INFO("Completion read");
    `endif

endtask

task stop_cmpl(input integer agent);

    `ifdef VERBOSE
        string msg;
        $sformat(msg, "Read completion for agent %0d", agent);
        `INFO(msg);
    `endif

    checkAgent(agent);

    if (agent == AGENT1) begin
        @ (posedge aclk_wr1);
        bready1 = 1'b0;
    end
    if (agent == AGENT2) begin
        @ (posedge aclk_wr2);
        bready2 = 1'b0;
    end

    `ifdef VERBOSE
        `INFO("Completion ack done");
    `endif

endtask

task read_address(input integer agent, input addr);

    `ifdef VERBOSE
        string msg;
        $sformat(msg, "read address for agent %0d", agent);
        `INFO(msg);
    `endif

    checkAgent(agent);

    if (agent == AGENT1) begin
        @ (posedge aclk_rd1);
        arvalid1 = 1'b1;
        araddr1 = addr;
    end
    if (agent == AGENT2) begin
        @ (posedge aclk_rd2);
        arvalid2 = 1'b1;
        araddr2 = addr;
    end

    `ifdef VERBOSE
        `INFO("Address written");
    `endif

endtask

task disable_read_address(input integer agent);

    `ifdef VERBOSE
        string msg;
        $sformat(msg, "read address for agent %0d", agent);
        `INFO(msg);
    `endif

    checkAgent(agent);

    if (agent == AGENT1) begin
        arvalid1 = 1'b0;
    end
    if (agent == AGENT2) begin
        arvalid2 = 1'b0;
    end
    `ifdef VERBOSE
        `INFO("Address access now disabled");
    `endif

endtask

task read_data(input integer agent, output data, output resp);

    `ifdef VERBOSE
        string msg;
        $sformat(msg, "read data for agent %0d", agent);
        `INFO(msg);
    `endif

    checkAgent(agent);

    if (agent == AGENT1) begin
        rready1 = 1'b1;
        rdata = rdata1;
        resp = rresp1;
    end
    if (agent == AGENT2) begin
        rready2 = 1'b1;
        data = rdata2;
        resp = rresp2;
    end
    `ifdef VERBOSE
        `INFO("Data read");
    `endif

endtask

task disable_read_data(input integer agent);

    `ifdef VERBOSE
        string msg;
        $sformat(msg, "read data for agent %0d", agent);
        `INFO(msg);
    `endif

    checkAgent(agent);

    if (agent == AGENT1) begin
        rready1 = 1'b0;
    end
    if (agent == AGENT2) begin
        rready2 = 1'b0;
    end
    `ifdef VERBOSE
        `INFO("Data access disable");
    `endif

endtask

