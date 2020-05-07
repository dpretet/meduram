parameter AGENT1 = 1;
parameter AGENT2 = 2;

task checkAgent(input integer agent);
    // Finish simulation if don't use a correct index
    if (agent > 2) begin
        `ERROR("No more than 2 agents are supported in this testbench");
        $finish;
    end
endtask

task writeAgent(input integer agent, input integer addr, input integer data);
begin
    string msg;
    $sformat(msg, "Write access start with agent %0d", agent);
    `INFO(msg);
    checkAgent(agent);

    // Wait for posedge and write a data into memory
    @ (posedge aclk);
    if (agent == AGENT1) begin
        wren1 = 1'b1;
        wraddr1 = addr;
        wrdata1 = data;
    end else if (agent == AGENT2) begin
        wren2 = 1'b1;
        wraddr2 = addr;
        wrdata2 = data;
    end

    // Deassert the xfer after one cycle
    @ (posedge aclk);
    if (agent == AGENT1) wren1 = 1'b0;
    else if (agent == AGENT2) wren2 = 1'b0;
    `INFO("Write access done");
end
endtask

task readAgent(input integer agent, input integer addr, output integer value);
begin
    string msg;
    $sformat(msg, "Read access start with agent %0d", agent);
    `INFO(msg);
    checkAgent(agent);

    // Wait for posedge and read a memory address
    @ (posedge aclk);
    if (agent == AGENT1) begin
        rden1 = 1'b1;
        rdaddr1 = addr;
    end else if (agent == AGENT2) begin
        rden2 = 1'b1;
        rdaddr2 = addr;
    end

    // Deassert the request and read data
    @ (posedge aclk);
    @ (negedge aclk);
    if (agent == AGENT1) begin
        rden1 = 1'b0;
        value = rddata1;
    end else if (agent == AGENT2) begin
        rden2 = 1'b0;
        value = rddata2;
    end
    $sformat(msg, "Value read: %x", value);
    `INFO(msg);
    `INFO("Read access done");
end
endtask
